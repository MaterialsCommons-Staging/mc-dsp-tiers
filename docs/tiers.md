# The tier model

## Status of this document

Non-normative. This page explains how the Materials Commons tiers relate to each other, to the
Dataspace Protocol, and to the participation levels used in the project's architecture
publications. It records what the WP11 working group has agreed and what it has not.

Sections marked **proposed** have not been decided. They are written down so they can be argued
against rather than rediscovered.

## 1. What a tier is

A tier is a **subset of the Dataspace Protocol** that a Materials Commons participant implements.
It is not a security level, a trust level, or a statement about the data.

Two properties, both agreed:

1. **A tier is a minimum feature set.** A provider that implements more than its tier requires
   does not lose the tier. An implementation claiming Tier 1 may also support authentication;
   consumers simply cannot rely on it.
2. **Claiming a tier means everything below it is available too.** Tiers accumulate.

The consequence is that a tier is a promise to a consumer about the *least* it can expect, not a
description of the provider's deployment.

Always write "Materials Commons tiers of DSP implementation" on first use. The word "tier"
collides with the security profile tiers of the older data space reference architecture, and this
naming is to be revisited before a release version.

## 2. The ladder

**Proposed.** Tier 1 to Tier 3 follow the agreed direction; Tier 0 is a proposal, discussed in
Section 4.

| Tier | Criterion | Specification |
|---|---|---|
| **0** | Static DCAT-AP catalogue with direct download URLs. Conformant to DCAT-AP, not to DSP. | [DCAT-AP GET Protocol Tier 1](materials-commons-dcat-ap-get-protocol-tier-1.md) |
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
- Thirteen of the fifteen provider endpoints in
  [DSP Tier 1, Section 5.2](materials-commons-dsp-tier1.md) remain `POST`.

The first two are obligations of a DSP **Connector**. The Catalog Protocol names a **Catalog
Service** as a separate role, so a catalogue-only service is a coherent idea, but DSP defines no
conformance classes for it and the catalogue must still advertise a `DataService` at which
negotiation and transfer are initiated.

Tier 0 therefore exists because a catalogue-only level is structurally necessary, not as a
placeholder for a future protocol change. It is what lets a research group participate with a
file on static hosting.

## 4. Proposal: renaming the catalogue-only level to Tier 0

**Proposed, for decision.** Today three different things are called Tier 1: the DSP profile, the
DCAT-AP GET profile, and the first lane of the feature board. Renaming the GET profile's level to
Tier 0 removes the collision and places both specifications on one ladder.

This is a rename, not new work: the DCAT-AP GET Protocol already specifies exactly this level. If
adopted it affects the document title, the `tag:` profile IRI, the well-known `version` value,
and the cross-references in DSP Tier 1 Sections 1.2 and 9.

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

## 7. Relationship to the participation levels

The project's architecture publications describe **participation levels** L0 to L3. They answer a
different question from tiers:

- **A level asks what the participant must operate**: nothing, a web server, a connector library,
  or a connector deployment.
- **A tier asks how much of DSP an endpoint implements.**

| Level | Tier | Note |
|---|---|---|
| L0 publish | 0 | The same thing under two names. |
| L1 serve | none directly | A published catalogue with gated payloads. The authentication is out of band, so DSP does not see it. Reaches Tier 2 once the connector mints the data-plane token rather than the user logging in directly. |
| L2 negotiate | 1 | Access granted through contract negotiation, agreed automatically. |
| L3 operate | 2 to 3 | Fine-grained usage policies, auditability, managed transfer channels. |

The mapping is typical, not binding. A library-based deployment may implement Tier 3 features
without changing level, because levels and tiers measure different things.

## 8. Open decisions

Carried into the WP11 session on 2026-09-25:

- Tier 0, Section 4.
- The Tier 1 conformance-target split, Section 5.
- Feature assignment for the contract negotiation and transfer process sections, and for the
  remaining catalogue features. Eighteen of thirty-eight features are unassigned.
- Whether catalogue filter expressions and pagination belong at Tier 2. They were assigned there
  on the grounds that a static host cannot provide them, but static hosting is a property of
  Tier 0, not a criterion for any DSP tier. An intrinsic criterion is proposed in Section 2.
- The filter language a Tier 2 provider must support. JSONPath is proposed as the baseline that
  any provider can meet, with SPARQL optional and a mechanism for advertising more than one.
- The name "tier" itself.
