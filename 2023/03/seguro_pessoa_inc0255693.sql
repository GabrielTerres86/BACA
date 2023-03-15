DECLARE
  pr_cdcooper            CECRED.crapcop.cdcooper%TYPE := 1;
  vr_exc_saida           EXCEPTION;
  vr_cdprogra            CONSTANT CECRED.crapprg.cdprogra%TYPE := 'JB_ARQPRST';
  vr_idprglog            CECRED.tbgen_prglog.idprglog%TYPE := 0;
  vr_cdcritic            PLS_INTEGER;
  vr_dscritic            VARCHAR2(20000);
  vr_exc_erro            EXCEPTION;
  vr_vlenviad            NUMBER;
  vr_dsdemail            VARCHAR2(200); 
  vr_destinatario_email  VARCHAR2(500);       
  vr_nrsequen            NUMBER(5);
  vr_seqtran             INTEGER;
  vr_vlsdatua            NUMBER;
  vr_vlsdeved            NUMBER := 0;
  vr_tpregist            INTEGER;
  vr_nrproposta          CECRED.tbseg_prestamista.NRPROPOSTA%TYPE;
  vr_nrproposta_ant      CECRED.tbseg_prestamista.NRPROPOSTA%TYPE;
  vr_cdapolic            CECRED.tbseg_prestamista.cdapolic%TYPE;
  vr_dtdevend            CECRED.tbseg_prestamista.dtdevend%TYPE;
  vr_dtinivig            CECRED.tbseg_prestamista.dtinivig%TYPE;
  vr_flgnvenv            BOOLEAN;
  vr_nmsegura            VARCHAR2(200);
  vr_nmdir               VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0255693';
  vr_nmarq               VARCHAR2(100)  := 'ROLLBACK_INC0255693.sql';
  vr_ind_arq             utl_file.file_type;
  vr_linha               VARCHAR2(32767);
  vr_dtrefere            DATE;

  vr_nmrescop            CECRED.crapcop.nmrescop%TYPE;
  vr_apolice             VARCHAR2(20);
  vr_nmarquiv            VARCHAR2(100);
  vr_linha_txt           VARCHAR2(32600);
  vr_ultimoDia           DATE;
  vr_pgtosegu            NUMBER;
  vr_vlprodvl            NUMBER;
  vr_dtfimvig            DATE;
   
  vr_ind_arquivo utl_file.file_type;
  
  TYPE pl_tipo_registros IS RECORD (tpregist VARCHAR2(20));

  TYPE typ_registros IS TABLE OF pl_tipo_registros INDEX BY PLS_INTEGER;

  vr_tipo_registro typ_registros;
       
  CURSOR cr_crapcop(pr_cdcooper in crapcop.cdcooper%type) IS
    SELECT c.cdcooper
          ,c.dsdircop
          ,c.nmrescop
          ,(SELECT dat.dtmvtolt
              FROM CECRED.crapdat dat 
              WHERE dat.cdcooper = c.cdcooper) dtmvtolt         
      FROM CECRED.crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_crapris(pr_cdcooper IN CECRED.crapris.cdcooper%TYPE,
                    pr_nrdconta IN CECRED.crapris.nrdconta%TYPE,
                    pr_nrctremp IN CECRED.crapris.nrctremp%TYPE,
                    pr_dtrefere IN CECRED.crapris.dtrefere%TYPE) IS
    SELECT j.vldivida
      FROM CECRED.crapris j 
     WHERE j.cdcooper = pr_cdcooper 
       AND j.nrdconta = pr_nrdconta 
       AND j.nrctremp = pr_nrctremp
       AND j.dtrefere = pr_dtrefere;

  CURSOR cr_prestamista(pr_cdcooper IN CECRED.crapcop.cdcooper%TYPE) IS
    SELECT p.idseqtra
          ,p.cdcooper
          ,p.nrdconta
          ,ass.cdagenci
          ,p.nrctrseg
          ,p.tpregist
          ,p.cdapolic
          ,p.nrcpfcgc
          ,p.nmprimtl
          ,p.dtnasctl
          ,p.cdsexotl
          ,p.dsendres
          ,p.dsdemail
          ,p.nmbairro
          ,p.nmcidade
          ,p.cdufresd
          ,p.nrcepend
          ,p.nrtelefo
          ,p.dtdevend
          ,p.dtinivig
          ,p.nrctremp
          ,p.cdcobran
          ,p.cdadmcob
          ,p.tpfrecob
          ,p.tpsegura
          ,p.cdplapro
          ,p.vlprodut
          ,p.tpcobran
          ,p.vlsdeved
          ,p.vldevatu
          ,p.dtfimvig
          ,c.inliquid
          ,c.dtmvtolt data_emp
          ,p.nrproposta
          ,lpad(decode(p.cdcooper , 5,1, 7,2, 10,3,  11,4, 14,5, 9,6, 16,7, 2,8, 8,9, 6,10, 12,11, 13,12, 1,13  )   ,6,'0') cdcooperativa
          ,p.vldevatu saldo_cpf
          ,ADD_MONTHS(c.dtmvtolt, c.qtpreemp)  dtfimctr
          ,s.cdsitseg
          ,p.dtdenvio
          ,s.dtcancel
          ,p.dtrefcob
      FROM CECRED.tbseg_prestamista p, CECRED.crapepr c, CECRED.crapass ass, CECRED.crapseg s
     WHERE p.cdcooper = pr_cdcooper
       AND c.cdcooper = p.cdcooper
       AND c.nrdconta = p.nrdconta
       AND c.nrctremp = p.nrctremp
       AND ass.cdcooper = c.cdcooper
       AND ass.nrdconta = c.nrdconta
       AND p.cdcooper = s.cdcooper
       AND p.nrdconta = s.nrdconta
       AND p.nrctrseg = s.nrctrseg
       AND p.nrproposta IN ('770350614753','770350561927')
       AND p.tpcustei = 1
     ORDER BY p.nrcpfcgc ASC , p.dtinivig, p.nrctremp;
  rw_prestamista cr_prestamista%ROWTYPE;
        
  CURSOR cr_seg_parametro_prst(pr_cdcooper IN CECRED.tbseg_prestamista.cdcooper%TYPE
                              ,pr_tpcustei IN CECRED.tbseg_parametros_prst.tpcustei%TYPE) IS
    SELECT pp.idseqpar,
           pp.tppessoa,
           pp.cdsegura,
           pp.tpcustei,
           pp.nrapolic,
           pp.pagsegu,
           pp.seqarqu,
           pp.enderftp,
           pp.loginftp,
           pp.senhaftp
      FROM CECRED.tbseg_parametros_prst pp
     WHERE pp.cdcooper = pr_cdcooper
       AND pp.tppessoa = 1
       AND pp.cdsegura = CECRED.SEGU0001.busca_seguradora
       AND pp.tpcustei = pr_tpcustei;
  rw_seg_parametro_prst cr_seg_parametro_prst%ROWTYPE;
  
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
        vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                       vr_des_saida;
        RAISE vr_exc_erro;
      END IF;

      CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                           pr_nmdireto ||
                                                           ' 1> /dev/null',
                                  pr_typ_saida   => vr_typ_saida,
                                  pr_des_saida   => vr_des_saida);

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
       
  BEGIN
    pc_valida_direto(pr_nmdireto => vr_nmdir,
                     pr_dscritic => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                   ,pr_nmarquiv => vr_nmarq
                                   ,pr_tipabert => 'W'
                                   ,pr_utlfileh => vr_ind_arq
                                   ,pr_des_erro => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
       vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq;
       RAISE vr_exc_saida;
    END IF;

    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

    vr_destinatario_email := gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_EMAIL');   
   
    IF cr_crapcop%ISOPEN THEN
      CLOSE cr_crapcop;
    END IF;
 
    SELECT nmsegura INTO vr_nmsegura FROM CECRED.crapcsg WHERE cdcooper = pr_cdcooper AND cdsegura = 514; 
  
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop; 

    
    vr_tipo_registro(0).tpregist := 'NOT FOUND';
    vr_tipo_registro(1).tpregist := 'ADESAO';
    vr_tipo_registro(2).tpregist := 'CANCELAMENTO';
    vr_tipo_registro(3).tpregist := 'ENDOSSO'; 
  
    cecred.pc_log_programa(pr_dstiplog   => 'I',
                           pr_cdprograma => vr_cdprogra,
                           pr_cdcooper   => pr_cdcooper,
                           pr_tpexecucao => 2,
                           pr_idprglog   => vr_idprglog);
    vr_seqtran := 1;
    
    SELECT nmrescop
      INTO vr_nmrescop
      FROM CECRED.crapcop
     WHERE cdcooper = pr_cdcooper;
    
    OPEN cr_seg_parametro_prst(pr_cdcooper => pr_cdcooper,
                               pr_tpcustei => 1);
      FETCH cr_seg_parametro_prst INTO rw_seg_parametro_prst;        
      IF cr_seg_parametro_prst%NOTFOUND THEN
        CLOSE cr_seg_parametro_prst;
        vr_dscritic := 'Nao foi possivel localizar taxa de pagamento da seguradora. PC_PARAMETROS_PRST';          
        RAISE vr_exc_saida;
      END IF;           
    CLOSE cr_seg_parametro_prst;
    
    IF vr_dscritic IS NOT NULL THEN            
      RAISE vr_exc_saida;
    END IF;
      
    vr_nrsequen := rw_seg_parametro_prst.seqarqu+ 1;

    vr_apolice  := rw_seg_parametro_prst.nrapolic;
      
    vr_pgtosegu := rw_seg_parametro_prst.pagsegu;
    
    vr_linha :=    ' UPDATE CECRED.tbseg_parametros_prst p   '
                || '    SET p.seqarqu = ''' || rw_seg_parametro_prst.seqarqu || ''''
                || '  WHERE p.idseqpar = ' || rw_seg_parametro_prst.idseqpar ||';';
    
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha); 
      
    BEGIN
      UPDATE CECRED.tbseg_parametros_prst p
         SET p.seqarqu = vr_nrsequen
       WHERE p.idseqpar = rw_seg_parametro_prst.idseqpar;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar sequencia da cooperativa: ' || pr_cdcooper || ' - ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
    
    vr_ultimoDia := trunc(sysdate,'MONTH')-1;
                                         
    vr_nmarquiv := 'AILOS_'||REPLACE(vr_nmrescop,' ','_')||'_'
                 ||REPLACE(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '_') || '_' ||
                   CECRED.gene0002.fn_mask(vr_nrsequen, '99999') || '.txt';                                             
    
    CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                   ,pr_nmarquiv => vr_nmarquiv                  
                                   ,pr_tipabert => 'W'                          
                                   ,pr_utlfileh => vr_ind_arquivo               
                                   ,pr_des_erro => vr_dscritic); 
                                           
    IF vr_dscritic IS NOT NULL THEN         
      RAISE vr_exc_erro;
    END IF;
    
    cecred.pc_log_programa(pr_dstiplog           => 'O',
                           pr_cdprograma         => vr_cdprogra,
                           pr_cdcooper           => pr_cdcooper,
                           pr_tpexecucao         => 2,
                           pr_tpocorrencia       => 0,
                           pr_cdcriticidade      => 2,
                           pr_dsmensagem         => 'Começo loop CR_PRESTAMISTA',
                           pr_flgsucesso         => 0,
                           pr_nmarqlog           => NULL,
                           pr_destinatario_email => NULL,
                           pr_idprglog           => vr_idprglog);

    FOR rw_prestamista IN cr_prestamista(pr_cdcooper => pr_cdcooper) LOOP
                                         
     IF rw_prestamista.nrproposta = '770350561927' THEN
       vr_dtrefere  := TO_DATE('31/01/2023','DD/MM/RRRR');
       vr_ultimoDia := TO_DATE('31/01/2023','DD/MM/RRRR');
     ELSE
       vr_dtrefere := TO_DATE('28/02/2023','DD/MM/RRRR');
     END IF; 
     
     OPEN cr_crapris(pr_cdcooper => rw_prestamista.cdcooper,
                     pr_nrdconta => rw_prestamista.nrdconta,
                     pr_nrctremp => rw_prestamista.nrctremp,
                     pr_dtrefere => vr_dtrefere);
        FETCH cr_crapris INTO vr_vlsdeved;
     CLOSE cr_crapris;
     
     IF vr_vlsdeved IS NULL THEN
       vr_vlsdeved   := rw_prestamista.saldo_cpf;
       vr_vlsdatua   := rw_prestamista.vldevatu;
     ELSE
       vr_vlsdatua := vr_vlsdeved;
     END IF;
     
      vr_tpregist   := rw_prestamista.tpregist;  
      vr_cdapolic   := rw_prestamista.cdapolic;
      vr_nrproposta_ant := nvl(rw_prestamista.nrproposta,'0');
      vr_nrproposta := CECRED.SEGU0003.FN_NRPROPOSTA(pr_tpcustei => 1);
      vr_dtdevend   := rw_prestamista.dtdevend;
      vr_dtinivig   := rw_prestamista.dtinivig;
      vr_dtfimvig   := rw_prestamista.dtfimvig;
      vr_flgnvenv   := FALSE;         
      
      if rw_prestamista.dtfimvig is null then
        vr_dtfimvig := rw_prestamista.dtfimctr;
      end if;                           
      
      vr_vlprodvl := vr_vlenviad * (vr_pgtosegu/100);
      
      if vr_vlprodvl < 0.01 then
        vr_vlprodvl:= 0.01;
      end if;  
      
      if vr_vlenviad < 0.01 then
        vr_vlenviad:= 0.01;
      end if;
      
      vr_linha_txt := '';
      vr_linha_txt := vr_linha_txt || LPAD(vr_seqtran, 5, 0); 
      vr_linha_txt := vr_linha_txt || LPAD(vr_tpregist, 2, 0);
      vr_linha_txt := vr_linha_txt || LPAD(vr_apolice, 15, 0);
      vr_linha_txt := vr_linha_txt || RPAD(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'), 14, ' '); 
      vr_linha_txt := vr_linha_txt || LPAD(' ', 20, ' ');
      vr_linha_txt := vr_linha_txt ||
                      RPAD(UPPER(gene0007.fn_caract_especial(rw_prestamista.nmprimtl)), 70, ' '); 
      vr_linha_txt := vr_linha_txt ||
                      LPAD(to_char(rw_prestamista.dtnasctl, 'YYYY-MM-DD'), 10, 0);
      vr_linha_txt := vr_linha_txt || LPAD(rw_prestamista.cdsexotl, 2, 0);
      vr_linha_txt := vr_linha_txt ||
                      RPAD(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.dsendres,' '))), 60, ' '); 
      vr_linha_txt := vr_linha_txt ||
                      RPAD(UPPER(gene0007.fn_caract_especial(nvl(substr(rw_prestamista.nmbairro,0,30),' '))), 30, ' '); 
      vr_linha_txt := vr_linha_txt ||
                      RPAD(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.nmcidade,' '))), 30, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.cdufresd), ' '),2,' '); 
      vr_linha_txt := vr_linha_txt || RPAD(CECRED.gene0002.fn_mask(rw_prestamista.nrcepend, 'zzzzz-zz9'), 10, ' '); 
      
      IF length(rw_prestamista.nrtelefo) = 11 THEN
        vr_linha_txt := vr_linha_txt || RPAD(CECRED.gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)99999-9999'), 15, ' '); 
      ELSIF length(rw_prestamista.nrtelefo) = 10 THEN
        vr_linha_txt := vr_linha_txt || RPAD(CECRED.gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)9999-9999'), 15, ' '); 
      ELSE
        vr_linha_txt := vr_linha_txt || RPAD(CECRED.gene0002.fn_mask(rw_prestamista.nrtelefo, '99999-9999'), 15, ' '); 
      END IF;
      
      vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); 
      
      vr_dsdemail := rw_prestamista.dsdemail;
      CECRED.SEGU0003.pc_limpa_email(vr_dsdemail);
      
      vr_linha_txt := vr_linha_txt || RPAD(' ', 1, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(nvl(vr_dsdemail, ' '), 50, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(' ', 12, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD( vr_nrproposta, 30, ' '); 
      vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_dtdevend, 'YYYY-MM-DD'), 10, 0); 
      vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_dtinivig, 'YYYY-MM-DD'), 10, 0); 
      vr_linha_txt := vr_linha_txt || LPAD(' ', 2, ' '); 
                                                      
      vr_linha_txt := vr_linha_txt || LPAD(nvl(to_char(rw_prestamista.nrctremp), 0), 10, 0);
      
      vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); 
      vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); 
      vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); 
      vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); 
      
      vr_linha_txt := vr_linha_txt || RPAD(LPAD(rw_prestamista.cdcooper, 4, 0), 50, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
      vr_linha_txt := vr_linha_txt || nvl(to_char(rw_prestamista.cdcobran), ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.cdadmcob), ' '), 3, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(' ', 2, ' ');  
      vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(' ', 5, ' ');  
      vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.tpfrecob), ' '), 2, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.tpsegura), ' '), 2, ' '); 
      vr_linha_txt := vr_linha_txt || nvl(to_char(rw_prestamista.cdcooperativa), ' '); 
      vr_linha_txt := vr_linha_txt || nvl(to_char(rw_prestamista.cdplapro), ' ');
      
      vr_linha_txt := vr_linha_txt || LPAD(replace(to_char(vr_vlprodvl,'fm99999990d00'), ',', '.'), 12, 0); 
      vr_linha_txt := vr_linha_txt || LPAD(nvl(to_char(rw_prestamista.tpcobran), ' '), 1, ' '); 
      vr_linha_txt := vr_linha_txt || LPAD(replace(to_char(vr_vlenviad,'fm999999999999990d00'), ',', '.'), 30, 0); 
      vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_ultimoDia, 'YYYY-MM-DD'), 10, 0); 
      vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_dtfimvig, 'YYYY-MM-DD'), 10, 0); 
      
      vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 89, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 15, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' '); 
      vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' ');
      vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' ');
      vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' '); 
      
      vr_linha_txt := vr_linha_txt || chr(13);
      
      cecred.pc_log_programa(pr_dstiplog           => 'O',
                             pr_cdprograma         => vr_cdprogra,
                             pr_cdcooper           => pr_cdcooper,
                             pr_tpexecucao         => 2,
                             pr_tpocorrencia       => 0,
                             pr_cdcriticidade      => 2,
                             pr_dsmensagem         => LPAD(vr_seqtran,10,0) || ' Inserido arquivo, Conta: ' || rw_prestamista.nrdconta || ' nrctrseg: ' || rw_prestamista.nrctrseg || 
                                                                ' nrproposta: ' || vr_nrproposta,
                             pr_flgsucesso         => 0,
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => NULL,
                             pr_idprglog           => vr_idprglog);     
      
      vr_linha :=    ' UPDATE CECRED.crawseg p   '
                  || '    SET p.nrproposta = ''' || vr_nrproposta_ant || ''''
                  || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                  || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                  || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg ||';';
        
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
        
      vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                  || '    SET p.nrproposta = ''' || vr_nrproposta_ant || ''''
                  || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                  || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                  || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                  || '    AND p.nrctremp = ' || rw_prestamista.nrctremp
                  || '    AND p.cdapolic = ' || vr_cdapolic ||';';
        
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
      
      BEGIN
        UPDATE CECRED.crawseg c
           SET c.nrproposta = vr_nrproposta
         WHERE c.cdcooper = rw_prestamista.cdcooper
           AND c.nrdconta = rw_prestamista.nrdconta
           AND c.nrctrseg = rw_prestamista.nrctrseg;
             
        UPDATE CECRED.tbseg_prestamista
           SET nrproposta = vr_nrproposta
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = rw_prestamista.nrdconta
           AND nrctrseg = rw_prestamista.nrctrseg
           AND nrctremp = rw_prestamista.nrctremp
           AND cdapolic = vr_cdapolic;                 
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao cancelar seguro prestamista: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    
      CECRED.gene0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);
    
      vr_seqtran := vr_seqtran + 1;         
    END LOOP;
    
    vr_seqtran := vr_seqtran - 1;
    
    cecred.pc_log_programa(pr_dstiplog           => 'O',
                           pr_cdprograma         => vr_cdprogra,
                           pr_cdcooper           => pr_cdcooper,
                           pr_tpexecucao         => 2,
                           pr_tpocorrencia       => 0,
                           pr_cdcriticidade      => 2,
                           pr_dsmensagem         => 'Fim loop CR_PRESTAMISTA, total: ' || vr_seqtran,
                           pr_flgsucesso         => 0,
                           pr_nmarqlog           => NULL,
                           pr_destinatario_email => NULL,
                           pr_idprglog           => vr_idprglog);                           
    
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);
    
    cecred.pc_log_programa(pr_dstiplog           => 'O',
                           pr_cdprograma         => vr_cdprogra,
                           pr_cdcooper           => pr_cdcooper,
                           pr_tpexecucao         => 2,
                           pr_tpocorrencia       => 0,
                           pr_cdcriticidade      => 2,
                           pr_dsmensagem         => '01 Começo converte arquivo',
                           pr_flgsucesso         => 0,
                           pr_nmarqlog           => NULL,
                           pr_destinatario_email => NULL,
                           pr_idprglog           => vr_idprglog);

    CECRED.gene0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper                        
                                       ,pr_nmarquiv => vr_nmdir || vr_nmarquiv
                                       ,pr_nmarqenv => vr_nmarquiv                        
                                       ,pr_des_erro => vr_dscritic);
                                       
    cecred.pc_log_programa(pr_dstiplog           => 'O',
                           pr_cdprograma         => vr_cdprogra,
                           pr_cdcooper           => pr_cdcooper,
                           pr_tpexecucao         => 2,
                           pr_tpocorrencia       => 0,
                           pr_cdcriticidade      => 2,
                           pr_dsmensagem         => '02 Fim converte arquivo, vr_dscritic: ' || vr_dscritic,
                           pr_flgsucesso         => 0,
                           pr_nmarqlog           => NULL,
                           pr_destinatario_email => NULL,
                           pr_idprglog           => vr_idprglog);                     

    IF vr_dscritic IS NOT NULL THEN             
      RAISE vr_exc_erro;               
    END IF;    
    
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
    CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
    
    cecred.pc_log_programa(pr_dstiplog           => 'O',
                           pr_cdprograma         => vr_cdprogra,
                           pr_cdcooper           => pr_cdcooper,
                           pr_tpexecucao         => 2,
                           pr_tpocorrencia       => 0,
                           pr_cdcriticidade      => 2,
                           pr_dsmensagem         => 'Conclusao e commit',
                           pr_flgsucesso         => 0,
                           pr_nmarqlog           => NULL,
                           pr_destinatario_email => NULL,
                           pr_idprglog           => vr_idprglog);
                           
    COMMIT;                           
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := CECRED.gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
    
      vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      ROLLBACK;
      cecred.pc_log_programa(pr_dstiplog           => 'E',         
                             pr_cdprograma         => vr_cdprogra, 
                             pr_cdcooper           => pr_cdcooper, 
                             pr_tpexecucao         => 2,           
                             pr_tpocorrencia       => 0,           
                             pr_cdcriticidade      => 2,           
                             pr_dsmensagem         => vr_dscritic, 
                             pr_flgsucesso         => 0,           
                             pr_nmarqlog           => NULL,
                             pr_idprglog           => vr_idprglog);

      CECRED.gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                        pr_des_destino => vr_destinatario_email,
                                        pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                        pr_des_corpo   => vr_dscritic,
                                        pr_des_anexo   => NULL,
                                        pr_flg_enviar  => 'S',
                                        pr_des_erro    => vr_dscritic); 
    WHEN OTHERS THEN
      vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
      vr_dscritic := vr_dscritic;
      ROLLBACK;
      cecred.pc_log_programa(pr_dstiplog           => 'E',         
                             pr_cdprograma         => vr_cdprogra, 
                             pr_cdcooper           => pr_cdcooper, 
                             pr_tpexecucao         => 2,           
                             pr_tpocorrencia       => 0,           
                             pr_cdcriticidade      => 2,           
                             pr_dsmensagem         => vr_dscritic, 
                             pr_flgsucesso         => 0,           
                             pr_nmarqlog           => NULL,
                             pr_destinatario_email => vr_destinatario_email,
                             pr_idprglog           => vr_idprglog);
      
      CECRED.gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                        pr_des_destino => vr_destinatario_email,
                                        pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                        pr_des_corpo   => vr_dscritic,
                                        pr_des_anexo   => NULL,
                                        pr_flg_enviar  => 'S',
                                        pr_des_erro    => vr_dscritic); 

  END;
/
