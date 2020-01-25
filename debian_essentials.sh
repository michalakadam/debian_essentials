#! /bin/bash

sudo apt update -y
sudo apt install dpkg -y
sudo apt install snap -y

is_action_successful(){
	program_name=$1
	exit_code=$2
	action=${3:-INSTALLED}
	echo -e "\n"
	if [[ $exit_code -eq 0 ]] ; then
		printf '\e[32m%-6s\e[m' "$program_name $action"
	else
		printf -e '\e[31m%-6s\e[m' "$program_name NOT $action"
	fi
	echo -e "\n"
}

sudo apt install -y vim
is_action_successful VIM $?

sudo apt install terminator
is_action_successful TERMINATOR $?
sudo update-alternatives --config x-terminal-emulator
is_action_successful TERMINATOR $? "SET AS DEFAULT TERMINAL"

sudo apt install -y git
is_action_successful GIT $?

sudo apt install -y wget git
is_action_successful WGET $?

read -p "Do you want to install Chrome browser? [Y/n] " install_chrome
install_chrome=${install_chrome:-Y}
if [[ $install_chrome == "Y" ]] ; then
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo dpkg -i google-chrome-stable_current_amd64.deb
	is_action_successful CHROME $?
	rm google-chrome-stable_current_amd64.deb
fi

read -p "Do you want to install Visual Studio Code? [Y/n] " install_code
install_code=${install_code:-Y}
if [[ $install_code == "Y" ]] ; then
	sudo snap install --classic code
fi

read -p "Do you want to install Libre Office? [Y/n] " install_office
install_office=${install_office:-Y}
if [[ $install_office == "Y" ]] ; then
        sudo add-apt-repository ppa:libreoffice/ppa
        sudo apt install -y libreoffice
        is_action_successful "LIBRE OFFICE $?"
fi

read -p "Do you want to install zsh and set it as default shell? [Y/n]" install_zsh
install_zsh=${install_zsh:-Y}
if [[ $install_zsh == "Y" ]] ; then
	sudo apt install -y zsh
	is_action_successful ZSH $?
	chsh -s $(which zsh)
	is_action_successful ZSH $? "SET AS DEFAULT SHELL"
	wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
	cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
	source ~/.zshrc
fi

printf '\e[32m%-6s\e[m' "SCRIPT EXECUTED SUCCESSFULLY, PLEASE RESTART TERMINAL TO APPLY CHANGES"
echo -e "\n"




