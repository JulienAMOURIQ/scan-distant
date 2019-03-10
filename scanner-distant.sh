#!/bin/bash


#Choix par défaut
RESOLUTION="300"
MODE="Color"


#-------------------------------------------------
# Taille du fichier de sortie selon la résolution
#-------------------------------------------------
TAILLE75=1676187 
TAILLE100=2981190 
TAILLE200=11924040
TAILLE300=26836440
TAILLE600=107345040
TAILLE1200=429379440 
TAILLE2400=1717517760 


#Cette fonction charge le fichier de configuration et vérifie que tous les paramètres requis sont bien présents
# renvoie le nombre de paramêtres manquants (0 si tout est bon)
. ./numeriser.cfg
chargerconfig(){
	local PRET=0
	
	if [ -z "$UTILISATEUR" ];then
		#echo "'UTILISATEUR' manquant"
		PRET=1
	fi

	if [ -z "$HOTE" ];then
		#echo "'HOTE' manquant"
		let PRET++
	fi
	if [ -z "$FORMAT" ];then
		#echo "'FORMAT' manquant"
		let PRET++
	fi
	if [ -z "$NOM_SORTIE" ];then
		#echo "'NUM_SORTIE' manquant"
		let PRET++
	fi
	echo $PRET
}

res=$(chargerconfig)
if [ $res -ne 0 ] ;then
	echo "ERREUR : fichier numeriser.cfg incomplet"
	echo "Il manque $res paramètre(s) parmi 'UTILISATEUR','HOTE','FORMAT' et 'NUM_SORTIE' dans le fichier numeriser.cfg"
	exit 2
fi

echo $NOM_SORTIE

#MENU 1
if [ "$1" != "-nodialog" ] ; then 
	dialog --menu "Mode ?" 12 50 9 Couleur "scanner en couleurs" Nuances_de_gris "scanner en nuances de gris" 2> /tmp/choix.txt
	if ! [ $? -eq 0 ];then
		clear
		echo "numérisation annulée. essayez '-nodialog'"
		exit 1
	fi
	choix=$(cat /tmp/choix.txt)
	if [ $choix = "Nuances_de_gris" ]; then
		MODE="Gray"
	fi
fi



#MENU 2
if [ "$1" != "-nodialog" ] ; then 
	dialog --menu "Veuillez choisir la résolution:" 12 50 9 75 "brouillon" 100 "guère mieux" 200 "faible résolution" 300 "résolution normale" 600 "haute résolution" 1200 "très haute résolution" 2400 "Meilleur résolution" 2> /tmp/choix.txt
	if ! [ $? -eq 0 ];then
		clear
		echo "numérisation annulée. essayez '-nodialog'"
		exit 1
	fi
	RESOLUTION=$(cat /tmp/choix.txt)
fi



TAILLE=1676187
if [ $RESOLUTION -eq 75 ];then
	TAILLE=$TAILLE75
fi
if [ $RESOLUTION -eq 100 ];then
	TAILLE=$TAILLE100 
fi
if [ $RESOLUTION -eq 200 ];then
	TAILLE=$TAILLE200
fi
if [ $RESOLUTION -eq 300 ];then
	TAILLE=$TAILLE300
fi
if [ $RESOLUTION -eq 600 ];then
	TAILLE=$TAILLE600
fi
if [ $RESOLUTION -eq 1200 ];then
	TAILLE=$TAILLE1200 
fi
if [ $RESOLUTION -eq 2400 ];then
	TAILLE=$TAILLE2400 
fi

if [ "$1" != "-nodialog" ] ; then 
	ssh "$UTILISATEUR@$HOTE" "scanimage --format=$FORMAT --resolution=$RESOLUTION --mode=$MODE" | pv -n -s $TAILLE 2>&1 > "$NOM_SORTIE.$FORMAT"  | dialog --gauge "Numérisation en cours..." 12 50
else
	ssh "$UTILISATEUR@$HOTE" "scanimage --format=$FORMAT --resolution=$RESOLUTION --mode=$MODE" | pv -s $TAILLE 2>&1> "$NOM_SORTIE.$FORMAT"
fi
