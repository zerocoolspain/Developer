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
days="${4}"
fecha=$(date +%Y%m%d)
fecha2=$(date +%Y%m%d%H%M%S)
sistema=$(uname)

## BACKUP DEL SHADOW

if [ -f /etc/shadow ]
    then
        cp -p /etc/shadow /etc/shadow.pds_original
fi

cp /etc/shadow /etc/shadow.pds_$fecha
cp /etc/shadow /etc/shadow.pds_$fecha2


if [ "${sistema}" = "SunOS" ]
    then
        ## CAMBIAMOS FECHA CONTRASEÑA

        buscaren=$(nawk -v user="${3}" '$1==user {print NR}' 'FS=:' /etc/shadow)
        #days=$(echo $(( $(date +%s) / 86400 )))
        campotocar=$(nawk -v user="${3}" '$1==user {print $3}' 'FS=:' /etc/shadow)
        #sed -i "${buscaren}s/${campotocar}/${days}/g" /etc/shadow
        perl -p -i  -e "s/${campotocar}/${days}/ if $. == ${buscaren}" /etc/shadow
        chmod 0000 /etc/shadow

        ## ROTADO DE CONTRASEÑA

        if [ "$(nawk -v user="${3}" '$1==user {print $3}' 'FS=:' /etc/shadow)" = "$days" ] 
            then
                useradd pepePDS
                userdel pepePDS
	            passwd -x 91 -n 1 -w 7 "${3}"
        fi
fi  



if [ "${sistema}" = "Linux" ]
    then
        ## CAMBIAMOS FECHA CONTRASEÑA

        buscaren=$(awk -v user="${3}" -F":" 'BEGIN {OFS=":"} { if($1 == user) {print NR} }' /etc/shadow)
        #days=$(echo $(( $(date +%s) / 86400 )))
        campotocar=$(awk -v user="${3}" -F":" 'BEGIN {OFS=":"} { if($1 == user) {print $3} }' /etc/shadow)
        sed -i "${buscaren}s/${campotocar}/${days}/g" /etc/shadow
        chmod 0000 /etc/shadow

        ## ROTADO DE CONTRASEÑA

        if [ "$(awk -v user="${3}" -F: '{if($1 == user) {print $3}}' /etc/shadow)" = "$days" ] 
            then
                useradd pepePDS
                userdel pepePDS
	            chage -I 90 -W 7 -m 1 -M 90 "${3}"
    fi
fi  


# Realizamos comprobacion

if [ "${sistema}" = "SunOS" ]
    then
        #days=$(echo $(( $(date +%s) / 86400 )))
        if [ "$(nawk -v user="${3}" '$1==user {print $3}' 'FS=:' /etc/shadow)" = "$days" ] 
            then
                cambio="OK"
                comp=$(nawk -v user="${3}" '$1==user {print $3}' 'FS=:' /etc/shadow)
                minD=$(logins -oxl "${3}" | awk -F: '{print $10'}|sed 's/ //g')
                maxD=$(logins -oxl "${3}" | awk -F: '{print $11'}|sed 's/ //g')
                warD=$(logins -oxl "${3}" | awk -F: '{print $12'}|sed 's/ //g')
                echo "${1};${3};Vodafone-IT;${2};${comp};${days};${cambio};${maxD};${minD};${warD}"
            else
                cambio="NOK"
                minD=$(logins -oxl "${3}" | awk -F: '{print $10'}|sed 's/ //g')
                maxD=$(logins -oxl "${3}" | awk -F: '{print $11'}|sed 's/ //g')
                warD=$(logins -oxl "${3}" | awk -F: '{print $12'}|sed 's/ //g')
                echo "${1};${3};Vodafone-IT;${2};${comp};${days};${cambio};${maxD};${minD};${warD}"
        fi
fi

if [ "${sistema}" = "Linux" ]
    then
        #days=$(echo $(( $(date +%s) / 86400 )))
        if [ "$(awk -v user="${3}" -F: '{if($1 == user) {print $3}}' /etc/shadow)" = "$days" ] 
            then
                cambio="OK"
                comp=$(awk -v user="${3}" -F: '{if($1 == user) {print $3}}' /etc/shadow)
                minD=$(chage -l "${3}" | grep -Ei "Minimum|nimo" |awk -F: '{print $2}'|sed 's/ //g')
                maxD=$(chage -l "${3}" | grep -Ei "Maximum|ximo" |awk -F: '{print $2}'|sed 's/ //g')
                warD=$(chage -l "${3}" | grep -Ei "warning|aviso" |awk -F: '{print $2}'|sed 's/ //g')
                echo "${1};${3};Vodafone-IT;${2};${comp};${days};${cambio};${maxD};${minD};${warD}"
            else
                cambio="NOK"
                minD=$(chage -l "${3}" | grep -Ei "Minimum|nimo" |awk -F: '{print $2}'|sed 's/ //g')
                maxD=$(chage -l "${3}" | grep -Ei "Maximum|ximo" |awk -F: '{print $2}'|sed 's/ //g')
                warD=$(chage -l "${3}" | grep -Ei "warning|aviso" |awk -F: '{print $2}'|sed 's/ //g')
                echo "${1};${3};Vodafone-IT;${2};${comp};${days};${cambio};${maxD};${minD};${warD}"
        fi
fi

}

#################### FUNCION MAIN ####################

f_master="ficheros/master_maquinas.txt"
f_uso="workaround_shadow_manual.txt"

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
                    UPDATE PASS SHADOW
    ==========================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y pass_shadow.txt
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           workaround_shadow_manual.txt -> Listado de maquinas y usuarios con formato: MAQUINA;USUARIO
       
EOF

continua
############################################################
############################################################

# Creamos cabecera CSV
echo "SERVIDOR;USUARIO;ENTORNO;ID;FECHA_ACTUAL;FECHA_DEBERIA;COMPROBACION_FECHA;MAX_DAYS;MIN_DAYS;WAR_DAYS"

#days=$(echo $(( $(date +%s) / 86400 ))) # Calculamos los dias desde 1970

while IFS=';' read -r serv user days<&3 
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
            ssh ${serv} 'bash -s' <  /tmp/funcion_no_borrar.sh "${serv}" "${identificador}" "${user}" "${days}"
            ssh ${serv} 'rm -f /tmp/funcion_no_borrar.sh'
EOF
            ssh hmc 'rm -f /tmp/funcion_no_borrar.sh'
            rm -f funcion_no_borrar.sh
    fi 

    if [ "${red}" == "TELE2" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2} \${3} \${4}" >> funcion_no_borrar.sh
            ssh hmc 'ssh admunix 'ssh "${serv}" 'bash -s''' <  funcion_no_borrar.sh "${serv}" "${identificador}" "${user}" "${days}"
            rm -f funcion_no_borrar.sh
    fi

    if [ "${red}" == "ONO" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2} \${3} \${4}" >> funcion_no_borrar.sh
            ssh "${serv}" 'bash -s' <  funcion_no_borrar.sh "${serv}" "${identificador}" "${user}" "${days}"
            rm -f funcion_no_borrar.sh
    fi
 } 3<&-
done 3< workaround_shadow_manual.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/funcion_no_borrar.sh

sed $'s/[^[:print:]\t]//g' workaround_shadow_manual.log | grep -E "COMPROBACION|Vodafone-IT" > workaround_shadow_manual.csv
perl -npi -e "s/Press ENTER to continue ...//g" workaround_shadow_manual.csv
