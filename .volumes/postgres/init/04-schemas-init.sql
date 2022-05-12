-- posts schema
CREATE TYPE post_status AS ENUM (
	'draft',
	'public',
	'private',
	'removed',
	'permanantly_deleted'
);

CREATE TABLE public.posts (
	post_id bigserial NOT NULL,
	user_id uuid references auth.users not null,
	title varchar not null,
	content text not null,
	status post_status not null default 'draft',
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	PRIMARY KEY (post_id)
);

CREATE OR REPLACE FUNCTION public.automatically_update_updated_at_column() 
RETURNS TRIGGER AS $$ 
BEGIN 
	NEW.updated_at = now();
	RETURN NEW;
END;

$$ language 'plpgsql';

CREATE TRIGGER trigger_automatically_update_updated_at_column BEFORE
UPDATE
	ON posts FOR EACH ROW EXECUTE PROCEDURE automatically_update_updated_at_column();
