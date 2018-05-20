CREATE OR REPLACE PACKAGE CECRED.CTME0001 AS

  /*---------------------------------------------------------------------------------------------------------------
  --
  -- Programa : CTME0001
  --  Sistema : Processos Batch
  --  Sigla   : BTCH
  --  Autor   : Odirlei Busana - AMcom
  --  Data    : Maio/2014.                       Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas de Controle de Movimentacao de especie
  --
  -- Alteracoes: 29/02/2016 - Trocando o campo flpolexp para inpolexp conforme
  --                          solicitado no chamado 402159 (Kelvin)
  --
  ---------------------------------------------------------------------------------------------------------------*/

  -- Type para armazenar a descrição das opções recebidas por parametro
  TYPE typ_des_dsdopcao IS VARRAY(3) OF VARCHAR2(15);
  vr_tab_dsdopcao typ_des_dsdopcao := typ_des_dsdopcao('Inclusao','Alteracao','Exclusao');

  -- Type para armazenar a descrição dos tipos de operação
  TYPE typ_des_dsoperac IS VARRAY(3) OF VARCHAR2(15);
  vr_tab_dsoperac typ_des_dsoperac := typ_des_dsoperac('Deposito','Saque');

  --type para armazenar os registros que precisam ser processados
  TYPE typ_reg_crapcme IS RECORD
    (rowidcme rowid
    ,nrdconta NUMBER);
  TYPE typ_tab_crapcme IS
    TABLE OF typ_reg_crapcme
      INDEX BY BINARY_INTEGER;

  /******************************************************************************
    Montar e enviar o email que trata sobre Controle de Movimentacao
  ******************************************************************************/
  PROCEDURE pc_email_controle_movimentacao (pr_cdcooper  IN NUMBER,         -- Codigo da cooperativa
                                            pr_cdagenci  IN NUMBER,         -- Codigo da agencia
                                            pr_nrdcaixa  IN NUMBER,         -- Numero do caixa
                                            pr_cdoperad  IN VARCHAR2,       -- codigo do operador
                                            pr_nmdatela  IN VARCHAR2,       -- Nome da tela
                                            pr_idorigem  IN INTEGER,        -- indicador de origem
                                            pr_nrdconta  IN NUMBER,         -- Numero da conta
                                            pr_idseqttl  IN NUMBER,         -- Indicador de titular
                                            pr_cddopcao  IN INTEGER,        -- Codigo da opção
                                            pr_rowidcme  IN VARCHAR2,       -- rowid do crapcme
                                            pr_flgenvia  IN BOOLEAN,        -- indicador se deve enviar email
                                            pr_dtmvtolt  IN DATE ,          -- data do movimento
                                            pr_flgerlog  IN BOOLEAN,        -- indicador se gera log
                                            pr_des_xml  IN OUT clob,        -- xml do relatorio
                                            pr_flgprime IN OUT BOOLEAN,     -- flag de controle de impressao
                                            pr_nmarqimp IN OUT VARCHAR2,    -- Nome do arquivo de impressao
                                            pr_nmarqpdf IN OUT VARCHAR2,    -- Nome do pdf do relatorio
                                            pr_des_erro OUT VARCHAR2,       -- retorno se existe erro OK/NOK
                                            pr_tab_erro OUT GENE0001.typ_tab_erro);


  /******************************************************************************
     Gerar e enviar por email o arquivo de varios controles de movimentacao
  ******************************************************************************/
  PROCEDURE pc_gera_arquivo_controle (pr_cdcooper  IN NUMBER,                    -- Codigo da cooperativa
                                      pr_cdagenci  IN NUMBER,                    -- Codigo da agencia
                                      pr_nrdcaixa  IN NUMBER,                    -- Numero do caixa
                                      pr_cdoperad  IN VARCHAR2,                  -- codigo do operador
                                      pr_nmdatela  IN VARCHAR2,                  -- Nome da tela
                                      pr_idorigem  IN INTEGER,                   -- indicador de origem
                                      pr_cddopcao  IN INTEGER,                   -- Codigo da opção
                                      pr_dtmvtolt  IN DATE ,                     -- data do movimento
                                      pr_dtarquiv  IN DATE ,                     -- Data do arquivo
                                      pr_flgerlog  IN BOOLEAN,                   -- indicador se gera log
                                      pr_tab_crapcme typ_tab_crapcme,            -- temp-table com os registros a processar
                                      pr_des_erro OUT VARCHAR2,                  -- retorno se existe erro OK/NOK
                                      pr_tab_erro OUT GENE0001.typ_tab_erro);

