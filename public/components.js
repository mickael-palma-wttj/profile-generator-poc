/**
 * Profile Section Web Components
 * Custom elements for rendering structured profile sections
 * 
 * @file components.js
 * @version 2.0.0 - Refactored for better maintainability
 */

(function () {
    'use strict';

    // ============================================================================
    // Constants
    // ============================================================================

    const DEFAULT_ICONS = {
        industry: '🏭',
        founded: '📅',
        headquarters: '🏢',
        size: '👥',
        website: '🌐',
        value: '💎',
        ahaMoment: '💡'
    };

    // ============================================================================
    // Leaflet Library Loader
    // ============================================================================

    /**
     * Wait for Leaflet library to be available
     * Returns a promise that resolves when window.L is defined
     */
    function waitForLeaflet(maxAttempts = 200, delayMs = 50) {
        return new Promise((resolve, reject) => {
            // If already loaded, resolve immediately
            if (window.L) {
                console.log(`[Leaflet] Library already available`);
                resolve(window.L);
                return;
            }

            let attempts = 0;
            console.log(`[Leaflet] Starting wait for Leaflet library (max ${maxAttempts} attempts = ${(maxAttempts * delayMs / 1000).toFixed(1)}s)`);

            function checkLeaflet() {
                if (window.L) {
                    console.log(`[Leaflet] ✅ Library loaded successfully after ${attempts} attempts (${attempts * delayMs}ms)`);
                    resolve(window.L);
                    return;
                }

                attempts++;
                if (attempts % 20 === 0) {
                    console.log(`[Leaflet] Still waiting... ${attempts}/${maxAttempts} attempts`);
                }

                if (attempts > maxAttempts) {
                    console.error(`[Leaflet] ❌ Failed to load after ${maxAttempts} attempts (${(maxAttempts * delayMs / 1000).toFixed(1)}s)`);
                    console.error(`[Leaflet] window.L is:`, window.L);
                    console.error(`[Leaflet] Leaflet global is:`, typeof Leaflet !== 'undefined' ? Leaflet : 'undefined');
                    reject(new Error('Leaflet library failed to load'));
                    return;
                }

                setTimeout(checkLeaflet, delayMs);
            }

            checkLeaflet();
        });
    }

    // ============================================================================
    // Template Utilities
    // ============================================================================

    /**
     * Utility class for common HTML template patterns
     */
    class TemplateUtils {
        /**
         * Conditionally render content if value exists
         * @param {*} value - Value to check
         * @param {Function} renderer - Function that returns HTML string
         * @returns {string} Rendered HTML or empty string
         */
        static renderIf(value, renderer) {
            return value ? renderer(value) : '';
        }

        /**
         * Render an array of items with a template
         * @param {Array} items - Array of items to render
         * @param {Function} itemRenderer - Function that renders each item
         * @param {string} emptyContent - Content to show if array is empty
         * @returns {string} Rendered HTML
         */
        static renderList(items, itemRenderer, emptyContent = '') {
            if (!items || items.length === 0) return emptyContent;
            return items.map(itemRenderer).join('');
        }

        /**
         * Escape HTML to prevent XSS
         * @param {string} text - Text to escape
         * @returns {string} Escaped text
         */
        static escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        /**
         * Render a section with heading and content
         * @param {string} title - Section title
         * @param {string} content - Section content
         * @param {string} className - Optional CSS class
         * @returns {string} Rendered section HTML
         */
        static renderSection(title, content, className = 'info-section') {
            return `
                <div class="${className}">
                    <h3>${title}</h3>
                    ${content}
                </div>
            `;
        }

        /**
         * Render a fact item (icon, label, value)
         * @param {string} icon - Icon emoji
         * @param {string} label - Fact label
         * @param {string} value - Fact value
         * @param {boolean} isLink - Whether value is a link
         * @returns {string} Rendered fact HTML
         */
        static renderFact(icon, label, value, isLink = false) {
            const valueContent = isLink
                ? `<a href="${value}" target="_blank" rel="noopener noreferrer">${value}</a>`
                : value;

            return `
                <div class="fact-item">
                    <span class="fact-icon">${icon}</span>
                    <div>
                        <div class="fact-label">${label}</div>
                        <div class="fact-value">${valueContent}</div>
                    </div>
                </div>
            `;
        }

        /**
         * Render a timeline item
         * @param {string} year - Timeline year
         * @param {string} title - Item title
         * @param {string} description - Item description
         * @param {string} extraContent - Additional content to show
         * @returns {string} Rendered timeline item HTML
         */
        static renderTimelineItem(year, title, description, extraContent = '') {
            return `
                <div class="milestone-item">
                    <div class="milestone-year">${year}</div>
                    <div class="milestone-content">
                        <h4>${title}</h4>
                        ${extraContent}
                        <p>${description}</p>
                    </div>
                </div>
            `;
        }

        /**
         * Render a card with optional icon
         * @param {string} title - Card title
         * @param {string} content - Card content
         * @param {string} icon - Optional icon
         * @param {string} className - Card CSS class
         * @returns {string} Rendered card HTML
         */
        static renderCard(title, content, icon = '', className = 'card') {
            return `
                <div class="${className}">
                    ${icon ? `<div class="card-icon">${icon}</div>` : ''}
                    <h4>${title}</h4>
                    ${content}
                </div>
            `;
        }

        /**
         * Render sources/citations
         * @param {Array} sources - Array of source objects with title, url, date, type
         * @returns {string} Rendered sources HTML
         */
        static renderSources(sources) {
            if (!sources || sources.length === 0) return '';

            return `
                <div class="section-sources">
                    <h4>📚 Sources</h4>
                    <ul class="sources-list">
                        ${sources.map(source => `
                            <li class="source-item">
                                <a href="${source.url}" target="_blank" rel="noopener noreferrer" class="source-link">
                                    ${source.title}
                                </a>
                                ${source.date ? `<span class="source-date">(${source.date})</span>` : ''}
                                ${source.type ? `<span class="source-type">${source.type}</span>` : ''}
                            </li>
                        `).join('')}
                    </ul>
                </div>
            `;
        }
    }

    // ============================================================================
    // Base Component Class
    // ============================================================================

    /**
     * Base class for all profile section components
     * Handles data parsing, error handling, and provides utility methods
     */
    class ProfileSectionComponent extends HTMLElement {
        constructor() {
            super();
            this.data = null;
        }

        connectedCallback() {
            const dataAttr = this.getAttribute('data');

            if (!dataAttr) {
                console.warn('[Component] No data attribute found for', this.constructor.name);
                return;
            }

            try {
                const parsed = JSON.parse(dataAttr);
                // Extract the actual data from { type: "...", data: {...} } structure
                this.data = parsed.data || parsed;
                this.validateData();
                this.render();
            } catch (e) {
                console.error('[Component] Failed to parse section data:', e);
                console.error('[Component] Component:', this.constructor.name);
                console.error('[Component] Data preview:', dataAttr.substring(0, 200));
                this.renderError(e.message);
            }
        }

        /**
         * Validate component data (override in subclasses if needed)
         * @throws {Error} If data is invalid
         */
        validateData() {
            if (!this.data) {
                throw new Error('No data provided to component');
            }
        }

        /**
         * Render the component (must be overridden in subclasses)
         */
        render() {
            console.warn('[Component] No render method defined for', this.constructor.name);
            this.innerHTML = '<p class="component-warning">No renderer defined</p>';
        }

        /**
         * Render an error state
         * @param {string} message - Error message to display
         */
        renderError(message = 'Failed to render section') {
            this.innerHTML = `
                <div class="alert alert-error">
                    <strong>Error:</strong> ${TemplateUtils.escapeHtml(message)}
                </div>
            `;
        }

        /**
         * Safely get a nested property from data
         * @param {string} path - Dot-separated path (e.g., 'user.profile.name')
         * @param {*} defaultValue - Default value if path not found
         * @returns {*} Property value or default
         */
        get(path, defaultValue = null) {
            return path.split('.').reduce((obj, key) =>
                (obj && obj[key] !== undefined) ? obj[key] : defaultValue,
                this.data
            );
        }
    }

    // ============================================================================
    // Company Description Component
    // ============================================================================

    class CompanyDescriptionSection extends ProfileSectionComponent {
        render() {
            const {
                title,
                content,
                sources
            } = this.data;

            this.innerHTML = `
                <div class="company-description-section">
                    ${TemplateUtils.renderIf(title, t => `<h2 class="company-title">${t}</h2>`)}
                    
                    ${TemplateUtils.renderIf(content, c => `
                        <div class="company-content">
                            ${this.renderFormattedContent(c)}
                        </div>
                    `)}

                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderFormattedContent(content) {
            // Split content by newlines and render as paragraphs/sections
            const sections = content.split('\n\n');
            return sections.map(section => {
                const trimmed = section.trim();
                if (!trimmed) return '';

                // Check if this is a section header (ends with colon)
                if (trimmed.match(/^[A-Z][^:]*:$/)) {
                    return `<h3 class="content-section-header">${trimmed}</h3>`;
                }

                // Check if this is a list (lines starting with dashes, asterisks, or "Key")
                if (trimmed.includes('\n') && (trimmed.includes('-') || trimmed.includes('Key') || trimmed.includes('•'))) {
                    const items = trimmed.split('\n').filter(line => line.trim());
                    return `
                        <ul class="content-list">
                            ${items.map(item => `<li>${item.replace(/^[-•*]\s*/, '').trim()}</li>`).join('')}
                        </ul>
                    `;
                }

                // Otherwise render as paragraph
                return `<p class="content-paragraph">${trimmed}</p>`;
            }).join('');
        }
    }

    // ============================================================================
    // Their Story Component
    // ============================================================================

    class TheirStorySection extends ProfileSectionComponent {
        render() {
            const { foundingStory, founders, ahaMoment, milestones, sources } = this.data;

            this.innerHTML = `
                <div class="their-story-section">
                    ${this.renderFoundingStory(foundingStory)}
                    ${this.renderFounders(founders)}
                    ${this.renderAhaMoment(ahaMoment)}
                    ${this.renderMilestones(milestones)}
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderFoundingStory(story) {
            return TemplateUtils.renderIf(story, s =>
                TemplateUtils.renderSection('The Founding Story', `<p>${s}</p>`, 'story-section')
            );
        }

        renderFounders(founders) {
            if (!founders || founders.length === 0) return '';

            return `
                <div class="founders-section">
                    <h3>The Founders</h3>
                    <div class="founders-grid">
                        ${TemplateUtils.renderList(founders, f => `
                            <div class="founder-card">
                                <div class="founder-name">${f.name}</div>
                                ${TemplateUtils.renderIf(f.role, r => `<div class="founder-role">${r}</div>`)}
                                <p class="founder-background">${f.background}</p>
                            </div>
                        `)}
                    </div>
                </div>
            `;
        }

        renderAhaMoment(moment) {
            if (!moment) return '';

            const icon = typeof moment === 'object' ? (moment.icon || DEFAULT_ICONS.ahaMoment) : DEFAULT_ICONS.ahaMoment;
            const title = typeof moment === 'object' ? (moment.title || 'The "Aha!" Moment') : 'The "Aha!" Moment';
            const description = typeof moment === 'object' ? moment.description : moment;

            return `
                <div class="aha-moment">
                    <div class="aha-icon">${icon}</div>
                    <div class="aha-content">
                        <h3>${title}</h3>
                        <p>${description}</p>
                    </div>
                </div>
            `;
        }

        renderMilestones(milestones) {
            if (!milestones || milestones.length === 0) return '';

            return `
                <div class="milestones-section">
                    <h3>Key Milestones</h3>
                    <div class="timeline">
                        ${TemplateUtils.renderList(milestones, m =>
                TemplateUtils.renderTimelineItem(m.year, m.title, m.description)
            )}
                    </div>
                </div>
            `;
        }
    }

    // ============================================================================
    // Company Values Component
    // ============================================================================

    class CompanyValuesSection extends ProfileSectionComponent {
        render() {
            const {
                title,
                values_source_type,
                introduction,
                values,
                sources
            } = this.data;

            this.innerHTML = `
                <div class="company-values-section">
                    ${TemplateUtils.renderIf(title, t => `<h2 class="values-title">${t}</h2>`)}
                    
                    ${TemplateUtils.renderIf(introduction, i => `<p class="values-intro">${TemplateUtils.escapeHtml(i)}</p>`)}
                    
                    ${this.renderValuesGrid(values)}
                    
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderValuesGrid(values) {
            if (!values || values.length === 0) return '';

            return `
                <div class="values-grid">
                    ${values.map(v => this.renderValue(v)).join('')}
                </div>
            `;
        }

        renderValue(value) {
            return `
                <div class="value-card">
                    <h3 class="value-title">${TemplateUtils.escapeHtml(value.title)}</h3>
                    ${TemplateUtils.renderIf(value.tagline, t => `<div class="value-tagline">${TemplateUtils.escapeHtml(t)}</div>`)}
                    <p class="value-description">${TemplateUtils.escapeHtml(value.description)}</p>
                </div>
            `;
        }
    }

    // ============================================================================
    // Key Numbers Component
    // ============================================================================

    class KeyNumbersSection extends ProfileSectionComponent {
        render() {
            const { basic_stats, breakdowns, sources } = this.data;

            this.innerHTML = `
                <div class="key-numbers-section">
                    ${this.renderBasicStats(basic_stats)}
                    ${this.renderBreakdowns(breakdowns)}
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderBasicStats(stats) {
            if (!stats || stats.length === 0) return '';

            return `
                <div class="stats-grid">
                    ${stats.map(s => this.renderStat(s)).join('')}
                </div>
            `;
        }

        renderStat(stat) {
            return `
                <div class="stat-card">
                    <div class="stat-value">${TemplateUtils.escapeHtml(stat.value)}</div>
                    <div class="stat-label">${TemplateUtils.escapeHtml(stat.label)}</div>
                </div>
            `;
        }

        renderBreakdowns(breakdowns) {
            if (!breakdowns || breakdowns.length === 0) return '';

            return `
                <div class="breakdowns-section">
                    ${breakdowns.map(b => this.renderBreakdown(b)).join('')}
                </div>
            `;
        }

        renderBreakdown(breakdown) {
            if (!breakdown.items || breakdown.items.length === 0) return '';

            const totalPercentage = breakdown.items.reduce((sum, item) => sum + (item.percentage || 0), 0);
            const chartId = `pie-chart-${Math.random().toString(36).substr(2, 9)}`;

            return `
                <div class="breakdown-card">
                    <h3 class="breakdown-label">${TemplateUtils.escapeHtml(breakdown.label)}</h3>
                    <div class="breakdown-content">
                        <div class="breakdown-chart-container">
                            <svg id="${chartId}" class="pie-chart" viewBox="0 0 200 200">
                                ${this.renderPieChart(breakdown.items)}
                            </svg>
                        </div>
                        <div class="breakdown-legend">
                            ${breakdown.items.map(item => this.renderLegendItem(item)).join('')}
                        </div>
                    </div>
                    ${totalPercentage !== 100 ? `<div class="breakdown-warning">⚠️ Percentages sum to ${totalPercentage}% (expected 100%)</div>` : ''}
                </div>
            `;
        }

        renderPieChart(items) {
            let cumulativePercentage = 0;
            const colors = [
                '#667eea', '#764ba2', '#f093fb', '#4facfe', '#00f2fe',
                '#43e97b', '#fa709a', '#fee140', '#30cfd0', '#330867'
            ];

            return items.map((item, index) => {
                const percentage = item.percentage || 0;
                const startAngle = (cumulativePercentage / 100) * 360;
                const endAngle = ((cumulativePercentage + percentage) / 100) * 360;
                cumulativePercentage += percentage;

                const largeArc = percentage > 50 ? 1 : 0;
                const startRad = (startAngle - 90) * (Math.PI / 180);
                const endRad = (endAngle - 90) * (Math.PI / 180);

                const x1 = 100 + 100 * Math.cos(startRad);
                const y1 = 100 + 100 * Math.sin(startRad);
                const x2 = 100 + 100 * Math.cos(endRad);
                const y2 = 100 + 100 * Math.sin(endRad);

                const pathData = `M 100 100 L ${x1} ${y1} A 100 100 0 ${largeArc} 1 ${x2} ${y2} Z`;
                const color = colors[index % colors.length];

                return `<path d="${pathData}" fill="${color}" stroke="white" stroke-width="2"></path>`;
            }).join('');
        }

        renderLegendItem(item) {
            const percentage = item.percentage || 0;
            const colors = [
                '#667eea', '#764ba2', '#f093fb', '#4facfe', '#00f2fe',
                '#43e97b', '#fa709a', '#fee140', '#30cfd0', '#330867'
            ];

            // Find color index based on cumulative percentage
            let colorIndex = 0;
            let cumulative = 0;
            const items = Array.isArray(this.data.breakdowns) ?
                this.data.breakdowns.find(b => b.items && b.items.includes(item))?.items || [] : [];

            for (let i = 0; i < items.length; i++) {
                if (items[i] === item) {
                    colorIndex = i;
                    break;
                }
            }

            const color = colors[colorIndex % colors.length];

            return `
                <div class="legend-item">
                    <div class="legend-color" style="background-color: ${color}"></div>
                    <div class="legend-text">
                        <div class="legend-category">${TemplateUtils.escapeHtml(item.category)}</div>
                        <div class="legend-percentage">${item.percentage}%</div>
                    </div>
                </div>
            `;
        }
    }

    // ============================================================================
    // Funding Component
    // ============================================================================

    class FundingSection extends ProfileSectionComponent {
        render() {
            const { totalRaised, latestRound, valuation, status, rounds, keyInvestors, sources } = this.data;

            this.innerHTML = `
                <div class="funding-section">
                    ${this.renderFundingSummary({ totalRaised, latestRound, valuation, status })}
                    ${this.renderFundingRounds(rounds)}
                    ${this.renderKeyInvestors(keyInvestors)}
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderFundingSummary({ totalRaised, latestRound, valuation, status }) {
            // Handle latestRound which might be an object or string
            const latestRoundValue = latestRound
                ? (typeof latestRound === 'string'
                    ? latestRound
                    : `${latestRound.series || 'Round'} - ${latestRound.amount || 'N/A'}`)
                : null;

            const summaryItems = [
                totalRaised && { label: 'Total Raised', value: totalRaised, icon: '💰' },
                latestRoundValue && { label: 'Latest Round', value: latestRoundValue, icon: '🎯' },
                valuation && { label: 'Valuation', value: valuation, icon: '📈' },
                status && { label: 'Status', value: status, icon: '📊' }
            ].filter(Boolean);

            if (summaryItems.length === 0) return '';

            return `
                <div class="funding-summary">
                    ${summaryItems.map(item => `
                        <div class="funding-stat">
                            <div class="stat-icon">${item.icon}</div>
                            <div class="funding-stat-label">${item.label}</div>
                            <div class="funding-stat-value">${item.value}</div>
                        </div>
                    `).join('')}
                </div>
            `;
        }

        renderFundingRounds(rounds) {
            if (!rounds || rounds.length === 0) return '';

            return `
                <div class="funding-rounds">
                    <h3>Funding History</h3>
                    <div class="timeline">
                        ${TemplateUtils.renderList(rounds, r => this.renderRound(r))}
                    </div>
                </div>
            `;
        }

        renderRound(round) {
            const year = round.date.match(/\d{4}/)?.[0] || round.date;
            const showFullDate = round.date !== year;
            const extraContent = showFullDate ? `<div class="round-date">${round.date}</div>` : '';

            return TemplateUtils.renderTimelineItem(
                year,
                `${round.series} - ${round.amount}`,
                round.description || '',
                extraContent
            );
        }

        renderKeyInvestors(investors) {
            if (!investors || investors.length === 0) return '';

            return `
                <div class="key-investors">
                    <h3>Key Investors</h3>
                    <div class="investors-list">
                        ${TemplateUtils.renderList(investors, inv => {
                // Handle both string and object formats
                const name = typeof inv === 'string' ? inv : (inv.name || JSON.stringify(inv));
                return `<div class="investor-tag">${name}</div>`;
            })}
                    </div>
                </div>
            `;
        }
    }

    // ============================================================================
    // Leadership Component
    // ============================================================================

    class LeadershipSection extends ProfileSectionComponent {
        render() {
            const { introduction, leaders, sources } = this.data;

            this.innerHTML = `
                <div class="leadership-section">
                    ${TemplateUtils.renderIf(introduction, i => `<p class="leadership-intro">${TemplateUtils.escapeHtml(i)}</p>`)}
                    ${this.renderLeaders(leaders)}
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderLeaders(leaders) {
            if (!leaders || leaders.length === 0) return '';

            return `
                <div class="leaders-grid">
                    ${leaders.map(l => this.renderLeader(l)).join('')}
                </div>
            `;
        }

        renderLeader(leader) {
            return `
                <div class="leader-card">
                    <div class="leader-header">
                        <h3 class="leader-name">${TemplateUtils.escapeHtml(leader.name)}</h3>
                        <div class="leader-role">${TemplateUtils.escapeHtml(leader.role)}</div>
                        ${TemplateUtils.renderIf(leader.tenure, t => `<div class="leader-tenure">${TemplateUtils.escapeHtml(t)}</div>`)}
                    </div>
                    
                    ${TemplateUtils.renderIf(leader.background, b => `
                        <p class="leader-background">${TemplateUtils.escapeHtml(b)}</p>
                    `)}
                    
                    ${this.renderAchievements(leader.achievements)}
                    
                    ${TemplateUtils.renderIf(leader.linkedin, url => `
                        <a href="${url}" target="_blank" rel="noopener noreferrer" class="leader-linkedin-link">
                            🔗 LinkedIn Profile
                        </a>
                    `)}
                </div>
            `;
        }

        renderAchievements(achievements) {
            if (!achievements || achievements.length === 0) return '';

            return `
                <div class="leader-achievements">
                    <h4>Key Achievements</h4>
                    <ul class="achievements-list">
                        ${achievements.map(a => `<li>${TemplateUtils.escapeHtml(a)}</li>`).join('')}
                    </ul>
                </div>
            `;
        }
    }

    // ============================================================================
    // Geocoding Utility (for automatic coordinate lookup)
    // ============================================================================

    const GEOCODING_CACHE = {};

    async function geocodeLocation(address, city, country) {
        // Build query string - skip undefined country
        let queryParts = [];
        if (address) queryParts.push(address);
        if (city) queryParts.push(city);
        if (country) queryParts.push(country);

        const queryString = queryParts.join(', ').trim();
        const cacheKey = queryString.toLowerCase();

        // Return from cache if available
        if (GEOCODING_CACHE[cacheKey]) {
            console.log(`[Geocoding] Cache hit for: ${cacheKey}`, GEOCODING_CACHE[cacheKey]);
            return GEOCODING_CACHE[cacheKey];
        }

        try {
            // Try queries in order of specificity (most specific first)
            const queries = [
                queryString, // Full address: "123 Main St, Berlin, Germany"
                city && country ? `${city}, ${country}` : null, // City + Country: "Berlin, Germany"
                city ? city : null // Just city: "Berlin"
            ].filter(q => q); // Remove null values

            for (const query of queries) {
                console.log(`[Geocoding] Attempting query: ${query}`);
                const encodedQuery = encodeURIComponent(query);
                const url = `https://nominatim.openstreetmap.org/search?q=${encodedQuery}&format=json`;

                const response = await fetch(url);
                const data = await response.json();

                console.log(`[Geocoding] Response for "${query}":`, data);

                if (data && data.length > 0) {
                    const result = {
                        latitude: parseFloat(data[0].lat),
                        longitude: parseFloat(data[0].lon)
                    };
                    console.log(`[Geocoding] ✅ Found coordinates for "${query}":`, result);
                    GEOCODING_CACHE[cacheKey] = result;
                    return result;
                } else {
                    console.log(`[Geocoding] No results for "${query}", trying next query...`);
                }
            }

            console.warn(`[Geocoding] ❌ No results found for any query variation: ${queryString}`);
        } catch (error) {
            console.error(`[Geocoding] Error geocoding "${queryString}":`, error);
        }

        return null;
    }

    // ============================================================================
    // Office Locations Component
    // ============================================================================

    class OfficeLocationsSection extends ProfileSectionComponent {
        connectedCallback() {
            const dataAttr = this.getAttribute('data');

            if (!dataAttr) {
                console.warn('[Component] No data attribute found for', this.constructor.name);
                return;
            }

            try {
                const parsed = JSON.parse(dataAttr);
                // Extract the actual data from { type: "...", data: {...} } structure
                this.data = parsed.data || parsed;
                this.validateData();
                // Use async render for geocoding
                this.renderAsync();
            } catch (e) {
                console.error('[Component] Failed to parse section data:', e);
                console.error('[Component] Component:', this.constructor.name);
                console.error('[Component] Data preview:', dataAttr.substring(0, 200));
                this.renderError(e.message);
            }
        }

        async renderAsync() {
            await this.enhanceLocationsWithGeocoding(this.data.headquarters, this.data.offices);
            this.render();
        }

        render() {
            const { headquarters, offices, sources } = this.data;

            this.innerHTML = `
                <div class="office-locations-section">
                    ${this.renderCombinedMap(headquarters, offices)}
                    ${this.renderHeadquarters(headquarters)}
                    ${this.renderOffices(offices)}
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        async enhanceLocationsWithGeocoding(headquarters, offices) {
            console.log('[OfficeLocations] Enhancing locations with geocoding...');
            console.log('[OfficeLocations] Headquarters:', headquarters);
            console.log('[OfficeLocations] Offices:', offices);

            // Geocode headquarters if needed
            if (headquarters) {
                if (headquarters.latitude && headquarters.longitude) {
                    console.log('[OfficeLocations] ✅ Headquarters already has coordinates from LLM:', { lat: headquarters.latitude, lon: headquarters.longitude });
                } else {
                    console.log(`[OfficeLocations] Geocoding headquarters (no LLM coords): ${headquarters.address || headquarters.city}, ${headquarters.country}`);
                    const coords = await geocodeLocation(headquarters.address, headquarters.city, headquarters.country);
                    if (coords) {
                        headquarters.latitude = coords.latitude;
                        headquarters.longitude = coords.longitude;
                        console.log('[OfficeLocations] ✅ Headquarters geocoded:', headquarters);
                    }
                }
            }

            // Geocode offices if needed
            if (offices && Array.isArray(offices)) {
                for (const office of offices) {
                    if (office.latitude && office.longitude) {
                        console.log(`[OfficeLocations] ✅ Office already has coordinates from LLM:`, { city: office.city, lat: office.latitude, lon: office.longitude });
                    } else {
                        console.log(`[OfficeLocations] Geocoding office (no LLM coords): ${office.address || office.city}, ${office.country}`);
                        const coords = await geocodeLocation(office.address, office.city, office.country);
                        if (coords) {
                            office.latitude = coords.latitude;
                            office.longitude = coords.longitude;
                            console.log('[OfficeLocations] ✅ Office geocoded:', office);
                        }
                    }
                }
            }
        }

        renderCombinedMap(headquarters, offices) {
            const allLocations = [];
            if (headquarters && headquarters.latitude && headquarters.longitude) {
                allLocations.push({ ...headquarters, isHeadquarters: true });
            }
            if (offices && offices.length > 0) {
                allLocations.push(...offices.filter(o => o.latitude && o.longitude));
            }

            if (allLocations.length === 0) return '';

            const mapId = `combined-map-${Math.random().toString(36).substr(2, 9)}`;

            // Schedule map initialization after DOM is ready and Leaflet is loaded
            // Use setTimeout to defer until DOM is in place, then wait for Leaflet
            setTimeout(() => this.initCombinedMapWhenReady(mapId, allLocations), 50);

            return `
                <div class="combined-map-container">
                    <h3>📍 Global Office Locations</h3>
                    <div id="${mapId}" class="combined-map" style="background: #f0f0f0; display: flex; align-items: center; justify-content: center; color: #999; font-size: 12px; min-height: 200px;">
                        ${allLocations.length} location(s) - Map rendering...
                    </div>
                </div>
            `;
        }

        async initCombinedMapWhenReady(mapId, locations) {
            try {
                await waitForLeaflet(200, 50); // Wait up to 10 seconds
                this.initCombinedMap(mapId, locations);
            } catch (error) {
                console.error(`[OfficeLocations] Failed to initialize combined map for "${mapId}":`, error);
                // Gracefully degrade - show list of locations instead of interactive map
                const mapElement = document.getElementById(mapId);
                if (mapElement) {
                    console.log(`[OfficeLocations] Rendering fallback for combined map "${mapId}" with ${locations.length} locations`);
                    const locationsList = locations
                        .map(l => `<div style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>${l.city}</strong>: ${l.latitude.toFixed(4)}, ${l.longitude.toFixed(4)}</div>`)
                        .join('');
                    mapElement.innerHTML = `
                        <div style="width: 100%; padding: 12px; background: #fff9f0; border: 1px solid #fdd7d7; border-radius: 4px; color: #666; font-size: 12px; text-align: left;">
                            <strong style="display: block; margin-bottom: 8px;">📍 Office Locations (Interactive map unavailable)</strong>
                            ${locationsList}
                        </div>
                    `;
                    console.log(`[OfficeLocations] Fallback rendered for combined map "${mapId}"`);
                }
            }
        }

        initCombinedMap(mapId, locations) {
            const mapElement = document.getElementById(mapId);
            if (!mapElement) {
                console.warn(`[OfficeLocations] Combined map element "${mapId}" not found`);
                return;
            }

            // Check if already has Leaflet container (don't re-initialize)
            if (mapElement.classList.contains('leaflet-container')) {
                console.log(`[OfficeLocations] Combined map "${mapId}" already initialized`);
                return;
            }

            // Calculate center and zoom
            const lats = locations.map(l => l.latitude);
            const lons = locations.map(l => l.longitude);
            const centerLat = (Math.min(...lats) + Math.max(...lats)) / 2;
            const centerLon = (Math.min(...lons) + Math.max(...lons)) / 2;

            // Create map
            const map = L.map(mapId).setView([centerLat, centerLon], 4);

            // Add OpenStreetMap tile layer
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors',
                maxZoom: 19
            }).addTo(map);

            // Add markers for each location
            locations.forEach(location => {
                const markerColor = location.isHeadquarters ? '#667eea' : '#3498db';
                const markerIcon = L.divIcon({
                    html: `<div style="background-color: ${markerColor}; width: 30px; height: 30px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; border: 2px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.2);">📍</div>`,
                    iconSize: [30, 30],
                    className: 'office-marker'
                });

                const popup = `
                    <strong>${location.city}${location.country ? ', ' + location.country : ''}</strong><br/>
                    ${location.address ? location.address + '<br/>' : ''}
                    ${location.type ? '<em>' + location.type + '</em>' : ''}
                `;

                L.marker([location.latitude, location.longitude], { icon: markerIcon })
                    .bindPopup(popup)
                    .addTo(map);
            });

            // Fit bounds to show all markers
            if (locations.length > 0) {
                const bounds = L.latLngBounds(locations.map(l => [l.latitude, l.longitude]));
                map.fitBounds(bounds, { padding: [50, 50] });
            }
        }

        calculateBounds(locations) {
            let minLat = locations[0].latitude;
            let maxLat = locations[0].latitude;
            let minLon = locations[0].longitude;
            let maxLon = locations[0].longitude;

            locations.forEach(loc => {
                minLat = Math.min(minLat, loc.latitude);
                maxLat = Math.max(maxLat, loc.latitude);
                minLon = Math.min(minLon, loc.longitude);
                maxLon = Math.max(maxLon, loc.longitude);
            });

            return { minLat, maxLat, minLon, maxLon };
        }

        renderHeadquarters(hq) {
            if (!hq) return '';

            const cityDisplay = hq.country ? `${hq.city}, ${hq.country}` : hq.city;

            return `
                <div class="headquarters-card">
                    <div class="location-badge">🏢 Headquarters</div>
                    <h3 class="location-city">${cityDisplay}</h3>
                    ${TemplateUtils.renderIf(hq.address, a => `<p class="location-address">${a}</p>`)}
                    ${TemplateUtils.renderIf(hq.size, s => `<div class="location-size">👥 ${s}</div>`)}
                    ${TemplateUtils.renderIf(hq.description, d => `<p class="location-description">${d}</p>`)}
                    ${this.renderLocationMap(hq, 'hq-map')}
                </div>
            `;
        }

        renderOffices(offices) {
            if (!offices || offices.length === 0) return '';

            return `
                <div class="offices-grid">
                    ${TemplateUtils.renderList(offices, (o, idx) => this.renderOffice(o, idx))}
                </div>
            `;
        }

        renderOffice(office, index) {
            const mapId = `office-map-${index}`;
            const cityDisplay = office.country ? `${office.city}, ${office.country}` : office.city;
            return `
                <div class="office-card">
                    <div class="location-header">
                        <h4 class="location-city">${cityDisplay}</h4>
                        ${TemplateUtils.renderIf(office.type, t => `<span class="location-type-badge">${t}</span>`)}
                    </div>
                    ${TemplateUtils.renderIf(office.address, a => `<p class="location-address">${a}</p>`)}
                    ${TemplateUtils.renderIf(office.size, s => `<div class="location-size">👥 ${s}</div>`)}
                    ${TemplateUtils.renderIf(office.description, d => `<p class="location-description">${d}</p>`)}
                    ${this.renderLocationMap(office, mapId)}
                </div>
            `;
        }

        renderLocationMap(location, mapId) {
            if (!location.latitude || !location.longitude) return '';

            // Schedule map initialization after DOM is ready and Leaflet is loaded
            // Use setTimeout to defer until DOM is in place, then wait for Leaflet
            setTimeout(() => this.initLocationMapWhenReady(mapId, location), 50);

            return `
                <div class="location-map-container">
                    <div id="${mapId}" class="location-map" style="background: #f0f0f0; display: flex; align-items: center; justify-content: center; color: #999; font-size: 12px;">
                        📍 ${location.latitude.toFixed(4)}, ${location.longitude.toFixed(4)}<br/>
                        <small>(Map rendering...)</small>
                    </div>
                </div>
            `;
        }

        async initLocationMapWhenReady(mapId, location) {
            try {
                await waitForLeaflet(200, 50); // Wait up to 10 seconds
                this.initLocationMap(mapId, location);
            } catch (error) {
                console.error(`[OfficeLocations] Failed to initialize map for "${mapId}":`, error);
                // Gracefully degrade - show coordinates instead of interactive map
                const mapElement = document.getElementById(mapId);
                if (mapElement) {
                    console.log(`[OfficeLocations] Rendering fallback for "${mapId}" with location:`, location);
                    mapElement.innerHTML = `
                        <div style="padding: 12px; background: #fff9f0; border: 1px solid #fdd7d7; border-radius: 4px; text-align: center; color: #666; font-size: 12px;">
                            📍 <strong>${location.city || 'Location'}</strong><br/>
                            Lat: ${location.latitude.toFixed(4)}<br/>
                            Lon: ${location.longitude.toFixed(4)}<br/>
                            <small>(Interactive map unavailable)</small>
                        </div>
                    `;
                    console.log(`[OfficeLocations] Fallback rendered for "${mapId}"`);
                }
            }
        }

        initLocationMap(mapId, location) {
            const mapElement = document.getElementById(mapId);
            if (!mapElement) {
                console.warn(`[OfficeLocations] Map element "${mapId}" not found`);
                return;
            }

            // Check if already has Leaflet container (don't re-initialize)
            if (mapElement.classList.contains('leaflet-container')) {
                console.log(`[OfficeLocations] Map "${mapId}" already initialized`);
                return;
            }

            // Create map
            const map = L.map(mapId).setView([location.latitude, location.longitude], 14);

            // Add OpenStreetMap tile layer
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors',
                maxZoom: 19
            }).addTo(map);

            // Add marker
            const markerIcon = L.divIcon({
                html: `<div style="background-color: #667eea; width: 35px; height: 35px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; border: 3px solid white; box-shadow: 0 2px 8px rgba(0,0,0,0.3); font-size: 18px;">📍</div>`,
                iconSize: [35, 35],
                className: 'office-marker'
            });

            const popup = `
                <strong>${location.city}${location.country ? ', ' + location.country : ''}</strong><br/>
                ${location.address ? location.address + '<br/>' : ''}
                ${location.type ? '<em>' + location.type + '</em>' : ''}
            `;

            L.marker([location.latitude, location.longitude], { icon: markerIcon })
                .bindPopup(popup)
                .addTo(map)
                .openPopup();
        }
    }

    // ============================================================================
    // Perks and Benefits Component
    // ============================================================================

    class PerksBenefitsSection extends ProfileSectionComponent {
        render() {
            const { introduction, standoutBenefits, categories, sources } = this.data;

            this.innerHTML = `
                <div class="perks-benefits-section">
                    ${TemplateUtils.renderIf(introduction, i => `<p class="benefits-intro">${i}</p>`)}
                    ${this.renderStandoutBenefits(standoutBenefits)}
                    ${this.renderCategories(categories)}
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderStandoutBenefits(benefits) {
            if (!benefits || benefits.length === 0) return '';

            return `
                <div class="standout-benefits">
                    <h3>✨ Standout Benefits</h3>
                    <div class="benefits-highlight-grid">
                        ${TemplateUtils.renderList(benefits, b => `
                            <div class="benefit-highlight">
                                ${TemplateUtils.renderIf(b.icon, i => `<div class="benefit-icon">${i}</div>`)}
                                <h4>${b.name}</h4>
                                ${TemplateUtils.renderIf(b.description, d => `<p>${d}</p>`)}
                            </div>
                        `)}
                    </div>
                </div>
            `;
        }

        renderCategories(categories) {
            if (!categories || categories.length === 0) return '';

            return `
                <div class="benefits-categories">
                    ${TemplateUtils.renderList(categories, c => this.renderCategory(c))}
                </div>
            `;
        }

        renderCategory(category) {
            return `
                <div class="benefit-category">
                    <h4 class="category-header">
                        ${TemplateUtils.renderIf(category.icon, i => `${i} `)}${category.category}
                    </h4>
                    <ul class="benefits-list">
                        ${TemplateUtils.renderList(category.benefits, benefit => this.renderBenefit(benefit))}
                    </ul>
                </div>
            `;
        }

        renderBenefit(benefit) {
            const highlightClass = benefit.highlight ? ' class="benefit-highlight-item"' : '';
            return `
                <li${highlightClass}>
                    <strong>${benefit.name}:</strong> ${benefit.description}
                </li>
            `;
        }
    }

    // ============================================================================
    // Remote Policy Component
    // ============================================================================

    class RemotePolicySection extends ProfileSectionComponent {
        render() {
            const { models, summary, policy_details, sources } = this.data;

            this.innerHTML = `
                <div class="remote-policy-section">
                    ${this.renderModels(models)}
                    ${TemplateUtils.renderIf(summary, s => `
                        <div class="policy-summary">
                            <h3>Remote Work Philosophy</h3>
                            <p>${s}</p>
                        </div>
                    `)}
                    ${TemplateUtils.renderIf(policy_details, p => `
                        <div class="policy-details-block">
                            <h3>Policy Details</h3>
                            <p>${p}</p>
                        </div>
                    `)}
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderModels(models) {
            if (!models || models.length === 0) return '';

            // Ensure models is an array
            const modelArray = Array.isArray(models) ? models : [models];

            return `
                <div class="remote-models">
                    <h3>Remote Work Models</h3>
                    <div class="models-grid">
                        ${modelArray.map(model => this.renderModelBadge(model)).join('')}
                    </div>
                </div>
            `;
        }

        renderModelBadge(model) {
            const modelIcons = {
                'Office-First': '🏢',
                'Hybrid-Required': '🔄',
                'Hybrid-Flexible': '⚡',
                'Remote-First': '🌍',
                'Fully Remote': '🚀'
            };

            const icon = modelIcons[model] || '💼';
            const escapedModel = TemplateUtils.escapeHtml(model);

            return `
                <div class="model-badge">
                    <span class="model-icon">${icon}</span>
                    <span class="model-name">${escapedModel}</span>
                </div>
            `;
        }
    }

    // ============================================================================
    // What We Are Looking For Component
    // ============================================================================

    class WhatWeAreLookingForSection extends ProfileSectionComponent {
        render() {
            const { title, content, sources } = this.data;

            this.innerHTML = `
                <div class="what-we-are-looking-for-section">
                    ${TemplateUtils.renderIf(title, t => `<h2 class="wwalf-title">${TemplateUtils.escapeHtml(t)}</h2>`)}
                    
                    ${TemplateUtils.renderIf(content, c => `
                        <div class="wwalf-content">
                            ${this.renderFormattedContent(c)}
                        </div>
                    `)}

                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderFormattedContent(content) {
            // Split content by double newlines for paragraphs
            const paragraphs = content.split('\n\n');
            return paragraphs.map(paragraph => {
                const trimmed = paragraph.trim();
                if (!trimmed) return '';

                // Check if this looks like a section header (short text ending with colon or ?)
                if (trimmed.match(/^[A-ZÀ-Ú][^.!?\n]{0,50}[?:]$/)) {
                    return `<h3 class="wwalf-section-header">${TemplateUtils.escapeHtml(trimmed)}</h3>`;
                }

                // Render as paragraph
                return `<p class="wwalf-paragraph">${TemplateUtils.escapeHtml(trimmed)}</p>`;
            }).join('');
        }
    }

    // ============================================================================
    // File Analysis Section Component
    // ============================================================================

    class FileAnalysisSection extends ProfileSectionComponent {
        render() {
            // Normalize data: ensure arrays are arrays, not comma-separated strings
            const normalizedData = this.normalizeData(this.data);
            const {
                tone_of_voice,
                brand_personality,
                key_themes = [],
                messaging_style,
                target_audience,
                core_values = [],
                language_patterns,
                industry_focus,
                summary
            } = normalizedData;

            this.innerHTML = `
                <div class="file-analysis-section">
                    <div class="file-analysis-intro">
                        <p><strong>Brand Voice & Tone Analysis</strong> based on uploaded company materials. This analysis reveals the distinctive characteristics of how the company communicates, their brand personality, and messaging approach.</p>
                    </div>

                    <!-- Tone of Voice Section -->
                    <div class="tone-section">
                        <h3>🎯 Tone of Voice</h3>
                        <div class="tone-content">
                            <p>${TemplateUtils.escapeHtml(tone_of_voice || '')}</p>
                        </div>
                    </div>

                    <!-- Brand Personality Section -->
                    <div class="brand-section">
                        <h3>✨ Brand Personality</h3>
                        <div class="personality-traits">
                            ${this.renderPersonalityTraits(brand_personality)}
                        </div>
                    </div>

                    <!-- Key Themes Section -->
                    ${Array.isArray(key_themes) && key_themes.length > 0 ? `
                        <div class="themes-section">
                            <h3>🎨 Key Themes</h3>
                            <div class="themes-list">
                                ${key_themes.map((theme, idx) => this.renderThemeCard(theme, idx)).join('')}
                            </div>
                        </div>
                    ` : ''}

                    <!-- Messaging Style Section -->
                    ${TemplateUtils.renderIf(messaging_style, style => `
                        <div class="messaging-section">
                            <h3>💬 Messaging Style</h3>
                            <p class="messaging-description">${TemplateUtils.escapeHtml(style)}</p>
                        </div>
                    `)}

                    <!-- Target Audience Section -->
                    ${TemplateUtils.renderIf(target_audience, audience => `
                        <div class="audience-section">
                            <h3>👥 Target Audience</h3>
                            <p class="audience-description">${TemplateUtils.escapeHtml(audience)}</p>
                        </div>
                    `)}

                    <!-- Core Values Section -->
                    ${Array.isArray(core_values) && core_values.length > 0 ? `
                        <div class="values-analysis-section">
                            <h3>💎 Core Values</h3>
                            <div class="values-badges">
                                ${core_values.map(value => `<span class="value-badge">${TemplateUtils.escapeHtml(value)}</span>`).join('')}
                            </div>
                        </div>
                    ` : ''}

                    <!-- Language Patterns Section -->
                    ${TemplateUtils.renderIf(language_patterns, patterns => `
                        <div class="language-section">
                            <h3>🔤 Language Patterns</h3>
                            <p class="language-description">${TemplateUtils.escapeHtml(patterns)}</p>
                        </div>
                    `)}

                    <!-- Industry Focus Section -->
                    ${TemplateUtils.renderIf(industry_focus, industry => `
                        <div class="industry-section">
                            <h3>🏢 Industry Focus</h3>
                            <p class="industry-description">${TemplateUtils.escapeHtml(industry)}</p>
                        </div>
                    `)}

                    <!-- Summary Section -->
                    ${TemplateUtils.renderIf(summary, sum => `
                        <div class="summary-section">
                            <h3>📋 Summary & Guidelines</h3>
                            <p class="summary-content">${TemplateUtils.escapeHtml(sum)}</p>
                        </div>
                    `)}
                </div>
            `;
        }

        normalizeData(data) {
            // Convert comma-separated strings to arrays for array fields
            return {
                ...data,
                key_themes: this.ensureArray(data.key_themes),
                core_values: this.ensureArray(data.core_values)
            };
        }

        ensureArray(value) {
            if (!value) return [];
            // If already an array, return as-is
            if (Array.isArray(value)) return value;
            // If string, try to split by comma
            if (typeof value === 'string') {
                const trimmed = value.trim();
                if (trimmed.length === 0) return [];
                // Split by comma, clean up, and filter empty strings
                return trimmed
                    .split(',')
                    .map(item => item.trim())
                    .filter(item => item.length > 0);
            }
            // For any other type, return empty array
            return [];
        }

        renderPersonalityTraits(brandPersonality) {
            if (!brandPersonality) return '';

            // Split by comma and clean up
            const traits = brandPersonality
                .split(',')
                .map(t => t.trim())
                .filter(t => t.length > 0)
                .slice(0, 4); // Limit to 4 traits for layout

            return traits.map(trait => `
                <div class="trait-badge">
                    <p class="trait-text">${TemplateUtils.escapeHtml(trait)}</p>
                </div>
            `).join('');
        }

        renderThemeCard(theme, index) {
            const icons = ['🎯', '💡', '🚀', '🌟', '⚡'];
            const icon = icons[index % icons.length];

            return `
                <div class="theme-card">
                    <div class="theme-icon">${icon}</div>
                    <p class="theme-text">${TemplateUtils.escapeHtml(theme)}</p>
                </div>
            `;
        }
    }

    // ============================================================================
    // Component Registration
    // ============================================================================

    customElements.define('company-description-section', CompanyDescriptionSection);
    customElements.define('their-story-section', TheirStorySection);
    customElements.define('company-values-section', CompanyValuesSection);
    customElements.define('key-numbers-section', KeyNumbersSection);
    customElements.define('funding-section', FundingSection);
    customElements.define('leadership-section', LeadershipSection);
    customElements.define('office-locations-section', OfficeLocationsSection);
    customElements.define('perks-benefits-section', PerksBenefitsSection);
    customElements.define('remote-policy-section', RemotePolicySection);
    customElements.define('what-we-are-looking-for-section', WhatWeAreLookingForSection);
    customElements.define('file-analysis-section', FileAnalysisSection);

    // Export for testing
    if (typeof module !== 'undefined' && module.exports) {
        module.exports = {
            TemplateUtils,
            ProfileSectionComponent,
            CompanyDescriptionSection,
            TheirStorySection,
            CompanyValuesSection,
            KeyNumbersSection,
            FundingSection,
            LeadershipSection,
            OfficeLocationsSection,
            PerksBenefitsSection,
            RemotePolicySection,
            WhatWeAreLookingForSection,
            FileAnalysisSection
        };
    }


})();
