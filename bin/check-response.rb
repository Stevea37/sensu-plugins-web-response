#! /usr/bin/env ruby
#
#   check-response
#
# DESCRIPTION:
#   This plugin checks that a web page returns a running state with status 200 OK
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rest-client
#
# USAGE:
#   #YELLOW
#
# NOTES:
#
# LICENSE:
#   Copyright 2015, Steven Ayers sayers@equalexperts.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'rest-client'

#
# Web Status Checker
#
class WebStatusChecker < Sensu::Plugin::Check::CLI


  option :url,
         description: 'URL for Web root page',
         short: '-u',
         long: '--url'

  option :name,
         description: 'Service name',
         short: '-n',
         long: '--name'

  def run
    https ||= config[:https] ? 'https' : 'http'
    testurl = "#{https}://#{config[:url]}"
    r = RestClient::Resource.new(testurl, timeout: 5).get
    if r.code == 200
      ok "#{config[:name]} Service is up"
    else
      critical "#{config[:name]} Service is not responding"
    end
  rescue Errno::ECONNREFUSED
    critical "#{config[:name]} Service is not responding"
  rescue RestClient::RequestTimeout
    critical "#{config[:name]} Service Connection timed out"
  rescue
    critical "Couldn't get: '#{config[:url]}' is the server option set correctly?"
  end
end