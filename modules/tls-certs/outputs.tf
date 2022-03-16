output "vault_crt" {
  # value = tls_locally_signed_cert.server.*.cert_pem
  value = tls_locally_signed_cert.server.cert_pem
  sensitive = true
}
output "vault_ca" {
  value = tls_self_signed_cert.ca.cert_pem
  sensitive = true
}
output "vault_key" {
  # value = tls_private_key.server.*.private_key_pem
  value = nonsensitive(tls_private_key.server.private_key_pem)
  sensitive = true
}
