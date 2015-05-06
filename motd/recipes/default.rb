#
# Cookbook Name:: motd
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

file '/etc/motd' do
  content "hellooooooooooo docker seminar"
  mode "0644"
  action :create
end
