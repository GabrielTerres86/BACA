DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0255693';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0255693_1.sql';
  vr_exc_saida      EXCEPTION;
  vcount            NUMBER;
  vr_tiporecus      CECRED.tbseg_prestamista.tprecusa;
  vr_motivorec      CECRED.tbseg_prestamista.cdmotrec;
  vr_des_xml        CLOB;
  vr_tpregist       VARCHAR2(200);
  vr_nrlinha        NUMBER(9) := 0;
  
  TYPE typ_reg_arq IS RECORD(nrproposta VARCHAR2(200),    
                           cdcooper   VARCHAR2(200),
                           nomecooper VARCHAR2(2000),
                           cpf        VARCHAR2(200),
                           cooperati  VARCHAR2(200),
                           pa         VARCHAR2(200),
                           dataassin  DATE,
                           tiporecus  NUMBER(9),
                           motivorec  NUMBER(9),
                           nmrescop   VARCHAR2(200),
                           nrdconta   VARCHAR2(20),   
                           nmprimtl   VARCHAR2(20),  
                           nrctremp   VARCHAR2(20),            
                           nrctrseg   VARCHAR2(20),
                           vlrsegur   NUMBER(20,5),
                           vlprodut   NUMBER(20,5),
                           tpseguro   NUMBER(5),
                           dtmvtolt   DATE);  

    TYPE typ_tab_arquiv IS TABLE OF typ_reg_arq INDEX BY PLS_INTEGER;
    vr_tabarquiv typ_tab_arquiv;
    
    TYPE typ_reg_totais_crrl817 IS RECORD (vlpremio  NUMBER(25,2),
                                           slddeved  NUMBER(25,2),
                                           qtdadesao PLS_INTEGER,
                                           dsadesao  VARCHAR(20));

    TYPE typ_tab_totais_crrl817 IS TABLE OF typ_reg_totais_crrl817 INDEX BY VARCHAR2(100);
    vr_totais_crrl817 typ_tab_totais_crrl817;
     
    TYPE typ_tab_lancarq IS TABLE OF NUMBER(30,10) INDEX BY PLS_INTEGER;         
    vr_tab_lancarq typ_tab_lancarq;
        
       
    TYPE typ_reg_totDAT IS RECORD (vlpremio NUMBER(25,2),
                                   slddeved NUMBER(25,2));
    
    TYPE typ_tab_sldevpac IS TABLE OF typ_reg_totDAT INDEX BY PLS_INTEGER;
    vr_tab_sldevpac typ_tab_sldevpac; 
  
  CURSOR cr_principal(pr_cdcooper CECRED.crapseg.cdcooper%TYPE) IS
    SELECT p.idseqtra
          ,p.cdcooper
          ,p.nrdconta
          ,p.nrctrseg
          ,p.nrctremp
          ,p.nrproposta
          ,p.nrcpfcgc
          ,p.vldevatu
          ,p.vlprodut
          ,a.nmprimtl
          ,a.cdagenci
          ,p.situacao   
          ,p.dtrecusa   
          ,p.tprecusa   
          ,p.cdmotrec   
          ,p.tpregist
          ,s.progress_recid   
          ,s.dtcancel
          ,s.cdsitseg
          ,s.cdopeexc
          ,s.cdageexc
          ,s.dtinsexc
          ,s.cdopecnl
      FROM CECRED.crapass a,
           CECRED.crapseg s, 
           CECRED.tbseg_prestamista p
     WHERE p.cdcooper = s.cdcooper
       AND p.nrdconta = s.nrdconta
       AND p.nrctrseg = s.nrctrseg
       AND p.cdcooper = pr_cdcooper
       AND p.cdcooper = a.cdcooper
       AND p.nrdconta = a.nrdconta
       AND p.nrproposta IN ('770359166346',
                            '770354947285',
                            '770656606983',
                            '202213815430',
                            '202213811687',
                            '770657291960',
                            '202213723509',
                            '770658232045',
                            '770355926540',
                            '770573476077',
                            '770658782240',
                            '202213764320',
                            '202213730544',
                            '770658728008',
                            '202213828455',
                            '202213823830',
                            '770658827987',
                            '770658760815',
                            '770658682687',
                            '770658748343',
                            '202213752165',
                            '770656969393',
                            '770658713345',
                            '770656991623',
                            '770658669451',
                            '202213810547',
                            '770658658310',
                            '202213789255',
                            '202213808205',
                            '770658875299',
                            '770658875280',
                            '202213829683',
                            '202213829684',
                            '202213829682',
                            '770658774387',
                            '770352241660',
                            '202213814587',
                            '770658726234',
                            '202213715013',
                            '202213744147',
                            '770658854682',
                            '202213818209',
                            '202213810639',
                            '202213829990',
                            '202213808147',
                            '770658872460',
                            '770658685856',
                            '770656807970',
                            '770658844822',
                            '202213808964',
                            '770657199656',
                            '770658858777',
                            '202213718757',
                            '770658737201',
                            '770658689940',
                            '202213723434',
                            '770658863878',
                            '770658863908',
                            '202213711142',
                            '202213818298',
                            '770656372699',
                            '770657015270',
                            '770658664417',
                            '202213813883',
                            '202213813885',
                            '770658712136',
                            '770656521562',
                            '202213794333',
                            '202213794334',
                            '770656577398',
                            '770658861930',
                            '770658861948',
                            '770658861921',
                            '770658861956',
                            '770658704974',
                            '770658795007',
                            '770656837330',
                            '770354570432',
                            '202213814586',
                            '202213814667',
                            '770658736159',
                            '770658871099',
                            '202213743861',
                            '770658653628',
                            '770658811924',
                            '770658780921',
                            '770658869841',
                            '770658869850',
                            '770656755407',
                            '202213804924',
                            '202213789840',
                            '202213805679',
                            '770658846248',
                            '770658846256',
                            '770658846264',
                            '770658846272',
                            '770350561927',
                            '770658877283',
                            '770658861522',
                            '770658866125',
                            '770658682008',
                            '770658662457',
                            '202213794138',
                            '770658670743',
                            '770658758675',
                            '202213828449',
                            '770658738852',
                            '202213770231',
                            '770658840290',
                            '770658836293',
                            '202213791212',
                            '202213791211',
                            '770658866540',
                            '770656709596',
                            '770658662244',
                            '770658704702',
                            '770658673157',
                            '202213813939',
                            '770658750470');

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,c.nmrescop
          ,d.dtmvtolt
      FROM CECRED.crapcop c,
           CECRED.crapdat d
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3
       AND c.cdcooper = d.cdcooper;

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
        CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'03.Erro: ' || vr_dscritic);
    END;

  PROCEDURE pc_leitor(pr_nrproposta IN VARCHAR2,
                      pr_tipo       OUT CECRED.tbseg_prestamista.tprecusa,
                      pr_motivo     OUT CECRED.tbseg_prestamista.cdmotrec) IS
                      
  vr_proposta_idx  CECRED.tbseg_prestamista.nrproposta;
  vr_tipo_idx      CECRED.tbseg_prestamista.tprecusa;
  vr_motivo_idx    CECRED.tbseg_prestamista.cdmotrec;
  vr_separador_idx VARCHAR2(1000);

  vr_texto varchar2(20000) := '770359166346#8$207,
