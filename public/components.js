/**
 * Profile Section Web Components
 * Custom elements for rendering structured profile sections
 */

(function () {
    'use strict';

    // ============================================================================
    // Base Component Class
    // ============================================================================

    class ProfileSectionComponent extends HTMLElement {
        constructor() {
            super();
            this.data = null;
        }

        connectedCallback() {
            const dataAttr = this.getAttribute('data');
            if (dataAttr) {
                try {
                    const parsed = JSON.parse(dataAttr);
                    // Extract the actual data from { type: "...", data: {...} } structure
                    this.data = parsed.data || parsed;
                    this.render();
                } catch (e) {
                    console.error('[Component] Failed to parse section data:', e);
                    console.error('[Component] Data was:', dataAttr.substring(0, 500));
                    this.renderError();
                }
            } else {
                console.warn('[Component] No data attribute found');
            }
        }

        render() {
            // Override in subclasses
            this.innerHTML = '<p>No renderer defined</p>';
        }

        renderError() {
            this.innerHTML = `
                <div class="alert alert-error">
                    <strong>Error:</strong> Failed to render section
                </div>
            `;
        }

        // Utility method to create element from HTML string
        createFromHTML(html) {
            const template = document.createElement('template');
            template.innerHTML = html.trim();
            return template.content.firstChild;
        }
    }

    // ============================================================================
    // Company Description Component
    // ============================================================================

    class CompanyDescriptionSection extends ProfileSectionComponent {
        render() {
            const { tagline, overview, industry, founded, headquarters, companySize, website, keyProducts, targetMarket, businessModel } = this.data;

            this.innerHTML = `
                <div class="company-description-section">
                    ${tagline ? `<div class="tagline">${tagline}</div>` : ''}
                    
                    <div class="company-overview">
                        <p>${overview}</p>
                    </div>

                    <div class="company-quick-facts">
                        ${industry ? `
                            <div class="fact-item">
                                <span class="fact-icon">🏭</span>
                                <div>
                                    <div class="fact-label">Industry</div>
                                    <div class="fact-value">${industry}</div>
                                </div>
                            </div>
                        ` : ''}
                        
                        ${founded ? `
                            <div class="fact-item">
                                <span class="fact-icon">📅</span>
                                <div>
                                    <div class="fact-label">Founded</div>
                                    <div class="fact-value">${founded}</div>
                                </div>
                            </div>
                        ` : ''}
                        
                        ${headquarters ? `
                            <div class="fact-item">
                                <span class="fact-icon">🏢</span>
                                <div>
                                    <div class="fact-label">Headquarters</div>
                                    <div class="fact-value">${headquarters}</div>
                                </div>
                            </div>
                        ` : ''}
                        
                        ${companySize ? `
                            <div class="fact-item">
                                <span class="fact-icon">👥</span>
                                <div>
                                    <div class="fact-label">Company Size</div>
                                    <div class="fact-value">${companySize}</div>
                                </div>
                            </div>
                        ` : ''}
                        
                        ${website ? `
                            <div class="fact-item">
                                <span class="fact-icon">🌐</span>
                                <div>
                                    <div class="fact-label">Website</div>
                                    <div class="fact-value">
                                        <a href="${website}" target="_blank" rel="noopener noreferrer">${website}</a>
                                    </div>
                                </div>
                            </div>
                        ` : ''}
                    </div>

                    ${keyProducts && keyProducts.length > 0 ? `
                        <div class="key-products">
                            <h3>Key Products & Services</h3>
                            <div class="products-grid">
                                ${keyProducts.map(product => `
                                    <div class="product-card">
                                        <h4>${product.name}</h4>
                                        <p>${product.description}</p>
                                    </div>
                                `).join('')}
                            </div>
                        </div>
                    ` : ''}

                    ${targetMarket ? `
                        <div class="info-section">
                            <h3>Target Market</h3>
                            <p>${targetMarket}</p>
                        </div>
                    ` : ''}

                    ${businessModel ? `
                        <div class="info-section">
                            <h3>Business Model</h3>
                            <p>${businessModel}</p>
                        </div>
                    ` : ''}
                </div>
            `;
        }
    }

    // ============================================================================
    // Their Story Component
    // ============================================================================

    class TheirStorySection extends ProfileSectionComponent {
        render() {
            const { foundingStory, founders, ahaMoment, milestones } = this.data;

            this.innerHTML = `
                <div class="their-story-section">
                    ${foundingStory ? `
                        <div class="story-section">
                            <h3>The Founding Story</h3>
                            <p>${foundingStory}</p>
                        </div>
                    ` : ''}
                    
                    ${founders && founders.length > 0 ? `
                        <div class="founders-section">
                            <h3>The Founders</h3>
                            <div class="founders-grid">
                                ${founders.map(founder => `
                                    <div class="founder-card">
                                        <div class="founder-name">${founder.name}</div>
                                        ${founder.role ? `<div class="founder-role">${founder.role}</div>` : ''}
                                        <p class="founder-background">${founder.background}</p>
                                    </div>
                                `).join('')}
                            </div>
                        </div>
                    ` : ''}

                    ${ahaMoment ? `
                        <div class="aha-moment">
                            <div class="aha-icon">${ahaMoment.icon || '💡'}</div>
                            <div class="aha-content">
                                <h3>${ahaMoment.title || 'The "Aha!" Moment'}</h3>
                                <p>${ahaMoment.description || ahaMoment}</p>
                            </div>
                        </div>
                    ` : ''}

                    ${milestones && milestones.length > 0 ? `
                        <div class="milestones-section">
                            <h3>Key Milestones</h3>
                            <div class="timeline">
                                ${milestones.map(milestone => `
                                    <div class="milestone-item">
                                        <div class="milestone-year">${milestone.year}</div>
                                        <div class="milestone-content">
                                            <h4>${milestone.title}</h4>
                                            <p>${milestone.description}</p>
                                        </div>
                                    </div>
                                `).join('')}
                            </div>
                        </div>
                    ` : ''}
                </div>
            `;
        }
    }

    // ============================================================================
    // Company Values Component
    // ============================================================================

    class CompanyValuesSection extends ProfileSectionComponent {
        render() {
            const { introduction, values } = this.data;

            this.innerHTML = `
                <div class="company-values-section">
                    ${introduction ? `<p class="values-intro">${introduction}</p>` : ''}
                    
                    <div class="values-grid">
                        ${values.map(value => `
                            <div class="value-card">
                                <div class="value-header">
                                    <span class="value-icon">${value.icon || '💎'}</span>
                                    <h3>${value.title}</h3>
                                </div>
                                ${value.tagline ? `<div class="value-tagline">${value.tagline}</div>` : ''}
                                <div class="value-description">
                                    <p>${value.description}</p>
                                </div>
                                ${value.examples && value.examples.length > 0 ? `
                                    <div class="value-examples">
                                        <strong>In practice:</strong>
                                        <ul>
                                            ${value.examples.map(ex => `<li>${ex}</li>`).join('')}
                                        </ul>
                                    </div>
                                ` : ''}
                            </div>
                        `).join('')}
                    </div>
                </div>
            `;
        }
    }

    // ============================================================================
    // Key Numbers Component
    // ============================================================================

    class KeyNumbersSection extends ProfileSectionComponent {
        render() {
            const { stats, context, lastUpdated } = this.data;

            this.innerHTML = `
                <div class="key-numbers-section">
                    <div class="stats-grid">
                        ${(stats || []).map(stat => `
                            <div class="stat-card">
                                ${stat.icon ? `<div class="stat-icon">${stat.icon}</div>` : ''}
                                <div class="stat-value">${stat.value}</div>
                                <div class="stat-label">${stat.label}</div>
                                ${stat.context ? `<div class="stat-context">${stat.context}</div>` : ''}
                            </div>
                        `).join('')}
                    </div>
                    
                    ${context ? `
                        <div class="numbers-context">
                            <p>${context}</p>
                        </div>
                    ` : ''}
                    
                    ${lastUpdated ? `
                        <div class="last-updated">
                            <small>Last updated: ${lastUpdated}</small>
                        </div>
                    ` : ''}
                </div>
            `;
        }
    }

    // ============================================================================
    // Funding Component
    // ============================================================================

    class FundingSection extends ProfileSectionComponent {
        render() {
            const { totalRaised, latestRound, valuation, status, rounds, keyInvestors } = this.data;

            this.innerHTML = `
                <div class="funding-section">
                    <div class="funding-overview">
                        ${totalRaised ? `
                            <div class="funding-stat">
                                <div class="funding-stat-label">Total Raised</div>
                                <div class="funding-stat-value">${totalRaised}</div>
                            </div>
                        ` : ''}
                        
                        ${latestRound ? `
                            <div class="funding-stat">
                                <div class="funding-stat-label">Latest Round</div>
                                <div class="funding-stat-value">${latestRound.amount}</div>
                                ${latestRound.date ? `<div class="funding-stat-date">${latestRound.date}</div>` : ''}
                            </div>
                        ` : ''}
                        
                        ${valuation ? `
                            <div class="funding-stat">
                                <div class="funding-stat-label">Valuation</div>
                                <div class="funding-stat-value">${valuation}</div>
                            </div>
                        ` : ''}
                        
                        ${status ? `
                            <div class="funding-stat">
                                <div class="funding-stat-label">Status</div>
                                <div class="funding-stat-value">${status}</div>
                            </div>
                        ` : ''}
                    </div>

                    ${rounds && rounds.length > 0 ? `
                        <div class="funding-rounds">
                            <h3>Funding Rounds</h3>
                            <div class="timeline">
                                ${rounds.map(round => {
                // Extract year from date (handles formats like "July 2017", "2017", "March 2020")
                const year = round.date.match(/\d{4}/)?.[0] || round.date;
                return `
                                    <div class="milestone-item">
                                        <div class="milestone-year">${year}</div>
                                        <div class="milestone-content">
                                            <h4>${round.series} - ${round.amount}</h4>
                                            ${round.date !== year ? `<div style="color: var(--text-secondary); font-size: 0.9rem; margin-bottom: 0.5rem;">${round.date}</div>` : ''}
                                            ${round.valuation ? `<div style="color: var(--text-secondary); margin-bottom: 0.5rem;">Valuation: ${round.valuation}</div>` : ''}
                                            ${round.leadInvestors && round.leadInvestors.length > 0 ? `
                                                <div style="color: var(--text-secondary); margin-bottom: 0.5rem;">
                                                    <strong>Lead:</strong> ${round.leadInvestors.join(', ')}
                                                </div>
                                            ` : ''}
                                            ${round.description ? `<p>${round.description}</p>` : ''}
                                        </div>
                                    </div>
                                `}).join('')}
                            </div>
                        </div>
                    ` : ''}

                    ${keyInvestors && keyInvestors.length > 0 ? `
                        <div class="key-investors">
                            <h3>Key Investors</h3>
                            <div class="investors-grid">
                                ${keyInvestors.map(investor => `
                                    <div class="investor-card">
                                        <div class="investor-name">${investor.name}</div>
                                        <div class="investor-type">${investor.type}</div>
                                        ${investor.description ? `<p>${investor.description}</p>` : ''}
                                    </div>
                                `).join('')}
                            </div>
                        </div>
                    ` : ''}
                </div>
            `;
        }
    }

    // ============================================================================
    // Leadership Component
    // ============================================================================

    class LeadershipSection extends ProfileSectionComponent {
        render() {
            const { introduction, leaders, boardMembers } = this.data;

            this.innerHTML = `
                <div class="leadership-section">
                    ${introduction ? `<p class="leadership-intro">${introduction}</p>` : ''}
                    
                    ${leaders && leaders.length > 0 ? `
                        <div class="leaders-grid">
                            ${leaders.map(leader => `
                                <div class="leader-card">
                                    <div class="leader-header">
                                        <div class="leader-avatar">${this.getInitials(leader.name)}</div>
                                        <div class="leader-info">
                                            <h3 class="leader-name">${leader.name}</h3>
                                            <div class="leader-title">${leader.title}</div>
                                            ${leader.tenure ? `<div class="leader-tenure">${leader.tenure}</div>` : ''}
                                        </div>
                                    </div>
                                    ${leader.background ? `<p class="leader-background">${leader.background}</p>` : ''}
                                    ${leader.achievements && leader.achievements.length > 0 ? `
                                        <div class="leader-achievements">
                                            <strong>Key Achievements:</strong>
                                            <ul>
                                                ${leader.achievements.map(ach => `<li>${ach}</li>`).join('')}
                                            </ul>
                                        </div>
                                    ` : ''}
                                    ${leader.quote ? `
                                        <div class="leader-quote">
                                            <span class="quote-icon">"</span>
                                            <p>${leader.quote}</p>
                                        </div>
                                    ` : ''}
                                    ${leader.linkedin ? `
                                        <a href="${leader.linkedin}" target="_blank" rel="noopener noreferrer" class="leader-linkedin">
                                            🔗 LinkedIn Profile
                                        </a>
                                    ` : ''}
                                </div>
                            `).join('')}
                        </div>
                    ` : ''}

                    ${boardMembers && boardMembers.length > 0 ? `
                        <div class="board-members">
                            <h3>Board Members</h3>
                            <div class="board-grid">
                                ${boardMembers.map(member => `
                                    <div class="board-member">
                                        <div class="board-member-name">${member.name}</div>
                                        <div class="board-member-role">${member.role}</div>
                                        ${member.affiliation ? `<div class="board-member-affiliation">${member.affiliation}</div>` : ''}
                                    </div>
                                `).join('')}
                            </div>
                        </div>
                    ` : ''}
                </div>
            `;
        }

        getInitials(name) {
            return name
                .split(' ')
                .map(part => part[0])
                .join('')
                .toUpperCase()
                .substring(0, 2);
        }
    }

    // ============================================================================
    // Office Locations Component
    // ============================================================================

    class OfficeLocationsSection extends ProfileSectionComponent {
        render() {
            const { headquarters, offices, remotePresence } = this.data;

            this.innerHTML = `
                <div class="office-locations-section">
                    ${headquarters ? `
                        <div class="headquarters-card">
                            <div class="location-badge">🏢 Headquarters</div>
                            <h3 class="location-city">${headquarters.city}, ${headquarters.country}</h3>
                            ${headquarters.address ? `<p class="location-address">${headquarters.address}</p>` : ''}
                            ${headquarters.size ? `<div class="location-size">👥 ${headquarters.size}</div>` : ''}
                            ${headquarters.description ? `<p class="location-description">${headquarters.description}</p>` : ''}
                        </div>
                    ` : ''}

                    ${offices && offices.length > 0 ? `
                        <div class="offices-grid">
                            ${offices.map(office => `
                                <div class="office-card">
                                    <div class="location-header">
                                        <h4 class="location-city">${office.city}, ${office.country}</h4>
                                        ${office.type ? `<span class="location-type-badge">${office.type}</span>` : ''}
                                    </div>
                                    ${office.address ? `<p class="location-address">${office.address}</p>` : ''}
                                    ${office.size ? `<div class="location-size">👥 ${office.size}</div>` : ''}
                                    ${office.description ? `<p class="location-description">${office.description}</p>` : ''}
                                </div>
                            `).join('')}
                        </div>
                    ` : ''}

                    ${remotePresence ? `
                        <div class="remote-presence">
                            <h3>🌍 Remote Work</h3>
                            <p>${remotePresence}</p>
                        </div>
                    ` : ''}
                </div>
            `;
        }
    }

    // ============================================================================
    // Perks and Benefits Component
    // ============================================================================

    class PerksBenefitsSection extends ProfileSectionComponent {
        render() {
            const { introduction, categories, standoutBenefits } = this.data;

            this.innerHTML = `
                <div class="perks-benefits-section">
                    ${introduction ? `<p class="perks-intro">${introduction}</p>` : ''}
                    
                    ${standoutBenefits && standoutBenefits.length > 0 ? `
                        <div class="standout-benefits">
                            <h3>✨ Standout Benefits</h3>
                            <div class="standout-grid">
                                ${standoutBenefits.map(benefit => `
                                    <div class="standout-benefit">
                                        <div class="benefit-icon">${benefit.icon || '🌟'}</div>
                                        <div class="benefit-content">
                                            <h4>${benefit.name}</h4>
                                            <p>${benefit.description}</p>
                                        </div>
                                    </div>
                                `).join('')}
                            </div>
                        </div>
                    ` : ''}

                    ${categories && categories.length > 0 ? `
                        <div class="benefits-categories">
                            ${categories.map(category => `
                                <div class="benefit-category">
                                    <div class="category-header">
                                        <span class="category-icon">${category.icon || '📦'}</span>
                                        <h3>${category.category}</h3>
                                    </div>
                                    <div class="benefits-list">
                                        ${category.benefits.map(benefit => `
                                            <div class="benefit-item ${benefit.highlight ? 'highlight' : ''}">
                                                <div class="benefit-name">${benefit.name}</div>
                                                <div class="benefit-description">${benefit.description}</div>
                                            </div>
                                        `).join('')}
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                    ` : ''}
                </div>
            `;
        }
    }

    // ============================================================================
    // Remote Policy Component
    // ============================================================================

    class RemotePolicySection extends ProfileSectionComponent {
        render() {
            const { model, summary, workLocation, equipment, schedule, tools, culture } = this.data;

            this.innerHTML = `
                <div class="remote-policy-section">
                    <div class="policy-header">
                        ${model ? `<div class="policy-model">${model} Model</div>` : ''}
                        ${summary ? `<p class="policy-summary">${summary}</p>` : ''}
                    </div>

                    ${workLocation ? `
                        <div class="policy-block">
                            <h3>📍 Work Location</h3>
                            <div class="policy-details">
                                ${workLocation.policy ? `
                                    <div class="policy-item">
                                        <span class="policy-label">Policy:</span>
                                        <span class="policy-value">${workLocation.policy}</span>
                                    </div>
                                ` : ''}
                                ${workLocation.officeExpectation ? `
                                    <div class="policy-item">
                                        <span class="policy-label">Office Expectation:</span>
                                        <span class="policy-value">${workLocation.officeExpectation}</span>
                                    </div>
                                ` : ''}
                                ${workLocation.workFromAnywhere ? `
                                    <div class="policy-item">
                                        <span class="policy-label">Work from Anywhere:</span>
                                        <span class="policy-value">${workLocation.workFromAnywhere}</span>
                                    </div>
                                ` : ''}
                            </div>
                        </div>
                    ` : ''}

                    ${equipment ? `
                        <div class="policy-block">
                            <h3>💻 Equipment & Setup</h3>
                            <div class="policy-details">
                                ${equipment.budget ? `
                                    <div class="policy-item">
                                        <span class="policy-label">Budget:</span>
                                        <span class="policy-value">${equipment.budget}</span>
                                    </div>
                                ` : ''}
                                ${equipment.provided ? `
                                    <div class="policy-item">
                                        <span class="policy-label">Provided:</span>
                                        <span class="policy-value">${equipment.provided}</span>
                                    </div>
                                ` : ''}
                                ${equipment.support ? `
                                    <div class="policy-item">
                                        <span class="policy-label">Support:</span>
                                        <span class="policy-value">${equipment.support}</span>
                                    </div>
                                ` : ''}
                            </div>
                        </div>
                    ` : ''}

                    ${schedule ? `
                        <div class="policy-block">
                            <h3>⏰ Schedule & Hours</h3>
                            <div class="policy-details">
                                ${schedule.flexibility ? `
                                    <div class="policy-item">
                                        <span class="policy-label">Flexibility:</span>
                                        <span class="policy-value">${schedule.flexibility}</span>
                                    </div>
                                ` : ''}
                                ${schedule.coreHours ? `
                                    <div class="policy-item">
                                        <span class="policy-label">Core Hours:</span>
                                        <span class="policy-value">${schedule.coreHours}</span>
                                    </div>
                                ` : ''}
                                ${schedule.asynchronous ? `
                                    <div class="policy-item">
                                        <span class="policy-label">Async Work:</span>
                                        <span class="policy-value">${schedule.asynchronous}</span>
                                    </div>
                                ` : ''}
                            </div>
                        </div>
                    ` : ''}

                    ${tools ? `
                        <div class="policy-block">
                            <h3>🛠️ Tools & Collaboration</h3>
                            <div class="policy-details">
                                ${tools.communication ? `
                                    <div class="policy-item">
                                        <span class="policy-label">Communication:</span>
                                        <span class="policy-value">${tools.communication}</span>
                                    </div>
                                ` : ''}
                                ${tools.collaboration ? `
                                    <div class="policy-item">
                                        <span class="policy-label">Collaboration:</span>
                                        <span class="policy-value">${tools.collaboration}</span>
                                    </div>
                                ` : ''}
                                ${tools.socializing ? `
                                    <div class="policy-item">
                                        <span class="policy-label">Socializing:</span>
                                        <span class="policy-value">${tools.socializing}</span>
                                    </div>
                                ` : ''}
                            </div>
                        </div>
                    ` : ''}

                    ${culture ? `
                        <div class="policy-block culture-block">
                            <h3>🤝 Culture & Connection</h3>
                            ${culture.inPerson ? `<p><strong>In-Person:</strong> ${culture.inPerson}</p>` : ''}
                            ${culture.remoteCulture ? `<p><strong>Remote Culture:</strong> ${culture.remoteCulture}</p>` : ''}
                            ${culture.inclusion ? `<p><strong>Inclusion:</strong> ${culture.inclusion}</p>` : ''}
                        </div>
                    ` : ''}
                </div>
            `;
        }
    }

    // ============================================================================
    // Register Components
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
