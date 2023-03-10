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
days=$(echo $(( $(date +%s) / 86400 )))
fecha=$(date +%Y%m%d)
fecha2=$(date +%Y%m%d%H%M%S)
existeaddm=$(gawk '$1=="addm" {print $1}' 'FS=:' /etc/shadow | wc -l)
existeaddmusr=$(gawk '$1=="addmusr" {print $1}' 'FS=:' /etc/shadow | wc -l)
sistema=$(uname)

## BACKUP DEL SHADOW

if [ -f /etc/shadow ]
    then
        cp -p /etc/shadow /etc/shadow.pds_original
fi

cp /etc/shadow /etc/shadow.pds_$fecha
cp /etc/shadow /etc/shadow.pds_$fecha2

## CAMBIAMOS CONTRASEÑA

awk -v days="$(echo $(( $(date +%s) / 86400 )))" -F":" 'BEGIN {OFS=":"} { if($1 == "addm" || $1 == "addmusr") {$3=days;print} else {print} }' /etc/shadow > /etc/shadow.tmp
mv -f /etc/shadow.tmp /etc/shadow
    
## ROTADO DE CONTRASEÑA

if [ "${sistema}" == "SunOS" ]
    then
        if [ ${existeaddm} -gt 0 ]
            then
                if [ "$(awk -F: '{if($1 == "addm") {print $3}}' /etc/shadow)" == "$days" ] 
                    then
                        chmod 0000 /etc/shadow
                        ## Creamos y borramos un usuario por problemas encontrados con el shadow al rotar
                        useradd pepePDS
                        userdel pepePDS
	                    passwd -x 91 -n 1 -w 7 addm
                    else
	                    cp -f /etc/shadow.pds_$fecha /etc/shadow
                fi
        fi
        
        if [ ${existeaddmusr} -gt 0 ]
            then
                if [ "$(awk -F: '{if($1 == "addmusr") {print $3}}' /etc/shadow)" == "$days" ]
                    then
                        chmod 0000 /etc/shadow
                        ## Creamos y borramos un usuario por problemas encontrados con el shadow al rotar
                        useradd pepePDS
                        userdel pepePDS
	                    passwd -x 91 -n 1 -w 7 addmusr
                    else
	                    cp -f /etc/shadow.pds_$fecha /etc/shadow
                fi
        fi
       
fi  


if [ "${sistema}" == "Linux" ]
    then
        if [ ${existeaddm} -gt 0 ]
            then
                if [ "$(awk -F: '{if($1 == "addm") {print $3}}' /etc/shadow)" == "$days" ]
                    then
                        chmod 0000 /etc/shadow
                        ## Creamos y borramos un usuario por problemas encontrados con el shadow al rotar
                        useradd pepePDS
                        userdel pepePDS
	                    chage -I 90 -W 7 -m 1 -M 90 addm
                    else
	                    cp -f /etc/shadow.pds_$fecha /etc/shadow
                fi
        fi

        if [ ${existeaddmusr} -gt 0 ]
            then
                if [ "$(awk -F: '{if($1 == "addmusr") {print $3}}' /etc/shadow)" == "$days" ]
                    then
                        chmod 0000 /etc/shadow
                        ## Creamos y borramos un usuario por problemas encontrados con el shadow al rotar
                        useradd pepePDS
                        userdel pepePDS
	                    chage -I 90 -W 7 -m 1 -M 90 addmusr
                    else
	                    cp -f /etc/shadow.pds_$fecha /etc/shadow
                fi
        fi
        
fi


# Realizamos comprobacion

if [ "${sistema}" == "SunOS" ]
then
if [ ${existeaddmusr} -gt 0 ]
    then
        if [ "$(awk -F: '{if($1 == "addmusr") {print $3}}' /etc/shadow)" = "$days" ]
            then
                cambio1="OK"
                comp1=$(awk -F: '{if($1 == "addmusr") {print $3}}' /etc/shadow)
                minD=$(logins -oxl addmusr | awk -F: '{print $10'}|sed 's/ //g')
                maxD=$(logins -oxl addmusr | awk -F: '{print $11'}|sed 's/ //g')
                warD=$(logins -oxl addmusr | awk -F: '{print $12'}|sed 's/ //g')
                echo "${1};addmusr;Vodafone-IT;${2};${comp1};${days};${cambio1};${maxD};${minD};${warD}"
            else
                cambio1="NOK"
                comp1=$(awk -F: '{if($1 == "addmusr") {print $3}}' /etc/shadow)
                echo "${1};addmusr;Vodafone-IT;${2};${comp1};${days};${cambio1};N/A;N/A;N/A"
        fi
fi

if [ ${existeaddm} -gt 0 ]
    then
        if [ "$(awk -F: '{if($1 == "addm") {print $3}}' /etc/shadow)" = "$days" ]
            then
                cambio="OK"
                comp=$(awk -F: '{if($1 == "addm") {print $3}}' /etc/shadow)
                minD=$(logins -oxl addm | awk -F: '{print $10'}|sed 's/ //g')
                maxD=$(logins -oxl addm | awk -F: '{print $11'}|sed 's/ //g')
                warD=$(logins -oxl addm | awk -F: '{print $12'}|sed 's/ //g')
                echo "${1};addm;Vodafone-IT;${2};${comp};${days};${cambio};${maxD};${minD};${warD}"
            else
                cambio="NOK"
                comp=$(awk -F: '{if($1 == "addm") {print $3}}' /etc/shadow)
                echo "${1};addm;Vodafone-IT;${2};${comp};${days};${cambio};N/A;N/A;N/A"
        fi
