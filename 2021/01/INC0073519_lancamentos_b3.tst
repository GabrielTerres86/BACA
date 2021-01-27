PL/SQL Developer Test script 3.0
88
DECLARE 
  vr_cdcritic INTEGER;
  vr_exc_erro EXCEPTION;
  vr_dscritic   VARCHAR2(5000) := ' ';
  vr_nmarqimp1       VARCHAR2(100)  := 'erro.txt';
  vr_ind_arquiv1     utl_file.file_type;
  vr_nmarqimp2       VARCHAR2(100)  := 'backup.txt';
  vr_ind_arquiv2     utl_file.file_type;
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/backup_b3'; 
  
  CURSOR cr_custodia_lan  IS
  SELECT * 
    FROM tbcapt_custodia_lanctos 
   WHERE idlancamento IN (
         SELECT nvl(idlancamento,0) 
           FROM tbcapt_custodia_conteudo_arq
          WHERE idarquivo IN (55747,55749,55750,55751,55752,55753,
                              55754,55755,55756,55757,55758,55759,
                              55760,55761,55762,55763,55764,55769,
                              55770,55771,55772,55773,55774,55775,
                              55776,55777));                    
    rw_custodia_lan cr_custodia_lan%ROWTYPE; 
      
  PROCEDURE erro (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);    
  END; 
  PROCEDURE backup (pr_msg VARCHAR2) IS
    BEGIN
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
  END; 
  
  PROCEDURE fecha_arquivos IS
  BEGIN
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1);
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); 
  END;
  
  --INICIO
BEGIN   
   --Criar arquivo
   gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                           ,pr_nmarquiv => vr_nmarqimp1       --> Nome do arquivo
                           ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                           ,pr_utlfileh => vr_ind_arquiv1     --> handle do arquivo aberto
                           ,pr_des_erro => vr_dscritic);      --> erro
   -- em caso de crítica
   IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exc_erro;
   END IF; 
--Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exc_erro;
  END IF;            
   FOR rw_custodia_lan IN cr_custodia_lan LOOP   
         backup( ' update tbcapt_custodia_lanctos set idsituacao = 9 where = idlancamento ' || rw_custodia_lan.idlancamento || ';');
       BEGIN    
         UPDATE tbcapt_custodia_lanctos lan
            SET lan.idsituacao = 2
          WHERE lan.idlancamento = rw_custodia_lan.idlancamento;
         EXCEPTION
         WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar craplat.';
          erro( ' - Lancamento: ' || rw_custodia_lan.idlancamento );
         RAISE vr_exc_erro;
        end;
   END LOOP;    
   COMMIT; 
   fecha_arquivos;
  
   EXCEPTION
    WHEN vr_exc_erro THEN    
      vr_cdcritic := vr_cdcritic;
      vr_dscritic := vr_dscritic;
      fecha_arquivos;
    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro no lancamento' ||  rw_custodia_lan.idlancamento||sqlerrm;
      fecha_arquivos;
     ROLLBACK;
END;
0
1
vr_dscritic
