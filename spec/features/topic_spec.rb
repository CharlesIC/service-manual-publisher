require 'rails_helper'
require 'capybara/rails'
require 'gds_api/publishing_api_v2'

RSpec.describe "Creating topics", type: :feature do
  let(:api_double) { double(:publishing_api) }

  it "save a draft topic", js: true do
    guide1 = create(:guide)
    guide2 = create(:guide)

    visit root_path
    click_link "Manage Topics"
    click_link "Create a Topic"

    expect(page).to_not have_button('Publish')

    fill_in "Path", with: "/service-manual/something"
    fill_in "Title", with: "The title"
    fill_in "Description", with: "The description"

    click_button "Add Heading"
    fill_in "Heading Title", with: "The heading title"
    fill_in "Heading Description", with: "The heading description"

    click_button "Add Guide"
    all(".js-topic-guide")[0].find("option[value='#{guide1.id}']").select_option

    click_button "Add Guide"
    all(".js-topic-guide")[1].find("option[value='#{guide2.id}']").select_option

    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:put_content)
                            .once
                            .with(an_instance_of(String), be_valid_against_schema('service_manual_topic'))
    expect(api_double).to receive(:patch_links)
                            .once
                            .with(an_instance_of(String), an_instance_of(Hash))

    click_button "Save"

    expect(Topic.count).to eq 1
    topic = Topic.first
    expect(topic.title).to eq "The title"
    expect(topic.description).to eq "The description"
    expect(topic.tree.to_json).to eq(
      [
        {
          "title": "The heading title",
          "guides": [guide1.id.to_s, guide2.id.to_s],
          "description": "The heading description",
        }
      ].to_json
    )

    expect(page).to have_button('Publish')
  end

  it "publishes an existing draft" do
    topic = build(:topic)
    topic.save!

    publishing_api = double(:publishing_api)
    stub_const("PUBLISHING_API", publishing_api)
    expect(publishing_api).to receive(:publish)

    visit edit_topic_path(topic)
    click_button 'Publish'

    within('.alert') do
      expect(page).to have_content('Topic has been published')
    end
  end
end

RSpec.describe "topic editor", type: :feature do
  it "can view topics" do
    topic = Topic.create!(
      path: "/service-manual/topic1",
      title: "Topic 1",
      description: "A Description",
    )
    visit root_path
    click_link "Manage Topics"
    click_link "Topic 1"
    expect(page).to have_link "View", href: "http://www.dev.gov.uk/service-manual/topic1"
  end
end
