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
    sudo add-apt-repository universe
  fi
fi

sudo apt-get -y update
sudo apt-get install -y unzip git imagemagick curl wget make python python-pip

# Install packages release specific
if [ ${DISTRIBUTION_CODENAME} = 'bionic' ]; then
  sudo apt-get install -y python3-distutils
elif [ ${DISTRIBUTION_CODENAME} = 'focal' ]; then
  sudo apt-get install -y python-is-python3
# else
#     if [ ${DISTRIBUTION_ID} = 'Ubuntu' ]; then
#         # sudo apt-get install -y python-is-python3
#     fi
fi

# Get pip through the official website to get the lastest release
# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
# python2 get-pip.py
# rm -f get-pip.py

# Install sphinx
python -m pip install alabaster==0.7.12 Babel==2.7.0 beautifulsoup4==4.4.1 certifi==2019.9.11 chardet==3.0.4 docutils==0.15.2 html==1.16 html5lib==0.999 idna==2.8 imagesize==1.1.0 Jinja2==2.10.3 lxml==4.6.2 MarkupSafe==1.1.1 mercurial==3.7.3 packaging==19.2 Pygments==2.4.2 pyparsing==2.4.2 pytz==2019.3 requests==2.22.0 roman==2.0.0 six==1.12.0 snowballstemmer==2.0.0 Sphinx==1.8.5 sphinxcontrib-websupport==1.1.2 typing==3.7.4.1 urllib3==1.25.6 'setuptools<44' git+https://github.com/ArduPilot/sphinx_rtd_theme.git git+https://github.com/TunaLobster/youtube.git

# lxml for parameter parsing:
# python -m pip install --user --upgrade lxml

# Install sphinx theme from ArduPilot repository
# python -m pip install --user --upgrade git+https://github.com/ArduPilot/sphinx_rtd_theme.git

# and a youtube plugin:
# python -m pip install --user --upgrade git+https://github.com/TunaLobster/youtube.git

# and a vimeo plugin:
# python -m pip install --user --upgrade git+https://github.com/ArduPilot/sphinxcontrib.vimeo.git
# we previously used this plugin, but the features are now included in the youtube plugin
# remove if installed (will warn if not installed)
if python -m pip show sphinxcontrib.vimeo > /dev/null 2>&1; then
  python -m pip uninstall -y sphinxcontrib.vimeo
fi

echo "Setup completed successfully!"
