CREATE OR REPLACE PACKAGE cecred.tela_atenda_portab IS

    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : TELA_ATENDA_PORSOL
    --  Sistema  : Procedimentos para tela Atenda / Portabilidade de Salario
    --  Sigla    : CRED
    --  Autor    : Anderson Alan - Supero
    --  Data     : Setembro/2018.
    --
    -- Frequencia: -----
    -- Objetivo  : Procedimentos para retorno das informações da Atenda Portabilidade de Salário
    --
    -- Alteracoes:
    ---------------------------------------------------------------------------------------------------------------

    PROCEDURE pc_busca_dados(pr_nrdconta IN crapcdr.nrdconta%TYPE --> Numero da conta
                            ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2); --> Descricao do erro

    PROCEDURE pc_busca_bancos_folha(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2); --> Descricao do erro

    PROCEDURE pc_solicita_portabilidade(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                       ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE --> Codigo do banco folha
                                       ,pr_nrispbif IN crapban.nrispbif%TYPE --> ISPB do banco folha
                                       ,pr_nrcnpjif IN crapban.nrcnpjif%TYPE --> CNPJ do banco folha
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2); --> Descricao do erro

    PROCEDURE pc_busca_motivos_cancelamento(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                           ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2); --> Descricao do erro

    PROCEDURE pc_cancela_portabilidade(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                      ,pr_cdmotivo IN tbcc_portabilidade_envia.cdmotivo%TYPE --> Motivo do cancelamento
                                      ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2); --> Descricao do erro

    PROCEDURE pc_imprimir_termo_portab(pr_dsrowid  IN VARCHAR2 --> Rowid da tabela
                                      ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2); --> Descricao do erro

