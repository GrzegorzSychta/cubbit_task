# Practical Task

## Part 1: Kubernetes and Helm with a Go Application

### Tasks:

1. **Go Application Deployment:**
   - **a.** Write a basic Go web application: an HTTP server that responds with "Hello, World!”.
   - **b.** Containerize this application.
   - **c.** Create a Kubernetes deployment for the Go application.

2. **Helm Chart:**
   - **a.** Package the deployment using Helm.
   - **b.** Include a Helm values file that allows customization of the number of replicas and image tags.

3. **Bonus: Managing Kubernetes Secrets:**
   - **a.** Store a sensitive configuration value as a Kubernetes secret.
   - **b.** Modify the Golang app and its k8s resources/deployments to read an environment variable that contains sensitive data (/secret).

## Part 2: Infrastructure as Code and k3s Installation

**Using Terraform and/or Pulumi and/or Ansible**

### Task:

1. **Write infrastructure as code (IaC) to provision one or more virtual machines (VMs)** using either Terraform or Pulumi. Use a cloud provider of your choice.
2. **Install k3s** on the provisioned VM(s) and set up a lightweight Kubernetes cluster.
3. **Deploy the Go application from Part 1** onto the k3s cluster.

## Part 3: DevOps

### Task:

1. **CI/CD Pipeline:**
   - **a.** Design a CI/CD pipeline for the Go application from Part 1. Describe the steps involved in building, testing, and deploying the application.

2. **Bonus:**
   - **a.** Running integration tests on the deployed application.

# Key Decisions

## Part 1: IaC

### a) Terraform

- **Modules** instead of static configuration.
- **Remote states** for every module, stored in S3 buckets.
- **Enabled versioning** and **server-side encryption**.
- **DynamoDB table locks** to avoid state corruption.

### b) VPC Module

- **Private subnets** for EC2 instances.
- **Access to the internet via NAT**.

### c) VPN Module

- **easy-rsa CA** generated locally and uploaded to AWS Certificate Manager.
- **Client VPN endpoint** for enabling direct access to the private subnet.

### d) EC2 Module

- **AL2023 AMI** because it's a long-term support Amazon Linux 2023 optimized for AWS usage.
- **Allowed SSH** for VPN clients.

## Part 2: K3S

### a) Ansible

- Basic lightweight installation is very simple, so I decided to do it manually for simplicity.

### b) Installation Script

- I decided to use the simplest non-HA script to create a basic cluster with a single control plane.

### c) Workers

- I decided to create two worker nodes, but adding more is very simple thanks to my Terraform module and K3S way of adding nodes to the cluster.

## Part 3: Go Application

### a) Kubernetes Secret

- Application can use the secret provided as an environment variable.

### b) Unit Tests

- I created very simple tests for my Go application.

### c) Helm

- Created Helm Deployment, Service, and Values.
- Multiple values for multiple environments.

### d) Modules

- I didn't need to use any additional packages, so there is no `go.sum`.

### e) Dockerfile

- Application containerized.
- Separated the build and running of the application.
- Utilized lightweight Alpine image.
- Since it's an HTTP app, I exposed the 8080 port.

## Part 4: CI/CD

### a) Repository

- Used a private GitHub repository.
- Single branch. I decided to go with the GitOps way and have a single source of truth with only a "main" branch.

### b) DockerHub

- Used DockerHub because it's free and easy to set up.

### c) CircleCI

- **CI Pipeline:**
  - Tests
  - Set tag
  - Build
  - DockerHub push
  - Update Helm values
  - Trigger on pushes
  - Different workflows for different environments

### d) ArgoCD

- **CD Pipeline:**
  - Utilized **App of Apps** pattern
  - **ApplicationSet** for go-hello-app
  - Triggers on modification of Helm Values. Automated sync policy.
  - **List generator**, per environment
  - **Prune policy**: ArgoCD will delete resources if they are no longer available in the repository.
  - **SelfHeal policy**: ArgoCD will try to recreate resources in case of unhealthy status, e.g., when resources are modified manually.
  - **CreateNamespace**: Creates the namespace if missing.

