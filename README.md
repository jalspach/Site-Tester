[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-Ready--to--Code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/jalspach/Site-Tester) 

# Site-Tester
Tool to test multiple sites before a roll out.
This script runs a series of tests to verify the pre and later post install status.
WARNING...this code is UGLY and not nearly as clean as it should be...in fact it hardly gets the job done. BUT...it DOES get the job done so it is what it is.
This script requires the following packages be installed manually, as of the current version:
 - iperf3
 - speedtest-cli
 - nuttcp
 - netcat < commented out for now since it requires root permissions
 - nmap

Using Puppet to ensure these things are installed and that the current version of this script is pulled.
~~~
Potential Improvements
lots lol but some specifics:
- Copy results to a web server or other remote, accessible storage location
- List targets to iterate over
- rewrite tests as functions that get called against the list of targets
- Allow the user to pull the latest version of the script
- Output JSON or similar to make it easier to pull into other systems
