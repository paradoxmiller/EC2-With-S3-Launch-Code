#!/bin/bash -e
AMIID=$(aws ec2 describe-images --filters "Name=description, \
Values=Amazon Linux AMI 2015.03.? x86_64 HVM GP2" \
--query "Images[0].ImageId" --output text)

VPCID=$(aws ec2 describe-vpcs --filter "Name=isDefault, Values=true" \
--query "Vpcs[0].VpcId" --output text)

SUBNETID=$(aws ec2 describe-subnets --filters "Name=vpc-id, Values=$VPCID" \
--query "Subnets[0].SubnetId" --output text)

SGID=$(aws ec2 create-security-group --group-name mysecuritygroup \
--description "My security group" --vpc-id $VPCID --output text)

aws ec2 authorize-security-group-ingress --group-id $SGID \
--protocol tcp --port 22 --cidr 0.0.0.0/0

INSTANCEID=$(aws ec2 run-instances --image-id $AMIID --key-name mykey \
--instance-type t2.micro --security-group-ids $SGID \
--subnet-id $SUBNETID --query "Instances[0].InstanceId" --output text)

echo "waiting for $INSTANCEID ..."

aws ec2 wait instance-running --instance-ids $INSTANCEID

PUBLICNAME=$(aws ec2 describe-instances --instance-ids $INSTANCEID \
--query "Reservations[0].Instances[0].PublicDnsName" --output text)

echo "$INSTANCEID is accepting SSH connections under $PUBLICNAME"
echo "ssh -i mykey.pem ec2-user@$PUBLICNAME"

echo ".... .... .... .... .... .... .... ...."
read -r -p "Enter the bucket name: " bname
echo "$bname"
aws s3api create-bucket --bucket $bname


echo "Time to terminate the EC2 instance $INSTANCEID and"
echo "the S3 bucket $bname"
echo ".... .... .... .... .... .... ...."
echo "Do you wish to continue?:"

select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

read -p "Press [Enter] key to terminate $INSTANCEID ..."
aws ec2 terminate-instances --instance-ids $INSTANCEID
echo "terminating $INSTANCEID ..."
aws ec2 wait instance-terminated --instance-ids $INSTANCEID
aws ec2 delete-security-group --group-id $SGID

echo ".... .... .... .... .... .... .... ...."
read -p "Press [Enter] key to terminate $bname ..."
aws s3 rb --force s3://$bname

echo "...Done"
