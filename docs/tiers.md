# The tier model

## Status of this document

Non-normative. This page explains how the Materials Commons tiers relate to each other, to the
Dataspace Protocol, and to the profiles that specify them. It records what has been settled and
what has not.

The ladder was reopened once Tier 1 had been checked against the Dataspace Protocol in detail,
and the result is below. Items that are still open are collected in Section 8 so they can be
argued against rather than rediscovered.

## 1. What a tier is

A tier is a **publication level** that a Materials Commons participant implements, described by
how much of the Dataspace Protocol it uses. Tier 0 uses none of it, Tier 1 uses the catalogue
schema and the catalogue interaction, and from Tier 2 upward the protocol itself is implemented.
A tier is not a security level, a trust level, or a statement about the data.

Two properties, both agreed:

1. **A tier is a minimum feature set.** A provider that implements more than its tier requires
   does not lose the tier. An implementation claiming Tier 1 may also support authentication;
   consumers simply cannot rely on it.
2. **Claiming a tier means the functionality of every tier below it is available too.**
   Three things do not carry upward. The Tier 0 DCAT-AP GET protocol is a separate conformance
   claim and stays optional at every higher tier. The gated download that Tier 0 permits has no
   counterpart at Tier 1, where every endpoint and every distribution is unauthenticated. And the
   Tier 1 guarantee that every advertised dataset is retrievable without credentials binds Tier 1
   alone; Tier 2 exists to make access depend on the caller.

The consequence is that a tier is a promise to a consumer about the *least* it can expect, not a
description of the provider's deployment.

Always write "Materials Commons tiers of DSP implementation" on first use. The word "tier"
collides with the security profile tiers of the older data space reference architecture, and this
naming is to be revisited before a release version.

## 2. The ladder

Tier 0 and Tier 1 have specification text. Tier 2 and Tier 3 have outlines only.

| Tier | Criterion | Adds over the tier below | Specification |
|---|---|---|---|
| **0** | Static DCAT-AP catalogue with direct download URLs. Conformant to DCAT-AP, outside DSP. The download may be gated behind a bearer token. | Entry level. A catalogue document a harvester can read and distributions it can fetch. The catalogue is a static file; a gated download is not, because it has to check a token. | [DCAT-AP GET Protocol Tier 0](materials-commons-dcat-ap-get-protocol-tier-0.md) |
| **1** | The DSP catalogue schema, catalogue pagination, and the DSP catalogue interaction. No contract negotiation and no transfer process, so no DSP conformance claim. | A catalogue request endpoint in place of a fixed document, so a catalogue too large to pre-compute can be generated per request and paged. DCAT-AP from the same endpoint by profile content negotiation. Public read throughout. | [DSP Tier 1](materials-commons-dsp-tier1.md) |
| **2** | Contract negotiation, with ODRL policy that carries more than an empty condition. Endpoints are authenticated, and catalogue content and access decisions may depend on the caller. | The DSP control plane: negotiation state machines, provider-initiated callbacks, agreements, the transfer process, and a policy evaluation that can refuse a well-formed request. | [DSP Tier 2](materials-commons-dsp-tier2.md), outline |
| **3** | Full protocol. The remaining optional DSP capabilities. | Provider-initiated and multi-round negotiation, push and streaming transfers, catalogue brokers, DID-based service discovery. | [DSP Tier 3](materials-commons-dsp-tier3.md), outline |

Tier 2 is the first tier that has a contract negotiation at all, and therefore the first at which
a request can be refused for a reason other than malformed input.

The Tier 1 document is titled "Public Datasets and Services" and its file name says `dsp-tier1`.
Neither matches a catalogue-only scope. The naming is to be decided, and nothing is renamed until
it is.

## 3. Why Tier 1 does not claim DSP conformance

Tier 1 implements the DSP catalogue schema, the catalogue request and dataset request
interaction, and catalogue pagination. It implements none of contract negotiation and none of
the transfer process. A profile that leaves those out cannot claim conformance to DSP, and
Tier 1 no longer does.

There is also nothing narrower to claim. DSP defines no conformance class for a catalogue alone,
so "DSP catalogue conformance" is not a statement anyone can make. What a Tier 1 Provider
conforms to is this profile, and within it the official DSP JSON Schemas and the protected DSP
JSON-LD context for the catalogue messages it serves.

