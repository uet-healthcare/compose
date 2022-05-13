CREATE TABLE public.profiles (
	user_id uuid references auth.users not null,
	username varchar(255) unique,
	full_name varchar(255),
	avatar_url varchar(255),
	bio varchar(255),
	about text,
	PRIMARY KEY (user_id)
);

-- inserts a row into public.users
create function public.handle_new_user() returns trigger language plpgsql security definer
set
	search_path = public as $$ begin
insert into
	public.profiles (user_id, full_name, avatar_url)
values
	(
		new.id,
		new.raw_user_meta_data ->> 'full_name',
		new.raw_user_meta_data ->> 'avatar_url'
	);

update
	auth.users
set
	raw_user_meta_data = '{}'
where
	id = new.id;

return new;

end;

$$;

-- trigger the function every time a user is created
create trigger on_auth_user_created
after
insert
	on auth.users for each row execute procedure public.handle_new_user();
