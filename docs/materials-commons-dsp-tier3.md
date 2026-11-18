# Materials Commons Tier 3: Optional DSP Features

## Status of this document

**Outline only.** This is not yet a specification. Tier 3 is the least developed of the tiers.
This page holds the scope and records why the tier is defined as a remainder rather than as a
capability level.

See [the tier model](tiers.md) for how the tiers relate.

## Criterion

**Everything the Dataspace Protocol leaves optional**, once the required feature set is covered
by [Tier 2](materials-commons-dsp-tier2.md).

That criterion became usable once Tier 1 stopped claiming DSP conformance, which moved Tier 2
onto the required DSP feature set and left a clean remainder here. It is still a remainder rather
than a coherent capability level, which is a known weakness. If the sorting reveals a natural
split inside it, splitting is better than keeping one large lane.

## Included capabilities

Capabilities placed at this tier:

| Capability |
|---|
| Service discovery through a DID document |
| Provider-initiated negotiations |
| Multi-round negotiation with changed terms |
| Push transfers, and non-finite or streaming transfers |
| Catalogue brokers and catalogue replication |
| Nested sub-catalogues |
| Catalogue query and filter expressions |
| Distribution-level offers (`Distribution.hasPolicy`) |
| The proof metadata endpoint |
| Enforcement of usage terms after access has been granted |

## Open questions

- **A minimum data plane set may belong at Tier 2 instead.** On the control plane Tier 2 and
  Tier 3 barely differ. The data plane is where interoperation breaks, because both ends need
  compatible implementations, so some of the transfer variants listed above may be where the
  real boundary sits.
- **DID-based service discovery is conditional.** It sits here because Materials Commons does not
  currently plan to resolve DID documents to find endpoints. Using DID identifiers as
  `participantId` placeholders is a separate matter and is recommended from Tier 2, per
  [the tier model](tiers.md). If the project later adopts DID documents for discovery itself, the
  capability moves down, since it would become the mechanism by which a participant is found at
  all.
- **Non-HTTPS callback address schemes** are a candidate for "out of scope at every tier" rather
  than Tier 3. No use case has been named, and supporting them weakens the callback safety rules
  that come with Tier 2.
- **Multi-round negotiation straddles two tiers.** An `OFFERED` and `ACCEPTED` branch carrying an
  unchanged offer belongs with the rest of negotiation at Tier 2, while counter-offers with
  changed terms are clearly above it. The feature card should be split.
- Whether Tier 3 conformance is worth claiming at all, or whether above Tier 2 a participant
  should simply state which optional DSP capabilities it supports.

## Sections to write

Not yet. Tier 2 has to be specified first, and the remaining feature inventory has to be
assigned, before the boundary of this tier is knowable.
