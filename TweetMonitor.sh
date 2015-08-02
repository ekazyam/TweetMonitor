#!/bin/bash
################################
# Author: Rum Coke
# Data  : 2015/08/02
# Ver   : 1.2.0
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
			test 1 -eq ${FLAG_FAV} && echo ${IDs[@]} | sed 's/ /\n/g' | xargs -P${MAX_P} -n1 -I % bash -c "AddFavorite %"

			# Execute Do ReTweet.
			test 1 -eq ${FLAG_RT} && echo ${IDs[@]} | sed 's/ /\n/g' | xargs -P${MAX_P} -n1 -I % bash -c "Retweet %"

			# Execute Do RePly.
			test 1 -eq ${FLAG_RP} && echo ${IDs[@]} | sed 's/ /\n/g' | xargs -P${MAX_P} -n1 -I % bash -c "RePly %"
		fi
        done
}

# Add Favorite.
function AddFavorite()
{
	tw --fav=${1} --yes > /dev/null 2>&1
}

# Do Retweet.
function Retweet()
{
	tw --rt=${1} --yes > /dev/null 2>&1
}

# Do Reply.
function RePly()
{
	tw "${RT_WORD}" --id={1} --yes > /dev/null 2>&1
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
 "@hogehoge,Linux,Mac,Windows"
)

# Fav Flag.
# ON :1
# OFF:0
FLAG_FAV=1

# RT Flag.
# ON :1
# OFF:0
FLAG_RT=0

# RP Flag.
# ON :1
# OFF:0
FLAG_RP=0

# Max Parallel Process.
MAX_P=8

##### User Config #####

# Keyword.
KEY_WORD=''

# Tweet IDs.
IDs=()

# Rt word.
RT_WORD="I think so too."

# Export Data.
export PATH FLAG_FAV FLAG_RT FLAG_RP Account KEY_WORD IDs RT_WORD MAX_P

# Export Function.
export -f TwCroller AddFavorite Retweet RePly

# Twitter Reading.
TwCroller

