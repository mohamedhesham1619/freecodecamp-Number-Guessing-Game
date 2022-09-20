#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# read username
echo "Enter your username:"
read USERNAME

# search for username in database
USER_SEARCH_RESULT=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")

# if username not found in number_guess database
if [[ -z $USER_SEARCH_RESULT ]]
then
  # add username and games played as 0 to database
  INSERT_NEW_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)")
  
  # welcome user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  
# if username found in number_guess database
else
  # get number of games played by the user
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  
  # get best game played by the user
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

  # welcome user with his info
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
  
# generate random number between 1-1000
RANDOM_NUMBER=$(($RANDOM % 1000 + 1))

GUESSES_COUNTER=0

# let user guess the random number and count number of guesses
LET_USER_GUESS () {
  # if there is an argument, print it
  if [[ ! -z $1 ]]
  then
    echo "$1"
  fi

  read GUESS

  # increase guesses number by one
  (( GUESSES_COUNTER++ ))

  # if the input is not a number
  if [[ ! $GUESS =~ ^[0-9]*$ ]]
  then
    LET_USER_GUESS "That is not an integer, guess again:"
    return
  fi

  # if the input lower than the random number
  if [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    LET_USER_GUESS "It's higher than that, guess again:"
    return
  fi

  # if the input higher than the random number
  if [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    LET_USER_GUESS "It's lower than that, guess again:"
    return
  fi

  # if the input equal the random number
  if [[ $GUESS -eq $RANDOM_NUMBER ]]
  then
    # if number of guesses lower than best game or this is the first game for the user update best game value
    if [[ -z $BEST_GAME || $GUESSES_COUNTER -lt $BEST_GAME ]]
    then
      UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESSES_COUNTER WHERE username = '$USERNAME'")
    fi

fi
}

LET_USER_GUESS "Guess the secret number between 1 and 1000:"

# increase games_player by one
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")

# output result
echo "You guessed it in $GUESSES_COUNTER tries. The secret number was $RANDOM_NUMBER. Nice job!"

