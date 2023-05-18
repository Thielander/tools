#!/bin/bash  -
#code by Ale-x
#www.ale-x.com
#icq 153228510
#axelskywalker dot googlemail dot com
#  Copyright (c) 2010 by Alexander Thiele
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#
#
##################config#######################
if test -f $HOME/.climm/.icqcontrol ;then touch $HOME/.climm/.icqcontrol ;fi             #Datei anlegen wenn nicht vorhanden
DIR="$HOME/.climm/scripting"                                                             #verzeichnis von micq wo die msg's hingeschickt werden
PASS="$(grep "password" $HOME/.climm/.icqcontrol | awk -F: '{print $2}')"                #Passwort um Befehle zu senden
SCRIPTVERSION="1"                                                                        #aktuelle Scriptversion
UIN="153228510"                                                                          #von welcher UIN werden Befehle akzeptiert
OUTPUT=""                                                                                #no angeben wenn generell ohne output
SEC="1"                                                                                  #Wie oft soll die .log Datei gelesen werden? Standard 1Sekunde
                                                                                         #ist der Wert zu gross koennen Befehle verloren gehen

##############################################
##############################################
clear
function update()
 {
  echo "Suche nach neuer Version...."
  UPDATE=$(lynx -source http://www.ale-x.com/icqcontrol.sh | grep "version" | grep "SCRIPTVERSION=" | awk -F\" '{print $2}')
   if [ "$SCRIPTVERSION" -lt "$UPDATE" ]
    then
        echo "Neue Version verhanden"
        echo "Runterladen? (j)a (n)ein";read answer
         if [ "$answer" = "j" ]
          then
              rm -fr icqcontrol.sh
              wget www.ale-x.com/icqcontrol.sh
              chmod +x icqcontrol.sh
          else
              echo "Dann gibt es eben keine neue Version "
         fi
    else
        echo "Keine neue Version vorhanden"
        echo "Trotzdem neu laden? (j)a (n)ein";read answer
         if [ "$answer" = "j" ]
          then
              rm -fr icqcontrol.sh
              wget www.ale-x.com/icqcontrol.sh
              chmod +x icqcontrol.sh
          else
              echo "Dann eben nicht :P "
         fi
   fi
 exit
}

function install()
{
sudo apt-get install tcl8.4-dev tcl8.3-dev libgnutls-dev libgnutls-dev libiksemel-dev lynx 
}
if [ "$1" = "-u" ]; then update;fi
if [ "$1" = "-install" ]; then install;fi
if [ "$1" = "-no" ];then OUTPUT=no;fi                          #Bei Option -no -> no outout
if [ "$OUTPUT" != "no" ];then
if [ ! -n "$(which climm)" ];then echo "climm nicht gefunden." ;   exit;fi      #climm installiert
if [ ! -n "$(which lynx)" ];then echo "lynx nicht gefunden." ;   exit;fi      #lynx




function banner()
{
echo "
        \|||/
        (o o)
,~~~ooO~~(_)~~~~~~~~~,
| briXtons icqcontrol|
|                    |
|     Version 1      |
|                    |
'~~~~~~~~~~~~~~ooO~~~'
       |__|__|
        || ||
       ooO Ooo
"
}
banner
fi


function help()
{
echo "
NAME
       $0 fuer Climm (Konsolen ICQ)

ÜBERSICHT
       $0 [-h] [-no]  [-u]

BESCHREIBUNG
       $0 ist ein bash script fuer climm, climm  ist  ein  text-basiertes  ICQ-Programm. Es lauft im Hintergrund und kann von
       einer bestimmten UIN Befehle annehmen und ausfuehren und schickt das Ergebnis an die UIN zurueck. Somit ist es 
       moeglich den PC/Server von ueberall wo ICQ vorhanden ist fernzusteuern wie z.B. einem Windows PC, Mac, Linux, Handys usw.

OPTIONEN
       -h              Zeigt einen kurzen Hilfe-Text an und beendet.

       -no             programm laeuft komplett ohne output

       -u              update

       -install        Pakete installieren mit apt-get

INSTALLATION

       benoetigt wird natuerlich climm das gibt es unter www.climm.org
       folgende Pakete sollten installiert sein
       tcl8.4-dev tcl8.3-dev libgnutls-dev libgnutls-dev libiksemel-dev lynx climm
       Climm downloaden, entpacken und mit ./configure && make && make install installieren.
       Sollte in der Regel klappen. 
       In diesm Script muesst ihr eure Icq Nummer angeben. Fuer das Script wird eine zweite Icq
       Nummer benoetigt. Ihr registriert euch also eine zweite nummer und geht mit Climm und dieser
       Nummer auf dem Rechner den ihr steuern wollt online. Dann startet ihr icqcontrol. Entweder in einen eigenem
       Terminal oder im Hintergrund mit icqcontrol.sh -no. 
       Bei ersten start solltet ihr das aber so ausfuehren weil ein passwort angelegt wird.
       Das wars eigentlich. Jetzt koennt ihr von eurer normal Icq Nummer Nachrichten an die neue Nummer schicken.
       Dies wird aber nicht einfach gehen zuerst muesst ihr euch einloggen indem ihr folgenden Befehl per Icq sendet
      
       Login              -> cmd:Login passwort
       Logout             -> cmd:Logout
       icqcontrol beenden -> cmd:exit
       Befehle senden     -> cmd:uname-a   ->cmd:pwd    

       Info: Befehle mit sonderzeichen werden noch nicht unterstuetzt also cmd:echo \"test\" geht nicht
             Befehle mit mehrzeiligen Ergebnissen gehen auch noch nicht
             




              
"
}

function deleteuinlog ()                    #inhalt log datei loeschen
{
  echo "" >$HOME/.climm/history/$UIN.log
}

function login() 
{
 if [ "$(echo $2 | md5sum)" =  "$PASS" ];then touch .LOCK;echo "msg $UIN erfolgreich angemeldet" >$DIR;else echo "msg $UIN Login falsch" >$DIR;fi
}

function passwortanlegen()
{
 echo "Gebe hier ein Passwort ein";stty -echo;read password
 echo "password:$(echo $password | md5sum)" >$HOME/.climm/.icqcontrol
# echo "password:$(echo $password)" >$HOME/.climm/.icqcontrol
 clear
}
 
function main()
{
 if [ "$PASS" = "" ];then passwortanlegen ;fi
  while sleep $SEC  
   do
     cmd=$(tail -n1 $HOME/.climm/history/$UIN.log | grep "cmd:" | awk -Fcmd: '{print $2}' ) #befehl aus der log datei lesen
     deleteuinlog
      if [ "$cmd" = "exit" ];then  break;fi           #bei befehl exit programm schliessen
      if [ "$cmd" = "Logout" ];then  cmd="";rm -fr .LOCK;echo "msg $UIN Logout erfolgreich" >$DIR;fi          
      if [ "$cmd" != "" ] 
       then
           if test -f .LOCK ;then                       
            echo "msg $UIN $($cmd)" >$DIR           #NAchricht an uin schicken
            deleteuinlog
           elif  [ "$(echo $cmd | grep Login)" != "" ];then  login  $cmd
           else  echo "msg $UIN Login fehlt" >$DIR
           fi
     fi
  done
}
if [ "$1" = "-h" ] 
then help
else main
fi
exit
