# Cloudflare-DDNS-Update

This was a project I began working on when I founded Machine IT Services, a web hosting, web development, and IT company based in Louisville, KY.
This script has the potential to update the DNS A Records of a multitude of domains, or "zones", on Cloudflare, while also providing flexibility by allowing the update of specific subdomains, or "records", for each domain specified in the config file.
You may refer to included config-example.sh for config file format. In order to run the script, just execute it with either the config file name (if in the same directory, i.e. config.sh) or the config file location (i.e. /your/config/directory/config.sh) as your first argument.
It will also accept a second and third argument. These are to specify 1) An additional script to run and 2) an additional argument to pass to the additional script. This is helpful in the situation that your server is also a DNS server or needs the IP address updated somewhere in it's own files or databases.

A few examples of usage are:

#In this command, the config file is assumed to be in the same directory as the script
/path/to/cf-update.sh config.sh

#In this command, the config file location is specified
/path/to/cf-update.sh /path/to/config.sh

#Custom script specified. Please note that the variables $updatedir (cf-update.sh location) $oldip and $newip will be passed
/path/to/cf-update.sh config.sh update-my-dns-server.sh

#Custom script and argument provided. Please note that the argument is passed normally as ${1}
/path/to/cf-update.sh config.sh update-my-dns-server.sh secondary-server-address

For assistance with the use or operation of this utility, you may email me at contact@machineitservices.com. Please no spam or soliciting.
