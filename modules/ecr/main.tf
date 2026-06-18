resource "aws_ecr_repository" "this" {
  count                = length(var.repo_names)
  name                 = "${var.env}-${var.repo_names[count.index]}"
  image_tag_mutability = "MUTABLE"

  lifecycle {
    prevent_destroy = false
  }
}
