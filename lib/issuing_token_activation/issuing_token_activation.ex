defmodule StarkInfra.IssuingTokenActivation do
  alias __MODULE__, as: IssuingTokenActivation
  alias StarkInfra.Utils.Check
  alias StarkInfra.Utils.Parse
  alias StarkInfra.User.Project
  alias StarkInfra.User.Organization
  alias StarkInfra.Error

  @moduledoc """
  Groups IssuingTokenActivation related functions
  """

  @doc """
  The IssuingTokenActivation struct displays the necessary information to proceed with the card tokenization.
  You will receive this struct at your registered tokenActivationUrl to be notified of which method your
  user wants to use to receive the activation code. The POST request must be answered with no content,
  within 2 seconds, and with an HTTP status code 200. After that, you may generate the activation code
  and send it to the cardholder.

  ## Attributes (return-only):
    - `:card_id` [string]: card id which the token is bounded to. ex: "5656565656565656"
    - `:token_id` [string]: token unique id. ex: "5656565656565656"
    - `:tags` [list of strings]: tags to filter retrieved struct. ex: ["tony", "stark"]
    - `:activation_method` [map]: map with "type" and "value" string pairs.
  """
  defstruct [
    :card_id,
    :token_id,
    :tags,
    :activation_method
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Create a single IssuingTokenActivation struct from a content string received from a handler listening at
  the registered tokenActivationUrl endpoint.
  If the provided digital signature does not check out with the StarkInfra public key, a
  starkinfra.error.InvalidSignatureError will be raised.

  ## Parameters (required):
    - `:content` [string]: response content from request received at user endpoint (not parsed)
    - `:signature` [string]: base-64 digital signature received at response header "Digital-Signature"

  ## Options:
    - `:cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkInfra.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Parsed IssuingTokenActivation struct
  """
  @spec parse(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  ) ::
    {:ok, {IssuingTokenActivation.t(), binary}} |
    {:error, [Error.t()]}
  def parse(options) do
    %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        options |> Check.enforced_keys([:content, :signature]),
        %{cache_pid: nil, user: nil}
      )
    Parse.parse_and_verify(
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      key: nil,
      resource_maker: &resource_maker/1,
      user: user
    )
  end

  @doc """
  Same as parse(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  ) :: any
  def parse!(options \\ []) do
    %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        options |> Check.enforced_keys([:content, :signature]),
        %{cache_pid: nil, user: nil}
      )
    Parse.parse_and_verify!(
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      key: nil,
      resource_maker: &resource_maker/1,
      user: user
    )
  end

  @doc false
  def resource_maker(json) do
    %IssuingTokenActivation{
      card_id: json[:card_id],
      token_id: json[:token_id],
      tags: json[:tags],
      activation_method: json[:activation_method]
    }
  end
end
