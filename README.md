# Terraform_2tier_AWS_CICD
Deploy A Two-Tier Architecture With AWS. Configuring a CI/CD Pipeline on Terraform Cloud

In this project, we will leverage the power of Terraform Cloud, AWS, and Github to create a robust CI/CD pipeline. Through a step-by-step approach, we will demonstrate how to create Terraform configuration files and implement a highly scalable and available two-tier architecture.

The architecture we will build consists of a public network and a private network, known as the first and second tiers respectively. The first tier is the user-facing network, providing access to the web application. On the other hand, the second tier serves as the data center, offering business logic back to the web application. By segregating the data center’s information from the client, this architecture helps to keep sensitive information secure.

We will begin by setting up the development environment, configuring Github repositories, and creating IAM roles with the necessary permissions. Afterward, we will move on to creating a VPC, subnets, security groups, and NAT gateway. We will then build an RDS instance and connect it to the web application. Finally, we will use Terraform Cloud to implement the CI/CD pipeline.

By the end of this project, you will have a deep understanding of how to use Terraform, AWS, and Github to build a highly scalable and available two-tier architecture. You will also learn how to automate the deployment process with Terraform Cloud and ensure that changes are rolled out efficiently and reliably. Without further ado, let’s dive in and start building!

Project Outline:

Create a custom VPC with:
2 public subnets for the Web Server Tier
2 private subnets for the RDS Tier
A public route table
A private route table
Create an Auto Scaling Group to launch an EC2 Instance with an Apache web server in each public subnet in the web tier. Configure necessary security groups.
Create an Internet-facing Application Load Balancer targeting web servers.
Create an ALB security group with needed permissions and modifications needed.
Create one RDS MySQL Instance (micro) in the private RDS subnets with appropriate security groups.
Deploy the architecture using Terraform Cloud as a CI/CD tool to check the build.

Prerequisites:

An AWS Admin Account with Access Key and Secret Access Key

An AWS Cloud9 Environment

A free Terraform Cloud Account

A Github Account

Familiarity with Linux and Git commands

In your chose IDE (I am using Cloud9) Lets write the code that will launch our infrastructure.


The instance_type variable is a string type and specifies the default EC2 instance type that will be launched in the VPC.
The ami_id variable is a string type and specifies the default AMI ID to use for the EC2 instance.
The vpc_name variable is a string type and specifies the name of the VPC.
The vpc_cidr variable is a string type and specifies the CIDR block for the VPC.
The az1a and az1b variables are string types and specify the two availability zones that will be used for the public and private subnets.
The db_username variable is a string type and specifies the default database admin username.
The db_password variable is a string type and specifies the default database admin password.
These variables are used to define the infrastructure and can be easily updated as required.


This Terraform code defines the infrastructure for an Amazon Web Services (AWS) VPC that will have a public subnet with two Availability Zones (AZs) for the web tier, and two private subnets with two AZs for the RDS tier. The public subnets will have Internet access via an Internet Gateway, while the private subnets will have internet access through a NAT Gateway.

Here is a brief explanation of each resource:

aws_vpc: This resource creates a custom VPC with a given CIDR block, and enables DNS hostnames. Tags are also assigned to the resource.

aws_internet_gateway: This resource creates an Internet Gateway that can be attached to the custom VPC.

aws_subnet (two instances): These resources create two public subnets that will be launched in different Availability Zones. The subnets will have unique CIDR blocks and a flag set to true to enable mapping of public IP addresses to instances launched in the subnets.

aws_eip (two instances): These resources create two Elastic IPs to assign to the NAT Gateways.

aws_nat_gateway (two instances): These resources create two NAT Gateways with an assigned Elastic IP address each. The NAT Gateways are launched in the public subnets, with one NAT Gateway per public subnet.

aws_subnet (two instances): These resources create two private subnets that will be launched in different Availability Zones. The subnets will have unique CIDR blocks.

aws_route_table (two instances): These resources create two route tables. One is a public route table with a route to the Internet Gateway for internet access, and the other is a private route table with a route to the NAT Gateway for internet access. Both route tables are associated with the custom VPC.

aws_route_table_association (two instances): These resources associate the public route table with the two public subnets and the private route table with the two private subnets.


aws_security_group.Project-webserver-sg: This security group allows inbound traffic on port 22 (SSH), port 80 (HTTP), and port 8080 (Custom web server port) from any IP address (0.0.0.0/0). It also allows outbound traffic to any IP address (0.0.0.0/0).

