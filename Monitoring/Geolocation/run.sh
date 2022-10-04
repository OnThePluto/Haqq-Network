#!/usr/local/bin/bash

ADDRBOOK="$HOME/.haqqd/config/addrbook.json"

read -p "Enter your path to addrbook [default $ADDRBOOK]:" ADDRBOOK
echo 'export ADDRBOOK='${ADDRBOOK:=$ADDRBOOK} >> $HOME/.bash_profile

if [ -z "$ADDRBOOK" ]; then
  echo "Please configure addrbook.json in script"
  exit 1
fi

GEO_DATA_DIR="$HOME/geolocation"
if [ ! -d "$GEO_DATA_DIR" ]; then
  mkdir "$GEO_DATA_DIR";
fi

GEO_DATA="$GEO_DATA_DIR/data"
if [ ! -d "$GEO_DATA" ]; then
  mkdir "$GEO_DATA";
fi

if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi

declare -a Countries Cities Organizations;
# shellcheck disable=SC2002
for IP in $(cat "$ADDRBOOK" | jq -rc '.addrs[] | .addr.ip '); do
  if [ ! -f "$GEO_DATA/$IP.json" ]; then
    # shellcheck disable=SC2034
    DATA=$(curl -s "https://ipinfo.io/$IP");
    # shellcheck disable=SC2034
    # shellcheck disable=SC2036
    # shellcheck disable=SC2030
    IP=$(echo "$DATA" | jq '.ip' | sed 's/\"//g');
    # shellcheck disable=SC2034
    COUNTRY=$(echo "$DATA" | jq '.country' | sed 's/\"//g');
    # shellcheck disable=SC2034
    # shellcheck disable=SC2030
    CITY=$(echo "$DATA" | jq '.city' | sed 's/\"//g');
    # shellcheck disable=SC2034
    # shellcheck disable=SC2030
    ORG=$(echo "$DATA" | jq '.org' | sed 's/\"//g');
    # shellcheck disable=SC2034
    # shellcheck disable=SC2157
    JSON_STRING=$( jq -n \
                      --arg ip "$IP"  \
                      --arg country "$COUNTRY" \
                      --arg city "$CITY" \
                      --arg org "$ORG" \
                      '{ip: $ip, country: $country, city: $city, org: $org}' )
    echo "$JSON_STRING" >> "$GEO_DATA/$IP.json";
  fi
  if [ -f "$GEO_DATA/$IP.json" ]; then
    COUNTRY=$(cat "$GEO_DATA/$IP.json" | jq '.country')
    CITY=$(cat "$GEO_DATA/$IP.json" | jq '.city')
    ORG=$(cat "$GEO_DATA/$IP.json" | jq '.org')
    # shellcheck disable=SC2206
    Countries+=($COUNTRY);
    # shellcheck disable=SC2030
    # shellcheck disable=SC2001
    # shellcheck disable=SC2179
    Cities+=($(echo "$CITY" | sed s/' '/_/g));
    # shellcheck disable=SC2030
    # shellcheck disable=SC2001
    # shellcheck disable=SC2179
    Organizations+=($(echo "$ORG" | sed s/' '/_/g));
  fi
done
# shellcheck disable=SC2034
SUM="${#Countries[@]}";
# shellcheck disable=SC2068
# shellcheck disable=SC2207
# shellcheck disable=SC2006
UniqCountries=( `for i in ${Countries[@]}; do echo "$i"; done | sort -u` )
# shellcheck disable=SC2068
# shellcheck disable=SC2207
# shellcheck disable=SC2068
# shellcheck disable=SC2006
# shellcheck disable=SC2034
UniqCities=( `for i in ${Cities[@]}; do echo "$i"; done | sort -u` )
# shellcheck disable=SC2034
# shellcheck disable=SC2068
# shellcheck disable=SC2207
# shellcheck disable=SC2207
# shellcheck disable=SC2207
# shellcheck disable=SC2068
# shellcheck disable=SC2006
UniqOrganizations=( `for i in ${Organizations[@]}; do echo "$i"; done | sort -u` )

