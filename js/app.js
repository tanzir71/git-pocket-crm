/**
 * PocketCRM - Main Application Controller
 */

// Helper to format timestamps
function formatTime(isoString) {
  const d = new Date(isoString);
  const now = new Date();
  
  const isToday = d.toDateString() === now.toDateString();
  const isYesterday = new Date(now.setDate(now.getDate() - 1)).toDateString() === d.toDateString();
  
  const timeStr = d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  
  if (isToday) return `Today ${timeStr}`;
  if (isYesterday) return `Yesterday ${timeStr}`;
  
  return `${d.toLocaleDateString([], { month: 'short', day: 'numeric' })} ${timeStr}`;
}

const App = {
  db: null,
  currentView: 'home',
  activeContactId: null,
  activeEnrichTab: 'social',
  tempBackupData: null,
  
  // Voice Recording Simulator state
  isRecordingVoice: false,
  recordTimer: null,
  recordSeconds: 0,
  
  // Scheduler Dispatch Simulation interval
  schedulerInterval: null,
  secondsToDispatch: 300, // 5 minutes

  // Active Sorting Option
  currentSortKey: 'name',
  sortAscending: true,

  async init() {
    console.log('Initializing PocketCRM App Shell...');
    
    // 1. Open Database & Seed Mock Data
    try {
      this.db = await window.PocketDB.open();
      console.log('PocketDB initialized successfully.');
    } catch (err) {
      console.error('Failed to open PocketDB:', err);
      this.showNotification('Error initializing database offline.', 'error');
      return;
    }

    // 2. Setup Router Event Listeners
    window.addEventListener('popstate', (e) => {
      if (e.state && e.state.view) {
        this.navigateTo(e.state.view, e.state.contactId, false);
      }
    });

    // 3. Register Key Listeners (Ctrl + K shortcut for search)
    document.addEventListener('keydown', (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        const searchBar = document.getElementById('global-search');
        if (searchBar) {
          this.navigateTo('home');
          searchBar.focus();
        }
      }
    });

    // 4. Initialize Core Views
    this.refreshAllData();
    this.initSchedulerDispatcher();
    
    // Initialize Share Sheet simulation default
    window.ShareSheet.init();

    // Initialize Autocomplete search
    this.initQuickActionAutocomplete();
    
    console.log('PocketCRM UI Loaded and Active.');
  },

  // ROUTER CONTROLLERS
  navigateTo(viewName, contactId = null, pushState = true) {
    console.log(`Navigating to view: ${viewName}, Contact: ${contactId}`);
    this.currentView = viewName;
    this.activeContactId = contactId ? Number(contactId) : null;

    // Toggle active view states in DOM
    document.querySelectorAll('.view-pane').forEach(el => el.classList.remove('active'));
    const targetPane = document.getElementById(`view-${viewName}`);
    if (targetPane) targetPane.classList.add('active');

    // Update active indicators on navigation elements
    document.querySelectorAll('.nav-link, .sidebar-item, .mobile-nav-item').forEach(el => {
      if (el.getAttribute('data-view') === viewName) {
        el.classList.add('active');
      } else {
        el.classList.remove('active');
      }
    });

    // Handle state routing details
    if (pushState) {
      const stateObj = { view: viewName, contactId: this.activeContactId };
      const path = contactId ? `?view=${viewName}&id=${contactId}` : `?view=${viewName}`;
      window.history.pushState(stateObj, '', path);
    }

    // Custom view initializer runs
    if (viewName === 'home') {
      this.renderHomeHub();
    } else if (viewName === 'directory') {
      this.renderDirectory();
    } else if (viewName === 'thread' && contactId) {
      this.renderRelationshipThread(contactId);
    } else if (viewName === 'scheduler') {
      this.renderSchedulerHub();
    } else if (viewName === 'activities') {
      this.renderActivitiesFeed();
    }

    // Scroll to top
    window.scrollTo({ top: 0, behavior: 'instant' });
  },

  // REFRESH ENTIRE APP STATE
  async refreshAllData() {
    this.renderHomeHub();
    this.renderDirectory();
    this.renderSchedulerHub();
    this.populateContactsDropdowns();
  },

  // ================= 1. HOME HUB RENDERING =================
  async renderHomeHub() {
    const contacts = await this.db.getAllContacts();
    const timeline = await this.db.getAllTimeline();
    const tasks = await this.db.getAllTasks();
    
    // Sort contacts by activity frequencies / last contacted
    const sortedByActivity = [...contacts].sort((a, b) => {
      const timeA = a.lastContacted ? new Date(a.lastContacted) : new Date(0);
      const timeB = b.lastContacted ? new Date(b.lastContacted) : new Date(0);
      return timeB - timeA;
    });

    // RENDER BENTO GRID PINNED CONTACTS
    const pinnedContacts = sortedByActivity.filter(c => c.isPinned);
    const bentoGrid = document.getElementById('pinned-bento-grid');
    bentoGrid.innerHTML = '';

    if (pinnedContacts.length === 0) {
      bentoGrid.innerHTML = `
        <div class="bento-card bento-card-wide" style="cursor:default; grid-column: span 4; align-items:center; text-align:center;">
          <span class="material-symbols-outlined text-[36px]" style="color:var(--outline);">push_pin</span>
          <p class="bento-name" style="margin-top:8px;">No pinned contacts yet</p>
          <p class="bento-subtext">Pin relationships to pin them to this Bento board dashboard.</p>
        </div>
      `;
    } else {
      pinnedContacts.forEach((contact, idx) => {
        // First bento card is rendered WIDE for visual asymmetry
        const isWide = idx === 0;
        const colSpanClass = isWide ? 'bento-card-wide' : '';
        
        const cardHtml = `
          <div class="bento-card ${colSpanClass}" onclick="App.navigateTo('thread', ${contact.id})">
            <div class="bento-header">
              <div class="bento-avatar" style="background-color: ${contact.avatarColor || '#3525cd'};">
                ${contact.name.split(' ').map(n=>n[0]).join('').substring(0,2).toUpperCase()}
              </div>
              <span class="material-symbols-outlined bento-star active" onclick="event.stopPropagation(); App.togglePinContact(${contact.id})">push_pin</span>
            </div>
            <div class="bento-body">
              <p class="bento-name">${contact.name}</p>
              <p class="bento-subtext">${contact.category || 'General'} • ${contact.status || 'Active'}</p>
              ${isWide && contact.pinnedNote ? `<p class="bento-subtext" style="margin-top:8px; line-clamp:2; display:-webkit-box; -webkit-box-orient:vertical; overflow:hidden;">${contact.pinnedNote}</p>` : ''}
            </div>
            <div class="bento-tags">
              <span class="badge badge-outline">${contact.category || 'General'}</span>
              ${contact.lastContacted ? `<span class="badge badge-indigo">Active ${formatTime(contact.lastContacted).split(' ')[0]}</span>` : ''}
            </div>
          </div>
        `;
        bentoGrid.insertAdjacentHTML('beforeend', cardHtml);
      });
    }

    // RENDER TOP ACTIVITY ROSTER LIST
    const rosterList = document.getElementById('home-contacts-list');
    rosterList.innerHTML = '';

    const top8 = sortedByActivity.slice(0, 8);
    if (top8.length === 0) {
      rosterList.innerHTML = `<tr><td colspan="4" style="text-align:center; padding:24px;">No contacts found. Add one or sync phone contacts to start!</td></tr>`;
    } else {
      top8.forEach(c => {
        const lastActivityText = c.lastContacted ? formatTime(c.lastContacted) : 'No interaction logs';
        
        let statusBadgeClass = 'badge-indigo';
        if (c.status === 'Starred') statusBadgeClass = 'badge-rose';
        if (c.status === 'Pending') statusBadgeClass = 'badge-amber';
        
        const rowHtml = `
          <tr onclick="App.navigateTo('thread', ${c.id})">
            <td>
              <div class="contact-row-info">
                <div class="row-avatar" style="background-color: ${c.avatarColor || '#5c5f61'};">
                  ${c.name.split(' ').map(n=>n[0]).join('').substring(0,2).toUpperCase()}
                </div>
                <div>
                  <p style="font-weight: 700;">${c.name}</p>
                  <p class="text-small" style="color:var(--outline);">${c.email || 'No email saved'}</p>
                </div>
              </div>
            </td>
            <td>
              <p class="text-number">${c.phone}</p>
            </td>
            <td>
              <div class="flex-row-gap gap-sm" style="flex-wrap: wrap;">
                <span class="badge badge-outline">${c.category || 'General'}</span>
                <span class="badge ${statusBadgeClass}">${c.status || 'Active'}</span>
              </div>
            </td>
            <td style="text-align: right;">
              <p class="text-number" style="font-weight: 600;">${lastActivityText}</p>
            </td>
          </tr>
        `;
        rosterList.insertAdjacentHTML('beforeend', rowHtml);
      });
    }

    // RE-CALCULATE AND RENDER RELATIONSHIP CATEGORY FILTERS
    const filterContainer = document.getElementById('category-filters');
    // Save the Active element
    const activeFilter = filterContainer.querySelector('.filter-item.active');
    const activeCategory = activeFilter ? activeFilter.getAttribute('data-category') : 'all';

    filterContainer.innerHTML = `
      <div class="filter-item ${activeCategory === 'all' ? 'active' : ''}" data-category="all" onclick="App.filterByCategory('all')">
        <span>All Contacts</span>
        <span class="filter-count">${contacts.length}</span>
      </div>
    `;

    const categories = ['Family', 'Vendor', 'Doctor', 'Client', 'Contractor', 'Partner', 'Other'];
    categories.forEach(cat => {
      const count = contacts.filter(c => c.category === cat).length;
      const catHtml = `
        <div class="filter-item ${activeCategory === cat ? 'active' : ''}" data-category="${cat}" onclick="App.filterByCategory('${cat}')">
          <span>${cat}</span>
          <span class="filter-count">${count}</span>
        </div>
      `;
      filterContainer.insertAdjacentHTML('beforeend', catHtml);
    });

    // RENDER REMINDERS WIDGET list (Pending tasks)
    const taskList = document.getElementById('home-tasks-list');
    taskList.innerHTML = '';
    
    const pendingTasks = tasks.filter(t => !t.isCompleted).slice(0, 4);
    if (pendingTasks.length === 0) {
      taskList.innerHTML = `<p class="text-small" style="color:var(--outline); text-align:center; padding:12px;">No pending actions or reminders!</p>`;
    } else {
      pendingTasks.forEach(t => {
        const contact = contacts.find(c => c.id === t.contactId);
        const contactName = contact ? contact.name : 'Global Task';
        const isOverdue = new Date(t.dueDate) < new Date();
        const timeBadgeColor = isOverdue ? 'color: var(--rose); font-weight:700;' : 'color: var(--outline);';
        
        const taskHtml = `
          <div class="filter-item" style="cursor:default; align-items: flex-start; gap: 8px;">
            <div style="display:flex; gap:8px; align-items:flex-start;">
              <span class="material-symbols-outlined" style="cursor:pointer; color:var(--outline);" onclick="App.toggleTaskComplete(${t.id})">radio_button_unchecked</span>
              <div style="display:flex; flex-direction:column;">
                <span style="font-weight:600; font-size:13px; color:var(--on-surface);">${t.title}</span>
                <span class="text-small" style="cursor:pointer; text-decoration:underline; font-weight:500;" onclick="App.navigateTo('thread', ${t.contactId})">For: ${contactName}</span>
                <span class="text-small" style="${timeBadgeColor}">${isOverdue ? 'Overdue: ' : 'Due: '}${new Date(t.dueDate).toLocaleDateString([], {month:'short', day:'numeric'})}</span>
              </div>
            </div>
          </div>
        `;
        taskList.insertAdjacentHTML('beforeend', taskHtml);
      });
    }
  },

  // FILTER BY RELATIONSHIP CATEGORY
  async filterByCategory(category) {
    console.log(`Filtering roster list by category: ${category}`);
    
    // Toggle active classes on widgets
    document.querySelectorAll('#category-filters .filter-item').forEach(el => {
      if (el.getAttribute('data-category') === category) {
        el.classList.add('active');
      } else {
        el.classList.remove('active');
      }
    });

    const contacts = await this.db.getAllContacts();
    const filtered = category === 'all' ? contacts : contacts.filter(c => c.category === category);
    
    // Sort filtered contacts
    filtered.sort((a, b) => {
      const timeA = a.lastContacted ? new Date(a.lastContacted) : new Date(0);
      const timeB = b.lastContacted ? new Date(b.lastContacted) : new Date(0);
      return timeB - timeA;
    });

    const rosterList = document.getElementById('home-contacts-list');
    rosterList.innerHTML = '';

    if (filtered.length === 0) {
      rosterList.innerHTML = `<tr><td colspan="4" style="text-align:center; padding:24px;">No contacts in this category.</td></tr>`;
      return;
    }

    filtered.forEach(c => {
      const lastActivityText = c.lastContacted ? formatTime(c.lastContacted) : 'No interaction logs';
      let statusBadgeClass = 'badge-indigo';
      if (c.status === 'Starred') statusBadgeClass = 'badge-rose';
      if (c.status === 'Pending') statusBadgeClass = 'badge-amber';

      const rowHtml = `
        <tr onclick="App.navigateTo('thread', ${c.id})">
          <td>
            <div class="contact-row-info">
              <div class="row-avatar" style="background-color: ${c.avatarColor || '#5c5f61'};">
                ${c.name.split(' ').map(n=>n[0]).join('').substring(0,2).toUpperCase()}
              </div>
              <div>
                <p style="font-weight: 700;">${c.name}</p>
                <p class="text-small" style="color:var(--outline);">${c.email || 'No email saved'}</p>
              </div>
            </div>
          </td>
          <td>
            <p class="text-number">${c.phone}</p>
          </td>
          <td>
            <div class="flex-row-gap gap-sm" style="flex-wrap: wrap;">
              <span class="badge badge-outline">${c.category || 'General'}</span>
              <span class="badge ${statusBadgeClass}">${c.status || 'Active'}</span>
            </div>
          </td>
          <td style="text-align: right;">
            <p class="text-number" style="font-weight: 600;">${lastActivityText}</p>
          </td>
        </tr>
      `;
      rosterList.insertAdjacentHTML('beforeend', rowHtml);
    });
  },

  // TOGGLE FAVORITE / PIN STATUS
  async togglePinContact(id) {
    const contact = await this.db.getContact(id);
    const updated = await this.db.updateContact(id, { isPinned: !contact.isPinned });
    this.showNotification(`${contact.name} ${updated.isPinned ? 'pinned to bento board' : 'unpinned'}`);
    this.refreshAllData();
  },

  async toggleThreadContactFav() {
    if (!this.activeContactId) return;
    const contact = await this.db.getContact(this.activeContactId);
    const updated = await this.db.updateContact(this.activeContactId, { isFavorite: !contact.isFavorite });
    
    const starEl = document.getElementById('thread-contact-star');
    if (updated.isFavorite) {
      starEl.classList.add('active');
      this.showNotification(`Added ${contact.name} to Favorites`);
    } else {
      starEl.classList.remove('active');
      this.showNotification(`Removed ${contact.name} from Favorites`);
    }
    this.refreshAllData();
  },

  // GLOBAL SEARCH (Ctrl+K overlay dispatcher)
  async onSearch(query) {
    const q = query.trim().toUpperCase();
    const contacts = await this.db.getAllContacts();
    const timeline = await this.db.getAllTimeline();
    const rosterList = document.getElementById('home-contacts-list');
    rosterList.innerHTML = '';

    if (!q) {
      this.renderHomeHub();
      return;
    }

    // Filter contacts by name, phone, tags, email, OR their timeline content
    const matchedContactIds = new Set();
    
    // Search timeline text notes
    timeline.forEach(item => {
      if (item.content.toUpperCase().includes(q)) {
        matchedContactIds.add(item.contactId);
      }
    });

    const filtered = contacts.filter(c => {
      const matchBasic = c.name.toUpperCase().includes(q) ||
                         c.phone.toUpperCase().includes(q) ||
                         c.email.toUpperCase().includes(q) ||
                         c.category.toUpperCase().includes(q) ||
                         (c.pinnedNote && c.pinnedNote.toUpperCase().includes(q));
      return matchBasic || matchedContactIds.has(c.id);
    });

    if (filtered.length === 0) {
      rosterList.innerHTML = `<tr><td colspan="4" style="text-align:center; padding:24px; color:var(--outline);">No search matches found across CRM database.</td></tr>`;
      return;
    }

    filtered.forEach(c => {
      const lastActivityText = c.lastContacted ? formatTime(c.lastContacted) : 'No interaction logs';
      let statusBadgeClass = 'badge-indigo';
      const rowHtml = `
        <tr onclick="App.navigateTo('thread', ${c.id})">
          <td>
            <div class="contact-row-info">
              <div class="row-avatar" style="background-color: ${c.avatarColor || '#5c5f61'};">
                ${c.name.split(' ').map(n=>n[0]).join('').substring(0,2).toUpperCase()}
              </div>
              <div>
                <p style="font-weight: 700;">${c.name}</p>
                <p class="text-small" style="color:var(--outline);">${c.email || 'No email saved'}</p>
              </div>
            </div>
          </td>
          <td>
            <p class="text-number">${c.phone}</p>
          </td>
          <td>
            <div class="flex-row-gap gap-sm" style="flex-wrap: wrap;">
              <span class="badge badge-outline">${c.category || 'General'}</span>
              <span class="badge ${statusBadgeClass}">${c.status || 'Active'}</span>
            </div>
          </td>
          <td style="text-align: right;">
            <p class="text-number" style="font-weight: 600;">${lastActivityText}</p>
          </td>
        </tr>
      `;
      rosterList.insertAdjacentHTML('beforeend', rowHtml);
    });
  },

  // ================= 2. DIRECTORY RENDERING =================
  async renderDirectory() {
    let contacts = await this.db.getAllContacts();
    const listBody = document.getElementById('directory-contacts-list');
    listBody.innerHTML = '';

    // Apply Sorting logic
    contacts.sort((a, b) => {
      let valA = a[this.currentSortKey] || '';
      let valB = b[this.currentSortKey] || '';

      if (this.currentSortKey === 'lastContacted') {
        valA = valA ? new Date(valA) : new Date(0);
        valB = valB ? new Date(valB) : new Date(0);
      } else {
        valA = valA.toString().toUpperCase();
        valB = valB.toString().toUpperCase();
      }

      if (valA < valB) return this.sortAscending ? -1 : 1;
      if (valA > valB) return this.sortAscending ? 1 : -1;
      return 0;
    });

    if (contacts.length === 0) {
      listBody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding:24px;">No contacts in local database. Click Sync Phone Contacts to simulate loading logs!</td></tr>`;
      return;
    }

    contacts.forEach(c => {
      const lastActivityText = c.lastContacted ? formatTime(c.lastContacted) : 'Never';
      let statusBadgeClass = 'badge-indigo';
      if (c.status === 'Starred') statusBadgeClass = 'badge-rose';
      if (c.status === 'Pending') statusBadgeClass = 'badge-amber';

      const rowHtml = `
        <tr onclick="App.navigateTo('thread', ${c.id})">
          <td>
            <div class="contact-row-info">
              <div class="row-avatar" style="background-color: ${c.avatarColor || '#3525cd'};">
                ${c.name.split(' ').map(n=>n[0]).join('').substring(0,2).toUpperCase()}
              </div>
              <div style="font-weight: 700; color:var(--on-surface);">${c.name}</div>
            </div>
          </td>
          <td>
            <span class="text-number">${c.phone}</span>
          </td>
          <td>
            <span class="badge badge-outline">${c.category || 'General'}</span>
          </td>
          <td>
            <span class="badge ${statusBadgeClass}">${c.status || 'Active'}</span>
          </td>
          <td style="text-align: right;">
            <span class="text-number" style="font-weight: 600;">${lastActivityText}</span>
          </td>
        </tr>
      `;
      listBody.insertAdjacentHTML('beforeend', rowHtml);
    });
  },

  onDirectorySearch(val) {
    const q = val.toUpperCase().trim();
    this.db.getAllContacts().then(contacts => {
      const filtered = contacts.filter(c => 
        c.name.toUpperCase().includes(q) ||
        c.phone.toUpperCase().includes(q) ||
        c.category.toUpperCase().includes(q) ||
        (c.email && c.email.toUpperCase().includes(q))
      );
      
      const listBody = document.getElementById('directory-contacts-list');
      listBody.innerHTML = '';

      if (filtered.length === 0) {
        listBody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding:24px; color:var(--outline);">No matching directory rows.</td></tr>`;
        return;
      }

      filtered.forEach(c => {
        const lastActivityText = c.lastContacted ? formatTime(c.lastContacted) : 'Never';
        let statusBadgeClass = 'badge-indigo';
        if (c.status === 'Starred') statusBadgeClass = 'badge-rose';
        if (c.status === 'Pending') statusBadgeClass = 'badge-amber';

        const rowHtml = `
          <tr onclick="App.navigateTo('thread', ${c.id})">
            <td>
              <div class="contact-row-info">
                <div class="row-avatar" style="background-color: ${c.avatarColor || '#3525cd'};">
                  ${c.name.split(' ').map(n=>n[0]).join('').substring(0,2).toUpperCase()}
                </div>
                <div style="font-weight: 700;">${c.name}</div>
              </div>
            </td>
            <td>
              <span class="text-number">${c.phone}</span>
            </td>
            <td>
              <span class="badge badge-outline">${c.category || 'General'}</span>
            </td>
            <td>
              <span class="badge ${statusBadgeClass}">${c.status || 'Active'}</span>
            </td>
            <td style="text-align: right;">
              <span class="text-number" style="font-weight: 600;">${lastActivityText}</span>
            </td>
          </tr>
        `;
        listBody.insertAdjacentHTML('beforeend', rowHtml);
      });
    });
  },

  sortDirectory(key) {
    if (this.currentSortKey === key) {
      this.sortAscending = !this.sortAscending;
    } else {
      this.currentSortKey = key;
      this.sortAscending = true;
    }
    console.log(`Sorting directory by ${key} ascending: ${this.sortAscending}`);
    this.renderDirectory();
  },

  // ================= 3. RELATIONSHIP THREAD RENDERING =================
  async renderRelationshipThread(contactId) {
    const contact = await this.db.getContact(contactId);
    if (!contact) {
      this.navigateTo('home');
      return;
    }

    // Set Active contact detail text fields
    document.getElementById('thread-contact-name').innerHTML = `
      ${contact.name}
      <span class="material-symbols-outlined bento-star ${contact.isFavorite ? 'active' : ''}" id="thread-contact-star" onclick="event.stopPropagation(); App.toggleThreadContactFav()">star</span>
    `;
    document.getElementById('thread-contact-phone').textContent = contact.phone;
    
    const avatarEl = document.getElementById('thread-contact-avatar');
    avatarEl.textContent = contact.name.split(' ').map(n=>n[0]).join('').substring(0,2).toUpperCase();
    avatarEl.style.backgroundColor = contact.avatarColor || '#3525cd';

    // RENDER PINNED NOTE IF EXISTS
    const pinnedNoteBox = document.getElementById('thread-pinned-note-box');
    const pinnedNoteText = document.getElementById('thread-pinned-note-text');
    if (contact.pinnedNote) {
      pinnedNoteText.textContent = contact.pinnedNote;
      pinnedNoteBox.style.display = 'flex';
    } else {
      pinnedNoteBox.style.display = 'none';
    }

    // RENDER CHRONOLOGICAL TIMELINE CARDS
    const timelineList = document.getElementById('thread-timeline-list');
    timelineList.innerHTML = '';

    const events = await this.db.getTimelineForContact(contactId);
    const tasks = await this.db.getAllTasks();
    const contactTasks = tasks.filter(t => t.contactId === contactId && !t.isCompleted);
    
    // Check if there is an active tracked promise in the upcoming actions widget
    const upcomingActionBox = document.getElementById('thread-upcoming-action-box');
    const upcomingActionText = document.getElementById('thread-upcoming-action-text');
    
    const promiseTask = contactTasks.find(t => t.title.toUpperCase().includes('PROMISE') || t.title.toUpperCase().includes('DELIVERY'));
    if (promiseTask) {
      upcomingActionText.textContent = `Promise Track: ${promiseTask.title} (Due: ${new Date(promiseTask.dueDate).toLocaleDateString()})`;
      upcomingActionBox.style.display = 'flex';
    } else if (contactTasks.length > 0) {
      upcomingActionText.textContent = `Action Due: ${contactTasks[0].title} (Due: ${new Date(contactTasks[0].dueDate).toLocaleDateString()})`;
      upcomingActionBox.style.display = 'flex';
    } else {
      upcomingActionBox.style.display = 'none';
    }

    if (events.length === 0) {
      timelineList.innerHTML = `
        <div style="text-align:center; padding: 40px var(--margin-mobile); color:var(--outline);">
          <span class="material-symbols-outlined" style="font-size: 36px; margin-bottom:8px;">forum</span>
          <p style="font-weight:700;">No timeline events recorded.</p>
          <p class="text-small">Use the Quick Event Logger at the bottom to log call outcomes, BKash payments, promises, or attachments.</p>
        </div>
      `;
      return;
    }

    events.forEach(item => {
      let icon = 'chat_bubble';
      let headerText = 'Note Log';
      let iconColor = 'background-color: var(--surface-container-highest); color: var(--on-surface-variant);';
      let bodyContentHtml = `<p class="timeline-content-text">${item.content}</p>`;

      // Custom formatting based on timeline type
      switch (item.type) {
        case 'call':
          icon = 'call';
          const typeLabel = item.meta.type === 'incoming' ? 'Incoming call' : 'Outgoing call';
          headerText = `${typeLabel} (${item.meta.duration || '0m'})`;
          iconColor = 'background-color: var(--surface-container-low); color: var(--primary); border: 1.5px solid var(--outline-variant);';
          break;
        case 'screenshot':
          icon = 'photo_library';
          headerText = 'Attached Screenshot / Image';
          iconColor = 'background-color: var(--surface-container-high); color: var(--primary);';
          bodyContentHtml = `
            <p class="timeline-content-text italic">"${item.content || 'Base64 Attachment uploaded'}"</p>
            <div class="timeline-attachment-card">
              <div class="timeline-attachment-preview">
                <img src="${item.meta.fileDataUri}" alt="Attachment preview" onclick="window.open('${item.meta.fileDataUri}')" style="cursor:zoom-in;">
              </div>
            </div>
          `;
          break;
        case 'payment':
          icon = 'payments';
          headerText = 'Payment Logged';
          iconColor = 'background-color: var(--emerald-bg); color: var(--emerald); border: 1.5px solid var(--emerald);';
          bodyContentHtml = `
            <div class="timeline-payment-box">
              <p class="timeline-content-text" style="font-weight:700; color:var(--primary); font-size:14px;">${item.meta.amount}</p>
              <p class="text-small">${item.content || 'Logged cash flow payment'}</p>
              ${item.meta.method ? `<p class="text-small" style="font-family:var(--font-mono); font-size:10px; margin-top:2px;">Ref: ${item.meta.method}</p>` : ''}
            </div>
          `;
          break;
        case 'voice':
          icon = 'mic';
          headerText = 'Audio Voice Memo';
          iconColor = 'background-color: var(--rose-bg); color: var(--rose); border: 1.5px solid var(--rose);';
          bodyContentHtml = `
            <p class="timeline-content-text italic">${item.content}</p>
            <div class="timeline-audio-player">
              <span class="material-symbols-outlined" style="color:var(--rose); cursor:pointer;" onclick="App.playAudioPlaceholder(this)">play_arrow</span>
              <span class="text-number" style="font-size:11px; flex:1; font-weight:600;">Voice recording (${item.meta.voiceDuration || '0:05'})</span>
            </div>
          `;
          break;
        case 'promise':
          icon = 'handshake';
          headerText = 'Tracked Promise';
          iconColor = 'background-color: var(--amber-bg); color: var(--amber); border: 1.5px solid var(--amber);';
          bodyContentHtml = `
            <div class="timeline-payment-box" style="border-left-color: var(--amber); background-color: var(--surface-container-low);">
              <p class="timeline-content-text" style="font-weight:700; color:var(--amber);">${item.content}</p>
              <p class="text-small">Promise Target Status: ACTIVE TRACKING</p>
            </div>
          `;
          break;
        default:
          icon = 'sticky_note_2';
          headerText = 'Typed Note Log';
      }

      const itemHtml = `
        <div class="timeline-item relative">
          <div class="timeline-connector"></div>
          <div class="timeline-avatar-wrapper" style="${iconColor}">
            <span class="material-symbols-outlined">${icon}</span>
          </div>
          <div class="timeline-body">
            <div class="timeline-meta">
              <span class="timeline-title">${headerText}</span>
              <span class="timeline-time">${formatTime(item.timestamp)}</span>
            </div>
            ${bodyContentHtml}
          </div>
        </div>
      `;
      timelineList.insertAdjacentHTML('beforeend', itemHtml);
    });

    // Populate enrichment fields with current details
    document.getElementById('enrich-fb').value = contact.fbProfile || '';
    document.getElementById('enrich-linkedin').value = contact.linkedinProfile || '';
    document.getElementById('enrich-gmail').value = contact.gmailProfile || '';
    document.getElementById('enrich-pinned-note').value = contact.pinnedNote || '';
    document.getElementById('enrich-category').value = contact.category || 'Client';
    document.getElementById('enrich-status').value = contact.status || 'Active';
  },

  // TOGGLE ENRICHMENT BOX DRAWER
  toggleThreadEnrichmentBox() {
    const box = document.getElementById('thread-enrichment-box');
    box.style.display = box.style.display === 'none' ? 'block' : 'none';
  },

  switchEnrichTab(tabName) {
    this.activeEnrichTab = tabName;
    document.querySelectorAll('.enrichment-tab').forEach(el => {
      if (el.getAttribute('data-tab') === tabName) {
        el.classList.add('active');
      } else {
        el.classList.remove('active');
      }
    });

    document.querySelectorAll('.enrichment-pane').forEach(el => {
      if (el.getAttribute('id') === `enrich-pane-${tabName}`) {
        el.classList.add('active');
      } else {
        el.classList.remove('active');
      }
    });
  },

  // SAVE MANUAL ENRICHMENTS
  async saveEnrichmentSocial(e) {
    e.preventDefault();
    if (!this.activeContactId) return;

    const fb = document.getElementById('enrich-fb').value;
    const linkedin = document.getElementById('enrich-linkedin').value;
    const gmail = document.getElementById('enrich-gmail').value;

    const updated = await this.db.updateContact(this.activeContactId, {
      fbProfile: fb,
      linkedinProfile: linkedin,
      gmailProfile: gmail,
      email: gmail // Sync basic email
    });

    this.showNotification(`Social data enriched for ${updated.name}`);
    this.renderRelationshipThread(this.activeContactId);
    this.refreshAllData();
  },

  async saveEnrichmentPinnedNote(e) {
    e.preventDefault();
    if (!this.activeContactId) return;

    const pinnedNote = document.getElementById('enrich-pinned-note').value;
    const updated = await this.db.updateContact(this.activeContactId, { pinnedNote });
    
    // Add timeline log for pinned note update
    await this.db.addTimelineEntry({
      contactId: this.activeContactId,
      type: 'note',
      content: `Updated pinned CRM Note: "${pinnedNote}"`,
      tags: ['CRM_PIN'],
      meta: {},
      timestamp: new Date().toISOString()
    });

    this.showNotification(`Pinned CRM note updated`);
    this.renderRelationshipThread(this.activeContactId);
    this.refreshAllData();
  },

  async saveEnrichmentLabels(e) {
    e.preventDefault();
    if (!this.activeContactId) return;

    const category = document.getElementById('enrich-category').value;
    const status = document.getElementById('enrich-status').value;

    const updated = await this.db.updateContact(this.activeContactId, { category, status });
    this.showNotification(`Badges updated to ${category} / ${status}`);
    this.renderRelationshipThread(this.activeContactId);
    this.refreshAllData();
  },

  // ================= DATA IMPORT & EXPORT (DEVICE MIGRATION) =================
  exportData() {
    Modals.open('export-settings-modal');
  },

  async performExport(e) {
    e.preventDefault();
    const exportContacts = document.getElementById('export-contacts').checked;
    const exportTimeline = document.getElementById('export-timeline').checked;
    const exportSMS = document.getElementById('export-sms').checked;
    const exportTasks = document.getElementById('export-tasks').checked;

    if (!exportContacts && !exportTimeline && !exportSMS && !exportTasks) {
      this.showNotification('Please select at least one category to export.', 'error');
      return;
    }

    try {
      const payload = {
        database: "PocketCRM",
        timestamp: new Date().toISOString(),
        version: "1.0",
        data: {}
      };

      const promises = [];

      if (exportContacts) {
        promises.push(this.db.getAllContacts().then(res => {
          payload.data.contacts = res;
        }));
      }
      if (exportTimeline) {
        promises.push(this.db.getAllTimeline().then(res => {
          payload.data.timeline = res;
        }));
      }
      if (exportSMS) {
        promises.push(this.db.getAllScheduledSMS().then(res => {
          payload.data.scheduled_sms = res;
        }));
      }
      if (exportTasks) {
        promises.push(this.db.getAllTasks().then(res => {
          payload.data.tasks = res;
        }));
      }

      await Promise.all(promises);

      const jsonStr = JSON.stringify(payload, null, 2);
      const blob = new Blob([jsonStr], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      
      const dateStr = new Date().toISOString().split('T')[0];
      const link = document.createElement('a');
      link.href = url;
      link.download = `pocketcrm_backup_${dateStr}.json`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);

      Modals.close('export-settings-modal');
      this.showNotification('Backup file generated and downloaded successfully!');
    } catch (err) {
      console.error(err);
      this.showNotification('Error creating backup file.', 'error');
    }
  },

  triggerImportData() {
    document.getElementById('hidden-import-input').click();
  },

  handleImportData(e) {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      try {
        const payload = JSON.parse(event.target.result);
        
        if (payload.database !== 'PocketCRM' || !payload.data) {
          throw new Error('Invalid file format. Not a PocketCRM backup.');
        }

        this.tempBackupData = payload;

        const summaryInfoDiv = document.getElementById('import-summary-info');
        const cCount = payload.data.contacts ? payload.data.contacts.length : 0;
        const tCount = payload.data.timeline ? payload.data.timeline.length : 0;
        const sCount = payload.data.scheduled_sms ? payload.data.scheduled_sms.length : 0;
        const tkCount = payload.data.tasks ? payload.data.tasks.length : 0;

        summaryInfoDiv.innerHTML = `
          <strong>Backup File Details:</strong><br>
          &bull; Generated on: ${payload.timestamp ? new Date(payload.timestamp).toLocaleString() : 'N/A'}<br>
          &bull; Contacts: ${cCount} records<br>
          &bull; Timeline Events: ${tCount} records (including SMS sync logs)<br>
          &bull; Scheduled Queue: ${sCount} records<br>
          &bull; Tasks &amp; Promises: ${tkCount} records
        `;

        const contactsChk = document.getElementById('import-contacts-chk');
        const timelineChk = document.getElementById('import-timeline-chk');
        const smsChk = document.getElementById('import-sms-chk');
        const tasksChk = document.getElementById('import-tasks-chk');

        contactsChk.checked = cCount > 0;
        contactsChk.disabled = cCount === 0;
        document.getElementById('import-contacts-label').style.opacity = cCount === 0 ? '0.5' : '1';

        timelineChk.checked = tCount > 0;
        timelineChk.disabled = tCount === 0;
        document.getElementById('import-timeline-label').style.opacity = tCount === 0 ? '0.5' : '1';

        smsChk.checked = sCount > 0;
        smsChk.disabled = sCount === 0;
        document.getElementById('import-sms-label').style.opacity = sCount === 0 ? '0.5' : '1';

        tasksChk.checked = tkCount > 0;
        tasksChk.disabled = tkCount === 0;
        document.getElementById('import-tasks-label').style.opacity = tkCount === 0 ? '0.5' : '1';

        Modals.open('import-settings-modal');

      } catch (err) {
        console.error(err);
        this.showNotification('Error parsing backup file: ' + err.message, 'error');
        e.target.value = '';
      }
    };
    reader.readAsText(file);
  },

  async performImport(e) {
    e.preventDefault();
    if (!this.tempBackupData) return;

    const importContacts = document.getElementById('import-contacts-chk').checked;
    const importTimeline = document.getElementById('import-timeline-chk').checked;
    const importSMS = document.getElementById('import-sms-chk').checked;
    const importTasks = document.getElementById('import-tasks-chk').checked;
    
    const strategy = document.querySelector('input[name="import-strategy"]:checked').value;

    const data = this.tempBackupData.data;

    try {
      const existingContacts = await this.db.getAllContacts();
      const existingPhones = new Map();
      existingContacts.forEach(c => {
        if (c.phone) existingPhones.set(c.phone, c);
      });

      const idMap = new Map();

      // 1. Process Contacts
      if (importContacts && data.contacts) {
        if (strategy === 'overwrite') {
          // Clear store
          await new Promise((res, rej) => {
            const { store } = this.db._getTransaction('contacts', 'readwrite');
            const req = store.clear();
            req.onsuccess = () => res();
            req.onerror = () => rej(req.error);
          });
        }

        for (const item of data.contacts) {
          if (strategy === 'merge') {
            const match = existingPhones.get(item.phone);
            if (match) {
              const merged = { ...match, ...item, id: match.id };
              await this.db.updateContact(match.id, merged);
              idMap.set(item.id, match.id);
            } else {
              const newItem = { ...item };
              delete newItem.id;
              const newId = await this.db.addContact(newItem);
              idMap.set(item.id, newId);
            }
          } else {
            await this.db.addContact(item);
            idMap.set(item.id, item.id);
          }
        }
      } else {
        existingContacts.forEach(c => idMap.set(c.id, c.id));
      }

      // 2. Process Timeline
      if (importTimeline && data.timeline) {
        if (strategy === 'overwrite') {
          await new Promise((res, rej) => {
            const { store } = this.db._getTransaction('timeline', 'readwrite');
            const req = store.clear();
            req.onsuccess = () => res();
            req.onerror = () => rej(req.error);
          });
        }
        for (const item of data.timeline) {
          const newContactId = idMap.get(item.contactId);
          if (newContactId) {
            const newItem = { ...item, contactId: newContactId };
            if (strategy === 'merge') {
              delete newItem.id;
            }
            await this.db.addTimelineEntry(newItem);
          }
        }
      }

      // 3. Process Scheduled SMS
      if (importSMS && data.scheduled_sms) {
        if (strategy === 'overwrite') {
          await new Promise((res, rej) => {
            const { store } = this.db._getTransaction('scheduled_sms', 'readwrite');
            const req = store.clear();
            req.onsuccess = () => res();
            req.onerror = () => rej(req.error);
          });
        }
        for (const item of data.scheduled_sms) {
          const newContactId = idMap.get(item.contactId);
          if (newContactId) {
            const newItem = { ...item, contactId: newContactId };
            if (strategy === 'merge') {
              delete newItem.id;
            }
            await this.db.addScheduledSMS(newItem);
          }
        }
      }

      // 4. Process Tasks & Promises
      if (importTasks && data.tasks) {
        if (strategy === 'overwrite') {
          await new Promise((res, rej) => {
            const { store } = this.db._getTransaction('tasks', 'readwrite');
            const req = store.clear();
            req.onsuccess = () => res();
            req.onerror = () => rej(req.error);
          });
        }
        for (const item of data.tasks) {
          const newContactId = idMap.get(item.contactId);
          if (newContactId) {
            const newItem = { ...item, contactId: newContactId };
            if (strategy === 'merge') {
              delete newItem.id;
            }
            await new Promise((res, rej) => {
              const { store } = this.db._getTransaction('tasks', 'readwrite');
              const req = store.add(newItem);
              req.onsuccess = () => res();
              req.onerror = () => rej(req.error);
            });
          }
        }
      }

      Modals.close('import-settings-modal');
      this.showNotification('Backup successfully restored offline!', 'success');
      this.tempBackupData = null;
      document.getElementById('hidden-import-input').value = '';
      this.refreshAllData();
      
      if (this.currentView === 'thread' && this.activeContactId) {
        this.renderRelationshipThread(this.activeContactId);
      }

    } catch (err) {
      console.error(err);
      this.showNotification('Error restoring backup: ' + err.message, 'error');
    }
  },

  async clearThreadPinnedNote() {
    if (!this.activeContactId) return;
    await this.db.updateContact(this.activeContactId, { pinnedNote: '' });
    this.showNotification('Relationship note unpinned.');
    this.renderRelationshipThread(this.activeContactId);
    this.refreshAllData();
  },

  // TIMELINE INTERACTIVE TOOLS
  insertLoggerTemplate(template) {
    const input = document.getElementById('logger-text-input');
    
    if (template === '#payment') {
      input.value = 'Sent payment of ৳5,000 via bKash ';
    } else if (template === '#promise') {
      input.value = 'Promised delivery Friday ';
    } else if (template === '#quote') {
      input.value = 'Quoted ৳12,000 for AC annual contract ';
    } else if (template === '#schedule') {
      input.value = 'Scheduled a follow up reminder ';
    } else {
      input.value = template + ' ';
    }
    input.focus();
  },

  handleLoggerKeyPress(e) {
    if (e.key === 'Enter') {
      this.logEventFromLogger();
    }
  },

  async logEventFromLogger() {
    if (!this.activeContactId) return;
    const input = document.getElementById('logger-text-input');
    const val = input.value.trim();
    if (!val) return;

    let type = 'note';
    let meta = {};
    let tags = ['MANUAL'];

    // Auto-parse tag categories from logger inputs
    if (val.toUpperCase().includes('#PAYMENT') || val.includes('৳')) {
      type = 'payment';
      tags.push('PAYMENT');
      // Regex parse payment amounts
      const amtMatch = val.match(/৳\s*[0-9,]+/);
      meta.amount = amtMatch ? amtMatch[0] : '৳2,000';
      meta.method = val.toUpperCase().includes('BKASH') ? 'bKash Transaction' : 'Cash Log';
    } else if (val.toUpperCase().includes('PROMISED') || val.toUpperCase().includes('#PROMISE') || val.toUpperCase().includes('#TASK')) {
      type = 'promise';
      tags.push('PROMISE');
      // Create a task automatically for the promise/task deliverable!
      // Strip out the tags for clean task title
      let taskTitle = val.replace(/#promise|#task/gi, '').trim();
      if (!taskTitle) taskTitle = `Promise tracking: ${val}`;
      await this.db.addTask({
        contactId: this.activeContactId,
        title: taskTitle,
        dueDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
        isCompleted: false,
        isReminder: true,
        createdAt: new Date().toISOString()
      });
    } else if (val.toUpperCase().includes('CALL') || val.toUpperCase().includes('TELE')) {
      type = 'call';
      tags.push('CALL');
      meta.duration = '3 mins';
      meta.type = 'outgoing';
    }

    const entry = {
      contactId: this.activeContactId,
      type,
      content: val,
      tags,
      meta,
      timestamp: new Date().toISOString()
    };

    await this.db.addTimelineEntry(entry);
    input.value = '';
    this.renderRelationshipThread(this.activeContactId);
    this.refreshAllData();
    this.showNotification('Timeline interaction logged.');
  },

  // CALL LOG SIMULATION TRIGGER
  async triggerThreadCall() {
    if (!this.activeContactId) return;
    const contact = await this.db.getContact(this.activeContactId);
    
    this.showNotification(`Dialing ${contact.phone}...`, 'info');
    
    setTimeout(async () => {
      await this.db.addTimelineEntry({
        contactId: this.activeContactId,
        type: 'call',
        content: `Outgoing call completed with ${contact.name}.`,
        tags: ['CALL', 'OUTGOING'],
        meta: { duration: '2 mins', type: 'outgoing' },
        timestamp: new Date().toISOString()
      });
      this.renderRelationshipThread(this.activeContactId);
      this.refreshAllData();
      this.showNotification('Outgoing call logged to relationship timeline.');
    }, 1500);
  },

  // VOICE MEMO RECORDER SIMULATION
  triggerVoiceRecording() {
    const btn = document.getElementById('voice-record-btn');
    
    if (this.isRecordingVoice) {
      // STOP RECORDING
      clearInterval(this.recordTimer);
      this.isRecordingVoice = false;
      btn.classList.remove('recording');
      btn.innerHTML = `<span class="material-symbols-outlined">mic</span>`;
      
      const durationText = `0:${this.recordSeconds.toString().padStart(2, '0')}`;
      
      // Save voice timeline entry
      this.db.addTimelineEntry({
        contactId: this.activeContactId,
        type: 'voice',
        content: 'Voice memo logged via browser recording.',
        tags: ['AUDIO', 'VOICE_MEMO'],
        meta: { 
          voiceDuration: durationText,
          fileDataUri: 'data:audio/mp3;base64,AAA=' // Simulated base64 wave
        },
        timestamp: new Date().toISOString()
      }).then(() => {
        this.renderRelationshipThread(this.activeContactId);
        this.refreshAllData();
        this.showNotification('Voice memo recorded offline.');
      });

    } else {
      // START RECORDING
      this.isRecordingVoice = true;
      this.recordSeconds = 0;
      btn.classList.add('recording');
      btn.innerHTML = `<span class="material-symbols-outlined" style="color:var(--rose)">stop</span>`;
      
      this.showNotification('Recording voice memo... Press mic again to stop.');
      
      this.recordTimer = setInterval(() => {
        this.recordSeconds++;
        this.showNotification(`Recording: 0:${this.recordSeconds.toString().padStart(2, '0')}`, 'info');
        if (this.recordSeconds >= 30) { // Limit mock recording to 30s
          this.triggerVoiceRecording();
        }
      }, 1000);
    }
  },

  playAudioPlaceholder(btn) {
    if (btn.textContent === 'play_arrow') {
      btn.textContent = 'pause';
      btn.style.color = 'var(--rose)';
      this.showNotification('Playing local encrypted audio wave memo...', 'info');
      setTimeout(() => {
        btn.textContent = 'play_arrow';
        btn.style.color = 'inherit';
      }, 2500);
    } else {
      btn.textContent = 'play_arrow';
      btn.style.color = 'inherit';
    }
  },

  // SCREENSHOT FILE ATTACHMENTS
  triggerFileAttachment() {
    document.getElementById('hidden-file-input').click();
  },

  handleFileAttached(event) {
    const file = event.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = async (e) => {
      const dataUri = e.target.result;
      
      await this.db.addTimelineEntry({
        contactId: this.activeContactId,
        type: 'screenshot',
        content: `Manual file attached: ${file.name}`,
        tags: ['FILE', 'UPLOAD'],
        meta: { 
          fileType: file.type,
          fileDataUri: dataUri
        },
        timestamp: new Date().toISOString()
      });

      this.renderRelationshipThread(this.activeContactId);
      this.refreshAllData();
      this.showNotification('File attached and encrypted locally.');
    };

    reader.readAsDataURL(file);
  },

  // ================= 4. SMS SCHEDULER HUB RENDERING =================
  async renderSchedulerHub() {
    const messages = await this.db.getAllScheduledSMS();
    const contacts = await this.db.getAllContacts();
    
    // Update queue summary counts in widgets
    const pending = messages.filter(m => m.status === 'pending');
    document.getElementById('scheduler-pending-count').textContent = `${pending.length} Messages Pending`;

    const tbody = document.getElementById('scheduler-list-rows');
    tbody.innerHTML = '';

    if (messages.length === 0) {
      tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding:24px; color:var(--outline);">No scheduled messages. Click "New Schedule" to queue automation dispatches!</td></tr>`;
      return;
    }

    messages.forEach(m => {
      const contact = contacts.find(c => c.id === m.contactId);
      const contactName = contact ? contact.name : 'Unknown Contact';
      const statusLabel = m.status.charAt(0).toUpperCase() + m.status.slice(1);
      const isChecked = m.status === 'pending' ? 'checked' : '';

      const trHtml = `
        <tr class="${m.status === 'paused' ? 'bg-surface-dim/20' : ''}">
          <td>
            <div style="font-weight:700;">${contactName}</div>
            <div class="text-small" style="color:var(--outline); font-family:var(--font-mono);">${contact ? contact.phone : ''}</div>
          </td>
          <td style="max-width:280px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap;">
            ${m.message}
          </td>
          <td>
            <span class="mono-font" style="font-weight:600; color:var(--primary);">${formatTime(m.scheduledTime)}</span>
          </td>
          <td>
            <label class="toggle-switch">
              <input type="checkbox" class="toggle-input" ${isChecked} onchange="App.toggleSMSStatus(${m.id}, this.checked)">
              <span class="toggle-slider"></span>
              <span class="toggle-label text-small ${m.status === 'paused' ? 'text-outline' : ''}">${statusLabel}</span>
            </label>
          </td>
          <td style="text-align: right;">
            <div class="flex-row-gap gap-sm" style="justify-content: flex-end;">
              <button class="btn btn-secondary btn-icon" style="width:30px; height:30px;" onclick="App.deleteScheduledSMS(${m.id})" title="Delete from Queue">
                <span class="material-symbols-outlined" style="font-size: 16px; color:var(--rose);">delete</span>
              </button>
            </div>
          </td>
        </tr>
      `;
      tbody.insertAdjacentHTML('beforeend', trHtml);
    });
  },

  async toggleSMSStatus(id, isChecked) {
    const newStatus = isChecked ? 'pending' : 'paused';
    await this.db.updateScheduledSMS(id, { status: newStatus });
    this.showNotification(`SMS automation ${newStatus === 'pending' ? 'resumed' : 'paused'}`);
    this.refreshAllData();
  },

  async deleteScheduledSMS(id) {
    if (!confirm('Are you sure you want to cancel this scheduled message?')) return;
    await this.db.deleteScheduledSMS(id);
    this.showNotification('Scheduled message cancelled.');
    this.refreshAllData();
  },

  onSchedulerSearch(val) {
    const q = val.toUpperCase().trim();
    this.db.getAllScheduledSMS().then(async messages => {
      const contacts = await this.db.getAllContacts();
      
      const filtered = messages.filter(m => {
        const contact = contacts.find(c => c.id === m.contactId);
        const contactName = contact ? contact.name : '';
        return contactName.toUpperCase().includes(q) || m.message.toUpperCase().includes(q);
      });

      const tbody = document.getElementById('scheduler-list-rows');
      tbody.innerHTML = '';

      if (filtered.length === 0) {
        tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding:24px; color:var(--outline);">No schedules matching filter.</td></tr>`;
        return;
      }

      filtered.forEach(m => {
        const contact = contacts.find(c => c.id === m.contactId);
        const contactName = contact ? contact.name : 'Unknown Contact';
        const isChecked = m.status === 'pending' ? 'checked' : '';

        const trHtml = `
          <tr class="${m.status === 'paused' ? 'bg-surface-dim/20' : ''}">
            <td>
              <div style="font-weight:700;">${contactName}</div>
              <div class="text-small" style="color:var(--outline); font-family:var(--font-mono);">${contact ? contact.phone : ''}</div>
            </td>
            <td style="max-width:280px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap;">
              ${m.message}
            </td>
            <td>
              <span class="mono-font" style="font-weight:600; color:var(--primary);">${formatTime(m.scheduledTime)}</span>
            </td>
            <td>
              <label class="toggle-switch">
                <input type="checkbox" class="toggle-input" ${isChecked} onchange="App.toggleSMSStatus(${m.id}, this.checked)">
                <span class="toggle-slider"></span>
                <span class="toggle-label text-small">${m.status.toUpperCase()}</span>
              </label>
            </td>
            <td style="text-align: right;">
              <div class="flex-row-gap gap-sm" style="justify-content: flex-end;">
                <button class="btn btn-secondary btn-icon" style="width:30px; height:30px;" onclick="App.deleteScheduledSMS(${m.id})">
                  <span class="material-symbols-outlined" style="font-size: 16px; color:var(--rose);">delete</span>
                </button>
              </div>
            </td>
          </tr>
        `;
        tbody.insertAdjacentHTML('beforeend', trHtml);
      });
    });
  },

  // SIMULATE DISPATCH ENGINES (Active Dispatch checks every 10s)
  initSchedulerDispatcher() {
    const timerText = document.getElementById('scheduler-timer');
    
    this.schedulerInterval = setInterval(() => {
      this.secondsToDispatch -= 10;
      if (this.secondsToDispatch <= 0) {
        this.secondsToDispatch = 300;
        this.triggerAutomatedDispatchTick();
      }
      
      const mins = Math.floor(this.secondsToDispatch / 60);
      const secs = this.secondsToDispatch % 60;
      if (timerText) {
        timerText.textContent = `Next automated dispatch check in ${mins}:${secs.toString().padStart(2, '0')}`;
      }
    }, 10000);
  },

  async triggerAutomatedDispatchTick() {
    const messages = await this.db.getAllScheduledSMS();
    const now = new Date();
    
    // Find pending messages with scheduled dates in past
    const toDispatch = messages.filter(m => m.status === 'pending' && new Date(m.scheduledTime) <= now);
    
    if (toDispatch.length > 0) {
      console.log(`Auto dispatch engine: dispatching ${toDispatch.length} queued SMS...`);
      for (const m of toDispatch) {
        await this.dispatchSingleSMS(m);
      }
      this.refreshAllData();
    }
  },

  async triggerInstantDispatchAll() {
    const messages = await this.db.getAllScheduledSMS();
    const pending = messages.filter(m => m.status === 'pending');
    
    if (pending.length === 0) {
      this.showNotification('No pending messages queued for automated dispatch.', 'info');
      return;
    }

    this.showNotification(`Forcing instant dispatch on ${pending.length} scheduled SMS...`);
    for (const m of pending) {
      await this.dispatchSingleSMS(m);
    }
    
    this.refreshAllData();
    this.showNotification('All pending SMS messages successfully dispatched on-device.');
  },

  async dispatchSingleSMS(sms) {
    // 1. Update status to 'sent'
    await this.db.updateScheduledSMS(sms.id, { status: 'sent' });
    
    // 2. Insert corresponding text/message log inside that contact timeline
    await this.db.addTimelineEntry({
      contactId: sms.contactId,
      type: 'note',
      content: `Dispatched automated SMS: "${sms.message}"`,
      tags: ['AUTOMATION', 'DISPATCHED_SMS'],
      meta: { status: 'success' },
      timestamp: new Date().toISOString()
    });
  },

  async toggleAllScheduler() {
    const btn = document.getElementById('scheduler-toggle-all-btn');
    const messages = await this.db.getAllScheduledSMS();
    
    const hasPending = messages.some(m => m.status === 'pending');
    const targetStatus = hasPending ? 'paused' : 'pending';

    for (const m of messages) {
      if (m.status !== 'sent') {
        await this.db.updateScheduledSMS(m.id, { status: targetStatus });
      }
    }

    btn.textContent = targetStatus === 'pending' ? 'Pause All queue' : 'Resume All queue';
    this.showNotification(`All scheduled messages ${targetStatus === 'pending' ? 'resumed' : 'paused'}.`);
    this.refreshAllData();
  },

  // ================= 5. GLOBAL ACTIVITIES LOG RENDERING =================
  async renderActivitiesFeed() {
    const events = await this.db.getAllTimeline();
    const contacts = await this.db.getAllContacts();
    
    document.getElementById('activities-total').textContent = `Total timeline logs: ${events.length}`;

    const container = document.getElementById('global-activities-timeline');
    container.innerHTML = '';

    if (events.length === 0) {
      container.innerHTML = `<p class="text-small" style="color:var(--outline); text-align:center;">No timeline logs recorded globally.</p>`;
      return;
    }

    events.forEach(item => {
      const contact = contacts.find(c => c.id === item.contactId);
      const contactName = contact ? contact.name : 'Unknown Contact';
      
      let badgeType = 'badge-indigo';
      if (item.type === 'payment') badgeType = 'badge-emerald';
      if (item.type === 'promise') badgeType = 'badge-amber';
      if (item.type === 'voice') badgeType = 'badge-rose';

      const logHtml = `
        <div class="timeline-item relative" onclick="App.navigateTo('thread', ${item.contactId})" style="cursor:pointer; border-bottom: 1px dashed var(--outline-variant); padding-bottom:12px; margin-bottom:12px;">
          <div class="row-avatar small" style="background-color: ${contact ? contact.avatarColor : '#5c5f61'}; display:flex; align-items:center; justify-content:center; color:#fff; font-weight:700; font-size:11px; flex-shrink:0;">
            ${contactName.split(' ').map(n=>n[0]).join('').substring(0,2).toUpperCase()}
          </div>
          <div class="timeline-body">
            <div class="timeline-meta" style="margin-bottom:2px;">
              <span style="font-weight:700;">${contactName} &bull; <span class="badge ${badgeType}">${item.type.toUpperCase()}</span></span>
              <span class="timeline-time">${formatTime(item.timestamp)}</span>
            </div>
            <p class="timeline-content-text">${item.content}</p>
          </div>
        </div>
      `;
      container.insertAdjacentHTML('beforeend', logHtml);
    });
  },

  // ================= SIMULATOR PHONE IMPORT terminal =================
  triggerPhoneSync() {
    const term = document.getElementById('sync-terminal');
    term.innerHTML = `<div class="spam-line">Establishing local ADB bridge to phone database...</div>`;
    Modals.open('sync-console-modal');

    window.PocketSpamFilter.simulatePhoneImport(async (analysis, index, total) => {
      const isBlocked = analysis.isSpam;
      const lineClass = isBlocked ? 'blocked' : 'kept';
      const statusText = isBlocked ? '[BLOCKED SPAM]' : '[KEPT PERSONAL]';
      
      const lineHtml = `
        <div class="spam-line ${lineClass}">
          ${statusText} FROM: ${analysis.sender}<br>
          CONTENT: "${analysis.text}"<br>
          REASON: ${analysis.reason}<br>
          -----------------------------------------
        </div>
      `;
      term.insertAdjacentHTML('beforeend', lineHtml);
      term.scrollTop = term.scrollHeight;

      // If it is personal contact, automatically load them into IndexedDB!
      if (!isBlocked) {
        const contacts = await this.db.getAllContacts();
        const existing = contacts.find(c => c.phone.replace(/[\s-]/g,'') === analysis.sender.replace(/[\s-]/g,''));
        
        if (!existing) {
          const newId = await this.db.addContact({
            name: `Imported: ${analysis.sender}`,
            phone: analysis.sender,
            category: 'Other',
            status: 'Active',
            avatarColor: '#5c5f61',
            isPinned: false,
            isFavorite: false,
            pinnedNote: 'Simulated Import from spam logs.',
            lastContacted: new Date().toISOString()
          });

          await this.db.addTimelineEntry({
            contactId: newId,
            type: 'note',
            content: `Imported message: "${analysis.text}"`,
            tags: ['SMS_IMPORT'],
            meta: {},
            timestamp: new Date().toISOString()
          });
        }
      }

      if (index === total) {
        term.insertAdjacentHTML('beforeend', `<div class="spam-line" style="color:#fff; font-weight:700;">Sync sync-cycles complete. ${total} logs analyzed. spam isolated.</div>`);
        this.refreshAllData();
      }
    });
  },

  // ================= MODAL SUBMISSION FORM HANDLERS =================
  async handleCreateContact(e) {
    e.preventDefault();
    const name = document.getElementById('new-contact-name').value;
    const phone = document.getElementById('new-contact-phone').value;
    const email = document.getElementById('new-contact-email').value;
    const category = document.getElementById('new-contact-category').value;
    const pinnedNote = document.getElementById('new-contact-pinned').value;

    const colors = ['#3525cd', '#5c5f61', '#7e3000', '#10b981', '#ba1a1a', '#ffd2be'];
    const randColor = colors[Math.floor(Math.random() * colors.length)];

    try {
      const newId = await this.db.addContact({
        name,
        phone,
        email,
        category,
        status: 'Active',
        avatarColor: randColor,
        isPinned: false,
        isFavorite: false,
        pinnedNote,
        createdAt: new Date().toISOString()
      });

      // Insert Initial interaction card
      await this.db.addTimelineEntry({
        contactId: newId,
        type: 'note',
        content: `Contact profile created locally. Initial notes: "${pinnedNote || 'No special requirements listed'}"`,
        tags: ['CRM_INIT'],
        meta: {},
        timestamp: new Date().toISOString()
      });

      this.showNotification(`Contact ${name} created successfully.`);
      Modals.close('add-contact-modal');
      
      // Reset form
      e.target.reset();

      this.refreshAllData();
      this.navigateTo('thread', newId);

    } catch (err) {
      console.error(err);
      this.showNotification('Error creating contact (Phone number must be unique).', 'error');
    }
  },

  async handleCreateScheduleSMS(e) {
    e.preventDefault();
    const contactId = Number(document.getElementById('schedule-sms-contact').value);
    const message = document.getElementById('schedule-sms-text').value;
    const scheduledTime = new Date(document.getElementById('schedule-sms-time').value).toISOString();

    await this.db.addScheduledSMS({
      contactId,
      message,
      scheduledTime,
      status: 'pending',
      createdAt: new Date().toISOString()
    });

    // Log the schedule trigger in timeline
    await this.db.addTimelineEntry({
      contactId,
      type: 'note',
      content: `Queued automated SMS: "${message}"`,
      tags: ['AUTOMATION', 'QUEUED_SMS'],
      meta: { targetTime: scheduledTime },
      timestamp: new Date().toISOString()
    });

    this.showNotification('Message scheduled and added to queue.');
    Modals.close('schedule-sms-modal');
    e.target.reset();
    
    this.refreshAllData();
    if (this.currentView === 'thread') {
      this.renderRelationshipThread(this.activeContactId);
    }
  },

  async handleQuickActionSubmit(e) {
    e.preventDefault();
    const contactIdInput = document.getElementById('quick-action-contact-id');
    const contactId = contactIdInput ? Number(contactIdInput.value) : null;
    
    if (!contactId) {
      this.showNotification('Please select a valid contact from the suggestions list.', 'error');
      return;
    }

    const type = document.getElementById('quick-action-type').value;
    const content = document.getElementById('quick-action-text').value;
    
    let meta = {};
    let tags = ['QUICK_ACTION'];

    if (type === 'payment') {
      meta.amount = document.getElementById('quick-payment-amount').value || '৳2,000';
      meta.method = 'BKash Payment Transaction';
      tags.push('PAYMENT');
    } else if (type === 'call') {
      meta.duration = document.getElementById('quick-call-duration').value || '5 mins';
      meta.type = 'outgoing';
      tags.push('CALL');
    } else if (type === 'promise') {
      tags.push('PROMISE');
      
      // Auto register upcoming tracked promise task
      await this.db.addTask({
        contactId,
        title: `Tracked Promise: ${content}`,
        dueDate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString(),
        isCompleted: false,
        isReminder: true,
        createdAt: new Date().toISOString()
      });
    } else if (type === 'note') {
      // Auto-extract tasks from notes containing #task or #promise
      const upper = content.toUpperCase();
      if (upper.includes('#PROMISE') || upper.includes('#TASK') || upper.includes('PROMISED')) {
        let taskTitle = content.replace(/#promise|#task/gi, '').trim();
        if (!taskTitle) taskTitle = `Task from Note: ${content}`;
        
        await this.db.addTask({
          contactId,
          title: taskTitle,
          dueDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
          isCompleted: false,
          isReminder: true,
          createdAt: new Date().toISOString()
        });
        tags.push('CHECKLIST_AUTO');
      }
    }

    await this.db.addTimelineEntry({
      contactId,
      type,
      content,
      tags,
      meta,
      timestamp: new Date().toISOString()
    });

    this.showNotification('Event logged successfully.');
    Modals.close('quick-action-modal');
    e.target.reset();

    // Explicitly reset autocomplete inputs
    const searchInput = document.getElementById('quick-action-contact-search');
    if (searchInput) searchInput.value = '';
    if (contactIdInput) contactIdInput.value = '';
    const suggestionsDiv = document.getElementById('quick-action-suggestions');
    if (suggestionsDiv) {
      suggestionsDiv.innerHTML = '';
      suggestionsDiv.style.display = 'none';
    }

    this.refreshAllData();
    if (this.currentView === 'thread' && this.activeContactId === contactId) {
      this.renderRelationshipThread(contactId);
    }
  },

  onQuickLogTypeChange(val) {
    document.getElementById('quick-subfield-payment').style.display = val === 'payment' ? 'block' : 'none';
    document.getElementById('quick-subfield-call').style.display = val === 'call' ? 'block' : 'none';
  },

  initQuickActionAutocomplete() {
    const searchInput = document.getElementById('quick-action-contact-search');
    const idInput = document.getElementById('quick-action-contact-id');
    const suggestionsDiv = document.getElementById('quick-action-suggestions');

    if (!searchInput || !suggestionsDiv) return;

    // Reset autocomplete values when modal is closed
    const resetAutocomplete = () => {
      searchInput.value = '';
      idInput.value = '';
      suggestionsDiv.innerHTML = '';
      suggestionsDiv.style.display = 'none';
    };

    // Close suggestions on click outside
    document.addEventListener('click', (e) => {
      if (e.target !== searchInput && e.target !== suggestionsDiv && !suggestionsDiv.contains(e.target)) {
        suggestionsDiv.style.display = 'none';
      }
    });

    searchInput.addEventListener('input', async () => {
      const val = searchInput.value.trim();
      idInput.value = ''; // Reset ID since they typed
      
      if (!val) {
        suggestionsDiv.innerHTML = '';
        suggestionsDiv.style.display = 'none';
        return;
      }

      const contacts = await this.db.getAllContacts();
      const query = val.toLowerCase();
      
      // Filter contacts
      const matches = contacts.filter(c => c.name.toLowerCase().includes(query));
      
      suggestionsDiv.innerHTML = '';
      
      if (matches.length > 0) {
        matches.forEach(c => {
          const item = document.createElement('div');
          item.className = 'autocomplete-suggestion';
          item.innerHTML = `
            <span>${c.name}</span>
            <span class="suggestion-phone">${c.phone}</span>
          `;
          item.addEventListener('mousedown', (e) => {
            e.preventDefault(); // Prevent blur
            searchInput.value = c.name;
            idInput.value = c.id;
            suggestionsDiv.style.display = 'none';
          });
          suggestionsDiv.appendChild(item);
        });
      }

      // Check if there is an exact name match
      const exactMatch = contacts.some(c => c.name.toLowerCase() === query);
      if (!exactMatch) {
        const createItem = document.createElement('div');
        createItem.className = 'autocomplete-suggestion';
        createItem.innerHTML = `
          <span class="suggestion-new">Create new contact "${val}"</span>
          <span class="material-symbols-outlined" style="font-size: 16px; color: var(--primary);">person_add</span>
        `;
        createItem.addEventListener('mousedown', (e) => {
          e.preventDefault(); // Prevent blur
          
          // 1. Close current event log modal
          Modals.close('quick-action-modal');
          
          // Reset autocomplete/search inputs
          resetAutocomplete();
          
          // 2. Open create contact modal
          Modals.open('add-contact-modal');
          
          // 3. Populate name
          const nameInput = document.getElementById('new-contact-name');
          if (nameInput) {
            nameInput.value = val;
          }
          
          // 4. Focus phone input
          setTimeout(() => {
            const phoneInput = document.getElementById('new-contact-phone');
            if (phoneInput) {
              phoneInput.focus();
            }
          }, 150);
        });
        suggestionsDiv.appendChild(createItem);
      }

      suggestionsDiv.style.display = 'block';
    });

    // Handle focus event to show matches if search query exists
    searchInput.addEventListener('focus', async () => {
      const val = searchInput.value.trim();
      if (val) {
        searchInput.dispatchEvent(new Event('input'));
      }
    });
  },

  async toggleTaskComplete(taskId) {
    const tasks = await this.db.getAllTasks();
    const task = tasks.find(t => t.id === taskId);
    if (!task) return;

    await this.db.updateTask(taskId, { isCompleted: !task.isCompleted });
    
    // Log timeline note
    await this.db.addTimelineEntry({
      contactId: task.contactId,
      type: 'note',
      content: `Completed Action Checklist Task: "${task.title}"`,
      tags: ['CHECKLIST', 'TASK_DONE'],
      meta: {},
      timestamp: new Date().toISOString()
    });

    this.showNotification('Task checklist updated successfully.');
    this.refreshAllData();
    if (this.currentView === 'thread') {
      this.renderRelationshipThread(this.activeContactId);
    }
  },

  // UTILITY DROPDOWN HELPERS
  async populateContactsDropdowns() {
    const contacts = await this.db.getAllContacts();
    
    const dropdowns = [
      document.getElementById('schedule-sms-contact'),
      document.getElementById('share-contact-select')
    ];

    dropdowns.forEach(dd => {
      if (!dd) return;
      const prevVal = dd.value;
      dd.innerHTML = '';
      contacts.forEach(c => {
        dd.insertAdjacentHTML('beforeend', `<option value="${c.id}">${c.name} (${c.phone})</option>`);
      });
      if (prevVal) {
        dd.value = prevVal;
      }
    });
  },

  // NOTIFICATION BANNER UTILITIES
  showNotification(text, type = 'success') {
    const banner = document.getElementById('notif-banner');
    const bannerText = document.getElementById('notif-text');
    
    bannerText.textContent = text;
    banner.style.transform = 'translateX(-50%) translateY(30px)';
    
    const icon = banner.querySelector('.material-symbols-outlined');
    if (type === 'error') {
      icon.textContent = 'error';
      icon.style.color = 'var(--rose)';
    } else if (type === 'info') {
      icon.textContent = 'info';
      icon.style.color = 'var(--primary)';
    } else {
      icon.textContent = 'check_circle';
      icon.style.color = 'var(--emerald)';
    }

    setTimeout(() => {
      banner.style.transform = 'translateX(-50%) translateY(-100px)';
    }, 3000);
  }
};

// ================= MODAL OVERLAYS TRIGGER LAYER =================
const Modals = {
  open(id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.add('active');
  },
  close(id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.remove('active');
  }
};

// ================= SIMULATED SHARE SHEET CONTROLLER =================
const ShareSheet = {
  init() {
    this.onSourceChange('bKash');
  },

  toggle() {
    const el = document.getElementById('share-sheet-drawer');
    el.classList.toggle('active');
    App.populateContactsDropdowns();
  },

  onSourceChange(val) {
    const preview = document.getElementById('share-preview');
    let text = '';
    
    if (val === 'bKash') {
      text = `
        <strong>bKash Receipt Shared</strong><br>
        Transaction: 2026_XM_4492<br>
        Amount: ৳12,000<br>
        Ref: Banani AC final settlement
      `;
      window.PocketShareSimulator.setAsset('receipt', 'Final settlement for AC Repair installation.', {
        amount: '৳12,000',
        method: 'bKash Transaction: 2026_XM_4492'
      });
    } else if (val === 'WhatsApp') {
      text = `
        <strong>WhatsApp Chat Screenshot Shared</strong><br>
        Attachment: chat_export_AC_repair.png<br>
        Image Payload: Base64 Canvas Screen
      `;
      window.PocketShareSimulator.setAsset('screenshot', 'Screenshot check of completed AC vents.', {
        // SVG mock payload
        dataUri: 'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="300" height="150" viewBox="0 0 300 150"><rect width="300" height="150" fill="%23eeedf7"/><text x="15" y="45" font-family="sans-serif" font-size="14" font-weight="bold" fill="%233525cd">WhatsApp Chat Export</text><text x="15" y="75" font-family="sans-serif" font-size="12" fill="%231a1b22">"Vents are fully cleaned. Work done!"</text><text x="15" y="110" font-family="sans-serif" font-size="10" fill="%23777587">Arif AC &bull; Sent 10m ago</text></svg>'
      });
    } else if (val === 'Maps') {
      text = `
        <strong>Google Maps Location Shared</strong><br>
        Address: Road 11, Banani, Dhaka<br>
        Coordinates: 23.7937° N, 90.4066° E
      `;
      window.PocketShareSimulator.setAsset('location', 'Met at Banani Road 11 AC workshop.', {
        address: 'Road 11, Banani, Dhaka',
        coords: '23.7937, 90.4066'
      });
    }

    preview.innerHTML = text;
  },

  async submitShare() {
    const contactId = Number(document.getElementById('share-contact-select').value);
    
    try {
      const entryId = await window.PocketShareSimulator.shareToContact(App.db, contactId);
      const contact = await App.db.getContact(contactId);
      
      this.toggle();
      App.refreshAllData();
      
      if (App.currentView === 'thread' && App.activeContactId === contactId) {
        App.renderRelationshipThread(contactId);
      }
      
      App.showNotification(`Shared asset logged successfully to ${contact.name}'s thread!`);
    } catch (err) {
      console.error(err);
      App.showNotification('Error logging shared asset.', 'error');
    }
  }
};

// Start application when DOM loads
window.addEventListener('DOMContentLoaded', () => {
  App.init();
});

// Export globally
window.App = App;
window.Modals = Modals;
window.ShareSheet = ShareSheet;
