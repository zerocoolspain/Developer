#! /bin/bash -p

export LANG=en_US.UTF-8

# Borramos fichero temporal
rm -f /home/mdearri2/funcion_no_borrar.sh

#########################################
#                Funciones              #
#########################################
continua()
{
  printf "\n\n\nPress ENTER to continue ..."
  read enter
}

funcion ()
{
export LANG=en_US.UTF-8
days1="${3}"
days2="${4}"
fecha=$(date +%Y%m%d)
fecha2=$(date +%Y%m%d%H%M%S)
sistema=$(uname)

## BACKUP DEL SHADOW

if [ -f /etc/shadow ]
    then
        cp -p /etc/shadow /etc/shadow.pds2_original
fi

cp /etc/shadow /etc/shadow.pds2_$fecha
cp /etc/shadow /etc/shadow.pds2_$fecha2


if [ "${sistema}" == "SunOS" ]
    then
        for u in $(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") {print $1}'| /usr/bin/sort) 
            do
                if [ "$(nawk -v user="${u}" -v dato="${days1}" '$1==user && $3==dato {print NR}' 'FS=:' /etc/shadow)" != "" ]
                    then
                        buscaren=$(nawk -v user="${u}" -v dato="${days1}" '$1==user && $3==dato {print NR}' 'FS=:' /etc/shadow)
                        perl -p -i  -e "s/${days1}/${days2}/ if $. == ${buscaren}" /etc/shadow
                        chmod 0000 /etc/shadow
                        useradd pepePDS
                        userdel pepePDS
                        echo "${1};${u};Vodafone-IT;${2};${days1};${days2}"
                fi


            done
fi

if [ "${sistema}" == "Linux" ]
    then   
        for u in $(awk -F: '($2 != "*" && $2 != "!!" && $2 != "!" && $2 != "!*" && $1 != "root") {print $1}' /etc/shadow | sort)
            do   
                if [ "$(awk -v user="${u}" -v dato="${days1}" -F":" 'BEGIN {OFS=":"} { if($1 == user && $3 == dato) {print NR} }' /etc/shadow)" != "" ]
                    then
                        buscaren=$(awk -v user="${u}" -v dato="${days1}" -F":" 'BEGIN {OFS=":"} { if($1 == user && $3 == dato) {print NR} }' /etc/shadow)
                        sed -i "${buscaren}s/${days1}/${days2}/g" /etc/shadow
                        chmod 0000 /etc/shadow
                        useradd pepePDS
                        userdel pepePDS
                        echo "${1};${u};Vodafone-IT;${2};${days1};${days2}"
                fi   
            done
                    
fi 




}

#################### FUNCION MAIN ####################

f_master="ficheros/master_maquinas.txt"
f_uso="change_date_shadow.txt"

if [ ! -f ${f_master} ]
    then
        echo "No existe el fichero ${f_master}"
        continua
        clear
        exit 0
fi

if [ ! -f ${f_uso} ]
    then
        echo "No existe el fichero ${f_uso}"
        continua
        clear
        exit 0
fi

if [ $# -ne 2 ]
    then
        echo "Se deben pasar los dias de cambio de contraseña a modificar y los nuevos a incluir"
        continua
        clear
        exit 0
fi

clear

if [ -f "$0".flag ]
     then
        clear
        echo ""
        echo " Ya hay un usuario usando este menu "
        echo ""
        continua
        exit 0
        else
        touch  "$0".flag 
fi
     trap 'rm -f $0.flag' EXIT


  printf "\f"
  cat <<EOF

#######################################################
#                                                     #
#               Menu Hardenizacion                    #
#                                                     #
#              Fecha -> 08/03/2023                    #
#                                                     #
#     v2.0  -- Miguel Angel de Arriba Gutierrez       #
#                                                     #
####################################################### 
    ==========================================================
                    CHANGE DATE SHADOW
    ==========================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y pass_shadow.txt
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           change_date_shadow.txt -> Listado de maquinas a tratar
       
EOF

continua
############################################################
############################################################

# Creamos cabecera CSV
echo "SERVIDOR;USUARIO;ENTORNO;ID;FECHA_ANTERIOR;FECHA_NUEVA"

#days=$(echo $(( $(date +%s) / 86400 ))) # Calculamos los dias desde 1970
f1="${1}"
f2="${2}"

while IFS=';' read -r serv user <&3 
do
 {
    red=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ficheros/master_maquinas.txt)
    identificador=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt)

   if [ "${red}" == "VODAFONE" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2} \${3} \${4}" >> funcion_no_borrar.sh
            scp -p funcion_no_borrar.sh hmc:/tmp/.
            ssh hmc << EOF
            scp -p /tmp/funcion_no_borrar.sh ${serv}:/tmp/.
            ssh ${serv} 'bash -s' <  /tmp/funcion_no_borrar.sh "${serv}" "${identificador}" "${f1}" "${f2}"
            ssh ${serv} 'rm -f /tmp/funcion_no_borrar.sh'
EOF
            ssh hmc 'rm -f /tmp/funcion_no_borrar.sh'
            rm -f funcion_no_borrar.sh
    fi 

    if [ "${red}" == "TELE2" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2} \${3} \${4}" >> funcion_no_borrar.sh
            ssh hmc 'ssh admunix 'ssh "${serv}" 'bash -s''' <  funcion_no_borrar.sh "${serv}" "${identificador}" "${f1}" "${f2}"
            rm -f funcion_no_borrar.sh
    fi

    if [ "${red}" == "ONO" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2} \${3} \${4}" >> funcion_no_borrar.sh
            ssh "${serv}" 'bash -s' <  funcion_no_borrar.sh "${serv}" "${identificador}" "${f1}" "${f2}"
            rm -f funcion_no_borrar.sh
    fi
 } 3<&-
done 3< change_date_shadow.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/funcion_no_borrar.sh

sed $'s/[^[:print:]\t]//g' change_date_shadow.log | grep -E "FECHA_NUEVA|Vodafone-IT" > change_date_shadow.csv
perl -npi -e "s/Press ENTER to continue ...//g" change_date_shadow.csv
