#!/usr/bin/expect

spawn "./ccoe-login-script.sh"

expect "arn:aws:iam::599972258766:role/CLNP_AWS_CL_EDBHubDev_AppCreator" { send "\n" }

expect "*Session *" { send "2\n"}

expect eof




