DECLARE
  vr_nrproposta      VARCHAR2(30);
  vr_dscritic        VARCHAR2(1000);
  vr_exc_saida       EXCEPTION;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros|| 'cpd/bacas/INC0106200';
  
  -- Arquivo de rollback
  vr_nmarqimp        VARCHAR2(100)  := 'INC0106200_ROLLBACK.txt';     
  vr_ind_arquiv      utl_file.file_type; 
  
  CURSOR cr_crapseg IS
  SELECT p.cdcooper,
         p.nrdconta,
         p.nrctrseg
    FROM crapseg p
   WHERE p.cdcooper = 1
     AND (p.nrdconta = 2659182 and p.nrctrseg = 705806)
      OR (p.nrdconta = 1915673 and p.nrctrseg = 797285);
      
BEGIN
  --Criar arquivo de Roll Back
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_exc_saida;
  END IF;
  
  FOR rw_crapseg IN cr_crapseg LOOP           
    BEGIN            
      UPDATE crapseg p 
         SET p.cdsitseg = 2
       WHERE p.cdcooper = rw_crapseg.cdcooper
         AND p.nrdconta = rw_crapseg.nrdconta
         AND p.nrctrseg = rw_crapseg.nrctrseg;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic:= 'Erro ao atualizar a situacao do seguro da conta: '||rw_crapseg.nrdconta||' apolice: '|| rw_crapseg.nrctrseg||' - '||SQLERRM;
        RAISE vr_exc_saida;              
    END;
            
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crapseg set cdsitseg = 1'
                                               ||' where cdcooper = ' ||rw_crapseg.cdcooper
                                               ||'   and nrdconta = ' ||rw_crapseg.nrdconta
                                               ||'   and nrctrseg = ' ||rw_crapseg.nrctrseg||';');
    COMMIT;
  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  vr_dscritic := 'Registro atualizado com sucesso!';
  dbms_output.put_line(vr_dscritic);
EXCEPTION
  WHEN vr_exc_saida THEN 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    vr_dscritic := 'ERRO ' || vr_dscritic;
    dbms_output.put_line(vr_dscritic);
    ROLLBACK;
END; 
/