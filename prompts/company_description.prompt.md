{
  "role": "company_researcher",
  "task": "Generate structured company description data",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "company_description",
      "data": {
        "tagline": "string (10-20 words, specific and compelling)",
        "overview": "string (2-3 paragraphs, 3-5 sentences each)",
        "quickFacts": [
          {
            "label": "string",
            "value": "string"
          }
        ],
        "keyProducts": [
          {
            "name": "string",
            "description": "string (1-2 sentences)"
          }
        ],
        "targetMarket": "string (2-3 sentences)",
        "sources": [
          {
            "title": "string",
            "url": "string",
            "date": "YYYY-MM-DD",
            "type": "website|article|press-release|company-page|blog-post|interview|financial-report"
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
  "content_guidelines": {
    "tagline": {
      "length": "10-20 words",
      "purpose": "Immediately convey what the company does",
      "style": "Specific, not generic",
      "example": "Stripe builds economic infrastructure for the internet, enabling businesses of all sizes to accept payments and manage their finances online"
    },
    "overview": {
      "structure": [
        "Paragraph 1: Core business, products/services, primary value proposition",
        "Paragraph 2: Problem solved, unique approach, differentiation",
        "Paragraph 3: Mission, vision, market position, or impact"
      ],
      "length": "Each paragraph 3-5 sentences",
      "style": "Substantive with specific details, avoid corporate platitudes"
    },
    "quickFacts": {
      "count": "4-8 facts",
      "common_fields": [
        "Founded (year)",
        "Headquarters (city, state/country)",
        "Industry (specific classification)",
        "Company Size (employee count)",
        "Type (Public/Private/Series X)",
        "Funding (if significant)",
        "Revenue (if public)",
        "Valuation (if known)"
      ]
    },
    "keyProducts": {
      "count": "2-5 flagship products",
      "format": "Official name + 1-2 sentence description",
      "focus": "Customer-understandable benefits"
    },
    "targetMarket": {
      "length": "2-3 sentences",
      "include": [
        "Customer segments",
        "Company sizes",
        "Industries",
        "Geographies",
        "Use cases"
      ]
    },
    "sources": {
      "count": "3-10 citations",
      "requirements": [
        "At least one primary source (company materials)",
        "At least one third-party validation",
        "Prefer sources from last 12 months",
        "Include publication dates",
        "Use accessible URLs"
      ],
      "what_to_cite": [
        "Company website/about page (mission, overview, products)",
        "Press releases (funding, milestones)",
        "News articles (context, validation)",
        "Financial reports (valuation, revenue, headcount)",
        "Company blog (product launches, updates)",
        "Careers page (culture, team size, locations)"
      ]
    }
  },
  "tone_matching": {
    "instruction": "Analyze and match the company's authentic voice",
    "process": [
      "1. Research company materials (homepage, about page, blog, social media)",
      "2. Identify communication style (formal/casual, technical/accessible, sentence structure, use of humor/metaphors)",
      "3. Apply their voice to all written content"
    ],
    "style_examples": {
      "developer_focused": "Use precise language, avoid marketing fluff (e.g., 'Simple APIs that developers love')",
      "community_focused": "Use warm, human language (e.g., 'Belong anywhere')",
      "approachable": "Use conversational tone (e.g., 'Your connected workspace')",
      "bold_aspirational": "Use confident, future-focused language"
    },
    "note": "Match tone in content, but DO NOT include tone analysis in JSON output"
  },
  "quality_standards": {
    "do": [
      "Use concrete facts and specific details",
      "Research current information",
      "Use official product names",
      "Include quantifiable metrics",
      "Highlight unique differentiators"
    ],
    "dont": [
      "Use vague corporate language ('leading provider of innovative solutions')",
      "Include outdated information",
      "Make unverifiable claims",
      "Copy marketing copy verbatim",
      "Confuse with competitors"
    ]
  },
  "research_sources": [
    "Company official website (About, Products)",
    "Recent press releases and news articles",
    "Crunchbase or similar databases",
    "Company blog and annual reports",
    "LinkedIn company page",
    "Product documentation pages"
  ],
  "example": {
    "type": "company_description",
    "data": {
      "tagline": "Stripe builds economic infrastructure for the internet, enabling businesses of all sizes to accept payments and manage their finances online",
      "overview": "Stripe is a financial technology company that provides payment processing software and APIs for e-commerce websites and mobile applications. Founded in 2010, Stripe has grown to serve millions of businesses worldwide, from startups to Fortune 500 companies, processing hundreds of billions of dollars in transactions annually.\n\nWhat sets Stripe apart is its developer-first approach. Rather than requiring businesses to navigate complex banking relationships and compliance requirements, Stripe provides simple APIs that developers can integrate in hours, not months. The platform handles the complexity of global payments, including multiple currencies, payment methods, fraud prevention, and regulatory compliance.\n\nStripe's mission is to increase the GDP of the internet by making it easier for businesses to start, run, and scale online. Beyond payments, they've expanded into a full financial services platform including billing, invoicing, capital lending, corporate cards, and banking-as-a-service infrastructure.",
      "quickFacts": [
        {"label": "Founded", "value": "2010"},
        {"label": "Headquarters", "value": "San Francisco, CA"},
        {"label": "Industry", "value": "Financial Technology / Payments"},
        {"label": "Company Size", "value": "8,000+ employees"},
        {"label": "Type", "value": "Private (Series H)"},
        {"label": "Valuation", "value": "$50B (2023)"},
        {"label": "Annual Revenue", "value": "$14B+ (2023)"}
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
      "targetMarket": "Stripe primarily serves online businesses ranging from startups to Fortune 500 companies. Their customers span e-commerce, SaaS, marketplaces, and platforms across all industries. They're particularly strong with developer-focused companies and businesses with complex payment needs.",
      "sources": [
        {
          "title": "Stripe About Page",
          "url": "https://stripe.com/about",
          "date": "2024-03-15",
          "type": "company-page"
        },
        {
          "title": "TechCrunch: Stripe reaches $50B valuation",
          "url": "https://techcrunch.com/2023/03/14/stripe-valuation-50b",
          "date": "2023-03-14",
          "type": "article"
        },
        {
          "title": "Stripe Newsroom: Q4 2023 Metrics",
          "url": "https://stripe.com/newsroom/news/q4-2023",
          "date": "2024-01-15",
          "type": "press-release"
        }
      ]
    }
  },
  "input_variables": {
    "company_name": "{COMPANY_NAME}",
    "website": "{WEBSITE}",
    "additional_context": "{CONTEXT}"
  },
  "final_instruction": "Return ONLY the JSON structure following the exact format shown in the example. No markdown, no explanations, no code blocks—pure JSON only."
}
