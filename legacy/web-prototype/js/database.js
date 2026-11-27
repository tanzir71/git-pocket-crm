/**
 * PocketDB - Local-First IndexedDB wrapper for PocketCRM
 */
const DB_NAME = 'PocketCRM_DB';
const DB_VERSION = 1;

class PocketDatabase {
  constructor() {
    this.db = null;
  }

  open() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(DB_NAME, DB_VERSION);

      request.onupgradeneeded = (event) => {
        const db = event.target.result;

        // Contacts store
        if (!db.objectStoreNames.contains('contacts')) {
          const contactStore = db.createObjectStore('contacts', { keyPath: 'id', autoIncrement: true });
          contactStore.createIndex('name', 'name', { unique: false });
          contactStore.createIndex('phone', 'phone', { unique: true });
          contactStore.createIndex('category', 'category', { unique: false });
          contactStore.createIndex('status', 'status', { unique: false });
          contactStore.createIndex('isPinned', 'isPinned', { unique: false });
          contactStore.createIndex('isFavorite', 'isFavorite', { unique: false });
        }

        // Timeline events store
        if (!db.objectStoreNames.contains('timeline')) {
          const timelineStore = db.createObjectStore('timeline', { keyPath: 'id', autoIncrement: true });
          timelineStore.createIndex('contactId', 'contactId', { unique: false });
          timelineStore.createIndex('timestamp', 'timestamp', { unique: false });
          timelineStore.createIndex('type', 'type', { unique: false });
        }

        // Scheduled SMS store
        if (!db.objectStoreNames.contains('scheduled_sms')) {
          const smsStore = db.createObjectStore('scheduled_sms', { keyPath: 'id', autoIncrement: true });
          smsStore.createIndex('contactId', 'contactId', { unique: false });
          smsStore.createIndex('status', 'status', { unique: false });
          smsStore.createIndex('scheduledTime', 'scheduledTime', { unique: false });
        }

        // Tasks and reminders store
        if (!db.objectStoreNames.contains('tasks')) {
          const taskStore = db.createObjectStore('tasks', { keyPath: 'id', autoIncrement: true });
          taskStore.createIndex('contactId', 'contactId', { unique: false });
          taskStore.createIndex('dueDate', 'dueDate', { unique: false });
          taskStore.createIndex('isCompleted', 'isCompleted', { unique: false });
        }
      };

      request.onsuccess = (event) => {
        this.db = event.target.result;
        this.seedMockData().then(() => resolve(this));
      };

