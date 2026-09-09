# OUTLINE: Materials Commons DSP Tier 2 (Identified and Controlled Access)

## Status of this document

**This is an outline, not a specification.** It records the scope agreed for Tier 2 so that the
boundary against [Tier 1](materials-commons-dsp-tier1.md) is written down. No section below is
normative, and the requirement language of BCP 14 is deliberately not used yet.

Feature assignments come from the
[feature board](https://github.com/orgs/MaterialsCommons-Staging/projects/1) as sorted in the
WP11 session of 2026-09-08. See [the tier model](tiers.md) for how the tiers relate.

## Criterion

Endpoints are authenticated, catalogue content and access decisions may depend on the caller's
identity or credentials, and policy actually constrains what a consumer may do.

Tier 2 is the first tier at which a contract negotiation can fail for a reason other than a
malformed message. That single sentence is the test: if every well-formed request still
succeeds, the deployment is Tier 1 with extra machinery, not Tier 2.

## Included capabilities

Assigned to Tier 2 on 2026-09-08:

| Feature | Capability |
|---|---|
| A3 | Token-based authorization on DSP endpoints, via the `Authorization` header |
| A5b | Advertising authentication and participant identity in the version response (`auth`, `identifierType`) |
| B3 | Nested sub-catalogues |
| B4 | Distribution-level offers (`Distribution.hasPolicy`) |
| B5a | Permission rules in offers and agreements |
| B5b | Prohibition and obligation rules, and the ODRL profile |
| B6 | ODRL constraints on rules, including logical constraints |
| B7 | Catalogue query and filter expressions |
| B8 | Pagination of catalogue responses via HTTP `Link` headers |
| B10 | Access-controlled catalogues and credential-dependent catalogue content |

Contract negotiation and transfer process features are not yet assigned. Expected to land here:
policy-based or manual approval of contract requests, and data-plane credentials in
`endpointProperties`.

## Excluded

Everything not listed above and not inherited from Tier 1. In particular the capabilities
expected at [Tier 3](materials-commons-dsp-tier3.md).

## Open questions

- **B7 and B8 may not belong here.** They were assigned to Tier 2 because a static host cannot
  provide them, but static hosting is a property of the catalogue-only level, not a criterion for
  any DSP tier. Both are candidates for Tier 1 under an intrinsic criterion.
- **B5b may belong at Tier 3.** Prohibitions and duties express usage control after access has
  been granted, which is beyond the Tier 2 criterion of controlling access. This was proposed in
  the meeting; the board records Tier 2.
- **The filter language is undefined.** DSP makes filter expressions implementation-specific, so
  a Materials Commons profile has to name one. JSONPath is proposed as the baseline any provider
  can meet, with SPARQL optional where a triple store already exists, and a mechanism for a
  catalogue to advertise which languages it accepts.
- **Which authentication profile.** OpenID Connect fills the extension point DSP leaves open, and
  the `auth` object has to carry a concrete `protocol`, `version` and `profile`. The exact values
  are not chosen.
- Whether a provider must be able to state that it withholds nothing, which the working group
  agreed should not be expressed through the tier levels themselves.

## Sections to write

Following the structure of the Tier 1 profile: conformance and requirement language; scope;
terminology; normative namespaces; HTTPS service organization; version discovery including the
`auth` advertisement; catalogue protocol including access-controlled content and filters;
publication model including conditional offers; negotiation with policy evaluation; transfer with
data-plane credentials; errors and status codes; security and privacy; state and lifecycle;
extensibility; conformance checklist.
