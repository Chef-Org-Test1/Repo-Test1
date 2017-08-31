#
# Cookbook:: win-iis
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
dsc_script 'Web-Server' do
    code <<-EOH
    WindowsFeature InstallWebServer
    {
        Name = "Web-Server"
        Ensure = "Present"
    }
    EOH
end

# Install ASP.NET 4.5
dsc_script 'Web-Asp-Net45' do
    code <<-EOH
    WindowsFeature InstallAspDotNet45
    {
        Name = "Web-Asp-Net45"
        Ensure = "Present"
    }
    EOH
end

# Install IIS Management Console
dsc_script 'Web-Mgmt-Console' do
    code <<-EOH
    WindowsFeature InstallIISConsole
    {
        Name = "Web-Mgmt-Console"
        Ensure = "Present"
    }
    EOH
end


# Remove IIS default web site
include_recipe 'iis::remove_default_site'

iis_site 'Default Web Site' do
    action [:stop, :delete]
end

iis_pool 'DefaultAppPool' do
    action [:stop, :delete]
end

iis_pool '.NET v4.5' do
    action [:stop, :delete]
end

iis_pool '.NET v4.5 Classic' do
    action [:stop, :delete]
end

# Create Site Directory
directory "C:\\Test\\IIS" do
    rights :read, 'IIS_IUSRS'
    recursive true
    action :create
 end

# Download pre-built site and extract package
remote_file "C:\\Test\\IIS\\itops.zip" do
  source 'file:////192.168.18.187/Share-Chef/itops.zip'
end

unless Dir.exist? "C:\\Test\\IIS\\itops"
    windows_zipfile "C:\\Test\\IIS" do
        source "C:\\Test\\IIS\\itops.zip"
        action :unzip
    end
end

#Create application pool
iis_pool 'pool_chef' do
  name 'pool_chef'
  runtime_version '4.0'
  action [:add, :recycle]
end

# Create web site
 iis_site 'chef' do
   protocol :http
   path "C:\\Test\\IIS\\itops"
   port 8080
   application_pool 'pool_chef'
   action [:add, :start]
end
