variable "subscription_id" {
  type        = string
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."
}

variable "tenant_id" {
  type        = string
  description = "The admin username for the new cluster."
}