# ..................................Creating my VPC.........................................
resource "aws_vpc" "terra_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "TERRAVPC"
  }
}

# ....................Creating public Subnet1 for ALB and Bastion server.....................
resource "aws_subnet" "public_sub" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.0.0/23"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "TERRA-PUB-SUB1"
  }
}

# ....................Creating public Subnet2 for ALB and Bastion server.....................
resource "aws_subnet" "public_sub2" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.2.0/23"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "TERRA-PUB-SUB2"
  }
}

# ....................Creating private subnet1 for MYSQL App server...........................
resource "aws_subnet" "private_sub" {
   vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "TERRA-PRIV-SUB1"
  }
}

# ....................Creating private subnet2 for MYSQL App server...........................
resource "aws_subnet" "private_sub1" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "TERRA-PRIV-SUB2"
  }
}

# ......................Creating private Subnet1 for MYSQL RDS DB..............................
resource "aws_subnet" "private_sub2" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.8.0/22"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "TERRA-PRIV-SUB3"
  }
}

# ......................Creating private Subnet2 for MYSQL RDS DB...............................
resource "aws_subnet" "private_sub3" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = "10.0.24.0/22"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "TERRA-PRIV-SUB4"
  }
}

# ...........................Creating an Internet Gateway.....................................
resource "aws_internet_gateway" "G_W" {
  vpc_id = aws_vpc.terra_vpc.id

  tags = {
    Name = "TERRA_GW"
  }
}

# ........................Creating route table for public subnets.............................
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

# ....................Create a network interface for the proxy EC2 instance..................
resource "aws_network_interface" "proxy_eni" {
  subnet_id       = aws_subnet.public_sub.id
  security_groups = [aws_security_group.proxy_sg.id]
  private_ip      = "10.0.1.10"
  tags = {
    Name = "Proxy Network Interface"
  }
}

# ........................Security Group for the Proxy Server.............................
resource "aws_security_group" "proxy_sg" {
  name        = "proxy-sg"
  description = "Allow outbound access to AWS endpoints"
  vpc_id      = aws_vpc.terra_vpc.id

  # Allow inbound SSH (for setup and debugging)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow inbound HTTP/HTTPS traffic for debugging (optional, remove if unnecessary)
  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (we'll restrict traffic using Squid config)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ..................Defining templatefile with local variables..........................
locals {
  bootstrap = templatefile("${path.module}/scripts/bootstrap.tpl", {
    REGION = "us-east-1",
    DB_PASS = data.aws_ssm_parameter.db_password.value,
    DB_NAME = data.aws_ssm_parameter.db_name.value,
    DB_USER = data.aws_ssm_parameter.db_user.value,
  })
  BOOTSTRAP1  = templatefile("${path.module}/scripts/BOOTSTRAP.tpl")
}

output "bootstrap_content" {
  value = local.bootstrap
}

# ............................Launch Proxy Server (EC2 Instance).............................
resource "aws_instance" "proxy" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.PATH_TO_PUBLIC_KEY
  security_groups = [aws_security_group.proxy_sg.id]

  network_interface {
    device_index          = 0
    network_interface_id  = aws_network_interface.proxy_eni.id
  }

  # Install Squid Proxy on the instance
  user_data = base64encode(local.BOOTSTRAP1)

  tags = {
    Name = "proxy-server"
  }
}

# .........................Creating route table for private subnets...........................
resource "aws_route_table" "priv_routetable" {
  vpc_id = aws_vpc.terra_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_network_interface.proxy_eni.id
  }

  tags = {
    Name = "TERRA_RT2"
  }
}

# .......................Creating route table2 for private DB subnets.........................
resource "aws_route_table" "priv_routetable2" {
  vpc_id = aws_vpc.terra_vpc.id

  tags = {
    Name = "TERRA_RT3"
  }
}

# .....................Associate public route table with public subnets........................
resource "aws_route_table_association" "connect_pub1" {
  subnet_id      = aws_subnet.public_sub.id
  route_table_id = aws_route_table.pub_routetable.id
}

resource "aws_route_table_association" "connect_pub2" {
  subnet_id      = aws_subnet.public_sub2.id
  route_table_id = aws_route_table.pub_routetable.id
}

# .....................Associate private route table with private subnets......................
resource "aws_route_table_association" "connect_priv3" {
  subnet_id      = aws_subnet.private_sub.id
  route_table_id = aws_route_table.priv_routetable.id
}

resource "aws_route_table_association" "connect_priv4" {
  subnet_id      = aws_subnet.private_sub1.id
  route_table_id = aws_route_table.priv_routetable.id
}

resource "aws_route_table_association" "connect_priv7" {
  subnet_id      = aws_subnet.private_sub2.id
  route_table_id = aws_route_table.priv_routetable2.id
}

resource "aws_route_table_association" "connect_priv8" {
  subnet_id      = aws_subnet.private_sub3.id
  route_table_id = aws_route_table.priv_routetable2.id
}

