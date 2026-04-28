# variable "dev_bucket" {
# }
# variable "stage_bucket" {
# }

variable "buckets" {
  type = map(string)
}

# variable "replication_pairs" {
#   description = "Bucket replication source and destination pairs"

#   type = map(object({
#     source = string
#     dest   = string
#   }))
# }