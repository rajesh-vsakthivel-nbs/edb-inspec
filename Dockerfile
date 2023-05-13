FROM chef/inspec:latest

RUN mkdir -p /etc/chef/accepted_licenses
COPY inspec-accepted-license /etc/chef/accepted_licenses/inspec