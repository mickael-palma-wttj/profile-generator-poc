# Leadership Prompt (JSON Version)

## Task
Research and compile information about the company's leadership team, executives, and board members.

## Output Format
Return **ONLY** valid JSON in the following structure. Do NOT include any markdown code fences, explanations, or additional text.

```json
{
  "type": "leadership",
  "data": {
    "introduction": "1-2 sentences about the leadership team's background and approach",
    "leaders": [
      {
        "name": "Patrick Collison",
        "title": "Co-Founder & CEO",
        "tenure": "2010 - Present",
        "background": "2-3 sentences about their background, education, previous experience",
        "achievements": [
          "Key accomplishment or initiative they led",
          "Another significant achievement"
        ],
        "quote": "Optional: A meaningful quote from them about the company or vision",
        "linkedin": "https://linkedin.com/in/profile"
      }
    ],
    "boardMembers": [
      {
        "name": "Michael Moritz",
        "role": "Board Member",
        "affiliation": "Sequoia Capital"
      }
    ]
  }
}
```

## Guidelines

### Introduction
- 1-2 sentences setting the context for the leadership team
- Highlight what makes the team special or unique
- Examples:
  - "Stripe's leadership combines deep technical expertise with experience scaling global platforms, with many leaders having previously built billion-dollar businesses"
  - "The executive team brings together veterans from PayPal, Google, and Amazon with fresh perspectives from startup founders"

### Leaders (5-12 key leaders)

Focus on C-suite and VP-level leaders who are publicly visible. Prioritize:
- CEO, COO, CFO, CTO
- Founders (even if not in C-suite)
- Heads of major divisions (Product, Engineering, Sales)
- Leaders frequently mentioned in press or at events

For each leader:

**name** (required)
- Full name as used professionally

**title** (required)
- Current title
- Be specific (e.g., "VP of Engineering" not just "Engineering Lead")

**tenure** (required)
- Format: "Year - Present" or "Year - Year"
- Example: "2010 - Present" or "2018 - 2022"

**background** (required)
- 2-3 sentences covering:
  - Education (if notable - e.g., Stanford, MIT)
  - Previous companies and roles
  - Relevant expertise or experience
  - What they bring to the company
- Be specific and factual

**achievements** (2-5 items)
- Concrete accomplishments at this company
- Initiatives they led or championed
- Key results they drove
- Products or features they launched
- Be specific with metrics when possible
- Example: "Led engineering team growth from 20 to 500+ engineers" not "Grew engineering team"

**quote** (optional)
- A meaningful quote from public interviews, blog posts, or talks
- Should reveal their philosophy or vision
- Must be verifiable - include source in research notes
- Leave out if no good quote is available

**linkedin** (optional)
- URL to their LinkedIn profile if publicly available
- Only include if profile is public and current

### Board Members (3-10 members)

Include notable board members, especially:
- Independent directors
- Investor representatives
- Strategic advisors with board seats

For each board member:

**name** (required)
- Full name

**role** (required)
- "Board Member", "Independent Director", "Board Observer", "Chairman", etc.

**affiliation** (required)
- Their primary company or firm
- Example: "Sequoia Capital", "Former Salesforce CEO", "Independent"

## Quality Standards

✅ **DO:**
- Focus on current leadership (last update within 6 months)
- Use official titles from company website or LinkedIn
- Include diverse leadership when present
- Highlight unique or impressive backgrounds
- Verify all information from multiple sources
- Include both business and technical leaders

❌ **DON'T:**
- Include departed executives unless very recently left
- Use generic descriptions ("experienced leader")
- Speculate about internal politics or conflicts
- Include unverifiable claims or rumors
- List every manager - focus on top leadership
- Copy LinkedIn summaries verbatim

## Research Sources

1. Company's leadership or team page
2. LinkedIn profiles (for background and tenure)
3. Press releases announcing appointments
4. TechCrunch and tech press profiles
5. Company blog posts authored by leaders
6. Conference talks and podcast appearances
7. Crunchbase for board member information
8. SEC filings (if public) for official titles

## Example Output