aws_security_group.Project-mysql-sg: This security group allows inbound traffic on port 3306 (MySQL) from any IP address (0.0.0.0/0). It also allows outbound traffic to any IP address (0.0.0.0/0).

aws_security_group.Project-alb-sg: This security group allows inbound traffic on port 80 (HTTP) and port 443 (HTTPS) from any IP address (0.0.0.0/0). It also allows outbound traffic to any IP address (0.0.0.0/0).

Each security group is associated with the VPC (aws_vpc.Project-vpc.id) specified in the code. Additionally, each security group has a tag Name with the value of the security group's name.

Overall, this code is creating security groups that allow inbound traffic from the internet to specific ports, and outbound traffic to any IP address. This is useful for creating infrastructure that is accessible from the internet, such as web servers and load balancers, while still maintaining some level of security by limiting inbound traffic to specific ports.

Create a shell script to bootstrap EC2 instances

This is a shell script used as userdata to bootstrap the EC2 instances running on Amazon Linux 2. The userdata is a script that will be executed automatically by the instances when they first start up.

The script updates the instance’s package index using the yum update command. It then installs the Apache web server using the yum install command.

After installation, the script starts the httpd service using the systemctl start command, and configures it to start automatically on system startup using the systemctl enable command.

Finally, the script creates an HTML file in the default location for Apache web content /var/www/html/index.html containing the text "This is my Final Level Up In Tech Project." followed by the fully qualified hostname of the instance, which is obtained using the $(hostname -f) command.

In summary, this script installs and configures Apache web server, and creates a simple HTML page to be served by the web server, displaying a message along with the fully qualified hostname of the instance.


This Terraform code defines an Application Load Balancer (ALB) and associated resources for a web application. Here’s what each resource does:

aws_lb defines an Application Load Balancer with a name, Project-alb, and internal set to false which means it's an internet-facing load balancer. It uses the application load balancer type, which is the default. The ALB is associated with two public subnets using their IDs. The security group Project-alb-sg is added to the ALB, and a tag with the name Project-alb-sg is added to the ALB as well.

aws_lb_listener creates a listener on the ALB on port 80, using the HTTP protocol. The default action for incoming traffic is to forward it to the target group Project-launch-template which we will define in the next resource.

aws_lb_target_group defines a target group for the ALB named Project-launch-template with the target type set to instance. It also specifies the VPC ID where the instances are located, and the port and protocol to use for health checks. It also has a depends_on attribute set to [aws_lb.Project-alb], indicating that this resource depends on the ALB resource.

Overall, this Terraform code sets up an Application Load Balancer with a listener and target group, ready to route traffic to instances of the web application running in an Auto Scaling Group.


The asg.tf file contains the Terraform code for creating an Auto Scaling Group (ASG) for launching EC2 instances using a launch template. Here is an explanation of the code:

aws_launch_template resource block creates an EC2 instance launch template that defines the specifications for the instances that will be launched by the ASG. The template includes the AMI ID, instance type, VPC security group ID, and user data to execute a script (apache.sh) on instance boot-up. This resource is used by the aws_autoscaling_group resource to launch instances in the ASG.

aws_autoscaling_group resource block creates the Auto Scaling Group, which manages the EC2 instances launched from the launch template created in the previous resource block. The ASG is configured to launch between min_size (3) and max_size (10) instances, with a desired_capacity of 5 instances. The vpc_zone_identifier parameter specifies the subnets in which to launch instances. The lifecycle block specifies that the ASG should ignore changes to the load_balancers and target_group_arns properties. The launch_template block references the launch template created in the previous resource block.

aws_autoscaling_attachment resource block creates an attachment between the ASG and an Application Load Balancer (ALB). The autoscaling_group_name parameter specifies the name of the ASG to attach to the ALB. The lb_target_group_arn parameter specifies the ARN of the target group to use for routing traffic to the instances launched by the ASG.

Overall, this Terraform code creates an ASG that can automatically scale the number of EC2 instances based on the demand for the web application. The instances will be launched from the launch template and will execute the specified user data script (apache.sh) on boot-up. The ASG is attached to an ALB, enabling it to route traffic to the instances launched by the ASG.


The code creates two resources:

aws_db_instance: This resource is used to create an RDS MySQL instance with the specified configuration options. The following parameters are set:

