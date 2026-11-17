# OUTLINE: Materials Commons DSP Tier 3 (Full Protocol)

## Status of this document

**This is an outline, not a specification.** Tier 3 is the least developed of the tiers. This
page exists to hold the scope and to record why the tier is defined as a remainder rather than
as a capability level.

See [the tier model](tiers.md) for how the tiers relate.

## Criterion

The remaining optional capabilities of the Dataspace Protocol, once the catalogue
([Tier 1](materials-commons-dsp-tier1.md)) and contract negotiation with policy
([Tier 2](materials-commons-dsp-tier2.md)) are covered.

Tier 3 is a remainder, not a coherent capability level. That is a known weakness. If the sorting
reveals a natural split inside it, splitting is better than keeping one large lane, and the
split should be expected rather than treating Tier 3 as final.

## Included capabilities

Capabilities placed at this tier:

| Capability |
|---|
| Service discovery through a DID document |
| Provider-initiated negotiations |
| Multi-round negotiation with changed terms |
| Push transfers, and non-finite or streaming transfers |
| Catalogue brokers and catalogue replication |
| The proof metadata endpoint |
| Enforcement of usage terms after access has been granted |

## Open questions

- **DID-based discovery is conditional.** It sits here because Materials Commons does not
  currently plan to use it. If the project adopts DID documents for service discovery, it moves
  to Tier 1, since it would become the mechanism by which a participant is found at all.
- **Non-HTTPS callback address schemes** are a candidate for "out of scope at every tier" rather
  than Tier 3. No use case has been named, and supporting them weakens the callback safety rules
  that come with Tier 2.
- **Multi-round negotiation straddles two tiers.** An `OFFERED` and `ACCEPTED` branch carrying an
  unchanged offer belongs with the rest of negotiation at Tier 2, while counter-offers with
  changed terms are clearly above it. The feature card should be split.
- Whether Tier 3 conformance is worth claiming at all, or whether above Tier 2 a participant
  should simply state which optional DSP capabilities it supports.

## Sections to write

Not yet. Tier 2 has to be specified first, and the remaining two thirds of the feature inventory
have to be assigned, before the boundary of this tier is knowable.
