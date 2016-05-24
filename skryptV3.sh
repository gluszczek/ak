#!/bin/bash

WYBOR=-1
LICZNIK=-1
TRYB=1
BGMODE=0
PRMODE=0
CZAS=0
NAZWA=""
TIMELIMIT="timelimit -t "
PROG=""
LOOP=-1
REPEAT=-1

declare -a EVENTS=(0 0 0 0 0 0)
declare -a E_CMD=("cpu-cycles" "instructions" "cache-references" "cache-misses" "branches" "branch-misses")

while [ "$WYBOR" != "0" ]; do
	clear
	echo "aktywne liczniki: "
	for i in {0..5..1}
		do 
		if [ ${EVENTS[i]} -eq 1 ] ; then
			echo "*${E_CMD[i]} "
		fi
	done
	echo ""
	echo "plik: $NAZWA"
	echo "czas: $CZAS"
	echo "____________________________"
	
	echo ""
	echo "Wybierz opcje: "
	echo ""
	echo "1. Dodaj licznik"
	echo "2. Usun licznik"
	echo "3. Wybierz tryb"
	echo "4. Ustaw czas"
	echo "5. Ustaw nazwe pliku"
	echo "6. Wybierz program"
	echo "7. Rozpocznij eksperyment"
	echo "0. Wyjdz"
	echo ""
	read WYBOR


	case $WYBOR in
		0)
			break
			;;
		1)	clear
			echo "DODAWANIE LICZNIKA"
			echo "1. cpu-cycles [${EVENTS[0]}]"
			echo "2. instructions [${EVENTS[1]}]"
			echo "3. cache-references [${EVENTS[2]}]"
			echo "4. cahce-misses [${EVENTS[3]}]"
			echo "5. branches [${EVENTS[4]}]"
			echo "6. bus-cycles [${EVENTS[5]}]"
			echo ""
			echo "0. POWROT"
			
			read LICZNIK
			LICZNIK=$LICZNIK-1
			EVENTS[$LICZNIK]=1
			;;
		2)	clear
                        echo "USUWANIE LICZNIKA"

                        echo "1. cpu-cycles [$CPUCYCLES]"
                        echo "2. instructions [$INSTRUCT]"
                        echo "3. cache-references [$CACHEREF]"
                        echo "4. cache-misses [$CACHEMISS]"
                        echo "5. branches [$BRANCHES]"
                        echo "6. bus-cycles [$BUSCYCLES]"
                        echo ""
                        echo "0. POWROT"

                        read LICZNIK
                        LICZNIK=$LICZNIK-1
                        EVENTS[$LICZNIK]=0
			;;
		3)	clear
			echo "WYBIERANIE TRYBU"
			
			echo "1. Monitorowanie pracy procesora w tle podczas uruchomionych programow uzytkowych[$BGMODE]"
			echo "2. Monitorowanie podczas uruchomionego konkretnego programu w okreslonym czasie[$PRMODE]"
			echo ""
			echo "0. Powrot"
			read TRYB
			
			case $TRYB in
				1)	BGMODE=1
					PRMODE=0
					;;
				2)	BGMODE=0
					PRMODE=1
					;;
				0)
					;;
				*)
					;;
			esac
			;;
		4)	clear
			echo "USTAWIANIE CZASU"
			
			echo "Podaj czas wczytywania pomiarow: "
			read CZAS
			;;
		5)	clear
			echo "USTAWIANIE NAZWY PLIKU"
			echo "Podaj nazwe pliku do zapisu danych: "
			read NAZWA
			echo "Wczytano nazwe: $NAZWA"
			;;
		6)	clear
			echo "WYBIERANIE PROGRAMU"
			echo "Wybierz program obciazajacy procesor: "
			echo "1.Mnozenie macierzy"
			echo "2.Liczby pierwsze"
			echo "3.Film"
			echo "4.Muzyka"
			echo "5.Animacja"
			echo ""
			echo "0.Powrot"
			read PROGRAM
			
			case $PROGRAM in
				1)	PROG="./matrix"	
					;;
				2)	PROG="./primes"
					;;
				3)	PROG="totem movie.mp4"
					;;
				4)	PROG="totem music.mp3"
					;;
				5)	PROG="gnash animation.swf"
					;;
				0)
					;;
				*)
					;;
			esac
			;;
		7)	clear
			echo "ROZPOCZETO EKSPERYMENT"
			echo "Nazwa pliku: $NAZWA"
			echo "Program: $PROG"
			
			KOMENDA="perf stat -e "
			for i in {0..5..1}
                	do
                		if [ ${EVENTS[i]} -eq 1 ] ; then
				KOMENDA=$KOMENDA${E_CMD[i]}","
               			fi
		        done
			KOMENDA=${KOMENDA::-1}
			
			if [ $BGMODE -eq 1 ] ; then
				KOMENDA="3>>"$NAZWA" "$KOMENDA" -a --log-fd 3 sleep "$CZAS
			else
				KOMENDA="3>>"$NAZWA" "$KOMENDA" --log-fd 3 "$TIMELIMIT" "$CZAS" "$PROG
			fi

			echo "Ile razy wykonac ten eksperyment? "
			read LOOP
			
			echo "start"
			sleep 1
			LICZ=0
			while [ "$LOOP" != "0" ] ; do	
				echo "LOOP= $LOOP"
				echo "LICZ= $LICZ"
				LICZ=$((LICZ+1))
				echo $LICZ >> $NAZWA
				echo $(date) >> $NAZWA
				echo "$KOMENDA"
				eval $KOMENDA
				LOOP=$((LOOP-1))
			done	
			;;
		*)
			echo "Nie ma takiej opcji"
			sleep 1
			;;
	esac
done








