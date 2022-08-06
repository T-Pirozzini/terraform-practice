# INITIAL TERRAFORM SETUP
- Add required_providers source (hashicorp)
- Add provider (aws, google etc) & region
- Add access_key & secret_key (aws Console)

# 1. CREATE VIRTUAL PRIVATE CLOUD (VPC)
- Resource aws_vpc
- Add cidr_block

# 2. CREATE INTERNET GATEWAY

# 3. CREATE CUSTOM ROUTE TABLE

# 4. CREATE SUBNET
- Resource aws_subnet
- Add vpc_id, add cidr_block (within same range as vpc)
* vpc & subnet order does not matter - doesn't execute top to bottom

# 5. ASSOCIATE SUBNET WITH ROUTE TABLE

# 6. CREATE SECURITY GROUP
- Allow port 22(ssh), 80(http) & 443(https)

# 7. CREATE A NETWORK INTERFACE

# 8. ASSIGN AN ELASTIC IP TO THE NETWORK INTERFACE
- Internet gateway must be created first

# 9. CONFIGURE AMAZON MACHINE IMAGE/INSTANCE (AMI)
- Terraform Method: 
  - Resource aws_instance (terraform method)
  - Add ami & instance_type
  - terraform init -> terraform plan -> terraform apply (yes)
- AWS Console Method:
  - EC2 -> Instances -> Launch Instance -> Ubuntu (AWS Console method)
