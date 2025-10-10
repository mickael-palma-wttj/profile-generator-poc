# Funding Parser Prompt (JSON Version)

## Task
Research and compile detailed funding history and investor information for the specified company.

## Output Format
Return **ONLY** valid JSON in the following structure. Do NOT include any markdown code fences, explanations, or additional text.

```json
{
  "type": "funding_parser",
  "data": {
    "totalRaised": "$6.5B",
    "latestRound": {
      "amount": "$6.5B",
      "date": "March 2023"
    },
    "valuation": "$50B",
    "status": "Private (Series H)",
    "rounds": [
      {
        "series": "Seed",
        "amount": "$2M",
        "date": "March 2010",
        "valuation": "$20M",
        "leadInvestors": ["Y Combinator"],
        "description": "Initial seed funding to build payments infrastructure"
      }
    ],
    "keyInvestors": [
      {
        "name": "Sequoia Capital",
        "type": "Venture Capital",
        "description": "Early investor and board member, led multiple rounds"
      }
    ]
  }
}
```

## Guidelines

### Summary Metrics

**totalRaised** (required)
- Sum of all disclosed funding amounts
- Format: $XXM or $XXB
- Example: "$6.5B"

**latestRound** (required)
- **amount**: Most recent funding amount
- **date**: Month and year of latest round
- Use "March 2023" format

**valuation** (required if available)
- Current or most recent valuation
- Format: $XXM or $XXB
- Note if it's "at least" or estimated

**status** (required)
- Company stage and funding round
- Examples: "Private (Series H)", "Public (NASDAQ)", "Private (Growth Stage)"

### Funding Rounds (All known rounds)

List funding rounds in chronological order. For each round:

**series** (required)
- Type of funding round
- Examples: "Seed", "Series A", "Series B", "Growth", "IPO"

**amount** (required)
- Amount raised in this round
- Format: $XXM or $XXB
- Use "Undisclosed" if amount not public

**date** (required)
- Month and year
- Example: "March 2023"

**valuation** (optional)
- Post-money valuation if publicly disclosed
- Format: $XXM or $XXB

**leadInvestors** (required if known)
- Array of lead investor names
- Typically 1-3 leads per round
- Use empty array if unknown

**description** (required)
- 1-2 sentences describing:
  - What the funds were used for
  - Company stage at the time
  - Significant context (e.g., "during COVID-19", "first institutional funding")
  - Major achievements or milestones around this time

### Key Investors (5-15 investors)

Focus on most prominent investors:
- Lead investors from major rounds
- Strategic investors (corporate VCs)
- Notable angel investors
- Board members or highly involved investors

For each investor:

**name** (required)
- Official name of firm or individual

**type** (required)
- Classification: "Venture Capital", "Corporate Investor", "Angel Investor", "Private Equity", "Hedge Fund", "Sovereign Wealth Fund"

**description** (required)
- 1-2 sentences explaining:
  - Which rounds they participated in
  - Their level of involvement (board seat, lead investor)
  - Why they're notable or strategic
  - Their expertise or portfolio relevance

## Quality Standards

✅ **DO:**
- List all disclosed funding rounds chronologically
- Use official amounts from press releases or filings
- Include context about what stage the company was at
- Note if funding was during significant events (pandemic, economic downturn)
- Verify amounts match across sources
- Include both venture and strategic investors

❌ **DON'T:**
- Speculate on undisclosed amounts
- Include rumored or unconfirmed funding
- List every participating investor (focus on leads and key players)
- Use outdated valuations without noting the date
- Confuse pre-money and post-money valuations
- Include debt financing unless significant

## Funding Round Types

**Early Stage**
- **Seed**: Initial funding, typically $500K-$5M
- **Series A**: First institutional round, typically $2M-$15M
- **Series B**: Growth stage, typically $10M-$50M

**Growth Stage**
- **Series C+**: Expansion funding, $50M+
- **Growth/Late Stage**: Large rounds pre-IPO, $100M+

**Other**
- **Bridge**: Between major rounds
- **Convertible Note**: Debt that converts to equity
- **IPO**: Public offering
- **Secondary**: Existing shares sold, no capital to company
- **Debt Financing**: Loans, credit facilities

## Research Sources

1. Crunchbase (most comprehensive funding database)
2. PitchBook (for accurate valuations)
3. Company press releases announcing funding
4. TechCrunch and tech press covering rounds
5. SEC filings (Form D for US companies)
6. Company website investor relations page
7. Investor firm announcements

