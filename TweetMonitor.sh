#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/07/30
# Ver   : 1.0.0
################################
# Crolling at Twitter.
function TwCroller()
{
        for (( Z = 0; Z < ${#Account[@]}; ++Z ))
        do
	        # Set Key Word.
		KEY_WORD=''

		# Set Target Acccount.
		Target_Account=`echo ${Account[$Z]} | sed -r 's/,.{1,}//g'`

		COMMAND="tw ${Target_Account} --id "

		# Check Keyword Exist.
		if [ `echo ${Account[$Z]} | grep ',' | wc -l ` != 0 ]
		then
               		# Valid Data Exist.
                	KEY_WORD=`echo ${Account[$Z]} \
                	| cut -d , -f 2- \
                	| sed -e 's/,/\n/g' \
                	| sort -r \
                	| sed -e 's/$/,/g' \
                	| tr -d '\n' \
                	| sed -e 's/,$//' \
                	-e 's/^/,/' \
                	-e 's/,/'\'','\''/g' \
                	-e 's/$/'\''/' \
                	-e 's/,'\''#/\ egrep\ -v\ -ie\ '\''/' \
                	-e 's/'\''\ \|//' \
                	-e 's/\ egrep/\ \|\ egrep/' \
                	-e 's/,'\''#/\ -ie\ '\''/g' \
                	-e 's/^'\'',/grep\ -ie\ /' \
                	-e 's/,/\ -ie\ /g' \
                	`

			# Set KeyWord.
			COMMAND="${COMMAND} | ${KEY_WORD}"
		fi

		# Setting Command.
		COMMAND="${COMMAND}"' | grep -Eo "<[[:digit:]]{1,}>$"'
		COMMAND="${COMMAND}"' | sed '\''s/[<>]//g'\'''
		
		# Execute Command adn Set to Array at Ids.
		IDs=( `eval $COMMAND` )

		# Check ID Count.
		if [ ${#IDs[*]} -ne 0 ]
		then 
			# Execute Add Favorite.
			test 1 -eq ${FLAG_FAV} && AddFavorite

			# Execute Do ReTweet.
			test 1 -eq ${FLAG_RT} && Retweet
		fi
        done
}

# Add Favorite.
function AddFavorite()
{
	for (( X = 0; X < ${#IDs[@]}; ++X ))
	do
		tw --fav=${IDs[$X]} --yes
	done
}

# Do Retweet.
function Retweet()
{
	for (( X = 0; X < ${#IDs[@]}; ++X ))
	do
		tw --rt=${IDs[$X]} --yes
	done
}

##################
# Main Function
##################
# Path Setting
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

###### User Config ######
# Twitter Account and Keyword.
# Usage: Account,Keyword1,Keyword2..,Keyword n
Account=(
 "@AccountName1,Keyword1,Keyword2"
 "@AccountName2,Keyword1,Keyword2"
)

# Fav Flag.
# ON :1
# OFF:0
FLAG_FAV=1

# RT Flag.
# ON :1
# OFF:0
FLAG_RT=1

##### User Config #####

# Keyword.
KEY_WORD=''

# Tweet IDs.
IDs=()

# Twitter Reading.
TwCroller

