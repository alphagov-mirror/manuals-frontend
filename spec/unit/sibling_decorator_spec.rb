require "rails_helper"

describe SiblingDecorator do
  let(:document_base_path) do
    "/guidance/a-manual/child-section"
  end

  let(:manual_base_path) do
    "/guidance/a-manual"
  end

  let(:document_id) do
    "child-section"
  end

  let(:document) do
    {
      base_path: document_base_path,
      details: {
        breadcrumbs: [
          {
            section_id: parent_id,
            base_path: parent_base_path,
          },
        ],
        section_id: document_id,
      },
    }.deep_stringify_keys
  end

  let(:parent_base_path) do
    "/guidance/a-manual/parent-section"
  end

  let(:parent_id) do
    "parent-section"
  end

  let(:parent) do
    {
      base_path: parent_base_path,
      details: {
        section_id: parent_id,
        child_section_groups: child_section_groups,
      },
    }.deep_stringify_keys
  end

  let(:child_section_groups) do
    []
  end

  subject(:decorator) do
    SiblingDecorator.new(
      document: document,
      parent: parent,
    )
  end

  context "for a section that is an only-child" do
    let(:child_section_groups) do
      [
        {
          child_sections: [
            {
              section_id: document_id,
              base_path: document_base_path,
              title: "Child section title",
            },
          ],
        }.deep_stringify_keys,
      ]
    end

    describe "#previous_sibling" do
      it "should be nil" do
        expect(decorator.previous_sibling).to be_nil
      end
    end

    describe "#next_sibling" do
      it "should be nil" do
        expect(decorator.next_sibling).to be_nil
      end
    end
  end

  context "for a section that is a first child" do
    let(:child_section_groups) do
      [
        {
          child_sections: [
            {
              section_id: document_id,
              base_path: document_base_path,
              title: "Child section title",
            },
            {
              section_id: "next-sibling",
              base_path: "/guidance/a-manual/next-sibling",
              title: "Next sibling title",
            },
          ],
        }.deep_stringify_keys,
      ]
    end

    describe "#previous_sibling" do
      it "should be nil" do
        expect(decorator.previous_sibling).to be_nil
      end
    end

    describe "#next_sibling" do
      it "should be present" do
        expect(decorator.next_sibling["section_id"]).to eq("next-sibling")
        expect(decorator.next_sibling["base_path"]).to eq("/guidance/a-manual/next-sibling")
        expect(decorator.next_sibling["title"]).to eq("Next sibling title")
      end
    end
  end

  context "for a section that is a last child" do
    let(:child_section_groups) do
      [
        {
          child_sections: [
            {
              section_id: "previous-sibling",
              base_path: "/guidance/a-manual/previous-sibling",
              title: "Previous sibling title",
            },
            {
              section_id: document_id,
              base_path: document_base_path,
              title: "Child section title",
            },
          ],
        }.deep_stringify_keys,
      ]
    end

    describe "#previous_sibling" do
      it "should be present" do
        expect(decorator.previous_sibling["section_id"]).to eq("previous-sibling")
        expect(decorator.previous_sibling["base_path"]).to eq("/guidance/a-manual/previous-sibling")
        expect(decorator.previous_sibling["title"]).to eq("Previous sibling title")
      end
    end

    describe "#next_sibling" do
      it "should be nil" do
        expect(decorator.next_sibling).to be_nil
      end
    end
  end

  context "for a section that is a mid child" do
    let(:child_section_groups) do
      [
        {
          child_sections: [
            {
              section_id: "previous-sibling",
              base_path: "/guidance/a-manual/previous-sibling",
              title: "Previous sibling title",
            },
            {
              section_id: document_id,
              base_path: document_base_path,
              title: "Child section title",
            },
            {
              section_id: "next-sibling",
              base_path: "/guidance/a-manual/next-sibling",
              title: "Next sibling title",
            },
          ],
        }.deep_stringify_keys,
      ]
    end

    describe "#previous_sibling" do
      it "should be present" do
        expect(decorator.previous_sibling["section_id"]).to eq("previous-sibling")
        expect(decorator.previous_sibling["base_path"]).to eq("/guidance/a-manual/previous-sibling")
        expect(decorator.previous_sibling["title"]).to eq("Previous sibling title")
      end
    end

    describe "#next_sibling" do
      it "should be present" do
        expect(decorator.next_sibling["section_id"]).to eq("next-sibling")
        expect(decorator.next_sibling["base_path"]).to eq("/guidance/a-manual/next-sibling")
        expect(decorator.next_sibling["title"]).to eq("Next sibling title")
      end
    end

    context "for a section not recognised by its parent" do
      let(:child_section_groups) do
        [
          {
            child_sections: [],
          }.deep_stringify_keys,
        ]
      end

      describe "#previous_sibling" do
        it "should be nil" do
          expect(decorator.previous_sibling).to be_nil
        end
      end

      describe "#next_sibling" do
        it "should be nil" do
          expect(decorator.next_sibling).to be_nil
        end
      end
    end
  end

  context "for a section that is the first child and has a cousin" do
    let(:child_section_groups) do
      [
        {
          child_sections: [
            {
              section_id: "cousin-section",
              base_path: "/guidance/a-manual/cousin-section",
              title: "Cousin section title",
            },
          ],
        }.deep_stringify_keys,
        {
          child_sections: [
            {
              section_id: document_id,
              base_path: document_base_path,
              title: "Child section title",
            },
            {
              section_id: "next-sibling",
              base_path: "/guidance/a-manual/next-sibling",
              title: "Next sibling title",
            },
          ],
        }.deep_stringify_keys,
      ]
    end

    describe "#previous_sibling" do
      it "should be nil" do
        expect(decorator.previous_sibling).to be_nil
      end
    end

    describe "#next_sibling" do
      it "should be present" do
        expect(decorator.next_sibling["section_id"]).to eq("next-sibling")
        expect(decorator.next_sibling["base_path"]).to eq("/guidance/a-manual/next-sibling")
        expect(decorator.next_sibling["title"]).to eq("Next sibling title")
      end
    end
  end

  context "for a section whose parent doesn't exist" do
    let(:parent) { nil }

    describe "#previous_sibling" do
      it "should be nil" do
        expect(decorator.previous_sibling).to be_nil
      end
    end

    describe "#next_sibling" do
      it "should be nil" do
        expect(decorator.next_sibling).to be_nil
      end
    end
  end
end
