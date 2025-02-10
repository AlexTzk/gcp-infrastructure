# GCP Infrastructure

A repository for automating the deployment and management of Google Cloud Platform (GCP) resources. This project aims to provide a scalable, maintainable, and reproducible infrastructure setup using Infrastructure as Code (IaC) principles. 

## Architecture Diagram
![Architecture](![Drawing 1](https://github.com/user-attachments/assets/6bd03cef-3aa7-4c54-93f9-165a025f7ddf)

---

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Contents](#contents)
- [Steps](#steps)
- [Contributing](#contributing)
- [License](#license) 
- [Contact](#contact)
---

## Overview

This repository contains all the necessary files and scripts to provision resources on Google Cloud Platform. It leverages best practices, including:

- **Infrastructure as Code (IaC):** Ensuring reproducibility and version control.
- **Modular Design:** Allowing each component to be managed and reused independently.
- **Scalability and Maintainability:** Facilitating easy updates and rollbacks.

## Features
- **Private by default:** Ensuring no endpoints are exposed directly and every component is VPC native to a Private Subnet. Employing a GLOBAL HTTPS Load Balancer to proxy through HTTPS to our various Backends. Employing Cloud SQL Proxy and Service Account for GKE to PostgreSQL connectivity
- **Predictable EGRESS** EGRESS is configured through a NAT Gateway that has one IP assigned to so we can easily whitelist this address to other Cloud Providers or OnPrem tools
- **Scalable** Using Serverless and GKE to be able to scale effectively and quickly
- **Versatility and Fast IO** Employing NFS shares on a RAID volume composed of NVMEs. This ensures very fast speeds for our GKE volumes.
- **Bastion VM via Cloud IAP** One central point for managing all resources that's secured through Cloud Identity Aware Proxy
- **Security** Minimal scope Firewall rules to not expose ports or endpoints unnecesarily
- **High Availability** PostgreSQL and GKE cluster are highly available and resistant to zone failures
- **Disaster Recovery** Disaster recovery and Business Continuity plan compliant with Point in Time Recovery


By centralizing GCP infrastructure, you can rapidly spin up (or tear down) resources and track changes over time through Git. It also helps with Business continuity and Disaster recovery plans. 

A custom IAM role is created during setup, this role is used for Bitbucket pipelines. The role also gets a Service Account assigned to it and a JSON auth key created. The JSON KEY will be in the `./modules/iam/` subfolder. 

GCP APIs needed for deploying this infrastructure are enabled at the beginning. You can adjust the `disable_services_on_destro` to true if you want the destroy command to disable them. 

---

## Repository Structure
```
├── main.tf
├── modules
│   ├── firewall
│   │   ├── firewall.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── iam
│   │   ├── iam.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── vpc
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   └── vpc.tf
│   ├── gke
│   │   ├── outputs.tf
│   │   ├── deployment.yaml
│   │   ├── values.yaml
│   │   ├── routes_test_deployment.yaml
│   │   ├── variables.tf
│   │   └── gke.tf
│   ├── cr
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   └── cr.tf
│   ├── gce
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   ├── startup_nfs.sh
│   │   └── gce.tf
│   ├── iap
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   └── iap.tf
│   ├── lbs
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   └── lb.tf
│   └── sql
│       ├── outputs.tf
│       ├── variables.tf
│       └── sql.tf
├── outputs.tf
├── plan_p1.json
├── plan_p2.json
├── plan_p3.json
├── plan_p4.json
├── terraform.tfvars_example
└── variables.tf
```

## Contents
The content of this repository will be deployed into parts based on the release of the [Medium](https://medium.com/@alexandrumarius) articles. Once all four parts are written, the [main](https://github.com/AlexTzk/gcp-infrastructure/tree/main) branch will contain all the components. 

- Part 1: VPC + IAM + Firewall
  - Part 2:  + GCE + SQL
    - Part 3:  + GKE + CR
      - Part 4:  + IAP + LB

## Steps
1. Clone this repository
2. Create a storage bucket within GCP i.e. `$project_name-tfstate`
3. Edit main.tf in root directory and add your project name and bucket you just created 
4. Adjust and rename`terraform.tfvars_example` -> `terraform.tfvars`
5. Run `terraform apply` 

## Optional steps
* You can download the plan_p*.json to review what infrastructure is deployed in each part. Upload the JSON file on [Hieven's visual terraform tool](https://hieven.github.io/terraform-visual/)
![image](https://github.com/user-attachments/assets/a3140c20-aa65-4ed2-9330-4efa6ffc6709)
* Part II
![image](https://github.com/user-attachments/assets/782458d7-a441-4974-853e-e543db05e3df)
* Part III (too big to capture)
![image](https://github.com/user-attachments/assets/86fed02b-39db-4767-8a1a-1ff677ff8273)
* Part IV (too big to capture)
![image](https://github.com/user-attachments/assets/061fdde6-62b0-4225-82d0-399b954bfa27)


## Contributing
Contributions are welcome! If you’d like to make changes or improvements:
-   Fork this repository.
-   Create a feature branch.
-   Commit and push your changes.
-   Open a Pull Request describing what you changed and why.

## License

This project is licensed under the [MIT License](LICENSE). Feel free to use and modify the code for your own projects. If you distribute your version, please reference the original source.

## Contact
Author: [AlexTzk](https://github.com/AlexTzk/)

* If you find any issues or have suggestions, please open an issue.
* For direct inquiries, you can also reach out via GitHub.
