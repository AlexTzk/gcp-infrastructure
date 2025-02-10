module "iap_tunneling" {
  source = "terraform-google-modules/bastion-host/google//modules/iap-tunneling"

  project                    = "${var.project}"
  network                    = "${var.privatenetwork_subnet}"
  service_accounts           = ["alex@hey.com"]
  create_firewall_rule       = false
  instances = [{
    name = "${var.company}-${var.env}-bastion-nfs"
    zone = "${var.zone}"
  }]

  members = [
#    "group:devs@example.com",
    "user:alex@hey.com",
  ]
}
