defmodule StarkInfra.CreditPreview do
  alias __MODULE__, as: CreditPreview
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.API
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error
  alias StarkInfra.CreditPreview.CreditNotePreview

  @moduledoc """
  Groups CreditPreview related functions
  """

  @doc """
  A CreditPreview is used to get information from a credit before taking it.
  This struct can be used to preview credit notes.
  When you initialize a CreditPreview, the entity will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the list of created structs.

  ## Parameters (required):
    - `:credit` [CreditNotePreview struct or map]: Information preview of the informed credit.
    - `:type` [string]: Credit type. ex: "credit-note"
  """
  @enforce_keys [
    :credit,
    :type
  ]
  defstruct [
    :credit,
    :type
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of CreditPreview structs for processing in the Stark Infra API

  ## Parameters (required):
    - `:previews` [list of CreditPreview structs]: list of CreditPreview structs to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CreditPreview structs with updated attributes
  """
  @spec create(
    [CreditPreview.t() | map],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [CreditPreview.t()]} |
    {:error, [Error.t()]}
  def create(previews, options \\ []) do
    Rest.post(
      resource(),
      previews,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    [CreditPreview.t() | map],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(previews, options \\ []) do
    Rest.post!(
      resource(),
      previews,
      options
    )
  end

  defp parse_credit!(credit, type) do
    case type do
      "credit-note" -> API.from_api_json(credit, &CreditNotePreview.resource_maker/1)
      _ -> credit
    end
  end

  @doc false
  def resource() do
    {
      "CreditPreview",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CreditPreview{
      credit: parse_credit!(json[:credit], json[:type]),
      type: json[:type]
    }
  end
end
