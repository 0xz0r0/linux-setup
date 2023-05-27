#!/bin/bash

RED='\033[0;31m';
NC='\033[0m'; # No Color
GREEN='\033[0;32m';
YELLOW='\033[1;33m';

delay_after_message=3;

if (( $EUID != 0 )); then
    echo "This script must be run with sudo (sudo -i)" 
    exit 1
fi

read -p "Please enter your username: " target_user;

if id -u "$target_user" >/dev/null 2>&1; then
    echo "User $target_user exists! Proceeding.. ";
else
    echo 'The username you entered does not seem to exist.';
    exit 1;
fi


# function to run command as non-root user
run_as_user() {
	sudo -u $target_user bash -c "$1";
}


apt update && apt -y upgrade
apt install -y wget git curl nfs-common preload
clear;
# Install chrome
printf "${YELLOW}Installing Chrome and brave browsers!${NC}\n";
sleep $delay_after_message;
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
clear;
# Install Brave
apt install -y apt-transport-https curl
clear;
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|tee /etc/apt/sources.list.d/brave-browser-release.list
apt update && apt install -y brave-browser


# Install zsh ohMyZsh
apt install -y zsh
clear;
printf "${YELLOW}Installing Zsh and Oh My Zsh!${NC}\n";
sleep $delay_after_message;
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# Install fonts
#Setting up Powerline
printf "${YELLOW}Installing and Setting up Powerline and Powerline Fonts${NC}\n";
sleep $delay_after_message;
apt-get install powerline -y
run_as_user "mkdir -p /home/${target_user}/.fonts";
run_as_user "cp powerline-fonts/* /home/${target_user}/.fonts/";
# Install powerlevel10k
run_as_user "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/${target_user}/.oh-my-zsh/custom/themes/powerlevel10k";
run_as_user "sed -i 's/robbyrussell/powerlevel10k\/powerlevel10k/' /home/${target_user}/.zshrc";

# Install Code
clear;
printf "${YELLOW}Installing VS Code${NC}\n";
sleep $delay_after_message;
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg;
mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg;
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list';
apt-get update && apt-get -y install code;


# Install docker
clear;
printf "${YELLOW}Installing Docker ${NC}\n";
sleep $delay_after_message;
apt install docker.io -y
systemctl enable --now docker
usermod -aG docker $target_user;
clear;

# Install extensions and tweaks
add-apt-repository universe -y
printf "${YELLOW}Installing Gnome tweaks and shell extension!${NC}\n";
sleep $delay_after_message;
apt install -y gnome-tweaks
apt-get install -y gnome-shell-extension-manager chrome-gnome-shell
clear;

# stacer
printf "${YELLOW}Installing stacer.. ${NC}\n";
sleep $delay_after_message;
apt install stacer -y;
clear;

#Install z.lua
printf "${YELLOW}Setting up z.lua${NC}\n";
sleep $delay_after_message;
apt install lua5.1 -y
run_as_user "mkdir ~/scripts && cd ~/scripts";
run_as_user "git clone --depth=1 https://github.com/skywind3000/z.lua";
run_as_user "mv z.lua /home/${target_user}/.z-lua";
run_as_user "eval '\$(lua /home/${target_user}/.z-lua/z.lua --init zsh)' >> /home/${target_user}/.zshrc";
clear;

#lm-sensors
printf "${YELLOW}Installing lm-sensors${NC}\n";
sleep $delay_after_message
apt install lm-sensors -y
sensors-detect --auto


#Change Theme to WhiteSur Dark
printf "${YELLOW}Installing WhiteSur-dark theme${NC}\n";
sleep $delay_after_message;
run_as_user "unzip Mojave-Dark.zip -d /home/${target_user}/.themes/";
run_as_user "unzip WhiteSur-icons-patched.zip -d /home/${target_user}/.icons/";
printf "${YELLOW}WhiteSur was installed, but for better results, download the User Themes gnome extension and use the tweak tool to change shell theme to WhiteSur as well.${NC}\n";
sleep $delay_after_message;



# Clean
# Remove thunderbird
printf "${RED}Removing thunderbird completely${NC}\n";
sleep $delay_after_message;
apt-get purge thunderbird -y

printf "${YELLOW}Cleaning system!${NC}\n";
sleep $delay_after_message;
apt-get autoclean -y && apt-get autoremove -y && apt-get clean -y;
clear;

printf "${GREEN}Basic settings done${NC}\n";
sleep 5;

echo "Run chsh -s $(which zsh) to make zsh your default shell"
echo "Open ~/.zshrc and add the plugin to the list of plugins for Oh My Zsh to load inside of ~/.zshrc  like plugins=(git zsh-autosuggestions)"

