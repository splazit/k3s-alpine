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
 | |/ /|__ </ __|
 |   < ___) \__ \
 |_|\_\____/|___/   _____ _ __
 / __|/ _ \ '__\ \ / / _ \ '__|
 \__ \  __/ |   \ V /  __/ |
 |___/\___|_|    \_/ \___|_|
EOF

if [ $(hostname) = "server1" ]
then 
  curl -sfL https://get.k3s.io \
    | \
        K3S_TOKEN="$k3s_token" \
        sh -s -- \
            server \
            --cluster-init \
            --bind-address "$ip_address" \
            --no-deploy traefik \
            --node-ip "$ip_address" \
            --cluster-cidr '10.12.0.0/16' \
            --service-cidr '10.13.0.0/16' \
            --cluster-dns '10.13.0.10' \
            --cluster-domain 'cluster.local' \
            --flannel-iface 'eth1'
else
  curl -sfL https://get.k3s.io \
    | \
        K3S_TOKEN="$k3s_token" \
        K3S_URL="https://$master_server_ip:6443" \
        sh -s -- \
            server \
            --bind-address "$ip_address" \
            --no-deploy traefik \
            --node-ip "$ip_address" \
            --cluster-cidr '10.12.0.0/16' \
            --service-cidr '10.13.0.0/16' \
            --cluster-dns '10.13.0.10' \
            --cluster-domain 'cluster.local' \
            --flannel-iface 'eth1'
fi            

# wait for this node to be Ready.
$SHELL -c 'node_name=$(hostname); echo "waiting for node $node_name to be ready..."; while [ -z "$(kubectl get nodes $node_name | grep -E "$node_name\s+Ready\s+")" ]; do sleep 3; done; echo "$(kubectl get nodes)"'

# wait for the kube-dns pod to be Running.
$SHELL -c 'while [ -z "$(kubectl get pods -A --selector k8s-app=kube-dns | grep -E "\s+Running\s+")" ]; do sleep 3; done; echo "kube-dns ready!"'