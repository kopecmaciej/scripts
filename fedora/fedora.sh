#!/bin/bash

tabbyVersion=1.0.187

#dnf
if cat /etc/dnf/dnf.conf | grep -q "defaultyes=True" ; then
    echo "defaultyes is already enabled"
else
echo 'defaultyes=True' >> /etc/dnf/dnf.conf
fi

# fish
if test -f "/usr/bin/fish" ; then
    echo "fish is already installed"
else 
sudo dnf -y install fish
sudo chsh -s /usr/bin/fish

#oh-my-fish
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install

#fisher
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

#bass
fisher install edc/bass

#nvm
fisher install jorgebucaran/nvm.fish
fi

# docker
if test -f "/usr/bin/docker" ; then
    echo "docker is already installed"
else
sudo dnf -y install dnf-plugins-core
sudo dnf -y config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo newgrp docker
fi

#docker-compose
if test -f "/usr/bin/docker-compose" ; then
    echo "docker-compose is already installed"
else
sudo dnf -y install docker-compose
fi

# kubectl
if test -f "/usr/bin/kubectl" ; then
    echo "kubectl is already installed"
else
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo yum install -y kubectl
fi

#tabby 
if test -f "/usr/bin/tabby" ; then
    echo "tabby is already installed"
else
wget https://github.com/Eugeny/tabby/releases/download/v1.0.187/tabby-$tabbyVersion-linux-x64.rpm
sudo rpm -i tabby-$tabbyVersion-linux-x64.rpm
rm tabby-$tabbyVersion-linux-x64.rpm
fi

### Browsers

# brave

if test -f "/usr/bin/brave-browser" ; then
    echo "brave is already installed"
else
sudo dnf -y install dnf-plugins-core
sudo dnf -y config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf -y install brave-browser
fi
