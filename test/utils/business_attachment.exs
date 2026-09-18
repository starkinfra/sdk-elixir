defmodule StarkInfraTest.Utils.BusinessAttachment do
  def generate_example_business_attachment(business_identity_id) do
    %StarkInfra.BusinessAttachment{
      name: "articles-of-incorporation-" <> StarkInfraTest.Utils.Random.random_string(8) <> ".pdf",
      content: "data:application/pdf;base64,JVBERi0xLjQ=",
      business_identity_id: business_identity_id,
      tags: ["doc-principal"]
    }
  end
end