END tela_atenda_portab;
/
CREATE OR REPLACE PACKAGE BODY cecred.tela_atenda_portab IS

    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : TELA_ATENDA_PORTAB
    --  Sistema  : Procedimentos para tela Atenda / Portabilidade de Salario
    --  Sigla    : CRED
    --  Autor    : Anderson Alan - Supero
    --  Data     : Setembro/2018.                
    --
    -- Frequencia: -----
    -- Objetivo  : Procedimentos para retorno das informações da Atenda Portabilidade de Salário
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------

    PROCEDURE pc_busca_dados(pr_nrdconta IN crapcdr.nrdconta%TYPE --> Numero da conta
                            ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_busca_dados
        Sistema : Ayllos Web
        Autor   : Anderson Alan
        Data    : Setembro/2018                 Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para buscar os dados.
        
        Alteracoes: -----
        ..............................................................................*/
        DECLARE
        
            -- Selecionar o CPF, Nome
            CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
                SELECT crapass.nrcpfcgc
                      ,crapass.nmprimtl
                  FROM crapass
                 WHERE crapass.cdcooper = pr_cdcooper
                   AND crapass.nrdconta = pr_nrdconta;
        
            -- Seleciona o Telefone
            CURSOR cr_craptfc(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
                SELECT *
                  FROM (SELECT '(' || to_char(craptfc.nrdddtfc) || ')' || craptfc.nrtelefo
                          FROM craptfc
                         WHERE craptfc.cdcooper = pr_cdcooper
                           AND craptfc.nrdconta = pr_nrdconta
                           AND craptfc.tptelefo IN (1, 2, 3)
                         ORDER BY CASE tptelefo
                                      WHEN 2 THEN -- priorizar celular
                                       0
                                      ELSE -- demais telefones
                                       tptelefo
                                  END ASC)
                 WHERE rownum = 1; -- retorna apenas uma ocorrencia conforme prioridade na ordenacao
        
            -- Selecionar o Email
            CURSOR cr_crapcem(pr_cdcooper IN crapenc.cdcooper%TYPE
                             ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
                SELECT *
                  FROM (SELECT crapcem.dsdemail
                          FROM crapcem
                         WHERE crapcem.cdcooper = pr_cdcooper
                           AND crapcem.nrdconta = pr_nrdconta
                         ORDER BY crapcem.dtmvtolt
                                 ,crapcem.hrtransa DESC)
                 WHERE rownum = 1; -- retorna apenas uma ocorrencia
        
            -- Selecionar o codigo da empresa
            CURSOR cr_crapttl(pr_cdcooper IN crapenc.cdcooper%TYPE
                             ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
                SELECT crapttl.nrcpfemp
                      ,crapttl.nmextemp
                  FROM crapttl
                 WHERE crapttl.cdcooper = pr_cdcooper
                   AND crapttl.nrdconta = pr_nrdconta
                   AND crapttl.idseqttl = 1;
        
            -- Seleciona a Instituicao Destinatario
            CURSOR cr_crapban_crapcop(pr_cdcooper IN crapenc.cdcooper%TYPE) IS
                SELECT b.nrispbif
                      ,c.nrdocnpj
                      ,c.cdagectl
                  FROM crapban b
                      ,crapcop c
                 WHERE b.cdbccxlt = c.cdbcoctl
                   AND c.cdcooper = pr_cdcooper;
        
            -- Seleciona Portab Envia
            CURSOR cr_portab_envia(pr_cdcooper IN crapenc.cdcooper%TYPE
                                  ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
                SELECT '(' || to_char(nrddd_telefone) || ')' || nrtelefone AS telefone
                      ,dsdemail
                      ,situacao
                      ,cdsituacao
                      ,motivo
                      ,cdmotivo
                      ,to_char(dtsolicitacao, 'DD/MM/RRRR HH24:MI:SS') AS dtsolicitacao
                      ,to_char(dtretorno, 'DD/MM/RRRR HH24:MI:SS') AS dtretorno
                      ,to_char(nrnu_portabilidade) AS nrnu_portabilidade
                      ,cdbanco_folha
                      ,nrispb_banco_folha
                      ,nrcnpj_banco_folha
                      ,dsrowid
                      ,to_char(nrnu_portabilidade_r) AS nrnu_portabilidade_r
                      ,to_char(dtsolicitacao_r, 'DD/MM/RRRR HH24:MI:SS') AS dtsolicitacao_r
                      ,nrcnpj_empregador_r
                      ,dsnome_empregador_r
                      ,banco
                      ,cdagencia_destinataria_r
                      ,nrdconta_destinataria_r
                  FROM (SELECT tpe.nrddd_telefone
                              ,tpe.nrtelefone
                              ,tpe.dsdemail
                              ,dom.dscodigo AS situacao
                              ,dom.cddominio AS cdsituacao
                              ,dcp.dscodigo AS motivo
                              ,dcp.cddominio AS cdmotivo
                              ,tpe.dtsolicitacao AS dtsolicitacao
                              ,tpe.dtretorno
                              ,tpe.nrnu_portabilidade
                              ,tpe.cdbanco_folha
                              ,tpe.nrispb_banco_folha
                              ,tpe.nrcnpj_banco_folha
                              ,tpe.rowid AS dsrowid
                              ,tpr.nrnu_portabilidade AS nrnu_portabilidade_r
                              ,tpr.dtsolicitacao AS dtsolicitacao_r
                              ,tpr.nrcnpj_empregador AS nrcnpj_empregador_r
                              ,tpr.dsnome_empregador AS dsnome_empregador_r
                              ,lpad(ban.cdbccxlt, 3, '0') || ' - ' || ban.nmresbcc banco
                              ,tpr.cdagencia_destinataria AS cdagencia_destinataria_r
                              ,tpr.nrdconta_destinataria AS nrdconta_destinataria_r
                          FROM tbcc_portabilidade_envia  tpe
                              ,tbcc_portabilidade_recebe tpr
                              ,tbcc_dominio_campo        dom
                              ,tbcc_dominio_campo        dcp
                              ,crapban                   ban
                         WHERE tpe.idsituacao = dom.cddominio
                           AND ban.nrispbif(+) = tpr.nrispb_destinataria
                           AND dom.nmdominio = 'SIT_PORTAB_SALARIO_ENVIA'
                           AND dcp.nmdominio(+) = tpe.dsdominio_motivo
                           AND dcp.cddominio(+) = tpe.cdmotivo
                           AND tpr.nrnu_portabilidade(+) = tpe.nrnu_portabilidade
                           AND tpe.nrdconta = pr_nrdconta
                           AND tpe.cdcooper = pr_cdcooper
                         ORDER BY tpe.dtsolicitacao DESC)
                 WHERE rownum = 1;
            -- AND motivo IS NOT NULL; debug
            rw_portab_envia cr_portab_envia%ROWTYPE;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_erro EXCEPTION;
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            vr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
        
            -- Variaveis para CADA0008.pc_busca_inf_emp
            vr_nmpessoa tbcadast_pessoa.nmpessoa%TYPE;
            vr_idaltera PLS_INTEGER;
            vr_idseqttl crapttl.idseqttl%TYPE := 1;
            vr_nrdocnpj VARCHAR2(100);
            vr_cdempres crapemp.cdempres%TYPE;
            vr_nmpessot tbcadast_pessoa.nmpessoa%TYPE;
            vr_nrcnpjot crapemp.nrdocnpj%TYPE;
            vr_nmempout crapemp.nmresemp%TYPE;
            vr_cdemprot crapemp.cdempres%TYPE;
        
            -- Variaveis Gerais
            vr_nrcpfcgc     crapass.nrcpfcgc%TYPE;
            vr_nmprimtl     crapass.nmprimtl%TYPE;
            vr_nrtelefo     VARCHAR2(100);
            vr_dsdemail     crapcem.dsdemail%TYPE;
            vr_nrispbif_cop crapban.nrispbif%TYPE;
            vr_nrdocnpj_cop VARCHAR2(100);
            vr_cdagectl_cop crapcop.cdagectl%TYPE;
        
        BEGIN
            -- Incluir Nome do Módulo Logado
            gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
        
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            -- Criar cabecalho do XML
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
        
            -- Selecionar o CPF, Nome
            OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
            FETCH cr_crapass
                INTO vr_nrcpfcgc
                    ,vr_nmprimtl;
            IF cr_crapass%NOTFOUND THEN
                vr_dscritic := 'Cooperado não encontrado.';
                RAISE vr_exc_erro;
            END IF;
            CLOSE cr_crapass;
        
            -- Selecionar o Telefone
            OPEN cr_craptfc(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
            FETCH cr_craptfc
                INTO vr_nrtelefo;
            CLOSE cr_craptfc;
        
            -- Selecionar o Email
            OPEN cr_crapcem(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
            FETCH cr_crapcem
                INTO vr_dsdemail;
            CLOSE cr_crapcem;
        
            -- Selecionar o codigo da empresa
            OPEN cr_crapttl(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
            FETCH cr_crapttl
                INTO vr_nrdocnpj
                    ,vr_nmpessot;
        
            IF cr_crapttl%NOTFOUND THEN
                vr_dscritic := 'Codigo da empresa do titular da conta não encontrado.';
                RAISE vr_exc_erro;
            END IF;
            CLOSE cr_crapttl;
        
            -- Selecionar a instituicao destinataria
            OPEN cr_crapban_crapcop(pr_cdcooper => vr_cdcooper);
            FETCH cr_crapban_crapcop
                INTO vr_nrispbif_cop
                    ,vr_nrdocnpj_cop
                    ,vr_cdagectl_cop;
            IF cr_crapban_crapcop%NOTFOUND THEN
                vr_dscritic := 'Instituição Destinatária não encontrada.';
                RAISE vr_exc_erro;
            END IF;
            CLOSE cr_crapban_crapcop;
        
            -- Seleciona Portab Envia
            OPEN cr_portab_envia(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
            FETCH cr_portab_envia
                INTO rw_portab_envia;
            CLOSE cr_portab_envia;
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Root'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Dados'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nrdconta'
                                  ,pr_tag_cont => gene0002.fn_mask_conta(pr_nrdconta)
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nrcpfcgc'
                                  ,pr_tag_cont => gene0002.fn_mask_cpf_cnpj(vr_nrcpfcgc, 1)
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nmprimtl'
                                  ,pr_tag_cont => vr_nmprimtl
                                  ,pr_des_erro => vr_dscritic);
        
            IF TRIM(rw_portab_envia.telefone) IS NOT NULL AND TRIM(rw_portab_envia.dsdemail) IS NOT NULL THEN
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Dados'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'nrtelefo'
                                      ,pr_tag_cont => rw_portab_envia.telefone
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Dados'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'dsdemail'
                                      ,pr_tag_cont => rw_portab_envia.dsdemail
                                      ,pr_des_erro => vr_dscritic);
            ELSE
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Dados'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'nrtelefo'
                                      ,pr_tag_cont => vr_nrtelefo
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Dados'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'dsdemail'
                                      ,pr_tag_cont => vr_dsdemail
                                      ,pr_des_erro => vr_dscritic);
            END IF;
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nrdocnpj_emp'
                                  ,pr_tag_cont => gene0002.fn_mask_cpf_cnpj(vr_nrdocnpj, 2)
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nmprimtl_emp'
                                  ,pr_tag_cont => vr_nmpessot
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nrispbif'
                                  ,pr_tag_cont => vr_nrispbif_cop
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nrdocnpj'
                                  ,pr_tag_cont => gene0002.fn_mask_cpf_cnpj(vr_nrdocnpj_cop, 2)
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'cdagectl'
                                  ,pr_tag_cont => vr_cdagectl_cop
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'dssituacao'
                                  ,pr_tag_cont => rw_portab_envia.situacao
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'cdsituacao'
                                  ,pr_tag_cont => rw_portab_envia.cdsituacao
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'dsmotivo'
                                  ,pr_tag_cont => rw_portab_envia.motivo
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'cdmotivo'
                                  ,pr_tag_cont => rw_portab_envia.cdmotivo
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'dtsolicita'
                                  ,pr_tag_cont => rw_portab_envia.dtsolicitacao
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'dtretorno'
                                  ,pr_tag_cont => rw_portab_envia.dtretorno
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nrnu_portabilidade'
                                  ,pr_tag_cont => rw_portab_envia.nrnu_portabilidade
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'cdbanco_folha'
                                  ,pr_tag_cont => rw_portab_envia.cdbanco_folha
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nrispb_banco_folha'
                                  ,pr_tag_cont => rw_portab_envia.nrispb_banco_folha
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nrcnpj_banco_folha'
                                  ,pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_portab_envia.nrcnpj_banco_folha
                                                                           ,2)
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'dsrowid'
                                  ,pr_tag_cont => rw_portab_envia.dsrowid
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nrnu_portabilidade_r'
                                  ,pr_tag_cont => rw_portab_envia.nrnu_portabilidade_r
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'dtsolicitacao_r'
                                  ,pr_tag_cont => rw_portab_envia.dtsolicitacao_r
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nrcnpj_empregador_r'
                                  ,pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_portab_envia.nrcnpj_empregador_r
                                                                           ,2)
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'dsnome_empregador_r'
                                  ,pr_tag_cont => rw_portab_envia.dsnome_empregador_r
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'banco'
                                  ,pr_tag_cont => rw_portab_envia.banco
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'cdagencia_destinataria_r'
                                  ,pr_tag_cont => rw_portab_envia.cdagencia_destinataria_r
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'nrdconta_destinataria_r'
                                  ,pr_tag_cont => gene0002.fn_mask_conta(rw_portab_envia.nrdconta_destinataria_r)
                                  ,pr_des_erro => vr_dscritic);
        
            -- Se houve retorno de erro
            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
            END IF;
        
        EXCEPTION
            WHEN vr_exc_erro THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        END;
    
    END pc_busca_dados;

    PROCEDURE pc_busca_bancos_folha(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_busca_bancos_folha
        Sistema : Ayllos Web
        Autor   : Andre Clemer (Supero)
        Data    : Outubro/2018                 Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para buscar os bancos folha.
        
        Alteracoes: -----
        ..............................................................................*/
        DECLARE
        
            -- Selecionar o CPF, Nome
            CURSOR cr_crapban IS
                SELECT lpad(t.cdbccxlt, 3, '0') || ' - ' || upper(t.nmextbcc) AS dsdbanco
                      ,t.nrispbif
                      ,t.nrcnpjif
                      ,t.cdbccxlt
                  FROM crapban t
                 WHERE t.flgdispb = 1
                   AND t.nrcnpjif > 0
                 ORDER BY t.cdbccxlt;
        
            rw_crapban cr_crapban%ROWTYPE;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_erro EXCEPTION;
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            vr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
        
            -- Variaveis locais
            vr_contador INTEGER := 0;
        
        BEGIN
            -- Incluir Nome do Módulo Logado
            gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
        
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
            END IF;
        
            -- Criar cabecalho do XML
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        
            FOR rw_crapban IN cr_crapban LOOP
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Dados'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'inf'
                                      ,pr_tag_cont => NULL
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'dsdbanco'
                                      ,pr_tag_cont => rw_crapban.dsdbanco
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'nrispbif'
                                      ,pr_tag_cont => rw_crapban.nrispbif
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'nrcnpjif'
                                      ,pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_crapban.nrcnpjif, 2)
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'cdbccxlt'
                                      ,pr_tag_cont => rw_crapban.cdbccxlt
                                      ,pr_des_erro => vr_dscritic);
            
                vr_contador := vr_contador + 1;
            
            END LOOP;
        
        EXCEPTION
            WHEN vr_exc_erro THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        END;
    
    END pc_busca_bancos_folha;

    PROCEDURE pc_solicita_portabilidade(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                       ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE --> Codigo do banco folha
                                       ,pr_nrispbif IN crapban.nrispbif%TYPE --> ISPB do banco folha
                                       ,pr_nrcnpjif IN crapban.nrcnpjif%TYPE --> CNPJ do banco folha
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_solicita_portabilidade
        Sistema : Ayllos Web
        Autor   : Andre Clemer (Supero)
        Data    : Outubro/2018                 Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para solicitar portabilidade.
        
        Alteracoes: -----
        ..............................................................................*/
        DECLARE
        
            -- Selecionar o banco folha
            CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE
                             ,pr_nrispbif IN crapban.nrispbif%TYPE
                             ,pr_nrcnpjif IN crapban.nrcnpjif%TYPE) IS
                SELECT 1
                  FROM crapban
                 WHERE crapban.cdbccxlt = pr_cdbccxlt
                   AND crapban.nrispbif = pr_nrispbif
                   AND crapban.nrcnpjif = pr_nrcnpjif;
            rw_crapban cr_crapban%ROWTYPE;
        
            -- Selecionar o CPF, Nome
            CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
                SELECT crapass.nrcpfcgc
                      ,crapass.nmprimtl
                  FROM crapass
                 WHERE crapass.cdcooper = pr_cdcooper
                   AND crapass.nrdconta = pr_nrdconta;
            rw_crapass cr_crapass%ROWTYPE;
        
            -- Selecionar DDD + telefone
            CURSOR cr_craptfc(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
                SELECT nrdddtfc
                      ,nrtelefo
                  FROM (SELECT craptfc.nrdddtfc
                              ,craptfc.nrtelefo
                          FROM craptfc
                         WHERE craptfc.cdcooper = pr_cdcooper
                           AND craptfc.nrdconta = pr_nrdconta
                           AND craptfc.tptelefo IN (1, 2, 3)
                         ORDER BY CASE tptelefo
                                      WHEN 2 THEN -- priorizar celular
                                       0
                                      ELSE -- demais telefones
                                       tptelefo
                                  END ASC)
                 WHERE rownum = 1; -- retorna apenas uma ocorrencia conforme prioridade na ordenacao
            rw_craptfc cr_craptfc%ROWTYPE;
        
            -- Selecionar o Email
            CURSOR cr_crapcem(pr_cdcooper IN crapenc.cdcooper%TYPE
                             ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
                SELECT dsdemail
                  FROM (SELECT crapcem.dsdemail
                          FROM crapcem
                         WHERE crapcem.cdcooper = pr_cdcooper
                           AND crapcem.nrdconta = pr_nrdconta
                         ORDER BY crapcem.dtmvtolt
                                 ,crapcem.hrtransa DESC)
                 WHERE rownum = 1; -- retorna apenas uma ocorrencia
            rw_crapcem cr_crapcem%ROWTYPE;
        
            -- Selecionar dados da empresa do cooperado
            CURSOR cr_crapttl(pr_cdcooper IN crapenc.cdcooper%TYPE
                             ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
                SELECT crapttl.nrcpfemp
                      ,crapttl.nmextemp
                  FROM crapttl
                 WHERE crapttl.cdcooper = pr_cdcooper
                   AND crapttl.nrdconta = pr_nrdconta
                   AND crapttl.idseqttl = 1;
            rw_crapttl cr_crapttl%ROWTYPE;
        
            -- Seleciona a Instituicao Destinatario
            CURSOR cr_crapcop(pr_cdcooper IN crapenc.cdcooper%TYPE) IS
                SELECT b.nrispbif
                      ,c.nrdocnpj
                      ,c.cdagectl
                  FROM crapban b
                      ,crapcop c
                 WHERE b.cdbccxlt = c.cdbcoctl
                   AND c.cdcooper = pr_cdcooper;
            rw_crapcop cr_crapcop%ROWTYPE;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_erro EXCEPTION;
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            pr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
            vr_nrdrowid ROWID;
        
            -- Variaveis locais
            vr_contador      INTEGER := 0;
            vr_nrsolicitacao tbcc_portabilidade_envia.nrsolicitacao%TYPE;
        
        BEGIN
            -- Incluir Nome do Módulo Logado
            gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
        
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => pr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
            END IF;
        
            /***
             ** INICIO DAS VALIDAÇÕES
            ***/
        
            -- Valida Nro da conta
            IF TRIM(pr_nrdconta) IS NULL THEN
                vr_dscritic := 'Numero de Conta nao encontrado.';
                RAISE vr_exc_erro;
            END IF;
        
            -- Valida dados do Banco Folha
            IF TRIM(pr_cdbccxlt) IS NULL THEN
                vr_dscritic := 'Codigo do Banco Folha nao encontrado.';
                RAISE vr_exc_erro;
            END IF;
        
            IF TRIM(pr_nrispbif) IS NULL THEN
                vr_dscritic := 'ISPB do Banco Folha nao encontrado.';
                RAISE vr_exc_erro;
            END IF;
        
            IF TRIM(pr_nrcnpjif) IS NULL THEN
                vr_dscritic := 'CNPJ do Banco Folha nao encontrado.';
                RAISE vr_exc_erro;
            END IF;
        
            -- Busca dados do Banco Folha
            OPEN cr_crapban(pr_cdbccxlt, pr_nrispbif, pr_nrcnpjif);
            FETCH cr_crapban
                INTO rw_crapban;
        
            IF cr_crapban%NOTFOUND THEN
                vr_dscritic := 'Banco Folha nao encontrado.';
                RAISE vr_exc_erro;
            END IF;
        
            -- Busca informacoes do cooperado
            OPEN cr_crapass(vr_cdcooper, pr_nrdconta);
            FETCH cr_crapass
                INTO rw_crapass;
        
            -- Valida dados do cooperado
            IF cr_crapass%NOTFOUND THEN
                vr_dscritic := 'Dados do cooperado nao encontrados.';
                RAISE vr_exc_erro;
            END IF;
        
            IF TRIM(rw_crapass.nmprimtl) IS NULL THEN
                vr_dscritic := 'Nome do cooperado nao encontrado.';
                RAISE vr_exc_erro;
            END IF;
        
            IF TRIM(rw_crapass.nrcpfcgc) IS NULL THEN
                vr_dscritic := 'CPF do cooperado nao encontrado.';
                RAISE vr_exc_erro;
            END IF;
        
            -- Busca telefone do cooperado
            OPEN cr_craptfc(vr_cdcooper, pr_nrdconta);
            FETCH cr_craptfc
                INTO rw_craptfc;
        
            IF length(rw_craptfc.nrdddtfc) <> 2 THEN
                vr_dscritic := 'DDD do cooperado invalido.';
                RAISE vr_exc_erro;
            END IF;
        
            IF length(rw_craptfc.nrtelefo) > 9 OR length(rw_craptfc.nrtelefo) > 6 THEN
                vr_dscritic := 'Numero do telefone do cooperado invalido.';
                RAISE vr_exc_erro;
            END IF;
        
            -- Busca email do cooperado
            OPEN cr_crapcem(vr_cdcooper, pr_nrdconta);
            FETCH cr_crapcem
                INTO rw_crapcem;
        
            -- Busca CNPJ e Nome da empresa do cooperado    
            OPEN cr_crapttl(vr_cdcooper, pr_nrdconta);
            FETCH cr_crapttl
                INTO rw_crapttl;
        
            IF cr_crapttl%NOTFOUND THEN
                vr_dscritic := 'Dados do empregador nao encontrados.';
                RAISE vr_exc_erro;
            END IF;
        
            IF TRIM(rw_crapttl.nmextemp) IS NULL THEN
                vr_dscritic := 'Nome do empregador nao encontrado.';
                RAISE vr_exc_erro;
            END IF;
        
            IF TRIM(rw_crapttl.nrcpfemp) IS NULL THEN
                vr_dscritic := 'CNPJ do empregador nao encontrado.';
                RAISE vr_exc_erro;
            END IF;
        
            -- Busca dados da instituicao financeira destinataria
            OPEN cr_crapcop(vr_cdcooper);
            FETCH cr_crapcop
                INTO rw_crapcop;
        
            IF cr_crapcop%NOTFOUND THEN
                vr_dscritic := 'Dados da Instituicao Financeira Destinataria nao encontrados.';
                RAISE vr_exc_erro;
            END IF;
        
            IF TRIM(rw_crapcop.nrispbif) IS NULL THEN
                vr_dscritic := 'ISPB da Instituicao Financeira Destinataria nao encontrada.';
                RAISE vr_exc_erro;
            END IF;
        
            IF TRIM(rw_crapcop.nrdocnpj) IS NULL THEN
                vr_dscritic := 'CNPJ da Instituicao Financeira Destinataria nao encontrado.';
                RAISE vr_exc_erro;
            END IF;
        
            IF TRIM(rw_crapcop.cdagectl) IS NULL THEN
                vr_dscritic := 'Agencia da Instituicao Financeira Destinataria nao encontrada.';
                RAISE vr_exc_erro;
            END IF;
        
            /***
             ** FIM DAS VALIDAÇÕES.
            ***/
        
            BEGIN
            
                SELECT nvl(MAX(nrsolicitacao), 0) + 1
                  INTO vr_nrsolicitacao
                  FROM tbcc_portabilidade_envia
                 WHERE cdcooper = vr_cdcooper
                   AND nrdconta = pr_nrdconta;
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao buscar Numero de solicitacao: ' || SQLERRM;
                    RAISE vr_exc_erro;
            END;
        
            BEGIN
                INSERT INTO tbcc_portabilidade_envia
                    (cdcooper
                    ,nrdconta
                    ,nrsolicitacao
                    ,dtsolicitacao
                    ,nrcpfcgc
                    ,nmprimtl
                    ,nrddd_telefone
                    ,nrtelefone
                    ,dsdemail
                    ,cdbanco_folha
                    ,cdagencia_folha
                    ,nrispb_banco_folha
                    ,nrcnpj_banco_folha
                    ,nrcnpj_empregador
                    ,dsnome_empregador
                    ,nrispb_destinataria
                    ,nrcnpj_destinataria
                    ,cdtipo_conta
                    ,cdagencia
                    ,idsituacao
                    ,cdoperador)
                VALUES
                    (vr_cdcooper
                    ,pr_nrdconta
                    ,vr_nrsolicitacao
                    ,SYSDATE
                    ,rw_crapass.nrcpfcgc
                    ,rw_crapass.nmprimtl
                    ,rw_craptfc.nrdddtfc
                    ,rw_craptfc.nrtelefo
                    ,rw_crapcem.dsdemail
                    ,pr_cdbccxlt
                    ,1
                    ,pr_nrispbif
                    ,pr_nrcnpjif
                    ,rw_crapttl.nrcpfemp
                    ,rw_crapttl.nmextemp
                    ,rw_crapcop.nrispbif
                    ,rw_crapcop.nrdocnpj
                    ,'CC' -- Conta Corrente
                    ,rw_crapcop.cdagectl
                    ,1 -- a solicitar
                    ,vr_cdoperad);
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao criar solicitacao de portabilidade: ' || SQLERRM;
                    RAISE vr_exc_erro;
            END;
        
            -- Efetua os inserts para apresentacao na tela VERLOG
            gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => ' '
                                ,pr_dsorigem => ''
                                ,pr_dstransa => 'Solicitacao de Portabilidade de Salario'
                                ,pr_dttransa => trunc(SYSDATE)
                                ,pr_flgtrans => 1
                                ,pr_hrtransa => to_char(SYSDATE, 'SSSSS')
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => ' '
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
        
            -- Gera o log para o CPF do cooperado
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'CPF'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc, 1));
            -- Gera o log para o nome do cooperado
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Nome'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => rw_crapass.nmprimtl);
            -- Gera o log para o DDD do cooperado
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'DDD'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => rw_craptfc.nrdddtfc);
            -- Gera o log para o Telefone do cooperado
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Telefone'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => rw_craptfc.nrtelefo);
            -- Gera o log para o E-mail do cooperado
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'E-mail'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => rw_crapcem.dsdemail);
            -- Gera o log para o Cod. Banco Folha
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Cod. Banco Folha'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => pr_cdbccxlt);
            -- Gera o log para o ISPB Banco Folha
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'ISPB Banco Folha'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => pr_nrispbif);
            -- Gera o log para o CNPJ Banco Folha
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'CNPJ Banco Folha'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(pr_nrcnpjif, 2));
            -- Gera o log para o CNPJ Empregador
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'CNPJ Empregador'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => gene0002.fn_mask_cpf_cnpj(rw_crapttl.nrcpfemp, 2));
            -- Gera o log para o Nome Empregador
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Nome Empregador'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => rw_crapttl.nmextemp);
            -- Gera o log para o ISPB Destinataria
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'ISPB Destinataria'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => rw_crapcop.nrispbif);
            -- Gera o log para o CNPJ Destinataria
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'CNPJ Destinataria'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => rw_crapcop.nrdocnpj);
            -- Gera o log para o Tipo Conta
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Tipo Conta CIP'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => 'Conta Corrente');
            -- Gera o log para o Agencia Destinataria
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Agencia Destinataria'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => rw_crapcop.cdagectl);
        
        EXCEPTION
            WHEN vr_exc_erro THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        END;
    
    END pc_solicita_portabilidade;

    PROCEDURE pc_busca_motivos_cancelamento(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                           ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_busca_motivos_cancelamento
        Sistema : Ayllos Web
        Autor   : Andre Clemer (Supero)
        Data    : Outubro/2018                 Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para buscar os motivos de cancelamento da portabilidade.
        
        Alteracoes: -----
        ..............................................................................*/
        DECLARE
        
            -- Buscar os motivos
            CURSOR cr_motivos IS
                SELECT cddominio
                      ,nmdominio
                      ,dscodigo
                  FROM tbcc_dominio_campo
                 WHERE nmdominio = 'MOTVCANCELTPORTDDCTSALR';
        
            rw_motivos cr_motivos%ROWTYPE;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_erro EXCEPTION;
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            vr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
        
            -- Variaveis locais
            vr_contador INTEGER := 0;
        
        BEGIN
            -- Incluir Nome do Módulo Logado
            gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
        
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
            END IF;
        
            -- Criar cabecalho do XML
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        
            FOR rw_motivos IN cr_motivos LOOP
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Dados'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'inf'
                                      ,pr_tag_cont => NULL
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'cddominio'
                                      ,pr_tag_cont => rw_motivos.cddominio
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'nmdominio'
                                      ,pr_tag_cont => rw_motivos.nmdominio
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'dscodigo'
                                      ,pr_tag_cont => rw_motivos.dscodigo
                                      ,pr_des_erro => vr_dscritic);
            
                vr_contador := vr_contador + 1;
            
            END LOOP;
        
        EXCEPTION
            WHEN vr_exc_erro THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        END;
    
    END pc_busca_motivos_cancelamento;

    PROCEDURE pc_cancela_portabilidade(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do cooperado
                                      ,pr_cdmotivo IN tbcc_portabilidade_envia.cdmotivo%TYPE --> Motivo do cancelamento
                                      ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_cancela_portabilidade
        Sistema : Ayllos Web
        Autor   : Andre Clemer (Supero)
        Data    : Outubro/2018                 Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para cancelar portabilidade.
        
        Alteracoes: -----
        ..............................................................................*/
        DECLARE
        
            -- Buscar o motivo
            CURSOR cr_motivo(pr_cdmotivo IN tbcc_dominio_campo.cddominio%TYPE) IS
                SELECT cddominio
                      ,nmdominio
                      ,dscodigo
                  FROM tbcc_dominio_campo
                 WHERE nmdominio = 'MOTVCANCELTPORTDDCTSALR'
                   AND cddominio = pr_cdmotivo;
        
            rw_motivo cr_motivo%ROWTYPE;
        
            -- Seleciona Portab Envia
            CURSOR cr_portab_envia(pr_cdcooper IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
                SELECT ROWID
                      ,situacao
                      ,cdsituacao
                      ,motivo
                      ,cdmotivo
                      ,to_char(dtsolicitacao, 'DD/MM/RRRR HH24:MI:SS') dtsolicitacao
                      ,to_char(dtretorno, 'DD/MM/RRRR HH24:MI:SS') dtretorno
                      ,to_char(nrnu_portabilidade) nrnu_portabilidade
                      ,cdbanco_folha
                      ,nrispb_banco_folha
                      ,nrcnpj_banco_folha
                  FROM (SELECT dom.dscodigo           AS situacao
                              ,dom.cddominio          AS cdsituacao
                              ,dcp.dscodigo           AS motivo
                              ,dcp.cddominio          AS cdmotivo
                              ,tpe.dtsolicitacao      AS dtsolicitacao
                              ,tpe.dtretorno
                              ,tpe.nrnu_portabilidade
                              ,tpe.cdbanco_folha
                              ,tpe.nrispb_banco_folha
                              ,tpe.nrcnpj_banco_folha
                          FROM tbcc_portabilidade_envia tpe
                              ,tbcc_dominio_campo       dom
                              ,tbcc_dominio_campo       dcp
                         WHERE tpe.idsituacao = dom.cddominio
                           AND dom.nmdominio = 'SIT_PORTAB_SALARIO_ENVIA'
                           AND dcp.nmdominio(+) = tpe.dsdominio_motivo
                           AND dcp.cddominio(+) = tpe.cdmotivo
                           AND nrdconta = pr_nrdconta
                           AND cdcooper = pr_cdcooper
                         ORDER BY tpe.dtsolicitacao DESC)
                 WHERE rownum = 1;
            rw_portab_envia cr_portab_envia%ROWTYPE;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_erro EXCEPTION;
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            pr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
            vr_nrdrowid ROWID;
        
            -- Variaveis locais
            vr_contador INTEGER := 0;
            vr_situacao tbcc_dominio_campo.cddominio%TYPE;
            vr_motivo   tbcc_dominio_campo.dscodigo%TYPE;
        
        BEGIN
            -- Incluir Nome do Módulo Logado
            gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_PORTAB', pr_action => NULL);
        
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => pr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
            END IF;
        
            -- Busca dados da instituicao financeira destinataria
            OPEN cr_portab_envia(vr_cdcooper, pr_nrdconta);
            FETCH cr_portab_envia
                INTO rw_portab_envia;
        
            IF rw_portab_envia.cdsituacao = 1 THEN
                -- A solicitar
                vr_situacao := 6; -- Cancelada
            ELSIF rw_portab_envia.cdsituacao = 2 OR rw_portab_envia.cdsituacao = 3 THEN
                -- Solicitada OU Aprovada
                vr_situacao := 5; -- A cancelar
            END IF;
        
            OPEN cr_motivo(pr_cdmotivo);
            FETCH cr_motivo
                INTO rw_motivo;
        
            IF cr_motivo%NOTFOUND THEN
                vr_dscritic := 'Erro ao buscar motivo de cancelamento: ' || SQLERRM;
                RAISE vr_exc_erro;
            END IF;
        
            vr_motivo := rw_motivo.dscodigo;
        
            BEGIN
                UPDATE tbcc_portabilidade_envia
                   SET idsituacao       = vr_situacao
                      ,cdmotivo         = pr_cdmotivo
                      ,dsdominio_motivo = 'MOTVCANCELTPORTDDCTSALR'
                 WHERE ROWID = rw_portab_envia.rowid;
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao cancelar portabilidade: ' || SQLERRM;
                    RAISE vr_exc_erro;
            END;
        
            -- Efetua os inserts para apresentacao na tela VERLOG
            gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => ' '
                                ,pr_dsorigem => ''
                                ,pr_dstransa => 'Cancelamento de Portabilidade de Salario'
                                ,pr_dttransa => trunc(SYSDATE)
                                ,pr_flgtrans => 1
                                ,pr_hrtransa => to_char(SYSDATE, 'SSSSS')
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => ' '
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
        
            -- Gera o log para o NU Portabilidade
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'NU Portabilidade'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => rw_portab_envia.nrnu_portabilidade);
            -- Gera o log para o Motivo Portabilidade
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Motivo'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => vr_motivo);
        
        EXCEPTION
            WHEN vr_exc_erro THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela PORTAB: ' || SQLERRM;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        END;
    
    END pc_cancela_portabilidade;

    PROCEDURE pc_imprimir_termo_portab(pr_dsrowid  IN VARCHAR2 --> Rowid da tabela
                                      ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS
        /* .............................................................................
        
        Programa: pc_imprimir_termo_portab
        Sistema : Ayllos Web
        Autor   : Augusto (Supero)
        Data    : Outubro/2018                 Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para retornar os dados para o termo de portabilidade
        
        Alteracoes:
        ..............................................................................*/
    
        -- Cria o registro de data
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
        vr_tab_erro gene0001.typ_tab_erro;
        vr_des_reto VARCHAR2(10);
    
        -- Variaveis de log
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis
        vr_xml_temp    VARCHAR2(32726) := '';
        vr_clob        CLOB;
        vr_qtde_dias   VARCHAR2(200);
        vr_dsqtde_dias VARCHAR2(200);
    
        vr_nom_direto VARCHAR2(200); --> Diretório para gravação do arquivo
        vr_dsjasper   VARCHAR2(100); --> nome do jasper a ser usado
        vr_nmarqim    VARCHAR2(50); --> nome do arquivo PDF
    
        CURSOR cr_solicitacao(pr_dsrowid VARCHAR2) IS
            SELECT tpe.dtsolicitacao
                  ,gene0002.fn_mask_conta(tpe.nrdconta) nrdconta
                  ,gene0002.fn_mask_cpf_cnpj(tpe.nrcpfcgc, 1) nrcpfcgc
                  ,'(' || lpad(tpe.nrddd_telefone, 2, '0') || ')' || tpe.nrtelefone telefone
                  ,tpe.nmprimtl
                  ,gene0002.fn_mask_cpf_cnpj(tpe.nrcnpj_empregador, 2) nrcnpj_empregador
                  ,tpe.dsnome_empregador
                  ,lpad(ban.cdbccxlt, 3, '0') || ' - ' || ban.nmresbcc banco
                  ,tpe.nrispb_banco_folha
                  ,gene0002.fn_mask_cpf_cnpj(tpe.nrcnpj_banco_folha, 2) nrcnpj_banco_folha
                  ,dom.dscodigo tipo_conta
                  ,tpe.dsdemail
                  ,ope.nmoperad
                  ,ope.cdagenci pa
                  ,tpe.cdagencia
                  ,prm.dsvlrprm img_cooperativa
              FROM tbcc_portabilidade_envia tpe
                  ,crapban                  ban
                  ,tbcc_dominio_campo       dom
                  ,crapope                  ope
                  ,crapprm                  prm
             WHERE tpe.nrispb_banco_folha = ban.nrispbif
               AND tpe.cdtipo_conta = dom.cddominio
               AND dom.nmdominio = 'TIPO_CONTA_PCPS'
               AND tpe.cdoperador = ope.cdoperad
               AND prm.cdacesso = 'IMG_LOGO_COOP'
               AND prm.cdcooper = tpe.cdcooper
               AND tpe.rowid = pr_dsrowid;
        rw_solicitacao cr_solicitacao%ROWTYPE;
    
        CURSOR cr_dias_comp IS
            SELECT o.dsconteu
              FROM crappco o
             WHERE o.cdpartar = 63
               AND o.cdcooper = 3;
        rw_dias_comp cr_dias_comp%ROWTYPE;
    
    BEGIN
        -- Extrai os dados vindos do XML
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        -- Abre o cursor de data
        OPEN btch0001.cr_crapdat(vr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
    
        -- Abre o cursor com os dados do termo
        OPEN cr_solicitacao(pr_dsrowid => pr_dsrowid);
        FETCH cr_solicitacao
            INTO rw_solicitacao;
    
        IF cr_solicitacao%NOTFOUND THEN
            CLOSE cr_solicitacao;
            vr_dscritic := 'Solicitacao nao encontrada.';
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_solicitacao;
    
        -- Abre o cursor com a parametrização de dias para aceite compulsório
        OPEN cr_dias_comp;
        FETCH cr_dias_comp
            INTO rw_dias_comp;
    
        IF cr_dias_comp%NOTFOUND OR rw_dias_comp.dsconteu IS NULL THEN
            CLOSE cr_dias_comp;
            vr_dscritic := 'Parametro de dias para aceite compulsorio nao cadastrado.';
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_dias_comp;
    
        BEGIN
            vr_qtde_dias   := to_number(rw_dias_comp.dsconteu);
            vr_dsqtde_dias := gene0002.fn_valor_extenso(pr_idtipval => 'I', pr_valor => vr_qtde_dias);
        
        EXCEPTION
            WHEN OTHERS THEN
                vr_dscritic := 'Parametro de dias para aceite compulsorio invalido.';
                RAISE vr_exc_saida;
        END;
    
        --busca diretorio padrao da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                              ,pr_cdcooper => vr_cdcooper
                                              ,pr_nmsubdir => 'rl');
    
        -- Monta documento XML de Dados
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><adesao>');
    
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<qtde_dias>' || vr_qtde_dias || '</qtde_dias>' ||
                                                     '<dsqtde_dias>' || vr_dsqtde_dias || '</dsqtde_dias>' ||
                                                     '<dtsolicitacao>' ||
                                                     to_char(rw_solicitacao.dtsolicitacao, 'DD/MM/RRRR') ||
                                                     '</dtsolicitacao>' || '<nrdconta>' ||
                                                     rw_solicitacao.nrdconta || '</nrdconta>' || '<nrcpfcgc>' ||
                                                     rw_solicitacao.nrcpfcgc || '</nrcpfcgc>' || '<telefone>' ||
                                                     rw_solicitacao.telefone || '</telefone>' || '<nmprimtl>' ||
                                                     rw_solicitacao.nmprimtl || '</nmprimtl>' ||
                                                     '<nrcnpj_empregador>' || rw_solicitacao.nrcnpj_empregador ||
                                                     '</nrcnpj_empregador>' || '<dsnome_empregador>' ||
                                                     rw_solicitacao.dsnome_empregador ||
                                                     '</dsnome_empregador>' || '<banco>' ||
                                                     rw_solicitacao.banco || '</banco>' ||
                                                     '<nrispb_banco_folha>' ||
                                                     rw_solicitacao.nrispb_banco_folha ||
                                                     '</nrispb_banco_folha>' || '<nrcnpj_banco_folha>' ||
                                                     rw_solicitacao.nrcnpj_banco_folha ||
                                                     '</nrcnpj_banco_folha>' || '<tipo_conta>' ||
                                                     rw_solicitacao.tipo_conta || '</tipo_conta>' ||
                                                     '<dsdemail>' || rw_solicitacao.dsdemail || '</dsdemail>' ||
                                                     '<nmoperad>' || rw_solicitacao.nmoperad || '</nmoperad>' ||
                                                     '<pa>' || rw_solicitacao.pa || '</pa>' || '<cdagencia>' ||
                                                     rw_solicitacao.cdagencia || '</cdagencia>' ||
                                                     '<img_cooperativa>' || rw_solicitacao.img_cooperativa ||
                                                     '</img_cooperativa>');
    
        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</adesao>'
                               ,pr_fecha_xml      => TRUE);
    
        vr_dsjasper := 'termo_solicitacao_portabilidade.jasper';
        vr_nmarqim  := '/TermoAdesaoPortabilidade_' || to_char(SYSDATE, 'DDMMYYYYHH24MISS') || '.pdf';
    
        -- Solicita geracao do PDF
        gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper
                                   ,pr_cdprogra  => 'ATENDA'
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                   ,pr_dsxml     => vr_clob
                                   ,pr_dsxmlnode => '/adesao'
                                   ,pr_dsjasper  => vr_dsjasper
                                   ,pr_dsparams  => NULL
                                   ,pr_dsarqsaid => vr_nom_direto || vr_nmarqim
                                   ,pr_cdrelato  => 684
                                   ,pr_flg_gerar => 'S'
                                   ,pr_qtcoluna  => 80
                                   ,pr_sqcabrel  => 1
                                   ,pr_flg_impri => 'N'
                                   ,pr_nmformul  => ' '
                                   ,pr_nrcopias  => 1
                                   ,pr_parser    => 'R'
                                   ,pr_nrvergrl  => 1
                                   ,pr_des_erro  => vr_dscritic);
    
        -- copia contrato pdf do diretorio da cooperativa para servidor web
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_nom_direto || vr_nmarqim
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
    
        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);
    
        -- Criar XML de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarqim ||
                                       '</nmarqpdf>');
    
        COMMIT;
    EXCEPTION
        WHEN vr_exc_saida THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            ROLLBACK;
            -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        
        WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral em pc_imprimir_termo_portab: ' || SQLERRM;
            ROLLBACK;
            -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_imprimir_termo_portab;

END tela_atenda_portab;
/
