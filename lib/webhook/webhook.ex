defmodule StarkInfra.Webhook do
  alias __MODULE__, as: Webhook
  alias StarkInfra.Utils.Rest
  alias StarkInfra.Utils.Check
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups Webhook related functions
  """

  @doc """
  A Webhook is used to subscribe to notification events on a user-selected endpoint.
  Currently available services for subscription are credit-note, issuing-card, issuing-invoice, issuing-purchase, pix-request.in, pix-request.out, pix-reversal.in, pix-reversal.out, pix-claim, pix-key, pix-chargeback, pix-infraction.

  ## Parameters (required):
    - `:url` [binary]: URL that will be notified when an event occurs.
    - `:subscriptions` [list of binaries]: list of any non-empty combination of the available services. ex: ["contract", "credit-note", "signer", "issuing-card", "issuing-invoice", "issuing-purchase", "pix-request.in", "pix-request.out", "pix-reversal.in", "pix-reversal.out", "pix-claim", "pix-key", "pix-chargeback", "pix-infraction"]

  ## Attributes (return-only):
    - `:id` [binary, default nil]: unique id returned when the Webhook is created. ex: "5656565656565656"
  """
  @enforce_keys [
    :url,
    :subscriptions
  ]
  defstruct [
    :id,
    :url,
    :subscriptions
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a single Webhook for creation in the Stark Infra API

  ## Parameters (required):
    - `:url` [binary]: URL to which notification events will be sent to. ex: "https://webhook.site/60e9c18e-4b5c-4369-bda1-ab5fcd8e1b29"
    - `:subscriptions` [list of binaries]: list of any non-empty combination of the available services. ex: ["contract", "credit-note", "signer", "issuing-card", "issuing-invoice", "issuing-purchase", "pix-request.in", "pix-request.out", "pix-reversal.in", "pix-reversal.out", "pix-claim", "pix-key", "pix-chargeback", "pix-infraction"]

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Webhook object with updated attributes
  """
  @spec create(
    url: binary,
    subscriptions: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, Webhook.t()} |
    {:error, [Error.t()]}
  def create(options \\ []) do
    %{user: user, url: url, subscriptions: subscriptions} =
      Enum.into(
        options |> Check.enforced_keys([:url, :subscriptions]),
        %{user: nil}
      )

    Rest.post_single(
      resource(),
      %Webhook{url: url, subscriptions: subscriptions},
      %{user: user}
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(user: Project.t() | Organization.t() | nil, url: binary, subscriptions: [binary]) :: any
  def create!(options \\ []) do
    %{user: user, url: url, subscriptions: subscriptions} =
      Enum.into(
        options |> Check.enforced_keys([:url, :subscriptions]),
        %{user: nil, url: nil, subscriptions: nil}
      )

    Rest.post_single!(
      resource(),
      %Webhook{url: url, subscriptions: subscriptions},
      %{user: user}
    )
  end

  @doc """
  Receive a single Webhook object previously created in the Stark Infra API by passing its id

  ## Parameters (required):
    - `id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Webhook object with that corresponds to the given id.
  """
  @spec get(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, Webhook.t()} |
    {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: Webhook.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of Webhook objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of Webhook objects with updated attributes
  """
  @spec query(
    limit: integer,
    user: Project.t() | Organization.t()
  ) ::
    (
      {:cont, {:ok, [Webhook.t()]}} |
      {:error, [Error.t()]} |
      {:halt, any} |
      {:suspend, any},
      any -> any
    )
  def query(options \\ []) do
    Rest.get_list(resource(), options)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    limit: integer,
    user: Project.t() | Organization.t()
  ) ::
    (
      {:cont, [Webhook.t()]} |
      {:halt, any} |
      {:suspend, any},
      any -> any
    )
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 Webhook objects previously created in the Stark Infra API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of Webhook objects with updated attributes
    - cursor to retrieve the next page of Webhook objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    user: Project.t() | Organization.t()
  ) ::
    {:ok, {binary, [Webhook.t()]}} |
    {:error, [%Error{}]}
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
    cursor: binary,
    limit: integer,
    user: Project.t() | Organization.t()
  ) :: [Webhook.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Delete a Webhook entity previously created in the Stark Infra API

  ## Parameters (required):
    - `id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - deleted Webhook object
  """
  @spec delete(
    binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, Webhook.t()} |
    {:error, [%Error{}]}
  def delete(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(
    binary,
    user: Project.t() | Organization.t() | nil
  ) :: Webhook.t()
  def delete!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  @doc false
  def resource() do
    {
      "Webhook",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Webhook{
      id: json[:id],
      url: json[:url],
      subscriptions: json[:subscriptions]
    }
  end
end
