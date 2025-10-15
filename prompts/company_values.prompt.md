# Company Values Prompt (JSON Version)

## Task
Research and generate structured company values information for the specified company.

## Output Format
Return **ONLY** valid JSON in the following structure. Do NOT include any markdown code fences, explanations, or additional text.

```json
{
  "type": "company_values",
  "data": {
    "introduction": "Brief 1-2 sentence introduction about the company's culture and what drives them",
    "values": [
      {
        "icon": "🎯",
        "title": "Value Name",
        "tagline": "One compelling sentence that captures this value",
        "description": "2-3 paragraphs explaining this value in depth. How does it manifest in daily operations? What makes it unique to this company? Include specific examples of how employees embody this value.",
        "examples": [
          "Concrete example of this value in action (e.g., 'Teams have autonomy to make technical decisions without layers of approval')",
          "Another specific manifestation (e.g., 'Weekly demo days where anyone can present work to the entire company')"
        ]
      }
    ],
    "sources": [
      {
        "title": "Source title",
        "url": "https://example.com/source",
        "date": "2024-01-15",
        "type": "website|article|company-page|blog-post"
      }
    ]
  }
}
```

## Guidelines

### Introduction
- Keep it concise but meaningful (1-2 sentences)
- Set the tone for understanding the company's culture
- Example: "At Stripe, values aren't just words on a wall—they're the operating principles that guide every decision from product development to customer support."

### Values (4-6 values)
Each value should include:

1. **Icon** (required)
   - Choose an appropriate emoji that represents the value
   - Examples: 🎯 (focus), 💪 (resilience), 🤝 (collaboration), 🚀 (ambition), 💎 (quality), ⚡ (speed)

2. **Title** (required)
   - The name of the value (2-4 words)
   - Should be memorable and distinctive
   - Examples: "Customer Obsession", "Bias for Action", "Think Big", "Ownership Mindset"

3. **Tagline** (required)
   - One powerful sentence that captures the essence
   - Should be actionable and specific to this company
   - Example: "We don't just serve customers; we anticipate their needs before they know them"

4. **Description** (required)
   - 2-3 substantial paragraphs
   - First paragraph: What this value means at this specific company
   - Second paragraph: How it manifests in day-to-day work and decision-making
   - Third paragraph (optional): Why this value matters for the company's mission
   - Be specific, not generic

5. **Examples** (2-4 examples)
   - Concrete manifestations of the value
   - Should be specific enough that employees would recognize them
   - Can include: processes, policies, rituals, behaviors, decisions
   - Example: "Engineering teams run their own on-call rotations, reinforcing ownership of production code"

### Tone of Voice (Internal Guidance - Do NOT include in JSON output)

**IMPORTANT**: Analyze the company's tone of voice and use it when writing about their values, but do NOT include tone of voice details in the JSON response.

**Before writing, match how they talk about values:**

1. **Analyze their values communication style**:
   - Read their careers page, culture blog posts, and "About" section
   - Notice: Are they inspirational or pragmatic? Formal or casual? Idealistic or grounded?
   
2. **Match their voice in value descriptions**:
   - If they're **bold and aspirational** → Use inspiring, future-focused language ("We're building the future of...")
   - If they're **practical and grounded** → Focus on day-to-day behaviors and concrete actions ("We ship code every day...")
   - If they're **warm and human** → Use inclusive, personal language ("We believe everyone deserves...")
   - If they're **direct and no-nonsense** → Keep it clear, concise, actionable ("We move fast. We ship. We iterate.")

3. **Use their actual language**:
   - If they say "team members," don't write "employees"
   - If they say "shipping," use that instead of "delivering"
   - Match their characteristic phrases and terminology

### Quality Standards

✅ **DO:**
- Research actual company values from careers pages, blog posts, and reviews
- Include company-specific language and terminology
- Make descriptions rich with detail and context
- Show how values interconnect and reinforce each other
- Include both aspirational and practical elements
- **Write value descriptions in the company's authentic voice**

❌ **DON'T:**
- Use generic corporate speak ("we value integrity and teamwork")
- Include values that could apply to any company
- Write surface-level descriptions without substance
- Contradict information from other sections (e.g., if they're fully remote, don't emphasize office culture)
- Include more than 6 values (keeps focus on what truly matters)
- Write in a generic voice that doesn't reflect the company's culture

