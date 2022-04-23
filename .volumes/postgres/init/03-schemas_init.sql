CREATE TABLE public.posts (
	post_id bigserial NOT NULL,
	user_id varchar(255) references auth.users not null,
	title varchar not null,
	content text not null,
	created_time timestamp not null default now(),
	PRIMARY KEY (post_id)
);
