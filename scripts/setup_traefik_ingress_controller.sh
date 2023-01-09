#!/bin/bash

echo "###########################################################################"
echo "Setup Traefik as the clusters' load balancer"
echo "###########################################################################"

HOME_V="/home/vagrant"

# --- Reference
# File: https://github.com/rgl/k3s-vagrant/blob/master/provision-k3s-server.sh

#------------------------------------------------------------------------

echo 'configuring Traefik...'
# apt-get install -y python3-yaml
python3 - <<'EOF'
import difflib
import io
import sys
import yaml


# configure the yaml library to write multiline strings using the block scalar
# style syntax.
# NB this uses a modified version of https://github.com/yaml/pyyaml/issues/240#issuecomment-1096224358:
#      * uses the `in` operator.
def str_presenter(dumper, data):
    """configures yaml for dumping multiline strings
    Ref: https://stackoverflow.com/questions/8640959/how-can-i-control-what-scalar-form-pyyaml-uses-for-my-data"""
    if '\n' in data:
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
    return dumper.represent_scalar('tag:yaml.org,2002:str', data)
yaml.add_representer(str, str_presenter)
yaml.representer.SafeRepresenter.add_representer(str, str_presenter) # to use with safe_dum

config_path = '/var/lib/rancher/k3s/server/manifests/traefik.yaml'
config_orig = open(config_path, 'r', encoding='utf-8').read()

documents = list(yaml.load_all(config_orig, Loader=yaml.FullLoader))
d = documents[1]
values = yaml.load(d['spec']['valuesContent'], Loader=yaml.FullLoader)

# configure logging.
# NB you can see the logs with:
#       kubectl -n kube-system logs -f -l app.kubernetes.io/name=traefik
values['logs'] = {
    'general': {
        'level': 'WARN',
    },
    'access': {
        'enabled': True,
    },
}

# configure traefik to skip certificate validation.
# NB this is needed to expose the k8s dashboard as an ingress at
#    https://kubernetes-dashboard.example.test.
# NB without this, traefik returns "internal server error".
# TODO see how to set the CAs in traefik.
# NB this should never be done at production.
values['additionalArguments'] = [
    '--serverstransport.insecureskipverify=true'
]

# expose the traefik port so we can access the api/dashboard from an ingress.
values['ports']['traefik'] = {
    'expose': True,
}

# save values back.
config = io.StringIO()
yaml.dump(values, config, default_flow_style=False)
d['spec']['valuesContent'] = config.getvalue()

# show the differences and save the modified yaml file.
config = io.StringIO()
yaml.dump_all(documents, config, default_flow_style=False)
config = config.getvalue()
sys.stdout.writelines(difflib.unified_diff(config_orig.splitlines(1), config.splitlines(1)))
open(config_path, 'w', encoding='utf-8').write(config)
EOF

#------------------------------------------------------------------------

sed -i "s/{{DOMAIN}}/$(hostname --domain)/g" $HOME_V/manifests/traefik_ingress_controller/ingress.yaml
kubectl apply -n kube-system -f $HOME_V/manifests/traefik_ingress_controller/ingress.yaml
sed -i "s/$(hostname --domain)/{{DOMAIN}}/g" $HOME_V/manifests/traefik_ingress_controller/ingress.yaml