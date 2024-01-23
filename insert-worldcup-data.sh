#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  if [[ $WINNER != "winner" ]]
  then
     TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

     if [[ -z $TEAM_ID ]]
      then
      # insert winner
      INSERT_WINNER_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_TEAM == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
    fi
  
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    if [[ -z $TEAM_ID ]]
      then
      # insert opponent
      INSERT_OPPONENT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_TEAM == "INSERT 0 1" ]]
        then
          echo Inserted into teams, $OPPONENT
      fi
    fi

    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year='$YEAR' AND round='$ROUND' AND winner_id=(SELECT team_id FROM teams WHERE name='$WINNER')")


    if [[ -z $GAME_ID ]]
      then
      # inserst game
      INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', (SELECT team_id FROM teams WHERE name='$WINNER'), (SELECT team_id FROM teams WHERE name='$OPPONENT'), '$WINNER_GOALS', '$OPPONENT_GOALS')")
      if [[ $INSERT_GAME == "INSERT 0 1" ]]
        then
          echo Inserted into games, $YEAR $WINNER $OPPONENT $WINNER_GOALS $OPPONENT_GOALS
      fi
    fi
  fi
done
