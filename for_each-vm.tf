resource "yandex_compute_instance" "db" {
  for_each = {
    main = var.each_vm[0]
    replica = var.each_vm[1]
  }
  name        = "${each.value.vm_name}"
  platform_id = var.vms_resources.platform_id


  resources {
    cores         = "${each.value.cpu}"
    memory        = "${each.value.ram}"
    core_fraction = var.vms_resources.core_fraction
  }

  boot_disk {
    initialize_params {
        image_id = data.yandex_compute_image.ubuntu.image_id
        type     = var.vms_resources.disk_type
        size     = "${each.value.disk_volume}"
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