module OmiseService
  class CreateRecipient
    def initialize(store:)
      @store = store
    end

    def call
      Omise.api_key = ENV.fetch("OMISE_SECRET_KEY")

      recipient = Omise::Recipient.create(
        name: @store.name,
        type: "individual",
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
