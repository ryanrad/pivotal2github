#encoding:UTF-8
#!/usr/bin/env ruby
require 'OctoKit'
require 'CSV'
require 'highline/import'

# because github didn't display my random colors
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

Issue = Struct.new(:title, :body, :labels, :comments)
issues = Array.new

CSV.foreach issues_csv, headers: true do |row|
	labels = [row['Story Type']]
	labels << row['Labels'].split(',') unless row['Labels'].nil?
	# lol let's hack around the duplicate column names from pivotal tracker
	comments_col = row.index('Comment')
	has_comments = !row['Comment', comments_col].nil?
	comments = []
	while has_comments do
		comments << row['Comment', comments_col]
		comments_col += 1
		has_comments = !row['Comment', comments_col].nil?
	end
	issues << Issue.new(row['Story'], row['Description'], labels, comments)
end

unique_labels = issues.map{ |i| i.labels }.flatten.map{|j| j.to_s.strip}.uniq
puts "adding labels: #{unique_labels.to_s}"
unique_labels.each do |l|
	begin
		#client.add_label(repo, l, ISSUE_COLORS.sample)
	rescue Octokit::UnprocessableEntity => e
		puts "Unable to add #{l} as a label. Reason: #{e.errors.first[:code]}"
	end
end

issues.each do |issue|
	puts "creating issue '#{issue.title}'"
	issue_number = client.create_issue(repo, issue.title, issue.body, {:labels => issue.labels.join(',')}).number
	issue.comments.each do |comment|
		client.add_comment(repo, issue_number, comment)
	end
end