770354947285#8$207,
770656606983#8$193,
202213815430#8$193,
202213811687#8$193,
770657291960#8$207,
202213723509#8$193,
770658232045#8$193,
770355926540#8$207,
770573476077#8$207,
770658782240#8$193,
202213764320#8$193,
202213730544#8$143,
770658728008#8$193,
202213828455#8$193,
202213823830#8$193,
770658827987#8$193,
770658760815#8$193,
770658682687#8$193,
770658748343#8$193,
202213752165#8$193,
770656969393#8$193,
770658713345#8$193,
770656991623#8$193,
770658669451#8$193,
202213810547#8$193,
770658658310#8$193,
202213789255#8$193,
202213808205#8$193,
770658875299#8$193,
770658875280#8$143,
202213829683#8$143,
202213829684#8$143,
202213829682#8$193,
770658774387#8$193,
770352241660#8$143,
202213814587#8$193,
770658726234#8$193,
202213715013#8$193,
202213744147#8$193,
770658854682#8$193,
202213818209#8$193,
202213810639#8$193,
202213829990#8$193,
202213808147#8$193,
770658872460#8$193,
770658685856#8$193,
770656807970#8$193,
770658844822#8$193,
202213808964#8$193,
770657199656#8$193,
770658858777#8$193,
202213718757#8$193,
770658737201#8$193,
770658689940#8$143,
202213723434#8$193,
770658863878#8$193,
770658863908#8$193,
202213711142#7$75,
202213818298#8$193,
770656372699#8$193,
770657015270#8$193,
770658664417#8$193,
202213813883#8$143,
202213813885#8$193,
770658712136#8$193,
770656521562#8$193,
202213794333#8$143,
202213794334#8$193,
770656577398#8$143,
770658861930#8$193,
770658861948#8$193,
770658861921#8$193,
770658861956#8$193,
770658704974#8$193,
770658795007#8$193,
770656837330#8$193,
770354570432#8$143,
202213814586#8$193,
202213814667#8$143,
770658736159#8$143,
770658871099#8$193,
202213743861#8$193,
770658653628#8$193,
770658811924#8$193,
770658780921#8$193,
770658869841#8$193,
770658869850#8$143,
770656755407#8$143,
202213804924#7$75,
202213789840#7$75,
202213805679#8$193,
770658846248#8$193,
770658846256#8$193,
770658846264#8$193,
770658846272#8$193,
770350561927#8$143,
770658877283#8$193,
770658861522#7$75,
770658866125#8$193,
770658682008#8$193,
770658662457#8$193,
202213794138#8$193,
770658670743#8$193,
770658758675#8$193,
202213828449#8$193,
770658738852#8$193,
202213770231#8$193,
770658840290#8$193,
770658836293#8$193,
202213791212#8$193,
202213791211#8$193,
770658866540#8$193,
770656709596#8$193,
770658662244#8$193,
770658704702#8$193,
770658673157#8$193,
202213813939#8$193,
770658750470#8$193,';
BEGIN
  vr_proposta_idx  := INSTR(vr_texto, pr_nrproposta);
  vr_separador_idx := INSTR(vr_texto, ',', vr_proposta_idx);
  vr_tipo_idx      := INSTR(vr_texto, '#', vr_proposta_idx);
  vr_motivo_idx    := INSTR(vr_texto, '$', vr_proposta_idx);

  pr_tipo     := SUBSTR(vr_texto,
                        vr_tipo_idx + 1,
                        vr_motivo_idx - vr_tipo_idx - 1);
  pr_motivo   := SUBSTR(vr_texto,
                        vr_motivo_idx + 1,
                        vr_separador_idx - vr_motivo_idx - 1);
