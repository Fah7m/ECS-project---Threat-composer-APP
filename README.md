# Threat Composer App on AWS (ECS Deployment)

This repository contains a production-ready deployment of the **Threat Composer** web application on **AWS ECS Fargate** using **Terraform** and **GitHub Actions** CI/CD. The deployment packages the application as a Docker container backed by an ALB, and infrastructure is fully automated and versionable.

Threat Composer is an open-source threat modeling tool originally developed by AWS Labs, designed to help users brainstorm, document, and improve threat models. 

<img width="928" height="653" alt="image" src="https://github.com/user-attachments/assets/9db8dc92-21e6-458e-be3b-26beba13e6ac" />

---

## 🚀 Project Overview

This project includes:

- **Application Code** (`/app`): React/TypeScript single-page app delivering the Threat Composer UI.
- **Infrastructure as Code** (`/infra`): Terraform modules defining AWS resources (VPC, ECS, ALB, ECR, IAM, NAT, etc.).
- **CI/CD Workflows** (`.github/workflows`): GitHub Actions automating Docker image builds, image pushes to ECR, and Terraform deployments.
- **Production Patterns**: Remote Terraform state in S3 with DynamoDB locking, secure ALB TLS termination, and scalable ECS service.

Project Structure:

```
ECS/
├── .github/
│   └── workflows/
│       ├── docker-push.yml
│       ├── terraform-apply.yml
│       └── destroy.yml
├── app/
|   ├── dockerfile
├── infra/
│   ├── main.tf
│   ├── provider.tf
|   ├── terraform.tfvars (hidden)
│   ├── variable.tf
│   └── modules/
│       ├── acm/
│       ├── alb/
│       ├── ecs/
│       ├── iam/
|       ├── route53/
│       └── vpc/
└── README.md
```

## 🔄 Workflow

This project follows a clear separation of concerns between user access, developer interaction, and automated deployment, with industry best practices applied throughout.

**User Workflow (Application Access)**

- A user navigates to the application domain (for example: http://tm.f7him.com).

- **Route 53** resolves the domain directly to the Application Load Balancer.

**The ALB:**

- A client initiates an HTTPS connection to the application domain.

- The Application Load Balancer presents an ACM-managed TLS certificate and completes the TLS handshake with the client.

- An encrypted HTTPS session is established between the client and the ALB.

- The ALB decrypts the incoming request and applies listener rules and routing logic.

- The ALB forwards the request to the ECS target group

- ECS tasks, running in private subnets, receive the request over the VPC’s internal network.

- The application inside the ECS task processes the request and generates a response.

- The response is sent back to the ALB.

- The ALB returns the response to the client over the existing HTTPS connection.

- Application logs are streamed to CloudWatch Logs, and any outbound traffic from ECS tasks exits via the Private subnet → NAT Gateway → Internet Gateway → Internet

- At no point are application containers directly exposed to the internet.

**👨‍💻 Developer Workflow & CI/CD Workflow (Source to Deployment)**

- The developer makes changes to application code (/app) and/or infrastructure code (/infra) and pushes them to the main branch.

- GitHub Actions workflows are manually triggered to control when deployments occur.

- CI/CD authenticates to AWS using OIDC, allowing GitHub Actions to assume IAM roles with short-lived credentials and no long-lived secrets.

- **The application pipeline:**

- Builds the Docker image using a multi-stage build

- Tags with SHA and pushes the image to Amazon ECR

- **The infrastructure pipeline:**

- Runs Terraform to provision or update AWS resources

- Uses S3 for remote Terraform state storage

- Uses DynamoDB for state locking to prevent concurrent runs

- **Terraform deploys and manages the below modules:**

- VPC networking, including:
  - VPC, Public/Private subnets, Internet Gateway (IGW), NAT GW and routing

- Application Load Balancer (ALB), including:
  - HTTP/S listeners and Target Groups

- ACM certificates for TLS, including DNS validation

- Route 53 DNS records, including:
  - Alias records pointing the domain to the ALB

- ECS (Fargate) resources, including:
  - ECS cluster, Task Definitions, ECS Service running in private subnets

IAM roles and policies required for ECS, including:

Task execution role

Task role with least-privilege permissions

Security groups controlling traffic between the ALB and ECS tasks

- The ECS service pulls the latest container image from ECR and performs a rolling update of running tasks.

- Infrastructure can be safely removed by manually triggering a Terraform destroy workflow, ensuring clean teardown of all managed resources.


**🚀 Deployment & CI/CD Workflow (Secure Automation)**

Pipeline 1: Application Build & Image Push

GitHub Actions builds the application into a Docker image.

The image is tagged and pushed to Amazon ECR.

Permissions are granted via a least-privilege IAM role assumed through OIDC.

Pipeline 2: Infrastructure Provisioning (Terraform)

GitHub Actions runs Terraform to provision or update infrastructure.

Terraform uses:

S3 for remote state storage

DynamoDB for state locking

Resources managed include:

VPC, subnets, IGW, NAT

ALB and listeners

ECS cluster, service, and task definitions

IAM roles and security groups

Terraform ensures idempotent, predictable infrastructure changes.

Service Update

The ECS service detects the new container image in ECR.

Tasks are replaced using a rolling deployment strategy.

The ALB continues routing traffic with no downtime.

**🧹 Teardown Workflow (Cleanup)**

Infrastructure can be safely destroyed by running:

terraform destroy


Terraform:

Uses the same remote state and locking mechanism

Deletes resources in the correct dependency order

This ensures no orphaned infrastructure remains.

**🔐 Security Highlights**

No long-lived AWS credentials

OIDC-based authentication for CI/CD

Least-privilege IAM roles

Private subnets for application workloads

TLS termination using ACM

Centralised logging with CloudWatch



---

---

## 🏗 🔨Deployment Overview

Below are screenshots of the full deployment from the very beginning.

***Docker build and push to AWS ECR:***

<img width="1875" height="686" alt="image" src="https://github.com/user-attachments/assets/23bb3ddd-8d40-459c-9590-f64559ce4b4d" />

***Terraform Plan and Apply***

<img width="1877" height="679" alt="image" src="https://github.com/user-attachments/assets/2ee54c52-0f5b-47c6-a8fe-0471b0abc7d9" />

***Application snapshot***

<img width="1919" height="828" alt="image" src="https://github.com/user-attachments/assets/d683236d-d012-4ec6-a618-f2836cd21142" />

***Terraform Destroy***

<img width="1907" height="682" alt="image" src="https://github.com/user-attachments/assets/5186c74d-286f-4855-8062-ba624c8aa18e" />



## 🧰 Prerequisites

Before you begin:

- **Terraform v1.x**
- **AWS CLI v2**
- **Docker**
- **GitHub Account**
- **AWS Account + Credentials**
- Configure AWS CLI:
  ```bash
  aws configure

