declare
vr_des_erro varchar2(1000);
begin
  -- Call the procedure
  
  for x in (select l.nrseqsol,null cdfilrel from crapslr l where dsjasper='crrl220.jasper' and dtmvtolt='30/04/2019') loop
  cecred.gene0002.pc_process_relato_penden(pr_nrseqsol => x.nrseqsol,
                                           pr_cdfilrel => x.cdfilrel,
                                           pr_des_erro => vr_des_erro);
 end loop;
 
 commit;
end;