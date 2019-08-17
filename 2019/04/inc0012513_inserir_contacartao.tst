PL/SQL Developer Test script 3.0
42
-- Created on 17/04/2019 by F0030367 
declare 
  -- Local variables here
  i integer:=0;
  vr_dscritic varchar2(500);
  
  cursor cr_crawcrd is
  select w.cdcooper, 
         w.nrdconta,
         w.nrcctitg
  from crawcrd w
 where w.insitcrd in (3, 4)
   and w.nrcctitg > 0
   and w.cdadmcrd between 10 and 80
   and not exists (SELECT 1
          FROM tbcrd_conta_cartao crd
         WHERE crd.cdcooper = w.cdcooper
           AND crd.nrdconta = w.nrdconta
           and crd.nrconta_cartao = w.nrcctitg);
begin
  -- Test statements here
  for rw_crawcrd in cr_crawcrd loop
     BEGIN  
        INSERT INTO tbcrd_conta_cartao
                    (cdcooper, 
                     nrdconta, 
                     nrconta_cartao)
             VALUES (rw_crawcrd.cdcooper,        --> cdcooper
                     rw_crawcrd.nrdconta,        --> nrdconta
                     rw_crawcrd.nrcctitg); --> nrconta_cartao
      EXCEPTION
        WHEN dup_val_on_index THEN
          NULL; --> Caso ja exista nao deve apresentar critica
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir tbcrd_conta_cartao: '||SQLERRM;
          dbms_output.put_line(vr_dscritic);
       END;
       i:=i+1;
  end loop;
  dbms_output.put_line('Registros criados: '||i);
  Commit;
end;
0
0
