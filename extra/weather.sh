#!/bin/bash
set -e

mode=1

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

set -x


CIUDADES=(
"Murcia"
"Leon"
"Caceres"
"Pamplona"
"Albacete"
"Don-Benito"
"Malaga"
"Donostia-San-Sebastian"
"Salerno"
"Villanueva-de-los-infantes"
"Huesca"
"Lleida"
"Barcelona"
"Madrid"
"Las-rozas-de-madrid"
"Oviedo"
)


IMAGE_PATH=$WEATHER_DIR

mkdir -p $IMAGE_PATH

to=("channel#1135859121") #OpenRITSI
# to=("@vk496")


function send(){
    #send "$city" "$ciudad" "#Tiempo" "$extra"
    
    
    if [ -f $IMAGE_PATH/$city.png ]; then
    
        #to=("@vk496")

        for i in "${to[@]}"; do
            set +e
            (sleep 5; echo "safe_quit") | eval $TG_CLI -U root -G root -W -D -e \"send_photo $i $IMAGE_PATH/$1.png ${@:2}\"
            set -e
        done
	
	fi
}


function getCiudad() {
	rm -f $IMAGE_PATH/$1.png
	xvfb-run -a -- /usr/bin/wkhtmltoimage --disable-javascript --height 950 --crop-y 200 --crop-w 700 https://www.eltiempo.es/$1.html $IMAGE_PATH/$1.png
}


if [ $mode -eq 1 ]; then
    source "$WEATHER_DIR"/weatherv2.sh
fi




for city in "${CIUDADES[@]}"; do

    getCiudad $city

done


for city in "${CIUDADES[@]}"; do
	#echo $city
	
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
        "Oviedo") extra="#Oviedo" ;;
    esac

    send "$city" "$ciudad" "#Tiempo" "$extra"
    
    unset city ciudad extra

done

for i in "${to[@]}"; do
    set +e
	(sleep 7; echo "safe_quit") | $TG_CLI -U root -G root -W -D -e "msg $i Recordad añadir vuestra ciudad en https://github.com/vk496/TelegramTiempo :)"
	set -e
done
