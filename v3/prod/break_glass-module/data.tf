#############################
# USER POLICIES BEGINNING
#############################

data "aws_iam_policy" "administrator_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

#############################
# USER POLICIES END
#############################