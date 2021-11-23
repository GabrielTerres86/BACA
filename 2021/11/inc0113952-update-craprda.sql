
DECLARE
    
    vr_excsaida   EXCEPTION;
    vr_dscritic   VARCHAR2(5000) := ' ';
    vr_nraplica craprac.nraplica%TYPE;
    vr_nmarqimp1       VARCHAR2(100)  := 'backup.txt';
    vr_ind_arquiv1     utl_file.file_type;
    
    vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
    vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/inc0113952';       
    
   CURSOR cr_craprda(pr_cdcooper IN craprda.cdcooper%TYPE
                    ,pr_nrdconta IN craprda.nrdconta%TYPE
                    ,pr_nraplica IN craprda.nraplica%TYPE)IS

        SELECT rda.cdcooper
              ,rda.nrdconta
              ,rda.nraplica
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.nraplica = pr_nraplica;

      rw_craprda cr_craprda%ROWTYPE;
                       
   CURSOR cr_aplica IS
     SELECT rda.cdcooper,
            rda.nrdconta,
            rda.nraplica
       FROM craprda rda, 
            craprac rac
      WHERE rda.cdcooper = rac.cdcooper
        AND rda.nrdconta = rac.nrdconta
        AND rda.nraplica = rac.nraplica 
        AND rac.cdprodut <> 1007;
   
   rw_aplica cr_aplica%ROWTYPE;
   
   procedure backup (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
  END; 
  
  PROCEDURE fecha_arquivos IS
  BEGIN
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
  END; 
  
BEGIN
   --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp1       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv1     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;  
  FOR rw_aplica IN cr_aplica LOOP
    
     vr_nraplica := 0;
       LOOP
        -- Verifica o valor da sequence
        
        vr_nraplica := fn_sequence(pr_nmtabela => 'CRAPRAC'
                                  ,pr_nmdcampo => 'NRAPLICA'
                                  ,pr_dsdchave => rw_aplica.cdcooper || ';' || rw_aplica.nrdconta
                                  ,pr_flgdecre => 'N');

        /* Consulta CRAPRDA para nao existir aplicacoes com o mesmo numero mesmo
        sendo produto antigo e novo */

        OPEN cr_craprda(pr_cdcooper => rw_aplica.cdcooper
                       ,pr_nrdconta => rw_aplica.nrdconta
                       ,pr_nraplica => vr_nraplica);

        FETCH cr_craprda INTO rw_craprda;

        IF cr_craprda%FOUND THEN
          CLOSE cr_craprda;
          CONTINUE;
        ELSE
          CLOSE cr_craprda;
          EXIT;
        END IF;

      END LOOP;
      
      backup('update craprda set nraplica = '||rw_aplica.nraplica||' where cdcooper = 1 and nrdconta = '||rw_aplica.nrdconta||' and nraplica = '||vr_nraplica||';');
      backup('update craplap set nraplica = '||rw_aplica.nraplica||' where cdcooper = 1 and nrdconta = '||rw_aplica.nrdconta||' and nraplica = '||vr_nraplica||';');
      
      UPDATE craprda rda
         SET rda.nraplica = vr_nraplica
       WHERE rda.cdcooper = rw_aplica.cdcooper
         AND rda.nrdconta = rw_aplica.nrdconta
         AND rda.nraplica = rw_aplica.nraplica;
         
      UPDATE craplap lap
         SET lap.nraplica = vr_nraplica
       WHERE lap.cdcooper = rw_aplica.cdcooper
         AND lap.nrdconta = rw_aplica.nrdconta
         AND lap.nraplica = rw_aplica.nraplica;
         
                  
         
  END LOOP;      

  COMMIT;   
  fecha_arquivos; 
    EXCEPTION 
       WHEN vr_excsaida then  
       backup('ERRO ' || vr_dscritic);  
       fecha_arquivos;  
       ROLLBACK;    
      WHEN OTHERS then
       vr_dscritic :=  sqlerrm;
       backup('ERRO ' || vr_dscritic); 
       fecha_arquivos; 
       ROLLBACK;       
END;
