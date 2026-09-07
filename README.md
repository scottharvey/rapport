# Rapport

Operator-only relationship tracking for a Rails SaaS app. Rapport keeps a Contact for every person worth remembering, a Company for every organisation, and one Timeline per Contact that merges everything the host app already knows about them: signups, subscriptions, charges, product events, support chats, testimonials, feedback and outgoing mail.

It is a mountable engine for the operator, not a customer-facing feature. Think of it as a lightweight, private Dex or Clay that lives inside the app whose customers it tracks.

Built for my own Rails apps and shared as-is under MIT. It assumes a fairly conventional shell (see [What it expects from the host](#what-it-expects-from-the-host)). Issues and pull requests are welcome, but there is no support commitment and the API may change between minor versions.

## Vocabulary

**Contact**: a person the operator tracks, identified by email address. May be linked to a User once that person signs up.

**Company**: an organisation a Contact belongs to. May be linked to an Account once one exists.

**Stage**: where a Contact sits in the buying lifecycle: lead, signed up, trialing, subscribed, or churned. Derived from the linked User and Subscription; may be set by hand only while no User is linked.

**Source**: the system a Contact or Timeline entry was first discovered in: signup, Stripe, livechat, testimonial, feedback, or the operator.

**Timeline**: the chronological list of everything known to have happened with a Contact, from every Source.

**Interaction**: something the operator did with one or more Contacts: a meeting, call, email, or message, logged by hand.

**Note**: a dated observation the operator writes about a Contact. Appears on the Timeline but is not a Touch.

**Touch**: the moment a Contact was last kept in touch with. Only an Interaction or an explicit mark-as-touched counts.

**Reminder**: a per-Contact cadence in days. Due when the last Touch is older than the cadence.

**Merge**: folding one Contact into another. The survivor keeps every email address, Timeline entry, Note and tag.

**Sweep**: the recurring job that reads every Source and upserts Contacts, Companies and Timeline entries. The only way host data enters Rapport.

## How data gets in

Only through the Sweep. `Rapport::Sweep.call` reads Users, Accounts, Pay subscriptions and charges, Ahoy events, livechat conversations, testimonials, NPS responses and feedback, and upserts Contacts, Companies and Timeline entries. `Rapport::SweepJob` wraps it for a scheduler, and the "Sweep now" button runs it on demand. Sweeps are idempotent.

The one exception is outgoing mail: `Rapport::MailObserver` is registered with ActionMailer at boot and writes an email entry for each recipient who is already a Contact.

Rapport never adds callbacks to host models and holds host ids as plain integers with no foreign keys. The reasoning is in [docs/adr/0001-sync-via-sweep-not-callbacks.md](docs/adr/0001-sync-via-sweep-not-callbacks.md).

## What it expects from the host

Every Source is optional. A class name that does not resolve is skipped, so a host with no livechat engine simply has no chat entries. The defaults assume:

| Concern | Default class | Used for |
|---|---|---|
| People | `User` | signup entries, linking Contacts, `admin?` for access |
| Tenants | `Account` | linking Companies |
| Billing | `Pay::Subscription`, `Pay::Charge` | Stage derivation, subscription and charge entries |
| Product events | `Ahoy::Event` | activity entries |
| Support | `Livechat::Conversation` | chat entries |
| Social proof | `Testimonials::Testimonial`, `Testimonials::NpsResponse` | testimonial and NPS entries |
| Feedback | `Ideasbugs::Feedback` | feedback entries |

Screens render in a host layout (`hub` by default) and inherit from the host's `ApplicationController`, so the host's styling and helpers apply. The views use Tailwind and DaisyUI class names.

## Installation

```ruby
# Gemfile
gem "rapport", github: "scottharvey/rapport", tag: "v0.1.0"
```

```bash
bundle install
bin/rails db:migrate   # the engine adds its own migrations
```

Mount it and schedule the Sweep:

```ruby
# config/routes.rb
mount Rapport::Engine, at: Rapport.configuration.mount_path
```

```yaml
# config/recurring.yml (Solid Queue), or your scheduler of choice
rapport_sweep:
  class: Rapport::SweepJob
  schedule: every 5 minutes
```

Then visit `/rapport` as an admin and press "Sweep now".

## Configuration

`config/initializers/rapport.rb`. Every setting has a default, so start empty and override only what differs.

```ruby
Rapport.configure do |config|
  config.mount_path = "/rapport"
  config.parent_controller = "::ApplicationController"
  config.layout = "hub"

  # Host before_actions to skip inside the engine, because they redirect
  # with host route helpers that do not resolve in an isolated engine.
  config.skip_host_before_actions = %i[require_authentication require_active_subscription]

  # Runs in the controller. The default redirects anyone who is not a signed-in admin.
  config.authenticate = -> { redirect_to main_app.root_path unless Current.user&.admin? }

  # Users left out of the Sweep. Operators are not Contacts.
  config.skip_user = ->(user) { user.admin? }

  # Host class names, one per Source. Set to nil to disable a Source.
  config.user_class = "User"
  config.subscription_class = "Pay::Subscription"
  config.livechat_conversation_class = nil

  # Where Timeline entries link out to. Return nil for plain text.
  config.entry_links["charge"] = ->(entry) { "https://dashboard.stripe.com/payments/#{entry.source_id}" }
  config.user_link = ->(user) { main_app.admin_user_path(user) }
end
```

By default charges and subscriptions open the Stripe dashboard (test mode detected from the API key), emails open the Resend log, and chat, feedback, testimonial and NPS entries open the host's own engines.

## Layout

- `app/models/rapport`: Contact, Company, EmailAddress, Tag, Tagging, Note, Interaction, TimelineEntry, and the Stage derivation
- `app/services/rapport/sweep`: one class per Source, plus Stages and Activity
- `app/services/rapport/merge.rb`: folds one Contact into another
- `app/controllers/rapport`, `app/views/rapport`: the screens
- `app/components/rapport`: the timeline entry ViewComponent, with a Lookbook preview under `test/components/previews`
- `db/migrate`: the single migration that creates the `rapport_*` tables

## Tests

The engine does not yet carry a dummy app. Its tests run inside the host application it was extracted from, where User, Account, Pay and the other Sources exist for real. A standalone suite is the next piece of work if you want to contribute one.

## License

MIT. See `MIT-LICENSE`.
