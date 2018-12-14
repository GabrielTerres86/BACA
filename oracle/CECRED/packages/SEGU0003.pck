CREATE OR REPLACE PACKAGE CECRED.SEGU0003 IS
  -- Função que retorna o saldo devedor para utilização no seguro de vida prestamista
  PROCEDURE pc_saldo_devedor(pr_cdcooper     IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                            ,pr_nrdconta     IN crapass.nrdconta%TYPE  --> Número da conta
                            ,pr_nrctremp     IN crawepr.nrctremp%TYPE  --> Número do contrato
                            ,pr_cdagenci     IN crapage.cdagenci%TYPE  --> Código da agencia
                            ,pr_nrdcaixa     IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                            ,pr_cdoperad     IN crapope.cdoperad%TYPE  --> Código do Operador
                            ,pr_nmdatela     IN craptel.nmdatela%TYPE  --> Nome da Tela
                            ,pr_idorigem     IN INTEGER                --> Identificador de Origem
                            ,pr_saldodevedor OUT NUMBER                --> Valor do saldo devedor total
                            ,pr_saldodevempr OUT NUMBER                --> Valor do saldo devedor somente dos empréstimos efetivador                            
                            ,pr_cdcritic     OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic     OUT VARCHAR2                            
                             );
                         
  -- Rotina para geração do relatório da proposta de seguro de vida prestamista
  PROCEDURE pc_imp_proposta_seg_pres(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                    ,pr_nrctrseg IN crawseg.nrctrseg%TYPE  --> Proposta
                                    ,pr_nrctremp IN crawepr.nrctremp%TYPE  --> Contrato                                    
                                    ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                    ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                    ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                    ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                    ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Código do operador                                    
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento                                                                              
                                    ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)                                       
                                    --------> OUT <--------
                                    ,pr_nmarqpdf  OUT VARCHAR2             --> Retornar Nome do arquivo
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica
                                      
