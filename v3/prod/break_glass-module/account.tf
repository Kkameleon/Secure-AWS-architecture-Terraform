#############################
# BREAK_GLASS ACCOUNT BEGINNING
#############################

# We have :
# - A break-glass account

data "local_file" "pgp_key_break_glass" {
  filename = "./${path.module}/public-key-binary-break_glass.gpg"
}

resource "aws_iam_user" "break_glass" {
  name = "break_glass"
}

resource "aws_iam_user_login_profile" "break_glass_login_profile" {
  user    = aws_iam_user.break_glass.name
  pgp_key = data.local_file.pgp_key_break_glass.content_base64
}

# BreakGlass user
resource "aws_iam_group" "break_glass_user" {
  name = "break_glass_user"
}

resource "aws_iam_group_membership" "break_glass_membership" {
  name = "administrators_membership"

  users = [
    aws_iam_user.break_glass.name
  ]

  group = aws_iam_group.break_glass_user.name
}

resource "aws_iam_group_policy_attachment" "break_glass_admin_access" {
  group       = aws_iam_group.break_glass_user.name
  policy_arn = data.aws_iam_policy.administrator_access.arn
}

#############################
# BREAK_GLASS ACCOUNT END
#############################


