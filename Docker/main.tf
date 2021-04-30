module "image" {
  source = "./image"
  image  = "${var.image}"
}

module "container" {
  source   = "./container"
  image    = "${module.image.image_out}"
  name     = "${var.container_name}"
  int_port = "${var.int_port}"
  ext_port = "${var.ext_port}"
}
