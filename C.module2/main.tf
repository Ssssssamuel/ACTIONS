# Creating my VPC
resource "aws_vpc" "terra_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "TERRAVPC"
  }
}

# Creating public Subnet1 for ALB and Bastion server
resource "aws_subnet" "public_sub" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.0.0/23"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "TERRA-PUB-SUB1"
  }
}

# Creating public Subnet2 for ALB
resource "aws_subnet" "public_sub2" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.2.0/23"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "TERRA-PUB-SUB2"
  }
}

# Creating private subnet1 for MYSQL App server
resource "aws_subnet" "private_sub" {
   vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "TERRA-PRIV-SUB1"
  }
}

# Creating private subnet2 for MYSQL App server
resource "aws_subnet" "private_sub1" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "TERRA-PRIV-SUB2"
  }
}

# Creating private Subnet1 for MYSQL RDS DB
resource "aws_subnet" "private_sub2" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.8.0/22"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "TERRA-PRIV-SUB3"
  }
}

# Creating private Subnet2 for MYSQL RDS DB
resource "aws_subnet" "private_sub3" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.24.0/22"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "TERRA-PRIV-SUB4"
  }
}

# Creating private Subnet1 for Oracle DB
resource "aws_subnet" "private_sub4" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "TERRA-PRIV-SUB5"
  }
}

# Creating private Subnet2 for Oracle DB
resource "aws_subnet" "private_sub5" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.17.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "TERRA-PRIV-SUB6"
  }
}

# Creating private Subnet1 for Java App Server
resource "aws_subnet" "private_sub6" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.12.0/26"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "TERRA-PRIV-SUB7"
  }
}

# Creating private Subnet2 for Java App Server
resource "aws_subnet" "private_sub7" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.13.0/26"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "TERRA-PRIV-SUB8"
  }
}

# Creating private Subnet1 for Java DB
resource "aws_subnet" "private_sub8" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.14.0/26"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "TERRA-PRIV-SUB9"
  }
}

# Creating private Subnet2 for Java DB
resource "aws_subnet" "private_sub9" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.15.0/26"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "TERRA-PRIV-SUB10"
  }
}

# Creating an Internet Gateway
resource "aws_internet_gateway" "G_W" {
  vpc_id = aws_vpc.terra_vpc.id

  tags = {
    Name = "TERRA_GW"
  }
}

# Creating Elastic IP for NAT Gateway
resource "aws_eip" "NAT_EIP" {
  domain = "vpc"
}

# Creating NAT Gateway
resource "aws_nat_gateway" "T_NATGATE" {
  allocation_id = aws_eip.NAT_EIP.id
  subnet_id     = aws_subnet.public_sub.id

  tags = {
    Name = "TERRANATGATEWAY"
  }

  depends_on = [aws_internet_gateway.G_W]
}

# Creating route table for public subnets
resource "aws_route_table" "pub_routetable" {
  vpc_id = aws_vpc.terra_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.G_W.id
  }

  tags = {
    Name = "TERRA_RT1"
  }
}

# Creating route table for private subnets
resource "aws_route_table" "priv_routetable" {
  vpc_id = aws_vpc.terra_vpc.id

  route {
    cidr_block    = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.T_NATGATE.id
  }

  tags = {
    Name = "TERRA_RT2"
  }
}

# Creating route table2 for private DB subnets
resource "aws_route_table" "priv_routetable2" {
  vpc_id = aws_vpc.terra_vpc.id

  tags = {
    Name = "TERRA_RT3"
  }
}

# Associate public route table with public subnets
resource "aws_route_table_association" "connect_pub1" {
  subnet_id      = aws_subnet.public_sub.id
  route_table_id = aws_route_table.pub_routetable.id
}

resource "aws_route_table_association" "connect_pub2" {
  subnet_id      = aws_subnet.public_sub2.id
  route_table_id = aws_route_table.pub_routetable.id
}

# Associate private route table with private subnets
resource "aws_route_table_association" "connect_priv3" {
  subnet_id      = aws_subnet.private_sub.id
  route_table_id = aws_route_table.priv_routetable.id
}

resource "aws_route_table_association" "connect_priv4" {
  subnet_id      = aws_subnet.private_sub1.id
  route_table_id = aws_route_table.priv_routetable.id
}

resource "aws_route_table_association" "connect_priv5" {
  subnet_id      = aws_subnet.private_sub6.id
  route_table_id = aws_route_table.priv_routetable.id
}

resource "aws_route_table_association" "connect_priv6" {
  subnet_id      = aws_subnet.private_sub7.id
  route_table_id = aws_route_table.priv_routetable.id
}

