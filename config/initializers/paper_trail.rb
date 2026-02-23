module PaperTrail
  module Serializers
    module YAML
      def self.load(string)
        ::YAML.safe_load(
          string,
          permitted_classes: [
            ActiveSupport::TimeWithZone,
            ActiveSupport::TimeZone,
            Date,
            Time,
            Symbol,
            BigDecimal,
            Hash,
            Array
          ],
          aliases: true
        )
      end
    end
  end
end
