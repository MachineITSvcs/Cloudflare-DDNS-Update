############### START CONFIG ###############

hostnameaddr=ns1.example.com			## Check IP Address of This Hostname

zones=(example.com example1.com example2.com)	## Zones to update. Listed in array surrounded by paranthesis in the format: (example1.com example2.com ...) Remember array values start at 0

user1_creds=("user1@example.com" "user1APIkey")	## First Set of Credentials listed in array in the format: (user@name.com zone_global_api_key)
user1_credzone=(0 1)				## Specify Zones that utilize the First Set of Credentials in array in the format: (0 1 ...)
user2_creds=("user2@example2.com" "user2APIkey") ## Second Set of Credentials listed in array in the format: (user@name.com zone_global_api_key)
user2_credzone=(2)				 ## Specify Zones that utilize the Second Set of Credentials in array in the format: (0 1 ...)

custom1_records=(ns1 www)			## First Set of Records listed in array in the format: ("" ns1 www ...)
custom1_zones=(0)				## Specify Zones containing the aforementioned records to be updated in array in the format: (0 1 ...)
custom1_proxied=no				## Specify whether records updated will have proxy enabled or disabled. Use either "yes" or "no" without quotes
custom2_records=("")				## Second Set of Records listed in array in the format: ("" ns1 www ...)
custom2_zones=(0 1 2)				## Specify Zones containing the aforementioned records to be updated in array in the format: (0 1 ...)
custom2_proxied=yes				## Specify whether records updated will have proxy enabled or disabled. Use either "yes" or "no" without quotes

# If you add custom variables above (i.e. user3... or custom3...), you will also have to change the values below.

user_creds_num=2				## Number of Sets of Credentials Above
custom_records_num=2				## Number of Sets of Records Above
ids_dir=ids					## Subdirectory to save API Identifier files for faster updates in the future

################ END CONFIG ################