# Associate private route table2 with private DB subnets
resource "aws_route_table_association" "connect_priv7" {
  subnet_id      = aws_subnet.private_sub2.id
  route_table_id = aws_route_table.priv_routetable2.id
}

resource "aws_route_table_association" "connect_priv8" {
  subnet_id      = aws_subnet.private_sub3.id
  route_table_id = aws_route_table.priv_routetable2.id
}

resource "aws_route_table_association" "connect_priv9" {
  subnet_id      = aws_subnet.private_sub4.id
  route_table_id = aws_route_table.priv_routetable2.id
}

resource "aws_route_table_association" "connect_priv10" {
  subnet_id      = aws_subnet.private_sub5.id
  route_table_id = aws_route_table.priv_routetable2.id
}

resource "aws_route_table_association" "connect_priv11" {
  subnet_id      = aws_subnet.private_sub8.id
  route_table_id = aws_route_table.priv_routetable2.id
}

resource "aws_route_table_association" "connect_priv12" {
  subnet_id      = aws_subnet.private_sub9.id
  route_table_id = aws_route_table.priv_routetable2.id
}

# Creating Key Pair
resource "aws_key_pair" "Stack_KP" {
  key_name   = "clixx_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

# Creating Security Group for Bastion Server
resource "aws_security_group" "terra_Bast_sg" {
  vpc_id     = aws_vpc.terra_vpc.id
  name       = "clixx_Terra_Bast"
  description = "clixx Security Group For Bastion Instance"
}

# SSH ingress rule
resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.terra_Bast_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_agent_ingress" {
  security_group_id = aws_security_group.terra_Bast_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 32768
  to_port           = 65535
  cidr_blocks       = ["10.0.0.0/16"] # Adjust to your VPC CIDR
}

# MySQL ingress rule
resource "aws_security_group_rule" "mysql_ingress" {
  security_group_id = aws_security_group.terra_Bast_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_blocks       = ["0.0.0.0/0"]
}

# HTTP ingress rules
resource "aws_security_group_rule" "http_ingress" {
  security_group_id          = aws_security_group.terra_Bast_sg.id
  type                       = "ingress"
  protocol                   = "tcp"
  from_port                  = 80
  to_port                    = 80
  source_security_group_id   = aws_security_group.terra_Bast_sg.id
}