--> Rotina para geração do relatório da proposta de seguro de vida prestamista - Ayllos Web
  PROCEDURE pc_imp_proposta_seg_pres_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
                                        ,pr_nrctrseg   IN crawseg.nrctrseg%TYPE  --> Proposta
                                        ,pr_nrctremp IN crawepr.nrctremp%TYPE  --> Contrato                                                                            
                                        ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                        ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo
  --Validações Seguro Prestamista
  PROCEDURE pc_validar_prestamista(pr_cdcooper in crapcop.cdcooper%type,
                                   pr_nrdconta in crapass.nrdconta%type,
                                   pr_nrctremp in crapepr.nrctremp%type,
                                   pr_cdagenci IN crapage.cdagenci%type,  --> Código da agencia
                                   pr_nrdcaixa IN crapbcx.nrdcaixa%type,  --> Numero do caixa do operador
                                   pr_cdoperad IN crapope.cdoperad%type,  --> Código do Operador
                                   pr_nmdatela IN craptel.nmdatela%type,  --> Nome da Tela
                                   pr_idorigem IN INTEGER,                --> Identificador de Origem    
                                   pr_valida_proposta in varchar2,   --> Usado não para validar o cancelamento em pc_crps781                                
                                   pr_sld_devedor out crawseg.vlseguro%type,   --> Valor proposta      
                                   pr_flgprestamista out char,
                                   pr_flgdps         out char,
                                   pr_dsmotcan out varchar2,
                                   pr_cdcritic out crapcri.cdcritic%type,    --> Codigo da critica
                                   pr_dscritic out crapcri.dscritic%type); --> Descricao da critica   
  
  PROCEDURE pc_cria_proposta_sp(pr_cdcooper in crapcop.cdcooper%type,
                                pr_nrdconta in crapass.nrdconta%type,
                                pr_nrctremp in crapepr.nrctremp%type,
                                pr_cdagenci IN crapage.cdagenci%type,  --> Código da agencia
                                pr_nrdcaixa IN crapbcx.nrdcaixa%type,  --> Numero do caixa do operador
                                pr_cdoperad IN crapope.cdoperad%type,  --> Código do Operador
                                pr_nmdatela IN craptel.nmdatela%type,  --> Nome da Tela
                                pr_idorigem IN INTEGER,                --> Identificador de Origem                                     
                                pr_cdcritic out crapcri.cdcritic%type,    --> Codigo da critica
                                pr_dscritic out crapcri.dscritic%type); --> Descricao da critica   
                                
  PROCEDURE pc_efetiva_proposta_sp(pr_cdcooper in crapcop.cdcooper%type,
                                   pr_nrdconta in crapass.nrdconta%type,
                                   pr_nrctrato in crawseg.nrctrato%type,
                                   pr_cdagenci IN crapage.cdagenci%type,  --> Código da agencia
                                   pr_nrdcaixa IN crapbcx.nrdcaixa%type,  --> Numero do caixa do operador
                                   pr_cdoperad IN crapope.cdoperad%type,  --> Código do Operador
                                   pr_nmdatela IN craptel.nmdatela%type,  --> Nome da Tela
                                   pr_idorigem IN INTEGER,                --> Identificador de Origem                                     
                                   pr_cdcritic out crapcri.cdcritic%type,    --> Codigo da critica
                                   pr_dscritic out crapcri.dscritic%type); --> Descricao da critica     
                                   
  PROCEDURE pc_valida_contrato( pr_nrctrato IN crawseg.nrctrato%TYPE --Número do contrato
                               ,pr_nrdconta IN crawseg.nrdconta% TYPE -- Número da conta    
                               ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK     
                               
  PROCEDURE pc_busca_contratos(pr_nrdconta IN CRAPASS.NRDCONTA%TYPE --> Número da conta
                              ,pr_nrregist IN INTEGER               --> Quantidade de registros
                              ,pr_nriniseq IN INTEGER               --> Qunatidade inicial
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK   
                                       
END SEGU0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.SEGU0003 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : SEGU0003
  --  Sistema  : Crédito - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Márcio Carvalho - Mouts
  --  Data     : Agosto - 2018                 Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas de proposta de seguro prestamista
  --
  -- Alteracoes: 
  --
  --             13/12/2018 - Retirado Commit e Rollback Procedures prestamista chamados via progress - Paulo Martins
  ---------------------------------------------------------------------------
  
  -- Função que retorna o saldo devedor para utilização no seguro de vida prestamista
  PROCEDURE pc_saldo_devedor(pr_cdcooper     IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                            ,pr_nrdconta     IN crapass.nrdconta%TYPE  --> Número da conta
                            ,pr_nrctremp     IN crawepr.nrctremp%TYPE  --> Número do contrato
                            ,pr_cdagenci     IN crapage.cdagenci%TYPE  --> Código da agencia
                            ,pr_nrdcaixa     IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                            ,pr_cdoperad     IN crapope.cdoperad%TYPE  --> Código do Operador
                            ,pr_nmdatela     IN craptel.nmdatela%TYPE  --> Nome da Tela
                            ,pr_idorigem     IN INTEGER                --> Identificador de Origem
                            ,pr_saldodevedor OUT NUMBER                --> Valor do saldo devedor total
                            ,pr_saldodevempr OUT NUMBER                --> Valor do saldo devedor somente dos empréstimos efetivador
                            ,pr_cdcritic     OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic     OUT VARCHAR2                            ) IS
   /* .............................................................................

       Programa: fn_saldo_devedor
       Sistema : Seguros - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Márcio (Mouts)
       Data    : Agosto/2018.                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Função que retorna o saldo devedor para utilização no seguro de vida prestamista.

       Alteracoes:

    ............................................................................. */
-- ler todos os contratos não liquidados onde a linha de crédito possui o flag de seguro prestamista
    CURSOR cr_crapepr IS
      SELECT
            ce.nrctremp
        FROM
            crapepr ce,
            craplcr cl
       WHERE
            ce.cdcooper = pr_cdcooper
        AND ce.nrdconta = pr_nrdconta
        AND ce.inliquid <> 1 -- não liquidao
        AND cl.cdcooper = ce.cdcooper
        AND cl.cdlcremp = ce.cdlcremp
        AND cl.flgsegpr = 1;

    -- Ler o valor da proposta de contrato atual para somar ao valor do saldo devedor   
    CURSOR cr_crawepr IS
      SELECT
             c.vlemprst
        FROM
             crawepr c
       WHERE
             c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND c.nrctremp = pr_nrctremp
         and not exists (select 1 -- Garantir que somente proposta não efetivada esteja no saldo -- Paulo 12/09
                           from crapepr e -- Emprestimos efetivados
                          where e.cdcooper = c.cdcooper
                            and e.nrdconta = c.nrdconta
                            and e.nrctremp = c.nrctremp);

    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;

    rw_crapdat             BTCH0001.cr_crapdat%ROWTYPE;
    vr_des_reto            VARCHAR2(3) := '';
    vr_tab_erro            GENE0001.typ_tab_erro;
    vr_inusatab            BOOLEAN :=FALSE;    
    vr_dstextab            VARCHAR2(400);
    vr_total_saldo_devedor NUMBER:=0;
    vr_vltotpre            NUMBER;--:=0;
    vr_qtprecal            NUMBER:=0;   
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    

  BEGIN
    -- Calendario da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    --Verificar se usa tabela juros
    vr_dstextab := TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TAXATABELA'
                                              ,pr_tpregist => 0);
    -- Se a primeira posição do campo dstextab for diferente de zero
    IF vr_dstextab IS NOT NULL AND substr(vr_dstextab,1,1) = 0 THEN
      vr_inusatab:= FALSE;
    ELSE 
      vr_inusatab:= TRUE;      
    END IF;
    
    FOR rw_crapepr IN cr_crapepr LOOP
      -- Buscar o saldo devedor atualizado do contrato
      EMPR0001.pc_saldo_devedor_epr (pr_cdcooper => pr_cdcooper             --> Cooperativa conectada
                                    ,pr_cdagenci => pr_cdagenci             --> Codigo da agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa             --> Numero do caixa
                                    ,pr_cdoperad => pr_cdoperad             --> Codigo do operador
                                    ,pr_nmdatela => pr_nmdatela             --> Nome datela conectada
                                    ,pr_idorigem => pr_idorigem             --> Indicador da origem da chamada
                                    ,pr_nrdconta => pr_nrdconta             --> Conta do associado
                                    ,pr_idseqttl => 1                       --> Sequencia de titularidade da conta
                                    ,pr_rw_crapdat => rw_crapdat            --> Vetor com dados de parametro (CRAPDAT)
                                    ,pr_nrctremp => rw_crapepr.nrctremp     --> Numero contrato emprestimo
                                    ,pr_cdprogra => 'SEGU0003'            --> Programa conectado
                                    ,pr_inusatab => vr_inusatab             --> Indicador de utilizacão da tabela
                                    ,pr_flgerlog => 'N'                     --> Gerar log S/N
                                    ,pr_vlsdeved => vr_total_saldo_devedor  --> Saldo devedor calculado
                                    ,pr_vltotpre => vr_vltotpre             --> Valor total das prestacães
                                    ,pr_qtprecal => vr_qtprecal             --> Parcelas calculadas
                                    ,pr_des_reto => vr_des_reto             --> Retorno OK / NOK
                                    ,pr_tab_erro => vr_tab_erro);           --> Tabela com possives erros
      -- Se houve retorno de erro
      IF vr_des_reto = 'NOK' THEN
        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        -- Limpar tabela de erros
        vr_tab_erro.DELETE;
        RAISE vr_exc_erro;
      END IF;
    END LOOP;
    
    pr_saldodevempr := vr_total_saldo_devedor; --Somente o Saldo devedor - Sem proposta
    
    -- Buscar o valor da proposta de emprestimo e somar ao saldo devedor
    FOR rw_crawepr IN cr_crawepr LOOP
      vr_total_saldo_devedor:=vr_total_saldo_devedor + rw_crawepr.vlemprst;
    END LOOP;
    
    pr_saldodevedor:= vr_total_saldo_devedor;
    
    
EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
     
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao calcular saldo devedor: ' || SQLERRM, chr(13)),chr(10));   

  END pc_saldo_devedor;

  -------------------------------------------------------------------------------
  -- Rotina para geração do relatório da proposta de seguro de vida prestamista
  PROCEDURE pc_imp_proposta_seg_pres(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                    ,pr_nrctrseg IN crawseg.nrctrseg%TYPE  --> Proposta
                                    ,pr_nrctremp IN crawepr.nrctremp%TYPE  --> Contrato                                    
                                    ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                    ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                    ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                    ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                    ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE  -- Código do operador
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento                                       
                                    ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)                                       
                                    --------> OUT <--------
                                    ,pr_nmarqpdf  OUT VARCHAR2             --> Retorna Nome do arquivo                           
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .............................................................................

     Programa: pc_impres_proposta_seg_pres
     Sistema : Seguros - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Márcio(Mouts)
     Data    : Agosto/2018.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do relatório da proposta de seguro de vida prestamista
     Alteracoes: 
     
    ..............................................................................*/
    ----------->>> Cursores <<<--------   
    --> Buscar informações da proposta    
    CURSOR cr_crawseg IS
      select 
             cc.nmextcop, -- Nome da cooperativa
             trim(gene0002.fn_mask_conta(ca.nrdconta)) nrdconta, -- Número da conta
             cs.nrctrseg, -- Número da Proposta de Seguro de Vida Prestamista             
             cg.cdagenci, -- Número do PA
             cs.nmdsegur, -- Nome do segurado
             cs.nrcpfcgc, -- Cpf do segurado
             g.rsestcvl , -- Estado Civil
             cs.dtnascsg, -- Data de nascimento
             decode(cs.cdsexosg,1,'MASCULINO','FEMININO') cdsexosg, -- Sexo
             cs.dsendres||' '||cs.nrendres Endereco,
             cs.nmbairro, -- Nome do Bairro
             cs.nmcidade, -- Nome da Cidade
             cs.cdufresd, -- UF
             cs.nrcepend, -- CEP
             cs.nrctrato, -- Número do Contrato             
             lpad(cs.tpplaseg,3,'0') tpplaseg, -- Plano
             0 vl_saldo_devedor, --cs.vl_saldo_devedor
             1 id_imprime_DPS, -- Indicador se imprime DPS ou não
             cs.dtinivig,
             cs.dtmvtolt,
             cs.nmdsegur Cooperado, -- Cooperado
             trim(gene0002.fn_mask_conta(ca.nrdconta)) nrdconta2, -- Número da conta
             co.nmoperad -- Nome do operador
      from 
             crawseg cs,
             crapcop cc,
             crapass ca,
             crapage cg,
             crapttl ct,
             gnetcvl g,
             crapope co
      where 
             cs.cdcooper = pr_cdcooper 
         and cs.nrdconta = pr_nrdconta 
         and (cs.nrctrseg = pr_nrctrseg or cs.nrctrato = pr_nrctremp)
         and cs.cdcooper = cc.cdcooper
         and cs.cdcooper = ca.cdcooper
         and cs.nrdconta = ca.nrdconta
         and ca.cdcooper = cg.cdcooper
         and ca.cdagenci = cg.cdagenci
         and ct.cdcooper = cs.cdcooper
         and ct.nrdconta = cs.nrdconta
         and ct.nrcpfcgc = cs.nrcpfcgc
         and g.cdestcvl  = ct.cdestcvl
         and co.cdcooper = cs.cdcooper
         and co.cdoperad = pr_cdoperad;

    rw_crawseg cr_crawseg%ROWTYPE;   
      
    --> Buscar informações da proposta efetivada
    CURSOR cr_crapseg(prr_nrctrseg IN crawseg.nrctrseg%TYPE) IS
      select 
             cs.vlslddev, 
             decode(cs.idimpdps,1,'S','N') idimpdps
      from 
             crapseg cs
      where 
             cs.cdcooper = pr_cdcooper 
         and cs.nrdconta = pr_nrdconta 
         and cs.nrctrseg = prr_nrctrseg;
  
    rw_crapseg cr_crapseg%ROWTYPE;   

    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        GENE0001.typ_tab_erro;
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE;
    vr_nrdrowid        ROWID;

    vr_idseqttl        crapttl.idseqttl%TYPE;
    
    vr_dsdireto        VARCHAR2(4000);
    vr_nmendter        VARCHAR2(4000);     
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100);    
    
    vr_dsmailcop       VARCHAR2(4000);
    vr_dsassmail       VARCHAR2(200);
    vr_dscormail       VARCHAR2(50);
    
    vr_saldodevedor    NUMBER:=0;
    vr_saldodevempr    NUMBER:=0;
    vr_id_imprime_dsp  VARCHAR2(1);    
    vr_flgprestamista  VARCHAR2(1);
    vr_localedata      VARCHAR2(200);    
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    
    l_offset     NUMBER:=0;
    
    vr_dsjasper  VARCHAR2(100);
    vr_dsmotcan  VARCHAR2(60);    
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN   
    --> Definir transação
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    END IF; 
    
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper);
                                         
    vr_nmendter := vr_dsdireto ||'/rl/psdp001';
    
    vr_dscomand := 'rm '||vr_nmendter||'* 2>/dev/null';
    
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 
    
    --> Montar nome do arquivo
    pr_nmarqpdf := 'psvp001'|| gene0002.fn_busca_time || '.pdf';
    
    
    --Aqui deve chamar a rotina para verificar se imprime o relatório e se é DPS ou não
    pc_validar_prestamista(pr_cdcooper       => pr_cdcooper,
                           pr_nrdconta       => pr_nrdconta,
                           pr_nrctremp       => rw_crawseg.nrctrato,
                           pr_cdagenci       => pr_cdagecxa,
                           pr_nrdcaixa       => pr_nrdcaixa,
                           pr_cdoperad       => pr_cdoperad,
                           pr_nmdatela       => pr_nmdatela,
                           pr_idorigem       => pr_idorigem,   
                           pr_valida_proposta => 'N', -- Na impressão somente considera valor saldo devedor
                           pr_sld_devedor    => vr_saldodevedor,  
                           pr_flgprestamista => vr_flgprestamista,
                           pr_flgdps         => vr_id_imprime_dsp,
                           pr_dsmotcan       => vr_dsmotcan,
                           pr_cdcritic       => pr_cdcritic,
                           pr_dscritic       => pr_dscritic);
                              
    IF pr_dscritic IS NOT NULL THEN
           RAISE vr_exc_erro; -- encerra programa           
    END IF;
    --
    --> Buscar dados para impressao da Proposta de Seguro de Vida Prestamista
    OPEN cr_crawseg;
    FETCH cr_crawseg INTO rw_crawseg;
    IF cr_crawseg%NOTFOUND THEN
      CLOSE cr_crawseg;
      vr_dscritic := 'Proposta nao encontrada.';
      RAISE vr_exc_erro;
    ELSE
     CLOSE cr_crawseg;
    END IF;
    
    OPEN cr_crapseg(rw_crawseg.nrctrseg);
    FETCH cr_crapseg INTO rw_crapseg;
    IF cr_crapseg%NOTFOUND THEN
      CLOSE cr_crapseg;      
      -- Se a proposta nao estiver efetivada, rodar a rotina para calculo do saldo devedor
      pc_saldo_devedor(pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_nrctremp => rw_crawseg.nrctrato,
                       pr_cdagenci => pr_cdagecxa,
                       pr_nrdcaixa => pr_nrdcaixa,
                       pr_cdoperad => pr_cdoperad,
                       pr_nmdatela => pr_nmdatela,
                       pr_idorigem => pr_idorigem,
                       pr_saldodevedor => vr_saldodevedor,
                       pr_saldodevempr => vr_saldodevempr,
                       pr_cdcritic => pr_cdcritic,
                       pr_dscritic => pr_dscritic);
       IF pr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro; -- encerra programa           
       END IF;
           
    ELSE
      -- Se proposta de seguro estiver efetivada, buscar da tabela o valor do saldo e o indicador de DPS   
      --> Buscar dados para impressao da Proposta de Seguro de Vida Prestamista
      CLOSE cr_crapseg;
      vr_saldodevedor   := rw_crapseg.vlslddev;
      vr_id_imprime_dsp := rw_crapseg.idimpdps;
    END IF;

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    -- Monta o Local e Data
    vr_localedata := upper(SUBSTR(rw_crawseg.nmcidade,1,15) ||', ' || gene0005.fn_data_extenso(rw_crawseg.dtmvtolt));
    
    vr_txtcompl := NULL;
      
    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><dadosRelatorio>
                    <dps>'|| vr_id_imprime_dsp ||'</dps>');  -- Nome da cooperativa
    pc_escreve_xml(
      '<nmextcop>'        ||rw_crawseg.nmextcop                       ||'</nmextcop>'        ||-- Nome da cooperativa
      '<conta>'           ||rw_crawseg.nrdconta                       ||'</conta>'           ||-- Número da conta - Formatado
      '<proposta>'        ||rw_crawseg.nrctrseg                       ||'</proposta>'        ||-- Número da Proposta de Seguro de Vida Prestamista    
      '<contaProponete>'  ||rw_crawseg.nrdconta                       ||'</contaProponete>'  ||-- Número da conta - Formatado
      '<postoAtendimento>'||rw_crawseg.cdagenci                       ||'</postoAtendimento>'||-- Número do PA
      '<segurado>'        ||rw_crawseg.nmdsegur                       ||'</segurado>'        ||-- Nome do segurado     
      '<cpf>'             ||rw_crawseg.nrcpfcgc                       ||'</cpf>'             ||-- Cpf do segurado                                     
      '<estadoCivil>'     ||rw_crawseg.rsestcvl                       ||'</estadoCivil>'     ||-- Estado Civil
      '<dataNascimento>'  ||to_char(rw_crawseg.dtnascsg,'DD/MM/RRRR') ||'</dataNascimento>'  ||-- Data de nascimento
      '<sexo>'            ||rw_crawseg.cdsexosg                       ||'</sexo>'            ||-- Sexo 
      '<endereco>'        ||rw_crawseg.Endereco                       ||'</endereco>'        ||-- Endereco
      '<bairro>'          ||rw_crawseg.nmbairro                       ||'</bairro>'          ||-- Nome do Bairro
      '<cidade>'          ||rw_crawseg.nmcidade                       ||'</cidade>'          ||-- Nome da Cidade
      '<uf>'              ||rw_crawseg.cdufresd                       ||'</uf>'              ||-- Unidade da Federacao
      '<cep>'             ||rw_crawseg.nrcepend                       ||'</cep>'             ||-- Cep
      '<contrato>'        ||rw_crawseg.nrctrato                       ||'</contrato>'        ||-- Número do Contrato de empr'estimo vinculado ao seguro 
      '<plano>'           ||rw_crawseg.tpplaseg                       ||'</plano>'           ||-- Plano
      '<saldoDevedor>'    ||vr_saldodevedor                           ||'</saldoDevedor>'    ||-- Saldo Devedor do Cooperado/Conta        
      '<dataIniVigencia>' ||to_char(rw_crawseg.dtinivig,'DD/MM/RRRR') ||'</dataIniVigencia>' ||-- Data de inicio da vigencia do seguro prestamista
      '<localData>'       ||vr_localedata                             ||'</localData>'       ||-- Local e data do seguro prestamista
      '<nomeCooperado>'   ||rw_crawseg.nmdsegur                       ||'</nomeCooperado>'   ||-- Nome do Coooperado
      '<contaCooperado>'  ||rw_crawseg.nrdconta                       ||'</contaCooperado>'  ||-- Conta do Cooperado
      '<operador>'|| rw_crawseg.nmoperad ||'</operador>'); -- Nome do operador           

    --> Descarregar buffer    
    pc_escreve_xml(' ',TRUE); 
    
    --> Descarregar buffer    
    pc_escreve_xml('</dadosRelatorio>',TRUE); 
    
    loop exit when l_offset > dbms_lob.getlength(vr_des_xml);
    DBMS_OUTPUT.PUT_LINE (dbms_lob.substr( vr_des_xml, 254, l_offset) || '~');
    l_offset := l_offset + 255;
    end loop;
    
    IF vr_id_imprime_dsp = 'S'THEN
      vr_dsjasper :='proposta_prestamista_dps.jasper';
    ELSE
      vr_dsjasper := 'proposta_prestamista.jasper';
    END IF;
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => pr_cdprogra
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/dadosRelatorio'
                               , pr_dsjasper  => vr_dsjasper
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 234
                               , pr_cdrelato  => 280
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_dsextmail => NULL
                               , pr_dsmailcop => vr_dsmailcop
                               , pr_dsassmail => vr_dsassmail
                               , pr_dscormail => vr_dscormail
                               , pr_des_erro  => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;        
    
    --IF pr_idorigem = 5 THEN
      -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => NULL
                                ,pr_nrdcaixa => NULL
                                ,pr_nmarqpdf => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);
    -- Se retornou erro
    IF NVL(vr_des_reto,'OK') <> 'OK' THEN
      IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;

    -- Remover relatorio do diretorio padrao da cooperativa
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => 'rm '||vr_dsdireto ||'/rl/'||pr_nmarqpdf
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    -- Se retornou erro
    IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
      -- Concatena o erro que veio
      vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
      RAISE vr_exc_erro; -- encerra programa
    END IF;
    --END IF;        
    
    --> Gerar log de sucesso
    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdopecxa, 
                           pr_dscritic => NULL, 
                           pr_dsorigem => vr_dsorigem, 
                           pr_dstransa => vr_dstransa, 
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans =>  1, -- True
                           pr_hrtransa => gene0002.fn_busca_time, 
                           pr_idseqttl => vr_idseqttl, 
                           pr_nmdatela => pr_nmdatela, 
                           pr_nrdconta => pr_nrdconta, 
                           pr_nrdrowid => vr_nrdrowid);
                             
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                pr_nmdcampo => 'nrctrseg', 
                                pr_dsdadant => NULL, 
                                pr_dsdadatu => pr_nrctrseg);
    END IF;
    
    COMMIT;
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrseg', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrseg);
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao da proposta de seguro de vida prestamista: ' || SQLERRM, chr(13)),chr(10));   
  
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrseg', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrseg);
      END IF; 
      
  END pc_imp_proposta_seg_pres;
