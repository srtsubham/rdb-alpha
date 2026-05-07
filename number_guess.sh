#!/bin/bash
P="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
S=$((RANDOM % 1000 + 1))
echo "Enter your username:"
read U
R=$($P "SELECT games_played, best_game FROM users WHERE username='$U'")
if [[ -z $R ]]
then
  echo "Welcome, $U! It looks like this is your first time here."
  $P "INSERT INTO users(username) VALUES('$U')"
else
  echo "$R" | while IFS="|" read G B
  do
    echo "Welcome back, $U! You have played $G games, and your best game took $B guesses."
  done
fi
echo "Guess the secret number between 1 and 1000:"
T=0
while true
do
  read G
  ((T++))
  if [[ ! $G =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $G -eq $S ]]
  then
    echo "You guessed it in $T tries. The secret number was $S. Nice job!"
    $P "UPDATE users SET games_played = games_played + 1 WHERE username='$U'"
    B=$($P "SELECT best_game FROM users WHERE username='$U'")
    if [[ -z $B || $T -lt $B ]]
    then
      $P "UPDATE users SET best_game = $T WHERE username='$U'"
    fi
    break
  elif [[ $G -gt $S ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done 
