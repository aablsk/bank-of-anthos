set -Eeuo pipefail

echo '🚀  Starting ./03-wait-for-asm.sh'
echo '🕰  Waiting for GKE cluster setup to complete provisioning managed Service Mesh with managed Control Plane and managed Data Plane.'
echo '🍵 🧉 🫖  This will take some time - why not get ANOTHER hot beverage?  🍵 🧉 🫖'
while true
do 
    output=$( gcloud container fleet mesh describe | grep "      state: " | grep -v ACTIVE ) || output=""
    if ! [ -n "$output" ]
    then
        break
    else
        sleep 15
        echo -ne "."
    fi
done
echo '✅  Finished ./03-wait-for-asm.sh'