begin
  -- Call the procedure
  
  for x in (select l.nrseqsol,null cdfilrel from crapslr l where dsjasper='crrl399.jasper' and dtmvtolt='30/04/2019') loop
  cecred.gene0002.pc_process_relato_penden(pr_nrseqsol => x.nrseqsol,
                                           pr_cdfilrel => x.cdfilrel,
                                           pr_des_erro => :pr_des_erro);
 end loop;
 
 commit;
end;