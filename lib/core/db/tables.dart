import 'package:drift/drift.dart';

// ---------------------------------------------------------------------------
// Existing v4 tables (exact table & column names preserved) + v5 columns
// ---------------------------------------------------------------------------

class Contacts extends Table {
  @override
  String get tableName => 'contacts';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get phoneNumber => text().named('phone_number').nullable().unique()();
  TextColumn get displayName => text().named('display_name')();
  TextColumn get avatarColor => text().named('avatar_color').nullable()();
  IntColumn get isStarred => integer().named('is_starred').withDefault(const Constant(0))();
  TextColumn get facebookUrl => text().named('facebook_url').nullable()();
  TextColumn get linkedinUrl => text().named('linkedin_url').nullable()();
  TextColumn get gmailAddress => text().named('gmail_address').nullable()();
  TextColumn get pinnedNote => text().named('pinned_note').nullable()();
  IntColumn get lastSyncTime => integer().named('last_sync_time').withDefault(const Constant(0))();

  // v5 columns
  TextColumn get company => text().nullable()();
  TextColumn get role => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get birthday => text().nullable()();
  TextColumn get about => text().nullable()();
  IntColumn get cadenceDays => integer().named('cadence_days').nullable()();
  IntColumn get cadenceSnoozedUntil => integer().named('cadence_snoozed_until').nullable()();
  IntColumn get lastInteractionAt => integer().named('last_interaction_at').nullable()();
  IntColumn get doNotMessage => integer().named('do_not_message').withDefault(const Constant(0))();
  TextColumn get deviceContactId => text().named('device_contact_id').nullable()();
  TextColumn get source => text().withDefault(const Constant('device'))();
  IntColumn get createdAt => integer().named('created_at').nullable()();
}

class TimelineEntries extends Table {
  @override
  String get tableName => 'timeline';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get contactId =>
      integer().named('contact_id').nullable().references(Contacts, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  IntColumn get timestamp => integer()();
  TextColumn get content => text().nullable()();
  RealColumn get amount => real().nullable()();
  TextColumn get attachmentPath => text().named('attachment_path').nullable()();
  TextColumn get nativeMessageId => text().named('native_message_id').nullable()();
  IntColumn get isPinned => integer().named('is_pinned').withDefault(const Constant(0))();

  // v5 columns
  TextColumn get note => text().nullable()();
  TextColumn get outcome => text().nullable()();
  IntColumn get durationSeconds => integer().named('duration_seconds').nullable()();
  TextColumn get placeName => text().named('place_name').nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get paymentStatus => text().named('payment_status').nullable()();
  RealColumn get suggestedAmount => real().named('suggested_amount').nullable()();
  TextColumn get suggestionState => text().named('suggestion_state').nullable()();
  IntColumn get reviewedAt => integer().named('reviewed_at').nullable()();
  IntColumn get hidden => integer().withDefault(const Constant(0))();
  TextColumn get source => text().nullable()();
  TextColumn get outboxClientId => text().named('outbox_client_id').nullable()();
  IntColumn get editedAt => integer().named('edited_at').nullable()();
}

class ScheduledSmsEntries extends Table {
  @override
  String get tableName => 'scheduled_sms';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get contactId =>
      integer().named('contact_id').nullable().references(Contacts, #id, onDelete: KeyAction.cascade)();
  TextColumn get phoneNumber => text().named('phone_number')();
  TextColumn get message => text()();
  IntColumn get scheduledTime => integer().named('scheduled_time')();
  IntColumn get isSent => integer().named('is_sent').withDefault(const Constant(0))();
  IntColumn get bulkJobId => integer().named('bulk_job_id').nullable()();
}

class Tasks extends Table {
  @override
  String get tableName => 'tasks';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get contactId =>
      integer().named('contact_id').nullable().references(Contacts, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  IntColumn get dueDate => integer().named('due_date')();
  IntColumn get isCompleted => integer().named('is_completed').withDefault(const Constant(0))();
  IntColumn get reminderTime => integer().named('reminder_time').nullable()();

  // v5 columns
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer().named('created_at').nullable()();
  IntColumn get completedAt => integer().named('completed_at').nullable()();
  IntColumn get sourceTimelineId => integer().named('source_timeline_id').nullable()();
}

class ContactLists extends Table {
  @override
  String get tableName => 'contact_lists';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();