# How to Set Up the Project (Step-by-Step)

## Stage 1: Create AWS Prerequisites

1. **Create User for Terraform**

   - Permissions: `AmazonEC2FullAccess`, `AmazonS3FullAccess`, `AmazonDynamoDBFullAccess`
   - Create an Access Key

2. **Configure AWS CLI**

   ```bash
   aws configure

   AWS Access Key ID [None]: accesskey
   AWS Secret Access Key [None]: secretkey
   Default region name [None]: eu-west-2
   Default output format [None]: json

   aws sts get-caller-identity
   ```

3. **Generate SSH Key for EC2 Instances**

   ```bash
   aws ec2 create-key-pair \
     --key-name terraform \
     --key-type ed25519 \
     --key-format pem \
     --query "KeyMaterial" \
     --output text > terraform.pem

   chmod 400 terraform.pem 
   ```

4. **Set Up S3 Bucket for Terraform States**

   ```bash
   aws s3api create-bucket \
     --bucket cubbit-terraform-state-bucket \
     --region eu-west-2 \
     --create-bucket-configuration LocationConstraint=eu-west-2

   aws s3api put-bucket-versioning \
     --bucket cubbit-terraform-state-bucket \
     --versioning-configuration Status=Enabled

   aws s3api put-bucket-encryption \
     --bucket cubbit-terraform-state-bucket \
     --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
   ```

5. **Set Up DynamoDB for State Locks**

   ```bash
   aws dynamodb create-table \
     --table-name cubbit-terraform-lock-table \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
   ```

6. **Get the Latest AMI for Amazon Linux 2023**

   ```bash
   aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2023/recommended
   ```

7. **Set Up AWS Certificate Manager**

   [AWS Documentation](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-auth-mutual-enable.html)

   ```bash
   git clone https://github.com/OpenVPN/easy-rsa.git
   cd easy-rsa/easyrsa3
   ./easyrsa init-pki
   ./easyrsa build-ca nopass
   ./easyrsa --san=DNS:server build-server-full server nopass
   ./easyrsa build-client-full client1.domain.tld nopass

   mkdir ~/custom_folder/
   cp pki/ca.crt ~/custom_folder/
   cp pki/issued/server.crt ~/custom_folder/
   cp pki/private/server.key ~/custom_folder/
   cp pki/issued/client1.domain.tld.crt ~/custom_folder
   cp pki/private/client1.domain.tld.key ~/custom_folder/
   cd ~/custom_folder/

   aws acm import-certificate --certificate fileb://server.crt --private-key fileb://server.key --certificate-chain fileb://ca.crt
   aws acm import-certificate --certificate fileb://client1.domain.tld.crt --private-key fileb://client1.domain.tld.key --certificate-chain fileb://ca.crt
   ```

## Stage 2: Terraform Provisioning

**Execute in the following order!**

1. **Module VPC**

   Can generate:

   - Public subnets
   - Private subnets
   - Route tables
   - Elastic IP
   - Internet gateway
   - NAT gateway

2. **Module VPN**

   Can generate:

   - AWS Client VPN Endpoint

   When calling the module, please replace the certificate `server_certificate_arn` and `client_certificate_arn` with the IDs of the certificates uploaded to the ACM.

   Navigate to the Client VPN endpoints in AWS console and click "Download client configuration".

   Regardless of your OS, you need to modify the downloaded `.ovpn` file and add the client certificate and client key below the CA cert.

   If you followed the instructions, they should be located within:

   - `~/custom_folder/client1.domain.tld.crt`
   - `~/custom_folder/client1.domain.tld.key`

   Final file should look like this:

   ```text
   <ca>
   -----BEGIN CERTIFICATE-----
   -----END CERTIFICATE-----
   </ca>

   <cert>
   -----BEGIN CERTIFICATE-----
   -----END CERTIFICATE-----
   </cert>

   <key>
   -----BEGIN PRIVATE KEY-----
   -----END PRIVATE KEY-----
   </key>
   ```

   Upload configuration to the Network Manager (Linux) or OpenVPN Client (Windows).

