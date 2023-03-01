#! /bin/bash -p

export LANG=en_US.UTF-8

rm -f ${1}_PRO.csv ${1}_PRE.cvs ${1}_NONE.csv

if [ $# -ne 1 ]
    then
        echo "Se debe pasar como parametro el fichero a separar"
        exit
fi

cat $1 | while read line
do
    serv=$(echo "${line}" | awk -F";" '{print $1}')
    user=$(echo "${line}" | awk -F";" '{print $2}')
    red=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ficheros/entorno_maquinas.txt)
    ##id=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt)
    
    if [ "${red}" = "Pre-Production" ]
        then
            echo "${line}" >> ${1}_PRE.csv
    fi

    if [ "${red}" = "Production" ]
        then
            echo "${line}" >> ${1}_PRO.csv
    fi

     if [ "${red}" != "Pre-Production" ] && [ "${red}" != "Production" ]
        then
            echo "${line}" >> ${1}_NONE.csv
    fi

done
