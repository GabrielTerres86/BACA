PL/SQL Developer Test script 3.0
53
-- Created on 19/01/2021 by F0032948 
declare 
  -- Local variables here
 CURSOR cr_dados is
    select 'f0014849' as usuario from dual
    union
    select 'f0015250' as usuario from dual
    union
    select 'f0014235' as usuario from dual
    union
    select 'f0013018' as usuario from dual
    union
    select 'f0014308' as usuario from dual
    union
    select 'f0014987' as usuario from dual
    union
    select 'f0014895' as usuario from dual
    union
    select 'f0013447' as usuario from dual
    union
    select 'f0013307' as usuario from dual
    union
    select 'f0013579' as usuario from dual
    union
    select 'f0012467' as usuario from dual
    union
    select 'f0011742' as usuario from dual
    union
    select 'f0013993' as usuario from dual
    union
    select 'f0013016' as usuario from dual
    union
    select 'f0014129' as usuario from dual
    union
    select 'f0012861' as usuario from dual
    ;
    rw_dados cr_dados%ROWTYPE;  
begin
   FOR rw_dados IN cr_dados LOOP
   begin
  -- Test statements here
  insert into crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('ATENDA', 'A', ''||rw_dados.usuario||'', 'CONVENIO CDC', 1, 1, 0, 2);
  commit;
  dbms_output.put_line ('OK: '||rw_dados.usuario);
  exception when others then
    dbms_output.put_line ('Erro: '||rw_dados.usuario);
    continue;
  end;
  end loop;

end;

0
0
