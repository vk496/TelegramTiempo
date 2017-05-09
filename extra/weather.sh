#!/bin/bash
set -e

echo "[RUN] Looking for existing authentification at '$CLI_DATA/auth'."
if [ -f $CLI_DATA/auth.bot.gpg ];
then
  asize=$(wc -c < $CLI_DATA/auth.bot.gpg)
  if (($asize > 0)); then
	gpg --yes --batch --passphrase=$GPG_PASS $CLI_DATA/auth.bot.gpg -o $CLI_DATA/auth
  else
     echo "[RUN] Authfile is empty."
     exit 1
  fi
else
  echo "[RUN] Authfile is not existent."
  exit 2
fi

CIUDADES=("Murcia" "Leon" "Caceres" "Pamplona" "Arrasate" "Albacete" "Don-Benito" "Malaga" "Donostia-San-Sebastian" )
IMAGE_PATH=$WEATHER_DIR

mkdir -p $IMAGE_PATH

function send(){

        to=("@vk496")
        #to=("chat#5193990") #OpenRITSI

        for i in "${to[@]}"; do
		$TG_CLI -U root -G root -W -e "send_photo $i $IMAGE_PATH/$1.png ${@:2}"
        done
}



function getCiudad() {
	rm -f $IMAGE_PATH/$1.png
	xvfb-run -a -- /usr/bin/wkhtmltoimage --disable-javascript --height 950 --crop-y 200 --crop-w 700 https://www.eltiempo.es/$1.html $IMAGE_PATH/$1.png
}




for city in "${CIUDADES[@]}"; do
	#echo $city
	getCiudad $city

	if [ -f $IMAGE_PATH/$city.png ]; then
		ciudad="#${city}Directo"
		extra=

		case $city in
			"Albacete") extra="#Miguelitos" ;;
			"Don-Benito") extra="#MakeDonBenitoGreatAgain"; ciudad="#DonBenitoDirecto" ;;
			"Donostia-San-Sebastian") ciudad="#DonostiaDirecto" ;;
		esac

		eval send $city \"$ciudad\" \"#Tiempo\" \"$extra\"
	fi
done
