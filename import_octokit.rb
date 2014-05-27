#encoding:UTF-8
#!/usr/bin/env ruby
require 'OctoKit'
require 'yaml'
require 'CSV'

LOGIN = YAML.load_file('login.yaml')

client = Octokit::Client.new \
	:login => LOGIN['USERNAME'],
	:password => LOGIN['PASSWORD']

user = client.user
user.login

repo = 'antislice/HelloRubyTuesdays'

CSV.foreach 'hrt_issues.csv', headers: true do |row|
	labels = row['Labels'].split(',')
	labels << row['Story Type']
	client.create_issue(repo, row['Story'], row['Description'], {:labels => labels.join(',')})
end


#issue = client.create_issue("antislice/HelloRubyTuesdays", 'test API issue', 'test issue body', {:labels => "bug"})
#puts issue.title