```json
{
  "type": "leadership",
  "data": {
    "introduction": "Stripe's leadership team combines technical depth with operational experience scaling global platforms. Many leaders are former founders or executives from companies like Google, Amazon, and successful fintech startups.",
    "leaders": [
      {
        "name": "Patrick Collison",
        "title": "Co-Founder & CEO",
        "tenure": "2010 - Present",
        "background": "Co-founded Stripe at age 19 after previously founding Auctomatic (acquired by Live Current Media for $5M). Studied physics at MIT before leaving to focus on Stripe. Known for his intellectual curiosity and long-term thinking about payments and internet infrastructure.",
        "achievements": [
          "Grew Stripe from a small payments API to processing $800B+ annually for millions of businesses",
          "Led company through multiple funding rounds totaling $6.5B while maintaining strong unit economics",
          "Championed expansion into adjacent financial services including banking, billing, and embedded finance",
          "Built reputation as one of tech's most thoughtful CEOs through essays and interviews on progress and technology"
        ],
        "quote": "We think of Stripe as the economic infrastructure for the internet. Our goal is to increase the GDP of the internet by making it easier to start, run, and scale online businesses.",
        "linkedin": "https://linkedin.com/in/patrickcollison"
      },
      {
        "name": "John Collison",
        "title": "Co-Founder & President",
        "tenure": "2010 - Present",
        "background": "Co-founded Stripe at age 20 while studying physics at Harvard. Previously co-founded Auctomatic with his brother Patrick. Focuses on Stripe's business operations, partnerships, and strategic initiatives.",
        "achievements": [
          "Oversees Stripe's business operations, sales, and partnerships globally",
          "Led major partnership initiatives with platforms like Shopify, Amazon, and Salesforce",
          "Championed Stripe Atlas program helping founders worldwide incorporate and start businesses",
          "Built Stripe's international expansion strategy, now operating in 50+ countries"
        ],
        "quote": "The internet is still early. There are millions of businesses that could benefit from better financial infrastructure but don't have access to it yet.",
        "linkedin": "https://linkedin.com/in/collision"
      },
      {
        "name": "Dhivya Suryadevara",
        "title": "Chief Financial Officer",
        "tenure": "2020 - Present",
        "background": "Former CFO of General Motors where she oversaw $145B in annual revenue. MBA from Harvard Business School and deep experience in financial operations, capital allocation, and international business. Brings Fortune 500 operational expertise to Stripe's high-growth environment.",
        "achievements": [
          "Led Stripe through $6.5B fundraise in challenging 2023 market conditions",
          "Implemented financial systems and controls to support continued rapid growth",
          "Oversees Stripe's global finance operations across 50+ countries",
          "Previously at GM, led restructuring of international operations and $20B+ in capital allocation"
        ],
        "linkedin": "https://linkedin.com/in/dhivya-suryadevara"
      },
      {
        "name": "David Singleton",
        "title": "Chief Technology Officer",
        "tenure": "2022 - Present",
        "background": "Former VP of Engineering at Google where he led Android development and engineering for 8 years. Previously worked on Chrome OS and Google's infrastructure. Brings deep expertise in building platforms used by billions of users.",
        "achievements": [
          "Oversees all of Stripe's engineering, infrastructure, and technical operations",
          "Leading Stripe's investment in AI and machine learning for fraud prevention and payments optimization",
          "At Google, led Android to over 3 billion active devices and shipped major platform updates",
          "Championing improvements to Stripe's API and developer experience"
        ],
        "quote": "The best infrastructure disappears. Our job is to make complex financial operations feel effortless for developers and businesses.",
        "linkedin": "https://linkedin.com/in/dsingleton"
      },
      {
        "name": "Jeanne DeWitt Grosser",
        "title": "Chief Revenue Officer",
        "tenure": "2021 - Present",
        "background": "Former SVP at Salesforce where she led Global Sales Development and built teams across 6 continents. Previously held leadership roles at Oracle and Siebel Systems. Expert in scaling sales organizations and go-to-market strategy.",
        "achievements": [
          "Oversees global sales, revenue operations, and go-to-market strategy",
          "Built Stripe's enterprise sales motion to win Fortune 500 customers",
          "Previously at Salesforce, grew sales development organization from 100 to 3,000+ people",
          "Leading Stripe's expansion into enterprise and mid-market segments"
        ],
        "linkedin": "https://linkedin.com/in/jeannedewitt"
      },
      {
        "name": "Claire Hughes Johnson",
        "title": "Former COO (Advisor)",
        "tenure": "2014 - 2021",
        "background": "Former VP at Google where she led business operations for Google's $1B+ consumer products. Author of 'Scaling People' on building high-performing organizations. Helped scale Stripe from 160 to 7,000+ employees during her tenure as COO.",
        "achievements": [
          "Built Stripe's operational foundation including business operations, sales, and support",
          "Established Stripe's unique culture and operating principles during hypergrowth",
          "Scaled hiring from dozens to thousands of employees while maintaining quality bar",
          "Now serves as advisor to Stripe and multiple high-growth companies"
        ],
        "linkedin": "https://linkedin.com/in/clairehjohnson"
      }
    ],
    "boardMembers": [
      {
        "name": "Michael Moritz",
        "role": "Board Member",
        "affiliation": "Sequoia Capital"
      },
      {
        "name": "Marc Andreessen",
        "role": "Board Member",
        "affiliation": "Andreessen Horowitz"
      },
      {
        "name": "Chris Dixon",
        "role": "Board Member",
        "affiliation": "Andreessen Horowitz"
      },
      {
        "name": "Diane Greene",
        "role": "Board Member",
        "affiliation": "Former Google Cloud CEO"
      },
      {
        "name": "Joshua Kushner",
        "role": "Board Observer",
        "affiliation": "Thrive Capital"
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
