#!/bin/bash
set -e
set -x

if [ "$UID" -eq 0 ]; then
     echo "Sorry, this script must NOT be run as ROOT!"
     exit 1
fi

DISTRIBUTION_ID=$(lsb_release -i -s)
if [ ${DISTRIBUTION_ID} = 'Ubuntu' ]; then
  DISTRIBUTION_CODENAME=$(lsb_release -c -s)
  if [ ${DISTRIBUTION_CODENAME} = 'focal' ] || [ ${DISTRIBUTION_CODENAME} = 'bionic' ]; then
    sudo add-apt-repository universe -y
  fi
fi

sudo apt-get -y update
sudo apt-get install -y unzip git imagemagick curl wget make python3

# create a Python venv on more recent releases:
if [ ${DISTRIBUTION_CODENAME} = 'noble' ]; then
    sudo apt install python3-venv
    python3 -m venv $HOME/venv-ardupilot-wiki --upgrade-deps

    # activate it:
    SOURCE_LINE="source $HOME/venv-ardupilot-wiki/bin/activate"
    $SOURCE_LINE
fi

# Install packages release specific
if [ ${DISTRIBUTION_CODENAME} = 'bionic' ]; then
  sudo apt-get install -y python3-distutils
fi

# For WSL (esp. version 2) make DISPLAY empty to allow pip to run
STORED_DISPLAY_VALUE=$DISPLAY
if grep -qi -E '(Microsoft|WSL)' /proc/version; then
  echo "Temporarily clearing the DISPLAY variable because this is WSL"
  export DISPLAY=
fi

# Get pip through the official website to get the latest release
GET_PIP_URL="https://bootstrap.pypa.io/get-pip.py"

# accomodate default Python on bionic:
if [ "$(python --version)" == "Python 3.6.9" ]; then
    GET_PIP_URL="https://bootstrap.pypa.io/pip/3.6/get-pip.py"
fi

PIP_USER_ARGUMENT=""
if [ ${DISTRIBUTION_CODENAME} != 'noble' ]; then
  curl "$GET_PIP_URL" -o get-pip.py
  python3 get-pip.py
  rm -f get-pip.py
  PIP_USER_ARGUMENT="--user"
fi

# Install required python packages
python3 -m pip install $PIP_USER_ARGUMENT --upgrade -r requirements.txt

# Reset the value of DISPLAY
if grep -qi -E '(Microsoft|WSL)' /proc/version; then
  echo "Returning DISPLAY to the previous value in WSL"
  export DISPLAY=$STORED_DISPLAY_VALUE
fi

echo "Setup completed successfully!"
