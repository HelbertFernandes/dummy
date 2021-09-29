# . /fullPath/hilanderProcess.sh

ps -C `basename $0` | awk '{print $1}' | sed "1d;/^$$\$/d" | xargs kill -9 2> /dev/null
