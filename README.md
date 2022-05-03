# Stark Infra Elixir SDK Beta

Welcome to the Stark Infra Elixir SDK! This tool is made for Elixir
developers who want to easily integrate with our API.
This SDK version is compatible with the Stark Infra API v2.

# Introduction

# Index

- [Introduction](#introduction)
    - [Supported Elixir versions](#supported-elixir-versions)
    - [API documentation](#stark-bank-api-documentation)
    - [Versioning](#versioning)
- [Setup](#setup)
    - [Install our SDK](#1-install-our-sdk)
    - [Create your Private and Public Keys](#2-create-your-private-and-public-keys)
    - [Register your user credentials](#3-register-your-user-credentials)
    - [Setting up the user](#4-setting-up-the-user)
    - [Setting up the error language](#5-setting-up-the-error-language)
    - [Resource listing and manual pagination](#6-resource-listing-and-manual-pagination)
- [Testing in Sandbox](#testing-in-sandbox) 
- [Usage](#usage)
    - [CreditNote](#create-creditnotes): Create credit notes
- [Handling errors](#handling-errors)
- [Help and Feedback](#help-and-feedback)

# Supported Elixir Versions

This library supports Elixir versions 1.9+.

# Stark Bank API documentation

Feel free to take a look at our [API docs](https://www.starkbank.com/docs/api).

# Versioning

This project adheres to the following versioning pattern:

Given a version number MAJOR.MINOR.PATCH, increment:

- MAJOR version when the **API** version is incremented. This may include backwards incompatible changes;
- MINOR version when **breaking changes** are introduced OR **new functionalities** are added in a backwards compatible manner;
- PATCH version when backwards compatible bug **fixes** are implemented.

# Setup

## 1. Install our SDK

To install the package with mix, add this to your deps and run `mix deps.get`:

```elixir
def deps do
  [
    {:starkinfra, "~> 0.0.1"}
  ]
end
```

## 2. Create your Private and Public Keys

We use ECDSA. That means you need to generate a secp256k1 private
key to sign your requests to our API, and register your public key
with us so we can validate those requests.

You can use one of following methods:

2.1. Check out the options in our [tutorial](https://starkbank.com/faq/how-to-create-ecdsa-keys).

2.2. Use our SDK:

```elixir
{private_key, public_key} = StarkInfra.Key.create()

# or, to also save .pem files in a specific path
{private_key, public_key} = StarkInfra.Key.create("file/keys/")
```

**Note**: When you are creating a new Project, it is recommended that you create the
keys inside the infrastructure that will use it, in order to avoid risky internet
transmissions of your **private-key**. Then you can export the **public-key** alone to the
computer where it will be used in the new Project creation.

## 3. Register your user credentials

You can interact directly with our API using two types of users: Projects and Organizations.

- **Projects** are workspace-specific users, that is, they are bound to the workspaces they are created in.
One workspace can have multiple Projects.
- **Organizations** are general users that control your entire organization.
They can control all your Workspaces and even create new ones. The Organization is bound to your company's tax ID only.
Since this user is unique in your entire organization, only one credential can be linked to it.

3.1. To create a Project in Sandbox:

3.1.1. Log into [StarkInfra Sandbox](https://web.sandbox.starkinfra.com)

3.1.2. Go to Menu > Integrations

3.1.3. Click on the "New Project" button

3.1.4. Create a Project: Give it a name and upload the public key you created in section 2

3.1.5. After creating the Project, get its Project ID

3.1.6. Use the Project ID and private key to create the object below:

```elixir
# Get your private key from an environment variable or an encrypted database.
# This is only an example of a private key content. You should use your own key.
private_key_content = "
-----BEGIN EC PARAMETERS-----
BgUrgQQACg==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIMCwW74H6egQkTiz87WDvLNm7fK/cA+ctA2vg/bbHx3woAcGBSuBBAAK
oUQDQgAE0iaeEHEgr3oTbCfh8U2L+r7zoaeOX964xaAnND5jATGpD/tHec6Oe9U1
IF16ZoTVt1FzZ8WkYQ3XomRD4HS13A==
-----END EC PRIVATE KEY-----
"

project = StarkInfra.project(
    id: "5671398416568321",
    environment: :sandbox,
    private_key: private_key_content
)
```

3.2. To create Organization credentials in Sandbox:

3.2.1. Log into [Starkinfra Sandbox](https://web.sandbox.starkinfra.com)

3.2.2. Go to Menu > Integrations

3.2.3. Click on the "Organization public key" button

3.2.4. Upload the public key you created in section 2 (only a legal representative of the organization can upload the public key)

3.2.5. Click on your profile picture and then on the "Organization" menu to get the Organization ID

3.2.6. Use the Organization ID and private key to create the object below:

```elixir
# Get your private key from an environment variable or an encrypted database.
# This is only an example of a private key content. You should use your own key.
private_key_content = """
-----BEGIN EC PARAMETERS-----
BgUrgQQACg==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIMCwW74H6egQkTiz87WDvLNm7fK/cA+ctA2vg/bbHx3woAcGBSuBBAAK
oUQDQgAE0iaeEHEgr3oTbCfh8U2L+r7zoaeOX964xaAnND5jATGpD/tHec6Oe9U1
IF16ZoTVt1FzZ8WkYQ3XomRD4HS13A==
-----END EC PRIVATE KEY-----
"""

organization = StarkInfra.Organization(
    environment: "sandbox",
    id: "5656565656565656",
    private_key: private_key_content,
    workspace_id: nil,  # You only need to set the workspace_id when you are operating a specific workspace_id
)
```

NOTE 1: Never hard-code your private key. Get it from an environment variable or an encrypted database.

NOTE 2: We support `'sandbox'` and `'production'` as environments.

NOTE 3: The credentials you registered in `sandbox` do not exist in `production` and vice versa.

## 4. Setting up the user

There are three kinds of users that can access our API: **Organization**, **Project** and **Member**.

- `Project` and `Organization` are designed for integrations and are the ones meant for our SDKs.
- `Member` is the one you use when you log into our webpage with your e-mail.

There are two ways to inform the user to the SDK:
 
4.1 Passing the user as argument in all functions using the `user` keyword:

```elixir
balance = StarkInfra.Balance.get!(user: project)  # or organization
```

4.2 Set it as a default user in the `config/config.exs` file:

```elixir
import Config

config :starkinfra,
  project: [
    environment: :sandbox,
    id: "9999999999999999",
    private_key: private_key_content
  ]
```

or

```elixir
import Config

config :starkinfra,
  organization: [
    environment: :sandbox,
    id: "9999999999999999",
    private_key: private_key_content,
    workspace_id: "8888888888888888" # or nil
  ]
```

Just select the way of passing the user that is more convenient to you.
On all following examples we will assume a default user has been set in the configs.


## 5. Setting up the error language

The error language can also be set in the `config/config.exs` file:

```elixir
import Config

config :starkinfra,
  language: "en-US"
```

Language options are "en-US" for english and "pt-BR" for brazilian portuguese. English is default

## 6. Resource listing and manual pagination

Almost all SDK resources provide a `query` and a `page` function.

- The `query` function provides a straight forward way to efficiently iterate through all results that match the filters you inform,
seamlessly retrieving the next batch of elements from the API only when you reach the end of the current batch.
If you are not worried about data volume or processing time, this is the way to go.

```elixir
notes = StarkInfra.CreditNote.query!(
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1)
) |> Enum.take(10) |> IO.inspect
```

- The `page` function gives you full control over the API pagination. With each function call, you receive up to
100 results and the cursor to retrieve the next batch of elements. This allows you to stop your queries and
pick up from where you left off whenever it is convenient. When there are no more elements to be retrieved, the returned cursor will be `nil`.

```elixir
defmodule CursorRecursion do
  def get!(iterations \\ 1, cursor \\ nil)  

  def get!(iterations, cursor) when iterations > 0 do
    {new_cursor, new_entities} = StarkInfra.CreditNote.page!(cursor: cursor)
    new_entities ++ get!(
      iterations - 1,
      new_cursor
    )
  end

  def get!(iterations, _cursor) do
    []
  end
end

transactions = CursorRecursion.get!(3) |> IO.inspect
```

To simplify the following SDK examples, we will only use the `query` function, but feel free to use `page` instead.

# Testing in Sandbox

Your initial balance is zero. For many operations in Stark Bank, you'll need funds
in your account, which can be added to your balance by creating an Invoice or a Boleto. 

In the Sandbox environment, most of the created Invoices and Boletos will be automatically paid,
so there's nothing else you need to do to add funds to your account. Just create
a few Invoices and wait around a bit.

In Production, you (or one of your clients) will need to actually pay this Invoice or Boleto
for the value to be credited to your account.


# Usage

Here are a few examples on how to use the SDK.

## Credit Note

### Create CreditNote

You can create a Credit Note to generate a CCB contract:

```elixir
  creditnote = StarkInfra.CreditNote.create([
    %StarkInfra.CreditNote{
      template_id: "5686220801703936",
      name: "Jamie Lannister",
      tax_id: "012.345.678-90",
      nominal_amount: 100000,
      scheduled: "2022-04-28",
      invoices: [
          %{
              due: "2023-06-25",
              amount: 120000,
              fine: 10,
              interest: 2
          }
      ],
      tags: ["test", "testing"],
      transfer: %{
          bankCode: "00000000",
          branchCode: "1234",
          accountNumber: "129340-1",
          name: "Jamie Lannister",
          taxId: "012.345.678-90"
      },
      signers: [
          %{
              name: "Jamie Lannister",
              contact: "jamie.lannister@gmail.com",
              method: "link"
          }
      ],
    }
  ]) |> IO.inspect
```

**Note**: Instead of using CreditNote structs, you can also pass each CreditNote element in map format

### Query CreditNotes

You can query multiple credit notes according to filters.

```elixir
credit_note = StarkInfra.CreditNote.query!(
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1)
) |> Enum.take(10) |> IO.inspect
```

### Get a CreditNote

After its creation, information on a credit note may be retrieved by its id.

```elixir
transaction = StarkInfra.CreditNote.get("5155165527080960")
  |> IO.inspect
```

## Cancel a CreditNote

You can cancel a credit note if it has not been signed yet.

```elixir
note = StarkInfra.CreditNote.delete("5155165527080960")
  |> IO.inspect
```
  
### Query CreditNote logs

You can query credit note logs to better understand credit note life cycles. 

```elixir
logs = StarkInfra.CreditNote.Log.query!(
  limit: 10,
  after: "2020-11-01",
  before: "2020-11-02"
)
|> Enum.take(10)
|> IO.inspect
```

### Get a CreditNote log

You can also get a specific log by its id.

```elixir
log = StarkInfra.CreditNote.log.get("5155165527080960")
|> IO.inspect
```

Here are a few examples on how to use the SDK. If you have any doubts, use the built-in
`h()` function to get more info on the desired functionality
(for example: `StarkInfra.CreditNote |> h`)

**Note**: Almost all SDK functions also provide a bang (!) version. To simplify the examples, they will be used the most throughout this README.



# Handling errors

The SDK may raise or return errors as the StarkInfra.Error struct, which contains the "code" and "message" attributes.

If you use bang functions, the list of errors will be converted into a string and raised.
If you use normal functions, the list of error structs will be returned so you can better analyse them.

# Help and Feedback

If you have any questions about our SDK, just send us an email.
We will respond you quickly, pinky promise. We are here to help you integrate with us ASAP.
We also love feedback, so don't be shy about sharing your thoughts with us.

Email: developers@starkinfra.com
