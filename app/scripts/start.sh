## Start script
yarn install --check-files
tor & sleep 10
echo "Onion address: $(cat /root/data/tor/hostname)"
node --es-module-specifier-resolution=node --no-warnings app.js