##COUNTRIES
# shellcheck disable=SC2028
echo "Statistic Countries"
declare -A StatisticCountry
for COUNTRY in ${UniqCountries[*]}; do
  # shellcheck disable=SC2031
  COUNT=$(grep -o "$COUNTRY" <<< "${Countries[*]}" | wc -l)
  StatisticCountry["$COUNTRY"]=$COUNT;
done

# shellcheck disable=SC2034
MAP="map.svg";
NEW_MAP="new_map.svg";
cp "$MAP" "$NEW_MAP";

for COUNTRY in "${!StatisticCountry[@]}"; do
  # shellcheck disable=SC2004
  PERCENT=$((${StatisticCountry[$COUNTRY]} * 100 / $SUM))
  if [ $PERCENT -lt 5 ]; then
    COLOR="E6E6FA";
  elif [ $PERCENT -lt 10 ]; then
    COLOR="D8BFD8";
  elif [ $PERCENT -lt 20 ]; then
    COLOR="EE82EE";
  elif [ $PERCENT -lt 30 ]; then
    COLOR="FF00FF";
  elif [ $PERCENT -lt 40 ]; then
    COLOR="BA55D3";
  elif [ $PERCENT -lt 50 ]; then
    COLOR="8A2BE2";
  else
    COLOR="4B0082";
  fi
  # shellcheck disable=SC2002
  STRING=$(cat "$NEW_MAP" | grep "$COUNTRY" | sed -e 's/^[[:space:]]*//' | awk -F 'transform' '{print $2}');
  if [ "$STRING" ]; then
    NEW_STRING=$(sed -e "s/818181/$COLOR/; s/fill-opacity=\"0\"/fill-opacity=\"1\"/" <<< "$STRING")
    sed -i "" "s|$STRING|$NEW_STRING|g" "$NEW_MAP"
  fi
  # shellcheck disable=SC2074
  # shellcheck disable=SC1072
  # shellcheck disable=SC1073
  # shellcheck disable=SC1009
  if [ $PERCENT -gt 0 ]; then
    printf "COUNTRY: %s, Servers: %s, Current Percent: %s\r\n" "$COUNTRY" "${StatisticCountry[$COUNTRY]}" "$PERCENT%"
  fi
done

##CITIES
# shellcheck disable=SC2028
echo "Statistic Cities"
declare -A StatisticCity
for CITY in ${UniqCities[*]}; do
  # shellcheck disable=SC2031
  COUNT=$(grep -o "$CITY" <<< "${Cities[*]}" | wc -l)
  StatisticCity["$CITY"]=$COUNT;
done

for CITY in "${!StatisticCity[@]}"; do
  # shellcheck disable=SC2004
  # shellcheck disable=SC2074
  PERCENT=$((${StatisticCity[$CITY]} * 100 / $SUM))
  if [ $PERCENT -gt 0 ]; then
    printf "CITY: %s, Servers: %s, Current Percent: %s\r\n" "$CITY" "${StatisticCity[$CITY]}" "$PERCENT%"
  fi
done

##ORGANIZATIONS
# shellcheck disable=SC2028
echo "Statistic Organizations"
declare -A StatisticOrg
for ORG in ${UniqOrganizations[*]}; do
  # shellcheck disable=SC2031
  COUNT=$(grep -o "$ORG" <<< "${Organizations[*]}" | wc -l)
  # shellcheck disable=SC2034
  StatisticOrg["$ORG"]=$COUNT;
done

for ORG in "${!StatisticOrg[@]}"; do
  # shellcheck disable=SC2004
  # shellcheck disable=SC1072
  # shellcheck disable=SC1073
  # shellcheck disable=SC1009
  PERCENT=$((${StatisticOrg[$ORG]} * 100 / $SUM))
  if [ $PERCENT -gt 0 ]; then
    printf "ORGANIZATION: %s, Servers: %s, Current Percent: %s\r\n" "$ORG" "${StatisticOrg[$ORG]}" "$PERCENT%"
  fi
done
