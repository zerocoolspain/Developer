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

echo "Tratamos servidor ${1}" 

sistema=$(uname)

if [ "${sistema}" == "SunOS" ]
    then
        # Normalizamos Rotado y aplicamos a TODOS los usuarios excepto root, bloqueados y nologin
        awk '/MAXWEEKS=/ { $1 = "MAXWEEKS=13" } { print }' /etc/default/passwd > /etc/default/passwd.new
        mv /etc/default/passwd.new /etc/default/passwd
        for u in $(logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") { print $1 }')
            do
                passwd -x 91 $u
            done
      

        # Normalizamos periodo para cambio de password y aplicamos a TODOS los usuarios excepto root, bloqueados y nologin
        awk '/MINWEEKS=/ { $1 = "MINWEEKS=1" } { print }' /etc/default/passwd > /etc/default/passwd.new
        mv /etc/default/passwd.new /etc/default/passwd
        for u in $(logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") && ( $10 != "7" ) { print $1 }')
            do
                passwd -n 7 $u
            done
  

        # Normalizamos aviso cambio password y aplicamos a TODOS los usuarios excepto root, bloqueados y nologin
        awk '/WARNWEEKS=/ { $1 = "WARNWEEKS=1" } { print }' /etc/default/passwd > /etc/default/passwd.new
        mv /etc/default/passwd.new /etc/default/passwd
        for u in $(logins -ox | awk -F: '( $1 != "root" && $8 != "LK" && $8 != "NL") && ( $12 != "7") { print $1 }')
            do
                passwd -w 7 $u
            done
      
           
fi

}

## FUNCIONES EN DESUSO AL EJECUTAR TODO EN BUCLE INICIAL
normalizado_todos_usuarios_solaris_tele2 ()
{
ssh ADMUNIX << EOF 
ssh ${serv}  'bash' 
$(typeset -f funcion)
funcion ${serv}
EOF
}

normalizado_todos_usuarios_solaris_vodafone ()
{
ssh hmc << EOF
ssh ${serv} 'bash'
$(typeset -f funcion)
funcion ${serv}
EOFodafone.sh
sh vodafone.sh
}

normalizado_todos_usuarios_solaris_ono ()
{
ssh ${serv} 'bash'<< EOF
$(typeset -f funcion)
funcion ${serv}
EOF
}

#################### FUNCION MAIN ####################

f_master="master_maquinas.txt"
f_uso="normalizado_todos_usuarios_solaris.txt"

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

 
    =====================================================================================
                NORMALIZADO DE PARAMETROS Y USUARIOS EN MAQUINAS SOLARIS
    =====================================================================================
     
     NOTA: Se usaran los ficheros master_maquinas.txt y normalizado_maquinas_solaris.txt 
           master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           normalizado_todos_usuarios_solaris.txt -> Listado de maquinas a tratar
       
EOF

continua
############################################################
############################################################


while IFS=';' read -r serv user <&3 
do
 {
    red=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ficheros/master_maquinas.txt)
    #identificador=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt)

   if [ "${red}" == "VODAFONE" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            scp -p funcion_no_borrar.sh hmc:/tmp/.
            ssh hmc << EOF
            scp -p /tmp/funcion_no_borrar.sh ${serv}:/tmp/.
            ssh ${serv} 'bash -s' <  /tmp/funcion_no_borrar.sh "${serv}"
            ssh ${serv} 'rm -f /tmp/funcion_no_borrar.sh'
EOF
            ssh hmc 'rm -f /tmp/funcion_no_borrar.sh'
            rm -f funcion_no_borrar.sh
    fi 

    if [ "${red}" == "TELE2" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            ssh hmc 'ssh admunix 'ssh "${serv}" 'bash -s''' <  funcion_no_borrar.sh "${serv}"
            rm -f funcion_no_borrar.sh
    fi

    if [ "${red}" == "ONO" ]
        then
            typeset -f funcion > funcion_no_borrar.sh
            echo "funcion \${1} \${2}" >> funcion_no_borrar.sh
            ssh "${serv}" 'bash -s' <  funcion_no_borrar.sh "${serv}"
            rm -f funcion_no_borrar.sh
    fi
 } 3<&-
done 3< normalizado_todos_usuarios_solaris.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

sed $'s/[^[:print:]\t]//g' normalizado_todos_usuarios_solaris.log | grep -Ei "ENTORNO|Vodafone-IT" > normalizado_todos_usuarios_solaris.csv
perl -npi -e "s/Press ENTER to continue ...//g" normalizado_todos_usuarios_solaris.csv
