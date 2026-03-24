variable "config" {
  description = "Configuration object for S3 bucket"
  type = object({
    bucket_name         = string
    public_access_block = optional(bool, true)
    enable_versioning   = optional(bool, false)
    
    # Ownership controls
    object_ownership = optional(string, "BucketOwnerEnforced") # Recommended default

    # Server-Side Encryption
    server_side_encryption = optional(object({
      sse_algorithm     = optional(string, "AES256")
      kms_master_key_id = optional(string)
    }), { sse_algorithm = "AES256" })

    # CORS Configuration
    cors_policy = optional(list(object({
      allowed_headers = optional(list(string))
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = optional(list(string))
      max_age_seconds = optional(number)
    })), [])

    # Lifecycle Rules
    lifecycle_rules = optional(list(object({
      id      = string
      status  = optional(string, "Enabled")
      prefix  = optional(string)
      
      expiration = optional(object({
        days = number
      }))
      
      transition = optional(list(object({
        days          = number
        storage_class = string
      })))

      noncurrent_version_expiration = optional(object({
        days = number
      }))

      noncurrent_version_transition = optional(list(object({
        days          = number
        storage_class = string
      })))
    })), [])

    # Logging
    logging = optional(object({
      target_bucket = string
      target_prefix = optional(string, "log/")
    }))

    # Intelligent Tiering
    intelligent_tiering = optional(list(object({
      name   = string
      status = optional(string, "Enabled")
      tiering = list(object({
        access_tier = string
        days        = number
      }))
    })), [])

    # Policy Statements
    s3_policy_statements = optional(list(object({
      actions    = list(string)
      resources  = list(string)
      effect     = string
      principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      condition = optional(list(object({
        test     = string
        variable = string
        values   = list(string)
      })))
    })), [])

    tags = optional(map(string), {})
  })
}
