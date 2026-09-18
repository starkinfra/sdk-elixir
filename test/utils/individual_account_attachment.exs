defmodule StarkInfraTest.Utils.IndividualAccountAttachment do
  use ExUnit.Case

  alias StarkInfra.IndividualAccountAttachment

  # minimal valid 1x1 black PNG, used only so a real image is base64-encoded
  # into the create payload; no external fixture files exist in this repo.
  @tiny_png Base.decode64!(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
  )

  def generate_example_individual_account_attachment(account_request_id) do
    %IndividualAccountAttachment{
      type: "identity-front",
      content: @tiny_png,
      content_type: "image/png",
      account_request_id: account_request_id,
      tags: ["test", "testing"]
    }
  end
end
