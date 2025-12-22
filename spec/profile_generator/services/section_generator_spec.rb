# frozen_string_literal: true

RSpec.describe ProfileGenerator::Services::SectionGenerator do
  let(:client_factory) { instance_double(ProfileGenerator::Services::LLMClientFactory) }
  let(:anthropic_client) { instance_double(ProfileGenerator::Services::AnthropicClient) }
  let(:prompt_loader) { instance_double(ProfileGenerator::Services::PromptManager) }
  let(:logger) { instance_double(ProfileGenerator::Services::GenerationLogger, info: nil, debug: nil) }

  let(:company) { ProfileGenerator::Models::Company.new(name: "Acme", website: "https://acme.com") }
  let(:section_name) { "company_description" }
  let(:prompt_config) { { provider: "anthropic" } }
  let(:prompt_object) { instance_double(ProfileGenerator::Models::Prompt, config: prompt_config, content: "prompt template") }

  before do
    allow(prompt_loader).to receive(:load).with(section_name).and_return(prompt_object)
    allow(client_factory).to receive(:client_for).with(prompt_config).and_return(anthropic_client)
  end

  def build_generator(retryer: nil)
    described_class.new(
      client_factory: client_factory,
      prompt_loader: prompt_loader,
      logger: logger,
      retryer: retryer
    )
  end

  def build_section(retryer: nil)
    build_generator(retryer: retryer).call(company: company, section_name: section_name)
  end

  def build_called_retryer(called)
    retryer = instance_double(ProfileGenerator::Services::Retryer)
    allow(retryer).to receive(:with_retries) do
      called << true
      "AI content via retry"
    end

    retryer
  end

  describe "happy path" do
    before do
      builder = instance_double(ProfileGenerator::Services::PromptBuilder)
      allow(ProfileGenerator::Services::PromptBuilder).to receive(:new).with(company).and_return(builder)
      allow(builder).to receive_messages(
        build_system_prompt: "system prompt",
        build_user_prompt: "user prompt"
      )
      allow(anthropic_client).to receive(:generate).and_return("AI content")
    end

    it "returns a ProfileSection instance" do
      section = build_section

      expect(section).to be_a(ProfileGenerator::Models::ProfileSection)
    end

    it "humanizes the section name" do
      section = build_section

      expect(section.name).to eq("Company Description")
    end

    it "uses the AI content" do
      section = build_section

      expect(section.content).to eq("AI content")
    end

    it "records the prompt file name" do
      section = build_section

      expect(section.prompt_file).to eq(section_name)
    end
  end

  describe "with retryer" do
    before do
      builder = instance_double(ProfileGenerator::Services::PromptBuilder)
      allow(ProfileGenerator::Services::PromptBuilder).to receive(:new).with(company).and_return(builder)
      allow(builder).to receive_messages(
        build_system_prompt: "system prompt",
        build_user_prompt: "user prompt"
      )
      allow(anthropic_client).to receive(:generate).and_return("AI content via retry")
    end

    it "invokes the retryer" do
      called = []
      retryer = build_called_retryer(called)

      build_section(retryer: retryer)

      expect(called).not_to be_empty
    end

    it "returns content from the retry path" do
      retryer = instance_double(ProfileGenerator::Services::Retryer)
      allow(retryer).to receive(:with_retries).and_return("AI content via retry")

      section = build_section(retryer: retryer)

      expect(section.content).to eq("AI content via retry")
    end
  end
end
