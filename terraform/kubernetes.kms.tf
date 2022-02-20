resource "aws_kms_key" "eks" {
  description             = "Primary EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

}


resource "aws_kms_alias" "eks" {
  name          = "alias/secret-encryption-eks" #TODO: You might wanna change the name
  target_key_id = aws_kms_key.eks.key_id
}