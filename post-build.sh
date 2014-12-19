echo "Creating the logs directory"

logDir="$(pwd)/logs"
if [ ! -d $logDir ]; then
  mkdir $logDir
fi

foreverLogDir="$(pwd)/forever-logs"
if [ -d $foreverLogDir ]; then
  rm -rf $foreverLogDir
fi
mkdir $foreverLogDir

echo "Starting the coffee-script in forever"
forever stop -c coffee src/app.coffee
forever start -l $foreverLogDir/forever.log -o $foreverLogDir/console.log -e $foreverLogDir/error.log -c coffee src/app.coffee
