# PivotalTracker to Github Issues migration scripts

Rewrote the original import_issues.rb into import_octokit.rb to use github's official ruby gem. The original script wasn't working for me.

To succesfully migrate tickets from PivotalTracker to Github do:

1. Clone this repo
2. Install the gems octokit and highline
3. Import all user stories from PivotalTracker to csv file
4. For importing tickets from csv to repo, run: `ruby import_octokit.rb your-issues.csv` and follow prompts

I haven't looked at the delete_labels script yet, it could probably use some work.

Original thanks for making these scripts to @robotarmy and his gist: https://gist.github.com/2257596

Done!
