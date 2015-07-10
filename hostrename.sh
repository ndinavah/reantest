# Declarations
IFCONFIG="/sbin/ifconfig"
DNS_DOMAIN="i4c.aws"
TIME_STAMP="$(date --iso).$(date '+%s')"

# This line will fetch HString value from /bootstrap/HString file
[ -f "/bootstrap/HString" ] || { echo 'Error: HString file not found!'; exit 127; }
HString=$(cat /bootstrap/HString)

# Find IP Address of eth0
IPADDR=$($IFCONFIG eth0|grep -w inet|awk '{print $2}'|cut -d: -f2)

# This will fetch last two octects of IP Address
OCT3=$(echo $IPADDR|cut -d. -f3)
OCT4=$(echo $IPADDR|cut -d. -f4)

# Construct hostname
NEW_HOSTNAME=${HString}-${OCT3}-${OCT4}
NEW_FQDN=${NEW_HOSTNAME}.${DNS_DOMAIN}

# backup hosts file and update
cp /etc/hosts /etc/hosts.backup-${TIME_STAMP}
sed -i "/#AddedByHostRename$/d" /etc/hosts
echo "${IPADDR}   ${NEW_HOSTNAME}    ${NEW_FQDN} #AddedByHostRename" >> /etc/hosts

# Set hostname and make it persistant
echo `hostname` > /bootstrap/oldhostname-${TIME_STAMP}
hostname ${NEW_HOSTNAME}


if [ -f "/etc/lsb-release" ]; then # For ubuntu this will update HOSTNAME value in /etc/hostname
                cp /etc/hostname /etc/hostname-${TIME_STAMP}
                echo ${NEW_HOSTNAME} > /etc/hostname
else
                # For amazon, redhat and centos linux this will update HOSTNAME value in /etc/sysconfig/network file
                cp /etc/sysconfig/network /etc/sysconfig/network-${TIME_STAMP}
                sed -i -e "s/^HOSTNAME=.*/HOSTNAME=${NEW_HOSTNAME}/" /etc/sysconfig/network
fi
