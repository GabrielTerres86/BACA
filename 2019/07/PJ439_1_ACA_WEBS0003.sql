declare

begin

update crapaca a
   set a.lstparam= a.lstparam || ',pr_idacionamento'
 where a.nmdeacao='RETORNA_PROPOSTA';
 
 commit;
end;