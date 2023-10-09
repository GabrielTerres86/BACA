DECLARE
  vr_dscritic  VARCHAR2(5000) := NULL;
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
  pr_cdprogra VARCHAR2(15) := 'RITM0330690';
  pr_dscritic VARCHAR2(4000);
  
  vr_exc_saida EXCEPTION;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dtfimper DATE;
      vr_dtmvtolt DATE;
      vr_qtdiaute INTEGER := 0;
      vr_txprodia NUMBER(22,8);
  
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper ,
           cop.nmrescop
      FROM crapcop cop
     WHERE cop.flgativo = 1 
       AND cop.cdcooper not in (3,1);       
  rw_crapcop cr_crapcop%ROWTYPE;
  
   CURSOR cr_crapcop_2 IS
    SELECT cop.cdcooper ,
           cop.nmrescop
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper not in (3);       
  rw_crapcop_2 cr_crapcop_2%ROWTYPE;
  
  CURSOR cr_crapgen(pr_cdcooper IN crapdtc.cdcooper%TYPE) IS
    SELECT dtc.cdcooper,
           dtc.tpaplica,
           ftx.vlfaixas,
           ftx.cdperapl,
           ftx.perapltx,
           ftx.perrdttx
      FROM crapdtc dtc,
           crapttx ttx,
           crapftx ftx
     WHERE dtc.cdcooper = pr_cdcooper  AND
           dtc.flgstrdc = 1            AND
           dtc.tpaplrdc = 1            AND
           ttx.cdcooper = dtc.cdcooper AND
           ttx.tptaxrdc = dtc.tpaplica AND
           ftx.cdcooper = dtc.cdcooper AND
           ftx.tptaxrdc = dtc.tpaplica AND
           ftx.cdperapl = ttx.cdperapl AND 
           dtc.tpaplica = 7;
  rw_crapgen cr_crapgen%ROWTYPE;
      
  CURSOR cr_craptxi(pr_cddindex IN craptxi.cddindex%TYPE
                   ,pr_dtmvtolt IN craptxi.dtiniper%TYPE) IS
    SELECT vlrdtaxa
      FROM craptxi
     WHERE cddindex = pr_cddindex
       AND dtiniper = pr_dtmvtolt; 
  rw_craptxi cr_craptxi%ROWTYPE;       

  rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;   

  CURSOR cr_craptrd(pr_cdcooper IN craptrd.cdcooper%TYPE
                   ,pr_dtiniper IN craptrd.dtiniper%TYPE
                   ,pr_vlfaixas IN craptrd.vlfaixas%TYPE
                   ,pr_cdperapl IN craptrd.cdperapl%TYPE
                   ,pr_tptaxrda IN craptrd.tptaxrda%TYPE) IS
    SELECT trd.cdcooper
      FROM craptrd trd
     WHERE trd.cdcooper = pr_cdcooper
       AND trd.dtiniper = pr_dtiniper
       AND trd.tptaxrda = pr_tptaxrda
       AND trd.incarenc = 0          
       AND trd.vlfaixas = pr_vlfaixas
       AND trd.cdperapl = pr_cdperapl;
  rw_craptrd cr_craptrd%ROWTYPE;
  
