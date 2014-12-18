echo "Creating the logs directory"
logDir="$(pwd)/logs"
mkdir $logDir

echo "Starting the coffee-script in forever"
forever stop -c coffee src/app.coffee
forever start -l $logDir/forever.log -o $logDir/console.log -e $logDir/error.log -c coffee src/app.coffee