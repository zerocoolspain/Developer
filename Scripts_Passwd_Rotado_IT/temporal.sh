#! /bin/bash -p

export LANG=en_US.UTF-8

cat total | while read line
do
    serv=$(echo "${line}" | awk -F";" '{print $1}')
    
    entorno=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ../ficheros/master_total.csv)
    aplicativo=$(gawk -v a="${serv}" '$2==a {print $4}' 'FS=;' ../ficheros/master_total.csv)
    p=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' id.txt)
    
    echo "${line};${p};${entorno};${aplicativo}" >> obelix

done

