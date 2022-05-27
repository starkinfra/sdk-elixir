defmodule StarkInfra.CreditNote.Signer do
    alias __MODULE__, as: Signer

    @moduledoc """
    Groups Signer related functions
    """

    @doc """
    CreditNote signer's information.

    ## Parameters (required):
        - `:name` [string]: signer's name. ex: "Tony Stark"
        - `:contact` [string]: signer's contact information. ex: "tony@starkindustries.com"
        - `:method` [string]: delivery method for the contract. ex: "link"
    """
    @enforce_keys [
        :name,
        :contact,
        :method
    ]
    defstruct [
        :name,
        :contact,
        :method
    ]

    @type t() :: %__MODULE__{}

    @doc false
    def resource_maker(json) do
        %Signer{
            name: json[:name],
            contact: json[:contact],
            method: json[:method]
        }
    end
end
