# NAFABox (Nomad Astronomy For All)

Script d'installation pour créer une NAFABox.

Ces scripts sont compatibles avec les systèmes classiques amd64/x86_64 (Ubuntu).   
Les scripts ont été testés avec Ubuntu Bionic (18.04 LTS) et Ubuntu Focal (20.04 LTS).  
Il est recommandé d'utiliser **Ubuntu Focal (20.04 LTS)**.

Il est nécessaire de disposer d'au moins 10Go d'espace de stockage (index d'astrométrie non compris)  

**ATTENTION :** Vérifiez que les mises à jour automatiques sont désactivées afin qu'elles n'interfèrent pas avec les scripts.


### Pour les systèmes X86_64/Amd64 Ubuntu Linux system :

1/ Pour une installation par USB, utilisez Etcher.

**Ubuntu Mate** Focal (20.04 LTS) --> conseillé 
http://cdimage.ubuntu.com/ubuntu-mate/releases/20.04/release/ubuntu-mate-20.04.3-desktop-amd64.iso   
ou **Xubuntu** Focal (20.04 LTS):   
http://cdimage.ubuntu.com/xubuntu/releases/20.04/release/xubuntu-20.04.3-desktop-amd64.iso   
ou **Lubuntu** Focal (20.04 LTS) (Pas testé):  
http://cdimage.ubuntu.com/lubuntu/releases/20.04/release/lubuntu-20.04.3-desktop-amd64.iso   
ou **Ubuntu** Focal (20.04 LTS) (Pas testé):  
https://releases.ubuntu.com/20.04.3/ubuntu-20.04.3-desktop-amd64.iso 
ou **Kubuntu** Focal (20.04 LTS) (Pas testé):  
http://cdimage.ubuntu.com/kubuntu/releases/20.04/release/kubuntu-20.04.3-desktop-amd64.iso   
ou **Ubuntu-Budgie** Focal (20.04 LTS) (Pas testé):  
http://cdimage.ubuntu.com/ubuntu-budgie/releases/20.04/release/ubuntu-budgie-20.04.3-desktop-amd64.iso   


Puis démarrez sur l'image disque et suivez la procédure d'installation standard.


2/ Téléchargez :  https://github.com/Patrick-81/NAFABox/archive/master.zip  
ou  
2bis/ Dans votre répertoire home : `git clone https://github.com/Patrick-81/NAFABox.git`

3/ Décompressez le fichier zip ( juste pour 2/)

4/ Ouvrez le dossier ainsi créé

5/ Lancez **Pre_Install.sh** dans un terminal (avec un clic droit dans le dossier)

`$ ./Pre_Install.sh` 

Vous pouvez choisir d'installer la langue française et le clavier français si ce n'est pas déjà fait.

6/ Une fois le script __Pre_Install__ fini, fermez le terminal puis redémarrez.

__Si vous avez modifié la langue,__ le système va vous proposer de renommer les dossiers utilisateur. Acceptez puis redémarrez. Après le redémarrage, il faut supprimer l'ancien dossier correspondant au bureau (par exemple, supprimez le dossier __Desktop__ si vous passez de l'anglais au français).    
__Attention__ Ne pas supprimer le dossier __Desktop__ si c'est le seul présent.

Ouvrez un nouveau terminal.

Lancez une mise a jour :   
`$ sudo apt update`    
`$ sudo apt upgrade -y`    
Redémarrez

Ouvrez un nouveau terminal.    
Lancez __Install.sh__   

`$ ./Install.sh` 

7/ Répondez aux questions lorsque vous y êtes invité et entrez votre mot de passe quand c'est demandé. Remplissez les menus si nécessaire.

8/ Quand tout est fini, vous pouvez redémarrer.


### Documentation pour le mappage persistant pour les périphériques série/usb (en anglais):      
https://indilib.org/support/tutorials/157-persistent-serial-port-mapping.html
