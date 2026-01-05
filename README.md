# Threat Composer App on AWS (ECS Deployment)

This repository contains a production-ready deployment of the **Threat Composer** web application on **AWS ECS Fargate** using **Terraform** and **GitHub Actions** CI/CD. The deployment packages the application as a Docker container backed by an ALB, and infrastructure is fully automated and versionable.

Threat Composer is an open-source threat modeling tool originally developed by AWS Labs, designed to help users brainstorm, document, and improve threat models. 

<img width="928" height="653" alt="image" src="https://github.com/user-attachments/assets/9db8dc92-21e6-458e-be3b-26beba13e6ac" />

---

## Table of Contents

- [Architecture](#project-overview)
- [Workflow](#workflow)
  - [User Workflow](#user-workflow)
  - [Developer & CI/CD Workflow](#developer--cicd-workflow)
- [Security & Best Practices](#security-highlights-and-best-practices)
- [Improvements](#improvements)
- [Deployment Overview](#deployment-overview)
- [Replication Guide](#replicating-this-project)



---
## Project Overview

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

---
##  Workflow

This project follows a clear separation of concerns between user access, developer interaction, and automated deployment, with industry best practices applied throughout.


### User Workflow (Application Access)

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


### Developer Workflow & CI/CD Workflow (Source to Deployment)

- The developer makes changes to application code (/app) and/or infrastructure code (/infra) and pushes them to the main branch.

- GitHub Actions workflows are manually triggered to control when deployments occur.

- CI/CD authenticates to AWS using OIDC, allowing GitHub Actions to assume IAM roles with short-lived credentials and no long-lived secrets.


**The application pipeline:**

- Builds the Docker image using a multi-stage build

- Tags with SHA and pushes the image to Amazon ECR


**The infrastructure pipeline:**

- Runs Terraform to provision or update AWS resources

- Uses S3 for remote Terraform state storage

- Uses DynamoDB for state locking to prevent concurrent runs


**Terraform deploys and manages the below modules:**

- VPC networking, including:
  - VPC, Public/Private subnets, Internet Gateway (IGW), NAT GW and routing

- Application Load Balancer (ALB), including:
  - HTTP/S listeners and Target Groups

- ACM certificates for TLS, including DNS validation

- Route 53 DNS records, including:
  - Alias records pointing the domain to the ALB

- ECS (Fargate) resources, including:
  - ECS cluster, Task Definitions, ECS Service running in private subnets

- IAM roles and policies required for ECS, including:
  - Task execution role, Task role with least-privilege permissions

- Security groups controlling traffic between the ALB and ECS tasks

- The ECS service pulls the latest container image from ECR and performs a rolling update of running tasks.

- Infrastructure can be safely removed by manually triggering a Terraform destroy workflow, ensuring clean teardown of all managed resources.


**Teardown Workflow (Cleanup)**

- Infrastructure can be safely destroyed by running:

```
terraform destroy
```

- Terraform:
  - Uses the same remote state and locking mechanism
  - Deletes resources in the correct dependency order

- This ensures no orphaned infrastructure remains.


---

## Security Highlights and Best Practices


This project follows security-first and production-ready best practices across CI/CD pipelines, containerisation, infrastructure provisioning, and runtime configuration, with multiple layers of automated security scanning.

**Container Security & Optimisation**

- The application uses a multi-stage Docker build, separating build-time and runtime dependencies.

- The Docker image size was reduced by approximately **88.8%**, from 2.59 GB to 291 MB, because of the multistage build.

- Faster ECS task startup times

- Reduced attack surface

- Lower network and storage overhead

- Containers run as a non-root user, following container hardening best practices.

- Only required runtime artifacts are included in the final image.

- Docker images are tagged using the Git commit SHA, ensuring immutable, traceable deployments.


**CI/CD & Pipeline Security**

- OIDC-based authentication is used between GitHub Actions and AWS, eliminating long-lived AWS credentials.

- CI/CD pipelines assume IAM roles with short-lived, least-privilege permissions.

- Deployment workflows are manually triggered, reducing the risk of unintended or automatic production changes.

- Application and infrastructure pipelines are logically separated, providing clearer ownership and reduced blast radius.

- All pipeline executions are fully auditable via GitHub Actions logs.


**Automated Security Scanning**

Security scanning is integrated directly into the CI/CD pipelines to detect issues early.


***Infrastructure Pipeline***

- Checkov is run as part of the Terraform pipeline to statically analyse infrastructure code.

- Checkov enforces security and compliance best practices, including:
  - Network exposure, IAM misconfigurations, Encryption and logging controls, Infrastructure changes are validated before deployment, reducing misconfiguration risk.


***Application / Docker Pipeline***

- Trivy is used to scan Docker images for:
  - Known vulnerabilities (CVEs), OS and dependency-level security issues

- CodeQL is used to perform static code analysis on the application source, detecting:
  - Common security vulnerabilities, Unsafe coding patterns

- Images are only deployed after passing all security scans.


**Operational Best Practices**

- Clear separation of build, deploy, and runtime responsibilities.

- Defence-in-depth approach through:
  - Static analysis (CodeQL)
  - Image vulnerability scanning (Trivy)
  - Infrastructure policy checks (Checkov)

- The infrastructure is idempotent, allowing safe re-runs without unintended changes.

- Deployments are **reproducible, seccure, and auditable**
  
- The overall design aligns with AWS Well-Architected Framework principles.


---

## Improvements



---

## Deployment Overview

Below are screenshots of the full deployment from the very beginning.

***Docker build and push to AWS ECR:***

<img width="1875" height="686" alt="image" src="https://github.com/user-attachments/assets/23bb3ddd-8d40-459c-9590-f64559ce4b4d" />

***Terraform Plan and Apply***

<img width="1877" height="679" alt="image" src="https://github.com/user-attachments/assets/2ee54c52-0f5b-47c6-a8fe-0471b0abc7d9" />

***Application snapshot***

<img width="1919" height="828" alt="image" src="https://github.com/user-attachments/assets/d683236d-d012-4ec6-a618-f2836cd21142" />

***Terraform Destroy***

<img width="1907" height="682" alt="image" src="https://github.com/user-attachments/assets/5186c74d-286f-4855-8062-ba624c8aa18e" />



## Replicating this project

Before you begin:

- **Terraform v1.x**
- **AWS CLI v2**
- **Docker**
- **GitHub Account**
- **AWS Account + Credentials**
- Permissions for the pipelines and ECS
- A registered domain managed in Route 53
- Configure AWS CLI:
  ```bash
  aws configure

**Step by Step replication**

1. Clone and Fork the Repository

```
git clone https://github.com/Fah7m/ECS-project---Threat-composer-APP.git
cd ECS-project---Threat-composer-APP
```

Push the project to your own **Github Repository**

2. Create the Terraform backend Resources

This project uses a remote backend in terraform. Create the resources manually once in your AWS account:
- S3 bucket (for remote statefile)
- DynamoDB (for state locking)


3. Configure AWS OIDC and Roles for Github Actions

Create an IAM role in AWS that trusts GitHub's OIDC provider
- Trusts GitHub's OIDC provider
- Allows:
  - Terraform to manage AWS Resources
  - Docker Image push/pull to ECR
  - Access to S3 and DynamoDB backend  

4. Configure GitHub Repository Secrets

The project uses github secrets to store some sensitive data such as :
- AWS_REGION
- ECR_REGISTRY
- ECR_REPOSITORY
- And the roles to assume

5. (Optional) Local test

If you want to validate locally before CI/CD:

```
aws configure
cd infra/
terraform init
terraform plan
```

6. Run the CI/CD Pipelines (Manual Trigger)

From GiHub Actions:

1. Trigger the Docker pipeline
   - Builds the application image
   - Scans it with Trivy and CodeQL
   - Pushes the image to AWS ECR

2. Trigger the terraform apply pipeline
   - Runs Checkov security scans
   - Provisions the infrastructure (VPC, ECS, ALB etc)
   - Navigate to your domain (https://your-domain)
     
3.  Once happy run the terraform destroy pipeline
    - Removes everything that was deployed 
