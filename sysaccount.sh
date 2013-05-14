#! /bin/bash

# Variables
attemptN=0

# Functions
function login() {
  if !([ -s ~/.passwd -a -r ~/.passwd ]);
  then
    echo "There is no passwd file."
    echo "Would you like to add a new user?"
    read -n1 -p "[Y/n]" REPLY
    if [ "$REPLY" == "y" ] || [ "$REPLY" == "Y" ];
    then
      #Newline
      echo
      useradd
      exit 0
    else
      #Newline
      echo
      exit 0
    fi
  fi

  read -p "Login: " LOGIN
  read -s -p "Password: " PASS
  ACCOUNT=`grep "$LOGIN" ~/.passwd | awk -F " " {' print $1 '}`
  PASSWORD=`grep "$LOGIN" ~/.passwd | awk -F " " {' print $2 '}`
  PASS=`echo "$PASS" | shasum | awk -F " " {' print $1 '}`

  if [ "$LOGIN" == "$ACCOUNT" ] && [ "$PASS" == "$PASSWORD" ];
  then
    logged
  else
    retry
  fi
}

function retry() {
  attemptN="$((attemptN+1))"
  if [ "$attemptN" -ge "3" ];
  then
    echo -e "\nYou've reached maximum attempt number."
    exit 0
  else
    echo -e "\nLogin failed"
    login
  fi
}

function logged() {
  echo -e "\nWelcome ${LOGIN}!"
}

function useradd() {
  if [ "$1" == "" ];
  then
    read -p "Username: " USERNAME
  else
    USERNAME=$1
  fi
  read -s -p "Password: " PASSWORD
  #Newline
  echo
  read -s -p "Password: " PASSWORD2
  if [ "$PASSWORD" == "$PASSWORD2" ];
  then
    echo "$USERNAME `echo $PASSWORD | shasum`" >> ~/.passwd &&
    echo -e "\nUser $USERNAME was added successfully." ||
    echo -e "\nUser $USERNAME was not added."
  else
    echo -e "\nPasswords didn't match."
    echo "Try again!"
    useradd
  fi 
}

function userdel() {
  if [ "`grep "$1" ~/.passwd`" != "" ];
  then
    echo "`cat ~/.passwd | sed "/$1/ d"`" > ~/.passwd &&
    echo "Useraccount $1 successfully removed." ||
    echo "Useraccount $1 was not removed."
    if [ "`cat ~/.passwd | grep " "`" == "" ];
    then
      rm ~/.passwd
    fi
  else
    echo "${1}'s account does not exist."
  fi
}

# Main
if [ "$#" == 0 ];
then
  echo "Usage: sysaccount [option] [argument]"
else
  if [ "$1" == "-a" ] || [ "$1" == "--add" ];
  then
    useradd $2
  elif [ "$1" == "-d" ] || [ "$1" == "--del" ];
  then
    userdel $2
  elif [ "$1" == "-l" ] || [ "$1" == "--login" ];
  then
    login
  fi
fi
