# frozen_string_literal: true

if ENV.key?("ENABLE_PARENT_ASSIGNMENT")
  value = ENV.fetch("ENABLE_PARENT_ASSIGNMENT").strip.downcase
  enable_parent_assignment = case value
                             when "true"
                               true
                             when "false"
                               false
                             else
                               raise "Wrong ENV['ENABLE_PARENT_ASSIGNMENT'] value: #{value}"
                             end
  StoreModel.config.enable_parent_assignment = enable_parent_assignment
end
ENABLE_PARENT_ASSIGNMENT = StoreModel.config.enable_parent_assignment
