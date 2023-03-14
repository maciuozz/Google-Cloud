terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.49.0"
    }
  }
}

provider "google" {
    credentials= file("cred.json")
    project= "premium-cipher-374400"
    region= "europe-southwest1"
    zone= "europe-southwest1-b"
}

resource "google_compute_network" "vpc_network" {
  name = "practica-network"
}

#Creacion de una IP statica.
resource "google_compute_address" "my_ip" {
  name= "static-ip"
}

#Creamos un firewall para permitir trafico HTTP en el puerto 80.
resource "google_compute_firewall" "allow_http" {
  name = "allow-http"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports = ["80"]
  }
  source_ranges = ["0.0.0.0/0"] #Cualquier dirección IP puede acceder a los servidores con la etiqueta "http-server".
  target_tags = ["http-server"]
}

#Creacion de la istancia.
resource "google_compute_instance" "my_vm" {
  depends_on= [
    google_compute_network.vpc_network,
    google_compute_address.my_ip
  ]
  name= "my-instance"
  machine_type= "e2-micro"
  tags = ["http-server"]
  #Script de configuracion inicial que instala apache2.
  metadata_startup_script = file("startup.sh")

  boot_disk {
    initialize_params {
      image= "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230114"
      size = 10
      type = "pd-ssd"
    }
  } 

  network_interface {
    network= google_compute_network.vpc_network.name
    access_config {
      nat_ip= google_compute_address.my_ip.address
    }
  }
}


resource "random_string" "mirandom" {
  length= 9
  special= false
  upper= false
}

#Creamos un bucket con un nombre aleatorio en minusculas, de longitud 9, sin caracteres especiales, llamando al recurso anterior.
resource "google_storage_bucket" "my-bucket" {
  name= "bucket-${random_string.mirandom.result}"
  location= "europe-southwest1"
}

#Creamos una cuenta de servicio.
resource "google_service_account" "example_sa" {
account_id = "service-account-${random_string.mirandom.result}"
display_name = "Example Service Account"
}

#Clave necesaria para que la cuenta de servicio pueda autenticarse.
resource "google_service_account_key" "example_sa_key" {
  service_account_id = google_service_account.example_sa.name
}

#Asignamos a la cuenta de servicio el rol de "objectAdmin" que otorga permisos de lectura, escritura y administración de los 
#objetos en el bucket. El correo electronico lo genera Google automáticamente cuando se crea la cuenta en el formato 
#"example-sa@my-project.iam.gserviceaccount.com".
resource "google_storage_bucket_iam_binding" "example_binding" {
  bucket = google_storage_bucket.my-bucket.name
  role = "roles/storage.objectAdmin"
  members = ["serviceAccount:${google_service_account.example_sa.email}"]
}