# ...............................Creating Key Pair.............................................
resource "aws_key_pair" "Stack_KP" {
  key_name   = "clixx_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

# .......................Creating Security Group for Bastion Server............................
resource "aws_security_group" "terra_Bast_sg" {
  vpc_id     = aws_vpc.terra_vpc.id
  name       = "clixx_Terra_Bast"
  description = "clixx Security Group For Bastion Instance & ELB"
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
  cidr_blocks       = ["10.0.0.0/16"] # Adjusted to my VPC CIDR
}
# MySQL ingress rule
resource "aws_security_group_rule" "mysql_ingress" {
  security_group_id = aws_security_group.terra_Bast_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_blocks       = ["10.0.0.0/16"]
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
# All traffic outbound rule
resource "aws_security_group_rule" "all_traffic" { 
  security_group_id = aws_security_group.terra_Bast_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

# ..........................Creating Security Group for DB................................
resource "aws_security_group" "terra_sg2" {
  vpc_id     = aws_vpc.terra_vpc.id
  name       = "clixx-terra-DB-sg"
  description = "clixx Security Group For RDS Instance"
}
resource "aws_security_group_rule" "mysql_ingress_db" {
  security_group_id = aws_security_group.terra_sg2.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_blocks       = ["10.0.0.0/16"]
}

# ........................Creating Security Group for ECS Server..........................
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

resource "aws_security_group_rule" "scp" {
  security_group_id        = aws_security_group.terra_ecs_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  cidr_blocks              = ["10.0.0.0/16"]
}

resource "aws_security_group_rule" "https" {
  security_group_id        = aws_security_group.terra_ecs_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_egress" {
  security_group_id        = aws_security_group.terra_ecs_sg.id
  type                     = "egress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  cidr_blocks              = ["0.0.0.0/0"]
}

# .............................Creating MYSQL DB Subnet Group..............................
resource "aws_db_subnet_group" "subgroupdb" {
  name       = "terra-mysql-subnet"
  subnet_ids = [aws_subnet.private_sub2.id, aws_subnet.private_sub3.id]

  tags = {
    Name = "MYSQL_SUBNET_Grp"
  }
}

# ........................Creating Security Group for VPC endpoint..........................
resource "aws_security_group" "endpoint_sg" {
  name        = "vpc-endpoint-sg"
  vpc_id      =  aws_vpc.terra_vpc.id
  description = "Security group for VPC endpoints"
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# # ...............................Creating ECS endpoint........................................
# resource "aws_vpc_endpoint" "ecs" {
#   vpc_id       = aws_vpc.terra_vpc.id
#   service_name = "com.amazonaws.${var.AWS_REGION}.ecs"
#   vpc_endpoint_type = "Interface"
#   subnet_ids   = [aws_subnet.private_sub.id, aws_subnet.private_sub1.id]  
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "ECS-EP"
#   }
# }

# # .............................ECS Telemetry VPC Endpoint....................................
# resource "aws_vpc_endpoint" "ecs_telemetry" {
#   vpc_id             = aws_vpc.terra_vpc.id
#   service_name       = "com.amazonaws.${var.AWS_REGION}.ecs-telemetry"
#   vpc_endpoint_type  = "Interface"
#   subnet_ids         = [aws_subnet.private_sub.id, aws_subnet.private_sub1.id]
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "ECS-Telemetry-EP"
#   }
# }

# # ...............................Creating ssm endpoint........................................
# resource "aws_vpc_endpoint" "ssm" {
#   vpc_id       = aws_vpc.terra_vpc.id
#   service_name = "com.amazonaws.${var.AWS_REGION}.ssm"
#   vpc_endpoint_type = "Interface"
#   subnet_ids   = [aws_subnet.private_sub.id, aws_subnet.private_sub1.id]  
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "SSM-EP"
#   }
# }

# # ..............................Creating ssm_msg endpoint.....................................
# resource "aws_vpc_endpoint" "ssm_msgs" {
#   vpc_id       = aws_vpc.terra_vpc.id
#   service_name = "com.amazonaws.${var.AWS_REGION}.ssmmessages"
#   vpc_endpoint_type = "Interface"
#   subnet_ids   = [aws_subnet.private_sub.id, aws_subnet.private_sub1.id]  
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "SSM_MSG-EP"
#   }
# }

# # ...............................Creating ECR endpoint........................................
# resource "aws_vpc_endpoint" "ecr_dkr" {
#   vpc_id       = aws_vpc.terra_vpc.id
#   service_name = "com.amazonaws.${var.AWS_REGION}.ecr.dkr"
#   vpc_endpoint_type = "Interface"
#   subnet_ids   = [aws_subnet.private_sub.id, aws_subnet.private_sub1.id]
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "ECR-EP"
#   }
# }

# # ...............................Creating ec2_msgs endpoint...................................
# resource "aws_vpc_endpoint" "ec2_msgs" {
#   vpc_id       = aws_vpc.terra_vpc.id
#   service_name = "com.amazonaws.${var.AWS_REGION}.ec2messages"
#   vpc_endpoint_type = "Interface"
#   subnet_ids   = [aws_subnet.private_sub.id, aws_subnet.private_sub1.id]  
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "EC2_MSG-EP"
#   }
# }

# # .............................Creating ECR.API endpoint......................................
# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id       = aws_vpc.terra_vpc.id
#   service_name = "com.amazonaws.${var.AWS_REGION}.ecr.api"
#   vpc_endpoint_type = "Interface"
#   subnet_ids   = [aws_subnet.private_sub.id, aws_subnet.private_sub1.id]  
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "ECR_API-EP"
#   }
# }

# # ...............................Creating logs endpoint........................................
# resource "aws_vpc_endpoint" "logs" {
#   vpc_id       = aws_vpc.terra_vpc.id
#   service_name = "com.amazonaws.${var.AWS_REGION}.logs"
#   vpc_endpoint_type = "Interface"
#   subnet_ids   = [aws_subnet.private_sub.id, aws_subnet.private_sub1.id]
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "LOGS-EP"
#   }
# }

# # ................................Creating RDS endpoint.......................................
# resource "aws_vpc_endpoint" "rds" {
#   vpc_id       = aws_vpc.terra_vpc.id
#   service_name = "com.amazonaws.${var.AWS_REGION}.rds"
#   vpc_endpoint_type = "Interface"
#   subnet_ids   = [aws_subnet.private_sub.id, aws_subnet.private_sub1.id]
#   security_group_ids = [aws_security_group.endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "RDS-EP"
#   }
# }

# .....................Retreiving my secretes from SSM parameter store........................
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

# .......................Restoring Database from Snapshot................................
resource "aws_db_instance" "restored_db" {
  identifier            = "wordpressdbclixx-ecs"
  snapshot_identifier   = var.snapshot_id  
  instance_class        = "db.m6gd.large"
  engine                = "mysql"
  db_subnet_group_name  = aws_db_subnet_group.subgroupdb.name
  vpc_security_group_ids = [aws_security_group.terra_sg2.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = data.aws_ssm_parameter.db_name.value
  }
}

# .............................IAM Role for ECS EC2 Instances.............................
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
          "ecs:SubmitContainerStateChange", 
          "ecs:StartTelemetrySession",      
          "ecs:UpdateContainerInstancesState", 
          "ecs:DescribeTasks",
          "ecs:DescribeClusters",
          "ecs:DescribeContainerInstances",
          "ecs:DeregisterContainerInstance",
          "ec2:CreateNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "ecs:StartTask",
          "ecs:StopTask",
          "ecs:ListServices",
          "ecs:RunTask",
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
          "s3:ListBucket",
          "s3:HeadBucket"
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
          "ssm:DescribeParameters",
          "ssm:TerminateSession",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:UpdateInstanceInformation",
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
          "ssmmessages:OpenDataChannel",
          "ec2messages:*"
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
          "arn:aws:s3:::stuff-bucket-fer",
          "arn:aws:s3:::stuff-bucket-fer/*"
        ]
      }
    ]
  })
}

