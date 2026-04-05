# frozen_string_literal: true

require "test_helper"

class OmiseServiceTest < ActiveSupport::TestCase
  setup do
    OmiseTestStubs.charge_raise_error = false
    OmiseTestStubs.charge_paid = true
    OmiseTestStubs.transfer_sent = true
    OmiseTestStubs.transfer_create_returns_nil = false
  end

  test "CreateCharge marks order paid when charge succeeds" do
    user = create_user!
    order = Order.create!(user: user, total_amount_cents: 1000, platform_fee_cents: 0)
    OmiseService::CreateCharge.new(order: order, token: "tok_test", amount: 1000).call
    assert order.reload.paid?
  end

  test "CreateCharge marks failed when charge not paid" do
    OmiseTestStubs.charge_paid = false
    user = create_user!
    order = Order.create!(user: user, total_amount_cents: 1000, platform_fee_cents: 0)
    OmiseService::CreateCharge.new(order: order, token: "tok_test", amount: 1000).call
    assert order.reload.failed?
  end

  test "CreateCharge rescues Omise::Error" do
    OmiseTestStubs.charge_raise_error = true
    user = create_user!
    order = Order.create!(user: user, total_amount_cents: 1000, platform_fee_cents: 0)
    assert_nil OmiseService::CreateCharge.new(order: order, token: "tok_test", amount: 1000).call
    assert order.reload.failed?
  end

  test "CreateRecipient stores omise_recipient_id" do
    store = create_store!
    OmiseService::CreateRecipient.new(store: store).call
    assert store.reload.omise_recipient_id.present?
  end

  test "UpdateRecipient creates recipient when missing then updates" do
    store = create_store!
    assert_nil store.omise_recipient_id
    result = OmiseService::UpdateRecipient.new(store: store).call
    assert result
    assert store.reload.omise_recipient_id.present?
  end

  test "UpdateRecipient updates when recipient exists" do
    store = create_store!
    store.update!(omise_recipient_id: "recp_existing")
    assert_nothing_raised { OmiseService::UpdateRecipient.new(store: store).call }
  end

  test "TransferToStore raises when recipient missing" do
    user = create_user!
    order = Order.create!(user: user)
    store = create_store!
    payout = OrderStorePayout.create!(order: order, store: store, amount_cents: 100)
    assert_raises(RuntimeError) { OmiseService::TransferToStore.new(payout: payout).call }
  end

  test "TransferToStore creates transfer when recipient present" do
    user = create_user!
    order = Order.create!(user: user)
    store = create_store!
    store.update!(omise_recipient_id: "recp_x")
    payout = OrderStorePayout.create!(order: order, store: store, amount_cents: 100)
    tr = OmiseService::TransferToStore.new(payout: payout).call
    assert tr
  end

  test "SyncTransferStatus returns early without transfer_id" do
    user = create_user!
    order = Order.create!(user: user)
    store = create_store!
    payout = OrderStorePayout.create!(order: order, store: store, amount_cents: 100, transfer_id: nil)
    assert_nil OmiseService::SyncTransferStatus.new(payout: payout).call
  end

  test "SyncTransferStatus updates when sent" do
    user = create_user!
    order = Order.create!(user: user)
    store = create_store!
    payout = OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 100,
      transfer_id: "tr_x",
      status: :processing
    )
    OmiseTestStubs.transfer_sent = true
    OmiseService::SyncTransferStatus.new(payout: payout).call
    assert payout.reload.transferred?
  end

  test "SyncTransferStatus does not update when not sent" do
    user = create_user!
    order = Order.create!(user: user)
    store = create_store!
    payout = OrderStorePayout.create!(
      order: order,
      store: store,
      amount_cents: 100,
      transfer_id: "tr_x",
      status: :processing
    )
    OmiseTestStubs.transfer_sent = false
    OmiseService::SyncTransferStatus.new(payout: payout).call
    assert payout.reload.processing?
  end
end