--> Rotina para geração do relatório da proposta de seguro de vida prestamista - Ayllos Web
  PROCEDURE pc_imp_proposta_seg_pres_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
                                        ,pr_nrctrseg   IN crawseg.nrctrseg%TYPE  --> Proposta
                                        ,pr_nrctremp   IN crawepr.nrctremp%TYPE  --> Contrato                                    
                                        ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                        ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                        ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa:  pc_imp_proposta_seg_pres_web
    Sistema : Seguros - Cooperativa de Credito
    Autor   : Márcio(Mouts)
    Data    : Agosto/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para chamar as impressoes pelo Ayllos Web

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

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

      -- Variaveis gerais
      vr_nmarqpdf VARCHAR2(1000);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
                              
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_gera_impressao'
                                ,pr_action => vr_nmeacao);

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      pc_imp_proposta_seg_pres(pr_cdcooper => vr_cdcooper   --> Código da Cooperativa
                               ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                               ,pr_nrctrseg => pr_nrctrseg  --> Proposta
                               ,pr_nrctremp => pr_nrctremp  --> Contrato                                                                   
                               ,pr_cdagecxa => vr_cdagenci  --> Código da agencia
                               ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa do operador
                               ,pr_cdopecxa => vr_cdoperad  --> Código do Operador
                               ,pr_nmdatela => vr_nmdatela  --> Nome da Tela
                               ,pr_idorigem => vr_idorigem  --> Identificador de Origem
                               ,pr_cdprogra => 'ATENDA'     --> Codigo do programa
                               ,pr_cdoperad => vr_cdoperad  --> Código do Operador
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data de Movimento
                               ,pr_flgerlog => 1            --> True 
                               --------> OUT <--------
                               ,pr_nmarqpdf => vr_nmarqpdf       --> Retornar quantidad de registros                           
                               ,pr_cdcritic => vr_cdcritic       --> Código da crítica
                               ,pr_dscritic => vr_dscritic);     --> Descrição da crítica

      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_impres_termo_adesao_pf_web: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END  pc_imp_proposta_seg_pres_web;
