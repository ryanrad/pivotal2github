#encoding:UTF-8
#!/usr/bin/env ruby
require 'OctoKit'
require 'CSV'
require 'highline/import'


# my csv didn't have any of the comments, so didn't have to handle those?

ISSUE_COLORS = ['d4c5f9','e11d21','eb6420','fbca04','009800','006b75','207de5',
				'0052cc','5319e7','f7c6c7','fad8c7','fef2c0','bfe5bf','bfdadc',
				'c7def8', 'bfd4f2']

def get_input(prompt="Enter >",show = true)
	ask(prompt) {|q| q.echo = show}
end

issues_csv = ARGV.shift or raise "Enter Filepath to CSV as ARG1"

user = get_input('Enter Username >')
password = get_input('Enter Password >', '*')

client = Octokit::Client.new \
	:login => user,
	:password => password

user = client.user
user.login

repo = get_input('Enter repo (owner/repo_name) >')

Issue = Struct.new(:title, :body, :labels, :comment)
issues = Array.new

CSV.foreach 'hrt_issues.csv', headers: true do |row|
	labels = row['Labels'].split(',')
	labels << row['Story Type']
	comment = row['Comment'].nil? ? nil : row['Comment']
	issues << Issue.new(row['Story'], row['Description'], labels, comment)
end

unique_labels = issues.map{ |i| i.labels }.flatten.map{|j| j.strip}.uniq
puts unique_labels.to_s
unique_labels.each do |l|
	begin
		client.add_label(repo, l, ISSUE_COLORS.sample)
	rescue Octokit::UnprocessableEntity => e
		puts "Unable to add #{l} as a label. Reason: #{e.errors['code']}"
	end
end

issues.each do |issue|
	puts "creating issue '#{issue.title}'"
	client.create_issue(repo, issue.title, issue.body, {:labels => issue.labels})
end

# TODO add comments