BEGIN

  DELETE crapttx 
   WHERE tptaxrdc = 7
     AND cdcooper in (SELECT cop.cdcooper 
                        FROM crapcop cop
                       WHERE cop.flgativo = 1
                         AND cop.cdcooper <> 3) ;                         
                         
  DELETE craptrd 
   WHERE tptaxrda = 7
     AND dtiniper = TRUNC(SYSDATE)
     AND cdcooper in (SELECT cop.cdcooper 
                        FROM crapcop cop
                       WHERE cop.flgativo = 1
                         AND cop.cdcooper <> 3) ;                         

  insert into crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
               values (1, 7, 1, 30, 30, 0);

  insert into crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
               values (1, 7, 2, 90, 90, 0);

  insert into crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
               values (1, 7, 3, 181, 186, 0);

  insert into crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
               values (1, 7, 4, 361, 366, 0);

  insert into crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
               values (1, 7, 5, 721, 721, 0);

  FOR rw_crapcop IN cr_crapcop LOOP
     
    insert into crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
                 values (rw_crapcop.cdcooper, 7, 1, 30, 30, 0);
    insert into crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
                 values (rw_crapcop.cdcooper, 7, 2, 90, 90, 0);
    insert into crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
                 values (rw_crapcop.cdcooper, 7, 3, 181, 181, 0);
    insert into crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
                 values (rw_crapcop.cdcooper, 7, 4, 361, 361, 0);
    insert into crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
                 values (rw_crapcop.cdcooper, 7, 5, 721, 721, 0);

  END LOOP;



  COMMIT;
  
  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 3);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;

  IF btch0001.cr_crapdat%NOTFOUND THEN
    CLOSE btch0001.cr_crapdat;
    vr_dscritic := 'Erro no carregamento do cursor btch0001.cr_crapdat. Dados nao encontrados.';
    RAISE vr_exc_saida;
  ELSE
    CLOSE btch0001.cr_crapdat;
  END IF;
  
  
  OPEN cr_craptxi(pr_cddindex => 1
                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);

  FETCH cr_craptxi INTO rw_craptxi;

  IF cr_craptxi %NOTFOUND THEN
    CLOSE cr_craptxi;
    vr_dscritic := 'TAXA craptxi nao encontrada';
    RAISE vr_exc_saida;
  END IF;
  CLOSE cr_craptxi;
           
  FOR rw_crapcop_2 IN cr_crapcop_2 LOOP 

    pr_dscritic := 'SCRIPT TAX RDCPRE : '||rw_crapcop_2.nmrescop;

    CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                           pr_cdprograma    => pr_cdprogra, 
                           pr_cdcooper      => 3, 
                           pr_tpexecucao    => 2,
                           pr_tpocorrencia  => 4,
                           pr_cdcriticidade => 0,
                           pr_dsmensagem    => pr_dscritic,                             
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => NULL);

    vr_dtfimper := GENE0005.fn_calc_data(pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_qtmesano => 1
                                        ,pr_tpmesano => 'M'
                                        ,pr_des_erro => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    vr_dtmvtolt := rw_crapdat.dtmvtolt;
    vr_qtdiaute := 0;
    
    WHILE vr_dtmvtolt < vr_dtfimper LOOP
      IF TO_CHAR(vr_dtmvtolt,'D') NOT IN (1,7) AND
      NOT FLXF0001.fn_verifica_feriado(rw_crapcop_2.cdcooper,vr_dtmvtolt) THEN
        
        vr_qtdiaute := vr_qtdiaute + 1;

      END IF;
      
      vr_dtmvtolt := vr_dtmvtolt + 1;
    END LOOP;
    OPEN cr_crapgen(pr_cdcooper => rw_crapcop_2.cdcooper); 
      LOOP
      FETCH cr_crapgen INTO rw_crapgen;

      EXIT WHEN cr_crapgen%NOTFOUND;

      OPEN cr_craptrd(pr_cdcooper => rw_crapgen.cdcooper
                     ,pr_dtiniper => rw_crapdat.dtmvtolt
                     ,pr_vlfaixas => rw_crapgen.vlfaixas
                     ,pr_cdperapl => rw_crapgen.cdperapl
                     ,pr_tptaxrda => rw_crapgen.tpaplica);

      FETCH cr_craptrd INTO rw_craptrd;

      IF cr_craptrd %NOTFOUND THEN
        CLOSE cr_craptrd;
        BEGIN
          vr_txprodia := ((POWER((1 + rw_craptxi.vlrdtaxa / 100),(1 / 252)) - 1) * 100);

          INSERT INTO
            craptrd(cdcooper, dtiniper, qtdiaute, tptaxrda, incarenc, vlfaixas, cdperapl, txprodia, txofidia)
          VALUES(rw_crapgen.cdcooper, rw_crapdat.dtmvtolt, vr_qtdiaute, rw_crapgen.tpaplica, 0,
                 rw_crapgen.vlfaixas, rw_crapgen.cdperapl, vr_txprodia,
                 (ROUND((vr_txprodia * rw_crapgen.perapltx / 100),6)));
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro na CRAPTRD - 1: cdcooper:'||rw_crapgen.cdcooper
                         ||', dtiniper:'||rw_crapdat.dtmvtolt||', qtdiaute:'||vr_qtdiaute
                         ||', tptaxrda:'||rw_crapgen.tpaplica||', incarenc:0'
                         ||', vlfaixas:'||rw_crapgen.vlfaixas||', cdperapl:'||rw_crapgen.cdperapl
                         ||', txprodia:'||vr_txprodia
                         ||', txofidia:'||(ROUND((vr_txprodia * rw_crapgen.perapltx / 100),6))||'. '
                         ||SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE
        CLOSE cr_craptrd;
        CONTINUE;

      END IF;

    END LOOP;
    CLOSE cr_crapgen;                        
  END LOOP;
      
  COMMIT;                 
  
EXCEPTION  
   WHEN vr_exc_saida THEN

    ROLLBACK;        
    
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => vr_dscritic,
                           pr_cdmensagem => 777,
                           pr_cdprograma => 'RITM0330690',
                           pr_cdcooper   => 3,
                           pr_idprglog   => vr_idprglog);  
  WHEN OTHERS THEN
    vr_dscritic := 'Erro nao tratado ao rodar script : ' || SQLERRM;
    
    ROLLBACK;
    
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => vr_dscritic,
                           pr_cdmensagem => 999,
                           pr_cdprograma => 'RITM0330690',
                           pr_cdcooper   => 3,
                           pr_idprglog   => vr_idprglog);
END;
