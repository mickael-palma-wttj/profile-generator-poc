{
  "role": "company_metrics_researcher",
  "task": "Research and generate key metrics and statistics that quantify company scale, impact, and performance",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "key_numbers",
      "data": {
        "stats": [
          {
            "icon": "emoji",
            "value": "string (formatted number)",
            "label": "string (1-4 words)",
            "context": "string (1 sentence)"
          }
        ],
        "sources": [
          {
            "title": "string",
            "url": "string",
            "date": "YYYY-MM-DD",
            "type": "press-release|article|company-page|financial-report|interview|database"
          }
        ]
      }
    },
    "constraints": [
      "Return ONLY valid JSON",
      "NO markdown code fences",
      "NO explanatory text outside JSON",
      "NO comments in JSON"
    ]
  },
  "stats_guidelines": {
    "count": "6-12 stats",
    "selection_criteria": {
      "impressive": "Numbers that demonstrate scale or achievement",
      "relevant": "Metrics that matter for this specific business",
      "verifiable": "Based on public information or credible estimates",
      "recent": "Preferably from the last 1-2 years"
    },
    "storytelling": "Choose metrics that collectively tell a compelling story about the company's scale and impact",
    "diversity": "Include a mix of different metric types (people, financial, product, impact)"
  },
  "metric_categories": {
    "people_scale": {
      "description": "Metrics about team size and reach",
      "examples": [
        "Total employees/headcount",
        "Number of customers or users",
        "Active users (DAU/MAU)",
        "Offices or locations",
        "Countries served",
        "Community members"
      ]
    },
    "financial_performance": {
      "description": "Revenue and valuation metrics",
      "examples": [
        "Annual revenue",
        "Revenue growth rate",
        "Valuation (if private)",
        "Market cap (if public)",
        "Total funding raised",
        "Profitability metrics",
        "ARR/MRR (for SaaS)"
      ]
    },
    "product_service": {
      "description": "Usage and capability metrics",
      "examples": [
        "Transactions processed",
        "Volume (GMV, payment volume, etc.)",
        "Products/services offered",
        "Integrations or partnerships",
        "API calls or usage metrics",
        "Items sold or shipped"
      ]
    },
    "impact_growth": {
      "description": "Achievement and trajectory metrics",
      "examples": [
        "Year-over-year growth rates",
        "Market share or position",
        "Awards or recognitions",
        "Patents or IP",
        "Social/environmental impact",
        "Customer satisfaction scores"
      ]
    }
  },
  "stat_components": {
    "icon": {
      "requirement": "required",
      "format": "Single emoji representing the metric",
      "options": {
        "people": "👥 (employees/users/customers)",
        "money": "💰 (revenue/funding/valuation)",
        "global": "🌍 (countries/locations/reach)",
        "growth": "📈 (growth metrics/trends)",
        "achievement": "🏆 (awards/milestones/rankings)",
        "business": "💼 (customers/businesses/clients)",
        "product": "🔧 (products/services/features)",
        "speed": "⚡ (volume/velocity/performance)",
        "target": "🎯 (market position/accuracy)",
        "chart": "📊 (data/analytics/insights)",
        "rocket": "🚀 (launches/expansion/innovation)",
        "check": "✅ (reliability/quality/completion)"
      }
    },
    "value": {
      "requirement": "required",
      "formatting_rules": [
        "Use appropriate abbreviations: K (thousands), M (millions), B (billions), T (trillions)",
        "Use + for 'more than' (e.g., '8,000+', '$14B+')",
        "Use % for percentages (e.g., '99.99%', '40%')",
        "Include currency symbols where appropriate ($, €, £)",
        "Keep concise and scannable",
        "Round appropriately for clarity ($14.3B → $14B+)"
      ],
      "examples": [
        "$14B+",
        "8,000+",
        "50+",
        "Millions",
        "99.99%",
        "Top 3",
        "#1",
        "100+"
      ]
    },
    "label": {
      "requirement": "required",
      "length": "1-4 words",
      "style": "Clear, concise description with proper capitalization",
      "examples": [
        "Employees",
        "Annual Revenue",
        "Countries Served",
        "Payment Volume",
        "Total Funding",
        "Active Users",
        "Customer Satisfaction",
        "Market Position"
      ]
    },
    "context": {
      "requirement": "required",
      "length": "One sentence",
      "what_to_include": [
        "Time reference if relevant (e.g., 'as of 2023', 'in Q4 2023')",
        "Significance explanation if not obvious",
        "Growth comparison if showing trajectory",
        "Scope or methodology clarification if needed"
      ],
      "examples": [
        "Grew 40% year-over-year, making it one of the fastest-growing fintech companies",
        "As of 2023, with offices in major cities worldwide",
        "Processed over $800 billion in payment volume in 2023",
        "Based on customer surveys with 95% response rate"
      ],
      "tone": "Match company's communication style while keeping factual"
    }
  },
  "number_formatting": {
    "abbreviations": {
      "K": "thousands (e.g., 8K = 8,000)",
      "M": "millions (e.g., 2.5M = 2,500,000)",
      "B": "billions (e.g., $14B = $14,000,000,000)",
      "T": "trillions"
    },
    "modifiers": {
      "+": "more than (e.g., 8,000+)",
      "~": "approximately (use sparingly)",
      "<": "less than",
      ">": "greater than"
    },
    "consistency": [
      "Use same format for similar metrics",
      "Be consistent with precision (don't mix $14.3B and $15B)",
      "Use commas for clarity in full numbers (8,000 not 8000)"
    ]
  },
  "tone_matching": {
    "instruction": "Match company's style in metric contexts while keeping numbers objective",
    "application": {
      "numbers": "Keep factual and verifiable",
      "context": "Infuse company's voice and perspective"
    },
    "style_adaptations": {
      "data_driven_technical": "Use precise language, include methodology ('Based on Q4 2023 results', 'Verified by third-party audit')",
      "bold_aspirational": "Emphasize impact and scale ('Powering millions of businesses worldwide', 'Leading the industry transformation')",
      "humble_grounded": "Focus on customer benefit ('Helping businesses of all sizes succeed', 'Supporting entrepreneurs globally')",
      "innovative_disruptive": "Highlight breakthroughs ('First to achieve', 'Pioneering new standards')"
    },
    "note": "Match tone in context, but DO NOT include tone analysis in JSON output"
  },
  "quality_standards": {
    "do": [
      "Use official numbers from company sources when available",
      "Include year/date context (especially for funding, valuation)",
      "Round appropriately for clarity and scannability",
      "Use consistent formatting across all metrics",
      "Include a mix of different metric types",
      "Verify numbers from multiple sources",
      "Note if metrics are estimates vs. official figures",
      "Prioritize recent data (within 1-2 years)"
    ],
    "dont": [
      "Include unverifiable or speculative numbers",
      "Use outdated metrics (>2 years old) without noting",
      "Include every possible metric (be selective)",
      "Use metrics that are too industry-specific without context",
      "Make direct competitor comparisons unless factual and sourced",
      "Mix precision levels inconsistently",
      "Use metrics that contradict each other"
    ]
  },
  "research_sources": {
    "primary": [
      "Company's official press releases",
      "Investor relations pages",
      "SEC filings (if public)",
      "Company blog milestone posts",
      "Official earnings reports"
    ],
    "secondary": [
      "Recent news articles and interviews",
      "Crunchbase, PitchBook for funding data",
      "LinkedIn for employee count",
      "App Annie or SimilarWeb for usage estimates",
      "Industry reports and analyst coverage",
      "Third-party research firms"
    ],
    "verification": [
      "Cross-reference numbers across multiple sources",
      "Prioritize official company disclosures",
      "Note discrepancies between sources",
      "Verify dates and time periods match",
      "Check for updates to previously reported numbers"
    ]
  },
  "sources": {
    "count": "3-8 citations",
    "requirements": [
      "Prefer official company sources for financial metrics",
      "Include dates for all time-sensitive numbers",
      "Cite multiple sources if numbers vary",
      "Note if metrics are estimates vs. official figures"
    ],
    "what_to_cite": [
      "Company press releases and investor relations",
      "Recent news articles with disclosed metrics",
      "LinkedIn company page (for employee count)",
      "Crunchbase/PitchBook (for funding data)",
      "Company blog posts sharing milestones",
      "SEC filings (if public company)",
      "Industry reports (as secondary validation)",
      "Third-party research or estimates"
    ],
    "fields": {
      "title": {
        "description": "Clear description of source",
        "examples": [
          "Company Q4 2023 results",
          "LinkedIn company page",
          "TechCrunch interview with CEO",
          "Crunchbase funding data"
        ]
      },
      "url": {
        "description": "Full URL to the source"
      },
      "date": {
        "format": "YYYY-MM-DD",
        "description": "Publication or last updated date"
      },
      "type": {
        "options": [
          "press-release",
          "article",
          "company-page",
          "financial-report",
          "interview",
          "database",
          "blog-post"
        ]
      }
    }
  },
  "example": {
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
          "context": "Valued at $50B in latest funding round (March 2023)"
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
          "title": "Stripe Q4 2023 Financial Results",
          "url": "https://stripe.com/newsroom/news/q4-2023",
          "date": "2024-01-15",
          "type": "press-release"
        },
        {
          "title": "LinkedIn: Stripe Company Page",
          "url": "https://www.linkedin.com/company/stripe",
          "date": "2024-01-20",
          "type": "company-page"
        },
        {
          "title": "Crunchbase: Stripe FundingCrunchbase: Stripe Funding Data",
          "url": "https://www.crunchbase.com/organization/stripe",
          "date": "2024-01-15",
          "type": "database"
        }
      ]
    }
  },
  "input_variables": {
    "company_name": "{COMPANY_NAME}",
    "website": "{WEBSITE}",
    "additional_context": "{CONTEXT}"
  },
  "final_instruction": "Return ONLY the JSON structure with 6-12 compelling, verified metrics. No markdown, no explanations, no code blocks—pure JSON only."
}