# .........................Attach the policy to ECS instance role........................
resource "aws_iam_role_policy_attachment" "ecs_instance_policy_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = aws_iam_policy.ecs_role.arn
}

# ...............................ECS Instance Profile....................................
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "Clixx-ECS-Instance-Profile"
  role = aws_iam_role.ecs_instance_role.name
}

# ................Assume Role Policy Document for ECS Task Execution Role................
data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ...........................IAM Role for ECS Task Execution.............................
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ECS_TaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json
}

# .....................Attaching Policy to Task Execution Role..........................
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ..................................Creating Cluster.....................................
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "new-clixx-cluster"
}

# ..............................Creating a launch template...............................
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

# ..............................Creating Auto Scaling group.............................
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
  depends_on = [aws_db_instance.restored_db]
}

# ...........................Target type for EC2 instances..............................
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

# ..........................Creating Application Load Balancer..........................
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

# .............................Listeners for Routing Traffic...........................
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

# ................................Creating task definition..............................
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
      environment = [
        { name = "HTTP_PROXY", value = "http://10.0.1.10:3128" },
        { name = "HTTPS_PROXY", value = "http://10.0.1.10:3128" },
        { name = "NO_PROXY", value = ".amazonaws.com,169.254.169.254,localhost" }
      ],
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

# ............................Creating ECS Service....................................
resource "aws_ecs_service" "ecs_service" {
  name            = "new-clixx-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_terra_tg.arn
    container_name   = "clixx-cont"
    container_port   = 80
  }

  health_check_grace_period_seconds = 30

  # Ensuring service is created only after cluster is ready
  depends_on = [aws_ecs_cluster.ecs_cluster, aws_lb_listener.http_listener, aws_ecs_task_definition.ecs_task]
}

# ...........................Creating Route 53 record...................................
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

  geolocation_routing_policy {
    country = "GB"
  }
}



