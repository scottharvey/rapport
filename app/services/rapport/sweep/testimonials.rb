module Rapport
  class Sweep
    class Testimonials < Base
      def call
        testimonials = host(:testimonial_class) or return

        testimonials.where.not(email: [ nil, "" ]).find_each do |testimonial|
          contact = contact_for_email(testimonial.email, source: "testimonial", name: testimonial.name) or next
          record(contact, kind: "testimonial", occurred_at: testimonial.created_at,
                          title: "Testimonial (#{testimonial.status}): #{testimonial.body.to_s.truncate(80)}",
                          payload: { status: testimonial.status, rating: testimonial.rating, body: testimonial.body },
                          source: testimonial)
        end
      end
    end
  end
end
