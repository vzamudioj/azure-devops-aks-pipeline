
data "azurerm_kubernetes_cluster" "this" {
  name                = "${var.cluster_name}_${var.environment}"
  resource_group_name = azurerm_resource_group.resource_group.name

  # Comment this out if you get: Error: Kubernetes cluster unreachable 
  # depends_on = [azurerm_kubernetes_cluster.this]
}

provider "helm" {
  kubernetes = {
    host                   = data.azurerm_kubernetes_cluster.this.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate)
  }
}


resource "helm_release" "cert_manager" {
  name = "cert-manager"

  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.13.1"

  set = [
    {
      name  = "installCRDs"
      value = "true"
    }
  ]

}