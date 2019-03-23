# Example ufo/variables/base.rb
# More info on how variables work: http://ufoships.com/docs/variables/
@image = helper.full_image_name # includes the git sha tongueroo/demo-ufo:ufo-[sha].
@environment = helper.env_file(".env")
# Ensure that the cpu and memory values are a supported combination by Fargate.
# More info: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
@cpu = 256
@memory = 512
@memory_reservation = 512

@execution_role_arn = "arn:aws:iam::423858844957:role/ecsTaskExecutionRole"
