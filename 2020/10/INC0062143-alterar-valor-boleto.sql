/*
(Luiz Cherpers(Mouts) - INC0062143)
Ajuste valor boleto - 1392 de 105 bi para 1050.00
*/
declare
  -- Local variables here
  vr_dserro   VARCHAR2(100);
  vr_dscritic VARCHAR2(4000);

  cursor cr_crapcob is
    SELECT cob.rowid
      FROM crapcob cob
     WHERE cob.nrdconta = 7204299
       AND cob.cdcooper = 1
       AND cob.nrcnvcob = 101002
       AND cob.nrdocmto = 1392;

begin

  for rw_dados in cr_crapcob loop
    begin
      update crapcob
         set crapcob.vltitulo = 1050.00
       where crapcob.rowid = rw_dados.rowid;
    
      paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_dados.rowid,
                                    pr_cdoperad => '1',
                                    pr_dtmvtolt => trunc(SYSDATE),
                                    pr_dsmensag => 'Ajuste efetuado no valor do título devido à emissão incorreta',
                                    pr_des_erro => vr_dserro,
                                    pr_dscritic => vr_dscritic);
    end;
  
  end loop;
  commit;
end;
