#!/bin/bash

tabbyVersion=1.0.187

#dnf
# echo 'defaultyes=True' >> /etc/dnf/dnf.conf

# fish
if test -f "/usr/bin/fish" ; then
    echo "fish is already installed"
else 
sudo dnf -y install fish
sudo chsh -s /usr/bin/fish

#oh-my-fish
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

#fisher
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

#nvm
fisher install jorgebucaran/nvm.fish
fi

# docker
sudo dnf -y install dnf-plugins-core
sudo dnf -y config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo newgrp docker

#docker-compose
sudo dnf -y install docker-compose
 
# kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo yum install -y kubectl

#tabby 
wget https://github.com/Eugeny/tabby/releases/download/v1.0.187/tabby-$tabbyVersion-linux-x64.rpm
sudo rpm -i tabby-$tabbyVersion-linux-x64.rpm
rm tabby-$tabbyVersion-linux-x64.rpm
