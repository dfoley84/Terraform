provider "vra7" {
    username = "${var.username}"
    password = "${var.password}"
    host     = "${var.Host}"
    tenant   = "${var.tenant}"
    allow_unverified_ssl = true
}

resource "vra7_resource" "Catalog_Request" {
    catalog_name = "${var.catalog_Windows}"  
    catalog_configuration ={
        _deploymentName = "PRDTEST"
        VirtualMachine.Disk1.Size = 20
    }
    resource_configuration{
        MZvm.cpu = 2
        MZvm.memory = 4092
        MZvm._cluster = 2 
    }
}
