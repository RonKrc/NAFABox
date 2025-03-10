################################################
# Under GPL license
#     https://www.gnu.org/licenses/gpl.html
# Authors:	Patrick Dutoit
# 			Laurent Roge
# On June 10 2017
# V0.1
# v0.2  ajout de browsepy (Patrick Dutoit)
################################################
#!/bin/bash -i
######
# Recherche du répertoire ConfigTinker
######
if [[ -z "$nafabox_path" ]]
then
	echo "Run first Pre_Install.sh and reload Terminal"
	exit
fi
dirinstall=${nafabox_path}
server_choice=$1

figlet -k Install ComSetup
echo "================================================="
echo "================================================="
echo " Install time zone, Web Interface, X11VNC, WebDavServer, BrowsePy and NoVNC"
echo "================================================="
echo "================================================="

cd ${dirinstall}
######
# detect language
######
source ${dirinstall}/detect_language.sh
source ${dirinstall}/proctype.sh


sudo apt-get update
if [[ ${server_choice} == "server" ]]
then
    echo "############################"
    echo "## install in server mode ##"
    echo "############################"
	web=TRUE
	xvnc=FALSE
	dav=TRUE
	browse=TRUE
	novnc=FALSE
    	nomach=FALSE
    	ddserv=TRUE
    	mobindi=FALSE
elif [[ ${server_choice} == "default" ]]
then
    echo "#############################"
    echo "## install in default mode ##"
    echo "#############################"
	web=TRUE
	xvnc=TRUE
	dav=TRUE
	browse=TRUE
	novnc=TRUE
    	nomach=TRUE
    	ddserv=TRUE
    	mobindi=TRUE
    
else
	if ${french}
	then
		dial[0]="Installation/Mise à jour des logiciels"
		dial[1]="Choisir le(s) logiciel(s) à installer"
		choice[0]="Installation Interface HTML"
		choice[1]="Installation X11VNC"
		choice[2]="Install WebDav"
		choice[3]="Installation BrowsePy"
		choice[4]="Installation NoVNC"
        	choice[5]="Installation Nomachine"
        	choice[6]="Serveur pour QDslrDashboard"
		choice[7]="Installation de Mobindi"

	else
		dial[0]="Install/Update of software"
		dial[1]="Choose software(s) to install"
		choice[0]="Install HTML Interface"
		choice[1]="Install X11VNC"
		choice[2]="Install WebDav"
		choice[3]="Install BrowsePy"
		choice[4]="Install NoVNC"
        	choice[5]="Install Nomachine"
        	choice[6]="Server for QDslrDashboard"
		choice[7]="Install Mobindi"

	fi

	st=(true true true true true true true true)

	# interface de choix
	if chose=`yad --width=400 \
		--center \
		--form \
		--title="${dial[0]}" \
		--text="${dial[1]}" \
		--field=":LBL" \
		--field="${choice[0]}:CHK" \
		--field="${choice[1]}:CHK" \
		--field="${choice[2]}:CHK" \
		--field="${choice[3]}:CHK" \
		--field="${choice[4]}:CHK" \
		--field="${choice[5]}:CHK" \
		--field="${choice[6]}:CHK" \
        	--field="${choice[7]}:CHK" \
		"" "${st[0]}" "${st[1]}" "${st[2]}" \
		"${st[3]}" "${st[4]}" "${st[5]}" "${st[6]}" \
        	"${st[7]}"`
	then
		web=$(echo "$chose" | cut -d "|" -f2)
		xvnc=$(echo "$chose" | cut -d "|" -f3)
		dav=$(echo "$chose" | cut -d "|" -f4)
		browse=$(echo "$chose" | cut -d "|" -f5)
		novnc=$(echo "$chose" | cut -d "|" -f6)
        	nomach=$(echo "$chose" | cut -d "|" -f7)
        	ddserv=$(echo "$chose" | cut -d "|" -f8)
        	mobindi=$(echo "$chose" | cut -d "|" -f9)
	else
		echo "cancel"
	fi
fi

