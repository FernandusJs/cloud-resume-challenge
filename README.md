# ☁️ Azure Cloud Resume Challenge

This repository contains the source code and Infrastructure as Code (IaC) for my personal resume website. This project was built as part of [**The Cloud Resume Challenge**](https://cloudresumechallenge.dev), demonstrating a full-stack serverless architecture on Microsoft Azure with a global edge layer via Cloudflare.

---

## 🎯 The Goal

The objective was to move beyond a simple static site by engineering a highly available, secure, and automated system using industry-standard DevOps tools and cloud-native services.

---

## 🏗️ Architecture Overview

The system is designed as a decoupled, serverless application:

### 1. Frontend & Edge Layer

- **Static Hosting:** The resume (HTML / Tailwind CSS / JavaScript) is hosted on **Azure Blob Storage** using the Static Website feature.
- **CDN & DNS:** **Cloudflare** acts as the primary entry point, providing:
  - Full SSL/TLS encryption
  - Global Content Delivery Network (CDN) caching for minimal latency
  - DNS management for a custom domain
- **Security:** Traffic is proxied through Cloudflare’s Web Application Firewall (WAF).

### 2. Backend (Serverless API)

- **Compute:** **Azure Functions** (Python v2 model) handle the visitor counter logic.
- **Database:** **Azure Cosmos DB** (NoSQL) stores visitor data using **Serverless capacity mode** to ensure zero cost during idle periods.
- **Logic:** Cosmos DB input and output bindings are used to atomically increment the counter without requiring extensive database connection code.

### 3. Automation (IaC) & Infrastructure

- **Infrastructure as Code:** All Azure resources are provisioned using **Terraform**.
- **State Management:** Terraform state is stored in a remote **Azure Storage backend** for consistency and security.
- **Deployment:** Happens with VScode extension because of azure ad permission restrictions making it unable to use GitHub Actions


---

## 🛠️ Tech Stack

| Category | Tool |
|--------|------|
| **Cloud Provider** | Microsoft Azure |
| **Infrastructure** | Terraform |
| **CDN / DNS** | Cloudflare |
| **Backend API** | Python (Azure Functions) |
| **Database** | Cosmos DB (NoSQL Serverless) |
| **Frontend** | HTML5, Tailwind CSS, JavaScript |

---

## 🚀 Key Engineering Milestones

- **Modular IaC:** Configured Terraform to handle complex resource dependencies, including resolving attribute type mismatches (object vs string).
- **Zero-Trust CORS:** Implemented a strict CORS policy in the Function App, restricting API access exclusively to the custom domain.
- **Global Performance:** Integrated Cloudflare’s edge network to reduce Time to First Byte (TTFB) for global users.

---

## 📂 Project Structure

```text
.
├── terraform/          # Infrastructure as Code (Azure Resources)
│   ├── main.tf
│   ├── database.tf
│   └── ... .tf
├── api/            # Python Azure Function logic
│   ├── function_app.py
│   ├── host.json
│   └── requirements.txt
├── frontend/           # Website assets (HTML/JS/CSS)
│   ├── index.html
│   └── script.js

```

---

## 📝 How to Use

### Initialize Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

### Deploy Backend

Use the VS Code Azure Functions extension to deploy the `/api` directory.



## 👤 Author

**Nand Beeckx**  
Applied Computer Science Student @ Karel De Grote  

