#!/bin/bash -
clear
datei="all.lst"



usage()
{
 echo "$0 -d [eins-sieben] [..OPTION..]"
 echo "[-d|wieviel stellen] [-n|nur nummern] [-l|nur kleine buchstaben] [-b|nur große buchstaben] [-all|0-9 a-z A-Z]"
 echo ""
 echo "example:"
 echo "$0 -d sieben -a"
}

if [ "$3" = "" ];then echo "Parameter fehlen";usage;exit;fi

if [ "$3" = "-all" ];then 
 ALPHABET=( a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9 )
 ende=61
fi

if [ "$3" = "-l" ];then 
 ALPHABET=( a b c d e f g h i j k l m n o p q r s t u v w x y z )
 ende=25
fi

if [ "$3" = "-n" ];then 
 ALPHABET=( 0 1 2 3 4 5 6 7 8 9 )
 ende=9
fi

if [ "$3" = "-b" ];then 
 ALPHABET=( A B C D E F G H I J K L M N O P Q R S T U V W X Y Z )
 ende=25
fi
nummer=0





eins()
{
 for i in `seq $nummer $ende`
   do
              echo "${ALPHABET[$i]}" >>$datei
              echo "${ALPHABET[$i]}" 
   done
}


zwei()
{
for i in `seq $nummer $ende`
  do
    for f in  `seq $nummer $ende`
      do
              echo "${ALPHABET[$i]}${ALPHABET[$f]}" >>$datei
              echo "${ALPHABET[$i]}${ALPHABET[$f]}" 
    done
done
}


drei()
{
for i in `seq $nummer $ende`
  do
    for f in  `seq $nummer $ende`
      do
        for k in  `seq $nummer $ende`
          do
              echo "${ALPHABET[$i]}${ALPHABET[$f]}${ALPHABET[$k]}" >>$datei
              echo "${ALPHABET[$i]}${ALPHABET[$f]}${ALPHABET[$k]}" 
          done
      done
  done
}


vier()
{
for i in `seq $nummer $ende`
  do
    for f in  `seq $nummer $ende`
      do
        for k in  `seq $nummer $ende`
          do
            for l in  `seq $nummer $ende`
             do
              echo "${ALPHABET[$i]}${ALPHABET[$f]}${ALPHABET[$k]}${ALPHABET[$l]}" >>$datei
              echo "${ALPHABET[$i]}${ALPHABET[$f]}${ALPHABET[$k]}${ALPHABET[$l]}"
            done
        done
    done
done
}


fuenf()
{
for i in `seq $nummer $ende`
  do
    for f in  `seq $nummer $ende`
      do
        for k in  `seq $nummer $ende`
          do
            for l in  `seq $nummer $ende`
             do
               for a in  `seq $nummer $ende`
                 do
              echo "${ALPHABET[$i]}${ALPHABET[$f]}${ALPHABET[$k]}${ALPHABET[$l]}${ALPHABET[$a]}" >>$datei
              echo "${ALPHABET[$i]}${ALPHABET[$f]}${ALPHABET[$k]}${ALPHABET[$l]}${ALPHABET[$a]}" 
               done
            done
        done
    done
done
}


sechs()
{
for i in `seq $nummer $ende`
  do
    for f in  `seq $nummer $ende`
      do
        for k in  `seq $nummer $ende`
          do
            for l in  `seq $nummer $ende`
             do
               for a in  `seq $nummer $ende`
                 do
                  for b in  `seq $nummer $ende`
                    do
                      echo "${ALPHABET[$i]}${ALPHABET[$f]}${ALPHABET[$k]}${ALPHABET[$l]}${ALPHABET[$a]}${ALPHABET[$b]}" >>$datei
                      echo "${ALPHABET[$i]}${ALPHABET[$f]}${ALPHABET[$k]}${ALPHABET[$l]}${ALPHABET[$a]}${ALPHABET[$b]}"
                 done
               done
            done
        done
    done
done

}



sieben()
{
for i in `seq $nummer $ende`
  do
    for f in  `seq $nummer $ende`
      do
        for k in  `seq $nummer $ende`
          do
            for l in  `seq $nummer $ende`
             do
               for a in  `seq $nummer $ende`
                 do
                  for b in  `seq $nummer $ende`
                    do
                     for c in  `seq $nummer $ende`
                       do
                      echo "${ALPHABET[$i]}${ALPHABET[$f]}${ALPHABET[$k]}${ALPHABET[$l]}${ALPHABET[$a]}${ALPHABET[$b]}${ALPHABET[$c]}" >>password.lst
                      echo "${ALPHABET[$i]}${ALPHABET[$f]}${ALPHABET[$k]}${ALPHABET[$l]}${ALPHABET[$a]}${ALPHABET[$b]}${ALPHABET[$c]}"
                 done
               done
            done
        done
    done
done
done
}

$2
exit 0

