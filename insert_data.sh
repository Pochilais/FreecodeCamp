#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# -----------------------------------------------------------------------------
# NO MODIFICAR LÍNEAS POR ENCIMA DE ESTA MARCA. Usa $PSQL para todas las consultas.
# -----------------------------------------------------------------------------

# 1) Vaciar las tablas y reiniciar los contadores de los SERIAL
echo "$($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;")"

# 2) Leer línea por línea desde games.csv (omitimos la cabecera)
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Saltar la fila de encabezado
  if [[ $YEAR != "year" ]]
  then
    # 2.1) Insertar WINNER en teams (si no existe) y tomar su team_id
    TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    if [[ -z $TEAM_ID_WINNER ]]
    then
      # Si no existe, lo insertamos
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER');"
      # Luego recuperamos su team_id
      TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    fi

    # 2.2) Insertar OPPONENT en teams (si no existe) y tomar su team_id
    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    if [[ -z $TEAM_ID_OPPONENT ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');"
      TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi

    # 2.3) Insertar el registro en la tabla games, usando los IDs obtenidos
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
           VALUES($YEAR, '$ROUND', $TEAM_ID_WINNER, $TEAM_ID_OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS);"
  fi
done