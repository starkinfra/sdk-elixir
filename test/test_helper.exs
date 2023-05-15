# remove excluded tags to run specific module tests
ExUnit.start(
  exclude: [
    # :brcode_preview,
    # :card_method,
    # :credit_holmes,
    # :credit_holmes_log,
    # :credit_note,
    # :credit_note_log,
    # :credit_preview,
    # :dynamic_brcode,
    # :static_brcode,
    # :event,
    # :merchant_category,
    # :merchant_country,
    # :pix_key,
    # :pix_key_log,
    :pix_director,
    :pix_statement,
    # :pix_balance,
    # :pix_request,
    # :pix_request_log,
    # :pix_reversal,
    # :pix_reversal_log,
    # :pix_claim,
    # :pix_claim_log,
    # :pix_chargeback,
    # :pix_chargeback_log,
    # :pix_infraction,
    # :pix_infraction_log,
    # :pix_domain,
    # :individual_identity,
    # :individual_identity_log,
    # :individual_document,
    # :individual_document_log,
    # :issuing_balance,
    # :issuing_card,
    # :issuing_card_log,
    # :issuing_design,
    # :issuing_embossing_request,
    # :issuing_embossing_kit,
    # :issuing_embossing_request_log,
    # :issuing_holder,
    # :issuing_holder_log,
    # :issuing_invoice,
    # :issuing_invoice_log,
    # :issuing_product,
    # :issuing_purchase,
    # :issuing_purchase_log,
    :issuing_restock,
    :issuing_restock_log,
    :issuing_stock,
    :issuing_stock_log,
    # :issuing_transaction,
    # :issuing_transaction_log,
    # :issuing_withdrawal,
    # :issuing_withdrawal_log,
    # :webhook
  ]
)

Code.require_file("./test/utils/page.exs")
Code.require_file("./test/utils/end_to_end_id.exs")
Code.require_file("./test/utils/pix_reversal.exs")
Code.require_file("./test/utils/random.exs")
Code.require_file("./test/utils/issuing_holder.exs")
Code.require_file("./test/utils/issuing_withdrawal.exs")
Code.require_file("./test/utils/issuing_invoice.exs")
