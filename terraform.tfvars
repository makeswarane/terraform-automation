# terraform.tfvars: Dynamic input file for ALL EC2 and network options
# // cmd: Edit this file for custom values, then terraform apply for one-click launch
# Example with 10 instances across regions, varied configs, network dynamics

s3_bucket_name = "my-ec2-keys-bucket"  // cmd: string e.g., "secure-keys-bucket" (must exist; create via aws s3 mb s3://bucket)

instances = [
  # Instance 1: Web server in us-east-1
  {
    name                  = "web-server-1"
    ubuntu_version        = "22.04"  // cmd: string e.g., "20.04"
    instance_type         = "t2.micro"  // cmd: string e.g., "m5.large"
    volume_size           = 20  // cmd: number e.g., 30
    create_pem_key        = true  // cmd: bool e.g., false
    number_of_instances   = 2  // cmd: number e.g., 3 (launch multiple of this config)
    purchasing_option     = "on_demand"  // cmd: string e.g., "spot"
    spot_price            = "0.01"  // cmd: string e.g., "0.005" (only if spot)
    public_access         = true  // cmd: bool e.g., false
    security_ports        = [22, 80, 443]  // cmd: list(number) e.g., [8080]
    user_data             = "userdata-web.sh"  // cmd: string e.g., "custom.sh"
    iam_role              = "web-role"  // cmd: string e.g., "admin-role"
    shutdown_behavior     = "stop"  // cmd: string e.g., "terminate"
    monitoring            = true  // cmd: bool e.g., false
    termination_protection = true  // cmd: bool e.g., false
    additional_ebs_volumes = [
      { device_name = "/dev/sdb", size = 50, type = "gp3", encrypted = true, iops = 3000, throughput = 125, delete_on_termination = true }
    ]  // cmd: list(object) e.g., add more volumes
    region                = "us-east-1"  // cmd: string e.g., "eu-west-1" (multi-region)
  },
  # Instance 2: GPU trainer in us-west-2
  {
    name                  = "gpu-trainer-1"
    ubuntu_version        = "20.04"
    instance_type         = "p3.2xlarge"
    volume_size           = 100
    create_pem_key        = true
    number_of_instances   = 1
    purchasing_option     = "spot"
    spot_price            = "0.5"
    public_access         = false
    security_ports        = [22]
    user_data             = "userdata-gpu.sh"
    iam_role              = "gpu-role"
    shutdown_behavior     = "terminate"
    monitoring            = true
    termination_protection = false
    elastic_gpu           = true
    additional_ebs_volumes = []
    region                = "us-west-2"
  },
  # Instance 3: DB server
  {
    name                  = "db-server-1"
    ubuntu_version        = "22.04"
    instance_type         = "m5.large"
    volume_size           = 50
    create_pem_key        = false
    key_name              = "existing-key"
    number_of_instances   = 1
    purchasing_option     = "on_demand"
    public_access         = false
    security_ports        = [3306, 22]
    user_data             = ""
    iam_role              = "db-role"
    shutdown_behavior     = "stop"
    monitoring            = true
    termination_protection = true
    additional_ebs_volumes = [{ device_name = "/dev/sdc", size = 100, type = "io1", encrypted = true, iops = 5000, delete_on_termination = false }]
    region                = "us-east-1"
  },
  # Instance 4
  {
    name                  = "app-server-1"
    ubuntu_version        = "20.04"
    instance_type         = "t3.medium"
    volume_size           = 30
    create_pem_key        = true
    number_of_instances   = 2
    purchasing_option     = "on_demand"
    public_access         = true
    security_ports        = [22, 8080]
    user_data             = "userdata-web.sh"
    iam_role              = "app-role"
    shutdown_behavior     = "stop"
    monitoring            = false
    termination_protection = false
    additional_ebs_volumes = []
    region                = "us-east-1"
  },
  # Instance 5
  {
    name                  = "worker-1"
    ubuntu_version        = "22.04"
    instance_type         = "c5.xlarge"
    volume_size           = 40
    create_pem_key        = true
    number_of_instances   = 3
    purchasing_option     = "spot"
    spot_price            = "0.02"
    public_access         = false
    security_ports        = [22]
    user_data             = ""
    iam_role              = "worker-role"
    shutdown_behavior     = "terminate"
    monitoring            = false
    termination_protection = false
    additional_ebs_volumes = []
    region                = "us-west-2"
  },
  # Instance 6
  {
    name                  = "cache-1"
    ubuntu_version        = "20.04"
    instance_type         = "r5.large"
    volume_size           = 30
    create_pem_key        = false
    key_name              = "existing-key"
    number_of_instances   = 1
    purchasing_option     = "on_demand"
    public_access         = false
    security_ports        = [6379, 22]
    user_data             = ""
    iam_role              = "cache-role"
    shutdown_behavior     = "stop"
    monitoring            = true
    termination_protection = true
    additional_ebs_volumes = []
    region                = "eu-west-1"
  },
  # Instance 7
  {
    name                  = "test-node-1"
    ubuntu_version        = "22.04"
    instance_type         = "t2.nano"
    volume_size           = 10
    create_pem_key        = true
    number_of_instances   = 1
    purchasing_option     = "on_demand"
    public_access         = true
    security_ports        = [22, 80]
    user_data             = ""
    iam_role              = null
    shutdown_behavior     = "terminate"
    monitoring            = false
    termination_protection = false
    additional_ebs_volumes = []
    region                = "us-east-1"
  },
  # Instance 8
  {
    name                  = "batch-processor-1"
    ubuntu_version        = "20.04"
    instance_type         = "c5.2xlarge"
    volume_size           = 60
    create_pem_key        = true
    number_of_instances   = 1
    purchasing_option     = "spot"
    spot_price            = "0.1"
    public_access         = false
    security_ports        = [22]
    user_data             = ""
    iam_role              = "batch-role"
    shutdown_behavior     = "terminate"
    monitoring            = false
    termination_protection = false
    additional_ebs_volumes = [{ device_name = "/dev/sdd", size = 200, type = "gp3", encrypted = true, delete_on_termination = true }]
    region                = "us-west-2"
  },
  # Instance 9
  {
    name                  = "frontend-1"
    ubuntu_version        = "22.04"
    instance_type         = "t3.small"
    volume_size           = 15
    create_pem_key        = false
    key_name              = "existing-key"
    number_of_instances   = 2
    purchasing_option     = "on_demand"
    public_access         = true
    security_ports        = [22, 80, 443]
    user_data             = "userdata-web.sh"
    iam_role              = "frontend-role"
    shutdown_behavior     = "stop"
    monitoring            = true
    termination_protection = false
    additional_ebs_volumes = []
    region                = "eu-west-1"
  },
  # Instance 10
  {
    name                  = "monitor-node-1"
    ubuntu_version        = "20.04"
    instance_type         = "m5.xlarge"
    volume_size           = 40
    create_pem_key        = true
    number_of_instances   = 1
    purchasing_option     = "on_demand"
    public_access         = false
    security_ports        = [22, 9090]
    user_data             = ""
    iam_role              = "monitor-role"
    shutdown_behavior     = "stop"
    monitoring            = true
    termination_protection = true
    additional_ebs_volumes = []
    region                = "us-east-1"
  }
  # // cmd: Add more objects here for >10 instances; all launch in one terraform apply
]

