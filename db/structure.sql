CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE IF NOT EXISTS "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "first_name" varchar, "last_name" varchar, "email" varchar, "loyalty_tier" integer DEFAULT 0 NOT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE IF NOT EXISTS "order_transactions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "amount" decimal(8,2), "user_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE INDEX "index_order_transactions_on_user_id" ON "order_transactions" ("user_id");
CREATE TABLE IF NOT EXISTS "points" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "type" varchar, "order_transaction_id" integer, "quantity" integer DEFAULT 0, "expired" boolean DEFAULT 'f', "expired_at" datetime, "point_reward_manager_id" integer);
CREATE INDEX "index_points_on_type" ON "points" ("type");
CREATE INDEX "index_points_on_order_transaction_id" ON "points" ("order_transaction_id");
CREATE TABLE IF NOT EXISTS "point_reward_managers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer);
CREATE INDEX "index_point_reward_managers_on_user_id" ON "point_reward_managers" ("user_id");
CREATE INDEX "index_points_on_point_reward_manager_id" ON "points" ("point_reward_manager_id");
INSERT INTO "schema_migrations" (version) VALUES
('20191108084317'),
('20191108090538'),
('20191108222411'),
('20191108224213');


