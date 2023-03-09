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

# Realizamos comprobacion. Segun SO el parametro cambia

sistema=$(uname)

if [ "${sistema}" == "SunOS" ]
    then
        os=$(head -1 /etc/release | xargs)

        #for u in $(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") {print $1}'| /usr/bin/sort)
        for u in $(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "NL") {print $1}'| /usr/bin/sort)    
            do
                block=$(logins -oxl "${u}" | awk -F: '{print $8}')
                #rotated=$(logins -oxl ${u} | awk -F: '{print $11}')
                ##fecha=$(logins -oxl ${u} | awk -F: '{print $9}')
                minD=$(logins -oxl "${u}" | awk -F: '{print $10'}|sed 's/ //g')
                maxD=$(logins -oxl "${u}" | awk -F: '{print $11'}|sed 's/ //g')
                warD=$(logins -oxl "${u}" | awk -F: '{print $12'}|sed 's/ //g')

                if [ "${block}" = "LK" ]
                    then
                        bloqueado="YES"
                    else
                        bloqueado="NO"
                fi

                if [ ${minD} -eq 1 ] && [ ${maxD} -eq 91 ] && [ ${warD} -eq 7 ]
                    then
                        rotado="YES"
                    else
                        rotado="NO"
                fi

                if [ "${bloqueado}" = "YES" ]  ||  [ "${rotado}" = "YES" ]
                    then
                        hardenizado="YES"
                    else
                        hardenizado="NO"
                fi

                echo "${2};${1};Vodafone-IT;${u};${bloqueado};${rotado};${minD};${maxD};${warD};${os};${hardenizado}" 
            done
fi

