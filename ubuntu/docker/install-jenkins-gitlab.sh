#!/bin/bash
#sudo apt-get install curl
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates gnupg-agent software-properties-common
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose
