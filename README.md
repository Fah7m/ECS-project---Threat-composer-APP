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
|   ├── terraform.tfvars
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
---

## 📌 Table of Contents

1. [Architecture Overview](#architecture-overview)  
2. [Prerequisites](#prerequisites)  
3. [Local Development](#local-development)  
4. [Infrastructure Deployment](#infrastructure-deployment)  
5. [CI/CD Deployment](#ci-cd-deployment)  
6. [Improvements & Future Work](#improvements--future-work)  
7. [Improvements](#troubleshooting)  
8. [License](#license)

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


---

## 🔄 Workflow

This project follows a clear separation of concerns between user access, developer interaction, and automated deployment, with security-first practices applied throughout.

**🧑‍💻 User Workflow (Application Access)**

A user navigates to the application domain (for example: https://<your-domain>).

Route 53 resolves the domain directly to the Application Load Balancer (ALB) using an Alias record.

The ALB:

Terminates HTTPS using an ACM-managed TLS certificate

Listens on port 443

The ALB forwards incoming requests to a target group associated with the ECS service.

ECS tasks, running in private subnets, process the request and return a response.

Application logs are streamed to CloudWatch Logs.

Any outbound traffic from ECS tasks (e.g. image pulls or external API calls) exits via:

Private subnet → NAT Gateway → Internet Gateway → Internet


At no point are application containers directly exposed to the internet.

**👨‍💻 Developer Workflow (Source to Deployment)**

The developer makes changes to:

Application code (/app)

Infrastructure code (/infra)

Changes are committed and pushed to the main branch.

This push triggers GitHub Actions workflows for both application and infrastructure deployment.

The developer never handles or stores AWS credentials locally for CI/CD.

All deployments are fully automated and reproducible.

**🚀 Deployment & CI/CD Workflow (Secure Automation)**

This project uses GitHub Actions with OIDC to deploy without long-lived AWS credentials.

Authentication (OIDC – No Long-Lived Credentials)

GitHub Actions authenticates to AWS using OpenID Connect (OIDC).

AWS IAM validates the GitHub identity and issues temporary credentials.

No static AWS access keys are stored in GitHub secrets.

This follows AWS and GitHub security best practices.

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

