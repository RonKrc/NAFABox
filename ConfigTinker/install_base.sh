################################################
# Under GPL license
#     https://www.gnu.org/licenses/gpl.html
# Authors:	Patrick Dutoit
# 			Laurent Roge
#			Sébastien Durand
# On June 10 2017
# V0.1
################################################
#!/bin/bash -i
######
######
# Recherche du répertoire ConfigTinker
######
if [[ -z "$nafabox_path" ]]
then
	echo "Run first Pre_Install.sh and reload Terminal"
	exit
fi
dirinstall=${nafabox_path}
source ${dirinstall}/proctype.sh

server_choice=$2

######
sudo rm /var/lib/dpkg/lock
sudo apt-get -y install libnss3
sudo apt-get -y install software-properties-common
sudo apt-get update 
sudo apt-get -y install dirmngr
sudo apt-get -y install git
sudo apt-get -y install gparted
sudo apt-get -y install chromium-browser
# for bluetooth
sudo apt-get -y install bluetooth bluez bluez-tools pulseaudio-module-bluetooth blueman
# for hotspot
sudo apt-get -y install dnsmasq hostapd
sudo apt-get -y install dhcpcd5 dhcpcd-gtk

#sudo apt-get --reinstall -o Dpkg::Options::="--force-confnew" -y --no-install-recommends install hostapd
#sudo apt-get --reinstall -o Dpkg::Options::="--force-confnew" -y --no-install-recommends install hostapd-realtek

version=`lsb_release -c -s`

#sudo usermod -l nafa -d /home/nafa -m tinker

######
# Options d'installation
######

# init

installMate="FALSE"
autologin="FALSE"
ip_indicator="FALSE"
o_indicator="FALSE"
host="FALSE"

if [[ $1 == "initial" ]]
then
	st=(true true true false true)

else
	st=(false false false false false)
fi

if [[ ${server_choice} == "server" ]]
then
    installMate="FALSE"
    autologin="FALSE"
    ip_indicator="FALSE"
    o_indicator="FALSE"
    host="TRUE"

elif [[ ${server_choice} == "default" ]]
then
    installMate="FALSE"
    dialog --title " Install Ubuntu MATE" --clear \
	    --yesno "Do you need install Ubuntu MATE" 10 30

    case $? in
	    0)	echo "Install Ubuntu MATE"
            installMate="TRUE"
            ;;
	    1)	
            installMate="FALSE"
            ;;
	    255)	
            echo "exit"
            ;;
    esac

    autologin="FALSE"
    ip_indicator="TRUE"
    o_indicator="TRUE"
    host="TRUE"
else
    if [[ ${DESKTOP_SESSION} == "mate" ]]
    then
        if chose=`yad --width=350 \
	        --center \
	        --form \
	        --title="Select Installation Options :" \
	        --text="Install Program :" \
	        --field=":LBL" \
	        --field="Plugin IP Indicator:CHK" \
            --field="Other indicator:CHK" \
	        --field="Autologin for dev armbian (nightly):CHK" \
	        --field="Change hostname to NAFABox ?:CHK" \
	        "" "${st[1]}" "${st[2]}" "${st[3]}" "${st[4]}"`
        then
	        # recuperation des valeurs
	        ip_indicator=$(echo "$chose" | cut -d "|" -f2)
            o_indicator=$(echo "$chose" | cut -d "|" -f3)
	        autologin=$(echo "$chose" | cut -d "|" -f4)
	        host=$(echo "$chose" | cut -d "|" -f5)

        else
	        echo "cancel"
        fi
    else
	    if chose=`yad --width=300 \
		    --center \
		    --form \
		    --title="Select Installation Options :" \
		    --text="Install Program :" \
		    --field=":LBL" \
		    --field="Mate destktop and components:CHK" \
		    --field="Plugin IP Indicator:CHK" \
            --field="Other indicator:CHK" \
		    --field="Autologin for dev armbian (nightly):CHK" \
		    --field="Change hostname to NAFABox ?:CHK" \
		    "" "${st[0]}" "${st[1]}" "${st[2]}" "${st[3]}" "${st[4]}"`
	    then
		    # recuperation des valeurs
		    installMate=$(echo "$chose" | cut -d "|" -f2)
		    ip_indicator=$(echo "$chose" | cut -d "|" -f3)
            o_indicator=$(echo "$chose" | cut -d "|" -f4)
		    autologin=$(echo "$chose" | cut -d "|" -f5)
		    host=$(echo "$chose" | cut -d "|" -f6)

	    else
		    echo "cancel"
	    fi
    fi
