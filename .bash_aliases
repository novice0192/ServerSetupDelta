alias genUser='
useracc=$1
cut -f 2 -d " " $useracc | sort -fi | uniq | awk '\''{print("sudo groupadd " $1 "; sudo useradd -m -d /home/" $1 " -g " $1 " -s /bin/bash " $1 "; sudo passwd " $1 " < defpass.txt") | "/bin/bash"}'\'';
awk '\''{print("sudo useradd -m -d /home/" $1 " -g " $2 " -s /bin/bash -c \"" $3 "|" $4 "|" $5 "\" " $1 "; sudo passwd " $1 " < defpass.txt; sudo cp Curr_Bal.txt /home/" $1 "/Current_Balance.txt; sudo chown " $1 ":" $2 " /home/" $1 "/Current_Balance.txt; sudo cp Trans_hist_user.txt /home/" $1 "/Transaction_History.txt; sudo chown " $1 ":" $2 " /home/" $1 "/Transaction_History.txt; ") | "/bin/bash"}'\'' $useracc;'

alias permit='
sudo useradd -m -d /home/OmegaCEO -s /bin/bash OmegaCEO;
sudo passwd OmegaCEO < defpass.txt;
sudo chmod -R 711 /home/OmegaCEO;
grep "Branch" /etc/passwd | cut -f1 -d: | awk '\''{print("sudo chmod -R 711 /home/" $1 "; sudo setfacl -R -m u:OmegaCEO:rx /home/" $1) | "/bin/bash"}'\'';
grep "ACC" /etc/passwd | cut -f 1,4 -d: | awk -F ":" '\''{print("sudo chmod -R 711 /home/" $1 "; sudo setfacl -R -m u:$(id -nu " $2 "):rwx /home/" $1) | "/bin/bash"}'\'';
grep "ACC" /etc/passwd | cut -f 1 -d: | awk -F ":" '\''{print("sudo setfacl -R -m u:OmegaCEO:rx /home/" $1) | "/bin/bash"}'\'';'

alias updateBranch='
grp=$(id -g $USER);
grep "ACC" /etc/passwd | grep "$grp_id" | cut -f1 -d: | awk '\''BEGIN{print("branch_bal=0") | "/bin/bash"} { print("usr_bal=$(cat /home/" $1 "/Current_Balance.txt); branch_bal=$(echo \"$branch_bal+$usr_bal\" | bc -l);") | "/bin/bash" } END {print("echo $branch_bal > $HOME/Branch_Current_Balance.txt") | "/bin/bash" }'\'';
if [[ ! -e $HOME/Branch_Transaction_History.txt ]]; then
	echo "Account-number Amount Date Time" > $HOME/Branch_Transaction_History.txt
fi
grep "ACC" /etc/passwd | grep "$grp_id" | cut -f1 -d: | awk '\''{ print("tail -n +2 /home/" $1 "/Transaction_History.txt >> $HOME/Branch_Transaction_History.txt") | "/bin/bash"}'\'';'

alias allotInterest='
intrst=100;
citizen=$(echo "$(grep "citizen" $HOME/Daily_Interest_Rates.txt | cut -f 2 -d " " | cut -f1 -d%) / 100" | bc -l);
resident=$(echo "$(grep "resident" $HOME/Daily_Interest_Rates.txt | cut -f 2 -d " " | cut -f1 -d%) / 100" | bc -l);
foreigner=$(echo "$(grep "foreigner" $HOME/Daily_Interest_Rates.txt | cut -f 2 -d " " | cut -f1 -d%) / 100" | bc -l);
snrcitizen=$(echo "$(grep "seniorCitizen" $HOME/Daily_Interest_Rates.txt | cut -f 2 -d " " | cut -f1 -d%) / 100" | bc -l);
minor=$(echo "$(grep "minor" $HOME/Daily_Interest_Rates.txt | cut -f 2 -d " " | cut -f1 -d%) / 100" | bc -l);
legacy=$(echo "$(grep "legacy" $HOME/Daily_Interest_Rates.txt | cut -f 2 -d " " | cut -f1 -d%) / 100" | bc -l);
grep "ACC" /etc/passwd | grep $(id -u $USER) | cut -f 1,5 -d ":" | awk -F ":" -v citizen="$citizen" -v resident="$resident" -v foreigner="$foreigner" -v snrcitizen="$snrcitizen" -v minor="$minor" -v legacy="$legacy" '\''{ print("cum_intr=1") | "/bin/bash" ; if ( $2 ~ /citizen/ ) { print("cum_intr=$(echo \"$cum_intr+" citizen "\" | bc -l)") | "/bin/bash" } if ( $2 ~ /resident/ ) { print("cum_intr=$(echo \"$cum_intr+" resident "\" | bc -l)") | "/bin/bash" } if ( $2 ~ /foreigner/ ) { print("cum_intr=$(echo \"$cum_intr+" foreigner "\" | bc -l)") | "/bin/bash" } if ( $2 ~ /seniorCitizen/ ) { print("cum_intr=$(echo \"$cum_intr+" snrcitizen" \" | bc -l)") | "/bin/bash" } if ( $2 ~ /minor/ ) { print("cum_intr=$(echo \"$cum_intr+" minor "\" | bc -l)") | "/bin/bash" } if ( $2 ~ /legacy/ ) { print("cum_intr=$(echo \"$cum_intr+" legacy "\" | bc -l)") | "/bin/bash" } print("net_bal=$(echo \"scale=2; $(cat /home/" $1 "/Current_Balance.txt)*$cum_intr\" | bc); echo $net_bal > /home/" $1 "/Current_Balance.txt;") | "/bin/bash" }'\'';'

alias makeTransaction='
curbal=$(cat $HOME/Current_Balance.txt);
echo "Welcome to Omega Bank";
echo "Your current balance is: $curbal";
echo "Do you wish to Withdraw(w) or Deposit(d)";
read action;
if [ "$action" == "w" ];
then
	echo "Enter amount to withdraw";
	read amount;
	if (( $(echo "$amount > 0" | bc -l) ));
	then
		bal_left=$(echo "scale=2; $curbal-$amount" | bc);

		if (( $(echo "$curbal > $amount" | bc -l) ));
		then
			echo $bal_left > $HOME/Current_Balance.txt;
			echo "$USER -$amount $(date +%F) $(date +%T)" >> $HOME/Transaction_History.txt;
		else
			echo "Insufficient balance";
		fi;
	else
		echo "Enter positive amount";
	fi;
elif [ "$action" == "d" ];
then
	echo "Enter amount to deposit";
	read amount;
	bal_left=$(echo "scale=2; $curbal+$amount" | bc);
	if (( $(echo "$amount > 0" | bc -l) ));
	then
		echo $bal_left > $HOME/Current_Balance.txt;
		echo "$USER +$amount $(date +%F) $(date +%T)" >> $HOME/Transaction_History.txt;
	else
		echo "Enter positive amount";
	fi;
else
	echo "Invalid option";
fi;'



