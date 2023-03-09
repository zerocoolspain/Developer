#! /bin/bash -p

export LANG=en_US.UTF-8

# Parte 1: Existe el usuario para conectar desde Cyberark

os=$( (cat /etc/redhat-release || lsb_release -ds || cat /etc/*release | grep -i pretty_name || uname -om) 2>/dev/null | head -n1 | sed 's/PRETTY_NAME=//' | tr -d '"')
#version=$(cat /etc/redhat-release | tr -dc '0-9' | cut -c-1)
version=$(echo $os | tr -dc '0-9' | cut -c-1)

nouser=$(egrep ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1 | wc -l)
users=$(egrep ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1 | sort | xargs | head -1)
now=$(date +%s)

existCcs="NO"
if [[ "$users" == *"ccs_"* ]]; then existCcs="SI"; fi

existCarp="NO"
if [[ "$users" == *"carp_"* ]]; then existCarp="SI"; fi

existCyberark="NO"
if [[ "$users" == *"cyberark"* ]]; then existCyberark="SI"; fi

existCyberlog="NO"
if [[ "$users" == *"cyberlog"* ]]; then existCyberlog="SI"; fi

# Parte 2: Obtener usuarios del sistema, lastlogin y si ha ejecutado algún comando realizando sudo

users=""
for u in $(egrep ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1 | sort | xargs | head -1); do
   result=$(lastlog -u $u)
   if [ $? -eq 0 ]; then 
      result=$(lastlog -u $u | tail -1 | tr -s ' ')
      if [[ "$result" == *"Never"* ]]; then
         lastDate="never"
         diffDays="99999"
      else
         lastDate=$(echo "$result" | rev | cut -d' ' -f1-6 | rev)
         lastDate=$(date -d "$lastDate" +%d/%m/%Y)         
         last=$(echo "$lastDate" | awk -v FS=/ -v OFS=/ '{print $3,$2,$1}' | xargs -i date -d {} +%s)
         diffDays=$(( ($now - $last)/(86400) ))
      fi
   else
      lastDate="lastlog_not_found"
      diffDays="99999"
   fi

   h=$(grep "^$u" /etc/passwd | awk -F: '{print $6}')
   if [ -f "$h/.bash_history" ]; then
      historyDate=$(stat -c %y $h/.bash_history | awk '{print $1}' | awk -F- '{print $3"/"$2"/"$1}')
      last=$(echo "$historyDate" | awk -v FS=/ -v OFS=/ '{print $3,$2,$1}' | xargs -i date -d {} +%s)
      diffDaysHistory=$(( ($now - $last)/(86400) ))
   else
      historyDate="no_history"
      diffDaysHistory="99999"
   fi

   users="$users $u|$lastDate|$diffDays|$historyDate|$diffDaysHistory"
done

# Parte 3: Resultado final

users=$(echo $users | xargs)
linea="$(hostname | cut -d'.' -f1 | tr a-z A-Z);$os;$nouser;$existCarp;$existCyberark;$existCyberlog;$existCcs;$users"
echo $linea
