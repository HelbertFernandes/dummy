#!/bin/sh

htpasswd -nbd $1 $2

# see: http://httpd.apache.org/docs/2.2/misc/password_encryptions.html
############################
### Basic Authentication ###
############################

#There are four formats that Apache recognizes for basic-authentication passwords. Note that not all formats work on every platform:

#PLAIN TEXT (i.e. unencrypted): Windows, BEOS, & Netware only.
#CRYPT: Unix only. Uses the traditional Unix crypt(3) function with a randomly-generated 32-bit salt (only 12 bits used) and the first 8 characters of the password.
#SHA1: "{SHA}" + Base64-encoded SHA-1 digest of the password.
#MD5: "$apr1$" + the result of an Apache-specific algorithm using an iterated (1,000 times) MD5 digest of various combinations of a random 32-bit salt and the password. See the APR source file apr_md5.c for the details of the algorithm.

### Generating values with htpasswd ###
#MD5
#$ htpasswd -nbm myName myPassword
#myName:$apr1$r31.....$HqJZimcKQFAMYayBlzkrA/
#
#SHA1
#$ htpasswd -nbs myName myPassword
#myName:{SHA}VBPuJHI7uixaa6LQGWx4s+5GKNE=
#
#CRYPT
#$ htpasswd -nbd myName myPassword
#myName:rqXexS6ZhobKA


### Generating CRYPT and MD5 values with the OpenSSL command-line program ###
#OpenSSL knows the Apache-specific MD5 algorithm.
#MD5
#$ openssl passwd -apr1 myPassword
#$apr1$qHDFfhPC$nITSVHgYbDAK1Y0acGRnY0
#
#CRYPT
#openssl passwd -crypt myPassword
#qQ5vTYO3c8dsU

### Validating CRYPT or MD5 passwords with the OpenSSL command line program ###
#The salt for a CRYPT password is the first two characters (converted to a binary value). To validate myPassword against rqXexS6ZhobKA
#
#CRYPT
#$ openssl passwd -crypt -salt rq myPassword
#Warning: truncating password to 8 characters
#rqXexS6ZhobKA
#
#Note that using myPasswo instead of myPassword will produce the same result because only the first 8 characters of CRYPT passwords are considered.
#The salt for an MD5 password is between $apr1$ and the following $ (as a Base64-encoded binary value - max 8 chars). To validate myPassword against $apr1$r31.....$HqJZimcKQFAMYayBlzkrA/
#
#MD5
#$ openssl passwd -apr1 -salt r31..... myPassword
#$apr1$r31.....$HqJZimcKQFAMYayBlzkrA/

### Database password fields for mod_dbd ###
#The SHA1 variant is probably the most useful format for DBD authentication. Since the SHA1 and Base64 functions are commonly available, other software can populate a database with encrypted passwords that are usable by Apache basic authentication.
#To create Apache SHA1-variant basic-authentication passwords in various languages:
#
#PHP
#'{SHA}' . base64_encode(sha1($password, TRUE))
#
#Java
#"{SHA}" + new sun.misc.BASE64Encoder().encode(java.security.MessageDigest.getInstance("SHA1").digest(password.getBytes()))
#
#ColdFusion
#"{SHA}" & ToBase64(BinaryDecode(Hash(password, "SHA1"), "Hex"))
#
#Ruby
#require 'digest/sha1'
#require 'base64'
#'{SHA}' + Base64.encode64(Digest::SHA1.digest(password))
#
#C or C++
#Use the APR function: apr_sha1_base64
#
#PostgreSQL (with the contrib/pgcrypto functions installed)
#'{SHA}'||encode(digest(password,'sha1'),'base64')



#############################
### Digest Authentication ###
#############################
#Apache recognizes one format for digest-authentication passwords - the MD5 hash of the string user:realm:password as a 32-character string of hexadecimal digits. realm is the Authorization Realm argument to the AuthName directive in httpd.conf.

### Database password fields for mod_dbd ###
#Since the MD5 function is commonly available, other software can populate a database with encrypted passwords that are usable by Apache digest authentication.
#To create Apache digest-authentication passwords in various languages:
#
#PHP
#md5($user . ':' . $realm . ':' .$password)
#
#Java
#byte b[] = java.security.MessageDigest.getInstance("MD5").digest( (user + ":" + realm + ":" + password ).getBytes());
#java.math.BigInteger bi = new java.math.BigInteger(1, b);
#String s = bi.toString(16);
#while (s.length() < 32)
#s = "0" + s;
#// String s is the encrypted password
#
#ColdFusion
#LCase(Hash( (user & ":" & realm & ":" & password) , "MD5"))
#
#Ruby
#require 'digest/md5'
#Digest::MD5.hexdigest(user + ':' + realm + ':' + password)
#
#PostgreSQL (with the contrib/pgcrypto functions installed)
#encode(digest( user || ':' || realm || ':' || password , 'md5'), 'hex')
