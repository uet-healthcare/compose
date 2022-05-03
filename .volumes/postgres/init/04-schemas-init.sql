CREATE TABLE public.posts (
	post_id bigserial NOT NULL,
	user_id uuid references auth.users not null,
	title varchar not null,
	content text not null,
	created_time timestamptz not null default now(),
	updated_at timestamptz,
	PRIMARY KEY (post_id)
);

CREATE TABLE public.trash_posts (
	post_id bigserial NOT NULL,
	user_id uuid references auth.users not null,
	title varchar not null,
	content text not null,
	created_time timestamptz not null,
	updated_at timestamptz,
	deleted_at timestamptz not null default now(),
	PRIMARY KEY (post_id)
);

CREATE OR REPLACE FUNCTION public.automatically_update_updated_at_column() 
RETURNS TRIGGER AS $$ 
BEGIN 
	NEW.updated_at = now();
	RETURN NEW;
END;

$$ language 'plpgsql';

CREATE TRIGGER trigger_automatically_update_updated_at_column 
BEFORE UPDATE
	ON posts FOR EACH ROW EXECUTE PROCEDURE automatically_update_updated_at_column();

-- move post to trash
create function public.move_post_to_trash() returns trigger language plpgsql security definer
set
	search_path = public as $$ 
begin
	insert into
		public.trash_posts (
			post_id,
			user_id,
			title,
			content,
			created_time,
			updated_at
		)
	values (
		old.post_id,
		old.user_id,
		old.title,
		old.content,
		old.created_time,
		old.updated_at
	);

	return old;
end;
$$;

CREATE TRIGGER trigger_move_post_to_trash
BEFORE DELETE
	ON posts FOR EACH ROW EXECUTE PROCEDURE move_post_to_trash();
