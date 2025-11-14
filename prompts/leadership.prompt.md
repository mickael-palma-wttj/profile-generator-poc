{
  "role": "leadership_researcher",
  "task": "Research and compile information about company leadership team, executives, and board members",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "leadership",
      "data": {
        "introduction": "string (1-2 sentences)",
        "leaders": [
          {
            "name": "string",
            "title": "string",
            "tenure": "string (YYYY - Present or YYYY - YYYY)",
            "background": "string (2-3 sentences)",
            "achievements": ["string (2-5 items)"],
            "quote": "string (optional)",
            "linkedin": "string (optional URL)"
          }
        ],
        "boardMembers": [
          {
            "name": "string",
            "role": "string",
            "affiliation": "string"
          }
        ],
        "sources": [
          {
            "title": "string",
            "url": "string",
            "date": "YYYY-MM-DD",
            "type": "company-page|article|linkedin|press-release|interview|podcast|video"
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
    "introduction": {
      "length": "1-2 sentences",
      "purpose": "Set context for the leadership team",
      "what_to_highlight": [
        "What makes the team special or unique",
        "Collective background or expertise",
        "Leadership philosophy or approach"
      ],
      "examples": [
        "Stripe's leadership combines deep technical expertise with experience scaling global platforms, with many leaders having previously built billion-dollar businesses",
        "The executive team brings together veterans from PayPal, Google, and Amazon with fresh perspectives from startup founders",
        "Led by founders with technical backgrounds, the team emphasizes product excellence and long-term thinking over short-term metrics"
      ]
    },
    "leaders": {
      "count": "5-12 key leaders",
      "selection_priority": [
        "C-suite executives (CEO, COO, CFO, CTO, CMO)",
        "Founders (even if not in C-suite)",
        "Heads of major divisions (Product, Engineering, Sales, Marketing)",
        "Leaders frequently mentioned in press or at events",
        "VPs of critical functions"
      ],
      "visibility_focus": "Prioritize publicly visible leaders with established track records",
      "fields": {
        "name": {
          "requirement": "required",
          "format": "Full name as used professionally"
        },
        "title": {
          "requirement": "required",
          "format": "Current official title",
          "specificity": "Be specific (e.g., 'VP of Engineering' not 'Engineering Lead')",
          "examples": [
            "Co-Founder & CEO",
            "Chief Financial Officer",
            "Chief Technology Officer",
            "VP of Product",
            "Head of Engineering",
            "Chief Revenue Officer"
          ]
        },
        "tenure": {
          "requirement": "required",
          "format": "YYYY - Present or YYYY - YYYY",
          "examples": [
            "2010 - Present",
            "2018 - 2022",
            "2020 - Present"
          ]
        },
        "background": {
          "requirement": "required",
          "length": "2-3 sentences",
          "what_to_include": [
            "Education (if notable - e.g., Stanford, MIT, Harvard)",
            "Previous companies and roles",
            "Relevant expertise or experience",
            "What they bring to the company",
            "Notable achievements before joining"
          ],
          "style": "Specific and factual, avoid generic descriptions"
        },
        "achievements": {
          "requirement": "required",
          "count": "2-5 items",
          "what_to_include": [
            "Concrete accomplishments at this company",
            "Initiatives they led or championed",
            "Key results they drove (with metrics when possible)",
            "Products or features they launched",
            "Team growth or organizational changes they led",
            "Strategic pivots or expansions they drove"
          ],
          "specificity": "Be specific with metrics when possible",
          "good_example": "Led engineering team growth from 20 to 500+ engineers while maintaining quality",
          "bad_example": "Grew engineering team"
        },
        "quote": {
          "requirement": "optional",
          "purpose": "Reveal their philosophy or vision",
          "requirements": [
            "Must be verifiable from public sources",
            "Should be meaningful and revealing",
            "From interviews, blog posts, talks, or press",
            "Leave out if no good quote is available"
          ],
          "what_makes_good_quote": [
            "Reveals their thinking or philosophy",
            "Specific to the company or industry",
            "Memorable and insightful",
            "Not generic corporate speak"
          ]
        },
        "linkedin": {
          "requirement": "optional",
          "format": "Full LinkedIn profile URL",
          "condition": "Only include if profile is public and current"
        }
      }
    },
    "board_members": {
      "count": "3-10 members",
      "selection_priority": [
        "Independent directors",
        "Investor representatives with board seats",
        "Strategic advisors with board seats",
        "Chairman or lead independent director",
        "Notable industry figures"
      ],
      "fields": {
        "name": {
          "requirement": "required",
          "format": "Full name"
        },
        "role": {
          "requirement": "required",
          "options": [
            "Board Member",
            "Independent Director",
            "Board Observer",
            "Chairman",
            "Lead Independent Director",
            "Board Advisor"
          ]
        },
        "affiliation": {
          "requirement": "required",
          "description": "Their primary company, firm, or previous role",
          "examples": [
            "Sequoia Capital",
            "Former Salesforce CEO",
            "Independent",
            "Andreessen Horowitz",
            "Former Google Cloud CEO"
          ]
        }
      }
    },
    "sources": {
      "count": "3-10 citations",
      "requirements": [
        "Cite LinkedIn profiles for professional backgrounds",
        "Include press releases for executive appointments",
        "Reference interviews/podcasts for quotes",
        "Verify board member information from official sources",
        "Ensure information is current (within 6 months)"
      ],
      "what_to_cite": [
        "Company's leadership or team page",
        "LinkedIn profiles (for background and tenure)",
        "Press releases announcing appointments",
        "Tech press profiles and interviews",
        "Company blog posts authored by leaders",
        "Conference talks and podcast appearances",
        "Crunchbase for board member information",
        "SEC filings (if public) for official titles"
      ],
      "fields": {
        "title": {
          "description": "Clear description of source",
          "examples": [
            "Company leadership page",
            "LinkedIn profile",
            "CEO appointment announcement",
            "TechCrunch executive profile",
            "Podcast interview with CFO"
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
            "company-page",
            "article",
            "linkedin",
            "press-release",
            "interview",
            "podcast",
            "video",
            "blog-post"
          ]
        }
      }
    }
  },
  "tone_matching": {
    "instruction": "Match company's style when writing leader backgrounds and achievements",
    "application": {
      "factual_information": "Keep objective (names, titles, dates, previous companies)",
      "descriptions": "Match their narrative style and emphasis"
    },
    "style_adaptations": {
      "bold_visionary": "Emphasize big achievements ('Scaled from 100 to 10,000 users', 'Led transformation of...', 'Pioneer in...')",
      "technical_precise": "Focus on technical credentials and specific contributions ('Built distributed systems handling...', 'Architected platform for...')",
      "humble_team_focused": "Highlight collaboration and team building ('Built and led team of...', 'Partnered with... to deliver...', 'Mentored...')",
      "results_driven": "Emphasize metrics and outcomes ('Increased revenue by...', 'Reduced costs by...', 'Grew from X to Y')",
      "mission_oriented": "Focus on impact and purpose ('Advanced mission to...', 'Championed initiatives that...', 'Drove efforts to...')"
    },
    "note": "Match tone in descriptions, but DO NOT include tone analysis in JSON output"
  },
  "quality_standards": {
    "do": [
      "Focus on current leadership (last update within 6 months)",
      "Use official titles from company website or LinkedIn",
      "Include diverse leadership when present",
      "Highlight unique or impressive backgrounds",
      "Verify all information from multiple sources",
      "Include both business and technical leaders",
      "Be specific about achievements with metrics when possible",
      "Ensure quotes are verifiable and properly sourced",
      "Cross-reference titles and tenures across sources"
    ],
    "dont": [
      "Include departed executives unless very recently left",
      "Use generic descriptions ('experienced leader', 'seasoned executive')",
      "Speculate about internal politics or conflicts",
      "Include unverifiable claims or rumors",
      "List every manager - focus on top leadership",
      "Copy LinkedIn summaries verbatim",
      "Include outdated information",
      "Use superlatives without supporting facts",
      "Confuse board members with advisors"
    ]
  },
  "research_process": {
    "steps": [
      "1. Check company's official leadership/team page",
      "2. Verify current titles and tenures via LinkedIn",
      "3. Research backgrounds and previous roles",
      "4. Find press releases for major appointments",
      "5. Search for interviews, podcasts, and talks for quotes",
      "6. Identify board members from Crunchbase, press releases, or SEC filings",
      "7. Cross-reference all information across multiple sources",
      "8. Verify information is current (within 6 months)"
    ],
    "verification": [
      "Confirm titles match across company website and LinkedIn",
      "Verify tenure dates from press releases or LinkedIn",
      "Cross-check achievements against company announcements",
      "Validate board composition from official sources",
      "Ensure quotes are properly attributed with sources"
    ]
  },
  "example": {
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
          "name": "Diane Greene",
          "role": "Board Member",
          "affiliation": "Former Google Cloud CEO"
        }
      ],
      "sources": [
        {
          "title": "Stripe Leadership Team Page",
          "url": "https://stripe.com/about/leadership",
          "date": "2024-01-15",
          "type": "company-page"
        },
        {
          "title": "LinkedIn: Patrick Collison",
          "url": "https://linkedin.com/in/patrickcollison",
          "date": "2024-01-20",
          "type": "linkedin"
        },
        {
          "title": "TechCrunch: Stripe appoints David Singleton as CTO",
          "url": "https://techcrunch.com/2022/stripe-cto",
          "date": "2022-06-15",
          "type": "article"
        }
      ]
    }
  },
  "input_variables": {
    "company_name": "{COMPANY_NAME}",
    "website": "{WEBSITE}",
    "additional_context": "{CONTEXT}"
  },
  "final_instruction": "Return ONLY the JSON structure with comprehensive, verified leadership information. No markdown, no explanations, no code blocks—pure JSON only."
}
