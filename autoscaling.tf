#Template with us-east-1 AMI frontend
resource "aws_launch_template" "frontend" {
  name_prefix            = "template-nic-frontend-tf"
  image_id               = "ami-0022f774911c1d690"
  instance_type          = "t3a.micro"
  user_data              = filebase64("front_end2.sh")
  vpc_security_group_ids = [aws_security_group.nic-pb-sg.id]
  key_name               = "nicKeyPairNew"
}

#Deploy only when api listener is created
resource "aws_autoscaling_group" "smartbank_frontend" {
  depends_on = [
    aws_lb_listener.https_api_listener
  ]
  name                      = "test-nic-ASG-frontend"
  max_size                  = 3
  desired_capacity          = 1
  min_size                  = 1
  health_check_grace_period = 180
  health_check_type         = "ELB"
  force_delete              = true
  termination_policies      = ["OldestInstance"]
  vpc_zone_identifier       = [aws_subnet.private_subnets["tf_private_subnet_1"].id, aws_subnet.private_subnets["tf_private_subnet_2"].id]

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }
  #target_group_arns = [aws_lb_target_group.test.arn]
  target_group_arns = [aws_lb_target_group.frontend_tg.arn]
}

resource "aws_autoscaling_policy" "test" {
  name = "frontend_scaling_policy"
  #adjustment_type        = "ChangeInCapacity"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 60
  autoscaling_group_name    = aws_autoscaling_group.smartbank_frontend.name
  #scaling_adjustment        = 4
  #cooldown                  = 180

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 30.0
  }
}

#Template with us-east-1 AMI apiserver
resource "aws_launch_template" "apiserver" {
  name_prefix            = "template-nic-apisever-tf"
  image_id               = "ami-0022f774911c1d690"
  instance_type          = "t3a.micro"
  user_data              = filebase64("apiserver2.sh")
  vpc_security_group_ids = [aws_security_group.nic-pb-sg.id]
  key_name               = "nicKeyPairNew"
}

resource "aws_autoscaling_group" "smartbank_apiserver" {
  depends_on = [
    aws_db_instance.postgres
  ]
  name                      = "test-nic-ASG-apiserver"
  max_size                  = 3
  desired_capacity          = 1
  min_size                  = 1
  health_check_grace_period = 180
  health_check_type         = "ELB"
  force_delete              = true
  termination_policies      = ["OldestInstance"]
  vpc_zone_identifier       = [aws_subnet.private_subnets["tf_private_subnet_1"].id, aws_subnet.private_subnets["tf_private_subnet_2"].id]

  launch_template {
    id      = aws_launch_template.apiserver.id
    version = "$Latest"
  }
  #target_group_arns = [aws_lb_target_group.test.arn]
  target_group_arns = [aws_lb_target_group.api_tg.arn]

}

resource "aws_autoscaling_policy" "api_scaling_policy" {
  name = "apiserver_scaling_policy"
  #adjustment_type        = "ChangeInCapacity"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 60
  autoscaling_group_name    = aws_autoscaling_group.smartbank_apiserver.name
  #scaling_adjustment        = 4
  #cooldown                  = 180

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 30.0
  }
}
