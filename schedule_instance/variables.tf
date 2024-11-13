variable "stop_schedule" {
  type = string
  default = "cron(43 15 * * ? *)"
}

variable "start_schedule" {
  type = string
  default = "cron(46 15 * * ? *)"
}

variable "tag_key" {
  type = string
  default = "Name"
}

variable "tag_value" {
  type = string
  default = "dev_test"
}