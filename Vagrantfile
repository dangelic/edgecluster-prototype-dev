# -*- mode: ruby -*-
# vi: set ft=ruby :

# --- This script sets up multiple linked VMs for a k3s Edge-Cluster lab environment via Vagrant and VirtualBox

ENV["VAGRANT_NO_PARALLEL"] = "yes"

require "json"

# Define the machines (n-master and n-worker (edge-nodes) in ./vm_config/*_node_config.json)

# Note: High-Availability-Cluster (HA) with multiple masters are possible
# Note: Specify the IP-realm in config to not be in collision!
master_node_definition = JSON.parse(File.read("./vm_config/master_node_config.json"))
num_master_nodes = master_node_definition.size
worker_node_definition = JSON.parse(File.read("./vm_config/worker_node_config.json"))
num_worker_nodes = worker_node_definition.size

Vagrant.configure(VAGRANTFILE_API_VERSION = "2") do |config|

	# --- Basic Vagrant options
	config.vm.box_check_update = true
	config.env.enable # Enable vagrant-env(./.env)

	# --- ENVs to be set in .env (required)
	VM_OS 			= ENV["VM_OS"]
	K3S_CHANNEL 	= ENV["K3S_CHANNEL"]
	K3S_VERSION 	= ENV["K3S_VERSION"]
	K3S_TOKEN 		= ENV["K3S_TOKEN"]
	FLANNEL_BACKEND = ENV["FLANNEL_BACKEND"]
	DOMAIN			= ENV["DOMAIN"]
	VM_ALIAS_SUFFIX	= ENV["NAMING_SUFFIX"]

	MAIN_MASTER_HOSTNAME = master_node_definition[0]["hostname"]


	# --- Provisions n Master-Nodes
	(1..num_master_nodes).each do |master|
		config.vm.define "#{master_node_definition[master-1]["vname"]}" do |node|
			node.vm.box = VM_OS
			node.vm.hostname = "#{master_node_definition[master-1]["hostname"]}.#{DOMAIN}" # FQDN
			node.vm.network :private_network, ip: master_node_definition[master-1]["ip"]
			node.vm.network :forwarded_port, guest: 8001, host: 8001+master-1 # k8s-API

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
			if master_node_definition[master-1]["gui_enabled"] then node.vm.provision "shell", path: "cluster_bootstrap/setup_xfce_gui.sh" end
			node.vm.provision "shell", path: "cluster_bootstrap/setup_base.sh", args: ["master"]
      		node.vm.provision "shell", path: "cluster_bootstrap/setup_k3s.sh", args: [
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

			# --- Additional deployments
			#

			node.vm.provision :shell, :inline => <<-SCRIPT 
			neofetch 
			SCRIPT
		end
	end
	
	# --- Provisions n Worker-Nodes (Edge-Nodes)
	(1..num_worker_nodes).each do |worker|
		config.vm.define "#{worker_node_definition[worker-1]["vname"]}" do |node|
			node.vm.box = VM_OS
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
			if worker_node_definition[worker-1]["gui_enabled"] then node.vm.provision "shell", path: "cluster_bootstrap/setup_xfce_gui.sh" end
			node.vm.provision "shell", path: "cluster_bootstrap/setup_base.sh", args: ["worker"]
      		node.vm.provision "shell", path: "cluster_bootstrap/setup_k3s.sh", args: [
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
			
			node.vm.provision :shell, :inline => <<-SCRIPT 
			neofetch 
			SCRIPT
		end
	end
end
