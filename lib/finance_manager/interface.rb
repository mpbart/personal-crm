require 'plaid'
require 'config_reader'
require_relative 'account'
require_relative 'transaction'

module FinanceManager
  class Interface
    DATE_FORMAT = '%Y-%m-%d'.freeze
    
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def plaid_client
      @plaid_client ||= begin
        config = ConfigReader.for('plaid')
        env = config['environment'].fetch(ENV['RAILS_ENV']) { raise StandardError, "No mapping found for environment #{ENV['RAILS_ENV']}" }
        Plaid::Client.new(env:        env,
                          client_id:  config['client_id'],
                          secret:     config['secret'])
      end
    end

    def refresh_accounts
      user.plaid_credentials.each do |credential|
        response = plaid_client.accounts.get(credential.access_token)
        PlaidResponse.record_accounts_response!(response, credential)

        next unless response[:accounts]&.any?

        response[:accounts].each do |account_hash|
          FinanceManager::Account.handle(account_hash, credential)
        end
      end
    end

    def refresh_transactions
      user.plaid_credentials.each do |credential|
        response = plaid_client.transactions.get(credential.access_token,
                                                 transactions_refresh_start_date(credential),
                                                 transactions_refresh_end_date)
        PlaidResponse.record_transactions_response!(response, credential)

        next unless response[:transactions]&.any?

        response[:transactions].each do |transaction|
          FinanceManager::Transaction.handle(transaction)
        end
      end
    end

    def split_transaction!(transaction_id, new_transaction_details)
      begin
        return unless transaction = ::Transaction.find(transaction_id)
        FinanceManager::Transaction.split!(
          transaction,
          new_transaction_details
        )
      rescue => e
        Rails.logger.error("Error splitting transaction: #{e}")
        false
      end
    end

    def edit_transaction!(transaction_id, new_transaction_details)
      begin
        return unless transaction = ::Transaction.find(transaction_id)
        Financemanager::Transaction.edit!(transaction, new_transaction_details)
        true
      rescue => e
        Rails.logger.error("Error editing transaction: #{e}")
        false
      end
    end

    private

    # Using a lookback window of 10 days since the last refresh so that
    # pending transactions will (hopefully) post by then
    def transactions_refresh_start_date(plaid_cred)
      ((plaid_cred.user.transactions.order(:updated_at).last&.created_at || Date.current) - 10.days).strftime(DATE_FORMAT)
    end

    def transactions_refresh_end_date
      Date.today.strftime(DATE_FORMAT)
    end

  end
end
