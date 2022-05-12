-- create public buckets
insert into
	storage.buckets (id, name)
values
	('public', 'public');

-- 1. Allow public access to any files in the "public" bucket
create policy "Public Access" on storage.objects for
select
	using (bucket_id = 'public');

-- 1. Allow logged-in access to any files in the "restricted" bucket
create policy "Restricted Insert" on storage.objects for
insert
	with check (bucket_id = 'public');
