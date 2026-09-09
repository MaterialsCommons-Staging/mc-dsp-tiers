# PROTOTYPE DRAFT FOR DISCUSSION: Materials Commons DCAT-AP GET Protocol Tier 0 (Public Catalogues)

## Status of this document

This document defines **Materials Commons DCAT-AP Get Protocol Tier 0**, an independent
HTTPS protocol for discovery and retrieval of standards-conformant DCAT-AP
3.0.1 catalogues of public datasets and services.

This document is a normative specification. It profiles
[DCAT-AP 3.0.1](https://semiceu.github.io/DCAT-AP/releases/3.0.1/), which is an
application profile of
[DCAT 3](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/). It also defines
an HTTPS retrieval operation and a well-known discovery document; neither
DCAT 3 nor DCAT-AP prescribes those protocol details.

The separately specified
[Materials Commons DSP Tier 1](materials-commons-dsp-tier1.md) protocol may advertise a
service conforming to this document. Neither protocol requires the other for
conformance.

## Abstract

Materials Commons DCAT-AP Get Protocol Tier 0 provides basic non-authenticated access to a
strict DCAT-AP 3.0.1 catalogue of public datasets and services. It defines:

1. origin-level discovery at `/.well-known/mc-dcat-ap`;
2. an absolute, implementation-selected HTTPS catalogue endpoint;
3. a profiled `application/ld+json` response;
4. a deterministic minimum graph for catalogues, publishers, datasets,
   distributions, checksums, and data services;
5. public direct-download behavior;
6. consistency rules for an optional Materials Commons DSP Tier 1 companion;
   and
7. offline-capable DCAT-AP mandatory, range, and controlled-vocabulary
   validation.

The path of the catalogue endpoint is not prescribed. For example,
`/mc-dcat-ap/3.0.1/` is convenient but not normative.

## 1. Conformance and requirement language

### 1.1 Normative language

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**,
**SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **NOT RECOMMENDED**, **MAY**, and
**OPTIONAL** in this document are to be interpreted as described in
[BCP 14](https://www.rfc-editor.org/info/bcp14) when, and only when, they appear
in all capitals.

Examples and sections explicitly marked non-normative are not conformance
requirements.

### 1.2 Conformance targets

This specification defines three conformance targets:

- A **Discovery Service** exposes the well-known document in Section 6.
- A **Catalogue Service** implements the HTTPS behavior in Section 7.
- A **Catalogue Representation** is the DCAT-AP RDF graph and JSON-LD
  serialization in Sections 8 through 12.

A service claiming **Materials Commons DCAT-AP Get Protocol Tier 0 conformance** MUST
conform to all three targets.

### 1.3 Upstream conformance

A Catalogue Representation MUST conform to the
[DCAT 3 conformance requirements](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#conformance)
and the
[DCAT-AP provider requirements](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#provider-requirements).

The normative conformance identifier for this profile is:

```text
tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-0
```

The identifier names the conformance profile and does not prescribe a
deployment URL.

The `tag:` URIs in this specification are provisional prototype
identifiers (RFC 4151), marked (TBD) where they appear in prose, pending
a working-group decision.

When this specification is published at a stable public location, the profile
IRI SHOULD dereference to this document or to authoritative metadata linking
to it.

### 1.4 Why this is separate from DSP

DSP 2025-1 reuses selected DCAT terms in a DSP-specific JSON profile. It does
not define a general DCAT serialization, and its protected JSON-LD context
cannot always produce values satisfying DCAT and DCAT-AP RDF constraints.

In particular, DSP requires `DataService.endpointURL` as a JSON string. The DSP
context expands that value as an RDF literal of `dcat:endpointURL`. DCAT 3
defines the value as a Web-resolvable IRI, while DCAT-AP requires an IRI or
blank node. Replacing the DSP string with a JSON-LD `@id` object would violate
the DSP JSON Schema, and redefining the protected DSP term is prohibited. See:

- DSP [Schemas and Contexts](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#schemas-contexts);
- DSP [DataService requirements](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/#ack-dataset);
- DCAT 3 [endpoint URL](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#Property:data_service_endpoint_url); and
- DCAT-AP [Data Service endpoint URL](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#DataService.endpointURL).

Materials Commons resolves this standards conflict through two representations:

1. **Materials Commons DSP Tier 1** remains schema-valid DSP and may carry
   useful compatible metadata without claiming DCAT conformance.
2. **Materials Commons DCAT-AP Get Protocol Tier 0**, defined here, provides a separate RDF
   graph that is fully validated as DCAT-AP 3.0.1.

The two representations MAY describe the same resources and reference each
other, but they have independent conformance and deployment URLs.

## 2. Scope

### 2.1 Purpose

This protocol is intended for public catalogues whose metadata and
distributions can be discovered without authentication. It gives generic
DCAT-AP clients a predictable discovery operation and a directly retrievable,
strictly validated JSON-LD representation.

### 2.2 Included capabilities

Tier 0 includes:

- unauthenticated well-known discovery;
- one or more discoverable catalogue endpoints per HTTPS origin;
- direct `GET` and `HEAD` retrieval;
- strict DCAT-AP 3.0.1 JSON-LD;
- at least one public dataset per catalogue;
- exactly one public downloadable distribution per Tier 0 dataset;
- EU File Type and IANA media-type identifiers;
- optional byte size and SHA-256 checksum;
- descriptions of the catalogue service and companion public data services;
- optional linkage to Materials Commons DSP Tier 1; and
- normal HTTP caching and conditional requests.

### 2.3 Excluded capabilities

The following are outside Tier 0:

- authentication and authorization;
- private, confidential, or caller-specific catalogue views;
- catalogue mutation;
- a query or filtering language;
- required pagination;
- content negotiation for non-JSON-LD RDF syntaxes;
- non-HTTPS distribution protocols;
- access-controlled distribution URLs; and
- DSP negotiation or transfer-process behavior.

A Provider MAY offer such capabilities separately. They MUST NOT be required
to retrieve a Tier 0 discovery document, catalogue, or distribution.

## 3. Terminology

Terms defined by
[DCAT 3](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#vocabulary-overview)
and
[DCAT-AP 3.0.1](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#specterminology)
apply.

For this specification:

- **Provider** means the organization publishing a conforming catalogue.
- **Discovery origin**, written `<origin>`, means an HTTPS URI consisting only
  of scheme and authority, such as `https://provider.example`.
- **Discovery endpoint** means
  `<origin>/.well-known/mc-dcat-ap`.
- **Catalogue endpoint** means the absolute HTTPS URL advertised by a discovery
  entry. `GET` on that URL returns one Catalogue Representation.
- **Catalogue service** means the `dcat:DataService` describing the Catalogue
  endpoint itself.
- **DSP companion** means an optional Materials Commons DSP Tier 1 Provider
  describing the same datasets.
- **Snapshot** means one internally consistent Catalogue Representation and
  the source metadata used to construct it.

## 4. Normative namespaces and identifiers

| Prefix or name | IRI |
|---|---|
| Tier 0 DCAT-AP profile | (TBD) `tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-0` |
| Tier 0 DSP profile | (TBD) `tag:materialscommons.eu,2026:dsp/prototype-tier-1` |
| DSP 2025-1 specification | `https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/` |
| DCAT-AP 3.0.1 profile | `https://semiceu.github.io/DCAT-AP/releases/3.0.1/` |
| `dcat` | `http://www.w3.org/ns/dcat#` |
| `dct` | `http://purl.org/dc/terms/` |
| `foaf` | `http://xmlns.com/foaf/0.1/` |
| `odrl` | `http://www.w3.org/ns/odrl/2/` |
| `spdx` | `http://spdx.org/rdf/terms#` |
| `xsd` | `http://www.w3.org/2001/XMLSchema#` |
| EU File Type authority | `http://publications.europa.eu/resource/authority/file-type/` |
| IANA media types | `https://www.iana.org/assignments/media-types/` |
| SPDX SHA-256 algorithm | `https://spdx.org/rdf/terms#checksumAlgorithm_sha256` |

All resource identifiers MUST be absolute IRIs. Every retrievable endpoint and
distribution URL MUST use HTTPS. Identifiers MUST NOT be inferred from endpoint
paths.

## 5. Protocol architecture and URL independence

### 5.1 Separation of identity and location

Catalogue, dataset, distribution, publisher, and service IRIs identify RDF
resources. The Catalogue endpoint is the network location from which one graph
is retrieved. These values MAY be equal but MUST NOT be assumed to be equal.

### 5.2 No prescribed catalogue path

This specification does not prescribe the Catalogue endpoint path. It may be
rooted at any absolute HTTPS URL and may be hosted on a different origin from
the Discovery endpoint.

The following arrangement is non-normative:

```text
Discovery endpoint: https://provider.example/.well-known/mc-dcat-ap
Catalogue endpoint: https://provider.example/mc-dcat-ap/3.0.1/
DSP connector root: https://provider.example/dsp
DSP version base:   https://provider.example/dsp/2025-1
```

Clients MUST follow the discovered absolute URL and MUST NOT construct it from
the version number or from the DSP location.

### 5.3 Versioning

The protocol version advertised by this document is `3.0.1`, aligned with the
required DCAT-AP release. A future protocol or DCAT-AP release MUST use a
distinct discovery version and profile identifier. Multiple versions MAY be
advertised concurrently.

## 6. Well-known discovery

### 6.1 Discovery endpoint

A Provider MUST expose:

```text
GET <origin>/.well-known/mc-dcat-ap
```

This use of `/.well-known/` follows
[RFC 8615](https://www.rfc-editor.org/rfc/rfc8615). The Discovery endpoint is
fixed at the origin level; only the discovered Catalogue endpoint is
path-independent.

The well-known suffix defined by this specification is `mc-dcat-ap`. Its
registration under the RFC 8615 procedure is part of publication of this
protocol as an Internet-wide standard; deployment documentation MUST NOT claim
that an unregistered suffix has already been registered.

The Discovery endpoint MUST:

- be available without authentication;
- return `200 OK` and `application/json` on success;
- return a UTF-8 JSON object conforming to Section 6.2;
- support `HEAD` with the same headers and no body;
- send `Access-Control-Allow-Origin: *`; and
- not redirect to a different origin.

### 6.2 Discovery document

The document MUST contain exactly one top-level required member, `services`,
whose value is a non-empty array. Additional top-level members MAY be present
and MUST be ignored by clients that do not understand them.

Each service entry MUST contain:

| Member | Type | Cardinality | Requirement |
|---|---|---:|---|
| `version` | string | `1` | Exact value `3.0.1` |
| `profile` | string | `1` | Exact Tier 0 profile IRI |
| `endpoint` | string | `1` | Absolute HTTPS Catalogue endpoint |
| `catalogueId` | string | `1` | Absolute IRI of the returned `dcat:Catalog` |
| `serviceId` | string | `1` | Absolute IRI of its Catalogue service |
| `dspVersionDiscovery` | string | `0..1` | Absolute HTTPS DSP version-discovery URL |

The exact `profile` value MUST be:

```text
tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-0
```

`endpoint` MUST NOT contain user information, a query, or a fragment.
`dspVersionDiscovery`, when present, MUST end in
`/.well-known/dspace-version` and identify a Materials Commons DSP Tier 1
companion.

Two entries MUST NOT have the same pair of `profile` and `catalogueId`.
Unknown entry members MAY be present and MUST be ignored by clients.

### 6.3 Discovery example

```json
{
  "services": [
    {
      "version": "3.0.1",
      "profile": "tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-0",
      "endpoint": "https://provider.example/mc-dcat-ap/3.0.1/",
      "catalogueId": "https://provider.example/catalogues/public",
      "serviceId": "https://provider.example/services/mc-dcat-ap",
      "dspVersionDiscovery": "https://provider.example/dsp/.well-known/dspace-version"
    }
  ]
}
```

### 6.4 Selection and failure behavior

A client selects entries by exact `profile` and `version`. It MUST NOT select
an entry solely from its endpoint path. If no supported entry exists, the
client MUST treat the origin as not offering this protocol.

Malformed JSON, a missing required member, a duplicate entry, an invalid URL,
or an unrecognized required version MUST make the affected document or entry
unusable. A client SHOULD continue considering other independently valid
entries when possible.

### 6.5 Caching

Discovery responses SHOULD provide `ETag`, `Last-Modified`, and an explicit
`Cache-Control` policy. Clients MAY cache them according to HTTP semantics and
SHOULD revalidate before assuming that a previously advertised endpoint has
been permanently removed.

## 7. Catalogue HTTPS endpoint

### 7.1 Retrieval

A Catalogue endpoint MUST support:

```text
GET <catalogue-endpoint>
HEAD <catalogue-endpoint>
```

`GET` MUST return `200 OK` and the Catalogue Representation. `HEAD` MUST
return the same representation headers without a body.

The endpoint MUST be public and MUST NOT require credentials, cookies, tokens,
or prior DSP negotiation.

### 7.2 Media type

The successful response MUST use:

```text
application/ld+json; profile="https://semiceu.github.io/DCAT-AP/releases/3.0.1/"
```

The profile parameter is a DCAT-AP 3.0.1 conformance claim. A response that has
not passed Section 12 validation MUST NOT use it.

The response SHOULD also contain:

```text
Link: <tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-0>; rel="profile"
```

### 7.3 Request headers and status codes

A client SHOULD send `Accept: application/ld+json`. A Provider MAY return
`406 Not Acceptable` when the request explicitly excludes JSON-LD.

| Status | Meaning |
|---:|---|
| `200 OK` | Successful retrieval |
| `304 Not Modified` | Conditional request matched cached representation |
| `406 Not Acceptable` | Requested representations exclude JSON-LD |
| `500 Internal Server Error` | No valid snapshot can be emitted |
| `503 Service Unavailable` | Catalogue temporarily unavailable |

The endpoint MUST NOT return `401` or `403` merely because authorization is
absent.

### 7.4 Caching and CORS

The response SHOULD provide `ETag`, `Last-Modified`, and `Cache-Control`, and
SHOULD honor `If-None-Match` and `If-Modified-Since`. It MUST send
`Access-Control-Allow-Origin: *`.

## 8. RDF and JSON-LD representation

### 8.1 Normative graph

The expanded RDF graph is normative. JSON object ordering, RDF-irrelevant
array ordering, blank-node labels, whitespace, and compact versus expanded IRI
spelling are not normative.

The response MUST:

- be valid UTF-8 JSON;
- be valid JSON-LD 1.1;
- expand without network-dependent context ambiguity;
- parse as an RDF graph; and
- contain the graph defined in Sections 9 through 11.

### 8.2 Context

The document SHOULD use an inline, provider-owned, `@protected` context
covering every compact term it uses. A remote context MAY be used only when it
is stable, HTTPS, and available for offline pinning. Undefined compact prefixes
MUST NOT be used.

IRI-valued DCAT properties MUST expand as IRIs or blank nodes, never as string
literals. This requirement especially applies to `dcat:endpointURL`,
`dcat:accessURL`, `dcat:downloadURL`, `dcat:mediaType`,
`dcat:accessService`, `dcat:servesDataset`, and `dct:conformsTo`.

### 8.3 Snapshot consistency

One response MUST describe one internally consistent snapshot. Identifiers
MUST be unique in their applicable resource family. References MUST resolve to
nodes in the graph when this profile requires those nodes to be present.

## 9. Catalogue, publisher, and datasets

### 9.1 Catalogue

The graph MUST contain exactly one primary catalogue node with:

| Property | Cardinality | Requirement |
|---|---:|---|
| `rdf:type` | `1..*` | Includes `dcat:Catalog` |
| `dct:title` | `1..*` | At least one non-empty literal |
| `dct:description` | `1..*` | At least one non-empty literal |
| `dct:publisher` | `1` | Publisher Agent in Section 9.2 |
| `dcat:dataset` | `1..*` | Every Tier 0 dataset |
| `dcat:service` | `1..*` | Catalogue service and companion services |
| `dct:conformsTo` | `2..*` | Both Tier 0 and DCAT-AP profile IRIs |

Its IRI MUST equal the discovery entry's `catalogueId`. These requirements
specialize DCAT
[Catalog](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#Class:Catalog)
and DCAT-AP
[Catalogue](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#Catalogue).

`dct:conformsTo` MUST include:

```text
tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-0
https://semiceu.github.io/DCAT-AP/releases/3.0.1/
```

Each referenced conformance resource MUST be asserted as a `dct:Standard` in
the graph.

### 9.2 Publisher Agent

The publisher MUST have a stable absolute IRI, type `foaf:Agent`, and at least
one non-empty `foaf:name`, satisfying
[DCAT-AP Agent](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#Agent).

Every dataset MUST use the same `dct:publisher` Agent. Additional creators or
contributors MAY differ.

### 9.3 Dataset

Each dataset MUST have:

| Property | Cardinality | Requirement |
|---|---:|---|
| `rdf:type` | `1..*` | Includes `dcat:Dataset` |
| `dct:title` | `1..*` | Non-empty literal |
| `dct:description` | `1..*` | Non-empty literal |
| `dct:publisher` | `1` | Catalogue publisher |
| `odrl:hasPolicy` | `1` | Section 9.4 public-use offer |
| `dcat:distribution` | `1` | Exactly one Section 10 distribution |

Dataset IRIs MUST be unique. This specializes DCAT
[Dataset](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#Class:Dataset)
and DCAT-AP
[Dataset](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#Dataset).

### 9.4 Public-use ODRL offer

The dataset MUST link to one `odrl:Offer` with one permission whose action is
`odrl:use`. The offer MUST NOT contain constraints, duties, prohibitions,
remedies, or a target conflicting with the dataset. The policy expresses
unconditional technical access; it does not replace licence, copyright,
attribution, citation, or ethical-use metadata.

## 10. Distribution and file metadata

### 10.1 Distribution

Each Tier 0 dataset MUST have exactly one distribution with:

| Property | Cardinality | Requirement |
|---|---:|---|
| `rdf:type` | `1..*` | Includes `dcat:Distribution` |
| `dct:format` | `1` | EU File Type concept IRI typed `dct:MediaTypeOrExtent` |
| `dcat:mediaType` | `1` | IANA media-type IRI typed `dct:MediaType` |
| `dcat:accessURL` | `1` | Direct public HTTPS URL |
| `dcat:downloadURL` | `1` | Same direct public HTTPS URL |
| `dcat:accessService` | `0..1` | Data service that actually supplies access |
| `dcat:byteSize` | `0..1` | Non-negative integer |
| `spdx:checksum` | `0..1` | Section 10.3 checksum |

These specialize the DCAT
[Distribution](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#Class:Distribution),
[access URL](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#Property:distribution_access_url),
[download URL](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#Property:distribution_download_url),
[media type](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#Property:distribution_media_type),
[format](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#Property:distribution_format),
and [byte size](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#Property:distribution_size),
and the DCAT-AP
[Distribution](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#Distribution).

`dcat:accessService`, when present, MUST reference a `dcat:DataService` in the
graph that genuinely provides access to the distribution. The Catalogue
service MUST NOT be used merely because it describes the distribution.

### 10.2 Controlled format and media type

The mandatory DCAT-AP
[controlled-vocabulary rules](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#properties-with-controlled-vocabularies-that-must-be-used-for-the-listed-properties)
apply.

| Representation | `dct:format` | `dcat:mediaType` |
|---|---|---|
| CSV | `http://publications.europa.eu/resource/authority/file-type/CSV` | `https://www.iana.org/assignments/media-types/text/csv` |
| JSON | `http://publications.europa.eu/resource/authority/file-type/JSON` | `https://www.iana.org/assignments/media-types/application/json` |

Another representation MAY be used only when both an applicable EU File Type
concept and IANA media-type IRI are supplied.

The graph MUST explicitly assert the selected format resource as a
`dct:MediaTypeOrExtent` and the selected media-type resource as a
`dct:MediaType`. Loading a controlled-vocabulary document during validation
does not replace these assertions in the published graph.

### 10.3 Byte size and checksum

Byte size and checksum are independently OPTIONAL. When present:

- `dcat:byteSize` MUST be the number of octets at `dcat:downloadURL`;
- the checksum node MUST have type `spdx:Checksum`;
- it MUST have exactly one `spdx:algorithm`, equal to the normative SHA-256
  algorithm IRI; and
- it MUST have exactly one `spdx:checksumValue`, a 64-character lower-case
  hexadecimal value typed as `xsd:hexBinary`.

This follows DCAT
[checksum](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#Property:distribution_checksum)
and DCAT-AP
[Checksum](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#Checksum).

The values are publisher assertions and MUST NOT knowingly be stale or false.
They need not be recomputed during each request.

## 11. Data services and cross-protocol discovery

### 11.1 Catalogue service

The graph MUST contain exactly one Catalogue service whose IRI equals the
discovery entry's `serviceId`. It MUST have:

| Property | Cardinality | Requirement |
|---|---:|---|
| `rdf:type` | `1..*` | Includes `dcat:DataService` |
| `dct:title` | `1..*` | Non-empty literal |
| `dcat:endpointURL` | `1` | Catalogue endpoint as an IRI |
| `dct:conformsTo` | `2..*` | Tier 0 and DCAT-AP profile IRIs |
| `dcat:servesDataset` | `1..*` | Every dataset in the catalogue |

The endpoint URL MUST be an RDF IRI, not a literal. These requirements
specialize DCAT
[Data Service](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/#Class:Data_Service)
and DCAT-AP
[Data Service](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#DataService).

Every `dct:conformsTo` value MUST be asserted as a `dct:Standard`.

### 11.2 Other public services

The catalogue MAY describe additional public data services. Each MUST have a
stable IRI, type `dcat:DataService`, title, at least one IRI-valued endpoint
URL, at least one standards IRI in `dct:conformsTo`, and at least one known
dataset in `dcat:servesDataset`. An optional `dcat:endpointDescription` SHOULD
identify a machine-readable API description.

Each standards IRI used by such a service MUST be asserted as a
`dct:Standard`.

### 11.3 Materials Commons DSP Tier 1 companion

When a DSP companion exists:

- the well-known discovery entry SHOULD contain `dspVersionDiscovery`;
- the catalogue MUST include the DSP access service as a `dcat:DataService`;
- that service's `dct:conformsTo` MUST include the Materials Commons DSP Tier 1
  profile IRI and
  `https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/`,
  with both resources asserted as `dct:Standard`;
- its `dcat:endpointURL` MUST be the discovered DSP version base as an RDF IRI;
  and
- `dcat:servesDataset` MUST identify the datasets available through DSP.

The DSP catalogue reciprocally advertises this Catalogue service using the
mechanism in **Materials Commons DSP Tier 1, Section 9**.

The DCAT-AP graph MUST use an IRI-valued `dcat:endpointURL`, even though the DSP
serialization of its own DataService uses a JSON string. This independent
serialization is the purpose of the companion protocol split.

## 12. Validation

### 12.1 Required validation

Every emitted Catalogue Representation MUST pass:

1. UTF-8 and JSON parsing;
2. JSON-LD 1.1 expansion;
3. RDF graph parsing;
4. DCAT-AP 3.0.1 mandatory-property validation;
5. DCAT-AP 3.0.1 range validation;
6. DCAT-AP 3.0.1 controlled-vocabulary validation; and
7. all Tier 0 cardinality, datatype, identity, and consistency rules in this
   document.

DCAT-AP validation is described in
[Section 17.3](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#validation)
and
[Section 18](https://semiceu.github.io/DCAT-AP/releases/3.0.1/#validation-of-dcat-ap).

### 12.2 Offline validation

Providers SHOULD validate with pinned copies of the official DCAT-AP shapes,
range constraints, controlled-vocabulary material, and SPDX checksum
vocabulary. Runtime conformance MUST NOT depend on the availability or mutable
content of a remote vocabulary server.

Pinned material MUST retain provenance, source URLs, retrieval dates, licences,
and integrity hashes.

### 12.3 Failure behavior

A Provider MUST NOT emit a knowingly invalid graph with the DCAT-AP profile
media type. If no valid snapshot is available, it MUST fail the request with
`500` or `503` rather than weaken or omit mandatory validation.

## 13. Public distribution behavior

The direct `dcat:downloadURL`:

- MUST support unauthenticated `GET`;
- MUST support `HEAD` with matching metadata and no body;
- MUST return the advertised media type;
- MUST return `Content-Length` when known;
- SHOULD support byte ranges;
- SHOULD provide `ETag`, `Last-Modified`, or both; and
- MUST return ordinary HTTP errors when unavailable.

Replacing a representation does not automatically update publisher-supplied
size or checksum metadata. The Provider SHOULD update the catalogue promptly.

## 14. Synchronization with a DSP companion

When the same publication is offered through both Materials Commons protocols,
the following MUST agree for the same snapshot:

- catalogue identifier;
- publisher identifier and name;
- dataset identifiers, titles, and descriptions;
- distribution identifiers;
- public access and download URLs;
- EU File Type and IANA media-type IRIs;
- byte size and checksum when supplied; and
- dataset membership of each shared service.

The DCAT-AP graph MAY include additional DCAT-AP metadata that cannot be
represented safely in DSP. The DSP document MAY include negotiation and
transfer metadata that has no role in this graph.

The two endpoints need not complete requests atomically. Short-lived
differences between snapshots SHOULD be minimized, and contradictory metadata
MUST NOT be deliberately published.

## 15. Security and privacy

Discovery, catalogue, and distributions are public. A Provider MUST NOT vary
their membership or content by caller identity or credentials.

All traffic MUST use HTTPS with certificate and hostname validation. Responses
MUST NOT expose local paths, database identifiers, private network addresses,
credentials, access tokens, stack traces, or private participant data.

Clients MUST treat all discovered endpoints and RDF IRIs as untrusted input.
Automatic dereferencing SHOULD enforce HTTPS, redirect limits, response-size
limits, timeouts, and protections against access to non-public network
addresses.

## 16. Extensibility

Discovery documents MAY contain unknown members, and RDF graphs MAY contain
additional DCAT-AP-conformant properties and classes. Clients MUST ignore
unknown discovery members unless a future specification marks them required.

Additional catalogue metadata MAY include language variants, licences, themes,
keywords, provenance, temporal or spatial coverage, documentation, dataset
series, catalogue records, and identifiers.

Extensions MUST NOT:

- change the meaning of a required member;
- make public retrieval conditional;
- replace a direct download URL with a landing page;
- violate DCAT-AP cardinality, range, or controlled-vocabulary rules;
- use the Tier 0 profile IRI for a different protocol version; or
- contradict an advertised DSP companion.

## 17. Conformance checklist

### 17.1 Discovery

- [ ] `GET <origin>/.well-known/mc-dcat-ap` is public and returns JSON.
- [ ] `HEAD` and wildcard CORS are supported.
- [ ] Every entry has exact version and profile values.
- [ ] Endpoint, catalogue ID, and service ID are absolute and valid.
- [ ] Endpoint paths are discovered, not constructed.
- [ ] Optional DSP discovery URLs end in `/.well-known/dspace-version`.

### 17.2 Catalogue endpoint

- [ ] `GET` and `HEAD` are unauthenticated.
- [ ] Successful `GET` uses the exact profiled JSON-LD media type.
- [ ] The response is valid JSON-LD and RDF.
- [ ] Cache validators and wildcard CORS are provided.
- [ ] Invalid graphs are not served under the conformance media type.

### 17.3 RDF graph

- [ ] Exactly one primary Catalogue has title, description, publisher,
      datasets, services, and conformance IRIs.
- [ ] The publisher is one named Agent shared by all datasets.
- [ ] At least one Dataset has title, description, public-use offer, and one
      Distribution.
- [ ] Every Distribution has EU format, IANA media type, and equal direct
      access and download URLs.
- [ ] Optional sizes and checksums use the required values and datatypes.
- [ ] The Catalogue service endpoint is an RDF IRI and matches discovery.
- [ ] Every service has known served datasets and standards identifiers.

### 17.4 Validation and companion consistency

- [ ] Mandatory, range, and controlled-vocabulary validation passes.
- [ ] Validation can use pinned offline standards material.
- [ ] Public distribution URLs support required HTTP behavior.
- [ ] If DSP is advertised, the reciprocal service advertisements exist.
- [ ] Shared identifiers and metadata agree across protocols.

## Appendix A. Minimal JSON-LD example (non-normative)

```json
{
  "@context": {
    "@version": 1.1,
    "@protected": true,
    "dcat": "http://www.w3.org/ns/dcat#",
    "dct": "http://purl.org/dc/terms/",
    "foaf": "http://xmlns.com/foaf/0.1/",
    "odrl": "http://www.w3.org/ns/odrl/2/",
    "spdx": "http://spdx.org/rdf/terms#",
    "xsd": "http://www.w3.org/2001/XMLSchema#",
    "Catalog": "dcat:Catalog",
    "Dataset": "dcat:Dataset",
    "Distribution": "dcat:Distribution",
    "DataService": "dcat:DataService",
    "Agent": "foaf:Agent",
    "Standard": "dct:Standard",
    "MediaType": "dct:MediaType",
    "MediaTypeOrExtent": "dct:MediaTypeOrExtent",
    "title": "dct:title",
    "description": "dct:description",
    "publisher": {"@id": "dct:publisher", "@type": "@id"},
    "dataset": {"@id": "dcat:dataset", "@type": "@id", "@container": "@set"},
    "distribution": {"@id": "dcat:distribution", "@type": "@id"},
    "service": {"@id": "dcat:service", "@type": "@id", "@container": "@set"},
    "format": {"@id": "dct:format", "@type": "@id"},
    "mediaType": {"@id": "dcat:mediaType", "@type": "@id"},
    "accessURL": {"@id": "dcat:accessURL", "@type": "@id"},
    "downloadURL": {"@id": "dcat:downloadURL", "@type": "@id"},
    "endpointURL": {"@id": "dcat:endpointURL", "@type": "@id"},
    "servesDataset": {"@id": "dcat:servesDataset", "@type": "@id", "@container": "@set"},
    "conformsTo": {"@id": "dct:conformsTo", "@type": "@id", "@container": "@set"},
    "hasPolicy": {"@id": "odrl:hasPolicy", "@type": "@id"},
    "permission": {"@id": "odrl:permission", "@container": "@set"},
    "action": {"@id": "odrl:action", "@type": "@id"}
  },
  "@id": "https://provider.example/catalogues/public",
  "@type": "Catalog",
  "title": "Public materials catalogue",
  "description": "Public datasets and services.",
  "conformsTo": [
    {
      "@id": "tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-0",
      "@type": "Standard"
    },
    {
      "@id": "https://semiceu.github.io/DCAT-AP/releases/3.0.1/",
      "@type": "Standard"
    }
  ],
  "publisher": {
    "@id": "https://provider.example/participants/provider",
    "@type": "Agent",
    "foaf:name": "Example Provider"
  },
  "dataset": [{
    "@id": "https://provider.example/datasets/example",
    "@type": "Dataset",
    "title": "Example materials dataset",
    "description": "A public example dataset.",
    "publisher": "https://provider.example/participants/provider",
    "hasPolicy": {
      "@id": "https://provider.example/datasets/example#offer",
      "@type": "odrl:Offer",
      "permission": [{"action": "odrl:use"}]
    },
    "distribution": {
      "@id": "https://provider.example/datasets/example#distribution",
      "@type": "Distribution",
      "format": {
        "@id": "http://publications.europa.eu/resource/authority/file-type/CSV",
        "@type": "MediaTypeOrExtent"
      },
      "mediaType": {
        "@id": "https://www.iana.org/assignments/media-types/text/csv",
        "@type": "MediaType"
      },
      "accessURL": "https://provider.example/files/example.csv",
      "downloadURL": "https://provider.example/files/example.csv"
    }
  }],
  "service": [{
    "@id": "https://provider.example/services/mc-dcat-ap",
    "@type": "DataService",
    "title": "Public Materials Commons DCAT-AP catalogue",
    "endpointURL": "https://provider.example/mc-dcat-ap/3.0.1/",
    "conformsTo": [
      {
        "@id": "tag:materialscommons.eu,2026:mc-dcat-ap/prototype-tier-0",
        "@type": "Standard"
      },
      {
        "@id": "https://semiceu.github.io/DCAT-AP/releases/3.0.1/",
        "@type": "Standard"
      }
    ],
    "servesDataset": ["https://provider.example/datasets/example"]
  }]
}
```

## Appendix B. Normative references

- **DCAT 3** — [Data Catalog Vocabulary (DCAT), Version 3, W3C Recommendation 22 August 2024](https://www.w3.org/TR/2024/REC-vocab-dcat-3-20240822/).
- **DCAT-AP 3.0.1** — [DCAT Application Profile for data portals in Europe, Version 3.0.1](https://semiceu.github.io/DCAT-AP/releases/3.0.1/).
- **JSON-LD 1.1** — [JSON-LD 1.1](https://www.w3.org/TR/json-ld11/).
- **ODRL** — [ODRL Information Model 2.2](https://www.w3.org/TR/odrl-model/).
- **RFC 2119** — [Key words for use in RFCs to Indicate Requirement Levels](https://www.rfc-editor.org/rfc/rfc2119).
- **RFC 8174** — [Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words](https://www.rfc-editor.org/rfc/rfc8174).
- **RFC 6906** — [The `profile` Link Relation Type](https://www.rfc-editor.org/rfc/rfc6906).
- **RFC 8615** — [Well-Known Uniform Resource Identifiers](https://www.rfc-editor.org/rfc/rfc8615).

## Appendix C. Informative references

- **DSP 2025-1-err1** — [Dataspace Protocol 2025-1, errata revision 1](https://eclipse-dataspace-protocol-base.github.io/DataspaceProtocol/2025-1-err1/).
- **Materials Commons DSP Tier 1** — [Companion protocol](materials-commons-dsp-tier1.md).
