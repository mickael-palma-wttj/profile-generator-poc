# File Analysis Prompt

## Task
Analyze the uploaded files and extract key insights about the company's brand, tone, and messaging.

## Files to Analyze
The files are provided above in this message. Please analyze all of them.

## Output Format
Return **ONLY** valid JSON in the following structure. Do NOT include any markdown code fences, explanations, or additional text.

```json
{
  "tone_of_voice": "description of tone (e.g., formal, casual, playful, technical, inspiring)",
  "brand_personality": "description of brand personality traits",
  "key_themes": ["theme1", "theme2", "theme3"],
  "messaging_style": "how they structure and present information",
  "target_audience": "description of who they're speaking to",
  "core_values": ["value1", "value2"],
  "language_patterns": "distinctive words, phrases, or language choices",
  "industry_focus": "their primary industry/market focus",
  "summary": "brief summary of all findings to guide content generation"
}
```

## Guidelines

### Tone of Voice
Describe the overall tone in 1-2 sentences. Examples:
- Formal and professional
- Casual and conversational
- Technical and precise
- Playful and creative
- Inspiring and motivational

### Brand Personality
Extract 3-4 key personality traits that define the brand. Consider:
- How they present themselves
- Their values and principles
- Their communication style
- Their target audience interaction

### Key Themes
List 3-5 major themes that appear consistently across the files. These are the core concepts the company emphasizes.

### Messaging Style
Describe how they structure and present information:
- Do they use storytelling?
- Are they data-driven?
- Do they use analogies?
- What's their narrative structure?

### Target Audience
Who are they speaking to? Consider:
- Industry professionals
- General consumers
- Technical developers
- Enterprise clients
- Specific demographics

### Core Values
Extract 2-4 core values explicitly or implicitly mentioned:
- Mission-driven principles
- What they stand for
- What matters to them

### Language Patterns
Identify distinctive language choices:
- Repeated words or phrases
- Specific terminology
- Vocabulary level (simple, complex, specialized)
- Idioms or expressions they use
- Metaphors or comparisons

### Industry Focus
What is their primary industry or market focus?
- Their main business domain
- Market segment
- Geographic focus if applicable

### Summary
Provide a brief (2-3 sentences) summary of all findings that should guide content generation. This helps LLM understand how to write content that matches this company's voice and style.

## Quality Standards

✅ **DO:**
- Extract insights from ALL uploaded files
- Look for patterns and consistency across files
- Identify explicit and implicit values
- Note tone through language and structure
- Consider target audience impact on messaging

❌ **DON'T:**
- Make assumptions beyond what's in the files
- Be generic or vague
- Ignore minority or single-mention items (if consistently used)
- Over-interpret tone
- Include fields not in the JSON structure

## Output
Provide ONLY the JSON response, no explanations, no markdown formatting, no code blocks—just pure JSON.
