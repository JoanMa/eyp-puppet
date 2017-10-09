#!/bin/bash

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

DIR='/var/lib/puppet'
MAXDIFF=7200
WARNDIFF=3600

while getopts 'd:hc:w:' OPT; do
  case $OPT in
    d)  DIR=$OPTARG;;
    c)  MAXDIFF=$OPTARG;;
    w)  WARNDIFF=$OPTARG;;
    h)  JELP="yes";;
    *)  JELP="yes";;
  esac
done

shift $(($OPTIND - 1))

#/var/lib/puppet/state/last_run_summary.yaml

if [ ! -e "${DIR}/state/last_run_summary.yaml" ];
then
	echo "last_run_summary.yaml does not exists"
	exit 2
fi

if [ ! -e "${DIR}/state/last_run_report.yaml" ];
then
	echo "last_run_report.yaml does not exists"
	exit 2
fi

LAST_RUN=$(grep last_run ${DIR}/state/last_run_summary.yaml | awk '{ print $NF }')

if [ -z "$LAST_RUN" ];
then
	echo "error getting data from last_run_summary.yaml"
	exit 2
fi

NOW=$(date +%s)

DIFF_LAST_RUN=$(($NOW-$LAST_RUN))

# PERFDATA="$PERFDATA difflastrun=$DIFF_LAST_RUN;"

PERFDATA="$PERFDATA $(grep resources: ${DIR}/state/last_run_summary.yaml -A7 | grep -v resources: | paste '-sd;')"

if [ $DIFF_LAST_RUN -ge $MAXDIFF ];
then
	echo "CRITICAL - last run: $DIFF_LAST_RUN seconds ago |$PERFDATA"
	exit 2
fi

if [ $DIFF_LAST_RUN -ge $WARNDIFF ];
then
        echo "WARNING - last run: $DIFF_LAST_RUN seconds ago |$PERFDATA"
        exit 1
fi

#
# outputs
#
# # grep -i catalo /var/lib/puppet/state/last_run_report.yaml
#       message: "Could not retrieve catalog from remote server: Error 400 on SERVER: Puppet::Parser::AST::Resource failed with error ArgumentError: Could not find declared class sssd::monit at /etc/puppet/manifests/site.pp:919 on node centos7.vm"
#       message: "Using cached catalog"
#       message: "Finished catalog run in 7.96 seconds"
#

grep "Using cached catalog" ${DIR}/state/last_run_report.yaml >/dev/null 2>&1
if [ "$?" -eq 0 ];
then
  echo "CRITICAL - server using cached catalog |$PERFDATA"
  exit 2
fi

# # grep -i catalo /var/lib/puppet/state/last_run_report.yaml
#       message: "Could not retrieve catalog from remote server: Error 400 on SERVER: Puppet::Parser::AST::Resource failed with error ArgumentError: Invalid resource type pam::securetty at /etc/puppet/manifests/site.pp:356 on node ar-tst2-ebsdb01.lifecapnet.com"
#       message: "Not using cache on failed catalog"
#       message: "Could not retrieve catalog; skipping run"
#
grep "Could not retrieve catalog from remote server" ${DIR}/state/last_run_report.yaml >/dev/null 2>&1
if [ "$?" -eq 0 ];
then
  echo "CRITICAL - could not retrieve catalog from remote server |$PERFDATA"
  exit 2
fi

# # grep -i catalo /var/lib/puppet/state/last_run_report.yaml
#       message: "Caching catalog for ar-mgmt-svn01.lifecapnet.com"
#       message: "Finished catalog run in 10.89 seconds"
grep "Finished catalog run" ${DIR}/state/last_run_report.yaml >/dev/null 2>&1
if [ "$?" -eq 0 ];
then
  echo "OK - last run: $DIFF_LAST_RUN seconds ago |$PERFDATA"
  exit 0
else
  echo "CRITICAL - puppet agent does not report to have finished to apply the catalog |$PERFDATA"
  exit 3
fi
