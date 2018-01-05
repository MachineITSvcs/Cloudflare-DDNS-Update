<meta name="google-site-verification" content="2s6B5-69zE7JKTxiw2EZkN5hZRyK9TqRIrR_D9Nk-cs" />
# <a href="https://github.com/MachineITSvcs/Cloudflare-DDNS-Update" target="_blank">Cloudflare-DDNS-Update</a>

## Introduction

This was a project I began working on when I founded <a href="https://www.machineitservices.com/" target="_blank">Machine IT Services</a>, a web hosting, web development, and IT company based in Louisville, KY.
This script has the potential to update the DNS A Records of a multitude of domains, or "zones", on Cloudflare, while also providing flexibility by allowing the update of specific subdomains, or "records", for each domain specified in the config file.
You may refer to included config-example.sh for config file format. In order to run the script, just execute it with either the config file name (if in the same directory, i.e. config.sh) or the config file location (i.e. /your/config/directory/config.sh) as your first argument.
It will also accept a second and third argument. These are to specify: 1) An additional script to run and 2) an additional argument to pass to the additional script. This is helpful in the situation that your server is also a DNS server or needs the IP address updated somewhere in it's own files or databases.
This is the perfect script if you're managing multiple sites on your dynamic server, and want to update several individual zones for separate Cloudflare accounts in one script. This script will allow you to specify your accounts, zones, records, and whether or not to use the Cloudflare proxy.

## Usage

- In this command, the config file is assumed to be in the same directory as the script.
	- `/path/to/cf-update.sh config.sh`

- In this command, the config file location is specified.
	- `/path/to/cf-update.sh /path/to/config.sh`

- Custom script specified. Please note that the variables $updatedir (cf-update.sh location) $oldip and $newip will be passed.
	- `/path/to/cf-update.sh config.sh update-my-dns-server.sh`

- Custom script and argument provided. Please note that the argument is passed normally as `${1}` within your additional script.
	- `/path/to/cf-update.sh config.sh update-my-dns-server.sh secondary-server-address`

Of course, I'd recommend using a cronjob to run this script automatically at set intervals; Once every minute should be fine.

Please set the `hostnameaddr` variable in your config file to a record that is NOT proxied.
That is the address checked against your current server address. This is IMPORTANT!

## Contact

For assistance with the use or operation of this utility, feel free to <a href="mailto:contact@machineitservices.com">email me</a>. Please no spam or solicitation.

## Donate

Donations are definitely welcome to encourage future developments like this one. You may visit <a href="https://www.machineitservices.com/donate/" target="_blank">our site</a> if you would like to contribute. Thank you.
