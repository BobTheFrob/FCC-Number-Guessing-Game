#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_1000=$(( RANDOM % 1000 + 1 ))
GUESSES_SO_FAR=1

PLAY_GAME() {
  echo Guess the secret number between 1 and 1000:
  read GUESS
  if ! [[ $GUESS =~ [0-9]+ ]]
    then
      echo That is not an integer, guess again: 
      read GUESS
  fi
  while [[ $GUESS != $RANDOM_1000 ]] 
    do
      if ! [[ $GUESS =~ [0-9]+ ]]
        then
          echo That is not an integer, guess again: 
          read GUESS
      fi
      if [[ $GUESS > $RANDOM_1000 ]]
        then
          echo -e "It's lower than that, guess again:"
          GUESSES_SO_FAR=$(( $GUESSES_SO_FAR + 1 ))
          read GUESS
          continue
        else
          echo -e "It's higher than that, guess again:"
          GUESSES_SO_FAR=$(( $GUESSES_SO_FAR + 1 ))
          read GUESS
          continue
      fi
  done
}

echo "Enter your username:"
read USERNAME
# get username
QUERIED_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
if [[ -z $QUERIED_USERNAME ]]
  then
    ADD_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    echo Welcome, $USERNAME! It looks like this is your first time here.
    PLAY_GAME
    INSERT_INTO_GAMES=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID,$GUESSES_SO_FAR)")
else
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo $USER_ID
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id='$USER_ID'")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id='$USER_ID'")
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  PLAY_GAME
  INSERT_INTO_GAMES=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID,$GUESSES_SO_FAR)")
fi
echo You guessed it in $GUESSES_SO_FAR tries. The secret number was $RANDOM_1000. Nice job!