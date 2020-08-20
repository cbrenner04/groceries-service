SecureHeaders::Configuration.default do |config|
  config.csp = { default_src: ["'none'"], script_src: ["'none'"] }
end
