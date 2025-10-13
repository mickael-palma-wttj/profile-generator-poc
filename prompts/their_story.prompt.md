# Their Story Prompt (JSON Version)

## Task
Research and generate a compelling narrative about the company's founding, origins, and journey.

## Output Format
Return **ONLY** valid JSON in the following structure. Do NOT include any markdown code fences, explanations, or additional text.

```json
{
  "type": "their_story",
  "data": {
    "foundingStory": "3-4 paragraphs telling the story of how and why the company was founded. Include the problem they saw, what motivated them, and how they got started.",
    "founders": [
      {
        "name": "Founder Name",
        "role": "Co-Founder & CEO",
        "background": "Brief description of their background before founding the company (1-2 sentences)",
        "image": "https://example.com/image.jpg"
      }
    ],
    "ahaMoment": {
      "icon": "💡",
      "title": "The Aha Moment",
      "description": "Description of the key insight or moment that led to the company's creation"
    },
    "milestones": [
      {
        "year": "2023",
        "title": "Company Founded",
        "description": "Brief description of this milestone"
      }
    ]
  }
}
```

## Guidelines

### Founding Story (3-4 paragraphs)
Tell a compelling narrative that includes:

**Paragraph 1: The Problem**
- What problem did the founders experience or observe?
- Why did existing solutions fall short?
- What was the pain point that motivated them?

**Paragraph 2: The Insight**
- What unique insight did they have?
- What made them think they could solve it differently?
- What was their background that prepared them for this?

**Paragraph 3: The Beginning**
- How did they actually get started?
- First product, first customer, early days
- Key decisions or pivots in the early journey

**Paragraph 4 (optional): The Evolution**
- How has the company evolved since founding?
- Major inflection points or transformations
- Where they are today vs. where they started

### Founders (1-5 founders)
For each founder:
- **Name**: Full name
- **Role**: Current or founding role
- **Background**: What they did before (education, previous companies, expertise)
- **Image**: URL to professional photo (if publicly available) or omit field
- Focus on most prominent or active founders if there are many

### Aha Moment
- **Icon**: Choose relevant emoji (💡 🚀 ⚡ 🎯 💥)
- **Title**: Short, punchy headline (3-6 words)
- **Description**: 2-3 sentences describing the pivotal insight or moment
- Should feel like a "eureka" moment or turning point

### Milestones (5-10 milestones)
Choose significant moments in chronological order:
- Company founded
- First product launch
- First major customer or milestone
- Funding rounds (if significant)
- Major product launches
- International expansion
- Key partnerships or acquisitions
- Major rebrands or pivots
- Recent achievements

For each milestone:
- **Year**: Year it happened
- **Title**: Short description (3-6 words)
- **Description**: 1-2 sentences providing context

## Tone of Voice (Internal Guidance - Do NOT include in JSON output)

**IMPORTANT**: Analyze the company's tone of voice and use it to write the story, but do NOT include tone of voice details in the JSON response.

**Before writing, match the company's storytelling style:**

1. **Analyze their voice**:
   - Read their About page, blog posts, founder interviews
   - Notice: Do they tell emotional stories or stick to facts? Are they inspirational or humble? Bold or understated?
   
2. **Match their narrative style**:
   - If they're **bold and visionary** → Use aspirational language, paint the big picture ("They set out to change how the world...")
   - If they're **humble and human** → Focus on personal struggles and authenticity ("Like many founders, they faced...")
   - If they're **technical and precise** → Keep it factual, focus on the problem and solution ("They identified a gap in...")
   - If they're **playful and creative** → Include their characteristic personality and warmth

3. **Write the story in their voice**:
   - The founding story should sound like THEY would tell it
   - Use their typical word choices and phrasing patterns
   - Match their level of formality, emotion, and detail

## Quality Standards

✅ **DO:**
- Make it read like a compelling story, not a Wikipedia entry
- Include specific details that make it memorable
- Show the human side - struggles, uncertainties, breakthroughs
- Connect the founding story to the company's current mission
- Use quotes from founders if publicly available
- Include interesting anecdotes or lesser-known facts
- **Write in the company's authentic voice and storytelling style**

