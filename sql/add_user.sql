-- Creates a FCA-PRO login, or resets the password if the account already exists.
-- Set v_user / v_pass below, then run in the Supabase SQL editor.
-- This repo is public: copy to add_user.local.sql before putting a real password in it.

create extension if not exists pgcrypto with schema extensions;
set search_path = public, extensions, auth;

do $$
declare
  v_user  text := 'newuser';
  v_pass  text := 'CHANGE-ME';
  v_email text;
  v_id    uuid;
begin
  v_email := lower(trim(v_user));
  if position('@' in v_email) = 0 then
    v_email := v_email || '@fcapro.app';
  end if;

  select id into v_id from auth.users where email = v_email;

  if v_id is null then
    v_id := gen_random_uuid();

    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change)
    values (
      '00000000-0000-0000-0000-000000000000', v_id, 'authenticated', 'authenticated',
      v_email, crypt(v_pass, gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now(),
      '', '', '', '');

    -- without a matching identity row GoTrue rejects the password grant
    insert into auth.identities (
      id, provider_id, user_id, identity_data, provider,
      last_sign_in_at, created_at, updated_at)
    values (
      gen_random_uuid(), v_id::text, v_id,
      jsonb_build_object('sub', v_id::text, 'email', v_email,
                         'email_verified', true, 'phone_verified', false),
      'email', now(), now(), now());

    raise notice 'created %', v_email;
  else
    update auth.users
       set encrypted_password = crypt(v_pass, gen_salt('bf')),
           email_confirmed_at = coalesce(email_confirmed_at, now()),
           updated_at         = now()
     where id = v_id;

    raise notice 'password reset for %', v_email;
  end if;
end $$;
