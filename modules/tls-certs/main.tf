# ----- Create the CA Certificate -----

# CA private key
resource "tls_private_key" "ca" {
  algorithm   = var.algorithm
  # ecdsa_curve = "${var.algorithm}" == "ECDSA" ? var.ecdsa_curve : "P224"
  # rsa_bits = "${var.algorithm}" == "RSA" ? var.rsa_bits : "2048"
  ecdsa_curve = var.ecdsa_curve
  rsa_bits = var.rsa_bits
}

# CA certificate
resource "tls_self_signed_cert" "ca" {
  # key_algorithm   = tls_private_key.ca.algorithm
  private_key_pem = tls_private_key.ca.private_key_pem
  is_ca_certificate = true 

  subject {
    common_name  = "${var.ca_common_name}"
    organization = "${var.ca_organization}"
  }

  validity_period_hours = "${var.validity_period_hours}"

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "crl_signing",
  ]

#   # Store the CA public key in a file.
#   provisioner "local-exec" {
#     command = "echo '${tls_self_signed_cert.ca.cert_pem}' > '${var.ca_public_key_file_path}' && chmod ${var.permissions} '${var.ca_public_key_file_path}' && chown ${var.owner} '${var.ca_public_key_file_path}'"
#   }
   
}

# --------------------------------------


# ---------- TLS Signed certificate using the CA certificate -----------
# Server private key
resource "tls_private_key" "server" {
  # count       = var.servers
  algorithm   = var.algorithm
  #ecdsa_curve = "P521"
}

# Server signing request
resource "tls_cert_request" "server" {
  # count           = var.servers
#   key_algorithm   = element(tls_private_key.server.*.algorithm, count.index)
#   private_key_pem = element(tls_private_key.server.*.private_key_pem, count.index)

  # key_algorithm   = tls_private_key.server[count.index].algorithm
  # private_key_pem = tls_private_key.server[count.index].private_key_pem
  # key_algorithm   = tls_private_key.server.algorithm
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name  = var.common_name
    organization = "HashiCorp Demo"
  }

  dns_names = concat([
    var.vaulthost,
    "*.${var.vaulthost}",
    "vault",
    "vault.local",
    "vault.default.svc.cluster.local",
    "*.vault-internal",
    # Common
    # "vault-server-sec-${count.index}",
    "localhost",
    "*.${var.common_name}"
  ],
  [for i in range(var.servers): "vault-${i}"]
  )

  ip_addresses = [
    # var.compute_address,
    "127.0.0.1"
  ]
}

# Server certificate
resource "tls_locally_signed_cert" "server" {
  # count            = var.servers
#   cert_request_pem = element(tls_cert_request.server.*.cert_request_pem, count.index)
  # cert_request_pem = tls_cert_request.server[count.index].cert_request_pem
  cert_request_pem = tls_cert_request.server.cert_request_pem
  # ca_key_algorithm = tls_private_key.ca.algorithm
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 720 # 30 days

  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "server_auth",
  ]
}