      request.onerror = (event) => {
        console.error('IndexedDB open error:', event.target.error);
        reject(event.target.error);
      };
    });
  }

  // Generic helper for transactions
  _getTransaction(storeName, mode = 'readonly') {
    const transaction = this.db.transaction([storeName], mode);
    const store = transaction.objectStore(storeName);
    return { transaction, store };
  }

  // CONTACTS OPERATIONS
  getAllContacts() {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('contacts');
      const request = store.getAll();
      request.onsuccess = () => resolve(request.result || []);
      request.onerror = () => reject(request.error);
    });
  }

  getContact(id) {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('contacts');
      const request = store.get(Number(id));
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  addContact(contact) {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('contacts', 'readwrite');
      const request = store.add(contact);
      request.onsuccess = (e) => resolve(e.target.result);
      request.onerror = () => reject(request.error);
    });
  }

  updateContact(id, updates) {
    return new Promise((resolve, reject) => {
      this.getContact(id).then(contact => {
        if (!contact) {
          reject(new Error('Contact not found'));
          return;
        }
        const updatedContact = { ...contact, ...updates };
        const { store } = this._getTransaction('contacts', 'readwrite');
        const request = store.put(updatedContact);
        request.onsuccess = () => resolve(updatedContact);
        request.onerror = () => reject(request.error);
      }).catch(reject);
    });
  }

  deleteContact(id) {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('contacts', 'readwrite');
      const request = store.delete(Number(id));
      request.onsuccess = () => resolve(true);
      request.onerror = () => reject(request.error);
    });
  }

  // TIMELINE EVENT OPERATIONS
  getTimelineForContact(contactId) {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('timeline');
      const index = store.index('contactId');
      const request = index.getAll(Number(contactId));
      request.onsuccess = () => {
        const results = request.result || [];
        // Sort by timestamp descending
        results.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        resolve(results);
      };
      request.onerror = () => reject(request.error);
    });
  }

  getAllTimeline() {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('timeline');
      const request = store.getAll();
      request.onsuccess = () => {
        const results = request.result || [];
        results.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        resolve(results);
      };
      request.onerror = () => reject(request.error);
    });
  }

  addTimelineEntry(entry) {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('timeline', 'readwrite');
      const request = store.add(entry);
      request.onsuccess = (e) => {
        const insertedId = e.target.result;
        // Update contact last contacted status
        this.updateContact(entry.contactId, { lastContacted: entry.timestamp });
        resolve(insertedId);
      };
      request.onerror = () => reject(request.error);
    });
  }

  deleteTimelineEntry(id) {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('timeline', 'readwrite');
      const request = store.delete(Number(id));
      request.onsuccess = () => resolve(true);
      request.onerror = () => reject(request.error);
    });
  }

  // SCHEDULED SMS OPERATIONS
  getAllScheduledSMS() {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('scheduled_sms');
      const request = store.getAll();
      request.onsuccess = () => {
        const results = request.result || [];
        results.sort((a, b) => new Date(a.scheduledTime) - new Date(b.scheduledTime));
        resolve(results);
      };
      request.onerror = () => reject(request.error);
    });
  }

  addScheduledSMS(sms) {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('scheduled_sms', 'readwrite');
      const request = store.add(sms);
      request.onsuccess = (e) => resolve(e.target.result);
      request.onerror = () => reject(request.error);
    });
  }

  updateScheduledSMS(id, updates) {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('scheduled_sms', 'readwrite');
      const getReq = store.get(Number(id));
      getReq.onsuccess = () => {
        const data = getReq.result;
        if (!data) {
          reject(new Error('SMS not found'));
          return;
        }
        const updated = { ...data, ...updates };
        const putReq = store.put(updated);
        putReq.onsuccess = () => resolve(updated);
        putReq.onerror = () => reject(putReq.error);
      };
      getReq.onerror = () => reject(getReq.error);
    });
  }

  deleteScheduledSMS(id) {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('scheduled_sms', 'readwrite');
      const request = store.delete(Number(id));
      request.onsuccess = () => resolve(true);
      request.onerror = () => reject(request.error);
    });
  }

  // TASKS AND REMINDERS OPERATIONS
  getAllTasks() {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('tasks');
      const request = store.getAll();
      request.onsuccess = () => {
        const results = request.result || [];
        results.sort((a, b) => new Date(a.dueDate) - new Date(b.dueDate));
        resolve(results);
      };
      request.onerror = () => reject(request.error);
    });
  }

  addTask(task) {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('tasks', 'readwrite');
      const request = store.add(task);
      request.onsuccess = (e) => resolve(e.target.result);
      request.onerror = () => reject(request.error);
    });
  }

  updateTask(id, updates) {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('tasks', 'readwrite');
      const getReq = store.get(Number(id));
      getReq.onsuccess = () => {
        const data = getReq.result;
        if (!data) {
          reject(new Error('Task not found'));
          return;
        }
        const updated = { ...data, ...updates };
        const putReq = store.put(updated);
        putReq.onsuccess = () => resolve(updated);
        putReq.onerror = () => reject(putReq.error);
      };
      getReq.onerror = () => reject(getReq.error);
    });
  }

  deleteTask(id) {
    return new Promise((resolve, reject) => {
      const { store } = this._getTransaction('tasks', 'readwrite');
      const request = store.delete(Number(id));
      request.onsuccess = () => resolve(true);
      request.onerror = () => reject(request.error);
    });
  }

  // SEED RICH MOCK DATA
  seedMockData() {
    return new Promise((resolve, reject) => {
      this.getAllContacts().then(contacts => {
        if (contacts.length > 0) {
          // Already seeded
          resolve();
          return;
        }

        const mockContacts = [
          {
            id: 1,
            name: 'Arif (AC Repair)',
            phone: '+880 1711-555222',
            email: 'arif.coolings@gmail.com',
            avatarColor: '#ba1a1a', // Crimson/Red
            category: 'Contractor',
            status: 'Active',
            isPinned: true,
            isFavorite: true,
            fbProfile: 'https://facebook.com/arif.ac.services',
            linkedinProfile: '',
            gmailProfile: 'arif.coolings@gmail.com',
            pinnedNote: 'Located at Banani, Quoted ৳12,000 for full VRF/split AC installations and annual maintenance contract.',
            lastContacted: '2026-05-21T14:00:00+06:00',
            createdAt: '2026-05-01T10:00:00Z'
          },
          {
            id: 2,
            name: 'Jane Doe',
            phone: '+1 (555) 019-2834',
            email: 'jane.doe@architects.com',
            avatarColor: '#3525cd', // Indigo
            category: 'Partner',
            status: 'Starred',
            isPinned: true,
            isFavorite: true,
            fbProfile: 'https://facebook.com/janedoe.arch',
            linkedinProfile: 'https://linkedin.com/in/jane-doe-architect',
            gmailProfile: 'jane.doe@architects.com',
            pinnedNote: 'Lead architect for the Q4 launch phase. Focus on sustainability metrics.',
            lastContacted: '2026-05-20T17:00:00Z',
            createdAt: '2026-05-01T10:00:00Z'
          },
          {
            id: 3,
            name: 'Marcus Chen',
            phone: '+1 (555) 092-3341',
            email: 'marcus.chen@techventures.io',
            avatarColor: '#5c5f61', // Slate
            category: 'Client',
            status: 'Starred',
            isPinned: true,
            isFavorite: false,
            fbProfile: '',
            linkedinProfile: 'https://linkedin.com/in/marcus-chen-invests',
            gmailProfile: 'marcus.chen@techventures.io',
            pinnedNote: 'Interested in the modern relationship tracker concept. Follow up in late May.',
            lastContacted: '2026-05-19T11:00:00Z',
            createdAt: '2026-05-01T10:00:00Z'
          },
          {
            id: 4,
            name: 'Claire Chen',
            phone: '+1 (555) 128-9902',
            email: 'claire.c@design.co',
            avatarColor: '#7e3000', // Amber/Orange
            category: 'Creative',
            status: 'Partner',
            isPinned: false,
            isFavorite: true,
            fbProfile: 'https://facebook.com/claire.chen.designs',
            linkedinProfile: 'https://linkedin.com/in/claire-chen-design',
            gmailProfile: 'claire.c@design.co',
            pinnedNote: 'Met at the design summit in London. Talented in micro-animations and typography.',
            lastContacted: '2026-05-21T13:15:00Z',
            createdAt: '2026-05-01T10:00:00Z'
          },
          {
            id: 5,
            name: 'Sarah Jenkins',
            phone: '+1 (555) 238-9921',
            email: 's.jenkins@corporate.com',
            avatarColor: '#10b981', // Emerald
            category: 'Doctor',
            status: 'Active',
            isPinned: false,
            isFavorite: false,
            fbProfile: '',
            linkedinProfile: 'https://linkedin.com/in/sarah-jenkins-md',
            gmailProfile: 's.jenkins@corporate.com',
            pinnedNote: 'Contact person for our wellness group scheme.',
            lastContacted: '2026-05-20T08:30:00Z',
            createdAt: '2026-05-02T10:00:00Z'
          },
          {
            id: 6,
            name: 'David Kim',
            phone: '+1 (555) 776-2210',
            email: 'david@venture.io',
            avatarColor: '#ffd2be', // Muted Orange
            category: 'Vendor',
            status: 'Cold Lead',
            isPinned: false,
            isFavorite: false,
            fbProfile: '',
            linkedinProfile: 'https://linkedin.com/in/david-kim-ventures',
            gmailProfile: 'david@venture.io',
            pinnedNote: 'Supplier of premium hardware prototypes.',
            lastContacted: '2026-05-15T09:00:00Z',
            createdAt: '2026-05-03T10:00:00Z'
          }
        ];

        const mockTimeline = [
          // Timeline for Arif (AC Repair) - ID 1
          {
            contactId: 1,
            type: 'call',
            content: 'Outgoing call to confirm scheduling.',
            tags: ['SCHEDULE', 'AC_REPAIR'],
            meta: { duration: '4 mins', type: 'outgoing' },
            timestamp: '2026-05-21T14:00:00+06:00'
          },
          {
            contactId: 1,
            type: 'screenshot',
            content: 'Service confirmation screenshot sent via WhatsApp.',
            tags: ['RECEIPT', 'SCHEDULE'],
            meta: { 
              fileType: 'image/png',
              // Clean placeholder confirmation image
              fileDataUri: 'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="300" height="150" viewBox="0 0 300 150"><rect width="300" height="150" fill="%23f4f2fd"/><text x="15" y="45" font-family="sans-serif" font-size="14" font-weight="bold" fill="%233525cd">Cooling Services Ltd.</text><text x="15" y="75" font-family="sans-serif" font-size="12" fill="%23464555">Booking Confirmed: Friday, May 22</text><text x="15" y="100" font-family="sans-serif" font-size="12" fill="%23464555">Estimated Cost: ৳12,000</text><text x="15" y="125" font-family="sans-serif" font-size="11" font-weight="bold" fill="%2310b981">bKash Deposit Received: ৳2,000</text></svg>'
            },
            timestamp: '2026-05-21T13:15:00+06:00'
          },
          {
            contactId: 1,
            type: 'payment',
            content: 'Sent advance payment to secure slot.',
            tags: ['PAYMENT', 'BKASH'],
            meta: { amount: '৳2,000', method: 'bKash Transaction: 2026_XM_4492' },
            timestamp: '2026-05-20T11:00:00+06:00'
          },
          {
            contactId: 1,
            type: 'note',
            content: 'Met at Banani AC center. Quoted ৳12,000 for VRF split installations. Mentioned Friday is the best day to start.',
            tags: ['QUOTE', 'MEETING'],
            meta: { location: 'Banani, Dhaka' },
            timestamp: '2026-05-18T10:30:00+06:00'
          },

          // Timeline for Jane Doe - ID 2
          {
            contactId: 2,
            type: 'note',
            content: 'Discussed architectural blueprints and draft plans. Pinned the milestone deliverables.',
            tags: ['BLUEPRINTS', 'DESIGN'],
            meta: {},
            timestamp: '2026-05-20T17:00:00Z'
          },
          {
            contactId: 2,
            type: 'call',
            content: 'Incoming call regarding Q4 launch delays. Discussed mitigation pathways.',
            tags: ['LAUNCH', 'URGENT'],
            meta: { duration: '18 mins', type: 'incoming' },
            timestamp: '2026-05-19T14:10:00Z'
          },

          // Timeline for Marcus Chen - ID 3
          {
            contactId: 3,
            type: 'note',
            content: 'Initial discussion on investment scope. Marcus was highly impressed by the local-first security architecture.',
            tags: ['DEAL', 'PITCH'],
            meta: {},
            timestamp: '2026-05-19T11:00:00Z'
          },

          // Timeline for Claire Chen - ID 4
          {
            contactId: 4,
            type: 'note',
            content: 'Service scheduled for Friday. Claire will deliver initial SVG assets and color variables.',
            tags: ['ASSETS', 'SCHEDULE'],
            meta: {},
            timestamp: '2026-05-21T13:15:00Z'
          }
        ];

        const mockSMS = [
          {
            contactId: 3,
            message: 'Marcus, confirmed for our quarterly review on Tuesday. I\'ll bring the updated portfolio docs.',
            scheduledTime: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // Tomorrow
            status: 'pending',
            createdAt: new Date().toISOString()
          },
          {
            contactId: 5,
            message: 'Happy work anniversary at the firm, Sarah! It\'s been great working together this year.',
            scheduledTime: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString(), 
            status: 'pending',
            createdAt: new Date().toISOString()
          },
          {
            contactId: 6,
            message: 'Hi David, just checking in regarding the hardware prototype shipment #4492.',
            scheduledTime: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000).toISOString(), 
            status: 'paused',
            createdAt: new Date().toISOString()
          }
        ];

        const mockTasks = [
          {
            contactId: 1,
            title: 'Verify AC Repair installation at Banani',
            dueDate: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // Tomorrow
            isCompleted: false,
            isReminder: true,
            isRecurring: false,
            createdAt: new Date().toISOString()
          },
          {
            contactId: 2,
            title: 'Send architectural review feedback to Jane',
            dueDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
            isCompleted: false,
            isReminder: true,
            isRecurring: false,
            createdAt: new Date().toISOString()
          },
          {
            contactId: 3,
            title: 'Prepare VC Investment pitch deck',
            dueDate: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(), // Overdue!
            isCompleted: false,
            isReminder: false,
            isRecurring: false,
            createdAt: new Date().toISOString()
          },
          {
            contactId: 4,
            title: 'Weekly sync with Claire Chen on style specs',
            dueDate: new Date(Date.now() + 6 * 24 * 60 * 60 * 1000).toISOString(),
            isCompleted: false,
            isReminder: true,
            isRecurring: true,
            recurrenceInterval: 'weekly',
            createdAt: new Date().toISOString()
          }
        ];

        // Perform transactional writes
        const contactTX = this.db.transaction(['contacts'], 'readwrite');
        const contactStore = contactTX.objectStore('contacts');
        mockContacts.forEach(c => contactStore.add(c));

        contactTX.oncomplete = () => {
          const mainTX = this.db.transaction(['timeline', 'scheduled_sms', 'tasks'], 'readwrite');
          
          const timelineStore = mainTX.objectStore('timeline');
          mockTimeline.forEach(t => timelineStore.add(t));

          const smsStore = mainTX.objectStore('scheduled_sms');
          mockSMS.forEach(s => smsStore.add(s));

          const taskStore = mainTX.objectStore('tasks');
          mockTasks.forEach(tk => taskStore.add(tk));

          mainTX.oncomplete = () => {
            console.log('Seeded database successfully.');
            resolve();
          };
          mainTX.onerror = (e) => reject(e.target.error);
        };

        contactTX.onerror = (e) => reject(e.target.error);
      }).catch(reject);
    });
  }
}

// Export database class globally so files can access it
window.PocketDB = new PocketDatabase();
