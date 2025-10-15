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
                tagline,
                overview,
                industry,
                founded,
                headquarters,
                companySize,
                website,
                keyProducts,
                targetMarket,
                businessModel,
                sources
            } = this.data;

            this.innerHTML = `
                <div class="company-description-section">
                    ${TemplateUtils.renderIf(tagline, t => `<div class="tagline">${t}</div>`)}
                    
                    ${TemplateUtils.renderIf(overview, o => `
                        <div class="company-overview">
                            <p>${o}</p>
                        </div>
                    `)}

                    <div class="company-quick-facts">
                        ${this.renderQuickFacts({ industry, founded, headquarters, companySize, website })}
                    </div>

                    ${this.renderKeyProducts(keyProducts)}
                    ${TemplateUtils.renderIf(targetMarket, tm =>
                TemplateUtils.renderSection('Target Market', `<p>${tm}</p>`)
            )}
                    ${TemplateUtils.renderIf(businessModel, bm =>
                TemplateUtils.renderSection('Business Model', `<p>${bm}</p>`)
            )}
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderQuickFacts({ industry, founded, headquarters, companySize, website }) {
            const facts = [
                industry && TemplateUtils.renderFact(DEFAULT_ICONS.industry, 'Industry', industry),
                founded && TemplateUtils.renderFact(DEFAULT_ICONS.founded, 'Founded', founded),
                headquarters && TemplateUtils.renderFact(DEFAULT_ICONS.headquarters, 'Headquarters', headquarters),
                companySize && TemplateUtils.renderFact(DEFAULT_ICONS.size, 'Company Size', companySize),
                website && TemplateUtils.renderFact(DEFAULT_ICONS.website, 'Website', website, true)
            ].filter(Boolean);

            return facts.join('');
        }

        renderKeyProducts(products) {
            if (!products || products.length === 0) return '';

            return `
                <div class="key-products">
                    <h3>Key Products & Services</h3>
                    <div class="products-grid">
                        ${TemplateUtils.renderList(products, p => `
                            <div class="product-card">
                                <h4>${p.name}</h4>
                                <p>${p.description}</p>
                            </div>
                        `)}
                    </div>
                </div>
            `;
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
            const { introduction, values, sources } = this.data;

            this.innerHTML = `
                <div class="company-values-section">
                    ${TemplateUtils.renderIf(introduction, i => `<p class="values-intro">${i}</p>`)}
                    <div class="values-grid">
                        ${TemplateUtils.renderList(values, v => this.renderValue(v))}
                    </div>
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderValue(value) {
            return `
                <div class="value-card">
                    <div class="value-header">
                        <span class="value-icon">${value.icon || DEFAULT_ICONS.value}</span>
                        <h3>${value.title}</h3>
                    </div>
                    ${TemplateUtils.renderIf(value.tagline, t => `<div class="value-tagline">${t}</div>`)}
                    <div class="value-description">
                        <p>${value.description}</p>
                    </div>
                    ${this.renderExamples(value.examples)}
                </div>
            `;
        }

        renderExamples(examples) {
            if (!examples || examples.length === 0) return '';

            return `
                <div class="value-examples">
                    <strong>In practice:</strong>
                    <ul>
                        ${TemplateUtils.renderList(examples, ex => `<li>${ex}</li>`)}
                    </ul>
                </div>
            `;
        }
    }

    // ============================================================================
    // Key Numbers Component
    // ============================================================================

    class KeyNumbersSection extends ProfileSectionComponent {
        render() {
            const { stats, context, lastUpdated, sources } = this.data;

            this.innerHTML = `
                <div class="key-numbers-section">
                    <div class="stats-grid">
                        ${TemplateUtils.renderList(stats, s => this.renderStat(s))}
                    </div>
                    ${TemplateUtils.renderIf(context, c => `
                        <div class="numbers-context">
                            <p>${c}</p>
                        </div>
                    `)}
                    ${TemplateUtils.renderIf(lastUpdated, u => `
                        <div class="last-updated">
                            <small>Last updated: ${u}</small>
                        </div>
                    `)}
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderStat(stat) {
            return `
                <div class="stat-card">
                    ${TemplateUtils.renderIf(stat.icon, i => `<div class="stat-icon">${i}</div>`)}
                    <div class="stat-value">${stat.value}</div>
                    <div class="stat-label">${stat.label}</div>
                    ${TemplateUtils.renderIf(stat.context, c => `<div class="stat-context">${c}</div>`)}
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
                            <div class="funding-icon">${item.icon}</div>
                            <div class="funding-label">${item.label}</div>
                            <div class="funding-value">${item.value}</div>
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
            const { introduction, leaders, organizationStructure, sources } = this.data;

            this.innerHTML = `
                <div class="leadership-section">
                    ${TemplateUtils.renderIf(introduction, i => `<p class="leadership-intro">${i}</p>`)}
                    ${this.renderLeaders(leaders)}
                    ${TemplateUtils.renderIf(organizationStructure, s =>
                TemplateUtils.renderSection('Organization Structure', `<p>${s}</p>`)
            )}
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderLeaders(leaders) {
            if (!leaders || leaders.length === 0) return '';

            return `
                <div class="leaders-grid">
                    ${TemplateUtils.renderList(leaders, l => this.renderLeader(l))}
                </div>
            `;
        }

        renderLeader(leader) {
            return `
                <div class="leader-card">
                    <div class="leader-header">
                        <div class="leader-name">${leader.name}</div>
                        <div class="leader-title">${leader.title}</div>
                    </div>
                    ${TemplateUtils.renderIf(leader.background, b => `
                        <p class="leader-background">${b}</p>
                    `)}
                    ${this.renderLeaderHighlights(leader.keyContributions)}
                    ${this.renderSocialLinks(leader.linkedin, leader.twitter)}
                </div>
            `;
        }

        renderLeaderHighlights(contributions) {
            if (!contributions || contributions.length === 0) return '';

            return `
                <div class="leader-highlights">
                    <strong>Key Contributions:</strong>
                    <ul>
                        ${TemplateUtils.renderList(contributions, c => `<li>${c}</li>`)}
                    </ul>
                </div>
            `;
        }

        renderSocialLinks(linkedin, twitter) {
            const links = [];

            if (linkedin) {
                links.push(`<a href="${linkedin}" target="_blank" rel="noopener noreferrer" class="social-link">LinkedIn</a>`);
            }
            if (twitter) {
                links.push(`<a href="${twitter}" target="_blank" rel="noopener noreferrer" class="social-link">Twitter</a>`);
            }

            return links.length > 0 ? `<div class="leader-social">${links.join(' • ')}</div>` : '';
        }
    }

    // ============================================================================
    // Office Locations Component
    // ============================================================================

    class OfficeLocationsSection extends ProfileSectionComponent {
        render() {
            const { headquarters, offices, sources } = this.data;

            this.innerHTML = `
                <div class="office-locations-section">
                    ${this.renderHeadquarters(headquarters)}
                    ${this.renderOffices(offices)}
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderHeadquarters(hq) {
            if (!hq) return '';

            return `
                <div class="headquarters-card">
                    <div class="location-badge">🏢 Headquarters</div>
                    <h3 class="location-city">${hq.city}, ${hq.country}</h3>
                    ${TemplateUtils.renderIf(hq.address, a => `<p class="location-address">${a}</p>`)}
                    ${TemplateUtils.renderIf(hq.size, s => `<div class="location-size">👥 ${s}</div>`)}
                    ${TemplateUtils.renderIf(hq.description, d => `<p class="location-description">${d}</p>`)}
                </div>
            `;
        }

        renderOffices(offices) {
            if (!offices || offices.length === 0) return '';

            return `
                <div class="offices-grid">
                    ${TemplateUtils.renderList(offices, o => this.renderOffice(o))}
                </div>
            `;
        }

        renderOffice(office) {
            return `
                <div class="office-card">
                    <div class="location-header">
                        <h4 class="location-city">${office.city}, ${office.country}</h4>
                        ${TemplateUtils.renderIf(office.type, t => `<span class="location-type-badge">${t}</span>`)}
                    </div>
                    ${TemplateUtils.renderIf(office.address, a => `<p class="location-address">${a}</p>`)}
                    ${TemplateUtils.renderIf(office.size, s => `<div class="location-size">👥 ${s}</div>`)}
                    ${TemplateUtils.renderIf(office.description, d => `<p class="location-description">${d}</p>`)}
                </div>
            `;
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
                        ${TemplateUtils.renderList(category.items, item => `<li>${item}</li>`)}
                    </ul>
                </div>
            `;
        }
    }

    // ============================================================================
    // Remote Policy Component
    // ============================================================================

    class RemotePolicySection extends ProfileSectionComponent {
        render() {
            const { workLocation, equipment, schedule, tools, culture, sources } = this.data;

            this.innerHTML = `
                <div class="remote-policy-section">
                    ${this.renderWorkLocation(workLocation)}
                    ${this.renderEquipment(equipment)}
                    ${this.renderSchedule(schedule)}
                    ${this.renderTools(tools)}
                    ${this.renderCulture(culture)}
                    ${TemplateUtils.renderSources(sources)}
                </div>
            `;
        }

        renderWorkLocation(location) {
            if (!location) return '';

            return `
                <div class="policy-block">
                    <h3>📍 Work Location Policy</h3>
                    ${this.renderTextField('Policy', location.policy)}
                    ${this.renderTextField('Office Expectation', location.officeExpectation)}
                    ${this.renderTextField('Work From Anywhere', location.workFromAnywhere)}
                </div>
            `;
        }

        renderEquipment(equipment) {
            if (!equipment) return '';

            return `
                <div class="policy-block">
                    <h3>💻 Equipment & Setup</h3>
                    ${this.renderTextField('Budget', equipment.budget)}
                    ${this.renderTextField('Provided Equipment', equipment.provided)}
                    ${this.renderTextField('Support', equipment.support)}
                </div>
            `;
        }

        renderSchedule(schedule) {
            if (!schedule) return '';

            return `
                <div class="policy-block">
                    <h3>⏰ Schedule & Hours</h3>
                    ${this.renderTextField('Flexibility', schedule.flexibility)}
                    ${this.renderTextField('Core Hours', schedule.coreHours)}
                    ${this.renderTextField('Asynchronous Work', schedule.asynchronous)}
                </div>
            `;
        }

        renderTools(tools) {
            if (!tools) return '';

            return `
                <div class="policy-block">
                    <h3>🛠️ Tools & Technology</h3>
                    ${this.renderTextField('Communication', tools.communication)}
                    ${this.renderTextField('Collaboration', tools.collaboration)}
                    ${this.renderTextField('Socializing', tools.socializing)}
                </div>
            `;
        }

        renderCulture(culture) {
            if (!culture) return '';

            return `
                <div class="policy-block">
                    <h3>🌟 Remote Culture</h3>
                    ${this.renderTextField('In-Person Events', culture.inPerson)}
                    ${this.renderTextField('Remote Culture', culture.remoteCulture)}
                    ${this.renderTextField('Inclusion', culture.inclusion)}
                </div>
            `;
        }

        renderTextField(label, value) {
            return TemplateUtils.renderIf(value, v => `
                <div class="policy-text-section">
                    <h4>${label}:</h4>
                    <p>${v}</p>
                </div>
            `);
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
            RemotePolicySection
        };
    }

})();
