defmodule StarkInfra.Utils.Parse do
  alias EllipticCurve.Signature
  alias EllipticCurve.PublicKey
  alias EllipticCurve.Ecdsa
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.JSON
  alias StarkInfra.Utils.API
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error
  alias StarkInfra.Utils.Request
  @moduledoc false

  @doc """
  Create a single Event struct received from event listening at subscribed user endpoint.
  If the provided digital signature does not check out with the StarkInfra public key, an "invalidSignature"
  error will be returned.

  ## Parameters (required):
    - `content` [string]: response content from request received at user endpoint (not parsed)
    - `signature` [string]: base-64 digital signature received at response header "Digital-Signature"

  ## Options:
    - `cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Event struct with updated attributes
    - Cache PID that holds the Stark Infra public key in order to avoid unnecessary requests to the API on future parses
  """
  @spec parse_and_verify(
    content: binary,
    signature: binary,
    cache_pid: PID,
    resource_maker: any,
    user: Project.t() | Organization.t()
  ) ::
    {:ok, {Event.t(), binary}} | {:error, [Error.t()]}
  def parse_and_verify(parameters \\ []) do
    parameters =
    Enum.into(
      parameters |> Check.enforced_keys([:content, :signature]),
      %{cache_pid: nil, user: nil}
    )
    parse(parameters.user, parameters.content, parameters.signature, parameters.cache_pid, parameters.resource_maker, parameters.key, 0)
  end

  @doc """
  Same as parse(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse_and_verify!(
    content: binary,
    signature: binary,
    cache_pid: PID,
    resource_maker: any,
    key: binary,
    user: Project.t() | Organization.t()
  ) :: {Event.t(), any}
  def parse_and_verify!(parameters \\ []) do
    case parse_and_verify(parameters) do
      {:ok, {event, cache_pid_}} -> {event, cache_pid_}
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  defp parse(user, content, signature, cache_pid, resource_maker, key, counter) when is_nil(cache_pid) do
    {:ok, new_cache_pid} = Agent.start_link(fn -> %{} end)
    parse(user, content, signature, new_cache_pid, resource_maker, key, counter)
  end

  defp parse(user, content, signature, cache_pid, resource_maker, key, counter) do
    case verify_signature(user, content, signature, cache_pid, counter) do
      {:ok, true} ->
        {:ok, {content |> parse_content(resource_maker, key), cache_pid}}

      {:ok, false} ->
        parse(user, content, signature, cache_pid |> update_public_key(nil), resource_maker, key, counter + 1)

      {:error, errors} -> {:error, errors}
    end
  end

  defp parse_content(content, resource_maker, key) when is_nil(key) do
    API.from_api_json(
      JSON.decode!(content),
      resource_maker
    )
  end

  defp parse_content(content, resource_maker, key) do
    API.from_api_json(
      JSON.decode!(content)[key],
      resource_maker
    )
  end

  defp verify_signature(_user, _content, _signature_base_64, _cache_pid, counter)
      when counter > 1 do
    {
    :error,
      [
        %Error{
          code: "invalidSignature",
          message: "The provided signature and content do not match the Stark Infra public key"
        }
      ]
    }
  end

  defp verify_signature(user, content, signature_base_64, cache_pid, counter)
      when is_binary(signature_base_64) and counter <= 1 do
    try do
      signature_base_64 |> Signature.fromBase64!()
    rescue
      _error -> {
        :error,
        [
          %Error{
            code: "invalidSignature",
            message: "The provided signature is not valid"
          }
        ]
      }
    else
    signature -> verify_signature(
      user,
      content,
      signature,
      cache_pid,
      counter
    )
    end
  end

  defp verify_signature(user, content, signature, cache_pid, _counter) do
    case get_StarkInfra_public_key(user, cache_pid) do
    {:ok, public_key} ->
      {
      :ok,
      (fn p ->
        Ecdsa.verify?(
          content,
          signature,
          p |> PublicKey.fromPem!()
        )
      end).(public_key)
      }

    {:error, errors} ->
      {:error, errors}
    end
  end

  defp get_StarkInfra_public_key(user, cache_pid) do
    get_public_key(cache_pid) |> fill_public_key(user, cache_pid)
  end

  defp fill_public_key(public_key, user, cache_pid) when is_nil(public_key) do
    case Request.fetch(:get, "public-key", query: %{limit: 1}, user: user) do
      {:ok, response} -> {:ok, response |> extract_public_key(cache_pid)}
      {:error, errors} -> {:error, errors}
    end
  end

  defp fill_public_key(public_key, _user, _cache_pid) do
    {:ok, public_key}
  end

  defp extract_public_key(response, cache_pid) do
    public_key =
    JSON.decode!(response)["publicKeys"]
    |> hd
    |> (fn x -> x["content"] end).()

    update_public_key(cache_pid, public_key)

    public_key
  end

  defp get_public_key(cache_pid) do
    Agent.get(cache_pid, fn map -> Map.get(map, :StarkInfra_public_key) end)
  end

  defp update_public_key(cache_pid, public_key) do
    Agent.update(cache_pid, fn map -> Map.put(map, :StarkInfra_public_key, public_key) end)
    cache_pid
  end
end
