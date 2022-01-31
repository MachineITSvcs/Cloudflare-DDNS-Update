# <a href="https://github.com/MachineITSvcs/Cloudflare-DDNS-Update" target="_blank">Cloudflare-DDNS-Update</a>

## Introduction

This was a project I began working on when I founded <a href="https://www.machineitservices.com/" target="_blank">Machine IT Services</a>, a web hosting, web development, and IT company based in Louisville, KY.
This script has the potential to update the DNS Records (A and AAAA) of a multitude of domains/zones on Cloudflare, while also providing flexibility by allowing the update of specific subdomains/records for each domain specified in the config file, compatible with both IPv4 and IPv6 addresses.
You may refer to included config-example.sh for config file format. In order to run the script, just execute it with either the config file name (if in the same directory, i.e. config.sh) or the config file location (i.e. /your/config/directory/config.sh) as your first argument. You can specify numerous custom record sections, with each containing unique or different sets of subdomains/records for each zone specified. You can list the same zone more than once in separate records groups, setting the proxy option for each group as needed.
It will also accept a second argument. This is to specify an additional script to run. Any additional arguments will be passed to the additional script. This is helpful in the situation that your server is also a DNS server or needs the IP address updated somewhere in it's own files or databases as it will include the $oldip4/6 and $newip4/6 variables, as well as the $updatedir/cloudflare-ddns-update.sh script location..
This is the perfect script if you're managing multiple sites on your dynamic server, and want to update several individual zones for separate Cloudflare accounts in one script. This script will allow you to specify your accounts, zones, records, and whether or not to use the Cloudflare proxy.

## Usage

- In this command, the config file is assumed to be in the same directory as the script.
	- `/path/to/cloudflare-ddns-update.sh config.sh`

- In this command, the config file location is specified.
	- `/path/to/cloudflare-ddns-update.sh /path/to/config.sh`

- Custom script specified. Please note that the variables $updatedir (cloudflare-ddns-update.sh location) $oldip4, $oldip6, $newip4, and $newip6 will be passed.
	- `/path/to/cloudflare-ddns-update.sh config.sh update-my-dns-server.sh`

- Custom script and argument provided. Please note that the argument is passed normally as `${1}` within your additional script.
	- `/path/to/cloudflare-ddns-update.sh config.sh update-my-dns-server.sh secondary-server-address`

Of course, I'd recommend using a cronjob to run this script automatically at set intervals; Once every minute should be fine.

Please set the `hostnameaddr` variable in your config file to a record that is NOT proxied, and INCLUDE it in your list of records to update.
Otherwise it will always run, as it is the address checked against your current server address. This is IMPORTANT!

NOTE: In the future, I may just use the API to retrieve each record's currently set address in Cloudflare to do away with this "non-proxied" record requirement.

## Contact

For assistance with the use or operation of this utility, feel free to <a href="mailto:contact@machineitservices.com">email me</a>. Please no spam or solicitation.

## Donate

Donations are definitely welcome to encourage future developments like this one. You may visit <a href="https://www.machineitservices.com/donate/" target="_blank">our site</a> if you would like to contribute. Thank you.
