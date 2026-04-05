module OmiseService
  class UpdateRecipient
    def initialize(store:)
      @store = store
    end

    def call
      OmiseService::CreateRecipient.new(store: @store).call if @store.omise_recipient_id.blank?

      Omise.api_key = ENV.fetch("OMISE_SECRET_KEY")

      recipient = Omise::Recipient.retrieve(@store.omise_recipient_id)
      recipient.update(
        name: @store.name,
        email: @store.owner.email,
        bank_account: {
          brand: @store.bank_code,
          number: @store.bank_number,
          name: @store.bank_name
        }
      )

      @store.update!(omise_recipient_id: recipient.id)

      recipient
    end
  end
end
