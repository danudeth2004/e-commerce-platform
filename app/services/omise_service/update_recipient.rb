module OmiseService
  class UpdateRecipient
    def initialize(store:)
      @store = store
    end

    def call
      return unless @store.omise_recipient_id.present?

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
    end
  end
end
