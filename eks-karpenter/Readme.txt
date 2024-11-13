EKS Module Code

This code is split into two folders. 

$ tree
.
├── Readme.txt
├── modules               ---------> Modules (Cluster and Networking) 
│   ├── cluster
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── networking
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.t f
└── terraform              ---------> Root Folder
    └── dev
        └── us-east-1
            └── eks-cluster-deployment
                ├── main.tf
                └── outputs.tf

8 directories, 9 files

To access worker nodes via SSH you will need to generate a keypair. 

#aws ec2 create-key-pair --key-name Emanuael_keyPair --query 'KeyMaterial' --output text | out-file -encoding ascii -filepath Emanuael_keyPair.pem

To display your created keypair

aws ec2 describe-key-pairs --key-name Emanuael_keyPair.pem

Please run the following commands in the root directory 

terraform init 
terraform validate
terraform plan 
terraform apply