  // v5 columns
  IntColumn get cadenceDays => integer().named('cadence_days').nullable()();
  IntColumn get createdAt => integer().named('created_at').nullable()();
}

class ContactListMembers extends Table {
  @override
  String get tableName => 'contact_list_members';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId =>
      integer().named('list_id').nullable().references(ContactLists, #id, onDelete: KeyAction.cascade)();
  IntColumn get contactId =>
      integer().named('contact_id').nullable().references(Contacts, #id, onDelete: KeyAction.cascade)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {listId, contactId},
      ];
}

class BulkSmsJobs extends Table {
  @override
  String get tableName => 'bulk_sms_jobs';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get listName => text().named('list_name')();
  TextColumn get message => text()();
  IntColumn get scheduledTime => integer().named('scheduled_time')();
  IntColumn get isSent => integer().named('is_sent').withDefault(const Constant(0))();
}

// ---------------------------------------------------------------------------
// New v5 tables
// ---------------------------------------------------------------------------

class ContactPhones extends Table {
  @override
  String get tableName => 'contact_phones';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get contactId =>
      integer().named('contact_id').references(Contacts, #id, onDelete: KeyAction.cascade)();
  TextColumn get e164 => text().nullable().unique()();
  TextColumn get raw => text().nullable()();
  TextColumn get label => text().nullable()();
  IntColumn get isPrimary => integer().named('is_primary').withDefault(const Constant(0))();
  IntColumn get isMobile => integer().named('is_mobile').withDefault(const Constant(1))();
}

class TimelineAttachments extends Table {
  @override
  String get tableName => 'timeline_attachments';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get timelineId =>
      integer().named('timeline_id').references(TimelineEntries, #id, onDelete: KeyAction.cascade)();
  TextColumn get path => text()();
  TextColumn get mime => text().nullable()();
  IntColumn get createdAt => integer().named('created_at').nullable()();
}

class Templates extends Table {
  @override
  String get tableName => 'templates';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get body => text()();
  IntColumn get createdAt => integer().named('created_at').nullable()();
  IntColumn get updatedAt => integer().named('updated_at').nullable()();
}

class Campaigns extends Table {
  @override
  String get tableName => 'campaigns';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get bodyTemplate => text().named('body_template')();
  IntColumn get scheduledAt => integer().named('scheduled_at').nullable()();
  TextColumn get status => text()();
  IntColumn get subId => integer().named('sub_id').nullable()();
  IntColumn get paceSeconds => integer().named('pace_seconds').nullable()();
  IntColumn get windowStartMin => integer().named('window_start_min').nullable()();
  IntColumn get windowEndMin => integer().named('window_end_min').nullable()();
  IntColumn get createdAt => integer().named('created_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class OutboxMessages extends Table {
  @override
  String get tableName => 'outbox_messages';

  TextColumn get clientId => text().named('client_id')();
  IntColumn get contactId =>
      integer().named('contact_id').nullable().references(Contacts, #id, onDelete: KeyAction.setNull)();
  TextColumn get campaignId => text().named('campaign_id').nullable()();
  TextColumn get address => text()();
  TextColumn get body => text()();
  IntColumn get dueAt => integer().named('due_at')();
  IntColumn get subId => integer().named('sub_id').nullable()();
  TextColumn get status => text()();
  IntColumn get errorCode => integer().named('error_code').nullable()();
  TextColumn get errorLabel => text().named('error_label').nullable()();
  IntColumn get parts => integer().nullable()();
  IntColumn get attempt => integer().withDefault(const Constant(0))();
  IntColumn get sentAt => integer().named('sent_at').nullable()();
  IntColumn get deliveredAt => integer().named('delivered_at').nullable()();
  TextColumn get providerSmsId => text().named('provider_sms_id').nullable()();
  TextColumn get mergeSummary => text().named('merge_summary').nullable()();
  IntColumn get createdAt => integer().named('created_at').nullable()();
  IntColumn get updatedAt => integer().named('updated_at').nullable()();

  @override
  Set<Column> get primaryKey => {clientId};
}

class Settings extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

class SyncStates extends Table {
  @override
  String get tableName => 'sync_state';

  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
