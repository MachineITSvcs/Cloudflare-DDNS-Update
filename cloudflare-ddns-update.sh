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

if [ "${force}" == "on" ]; then
	setip4=0.0.0.0
	setip6=::
else
	setip4=$(dig +short a ${hostnameaddr})
	setip6=$(dig +short aaaa ${hostnameaddr})
fi

pushd "${updatedir}" > /dev/null 2>&1

export newip4=$(curl -4 -s myipv4.machineitservices.com)
export newip6=$(curl -6 -s myipv6.machineitservices.com)

if $([[ "${setip4}" == *"connection timed out"* ]] || [ "${newip4}" == "" ] || [ "${setip4}" == "" ] || $(unset newip4 && echo false)) && \
	$([[ "${setip6}" == *"connection timed out"* ]] || [ "${newip6}" == "" ] || [ "${setip6}" == "" ] || $(unset newip6 && echo false)); then
	echo Obtaining Addresses Failed. Now Exiting...
	exit
else

	new_ips="ip4 ip6"
	for i in ${new_ips[@]}; do
		
		setip="$(set_ip="set${i}"; setip=$(eval echo '${'${set_ip}'}'); echo ${setip};)"
		newip="$(new_ip="new${i}"; newip=$(eval echo '${'${new_ip}'}'); echo ${newip};)"

		if [ "${newip}" != "" ] && [ "${setip}" != "${newip}" ]; then
			if [ "${i}" == "ip4" ]; then
				echo -e "\nChecking IPv4 Address\n"
				rec_type="A"
			elif [ "${i}" == "ip6" ]; then
				echo -e "\nChecking IPv6 Address\n"
				rec_type="AAAA"
			fi
	
	if [ -f "${updatedir}/new_${i}.txt" ]; then
        	mv "${updatedir}/new_${i}.txt" "${updatedir}/old_${i}.txt"
	elif [ "${setip}" != "" ]; then
		echo "${setip}"> "${updatedir}/old_${i}.txt"
	else
		echo ERROR! Unable To Obtain Old Hostname IP Address
	fi

	ip_file="${updatedir}/old_${i}.txt"
	if [ -f "${ip_file}" ]; then export oldip="$(cat "${updatedir}/old_${i}.txt")"; fi
	echo "${newip}"> "${updatedir}/new_${i}.txt"

        echo IP Discrepancy Detected
        echo Saved IP: ${oldip}
        echo Live IP: ${setip}
        echo Current IP: ${newip}
	echo DNS ${rec_type} Record Updates Required
	echo Updating Cloudflare DNS Records
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
							if [ -f ${!id_file} ] && [ $(wc -l ${!id_file} | cut -d " " -f 1) == 2 ]; then
								echo Reading Identifiers from Saved File: cf-${i}-${h}${q}${zones[${g}]}.ids
								zone_identifier=$(head -1 ${!id_file})
								record_identifier=$(tail -1 ${!id_file})
							else
								echo Using API to GET Identifiers
								zone_identifier="$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${zones[${g}]}" -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )"
								record_identifier="$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records?name=${h}${q}${zones[${g}]}&type=${rec_type}" -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json"  | grep -Po '(?<="id":")[^"]*' | head -1 )"
								echo Writing Identifiers to Save File: cf-${h}${q}${zones[${g}]}.ids
								echo "${zone_identifier}" > "${!id_file}"
								echo "${record_identifier}" >> "${!id_file}"
							fi						

							proxy_check="custom${a}_proxied"
							proxied=${!proxy_check}
							if [ "${proxied}" == "no" ] || [ "${proxied}" == "0" ]; then
								update="$(curl -s -X PUT https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records/${record_identifier} -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" --data "{\"type\":\"${rec_type}\",\"name\":\"${h}${q}${zones[${g}]}\",\"content\":\"${newip}\",\"proxied\":false}")"

							elif [ "${proxied}" == "yes" ] || [ "${proxied}" == "1" ]; then
								update="$(curl -s -X PUT https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records/${record_identifier} -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" --data "{\"type\":\"${rec_type}\",\"name\":\"${h}${q}${zones[${g}]}\",\"content\":\"${newip}\",\"proxied\":true}")"
							else echo Proxy Value Not Defined in Custom $a; echo Attempting to Update Record Without Proxy Definition in Request
								update=$(curl -s -X PUT https://api.cloudflare.com/client/v4/zones/${zone_identifier}/dns_records/${record_identifier} -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" --data "{\"type\":\"${rec_type}\",\"name\":\"${h}${q}${zones[${g}]}\",\"content\":\"${newip}\"}")
							fi
							if [[ ${update} == *"\"success\":false"* ]]; then
								message="API UPDATE FAILED FOR: \"${h}${q}${zones[${g}]}\" DUMPING RESULTS:\n${update}"
								echo -e "${message}"
							else
								message="IP changed to: ${newip}\nProxied: $(echo "${update}" | grep -Po '(?<="proxied":)[^,]*' | head -1)"
								echo -e "${message}"
							fi
							break
						fi
					done
					((s++))
				done
			done
		else echo No Zones Listed... Continuing...
		fi
	done
	((a++))
done

echo "${newip}" > ${ip_file}

	if [ "${1}" != "" ]; then
		call_script="${1}"
		shift
        	if [ -e "${call_script}" ]; then
                	source "${call_script}" "${@}"
        	elif [ -e "${updatedir}/${call_script}" ]; then
                	source "${updatedir}/${call_script}" "${@}"
        	else
                	echo Secondary Script Specified But File Not Found... Continuing...
        	fi
	fi
	fi
done
fi
