## External IP addresses

We can query the Terraform state files to get what we need. Why not use the Terraform output?
I haven't figured out how to use the looping syntax within the output...

This works:
```
for i in 0 1; do
  ip=`terraform state show module.aws_lab.aws_instance.jump[$i] | \
    grep -i '^public_ip' | \
    awk '{print $3}'`; let num=$i+1
  echo "Student${num}_Jumphost: ${ip}"
done
```

## Terraform variables

Terraform automatically loads the files
- `terraform.tfvars`
- `*.auto.tfvars`

We can use the `terraform.tfvars` for the private information such as the AWS key and secret

## Image handling

Currently image IDs are statically stored in a region / ID map variable, for example:
```
variable "ami_avi_controller" {
  type        = "map"
  description = "AMI by region"

  default = {
    us-west-2 = "ami-2c0bbf54"
    eu-west-2 = "ami-9caeb6f8"
  }
}
```

Use the following commands to get the latest image ID:
- Avi Controller
```
aws ec2 describe-images --owners 139284885014 --filters Name=name,Values='Avi-Controller-17.2.5*' | \
jq -r '.Images | \
sort_by(.CreationDate) | \
last(.[]).ImageId'
```
- CentOS
```
aws ec2 describe-images --owners aws-marketplace --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce | \
jq -r '.Images | \
sort_by(.CreationDate) | \
last(.[]).ImageId'
```

###### Notes
- aws cli accepts the `--region` option
- the above requires the [jq software](https://stedolan.github.io/jq/)

## Key handling

There are two required key pairs:
- A pair to access the environment from outside, `training-access`
- A pair to access the internal infrastructure, `training-internal`

The private portion of the keys is stored in the keys directory while the public portion needs to match as an available
AWS key pair.

```
for i in access internal; do
  key=$(ssh-keygen -yf ./keys/training-${i})
  aws ec2 import-key-pair --key-name training-${i} --public-key-material "${key}"
done
```

###### Notes
- It will be required to distribute at least one of these private keys to the entire class, don't use one we care about.