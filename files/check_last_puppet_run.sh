#!/bin/bash
# puppet managed file

PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin"

MAXDIFF=7200
WARNDIFF=3600

while getopts 'c:w:' OPT; do
  case $OPT in
    c)  MAXDIFF=$OPTARG;;
    w)  WARNDIFF=$OPTARG;;
  esac
done

shift $(($OPTIND - 1))

PUPPETBIN=$(which puppet 2>/dev/null)

if [ -z "${PUPPETBIN}" ];
then
  echo "CRITICAL - puppet not found"
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
  echo "CRITICAL - Unsupported puppet version"
  exit 2
fi

if [ ! -e "${LAST_RUN_FILE}" ];
then
	echo "CRITICAL - ${LAST_RUN_FILE} does not exists"
	exit 2
fi

if [ ! -e "${LAST_RUN_REPORT}" ];
then
	echo "CRITICAL - ${LAST_RUN_REPORT} does not exists"
	exit 2
fi

PERFDATA="$PERFDATA $(grep resources: ${LAST_RUN_FILE} -A7 | grep -v resources: | paste '-sd;' | sed -e 's/: /=/g' -e 's/^[^a-zA-Z]*//' -e 's/[ \t]+/ /g')"

#
# outputs
#
# # grep -i catalo /var/lib/puppet/state/last_run_report.yaml
#       message: "Could not retrieve catalog from remote server: Error 400 on SERVER: Puppet::Parser::AST::Resource failed with error ArgumentError: Could not find declared class sssd::monit at /etc/puppet/manifests/site.pp:919 on node testvm.systemadmin.es"
#       message: "Using cached catalog"
#       message: "Finished catalog run in 7.96 seconds"
#

grep "Using cached catalog" "${LAST_RUN_REPORT}" >/dev/null 2>&1
if [ "$?" -eq 0 ];
then
  echo "CRITICAL - server using cached catalog |${PERFDATA}"
  exit 2
fi

# # grep -i catalo /var/lib/puppet/state/last_run_report.yaml
#       message: "Could not retrieve catalog from remote server: Error 400 on SERVER: Puppet::Parser::AST::Resource failed with error ArgumentError: Invalid resource type pam::securetty at /etc/puppet/manifests/site.pp:356 on node demovm.systemadmin.es"
#       message: "Not using cache on failed catalog"
#       message: "Could not retrieve catalog; skipping run"
#
grep "Could not retrieve catalog from remote server" ${LAST_RUN_REPORT} >/dev/null 2>&1
if [ "$?" -eq 0 ];
then
  echo "CRITICAL - could not retrieve catalog from remote server |${PERFDATA}"
  exit 2
fi

LAST_RUN=$(grep last_run "${LAST_RUN_FILE}" 2>/dev/null | awk '{ print $NF }')

if [ -z "$LAST_RUN" ];
then
	echo "CRITICAL - error getting data from last_run_summary.yaml"
	exit 2
fi

NOW=$(date +%s)

DIFF_LAST_RUN=$(($NOW-$LAST_RUN))

if [ "$?" -ne 0 ];
then
  echo "CRITICAL - unable to fect last run data"
  exit 2
fi

if [ -z "${DIFF_LAST_RUN}" ];
then
  echo "CRITICAL - unable to fect last run data"
  exit 2
fi

PERFDATA="${PERFDATA}; difflastrun=${DIFF_LAST_RUN};"

if [ "${DIFF_LAST_RUN}" -ge "${MAXDIFF}" ];
then
	echo "CRITICAL - last run: ${DIFF_LAST_RUN} seconds ago |${PERFDATA}"
	exit 2
fi

if [ "${DIFF_LAST_RUN}" -ge "${WARNDIFF}" ];
then
  echo "WARNING - last run: ${DIFF_LAST_RUN} seconds ago |${PERFDATA}"
  exit 1
fi

# # grep -i catalo /var/lib/puppet/state/last_run_report.yaml
#       message: "Caching catalog for demovm.systemadmin.es"
#       message: "Finished catalog run in 10.89 seconds"
grep "Finished catalog run" "${LAST_RUN_REPORT}" >/dev/null 2>&1
if [ "$?" -eq 0 ];
then
  echo "OK - last run: ${DIFF_LAST_RUN} seconds ago |${PERFDATA}"
  exit 0
else
  grep "Applied catalog in " "${LAST_RUN_REPORT}" >/dev/null 2>&1
  if [ "$?" -eq 0 ];
  then
    echo "OK - last run: ${DIFF_LAST_RUN} seconds ago |${PERFDATA}"
    exit 0
  else
    echo "CRITICAL - puppet agent does not report to have finished to apply the catalog |$PERFDATA"
    exit 3
  fi
fi
