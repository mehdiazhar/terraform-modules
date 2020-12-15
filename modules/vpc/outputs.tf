# output "vpc_id" {
#   value = aws_vpc.mehdi-vpc.id
# }
# output "public_subnets_ids" {
#   value = "${aws_subnet.public_subnet.*.id}"
# }
# output "private_subnets_ids" {
#   value = "${aws_subnet.private_subnet.*.id}"
# }

locals {
  vpc_output = {
    vpc_id              = aws_vpc.mehdi-vpc.id
    public_subnets_ids  = aws_subnet.public_subnet.*.id
    private_subnets_ids = aws_subnet.private_subnet.*.id
  }
}

output "vpc_out" {
  value = local.vpc_output
}
