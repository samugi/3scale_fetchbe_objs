# 3scale_fetchbe_objs
Script to extract details about 3scale resources that can affect the space utilization on backend Redis

## Run the script
```
sudo chmod +x fetchinfo.sh
./fetchinfo.sh https://ADMIN_PORTAL_URL ACCESS_TOKEN
```

## What is being fetched
```
# of services
# of metrics per service
# of applications (total)
# of application plans (total)
# of limits per application plan
```
