DECLARE
   vr_exc_saida     EXCEPTION;
   vr_tipo_saida    VARCHAR2(100);
   vr_dscritic      VARCHAR2(500);
   vr_exc_erro      EXCEPTION;
   vr_dtmvtolt      CECRED.crapdat.dtmvtolt%type;
   vr_cdcooper      CECRED.crapcop.cdcooper%TYPE;
     
   vr_nrsequen      NUMBER(5);
   vr_endereco      VARCHAR2(100);
   vr_login         VARCHAR2(100);
   vr_senha         VARCHAR2(100);
   vr_seqtran       INTEGER;
   vr_vlsdatua      NUMBER;
   vr_vlsdeved      NUMBER := 0;
   vr_tpregist      INTEGER;
   vr_tiporeg       VARCHAR2(1);
   vr_nrproposta    CECRED.tbseg_prestamista.nrproposta%TYPE;
   vr_cdapolic      CECRED.tbseg_prestamista.cdapolic%TYPE;
   vr_dtdevend      CECRED.tbseg_prestamista.dtdevend%TYPE;
   vr_dtinivig      CECRED.tbseg_prestamista.dtinivig%TYPE;
   vr_pielimit      CECRED.tbseg_prestamista.vlpielimit%TYPE;
   vr_ifttlimi      CECRED.tbseg_prestamista.vlpielimit%TYPE;
     
   vr_nmrescop      CECRED.crapcop.nmrescop%TYPE;
   vr_apolice       VARCHAR2(20);
   vr_nmdircop      VARCHAR2(100);
   vr_nmarquiv      VARCHAR2(100);
   vr_nmarquivFinal VARCHAR2(100);
   vr_linha_txt     VARCHAR2(32600);
   vr_ultimoDia     DATE;
   vr_vlprodvl      NUMBER;
   vr_dtfimvig      DATE;
   vr_nr_meses      NUMBER;
   vr_cdmotcan      NUMBER;
   vr_endosso       VARCHAR2(1) := 'N';
  
   vr_dtcancelamento DATE;
   vr_dtprotocolo    DATE;
   vr_vlcaptpie      NUMERIC (15,2);
   vr_vlcaptiftt     NUMERIC (15,2);
   vr_capitalvg      NUMERIC (15,2);
   vr_modulo         VARCHAR2(50);
   vr_sub            VARCHAR2(50);
   vr_pac            VARCHAR2(10);
   vr_complemento    VARCHAR2(50);
   vr_motivo_cancel  VARCHAR2(100);
   vr_banco          VARCHAR2(100);
   vr_agencia        VARCHAR2(100);
   vr_conta_corrente VARCHAR2(100);
  
   vr_ind_arquivo utl_file.file_type;
   vr_linha          VARCHAR2(32767);
   vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0230396';
   vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0230396.sql';
   vr_ind_arq        utl_file.file_type;
   
   CURSOR cr_prestamista(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
     SELECT p.idseqtra
           ,p.cdcooper
           ,p.nrdconta
           ,decode(s.cdagenci,90,decode(w.cdagenci,90,a.cdagenci,w.cdagenci),s.cdagenci) cdagenci
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
           ,LPAD(DECODE(p.cdcooper,1,'0101',2,'0102',5,'0104',6,'0105',7,'0106',8,'0107',9,'0108',10,'0110',11,'0109',12,'0111',13,'0112',14,'0113',16,'0115'),4,0) nr_agencia
           ,SUM(p.vldevatu) over(partition by  p.cdcooper, p.nrcpfcgc ) saldo_cpf
           ,ADD_MONTHS(c.dtmvtolt, c.qtpreemp)  dtfimctr
           ,p.nrapolice
           ,p.vlpielimit
           ,p.vlifttlimi
           ,p.qtifttdias
           ,s.cdmotcan
           ,s.dtcancel
           ,s.cdsitseg
           ,w.nrctrliq##1
           ,w.nrctrliq##2
           ,w.nrctrliq##3
           ,w.nrctrliq##4
           ,w.nrctrliq##5
           ,w.nrctrliq##6
           ,w.nrctrliq##7
           ,w.nrctrliq##8
           ,w.nrctrliq##9
           ,w.nrctrliq##10
       FROM tbseg_prestamista p
           ,crapepr c
           ,crapseg s
           ,crawepr w
           ,crapass a
      WHERE p.cdcooper = pr_cdcooper
        AND c.cdcooper = p.cdcooper
        AND c.nrdconta = p.nrdconta
        AND c.nrctremp = p.nrctremp
        AND p.cdcooper = s.cdcooper
        AND p.nrdconta = s.nrdconta
        AND p.nrctrseg = s.nrctrseg
        AND c.cdcooper = w.cdcooper
        AND c.nrdconta = w.nrdconta
        AND c.nrctremp = w.nrctremp
        AND p.cdcooper = a.cdcooper
        AND p.nrdconta = a.nrdconta
        AND TRUNC(p.dtinivig) < TRUNC(SYSDATE)
        AND p.tpregist NOT IN (0)
        AND p.tpcustei = 0
        AND p.dtrefcob = '31/10/2022'
        AND p.nrproposta NOT IN ('770655718460',
                                 '770629373667',
                                 '770628746532',
                                 '770629003355',
                                 '770629082190',
                                 '770629644571',
                                 '770628805520',
                                 '770655956794',
                                 '770629379797',
                                 '770629537465',
                                 '770629680900',
                                 '770629000070',
                                 '770629375112',
                                 '770628945322',
                                 '770629153039',
                                 '770628750467',
                                 '770629231455',
                                 '770629449698',
                                 '770629439307',
                                 '770629217657',
                                 '770628811458',
                                 '770629146717',
                                 '770629380299',
                                 '770629673270',
                                 '770629001638',
                                 '770629681167',
                                 '770629218700',
                                 '770629312110',
                                 '770629267395',
                                 '770628804753',
                                 '770629672788',
                                 '770629370595',
                                 '770628945675',
                                 '770628999678',
                                 '770629230742',
                                 '770629312315',
                                 '770629229469',
                                 '770629436057',
                                 '770629371990',
                                 '770629455655',
                                 '770628806497',
                                 '770657756989',
                                 '770657205320',
                                 '770628806152',
                                 '770657205346',
                                 '770657205354')
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
     
   CURSOR cr_crapcop IS
     SELECT c.cdcooper
           ,d.dtmvtolt
           ,c.nmrescop
       FROM CECRED.crapcop c,
            CECRED.crapdat d
      WHERE c.flgativo = 1
        AND c.cdcooper IN (9,11,13)
        AND c.cdcooper <> 3
        AND c.cdcooper = d.cdcooper;

  BEGIN
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
    FOR rw_crapcop IN cr_crapcop LOOP
      vr_cdcooper := rw_crapcop.cdcooper;
      vr_nmrescop := rw_crapcop.nmrescop;
      vr_dtmvtolt := rw_crapcop.dtmvtolt;
        
      OPEN cr_seg_parametro_prst(pr_cdcooper => vr_cdcooper,
                                 pr_tpcustei => 0);
        FETCH cr_seg_parametro_prst INTO rw_seg_parametro_prst;
        IF cr_seg_parametro_prst%NOTFOUND THEN
          CLOSE cr_seg_parametro_prst;
          vr_dscritic := 'Não foi possível localizar taxa de pagamento da seguradora. PC_PARAMETROS_PRST';
          RAISE vr_exc_saida;
        END IF;
      CLOSE cr_seg_parametro_prst;

      vr_nrsequen := rw_seg_parametro_prst.seqarqu + 1;

      vr_endereco := rw_seg_parametro_prst.enderftp;
      vr_login    := rw_seg_parametro_prst.loginftp;
      vr_senha    := rw_seg_parametro_prst.senhaftp;
      
      vr_ultimoDia := trunc(SYSDATE,'MONTH')-1;
      
      vr_nmdircop := CECRED.GENE0001.fn_diretorio(pr_tpdireto => 'C',
                                                  pr_cdcooper => vr_cdcooper);

      IF NOT CECRED.GENE0001.fn_database_name = CECRED.GENE0001.fn_param_sistema('CRED',0,'DB_NAME_PRODUC') THEN
        vr_apolice := NVL(CECRED.GENE0001.fn_param_sistema('CRED', 0, 'APOLICE_ICATU_SEGPRE'),'77000799');
      ELSE
        vr_apolice := NVL(rw_prestamista.nrapolice,rw_seg_parametro_prst.nrapolic);
      END IF;

      vr_nmarquiv := 'TMP_AILOS_'||vr_apolice||'_'||replace(vr_nmrescop,' ','_')||'_'
                   ||REPLACE(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '') || '_' ||
                     gene0002.fn_mask(vr_nrsequen, '99999') || '.csv';

      vr_nmarquivFinal := 'AILOS_'||vr_apolice||'_'||replace(vr_nmrescop,' ','_')||'_'
                   ||REPLACE(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '') || '_' ||
                     gene0002.fn_mask(vr_nrsequen, '99999') || '.csv';

      CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop || '/arq/'
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
        ||'Competencia do movimento,Motivo do cancelamento do risco,Cooperativa,Banco,Agencia,Numero Conta Corrente,PAC';
      
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);
      vr_linha_txt := '';
      
      FOR rw_prestamista IN cr_prestamista(pr_cdcooper => vr_cdcooper) LOOP        
        vr_vlsdeved   := rw_prestamista.saldo_cpf;
        vr_vlsdatua   := rw_prestamista.vldevatu;
        vr_tpregist   := rw_prestamista.tpregist;
        vr_cdapolic   := rw_prestamista.cdapolic;
        vr_nrproposta := NVL(rw_prestamista.nrproposta,0);
        vr_dtdevend   := rw_prestamista.dtdevend;
        vr_dtinivig   := rw_prestamista.dtinivig;
        vr_dtfimvig   := rw_prestamista.dtfimvig;
        vr_endosso    := 'S';
        vr_cdmotcan   := NULL;
        vr_motivo_cancel := NULL;

        IF rw_prestamista.dtfimvig IS NULL THEN
          vr_dtfimvig := rw_prestamista.dtfimctr;
        END IF;

        vr_tiporeg := CASE WHEN vr_tpregist = 1
                         THEN 'I'
                      WHEN vr_tpregist = 2
                         THEN 'C'
                      WHEN vr_tpregist = 3
                         THEN 'A'
                      END;

        vr_dtcancelamento := NULL;

        IF vr_tpregist = 2 THEN
           vr_dtcancelamento := vr_ultimoDia;
           vr_dtinivig := vr_ultimoDia;
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

        vr_vlprodvl := rw_prestamista.vlprodut;

        IF vr_vlprodvl < 0.01 THEN
          vr_vlprodvl:= 0.01;
        END IF;
        
        IF rw_prestamista.cdcooper = '9' AND rw_prestamista.nrproposta = '770629267000' THEN
          SELECT TO_NUMBER(p.nrproposta) INTO vr_nrproposta 
            FROM CECRED.tbseg_nrproposta p
           WHERE p.dhseguro IS NULL
             AND p.tpcustei = 0
             AND rownum = 1 FOR UPDATE;
         
          UPDATE CECRED.tbseg_nrproposta
             SET dhseguro = SYSDATE
           WHERE nrproposta = vr_nrproposta;
           
          vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.nrproposta = ''' || rw_prestamista.nrproposta || ''''
                      || '  WHERE p.idseqtra = ' || rw_prestamista.idseqtra || ';';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
          
          vr_linha :=    ' UPDATE CECRED.crawseg p   '
                      || '    SET p.vr_nrproposta = ''' || rw_prestamista.nrproposta || ''''
                      || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                      || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                      || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg || ';';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
          
          UPDATE CECRED.tbseg_prestamista p
             SET p.nrproposta = vr_nrproposta
           WHERE p.idseqtra = rw_prestamista.idseqtra;
           
          UPDATE CECRED.crawseg w
             SET w.nrproposta = vr_nrproposta
           WHERE w.cdcooper = rw_prestamista.cdcooper
             AND w.nrdconta = rw_prestamista.nrdconta
             AND w.nrctrseg = rw_prestamista.nrctrseg;
             
          COMMIT;
        ELSIF rw_prestamista.cdcooper = '13' AND rw_prestamista.nrproposta = '770628806969' THEN
          
          vr_tpregist := 1;
          
          vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.tpregist = ''' || rw_prestamista.tpregist || ''''
                      || '  WHERE p.idseqtra = ' || rw_prestamista.idseqtra || ';';
                      
          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
          
          vr_linha :=    ' UPDATE CECRED.crapseg p   '
                      || '    SET p.cdsitseg = ''' || rw_prestamista.cdsitseg || ''''
                      || '  WHERE p.cdcooper = ' || rw_prestamista.cdcooper
                      || '    AND p.nrdconta = ' || rw_prestamista.nrdconta
                      || '    AND p.nrctrseg = ' || rw_prestamista.nrctrseg || ';';
                      
          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
        
          UPDATE CECRED.tbseg_prestamista p
             SET p.tpregist = 3
           WHERE p.idseqtra = rw_prestamista.idseqtra;
           
          UPDATE CECRED.crapseg w
             SET w.cdsitseg = 1
           WHERE w.cdcooper = rw_prestamista.cdcooper
             AND w.nrdconta = rw_prestamista.nrdconta
             AND w.nrctrseg = rw_prestamista.nrctrseg;
             
        END IF;

        vr_banco           := '85';
        vr_agencia         := rw_prestamista.nr_agencia;
        vr_conta_corrente  := rw_prestamista.nrdconta;
        vr_pac             := rw_prestamista.cdcooper || LPAD(rw_prestamista.cdagenci,4,0);

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

        vr_linha_txt := vr_linha_txt || TRIM(vr_conta_corrente)|| ',';

        vr_linha_txt := vr_linha_txt || TRIM(vr_pac);
        
        CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);
        vr_seqtran := vr_seqtran + 1;
      END LOOP;
      
      CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

      
      GENE0003.pc_converte_arquivo(pr_cdcooper => vr_cdcooper
                                  ,pr_nmarquiv => vr_nmdircop || '/arq/'||vr_nmarquiv
                                  ,pr_nmarqenv => vr_nmarquiv
                                  ,pr_des_erro => vr_dscritic);

       IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro;
       END IF;

       CECRED.GENE0001.pc_OScommand_Shell(pr_des_comando => 'iconv -f ISO8859-1 -t utf-8 '||vr_nmdircop || '/converte/' || vr_nmarquiv||
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
         vr_dscritic := 'Erro ao processar arquivo via FTP - Cooperativa: ' || vr_cdcooper || ' - ' || vr_dscritic;
         dbms_output.put_line('Erro: ' || vr_dscritic);
       END IF;

       IF TRIM(vr_nmarquiv) IS NOT NULL THEN
          CECRED.GENE0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdircop||'/arq/'||vr_nmarquivFinal||' '||vr_nmdircop||'/salvar',
                                      pr_typ_saida   => vr_tipo_saida,
                                      pr_des_saida   => vr_dscritic);
       END IF;

       IF vr_tipo_saida = 'ERR' THEN
         vr_dscritic := 'Erro ao mover o arquivo - Cooperativa: ' || vr_cdcooper || ' - ' ||vr_dscritic;
         dbms_output.put_line('Erro: ' || vr_dscritic);
       END IF;
    END LOOP;
    
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
    CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
    COMMIT;
   EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro: ' || SQLERRM);
          ROLLBACK;
   END;
/
