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
        nousers=$(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") && ( $11 != "91") { print $1}' | /usr/bin/wc -l | /usr/bin/xargs)
        users=$(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") && ( $11 != "91") { print $1}' | /usr/bin/sort | /usr/bin/xargs)
        cyber=$(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") && ( $11 != "91") { print $1}' | /usr/bin/sort | /usr/bin/xargs|grep -i cyberark|wc -l)
        cyber2=$(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") && ( $11 != "91") { print $1}' | /usr/bin/sort | /usr/bin/xargs|grep -i cyberlog|wc -l)
        carp=$(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") && ( $11 != "91") { print $1}' | /usr/bin/sort | /usr/bin/xargs|grep -i carp|wc -l)
        css=$(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") && ( $11 != "91") { print $1}' | /usr/bin/sort | /usr/bin/xargs|grep -i css_mon|wc -l)

        existCcs="NO"
        if [ $css -gt 0 ]
            then existCcs="SI"
        fi

        existCarp="NO"
        if [ $carp -gt 0 ]
            then existCarp="SI"
        fi

        existCyberark="NO"
        if [ $cyber -gt 0 ]
            then existCyberark="SI"
        fi

        existCyberlog="NO"
        if [ $cyber2 -gt 0 ]
            then existCyberlog="SI"
        fi

        users=""
        for u in $(/usr/bin/logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") && ( $11 != "91") { print $1}' | /usr/bin/sort | /usr/bin/xargs | /usr/bin/head -1)
            do
                result=$(/usr/bin/last -1 $u | /usr/bin/head -1)
                if [ ! -z "$result" ]
                    then
                        if [ $(echo $result | grep console > /dev/null) ]
                            then
                                lastDate=$(echo "$result" | /usr/bin/awk -F' ' '{print $5"/"$4}')
                            else
                                lastDate=$(echo "$result" | /usr/bin/awk -F' ' '{print $6"/"$5}')
                        fi
                         else
                             lastDate="never"
                fi
                users="$users $u|$lastDate"
            done

        users=$(echo $users | xargs)
        linea="$(cat /var/hostname);$os;$nousers;$existCarp;$existCyberark;$existCyberlog;$existCcs;$users"
        datos="$(cat /var/hostname);$os;$nousers;$existCarp;$existCyberark;$existCyberlog;$existCcs"

        for i in  $(echo $linea | awk -F";" '{print $8}')
            do
                mm=$(echo "${i}"| awk -F"|" '{print $1}')
                block=$(logins -oxl ${mm} | awk -F: '{print $8}')
                ##rotated=$(logins -oxl ${mm} | awk -F: '{print $11}')
                ##fecha=$(logins -oxl ${u} | awk -F: '{print $9}')
                minD=$(logins -oxl ${mm} | awk -F: '{print $10'}|sed 's/ //g')
                maxD=$(logins -oxl ${mm} | awk -F: '{print $11'}|sed 's/ //g')
                warD=$(logins -oxl ${mm} | awk -F: '{print $12'}|sed 's/ //g')

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

                echo "${2};$(cat /var/hostname);Vodafone-IT;${i};${bloqueado};${rotado};${minD};${maxD};${warD};${hardenizado}" |  tr '|' ';'
             done
        echo "A1HOJA;SERVIDOR;SISTEMA;USUARIOS;CARP*;CYBEARK;CYBERLOG;CCS_MON"
        echo "OTRA HOJA;${datos}"
fi

if [ "${sistema}" == "Linux" ]
    then
        os=$( (cat /etc/redhat-release || lsb_release -ds || cat /etc/*release | grep -i pretty_name || uname -om) 2>/dev/null | head -n1 | sed 's/PRETTY_NAME=//' | tr -d '"')
        version=$(echo $os | tr -dc '0-9' | cut -c-1)

        nouser=$(egrep ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1 | wc -l)
        users=$(egrep ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1 | sort | xargs | head -1)
        now=$(date +%s)
        cyber=$(grep -ci cyberark /etc/shadow)
        cyber2=$(grep -ci cyberlog /etc/shadow)
        carp=$(grep -ci carp /etc/shadow)
        css=$(grep -ci ccs_mon /etc/shadow)

        existCcs="NO"
        if [ $css -gt 0 ]
            then existCcs="SI"
        fi

        existCarp="NO"
        if [ $carp -gt 0 ]
            then existCarp="SI"
        fi

        existCyberark="NO"
        if [ $cyber -gt 0 ]
            then existCyberark="SI"
        fi

        existCyberlog="NO"
        if [ $cyber2 -gt 0 ]
            then existCyberlog="SI"
        fi


        users=""
        for u in $(egrep ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1 | sort | xargs | head -1)
            do
                result=$(lastlog -u $u)
                if [ $? -eq 0 ]
                    then 
                        result=$(lastlog -u $u | tail -1 | tr -s ' ')
                        if [[ "$result" == *"Never"* ]]
                            then
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
                if [ -f "$h/.bash_history" ]
                    then
                        historyDate=$(stat -c %y $h/.bash_history | awk '{print $1}' | awk -F- '{print $3"/"$2"/"$1}')
                        last=$(echo "$historyDate" | awk -v FS=/ -v OFS=/ '{print $3,$2,$1}' | xargs -i date -d {} +%s)
                        diffDaysHistory=$(( ($now - $last)/(86400) ))
                    else
                        historyDate="no_history"
                        diffDaysHistory="99999"
                fi

                users="$users $u|$lastDate|$diffDays|$historyDate|$diffDaysHistory"
            done


        users=$(echo $users | xargs)
        linea="$(hostname | cut -d'.' -f1 | tr a-z A-Z);$os;$nouser;$existCarp;$existCyberark;$existCyberlog;$existCcs;$users"
        datos="$(hostname | cut -d'.' -f1 | tr a-z A-Z);$os;$nouser;$existCarp;$existCyberark;$existCyberlog;$existCcs"

        for i in $(echo $linea | awk -F";" '{print $8}')
            do
                mm=$(echo "${i}"| awk -F"|" '{print $1}')
                block=$(passwd --status ${mm}| awk '{print $2}')
                ##rotated=$(passwd --status ${mm}| awk '{print $5}')
                minD=$(chage -l ${mm} | grep -i "Minimum" |awk -F: '{print $2}'|sed 's/ //g')
                maxD=$(chage -l ${mm} | grep -i "Maximum" |awk -F: '{print $2}'|sed 's/ //g')
                warD=$(chage -l ${mm} | grep -i "Warning" |awk -F: '{print $2}'|sed 's/ //g')

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

                echo "${2};$(hostname | cut -d'.' -f1 | tr a-z A-Z);Vodafone-IT;${i};${bloqueado};${rotado};${minD};${maxD};${warD};${hardenizado}" |  tr '|' ';'
            done

        echo "A1HOJA;SERVIDOR;SISTEMA;USUARIOS;CARP*;CYBEARK;CYBERLOG;CCS_MON"
        echo "OTRA HOJA;${datos}"
fi 

}

## FUNCIONES EN DESUSO AL EJECUTAR TODO EN BUCLE INICIAL
escaneo_maquina_tele2 ()
{
ssh ADMUNIX << EOF 
ssh ${serv}  'bash' 
$(typeset -f funcion)
funcion ${serv}
EOF
}

escaneo_maquina_vodafone ()
{
ssh hmc << EOF
ssh ${serv} 'bash'
$(typeset -f funcion)
funcion ${serv}
EOF
}

escaneo_maquina_ono ()
{
ssh ${serv} 'bash'<< EOF
$(typeset -f funcion)
funcion ${serv}
EOF
}

#################### FUNCION MAIN ####################

f_master="ficheros/master_maquinas.txt"
f_uso="escaneo_maquina.txt"

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

if [ -f $0.flag ]
     then
        clear
        echo ""
        echo " Ya hay un usuario usando este menu "
        echo ""
        continua
        exit 0
        else
        touch  $0.flag 
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
                    ESCANEO MAQUINAS
    ==========================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y escaneo_maquina.txt 
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           escaneo_maquina.txt -> Listado de maquinas
       
EOF

continua
############################################################
############################################################

# Creamos cabecera CSV
echo "ID;SERVIDOR;ENTORNO;USUARIO;LAST_LOGIN;DIFF_DAYS;LAST_COMMAND;DIFF_LAST_COMMAND;BLOCK;ROTATED;MIN_DAYS;MAX_DAYS;WARN_DAYS;HARDENIZADO"


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
done 3< escaneo_maquina.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

sed $'s/[^[:print:]\t]//g' escaneo_maquina.log | grep -Ei "HARDENIZADO|Vodafone-IT" > escaneo_maquina_USUARIOS.csv
perl -npi -e "s/Press ENTER to continue ...//g" escaneo_maquina_USUARIOS.csv
grep -wv "root" escaneo_maquina_USUARIOS.csv > escaneo_maquina_USUARIOS.csv_TMP
mv escaneo_maquina_USUARIOS.csv_TMP escaneo_maquina_USUARIOS.csv

sed $'s/[^[:print:]\t]//g' escaneo_maquina.log | grep -Ei "A1HOJA|OTRA HOJA" > escaneo_maquina_DATOS_MAQUINA.csv
perl -npi -e "s/Press ENTER to continue ...//g" escaneo_maquina_DATOS_MAQUINA.csv


sort -u escaneo_maquina_DATOS_MAQUINA.csv > temp.kk
cat temp.kk | awk -F";" '{print $2";"$3";"$4";"$5";"$6";"$7";"$8";"$9}' > escaneo_maquina_DATOS_MAQUINA.csv
rm -f temp.kk

# Comprobamos maquinas que no se han podido hacer 1

cat ficheros/master_maquinas.txt | while read line
do
a=$(echo "${line}"| awk -F";" '{print $2}')
b=$(grep -cw "${a}"  escaneo_maquina_USUARIOS.csv)
c=$(echo "${line}"| awk -F";" '{print $1}')

if [ ${b} -lt 1 ]
then
echo "${c};${a};Vodafone-IT;SCAN FAIL;;;;;;;" >> escaneo_maquina_USUARIOS.csv_TMP2
fi
done

fecha=$(date +%d_%m_%Y)
cat escaneo_maquina_USUARIOS.csv_TMP2 >> escaneo_maquina_USUARIOS.csv
mv escaneo_maquina_USUARIOS.csv escaneo_maquina_USUARIOS_${fecha}.csv
rm -f escaneo_maquina_USUARIOS.csv_TMP2 

# Comprobamos maquinas que no se han podido hacer 2

cat ficheros/master_maquinas.txt | while read line
do
a=$(echo "${line}"| awk -F";" '{print $2}')
b=$(grep -cw "${a}"  escaneo_maquina_DATOS_MAQUINA.csv)
c=$(echo "${line}"| awk -F";" '{print $1}')

if [ ${b} -lt 1 ]
then
echo "${c};${a};Vodafone-IT;SCAN FAIL;;;;;;;" >> escaneo_maquina_DATOS_MAQUINA.csv_TMP2
fi
done

fecha=$(date +%d_%m_%Y)
cat escaneo_maquina_DATOS_MAQUINA.csv_TMP2 >> escaneo_maquina_DATOS_MAQUINA.csv
mv escaneo_maquina_DATOS_MAQUINA.csv escaneo_maquina_DATOS_MAQUINA_${fecha}.csv
rm -f escaneo_maquina_DATOS_MAQUINA.csv_TMP2 
