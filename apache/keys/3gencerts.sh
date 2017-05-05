export PW=`cat password`

# Create a server certificate, tied to example.com
keytool -genkeypair -v \
  -alias mylocalhost \
  -dname "CN=10.6.0.18, OU=IGG PTE. LTD., O=IGG PTE. LTD., L=Singapore, ST=Singapore, C=SG" \
  -keystore mylocalhost.jks \
  -keypass:env PW \
  -storepass:env PW \
  -keyalg RSA \
  -keysize 2048 \
  -validity 3850

# Create a certificate signing request for example.com
keytool -certreq -v \
  -alias mylocalhost \
  -keypass:env PW \
  -storepass:env PW \
  -keystore mylocalhost.jks \
  -file mylocalhost.csr

# Tell exampleCA to sign the example.com certificate. Note the extension is on the request, not the
# original certificate.
# Technically, keyUsage should be digitalSignature for DHE or ECDHE, keyEncipherment for RSA.
keytool -gencert -v \
  -alias rootca \
  -keypass:env PW \
  -storepass:env PW \
  -keystore rootca.jks \
  -infile mylocalhost.csr \
  -outfile mylocalhost.crt \
  -ext KeyUsage:critical="digitalSignature,keyEncipherment" \
  -ext EKU="serverAuth" \
  -ext san=ip:10.6.0.18 \
  -rfc

# Tell example.com.jks it can trust exampleca as a signer.
keytool -import -v \
  -alias rootca \
  -file rootca.crt \
  -keystore mylocalhost.jks \
  -storetype JKS \
  -storepass:env PW << EOF
yes
EOF

# Import the signed certificate back into example.com.jks 
keytool -import -v \
  -alias mylocalhost \
  -file mylocalhost.crt \
  -keystore mylocalhost.jks \
  -storetype JKS \
  -storepass:env PW

# List out the contents of example.com.jks just to confirm it.  
# If you are using Play as a TLS termination point, this is the key store you should present as the server.
keytool -list -v \
  -keystore mylocalhost.jks \
  -storepass:env PW