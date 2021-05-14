#!/bin/bash
source .env # import credentials, tg api, cookie path, bml api

if [ ! -f delay ] # if delay file missing
then
	echo 160 > delay # make delay file with 160 sec
fi

while true; do

LOGIN=$(curl -s -c $COOKIE $BML_URL/login --data-raw username=$BML_USERNAME --data-raw password=${BML_PASSWORD} | jq -r .code) # attempt to login and generate cookie

if [ "$LOGIN" = "0" ] # if Login success
then
	PROFILE=$(curl -s -b $COOKIE $BML_URL/profile | jq -r '.payload | .profile | .[] | .profile' | head -n 1) # get Personal Profile
	curl -s -b $COOKIE $BML_URL/profile --data-raw profile=$PROFILE > /dev/null # select Personal Profile
else # if login failed
	echo 'Something went wrong..'
	echo ""
	echo '"Code: 2" means your username or password is incorrect, Please check .env to see if theyre entered correctly'
	echo '"Code: 20" means your account is locked, Please reset password from "https://www.bankofmaldives.com.mv/internetbanking/forgot_password"'
	echo ""
	echo Code: $LOGIN # show error code
	echo 'Run "curl https://www.bankofmaldives.com.mv/" and see if you get "Error code 1020", if you do this means your IP blocked'
	echo 'exiting...'
	exit # close
fi

CHECKDIFF1=$(echo $HISTORY | wc -c) # check intial and previous history
HISTORY=$(curl -s -b $COOKIE $BML_URL/account/$BML_ACCOUNTID/history/today | jq -r '.payload | .history | .[]') # request history
CHECKDIFF2=$(echo $HISTORY | wc -c) # check new history
DELAY=$(cat delay) # read delay file and get value

if [ "$CHECKDIFF1" != "$CHECKDIFF2" ] # if previous history do not match with new history
then
	DESCRIPTION=$(echo $HISTORY | jq -r .description | head -n1) # get last trascation description
	AMOUNT=$(echo $HISTORY | jq -r .amount | head -n1) # get last trascation amount
	if [ "$DESCRIPTION" = "Transfer Credit" ] # if last trascation is description is Transfer Credit
	then
		FROMTOAT=From
		ENTITY=$(echo $HISTORY | jq -r .narrative3 | head -n1) # get last persona or place name
	elif [ "$DESCRIPTION" = "Transfer Debit" ] # if last trascation descripton is Transfer Debit
	then
		FROMTOAT=To
		ENTITY=$(echo $HISTORY | jq -r .narrative3 | head -n1) # get last person or place name
	elif [ "$DESCRIPTION" = "ATM Withdrawal" ] # if last trascation descripton is ATM Withdrawal
	then
		FROMTOAT=At
		ENTITY=$(echo $HISTORY | jq -r .narrative3 | head -n1) #get last ATM name
	elif [ "$DESCRIPTION" = "Purchase" ]
	then
		FROMTOAT=At
		ENTITY=$(echo $HISTORY | jq -r .narrative3 | head -n1)
	elif [ "$DESCRIPTION" = "Salary" ] # if last trascation descripton is Salary
	then
		FROMTOAT=From
		ENTITY=$(echo $HISTORY | jq -r .narrative2 | head -n1) # get last trascation company name
	fi
	echo $DESCRIPTION
	echo $FROMTOAT: $ENTITY
	echo $CURRENCY: $AMOUNT
	TGTEXT=$(echo $DESCRIPTION%0A$FROMTOAT:%20$ENTITY%0A$CURRENCY:%20$AMOUNT | sed "s/ /%20/g") # format text for telegram
	curl -s $TG_BOTAPI$TG_BOT_TOKEN/sendMessage?chat_id=$TG_CHATID'&'text=$TGTEXT > /dev/null #send to telegram
	echo "Next check in $DELAY seconds"
else
	echo "nothing new..checking again in $DELAY seconds"
fi

sleep $DELAY # initiate delay read from delay file

done
