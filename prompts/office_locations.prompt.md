# Office Locations Prompt (JSON Version)

## Task
Research and compile information about the company's office locations, headquarters, and physical presence.

## Output Format
Return **ONLY** valid JSON in the following structure. Do NOT include any markdown code fences, explanations, or additional text.

```json
{
  "type": "office_locations",
  "data": {
    "headquarters": {
      "city": "San Francisco",
      "address": "510 Townsend Street, San Francisco, CA 94103",
      "size": "185,000 sq ft",
      "description": "Brief description of the HQ location and what makes it special (1-2 sentences)"
    },
    "offices": [
      {
        "city": "Dublin",
        "country": "Ireland",
        "type": "Regional HQ",
        "address": "1 Grand Canal Street Lower, Dublin 2",
        "size": "50,000 sq ft",
        "description": "What teams work here and why this location is important (1-2 sentences)"
      }
    ],
    "remotePresence": "Description of remote work policy and distributed team presence (2-3 sentences)",
    "sources": [
      {
        "title": "Source title",
        "url": "https://example.com/source",
        "date": "2024-01-15",
        "type": "company-page|article|press-release"
      }
    ]
  }
}
```

## Guidelines

### Headquarters (required)

**city** (required)
- City name where HQ is located
- Example: "San Francisco", "London", "Singapore"

**address** (required)
- Full street address
- Format: "Street Address, City, State/Province ZIP, Country"
- Use official address from company website or press releases

**size** (optional)
- Office size in square feet or square meters
- Include unit (sq ft, sq m, m²)
- Only include if publicly disclosed

**description** (required)
- 1-2 sentences describing:
  - What's notable about this location
  - What functions are based here
  - Any special features or design elements
  - Why this city was chosen
- Example: "The headquarters houses engineering, product, and executive teams in a renovated warehouse space in San Francisco's SOMA district. The location provides access to top technical talent and proximity to key partners."

### Offices (All other locations)

List all significant office locations. Prioritize:
- Regional headquarters
- Engineering hubs
- Major sales offices
- Customer support centers

For each office:

**city** (required)
- City name

**country** (required)
- Country name (for international clarity)

**type** (required)
- Classification: "Regional HQ", "Engineering Hub", "Sales Office", "Support Center", "R&D Center", "Satellite Office"

**address** (optional)
- Full address if publicly available
- Can omit if not disclosed

**size** (optional)
- Office size if publicly disclosed

**description** (required)
- 1-2 sentences covering:
  - Primary functions at this location
  - Size of team (if known)
  - Strategic importance of location
  - When it was established (if notable)

### Remote Presence

**remotePresence** (required if applicable)
- 2-3 sentences describing:
  - Remote work policy (fully remote, hybrid, office-first)
  - Geographic distribution of remote workers
  - Remote-first infrastructure and culture
  - How remote work is supported
- Include even if company is office-centric (state the policy)
- Example: "Stripe operates a hybrid model with employees working from offices or remotely. The company has hundreds of fully remote employees across the US and Europe, with infrastructure built to support distributed collaboration. Remote workers receive home office stipends and gather quarterly for team offsites."

## Quality Standards

✅ **DO:**
- Verify addresses from official company sources
- List offices in order of importance (HQ first, then by size/significance)
- Include both established presence and recent expansions
- Note if office is new or recently expanded
- Mention if location is in notable building or district
- Include team size if publicly disclosed

