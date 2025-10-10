# Company Description Prompt (JSON Version)

## Task
Research and generate structured company description information for the specified company.

## Output Format
Return **ONLY** valid JSON in the following structure. Do NOT include any markdown code fences, explanations, or additional text.

```json
{
  "type": "company_description",
  "data": {
    "tagline": "One compelling sentence that captures what the company does",
    "overview": "2-3 paragraphs providing a comprehensive overview of the company, its mission, and what makes it unique",
    "quickFacts": [
      { "label": "Founded", "value": "2023" },
      { "label": "Headquarters", "value": "San Francisco, CA" },
      { "label": "Industry", "value": "Financial Technology" },
      { "label": "Company Size", "value": "1,000-5,000 employees" }
    ],
    "keyProducts": [
      {
        "name": "Product Name",
        "description": "Brief description of what this product does and why it matters"
      }
    ],
    "targetMarket": "Description of who the company serves - customer segments, industries, company sizes, etc."
  }
}
```

## Guidelines

### Tagline
- One powerful sentence (10-20 words)
- Should immediately convey what the company does
- Be specific, not generic
- Example: "Stripe builds economic infrastructure for the internet, enabling businesses of all sizes to accept payments and manage their finances online"

### Overview (2-3 paragraphs)
- **Paragraph 1**: What the company does, core products/services, primary value proposition
- **Paragraph 2**: The problem they solve, their approach, what makes them different
- **Paragraph 3**: Mission, vision, impact, or market position
- Be substantive - each paragraph should be 3-5 sentences
- Use specific details, not corporate platitudes

### Quick Facts (4-8 facts)
Common facts to include:
- **Founded**: Year established
- **Headquarters**: City, State/Country
- **Industry**: Specific industry classification
- **Company Size**: Employee count range or specific number
- **Type**: Public, Private, Series X, etc.
- **Funding**: Total raised (if significant and public)
- **Revenue**: Annual revenue (if public)
- **Valuation**: Current valuation (if known)

### Key Products (2-5 products)
For each product:
- **Name**: Official product name
- **Description**: 1-2 sentences explaining what it does and its key benefit
- Focus on flagship or most important products
- Explain in terms customers would understand

### Target Market
- Be specific about customer segments
- Include: company sizes, industries, geographies, use cases
- 2-3 sentences that paint a clear picture
- Example: "Stripe primarily serves online businesses ranging from startups to Fortune 500 companies. Their customers span e-commerce, SaaS, marketplaces, and platforms across all industries. They're particularly strong with developer-focused companies and businesses with complex payment needs."

## Quality Standards

✅ **DO:**
- Use concrete facts and specific details
- Research current information (check latest funding, headcount, etc.)
- Use official product names and descriptions
- Include quantifiable metrics where available
- Make it clear what makes this company unique

❌ **DON'T:**
- Use vague corporate language ("leading provider of innovative solutions")
- Include outdated information
- Make unverifiable claims
- Copy marketing copy verbatim without context
- Confuse the company with competitors

## Research Sources

1. Company's official website (About, Products pages)
2. Recent press releases and news articles
3. Crunchbase or similar for funding/size data
4. Company blog and annual reports
5. LinkedIn company page for employee count
6. Product pages for accurate product descriptions

## Example Output

```json
{
  "type": "company_description",
  "data": {
    "tagline": "Stripe builds economic infrastructure for the internet, enabling businesses of all sizes to accept payments and manage their finances online",
    "overview": "Stripe is a financial technology company that provides payment processing software and APIs for e-commerce websites and mobile applications. Founded in 2010, Stripe has grown to serve millions of businesses worldwide, from startups to Fortune 500 companies, processing hundreds of billions of dollars in transactions annually.\n\nWhat sets Stripe apart is its developer-first approach. Rather than requiring businesses to navigate complex banking relationships and compliance requirements, Stripe provides simple APIs that developers can integrate in hours, not months. The platform handles the complexity of global payments, including multiple currencies, payment methods, fraud prevention, and regulatory compliance.\n\nStripe's mission is to increase the GDP of the internet by making it easier for businesses to start, run, and scale online. Beyond payments, they've expanded into a full financial services platform including billing, invoicing, capital lending, corporate cards, and banking-as-a-service infrastructure.",
    "quickFacts": [
      { "label": "Founded", "value": "2010" },
      { "label": "Headquarters", "value": "San Francisco, CA" },
      { "label": "Industry", "value": "Financial Technology / Payments" },
      { "label": "Company Size", "value": "8,000+ employees" },
      { "label": "Type", "value": "Private (Series H)" },
      { "label": "Valuation", "value": "$50B (2023)" },
      { "label": "Annual Revenue", "value": "$14B+ (2023)" }
    ],
    "keyProducts": [
      {
        "name": "Stripe Payments",
        "description": "Core payment processing API that enables businesses to accept credit cards, digital wallets, and local payment methods with a few lines of code"
      },
      {
        "name": "Stripe Billing",
        "description": "Subscription management and recurring billing platform for SaaS companies and subscription businesses"
      },
      {
        "name": "Stripe Connect",
        "description": "Marketplace and platform payments infrastructure that enables businesses to pay sellers, service providers, and contractors"
      },
      {
        "name": "Stripe Treasury",
        "description": "Banking-as-a-service platform that lets businesses embed financial services directly into their products"
      }
    ],
    "targetMarket": "Stripe primarily serves online businesses ranging from startups to Fortune 500 companies. Their customers span e-commerce, SaaS, marketplaces, and platforms across all industries. They're particularly strong with developer-focused companies and businesses with complex payment needs like multi-currency support, subscription billing, or marketplace payments."
  }
}
```

## Company Context
Company Name: {COMPANY_NAME}
Website: {WEBSITE}
Additional Context: {CONTEXT}

## Output
Return ONLY the JSON structure. No explanations, no markdown formatting, no code blocks—just pure JSON.
