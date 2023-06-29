import os,sys

# Usage (assuming terraform.auto.tfvars is your Terraform variables values file):
#   $ python3 pyvars_file.py terraform.auto.tfvars

file = open(sys.argv[1], "r")
new_content = ""

for line in file:
  line = line.strip()
  new_line = line.replace(" = ",",")
  new_line = new_line.replace("\"","")
  new_content = new_content + new_line + ",terraform,false\n"

file.close()

write_file = open(sys.argv[2], "w+")
write_file.write("#[var name],[var value],[var type],[var is sensitive]\n")
write_file.write(new_content)
write_file.close()