### Value Selection Priority

Choose values that are:
1. **Distinctive**: Unique to this company's culture
2. **Actionable**: Can be practiced daily, not just aspirational
3. **Evident**: Can be observed in company behavior and decisions
4. **Important**: Actually guides decision-making, not just marketing

### Common Value Themes (Choose Relevant Ones)

- Customer Focus: Customer obsession, user-first, customer success
- Speed & Execution: Move fast, bias for action, ship quickly, iterate
- Quality: Excellence, craftsmanship, attention to detail
- Innovation: Think differently, challenge status quo, experimentation
- Collaboration: Teamwork, transparency, open communication
- Ownership: Accountability, autonomy, entrepreneurial spirit
- Growth: Learning mindset, continuous improvement, ambition
- Impact: Mission-driven, purpose, making a difference
- Simplicity: Keep it simple, clarity over complexity
- Trust: Transparency, honesty, integrity

## Sources (3-8 sources)

**IMPORTANT**: Include citations for company values and culture information.

**For each source:**
- **title**: Clear description (e.g., "Company careers page", "Culture blog post", "CEO interview about values")
- **url**: Full URL to the source
- **date**: Publication or last updated date (YYYY-MM-DD)
- **type**: `website`, `article`, `company-page`, `blog-post`, `interview`, `employee-review`

**What to cite:**
- Official careers/about pages mentioning values or culture
- Company blog posts about culture and values
- Leadership interviews discussing company principles
- Employee reviews on Glassdoor/Comparably (as supporting evidence)
- Press releases showing values in action
- Company handbook or culture deck (if publicly available)

**Quality guidelines:**
- Prioritize official company sources for stated values
- Include third-party sources (interviews, reviews) for validation
- Cite specific blog posts or pages rather than just homepage
- Include recent sources to ensure values are current

## Example Output

{
  "type": "company_values",
  "data": {
    "introduction": "Stripe's values are the foundation of how the company operates, from building payments infrastructure to supporting millions of businesses worldwide.",
    "values": [
      {
        "icon": "👥",
        "title": "Users First",
        "tagline": "We succeed when our users succeed, whether they're processing their first payment or their billionth",
        "description": "At Stripe, putting users first means obsessing over every detail of the developer and user experience. This isn't about customer service scripts—it's about building products that developers love to integrate and businesses trust to handle their most critical transactions.\n\nThis value manifests in how teams prioritize work. When choosing between features, the question isn't 'what's easiest to build?' but 'what will have the biggest impact on our users?' Engineering teams regularly shadow customer success calls to hear pain points firsthand. Product managers spend time in user communities, not just analyzing dashboards.\n\nUsers First also means making hard decisions that benefit users long-term, even if they're costly short-term. Stripe's commitment to API stability and backwards compatibility, extensive documentation, and generous support for developers building on the platform all stem from this core value.",
        "examples": [
          "Engineering teams maintain API compatibility for years, even when it complicates internal systems",
          "Customer-facing teams have authority to make decisions that benefit users without lengthy approval chains",
          "Regular 'Bug Bash' events where entire company focuses on fixing user-reported issues",
          "Comprehensive documentation is written alongside code, not as an afterthought"
        ]
      }
    ],
    "sources": [
      {
        "title": "Stripe Careers: Our Values",
        "url": "https://stripe.com/jobs/culture",
        "date": "2024-02-10",
        "type": "company-page"
      },
      {
        "title": "Stripe Blog: Operating Principles",
        "url": "https://stripe.com/blog/operating-principles",
        "date": "2023-11-15",
        "type": "blog-post"
      },
      {
        "title": "Glassdoor: Stripe Company Reviews",
        "url": "https://www.glassdoor.com/Reviews/Stripe",
        "date": "2024-01-20",
        "type": "employee-review"
      }
    ]
  }
}

## Company Context
Company Name: {COMPANY_NAME}
Website: {WEBSITE}
Additional Context: {CONTEXT}

## Output
Return ONLY the JSON structure. No explanations, no markdown formatting, no code blocks—just pure JSON.
