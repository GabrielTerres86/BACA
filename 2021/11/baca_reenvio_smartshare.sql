-- Created on 26/10/2021 by F0032990 
declare 
   CURSOR cr_reenvios IS
      SELECT f.rowid, f.cdcooper, f.nrdconta, f.nrctremp, c.flgdigit, c.vlemprst,
             c.dtmvtolt, a.cdagenci, f.dscritic
        FROM TBEPR_REENVIO_FTP f 
            ,crapepr c
            ,crapass a
       WHERE f.qtdenvio < nvl(30,0)
         AND f.insitenv = 0 -- Pendente
         AND c.cdcooper = f.cdcooper
         AND c.nrdconta = f.nrdconta
         AND c.nrctremp = f.nrctremp
         AND a.cdcooper = f.cdcooper
         AND a.nrdconta = f.nrdconta
         AND c.tpemprst = 2;

    rw_reenvios cr_reenvios%ROWTYPE; 
    
    vr_dscritic      VARCHAR(1000); 
    vr_exc_saida     EXCEPTION;               
begin

  -- Faz a geração e o envio do contrato novamente
  FOR rw_reenvios IN cr_reenvios LOOP
        
    -- Só faz a geração e o reenvio caso ainda esteja pendente no registro do contrato
    -- Se flgdigit = 1 então já houve a digitalização e o batimento feito pela bo 137
    IF rw_reenvios.flgdigit = 0 THEN 
      EMPR0017.pc_gera_contrato_smartshare(pr_cdcooper => rw_reenvios.cdcooper
                                         , pr_nrdconta => rw_reenvios.nrdconta
                                         , pr_nrctremp => rw_reenvios.nrctremp
                                         , pr_dscritic => vr_dscritic);  
    END IF;
          
    -- Gerou e enviou sem problemas
    IF vr_dscritic is null THEN
      -- Atualiza o registro de reenvio como ENVIADO
      BEGIN
        UPDATE TBEPR_REENVIO_FTP f
           SET f.insitenv =  1 
         WHERE f.rowid = rw_reenvios.rowid;   
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar o registro de reenvio do contrato: '|| sqlerrm;  
      END;  
    END IF;
        
  END LOOP; -- geração e envio
       
  COMMIT;
end;
