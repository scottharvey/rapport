# Rapport

Operator-only relationship tracking for the Launchpad shell. Keeps a Contact for every person worth remembering, a Company for every organisation, and one Timeline per Contact that merges everything the host already knows.

The vocabulary (Contact, Company, Stage, Source, Timeline, Interaction, Note, Touch, Reminder, Merge, Sweep) is defined in the host's `CONTEXT.md`. The integration rule is in `docs/adr/0001-rapport-syncs-via-sweep-not-callbacks.md`.

## How data gets in

Only through the Sweep. `Rapport::Sweep.call` reads Users, Accounts, Pay subscriptions and charges, Ahoy events, livechat conversations, testimonials, NPS responses and feedback, and upserts Contacts, Companies and Timeline entries. It runs every five minutes via `Rapport::SweepJob` (see `config/recurring.yml`) and from the "Sweep now" button.

The one exception is outgoing mail: `Rapport::MailObserver` is registered with ActionMailer at boot and writes an email entry for each recipient who is already a Contact.

Rapport never adds callbacks to host models and holds host ids as plain integers with no foreign keys.

## Configuration

`config/initializers/rapport.rb` in the host. Defaults assume the Launchpad shell:

- `mount_path`, `parent_controller`, `layout`
- `authenticate`: a block run in the controller; the default redirects anyone who is not a signed-in admin
- `skip_host_before_actions`: host guards to skip, since they redirect with host route helpers
- `*_class`: the host class name for each Source; a name that does not resolve is skipped

## Layout

- `app/models/rapport`: Contact, Company, EmailAddress, Tag, Tagging, Note, Interaction, TimelineEntry, and the Stage derivation
- `app/services/rapport/sweep`: one class per Source, plus Stages and Activity
- `app/services/rapport/merge.rb`: folds one Contact into another
- `app/controllers/rapport`, `app/views/rapport`: the screens, rendered in the host's hub layout
- `app/components/rapport`: the timeline entry component, with a Lookbook preview under `test/components/previews`

## Tests

Live in the host suite under `test/rapport/`. They exercise the Sweep, the mail observer, engine access and the three write actions (merge, touch, sync).
