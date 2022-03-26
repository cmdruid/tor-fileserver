## Start script
LOGFILE="/tmp/tor.log"

# Install dependencies if not present
yarn install --check-files

# Initialize Tor
echo "Starting Tor server..."
pkill tor
tor > $LOGFILE & TORPID=$!

# Wait for Tor to load, then start node.
tail -fn0 $LOGFILE | while read line; do
  echo "$line" | grep "Bootstrapped 100%"
  if [ $? = 0 ]; then
    echo "onion address: $(cat /root/data/tor/hostname)"
    node --es-module-specifier-resolution=node --no-warnings app.js
  fi
done