## Example Output

```json
{
  "type": "funding_parser",
  "data": {
    "totalRaised": "$6.5B",
    "latestRound": {
      "amount": "$6.5B",
      "date": "March 2023"
    },
    "valuation": "$50B",
    "status": "Private (Series I)",
    "rounds": [
      {
        "series": "Seed",
        "amount": "$2M",
        "date": "March 2010",
        "valuation": "$20M",
        "leadInvestors": ["Y Combinator", "Peter Thiel"],
        "description": "Initial seed funding from Y Combinator's S10 batch. Used to build initial payments API and sign first beta customers."
      },
      {
        "series": "Series A",
        "amount": "$18M",
        "date": "February 2012",
        "valuation": "$100M",
        "leadInvestors": ["Sequoia Capital", "Andreessen Horowitz"],
        "description": "Led by Sequoia and a16z to expand engineering team and launch publicly after successful beta. First major institutional funding round."
      },
      {
        "series": "Series B",
        "amount": "$20M",
        "date": "July 2012",
        "valuation": "$500M",
        "leadInvestors": ["Sequoia Capital"],
        "description": "Follow-on round just 5 months after Series A to accelerate growth and international expansion. Sequoia increased their position."
      },
      {
        "series": "Series C",
        "amount": "$80M",
        "date": "January 2014",
        "valuation": "$1.75B",
        "leadInvestors": ["Khosla Ventures"],
        "description": "Unicorn round to fund global expansion and launch new products like Stripe Atlas. Company was processing billions annually."
      },
      {
        "series": "Series D",
        "amount": "$150M",
        "date": "November 2016",
        "valuation": "$9.2B",
        "leadInvestors": ["General Catalyst", "CapitalG"],
        "description": "Growth funding led by Google's CapitalG to expand beyond payments into billing, fraud prevention, and infrastructure."
      },
      {
        "series": "Series G",
        "amount": "$600M",
        "date": "September 2019",
        "valuation": "$35B",
        "leadInvestors": ["Andreessen Horowitz", "Sequoia"],
        "description": "Major growth round making Stripe one of the most valuable private companies globally. Funded expansion into banking and financial services."
      },
      {
        "series": "Series H",
        "amount": "$600M",
        "date": "March 2021",
        "valuation": "$95B",
        "leadInvestors": ["Allianz X", "Fidelity"],
        "description": "Pandemic-era funding round as online payments surged. Peak valuation for the company during tech boom."
      },
      {
        "series": "Series I",
        "amount": "$6.5B",
        "date": "March 2023",
        "valuation": "$50B",
        "leadInvestors": ["Thrive Capital", "General Catalyst"],
        "description": "Down round reflecting broader tech market correction. Used for acquisitions and extending runway in higher interest rate environment."
      }
    ],
    "keyInvestors": [
      {
        "name": "Sequoia Capital",
        "type": "Venture Capital",
        "description": "Early investor who led Series A and B rounds. Partner Michael Moritz joined the board and has been involved since 2012. One of Stripe's most significant backers."
      },
      {
        "name": "Andreessen Horowitz",
        "type": "Venture Capital",
        "description": "Co-led Series A and participated in multiple subsequent rounds. General Partner Chris Dixon joined the board representing a16z's significant stake."
      },
      {
        "name": "Thrive Capital",
        "type": "Venture Capital",
        "description": "Led the $6.5B Series I round in 2023. Josh Kushner's firm that previously backed Instagram, GitHub, and Oscar Health."
      },
      {
        "name": "General Catalyst",
        "type": "Venture Capital",
        "description": "Long-term investor participating in Series D, E, and most recent Series I. Known for backing infrastructure companies like Stripe, Airbnb, and Snap."
      },
      {
        "name": "CapitalG",
        "type": "Corporate Investor",
        "description": "Google's growth equity fund that led Series D. Brings strategic value through Google Cloud partnerships and technical expertise."
      },
      {
        "name": "Peter Thiel",
        "type": "Angel Investor",
        "description": "Early angel investor in the seed round. PayPal co-founder saw Stripe as next evolution of online payments."
      },
      {
        "name": "Elon Musk",
        "type": "Angel Investor",
        "description": "Participated in early funding rounds. Former PayPal executive who recognized Stripe's potential to modernize payments infrastructure."
      },
      {
        "name": "Y Combinator",
        "type": "Venture Capital",
        "description": "Backed Stripe in their S10 batch in 2010. Provided initial seed funding and mentorship during the company's earliest days."
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