# HTTPS ingress rules
resource "aws_security_group_rule" "https_ingress" {
  security_group_id = aws_security_group.terra_Bast_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

# Oracle ingress rules
resource "aws_security_group_rule" "oracle_ingress" {
  security_group_id = aws_security_group.terra_Bast_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  cidr_blocks       = ["0.0.0.0/0"]
}

# All traffic outbound rule
resource "aws_security_group_rule" "all_traffic" { 
  security_group_id = aws_security_group.terra_Bast_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

# Creating Security Group for DB
resource "aws_security_group" "terra_sg2" {
  vpc_id     = aws_vpc.terra_vpc.id
  name       = "clixx-terra-DB-sg"
  description = "clixx Security Group For RDS Instance"
}

# NFS, MySQL, Oracle, and Java rules for DB Security Group
resource "aws_security_group_rule" "nfs_ingress" {
  security_group_id = aws_security_group.terra_sg2.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2049
  to_port           = 2049
  cidr_blocks       = ["10.0.0.0/16"]
}

resource "aws_security_group_rule" "mysql_ingress_db" {
  security_group_id = aws_security_group.terra_sg2.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_blocks       = ["10.0.0.0/16"]
}

resource "aws_security_group_rule" "oracle_ingress_db" {
  security_group_id = aws_security_group.terra_sg2.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  cidr_blocks       = ["10.0.0.0/16"]
}

resource "aws_security_group_rule" "java_ingress_db" {
  security_group_id = aws_security_group.terra_sg2.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1527
  to_port           = 1527
  cidr_blocks       = ["10.0.0.0/16"]
}

# Creating Security Group for ECS Server
resource "aws_security_group" "terra_ecs_sg" {
  vpc_id     = aws_vpc.terra_vpc.id
  name       = "clixx_Terra_ecs"
  description = "clixx Security Group For ecs Instance"
}

resource "aws_security_group_rule" "http_ingress_from_lb" {
  security_group_id        = aws_security_group.terra_ecs_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.terra_Bast_sg.id
}

resource "aws_security_group_rule" "http_egress" {
  security_group_id        = aws_security_group.terra_ecs_sg.id
  type                     = "egress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  cidr_blocks              = ["0.0.0.0/0"]
}

# Creating MYSQL DB Subnet Group
resource "aws_db_subnet_group" "subgroupdb" {
  name       = "terra-mysql-subnet"
  subnet_ids = [aws_subnet.private_sub2.id, aws_subnet.private_sub3.id]

  tags = {
    Name = "MYSQL_SUBNET_Grp"
  }
}

# Creating Oracle DB Subnet Group (for migration)
resource "aws_db_subnet_group" "subgroupdb1" {
  name       = "terra-oracle-subnet"
  subnet_ids = [aws_subnet.private_sub4.id, aws_subnet.private_sub5.id]

  tags = {
    Name = "Oracle_SUBNET_Grp"
  }
}

# Retreiving my secretes from SSM parameter
data "aws_ssm_parameter" "db_password" {
  name = "/myapp/pass"
  with_decryption = false
}

data "aws_ssm_parameter" "db_name" {
  name = "/myapp/name"
  with_decryption = false
}

data "aws_ssm_parameter" "db_user" {
  name = "/myapp/user"
  with_decryption = false
}

# Define the templatefile with local variables
locals {
  bootstrap = templatefile("${path.module}/scripts/bootstrap.tpl", {
    FILE = aws_efs_file_system.my_efs.id,
    MOUNT_POINT= "/var/www/html",
    REGION = "us-east-1",
    DB_PASS = data.aws_ssm_parameter.db_password.value,
    DB_NAME = data.aws_ssm_parameter.db_name.value,
    DB_USER = data.aws_ssm_parameter.db_user.value,
  })
}

# Restoring Database from Snapshot
resource "aws_db_instance" "restored_db" {
  identifier            = "wordpressdbclixx-ecs"
  snapshot_identifier   = var.snapshot_id  
  instance_class        = "db.m6gd.large"
  allocated_storage      = 20
  engine                = "mysql"
  db_subnet_group_name  = aws_db_subnet_group.subgroupdb.name
  vpc_security_group_ids = [aws_security_group.terra_sg2.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = data.aws_ssm_parameter.db_name.value
  }

}

# Creating EFS File System
resource "aws_efs_file_system" "my_efs" {
  creation_token = "my-efs-token"

  tags = {
    Name        = "TERRA_EFS"
    Environment = "Development"
  }
}

# IAM Role for ECS EC2 Instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "Clixx-ECS-Instance-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Creating Policy for Role
resource "aws_iam_policy" "ecs_role" {
  name        = "Clixx-ECS-Instance-Policy"
  description = "Policy to allow ECS Instance role to register with ECS, interact with ELB, pull images from ECR, and connect to Systems Manager"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          # EC2 permissions
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:Describe*",

          # Elastic Load Balancing permissions
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:RegisterTargets",

          # ECS permissions
          "ecs:Poll",
          "ecs:DiscoverPollEndpoint",
          "ecs:SubmitTaskStateChange",
          "ecs:RegisterContainerInstance", 
          "ecs:DiscoverPollEndpoint",      
          "ecs:SubmitContainerStateChange", 
          "ecs:StartTelemetrySession",      
          "ecs:UpdateContainerInstancesState", 
          "ecs:DescribeTasks",
          "ecs:DescribeContainerInstances",
          "ecs:DeregisterContainerInstance",
          "ecs:StartTask",
          "ecs:StopTask",
          "ecs:ListClusters",
          "ecs:ListTasks",

          # Logging permissions
          "logs:CreateLogStream",           
          "logs:PutLogEvents",     
          "logs:DescribeLogStreams", 
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          # S3 permissions for ECS
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::aws-ecs-*",      
          "arn:aws:s3:::aws-ecs-logs-*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          # ECR permissions for pulling images
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          # Systems Manager (SSM) permissions
          "ssm:DescribeInstanceInformation",
          "ssm:GetCommandInvocation",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations",
          "ssm:SendCommand",
          "ssm:StartSession",
          "ssm:DescribeSessions",
          "ssm:TerminateSession",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:PutParameter"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          # Session Manager permissions for SSM
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          # S3 permissions for SSM
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::your-ssm-bucket-name",
          "arn:aws:s3:::your-ssm-bucket-name/*"
        ]
      }
    ]
  })
}


# Attach the policy to ECS instance role
resource "aws_iam_role_policy_attachment" "ecs_instance_policy_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = aws_iam_policy.ecs_role.arn
}

# ECS Instance Profile
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "Clixx-ECS-Instance-Profile"
  role = aws_iam_role.ecs_instance_role.name
}

