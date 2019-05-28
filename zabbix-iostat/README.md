# Installation

- import IostatTemplate.xml into zabbix
- install sysstat package if it is not installed
- run install.sh as root

You should see answer from zabbix agent with discovered disks.
Example:
```
# zabbix_agentd -t iostat.discovery
iostat.discovery                              [t|{
  "data": [
    {
      "{#HARDDISK}": "nvme3n1"
    }, 
    {
      "{#HARDDISK}": "nvme1n1"
    }, 
    {
      "{#HARDDISK}": "nvme2n1"
    }, 
    {
      "{#HARDDISK}": "nvme0n1"
    }
  ]
}]
```
