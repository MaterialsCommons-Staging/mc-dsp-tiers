# The tier model

## Status of this document

Non-normative. This page explains how the Materials Commons tiers relate to each other, to the
Dataspace Protocol, and to the profiles that specify them. It records what has been settled and
what has not.

The ladder was reopened once Tier 1 had been checked against the Dataspace Protocol in detail,
and it is now settled. Items that remain open are collected in Section 9 so they can be argued
against rather than rediscovered.

## 1. What a tier is

A tier is a **publication level** that a Materials Commons participant implements, described by
how much of the Dataspace Protocol it uses. Tier 0 uses none of it, Tier 1 uses the catalogue
schema and the catalogue interaction, Tier 2 is a full DSP implementation, and Tier 3 adds what
DSP leaves optional. A tier is not a security level, a trust level, or a statement about the data.

Materials Commons is the federated data space, and these are its tiers. The set is named
**Materials Commons tiers** rather than "DSP tiers", because only Tier 2 and Tier 3 are DSP
implementations. Write it out on first use: the word "tier" collides with the security profile
tiers of the older data space reference architecture.

Three properties, all agreed:

1. **A tier is a minimum feature set.** A provider that implements more than its tier requires
   does not lose the tier.
2. **Claiming a tier means the functionality of every tier below it is available too.** One
   thing does not carry upward: the Tier 0 DCAT-AP GET protocol is a separate conformance claim
   and stays optional at every higher tier.
3. **Gating belongs to no tier.** A catalogue and a download may each be gated behind a bearer
   token at every level, and nothing obliges a provider to gate anything. What a tier fixes is
   what a client claiming that tier must be able to follow when it meets a gate. Section 3
   explains why that does not break property 2.

The consequence is that a tier is a promise to a consumer about the *least* it can expect, rather
than a description of the provider's deployment.

## 2. The ladder

Tier 0 and Tier 1 have specification text. Tier 2 and Tier 3 have outlines only.

| Tier | Criterion | Adds over the tier below | Specification |
|---|---|---|---|
| **0** | Static DCAT-AP catalogue at a well-known location, with direct download URLs. Conformant to DCAT-AP, outside DSP. | Entry level. A catalogue document a harvester can read and distributions it can fetch. | [Tier 0](materials-commons-dcat-ap-get-protocol-tier-0.md) |
| **1** | A catalogue endpoint rather than a file. DSP catalogue schema by default, DCAT-AP on request by profile. Pagination and catalogue interaction. No contract negotiation and no transfer process, so no DSP conformance claim. | A request a provider answers in place of a fixed document, so a catalogue too large to pre-compute can be generated per request and paged. DCAT-AP from the same endpoint by profile selection. Downloads stay plain `GET`. | [Tier 1](materials-commons-dsp-tier1.md) |
| **2** | The first actual DSP implementation: every required DSP feature, meaning contract negotiation, policy evaluation and the transfer state machine. | The DSP control plane. An ODRL policy that carries terms, a negotiation that can refuse a well-formed request, provider-initiated callbacks, agreements, and a transfer process. | [Tier 2](materials-commons-dsp-tier2.md), outline |
| **3** | Everything DSP leaves optional. | Provider-initiated and multi-round negotiation, push and streaming transfers, catalogue brokers, nested sub-catalogues, catalogue filter expressions, DID-based service discovery. | [Tier 3](materials-commons-dsp-tier3.md), outline |

Two boundaries carry the weight. Tier 0 to Tier 1 is a document becoming an endpoint. Tier 1 to
Tier 2 is a catalogue becoming a protocol, which is where a participant first has to run a
connector and answer inbound requests.

Tier 1 losing the DSP conformance claim moved everything above it up one rung, and made the upper
half simpler: Tier 2 is now the required DSP feature set and Tier 3 the optional remainder.

Gating appears in none of the criteria. It is available at every tier, per Section 3.

## 3. Gating, and why additivity survives it

A catalogue or a download may be gated behind an OAuth 2.0 bearer token, discovered through
RFC 9728 protected resource metadata. The mechanism is specified once, in
[Tier 0, Section 13.2](materials-commons-dcat-ap-get-protocol-tier-0.md), and
[Tier 1, Section 10.3](materials-commons-dsp-tier1.md) adopts it unchanged.

Two framings matter.

**Gating is an expectation on clients.** No provider is required to gate anything. What a tier
fixes is the exchange a client claiming that tier has to be able to follow, so that a gate placed
by one participant is not a private arrangement another cannot use.

