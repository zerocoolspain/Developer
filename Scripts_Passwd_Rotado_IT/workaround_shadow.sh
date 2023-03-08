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
sistema=$(uname)

## BACKUP DEL SHADOW

if [ -f /etc/shadow ]
    then
        cp -p /etc/shadow /etc/shadow.pds_original
fi

cp /etc/shadow /etc/shadow.pds_$fecha
cp /etc/shadow /etc/shadow.pds_$fecha2
rm -f /etc/shadow.tmp.pds

## CAMBIAMOS FECHA CONTRASEÑA

if [ "${sistema}" = "SunOS" ]
    then
        rm -f /tmp/listado_usuarios_tocar.txt
        for u in $(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") {print $1}'| /usr/bin/sort)
            do
                encuentra=$(grep -cx ${u} /tmp/excepciones.txt)
                if [ ${encuentra} -eq 0 ]
                    then
                        echo "${u}" >> /tmp/listado_usuarios_tocar.txt
                fi
            done
        sort -u /tmp/listado_usuarios_tocar.txt > /tmp/listado_usuarios_tocar.txt.MIG
        mv /tmp/listado_usuarios_tocar.txt.MIG /tmp/listado_usuarios_tocar.txt
        cat /tmp/listado_usuarios_tocar.txt | while read line
            do
                buscaren=$(awk -v user="${line}" -F":" 'BEGIN {OFS=":"} { if($1 == user) {print NR} }' /etc/shadow)
                days=$(echo $(( $(date +%s) / 86400 )))
                campotocar=$(awk -v user="${line}" -F":" 'BEGIN {OFS=":"} { if($1 == user) {print $3} }' /etc/shadow)
                sed -i "${buscaren}s/${campotocar}/${days}/g" /etc/shadow
            done
        chmod 0000 /etc/shadow
fi

if [ "${sistema}" = "Linux" ]
    then
        rm -f /tmp/listado_usuarios_tocar.txt
        for u in $(awk -F: '($2 != "*" && $2 != "!!" && $2 != "!" && $2 != "!*" && $1 != "root") {print $1}' /etc/shadow | sort)
            do
                encuentra=$(grep -cx ${u} /tmp/excepciones.txt)
                if [ ${encuentra} -eq 0 ]
                    then
                        echo "${u}" >> /tmp/listado_usuarios_tocar.txt
                fi
            done
        
        sort -u /tmp/listado_usuarios_tocar.txt > /tmp/listado_usuarios_tocar.txt.MIG
        mv /tmp/listado_usuarios_tocar.txt.MIG /tmp/listado_usuarios_tocar.txt
        
        cat /tmp/listado_usuarios_tocar.txt | while read line
            do
                buscaren=$(awk -v user="${line}" -F":" 'BEGIN {OFS=":"} { if($1 == user) {print NR} }' /etc/shadow)
                days=$(echo $(( $(date +%s) / 86400 )))
                campotocar=$(awk -v user="${line}" -F":" 'BEGIN {OFS=":"} { if($1 == user) {print $3} }' /etc/shadow)
                sed -i "${buscaren}s/${campotocar}/${days}/g" /etc/shadow
            done
        chmod 0000 /etc/shadow
fi
    
## ROTADO DE CONTRASEÑA

if [ "${sistema}" = "SunOS" ]
    then
        for u in $(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") {print $1}'| /usr/bin/sort)
            do
                encuentra=$(grep -cx ${u} /tmp/excepciones.txt)
                if [ ${encuentra} -eq 0 ]
                    then
                        echo "${u}" >> /tmp/listado_usuarios_tocar.txt
                fi
            done
        
        sort -u /tmp/listado_usuarios_tocar.txt > /tmp/listado_usuarios_tocar.txt.MIG
        mv /tmp/listado_usuarios_tocar.txt.MIG /tmp/listado_usuarios_tocar.txt
        
        cat /tmp/listado_usuarios_tocar.txt | while read line
            do
                if [ "$(awk -v user="${line}" -F: '{if($1 == user) {print $3}}' /etc/shadow)" = "$days" ] 
                    then
                        useradd pepePDS
                        userdel pepePDS
	                    passwd -x 91 -n 1 -w 7 "${line}"
                    else
	                    cp -f /etc/shadow.pds_$fecha /etc/shadow
                fi
            done
fi  


if [ "${sistema}" = "Linux" ]
    then
        for u in $(awk -F: '($2 != "*" && $2 != "!!" && $2 != "!" && $2 != "!*" && $1 != "root") {print $1}' /etc/shadow | sort)
            do
                encuentra=$(grep -cx ${u} /tmp/excepciones.txt)
                if [ ${encuentra} -eq 0 ]
                    then
                        echo "${u}" >> /tmp/listado_usuarios_tocar.txt
                fi
            done
        
        sort -u /tmp/listado_usuarios_tocar.txt > /tmp/listado_usuarios_tocar.txt.MIG
        mv /tmp/listado_usuarios_tocar.txt.MIG /tmp/listado_usuarios_tocar.txt
        
        cat /tmp/listado_usuarios_tocar.txt | while read line
            do
                if [ "$(awk -v user="${line}" -F: '{if($1 == user) {print $3}}' /etc/shadow)" = "$days" ] 
                    then
                        useradd pepePDS
                        userdel pepePDS
	                    chage -I 90 -W 7 -m 1 -M 90 "${line}"
                    else
	                    cp -f /etc/shadow.pds_$fecha /etc/shadow
                fi
            done
fi  


# Realizamos comprobacion

if [ "${sistema}" = "SunOS" ]
    then
        days=$(echo $(( $(date +%s) / 86400 )))
        cat /tmp/listado_usuarios_tocar.txt | while read line
            do
                if [ "$(awk -v user="${line}" -F: '{if($1 == user) {print $3}}' /etc/shadow)" = "$days" ] 
                    then
                        cambio="OK"
                        comp=$(awk -v user="${line}" -F: '{if($1 == user) {print $3}}' /etc/shadow)
                        minD=$(logins -oxl "${line}" | awk -F: '{print $10'}|sed 's/ //g')
                        maxD=$(logins -oxl "${line}" | awk -F: '{print $11'}|sed 's/ //g')
                        warD=$(logins -oxl "${line}" | awk -F: '{print $12'}|sed 's/ //g')
                        echo "${1};${line};Vodafone-IT;${2};${comp};${days};${cambio};${maxD};${minD};${warD}"
                    else
                        cambio="NOK"
                        comp=$(awk -v user="${line}" -F: '{if($1 == user) {print $3}}' /etc/shadow)
                        echo "${1};${line};Vodafone-IT;${2};${comp};${days};${cambio};N/A;N/A;N/A"
                fi
            done
