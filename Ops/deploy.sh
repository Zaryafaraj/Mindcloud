#!/bin/bash
clear
echo "Starting to deploy .... hold tight ...."
sudo ./s3cmd/s3cmd sync ./../web/ s3://mindcloud.io
echo "\n\n============================================"
echo "Deploy Done go eat a banana ..."
