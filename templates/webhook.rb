require 'sinatra'
require 'json'

# User customization
repo_puppetfile = "<%= @repo_puppetfile %>"
<% if @repo_hieradata -%>
repo_hierdata   = "<%= @repo_hieradata %>"
<% end -%>

post '/payload' do
  push = JSON.parse(request.body.read)
  logger.info("json payload: #{push.inspect}")

  repo_name   = push['repository']['name']
  repo_ref    = push['ref']
  ref_array   = repo_ref.split("/")
  ref_type    = ref_array[1]
  branchName  = ref_array[2]
  logger.info("repo name = #{repo_name}")
  logger.info("repo ref = #{repo_ref}")
  logger.info("branch = #{branchName}")

  # Check if repo_name is 'puppetfile'
  if #{repo_name} == #{repo_puppetfile} <% if @repo_hieradata %>|| #{repo_name} == #{repo_hieradata}<% end %>
    logger.info("Deploy r10k for this environment #{branchName}")
    deployEnv(branchName)
  else
    logger.info("Deploy puppet module #{repo_name}")
    logger.info("Running for branch #{branchName}")
    deployModule(repo_name)
  end
end

# Some defines.
def deployEnv(branchname)
  deployCmd = "/usr/bin/r10k deploy environment #{branchname} -pv"
  `#{deployCmd}`
end

def deployModule(modulename)
  deployCmd = "/usr/bin/r10k deploy module #{modulename} -v"
  `#{deployCmd}`
end
