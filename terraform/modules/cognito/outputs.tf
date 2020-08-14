output outputs {
  value = {
    name                = aws_cognito_user_pool_client.app_client.name
    app_client          = aws_cognito_user_pool_client.app_client
    user_pool_domain    = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${local.region}.amazoncognito.com"
    user_pool_id        = aws_cognito_user_pool.concourse.id
    user_pool_arn       = aws_cognito_user_pool.concourse.arn
    user_pool_client_id = aws_cognito_user_pool_client.app_client.id
    issuer              = "https://cognito-idp.${local.region}.amazonaws.com/${aws_cognito_user_pool.concourse.id}"
  }
}
