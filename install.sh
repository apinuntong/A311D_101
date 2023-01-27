#!/bin/sh

set -e

password='rpdzkj:'

# Record the time this script starts
date

# Get the full dir name of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Keep updating the existing sudo time stamp
sudo -v
while true; do sudo -n true; sleep 120; kill -0 "$$" || exit; done 2>/dev/null &

# Install pip and some python dependencies
echo "\e[104m Install pip and some python dependencies \e[0m"
sudo apt-get update
sudo apt install -y python3-pip python3-setuptools python3-pil python3-smbus python3-matplotlib cmake curl
sudo -H pip3 install --upgrade pip

sudo apt-get install -y python3-pip libopenblas-base libopenmpi-dev 
sudo -H pip3 install Cython

sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev
sudo -H pip3 install pillow

# Install traitlets (master, to support the unlink() method)
echo "\e[48;5;172m Install traitlets \e[0m"
sudo -H python3 -m pip install git+https://github.com/ipython/traitlets@dead2b8cdde5913572254cf6dc70b5a6065b86f8

# Install JupyterLab (lock to 2.2.6, latest as of Sept 2020)
echo "\e[48;5;172m Install Jupyter Lab 2.2.6 \e[0m"
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install -y nodejs libffi-dev libssl1.1
sudo -H pip3 install jupyter jupyterlab==2.2.6 --verbose
sudo -H jupyter labextension install @jupyter-widgets/jupyterlab-manager

jupyter lab --generate-config
python3 -c "from notebook.auth.security import set_password; set_password('$password', '$HOME/.jupyter/jupyter_notebook_config.json')"


# Install jupyter_clickable_image_widget
echo "\e[42m Install jupyter_clickable_image_widget \e[0m"
cd
git clone https://github.com/jaybdub/jupyter_clickable_image_widget
cd jupyter_clickable_image_widget
git checkout tags/v0.1
sudo -H pip3 install -e .
sudo -H jupyter labextension install js
sudo -H jupyter lab build

# fix for permission error
sudo chown -R rpdzkj:rpdzkj /usr/rpdzkj:local/share/jupyter/lab/settings/build_config.json

# install version of traitlets with dlink.link() feature
# (added after 4.3.3 and commits after the one below only support Python 3.7+) 
#
sudo -H python3 -m pip install git+https://github.com/ipython/traitlets@dead2b8cdde5913572254cf6dc70b5a6065b86f8
sudo -H jupyter lab build


# ========================================
# Install other misc packages 
# ========================================
sudo -H pip3 install tqdm cython pycocotools 
sudo apt-get install python3-matplotlib
sudo -H pip3 install traitlets
sudo -H pip3 install -U scikit-learn


# Install jetcard
echo "\e[44m Install jetcard \e[0m"
cd $DIR
pwd
sudo apt-get install python3-pip python3-setuptools python3-pil python3-smbus
sudo -H pip3 install flask
sudo -H python3 setup.py install

# Install jetcard display service
echo "\e[44m Install jetcard display service \e[0m"
python3 -m jetcard.create_display_service
sudo mv jetcard_display.service /etc/systemd/system/jetcard_display.service
sudo systemctl enable jetcard_display
sudo systemctl start jetcard_display

# Install jetcard jupyter service
#echo "\e[44m Install jetcard jupyter service \e[0m"
#python3 -m jetcard.create_jupyter_service
#sudo mv jetcard_jupyter.service /etc/systemd/system/jetcard_jupyter.service
#sudo systemctl enable jetcard_jupyter
#sudo systemctl start jetcard_jupyter

# Make swapfile
echo "\e[46m Make swapfile \e[0m"
cd
if [ ! -f /var/swapfile ]; then
	sudo fallocate -l 2G /var/swapfile
	sudo chmod 600 /var/swapfile
	sudo mkswap /var/swapfile
	sudo swapon /var/swapfile
	sudo bash -c 'echo "/var/swapfile swap swap defaults 0 0" >> /etc/fstab'
else
	echo "Swapfile already exists"
fi



# Install remaining dependencies for projects
echo "\e[104m Install remaining dependencies for projects \e[0m"
sudo apt-get install python-setuptools



echo "\e[42m All done! \e[0m"

#record the time this script ends
date
