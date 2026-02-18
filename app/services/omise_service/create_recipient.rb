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
        email: @store.seller_user.email,
        bank_account: {
          brand: "bbl",
          number: "1234567890",
          name: @store.name
        }
      )

      @store.update!(
        omise_recipient_id: recipient.id
      )

      recipient
    end
  end
end
