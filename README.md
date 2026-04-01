# Terraform-Managed Three-Tier WordPress Architecture ☁️

![Build Status](https://img.shields.io/github/actions/workflow/status/penducky/terraform-wordpress/terraform_plan.yaml?style=flat-square&label=Build&logo=github)
![AWS](https://img.shields.io/badge/Hosted_on-AWS-FF9900?style=flat-square&logo=amazon-aws&logoColor=yellow)
![Cost](https://img.shields.io/badge/Cost-Standard_Rates-orange?style=flat-square)

A fully provisioned, highly available Three-Tier WordPress architecture engineered on AWS using Terraform for Infrastructure as Code (IaC).

<div align="center">
<img src=".github/assets/wordpress-site.png" alt="Wordpress Site" width="1080">
</div>

### 🔗 [View Live Site](https://wordpress.penducky.click/wordpress)
![Website Status](https://img.shields.io/website?url=https%3A%2F%2Fwordpress.penducky.click)

Due to budget constraints, the website is not hosted 24/7.


---


## 🎯 Project Goal
This project was made to demonstrate hands-on IaC skills using Terraform and AWS infrastructure to provision a scalable server environment capable of hosting a functioning WordPress site, one of the most popular content management systems on the internet. That's why I write everything here by myself, without following any tutorial.

## 🏗️ Architecture & Engineering Decisions
The infrastructure is designed for high availability, security, and automated scaling.

![Architecture Diagram](.github/assets/wordpress-infrastructure-diagram.png)

*Resources marked with grey color is not defined in the code due to the cost reason. Instead, it is listed as a future improvements.

### 1. <img src="https://raw.githubusercontent.com/penducky/icons/refs/heads/main/AWS/Architecture-Service-Icons_01302026/Arch_Storage/64/Arch_Amazon-Simple-Storage-Service_64.svg" width="25"> State Locking: Simple Storage Service (S3)
Stores the state as a given key in a given bucket on Amazon S3 to prevent others from acquiring the lock and potentially corrupting the state.


### 2. <img src="https://raw.githubusercontent.com/penducky/icons/refs/heads/main/AWS/Architecture-Service-Icons_01302026/Arch_Compute/64/Arch_Amazon-EC2_64.svg" width="25"> Compute: Elastic Compute Cloud (EC2)
**EC2** is utilized instead of **Lambda** because WordPress requires a persistent PHP runtime environment.

### 3. <img src="https://raw.githubusercontent.com/penducky/icons/refs/heads/main/AWS/Architecture-Service-Icons_01302026/Arch_Compute/64/Arch_Amazon-EC2-Auto-Scaling_64.svg" width="25"> Scaling: Auto Scaling Group (ASG)
The ASG automatically scales the number of EC2 instances up or down based on traffic demands.

### 4. <img src="https://raw.githubusercontent.com/penducky/icons/refs/heads/main/AWS/Resource-Icons_01302026/Res_Networking-Content-Delivery/Res_Elastic-Load-Balancing_Application-Load-Balancer_48.svg" width="25"> Traffic Distribution: Application Load Balancer (ALB)
The **ALB** distributes incoming HTTP/HTTPS traffic across the **EC2** instances provisioned by **ASG** to maintain performance and availability. The traffic flow routes from the internet to the load balancer, then to the app servers (EC2), and finally to the database (RDS).

### 5. <img src="https://raw.githubusercontent.com/penducky/icons/refs/heads/main/AWS/Architecture-Service-Icons_01302026/Arch_Databases/64/Arch_Amazon-RDS_64.svg" width="25"> Database: Relational Database (RDS)
**Amazon RDS running MySQL** is used instead of self-hosting a database directly on an **EC2** instance to offloads maintenance responsibilities such as provisioning and automated backups.



## 🛠️ Tech Stack & Tools

* **Infrastructure as Code:** Terraform v1.14.6
* **Cloud Provider:** AWS (VPC, EC2, RDS, ALB, ASG, NAT Gateway, Internet Gateway)
* **Server Environment:** Ubuntu OS, Apache Web Server, MySQL Database



## 🚀 Future Improvements

A conscious decision was made to exclude the following paid services to prioritize a cost-efficient learning environment. With an allocated budget for a real production environment, these services would be crucial. These resources are marked with grey color on the architecture diagram shown above.

- [ ] <img src="https://raw.githubusercontent.com/penducky/icons/refs/heads/main/AWS/Architecture-Service-Icons_01302026/Arch_Storage/64/Arch_Amazon-EFS_64.svg" width="25"> **Shared Storage:** Deploy **Amazon Elastic File System (EFS)** for shared storage across multiple EC2 instances to ensure media uploads and themes remain consistent and accessible, regardless of which instance serves the request. For this demonstration project, I keep 'one' instance as the ASG's desired capacity to minimize the cost, therefore shared storage is unnecessary.
- [ ] <img src="https://raw.githubusercontent.com/penducky/icons/refs/heads/main/AWS/Resource-Icons_01302026/Res_Databases/Res_Amazon-RDS_Multi-AZ_48.svg" width="25"> **Multi-AZ Database:** Configure **Relational Database (RDS)** to use multi-AZ instead of single-AZ for disaster recovery and fault tolerance. To minimize the cost of this demonstration project, I keep the RDS in a single-AZ since there is no important data stored, and data-loss is not a problem.
- [ ] <img src="https://raw.githubusercontent.com/penducky/icons/refs/heads/main/AWS/Architecture-Service-Icons_01302026/Arch_Networking-Content-Delivery/64/Arch_Amazon-CloudFront_64.svg" width="25"> **Content Delivery:** Deploy **CloudFront** in front of the ALB to cache static assets at edge locations, reducing latency and EC2 load.
- [ ] <img src="https://raw.githubusercontent.com/penducky/icons/refs/heads/main/AWS/Resource-Icons_01302026/Res_Networking-Content-Delivery/Res_Amazon-VPC_NAT-Gateway_48.svg" width="25"> **Redundant NAT Gateways:** Provision a NAT Gateway in each Availability Zone to prevent a single-AZ failure from severing outbound internet access for EC2 instances in healthy subnets.

## 📂 Project Structure

```text
.
├── .github
│   ├── assets
│   └── workflows
│       ├── icons
│       └── projects
├── modules
│   ├── app
│   │   ├── main.tf
│   │   ├── sg.tf
│   │   ├── variables.tf
│   │   └── user_data.tftpl
│   └── infra
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── main.tf
├── variables.tf
├── backend.tf
└── README.md