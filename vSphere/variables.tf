#vSphere Credentials 
variable "Username"{}
variable "Password"{}
variable "Server"{}

#vSphere Prefix
variable "prdouction_prefix"{}
variable "Development_prefix"{}
variable "JDE_prefix"{}
variable "SDT_prefix"{}

#vSphere Environment
variable "vphere_datacenter"{}
variable "production_cluster"{}
variable "development_cluster"{}
variable "vRealizeFolder"{}

#Storage
variable "storage"{}
variable "Windows"{}

#Network
variable "vlan105"{}
variable "vlan106"{}
variable "vlan225"{}
variable "vlan180"{}
