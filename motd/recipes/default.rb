#
# Cookbook Name:: motd
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

file '/var/run/motd' do
  content "helloooooooooo"
  mode 0644
  action :create
end
