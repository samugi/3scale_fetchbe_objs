#!/bin/bash

admin_portal=$1
access_token=$2

display_usage(){
	echo -e "Usage:\n$0 <https://ADMIN_PORTAL_URL> <ACCESS_TOKEN>"
}

PER_PAGE=50

if [  $# -le 1 ]
then
	display_usage
	exit 1
fi

declare -a service_ids

# SERVICES
url="$admin_portal/admin/api/services.json"
echo "using url: $url"
for ((i=1;;i+=1)); do
	resp=$(curl -sk -X GET "$url?access_token=$access_token&page=$i&per_page=$PER_PAGE" | jq -r '.services[] | .service.id | @sh')
	if [ -z "$resp" ]; then
		break;
	else
		service_ids+=(${resp})
	fi

	# last page
	if [ ${#resp[@]} -lt $PER_PAGE ]; then
		break;
	fi
done
echo "there are ${#service_ids[@]} services"

# METRICS
for id in ${service_ids[@]}; do
	count=$(curl -sk -X GET "$admin_portal/admin/api/services/$id/metrics.json?access_token=$access_token" | jq -r '.metrics' | jq length)
	echo -e "service $id has $count metrics"
done

# APPLICATIONS
application_count=0 
for ((i=1;;i+=1)); do
    resp=$(curl -sk -X GET "$admin_portal/admin/api/applications.json?access_token=$access_token&page=$i&per_page=$PER_PAGE" | jq -r '.applications' | jq length)
    if [ ! -z "$resp" ] && [ $resp -ne 0 ]; then
		application_count=$((application_count+resp))
    else
        break;
    fi
done
echo "there are $application_count applications"

# APPLICATION PLANS
declare -a application_plan_ids

app_plan_ids_resp=$(curl -sk -X GET "$admin_portal/admin/api/application_plans.json?access_token=$access_token" | jq -r '.plans[] | .application_plan.id | @sh')
if [ ! -z "$app_plan_ids_resp" ]; then
    application_plan_ids+=(${app_plan_ids_resp})
fi
echo "there are ${#application_plan_ids[@]} application plans"


# LIMITS
for id in ${application_plan_ids[@]}; do
	for ((i=1;;i+=1)); do
        	count=$(curl -sk  -X GET "$admin_portal/admin/api/application_plans/$id/limits.json?access_token=$access_token&page=$i&per_page=$PER_PAGE" | jq -r '.limits' | jq length)
		if [ $count != 0 ]; then
            echo "application plan $id has $count limits"
        else
           	break;
        fi
	done
done
