#! /bin/bash -p

export LANG=en_US.UTF-8
rm -f obelix
cat $1 | while read line
do
    serv=$(echo "${line}" | awk -F";" '{print $1}')
    fecha=$(date +%d/%m/%y)
    usuario=$(echo "${line}" | awk -F";" '{print $2}')
    entorno=$(gawk -v a="${serv}" '$2==a {print $4}' 'FS=;' ficheros/master_maquinas.txt)
    aplicativo=$(gawk -v a="${serv}" '$2==a {print $5}' 'FS=;' ficheros/master_maquinas.txt)
    id=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt)

    echo "${fecha};${id};${serv};${usuario};${aplicativo};${entorno}" >> obelix

done
