class SplitTransaction < ApplicationRecord
  belongs_to :parent_transaction, class_name: 'Transaction', primary_key: :id, foreign_key: :transaction_id

  def self.initialize_from_original_transaction(transaction)
    split = new
    split.date = transaction.date
    split.description = transaction.description
    split
  end
end