fi

fi


if [ "${sistema}" == "Linux" ]
then
if [ ${existeaddmusr} -gt 0 ]
    then
        if [ "$(awk -F: '{if($1 == "addmusr") {print $3}}' /etc/shadow)" = "$days" ]
            then
                cambio1="OK"
                comp1=$(awk -F: '{if($1 == "addmusr") {print $3}}' /etc/shadow)
                minD=$(chage -l addmusr | grep -Ei "Minimum|nimo" |awk -F: '{print $2}'|sed 's/ //g')
                maxD=$(chage -l addmusr | grep -Ei "Maximum|ximo" |awk -F: '{print $2}'|sed 's/ //g')
                warD=$(chage -l addmusr | grep -Ei "warning|aviso" |awk -F: '{print $2}'|sed 's/ //g')
                echo "${1};addmusr;Vodafone-IT;${2};${comp1};${days};${cambio1};${maxD};${minD};${warD}"
            else
                cambio1="NOK"
                comp1=$(awk -F: '{if($1 == "addmusr") {print $3}}' /etc/shadow)
                echo "${1};addmusr;Vodafone-IT;${2};${comp1};${days};${cambio1};N/A;N/A;N/A"
        fi
fi

if [ ${existeaddm} -gt 0 ]
    then
        if [ "$(awk -F: '{if($1 == "addm") {print $3}}' /etc/shadow)" = "$days" ]
            then
                cambio="OK"
                comp=$(awk -F: '{if($1 == "addm") {print $3}}' /etc/shadow)
                minD=$(chage -l addm | grep -Ei "Minimum|nimo" |awk -F: '{print $2}'|sed 's/ //g')
                maxD=$(chage -l addm | grep -Ei "Maximum|ximo" |awk -F: '{print $2}'|sed 's/ //g')
                warD=$(chage -l addm | grep -Ei "warning|aviso" |awk -F: '{print $2}'|sed 's/ //g')
                echo "${1};addm;Vodafone-IT;${2};${comp};${days};${cambio};${maxD};${minD};${warD}"
            else
                cambio="NOK"
                comp=$(awk -F: '{if($1 == "addm") {print $3}}' /etc/shadow)
                echo "${1};addm;Vodafone-IT;${2};${comp};${days};${cambio};N/A;N/A;N/A"
        fi
fi
fi
}

#################### FUNCION MAIN ####################

f_master="ficheros/master_maquinas.txt"
f_uso="pass_shadow.txt"

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
            MODIFICACION SHADOW USUARIO ADDM/ADDMUSER
    ==========================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y pass_shadow.txt
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           pass_shadow.txt -> Listado de maquinas
       
EOF

continua
############################################################
############################################################

# Creamos cabecera CSV
echo "SERVIDOR;USUARIO;ENTORNO;ID;FECHA_ACTUAL;FECHA_DEBERIA;COMPROBACION_FECHA;MAX_DAYS;MIN_DAYS;WAR_DAYS"

days=$(echo $(( $(date +%s) / 86400 )))

while IFS=';' read -r serv user <&3 
do
 {
    red=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ficheros/master_maquinas.txt)
    identificador=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt)

   if [ "${red}" == "VODAFONE" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2} \${3}" >> funcion_no_borrar.sh
            scp -p funcion_no_borrar.sh hmc:/tmp/.
            ssh hmc << EOF
            scp -p /tmp/funcion_no_borrar.sh ${serv}:/tmp/.
            ssh ${serv} 'bash -s' <  /tmp/funcion_no_borrar.sh "${serv}" "${identificador}" "$days"
            ssh ${serv} 'rm -f /tmp/funcion_no_borrar.sh'
EOF
            ssh hmc 'rm -f /tmp/funcion_no_borrar.sh'
            rm -f funcion_no_borrar.sh
    fi 

    if [ "${red}" == "TELE2" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2} \${3}" >> funcion_no_borrar.sh
            ssh hmc 'ssh admunix 'ssh "${serv}" 'bash -s''' <  funcion_no_borrar.sh "${serv}" "${identificador}" "$days"
            rm -f funcion_no_borrar.sh
    fi

    if [ "${red}" == "ONO" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2} \${3}" >> funcion_no_borrar.sh
            ssh "${serv}" 'bash -s' <  funcion_no_borrar.sh "${serv}" "${identificador}" "$days"
            rm -f funcion_no_borrar.sh
    fi
 } 3<&-
done 3< pass_shadow.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/funcion_no_borrar.sh

sed $'s/[^[:print:]\t]//g' pass_shadow.log | grep -E "COMPROBACION|Vodafone-IT" > pass_shadow.csv
perl -npi -e "s/Press ENTER to continue ...//g" pass_shadow.csv
