# web-server-configurator

web-server-configurator is a set of shell scripts created in order to make web server configuration easily and faster.

## Current scripts:
| Script name | Files | Description | Supported OS | Using | 
| ----------- | ----- | ----------- | ------------ | ----- |
| LAMP installer | **lamp-installer-linux.sh** - main script, working on linux <br>**lamp-installer-windown.sh** - same script, but created within Wondows OS and cannot work in Linux <br>**win2linux.sh** - changes content of *lamp-installer-windown.sh* (for working on Linux) and put it in *lamp-installer-linux.sh*, it's useful if you make changes script in Windows | installs LAMP (Linux Apache MySQL PHP) stack | Ubuntu (Linux) 16.04 and newer | run <br>`win2linux.sh` <br>or <br>`lamp-installer-linux.sh` (if you didn't change *lamp-installer-windown.sh*) and follow instructions |


# Contributing
If you want to help me make this project better, you can fix [some issue](https://github.com/ReeNekt/web-server-configurator/issues) or create merge request with new functional, or help me translate docs

# License
This project licensed under MIT Lisence. See **[LICENSE](https://github.com/ReeNekt/web-server-configurator/blob/master/LICENSE)** file for details

# Changelog

Version 0.1 beta - created LAMP installer script, created README and LICENSE files
