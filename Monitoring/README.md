# Tenderduty monitoring and alerting system guide for Haqq validator

This monitoring of TenderDuty v2 allows you to control the nodes and, in particular, see the height of the network, the status of the validator, uptime, signed and skipped blocks. It is also possible to connect notifications to telegrams and discord

Installation is possible in various ways, but we will use installation via Docker.
U can find Build From Source in the [original docs](https://github.com/blockpane/tenderduty/blob/main/docs/install.md).

So, we need a separate server (which definitely gives a security plus) or a server with an already installed node (nodes). You will also need to find open RPCs or open your own on the main (not desirable) or backup node.

## Install dependencies

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt install screen make clang pkg-config libssl-dev build-essential git jq llvm libudev-dev -y
```

## Install Docker

```bash
apt update && \
apt install apt-transport-https ca-certificates curl software-properties-common -y && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" && \
apt update && \
apt-cache policy docker-ce && \
sudo apt install docker-ce -y && \
docker --version
```
## Install and setup config file

```bash
mkdir tenderduty && cd tenderduty
docker run --rm ghcr.io/blockpane/tenderduty:latest -example-config >config.yml
```
#### Download config sample
```bash
wget -qO $HOME/config.yml https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Tenderduty/config.yml
```
#### Set your valoper address
Open file `$HOME/config.yml` find `chains:` paragraph, set your valoper address here : `valoper_address:` and save file.

![valoper](https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Tenderduty/images/valoper.png)

#### Run service

```bash
docker run -d --name tenderduty -p "8888:8888" -p "28686:28686" --restart unless-stopped -v $(pwd)/config.yml:/var/lib/tenderduty/config.yml ghcr.io/blockpane/tenderduty:latest
```

#### Check logs
```bash
 ![img.png](img.png)
```
This is how the right logs supposed to look like

![logs](https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Tenderduty/images/logs.png)

#### Check dashboard

By default Tenderduty dashboard run at port `8888`. Just open your browser and open dashboard by typing `http://<SERVER_IP_HERE>:8888`  <br />

Sample of right working dashboard  <br />
![dashboard](https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Tenderduty/images/dashboard.png)

<br />

# Telegram alert bot setup


Create your own group at Telegram where your bot will be sending alert notifications  <br />
Find **@BotFather** user at telegram and create your own Bot (use any available name) Use `/newbot` command <br />

**>>> PLEASE COPY HTTP API KEY AND SAVE <<<**

![new_bot](https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Tenderduty/images/newbot.png)

### Add bot to your group and find out group ID
bot
Find your bot by TG @username and add to your group

![add_bot](https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Tenderduty/images/addbot.png)

#### Find out group ID

Find bot named **@JsonViewBot** and add to your group <br />
Bot should join group, show your group ID and leave the group. <br />

**>>> PLEASE COPY GROUP ID AND SAVE <<<**

![bot_info](https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Tenderduty/images/botinfo.png)

![chat_id](https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Tenderduty/images/chatid.png)

### Activate Telegram bot

Open file `$HOME/config.yml` find `#telegram settings:` paragraph, set some params we saved above: <br />
enabled: yes <br />
api_key: <YOUR_BOT_API_KEY> <br />
channel: <YOUR_GROUP_ID> <br />
Save changes.

![telegram](https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Tenderduty/images/telegram.png)

### Last steps...

Restart tenderduty service
```bash
docker restart tenderduty
```
**NOTE** : If after restart U will find logs like : <br />
`Haqq is configured for telegram alerts, but it is not enabled` never mind, it doesn`t mean Telegram notification is not working.

Set up Your Telegram notification settings to receive notifications from created group!

#### Example alert service

![alert](https://github.com/OnThePluto/Haqq-Network/blob/main/Monitoring/Tenderduty/images/alert.png)
