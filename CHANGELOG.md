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
- BrcodePreview resource
- DynamicBrcode resource
- IndividualDocument resource
- IndividualDocument.Log resource
- IndividualIdentity resource
- IndividualIdentity.Log resource
- CreditHolmes resource
- CreditHolmes.Log resource
- IssuingDesign resource
- IssuingEmbossingKit resource
- IssuingEmbossingRequest resource
- IssuingEmbossingRequest.Log resource
- IssuingRestock resource
- IssuingRestock.Log resource
- IssuingStock resource
- IssuingStock.Log resource
- CardMethod sub-resource
- MerchantCountry sub-resource
- MerchantCategory sub-resource
- CreditPreview sub-resource
- CreditNotePreview sub-resource
- flow attribute to PixChargeback and PixInfraction resources
- tags parameter to PixClaim, PixInfraction, PixChargeback resources
- tags parameter to query and page methods in PixChargeback, PixClaim and PixInfraction resources
- agent parameter to query and page methods in PixInfraction and PixChargeback resources
- expand parameter to create, get, query and page methods in IssuingHolder resource
- pin parameter to update method in IssuingCard resource
- nominal_interest attributes to return only in CreditNote resource
- code attribute to IssuingProduct resource
- parse method in IssuingPurchase resource
- response method in IssuingPurchas, PixRequest and PixReversal resources
- zip_code, is_partial_allowed, card_tags and holder_tags attributes to IssuingPurchase resource
- brcode, link and due attributes to IssuingInvoice resource
- payer_id and endToEndId parameter to BrcodePreview resource
- cashier_bank_code and description parameter to StaticBrcode resource
- merchant_category_type, description, metadata and holder_id attributes to IssuingPurchase resource
### Changed
- CreditNote.Signer to CreditSigner sub-resource
- PixDirector resource to sub-resource
- IssuingBin resource to IssuingProduct
- fine and interest attributes to return only in CreditNote.Invoice sub-resource
- expiration from returned-only attribute to optional parameter in the CreditNote resource
- settlement parameter to funding_type and client parameter to holder_type in Issuing Product resource
- bank_code parameter to claimer_bank_code in PixClaim resource
- agent parameter to flow in PixClaim and PixInfraction resources
- agent parameter to flow on query and page methods in PixClaim resource
- CreditNote.Signer sub-resource to CreditSigner resource
- change nominal_amount and amount parameters to conditionally required to CreditNote resource
- sender_tax_id and receiver_tax_id parameters to DynamicBrcode resource
### Removed
- IssuingAuthorization resource
- category parameter from IssuingProduct resource
- bank_code attribute from PixReversal resource
- agent parameter from PixClaim.Log
- bacen_id attribute from PixChargeback and PixInfraction resources
- card_design_id and envelopeDesignId attributes to IssuingEmbossingRequest resource

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
