#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo -e "\n~~~~~ NUMBER GUESSING GAME ~~~~~\n"
echo -e "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

USERS() {
  if [[ -z $USER_ID ]]
  then
    CREATE_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    NEW_USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    USERSNAME=$($PSQL "SELECT username FROM users WHERE user_id=$NEW_USER_ID")
    echo -e "\nWelcome, $USERSNAME! It looks like this is your first time here." | sed 's/  / /g'
  else
    BEST_GAMES=$($PSQL "SELECT MIN(best_game) FROM games WHERE user_id=$USER_ID")
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
    USERSNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
    echo -e "\nWelcome back, $USERSNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAMES guesses."  | sed 's/   / /g' -E | sed 's/  / /g'
  fi

  GAMES
}

GAMES() {
  USERS_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  SECRET_NUMBER=$(( 1 + $RANDOM % 1000))
  TRIES=0
  GUESSED=0
  echo -e "\nGuess the secret number between 1 and 1000:"

  while [ $GUESSED = 0 ]
  do
    read GUESS
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
    elif [[ $GUESS = $SECRET_NUMBER ]]
    then
      TRIES=$(($TRIES + 1))
      SAVE_GAME_DATA=$($PSQL "INSERT INTO games(user_id, best_game) VALUES($USERS_ID, $TRIES)")
      echo -e "\nYou guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
      GUESSED=1
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      TRIES=$(($TRIES + 1))
      echo -e "\nIt's lower than that, guess again:"
    else
      TRIES=$(($TRIES + 1))
      echo -e "\nIt's higher than that, guess again:"
    fi
  done
}

USERS