fi

if [[ ${host} == "TRUE" ]]
then


	${dirinstall}/install_hostname.sh ${server_choice}

fi

# Options de apt-get pour l'installation des paquets
options="-y"
#activation de l'autologin pour les version nightly
if [[ ${autologin} == "TRUE" ]]
then
	figlet -k Install AutoLogin
	echo "================================================="
	echo "================================================="

	if [[ -f "/usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf" ]]
	then
		if [grep -q "autologin" "/usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf" ]
		then
			echo "autologin exist"
		else
			echo "autologin activate"
			echo "autologin-user=$USER"| sudo tee -a /usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf
		fi
	fi
fi
#  Désinstallation de xfce et installation de Mate
if [[ ${installMate} == "TRUE" ]]
then

	figlet -k Install Ubuntu Mate
	echo "================================================="
	echo "================================================="

	# add repository pour avoir la 1.16 au lieu de la 1.12
	if [[ ${version} == "xenial" ]]
	then
		sudo apt-add-repository -y ppa:ubuntu-mate-dev/xenial-mate # ==> bug
	fi
	sudo apt-get update
	# désinstallation xfce4
	sudo apt-get -y remove --purge  xfce*
	sudo apt-get -y remove --purge  lxde
	sudo apt-get -y remove --purge  lubuntu*
	sudo apt autoremove -y
	sudo apt-get -y clean
	sudo apt-get update
	# installation du session manager
    echo "#################################"
    echo "Chose NoDM after install"
    echo "#################################"
	sudo apt-get -y install lightdm
	sudo apt-get -y install xserver-xorg
	sudo apt-get -y install lightdm-greeter
	# Mise à jour de l'autologin
	cat  ${dirinstall}/20-lightdm.conf | sed -e "s/MOI/$(whoami)/g" > /tmp/20-lightdm.conf
	sudo cp /tmp/20-lightdm.conf /etc/lighdm/lightdm.conf.d/.

    machine=$(sudo lshw | grep "produit\|product" | grep "Raspberry")

	# installation de base de mate
	sudo apt-get ${options} install mate
    sudo apt-get ${options} install ubuntu-mate-core ubuntu-mate-desktop
    sudo apt-get ${options} install ubuntu-mate-default-settings ubuntu-mate-icon-themes
    sudo apt-get ${options} install ubuntu-mate-live-settings ubuntu-mate-guide

	# installation de mate compléments
	sudo apt-get ${options} install mate-desktop-environment-extras mate-indicator-applet
	sudo apt-get ${options} install mate-dock-applet plank mate-hud mate-applet-brisk-menu mate-menu mate-applet-appmenu

    # dangereux à remplacer des que possible
	sudo apt-get ${options} install mate-*

	
	# supprimer veille
	sudo sed -i "/DPMS/ s/true/false/" /etc/X11/xorg.conf.d/01-armbian-defaults.conf
	# Ajout d'utilitaires
	echo "================================================="
	echo "================================================="
	echo "install supplements"
	echo "================================================="
	echo "================================================="

	sudo apt-get ${options} install synaptic
	sudo apt-get ${options} install engrapa
	sudo apt-get ${options} install caja-actions
	sudo apt-get ${options} install caja-wallpaper
	sudo apt-get ${options} install caja-open-terminal
	sudo apt-get ${options} install mozo
	sudo apt-get ${options} install pluma
	sudo apt-get ${options} install mate-tweak
	sudo apt-get ${options} install mate-themes
	sudo apt-get ${options} install mate-applets gnome-media
	sudo apt-get ${options} install mate-panel
	sudo apt-get ${options} install mate-system-monitor
	sudo apt-get ${options} install blueman
	sudo apt-get ${options} install firefox
	sudo apt-get ${options} install ubuntu-mate-themes
    sudo apt-get ${options} install pulseaudio libcanberra-pulse paprefs
    sudo apt-get ${options} install pulseaudio-module-bluetooth pulseaudio-module-gconf pulseaudio-module-zeroconf
    sudo alsa force-reload
	# désinstallation diverses des relicats de xfce et de thunderbird ajouté par maté
	sudo apt-get -y purge thunderbird transmission-gtk thunar leafpad hexchat geany k3b brasero cheese
	sudo apt-get -y remove --purge  libreoffice-*
    sudo apt-get -y install chromium-browser
    sudo dpkg --configure -a
    sudo apt-get install -f
    sudo apt-get -y autoremove
    sudo apt-get clean

    if [[ -z "$DESKTOP_SESSION" ]]
    then
	    echo "export DESKTOP_SESSION=\"mate\""  >> ~/.bashrc
    fi


	# mise à jour de tout le système
	# sudo apt-get -q --yes dist-upgrade