if [[ ${web} == "TRUE" ]]
then

    figlet -k Install web server
	######
	# Installer nginx
	######
	sudo apt-get -y install nginx apache2 cockpit
	######
	# Installer php
	######
	sudo apt-get -y install php
	######
	# Creer le répertoire www
	######
	site=/home/${USER}/www
	mkdir -p /home/${USER}/www
	######
	# Installer les fichiers nécessaires pour la mise à l'heure
	# en remote
	######
	# le fichier html d'accès au site
	if ${french}
	then
		dial[0]="Actualiser la date"
		dial[1]="Date==>NAFABox"
		dial[2]="Date actualisée a"
		dial[3]="Pour la mise a l\'heure se connecter sur le boitier
	avec l\'adresse IP de ce dernier qui differe selon qu\'il
	est soit en reseau domestique soit en mode point d\'acces."
	else
		dial[0]="Actuate Date"
		dial[1]="Update hour"
		dial[2]="Date and time updated to"
		dial[3]="To update remote date do connect to the box with its
	IP adress which is different if it is on home network or access point"
	fi
	#echo "Dirinstall "$dirinstall
#	cat ${dirinstall}/index.html | sed -e "s/ACTUATE/${dial[0]}/g" > ${site}/index.html
	cat ${dirinstall}/startup.php | sed -e "s/ACTUATE/${dial[0]}/g" > ${site}/startup.php

	sudo systemctl stop nginx.service
	sudo systemctl disable nginx.service
	sudo cp ${dirinstall}/setdate.php ${site}/setdate.php
	sudo cp ${dirinstall}/getTemp.php ${site}/getTemp.php
	sudo cp ${dirinstall}/logo_256.png ${site}/logo_256.png
	sudo cp ${dirinstall}/light.css ${site}/light.css
	sudo cp ${dirinstall}/dark.css ${site}/dark.css
	sudo cp ${dirinstall}/shutdown_reboot.php ${site}/shutdown_reboot.php
	sudo chown www-data:www-data ${site}/startup.php
	sudo chown www-data:www-data ${site}/setdate.php
	sudo chown www-data:www-data ${site}/getTemp.php
	sudo chown www-data:www-data ${site}/logo_256.png
	sudo chown www-data:www-data ${site}/light.css
	sudo chown www-data:www-data ${site}/dark.css
	sudo chown www-data:www-data ${site}/shutdown_reboot.php
	
	# ajout droit d'acces pour nginx
	sudo gpasswd -a www-data ${USER}

	# move apache at port 8280
	cat /etc/apache2/ports.conf | sed -e "s/Listen 80/Listen 8280/g" > /tmp/ports.conf
	sudo mv /tmp/ports.conf /etc/apache2/ports.conf
	cat /etc/apache2/sites-enabled/000-default.conf | sed -e "s=*:80=*:8280=g" > /tmp/000-default.conf
	sudo mv /tmp/000-default.conf /etc/apache2/sites-enabled/000-default.conf
	sudo service apache2 restart


	sudo systemctl enable nginx.service
	sudo systemctl start nginx.service

	cat sudoers.txt | sed -e "s/MOI/${USER}/g" > /tmp/sudoers
	sudo cp /tmp/sudoers /etc/sudoers.d/perm${USER}
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "${dial[3]}"
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

	######
	# Installation du serveur nginx
	######
	# mod 22/11/2018
	sudo apt-get install -y --reinstall php-fpm
    #
	sudo apt-get install -y --reinstall nginx
	sudo apt-get -y install php-fpm
	sudo rm /etc/nginx/sites-available/default
	sudo rm /etc/nginx/sites-enabled/default
	cat ${dirinstall}/server.txt | sed -e "s/MOI/${USER}/g" > /tmp/site-temp
    if [[ -S "/var/run/php/php7.0-fpm.sock" ]]
    then
        cat /tmp/site-temp | sed -e "s/VER-PHP/7.0/g" > /tmp/site-${USER}
    elif  [[ -S "/var/run/php/php7.1-fpm.sock" ]]
    then
        cat /tmp/site-temp | sed -e "s/VER-PHP/7.1/g" > /tmp/site-${USER}
    elif  [[ -S "/var/run/php/php7.2-fpm.sock" ]]
    then
        cat /tmp/site-temp | sed -e "s/VER-PHP/7.2/g" > /tmp/site-${USER}
    elif  [[ -S "/var/run/php/php7.3-fpm.sock" ]]
    then
        cat /tmp/site-temp | sed -e "s/VER-PHP/7.3/g" > /tmp/site-${USER}
    elif  [[ -S "/var/run/php/php7.4-fpm.sock" ]]
    then
        cat /tmp/site-temp | sed -e "s/VER-PHP/7.4/g" > /tmp/site-${USER}
    elif  [[ -S "/var/run/php/php8.0-fpm.sock" ]]
    then
        cat /tmp/site-temp | sed -e "s/VER-PHP/8.0/g" > /tmp/site-${USER}
    elif  [[ -S "/var/run/php/php8.1-fpm.sock" ]]
        then
        cat /tmp/site-temp | sed -e "s/VER-PHP/8.1/g" > /tmp/site-${USER}
    elif  [[ -S "/var/run/php/php8.2-fpm.sock" ]]
    then
        cat /tmp/site-temp | sed -e "s/VER-PHP/8.2/g" > /tmp/site-${USER}
    fi
	sudo cp /tmp/site-${USER} /etc/nginx/sites-available/site-${USER}
	sudo chown ${USER}:${USER} /etc/nginx/sites-available/site-${USER}
	sudo ln -sf /etc/nginx/sites-available/site-${USER} /etc/nginx/sites-enabled/site-${USER}