------------------------------------                                                      
  PROCEDURE pc_validar_prestamista(pr_cdcooper in crapcop.cdcooper%type,
                                   pr_nrdconta in crapass.nrdconta%type,
                                   pr_nrctremp in crapepr.nrctremp%type,
                                   pr_cdagenci IN crapage.cdagenci%type,  --> Código da agencia
                                   pr_nrdcaixa IN crapbcx.nrdcaixa%type,  --> Numero do caixa do operador
                                   pr_cdoperad IN crapope.cdoperad%type,  --> Código do Operador
                                   pr_nmdatela IN craptel.nmdatela%type,  --> Nome da Tela
                                   pr_idorigem IN INTEGER,                --> Identificador de Origem       
                                   pr_valida_proposta in varchar2,         --> Usado não para validar o cancelamento em pc_crps781
                                   pr_sld_devedor out crawseg.vlseguro%type,   --> Valor proposta   
                                   pr_flgprestamista out char,
                                   pr_flgdps         out char,
                                   pr_dsmotcan out varchar2,
                                   pr_cdcritic out crapcri.cdcritic%type,    --> Codigo da critica
                                   pr_dscritic out crapcri.dscritic%type) IS --> Descricao da critica  
                                   

                                     
    /* .............................................................................

    Programa:  pc_validar_prestamista
    Sistema : Ayllos Web
    Autor   : Paulo Martins(Mouts)
    Data    : Agosto/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Validaçoes para criação, impressão e efetivação de seguro prestamista

    Alteracoes: -----
    ..............................................................................*/                                     
                                     
  -- Dados Cooperado
   CURSOR cr_crapass IS
      SELECT d.dtnasctl
      FROM crapass d
      WHERE d.cdcooper = pr_cdcooper
      AND   d.nrdconta = pr_nrdconta;

                                     
  -- Busca da idade limite
  CURSOR cr_craptsg IS
    SELECT nrtabela
      FROM craptsg
     WHERE cdcooper = pr_cdcooper
       AND tpseguro = 4
       AND tpplaseg = 1
       AND cdsegura = 5011; -- SEGURADORA CHUBB                                     

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);         

  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;                                
                                    
  -- Variaveis para retorno da parametrização do relatório
  vr_dstextab     craptab.dstextab%TYPE;  --> Busca na craptab
  
  vr_vallidps     number;
  vr_sld_devedor  crawseg.vlseguro%type;    
  vr_sld_devempr  crapseg.vlslddev%type; 
  vr_valor_para_validacao crapseg.vlslddev%type;
  vr_vlminimo     number;                 
  --vr_vlmaximo     number;      
  -- Idade do cooperado
  vr_nrdeanos     PLS_INTEGER;
  vr_nrdeanos_aux PLS_INTEGER;  
  vr_nrdmeses     PLS_INTEGER;
  vr_dsdidade     VARCHAR2(50);  
  vr_dtnasctl     crawseg.dtnascsg%type;   
      
  BEGIN
  
  /*Busca Saldo Devedor*/

  segu0003.pc_saldo_devedor(pr_cdcooper => pr_cdcooper
                          , pr_nrdconta => pr_nrdconta
                          , pr_nrctremp => pr_nrctremp
                          , pr_cdagenci => pr_cdagenci
                          , pr_nrdcaixa => pr_nrdcaixa
                          , pr_cdoperad => pr_cdoperad
                          , pr_nmdatela => pr_nmdatela
                          , pr_idorigem => pr_idorigem
                          , pr_saldodevedor => vr_sld_devedor -- Armazena o Saldo Devedor
                          , pr_saldodevempr => vr_sld_devempr
                          , pr_cdcritic => vr_cdcritic
                          , pr_dscritic => vr_dscritic);

  -- Leitura dos valores de mínimo e máximo
  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'USUARI'
                                           ,pr_cdempres => 11
                                           ,pr_cdacesso => 'SEGPRESTAM'
                                           ,pr_tpregist => 0);
  -- Se não encontrar
  IF vr_dstextab IS NULL THEN
    -- Usar valores padrão
    vr_vlminimo := 0;
    --vr_vlmaximo := 999999999.99;
  ELSE
    -- Usar informações conforme o posicionamento
    -- Valor mínimo da posição 27 a 39
    vr_vlminimo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,27,12));
    -- Valor máximo da posição 14 a 26
    -- Foi definido como regra, não validar valores máximos 
    -- vr_vlmaximo := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));
  END IF;


  -- Buscar idade limite
  OPEN cr_craptsg;
  FETCH cr_craptsg
   INTO vr_nrdeanos;
  -- Se não tiver encontrado
  IF cr_craptsg%NOTFOUND THEN
    -- Usar 0
    vr_nrdeanos := 0;
  END IF;

  CLOSE cr_craptsg;
  
  -- Buscar data de Nascimento - Proposta
  OPEN cr_crapass;
  FETCH cr_crapass
   INTO vr_dtnasctl;
  CLOSE cr_crapass;  
  
  -- Leitura do calendário da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
   INTO rw_crapdat;
  -- Se não encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE btch0001.cr_crapdat;

  END IF;  
  
  -- Rotina responsavel por calcular a quantidade de anos e meses entre as datas
  CADA0001.pc_busca_idade(pr_dtnasctl => vr_dtnasctl -- Data de Nascimento
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data da utilizacao atual
                         ,pr_nrdeanos => vr_nrdeanos_aux     -- Numero de Anos
                         ,pr_nrdmeses => vr_nrdmeses                -- Numero de meses
                         ,pr_dsdidade => vr_dsdidade                -- Descricao da idade
                         ,pr_des_erro => vr_dscritic);       -- Mensagem de Erro
                         
    if pr_valida_proposta = 'N' then
      vr_valor_para_validacao := vr_sld_devempr; -- Valor somente dos emprestimos    
    else
      vr_valor_para_validacao := vr_sld_devedor; -- Valor de emprestimos + proposta
    end if;
  
    pr_flgprestamista := 'N';
    --Validar Valor 
    if vr_valor_para_validacao > vr_vlminimo /*and vr_valor_para_validacao < vr_vlmaximo*/ then
      pr_flgprestamista := 'S';
      --Validar Idades
      if vr_nrdeanos_aux > vr_nrdeanos then
        pr_flgprestamista := 'N';
        pr_dsmotcan := 'Idade acima do limite';      
      end if;      
    else
      if vr_valor_para_validacao < vr_vlminimo then
        pr_dsmotcan := 'Saldo devedor abaixo do valor mínimo';
      /*elsif vr_valor_para_validacao > vr_vlmaximo then
        pr_dsmotcan := 'Saldo devedor acima do valor máximo';*/
      end if;
    end if;

    pr_flgdps := 'N';
    if pr_flgprestamista = 'S' then
    -- Buscar o valor para impressão com DPS ou sem DPS
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'SEGPRESTAM'
                                             ,pr_tpregist => 0);
    --Se nao encontrou parametro
    IF TRIM(vr_dstextab) IS NULL THEN
      vr_cdcritic := 55;
      RAISE vr_exc_saida;
    ELSE
      -- EFETUA OS PROCEDIMENTOS COM O DADO RETORNADO DA CRAPTAB
      vr_vallidps := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,94,12));
      IF vr_vallidps IS NULL THEN
        vr_dscritic := 'Parametro de Valor Limite para Impressao com DPS nao cadastrado!';
        RAISE vr_exc_saida;
      END IF;

    END IF;  
    
    if vr_valor_para_validacao > vr_vallidps then
      pr_flgdps := 'S';
    end if;
    end if;
  
    pr_sld_devedor := vr_sld_devedor;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      -- ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      -- ROLLBACK;  
  END pc_validar_prestamista; 

  PROCEDURE pc_cria_proposta_sp(pr_cdcooper in crapcop.cdcooper%type,
                                pr_nrdconta in crapass.nrdconta%type,
                                pr_nrctremp in crapepr.nrctremp%type,
                                pr_cdagenci IN crapage.cdagenci%type,  --> Código da agencia
                                pr_nrdcaixa IN crapbcx.nrdcaixa%type,  --> Numero do caixa do operador
                                pr_cdoperad IN crapope.cdoperad%type,  --> Código do Operador
                                pr_nmdatela IN craptel.nmdatela%type,  --> Nome da Tela
                                pr_idorigem IN INTEGER,                --> Identificador de Origem                                     
                                pr_cdcritic out crapcri.cdcritic%type,    --> Codigo da critica
                                pr_dscritic out crapcri.dscritic%type) IS --> Descricao da critica  
                                     
    /* .............................................................................

    Programa:  pc_validar_prestamista
    Sistema : Ayllos Web
    Autor   : Paulo Martins(Mouts)
    Data    : Agosto/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Validaçoes para criação, impressão e efetivação de seguro prestamista

    Alteracoes: -----
    ..............................................................................*/                                     
                                     

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000); 
    
    -- 
    vr_flgprestamista varchar2(1) := 'N';        
    vr_flgdps         varchar2(1) := 'N';
    vr_vlproposta     crawseg.vlseguro%type;  
    vr_dsmotcan  VARCHAR2(60);  
    
  BEGIN
  
   --Validar necessidade de criação
   segu0003.pc_validar_prestamista(pr_cdcooper => pr_cdcooper
                                 , pr_nrdconta => pr_nrdconta
                                 , pr_nrctremp => pr_nrctremp
                                 , pr_cdagenci => pr_cdagenci
                                 , pr_nrdcaixa => pr_nrdcaixa
                                 , pr_cdoperad => pr_cdoperad
                                 , pr_nmdatela => pr_nmdatela
                                 , pr_idorigem => pr_idorigem
                                 , pr_valida_proposta => 'S' -- Na criação considera proposta + Saldo
                                 , pr_sld_devedor => vr_vlproposta
                                 , pr_flgprestamista => vr_flgprestamista
                                 , pr_flgdps => vr_flgdps
                                 , pr_dsmotcan => vr_dsmotcan                                 
                                 , pr_cdcritic => vr_cdcritic
                                 , pr_dscritic => vr_dscritic);
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;                                                                   
                                      
   --Cria proposta
   if vr_flgprestamista = 'S' then
     segu0001.pc_cria_proposta_seguro_p(pr_cdcooper => pr_cdcooper
                                      , pr_nrdconta => pr_nrdconta
                                      , pr_vlseguro => vr_vlproposta
                                      , pr_nrctrato => pr_nrctremp
                                      , pr_cdoperad => pr_cdoperad
                                      , pr_cdcritic => vr_cdcritic
                                      , pr_dscritic => vr_dscritic);
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;                                           
   end if;

  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      -- ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      -- ROLLBACK;  
  END pc_cria_proposta_sp;   
                                                                       
  PROCEDURE pc_efetiva_proposta_sp(pr_cdcooper in crapcop.cdcooper%type,
                                   pr_nrdconta in crapass.nrdconta%type,
                                   pr_nrctrato in crawseg.nrctrato%type,
                                   pr_cdagenci IN crapage.cdagenci%type,  --> Código da agencia
                                   pr_nrdcaixa IN crapbcx.nrdcaixa%type,  --> Numero do caixa do operador
                                   pr_cdoperad IN crapope.cdoperad%type,  --> Código do Operador
                                   pr_nmdatela IN craptel.nmdatela%type,  --> Nome da Tela
                                   pr_idorigem IN INTEGER,                --> Identificador de Origem                                     
                                   pr_cdcritic out crapcri.cdcritic%type,    --> Codigo da critica
                                   pr_dscritic out crapcri.dscritic%type) IS --> Descricao da critica  
                                     
    /* .............................................................................

    Programa:  pc_validar_prestamista
    Sistema : Ayllos Web
    Autor   : Paulo Martins(Mouts)
    Data    : Agosto/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Validaçoes para criação, impressão e efetivação de seguro prestamista

    Alteracoes: -----
    ..............................................................................*/         
    
    -- Proposta para efetivar ou excluir
    CURSOR c_proposta IS
    select s.rowid,
           s.nrctrseg
      from crawseg s
     where s.tpseguro = 4
       and s.cdcooper = pr_cdcooper
       and s.nrdconta = pr_nrdconta
       and s.nrctrato = pr_nrctrato
       and not exists (select 1 
                         from crapseg p
                        where s.cdcooper = p.cdcooper
                          and s.nrdconta = p.nrdconta
                          and s.tpseguro = p.tpseguro
                          and s.nrctrseg = p.nrctrseg);   
       r_proposta c_proposta%rowtype;                                                                    
                                     

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000); 
    
    -- 
    vr_flgprestamista varchar2(1) := 'N';        
    vr_flgdps         varchar2(1) := 'N';
    vr_vlproposta     crawseg.vlseguro%type; 
    vr_dsmotcan       VARCHAR2(60);        
    
  BEGIN
    
   open c_proposta;
    fetch c_proposta into r_proposta;
     if c_proposta%found then
       --Validar necessidade de criação
       segu0003.pc_validar_prestamista(pr_cdcooper => pr_cdcooper
                                     , pr_nrdconta => pr_nrdconta
                                     , pr_nrctremp => pr_nrctrato
                                     , pr_cdagenci => pr_cdagenci
                                     , pr_nrdcaixa => pr_nrdcaixa
                                     , pr_cdoperad => pr_cdoperad
                                     , pr_nmdatela => pr_nmdatela
                                     , pr_idorigem => pr_idorigem
                                     , pr_valida_proposta => 'N' --Na efetivação da proposta o emprestimo já esta efetivado
                                     , pr_sld_devedor => vr_vlproposta
                                     , pr_flgprestamista => vr_flgprestamista
                                     , pr_flgdps => vr_flgdps
                                     , pr_dsmotcan =>  vr_dsmotcan
                                     , pr_cdcritic => vr_cdcritic
                                     , pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          close c_proposta;
          RAISE vr_exc_saida;
        END IF;    
     end if;

    close c_proposta;
                                      
   --Cria proposta
   if vr_flgprestamista = 'S' then
     segu0001.pc_efetiva_proposta_seguro_p(pr_cdcooper => pr_cdcooper
                                         , pr_nrdconta => pr_nrdconta 
                                         , pr_nrctrato => pr_nrctrato
                                         , pr_cdoperad => pr_cdoperad
                                         , pr_cdagenci => pr_cdagenci
                                         , pr_vlslddev => vr_vlproposta
                                         , pr_idimpdps => vr_flgdps 
                                         , pr_cdcritic => vr_cdcritic
                                         , pr_dscritic => vr_dscritic);

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;      
   else
     -- Validar se existe proposta prestamista para este contrato se encontrar deleta
     open c_proposta;
      fetch c_proposta into r_proposta;
       if c_proposta%found then
         begin
          delete from crawseg s where s.rowid = r_proposta.rowid;

         exception
           when others then
            close c_proposta;
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao deletar proposta: '||sqlerrm;

         end;

       end if;

      close c_proposta;

   end if;

  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      -- ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      -- ROLLBACK;  
  END pc_efetiva_proposta_sp; 
    
  PROCEDURE pc_valida_contrato( pr_nrctrato IN crawseg.nrctrato%TYPE --Número do contrato
                               ,pr_nrdconta IN crawseg.nrdconta% TYPE -- Número da conta
                               ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2)IS         --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_valida_contrato      Antiga: 
    Sistema : Seguros - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Márcio (Mouts)
    Data    : 04/09/2018                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Por demanda
    Objetivo  : Verificar se o contrato já está associado a algum seguro prestamista

    Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------*/
  
  ------------------------------- VARIÁVEIS --------------------------------  
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 
  
 
  -- Variaveis de log
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);
  
  --Variaveis de Excecoes    
  vr_exc_erro  EXCEPTION;                                       
  
  BEGIN
               
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Validar que o contrato existe para a cooperativa e conta informada
    BEGIN
      SELECT 
            'OK'
        INTO
           pr_des_erro
        FROM
           crawepr c
       WHERE
           c.cdcooper = vr_cdcooper
       AND c.nrdconta = pr_nrdconta 
       AND c.nrctremp = pr_nrctrato
       AND c.nrctremp > 0;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       vr_dscritic:= 'Contrato informado nao pertence ao cooperado!';
      WHEN OTHERS THEN
        vr_dscritic:= 'Erro ao executar a rotina SEGU0003.pc_valida_contrato.'|| SQLERRM;
      --Levantar Excecao
      RAISE vr_exc_erro;          
    END;
        
    -- Verificar se o contrato está associado a alguma proposta de seguro prestamista
    -- Se estiver, retornar mensagem informando
    BEGIN
      SELECT 
            'Proposta de Prestamista já contratada! Proposta: '||c.nrctrseg||'.'
        INTO
           vr_dscritic
        FROM
           crawseg c
       WHERE
           c.cdcooper = vr_cdcooper
       AND c.nrdconta = pr_nrdconta 
       AND c.nrctrato = pr_nrctrato
       AND c.nrctrato > 0;       
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       pr_des_erro:='OK';
      WHEN OTHERS THEN
        vr_dscritic:= 'Erro ao executar a rotina SEGU0003.pc_valida_contrato.'|| SQLERRM;
      --Levantar Excecao
      RAISE vr_exc_erro;          
    END;
                                      
    if vr_dscritic is not null then
      --Levantar Excecao
      RAISE vr_exc_erro;
    end if;                                             
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');           
        
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                                     
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
      
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro ao executar a rotina BLQJ0002.PC_VAL_OPE_JURIDICO --> '|| SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  
  END pc_valida_contrato;

  PROCEDURE pc_busca_contratos(pr_nrdconta IN CRAPASS.NRDCONTA%TYPE --> Número da conta
                              ,pr_nrregist IN INTEGER               --> Quantidade de registros
                              ,pr_nriniseq IN INTEGER               --> Qunatidade inicial
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_contratos
    Sistema : CECRED
    Sigla   : EMPR
    Autor   : Márcio (Mouts)
    Data    : Setembro/2018                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar os códigos dos contratos cadastrados na CRAWEPR aprovados 
                e que não estejam associados a uma proposta de seguro prestamista
    
    Alteracoes: 09/10/2018 - Alterado para buscar dados da crapepr (Propostas efetivadas) -- Paulo Martins - Mouts
    ............................................................................. */
    CURSOR cr_crawepr(p_cdcooper IN crapcop.cdcooper%type) IS             
      SELECT 
              e.nrctremp
          FROM
              crapepr e
         WHERE 
              e.cdcooper = p_cdcooper
          AND e.nrdconta = pr_nrdconta
		  AND e.inliquid = 0
          AND NOT EXISTS (SELECT 
                                1 
                            FROM 
                                crawseg cc 
                           WHERE
                                cc.cdcooper = e.cdcooper 
                            AND cc.nrdconta = e.nrdconta 
                            AND cc.nrctrato = e.nrctremp
                            AND cc.tpseguro = 4)          
      ORDER BY          
              e.nrctremp;          
              
    -- Variaveis de log
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_auxconta PLS_INTEGER := 0;

    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida EXCEPTION;

    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    vr_qtregist INTEGER;

  BEGIN -- Inicio pc_busca_paises

    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'SEGU0003'
                              ,pr_action => null);

    -- Extrai os dados dos dados que vieram do php
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'crawepr',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    FOR rw_crawepr IN cr_crawepr (vr_cdcooper) LOOP

      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo contrato
        CONTINUE;
      END IF;

      --Numero Registros
      IF vr_nrregist > 0 THEN
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'crawepr'      ,pr_posicao => 0          , pr_tag_nova => 'dados_crawepr', pr_tag_cont => NULL                , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'dados_crawepr',pr_posicao => vr_auxconta, pr_tag_nova => 'nrctremp'     , pr_tag_cont => rw_crawepr.nrctremp , pr_des_erro => vr_dscritic);
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;
      END IF;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'crawepr'           --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

    WHEN OTHERS THEN

      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral (TELA_FATCA_CRS.pc_busca_paises).';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;
    
  END pc_busca_contratos;

END SEGU0003;
/
