# Perks and Benefits Prompt (JSON Version)

## Task
Research and compile comprehensive information about the company's employee perks, benefits, and compensation philosophy.

## Output Format
Return **ONLY** valid JSON in the following structure. Do NOT include any markdown code fences, explanations, or additional text.

```json
{
  "type": "perks_and_benefits",
  "data": {
    "introduction": "1-2 sentences about the company's benefits philosophy and approach to employee compensation",
    "standoutBenefits": [
      {
        "icon": "💰",
        "name": "Competitive Equity",
        "description": "What makes this benefit special or unique (2-3 sentences)"
      }
    ],
    "categories": [
      {
        "icon": "🏥",
        "category": "Health & Wellness",
        "benefits": [
          {
            "name": "Premium Health Coverage",
            "description": "Description of this specific benefit",
            "highlight": true
          }
        ]
      }
    ],
    "sources": [
      {
        "title": "Source title",
        "url": "https://example.com/source",
        "date": "2024-01-15",
        "type": "company-page|article|employee-review"
      }
    ]
  }
}
```

## Guidelines

### Introduction
- 1-2 sentences summarizing the company's approach to benefits
- What's their philosophy on compensation and perks?
- Example: "Stripe offers competitive compensation including base salary, equity, and comprehensive benefits designed to support employees' financial, physical, and mental well-being. The company takes a data-driven approach to benefits, regularly surveying employees to ensure offerings meet their needs."

### Standout Benefits (3-6 benefits)

These are the most unique, generous, or impressive benefits that differentiate this company. Consider:
- Unusually generous versions of standard benefits
- Unique perks not offered elsewhere
- Benefits that reflect company values
- Benefits frequently mentioned in reviews or recruitment

For each standout benefit:

**icon** (required)
- Choose relevant emoji
- Examples: 💰 (compensation), 🏖️ (time off), 📚 (learning), 🏠 (remote), ✈️ (travel), 🍼 (family)

**name** (required)
- Concise benefit name (2-5 words)
- Example: "Unlimited PTO", "Equity for All", "Learning Budget"

**description** (required)
- 2-3 sentences explaining:
  - What exactly is offered
  - What makes it special or generous
  - How employees can use it
- Be specific with amounts, timeframes, or limits when known

### Categories (5-8 categories)

Organize all benefits into logical categories:

#### Common Categories

1. **💰 Compensation & Equity**
   - Base salary philosophy
   - Equity/stock options
   - Bonuses and profit sharing
   - Pay transparency
   - Salary bands

2. **🏥 Health & Wellness**
   - Medical, dental, vision insurance
   - Mental health support
   - Wellness programs
   - Gym memberships
   - Health stipends

3. **👪 Family & Parental**
   - Parental leave (specify weeks)
   - Adoption assistance
   - Childcare support
   - Family planning benefits
   - Eldercare support

4. **⏰ Work-Life Balance**
   - PTO policy
   - Flexible schedule
   - Remote work options
   - Sabbaticals
   - Unlimited vacation

5. **📚 Learning & Development**
   - Learning stipends ($ amount)
   - Conference attendance
   - Tuition reimbursement
   - Mentorship programs
   - Book clubs or learning groups

6. **💻 Equipment & Workspace**
   - Home office setup
   - Equipment budget ($ amount)
   - Laptop and phone
   - Co-working stipends
   - Office ergonomics

7. **🍽️ Food & Office Perks**
   - Free meals/snacks
   - Catered lunches
   - Coffee and drinks
   - Office amenities
   - Kitchen facilities

8. **✈️ Travel & Commute**
   - Commuter benefits
   - Company retreats
   - Team offsites
   - Transit passes
   - Parking

9. **💳 Financial & Retirement**
   - 401(k) matching (% amount)
   - Financial planning services
   - Life insurance
   - Disability insurance
   - HSA/FSA contributions

For each benefit in a category:

**name** (required)
- Specific benefit name
- Be clear and concise

