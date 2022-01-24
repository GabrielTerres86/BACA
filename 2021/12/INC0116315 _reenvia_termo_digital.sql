-- Reenvia propostas contratadas via mobile para o smartshare, antes do aditivos_agilidades ter sido implementado
DECLARE
  vr_dscritic crapcri.dscritic%TYPE;
  vr_retxml   xmltype;
   
  CURSOR cr_tbepr_reneg_contratada IS
     SELECT s.cdcooper, s.nrdconta, s.nrctremp, TRUNC(s.dtassinatura) dtassinatura
	   FROM tbcred_assinaturas_contrato s
	   WHERE s.tpproduto = 4 AND s.tpassinatura = 1 AND TRUNC(s.dtassinatura) <= '30/11/2021';     
  rw_tbepr_reneg_contratada cr_tbepr_reneg_contratada%ROWTYPE;    
  
BEGIN
    
  FOR rw_tbepr_reneg_contratada IN cr_tbepr_reneg_contratada LOOP
    
      -- Itens enviados previamente, porém com taxa mensal/anual zerada
      IF rw_tbepr_reneg_contratada.dtassinatura BETWEEN to_date('25/11/2021','dd/mm/rrrr') and to_date('30/11/2021','dd/mm/rrrr') THEN        
      
	       UPDATE TBEPR_REENVIO_FTP f
	       SET f.insitenv = 0, f.qtdenvio = 1, f.dscritic = null
	       WHERE f.dtdenvio = rw_tbepr_reneg_contratada.dtassinatura
         AND   EXISTS (SELECT c.nrctrepr FROM tbepr_renegociacao_contrato c
                       WHERE f.cdcooper = c.cdcooper AND f.nrdconta = c.nrdconta AND f.nrctremp = c.nrctrepr
                       AND   c.cdcooper = rw_tbepr_reneg_contratada.cdcooper AND c.nrdconta = rw_tbepr_reneg_contratada.nrdconta AND c.nrctremp = rw_tbepr_reneg_contratada.nrctremp);
        
      END IF;

	    CREDITO.obterTermoRenegSimula(pr_cdcooper  => rw_tbepr_reneg_contratada.cdcooper
                                   ,pr_nrdconta  => rw_tbepr_reneg_contratada.nrdconta
                                   ,pr_nrctremp  => rw_tbepr_reneg_contratada.nrctremp
                                   ,pr_flgsmart  => TRUE
                                   ,pr_des_reto  => vr_dscritic
                                   ,pr_xml       => vr_retxml);
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION  
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao apagar contratos - ' || SQLERRM);
END;
