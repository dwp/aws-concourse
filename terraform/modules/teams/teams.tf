//resource "concourse_team" "main" {
//  team_name = "main"
//
//  owners = [
//    "group:github:org-name",
//    "group:github:org-name:team-name",
//    "user:github:tlwr",
//  ]
//
//  viewers = [
//    "user:github:samrees"
//  ]
//
//  members = [
//  ]
//
//  pipeline_operators = [
//  ]
//}
//
//resource "concourse_team" "dataworks" {
//  team_name = "dataworks"
//
//  owners = [
//    "group:github:org-name",
//    "group:github:org-name:team-name",
//    "user:github:tlwr",
//  ]
//
//  viewers = [
//    "user:github:samrees"
//  ]
//
//  members = [
//  ]
//
//  pipeline_operators = [
//  ]
//}
//
//resource "concourse_team" "utility" {
//  team_name = "utility"
//
//  owners = [
//    "group:github:org-name",
//    "group:github:org-name:team-name",
//    "user:github:tlwr",
//  ]
//
//  viewers = [
//    "user:github:samrees"
//  ]
//
//  members = [
//  ]
//
//  pipeline_operators = [
//  ]
//}
//
//resource "concourse_team" "identity" {
//  team_name = "identity"
//
//  owners = [
//    "group:github:org-name",
//    "group:github:org-name:team-name",
//    "user:github:tlwr",
//  ]
//
//  viewers = [
//    "user:github:samrees"
//  ]
//
//  members = [
//  ]
//
//  pipeline_operators = [
//  ]
//}

resource "concourse_team" "test_team" {
  team_name = "test_team"

  owners = [
    "group:oidc:admins",
  ]

  viewers = [
    "group:github:dip:devops"
  ]

  members = [
    "group:oidc:dataworks"
  ]
}

