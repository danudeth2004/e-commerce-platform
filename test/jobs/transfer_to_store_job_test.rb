# frozen_string_literal: true

require "test_helper"

class TransferToStoreJobTest < ActiveJob::TestCase
  setup do
    OmiseTestStubs.transfer_create_returns_nil = false
    OmiseTestStubs.transfer_sent = true
  end

  test "processes pending payout" do
    user = create_user!
    order = Order.create!(user: user, status: :paid)
    store = create_store!
    store.update!(omise_recipient_id: "recp_x")
    payout = OrderStorePayout.create!(order: order, store: store, amount_cents: 500, status: :pending)

    TransferToStoreJob.perform_now(payout.id)

    assert payout.reload.processing?
    assert payout.transfer_id.present?
  end

  test "no-op when order not paid" do
    user = create_user!
    order = Order.create!(user: user, status: :pending)
    store = create_store!
    store.update!(omise_recipient_id: "recp_x")
    payout = OrderStorePayout.create!(order: order, store: store, amount_cents: 500, status: :pending)

    TransferToStoreJob.perform_now(payout.id)

    assert payout.reload.pending?
  end

  test "marks failed when transfer returns nil" do
    OmiseTestStubs.transfer_create_returns_nil = true
    user = create_user!
    order = Order.create!(user: user, status: :paid)
    store = create_store!
    store.update!(omise_recipient_id: "recp_x")
    payout = OrderStorePayout.create!(order: order, store: store, amount_cents: 500, status: :pending)

    TransferToStoreJob.perform_now(payout.id)

    assert payout.reload.failed?
  end
end
