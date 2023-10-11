defmodule StarkInfra.PixDomain do
  alias __MODULE__, as: PixDomain
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error
  alias StarkInfra.PixDomain.Certificate

  @moduledoc """
  Groups PixDomain related functions
  """

  @doc """
  The PixDomain object displays the domain name and the QR Code domain certificate of Pix participants.
  All certificates must be registered with the Central Bank.

  ## Attributes (return-only):
    - certificates [list of PixDomain.Certificate]: certificate information of the Pix participant.
    - name [binary]: current active domain (URL) of the Pix participant.
  """
  @enforce_keys [
    :certificates,
    :name
  ]
  defstruct [
    :certificates,
    :name
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of PixDomain objects of Pix participants able to issue BR Codes

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of PixDomain objects with updated attributes
  """
  @spec query(
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, [PixDomain.t()]} |
    {:error, Error.t()}
  def query(options \\ []) do
    Rest.get_list(
      resource(),
      options
    )
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc false
  def resource() do
    {
      "PixDomain",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixDomain{
      certificates: json[:certificates] |> Enum.map(fn invoice -> API.from_api_json(invoice, &Certificate.resource_maker/1) end),
      name: json[:name]
    }
  end
end
