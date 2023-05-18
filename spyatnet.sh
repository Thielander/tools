#!/usr/bin/bash
#  code by Alexander Thiele
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
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA#
#
clear
#####dont change####
version=1.1
###################
echo "
        \|||/
        (o o)
,~~~ooO~~(_)~~~~~~~~~,
|                    |
|    Web Scanner     |
|    Version $version     |
'~~~~~~~~~~~~~~ooO~~~'
       |__|__|
        || ||
       ooO Ooo
"
#################root? for nmap##########################################################################################
if (( $UID )); then
	echo "you need root!" 
	exit
fi
################Softwarecheck?###########################################################################################
software_installed=(nmap curl wget lynx bc ncftpput) #ncftpput just for ftp upload
for i in ${software_installed[@]}; do
	if [ "$(which $i)" = "" ];
        	then 
                	echo "$i not found"
	fi
done
#################default#################################################################################################
wget_timeout=5
listfile="/tmp/online.nmap" 
listfile_rc="/tmp/.online.nmap" 
output="/tmp/outputfile"
htmldir="/tmp/"
htmlfile="all.html"
lstfile="/tmp/scanning.lst"
xmlfile="/var/www/html/all.xml"
cachefile="/tmp/cache"
localwebserver="/var/www/html/"	#path local webserver
##############ftpupload########
ftpuser=""
ftppass=""
ftpurl=""
ftpdir="/"
###create files or overwrite###
echo "" >$output
echo "" >$htmldir$htmlfile
echo "" >$cachefile
echo "" >$listfile
echo "" >$listfile_rc
echo "" >$lstfile
#################Webserver check###########
if [ -d $localwebserver ]; then 			#Wenn Verzeichnis vorhanden
	echo "spyat.test">spyat.html			#Datei mit Inhalt erstellen
	sudo mv spyat.html $localwebserver		#Datei verschieben
	localtest=$(lynx -source localhost/spyat.html)	#Datei über localhost aufrufen
	rm  $localwebserver/spyat.html			#Datei wieder löschen

	if [ $localtest != "spyat.test" ];		#Inhaltscheck
		then
			echo "Webserver konnte nicht aufgerufen werden"
			echo "Entweder ist kein Webserver installiert, oder das Verzeichnis in den Einstellungen stimmt nicht."
			echo "Wenn du kein Webserver nutzen willst gib dort /tmp/ ein"
			exit
	fi

else
echo "Webserverpfad passt nicht, bitte passe die Einstellungen an"
exit
fi


#################message#########################

trap abbruch SIGINT #wird das script mit strg + c abgebrochen dann function abbruch aufrufen

function abbruch {
	clear
	echo "ctrl + c"
	echo "Delete all files"
	rm $listfile
	rm $lstfile
	rm $xmlfile
	rm $listfile_rc
	rm $output
	rm $cachefile
 	exit 0
}

usage()
{
	echo "
spyatnet.sh [-o <html|list|xml>]                                   -> output
 	    [-h]                                                   -> this help 
 	    [-c <ip>]                                              -> curl -L  -k -S <ip> 
 	    [-u]                                                   -> udate check 
 	    [-i]                                                   -> show youronline ip
 	    [-n <networkrange>]  	         	           -> scanning

	    Example:
	    sudo spyatnet.sh  -n 192.168.178-179         	( scan 192.168.178.0 - 192.168.178.255 )
	    sudo spyatnet.sh  -o html -n 192.168.178-179           ( scan + output in html )
	    " 1>&2
 	    exit 1;
}

delout()
 {
   	rm $output
 }

scan()
 {
   if (($OUT == "xml" ))
    then
        echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
<result>">$xmlfile
   fi 
  if (($OUT == "html" ))
   then
    echo "<style type=\"text/css\">
.tg  {border-collapse:collapse;border-spacing:0;}
.tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
  overflow:hidden;padding:10px 5px;word-break:normal;}
.tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
  font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
