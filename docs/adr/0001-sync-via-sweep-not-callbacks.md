# Rapport reads the host only through a scheduled sweep into a materialised timeline

Rapport is a mountable, operator-only CRM engine that needs to know about Users, Pay subscriptions and charges, Ahoy events, and the livechat, testimonials and ideasbugs engines. It never hooks host models with callbacks or subscribes to Pay webhooks. A recurring job sweeps those tables every few minutes and upserts rows into a single materialised timeline table keyed by source type and id, and a sweep-now button runs the same job on demand. Rapport tables carry host ids as plain integers with no database foreign keys, and host class names come from an initializer.

One exception: outgoing mail leaves no host table to sweep, so Rapport registers an ActionMailer delivery observer at boot. It observes the mail pipeline, not host models, and writes only to Rapport's own tables.

## Considered options

- **Callbacks on User, Account and Pay models, plus Pay webhook subscribers.** Instant, but scatters Rapport concerns through the host's app/ directory and couples the engine to one host's internals.
- **Read-time timeline assembled by querying every source table.** No sync lag, but every page load joins six tables, Merge would have to rewrite host rows, and pagination across sources is awkward.
- **Scheduled sweep into a materialised table (chosen).** A signup appears a few minutes late, which is acceptable for an operator tool.

## Consequences

- Nothing in the host's app/ directory references Rapport. Installing it touches only the Gemfile, routes, an initializer and the job schedule.
- Sweeps must be idempotent. Re-running never duplicates timeline rows.
- The Timeline lags the host by up to one sweep interval.
