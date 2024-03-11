DECLARE
vr_cdprograma   VARCHAR2(50) := 'SCRIPT-LCI';
rw_crapdat      btch0001.cr_crapdat%rowtype;
pr_cdcooper     NUMBER := 1;
vr_vllanmto     NUMBER(25,2) := 0;
vr_exc_saida     EXCEPTION;
vr_idprglog     NUMBER;
vr_cdcritic     NUMBER;
vr_dscritic     VARCHAR(4000);
vr_nrdocmto     craplci.nrdocmto%TYPE;
pr_nrdconta     NUMBER := 15379590;

CURSOR cr_crapsli(pr_cdcooper IN crapsli.cdcooper%TYPE
                 ,pr_nrdconta IN crapsli.nrdconta%TYPE
                 ,pr_dtrefere IN crapsli.dtrefere%TYPE) IS
        SELECT
          sli.cdcooper
         ,sli.nrdconta
         ,sli.dtrefere
         ,sli.vlsddisp
         ,sli.rowid
        FROM
          crapsli sli
        WHERE
              sli.cdcooper = pr_cdcooper
          AND sli.nrdconta = pr_nrdconta
          AND sli.dtrefere = pr_dtrefere;

      rw_crapsli cr_crapsli%ROWTYPE;
  
BEGIN
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;          
  CLOSE BTCH0001.cr_crapdat;
 FOR cr IN (SELECT r.vlsolicitado, r.vlresgate, r.rowid
               FROM investimento.tbinvest_resgate_judicial_lci r
              WHERE r.cdcooper = 1
                AND r.nrdconta = pr_nrdconta
                AND r.insituacao = 2)
     LOOP
        vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCI_LCI'
                                ,pr_nmdcampo => 'NRDOCMTO'
                                ,pr_dsdchave => TO_CHAR(rw_crapdat.dtmvtolt ,'DDMMRRRR')||';'||pr_cdcooper 
                                ,pr_flgdecre => 'N');
      BEGIN
        INSERT INTO
              cecred.craplci(
                cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,nrdconta
               ,nrdocmto
               ,nrseqdig
               ,vllanmto
               ,cdhistor)
            VALUES(
              pr_cdcooper
             ,rw_crapdat.dtmvtolt
             ,1
             ,100
             ,8599
             ,pr_nrdconta
             ,vr_nrdocmto
             ,vr_nrdocmto
             ,cr.vlsolicitado
             ,489);

        EXCEPTION
          WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro de lancamento CRAPLCI. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
      END;
       
       
      update investimento.tbinvest_resgate_judicial_lci lci
         set lci.insituacao = 3,
             lci.vlresgate = cr.vlsolicitado
       where lci.rowid = cr.rowid;
       
       
        vr_vllanmto :=  vr_vllanmto +  cr.vlsolicitado;
       
     END LOOP;
     OPEN cr_crapsli(pr_cdcooper => 1
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_dtrefere => rw_crapdat.dtultdia);

     FETCH cr_crapsli INTO rw_crapsli;
     IF cr_crapsli%NOTFOUND THEN          
          CLOSE cr_crapsli;
         
          BEGIN

            INSERT INTO
              cecred.crapsli(
                cdcooper
               ,nrdconta
               ,dtrefere
               ,vlsddisp
              ) VALUES(
                1
               ,pr_nrdconta
               ,rw_crapdat.dtultdia
               ,vr_vllanmto);

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na CRAPSLI. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

        ELSE
          CLOSE cr_crapsli;

          BEGIN
            UPDATE cecred.crapsli
               SET vlsddisp = vlsddisp + vr_vllanmto
             WHERE cdcooper = 1
               and nrdconta = pr_nrdconta;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na CRAPSLI. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
 COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dscritic,
                             pr_cdmensagem => 222,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog); 
      ROLLBACK;
    WHEN OTHERS THEN
      vr_dscritic := 'Erro nao especificado! ' || SQLERRM;
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dscritic,
                             pr_cdmensagem => 333,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog); 
      ROLLBACK;                
END;
