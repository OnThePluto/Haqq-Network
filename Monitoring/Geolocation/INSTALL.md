# GEO location monitoring for Haqq validator

This location monitoring allows you to determine the decentralization of the blockchain and / or indicate its absence, statistics are compiled on validators: providers, cities and countries, and a map of validators is also built

## Install dependencies

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt install screen bash git curl jq awk -y
```

## Specify the path to the addrbook file
By default, we will search for network peers in a specialized file at: $HOME/.haqqd/config/addrbook.json

## Run service

```bash
cd $HOME && rm -rf Haqq-Network && git clone https://github.com/OnThePluto/Haqq-Network.git && cd Haqq-Network/Monitoring/Geolocation && chmod +x run.sh && bash run.sh
```

### Country & city statistic 

![countries](https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Geolocation/images/country_statistic.png)

### Country & city statistic

![providers](https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Geolocation/images/provider_statistic.png)

### Map (in format: .svg)

![map](https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Geolocation/images/map.svg)