END CTME0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CTME0001 AS

  /*---------------------------------------------------------------------------------------------------------------
  --
  -- Programa : CTME0001
  --  Sistema : Processos Batch
  --  Sigla   : BTCH
  --  Autor   : Odirlei Busana - AMcom
  --  Data    : Maio/2014.                       Ultima atualizacao: 10/08/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas de Controle de Movimentacao de especie
  --
  -- Alteracoes: 29/02/2016 - Trocando o campo flpolexp para inpolexp conforme
                              solicitado no chamado 402159 (Kelvin)

                 10/08/2017 - #694567 Alteração do parâmetro pr_flg_impri para 'N' em pc_solicia_relato 
                              pois este relatório não vai para a intranet (Carlos)

  ---------------------------------------------------------------------------------------------------------------*/

  /******************************************************************************
    Gerar o relatorio e enviar por e-mail
  ******************************************************************************/
  PROCEDURE pc_gera_envia_relatoCME (pr_cdcooper IN NUMBER,          --> Codigo da cooperativa
                                     pr_nmdatela IN VARCHAR2,        --> Nome da tela
                                     pr_dtmvtolt IN DATE ,           --> data do movimento
                                     pr_des_xml  IN OUT NOCOPY CLOB, --> Xml do relatorio
                                     pr_nmarqimp IN VARCHAR2,        --> local/nome do relatorio
                                     pr_nmarqpdf IN VARCHAR2,        --> local/nome do relatorio em pdf
                                     pr_flgenvia IN BOOLEAN,         --> indicador se deve enviar por email
                                     pr_dsdemail IN VARCHAR2,        --> destino do email
                                     pr_gerrelat IN BOOLEAN,         --> Indica se deve gerar o relatorio ou ja esta gerado, somente enviar
                                     pr_flappend IN VARCHAR2,        --> indica se deverá concatenar com o relatorio ja existente
                                     pr_dscritic OUT VARCHAR2)is     --> retorna critica encontrada

   /*---------------------------------------------------------------------------------------------------------------
      Programa: pc_gera_envia_relatoCME
      Sistema : Processos Batch
      Sigla   : CRED
      Autora  : Odirlei Busana(AMcom)
      Data    : Maio/2014.                     Ultima atualizacao: 26/05/2014

      Dados referentes ao programa:

      Frequencia: Sempre que chamada
      Objetivo  : Rotina responsavel em solicitar a geração do relatorio e enviar por email

      Alteracoes: 25/08/2014 - Retirado emails fixos para validação (Odirlei-AMcom)
    ---------------------------------------------------------------------------------------------------------------*/

     vr_dscritic  VARCHAR2(2000);
     vr_exc_erro  exception;


  BEGIN

    -- verificar se deve gerar o relatorio
    IF pr_gerrelat  THEN
      -- Efetuar solicitação de geração de relatório --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_nmdatela         --> Programa chamador
                                 ,pr_dtmvtolt  => pr_dtmvtolt         --> Data do movimento atual
                                 ,pr_dsxml     => pr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/detalhe'    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrlCME.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parametros
                                 ,pr_dsarqsaid => pr_nmarqimp         --> Arquivo final com código da agência
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_cdrelato  => 1                   --> codigo do relatorio
                                 ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_flg_impri => 'N'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_flg_gerar => 'S'                 --> gerar na hora
                                 ,pr_flappend  => pr_flappend         --> indica se deverá concatenar com o relatorio ja existente
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        raise vr_exc_erro;
      END IF;
    END IF;

    -- verificar se deve enviar por email o relatorio
    IF pr_flgenvia THEN
      --Gerar PDF do relatorio
      gene0002.pc_gera_pdf_impressao
                                ( pr_cdcooper => pr_cdcooper    --> Cooperativa conectada
                                 ,pr_nmarqimp => pr_nmarqimp    --> Arquivo a ser convertido para pDf
                                 ,pr_nmarqpdf => pr_nmarqpdf    --> Arquivo PDF  a ser gerado
                                 ,pr_des_erro => vr_dscritic);  --> Saída com erro

      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        raise vr_exc_erro;
      END IF;

      -- Mandar arquivo por email
      gene0003.pc_solicita_email( pr_cdcooper    => pr_cdcooper               --> Cooperativa conectada
                                 ,pr_cdprogra    => pr_nmdatela               --> Programa conectado
                                 ,pr_des_destino => pr_dsdemail               --> Dest. sep. por ';' ou ','
                                 ,pr_des_assunto => 'Controle de Movimentacao'--> Assunto do e-mail
                                 ,pr_des_corpo   => NULL                      --> Corpo do email
                                 ,pr_des_anexo   => pr_nmarqpdf               --> Anexo
                                 ,pr_flg_remove_anex => 'N'                   --> indicador se deve remover anexo
                                 -- provisorio para teste, posteriormente não precisa enviar na hora --> odirlei
                                 ,pr_flg_enviar      => 'S'                   --> Indicado se deve enviar na hora o email
                                 ,pr_des_erro    => vr_dscritic);             --> Desc. da crítica

      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        raise vr_exc_erro;
      END IF;
      -- Remover txt
      gene0001.pc_OScommand_Shell('rm '||pr_nmarqimp||' 2>/dev/null');

    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Erro não tratado
      pr_dscritic := 'Erro na pc_gera_envia_relatoCME: '||SQLerrm;

  END pc_gera_envia_relatoCME;

  /******************************************************************************
   Montar e enviar o email que trata sobre Controle de Movimentacao
  ******************************************************************************/
  PROCEDURE pc_email_controle_movimentacao (pr_cdcooper  IN NUMBER,           -- Codigo da cooperativa
                                            pr_cdagenci  IN NUMBER,           -- Codigo da agencia
                                            pr_nrdcaixa  IN NUMBER,           -- Numero do caixa
                                            pr_cdoperad  IN VARCHAR2,         -- codigo do operador
                                            pr_nmdatela  IN VARCHAR2,         -- Nome da tela
                                            pr_idorigem  IN INTEGER,          -- indicador de origem
                                            pr_nrdconta  IN NUMBER,           -- Numero da conta
                                            pr_idseqttl  IN NUMBER,           -- Indicador de titular
                                            pr_cddopcao  IN INTEGER,          -- Codigo da opção
                                            pr_rowidcme  IN VARCHAR2,         -- rowid do crapcme
                                            pr_flgenvia  IN BOOLEAN,          -- indicador se deve enviar email
                                            pr_dtmvtolt  IN DATE ,            -- data do movimento
                                            pr_flgerlog  IN BOOLEAN,          -- indicador se gera log
                                            pr_des_xml  IN OUT NOCOPY CLOB,   -- xml do relatorio
                                            pr_flgprime IN OUT BOOLEAN,       -- flag de controle de impressao
                                            pr_nmarqimp IN OUT VARCHAR2,      -- Nome do arquivo de impressao
                                            pr_nmarqpdf IN OUT VARCHAR2,      -- Nome do pdf do relatorio
                                            pr_des_erro OUT VARCHAR2,         -- retorno se existe erro OK/NOK
                                            pr_tab_erro OUT GENE0001.typ_tab_erro) IS

    /*---------------------------------------------------------------------------------------------------------------
      Programa: pc_email_controle_movimentacao        Antigo: b1wgen9998.p/email-controle-movimentacao
      Sistema : Processos Batch
      Sigla   : CRED
      Autora  : Odirlei Busana(AMcom)
      Data    : Maio/2014.                     Ultima atualizacao: 26/05/2014

      Dados referentes ao programa:

      Frequencia: Sempre que chamada
      Objetivo  : Montar e enviar o email que trata sobre Controle de Movimentacao

      Alteracoes: 19/12/2017 - Antonio R. Jr (mouts): Adicionado tipo de operacao 3.
    ---------------------------------------------------------------------------------------------------------------*/

    ------------------------------- CURSORES ---------------------------------
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.dsemlcof
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Buscar controle de movimentacao em especie
    CURSOR cr_crapcme IS
      SELECT cpfcgrcb,
             vllanmto,
             tpoperac,
             cdagenci,
             nrdocmto,
             inpesrcb,
             nmpesrcb,
             vlretesp,
             dstrecur,
             recursos,
             nrccdrcb,
             decode(inpesrcb,1,'CPF','CNPJ') dsinpesrcb
        FROM crapcme
       WHERE ROWID = pr_rowidcme;
    rw_crapcme cr_crapcme%rowtype;

    -- buscar associado, pelo numero da conta ou cpf/cnpj
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%type,
                       pr_nrcpfcgc crapass.nrcpfcgc%type) IS
      SELECT nrdconta,
             inpessoa,
             dtadmiss,
             nrcpfcgc
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)
         AND crapass.nrcpfcgc = nvl(pr_nrcpfcgc,crapass.nrcpfcgc)
       ORDER BY cdcooper, nrdconta ;
    rw_crapass cr_crapass%rowtype;
    rw_crabass  cr_crapass%rowtype; --outro ponteiro

    -- Buscar informações da agencia
    CURSOR cr_crapage (pr_cdcooper crapass.cdcooper%type,
                       pr_cdagenci crapass.cdagenci%type) IS
      SELECT nmcidade
            ,nmresage
            ,cdagenci
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper
         AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%rowtype;

    -- buscar alterações da conta
    CURSOR cr_crapalt (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%type) IS
      SELECT dtaltera
        FROM crapalt
       WHERE crapalt.cdcooper = pr_cdcooper
         AND crapalt.nrdconta = pr_nrdconta
         AND crapalt.tpaltera = 1
       ORDER BY cdcooper, nrdconta, dtaltera desc;
    rw_crapalt cr_crapalt%rowtype;
    rw_crabalt cr_crapalt%rowtype; -- Outro ponteiro

    -- buscar titular
    CURSOR cr_crapttl (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%type) IS
      SELECT cdocpttl
            ,idseqttl
            ,nmextttl
            ,inpolexp 
            ,decode(inpolexp,0,'Nao',1,'Sim',2,'Pendente') dsinpolexp
            ,nrcpfcgc
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta;
    rw_crapttl cr_crapttl%rowtype;

    -- buscar pessoa juridica
    CURSOR cr_crapjur (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%type) IS
      SELECT nmextttl
        FROM crapjur
       WHERE crapjur.cdcooper = pr_cdcooper
         AND crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%rowtype;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

    ------------------------------- VARIAVEIS -------------------------------
    -- descrição de origem
    vr_dsorigem  VARCHAR2(100);
    -- descrição da transação
    vr_dstransa  VARCHAR2(100);
    -- variaveis para armazenar as criticas
    vr_cdcritic  NUMBER;
    vr_dscritic  VARCHAR2(2000);
    vr_exec_sair exception;
    -- codigos de ocupação dos titulares - servidores publicos
    vr_dsocpttl  VARCHAR2(2000);
    -- descrição da informação na tabela generica
    vr_dstextab  craptab.dstextab%type;
    -- Flag para controlar se localizou associado
    vr_crapass   BOOLEAN := FALSE;
    -- Descrição da opção
    vr_dsdopcao  VARCHAR2(200);
    -- descrição da cooperativa
    vr_nmextcop  VARCHAR2(200);
    -- descrição da agencia
    vr_dsagenci  VARCHAR2(200);
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  varchar2(32600);
    -- diretorio de geracao do relatorio
    vr_nom_direto  VARCHAR2(200);
    -- nome dos arquivos a serem gerados
    vr_nmarquiv  VARCHAR2(200);
    -- Descrição se é servidor publico
    vr_dsdpubli  VARCHAR2(10);
    -- Rowid do log
    vr_nrdrowid  ROWID;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    procedure pc_escreve_xml(pr_des_dados in varchar2,
                             pr_fecha_xml in boolean default false) is
    begin
      gene0002.pc_escreve_xml(pr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    end;

  BEGIN

    -- Busca do diretório base da cooperativa para PDF
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => null);


    -- Iniciar valores
    IF pr_flgerlog   THEN
      vr_dsorigem := trim(gene0001.vr_vet_des_origens(pr_idorigem));
      vr_dstransa := 'Enviar e-mail para Controle de Movimentacao.';
    END IF;

    vr_cdcritic := 0;
    vr_dscritic := null;
    -- codigo de ocupação dos servidores publicos
    vr_dsocpttl := '169,319,67,309,308,271,65,306,272,273,74,305,69,'||
                   '316,209,311,303,64,310,314,313,315,307,76,75,77,317,325,312,304';

    BEGIN
      -- Validar cooperativa
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- definir critica e ir para o final
        vr_cdcritic := 794;
        CLOSE cr_crapcop;
        raise vr_exec_sair;
      END IF;
      CLOSE cr_crapcop;

      -- buscar controle de movimentacao em especie
      OPEN cr_crapcme;
      FETCH cr_crapcme
       INTO rw_crapcme;
      -- Se não encontrar
      IF cr_crapcme%NOTFOUND THEN
        -- definir critica e ir para o final
        vr_dscritic := 'Controle de movimentacao nao encontrado.';
        CLOSE cr_crapcme;
        raise vr_exec_sair;
      END IF;
      CLOSE cr_crapcme;

      -- buscar associado pelo numero da conta
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_nrcpfcgc => null);
      FETCH cr_crapass INTO rw_crapass;
      -- se não localizar
      IF cr_crapass%NOTFOUND THEN
        close cr_crapass;
        -- tentar buscar pelo CPF/CNPJ
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => null,
                         pr_nrcpfcgc => rw_crapcme.cpfcgrcb);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%FOUND THEN
          vr_crapass := true;
          /* Nas contas administrativas nao é necessario ter o controle */
          IF rw_crapass.inpessoa = 3 THEN
            pr_des_erro := 'OK';
            RETURN;
          END IF;
        END IF;
        CLOSE cr_crapass;
      ELSE
        vr_crapass := true;
        CLOSE cr_crapass;
      END IF;

      -- Buscar informação na craptab
      vr_dstextab := null;
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper,
                                                 pr_nmsistem => 'CRED',
                                                 pr_tptabela => 'GENERI',
                                                 pr_cdempres => 0,
                                                 pr_cdacesso => 'VMINCTRCEN',
                                                 pr_tpregist => 0);

      -- verificar se existe valor
      IF TRIM(vr_dstextab) is not null THEN
        /* Se valor do lancamento menor que o da TAB
            entao nao manda email */
        IF gene0002.fn_char_para_number(vr_dstextab) > rw_crapcme.vllanmto THEN
          pr_des_erro := 'OK';
          RETURN;
        END IF;
      END IF;

      -- Buscar informações da agencia
      OPEN cr_crapage (pr_cdcooper => pr_cdcooper,
                       pr_cdagenci => rw_crapcme.cdagenci);
      FETCH cr_crapage INTO rw_crapage;

      IF cr_crapage%NOTFOUND THEN
        -- senão encontrar agencia, dar critica e ir para o final
        vr_cdcritic := 15;
        CLOSE cr_crapage;
        raise vr_exec_sair;
      END IF;
      CLOSE cr_crapage;

      /* Opcao: 1 - Inclusao / 2- Alteracao / 3- Exclusao */
      IF pr_cddopcao < 1 OR pr_cddopcao > 3   THEN
        vr_dscritic := 'Opcao nao valida para esta operacao';
        raise vr_exec_sair;
      END IF;
      -- Validar tipo de operação
      IF rw_crapcme.tpoperac  not in (1,2,3) THEN
        vr_dscritic := 'Tipo de operacao invalida';
        raise vr_exec_sair;
      END IF;

      -- se localizou o associado
      IF vr_crapass  THEN
        /* Data de Re cadastramento */
        OPEN cr_crapalt (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => rw_crapass.nrdconta);
        FETCH cr_crapalt INTO rw_crapalt;
        CLOSE cr_crapalt;
      END IF;

      BEGIN
        -- Definir descrições
        vr_dsdopcao := '('||vr_tab_dsdopcao(pr_cddopcao) ||' de '
                          ||vr_tab_dsoperac(rw_crapcme.tpoperac)||')';
        vr_nmextcop := rw_crapcop.nmrescop ||' - '|| rw_crapcop.nmextcop;
        vr_dsagenci := rw_crapage.cdagenci||' - '||rw_crapage.nmresage||
                       ' ('||rw_crapage.nmcidade||')';

      -- Ignorar qualquer erro de conversão que apresentar
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF pr_flgenvia OR    /* Se gera só um arquivo de controle */
         pr_flgprime THEN  /* Ou se é o primeiro de varios */

        -- Definir nome do arquivo
        vr_nmarquiv := pr_nrdconta||'_'||gene0002.fn_busca_time;
        -- definir local que será gerado os arquivos
        pr_nmarqimp := vr_nom_direto||'/converte/'||vr_nmarquiv||'.txt';
        pr_nmarqpdf := vr_nom_direto||'/converte/'||vr_nmarquiv||'.pdf';
        vr_nmarquiv := vr_nmarquiv ||'.pdf';

        pr_flgprime := FALSE;

        -- Inicializar o CLOB
        pr_des_xml := null;
        dbms_lob.createtemporary(pr_des_xml, true);
        dbms_lob.open(pr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        vr_texto_completo := null;
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');

      ELSE
        -- Inicilizar as informações do XML
        vr_texto_completo := null;

      END IF;

      --se localizou o associado
      IF vr_crapass THEN
        pc_escreve_xml('<detalhe tipo="f_controle">
                          <dsdopcao>'|| vr_dsdopcao ||'</dsdopcao>
                          <dtmvtolt>'|| to_char(pr_dtmvtolt,'DD/MM/RRRR') ||'</dtmvtolt>
                          <nmextcop>'|| vr_nmextcop ||'</nmextcop>
                          <dsagenci>'|| vr_dsagenci ||'</dsagenci>
                          <nrdconta>'|| trim(gene0002.fn_mask_conta(rw_crapass.nrdconta))    ||'</nrdconta>
                          <nrdocmto>'|| trim(gene0002.fn_mask_contrato(rw_crapcme.nrdocmto)) ||'</nrdocmto>
                          <vllanmto>'|| trim(to_char(rw_crapcme.vllanmto,'999G999G990D00'))  ||'</vllanmto>
                       </detalhe>');
      ELSE
        -- se não localizou gerar com o cpf/cnpj da crapcme
        pc_escreve_xml('<detalhe tipo="f_controle_nao_cooperado">
                          <dsdopcao>'|| vr_dsdopcao ||'</dsdopcao>
                          <dtmvtolt>'|| to_char(pr_dtmvtolt,'DD/MM/RRRR') ||'</dtmvtolt>
                          <nmextcop>'|| vr_nmextcop ||'</nmextcop>
                          <dsagenci>'|| vr_dsagenci ||'</dsagenci>
                          <nrcpfcgc>'|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcme.cpfcgrcb,
                                                                  pr_inpessoa => rw_crapcme.inpesrcb)
                                     ||'<nrcpfcgc>
                          <nmpesrcb>'|| rw_crapcme.nmpesrcb ||'</nmpesrcb>
                          <nrdocmto>'|| trim(gene0002.fn_mask_contrato(rw_crapcme.nrdocmto))||'</nrdocmto>
                          <vllanmto>'|| trim(to_char(rw_crapcme.vllanmto,'999G999G990D00')) ||'</vllanmto>
                       </detalhe>');
      END IF;

      /* Saque */
      IF rw_crapcme.tpoperac = 2  THEN
        pc_escreve_xml('<detalhe tipo="f_saque">
                          <vlretesp>'|| trim(to_char(rw_crapcme.vlretesp,'999G999G990D00')) ||'</vlretesp>
                        </detalhe>');
      END IF;

      -- se localizou o associado
      IF vr_crapass  THEN
        pc_escreve_xml('<detalhe tipo="f_coop">
                          <dtadmiss>'|| to_char(rw_crapass.dtadmiss,'DD/MM/RRRR') ||'</dtadmiss>
                          <dtaltera>'|| to_char(rw_crapalt.dtaltera,'DD/MM/RRRR') ||'</dtaltera>
                        </detalhe>');
      END IF;

      -- verificar se  saque(destino) ou deposito(origem)
      IF upper(vr_dsdopcao) like '%SAQUE%' THEN
        pc_escreve_xml('<detalhe tipo="f_dest_orig">
                          <dsdlabel>Destino do dinheiro</dsdlabel>
                          <descrica>'|| rw_crapcme.dstrecur ||'</descrica>
                        </detalhe>');

      ELSE /* Deposito */
        pc_escreve_xml('<detalhe tipo="f_dest_orig">
                          <dsdlabel>Origem do dinheiro</dsdlabel>
                          <descrica>'|| rw_crapcme.recursos ||'</descrica>
                        </detalhe>');
      END IF;

      -- se localizou o associado
      IF vr_crapass THEN
        IF rw_crapass.inpessoa = 1 THEN /* Para todos os titulares */
          OPEN cr_crapttl (pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => RW_crapass.nrdconta);
          FETCH cr_crapttl INTO rw_crapttl;
          CLOSE cr_crapttl;

          /* Verifica se é servidor publico */
          IF gene0002.fn_existe_valor(pr_base     => vr_dsocpttl,
                                      pr_busca    => rw_crapttl.cdocpttl,
                                      pr_delimite => ',') = 'S' THEN
            vr_dsdpubli := 'Sim';
          ELSE
            vr_dsdpubli := 'Nao';
          END IF;
          -- Incluir no xml
          pc_escreve_xml('<detalhe tipo="f_tit_fis_jur">
                            <dsdlabel>Titular(es) da Conta</dsdlabel>
                          </detalhe>
                          <detalhe tipo="f_fis"><titular>
                            <idseqttl>'|| rw_crapttl.idseqttl ||'</idseqttl>
                            <nmextttl>'|| rw_crapttl.nmextttl ||'</nmextttl>
                            <nrcpfcgc>'|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapttl.nrcpfcgc,
                                                                    pr_inpessoa => rw_crapass.inpessoa)
                                       ||'</nrcpfcgc>
                            <inpolexp>'|| rw_crapttl.dsinpolexp ||'</inpolexp>
                            <dsdpubli>'|| vr_dsdpubli           ||'</dsdpubli>
                          </titular></detalhe>');

        ELSE /* Pessoa Juridica */
          OPEN cr_crapjur (pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => RW_crapass.nrdconta);
          FETCH cr_crapjur INTO rw_crapjur;
          --se não localizar, definir critica e ir para o final
          IF cr_crapjur%NOTFOUND THEN
            vr_cdcritic := 821;
            CLOSE cr_crapjur;
            raise vr_exec_sair;
          END IF;
          CLOSE cr_crapjur;

          -- Incluir no xml
          pc_escreve_xml('<detalhe tipo="f_tit_fis_jur">
                            <dsdlabel>Titular da Conta</dsdlabel>
                          </detalhe>
                          <detalhe tipo="f_jur">
                            <nmextttl>'|| rw_crapjur.nmextttl ||'</nmextttl>
                            <nrcpfcgc>'|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                                                    pr_inpessoa => rw_crapass.inpessoa)
                                       ||'</nrcpfcgc>
                          </detalhe>');

        END IF;
      END IF;

      /* Conta que realiza o valor movimentado */
      IF rw_crapcme.nrccdrcb = 0 THEN
        -- Incluir no xml CPF/CNPJ
        pc_escreve_xml('<detalhe tipo="f_rec">
                          <nmpesrcb>  '|| rw_crapcme.nmpesrcb   ||'</nmpesrcb>
                          <dsinpesrcb>'|| rw_crapcme.dsinpesrcb ||'</dsinpesrcb>
                          <nrcpfcgc>  '|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcme.cpfcgrcb,
                                                                    pr_inpessoa => rw_crapcme.inpesrcb)
                                     ||'</nrcpfcgc>
                        </detalhe>');
      ELSE
        -- buscar associado pelo numero da conta
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => rw_crapcme.nrccdrcb,
                         pr_nrcpfcgc => null);
        FETCH cr_crapass INTO rw_crabass;
        -- se não localizar
        IF cr_crapass%NOTFOUND THEN
          vr_cdcritic := 9;
          close cr_crapass;
          raise vr_exec_sair;
        END IF;
        close cr_crapass;

        /* Data de Re cadastramento */
        OPEN cr_crapalt (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => rw_crapcme.nrccdrcb);
        FETCH cr_crapalt INTO rw_crabalt;
        CLOSE cr_crapalt;

        -- Incluir no xml datas
        pc_escreve_xml('<detalhe tipo="f_rea_oper_2">
                          <nrccdrcb> '|| trim(gene0002.fn_mask_conta(rw_crapcme.nrccdrcb)) ||'</nrccdrcb>
                          <dtadmiss> '|| to_char(rw_crabass.dtadmiss,'DD/MM/RRRR') ||'</dtadmiss>
                          <dtaltera> '|| to_char(rw_crabalt.dtaltera,'DD/MM/RRRR') ||'</dtaltera>
                        </detalhe>');

        -- Buscar titular
        pc_escreve_xml('<detalhe tipo="f_fis">');
        FOR rw_crapttl in cr_crapttl (pr_cdcooper => pr_cdcooper,
                                      pr_nrdconta => RW_crapcme.nrccdrcb) LOOP

          /* Verifica se é servidor publico */
          IF gene0002.fn_existe_valor(pr_base     => vr_dsocpttl,
                                      pr_busca    => rw_crapttl.cdocpttl,
                                      pr_delimite => ',') = 'S' THEN
            vr_dsdpubli := 'Sim';
          ELSE
            vr_dsdpubli := 'Nao';
          END IF;
          -- Incluir no xml
          pc_escreve_xml('<titular>
                            <idseqttl>'|| rw_crapttl.idseqttl ||'</idseqttl>
                            <nmextttl>'|| rw_crapttl.nmextttl ||'</nmextttl>
                            <nrcpfcgc>'|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapttl.nrcpfcgc,
                                                                    pr_inpessoa => rw_crabass.inpessoa)
                                       ||'</nrcpfcgc>
                            <inpolexp>'|| rw_crapttl.dsinpolexp ||'</inpolexp>
                            <dsdpubli>'|| vr_dsdpubli           ||'</dsdpubli>
                          </titular>');

        END LOOP;
        pc_escreve_xml('</detalhe>');

      END IF;

      IF pr_flgenvia THEN -- Se gera so um arquivo , envia ...
        -- descarregar o buffer
        pc_escreve_xml('</raiz>',True);

        pc_gera_envia_relatoCME (pr_cdcooper => pr_cdcooper,         --> Codigo da cooperativa
                                 pr_nmdatela => 'PROCES',        --> Nome da tela
                                 pr_dtmvtolt => pr_dtmvtolt,         --> data do movimento
                                 pr_des_xml  => pr_des_xml,          --> Xml do relatorio
                                 pr_nmarqimp => pr_nmarqimp,         --> local/nome do relatorio
                                 pr_nmarqpdf => pr_nmarqpdf,         --> local/nome do relatorio em pdf
                                 pr_flgenvia => pr_flgenvia,         --> indicador se deve enviar por email
                                 pr_dsdemail => rw_crapcop.dsemlcof, --> destino do email
                                 pr_gerrelat => TRUE,                --> Indica se deve gerar o relatorio ou ja esta gerado, somente enviar
                                 pr_flappend => 'N',                 --> indica se deverá concatenar com o relatorio ja existente
                                 pr_dscritic => vr_dscritic);        --> retorna critica encontrada

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(pr_des_xml);
        dbms_lob.freetemporary(pr_des_xml);
        -- se identificou algum erro, levantar exception e ir para o final
        IF vr_dscritic is not null THEN
          raise vr_exec_sair;
        END IF;
      ELSE
        -- Incluir no xml e descarregar o buffer
        pc_escreve_xml('<detalhe tipo="f_pula"> </detalhe>',true);

      END IF;

    EXCEPTION
      -- exception apenas para sair do begin, tratamento será feiro em seguida
      WHEN vr_exec_sair THEN
        null;
      WHEN OTHERS THEN
        -- Erro não tratado
        vr_dscritic := 'Erro na pc_email_controle_movimentacao: '||SQLerrm;
    END;

    -- verificar se existe critica
    IF nvl(vr_cdcritic,0) <> 0    OR
       trim(vr_dscritic) is not null THEN
      GENE0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_nrsequen => 1
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic
                            ,pr_tab_erro => pr_tab_erro);
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => SubStr(pr_cdoperad,1,10)
                            ,pr_dscritic => SubStr(vr_dscritic,1,159)
                            ,pr_dsorigem => SubStr(vr_dsorigem,1,13)
                            ,pr_dstransa => SubStr(vr_dstransa,1,121)
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      -- Setar com erro e retornar ao chamador
      pr_des_erro := 'NOK';
      RETURN;
    END IF;
    -- Gerar log
    IF pr_flgerlog THEN
      --Executar rotina geracao log
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => SubStr(pr_cdoperad,1,10)
                          ,pr_dscritic => null
                          ,pr_dsorigem => SubStr(vr_dsorigem,1,13)
                          ,pr_dstransa => SubStr(vr_dstransa,1,121)
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;
    -- Setar com erro e retornar ao chamador
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN OTHERS THEN

      pr_des_erro := 'NOK';
      -- Erro não tratado
      vr_dscritic := 'Erro na pc_email_controle_movimentacao: '||SQLerrm;
      GENE0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_nrsequen => 1
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic
                            ,pr_tab_erro => pr_tab_erro);

  END pc_email_controle_movimentacao;

  /******************************************************************************
     Gerar e enviar por email o arquivo de varios controles de movimentacao
  ******************************************************************************/
  PROCEDURE pc_gera_arquivo_controle (pr_cdcooper  IN NUMBER,                      -- Codigo da cooperativa
                                      pr_cdagenci  IN NUMBER,                      -- Codigo da agencia
                                      pr_nrdcaixa  IN NUMBER,                      -- Numero do caixa
                                      pr_cdoperad  IN VARCHAR2,                    -- codigo do operador
                                      pr_nmdatela  IN VARCHAR2,                    -- Nome da tela
                                      pr_idorigem  IN INTEGER,                     -- indicador de origem
                                      pr_cddopcao  IN INTEGER,                     -- Codigo da opção
                                      pr_dtmvtolt  IN DATE ,                       -- data do movimento
                                      pr_dtarquiv  IN DATE ,                       -- Data do arquivo
                                      pr_flgerlog  IN BOOLEAN,                     -- indicador se gera log
                                      pr_tab_crapcme typ_tab_crapcme,              -- temp-table com os registros a processar
                                      pr_des_erro OUT VARCHAR2,                    -- retorno se existe erro OK/NOK
                                      pr_tab_erro OUT GENE0001.typ_tab_erro)IS
  /*---------------------------------------------------------------------------------------------------------------
      Programa: pc_gera_arquivo_controle        Antigo: b1wgen9998.p/gera-arquivo-controle
      Sistema : Processos Batch
      Sigla   : CRED
      Autora  : Odirlei Busana(AMcom)
      Data    : Maio/2014.                     Ultima atualizacao: 26/05/2014

      Dados referentes ao programa:

      Frequencia: Sempre que chamada
      Objetivo  : Gerar e enviar por email o arquivo de varios controles de movimentacao

      Alteracoes:
    ---------------------------------------------------------------------------------------------------------------*/
    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.dsemlcof
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

    ------------------------------- VARIAVEIS -------------------------------
    -- variaveis para armazenar as criticas
    vr_cdcritic  NUMBER;
    vr_dscritic  VARCHAR2(2000);
    vr_exec_sair exception;
    -- Controle de impressao
    vr_flgprime  BOOLEAN;
    -- Nome do arquivo
    vr_nmarqimp  VARCHAR2(500);
    vr_nmarqpdf  VARCHAR2(500);
    -- controle de transferencia
    vr_flgtrans  BOOLEAN;
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         clob;
    --------------------------- SUBROTINAS INTERNAS --------------------------


  BEGIN
    BEGIN
      -- Validar cooperativa
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- definir critica e ir para o final
        vr_cdcritic := 794;
        CLOSE cr_crapcop;
        raise vr_exec_sair;
      END IF;
      CLOSE cr_crapcop;

      vr_flgprime := TRUE;

      -- varrer temp-table caso exista algum registro
      IF pr_tab_crapcme.COUNT > 0 THEN
        FOR vr_idx IN pr_tab_crapcme.first..pr_tab_crapcme.last LOOP
          -- gerar relatorio de controle de monimentação de especie
          pc_email_controle_movimentacao (pr_cdcooper  => pr_cdcooper,   -- Codigo da cooperativa
                                          pr_cdagenci  => pr_cdagenci,   -- Codigo da agencia
                                          pr_nrdcaixa  => pr_nrdcaixa,   -- Numero do caixa
                                          pr_cdoperad  => pr_cdoperad,   -- codigo do operador
                                          pr_nmdatela  => pr_nmdatela,   -- Nome da tela
                                          pr_idorigem  => pr_idorigem,   -- indicador de origem
                                          pr_nrdconta  => pr_tab_crapcme(vr_idx).nrdconta,   -- Numero da conta
                                          pr_idseqttl  => 1,             -- Indicador de titular
                                          pr_cddopcao  => pr_cddopcao,   -- Codigo da opção
                                          pr_rowidcme  => pr_tab_crapcme(vr_idx).rowidcme, -- rowid do crapcme
                                          pr_flgenvia  => FALSE,         -- indicador se deve enviar email
                                          pr_dtmvtolt  => pr_dtmvtolt,   -- data do movimento
                                          pr_flgerlog  => pr_flgerlog,   -- indicador se gera log
                                          pr_des_xml   => vr_des_xml,    -- xml do relatorio
                                          pr_flgprime  => vr_flgprime,   -- flag de controle de impressao
                                          pr_nmarqimp  => vr_nmarqimp,   -- Nome do arquivo gerado
                                          pr_nmarqpdf  => vr_nmarqpdf,   -- Nome do pdf do relatorio
                                          pr_des_erro  => pr_des_erro,   -- retorno se existe erro OK/NOK
                                          pr_tab_erro  => pr_tab_erro);

          -- Se retornou erro, ir para o final
          IF pr_des_erro <> 'OK' THEN
            raise vr_exec_sair;
          END IF;
        END LOOP; -- Fim loop pr_tab_crapcme
      END IF;

      /* Sem arquivos Gerados */
      IF trim(vr_nmarqimp) is null  THEN
        vr_flgtrans := TRUE;
        raise vr_exec_sair;
      END IF;

      -- descarregar o buffer
      vr_des_xml := vr_des_xml||'</raiz>';

      -- Solicitar geração do relatorio e envia-lo por email
      pc_gera_envia_relatoCME (pr_cdcooper => pr_cdcooper,         --> Codigo da cooperativa
                               pr_nmdatela => 'PROCES',            --> Nome da tela
                               pr_dtmvtolt => pr_dtmvtolt,         --> data do movimento
                               pr_des_xml  => vr_des_xml,          --> Xml do relatorio
                               pr_nmarqimp => vr_nmarqimp,         --> local/nome do relatorio
                               pr_nmarqpdf => vr_nmarqpdf,         --> local/nome do relatorio em pdf
                               pr_flgenvia => TRUE,                --> indicador se deve enviar por email
                               pr_dsdemail => rw_crapcop.dsemlcof, --> destino do email
                               pr_gerrelat => TRUE,                --> Indica se deve gerar o relatorio ou ja esta gerado, somente enviar
                               pr_flappend => 'N',                 --> indica se deverá concatenar com o relatorio ja existente
                               pr_dscritic => vr_dscritic);        --> retorna critica encontrada

      -- se identificou algum erro, levantar exception e ir para o final
      IF vr_dscritic is not null THEN
        raise vr_exec_sair;
      END IF;

      -- Marcar como transmitido
      vr_flgtrans := TRUE;

    EXCEPTION
      -- exception apenas para sair do begin, tratamento será feiro em seguida
      WHEN vr_exec_sair THEN
        null;
      WHEN OTHERS THEN
        -- Erro não tratado
        vr_dscritic := 'Erro na pc_gera_arquivo_controle: '||SQLerrm;
    END;

    -- Caso não efetuou a transação
    IF NOT vr_flgtrans THEN
      -- caso a tabela de erro esteja vazia
      IF pr_tab_erro.count = 0 THEN
        GENE0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_nrdcaixa => pr_nrdcaixa
                              ,pr_nrsequen => 1
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic
                              ,pr_tab_erro => pr_tab_erro);

        pr_des_erro := 'NOK';
        --retornar nok
        RETURN;
      END IF;
    END IF;
    --retornar ok
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      -- Erro não tratado
      vr_dscritic := 'Erro na pc_gera_arquivo_controle: '||SQLerrm;
      GENE0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_nrsequen => 1
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic
                            ,pr_tab_erro => pr_tab_erro);

  END pc_gera_arquivo_controle;



END CTME0001;
/

