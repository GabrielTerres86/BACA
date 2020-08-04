DECLARE
  vr_tipo_saida VARCHAR2(100);
  vr_nrapolic   VARCHAR2(100);
  vr_dsdircop   VARCHAR2(50);
  vr_nmdircop   VARCHAR2(100);
  vr_nmarquiv   VARCHAR2(100);
  vr_linha_txt  VARCHAR2(32600);
  vr_xml_temp   VARCHAR2(32726) := ''; --> Temp xml/csv 

  vr_idseqtra   tbseg_prestamista.idseqtra%TYPE;
  vr_dtfimvig   DATE;
  vr_cdcooper   crapcop.cdcooper%TYPE;
  vr_nrsequen   NUMBER(10);
  rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE;
  
  vr_dados_er   CLOB; -- Grava informacoes no xls
  vr_texto_er  VARCHAR2(32600);  
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqimp   VARCHAR2(100);
  vr_nmarqbkp   VARCHAR2(100);
  vr_nmdireto   VARCHAR2(4000); 
  -- Declarando handle do Arquivo
  vr_ind_arquivo utl_file.file_type;
  
  -- Código do programa
  vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'JB_ARQPRST';
  
  vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;
  vr_destinatario_email VARCHAR2(500);
  vr_pgtosegu     NUMBER;
  vr_vlprodvl     NUMBER;
  vr_dstextab     craptab.dstextab%TYPE; --> Busca na craptab

  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000); --> Desc. Erro
  vr_tab_erro  GENE0001.typ_tab_erro;
  vr_des_reto  VARCHAR2(10);

  vr_exc_erro  EXCEPTION;
  vr_exc_saida EXCEPTION;
  vr_typ_saida VARCHAR2(100);
  vr_des_saida VARCHAR2(2000);
  
  vr_flgprestamista varchar2(1) := 'N';
  vr_flgdps         varchar2(1) := 'N';
  vr_vlproposta     crawseg.vlseguro%type;
  vr_dsmotcan       VARCHAR2(60);
  vr_inusatab       BOOLEAN := FALSE;
  vr_sld_devedor    crawseg.vlseguro%type;
  vr_vltotpre       NUMBER := 0;
  vr_qtprecal       NUMBER := 0;
  vr_nrctrseg       crapseg.nrctrseg%TYPE;
  vr_dtiniseg       crapepr.dtmvtolt%TYPE;
  vr_tab_vlmaximo   NUMBER;
  vr_tab_vlminimo   NUMBER;
  vr_tab_nrdeanos   NUMBER;
  vr_flgnenvi       INTEGER;
  vr_contrcpf       tbseg_prestamista.nrcpfcgc%TYPE := NULL;
  vr_vlenviad       NUMBER;
  vr_vltotenv       NUMBER;
  vr_vlmaximo       NUMBER;
  vr_dscorpem       VARCHAR2(2000);
  vr_nmrescop       crapcop.nmrescop%TYPE;
  vr_nrdeanos       PLS_INTEGER;
  vr_nrdmeses       PLS_INTEGER;
  vr_dsdidade       VARCHAR2(50);
  vr_total_conta    NUMBER;
  vr_countcom       INTEGER;
  vr_pref_adesao    VARCHAR2(20);
  vr_pref_endoss    VARCHAR2(20);

  -- Definicao do tipo de array para nome origem do módulo
  TYPE typ_tab_prefixo IS VARRAY(16) OF VARCHAR2(5);
  -- Vetor de memória com as origens do módulo
  vr_vet_prefixo typ_tab_prefixo := typ_tab_prefixo('CEVIA',
                                                    'CECOO',
                                                    '',
                                                    '',
                                                    'CECRI',
                                                    'CREFI',
                                                    'CRERE',
                                                    'CRELE',
                                                    'CETRA',
                                                    'CREDM',
                                                    'CREFO',
                                                    'CREVI',
                                                    'CECIV',
                                                    'CRERO',
                                                    '',
                                                    'CEALT');

  -- Ultima parcela do financiamento
  CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                   ,pr_nrdconta IN crappep.nrdconta%TYPE
                   ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
    SELECT MAX(p.dtvencto) dtvencto
      FROM crappep p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.nrctremp = pr_nrctremp;
  rw_crappep cr_crappep%ROWTYPE;

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,c.dsdircop
          ,c.nmrescop
      FROM crapcop c
     WHERE c.flgativo = 1 -- Somente ativas
       AND c.cdcooper <> 3 -- nao será gerado para central
     ORDER BY c.cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Cursor de email
  CURSOR cr_crapcem(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT e.dsdemail
      FROM crapcem e
     WHERE e.cdcooper = pr_cdcooper
       AND e.nrdconta = pr_nrdconta;
  rw_crapcem cr_crapcem%ROWTYPE;
  
  -- Dados de endereço do cooperado
  CURSOR cr_crapenc(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
   SELECT e.dsendere dsendres
         ,e.nrendere 
         ,e.nmbairro
         ,e.nmcidade
         ,e.cdufende cdufresd
         ,e.nrcepend
         ,e.complend
     FROM crapenc e
    WHERE cdcooper = pr_cdcooper  
      AND nrdconta = pr_nrdconta
      AND idseqttl = 1 -- 1 Titular
      AND dsendere IS NOT NULL 
      AND tpendass = 10;  /* Residencial */ 
  rw_crapenc cr_crapenc%ROWTYPE;
  
  -- Cursor de telefone
  CURSOR cr_craptfc(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT (f.nrdddtfc || f.nrtelefo) nrtelefo -- Telefone Residencial
      FROM craptfc f
     WHERE f.cdcooper = pr_cdcooper
       AND f.nrdconta = pr_nrdconta
       AND f.tptelefo(+) IN (1, 2, 4)
     ORDER BY f.tptelefo ASC;
  rw_craptfc cr_craptfc%ROWTYPE;
  
  -- Leitura dos associados e seus empréstimos em aberto
  CURSOR cr_contas(pr_cdcooper IN crapcop.cdcooper%TYPE
                  ,pr_dtiniseg DATE) IS
      select a.nrcpfcgc
            ,a.inmatric
            ,a.nrdconta
            ,a.nmprimtl
            ,a.cdagenci
            ,a.dtnasctl
            ,a.nrctremp
            ,a.vlsdeved
            ,a.dtmvtolt
            ,a.cdsexotl
            ,a.dtinipag
            ,add_months(a.dtinipag,a.qtpreemp) dtfimctr
            ,ROW_NUMBER () OVER (PARTITION BY a.nrcpfcgc
                                     ORDER BY a.nrcpfcgc
                                             ,a.inmatric DESC
                                             ,a.nrdconta) sqregcpf
            ,COUNT (*) OVER (PARTITION BY a.nrcpfcgc)     qtregcpf
        FROM ( SELECT ass.nrcpfcgc
                      ,ass.inmatric
                      ,ass.nrdconta
                      ,ass.nmprimtl
                      ,ass.cdagenci
                      ,ass.dtnasctl
                      ,epr.nrctremp
                      ,epr.vlsdeved
                      ,epr.dtmvtolt
                      ,epr.dtinipag
                      ,epr.qtpreemp
                      ,ass.cdsexotl
                  FROM crapepr epr
                      ,crapass ass
                      ,craplcr lcr
                 WHERE ass.cdcooper = pr_cdcooper
                   AND ass.inpessoa = 1 --> Somente fisica
                   AND ass.cdcooper = epr.cdcooper
                   AND ass.nrdconta = epr.nrdconta
                   AND epr.dtmvtolt >= pr_dtiniseg
                   AND epr.inliquid = 0     --> Em aberto
                   AND epr.inprejuz = 0
                   AND lcr.cdcooper = epr.cdcooper
                   AND lcr.cdlcremp = epr.cdlcremp
                   AND lcr.flgsegpr = 1
                UNION
                SELECT ass.nrcpfcgc 
                      ,ass.inmatric
                      ,ass.nrdconta
                      ,ass.nmprimtl
                      ,ass.cdagenci
                      ,ass.dtnasctl
                      ,epr.nrctremp
                      ,epr.vlsdeved
                      ,epr.dtmvtolt
                      ,epr.dtinipag
                      ,epr.qtpreemp
                      ,ass.cdsexotl
                       FROM crapepr epr
                          ,crapass ass
                          ,craplcr lcr
                      WHERE ass.cdcooper = 9 -->cooperativa 9
                        AND ass.inpessoa = 1 --> Somente fisica
                        AND ass.cdcooper = epr.cdcooper
                        AND ass.nrdconta = epr.nrdconta
                        AND epr.dtmvtolt < '01/01/2017' --> todos os registros antes do dia primeiro
                        AND epr.inliquid = 0 --> Em aberto
                        AND epr.inprejuz = 0
                        AND lcr.cdcooper = epr.cdcooper
                        AND lcr.cdlcremp = epr.cdlcremp
                        AND lcr.flgsegpr = 1
                        AND ass.nrdconta BETWEEN 900001 and 912654 --> somente as contas que foram incorporadas (Incorporação Transulcred -> Transpocred)
                        AND pr_cdcooper = 9 -- Apenas para Cooperativa 9, (Incorporação Transulcred -> Transpocred)
                        ) a
    ORDER BY a.nrcpfcgc
            ,a.inmatric DESC
            ,a.nrdconta
            ,sqregcpf;
  rw_contas cr_contas%ROWTYPE;
  
  CURSOR cr_crawseg(pr_cdcooper IN crawseg.cdcooper%TYPE
                   ,pr_nrdconta IN crawseg.nrdconta%TYPE
                   ,pr_nrctremp IN crawseg.nrctrato%TYPE) IS
    SELECT w.nrctrseg nrctrseg
      FROM crawseg w
     WHERE w.cdcooper = pr_cdcooper
       AND w.nrdconta = pr_nrdconta
       AND w.nrctrato = pr_nrctremp; -- se existir um seguro vinculado
  rw_crawseg cr_crawseg%ROWTYPE;
  
  CURSOR cr_crapseg(pr_cdcooper IN crapseg.cdcooper%TYPE
                   ,pr_nrdconta IN crapseg.nrdconta%TYPE) IS
    SELECT MAX(p.nrctrseg) nrctrseg
      FROM crapseg p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.cdsitseg = 1
       AND p.tpseguro = 4;
   rw_crapseg cr_crapseg%ROWTYPE;
  
  -- Busca da idade limite
  CURSOR cr_craptsg(pr_cdcooper IN crapseg.cdcooper%TYPE) IS
    SELECT nrtabela
      FROM craptsg
     WHERE cdcooper = pr_cdcooper
       AND tpseguro = 4
       AND tpplaseg = 1
       AND cdsegura = 5011; -- SEGURADORA CHUBB
           
  -- Validacao de diretorio
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);      
    BEGIN
        -- Primeiro garantimos que o diretorio exista
        IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN

          -- Efetuar a criação do mesmo
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;

          -- Adicionar permissão total na pasta
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;

        END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;    
  END;    
  
  procedure pc_verifica_saldo_devedor(pr_cdcooper in crapcop.cdcooper%type
                                     ,pr_nrdconta in crapass.nrdconta%type
                                     ,pr_vlsdeved out crapepr.vlsdeved%type) is
  begin    
    declare
      vr_vlsdeved crapepr.vlsdeved%type:=0;  
    
      CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ce.nrctremp, ce.vlsdeved
          FROM crapepr ce
              ,craplcr cl
         WHERE ce.cdcooper = pr_cdcooper
           AND ce.nrdconta = pr_nrdconta
           AND ce.inliquid = 0
           AND cl.cdcooper = ce.cdcooper
           AND cl.cdlcremp = ce.cdlcremp
           AND cl.flgsegpr = 1
           ORDER BY ce.nrctremp ASC;
      rw_crapepr cr_crapepr%ROWTYPE;
    --------
   
    begin
       FOR rw_crapepr IN cr_crapepr(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta) LOOP

          vr_vlsdeved := vr_vlsdeved + rw_crapepr.vlsdeved;
       END LOOP;                                 
       pr_vlsdeved:= vr_vlsdeved;
    exception 
      when others then
        null;
    end;
  end;
    
BEGIN

  vr_destinatario_email := gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_EMAIL'); -- seguros@ailos.com.br
  
  -- para cada cooperativa...
  FOR rw_crapcop IN cr_crapcop LOOP
    
    -- Dados para arquivo de rollback
    vr_dados_rollback := NULL;
    
    dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
    
    -- dados para csv de contratos nao tratados (cdc, conta online..)
    vr_dados_er := NULL;

    dbms_lob.createtemporary(vr_dados_er, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_dados_er, dbms_lob.lob_readwrite);
    gene0002.pc_escreve_xml(vr_dados_er, vr_texto_er, 'Cooperativa; Conta; Emprestimo'||chr(13), FALSE);
    
    vr_cdcooper := rw_crapcop.cdcooper; -- Para log em caso de exceção imprevista
  
    -- Calendario da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
  
    vr_nmdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', --> /usr/coop
                                         pr_cdcooper => rw_crapcop.cdcooper);
  
    -- Leitura da sequencia na tab
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper,
                                              pr_nmsistem => 'CRED',
                                              pr_tptabela => 'USUARI',
                                              pr_cdempres => 11,
                                              pr_cdacesso => 'SEGPRESTAM',
                                              pr_tpregist => 0);
  
    vr_nrsequen := to_number(substr(vr_dstextab, 139, 5)) + 1;
    -- Valor máximo da posição 14 a 26
    vr_tab_vlmaximo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));
    -- Valor mínimo da posição 27 a 39
    vr_tab_vlminimo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,27,12));
    -- Data de inicio dos seguros da posição 40 a 50
    vr_dtiniseg := to_date(SUBSTR(vr_dstextab,40,10),'dd/mm/yyyy');
    vr_pgtosegu := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7));
    
    -- Verificar se usa tabela juros
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper,
                                              pr_nmsistem => 'CRED',
                                              pr_tptabela => 'USUARI',
                                              pr_cdempres => 11,
                                              pr_cdacesso => 'TAXATABELA',
                                              pr_tpregist => 0);
    -- Se a primeira posição do campo dstextab for diferente de zero
    IF vr_dstextab IS NOT NULL AND substr(vr_dstextab, 1, 1) = 0 THEN
      vr_inusatab := FALSE;
    ELSE
      vr_inusatab := TRUE;
    END IF;
    
    vr_nmarquiv := vr_vet_prefixo(rw_crapcop.cdcooper) || '_' ||
                   REPLACE(to_char(rw_crapdat.dtmvtolt, 'YYYY/MM/DD'), '/', '') || '_' ||
                   gene0002.fn_mask(vr_nrsequen, '99999') || 'MOV.txt';

    vr_nmdireto := gene0001.fn_param_sistema('CRED',vr_cdcooper,'ROOT_MICROS');
    
    -- Depois criamos o diretorio do projeto
    pc_valida_direto(pr_nmdireto => vr_nmdireto || 'cpd/bacas/PRJ0015011'
                    ,pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;  
    
    vr_nmdireto := vr_nmdireto||'cpd/bacas/PRJ0015011/'||rw_crapcop.dsdircop; 

    -- Depois criamos o diretorio da coop
    pc_valida_direto(pr_nmdireto => vr_nmdireto
                    ,pr_dscritic => vr_dscritic);
    
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    -- Abre arquivo em modo de escrita (W)
    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto         --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                            ,pr_tipabert => 'W'                          --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_ind_arquivo               --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);                --> Erro
    IF vr_dscritic IS NOT NULL THEN
      -- Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
        
    -- Atualiza sequencia (posições 139 a 144 do string)
    BEGIN
      UPDATE craptab
         SET craptab.dstextab = substr(craptab.dstextab, 1, 138) ||
                                gene0002.fn_mask(vr_nrsequen, '99999') ||
                                substr(craptab.dstextab, 145)
       WHERE craptab.cdcooper = rw_crapcop.cdcooper
         AND craptab.nmsistem = 'CRED'
         AND craptab.tptabela = 'USUARI'
         AND craptab.cdempres = 11
         AND craptab.cdacesso = 'SEGPRESTAM'
         AND craptab.tpregist = 0;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar sequencia da cooperativa: ' || rw_crapcop.cdcooper || ' - ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
    
    -- Buscar idade limite
    OPEN cr_craptsg(rw_crapcop.cdcooper);
    FETCH cr_craptsg
     INTO vr_tab_nrdeanos;
    -- Se não tiver encontrado
    IF cr_craptsg%NOTFOUND THEN
      -- Usar 0
      vr_tab_nrdeanos := 0;
    END IF;
    CLOSE cr_craptsg;
    
    vr_idseqtra := 1; -- Começa em 1
    vr_contrcpf := NULL;
    vr_countcom := 0;
    --
    FOR rw_contas IN cr_contas(pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_dtiniseg => vr_dtiniseg) LOOP
      
      vr_flgnenvi := 0;
      vr_total_conta := 0;
      
      -- Buscamos o saldo devedor dos emprestimos
      pc_verifica_saldo_devedor(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_nrdconta => rw_contas.nrdconta
                               ,pr_vlsdeved => vr_total_conta);
                                 
        -- Total da conta menor que o minimo
        IF vr_total_conta < vr_tab_vlminimo THEN
          CONTINUE;
        END IF;
        
      -- controla o cpf para agrupar os valores enviados
      IF vr_contrcpf IS NULL OR vr_contrcpf <> rw_contas.nrcpfcgc THEN 
        vr_contrcpf := rw_contas.nrcpfcgc; -- novo cpf do loop
        vr_vlenviad := rw_contas.vlsdeved; -- novo contrato 
        vr_vltotenv := rw_contas.vlsdeved; -- inicia novo totalizador        
        
        -- Rotina responsavel por calcular a quantidade de anos e meses entre as datas
        CADA0001.pc_busca_idade(pr_dtnasctl => rw_contas.dtnasctl -- Data de Nascimento
                               ,pr_dtmvtolt => rw_contas.dtmvtolt -- Data da utilizacao atual
                               ,pr_nrdeanos => vr_nrdeanos         -- Numero de Anos
                               ,pr_nrdmeses => vr_nrdmeses         -- Numero de meses
                               ,pr_dsdidade => vr_dsdidade         -- Descricao da idade
                               ,pr_des_erro => vr_dscritic);       -- Mensagem de Erro

      ELSE
        vr_vltotenv := vr_vltotenv + rw_contas.vlsdeved;
        IF vr_vltotenv > vr_tab_vlmaximo THEN
          vr_vlenviad := vr_tab_vlmaximo - (vr_vltotenv - rw_contas.vlsdeved); -- enviamos a diferença para preencher até o maximo
          vr_dscorpem := 'Ola, o contrato de emprestimo abaixo ultrapassou o valor limite maximo coberto pela seguradora, segue dados:<br /><br />
                          Cooperativa: ' || rw_crapcop.nmrescop || '<br />
                          Conta: '       || rw_contas.nrdconta || '<br />
                          Nome: '        || rw_contas.nmprimtl || '<br />
                          Contrato Empréstimo: '|| rw_contas.nrctremp || '<br />
                          Proposta seguro: '    || vr_nrctrseg || '<br />
                          Valor Empréstimo: '   || rw_contas.vlsdeved || '<br />
                          Valor saldo devedor total: '|| vr_total_conta || '<br />
                          Valor Limite Máximo: ' || vr_tab_vlmaximo;
                    
          -- Por fim, envia o email
          gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra,
                                     pr_des_destino => vr_destinatario_email,
                                     pr_des_assunto => 'Valor limite maximo excedido ',
                                     pr_des_corpo   => vr_dscorpem,
                                     pr_des_anexo   => NULL,
                                     pr_flg_enviar  => 'S',
                                     pr_des_erro    => vr_dscritic); 
          -- Contratos excedentes acima do maximo, nao serao enviados mas devem ser colocados na tabela
          IF vr_vlenviad <= 0 THEN
            vr_flgnenvi := 1; -- flag para nao enviar no arquivo mas para inserir na tabela
          END IF;
        ELSE 
          vr_vlenviad := rw_contas.vlsdeved; -- envia o valor cheio
        END IF;
      END IF;
      -- Se passar a idade limite parametrizada
      IF vr_nrdeanos > vr_tab_nrdeanos THEN
        continue;
      END IF;
      
      vr_vlprodvl := rw_contas.vlsdeved * (vr_pgtosegu/100); -- Produto – Valor
      vr_nrapolic := fn_sequence('TBSEG_PRESTAMISTA', 'SEQCERTIFICADO', 0);
      
      -- Dados do endereço
      OPEN cr_crapenc(pr_cdcooper => rw_crapcop.cdcooper
                     ,pr_nrdconta => rw_contas.nrdconta);
      FETCH cr_crapenc INTO rw_crapenc;
      CLOSE cr_crapenc;
      
      -- Vigencia do emprestimo
      OPEN cr_crappep(pr_cdcooper => rw_crapcop.cdcooper,
                      pr_nrdconta => rw_contas.nrdconta,
                      pr_nrctremp => rw_contas.nrctremp);
      FETCH cr_crappep INTO rw_crappep;
      CLOSE cr_crappep;
      vr_dtfimvig := nvl(rw_crappep.dtvencto,rw_contas.dtfimctr);
      
      -- Dados de telefone
      OPEN cr_craptfc(pr_cdcooper => rw_crapcop.cdcooper 
                     ,pr_nrdconta => rw_contas.nrdconta);
      FETCH cr_craptfc
        INTO rw_craptfc;
      CLOSE cr_craptfc;
      
      -- numero do seguro
      OPEN cr_crawseg(pr_cdcooper => rw_crapcop.cdcooper 
                     ,pr_nrdconta => rw_contas.nrdconta
                     ,pr_nrctremp => rw_contas.nrctremp);
      FETCH cr_crawseg INTO rw_crawseg;
      IF cr_crawseg%NOTFOUND THEN
        OPEN cr_crapseg(pr_cdcooper => rw_crapcop.cdcooper 
                       ,pr_nrdconta => rw_contas.nrdconta);
        FETCH cr_crapseg INTO rw_crapseg;
        IF cr_crapseg%NOTFOUND THEN
          CLOSE cr_crapseg;
          CLOSE cr_crawseg;
          -- listar no csv
          gene0002.pc_escreve_xml(vr_dados_er, vr_texto_er, 
                                  rw_crapcop.cdcooper  ||';' -- Cooperativa
                                ||rw_contas.nrdconta   ||';' -- Conta
                                ||rw_contas.nrctremp   ||';' -- Nr. Emprestimo
                                ||chr(13), FALSE);  
          CONTINUE; 
        ELSE
          IF rw_crapseg.nrctrseg IS NULL THEN
            CLOSE cr_crapseg;
            CLOSE cr_crawseg;
            -- listar no csv
            gene0002.pc_escreve_xml(vr_dados_er, vr_texto_er, 
                                    rw_crapcop.cdcooper  ||';' -- Cooperativa
                                  ||rw_contas.nrdconta   ||';' -- Conta
                                  ||rw_contas.nrctremp   ||';' -- Nr. Emprestimo
                                  ||chr(13), FALSE);  
            CONTINUE; 
          END IF;
        END IF;
        CLOSE cr_crapseg;
        vr_nrctrseg := rw_crapseg.nrctrseg;
      ELSE
        IF rw_crawseg.nrctrseg IS NULL THEN 
          CLOSE cr_crawseg; 
          -- listar no csv
          gene0002.pc_escreve_xml(vr_dados_er, vr_texto_er, 
                                  rw_crapcop.cdcooper  ||';' -- Cooperativa
                                ||rw_contas.nrdconta   ||';' -- Conta
                                ||rw_contas.nrctremp   ||';' -- Nr. Emprestimo
                                ||chr(13), FALSE);  
          CONTINUE;
        END IF;
        vr_nrctrseg := rw_crawseg.nrctrseg;
      END IF;
      CLOSE cr_crawseg;
      
      BEGIN
        INSERT INTO tbseg_prestamista
            (cdcooper,
             nrdconta,
             nrctrseg,
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
             nrctremp,
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
             dtdenvio)
          VALUES
            (rw_crapcop.cdcooper,
             rw_contas.nrdconta,
             vr_nrctrseg,
             3 -- tipo endosso
            ,vr_nrapolic -- apolice
            ,rw_contas.nrcpfcgc -- cpf
            ,gene0007.fn_caract_especial(rw_contas.nmprimtl) -- nome
            ,rw_contas.dtnasctl -- data de nasc
            ,rw_contas.cdsexotl -- sexo
            ,gene0007.fn_caract_especial(rw_crapenc.dsendres) -- Endereço
            ,rw_crapcem.dsdemail -- email
            ,substr(gene0007.fn_caract_especial(rw_crapenc.nmbairro), 1, 30) -- Bairro
            ,gene0007.fn_caract_especial(rw_crapenc.nmcidade) -- Cidade
            ,rw_crapenc.cdufresd -- UF
            ,rw_crapenc.nrcepend -- CEP
            ,rw_craptfc.nrtelefo -- Telefone Residencial --x
            ,rw_contas.dtinipag -- data da venda
            ,rw_contas.dtinipag -- inicio da vigencia
            ,rw_contas.nrctremp -- Emprestimo vinculado
            ,10 -- Meio de cobranca (fixo 10 - Software Express)
            ,'' --BY ou BC -- Cód.Administr.Cobrança
            ,'M' -- Frequência Cobrança  Mensal: M
            ,'MI' -- Tipo Segurado  Titular: MI
            ,'BCV012' -- codigo
            ,1 -- plano
            ,vr_vlprodvl -- valor
            ,'O' -- Tipo de cobranca (fixo O - Online)
            ,rw_contas.vlsdeved -- Saldo Devedor
            ,rw_contas.vlsdeved -- Saldo devedor atualizado, atualizar o valor a cada endosso
            ,to_date('31-07-2020', 'dd-mm-yyyy') -- Data referencia para cobranca
            ,vr_dtfimvig -- fim da vigencia
            ,to_date('31-07-2020', 'dd-mm-yyyy') -- Envio mensal dos endossos
             );

        vr_countcom := vr_countcom + 1;
      EXCEPTION
        WHEN OTHERS THEN
          -- Erro não tratado
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir tbseg_prestamista - Conta: ' || rw_contas.nrdconta || '' || '' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , 'DELETE FROM tbseg_prestamista ' || chr(13) || 
                              ' WHERE cdcooper = ' || rw_crapcop.cdcooper || chr(13) ||
                              '   AND nrdconta = ' || rw_contas.nrdconta  || chr(13) ||
                              '   AND nrctremp = ' || rw_contas.nrctremp  || '; ' ||chr(13)||chr(13), FALSE);     

      -------------------------------------------------------------------------------------------------------------------------------------------------------
      -- Geração das linhas do txt
      -- Vamos fazer a inserção e geração ao mesmo tempo
      
      vr_linha_txt := '';
      vr_pref_adesao := '';
      vr_pref_endoss := '';
      -- informacoes para impressao
      vr_linha_txt := vr_linha_txt || 'BZBCC' || LPAD(vr_nrapolic, 10, 0); -- Nº Apólice / Certificado
      vr_linha_txt := vr_linha_txt || RPAD(to_char(rw_contas.nrcpfcgc,'fm00000000000'), 14, ' '); -- CPF / CNPJ - sem formatacao
      vr_linha_txt := vr_linha_txt || LPAD(' ', 20, ' '); -- Cód.Empregado
      vr_linha_txt := vr_linha_txt || RPAD(UPPER(gene0007.fn_caract_especial(rw_contas.nmprimtl)), 70, ' '); -- Nome completo do cliente
      vr_linha_txt := vr_linha_txt || LPAD(to_char(to_date(rw_contas.dtnasctl), 'RRRR-MM-DD'), 10, 0); -- Data Nascimento
      vr_linha_txt := vr_linha_txt || LPAD(nvl(to_char(rw_contas.cdsexotl), ' '), 2, 0); -- Sexo
      vr_linha_txt := vr_linha_txt || RPAD(UPPER(gene0007.fn_caract_especial(rw_crapenc.dsendres)), 60, ' '); -- Endereço
      vr_linha_txt := vr_linha_txt || RPAD(UPPER(gene0007.fn_caract_especial(rw_crapenc.nmbairro)), 30, ' '); -- Bairro
      vr_linha_txt := vr_linha_txt || RPAD(UPPER(gene0007.fn_caract_especial(rw_crapenc.nmcidade)), 30, ' '); -- Cidade
      vr_linha_txt := vr_linha_txt || RPAD(nvl(to_char(rw_crapenc.cdufresd), '  '),2,' '); -- UF
      vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_crapenc.nrcepend, 'zzzzz-zz9'), 10, ' '); -- CEP

      IF length(rw_craptfc.nrtelefo) = 11 THEN
        vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_craptfc.nrtelefo, '(99)99999-9999'), 15, ' '); -- Telefone Residencial
      ELSIF length(rw_craptfc.nrtelefo) = 10 THEN
        vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_craptfc.nrtelefo, '(99)9999-9999'), 15, ' '); -- Telefone Residencial
      ELSE
        vr_linha_txt := vr_linha_txt || RPAD(gene0002.fn_mask(rw_craptfc.nrtelefo, '99999-9999'), 15, ' '); -- Telefone Residencial
      END IF;
      
      vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Telefone Comercial
      vr_linha_txt := vr_linha_txt || RPAD(' ', 15, ' '); -- Telefone Celular
      IF rw_crapcem.dsdemail IS NOT NULL THEN
        vr_linha_txt := vr_linha_txt || RPAD('Y', 1, ' '); -- E-mail Fulfillment
      ELSE
        vr_linha_txt := vr_linha_txt || RPAD(' ', 1, ' '); -- E-mail Fulfillment
      END IF;
      vr_linha_txt := vr_linha_txt || RPAD(nvl(rw_crapcem.dsdemail, ' '), 50, ' '); -- E-mail
      vr_linha_txt := vr_linha_txt || RPAD(' ', 12, ' ');         -- Cód.Campanha
      vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' ');         -- Cód.Vendedor
      vr_linha_txt := vr_linha_txt || RPAD(vr_nrctrseg, 30, ' '); -- Nº Proposta
      vr_linha_txt := vr_linha_txt || LPAD(to_char(to_date(SYSDATE), 'RRRR-MM-DD'), 10, 0); -- Data Transação (Data da venda) / Data Cancelamento
      vr_linha_txt := vr_linha_txt || LPAD(to_char(to_date(SYSDATE), 'RRRR-MM-DD'), 10, 0); -- Inicio Vigência
      vr_linha_txt := vr_linha_txt || LPAD(' ', 2, ' '); -- Razão Cancelam/Suspensão
      --  Referencia 1 50 pos - Contratos vinculados
    
      vr_linha_txt := vr_linha_txt || LPAD(nvl(to_char(rw_contas.nrctremp), 0), 10, 0); -- Referencia 6 - nrctremp
    
      vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##2
      vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##3
      vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##4
      vr_linha_txt := vr_linha_txt || LPAD(' ', 10, ' '); -- nrctremp##5
    
      vr_linha_txt := vr_linha_txt || RPAD(LPAD(rw_crapcop.cdcooper, 3, 0),50,' '); -- Referencia 7 - Cooperativa
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' ');      -- Referencia 3 - Nº da Sorte
      vr_linha_txt := vr_linha_txt || '10';                  -- Meio Cobrança
      vr_linha_txt := vr_linha_txt || RPAD(' ', 3, ' ');     -- Cód.Administr.Cobrança BY e BC
      vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' ');    -- Cód. Banco
      vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' ');    -- Cód.Agência
      vr_linha_txt := vr_linha_txt || RPAD(' ', 2, ' ');     -- Cód.Admin.Cartão Crédito
      vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' ');    -- Nº Conta Corrente
      vr_linha_txt := vr_linha_txt || RPAD(' ', 5, ' ');     -- Validade Cartão Crédito
      vr_linha_txt := vr_linha_txt || RPAD(' ', 10, ' ');    -- Data Cobrança          
      vr_linha_txt := vr_linha_txt || RPAD('M', 2, ' ');     -- Frequência Cobrança
      vr_linha_txt := vr_linha_txt || RPAD('MI', 2, ' ');    -- Tipo Segurado
      vr_linha_txt := vr_linha_txt || 'BCV012';              -- Produto - Cód.Produto
      vr_linha_txt := vr_linha_txt || '1';                   -- Produto - Plano
      vr_linha_txt := vr_linha_txt || LPAD(replace(to_char(vr_vlprodvl,'fm99999990d00'), ',', '.'), 12, 0); -- Produto – Valor
      vr_linha_txt := vr_linha_txt || LPAD('O', 1, ' ');                                               -- Tipo de Cobrança
      vr_linha_txt := vr_linha_txt || LPAD(replace(to_char(vr_vlenviad,'fm999999999999990d00'), ',', '.'), 30, 0); -- Valor do Saldo Devedor Atualizado
      vr_linha_txt := vr_linha_txt || LPAD(to_char(to_date('31-07-2020', 'dd-mm-yyyy'), 'RRRR-MM-DD'), 10, 0); -- Data Referência para Cobrança
      vr_linha_txt := vr_linha_txt || LPAD(to_char(to_date(vr_dtfimvig), 'RRRR-MM-DD'), 10, 0);        -- Data final de vigência contrato
    
      -- Opcionais nao enviados
      vr_linha_txt := vr_linha_txt || RPAD(' ', 20, ' '); -- Data/Hora Autorização – SITEF
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 1 – Dados do risco
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 2 – Dados do risco
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 3 – Dados do risco
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 4 – Dados do risco
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 5 – Dados do risco
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 6 – Dados do risco
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 7 – Dados do risco
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 8 – Dados do risco
      vr_linha_txt := vr_linha_txt || LPAD(' ', 50, ' '); -- PSD 9 – Dados do risco
      vr_linha_txt := vr_linha_txt || LPAD(' ', 89, ' '); -- Código Identificador do Cartão de Crédito (cardHash) – Software Express
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
      
      IF vr_flgnenvi = 0 THEN
        -- prefixo para linha de adesao
        vr_pref_adesao := vr_pref_adesao || LPAD(vr_idseqtra, 5, 0); -- Sequencial Transação
        vr_pref_adesao := vr_pref_adesao || LPAD(1, 2, 0); -- Tipo Registro - 01 Adesao
        vr_idseqtra := vr_idseqtra + 1;
        -- prefixo para linha de endosso
        vr_pref_endoss := vr_pref_endoss || LPAD(vr_idseqtra, 5, 0); -- Sequencial Transação
        vr_pref_endoss := vr_pref_endoss || LPAD(3, 2, 0); -- Tipo Registro - 03 Endosso
        vr_idseqtra := vr_idseqtra + 1;
        
        -- Escrever Linha do Arquivo 
        GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo, vr_pref_adesao || vr_linha_txt); -- adesao
        GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo, vr_pref_endoss || vr_linha_txt); -- endosso
        
      END IF;

      -- commit a cada 10 mil registros
      IF MOD(vr_countcom, 10000) = 0 THEN
        COMMIT;
      END IF;
      
    END LOOP;
  
    -- Fechar o arquivo
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);
    
    -- UX2DOS
    GENE0003.pc_converte_arquivo(pr_cdcooper => vr_cdcooper                   --> Cooperativa
                                ,pr_nmarquiv => vr_nmdireto||'/'||vr_nmarquiv        --> Caminho e nome do arquivo a ser convertido
                                ,pr_nmarqenv => vr_nmarquiv           --> Nome desejado para o arquivo convertido
                                ,pr_des_erro => vr_dscritic);                 --> Retorno da critica

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
        
    -- Adiciona TAG de commit rollback
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
        
    -- Fecha o arquivo rollback
    gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);    

    vr_nmarqimp  := 'EMPRESTIMOS_SEM_SEG_'||rw_crapcop.dsdircop||'.csv';
    vr_nmarqbkp  := 'ROLLBACK_PRJ0015011_'||upper(rw_crapcop.dsdircop)||'_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
    
    gene0002.pc_escreve_xml(vr_dados_er, vr_texto_er, chr(13), TRUE);
    
    -- Grava arquivo de contas alteradas
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => vr_cdcooper                   --> Cooperativa conectada
                                       ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                       ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                       ,pr_dsxml     => vr_dados_er                   --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqimp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                       ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
    
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Grava o arquivo de rollback
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => vr_cdcooper                     --> Cooperativa conectada
                                       ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                       ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                       ,pr_dsxml     => vr_dados_rollback             --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                       ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
        
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;   
    
    dbms_lob.close(vr_dados_er);
    dbms_lob.freetemporary(vr_dados_er);   
    
    dbms_lob.close(vr_dados_rollback);
    dbms_lob.freetemporary(vr_dados_rollback);   
    
    --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
    cecred.pc_log_programa(pr_dstiplog   => 'F',
                           pr_cdprograma => vr_cdprogra,
                           pr_cdcooper   => vr_cdcooper,
                           pr_tpexecucao => 2, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_idprglog   => vr_idprglog);
  
    COMMIT;
  
  END LOOP; -- Loop crapcop

EXCEPTION
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    dbms_output.put_line(vr_dscritic);
    ROLLBACK;
    
    -- Envio centralizado de log de erro
    cecred.pc_log_programa(pr_dstiplog           => 'E',         -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                           pr_cdprograma         => vr_cdprogra, -- tbgen_prglog
                           pr_cdcooper           => vr_cdcooper, -- tbgen_prglog
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
                               pr_des_corpo   => vr_dscritic,
                               pr_des_anexo   => NULL,
                               pr_flg_enviar  => 'S',
                               pr_des_erro    => vr_dscritic); 
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    vr_dscritic := SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    dbms_output.put_line(vr_dscritic);
    ROLLBACK;
    
    -- Envio centralizado de log de erro
    cecred.pc_log_programa(pr_dstiplog           => 'E',         -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                           pr_cdprograma         => vr_cdprogra, -- tbgen_prglog
                           pr_cdcooper           => vr_cdcooper, -- tbgen_prglog
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
                               pr_des_corpo   => vr_dscritic,
                               pr_des_anexo   => NULL,
                               pr_flg_enviar  => 'S',
                               pr_des_erro    => vr_dscritic); 
END;
