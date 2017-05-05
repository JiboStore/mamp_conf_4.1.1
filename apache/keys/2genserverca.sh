export PW=`cat password`

# http://stackoverflow.com/questions/8443081/how-are-ssl-certificate-server-names-resolved-can-i-add-alternative-names-using/8444863#8444863
# https://www.playframework.com/documentation/2.5.x/CertificateGeneration
#  -ext san=dns:10.6.0.18 \

# Create a self signed key pair root CA certificate.
keytool -genkeypair -v \
  -alias rootca \
  -dname "CN=10.6.0.18, OU=IGG PTE. LTD., O=IGG PTE. LTD., L=Singapore, ST=Singapore, C=SG" \
  -keystore rootca.jks \
  -keypass:env PW \
  -storepass:env PW \
  -keyalg RSA \
  -keysize 4096 \
  -ext KeyUsage:critical="keyCertSign" \
  -ext BasicConstraints:critical="ca:true" \
  -ext san=ip:10.6.0.18 \
  -validity 3650

# Export the exampleCA public certificate as exampleca.crt so that it can be used in trust stores.
keytool -export -v \
  -alias rootca \
  -file rootca.crt \
  -keypass:env PW \
  -storepass:env PW \
  -keystore rootca.jks \
  -rfc