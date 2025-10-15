# Key Numbers Prompt (JSON Version)

## Task
Research and generate key metrics and statistics that quantify the company's scale, impact, and business performance.

## Output Format
Return **ONLY** valid JSON in the following structure. Do NOT include any markdown code fences, explanations, or additional text.

```json
{
  "type": "key_numbers",
  "data": {
    "stats": [
      {
        "icon": "👥",
        "value": "8,000+",
        "label": "Employees",
        "context": "Brief context about this metric (1 sentence)"
      },
      {
        "icon": "💰",
        "value": "$14B+",
        "label": "Annual Revenue",
        "context": "Additional context or year reference"
      }
    ],
    "sources": [
      {
        "title": "Source title",
        "url": "https://example.com/source",
        "date": "2024-01-15",
        "type": "press-release|article|company-page"
      }
    ]
  }
}
```

## Guidelines

### Stats Selection (6-12 stats)
Choose metrics that tell a compelling story about the company's scale and impact. Prioritize metrics that are:
- **Impressive**: Numbers that demonstrate scale or achievement
- **Relevant**: Metrics that matter for this specific business
- **Verifiable**: Based on public information or credible estimates
- **Recent**: Preferably from the last 1-2 years

### Categories of Metrics to Consider

**People & Scale**
- Employees (total headcount)
- Customers (number of customers or users)
- Active users (DAU/MAU if applicable)
- Offices or locations
- Countries served

**Financial Performance**
- Annual revenue
- Revenue growth rate
- Valuation (if private)
- Market cap (if public)
- Total funding raised
- Profitability metrics

**Product/Service Metrics**
- Transactions processed
- Volume (GMV, payment volume, etc.)
- Products/services offered
- Integrations or partnerships
- API calls or usage metrics

**Impact & Growth**
- Year-over-year growth rates
- Market share or position
- Awards or recognitions
- Patents or IP
- Social/environmental impact metrics

### For Each Stat

**Icon** (required)
Choose appropriate emoji:
- 👥 People/employees/users
- 💰 Revenue/funding/valuation
- 🌍 Global reach/countries/locations
- 📈 Growth metrics
- 🏆 Achievements/milestones
- 💼 Customers/businesses
- 🔧 Products/services
- ⚡ Speed/volume metrics
- 🎯 Market position

**Value** (required)
- Use appropriate formatting ($14B, 8K, 50%, etc.)
- Use + for "more than" (8,000+)
- Use common abbreviations (K, M, B, T)
- Keep it concise and scannable

**Label** (required)
- Clear, concise description (1-4 words)
- Capitalize properly
- Examples: "Employees", "Annual Revenue", "Countries Served"

**Context** (required)
- One sentence providing context
- Include time reference if relevant ("as of 2023")
- Explain significance if not obvious
- Compare to previous period if showing growth
- Example: "Grew 40% year-over-year, making it one of the fastest-growing fintech companies"

## Quality Standards

✅ **DO:**
- Use official numbers from company sources when available
- Include year/date context (especially for funding, valuation)
- Round appropriately for clarity ($14.3B → $14B+)
- Use consistent formatting across all metrics
- Include a mix of different metric types
- Verify numbers from multiple sources

❌ **DON'T:**
- Include unverifiable or speculative numbers
- Use outdated metrics (> 2 years old) without noting
- Include every possible metric (be selective)
- Use metrics that are too industry-specific without context
- Make direct competitor comparisons unless factual

## Research Sources

1. Company's official press releases and investor relations
2. Recent news articles and interviews
3. Crunchbase, PitchBook for funding data
4. LinkedIn for employee count
5. Company blog posts sharing milestones
6. Industry reports and analyst coverage
7. SEC filings (if public)
8. App Annie or SimilarWeb for usage estimates

## Example Output

```json
{
  "type": "key_numbers",
  "data": {
    "stats": [
      {
        "icon": "👥",
        "value": "8,000+",
        "label": "Employees",
        "context": "Grew from 3,000 in 2020 to over 8,000 globally as of 2023"
      },
      {
        "icon": "💰",
        "value": "$14B+",
        "label": "Annual Revenue",
        "context": "2023 revenue, growing 25% year-over-year"
      },
      {
        "icon": "💼",
        "value": "Millions",
        "label": "Businesses",
        "context": "Used by businesses ranging from startups to Fortune 500 companies"
      },
      {
        "icon": "🌍",
        "value": "50+",
        "label": "Countries",
        "context": "Supports payments in over 135 currencies across 50+ countries"
      },
      {
        "icon": "💰",
        "value": "$50B",
        "label": "Valuation",
        "context": "Valued at $50B in latest funding round (2023)"
      },
      {
        "icon": "📈",
        "value": "$6.5B",
        "label": "Total Funding",
        "context": "Raised across multiple rounds from top tier investors"
      },
      {
        "icon": "⚡",
        "value": "$800B+",
        "label": "Payment Volume",
        "context": "Processed over $800 billion in payment volume in 2023"
      },
      {
        "icon": "🏆",
        "value": "Top 3",
        "label": "Payment Processor",
        "context": "One of the top 3 payment processors globally by volume"
      },
      {
        "icon": "🔧",
        "value": "100+",
        "label": "Payment Methods",
        "context": "Supports over 100 payment methods including cards, wallets, and local options"
      },
      {
        "icon": "🎯",
        "value": "99.99%",
        "label": "Uptime",
        "context": "Industry-leading reliability with 99.99% uptime SLA"
      }
    ],
    "sources": [
      {
        "title": "Source title",
        "url": "https://example.com/source",
        "date": "2024-01-15",
        "type": "press-release|article|company-page|financial-report"
      }
    ]
  }
}
```

## Tone of Voice (Internal Guidance - Do NOT include in JSON output)

**IMPORTANT**: Match the company's style when writing metric contexts, but keep numbers factual.

**For metric context:**
- If they're **data-driven/technical** → Use precise language, include methodology ("Based on Q4 2023 results")
- If they're **bold/aspirational** → Emphasize impact ("Powering millions of businesses worldwide")
- If they're **humble/grounded** → Focus on customer benefit ("Helping businesses of all sizes succeed")

**Keep numbers objective** but infuse their voice into the narrative context.

## Sources (3-8 sources)

**IMPORTANT**: Include citations for key metrics and statistics.

**For each source:**
- **title**: Clear description (e.g., "Company Q4 2023 results", "LinkedIn company page", "TechCrunch interview")
- **url**: Full URL to the source
- **date**: Publication or last updated date (YYYY-MM-DD)
- **type**: `press-release`, `article`, `company-page`, `financial-report`, `interview`, `database`

**What to cite:**
- Company's official press releases and investor relations
- Recent news articles with disclosed metrics
- LinkedIn for employee count
- Crunchbase/PitchBook for funding data
- Company blog posts sharing milestones
- SEC filings (if public company)
- Industry reports (as secondary validation)

**Quality guidelines:**
- Prefer official company sources for financial metrics
- Include dates for all time-sensitive numbers
- Cite multiple sources if numbers vary
- Note if metrics are estimates vs. official figures

## Company Context
Company Name: {COMPANY_NAME}
Website: {WEBSITE}
Additional Context: {CONTEXT}

## Output
Return ONLY the JSON structure. No explanations, no markdown formatting, no code blocks—just pure JSON.
