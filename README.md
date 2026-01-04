# Threat Composer App (ECS Deployment)

This repository contains a production-ready deployment of the **Threat Composer** web application on **AWS ECS Fargate** using **Terraform** and **GitHub Actions** CI/CD. The deployment packages the application as a Docker container backed by an ALB, and infrastructure is fully automated and versionable.

Threat Composer is an open-source threat modeling tool originally developed by AWS Labs, designed to help users brainstorm, document, and improve threat models. :contentReference[oaicite:1]{index=1}

---

## 🚀 Project Overview

This project includes:

- **Application Code** (`/app`): React/TypeScript single-page app delivering the Threat Composer UI.
- **Infrastructure as Code** (`/infra`): Terraform modules defining AWS resources (VPC, ECS, ALB, ECR, IAM, NAT, etc.).
- **CI/CD Workflows** (`.github/workflows`): GitHub Actions automating Docker image builds, image pushes to ECR, and Terraform deployments.
- **Production Patterns**: Remote Terraform state in S3 with DynamoDB locking, secure ALB TLS termination, and scalable ECS service.

---

## 📌 Table of Contents

1. [Architecture Overview](#architecture-overview)  
2. [Prerequisites](#prerequisites)  
3. [Local Development](#local-development)  
4. [Infrastructure Deployment](#infrastructure-deployment)  
5. [CI/CD Deployment](#ci-cd-deployment)  
6. [Improvements & Future Work](#improvements--future-work)  
7. [Troubleshooting](#troubleshooting)  
8. [License](#license)

---

## 🏗 Architecture Overview

This project deploys the Threat Composer application via the following components:

