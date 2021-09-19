#!/bin/bash
source .env # import credentials, tg api, cookie path, bml api


init(){
if [ ! -f delay ] # if delay file missing
then
	echo 160 > delay # make delay file with 160 sec
fi
}

login(){
echo ""
echo ""
echo ===========
echo LOGGING IN
curl -s -c $COOKIE $BML_URL/login --data-raw username=$BML_USERNAME --data-raw password=${BML_PASSWORD}  # attempt to login and generate cookie
echo ""
echo ""
echo ===========
echo SELECTING PROFILE
PROFILE=$(curl -s -b $COOKIE $BML_URL/profile | jq -r '.payload | .profile | .[] | .profile' | head -n 1) ; echo $PROFILE # get Personal Profile
curl -s -b $COOKIE $BML_URL/profile --data-raw profile=$PROFILE  # select Personal Profile
echo ""
echo ""
}

getnumberofaccounts(){
NUMBEROFACCOUNTS=$(cat .env | grep BML_ACCOUNTID | cut --complement -d "'" -f 1 |  cut -f1 -d "'" | wc -l)
NUMBEROFACCOUNTS=$(expr $NUMBEROFACCOUNTS - 1)
echo ""
echo $NUMBEROFACCOUNTS Accounts loaded
}

getaccountdetails(){
REQACCOUNTDETAILS=$(curl -s -b $COOKIE $BML_URL/account/$BML_ACCOUNTID | jq -r .payload)
ACCOUNTTYPE=$(echo $REQACCOUNTDETAILS | jq -r .product)
ACCOUNTNUMBER=$(echo $REQACCOUNTDETAILS | jq -r .accountNumber)
CURRENCY=$(echo $REQACCOUNTDETAILS | jq -r .currency)
}

send_tg(){
TGTEXT=$(echo $ACCOUNTTYPE%0A$ACCOUNTNUMBER%0A%0A$DESCRIPTION%0A$FROMTOAT: $ENTITY%0A$CURRENCY: $AMOUNT | sed "s/ /%20/g") ; echo $TGTEXT # format text for telegram
echo ""
echo ""
echo SENDING TO TG

curl -s $TG_BOTAPI$TG_BOT_TOKEN/sendMessage?chat_id=$TG_CHATID'&'text=$TGTEXT  #send to telegram
echo ""
echo ""

}

req_history(){
echo ""
echo ""
echo ===========
echo Requesting History for: $BML_ACCOUNTID
REQ_HISTORY=$(curl -s -b $COOKIE $BML_URL/account/$BML_ACCOUNTID/history/today) ; echo $REQ_HISTORY
#LOGIN_STATUS=$(echo $REQ_HISTORY | jq -r .success) ; echo $LOGIN_STATUS
echo ""
echo ""
echo ===========

}

check_diff(){
CHECKDIFF1=$(echo $HISTORY | wc -c) ; echo $CHECKDIFF1 # check intial and previous history
#HISTORY=$(curl -s -b $COOKIE $BML_URL/account/$BML_ACCOUNTID/history/today | jq -r '.payload | .history | .[]') ; echo $HISTORY # request history
HISTORY=$(echo $REQ_HISTORY | jq -r '.payload | .history | .[]') ; echo $HISTORY
CHECKDIFF2=$(echo $HISTORY | wc -c) ; echo $CHECKDIFF2 # check new history
}

read_delay(){
DELAY=$(cat delay) ; echo $DELAY # read delay file and get value
}


init
login
loop(){
i=0
#	if [ "$LOGIN_STATUS" != "true" ]
#	then
#		echo ""
#		echo ""
#		echo " LOGGED OUT - SLEEPING
#		sleep 200
#	        login
#	        infinite_loop
#	fi

	for account in `cat .env | grep BML_ACCOUNTID | cut --complement -d "'" -f 1 |  cut -f1 -d "'"`
	do
        	accountid[$i]=$account;
		i=$(($i+1));
		BML_ACCOUNTID=$(cat .env | grep BML_ACCOUNTID | cut --complement -d "'" -f 1 |  cut -f1 -d "'" | head -n$i | tail -n1)
		echo ""
		echo $BML_ACCOUNTID Selected
		echo ""
		getaccountdetails
		req_history
		check_diff
		read_delay

if [ "$CHECKDIFF1" != "$CHECKDIFF2" ] # if previous history do not match with new history
then
	if [ "$CHECKDIFF2" = "1" ]
	then
		echo "=============" ; echo NEW DAY ; echo "============="
		# curl -s $TG_BOTAPI$TG_BOT_TOKEN/sendMessage?chat_id=$TG_CHATID'&'text=GO%20TO%20SLEEP%0AITS%0000
	else
		echo ""
		echo ""
		echo ==============
		echo History of $ACCOUNTTYPE - $ACCOUNTNUMBER
		echo $HISTORY | jq
		echo ""
		echo ""
		DESCRIPTION=$(echo $HISTORY | jq -r .description | head -n1) ; echo $DESCRIPTION # get last trascation description
		AMOUNT=$(echo $HISTORY | jq -r .amount | head -n1) ; echo $AMOUNT # get last trascation amount
		if [ "$DESCRIPTION" = "Transfer Credit" ] # if last trascation is description is Transfer Credit
		then
			FROMTOAT=From
			ENTITY=$(echo $HISTORY | jq -r .narrative3 | head -n1) ; echo $ENTITY # get last persona or place name
		elif [ "$DESCRIPTION" = "Transfer Debit" ] # if last trascation descripton is Transfer Debit
		then
			FROMTOAT=To
			ENTITY=$(echo $HISTORY | jq -r .narrative3 | head -n1) ; echo $ENTITY # get last person or place name
		elif [ "$DESCRIPTION" = "Cash Deposit-ATM" ] || [ "$DESCRIPTION" = "ATM Withdrawal" ] || [ "$DESCRIPTION" = "Purchase" ] # if last trascation descripton is ATM Withdrawal
		then
			FROMTOAT=At
			ENTITY=$(echo $HISTORY | jq -r .narrative3 | head -n1) ; echo $ENTITY #get last ATM name
		elif [ "$DESCRIPTION" = "Salary" ] # if last trascation descripton is Salary
		then
			FROMTOAT=From
			ENTITY=$(echo $HISTORY | jq -r .narrative2 | head -n1) ; echo $ENTITY # get last trascation company name
		fi
		send_tg
	fi
else
	echo  "Nothing new....Next check in $DELAY seconds"
fi
done
}

infinite_loop(){
while true; do
	loop
	sleep $DELAY # initiate delay read from delay file
done
}
infinite_loop
