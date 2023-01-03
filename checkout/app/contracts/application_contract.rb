# frozen_string_literal: true

# Base Contract with encapsulated validate! method
class ApplicationContract < Dry::Validation::Contract
  def self.validate!(data)
    result = new.call(data)

    raise ApiErrors::ValidationError, result.errors.to_h unless result.success?

    result.to_h
  end
end
