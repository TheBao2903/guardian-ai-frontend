import '../../l10n/app_localizations.dart';
import '../../features/contacts/domain/entities/contact_entity.dart';

/// Display labels only: never rewrite user content or identifiers sent to APIs.
extension LocalizedDomainLabels on AppLocalizations {
  String relationshipLabel(ContactRelationshipEnum value) => switch (value) {
        ContactRelationshipEnum.parent => relationshipParent,
        ContactRelationshipEnum.spouse => relationshipSpouse,
        ContactRelationshipEnum.sibling => relationshipSibling,
        ContactRelationshipEnum.child => relationshipChild,
        ContactRelationshipEnum.friend => relationshipFriend,
        ContactRelationshipEnum.colleague => relationshipColleague,
        ContactRelationshipEnum.other => relationshipOther,
      };

  String templateName(String? id, String fallback, {bool isSystem = true}) {
    if (!isSystem) return fallback;
    return switch (id) {
      'tpl_walk_home' || 'tpl_walking_home' => templateWalkHome,
      'tpl_late_ride' => templateLateRide,
      'tpl_exercise' => templateExercise,
      'tpl_meetup' => templateMeetup,
      'tpl_overtime' => templateOvertime,
      'tpl_commute_transit' => templateCommute,
      'tpl_outdoor_trekking' => templateOutdoor,
      'tpl_alone_home' => templateAlone,
      'tpl_meeting_stranger' => templateStranger,
      _ => fallback,
    };
  }

  String templateDescription(String? id, String fallback,
      {bool isSystem = true}) {
    if (!isSystem) return fallback;
    return switch (id) {
      'tpl_walk_home' || 'tpl_walking_home' => templateWalkHomeDescription,
      'tpl_late_ride' => templateLateRideDescription,
      'tpl_exercise' => templateExerciseDescription,
      'tpl_meetup' => templateMeetupDescription,
      'tpl_overtime' => templateOvertimeDescription,
      'tpl_commute_transit' => templateCommuteDescription,
      'tpl_outdoor_trekking' => templateOutdoorDescription,
      'tpl_alone_home' => templateAloneDescription,
      'tpl_meeting_stranger' => templateStrangerDescription,
      _ => fallback,
    };
  }
}
