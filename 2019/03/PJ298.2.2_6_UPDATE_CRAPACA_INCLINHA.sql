declare

begin
UPDATE crapaca
   SET crapaca.lstparam = lstparam || ',pr_vlperidx'
 WHERE crapaca.nmdeacao = 'INCLINHA';

  COMMIT;
end;
