declare
  vr_nrctrseg   cecred.crawseg.nrctrseg%TYPE;
  vr_nrproposta cecred.crawseg.nrproposta%TYPE;
  vr_exc_saida  EXCEPTION;
  vr_nrseqdig   NUMERIC(15);
  vr_nrsequen   NUMBER(10);
  vr_dtrefere   DATE;
  vr_nmdir      VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0276141';
  vr_nmarq      VARCHAR2(100)  := 'ROLLBACK_INC0276141.sql';
  vr_ind_arq    utl_file.file_type;
  vr_linha      VARCHAR2(32767);
  vr_dscritic   VARCHAR2(2000);
  vr_nrseguro   cecred.tbseg_prestamista.nrctrseg%TYPE;

  CURSOR cr_principal IS
    SELECT *
      FROM cecred.tbseg_prestamista t
     WHERE t.nrproposta IN ('202304214850',
                            '202304214848',
                            '202304214862',
                            '202304214852',
                            '202304214858',
                            '202304214860',
                            '202304214856',
                            '202304214854',
                            '202304214864',
                            '202304214866',
                            '202304214868',
                            '202304214870',
                            '202304214872',
                            '202304214876',
                            '202304214874',
                            '202304214878',
                            '202304214880',
                            '202304214882',
                            '202304214884',
                            '202304214886',
                            '202304214888',
                            '202304214890',
                            '202304214892',
                            '202304214894',
                            '202304214896',
                            '202304214898',
                            '202304214900',
                            '202304214902',
                            '202304214904',
                            '202304214906',
                            '202304214908',
                            '202304214910',
                            '202304214914',
                            '202304214912',
                            '202304214920',
                            '202304214918',
                            '202304214916',
                            '202304214922',
                            '202304214924',
                            '202304214932',
                            '202304214928',
                            '202304214934',
                            '202304214926',
                            '202304214930',
                            '202304214938',
                            '202304214936',
                            '202304214940',
                            '202304214942',
                            '202304214944',
                            '202304214946',
                            '202304214960',
                            '202304214958',
                            '202304214956',
                            '202304214952',
                            '202304214948',
                            '202304214950',
                            '202304214954',
                            '202304214966',
                            '202304214964',
                            '202304214962',
                            '202304214968',
                            '202304214970',
                            '202304214972',
                            '202304214976',
                            '202304214974',
                            '202304214978',
                            '202304214980',
                            '202304214982',
                            '202304214984',
                            '202304214986',
                            '202304214990',
                            '202304214988',
                            '202304214992',
                            '202304214994',
                            '202304214996',
                            '202304214998',
                            '202304215000',
                            '202304215002',
                            '202304215006',
                            '202304215008',
                            '202304215004',
                            '202304215010',
                            '202304215012',
                            '202304215018',
                            '202304215016',
                            '202304215014',
                            '202304345108',
                            '202304345110',
                            '202304215020',
                            '202304345112',
                            '202304345114',
                            '202304345116',
                            '202304345126',
                            '202304345120',
                            '202304345118',
                            '202304345128',
                            '202304345124',
                            '202304345122',
                            '202304345130',
                            '202304345132',
                            '202304345134',
                            '202304345136',
                            '202304345138',
                            '202304345140',
                            '202304345142',
                            '202304345146',
                            '202304345144',
                            '202304345148',
                            '202304345150',
                            '202304345152',
                            '202304345156',
                            '202304345158',
                            '202304345154',
                            '202304345160',
                            '202304345162',
                            '202304345164',
                            '202304345166',
                            '202304345170',
                            '202304345172',
                            '202304345174',
                            '202304345176',
                            '202304345178',
                            '202304345180',
                            '202304345182',
                            '202304345184',
                            '202304345186',
                            '202304345188',
                            '202304345190',
                            '202304345192',
                            '202304345194')
     ORDER BY t.cdcooper, t.nrdconta, t.nrctrseg;

  rw_principal cr_principal%ROWTYPE;
      
  CURSOR cr_tbseg_prestamista(pr_cdcooper in cecred.tbseg_prestamista.cdcooper%TYPE,
                              pr_nrdconta in cecred.tbseg_prestamista.nrdconta%TYPE,
                              pr_nrctremp in cecred.tbseg_prestamista.nrctremp%TYPE) IS
    SELECT p.vlprodut 
      FROM CECRED.tbseg_prestamista p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.nrctremp = pr_nrctremp
       AND p.nrproposta IN ('770350363653',
                            '770350382500',
                            '770349642999',
                            '770349642980',
                            '770349642948',
                            '770349642956',
                            '770349642930',
                            '770349642964',
                            '770350094032',
                            '770353822799',
                            '770355157440',
                            '770357416060',
                            '770350486577',
                            '770356018370',
                            '770359444460',
                            '770355812383',
                            '770358981259',
                            '770358052010',
                            '770354616408',
                            '770657475750',
                            '770613668403',
                            '770356996070',
                            '770349026694',
                            '770353405497',
                            '770613124080',
                            '770573456076',
                            '770573570103',
                            '770349930234',
                            '770349494299',
                            '770657643017',
                            '770358393004',
                            '770356083857',
                            '770573552571',
                            '770355079988',
                            '770613701800',
                            '770573201728',
                            '770355334031',
                            '770350535535',
                            '770573513975',
                            '770573611420',
                            '770349314274',
                            '770573611446',
                            '770349314258',
                            '770350176756',
                            '770351205865',
                            '770349306239',
                            '770350241884',
                            '770613011692',
                            '770572926184',
                            '770613597042',
                            '770356672623',
                            '770356893611',
                            '770357829380',
                            '770358916074',
                            '770350257268',
                            '770358656048',
                            '770357125944',
                            '770352127590',
                            '770351490942',
                            '770349249367',
                            '770353928163',
                            '770355063062',
                            '770349057727',
                            '770354209675',
                            '770349243580',
                            '770359416555',
                            '770354668246',
                            '770354206072',
                            '770349193892',
                            '770573307909',
                            '770353958780',
                            '770353148001',
                            '770359201060',
                            '770358360882',
                            '770355969169',
                            '770573610997',
                            '770350256032',
                            '770613148302',
                            '770613464816',
                            '770657503959',
                            '770573655303',
                            '770613598278',
                            '770349285886',
                            '770356740297',
                            '770359678231',
                            '770349225280',
                            '770357409837',
                            '770657532312',
                            '770350246835',
                            '770354280604',
                            '770357218012',
                            '770357345243',
                            '770573022742',
                            '770351912847',
                            '770351372621',
                            '770573681770',
                            '770354948010',
                            '770354516519',
                            '770572881091',
                            '770358800777',
                            '770351047526',
                            '770353450913',
                            '770354736110',
                            '770349911477',
                            '770356664400',
                            '770573385217',
                            '770354700077',
                            '770351374586',
                            '770573323823',
                            '770573324005',
                            '770573358333',
                            '770613690310',
                            '770350206930',
                            '770613182403',
                            '770354535971',
                            '770353660950',
                            '770613224670',
                            '770358101798',
                            '770573520491',
                            '770354612054',
                            '770573789008',
                            '770573094832',
                            '770573270541',
                            '770573725298',
                            '770354497263',
                            '770613579133',
                            '770354938405',
                            '770351510692',
                            '770657296511',
                            '770353653687');
  rw_tbseg_prestamista cr_tbseg_prestamista%ROWTYPE;   
  
  CURSOR cr_saldo_emp(pr_cdcooper in cecred.crapris.cdcooper%TYPE,
                      pr_nrdconta in cecred.crapris.nrdconta%TYPE,
                      pr_nrctremp in cecred.crapris.nrctremp%TYPE) IS
    SELECT SUM(j.vldivida) saldo
      FROM CECRED.crapris j,
           CECRED.crapepr e
     WHERE j.cdcooper = e.cdcooper
       AND j.nrdconta = e.nrdconta
       AND j.nrctremp = e.nrctremp
       AND j.inddocto = 1
       AND j.cdcooper = pr_cdcooper
       AND j.nrdconta = pr_nrdconta
       AND j.nrctremp = pr_nrctremp
       AND j.dtrefere = TO_DATE('31/03/2023','DD/MM/RRRR');
  rw_saldo_emp cr_saldo_emp%ROWTYPE;  
    
  CURSOR cr_saldodev(pr_cdcooper in cecred.crapris.cdcooper%TYPE,
                     pr_nrdconta in cecred.crapris.nrdconta%TYPE) IS
    SELECT SUM(j.vldivida) saldo
      FROM cecred.crapris j,
           cecred.crapepr e
     WHERE j.cdcooper = e.cdcooper
       AND j.nrdconta = e.nrdconta
       AND j.nrctremp = e.nrctremp
       AND j.inddocto = 1
       AND j.dtrefere = TO_DATE('31/03/2023','DD/MM/RRRR') 
       AND j.cdcooper = pr_cdcooper
       AND j.nrdconta = pr_nrdconta;
  rw_saldodev cr_saldodev%ROWTYPE;       
 
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
        vr_dscritic := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
        RAISE vr_exc_erro;
      END IF;

      CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto || ' 1> /dev/null',
                                         pr_typ_saida   => vr_typ_saida,
                                         pr_des_saida   => vr_des_saida);

      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
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
     
   OPEN cr_saldo_emp(pr_cdcooper => rw_principal.cdcooper,
                     pr_nrdconta => rw_principal.nrdconta,
                     pr_nrctremp => rw_principal.nrctremp);
   FETCH cr_saldo_emp INTO rw_saldo_emp;
   CLOSE cr_saldo_emp;
   
   OPEN cr_saldodev(pr_cdcooper => rw_principal.cdcooper,
                   pr_nrdconta => rw_principal.nrdconta);
   FETCH cr_saldodev INTO rw_saldodev;
   CLOSE cr_saldodev;
   
   OPEN cr_tbseg_prestamista(pr_cdcooper => rw_principal.cdcooper,
                             pr_nrdconta => rw_principal.nrdconta,
                             pr_nrctremp => rw_principal.nrctremp);
   FETCH cr_tbseg_prestamista INTO rw_tbseg_prestamista;
   CLOSE cr_tbseg_prestamista;
   
   vr_linha := 'UPDATE CECRED.crawseg ' ||
               ' SET vlpremio = 0' || 
               ' , vlseguro = ' || REPLACE(REPLACE(TO_CHAR(rw_principal.vlsdeved),'.',','),',','.') || 
               ' WHERE cdcooper = ' || rw_principal.cdcooper ||
               ' AND nrdconta = ' || rw_principal.nrdconta ||
               ' AND nrctrseg = ' || rw_principal.nrctrseg ||
               ' AND tpseguro = 4;';
   
   CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
   
   vr_linha := 'UPDATE CECRED.crapseg ' ||
               ' SET vlpremio = 0' || 
               ' , vlslddev = ' || REPLACE(REPLACE(TO_CHAR(rw_principal.vlsdeved),'.',','),',','.') || 
               ' WHERE cdcooper = ' || rw_principal.cdcooper ||
               ' AND nrdconta = ' || rw_principal.nrdconta ||
               ' AND nrctrseg = ' || rw_principal.nrctrseg ||
               ' AND tpseguro = 4;';
   
   CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
      
   vr_linha := 'UPDATE CECRED.tbseg_prestamista ' ||
               ' SET vlprodut = ' || REPLACE(REPLACE(TO_CHAR(rw_principal.vlprodut),'.',','),',','.') || 
               ' , vldevatu = ' || REPLACE(REPLACE(TO_CHAR(rw_principal.vldevatu),'.',','),',','.') ||
               ' , vlsdeved = ' || REPLACE(REPLACE(TO_CHAR(rw_principal.vlsdeved),'.',','),',','.') || 
               ' WHERE nrproposta = ''' || rw_principal.nrproposta ||''';';
   
   CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
      
   UPDATE cecred.crawseg w 
      SET w.vlpremio = rw_tbseg_prestamista.vlprodut, 
          w.vlseguro = rw_saldodev.saldo
    WHERE cdcooper = rw_principal.cdcooper 
      AND nrdconta = rw_principal.nrdconta 
      AND nrctrseg = rw_principal.nrctrseg
      AND tpseguro = 4; 
      
   UPDATE cecred.crapseg s 
      SET s.vlpremio = rw_tbseg_prestamista.vlprodut, 
          s.vlslddev = rw_saldodev.saldo 
    WHERE cdcooper = rw_principal.cdcooper 
      AND nrdconta = rw_principal.nrdconta 
      AND nrctrseg = rw_principal.nrctrseg
      AND tpseguro = 4;   
   
   UPDATE cecred.tbseg_prestamista t 
      SET t.vlprodut = rw_tbseg_prestamista.vlprodut, 
          t.vldevatu = rw_saldo_emp.saldo, 
          t.vlsdeved = rw_saldodev.saldo
    WHERE nrproposta = rw_principal.nrproposta;     
      
   COMMIT;
       
 END LOOP;
 
 CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
 CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
 CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
 CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq ); 
  
end;
