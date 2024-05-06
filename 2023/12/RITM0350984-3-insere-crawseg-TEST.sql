DECLARE

  vr_exc_saida      EXCEPTION;
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/RITM0350984';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_RITM0350984_3.sql';
  vr_qtd_reg        NUMBER:=0;
  vr_cdcooper       cecred.tbseg_prestamista.cdcooper%type;
  vr_nrdconta       cecred.tbseg_prestamista.nrdconta%type;
  vr_nrctrseg       cecred.tbseg_prestamista.nrctrseg%type;
  vr_nrctremp       cecred.tbseg_prestamista.nrctremp%type;
  
  CURSOR cr_tbseg_prestamista IS
    SELECT p.*, c.dtmvtolt, e.flggarad, c.tpdpagto, c.vldifseg, c.dtprideb, c.flgunica, c.nrctratu,  
           c.lsctrant, c.dtiniseg, c.dtdebito, c.cdsegura, c.vlpreseg, c.tpplaseg,
            c.tpseguro,
           a.nrcadast, d.nrendere
      FROM CECRED.tbseg_prestamista p, 
           CECRED.crapseg c,
           CECRED.crawepr e,
           CECRED.crapass a,
           CECRED.crapenc d
     WHERE p.cdcooper = c.cdcooper 
       AND p.nrdconta = c.nrdconta 
       AND p.nrctrseg = c.nrctrseg 
       AND c.tpseguro = 4 
       AND p.cdcooper = e.cdcooper
       AND p.nrdconta = e.nrdconta
       AND p.nrctremp = e.nrctremp
       AND p.cdcooper = a.cdcooper
       AND p.nrdconta = a.nrdconta
       AND p.cdcooper = d.cdcooper
       AND p.nrdconta = d.nrdconta
       AND d.idseqttl = 1
       AND d.tpendass = 10
       AND ((c.dtcancel IS NULL  
       AND p.tpregist IN (1,3)) or (p.tpregist = 0 and p.nrctrseg in (360458,360459)))
       AND NOT EXISTS ( SELECT 0 
                          FROM CECRED.crawseg w 
                         WHERE w.cdcooper = p.cdcooper 
                           AND w.nrdconta = p.nrdconta 
                           AND w.nrctrseg = p.nrctrseg 
                           AND w.nrctrato = p.nrctremp) 
       AND (p.cdcooper,p.nrctrseg) IN((1,1491035),
									  (1,1491032),
									  (1,1491033),
									  (1,1491034),
									  (1,1477550),
									  (1,1477551),
									  (1,1477552),
									  (1,1477553),
									  (1,1451091),
									  (1,1451092),
									  (1,1451093),
									  (1,1232840),
									  (1,1126936),
									  (1,1126937),
									  (1,1126938),
									  (1,1126939),
									  (1,1343040),
									  (1,1343041),
									  (1,1343042),
									  (1,1340990),
									  (1,1320281),
									  (1,1320282),
									  (1,1320283),
									  (1,1320284),
									  (1,1320285),
									  (1,1245629),
									  (1,1220600),
									  (1,1220605),
									  (1,1220606),
									  (1,1220607),
									  (1,1220608),
									  (1,1220609),
									  (1,1220610),
									  (1,1218120),
									  (5,60206),
									  (7,147015),
									  (10,49820),
									  (12,61991),
									  (16,360458),
									  (16,360459))                                                          
    ORDER BY p.cdcooper, p.dtinivig DESC, p.nrproposta; 
  rw_tbseg_prestamista cr_tbseg_prestamista%ROWTYPE; 
  
  PROCEDURE pc_valida_direto(pr_nmdireto IN  VARCHAR2,
                             pr_dscritic OUT CECRED.crapcri.dscritic%TYPE) IS
    vr_dscritic  CECRED.crapcri.dscritic%TYPE;
    vr_typ_saida VARCHAR2(3);
    vr_des_saida VARCHAR2(1000);
    vr_exc_erro  EXCEPTION;
    
    BEGIN
      IF NOT CECRED.gene0001.fn_exis_diretorio(pr_nmdireto) THEN

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null',
                                           pr_typ_saida   => vr_typ_saida,
                                           pr_des_saida   => vr_des_saida);

        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto || ' 1> /dev/null',
                                           pr_typ_saida   => vr_typ_saida,
                                           pr_des_saida   => vr_des_saida);

        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
  END;  
  
  
