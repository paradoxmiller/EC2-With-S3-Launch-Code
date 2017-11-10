#!/bin/bash
# Script to create S3 bucket from the AWS CLI

read -r -p "Enter the bucket name: " bname
echo "$bname"
aws s3api create-bucket --bucket $bname


read -p "Press [Enter] key to terminate $bname ..."
aws s3 rb --force s3://$bname


echo "...Done"