Two pressures produced the decision. A catalogue of several million datasets with no
pre-computed form has to be generated from search results per request and paged, which Tier 0
cannot do and which needs no negotiation. At the other end, full DSP requires the consumer to
operate a reachable inbound endpoint, which is the requirement that cannot be placed on an
ordinary participant. Participation was given priority over the conformance claim.

The consequence for consumers is that a Tier 1 `DataService` answers catalogue requests and
nothing else. A consumer that wants an agreement needs a Tier 2 provider, or a connector
operated on the publisher's behalf, Section 6.

## 4. Why Tier 0 is not a DSP tier

A static file host cannot be a DSP provider. This is not a consequence of the catalogue request
being a `POST`, and it would not be fixed by relaxing that:

- The provider must **initiate** requests to the consumer's `callbackAddress`
  (`ContractAgreementMessage`, the `FINALIZED` event, `TransferStartMessage`). Static hosting
  cannot originate an HTTP request.
- `providerPid` is **minted per process**, and the negotiation and transfer state machines
  require mutation with commit-only-after-`2xx`. No file can be pre-generated for an identifier
  that does not yet exist.
- Eleven of the fifteen DSP provider endpoints are `POST`, as listed in
  [DSP Tier 1, Section 5.2](materials-commons-dsp-tier1.md).

The first two are obligations of a DSP **Connector**. The Catalog Protocol names a **Catalog
Service** as a separate role, so a catalogue-only service is a coherent idea, but DSP defines no
conformance classes for it and the catalogue must still advertise a `DataService` at which
negotiation and transfer are initiated. Tier 1 occupies that role and accepts the consequence in
Section 3: it serves a DSP catalogue without claiming DSP conformance.

Tier 0 therefore exists because a catalogue-only level is structurally necessary, not as a
placeholder for a future protocol change. It is what lets a research group participate with a
file on static hosting.

