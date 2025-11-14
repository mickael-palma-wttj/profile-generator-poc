{
  "role": "remote_work_policy_researcher",
  "task": "Research and provide comprehensive information about company remote work policies, flexibility, and distributed work culture",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "remote_policy",
      "data": {
        "model": "string (Office-First|Hybrid-Required|Hybrid-Flexible|Remote-First|Fully Remote)",
        "summary": "string (2-3 sentences)",
        "workLocation": {
          "policy": "string (1-2 sentences)",
          "officeExpectation": "string",
          "workFromAnywhere": "string"
        },
        "equipment": {
          "budget": "string",
          "provided": "string",
          "support": "string"
        },
        "schedule": {
          "flexibility": "string",
          "coreHours": "string",
          "asynchronous": "string"
        },
        "tools": {
          "communication": "string",
          "collaboration": "string",
          "socializing": "string"
        },
        "culture": {
          "inPerson": "string",
          "remoteCulture": "string",
          "inclusion": "string"
        },
        "sources": [
          {
            "title": "string",
            "url": "string",
            "date": "YYYY-MM-DD",
            "type": "company-page|article|press-release|employee-review|blog-post|job-posting|interview"
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
    "model": {
      "requirement": "required",
      "description": "Choose the category that best describes overall remote work policy",
      "options": {
        "Office-First": {
          "definition": "Primarily in-office with limited remote options",
          "characteristics": [
            "Default expectation is office presence",
            "Remote work by exception or limited days",
            "Example: In office 5 days/week with 1-2 remote days allowed"
          ]
        },
        "Hybrid-Required": {
          "definition": "Mix of office and remote with set requirements",
          "characteristics": [
            "Set hybrid schedule (e.g., 3 days office, 2 remote)",
            "Specific days may be required",
            "Example: Tuesday, Wednesday, Thursday in office"
          ]
        },
        "Hybrid-Flexible": {
          "definition": "Mix of office and remote, employee choice",
          "characteristics": [
            "Employees choose mix of office/remote",
            "No set schedule",
            "Example: Come to office as needed for your work"
          ]
        },
        "Remote-First": {
          "definition": "Default remote with optional office access",
          "characteristics": [
            "Optimized for distributed work",
            "Offices available but optional",
            "Example: 50%+ employees fully remote"
          ]
        },
        "Fully Remote": {
          "definition": "No physical offices, entirely distributed",
          "characteristics": [
            "No permanent offices",
            "All employees distributed",
            "Example: Entire company is remote with co-working stipends"
          ]
        }
      }
    },
    "summary": {
      "requirement": "required",
      "length": "2-3 sentences",
      "purpose": "Capture essence of remote work philosophy",
      "what_to_include": [
        "Overall stance on remote work",
        "Flexibility employees have",
        "Reasoning behind their approach",
        "Long-term commitment or temporary"
      ],
      "example": "Stripe operates a hybrid-flexible model where employees can choose to work from offices, fully remotely, or a mix of both. The company maintains offices in major tech hubs but has invested heavily in remote infrastructure to support distributed collaboration. Teams gather in person quarterly for planning and team building, but day-to-day work is optimized for flexibility."
    },
    "work_location": {
      "policy": {
        "requirement": "required",
        "length": "1-2 sentences",
        "what_to_include": [
          "Where employees can work from",
          "Percentage of remote workers if known",
          "Office availability"
        ],
        "example": "Employees can work from any Stripe office, their home, or co-working spaces. Remote work is supported globally with teams distributed across North America, Europe, and parts of Asia."
      },
      "office_expectation": {
        "requirement": "required",
        "what_to_include": [
          "Is office attendance required?",
          "How often are people expected in office?",
          "Team-specific variations",
          "Flexibility level"
        ],
        "example": "No mandatory office attendance, though teams coordinate regular in-person days. Some teams opt for weekly or monthly in-office days for collaboration."
      },
      "work_from_anywhere": {
        "requirement": "required",
        "what_to_include": [
          "Can employees work from anywhere in the world?",
          "Geographic restrictions or requirements",
          "Countries where employment is supported",
          "International travel policies",
          "Digital nomad arrangements"
        ],
        "example": "Employees must be located in countries where Stripe has legal entities for employment. Within those countries, work from anywhere is supported. International travel for remote work up to 90 days per year is allowed with approval."
      }
    },
    "equipment": {
      "budget": {
        "requirement": "required",
        "what_to_include": [
          "Initial home office setup budget amount",
          "Annual refresh or upgrade budget",
          "Specific dollar amounts when known"
        ],
        "example": "$1,500 initial setup budget plus $500 annually for replacements"
      },
      "provided": {
        "requirement": "required",
        "what_to_include": [
          "Standard equipment provided to all employees",
          "Computer/laptop options",
          "Monitors and accessories",
          "Additional equipment available on request"
        ],
        "example": "MacBook Pro or PC of choice, external monitors, keyboard, mouse, headphones, and webcam. Additional equipment like monitor arms or desk accessories available on request."
      },
      "support": {
        "requirement": "required",
        "what_to_include": [
          "IT support availability",
          "Equipment repair/replacement process",
          "Ergonomic consultations",
          "Response time for issues"
        ],
        "example": "24/7 IT support via Slack or phone. Equipment repair or replacement shipped next-day. Ergonomic consultations available for home office optimization."
      }
    },
    "schedule": {
      "flexibility": {
        "requirement": "required",
        "what_to_include": [
          "How flexible are working hours?",
          "Are there set hours or full flexibility?",
          "Expectations around availability"
        ],
        "example": "Fully flexible schedule with no set hours. Employees work when they're most productive, with core collaboration windows for team sync."
      },
      "core_hours": {
        "requirement": "required",
        "what_to_include": [
          "Required meeting windows or core hours",
          "Time zone considerations",
          "How global teams handle timezone differences",
          "Meeting rotation for fairness"
        ],
        "example": "Teams establish core overlap hours based on their distribution, typically 10am-2pm in their primary time zone. Global teams rotate meeting times to share timezone burden."
      },
      "asynchronous": {
        "requirement": "required",
        "what_to_include": [
          "How company handles async work",
          "Documentation practices",
          "Meeting recording policies",
          "Default communication modes"
        ],
        "example": "Strong async culture with detailed written documentation and recorded meetings. Default to async communication via Notion and Slack, with synchronous meetings reserved for brainstorming or complex discussions."
      }
    },
    "tools": {
      "communication": {
        "requirement": "required",
        "what_to_include": [
          "Primary tools for chat, email, video",
          "Guidelines for tool usage",
          "Video meeting norms"
        ],
        "focus": "Primary tools only, not exhaustive list",
        "example": "Slack for instant messaging, Zoom for video calls, Gmail for email. Company encourages thoughtful use of communication channels based on urgency."
      },
      "collaboration": {
        "requirement": "required",
        "what_to_include": [
          "Tools for documentation",
          "Project management platforms",
          "Design and code collaboration tools",
          "Integration between tools"
        ],
        "example": "Notion for documentation, Figma for design, GitHub for code, Linear for task management. All meetings recorded and shared for async viewing."
      },
      "socializing": {
        "requirement": "required",
        "what_to_include": [
          "How remote teams socialize",
          "Virtual social events",
          "Tools for connection",
          "Frequency of social activities"
        ],
        "example": "Virtual coffee chats through Donut, monthly team trivia nights, Slack channels for hobbies and interests, and quarterly in-person team gatherings."
      }
    },
    "culture": {
      "in_person": {
        "requirement": "required",
        "what_to_include": [
          "How often do people gather in person?",
          "Types of in-person events",
          "Who covers costs?",
          "Mandatory vs optional gatherings"
        ],
        "example": "Quarterly team offsites for planning and bonding, optional monthly office days, and annual all-company gathering. Travel and accommodation fully covered."
      },
      "remote_culture": {
        "requirement": "required",
        "what_to_include": [
          "How culture is maintained remotely",
          "Communication practices",
          "Transparency initiatives",
          "Virtual events and rituals"
        ],
        "example": "Strong documentation culture ensures information is accessible to all. Regular all-hands meetings, transparent internal communications, and intentional virtual social events keep remote employees connected."
      },
      "inclusion": {
        "requirement": "required",
        "what_to_include": [
          "How remote employees are included",
          "Equal access to opportunities",
          "Meeting practices for hybrid teams",
          "Tracking of remote employee experience"
        ],
        "example": "Remote employees have equal access to growth opportunities and leadership visibility. All meetings are video-first even if some attendees are in office. Company tracks promotion rates to ensure remote employees aren't disadvantaged."
      }
    },
    "sources": {
      "count": "2-8 citations",
      "criticality": "REQUIRED - Must include verifiable sources",
      "priority": "Official company sources for policies, employee reviews for actual practices",
      "types": {
        "company-page": "Careers page, remote work policy page, employee handbook sections",
        "article": "News articles, blog posts about company's remote work announcements",
        "press-release": "Official announcements about remote work changes",
        "employee-review": "Glassdoor, Blind, or other employee review sites (for validation)",
        "blog-post": "Company engineering/culture blog posts about remote work",
        "job-posting": "Job listings that specify remote work arrangements",
        "interview": "Leadership interviews discussing remote work philosophy"
      },
      "quality_guidelines": [
        "Prioritize official company sources for formal policies",
        "Use employee reviews to validate actual practice vs. stated policy",
        "Include recent job postings to show current remote work options",
        "Link to specific blog posts about remote work changes or philosophy",
        "If policy differs by team/role, cite sources for each variation",
        "Date sources appropriately (policies from last 1-2 years most relevant)"
      ],
      "fields": {
        "title": {
          "description": "Clear, descriptive title of the source",
          "examples": [
            "Remote Work at Stripe - Careers Page",
            "Stripe Employee Reviews - Remote Work",
            "How Stripe Built a Hybrid-First Culture",
            "Stripe's Remote Work Equipment Policy"
          ]
        },
        "url": {
          "description": "Direct link to the source (must be accessible)"
        },
        "date": {
          "format": "YYYY-MM-DD",
          "description": "Publication or last update date"
        },
        "type": {
          "options": [
            "company-page",
            "article",
            "press-release",
            "employee-review",
            "blog-post",
            "job-posting",
            "interview"
          ]
        }
      }
    }
  },
  "tone_matching": {
    "instruction": "Match company's tone when describing remote work policies",
    "style_adaptations": {
      "employee_centric": {
        "companies": "GitLab, Buffer",
        "style": "Warm, transparent, detailed language emphasizing trust and flexibility",
        "example": "We trust our team members to work when and where they're most productive"
      },
      "tech_forward": {
        "companies": "Stripe, Shopify",
        "style": "Practical, data-driven language focusing on tools and processes",
        "example": "Our remote infrastructure enables seamless collaboration across time zones"
      },
      "traditional": {
        "companies": "Banks, enterprises",
        "style": "Professional, policy-focused language emphasizing structure and guidelines",
        "example": "Remote work arrangements follow established guidelines and manager approval"
      },
      "startup_culture": {
        "style": "Casual, authentic language reflecting actual practices over formal policies",
        "example": "Work from wherever you're happiest - we care about output, not location"
      }
    },
    "principle": "Match how the company communicates about work culture and benefits. Avoid generic HR language—use their authentic voice.",
    "note": "Match tone throughout, but DO NOT include tone analysis in JSON output"
  },
  "quality_standards": {
    "do": [
      "Be specific about policies (not vague 'we support flexibility')",
      "Include both official policy and actual practice",
      "Note if policies differ by role or team",
      "Mention if policy has changed recently",
      "Include geographic limitations clearly",
      "Explain the 'why' behind policies when known",
      "Verify information from multiple sources",
      "Include employee perspective from reviews",
      "Note percentage of remote workers if known",
      "Specify budget amounts and timeframes"
    ],
    "dont": [
      "Copy marketing language about 'flexible culture'",
      "Ignore negative aspects mentioned in reviews",
      "Assume flexibility means no structure",
      "Confuse 'work from anywhere' with 'hire from anywhere'",
      "Oversell remote culture if reviews suggest issues",
      "List every communication tool (focus on primary ones)",
      "Include speculative or unverified policies",
      "Use generic descriptions without specifics",
      "Ignore timezone or location restrictions"
    ]
  },
  "research_process": {
    "steps": [
      "1. Check company careers page for official remote work policy",
      "2. Review job postings to see remote work options offered",
      "3. Search for company blog posts about remote work philosophy",
      "4. Check employee reviews (Glassdoor, Blind) for actual practices",
      "5. Look for press releases about remote work policy changes",
      "6. Search for leadership interviews discussing remote work",
      "7. Verify equipment budgets and support from multiple sources",
      "8. Identify tools used from job descriptions or tech blog posts",
      "9. Look for information about in-person gatherings frequency",
      "10. Cross-reference all information across sources"
    ],
    "verification": [
      "Confirm policy is current (within last 1-2 years)",
      "Check if employee reviews align with official policy",
      "Verify geographic restrictions and legal entity locations",
      "Confirm equipment budgets and what's provided",
      "Validate meeting culture and async practices",
      "Check if policy differs by team, role, or seniority",
      "Verify in-person gathering frequency and coverage"
    ]
  },
  "example": {
    "type": "remote_policy",
    "data": {
      "model": "Hybrid-Flexible",
      "summary": "Stripe operates a hybrid-flexible model where employees can choose to work from offices, fully remotely, or a mix of both based on their personal preference and team needs. The company maintains offices in major cities globally but has invested significantly in remote infrastructure to ensure distributed teams can collaborate effectively. Remote work is viewed as a long-term commitment, not a pandemic-era temporary measure.",
      "workLocation": {
        "policy": "Employees can work from any Stripe office, their home, or co-working spaces. The company supports fully remote work for most roles, with roughly 40% of employees working remotely full-time. Office presence is optional and based on team coordination and individual preference.",
        "officeExpectation": "No mandatory office attendance requirements. Teams coordinate their own in-office days based on when face-to-face collaboration is most valuable. Some teams opt for monthly in-office weeks for planning sprints, while others meet quarterly. Individual contributors have full flexibility to work remotely 100% of the time if they choose.",
        "workFromAnywhere": "Employees must be located in countries where Stripe has legal entities (US, Canada, UK, Ireland, France, Germany, Singapore, Australia, and others). Within approved countries, employees can work from anywhere. Short-term international work travel is supported up to 90 days per year with manager approval. Digital nomad arrangements considered case-by-case for certain roles."
      },
      "equipment": {
        "budget": "$1,500 initial budget for home office setup, plus $500 annually for equipment refresh or upgrades",
        "provided": "All employees receive a MacBook Pro (or Windows laptop of choice), external monitor(s), desk accessories, keyboard, mouse, headphones, and webcam. Additional ergonomic equipment like standing desks, monitor arms, or specialized chairs can be requested through IT. Remote employees also get shipped an equipment kit with cables, adapters, and accessories.",
        "support": "24/7 IT support available via Slack and phone for all equipment issues. Next-day replacement shipping for any malfunctioning equipment. Ergonomic consultations available to optimize home office setup. Annual equipment refresh program allows upgrading devices."
      },
      "schedule": {
        "flexibility": "Fully flexible working hours with no set schedule requirements. Employees work when they're most productive, whether that's early morning, late night, or standard business hours. The only expectation is delivering results and being available during agreed-upon team overlap windows.",
        "coreHours": "Teams establish core collaboration hours based on their geographic distribution, typically 3-4 hours of overlap when most team members are expected to be available for meetings. For globally distributed teams, meeting times rotate to share the timezone burden fairly. Most teams keep core hours between 10am-2pm in their primary timezone.",
        "asynchronous": "Strong asynchronous work culture with extensive use of written documentation and recorded meetings. Default to async communication through Notion docs, detailed Slack messages, and recorded Loom videos. All meetings are recorded and shared for teammates who can't attend live. Decision-making processes are documented transparently so remote employees never feel out of the loop."
      },
      "tools": {
        "communication": "Slack for team chat and quick questions, Zoom for video meetings, Gmail for email. Guidelines encourage thoughtful channel choice: Slack for urgent, email for non-urgent, Notion for anything that needs to persist. All meetings are video-on by default to maintain connection.",
        "collaboration": "Notion for documentation and knowledge management, Figma for design collaboration, GitHub for code and technical documentation, Linear for project tracking, Miro for virtual whiteboarding. All tools integrated to enable seamless remote collaboration.",
        "socializing": "Donut bot randomly pairs employees for virtual coffee chats, monthly team trivia and game nights, dedicated Slack channels for hobbies (#cooking, #bookclub, #fitness), virtual happy hours, and async social threads for sharing life updates. Remote employees are explicitly included in all social initiatives."
      },
      "culture": {
        "inPerson": "Quarterly team offsites where distributed teams gather for 2-3 days of planning, team building, and social time. All travel and accommodation costs covered by company. Annual all-company gathering brings entire organization together for strategy sharing and celebration. Office-based teams often organize monthly social events that remote employees can join if they happen to be in town.",
        "remoteCulture": "Culture is maintained through transparent communication, strong documentation practices, and intentional inclusion of remote employees. All-hands meetings every two weeks keep everyone aligned on company direction. Internal blog shares wins, challenges, and learnings across teams. Employee resource groups help remote workers build connections beyond their immediate teams.",
        "inclusion": "Remote employees have equal access to growth opportunities with promotion rates tracked to ensure no location bias. All meetings default to video even if some participants are in office together to keep remote attendees equally engaged. Leadership makes concerted effort to highlight work from distributed teams. Remote employees report feeling equally valued and included based on internal surveys."
      },
      "sources": [
        {
          "title": "Remote Work at Stripe - Careers Page",
          "url": "https://stripe.com/careers/remote-work",
          "date": "2024-01-15",
          "type": "company-page"
        },
        {
          "title": "Stripe Employee Reviews - Remote Work",
          "url": "https://glassdoor.com/stripe-reviews-remote",
          "date": "2024-03-20",
          "type": "employee-review"
        },
        {
          "title": "How Stripe Built a Hybrid-First Culture",
          "url": "https://stripe.com/blog/hybrid-work-culture",
          "date": "2023-09-10",
          "type": "blog-post"
        }
      ]
    }
  },
  "input_variables": {
    "company_name": "{COMPANY_NAME}",
    "website": "{WEBSITE}",
    "additional_context": "{CONTEXT}"
  },
  "final_instruction": "Return ONLY the JSON structure with comprehensive, verified remote work policy information. No markdown, no explanations, no code blocks—pure JSON only."
}
