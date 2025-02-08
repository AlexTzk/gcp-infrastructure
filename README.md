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
│   ├── gce
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   ├── startup_nfs.sh
│   │   └── gce.tf
│   └── sql
│       ├── outputs.tf
│       ├── variables.tf
│       └── sql.tf
├── outputs.tf
├── plan_p1.json
├── plan_p2.json
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
* Part Two
![image](https://github.com/user-attachments/assets/782458d7-a441-4974-853e-e543db05e3df)

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
