#! /bin/bash

sudo apt update -y
sudo apt install dpkg -y
sudo apt install snap -y
sudo apt install tree -y

is_action_successful(){
	program_name=$1
	exit_code=$2
	action=${3:-INSTALLED}
	if [[ $exit_code -eq 0 ]] ; then
		printf '\e[32m%-6s\e[m' "$program_name $action"
	else
		printf '\e[31m%-6s\e[m' "$program_name NOT $action"
	fi
	echo -e "\n"
}

#Add custom keybindings for shutdown and reboot
sudo apt install dconf-editor

dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'shutdown -h now'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Primary><Alt>k'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'shutdown'"
is_action_successful "CUSTOM KEYBINDING FOR SHUTDOWN" $? "SET TO <Primary>+<Alt>+k"

dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/command "'reboot'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/binding "'<Primary><Alt>r'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/name "'reboot'"
is_action_successful "CUSTOM KEYBINDING FOR REBOOT" $? "SET TO <Primary>+<Alt>+r"

sudo apt install -y vim
is_action_successful VIM $?
sudo update-alternatives --config editor

sudo apt install terminator
is_action_successful TERMINATOR $?
sudo update-alternatives --config x-terminal-emulator

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

read -p "Do you want to install Spotify? [Y/n] " install_spotify
install_spotify=${install_spotify:-Y}
if [[ $install_spotify == "Y" ]] ; then
	snap install spotify
        is_action_successful SPOTIFY $?
	dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/command "'spotify'"
	dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/binding "'<Primary><Alt>s'"
	dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/name "'open spotify'"
	is_action_successful "CUSTOM KEYBINDING FOR RUNNING SPOTIFY" $? "SET TO <Primary>+<Alt>+s"
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

#Add installed programs to favourites' bar. Note that if a program was not installed and is present on the list below, it will just not appear among the favourites.
dconf write /org/gnome/shell/favorite-apps "['google-chrome.desktop', 'org.gnome.Nautilus.desktop', 'libreoffice-writer.desktop', 'code_code.desktop', 'spotify_spotify.desktop', 'terminator.desktop']"

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

	read -p "Please specify zsh theme you want to use? [gnzh] " zsh_theme
	zsh_theme=${zsh_theme:-gnzh}
	sed -i "s/robbyrussell/$zsh_theme/g" $HOME/.zshrc
	is_action_successful $zsh_theme $? "SET AS ZSH THEME"
fi

#Create file with useful aliases and add it to shell
cat > $HOME/.aliases <<EOF
# You can add your aliases here.
# Make sure to reset shell after editing this file for an alias to work!

alias c='clear'
alias ls='ls --color=auto'
alias ll='ls -la'
alias rmf='rm -rf'
alias grep='grep --color=auto'
alias log='git log --oneline --decorate --graph'
alias commit='git add . && git commit'
alias amend='git commit --amend'

EOF

if [ -f $HOME/.bashrc ]; then
	sed -i 's/.bash_aliases/.aliases/g' $HOME/.bashrc
	is_action_successful "Aliases" $? "added to bash config file"
fi

if [ -f $HOME/.zshrc ]; then
	echo 'source $HOME/.aliases' >> $HOME/.zshrc
	is_action_successful "Aliases" $? "added to zsh config file"
fi

printf '\e[32m%-6s\e[m' "SCRIPT EXECUTED SUCCESSFULLY, PLEASE RESTART TERMINAL TO APPLY CHANGES"
echo -e "\n"

