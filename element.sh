#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
else
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    SELECTED_ELEMENT_ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE (symbol='$1' OR name='$1')")
  else
    SELECTED_ELEMENT_ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
  fi
  if [[ -z $SELECTED_ELEMENT_ATOMIC_NUMBER ]]
    then
      echo "I could not find that element in the database."
    else
    ELEMENT_NAME_ROW=$($PSQL "SELECT name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id) WHERE atomic_number=$SELECTED_ELEMENT_ATOMIC_NUMBER")
    IFS='|' read NAME SYMBOL TYPE  ATOMIC_MASS MELTING_POINT BOILING_POINT <<<"$ELEMENT_NAME_ROW"
    echo "The element with atomic number $SELECTED_ELEMENT_ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi