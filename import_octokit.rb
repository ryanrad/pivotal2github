#encoding:UTF-8
#!/usr/bin/env ruby
require 'OctoKit'
require 'CSV'
require 'highline/import'

# requires fiddling with the labels later, not as neat with those
# my csv didn't have any of the comments, so didn't have to handle those?

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

unique_labels = issues.map{ |i| i.labels.each{|l| l.trim} }.uniq
puts unique_labels.to_s
unique_labels.each do |l|
    color = ''
    3.times { color << "%02x" % rand(255) }
    puts l.to_s
    puts color.to_s
	#client.add_label(repo, l, color)
end

issues.each do |issue|
	puts "creating issue '#{issue.title}'"
	client.create_issue(repo, issue.title, issue.body, {:labels => issue.labels})
end

# TODO add comments