CREATE TABLE public.comments (
	comment_id bigserial NOT NULL,
	parent_comment_id bigint,
	post_id bigint references posts(post_id) not null,
	user_id uuid references auth.users not null,
	content varchar(255),
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	PRIMARY KEY (comment_id)
);

CREATE TRIGGER trigger_automatically_update_updated_at_column BEFORE
UPDATE
	ON comments FOR EACH ROW EXECUTE PROCEDURE automatically_update_updated_at_column();
