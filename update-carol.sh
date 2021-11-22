#!/bin/bash
clear
echo "===============T O T V S - C L O U D ==============================="
echo "===========PROCESSO DE ATUALIZACAO DA CAROL - 2C==========="
echo "========================================================"

#VARIAVEIS GLOBAIS

DIR_ORIG=/tmp/

checa_result()
{
    if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; exit 1;
    fi
}

################################################
#Inicio do script.

echo -e "Qual versao deseja instalar? Exemplo: '3.3.8'. "
read VCAROL

echo "Realizando o download da versao $VCAROL"
echo "."
wget https://storage.googleapis.com/labs-2c-releases-1/$VCAROL/CarolConnectLinux.tar.gz -O /outsourcing/totvs/CarolConnectLinux.tar.gz 2>&1

if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Verifique se a versao digitada esta correta e tente novamente."; exit 1;
    fi


echo "Desabilitando o servico Carol Connector"
echo "."
systemctl disable /outsourcing/totvs/2c/carolconnector.service
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi possivel desabilitar o servico carolconnector. Por favor entre em contato com a equipe responsavel."; exit 1;
    fi

echo "Realizando backup do diretorio atual 2C"
echo "."
zip -r /outsourcing/totvs/2c_backup`date +"%Y%m%d_%H%M%S"`.zip /outsourcing/totvs/2c
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi possivel Realizar o backup Por gentileza verifique se ha espaco em disco."; exit 1;
    fi

echo "Excluindo o arquivo `ls /outsourcing/totvs/2c/mdm*.jar` do diretorio 2C..."
echo "."
rm -Rf /outsourcing/totvs/2c/mdm*.jar
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi excluir o arquivo .Jar"; exit 1;
    fi

echo "Extraindo a nova versao do 2C-Carol"
echo "."
tar -xf /outsourcing/totvs/CarolConnectLinux.tar.gz -C /outsourcing/totvs/
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi possivel extrair o arquivo baixado. Por favor tente novamente."; exit 1;
    fi

echo "Ajustando permissoes do diretorio /outsourcing/totvs/2c"
echo "."
chown -R protheus.totvs /outsourcing/totvs/2c
chmod -R 770 /outsourcing/totvs/2c
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; exit 1;
    fi

echo "Ajustando o novo servico CarolConnect"
echo "."
sed -i s#User=carol#User=protheus#g /outsourcing/totvs/2c/carolconnector.service
sed -i s#WorkingDirectory=/opt/2c#WorkingDirectory=/outsourcing/totvs/2c#g /outsourcing/totvs/2c/carolconnector.service
sed -i s#ExecStart=/opt/2c/2c.sh#ExecStart=/outsourcing/totvs/2c/2c.sh#g /outsourcing/totvs/2c/carolconnector.service


echo "Reiniciando o daemon e criando o novo servico CarolConnect"
echo "."
systemctl daemon-reload
systemctl start /outsourcing/totvs/2c/carolconnector.service
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi possivel instalar o novo servico. Tente novamente." exit 1;
    fi

echo "Consultando o novo servico instalado..."
systemctl status carolconnector.service
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi possivel consultar o novo servico. Verifique se o mesmo esta instalado." exit 1;
    fi


echo ""