This was put to the Dataspace Protocol maintainers in
[discussion 276](https://github.com/eclipse-dataspace-protocol-base/DataspaceProtocol/discussions/276)
and the reading was confirmed, on the stronger ground that static hosting makes no per-request
decision at all: the process state, the callbacks and the POST are consequences of there being a
decision to make. Their position is that a data space begins where an access decision is made,
so open data is served by a catalogue vocabulary rather than by the protocol. Merging Tier 0 into
the DSP catalogue endpoint should therefore not be assumed.

The same constraint applies to the consumer side, which was confirmed in
[issue 281](https://github.com/eclipse-dataspace-protocol-base/DataspaceProtocol/issues/281).
A consumer that cannot accept an inbound connection is not a DSP consumer: `callbackAddress` is
where every provider-initiated transition arrives, including the agreement, finalization, and
transfer start, suspension, completion and termination. Polling a state resource is not a
substitute, because transitions can be missed between polls and the offer content never appears
in the state resource.

So DSP requires a reachable participant agent at both ends. Nothing requires that agent to be the
same process, machine or operator as the application using it, so a client on a network that
permits no inbound connections participates through an agent rather than directly.

Two consequences for this tier model. Reachability is what separates the tiers that negotiate
from the tiers that do not: Tier 0 and Tier 1 need it at neither end, and every tier that
negotiates or transfers needs it at both. That is why the catalogue-only levels sit below the
protocol rather than inside it. And any tier that negotiates has to say what a participant may
delegate to an agent operated by somebody else.

## 5. Why the catalogue-only level was renumbered

The DCAT-AP GET Protocol was originally numbered Tier 1, which meant three different things
carried that number: the DSP profile, the DCAT-AP GET profile, and the first lane of the feature
board. Renumbering the GET profile to Tier 0 removes the collision and places both specifications
on one ladder.

This was a rename, not new work: the DCAT-AP GET Protocol already specified exactly this level.
It changed the document title, the `tag:` profile IRI, and the cross-references in DSP Tier 1.
Both documents remain prototype drafts, so the numbering is open to revision.

The migration property that makes the ladder worth having is that **Tier 0 to Tier 1 leaves the
assets untouched**. The files, their URLs, their formats and their licences are unchanged, and the
catalogue keeps its identifiers. What the publisher adds is protocol scaffolding: a
`participantId`, an offer carrying the fixed `use` permission that the DSP schema requires, an
`accessService` on every distribution, the DSP `format` string alongside the `dct:format` node,
and the prefixed `dcat:servesDataset` spelling.

What the publisher also has to add is a running service. Tier 0 is a document; Tier 1 answers a
`POST` and paginates. That step, rather than the payload, is the cost of moving up.

## 6. Serving a catalogue for a connector somebody else operates

Narrowing Tier 1 to the catalogue settled the first half of what used to be proposed here. Tier 1
is the catalogue-only conformance target, so a participant that serves a catalogue and operates
no connector now describes exactly one tier rather than half of one.

What remains open is the other half. DSP requires every advertised `DataService` to be backed by
a working connector, and Tier 1 does not operate one. A shared connector, for example one run by
the common node, can perform negotiation and transfer on behalf of catalogue-only publishers. It
never handles the data: the `DataAddress` in the Transfer Start Message carries the publisher's
own public URL, and DSP places no host constraint on it.

Known costs, unresolved:

- `Agreement.assigner` would name the shared connector rather than the publisher.
- `Catalog.participantId` is required, so a broker-served publisher becomes content inside
  another participant's catalogue rather than a participant of its own.
- The pattern only works while the data behind the catalogue is ungated, which Tier 1 guarantees.
  At Tier 2 the shared connector would need credentials for another participant's data, which is
  where it must stop.

## 7. Where authentication fits

DSP leaves token semantics unspecified deliberately, and provides two extension points: the
`Authorization` header on every endpoint, and the `auth` object in the version response naming
`protocol`, `version` and `profile`.

OAuth 2.0 with JWT access tokens is a legitimate fill for those extension points, not a deviation
from DSP. Verifiable credentials through the Decentralized Claims Protocol are a different fill
for the same extension points, and are equally outside DSP.

Every DSP exchange is machine to machine between participants, so the relevant profile is the
client credentials grant with signed JWT bearer tokens, validated against the issuing authority's
public keys. OpenID Connect is a different layer and applies to a hop that is not part of DSP:
a person signing in to their own participant's services. Conflating the two points an
implementation at the wrong specifications.

Where the token sits determines which tier the deployment is at:

| Token presented at | Tier |
|---|---|
| A direct download URL, with no connector | 0, through the optional gated access in the Tier 0 profile. The DSP control plane never sees it. |
| The DSP endpoints | 2 |
| The `DataAddress` of a Transfer Start Message, minted by the connector | 2 |

Gated access at Tier 0 is discovered through RFC 9728 OAuth Protected Resource Metadata, which
names the authorization server for a download URL. Neither that server nor the host of the bytes
need belong to the publisher, so a third party holding the files can accept a token carrying a
claim the publisher controls. A group can therefore be given access without anyone running a
connector, which was previously assumed to need Tier 2.

Two parts of that stay static: the catalogue and the protected resource metadata are fixed
files. The gated download is not, because RFC 9728 and RFC 6750 require it to answer an
unauthorised request with `401` and a `WWW-Authenticate` challenge and then validate a token on
the retry. Static hosting serves the bytes to anyone holding the URL. The property that keeps
this at Tier 0 is the absence of a connector rather than the absence of a server.

Tier 1 has no place in this table. Its endpoints and its distributions are unauthenticated
throughout.

## 8. Open decisions

Still to settle:

- How a Tier 1 catalogue advertises a connector operated by somebody else, Section 6.
- Grouping the remaining compliance targets into tiers without ending up with eight of them.
  Roughly half of the inventory is still unassigned.
- The filter language a Tier 2 provider must support. JSONPath is proposed as the baseline that
  any provider can meet, with SPARQL optional and a mechanism for advertising more than one.
  Whether catalogue filter expressions belong at Tier 1 is open; pagination is settled and is
  required at Tier 1.
- The profile parameter value for the Materials DCAT-AP representation, and whether to register
  a profile URI or a vendor media type for it.
- Whether current academic repositories can act as an RFC 9728 protected resource against an
  external authorization server. Unverified. Several gate restricted records through their own
  access-request and session model, and if that is the general case, a static catalogue paired
  with third-party gated storage is not satisfiable with present services.
- Whether DCAT-AP tolerates the Materials DCAT-AP extensions, and where a licence sits relative
  to an ODRL policy, which DCAT-AP places at different levels of the structure.
- The trust overlay for Tier 2. The Decentralized Claims Protocol with a self-hosted issuer is
  more viable than the earlier drafts assumed, which reopens a decision that read as settled in
  favour of OAuth 2.0 with a shared authorization server.
- The name "tier" itself, and the name of the Tier 1 document now that its scope has narrowed.

Deprioritised rather than open: a relay server that would let a client without an inbound
endpoint take part in DSP by proxying the bidirectional exchange. The tiers are designed without
it, and DSP is introduced at the level where it is needed. The relay is revisited only if a
DSP-only data space has to be joined.
