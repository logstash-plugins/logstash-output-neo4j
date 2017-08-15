Gem::Specification.new do |s|

  s.name            = 'logstash-output-neo4j'
  s.version         = '2.0.6'
  s.licenses        = ['Apache License (2.0)']
  s.summary         = "Logstash Output to Neo4j"
  s.description     = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
  s.authors         = ["Pere Urbon-Bayes"]
  s.email           = 'pere.urbon@gmail.com'
  s.homepage        = "http://purbon.com/"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir["lib/**/*","spec/**/*","*.gemspec","*.md","CONTRIBUTORS","Gemfile","LICENSE","NOTICE.TXT", "vendor/jar-dependencies/**/*.jar", "vendor/jar-dependencies/**/*.rb", "VERSION", "docs/**/*"]

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  s.add_runtime_dependency "logstash-core-plugin-api", "~> 1.0"
  s.add_runtime_dependency 'jar-dependencies'

  if RUBY_PLATFORM == 'java'
    s.platform = RUBY_PLATFORM
    s.add_runtime_dependency 'neo4j', '>= 3.0'
    s.add_runtime_dependency 'neo4j-community', '~> 2.0.0'
  end

  s.add_development_dependency 'logstash-devutils'
  s.add_development_dependency 'logstash-codec-plain'

end
