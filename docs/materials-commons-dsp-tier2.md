# OUTLINE: Materials Commons DSP Tier 2 (Contract Negotiation and Policy)

## Status of this document

**This is an outline, not a specification.** It records the scope agreed for Tier 2 so that the
boundary against [Tier 1](materials-commons-dsp-tier1.md) is written down. No section below is
normative, and the requirement language of BCP 14 is deliberately not used yet.

See [the tier model](tiers.md) for how the tiers relate.

## Criterion

**Contract negotiation, with an ODRL policy that carries more than an empty condition.** Tier 1
stops at the catalogue, so Tier 2 is where the Dataspace Protocol is implemented as a protocol:
the negotiation state machines, the provider-initiated callbacks, the agreement, and the
transfer process that an agreement leads to. Endpoints are authenticated, and catalogue content
and access decisions may depend on the caller.

Tier 2 is the first tier that has a contract negotiation at all, and therefore the first at
which a request can be refused for a reason other than malformed input. That is the test: if
every well-formed request still succeeds, the policy carries no condition and the deployment is
Tier 1 with extra machinery.

The value DSP adds here is the structured, standardised negotiation of terms, including a
consumer proposing a modification and the provider answering. Geographic restrictions and
payment modalities are the cases where a licence link does not carry enough. Outside DSP the
same thing is usually settled by mail or telephone and followed by an account that grants
access, which is the common practice today and the reason this belongs above the entry tiers
rather than at them.

## Included capabilities

Capabilities placed at this tier:

| Capability |
|---|
| The DSP contract negotiation protocol: provider endpoints, states, agreements, verification, finalization |
| Provider-initiated callbacks to a consumer `callbackAddress`, with the reachability that implies on the consumer side |
| The DSP transfer process, as the thing an agreement leads to, in its finite pull form |
| ODRL constraints on rules, including logical constraints |
| Permission rules beyond the fixed `use` permission that Tier 1 carries for schema reasons |
| Prohibition and obligation rules, and the ODRL profile |
| Distribution-level offers (`Distribution.hasPolicy`) |
| Token-based authorization on DSP endpoints, via the `Authorization` header |
| Advertising authentication and participant identity in the version response (`auth`, `identifierType`) |
| Access-controlled catalogues and credential-dependent catalogue content |
| Nested sub-catalogues |
| Catalogue query and filter expressions |

Pagination is not here. It is required at Tier 1, because a catalogue generated from search
results cannot be served any other way.

## Excluded

Everything not listed above and not inherited from Tier 1. In particular the capabilities
expected at [Tier 3](materials-commons-dsp-tier3.md): provider-initiated negotiation,
multi-round negotiation with changed terms, push and streaming transfers, catalogue brokers, and
DID-based discovery.

Tier 2 also does not cover enforcement after access has been granted. A consumer granted access
for one purpose is not technically prevented from another; the agreement is a statement of terms
rather than a control.

## Open questions

- **Prohibitions and duties may belong at Tier 3.** They express usage control after access has
  been granted, which is beyond the Tier 2 criterion of agreeing terms.
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
  while carrying a policy per dataset.
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
