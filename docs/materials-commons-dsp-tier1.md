# PROTOTYPE DRAFT FOR DISCUSSION: Materials Commons DSP Tier 1 (Public Datasets and Services)

## Status of this document

This document defines **Materials Commons DSP Tier 1**, a provider-side
interoperability profile for unauthenticated catalogues of public datasets and
services.

**Tier 1 covers the Dataspace Protocol catalogue only.** It implements the DSP
catalogue schema, the catalogue request and dataset request interaction, and
catalogue pagination. It implements no part of contract negotiation and no part
of the transfer process. **A Tier 1 Provider therefore does not conform to the
Dataspace Protocol and MUST NOT claim that it does.** Section 1.3 states what it
does conform to, and Section 2.3 lists what is excluded.

This document is a normative specification. It profiles the catalogue part of
[Dataspace Protocol 2025-1, errata revision 2](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/)
and uses terms from
[DCAT 3](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/)
and [ODRL 2.2](https://www.w3.org/TR/odrl-model/). Where this document imposes
a narrower requirement than DSP 2025-1, the narrower requirement applies to
Materials Commons DSP Tier 1 conformance. Within the catalogue messages it
serves, this document relaxes no DSP requirement.

DCAT-AP is served from the same catalogue endpoint, selected by an explicit
profile parameter, as specified in Section 9. The DSP and DCAT-AP
representations carry the same complete catalogue JSON value except for
`@context`, after assembling pages when pagination is used; changing that
context repairs the one unavoidable RDF literal-versus-IRI conflict imposed by
DSP. The separately specified
[Materials Commons DCAT-AP GET Protocol Tier 0](materials-commons-dcat-ap-get-protocol-tier-0.md)
offers the same graph to conventional harvesters over `GET`. Conformance to
that protocol is an independent claim and is not required for conformance to
this document.

## Abstract

Materials Commons DSP Tier 1 defines a small, deterministic catalogue profile
for datasets and services that are already public. It takes the catalogue
schema and the catalogue interaction of the Dataspace Protocol and leaves the
rest of the protocol out, so that publishing a machine-readable catalogue does
not require operating a connector.

It provides:

1. unauthenticated DSP version discovery;
2. unauthenticated DSP catalogue and individual-dataset discovery, with
   required catalogue pagination;
3. one unconditional ODRL `use` offer and one or more public HTTPS
   distributions for each dataset;
4. a direct, unauthenticated HTTPS download for every distribution;
5. DCAT-AP 3.0.1-compatible catalogue metadata, with `dcat:endpointURL` as the
   single unavoidable RDF range exception imposed by DSP;
6. a DCAT-AP representation of the same catalogue value, selected at the same
   endpoint by an explicit profile parameter and obtained by replacing only the
   DSP context; and
7. an optional DSP-native advertisement of a Materials Commons DCAT-AP Tier 0
   companion service.

Tier 1 excludes contract negotiation, the transfer process, authentication,
authorization, confidential or embargoed datasets, policy constraints,
catalogue filters, proof exchange, and broker replication. Because negotiation
and transfer are out, a Tier 1 Provider makes no Dataspace Protocol conformance
claim.

The DSP `application/json` response does not claim DCAT-AP conformance either,
because its official context necessarily expands `dcat:endpointURL` as an RDF
literal. The profiled `application/ld+json` representation makes the complete
DCAT-AP conformance claim without changing the catalogue payload.

Required pagination is what distinguishes this tier from a static catalogue
document. A catalogue of several million datasets has no pre-computed form; it
is produced from search results per request and returned a page at a time.

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
conforming Provider implements the provider-side HTTPS catalogue endpoints,
catalogue messages, resource model, pagination, representation selection, and
public data plane defined by this document.

A Provider MAY additionally conform to Materials Commons DCAT-AP Tier 0. That
is an independent conformance claim and MUST NOT be inferred merely because a
DSP catalogue contains DCAT terms. It MAY be inferred from the exact
machine-readable service advertisement defined in Section 9.

### 1.3 Relationship to DSP conformance

A Tier 1 Provider does **not** conform to the Dataspace Protocol, and MUST NOT
state or imply that it does. Conformance to DSP covers contract negotiation and
the transfer process, and Tier 1 implements neither. There is also no narrower
claim available: DSP defines no conformance class for a catalogue service on
its own, so "DSP catalogue conformance" is not a statement that can be made
against the specification.

What a Tier 1 Provider does conform to is this profile. Within it:

1. every catalogue message a Provider sends or accepts MUST validate against
   the official DSP 2025-1 JSON Schema for its message or resource type;
2. every such message MUST use the protected official DSP JSON-LD context
   unchanged; and
3. the catalogue request, dataset request, error, and pagination behavior MUST
   follow the DSP Catalog Protocol and its HTTPS binding, as narrowed by this
   document.

Those three obligations are the reason a DSP-native consumer can read a Tier 1
catalogue without special handling. They stop at the catalogue. A consumer MUST
NOT expect a Tier 1 Provider to answer a `ContractRequestMessage` or a
`TransferRequestMessage`, and MUST NOT treat the absence of those endpoints as
a protocol error.

The applicable requirements of the
[DSP conformance section](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#conformance)
are met for the catalogue messages covered above. The requirements that section
places on a Connector are out of scope.

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
[Schemas and Contexts](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#schemas-contexts),
the DSP
[DataService requirements](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#ack-dataset),
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
4. the DSP `application/json` response MUST NOT claim that its own RDF graph
   conforms to DCAT or DCAT-AP. The catalogue-level `dct:conformsTo` values
   required by Section 7.2 describe the common catalogue value and its
   context-substituted DCAT-AP representation, not the expansion of the DSP
   response itself;
5. the profiled DCAT-AP representation MUST change only the top-level
   `@context`, the HTTP representation headers, and serialization details that
   do not change the JSON value; and
6. expansion under that alternate context MUST satisfy all applicable
   DCAT-AP 3.0.1 constraints without exception.

When pagination is used, RDF conformance and complete-catalogue equality
apply to the snapshot reconstructed under Section 7.5. Each DSP page MUST
still satisfy its JSON Schema, and corresponding DSP and negotiated DCAT-AP
pages differ only as permitted by Section 9.5.

The JSON-LD context is a mapping mechanism, not a complete validation
language. Requirements such as class membership of an EU File Type concept
are therefore stated normatively here and asserted explicitly in the payload,
even though the official DSP context does not enforce them.

The separate **Materials Commons DCAT-AP Tier 0** protocol supplies a
well-known-discoverable `GET` operation for conventional DCAT harvesters. The
profiled representation in Section 9 gives DSP-aware clients the same graph
from the DSP catalogue endpoint, without inventing `GET <base>/catalog`.

## 2. Scope

### 2.1 Purpose

Tier 1 is intended for a provider that publishes datasets and public services
for unrestricted discovery and retrieval, including a catalogue too large to
pre-compute. A consumer can discover and download a Tier 1 dataset without
credentials, tokens, proofs, or prior authorization.

Contract Negotiation and Transfer Process are outside this tier. A consumer
reaches the bytes through the direct download URL that every distribution
carries, which is also what makes those two protocols unnecessary here: there
is no access decision for them to carry out.

### 2.2 Included capabilities

Tier 1 includes:

- DSP 2025-1 version discovery over HTTPS;
- the provider-side DSP catalogue endpoints, meaning the catalogue request and
  the dataset request;
- complete-catalogue retrieval without server-side filtering, across pages
  using DSP HTTP `Link` pagination, which is required at this tier;
- retrieval of one dataset description by its exact identifier;
- one or more public distributions per dataset, with distinct format values;
- a direct, unauthenticated HTTPS download for every distribution;
- an unconditional ODRL permission to perform the `use` action, carried because
  the DSP catalogue schema requires a policy on every dataset;
- DCAT-AP-compatible publication metadata for formats, media types, licences,
  direct download URLs, optional byte sizes, and optional SHA-256 checksums;
- retrieval of a context-substituted DCAT-AP representation from the DSP
  catalogue request target, selected by an explicit profile parameter; and
- optional discovery of a Materials Commons DCAT-AP Tier 0 service through the
  DSP catalogue.

### 2.3 Excluded capabilities

The following are outside Tier 1:

- contract negotiation in every form, including the provider negotiation
  endpoints, agreements, and the negotiation state machine;
- the transfer process in every form, including the provider transfer
  endpoints, `TransferStartMessage`, `DataAddress`, and the transfer state
  machine;
- any obligation to initiate an HTTP request to a consumer `callbackAddress`;
- authentication and authorization requirements;
- access tokens in DSP messages or data addresses;
- restricted, confidential, embargoed, or participant-specific catalogues;
- ODRL constraints, duties, obligations, and prohibitions;
- server-side catalogue filtering or query languages;
- catalogue proof-metadata endpoints;
- DID-based service discovery requirements;
- catalogue brokers and catalogue replication;
- a Dataspace Protocol conformance claim, per Section 1.3; and
- a DCAT 3 or DCAT-AP conformance claim for the RDF graph obtained by expanding
  the DSP `application/json` response under the official DSP context. The
  catalogue still carries the `dct:conformsTo` values of Section 7.2, which
  describe the common catalogue value rather than that expansion.

The first three exclusions are the substantive change from earlier drafts of
this profile, which required the full provider endpoint set. The requirements
those drafts stated are retained as Sections 11 and 12, where they now apply
only to a Provider that chooses to implement the flows on top of Tier 1, and
they are expected to move to the Tier 2 profile.

An implementation MAY provide excluded capabilities in another profile or
tier. They MUST NOT be required to access a Tier 1 dataset or alter the
semantics of a Tier 1 endpoint.

## 3. Terminology

Terms defined by the
[DSP terms and definitions](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#terminology)
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
- **DSP access service** means the DSP `DataService` that answers the catalogue
  and dataset requests at `<base>`. DSP positions this service as the one at
  which negotiation and transfer are initiated; a Tier 1 Provider operates its
  catalogue half only, as stated in Section 8.6.
- **DCAT-AP companion service** means an optional service conforming to
  Materials Commons DCAT-AP Tier 0 and advertised as specified in Section 9.
- **Public distribution** means a distribution whose direct HTTPS URL is usable
  without authentication or authorization.
- **Catalogue snapshot** means one internally consistent complete catalogue
  and the dataset, offer, distribution, publisher, and service metadata used
  to construct it. A response MAY carry the whole snapshot or one page of it.
- **Common catalogue value** means the JSON value of a catalogue snapshot
  after assembling any pages as specified in Section 7.5 and removing its
  top-level `@context` member. Object-member order,
  insignificant whitespace, and equivalent JSON number spellings are not
  part of this value.
- **Negotiated DCAT-AP feature** means the Section 9 context-substitution
  operation advertised by the DSP access service and selected by an explicit
  profile parameter.
- **Representation profile** means the IRI carried in the `profile` media-type
  parameter that selects one of the representations of a catalogue snapshot.

## 4. Normative namespaces and identifiers

| Prefix or name | IRI |
|---|---|
| DSP context | `https://w3id.org/dspace/2025/1/context.jsonld` |
| DSP 2025-1-err2 specification | `https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/` |
| Tier 1 DSP profile | (TBD) `tag:materialscommons.eu,2026:dsp/prototype-tier-1` |
| Tier 0 DCAT-AP companion profile | (TBD) `tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-0` |
| Negotiated DCAT-AP feature | (TBD) `tag:materialscommons.eu,2026:dsp/prototype-tier-1#dcat-ap-content-negotiation` |
| DCAT-AP 3.0.1 profile, also the DCAT-AP representation profile | `https://semiceu.github.io/DCAT-AP/releases/3.0.1/` |
| Materials DCAT-AP representation profile | (TBD) `tag:materialscommons.eu,2026:mc-dcat-ap/materials` |
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

When no independent offer identifier has been assigned, a Provider SHOULD
derive one by appending `#offer` to the dataset identifier. A sole distribution
MAY similarly use `#distribution`. Multiple distributions MUST have distinct,
stable identifiers, for example `#distribution-csv` and `#distribution-json`.

## 5. HTTPS service organization

### 5.1 Location independence

This specification does not prescribe the path of `<root>` or `<base>`.
`<root>` MUST be an absolute HTTPS URL without user information, query, or
fragment. It MAY include a deployment path.

The DSP version `path` MUST be interpreted according to the DSP
[HTTPS version-path rule](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#https-binding).
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

A Tier 1 Provider MUST expose these DSP endpoints, and no others are required:

| Method | URL | Function |
|---|---|---|
| `GET` | `<root>/.well-known/dspace-version` | DSP version discovery |
| `POST` | `<base>/catalog/request` | DSP catalogue request |
| `GET` | `<base>/catalog/datasets/{id}` | DSP dataset request |

These paths follow the DSP
[catalogue HTTPS binding](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#catalog-http).

DSP defines twelve further provider endpoints, ten of them `POST`, which makes
eleven `POST` endpoints in the full set of fifteen. They are listed here so
that the boundary of this tier is explicit, and a Tier 1 Provider MUST NOT be
required to expose any of them:

| Method | URL | Function | Tier 1 |
|---|---|---|---|
| `GET` | `<base>/negotiations/{providerPid}` | Negotiation state | Out of scope |
| `POST` | `<base>/negotiations/request` | Initial contract request | Out of scope |
| `POST` | `<base>/negotiations/{providerPid}/request` | Counter-request | Out of scope |
| `POST` | `<base>/negotiations/{providerPid}/events` | Negotiation event | Out of scope |
| `POST` | `<base>/negotiations/{providerPid}/agreement/verification` | Agreement verification | Out of scope |
| `POST` | `<base>/negotiations/{providerPid}/termination` | Negotiation termination | Out of scope |
| `GET` | `<base>/transfers/{providerPid}` | Transfer state | Out of scope |
| `POST` | `<base>/transfers/request` | Initial transfer request | Out of scope |
| `POST` | `<base>/transfers/{providerPid}/start` | Resume transfer | Out of scope |
| `POST` | `<base>/transfers/{providerPid}/suspension` | Suspend transfer | Out of scope |
| `POST` | `<base>/transfers/{providerPid}/completion` | Complete transfer | Out of scope |
| `POST` | `<base>/transfers/{providerPid}/termination` | Terminate transfer | Out of scope |

Their paths follow the DSP
[negotiation provider paths](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#provider-path-bindings)
and [transfer provider paths](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#provider-path-bindings-0).
A Provider that chooses to expose them follows Sections 11 and 12.

A Provider that exposes none of them SHOULD return `404 Not Found` on those
paths. A consumer MUST treat that as the documented Tier 1 behavior rather than
a fault.

`GET <base>/catalog` is not a DSP 2025-1 endpoint and is not required or defined
by this specification.

### 5.3 Media type, context, and schemas

All DSP request and response bodies MUST use `application/json`, as required by
the HTTPS bindings for
[catalogue](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#prerequisites),
[negotiation](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#prerequisites-0),
and [transfer](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#prerequisites-3).

Every contextualized DSP message MUST contain an `@context` array including
the exact official DSP context and MUST use the required `@type`. Incoming and
outgoing DSP documents MUST validate against the official DSP 2025-1 JSON
Schema for their message or resource type. Providers SHOULD validate against
pinned schemas without live retrieval during request processing.

The Section 9 DCAT-AP representation is not a DSP response message. It is an
additional HTTP representation selected by an explicit profile parameter and
has its own context and media-type parameters. Its availability does not alter
the required DSP behavior for `application/json` requests and responses.

## 6. DSP version discovery

`GET <root>/.well-known/dspace-version` MUST be unversioned, public, and
unauthenticated, following DSP
[Exposure of Versions](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#exposure-of-dataspace-protocol-versions).

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
[DSP Section 5.2.1](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#catalog-request-message)
and its
[HTTPS endpoint](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#catalog-request-post).

`filter` MUST be absent or an empty array. A non-empty filter MUST produce
`400 Bad Request` with a `CatalogError` whose code identifies an unsupported
filter.

A successful request MUST return `200 OK` and either the complete current DSP
catalogue or its first page, with navigation as specified in Section 7.5.
Pagination is REQUIRED for Tier 1 Providers.

### 7.2 Catalogue response

The response MUST satisfy the DSP
[Catalog response requirements](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#ack-catalog)
and contain:

- the official DSP context;
- an absolute catalogue `@id`;
- `@type` equal to `Catalog`;
- a stable `participantId`;
- non-empty `dct:title` and `dct:description` values;
- a `dct:conformsTo` array containing the Materials Commons DCAT-AP GET
  Protocol Tier 0 and DCAT-AP 3.0.1 profile IRIs, each represented as a typed
  `dct:Standard` object;
- `dct:publisher` conforming to Section 8.2;
- at least one dataset;
- exactly one DSP access service in the root `service` array and referenced by
  every distribution;
- zero or one DCAT-AP companion-service advertisement conforming to Section 9;
  and
- a negotiated DCAT-AP feature declaration on the DSP access service conforming
  to Section 9, where the Provider serves a DCAT-AP representation.

The response MUST be internally consistent. Dataset, offer, distribution,
and service identifiers MUST be unique throughout the complete snapshot,
including when its datasets are split across pages as specified in Section 7.5.

The response is a DSP document. Under the official DSP context its
`endpointURL` values remain RDF literals, so that JSON-LD expansion is not a
DCAT 3 or DCAT-AP conformant RDF representation. The catalogue-level
`dct:conformsTo` values identify the conformance targets of the shared
catalogue value and its context-substituted DCAT-AP representation; they MUST
NOT be interpreted as overriding the RDF-literal exception in Section 1.4. A
`DataService` MAY additionally claim conformance to a protocol that it
implements; such a service-level statement does not claim that the enclosing
DSP serialization removes that exception.

### 7.3 Dataset entries

Each dataset MUST satisfy the DSP
[Dataset response requirements](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#ack-dataset)
and contain:

- an absolute, unique `@id`;
- `@type` equal to `Dataset`;
- non-empty `dct:title` and `dct:description` values;
- one publisher with an absolute IRI and non-empty name;
- exactly one `hasPolicy` value conforming to Section 8.4; and
- one or more `distribution` values conforming to Section 8.5.

All datasets in one snapshot MUST use the catalogue publisher's identifier and
name.

### 7.4 Individual dataset request

A Consumer retrieves one dataset using:

```text
GET <base>/catalog/datasets/{id}
```

The identifier MUST be matched exactly after normal HTTP path decoding. This
is the binding of the DSP
[Dataset Request Message](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#dataset-request-message)
defined by
[DSP Section 6.2.2](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#catalog-datasets-get).

A known identifier MUST return `200 OK` and the same dataset metadata as the
catalogue, with the DSP context at the document root. An unknown identifier
MUST return `404 Not Found` with `CatalogError`.

### 7.5 Filters, pagination, and compression

Tier 1 defines no filter language. Consumers MUST filter the returned
catalogue locally, consistent with DSP
[Queries and Filter Expressions](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#queries-and-filter-expressions).

Providers MUST support pagination of catalogue responses following DSP
[Pagination](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#pagination).
This is a requirement on the Provider rather than on an individual response: a
snapshot that fits in one response MUST still be returned as a single page,
which is a complete snapshot carrying neither a `next` nor a `previous` link.

Navigation MUST use the HTTP `Link` header with `next` and `previous` relations
for adjacent pages where they exist. The last page MUST omit `next` and the
first MUST omit `previous`. Consumers retrieving the complete catalogue MUST
follow `next` links until no next page remains, and MUST NOT assume that one
response carries the whole catalogue.

Pagination is required because a Tier 1 catalogue is not assumed to exist
before the request. A provider holding millions of datasets produces the
catalogue from search results per request, and a profile that let it answer
with the complete snapshot would exclude exactly the providers this tier is
meant to admit. The page size is the Provider's choice.

For this profile, page links MUST be absolute HTTPS URLs accepting `POST`
with the same `CatalogRequestMessage` body and representation selection as
the initial request. Their query parameters are implementation-defined and
MUST be treated as opaque by Consumers. Page retrieval MUST remain
unauthenticated and satisfy the same response and error requirements as the
initial request. An expired or unknown page reference MUST return
`404 CatalogError`; a Consumer MAY restart from the initial catalogue request.

Each page MUST be a schema-conforming Catalog containing complete dataset
entries. Only the top-level `dataset` array varies across pages of a snapshot;
all other catalogue properties, including service metadata, MUST be identical.
Following all `next` links MUST yield every dataset in that snapshot exactly
once. The complete catalogue is reconstructed by concatenating those `dataset`
arrays and retaining the common catalogue properties. A page reference MUST
NOT silently switch to another snapshot when publication metadata changes.

HTTP content coding MAY be used independently of pagination when normal HTTP
negotiation is respected and decoded content is unchanged.

### 7.6 RDF alignment and validation

Each complete catalogue snapshot, when expanded using the official DSP
context, MUST satisfy the authoritative DCAT-AP 3.0.1 mandatory-property,
range, and controlled-vocabulary SHACL constraints, with only the exception
below. For paginated catalogues this requirement applies to the reconstructed
complete snapshot from Section 7.5; each DSP page MUST still satisfy its JSON
Schema and the publication requirements for the entries it carries.

This is an output-conformance requirement. A Provider MAY ensure it through
validated publication inputs, pre-generated catalogues, JSON-LD/SHACL
processing, or an equivalent method. Providers are not required to run a
JSON-LD processor or SHACL engine, or to repeat validation during requests.
Regardless of method, non-conforming output remains a conformance failure.

The reference procedure for conformance checking is to expand the complete
snapshot and validate it against pinned, provenance-recorded copies of the
authoritative shapes. Such checks MUST NOT depend on live network retrieval.

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

When a Section 9 DCAT-AP representation is generated, its context MUST coerce
every `endpointURL` value to an RDF IRI. The resulting graph MUST pass the same
validation without the exception above.

## 8. Tier 1 publication model

### 8.1 Catalogue metadata

One catalogue snapshot MUST define:

| Field | Cardinality | Requirement |
|---|---:|---|
| Catalogue identifier | `1` | Absolute stable IRI |
| Title | `1` | Non-empty string |
| Description | `1` | Non-empty string |
| Participant identifier | `1` | Absolute stable IRI |
| Conformance | `2..*` | Tier 0 and DCAT-AP 3.0.1 profile IRIs, typed `dct:Standard`, per Section 7.2 |
| Publisher | `1` | One shared Agent identifier and name |
| DSP access service | `1` | Root catalogue service with stable ID, title, `<base>` endpoint, conformance, and served datasets |
| Dataset | `1..*` | At least one Tier 1 dataset |
| DCAT-AP companion service | `0..1` | Optional Section 9 advertisement |
| Negotiated DCAT-AP feature | `0..1` | Section 9 declaration on the DSP access service; REQUIRED where a DCAT-AP representation is served |

### 8.2 Publisher

The publisher MUST have an absolute `@id`, type
`http://xmlns.com/foaf/0.1/Agent`, and a non-empty value for
`http://xmlns.com/foaf/0.1/name`. Full FOAF IRIs are used because the official
DSP context does not define the `foaf` prefix.

The same publisher object MUST appear as `dct:publisher` on the catalogue.
Each dataset MUST refer to the same publisher and MUST either include its name
or identify the catalogue publisher node carrying that name.

### 8.3 Dataset declaration

Each dataset MUST define the following metadata. Cardinalities for fields
marked "per distribution" apply independently to each of its one or more
distributions.

| Field | Cardinality | Requirement |
|---|---:|---|
| Dataset identifier | `1` | Absolute stable IRI; unique |
| Title | `1` | Non-empty string |
| Description | `1` | Non-empty string |
| Publisher identifier and name | `1` | Equal to catalogue publisher |
| Offer identifier | `1` | Absolute stable IRI; unique |
| Distribution identifier | `1` per distribution | Absolute stable IRI; unique |
| Licence | `1` per distribution | IRI of a published licence, typed `dct:LicenseDocument` |
| Public access URL | `1` per distribution | Absolute HTTPS URL |
| EU file-type IRI | `1` per distribution | EU File Type concept; distinct within the dataset |
| IANA media-type IRI | `1` per distribution | Registered media-type IRI |
| Byte size | `0..1` per distribution | Non-negative integer |
| SHA-256 digest | `0..1` per distribution | 64 lower-case hexadecimal characters |

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
obligations, prohibitions, remedies, or nested targets.

The offer MUST carry exactly one `permission`, whose action MUST be `use`,
which the official DSP context maps to `odrl:use`.

The permission is not optional, because the DSP JSON Schema does not allow it
to be. `Offer` requires `anyOf` of `permission` or `prohibition`, and Section
2.3 excludes prohibitions, so the permission is the only rule a Tier 1 offer
may carry. Section 5.3 requires outgoing documents to validate against that
schema, so an offer without a rule is not a conforming Tier 1 catalogue.

It is fixed boilerplate rather than a rights statement: every Tier 1 dataset
carries the identical four tokens, they convey nothing about the dataset, and
they cannot restrict access. The rights statement is the licence required by
Section 8.5.

This offer is not the licence. It expresses unconditional technical access,
and it does not replace copyright, attribution, citation, or ethical-use
metadata. The licence is carried separately and is REQUIRED by Section 8.5.

Tier 1 never receives this offer back. Nothing at this tier consumes it, and no
`ContractRequestMessage` reaches a Tier 1 Provider. It is carried because the
DSP catalogue schema requires `hasPolicy` on every Dataset, which is also why
Section 2.3 can exclude negotiation without the catalogue ceasing to validate.
Section 11.2 states the form the same offer takes for a Provider that
implements the optional negotiation flow.

### 8.5 Distribution and DCAT-AP-aligned metadata

Each dataset MUST have one or more DSP Distributions. Each Distribution MUST
contain:

- absolute `@id` and `@type` equal to `Distribution`;
- `format` equal to the full EU File Type IRI;
- an explicit `dct:format` node with that same `@id` and `@type` equal to
  `dct:MediaTypeOrExtent`;
- `dcat:accessURL` as an `@id` object containing the public HTTPS URL;
- `dcat:downloadURL` as an `@id` object containing that same direct URL;
- `dcat:mediaType` as an `@id` object containing the IANA media-type IRI and
  `@type` equal to `dct:MediaType`;
- `dct:license` as an `@id` object containing the IRI of a published licence,
  typed `dct:LicenseDocument`; and
- one DSP `accessService` object identifying the root DSP access service.

The licence is REQUIRED, which is stricter than DCAT-AP, where
[Distribution licence](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#Distribution.licence)
is only recommended. Publishing a dataset with no licence would leave a
consumer to infer that nothing is granted, which contradicts the unconditional
offer in Section 8.4 that accompanies it. A well-known licence IRI, for example
a Creative Commons one, SHOULD be used in preference to a bespoke document, and
in preference to modelling the same terms in ODRL.

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

Distributions within one dataset MUST have distinct DSP `format` values, so
that a Consumer can tell them apart and pick one. This permits, for example,
CSV and JSON representations of the same dataset under its single unconditional
offer.

At Tier 1 a Consumer selects a distribution and retrieves it from the
`dcat:downloadURL` directly. The format value is a description of the bytes.
Section 12 gives it a second role, selecting the transport, for a Provider that
implements the optional transfer flow; that role carries no weight here.

### 8.6 DSP access service

DSP requires every advertised Distribution to reference a `DataService`, and
positions that service as the one at which contract negotiation and the
transfer process are initiated. A Tier 1 Provider operates its catalogue half
and nothing else. The service is therefore the catalogue service: the endpoint
that answers the catalogue and dataset requests of Section 7.

What this changes against earlier drafts of this profile is stated here rather
than removed quietly:

- The service is still REQUIRED, and every distribution MUST still reference
  it. The DSP schema gives no alternative.
- The requirement to advertise DSP 2025-1 in `dct:conformsTo` is **withdrawn**.
  A Tier 1 Provider does not conform to DSP, per Section 1.3, so making that
  claim in the catalogue would be false. A Provider implementing Tier 1 alone
  MUST NOT carry the DSP specification IRI in this service's `dct:conformsTo`.
  A Provider that also implements the flows of Sections 11 and 12, and meets
  the DSP conformance requirements in full, MAY carry it. That addition is a
  claim about the deployment and lies outside Tier 1 conformance.
- The requirement that the service accept negotiation and transfer messages is
  **withdrawn**. A Consumer MUST NOT infer from the presence of this service
  that `<base>/negotiations/request` or `<base>/transfers/request` exists.

The DSP access service MUST have a stable absolute `@id`, `@type` equal to
`DataService`, a non-empty `dct:title`, and `endpointURL` equal to `<base>`. It
MUST occur in the root catalogue `service` array. It MUST contain a
`dct:conformsTo` value for the Materials Commons DSP Tier 1 profile, expressed
as an `@id` object with `@type` equal to `dct:Standard`. That one IRI is what
tells a Consumer which subset of DSP the endpoint speaks. It MUST contain
`dcat:servesDataset` as `@id` objects naming every dataset in the snapshot.
Across the pages of one snapshot, this complete list and the rest of the
service metadata MUST be repeated identically on each page; it is not limited
to the datasets carried by that page.

If the Section 9 negotiated DCAT-AP feature is supported, this service's
`dct:conformsTo` values MUST additionally include the negotiated DCAT-AP
feature IRI and the representation profile IRIs it serves, each typed
`dct:Standard`.

Each distribution MUST identify that same service through `accessService`.
An embedded copy and the root copy, if both contain metadata, MUST be
identical after RDF node merging.

A Provider MAY advertise a second `DataService` for a connector operated by
somebody else, so that a Consumer wanting an agreement knows where to go. Such
a service MUST NOT be the `accessService` of a Tier 1 distribution, because
Tier 1 makes no statement about what it will do. Its specification is left to
the tier that covers negotiation.

The prefixed spelling `dcat:servesDataset` is required, and MUST NOT be
shortened to a bare `servesDataset`. The DSP JSON Schema declares the bare
property, but the official DSP context defines no term for it, so a bare
`servesDataset` expands to no triple at all and the served-dataset list is
silently lost. The `dcat` prefix is defined in that context, so the prefixed
form expands correctly. Reported upstream as
[DataspaceProtocol#277](https://github.com/eclipse-dataspace-protocol-base/DataspaceProtocol/issues/277).

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

## 9. Serving DCAT-AP from the catalogue endpoint

### 9.1 How DCAT-AP is served at this tier

Sections 9.3 through 9.5 define **the** way a Tier 1 Provider serves DCAT-AP
from its DSP catalogue endpoint. A Provider that offers any DCAT-AP
representation of its DSP catalogue MUST offer it this way, and every
requirement stated for the mechanism is then mandatory and its availability
MUST be advertised in the DSP catalogue. A Tier 1 Provider SHOULD offer it.

Two things follow from making this the specified mechanism.

First, a Provider MUST NOT serve DCAT-AP-shaped output in response to a request
that selects no representation profile. An unprofiled catalogue request gets
the DSP context and a payload that is valid for any DSP-native client. Serving
something that looks DCAT-AP conformant to a client that asked for DSP would
put non-conformant output in front of every harvester that finds the endpoint,
which is the failure this mechanism exists to prevent.

Second, selection MUST key on an explicit profile parameter, per Section 9.4.
Earlier drafts keyed on a bare `application/ld+json` media range. That breaks
as soon as DSP itself accepts that media type, because the same request would
then select two different representations.

The separate `GET` service remains available as well. A Tier 1 Provider MAY
expose a strict DCAT-AP catalogue by separately conforming to **Materials
Commons DCAT-AP Tier 0**. Absence of that service does not affect DSP Tier 1
conformance, and its presence is no longer a precondition for the mechanism in
Sections 9.3 through 9.5.

If the companion service is present, it MUST be discoverable both:

1. through the well-known discovery mechanism required by Materials Commons
   DCAT-AP Tier 0; and
2. through a `DataService` in the root DSP catalogue `service` array as defined
   in Section 9.2.

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
tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-0
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

Support for the profiled representations MUST be advertised on the existing
DSP access service from Section 8.6. A Provider MUST NOT invent a second
distribution access service for this purpose.

The DSP access service's `dct:conformsTo` array MUST contain typed Standard
objects for the Tier 1 profile, the feature discriminator, and every
representation profile the Provider serves:

```text
tag:materialscommons.eu,2026:dsp/prototype-tier-1
tag:materialscommons.eu,2026:dsp/prototype-tier-1#dcat-ap-content-negotiation
https://semiceu.github.io/DCAT-AP/releases/3.0.1/
```

A Provider that also serves Materials DCAT-AP MUST additionally carry its
representation profile IRI, currently (TBD)
`tag:materialscommons.eu,2026:mc-dcat-ap/materials`. The two are advertised and
requested separately, because Materials DCAT-AP adds properties that plain
DCAT-AP does not define, and a Consumer that asked for DCAT-AP has to receive
DCAT-AP.

The DSP specification IRI stays out of this array unless Section 8.6 permits
it.

Each value MUST be an `@id` object with `@type` equal to `dct:Standard`. The
feature IRI is the machine-readable discriminator. A Consumer that recognizes
it learns the HTTP method, request type, media-type parameter, context
substitution, and identity invariant from this section; it MUST NOT infer
support from a media type alone, or from a service title or URL pattern.

The DSP access service's `endpointURL` remains `<base>`, as required by DSP.
The feature operation is the standard DSP catalogue request target obtained by
appending `/catalog/request`. Advertising a capability of the existing service
through typed extension metadata neither changes the meaning of that service
nor introduces a second route.

A compatible Consumer discovers the feature without path guessing:

1. derive `<base>` and the DSP access-service identifier through DSP version
   discovery;
2. request the ordinary DSP catalogue;
3. locate the root `service` whose `@id` equals that advertised service
   identifier, verify the exact feature IRI in its `dct:conformsTo` values, and
   read off which representation profiles are listed there; and
4. repeat the catalogue request at `<base>/catalog/request` using the explicit
   `Accept` rule in Section 9.4, naming one of those profiles.

### 9.4 Profile selection and retrieval

A Consumer invokes the advertised operation by sending a valid DSP
`CatalogRequestMessage` to `<base>/catalog/request`, where `<base>` is the
advertised DSP access-service `endpointURL`, using:

```http
Content-Type: application/json
Accept: application/ld+json;profile="https://semiceu.github.io/DCAT-AP/releases/3.0.1/"
```

The `profile` media-type parameter is what selects the representation. For this
feature, a valid selection means an `Accept` field containing exactly one
acceptable media range, `application/ld+json`, carrying exactly one `profile`
parameter whose value is one representation profile IRI advertised under
Section 9.3, with no quality value other than `1`.

Anything else leaves the representation unselected. In particular:

- an absent `Accept` field, or `*/*`, MUST return the ordinary DSP response;
- an `Accept` field permitting `application/json` that does not meet the
  selection rule MUST return the ordinary DSP response;
- `application/ld+json` with no `profile` parameter, or with a `profile` value
  the Provider does not serve, MUST NOT select a DCAT-AP representation. The
  unrecognized profile is ignored, as JSON-LD 1.1 requires, which leaves the
  request naming no representation the Provider can supply. The Provider then
  returns the ordinary DSP response if the `Accept` field also permits
  `application/json`, and `406 Not Acceptable` otherwise.

A bare `application/ld+json` media range therefore selects nothing on its own.
DSP may accept that media type for its own responses, at which point the bare
range would identify two representations at once. The profile parameter stays
unambiguous whatever DSP does with media types.

A list containing any other media range MUST NOT accidentally select a
profiled representation.

For a valid selection, a Provider advertising this feature MUST return
`200 OK` with the same profile IRI echoed in the response:

```http
Content-Type: application/ld+json; profile="https://semiceu.github.io/DCAT-AP/releases/3.0.1/"
Vary: Accept
```

The response SHOULD also contain a `Link` header with the same profile IRI and
relation type `profile`, per
[RFC 6906](https://www.rfc-editor.org/rfc/rfc6906):

```http
Link: <https://semiceu.github.io/DCAT-AP/releases/3.0.1/>; rel="profile"
```

The `profile` parameter is defined for `application/ld+json` by
[JSON-LD 1.1](https://www.w3.org/TR/json-ld11/#iana-considerations), which is
why no new media type is required for this. Registering a vendor media type
instead remains open; it would be an alternative spelling of the same
selection, with the same invariant in Section 9.5.

The response is an additional Materials Commons DCAT-AP representation rather
than a DSP response message. Ordinary DSP catalogue requests and all DSP error
messages continue to use `application/json` as required by DSP. A Provider that
does not advertise this feature MAY return `406 Not Acceptable` for a request
that accepts only `application/ld+json`.

### 9.5 Common-payload and context-substitution invariant

For one catalogue snapshot, the ordinary DSP response, the negotiated
DCAT-AP response, and the companion `GET` response MUST have the same Common
catalogue value. No dataset, service, policy, distribution, metadata property,
or conformance value may be added, removed, or changed between those
representations.

When DSP responses are paginated, this equality applies to the reconstructed
complete snapshot, not to an individual page. A negotiated DCAT-AP response
at a DSP page URL MUST contain the same page payload except for `@context`,
with the same navigation links and the Section 9.4 representation headers.
The companion `GET` service retains its separately specified retrieval
behavior; it need not share DSP page boundaries. Its complete catalogue MUST
equal the reconstructed DSP catalogue after removing `@context`.

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
property on a Catalogue. Conformance of the profiled representation is
identified by its media-type profile parameter, `Link` header, discovery
record, and the typed service-level `dct:conformsTo` statements above.

The invariant holds for every representation profile. A Materials DCAT-AP
response carries the same Common catalogue value as the DCAT-AP response and
the DSP response, and differs from them only in `@context`. Whether DCAT-AP
tolerates the additional Materials DCAT-AP properties is open, which is the
reason the two profiles are requested separately rather than merged.

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
        "@id": "tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-0",
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

The example path `/mc-dcat-ap/3.0.1/` is not normative. The DSP specification
IRI is absent from the second service by design, per Section 8.6.

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

This is the only retrieval path Tier 1 defines. A Provider that implements the
optional transfer flow of Section 12 hands out the same URL in its
`DataAddress`, so that flow adds steps without adding access.

Gated distributions are a Tier 0 capability and have no counterpart here. A
Tier 1 distribution MUST be retrievable by any consumer.

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

## 11. Contract negotiation, outside Tier 1

**Contract negotiation is outside the Tier 1 conformance target**, per Section
2.3. A Tier 1 Provider implements none of this section, exposes none of the
negotiation endpoints, and remains fully conforming.

This section is retained for two reasons. It records the rules that earlier
drafts of this profile imposed, so that an implementation built against them
can see exactly what changed. And it is the starting text for the Tier 2
profile, where contract negotiation belongs because that is where a policy can
refuse a request.

Everything below therefore applies only to a Provider that chooses to
implement the DSP negotiation flow alongside Tier 1. Such a Provider is making
a claim about its deployment; Section 8.6 states how that claim is advertised
and how it is kept apart from the Tier 1 claim.

### 11.1 Applicability and identifiers

A Provider implementing this optional flow MUST implement the DSP
[Contract Negotiation Protocol](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#negotiation-protocol)
for the Section 8.4 offer. The negotiation carries no access decision: the
offer is unconditional and the distributions are public either way.

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
[negotiation states](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#contract-negotiation-states):
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
[Consumer Path Bindings](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#consumer-path-bindings).

### 11.4 Optional offer branch

The Provider MAY send the unchanged offer to the Consumer offers callback and
commit `OFFERED` after acknowledgement. In `OFFERED`, the Consumer MAY send an
`ACCEPTED` event or return the exact same offer as a counter-request. Changed
terms are not permitted by this flow.

The direct-agreement flow is sufficient for the initial implementation;
sending offers need only be added when a target Consumer requires this
optional branch. The required provider endpoints and state-transition checks
remain applicable.

### 11.5 Agreement

The Agreement MUST contain a unique `@id`, `@type` equal to `Agreement`, target
equal to one catalogue dataset, assigner equal to the Provider participant,
assignee equal to the Consumer process identifier, a UTC XML Schema
`dateTime`, and a `permission` structurally equal to that of the selected
Offer. Rules inside the Agreement MUST NOT have their own targets.

### 11.6 Status, termination, and callbacks

`GET <base>/negotiations/{providerPid}` MUST return the current acknowledged
state or `404`. Either party MAY terminate a nonterminal process. All route and
message process identifiers MUST match. Invalid transitions or mismatches MUST
return `400` without changing state.

An outbound state MUST NOT be committed before its callback receives `2xx`.
Retry counts, timing, and backoff are implementation choices; this flow does
not prescribe a fixed attempt count. Retries MUST preserve message and process
identity and MUST NOT overwrite a newer acknowledged state. After the
Provider abandons delivery, it SHOULD attempt termination and MUST NOT report
the unacknowledged target state. These rules also apply to transfer callbacks.

## 12. Transfer process, outside Tier 1

**The transfer process is outside the Tier 1 conformance target**, per Section
2.3, and is retained on the same terms as Section 11. A Tier 1 Provider
implements none of it. At Tier 1 a Consumer retrieves bytes from the
`dcat:downloadURL` of the distribution it picked, as specified in Section 10.

Everything below applies only to a Provider that chooses to implement the DSP
transfer flow alongside Tier 1, and it presupposes the negotiation flow of
Section 11, since a transfer needs a finalized Agreement.

### 12.1 Preconditions and request

A transfer MUST refer to a current Agreement in `FINALIZED` whose target is a
currently published dataset. A Provider implementing this optional flow MUST
implement DSP
[Transfer Process Protocol](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#transfer-protocol)
as finite public HTTPS pull. Push transfer, consumer-supplied data addresses,
non-finite streams, and data-plane protocols other than HTTPS pull stay out of
scope even for such a Provider.

Within this flow, every advertised format value selects HTTPS consumer-pull
behavior. That mapping is a Materials Commons profile convention; DSP alone
does not define EU file-type IRIs as transport selections. A Consumer using the
flow MUST support it. `TransferRequestMessage.format` MUST exactly match one
advertised distribution of the Agreement's target dataset, and the Provider
MUST select that distribution and reject an unknown format.

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

`endpoint` MUST equal the resolved public access and download URL of the
distribution selected by the request's `format`.
`endpointProperties` MUST NOT convey authorization, credentials, cookies, or
tokens. The Provider commits `STARTED` only after `2xx` acknowledgement. This
implements DSP
[pull transfer](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#pull-transfer).

### 12.4 States and provider endpoints

The Provider MUST enforce DSP
[transfer states](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#transfer-process-states):
`REQUESTED`, `STARTED`, `SUSPENDED`, `COMPLETED`, and `TERMINATED`.

| From | Action | To |
|---|---|---|
| none | Valid initial request | `REQUESTED` |
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
[Consumer Callback](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#consumer-callback-path-bindings)
returns `2xx`.

## 13. Errors and HTTP status codes

Catalogue errors MUST use `CatalogError`, with the official context and exact
type. A safe non-empty reason SHOULD be supplied. A Provider implementing the
optional flows of Sections 11 and 12 uses `ContractNegotiationError` and
`TransferError` on the same terms, and MUST include known process identifiers
where the schema requires them.

| Status | Use | Tier 1 |
|---:|---|---|
| `200 OK` | Successful retrieval | Yes |
| `400 Bad Request` | Invalid message, unsupported feature, or mismatch | Yes |
| `404 Not Found` | Unknown dataset, or an expired page reference | Yes |
| `406 Not Acceptable` | No acceptable catalogue representation, per Section 9.4 | Yes |
| `201 Created` | New negotiation or transfer process | Optional flows only |
| `400 Bad Request` | Invalid state transition | Optional flows only |
| `404 Not Found` | Unknown negotiation, transfer, or agreement | Optional flows only |
| `409 Conflict` | Optional concurrent-transition conflict | Optional flows only |
| `502 Bad Gateway` | Optional failure of a required synchronous callback | Optional flows only |

A Tier 1 Provider SHOULD return `404 Not Found` for the negotiation and
transfer paths it does not implement, per Section 5.2.

Tier 1 endpoints and public distributions MUST NOT return `401` or `403`
merely because `Authorization` is absent. Unexpected errors MAY return `500`
without exposing implementation details.

## 14. Security and privacy

### 14.1 Public access and TLS

Tier 1 selects the unauthenticated option permitted by DSP
[Authorization](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/#authorization).
Catalogue content and public data MUST NOT vary by caller identity or
credentials. All public traffic MUST use HTTPS with certificate and hostname
validation, and so MUST callback traffic where a Provider implements the
optional flows.

### 14.2 Callback safety

Callback addresses are relevant only to the optional flows of Sections 11 and
12. A Tier 1 Provider initiates no outbound request and this subsection does
not apply to it.

Callback addresses are untrusted outbound destinations. A Provider sending to
one MUST:

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

Metadata MAY change between independent catalogue requests; pages belonging
to one snapshot MUST follow Section 7.5. A removed dataset MUST not silently
resolve to another dataset.

A Tier 1 Provider keeps no process state. Pagination references are the only
state a catalogue request can create, and Section 7.5 allows a Provider to
invalidate them.

For a Provider implementing the optional flows of Sections 11 and 12,
negotiation and transfer operations MUST resolve the publication against the
current snapshot. Such a Provider MAY persist process state across restart;
durable storage does not require a higher tier, and it is not required here.
After state loss, an unknown prior process returns `404`; the Consumer MAY
begin again. Retained processes MUST preserve their identifiers, acknowledged
states, and idempotency behavior. Transitions MUST be concurrency-safe and
stale callbacks MUST NOT overwrite newer acknowledged state, whether storage
is in memory or durable.

## 16. Extensibility

DSP messages MAY contain extension properties permitted by upstream schemas,
provided they do not redefine protected terms or alter Tier 1 semantics.

Additional publication metadata MAY use DCAT, DCTERMS, FOAF, SPDX, or another
vocabulary. Such use does not by itself create a DCAT conformance claim. It
MUST preserve the Section 9.5 Common catalogue value across every
representation served. Extension metadata MUST NOT:

- require authentication;
- make the unconditional offer conditional;
- replace the direct public download with a landing page;
- gate a distribution, which is a Tier 0 capability and has no Tier 1 form;
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
- [ ] No DSP conformance claim is made in the documentation or in the
      catalogue, unless the deployment also meets the condition in Section 8.6.
- [ ] The negotiation and transfer paths are either absent, answering `404`, or
      documented as an addition outside Tier 1.
- [ ] The complete catalogue output, when expanded for conformance checking,
      passes pinned DCAT-AP mandatory, range, and
      controlled-vocabulary validation except only for literal-valued
      `dcat:endpointURL`.

### 17.2 Catalogue and publication

- [ ] `POST <base>/catalog/request` returns the complete catalogue or its first
      page with DSP `Link` navigation.
- [ ] Non-empty filters return `400 CatalogError`.
- [ ] At least one dataset is present, and pagination is supported.
- [ ] `next`/`previous` links accept the specified POST request, all pages form
      one consistent snapshot, and traversal returns every dataset exactly once.
      Invalidated page references return `404 CatalogError`.
- [ ] A snapshot that fits in one response is returned as a single page with
      neither link.
- [ ] Dataset, offer, distribution, and service IDs are stable and unique.
- [ ] All datasets share one publisher.
- [ ] The catalogue carries the Tier 0 and DCAT-AP 3.0.1 conformance IRIs as
      typed `dct:Standard` objects.
- [ ] Each dataset has one unconditional offer and one or more public
      distributions, with distinct DSP format values within the dataset.
- [ ] Every distribution states a licence.
- [ ] Format, media type, licence, access URL, and direct download URL are
      present with the required RDF classes and ranges.
- [ ] Every format is explicitly typed `dct:MediaTypeOrExtent`.
- [ ] Every media type is explicitly typed `dct:MediaType`.
- [ ] Known byte sizes are explicitly typed `xsd:nonNegativeInteger`, and
      checksums use the required SPDX and XML Schema types.
- [ ] The root DSP access service identifies every served dataset and the
      profiles to which it conforms, and carries no DSP specification IRI.
- [ ] Individual dataset retrieval returns the same metadata or `404`.
- [ ] The DSP response makes no DCAT or DCAT-AP conformance claim.

### 17.3 DCAT-AP representations and the optional companion

- [ ] If a DCAT-AP representation is served, it is served by profile selection
      as specified in Section 9 and by no other mechanism.
- [ ] An unprofiled catalogue request returns the DSP context and a payload
      valid for a DSP-native client.
- [ ] A bare `application/ld+json` media range selects no DCAT-AP
      representation.
- [ ] The DSP access service contains the exact feature IRI and every
      representation profile IRI served, while retaining `<base>` as its
      `endpointURL`.
- [ ] A valid profile selection returns the profiled JSON-LD media type with
      the same profile IRI echoed, plus `Vary: Accept`.
- [ ] An unserved profile value returns `406` or the ordinary DSP response, per
      Section 9.4.
- [ ] The DSP, profiled, and companion responses have structurally identical
      Common catalogue values for the same complete snapshot after assembling
      pages. Profiled page payloads match their DSP counterparts.
- [ ] Context substitution changes only literal `dcat:endpointURL` values into
      IRIs, and the substituted graph passes full DCAT-AP validation.
- [ ] If no `GET` companion is offered, DSP Tier 1 remains fully conformant.
- [ ] If offered, root `service` contains the exact companion profile and
      DCAT-AP 3.0.1 IRIs.
- [ ] The advertised companion endpoint is absolute HTTPS and path-independent.
- [ ] Served dataset identifiers refer to the current DSP snapshot.
- [ ] The companion endpoint also satisfies Materials Commons DCAT-AP Tier 0
      well-known discovery and conformance requirements.

### 17.4 Optional negotiation and transfer, outside Tier 1

These items are not Tier 1 conformance criteria. Use them only to check a
Provider that chose to implement Sections 11 and 12.

- [ ] Only the exact advertised unconditional offer is accepted.
- [ ] Agreement and finalization callbacks are supported.
- [ ] Agreements have unique ID, target, parties, UTC time, and permission.
- [ ] Transfers require a finalized agreement for a current dataset.
- [ ] Requested format exactly matches one distribution of the target dataset,
      and Start supplies that distribution's public URL.
- [ ] Consumer data addresses are rejected.
- [ ] Start supplies the public HTTPS DataAddress.
- [ ] Requests are idempotent by `consumerPid`.
- [ ] Invalid transitions are rejected without state change.
- [ ] Outbound states commit only after `2xx` callback acknowledgement.
- [ ] Optional persistence and callback retries preserve identifiers,
      acknowledged states, and idempotency behavior.

### 17.5 Independent consumer interoperability (non-normative)

Before relying on an interoperability claim, exercise the Tier 1 flow with an
independently implemented Consumer: version discovery, catalogue retrieval
across pages, retrieval of one dataset by identifier, profile selection of the
DCAT-AP representation, and download from the advertised URL. Include a
dataset with two formats and check that each resolves to the correct public
URL. Check as well that the Consumer tolerates the absence of the negotiation
and transfer endpoints.

Record the Consumer implementation and version, any configuration needed, and
the observed results. Schema validation and a Provider's own test client alone
do not demonstrate independent interoperability. This is verification guidance
rather than a requirement to implement consumer endpoints in a Tier 1 Provider.

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
    "dct:license": {
      "@id": "http://creativecommons.org/licenses/by/4.0/",
      "@type": "dct:LicenseDocument"
    },
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
        }
      ],
      "dcat:servesDataset": [
        {"@id": "https://provider.example/datasets/example"}
      ]
    }
  }]
}
```

### A.3 Profiled DCAT-AP catalogue request

```http
POST /dsp/2025-1/catalog/request HTTP/1.1
Host: provider.example
Content-Type: application/json
Accept: application/ld+json;profile="https://semiceu.github.io/DCAT-AP/releases/3.0.1/"

{
  "@context": ["https://w3id.org/dspace/2025/1/context.jsonld"],
  "@type": "CatalogRequestMessage",
  "filter": []
}
```

The response carries the same catalogue value as A.1 with the provider-owned
DCAT-AP context in place of the DSP one.

### A.4 Negotiation request, optional flow only

The remaining examples belong to Sections 11 and 12 and are outside Tier 1.

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

### A.5 Transfer request and start, optional flow only

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

- **DSP 2025-1-err2** - [Dataspace Protocol 2025-1, errata revision 2](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err2/).
- **DCAT 3** - [Data Catalog Vocabulary (DCAT), Version 3](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/).
- **DCAT-AP 3.0.1** - [DCAT Application Profile for data portals in Europe, Version 3.0.1](https://semiceu.github.io/DCAT-AP/releases/3.0.1/).
- **JSON-LD 1.1** - [JSON-LD 1.1](https://www.w3.org/TR/json-ld11/).
- **ODRL** - [ODRL Information Model 2.2](https://www.w3.org/TR/odrl-model/).
- **SHACL** - [Shapes Constraint Language](https://www.w3.org/TR/shacl/).
- **RFC 2119** - [Key words for use in RFCs to Indicate Requirement Levels](https://www.rfc-editor.org/rfc/rfc2119).
- **RFC 8174** - [Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words](https://www.rfc-editor.org/rfc/rfc8174).
- **RFC 6906** - [The `profile` Link Relation Type](https://www.rfc-editor.org/rfc/rfc6906).
- **RFC 8615** - [Well-Known Uniform Resource Identifiers](https://www.rfc-editor.org/rfc/rfc8615).
- **RFC 9110** - [HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110).

## Appendix C. Informative references

- **Materials Commons DCAT-AP GET Protocol Tier 0** - [Companion protocol](materials-commons-dcat-ap-get-protocol-tier-0.md).
- **The tier model** - [How the tiers relate](tiers.md).
