# -*- mode: ruby -*-
# vi: set ft=ruby :

# --- This script sets up multiple linked VMs for a k3s Edge-Cluster lab environment via Vagrant and VirtualBox as provider
# --- In addition, an additional VM serving as a Rancher server to manage the Edge-Cluster is provisioned

ENV["VAGRANT_NO_PARALLEL"] = "yes"

require "json"

# Define the machines (1...n Rancher server(s), 1...n Master(s) and 1...n Worker(s) (Edge-Node(s)) in ./vm_config_cluster/*.config.json)

# Note: High-Availability-Cluster (HA) with multiple masters are possible
# Note: HA Rancher setup tbd.
# Note: Specify the IP-realm in config to not be in collision! Mind .env IP-Range for Load Balancing
master_node_definition = JSON.parse(File.read("./vm_config_cluster/master_node.config.json"))
num_master_nodes = master_node_definition.size
worker_node_definition = JSON.parse(File.read("./vm_config_cluster/worker_node.config.json"))
num_worker_nodes = worker_node_definition.size
rancher_server_definition = JSON.parse(File.read("./vm_config_cluster/rancher_server.config.json"))
num_rancher_server = rancher_server_definition.size

Vagrant.configure(VAGRANTFILE_API_VERSION = "2") do |config|

	# --- Basic Vagrant options
	config.vm.box_check_update = false
	config.env.enable # Enable vagrant-env(./.env)

	# --- ENVs to be set in .env (required)
	VM_BOX_OS_RANCHERSERVER = ENV["VM_BOX_OS_RANCHERSERVER"]
	VM_BOX_OS_MASTER		= ENV["VM_BOX_OS_MASTER"]
	VM_BOX_OS_WORKER		= ENV["VM_BOX_OS_WORKER"]
	K3S_CHANNEL 			= ENV["K3S_CHANNEL"]
	K3S_VERSION 			= ENV["K3S_VERSION"]
	K3S_TOKEN 				= ENV["K3S_TOKEN"]
	FLANNEL_BACKEND 		= ENV["FLANNEL_BACKEND"]
	DOMAIN					= ENV["DOMAIN"]
	VM_ALIAS_SUFFIX			= ENV["NAMING_SUFFIX"]
	METALLB_CHART_VERSION	= ENV["METALLB_CHART_VERSION"]
	LB_IP_RANGE				= ENV["LB_IP_RANGE"]
	RANCHER_ENABLED			= ENV["RANCHER_VERSION"]
	RANCHER_VERSION			= ENV["RANCHER_VERSION"]

	MAIN_MASTER_HOSTNAME = master_node_definition[0]["hostname"]

	# Scripts to run post-provisioning phase on host system
	# config.vm.provision "shell", path: "scripts_post_provision/setup_ssh.sh", run: "once"

	# --- Provisions 1...n Rancher server(s)
	if RANCHER_ENABLED == "true" then
		end
		(1..num_rancher_server).each do |rancher|
			config.vm.define "#{rancher_server_definition[rancher-1]["vname"]}" do |node|
				node.vm.box = VM_BOX_OS_RANCHERSERVER
				node.vm.hostname = "#{rancher_server_definition[rancher-1]["hostname"]}.#{DOMAIN}" # FQDN
				node.vm.network :private_network, ip: rancher_server_definition[rancher-1]["ip"]
				# Forwards port 8080 of every VM (Rancher server 1...n) to 9090, 9091 on host, ... matching Rancher server 1, 2, ...
				node.vm.network :forwarded_port, guest: 8080, host: 9090+rancher-1

				# --- Setup dir sync only for Rancher server
				node.vm.provision "file", source: "tmp", destination: "$HOME/tmp" # Bootstrap secrets

				node.vm.provider "virtualbox" do |v|
					# v.linked_clone = true # Reduce provision overhead
					v.name = "#{rancher_server_definition[rancher-1]["hostname"]}#{VM_ALIAS_SUFFIX}"
					v.memory = rancher_server_definition[rancher-1]["mem"]
					v.cpus = rancher_server_definition[rancher-1]["cpu"]
					v.gui = rancher_server_definition[rancher-1]["gui_enabled"]
				end

				node.vm.provision "hosts" do |hosts|
					hosts.autoconfigure = true
					hosts.sync_hosts = true
					hosts.add_localhost_hostnames = false
				end
				
				# --- Scripts: Server / VM provisioning
				node.vm.provision "shell", path: "bootstrap_rancher_server/setup_base_opensuse_leap15-1.sh"
				# node.vm.provision "shell", path: "bootstrap_rancher_server/setup_rancher_2.sh", args: [RANCHER_VERSION]
			end
		end
	end

	# --- Provisions 1...n Master-Node(s)
	(1..num_master_nodes).each do |master|
		config.vm.define "#{master_node_definition[master-1]["vname"]}" do |node|
			node.vm.box = VM_BOX_OS_MASTER
			node.vm.hostname = "#{master_node_definition[master-1]["hostname"]}.#{DOMAIN}" # FQDN
			node.vm.network :private_network, ip: master_node_definition[master-1]["ip"]
			# node.vm.network :forwarded_port, guest: 8001, host: 8001+master-1 # k8s-API

			# --- Setup dir sync only for masters
			node.vm.provision "file", source: "scripts", destination: "$HOME/scripts" # Scripts to apply additional services, ingresses, rbac, service accounts, ...
			node.vm.provision "file", source: "manifests", destination: "$HOME/manifests" # Manifests to use in shell scripts to apply
			node.vm.provision "file", source: "tmp", destination: "$HOME/tmp" # Secrets
			node.vm.provision "file", source: "GitOps", destination: "$HOME/GitOps" # GitOps with ArgoCD

			node.vm.provider "virtualbox" do |v|
				v.linked_clone = true # Reduce provision overhead
				v.name = "#{master_node_definition[master-1]["hostname"]}#{VM_ALIAS_SUFFIX}"
				v.memory = master_node_definition[master-1]["mem"]
				v.cpus = master_node_definition[master-1]["cpu"]
				v.gui = master_node_definition[master-1]["gui_enabled"]
			end

			node.vm.provision "hosts" do |hosts|
				hosts.autoconfigure = true
				hosts.sync_hosts = true
				hosts.add_localhost_hostnames = false
			end
			
			# --- Scripts: Cluster / VM provisioning

			# TODO: tbd. GUI
			# if master_node_definition[master-1]["gui_enabled"] then node.vm.provision "shell", path: "bootstrap_edgecluster_k3s/setup_xfce_gui.sh" end
			node.vm.provision "shell", path: "bootstrap_edgecluster_k3s/setup_base.sh", args: ["master"]
      		node.vm.provision "shell", path: "bootstrap_edgecluster_k3s/setup_k3s.sh", args: [
				    "master",
        		master == 1 ? "init" : "join",
        		K3S_CHANNEL,
				    K3S_VERSION,
        		K3S_TOKEN,
        		FLANNEL_BACKEND,
        		DOMAIN,
				    MAIN_MASTER_HOSTNAME,
				    master_node_definition[master-1]["ip"]
      		]

			# Metallb as LoadBalancer
			if master == 1 then node.vm.provision "shell", path: "bootstrap_edgecluster_k3s/setup_metallb.sh", args: [METALLB_CHART_VERSION, LB_IP_RANGE] end
		end
	end
	
	# --- Provisions 1...n Worker-Node(s) -> Edge-Nodes
	(1..num_worker_nodes).each do |worker|
		config.vm.define "#{worker_node_definition[worker-1]["vname"]}" do |node|
			node.vm.box = VM_BOX_OS_WORKER
			node.vm.hostname = "#{worker_node_definition[worker-1]["hostname"]}.#{DOMAIN}" # FQDN
			node.vm.network :private_network, ip: worker_node_definition[worker-1]["ip"]
			node.vm.provider "virtualbox" do |v|
				v.linked_clone = true # Reduce provision overhead
				v.name = "#{worker_node_definition[worker-1]["hostname"]}#{VM_ALIAS_SUFFIX}"
				v.memory = worker_node_definition[worker-1]["mem"]
				v.cpus = worker_node_definition[worker-1]["cpu"]
				v.gui = worker_node_definition[worker-1]["gui_enabled"]
			end

			node.vm.provision "hosts" do |hosts|
				hosts.autoconfigure = true
				hosts.sync_hosts = true
				hosts.add_localhost_hostnames = false
			end
			
			# --- Scripts: Cluster / VM provisioning
			# if worker_node_definition[worker-1]["gui_enabled"] then node.vm.provision "shell", path: "bootstrap_edgecluster_k3s/setup_xfce_gui.sh" end
			node.vm.provision "shell", path: "bootstrap_edgecluster_k3s/setup_base.sh", args: ["worker"]
      		node.vm.provision "shell", path: "bootstrap_edgecluster_k3s/setup_k3s.sh", args: [
        		"worker",
				    "join",
        		K3S_CHANNEL,
				    K3S_VERSION,
            K3S_TOKEN,
        		FLANNEL_BACKEND,
        		DOMAIN,
				    MAIN_MASTER_HOSTNAME,
				    worker_node_definition[worker-1]["ip"]
      		]
		end
	end
end