.tg .tg-42jv{background-color:#32cb00;border-color:#000000;color:#000000;text-align:left;vertical-align:top}
.tg .tg-4yyz{background-color:#32cb00;border-color:#000000;color:#333333;text-align:left;vertical-align:top}
.tg .tg-69ho{background-color:#32cb00;border-color:#000000;color:#330001;text-align:left;vertical-align:top}
.tg .tg-0lax{text-align:left;vertical-align:top}
</style>
<table class=\"tg\">
<thead>
  <tr>
    <th class=\"tg-69ho\">ip</th>
    <th class=\"tg-42jv\">result</th>
    <th class=\"tg-4yyz\">link</th>
  </tr>
</thead>
<tbody>">>$htmldir$htmlfile
fi

  ipanet=$(echo $1 | cut -d"-" -f1 | cut -d"." -f1)
  ipbnet=$(echo $1 | cut -d"-" -f1 | cut -d"." -f2)
  rangefrom=$(echo $1 | cut -d"-" -f1 | cut -d"." -f3)
  rangeto=$(echo $1 | cut -d"-" -f2)
   if !(($ipanet < 256)) 2>/dev/null; then  echo "$ipanet wrong integer";exit;fi
   if !(($ipbnet < 256)) 2>/dev/null; then  echo "$ipbnet wrong integer";exit;fi
   if !(($rangefrom < 256)) 2>/dev/null; then  echo "$rangefrom wrong integer";exit;fi
   if !(($rangeto < 256)) 2>/dev/null; then  echo "$rangeto wrong integer";exit;fi
   if !(($rangeto > $rangefrom)) 2>/dev/null #swap variable 
    then  
        temp=$rangefrom
        rangefrom=$rangeto 
        rangeto=$temp 
   fi


echo "[SCAN $ipanet.$ipbnet.$rangefrom.0 - $ipanet.$ipbnet.$rangeto.255] "

   	for i in  `seq $rangefrom $rangeto`
      		do

         		printf "[SCAN $ipanet.$ipbnet.$i.0/24] "
         		sudo nmap -sS -PN -P0 -n -p80 -oG - $ipanet.$ipbnet.$i.0/24  -T5 | awk '/open/ {print $2}' >$listfile_rc  #Ergebnisse in die Datei .$listfile speichern
         		LINES=$(wc -l $listfile_rc  | awk '{print $1}') #Wie  viele Zeilen sind in .$listfile
         		printf "[FOUND $LINES IPs]\n"  #Ausgabe Anzahl Zeilen
         		cat $listfile_rc | sort | uniq >>$listfile #Datei  .$listfile lesen und in $listfile speichern
      		done
 
	LINESALL=$(cat $listfile | sort | uniq | wc -l | awk '{print $1}') #Wie  viele Zeilen sind in .$listfile
 	echo "CHECK $LINESALL HOSTS"
	cat $listfile | while read line #jede Zeile einlesen von $listfile
 		do   #do start
   			lock=""
   			if [ "$line" != "" ];then
        ##########curl or wget?###################
	curl -L -k -s --max-time 2.5 $line >$output
       	#wget $line  -o $cachefile -O $output --timeout=$wget_timeout --tries=1
       if [ "$(grep "HomeMatic" $output)" !=  "" ];then echo "$line ->  HomeMatic WebUI ";delout;info="HomeMatic WebUI";lock=1;html
       elif [ "$(grep "LANCOM" $output)" !=  "" ];then echo "$line -> Lancom Router ";delout;lock=1;info="Lancom Router";html
       elif [ "$(grep "HL-3142CW" $output)" !=  "" ];then echo "$line -> Brother HL-3142CW series ";delout;lock=1;info="Brother HL-3142CW series";html
       elif [ "$(grep "Kerio Connect WebMail" $output)" !=  "" ];then echo "$line -> Kerio Connect WebMail";delout;lock=1;info="Kerio Connect WebMail";html
       elif [ "$(grep "NethServer" $output)" !=  "" ];then echo "$line -> NethServer";delout;lock=1;info="NethServer";html
       elif [ "$(grep "Brother MFC-J470DW" $output)" !=  "" ];then echo "$line -> Brother MFC-J470DW";delout;lock=1;info="Brother MFC-J470DW";html
       elif [ "$(grep "SolarLog" $output)" !=  "" ];then echo "$line -> SolarLog";delout;lock=1;info="Solar-Log";html
       elif [ "$(grep "/sws/images/fav.ico" $output)" !=  "" ];then echo "$line -> SyncThru Webservice (Samsung) ";delout;lock=1;info="SyncThru Webservice (Samsung)";html
       elif [ "$(grep "ShareCenter" $output)" !=  "" ];then echo "$line -> ShareCenter (default user:admin)";delout;lock=1;info="ShareCenter (default user:admin)";html
       elif [ "$(grep "Foscam" $output)" !=  "" ];then echo "$line -> Foscam IP Camera (default user:admin)";delout;lock=1;info="Foscam IP Camera (default user:admin)";html
       elif [ "$(grep "DS1019plus" $output)" !=  "" ];then echo "$line -> Synology DS1019plus";delout;lock=1;info="Synology DS1019plus";html
       elif [ "$(grep "Nextcloud" $output)" !=  "" ];then echo "$line -> Nextcloud";delout;lock=1;info="Nextcloud";html
       elif [ "$(grep "Smart-Heat-OS" $output)" !=  "" ];then echo "$line -> Smart-Heat-OS";delout;lock=1;info="Smart-Heat-OS";html
       elif [ "$(grep "STIEBEL ELTRON" $output)" !=  "" ];then echo "$line ->  STIEBEL ELTRON";delout;lock=1;info="STIEBEL ELTRON";html
       elif [ "$(grep "Varta Storage" $output)" !=  "" ];then echo "$line ->  Varta Storage";delout;lock=1;info=" Varta Storage";html
       elif [ "$(grep "/view/viewer_index.shtml?id=" $output)" !=  "" ];then echo "$line -> Webcam?";delout;lock=1;info="Webcam ?";html
       elif [ "$(grep "doc/page/login.asp" $output)" !=  "" ];then echo "$line -> Abus - ©Hikvision Digital Technology ";delout;lock=1;info="Abus - ©Hikvision Digital Technology";html
       elif [ "$(grep "RESOL" $output)" !=  "" ];then echo "$line -> RESOL (admin:admin) ";delout;lock=1;info="RESOL (admin:admin)";html
       elif [ "$(grep "/dlx/home" $output)" !=  "" ];then echo "$line -> RESOL? (admin:admin)";delout;lock=1;info="Resol ? (admin:admin)";html
       elif [ "$(grep "nginx" $output)" !=  "" ];then echo "$line -> nginx default page ";delout;lock=1;info="nginx default page";html
       elif [ "$(grep "Zarafa" $output)" !=  "" ];then echo "$line -> Zarafa WebAccess ";delout;lock=1;info="Zarafa WebAccess";html
       elif [ "$(grep "GIRA" $output)" !=  "" ];then echo "$line -> GIRA Product";delout;lock=1;info="GIRA Product";html
       elif [ "$(grep "Hecstar db page" $output)" !=  "" ];then echo "$line -> Hecstar db page";delout;lock=1;info="Hecstar db page";html
       elif [ "$(grep "DS7700 WEB-Interface" $output)" !=  "" ];then echo "$line -> DS7700 WEB-Interface";delout;lock=1;info="DS7700 WEB-Interface";html
       elif [ "$(grep "Vilar IPCamera Login" $output)" !=  "" ];then echo "$line -> Vilar IPCamera Login ";delout;lock=1;info="Vilar IPCamera Login";html
       elif [ "$(grep "DVR Components Download" $output)" !=  "" ];then echo "$line -> DVR Components Download ";delout;lock=1;info="DVR Components Download";html
       elif [ "$(grep "Brother MFC-J5320DW" $output)" !=  "" ];then echo "$line -> Brother MFC-J5320DW ";delout;lock=1;info="Brother MFC-J5320DW";html
       elif [ "$(grep "QNAP Turbo NAS" $output)" !=  "" ];then echo "$line -> QNAP Turbo NAS (admin:admin) ";delout;lock=1;info="QNAP Turbo NAS (admin:admin)";html
       elif [ "$(grep "403 Forbidden" $output)" !=  "" ];then echo "$line -> 403 Forbidden ";delout;lock=1;info="403 Forbidden";html
       elif [ "$(grep "503 Service Unavailable" $output)" !=  "" ];then echo "$line -> 503 Service Unavailable";delout;lock=1;info="503 Service Unavailable";html
       elif [ "$(grep "Web Application Manager" $output)" !=  "" ];then echo "$line -> Web Application Manager ";delout;lock=1;info="Web Application Manager";html
       elif [ "$(grep "Loxone Smart Home" $output)" !=  "" ];then echo "$line -> Loxone Smart Home (default user:admin password:admin) ";delout;lock=1;info="Loxone Smart Home (admin:admin)";html
       elif [ "$(grep "Loxone" $output)" !=  "" ];then echo "$line -> Loxone Product";delout;lock=1;info="Loxone Product";html
       elif [ "$(grep "FRITZ!Box" $output)" !=  "" ];then echo "$line -> FRITZ!Box ";delout;lock=1;info="FRITZ!Box";html
       elif [ "$(grep "EHEIM" $output)" !=  "" ];then echo "$line -> EHEIM digital";delout;lock=1;info="EHEIM digital";html
       elif [ "$(grep "Minecraft Overviewer" $output)" !=  "" ];then echo "$line -> Minecraft Overviewer";delout;lock=1;info="Minecraft Overviewer";html
       elif [ "$(grep "Synology" $output)" !=  "" ];then echo "$line -> Synology ";delout;lock=1;info="Synology";html
       elif [ "$(grep "Axentra Server" $output)" !=  "" ];then echo "$line -> Axentra Server ";delout;lock=1;info="Axentra Server";html
       elif [ "$(grep "Please be patient as you are being re-directed to" $output)" !=  "" ];then echo "$line -> SonicWall Network Security Login ";delout;lock=1;info="SonicWall Network Security Login";html
       elif [ "$(grep "SonicWALL" $output)" !=  "" ];then echo "$line -> SonicWALL ";delout;lock=1;info="SonicWALL";html
       elif [ "$(grep "Neige-Netzwerkkamera" $output)" !=  "" ];then echo "$line -> Schwenk-Neige-Netzwerkkamera ";delout;lock=1;info="Schwenk-Neige-Netzwerkkamera";html
       elif [ "$(grep "Web Server Setup Guide" $output)" !=  "" ];then echo "$line -> Web Server Setup Guide";delout;lock=1;info="Web Server Setup Guide";html
       elif [ "$(grep "LanMpegView0.htm" $output)" !=  "" ];then echo "$line -> Cam Guard";delout;lock=1;info="Cam Guard";html
       elif [ "$(grep "aspx?gotodefault=true" $output)" !=  "" ];then echo "$line -> Windows Home Server?";delout;lock=1;info="Windows Home Server?";html
       elif [ "$(grep "rpAuth.html" $output)" !=  "" ];then echo "$line -> Zyxel ";delout;lock=1;info="Zyxel ";html
       elif [ "$(grep "Bootloader-NET" $output)" !=  "" ];then echo "$line -> Anlage mit Bootloader-NET";delout;lock=1;info="Anlage mit Bootloader-NET";html
       elif [ "$(grep "www.ta.co.at" $output)" !=  "" ];then echo "$line -> Anlage mit Bootloader-NET";delout;lock=1;info="Anlage mit Bootloader-NET";html
       elif [ "$(grep "belkin" $output)" !=  "" ];then echo "$line -> Belkin Router ";delout;lock=1;info="Belkin Router";html
       elif [ "$(grep "pihole" $output)" !=  "" ];then echo "$line -> pihole ";delout;lock=1;info="pihole";html
       elif [ "$(grep "TP-LINK" $output)" !=  "" ];then echo "$line -> TP-LINK Technologies ";delout;lock=1;info="TP-LINK Technologies";html
       elif [ "$(grep "DiskStation" $output)" !=  "" ];then echo "$line -> DiskStation ";delout;lock=1;info="DiskStation";html
       elif [ "$(grep "RomPager" $output)" !=  "" ];then echo "$line -> RomPager Server ";delout;lock=1;info="RomPager Server";html
       elif [ "$(grep "mobotix" $output)" !=  "" ];then echo "$line -> Mobotix Webcam -";delout;lock=1;info="Mobotix Webcam";html
       elif [ "$(grep "Netzwerkkonfigurations-Assistent" $output)" !=  "" ];then echo "$line -> Windows Small Buisness Server";delout;lock=1;info="Windows Small Buisness Server";html
       elif [ "$(grep "TechniSat" $output)" !=  "" ];then echo "$line -> TechniSat Webserver(Receiver?)";delout;lock=1;info="Technisat Webserver (Receiver?)";html
       elif [ "$(grep "pressum" $output)" !=  "" ];then echo "$line -> Normale Homepage ";delout;lock=1;info="Normale Homepage";html
       elif [ "$(grep "rcube_webmail" $output)" !=  "" ];then echo "$line -> Round Cube Webmail ";delout;lock=1;info="Round Cube Mail";html
       elif [ "$(grep "Vertriebsportal" $output)" !=  "" ];then echo "$line -> SAG Vertriebsportal";delout;lock=1;info="SAG Vertriebsportal";html
       elif [ "$(grep "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz012345678" $output)" !=  "" ];then echo "$line -> Pragma Standard Login";delout;lock=1;info="Pragma Standard Login";html
       elif [ "$(grep "QNAP" $output)" !=  "" ];then echo "$line -> QNAP Web Server Settings ";delout;lock=1;info="QNAP Web Server";html
       elif [ "$(grep "Detachering" $output)" !=  "" ];then echo "$line -> Alko Detachering Webmail - Login";delout;lock=1;info="Alko Detachering Webmail";html
       elif [ "$(grep "mailscope" $output)" !=  "" ];then echo "$line -> mailscope";delout;lock=1;info="mailscope";html
       elif [ "$(grep "FileVault" $output)" !=  "" ];then echo "$line -> iomega FileVault";delout;lock=1;info="iomega FileVault";html
       elif [ "$(grep "Redirecting to <a href=\"/cgi-bin/home" $output)" !=  "" ];then echo "$line -> TV Box Webinterface ";delout;lock=1;info="TV Box Webinterface";html
       elif [ "$(grep "TeamViewer" $output)" !=  "" ];then echo "$line -> Running Teamviewer";delout;lock=1;info="Running Teamviewer";html
       elif [ "$(grep "splashDefault-l-logo.jpg" $output)" !=  "" ];then echo "$line -> Blue Quartz Placeholder";delout;lock=1;info="Blue Quartz Placeholder";html
       elif [ "$(grep "status.asp" $output)" !=  "" ];then echo "$line -> Acer Router";acer $line;delout;lock=1;info="Acer Router";html
       elif [ "$(grep "IP300PTR" $output)" !=  "" ];then echo "$line -> IP Camera";delout;lock=1;info="IP Camera";html
       elif [ "$(grep "Hewlett-Packard Development" $output)" !=  "" ];then echo "$line -> Hewlett-Packard Development";delout;lock=1;info="Hewlett-Packard";html
       elif [ "$(grep "Willkommen" $output | grep "Welcome")" !=  "" ];then echo "$line -> Welcome Page";delout;lock=1;info="Welcome Page";html
       elif [ "$(grep "Tobit" $output)" !=  "" ];then echo "$line -> Welcome Page";delout;lock=1;info="Welcome Page";html
       elif [ "$(grep "Konfigurationsprogramm starten" $output)" !=  "" ];then echo "$line -> Telekom Router Speedport";delout;lock=1;info="Telekom Router";html
       elif [ "$(grep "WG-602" $output)" !=  "" ];then echo "$line -> Handlink WG-602";delout;lock=1;info="Handlink WG-602";html
       elif [ "$(grep "XAMPP" $output)" !=  "" ];then echo "$line -> XAMPP";delout;lock=1;info="XAMMP";html
       elif [ "$(grep "eMule" $output)" !=  "" ];then echo "$line -> eMule Webinterface";delout;lock=1;info="eMule Webinterface";html
       elif [ "$(grep "server-ams" $output)" !=  "" ];then echo "$line -> server-ams";delout;lock=1;info="server-ams";html
       elif [ "$(grep "Internetinformationsdienste" $output)" !=  "" ];then echo "$line -> Leere Seite";delout;lock=1;info="Leere Seite";html
       elif [ "$(grep "Placeholder" $output)" !=  "" ];then echo "$line -> Placeholder Page";delout;lock=1;info="Placeholder Page";html
       elif [ "$(grep "window.location=\"cgi-bin/webmng.cgi?next_file=login.htm" $output)" !=  "" ];then echo "$line -> Peer TV Web -Management";delout;lock=1;info="Peer TV Web";html
       elif [ "$(grep "Enigma" $output)" !=  "" ];then echo "$line -> Enigma Webinterface (DBOX)";delout;lock=1;info="Enigma Webinterface";html
       elif [ "$(grep "yWeb" $output)" !=  "" ];then echo "$line -> yWeb (DBOX)";delout;lock=1;info="yWeb->DBOX";html
       elif [ "$(grep "IServ" $output)" !=  "" ];then echo "$line -> IServ Weboberflaeche";delout;lock=1;info="IServ";html
       elif [ "$(grep "BMR" $output)" !=  "" ];then echo "$line -> BMR Webserver";delout;lock=1;info="BMR Webserver";html
       elif [ "$(grep "MSNTV" $output)" !=  "" ];then echo "$line -> MSNTV";delout;lock=1;info="MSNTV";html
       elif [ "$(grep "Bosch" $output)" !=  "" ];then echo "$line -> Bosch 1ch DVR?";delout;lock=1;info="Bosch 1ch BVR?";html
       elif [ "$(grep "IIS7" $output)" !=  "" ];then echo "$line -> IIS7 Internet Information Service";delout;lock=1;info="IIS7 Internet Information Service";html
       elif [ "$(grep "IIS Windows Server" $output)" !=  "" ];then echo "$line -> IIS Windows Server";delout;lock=1;info="IIS Windows Server";html
       elif [ "$(grep "WRT54G" $output)" !=  "" ];then echo "$line -> Linksys WRT54G";delout;lock=1;info="Linksys WRT54G";html
       elif [ "$(grep "Linksys_Blue.gif" $output)" !=  "" ];then echo "$line -> Linksys Storage System";delout;lock=1;info="Linksys Storage System";html
       elif [ "$(grep "Connectivity" $output)" !=  "" ];then echo "$line -> Connectivity Server";delout;lock=1;info="Connectivity Server";html
       elif [ "$(grep "WL700gE" $output)" !=  "" ];then echo "$line -> WL700gE Configuration";delout;lock=1;info="WL700gE Configurstion";html
       elif [ "$(grep "dmicros.com" $output)" !=  "" ];then echo "$line -> Dedicated Micros EcoSense";delout;lock=1;info="Dedicated Micros EcoSense";html
       elif [ "$(grep "LaserJet" $output)" !=  "" ];then echo "$line -> HP Laserjet Drucker";delout;lock=1;info="HP Laserjet Drucker";html
       elif [ "$(grep "Index of" $output)" !=  "" ];then echo "$line -> Index of (event. Dateien gefunden)";delout;lock=1;info="Index of(event. Dateien gefunden=";html
       elif [ "$(grep "Grandstream" $output)" !=  "" ];then echo "$line -> Grandstream Device Configuration";delout;lock=1;info="Grandstream Device Configuration";html
       elif [ "$(grep "Prestige" $output)" !=  "" ];then echo "$line -> Prestige Login";delout;lock=1;info="Prestige Login";html
       elif [ "$(grep "ZyXEL" $output)" !=  "" ];then echo "$line -> ZyXEL ZyWALL Series";delout;lock=1;info="ZyXEL ZyWALL Series";html
       elif [ "$(grep "Teledat" $output)" !=  "" ];then echo "$line -> Teledat Router";delout;lock=1;info="Teledat Router";html
       elif [ "$(grep "Dreambox" $output)" !=  "" ];then echo "$line -> Dreambox Webcontrol";delout;lock=1;info="Dreambox Webcontrol";html
       elif [ "$(grep "works!" $output)" !=  "" ];then echo "$line -> Apache IT works Seite";delout;lock=1;info="Apache IT works Seite";html
       elif [ "$(grep "Joomla" $output)" !=  "" ];then echo "$line -> Joomla Seite";delout;lock=1;info="Joomla Seite";html
       elif [ "$(grep "www.a-link.com" $output)" !=  "" ];then echo "$line -> A-Link Login Screen";delout;lock=1;info="A-Link Login Screen";html
       elif [ "$(grep "Construction" $output)" !=  "" ];then echo "$line -> Under Construction";delout;lock=1;info="Under Construction";html
       elif [ "$(grep "GIPZ" $output)" !=  "" ];then echo "$line -> GIPZ Network System";delout;lock=1;info="GIPZ Network System";html
       elif [ "$(grep "idesk" $output)" !=  "" ];then echo "$line -> idesk IServ";delout;lock=1;info="idesk IServ";html
       elif [ "$(grep "IBM HTTP Server" $output)" !=  "" ];then echo "$line -> IBM HTTP Server";delout;lock=1;info="IBM HTTP Server";html
       elif [ "$(grep "Sunny WebBox" $output)" !=  "" ];then echo "$line -> Sunny WebBox, Standard PW->sma";delout;lock=1;info="Sunny WebBox,Standard PW->sma";html
       elif [ "$(grep "SMA Energy Meter" $output)" !=  "" ];then echo "$line -> SMA Energy Meter";delout;lock=1;info="SMA Energy Meter";html
       elif [ "$(grep "DVR MPEG4 ActiveX" $output)" !=  "" ];then echo "$line -> DVR MPEG4 ActiveX";delout;lock=1;info="DVR MPEG4 ActiveX";html
       elif [ "$(grep "Funkwerk" $output)" !=  "" ];then echo "$line -> Funkwerk Gateway";delout;lock=1;info="Funkwerk Gateway";html
       elif [ "$(grep "nst4TWN.exe" $output)" !=  "" ];then echo "$line -> DVR Viewer";delout;lock=1;info="DVR Viewer";html
       elif [ "$(grep "MattiSyno4x500" $output)" !=  "" ];then echo "$line -> Synology Cube Station - MattiSyno4x500";delout;lock=1;info="Synology Cube Station - MattiSyno4x500";html
       elif [ "$(grep "tcpip.ssi" $output)" !=  "" ];then echo "$line ->  RAINOTRONIK    ";delout;lock=1;info="RAINOTRONIK";html
       elif [ "$(grep "phpinfo" $output)" !=  "" ];then echo "$line ->  phpinfo()    ";delout;lock=1;info="phpinfo()";html
       elif [ "$(grep "window.location" $output)" !=  "" ];then echo "$line -> Weiterleitung ->";delout;lock=1;info="Weiterleitung ->";html
       elif [ "$(grep "location.href" $output)" !=  "" ];then echo "$line -> Weiterleitung -> location.href";delout;lock=1;info="Weiterleitung -> location.href";html
       elif [ "$(grep "innovaphone" $output)" !=  "" ];then echo "$line ->  innovaphone";delout;lock=1;info="innovaphone";html
       elif [ "$(grep "Document Moved" $output)" !=  "" ];then echo "$line ->  Document Moved  ";delout;lock=1;info="Document Moved";html
       elif [ "$(grep "HTTP Error 404" $output)" !=  "" ];then echo "$line -> HTTP Error 404";delout;lock=1;info=">HTTP Error 404";html
       elif [ "$(grep "404 Not Found" $output)" !=  "" ];then echo "$line -> 404 Not Found";delout;lock=1;info=">404 Not Found";html
       else
	#titlecheck=$(curl -L  -k -s --max-time 2.5 $line | grep "<title>" | awk -F\> '{print $2}' | awk -F\< '{print $1}')
	titlecheck=$(grep "<title>" $output | awk -F\> '{print $2}' | awk -F\< '{print $1}')

if [ -z "${titlecheck}" ]; then
		echo "$line -> not recognized";info="not recognized";html
else
		echo "$line -> not recognized -> title = $titlecheck";info="not recognized -> title = $titlecheck";html

fi
       lock=""
       delout
       fi
 fi
  done #do End

	echo " "
        echo "Delete $listfile $listfile_rc $output $cachefile"
        rm $listfile
        rm $listfile_rc
        rm $cachefile
echo " "


if [ "$OUT" = "xml" ]
 then
     echo "</result>">>$xmlfile
     echo "$xmlfile saved"
fi 

if [ "$OUT" = "list" ]
 then
     echo "$lstfile saved"
fi 

if [ "$OUT" = "html" ];then 
	result=$(head $htmldir$htmlfile)
	if [ "$result" == "" ]
	 then
	     echo "<h1>no results</h1>">>$htmldir$htmlfile
	 else
	     echo "</tbody></table><p><a href=\"https://www.spyat.net\" target=\"_blank\" >Website</a>">>$htmldir$htmlfile
	fi
	mv $htmldir$htmlfile $localwebserver
	echo "Move $htmldir$htmlfile to $localwebserver$htmlfile"
	exit
fi
}

html()
 {
   if [ "$OUT" = "html" ];then #create an htmlfile?
    echo "
	<tbody>
  	<tr>
    		<td class="tg-0lax">$line</td>
    		<td class="tg-0lax">$info</td>
    		<td class="tg-0lax"><a href=\"http://$line\" target=\"_blank\">Open in new Tab</a></td>
  	</tr>
	</tbody>" >>$htmldir$htmlfile
   fi
   if [ "$OUT" = "list" ]
    then
	echo "$line:$info">>$lstfile
   fi

   if [ "$OUT" = "xml" ]
    then
echo "<scanning>
    <ip>$line</ip>
    <info>$info</info>
  </scanning>" >>$xmlfile
  fi
 }

update()
 {
newversion=$(lynx -source www.spyat.net/spyatnet.sh | grep "version=" | head -n1 | awk -F\= '{print $2}')
echo "Updatecheck"
echo "This version $version"
echo "New version $newversion"
if (( $(echo "$newversion > $version" |bc -l) )); then
 echo "new version available -> please download -> wget www.spyat.net/spyatnet.sh"
fi
exit
}

onlineip()
 {
  printf "Deine Online IP :"
  curl -s http://whatismijnip.nl |cut -d " " -f 5
  exit
 }

while getopts uic:o:n: options 2>/dev/null
do
  case $options in
    u ) update;;
    i ) onlineip;;
    c ) curl -L  -k -S $OPTARG 
	exit
	;;
    o ) OUT=$OPTARG
        if [ "$OUT" == "html" ]
	 then
	     echo "[html output active]"
	elif [ "$OUT" == "xml" ]
	 then
	     echo "[xml output active]"
	elif [ "$OUT" == "list" ]
	 then
	     echo "[list output active]"
	else
	     echo "wrong parameter ->$OUT"
	usage
	exit
	fi
	;;
    n ) arg=$OPTARG
        scan $OPTARG
	;;
    h ) usage;exit 0;;
   '?' ) echo "bad getopts-option $1"
	 usage
         exit 1
         ;;
  esac
done
shift $((OPTIND-1))
