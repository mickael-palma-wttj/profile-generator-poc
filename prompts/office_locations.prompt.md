Find all office locations for [COMPANY_NAME].

Search their website and major business directories. For each location provide:
- Complete address
- Office type (HQ, branch, regional office, etc.)
- Any notable details about the location

**OUTPUT FORMAT:**

Return **ONLY HTML** - no markdown, no explanations, no code fences.

Structure the content as:
```html
<div class="locations-grid">
  <div class="location-card">
    <h3>🏢 [City, Country]</h3>
    <p class="location-type">[Headquarters / Regional Office / Branch Office]</p>
    <p>[Street Address]</p>
    <p>[City, State/Province, Postal Code]</p>
    <p>[Country]</p>
    <p class="location-note">[Optional: Notable details about this location]</p>
  </div>
  <!-- Repeat for each location -->
</div>
```

**Requirements:**
- Wrap all content in `<div class="locations-grid">`
- Each location in `<div class="location-card">`
- City/country in `<h3>` with an emoji (🏢 for HQ, 🏛️ for major offices, 📍 for branches)
- Office type in `<p class="location-type">`
- Address details in separate `<p>` tags
- Optional notes in `<p class="location-note">`
- List HQ first, then major offices, then regional offices

**Example Output:**
```html
<div class="locations-grid">
  <div class="location-card">
    <h3>🏢 San Francisco, United States</h3>
    <p class="location-type">Global Headquarters</p>
    <p>510 Townsend Street</p>
    <p>San Francisco, CA 94103</p>
    <p>United States</p>
    <p class="location-note">Main engineering and product hub</p>
  </div>
  
  <div class="location-card">
    <h3>🏛️ Dublin, Ireland</h3>
    <p class="location-type">European Headquarters</p>
    <p>1 Grand Canal Street Lower</p>
    <p>Dublin, D02 H210</p>
    <p>Ireland</p>
  </div>
</div>
```