DECLARE
  pr_cdcooper   NUMBER := 9;
  vr_cdcritic   NUMBER;
  vr_dscritic   VARCHAR2(500);
  vr_exc_saida  EXCEPTION;
  vr_exc_erro   EXCEPTION;
  vr_tipo_saida VARCHAR2(100);
  vr_vlenviad   NUMBER;
  vr_nrsequen   NUMBER(5);
  vr_endereco   VARCHAR2(100);
  vr_login      VARCHAR2(100);
  vr_senha      VARCHAR2(100);
  vr_seqtran    INTEGER;
  vr_vlsdatua   NUMBER;
  vr_vlsdeved   NUMBER := 0;
  vr_tpregist   INTEGER;
  vr_tiporeg    VARCHAR2(1);
  vr_nrproposta tbseg_prestamista.nrproposta%TYPE;
  vr_cdapolic   tbseg_prestamista.cdapolic%TYPE;
  vr_dtdevend   tbseg_prestamista.dtdevend%TYPE;
  vr_dtinivig   tbseg_prestamista.dtinivig%TYPE;
  vr_pielimit   tbseg_prestamista.vlpielimit%TYPE;
  vr_ifttlimi   tbseg_prestamista.vlpielimit%TYPE;

  vr_nmrescop   crapcop.nmrescop%TYPE;
  vr_apolice    VARCHAR2(20);
  vr_nmdircop   VARCHAR2(100);
  vr_nmarquiv   VARCHAR2(100);
  vr_nmarquivFinal VARCHAR2(100);
  vr_linha_txt VARCHAR2(32600);
  vr_ultimoDia DATE;
  vr_vlprodvl  NUMBER;
  vr_dtfimvig  DATE;
  vr_nr_meses  NUMBER;

  vr_dtcancelamento DATE;
  vr_dtprotocolo    DATE;
  vr_vlcaptpie      NUMERIC (15,2);
  vr_vlcaptiftt     NUMERIC (15,2);
  vr_capitalvg      NUMERIC (15,2);
  vr_modulo         VARCHAR2(50);
  vr_sub            VARCHAR2(50);
  vr_complemento    VARCHAR2(50);
  vr_motivo_cancel  VARCHAR2(100);
  vr_banco          VARCHAR2(100);
  vr_agencia        VARCHAR2(100);
  vr_conta_corrente VARCHAR2(100);

  TYPE typ_reg_ctrl_prst IS RECORD(nrcpfcgc tbseg_prestamista.nrcpfcgc%TYPE,
                                   nrctremp tbseg_prestamista.nrctremp%TYPE);

  
  TYPE typ_tab_ctrl_prst IS TABLE OF typ_reg_ctrl_prst INDEX BY VARCHAR2(40);
  vr_tab_ctrl_prst typ_tab_ctrl_prst ;

  
  vr_ind_arquivo utl_file.file_type;

  
  CURSOR cr_prestamista(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
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
          ,c.qtpreemp
          ,c.vlpreemp
          ,p.nrproposta
          ,lpad(decode(p.cdcooper , 5,1, 7,2, 10,3,  11,4, 14,5, 9,6, 16,7, 2,8, 8,9, 6,10, 12,11, 13,12, 1,13  )   ,6,'0') cdcooperativa
          ,SUM(p.vldevatu) over(partition by  p.cdcooper, p.nrcpfcgc ) saldo_cpf
          ,ADD_MONTHS(c.dtmvtolt, c.qtpreemp)  dtfimctr
          ,p.nrapolice
          ,p.vlpielimit
          ,p.vlifttlimi
          ,p.qtifttdias
      FROM tbseg_prestamista p, crapepr c, crapass ass
     WHERE p.cdcooper = 9
       AND p.nrdconta = 191450
       AND p.nrproposta = 770629674187
       AND c.cdcooper = p.cdcooper
       AND c.nrdconta = p.nrdconta
       AND c.nrctremp = p.nrctremp
       AND ass.cdcooper = c.cdcooper
       AND ass.nrdconta = c.nrdconta
       AND TRUNC(p.dtinivig) < TRUNC(SYSDATE)
       AND p.tpregist NOT IN (0,2)
       AND p.tpcustei = 0 
       ORDER BY p.nrcpfcgc ASC , p.cdapolic;
  rw_prestamista cr_prestamista%ROWTYPE;

  
  CURSOR cr_seg_parametro_prst(pr_cdcooper IN tbseg_prestamista.cdcooper%TYPE
                              ,pr_tpcustei IN tbseg_parametros_prst.tpcustei%TYPE) IS
   
    SELECT pp.idseqpar,
           pp.seqarqu,
           pp.enderftp,
           pp.loginftp,
           pp.senhaftp,
           pp.nrapolic,
           pp.pielimit,
           pp.ifttlimi
      FROM tbseg_parametros_prst pp
     WHERE pp.cdcooper = pr_cdcooper
       AND pp.tppessoa = 1 
       AND pp.cdsegura = segu0001.busca_seguradora
       AND pp.tpcustei = pr_tpcustei;
  rw_seg_parametro_prst cr_seg_parametro_prst%ROWTYPE;

  CURSOR cr_crawseg(pr_cdcooper crawseg.cdcooper%TYPE,
                    pr_nrdconta crawseg.nrdconta%TYPE,
                    pr_nrctrseg crawseg.nrctrseg%TYPE,
                    pr_nrctrato crawseg.nrctrato%TYPE) IS
    SELECT c.flggarad, c.nrendres
      FROM crawseg c
     WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta = pr_nrdconta
       AND c.nrctrseg = pr_nrctrseg
       AND c.nrctrato = pr_nrctrato;
  rw_crawseg cr_crawseg%ROWTYPE;
  
 BEGIN  
   vr_seqtran := 1;

   SELECT nmrescop
     INTO vr_nmrescop
     FROM crapcop
    WHERE cdcooper = pr_cdcooper;

   
   OPEN cr_seg_parametro_prst(pr_cdcooper => pr_cdcooper,
                              pr_tpcustei => 0); 
     FETCH cr_seg_parametro_prst INTO rw_seg_parametro_prst;
     IF cr_seg_parametro_prst%NOTFOUND THEN
       CLOSE cr_seg_parametro_prst;
       vr_dscritic := 'Nao foi possivel localizar taxa de pagamento da seguradora. PC_PARAMETROS_PRST';
       RAISE vr_exc_saida;
     END IF;
   CLOSE cr_seg_parametro_prst;

  
   vr_nrsequen := rw_seg_parametro_prst.seqarqu + 1;

   vr_endereco := rw_seg_parametro_prst.enderftp;
   vr_login    := rw_seg_parametro_prst.loginftp;
   vr_senha    := rw_seg_parametro_prst.senhaftp;

        
   BEGIN
     UPDATE tbseg_parametros_prst p
        SET p.seqarqu = vr_nrsequen
      WHERE p.idseqpar = rw_seg_parametro_prst.idseqpar;
     COMMIT;
   EXCEPTION
     WHEN OTHERS THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Erro ao atualizar sequencia da cooperativa: ' || pr_cdcooper || ' - ' || SQLERRM;
       RAISE vr_exc_saida;
   END;

        
   vr_ultimoDia := trunc(SYSDATE,'MONTH')-1;

        
   vr_nmdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                        pr_cdcooper => pr_cdcooper);

        
   IF NOT gene0001.fn_database_name = gene0001.fn_param_sistema('CRED',0,'DB_NAME_PRODUC') THEN          
     vr_apolice := NVL(gene0001.fn_param_sistema('CRED', 0, 'APOLICE_ICATU_SEGPRE'),'77000799');
   ELSE          
     vr_apolice  := nvl(rw_prestamista.nrapolice,rw_seg_parametro_prst.nrapolic);
   END IF;

   vr_nmarquiv := 'TMP_AILOS_'||vr_apolice||'_'||replace(vr_nmrescop,' ','_')||'_'    
                ||REPLACE(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '') || '_' ||
                  gene0002.fn_mask(vr_nrsequen, '99999') || '.csv';

   vr_nmarquivFinal := 'AILOS_'||vr_apolice||'_'||replace(vr_nmrescop,' ','_')||'_'   
                ||REPLACE(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '') || '_' ||
                  gene0002.fn_mask(vr_nrsequen, '99999') || '.csv';

   
   GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop || '/arq/'       
                           ,pr_nmarquiv => vr_nmarquiv                  
                           ,pr_tipabert => 'W'                          
                           ,pr_utlfileh => vr_ind_arquivo               
                           ,pr_des_erro => vr_dscritic);                

   IF vr_dscritic IS NOT NULL THEN
     RAISE vr_exc_erro;      
   END IF;

       
   vr_linha_txt :=  'CPF,Nome,Sexo,Data de Nascimento,Modulo,Subestipulante,Capital VG Basica,Matricula Funcional,Valor Premio VG,Data de Inicio de Vigencia do Contrato/Certificado,Data de Fim de Vigencia do Contrato/Certificado,'
   ||'Tipo de movimento,Endereco,Complemento,Bairro,Cidade,UF,CEP,'
   ||'Numero Endereco,Numero Proposta,Data da solicitacao do cancelamento,Numero da apolice coletiva,Data do Protocolo,CAPITAL PIE,CAPITAL IFTT,Meses de Financiamento,Data da Assinatura da Proposta,Valor da Parcela do financiamento,'
   ||'Competencia do movimento,Motivo do cancelamento do risco,Cooperativa,Banco,Agencia,Numero Conta Corrente';
   GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);
   vr_linha_txt := '';

        
  FOR rw_prestamista IN cr_prestamista(pr_cdcooper => pr_cdcooper) LOOP
    vr_vlsdeved   := rw_prestamista.saldo_cpf;
    vr_vlsdatua   := rw_prestamista.vldevatu;
    vr_tpregist   := rw_prestamista.tpregist;
    vr_cdapolic   := rw_prestamista.cdapolic;
    vr_nrproposta := nvl(rw_prestamista.nrproposta,0);
    vr_dtdevend   := rw_prestamista.dtdevend;
    vr_dtinivig   := rw_prestamista.dtinivig;
    vr_dtfimvig   := rw_prestamista.dtfimvig;

    IF rw_prestamista.dtfimvig IS NULL THEN
      vr_dtfimvig := rw_prestamista.dtfimctr;
    END IF;

    vr_tiporeg := CASE WHEN vr_tpregist = 1
                     THEN 'I'
                  WHEN vr_tpregist = 2
                     THEN 'C'
                  WHEN vr_tpregist = 3
                     THEN 'I'
                  END;

    vr_dtcancelamento := NULL;

    IF vr_tpregist = 2 THEN
       vr_dtcancelamento := vr_ultimoDia;
    END IF;

    vr_modulo := '0';
    vr_sub    := rw_prestamista.cdcooperativa;
    vr_dtprotocolo := rw_prestamista.data_emp;

    OPEN cr_crawseg(pr_cdcooper => rw_prestamista.cdcooper,
                    pr_nrdconta => rw_prestamista.nrdconta,
                    pr_nrctrseg => rw_prestamista.nrctrseg,
                    pr_nrctrato => rw_prestamista.nrctremp);
      FETCH cr_crawseg INTO rw_crawseg;
      IF cr_crawseg%NOTFOUND THEN
        vr_dscritic := 'Proposta de seguro prestamista não localizado!:
                                 Conta: ' || rw_prestamista.nrdconta ||
                                ' Apólice: ' || rw_prestamista.nrctrseg ||
                                ' Contrato Empréstimo: ' ||rw_prestamista.nrctremp ;
        RAISE vr_exc_erro;       
      END IF;
    CLOSE cr_crawseg;

    IF rw_crawseg.flggarad = 1 THEN
      vr_vlcaptiftt := rw_prestamista.vlpreemp;
      vr_modulo     := 2;
      vr_vlcaptpie  := rw_prestamista.vlpreemp;

      vr_pielimit := nvl(rw_prestamista.vlpielimit, rw_seg_parametro_prst.pielimit);
      IF vr_vlcaptpie > vr_pielimit THEN
         vr_vlcaptpie := vr_pielimit;
      END IF;

      vr_vlcaptpie := vr_vlcaptpie * rw_prestamista.qtifttdias;

      vr_ifttlimi := nvl(rw_prestamista.vlifttlimi, rw_seg_parametro_prst.ifttlimi);
      IF vr_vlcaptiftt > vr_ifttlimi THEN
         vr_vlcaptiftt := vr_ifttlimi;
      END IF;

      vr_vlcaptiftt := vr_vlcaptiftt * rw_prestamista.qtifttdias;
    ELSE
      vr_vlcaptiftt := 0;
      vr_vlcaptpie  := 0;
      vr_modulo     := 1;
    END IF;
          
    vr_capitalvg := rw_prestamista.vlsdeved;
    vr_vlenviad := rw_prestamista.vlsdeved;
    vr_vlprodvl := rw_prestamista.vlprodut;
    
    IF vr_vlprodvl < 0.01 THEN
      vr_vlprodvl:= 0.01;
    END IF;
    
    IF vr_vlenviad < 0.01 THEN
      vr_vlenviad:= 0.01;
    END IF;

    vr_banco           := '85';
    vr_agencia         := rw_prestamista.cdagenci;
    vr_conta_corrente  := rw_prestamista.nrdconta;

    vr_linha_txt :='';
    
    vr_linha_txt := vr_linha_txt || TRIM(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'))||','; 
    
    vr_linha_txt := vr_linha_txt ||
                     TRIM(UPPER(gene0007.fn_caract_especial(rw_prestamista.nmprimtl)))||',';
     
    IF rw_prestamista.cdsexotl = 1 THEN 
      vr_linha_txt := vr_linha_txt || 'M,';
    ELSE
      vr_linha_txt := vr_linha_txt || 'F,';
    END IF;
    
    vr_linha_txt := vr_linha_txt ||to_char(rw_prestamista.dtnasctl, 'DD/MM/YYYY')||','; 
    
    vr_linha_txt := vr_linha_txt ||vr_modulo||',';
    
    vr_linha_txt := vr_linha_txt ||vr_sub||',';

    vr_linha_txt := vr_linha_txt || REPLACE(to_char(vr_capitalvg,'fm999999999990d00'),',','.') ||',';
    
    vr_linha_txt := vr_linha_txt ||TRIM(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'))
                                 ||rw_prestamista.nrctremp ||',' ;
    
    vr_linha_txt := vr_linha_txt || REPLACE(to_char(vr_vlprodvl,'fm999999999990d00'),',','.') ||',';

    vr_linha_txt := vr_linha_txt || TO_CHAR(vr_dtinivig, 'DD/MM/YYYY')||','; 
    
    vr_linha_txt := vr_linha_txt || TO_CHAR(vr_dtfimvig, 'DD/MM/YYYY')||','; 
    
    vr_linha_txt := vr_linha_txt ||vr_tiporeg||',';
    
    vr_linha_txt := vr_linha_txt ||TRIM(REPLACE(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.dsendres,' '))),',',' '))||','; 
    
    vr_linha_txt := vr_linha_txt ||TRIM(vr_complemento)||',';
    
    vr_linha_txt := vr_linha_txt ||TRIM(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.nmbairro,' '))))||',';
          
    vr_linha_txt := vr_linha_txt ||TRIM(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.nmcidade,' '))))||',';
    
    vr_linha_txt := vr_linha_txt || TRIM(nvl(to_char(rw_prestamista.cdufresd), ' '))||',';
    
    vr_linha_txt := vr_linha_txt || TRIM(rw_prestamista.nrcepend)||',';
    
    vr_linha_txt := vr_linha_txt || rw_crawseg.nrendres || ',';
    
    vr_linha_txt := vr_linha_txt || vr_nrproposta||',';

    vr_linha_txt := vr_linha_txt || TO_CHAR(vr_dtcancelamento, 'DD/MM/YYYY')||','; 
    
    vr_linha_txt := vr_linha_txt || vr_apolice||',' ; 

    vr_linha_txt := vr_linha_txt || TO_CHAR(vr_dtprotocolo, 'DD/MM/YYYY')||','; 

    vr_linha_txt := vr_linha_txt || REPLACE(to_char(vr_vlcaptpie,'fm999999999990d00'),',','.') ||',';
          
    vr_linha_txt := vr_linha_txt || REPLACE(to_char(vr_vlcaptiftt,'fm999999999990d00'),',','.') ||',';
    
    vr_nr_meses := TRUNC((vr_dtfimvig - vr_dtinivig)/30);
    
    vr_linha_txt := vr_linha_txt || vr_nr_meses ||',';
    
    vr_linha_txt := vr_linha_txt || TO_CHAR(rw_prestamista.dtdevend, 'DD/MM/YYYY')||' ,';

    vr_linha_txt := vr_linha_txt || REPLACE(to_char(rw_prestamista.vlpreemp,'fm999999999990d00'),',','.')||',' ;

    vr_linha_txt := vr_linha_txt || TO_CHAR(vr_ultimoDia, 'MMYYYY')||',' ;
    
    vr_linha_txt := vr_linha_txt || vr_motivo_cancel||' ,';
    
    vr_linha_txt := vr_linha_txt || TRIM(rw_prestamista.cdcooper)|| ',';

    vr_linha_txt := vr_linha_txt || TRIM(vr_banco)|| ','; 

    vr_linha_txt := vr_linha_txt || TRIM(vr_agencia)|| ','; 

    vr_linha_txt := vr_linha_txt || TRIM(vr_conta_corrente); 
     
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);
    
    vr_seqtran := vr_seqtran + 1;
  END LOOP;
   
  vr_tab_ctrl_prst.delete;        

  GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

  GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper                   
                              ,pr_nmarquiv => vr_nmdircop || '/arq/'||vr_nmarquiv       
                              ,pr_nmarqenv => vr_nmarquiv           
                              ,pr_des_erro => vr_dscritic);                

  IF vr_dscritic IS NOT NULL THEN    
    RAISE vr_exc_erro;
  END IF;

       
  gene0001.pc_OScommand_Shell(pr_des_comando => 'iconv -f ISO8859-1 -t utf-8 '||vr_nmdircop || '/converte/' || vr_nmarquiv||
                                                      ' > '||vr_nmdircop||'/arq/'||vr_nmarquivFinal);

        
  SEGU0003.pc_processa_arq_ftp_prest(pr_nmarquiv => vr_nmarquivFinal,     
                                     pr_idoperac => 'E',                 
                                     pr_nmdireto => vr_nmdircop || '/arq/', 
                                     pr_idenvseg => 'S',                
                                     pr_ftp_site => vr_endereco,        
                                     pr_ftp_user => vr_login,           
                                     pr_ftp_pass => vr_senha,           
                                     pr_ftp_path => 'Envio', 
                                     pr_dscritic => vr_dscritic);      

   IF vr_dscritic IS NOT NULL THEN
     vr_dscritic := 'Erro ao processar arquivo via FTP - Cooperativa: ' || pr_cdcooper || ' - ' || vr_dscritic;
     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                               ,pr_ind_tipo_log => 2 
                               ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                   || 'INC0147270 -> '
                                                   || 'Processamento de ftp retornou erro: '||vr_dscritic);
   END IF;

   IF TRIM(vr_nmarquiv) IS NOT NULL THEN
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdircop||'/arq/'||vr_nmarquivFinal||' '||gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0147270',
                                  pr_typ_saida   => vr_tipo_saida,
                                  pr_des_saida   => vr_dscritic);
   END IF;

   IF vr_tipo_saida = 'ERR' THEN
     vr_dscritic := 'Erro ao mover o arquivo - Cooperativa: ' || pr_cdcooper || ' - ' ||vr_dscritic;
     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 
                                 ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss')||' - '
                                                     ||'INC0147270 -> '
                                                     || 'Movimentacao de diretorio retornou erro: '||vr_dscritic);
   END IF;

   COMMIT;

  EXCEPTION
     WHEN vr_exc_saida THEN
       IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 
                                 ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss')||' - '
                                                     || 'INC0147270 -> '
                                                     || 'Movimentacao de diretorio retornou erro: '||vr_dscritic);
       ROLLBACK;
     WHEN OTHERS THEN
       vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
       vr_dscritic := vr_dscritic;
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 
                                 ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss')||' - '
                                                     ||'INC0147270 -> '
                                                     || 'Movimentacao de diretorio retornou erro: '||vr_dscritic);
       ROLLBACK;
 END;
/
