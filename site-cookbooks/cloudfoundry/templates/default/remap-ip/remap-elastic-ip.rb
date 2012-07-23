#!/usr/bin/env ruby

require 'rubygems'
require 'AWS'
require 'net/http'
require 'uri'

ACCESS_KEY_ID = '<%= @aws_key %>'
SECRET_ACCESS_KEY = '<%= @aws_secret_key %>'
EC2_URL = '<%= @aws_endpoint %>'
INSTANCE_HOST = '169.254.169.254'
INSTANCE_ID_URL = '/2012-01-12/meta-data/instance-id'
USER_DATA_URL = '/2012-01-12/user-data'

httpcall = Net::HTTP.new(INSTANCE_HOST)
resp, instance_id = httpcall.get2(INSTANCE_ID_URL)

httpcall = Net::HTTP.new(INSTANCE_HOST)
resp, ip_address = httpcall.get2(USER_DATA_URL)

ec2 = AWS::EC2::Base.new(
  :access_key_id => ACCESS_KEY_ID, 
  :secret_access_key => SECRET_ACCESS_KEY,
  :server => EC2_URL
)

ec2.associate_address(
  :instance_id => instance_id, 
  :public_ip => ip_address
)
