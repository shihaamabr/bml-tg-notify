# BML-TG-NOTIFY
## Push Notification BML Transcations to Telegram

### Requriements
`curl` `jq`
- Install with whatever package manager you use.

### There's catch! 
- BML do NOT allow you to be logged in more than 1 device at a time, 
So when this script runs and if you were using Mobile App or Website you will be logged out!
Which is why I have added a delay to change how often script logs into account and check for new transactions, 
This can be configured when you set up. You either get fast notification but with less time to use app to do whatever you do 
OR take as much as time you want to use app but slow notifications.

### Is it safe?
- Probably, I will NOT take resposibilty to whatever you do with this script, 
Understand how this works before proceeding. Your BML Username and Password will be saved in PLAIN TEXT! 
Anyone who has access (or gains access) to your server or computer can read .env file and optain your BML login credentials! 

### Limitations
- At the moment this script can only check 1 account from personal profile.

### Setup
```
git clone https://github.com/shihaamabr/bml-tg-notify.git
cd bml-tg-notify
chmod +x bml-tg-notify.sh
cp env.sample .env
```
- Edit the contents of .env to your config with text editor of your choosing (`nano .env`)\
- [How to obtain BML_ACCOUNTID](https://raw.githubusercontent.com/shihaamabr/bml-tg-notify/main/how-to-get-BML_ACCOUNTID.png){:target="_blank"}
- Optionally edit delay `echo XX > delay` where XX is the time in seconds you want to delay script run, 
By default this is set to 160. Please note that if the XX value is less than a certain value
your IP could blocked by CloudFlare for DoS attack.
```
./bml-tg-notify.sh
```

### Bugs
- You tell me :)
