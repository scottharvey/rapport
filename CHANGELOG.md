# Changelog

## 0.1.2

- Header now renders through the host's shared Ui::ToolHeaderComponent, so
  Rapport's chrome matches every other operator tool on /hub (Foothold,
  Growth, Email templates) instead of its own bespoke markup

## 0.1.1

- Fixed: Tailwind never scanned this engine's views, so any utility class not
  already used elsewhere in the host silently compiled to nothing (its own
  `@source` line, added for the public release, pointed at a `vendor/rapport`
  path that only existed in the pre-extraction private repo). Ships its own
  `app/assets/tailwind/rapport/engine.css`, picked up automatically by the
  host's `bin/rails tailwindcss:build`/`:watch` via the tailwindcss-rails
  gem's `tailwindcss:engines` task.

## 0.1.0

First public release, extracted from the private Rails Launchpad shell.

- Contacts, Companies, email addresses, tags, Notes and Interactions
- One materialised Timeline per Contact, filled by a scheduled Sweep over the host's Users, Accounts, Pay subscriptions and charges, Ahoy events, livechat conversations, testimonials, NPS responses and feedback
- ActionMailer observer that records outgoing mail to known Contacts
- Stage derivation (lead, signed up, trialing, subscribed, churned) from the linked User and Subscription
- Touch and Reminder cadence per Contact
- Merge one Contact into another
- Links from Timeline entries out to Stripe, Resend and the host's own engines
- Admin-only access by default, configurable per host
