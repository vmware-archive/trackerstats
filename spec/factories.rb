FactoryGirl.define do

  factory :project, class: Project do
    sequence(:id, 1)
    name { "Project-#{id}" }
  end

  factory :iteration, class: Iteration do
    sequence(:number, 1)
    sequence(:start, 0) { |n| n.weeks.from_now.to_date }
    finish { start + 1.week }

    factory :iteration_with_stories do
      stories { [
          FactoryGirl.build(:story, :feature, :accepted, created_at: start + 2.days),
          FactoryGirl.build(:story, :chore, :started, created_at: start + 2.days),
          FactoryGirl.build(:story, :bug, :accepted, created_at: start + 2.days)
      ] }
    end

  end

  factory :story, class: Story do
    ignore do
      iteration FactoryGirl.build :iteration,
                                  number: 1,
                                  start: Time.now.beginning_of_day
    end

    story_type "feature"
    current_state "accepted"
    created_at { iteration.start + 10.hours }
    accepted_at { created_at + 1.day }

    trait :feature do story_type "feature" end
    trait :chore do story_type "chore" end
    trait :bug do story_type "bug" end

    trait :started do current_state "started" end
    trait :accepted do current_state "accepted" end

  end

end
