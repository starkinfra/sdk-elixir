defmodule StarkInfra.PixDirector do
  alias __MODULE__, as: PixDirector
  alias StarkInfra.Utils.Rest
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups PixDirector related functions
  """

  @doc """
  The PixDomain struct displays the domain name and the QR Code domain certificate of Pix participants.
  All certificates must be registered with the Central Bank.

  # Parameters (required):
    - `:name` [string]: name of the PixDirector. ex: "Edward Stark".
    - `:tax_id` [string]: tax ID (CPF/CNPJ) of the PixDirector. ex: "03.300.300/0001-00"
    - `:phone` [string]: phone of the PixDirector. ex: "+551198989898"
    - `:email` [string]: email of the PixDirector. ex: "ned.stark@starkbank.com"
    - `:password` [string]: password of the PixDirector. ex: "12345678"
    - `:team_email` [string]: team email. ex: "aria.stark@starkbank.com"
    - `:team_phones` [list of strings]: list of phones of the team. ex: ["+5511988889999", "+5511988889998"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the PixDirector is created. ex: "5656565656565656"
    - `:status` [string]: current PixDirector status. ex: "success"
  """
  @enforce_keys [
    :name,
    :tax_id,
    :phone,
    :email,
    :password,
    :team_email,
    :team_phones
  ]
  defstruct [
    :name,
    :tax_id,
    :phone,
    :email,
    :password,
    :team_email,
    :team_phones,
    :id,
    :status
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a PixDirector struct for creation in the Stark Infra API

  ## Parameters (required):
    - `:director` [PixDirector struct]: PixDirector struct to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - PixDirector struct with updated attributes
  """
  @spec create(
    PixDirector.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixDirector.t()} |
    {:error, [error: Error.t()]}
  def create(director, options \\ []) do
    Rest.post_single(
      resource(),
      director,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    PixDirector.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(director, options \\ []) do
    Rest.post_single!(
      resource(),
      director,
      options
    )
  end

  @doc false
  def resource() do
    {
      "PixDirector",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PixDirector{
      id: json[:id],
      name: json[:name],
      tax_id: json[:tax_id],
      phone: json[:phone],
      email: json[:email],
      password: json[:password],
      team_email: json[:team_email],
      team_phones: json[:team_phones],
      status: json[:status]
    }
  end
end
