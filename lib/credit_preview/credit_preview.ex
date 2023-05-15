defmodule StarkInfra.CreditPreview do
  alias __MODULE__, as: CreditPreview
  alias StarkInfra.Error
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.API
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.CreditNote.Transfer

  @moduledoc """
  Groups CreditPreview related functions
  """

  @doc """
  A CreditPreview is used to get information from a credit before taking it.
  This resource can be used to preview CreditNotes

  ## Parameters (required):
    - `:credit` [CreditNotePreview object or map]: Information preview of the informed credit.
    - `:type` [binary]: Credit type. ex: "credit-note"
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
  Send a list of CreditPreview objects for processing in the Stark Infra API

  ## Parameters (required):
    - `:previews` [list of CreditPreview objects]: list of CreditPreview objects to be created in the API

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CreditPreview objects with updated attributes
  """
  @spec create(
    [CreditPreview.t() | map()],
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
    [CreditPreview.t() | map()],
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
      "credit" -> API.from_api_json(credit, &Transfer.resource_maker/1)
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
