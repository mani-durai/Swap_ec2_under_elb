#!/bin/bash
rm -rf /opt/scripts/instance.txt
DATE=`date +%Y-%m-%d`
MAIL_ID=test@example.com
LB_NAME=testt-lb
SERVER1=i-XXXXX
SERVER2=i-XXXXX
Instance=`aws elb describe-load-balancers --load-balancer-name "LB_NAME"  --query LoadBalancerDescriptions[].Instances[].InstanceId --output=text`

if [ $SERVER1 == $Instance ];then

  echo "current running instance as SERVER1 in under the LB_NAME:"$Instance >> instance.txt
  aws elb register-instances-with-load-balancer --load-balancer-name "LB_NAME" --instances $SERVER2
  echo "Register the SERVER2 instance in LB_NAME:"$SERVER2 >> instance.txt
  sleep(3);
  SERVER2_service_status=`aws elb describe-instance-health --load-balancer-name "LB_NAME" --instances $SERVER2  |  awk '{ print $5 }'`
  echo "instance health status in SERVER2:"$SERVER2_service_status >> instance.txt
  aws elb deregister-instances-from-load-balancer --load-balancer-name "LB_NAME" --instances $SERVER1
  echo "Deregister SERVER1 instance in LB_NAME:"$SERVER1 >> instance.txt
  cat instance.txt | mailx -s "swap instance PROD_SERVER1 to PROD_SERVER2 in LB_NAME $DATE" -r MAIL_ID   MAIL_ID

else

  echo "current running instance as SERVER2 in under the LB_NAME:"$Instance >> instance.txt
  aws elb register-instances-with-load-balancer --load-balancer-name "LB_NAME" --instances $SERVER1
  echo "Register the SERVER1 instance in LB_NAME:"$SERVER1 >> instance.txt
  sleep(3);
  SERVER1_service_status=`aws elb describe-instance-health --load-balancer-name "LB_NAME" --instances $SERVER1  |  awk '{ print $5 }'`
  echo "instance health status in SERVER1:"$SERVER1_service_status >> instance.txt
  aws elb deregister-instances-from-load-balancer --load-balancer-name "LB_NAME" --instances $SERVER2
  echo "Deregister SERVER2 instance in LB_NAME:"$SERVER2 >> instance.txt
  cat instance.txt | mailx -s "swap instance PROD_SERVER2 to PROD_SERVER1 in LB_NAME $DATE" -r MAIL_ID  MAIL_ID

fi
