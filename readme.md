rearm (Rearm Every Activation-Related Mechanism)
================================================
**rearm** is a simple script used to reset the state of every activation-related
mechanism in Windows. For example it can be used to clean the activation state
from a to-be-deployed image.

Usage
-----
**rearm** is required to be run from Windows PE or Windows RE. To use it, place
`rearm.cmd` in the root of the drive which contains the installation you wish to
rearm then reboot to Windows PE or Windows RE and run the script from the
command prompt.

License
-------
This script is licensed under the terms of the GNU General Public License v3.0
