#!/bin/bash
# puppet managed file
# snmpd compatible check

PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin"

PUPPETBIN=$(which puppet 2>/dev/null)

if [ -z "${PUPPETBIN}" ];
then
  # puppet not found
  exit 2
fi

PUPPET_VER="$(${PUPPETBIN} --version 2>/dev/null)"

if [[ $PUPPET_VER = 3* ]];
then
  LAST_RUN_FILE='/var/lib/puppet/state/last_run_summary.yaml'
  LAST_RUN_REPORT='/var/lib/puppet/state/last_run_report.yaml'
elif [[ $PUPPET_VER = 5* ]];
then
  LAST_RUN_FILE='/opt/puppetlabs/puppet/cache/state/last_run_summary.yaml'
  LAST_RUN_REPORT='/opt/puppetlabs/puppet/cache/state/last_run_report.yaml'
else
  exit 3
fi

if [ ! -e "${LAST_RUN_FILE}" ];
then
	# last_run_summary.yaml does not exists
	exit 4
fi

if [ ! -e "${LAST_RUN_REPORT}" ];
then
	# last_run_report.yaml does not exists
	exit 5
fi

LAST_RUN=$(grep last_run ${LAST_RUN_FILE} 2>/dev/null | awk '{ print $NF }')

if [ -z "$LAST_RUN" ];
then
	# error getting data from last_run_summary.yaml
	exit 6
fi

#
# outputs
#
# # grep -i catalo /var/lib/puppet/state/last_run_report.yaml
#       message: "Could not retrieve catalog from remote server: Error 400 on SERVER: Puppet::Parser::AST::Resource failed with error ArgumentError: Could not find declared class sssd::monit at /etc/puppet/manifests/site.pp:919 on node centos7.systemadmin.es"
#       message: "Using cached catalog"
#       message: "Finished catalog run in 7.96 seconds"
#

grep "Using cached catalog" ${LAST_RUN_REPORT} >/dev/null 2>&1
if [ "$?" -eq 0 ];
then
  # server using cached catalog
  exit 7
fi

# # grep -i catalo /var/lib/puppet/state/last_run_report.yaml
#       message: "Could not retrieve catalog from remote server: Error 400 on SERVER: Puppet::Parser::AST::Resource failed with error ArgumentError: Invalid resource type pam::securetty at /etc/puppet/manifests/site.pp:356 on node testvm.systemadmin.es"
#       message: "Not using cache on failed catalog"
#       message: "Could not retrieve catalog; skipping run"
#
grep "Could not retrieve catalog from remote server" ${LAST_RUN_REPORT} >/dev/null 2>&1
if [ "$?" -eq 0 ];
then
  # could not retrieve catalog from remote server
  exit 8
fi

#Notice: Skipping run of Puppet configuration client; administratively disabled (Reason: 'reason not specified');
#Use 'puppet agent --enable' to re-enable.
tail -n 2 /var/log/puppet/puppet.log | grep disable >/dev/null 2>&1
if [ "$?" -eq 0 ];
then
  # minion is disabled
  exit 9
fi

NOW=$(date +%s)

DIFF_LAST_RUN=$(($NOW-$LAST_RUN))
RESOURCES="$(grep resources: ${LAST_RUN_FILE} -A7 | grep -v resources: | paste '-sd;' | sed -e 's/: /=/g' -e 's/^[^a-zA-Z]*//' -e 's/[ \t]+/ /g')"

echo "${RESOURCES}; difflastrun=${DIFF_LAST_RUN};"
exit 0
