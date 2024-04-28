#!/bin/bash/

source ./common.sh #calling common.sh script

check_root


dnf module disable nodejs -y &>>$LOGFILE

dnf module enable nodejs:20 -y &>>$LOGFILE

dnf install nodejs -y &>>$LOGFILE

id expense &>>$LOGFILE

if [ $? -ne 0 ]
then
    echo "User expense need to be created"
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating expense user"
else
    echo -e "$Y user expense already present .. SKIPPING $N"
fi

mkdir -p /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE

npm install &>>$LOGFILE

cp /home/ec2-user/expense-shell-1/backend.service /etc/systemd/system/backend.service &>>$LOGFILE

systemctl daemon-reload &>>$LOGFILE

systemctl start backend &>>$LOGFILE

systemctl enable backend &>>$LOGFILE

dnf install mysql -y &>>$LOGFILE

mysql -h db.muvva.online -uroot -p${mysql_root_password} < /app/schema/backend.sql

systemctl restart backend &>>$LOGFILE