**The party publishing the catalogue need not be the party holding the gated asset.** A catalogue
can point at bytes someone else serves and gates, against a token carrying a claim the publisher
controls. A publisher with one restricted dataset among many therefore stays where it is instead
of being pushed up a tier, and a group with no infrastructure of its own can still share
selectively.

The objection this raises is worth stating plainly, because anyone reading the ladder will reach
it. Tiers are meant to be gained and never lost. If a low tier carries an RFC 9728 side channel,
would an off-the-shelf connector fail to claim the low tier while implementing the high one?

No. The side-channel declarations are themselves DSP catalogue compatible: DSP functionality plus
extras that DSP accommodates. DSP deliberately leaves token details open, so a connector that does
not implement one particular token exchange is a gap that already exists in DSP rather than one
this model introduces. Specifying the mechanism precisely narrows that gap. Additivity holds.

## 4. Why Tier 1 does not claim DSP conformance

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
operated on the publisher's behalf, Section 7.

## 5. Why Tier 0 is not a DSP tier

A static file host cannot be a DSP provider. This is not a consequence of the catalogue request
being a `POST`, and it would not be fixed by relaxing that:

- The provider must **initiate** requests to the consumer's `callbackAddress`
  (`ContractAgreementMessage`, the `FINALIZED` event, `TransferStartMessage`). Static hosting
  cannot originate an HTTP request.
- `providerPid` is **minted per process**, and the negotiation and transfer state machines
  require mutation with commit-only-after-`2xx`. No file can be pre-generated for an identifier
  that does not yet exist.
- Eleven of the fifteen DSP provider endpoints are `POST`, as listed in
  [Tier 1, Section 5.2](materials-commons-dsp-tier1.md).

The first two are obligations of a DSP **Connector**. The Catalog Protocol names a **Catalog
Service** as a separate role, so a catalogue-only service is a coherent idea, but DSP defines no
conformance classes for it and the catalogue must still advertise a `DataService` at which
negotiation and transfer are initiated. Tier 1 occupies that role and accepts the consequence in
Section 4: it serves a DSP catalogue without claiming DSP conformance.

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

## 6. Why the catalogue-only level was renumbered

The DCAT-AP GET Protocol was originally numbered Tier 1, which meant three different things
carried that number: the DSP profile, the DCAT-AP GET profile, and the first lane of the feature
board. Renumbering the GET profile to Tier 0 removes the collision and places both specifications
on one ladder.

That renumbering changed the document title, the `tag:` profile IRI and the cross-references,
without changing what the profile specified.

Two naming steps are still pending, and they are taken together because each invalidates
something published. The document file names still read `materials-commons-dsp-tier1` and
`materials-commons-dcat-ap-get-protocol-tier-0`, which the published URLs and an external
reference depend on. The `tag:` profile IRIs still spell `prototype`, which the status of the
documents no longer does, and changing an IRI invalidates every advertisement that carries it.
Both are listed in Section 9.

The migration property that makes the ladder worth having is that **Tier 0 to Tier 1 leaves the
assets untouched**. The files, their URLs, their formats and their licences are unchanged, and the
catalogue keeps its identifiers. What the publisher adds is protocol scaffolding: a
`participantId`, an offer carrying the fixed `use` permission that the DSP schema requires, an
`accessService` on every distribution, the DSP `format` string alongside the `dct:format` node,
and the prefixed `dcat:servesDataset` spelling.

What the publisher also has to add is a running service. Tier 0 is a document; Tier 1 answers a
`POST` and paginates. That step, rather than the payload, is the cost of moving up.

## 7. Serving a catalogue for a connector somebody else operates

Narrowing Tier 1 to the catalogue settled the first half of what used to be proposed here. Tier 1
is the catalogue-only conformance target, so a participant that serves a catalogue and operates
no connector now describes exactly one tier rather than half of one.

What remains open is the other half. DSP requires every advertised `DataService` to be backed by
a working connector, and Tier 1 does not operate one. A shared connector, for example one run by
the common node, can perform negotiation and transfer on behalf of catalogue-only publishers. It
never handles the data: the `DataAddress` in the Transfer Start Message carries the publisher's
own download URL, and DSP places no host constraint on it.

Known costs, unresolved:

- `Agreement.assigner` would name the shared connector rather than the publisher.
- `Catalog.participantId` is required, so a broker-served publisher becomes content inside
  another participant's catalogue rather than a participant of its own.
