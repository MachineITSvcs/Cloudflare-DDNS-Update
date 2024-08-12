############### START CONFIG ###############

## Zones to update. Space-delimited list in the format: (example1.com example2.com ...) - Used as array (first value 0)
zones=(example.com example1.com example2.com)

############# Credentials #############

## First Set of Credentials in the format: (user@name.com zone_global_api_key)
user1_creds=("user1@example.com" "user1APIkey")
## Specify Zones that utilize the First Set of Credentials in the format: (0 1 ...) - (0 refers to first domain in zones, 1 refers to second, and so on)
user1_credzone=(0 1)

## Second Set of Credentials in array in the format: (user@name.com zone_global_api_key)
user2_creds=("user2@example2.com" "user2APIkey")
## Specify Zones that utilize the Second Set of Credentials in the format: (0 1 ...) - (0 refers to first domain in zones, 1 refers to second, and so on)
user2_credzone=(2)

############## Records ##############

## First Set of Records listed in the format: ("" cf mail ...) - ("" refers to domain without subdomain, i.e. "naked" domain record)
custom1_records=(cf)
## Specify Zones containing the aforementioned records to be updated in the format: (0 1 ...) - (0 refers to first domain in zones, 1 refers to second, and so on)
custom1_zones=(0)
## Specify whether records updated will have proxy enabled or disabled. Use either "yes" or "no" without quotes
custom1_proxied=no

## Second Set of Records listed in the format: ("" ns1 ...) - ("" refers to domain without subdomain, i.e. "naked" domain record)
custom2_records=("")
## Specify Zones containing the aforementioned records to be updated in array in the format: (0 1 ...) - (0 refers to first domain in zones, 1 refers to second, and so on)
custom2_zones=(0 1 2)
## Specify whether records updated will have proxy enabled or disabled. Use either "yes" or "no" without quotes
custom2_proxied=yes

# If you add custom variables above (i.e. user3_... or custom3_...), you will also have to change the values below.

## Number of Sets of Credentials Above
user_creds_num=2

## Number of Sets of Records Above
custom_records_num=2

## Subdirectory to save API Identifiers for faster updates in the future
ids_dir=ids

## Directory to run the script from. Uncomment to override (Normally set to script location)
#updatedir=/your/working/directory

## Force update of records. Recommended if adding a new domain. Uncomment when needed.
#force=no

################ END CONFIG ################