❌ **DON'T:**
- Make it dry or corporate-sounding
- Include every single detail or milestone (be selective)
- Speculate or make up details you can't verify
- Focus only on successes - challenges make stories compelling
- Use generic startup language ("disrupting the industry")
- Write in a generic voice that could apply to any company

## Research Sources

1. Company's "About" or "Our Story" page
2. Founder interviews in tech press (TechCrunch, Forbes, etc.)
3. Company blog posts about history and culture
4. Podcast appearances by founders
5. LinkedIn profiles for founder backgrounds
6. Press releases for milestone dates
7. Wikipedia for timeline verification

## Example Output

```json
{
  "type": "their_story",
  "data": {
    "foundingStory": "In 2009, brothers Patrick and John Collison were running their first startup when they experienced firsthand how difficult it was to accept payments online. Integrating with traditional payment processors meant weeks of paperwork, complex technical requirements, and partnerships with multiple banks. For two developers who just wanted to start selling software, it felt absurdly complicated.\n\nThe brothers realized the problem wasn't unique to them—every developer building an online business faced the same frustrating barriers. They saw an opportunity to abstract away all the complexity of payments infrastructure behind a simple API. What if accepting payments could be as easy as adding a few lines of code? This insight became the foundation of Stripe.\n\nIn 2010, Patrick and John started building what would become Stripe in their apartment. They focused on creating an elegant developer experience first, then handling all the banking relationships and compliance requirements behind the scenes. Their early beta attracted developers from startups like Lyft, Pinterest, and Shopify who were hungry for a better payments solution. Within a year of launch, Stripe was processing millions in transactions.\n\nWhat started as a simple payments API has evolved into comprehensive economic infrastructure for the internet. Today, Stripe powers payments for millions of businesses and processes hundreds of billions of dollars annually, but the core mission remains the same: make it easier for businesses to start, run, and scale online.",
    "founders": [
      {
        "name": "Patrick Collison",
        "role": "Co-Founder & CEO",
        "background": "Began programming at age 10, won Young Scientist of the Year award at 16, founded previous startup Auctomatic (acquired) at 17, attended MIT briefly before founding Stripe"
      },
      {
        "name": "John Collison",
        "role": "Co-Founder & President",
        "background": "Won Young Scientist of the Year award at 19, studied physics at Harvard, worked on Auctomatic before co-founding Stripe at age 20"
      }
    ],
    "ahaMoment": {
      "icon": "💡",
      "title": "Payments Should Be Simple",
      "description": "The Collison brothers realized that accepting payments online was unnecessarily complex. They saw that if they could handle all the banking relationships and compliance behind a simple API, they could remove this barrier for millions of developers and businesses trying to build online."
    },
    "milestones": [
      {
        "year": "2010",
        "title": "Stripe Founded",
        "description": "Patrick and John Collison start building Stripe after experiencing payment integration pain firsthand"
      },
      {
        "year": "2011",
        "title": "Public Launch",
        "description": "Stripe opens to the public after a year in private beta with early customers like Lyft and Pinterest"
      },
      {
        "year": "2012",
        "title": "First Major Funding",
        "description": "Raised $20M Series A led by Sequoia Capital and Andreessen Horowitz"
      },
      {
        "year": "2014",
        "title": "International Expansion",
        "description": "Launched in 9 European countries, beginning global expansion beyond the US"
      },
      {
        "year": "2016",
        "title": "Stripe Atlas Launched",
        "description": "Released Atlas to help entrepreneurs worldwide incorporate and start a business from anywhere"
      },
      {
        "year": "2018",
        "title": "Expanded Beyond Payments",
        "description": "Launched Stripe Billing, Terminal, and Radar to become a full financial services platform"
      },
      {
        "year": "2021",
        "title": "$600B+ in Volume",
        "description": "Processed over $600 billion in payments for millions of businesses worldwide"
      },
      {
        "year": "2023",
        "title": "Stripe Treasury & Banking",
        "description": "Launched comprehensive banking-as-a-service infrastructure for platforms"
      }
    ]
  }
}
```

## Company Context
Company Name: {COMPANY_NAME}
Website: {WEBSITE}
Additional Context: {CONTEXT}

## Output
Return ONLY the JSON structure. No explanations, no markdown formatting, no code blocks—just pure JSON.