if [ "${sistema}" == "Linux" ]
    then
        os=$( (cat /etc/redhat-release || lsb_release -ds || cat /etc/*release | grep -i pretty_name || uname -om) 2>/dev/null | head -n1 | sed 's/PRETTY_NAME=//' | tr -d '"')

        comprobar=$(cat /etc/shadow | awk -F: '{print $1}' | sort | xargs -l1 passwd --status| awk '{print $1}' | head -1)

        if [ "${comprobar}" = "Password" ]
            then
                #for u in $(awk -F: '($2 != "*" && $2 != "!!" && $2 != "!" && $2 != "!*" && $1 != "root") {print $1}' /etc/shadow | sort)
                for u in $(awk -F: '($2 != "*" && $2 != "!" && $2 != "!*" && $1 != "root") {print $1}' /etc/shadow | sort)
                    do
                        block=$(cat /etc/shadow | grep "${u}" | awk -F: '{print $2}')
                        #rotated=$(cat /etc/shadow | grep ${u} | awk -F: '{print $5}')
                        ##fecha=""
                        minD=$(chage -l "${u}" | grep -i "Minimum" |awk -F: '{print $2}'|sed 's/ //g')
                        maxD=$(chage -l "${u}" | grep -i "Maximum" |awk -F: '{print $2}'|sed 's/ //g')
                        warD=$(chage -l "${u}" | grep -i "Warning" |awk -F: '{print $2}'|sed 's/ //g')
                    
                        if [ "${block}" = "!!" ]
                            then
                                bloqueado="YES"
                            else
                                bloqueado="NO"
                        fi

                        if [ ${minD} -eq 1 ] && [ ${maxD} -eq 90 ] && [ ${warD} -eq 7 ]
                            then
                                rotado="YES"
                            else
                                rotado="NO"
                        fi

                        if [ "${bloqueado}" = "YES" ]  ||  [ "${rotado}" = "YES" ]
                            then
                                hardenizado="YES"
                            else
                                hardenizado="NO"
                        fi

                        echo "${2};${1};Vodafone-IT;${u};${bloqueado};${rotado};${minD};${maxD};${warD};${os};${hardenizado}"  
                    done
            else
                #for u in $(awk -F: '($2 != "*" && $2 != "!!" && $2 != "!" && $2 != "!*" && $1 != "root") {print $1}' /etc/shadow | sort | xargs -l1 passwd --status| awk '{print $1}')
                for u in $(awk -F: '($2 != "*" && $2 != "!" && $2 != "!*" && $1 != "root") {print $1}' /etc/shadow | sort | xargs -l1 passwd --status| awk '{print $1}')
                    do
                        block=$(passwd --status "${u}"| awk '{print $2}')
                        #rotated=$(passwd --status ${u}| awk '{print $5}')
                        ##fecha=$(passwd --status ${u}| awk '{print $3}')
                        minD=$(chage -l "${u}" | grep -Ei "Minimum|nimo" |awk -F: '{print $2}'|sed 's/ //g')
                        maxD=$(chage -l "${u}" | grep -Ei "Maximum|ximo" |awk -F: '{print $2}'|sed 's/ //g')
                        warD=$(chage -l "${u}" | grep -Ei "warning|aviso" |awk -F: '{print $2}'|sed 's/ //g')

                        if [ "${block}" = "LK" ]
                            then
                                bloqueado="YES"
                            else
                                bloqueado="NO"
                        fi

                        if [ ${minD} -eq 1 ] && [ ${maxD} -eq 90 ] && [ ${warD} -eq 7 ]
                            then
                                rotado="YES"
                            else
                                rotado="NO"
                        fi
                        if [ "${bloqueado}" = "YES" ]  ||  [ "${rotado}" = "YES" ]
                            then
                                hardenizado="YES"
                            else
                                hardenizado="NO"
                        fi
                        echo "${2};${1};Vodafone-IT;${u};${bloqueado};${rotado};${minD};${maxD};${warD};${os};${hardenizado}" 
                    done
        fi              
fi 

}

## FUNCIONES EN DESUSO AL EJECUTAR TODO EN BUCLE INICIAL
saca_info_usuario_tele2 ()
{
ssh ADMUNIX << EOF 
ssh ${serv}  'bash' 
$(typeset -f funcion)
funcion ${serv}
EOF
}

saca_info_usuario_vodafone ()
{
ssh hmc << EOF
ssh ${serv} 'bash'
$(typeset -f funcion)
funcion ${serv}
EOF
}

saca_info_usuario_ono ()
{
ssh ${serv} 'bash'<< EOF
$(typeset -f funcion)
funcion ${serv}
EOF
}

#################### FUNCION MAIN ####################

f_master="ficheros/master_maquinas.txt"
f_uso="saca_info_usuario.txt"

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
                    SACA INFO USUARIOS MAQUINA
    ==========================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y saca_info_usuario.txt 
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           saca_info_usuario.txt -> Listado de maquinas
       
EOF

continua
############################################################
############################################################

# Creamos cabecera CSV
echo "ID;SERVIDOR;ENTORNO;USUARIO;BLOQUEADO;ROTADO;MIN_DAYS;MAX_DAYS;WARN_DAYS;OS;HARDENIZADO"


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
done 3< saca_info_usuario.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

sed $'s/[^[:print:]\t]//g' saca_info_usuario.log | grep -Ei "HARDENIZADO|Vodafone-IT" > saca_info_usuario.csv
perl -npi -e "s/Press ENTER to continue ...//g" saca_info_usuario.csv
##grep -Ewv "root|addm|addmusr|ansibleu|ansible" saca_info_usuario.csv > saca_info_usuario.csv_TMP
#grep -v "root" saca_info_usuario.csv > saca_info_usuario.csv_TMP
#mv saca_info_usuario.csv_TMP saca_info_usuario.csv

# Comprobamos maquinas que no se han podido hacer

cat ficheros/master_maquinas.txt | while read line
do
a=$(echo "${line}"| awk -F";" '{print $2}')
b=$(grep -cw "${a}"  saca_info_usuario.csv)
c=$(echo "${line}"| awk -F";" '{print $1}')

if [ ${b} -lt 1 ]
then
echo "${c};${a};Vodafone-IT;SCAN FAIL;;;;;;;" >> saca_info_usuario.csv_TMP2
fi
done

fecha=$(date +%d_%m_%Y)
cat saca_info_usuario.csv_TMP2 >> saca_info_usuario.csv
mv saca_info_usuario.csv escaneo_usuarios_"${fecha}".csv
rm -f saca_info_usuario.csv_TMP2 
