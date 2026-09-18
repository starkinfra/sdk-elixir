# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to the following versioning pattern:

Given a version number MAJOR.MINOR.PATCH, increment:

- MAJOR version when the **API** version is incremented. This may include backwards incompatible changes;
- MINOR version when **breaking changes** are introduced OR **new functionalities** are added in a backwards compatible manner;
- PATCH version when backwards compatible bug **fixes** are implemented.

## [Unreleased]
### Added
- StaticBrcode resource
- DynamicBrcode resource
- PixKeyHolmes resource
- PixKeyHolmes.Log sub-resource
- PixInternalTransactionReport resource
- PixInternalTransactionReport.Log sub-resource
- PixPullRequest resource
- PixPullRequest.Log sub-resource
- Ledger resource
- Ledger.Rule sub-resource
- Ledger.Log sub-resource
- LedgerTransaction resource
- CreditHolmes resource
- CreditHolmes.Log sub-resource
- CreditPreview resource
- CreditPreview.CreditNotePreview sub-resource
- CreditNote.Signer.resend_token method
- CreditNote.pdf method
- CreditNote.payment method
- IssuingBillingInvoice resource
- IssuingBillingTransaction resource
- IssuingDesign resource
- IssuingEmbossingKit resource
- IssuingEmbossingRequest resource
- IssuingEmbossingRequest.Log sub-resource
- IssuingRestock resource
- IssuingRestock.Log sub-resource
- PixFraud resource
- PixFraud.Log sub-resource
- PixPullSubscription resource
- PixPullSubscription.Log sub-resource
- IssuingStock resource
- IssuingStock.Log sub-resource
- IssuingRule missing parameters
- PixUser resource
- PixUser.Statistics sub-resource
- PixDispute resource
- PixDispute.Transaction sub-resource
- PixDispute.Log sub-resource
- priority and reason attributes and response method to PixRequest resource
- description attribute and response method to PixReversal resource
- tags, flow, dispute_id, is_monitoring_required and reversal attributes to PixChargeback resource
- tags, bacen_id, flow and claimer_bank_code attributes to PixClaim resource
- method, operator_email, operator_phone, tags, fraud_type, fraud_id, flow, amount and dispute_id attributes to PixInfraction resource
- chunk_count attribute to PixStatement resource
- update method and product_id, installment_count, merchant_category_type, merchant_category_number, confirmed, description, metadata and zip_code attributes to IssuingPurchase resource
- installment attribute to IssuingPurchase.Log sub-resource
- product_id and is_pin_defined attributes to IssuingCard resource
- limit and max_limit attributes to IssuingBalance resource
- brcode, due, link and metadata attributes to IssuingInvoice resource
- customer_type attribute to IssuingProduct resource
- Rule sub-resource and rules, debtor_workspace_id and nominal_interest attributes to CreditNote resource
- BrcodePreview resource
- IssuingToken resource
- IssuingToken.Log sub-resource
- IssuingTokenDesign resource
- IssuingTokenRequest sub-resource
- IssuingTokenActivation sub-resource
- IssuingStockRule resource
- CardMethod sub-resource
- MerchantCategory sub-resource
- MerchantCountry sub-resource
- IndividualAccountRequest resource
- IndividualAccountRequest.Address sub-resource
- IndividualAccountRequest.Log sub-resource
- IndividualAccountAttachment resource
- IndividualAccountAttachment.Log sub-resource
- IndividualIdentity resource
- IndividualIdentity.Log sub-resource
- BusinessIdentity resource
- BusinessIdentity.Log sub-resource
- BusinessAttachment resource
- BusinessAttachment.Log sub-resource
### Changed
- IssuingBin resource to IssuingProduct
- settlement parameter to funding_type and client parameter to holder_type of IssuingProduct
- IssuingAuthorization parse and response to IssuingPurchase.parse and IssuingPurchase.response
### Fixed
- query parameters in post requests
- user option sent as query string in post requests
- ssl and public_key applications missing from extra_applications, breaking every request on OTP 26+
- query parameters in delete requests
- amount, expiration, document_id, status, transaction_ids, workspace_id and tax_amount attributes of CreditNote resource not being parsed
- README headings for PixKey, PixClaim, IssuingEmbossingRequest and Webhook
### Removed
- IssuingAuthorization resource
- category parameter of IssuingProduct resource

## [0.1.0] - 2022-06-03
### Added
- credit receiver's billing address on CreditNote

## [0.0.1] - 2022-05-27
### Added
- CreditNote resource for money lending with Stark Infra's endorsement
- PixRequest resource for Indirect and Direct Participants
- PixReversal resource for Indirect and Direct Participants
- PixDirector resource for Direct Participants
- PixBalance resource for Indirect and Direct Participants
- PixStatement resource for Direct Participants
- PixClaim resource for Indirect and Direct Participants
- PixKey resource for Indirect and Direct Participants
- PixDomain resource for Indirect and Direct Participants
- PixInfraction resource for Indirect and Direct Participants
- PixChargeback resource for Indirect and Direct Participants
- IssuingAuthorization resource for Sub Issuers
- IssuingBalance resource for Sub Issuers
- IssuingBin resource for Sub Issuers
- IssuingCard resource for Sub Issuers
- IssuingHolder resource for Sub Issuers
- IssuingInvoice resource for Sub Issuers
- IssuingPurchase resource for Sub Issuers
- IssuingTransaction resource for Sub Issuers
- IssuingWithdrawal resource for Sub Issuers
- Webhook resource to receive Events
- Event resource for webhook receptions
- Event.Attempt sub-resource to allow retrieval of information on failed webhook event delivery attempts
