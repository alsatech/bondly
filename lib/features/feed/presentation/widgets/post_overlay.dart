/// post_overlay.dart
///
/// Renders an optional bottom overlay on the post image showing location or
/// music metadata.
///
/// TECH_DEBT: Location and music fields do not exist in the PostResponse schema
/// as of today. This widget renders nothing until the backend ships those fields.
/// See TECH_DEBT.md — Feed section.
library;

import 'package:flutter/widgets.dart';

/// Placeholder widget — renders nothing while location/music are absent
/// from the backend schema. When those fields arrive, this widget will be
/// updated to display them in a styled overlay row.
class PostOverlay extends StatelessWidget {
  const PostOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // No backend data for location or music yet. Render nothing.
    return const SizedBox.shrink();
  }
}
