#############################
# USER GROUPS BEGINNING
#############################

# Administrators
resource "aws_iam_group" "administrators" {
  name = "administrators"
}

# Developpers
resource "aws_iam_group" "developpers" {
  name = "developpers"
}

# Prod users
resource "aws_iam_group" "prod_users" {
  name = "prod_users"
}

#############################
# USER GROUP END
#############################


#############################
# USER POLICIES BEGINNING
#############################

data "aws_caller_identity" "current" {
}

# Developpers have access to databases and servers tagged "dev"
resource "aws_iam_policy" "developpers_policy" {
  name        = "developpers_policy"
  description = "Policy for developpers"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action"   : "ec2:*",
        "Effect"   : "Allow",
        "Resource" : "*",
        "Condition": {
            "StringEquals": {
               "ec2:ResourceTag/env": "dev"
              }
        }
      },
      {
        "Action"   : "rds:*",
        "Effect"   : "Allow",
        "Resource" : "*",
        "Condition": {
            "StringEquals": {
                "rds:ResourceTag/env": "dev"
              }
        }
      },
     
    ]
  })
}

# Developpers have access to databases and servers tagged "prod" and "preprod"
resource "aws_iam_policy" "prod_users_policy" {
  name        = "prod_users_policy"
  description = "Policy for prod_users"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action"   : "ec2:*",
        "Effect"   : "Allow",
        "Resource" : "*",
        "Condition": {
            "StringEquals": {
               "ec2:ResourceTag/env": ["preprod","prod"]
              }
        }
      },
      {
        "Action"   : "rds:*",
        "Effect"   : "Allow",
        "Resource" : "*",
        "Condition": {
            "StringEquals": {
                "rds:ResourceTag/env": ["preprod","prod"]
              }
        }
      },
   
    ]
  })
}

# Administrators
resource "aws_iam_policy" "administrators_policy" {
  name        = "administrators_policy"
  description = "Policy for administrators"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "NotAction": [
                "iam:*",
                "organizations:*",
                "account:*"
            ],
            "Resource": "*",
            "Condition": {
                "StringNotEquals": {
                    "aws:ResourceTag/security": "high"
                }
              }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole",
                "iam:DeleteServiceLinkedRole",
                "iam:ListRoles",
                "organizations:DescribeOrganization",
                "account:ListRegions"
            ],
            "Resource": "*"
        }
    ]
})
}


resource "aws_iam_group_policy_attachment" "administrators_admin_access" {
  group       = aws_iam_group.administrators.name
  policy_arn = aws_iam_policy.administrators_policy.arn
}


resource "aws_iam_group_policy_attachment" "developpers_access" {
  group       = aws_iam_group.developpers.name
  policy_arn = aws_iam_policy.developpers_policy.arn
}

resource "aws_iam_group_policy_attachment" "prod_users_access" {
  group       = aws_iam_group.prod_users.name
  policy_arn = aws_iam_policy.prod_users_policy.arn
}

#############################
# USER POLICIES BEGINNING
#############################


# #############################
# # POLICY BOUNDARIES BEGINNING
# #############################

# resource "aws_iam_policy" "permission_boundary_for_developpers" {
#   name        = "permission_boundary_for_developpers"
#   description = "Boundaries for developpers"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         "Action"   :"ec2:*"
#         "Effect"   : "Allow"
#         "Resource" : "*"
#         "Condition": {
#             "StringEquals": {
#                "ec2:ResourceTag/env": "dev"
#               }
#         }
#       },
#       {
#         "Action"   : "rds:*"
#         "Effect"   : "Allow"
#         "Resource" : "*"
#         "Condition": {
#             "StringEquals": {
#                "rds:ResourceTag/env": "dev"
#               }
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_policy" "permission_boundary_for_prod_users" {
#   name        = "permission_boundary_for_prod_users"
#   description = "Boundaries for prod users"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         "Action"   :"ec2:*"
#         "Effect"   : "Allow"
#         "Resource" : "*"
#         "Condition": {
#             "StringEquals": {
#                "ec2:ResourceTag/env": ["preprod","prod"]
#               }
#         }
#       },
#       {
#         "Action"   : "rds:*"
#         "Effect"   : "Allow"
#         "Resource" : "*"
#         "Condition": {
#             "StringEquals": {
#                "rds:ResourceTag/env": ["preprod","prod"]
#               }
#         }
#       },
#     ]
#   })
# }


#    {
#         "Action": [
#           "iam:CreateInstanceProfile",
#           "iam:DeleteInstanceProfile",
#           "iam:GetInstanceProfile",
#           "iam:AddRoleToInstanceProfile",
#           "iam:RemoveRoleFromInstanceProfile",
#           "iam:ListInstanceProfilesForRole"
#         ],
#         "Effect": "Allow",
#         "Resource": "*"
#       },
#       {
#         "Effect": "Allow",
#         "Action": [
#             "iam:CreateRole",
#             "iam:PutRolePolicy",
#             "iam:DeleteRolePolicy"
#         ],
#         "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/app-*",

#         "Condition": {
#           "StringEquals": {
#               "iam:PermissionsBoundary": "${aws_iam_policy.permission_boundary_for_developpers.arn}"
#           }
#         }
#       }


#  {
#         "Action": [
#           "iam:CreateInstanceProfile",
#           "iam:DeleteInstanceProfile",
#           "iam:GetInstanceProfile",
#           "iam:AddRoleToInstanceProfile",
#           "iam:RemoveRoleFromInstanceProfile",
#           "iam:ListInstanceProfilesForRole"
#         ],
#         "Effect": "Allow",
#         "Resource": "*"
#       },
#       {
#         "Effect": "Allow",
#         "Action": [
#             "iam:CreateRole",
#             "iam:PutRolePolicy",
#             "iam:DeleteRolePolicy"
#         ],
#         "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/app-*",

#         "Condition": {
#           "StringEquals": {
#               "iam:PermissionsBoundary": "${aws_iam_policy.permission_boundary_for_developpers.arn}"
#           }
#         }
#       }
# #############################
# # POLICY BOUNDARIES END
# #############################