# Azure-IaaS-Project

## Introduction

### Motivation
Learn and build a cloud-based system leveraging Infrastructure as a Service (IaaS) to maximize flexibility and cost-efficiency

### Problem 
Make a simple web application with strong data protection, featuring multi-layered security, robust encryption, and clear user access controls. This project highlights secure data management on cloud platforms and provides practical insights for designing scalable, secure applications.

## Propose solution

### Overview

To meet the requirements for data security, user access control, and system scalability, the team decided to adopt two notable technological architectures: **Securely Managed Web Applications** and **Siemens Teamcenter Baseline Architecture**.

![](https://i.imgur.com/X4FKNxw.png)


- Resources are organized into distinct Resource Groups for effective management.
- Hub Virtual Network serves as the central hub for connectivity, while Spoke Virtual Networks host application components.
- Users access via the Internet and Azure Firewall Subnet. Admins connect securely via Azure Bastion Subnet without public IP exposure.
- Secure connectivity to AWS is enabled using AWS Site-to-Site VPN and Azure VPN Gateway Subnet.
- Load Balancer acts as a reverse proxy, routing traffic to backend subnets. Internal Load Balancer coordinates traffic between Frontend and Backend Subnets for seamless application performance.



### Definition

**Users and Administrators**:
- Client: End users accessing the system via the Internet
- Admin: System administrators.

**AWS Connection**: 
- AWS EC2 Instance (AWS): Acts as a data source, communicating with Azure via a VPN connection.
- AWS Site-to-Site VPN (AWS): Establishes a secure VPN channel between AWS and Azure.
- VPN Gateway Subnet (Azure): Manages the VPN connection from AWS within Azure.
- Local Network Gateway (Azure): Represents the AWS network in Azure, storing AWS VPN and IP address details.

**Resource Management**: 
- Resource Groups: Organizes related resources to ensure efficient management and separation based on function or environment.

**Network Infrastructure**:
- Hub-Spoke Virtual Network: The central connectivity structure of the system, integrating services like the Azure Firewall Subnet and Azure Bastion Subnet.
- Azure Firewall Subnet: Controls access from the Internet to the system.
- Azure Bastion Subnet: Provides secure administrative access without requiring a public IP

**Traffic Management**:
- Load Balancer: Distributes traffic to backend subnets.
- Internal Load Balancer: Balances traffic between backend and frontend components.

**Compute Infrastructure**: 
- Proximity Placement Groups: Ensures low latency by placing application servers physically close together in the data center.
- Frontend Subnet: Handles user interface and interactions.
- Backend Subnet: Handles business logic and data storage.

**Data Storage**
- Azure Disk: Centralized data storage for the system.



# Hướng dẫn sử dụng  

1. Cài Azure CLI, đăng nhập bằng `az login`, chạy `az account list --output table` để lấy `subscription_id`.  
2. Vào file `dev/versions.tf`, chỉnh lại `subscription_id` vừa lấy.  
3. Tạo ssh-key 
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/my-key
4. Vào folder `dev`, chạy lần lượt các lệnh:  
   ```bash
   terraform init  
   terraform plan  
   terraform apply  