- The pattern only reaches as far as the data is ungated. A shared connector cannot negotiate
  over bytes it has no token for, so a publisher whose downloads are gated under Section 3 keeps
  that gate outside the arrangement, and the connector hands out a URL the consumer then has to
  satisfy itself.

## 8. Where identity and authentication fit

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

Where the token sits says what kind of credential it is, rather than which tier applies:

| Token presented at | Kind | Tiers |
|---|---|---|
| A catalogue or a direct download URL, through the RFC 9728 challenge | HTTP credential on the resource. The DSP control plane never sees it. | 0 and above |
| The DSP endpoints, through the `Authorization` header and the `auth` object | Participant credential, declared in version discovery | 2 and above |
| The `DataAddress` of a Transfer Start Message, minted by the connector | Data-plane credential issued by the control plane | 2 and above |

Only the second and third kinds depend on a tier. The first is available everywhere, per
Section 3, and it is why a group with no connector can still restrict who downloads its data.

Of the three artefacts a gate involves, two stay static: the catalogue and the protected resource
metadata are fixed files. The gated resource itself is not, because RFC 9728 and RFC 6750 require
it to answer an unauthorised request with `401` and a `WWW-Authenticate` challenge, then validate
a token on the retry. Static hosting serves the bytes to anyone holding the URL. What keeps this
out of the tier boundaries is the absence of a connector rather than the absence of a server.

### Participant identifiers: use DIDs now

DSP constrains `participantId` no further than a string, so a data space picks its own form.
**Use DID identifiers from the start**, even where no decentralised identity service stands
behind them. A DID costs nothing to mint, it is a legal `participantId`, and adopting it later
means reissuing every identifier in every catalogue and agreement.

Two things have to be said plainly alongside that recommendation, because a DID looks like it
carries more than it does:

- A connector is **not** required to resolve a DID it encounters. Treating it as an opaque
  identifier is conforming behaviour.
- Encountering a DID implies **nothing verifiable**. It is a placeholder until a credential
  issuer and a resolution path exist. A participant MUST NOT read a DID as evidence of identity,
  membership or any claim.

What this buys is a cheap migration. When the identity layer arrives, whether as the
Decentralized Claims Protocol or as something else, the identifiers are already in the right
shape and only the verification path is new.

## 9. Open decisions

The four levels and their boundaries are settled. These are not:

- **The media type or profile that selects the DCAT-AP representation.** An explicit `profile`
  parameter is specified in [Tier 1, Section 9.4](materials-commons-dsp-tier1.md); whether to
  register a profile URI or a vendor media type is open, and it has to be settled before a
  prototype needs it.
- **Whether any academic repository implements gated access of this shape.** Unverified. Several
  gate restricted records through their own access-request and session model rather than by
  accepting a bearer token from a third-party realm. If that is the general case, pairing a
  static catalogue with third-party gated storage is not satisfiable with present services.
- **Licence against policy where both are present.** DCAT-AP places them at different levels of
  the structure, and Tier 1 requires a licence per distribution while carrying a policy per
  dataset. Two ways out: drop the licence once a full policy is modelled, or model the licence
  completely in ODRL so the two cannot contradict each other.
- **Whether a minimum data plane set is the real Tier 2 and Tier 3 boundary.** On the control
  plane the two barely differ. The data plane is where interoperation actually breaks, because
  both ends need compatible implementations, so the useful boundary may sit there instead.
- **Whether DCAT-AP tolerates the Materials DCAT-AP extensions.**
- **The filter language, now that catalogue filter expressions sit at Tier 3.** DSP makes them
  implementation-specific, so a profile has to name one. JSONPath is proposed as the baseline any
  provider can meet, with SPARQL optional and a mechanism for advertising more than one.
- **How a Tier 1 catalogue advertises a connector operated by somebody else**, Section 7.
- **Workflows and other stateful data services.** A workflow has state, scheduling and error
  handling, which puts it further from a file than an API is. How other data space initiatives
  model data services is worth checking before inventing something.
- **Document file names and the `tag:` profile IRIs**, Section 6. Both still carry wording the
  model has moved past, and both break something published when changed.
- **The name "tier" itself.**

Deprioritised rather than open: a relay server that would let a client without an inbound
endpoint take part in DSP by proxying the bidirectional exchange. The tiers are designed without
it, and DSP is introduced at the level where it is needed. The relay is revisited only if a
DSP-only data space has to be joined.
