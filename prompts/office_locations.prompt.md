{
  "role": "office_locations_researcher",
  "task": "Research and compile information about company office locations, headquarters, and physical presence with geographic coordinates",
  "critical_requirement": "MUST include latitude and longitude coordinates for ALL locations - this is mandatory for map visualization",
  "output_format": {
    "type": "json_only",
    "structure": {
      "type": "office_locations",
      "data": {
        "headquarters": {
          "city": "string",
          "country": "string",
          "address": "string",
          "latitude": "number (REQUIRED)",
          "longitude": "number (REQUIRED)",
          "size": "string (optional)",
          "description": "string (1-2 sentences)",
          "image": "string (URL, optional)"
        },
        "offices": [
          {
            "city": "string",
            "country": "string",
            "type": "string",
            "address": "string (optional)",
            "latitude": "number (REQUIRED)",
            "longitude": "number (REQUIRED)",
            "size": "string (optional)",
            "description": "string (1-2 sentences)",
            "image": "string (URL, optional)"
          }
        ],
        "sources": [
          {
            "title": "string",
            "url": "string",
            "date": "YYYY-MM-DD",
            "type": "company-page|article|press-release|real-estate|blog-post"
          }
        ]
      }
    },
    "constraints": [
      "Return ONLY valid JSON",
      "NO markdown code fences",
      "NO explanatory text outside JSON",
      "NO comments in JSON",
      "EVERY location MUST have latitude and longitude"
    ]
  },
  "coordinate_requirements": {
    "criticality": "MANDATORY - Without coordinates, maps will not display",
    "scope": "ALL locations (headquarters and every office) must have coordinates",
    "format": {
      "latitude": {
        "type": "decimal number",
        "precision": "up to 4 decimal places",
        "range": "-90 to +90",
        "example": 37.7749
      },
      "longitude": {
        "type": "decimal number",
        "precision": "up to 4 decimal places",
        "range": "-180 to +180",
        "example": -122.4194
      }
    },
    "how_to_find": [
      "1. Search the address on Google Maps",
      "2. Right-click on the map marker or location",
      "3. Click 'Copy coordinates' or view coordinates in the URL/info panel",
      "4. Format: latitude, longitude (e.g., 48.8566, 2.3522)",
      "5. Verify coordinates point to the correct location"
    ],
    "examples": {
      "San Francisco": {"latitude": 37.7749, "longitude": -122.4194},
      "London": {"latitude": 51.5074, "longitude": -0.1278},
      "Paris": {"latitude": 48.8566, "longitude": 2.3522},
      "Tokyo": {"latitude": 35.6762, "longitude": 139.6503},
      "Singapore": {"latitude": 1.3521, "longitude": 103.8198},
      "Sydney": {"latitude": -33.8688, "longitude": 151.2093}
    },
    "validation": [
      "Verify coordinates are decimal numbers, not degrees/minutes/seconds",
      "Ensure latitude is between -90 and +90",
      "Ensure longitude is between -180 and +180",
      "Check coordinates point to correct city/country",
      "Do NOT include locations without coordinates"
    ],
    "if_coordinates_unavailable": "Do NOT include that location in the output - coordinates are mandatory"
  },
  "content_guidelines": {
    "headquarters": {
      "requirement": "required",
      "fields": {
        "city": {
          "requirement": "required",
          "format": "City name",
          "examples": ["San Francisco", "London", "Singapore", "Berlin"]
        },
        "country": {
          "requirement": "required",
          "purpose": "International clarity",
          "format": "Full country name",
          "examples": ["United States", "United Kingdom", "Singapore", "Germany"]
        },
        "address": {
          "requirement": "required",
          "format": "Street Address, City, State/Province ZIP, Country",
          "source": "Use official address from company website or press releases",
          "example": "510 Townsend Street, San Francisco, CA 94103, United States"
        },
        "latitude": {
          "requirement": "REQUIRED - MANDATORY",
          "format": "Decimal number with up to 4 decimal places",
          "example": 37.7749
        },
        "longitude": {
          "requirement": "REQUIRED - MANDATORY",
          "format": "Decimal number with up to 4 decimal places",
          "example": -122.4194
        },
        "size": {
          "requirement": "optional",
          "format": "Include unit (sq ft, sq m, m²)",
          "condition": "Only include if publicly disclosed",
          "examples": ["185,000 sq ft", "15,000 sq m", "50,000 m²"]
        },
        "image": {
          "requirement": "optional",
          "format": "URL to professional photo",
          "condition": "Include if publicly available, omit field if not"
        },
        "description": {
          "requirement": "required",
          "length": "1-2 sentences",
          "what_to_include": [
            "What's notable about this location",
            "What functions are based here",
            "Special features or design elements",
            "Why this city was chosen",
            "Team size if known"
          ],
          "example": "The headquarters houses engineering, product, and executive teams in a renovated warehouse space in San Francisco's SOMA district. The location provides access to top technical talent and proximity to key partners."
        }
      }
    },
    "offices": {
      "instruction": "List all significant office locations",
      "selection_priority": [
        "Regional headquarters",
        "Engineering hubs",
        "Major sales offices",
        "Customer support centers",
        "R&D centers"
      ],
      "ordering": "List in order of importance (HQ first, then by size/significance)",
      "fields": {
        "city": {
          "requirement": "required",
          "format": "City name"
        },
        "country": {
          "requirement": "required",
          "format": "Full country name"
        },
        "type": {
          "requirement": "required",
          "options": [
            "Regional HQ",
            "Regional HQ - EMEA",
            "Regional HQ - APAC",
            "Regional HQ - Americas",
            "Engineering Hub",
            "Sales Office",
            "Support Center",
            "R&D Center",
            "Satellite Office"
          ],
          "descriptions": {
            "Regional HQ": "Main office for a geographic region",
            "Engineering Hub": "Significant engineering/product development presence",
            "Sales Office": "Primarily focused on sales and business development",
            "Support Center": "Customer support and success teams",
            "R&D Center": "Research and development focused",
            "Satellite Office": "Smaller presence, often sales or specific team"
          }
        },
        "address": {
          "requirement": "optional",
          "condition": "Include if publicly available, can omit if not disclosed"
        },
        "latitude": {
          "requirement": "REQUIRED - MANDATORY",
          "format": "Decimal number with up to 4 decimal places"
        },
        "longitude": {
          "requirement": "REQUIRED - MANDATORY",
          "format": "Decimal number with up to 4 decimal places"
        },
        "size": {
          "requirement": "optional",
          "condition": "Include if publicly disclosed"
        },
        "image": {
          "requirement": "optional",
          "format": "URL to professional photo",
          "condition": "Include if publicly available, omit field if not"
        },
        "description": {
          "requirement": "required",
          "length": "1-2 sentences",
          "what_to_include": [
            "Primary functions at this location",
            "Size of team (if known)",
            "Strategic importance of location",
            "When it was established (if notable)",
            "Key focus areas or specializations"
          ]
        }
      }
    },
    "sources": {
      "count": "2-8 citations",
      "requirements": [
        "Cite official announcements for new office openings",
        "Use company careers page for current office list",
        "Include press releases for major expansions",
        "Verify addresses from official company sources"
      ],
      "what_to_cite": [
        "Company's careers page (often lists office locations)",
        "Press releases announcing new offices or expansions",
        "Real estate news about office leases",
        "Company blog posts about office openings",
        "Local business news when offices open",
        "LinkedIn for team size estimates (optional)"
      ],
      "fields": {
        "title": {
          "description": "Clear description of source",
          "examples": [
            "Company careers page",
            "New York office opening announcement",
            "Real estate news: Stripe leases Dublin space",
            "Blog post: Our new London office"
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
            "press-release",
            "real-estate",
            "blog-post",
            "news"
          ]
        }
      }
    }
  },
  "tone_matching": {
    "instruction": "Match company's style when describing office locations",
    "application": {
      "addresses_facts": "Keep objective and accurate",
      "descriptions": "Match their narrative style and emphasis"
    },
    "style_adaptations": {
      "bold_ambitious": "Emphasize strategic importance ('Hub for expanding into...', 'Center of innovation for...', 'Strategic foothold in...')",
      "technical_practical": "Focus on functions and teams ('Houses 300 engineers working on...', 'Dedicated to infrastructure development...', 'Supports regional API operations...')",
      "culture_focused": "Highlight workspace design and collaboration ('Designed to foster collaboration...', 'Features open spaces for team interaction...', 'Built to support creative problem-solving...')",
      "growth_oriented": "Emphasize expansion and scale ('Rapidly growing team of...', 'Expanding to accommodate...', 'Doubling headcount to...')"
    },
    "note": "Match tone in descriptions, but DO NOT include tone analysis in JSON output"
  },
  "quality_standards": {
    "do": [
      "ALWAYS include latitude and longitude for every location (most critical)",
      "Verify addresses from official company sources",
      "List offices in order of importance (HQ first, then by size/significance)",
      "Include both established presence and recent expansions",
      "Note if office is new or recently expanded",
      "Mention if location is in notable building or district",
      "Include team size if publicly disclosed",
      "Use Google Maps to verify coordinates are correct",
      "Double-check coordinate format (decimal, not degrees/minutes/seconds)",
      "Verify each coordinate points to the correct city/country"
    ],
    "dont": [
      "Include locations without coordinates - this breaks the maps feature",
      "Include every small satellite office or co-working space",
      "Use outdated addresses (check if they've moved)",
      "Speculate about future office plans unless officially announced",
      "Include offices that have been closed",
      "List cities where they only have remote workers (that's remote presence)",
      "Include vendor or partner offices",
      "Use coordinates in degrees/minutes/seconds format",
      "Include locations you cannot verify"
    ]
  },
  "research_process": {
    "steps": [
      "1. Check company careers/locations page for official office list",
      "2. Verify addresses from company website or press releases",
      "3. Find coordinates for each location using Google Maps",
      "4. Research when offices were opened (press releases, news)",
      "5. Identify office types and primary functions",
      "6. Look for team size information (LinkedIn, press releases)",
      "7. Research remote work policy from careers page or company blog",
      "8. Verify all coordinates are correct before finalizing",
      "9. Cross-reference office list across multiple sources"
    ],
    "coordinate_verification": [
      "Search exact address on Google Maps",
      "Right-click on the location marker",
      "Copy coordinates (ensure decimal format)",
      "Verify coordinates point to correct location",
      "Check latitude is between -90 and +90",
      "Check longitude is between -180 and +180",
      "If uncertain, use city center coordinates as fallback"
    ]
  },
  "example": {
    "type": "office_locations",
    "data": {
      "headquarters": {
        "city": "San Francisco",
        "country": "United States",
        "address": "510 Townsend Street, San Francisco, CA 94103",
        "latitude": 37.7749,
        "longitude": -122.4194,
        "size": "185,000 sq ft",
        "description": "Stripe's headquarters occupies a renovated warehouse in San Francisco's SOMA district, housing over 1,000 employees across engineering, product, design, and executive teams. The space features an open floor plan designed to foster collaboration and includes a demo theater for product showcases."
      },
      "offices": [
        {
          "city": "Dublin",
          "country": "Ireland",
          "type": "Regional HQ - EMEA",
          "address": "1 Grand Canal Street Lower, Dublin 2, Ireland",
          "latitude": 53.3494,
          "longitude": -6.2601,
          "size": "50,000 sq ft",
          "description": "Stripe's European headquarters serves as the hub for EMEA operations, including engineering, sales, and customer support teams. Dublin was chosen for its tech talent pool and favorable business environment for serving European customers."
        },
        {
          "city": "Singapore",
          "country": "Singapore",
          "type": "Regional HQ - APAC",
          "latitude": 1.2773,
          "longitude": 103.8507,
          "size": "40,000 sq ft",
          "description": "The APAC headquarters leads Stripe's expansion across Asia-Pacific markets with teams focused on regional partnerships, localization, and regulatory compliance. Opened in 2017 to serve growing demand from Asian businesses."
        },
        {
          "city": "London",
          "country": "United Kingdom",
          "type": "Engineering Hub",
          "latitude": 51.5074,
          "longitude": -0.1278,
          "description": "Stripe's second-largest office outside the US, housing engineering, product, and sales teams. Critical hub for serving UK and European markets with dedicated teams for local payment methods and financial regulations."
        }
      ],
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
        }
      ]
    }
  },
  "input_variables": {
    "company_name": "{COMPANY_NAME}",
    "website": "{WEBSITE}",
    "additional_context": "{CONTEXT}"
  },
  "final_instruction": "Return ONLY the JSON structure with ALL locations including mandatory latitude and longitude coordinates. No markdown, no explanations, no code blocks—pure JSON only. CRITICAL: Every location MUST have coordinates or it should not be included."
}
