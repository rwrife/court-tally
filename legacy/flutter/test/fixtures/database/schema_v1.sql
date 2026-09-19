PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

CREATE TABLE "rules_presets" (
  "id" TEXT NOT NULL,
  "version" INTEGER NOT NULL,
  "name" TEXT NOT NULL,
  "sport" TEXT NOT NULL,
  "units_to_win" INTEGER NOT NULL,
  "points_to_win_game" INTEGER NOT NULL,
  "win_by" INTEGER NOT NULL,
  "point_cap" INTEGER NULL,
  "games_to_win_set" INTEGER NULL,
  "tiebreak_at_games" INTEGER NULL,
  "tiebreak_points" INTEGER NULL,
  PRIMARY KEY ("id", "version")
);
CREATE TABLE "participants" (
  "id" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "updated_at" INTEGER NOT NULL,
  PRIMARY KEY ("id")
);
CREATE TABLE "matches" (
  "id" TEXT NOT NULL,
  "schema_version" INTEGER NOT NULL DEFAULT 1,
  "preset_id" TEXT NOT NULL,
  "preset_version" INTEGER NOT NULL,
  "sport" TEXT NOT NULL,
  "side_one_name" TEXT NOT NULL,
  "side_two_name" TEXT NOT NULL,
  "participant_search_text" TEXT NOT NULL,
  "status" TEXT NOT NULL,
  "winner" TEXT NULL,
  "created_at" INTEGER NOT NULL,
  "updated_at" INTEGER NOT NULL,
  "completed_at" INTEGER NULL,
  "last_event_sequence" INTEGER NOT NULL DEFAULT -1,
  PRIMARY KEY ("id")
);
CREATE TABLE "match_participants" (
  "match_id" TEXT NOT NULL REFERENCES matches (id) ON DELETE CASCADE,
  "participant_id" TEXT NOT NULL REFERENCES participants (id),
  "participant_name" TEXT NOT NULL,
  "side" TEXT NOT NULL,
  "position" INTEGER NOT NULL,
  PRIMARY KEY ("match_id", "side", "position")
);
CREATE TABLE "score_events" (
  "match_id" TEXT NOT NULL REFERENCES matches (id) ON DELETE CASCADE,
  "sequence" INTEGER NOT NULL,
  "event_type" TEXT NOT NULL,
  "payload_json" TEXT NOT NULL,
  "occurred_at" INTEGER NOT NULL,
  PRIMARY KEY ("match_id", "sequence")
);

INSERT INTO rules_presets VALUES (
  'badminton.bwf.best-of-3-to-21', 1, 'Badminton: best of 3 to 21',
  'badminton', 2, 21, 2, 30, NULL, NULL, NULL
);
INSERT INTO participants VALUES ('schema-v1-north', 'North', 0);
INSERT INTO participants VALUES ('schema-v1-south', 'South', 0);
INSERT INTO matches VALUES (
  'schema-v1-match', 1, 'badminton.bwf.best-of-3-to-21', 1,
  'badminton', 'North', 'South', 'north south',
  'awaitingInitialServer', NULL, 0, 0, NULL, -1
);
INSERT INTO match_participants VALUES (
  'schema-v1-match', 'schema-v1-north', 'North', 'one', 0
);
INSERT INTO match_participants VALUES (
  'schema-v1-match', 'schema-v1-south', 'South', 'two', 0
);

PRAGMA user_version = 1;
COMMIT;
