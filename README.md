# BML-TG-NOTIFICATION
## Push Notification BML Transcations to Telegram

### Requriements
`curl` `jq`
- Install with whatever package manager you use.
	
### Setup
```
git clone https://github.com/shihaamabr/bml-tg-notify.git
cd bml-tg-notify
chmod +x bml-tg-notify.sh
./bml.sh
```
- `mv env.sample .env`
- Edit the contents of .env to your config\
#### .env Sample
```
BML_USERNAME='' #Your BML Username
BML_PASSWORD='' #Your BML Password
BML_ACCOUNTID='' #Your BML Account ID, NOT ACCOUNT NUMBER!
CURRENCY='MVR' #Change if you're setting to a USD Account.
TG_BOT_TOKEN='' #Your Telegram Bot token, This can be optiained by talking to BotFather on Telegram https://t.me/BotFather
TG_CHATID='' #Your Telegram Chat ID
```
`echo XX > delay`
- where XX is the time in seconds you want to delay script run.\
- Please note that if the XX value is less than a certain value, you could get rate limited.

```
chmod +x bml-tg-notify.sh
./bml-tg-notify.sh
```

### Bugs
- You tell me :)
