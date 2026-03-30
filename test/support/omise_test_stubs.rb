# frozen_string_literal: true

# Stubs Omise Ruby API in test so app code in app/services/** runs without real HTTP.
require "omise"

module OmiseTestStubs
  class << self
    attr_accessor :charge_paid, :charge_raise_error, :transfer_sent, :transfer_create_returns_nil

    def apply!
      return if @applied

      @applied = true
      @charge_paid = true unless defined?(@charge_paid)
      @charge_raise_error = false
      @transfer_sent = true unless defined?(@transfer_sent)
      @transfer_create_returns_nil = false

      Omise::Charge.singleton_class.prepend(Module.new do
        def create(*)
          if OmiseTestStubs.charge_raise_error
            raise Omise::Error, "stubbed card error"
          end

          paid = OmiseTestStubs.charge_paid
          Struct.new(:paid, :id, :failure_code).new(paid, "ch_test_#{SecureRandom.hex(3)}", paid ? nil : "failed_charge")
        end
      end)

      Omise::Recipient.singleton_class.prepend(Module.new do
        def create(*)
          Struct.new(:id).new("recp_test_#{SecureRandom.hex(4)}")
        end

        def retrieve(id)
          r = Struct.new(:id).new(id)
          def r.update(*)
            self
          end

          r
        end
      end)

      Omise::Transfer.singleton_class.prepend(Module.new do
        def create(*)
          return nil if OmiseTestStubs.transfer_create_returns_nil

          Struct.new(:id).new("tr_test_#{SecureRandom.hex(4)}")
        end

        def retrieve(id)
          sent = OmiseTestStubs.transfer_sent
          Struct.new(:id, :sent).new(id, sent)
        end
      end)
    end
  end
end
