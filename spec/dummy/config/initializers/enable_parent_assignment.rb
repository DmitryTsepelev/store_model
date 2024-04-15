if ENV.key?("ENABLE_PARENT_ASSIGNMENT")
  enable_parent_assignment = case ENV.fetch("ENABLE_PARENT_ASSIGNMENT").strip.downcase
  when "true"
    true
  when "false"
    false
  else
    raise "Wrong ENV['ENABLE_PARENT_ASSIGNMENT'] value: #{ENV.fetch("ENABLE_PARENT_ASSIGNMENT")}"
  end
  StoreModel.config.enable_parent_assignment = enable_parent_assignment
end
ENABLE_PARENT_ASSIGNMENT = StoreModel.config.enable_parent_assignment
