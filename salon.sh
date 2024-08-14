#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi 
  echo -e "\nWelcome to My Salon, how can I help you?"
  # list of available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
  # if no service available
  if [[ -z $AVAILABLE_SERVICES ]]
    then
      MAIN_MENU "\nSorry we are fully booked right now. Please Try again later."
      echo "no service"
    else
      # list of available services
      echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
        do 
          echo "$SERVICE_ID) $SERVICE_NAME"
        done
      read SERVICE_ID_SELECTED
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_NAME ]] 
        then
          MAIN_MENU "I could not find that service. What would you like today?"
        else
        echo "else"
          # get phone number
          echo -e "\nWhat's your phone number?"
          read CUSTOMER_PHONE
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
          if [[ -z $CUSTOMER_NAME ]]
            then
            echo -e "\nI don't have a record for that number, what's your name?"
            read CUSTOMER_NAME
            INSERT_NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
            
            fi
          echo -e "\nWhat time would you like $SEVICE_NAME, $CUSTOMER_NAME?"
          read SERVICE_TIME
            
          # check if number is registered
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          # if not register the customer
          # reserve the srvice
          INSERT_NEW_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        
      fi
  fi

}

MAIN_MENU