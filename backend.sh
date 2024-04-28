#!/bin/bash/

source ./common.sh #calling common.sh script

check_root

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R failure $N"
        exit 197
    else
        echo -e "$2 is $G success $N"
    fi
}


dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling older nodejs versions"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "enabling nodejs version20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

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
VALIDATE $? "Creating a directory named app"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/expense-shell-1/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon reloading backend service"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Started backend service"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabled backend service"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql client"

mysql -h db.muvva.online -uroot -p${mysql_root_password} < /app/schema/backend.sql
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Resarting backend"