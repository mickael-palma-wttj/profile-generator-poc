# Remote Policy Prompt (JSON Version)

## Task
Research and provide comprehensive information about the company's remote work policies, flexibility, and distributed work culture.

## Output Format
Return **ONLY** valid JSON in the following structure. Do NOT include any markdown code fences, explanations, or additional text.

```json
{
  "type": "remote_policy",
  "data": {
    "model": "Hybrid-Flexible",
    "summary": "2-3 sentence overview of the company's approach to remote work",
    "workLocation": {
      "policy": "Description of where employees can work from (1-2 sentences)",
      "officeExpectation": "Description of office attendance expectations, if any",
      "workFromAnywhere": "Description of work-from-anywhere policies or geographic restrictions"
    },
    "equipment": {
      "budget": "Budget amount for home office setup",
      "provided": "List of equipment provided by company",
      "support": "Description of ongoing equipment support"
    },
    "schedule": {
      "flexibility": "Description of schedule flexibility",
      "coreHours": "Core collaboration hours or time zone considerations",
      "asynchronous": "Description of async work practices"
    },
    "tools": {
      "communication": "Tools used for team communication",
      "collaboration": "Tools for collaboration and project management",
      "socializing": "Tools or practices for virtual team bonding"
    },
    "culture": {
      "inPerson": "Description of in-person gatherings and frequency",
      "remoteCulture": "How the company maintains culture remotely",
      "inclusion": "How remote employees are included in company culture"
    }
  }
}
```

## Guidelines

### Model (required)
Choose one category that best describes the overall policy:
- **"Office-First"** - Primarily in-office with limited remote options
- **"Hybrid-Required"** - Mix of office and remote with set requirements
- **"Hybrid-Flexible"** - Mix of office and remote, employee choice
- **"Remote-First"** - Default remote with optional office access
- **"Fully Remote"** - No physical offices, entirely distributed

### Summary (required)
2-3 sentences that capture the essence of their remote work philosophy:
- What's their overall stance on remote work?
- What flexibility do employees have?
- What's the reasoning behind their approach?

Example: "Stripe operates a hybrid-flexible model where employees can choose to work from offices, fully remotely, or a mix of both. The company maintains offices in major tech hubs but has invested heavily in remote infrastructure to support distributed collaboration. Teams gather in person quarterly for planning and team building, but day-to-day work is optimized for flexibility."

### Work Location

**policy** (required)
- Where can employees work from?
- Example: "Employees can work from any Stripe office, their home, or co-working spaces. Remote work is supported globally with teams distributed across North America, Europe, and parts of Asia."

**officeExpectation** (required)
- Is office attendance required?
- How often are people expected in office?
- Example: "No mandatory office attendance, though teams coordinate regular in-person days. Some teams opt for weekly or monthly in-office days for collaboration."

**workFromAnywhere** (required)
- Can employees work from anywhere in the world?
- Any geographic restrictions?
- Example: "Employees must be located in countries where Stripe has legal entities for employment. Within those countries, work from anywhere is supported. International travel for remote work up to 90 days per year is allowed with approval."

### Equipment

**budget** (required)
- How much budget for home office setup?
- Example: "$1,500 initial setup budget plus $500 annually for replacements"

**provided** (required)
- What equipment does company provide?
- Example: "MacBook Pro or PC of choice, external monitors, keyboard, mouse, headphones, and webcam. Additional equipment like monitor arms or desk accessories available on request."

**support** (required)
- Ongoing IT support for remote workers?
- Example: "24/7 IT support via Slack or phone. Equipment repair or replacement shipped next-day. Ergonomic consultations available for home office optimization."

### Schedule

**flexibility** (required)
- How flexible are working hours?
- Example: "Fully flexible schedule with no set hours. Employees work when they're most productive, with core collaboration windows for team sync."

**coreHours** (required)
- Any required meeting windows or core hours?
- Time zone considerations?
- Example: "Teams establish core overlap hours based on their distribution, typically 10am-2pm in their primary time zone. Global teams rotate meeting times to share timezone burden."

**asynchronous** (required)
- How does company handle async work?
- Example: "Strong async culture with detailed written documentation and recorded meetings. Default to async communication via Notion and Slack, with synchronous meetings reserved for brainstorming or complex discussions."

### Tools

**communication** (required)
- What tools for chat, email, video?
- Example: "Slack for instant messaging, Zoom for video calls, Gmail for email. Company encourages thoughtful use of communication channels based on urgency."

**collaboration** (required)
- Tools for project management and collaboration?
- Example: "Notion for documentation, Figma for design, GitHub for code, Linear for task management. All meetings recorded and shared for async viewing."

**socializing** (required)
- How do remote teams socialize?
- Example: "Virtual coffee chats through Donut, monthly team trivia nights, Slack channels for hobbies and interests, and quarterly in-person team gatherings."

### Culture

**inPerson** (required)
- How often do people gather in person?
- Example: "Quarterly team offsites for planning and bonding, optional monthly office days, and annual all-company gathering. Travel and accommodation fully covered."

**remoteCulture** (required)
- How is culture maintained remotely?
- Example: "Strong documentation culture ensures information is accessible to all. Regular all-hands meetings, transparent internal communications, and intentional virtual social events keep remote employees connected."

**inclusion** (required)
- How are remote employees included?
- Example: "Remote employees have equal access to growth opportunities and leadership visibility. All meetings are video-first even if some attendees are in office. Company tracks promotion rates to ensure remote employees aren't disadvantaged."

## Quality Standards

✅ **DO:**
- Be specific about policies (not vague "we support flexibility")
- Include both official policy and actual practice
- Note if policies differ by role or team
- Mention if policy has changed recently
- Include geographic limitations clearly
- Explain the "why" behind policies when known

❌ **DON'T:**
- Copy marketing language about "flexible culture"
- Ignore negative aspects mentioned in reviews
- Assume flexibility means no structure
- Confuse "work from anywhere" with "hire from anywhere"
- Oversell remote culture if reviews suggest issues
- List every communication tool (focus on primary ones)

## Remote Work Models Explained

**Office-First**
- Default expectation is office presence
- Remote work by exception or limited days
- Example: "In office 5 days/week with 1-2 remote days allowed"

**Hybrid-Required**
- Set hybrid schedule (e.g., 3 days office, 2 remote)
- Specific days may be required
- Example: "Tuesday, Wednesday, Thursday in office"

**Hybrid-Flexible**
- Employees choose mix of office/remote
- No set schedule
- Example: "Come to office as needed for your work"

**Remote-First**
- Optimized for distributed work
- Offices available but optional
- Example: "50%+ employees fully remote"

**Fully Remote**
- No permanent offices
- All employees distributed
- Example: "Entire company is remote with co-working stipends"

## Research Sources

1. Company careers page (often has remote work section)
2. Job postings (note if "remote" or "hybrid")
3. Glassdoor reviews (search "remote" or "work from home")
4. Blind discussions about company remote culture
5. Company blog posts about remote work philosophy
6. Press releases about office changes or remote policies
7. LinkedIn posts from leadership about remote work
8. Employee interviews and testimonials

## Example Output

```json
{
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
    }
  }
}
```

## Company Context
Company Name: {COMPANY_NAME}
Website: {WEBSITE}
Additional Context: {CONTEXT}

## Output
Return ONLY the JSON structure. No explanations, no markdown formatting, no code blocks—just pure JSON.
