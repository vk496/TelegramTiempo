#!/bin/bash


xpathc() {

#xmllint --noent --format --html --xpath  "$@" 2>/dev/null -
    xmlstarlet sel -t -m "$@" -c "." -n 2>/dev/null

}

xpathv() {
    xmlstarlet sel -t -v "$@" 2>/dev/null
}


get_icon() {

# d000: "cloudless",
#     d100: "mostly-clear",
#     d200: "partly-cloudy",
#     d210: "partly-cloudy-light-rain",
#     d211: "partly-cloudy-light-wet-snow",
#     d212: "partly-cloudy-light-snow",
#     d220: "partly-cloudy-showers",
#     d221: "partly-cloudy-wet-snow-showers",
#     d222: "partly-cloudy-snow-showers",
#     d240: "partly-cloudy-thunderstorm-rain",
#     d300: "cloudy",
#     d310: "cloudy-light-rain",
#     d311: "cloudy-light-wet-snow",
#     d312: "cloudy-light-snow",
#     d320: "cloudy-showers",
#     d321: "cloudy-wet-snow-showers",
#     d322: "cloudy-snow-showers",
#     d340: "cloudy-thunderstorms-rain",
#     d400: "overcast",
#     d410: "overcast-light-rain",
#     d411: "overcast-light-wet-snow",
#     d412: "overcast-light-snow",
#     d420: "overcast-showers",
#     d421: "overcast-wet-snow-showers",
#     d422: "overcast-snow-showers",
#     d430: "overcast-rain",
#     d431: "overcast-wet-snow",
#     d432: "overcast-snow",
#     d440: "overcast-thunderstorms-rain",
#     n000: "night-cloudless",
#     n100: "night-mostly-clear",
#     n200: "night-partly-cloudy",
#     n210: "night-partly-cloudy-light-rain",
#     n211: "night-partly-cloudy-light-wet-snow",
#     n212: "night-partly-cloudy-light-snow",
#     n220: "night-partly-cloudy-showers",
#     n221: "night-partly-cloudy-wet-snow-showers",
#     n222: "night-partly-cloudy-snow-showers",
#     n240: "night-partly-cloudy-thunderstorm-rain",
#     n300: "night-cloudy",
#     n310: "night-cloudy-light-rain",
#     n311: "night-cloudy-light-wet-snow",
#     n312: "night-cloudy-light-snow",
#     n320: "night-cloudy-showers",
#     n321: "night-cloudy-wet-snow-showers",
#     n322: "night-cloudy-snow-showers",
#     n340: "night-cloudy-thunderstorms-rain",
#     n400: "overcast",
#     n410: "overcast-light-rain",
#     n411: "overcast-light-wet-snow",
#     n412: "overcast-light-snow",
#     n420: "overcast-showers",
#     n421: "overcast-wet-snow-showers",
#     n422: "overcast-snow-showers",
#     n430: "overcast-rain",
#     n431: "overcast-wet-snow",
#     n432: "overcast-snow",
#     n440: "overcast-thunderstorms-rain",
#     d999: "undefined-icon",
#     n999: "undefined-icon"


# ☀️🌤⛅️🌥🌦☁️🌧⛈🌩🌨

    case $1 in
        *cloudless)
            echo "☀️"
            ;;
        *mostly-clear)
            echo "🌤"
            ;;
        *partly-cloudy-light-rain)
            echo "🌦"
            ;;
        *thunderstorms-rain)
            echo "⛈"
            ;;
        *snow)
            echo "🌨"
            ;;
        *partly-cloudy*)
            echo "⛅️"
            ;; 
        *cloudy*)
            echo "🌥"
            ;; 
        overcast*)
            echo "☁️"
            ;; 
        *)
            echo "🌚"
            ;;
    esac

}


print_tiempo() {
    set +x
    lugar=$1

    if [ -z $lugar ]; then

        >&2 echo "No city specified"
        exit -1

    fi


    page=$(curl -qskL https://www.eltiempo.es/$lugar.html | xmlstarlet fo -H -D 2>/dev/null | xpathc "//article[@data-next-week]//div[@data-next-week-slider]" )


    for i in {1..3}; do

        ACTUAL=$(echo $page | xpathc "//div[@data-expand-tablechild-item][$i]")

        #### Fecha
        b1=$(echo $ACTUAL | xpathc "//div[contains(@class, \"m_table_weather_day_date\")]")

        dia=$(echo $b1 | xpathv "//p[contains(@class, \"m_table_weather_day_title\")][1]")
        fecha=$(echo $b1 | xpathv "//p[not(@class)]")
        ####


        #### Maximos
        b2=$(echo $ACTUAL | xpathc "//div[contains(@class, \"m_table_weather_day_max_min\")]")

        max=$(echo $b2 | xpathv "//span[contains(@class, \"m_table_weather_day_max_temp\")]/span[@data-temp]/@data-temp")
        min=$(echo $b2 | xpathv "//span[contains(@class, \"m_table_weather_day_min_temp\")]/span[@data-temp]/@data-temp")

        ####
        
        
        echo -n "\n$dia ($fecha): ⬆️$maxº  ⬇️$minº\n"
        echo -n "---------------\n"

        while read -r line; do
            hora=$(echo $line | xpathv "//div[@data-show-popup]/@popup_date" | grep -oP "\d{2}:\d{2}")
            temp_dia=$(echo $line | xpathv "//div[@data-show-popup]/@popup_temp_orig")
            text=$(echo $line | xpathv "//div[@data-show-popup]/@popup_forecast")
            icon=$(echo $line | xpathv "//div[@data-show-popup]/@popup_icon")
            

            echo -n "$hora: [$(get_icon $icon) $temp_diaº] $text\n"

        done < <(echo $ACTUAL | xpathc "//div[@data-show-popup]")


        echo -ne "\n"


    done
    set -x
}


function getCiudad() {
    print_tiempo $1 > $IMAGE_PATH/$1.txt
}

function send(){

    #send "$city" "$ciudad" "#Tiempo" "$extra"
    
    tiempo=$(cat $IMAGE_PATH/$1.txt)
    
    mensaje=${@:2}\\n$tiempo
    
    set +e
    for i in "${to[@]}"; do
        (sleep 7; echo "safe_quit") | eval $TG_CLI -U root -G root -W -D -e \"msg $i \'$mensaje\'\" &>/dev/null
    done
    set -e
    
    unset tiempo

}

#print_tiempo "$@"