fi

if [[ ${dav} == "TRUE" ]]
then
	######
	# Install of webdav server
	######
	${dirinstall}/install_webdavserver.sh
fi

if [[ ${browse} == "TRUE" ]]
then
	######
	# Install of browsepy
	######
	${dirinstall}/install_browsepy.sh
fi

if [[ ${nomach} == "TRUE" ]]
then
	######
	# Install of nomachine server
	######
	${dirinstall}/install_nomachine.sh
fi


if [[ ${xvnc} == "TRUE" ]]
then
	######
	# Installation x11vnc
	######

	figlet -k Install X11VNC

	sudo apt-get -y install x11vnc

	# demarage sur la session 

	#mkdir -p ~/.x11vnc
	#mkdir -p ~/bin/
	#cp $dirinstall/startx11vnc.sh ~/bin/
	#chmod +x ~/bin/startx11vnc.sh
	#~/bin/startx11vnc.sh
	#mkdir -p ~/.config/autostart/
	#cat $dirinstall/startx11vnc.desktop | sed -e "s/nafa/${USER}/g" > /tmp/startx11vnc.desktop
	#cp /tmp/startx11vnc.desktop ~/.config/autostart/
	#

	# demarage sur le X11
	vnc_path=/home/${USER}/.vnc/passwd
	rm ${vnc_path}
	test_w=true
	number_t=0
	while ${test_w} && [[ "$number_t" < 3 ]]
	do
        	echo "Enter Le mot de passe VNC pour votre BOX :"
        	x11vnc -storepasswd
        	if [[ -f ${vnc_path} ]]
        	then
        	    test_w=false
        	else
        	    number_t=$((number_t + 1))
        	    echo "Reload, remaing test: "$((3-number_t))
        	fi
	done
	echo "Merci ! ----------------------------------"

	machine=$(sudo lshw | grep "produit\|product" | grep "Raspberry")
	normal_option="-auth guess -forever -loop -noncache -noxdamage -noxrecord -repeat -shared -xkb -rfbauth $vnc_path -rfbport 5900"
	tinker_option="-forever -loop -noncache -noxdamage -noxrecord -repeat -shared -xkb -rfbauth $vnc_path -rfbport 5900"

 	#test version
	if [[ ${proc} == "_amd64" ]]
	then
		option=${normal_option}
	elif [[ ${proc} == "_armhf" ]]
	then
		if [[ ${machine} == *"Raspberry"* ]]
		then 
			option=${normal_option}
		else
			option=${tinker_option}
		fi
	elif [[ ${proc} == "_x86" ]]
	then
		option=${normal_option}
	elif [[ ${proc} == "_aarch64" ]]
	then
		if [[ ${machine} == *"Raspberry"* ]]
		then 
			option=${normal_option}
		else
			option=${tinker_option}
		fi
	fi

	# injection fichier system
	cat ${dirinstall}/x11vnc.service | sed -e "s=OPTION=$option=g" > /tmp/x11vnc2.service
	cat /tmp/x11vnc2.service | sed -e "s=MOI=${USER}=g" > /tmp/x11vnc.service
	sudo mv /tmp/x11vnc.service /lib/systemd/system/x11vnc.service
	# allumage au démarage
	sudo systemctl stop x11vnc.service
	sudo systemctl disable x11vnc.service
	sudo systemctl daemon-reload
	sudo systemctl enable x11vnc.service
	sudo systemctl start x11vnc.service
	echo "Need reboot for active VNC"

	######
	# Installation TightVNC Server
	######

	figlet -k Install TightVNC Server

	sudo apt-get -y install tightvncserver

	# injection fichier system
	cat ${dirinstall}/tightvnc.service | sed -e "s=MOI=${USER}=g" > /tmp/tightvnc.service
	sudo mv /tmp/tightvnc.service /lib/systemd/system/tightvnc.service
	# allumage au démarage
	sudo systemctl stop tightvnc.service
	sudo systemctl disable tightvnc.service
	sudo systemctl daemon-reload
	sudo systemctl enable tightvnc.service
	sudo systemctl start tightvnc.service
	echo "Need reboot for active VNC"

	cp ${dirinstall}/xstartup ${USER}/.vnc/xstartup
