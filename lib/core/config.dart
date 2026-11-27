/// Feature flag controlling whether the v2 interface is active.
/// Spec 10 flips the default to `true` and deletes `lib/legacy/`.
const bool kV2 = bool.fromEnvironment('V2', defaultValue: false);
