defmodule StarkInfra.AiKnowledgeBase do
  alias __MODULE__, as: AiKnowledgeBase
  alias StarkInfra.Utils.API
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.JSON
  alias StarkInfra.Utils.Request
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups AiKnowledgeBase related functions
  """

  @doc """
  An AiKnowledgeBase turns a website into material an AiAgent can read. You give it a root URL;
  Stark Infra crawls the page, follows its links, converts everything to Markdown and indexes it for retrieval.
  When you initialize an AiKnowledgeBase, the struct will not be automatically
  created in the Stark Infra API. The 'create' function sends the structs
  to the Stark Infra API and returns the created struct.

  ## Parameters (required):
    - `:name` [binary]: name of the knowledge base. Between 1 and 100 characters. ex: "Product Documentation"
    - `:root_url` [binary]: absolute http or https URL the crawl starts from. ex: "https://docs.starkinfra.com"

  ## Parameters (optional):
    - `:is_recursive` [bool, default nil]: whether the crawl may follow links into other subdomains of the root URL's registered domain. The API defaults to true. ex: false
    - `:tags` [list of binaries, default nil]: list of up to 100 strings for reference when searching for AiKnowledgeBases. ex: ["support", "public"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the AiKnowledgeBase is created. ex: "5656565656565656"
    - `:status` [binary]: current status of the knowledge base. Options: "processing", "success", "failed". An agent retrieves from a base only once it reaches "success".
    - `:created` [DateTime]: creation datetime for the AiKnowledgeBase. ex: ~U[2020-03-10 10:30:0:0]
    - `:updated` [DateTime]: latest update datetime for the AiKnowledgeBase. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :name,
    :root_url
  ]
  defstruct [
    :name,
    :root_url,
    :is_recursive,
    :tags,
    :id,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send an AiKnowledgeBase struct for creation at the Stark Infra API and start crawling it.
  The call returns immediately with the knowledge base in "processing" status.

  ## Parameters (required):
    - `:knowledge_base` [AiKnowledgeBase struct]: AiKnowledgeBase struct to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - AiKnowledgeBase struct with updated attributes
  """
  @spec create(
    knowledge_base: AiKnowledgeBase.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiKnowledgeBase.t()} |
    {:error, [Error.t()]}
  def create(knowledge_base, options \\ []) do
    # the API answers under "knowledgeBase", not under the "base" that Rest derives from the resource name,
    # so this resource reads its responses itself
    Request.fetch(
      :post,
      path(),
      # the API answers 400 to id, status, created and updated, which a struct returned by get/query/create carries
      payload: knowledge_base |> Map.take([:name, :root_url, :is_recursive, :tags]) |> API.api_json(),
      user: options[:user]
    )
    |> single_result()
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    knowledge_base: AiKnowledgeBase.t() | map(),
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(knowledge_base, options \\ []) do
    create(knowledge_base, options) |> unwrap!()
  end

  @doc """
  Receive a single AiKnowledgeBase struct previously created in the Stark Infra API by its id.
  This is the call to poll while the crawl runs.

  ## Parameters (required):
    - `:id` [binary]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - AiKnowledgeBase struct with updated attributes
  """
  @spec get(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiKnowledgeBase.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Request.fetch(
      :get,
      "#{path()}/#{id}",
      user: options[:user]
    )
    |> single_result()
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def get!(id, options \\ []) do
    get(id, options) |> unwrap!()
  end

  @doc """
  Receive a stream of AiKnowledgeBase structs previously created in the Stark Infra API.
  This route is not paginated: it answers with every base and rejects limit and cursor, so they are not options here.

  ## Options:
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:name` [binary, default nil]: case-insensitive substring of the name to filter retrieved structs. ex: "docs"
    - `:status` [binary, default nil]: filter for status of retrieved structs. Options: "processing", "success", "failed"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of AiKnowledgeBase structs with updated attributes
  """
  @spec query(
    ids: [binary] | nil,
    name: binary | nil,
    status: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) :: Enumerable.t()
  def query(options \\ []) do
    Stream.resource(
      fn -> list_result(options) end,
      fn
        :done -> {:halt, :done}
        {:ok, knowledge_bases} -> {Enum.map(knowledge_bases, &({:ok, &1})), :done}
        {:error, errors} -> {[{:error, errors}], :done}
      end,
      fn _state -> nil end
    )
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    ids: [binary] | nil,
    name: binary | nil,
    status: binary | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    Stream.resource(
      fn -> list_result(options) end,
      fn
        :done -> {:halt, :done}
        {:ok, knowledge_bases} -> {knowledge_bases, :done}
        {:error, errors} -> raise API.errors_to_string(errors)
      end,
      fn _state -> nil end
    )
  end

  @doc """
  Rename a knowledge base, retag it or change whether its crawl is recursive. The root URL cannot be changed.

  ## Parameters (required):
    - `:id` [binary]: AiKnowledgeBase unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:name` [binary, default nil]: new name of the knowledge base. Between 1 and 100 characters.
    - `:is_recursive` [bool, default nil]: whether the next crawl may follow links into other subdomains of the root URL's registered domain.
    - `:tags` [list of binaries, default nil]: new list of up to 100 strings. Replaces the current list.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target AiKnowledgeBase with updated attributes
  """
  @spec update(
    id: binary,
    name: binary | nil,
    is_recursive: boolean | nil,
    tags: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, AiKnowledgeBase.t()} |
    {:error, [Error.t()]}
  def update(id, parameters \\ []) do
    Request.fetch(
      :patch,
      "#{path()}/#{id}",
      payload: parameters |> Map.new() |> Map.take([:name, :is_recursive, :tags]) |> API.cast_json_to_api_format(),
      user: parameters[:user]
    )
    |> single_result()
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(
    id: binary,
    name: binary | nil,
    is_recursive: boolean | nil,
    tags: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def update!(id, parameters \\ []) do
    update(id, parameters) |> unwrap!()
  end

  @doc """
  Receive every page the crawler has seen, grouped by host. While a crawl is running this is the live picture,
  merged with the last finished one.

  ## Parameters (required):
    - `:id` [binary]: AiKnowledgeBase unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - map from each host to its list of pages. Each page is a map with :original_url, :storage_url and :status ("pending", "success" or "failed")
  """
  @spec hosts(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, %{binary => [map()]}} |
    {:error, [Error.t()]}
  def hosts(id, options \\ []) do
    case Request.fetch(:get, "#{path()}/#{id}/hosts", user: options[:user]) do
      {:ok, response} -> {:ok, response |> JSON.decode!() |> Map.fetch!("hosts") |> Map.new(&host_pages/1)}
      {:error, errors} -> {:error, errors}
    end
  end

  @doc """
  Same as hosts(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec hosts!(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def hosts!(id, options \\ []) do
    hosts(id, options) |> unwrap!()
  end

  @doc """
  Delete up to 100 AiKnowledgeBases at once. Agents still referencing a deleted base simply retrieve nothing from it.

  ## Parameters (required):
    - `:ids` [list of binaries]: ids of the AiKnowledgeBases to be deleted. Up to 100 ids. ex: ["5656565656565656", "4545454545454545"]

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of deleted AiKnowledgeBase structs
  """
  @spec delete(
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [AiKnowledgeBase.t()]} |
    {:error, [Error.t()]}
  def delete(ids, options \\ []) do
    # ids travel in the query string: this route takes no body
    Request.fetch(
      :delete,
      path(),
      query: %{ids: ids},
      user: options[:user]
    )
    |> list_response()
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def delete!(ids, options \\ []) do
    delete(ids, options) |> unwrap!()
  end

  @doc false
  def resource() do
    {
      "AiKnowledgeBase",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %AiKnowledgeBase{
      name: json[:name],
      root_url: json[:root_url],
      is_recursive: json[:is_recursive],
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end

  defp path() do
    {resource_name, _resource_maker} = resource()
    API.endpoint(resource_name)
  end

  defp list_result(options) do
    Request.fetch(
      :get,
      path(),
      query: options |> Map.new() |> Map.take([:ids, :name, :status]),
      user: options[:user]
    )
    |> list_response()
  end

  defp single_result({:ok, response}) do
    {:ok, response |> JSON.decode!() |> Map.fetch!("knowledgeBase") |> build()}
  end

  defp single_result({:error, errors}) do
    {:error, errors}
  end

  defp list_response({:ok, response}) do
    {:ok, response |> JSON.decode!() |> Map.fetch!("knowledgeBases") |> Enum.map(&build/1)}
  end

  defp list_response({:error, errors}) do
    {:error, errors}
  end

  defp build(json) do
    API.from_api_json(json, &resource_maker/1)
  end

  defp host_pages({host, pages}) do
    {host, Enum.map(pages, &API.from_api_json(&1, fn fields -> Map.new(fields) end))}
  end

  defp unwrap!({:ok, result}) do
    result
  end

  defp unwrap!({:error, errors}) do
    raise API.errors_to_string(errors)
  end
end
