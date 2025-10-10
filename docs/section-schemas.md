# Section JSON Schemas

This document defines the expected JSON structure for each profile section.

## 1. Company Description

```json
{
  "type": "company_description",
  "data": {
    "tagline": "One-line company tagline",
    "overview": "Comprehensive description (2-3 paragraphs)",
    "industry": "Industry/sector",
    "founded": "2024",
    "headquarters": "City, Country",
    "companySize": "50-200 employees",
    "website": "https://example.com",
    "keyProducts": [
      {
        "name": "Product Name",
        "description": "Brief description"
      }
    ],
    "targetMarket": "Description of target audience",
    "businessModel": "Description of revenue model"
  }
}
```

## 2. Their Story

```json
{
  "type": "their_story",
  "data": {
    "foundingYear": "2024",
    "founders": [
      {
        "name": "Founder Name",
        "background": "Brief background"
      }
    ],
    "origin": "The founding story (2-3 paragraphs)",
    "ahaмомент": "The moment that sparked the idea",
    "earlyDays": "Early challenges and milestones",
    "evolution": "How the company evolved",
    "milestones": [
      {
        "year": "2024",
        "title": "Milestone title",
        "description": "What happened"
      }
    ]
  }
}
```

## 3. Company Values

```json
{
  "type": "company_values",
  "data": {
    "introduction": "Brief intro about company culture",
    "values": [
      {
        "icon": "🎯",
        "title": "Value Name",
        "tagline": "One-line summary",
        "description": "Detailed explanation (2-3 paragraphs)",
        "examples": [
          "Concrete example of this value in action"
        ]
      }
    ]
  }
}
```

## 4. Key Numbers

```json
{
  "type": "key_numbers",
  "data": {
    "metrics": [
      {
        "value": "€204M",
        "label": "Annual Revenue",
        "context": "74% YoY growth",
        "icon": "💰"
      },
      {
        "value": "500K+",
        "label": "Customers",
        "context": "Across Europe",
        "icon": "👥"
      }
    ],
    "context": "Additional context about these numbers",
    "lastUpdated": "Q4 2024"
  }
}
```

## 5. Funding

```json
{
  "type": "funding_parser",
  "data": {
    "totalRaised": {
      "amount": "$1.16B",
      "currency": "USD"
    },
    "valuation": {
      "amount": "$5.4B",
      "currency": "USD",
      "date": "2022-01"
    },
    "status": "Private",
    "rounds": [
      {
        "series": "Series D",
        "date": "2022-01",
        "amount": "$552M",
        "valuation": "$5.4B",
        "leadInvestors": ["TCV", "Tiger Global"],
        "otherInvestors": ["Tencent", "Valar"],
        "description": "Purpose and outcome of this round"
      }
    ],
    "keyInvestors": [
      {
        "name": "TCV",
        "type": "VC Firm",
        "description": "Leading growth equity firm"
      }
    ]
  }
}
```

## 6. Leadership

```json
{
  "type": "leadership",
  "data": {
    "introduction": "Brief overview of leadership team",
    "leaders": [
      {
        "name": "Full Name",
        "title": "CEO & Co-Founder",
        "avatar": "initials or photo URL",
        "tenure": "8+ years",
        "background": "Previous experience and education",
        "achievements": [
          "Key accomplishment"
        ],
        "quote": "Optional inspiring quote",
        "linkedin": "https://linkedin.com/in/..."
      }
    ],
    "boardMembers": [
      {
        "name": "Board Member Name",
        "role": "Board Observer",
        "affiliation": "Company/Fund they represent"
      }
    ]
  }
}
```

## 7. Office Locations

```json
{
  "type": "office_locations",
  "data": {
    "headquarters": {
      "city": "Paris",
      "country": "France",
      "address": "18 Rue de Londres, 75009",
      "type": "HQ",
      "size": "500+ people",
      "description": "Main headquarters and engineering hub"
    },
    "offices": [
      {
        "city": "Berlin",
        "country": "Germany",
        "address": "Friedrichstraße 76, 10117",
        "type": "Regional Office",
        "size": "100+ people",
        "description": "German market operations"
      }
    ],
    "remotePresence": "Description of remote work setup"
  }
}
```

## 8. Perks and Benefits

```json
{
  "type": "perks_and_benefits",
  "data": {
    "introduction": "Overview of benefits philosophy",
    "categories": [
      {
        "icon": "💼",
        "title": "Health & Insurance",
        "benefits": [
          {
            "name": "Health Insurance",
            "description": "Comprehensive coverage with premium employer contribution",
            "highlight": true
          }
        ]
      },
      {
        "icon": "🏠",
        "title": "Work Flexibility",
        "benefits": [
          {
            "name": "Hybrid Work",
            "description": "3 days remote per week",
            "highlight": false
          }
        ]
      }
    ],
    "standoutBenefits": [
      {
        "title": "€1,000 Learning Budget",
        "description": "Annual budget per employee for conferences and training",
        "icon": "📚"
      }
    ]
  }
}
```

## 9. Remote Policy

```json
{
  "type": "remote_policy",
  "data": {
    "model": "Hybrid",
    "summary": "Brief 1-2 sentence summary",
    "workLocation": {
      "officeRequired": "3 days per week",
      "remoteAllowed": "2 days per week",
      "locations": ["France", "Germany", "Italy", "Spain"],
      "workFromAnywhere": {
        "allowed": true,
        "duration": "6 weeks per year",
        "restrictions": "Tax and legal considerations apply"
      }
    },
    "equipment": {
      "provided": ["MacBook Pro", "Monitor", "Accessories"],
      "homeOfficeStipend": "€1,000 one-time setup budget"
    },
    "schedule": {
      "flexibility": "Flexible hours with core collaboration time",
      "timezone": "European timezone (CET/CEST)",
      "coreHours": "10:00-16:00 CET"
    },
    "tools": [
      {
        "category": "Communication",
        "tools": ["Slack", "Zoom", "Google Meet"]
      }
    ],
    "culture": {
      "philosophy": "Best of both worlds approach",
      "teamEvents": "Quarterly offsites and regular team building",
      "onboarding": "First 2 weeks in office for new hires"
    }
  }
}
```

## Schema Validation

Each section should include:
- `type`: Section identifier (matches prompt file name)
- `data`: Section-specific structured data
- Optional: `meta` object with `lastUpdated`, `sources`, `confidence` scores

## General Guidelines

1. **Keep it structured**: Avoid large text blocks; break into logical pieces
2. **Use arrays**: For repeating elements (values, benefits, locations)
3. **Include icons**: Use emojis for visual appeal
4. **Add context**: Include additional information that helps understanding
5. **Be consistent**: Use similar patterns across sections
6. **Think responsive**: Structure should work on mobile and desktop
