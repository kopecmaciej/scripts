#!/bin/bash

tabbyVersion=1.0.187
slackVersion=4.29.149
sopsVersion=3.7.3
goVersion=1.19.4

#dnf
if cat /etc/dnf/dnf.conf | grep -q "defaultyes=True"; then
    echo "defaultyes is already enabled"
else
    echo 'defaultyes=True' >>/etc/dnf/dnf.conf
fi

#flatpak
if test -f "/usr/bin/flatpak"; then
    echo "flatpak is already installed"
else
    sudo dnf -y install flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

if test -f "/urs/local/bin/mkcert"; then
    curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
    chmod +x mkcert-v*-linux-amd64
    sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert
    rm mkcert-v*-linux-amd64
fi

# fish
if test -f "/usr/bin/fish"; then
    echo "fish is already installed"
else
    sudo dnf -y install fish
    sudo chsh -s /usr/bin/fish
    #oh-my-fish
    echo "
        run follow command manually:
        curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
        curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
        fisher install edc/bass
        fisher install jorgebucaran/nvm.fish
    "
fi

# docker
if test -f "/usr/bin/docker"; then
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
if test -f "/usr/bin/docker-compose"; then
    echo "docker-compose is already installed"
else
    sudo dnf -y install docker-compose
fi

# kubectl
if test -f "/usr/bin/kubectl"; then
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

#k9s
if test -f "/home/cieju/.local/bin/k9s"; then
    echo "k9s is already installed"
else
    curl -sS https://webinstall.dev/k9s | bash
    fish -c "source ~/.config/envman/PATH.env"
fi

#helm
if test -f "/usr/bin/helm"; then
    echo "helm is already installed"
else
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    helm plugin install https://github.com/databus23/helm-diff
fi

#tabby
if test -f "/usr/bin/tabby"; then
    echo "tabby is already installed"
else
    wget https://github.com/Eugeny/tabby/releases/download/v1.0.187/tabby-$tabbyVersion-linux-x64.rpm
    sudo rpm -i tabby-$tabbyVersion-linux-x64.rpm
    rm tabby-$tabbyVersion-linux-x64.rpm
fi

#neovim
if test -f "/usr/bin/nvim"; then
    echo "neovim is already installed"
else
    sudo dnf -y install neovim
    sudo dnf -y install ripgrep
    sudo yum -y install gcc-c++

fi

#go
if test -e "/usr/local/go/bin"; then
    echo "go is already installed"
else
    wget https://go.dev/dl/go$goVersion.linux-amd64.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xzf go$goVersion.linux-amd64.tar.gz
    fish -c "fish_add_path /usr/local/go/bin"
    set -xU GOPATH $HOME/go
fi

#aws
if test -e "/usr/local/bin/aws"; then
    echo "aws is already installed"
else
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    sudo rm -rf awscliv2.zip aws
fi

#gcloud
if test -e "/usr/local/google-cloud-sdk"; then
    echo "gcloud is already installed"
else
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-412.0.0-linux-x86_64.tar.gz
    tar -xf google-cloud-cli-412.0.0-linux-x86_64.tar.gz
    mv google-cloud-sdk /usr/local/
    /usr/local/google-cloud-sdk/install.sh
fi

#sops
if test -f "/usr/local/bin/sops"; then
    echo "sops is already installed"
else
    wget https://github.com/mozilla/sops/releases/download/v$sopsVersion/sops-$sopsVersion-1.x86_64.rpm
    sudo rpm -i sops-$sopsVersion-1.x86_64.rpm
    rm sops-$sopsVersion-1.x86_64.rpm
fi

### Browsers

# brave
if test -f "/usr/bin/brave-browser"; then
    echo "brave is already installed"
else
    sudo dnf -y install dnf-plugins-core
    sudo dnf -y config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    sudo dnf -y install brave-browser
fi

# slack
if test -f "/usr/bin/slack"; then
    echo "slack is already installed"
else
    wget https://downloads.slack-edge.com/releases/linux/$slackVersion/prod/x64/slack-$slackVersion-0.1.el8.x86_64.rpm
    sudo dnf -y install libappindicator-gtk3
    sudo rpm -i slack-$slackVersion-0.1.el8.x86_64.rpm
    rm slack-$slackVersion-0.1.el8.x86_64.rpm
fi

#droid sans mono nerd font
if test -e "/usr/share/fonts/droid-sans-mono-nerd-font"; then
    echo "droid sans mono nerd font is already installed"
else
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/DroidSansMono.zip
    sudo mkdir /usr/share/fonts/droid-sans-mono-nerd-font
    unzip -d DroidSansMono DroidSansMono.zip
    sudo mv DroidSansMono/* /usr/share/fonts/droid-sans-mono-nerd-font
    fc-cache -f
    rm -rf DroidSansMono.zip DroidSansMono
fi

flatpakDir=/var/lib/flatpak/exports/share/applications

#discord
if ls $flatpakDir | grep -q "discord"; then
    echo "discord is already installed"
else
    flatpak install discord
fi

#spotify
if ls $flatpakDir | grep -q "spotify"; then
    echo "spotify is already installed"
else
    sudo flatpak install flathub com.spotify.Client
fi

#fedora-view
if gsettings get org.gnome.desktop.wm.preferences button-layout | grep -q "appmenu"; then
    echo "fedora-view is already installed"
else
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
fi
