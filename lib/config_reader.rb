require 'json'

class ConfigReader
  def self.for(client_name)
    config_file.dig(client_name)
  end

  private

  def self.config_file
    File.open(Rails.root.join('config.json'), 'r') do |file|
      JSON.parse(file)
    end
  end
end
