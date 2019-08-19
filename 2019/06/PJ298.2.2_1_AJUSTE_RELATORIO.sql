declare
 vr_des_erro varchar2(1000);
begin
  -- Call the procedure
  
  for x in (select l.nrseqsol,null cdfilrel  from crapslr l where l.dtsolici>=trunc(sysdate) and l.cdcooper=3 and l.cdprogra='CRPS280') loop
    cecred.gene0002.pc_process_relato_penden(pr_nrseqsol => x.nrseqsol,
                                             pr_cdfilrel => x.cdfilrel,
                                             pr_des_erro => vr_des_erro);
  end loop;
 commit;
end;
