#!/bin/bash


updatedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "${1}" != "" ]; then
        if [ -e ${1} ]; then
                source ${1};
        elif [ -e ${updatedir}/${1} ]; then
                source ${updatedir}/${1};
        else
                echo Config File Not Found... Exiting...
		exit
        fi
else
        echo Config File Not Specified... Exiting...
        exit
fi

if [ "${ids_dir}" != "" ]; then
        if [ ! -d "${ids_dir}" ]; then
        	if [ -d "${updatedir}/${ids_dir}" ]; then
			ids_dir=${updatedir}/${ids_dir};
		else
			mkdir -p ${updatedir}/${ids_dir};
			ids_dir=${updatedir}/${ids_dir};
		fi
        fi
else
        echo IDS Storage Location Not Specified in Config File...
        echo Using Script Location Instead...
	ids_dir=${updatedir}
fi

if [ "${force}" == "on" ]; then
	setip=0.0.0.0
else
	setip=$(dig +short ${hostnameaddr})
fi

pushd ${updatedir} > /dev/null 2>&1

export newip=$(dig @8.8.8.8 -t txt o-o.myaddr.l.google.com | grep "client-subnet" | grep -o "\([0-9]\{1,3\}\.\)\{3\}\([0-9]\{1,3\}\)")

if [[ "${setip}" == *"connection timed out"* ]] || [ "${newip}" == "" ] || [ "${setip}" == "" ]; then
    echo Obtaining Addresses Failed. Now Exiting...
    exit
else
	if [ "${setip}" != "${newip}" ]; then
	
	oldiptxt=old_ip.txt
	newiptxt=new_ip.txt

	if [ -f ${updatedir}/${newiptxt} ]; then
        	mv ${updatedir}/${newiptxt} ${updatedir}/${oldiptxt}
	elif [ ! -f ${updatedir}/${newiptxt} ]; then
        	if [ "${setip}" != "" ]; then
                	echo ${setip}> ${updatedir}/${oldiptxt}
        	else
                	echo ERROR! Unable To Obtain Live Hostname IP Address. Exiting...
                	exit
        	fi
	fi

	ip_file=${updatedir}/${oldiptxt}
	export oldip=$(cat ${updatedir}/${oldiptxt})
	echo ${newip}> ${updatedir}/${newiptxt}

        echo IP Discrepancy Detected
        echo Saved IP: ${oldip}
        echo Live IP: ${setip}
        echo Current IP: ${newip}
	echo DNS A Record Updates Required
	echo Updating Cloudflare DNS Records
	a=1
while [ $a -le ${custom_records_num} ]; do
	echo "" && echo Loading Custom ${a}
	load_zone="custom${a}_zones[@]";
	cur_zone=(${!load_zone});
	for b in $(eval echo '${!'$load_zone'}'); do
		load_zone="custom${a}_zones[$b]";
		g=${!load_zone};
		if [ "$g" != "" ]; then
			load_record="custom${a}_records[@]";
			cur_record=(${!load_record})
			for c in $(eval echo '${!'$load_record'}'); do
				load_record="custom${a}_records[$c]";
				h=${!load_record};
				if [ "$h" != "" ]; then q="."; else q=""; fi
				declare ${zones[${g}]//.}_file[${c}]=${ids_dir}/cf-${h}${q}${zones[${g}]}.ids;
				id_file=$(eval "echo \"\${zones[${g}]//.}_file[${c}]\"");
				echo ""
				echo Updating Record for ${h}${q}${zones[${g}]}
				s=1
				while [ $s -le ${user_creds_num} ]; do
					load_creds="user${s}_credzone[@]";
					for t in $(eval echo '${!'$load_creds'}'); do
						load_creds="user${s}_credzone[$t]";
						i=${!load_creds};
						if [ "$i" == "$g" ]; then
							u="user${s}_creds[0]";
							p="user${s}_creds[1]";
						if [ -f ${!id_file} ] && [ $(wc -l ${!id_file} | cut -d " " -f 1) == 2 ]; then
							echo Reading Identifiers from Saved File: cf-${h}${q}${zones[${g}]}.ids
							zone_identifier=$(head -1 ${!id_file})
							record_identifier=$(tail -1 ${!id_file})
						else
							echo Using API to GET Identifiers
							zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${zones[${g}]}" -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )
							record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=${h}${q}${zones[${g}]}" -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json"  | grep -Po '(?<="id":")[^"]*' | head -1 )
							echo Writing Identifiers to Save File: cf-${h}${q}${zones[${g}]}.ids
							echo "$zone_identifier" > ${!id_file}
							echo "$record_identifier" >> ${!id_file}
						fi
						

						proxy_check="custom${a}_proxied";
						proxied=${!proxy_check}
						if [ "$proxied" == "no" ]; then
						update=$(curl -s -X PUT https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" --data "{\"type\":\"A\",\"name\":\"${h}${q}${zones[${g}]}\",\"content\":\"${newip}\",\"proxied\":false}")

						elif [ "$proxied" == "yes" ]; then
						update=$(curl -s -X PUT https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" --data "{\"type\":\"A\",\"name\":\"${h}${q}${zones[${g}]}\",\"content\":\"${newip}\",\"proxied\":true}")
						else echo Proxy Value Not Defined in Custom $a; echo Attempting to Update Record Without Proxy Definition in Request
						update=$(curl -s -X PUT https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier -H "X-Auth-Email: ${!u}" -H "X-Auth-Key: ${!p}" -H "Content-Type: application/json" --data "{\"type\":\"A\",\"name\":\"${h}${q}${zones[${g}]}\",\"content\":\"$newip\"}")
						fi
						if [[ $update == *"\"success\":false"* ]]; then
							message="API UPDATE FAILED FOR: \"${h}${q}${zones[${g}]}\" DUMPING RESULTS:\n$update"
							echo -e "$message"
						else
							message="IP changed to: ${newip}\nProxied: ${proxied}"
							echo -e "$message"
						fi
						break;
						fi
					done;
					((s++));
				done;
			done;
		else echo No Zones Listed... Continuing...
		fi
	done;
	((a++));
done;
echo "$newip" > $ip_file

	if [ "${2}" != "" ]; then
        	if [ -e ${2} ]; then
                	source ${2} ${3};
        	elif [ -e ${updatedir}/${2} ]; then
                	source ${updatedir}/${2} ${3};
        	else
                	echo Secondary Script Specified But File Not Found... Continuing...
        	fi
	fi
	
	else	
		exit
	fi
fi
