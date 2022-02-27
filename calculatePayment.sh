#!/bin/bash



if (( $#>=2 ));
then
    amount=${@: -1}
    if [[ $amount =~ ^[+]?[0-9]+\.?[0-9]*$ ]];
    then
    	fileProblem="no"
    	for (( i=1; i < "$#"; i++ ));
    	do
    		if [[ "${!i}" = /* ]];
    		then
    			path="${!i}"
    		else
    			d=`pwd`
    			path="$d/${!i}"
    		fi
    		if [[ ! -e $path  || ! -f $path ]];
    		then
    			>&2 printf "File does not exist : %s\n" ${!i}
    			fileProblem="yes"
    		fi
	done
	if [[ "$fileProblem" = "no" ]];
	then
		IFS=$'\n'
		sum=0
		for (( i=1; i < "$#"; i++ ));
		do
			if [[ "${!i}" = /* ]];
    			then
    				path="${!i}"
    			else
    				d=`pwd`
    				path="$d/${!i}"
    			fi
    			for line in `cat $path`
    			do
    				curCost=$(echo $line | grep -o -E '[0-9]+\.?[0-9]*')
    				if [[ ! $curCost = "" ]];
				then
					sum=$(bc -l <<< "${sum}+${curCost}")
				fi
    			done
		done
		printf "Total purchase price : %.2f\n" $sum
		if (( $(echo "$amount > $sum" |bc -l) ));
		then
			difference=$(bc -l <<< "${amount}-${sum}")
			printf "Your change is %.2f shekel\n" $difference
		elif (( $(echo "$sum > $amount" |bc -l) ));
		then
			difference=$(bc -l <<< "${sum}-${amount}")
			printf "You need to add %.2f shekel to pay the bill\n" $difference
		else
			printf "Exact payment\n"
		fi
	else
		printf "Usage : calculatePayment.sh <valid_file_name> [More_Files] ... <money>\n"
		exit
	fi
    else
    	>&2 printf "Not a valid number : %s\n" $amount
    	printf "Usage : calculatePayment.sh <valid_file_name> [More_Files] ... <money>\n"
    	exit
    fi
else
    >&2 printf "Number of parameters received : %d\n" $#
    printf "Usage : calculatePayment.sh <valid_file_name> [More_Files] ... <money>\n"
    exit
fi
