defmodule StarkInfraTest.BacenId do
  use ExUnit.Case

  alias StarkInfra.Utils.{BacenId, EndToEndId, PixSubscriptionBacenId, ReturnId}

  describe "PixSubscriptionBacenId" do
    test "is the prefix, the bank code, the UTC day and 11 random characters" do
      bacen_id = PixSubscriptionBacenId.create("32160637", "RR")

      assert String.length(bacen_id) == 29
      assert bacen_id =~ ~r/^RR32160637\d{8}[a-zA-Z0-9]{11}$/
      assert String.slice(bacen_id, 10, 8) == Calendar.strftime(DateTime.utc_now(), "%Y%m%d")
    end

    test "two ids created in a row differ" do
      refute PixSubscriptionBacenId.create("32160637", "RR") == PixSubscriptionBacenId.create("32160637", "RR")
    end
  end

  describe "BacenId" do
    test "keeps minute precision by default and accepts a date format" do
      assert String.length(BacenId.create("20018183")) == 31
      assert String.length(BacenId.create("20018183", "%Y%m%d")) == 27
    end
  end

  describe "EndToEndId and ReturnId" do
    test "keep 32 characters with minute precision" do
      end_to_end_id = EndToEndId.create("32160637")
      return_id = ReturnId.create("32160637")

      assert String.length(end_to_end_id) == 32
      assert String.length(return_id) == 32
      assert end_to_end_id =~ ~r/^E32160637\d{12}[a-zA-Z0-9]{11}$/
      assert return_id =~ ~r/^D32160637\d{12}[a-zA-Z0-9]{11}$/
    end
  end
end
