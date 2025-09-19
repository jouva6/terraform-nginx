terraform {
required_providers {
kubernetes = {
source = "hashicorp/kubernetes"
version = "2.27.0"
}
}
}
provider "kubernetes" {
config_path = "~/.kube/config"
}
variable "page_content" {
type = string
default = "<h1>Version 1 - Nginx via Terraform</h1>"
}
resource "kubernetes_config_map" "nginx_index" {
metadata {
   name = "nginx-index" 
   namespace = "yah-juva6-dev"   
}
data = { "index.html" = var.page_content }
}

resource "kubernetes_deployment" "nginx" {
metadata {
 name = "nginx-app"
 namespace = "yah-juva6-dev"
 }
spec {
replicas = 1
selector { match_labels = { app = "nginx-app" } }
template {
metadata { labels = { app = "nginx-app" } }
spec {
container {
name = "nginx"
image = "nginxinc/nginx-unprivileged:1.25-alpine"
port { container_port = 8080 }
volume_mount {
mount_path = "/usr/share/nginx/html/index.html"
sub_path = "index.html"
name = "html"
}
}
volume {
    name = "html"
    config_map {
       name = kubernetes_config_map.nginx_index.metadata[0].name
 }
 }
}
}
}
}
resource "kubernetes_service" "nginx" {
metadata { 
    name = "nginx-service"
    namespace = "yah-juva6-dev"
 
    }
  spec {
    selector = {
      app = "nginx-app" 
}
   port { 
     port = 8080 
     target_port = 8080
 }
 }
}
variable "page_content" {
type = string
default = "<h1>Version 2 - Nginx modifié via variable Terraform</h1>"
}
