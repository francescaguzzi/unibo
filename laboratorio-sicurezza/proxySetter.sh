#!/bin/bash

# Controllo del numero di argomenti
if [ $# -ne 1 ]; then
  echo "Utilizzo: $0 <numero>"
  exit 1
fi

numero=$1
ip="192.168.12${numero}.249:8080"

# Modifica di /etc/apt/apt.conf.d/proxy.conf
sudo sed -i "s|Acquire::http::Proxy.*|Acquire::http::Proxy \"http://${ip}/\";|" /etc/apt/apt.conf.d/proxy.conf
sudo sed -i "s|Acquire::https::Proxy.*|Acquire::https::Proxy \"http://${ip}/\";|" /etc/apt/apt.conf.d/proxy.conf

# Modifica di ~/.bashrc
sed -i "s|export http_proxy.*|export http_proxy=\"http://${ip}\"|" ~/.bashrc
sed -i "s|export https_proxy.*|export https_proxy=\"http://${ip}\"|" ~/.bashrc
sed -i "s|export HTTP_PROXY.*|export HTTP_PROXY=\"http://${ip}\"|" ~/.bashrc
sed -i "s|export HTTPS_PROXY.*|export HTTPS_PROXY=\"http://${ip}\"|" ~/.bashrc

# Modifica di ~/.zshrc
sed -i "s|export http_proxy.*|export http_proxy=\"http://${ip}\"|" ~/.zshrc
sed -i "s|export https_proxy.*|export https_proxy=\"http://${ip}\"|" ~/.zshrc
sed -i "s|export HTTP_PROXY.*|export HTTP_PROXY=\"http://${ip}\"|" ~/.zshrc
sed -i "s|export HTTPS_PROXY.*|export HTTPS_PROXY=\"http://${ip}\"|" ~/.zshrc

echo "Le impostazioni dei proxy sono state aggiornate con successo!"