❌ **DON'T:**
- Include every small satellite office or co-working space
- Use outdated addresses (check if they've moved)
- Speculate about future office plans unless officially announced
- Include offices that have been closed
- List cities where they only have remote workers (that's remote presence)
- Include vendor or partner offices

## Office Types Explained

- **Regional HQ**: Main office for a region (e.g., EMEA HQ, APAC HQ)
- **Engineering Hub**: Significant engineering/product development presence
- **Sales Office**: Primarily focused on sales and business development
- **Support Center**: Customer support and success teams
- **R&D Center**: Research and development focused
- **Satellite Office**: Smaller presence, often sales or specific team

## Tone of Voice (Internal Guidance - Do NOT include in JSON output)

**IMPORTANT**: Match the company's style when describing office locations.

**For office descriptions:**
- If they're **bold/ambitious** → Emphasize strategic importance ("Hub for expanding into...", "Center of innovation for...")
- If they're **technical/practical** → Focus on functions and teams ("Houses 300 engineers working on...")
- If they're **culture-focused** → Highlight workspace design and team collaboration ("Designed to foster collaboration...")

**Keep addresses and facts objective** but match their narrative style in descriptions.

## Sources (2-8 sources)

**IMPORTANT**: Include citations for office location information.

**For each source:**
- **title**: Clear description (e.g., "Company careers page", "New York office opening announcement", "Real estate news")
- **url**: Full URL to the source
- **date**: Publication or last updated date (YYYY-MM-DD)
- **type**: `company-page`, `article`, `press-release`, `real-estate`, `blog-post`

**What to cite:**
- Company's careers page (often lists office locations)
- Press releases announcing new offices or expansions
- Real estate news about office leases
- Company blog posts about office openings
- Local business news when offices open
- LinkedIn for team size estimates (optional)

**Quality guidelines:**
- Cite official announcements for new office openings
- Use company careers page for current office list
- Include press releases for major expansions
- Verify addresses from official company sources

## Example Output

```json
{
  "type": "office_locations",
  "data": {
    "headquarters": {
      "city": "San Francisco",
      "address": "510 Townsend Street, San Francisco, CA 94103",
      "size": "185,000 sq ft",
      "description": "Stripe's headquarters occupies a renovated warehouse in San Francisco's SOMA district, housing over 1,000 employees across engineering, product, design, and executive teams. The space features an open floor plan designed to foster collaboration and includes a demo theater for product showcases."
    },
    "offices": [
      {
        "city": "Dublin",
        "country": "Ireland",
        "type": "Regional HQ - EMEA",
        "address": "1 Grand Canal Street Lower, Dublin 2, Ireland",
        "size": "50,000 sq ft",
        "description": "Stripe's European headquarters serves as the hub for EMEA operations, including engineering, sales, and customer support teams. Dublin was chosen for its tech talent pool and favorable business environment for serving European customers."
      },
      {
        "city": "Singapore",
        "country": "Singapore",
        "type": "Regional HQ - APAC",
        "address": "9 Straits View, Marina One West Tower, Singapore 018937",
        "size": "40,000 sq ft",
        "description": "The APAC headquarters leads Stripe's expansion across Asia-Pacific markets with teams focused on regional partnerships, localization, and regulatory compliance. Opened in 2017 to serve growing demand from Asian businesses."
      },
      {
        "city": "Seattle",
        "country": "United States",
        "type": "Engineering Hub",
        "address": "925 4th Avenue, Suite 1800, Seattle, WA 98104",
        "description": "Major engineering office focused on payments infrastructure and platform development. Home to 300+ engineers and growing, taking advantage of Seattle's deep technical talent pool from Amazon, Microsoft, and local tech companies."
      },
      {
        "city": "London",
        "country": "United Kingdom",
        "type": "Engineering Hub",
        "address": "1 Finsbury Market, London EC2A 2EN, United Kingdom",
        "description": "Stripe's second-largest office outside the US, housing engineering, product, and sales teams. Critical hub for serving UK and European markets with dedicated teams for local payment methods and financial regulations."
      },
      {
        "city": "New York",
        "country": "United States",
        "type": "Sales Office",
        "address": "354 Oyster Point Blvd, South San Francisco, CA 94080",
        "description": "Stripe's East Coast office focuses primarily on enterprise sales and partnerships with major financial institutions and corporations. Strategic location for accessing Wall Street and Fortune 500 companies."
      },
      {
        "city": "Toronto",
        "country": "Canada",
        "type": "Engineering Hub",
        "address": "135 Liberty Street, Suite 200, Toronto, ON M6K 1A7",
        "description": "Canadian headquarters serving as an engineering and product hub. Opened in 2018 to tap into Toronto's thriving tech ecosystem and serve Canadian businesses with local support."
      },
      {
        "city": "Chicago",
        "country": "United States",
        "type": "Sales Office",
        "description": "Midwest sales and partnerships office serving the central US region. Focus on mid-market and enterprise accounts in manufacturing, logistics, and traditional industries."
      },
      {
        "city": "Paris",
        "country": "France",
        "type": "Sales Office",
        "address": "18 Rue la Fayette, 75009 Paris, France",
        "description": "French office serving local market with sales, support, and partnerships teams. Critical for navigating French regulatory environment and serving local businesses."
      },
      {
        "city": "Tokyo",
        "country": "Japan",
        "type": "Sales Office",
        "description": "Japan office focused on expanding Stripe's presence in one of the world's largest e-commerce markets. Teams work on local payment method integrations and partnerships with Japanese businesses."
      },
      {
        "city": "Sydney",
        "country": "Australia",
        "type": "Sales Office",
        "description": "Australian office serving businesses across Australia and New Zealand. Established to provide local support and build partnerships in the growing APAC e-commerce ecosystem."
      }
    ],
    "remotePresence": "Stripe operates a flexible hybrid model where employees can work from offices or remotely based on team needs. The company has hundreds of fully remote employees across North America and Europe, with robust infrastructure for distributed collaboration including async communication tools and quarterly team offsites. Remote employees receive home office stipends and regular opportunities to visit offices for team gatherings.",
    "sources": [
      {
        "title": "Stripe Careers: Locations",
        "url": "https://stripe.com/jobs/locations",
        "date": "2024-01-15",
        "type": "company-page"
      },
      {
        "title": "Press Release: Stripe opens Toronto office",
        "url": "https://stripe.com/newsroom/news/toronto-office",
        "date": "2018-09-12",
        "type": "press-release"
      },
      {
        "title": "TechCrunch: Stripe expands Dublin HQ",
        "url": "https://techcrunch.com/2020/stripe-dublin",
        "date": "2020-06-15",
        "type": "article"
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
