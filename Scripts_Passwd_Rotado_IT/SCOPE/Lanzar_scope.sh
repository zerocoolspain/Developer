#/bin/bash -p

export LANG=en_US.UTF-8

continua()
{
  printf "\n\n\nPress ENTER to continue ..."
  read enter
}

echo "Lanzamos el escaneo modificado"

continua

./scope.sh

echo "Lanzamos el KPI del escaneo"
continua

./resultado_scope.sh escaneo_usuarios.csv
