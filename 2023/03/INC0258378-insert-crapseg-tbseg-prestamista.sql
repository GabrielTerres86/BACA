DECLARE

  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_cdcritic       NUMBER;
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0258378';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0258378.sql';
  vr_exc_saida      EXCEPTION;
  vr_nrsequen       NUMBER(10);
  vr_vlpercmo       NUMBER;
  vr_vlpercin       NUMBER;
  rw_tbseg_parametros_prst cecred.tbseg_parametros_prst%ROWTYPE;
  vr_nrproposta     cecred.crawseg.nrproposta%TYPE;

  CURSOR cr_principal IS
    SELECT a.flfinanciasegprestamista flfinanciaseg_emp,
           a.flggarad flggarad_emp,
           a.nrctremp,
           a.vlpreemp,
           a.qtpreemp,
           b.cdagenci , b.cdbccxlt, b.cdopeori, b.cdageori,
           d.*
      FROM CECRED.crawepr a, 
           CECRED.crapepr b, 
           CECRED.crawseg d
     WHERE b.cdcooper = a.cdcooper
       AND b.nrdconta = a.nrdconta
       AND b.nrctremp = a.nrctremp
       AND a.cdcooper = d.cdcooper
       AND a.nrdconta = d.nrdconta
       AND a.nrctremp = d.nrctrato
       AND a.flfinanciasegprestamista = 1
       AND d.nrproposta IS NOT NULL
       AND a.dtmvtolt BETWEEN '13/02/2023' and '15/02/2023'
       AND NOT EXISTS ( SELECT 1
                          FROM CECRED.tbseg_prestamista c
                         WHERE c.cdcooper = b.cdcooper
                           AND c.nrdconta = b.nrdconta
                           AND c.nrctremp = b.nrctremp)
       AND d.nrctrato IN (441156,
                          441038,
                          441397,
                          441446,
                          441491,
                          441303,
                          81306,
                          45294,
                          45332,
                          315537,
                          315968,
                          316024,
                          95801,
                          95818);

  PROCEDURE pc_valida_direto(pr_nmdireto IN  VARCHAR2,
                             pr_dscritic OUT CECRED.crapcri.dscritic%TYPE) IS
    vr_dscritic  CECRED.crapcri.dscritic%TYPE;
    vr_typ_saida VARCHAR2(3);
    vr_des_saida VARCHAR2(1000);
    vr_exc_erro  EXCEPTION;
    
    BEGIN
      IF NOT CECRED.gene0001.fn_exis_diretorio(pr_nmdireto) THEN

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                             pr_nmdireto ||
                                                             ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);

        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                             pr_nmdireto ||
                                                             ' 1> /dev/null',
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
    
    FOR rw_principal IN cr_principal LOOP

      vr_linha := 'DELETE FROM CECRED.crapseg  ' ||
                  ' WHERE cdcooper = ' || rw_principal.cdcooper ||
                  '   AND nrdconta = ' || rw_principal.nrdconta ||
                  '   AND nrctrseg = ' || rw_principal.nrctrseg ||
                  '   AND tpseguro = 4;';

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
      
      vr_linha := 'DELETE FROM CECRED.tbseg_prestamista  ' ||
                  ' WHERE cdcooper = ' || rw_principal.cdcooper ||
                  '   AND nrdconta = ' || rw_principal.nrdconta ||
                  '   AND nrctrseg = ' || rw_principal.nrctrseg || ';';

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

      vr_linha := 'UPDATE CECRED.crawseg  ' ||
                  '   SET nrproposta = ''' || vr_nrproposta || ''',' ||
                  '       flgassum = 0, ' ||
                  '       flggarad = ' || rw_principal.flggarad || ', ' ||
                  '       flfinanciasegprestamista = ' || rw_principal.flfinanciasegprestamista || ', ' ||
                  '       vlpremio = ' || replace(nvl(trim(to_char(rw_principal.vlpremio)),'null'),',','.') || ', ' ||
                  '       vlseguro = ' || replace(nvl(trim(to_char(rw_principal.vlseguro)),'null'),',','.') || ', ' || 
                  '       dtinivig = to_date(' || chr(39) || trim(to_char(rw_principal.dtinivig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
                  '       dtfimvig = to_date(' || chr(39) || trim(to_char(rw_principal.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ') ' ||
                  ' WHERE cdcooper = ' || rw_principal.cdcooper ||
                  '   AND nrdconta = ' || rw_principal.nrdconta ||
                  '   AND nrctrseg = ' || rw_principal.nrctrseg ||
                  '   AND tpseguro = 4;';

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

      
      vr_nrproposta := cecred.segu0003.FN_NRPROPOSTA(pr_tpcustei => 0,
                                                     pr_cdcooper => rw_principal.cdcooper,
                                                     pr_nrdconta => rw_principal.nrdconta,
                                                     pr_nrctrseg => rw_principal.nrctrseg);
        
      UPDATE CECRED.crawseg 
         SET flgassum = 1,
             flggarad = rw_principal.flggarad_emp,
             flfinanciasegprestamista = rw_principal.flfinanciaseg_emp,
             nrproposta = vr_nrproposta
       WHERE cdcooper = rw_principal.cdcooper
         AND nrdconta = rw_principal.nrdconta
         AND nrctrseg = rw_principal.nrctrseg
         AND tpseguro = 4;
      
      COMMIT;

      INSERT INTO CECRED.crapseg(nrdconta,
                   nrctrseg,
                   dtinivig,
                   dtfimvig,
                   dtmvtolt,
                   cdagenci,
                   cdbccxlt,
                   cdsitseg,
                   dtaltseg,
                   dtcancel,
                   dtdebito,
                   dtiniseg,
                   indebito,
                   nrdolote,
                   nrseqdig,
                   qtprepag,
                   vlprepag,
                   vlpreseg,
                   dtultpag,
                   tpseguro,
                   tpplaseg,
                   qtprevig,
                   cdsegura,
                   lsctrant,
                   nrctratu,
                   flgunica,
                   dtprideb,
                   vldifseg,
                   nmbenvid##1,
                   nmbenvid##2,
                   nmbenvid##3,
                   nmbenvid##4,
                   nmbenvid##5,
                   dsgraupr##1,
                   dsgraupr##2,
                   dsgraupr##3,
                   dsgraupr##4,
                   dsgraupr##5,
                   txpartic##1,
                   txpartic##2,
                   txpartic##3,
                   txpartic##4,
                   txpartic##5,
                   dtultalt,
                   cdoperad,
                   vlpremio,
                   qtparcel,
                   tpdpagto,
                   cdcooper,
                   flgconve,
                   flgclabe,
                   cdmotcan,
                   tpendcor,
                   progress_recid,
                   cdopecnl,
                   dtrenova,
                   cdopeori,
                   cdageori,
                   dtinsori,
                   cdopeexc,
                   cdageexc,
                   dtinsexc,
                   vlslddev,
                   idimpdps)
               values(rw_principal.nrdconta,
                  rw_principal.nrctrseg,
                  rw_principal.dtinivig,
                  rw_principal.dtfimvig,
                  rw_principal.dtmvtolt,
                  rw_principal.cdagenci,
                  rw_principal.cdbccxlt,
                  1,
                  null,
                  null,
                  rw_principal.dtdebito,
                  rw_principal.dtiniseg,
                  0,
                  0,
                  rw_principal.nrctrseg,
                  0,
                  0,
                  rw_principal.vlpreseg,
                  null,
                  rw_principal.tpseguro,
                  rw_principal.tpplaseg,
                  0,
                  rw_principal.cdsegura,
                  rw_principal.lsctrant,
                  rw_principal.nrctratu,
                  rw_principal.flgunica,
                  rw_principal.dtprideb,
                  rw_principal.vldifseg,
                  rw_principal.dscobext##1,
                  rw_principal.dscobext##2,
                  rw_principal.dscobext##3,
                  rw_principal.dscobext##4,
                  rw_principal.dscobext##5,
                  null,
                  null,
                  null,
                  null,
                  null,
                  rw_principal.vlcobext##1,
                  rw_principal.vlcobext##2,
                  rw_principal.vlcobext##3,
                  rw_principal.vlcobext##4,
                  rw_principal.vlcobext##5,
                  null,
                  rw_principal.cdopeori,
                  rw_principal.vlpremio,
                  rw_principal.qtparcel,
                  rw_principal.tpdpagto,
                  rw_principal.cdcooper,
                  0,
                  0,
                  0,
                  0,
                  rw_principal.progress_recid,
                  null,
                  null,
                  rw_principal.cdopeori,
                  rw_principal.cdageori,
                  null,
                  1,
                  0,
                  null,
                  rw_principal.vlseguro,
                  0);
        
      vr_nrsequen := CECRED.fn_sequence('TBSEG_PRESTAMISTA', 'SEQCERTIFICADO', 0);
  
      CECRED.SEGU0003.pc_parametros_segpre(pr_cdcooper        => rw_principal.cdcooper
                        ,pr_nrdconta        => rw_principal.nrdconta
                        ,pr_nrctremp        => rw_principal.nrctrato
                        ,pr_nrctrseg        => rw_principal.nrctrseg
                        ,pr_parametros_prst => rw_tbseg_parametros_prst
                        ,pr_cdcritic        => vr_cdcritic
                        ,pr_dscritic        => vr_dscritic);
      
      vr_vlpercmo := CECRED.SEGU0003.fn_retorna_prst_perc_morte(pr_cdcooper => rw_principal.cdcooper,
                                   pr_tppessoa => rw_tbseg_parametros_prst.tppessoa,
                                   pr_cdsegura => rw_tbseg_parametros_prst.cdsegura,
                                   pr_tpcustei => rw_tbseg_parametros_prst.tpcustei,
                                   pr_dtnasc   => rw_principal.dtnascsg,
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
         
      vr_vlpercin := CECRED.SEGU0003.fn_retorna_prst_perc_invalidez(pr_cdcooper => rw_principal.cdcooper,
                                     pr_tppessoa => rw_tbseg_parametros_prst.tppessoa,
                                     pr_cdsegura => rw_tbseg_parametros_prst.cdsegura,
                                     pr_tpcustei => rw_tbseg_parametros_prst.tpcustei,
                                     pr_dtnasc   => rw_principal.dtnascsg,
                                     pr_cdcritic => vr_cdcritic,
                                     pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
  
      INSERT INTO cecred.tbseg_prestamista(cdcooper,
                         nrdconta,
                         nrctrseg,
                         nrctremp,
                         tpregist,
                         cdapolic,
                         nrcpfcgc,
                         nmprimtl,
                         dtnasctl,
                         cdsexotl,
                         dsendres,
                         dsdemail,
                         nmbairro,
                         nmcidade,
                         cdufresd,
                         nrcepend,
                         nrtelefo,
                         dtdevend,
                         dtinivig,
                         cdcobran,
                         cdadmcob,
                         tpfrecob,
                         tpsegura,
                         cdprodut,
                         cdplapro,
                         vlprodut,
                         tpcobran,
                         vlsdeved,
                         vldevatu,
                         dtrefcob,
                         dtfimvig,
                         dtdenvio,
                         nrproposta,
                         tprecusa,
                         cdmotrec,
                         dtrecusa,
                         situacao,
                         tpcustei,
                         pemorte,
                         peinvalidez,
                         peiftttaxa,
                         qtifttdias,
                         nrapolice,
                         qtparcel,
                         vlpielimit,
                         vlifttlimi,
                         dsprotocolo,
                         flfinanciasegprestamista)
      values (rw_principal.cdcooper,
           rw_principal.nrdconta,
           rw_principal.nrctrseg,
           rw_principal.nrctrato,
           1, 
           vr_nrsequen,
           rw_principal.nrcpfcgc,
           rw_principal.nmdsegur,
           rw_principal.dtnascsg,
           rw_principal.cdsexosg,
           rw_principal.dsendres,
           null,
           rw_principal.nmbairro,
           rw_principal.nmcidade,
           rw_principal.cdufresd,
           rw_principal.nrcepend,
           rw_principal.nrfonres,
           rw_principal.dtmvtolt,
           rw_principal.dtinivig,
           10,
           null,
           'M',
           'MI',
           'BCV012',
           1,
           rw_principal.vlpremio,
           'O',
           rw_principal.vlseguro, 
           rw_principal.vlseguro, 
           rw_principal.dtmvtolt, 
           rw_principal.dtfimvig,
           rw_principal.dtmvtolt, 
           vr_nrproposta,
           null,
           null,
           null,
           null,
           rw_principal.tpcustei,
           vr_vlpercmo,
           vr_vlpercin,
           rw_tbseg_parametros_prst.iftttaxa,
           rw_tbseg_parametros_prst.ifttparc,
           rw_tbseg_parametros_prst.nrapolic,
           rw_tbseg_parametros_prst.qtparcel,
           rw_tbseg_parametros_prst.pielimit,
           rw_tbseg_parametros_prst.ifttlimi,
           null,
           rw_principal.flfinanciaseg_emp);
        
      
      COMMIT;
      
      CECRED.SEGU0003.pc_atualiza_tab_seguro(pr_cdcooper  => rw_principal.cdcooper,
                                             pr_nrdconta  => rw_principal.nrdconta,
                                             pr_nrctremp  => rw_principal.nrctremp,
                                             pr_nrctrseg  => rw_principal.nrctrseg,
                                             pr_dtnascsg  => rw_principal.dtnascsg,    
                                             pr_vlpreemp  => rw_principal.vlpreemp,    
                                             pr_qtpreemp  => rw_principal.qtpreemp,
                                             pr_dtinivig  => rw_principal.dtinivig,
                                             pr_dtfimvig  => rw_principal.dtfimvig,
                                             pr_cdcritic  => vr_cdcritic,
                                             pr_dscritic  => vr_dscritic);
      
      COMMIT; 
   END LOOP;

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
       
            vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            dbms_output.put_line(vr_dscritic);
            ROLLBACK;
    END;
