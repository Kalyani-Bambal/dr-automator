#############################################################
# Amazon EBS CSI Driver IAM Role
#############################################################

resource "aws_iam_role" "ebs_csi_driver" {

  name = "${local.name_prefix}-ebs-csi-driver-role"

  description = "IAM Role for Amazon EBS CSI Driver using IRSA"

  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-ebs-csi-driver-role"

      Resource = "IRSA"

      KubernetesServiceAccount = "ebs-csi-controller-sa"

      KubernetesNamespace = "kube-system"

    }

  )

}

#############################################################
# Attach AWS Managed Policy
#############################################################

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {

  role = aws_iam_role.ebs_csi_driver.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"

}