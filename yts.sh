#!/bin/bash 
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
#https://www.youtube.com/watch?v=Vvum3C0lp4s
clear
software_installed=(curl) 
for i in ${software_installed[@]}; do
        if [ "$(which $i)" = "" ];
                then 
                        echo "$i not found"
        fi
done
VERSION=1.0
SILENTMODE=OFF
SIGNS=( a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9 )


if [ "$1" = "convert" ]
 then
  if [ "$2" = "" ]
   then
       echo "missing youtube id"
       exit 
 fi

###############convert id -> 0:0:0:0:0:0:0:0:0:0:0 format
#Cp4Rxh1ZqzA
YTID=$2 #youtube id
ID_SIZE=${#YTID} #länge der id
let ID_SIZE=$ID_SIZE-1 #von der länge 1 abziehen für for schleife
for length in `seq 0 $ID_SIZE`  #länge = durchläufe, prüft jedes zeichen an welcher stelle es sich im array befindet
 do
  for convert in `seq 0 61` #array SIGNS durchtesten
   do
     if [ "${YTID:$length:1}" = "${SIGNS[$convert]}" ] #an welcher stelle befindet sich das passende zeichen aus der id
      then
          #printf "[${YTID:$length:1}][${SIGNS[$convert]}][$convert]"
          printf "$convert:" #stelle im array ausgeben
          break
    fi
 done
done
fi


reset()
{
 echo "0:0:0:0:0:0:0:0:0:0:0">/root/ytscan/lastyt
}

if [ -f "lastyt" ]; then
 LAST=$(cat /root/ytscan/lastyt)
else 
 reset
fi

usage()
{
echo "
        \|||/
        (o o)
,~~~ooO~~(_)~~~~~~~~~,
|     spyat.net      |
| simple yt Scanner  |
|    Version $version     |
'~~~~~~~~~~~~~~ooO~~~'
       |__|__|
        || ||
       ooO Ooo
"

 echo "$0 [OPTION]"
 echo ""
 echo "scan 			-> scanning"
 echo "scan sleep 		-> scan with random sleep"
 echo "convert [youtube id] 	-> convert id to 0:0:0:0:0:0:0:0:0:0:0 format"
 echo "reset 			-> reset scanning counter to 0:0:0:0:0:0:0:0:0:0:0"
 echo "test [youtube id] 	-> check youtube id without saving"
 echo "help 			-> this help"
 echo ""
 echo "example:"
 echo "$0 scan"
 echo "$0 scan sleep"
 echo "$0 test a79xoHEesuA -> show title"
}
if [ "$1" = "" ] || [ "$1" == "help" ]
	then 
		usage
		exit
fi
if [ "$1" = "test" ] 
 then
  if [ "$2" != "" ] 
   then
       curl -s https://www.youtube.com/watch?v=$2 | grep "<title>" | awk -F\<title\> '{print $2}' | awk -F\</title '{print $1}'
   else
       usage	
  fi
fi

if [ "$1" = "scan" ]
 then

declare -i starta=$(echo $LAST | awk -F: '{print $1}')
declare -i startb=$(echo $LAST | awk -F: '{print $2}')
declare -i startc=$(echo $LAST | awk -F: '{print $3}')
declare -i startd=$(echo $LAST | awk -F: '{print $4}')
declare -i starte=$(echo $LAST | awk -F: '{print $5}')
declare -i startf=$(echo $LAST | awk -F: '{print $6}')
declare -i startg=$(echo $LAST | awk -F: '{print $7}')
declare -i starth=$(echo $LAST | awk -F: '{print $8}')
declare -i starti=$(echo $LAST | awk -F: '{print $9}')
declare -i startj=$(echo $LAST | awk -F: '{print $10}')
declare -i startk=$(echo $LAST | awk -F: '{print $11}')
let startk=$startk+1
if [ "$SILENTMODE" != "ON" ]
 then
	echo "start-> $starta:$startb:$startc:$startd:$starte:$startf:$startg:$starth:$starti:$startj:$startk" 
fi
for a in `seq $starta 61` #61
 do
  for b in `seq $startb 61` 
   do
    for c in `seq $startc 61` 
     do
      for d in `seq $startd 61` 
       do
        for e in `seq $starte 61` 
   	 do
	  for f in `seq $startf 61` 
   	   do
	    for g in `seq $startg 61` 
   	     do
	      for h in `seq $starth 61` 
   	       do
	        for i in `seq $starti 61` 
   		 do
		  for j in `seq $startj 61` 
   		   do
		    for k in `seq $startk 61` 
   		     do
		       curl -s --user-agent "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" "https://www.youtube.com/watch?v=${SIGNS[$a]}${SIGNS[$b]}${SIGNS[$c]}${SIGNS[$d]}${SIGNS[$e]}${SIGNS[$f]}${SIGNS[$g]}${SIGNS[$h]}${SIGNS[$i]}${SIGNS[$j]}${SIGNS[$k]}" >/root/ytscan/ytscache
		       CAT=$(awk -Fcategory\":\" '{print $2}' ytscache | awk -F\" '{print $1}' | grep "\S")
		       if [ "$CAT" != "" ]
                        then
			    TITLE=$(awk -F\<title\> '{print $2}' ytscache | awk -F\</title '{print $1}' | grep "\S")
		            CRAWL=$(awk -F\"isCrawlable\": '{print $2}' ytscache | awk -F\" '{print $1}' | grep "\S")
			     if [ "$SILENTMODE" != "ON" ]
			      then
			          echo "URL:https://www.youtube.com/watch?v=${SIGNS[$a]}${SIGNS[$b]}${SIGNS[$c]}${SIGNS[$d]}${SIGNS[$e]}${SIGNS[$f]}${SIGNS[$g]}${SIGNS[$h]}${SIGNS[$i]}${SIGNS[$j]}${SIGNS[$k]}"
			    	  echo "Titel:$TITLE"
		            	  echo "Category:$CAT"
			    	  echo "Crawlable:$CRAWL"
			     fi 
			    echo "_____________________________________">>ytfound
			    echo "URL:https://www.youtube.com/watch?v=${SIGNS[$a]}${SIGNS[$b]}${SIGNS[$c]}${SIGNS[$d]}${SIGNS[$e]}${SIGNS[$f]}${SIGNS[$g]}${SIGNS[$h]}${SIGNS[$i]}${SIGNS[$j]}${SIGNS[$k]}" >>ytfound
			    echo "Titel:$TITLE">>ytfound
		            echo "Category:$CAT">>ytfound
			    echo "Crawlable:$CRAWL">>ytfound
			else
			     if [ "$SILENTMODE" != "ON" ]
			      then
echo "check ->[YTid:${SIGNS[$a]}${SIGNS[$b]}${SIGNS[$c]}${SIGNS[$d]}${SIGNS[$e]}${SIGNS[$f]}${SIGNS[$g]}${SIGNS[$h]}${SIGNS[$i]}${SIGNS[$j]}${SIGNS[$k]}] [for:$a:$b:$c:$d:$e:$f:$g:$h:$i:$j:$k]"
			     fi	
			fi



				echo "$a:$b:$c:$d:$e:$f:$g:$h:$i:$j:$k" >lastyt
if [ "$2" = "sleep" ]
 then
     sleep $(( ( RANDOM % 4 )  + 1 ))
fi

	     done
	     declare -i startk=0
   	    done
	    declare -i startj=0
   	   done
	   declare -i starti=0
   	  done
	  declare -i starth=0
   	 done
	 declare -i startg=0
   	done
	declare -i startf=0
       done
       declare -i starte=0
      done
      declare -i startd=0
     done
     declare -i startc=0
    done
    declare -i startb=0
   done
   declare -i starta=0
fi #if $1 scan
