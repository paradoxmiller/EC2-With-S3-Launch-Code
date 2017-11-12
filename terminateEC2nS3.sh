#!/bin/bash -e
echo "This script will terminate the EC2 instance $INSTANCEID and"
echo "the S3 bucket $bname"

read -p "Press [Enter] key to terminate $INSTANCEID ..."
aws ec2 terminate-instances --instance-ids $INSTANCEID
echo "terminating $INSTANCEID ..."
aws ec2 wait instance-terminated --instance-ids $INSTANCEID
aws ec2 delete-security-group --group-id $SGID

echo ".... .... .... .... .... .... .... ...."
read -p "Press [Enter] key to terminate $bname ..."
aws s3 rb --force s3://$bname

echo "...Done"
