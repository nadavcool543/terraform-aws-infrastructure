## Mid Level Terraform Drills for AWS

### For all the drills use a remote backend and assumed role! (this part can be manually done initially)
### Additionally create all this as part of the same module, and once done bootstrap everything! 

### Drill 1: Creating an S3 Bucket
1. Write a Terraform configuration to create an S3 bucket.
2. Ensure the bucket has versioning enabled.
3. Add tags to the bucket for identification.

### Drill 2: Setting Up a VPC
1. Write a Terraform configuration to create a VPC.
2. Include subnets, route tables, and an internet gateway.
3. Configure the VPC to allow public and private subnets.
4. Add tags to all resources for identification.
5. Ensure the VPC is used by the EC2 instance in Drill 3 and the RDS instance in Drill 4.

### Drill 3: Launching an EC2 Instance
1. Write a Terraform configuration to launch an EC2 instance.
2. Use a specific AMI and instance type.
3. Configure security groups to allow SSH access.
4. Add tags to the instance for identification.
5. Ensure the EC2 instance can connect to the RDS instance created in Drill 4 via security group rules.


### Drill 4: Creating an RDS Instance
1. Write a Terraform configuration to create an RDS instance.
2. Specify the engine type and version.
3. Configure the instance with a specific instance class and storage type.
4. Add tags to the RDS instance for identification.
5. Ensure the RDS instance is accessible from the EC2 instance in Drill 2.

### Drill 5: Implementing IAM Roles and Policies
1. Write a Terraform configuration to create IAM roles and policies.
2. Attach the policies to the roles.
3. Assign the roles to specific AWS services.
4. Add tags to the roles and policies for identification.
5. Create a policy that allows the Lambda function in Drill 8 to access AWS Secrets Manager.

### Drill 6: Configuring CloudFront Distribution
1. Write a Terraform configuration to create a CloudFront distribution.
2. Specify the origin and default cache behavior.
3. Enable logging for the distribution.
4. Add tags to the distribution for identification.

### Drill 7: Setting Up Auto Scaling
1. Write a Terraform configuration to set up an Auto Scaling group.
2. Define the launch configuration or template.
3. Configure scaling policies and alarms.
4. Add tags to the Auto Scaling group for identification.
5. Ensure the Auto Scaling group is associated with the Elastic Load Balancer in Drill 10.

### Drill 8: Deploying a Lambda Function
1. Write a Terraform configuration to deploy a Lambda function.
2. Specify the runtime and handler.
3. Configure the function's execution role and permissions.
4. Add tags to the Lambda function for identification.
5. Ensure the Lambda function has access to AWS Secrets Manager using the IAM policy from Drill 5.

### Drill 9: Creating a DynamoDB Table
1. Write a Terraform configuration to create a DynamoDB table.
2. Define the primary key and provisioned throughput.
3. Enable point-in-time recovery.
4. Add tags to the DynamoDB table for identification.

### Drill 10: Setting Up an Elastic Load Balancer
1. Write a Terraform configuration to create an Elastic Load Balancer.
2. Configure listeners and target groups.
3. Set up health checks for the targets.
4. Add tags to the load balancer for identification.
5. Ensure the Elastic Load Balancer is used by the Auto Scaling group in Drill 7.

### Drill 11: Deploying an EKS Cluster
1. Write a Terraform configuration to deploy an EKS cluster.
2. Specify the Kubernetes version and node group configuration.
3. Configure the VPC and subnets for the EKS cluster.
4. Add tags to the EKS cluster and node groups for identification.
5. Ensure the EKS cluster can access the RDS instance in Drill 4.

### Drill 12: Managing EKS Node Groups
1. Write a Terraform configuration to manage EKS node groups.
2. Specify the instance types and scaling configuration.
3. Configure security groups to allow necessary traffic.
4. Add tags to the node groups for identification.
5. Ensure the node groups are associated with the EKS cluster in Drill 11.\
6. Create a fargate profile for one specific namespace

