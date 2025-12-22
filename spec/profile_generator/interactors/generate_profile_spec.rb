# frozen_string_literal: true

RSpec.describe ProfileGenerator::Interactors::GenerateProfile do
  subject(:interactor) do
    gen_logger = instance_double(
      ProfileGenerator::Services::GenerationLogger,
      info: nil,
      warn: nil,
      debug: nil,
      generation_started: nil,
      generation_completed: nil,
      section_started: nil,
      section_completed: nil,
      section_failed: nil
    )

    described_class.new(
      client_factory: client_factory,
      prompt_loader: prompt_loader,
      generation_logger: gen_logger,
      max_threads: 2,
      max_retries: 1
    )
  end

  let(:company) { ProfileGenerator::Models::Company.new(name: "Acme", website: "https://acme.com") }
  let(:section_name) { "company_description" }
  let(:client_factory) { instance_double(ProfileGenerator::Services::LLMClientFactory) }
  let(:anthropic_client) { instance_double(ProfileGenerator::Services::AnthropicClient) }
  let(:prompt_loader) { instance_double(ProfileGenerator::Services::PromptManager) }
  let(:prompt_config) { { provider: "anthropic" } }
  let(:prompt_object) { instance_double(ProfileGenerator::Models::Prompt, config: prompt_config, content: "prompt template") }

  describe "generate_section" do
    context "when generation succeeds" do
      before do
        allow(prompt_loader).to receive(:exist?).with(section_name).and_return(true)
        allow(prompt_loader).to receive(:load).with(section_name).and_return(prompt_object)
        allow(client_factory).to receive(:client_for).with(prompt_config).and_return(anthropic_client)

        builder = instance_double(ProfileGenerator::Services::PromptBuilder)
        allow(ProfileGenerator::Services::PromptBuilder).to receive(:new).with(company).and_return(builder)
        allow(builder).to receive_messages(build_system_prompt: "system prompt", build_user_prompt: "user prompt")

        allow(anthropic_client).to receive(:generate).and_return("Generated content from AI")
      end

      it "returns a success result" do
        result = interactor.generate_section(company: company, section_name: section_name)
        expect(result).to be_success
      end

      it "returns a section with a humanized name" do
        result = interactor.generate_section(company: company, section_name: section_name)
        expect(result.value.name).to eq("Company Description")
      end

      it "returns the generated content" do
        result = interactor.generate_section(company: company, section_name: section_name)
        expect(result.value.content).to eq("Generated content from AI")
      end
    end

    it "returns a failure Result for invalid company" do
      result = interactor.generate_section(company: "not a company", section_name: section_name)
      expect(result).to be_failure
    end

    it "returns an explanatory error message for invalid company" do
      result = interactor.generate_section(company: "not a company", section_name: section_name)
      expect(result.error).to match(/company must be a Company object/)
    end
  end

  describe "call" do
    context "when generating multiple sections sequentially" do
      let(:sections) { %w[company_description company_values] }

      before do
        allow(prompt_loader).to receive_messages(exist?: true, load: prompt_object)
        allow(client_factory).to receive(:client_for).and_return(anthropic_client)

        builder = instance_double(ProfileGenerator::Services::PromptBuilder)
        allow(ProfileGenerator::Services::PromptBuilder).to receive(:new).and_return(builder)
        allow(builder).to receive_messages(build_system_prompt: "system prompt", build_user_prompt: "user prompt")

        allow(anthropic_client).to receive(:generate).and_return("content 1", "content 2")
      end

      it "returns a successful result" do
        result = interactor.call(company: company, section_names: sections, parallel: false)
        expect(result).to be_success
      end

      it "includes humanized section names" do
        result = interactor.call(company: company, section_names: sections, parallel: false)
        expect(result.value.sections.map(&:name)).to include("Company Description", "Company Values")
      end

      it "reports sections generated in metadata" do
        result = interactor.call(company: company, section_names: sections, parallel: false)
        expect(result.metadata[:sections_generated]).to eq(2)
      end
    end
  end
end
