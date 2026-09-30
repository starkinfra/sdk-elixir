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

  def generate_example_reversal_pix_internal_transaction_report() do
    bank_code = System.get_env("SANDBOX_BANK_CODE")
    receiver_bank_codes = ["18236120", "60701190", "20018183"]

    %StarkInfra.PixInternalTransactionReport{
      amount: Enum.random(100..1_000_000),
      created: DateTime.utc_now() |> DateTime.add(-Enum.random(86_400..172_800), :second),
      end_to_end_id: StarkInfra.Utils.EndToEndId.create(bank_code),
      return_id: StarkInfra.Utils.ReturnId.create(bank_code),
      method: "dict",
      reference_type: "reversal",
      sender_account_number: "00000-0",
      sender_branch_code: "0000",
      sender_account_type: "checking",
      sender_bank_code: bank_code,
      sender_tax_id: "012.345.678-90",
      receiver_account_number: "00000-1",
      receiver_branch_code: "0001",
      receiver_account_type: "checking",
      receiver_bank_code: Enum.random(receiver_bank_codes),
      receiver_tax_id: "012.345.678-90"
    }
  end
end
