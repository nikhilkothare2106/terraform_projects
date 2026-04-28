# variable "dev_bucket" {
# }
# variable "stage_bucket" {
# }

variable "buckets" {
  type = map(string)
}
