# The tier model

## Status of this document

Non-normative. This page explains how the Materials Commons tiers relate to each other, to the
Dataspace Protocol, and to the profiles that specify them. It records what has been settled and
what has not.

Sections marked **proposed** have not been decided. They are written down so they can be argued
against rather than rediscovered.

## 1. What a tier is

A tier is a **subset of the Dataspace Protocol** that a Materials Commons participant implements.
It is not a security level, a trust level, or a statement about the data.

Two properties, both agreed:

1. **A tier is a minimum feature set.** A provider that implements more than its tier requires
   does not lose the tier. An implementation claiming Tier 1 may also support authentication;
   consumers simply cannot rely on it.
2. **Claiming a tier means the DSP functionality of every tier below it is available too.**
   Two things do not carry upward. The Tier 0 DCAT-AP GET protocol is a separate conformance
   claim and stays optional at every higher tier. Tier 1's guarantee that every advertised
   dataset is retrievable without credentials is a property of Tier 1, not an obligation on
   Tier 2, whose whole purpose is to make access depend on the caller.

The consequence is that a tier is a promise to a consumer about the *least* it can expect, not a
description of the provider's deployment.

Always write "Materials Commons tiers of DSP implementation" on first use. The word "tier"
collides with the security profile tiers of the older data space reference architecture, and this
naming is to be revisited before a release version.

## 2. The ladder

Tier 0 and Tier 1 have specification text. Tier 2 and Tier 3 have outlines only.

| Tier | Criterion | Specification |
|---|---|---|
| **0** | Static DCAT-AP catalogue with direct download URLs. Conformant to DCAT-AP, not to DSP. | [DCAT-AP GET Protocol Tier 0](materials-commons-dcat-ap-get-protocol-tier-0.md) |
| **1** | Public read. No authentication, no policy evaluation, no caller-dependent content. Every advertised dataset is retrievable by any consumer. | [DSP Tier 1](materials-commons-dsp-tier1.md) |
| **2** | Identified and controlled access. Endpoints are authenticated, catalogue content and access decisions may depend on the caller, and policy constrains what a consumer may do. | [DSP Tier 2](materials-commons-dsp-tier2.md), outline |
| **3** | Full protocol. The remaining optional DSP capabilities. | [DSP Tier 3](materials-commons-dsp-tier3.md), outline |

Tier 2 is the first tier at which a negotiation can fail for a reason other than a malformed
message.

## 3. Why Tier 0 is not a DSP tier

A static file host cannot be a DSP provider. This is not a consequence of the catalogue request
being a `POST`, and it would not be fixed by relaxing that:

- The provider must **initiate** requests to the consumer's `callbackAddress`
  (`ContractAgreementMessage`, the `FINALIZED` event, `TransferStartMessage`). Static hosting
  cannot originate an HTTP request.
- `providerPid` is **minted per process**, and the negotiation and transfer state machines
  require mutation with commit-only-after-`2xx`. No file can be pre-generated for an identifier
  that does not yet exist.
- Eleven of the fifteen provider endpoints in
  [DSP Tier 1, Section 5.2](materials-commons-dsp-tier1.md) remain `POST`.

The first two are obligations of a DSP **Connector**. The Catalog Protocol names a **Catalog
Service** as a separate role, so a catalogue-only service is a coherent idea, but DSP defines no
conformance classes for it and the catalogue must still advertise a `DataService` at which
negotiation and transfer are initiated.

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

## 4. Why the catalogue-only level was renumbered

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

## 5. Proposal: splitting the Tier 1 conformance target

**Proposed, for decision.** DSP requires every advertised `DataService` to be backed by a working
connector, but it does not require the catalogue publisher to *operate* that connector. Tier 1
currently collapses the two by assuming that the provider is the operator.

Splitting them gives:

- **Tier 1 Catalogue** - serves the catalogue and dataset requests and advertises a `DataService`
  it does not operate.
- **Tier 1 Connector** - the full provider endpoint set with automatic agreement.

A participant claims either or both. A shared connector, for example one operated by the common
node, can then perform negotiation and transfer on behalf of catalogue-only publishers. It never
handles the data: the `DataAddress` in the Transfer Start Message carries the publisher's own
public URL, and DSP places no host constraint on it.

Known costs, unresolved:

- `Agreement.assigner` would name the shared connector rather than the publisher.
- `Catalog.participantId` is required, so a broker-served publisher becomes content inside
  another participant's catalogue rather than a participant of its own.
- The pattern only works while nothing is gated. At Tier 2 the shared connector would need
  credentials for another participant's data, which is where it must stop.

## 6. Where authentication fits

DSP leaves token semantics unspecified deliberately, and provides two extension points: the
`Authorization` header on every endpoint, and the `auth` object in the version response naming
`protocol`, `version` and `profile`.

OpenID Connect is a legitimate fill for those extension points, not a deviation from DSP.
Verifiable credentials through the Decentralized Claims Protocol are a different fill for the
same extension points, and are equally outside DSP.

Where the token sits determines whether the deployment is on this ladder at all:

| Token presented at | Tier |
|---|---|
| The DSP endpoints | 2 |
| A direct download URL, with no connector | Not on the ladder. The data space never sees the authentication. |
| The `DataAddress` of a Transfer Start Message, minted by the connector | 2 |

## 7. Open decisions

Still to settle:

- The Tier 1 conformance-target split, Section 5.
- Which tier the contract negotiation and transfer process capabilities belong to, and the
  remaining catalogue capabilities. Roughly half of the inventory is still unassigned.
- The filter language a Tier 2 provider must support. JSONPath is proposed as the baseline that
  any provider can meet, with SPARQL optional and a mechanism for advertising more than one.
- Whether pagination belongs at Tier 1 rather than Tier 2 now that Tier 0 carries the
  static-hosting case, and whether it is optional or required at whichever tier it lands on. The
  same question applies to catalogue filter expressions.
- The name "tier" itself.
