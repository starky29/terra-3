resource "local_file" "inventory" {
    depends_on = [yandex_compute_instance.web, yandex_compute_instance.db, yandex_compute_instance.storage]
    filename = "./hosts.yml"
    content = templatefile("./ansible.tftpl", {
        webservers = [yandex_compute_instance.web],
        databases = [yandex_compute_instance.db],
        storage = [yandex_compute_instance.storage]
    })
}