resource "aws_s3_bucket" "this" {
  bucket = var.config.bucket_name
  tags = merge(
    {
      Name      = var.config.bucket_name
      ManagedBy = "Terraform"
      Writer    = "Cloud-Club"
    },
    var.config.tags
  )
}

# Ownership controls - BucketOwnerEnforced is recommended to disable ACLs
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = var.config.object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.config.public_access_block
  block_public_policy     = var.config.public_access_block
  ignore_public_acls      = var.config.public_access_block
  restrict_public_buckets = var.config.public_access_block
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.config.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.config.server_side_encryption.sse_algorithm
      kms_master_key_id = var.config.server_side_encryption.kms_master_key_id
    }
  }
}

# Lifecycle Management
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.config.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.config.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "filter" {
        for_each = rule.value.prefix != null ? [1] : []
        content {
          prefix = rule.value.prefix
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days = expiration.value.days
        }
      }

      dynamic "transition" {
        for_each = rule.value.transition != null ? rule.value.transition : []
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition != null ? rule.value.noncurrent_version_transition : []
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }
}

# Intelligent Tiering
resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  for_each = { for it in var.config.intelligent_tiering : it.name => it }
  bucket   = aws_s3_bucket.this.id
  name     = each.value.name
  status   = each.value.status

  dynamic "tiering" {
    for_each = each.value.tiering
    content {
      access_tier = tiering.value.access_tier
      days        = tiering.value.days
    }
  }
}

# Logging
resource "aws_s3_bucket_logging" "this" {
  count  = var.config.logging != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = var.config.logging.target_bucket
  target_prefix = var.config.logging.target_prefix
}

# CORS Configuration
resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(var.config.cors_policy) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = var.config.cors_policy
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

# Bucket Policy
resource "aws_s3_bucket_policy" "this" {
  count  = length(var.config.s3_policy_statements) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this[0].json
}

data "aws_iam_policy_document" "this" {
  count = length(var.config.s3_policy_statements) > 0 ? 1 : 0
  dynamic "statement" {
    for_each = var.config.s3_policy_statements
    content {
      actions   = statement.value.actions
      resources = statement.value.resources
      effect    = statement.value.effect

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}
