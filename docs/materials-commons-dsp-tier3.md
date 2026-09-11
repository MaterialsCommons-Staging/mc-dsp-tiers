# OUTLINE: Materials Commons DSP Tier 3 (Full Protocol)

## Status of this document

**This is an outline, not a specification.** Tier 3 is the least developed of the tiers: one
feature has been assigned to it so far. This page exists to hold the scope and to record why the
tier is defined as a remainder rather than as a capability level.

See [the tier model](tiers.md) for how the tiers relate.

## Criterion

The remaining optional capabilities of the Dataspace Protocol, once public read
([Tier 1](materials-commons-dsp-tier1.md)) and controlled access
([Tier 2](materials-commons-dsp-tier2.md)) are covered.

Tier 3 is a remainder, not a coherent capability level. That is a known weakness. If the sorting
reveals a natural split inside it, splitting is better than keeping one large lane, and the
split should be expected rather than treating Tier 3 as final.

## Included capabilities

Capabilities placed at this tier:

| Capability |
|---|
| Service discovery through a DID document |

Expected here once the contract negotiation and transfer process capabilities are placed:
provider-initiated negotiations, multi-round negotiation with changed terms, push transfers,
non-finite and streaming transfers, catalogue brokers, and the proof metadata endpoint.

## Open questions

- **DID-based discovery is conditional.** It sits here because Materials Commons does not
  currently plan to use it. If the project adopts DID documents for service discovery, it moves
  to Tier 1, since it would become the mechanism by which a participant is found at all.
- **Non-HTTPS callback address schemes** are a candidate for "out of scope at every tier" rather
  than Tier 3. No use case has been named, and supporting them weakens the callback safety rules
  that Tier 1 already imposes.
- **Multi-round negotiation straddles two tiers.** The Tier 1 profile already permits the
  `OFFERED` and `ACCEPTED` branch with an unchanged offer as an optional branch, while
  counter-offers with changed terms are clearly above it. The feature card should be split.
- Whether Tier 3 conformance is worth claiming at all, or whether above Tier 2 a participant
  should simply state which optional DSP capabilities it supports.

## Sections to write

Not yet. Tier 2 has to be specified first, and the remaining two thirds of the feature inventory
have to be assigned, before the boundary of this tier is knowable.
