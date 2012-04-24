Gem::Specification.new do |s|
  s.name 	= 'ruby-splunk'
  s.version	= '0.0.4'
  s.date	= '2012-04-24'
  s.summary	= 'Splunk API Library'
  s.description = 'Splunk API Library for Ruby'
  s.authors 	= ["Andrew Beresford"]
  s.email	= 'beezly@beez.ly'
  s.files	= ["lib/splunk.rb"]
  s.homepage 	= 'http://github.com/beezly/ruby-splunk'
  s.add_dependency 'nokogiri', '>= 1.5.2'
  s.add_dependency 'nori', '>= 1.1.0'
end
