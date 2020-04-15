output outputs {
  value = {
    app_client       = aws_cognito_user_pool_client.app_client
    user_pool_domain = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${local.region}.amazoncognito.com"
    user_pool_id     = aws_cognito_user_pool.concourse.id
  }
}
