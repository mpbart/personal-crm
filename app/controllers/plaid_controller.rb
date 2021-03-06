require 'finance_manager/interface'

class PlaidController < ActionController::Base
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  TOKEN_REGEX = /\w+-\w+-\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/

  # Add accounts from new financial institution for user
  def get_access_token
    params.permit(:public_token)
    public_token = params[:public_token]
    return unless valid_public_token?(public_token)

    response = finance_manager.plaid_client.item.public_token.exchange(public_token)
    PlaidCredential.create!(plaid_item_id:    response['item_id'],
                            access_token:     response['access_token'],
                            institution_name: params.dig('metadata', 'institution', 'name'),
                            institution_id:   params.dig('metadata', 'institution', 'institution_id'),
                            user:             current_user)
    render json: {success: true}
  end

  def refresh_accounts
    finance_manager.refresh_accounts
    finance_manager.refresh_transactions

    render json: {status: 'complete'}
  end

  def create_link_token
    token = finance_manager.plaid_client.link_token.create(
      user: {
        client_user_id: current_user.id.to_s
      },
      client_name: 'personal-dash',
      language: 'en',
      country_codes: ['US'],
      products: ['transactions']
    )

    render json: {link_token: token[:link_token]}
  end

  private

  def finance_manager
    @finance_manager ||= FinanceManager::Interface.new(current_user)
  end

  def valid_public_token?(token)
    TOKEN_REGEX =~ token
  end

end
