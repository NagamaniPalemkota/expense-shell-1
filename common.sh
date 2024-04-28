#!/bin/bash

set -e #used to handle errors by shell
trap 'failure ${LINENO} ${BASH_COMMAND}' ERR


failure()
{
    echo "Error occurs at $LINENO at $BASH_COMMAND"
}
USERID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo "$0" | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

check_root(){
    if [ $USERID -ne 0 ]
    then
        echo "Please run with super user access"
        exit 1 #manually exiting the code if error comes
    else
        echo "You are super user"
    fi
}