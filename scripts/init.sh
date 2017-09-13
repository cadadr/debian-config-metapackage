# Initialise a Debian/Ubuntu installation.

set -e

. /etc/os-release

say () {
    echo === $@
}

### Add third-party repos:
#### Syncthing:
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
echo 'deb https://apt.syncthing.net/ syncthing stable' |\
    sudo tee /etc/apt/sources.list.d/syncthing.list
sudo chmod 644 /etc/apt/sources.list.d/syncthing.list

### Install packages:
say Installing system packages...
sudo apt-get update

(
    if which make >/dev/null 2>/dev/null; then
	make debian-init
    else
	sudo apt-get install ./myconfig.deb && make debian-config
    fi \
	|| (echo Failed installing system programmes && exit 1)
)

### Add the user:
u=myuser
if id g 2>/dev/null >/dev/null; then
    say User $u exists already.
else
    say Adding user $u...
    sudo useradd -c 'Joe Maintainer' -d /home/$u \
	 -G sudo,adm,cdrom,dip,plugdev,lpadmin -m -s /bin/bash -U -u 1881 $u \
	|| echo Failed adding user $u && exit 1;
    sudo groupmod -g 1881 $u || echo Failed setting GID for $u && exit
fi

### Start system services:
say Starting system services...
for service in nginx syncthing@$u; do
    (systemctl status $service | grep 'enabled;') >/dev/null \
	|| sudo systemctl enable $service;
    (systemctl status $service | grep 'active (running)') >/dev/null \
	|| sudo systemctl start $service;
done

say Done.  You may want to reboot your computer.
