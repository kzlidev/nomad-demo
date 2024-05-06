# Installation 
Install Nomad, Vault and Terraform onto your local computer
```bash
# Install Nomad (for MacOS)
brew tap hashicorp/tap
brew install hashicorp/tap/nomad

# Install Vault
brew install hashicorp/tap/vault

# Install Terraform
brew install hashicorp/tap/terraform
```

# Create Vault Certificates
Follow the instructions in the Vault directory 
```bash
cd vault
```

# Setup Nomad Environment
Provision the Nomad Environment into AWS (3 servers and 3 clients)
```bash
cd platform
terraform init 
terraform apply --auto-approve 
# Provide your target AWS account_id
```

# Trigger Nomad Jobs
```bash
cd .. # To go back to root directory 
cd nomad

# Nomad Plan
nomad job plan webapp.nomad

# Run Nomad job
nomad job run webapp.nomad
```

Once the deployment has completed, you should be able access the deployed webapp through the provisioned ALB.