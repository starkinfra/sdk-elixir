defmodule StarkInfra.PixDomain.Certificate do
  alias __MODULE__, as: Certificate

  @moduledoc """
  Groups pixdomain.Certificate related functions
  """

  @doc """
  The Certificate object displays the certificate information from a specific domain.

  ## Attributes (return-only):
    - content [binary]: certificate of the Pix participant in PEM format.
  """
  defstruct [
    :content
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %Certificate{
      content: json[:content]
    }
  end
end
