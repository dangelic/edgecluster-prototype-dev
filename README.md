
# Maintenance 4.0 - Master Thesis practical project of Leonardo d'Angelico

This repository contains the source code of the practical project within the scope of a Masters Thesis at the Chair of Information Systems @ University of Leipzig.

In this project, a Kubernetes lab/sandbox environment will be developed to meet the needs of modern manufacturing involving Industrial Internet of Things (IIoT) in context of Edge-Computing in the aerospace industry. Specifically, Kubernetes will be "pushed to the Edge" using Rancher's lightweight Kubernetes distribution K3s.

The entire Tech-Stack to meet the required use cases is ***open source***.


## The Lab-Environment

### Description

Virtual Linux machines (VMs) are used to test the application of the Edge-Cluster. This offers the advantage of being able to flexibly make configurations (such as operating system, memory, RAM, CPU, storage, network, ... of each node individually) and thus sufficiently simulate a productive environment. 
The virtual machines run on a host (e.g. a simple business/home computer, independent of the operating system) via the hypervisor software VirtualBox from Oracle.
To make configuration and provisioning as simple as possible, Vagrant from HashiCorp is used. The goal is to be able to deploy the entire Edge-Cluster architecture as VMs via a single *vagrant up* command after installing Vagrant. This is to circumvent the familiar "it only works on my machine...".

### What is provisioned

Provisioned is a highly available, network-connected Edge-Cluster architecture with multiple Master-Nodes, Worker-Nodes (Edge-Nodes) and Rancher server(s). 
The Rancher dashboard provisioned on the Rancher server(s) is responsible for managing the entire cluster via GUI. 
Prometheus and Grafana are used to provide visualization and analysis of data streams. The cluster is http(s)-accessible via Traefik Ingress. A dedicated L2 load balancer (MetalLB) ensures sufficient load balancing. Finally, a connector is used to connect the IIoT devices to the appropriate Edge-Nodes.

**The following documents how to provision the cluster or configure it afterwards.**

**Note:** The commands are adapted for Linux-use, but the environment can be provisioned on every modern system.

## Documentation

### A. Provision the Lab-Environment

#### 1. VirtualBox download
VirtualBox as the VM hypervisor must simply be downloaded and installed - no further configuration is needed. 
To download VirtualBox for a system, the following link can be used:

[**Download VirtualBox for Linux, macOS or Windows** (Oracle)](https://www.virtualbox.org/wiki/Downloads)

#### 2. Vagrant installation and plugins

To install Vagrant as the VM provisioning tool on the system, the following documentation can be used:

[**Installing Vagrant on Linux, macOS or Windows** (HashiCorp)](https://developer.hashicorp.com/vagrant/downloads)

**Note:** After installation, plugins have to be installed via the following commands:

```vagrant plugin install vagrant-env```

#### 3. Repository clone

After git is installed, use the following command to clone this repository:

```git clone https://github.com/dangelic/edgecluster-prototype-dev```

**Note:** To use Vagrant (provisioning and all the other operations regarding a specific environment), one has to be in the explicit directory where the Vagrantfile of this environment lives:

```cd edgecluster-prototype-dev```

#### 4. Configure basic VM properties
The laboratory environment is flexible in configuration to a certain extent. 
Master-Nodes, Worker-Nodes (Edge-Nodes) and the Rancher server(s) can be configured via the .json files in the /node-config folder. 
In particular, nodes can be added/removed here by adding/removing individual elements in the .json array (1..n).

**Note:** Only the default configuration is tested.

In this directory, a sample .env file (.env-sample) is also given for further customization. 
This file contains the environment variables which can be adapted if needed. 
As a file called ".env" must be provided for the provisioning to work, the sample file has to be copied and renamed:

```cp .env-sample .env```

**Note:** Keeping the sample values after renaming is sufficient for the cluster to function.

#### Start VM provisioning phase

Now, the following command can be run to start provisioning and base-configuring the VMs:

```vagrant up```

**Note:** The provisioning of the machines can take up to 20 Minutes or (way) more, depending on the amount of nodes chosen.
A sufficient/stable internet connection (and patience...) is highly required.

### B. Use the Lab-Environment

Placeholder...


## Open-Source Tech-Stack

- [**Argo CD --latest:stable** by Argo Project](https://argo-cd.readthedocs.io/en/stable/) - *As GitOps-enabler* - A declarative, GitOps continuous delivery tool for Kubernetes.
- [**Grafana --latest:stable** by Grafana Labs](https://grafana.com/) -*As data visualization dashboard* - Grafana is a data visualization and monitoring platform that allows users to create and share interactive, customizable dashboards for monitoring and analyzing time-series data from various data sources.
- [**Helm --latest:stable** by the Helm Authors](https://helm.sh/) - *As the clusters' Package Manager* - Helm is a package manager for Kubernetes that helps to simplify the installation, configuration and management of Kubernetes applications using easy to use, reusable charts.
- [**K3s 1.25.2** by Rancher](https://k3s.io/) - *As Kubernetes Distribution* - K3s is a lightweight Kubernetes distribution, designed for easy deployment and management of small to medium-sized clusters. It is intended for use in resource-constrained environments such as edge computing and IoT.
- [**MetalLB --latest:stable** by the MetalLB Contributers](https://metallb.universe.tf/) - *As the clusters' Load Balancer* - MetalLB is a load-balancer implementation for bare metal Kubernetes clusters that operates at Layer 2, allowing to expose services on a cluster using standard protocols such as BGP or ARP.
- [**Prometheus --latest:stable** by the Prometheus Authors](https://prometheus.io/docs/prometheus/latest/configuration/configuration/) - *As the cluster monitoring solution* - Prometheus is a Kubernetes native monitoring tool that allows to collect and query time-series data from pods, nodes and other Kubernetes objects and alert on defined conditions.
- [**Rancher 2.7** by SUSE](https://www.suse.com/c/rancher_blog/whats-new-in-rancher-2-7/) - *As Cluster Management server* - Rancher is a container orchestration platform that provides a simple and user-friendly way to deploy and manage Kubernetes clusters.
- [**Traefik <latest>** by traefiklabs](https://traefik.io/traefik/) - *As the clusters' Ingress controller* - Traefik is a modern, dynamic Ingress controller that routes incoming traffic to the correct service based on its configuration and the label on the service, acting as a reverse proxy and load balancer for microservices at Layer 7 of the OSI Model.
- [**Vagrant 2.3.4** by HashiCorp](https://www.vagrantup.com/) - *As VM provisioner* - Vagrant is a tool for building and managing virtual machine environments, allowing developers to create and configure reproducible development environments via hypervisors like VirtualBox.
- [**VirtualBox 6.1** by Oracle](https://www.virtualbox.org/) - *As hypervisor* - Oracle VirtualBox is a free and open-source hypervisor software that allows users to run multiple operating systems on a single physical machine.
## Author

- Leonardo d'Angelico - GitHub: [@dangelic](https://www.github.com/dangelic)
