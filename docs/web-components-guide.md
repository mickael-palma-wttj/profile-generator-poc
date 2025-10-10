# Web Components Implementation Guide

## Overview

This document explains how to integrate the new web component architecture into the profile generator.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    AI (Claude)                          │
│              Returns Structured JSON                     │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│              Content Formatter                           │
│         Detects JSON vs HTML vs Markdown                │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│            Component Registry                            │
│      Maps section types to web components               │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│           Web Component Renderer                         │
│    <company-values-section data="{...}">                │
└─────────────────────────────────────────────────────────┘
```

## Step 1: Update Content Formatter

Modify `lib/profile_generator/services/content_formatter.rb`:

```ruby
def format(content)
  return "" if content.nil? || content.strip.empty?

  # Try to detect and parse JSON first
  if looks_like_json?(content)
    format_as_component(content)
  elsif html?(content)
    strip_code_fences(content)
  else
    format_markdown(content)
  end
end

private

def format_as_component(json_content)
  begin
    data = JSON.parse(json_content)
    section_type = data['type']
    component_name = component_name_for_type(section_type)
    
    # Return web component HTML
    %(<#{component_name} data='#{json_content.gsub("'", "&apos;")}'></#{component_name}>)
  rescue JSON::ParserError => e
    # Fall back to treating as regular content
    format_markdown(json_content)
  end
end

def component_name_for_type(type)
  case type
  when 'company_description'
    'company-description-section'
  when 'their_story'
    'their-story-section'
  when 'company_values'
    'company-values-section'
  when 'key_numbers'
    'key-numbers-section'
  when 'funding_parser'
    'funding-section'
  when 'leadership'
    'leadership-section'
  when 'office_locations'
    'office-locations-section'
  when 'perks_and_benefits'
    'perks-benefits-section'
  when 'remote_policy'
    'remote-policy-section'
  else
    'generic-section'
  end
end

def looks_like_json?(content)
  stripped = content.strip
  (stripped.start_with?("{") && stripped.end_with?("}")) &&
    stripped.include?('"type":')
end

def html?(content)
  content.strip.start_with?("<") && content.include?(">")
end
```

## Step 2: Update HTML Templates

Add component scripts to `app/views/index.erb` and `profile.erb`:

```erb
<head>
  <!-- Existing head content -->
  <link rel="stylesheet" href="/styles.css">
  <link rel="stylesheet" href="/components.css">
</head>
<body>
  <!-- Existing body content -->
  
  <script src="/components.js"></script>
  <script src="/app.js"></script>
</body>
```

## Step 3: Create Remaining Components

Complete the web components for all section types:

### Funding Component
```javascript
class FundingSection extends ProfileSectionComponent {
    render() {
        const { totalRaised, valuation, status, rounds, keyInvestors } = this.data;
        // Implementation similar to existing components
    }
}
customElements.define('funding-section', FundingSection);
```

### Leadership Component
```javascript
class LeadershipSection extends ProfileSectionComponent {
    render() {
        const { introduction, leaders, boardMembers } = this.data;
        // Grid of leader cards with avatars
    }
}
customElements.define('leadership-section', LeadershipSection);
```

### Office Locations Component
```javascript
class OfficeLocationsSection extends ProfileSectionComponent {
    render() {
        const { headquarters, offices, remotePresence } = this.data;
        // Map-style visualization
    }
}
customElements.define('office-locations-section', OfficeLocationsSection);
```

### Perks & Benefits Component
```javascript
class PerksBenefitsSection extends ProfileSectionComponent {
    render() {
        const { introduction, categories, standoutBenefits } = this.data;
        // Categorized benefits with highlights
    }
}
customElements.define('perks-benefits-section', PerksBenefitsSection);
```

### Remote Policy Component
```javascript
class RemotePolicySection extends ProfileSectionComponent {
    render() {
        const { model, summary, workLocation, equipment, schedule, tools, culture } = this.data;
        // Structured policy information
    }
}
customElements.define('remote-policy-section', RemotePolicySection);
```

## Step 4: Update AI Prompts

For each section, create a corresponding `*_json.prompt.md` file:

1. Copy the section's current prompt
2. Replace output instructions to return JSON
3. Define the exact JSON structure expected
4. Include examples of good vs bad output
5. Emphasize returning ONLY JSON (no markdown fences)

Example structure:
```markdown
# [Section Name] Prompt (JSON Version)

## Task
[What to research and generate]

## Output Format
Return **ONLY** valid JSON. No code fences, no explanations.

{
  "type": "section_type",
  "data": {
    // Structure here
  }
}

## Guidelines
[Detailed instructions]

## Company Context
Company Name: {COMPANY_NAME}
Website: {WEBSITE}

## Output
Return ONLY the JSON structure.
```

## Step 5: Gradual Migration Strategy

### Phase 1: Parallel Mode (Current)
- Keep existing HTML generation
- Add JSON prompts alongside HTML prompts
- Content formatter handles both

### Phase 2: JSON-First
- Update one section at a time to use JSON
- Test thoroughly before moving to next
- Recommended order:
  1. Key Numbers (simplest)
  2. Company Values (well-structured)
  3. Their Story (narrative heavy)
  4. Company Description
  5. Leadership
  6. Office Locations
  7. Perks & Benefits
  8. Remote Policy
  9. Funding (most complex)

### Phase 3: JSON-Only
- Remove HTML prompts
- Remove HTML-specific code from formatter
- All sections use components

## Step 6: Testing

### Unit Tests for Components

```javascript
// tests/components.test.js
describe('CompanyValuesSection', () => {
    it('renders values grid', () => {
        const component = document.createElement('company-values-section');
        component.setAttribute('data', JSON.stringify({
            introduction: "Test intro",
            values: [
                {
                    icon: "🎯",
                    title: "Focus",
                    tagline: "Stay focused",
                    description: "We focus on what matters",
                    examples: ["Example 1"]
                }
            ]
        }));
        
        document.body.appendChild(component);
        
        expect(component.querySelector('.values-grid')).toBeDefined();
        expect(component.querySelector('.value-card')).toBeDefined();
    });
});
```

### Integration Tests

```ruby
# test/services/content_formatter_test.rb
class ContentFormatterTest < Minitest::Test
  def test_formats_json_as_component
    json_content = {
      type: 'company_values',
      data: { introduction: 'Test', values: [] }
    }.to_json
    
    formatter = ProfileGenerator::Services::ContentFormatter.new
    result = formatter.format(json_content)
    
    assert_includes result, '<company-values-section'
    assert_includes result, 'data='
  end
end
```

## Step 7: Benefits

### For Developers
- ✅ Separation of concerns (data vs presentation)
- ✅ Reusable components
- ✅ Easier to test
- ✅ Type-safe data structures
- ✅ No HTML injection concerns

### For AI Prompts
- ✅ More reliable output (structured data)
- ✅ Easier to validate
- ✅ Less prone to HTML escaping issues
- ✅ Can enforce required fields
- ✅ Better error handling

### For Users
- ✅ Consistent design across sections
- ✅ Better responsive design
- ✅ Faster rendering
- ✅ More interactive possibilities (sort, filter, etc.)

## Step 8: Future Enhancements

Once components are stable:

1. **Interactive Features**
   - Filter/search within sections
   - Expand/collapse subsections
   - Copy individual metrics
   - Print individual sections

2. **Data Visualization**
   - Charts for key numbers
   - Timeline visualization for funding
   - Interactive org chart for leadership
   - Map for office locations

3. **Comparison Mode**
   - Compare two companies side-by-side
   - Highlight differences
   - Export comparison

4. **Export Options**
   - PDF with proper formatting
   - Markdown with structured data
   - JSON API endpoint
   - CSV for metrics

## Resources

- [MDN Web Components](https://developer.mozilla.org/en-US/docs/Web/Web_Components)
- [Custom Elements Spec](https://html.spec.whatwg.org/multipage/custom-elements.html)
- [JSON Schema](https://json-schema.org/)
- Schema Definitions: `docs/section-schemas.md`
- Component Styles: `public/components.css`
- Component Code: `public/components.js`

## Support

For questions or issues with the component system:
1. Check `docs/section-schemas.md` for data structures
2. Review existing component implementations
3. Test with sample JSON data
4. Use browser DevTools to inspect component rendering
