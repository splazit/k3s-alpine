#!/bin/bash
set -eux

k3s_token="$1"; shift
ip_address="$1"; shift
master_server_ip="$1"; shift

# configure the motd.
# NB this was generated at http://patorjk.com/software/taag/#p=display&f=Big&t=k3s%0Aserver.
#    it could also be generated with figlet.org.
cat >/etc/motd <<'EOF'
  _    ____
 | |  |___ \
 | | __ __) |___
 | |/ /|__ </ __|        _
 |   < ___) \__ \       | |
 |_|\_\____/|___/_ _ __ | |_
  / _` |/ _` |/ _ \ '_ \| __|
 | (_| | (_| |  __/ | | | |_
  \__,_|\__, |\___|_| |_|\__|
         __/ |
        |___/
EOF

curl -sfL https://get.k3s.io \
  | \
      K3S_TOKEN="$k3s_token" \
      K3S_URL="https://$master_server_ip:6443" \
      sh -s -- \
          agent \
          --node-ip "$ip_address" \
          --flannel-iface 'eth1'
