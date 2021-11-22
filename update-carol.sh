#!/bin/bash
#Script criado por Diogo Nogueira - Squad Cloud RM
clear
echo "===================T O T V S - C L O U D==========================="
echo "============SCRIPT DE ATUALIZACAO DA CAROL - 2C===================="
echo "==================================================================="
################################################
#Inicio do script.

echo "Checando ultima versao disponivel..."
echo ""
sleep 1
curl --silent https://storage.googleapis.com/labs-2c-releases-1/CHANGELOG.md | grep "##" | head -n 1

sleep 1

echo ""
echo ""
echo "Qual versao deseja instalar? Exemplo: '3.3.8'"
read VCAROL

echo "Realizando o download da versao $VCAROL"
wget -q https://storage.googleapis.com/labs-2c-releases-1/$VCAROL/CarolConnectLinux.tar.gz -O /outsourcing/totvs/CarolConnectLinux.tar.gz 2>&1
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Verifique se a versao digitada esta correta e tente novamente."; exit 1;
    fi
echo "."
sleep 2

echo "Parando o servico Carol Connector"
/outsourcing/totvs/cloud/scripts/protheus/actions/2c_service.py stop
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi possivel parar o servico carolconnector. Por favor entre em contato com a equipe responsavel."; exit 1;
    fi
echo "."
sleep 2

echo "Desabilitando o servico Carol Connector"
systemctl disable /outsourcing/totvs/2c/carolconnector.service
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi possivel desabilitar o servico carolconnector. Por favor entre em contato com a equipe responsavel."; exit 1;
    fi
echo "."
sleep 2


echo "Realizando backup do diretorio atual 2C"
zip -rqq /outsourcing/totvs/2c_backup`date +"%Y%m%d_%H%M%S"`.zip /outsourcing/totvs/2c
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi possivel Realizar o backup Por gentileza verifique se ha espaco em disco."; exit 1;
    fi
echo "."
sleep 2

echo "Excluindo o arquivo `ls /outsourcing/totvs/2c/mdm*.jar` do diretorio 2C..."
rm -Rf /outsourcing/totvs/2c/mdm*.jar
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi excluir o arquivo .Jar"; exit 1;
    fi
echo "."
sleep 2

echo "Extraindo a nova versao do 2C-Carol"
tar -xf /outsourcing/totvs/CarolConnectLinux.tar.gz -C /outsourcing/totvs/
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi possivel extrair o arquivo baixado. Por favor tente novamente."; exit 1;
    fi
echo "."
sleep 2

echo "Ajustando permissoes do diretorio /outsourcing/totvs/2c"
chown -R protheus.totvs /outsourcing/totvs/2c
chmod -R 770 /outsourcing/totvs/2c
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; exit 1;
    fi
echo "."
sleep 2

echo "Ajustando o novo servico CarolConnect"
sed -i s#User=carol#User=protheus#g /outsourcing/totvs/2c/carolconnector.service
sed -i s#WorkingDirectory=/opt/2c#WorkingDirectory=/outsourcing/totvs/2c#g /outsourcing/totvs/2c/carolconnector.service
sed -i s#ExecStart=/opt/2c/2c.sh#ExecStart=/outsourcing/totvs/2c/2c.sh#g /outsourcing/totvs/2c/carolconnector.service
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; exit 1;
    fi
echo "."
sleep 2

echo "Reiniciando o daemon e criando o novo servico CarolConnect"
systemctl daemon-reload
systemctl enable /outsourcing/totvs/2c/carolconnector.service
systemctl start carolconnector.service
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi possivel instalar o novo servico. Tente novamente." exit 1;
    fi
echo "."
sleep 2

echo "Consultando o novo servico instalado..."
systemctl status carolconnector.service
if [ $? -eq 0 ]
		then printf "\e[1;32mOk.\e[0m\n"
		else printf "\e[1;31mFalha.\e[0m\n"; echo "Nao foi possivel consultar o novo servico. Verifique se o mesmo esta instalado." exit 1;
    fi
sleep 2
echo "."
echo "."
echo "."

echo "A atualizacao para a versao $VCAROL finalizada com sucesso!"

