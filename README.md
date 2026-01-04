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




<img width="928" height="653" alt="image" src="https://github.com/user-attachments/assets/9db8dc92-21e6-458e-be3b-26beba13e6ac" />



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