allocated_storage: The amount of storage to be allocated to the instance in GB.

db_name: The name of the database to be created on the instance.

engine: The database engine to use. In this case, it is MySQL.

engine_version: The version of the database engine to use. In this case, it is MySQL version 5.7.

instance_class: The instance type to be used for the RDS instance.

username and password: The credentials to be used to access the instance. These are sensitive variables that will be provided in Terraform Cloud.

vpc_security_group_ids: The security group to be attached to the instance.

db_subnet_group_name: The name of the subnet group for the instance.

skip_final_snapshot: Whether or not to create a final snapshot when the instance is deleted.

aws_db_subnet_group: This resource is used to create a subnet group for the RDS instance. The following parameters are set:

name: The name of the subnet group.

subnet_ids: The IDs of the subnets in which the RDS instance will be launched.

tags: Tags to be attached to the subnet group.

Create an output for db-instance endpoint
output "Project-db-instance-endpoint" {
  description = "The Project DB instance endpoint"
  value       = aws_db_instance.projectdbinstance.endpoint
}
This is a Terraform output block for the rds.tf file. It specifies an output variable named Project-db-instance-endpoint. The purpose of an output in Terraform is to display the value of a resource attribute or a local value after it has been created or updated.

In this case, the output is referencing the aws_db_instance resource named Project-dbinstance, which is the RDS MySQL instance being created. The endpoint attribute of this resource returns the connection endpoint for the RDS instance, which is a DNS name that resolves to the primary instance of the DB.

The output block includes a description field that provides a human-readable description of what the output represents. This output variable can be used by other Terraform resources or modules, or it can be displayed as part of the Terraform apply output or queried using the terraform output command.

Push code to GitHub
In your GitHub account create a new repository and push all the above code to your new repository.

Create Terraform Cloud Account

Open a web browser and navigate to the Terraform Cloud website at https://app.terraform.io/signup/account.

Click on the “Sign Up” button located at the top right corner of the website.

On the next page, you will be prompted to enter your email address, a username, and a password.

Once you have entered your information, click on the “Create Account” button.

You will receive a confirmation email with a link to verify your email address. Click on the link to verify your email address.

Once your email address has been verified, you will be taken to the Terraform Cloud dashboard.


Before you can start using Terraform Cloud, you will need to create an organization. Click on the “Create Organization” button located on the left-hand side of the dashboard.

Enter a name for your organization and click on the “Create Organization” button.


You will be prompted to invite team members to your organization. You can skip this step for now and click on the “Skip” button located at the bottom right corner of the page.

You will now be taken to the Terraform Cloud workspace creation page. Click on the “Create a new workspace” button.


On the next page, you will need to choose a name for your workspace and select the version control system you will be using.



After selecting the version control system, you will need to provide Terraform Cloud with access to your repository. You can choose to either connect to a public repository or a private repository.


Once you have connected your repository, Terraform Cloud will automatically detect your Terraform configuration files and create a workspace for you.


You can now start using Terraform Cloud to manage your infrastructure as code.


That’s it! With these steps, you should now have a Terraform Cloud account and be ready to start using Terraform to manage your infrastructure as code.

We will make two variables. One variable will be for the AWS Access Key and the second variable will be for the AWS Secret Access Key. Under workspace variables > click add variable > select environment variable:

Variable #1

Key: AWS_ACCESS_KEY_ID

Value: PASTE_YOUR_ACCESS_KEY_ID

Click add variable, then repeat.
Variable #2

Key: AWS_SECRET_ACCESS_KEY

Value: PASTE_YOUR_SECRET_ACCESS_KEY

Check off “Sensitive”, then click add variable. This is a great feature of Terraform Cloud to protect your sensitive variables.



Once the plan has been created it’s time to apply.


Test our infrastructure

Navigate to theEC2 console and select “Load Balancers”. Select your load balancer and copy the public DNS name.


In the address bar of your web browser type in http://<PastePublicDNS>

http://Project-alb-1047634366.us-east-1.elb.amazonaws.com

Refresh the page a few times to test that the load balancer is directing traffic successfully to your different web servers, to validate, you should see the IP addresses change on each refresh.


Clean Up Environment
use Terraform Cloud to destroy your resources. Go to the left panel in your Terraform Cloud > settings > destruction and deletion > queue destroy plan. you should see the plan for a terraform destroy. Confirm and apply the plan to destroy your resources.



