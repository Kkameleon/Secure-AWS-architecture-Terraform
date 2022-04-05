output "all_groups_names" {
  value = [aws_iam_group.administrators.name,aws_iam_group.developpers.name,aws_iam_group.prod_users.name]
}