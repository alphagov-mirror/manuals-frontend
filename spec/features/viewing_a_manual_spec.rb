require 'rails_helper'
require 'gds_api/test_helpers/content_store'
require 'slimmer/test_helpers/shared_templates'
include Slimmer::TestHelpers::SharedTemplates

feature "Viewing manuals and sections" do
  # As a member of the public
  # I can view a manual and its sections

  include GdsApi::TestHelpers::ContentStore

  scenario "viewing any manual" do
    stub_hmrc_manual

    visit_hmrc_manual "inheritance-tax-manual"

    expect_title_tag_to_be('Inheritance Tax Manual - HMRC internal manual - GOV.UK')
    expect_manual_title_to_be("Inheritance Tax Manual")
    expect_manual_update_date_to_be("23 January 2014")

    # This next expectation has been temporarily disabled until inline rendering of leaf
    # sections is implemented
    # expect_page_to_include_section("About this manual",
    #   includes_text: "This manual is a guide to the Income Tax (Earnings and Pensions) Act")

    expect_page_to_include_section("Inheritance tax",
                                   href: "/hmrc-internal-manuals/inheritance-tax-manual/eim00500")

    expect_page_to_be_affiliated_with_org(title: "HM Revenue & Customs",
                                          slug: "hm-revenue-customs")
  end

  scenario "viewing a non-HMRC manual" do
    stub_fake_manual
    visit_manual "my-manual-about-burritos"
    expect(page.response_headers['X-Robots-Tag']).not_to eq("none")
  end

  scenario "viewing an HMRC manual" do
    stub_hmrc_manual
    visit_hmrc_manual "inheritance-tax-manual"
    expect(page.response_headers['X-Robots-Tag']).to eq("none")
  end

  scenario "viewing a manual section with subsections" do
    stub_hmrc_manual
    stub_hmrc_manual_section_with_subsections

    visit_hmrc_manual_section "inheritance-tax-manual", "eim00500"

    expect_title_tag_to_be('EIM00500 - Inheritance Tax Manual - HMRC internal manual - GOV.UK')
    expect_section_title_to_be("Inheritance tax: table of contents")

    expect_a_child_section_group_title_of("This is a dummy child_section_group title")

    expect_page_to_include_section("Introduction to particular items",
                                   href: "/hmrc-internal-manuals/inheritance-tax-manual/eim00510")
    expect_page_to_include_section("Particular items: A to P",
                                   href: "/hmrc-internal-manuals/inheritance-tax-manual/eim00520")
    expect_page_to_include_section("Particular items: R to Z",
                                   href: "/hmrc-internal-manuals/inheritance-tax-manual/eim00530")

    # breadcrumb
    expect(page).to have_link("Contents",
                              href: "/hmrc-internal-manuals/inheritance-tax-manual")

    expect_page_to_be_affiliated_with_org(title: "HM Revenue & Customs",
                                          slug: "hm-revenue-customs")

    expect_page_to_contain_navigation_link("Previous page", "/hmrc-internal-manuals/inheritance-tax-manual/eim00100")
    expect_page_to_contain_navigation_link("Next page", "/hmrc-internal-manuals/inheritance-tax-manual/eim00900")
  end

  scenario "viewing a sub-sub section" do
    stub_hmrc_manual
    stub_hmrc_manual_section_with_subsections
    stub_hmrc_manual_sub_sub_section

    visit_hmrc_manual_section "inheritance-tax-manual", "eim00520"

    expect(page).to have_link("Contents",
                              href: "/hmrc-internal-manuals/inheritance-tax-manual")
    expect(page).to have_link("EIM00500",
                              href: "/hmrc-internal-manuals/inheritance-tax-manual/eim00500")

    expect_page_to_contain_navigation_link("Previous page", "/hmrc-internal-manuals/inheritance-tax-manual/eim00510")
    expect_page_to_contain_navigation_link("Next page", "/hmrc-internal-manuals/inheritance-tax-manual/eim00530")
  end

  scenario "visiting a manual section with a body" do
    stub_hmrc_manual
    stub_hmrc_manual_section_with_body

    visit_hmrc_manual_section "inheritance-tax-manual", "eim15000"

    # HTML in the body
    within(shared_component_selector('govspeak')) do
      expect(page).to have_content("Sections 386-400 ITEPA 2003")
    end
  end

  scenario "HMRC manual section IDs are displayed in the title" do
    stub_hmrc_manual
    visit_hmrc_manual "inheritance-tax-manual"

    expect_page_to_include_section("EIM00100 About this manual")
    expect_page_to_include_section("EIM00500 Inheritance tax",
                                   href: "/hmrc-internal-manuals/inheritance-tax-manual/eim00500")
  end

  scenario "navigating from the manual to a section" do
    stub_hmrc_manual
    stub_hmrc_manual_section_with_subsections

    visit_hmrc_manual "inheritance-tax-manual"

    select_section "Inheritance tax"

    expect(current_path).to eq("/hmrc-internal-manuals/inheritance-tax-manual/eim00500")
    expect_section_title_to_be("Inheritance tax")
  end

  scenario "visiting a non-existent section" do
    stub_hmrc_manual
    content_store_does_not_have_item('/hmrc-internal-manuals/inheritance-tax-manual/nonexistent-manual-section')

    visit_hmrc_manual_section "inheritance-tax-manual", "nonexistent-manual-section"
    expect(page.status_code).to eq(404)
  end

  scenario "visiting the obsolete prototype HMRC manual" do
    content_store_does_not_have_item('/hmrc-internal-manuals/employment-income-manual')

    visit_hmrc_manual "employment-income-manual"
    expect_manual_title_to_be("This prototype of the Employment Income Manual is no longer available")
    expect(page.status_code).to eq(200)
  end

  scenario "visiting a section in the obsolete prototype HMRC manual" do
    content_store_does_not_have_item('/hmrc-internal-manuals/employment-income-manual')
    content_store_does_not_have_item('/hmrc-internal-manuals/employment-income-manual/abc123')

    visit_hmrc_manual_section "employment-income-manual", "abc123"
    expect_manual_title_to_be("This prototype of the Employment Income Manual is no longer available")
    expect(page.status_code).to eq(200)
  end

  context "prototype HMRC manual has now been published for real" do
    scenario "visiting the manual" do
      stub_hmrc_manual("employment-income-manual", "Employment Income Manual")

      visit_hmrc_manual "employment-income-manual"
      expect_manual_title_to_be("Employment Income Manual")
      expect(page.status_code).to eq(200)
    end

    scenario "visiting one of the manual's sections" do
      stub_hmrc_manual("employment-income-manual", "Employment Income Manual")
      stub_hmrc_manual_section_with_body("employment-income-manual", "abc123", "Some section title or other")

      visit_hmrc_manual_section "employment-income-manual", "abc123"
      expect_section_title_to_be("Some section title or other")
      expect(page.status_code).to eq(200)
    end
  end

  describe "support for example manuals in govuk-content-schemas" do
    it 'should render a page including the manual title' do
      GovukContentSchemaTestHelpers::Examples.new.get_all_for_format("manual").each do |example_json|
        content_item = JSON.parse(example_json)
        content_store_has_item(content_item['base_path'], content_item)

        visit content_item['base_path']

        expect(page.status_code).to eq(200)
        expect_manual_title_to_be(content_item['title'])
      end
    end
  end

  describe "support for example manual sections from govuk-content-schemas" do
    it 'should render a page including the section title' do
      # Assumption that there is an example manual relating to every example section
      examples_for_formats(["manual", "hmrc_manual"]).each do |example_json|
        content_item = JSON.parse(example_json)
        content_store_has_item(content_item['base_path'], content_item)
      end

      examples_for_formats(["manual_section", "hmrc_manual_section"]).each do |example_json|
        content_item = JSON.parse(example_json)
        content_store_has_item(content_item['base_path'], content_item)

        visit content_item['base_path']

        expect(page.status_code).to eq(200)
        expect_section_title_to_be(content_item['title'])
      end
    end
  end
end
