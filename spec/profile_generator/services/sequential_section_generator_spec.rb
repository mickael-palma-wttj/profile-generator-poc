# frozen_string_literal: true

RSpec.describe ProfileGenerator::Services::SequentialSectionGenerator do
  let(:logger) { nil }

  let(:company) { ProfileGenerator::Models::Company.new(name: "Acme", website: "https://acme.example") }

  def build_generator(section_generator, progress)
    described_class.new(
      section_generator: section_generator,
      progress_callback: progress,
      logger: logger
    )
  end

  def call_with_notifications(section_generator, names)
    notifications = []
    progress = ->(payload) { notifications << payload }

    results = build_generator(section_generator, progress).call(
      company: company,
      section_names: names
    )

    [results, notifications]
  end

  def ok_generator
    Class.new do
      def call(company:, section_name:)
        _company = company
        ProfileGenerator::Models::ProfileSection.new(
          name: section_name.capitalize,
          content: "content: #{section_name}",
          prompt_file: section_name
        )
      end
    end.new
  end

  def raising_generator
    Class.new do
      def call(_company:, _section_name:)
        raise StandardError, "boom"
      end
    end.new
  end

  it "generates sections sequentially" do
    results, = call_with_notifications(ok_generator, %w[description values])
    expect(results.map(&:content)).to eq(["content: description", "content: values"])
  end

  it "notifies progress while generating" do
    _, notifications = call_with_notifications(ok_generator, %w[description values])
    expect(notifications.any? { |n| n[:status] == :in_progress }).to be true
  end

  it "continues when a section generator raises and notifies failure" do
    notifications = []
    progress = ->(payload) { notifications << payload }

    build_generator(raising_generator, progress).call(company: company, section_names: %w[broken ok])

    expect(notifications.any? { |n| n[:section_name] == "broken" && n[:status] == :failed }).to be true
  end
end
