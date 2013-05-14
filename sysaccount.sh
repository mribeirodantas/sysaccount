#! /bin/bash

# Variables
attemptN=0
#Account information
ACCOUNT=""
PASSWORD=""
#Values informed
LOGIN=""
PASS=""


# Functions
function usage() {
  echo "Usage: sysaccount [option] [argument]"
}

function login() {
  if !([ -s ~/.passwd -a -r ~/.passwd ]);
  then
    echo "The account database is empty."
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
  ACCOUNT=`grep ";$LOGIN:" ~/.passwd | awk -F ":" {' print $1 '}`
  PASSWORD=`grep ";$LOGIN:" ~/.passwd | awk -F ":" {' print $2 '}`
  PASS=`echo "$PASS" | shasum | awk -F " " {' print $1 '}`

  if [ ";$LOGIN" == "$ACCOUNT" ] && [ "$PASS" == "$PASSWORD" ];
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
    read -p "Username: " LOGIN
  else
    LOGIN=$1
  fi
  if [ -s ~/.passwd -a -r ~/.passwd ] && [ "`grep ";$LOGIN:" ~/.passwd`" != "" ];
  then
    echo "This username is already registered."
    exit 0
  fi
  read -s -p "Password: " PASSWORD
  #Newline
  echo
  read -s -p "Password: " PASSWORD2
  if [ "$PASSWORD" == "$PASSWORD2" ];
  then
    echo ";$LOGIN:`echo $PASSWORD | shasum | awk -F " " {' print $1 '}`" >> ~/.passwd &&
    echo -e "\nUser $LOGIN was added successfully." ||
    echo -e "\nUser $LOGIN was not added."
  else
    echo -e "\nPasswords didn't match."
    echo "Try again!"
    useradd
  fi 
}

function userdel() {
  if !([ -s ~/.passwd ]);
  then
    login
  fi
  if [ "`grep ";$1:" ~/.passwd`" != "" ];
  then
    echo "`cat ~/.passwd | sed "/;$1:/ d"`" > ~/.passwd &&
    echo "Useraccount $1 successfully removed." ||
    echo "Useraccount $1 was not removed."
    if [ "`cat ~/.passwd | grep ":"`" == "" ];
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
  usage
else
  case "$1" in
    -a|--add)
      useradd $2
      ;;
    -d|--del)
      if [ "$2" == "" ];
      then
        usage
      else
        userdel $2
      fi
      ;;
    -l|--login)
      login
      ;;
  esac
fi
