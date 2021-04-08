declare
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_rootmicros    VARCHAR2(5000);
  vr_qtd            INTEGER;
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;

---------------------------------------------------------  
  --Buscar os registros a serem atualizados.
  CURSOR cr_registros IS
  select a.*
          from tbseg_prestamista a,
               (select max(IDSEQTRA) as IDSEQTRA,
                       cdcooper,
                       nrdconta,
                       nrctremp,
                       count(nrctremp)
                  from tbseg_prestamista c
                 where c.tpregist in (1, 3)
                 group by cdcooper, nrdconta, nrctremp
                having count(1) > 1) b
         where a.cdcooper = b.cdcooper
           and a.nrdconta = b.nrdconta
           and a.nrctremp = b.nrctremp
           and a.IDSEQTRA <> b.IDSEQTRA;
  rw_registro cr_registros%rowtype;  
---------------------------------------------------------  
  CURSOR cr_registros2 IS
  select p.*
    from crapseg p
    left join tbseg_prestamista s
    on p.NRDCONTA = S.NRDCONTA
     and p.CDCOOPER = S.CDCOOPER
     and p.nrctrseg = S.nrctrseg
   where idseqtra is null
     and p.Tpseguro = 4
     and p.cdsitseg = 1;
   rw_registro2 cr_registros2%rowtype;  

---------------------------------------------------------  
  CURSOR cr_registros3(pr_NRDCONTA crawseg.NRDCONTA%TYPE,
                       pr_CDCOOPER crawseg.CDCOOPER%TYPE,
                       pr_nrctrseg crawseg.nrctrseg%TYPE) IS
    select * from 
    crawseg w where w.NRDCONTA = pr_NRDCONTA 
                and w.CDCOOPER = pr_CDCOOPER
                and w.nrctrseg = pr_nrctrseg;
      rw_registro3 cr_registros3%rowtype;
---------------------------------------------------------  

  -- Validacao de diretorio
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2,
                             pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic  crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);
    BEGIN
      -- Primeiro garantimos que o diretorio exista
      IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN
        -- Efetuar a criação do mesmo
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                      pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
        -- Adicionar permissão total na pasta
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                      pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;
  END;

BEGIN

  vr_rootmicros     := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto       := vr_rootmicros|| 'cpd/bacas';
