# PROTOTYPE DRAFT FOR DISCUSSION: Materials Commons DSP Tier 1 (Public Datasets and Services)

## Status of this document

This document defines **Materials Commons DSP Tier 1**, a provider-side
interoperability profile for basic non-authenticated access to catalogs of
public datasets and services.

This document is a normative specification. It profiles the
[Dataspace Protocol 2025-1, errata revision 1](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/)
and uses terms from
[DCAT 3](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/)
and [ODRL 2.2](https://www.w3.org/TR/odrl-model/). Where this document imposes
a narrower requirement than DSP 2025-1, the narrower requirement applies to
Materials Commons DSP Tier 1 conformance. This document does not relax any DSP
requirement.

The separately specified
[Materials Commons DCAT-AP GET Protocol Tier 1](materials-commons-dcat-ap-get-protocol-tier-1.md) provides an optional,
strict DCAT-AP 3.0.1 representation of the same public catalogue. The two
representations use the same JSON value except for `@context`; changing that
context repairs the one unavoidable RDF literal-versus-IRI conflict imposed by
DSP. Conformance to the companion protocol is not required for conformance to
this document.

## Abstract

Materials Commons DSP Tier 1 defines a small, deterministic Dataspace
Protocol provider profile for datasets and services that are already
public. The profile aims to provide the minimum functionality needed
to make such datasets accessible to conforming DSP consumers without
requiring authentication or access control.

It provides:

1. unauthenticated DSP version discovery;
2. unauthenticated DSP catalogue and individual-dataset discovery;
3. one unconditional ODRL `use` offer and one public HTTPS-pull distribution
   for each dataset;
4. the provider endpoints required for the selected DSP contract-negotiation
   and transfer-process flows;
5. a direct, unauthenticated HTTPS data plane that is not protected by the DSP
   control plane;
6. DCAT-AP 3.0.1-compatible catalogue metadata, with `dcat:endpointURL` as the
   single unavoidable RDF range exception imposed by DSP;
7. an optional DSP-native advertisement of a Materials Commons DCAT-AP Tier 1
   companion service; and
8. an optional, discoverable `application/ld+json` representation obtained by
   replacing only the DSP context.

Tier 1 deliberately excludes authentication, authorization, confidential or
embargoed datasets, negotiated policy constraints, push transfer, catalogue
filters, catalogue pagination, proof exchange, and broker replication. The
DSP `application/json` response does not claim DCAT-AP conformance because its
official context necessarily expands `dcat:endpointURL` as an RDF literal. An
optional `application/ld+json` alternate representation can make the complete
DCAT-AP conformance claim without changing the catalogue payload.

Tier 1 deliberately goes beyond implementing the DSP Catalog Protocol
alone. DSP requires each advertised Distribution to reference a
DataService whose endpoint is used to initiate Contract Negotiation
and Transfer Process operations. Consequently, a self-contained
provider that has no existing DSP Connector must also provide these
Connector operations for its catalogue to be actionable by standard
DSP consumers. Tier 1 therefore defines the minimal
contract-negotiation and transfer-process flows for otherwise directly
accessible public datasets.

## 1. Conformance and requirement language

### 1.1 Normative language

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**,
**SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **NOT RECOMMENDED**, **MAY**, and
**OPTIONAL** in this document are to be interpreted as described in
[BCP 14](https://www.rfc-editor.org/info/bcp14) when, and only when, they appear
in all capitals.

Examples, explanatory notes, and sections explicitly marked non-normative are
not conformance requirements.

### 1.2 Conformance target

The conformance target is a **Materials Commons DSP Tier 1 Provider**. A
conforming Provider implements the provider-side HTTPS endpoints, messages,
resource model, callbacks, state transitions, and public data plane defined by
this document.

A Provider MAY additionally conform to Materials Commons DCAT-AP Tier 1. That
is an independent conformance claim and MUST NOT be inferred merely because a
DSP catalogue contains DCAT terms. It MAY be inferred from the exact
machine-readable service advertisement defined in Section 9.

### 1.3 Relationship to DSP conformance

A Tier 1 Provider MUST satisfy the applicable requirements of the
[DSP conformance section](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#conformance),
including the official DSP JSON Schemas and protected JSON-LD context.

The normative conformance identifier for this profile is:

```text
tag:materialscommons.eu,2026:dsp/prototype-tier-1
```

This IRI identifies the profile. It does not prescribe the deployment URL of a
Provider.

The `tag:` URIs in this specification are provisional prototype
identifiers (RFC 4151), marked (TBD) where they appear in prose, pending
a working-group decision.

### 1.4 Exact relationship to DCAT and DCAT-AP

DSP 2025-1 deliberately reuses DCAT classes and properties through a
restricted DSP profile. Its catalogue is therefore recognizably DCAT-shaped,
but the DSP JSON Schema and protected JSON-LD context are authoritative for DSP
messages. A DSP catalogue is not automatically a conforming DCAT catalogue.
Materials Commons DSP Tier 1 narrows the permitted DSP catalogue model so that
its RDF expansion satisfies DCAT 3 and DCAT-AP 3.0.1 in every respect except
the one conflict identified below.

There is a concrete incompatibility in the upstream standards. DSP requires
`DataService.endpointURL` to be serialized as a JSON string. The protected DSP
context maps that string to `dcat:endpointURL` without IRI coercion, so JSON-LD
expansion produces an RDF literal. DCAT 3 defines `dcat:endpointURL` as the
Web-resolvable IRI of the service, and DCAT-AP 3.0.1 requires an IRI or blank
node. The protected DSP term cannot be redefined by this profile. See the DSP
[Schemas and Contexts](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#schemas-contexts),
the DSP
[DataService requirements](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#ack-dataset),
the DCAT 3
[endpoint URL definition](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#Property:data_service_endpoint_url),
and the DCAT-AP
[Data Service endpoint URL constraint](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#DataService.endpointURL).

The incompatibility concerns the RDF interpretation, not the JSON datatype:
the same JSON string is interpreted as an RDF IRI when an owned DCAT-AP context
defines `endpointURL` with `"@type": "@id"`. This specification consequently
follows these rules:

1. the DSP catalogue MUST validate against the official DSP JSON Schema and
   MUST use the protected official DSP context;
2. its expanded RDF graph MUST satisfy the DCAT-AP 3.0.1 mandatory-property,
   range, and controlled-vocabulary constraints except that every
   `dcat:endpointURL` is a literal rather than an IRI;
3. every other RDF range, class assertion, controlled-vocabulary value, and
   datatype required by this profile MUST be represented explicitly in the
   common JSON value and MUST NOT depend on an implementation inference;
4. the DSP `application/json` response MUST NOT claim that its RDF graph
   conforms to DCAT or DCAT-AP;
5. an alternate DCAT-AP representation, when supplied, MUST change only the
   top-level `@context`, the HTTP representation headers, and serialization
   details that do not change the JSON value; and
6. expansion under that alternate context MUST satisfy all applicable
   DCAT-AP 3.0.1 constraints without exception.

The JSON-LD context is a mapping mechanism, not a complete validation
language. Requirements such as class membership of an EU File Type concept
are therefore stated normatively here and asserted explicitly in the payload,
even though the official DSP context does not enforce them.

The separate **Materials Commons DCAT-AP Tier 1** protocol supplies a
well-known-discoverable `GET` operation for conventional DCAT harvesters. The
optional content-negotiated representation in Section 9 gives DSP-aware
clients the same graph without inventing `GET <base>/catalog`.

## 2. Scope

### 2.1 Purpose

Tier 1 is intended for a provider that publishes finite datasets and public
services for unrestricted discovery and retrieval. A consumer can discover
and download a Tier 1 dataset without credentials, tokens, proofs, or prior
authorization.

At this protocol tier, Contract Negotiation and Transfer Process are
implemented only at the level needed to allows the standard DSP
access protocol to give access to all distributions, and cannot
be used to limit that access.

### 2.2 Included capabilities

Tier 1 includes:

- DSP 2025-1 version discovery over HTTPS;
- provider-side DSP catalogue, negotiation, and transfer endpoints;
- complete-catalogue retrieval without server-side filtering;
- retrieval of one dataset description by its exact identifier;
- public, finite, consumer-pull transfer over HTTPS;
- unconditional ODRL permission to perform the `use` action;
- process termination, suspension, resumption, and completion within the
  constrained state transitions defined here;
- DCAT-AP-compatible publication metadata for formats, media types, direct
  download URLs, optional byte sizes, and optional SHA-256 checksums;
- optional discovery of a Materials Commons DCAT-AP Tier 1 service through the
  DSP catalogue; and
- optional discovery and retrieval of a context-substituted DCAT-AP
  representation through the DSP catalogue request target.

### 2.3 Excluded capabilities

The following are outside Tier 1:

- authentication and authorization requirements;
- access tokens in DSP messages or data addresses;
- restricted, confidential, embargoed, or participant-specific catalogues;
- ODRL constraints, duties, obligations, and prohibitions;
- push transfer and consumer-supplied data addresses;
- non-finite streams;
- server-side catalogue filtering or query languages;
- catalogue pagination;
- catalogue proof-metadata endpoints;
- DID-based service discovery requirements;
- catalogue brokers and catalogue replication;
- data-plane protocols other than HTTPS pull;
- durable persistence of negotiation or transfer-process state; and
- a DCAT 3 or DCAT-AP conformance claim for the DSP `application/json`
  response.

An implementation MAY provide excluded capabilities in another profile or
tier. They MUST NOT be required to access a Tier 1 dataset or alter the
semantics of a Tier 1 endpoint.

## 3. Terminology

Terms defined by the
[DSP terms and definitions](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#terminology)
and [DCAT 3 vocabulary](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#vocabulary-overview)
apply.

For this specification:

- **Provider** means the participant that publishes the Tier 1 catalogue and
  makes its datasets available.
- **Consumer** means a participant that discovers or retrieves those datasets.
- **Connector root**, written `<root>`, means the externally visible,
  unversioned HTTPS URL prefix at which DSP version discovery is exposed. It
  may contain a path.
- **Version base**, written `<base>`, means the URL obtained by concatenating
  `<root>` with the selected DSP version entry's `path`.
- **DSP access service** means the DSP `DataService` through which negotiation
  and transfer processes are initiated.
- **DCAT-AP companion service** means an optional service conforming to
  Materials Commons DCAT-AP Tier 1 and advertised as specified in Section 9.
- **Public distribution** means a distribution whose direct HTTPS URL is usable
  without authentication or authorization.
- **Catalogue snapshot** means one internally consistent catalogue response
  and the dataset, offer, distribution, publisher, and service metadata used
  to construct it.
- **Common catalogue value** means the JSON value of a catalogue snapshot
  after removing its top-level `@context` member. Object-member order,
  insignificant whitespace, and equivalent JSON number spellings are not
  part of this value.
- **Negotiated DCAT-AP feature** means the optional Section 9
  context-substitution operation advertised by the DSP access service.

## 4. Normative namespaces and identifiers

| Prefix or name | IRI |
|---|---|
| DSP context | `https://w3id.org/dspace/2025/1/context.jsonld` |
| DSP 2025-1-err1 specification | `https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/` |
| Tier 1 DSP profile | (TBD) `tag:materialscommons.eu,2026:dsp/prototype-tier-1` |
| Tier 1 DCAT-AP companion profile | (TBD) `tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-1` |
| Negotiated DCAT-AP feature | (TBD) `tag:materialscommons.eu,2026:dsp/prototype-tier-1#dcat-ap-content-negotiation` |
| DCAT-AP 3.0.1 profile | `https://semiceu.github.io/DCAT-AP/releases/3.0.1/` |
| `dcat` | `http://www.w3.org/ns/dcat#` |
| `dct` | `http://purl.org/dc/terms/` |
| `foaf` | `http://xmlns.com/foaf/0.1/` |
| `odrl` | `http://www.w3.org/ns/odrl/2/` |
| `spdx` | `http://spdx.org/rdf/terms#` |
| `xsd` | `http://www.w3.org/2001/XMLSchema#` |
| HTTP endpoint type | `https://w3id.org/idsa/v4.1/HTTP` |
| EU File Type authority | `http://publications.europa.eu/resource/authority/file-type/` |
| IANA media-type identifiers | `https://www.iana.org/assignments/media-types/` |
| SPDX SHA-256 algorithm | `https://spdx.org/rdf/terms#checksumAlgorithm_sha256` |

All identifiers described as IRIs MUST be absolute IRIs. All public network
URLs, callback URLs, endpoint URLs, access URLs, and download URLs MUST use
HTTPS.

Catalogue, participant, publisher, dataset, offer, distribution, and service
identifiers MUST be stable. Dataset, offer, and distribution identifiers MUST
each be unique within a catalogue snapshot.

When no independent offer or distribution identifier has been assigned, a
Provider SHOULD derive one by appending `#offer` or `#distribution` to the
dataset identifier.

## 5. HTTPS service organization

### 5.1 Location independence

This specification does not prescribe the path of `<root>` or `<base>`.
`<root>` MUST be an absolute HTTPS URL without user information, query, or
fragment. It MAY include a deployment path.

The DSP version `path` MUST be interpreted according to the DSP
[HTTPS version-path rule](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#https-binding).
The Provider and Consumer MUST derive `<base>` from version discovery and MUST
NOT assume that it ends in `/2025-1`.

The following is a non-normative deployment example:

```text
<root> = https://provider.example/dsp
path   = /2025-1
<base> = https://provider.example/dsp/2025-1
```

The paths `/dsp` and `/2025-1` are convenient but are not required.

### 5.2 Required provider endpoints

A Tier 1 Provider MUST expose these DSP endpoints:

| Method | URL | Function |
|---|---|---|
| `GET` | `<root>/.well-known/dspace-version` | DSP version discovery |
| `POST` | `<base>/catalog/request` | DSP catalogue request |
| `GET` | `<base>/catalog/datasets/{id}` | DSP dataset request |
| `GET` | `<base>/negotiations/{providerPid}` | Negotiation state |
| `POST` | `<base>/negotiations/request` | Initial contract request |
| `POST` | `<base>/negotiations/{providerPid}/request` | Counter-request |
| `POST` | `<base>/negotiations/{providerPid}/events` | Negotiation event |
| `POST` | `<base>/negotiations/{providerPid}/agreement/verification` | Agreement verification |
| `POST` | `<base>/negotiations/{providerPid}/termination` | Negotiation termination |
| `GET` | `<base>/transfers/{providerPid}` | Transfer state |
| `POST` | `<base>/transfers/request` | Initial transfer request |
| `POST` | `<base>/transfers/{providerPid}/start` | Resume transfer |
| `POST` | `<base>/transfers/{providerPid}/suspension` | Suspend transfer |
| `POST` | `<base>/transfers/{providerPid}/completion` | Complete transfer |
| `POST` | `<base>/transfers/{providerPid}/termination` | Terminate transfer |

These paths follow the DSP
[catalogue HTTPS binding](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#catalog-http),
[negotiation provider paths](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#provider-path-bindings),
and [transfer provider paths](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#provider-path-bindings-0).

`GET <base>/catalog` is not a DSP 2025-1 endpoint and is not required or defined
by this specification.

### 5.3 Media type, context, and schemas

All DSP request and response bodies MUST use `application/json`, as required by
the HTTPS bindings for
[catalogue](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#prerequisites),
[negotiation](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#prerequisites-0),
and [transfer](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#prerequisites-3).

Every contextualized DSP message MUST contain an `@context` array including
the exact official DSP context and MUST use the required `@type`. Incoming and
outgoing DSP documents MUST validate against the official DSP 2025-1 JSON
Schema for their message or resource type. Providers SHOULD validate against
pinned schemas without live retrieval during request processing.

The optional Section 9 `application/ld+json` representation is not a DSP
response message. It is an additional HTTP representation selected by an
explicit request and has its own context and media type. Its availability does
not alter the required DSP behavior for `application/json` requests and
responses.

## 6. DSP version discovery

`GET <root>/.well-known/dspace-version` MUST be unversioned, public, and
unauthenticated, following DSP
[Exposure of Versions](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#exposure-of-dataspace-protocol-versions).

A successful response MUST return `200 OK` and a DSP `VersionResponse` with at
least one entry having:

- `version` equal to `2025-1`;
- `binding` equal to `HTTPS`;
- an absolute URL path segment in `path` that produces `<base>` when appended
  to `<root>`;
- `serviceId` equal to the stable DSP access-service identifier; and
- no `auth` member.

For the non-normative path arrangement in Section 5.1, that entry is:

```json
{
  "version": "2025-1",
  "path": "/2025-1",
  "binding": "HTTPS",
  "serviceId": "https://provider.example/services/dsp"
}
```

Additional version entries MAY be present and are outside this profile.

## 7. DSP catalogue protocol

### 7.1 Catalogue request

Official catalogue discovery MUST use:

```text
POST <base>/catalog/request
```

The request MUST be a DSP `CatalogRequestMessage` as defined by
[DSP Section 5.2.1](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#catalog-request-message)
and its
[HTTPS endpoint](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#catalog-request-post).

`filter` MUST be absent or an empty array. A non-empty filter MUST produce
`400 Bad Request` with a `CatalogError` whose code identifies an unsupported
filter.

A successful request MUST return `200 OK` and the complete current DSP
catalogue. It MUST NOT require pagination.

### 7.2 Catalogue response

The response MUST satisfy the DSP
[Catalog response requirements](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#ack-catalog)
and contain:

- the official DSP context;
- an absolute catalogue `@id`;
- `@type` equal to `Catalog`;
- a stable `participantId`;
- non-empty `dct:title` and `dct:description` values;
- a `dct:conformsTo` array containing the Materials Commons DCAT-AP GET
  Protocol Tier 1 and DCAT-AP 3.0.1 profile IRIs, each represented as a typed
  `dct:Standard` object;
- `dct:publisher` conforming to Section 8.2;
- at least one dataset;
- exactly one DSP access service in the root `service` array and referenced by
  every distribution;
- zero or one DCAT-AP companion-service advertisement conforming to Section 9;
  and
- an optional negotiated DCAT-AP feature declaration on the DSP access service
  conforming to Section 9.

The response MUST be internally consistent. It MUST NOT contain duplicate
dataset, offer, distribution, or service identifiers.

The response is a DSP document. Under the official DSP context its
`endpointURL` values remain RDF literals, so that JSON-LD expansion is not a
DCAT 3 or DCAT-AP conformant RDF representation. The catalogue-level
`dct:conformsTo` values identify the conformance targets of the shared
catalogue value and its context-substituted DCAT-AP representation; they MUST
NOT be interpreted as overriding the RDF-literal exception in Section 3. A
`DataService` MAY additionally claim conformance to a protocol that it
implements; such a service-level statement does not claim that the enclosing
DSP serialization removes that exception.

### 7.3 Dataset entries

Each dataset MUST satisfy the DSP
[Dataset response requirements](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#ack-dataset)
and contain:

- an absolute, unique `@id`;
- `@type` equal to `Dataset`;
- non-empty `dct:title` and `dct:description` values;
- one publisher with an absolute IRI and non-empty name;
- exactly one `hasPolicy` value conforming to Section 8.4; and
- exactly one `distribution` value conforming to Section 8.5.

All datasets in one snapshot MUST use the catalogue publisher's identifier and
name.

### 7.4 Individual dataset request

A Consumer retrieves one dataset using:

```text
GET <base>/catalog/datasets/{id}
```

The identifier MUST be matched exactly after normal HTTP path decoding. This
is the binding of the DSP
[Dataset Request Message](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#dataset-request-message)
defined by
[DSP Section 6.2.2](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#catalog-datasets-get).

A known identifier MUST return `200 OK` and the same dataset metadata as the
catalogue, with the DSP context at the document root. An unknown identifier
MUST return `404 Not Found` with `CatalogError`.

### 7.5 Filters, pagination, and compression

Tier 1 defines no filter language. Consumers MUST filter the returned
catalogue locally, consistent with DSP
[Queries and Filter Expressions](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#queries-and-filter-expressions).

Catalogue responses MUST be complete and unpaginated. HTTP content coding MAY
be used when normal HTTP negotiation is respected and decoded content is
unchanged.

### 7.6 RDF alignment and validation

The Provider MUST expand each catalogue snapshot using the official DSP
context and validate the resulting RDF graph against the authoritative
DCAT-AP 3.0.1 mandatory-property, range, and controlled-vocabulary SHACL
shapes. Validation MUST be performed against pinned, provenance-recorded
copies and MUST NOT depend on live network retrieval.

This requirement fixes the validation choices left to an implementing data
exchange by the DCAT-AP
[validation guidance](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#validation-of-dcat-ap)
and applies its
[controlled-vocabulary requirements](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#controlled-vocs).

The only permitted validation results are those for which all of the
following hold:

1. the result path is `dcat:endpointURL`;
2. the value is the DSP-required JSON string expanded as an RDF literal;
3. replacing that literal with the absolute HTTPS IRI having the same lexical
   value makes the result conform; and
4. no other triple is added, removed, or changed to obtain conformance.

A missing property, wrong class, wrong datatype, non-controlled value,
cardinality error, or any result on another path is a Tier 1 conformance
failure. Validation warnings that are not DCAT-AP conformance violations
SHOULD be reported and reviewed but do not by themselves make the Provider
non-conforming.

When a Section 9 alternate representation is generated, its context MUST
coerce every `endpointURL` value to an RDF IRI. The resulting graph MUST pass
the same validation without the exception above.

## 8. Tier 1 publication model

### 8.1 Catalogue metadata

One catalogue snapshot MUST define:

| Field | Cardinality | Requirement |
|---|---:|---|
| Catalogue identifier | `1` | Absolute stable IRI |
| Title | `1` | Non-empty string |
| Description | `1` | Non-empty string |
| Participant identifier | `1` | Absolute stable IRI |
| Publisher | `1` | One shared Agent identifier and name |
| DSP access service | `1` | Root service with stable ID, title, `<base>` endpoint, conformance, and served datasets |
| Dataset | `1..*` | At least one Tier 1 dataset |
| DCAT-AP companion service | `0..1` | Optional Section 9 advertisement |
| Negotiated DCAT-AP feature | `0..1` | Optional Section 9 declaration on the DSP access service |

### 8.2 Publisher

The publisher MUST have an absolute `@id`, type
`http://xmlns.com/foaf/0.1/Agent`, and a non-empty value for
`http://xmlns.com/foaf/0.1/name`. Full FOAF IRIs are used because the official
DSP context does not define the `foaf` prefix.

The same publisher object MUST appear as `dct:publisher` on the catalogue.
Each dataset MUST refer to the same publisher and MUST either include its name
or identify the catalogue publisher node carrying that name.

### 8.3 Dataset declaration

Each dataset MUST define:

| Field | Cardinality | Requirement |
|---|---:|---|
| Dataset identifier | `1` | Absolute stable IRI; unique |
| Title | `1` | Non-empty string |
| Description | `1` | Non-empty string |
| Publisher identifier and name | `1` | Equal to catalogue publisher |
| Offer identifier | `1` | Absolute stable IRI; unique |
| Distribution identifier | `1` | Absolute stable IRI; unique |
| Public access URL | `1` | Absolute HTTPS URL |
| EU file-type IRI | `1` | EU File Type concept |
| IANA media-type IRI | `1` | Registered media-type IRI |
| Byte size | `0..1` | Non-negative integer |
| SHA-256 digest | `0..1` | 64 lower-case hexadecimal characters |

Values beginning with `/` MAY be accepted as publication configuration and
resolved against the Provider's public HTTPS origin before serialization. A
serialized DSP access or download URL MUST be absolute. Other relative forms
MUST NOT be serialized.

### 8.4 Unconditional ODRL offer

Each dataset MUST have exactly one advertised ODRL Offer:

```json
{
  "@id": "https://provider.example/datasets/example#offer",
  "@type": "Offer",
  "permission": [{"action": "use"}]
}
```

The catalogue form MUST NOT contain `target`, because DSP derives it from the
enclosing dataset. The offer MUST NOT contain constraints, duties,
obligations, prohibitions, remedies, or nested targets. It does not replace
licence, copyright, attribution, citation, or ethical-use metadata.

In a `ContractRequestMessage`, the same offer MUST have exactly one top-level
`target` equal to the dataset identifier, following the DSP
[Contract Request Message](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#contract-request-message).

### 8.5 Distribution and DCAT-AP-aligned metadata

Each dataset MUST have exactly one DSP Distribution containing:

- absolute `@id` and `@type` equal to `Distribution`;
- `format` equal to the full EU File Type IRI;
- an explicit `dct:format` node with that same `@id` and `@type` equal to
  `dct:MediaTypeOrExtent`;
- `dcat:accessURL` as an `@id` object containing the public HTTPS URL;
- `dcat:downloadURL` as an `@id` object containing that same direct URL;
- `dcat:mediaType` as an `@id` object containing the IANA media-type IRI and
  `@type` equal to `dct:MediaType`; and
- one DSP `accessService` object identifying the root DSP access service.

These requirements specialize the DCAT-AP properties for Distribution
[format](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#Distribution.format),
[media type](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#Distribution.mediatype),
[access URL](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#Distribution.accessURL),
[download URL](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#Distribution.downloadURL),
and [access service](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#Distribution.accessservice).

If known, it SHOULD also contain:

- `dcat:byteSize` as an explicitly typed `xsd:nonNegativeInteger` value; and
- an SPDX SHA-256 checksum represented with the full SPDX property IRIs.

The DSP-required `format` member MUST remain a JSON string. The additional
`dct:format` member supplies the class assertion that DCAT-AP validation
requires but the protected DSP context cannot express for that string:

```json
{
  "format": "http://publications.europa.eu/resource/authority/file-type/CSV",
  "dct:format": {
    "@id": "http://publications.europa.eu/resource/authority/file-type/CSV",
    "@type": "dct:MediaTypeOrExtent"
  }
}
```

Both members MUST identify the same resource. They therefore produce one
`dct:format` value in the RDF graph, together with the required
`rdf:type dct:MediaTypeOrExtent` assertion. A Consumer MUST reject or ignore a
distribution in which the two identifiers differ.

Metadata MUST describe publisher-supplied facts. A Provider MUST NOT inspect a
local file, compute its size, or hash its content merely to construct a DSP
response unless that behavior is explicitly part of the publication system.

CSV and JSON MUST use these exact mappings:

| Representation | DSP `format` | `dcat:mediaType` |
|---|---|---|
| CSV | `http://publications.europa.eu/resource/authority/file-type/CSV` | `https://www.iana.org/assignments/media-types/text/csv` |
| JSON | `http://publications.europa.eu/resource/authority/file-type/JSON` | `https://www.iana.org/assignments/media-types/application/json` |

Another representation MAY be published only with explicitly supplied EU File
Type and IANA media-type IRIs.

`TransferRequestMessage.format` MUST exactly equal the distribution's
advertised DSP `format`. Within this profile, every such value selects HTTPS
consumer-pull behavior. A different value MUST be rejected.

### 8.6 DSP access service

The DSP access service MUST have a stable absolute `@id`, `@type` equal to
`DataService`, a non-empty `dct:title`, and `endpointURL` equal to `<base>`. It
MUST occur in the root catalogue `service` array. It MUST contain
`dct:conformsTo` values for both the Materials Commons DSP Tier 1 profile and
DSP 2025-1-err1, expressed as `@id` objects with `@type` equal to
`dct:Standard`. It MUST contain `dcat:servesDataset` as `@id` objects naming
every dataset in the snapshot.

If the Section 9 negotiated DCAT-AP feature is supported, this service's
`dct:conformsTo` values MUST additionally include the negotiated DCAT-AP
feature IRI and the DCAT-AP 3.0.1 profile IRI, each typed `dct:Standard`.

Each distribution MUST identify that same service through `accessService`.
An embedded copy and the root copy, if both contain metadata, MUST be
identical after RDF node merging.

`endpointURL` MUST remain the DSP-required JSON string. A Provider MUST NOT
replace it with a JSON-LD `@id` object in an attempt to make the DSP response
DCAT-conformant, because doing so violates the DSP JSON Schema.

### 8.7 Optional byte size and checksum

When present, byte size MUST be the number of octets in the representation at
the public download URL. It MUST use an explicit JSON-LD value object whose
`@type` is the full `xsd:nonNegativeInteger` IRI:

```json
{
  "dcat:byteSize": {
    "@value": "12345",
    "@type": "http://www.w3.org/2001/XMLSchema#nonNegativeInteger"
  }
}
```

The lexical value MUST be a canonical non-negative integer: `0`, or a sequence
beginning with `1` through `9` followed by zero or more decimal digits. A bare
JSON number is not conforming because JSON-LD expansion would assign a
different RDF datatype. This is the required RDF range for DCAT-AP
[Distribution byte size](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#Distribution.bytesize).

The SHA-256 digest MUST be exactly 64 lower-case hexadecimal characters and
use algorithm IRI:

```text
https://spdx.org/rdf/terms#checksumAlgorithm_sha256
```

The two values are independently OPTIONAL. They may become stale if a mutable
file is replaced; the Provider SHOULD update them promptly.

Because the DSP context defines neither `spdx` nor its checksum terms, a
checksum in a DSP response MUST use full IRIs, as follows:

```json
{
  "http://spdx.org/rdf/terms#checksum": {
    "@type": "http://spdx.org/rdf/terms#Checksum",
    "http://spdx.org/rdf/terms#algorithm": {
      "@id": "https://spdx.org/rdf/terms#checksumAlgorithm_sha256"
    },
    "http://spdx.org/rdf/terms#checksumValue": {
      "@value": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      "@type": "http://www.w3.org/2001/XMLSchema#hexBinary"
    }
  }
}
```

## 9. Discovery of Materials Commons DCAT-AP Tier 1

### 9.1 Optional capabilities

A Tier 1 Provider MAY expose a strict DCAT-AP catalogue by separately
conforming to **Materials Commons DCAT-AP Tier 1**. Absence of that service does
not affect DSP Tier 1 conformance.

If the companion service is present, it MUST be discoverable both:

1. through the well-known discovery mechanism required by Materials Commons
   DCAT-AP Tier 1; and
2. through a `DataService` in the root DSP catalogue `service` array as defined
   in Section 9.2.

A Provider exposing that companion service SHOULD also expose the
content-negotiated representation in Sections 9.3 through 9.5. Support for the
content-negotiated representation is OPTIONAL for DSP Tier 1 conformance. If
it is supported, every requirement stated for it in this section is mandatory
and its availability MUST be advertised in the DSP catalogue. It MUST NOT be
advertised unless the companion `GET` service is also present.

### 9.2 Companion `GET` service advertisement

The companion service advertisement MUST contain:

| Member | Cardinality | Requirement |
|---|---:|---|
| `@id` | `1` | Stable absolute service IRI |
| `@type` | `1` | `DataService` |
| `dct:title` | `1` | Non-empty service title |
| `endpointURL` | `1` | Absolute HTTPS companion catalogue endpoint |
| `dct:conformsTo` | `2..*` | `dct:Standard` IRI objects including both required profiles |
| `dcat:servesDataset` | `1..*` | IRI objects for datasets in this DSP snapshot |

`dct:conformsTo` MUST include both:

```text
tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-1
https://semiceu.github.io/DCAT-AP/releases/3.0.1/
```

The exact Materials Commons profile IRI is the machine-readable discriminator.
A Consumer MUST NOT identify the service from its title, path, hostname, or
media type alone.

Each `dct:conformsTo` object MUST include `@type` equal to `dct:Standard` so
that the common payload satisfies the DCAT-AP range constraint.

`endpointURL` MUST be the URL whose `GET` response is the companion catalogue.
No relationship between that URL and `<root>` or `<base>` is required. It MAY
be on another HTTPS origin.

Every `dcat:servesDataset` value MUST identify a dataset in the current DSP
snapshot. Every DSP dataset MUST be listed.

### 9.3 Negotiated DCAT-AP feature advertisement

Support for the alternate `application/ld+json` representation MUST be
advertised on the existing DSP access service from Section 8.6. A Provider
MUST NOT invent a second distribution access service for this purpose.

The DSP access service's `dct:conformsTo` array MUST contain typed Standard
objects for at least these four identifiers:

```text
tag:materialscommons.eu,2026:dsp/prototype-tier-1
https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/
tag:materialscommons.eu,2026:dsp/prototype-tier-1#dcat-ap-content-negotiation
https://semiceu.github.io/DCAT-AP/releases/3.0.1/
```

Each value MUST be an `@id` object with `@type` equal to `dct:Standard`. The
third IRI is the machine-readable feature discriminator. A Consumer that
recognizes it learns the HTTP method, request type, media type, context
substitution, and identity invariant from this section; it MUST NOT infer
support merely from an `application/ld+json` string, service title, or URL
pattern.

The DSP access service's `endpointURL` remains `<base>`, as required by DSP.
The feature operation is the standard DSP catalogue request target obtained by
appending `/catalog/request`. Advertising a capability of the existing
Connector through typed extension metadata neither changes the meaning of the
DSP service nor introduces a non-DSP route.

A compatible Consumer discovers the feature without path guessing:

1. derive `<base>` and the DSP access-service identifier through DSP version
   discovery;
2. request the ordinary DSP catalogue;
3. locate the root `service` whose `@id` equals that advertised service
   identifier and verify the exact feature IRI in its `dct:conformsTo` values;
   and
4. repeat the catalogue request at `<base>/catalog/request` using the explicit
   `Accept` rule in Section 9.4.

### 9.4 Content-negotiated retrieval

A Consumer invokes the advertised operation by sending a valid DSP
`CatalogRequestMessage` to `<base>/catalog/request`, where `<base>` is the
advertised DSP access-service `endpointURL`, using:

```http
Content-Type: application/json
Accept: application/ld+json
```

For this feature, an explicit JSON-LD request means an `Accept` field
containing exactly one acceptable media range, `application/ld+json`, with an
optional `profile` parameter equal to the DCAT-AP 3.0.1 profile IRI and with no
quality value other than `1`. An absent `Accept`, `*/*`,
or an `Accept` field that permits `application/json` but does not meet the
explicit JSON-LD rule selects the ordinary DSP response. A list containing any
other media range MUST NOT accidentally select the alternate representation.
When such a list excludes `application/json`, normal HTTP negotiation MAY
produce `406 Not Acceptable`.

For a valid explicit JSON-LD request, a Provider advertising this feature MUST
return `200 OK` with:

```http
Content-Type: application/ld+json; profile="https://semiceu.github.io/DCAT-AP/releases/3.0.1/"
Vary: Accept
```

The response SHOULD also contain:

```http
Link: <tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-1>; rel="profile"
```

The response is an additional Materials Commons DCAT-AP representation, not a
DSP response message. Ordinary DSP catalogue requests and all DSP error
messages continue to use `application/json` as required by DSP. A Provider
that does not advertise this feature MAY return `406 Not Acceptable` for a
request that accepts only `application/ld+json`.

### 9.5 Common-payload and context-substitution invariant

For one catalogue snapshot, the ordinary DSP response, the negotiated
DCAT-AP response, and the companion `GET` response MUST have the same Common
catalogue value. No dataset, service, policy, distribution, metadata property,
or conformance value may be added, removed, or changed between those
representations.

The negotiated and companion responses MUST replace the complete top-level
DSP `@context`; they MUST NOT attempt to override terms in the protected DSP
context. Their owned context MUST include the equivalent of:

```json
{
  "dcat": "http://www.w3.org/ns/dcat#",
  "endpointURL": {
    "@id": "dcat:endpointURL",
    "@type": "@id"
  }
}
```

Every other compact term used by the Common catalogue value MUST expand to the
same RDF predicate, class, or resource under both contexts. Consequently, the
only RDF change caused by context substitution MUST be replacement of each
literal `dcat:endpointURL` value by the IRI with the same lexical form.

Structural identity is normative, not byte identity. Object-member order,
whitespace, escaping choices, and RDF-irrelevant array order MAY differ. If
metadata changes between separate requests, each response MUST still describe
one internally consistent snapshot; a Provider SHOULD use validators or
snapshot identifiers that allow a Consumer to determine whether two responses
refer to the same snapshot.

The DCAT-AP response MUST NOT add a catalogue-level `dct:conformsTo` assertion
that is absent from the DSP response. DCAT-AP 3.0.1 does not require that
property on a Catalogue. Conformance of the alternate representation is
identified by its media-type profile, `Link` header, discovery record, and the
typed service-level `dct:conformsTo` statements above.

### 9.6 Advertisement example

The following is non-normative:

```json
[
  {
    "@id": "https://provider.example/services/mc-dcat-ap",
    "@type": "DataService",
    "dct:title": "Public Materials Commons DCAT-AP catalogue",
    "endpointURL": "https://provider.example/mc-dcat-ap/3.0.1/",
    "dct:conformsTo": [
      {
        "@id": "tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-1",
        "@type": "dct:Standard"
      },
      {
        "@id": "https://semiceu.github.io/DCAT-AP/releases/3.0.1/",
        "@type": "dct:Standard"
      }
    ],
    "dcat:servesDataset": [
      {"@id": "https://provider.example/datasets/example"}
    ]
  },
  {
    "@id": "https://provider.example/services/dsp",
    "@type": "DataService",
    "dct:title": "Public DSP service",
    "endpointURL": "https://provider.example/dsp/2025-1",
    "dct:conformsTo": [
      {
        "@id": "tag:materialscommons.eu,2026:dsp/prototype-tier-1",
        "@type": "dct:Standard"
      },
      {
        "@id": "https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/",
        "@type": "dct:Standard"
      },
      {
        "@id": "tag:materialscommons.eu,2026:dsp/prototype-tier-1#dcat-ap-content-negotiation",
        "@type": "dct:Standard"
      },
      {
        "@id": "https://semiceu.github.io/DCAT-AP/releases/3.0.1/",
        "@type": "dct:Standard"
      }
    ],
    "dcat:servesDataset": [
      {"@id": "https://provider.example/datasets/example"}
    ]
  }
]
```

The example path `/mc-dcat-ap/3.0.1/` is not normative.

### 9.7 Consistency with the companion

When both protocols are exposed, their catalogue identifier, publisher,
dataset identifiers, titles, descriptions, policies, distribution identifiers,
public download URLs, formats, media types, byte sizes, checksums, and services
MUST agree for the same snapshot in accordance with Section 9.5.

Temporary differences caused by independently completed requests SHOULD be
minimized. A Provider MUST NOT deliberately advertise contradictory values.

## 10. Public HTTPS data plane

### 10.1 Direct public access

Every distribution access and download URL MUST resolve to the same direct
public representation. It MUST be retrievable without negotiation, agreement,
transfer process, authorization header, cookie, credential, or access token.

The DSP negotiation and transfer flow remains available for control-plane
interoperability but does not gate the public URL.

### 10.2 HTTP behavior

The public distribution endpoint:

- MUST support `GET`;
- MUST support `HEAD` with the same representation metadata and no body;
- MUST return the advertised `Content-Type`;
- MUST report `Content-Length` when known;
- SHOULD support byte ranges and `206 Partial Content`;
- SHOULD provide `ETag`, `Last-Modified`, or both; and
- MUST return ordinary HTTP errors, including `404 Not Found`, when absent.

File routing and DSP declarations are independent. The Provider MUST ensure
that an advertised URL refers to the intended public representation.

## 11. Contract negotiation

### 11.1 Applicability and identifiers

Tier 1 retains DSP negotiation for protocol interoperability, not access
enforcement. The Provider MUST implement the DSP
[Contract Negotiation Protocol](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#negotiation-protocol)
for the Section 8.4 offer.

Each process MUST receive a unique `providerPid`. Provider-created process and
agreement identifiers SHOULD be `urn:uuid:` IRIs.

An initial request MUST contain a non-empty `consumerPid`, HTTPS
`callbackAddress`, and exact selected offer, and MUST omit `providerPid`.
Callback URLs MUST be absolute HTTPS URLs without user information, query, or
fragment.

### 11.2 Offer validation

The Provider MUST accept only an offer that:

1. uses a currently advertised offer `@id`;
2. has one top-level `target` equal to that offer's dataset;
3. has `@type` equal to `Offer`;
4. contains exactly the unconditional `use` permission;
5. contains no nested target; and
6. is otherwise structurally equal to the advertised policy.

Unknown, modified, constrained, or retargeted offers MUST return
`400 ContractNegotiationError`.

### 11.3 States and direct-agreement flow

The Provider MUST enforce the DSP
[negotiation states](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#contract-negotiation-states):
`REQUESTED`, `OFFERED`, `ACCEPTED`, `AGREED`, `VERIFIED`, `FINALIZED`, and
`TERMINATED`. `FINALIZED` and `TERMINATED` are terminal.

The required happy path is:

1. Consumer posts a valid `ContractRequestMessage` to
   `<base>/negotiations/request`.
2. Provider creates `REQUESTED` and returns `201 Created` with
   `ContractNegotiation`.
3. Provider sends `ContractAgreementMessage` to
   `{callbackAddress}/negotiations/{consumerPid}/agreement`.
4. Provider commits `AGREED` only after a `2xx` acknowledgement.
5. Consumer posts `ContractAgreementVerificationMessage` to the verification
   endpoint.
6. Provider returns `200 OK` and commits `VERIFIED`.
7. Provider sends a `FINALIZED` negotiation event to the Consumer callback.
8. Provider commits `FINALIZED` only after a `2xx` acknowledgement.

Callback paths follow the DSP
[Consumer Path Bindings](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#consumer-path-bindings).

### 11.4 Optional offer branch

The Provider MAY send the unchanged offer to the Consumer offers callback and
commit `OFFERED` after acknowledgement. In `OFFERED`, the Consumer MAY send an
`ACCEPTED` event or return the exact same offer as a counter-request. Tier 1
does not permit changed terms.

### 11.5 Agreement

The Agreement MUST contain a unique `@id`, `@type` equal to `Agreement`, target
equal to one catalogue dataset, assigner equal to the Provider participant,
assignee equal to the Consumer process identifier, a UTC XML Schema `dateTime`,
and the same unconditional permission. Rules inside the Agreement MUST NOT
have their own targets.

### 11.6 Status, termination, and callbacks

`GET <base>/negotiations/{providerPid}` MUST return the current acknowledged
state or `404`. Either party MAY terminate a nonterminal process. All route and
message process identifiers MUST match. Invalid transitions or mismatches MUST
return `400` without changing state.

An outbound state MUST NOT be committed before its callback receives `2xx`.
A failed callback SHOULD be attempted once more, for at most two attempts.
After final failure, the Provider SHOULD attempt termination and MUST NOT
report the unacknowledged target state.

## 12. Transfer process

### 12.1 Preconditions and request

A transfer MUST refer to a current Agreement in `FINALIZED` whose target is a
currently published dataset. The Provider MUST implement DSP
[Transfer Process Protocol](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#transfer-protocol)
as finite public HTTPS pull.

`POST <base>/transfers/request` MUST accept a `TransferRequestMessage` with the
official context, correct type, non-empty `consumerPid`, finalized
`agreementId`, HTTPS callback address, and exact distribution format. It MUST
NOT contain `dataAddress`. A new valid request returns `201 Created` with state
`REQUESTED`.

### 12.2 Idempotency

Transfer requests MUST be idempotent by `consumerPid`. Repeating the same
consumer PID, agreement, callback, and format MUST return the existing process.
Reusing it with different values MUST return `400` and preserve the process.

### 12.3 Start and DataAddress

After the initial response, the Provider MUST send `TransferStartMessage` to:

```text
{callbackAddress}/transfers/{consumerPid}/start
```

It MUST include both process identifiers and:

```json
{
  "@type": "DataAddress",
  "endpointType": "https://w3id.org/idsa/v4.1/HTTP",
  "endpoint": "https://provider.example/files/dataset.csv"
}
```

`endpoint` MUST equal the resolved public access and download URL.
`endpointProperties` MUST NOT convey authorization, credentials, cookies, or
tokens. The Provider commits `STARTED` only after `2xx` acknowledgement. This
implements DSP
[pull transfer](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#pull-transfer).

### 12.4 States and provider endpoints

The Provider MUST enforce DSP
[transfer states](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#transfer-process-states):
`REQUESTED`, `STARTED`, `SUSPENDED`, `COMPLETED`, and `TERMINATED`.

| From | Action | To |
|---|---|---|
| — | Valid initial request | `REQUESTED` |
| `REQUESTED` | Start callback acknowledged | `STARTED` |
| `STARTED` | Suspension acknowledged | `SUSPENDED` |
| `SUSPENDED` | Start acknowledged | `STARTED` |
| `STARTED` | Completion acknowledged | `COMPLETED` |
| `REQUESTED`, `STARTED`, or `SUSPENDED` | Termination acknowledged | `TERMINATED` |

`COMPLETED` and `TERMINATED` are terminal. The status, start, suspension,
completion, and termination endpoints in Section 5.2 MUST enforce these
transitions and exact process-identifier matching. Invalid operations return
`400 TransferError` without state change; unknown processes return `404`.

Outbound transfer state is committed only after the corresponding DSP
[Consumer Callback](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#consumer-callback-path-bindings)
returns `2xx`.

## 13. Errors and HTTP status codes

Catalogue, negotiation, and transfer errors MUST respectively use
`CatalogError`, `ContractNegotiationError`, and `TransferError`, with the
official context and exact type. A safe non-empty reason SHOULD be supplied.
Known process identifiers MUST be included where the schema requires them.

| Status | Use |
|---:|---|
| `200 OK` | Successful retrieval or accepted non-creating transition |
| `201 Created` | New negotiation or transfer process |
| `400 Bad Request` | Invalid message, unsupported feature, mismatch, or invalid transition |
| `404 Not Found` | Unknown dataset, negotiation, transfer, or agreement where applicable |
| `406 Not Acceptable` | No acceptable catalogue representation, including an unsupported JSON-LD-only request |
| `409 Conflict` | Optional concurrent-transition conflict |
| `502 Bad Gateway` | Optional failure of a required synchronous callback |

Tier 1 endpoints and public distributions MUST NOT return `401` or `403`
merely because `Authorization` is absent. Unexpected errors MAY return `500`
without exposing implementation details.

## 14. Security and privacy

### 14.1 Public access and TLS

Tier 1 selects the unauthenticated option permitted by DSP
[Authorization](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#authorization).
Catalogue content and public data MUST NOT vary by caller identity or
credentials. All public and callback traffic MUST use HTTPS with certificate
and hostname validation.

### 14.2 Callback safety

Callback addresses are untrusted outbound destinations. A Provider MUST:

- reject user information, query, fragments, and non-HTTPS schemes;
- reject loopback, link-local, private, multicast, unspecified, reserved, and
  other non-public addresses;
- validate every resolved address and protect against DNS rebinding;
- not follow a redirect to an unvalidated destination;
- bound connection, read, response-body, and header resources; and
- not forward ambient credentials, cookies, proxy credentials, or secrets.

Explicitly trusted private callback networks are outside public Internet Tier 1
conformance.

### 14.3 Data minimization

Responses MUST NOT expose local paths, database identifiers, internal network
addresses, credentials, tokens, stack traces, or private participant data.

## 15. State, consistency, and lifecycle

Every request MUST use one internally consistent catalogue snapshot. The
Provider MUST validate identifier uniqueness and shared publisher identity
before emitting a catalogue or resolving a process.

Metadata MAY change between requests. Negotiation and transfer operations MUST
resolve the publication against the current snapshot. A removed dataset MUST
not silently resolve to another dataset.

Tier 1 does not require process state to survive restart. After state loss, an
unknown prior process returns `404`; the Consumer MAY begin again. Within one
process lifetime, transitions MUST be concurrency-safe and stale callbacks
MUST NOT overwrite newer acknowledged state.

## 16. Extensibility

DSP messages MAY contain extension properties permitted by upstream schemas,
provided they do not redefine protected terms or alter Tier 1 semantics.

Additional publication metadata MAY use DCAT, DCTERMS, FOAF, SPDX, or another
vocabulary. Such use does not by itself create a DCAT conformance claim. It
MUST preserve the Section 9.5 Common catalogue value when an alternate
representation is supplied. Extension metadata MUST NOT:

- require authentication;
- make the unconditional offer conditional;
- replace the direct public download with a landing page;
- introduce push behavior under a Tier 1 format value;
- weaken checksum or media-type semantics; or
- contradict the DSP resource carrying it.

## 17. Conformance checklist

### 17.1 Discovery and transport

- [ ] All endpoints use HTTPS.
- [ ] `<root>/.well-known/dspace-version` is unversioned and unauthenticated.
- [ ] The response advertises version `2025-1`, binding `HTTPS`, a valid path,
      and the DSP service ID, with no `auth`.
- [ ] Consumers can derive `<base>` without assuming its path.
- [ ] DSP bodies use `application/json`, the official context, and schemas.
- [ ] No `GET <base>/catalog` endpoint is required for conformance.
- [ ] The expanded catalogue passes pinned DCAT-AP mandatory, range, and
      controlled-vocabulary validation except only for literal-valued
      `dcat:endpointURL`.

### 17.2 Catalogue and publication

- [ ] `POST <base>/catalog/request` returns the complete catalogue.
- [ ] Non-empty filters return `400 CatalogError`.
- [ ] At least one dataset is present and no pagination is required.
- [ ] Dataset, offer, distribution, and service IDs are stable and unique.
- [ ] All datasets share one publisher.
- [ ] Each dataset has one unconditional offer and one public distribution.
- [ ] Format, media type, access URL, and direct download URL are present with
      the required RDF classes and ranges.
- [ ] Every format is explicitly typed `dct:MediaTypeOrExtent`.
- [ ] Every media type is explicitly typed `dct:MediaType`.
- [ ] Known byte sizes are explicitly typed `xsd:nonNegativeInteger`, and
      checksums use the required SPDX and XML Schema types.
- [ ] The root DSP access service identifies every served dataset and the
      standards to which it conforms.
- [ ] Individual dataset retrieval returns the same metadata or `404`.
- [ ] The DSP response makes no DCAT or DCAT-AP conformance claim.

### 17.3 Optional DCAT-AP companion

- [ ] If no companion is offered, DSP Tier 1 remains fully conformant.
- [ ] If offered, root `service` contains the exact companion profile and
      DCAT-AP 3.0.1 IRIs.
- [ ] The advertised endpoint is absolute HTTPS and path-independent.
- [ ] Served dataset identifiers refer to the current DSP snapshot.
- [ ] The endpoint also satisfies Materials Commons DCAT-AP Tier 1 well-known
      discovery and conformance requirements.
- [ ] If negotiated DCAT-AP is supported, the DSP access service contains the
      exact feature and DCAT-AP profile IRIs while retaining `<base>` as its
      `endpointURL`.
- [ ] Exact `Accept: application/ld+json` returns the profiled JSON-LD media
      type and `Vary: Accept`.
- [ ] The DSP, negotiated, and companion responses have structurally identical
      Common catalogue values for the same snapshot.
- [ ] Context substitution changes only literal `dcat:endpointURL` values into
      IRIs, and the substituted graph passes full DCAT-AP validation.

### 17.4 Negotiation and transfer

- [ ] Only the exact advertised unconditional offer is accepted.
- [ ] Agreement and finalization callbacks are supported.
- [ ] Agreements have unique ID, target, parties, UTC time, and permission.
- [ ] Transfers require a finalized agreement for a current dataset.
- [ ] Requested format exactly matches the selected distribution.
- [ ] Consumer data addresses are rejected.
- [ ] Start supplies the public HTTPS DataAddress.
- [ ] Requests are idempotent by `consumerPid`.
- [ ] Invalid transitions are rejected without state change.
- [ ] Outbound states commit only after `2xx` callback acknowledgement.

## Appendix A. Minimal examples (non-normative)

### A.1 Catalogue request

```http
POST /dsp/2025-1/catalog/request HTTP/1.1
Host: provider.example
Content-Type: application/json
Accept: application/json

{
  "@context": ["https://w3id.org/dspace/2025/1/context.jsonld"],
  "@type": "CatalogRequestMessage",
  "filter": []
}
```

### A.2 Dataset with DCAT-AP-aligned metadata

```json
{
  "@id": "https://provider.example/datasets/example",
  "@type": "Dataset",
  "dct:title": "Example materials dataset",
  "dct:description": "A public example dataset.",
  "dct:publisher": {
    "@id": "https://provider.example/participants/provider",
    "@type": "http://xmlns.com/foaf/0.1/Agent",
    "http://xmlns.com/foaf/0.1/name": "Example Provider"
  },
  "hasPolicy": [{
    "@id": "https://provider.example/datasets/example#offer",
    "@type": "Offer",
    "permission": [{"action": "use"}]
  }],
  "distribution": [{
    "@id": "https://provider.example/datasets/example#distribution",
    "@type": "Distribution",
    "format": "http://publications.europa.eu/resource/authority/file-type/CSV",
    "dct:format": {
      "@id": "http://publications.europa.eu/resource/authority/file-type/CSV",
      "@type": "dct:MediaTypeOrExtent"
    },
    "dcat:mediaType": {
      "@id": "https://www.iana.org/assignments/media-types/text/csv",
      "@type": "dct:MediaType"
    },
    "dcat:accessURL": {"@id": "https://provider.example/files/example.csv"},
    "dcat:downloadURL": {"@id": "https://provider.example/files/example.csv"},
    "dcat:byteSize": {
      "@value": "12345",
      "@type": "http://www.w3.org/2001/XMLSchema#nonNegativeInteger"
    },
    "accessService": {
      "@id": "https://provider.example/services/dsp",
      "@type": "DataService",
      "dct:title": "Public DSP service",
      "endpointURL": "https://provider.example/dsp/2025-1",
      "dct:conformsTo": [
        {
          "@id": "tag:materialscommons.eu,2026:dsp/prototype-tier-1",
          "@type": "dct:Standard"
        },
        {
          "@id": "https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/",
          "@type": "dct:Standard"
        }
      ],
      "dcat:servesDataset": [
        {"@id": "https://provider.example/datasets/example"}
      ]
    }
  }]
}
```

### A.3 Negotiation request

```json
{
  "@context": ["https://w3id.org/dspace/2025/1/context.jsonld"],
  "@type": "ContractRequestMessage",
  "consumerPid": "urn:uuid:11111111-1111-4111-8111-111111111111",
  "callbackAddress": "https://consumer.example/dsp-callback",
  "offer": {
    "@id": "https://provider.example/datasets/example#offer",
    "@type": "Offer",
    "target": "https://provider.example/datasets/example",
    "permission": [{"action": "use"}]
  }
}
```

### A.4 Transfer request and start

```json
{
  "@context": ["https://w3id.org/dspace/2025/1/context.jsonld"],
  "@type": "TransferRequestMessage",
  "consumerPid": "urn:uuid:22222222-2222-4222-8222-222222222222",
  "agreementId": "urn:uuid:33333333-3333-4333-8333-333333333333",
  "format": "http://publications.europa.eu/resource/authority/file-type/CSV",
  "callbackAddress": "https://consumer.example/dsp-callback"
}
```

```json
{
  "@context": ["https://w3id.org/dspace/2025/1/context.jsonld"],
  "@type": "TransferStartMessage",
  "providerPid": "urn:uuid:44444444-4444-4444-8444-444444444444",
  "consumerPid": "urn:uuid:22222222-2222-4222-8222-222222222222",
  "dataAddress": {
    "@type": "DataAddress",
    "endpointType": "https://w3id.org/idsa/v4.1/HTTP",
    "endpoint": "https://provider.example/files/example.csv"
  }
}
```

## Appendix B. Normative references

- **DSP 2025-1-err1** — [Dataspace Protocol 2025-1, errata revision 1](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/).
- **DCAT 3** — [Data Catalog Vocabulary (DCAT), Version 3](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/).
- **DCAT-AP 3.0.1** — [DCAT Application Profile for data portals in Europe, Version 3.0.1](https://semiceu.github.io/DCAT-AP/releases/3.0.1/).
- **JSON-LD 1.1** — [JSON-LD 1.1](https://www.w3.org/TR/json-ld11/).
- **ODRL** — [ODRL Information Model 2.2](https://www.w3.org/TR/odrl-model/).
- **SHACL** — [Shapes Constraint Language](https://www.w3.org/TR/shacl/).
- **RFC 2119** — [Key words for use in RFCs to Indicate Requirement Levels](https://www.rfc-editor.org/rfc/rfc2119).
- **RFC 8174** — [Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words](https://www.rfc-editor.org/rfc/rfc8174).
- **RFC 8615** — [Well-Known Uniform Resource Identifiers](https://www.rfc-editor.org/rfc/rfc8615).
- **RFC 9110** — [HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110).

## Appendix C. Informative references

- **Materials Commons DCAT-AP GET Protocol Tier 1** — [Companion protocol](materials-commons-dcat-ap-get-protocol-tier-1.md).
