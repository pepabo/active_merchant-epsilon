require 'test_helper'

class EpsilonConvenienceStoreTest < MiniTest::Test
  def test_blank_parameter_generate_error
    convenience_store = ActiveMerchant::Billing::ConvenienceStore.new(code: "",
                                                                      full_name_kana: "",
                                                                      phone_number: "")
    errors = convenience_store.validate

    assert_includes errors.keys, :code
    assert_includes errors.keys, :full_name_kana
    assert_includes errors.keys, :phone_number

    assert_includes errors[:code], "is required"
    assert_includes errors[:full_name_kana], "is required"
    assert_includes errors[:phone_number], "is required"
  end

  def test_phone_number_only_accept_number
    convenience_store = ActiveMerchant::Billing::ConvenienceStore.new(code: 31,
                                                                      full_name_kana: "テスト",
                                                                      phone_number: "test")

    errors = convenience_store.validate

    assert_includes errors.keys, :phone_number
    assert_includes errors[:phone_number], "is not number"
  end
end
