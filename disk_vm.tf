resource "yandex_compute_disk" "disks" {
  count = 3

  name     = "disk-${count.index}"
  type     = var.disks_resources.disk_type
  size     = var.disks_resources.disk_size
}

resource "yandex_compute_instance" "storage" {
  # count = 1
  name        = var.vms_name_storage
  depends_on = [ yandex_compute_disk.disks ]
  platform_id = var.vms_resources.platform_id

  resources {
    cores         = var.vms_resources.cores
    memory        = var.vms_resources.memory
    core_fraction = var.vms_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  dynamic secondary_disk {
    for_each = yandex_compute_disk.disks[*].id
      content {
        disk_id = secondary_disk.value
      }
  }
  metadata = {
    serial-port-enable = 1
    ssh-keys           = local.ssh_key
  }

  scheduling_policy { preemptible = var.vms_resources.preemptible }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat = var.vms_resources.nat
  }
  allow_stopping_for_update = true
}