--  vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 3);
  pc_valida_direto(pr_nmdireto => vr_nmdireto || '/INC0081790',
                   pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  vr_nmdireto := vr_nmdireto || '/INC0081790';

  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);

  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          '-- Programa para rollback das informacoes' ||
                          chr(13),
                          FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'BEGIN' || chr(13),
                          FALSE);

  vr_nmarqbkp := 'ROLLBACK_INC0081790' || to_char(sysdate, 'hh24miss') ||
                 '.sql';
  ----------------------------------------------------------------------
  -- Gera rollback
  for rw_registro in cr_registros loop
      gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,                                             
                'insert into tbseg_prestamista(IDSEQTRA, CDCOOPER, NRDCONTA, NRCTRSEG, NRCTREMP, TPREGIST, CDAPOLIC, NRCPFCGC, NMPRIMTL, DTNASCTL, CDSEXOTL, DSENDRES, DSDEMAIL, NMBAIRRO, NMCIDADE, CDUFRESD, NRCEPEND, NRTELEFO, DTDEVEND, DTINIVIG, CDCOBRAN, CDADMCOB, TPFRECOB, TPSEGURA, CDPRODUT, CDPLAPRO, VLPRODUT, TPCOBRAN, VLSDEVED, VLDEVATU, DTREFCOB, DTFIMVIG, DTDENVIO, NRPROPOSTA ) values (''' ||
                   rw_registro.IDSEQTRA || ''',''' || --1
                   rw_registro.CDCOOPER || ''',''' || --1,
                   rw_registro.NRDCONTA || ''',''' || --3854868,
                   rw_registro.NRCTRSEG || ''',''' || --402015,
                   rw_registro.NRCTREMP || ''',''' || --1360400,
                   rw_registro.TPREGIST || ''',''' || --3,
                   rw_registro.CDAPOLIC || ''',''' || --39804,
                   rw_registro.NRCPFCGC || ''',''' || --217674089,
                   rw_registro.NMPRIMTL ||            --'GEAZI BONIFACIO MELLO',
                   ''',to_date(''' || rw_registro.DTNASCTL || ''', ''dd-mm-yyyy''),''' || --to_date('04-04-1984', 'dd-mm-yyyy'),
                   rw_registro.CDSEXOTL || ''',''' || --1,
                   rw_registro.DSENDRES || ''',''' || --'RUA PAULO SCHORK',
                   rw_registro.DSDEMAIL || ''',''' || --null,
                   rw_registro.NMBAIRRO || ''',''' || --'GUABIRUBA SUL',
                   rw_registro.NMCIDADE || ''',''' || --'GUABIRUBA',
                   rw_registro.CDUFRESD || ''',''' || --'SC',
                   rw_registro.NRCEPEND || ''',''' || --'88360000',
                   rw_registro.NRTELEFO ||            --'4733541596',
                   ''',to_date(''' || rw_registro.DTDEVEND || ''', ''dd-mm-yyyy'')' || --to_date('01-01-2019', 'dd-mm-yyyy'),
                   ',to_date(''' || rw_registro.DTINIVIG || ''', ''dd-mm-yyyy''),''' || --to_date('01-01-2019', 'dd-mm-yyyy'),
                   rw_registro.CDCOBRAN || ''',''' || --10,
                   rw_registro.CDADMCOB || ''',''' || --null,
                   rw_registro.TPFRECOB || ''',''' || --'M',
                   rw_registro.TPSEGURA || ''',''' || --'MI',
                   rw_registro.CDPRODUT || ''',''' || --'BCV012',
                   rw_registro.CDPLAPRO || ''',''' || --1,
                   rw_registro.VLPRODUT || ''',''' || --9.36,
                   rw_registro.TPCOBRAN || ''',''' || --'O',
                   rw_registro.VLSDEVED || ''',''' || --1621.12,
                   rw_registro.VLDEVATU ||            --1295.80,
                   ''',to_date(''' || rw_registro.DTREFCOB || ''', ''dd-mm-yyyy'')' || --to_date('28-02-2021', 'dd-mm-yyyy'),
                   ',to_date(''' || rw_registro.DTFIMVIG || ''', ''dd-mm-yyyy'')' || --to_date('15-12-2021', 'dd-mm-yyyy'),
                   ',to_date(''' || rw_registro.DTDENVIO || ''', ''dd-mm-yyyy''),''' || --to_date('04-03-2021', 'dd-mm-yyyy'),
                   rw_registro.NRPROPOSTA || ''');'     --null                                                          
                ,
                              FALSE);
                
                
    -- Efetua correção
      delete from TBSEG_PRESTAMISTA where IDSEQTRA = rw_registro.IDSEQTRA;
      ---------------------------------------------------------------------
    
  end loop;
  ------------------------------------------------------------------------------------------------------------------------------  
  for rw_registro2 in cr_registros2 loop
    
      gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,                                                            
                'insert into crapseg (NRDCONTA, NRCTRSEG, DTINIVIG, DTFIMVIG, DTMVTOLT, CDAGENCI, CDBCCXLT, CDSITSEG, DTALTSEG, DTCANCEL, DTDEBITO, DTINISEG, INDEBITO, NRDOLOTE, NRSEQDIG, QTPREPAG, VLPREPAG, VLPRESEG, DTULTPAG, TPSEGURO, TPPLASEG, QTPREVIG, CDSEGURA, LSCTRANT, NRCTRATU, FLGUNICA, DTPRIDEB, VLDIFSEG, NMBENVID##1, NMBENVID##2, NMBENVID##3, NMBENVID##4, NMBENVID##5, DSGRAUPR##1, DSGRAUPR##2, DSGRAUPR##3, DSGRAUPR##4, DSGRAUPR##5, TXPARTIC##1, TXPARTIC##2, TXPARTIC##3, TXPARTIC##4, TXPARTIC##5, DTULTALT, CDOPERAD, VLPREMIO, QTPARCEL, TPDPAGTO, CDCOOPER, FLGCONVE, FLGCLABE, CDMOTCAN, TPENDCOR, PROGRESS_RECID, CDOPECNL, DTRENOVA, CDOPEORI, CDAGEORI, DTINSORI, CDOPEEXC, CDAGEEXC, DTINSEXC, VLSLDDEV, IDIMPDPS) values(''' ||
                rw_registro2.NRDCONTA     || ''',''' ||--7485301, 
                rw_registro2.NRCTRSEG     || --72948, 
                 ''',to_date(''' || rw_registro2.DTINIVIG || ''', ''dd-mm-yyyy'')' || --to_date('08-01-2015', 'dd-mm-yyyy'), 
                 ',to_date(''' || rw_registro2.DTFIMVIG || ''', ''dd-mm-yyyy'')' || --to_date('19-10-2016', 'dd-mm-yyyy'), 
                 ',to_date(''' || rw_registro2.DTMVTOLT || ''', ''dd-mm-yyyy''),''' ||--to_date('08-01-2015', 'dd-mm-yyyy'), 
                rw_registro2.CDAGENCI     || ''','''  ||--35, 
                rw_registro2.CDBCCXLT     || ''','''  ||--0, 
                rw_registro2.CDSITSEG     || --2, 
                ''',to_date('''|| rw_registro2.DTALTSEG || ''', ''dd-mm-yyyy'')' ||--to_date('08-01-2015', 'dd-mm-yyyy'), 
                ',to_date('''  || rw_registro2.DTCANCEL || ''', ''dd-mm-yyyy'')' ||--to_date('19-10-2016', 'dd-mm-yyyy'), 
                ',to_date('''  || rw_registro2.DTDEBITO || ''', ''dd-mm-yyyy'')' ||--to_date('08-11-2016', 'dd-mm-yyyy'), 
                ',to_date('''  || rw_registro2.DTINISEG || ''', ''dd-mm-yyyy''),''' ||--to_date('08-01-2015', 'dd-mm-yyyy'), 
                rw_registro2.INDEBITO     || ''','''  ||--1, 
                rw_registro2.NRDOLOTE     || ''','''  ||--0, 
                rw_registro2.NRSEQDIG     || ''','''  ||--72948, 
                rw_registro2.QTPREPAG     || ''','''  ||--22, 
                rw_registro2.VLPREPAG     || ''','''  ||--91.16, 
                rw_registro2.VLPRESEG     || --5.36, 
                ''',to_date('''|| rw_registro2.DTULTPAG || ''', ''dd-mm-yyyy''),''' ||--to_date('10-10-2016', 'dd-mm-yyyy'), 
                rw_registro2.TPSEGURO     || ''','''  ||--3, 
                rw_registro2.TPPLASEG     || ''','''  ||--11, 
                rw_registro2.QTPREVIG     || ''','''  ||--22, 
                rw_registro2.CDSEGURA     || ''','''  ||--5011, 
                rw_registro2.LSCTRANT     || ''','''  ||--' ', 
                rw_registro2.NRCTRATU     || ''','''  ||--0, 
                rw_registro2.FLGUNICA     || ''','''  ||--0, 
                rw_registro2.DTPRIDEB       || ''','''  ||--null, 
                rw_registro2.VLDIFSEG       || ''','''  ||--0.00, 
                rw_registro2.NMBENVID##1    || ''','''  ||--'JURACI TEREZINHA DE FANTE', 
                rw_registro2.NMBENVID##2    || ''','''  ||--' ', 
                rw_registro2.NMBENVID##3    || ''','''  ||--' ', 
                rw_registro2.NMBENVID##4    || ''','''  ||--' ', 
                rw_registro2.NMBENVID##5    || ''','''  ||--' ', 
                rw_registro2.DSGRAUPR##1    || ''','''  ||--'MAE', 
                rw_registro2.DSGRAUPR##2    || ''','''  ||--' ', 
                rw_registro2.DSGRAUPR##3    || ''','''  ||--' ', 
                rw_registro2.DSGRAUPR##4    || ''','''  ||--' ', 
                rw_registro2.DSGRAUPR##5    || ''','''  ||--' ', 
                rw_registro2.TXPARTIC##1    || ''','''  ||--100.00, 
                rw_registro2.TXPARTIC##2    || ''','''  ||--0.00, 
                rw_registro2.TXPARTIC##3    || ''','''  ||--0.00, 
                rw_registro2.TXPARTIC##4    || ''','''  ||--0.00, 
                rw_registro2.TXPARTIC##5    || ''','''  ||--0.00, 
                rw_registro2.DTULTALT       || ''','''  ||
                rw_registro2.CDOPERAD       || ''','''  ||
                rw_registro2.VLPREMIO       || ''','''  ||
                rw_registro2.QTPARCEL       || ''','''  ||
                rw_registro2.TPDPAGTO       || ''','''  ||
                rw_registro2.CDCOOPER       || ''','''  ||
                rw_registro2.FLGCONVE       || ''','''  ||
                rw_registro2.FLGCLABE       || ''','''  ||
                rw_registro2.CDMOTCAN       || ''','''  ||
                rw_registro2.TPENDCOR       || ''','''  ||
                rw_registro2.PROGRESS_RECID || ''','''  ||
                rw_registro2.CDOPECNL       || ''','''  ||
                rw_registro2.DTRENOVA       || ''','''  ||
                rw_registro2.CDOPEORI       || ''','''  ||
                rw_registro2.CDAGEORI       || ''','''  ||
                rw_registro2.DTINSORI       || ''','''  ||
                rw_registro2.CDOPEEXC       || ''','''  ||
                rw_registro2.CDAGEEXC       || ''','''  ||
                rw_registro2.DTINSEXC       || ''','''  ||
                rw_registro2.VLSLDDEV       || ''','''  ||
                rw_registro2.IDIMPDPS       || ''');'
                 ,
                              FALSE);

      OPEN cr_registros3 (pr_NRDCONTA => rw_registro2.NRDCONTA,
                          pr_CDCOOPER => rw_registro2.CDCOOPER,
                          pr_nrctrseg => rw_registro2.nrctrseg
                       );

      FETCH cr_registros3 INTO rw_registro3;
    
    delete from crapseg where PROGRESS_RECID = rw_registro2.PROGRESS_RECID;
    
      gene0002.pc_escreve_xml(vr_dados_rollback,
                              vr_texto_rollback,                                                            
                 'insert into crawseg  (DTMVTOLT,   NRDCONTA,   NRCTRSEG,   TPSEGURO,   NMDSEGUR,   TPPLASEG,   NMBENEFI,   NRCADAST,   NMDSECAO,   DSENDRES,   NRENDRES,   NMBAIRRO,   NMCIDADE,   CDUFRESD,   NRCEPEND,   DTINIVIG,   DTFIMVIG,   DSMARVEI,   DSTIPVEI,   NRANOVEI,   NRMODVEI,   QTPASVEI,   PPDBONUS,   FLGDNOVO,   NRAPOANT,   NMSEGANT,   FLGDUTIL,   FLGNOTAF,   FLGAPANT,   VLPRESEG,   VLSEGURO,   VLDFRANQ,   VLDCASCO,   VLVERBAE,   FLGASSIS,   VLDANMAT,   VLDANPES,   VLDANMOR,   VLAPPMOR,   VLAPPINV,   CDSEGURA,   NMEMPRES,   DSCHASSI,   FLGRENOV,   DTDEBITO,   VLBENEFI,   CDCALCUL,   FLGCURSO,   DTINISEG,   NRDPLACA,   LSCTRANT,   NRCPFCGC,   NRCTRATU,   NMCPVEIC,   FLGUNICA,   NRCTRATO,   FLGVISTO,   CDAPOANT,   DTPRIDEB,   VLDIFSEG,   DSCOBEXT##1,   DSCOBEXT##2,   DSCOBEXT##3,   DSCOBEXT##4,   DSCOBEXT##5,   VLCOBEXT##1,   VLCOBEXT##2,   VLCOBEXT##3,   VLCOBEXT##4,   VLCOBEXT##5,   FLGREPGR,   VLFRQOBR,   TPSEGVID,   DTNASCSG,   CDSEXOSG,   VLPREMIO,   QTPARCEL,   NRFONEMP,   NRFONRES,   DSOUTGAR,   VLOUTGAR,   TPDPAGTO,   CDCOOPER,   FLGCONVE,   COMPLEND,   PROGRESS_RECID,   NRPROPOSTA ) values (' ||   
                 'to_date(''' ||  rw_registro3.DTMVTOLT  || ''', ''dd-mm-yyyy''),''' ||
                  rw_registro3.NRDCONTA   || ''',''' ||
                  rw_registro3.NRCTRSEG   || ''',''' ||
                  rw_registro3.TPSEGURO   || ''',''' ||
                  rw_registro3.NMDSEGUR   || ''',''' ||
                  rw_registro3.TPPLASEG   || ''',''' ||
                  rw_registro3.NMBENEFI   || ''',''' ||
                  rw_registro3.NRCADAST   || ''',''' ||
                  rw_registro3.NMDSECAO   || ''',''' ||
                  rw_registro3.DSENDRES   || ''',''' ||
                  rw_registro3.NRENDRES   || ''',''' ||
                  rw_registro3.NMBAIRRO   || ''',''' ||
                  rw_registro3.NMCIDADE   || ''',''' ||
                  rw_registro3.CDUFRESD   || ''',''' ||
                  rw_registro3.NRCEPEND   || 
                  ''',to_date(''' || rw_registro3.DTINIVIG   || ''', ''dd-mm-yyyy'')' ||
                  ',to_date(''' ||rw_registro3.DTFIMVIG    || ''', ''dd-mm-yyyy''),''' ||
                  rw_registro3.DSMARVEI   || ''',''' ||
                  rw_registro3.DSTIPVEI   || ''',''' ||
                  rw_registro3.NRANOVEI   || ''',''' ||
                  rw_registro3.NRMODVEI   || ''',''' ||
                  rw_registro3.QTPASVEI   || ''',''' ||
                  rw_registro3.PPDBONUS   || ''',''' ||
                  rw_registro3.FLGDNOVO   || ''',''' ||
                  rw_registro3.NRAPOANT   || ''',''' ||
                  rw_registro3.NMSEGANT   || ''',''' ||
                  rw_registro3.FLGDUTIL   || ''',''' ||
                  rw_registro3.FLGNOTAF   || ''',''' ||
                  rw_registro3.FLGAPANT   || ''',''' ||
                  rw_registro3.VLPRESEG   || ''',''' ||
                  rw_registro3.VLSEGURO   || ''',''' ||
                  rw_registro3.VLDFRANQ   || ''',''' ||
                  rw_registro3.VLDCASCO   || ''',''' ||
                  rw_registro3.VLVERBAE   || ''',''' ||
                  rw_registro3.FLGASSIS   || ''',''' ||
                  rw_registro3.VLDANMAT   || ''',''' ||
                  rw_registro3.VLDANPES   || ''',''' ||
                  rw_registro3.VLDANMOR   || ''',''' ||
                  rw_registro3.VLAPPMOR   || ''',''' ||
                  rw_registro3.VLAPPINV   || ''',''' ||
                  rw_registro3.CDSEGURA   || ''',''' ||
                  rw_registro3.NMEMPRES   || ''',''' ||
                  rw_registro3.DSCHASSI   || ''',''' ||
                  rw_registro3.FLGRENOV   || 
                  ''',to_date(''' ||rw_registro3.DTDEBITO || ''', ''dd-mm-yyyy''),''' ||
                  rw_registro3.VLBENEFI   || ''',''' ||
                  rw_registro3.CDCALCUL   || ''',''' ||
                  rw_registro3.FLGCURSO   ||
                  ''',to_date(''' ||rw_registro3.DTINISEG|| ''', ''dd-mm-yyyy''),''' ||
                  rw_registro3.NRDPLACA   || ''',''' ||
                  rw_registro3.LSCTRANT   || ''',''' ||
                  rw_registro3.NRCPFCGC   || ''',''' ||
                  rw_registro3.NRCTRATU   || ''',''' ||
                  rw_registro3.NMCPVEIC   || ''',''' ||
                  rw_registro3.FLGUNICA   || ''',''' ||
                  rw_registro3.NRCTRATO   || ''',''' ||
                  rw_registro3.FLGVISTO   || ''',''' ||
                  rw_registro3.CDAPOANT   || 
                  ''',to_date(''' ||rw_registro3.DTPRIDEB|| ''', ''dd-mm-yyyy''),''' ||
                  rw_registro3.VLDIFSEG   || ''',''' ||
                  rw_registro3.DSCOBEXT##1  || ''',''' ||
                  rw_registro3.DSCOBEXT##2  || ''',''' ||
                  rw_registro3.DSCOBEXT##3  || ''',''' ||
                  rw_registro3.DSCOBEXT##4  || ''',''' ||
                  rw_registro3.DSCOBEXT##5  || ''',''' ||
                  rw_registro3.VLCOBEXT##1  || ''',''' ||
                  rw_registro3.VLCOBEXT##2  || ''',''' ||
                  rw_registro3.VLCOBEXT##3  || ''',''' ||
                  rw_registro3.VLCOBEXT##4  || ''',''' ||
                  rw_registro3.VLCOBEXT##5  || ''',''' ||
                  rw_registro3.FLGREPGR   || ''',''' ||
                  rw_registro3.VLFRQOBR   || ''',''' ||
                  rw_registro3.TPSEGVID   || 
                  ''',to_date(''' ||rw_registro3.DTNASCSG|| ''', ''dd-mm-yyyy''),''' ||
                  rw_registro3.CDSEXOSG   || ''',''' ||
                  rw_registro3.VLPREMIO   || ''',''' ||
                  rw_registro3.QTPARCEL   || ''',''' ||
                  rw_registro3.NRFONEMP   || ''',''' ||
                  rw_registro3.NRFONRES   || ''',''' ||
                  rw_registro3.DSOUTGAR   || ''',''' ||
                  rw_registro3.VLOUTGAR   || ''',''' ||
                  rw_registro3.TPDPAGTO   || ''',''' ||
                  rw_registro3.CDCOOPER   || ''',''' ||
                  rw_registro3.FLGCONVE   || ''',''' ||
                  rw_registro3.COMPLEND   || ''',''' ||
                  rw_registro3.PROGRESS_RECID || ''',''' ||
                  rw_registro3.NRPROPOSTA     || ''');',
                              FALSE);
    
    delete from crawseg where NRDCONTA = rw_registro3.NRDCONTA and CDCOOPER = rw_registro3.CDCOOPER and nrctrseg = rw_registro3.nrctrseg;
    CLOSE cr_registros3;
  end loop;

  ---------------------------------------------------------------
  -- Adiciona TAG de commit 
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'COMMIT;' || chr(13),
                          FALSE);
						  
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'END;' || chr(13),
                          FALSE);

  -- Fecha o arquivo          
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          chr(13),
                          TRUE);

  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3 --> Cooperativa conectada
                                     ,
                                      pr_cdprogra  => 'ATENDA' --> Programa chamador - utilizamos apenas um existente 
                                     ,
                                      pr_dtmvtolt  => trunc(SYSDATE) --> Data do movimento atual
                                     ,
                                      pr_dsxml     => vr_dados_rollback --> Arquivo XML de dados
                                     ,
                                      pr_dsarqsaid => vr_nmdireto || '/' ||
                                                      vr_nmarqbkp --> Path/Nome do arquivo PDF gerado
                                     ,
                                      pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                                     ,
                                      pr_flg_gerar => 'S' --> Gerar o arquivo na hora
                                     ,
                                      pr_flgremarq => 'N' --> remover arquivo apos geracao
                                     ,
                                      pr_nrcopias  => 1 --> Número de cópias para impressão
                                     ,
                                      pr_des_erro  => vr_dscritic); --> Retorno de Erro

  -- Liberando a memória alocada pro CLOB    
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);

  -- Efetuamos a transação  
  COMMIT;
END;
/
