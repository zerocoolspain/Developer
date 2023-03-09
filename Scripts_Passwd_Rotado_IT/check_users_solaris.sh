#! /bin/bash -p

os=$(head -1 /etc/release | xargs)

# Parte 1: Listado de usuarios, total y si existe el usuario para conectar desde Cyberark

nousers=$(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") && ( $11 != "91") { print $1}' | /usr/bin/wc -l | /usr/bin/xargs)
users=$(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") && ( $11 != "91") { print $1}' | /usr/bin/sort | /usr/bin/xargs)

existCcs="NO"
if [[ "$users" == *"ccs_"* ]]; then existCcs="SI"; fi

existCarp="NO"
if [[ "$users" == *"carp_"* ]]; then existCarp="SI"; fi

existCyberark="NO"
if [[ "$users" == *"cyberark"* ]]; then existCyberark="SI"; fi

existCyberlog="NO"
if [[ "$users" == *"cyberlog"* ]]; then existCyberlog="SI"; fi

# Parte 2: Obtener usuarios del sistema y su último login

users=""
for u in $(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") && ( $11 != "91") { print $1}' | /usr/bin/sort | /usr/bin/xargs | /usr/bin/head -1); do
   result=$(/usr/bin/last -1 $u | /usr/bin/head -1)
   if [ ! -z "$result" ]; then
      if [ $(echo $result | grep console > /dev/null) ]; then
         lastDate=$(echo "$result" | /usr/bin/awk -F' ' '{print $5"/"$4}')
      else
         lastDate=$(echo "$result" | /usr/bin/awk -F' ' '{print $6"/"$5}')
      fi
   else
      lastDate="never"
   fi
   users="$users $u|$lastDate"
done

# Parte 3: Resultado final

users=$(echo $users | xargs)
linea="$(cat /var/hostname);$os;$nousers;$existCarp;$existCyberark;$existCyberlog;$existCcs;$users"
echo $linea
