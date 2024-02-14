#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU(){
  echo -e "\n$1\n"
  #get list of services
  LIST=$($PSQL "SELECT * FROM services")
  echo "$LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
      echo "$SERVICE_ID) $SERVICE_NAME."
  done
  read SERVICE_ID_SELECTED
  #if service doesn't exist
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not a valid option"
  else
    SERVICE_ID_TO_PICK=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_TO_PICK ]]
    then
      MAIN_MENU "That service doesn't exist"
    else
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      #get user 
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #if user doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        #add customer to the database
        echo "What's your name?"
        read CUSTOMER_NAME
        ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
        echo "You've been added to the database successfully"
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      echo "What time do you want the appointment?"
      read SERVICE_TIME
      ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/ //g')."
    fi
  fi


  #return to main menu
}


MAIN_MENU "Welcome to our salon page"
