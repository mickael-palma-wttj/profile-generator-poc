# frozen_string_literal: true

RSpec.describe ProfileGenerator::Helpers::SectionContentHelper do
  describe ".format" do
    context "when content is blank" do
      it "returns empty string for nil" do
        expect(described_class.format(nil)).to eq("")
      end

      it "returns empty string for empty string" do
        expect(described_class.format("")).to eq("")
      end

      it "returns empty string for whitespace" do
        expect(described_class.format("   \n  ")).to eq("")
      end
    end

    it "strips code fences around html blocks" do
      input = "```html\n<div class=\"value-card\">Hello</div>\n```"
      expect(described_class.format(input)).to eq("<div class=\"value-card\">Hello</div>")
    end

    it "returns raw html when content is html" do
      html = '<div class="story-content">Story here</div>'
      expect(described_class.format(html)).to eq(html)
    end

    it "extracts actual content when thinking/search tags are present" do
      noisy = 'Some preamble <code class="search">searching...</code> ' \
              '<div class="company-overview">Real content</div>'
      result = described_class.format(noisy)
      expect(result).to include('<div class="company-overview">Real content</div>')
    end

    context "when content is not html" do
      let(:formatter) { instance_double(ProfileGenerator::Services::ContentFormatter, format: "<p>markdown</p>") }

      before { allow(ProfileGenerator::Services::ContentFormatter).to receive(:new).and_return(formatter) }

      it "delegates to ContentFormatter" do
        expect(described_class.format("This is plain text")).to eq("<p>markdown</p>")
      end
    end
  end
end
