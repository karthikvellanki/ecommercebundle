Capybara.javascript_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {js_errors: false, phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes'],})
  #Capybara::Poltergeist::Driver.new(app, {js_errors: false, phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes','--proxy=54.200.60.239:8888'],})
end
Capybara.default_driver = :poltergeist

