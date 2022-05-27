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
    - [Pix](#pix)
        - [PixRequests](#create-pixrequests): Create Pix transactions
        - [PixReversals](#create-pixreversals): Reverse Pix transactions
        - [PixBalance](#get-your-pixbalance): View your account balance
        - [PixStatement](#create-a-pixstatement): Request your account statement
        - [PixKey](#create-a-pixkey): Create a Pix Key
        - [PixClaim](#create-a-pixclaim): Claim a Pix Key
        - [PixDirector](#create-a-pixdirector): Create a Pix Director
        - [PixInfraction](#create-pixinfractions): Create Pix Infraction reports
        - [PixChargeback](#create-pixchargebacks): Create Pix Chargeback requests
        - [PixDomain](#query-pixdomains): View registered SPI participants certificates
    - [Credit Note](#credit-note)
        - [CreditNote](#create-creditnotes): Create credit notes
- [Handling errors](#handling-errors)
- [Help and Feedback](#help-and-feedback)

# Supported Elixir Versions

This library supports Elixir versions 1.9+.

# Stark Infra API documentation

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

3.1.6. Use the Project ID and private key to create the struct below:

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

3.2.6. Use the Organization ID and private key to create the struct below:

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
balance = StarkInfra.PixBalance.get!(user: project)  # or organization
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

Your initial balance is zero. For many operations in Stark Infra, you'll need funds
in your account, which can be added to your balance by creating an Invoice or a Boleto. 

In the Sandbox environment, most of the created Invoices and Boletos will be automatically paid,
so there's nothing else you need to do to add funds to your account. Just create
a few Invoices and wait around a bit.

In Production, you (or one of your clients) will need to actually pay this Invoice or Boleto
for the value to be credited to your account.

# Usage

Here are a few examples on how to use the SDK.

## Pix

### Create PixRequests

You can create a Pix request to transfer money from one of your users to anyone else:

```elixir
StarkInfra.PixRequest.create!([
  %StarkInfra.PixRequest{
    amount: 100,
    external_id: "141234121",
    sender_account_number: "00000-0",
    sender_branch_code: "0001",
    sender_account_type: "checking",
    sender_name: "Tyrion Lannister",
    sender_tax_id: "012.345.678-90",
    receiver_bank_code: "00000001",
    receiver_account_number: "00000-0",
    receiver_branch_code: "0001",
    receiver_account_type: "checking",
    receiver_name: "Jamie Lannister",
    receiver_tax_id: "012.345.678-90",
    end_to_end_id: StarkInfra.Utils.EndToEndId.generate("00000001") # Pass your bank code to create an end to end ID
  }
]) |> IO.inspect
```

**Note**: Instead of using PixRequest structs, you can also pass each element in dictionary format

### Query PixRequests

You can query multiple Pix requests according to filters.

```elixir
requests = StarkInfra.PixRequest.query!(
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1),
  status: ["success"],
  tags: ["iron", "suit"],
  end_to_end_ids: ["E79457883202101262140HHX553UPqeq"]
) |> Enum.take(10) |> IO.inspect
```

### Get a PixRequest

After its creation, information on a Pix request may be retrieved by its id. Its status indicates whether it has been paid.

```elixir
request = StarkInfra.PixRequest.get!("5155165527080960") |> IO.inspect
```

### Query PixRequest logs

You can query Pix request logs to better understand Pix request life cycles. 

```elixir
logs = StarkInfra.PixRequest.Log.query!(
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1)
) |> Enum.take(10) |> IO.inspect
```

### Get a PixRequest log

You can also get a specific log by its id.

```elixir
log = StarkInfra.PixRequest.Log.get!("5155165527080960") |> IO.inspect
```

### Create PixReversals

You can reverse a PixRequest either partially or totally using a PixReversal.

```elixir
StarkInfra.PixReversal.create!([
  %StarkInfra.PixReversal{
    amount: 100,
    external_id: "my_unique_id",
    end_to_end_id: "E00000000202201060100rzsJzG9PzMg",
  }]) |> IO.inspect
```

### Query PixReversals 

You can query multiple Pix reversals according to filters. 

```elixir
reversals = StarkInfra.PixReversal.query!(
  limit: 10,
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1),
  status: ["created"],
  tags: ["iron", "suit"],
  return_ids: ["D20018183202202030109X3OoBHG74wo"]
) |> Enum.take(10) |> IO.inspect
```

### Get a PixReversal

After its creation, information on a Pix reversal may be retrieved by its id.
Its status indicates whether it has been successfully processed.

```elixir
reversal = StarkInfra.PixReversal.get!("5155165527080960") |> IO.inspect
```

### Query PixReversal logs

You can query Pix reversal logs to better understand their life cycles. 

```elixir
logs = StarkInfra.PixReversal.Log.query!(
  limit: 50,
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1)
) |> Enum.take(10) |> IO.inspect
```

### Get a PixReversal log

You can also get a specific log by its id.

```elixir
log = StarkInfra.PixReversal.Log.get!("5155165527080960") |> IO.inspect
```

### Get your PixBalance 

To see how much money you have in your account, run:

```elixir
balance = StarkInfra.PixBalance.get!() |> IO.inspect
```

### Create a PixStatement

Statements are generated directly by the Central Bank and are only available for direct participants.
To create a statement of all the transactions that happened on your account during a specific day, run:

```elixir
statement = StarkInfra.PixStatement.create!(
  after: Date.utc_today |> Date.add(-1), # This is the date that you want to create a statement.
  before: Date.utc_today |> Date.add(-1), # After and before must be the same date.
  type: "transaction"  # Options are "interchange", "interchangeTotal", "transaction".
) |> IO.inspect
```

### Query PixStatements

You can query multiple Pix statements according to filters. 

```elixir
statements = StarkInfra.PixStatement.query!(
  limit: 50,
) |> Enum.take(10) |> IO.inspect
```

### Get a PixStatement

Statements are only available for direct participants. To get a Pix statement by its id:

```elixir
statement = StarkInfra.PixStatement.get!("5674087007387648") |> IO.inspect
```

### Get a PixStatement .csv file

To get the .csv file corresponding to a Pix statement using its id, run:

```elixir
statement_csv = StarkInfra.PixStatement.get_csv!("5674087007387648")
file = File.open!("statement.zip", [:write])
IO.binwrite(file, statement_csv)
File.close(file)
```

## Create a PixKey

You can create a Pix Key to link a bank account information to a key id:

```elixir
key = StarkInfra.PixKey.create!(
  %StarkInfra.PixKey{
    key_id: "+5511989898989",
    bank_code: "34052649",
    account_number: "052649",
    branch_code: "0001",
    account_type: "checking",
    name: "Tyrion Lannister",
    tax_id: "012.345.678-90",
  }
) |> IO.inspect
```

## Query PixKeys

You can query multiple Pix keys you own according to filters.

```elixir
keys = StarkInfra.PixKey.query!(
  limit: 1,
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1),
  status: ["registered"],
  tags: ["iron", "suit"],
  ids: ["+5511989898989"],
) |> Enum.take(10) |> IO.inspect
```

## Get a PixKey

Information on a Pix key may be retrieved by its id and the tax ID of the consulting agent.
An endToEndId must be informed so you can link any resulting purchases to this query,
avoiding sweep blocks by the Central Bank.

```elixir
key = StarkInfra.PixKey.get!("+5511989898989", payer_id: "012.345.678-90") |> IO.inspect
```

## Patch a PixKey

Update the account information linked to a Pix Key.

```elixir
key = StarkInfra.PixKey.update!(
  "+5511989898989", 
  "reason": "reconciliation",
  %{"name": "Tyrion Lannister"}
) |> IO.inspect
```

## Cencel a PixKey

Cancel a specific Pix Key using its id.

```elixir
key = StarkInfra.PixKey.cancel!("+5511989898989") |> IO.inspect
```

## Query PixKey logs

You can query Pix key logs to better understand a Pix key life cycle. 

```elixir
logs = StarkInfra.PixKey.Log.query!(
  limit: 50,
  ids: ["5729405850615808"],
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1),
  types: ["created"],
  key_ids: ["+5511989898989"]
) |> Enum.take(10) |> IO.inspect
```

## Get a PixKey log

You can also get a specific log by its id.

```elixir
log = StarkInfra.PixKey.Log.get!("5729405850615808") |> IO.inspect
```

## Create a PixClaim

You can create a Pix claim to request the transfer of a Pix key from another bank to one of your accounts:

```elixir
claim = StarkInfra.PixClaim.create!(
  %StarkInfra.PixClaim{
    account_created: DateTime.utc_now(),
    account_number: "123456789",
    account_type: "checking",
    branch_code: "0001",
    name: "Jamie Lanister",
    tax_id: "012.345.678-90",
    key_id: "+5511933571793",
  }
) |> IO.inspect
```

## Query PixClaims

You can query multiple Pix claims according to filters.

```elixir
claims = StarkInfra.PixClaim.query!(
  limit: 1,
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1),
  status: ["registered"],
  type: "ownership",
  agent: "claimed",
  key_type: "phone",
  key_id: "+5511989898989"
) |> Enum.take(10) |> IO.inspect
```

## Get a PixClaim

After its creation, information on a Pix claim may be retrieved by its id.

```elixir
claim = StarkInfra.PixClaim.get!("5729405850615808") |> IO.inspect
```

## Patch a PixClaim

A Pix Claim can be confirmed or canceled by patching its status.
A received Pix Claim must be confirmed by the donor to be completed.
Ownership Pix Claims can only be canceled by the donor if the reason is "fraud".
A sent Pix Claim can also be canceled.

```elixir
claim = StarkInfra.PixClaim.update!("5729405850615808", "confirmed") |> IO.inspect
```

## Query PixClaim logs

You can query Pix claim logs to better understand Pix claim life cycles.

```elixir
logs = StarkInfra.PixClaim.Log.query!(
  limit: 50,
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1),
  types: ["registered"],
  claim_ids: ["5719405850615809"]
) |> Enum.take(10) |> IO.inspect
```

## Get a PixClaim log

You can also get a specific log by its id.

```elixir
log = StarkInfra.PixClaim.Log.get!("5719405850615809") |> IO.inspect
```
### Create a PixDirector

To register the Pix director contact information at the Central Bank, run the following:

```elixir
director = StarkInfra.PixDirector.create!(
  %StarkInfra.PixDirector{
    name: "Tyrion Lannister",
    email: "tyrion@lannister.com",
    phone: "+5511989898989",
    tax_id: "012.345.678-90",
  }
) |> IO.inspect
```

### Create PixInfractions

Pix infractions are used to report transactions that raise fraud suspicion, to request a refund or to 
reverse a refund. Pix infractions can be created by either participant of a transaction.

```elixir
infraction = StarkInfra.PixInfraction.create!([
  %StarkInfra.PixInfraction{
    reference_id: "E20018183202201201450u34sDGd19lz",
    type: "fraud",
  }
]) |> IO.inspect
```

### Query PixInfractions

You can query multiple Pix infractions according to filters.

```elixir
infractions = StarkInfra.PixInfraction.query!(
  limit: 10,
  after: "2022-01-01",
  before: "2022-01-12",
  status: ["delivered"],
  ids: ["5729405850615808"],
) |> Enum.take(10) |> IO.inspect
```

### Get a PixInfraction

After its creation, information on a Pix Infraction may be retrieved by its id.

```elixir
infraction = StarkInfra.PixInfraction.get!("5155165527080960") |> IO.inspect
```

### Update a PixInfraction

A received Pix Infraction can be confirmed or declined by patching its status.
After a Pix Infraction is patched, its status changes to closed.

```elixir
infraction = StarkInfra.PixInfraction.update!("5155165527080960", result: "agreed") |> IO.inspect
```

### Cancel a PixInfraction

Cancel a specific Pix Infraction using its id.

```elixir
infraction = StarkInfra.PixInfraction.cancel!("5155165527080960") |> IO.inspect
```

### Query PixInfraction logs

You can query Pix infractions logs to better understand their life cycles. 

```elixir
logs = StarkInfra.PixInfraction.Log.query!(
  limit: 50,
  ids: ["5729405850615808"],
  after: "2022-01-01",
  before: "2022-01-20",
  types: ["created"],
  infraction_ids: ["5155165527080960"]
) |> Enum.take(50) |> IO.inspect
```

### Get a PixInfraction log

You can also get a specific log by its id.

```elixir
log = StarkInfra.PixInfraction.Log.get!("5155165527080960") |> IO.inspect
```

### Create PixChargebacks

A Pix chargeback can be created when fraud is detected on a transaction or a system malfunction 
results in an erroneous transaction.

```elixir
chargebacks = StarkInfra.PixChargeback.create!(
  %StarkInfra.PixChargeback{
    amount: 100,
    reference_id: "E20018183202201201450u34sDGd19lz",
    reason: "fraud",
  }
) |> Enum.take(100) |> IO.inspect
```

### Query PixChargebacks

You can query multiple Pix chargebacks according to filters.

```elixir
chargebacks = StarkInfra.PixChargeback.query!(
  limit: 1,
  after: "2022-01-01",
  before: "2022-01-12",
  status: ["registered"],
  ids: ["5155165527080960"]
) |> Enum.take(1) |> IO.inspect
```

### Get a PixChargeback

After its creation, information on a Pix Chargeback may be retrieved by its.

```elixir
chargeback = StarkInfra.PixChargeback.get!("5155165527080960") |> IO.inspect
```

### Update a PixChargeback

A received Pix Chargeback can be accepted or rejected by patching its status.
After a Pix Chargeback is patched, its status changes to closed.

```elixir
chargeback = StarkInfra.PixChargeback.update!(
  "5155165527080960", 
  result: "accepted",
  %{"reversal_reference_id": StarkInfra.Utils.ReturnId.create!("20018183")}
) |> IO.inspect
```

### Cancel a PixChargeback

Cancel a specific Pix Chargeback using its id.

```elixir
chargeback = StarkInfra.PixChargeback.cancel!("5155165527080960") |> IO.inspect
```

### Query PixChargeback logs

You can query Pix chargeback logs to better understand Pix chargeback life cycles. 

```elixir
logs = StarkInfra.PixChargeback.Log.query!(
  limit: 50,
  ids: ["5729405850615808"],
  after: "2022-01-01",
  before: "2022-01-20",
  types: ["created"],
  chargeback_ids: ["5155165527080960"]
) |> Enum.take(50) |> IO.inspect
```
### Get a PixChargeback log

You can also get a specific log by its id.

```elixir
log = StarkInfra.PixChargeback.Log.get!("5155165527080960") |> IO.inspect
```

### Query PixDomains

You can query for domains of registered SPI participants able to issue dynamic QR Codes.

```elixir
domains = StarkInfra.PixDomain.query!() |> IO.inspect
```

## Credit Note

### Create CreditNotes

You can create a Credit Note to generate a CCB contract:

```elixir
creditnote = StarkInfra.CreditNote.create!([
  %StarkInfra.CreditNote{
    template_id: "5686220801703936",
    name: "Jamie Lannister",
    tax_id: "012.345.678-90",
    nominal_amount: 100000,
    scheduled: "2022-04-28",
    invoices: [
      %StarkInfra.CreditNote.Invoice{
          due: "2023-06-25",
          amount: 120000,
          fine: 10,
          interest: 2
      }
    ],
    tags: ["test", "testing"],
    payment: %StarkInfra.CreditNote.Transfer{
      due: "2023-06-25",
      amount: 120000,
      fine: 10,
      interest: 2
    }
    signers: [
      %StarkInfra.CreditNote.Transfer{
        due: "2023-06-25",
        amount: 120000,
        fine: 10,
        interest: 2
      }
    ]
  }
]) |> IO.inspect
```

**Note**: Instead of using CreditNote structs, you can also pass each CreditNote element in map format

### Query CreditNotes

You can query multiple credit notes according to filters.

```elixir
credit_note = StarkInfra.CreditNote.query!(
  limit: 10,
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1),
  status: ["success"],
  tags: ["iron", "suit"]
) |> Enum.take(10) |> IO.inspect
```

### Get a CreditNote

After its creation, information on a credit note may be retrieved by its id.

```elixir
transaction = StarkInfra.CreditNote.get!("5155165527080960") |> IO.inspect
```

## Cancel a CreditNote

You can cancel a credit note if it has not been signed yet.

```elixir
note = StarkInfra.CreditNote.cancel!("5155165527080960") |> IO.inspect
```
  
### Query CreditNote logs

You can query credit note logs to better understand credit note life cycles. 

```elixir
logs = StarkInfra.CreditNote.Log.query!(
  limit: 10,
  after: "2020-11-01",
  before: "2020-11-02"
) |> Enum.take(10) |> IO.inspect
```

### Get a CreditNote log

You can also get a specific log by its id.

```elixir
log = StarkInfra.CreditNote.log.get!("5155165527080960") |> IO.inspect
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

Email: help@starkinfra.com