END;

  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
  BEGIN
     dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
  END pc_escreve_xml;    

  PROCEDURE pc_gera_relatorio(pr_tabarquiv typ_tab_arquiv
                             ,pr_cdcooper  CECRED.crapcop.cdcooper%TYPE 
                             ,pr_dscritic  OUT NOCOPY VARCHAR2
                             ,pr_relatorio NUMBER) IS   
                             
    vr_dir_relatorio VARCHAR2(100);
    vr_relatorio     VARCHAR2(100);
    vr_motivorecusa  VARCHAR2(200);    
    vr_countxml      NUMBER := 0;
    vr_cdprogra      CONSTANT CECRED.crapprg.cdprogra%TYPE := 'JB_ARQPRST';
    vr_vlenviad      NUMBER(20,5);
    vr_vlprodut      NUMBER(20,5);    
    vr_vltotarq      NUMBER(20,5);
    vr_vltotpag      NUMBER(20,5);
    vr_index         VARCHAR2(50);
 
   BEGIN
      vr_relatorio := 'crrl'||to_char(pr_relatorio);
      vr_countxml := 0;
      vr_tab_sldevpac.delete;
      vr_totais_crrl817.delete;
      vr_tpregist := 'RECUSAS';      
      vr_vltotarq  := 0;
      vr_vlenviad  := 0;
      vr_vlprodut  := 0;
      
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);          
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><'||vr_relatorio||'><dados>');
      
      FOR I IN pr_tabarquiv.first .. pr_tabarquiv.last LOOP                                 
        IF vr_tabarquiv(I).cdcooper = pr_cdcooper THEN          
          vr_countxml := vr_countxml+1;
          pr_dscritic := ''; 
           
          BEGIN
            SELECT CECRED.gene0007.fn_caract_especial(dsmotivo) 
              INTO vr_motivorecusa  
              FROM CECRED.tbseg_prst_mot_recusa
             WHERE idmotivo = vr_tabarquiv(I).motivorec;   
          EXCEPTION
            WHEN OTHERS then
              vr_motivorecusa := '';
          END;
          
          pc_escreve_xml('<registro>'||
                         '<nmrescop>'    ||vr_tabarquiv(I).nmrescop   ||'</nmrescop>'    ||
                         '<nrdconta>'    ||vr_tabarquiv(I).nrdconta   ||'</nrdconta>'    ||
                         '<cdagenci>'    ||vr_tabarquiv(I).pa         ||'</cdagenci>'    ||
                         '<nrcpfcgc>'    ||vr_tabarquiv(I).cpf        ||'</nrcpfcgc>'    ||
                         '<nmprimtl>'    ||vr_tabarquiv(I).nmprimtl   ||'</nmprimtl>'    ||
                         '<nrctremp>'    ||vr_tabarquiv(I).nrctremp   ||'</nrctremp>'    ||
                         '<nrctrseg>'    ||vr_tabarquiv(I).nrctrseg   ||'</nrctrseg>'    ||                         
                         '<nrproposta>'  ||vr_tabarquiv(I).nrproposta ||'</nrproposta>'  ||
                         '<motivorecusa>'||vr_motivorecusa            ||'</motivorecusa>'||                           
                         '<vlsdeved>'    ||to_char( vr_tabarquiv(I).vlrsegur , 'FM99G999G999G999G999G999G999G990D00')||'</vlsdeved>'||
                         '<tprecusa>'    ||vr_tabarquiv(I).tiporecus||'</tprecusa>'||
                        '</registro>');   

          vr_vlenviad := vr_tabarquiv(I).vlrsegur; 
          vr_vlprodut := vr_tabarquiv(I).vlprodut; 
          
          IF NOT vr_totais_crrl817.EXISTS(vr_tpregist) THEN
            vr_totais_crrl817(vr_tpregist).qtdadesao := 0;
            vr_totais_crrl817(vr_tpregist).slddeved  := 0;
            vr_totais_crrl817(vr_tpregist).vlpremio  := 0;
            vr_totais_crrl817(vr_tpregist).dsadesao  := vr_tpregist;
          END IF;
          
          vr_totais_crrl817(vr_tpregist).slddeved  := vr_totais_crrl817(vr_tpregist).slddeved + vr_vlenviad;
          vr_totais_crrl817(vr_tpregist).vlpremio  := vr_totais_crrl817(vr_tpregist).vlpremio + vr_vlprodut;
          vr_totais_crrl817(vr_tpregist).qtdadesao := vr_totais_crrl817(vr_tpregist).qtdadesao + 1;
           
          IF NOT vr_tab_sldevpac.EXISTS(vr_tabarquiv(I).pa ) THEN
               vr_tab_sldevpac(vr_tabarquiv(I).pa ).slddeved := 0;
               vr_tab_sldevpac(vr_tabarquiv(I).pa ).vlpremio := 0;
          END IF;
          
          vr_tab_sldevpac(vr_tabarquiv(I).pa ).slddeved := vr_tab_sldevpac(vr_tabarquiv(I).pa ).slddeved + vr_vlenviad;
          vr_tab_sldevpac(vr_tabarquiv(I).pa ).vlpremio := vr_tab_sldevpac(vr_tabarquiv(I).pa ).vlpremio + vr_vlprodut;
          vr_vltotarq := vr_vltotarq + vr_vlenviad;
        END IF; 
      END LOOP;                 
      pc_escreve_xml('</dados>');
            
      pc_escreve_xml('<totais>');        
      vr_vltotpag := 0;
      
      vr_index := vr_totais_crrl817.first;
      WHILE vr_index IS NOT NULL LOOP
        IF vr_totais_crrl817.EXISTS(vr_index) = TRUE THEN                  
         pc_escreve_xml('<registro>'||
                   '<dsadesao>' ||NVL(vr_totais_crrl817(vr_index).dsadesao,' ')
                                   ||'</dsadesao>' ||
                   '<vlpremio>' || to_char(NVL(vr_totais_crrl817(vr_index).vlpremio,'0'),
                                 'FM99G999G999G999G999G999G999G990D00')||'</vlpremio>' ||
                   '<slddeved>'||to_char(NVL(vr_totais_crrl817(vr_index).slddeved, '0'),
                                 'FM99G999G999G999G999G999G999G990D00')||'</slddeved>' ||
                   '<qtdadesao>'||NVL(vr_totais_crrl817(vr_index).qtdadesao,0)||
                                                                        '</qtdadesao>'||
                 '</registro>');
                 vr_vltotpag := vr_vltotpag + vr_totais_crrl817(vr_index).vlpremio ;
         END IF;
         vr_index := vr_totais_crrl817.next(vr_index);
      END LOOP;
      
      pc_escreve_xml('</totais>');
      vr_tab_lancarq.delete;
                  
      pc_escreve_xml( '<totpac vltotdiv="'||to_char(vr_vltotarq,'fm999g999g999g990d00')||'"'
       ||' vlttpgto="'|| to_char(NVL(vr_vltotpag,0) ,'FM99G999G999G999G999G999G999G990D00')||'">');
      vr_index := vr_totais_crrl817.first;      
              
      IF vr_tab_sldevpac.COUNT > 0 THEN
        FOR vr_cdagenci IN vr_tab_sldevpac.FIRST..vr_tab_sldevpac.LAST LOOP
          IF vr_tab_sldevpac.EXISTS(vr_cdagenci) THEN
               pc_escreve_xml('<registro>'
                             ||'<cdagenci>'||LPAD(vr_cdagenci,3,' ')||
                               '</cdagenci>'||
                               '<sldevpac>'||to_char(vr_tab_sldevpac(vr_cdagenci).slddeved,
                                   'FM99G999G999G999G999G999G999G990D00')||'</sldevpac>'||
                               '<slpgtopac>'||to_char(vr_tab_sldevpac(vr_cdagenci).vlpremio,
                                   'FM99G999G999G999G999G999G999G990D00')||'</slpgtopac>'                              
                             ||'</registro>');  
            vr_tab_lancarq(vr_cdagenci) := vr_tab_sldevpac(vr_cdagenci).vlpremio;
          END IF;
        END LOOP;
        pc_escreve_xml('</totpac>');          
      END IF;
      
      pc_escreve_xml('</'||vr_relatorio||'>');

      IF vr_countxml > 0 THEN
        vr_dir_relatorio := CECRED.gene0001.fn_diretorio('C', pr_cdcooper, 'rl') || '/'||vr_relatorio||'.lst';

        CECRED.gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper              
                                   ,pr_cdprogra  => vr_cdprogra              
                                   ,pr_dtmvtolt  => trunc(sysdate)           
                                   ,pr_dsxml     => vr_des_xml               
                                   ,pr_dsxmlnode => '/'||vr_relatorio        
                                   ,pr_dsjasper  => vr_relatorio||'.jasper'  
                                   ,pr_dsparams  => NULL                     
                                   ,pr_dsarqsaid => vr_dir_relatorio         
                                   ,pr_cdrelato  => pr_relatorio
                                   ,pr_flg_gerar => 'S'
                                   ,pr_qtcoluna  => 234
                                   ,pr_sqcabrel  => 1
                                   ,pr_nmformul  => '234col'
                                   ,pr_flg_impri => 'S'
                                   ,pr_nrcopias  => 1
                                   ,pr_nrvergrl  => 1
                                   ,pr_des_erro  => pr_dscritic);
                                           
      END IF;     
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

      FOR rw_crapcop IN cr_crapcop LOOP
        vcount := 0;
        vr_linha := '';

        FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP

          vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                      || '    SET p.situacao    = ''' || rw_principal.situacao || ''''
                      || '       ,p.dtrecusa = TO_DATE(''' || rw_principal.dtrecusa || ''',''DD/MM/RRRR'')'
                      || '       ,p.tprecusa    = ''' || rw_principal.tprecusa || ''''
                      || '       ,p.cdmotrec    = ''' || rw_principal.cdmotrec || ''''
                      || '       ,p.tpregist    = ''' || rw_principal.tpregist || ''''
                      || '  WHERE p.idseqtra = ' || rw_principal.idseqtra || ';';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

          vr_linha :=    ' UPDATE CECRED.crapseg p   '
                      || '    SET p.cdsitseg    = ''' || rw_principal.cdsitseg || ''''
                      || '       ,p.dtcancel = TO_DATE(''' || rw_principal.dtcancel || ''',''DD/MM/RRRR'')'
                      || '       ,p.cdopeexc    = ''' || rw_principal.cdopeexc || ''''
                      || '       ,p.cdageexc    = ''' || rw_principal.cdageexc || ''''
                      || '       ,p.dtinsexc = TO_DATE(''' || rw_principal.dtinsexc || ''',''DD/MM/RRRR'')'
                      || '       ,p.cdopecnl = ''' || rw_principal.cdopecnl || ''''
                      || '  WHERE p.progress_recid = ' || rw_principal.progress_recid || ';';

          CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
          
          pc_leitor(pr_nrproposta => rw_principal.nrproposta,
                    pr_tipo       => vr_tiporecus,
                    pr_motivo     => vr_motivorec);          

          UPDATE CECRED.tbseg_prestamista p
            SET p.situacao = 0
               ,p.dtrecusa = TO_DATE(SYSDATE,'DD/MM/RRRR')
               ,p.tprecusa = 'Ajuste via script INC0255693, tipo:  ' || vr_tiporecus
               ,p.cdmotrec = vr_motivorec
               ,p.tpregist = 0 
          WHERE p.idseqtra = rw_principal.idseqtra;

          UPDATE CECRED.crapseg p
             SET p.dtcancel = TO_DATE(rw_crapcop.dtmvtolt,'DD/MM/RRRR'),
                 p.cdsitseg = 5,
                 p.cdopeexc = '1',
                 p.cdageexc = 1,
                 p.dtinsexc = TO_DATE(rw_crapcop.dtmvtolt,'DD/MM/RRRR'),
                 p.cdopecnl = '1'
           WHERE p.progress_recid = rw_principal.progress_recid;
           
          vr_nrlinha := vr_nrlinha + 1;
           
          vr_tabarquiv(vr_nrlinha).nrproposta   := rw_principal.nrproposta;
          vr_tabarquiv(vr_nrlinha).cpf          := rw_principal.nrcpfcgc;
          vr_tabarquiv(vr_nrlinha).tiporecus    := vr_tiporecus;
          vr_tabarquiv(vr_nrlinha).motivorec    := vr_motivorec;
          vr_tabarquiv(vr_nrlinha).vlrsegur     := rw_principal.vldevatu;
          vr_tabarquiv(vr_nrlinha).vlprodut     := rw_principal.vlprodut;
          vr_tabarquiv(vr_nrlinha).cdcooper     := rw_principal.cdcooper;
          vr_tabarquiv(vr_nrlinha).nrctrseg     := rw_principal.nrctrseg;
          vr_tabarquiv(vr_nrlinha).nrdconta     := rw_principal.nrdconta; 
          vr_tabarquiv(vr_nrlinha).nmrescop     := rw_crapcop.nmrescop;
          vr_tabarquiv(vr_nrlinha).nmprimtl     := rw_principal.nmprimtl;      
          vr_tabarquiv(vr_nrlinha).dtmvtolt     := rw_crapcop.dtmvtolt;
          vr_tabarquiv(vr_nrlinha).nrctremp     := rw_principal.nrctremp;                      
          vr_tabarquiv(vr_nrlinha).pa           := rw_principal.cdagenci;
         
          IF vcount = 1000 THEN
            COMMIT;
          ELSE
            vcount := vcount + 1;
          END IF;
        END LOOP;
        
        vr_dscritic := NULL;
        
        pc_gera_relatorio(pr_tabarquiv => vr_tabarquiv
                         ,pr_cdcooper  => rw_crapcop.cdcooper
                         ,pr_dscritic  => vr_dscritic
                         ,pr_relatorio => 817);

        COMMIT;
      END LOOP;

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
      CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
    EXCEPTION
       WHEN vr_exc_saida THEN
            vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'01.Erro: ' || vr_dscritic);
            dbms_output.put_line(vr_dscritic);
            ROLLBACK;
       WHEN OTHERS THEN
            vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'02.Erro: ' || vr_dscritic);
            dbms_output.put_line(vr_dscritic);
            ROLLBACK;
    END;
/
