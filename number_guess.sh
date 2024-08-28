#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER_OF_GUESSES=0

# Game played update function
GAME_PLAYED_INCREASE() {
  if [[ $1 ]]
  then 
    GAME_PLAYED_COUNTER_RESULT=$($PSQL "UPDATE users SET game_played = game_played + 1 WHERE user_id = $1")
  else
    echo "Please provide a user id"
  fi

}

# define main game function
GAME() {
if [[ $1 ]]
then
  echo -e "\n$1"
  # echo -e "\nGuess the secret number between 1 and 1000:"
  read USER_GUESSED_NUMBER
  ((NUMBER_OF_GUESSES++))
  # check if the input is a number
  if [[ ! $USER_GUESSED_NUMBER =~ ^[0-9]+$ ]]
  then
    GAME "That is not an integer, guess again:"
  else
    if [[ "$USER_GUESSED_NUMBER" -lt "$GOAL_NUMBER" ]]
    then
      GAME "It's higher than that, guess again:" 
    else
      if [[ "$USER_GUESSED_NUMBER" -gt "$GOAL_NUMBER" ]]
      then
        GAME "It's lower than that, guess again:"
      else
        # you hit the jackpot right answer
        echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $GOAL_NUMBER. Nice job!"
        BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$PLAYER_USER_ID")
        if [[ $BEST_GAME -eq 0 ]]
        then
          SET_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE user_id=$PLAYER_USER_ID")
        elif [[ "$BEST_GAME" -gt "$NUMBER_OF_GUESSES" ]]
        then
          SET_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE user_id=$PLAYER_USER_ID")
        fi
      fi


    fi

  fi
  fi
}


# Generate randome number
GOAL_NUMBER=$((1 + RANDOM % 1000))
# echo $GOAL_NUMBER
# get username
echo Enter your username:
read USER_NAME
PLAYER_USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USER_NAME'")
# if username exist
if [[ -z $PLAYER_USER_ID ]]
then
  # username does not exist in db
  # add username to db
  INSERT_RESULT=$($PSQL "INSERT INTO users (user_name) VALUES ('$USER_NAME')")
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  PLAYER_USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USER_NAME'")
  GAME_PLAYED_COUNTER_RESULT=$($PSQL "UPDATE users SET game_played = game_played + 1 WHERE user_id = $PLAYER_USER_ID")
  # GAME_PLAYED_INCREASE $PLAYER_USER_ID
else
# user exist in the db 
  # fetch game played and best score
  USER_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$PLAYER_USER_ID")
  USER_GAME_PLAYED=$($PSQL "SELECT game_played FROM users WHERE user_id=$PLAYER_USER_ID")
  echo "Welcome back, $USER_NAME! You have played $USER_GAME_PLAYED games, and your best game took $USER_BEST_GAME guesses."
  GAME_PLAYED_INCREASE $PLAYER_USER_ID
  GAME "Guess the secret number between 1 and 1000:"
fi
# prompt user to guess a number in range
