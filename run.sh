#!/usr/bin/env bash
########################################
#  Simple Telegram bot for shell scripting
########################################
#
#  Author: Facundo Montero <facumo.fm@gmail.com>
#
########################################
#
# Depends on: GNU minimal toolkit (curl).
#
########################################

# Configuration
# Your bot's API key.
#api_key='123123123:aaaabbbb...'
# Allowed chat IDs
#allowed_chat_ids=('987654321' '123456789')

# Crash if the user forgot to set the variables above.
if [ -z "$api_key" ] || [ -z "$allowed_chat_ids" ]
then
 echo 'Both the API key and allowed chat IDs must be set before running this script.'
 exit 1
fi

# Functions
function sendMessage
{
 curl -s "https://api.telegram.org/bot""$api_key""/sendMessage" -d "{ \"chat_id\":\"$chat_id\", \"text\":\"$1\", \"parse_mode\":\"markdown\"}" -H "Content-Type: application/json" 2>&1 > /dev/null
}

# Main
LAST=""
printf '\n'
while true
do
 LAST=$(curl -s "https://api.telegram.org/bot""$api_key""/getUpdates" -F offset=$(( $LUID + 1 )))
 LCID=$(echo "$LAST" | tail -1 | cut -d ':' -f 12 | cut -d ',' -f 1)
 LMSG=$(echo "$LAST" | sed 's/text/\ntext/' | tail -1 | cut -d '"' -f 3)
 printf "$(date '+%d-%m-%y / %H:%S')"': '
 LUID=$(echo "$LAST" | grep update_id)
 if [ "$?" -eq 0 ]
 then
  LUID=$(echo "$LUID" | head -1 | cut -d ':' -f 4 | cut -d ',' -f 1)
  printf "Update #""$(( $LUID + 1 )). "
  for chat_id in ${allowed_chat_ids[@]}
  do
    if [ "$chat_id" -eq "$LCID" ]
    then
       ALLOWED=1
    fi
  done
  if [ "$ALLOWED" -eq 1 ]
  then
   DISPLAY="\n-> Will now run '$LMSG'...\nWaiting for the child process to die...\n"
   printf "$DISPLAY"
   sendMessage "$DISPLAY"
   OUTPUT=$($LMSG 2>&1)
   echo "$OUTPUT" |
   while read l
   do
      printf "\n\r- Sending '$l'."
      sendMessage "$l"
   done
   printf '\n'
  else
   OUTPUT="You're not authorized to use this bot."
   sendMessage "$OUTPUT"
  fi
 else
  printf "no updates found."
 fi
 printf '\n'
done
