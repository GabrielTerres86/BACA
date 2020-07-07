DECLARE
  vr_tipo_saida VARCHAR2(100);
  vr_endereco   VARCHAR2(100);
  vr_login      VARCHAR2(100);
  vr_senha      VARCHAR2(100);
  vr_nrapolic   VARCHAR2(100);
  vr_dsdircop   VARCHAR2(50);
  vr_nmdircop   VARCHAR2(100);
  vr_nmarquiv   VARCHAR2(100);
  vr_linha_txt  VARCHAR2(32600);
  vr_xml_temp   VARCHAR2(32726) := ''; --> Temp xml/csv 
  vr_clob       CLOB; --> Clob buffer do xml gerado

  vr_seqtran    INTEGER;
  vr_dtfimvig   DATE;
  vr_cdcooper   crapcop.cdcooper%TYPE;
  vr_nrsequen   NUMBER(10);
  rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE;

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
  
  
  vr_flgprestamista varchar2(1) := 'N';
  vr_flgdps         varchar2(1) := 'N';
  vr_vlproposta     crawseg.vlseguro%type;
  vr_dsmotcan       VARCHAR2(60);
  vr_inusatab       BOOLEAN := FALSE;
  vr_sld_devedor    crawseg.vlseguro%type;
  vr_vltotpre       NUMBER := 0;
  vr_qtprecal       NUMBER := 0;
  vr_nrctrseg       crapseg.nrctrseg%TYPE;

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
  
  -- Cursor principal de contas com contratos ativos em linhas de crédito com prestamista
  CURSOR cr_contas(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT a.nrdconta
          ,e.nrctremp
          ,t.idseqttl
          ,DECODE(a.cdsexotl, 1, '2', 2, '1', '0') cdsexotl -- sexo
          ,a.nrcpfcgc
          ,a.nmprimtl
          ,a.dtnasctl
          ,e.dtmvtolt
      FROM crapass a, crapepr e, craplcr l, crapttl t
     WHERE a.cdcooper = pr_cdcooper
       AND e.cdcooper = a.cdcooper
       AND e.nrdconta = a.nrdconta
       AND l.cdcooper = e.cdcooper
       AND l.cdlcremp = e.cdlcremp
       AND l.flgsegpr = 1 -- liha de credito que permite prestamista
       AND a.inpessoa = 1 -- pessoa fisica
       AND e.inliquid = 0 -- nao liquidado
       AND e.inprejuz = 0 -- sem prejuizo
       AND t.cdcooper = a.cdcooper
       AND t.nrdconta = a.nrdconta
       AND NOT EXISTS (SELECT 1  -- garantir que nao existe na tbseg
                         FROM tbseg_prestamista p
                        WHERE p.cdcooper = e.cdcooper
                          AND p.nrdconta = e.nrdconta
                          AND e.nrctremp IN (nrctremp));
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
  
BEGIN

  vr_nrsequen := fn_sequence('TBSEG_PRESTAMISTA', 'SEQCERTIFICADO', 0);
  vr_destinatario_email := gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_EMAIL'); -- seguros@ailos.com.br
  
  -- para cada cooperativa...
  FOR rw_crapcop IN cr_crapcop LOOP
    vr_cdcooper := rw_crapcop.cdcooper; -- Para log em caso de exceção imprevista
  
    -- Calendario da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
  
    vr_nmdircop := gene0001.fn_diretorio(pr_tpdireto => 'C', --> /usr/coop
                                         pr_cdcooper => rw_crapcop.cdcooper);
  
    vr_nmarquiv := vr_vet_prefixo(rw_crapcop.cdcooper) || '_' ||
                   REPLACE(to_char(rw_crapdat.dtmvtolt, 'YYYY/MM/DD'), '/', '') || '_' ||
                   gene0002.fn_mask(vr_nrsequen, '99999') || 'MOV.txt';
  
    -- Leitura da sequencia na tab
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper,
                                              pr_nmsistem => 'CRED',
                                              pr_tptabela => 'USUARI',
                                              pr_cdempres => 11,
                                              pr_cdacesso => 'SEGPRESTAM',
                                              pr_tpregist => 0);
  
    -- Dados da conexao FTP
    vr_endereco := SUBSTR(vr_dstextab, 107, 16);
    vr_login    := SUBSTR(vr_dstextab, 124, 6); 
    vr_senha    := SUBSTR(vr_dstextab, 131, 7); 
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

    vr_seqtran := 1;
    
    -- Inicializa CLOB
    dbms_lob.createtemporary(vr_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
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

    --
    FOR rw_contas IN cr_contas(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      
      -- Validar necessidade de adição na tabela - aqui já é validado o saldo devedor 
      SEGU0003.pc_validar_prestamista(pr_cdcooper        => rw_crapcop.cdcooper
                                     ,pr_nrdconta        => rw_contas.nrdconta
                                     ,pr_nrctremp        => rw_contas.nrctremp
                                     ,pr_cdagenci        => 1
                                     ,pr_nrdcaixa        => 1
                                     ,pr_cdoperad        => 1
                                     ,pr_nmdatela        => 'ATENDA'
                                     ,pr_idorigem        => 7
                                     ,pr_valida_proposta => 'N'
                                     ,pr_sld_devedor     => vr_vlproposta
                                     ,pr_flgprestamista  => vr_flgprestamista
                                     ,pr_flgdps          => vr_flgdps
                                     ,pr_dsmotcan        => vr_dsmotcan
                                     ,pr_cdcritic        => vr_cdcritic
                                     ,pr_dscritic        => vr_dscritic);
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;

      -- Validamos se vamos criar o registro
      IF vr_flgprestamista = 'N' THEN
        CONTINUE;
      END IF;
      
      /* Definir como zero para passar no in out */
      vr_sld_devedor := 0;
      vr_vltotpre    := 0;
      vr_qtprecal    := 0;
      
      EMPR0001.pc_saldo_devedor_epr(pr_cdcooper   => rw_crapcop.cdcooper,    --> Cooperativa conectada
                                    pr_cdagenci   => 1,                      --> Codigo da agencia
                                    pr_nrdcaixa   => 1,                      --> Numero do caixa
                                    pr_cdoperad   => 1,                      --> Codigo do operador
                                    pr_nmdatela   => 'ATENDA',               --> Nome da tela conectada
                                    pr_idorigem   => 7,                      --> Indicador da origem da chamada
                                    pr_nrdconta   => rw_contas.nrdconta,     --> Conta do associado
                                    pr_idseqttl   => rw_contas.idseqttl,     --> Sequencia de titularidade da conta
                                    pr_rw_crapdat => rw_crapdat,             --> Vetor com dados de parametro (CRAPDAT)
                                    pr_nrctremp   => rw_contas.nrctremp,     --> Numero contrato emprestimo
                                    pr_cdprogra   => 'SEGU0003',             --> Programa conectado
                                    pr_inusatab   => vr_inusatab,            --> Indicador de utilizacão da tabela
                                    pr_flgerlog   => 'N',                    --> Gerar log S/N
                                    pr_vlsdeved   => vr_sld_devedor,         --> Saldo devedor calculado
                                    pr_vltotpre   => vr_vltotpre,            --> Valor total das prestacães
                                    pr_qtprecal   => vr_qtprecal,            --> Parcelas calculadas
                                    pr_des_reto   => vr_des_reto,            --> Retorno OK / NOK
                                    pr_tab_erro   => vr_tab_erro);           --> Tabela com possives erros   
      -- Se houve retorno de erro
      IF vr_des_reto = 'NOK' THEN
        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        -- Limpar tabela de erros
        vr_tab_erro.DELETE;
        RAISE vr_exc_saida; -- encerra programa
      END IF;

      vr_vlprodvl := vr_sld_devedor * (vr_pgtosegu/100); -- Produto – Valor
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
      vr_dtfimvig := rw_crappep.dtvencto;
      
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
        CLOSE cr_crapseg;
        vr_nrctrseg := rw_crapseg.nrctrseg;
      ELSE
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
            ,rw_contas.nmprimtl -- nome
            ,rw_contas.dtnasctl -- data de nasc
            ,rw_contas.cdsexotl -- sexo
            ,rw_crapenc.dsendres -- Endereço
            ,rw_crapcem.dsdemail -- email
            ,rw_crapenc.nmbairro -- Bairro
            ,rw_crapenc.nmcidade -- Cidade
            ,rw_crapenc.cdufresd -- UF
            ,rw_crapenc.nrcepend -- CEP
            ,rw_craptfc.nrtelefo -- Telefone Residencial --x
            ,SYSDATE -- data da venda
            ,SYSDATE -- inicio da vigencia
            ,rw_contas.nrctremp -- Emprestimo vinculado
            ,10 -- Meio de cobranca (fixo 10 - Software Express)
            ,'' --BY ou BC -- Cód.Administr.Cobrança
            ,'M' -- Frequência Cobrança  Mensal: M
            ,'MI' -- Tipo Segurado  Titular: MI
            ,'BCV012' -- codigo
            ,1 -- plano
            ,vr_vlprodvl -- valor
            ,'O' -- Tipo de cobranca (fixo O - Online)
            ,vr_sld_devedor -- Saldo Devedor
            ,vr_sld_devedor -- Saldo devedor atualizado, atualizar o valor a cada endosso
            ,rw_contas.dtmvtolt -- Data referencia para cobranca
            ,vr_dtfimvig -- fim da vigencia
            ,rw_crapdat.dtmvtolt -- Envio mensal dos endossos
             );
        
      EXCEPTION
        WHEN OTHERS THEN
          -- Erro não tratado
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir tbseg_prestamista - Conta: ' || rw_contas.nrdconta || '' || '' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      -------------------------------------------------------------------------------------------------------------------------------------------------------
      -- Geração das linhas do txt
      -- Vamos fazer a inserção e geração ao mesmo tempo
      
      vr_linha_txt := '';
      -- informacoes para impressao
      vr_linha_txt := vr_linha_txt || LPAD(vr_seqtran, 5, 0); -- Sequencial Transação
      vr_linha_txt := vr_linha_txt || LPAD(1, 2, 0); -- Tipo Registro
      vr_linha_txt := vr_linha_txt || 'BZBCC' || LPAD(vr_nrapolic, 10, 0); -- Nº Apólice / Certificado
      vr_linha_txt := vr_linha_txt || RPAD(rw_contas.nrcpfcgc, 14, ' '); -- CPF / CNPJ - sem formatacao
      vr_linha_txt := vr_linha_txt || LPAD(' ', 20, ' '); -- Cód.Empregado
      vr_linha_txt := vr_linha_txt || RPAD(UPPER(gene0007.fn_caract_acento(rw_contas.nmprimtl)), 70, ' '); -- Nome completo do cliente
      vr_linha_txt := vr_linha_txt || LPAD(to_char(to_date(rw_contas.dtnasctl), 'RRRR-MM-DD'), 10, 0); -- Data Nascimento
      vr_linha_txt := vr_linha_txt || LPAD(nvl(to_char(rw_contas.cdsexotl), ' '), 2, 0); -- Sexo
      vr_linha_txt := vr_linha_txt || RPAD(UPPER(gene0007.fn_caract_acento(rw_crapenc.dsendres)), 60, ' '); -- Endereço
      vr_linha_txt := vr_linha_txt || RPAD(UPPER(gene0007.fn_caract_acento(rw_crapenc.nmbairro)), 30, ' '); -- Bairro
      vr_linha_txt := vr_linha_txt || RPAD(UPPER(gene0007.fn_caract_acento(rw_crapenc.nmcidade)), 30, ' '); -- Cidade
      vr_linha_txt := vr_linha_txt || nvl(to_char(rw_crapenc.cdufresd), ' '); -- UF
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
    
      vr_linha_txt := vr_linha_txt || LPAD(rw_crapcop.cdcooper, 3, 0); -- Referencia 7 - Cooperativa
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
      vr_linha_txt := vr_linha_txt || LPAD(REPLACE(vr_vlprodvl, ',', '.'), 12, 0);                     -- Produto – Valor
      vr_linha_txt := vr_linha_txt || LPAD('O', 1, ' ');                                               -- Tipo de Cobrança
      vr_linha_txt := vr_linha_txt || LPAD(REPLACE(vr_sld_devedor, ',', '.'), 30, 0);                  -- Valor do Saldo Devedor Atualizado
      vr_linha_txt := vr_linha_txt || LPAD(to_char(to_date(rw_contas.dtmvtolt), 'RRRR-MM-DD'), 10, 0); -- Data Referência para Cobrança
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
    
      -- escreve linha no arquivo xml
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob,
                              pr_texto_completo => vr_xml_temp,
                              pr_texto_novo     => vr_linha_txt);
    
      vr_seqtran := vr_seqtran + 1;
    
    END LOOP;
  
    -- Encerrar o Clob
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => chr(13),
                            pr_fecha_xml      => TRUE);
  
    -- Grava arquivo de contas alteradas
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => vr_cdcooper, --> Cooperativa conectada
                                        pr_cdprogra  => 'ATENDA', --> Programa chamador - utilizamos apenas um existente 
                                        pr_dtmvtolt  => trunc(SYSDATE), --> Data do movimento atual
                                        pr_dsxml     => vr_clob, --> Arquivo XML de dados
                                        pr_dsarqsaid => vr_nmdircop || '/arq/' || vr_nmarquiv, --> Path/Nome do arquivo PDF gerado
                                        pr_flg_impri => 'N', --> Chamar a impressão (Imprim.p)
                                        pr_flg_gerar => 'S', --> Gerar o arquivo na hora
                                        pr_flgremarq => 'N', --> remover arquivo apos geracao
                                        pr_nrcopias  => 1, --> Número de cópias para impressão
                                        pr_des_erro  => vr_dscritic); --> Retorno de Erro
  
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := vr_dscritic || ' Cooperativa: ' || vr_cdcooper;
      RAISE vr_exc_saida;
    END IF;
  
    ESMS0001.pc_processa_arquivo_ftp(pr_nmarquiv => vr_nmarquiv, --> Nome arquivo a enviar
                                     pr_idoperac => 'E', --> Envio de arquivo
                                     pr_nmdireto => vr_nmdircop, --> Diretório do arquivo a enviar
                                     pr_idenvseg => 'S', --> Indicador de utilizacao de protocolo seguro (SFTP)
                                     pr_ftp_site => vr_endereco, --> Site de acesso ao FTP
                                     pr_ftp_user => vr_login, --> Usuário para acesso ao FTP
                                     pr_ftp_pass => vr_senha, --> Senha para acesso ao FTP
                                     pr_ftp_path => 'prestamista', --> Pasta no FTP para envio do arquivo
                                     pr_dscritic => vr_dscritic);
  
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro ao processar arquivo via FTP - Cooperativa: ' || vr_cdcooper || ' - ' ||
                     vr_dscritic;
      RAISE vr_exc_saida;
    END IF;
  
    -- Mover o arquivo processado para a pasta "salvar" 
    gene0001.pc_OScommand_Shell(pr_des_comando => 'mv ' || vr_nmdircop || '/arq/' || vr_nmarquiv || ' ' ||
                                                  vr_nmdircop || '/salvar',
                                pr_typ_saida   => vr_tipo_saida,
                                pr_des_saida   => vr_dscritic);
    -- Testa erro
    IF vr_tipo_saida = 'ERR' THEN
      vr_dscritic := 'Erro ao mover o arquivo - Cooperativa: ' || vr_cdcooper || ' - ' ||
                     vr_dscritic;
      RAISE vr_exc_saida;
    END IF;
  
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);
    dbms_lob.freetemporary(vr_clob);
  
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
