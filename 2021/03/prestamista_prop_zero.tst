PL/SQL Developer Test script 3.0
1213
/*
Preencher numero da proposta Icatu dos registros que não possuem
*/
declare 
  vr_nrproposta varchar2(30);
  vr_excsaida EXCEPTION;  
  -- Local variables here
  cursor cr_crapcop is 
  select p.cdcooper,
         (SELECT dat.dtmvtolt                
            FROM crapdat dat 
           WHERE dat.cdcooper = p.cdcooper) dtmvtolt 
   from crapcop p where p.flgativo = 1 and p.cdcooper <> 3;
  
  -- wseg > 0 e tbseg = 0
  cursor cr_registros(pr_cdcooper in number) is 
  SELECT *
  FROM (SELECT epr.nrctremp,
               epr.nrdconta,
               epr.vlsdeved,             
               ass.nrcpfcgc,
               ass.nmprimtl,
               ass.cdagenci,
               ass.cdcooper,
               epr.dtmvtolt,
               g.nrproposta prop_wseg,
               g.progress_recid rec_id_wseg
          FROM crapepr epr, crapass ass, craplcr lcr, crawseg g
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.cdcooper = epr.cdcooper
           AND ass.nrdconta = epr.nrdconta
           AND lcr.cdcooper = epr.cdcooper
           AND lcr.cdlcremp = epr.cdlcremp
           AND ass.inpessoa = 1 --> Somente fisica          
           AND epr.dtmvtolt >= to_date('01/07/2020', 'DD/MM/YYYY')
           AND lcr.flgsegpr = 1
           and g.cdcooper = epr.cdcooper
           and g.nrdconta = epr.nrdconta
           and g.nrctrato = epr.nrctremp                      
           and nvl(g.nrproposta,0) = 0) EPR
 order by epr.cdcooper, epr.nrdconta;
 
   -- tbseg = 0 e wseg > 0
 cursor cr_registros_tbseg(pr_cdcooper in number) is 
  SELECT *
  FROM (SELECT epr.nrctremp,
               epr.nrdconta,
               ass.cdcooper,
               epr.dtmvtolt,
               g.nrproposta,
               g.idseqtra
          FROM crapepr epr, crapass ass, craplcr lcr, tbseg_prestamista g
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.cdcooper = epr.cdcooper
           AND ass.nrdconta = epr.nrdconta
           AND lcr.cdcooper = epr.cdcooper
           AND lcr.cdlcremp = epr.cdlcremp
           AND ass.inpessoa = 1 --> Somente fisica           
           AND epr.dtmvtolt >= to_date('01/07/2020', 'DD/MM/YYYY')
           AND lcr.flgsegpr = 1           
           and g.cdcooper = epr.cdcooper
           and g.nrdconta = epr.nrdconta
           and g.nrctremp = epr.nrctremp                      
           and nvl(g.nrproposta,0) = 0) EPR
 order by epr.cdcooper, epr.nrdconta;
  -- wseg = 0 e tbseg = 0
  cursor cr_registros_todos(pr_cdcooper in number) is 
  SELECT *
  FROM (SELECT epr.nrctremp,
               epr.nrdconta,                             
               ass.nrcpfcgc,
               ass.nmprimtl,
               ass.cdagenci,
               ass.cdcooper,
               epr.dtmvtolt,
               g.nrproposta,
               g.idseqtra,
               wseg.progress_recid
          FROM crapepr epr, crapass ass, craplcr lcr, tbseg_prestamista g, crawseg wseg
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.cdcooper = epr.cdcooper
           AND ass.nrdconta = epr.nrdconta
           AND lcr.cdcooper = epr.cdcooper
           AND lcr.cdlcremp = epr.cdlcremp
           AND ass.inpessoa = 1 --> Somente fisica         
           AND epr.dtmvtolt >= to_date('01/07/2020', 'DD/MM/YYYY')
           AND lcr.flgsegpr = 1
           and g.cdcooper = epr.cdcooper
           and g.nrdconta = epr.nrdconta
           and g.nrctremp = epr.nrctremp                      
           and nvl(g.nrproposta,0) = 0
           and wseg.cdcooper = epr.cdcooper
           and wseg.nrdconta = epr.nrdconta
           and wseg.nrctrato = epr.nrctremp                      
           and nvl(wseg.nrproposta,0) = 0) EPR
 order by epr.cdcooper, epr.nrdconta; 
  
    CURSOR cr_prestamista(pr_cdcooper IN tbseg_prestamista.cdcooper%TYPE
                         ,pr_nrdconta IN tbseg_prestamista.nrdconta%TYPE
                         ,pr_nrctremp IN tbseg_prestamista.nrctremp%TYPE) IS
      SELECT t.*
        FROM tbseg_prestamista t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta        
         AND t.nrctremp = pr_nrctremp;
    rw_prestamista cr_prestamista%ROWTYPE;
    
    CURSOR cr_crawseg(pr_cdcooper IN tbseg_prestamista.cdcooper%TYPE
                     ,pr_nrdconta IN tbseg_prestamista.nrdconta%TYPE
                     ,pr_nrctremp IN tbseg_prestamista.nrctremp%TYPE) IS
      SELECT t.*
        FROM crawseg t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta        
         AND t.nrctrato = pr_nrctremp
         and t.cdsegura = 514;
    rw_crawseg cr_crawseg%ROWTYPE;    
    
    CURSOR cr_prestamista_prop_zero(pr_cdcooper IN tbseg_prestamista.cdcooper%TYPE) IS
      SELECT t.*
        FROM tbseg_prestamista t
       WHERE t.cdcooper = pr_cdcooper
        and t.tpregist in (1,3) 
        and nvl(t.nrproposta,0) = 0;
    rw_prestamista_prop_zero cr_prestamista_prop_zero%ROWTYPE;
    
    cursor cr_registros_sem_tbseg(pr_cdcooper in number) is 
    SELECT EPR.*              
        FROM (
        SELECT epr.nrctremp
              ,epr.nrdconta
              ,epr.vlsdeved
              ,substr((SELECT dstextab
                        from craptab b
                       where b.cdcooper = epr.cdcooper
                         and b.cdempres = 11
                         and b.cdacesso = 'SEGPRESTAM'
                         and b.tpregist = 0),
                      27,
                      12) vlminimo
            ,SUM( epr.vlsdeved) OVER(PARTITION BY epr.nrdconta )  Saldo_Devedor
              ,ass.nrcpfcgc
              ,ass.nmprimtl
              ,ass.cdagenci
              ,ass.cdcooper
              ,epr.dtmvtolt
          FROM crapepr epr
              ,crapass ass
              ,craplcr lcr
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.cdcooper = epr.cdcooper
           AND ass.nrdconta = epr.nrdconta
           AND lcr.cdcooper = epr.cdcooper
           AND lcr.cdlcremp = epr.cdlcremp
           AND ass.inpessoa = 1 --> Somente fisica
           AND epr.inliquid = 0 --> Em aberto
           AND epr.inprejuz = 0 --> Sem prejuizo
           AND epr.dtmvtolt >= '01/07/2020'
           AND lcr.flgsegpr = 1
      ) EPR WHERE Saldo_Devedor > vlminimo and                                                        
           NOT EXISTS (SELECT seg.idseqtra
                         FROM tbseg_prestamista seg
                        WHERE seg.cdcooper = epr.cdcooper
                          AND seg.nrdconta = epr.nrdconta
                          AND seg.nrctremp = epr.nrctremp);    
 
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0080242';
  -- Arquivo de rollback
  vr_nmarqimp        VARCHAR2(100)  := 'INC0080242_ROLLBACK.txt';   
  vr_ind_arquiv      utl_file.file_type;
  -- Relacao de registros criados
  vr_nmarqimp2        VARCHAR2(100)  := 'INC0080242_relacao.csv';   
  vr_ind_arquiv2      utl_file.file_type;
  vr_destinatario_email varchar2(500):= gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_EMAIL'); -- seguros@ailos.com.br
 
 ----------------------------------------------------------------
 TYPE typ_reg_crrl815 IS
    RECORD (cdcooper tbseg_prestamista.cdcooper%TYPE
           ,nrdconta tbseg_prestamista.nrdconta%TYPE
           ,dtmvtolt crapdat.dtmvtolt%TYPE
           ,dtinivig crapdat.dtmvtolt%TYPE
           ,dtrefcob crapdat.dtmvtolt%TYPE
           ,nmrescop crapcop.nmrescop%TYPE
           ,vlenviad NUMBER(25,2)
           ,dsregist VARCHAR2(20)
           ,inpessoa PLS_INTEGER
           ,tpregist tbseg_prestamista.tpregist%TYPE
           ,nmprimtl tbseg_prestamista.nmprimtl%TYPE
           ,nrcpfcgc tbseg_prestamista.nrcpfcgc%TYPE
           ,nrctrseg  varchar2(15)
           ,nrctremp tbseg_prestamista.nrctremp%TYPE
           ,vlprodut tbseg_prestamista.vlprodut%TYPE
           ,vlsdeved tbseg_prestamista.vlsdeved%TYPE);

    -- Definicao do tipo de tabela para o relatorio 815
    TYPE typ_tab_crrl815 IS
    TABLE OF typ_reg_crrl815
    INDEX BY VARCHAR2(30);

    vr_crrl815 typ_tab_crrl815 ; 
    vr_tab_crrl815 typ_tab_crrl815;

    TYPE pl_tipo_registros IS
    RECORD (tpregist VARCHAR2(20));

    TYPE typ_registros IS
    TABLE OF pl_tipo_registros
    INDEX BY PLS_INTEGER;

    vr_tipo_registro typ_registros;
    
    TYPE typ_reg_totais_crrl815 IS
    RECORD (vlpremio NUMBER(25,2),
            slddeved NUMBER(25,2),
            qtdadesao PLS_INTEGER,
            dsadesao VARCHAR(20));

    TYPE typ_tab_totais_crrl815 IS
    TABLE OF typ_reg_totais_crrl815
    INDEX BY VARCHAR2(100);

    vr_totais_crrl815 typ_tab_totais_crrl815;
    
    -- Tratamento de erros   
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);
    vr_exc_erro  EXCEPTION;
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'JB_ARQPRST';

    -- Cursor generico de calendario
    vr_dtmvtolt  crapdat.dtmvtolt%type;
    vr_cdcooper  crapcop.cdcooper%TYPE;
    
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
    
    vr_typ_saida    VARCHAR2(100);
    vr_des_saida    VARCHAR2(2000);
  
    vr_nmdircop   VARCHAR2(4000); 
    vr_nmarquiv   varchar2(100);
    -- Declarando handle do Arquivo
    vr_ind_arquivo utl_file.file_type;
    vr_index varchar2(50);
    vr_saldo_devedor number;
    
    vr_dsdemail VARCHAR2(100);
    vr_index_815 PLS_INTEGER := 0;
    vr_des_xml CLOB;
    vr_dsadesao VARCHAR2(100);
    vr_dir_relatorio_815 VARCHAR2(100);
    vr_arqhandle utl_file.file_type;
 
 ----------------------------------------------------------------
 ----------------------------------------------------------------
  --Procedure que escreve linha no arquivo CLOB
 PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
    BEGIN
      --Escrever no arquivo CLOB
      dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
 END pc_escreve_xml;
 
 PROCEDURE pc_gera_arquivo_coop(pr_cdcooper IN crapcop.cdcooper%TYPE
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada)
    BEGIN
      DECLARE
        vr_exc_saida  EXCEPTION;
        vr_tipo_saida VARCHAR2(100);

        rw_craptab   btch0001.cr_craptab%ROWTYPE;
        
        vr_nrsequen  NUMBER(5);
        vr_endereco  VARCHAR2(100);    
        vr_login     VARCHAR2(100);
        vr_senha     VARCHAR2(100);
        vr_seqtran   INTEGER;
        vr_vlsdatua  NUMBER;
        vr_vlminimo  NUMBER;
        vr_vlsdeved  NUMBER := 0;
        vr_tpregist  INTEGER;
        vr_NRPROPOSTA tbseg_prestamista.NRPROPOSTA%TYPE;
        vr_cdapolic  tbseg_prestamista.cdapolic%TYPE;
        vr_dtdevend  tbseg_prestamista.dtdevend%TYPE;
        vr_dtinivig  tbseg_prestamista.dtinivig%TYPE;
        vr_dtrefcob  tbseg_prestamista.dtrefcob%type;
        vr_flgnvenv  BOOLEAN;
        vr_dstextab  craptab.dstextab%TYPE; --> Busca na craptab
        vr_nrdmeses NUMBER;
        vr_nrdedias NUMBER;
        vr_contrcpf tbseg_prestamista.nrcpfcgc%TYPE;
        vr_vlenviad NUMBER;
        vr_vltotenv NUMBER;
        vr_vlmaximo NUMBER;
        vr_dscorpem VARCHAR2(2000);
        vr_nmrescop crapcop.nmrescop%TYPE;
        vr_apolice  VARCHAR2(20);
        -- Variaveis para o arquivo
        vr_nmdircop  VARCHAR2(100);
        vr_nmarquiv  VARCHAR2(100);
        vr_linha_txt VARCHAR2(32600);
        vr_xml_temp  VARCHAR2(32726) := ''; --> Temp xml/csv 
        vr_clob      CLOB; --> Clob buffer do xml gerado
        vr_ultimoDia DATE;
        -- Declarando handle do Arquivo
        vr_ind_arquivo utl_file.file_type;

    
        -- Cursor principal prestamista
        CURSOR cr_prestamista(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
          SELECT p.idseqtra
                ,p.cdcooper
                ,p.nrdconta
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
                ,p.cdprodut
                ,p.cdplapro
                ,p.vlprodut
                ,p.tpcobran
                ,p.vlsdeved
                ,p.vldevatu
                ,p.dtrefcob
                ,p.dtfimvig
                ,p.dtdenvio
                ,c.inprejuz
                ,c.inliquid
                ,p.nrproposta
                , lpad(decode(p.cdcooper , 5,1, 7,2, 10,3,  11,4, 14,5, 9,6, 16,7, 2,8, 8,9, 6,10, 12,11, 13,12, 1,13  )   ,6,'0') cdcooperativa
                ,  SUM(p.vldevatu) over(partition by  p.cdcooper, p.nrcpfcgc ) saldo_cpf
            FROM tbseg_prestamista p, crapepr c
           WHERE p.cdcooper = pr_cdcooper
             AND c.cdcooper = p.cdcooper
             AND c.nrdconta = p.nrdconta
             AND c.nrctremp = p.nrctremp
             AND p.tpregist <> 0      -- ignorar os tratamentos de cancelamento primario reenviado e adesao de liquidados
             ORDER BY p.nrcpfcgc ASC;
        rw_prestamista cr_prestamista%ROWTYPE;
                
      BEGIN
        --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        cecred.pc_log_programa(pr_dstiplog   => 'I',
                               pr_cdprograma => vr_cdprogra,
                               pr_cdcooper   => pr_cdcooper,
                               pr_tpexecucao => 2, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               pr_idprglog   => vr_idprglog);
        vr_seqtran := 1;
        
        SELECT nmrescop
          INTO vr_nmrescop
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
        
        -- Leitura dos valores de mínimo e máximo
        vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                                  pr_nmsistem => 'CRED',
                                                  pr_tptabela => 'USUARI',
                                                  pr_cdempres => 11,
                                                  pr_cdacesso => 'SEGPRESTAM',
                                                  pr_tpregist => 0);
        -- Se não encontrar
        IF vr_dstextab IS NULL THEN
          vr_vlminimo := 0;
        ELSE
          vr_vlmaximo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));
          vr_vlminimo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 27, 12));
        END IF;
      
        -- Leitura da sequencia na tab
        rw_craptab.dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                                          pr_nmsistem => 'CRED',
                                                          pr_tptabela => 'USUARI',
                                                          pr_cdempres => 11,
                                                          pr_cdacesso => 'SEGPRESTAM',
                                                          pr_tpregist => 0);
        -- Sequencia do arquivo
        vr_nrsequen := to_number(substr(rw_craptab.dstextab, 139, 5)) + 1;

        vr_apolice  := SUBSTR(vr_dstextab,146,16); -- numero apolice

        -- Dados da conexao FTP
        vr_endereco := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_ENDERECO');
        vr_login    := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_LOGIN');
        vr_senha    := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => pr_cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_SENHA');
      
      
        -- diretorio da cooperativa
        vr_nmdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', --> /usr/coop
                                             pr_cdcooper => pr_cdcooper);
        -- nome do arqquivo da cooperativa
        vr_nmarquiv := 'AILOS_'||replace(vr_nmrescop,' ','_')||'_'
                     ||REPLACE(to_char(vr_dtmvtolt , 'MM/YYYY'), '/', '_') || '_' ||
                       gene0002.fn_mask(vr_nrsequen, '99999') || '.txt';                                             
      
        -- Abre arquivo em modo de escrita (W)
        GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdircop || '/arq/'       --> Diretório do arquivo
                                ,pr_nmarquiv => vr_nmarquiv                  --> Nome do arquivo
                                ,pr_tipabert => 'W'                          --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_ind_arquivo               --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);                --> Erro
        IF vr_dscritic IS NOT NULL THEN         
          RAISE vr_exc_erro;       -- Levantar Excecao
        END IF;
      
        -- Atualiza sequencia (posições 139 a 144 do string)
        BEGIN
          UPDATE craptab
             SET craptab.dstextab = substr(craptab.dstextab, 1, 138) ||
                                    gene0002.fn_mask(vr_nrsequen, '99999') ||
                                    substr(craptab.dstextab, 144)
           WHERE craptab.cdcooper = pr_cdcooper
             AND craptab.nmsistem = 'CRED'
             AND craptab.tptabela = 'USUARI'
             AND craptab.cdempres = 11
             AND craptab.cdacesso = 'SEGPRESTAM'
             AND craptab.tpregist = 0;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar sequencia da cooperativa: ' || pr_cdcooper || ' - ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      
        -- Cabecalho do CSV
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob,
                                pr_texto_completo => vr_xml_temp,
                                pr_texto_novo     => '');
      
        vr_contrcpf := NULL;

        -- Definiçoes do programa
        FOR rw_prestamista IN cr_prestamista(pr_cdcooper => pr_cdcooper) LOOP

          vr_vlsdeved :=  rw_prestamista.saldo_cpf;
          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := vr_dscritic 
                           || ' Cooperativa: ' || pr_cdcooper 
                           || ' - Conta: ' || rw_prestamista.nrdconta 
                           || ' - Contrato Prestamista: ' || rw_prestamista.nrctrseg
                           || ' - Contrato Emprestimo: ' || rw_prestamista.nrctremp;
            RAISE vr_exc_saida;
          END IF;
        
          -- controle para o maximo nao alterar o valor enviado para cima no endosso
          IF rw_prestamista.vldevatu > rw_prestamista.vlsdeved THEN
            vr_vlsdatua := rw_prestamista.vlsdeved;
          ELSE
            vr_vlsdatua := rw_prestamista.vldevatu;
          END IF;
          
          vr_tpregist := rw_prestamista.tpregist;
          vr_cdapolic := rw_prestamista.cdapolic;
          vr_NRPROPOSTA := rw_prestamista.NRPROPOSTA;
          vr_dtdevend := rw_prestamista.dtdevend;
          vr_dtinivig := rw_prestamista.dtinivig;
          vr_flgnvenv := FALSE;
          
          if vr_tpregist = 3 then
            vr_dtrefcob := vr_dtmvtolt ;
          else
            vr_dtrefcob := rw_prestamista.dtrefcob; 
          end if;
          
          -- saldo devedor menor que o parametrizado e o cancelamento ainda nao foi feito
          IF vr_vlsdeved < vr_vlminimo AND vr_tpregist = 3 THEN
            -- cancelamento
            vr_tpregist := 2;
          ELSE             
            IF vr_vlsdeved < vr_vlminimo AND vr_tpregist IN(2, 1) THEN
               
              IF vr_tpregist = 1 THEN
                BEGIN 
                  UPDATE tbseg_prestamista
                     SET dtdenvio = vr_dtmvtolt  --rw_crapcop.dtmvtolt
                   WHERE cdcooper = pr_cdcooper
                     AND nrdconta = rw_prestamista.nrdconta
                     AND nrctrseg = rw_prestamista.nrctrseg
                     AND nrctremp = rw_prestamista.nrctremp
                     AND cdapolic = vr_cdapolic;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;   
              END IF;
              
              CONTINUE; -- nao processamos cancelados e adesoes com devedor abaixo do minimo 
            END IF;
          END IF;
          
          -- controla o cpf para agrupar os valores enviados
          IF vr_contrcpf IS NULL OR vr_contrcpf <> rw_prestamista.nrcpfcgc THEN 
            vr_contrcpf := rw_prestamista.nrcpfcgc; -- novo cpf do loop
            vr_vlenviad := vr_vlsdatua; -- novo contrato 
            vr_vltotenv := vr_vlsdatua; -- inicia novo totalizador
          ELSE
            vr_vltotenv := vr_vltotenv + vr_vlsdatua;
            IF vr_vltotenv > vr_vlmaximo THEN
              vr_vlenviad := vr_vlmaximo - (vr_vltotenv - vr_vlsdatua); -- enviamos a diferença para preencher até o maximo
              
              vr_dscorpem := 'Ola, o contrato de emprestimo abaixo ultrapassou o valor limite maximo coberto pela seguradora, segue dados:<br /><br />
                              Cooperativa: ' || vr_nmrescop || '<br />
                              Conta: '       || rw_prestamista.nrdconta || '<br />
                              Nome: '        || rw_prestamista.nmprimtl || '<br />
                              Contrato Empréstimo: '|| rw_prestamista.nrctremp || '<br />
                              Proposta seguro: '    || rw_prestamista.nrctrseg || '<br />
                              Valor Empréstimo: '   || rw_prestamista.vldevatu || '<br />
                              Valor saldo devedor total: '|| vr_vlsdeved || '<br />
                              Valor Limite Máximo: ' || vr_vlmaximo;
              
              -- Envia email
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
              vr_vlenviad := vr_vlsdatua; -- envia o valor cheio
            END IF;
          END IF;
          vr_ultimoDia := trunc(sysdate,'MONTH')-1;
          vr_linha_txt := '';
          -- informacoes para impressao
          vr_linha_txt := vr_linha_txt || LPAD(vr_seqtran, 5, 0); -- Sequencial Transação
          vr_linha_txt := vr_linha_txt || LPAD(vr_tpregist, 2, 0); -- Tipo Registro
          vr_linha_txt := vr_linha_txt || LPAD(vr_apolice, 15, 0); -- Nº Apólice / Certificado
          vr_linha_txt := vr_linha_txt || RPAD(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'), 14, ' '); -- CPF / CNPJ - sem formatacao
          vr_linha_txt := vr_linha_txt || LPAD(' ', 20, ' '); -- Cód.Empregado
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(gene0007.fn_caract_especial(rw_prestamista.nmprimtl)), 70, ' '); -- Nome completo do cliente
          vr_linha_txt := vr_linha_txt ||
                          LPAD(to_char(rw_prestamista.dtnasctl, 'YYYY-MM-DD'), 10, 0); -- Data Nascimento
          vr_linha_txt := vr_linha_txt || LPAD(rw_prestamista.cdsexotl, 2, 0); -- Sexo
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(gene0007.fn_caract_especial(rw_prestamista.dsendres)), 60, ' '); -- Endereço
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(gene0007.fn_caract_especial(rw_prestamista.nmbairro)), 30, ' '); -- Bairro
          vr_linha_txt := vr_linha_txt ||
                          RPAD(UPPER(gene0007.fn_caract_especial(rw_prestamista.nmcidade)), 30, ' '); -- Cidade
          vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.cdufresd), ' '),2,' '); -- UF
          vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_prestamista.nrcepend, 'zzzzz-zz9'), 10, ' '); -- CEP
          
          IF length(rw_prestamista.nrtelefo) = 11 THEN
            vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)99999-9999'), 15, ' '); -- Telefone Residencial
          ELSIF length(rw_prestamista.nrtelefo) = 10 THEN
            vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)9999-9999'), 15, ' '); -- Telefone Residencial
          ELSE
            vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_prestamista.nrtelefo, '99999-9999'), 15, ' '); -- Telefone Residencial
          END IF;
          
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Telefone Comercial
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Telefone Celular
          
          vr_dsdemail := rw_prestamista.dsdemail;
          SEGU0003.pc_limpa_email(vr_dsdemail);
          
          vr_linha_txt := vr_linha_txt || RPAD(' ', 1, ' '); -- E-mail Fulfillment
          vr_linha_txt := vr_linha_txt || RPAD(nvl(vr_dsdemail, ' '), 50, ' '); -- E-mail
          vr_linha_txt := vr_linha_txt || RPAD(' ', 12, ' '); -- Cód.Campanha
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); -- Cód.Vendedor
          vr_linha_txt := vr_linha_txt || RPAD( nvl(vr_NRPROPOSTA,' '), 30, ' '); -- Nº Proposta
          vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_dtdevend, 'YYYY-MM-DD'), 10, 0); -- Data Transação (Data da venda) / Data Cancelamento
          vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_dtinivig, 'YYYY-MM-DD'), 10, 0); -- Inicio Vigência
          vr_linha_txt := vr_linha_txt || LPAD(' ', 2, ' '); -- Razão Cancelam/Suspensão
                                                          
          --1 contrato para cada adesão
          vr_linha_txt := vr_linha_txt || LPAD(nvl(to_char(rw_prestamista.nrctremp), 0), 10, 0); -- Referencia 6 - nrctremp
          
          vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##2
          vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##3
          vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##4
          vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##5
          
          vr_linha_txt := vr_linha_txt || RPAD(LPAD(rw_prestamista.cdcooper, 4, 0), 50, ' '); -- Referencia 7 - Cooperativa 491
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- Referencia 3 - Nº da Sorte
          vr_linha_txt := vr_linha_txt || nvl(to_char(rw_prestamista.cdcobran), ' '); -- Meio Cobrança
          vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.cdadmcob), ' '), 3, ' '); -- Cód.Administr.Cobrança BY e BC
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); -- Cód. Banco
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); -- Cód.Agência
          vr_linha_txt := vr_linha_txt || RPAD(' ', 2, ' '); -- Cód.Admin.Cartão Crédito
          vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' '); -- Nº Conta Corrente
          vr_linha_txt := vr_linha_txt || RPAD(' ', 5, ' '); -- Validade Cartão Crédito
          vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' '); -- Data Cobrança          
          vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.tpfrecob), ' '), 2, ' '); -- Frequência Cobrança
          vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_prestamista.tpsegura), ' '), 2, ' '); -- Tipo Segurado
          vr_linha_txt := vr_linha_txt || nvl(to_char(rw_prestamista.cdcooperativa), ' '); -- Produto - Cód.Produto
          vr_linha_txt := vr_linha_txt || nvl(to_char(rw_prestamista.cdplapro), ' '); -- Produto - Plano
          
          vr_linha_txt := vr_linha_txt || LPAD(replace(to_char(rw_prestamista.vlprodut,'fm99999990d00'), ',', '.'), 12, 0); -- Produto ¿ Valor
          vr_linha_txt := vr_linha_txt || LPAD(nvl(to_char(rw_prestamista.tpcobran), ' '), 1, ' '); -- Tipo de Cobrança
          vr_linha_txt := vr_linha_txt || LPAD(replace(to_char(vr_vlenviad,'fm999999999999990d00'), ',', '.'), 30, 0); -- Valor do Saldo Devedor Atualizado
          vr_linha_txt := vr_linha_txt || LPAD(to_char(vr_ultimoDia, 'YYYY-MM-DD'), 10, 0); -- Data Referência para Cobrança
          vr_linha_txt := vr_linha_txt || LPAD(to_char(rw_prestamista.dtfimvig, 'YYYY-MM-DD'), 10, 0); -- Data final de vigência contrato
          
          -- Opcionais nao enviados
          vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' '); -- Data/Hora Autorização ¿ SITEF
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 1 ¿ Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 2 ¿ Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 3 ¿ Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 4 ¿ Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');-- PSD 5 ¿ Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 6 ¿ Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 7 ¿ Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 8 ¿ Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 9 ¿ Dados do risco
          vr_linha_txt := vr_linha_txt || LPAD(' ', 89, ' '); -- Código Identificador do Cartão de Crédito (cardHash) ¿ Software Express
          vr_linha_txt := vr_linha_txt || LPAD(' ', 15, ' '); -- authorizerId
          vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' '); -- Beneficiário 1 - Nome
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Beneficiário 1 - Relação
          vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');  -- Beneficiário 1 - Porcentagem
          vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' '); -- Beneficiário 2 - Nome
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Beneficiário 2 - Relação
          vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');  -- Beneficiário 2 - Porcentagem
          vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' '); -- Beneficiário 3 - Nome
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Beneficiário 3 - Relação
          vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');  -- Beneficiário 3 - Porcentagem
          vr_linha_txt := vr_linha_txt || RPAD(' ', 30, ' '); -- Beneficiário 4 - Nome
          vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Beneficiário 4 - Relação
          vr_linha_txt := vr_linha_txt || LPAD(' ', 3, ' ');  -- Beneficiário 4 - Porcentagem
          -- Opcionais nao enviados
          
          vr_linha_txt := vr_linha_txt || chr(13);
          
          vr_index_815 := vr_index_815 + 1;
          vr_tab_crrl815(vr_index_815) := NULL;
          vr_tab_crrl815(vr_index_815).dtmvtolt := vr_dtmvtolt ; --rw_crapcop.dtmvtolt;
          vr_tab_crrl815(vr_index_815).nmrescop := vr_nmrescop;
          vr_tab_crrl815(vr_index_815).nmprimtl := rw_prestamista.nmprimtl;
          vr_tab_crrl815(vr_index_815).nrdconta := rw_prestamista.nrdconta;
          vr_tab_crrl815(vr_index_815).nrctrseg := vr_NRPROPOSTA;
          vr_tab_crrl815(vr_index_815).nrctremp := rw_prestamista.nrctremp;
          vr_tab_crrl815(vr_index_815).nrcpfcgc := rw_prestamista.nrcpfcgc;
          vr_tab_crrl815(vr_index_815).vlprodut := rw_prestamista.vlprodut;
          vr_tab_crrl815(vr_index_815).vlenviad := vr_vlenviad;
          vr_tab_crrl815(vr_index_815).vlsdeved := vr_vlsdeved;
          vr_tab_crrl815(vr_index_815).dtinivig := rw_prestamista.dtinivig;
          vr_tab_crrl815(vr_index_815).dtrefcob := rw_prestamista.dtrefcob;
          vr_tab_crrl815(vr_index_815).tpregist := rw_prestamista.tpregist;
          vr_tab_crrl815(vr_index_815).dsregist := vr_tipo_registro(vr_tpregist).tpregist;
          -- adesao seta o proximo como endosso e a proxima execucao trata se sera cancelamento
          IF vr_tpregist = 1 THEN 
            vr_tpregist := 3;
          END IF;
            
          IF vr_flgnvenv THEN 
            vr_tpregist := 0; -- sera ignorado na proxima execucao
          END IF;
            
          BEGIN 
            UPDATE tbseg_prestamista
               SET tpregist = vr_tpregist
                  ,dtdenvio = vr_dtmvtolt  --rw_crapcop.dtmvtolt
                  ,dtrefcob = vr_ultimoDia
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = rw_prestamista.nrdconta
               AND nrctrseg = rw_prestamista.nrctrseg
               AND nrctremp = rw_prestamista.nrctremp
               AND cdapolic = vr_cdapolic;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
              RAISE vr_exc_saida;
          END;   
        
          -- Escrever Linha do Arquivo 
          GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);
        
          vr_seqtran := vr_seqtran + 1;
        END LOOP;
        vr_crrl815 := vr_tab_crrl815;

        -- Fechar o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

        -- UX2DOS
        GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper                   --> Cooperativa
                                    ,pr_nmarquiv => vr_nmdircop || '/arq/'||vr_nmarquiv        --> Caminho e nome do arquivo a ser convertido
                                    ,pr_nmarqenv => vr_nmarquiv           --> Nome desejado para o arquivo convertido
                                    ,pr_des_erro => vr_dscritic);                 --> Retorno da critica

        IF vr_dscritic IS NOT NULL THEN    --Se ocorreu erro          
          RAISE vr_exc_erro;               --Levantar Excecao
        END IF;
      
        -- Mover o arquivo processado para a pasta "salvar" 
        gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdircop||'/arq/'||vr_nmarquiv||' '||vr_nmdircop||'/salvar',
                                    pr_typ_saida   => vr_tipo_saida,
                                    pr_des_saida   => vr_dscritic);
        -- Testa erro
        IF vr_tipo_saida = 'ERR' THEN
          vr_dscritic := 'Erro ao mover o arquivo - Cooperativa: ' || pr_cdcooper || ' - ' ||vr_dscritic;
          -- Escreve log de erro, mas continua com o processo
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Movimentacao de diretorio retornou erro: '||vr_dscritic);
        END IF;
      
        --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
        cecred.pc_log_programa(pr_dstiplog   => 'F',
                               pr_cdprograma => vr_cdprogra,
                               pr_cdcooper   => pr_cdcooper,
                               pr_tpexecucao => 2, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               pr_idprglog   => vr_idprglog);
        
        -- Commitamos depois que o arquivo tiver sido enviado, 
        -- em caso de erros não perdemos o cenário de envios pendentes, 
        -- fazendo-o na próxima execução de sucesso
      --  COMMIT;   
        
      EXCEPTION
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
        
          pr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          -- Efetuar rollback
          ROLLBACK;
          -- Envio centralizado de log de erro
          cecred.pc_log_programa(pr_dstiplog           => 'E',         -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                                 pr_cdprograma         => vr_cdprogra, -- tbgen_prglog
                                 pr_cdcooper           => pr_cdcooper, -- tbgen_prglog
                                 pr_tpexecucao         => 2,           -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                 pr_tpocorrencia       => 0,           -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                                 pr_cdcriticidade      => 2,           -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                 pr_dsmensagem         => vr_dscritic, -- tbgen_prglog_ocorrencia
                                 pr_flgsucesso         => 0,           -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                                 pr_nmarqlog           => NULL,
                                 pr_idprglog           => vr_idprglog);

          -- Por fim, envia o email
          gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                     pr_des_destino => vr_destinatario_email,
                                     pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                     pr_des_corpo   => pr_dscritic,
                                     pr_des_anexo   => NULL,
                                     pr_flg_enviar  => 'S',
                                     pr_des_erro    => vr_dscritic); 
        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
          --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
          pr_dscritic := vr_dscritic;
          -- Efetuar rollback
          ROLLBACK;
          -- Envio centralizado de log de erro
          cecred.pc_log_programa(pr_dstiplog           => 'E',         -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                                 pr_cdprograma         => vr_cdprogra, -- tbgen_prglog
                                 pr_cdcooper           => pr_cdcooper, -- tbgen_prglog
                                 pr_tpexecucao         => 2,           -- tbgen_prglog  DEFAULT 1 - Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                                 pr_tpocorrencia       => 0,           -- tbgen_prglog_ocorrencia - 1 Erro TRATADO
                                 pr_cdcriticidade      => 2,           -- tbgen_prglog_ocorrencia DEFAULT 0 - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                                 pr_dsmensagem         => vr_dscritic, -- tbgen_prglog_ocorrencia
                                 pr_flgsucesso         => 0,           -- tbgen_prglog  DEFAULT 1 - Indicador de sucesso da execução
                                 pr_nmarqlog           => NULL,
                                 pr_destinatario_email => vr_destinatario_email,
                                 pr_idprglog           => vr_idprglog);
          -- Por fim, envia o email
          gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                     pr_des_destino => vr_destinatario_email,
                                     pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprogra,
                                     pr_des_corpo   => pr_dscritic,
                                     pr_des_anexo   => NULL,
                                     pr_flg_enviar  => 'S',
                                     pr_des_erro    => vr_dscritic); 
      END;
    END pc_gera_arquivo_coop;
 
