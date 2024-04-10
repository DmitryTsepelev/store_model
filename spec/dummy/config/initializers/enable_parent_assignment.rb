if ENV.key?("ENABLE_PARAM_ASSIGNMENT")
  enable_parent_assignment = case ENV.fetch("ENABLE_PARAM_ASSIGNMENT")
  when "true"
    true
  when "false"
    false
  else
    raise "Wrong ENV['ENABLE_PARAM_ASSIGNMENT'] value: #{ENV.fetch("ENABLE_PARAM_ASSIGNMENT")}"
  end
  StoreModel.config.enable_parent_assignment = enable_parent_assignment
end
ENABLE_PARAM_ASSIGNMENT = StoreModel.config.enable_parent_assignment
