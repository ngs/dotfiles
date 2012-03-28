#!/usr/bin/ruby -w
# 
# Author:: Joshua Timberman (<joshua@housepub.org>)
# Copyright:: Copyright (c) 2009 Joshua Timberman
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rubygems'
require 'erubis'

tmproj = File.read("#{ENV['HOME']}/lib/tmproj.erb")
eruby = Erubis::Eruby.new(tmproj)
project_name = ARGV[0]
create_here = ARGV[1]

if project_name =~ %r{^/}
  project_path = project_name
  project_name = File.basename(project_name)
else
  project_path = File.join(Dir.pwd, project_name)
end

if create_here
  output_file = File.new("#{project_name}.tmproj", "w")
else
  output_file = File.new("#{ENV['HOME']}/Documents/projects/#{project_name}.tmproj", "w")
end

if File.directory?(project_path)
  output_file.puts eruby.result(binding())
  puts "#{output_file} created"
end