fi


if [[ ${novnc} == "TRUE" ]]
then
	######
	# Installation accès vnc via navigateur
	######
	figlet -k Install novnc
	sudo apt-get -y install novnc
	sudo apt-get -y install git

	cd /home/${USER}/bin/
	#
	#test si le dossier noVNC existe, si oui suppression
	#
	if [[ -d "/home/${USER}/bin/noVNC" ]]
	then
	  echo "suppression de l'ancien dossier noVNC"
	  rm -Rf /home/${USER}/bin/noVNC
	fi

    #version=`curl -s "https://api.github.com/repos/novnc/noVNC/releases/latest" | awk -F '"' '/tag_name/{print $4}'`
    version="v1.3.0"
    wget https://github.com/novnc/noVNC/archive/${version}.zip
    unzip ${version}.zip
    rm ${version}.zip
    mv noVNC-${version:1} noVNC


	#git clone git://github.com/kanaka/noVNC

	if [[ -f /etc/systemd/system/novnc.service ]]
	  then
	  sudo systemctl stop novnc.service
	  sudo systemctl disable novnc.service
	  sudo rm /etc/systemd/system/novnc.service
	fi

	cat ${dirinstall}/novnc.service | sed -e "s=MOI=${USER}=g" > /tmp/novnc.service
	sudo cp /tmp/novnc.service /lib/systemd/system/novnc.service
	# sudo chmod a+rwx /lib/systemd/system/novnc.service

	sudo systemctl daemon-reload
	sudo systemctl enable novnc.service
	sudo systemctl start novnc.service
fi

if [[ ${ddserv} == "TRUE" ]]
then
	######
	# Installation du ddserver pour qdslrdashboard
	######
	figlet -k Install ddserver

    cd ~/bin
    if [[ -d "/home/${USER}/bin/DslrDashboardServer" ]]
	  then
	  echo "suppression de l'ancien dossier ddserver"
	  rm -Rf /home/${USER}/bin/DslrDashboardServer
	fi
    git clone https://github.com/hubaiz/DslrDashboardServer.git
    sudo apt-get -y install build-essential pkg-config libusb-1.0-0-dev
    cd ~/bin/DslrDashboardServer
    g++ -Wall src/main.cpp src/communicator.cpp `pkg-config --libs --cflags libusb-1.0` -lpthread -lrt -lstdc++ -o ddserver
    sudo ln -sf ~/bin/DslrDashboardServer/ddserver /usr/bin/ddserver

	cat ${dirinstall}/ddserver.service | sed -e "s/MOI/${USER}/g" > /tmp/ddserver.service
	sudo cp /tmp/ddserver.service /lib/systemd/system/ddserver.service
	sudo systemctl stop ddserver.service
	sudo systemctl disable ddserver.service
	sudo systemctl daemon-reload
	sudo systemctl enable ddserver.service
	sudo systemctl start ddserver.service

fi

if [[ ${mobindi} == "TRUE" ]]
then
	${dirinstall}/install_mobindi.sh
fi
