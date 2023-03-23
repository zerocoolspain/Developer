#! /bin/bash-p

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

cambia_pass_tele2 ()
{
ssh hmc 'ssh ADMUNIX' 'ssh ${1}' 'chpasswd' < pass.txt
}

cambia_pass_vodafone ()
{
ssh hmc 'ssh ${1}' 'chpasswd' < pass.txt

}

cambia_pass_ono ()
{
ssh ${1} 'chpasswd' < pass.txt

}

#################### FUNCION MAIN ####################

f_master="ficheros/master_maquinas.txt"
f_uso="servidores_cyberark.txt"

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

 
    ===============================================================================
      CAMBIO PASS USUARIOS CYBERARK Y CYBERLOG (NO FUNCIONA CON MAQUINAS SOLARIS)
    ===============================================================================
     
     NOTA: Se usaran los ficheros ficheros/master_maquinas.txt y servidores_cyberark.txt
           ficheros/master_maquinas.txt -> Listado de maquinas (unicas) y red con formato: MAQUINA;RED
           servidores_cyberark.txt -> Listado de maquinas a tratar
           pass.txt -> Fichero con el password nuevo con formato: usuario:password
       
EOF

continua
############################################################
############################################################

while IFS='' read -r serv <&3 
do
 {
    red=$(gawk -v a="${serv}" '$2==a {print $3}' 'FS=;' ficheros/master_maquinas.txt)
    id=$(gawk -v a="${serv}" '$2==a {print $1}' 'FS=;' ficheros/master_maquinas.txt)
    
    if [ ${red} == "VODAFONE" ]
        then
            cambia_pass_vodafone ${serv}
    fi

    if [ ${red} == "TELE2" ]
        then
            cambia_pass_tele2 ${serv}
    fi

    if [ ${red} == "ONO" ]
        then
            cambia_pass_ono ${serv}
    fi
 } 3<&-
done 3< servidores_cyberark.txt
continua
clear

# Borramos fichero temporal
rm -f /home/mdearri2/vodafone.sh

sed $'s/[^[:print:]\t]//g' cambio_pass.log | grep -Ei "ENTORNO|Vodafone-IT" > cambio_pass.csv
perl -npi -e "s/Press ENTER to continue ...//g" cambio_pass.csv