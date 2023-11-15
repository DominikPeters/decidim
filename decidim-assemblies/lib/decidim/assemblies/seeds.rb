# frozen_string_literal: true

require "decidim/seeds"

module Decidim
  module Assemblies
    class Seeds < Decidim::Seeds
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def call
        organization = Decidim::Organization.first

        Decidim::ContentBlock.create(
          organization:,
          weight: 32,
          scope_name: :homepage,
          manifest_name: :highlighted_assemblies,
          published_at: Time.current
        )

        2.times do |n|
          params = {
            title: Decidim::Faker::Localized.sentence(word_count: 5),
            slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
            subtitle: Decidim::Faker::Localized.sentence(word_count: 2),
            hashtag: "##{::Faker::Lorem.word}",
            short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.sentence(word_count: 3)
            end,
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            organization:,
            hero_image: ::Faker::Boolean.boolean(true_ratio: 0.5) ? hero_image : nil, # Keep after organization
            banner_image: ::Faker::Boolean.boolean(true_ratio: 0.5) ? banner_image : nil, # Keep after organization
            promoted: true,
            published_at: 2.weeks.ago,
            meta_scope: Decidim::Faker::Localized.word,
            developer_group: Decidim::Faker::Localized.sentence(word_count: 1),
            local_area: Decidim::Faker::Localized.sentence(word_count: 2),
            target: Decidim::Faker::Localized.sentence(word_count: 3),
            participatory_scope: Decidim::Faker::Localized.sentence(word_count: 1),
            participatory_structure: Decidim::Faker::Localized.sentence(word_count: 2),
            scope: n.positive? ? Decidim::Scope.reorder(Arel.sql("RANDOM()")).first : nil,
            purpose_of_action: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            composition: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            assembly_type: Decidim::AssembliesType.create!(organization:, title: Decidim::Faker::Localized.word),
            creation_date: 1.day.from_now,
            created_by: "others",
            created_by_other: Decidim::Faker::Localized.word,
            duration: 2.days.from_now,
            included_at: 5.days.from_now,
            closing_date: 5.days.from_now,
            closing_date_reason: Decidim::Faker::Localized.sentence(word_count: 3),
            internal_organisation: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            is_transparent: true,
            special_features: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            twitter_handler: ::Faker::Lorem.word,
            facebook_handler: ::Faker::Lorem.word,
            instagram_handler: ::Faker::Lorem.word,
            youtube_handler: ::Faker::Lorem.word,
            github_handler: ::Faker::Lorem.word
          }

          assembly = Decidim.traceability.perform_action!(
            "publish",
            Decidim::Assembly,
            organization.users.first,
            visibility: "all"
          ) do
            Decidim::Assembly.create!(params)
          end

          # Create users with specific roles
          Decidim::AssemblyUserRole::ROLES.each do |role|
            email = "assembly_#{assembly.id}_#{role}@example.org"

            user = Decidim::User.find_or_initialize_by(email:)
            user.update!(
              name: ::Faker::Name.name,
              nickname: ::Faker::Twitter.unique.screen_name,
              password: "decidim123456789",
              organization:,
              confirmed_at: Time.current,
              locale: I18n.default_locale,
              tos_agreement: true
            )

            Decidim::AssemblyUserRole.find_or_create_by!(
              user:,
              assembly:,
              role:
            )
          end

          child = Decidim::Assembly.create!(
            title: Decidim::Faker::Localized.sentence(word_count: 5),
            slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
            subtitle: Decidim::Faker::Localized.sentence(word_count: 2),
            hashtag: "##{::Faker::Lorem.word}",
            short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.sentence(word_count: 3)
            end,
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            organization:,
            hero_image: ::Faker::Boolean.boolean(true_ratio: 0.5) ? hero_image : nil, # Keep after organization
            banner_image: ::Faker::Boolean.boolean(true_ratio: 0.5) ? banner_image : nil, # Keep after organization
            promoted: true,
            published_at: 2.weeks.ago,
            meta_scope: Decidim::Faker::Localized.word,
            developer_group: Decidim::Faker::Localized.sentence(word_count: 1),
            local_area: Decidim::Faker::Localized.sentence(word_count: 2),
            target: Decidim::Faker::Localized.sentence(word_count: 3),
            participatory_scope: Decidim::Faker::Localized.sentence(word_count: 1),
            participatory_structure: Decidim::Faker::Localized.sentence(word_count: 2),
            scope: n.positive? ? Decidim::Scope.reorder(Arel.sql("RANDOM()")).first : nil,
            parent: assembly
          )

          [assembly, child].each do |current_assembly|
            current_assembly.add_to_index_as_search_resource

            attachment_collection = create_attachment_collection(collection_for: current_assembly)
            create_attachment(attached_to: assembly, filename: "Exampledocument.pdf", attachment_collection:)
            create_attachment(attached_to: assembly, filename: "city.jpeg")
            create_attachment(attached_to: assembly, filename: "Exampledocument.pdf")

            2.times do
              Decidim::Category.create!(
                name: Decidim::Faker::Localized.sentence(word_count: 5),
                description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
                  Decidim::Faker::Localized.paragraph(sentence_count: 3)
                end,
                participatory_space: current_assembly
              )
            end

            Decidim::AssemblyMember::POSITIONS.each do |position|
              Decidim::AssemblyMember.create!(
                full_name: ::Faker::Name.name,
                gender: ::Faker::Lorem.word,
                birthday: ::Faker::Date.birthday(min_age: 18, max_age: 65),
                birthplace: ::Faker::Demographic.demonym,
                designation_date: ::Faker::Date.between(from: 1.year.ago, to: 1.month.ago),
                position:,
                position_other: position == "other" ? ::Faker::Job.position : nil,
                assembly: current_assembly
              )
            end

            Decidim::AssemblyMember.create!(
              user: current_assembly.organization.users.first,
              gender: ::Faker::Lorem.word,
              birthday: ::Faker::Date.birthday(min_age: 18, max_age: 65),
              birthplace: ::Faker::Demographic.demonym,
              designation_date: ::Faker::Date.between(from: 1.year.ago, to: 1.month.ago),
              position: "other",
              position_other: ::Faker::Job.position,
              assembly: current_assembly
            )

            Decidim.component_manifests.each do |manifest|
              manifest.seed!(current_assembly.reload)
            end

            Decidim::ContentBlocksCreator.new(current_assembly).create_default!
          end
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end
  end
end
