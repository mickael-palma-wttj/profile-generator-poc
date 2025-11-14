{
  "role": "company_culture_researcher",
  "task": "Generate structured company values and culture information",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "company_values",
      "data": {
        "introduction": "string (1-2 sentences)",
        "values": [
          {
            "icon": "emoji",
            "title": "string (2-4 words)",
            "tagline": "string (one powerful sentence)",
            "description": "string (2-3 paragraphs)",
            "examples": ["string (2-4 concrete examples)"]
          }
        ],
        "sources": [
          {
            "title": "string",
            "url": "string",
            "date": "YYYY-MM-DD",
            "type": "website|article|company-page|blog-post|interview|employee-review"
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
      "purpose": "Set the tone for understanding the company's culture",
      "style": "Concise but meaningful",
      "example": "At Stripe, values aren't just words on a wall—they're the operating principles that guide every decision from product development to customer support."
    },
    "values": {
      "count": "4-6 values",
      "selection_criteria": [
        "Distinctive: Unique to this company's culture",
        "Actionable: Can be practiced daily",
        "Evident: Observable in company behavior",
        "Important: Actually guides decision-making"
      ],
      "components": {
        "icon": {
          "requirement": "required",
          "format": "Single emoji representing the value",
          "examples": {
            "focus": "🎯",
            "resilience": "💪",
            "collaboration": "🤝",
            "ambition": "🚀",
            "quality": "💎",
            "speed": "⚡",
            "innovation": "💡",
            "growth": "🌱",
            "trust": "🔒",
            "impact": "🌍"
          }
        },
        "title": {
          "requirement": "required",
          "length": "2-4 words",
          "style": "Memorable and distinctive",
          "examples": [
            "Customer Obsession",
            "Bias for Action",
            "Think Big",
            "Ownership Mindset",
            "Move Fast",
            "Quality First"
          ]
        },
        "tagline": {
          "requirement": "required",
          "format": "One powerful sentence",
          "style": "Actionable and specific to this company",
          "example": "We don't just serve customers; we anticipate their needs before they know them"
        },
        "description": {
          "requirement": "required",
          "length": "2-3 substantial paragraphs",
          "structure": [
            "Paragraph 1: What this value means at this specific company",
            "Paragraph 2: How it manifests in day-to-day work and decision-making",
            "Paragraph 3 (optional): Why this value matters for the company's mission"
          ],
          "style": "Specific, not generic; rich with detail and context"
        },
        "examples": {
          "requirement": "required",
          "count": "2-4 examples",
          "format": "Concrete manifestations of the value",
          "types": [
            "Processes",
            "Policies",
            "Rituals",
            "Behaviors",
            "Decisions"
          ],
          "example": "Engineering teams run their own on-call rotations, reinforcing ownership of production code"
        }
      }
    },
    "sources": {
      "count": "3-8 citations",
      "requirements": [
        "Prioritize official company sources for stated values",
        "Include third-party sources for validation",
        "Cite specific pages rather than just homepage",
        "Use recent sources to ensure values are current"
      ],
      "what_to_cite": [
        "Official careers/about pages",
        "Company blog posts about culture",
        "Leadership interviews discussing principles",
        "Employee reviews (Glassdoor/Comparably)",
        "Press releases showing values in action",
        "Company handbook or culture deck (if public)"
      ]
    }
  },
  "common_value_themes": {
    "customer_focus": [
      "Customer obsession",
      "User-first",
      "Customer success"
    ],
    "speed_execution": [
      "Move fast",
      "Bias for action",
      "Ship quickly",
      "Iterate"
    ],
    "quality": [
      "Excellence",
      "Craftsmanship",
      "Attention to detail"
    ],
    "innovation": [
      "Think differently",
      "Challenge status quo",
      "Experimentation"
    ],
    "collaboration": [
      "Teamwork",
      "Transparency",
      "Open communication"
    ],
    "ownership": [
      "Accountability",
      "Autonomy",
      "Entrepreneurial spirit"
    ],
    "growth": [
      "Learning mindset",
      "Continuous improvement",
      "Ambition"
    ],
    "impact": [
      "Mission-driven",
      "Purpose",
      "Making a difference"
    ],
    "simplicity": [
      "Keep it simple",
      "Clarity over complexity"
    ],
    "trust": [
      "Transparency",
      "Honesty",
      "Integrity"
    ]
  },
  "tone_matching": {
    "instruction": "Analyze and match the company's voice when writing about values",
    "process": [
      "1. Read careers page, culture blog posts, and about section",
      "2. Identify style: inspirational/pragmatic, formal/casual, idealistic/grounded",
      "3. Apply their voice to all value descriptions"
    ],
    "style_adaptations": {
      "bold_aspirational": "Use inspiring, future-focused language ('We're building the future of...')",
      "practical_grounded": "Focus on day-to-day behaviors and concrete actions ('We ship code every day...')",
      "warm_human": "Use inclusive, personal language ('We believe everyone deserves...')",
      "direct_no_nonsense": "Keep it clear, concise, actionable ('We move fast. We ship. We iterate.')"
    },
    "language_matching": [
      "Use their terminology (e.g., 'team members' vs 'employees')",
      "Match their characteristic phrases",
      "Adopt their action verbs (e.g., 'shipping' vs 'delivering')"
    ],
    "note": "Match tone in content, but DO NOT include tone analysis in JSON output"
  },
  "quality_standards": {
    "do": [
      "Research actual company values from careers pages and blog posts",
      "Include company-specific language and terminology",
      "Make descriptions rich with detail and context",
      "Show how values interconnect and reinforce each other",
      "Include both aspirational and practical elements",
      "Write value descriptions in the company's authentic voice"
    ],
    "dont": [
      "Use generic corporate speak ('we value integrity and teamwork')",
      "Include values that could apply to any company",
      "Write surface-level descriptions without substance",
      "Contradict information from other sections",
      "Include more than 6 values",
      "Write in a generic voice that doesn't reflect the company's culture"
    ]
  },
  "example": {
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
  },
  "input_variables": {
    "company_name": "{COMPANY_NAME}",
    "website": "{WEBSITE}",
    "additional_context": "{CONTEXT}"
  },
  "final_instruction": "Return ONLY the JSON structure following the exact format shown in the example. No markdown, no explanations, no code blocks—pure JSON only."
}
