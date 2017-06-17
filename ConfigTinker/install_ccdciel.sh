################################################
# Under GPL license
#     https://www.gnu.org/licenses/gpl.html
# Authors:	Patrick Dutoit
# 			Laurent Roge
# On June 10 2017
# V0.1
################################################
#!/bin/bash
######
# Installation des pré-requis
######
$(pwd)/install_libpasastro.sh
######
# détection de l'architecture
######
source $(pwd)/proctype.sh
######
# Installation du programme : ccdciel
######
software="ccdciel"
version="ccdciel_0.8.14"
file="ccdciel_0.8.14-382$proc.deb"
wget https://sourceforge.net/projects/$software/files/$version/$file -P /tmp/
sudo dpkg -i /tmp/$file
######
# Création de l'icône sur le bureau
######
$(pwd)/install_shortcut.sh ccdciel

