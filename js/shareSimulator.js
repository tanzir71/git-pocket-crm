/**
 * PocketCRM External Share Sheet Simulator.
 * Allows simulating share-actions from native apps into PocketCRM.
 */
class ShareSheetSimulator {
  constructor() {
    this.activeAsset = null;
  }

  setAsset(type, content, meta = {}) {
    this.activeAsset = {
      type,
      content,
      meta,
      timestamp: new Date().toISOString()
    };
  }

  getAsset() {
    return this.activeAsset;
  }

  clear() {
    this.activeAsset = null;
  }

  /**
   * Commit the shared asset to a contact's timeline in PocketDB.
   */
  async shareToContact(db, contactId) {
    if (!this.activeAsset) return null;

    let timelineType = 'note';
    let content = this.activeAsset.content;
    let meta = { ...this.activeAsset.meta };

    switch (this.activeAsset.type) {
      case 'screenshot':
        timelineType = 'screenshot';
        meta.fileType = 'image/png';
        meta.fileDataUri = this.activeAsset.meta.dataUri;
        break;
      case 'receipt':
        timelineType = 'payment';
        meta.amount = this.activeAsset.meta.amount;
        meta.method = this.activeAsset.meta.method;
        break;
      case 'location':
        timelineType = 'note';
        meta.location = this.activeAsset.meta.address;
        break;
      case 'voice':
        timelineType = 'note';
        meta.voiceDuration = this.activeAsset.meta.duration;
        meta.fileDataUri = this.activeAsset.meta.dataUri;
        break;
      default:
        timelineType = 'note';
    }

    const timelineEntry = {
      contactId: Number(contactId),
      type: timelineType,
      content: content,
      tags: ['SHARED', this.activeAsset.type.toUpperCase()],
      meta: meta,
      timestamp: new Date().toISOString()
    };

    const entryId = await db.addTimelineEntry(timelineEntry);
    this.clear();
    return entryId;
  }
}

window.PocketShareSimulator = new ShareSheetSimulator();
