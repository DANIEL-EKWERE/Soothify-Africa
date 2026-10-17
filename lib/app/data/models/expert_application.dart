/// What an applicant says they practise — Figma "Become an expert Form"
/// (`259:59145`), the first question.
enum ExpertField {
  therapist('Licensed Therapist', 'therapy'),
  yoga('Certified Yoga Instructor', 'yoga'),
  pilates('Certified Pilates Instructor', 'pilates');

  const ExpertField(this.label, this.key);

  final String label;

  /// What the server calls it. The label is the frame's wording and is not
  /// safe to send: "Certified Yoga Instructor" is not a discipline.
  final String key;

  static ExpertField? fromKey(String key) {
    for (final field in values) {
      if (field.key == key) return field;
    }
    return null;
  }
}

/// The languages a session can be run in — `259:59179`.
///
/// The same two the app itself offers, which is why the intro promises
/// "English or Pidgin".
enum ExpertLanguage {
  english('English', 'english'),
  pidgin('Pidgin English', 'pidgin');

  const ExpertLanguage(this.label, this.key);

  final String label;
  final String key;

  static ExpertLanguage? fromKey(String key) {
    for (final language in values) {
      if (language.key == key) return language;
    }
    return null;
  }
}

/// A document the application asks to be uploaded — `259:59198`.
///
/// Both are marked with an asterisk in the frame, so both are required.
enum ExpertDocument {
  certification(
    'Upload official certification, degree, or practicing license '
    '(PDF, JPG, or PNG)*',
  ),
  identity(
    'Government-issued photo ID (NIN, International Passport) for identity '
    'verification*',
  );

  const ExpertDocument(this.prompt);

  final String prompt;
}

/// A document the applicant has attached.
///
/// Only what the form needs to show and send: the name it was picked under,
/// where it is on disk, and how big it is. Deliberately not the bytes — a
/// scan of a passport is not something to hold in memory across three form
/// steps.
class AttachedDocument {
  const AttachedDocument({
    required this.name,
    required this.path,
    required this.bytes,
  });

  final String name;
  final String path;

  /// Size on disk, for the "2.4 MB" the row shows.
  final int bytes;

  /// The frame gives no size limit. 10 MB is this app's: a phone photo of a
  /// certificate is ~3-5 MB, and anything far past that is a scan that will
  /// fail to upload on the connections these users have.
  static const int maxBytes = 10 * 1024 * 1024;

  bool get tooLarge => bytes > maxBytes;

  String get size {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).round()} KB';
    return '$bytes B';
  }
}

/// The three form steps, in the order the frames run.
///
/// The progress bar carries three segments and fills one more per step —
/// read off `259:59145`, `259:59179` and `259:59198` in turn. (Each frame
/// also holds a second, misaligned pair of segments at y=69, one of them off
/// the frame entirely; that is a leftover layer, not a fourth step.)
enum ExpertApplicationStep { profile, languages, credentials }


/// Where a sent application stands — what `GET /experts/applications/`
/// answers with.
///
/// The acknowledgement screen used to be the end of the story because
/// nothing received an application. Now that something does, the applicant
/// can be told whether it is still being read.
class ExpertApplicationStatus {
  const ExpertApplicationStatus({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.sentAt,
    this.fields = const {},
  });

  final String id;

  /// 'submitted', 'reviewing', 'approved' or 'rejected'.
  final String status;

  /// The same, in the words the server chose, so one wording is used
  /// everywhere rather than each client inventing its own.
  final String statusLabel;

  final DateTime sentAt;
  final Set<ExpertField> fields;

  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  /// Still being read. Neither of the two outcomes has arrived.
  bool get isPending => !isApproved && !isRejected;

  factory ExpertApplicationStatus.fromJson(Map<String, dynamic> json) =>
      ExpertApplicationStatus(
        id: '${json['id']}',
        status: json['status'] as String? ?? 'submitted',
        statusLabel: json['status_display'] as String? ?? 'Submitted',
        sentAt: DateTime.tryParse('${json['created_at']}')?.toLocal() ??
            DateTime.now(),
        fields: {
          for (final key in (json['disciplines'] as List? ?? const []))
            if (ExpertField.fromKey('$key') != null)
              ExpertField.fromKey('$key')!,
        },
      );
}