regions = {
  "us-east-1" = "us-east-1"
  "us-west-2" = "us-west-2"
  "eu-west-1" = "eu-west-1"
}  // cmd: Change to map(string) e.g., add { "ap-south-1" = "ap-south-1" } for more regions

create_network = true  // cmd: Change to bool e.g., false (use existing network)
vpc_cidr_block = "10.0.0.0/16"  // cmd: Change to string e.g., "172.16.0.0/16"
subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]  // cmd: list(string) e.g., add more for multi-AZ
azs = ["us-east-1a", "us-east-1b"]  // cmd: list(string) e.g., ["us-east-1c"]
public_subnets = [true, false]  // cmd: list(bool) e.g., [false, false]
enable_nat_gateway = true  // cmd: Change to bool e.g., false (NAT for private subnets)

default_tags = {
  Environment = "prod"  // cmd: map(string) e.g., add { Project = "ec2", Owner = "team" }
}

aws_region = "us-east-1"  // cmd: Change to string e.g., "us-west-2" (primary region)
public_key_path = "~/.ssh/id_rsa.pub"  // cmd: Change to string e.g., "~/.ssh/my-key.pub" (for existing key upload)
vpc_id = ""  // cmd: Change to string e.g., "vpc-12345" if create_network=false
subnet_ids = []  // cmd: Change to list(string) e.g., ["subnet-12345"] if create_network=false
