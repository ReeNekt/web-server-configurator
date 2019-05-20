#!/bin/bash

clear

# replaces windows's new line chars to linux's new line chars
cat lamp-installer-windows.sh | tr -d '\r' > lamp-installer-linux.sh

chmod 0777 ./lamp-installer-linux.sh

# run lunix version script
./lamp-installer-linux.sh
