# Materials Commons Tier 2: Required DSP Feature Set

## Status of this document

**Outline only.** This is not yet a specification. It records the scope agreed for Tier 2 so that
the boundary against [Tier 1](materials-commons-dsp-tier1.md) is written down. No section below
is normative, and the requirement language of BCP 14 is deliberately not used yet.

See [the tier model](tiers.md) for how the tiers relate.

## Criterion

**The first actual DSP implementation: every feature the Dataspace Protocol requires.** Tier 1
stops at the catalogue, so Tier 2 is where the protocol is implemented as a protocol. Contract
negotiation, policy evaluation and the transfer state machine are all in, together with the
provider-initiated callbacks they depend on and the inbound endpoint a consumer needs to receive
them.

Tier 2 is the first tier that has a contract negotiation at all, and therefore the first at
which a request can be refused for a reason other than malformed input. That is the test: if
every well-formed request still succeeds, the policy carries no condition and the deployment is
Tier 1 with extra machinery.

What the minimal DSP subset buys a participant is ODRL policy. Region, purpose and time
constraints, export control, "not for training models": none of that fits in an access token,
and today it lives in an email nobody can audit. At this tier it can be exchanged and
acknowledged, which makes Tier 2 a tier of trust. Enforcement is a separate matter and sits
above it.

## Included capabilities

Capabilities placed at this tier, on the reading that Tier 2 is what DSP requires:

| Capability |
|---|
| The DSP contract negotiation protocol: provider endpoints, states, agreements, verification, finalization |
| Policy evaluation, meaning a decision that can refuse a well-formed request |
| Provider-initiated callbacks to a consumer `callbackAddress`, with the reachability that implies on the consumer side |
| The DSP transfer state machine, in its finite pull form |
| ODRL constraints on rules, including logical constraints |
| Permission rules beyond the fixed `use` permission that Tier 1 carries for schema reasons |
| Token-based authorization on DSP endpoints, via the `Authorization` header |
| Advertising authentication and participant identity in the version response (`auth`, `identifierType`) |
| Catalogue content that depends on the caller |

Pagination is not here. It is required at Tier 1, because a catalogue generated from search
results cannot be served any other way.

Gating is not here either. A catalogue or a download may be gated at any tier, including Tier 0,
through the RFC 9728 mechanism described in [the tier model](tiers.md). What Tier 2 adds is a
credential the control plane issues and evaluates, rather than one the resource checks.

## Excluded

Everything not listed above and not inherited from Tier 1. In particular what DSP leaves
optional, which is [Tier 3](materials-commons-dsp-tier3.md): provider-initiated negotiation,
multi-round negotiation with changed terms, push and streaming transfers, catalogue brokers,
nested sub-catalogues, catalogue filter expressions, distribution-level offers, the proof
metadata endpoint, and DID-based service discovery.

Tier 2 also does not cover enforcement after access has been granted. A consumer granted access
for one purpose is not technically prevented from another; the agreement is a statement of terms
rather than a control.

## Participant identifiers

Use DID identifiers for `participantId` from the start, as [the tier model](tiers.md) recommends,
even with no decentralised identity service behind them. A connector need not resolve a DID it
encounters, and the profile has to state plainly that encountering a DID implies nothing
verifiable. The gain is that a later migration to a real credential layer changes the
verification path rather than every identifier in every catalogue and agreement.

This is separate from DID-based service discovery, which stays at Tier 3 because it is a
mechanism for finding endpoints rather than for naming participants.

## Open questions

- **A minimum data plane set may be the real boundary against Tier 3.** On the control plane the
  two tiers barely differ. The data plane is where interoperation actually breaks, because both
  ends need compatible implementations, so the useful line may sit there rather than in the
  control-plane feature list above.
- **Prohibitions and duties are not placed.** They express usage control after access has been
  granted, which is beyond the Tier 2 criterion, so they probably belong at Tier 3 even though
  DSP itself does not mark them optional.
- **Consumer reachability is the entry cost of this tier.** Provider-initiated callbacks require
  the consumer to operate an inbound endpoint, which is the requirement that kept full DSP out
  of Tier 1. A relay that proxies the bidirectional exchange for a client without one has been
  deprioritised rather than ruled out, and would be revisited only if a DSP-only data space had
  to be joined.
- **The filter language is undefined.** DSP makes filter expressions implementation-specific, so
  a Materials Commons profile has to name one. JSONPath is proposed as the baseline any provider
  can meet, with SPARQL optional where a triple store already exists, and a mechanism for a
  catalogue to advertise which languages it accepts.
- **Which authentication profile.** OAuth 2.0 with signed JWT bearer tokens fills the extension
  point DSP leaves open, and the `auth` object has to carry a concrete `protocol`, `version` and
  `profile`. The exact values are not chosen. The profile also has to state what the token must
  assert, since DSP declares participant identity in the message payload and the authentication
  protocol in the version metadata without connecting the two: nothing in DSP requires the
  token's subject to correspond to the `participantId` it acts for.
- **Which trust overlay, and it binds the whole data space.** DSP leaves credential semantics to
  an overlay rather than defining them, in both directions: "All requests to HTTPS endpoints
  SHOULD use the `Authorization` header", which covers messages a provider sends to a consumer's
  callback as much as the reverse. The version metadata `auth` object is where a connector
  declares which overlay it speaks, and the specification's own example shows OAuth 2.0 and the
  Decentralized Claims Protocol as alternatives on an equal footing. DSP requires neither, and
  constrains `participantId` no further than a string.

  The two overlays do not interoperate: a token from a shared authorization server and a
  self-issued token addressed to a decentralized identifier cannot validate each other, and DSP
  says nothing about token contents that would bridge them. The choice therefore binds a whole
  data space rather than an individual participant, and it decides which other data spaces a
  participant can ever exchange with. `protocolVersions` is a list with its own `auth` per entry,
  so a second endpoint speaking a second overlay remains expressible later.

  The Decentralized Claims Protocol is more viable than this question assumed when it was
  written. EDC with DCP and a self-hosted issuer has been reported working elsewhere, the
  components behave, and the same protocols underlie the European identity wallet work. The
  decision no longer reads as settled in favour of a shared authorization server.
- **Where a licence sits relative to an ODRL policy.** DCAT-AP places the licence and the policy
  at different levels of the structure, and Tier 1 already requires a licence per distribution
  while carrying a policy per dataset. Two ways out: drop the licence once a full policy is
  modelled, or model the licence completely in ODRL so the two cannot contradict each other.
- Whether a provider must be able to state that it withholds nothing. That should not be
  expressed through the tier levels themselves.

## Sections to write

Following the structure of the Tier 1 profile: conformance and requirement language; scope;
terminology; normative namespaces; HTTPS service organization; version discovery including the
`auth` advertisement; catalogue protocol including access-controlled content and filters;
publication model including conditional offers; negotiation with policy evaluation; transfer with
data-plane credentials; errors and status codes; security and privacy; state and lifecycle;
extensibility; conformance checklist.

Sections 11 and 12 of the Tier 1 profile are the starting text for the negotiation and transfer
sections. They specify those flows against an unconditional offer, which is the degenerate case
of what this tier has to cover.
