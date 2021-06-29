-- Deploy test:sample/test to pg

BEGIN;
-- Testing different structures of writing
create FUNCTION 

news(Par int) returns table
            (
                id int,
                code text
            )
            language plpgsql
as
$$
begin
    return query select 1 as id, "a" as code;
end ;
$$;

create OR replace FUNCTION news2(Par int) returns table
            (
                id int,
                code text
            )
as
$$
begin
    return query select 1 as id, "a" as code;
end ;
$$;

create FUNCTION news3 
(Par int ) returns table
            (
                id int,
                code text
            )
as
$$
begin
    return query select 1 as id, "a" as code;
end ;
$$;

CREATE VIEW time AS
select now();

COMMIT;


           