fi

if [ "${sistema}" = "Linux" ]
    then
        days=$(echo $(( $(date +%s) / 86400 )))
        cat /tmp/listado_usuarios_tocar.txt | while read line
            do
                if [ "$(awk -v user="${line}" -F: '{if($1 == user) {print $3}}' /etc/shadow)" = "$days" ] 
                    then
                        cambio="OK"
                        comp=$(awk -v user="${line}" -F: '{if($1 == user) {print $3}}' /etc/shadow)
                        minD=$(chage -l "${line}" | grep -Ei "Minimum|nimo" |awk -F: '{print $2}'|sed 's/ //g')
                        maxD=$(chage -l "${line}" | grep -Ei "Maximum|ximo" |awk -F: '{print $2}'|sed 's/ //g')
                        warD=$(chage -l "${line}" | grep -Ei "warning|aviso" |awk -F: '{print $2}'|sed 's/ //g')
                        echo "${1};${line};Vodafone-IT;${2};${comp};${days};${cambio};${maxD};${minD};${warD}"
                    else
                        cambio="NOK"
                        comp=$(awk -v user="${line}" -F: '{if($1 == user) {print $3}}' /etc/shadow)
                        echo "${1};${line};Vodafone-IT;${2};${comp};${days};${cambio};N/A;N/A;N/A"
                fi
            done
fi

}

#################### FUNCION MAIN ####################

f_master="ficheros/master_maquinas.txt"
f_uso="workaround_shadow.txt"
f_exc="excepciones.txt"

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

if [ ! -f ${f_exc} ]
    then
        echo "No existe el fichero ${f_master}"
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
                    UPDATE PASS SHADOW
    ==========================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y pass_shadow.txt
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           workaround_shadow.txt -> Listado de maquinas
           excepciones.txt -> listado de usuarios que NO se deben tocar
       
EOF

continua
############################################################
############################################################

# Creamos cabecera CSV
echo "SERVIDOR;USUARIO;ENTORNO;ID;FECHA_ACTUAL;FECHA_DEBERIA;COMPROBACION_FECHA;MAX_DAYS;MIN_DAYS;WAR_DAYS"

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
            scp -p excepciones.txt hmc:/tmp/.
            ssh hmc << EOF
            scp -p /tmp/funcion_no_borrar.sh ${serv}:/tmp/.
            scp -p /tmp/excepciones.txt ${serv}:/tmp/.
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
            scp -p excepciones.txt admunix:/tmp/.
            ssh hmc 'ssh admunix 'scp -p /tmp/excepciones.txt {serv}:/tmp/. ; ssh "${serv}" 'bash -s''' <  funcion_no_borrar.sh "${serv}" "${identificador}"
            rm -f funcion_no_borrar.sh
    fi

    if [ "${red}" == "ONO" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            scp -p excepciones.txt ${serv}:/tmp/.
            ssh "${serv}" 'bash -s' <  funcion_no_borrar.sh "${serv}" "${identificador}"
            rm -f funcion_no_borrar.sh
    fi
 } 3<&-
done 3< workaround_shadow.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/funcion_no_borrar.sh

sed $'s/[^[:print:]\t]//g' workaround_shadow.log | grep -E "COMPROBACION|Vodafone-IT" > workaround_shadow.csv
perl -npi -e "s/Press ENTER to continue ...//g" workaround_shadow.csv