**description** (required)
- 1-2 sentences explaining the benefit
- Include specifics (amounts, timeframes, eligibility)
- Example: "16 weeks fully paid parental leave for all parents (birth or adoption), with option to extend with partial pay"

**highlight** (optional, boolean)
- Set to `true` for particularly generous or unique benefits within the category
- Use sparingly (1-2 per category max)

## Quality Standards

✅ **DO:**
- Focus on verified benefits from official sources
- Include specific amounts and timeframes when known
- Mention benefits in employee reviews if consistent
- Note if benefits vary by location/country
- Include both standard and unique perks
- Mention if they regularly update benefits based on feedback

❌ **DON'T:**
- List every tiny perk (be selective and meaningful)
- Include speculative or rumored benefits
- Copy marketing language verbatim
- Ignore regional differences if significant
- Include benefits that are standard everywhere (e.g., "we pay salaries")
- Make unverifiable claims about generosity

## Benefit Selection Priority

Choose benefits that are:
1. **Differentiated**: More generous or unique than competitors
2. **Meaningful**: Actually valued by employees (check reviews)
3. **Verifiable**: Can be confirmed from multiple sources
4. **Current**: Updated within last 12 months

## Tone of Voice (Internal Guidance - Do NOT include in JSON output)

**IMPORTANT**: Match the company's style when describing benefits.

**For benefit descriptions:**
- If they're **employee-focused/caring** → Emphasize support and wellbeing ("Supporting your health and family...")
- If they're **data-driven/technical** → Include specific numbers and details ("$X annual budget", "Y weeks of leave")
- If they're **competitive/ambitious** → Highlight market-leading aspects ("Top 10% of industry", "Best-in-class...")

**Keep benefit details factual** but match their tone in how benefits are framed.

## Sources (3-8 sources)

**IMPORTANT**: Include citations for benefits information.

**For each source:**
- **title**: Clear description (e.g., "Company careers benefits page", "Glassdoor reviews", "Parental leave announcement")
- **url**: Full URL to the source
- **date**: Publication or last updated date (YYYY-MM-DD)
- **type**: `company-page`, `article`, `press-release`, `employee-review`, `blog-post`, `job-posting`

**What to cite:**
- Company careers page (benefits section)
- Glassdoor reviews (benefits section)
- Comparably benefits data
- Company blog posts about benefits
- Job postings (often mention key benefits)
- Press releases about new benefit announcements
- Employee handbook excerpts (if publicly available)

**Quality guidelines:**
- Prefer official company sources for benefit details
- Use employee reviews to validate and provide context
- Include press releases for major benefit announcements
- Note if benefits vary by location/country

## Example Output

