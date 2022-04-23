CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION postgres;

CREATE TABLE auth.audit_log_entries (
	instance_id varchar(255) DEFAULT NULL,
	id varchar(255) NOT NULL,
	payload jsonb DEFAULT NULL,
	created_at timestamp NULL DEFAULT NULL,
	PRIMARY KEY (id)
);

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);

CREATE TABLE auth.instances (
	id varchar(255) NOT NULL,
	uuid varchar(255) DEFAULT NULL,
	raw_base_config text,
	created_at timestamp NULL DEFAULT NULL,
	updated_at timestamp NULL DEFAULT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE auth.refresh_tokens (
	instance_id varchar(255) DEFAULT NULL,
	id bigserial NOT NULL,
	token varchar(255) DEFAULT NULL,
	user_id varchar(255) DEFAULT NULL,
	revoked bool DEFAULT NULL,
	created_at timestamp NULL DEFAULT NULL,
	updated_at timestamp NULL DEFAULT NULL,
	PRIMARY KEY (id)
);

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);

CREATE INDEX refresh_tokens_token_idx ON auth.refresh_tokens USING btree (token);

CREATE TABLE auth.schema_migration (
	version varchar(255) NOT NULL,
	PRIMARY KEY (version)
);

CREATE TABLE auth.users (
	instance_id varchar(255) DEFAULT NULL,
	id varchar(255) NOT NULL,
	aud varchar(255) DEFAULT NULL,
	role varchar(255) DEFAULT NULL,
	email varchar(255) DEFAULT NULL,
	encrypted_password varchar(255) DEFAULT NULL,
	confirmed_at timestamp NULL DEFAULT NULL,
	invited_at timestamp NULL DEFAULT NULL,
	confirmation_token varchar(255) DEFAULT NULL,
	confirmation_sent_at timestamp NULL DEFAULT NULL,
	recovery_token varchar(255) DEFAULT NULL,
	recovery_sent_at timestamp NULL DEFAULT NULL,
	email_change_token varchar(255) DEFAULT NULL,
	email_change varchar(255) DEFAULT NULL,
	email_change_sent_at timestamp NULL DEFAULT NULL,
	last_sign_in_at timestamp NULL DEFAULT NULL,
	raw_app_meta_data jsonb DEFAULT NULL,
	raw_user_meta_data jsonb DEFAULT NULL,
	is_super_admin bool DEFAULT NULL,
	created_at timestamp NULL DEFAULT NULL,
	updated_at timestamp NULL DEFAULT NULL,
	PRIMARY KEY (id)
);

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, email);
