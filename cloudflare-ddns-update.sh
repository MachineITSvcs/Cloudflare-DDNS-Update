#!/bin/bash

updatedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "${1}" != "" ]; then
	if [ -e "${1}" ]; then
		source "${1}"
	elif [ -e "${updatedir}/${1}" ]; then
		source "${updatedir}/${1}"
	else
		echo Config File Not Found... Exiting...
		exit
	fi
	shift
else
	echo Config File Not Specified... Exiting...
	exit
fi

if [ "${ids_dir}" != "" ]; then
	if [ ! -d "${ids_dir}" ]; then
		if [ -d "${updatedir}/${ids_dir}" ]; then
			ids_dir="${updatedir}/${ids_dir}"
		else
			mkdir -p "${updatedir}/${ids_dir}"
			ids_dir="${updatedir}/${ids_dir}"
		fi
	fi
else
	echo IDS Storage Location Not Specified in Config File...
	echo Using Script Location Instead...
	ids_dir="${updatedir}"
fi

pushd "${updatedir}" > /dev/null 2>&1

export newip4=$(curl -4 -s myipv4.machineitservices.com)
export newip6=$(curl -6 -s myipv6.machineitservices.com)

new_ips="ip4 ip6"
for i in ${new_ips[@]}; do
	newip="$(new_ip="new${i}"; newip=$(eval echo '${'${new_ip}'}'); echo ${newip};)"

	if [ "${newip}" != "" ]; then
		if [ "${i}" == "ip4" ]; then
			echo -e "\nChecking IPv4 Address\n"
			rec_type="A"
		elif [ "${i}" == "ip6" ]; then
			echo -e "\nChecking IPv6 Address\n"
			rec_type="AAAA"
		fi

		ip_file="${updatedir}/old_${i}.txt"

		a=1
		while [ ${a} -le ${custom_records_num} ]; do
			echo -e "\nLoading Custom ${a}"
			load_zone="custom${a}_zones[@]"
			cur_zone="(${!load_zone})"
			for b in $(eval echo '${!'${load_zone}'}'); do
				load_zone="custom${a}_zones[${b}]"
				g="${!load_zone}"
				if [ "$g" != "" ]; then
					load_record="custom${a}_records[@]"
					cur_record="(${!load_record})"
					for c in $(eval echo '${!'$load_record'}'); do
						load_record="custom${a}_records[${c}]"
						h="${!load_record}"
						if [ "$h" != "" ]; then q="."; else q=""; fi
						declare ${zones[${g}]//.}_file[${c}]=${ids_dir}/cf-${i}-${h}${q}${zones[${g}]}.ids
						id_file=$(eval "echo \"\${zones[${g}]//.}_file[${c}]\"")
						echo -e "\nUpdating Record for ${h}${q}${zones[${g}]}"
						s=1
						while [ ${s} -le ${user_creds_num} ]; do
							load_creds="user${s}_credzone[@]"
							for t in $(eval echo '${!'${load_creds}'}'); do
								load_creds="user${s}_credzone[${t}]"
								p="${!load_creds}"
								if [ "${p}" == "${g}" ]; then
									u="user${s}_creds[0]"
									p="user${s}_creds[1]"
									unset zone_identifier
									unset record_identifier
									unset current_ip
									if [ -f ${!id_file} ] && [ $(wc -l ${!id_file} | cut -d " " -f 1) == 2 ]; then
										echo Reading Identifiers from Saved File: cf-${i}-${h}${q}${zones[${g}]}.ids
										zone_identifier=$(head -1 ${!id_file})
										record_identifier=$(tail -1 ${!id_file})
										if [ "${zone_identifier}" != "" ] && [ "${record_identifier}" != "" ]; then
											current_ip="$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records/${record_identifier}" -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" | grep -Po '(?<="content":")[^"]*' | head -1 )"
										fi
									fi

									if [ "${current_ip}" == "" ]; then
										echo Using API to GET Identifiers
										zone_identifier="$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${zones[${g}]}" -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )"
										if [ "${zone_identifier}" != "" ]; then
											record_identifier="$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records?name=${h}${q}${zones[${g}]}&type=${rec_type}" -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )"
											if [ "${record_identifier}" != "" ]; then
												echo Writing Identifiers to Save File: cf-${i}-${h}${q}${zones[${g}]}.ids
												echo "${zone_identifier}" > "${!id_file}"
												echo "${record_identifier}" >> "${!id_file}"
												current_ip="$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records/${record_identifier}" -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" | grep -Po '(?<="content":")[^"]*' | head -1 )"
											else
												echo DNS Record not found. Attempting to create new $rec_type record for ${h}${q}${zones[${g}]}
												proxy_check="custom${a}_proxied"
												proxied=${!proxy_check}
												if [ "${proxied}" == "no" ] || [ "${proxied}" == "0" ]; then
													proxied_bool="false"
												else
													proxied_bool="true"
												fi
												record_identifier="$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records" -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" --data "{\"type\":\"${rec_type}\",\"name\":\"${h}${q}${zones[${g}]}\",\"content\":\"${newip}\",\"proxied\":${proxied_bool}}" | grep -Po '(?<="id":")[^"]*' | head -1 )"
												if [ "${record_identifier}" != "" ]; then
													echo Writing Identifiers to Save File: cf-${i}-${h}${q}${zones[${g}]}.ids
													echo "${zone_identifier}" > "${!id_file}"
													echo "${record_identifier}" >> "${!id_file}"
													current_ip="${newip}"
												else
													echo Unable to retrieve DNS Record Identifier. DNS Record may or may not have been created.
													echo Please try running again.
												fi
											fi
										else
											echo DNS Zone not found... Continuing...
										fi
									fi

									if [ "${zone_identifier}" != "" ] && [ "${record_identifier}" != "" ]; then
										echo "Current IP for ${h}${q}${zones[${g}]} is ${current_ip}"
										if [ "${newip}" != "${current_ip}" ]; then
											proxy_check="custom${a}_proxied"
											proxied=${!proxy_check}
											if [ "${proxied}" == "no" ] || [ "${proxied}" == "0" ]; then
												update="$(curl -s -X PUT https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records/${record_identifier} -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" --data "{\"type\":\"${rec_type}\",\"name\":\"${h}${q}${zones[${g}]}\",\"content\":\"${newip}\",\"proxied\":false}")"
											elif [ "${proxied}" == "yes" ] || [ "${proxied}" == "1" ]; then
												update="$(curl -s -X PUT https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records/${record_identifier} -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" --data "{\"type\":\"${rec_type}\",\"name\":\"${h}${q}${zones[${g}]}\",\"content\":\"${newip}\",\"proxied\":true}")"
											else
												echo Proxy Value Not Defined in Custom $a; echo Attempting to Update Record Without Proxy Definition in Request
												update=$(curl -s -X PUT https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records/${record_identifier} -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" --data "{\"type\":\"${rec_type}\",\"name\":\"${h}${q}${zones[${g}]}\",\"content\":\"${newip}\"}")
											fi

											if [[ ${update} == *"\"success\":false"* ]]; then
												message="API UPDATE FAILED FOR: \"${h}${q}${zones[${g}]}\" DUMPING RESULTS:\n${update}"
												echo -e "${message}"
											else
												message="IP changed to: ${newip}\nProxied: $(echo "${update}" | grep -Po '(?<="proxied":)[^,]*' | head -1)"
												echo -e "${message}"
											fi
										else
											echo "No IP change detected for ${h}${q}${zones[${g}]}. No update required."
										fi
										break
									else
										echo DNS Zone or Record not found... Continuing...
									fi
								fi
							done
							((s++))
						done
					done
				else
					echo No Zones Listed... Continuing...
				fi
			done
			((a++))
		done
	fi
done
