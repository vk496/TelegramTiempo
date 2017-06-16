#!/bin/bash
set -e

echo "[RUN] Looking for existing authentification at '$CLI_DATA/auth'."
if [ -f $CLI_DATA/auth.bot.gpg ];
then
  asize=$(wc -c < $CLI_DATA/auth.bot.gpg)
  if (($asize > 0)); then
	gpg --yes --batch --passphrase=$GPG_PASS -o $CLI_DATA/auth $CLI_DATA/auth.bot.gpg
  else
     echo "[RUN] Authfile is empty."
     exit 1
  fi
else
  echo "[RUN] Authfile is not existent."
  exit 2
fi

CIUDADES=("Murcia" "Leon" "Caceres" "Pamplona" "Albacete" "Don-Benito" "Malaga" "Donostia-San-Sebastian" "Salerno" "Villanueva-de-los-infantes" "Huesca" "Lleida" "Barcelona" "Madrid" "Las-rozas-de-madrid")
IMAGE_PATH=$WEATHER_DIR

mkdir -p $IMAGE_PATH

to=("chat#5193990") #OpenRITSI

function send(){

        #to=("@vk496")

	set -x
        for i in "${to[@]}"; do
		eval $TG_CLI -U root -G root -W -D -e \"send_photo $i $IMAGE_PATH/$1.png ${@:2}\"
        done
	set +x
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
			"Villanueva-de-los-infantes") ciudad="#VillanuevaDeLosInfantesDirecto" ;;
			"Huesca") extra="#LaCapitalMundial" ;;
			"Lleida") extra="#fotCaloretNoi" ;;
			"Barcelona") extra="#AscoltaNanuQuinaCaloretaQueFa" ;;
			"Las-rozas-de-madrid") ciudad="#LasRozasDeMadridDirecto" ;;
		esac

		send "$city" "$ciudad" "#Tiempo" "$extra"
	fi
done

for i in "${to[@]}"; do
	$TG_CLI -U root -G root -W -D -e "msg $i Recordad añadir vuestra ciudad en https://github.com/vk496/TelegramTiempo :)"
done
