CREATE SCHEMA IF NOT EXISTS auth AUTHORIZATION vietlach_admin;

-- auth.users definition

CREATE TABLE auth.users (
	instance_id varchar(255) DEFAULT NULL,
	id uuid NOT NULL UNIQUE,
	aud varchar(255) DEFAULT NULL,
	"role" varchar(255) DEFAULT NULL,
	email varchar(255) DEFAULT NULL UNIQUE,
	encrypted_password varchar(255) DEFAULT NULL,
	confirmed_at timestamptz DEFAULT NULL,
	invited_at timestamptz DEFAULT NULL,
	confirmation_token varchar(255) DEFAULT NULL,
	confirmation_sent_at timestamptz DEFAULT NULL,
	recovery_token varchar(255) DEFAULT NULL,
	recovery_sent_at timestamptz DEFAULT NULL,
	email_change_token varchar(255) DEFAULT NULL,
	email_change varchar(255) DEFAULT NULL,
	email_change_sent_at timestamptz DEFAULT NULL,
	last_sign_in_at timestamptz DEFAULT NULL,
	raw_app_meta_data jsonb DEFAULT NULL,
	raw_user_meta_data jsonb DEFAULT NULL,
	is_super_admin bool DEFAULT NULL,
	created_at timestamptz DEFAULT NULL,
	updated_at timestamptz DEFAULT NULL,
	PRIMARY KEY (id)
);
CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);
CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, email);

-- auth.refresh_tokens definition

CREATE TABLE auth.refresh_tokens (
	instance_id uuid DEFAULT NULL,
	id bigserial NOT NULL,
	"token" varchar(255) DEFAULT NULL,
	user_id varchar(255) DEFAULT NULL,
	revoked bool DEFAULT NULL,
	created_at timestamptz DEFAULT NULL,
	updated_at timestamptz DEFAULT NULL,
	PRIMARY KEY (id)
);
CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);
CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);
CREATE INDEX refresh_tokens_token_idx ON auth.refresh_tokens USING btree (token);
comment on table auth.refresh_tokens is 'Auth: Store of tokens used to refresh JWT tokens once they expire.';

-- auth.instances definition

CREATE TABLE auth.instances (
	id uuid NOT NULL,
	uuid uuid DEFAULT NULL,
	raw_base_config text,
	created_at timestamptz DEFAULT NULL,
	updated_at timestamptz DEFAULT NULL,
	PRIMARY KEY (id)
);
comment on table auth.instances is 'Auth: Manages users across multiple sites.';

-- auth.audit_log_entries definition

CREATE TABLE auth.audit_log_entries (
	instance_id varchar(255) DEFAULT NULL,
	id varchar(255) NOT NULL,
	payload json DEFAULT NULL,
	created_at timestamptz DEFAULT NULL,
	PRIMARY KEY (id)
);
CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);
comment on table auth.audit_log_entries is 'Auth: Audit trail for user actions.';

-- auth.schema_migrations definition

CREATE TABLE auth.schema_migrations (
	version varchar(255) NOT NULL,
	PRIMARY KEY (version)
);
comment on table auth.schema_migrations is 'Auth: Manages updates to the auth system.';

-- functions for storage

create or replace function auth.uid() 
returns uuid 
language sql stable
as $$
  select 
  	coalesce(
		current_setting('request.jwt.claim.sub', true),
		(current_setting('request.jwt.claims', true)::jsonb ->> 'sub')
	)::uuid
$$;

create or replace function auth.role() 
returns text 
language sql stable
as $$
  select 
  	coalesce(
		current_setting('request.jwt.claim.role', true),
		(current_setting('request.jwt.claims', true)::jsonb ->> 'role')
	)::text
$$;

create or replace function auth.email() 
returns text 
language sql stable
as $$
  select 
  	coalesce(
		current_setting('request.jwt.claim.email', true),
		(current_setting('request.jwt.claims', true)::jsonb ->> 'email')
	)::text
$$;

-- usage on auth functions to API roles
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;

-- Supabase super admin
CREATE USER auth_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
GRANT ALL PRIVILEGES ON SCHEMA auth TO auth_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO auth_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA auth TO auth_admin;
ALTER USER auth_admin SET search_path = "auth";
ALTER table "auth".users OWNER TO auth_admin;
ALTER table "auth".refresh_tokens OWNER TO auth_admin;
ALTER table "auth".audit_log_entries OWNER TO auth_admin;
ALTER table "auth".instances OWNER TO auth_admin;
ALTER table "auth".schema_migrations OWNER TO auth_admin;

ALTER FUNCTION "auth"."uid" OWNER TO auth_admin;
ALTER FUNCTION "auth"."role" OWNER TO auth_admin;
ALTER FUNCTION "auth"."email" OWNER TO auth_admin;
GRANT EXECUTE ON FUNCTION "auth"."uid"() TO PUBLIC;
GRANT EXECUTE ON FUNCTION "auth"."role"() TO PUBLIC;
GRANT EXECUTE ON FUNCTION "auth"."email"() TO PUBLIC;
