defmodule StarkInfraTest.Utils.PixInternalTransactionReport do
  use ExUnit.Case

  def generate_example_pix_internal_transaction_report() do
    bank_code = System.get_env("SANDBOX_BANK_CODE")

    %StarkInfra.PixInternalTransactionReport{
      amount: 100,
      created: DateTime.utc_now(),
      end_to_end_id: StarkInfra.Utils.EndToEndId.create(bank_code),
      method: "manual",
      reference_type: "request",
      sender_account_number: "76543",
      sender_branch_code: "1234",
      sender_account_type: "checking",
      sender_bank_code: bank_code,
      sender_tax_id: "012.345.678-90",
      receiver_account_number: "76543",
      receiver_branch_code: "1234",
      receiver_account_type: "savings",
      receiver_bank_code: bank_code,
      receiver_tax_id: "20.018.183/0001-80"
    }
  end
end