3. **Module EC2**

   Can generate:

   - EC2 instances

   Create at least three instances.

   I used the newest Amazon Linux 2023 because it is a long-term support version with many AWS integrations included.

   The instance that will act as a control plane should be a little bit more powerful. I decided to use `t3.medium`.

## Stage 3: K3S Configuration

**Connect to the EC2 instance that will become a control plane and install K3S**

```bash
sudo curl -sfL https://get.k3s.io | sh -
```

**Get node-token and save it**

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

**Connect to every EC2 instance that will become a worker and add them to the cluster**

```bash
sudo curl -sfL https://get.k3s.io | K3S_URL=https://controlplane-ip:6443 K3S_TOKEN=token-from-point1 sh -
```

- `controlplane-ip`: IPv4 of Control Plane
- `token-from-point1`: Token generated previously.

**Enable access to the K3S API from local machine**

1. Access the Control Plane.
2. Edit `/etc/rancher/k3s/k3s.yaml`, change `127.0.0.1` to the private IPv4 of the instance.
3. Download `k3s.yaml` and save it as `config-remote`.
4. Export kubeconfig (or merge with the existing):

   ```bash
   export KUBECONFIG=~/.kube/config-remote
   ```

## Stage 4: Setup GitHub, DockerHub & CircleCI

### GitHub

Generate GitHub Personal Access Token (PAT).

[GitHub Documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

### DockerHub

1. Create DockerHub account.
2. Create private repository.
3. Update every `grg1337/cubbit` within this project to your values from DockerHub.

   - Format: `username/repository_name:docker_tag`

### CircleCI

1. Create CircleCI account.
2. Create project.
3. Connect project to the GitHub repository.
4. Navigate to the project settings > environment variables and add the following:

   - `DOCKERHUB_PASSWORD`
   - `DOCKERHUB_USERNAME`
   - `GIT_TOKEN`

   - `GIT_TOKEN`: Personal Access Token from GitHub.
   - `DOCKERHUB_USERNAME`: DockerHub username.
   - `DOCKERHUB_PASSWORD`: DockerHub password.

## Stage 5: Setup ArgoCD

```bash
kubectl create namespace argocd

# Quickstart installation script.
# https://argo-cd.readthedocs.io/en/stable/getting_started/
# https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl create namespace prod
kubectl create namespace dev
kubectl create namespace stage

# DockerHub secrets
kubectl create secret docker-registry regcred \
    --docker-username=x@example.com \
    --docker-password=xxx \
    --docker-email=xxx@example.com \
    --namespace=stage \
    --docker-server=https://index.docker.io/v1/

kubectl create secret docker-registry regcred \
    --docker-username=x@example.com \
    --docker-password=xxx \
    --docker-email=xxx@example.com \
    --namespace=dev \
    --docker-server=https://index.docker.io/v1/

kubectl create secret docker-registry regcred \
    --docker-username=x@example.com \
    --docker-password=xxx \
    --docker-email=xxx@example.com \
    --namespace=prod \
    --docker-server=https://index.docker.io/v1/

# Go-Hello-App secrets
kubectl create secret generic secret \
    --from-literal=secret-message="YourSecretValue" \
    --namespace=dev

kubectl create secret generic secret \
    --from-literal=secret-message="YourSecretValue" \
    --namespace=stage

kubectl create secret generic secret \
    --from-literal=secret-message="YourSecretValue" \
    --namespace=prod

# Getting the password for ArgoCD Dashboard & CLI. Save it.
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode

# To access ArgoCD dashboard from browser. Default username is: admin
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Install ArgoCD CLI.
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Authenticate to the ArgoCD CLI
argocd login localhost:8080

# Add repository to ArgoCD
argocd repo add https://github.com/GrzegorzSychta/cubbit.git --username xxx@example.com --password PersonalAccessToken

# Apply the App of Apps
# https://argo-cd.readthedocs.io/en/latest/operator-manual/cluster-bootstrapping/#app-of-apps-pattern
kubectl apply -f cubbit/argo-cd/app-of-apps.yaml
```