```json
{
  "type": "perks_and_benefits",
  "data": {
    "introduction": "Stripe offers competitive total compensation including market-leading salaries, significant equity grants, and comprehensive benefits. The company regularly surveys employees to evolve benefits based on their needs, with a focus on flexibility and supporting employees' long-term financial and personal well-being.",
    "standoutBenefits": [
      {
        "icon": "💰",
        "name": "Generous Equity Grants",
        "description": "All employees receive meaningful equity that vests over four years, with refresher grants to maintain ownership as the company grows. Stripe's equity packages are typically in the top 10% of comparable tech companies, and the company provides regular liquidity events for employees to realize value before a potential IPO."
      },
      {
        "icon": "🏖️",
        "name": "Flexible Time Off",
        "description": "Unlimited PTO with a minimum of 20 days off per year required. The company actively encourages taking time off with managers checking in if employees aren't using vacation, plus full company shutdowns during major holidays to ensure everyone disconnects."
      },
      {
        "icon": "📚",
        "name": "$3,000 Annual Learning Budget",
        "description": "Each employee receives $3,000 annually for learning and development, usable for courses, conferences, books, coaching, or any learning investment. Unused budget doesn't expire and can roll over, encouraging long-term learning goals."
      },
      {
        "icon": "🏠",
        "name": "$1,500 Remote Setup Budget",
        "description": "All employees receive $1,500 for home office setup, plus an additional $500 annually for equipment upgrades or office improvements. Stripe also provides ergonomic consultations and will ship additional monitors, chairs, or accessories as needed."
      }
    ],
    "categories": [
      {
        "icon": "💰",
        "category": "Compensation & Equity",
        "benefits": [
          {
            "name": "Market-Leading Salaries",
            "description": "Stripe targets 75th-90th percentile of market compensation for each role based on location, with transparent salary bands shared internally and during interview process.",
            "highlight": true
          },
          {
            "name": "Equity for All",
            "description": "Every employee receives equity grants that vest over 4 years with a 1-year cliff. Refresher grants are standard to maintain ownership over time.",
            "highlight": true
          },
          {
            "name": "Liquidity Events",
            "description": "Regular tender offers allowing employees to sell vested shares before IPO, providing liquidity without waiting for public market exit."
          },
          {
            "name": "Annual Performance Bonuses",
            "description": "Performance-based annual bonuses tied to both company and individual goals, typically 10-20% of base salary for strong performers."
          }
        ]
      },
      {
        "icon": "🏥",
        "category": "Health & Wellness",
        "benefits": [
          {
            "name": "Premium Health Coverage",
            "description": "Platinum-level medical, dental, and vision insurance with 100% of premiums covered for employees and 75% for dependents. Low deductibles and copays.",
            "highlight": true
          },
          {
            "name": "Mental Health Support",
            "description": "Unlimited therapy sessions covered through dedicated mental health platform, plus mindfulness and meditation app subscriptions for all employees.",
            "highlight": true
          },
          {
            "name": "$500 Wellness Stipend",
            "description": "Annual wellness budget for gym memberships, fitness equipment, wellness apps, or health-related expenses of your choice."
          },
          {
            "name": "On-Site Wellness",
            "description": "Office locations feature on-site fitness centers, yoga classes, massage therapy, and wellness rooms for meditation or nursing."
          }
        ]
      },
      {
        "icon": "👪",
        "category": "Family & Parental",
        "benefits": [
          {
            "name": "18 Weeks Paid Parental Leave",
            "description": "18 weeks fully paid leave for all parents (birth, adoption, or foster), with option to extend with partial pay up to 6 months total.",
            "highlight": true
          },
          {
            "name": "Family Planning Support",
            "description": "Comprehensive coverage for fertility treatments, IVF, egg freezing, and adoption costs up to $50,000 lifetime."
          },
          {
            "name": "Childcare Support",
            "description": "Backup childcare services through Care.com, plus $1,000 annual stipend toward childcare expenses."
          },
          {
            "name": "Return-to-Work Program",
            "description": "Structured onboarding program for parents returning from leave, including gradual ramp-up schedule and manager coaching."
          }
        ]
      },
      {
        "icon": "⏰",
        "category": "Work-Life Balance",
        "benefits": [
          {
            "name": "Flexible Schedule",
            "description": "Work the hours that work best for you, with core collaboration hours for team alignment but flexibility around personal schedule.",
            "highlight": true
          },
          {
            "name": "Unlimited PTO (20 day minimum)",
            "description": "Take time off when you need it, with a company minimum of 20 days to ensure everyone disconnects. Managers actively encourage vacation usage."
          },
          {
            "name": "Company Shutdowns",
            "description": "Full company shutdowns during major holidays including week between Christmas and New Year's to ensure everyone can disconnect."
          },
          {
            "name": "Sabbatical Program",
            "description": "After 5 years, employees can take a paid 4-week sabbatical to recharge, travel, or pursue personal projects."
          }
        ]
      },
      {
        "icon": "📚",
        "category": "Learning & Development",
        "benefits": [
          {
            "name": "$3,000 Learning Budget",
            "description": "Annual budget for courses, certifications, conferences, books, coaching, or any learning investment. Rolls over if unused.",
            "highlight": true
          },
          {
            "name": "Conference Attendance",
            "description": "Support for attending industry conferences with covered registration, travel, and accommodation costs."
          },
          {
            "name": "Tuition Reimbursement",
            "description": "Up to $10,000 annually for degree programs or professional certifications related to your role."
          },
          {
            "name": "Internal Learning Programs",
            "description": "Stripe-developed courses on payments, engineering, product, and leadership taught by internal experts."
          },
          {
            "name": "Mentorship Program",
            "description": "Structured mentorship matching employees with senior leaders for career development and guidance."
          }
        ]
      },
      {
        "icon": "💻",
        "category": "Equipment & Workspace",
        "benefits": [
          {
            "name": "$1,500 Home Office Setup",
            "description": "One-time budget for desk, chair, monitors, and office equipment, plus $500 annually for upgrades or replacements.",
            "highlight": true
          },
          {
            "name": "Premium Equipment",
            "description": "Latest MacBook Pro (or PC of choice), external monitors, mechanical keyboard, and any tools needed to be productive."
          },
          {
            "name": "Ergonomic Support",
            "description": "Free ergonomic consultations and equipment like standing desks, ergonomic chairs, keyboard trays, and monitor arms."
          },
          {
            "name": "Co-working Stipend",
            "description": "Monthly stipend for co-working space membership if you prefer working outside home."
          }
        ]
      },
      {
        "icon": "🍽️",
        "category": "Food & Office Perks",
        "benefits": [
          {
            "name": "Free Lunch & Snacks",
            "description": "Daily catered lunches in offices, plus fully stocked kitchens with snacks, drinks, coffee, and fresh fruit."
          },
          {
            "name": "Meal Stipends (Remote)",
            "description": "$30 daily meal stipend for remote employees to use for lunch or groceries."
          },
          {
            "name": "Coffee & Tea Program",
            "description": "Premium coffee, espresso machines, and variety of teas in all office locations."
          }
        ]
      },
      {
        "icon": "✈️",
        "category": "Travel & Team Building",
        "benefits": [
          {
            "name": "Quarterly Team Offsites",
            "description": "All-expenses-paid quarterly team gatherings for remote teams, rotating locations globally for connection and collaboration.",
            "highlight": true
          },
          {
            "name": "Annual Company Retreat",
            "description": "Annual all-company retreat bringing together global team for strategy sessions, team building, and fun."
          },
          {
            "name": "Commuter Benefits",
            "description": "Pre-tax commuter benefits for transit passes, parking, or bike commuting expenses up to IRS limits."
          }
        ]
      },
      {
        "icon": "💳",
        "category": "Financial & Retirement",
        "benefits": [
          {
            "name": "401(k) with 5% Match",
            "description": "Stripe matches 100% of contributions up to 5% of salary, with immediate vesting of employer contributions.",
            "highlight": true
          },
          {
            "name": "Financial Planning Services",
            "description": "Access to certified financial planners for equity planning, tax optimization, retirement planning, and general financial advice."
          },
          {
            "name": "Life Insurance",
            "description": "Company-paid life insurance equal to 2x annual salary, with option to purchase additional coverage."
          },
          {
            "name": "Disability Insurance",
            "description": "Short-term and long-term disability coverage at 60% salary replacement, fully paid by company."
          }
        ]
      }
    ],
    "sources": [
      {
        "title": "Stripe Careers: Benefits",
        "url": "https://stripe.com/jobs/benefits",
        "date": "2024-01-15",
        "type": "company-page"
      },
      {
        "title": "Glassdoor: Stripe Benefits Reviews",
        "url": "https://www.glassdoor.com/Benefits/Stripe-US-Benefits",
        "date": "2024-01-20",
        "type": "employee-review"
      },
      {
        "title": "Stripe Blog: Expanding Parental Leave",
        "url": "https://stripe.com/blog/parental-leave-2023",
        "date": "2023-06-15",
        "type": "blog-post"
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
