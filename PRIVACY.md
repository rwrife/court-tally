# Court Tally privacy policy

**Applies to:** Court Tally 1.0.0 and later

Court Tally is an offline, local-first scorekeeper. It requires no account,
cloud service, analytics service, advertising service, or network connection
to score and retain matches.

## Data the app stores

Court Tally stores player or team names, rules presets, score events, in-progress
matches, and match history in the app's private local database on the device.
The developer does not operate a backend that receives this information.
Court Tally includes no analytics, no advertising SDK, and no user tracking.

## Permissions and collection

The app does not request location, contacts, health, Bluetooth, microphone,
camera, notification, or broad-storage permission. It does not collect data for
tracking or link local match data to an identity. Platform stores may process
download or purchase telemetry under their own policies; that store processing
is not performed by Court Tally.

## Export, import, and sharing

JSON backup/import and CSV export happen only after an explicit user action.
The operating-system picker or share sheet lets the user choose the destination
or recipient. JSON is the lossless backup format; CSV is a summary and cannot
restore a Court Tally database. Once a user sends a file to another app,
person, cloud drive, or service, that recipient's privacy terms apply.

Imports are validated before writing. Merge and replace are separate confirmed
operations. Replace can remove local records not present in the selected backup.

## Retention, deletion, uninstall, and backup

Local records remain until the user deletes them in Court Tally, replaces them
with an imported backup, clears app data, or uninstalls the app. Uninstalling or
clearing app data normally removes the local database. Operating-system device
backups may retain app data according to the user's platform backup settings.
Court Tally does not control those backups.

Users should create and verify a JSON backup before uninstalling, clearing app
data, replacing history, changing devices, or installing an unverified build.
The developer cannot recover a lost local database because no server copy
exists.

## Changes and questions

Material privacy changes must be documented in the changelog and this policy
before release. Questions and policy defects may be reported through the
project's GitHub issue tracker: <https://github.com/rwrife/court-tally/issues>.
Do not include private match data in a public issue.
