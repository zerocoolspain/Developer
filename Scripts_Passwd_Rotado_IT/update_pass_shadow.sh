#! /bin/bash -p

export LANG=en_US.UTF-8

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

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
fecha=$(date +%Y%m%d%H%M%S)
addm=$(gawk '$1=="addm" {print $1}' 'FS=:' /etc/shadow  | wc -l)
addmusr=$(gawk '$1=="addmusr" {print $1}' 'FS=:' /etc/shadow |  wc -l)

#if [ -f /etc/shadow ]
#then
#cp -p /etc/shadow /etc/shadow.pds_original
#fi

#cp /etc/shadow /etc/shadow.pds_$fecha
#awk -v days="$(echo $(( $(date +%s) / 86400 )))" -F":" 'BEGIN {OFS=":"} { if($1 == "addm" || $1 == "addmusr") {$3=days;print} else {print} }' /etc/shadow > /etc/shadow.tmp
#mv -f /etc/shadow.tmp /etc/shadow



# Realizamos comprobacion

if [ "$(awk -F: '{if($1 == "addmusr") {print $3}}' /etc/shadow)" = "${days}" ]
then
cambio="OK"
else
cambio="NOK"
fi

if [ "$(awk -F: '{if($1 == "addm") {print $3}}' /etc/shadow)" = "${days}" ]
then
cambio1="OK"
else
cambio1="NOK"
fi

if [ ${addm} -gt 0 ]
    then
        comp1=$(awk -F: '{if($1 == "addm") {print $3}}' /etc/shadow)
        echo "${1};addm;Vodafone-IT;${2};${comp1};${cambio1}"
fi

if [ ${addmusr} -gt 0 ]
    then
        comp=$(awk -F: '{if($1 == "addmusr") {print $3}}' /etc/shadow)
        echo "${1};addmusr;Vodafone-IT;${2};${comp};${cambio}"
fi
    

### lo dejamos para mas adelante

##if [ "${sistema}" == "SunOS" ]
##then
##
##if [ $(awk -F: '{if($1 == "addm") {print $3}}' /etc/shadow) -eq $days ]; then
##	passwd -x 91 -n 1 -w 7 addm
##else
##	#rollback
##	cp -f /etc/shadow.pds_$fecha /etc/shadow
##fi
##
##if [ $(awk -F: '{if($1 == "addmusr") {print $3}}' /etc/shadow) -eq $days ]; then
##	passwd -x 91 -n 1 -w 7 addmusr
##else
##	#rollback
##	cp -f /etc/shadow.pds_$fecha /etc/shadow
##fi
##
##chmod 0000 /etc/shadow
##fi
##
##if [ "${sistema}" == "Linux" ]
##then
##if [ $(awk -F: '{if($1 == "addm") {print $3}}' /etc/shadow) -eq $days ]; then
##	chage -I 90 -W 7 -m 1 -M 90 addm
##else
##	#rollback
##	cp -f /etc/shadow.pds_$fecha /etc/shadow
##fi
##
##if [ $(awk -F: '{if($1 == "addmusr") {print $3}}' /etc/shadow) -eq $days ]; then
##	chage -I 90 -W 7 -m 1 -M 90 addmusr
##else
##	#rollback
##	cp -f /etc/shadow.pds_$fecha /etc/shadow
##fi
##
##chmod 0000 /etc/shadow
##fi


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

 
    ==========================================================
                    SACA INFO USUARIOS MAQUINA
    ==========================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y saca_info_usuario.txt 
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           pass_shadow.txt -> Listado de maquinas
       
EOF

continua
############################################################
############################################################

# Creamos cabecera CSV
echo "SERVIDOR;USUARIO;ENTORNO;ID;FECHA;COMPROBACION"


while IFS=';' read -r serv user <&3 
do
 {
    red=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ficheros/master_maquinas.txt)
    identificador=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt)

   if [ "${red}" == "VODAFONE" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            scp -p funcion_no_borrar.sh hmc:/tmp/.
            ssh hmc << EOF
            scp -p /tmp/funcion_no_borrar.sh ${serv}:/tmp/.
            ssh ${serv} 'bash -s' <  /tmp/funcion_no_borrar.sh "${serv}" "${identificador}"
            ssh ${serv} 'rm -f /tmp/funcion_no_borrar.sh'
EOF
            ssh hmc 'rm -f /tmp/funcion_no_borrar.sh'
            rm -f funcion_no_borrar.sh
    fi 

    if [ "${red}" == "TELE2" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            ssh hmc 'ssh admunix 'ssh "${serv}" 'bash -s''' <  funcion_no_borrar.sh "${serv}" "${identificador}" 
            rm -f funcion_no_borrar.sh
    fi

    if [ "${red}" == "ONO" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            ssh "${serv}" 'bash -s' <  funcion_no_borrar.sh "${serv}" "${identificador}"
            rm -f funcion_no_borrar.sh
    fi
 } 3<&-
done 3< pass_shadow.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

sed $'s/[^[:print:]\t]//g' pass_shadow.log | grep -E "COMPROBACION|Pre-Production|Production" > pass_shadow.csv
perl -npi -e "s/Press ENTER to continue ...//g" pass_shadow.csv