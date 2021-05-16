# BML-TG-NOTIFY
## Push Notification BML Transcations to Telegram
![bml-notify-screenshot.jpg](bml-notify-screenshot.jpg)

## Is it safe?
- Probably, I will NOT take resposibilty to whatever you do with this script. [See More](LICENSE)
- Your BML Username and Password will be saved in PLAIN TEXT!
Anyone who has access (or gains access) to your server or computer can read .env file and obtain your BML login credentials!

## Limitations
- At the moment this script can only check 1 account from personal profile.
- Script ONLY sends notification for last transaction, so if there more than 1 transacation 
when script checks for new transactions you will get notification for the last one only.
### There's catch!
- BML do NOT allow you to be logged in more than 1 session at a time,
so when this script runs and if you were using mobile app or website you will be logged out!
- You either get fast notification but with less time to use app 
OR take as much as time you want to use app but slow notifications.
Which is why I have added a delay to change how often script logs into account,
This can be delay can be configured later. [See how](#setting-delay---optional)

## Getting started. 
### Requriements
`curl` `jq`
- Install with whatever package manager you use.
- Make SURE they are installed before continuing!
### Clone repo and Configure
```
git clone https://github.com/shihaamabr/bml-tg-notify.git
cd bml-tg-notify
chmod +x bml-tg-notify.sh
cp env.sample .env
```
- Edit the contents of .env to your config (`nano .env`)
- [How to obtain BML_ACCOUNTID](https://raw.githubusercontent.com/shihaamabr/bml-tg-notify/main/how-to-obtain-BML_ACCOUNTID.png)
### Execute the script
```
./bml-tg-notify.sh
```
- Maybe run in a screen to run in background?
## Setting Delay - Optional Configration
In a different terminal seession run `echo XX > delay` where XX is the time in seconds you want to delay script logs into account [See why](#theres-catch)
### Notes
- Default value is 160.
- If the XX value is less than a certain value (I think 15) your IP could get blocked by CloudFlare for DoS attack.
- You do not need to restart script after changing delay.

## Bugs
- [You tell me :)](https://github.com/shihaamabr/bml-tg-notify/issues/new)
