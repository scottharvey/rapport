# Changelog

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
