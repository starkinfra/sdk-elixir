# remove excluded tags to run specific module tests
ExUnit.start(
  exclude: [
    # :credit_note,
    # :credit_note_log,
  ]
)

Code.require_file("./test/utils/page.exs")