begin
 
  vr_tab_crrl815.delete;
  vr_crrl815.delete;    
  vr_tipo_registro.delete;
  vr_totais_crrl815.delete;
      
  vr_tipo_registro(0).tpregist := 'NOT FOUND';
  vr_tipo_registro(1).tpregist := 'ADESAO';
  vr_tipo_registro(2).tpregist := 'CANCELAMENTO';
  vr_tipo_registro(3).tpregist := 'ENDOSSO';  

  --Criar arquivo de Roll Back
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo de relacao
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_excsaida;
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2,'Coop;Conta;Contrato;Data Emprestimo');
  
  for rw_crapcop in cr_crapcop loop
  
     for rw_registros in cr_registros(rw_crapcop.cdcooper) loop
            
        open cr_prestamista (rw_registros.cdcooper, rw_registros.nrdconta, rw_registros.nrctremp);
        fetch cr_prestamista into rw_prestamista;
        
        if cr_prestamista%found and nvl(rw_prestamista.nrproposta,0) > 0 then        
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crawseg set nrproposta = 0 where progress_recid = '||rw_registros.rec_id_wseg||';');
          
          begin            
            update crawseg g 
               set g.nrproposta = rw_prestamista.nrproposta
             where g.progress_recid = rw_registros.rec_id_wseg;         
          exception
          when others then
            vr_dscritic:= 'Erro ao gravar numero de proposta wseg: '||rw_prestamista.nrproposta||' - '||sqlerrm;
            raise vr_excsaida;
          end;          
          
       end if;
       
       close cr_prestamista;
       
     end loop; 
     
     for rw_registros_tbseg in cr_registros_tbseg(rw_crapcop.cdcooper) loop
            
        open cr_crawseg (rw_registros_tbseg.cdcooper, rw_registros_tbseg.nrdconta, rw_registros_tbseg.nrctremp);
        fetch cr_crawseg into rw_crawseg;
        
        if cr_crawseg%found and nvl(rw_crawseg.nrproposta,0) > 0 then      
        
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update tbseg_prestamista set nrproposta = 0 where idseqtra = '||rw_registros_tbseg.idseqtra||';');
          
          begin            
            update tbseg_prestamista g 
               set g.nrproposta = rw_crawseg.nrproposta
             where g.idseqtra = rw_registros_tbseg.idseqtra;         
          exception
          when others then
            vr_dscritic:= 'Erro ao gravar numero de proposta wseg: '||rw_prestamista.nrproposta||' - '||sqlerrm;
            raise vr_excsaida;
          end;            

       
       elsif cr_crawseg%notfound then
          
          SELECT SEGU0003.FN_NRPROPOSTA() INTO vr_nrproposta  FROM DUAL;       
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update tbseg_prestamista set nrproposta = 0 where idseqtra = '||rw_registros_tbseg.idseqtra||';');
          
          begin            
            update tbseg_prestamista g 
               set g.nrproposta = vr_nrproposta
             where g.idseqtra = rw_registros_tbseg.idseqtra;         
          exception
          when others then
            vr_dscritic:= 'Erro ao gravar numero de proposta 1: '||vr_nrproposta||' - '||sqlerrm;
            raise vr_excsaida;
          end;
       
          -- Gravar data da utilização da proposta para que nao utilize mais o mesmo numero
          begin
            UPDATE TBSEG_NRPROPOSTA 
               SET DTSEGURO = SYSDATE 
             WHERE NRPROPOSTA = vr_nrproposta; 
          exception
            when others then
               vr_dscritic:= 'Erro ao atualizar numero de TBSEG_NRPROPOSTA: '||vr_nrproposta||' - '||sqlerrm;
               raise vr_excsaida;
          end;         
       end if;
       
       close cr_crawseg;
       
     end loop; 
     
     for rw_registros_todos in cr_registros_todos(rw_crapcop.cdcooper) loop
            
         SELECT SEGU0003.FN_NRPROPOSTA() INTO vr_nrproposta  FROM DUAL; 
               
           gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update tbseg_prestamista set nrproposta = 0 where idseqtra = '||rw_registros_todos.idseqtra||';');
         
          begin            
            update tbseg_prestamista g 
               set g.nrproposta = vr_nrproposta
             where g.idseqtra = rw_registros_todos.idseqtra;         
          exception
            when others then
              vr_dscritic:= 'Erro ao gravar numero de proposta 1: '||vr_nrproposta||' - '||sqlerrm;
              raise vr_excsaida;              
          end;
          
           gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crawseg set nrproposta = 0 where progress_recid = '||rw_registros_todos.progress_recid||';');
           
          begin            
            update crawseg g 
               set g.nrproposta = vr_nrproposta
             where g.progress_recid = rw_registros_todos.progress_recid;         
          exception
            when others then
              vr_dscritic:= 'Erro ao gravar numero de proposta 2: '||vr_nrproposta||' - '||sqlerrm;
              raise vr_excsaida;                
          end;
          
          -- Gravar data da utilização da proposta para que nao utilize mais o mesmo numero
          begin
            UPDATE TBSEG_NRPROPOSTA 
               SET DTSEGURO = SYSDATE 
             WHERE NRPROPOSTA = vr_nrproposta; 
          exception
            when others then
              vr_dscritic:= 'Erro ao atualizar numero de TBSEG_NRPROPOSTA: '||vr_nrproposta||' - '||sqlerrm;
              raise vr_excsaida;              
          end;
     end loop; 
     
     -- Criar prestamista para os que não foram criados automaticamente
     for rw_registros_sem_tbseg in cr_registros_sem_tbseg(rw_crapcop.cdcooper) loop
     
       gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, rw_registros_sem_tbseg.cdcooper||';'||
                                                     rw_registros_sem_tbseg.nrdconta||';'||
                                                     rw_registros_sem_tbseg.nrctremp||';'||
                                                     rw_registros_sem_tbseg.dtmvtolt||';');
       
       SEGU0003.pc_efetiva_proposta_sp(rw_registros_sem_tbseg.cdcooper, --> Cooperativa
                                       rw_registros_sem_tbseg.nrdconta, --> numero da conta
                                       rw_registros_sem_tbseg.nrctremp, --> Contrato
                                       1,  --> Código da agencia
                                       1,  --> Numero do caixa do operador
                                       1,  --> Código do Operador
                                       'BACA', --> Nome da Tela
                                       1, --> Identificador de Origem
                                       vr_cdcritic,
                                       vr_dscritic);
                                            
        if trim(vr_dscritic) is not null then
           vr_dscritic:= 'Erro SEGU0003.pc_efetiva_proposta_sp: '||vr_dscritic;
           raise vr_excsaida;           
        end if;                          
     
        -- Verificar se ficou algum numero de proposta zerado na criação
        open cr_prestamista (rw_registros_sem_tbseg.cdcooper, rw_registros_sem_tbseg.nrdconta, rw_registros_sem_tbseg.nrctremp);
        fetch cr_prestamista into rw_prestamista;
        
        open cr_crawseg (rw_registros_sem_tbseg.cdcooper, rw_registros_sem_tbseg.nrdconta, rw_registros_sem_tbseg.nrctremp);
        fetch cr_crawseg into rw_crawseg;
        
        if cr_crawseg%found     and nvl(rw_crawseg.nrproposta,0) > 0 and 
           cr_prestamista%found and nvl(rw_prestamista.nrproposta,0) = 0 then    
           
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update tbseg_prestamista set nrproposta = 0 where idseqtra = '||rw_prestamista.idseqtra||';');
              
          begin            
            update tbseg_prestamista g 
               set g.nrproposta = rw_crawseg.nrproposta
             where g.idseqtra = rw_prestamista.idseqtra;         
          exception
          when others then
            vr_dscritic:= 'Erro ao gravar numero de proposta wseg: '||rw_prestamista.nrproposta||' - '||sqlerrm;
            raise vr_excsaida;            
          end;            
        
        elsif cr_prestamista%found and nvl(rw_prestamista.nrproposta,0) > 0 and 
              cr_crawseg%found     and nvl(rw_crawseg.nrproposta,0) = 0 then    
              
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crawseg set nrproposta = 0 where progress_recid = '||rw_crawseg.progress_recid||';');
              
          begin            
            update crawseg g 
               set g.nrproposta = rw_prestamista.nrproposta
             where g.progress_recid = rw_crawseg.progress_recid;         
          exception
          when others then
            vr_dscritic:= 'Erro ao gravar numero de proposta wseg(cr_registros_sem_tbseg): '||rw_prestamista.nrproposta||' - '||sqlerrm;
            raise vr_excsaida;            
          end;          
          
       end if;
       
       close cr_prestamista;
       close cr_crawseg;
     
     end loop;
     
     -- Se aiinda sim estiver algum registro na tbseg_prestamista zerado
     for rw_prestamista_prop_zero in cr_prestamista_prop_zero(rw_crapcop.cdcooper) loop 
     
       SELECT SEGU0003.FN_NRPROPOSTA() INTO vr_nrproposta  FROM DUAL; 
               
           gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update tbseg_prestamista set nrproposta = 0 where idseqtra = '||rw_prestamista_prop_zero.idseqtra||';');
         
          begin            
            update tbseg_prestamista g 
               set g.nrproposta = vr_nrproposta
             where g.idseqtra = rw_prestamista_prop_zero.idseqtra;         
          exception
            when others then
              vr_dscritic:= 'Erro ao gravar numero de proposta 3: '||vr_nrproposta||' - '||sqlerrm;
              raise vr_excsaida;              
          end;
          
          open cr_crawseg (rw_prestamista_prop_zero.cdcooper, rw_prestamista_prop_zero.nrdconta, rw_prestamista_prop_zero.nrctremp);
          fetch cr_crawseg into rw_crawseg;
          
          if cr_crawseg%found then
                    
            gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crawseg set nrproposta = 0 where progress_recid = '||rw_crawseg.progress_recid||';');
             
            begin            
              update crawseg g 
                 set g.nrproposta = vr_nrproposta
               where g.progress_recid = rw_crawseg.progress_recid;         
            exception
              when others then
                vr_dscritic:= 'Erro ao gravar numero de proposta 3: '||vr_nrproposta||' - '||sqlerrm;
                raise vr_excsaida;                
            end;
          end if;
          
          close cr_crawseg;
          
          -- Gravar data da utilização da proposta para que nao utilize mais o mesmo numero
          begin
            UPDATE TBSEG_NRPROPOSTA 
               SET DTSEGURO = SYSDATE 
             WHERE NRPROPOSTA = vr_nrproposta; 
          exception
            when others then
              vr_dscritic:= 'Erro ao atualizar numero de TBSEG_NRPROPOSTA: '||vr_nrproposta||' - '||sqlerrm;
              raise vr_excsaida;              
          end;
     
     end loop;
     
     -- Voltar para novo o tipo de registro 
     begin
       update tbseg_prestamista a 
          set a.tpregist = 1
        where a.tpregist = 3
          and a.cdcooper = rw_crapcop.cdcooper;       
     exception
        when others then
          vr_dscritic:= 'Erro ao atualizar numero de TBSEG_NRPROPOSTA: '||vr_nrproposta||' - '||sqlerrm;
          raise vr_excsaida;              
      end;
      
     vr_dtmvtolt := rw_crapcop.dtmvtolt;    
     vr_index_815 := 0;        
     -- Gerar Arquivo
     pc_gera_arquivo_coop(pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
                         
     if trim(vr_dscritic) is not null then
       vr_dscritic:= 'Erro pc_gera_arquivo_coop: '||vr_dscritic;
       raise vr_excsaida;           
     end if;   
       
      vr_totais_crrl815.delete;
      
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl815><dados>');  
        vr_index_815 :=  vr_crrl815.first;
        WHILE vr_index_815 IS NOT NULL LOOP
          pc_escreve_xml(
                '<registro>'||
                         '<dtmvtolt>' || TO_CHAR(vr_crrl815(vr_index_815).dtmvtolt , 'DD/MM/RRRR') || '</dtmvtolt>' ||
                         '<nmrescop>' || vr_crrl815(vr_index_815).nmrescop || '</nmrescop>' ||
                         '<nmprimtl>' || vr_crrl815(vr_index_815).nmprimtl || '</nmprimtl>' ||
                         '<nrdconta>' || TRIM(gene0002.fn_mask_conta(vr_crrl815(vr_index_815).nrdconta)) || '</nrdconta>' ||
                         '<nrctrseg>' || TRIM(gene0002.fn_mask_contrato(vr_crrl815(vr_index_815).nrctrseg)) || '</nrctrseg>' ||
                         '<nrctremp>' || TRIM(gene0002.fn_mask_contrato(vr_crrl815(vr_index_815).nrctremp)) || '</nrctremp>' ||
                         '<nrcpfcgc>' || TRIM(gene0002.fn_mask_cpf_cnpj(vr_crrl815(vr_index_815).nrcpfcgc, 1)) || '</nrcpfcgc>' ||
                         '<vlprodut>' || to_char(vr_crrl815(vr_index_815).vlprodut, 'FM99G999G999G999G999G999G999G990D00') || '</vlprodut>' ||
                         '<vlenviad>' || to_char(vr_crrl815(vr_index_815).vlenviad, 'FM99G999G999G999G999G999G999G990D00') || '</vlenviad>' ||
                         '<vlsdeved>' || to_char(vr_crrl815(vr_index_815).vlsdeved, 'FM99G999G999G999G999G999G999G990D00') || '</vlsdeved>' ||
                         '<dtrefcob>' || NVL(TO_CHAR( vr_crrl815(vr_index_815).dtrefcob, 'DD/MM/RRRR') , '') || '</dtrefcob>' ||
                         '<dsregist>' || vr_crrl815(vr_index_815).dsregist || '</dsregist>' ||
                         '<dtinivig>' || NVL(TO_CHAR(vr_crrl815(vr_index_815).dtinivig , 'DD/MM/RRRR') , '') || '</dtinivig>'
                 ||'</registro>');
         
          vr_dsadesao := vr_crrl815(vr_index_815).dsregist;

          IF vr_totais_crrl815.EXISTS(vr_dsadesao) = FALSE THEN
            vr_totais_crrl815(vr_dsadesao).qtdadesao := 1;
            vr_totais_crrl815(vr_dsadesao).slddeved := vr_crrl815(vr_index_815).vlenviad;
            vr_totais_crrl815(vr_dsadesao).vlpremio := vr_crrl815(vr_index_815).vlprodut;
            vr_totais_crrl815(vr_dsadesao).dsadesao := vr_dsadesao;
          ELSE
            vr_totais_crrl815(vr_dsadesao).slddeved := vr_totais_crrl815(vr_dsadesao).slddeved +
                                                       vr_crrl815(vr_index_815).vlenviad;
            vr_totais_crrl815(vr_dsadesao).vlpremio := vr_totais_crrl815(vr_dsadesao).vlpremio +
                                                       vr_crrl815(vr_index_815).vlprodut;
            vr_totais_crrl815(vr_dsadesao).qtdadesao := vr_totais_crrl815(vr_dsadesao).qtdadesao + 1;
          END IF;
          vr_index_815 := vr_crrl815.next(vr_index_815);
        END LOOP;
        pc_escreve_xml(  '</dados>'||
                       '<totais>');
        
        vr_index := vr_totais_crrl815.first;
        WHILE vr_index IS NOT NULL LOOP
          IF vr_totais_crrl815.EXISTS(vr_index) = TRUE THEN
                  
            pc_escreve_xml('<registro>'||
                             '<dsadesao>' || NVL(vr_totais_crrl815(vr_index).dsadesao, ' ') || '</dsadesao>' ||
                             '<vlpremio>' || to_char(NVL(vr_totais_crrl815(vr_index).vlpremio, '0'), 'FM99G999G999G999G999G999G999G990D00') || '</vlpremio>' ||
                             '<slddeved>' || to_char(NVL(vr_totais_crrl815(vr_index).slddeved, '0'), 'FM99G999G999G999G999G999G999G990D00') || '</slddeved>' ||
                             '<qtdadesao>' || NVL(vr_totais_crrl815(vr_index).qtdadesao, 0) || '</qtdadesao>'||
                           '</registro>');

          END IF;
          vr_index := vr_totais_crrl815.next(vr_index);
        END LOOP;

        pc_escreve_xml(  '</totais>'||
                       '</crrl815>');
        gene0001.pc_fecha_arquivo(vr_arqhandle);
        
        vr_dir_relatorio_815 := gene0001.fn_diretorio('C', rw_crapcop.cdcooper, 'rl') || '/crrl815.lst';
        -- entra apenas se existir algum conteudo para imprimir
        IF vr_crrl815.EXISTS(rw_crapcop.cdcooper) = TRUE THEN
          gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                 --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapcop.dtmvtolt         --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml                  --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl815'                  --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl815.jasper'            --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                        --> Nao tem parametros
                                     ,pr_dsarqsaid => vr_dir_relatorio_815        --> Arquivo final
                                     ,pr_cdrelato  => 815
                                     ,pr_flg_gerar => 'S'
                                     ,pr_qtcoluna  => 234
                                     ,pr_sqcabrel  => 1
                                     ,pr_nmformul  => '234col'
                                     ,pr_flg_impri => 'S'
                                     ,pr_nrcopias  => 1
                                     ,pr_nrvergrl  => 1
                                     ,pr_des_erro  => vr_dscritic);

          IF trim(vr_dscritic) IS NOT NULL THEN            
            RAISE vr_excsaida;            -- Gerar exceção
          END IF;
        END IF;
 
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
     
     -- Commit a cada cooperativa
     commit;
  end loop;  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  

  :vr_dscritic := 'SUCESSO';


EXCEPTION
  WHEN vr_excsaida then 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
end;
1
vr_dscritic
1
SUCESSO
5
3
rw_registros_tbseg.nrdconta
rw_registros_tbseg.nrctremp
rw_crawseg.nrproposta
