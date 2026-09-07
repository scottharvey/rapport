module Rapport
  class Sweep
    class NpsResponses < Base
      def call
        responses = host(:nps_response_class) or return

        responses.where.not(email: [ nil, "" ]).find_each do |response|
          contact = contact_for_email(response.email, source: "testimonial", name: response.name) or next
          record(contact, kind: "nps", occurred_at: response.created_at,
                          title: "NPS #{response.score}",
                          payload: { score: response.score, comment: response.comment },
                          source: response)
        end
      end
    end
  end
end
