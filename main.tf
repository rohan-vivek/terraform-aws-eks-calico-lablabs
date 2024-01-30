provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

resource "helm_repository" "default" {
  name = var.helm_repo_name
  url  = var.helm_repo_url
}

resource "helm_release" "calico" {
  depends_on = [helm_repository.default]
  count      = var.enabled ? 1 : 0
  name       = var.helm_release_name
  repository = helm_repository.default.metadata[0].name
  chart      = var.helm_chart_name
  namespace  = var.k8s_namespace
  version    = var.helm_chart_version

  values = [
    "${templatefile("${path.module}/templates/values.yaml.tpl",
      {
        "calico_version"         = var.calico_version,
        "calico_image"           = var.calico_image,
        "typha_image"            = var.typha_image,
        "service_account_create" = var.service_account_create,
      })
    }"
  ]
}
