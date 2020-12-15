module "vpc" {
  source         = "./modules/vpc"
  vpc_id         = var.vpc_id
  public_subnet  = var.public_subnet
  private_subnet = var.private_subnet
}

# output "vpc_id" {
#   value = module.vpc.vpc_out.public_subnets_ids
# }

module "alb" {
  source        = "./modules/alb"
  vpc_id        = module.vpc.vpc_out.vpc_id
  public_subnet = module.vpc.vpc_out.public_subnets_ids
}

module "asg" {
  source           = "./modules/asg"
  vpc_id           = module.vpc.vpc_out.vpc_id
  private_subnet   = module.vpc.vpc_out.private_subnets_ids
  key_name         = var.key_name
  instance_type    = var.instance_type
  alb_sg           = module.alb.alb_out.alb_sg
  alb_tg           = module.alb.alb_out.alb_tg
  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size
  clb_dns          = module.elb.clb_dns
}

module "elb" {
  source         = "./modules/elb"
  vpc_id         = module.vpc.vpc_out.vpc_id
  private_subnet = module.vpc.vpc_out.private_subnets_ids
  asgsg          = module.asg.asgsg
  sql_id         = module.sqldb.sql_id
}

module "sqldb" {
  source         = "./modules/sqldb"
  sqldbinstance  = var.sqldbinstance
  instance_type  = var.instance_type
  key_name       = var.key_name
  vpc_id         = module.vpc.vpc_out.vpc_id
  private_subnet = module.vpc.vpc_out.private_subnets_ids
  clb_sg         = module.elb.clb_sg
}