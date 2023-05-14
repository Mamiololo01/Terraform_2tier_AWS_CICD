#create EC2 instance launch template for auto scaling group
resource "aws_launch_template" "Project-WebApp" {
  name                   = "Project-launch-tp"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.Project-webserver-sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Apache-WebApp"
    }
  }
  user_data = filebase64("apache.sh")
}

#auto scaling group to launch minimum of 2 instances and maximum of 3 instances
resource "aws_autoscaling_group" "Project-asg" {
  desired_capacity    = 5
  max_size            = 10
  min_size            = 3
  vpc_zone_identifier = [aws_subnet.Project-privsub1.id, aws_subnet.Project-privsub2.id]

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  launch_template {
    id = aws_launch_template.Project-WebApp.id
  }

  tag {
    key                 = "Name"
    value               = "Project-WebApp"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "Project-asg-attach" {
  autoscaling_group_name = aws_autoscaling_group.Project-asg.id
  lb_target_group_arn    = aws_lb_target_group.Project-launch-template.arn
}