fi

if [[ ${o_indicator} == "TRUE" ]]
then
    sudo apt-get ${options} install indicator-cpufreq
    sudo apt-get ${options} install indicator-multiload
    #sudo apt-get ${options} install indicator-sound indicator-power indicator-messages indicator-application indicator-session
    #sudo apt-get ${options} install indicator-bluetooth
fi

sudo apt-get ${options} purge indicator-china-weather
if [[ ${version} == "xenial" ]]
then
    sudo apt-get ${options} purge indicator-network-tools indicator-network-autopilot
fi


# install ip indicator
if [[ ${ip_indicator} == "TRUE" ]]
then
	${dirinstall}/install_ip_indicator.sh
fi

# Installation du fond d'écran
echo "================================================="
echo "================================================="
echo "install Background"
echo "================================================="
echo "================================================="
# set NAFABox wallpaper
mkdir -p ~/bin
backpic="wallpaper.png"
dest="$HOME/bin"
cp ${dirinstall}/${backpic} ${dest}/${backpic}

if [[ ${installMate} == "TRUE" ]]
then
    gsettings set org.mate.background picture-filename ${dest}/${backpic}
elif [[ ${DESKTOP_SESSION} == "mate" ]]
then
    gsettings set org.mate.background picture-filename ${dest}/${backpic}
elif [[ ${DESKTOP_SESSION} == "lxde" ]]
then
    pcmanfm --set-wallpaper="$dest/$backpic"
elif [[ ${DESKTOP_SESSION} == "xfce" ]] || [[ ${DESKTOP_SESSION} == "xubuntu" ]]
then
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-show -s true
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path --set ${dest}/${backpic}
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor1/image-path --set ${dest}/${backpic}
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor2/image-path --set ${dest}/${backpic}
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor3/image-path --set ${dest}/${backpic}
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/workspace0/last-image --set ${dest}/${backpic}
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/workspace1/last-image --set ${dest}/${backpic}
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/workspace2/last-image --set ${dest}/${backpic}
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/workspace3/last-image --set ${dest}/${backpic}
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual1/workspace0/last-image --set ${dest}/${backpic}
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual1/workspace1/last-image --set ${dest}/${backpic}
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual1/workspace2/last-image --set ${dest}/${backpic}
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual1/workspace3/last-image --set ${dest}/${backpic}
    
fi



	


