require 'mina/git'
require 'mina/rvm'

# we need this cause gulp sends us some strangly encoded strings in the `build` task
Encoding.default_external = Encoding::UTF_8

set :app, 'web-client'
set :group, 'ogumi'
set_default :repository, "ssh://gitlab@hansolo.naymspace.de:9003/#{group}/#{app}.git"

# currently checked out branch or develop (we need a default for CI)

def current_branch_or_develop
  current = `git symbolic-ref HEAD 2> /dev/null`.strip.gsub(%r{^refs/heads/}, '')
  current = nil if current.empty? # convert empty string to nil for later convenience
  ENV['CI_BUILD_REF_NAME'] || current || 'develop'
end
set :branch, current_branch_or_develop


task :hansolo do
  set :rvm_path, '/usr/local/rvm/scripts/rvm'
  set :deploy_to, "/home/deploy/#{group}/#{app}"
  set :domain, 'hansolo.naymspace.de'
  set :port, '36234'
  set :user, 'deploy'
end


task :environment do
  invoke 'rvm:use[2.1@wordless]'.to_sym
end

set :shared_paths, [
  '.env',
  'node_modules',
  'bower_components'
]

task :setup do
  queue! %(touch "#{deploy_to}/shared/.env")
  queue! %(mkdir -p "#{deploy_to}/shared/node_modules")
  queue! %(mkdir -p "#{deploy_to}/shared/bower_components")
end

task deploy: :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    queue! %[ npm install ]
    queue! %[ bower install ]
    queue! %[ gulp test ]
    queue! %[ gulp ]
    # queue! %[ gulp protractor ] #TODO
    invoke :'deploy:cleanup'
  end
end
