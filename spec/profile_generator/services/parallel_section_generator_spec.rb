# frozen_string_literal: true

RSpec.describe ProfileGenerator::Services::ParallelSectionGenerator do
  let(:logger) { nil }
  let(:company) { ProfileGenerator::Models::Company.new(name: "Acme", website: "https://acme.example") }

  def generate_parallel_results(section_generator, names = %w[description values])
    fb = lambda do |_pool, &block|
      val = block.call
      Struct.new(:value).new(val)
    end

    build_parallel_generator(section_generator, ->(_) {}, fb).call(
      company: company,
      section_names: names
    )
  end

  def generate_parallel_with_notifications(section_generator, names = %w[description values])
    notifications, progress = build_notifications

    build_parallel_generator(
      section_generator,
      progress,
      ->(_pool, &block) { Struct.new(:value).new(block.call) }
    ).call(company: company, section_names: names)

    notifications
  end

  def build_notifications
    notifications = []
    progress = ->(payload) { notifications << payload }

    [notifications, progress]
  end

  def build_parallel_generator(section_generator, progress = ->(_) {}, future_builder = nil)
    described_class.new(
      section_generator: section_generator,
      max_threads: 2,
      progress_callback: progress,
      logger: logger,
      future_builder: future_builder
    )
  end

  def stub_futures_inline
    allow(Concurrent::Future).to receive(:execute) do |**_opts, &block|
      Struct.new(:value).new(block.call)
    end
  end

  def ok_section_generator
    lambda do |company:, section_name:|
      _company = company

      build_profile_section(section_name)
    end
  end

  def raising_section_generator
    lambda do |company:, section_name:|
      _company = company
      raise StandardError, "boom" if section_name == "bad"

      build_profile_section(section_name)
    end
  end

  def build_profile_section(section_name)
    ProfileGenerator::Models::ProfileSection.new(
      name: section_name.capitalize,
      content: "content: #{section_name}",
      prompt_file: section_name
    )
  end

  it "generates sections in parallel and returns results" do
    results = generate_parallel_results(ok_section_generator)
    expect(results.map(&:content).sort).to eq(["content: description", "content: values"].sort)
  end

  it "returns a prompt_file for successful sections" do
    results = generate_parallel_results(raising_section_generator, %w[good bad])
    expect(results.map(&:prompt_file)).to include("good")
  end

  it "reports failure for sections that raise" do
    notifications = generate_parallel_with_notifications(raising_section_generator, %w[good bad])
    expect(notifications.any? { |n| n[:section_name] == "bad" && n[:status] == :failed }).to be true
  end
end
