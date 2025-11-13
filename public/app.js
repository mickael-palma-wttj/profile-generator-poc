/**
 * Profile Generator - Main Application JavaScript
 * Handles form submission, progress tracking, SSE streaming, and clipboard functionality
 */

(function () {
    'use strict';

    // ============================================================================
    // Configuration & Constants
    // ============================================================================

    const CONFIG = {
        sectionOrder: [
            'file_analysis',            // File reference analysis (if files uploaded)
            'company_description',      // What the company is/does
            'their_story',              // Origin and history
            'company_values',           // Culture and principles
            'key_numbers',              // Quantitative snapshot
            'funding_parser',           // Financial backing
            'leadership',               // Who runs the company
            'office_locations',         // Geographic presence
            'perks_and_benefits',       // Employee benefits
            'remote_policy'             // Work arrangements
        ],
        icons: {
            pending: '⏳',
            inProgress: '🔄',
            completed: '✅',
            failed: '❌',
            collapsed: '▶',
            expanded: '▼'
        }
    };

    // ============================================================================
    // Application State
    // ============================================================================

    const state = {
        sectionsData: {},
        totalSections: 0,
        domElements: null
    };

    // ============================================================================
    // DOM Cache
    // ============================================================================

    function cacheDOMElements() {
        state.domElements = {
            form: document.getElementById('generate-form'),
            progressContainer: document.getElementById('progress-container'),
            resultsContainer: document.getElementById('results-container'),
            sectionsProgress: document.getElementById('sections-progress'),
            profileSections: document.getElementById('profile-sections'),
            progressBarFill: document.getElementById('progress-bar-fill'),
            progressPercentage: document.getElementById('progress-percentage'),
            progressStatus: document.getElementById('progress-status'),
            stickyNav: document.getElementById('sticky-nav'),
            stickyNavItems: document.getElementById('sticky-nav-items'),
            stickyNavToggleIcon: document.getElementById('sticky-nav-toggle-icon')
        };
    }

    // ============================================================================
    // Initialization
    // ============================================================================

    /**
     * Initialize the application when DOM is loaded
     */
    function init() {
        cacheDOMElements();
        initializeEventListeners();
        initializeLanguageSelector();
        initializeStickyNav();
    }

    /**
     * Set up all event listeners
     */
    function initializeEventListeners() {
        if (state.domElements.form) {
            state.domElements.form.addEventListener('submit', handleFormSubmit);
        }
    }

    function initializeLanguageSelector() {
        const select = document.getElementById('output_language');
        const otherInput = document.getElementById('output_language_other');
        if (!select || !otherInput) return;

        select.addEventListener('change', () => {
            if (select.value === 'Other') {
                otherInput.style.display = 'block';
                otherInput.focus();
            } else {
                otherInput.style.display = 'none';
            }
        });
    }

    /**
     * Initialize sticky navigation behavior
     */
    function initializeStickyNav() {
        // Show/hide sticky nav based on scroll position
        let lastScrollY = window.scrollY;

        window.addEventListener('scroll', () => {
            const resultsContainer = state.domElements.resultsContainer;
            const stickyNav = state.domElements.stickyNav;

            if (!resultsContainer || !stickyNav) return;

            // Only show sticky nav if results are visible and user has scrolled down
            const resultsVisible = resultsContainer.style.display !== 'none';
            const scrolledDown = window.scrollY > 200;

            if (resultsVisible && scrolledDown) {
                stickyNav.style.display = 'block';
            } else {
                stickyNav.style.display = 'none';
            }

            lastScrollY = window.scrollY;
        });
    }

    // ============================================================================
    // Form Handling
    // ============================================================================


    /**
     * Handle form submission for profile generation
     */
    async function handleFormSubmit(e) {
        e.preventDefault();

        const companyName = document.getElementById('company_name').value.trim();
        const website = document.getElementById('website').value.trim();

        if (!companyName) {
            alert('Company name is required');
            return;
        }

        // Debug: Check files before UI init
        const filesInput = document.getElementById('files');
        console.log('[handleFormSubmit] filesInput:', filesInput);
        console.log('[handleFormSubmit] filesInput.files:', filesInput?.files);
        console.log('[handleFormSubmit] filesInput.files.length:', filesInput?.files?.length);

        try {
            // START ASYNC GENERATION FIRST - before clearing the form from DOM
            const data = await startAsyncGeneration(companyName, website);

            // THEN initialize UI (which may clear the form)
            initializeGenerationUI(companyName, website);

            // THEN setup SSE IMMEDIATELY to catch file_analysis progress
            // This must be done right after UI init, before any generation starts
            setupServerSentEvents(data.session_id, companyName, website);
        } catch (error) {
            handleError(error.message);
        }
    }

    /**
     * Start async profile generation
     */
    async function startAsyncGeneration(companyName, website) {
        const outputLanguageEl = document.getElementById('output_language');
        const otherEl = document.getElementById('output_language_other');
        let outputLanguage = outputLanguageEl ? outputLanguageEl.value : '';
        if (outputLanguage === 'Other' && otherEl && otherEl.value.trim()) {
            outputLanguage = otherEl.value.trim();
        }

        // Normalize common display strings to locale codes
        const LANG_MAP = {
            '': 'en',
            '🇬🇧 English (default)': 'en',
            'Français': 'fr',
            'Español': 'es',
            'Deutsch': 'de',
            'Português': 'pt',
            '中文': 'zh-CN',
            '日本語': 'ja',
            'English': 'en',
            'Fr': 'fr'
        };

        // If the value is one of the mapped display names, convert it
        if (LANG_MAP[outputLanguage]) {
            outputLanguage = LANG_MAP[outputLanguage];
        } else {
            // If user typed free-text (Other), attempt to map common names
            const normalized = outputLanguage.toString().trim().toLowerCase();
            const fuzzyMap = {
                'français': 'fr', 'francais': 'fr', 'french': 'fr',
                'español': 'es', 'espanol': 'es', 'spanish': 'es',
                'deutsch': 'de', 'german': 'de',
                'português': 'pt', 'portugues': 'pt', 'portuguese': 'pt',
                '中文': 'zh-CN', 'chinese': 'zh-CN', 'zh': 'zh-CN',
                '日本語': 'ja', 'japanese': 'ja', 'ja': 'ja',
                'italiano': 'it', 'italian': 'it',
                'العربية': 'ar', 'arabic': 'ar',
                'русский': 'ru', 'russian': 'ru'
            };

            if (fuzzyMap[normalized]) {
                outputLanguage = fuzzyMap[normalized];
            }
            // else leave as-is (backend will attempt to canonicalize)
        }

        // Build form data with files BEFORE we clear the DOM
        // This is critical because initializeGenerationUI might clear the form
        const formData = new FormData();
        formData.append('company_name', companyName);
        formData.append('website', website);
        formData.append('output_language', outputLanguage);

        // Add uploaded files if present - READ FILES BEFORE ANY DOM CHANGES
        const filesInput = document.getElementById('files');
        console.log('[startAsyncGeneration] filesInput:', filesInput);
        console.log('[startAsyncGeneration] filesInput.files:', filesInput?.files);
        console.log('[startAsyncGeneration] filesInput.files.length:', filesInput?.files?.length);

        if (filesInput && filesInput.files && filesInput.files.length > 0) {
            console.log(`[startAsyncGeneration] Adding ${filesInput.files.length} file(s) to FormData`);
            for (let i = 0; i < filesInput.files.length; i++) {
                console.log(`[startAsyncGeneration] Adding file ${i}: ${filesInput.files[i].name}`);
                formData.append('files[]', filesInput.files[i]);
            }
        } else {
            console.warn('[startAsyncGeneration] ⚠️ NO FILES SELECTED - FormData will NOT include files');
            if (!filesInput) console.warn('[startAsyncGeneration] files input element not found!');
            if (filesInput && !filesInput.files) console.warn('[startAsyncGeneration] files input has no files property!');
            if (filesInput && filesInput.files && filesInput.files.length === 0) console.warn('[startAsyncGeneration] No files in FileList - user did not select any files');
        }

        console.log('[startAsyncGeneration] FormData ready, sending to /generate/async');

        // Debug: Log what's in FormData (note: can't directly inspect FormData entries in all browsers)
        // So we'll log individual appends
        console.log('[startAsyncGeneration] FormData contents:');
        console.log('[startAsyncGeneration] - company_name:', companyName);
        console.log('[startAsyncGeneration] - website:', website);
        console.log('[startAsyncGeneration] - output_language:', outputLanguage);
        console.log('[startAsyncGeneration] - files count:', filesInput?.files?.length || 0);

        const response = await fetch('/generate/async', {
            method: 'POST',
            body: formData
            // Note: DO NOT set Content-Type header - browser will set it with boundary for multipart/form-data
        });

        console.log('[startAsyncGeneration] Response status:', response.status);
        const data = await response.json();

        if (!data.success) {
            throw new Error(data.error || 'Failed to start generation');
        }

        return data;
    }

    // ============================================================================
    // UI Management
    // ============================================================================


    /**
     * Initialize UI for generation process
     */
    function initializeGenerationUI(companyName, website) {
        const { form, progressContainer, resultsContainer, sectionsProgress, profileSections } = state.domElements;

        // Hide form, show progress
        form.parentElement.style.display = 'none';
        progressContainer.style.display = 'block';
        document.querySelector('.progress-company-name').textContent = companyName;

        const features = document.querySelector('.features');
        if (features) features.style.display = 'none';

        // Show results and populate metadata
        resultsContainer.style.display = 'block';
        updateCompanyMetadata(companyName, website);

        // Reset state
        resetState();
        sectionsProgress.innerHTML = '';
        profileSections.innerHTML = '';

        // Initialize section progress items
        CONFIG.sectionOrder.forEach(section => {
            const sectionDiv = createSectionProgressItem(section);
            sectionsProgress.appendChild(sectionDiv);
        });
    }

    /**
     * Update company metadata in results section
     */
    function updateCompanyMetadata(companyName, website) {
        const nameElement = document.getElementById('result-company-name');
        const websiteElement = document.getElementById('result-website');

        if (nameElement) nameElement.textContent = companyName;

        if (websiteElement) {
            websiteElement.innerHTML = website
                ? ` | <a href="${website}" target="_blank">${website}</a>`
                : '';
        }
    }

    /**
     * Reset application state
     */
    function resetState() {
        state.sectionsData = {};
        // Count sections: if files are uploaded, include file_analysis; otherwise just the standard sections
        state.totalSections = CONFIG.sectionOrder.length;

        // Initialize sticky nav items for all sections
        initializeStickyNavItems();
    }


    // ============================================================================
    // Server-Sent Events (SSE)
    // ============================================================================

    /**
     * Set up Server-Sent Events connection
     */
    function setupServerSentEvents(sessionId, companyName, website) {
        const eventSource = new EventSource(`/generate/stream/${sessionId}`);

        eventSource.addEventListener('section_update', (e) => {
            const update = JSON.parse(e.data);
            handleSectionUpdate(update);
        });

        eventSource.addEventListener('complete', (e) => {
            handleComplete(companyName, website);
            eventSource.close();
        });

        eventSource.addEventListener('error', (e) => {
            let error = 'An error occurred during generation';
            try {
                const errorData = JSON.parse(e.data);
                error = errorData.error || error;
            } catch (parseError) {
                // Use default error message
            }
            handleError(error);
            eventSource.close();
        });

        eventSource.onerror = () => {
            handleError('Connection lost. Please try again.');
            eventSource.close();
        };
    }


    /**
     * Create a section progress item element
     */
    function createSectionProgressItem(sectionName) {
        const div = document.createElement('div');
        div.className = 'section-progress-item';
        div.id = `section-${sectionName}`;
        div.style.cursor = 'pointer';
        div.title = 'Click to scroll to section';
        div.innerHTML = `
      <div class="section-status-icon">${CONFIG.icons.pending}</div>
      <div class="section-info">
        <div class="section-name">${humanizeSectionName(sectionName)}</div>
        <div class="section-status">Pending...</div>
      </div>
    `;

        // Add click handler to scroll to the generated section
        div.addEventListener('click', () => scrollToSection(sectionName));

        return div;
    }

    /**
     * Scroll to a specific generated section
     */
    function scrollToSection(sectionName) {
        const sectionElement = document.getElementById(`result-section-${sectionName}`);
        if (!sectionElement) return;

        // Calculate offset to account for sticky nav
        const stickyNav = state.domElements.stickyNav;
        const stickyNavHeight = stickyNav && stickyNav.style.display !== 'none'
            ? stickyNav.offsetHeight + 20  // Add 20px extra padding
            : 0;

        // Get element position
        const elementPosition = sectionElement.getBoundingClientRect().top;
        const offsetPosition = elementPosition + window.pageYOffset - stickyNavHeight;

        // Smooth scroll to position
        window.scrollTo({
            top: offsetPosition,
            behavior: 'smooth'
        });

        // Add a temporary highlight effect
        sectionElement.style.transition = 'background-color 0.3s ease';
        const originalBg = sectionElement.style.backgroundColor;
        sectionElement.style.backgroundColor = 'rgba(52, 152, 219, 0.1)';

        setTimeout(() => {
            sectionElement.style.backgroundColor = originalBg;
        }, 1000);
    }


    // ============================================================================
    // Section Update Handling
    // ============================================================================

    /**
     * Handle section update from SSE stream
     */
    function handleSectionUpdate(update) {
        const { section_name, status, content, raw_content, humanized_name, error } = update;

        if (raw_content && status === 'completed') {
            console.log(`📋 Raw content available for ${section_name}: ${raw_content.length} chars`);
        }

        state.sectionsData[section_name] = { status, content, raw_content, humanized_name, error };

        const sectionDiv = document.getElementById(`section-${section_name}`);
        if (!sectionDiv) return;

        updateSectionUI(sectionDiv, status, content, section_name, humanized_name, error);
        updateProgress();
    }

    /**
     * Update section UI based on status
     */
    function updateSectionUI(sectionDiv, status, content, sectionName, humanizedName, error) {
        const icon = sectionDiv.querySelector('.section-status-icon');
        const statusText = sectionDiv.querySelector('.section-status');

        const statusMap = {
            pending: {
                icon: CONFIG.icons.pending,
                text: 'Pending...',
                classes: { add: ['pending'], remove: ['in-progress', 'completed', 'failed', 'skipped'] }
            },
            analyzing: {
                icon: CONFIG.icons.inProgress,
                text: 'Analyzing files...',
                classes: { add: ['in-progress'], remove: ['pending', 'completed', 'failed', 'skipped'] }
            },
            in_progress: {
                icon: CONFIG.icons.inProgress,
                text: 'Generating...',
                classes: { add: ['in-progress'], remove: ['pending', 'completed', 'failed', 'skipped'] }
            },
            completed: {
                icon: CONFIG.icons.completed,
                text: 'Completed',
                classes: { add: ['completed'], remove: ['pending', 'in-progress', 'failed', 'skipped'] },
                callback: () => content && addSectionToResults(sectionName, humanizedName, content)
            },
            failed: {
                icon: CONFIG.icons.failed,
                text: `Failed: ${error || 'Unknown error'}`,
                classes: { add: ['failed'], remove: ['pending', 'in-progress', 'completed', 'skipped'] }
            },
            skipped: {
                icon: CONFIG.icons.pending,
                text: 'Skipped (no files)',
                classes: { add: ['skipped'], remove: ['pending', 'in-progress', 'completed', 'failed'] }
            }
        };

        const statusConfig = statusMap[status];
        if (!statusConfig) return;

        icon.textContent = statusConfig.icon;
        statusText.textContent = statusConfig.text;
        sectionDiv.classList.remove(...statusConfig.classes.remove);
        sectionDiv.classList.add(...statusConfig.classes.add);

        // Update sticky nav item
        updateStickyNavItem(sectionName, humanizedName, status);

        if (statusConfig.callback) {
            statusConfig.callback();
        }
    }


    // ============================================================================
    // Progress Tracking
    // ============================================================================

    /**
     * Update progress bar and status
     */
    function updateProgress() {
        const sections = Object.values(state.sectionsData);
        const completed = sections.filter(s => s.status === 'completed').length;
        const failed = sections.filter(s => s.status === 'failed').length;
        const inProgress = sections.filter(s => s.status === 'in_progress').length;

        const percentage = Math.round((completed / state.totalSections) * 100);

        const { progressBarFill, progressPercentage, progressStatus } = state.domElements;
        progressBarFill.style.width = `${percentage}%`;
        progressPercentage.textContent = `${percentage}%`;

        progressStatus.textContent = getProgressStatusText(completed, failed, inProgress);
    }

    /**
     * Get progress status text based on current state
     */
    function getProgressStatusText(completed, failed, inProgress) {
        if (inProgress > 0) {
            return `${completed}/${state.totalSections} sections completed`;
        }
        if (completed === state.totalSections) {
            return 'All sections completed!';
        }
        return `${completed}/${state.totalSections} completed, ${failed} failed`;
    }


    // ============================================================================
    // Results Display
    // ============================================================================

    /**
     * Add a completed section to the results display
     */
    function addSectionToResults(sectionName, humanizedName, content) {
        if (document.getElementById(`result-section-${sectionName}`)) {
            return;
        }

        const sectionCard = createSectionCard(sectionName, humanizedName, content);

        // Insert section in the correct order based on CONFIG.sectionOrder
        insertSectionInOrder(sectionCard, sectionName);

        if (state.domElements.resultsContainer.style.display === 'none') {
            state.domElements.resultsContainer.style.display = 'block';
        }

        // Update sticky nav when new section is added
        updateStickyNavItem(sectionName, humanizedName, 'completed');
    }

    /**
     * Insert a section card in the correct position to maintain order
     */
    function insertSectionInOrder(sectionCard, sectionName) {
        const profileSections = state.domElements.profileSections;
        const sectionIndex = CONFIG.sectionOrder.indexOf(sectionName);

        // Find the correct position to insert this section
        let insertBeforeElement = null;

        for (let i = sectionIndex + 1; i < CONFIG.sectionOrder.length; i++) {
            const nextSectionName = CONFIG.sectionOrder[i];
            const nextElement = document.getElementById(`result-section-${nextSectionName}`);

            if (nextElement) {
                insertBeforeElement = nextElement;
                break;
            }
        }

        if (insertBeforeElement) {
            profileSections.insertBefore(sectionCard, insertBeforeElement);
        } else {
            profileSections.appendChild(sectionCard);
        }
    }

    /**
     * Process section content - strip code fences and detect HTML
     */
    function processSectionContent(content) {
        if (!content) return '';

        let cleaned = content.trim();

        // Strip markdown code fences if present (```html or ```)
        if (cleaned.match(/^```(?:html|HTML)?\s*[\r\n]/m)) {
            cleaned = cleaned.replace(/^```(?:html|HTML)?\s*[\r\n]+/m, '');
            cleaned = cleaned.replace(/[\r\n\s]*```[\r\n\s]*$/m, '');
            cleaned = cleaned.trim();
        }

        // Check if content is HTML (starts with < and contains >)
        const isHTML = cleaned.startsWith('<') && cleaned.includes('>');

        if (isHTML) {
            // Return HTML as-is
            return cleaned;
        } else {
            // For markdown content, we need to format it
            // Since we don't have a markdown parser in JS, return as-is with <pre>
            return `<pre style="white-space: pre-wrap; word-wrap: break-word;">${escapeHtml(cleaned)}</pre>`;
        }
    }

    /**
     * Escape HTML special characters
     */
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    /**
     * Create a section card element
     */
    function createSectionCard(sectionName, humanizedName, content) {
        const card = document.createElement('div');
        card.className = 'card section-card';
        card.id = `result-section-${sectionName}`;

        // Process content to strip code fences and handle HTML
        const processedContent = processSectionContent(content);

        card.innerHTML = `
      <div class="section-header section-header-toggle" onclick="window.profileGenerator.toggleSection('${sectionName}')">
        <h2>${humanizedName || humanizeSectionName(sectionName)}</h2>
        <div class="section-header-right">
          <button class="btn-copy" onclick="window.profileGenerator.copyRawContent('${sectionName}', event)" title="Copy raw content to clipboard">
            📋
          </button>
          <span class="section-badge">${sectionName}</span>
          <span class="section-toggle-icon" id="toggle-icon-${sectionName}">${CONFIG.icons.expanded}</span>
        </div>
      </div>
      <div class="section-content" id="content-${sectionName}">
        ${processedContent}
      </div>
    `;
        return card;
    }


    /**
     * Handle completion of profile generation
     */
    function handleComplete(companyName, website) {
        state.domElements.progressStatus.textContent = 'Profile generation complete!';

        setTimeout(() => {
            state.domElements.resultsContainer.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }, 500);
    }

    /**
     * Handle errors during generation
     */
    function handleError(error) {
        state.domElements.progressContainer.innerHTML = `
      <div class="alert alert-error">
        <strong>Error:</strong> ${error}
      </div>
      <button class="btn btn-primary" onclick="window.location.reload()">
        Try Again
      </button>
    `;
    }

    // ============================================================================
    // Utility Functions
    // ============================================================================

    /**
     * Convert snake_case section name to human readable format
     */
    function humanizeSectionName(sectionName) {
        return sectionName
            .replace(/_/g, ' ')
            .split(' ')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
    }


    // ============================================================================
    // Sticky Navigation Management
    // ============================================================================

    /**
     * Initialize sticky nav items for all sections
     */
    function initializeStickyNavItems() {
        if (!state.domElements.stickyNavItems) return;

        state.domElements.stickyNavItems.innerHTML = '';

        CONFIG.sectionOrder.forEach(sectionName => {
            const sectionData = state.sectionsData[sectionName];
            const humanizedName = sectionData?.humanized_name || humanizeSectionName(sectionName);
            const status = sectionData?.status || 'pending';

            const navItem = createStickyNavItem(sectionName, humanizedName, status);
            state.domElements.stickyNavItems.appendChild(navItem);
        });
    }

    /**
     * Create a sticky nav item element
     */
    function createStickyNavItem(sectionName, humanizedName, status) {
        const item = document.createElement('div');
        item.className = `sticky-nav-item ${status}`;
        item.id = `sticky-nav-${sectionName}`;
        item.title = `Jump to ${humanizedName}`;

        const icon = getStatusIcon(status);

        item.innerHTML = `
            <span class="sticky-nav-item-icon">${icon}</span>
            <span class="sticky-nav-item-text">${humanizedName}</span>
        `;

        item.addEventListener('click', () => {
            scrollToSection(sectionName);
            highlightActiveStickyNavItem(sectionName);
        });

        return item;
    }

    /**
     * Update a sticky nav item's status
     */
    function updateStickyNavItem(sectionName, humanizedName, status) {
        let navItem = document.getElementById(`sticky-nav-${sectionName}`);

        if (!navItem && state.domElements.stickyNavItems) {
            navItem = createStickyNavItem(sectionName, humanizedName, status);
            state.domElements.stickyNavItems.appendChild(navItem);
        } else if (navItem) {
            navItem.className = `sticky-nav-item ${status}`;
            const icon = navItem.querySelector('.sticky-nav-item-icon');
            if (icon) {
                icon.textContent = getStatusIcon(status);
            }
        }
    }

    /**
     * Get icon for section status
     */
    function getStatusIcon(status) {
        const iconMap = {
            pending: CONFIG.icons.pending,
            in_progress: CONFIG.icons.inProgress,
            completed: CONFIG.icons.completed,
            failed: CONFIG.icons.failed
        };
        return iconMap[status] || CONFIG.icons.pending;
    }

    /**
     * Highlight the active sticky nav item
     */
    function highlightActiveStickyNavItem(sectionName) {
        // Remove active class from all items
        document.querySelectorAll('.sticky-nav-item').forEach(item => {
            item.classList.remove('active');
        });

        // Add active class to clicked item
        const activeItem = document.getElementById(`sticky-nav-${sectionName}`);
        if (activeItem) {
            activeItem.classList.add('active');

            // Remove active class after animation
            setTimeout(() => {
                activeItem.classList.remove('active');
            }, 1500);
        }
    }

    /**
     * Toggle sticky nav expanded/collapsed
     */
    function toggleStickyNav() {
        const stickyNav = state.domElements.stickyNav;
        const toggleIcon = state.domElements.stickyNavToggleIcon;

        if (!stickyNav || !toggleIcon) return;

        stickyNav.classList.toggle('collapsed');
        toggleIcon.textContent = stickyNav.classList.contains('collapsed')
            ? CONFIG.icons.collapsed
            : CONFIG.icons.expanded;
    }

    // ============================================================================
    // Section Visibility Controls
    // ============================================================================

    /**
     * Toggle visibility of a section
     */
    function toggleSection(sectionName) {
        const content = document.getElementById(`content-${sectionName}`);
        const icon = document.getElementById(`toggle-icon-${sectionName}`);

        if (!content || !icon) return;

        const isHidden = content.style.display === 'none';
        content.style.display = isHidden ? 'block' : 'none';
        icon.textContent = isHidden ? CONFIG.icons.expanded : CONFIG.icons.collapsed;
        icon.classList.toggle('collapsed', !isHidden);
    }

    /**
     * Toggle all sections expanded/collapsed
     */
    function toggleAllSections() {
        const allContents = document.querySelectorAll('.section-content');
        const allIcons = document.querySelectorAll('.section-toggle-icon');
        const anyExpanded = Array.from(allContents).some(content => content.style.display !== 'none');

        allContents.forEach(content => {
            content.style.display = anyExpanded ? 'none' : 'block';
        });

        allIcons.forEach(icon => {
            icon.textContent = anyExpanded ? CONFIG.icons.collapsed : CONFIG.icons.expanded;
            icon.classList.toggle('collapsed', anyExpanded);
        });
    }


    // ============================================================================
    // Clipboard Operations
    // ============================================================================

    /**
     * Copy raw content of a section to clipboard
     */
    function copyRawContent(sectionName, event) {
        event.stopPropagation();

        const button = event.target;
        const originalText = button.textContent;
        const rawContent = getRawContentForSection(sectionName);

        if (!rawContent.trim()) {
            showCopyError(button, originalText);
            return;
        }

        copyToClipboard(rawContent)
            .then(() => showCopySuccess(button, originalText))
            .catch((err) => {
                console.error('Failed to copy:', err);
                showCopyError(button, originalText);
            });
    }

    /**
     * Get raw content for a section with fallback priority
     */
    function getRawContentForSection(sectionName) {
        const sectionData = state.sectionsData[sectionName];

        if (sectionData?.raw_content) {
            console.log(`📋 Copying raw API content for ${sectionName}: ${sectionData.raw_content.length} chars`);
            return sectionData.raw_content;
        }

        if (sectionData?.content) {
            console.log(`📋 Copying formatted content for ${sectionName} (raw not available)`);
            return sectionData.content;
        }

        const contentElement = document.getElementById(`content-${sectionName}`);
        if (contentElement) {
            const domContent = contentElement.textContent || contentElement.innerText || '';
            console.log(`📋 Copying DOM text content for ${sectionName} (fallback)`);
            return domContent;
        }

        return '';
    }


    /**
     * Generic clipboard copy function with fallback
     */
    async function copyToClipboard(text) {
        if (navigator.clipboard && navigator.clipboard.writeText) {
            return navigator.clipboard.writeText(text);
        }

        return fallbackCopyToClipboard(text);
    }

    /**
     * Fallback copy method for older browsers
     */
    function fallbackCopyToClipboard(text) {
        return new Promise((resolve, reject) => {
            const textarea = document.createElement('textarea');
            textarea.value = text;
            textarea.style.position = 'fixed';
            textarea.style.opacity = '0';
            textarea.style.pointerEvents = 'none';
            document.body.appendChild(textarea);

            try {
                textarea.select();
                textarea.setSelectionRange(0, textarea.value.length);
                const success = document.execCommand('copy');

                if (success) {
                    resolve();
                } else {
                    reject(new Error('execCommand copy failed'));
                }
            } catch (err) {
                reject(err);
            } finally {
                document.body.removeChild(textarea);
            }
        });
    }

    /**
     * Show visual feedback for successful copy
     */
    function showCopySuccess(button, originalText) {
        updateButtonState(button, '✅', 'var(--success-color)', originalText);
    }

    /**
     * Show visual feedback for copy error
     */
    function showCopyError(button, originalText) {
        updateButtonState(button, '❌', 'var(--error-color)', originalText);
    }

    /**
     * Update button state with timeout to restore original
     */
    function updateButtonState(button, text, color, originalText, duration = 2000) {
        button.textContent = text;
        button.style.color = color;
        setTimeout(() => {
            button.textContent = originalText;
            button.style.color = '';
        }, duration);
    }


    /**
     * Copy static profile to clipboard (used in profile.erb)
     */
    function copyStaticProfile() {
        const sections = document.querySelectorAll('.section-card');
        const companyNameEl = document.querySelector('h1');
        const companyName = companyNameEl ? companyNameEl.textContent.replace('🏢 ', '') : 'Company Profile';

        let text = `${companyName} - Company Profile\n\n`;

        sections.forEach(section => {
            const title = section.querySelector('h2')?.textContent || '';
            const content = section.querySelector('.section-content')?.textContent.trim() || '';
            if (title && content) {
                text += `${title}\n${'='.repeat(title.length)}\n${content}\n\n`;
            }
        });

        copyToClipboard(text)
            .then(() => alert('Profile copied to clipboard!'))
            .catch((err) => {
                console.error('Failed to copy:', err);
                alert('Failed to copy to clipboard');
            });
    }


    /**
     * Copy all content to clipboard as markdown document (used in index.erb)
     */
    function copyAllContent() {
        const button = document.getElementById('copy-all-btn');
        if (!button) return;

        const originalText = button.textContent;
        const allContent = buildMarkdownContent();

        if (!allContent.trim()) {
            updateButtonState(button, '❌ No content', 'var(--error-color)', originalText);
            return;
        }

        copyToClipboard(allContent)
            .then(() => updateButtonState(button, '✅ Copied!', 'var(--success-color)', originalText))
            .catch((err) => {
                console.error('Failed to copy all content:', err);
                updateButtonState(button, '❌ Failed', 'var(--error-color)', originalText);
            });
    }

    /**
     * Build markdown content from all sections
     */
    function buildMarkdownContent() {
        const companyNameEl = document.getElementById('result-company-name');
        const websiteEl = document.getElementById('result-website');

        const companyName = companyNameEl?.textContent || 'Company';
        const website = websiteEl?.textContent.replace(' | ', '').trim() || '';

        let content = `# ${companyName} - Company Profile\n`;
        if (website) {
            content += `Website: ${website}\n`;
        }
        content += `Generated: ${new Date().toLocaleDateString()}\n\n`;

        CONFIG.sectionOrder.forEach(sectionName => {
            const sectionData = state.sectionsData[sectionName];
            if (sectionData?.status === 'completed') {
                const humanizedName = sectionData.humanized_name || humanizeSectionName(sectionName);
                const contentToUse = sectionData.raw_content || sectionData.content;

                if (contentToUse) {
                    content += `## ${humanizedName}\n\n${contentToUse}\n\n---\n\n`;
                }
            }
        });

        return content;
    }

    // ============================================================================
    // Public API (Global Exposure)
    // ============================================================================

    // Expose functions that are called from onclick handlers in HTML
    window.profileGenerator = {
        toggleSection,
        toggleAllSections,
        scrollToSection,
        toggleStickyNav,
        copyRawContent,
        copyStaticProfile: copyStaticProfile,  // Used in profile.erb
        copyAllContent  // Used in index.erb
    };

    // For backward compatibility with old inline onclick handlers
    window.toggleSection = toggleSection;
    window.toggleAllSections = toggleAllSections;
    window.copyRawContent = copyRawContent;
    window.copyToClipboard = copyStaticProfile;
    window.copyAllContent = copyAllContent;

    // ============================================================================
    // Bootstrap Application
    // ============================================================================

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
