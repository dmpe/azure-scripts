data "azuread_application_published_app_ids" "well_known" {}
data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

resource "azuread_application_registration" "argocd2" {
  display_name            = "argocd2"
  sign_in_audience        = "AzureADMyOrg"
  group_membership_claims = ["SecurityGroup"]
}

resource "azuread_application_redirect_uris" "name" {
  application_id = azuread_application_registration.argocd2.id
  redirect_uris  = ["https://testvmalfadogmarker.westus3.cloudapp.azure.com/auth/callback", "https://4.242.221.93/auth/callback"]
  type           = "Web"
}

resource "azuread_application_api_access" "example_msgraph" {
  application_id = azuread_application_registration.argocd2.id
  api_client_id  = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
  scope_ids      = ["e1fe6dd8-ba31-4d61-89e7-88639da4683d"] # User.Read
}

resource "azuread_application_optional_claims" "example" {
  application_id = azuread_application_registration.argocd2.id

  access_token {
    name = "groups"
  }

  id_token {
    name = "groups"
  }

  saml2_token {
    name = "groups"
  }
}


resource "azuread_service_principal" "example" {
  client_id = azuread_application_registration.argocd2.client_id
}

resource "azuread_app_role_assignment" "example" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["User.Read"]
  app_
  principal_object_id = azuread_service_principal.example.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}
