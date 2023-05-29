      DECLARE
        vr_cdcritic   PLS_INTEGER;
        vr_dscritic   VARCHAR2(4000);
        vr_exc_erro   EXCEPTION;
        vr_exc_saida  EXCEPTION;
        vr_tipo_saida VARCHAR2(100);
        
        vr_nrsequen  NUMBER(5);
        vr_endereco  VARCHAR2(100);    
        vr_login     VARCHAR2(100);
        vr_senha     VARCHAR2(100);
        vr_seqtran   INTEGER;
        vr_vlsdatua  NUMBER;
        vr_vlminimo  NUMBER;
        vr_vlsdeved  NUMBER := 0;
        vr_vlenviad  NUMBER;
        vr_tpregist  INTEGER;
        vr_NRPROPOSTA cecred.tbseg_prestamista.NRPROPOSTA%TYPE;
        vr_cdapolic  cecred.tbseg_prestamista.cdapolic%TYPE;
        vr_cdapolic_canc  cecred.tbseg_prestamista.cdapolic%TYPE;
        vr_dtdevend  cecred.tbseg_prestamista.dtdevend%TYPE;
        vr_dtinivig  cecred.tbseg_prestamista.dtinivig%TYPE;
        vr_flgnvenv  BOOLEAN;
        vr_contrcpf cecred.tbseg_prestamista.nrcpfcgc%TYPE;

        vr_vltotenv NUMBER;
        vr_vlmaximo NUMBER;
        vr_dscorpem VARCHAR2(2000);
        vr_cdprogra CONSTANT cecred.crapprg.cdprogra%TYPE := 'JB_ARQPRST';
        vr_destinatario_email  VARCHAR2(500);
        vr_nmrescop cecred.crapcop.nmrescop%TYPE;
        vr_cdcooper cecred.crapcop.cdcooper%TYPE;
        vr_dtmvtolt cecred.crapdat.dtmvtolt%type;
        vr_apolice  VARCHAR2(20);
        vr_nmdircop  VARCHAR2(100);
        vr_nmarquiv  VARCHAR2(100);
        vr_linha_txt VARCHAR2(32600);
        vr_dsdemail  VARCHAR2(100);
        vr_ultimoDia DATE;
        vr_pgtosegu  NUMBER;
        vr_vlprodvl  NUMBER;
        vr_dtfimvig  DATE;
        vr_dtcalcidade DATE; 
        vr_regras_segpre VARCHAR2(1);
        vr_dstextab  cecred.craptab.dstextab%TYPE; 
        
        vr_nrdeanos     PLS_INTEGER;
        vr_tab_nrdeanos PLS_INTEGER;
        vr_nrdmeses     PLS_INTEGER;
        vr_dsdidade     VARCHAR2(50);
        
        vr_index         VARCHAR2(50);
        
        vr_nmdir  VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0270109';
        vr_nmarq  VARCHAR2(100)  := 'ROLLBACK_INC0270109_arq_fat_maio.sql';
        vr_ind_arq utl_file.file_type;
        vr_linha   VARCHAR2(32767);
           
        TYPE typ_reg_record IS RECORD (cdcooper cecred.tbseg_prestamista.cdcooper%TYPE
                                      ,nrdconta cecred.tbseg_prestamista.nrdconta%TYPE
                                      ,cdagenci cecred.crapass.cdagenci%TYPE
                                      ,dtmvtolt cecred.crapdat.dtmvtolt%TYPE
                                      ,dtinivig cecred.crapdat.dtmvtolt%TYPE
                                      ,dtrefcob cecred.crapdat.dtmvtolt%TYPE
                                      ,nmrescop cecred.crapcop.nmrescop%TYPE
                                      ,vlenviad NUMBER(25,2)
                                      ,dsregist VARCHAR2(20)
                                      ,inpessoa PLS_INTEGER
                                      ,tpregist cecred.tbseg_prestamista.tpregist%TYPE
                                      ,nmprimtl cecred.tbseg_prestamista.nmprimtl%TYPE
                                      ,nrcpfcgc cecred.tbseg_prestamista.nrcpfcgc%TYPE
                                      ,nrctrseg VARCHAR2(15)
                                      ,nrctremp cecred.tbseg_prestamista.nrctremp%TYPE
                                      ,vlprodut cecred.tbseg_prestamista.vlprodut%TYPE
                                      ,vlsdeved cecred.tbseg_prestamista.vlsdeved%TYPE
                                      ,insitlau VARCHAR2(20)
                                      ,dspessoa VARCHAR(20)
                                      ,vlpreemp cecred.crapepr.vlpreemp%TYPE
                                      ,nmsegura cecred.crapcsg.nmsegura%TYPE);

        vr_index_815     PLS_INTEGER := 0;
        TYPE typ_tab IS TABLE OF typ_reg_record INDEX BY VARCHAR2(30);
        vr_tab_crrl815   typ_tab;
        vr_crrl815     typ_tab;

        TYPE pl_tipo_registros IS RECORD (tpregist VARCHAR2(20));
        TYPE typ_registros IS TABLE OF pl_tipo_registros INDEX BY PLS_INTEGER;
        vr_tipo_registro typ_registros;
        
        TYPE typ_reg_ctrl_prst IS RECORD(nrcpfcgc cecred.tbseg_prestamista.nrcpfcgc%TYPE,
                                         nrctremp cecred.tbseg_prestamista.nrctremp%TYPE);  

        TYPE typ_tab_ctrl_prst IS TABLE OF typ_reg_ctrl_prst INDEX BY VARCHAR2(40);
        vr_tab_ctrl_prst typ_tab_ctrl_prst ;
        
        vr_ind_arquivo utl_file.file_type;
        vr_interacao  NUMBER;
        
        CURSOR cr_craptsg(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE) IS
          SELECT nrtabela
            FROM cecred.craptsg
           WHERE cdcooper = pr_cdcooper
             AND tpseguro = 4
             AND tpplaseg = 1
             AND cdsegura = cecred.SEGU0001.busca_seguradora;
    
        CURSOR cr_prestamista(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE,
                              pr_vlminimo IN NUMBER,
                              pr_idadelim IN NUMBER,
                              pr_dtmvtolt IN DATE) IS
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
                ,SUM (
                   CASE 
                     WHEN (TRUNC(p.dtinivig) >= TRUNC(SYSDATE) AND p.tpregist = 1) THEN
                       0
                     WHEN (p.vlsdeved >= pr_vlminimo AND p.tpregist = 2 AND p.vldevatu > 0 AND
                          (TRUNC(Months_Between(pr_dtmvtolt,p.dtnasctl) /12,0) > pr_idadelim OR 
                           TRUNC(Months_Between(pr_dtmvtolt,p.dtnasctl) /12,0) < 14))THEN
                       0
                     WHEN (p.idseqtra <> (SELECT MAX(t.idseqtra) 
                                            FROM cecred.tbseg_prestamista t
                                           WHERE t.cdcooper = p.cdcooper
                                             AND t.nrdconta = p.nrdconta
                                             AND t.nrctremp = p.nrctremp
                                             AND TRUNC(t.dtinivig) < TRUNC(SYSDATE)
                                             AND t.tpregist <> 0
                                             AND t.tpcustei = 1)) THEN
                       0  
                     ELSE                
                       p.vldevatu                       
                     END) over(partition by  p.cdcooper, p.nrcpfcgc ) saldo_cpf             
                
                ,ADD_MONTHS(c.dtmvtolt, c.qtpreemp)  dtfimctr
                ,s.cdsitseg
                ,p.dtdenvio
                ,s.dtcancel
                ,p.dtrefcob
            FROM cecred.tbseg_prestamista p, cecred.crapepr c, cecred.crapass ass, cecred.crapseg s
           WHERE p.cdcooper = pr_cdcooper    
             AND c.cdcooper = p.cdcooper
             AND c.nrdconta = p.nrdconta
             AND c.nrctremp = p.nrctremp             
             AND ass.cdcooper = c.cdcooper
             AND ass.nrdconta = c.nrdconta
             AND p.cdcooper = s.cdcooper
             AND p.nrdconta = s.nrdconta
             AND p.nrctrseg = s.nrctrseg
             AND TRUNC(p.dtinivig) < TRUNC(SYSDATE)
             AND p.tpcustei = 1 
             AND c.inliquid = 1
             AND c.vlsdeved = 0
             AND p.nrdconta = 210609
             AND p.nrctremp = 43291 
             ORDER BY p.cdcooper, p.nrdconta, p.dtinivig, p.nrctremp;
        rw_prestamista cr_prestamista%ROWTYPE;
        
        CURSOR cr_seg_parametro_prst(pr_cdcooper IN cecred.tbseg_prestamista.cdcooper%TYPE
                                    ,pr_tpcustei IN cecred.tbseg_parametros_prst.tpcustei%TYPE) IS
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
            FROM cecred.tbseg_parametros_prst pp
           WHERE pp.cdcooper = pr_cdcooper
             AND pp.tppessoa = 1 
             AND pp.cdsegura = segu0001.busca_seguradora
             AND pp.tpcustei = pr_tpcustei;
        rw_seg_parametro_prst cr_seg_parametro_prst%ROWTYPE;
        
        CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                         ,pr_nrdconta IN crawepr.nrdconta%TYPE
                         ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
          SELECT e.dtmvtolt,
                 (SELECT MAX(pe.dtvencto)
                    FROM cecred.crappep pe
                   WHERE e.cdcooper = pe.cdcooper
                     AND e.nrdconta = pe.nrdconta
                     AND e.nrctremp = pe.nrctremp) dtvencto
            FROM cecred.crawepr e
           WHERE e.cdcooper = pr_cdcooper
             AND e.nrdconta = pr_nrdconta
             AND e.nrctremp = pr_nrctremp
             AND e.flgreneg = 1;
        rw_crawepr cr_crawepr%ROWTYPE;
        
        CURSOR cr_nrproposta(pr_nrproposta cecred.tbseg_prestamista.nrproposta%TYPE) IS
          SELECT p.idseqtra
            FROM (SELECT p.nrproposta
                    FROM cecred.tbseg_prestamista p
                   GROUP BY p.nrproposta
                  HAVING COUNT(1) > 1) x,
                 cecred.tbseg_prestamista p
           WHERE x.nrproposta = p.nrproposta
             AND p.tpregist = 1
             AND p.nrproposta = pr_nrproposta;
        rw_nrproposta cr_nrproposta%ROWTYPE;
        
        CURSOR cr_crapcop IS
          SELECT c.cdcooper, c.nmrescop, d.dtmvtolt
            FROM cecred.crapcop c,
                 cecred.crapdat d
           WHERE c.flgativo = 1
             AND c.cdcooper = 13
             AND c.cdcooper = d.cdcooper
           ORDER BY cdcooper;
      
      PROCEDURE pc_replica_cancelado(pr_cdcooper   IN  cecred.tbseg_prestamista.cdcooper%TYPE
                                    ,pr_nrdconta   IN  cecred.tbseg_prestamista.nrdconta%TYPE
                                    ,pr_nrctremp   IN  cecred.tbseg_prestamista.nrctremp%TYPE
                                    ,pr_dtemprst   IN  cecred.tbseg_prestamista.dtdevend%TYPE
                                    ,pr_nrctrseg   IN  cecred.tbseg_prestamista.nrctrseg%TYPE                                  
                                    ,pr_cdapolic   OUT cecred.tbseg_prestamista.cdapolic%TYPE
                                    ,pr_nrproposta OUT cecred.tbseg_prestamista.nrproposta%TYPE
                                    ,pr_cdcritic   OUT cecred.crapcri.cdcritic%TYPE 
                                    ,pr_dscritic   OUT VARCHAR2) IS          
      
      CURSOR cr_prest(pr_cdcooper  IN cecred.tbseg_prestamista.cdcooper%TYPE
                     ,pr_nrdconta  IN cecred.tbseg_prestamista.nrdconta%TYPE
                     ,pr_nrctremp  IN cecred.tbseg_prestamista.nrctremp%TYPE
                     ,pr_nrctrseg  IN cecred.tbseg_prestamista.nrctrseg%TYPE) IS
        SELECT t.* 
          FROM cecred.tbseg_prestamista t,
               cecred.crapseg s 
         WHERE t.cdcooper = s.cdcooper
           AND t.nrdconta = s.nrdconta
           AND t.nrctrseg = s.nrctrseg
           AND t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.nrctremp = pr_nrctremp
           AND t.nrctrseg = pr_nrctrseg
           AND t.tpregist = 2
           AND s.cdsitseg IN (1,2)
           AND s.tpseguro = 4;
      rw_prest cr_prest%ROWTYPE;
            
      vr_dsdemail   VARCHAR2(100);
      VR_NRPROPOSTA VARCHAR2(15);
    BEGIN
    
        VR_NRPROPOSTA :=  cecred.SEGU0003.FN_NRPROPOSTA(1); 
      
        OPEN cr_prest(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_nrctrseg => pr_nrctrseg);
          FETCH cr_prest INTO rw_prest;
          IF cr_prest%FOUND THEN
            BEGIN 
              UPDATE cecred.tbseg_prestamista
                 SET tpregist = 1,
                     dtinivig = trunc(SYSDATE,'MONTH')-1,
                     nrproposta = VR_NRPROPOSTA 
               WHERE cdcooper = rw_prest.cdcooper
                 AND nrdconta = rw_prest.nrdconta
                 AND nrctremp = rw_prest.nrctremp
                 AND nrctrseg = rw_prest.nrctrseg;  
            
             UPDATE cecred.crawseg w
                SET w.nrproposta = VR_NRPROPOSTA
              WHERE w.cdcooper = rw_prest.cdcooper
                AND w.nrdconta = rw_prest.nrdconta
                AND decode(nvl(w.nrctrato,0),0,nvl(rw_prest.nrctremp,0),w.nrctrato) = nvl(rw_prest.nrctremp,0) 
                AND w.nrctrseg = rw_prest.nrctrseg;
            
            
            COMMIT;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic:= 'Erro ao atualizar tbseg_prestamista (replica_cancelado) ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
            pr_cdapolic := rw_prest.cdapolic;
            pr_nrproposta := VR_NRPROPOSTA; 
          END IF;
        CLOSE cr_prest;

        vr_dsdemail := rw_prest.dsdemail;
        cecred.SEGU0003.pc_limpa_email(vr_dsdemail);     
  
    EXCEPTION
        WHEN vr_exc_erro THEN
          pr_cdcritic:= nvl(vr_cdcritic,0);
          pr_dscritic:= vr_dscritic;          
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao criar certificado para reenvio de cancelado - Cooper:' || vr_cdcooper || ' - Conta: ' || rw_prest.nrdconta || ' - pc_replica_cancelado';
    END pc_replica_cancelado;
    
    FUNCTION fn_verifica_arq_disponivel_ftp(pr_caminho   IN VARCHAR2
                                           ,pr_interacao IN OUT NUMBER) RETURN BOOLEAN IS
    BEGIN
      pr_interacao := pr_interacao + 1;
      
      IF pr_interacao != 1 THEN
        DBMS_LOCK.SLEEP(10); 
      END IF;
      
      IF pr_interacao < 7 THEN
        IF cecred.GENE0001.fn_exis_arquivo(pr_caminho => pr_caminho) THEN 
          RETURN TRUE;
        ELSE
          RETURN fn_verifica_arq_disponivel_ftp(pr_caminho   => pr_caminho
                                               ,pr_interacao => pr_interacao);
        END IF;
      ELSE
        RETURN FALSE;  
      END IF;
    END fn_verifica_arq_disponivel_ftp;

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
      
    vr_seqtran := 1;
        
    FOR rw_crapcop IN cr_crapcop LOOP
      vr_nmrescop := rw_crapcop.nmrescop;
      vr_cdcooper := rw_crapcop.cdcooper;
      vr_dtmvtolt := rw_crapcop.dtmvtolt;
      
      vr_tipo_registro(0).tpregist := 'NOT FOUND';
      vr_tipo_registro(1).tpregist := 'ADESAO';
      vr_tipo_registro(2).tpregist := 'CANCELAMENTO';
      vr_tipo_registro(3).tpregist := 'ENDOSSO';

      IF NVL(vr_regras_segpre,'N') = 'S' THEN
        OPEN cr_seg_parametro_prst(pr_cdcooper => vr_cdcooper,
                                   pr_tpcustei => 1); 
          FETCH cr_seg_parametro_prst INTO rw_seg_parametro_prst;        
          IF cr_seg_parametro_prst%NOTFOUND THEN
            CLOSE cr_seg_parametro_prst;
            RAISE vr_exc_saida;
          END IF;           
        CLOSE cr_seg_parametro_prst;
           
        vr_vlminimo := cecred.segu0003.fn_capital_seguravel_min(pr_cdcooper => vr_cdcooper,
                                                                 pr_tppessoa => rw_seg_parametro_prst.tppessoa,
                                                                 pr_cdsegura => rw_seg_parametro_prst.cdsegura,
                                                                 pr_tpcustei => rw_seg_parametro_prst.tpcustei,
                                                                 pr_dtnasc   => TO_DATE('01/01/1990','DD/MM/RRRR'),
                                                                 pr_cdcritic => vr_cdcritic,
                                                                 pr_dscritic => vr_dscritic);

        vr_vlmaximo := cecred.segu0003.fn_capital_seguravel_max(pr_cdcooper => vr_cdcooper,
                                                               pr_tppessoa => rw_seg_parametro_prst.tppessoa,
                                                               pr_cdsegura => rw_seg_parametro_prst.cdsegura,
                                                               pr_tpcustei => rw_seg_parametro_prst.tpcustei,
                                                               pr_dtnasc   => TO_DATE('01/01/1990','DD/MM/RRRR'),
                                                               pr_cdcritic => vr_cdcritic,
                                                               pr_dscritic => vr_dscritic);
            
        IF vr_dscritic IS NOT NULL THEN            
          RAISE vr_exc_saida;
        END IF;
          
        vr_nrsequen := rw_seg_parametro_prst.seqarqu+ 1;

        vr_apolice  := rw_seg_parametro_prst.nrapolic;
          
        vr_pgtosegu := rw_seg_parametro_prst.pagsegu;
          
        vr_endereco := rw_seg_parametro_prst.enderftp;
        vr_login    := rw_seg_parametro_prst.loginftp;
        vr_senha    := rw_seg_parametro_prst.senhaftp;
        
        vr_linha    := ' UPDATE CECRED.tbseg_parametros_prst p '
                    || '    SET p.seqarqu = ''' || rw_seg_parametro_prst.seqarqu || ''''
                    || '  WHERE p.idseqpar = ' || rw_seg_parametro_prst.idseqpar ||';';

        CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
          
        BEGIN
          UPDATE cecred.tbseg_parametros_prst p
             SET p.seqarqu = vr_nrsequen
           WHERE p.idseqpar = rw_seg_parametro_prst.idseqpar;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar sequencia da cooperativa: ' || vr_cdcooper || ' - ' || SQLERRM;
            RAISE vr_exc_saida;
        END;   
      ELSE
          vr_dstextab := cecred.tabe0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                                         ,pr_nmsistem => 'CRED'
                                                         ,pr_tptabela => 'USUARI'
                                                         ,pr_cdempres => 11
                                                         ,pr_cdacesso => 'SEGPRESTAM'
                                                         ,pr_tpregist => 0);  
        
          IF vr_dstextab IS NULL THEN
            vr_vlminimo := 0;
          ELSE
            vr_vlminimo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 27, 12));
            vr_vlmaximo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));
          END IF;      
          
          vr_nrsequen := to_number(substr(vr_dstextab, 139, 5)) + 1;

          vr_apolice  := SUBSTR(vr_dstextab,146,16); 
          
          vr_pgtosegu := cecred.gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7));
          
          vr_endereco := cecred.gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                         pr_cdcooper => vr_cdcooper,
                                                         pr_cdacesso => 'PRST_FTP_ENDERECO');
          vr_login    := cecred.gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                         pr_cdcooper => vr_cdcooper,
                                                         pr_cdacesso => 'PRST_FTP_LOGIN');
          vr_senha    := cecred.gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                         pr_cdcooper => vr_cdcooper,
                                                         pr_cdacesso => 'PRST_FTP_SENHA');
          
          BEGIN
            UPDATE cecred.craptab
               SET cecred.craptab.dstextab = substr(craptab.dstextab, 1, 138) ||
                                      gene0002.fn_mask(vr_nrsequen, '99999') ||
                                      substr(cecred.craptab.dstextab, 144)
             WHERE cecred.craptab.cdcooper = vr_cdcooper
               AND cecred.craptab.nmsistem = 'CRED'
               AND cecred.craptab.tptabela = 'USUARI'
               AND cecred.craptab.cdempres = 11
               AND cecred.craptab.cdacesso = 'SEGPRESTAM'
               AND cecred.craptab.tpregist = 0;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar sequencia da cooperativa: ' || vr_cdcooper || ' - ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
                                                        
        vr_ultimoDia := add_months(trunc(sysdate,'MONTH')- 1,1);   
                
        vr_nmdircop := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                                    pr_cdcooper => vr_cdcooper);

        vr_nmarquiv := 'AILOS_'||replace(vr_nmrescop,' ','_')||'_'
                     ||REPLACE(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '_') || '_' ||
                       gene0002.fn_mask(vr_nrsequen, '99999') || '.txt';                                             
      
        cecred.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop || '/arq/'
                                      ,pr_nmarquiv => vr_nmarquiv           
                                      ,pr_tipabert => 'W'                   
                                      ,pr_utlfileh => vr_ind_arquivo        
                                      ,pr_des_erro => vr_dscritic);         
        IF vr_dscritic IS NOT NULL THEN         
          RAISE vr_exc_erro;      
        END IF;
      
        vr_contrcpf := NULL;
        
        OPEN cr_craptsg(pr_cdcooper => vr_cdcooper);
        FETCH cr_craptsg
         INTO vr_tab_nrdeanos;

        IF cr_craptsg%NOTFOUND THEN
          vr_tab_nrdeanos := 0;
        END IF;

        CLOSE cr_craptsg;

        FOR rw_prestamista IN cr_prestamista(pr_cdcooper => vr_cdcooper,
                                             pr_vlminimo => vr_vlminimo,
                                             pr_idadelim => vr_tab_nrdeanos,
                                             pr_dtmvtolt => TO_DATE(ADD_MONTHS(vr_ultimoDia,-1),'DD/MM/RRRR')) LOOP
          
          vr_vlsdeved := rw_prestamista.saldo_cpf;
          vr_vlsdatua := rw_prestamista.vldevatu;
          if rw_prestamista.tpregist = 0 then
             vr_tpregist := 2;
          else
            vr_tpregist := rw_prestamista.tpregist;
          end if;
          vr_cdapolic := rw_prestamista.cdapolic;
          vr_NRPROPOSTA := nvl(rw_prestamista.NRPROPOSTA,'0');
          vr_dtdevend := rw_prestamista.dtdevend;
          vr_dtinivig := rw_prestamista.dtinivig;
          vr_dtfimvig := rw_prestamista.dtfimvig;
          vr_flgnvenv := FALSE;         
          
          if rw_prestamista.dtfimvig is null then
            vr_dtfimvig := rw_prestamista.dtfimctr;
          end if;                           
                   
          if trunc(vr_dtinivig) >= trunc(sysdate) and vr_tpregist = 1 then                          
            continue;
          end if;
                    
          vr_dtcalcidade:= TO_DATE(ADD_MONTHS(vr_ultimoDia,-1),'DD/MM/RRRR');
          
          CADA0001.pc_busca_idade(pr_dtnasctl => rw_prestamista.dtnasctl 
                                 ,pr_dtmvtolt => vr_dtcalcidade          
                                 ,pr_flcomple => 1                   
                                 ,pr_nrdeanos => vr_nrdeanos         
                                 ,pr_nrdmeses => vr_nrdmeses         
                                 ,pr_dsdidade => vr_dsdidade         
                                 ,pr_des_erro => vr_dscritic);       
                    
          IF (vr_vlsdeved < vr_vlminimo AND vr_tpregist = 3) THEN 
            vr_tpregist := 2;
          ELSE 
            IF vr_vlsdeved >= vr_vlminimo AND vr_tpregist = 2 and vr_vlsdatua > 0 THEN            
              if vr_nrdeanos > vr_tab_nrdeanos or
                 vr_nrdeanos < 14 then             
                 if vr_nrdeanos > vr_tab_nrdeanos then
                    vr_tpregist:= 0; 
                   BEGIN         
                     
                     vr_linha := ' UPDATE CECRED.tbseg_prestamista p '
                              || '    SET p.tpregist = ' || rw_prestamista.tpregist 
                              || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                              || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                              || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                              || '    AND p.nrctremp = ' || rw_prestamista.nrctremp
                              || '    AND p.cdapolic = ' || vr_cdapolic ||';';

                      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
                          
                      UPDATE tbseg_prestamista
                         SET tpregist = vr_tpregist
                       WHERE cdcooper = vr_cdcooper
                         AND nrdconta = rw_prestamista.nrdconta
                         AND nrctrseg = rw_prestamista.nrctrseg
                         AND nrctremp = rw_prestamista.nrctremp
                         AND cdapolic = vr_cdapolic;
                         
                       COMMIT;  
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || vr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                        RAISE vr_exc_saida;
                    END;  
                 end if;
                 continue;
              end if;  
              pc_replica_cancelado(pr_cdcooper => vr_cdcooper,
                                   pr_nrdconta => rw_prestamista.nrdconta,
                                   pr_nrctremp => rw_prestamista.nrctremp,
                                   pr_dtemprst => rw_prestamista.data_emp, 
                                   pr_nrctrseg => rw_prestamista.nrctrseg,
                                   pr_cdapolic => vr_cdapolic_canc, 
                                   pr_nrproposta => vr_nrproposta,
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic);
              
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := vr_dscritic 
                               || ' Cooperativa: ' || vr_cdcooper 
                               || ' - Conta: ' || rw_prestamista.nrdconta 
                               || ' - Contrato Prestamista: ' || rw_prestamista.nrctrseg
                               || ' - Contrato Emprestimo: ' || rw_prestamista.nrctremp;
                RAISE vr_exc_saida;
              END IF;
              
              IF NVL(vr_nrproposta,'0') = '0' THEN
                vr_NRPROPOSTA := nvl(rw_prestamista.NRPROPOSTA,'0');
              END IF;
              
              vr_dtdevend := rw_prestamista.data_emp;
              vr_dtinivig := vr_ultimoDia; 
              
              vr_flgnvenv := TRUE;
            ELSIF vr_vlsdeved < vr_vlminimo AND vr_tpregist IN(2, 1) THEN

              IF vr_tpregist = 1 THEN
                BEGIN 
                  
                  vr_linha := ' UPDATE CECRED.tbseg_prestamista p '
                              || '    SET p.dtdenvio = TO_DATE(''' || rw_prestamista.dtdenvio || ''',''DD/MM/RRRR'')'
                              || '  WHERE p.cdcooper = ' || vr_cdcooper
                              || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                              || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                              || '    AND p.nrctremp = ' || rw_prestamista.nrctremp
                              || '    AND p.cdapolic = ' || vr_cdapolic ||';';

                  CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
                
                  UPDATE tbseg_prestamista
                     SET dtdenvio = vr_dtmvtolt
                   WHERE cdcooper = vr_cdcooper
                     AND nrdconta = rw_prestamista.nrdconta
                     AND nrctrseg = rw_prestamista.nrctrseg
                     AND nrctremp = rw_prestamista.nrctremp
                     AND cdapolic = vr_cdapolic;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || vr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;   
              END IF;
              
              CONTINUE;
            END IF;
          END IF;
          
          IF rw_prestamista.cdsitseg <> 2 THEN
            IF vr_tab_ctrl_prst.EXISTS(rw_prestamista.nrcpfcgc || rw_prestamista.nrctremp) THEN
              vr_tpregist:= 0; 
              BEGIN 
                
                vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p '
                            || '    SET p.tpregist = ' || rw_prestamista.tpregist 
                            || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                            || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                            || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                            || '    AND p.nrctremp = ' || rw_prestamista.nrctremp
                            || '    AND p.cdapolic = ' || vr_cdapolic ||';';

                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                vr_linha :=    ' UPDATE CECRED.crapseg p   '
                            || '    SET p.cdsitseg = ' || rw_prestamista.cdsitseg 
                            || '       ,p.dtcancel = TO_DATE(''' || rw_prestamista.dtcancel || ''',''DD/MM/RRRR'')'
                            || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                            || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                            || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                            || '    AND p.tpseguro = ' || 4 ||';';

                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
                             
                 UPDATE tbseg_prestamista
                    SET tpregist = vr_tpregist
                  WHERE cdcooper = vr_cdcooper
                    AND nrdconta = rw_prestamista.nrdconta
                    AND nrctrseg = rw_prestamista.nrctrseg
                    AND nrctremp = rw_prestamista.nrctremp
                    AND cdapolic = vr_cdapolic;                  
                    
                 UPDATE crapseg s
                   SET s.cdsitseg = 2,
                       s.dtcancel = vr_dtmvtolt
                 WHERE s.cdcooper = vr_cdcooper
                   AND s.nrdconta = rw_prestamista.nrdconta
                   AND s.nrctrseg = rw_prestamista.nrctrseg
                   AND s.tpseguro = 4;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || vr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;    
              CONTINUE;
            ELSE
              vr_index := rw_prestamista.nrcpfcgc || rw_prestamista.nrctremp;
              vr_tab_ctrl_prst(vr_index).nrcpfcgc := rw_prestamista.nrcpfcgc;
              vr_tab_ctrl_prst(vr_index).nrctremp := rw_prestamista.nrctremp;
            END IF;
          END IF;
          
          if vr_nrdeanos > vr_tab_nrdeanos or
             vr_nrdeanos < 14 then             
             if vr_nrdeanos > vr_tab_nrdeanos then
               if vr_tpregist = 1 then 
                 vr_tpregist:= 0; 
                 continue; 
               elsif vr_tpregist = 3 then 
                 vr_tpregist:= 2;
               elsif vr_tpregist = 2 then 
                 IF vr_tpregist <> rw_prestamista.tpregist THEN
                   vr_tpregist := 2;
                 ELSE
                    CONTINUE;
                 END IF;
               end if;
             elsif vr_nrdeanos < 14 then
               vr_tpregist:= 1; 
               BEGIN    
                 
                 vr_linha :=   ' UPDATE CECRED.tbseg_prestamista p '
                            || '    SET p.tpregist = ' || rw_prestamista.tpregist 
                            || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                            || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                            || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                            || '    AND p.nrctremp = ' || rw_prestamista.nrctremp
                            || '    AND p.cdapolic = ' || vr_cdapolic ||';';

                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
                           
                  UPDATE cecred.tbseg_prestamista
                     SET tpregist = vr_tpregist
                   WHERE cdcooper = vr_cdcooper
                     AND nrdconta = rw_prestamista.nrdconta
                     AND nrctrseg = rw_prestamista.nrctrseg
                     AND nrctremp = rw_prestamista.nrctremp
                     AND cdapolic = vr_cdapolic;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || vr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;                  
                continue;
             end if;
          end if;        
          
          if (vr_vlenviad = 0 or rw_prestamista.inliquid = 1) and vr_tpregist = 3 then 
            vr_tpregist := 2;
          elsif (vr_vlenviad = 0 or rw_prestamista.inliquid = 1) and rw_prestamista.tpregist in( 1,2) then 
            vr_tpregist:= 0;
             BEGIN 
               
               vr_linha := ' UPDATE CECRED.tbseg_prestamista p '
                        || '    SET p.tpregist = ' || rw_prestamista.tpregist 
                        || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                        || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                        || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                        || '    AND p.nrctremp = ' || rw_prestamista.nrctremp
                        || '    AND p.cdapolic = ' || vr_cdapolic ||';';

               CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

               vr_linha := ' UPDATE CECRED.crapseg p   '
                        || '    SET p.cdsitseg = ' || rw_prestamista.cdsitseg 
                        || '       ,p.dtcancel = TO_DATE(''' || rw_prestamista.dtcancel || ''',''DD/MM/RRRR'')'
                        || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                        || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                        || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                        || '    AND p.tpseguro = ' || 4 ||';';

               CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
                            
                UPDATE cecred.tbseg_prestamista
                   SET tpregist = vr_tpregist
                 WHERE cdcooper = vr_cdcooper
                   AND nrdconta = rw_prestamista.nrdconta
                   AND nrctrseg = rw_prestamista.nrctrseg
                   AND nrctremp = rw_prestamista.nrctremp
                   AND cdapolic = vr_cdapolic;
                   
                UPDATE cecred.crapseg s
                   SET s.cdsitseg = 2,
                       s.dtcancel = vr_dtmvtolt
                 WHERE s.cdcooper = vr_cdcooper
                   AND s.nrdconta = rw_prestamista.nrdconta
                   AND s.nrctrseg = rw_prestamista.nrctrseg
                   AND s.tpseguro = 4;  
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao atualizar tipo de registro(idade): ' || vr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;    
            continue;          
          end if;
          
          IF vr_contrcpf IS NULL OR vr_contrcpf <> rw_prestamista.nrcpfcgc THEN 
            vr_contrcpf := rw_prestamista.nrcpfcgc; 
            vr_vlenviad := vr_vlsdatua;
            vr_vltotenv := vr_vlsdatua;
            
            IF vr_vlenviad > vr_vlmaximo AND vr_tpregist NOT IN (0,2) THEN
              vr_vlenviad := vr_vlmaximo; 
                           
              vr_dscorpem := 'Ola, o contrato de emprestimo abaixo ultrapassou o valor limite maximo coberto pela seguradora, segue dados:<br /><br />
                              Cooperativa: ' || vr_nmrescop || '<br />
                              Conta: '       || rw_prestamista.nrdconta || '<br />
                              Nome: '        || rw_prestamista.nmprimtl || '<br />
                              Contrato Empréstimo: '|| rw_prestamista.nrctremp || '<br />
                              Proposta seguro: '    || rw_prestamista.nrctrseg || '<br />
                              Valor Empréstimo: '   || rw_prestamista.vldevatu || '<br />
                              Valor saldo devedor total: '|| vr_vlsdeved || '<br />
                              Valor Limite Máximo: ' || vr_vlmaximo;
              
              gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                         pr_des_destino => vr_destinatario_email,
                                         pr_des_assunto => 'Valor limite maximo excedido ',
                                         pr_des_corpo   => vr_dscorpem,
                                         pr_des_anexo   => NULL,
                                         pr_flg_enviar  => 'S',
                                         pr_des_erro    => vr_dscritic); 
              IF vr_vlenviad <= 0 THEN
                continue;
              END IF;                         
            END IF;  
          ELSE
            vr_vltotenv := vr_vltotenv + vr_vlsdatua;
            IF vr_vltotenv > vr_vlmaximo AND vr_tpregist NOT IN (0,2) THEN
              vr_vlenviad := vr_vlmaximo - (vr_vltotenv - vr_vlsdatua); 
              
              vr_dscorpem := 'Ola, o contrato de emprestimo abaixo ultrapassou o valor limite maximo coberto pela seguradora, segue dados:<br /><br />
                              Cooperativa: ' || vr_nmrescop || '<br />
                              Conta: '       || rw_prestamista.nrdconta || '<br />
                              Nome: '        || rw_prestamista.nmprimtl || '<br />
                              Contrato Empréstimo: '|| rw_prestamista.nrctremp || '<br />
                              Proposta seguro: '    || rw_prestamista.nrctrseg || '<br />
                              Valor Empréstimo: '   || rw_prestamista.vldevatu || '<br />
                              Valor saldo devedor total: '|| vr_vlsdeved || '<br />
                              Valor Limite Máximo: ' || vr_vlmaximo;
              
              gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                         pr_des_destino => vr_destinatario_email,
                                         pr_des_assunto => 'Valor limite maximo excedido ',
                                         pr_des_corpo   => vr_dscorpem,
                                         pr_des_anexo   => NULL,
                                         pr_flg_enviar  => 'S',
                                         pr_des_erro    => vr_dscritic); 
              IF vr_vlenviad <= 0 THEN
                continue;
              END IF;
            ELSE 
              vr_vlenviad := vr_vlsdatua; 
            END IF;
          END IF;
          
          vr_vlprodvl := vr_vlenviad * (vr_pgtosegu/100); 

          if vr_vlprodvl < 0.01 then
            vr_vlprodvl:= 0.01;
          end if;  
          if vr_vlenviad < 0.01 then
            vr_vlenviad:= 0.01;
          end if;
          
          IF vr_tpregist = 1 THEN
            OPEN cr_nrproposta(pr_nrproposta => vr_NRPROPOSTA);
              FETCH cr_nrproposta INTO rw_nrproposta;
              IF cr_nrproposta%FOUND THEN
                 BEGIN
                   vr_NRPROPOSTA := segu0003.fn_nrproposta;
                   
                   vr_linha := ' UPDATE CECRED.tbseg_prestamista p '
                            || '    SET p.nrproposta = ''' || rw_prestamista.nrproposta || ''''
                            || '  WHERE p.idseqtra = ' || rw_prestamista.idseqtra ||';';

                   CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                   vr_linha := ' UPDATE CECRED.crawseg '
                            || '    SET nrproposta = ' || rw_prestamista.nrproposta 
                            || '  WHERE cdcooper = ' || rw_prestamista.cdcooper
                            || '    AND nrdconta = ' || rw_prestamista.nrdconta
                            || '    AND nrctrseg = ' || rw_prestamista.nrctrseg
                            || '    AND tpseguro = ' || 4 ||';';

                   CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
                   
                   UPDATE tbseg_prestamista p
                      SET p.nrproposta = vr_NRPROPOSTA
                    WHERE p.idseqtra = rw_prestamista.idseqtra;
                      
                   UPDATE crawseg w
                      SET w.nrproposta = vr_NRPROPOSTA
                    WHERE w.cdcooper = rw_prestamista.cdcooper
                      AND w.nrdconta = rw_prestamista.nrdconta
                      AND w.nrctrseg = rw_prestamista.nrctrseg
                      AND w.tpseguro = 4;  
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_cdcritic := 0;
                      vr_dscritic := 'Erro ao atualizar numero de proposta já atualizada - cdcooper: ' || vr_cdcooper || ' - nrdconta: ' || rw_prestamista.nrdconta || ' - nrproposta: ' || vr_NRPROPOSTA || ' - '  || SQLERRM;
                      RAISE vr_exc_saida;
                  END;    
              END IF;
            CLOSE cr_nrproposta;
          END IF;
          
          OPEN cr_crawepr(pr_cdcooper => rw_prestamista.cdcooper,
                          pr_nrdconta => rw_prestamista.nrdconta,
                          pr_nrctremp => rw_prestamista.nrctremp);
            FETCH cr_crawepr INTO rw_crawepr;
            IF cr_crawepr%FOUND THEN
              IF rw_crawepr.dtvencto <> rw_prestamista.dtfimvig THEN
                
                vr_linha := 'UPDATE CECRED.tbseg_prestamista p '
                        || '    SET p.dtinivig = TO_DATE(''' || rw_prestamista.dtinivig || ''',''DD/MM/RRRR'')' 
                        || '        p.dtfimvig = TO_DATE(''' || rw_prestamista.dtfimvig || ''',''DD/MM/RRRR'')'
                        || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                        || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                        || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg ||';';

                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                vr_linha := 'UPDATE CECRED.crawseg p   '
                        || '    SET p.dtinivig = TO_DATE(''' || rw_prestamista.dtinivig || ''',''DD/MM/RRRR'')' 
                        || '        p.dtfimvig = TO_DATE(''' || rw_prestamista.dtfimvig || ''',''DD/MM/RRRR'')'
                        || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                        || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                        || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg ||';';

                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                vr_linha := 'UPDATE CECRED.crapseg p   '
                        || '    SET p.dtinivig = TO_DATE(''' || rw_prestamista.dtinivig || ''',''DD/MM/RRRR'')' 
                        || '        p.dtfimvig = TO_DATE(''' || rw_prestamista.dtfimvig || ''',''DD/MM/RRRR'')'
                        || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                        || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                        || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg ||';';

                CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
              
              
                UPDATE tbseg_prestamista p
                   SET p.dtinivig = rw_crawepr.dtmvtolt
                      ,p.dtfimvig = rw_crawepr.dtvencto
                 WHERE p.cdcooper = rw_prestamista.cdcooper
                   AND p.nrdconta = rw_prestamista.nrdconta
                   AND p.nrctrseg = rw_prestamista.nrctrseg;
                   
                UPDATE crawseg w
                   SET w.dtinivig = rw_crawepr.dtmvtolt
                      ,w.dtfimvig = rw_crawepr.dtvencto
                 WHERE w.cdcooper = rw_prestamista.cdcooper
                   AND w.nrdconta = rw_prestamista.nrdconta
                   AND w.nrctrseg = rw_prestamista.nrctrseg;
                   
                UPDATE crapseg p
                   SET p.dtinivig = rw_crawepr.dtmvtolt
                      ,p.dtfimvig = rw_crawepr.dtvencto
                 WHERE p.cdcooper = rw_prestamista.cdcooper
                   AND p.nrdconta = rw_prestamista.nrdconta
                   AND p.nrctrseg = rw_prestamista.nrctrseg;
                   
                vr_dtinivig := rw_crawepr.dtmvtolt;
                vr_dtfimvig := rw_crawepr.dtvencto;
              END IF;
            END IF;
          CLOSE cr_crawepr;
          
          IF rw_prestamista.cdsitseg = 2 AND rw_prestamista.tpregist = 3 THEN
            vr_tpregist := 2;
          
          END IF;
          
          vr_linha_txt := '';

          vr_linha_txt := vr_linha_txt || LPAD(vr_seqtran, 5, 0); 
          vr_linha_txt := vr_linha_txt || LPAD(vr_tpregist, 2, 0);
          vr_linha_txt := vr_linha_txt || LPAD(vr_apolice, 15, 0);
          vr_linha_txt := vr_linha_txt || RPAD(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'), 14, ' '); 
          vr_linha_txt := vr_linha_txt || LPAD(' ', 20, ' '); 
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(cecred.gene0007.fn_caract_especial(rw_prestamista.nmprimtl)), 70, ' '); 
          vr_linha_txt := vr_linha_txt ||
                          LPAD(to_char(rw_prestamista.dtnasctl, 'YYYY-MM-DD'), 10, 0); 
          vr_linha_txt := vr_linha_txt || LPAD(rw_prestamista.cdsexotl, 2, 0); 
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(cecred.gene0007.fn_caract_especial(nvl(rw_prestamista.dsendres,' '))), 60, ' '); 
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(cecred.gene0007.fn_caract_especial(nvl(substr(rw_prestamista.nmbairro,0,30),' '))), 30, ' '); 
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(cecred.gene0007.fn_caract_especial(nvl(rw_prestamista.nmcidade,' '))), 30, ' '); 
          vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.cdufresd), ' '),2,' '); 
          vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_prestamista.nrcepend, 'zzzzz-zz9'), 10, ' '); 
          
          IF length(rw_prestamista.nrtelefo) = 11 THEN
            vr_linha_txt := vr_linha_txt || RPAD(cecred.gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)99999-9999'), 15, ' '); 
          ELSIF length(rw_prestamista.nrtelefo) = 10 THEN
            vr_linha_txt := vr_linha_txt || RPAD(cecred.gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)9999-9999'), 15, ' '); 
          ELSE
            vr_linha_txt := vr_linha_txt || RPAD(cecred.gene0002.fn_mask(rw_prestamista.nrtelefo, '99999-9999'), 15, ' '); 
          END IF;
          
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); 
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); 
          
          vr_dsdemail := rw_prestamista.dsdemail;
          cecred.SEGU0003.pc_limpa_email(vr_dsdemail);
          
          vr_linha_txt := vr_linha_txt || RPAD(' ', 1, ' '); 
          vr_linha_txt := vr_linha_txt || RPAD(nvl(vr_dsdemail, ' '), 50, ' '); 
          vr_linha_txt := vr_linha_txt || RPAD(' ', 12, ' '); 
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); 
          vr_linha_txt := vr_linha_txt || RPAD( vr_NRPROPOSTA, 30, ' '); 
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
          
          vr_index_815 := vr_index_815 + 1;
          vr_tab_crrl815(vr_index_815) := NULL;
          vr_tab_crrl815(vr_index_815).dtmvtolt := vr_dtmvtolt ; 
          vr_tab_crrl815(vr_index_815).nmrescop := vr_nmrescop;
          vr_tab_crrl815(vr_index_815).nmprimtl := rw_prestamista.nmprimtl;
          vr_tab_crrl815(vr_index_815).nrdconta := rw_prestamista.nrdconta;
          vr_tab_crrl815(vr_index_815).cdagenci := rw_prestamista.cdagenci;          
          vr_tab_crrl815(vr_index_815).nrctrseg := vr_NRPROPOSTA;
          vr_tab_crrl815(vr_index_815).nrctremp := rw_prestamista.nrctremp;
          vr_tab_crrl815(vr_index_815).nrcpfcgc := rw_prestamista.nrcpfcgc;
          vr_tab_crrl815(vr_index_815).vlprodut := vr_vlprodvl;
          vr_tab_crrl815(vr_index_815).vlenviad := vr_vlenviad;
          vr_tab_crrl815(vr_index_815).vlsdeved := vr_vlsdeved;
          vr_tab_crrl815(vr_index_815).dtinivig := vr_dtinivig;
          vr_tab_crrl815(vr_index_815).dtrefcob := vr_ultimoDia;
          vr_tab_crrl815(vr_index_815).tpregist := vr_tpregist;
          vr_tab_crrl815(vr_index_815).dsregist := vr_tipo_registro(vr_tpregist).tpregist;
          
          IF vr_tpregist = 1 THEN 
            vr_tpregist := 3;
          END IF;
            
          IF vr_flgnvenv THEN           
            BEGIN 
              
              vr_linha := ' UPDATE CECRED.tbseg_prestamista p '
                       || '    SET tpregist = ' || rw_prestamista.tpregist
                       || '       ,vlprodut = ' || REPLACE(to_char(rw_prestamista.vlprodut,'fm999999999990d00'),',','.') 
                       || '       ,p.dtdenvio = TO_DATE(''' || rw_prestamista.dtdenvio || ''',''DD/MM/RRRR'')' 
                       || '       ,p.dtrefcob = TO_DATE(''' || rw_prestamista.dtrefcob || ''',''DD/MM/RRRR'')'
                       || '       ,p.dtdevend = TO_DATE(''' || rw_prestamista.dtdevend || ''',''DD/MM/RRRR'')' 
                       || '       ,p.dtfimvig = TO_DATE(''' || rw_prestamista.dtfimvig || ''',''DD/MM/RRRR'')'
                       || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                       || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                       || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg ||';';

              CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
            
              UPDATE cecred.tbseg_prestamista
                 SET tpregist = vr_tpregist
                    ,dtdenvio = vr_dtmvtolt  
                    ,vlprodut = vr_vlprodvl
                    ,dtrefcob = vr_ultimoDia
                    ,dtdevend = vr_dtdevend
                    ,dtfimvig = vr_dtfimvig
               WHERE cdcooper = vr_cdcooper
                 AND nrdconta = rw_prestamista.nrdconta
                 AND nrctrseg = rw_prestamista.nrctrseg
                 AND nrctremp = rw_prestamista.nrctremp
                 AND cdapolic = vr_cdapolic_canc;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || vr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                RAISE vr_exc_saida;
            END;   
            vr_tpregist := 0; 
          END IF;
            
          BEGIN 
            
            vr_linha := ' UPDATE CECRED.tbseg_prestamista p '
                     || '    SET tpregist = ' || rw_prestamista.tpregist
                     || '       ,vlprodut = ' || REPLACE(to_char(rw_prestamista.vlprodut,'fm999999999990d00'),',','.') 
                     || '       ,p.dtdenvio = TO_DATE(''' || rw_prestamista.dtdenvio || ''',''DD/MM/RRRR'')' 
                     || '       ,p.dtrefcob = TO_DATE(''' || rw_prestamista.dtrefcob || ''',''DD/MM/RRRR'')'
                     || '       ,p.dtdevend = TO_DATE(''' || rw_prestamista.dtdevend || ''',''DD/MM/RRRR'')' 
                     || '       ,p.dtfimvig = TO_DATE(''' || rw_prestamista.dtfimvig || ''',''DD/MM/RRRR'')'
                     || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                     || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                     || '    AND p.nrctremp = ' || rw_prestamista.nrctremp
                     || '    AND p.cdapolic = ' || vr_cdapolic || ';';

              CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
          
            UPDATE cecred.tbseg_prestamista
               SET tpregist = vr_tpregist
                  ,dtdenvio = vr_dtmvtolt  
                  ,vlprodut = vr_vlprodvl
                  ,dtrefcob = vr_ultimoDia
                  ,dtdevend = vr_dtdevend
                  ,dtfimvig = vr_dtfimvig
             WHERE cdcooper = vr_cdcooper
               AND nrdconta = rw_prestamista.nrdconta
               AND nrctrseg = rw_prestamista.nrctrseg
               AND nrctremp = rw_prestamista.nrctremp
               AND cdapolic = vr_cdapolic;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || vr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
          
          
          IF vr_tpregist = 2 THEN
            BEGIN
              
              vr_linha :=  ' UPDATE CECRED.crapseg p '
                        || '    SET p.cdsitseg = ' || rw_prestamista.cdsitseg 
                        || '       ,p.dtcancel = TO_DATE(''' || rw_prestamista.dtcancel || ''',''DD/MM/RRRR'')'
                        || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                        || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                        || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                        || '    AND p.tpseguro = ' || 4 ||';';

              CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
              
              vr_linha :=  ' UPDATE CECRED.tbseg_prestamista p '
                        || '    SET p.tpregist = ' || rw_prestamista.tpregist 
                        || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                        || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                        || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                        || '    AND p.nrctremp = ' || rw_prestamista.nrctremp
                        || '    AND p.cdapolic = ' || vr_cdapolic ||';';

              CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
            
              UPDATE cecred.crapseg c
                 SET c.cdsitseg = vr_tpregist,
                     c.dtcancel = vr_dtmvtolt 
               WHERE c.cdcooper = rw_prestamista.cdcooper
                 AND c.nrdconta = rw_prestamista.nrdconta
                 AND c.nrctrseg = rw_prestamista.nrctrseg
                 AND c.tpseguro = 4;
                 
              UPDATE cecred.tbseg_prestamista
                 SET tpregist = 0
               WHERE cdcooper = vr_cdcooper
                 AND nrdconta = rw_prestamista.nrdconta
                 AND nrctrseg = rw_prestamista.nrctrseg
                 AND nrctremp = rw_prestamista.nrctremp
                 AND cdapolic = vr_cdapolic;                 
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao cancelar seguro prestamista: ' || vr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                RAISE vr_exc_saida;
            END;  
          ELSIF vr_tpregist = 3 THEN
            BEGIN
              
              vr_linha :=  ' UPDATE CECRED.crapseg p   '
                        || '    SET p.cdsitseg = ''' || rw_prestamista.cdsitseg || ''''
                        || '       ,p.dtcancel = TO_DATE(''' || rw_prestamista.dtcancel || ''',''DD/MM/RRRR'')'
                        || '       ,p.dtfimvig = TO_DATE(''' || rw_prestamista.dtfimvig || ''',''DD/MM/RRRR'')'
                        || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                        || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                        || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg
                        || '    AND p.tpseguro = 4'
                        || '    AND p.cdsitseg <> 1;';

              CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
            
              UPDATE crapseg c
                 SET c.cdsitseg = 1,
                     c.dtcancel = NULL,
                     c.dtfimvig = rw_prestamista.dtfimvig
               WHERE c.cdcooper = rw_prestamista.cdcooper
                 AND c.nrdconta = rw_prestamista.nrdconta
                 AND c.nrctrseg = rw_prestamista.nrctrseg
                 AND c.tpseguro = 4
                 AND c.cdsitseg <> 1;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao cancelar seguro prestamista: ' || vr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                RAISE vr_exc_saida;
            END;            
          END IF;
        
          GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);
        
          vr_seqtran := vr_seqtran + 1;         
        END LOOP;
        vr_tab_ctrl_prst.delete;
        vr_crrl815 := vr_tab_crrl815;

        cecred.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

        cecred.GENE0003.pc_converte_arquivo(pr_cdcooper => vr_cdcooper  
                                            ,pr_nmarquiv => vr_nmdircop || '/arq/'||vr_nmarquiv  
                                            ,pr_nmarqenv => vr_nmarquiv  
                                            ,pr_des_erro => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN 
          RAISE vr_exc_erro;            
        END IF;
        
        IF TRIM(vr_nmarquiv) IS NOT NULL THEN
           cecred.gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdircop||'/arq/'||vr_nmarquiv||' '||vr_nmdircop||'/salvar',
                                             pr_typ_saida   => vr_tipo_saida,
                                             pr_des_saida   => vr_dscritic);
        END IF;    
                                  
        IF vr_tipo_saida = 'ERR' THEN
          vr_dscritic := 'Erro ao mover o arquivo - Cooperativa: ' || vr_cdcooper || ' - ' ||vr_dscritic;
          cecred.btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                            ,pr_ind_tipo_log => 2 
                                            ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' -> '
                                                        || 'Movimentacao de diretorio retornou erro: '||vr_dscritic);
        END IF;
        vr_interacao := 0;
        IF fn_verifica_arq_disponivel_ftp(pr_caminho   => vr_nmdircop || '/salvar/' || vr_nmarquiv
                                         ,pr_interacao => vr_interacao) THEN
                                    
          cecred.SEGU0003.pc_processa_arq_ftp_prest(pr_nmarquiv => vr_nmarquiv, 
                                                   pr_idoperac => 'E',         
                                                   pr_nmdireto => vr_nmdircop || '/salvar/', 
                                                   pr_idenvseg => 'S',                       
                                                   pr_ftp_site => vr_endereco,               
                                                   pr_ftp_user => vr_login,                  
                                                   pr_ftp_pass => vr_senha,                  
                                                   pr_ftp_path => 'Envio',                   
                                                   pr_dscritic => vr_dscritic);              

          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Erro ao processar arquivo via FTP - Cooperativa: ' || vr_cdcooper || ' - ' || vr_dscritic;

            cecred.btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                              ,pr_ind_tipo_log => 2 
                                              ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' -> '
                                                          || 'Processamento de ftp retornou erro: '||vr_dscritic);
          END IF;
        ELSE
           vr_dscritic := 'Erro, arquivo não localizado para processar arquivo via FTP - Cooperativa: ' || vr_cdcooper 
                                        || ' Caminho: ' ||  vr_nmdircop || '/salvar/' || vr_nmarquiv || ' - ' || vr_dscritic;

            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 2 
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' -> '
                                                          || 'Localizar o arquivo de ftp retornou erro: '||vr_dscritic);
        END IF; 
            
        COMMIT;   
      END LOOP; 
      
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
      CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
      
      EXCEPTION
        WHEN vr_exc_saida THEN
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
        
          vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          ROLLBACK;

          gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                     pr_des_destino => vr_destinatario_email,
                                     pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                     pr_des_corpo   => vr_dscritic,
                                     pr_des_anexo   => NULL,
                                     pr_flg_enviar  => 'S',
                                     pr_des_erro    => vr_dscritic); 
        WHEN OTHERS THEN

          vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          ROLLBACK;
          gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                     pr_des_destino => vr_destinatario_email,
                                     pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                     pr_des_corpo   => vr_dscritic,
                                     pr_des_anexo   => NULL,
                                     pr_flg_enviar  => 'S',
                                     pr_des_erro    => vr_dscritic); 
      END;
