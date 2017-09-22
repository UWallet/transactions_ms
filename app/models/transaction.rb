class Transaction < ApplicationRecord
  def self.transactions_by_id(id)
    find_by_id(id)
  end
end
