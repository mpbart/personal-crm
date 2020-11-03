class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :user
  has_many :split_transactions, inverse_of: :parent_transaction

  before_update :normalize_category

  scope :by_date, -> { order('date DESC') }

  private

  def normalize_category
    self.category = PlaidCategory.find_by(category_id: category_id).hierarchy
  end
end
