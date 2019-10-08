#!/usr/bin/env bash

# Your Telegram bot TOKEN (eg. 1234567890:AfH_shUhsjaKl3CYHxn1crI2829dIuUidm8)
TOKEN=Your_Token_Here

# List of Chat IDs to notify
CHATS_LIST=(123456789 123456789)

# Name of the Camera that has triggered the alarm
CAMERA="N/A"

# Telegram bot API endpoint to send messages
URL="https://api.telegram.org/bot${TOKEN}/sendMessage"

# Which MotionEyeOS directory to monitor for new videos
VIDEO_FOLDER=/data/output

# Find most recent MP4 video in $VIDEO_FOLDER. This is the video Motion has just created.
VIDEO=$(find ${VIDEO_FOLDER} -iname "*.mp4" -print0 | xargs -0 stat -c "%y %n" | sort -r | cut -d ' ' -f3 | head -n 1)

if [[ ! -z "${VIDEO}" ]]; then
	for CHAT_ID in ${CHATS_LIST[*]}
	do
	    CAMERA=$(echo ${VIDEO} | cut -d '/' -f4)
		curl -s -v -F "chat_id=${CHAT_ID}" \
			-F video=@${VIDEO} \
			-F caption="Motion detected in ${CAMERA}" \
			https://api.telegram.org/bot${TOKEN}/sendVideo
	done
else
	# Fallback to text message in case a video is not available
	curl -s -v -X POST $URL -d chat_id=$CHAT_ID -d text="Motion detected in ${CAMERA}, please check MotionEyeOs"
fi

# Uncomment to test Telegram's API
#curl -s -v -X POST $URL -d chat_id=$CHAT_ID -d text="Debug: $@"