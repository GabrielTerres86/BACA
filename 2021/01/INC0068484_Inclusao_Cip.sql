DECLARE  
  
  ---------------------------------------------------------------------------------------------------------------------------------
  -- Script para atualizar as informações da CIP no Aimaro dos títulos 76,77,78,79 da conta 120286 - INC0068484 (Jose Dill - Mouts)
  ---------------------------------------------------------------------------------------------------------------------------------
    
  
  ---------->>> VARIAVEIS <<<-----------   
  vr_cdcritic   INTEGER;
  vr_dscritic   VARCHAR2(2000);
  vr_des_erro   VARCHAR2(200);
    
  vr_insitpro   crapcob.insitpro%TYPE;
  vr_inenvcip   crapcob.inenvcip%TYPE;
  vr_flgcbdda   crapcob.flgcbdda%TYPE;
  vr_dhenvcip   crapcob.dhenvcip%TYPE;
  vr_dsmensag   crapcol.dslogtit%TYPE;
  vr_inregcip   crapcob.inregcip%TYPE;
  vr_cdmotivo   VARCHAR2(2);
  vr_flgsacad   INTEGER := 0;    
  --
  vr_cdstiope   VARCHAR2(2):= 'RC';
  vr_idtitnpc   crapcob.idtitleg%TYPE;
  vr_nratutit   crapcob.nratutit%TYPE;    
    
BEGIN
  
  vr_insitpro := 3; --> 3-RC registro CIP
  vr_inenvcip := 3; -- confirmado
  vr_flgcbdda := 1;
  vr_dsmensag := 'Boleto registrado no Sistema Financeiro Nacional';
  --
  FOR rw_crapcob in (SELECT cob.*
                           ,cob.rowid rowidcob
                           ,decode(cob.cdtpinsc,1,'F','J') tppessoa
                     FROM crapcob cob
                     WHERE (cob.cdcooper, cob.nrdconta, cob.nrcnvcob, cob.nrdocmto) IN
                         ((10, 120286, 110002, 76)
                         ,(10, 120286, 110002, 77)
                         ,(10, 120286, 110002, 78)
                         ,(10, 120286, 110002, 79))) LOOP
  
    --> RC - Operação registrada na CIP-NPC
    --
    IF rw_crapcob.cdcooper    = 10
      AND rw_crapcob.nrdconta = 120286
      AND rw_crapcob.nrcnvcob = 110002
      AND rw_crapcob.nrdocmto = 76 THEN
      --    (10,120286,110002,76)
      vr_idtitnpc := 2020081302757480753;
      vr_nratutit := 1597357635618000813;
    END IF;
    --
    IF rw_crapcob.cdcooper    = 10
      AND rw_crapcob.nrdconta = 120286
      AND rw_crapcob.nrcnvcob = 110002
      AND rw_crapcob.nrdocmto = 77 THEN
      --    (10,120286,110002,77)
      vr_idtitnpc := 2020081303757278849;
      vr_nratutit := 1597357635940000813;
    END IF;    
    --  
    IF rw_crapcob.cdcooper    = 10
      AND rw_crapcob.nrdconta = 120286
      AND rw_crapcob.nrcnvcob = 110002
      AND rw_crapcob.nrdocmto = 78 THEN
      --    (10,120286,110002,78)
      vr_idtitnpc := 2020081304758216149;
      vr_nratutit := 1597357636416000813;
    END IF;    
    --
    IF rw_crapcob.cdcooper    = 10
      AND rw_crapcob.nrdconta = 120286
      AND rw_crapcob.nrcnvcob = 110002
      AND rw_crapcob.nrdocmto = 79 THEN
      --    (10,120286,110002,79)
      vr_idtitnpc := 2020081305758052398;
      vr_nratutit := 1597357639545000813;
    END IF;    
    --
    vr_dhenvcip := SYSDATE;
    --   
    --> Atualizar informações do boleto
    BEGIN
      UPDATE crapcob cob
         SET cob.insitpro =  nvl(vr_insitpro,cob.insitpro)
           , cob.flgcbdda =  nvl(vr_flgcbdda,cob.flgcbdda)
           , cob.inenvcip =  nvl(vr_inenvcip,cob.inenvcip)
           , cob.dhenvcip =  nvl(vr_dhenvcip,cob.dhenvcip)
           , cob.inregcip =  nvl(vr_inregcip,cob.inregcip)
           , cob.nrdident =  nvl(vr_idtitnpc,cob.nrdident)           
           , cob.nratutit =  nvl(vr_nratutit,cob.nratutit)
       WHERE cob.rowid    = rw_crapcob.rowidcob;
         
       IF vr_cdstiope = 'RC' THEN
           
         -- verificar se o pagador eh DDA         
         DDDA0001.pc_verifica_sacado_DDA(pr_tppessoa => rw_crapcob.tppessoa
                                        ,pr_nrcpfcgc => rw_crapcob.nrinssac
                                        ,pr_flgsacad => vr_flgsacad
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                                          
         IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
           DBMS_OUTPUT.put_line('Erro DDDA0001.pc_verifica_sacado_DDA - '||vr_dscritic);           
           ROLLBACK;
           EXIT;           
         END IF;                                                             

         IF vr_flgsacad = 1 THEN
           -- A4 = Pagador DDA
           vr_cdmotivo := 'A4';
         ELSE
           -- PC = Boleto PCR (ou NPC)
           vr_cdmotivo := 'PC';
         END IF;
                              
         UPDATE crapret ret
            SET cdmotivo = vr_cdmotivo || cdmotivo
          WHERE ret.cdcooper = rw_crapcob.cdcooper
            AND ret.nrdconta = rw_crapcob.nrdconta
            AND ret.nrcnvcob = rw_crapcob.nrcnvcob
            AND ret.nrdocmto = rw_crapcob.nrdocmto
            AND ret.cdocorre = 2; -- 2=Confirmacao de registro de boleto
              
        END IF;
          
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.put_line('Erro ao atualizar crapret - '||sqlerrm);
        EXIT;
    END;
          
    --> Se conter mensagem deve gerar log
    IF trim(vr_dsmensag) IS NOT NULL THEN        
      -- Cria o log da cobrança
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                   ,pr_cdoperad => '1'
                                   ,pr_dtmvtolt => SYSDATE
                                   ,pr_dsmensag => vr_dsmensag
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);
              
      -- Se ocorrer erro
      IF vr_des_erro <> 'OK' THEN        
         DBMS_OUTPUT.put_line('Erro PAGA0001.pc_cria_log_cobranca - '||vr_dscritic);
      END IF;
      
    END IF;  
      
  END LOOP;
            
  COMMIT;
     
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Erro ao executar script INC0068484 - '||sqlerrm);
    ROLLBACK;
    --
END ;
