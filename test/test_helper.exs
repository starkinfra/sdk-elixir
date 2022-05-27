# remove excluded tags to run specific module tests
ExUnit.start(
    exclude: [
        # :credit_note,
        # :credit_note_log,
        # :event,
        # :pix_key,
        # :pix_key_log,
        # :pix_director,
        # :pix_statement,
        # :pix_balance,
        # :pix_request,
        # :pix_request_log,
        # :pix_reversal,
        # :pix_reversal_log,
        # :pix_key,
        # :pix_key_log,
        # :pix_claim,
        # :pix_claim_log,
        # :pix_chargeback,
        # :pix_chargeback_log,
        # :pix_infraction,
        # :pix_infraction_log,
        # :pix_domain
    ]
)

Code.require_file("./test/utils/page.exs")
Code.require_file("./test/utils/end_to_end_id.exs")
Code.require_file("./test/utils/pix_infraction.exs")
Code.require_file("./test/utils/pix_reversal.exs")
Code.require_file("./test/utils/pix_chargeback.exs")
Code.require_file("./test/utils/random.exs")