# Assume Role Policy Document for ECS Task Execution Role
data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ECS_TaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

# Attaching Policy to Task Execution Role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Creating Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "new-clixx-cluster"
}

# Creating a launch template
resource "aws_launch_template" "my_launch_template" {
  name          = "terra-launch-template"
  image_id      = var.ami
  instance_type = "c4.large"
  key_name      = aws_key_pair.Stack_KP.key_name
  user_data     = base64encode(local.bootstrap)

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }
  
  network_interfaces {
    associate_public_ip_address = true
    security_groups     = [aws_security_group.terra_ecs_sg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "terra-ec2-LT"
    }
  }
}

# Creating Auto Scaling group 
resource "aws_autoscaling_group" "my_terra_asg" {
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"  
  }

  min_size          = 1
  max_size          = 2
  desired_capacity  = 1
  vpc_zone_identifier = [aws_subnet.private_sub.id, aws_subnet.private_sub1.id]

  tag {
    key                 = "Name"
    value               = "terra-ec2"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true 
  }

  target_group_arns = [aws_lb_target_group.my_terra_tg.arn]

  # Ensuring Instances are created only after DB is ready
  depends_on = [aws_db_instance.restored_db]
  
}

# Target type for EC2 instances
resource "aws_lb_target_group" "my_terra_tg" {
  name        = "terra-asg-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.terra_vpc.id
  target_type = "instance"

  health_check {
    path                = "/index.php"
    interval            = 121
    timeout             = 120
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# Creating Application Load Balancer
resource "aws_lb" "web_lb" {
  name               = "clixx-terraform-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terra_Bast_sg.id]
  subnets            = [aws_subnet.public_sub.id, aws_subnet.public_sub2.id]

  enable_deletion_protection = false

  tags = {
    Name = "clixxweb-terra-lb"
  }
}

# Listeners for Routing Traffic
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.my_terra_tg.arn  # Forward to ASG target group
  }
   certificate_arn = var.cert_arn

   # Ensuring TG is attached only after LB is ready
   depends_on = [aws_lb.web_lb]
}

# Creating task definition
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "new-clixx-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"       
    cpu_architecture        = "X86_64" 
  }


  container_definitions = jsonencode([
    {
      name      = "clixx-cont"
      image     = "222634373909.dkr.ecr.us-east-1.amazonaws.com/clixx_image:new_image"
      
      # Resource allocation for container
      cpu       = 512       # 0.5 vCPU
      memory    = 1536      # 1.5 GB Memory (hard limit)
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])

  # Resource allocation for task
  cpu    = "1024"           # 1 vCPU (task-level)
  memory = "3072"           # 3 GB Memory (task-level)

  depends_on = [aws_ecs_cluster.ecs_cluster]
}

# Creating ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = "new-clixx-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  # Service Type and Deployment Configuration
  deployment_controller {
    type = "ECS"
  }

  # Load Balancer Configuration
  load_balancer {
    target_group_arn = aws_lb_target_group.my_terra_tg.arn
    container_name   = "clixx-cont"
    container_port   = 80
  }

  health_check_grace_period_seconds = 30

  # Ensuring service is created only after cluster is ready
  depends_on = [
    aws_ecs_cluster.ecs_cluster,
    aws_lb_listener.http_listener,
    aws_ecs_task_definition.ecs_task]
}


# Creating Route 53 record
resource "aws_route53_record" "my_record" {
  zone_id = var.Record
  name    = "dev.clixx-samuel.com"
  type    = "A"

  alias {
    name                   = aws_lb.web_lb.dns_name 
    zone_id                = aws_lb.web_lb.zone_id 
    evaluate_target_health = false  
  }
  set_identifier = "GeoLocation-Record"
  # Geolocation routing policy
  geolocation_routing_policy {
    country = "GB"
  }
}

# Creating Bastion Server
resource "aws_instance" "my-ec2-instance" {
    ami                         = "ami-0ddc798b3f1a5117e"
    instance_type               = var.instance_type
    vpc_security_group_ids      = [aws_security_group.terra_Bast_sg.id]
    subnet_id                   = aws_subnet.public_sub.id
    key_name                    = aws_key_pair.Stack_KP.key_name
    associate_public_ip_address = true

    root_block_device {
    volume_type                 = "gp2"
    volume_size                 = 30
    delete_on_termination       = true
    encrypted= "false"
    }
    tags                        = {
    Name                        = "Bastion-Server"
    }

    # Ensuring Bastion is created only after application server is ready
    depends_on = [aws_autoscaling_group.my_terra_asg]
}
