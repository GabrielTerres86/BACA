---atualizar cdageimp no limite desconto cheque e bordero de cheque.
DECLARE

  -- Tratamento de erros e log
  vr_dsmensagem     VARCHAR2(500);
  vr_nmarq_rollback VARCHAR2(100);
  vr_des_erro       VARCHAR2(1000);
  vr_dscritic       VARCHAR2(1000);
  
  --variaveis arquivos
  vr_handle         utl_file.file_type;
  vr_exc_erro EXCEPTION;

  vr_dsdireto VARCHAR2(300);

  --Busca Limites
  CURSOR c1 (pr_cdcooper IN crapcop.cdcooper%TYPE)  IS
    SELECT craplim.cdopelib
          ,crapope.cdpactra
          ,crawlim.cdagenci
          ,crawlim.cdageimp
          ,crawlim.cdcooper
          ,crawlim.nrdconta
          ,crawlim.tpctrlim
          ,crawlim.nrctrlim
      FROM craplim
          ,crapope
          ,crawlim
     WHERE craplim.cdcooper = pr_cdcooper
       AND craplim.dtinivig >= '01/01/2021'
       AND craplim.tpctrlim = 2  -- limite desconto cheque
       AND craplim.insitlim = 2
       AND crapope.cdcooper = craplim.cdcooper
       AND UPPER(crapope.cdoperad) = UPPER(NVL(TRIM(craplim.cdopelib),DECODE(craplim.cdoperad,'996','',craplim.cdoperad)))
       AND crawlim.cdcooper = craplim.cdcooper
       AND crawlim.nrdconta = craplim.nrdconta
       AND crawlim.nrctrlim = craplim.nrctrlim
       AND crawlim.tpctrlim = craplim.tpctrlim
       AND crawlim.insitlim = craplim.insitlim
       AND NVL(crawlim.cdageimp, 0) = 0;

  vr_conta_reg NUMBER(6);
  
    --Busca Borderôs de Cheque
  CURSOR c2 (pr_cdcooper IN crapcop.cdcooper%TYPE)  IS
    SELECT crapope.cdpactra
          ,a.cdopelib
          ,a.cdageimp
          ,a.cdagenci
          ,a.cdcooper
          ,a.nrborder
          ,a.nrdconta
      FROM crapbdc a
          ,crapope
     WHERE a.cdcooper = pr_cdcooper
       AND a.dtlibbdc >= '01/01/2021'
       AND NVL(a.cdageimp, 0) = 0
       AND crapope.cdcooper = a.cdcooper
       AND UPPER(crapope.cdoperad) = UPPER(a.cdopelib);        

BEGIN
  BEGIN
  -- caminho para produção:
     vr_dsdireto       := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/';
     vr_nmarq_rollback := vr_dsdireto||'RITM0146650_Limite_cheque_ROLLBACK.sql';

    
    -- Abrir o arquivo de rollback
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback,
                             pr_tipabert => 'W',
                             pr_utlfileh => vr_handle,
                             pr_des_erro => vr_des_erro);
                               
    IF vr_des_erro IS NOT NULL THEN
      vr_dsmensagem := 'Erro ao abrir arquivo de rollback: ' || vr_des_erro;
      RAISE vr_exc_erro;
    END IF;        

    FOR rw_crapcop IN (SELECT cop.cdcooper
                         FROM crapcop cop
                        WHERE cop.flgativo = 1) LOOP     
      vr_conta_reg := 0;                                                        
      FOR r1 IN c1(pr_cdcooper => rw_crapcop.cdcooper)  LOOP      
        BEGIN                                                 
          UPDATE cecred.crawlim a
             SET a.cdageimp = r1.cdpactra
           WHERE a.cdcooper = r1.cdcooper
             AND a.nrdconta = r1.nrdconta
             AND a.nrctrlim = r1.nrctrlim
             AND a.tpctrlim = r1.tpctrlim;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dsmensagem := 'Erro ao atualizar crawlim. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
    
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                       pr_des_text => 'UPDATE crawlim SET ' || ' cdageimp = 0 ' ||
                                                      ' WHERE cdcooper = ' || r1.cdcooper ||
                                                      '   AND nrdconta = ' || r1.nrdconta ||
                                                      '   AND nrctrlim = ' || r1.nrctrlim ||
                                                      '   AND tpctrlim = ' || r1.tpctrlim || ';');                 
        vr_conta_reg := vr_conta_reg +1;
        IF vr_conta_reg >= 10000 THEN
          COMMIT;
          vr_conta_reg:= 0;
        END IF;  
      END LOOP;

      -- bordero de cheque
      FOR r2 IN c2(pr_cdcooper => rw_crapcop.cdcooper)  LOOP            
        BEGIN
          UPDATE cecred.crapbdc a
             SET a.cdageimp = r2.cdpactra
           WHERE a.cdcooper = r2.cdcooper
             AND a.nrdconta = r2.nrdconta
             AND a.nrborder = r2.nrborder;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dsmensagem := 'Erro ao atualizar crapbdc. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                       pr_des_text => 'UPDATE crapbdc SET ' || ' cdageimp = 0 ' ||
                                                      ' WHERE cdcooper = ' || r2.cdcooper ||
                                                      '   AND nrdconta = ' || r2.nrdconta ||
                                                      '   AND nrborder = ' || r2.nrborder || ';');

        vr_conta_reg := vr_conta_reg +1;
        IF vr_conta_reg >= 10000 THEN
          COMMIT;
          vr_conta_reg:= 0;
        END IF; 
        
      END LOOP;    

      COMMIT; -- commit a cada coop
      vr_conta_reg:= 0;
      
    END LOOP; -- cooperativas

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle, pr_des_text => 'COMMIT;');
    
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
    BEGIN
      ROLLBACK;
      dbms_output.put_line('Erro geral: ' || vr_dsmensagem || ' SQLERRM: ' || SQLERRM);      
      IF vr_des_erro IS NULL THEN
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle, pr_des_text => 'COMMIT;');
      END IF;
    END;
      
    WHEN OTHERS THEN
    BEGIN
      ROLLBACK;
      dbms_output.put_line('Erro geral: ' || vr_dsmensagem || ' SQLERRM: ' || SQLERRM);       
      IF vr_des_erro IS NULL THEN
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle, pr_des_text => 'COMMIT;');
      END IF;
    END;
    
  END;
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
END;
/
