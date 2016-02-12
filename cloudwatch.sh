#!/bin/bash

# information taken from http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/mon-scripts.html

# install prerequisites
sudo apt-get update
sudo apt-get install -y unzip
sudo apt-get install -y libwww-perl libdatetime-perl

# download and install cloudwatch
rm -rf aws-scripts-mon
curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O
unzip CloudWatchMonitoringScripts-1.2.1.zip
rm CloudWatchMonitoringScripts-1.2.1.zip
cd aws-scripts-mon

# Set the Access Keys for the specifically created CloudWatch IAM user in to a file called awscreds
aws_key="AWSAccessKeyId=xxxxxxxxxxxx"
aws_secret="AWSSecretKey=yyyyyyyyyyyy"
cat >awscreds <<EOL
${aws_key}
${aws_secret}
EOL

# Test run
./mon-put-instance-data.pl --mem-util --verify --verbose --aws-credential-file=awscreds

# Add Crontab item for submitting metrics every 5 minutes
command="~/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --from-cron --aws-credential-file=/home/ubuntu/aws-scripts-mon/awscreds"
job="*/5 * * * * $command"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