BEGIN           
 
  pc_valida_direto(pr_nmdireto => vr_nmdir,
                   pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;    
    
  CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir,
                                  pr_nmarquiv => vr_nmarq,
                                  pr_tipabert => 'W',
                                  pr_utlfileh => vr_ind_arq,
                                  pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq;
    RAISE vr_exc_saida;
  END IF;

  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');


 FOR rw_tbseg_prestamista IN cr_tbseg_prestamista LOOP
 
   vr_linha := 'DELETE FROM CECRED.crawseg  ' ||
               ' WHERE cdcooper = ' || rw_tbseg_prestamista.cdcooper ||
               '   AND nrdconta = ' || rw_tbseg_prestamista.nrdconta ||
               '   AND nrctrseg = ' || rw_tbseg_prestamista.nrctrseg ||
               '   AND tpseguro = 4;';

   CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
   vr_cdcooper := rw_tbseg_prestamista.cdcooper;
   vr_nrdconta := rw_tbseg_prestamista.nrdconta;
   vr_nrctrseg := rw_tbseg_prestamista.nrctrseg;
   vr_nrctremp := rw_tbseg_prestamista.nrctremp;
   
   INSERT INTO CECRED.crawseg(dtmvtolt,
                              nrdconta,
                              nrctrseg,
                              tpseguro,
                              nmdsegur,
                              tpplaseg,
                              nmbenefi,
                              nrcadast,
                              nmdsecao,
                              dsendres,
                              nrendres,
                              nmbairro,
                              nmcidade,
                              cdufresd,
                              nrcepend,
                              dtinivig,
                              dtfimvig,
                              dsmarvei,
                              dstipvei,
                              nranovei,
                              nrmodvei,
                              qtpasvei,
                              ppdbonus,
                              flgdnovo,
                              nrapoant,
                              nmsegant,
                              flgdutil,
                              flgnotaf,
                              flgapant,
                              vlpreseg,
                              vlseguro,
                              vldfranq,
                              vldcasco,
                              vlverbae,
                              flgassis,
                              vldanmat,
                              vldanpes,
                              vldanmor,
                              vlappmor,
                              vlappinv,
                              cdsegura,
                              nmempres,
                              dschassi,
                              flgrenov,
                              dtdebito,
                              vlbenefi,
                              cdcalcul,
                              flgcurso,
                              dtiniseg,
                              nrdplaca,
                              lsctrant,
                              nrcpfcgc,
                              nrctratu,
                              nmcpveic,
                              flgunica,
                              nrctrato,
                              flgvisto,
                              cdapoant,
                              dtprideb,
                              vldifseg,
                              dscobext##1,
                              dscobext##2,
                              dscobext##3,
                              dscobext##4,
                              dscobext##5,
                              vlcobext##1,
                              vlcobext##2,
                              vlcobext##3,
                              vlcobext##4,
                              vlcobext##5,
                              flgrepgr,
                              vlfrqobr,
                              tpsegvid,
                              dtnascsg,
                              cdsexosg,
                              vlpremio,
                              qtparcel,
                              nrfonemp,
                              nrfonres,
                              dsoutgar,
                              vloutgar,
                              tpdpagto,
                              cdcooper,
                              flgconve,
                              complend,
                              nrproposta,
                              flggarad,
                              flgassum,
                              tpcustei,
                              tpmodali,
                              flfinanciasegprestamista,
                              flgsegma)
                       values(rw_tbseg_prestamista.dtmvtolt,
                              rw_tbseg_prestamista.nrdconta,
                              rw_tbseg_prestamista.nrctrseg,
                              rw_tbseg_prestamista.tpseguro,
                              rw_tbseg_prestamista.nmprimtl,
                              rw_tbseg_prestamista.tpplaseg,
                              NULL,
                              rw_tbseg_prestamista.nrcadast,
                              NULL,
                              rw_tbseg_prestamista.dsendres,
                              rw_tbseg_prestamista.nrendere,
                              rw_tbseg_prestamista.nmbairro,
                              rw_tbseg_prestamista.nmcidade,
                              rw_tbseg_prestamista.cdufresd,
                              rw_tbseg_prestamista.nrcepend,
                              rw_tbseg_prestamista.dtinivig,
                              rw_tbseg_prestamista.dtfimvig,
                              NULL,
                              NULL,
                              0,
                              0,
                              0,
                              0,
                              0,
                              0,
                              NULL,
                              1,
                              0,
                              0,
                              rw_tbseg_prestamista.vlpreseg,
                              rw_tbseg_prestamista.vlsdeved,
                              0,
                              0,
                              0,
                              0,
                              0,
                              0,
                              0,
                              0,
                              0,
                              rw_tbseg_prestamista.cdsegura,
                              NULL,
                              NULL,
                              0,
                              rw_tbseg_prestamista.dtdebito,
                              0,
                              0,
                              0,
                              rw_tbseg_prestamista.dtiniseg,
                              NULL,
                              rw_tbseg_prestamista.lsctrant,
                              rw_tbseg_prestamista.nrcpfcgc,
                              rw_tbseg_prestamista.nrctratu,
                              NULL,
                              rw_tbseg_prestamista.flgunica,
                              rw_tbseg_prestamista.nrctremp,
                              0,
                              NULL,
                              rw_tbseg_prestamista.dtprideb,
                              rw_tbseg_prestamista.vldifseg,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              0,
                              0,
                              0,
                              0,
                              0,
                              0,
                              0,
                              0,
                              rw_tbseg_prestamista.dtnasctl,
                              rw_tbseg_prestamista.cdsexotl,
                              rw_tbseg_prestamista.vlprodut,
                              rw_tbseg_prestamista.qtparcel,
                              NULL,
                              NULL,
                              NULL,
                              0,
                              rw_tbseg_prestamista.tpdpagto,
                              rw_tbseg_prestamista.cdcooper,
                              0,
                              NULL,
                              rw_tbseg_prestamista.nrproposta,
                              rw_tbseg_prestamista.flggarad,
                              0,
                              rw_tbseg_prestamista.tpcustei,
                              0,
                              rw_tbseg_prestamista.flfinanciasegprestamista,
                              0);
    
    COMMIT;
    UPDATE cecred.crawseg
       SET nrproposta = rw_tbseg_prestamista.nrproposta
     WHERE cdcooper = rw_tbseg_prestamista.cdcooper
       AND nrdconta = rw_tbseg_prestamista.nrdconta
       AND nrctrato = rw_tbseg_prestamista.nrctremp
       AND nrctrseg = rw_tbseg_prestamista.nrctrseg;
   
    COMMIT;
   
 END LOOP;
 COMMIT; 
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
  CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
 
EXCEPTION
  WHEN vr_exc_saida THEN
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
    CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
              
    vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    dbms_output.put_line(vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
    CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
         
    vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || '. cdcooper = ' || vr_cdcooper || ' nrdconta = ' || vr_nrdconta || ' nrctrseg = ' || vr_nrctrseg || ' nrctremp = ' || vr_nrctremp;
    dbms_output.put_line(vr_dscritic);
  ROLLBACK; 

END;