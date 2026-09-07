module Rapport
  # Folds one Contact into another. The survivor keeps every address, Timeline
  # entry, Note, tag and custom field; the other Contact is destroyed.
  class Merge
    def self.call(survivor:, other:)
      new(survivor, other).call
    end

    def initialize(survivor, other)
      @survivor = survivor
      @other = other
    end

    def call
      raise ArgumentError, "cannot merge a contact into itself" if @survivor == @other

      Contact.transaction do
        @other.email_addresses.update_all(contact_id: @survivor.id, primary: false)
        @other.notes.update_all(contact_id: @survivor.id)
        @other.interaction_participants.each do |participant|
          next if InteractionParticipant.exists?(interaction_id: participant.interaction_id, contact_id: @survivor.id)

          participant.update!(contact: @survivor)
        end
        @other.taggings.each do |tagging|
          @survivor.taggings.find_or_create_by!(tag_id: tagging.tag_id)
        end
        @other.timeline_entries.each do |entry|
          next if TimelineEntry.exists?(contact_id: @survivor.id, source_type: entry.source_type, source_id: entry.source_id)

          entry.update!(contact: @survivor)
        end

        @survivor.assign_attributes(
          custom_fields: @other.custom_fields.merge(@survivor.custom_fields),
          last_touched_at: [ @survivor.last_touched_at, @other.last_touched_at ].compact.max,
          reminder_cadence_days: [ @survivor.reminder_cadence_days, @other.reminder_cadence_days ].compact.min,
          user_id: @survivor.user_id || @other.user_id,
          company_id: @survivor.company_id || @other.company_id,
          name: @survivor.name.presence || @other.name,
          job_title: @survivor.job_title.presence || @other.job_title,
          phone: @survivor.phone.presence || @other.phone,
          avatar_url: @survivor.avatar_url.presence || @other.avatar_url
        )
        @other.reload.destroy!
        @survivor.save!
        @survivor.email_addresses.reload
        @survivor.email_addresses.first&.update!(primary: true) if @survivor.email_addresses.none?(&:primary?)
        @survivor.refresh_last_entry!
      end
      @survivor
    end
  end
end
