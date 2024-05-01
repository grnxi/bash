#!/bin/bash

# Define the output file
output_file="output.csv"

# Get the host IP address
host_ip=$(hostname -I | awk '{print $1}')
# Get the host hostname
host_hostname=$(hostname)
# Write the host VM information to the CSV file
echo "Host IP Address,Host Hostname" > $output_file
echo "$host_ip,$host_hostname" >> $output_file

# Write the header to the CSV file
echo "Container Name,Image Name,Status,Host VM Information,Port Mapping" >> $output_file
# Get the container names
container_names=$(docker ps --format "{{.Names}}")
# Loop through each container and get the container information
for container_name in $container_names; do
    # Get the image name
    image_name=$(docker inspect --format='{{.Config.Image}}' $container_name)
    # Remove the registry.n4monitoring.co.uk from the image name
    image_name=$(echo $image_name | sed 's/registry.n4monitoring.co.uk\///g')
    # Get the host VM information
    host_vm=$(hostname)
    # Get the port mapping
    port_mapping=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}} {{if $conf}} {{$p}} -> {{(index $conf 0).HostPort}} {{else}} "" {{end}} {{end}}' $container_name)
    # Remove the double quotes from the port mapping
    port_mapping=$(echo $port_mapping | sed 's/"//g')
    # Write the data to the CSV file
    echo "$container_name,$image_name,$host_vm,$port_mapping" >> $output_file
done