### Drill 13: Installing ArgoCD Helm Chart
1. Write a Terraform configuration to install the ArgoCD Helm chart.
2. Specify the Helm chart repository and version.
3. Configure the necessary values for the ArgoCD installation.
4. Add tags to the ArgoCD resources for identification.
5. Ensure the ArgoCD installation is associated with the Kubernetes cluster in Drill 11.
6. Create ingress resource that is of class alb that will forward to traffice to the nginx service that will be on clusterIP/NodePort and will forward * from your domain to the cluster

### Drill 15: Adding DNS in Route 53 and ACM for Existing Load Balancers
1. Write a Terraform configuration to create DNS records in Route 53 for the existing load balancers.
2. Ensure the DNS records are correctly associated with the load balancers.
3. Write a Terraform configuration to request and validate ACM certificates for the domains associated with the load balancers.
4. Configure the necessary values for the ACM certificate request and validation.
5. Add tags to the Route 53 and ACM resources for identification.
6. Ensure the DNS records and ACM certificates are associated with the Kubernetes cluster in Drill 11.

### Drill 16: Installing EKS Add-ons
1. Write a Terraform configuration to install the EKS add-ons for the Load Balancer Controller and EBS CSI Controller.
2. Specify the add-on names and versions.
3. Configure the necessary IAM roles and policies for the add-ons.
4. Add tags to the add-on resources for identification.
5. Ensure the add-ons are associated with the EKS cluster in Drill 11.

### Drill 17: Installing External Secrets Helm Chart with IRSA
1. Write a Terraform configuration to install the External Secrets Helm chart.
2. Specify the Helm chart repository and version.
3. Configure the necessary values for the External Secrets installation.
4. Create an IAM role and policy for the External Secrets service account (IRSA).
5. Associate the IAM role with the Kubernetes service account.
6. Add tags to the External Secrets resources for identification.
7. Ensure the External Secrets installation is associated with the Kubernetes cluster in Drill 11.

### Drill 18: Installing Cert Manager Helm Chart with IRSA
1. Write a Terraform configuration to install the Cert Manager Helm chart.
2. Specify the Helm chart repository and version.
3. Configure the necessary values for the Cert Manager installation.
4. Create an IAM role and policy for the Cert Manager service account (IRSA).
5. Associate the IAM role with the Kubernetes service account.
6. Configure Cert Manager to manage certificates for domains in Route 53.
7. Add tags to the Cert Manager resources for identification.
8. Ensure the Cert Manager installation is associated with the Kubernetes cluster in Drill 11.

### Drill 19: Migrating EKS to Karpenter
1. Write a Terraform configuration to install Karpenter. and delete managed node group
2. Specify the Karpenter Helm chart repository and version.
3. Configure the necessary values for the Karpenter installation.
4. Create an IAM role and policy for the Karpenter service account (IRSA).
5. Associate the IAM role with the Kubernetes service account.
6. Configure Karpenter to manage the scaling of the EKS cluster.
7. Add tags to the Karpenter resources for identification.
8. Ensure the Karpenter installation is associated with the Kubernetes cluster in Drill 11.
9. Karpenter controller must run on Fargate profile 



### Drill 20: Deploy Entire Infrastructure in a Single Apply
1. Write a Terraform configuration to deploy the entire infrastructure in a single `terraform apply` command.
2. Ensure all dependencies between resources are correctly defined to avoid the need for multiple apply steps.
3. Use Terraform modules to organize and manage the infrastructure components.
4. Configure the necessary values for each component to ensure they are correctly deployed.
5. Add tags to all resources for identification.
6. Ensure the entire infrastructure is associated with the Kubernetes cluster in Drill 11.
7. Validate the deployment by running `terraform plan` and `terraform apply` to ensure there are no errors.
8. Document the deployment process and any prerequisites required for a successful deployment.
9. Ensure the deployment is idempotent and can be re-applied without causing issues.
10. Implement any necessary workarounds to handle resources that require multiple apply steps during their initial creation.
11. Test the deployment thoroughly to ensure all components are correctly configured and operational.

### Project Structure
1. Create a module folder named `modules/aws_infrastructure/`.
2. Inside this folder, create the following files:
   - `variables.tf`
   - `terraform.tfvars`
   - `outputs.tf`
   - `providers.tf`
   
### Example Structure