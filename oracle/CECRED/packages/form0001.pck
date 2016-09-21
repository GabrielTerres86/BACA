CREATE OR REPLACE PACKAGE CECRED.FORM0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : FORM0001 (Agregando funções de formulários pré-impressos)
  --  Sistema  : Rotinas genéricas para formulários postmix/engecopy
  --  Sigla    : GENE
  --  Autor    : Marcos E. Martini - Supero
  --  Data     : Novembro/2012.                   Ultima atualizacao: 20/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Definir variaveis e procedimentos para ser utilizada na geracao dos Formularios FormPrint.
  ---------------------------------------------------------------------------------------------------------------

  /* Definir variaveis para ser utilizada na geracao dos Formularios FormPrint. */

  /* Tipo definido para guardar os comando LP a serem executados ao fim do processamento
     através da procedure GENE0001.pc_OScommand_LP  */
  TYPE typ_command_LP IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  /* Tabela de memória que irá guardar os commandos a serem executados.
     É importante limpar o registro antes da primeira execução para garantir
     que apenas as informações do processo estejam registrados na tabela. */
  vr_tbcommand    typ_command_LP;
  vr_tbscript     typ_command_LP;

  /* Type com 5 linhas para montagem de mensagens no rodapé informativo */
  TYPE typ_msg_rodape IS VARRAY(5) OF VARCHAR2(4000);

  /* Tipo genérico de 100 linhas com 80 colunas para armazenar as linhas internas do formulário */
  TYPE tab_dsintern IS
      TABLE OF VARCHAR2(100)
         INDEX BY BINARY_INTEGER;

  /* Tipo que compreende o registro */
  TYPE typ_reg_cratext IS
      RECORD (cdagenci crapage.cdagenci%TYPE
             ,nmagenci crapage.nmresage%TYPE
             ,nmsecext VARCHAR2(25)
             ,nrdconta crapass.nrdconta%TYPE
             ,nmprimtl crapass.nmprimtl%TYPE
             ,nmempres crapemp.nmresemp%TYPE
             ,nrsequen PLS_INTEGER
             ,indespac PLS_INTEGER     /* 1-Correio / 2-Secao */
             ,nrpagina PLS_INTEGER
             ,nrseqint PLS_INTEGER
             ,dsladopg VARCHAR2(1) /* "D" ou "E" */
             ,dsender1 VARCHAR2(60)
             ,dsender2 VARCHAR2(60)
             ,nrcepend crapenc.nrcepend%TYPE
             ,complend crapenc.complend%TYPE
             ,nomedcdd VARCHAR2(35)
             ,nrcepcdd VARCHAR2(23)
             ,dtemissa DATE
             ,nrdordem PLS_INTEGER
             ,tpdocmto PLS_INTEGER
             ,numeroar PLS_INTEGER
             ,dsintern tab_dsintern --> LInhas internas do formulário
             ,dscentra VARCHAR2(45));
  -- Definição de tabela que compreende os registros acima declarados.
  -- Deixamos com uma chave de até 140 caracteres para flexibilizar.
  -- Ordenação cfme necessidade de cada programa, por exemplo:
  --   por Cidade(35) + Cep(8) OU
  --   por Agencia(5) + Conta(10) + Ordem(3) OU
  --   por Tipo de Carta(1) + Conta(10)
  TYPE typ_tab_cratext IS
    TABLE OF typ_reg_cratext
    INDEX BY VARCHAR2(140);

  -- Tipo e vetor para mensagem externa do envelope
  TYPE typ_tab_dsmsgext IS
    TABLE OF VARCHAR2(50)
      INDEX BY BINARY_INTEGER;
  vr_tab_dsmsgext typ_tab_dsmsgext;

  -- Tipo para extrato de telas como a Atenda
  TYPE typ_reg_crawext IS
    RECORD (dtmvtolt DATE
           ,dshistor VARCHAR2(25)
           ,nrdocmto VARCHAR2(11)
           ,indebcre CHAR(1)
           ,vllanmto NUMBER(14,2));
  -- Tipo tabela para o registro acima
  TYPE typ_tab_crawext IS
    TABLE OF typ_reg_crawext
      INDEX BY BINARY_INTEGER;

  -- Imagens para os correios
  vr_impostal VARCHAR2(200) := 'laser/imagens/chancela_ect_cecred.pcx';
  vr_imcorre1 VARCHAR2(200) := 'laser/imagens/reintegracao_correio_grande.pcx';
  vr_imcorre2 VARCHAR2(200) := 'laser/imagens/reintegracao_correio.pcx';
  vr_imgvazio VARCHAR2(200) := 'laser/imagens/vazio.pcx';
  vr_imagemar VARCHAR2(200) := 'laser/imagens/chancela_arcorreio_cecred.pcx';

  -- Gerar os dados dos informativos na tabela crapinf --
  PROCEDURE pc_atualiza_crapinf(pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                               ,pr_cdagenci IN crapage.cdagenci%TYPE
                               ,pr_indespac IN INTEGER
                               ,pr_tpdocmto IN INTEGER
                               ,pr_nrdconta IN crapass.nrdconta%TYPE
                               ,pr_des_erro OUT VARCHAR2);

  /* Inserir/atualizar as informação na GNDCIMP */
  PROCEDURE pc_atualiza_gndcimp(pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                               ,pr_nmarquiv IN VARCHAR2
                               ,pr_numberdc IN OUT NUMBER
                               ,pr_numerseq IN OUT NUMBER
                               ,pr_dscritic OUT VARCHAR2);

  /* Gerar os dados para a frente e verso dos informativos. */
  PROCEDURE pc_gera_dados_inform(pr_cdcooper    IN crapcop.cdcooper%TYPE
                                ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE
                                ,pr_cdacesso    IN craptab.cdacesso%TYPE
                                ,pr_qtmaxarq    IN INTEGER
                                ,pr_nrarquiv    IN OUT INTEGER
                                ,pr_dsdireto    IN VARCHAR2
                                ,pr_nmarqdat    IN VARCHAR2
                                ,pr_tab_cratext IN OUT FORM0001.typ_tab_cratext
                                ,pr_imlogoex    IN VARCHAR2
                                ,pr_imlogoin    IN VARCHAR2
                                ,pr_des_erro    OUT VARCHAR2);

  /* Rotina de envio dos arquivos para Blucopy */
  PROCEDURE pc_envia_dados_blucopy(pr_cdcooper    IN crapcop.cdcooper%TYPE   --> Coop conectada
                                  ,pr_cdprogra    IN crapprg.cdprogra%TYPE   --> Programa que solicitou o envio
                                  ,pr_dslstarq    IN VARCHAR2                --> Lista de arquivos a enviar
                                  ,pr_dsasseml    IN VARCHAR2                --> Assunto do e-mail de envio
                                  ,pr_dscoreml    IN VARCHAR2                --> Corpo com as informações do e-mail
                                  ,pr_des_erro    OUT VARCHAR2);             --> Erro no processo

  /* Rotina de upload dos arquivos para Postmix */
  PROCEDURE pc_envia_dados_postmix(pr_cdcooper    IN crapcop.cdcooper%TYPE
                                  ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE
                                  ,pr_nmarqdat    IN VARCHAR2
                                  ,pr_nmarqenv    IN VARCHAR2
                                  ,pr_inaguard    IN VARCHAR2
                                  ,pr_des_erro    OUT VARCHAR2);

  /* Gerar os dados para a frente e verso dos informativos gerados */
  PROCEDURE pc_gera_dados_inform_1(pr_cdcooper    IN crapcop.cdcooper%TYPE
                                	,pr_cdacesso    IN craptab.cdacesso%TYPE
                                  ,pr_qtmaxarq    IN INTEGER
                                  ,pr_nrarquiv    IN OUT INTEGER
                                  ,pr_dsdireto    IN VARCHAR2
                                  ,pr_nmarqdat    IN VARCHAR2
                                  ,pr_tab_cratext IN OUT FORM0001.typ_tab_cratext
                                  ,pr_imlogoex    IN VARCHAR2
                                  ,pr_imlogoin    IN VARCHAR2
                                  ,pr_impostal    IN VARCHAR2
                                  ,pr_imcorre1    IN VARCHAR2
                                  ,pr_imgvazio    IN VARCHAR2
                                  ,pr_des_erro    OUT VARCHAR2 );

  /* Executar comandos para geracao e impressao de formularios FormPrint */
  PROCEDURE pc_gera_formprint(pr_nmscript  IN VARCHAR2
                             ,pr_dsformsk  IN VARCHAR2
                             ,pr_nmarqdat  IN VARCHAR2
                             ,pr_nmarqimp  IN VARCHAR2
                             ,pr_dsdestin  IN VARCHAR2
                             ,pr_dssubarq  IN VARCHAR2
                             ,pr_dssubrel  IN VARCHAR2
                             ,pr_nmforimp  IN VARCHAR2
                             ,pr_flgexect  IN NUMBER  /* 0 = FALSE e 1 = TRUE */
                             ,pr_des_erro OUT VARCHAR2);

END FORM0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.FORM0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : FORM0001 (Agregando funções de empréstimos e formulários)
  --  Sistema  : Rotinas genéricas para formulários postmix e formprint
  --  Sigla    : GENE
  --  Autor    : Marcos E. Martini - Supero
  --  Data     : Novembro/2012.                   Ultima atualizacao: 20/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Definir variaveis e procedimentos para ser utilizada na geracao dos Formularios FormPrint.

  --   ASSIGN cratext.nmagenci =
  --          cratext.nmsecext =
  --          cratext.nrdconta =
  --          cratext.nmprimtl =
  --          cratext.nmempres =
  --          cratext.nrsequen =
  --          cratext.indespac =
  --          cratext.nrpagina =
  --          cratext.nrseqint =
  --          cratext.dsladopg =
  --          cratext.dsender1 =
  --          cratext.dsender2 =
  --          cratext.nrcepend =
  --          cratext.dtemissa =
  --          cratext.nrdordem =
  --          cratext.tpdocmto =
  --          cratext.dsintern =

  --   Alteracoes: 03/01/2007 - Inclusao das variaveis aux_qtmaxarq e aux_nrarquiv
  --                          (Julio)
  --
  --             22/08/2007 - Inclusao do campo cratext.numeroar (Diego).
  --
  --             07/02/2008 - Inclusao do campo cratext.complend (Diego).
  --
  --             27/03/2008 - Incluida variaveis aux_numerseq, aux_nomedarq,
  --                          aux_numberdc (Gabriel).
  --
  --             06/02/2009 - Incluida variavel aux_nmdatspt (Diego).
  --
  --             19/04/2010 - Incluir nome de faixa de CEP e PAC na tabela
  --                          cratext. Alterar indices (Gabriel).
  --
  --             06/05/2011 - Incluido os campos nrcepcdd e dscentra na
  --                          Temp-Table cratext (Elton).
  --
  --             12/07/2011 - Incluida a variavel aux_nrseqenv para calculo
  --                          de sequencial (crapinf.nrseqenv) NO include
  --                          gera_dados_inform.i (GATI - Eder).
  --
  --             23/11/2012 - Transporte das rotinas e variáveis para o Oracle PLSQL
  --
  --             20/06/2016 - Correcao para o uso da function fn_busca_dstextab 
  --                          da TABE0001 em varias procedures desta package.
  --                          (Carlos Rafael Tanholi).   
  ---------------------------------------------------------------------------------------------------------------
  /* Saída com erro */
  vr_des_erro VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  vr_typ_said VARCHAR2(100);
  -- Guardar registro dstextab
  vr_dstextab craptab.dstextab%TYPE;
  
  -- Gerar os dados dos informativos na tabela crapinf --
  PROCEDURE pc_atualiza_crapinf(pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                               ,pr_cdagenci IN crapage.cdagenci%TYPE
                               ,pr_indespac IN INTEGER
                               ,pr_tpdocmto IN INTEGER
                               ,pr_nrdconta IN crapass.nrdconta%TYPE
                               ,pr_des_erro OUT VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : pc_atualiza_crapinf (includes/gera_dados_crapinf.i)
    --  Sistema : Conta-Corrente - Cooperativa de Credito
    --  Sigla   : CRED
    --  Autor   : GATI - Eder
    --  Data    : Setembro/2011                     Ultima atualizacao: 12/03/2014
    --
    --  Dados referentes ao programa:
    --  Frequencia: Sempre que chamada por outros programas.
    --  Objetivo  : Gerar os dados dos informativos na tabela crapinf.
    --              Chamada na include gera_dados_inform.i.
    --  Alteracoes:
    --              27/11/2012 - Conversão da rotina de Progress > Oracle PLSQL (Marcos-Supero).
    --
    --              27/06/2013 - Inclusão de NVL no nro da conta pois temos casos de não
    --                           haver essa informação e o teste retornar not-found quando
    --                           já existe outro registro sem conta (Marcos-Supero)
    --
    --              12/03/2014 - Alterado cláusula where do cursor cr_crapinf para melhora
    --                           de performance ( Renato - Supero )

  BEGIN
    -- Função convertida com base na includes/gera_dados_crapinf.i
    DECLARE
      -- Busca da ultima sequencia salva
      CURSOR cr_crapinf IS
        SELECT nrseqenv
          FROM crapinf
         WHERE cdcooper        = pr_cdcooper
           AND dtmvtolt        = pr_dtmvtolt
           AND tpdocmto        = pr_tpdocmto
           AND nrdconta        = NVL(pr_nrdconta,0)
        ORDER BY progress_recid DESC;
      vr_nrseqenv crapinf.nrseqenv%TYPE;
      -- Armazenar o fornecedor
      vr_cdfornec crapinf.cdfornec%TYPE;
    BEGIN

      -- Busca da ultima sequencia salva
      OPEN cr_crapinf;
      FETCH cr_crapinf
       INTO vr_nrseqenv;

      -- Se encontrar
      IF cr_crapinf%FOUND THEN
        -- Acumular
        vr_nrseqenv := vr_nrseqenv + 1;
      ELSE
        -- Utilizar sequencia inicial
        vr_nrseqenv := 1;
      END IF;
      -- Fechar cursor
      CLOSE cr_crapinf;
      -- Criar o registro CRAPINF
      BEGIN
        -- Fornecedor de acordo com a cooperativa
        IF pr_cdcooper IN(1,2,4) THEN
          -- Usar fornecedor Engecopy
          vr_cdfornec := 2; /* ENGECOPY */
        ELSE
          -- Usar Postmix
          vr_cdfornec := 1; /* POSTMIX */
        END IF;

        -- Inserir --
        INSERT INTO crapinf(cdagenci
                           ,cdcooper
                           ,dtmvtolt
                           ,indespac
                           ,nrdconta
                           ,nrseqenv
                           ,tpdocmto
                           ,cdfornec)
                     VALUES(pr_cdagenci
                           ,pr_cdcooper
                           ,pr_dtmvtolt
                           ,pr_indespac
                           ,NVL(pr_nrdconta,0)
                           ,vr_nrseqenv
                           ,pr_tpdocmto
                           ,vr_cdfornec);

      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'Erro ao criar registro na tabela crapinf (Coop:'||pr_cdcooper||',Data:'||pr_dtmvtolt||'). Detalhes: '||sqlerrm;
      END;
    END;
  END pc_atualiza_crapinf;

  -- Sub-rotina para aproveitamento de código e inserção/atualização da tabela gndcimp
  PROCEDURE pc_atualiza_gndcimp(pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                               ,pr_nmarquiv IN VARCHAR2
                               ,pr_numberdc IN OUT NUMBER
                               ,pr_numerseq IN OUT NUMBER
                               ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_atualiza_gndcimp (Trecho comum crps217 e crps399)
    --  Sistema : Conta-Corrente - Cooperativa de Credito
    --  Sigla   : CRED
    --  Autor   : Marcos - Supero
    --  Data    : Junho/2013                     Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --  Frequencia: Sempre que chamada por outros programas.
    --  Objetivo  : Atualizar/criar os dados da tabela gndcimp
    --  Alteracoes:
    --

    DECLARE
      -- Buscar se já existe registro na tabela de documentos impressos --
      CURSOR cr_gndcimp IS
        SELECT imp.flgenvio
              ,imp.nrsequen
              ,ROWID
          FROM gndcimp imp
         WHERE imp.cdcooper = pr_cdcooper
           AND imp.dtmvtolt = pr_dtmvtolt
           AND imp.nmarquiv = pr_nmarquiv;
      rw_gndcimp cr_gndcimp%ROWTYPE;
    BEGIN
      -- Buscar se já existe registro na tabela de documentos impressos --
      OPEN cr_gndcimp;
      FETCH cr_gndcimp
       INTO rw_gndcimp;
      -- Se tiver encontrado
      IF cr_gndcimp%FOUND THEN
        -- Fechar o cursor
        CLOSE cr_gndcimp;
        -- Se o documento já foi enviado
        IF rw_gndcimp.flgenvio = 1 THEN
          -- Próximo sequencial
          pr_numerseq := rw_gndcimp.nrsequen + 1;
          -- Criar o registro
          BEGIN
            INSERT INTO gndcimp(cdcooper
                               ,dtmvtolt
                               ,qtdoctos
                               ,nmarquiv
                               ,nrsequen)
                         VALUES(pr_cdcooper
                               ,pr_dtmvtolt
                               ,pr_numberdc
                               ,pr_nmarquiv
                               ,pr_numerseq);
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Erro ao criar registro na tabela gndcimp (Coop:'||pr_cdcooper||',Data:'||pr_dtmvtolt||',Arquivo:'||pr_nmarquiv||'). Detalhes: '||sqlerrm;
              RAISE vr_exc_erro;
          END;
        ELSE
          -- Apenas incrementa a quantidade de documentos
          BEGIN
            UPDATE gndcimp imp
               SET imp.qtdoctos = pr_numberdc
             WHERE imp.ROWID = rw_gndcimp.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Erro ao atualizar registro na tabela gndcimp (Coop:'||pr_cdcooper||',Data:'||pr_dtmvtolt||',Arquivo:'||pr_nmarquiv||'). Detalhes: '||sqlerrm;
              RAISE vr_exc_erro;
          END;
        END IF;
      ELSE
        -- Fechar o cursor
        CLOSE cr_gndcimp;
        -- Criar novo registro
        BEGIN
          INSERT INTO gndcimp(cdcooper
                             ,dtmvtolt
                             ,qtdoctos
                             ,nmarquiv
                             ,nrsequen
                             ,flgenvio)
                       VALUES(pr_cdcooper
                             ,pr_dtmvtolt
                             ,pr_numberdc
                             ,pr_nmarquiv
                             ,1
                             ,0); --> Não enviado
        EXCEPTION
          WHEN OTHERS THEN
            vr_des_erro := 'Erro ao criar registro na tabela gndcimp (Coop:'||pr_cdcooper||',Data:'||pr_dtmvtolt||',Arquivo:'||pr_nmarquiv||'). Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      END IF;
      -- Recomeçar contagem
      pr_numberdc := 0;
    END;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := 'Erro na rotina FORM0001.pc_atualiza_gndcimp. Detalhes: '||vr_des_erro;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro não tratado na rotina FORM0001.pc_atualiza_gndcimp. Detalhes: '||sqlerrm;

  END pc_atualiza_gndcimp;

  /* Gerar os dados para a frente e verso dos informativos. */
  PROCEDURE pc_gera_dados_inform(pr_cdcooper    IN crapcop.cdcooper%TYPE
                                ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE
                                ,pr_cdacesso    IN craptab.cdacesso%TYPE
                                ,pr_qtmaxarq    IN INTEGER
                                ,pr_nrarquiv    IN OUT INTEGER
                                ,pr_dsdireto    IN VARCHAR2
                                ,pr_nmarqdat    IN VARCHAR2
                                ,pr_tab_cratext IN OUT FORM0001.typ_tab_cratext
                                ,pr_imlogoex    IN VARCHAR2
                                ,pr_imlogoin    IN VARCHAR2
                                ,pr_des_erro    OUT VARCHAR2 ) IS

  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_gera_dados_inform (includes/gera_dados_inform.i)
    --  Sistema : Conta-Corrente - Cooperativa de Credito
    --  Sigla   : CRED
    --  Autor   : Gabriel
    --  Data    : Maio/2010.                   Ultima atualizacao: 12/03/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que chamada por outros programas.
    --
    --   Objetivo  : Gerar os dados para a frente e verso dos informativos.
    --               Um formulario por pagina (frente e verso).
    --               Unificacao das includes/gera_dados_inform_1_postmix.i e
    --                              includes/gera_dados_inform_2_postmix.i .
    --
    --   Observações: Quando a tabela pr_tab_cratext conter registro de indespac = 1 (Correios
    --                os mesmos devem estar ordenados por nomedcdd e nrcepend, já com
    --                indespac <> 1 ordenar por cdagenci
    --
    --   Alteracoes: 06/05/2011 - Incluido os campos cratext.nrcepcdd e
    --                            cratext.dscentra na descricao do CDD (Elton).
    --
    --               12/07/2011 - Inclusa gravacao na tabela de informativos do
    --                            associado - crapinf (GATI - Eder).
    --
    --               27/11/2012 - Conversão da rotina de Progress > Oracle PLSQL (Marcos-Supero).
    --
    --               25/03/2013 - Quando dividir arquivo, incluir carta separadora
    --                            no início do novo arquivo (Marcos-Supero).
    --
    --               26/06/2013 - Quando não encontrar mensagem para a carta, limpar o vetor
    --                            vr_tab_dsmsgext (Marcos-Supero)
    --
    --               12/07/2013 - Enviar um caracter de quebra de página ao final dos arquivos
    --                            cfme solicitado pelo pessoal da Engecopy (Marcos-Supero)
    --
    --               12/03/2014 - Implementar gravação via CLOB, para melhora de
    --                            performance ( Renato - Supero )

    DECLARE
      vr_chaveext VARCHAR(140);          --> Chave Hash por Cidade(35) + Cep(8ou23) + Nome(40) OU Agencia(5) + Conta(10) + Ordem(3))
      vr_nrpagina INTEGER;               --> Número de página
      vr_numerseq INTEGER;               --> Sequencial de documentos impressos
      vr_numberdc INTEGER;               --> Número de documentos no registro gndcimp
      vr_dsultlin VARCHAR2(1000);        --> Descrição da ultima linha no quadro de remetente
      vr_nmarquiv VARCHAR2(100);         --> Nome montado do arquivo
      -- Clob para gravar informações
      vr_des_xml     CLOB;

      -- Buscar nome da agência
      CURSOR cr_crapage(pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT age.nmresage
          FROM crapage age
         WHERE age.cdcooper = pr_cdcooper
           AND age.cdagenci = pr_cdagenci;
      vr_nmresage crapage.nmresage%TYPE;

      --Escrever no arquivo CLOB
      PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2) IS

        vr_des_dados VARCHAR2(32000) := pr_des_dados||chr(10);
      BEGIN
        --Escrever no arquivo XML
        dbms_lob.writeappend(vr_des_xml,length(vr_des_dados),vr_des_dados);
      END;

    BEGIN

      -- Somente continuar se existem informações no vetor
      IF pr_tab_cratext.COUNT = 0 THEN
        -- Indica que não será possível gerar nenhum arquivo
        pr_nrarquiv := 0;
      ELSE
        -- Buscar mensagem externa do informativo
        -- Buscar dados de CPMF na tabela de parâmetros
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => pr_cdacesso
                                                 ,pr_tpregist => 1);           
          
        IF TRIM(vr_dstextab) IS NOT NULL THEN        
          -- Montar a mensagem quebrando o conteudo do campo
          vr_tab_dsmsgext(1) := SUBSTR(vr_dstextab,001,50);
          vr_tab_dsmsgext(2) := SUBSTR(vr_dstextab,051,50);
          vr_tab_dsmsgext(3) := SUBSTR(vr_dstextab,101,50);
          vr_tab_dsmsgext(4) := SUBSTR(vr_dstextab,151,50);
          vr_tab_dsmsgext(5) := SUBSTR(vr_dstextab,201,50);
          vr_tab_dsmsgext(6) := SUBSTR(vr_dstextab,251,50);
          vr_tab_dsmsgext(7) := SUBSTR(vr_dstextab,301,50);
        ELSE
          -- Limpar o vetor de mensagem
          vr_tab_dsmsgext(1) := '';
          vr_tab_dsmsgext(2) := '';
          vr_tab_dsmsgext(3) := '';
          vr_tab_dsmsgext(4) := '';
          vr_tab_dsmsgext(5) := '';
          vr_tab_dsmsgext(6) := '';
          vr_tab_dsmsgext(7) := '';
        END IF;

        -- Inicializar contagem de documentos
        vr_numberdc := 0;
        -- Para informativos que geram arquivos muito grandes, dividir em *01.dat
        IF pr_qtmaxarq > 0 THEN
          -- Usar sequenciamento
          vr_nmarquiv := pr_nmarqdat||'01.dat';
        ELSE
          --  Usar o nome enviado
          vr_nmarquiv := pr_nmarqdat;
        END IF;

        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        IF vr_des_erro IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Zerar número da página
        vr_nrpagina := 0;
        -- Guardar o registro inicial do vetor
        vr_chaveext := pr_tab_cratext.FIRST;
        -- Buscar todos os registros da tabela CRATEXT
        -- Cuidando da quebra faixa de Cidade ou Agencia
        LOOP
          -- Sair quando não existir o próximo
          EXIT WHEN vr_chaveext IS NULL;
          -- Incrementar o número de página
          vr_nrpagina := vr_nrpagina + 1;
          -- Atualizar a sequencia interna com o número da página atual
          pr_tab_cratext(vr_chaveext).nrseqint := vr_nrpagina;
          -- Para informativos que geram arquivos muito grande, divir em *01.dat, *02.dat ...
          IF (pr_qtmaxarq > 0) AND MOD(vr_nrpagina,pr_qtmaxarq)=0 THEN
            -- Antes de fechar o arquivo aberto, enviar um caracter de quebra de página
            -- que segundo a Engecopy é necessário para que não haja perda do sequenciamento
            BEGIN
              pc_escreve_clob(chr(12));
            EXCEPTION
              WHEN OTHERS THEN
                -- Ignorar em caso de erro
                NULL;
            END;

            -- Escrever todo o conteúdo do CLOB num arquivo
            gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                         ,pr_caminho  => pr_dsdireto
                                         ,pr_arquivo  => vr_nmarquiv
                                         ,pr_des_erro => vr_des_erro);
            IF vr_des_erro IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_xml);
            dbms_lob.freetemporary(vr_des_xml);

            -- Chamar gravação da tabela de documentos impressos
            pc_atualiza_gndcimp(pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_nmarquiv => vr_nmarquiv
                               ,pr_numberdc => vr_numberdc
                               ,pr_numerseq => vr_numerseq
                               ,pr_dscritic => vr_des_erro);
            -- Se houve erro
            IF vr_des_erro IS NOT NULL THEN
              -- Gerar exceção
              RAISE vr_exc_erro;
            END IF;
            -- Criar novo arquivo
            pr_nrarquiv := pr_nrarquiv + 1;
            -- Abrir o novo arquivo para envio das informações
            -- Adicionar o sequencial
            vr_nmarquiv := pr_nmarqdat || to_char(pr_nrarquiv,'fm00') || '.dat';

            -- Inicializar o CLOB
            dbms_lob.createtemporary(vr_des_xml, TRUE);
            dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

            IF vr_des_erro IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            -- Tratar envio de página separadora quando são criados novos arquivos --
            -- 1 º Somente Para despacho por correios
            IF pr_tab_cratext(vr_chaveext).indespac = 1 THEN
              -- 9999999999 - utilizado na PostMix/Engecopy para separar as cartas
              IF nvl(pr_tab_cratext(vr_chaveext).nomedcdd,' ') = ' ' THEN
                -- Sem cidade descrição padrão
                pc_escreve_clob('9999999999 CDD NAO CADASTRADO');
              ELSE
                -- Com cidade utilizamos todas as informações
                pc_escreve_clob('9999999999 '||RPAD(pr_tab_cratext(vr_chaveext).nomedcdd,35,' ')||' '
                                            ||RPAD(pr_tab_cratext(vr_chaveext).nrcepcdd,23,' ')||' '
                                            ||RPAD(pr_tab_cratext(vr_chaveext).dscentra,60,' '));
              END IF;
            ELSE --> Despacho pelo PAC , SECAO
              -- Buscar descrição da agência
              vr_nmresage := NULL;
              OPEN cr_crapage(pr_cdagenci => pr_tab_cratext(vr_chaveext).cdagenci);
              FETCH cr_crapage
               INTO vr_nmresage;
              CLOSE cr_crapage;
              -- Gerar 9999999999 - utilizado na PostMix/Engecopy para gerar quebra de pagina
              pc_escreve_clob('9999999999 '||vr_nmresage);
            END IF;
            -- Incrementar número de documentos
            vr_numberdc := vr_numberdc + 1;
            -- Chamar rotina de criação da crapinf
            pc_atualiza_crapinf(pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_cdagenci => pr_tab_cratext(vr_chaveext).cdagenci
                               ,pr_indespac => pr_tab_cratext(vr_chaveext).indespac
                               ,pr_tpdocmto => pr_tab_cratext(vr_chaveext).tpdocmto
                               ,pr_nrdconta => 0
                               ,pr_des_erro => vr_des_erro);
            -- Testar saída de erro
            IF vr_des_erro IS NOT NULL THEN
              -- Gerar exceção
              RAISE vr_exc_erro;
            END IF;
          END IF;

          -- Acumular quantidade de documentos
          vr_numberdc := vr_numberdc + 1;
          -- Para despacho por correios
          IF pr_tab_cratext(vr_chaveext).indespac = 1 THEN
            -- Controlar quebra por Cidade, Imprimir Folha com a nova faixa de cidade em caso de mudança
            IF vr_chaveext = pr_tab_cratext.FIRST OR NVL(pr_tab_cratext(vr_chaveext).nomedcdd,' ') <> NVL(pr_tab_cratext(pr_tab_cratext.PRIOR(vr_chaveext)).nomedcdd,' ') THEN
              -- 9999999999 - utilizado na PostMix/Engecopy para separar as cartas
              IF nvl(pr_tab_cratext(vr_chaveext).nomedcdd,' ') = ' ' THEN
                -- Sem cidade descrição padrão
                pc_escreve_clob('9999999999 CDD NAO CADASTRADO');
              ELSE
                -- Com cidade utilizamos todas as informações
                pc_escreve_clob('9999999999 '||RPAD(pr_tab_cratext(vr_chaveext).nomedcdd,35,' ')||' '
                                             ||RPAD(pr_tab_cratext(vr_chaveext).nrcepcdd,23,' ')||' '
                                             ||RPAD(pr_tab_cratext(vr_chaveext).dscentra,60,' '));
              END IF;
              -- Incrementar número de documentos
              vr_numberdc := vr_numberdc + 1;
              -- Chamar rotina de criação da crapinf
              pc_atualiza_crapinf(pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdagenci => pr_tab_cratext(vr_chaveext).cdagenci
                                 ,pr_indespac => pr_tab_cratext(vr_chaveext).indespac
                                 ,pr_tpdocmto => pr_tab_cratext(vr_chaveext).tpdocmto
                                 ,pr_nrdconta => 0
                                 ,pr_des_erro => vr_des_erro);
              -- Testar saída de erro
              IF vr_des_erro IS NOT NULL THEN
                -- Gerar exceção
                RAISE vr_exc_erro;
              END IF;
            END IF;

            -- Montagem da ultima linha de acordo com o tipo do documento
            IF pr_tab_cratext(vr_chaveext).tpdocmto = 5 THEN
              -- Cartas CONVITE (Progrid)
              -- Utiliza-se tambem o numero da conta
              vr_dsultlin := 'ORDEM:'||to_char(pr_tab_cratext(vr_chaveext).nrdordem,'fm000')
                          || '   TIPO:'||to_char(pr_tab_cratext(vr_chaveext).tpdocmto,'fm000')
                          || ' - '||gene0002.fn_mask_conta(pr_tab_cratext(vr_chaveext).nrdconta)
                          || '  SEQUENCIA:'||gene0002.fn_mask(pr_tab_cratext(vr_chaveext).nrseqint,'999.999');
            ELSE
              -- Outros casos
              vr_dsultlin := 'ORDEM:'||to_char(pr_tab_cratext(vr_chaveext).nrdordem,'fm000')
                          || '        TIPO:'||to_char(pr_tab_cratext(vr_chaveext).tpdocmto,'fm000')
                          || '        SEQUENCIA:'||gene0002.fn_mask(pr_tab_cratext(vr_chaveext).nrseqint,'999.999');
            END IF;
            -- Enviar ao arquivo o destinatário
            pc_escreve_clob(pr_tab_cratext(vr_chaveext).nmprimtl);
            pc_escreve_clob(pr_tab_cratext(vr_chaveext).dsender1);
            pc_escreve_clob('COMPLEMENTO:'||pr_tab_cratext(vr_chaveext).complend);
            pc_escreve_clob('BAIRRO:'||pr_tab_cratext(vr_chaveext).dsender2);
            -- Para empréstimo em atraso com AR
            IF pr_tab_cratext(vr_chaveext).tpdocmto = 10 AND nvl(pr_tab_cratext(vr_chaveext).numeroar,0) <> 0 THEN
              -- Montar a linha com o AR
              pc_escreve_clob('CEP:'||gene0002.fn_mask_cep(pr_tab_cratext(vr_chaveext).nrcepend)
                                          ||'   AR:'||gene0002.fn_mask(pr_tab_cratext(vr_chaveext).numeroar,'999999')
                                          ||'       EMISSAO:'||to_char(pr_tab_cratext(vr_chaveext).dtemissa,'dd/mm/yyyy'));
            ELSE
              -- Montar a linha sem o AR
              pc_escreve_clob('CEP:'||gene0002.fn_mask_cep(pr_tab_cratext(vr_chaveext).nrcepend)
                                          ||'        EMISSAO:'||to_char(pr_tab_cratext(vr_chaveext).dtemissa,'dd/mm/yyyy'));
            END IF;
            -- Incluir a ultima linha do cabeçalho
            pc_escreve_clob(vr_dsultlin);
            -- Incluir todo o bloco de mensagens padrão
            pc_escreve_clob(vr_tab_dsmsgext(1));
            pc_escreve_clob(vr_tab_dsmsgext(2));
            pc_escreve_clob(vr_tab_dsmsgext(3));
            pc_escreve_clob(vr_tab_dsmsgext(4));
            pc_escreve_clob(vr_tab_dsmsgext(5));
            pc_escreve_clob(vr_tab_dsmsgext(6));
            pc_escreve_clob(vr_tab_dsmsgext(7));
            -- Incluir imagem do logo externo e logo postal
            pc_escreve_clob(pr_imlogoex);
            pc_escreve_clob(vr_impostal);
            -- Imprimir imagem dos correios conforme tipo documento
            IF pr_tab_cratext(vr_chaveext).tpdocmto = 5 THEN
              -- Cartas CONVITE (Progrid) -- Usar imagem 1 --
              pc_escreve_clob(vr_imcorre1);
            ELSE
              -- Outras usar imagem 2 (Grande)
              pc_escreve_clob(vr_imcorre2);
            END IF;

          ELSE --> Despacho pelo PAC , SECAO

            -- Controlar quebra por agência
            IF vr_chaveext = pr_tab_cratext.FIRST OR pr_tab_cratext(vr_chaveext).cdagenci <> pr_tab_cratext(pr_tab_cratext.PRIOR(vr_chaveext)).cdagenci THEN
              -- Buscar descrição da agência
              vr_nmresage := NULL;
              OPEN cr_crapage(pr_cdagenci => pr_tab_cratext(vr_chaveext).cdagenci);
              FETCH cr_crapage
               INTO vr_nmresage;
              CLOSE cr_crapage;
              -- Gerar 9999999999 - utilizado na PostMix/Engecopy para gerar quebra de pagina
              pc_escreve_clob('9999999999 '||vr_nmresage);
              -- Incrementar número do documento
              vr_numberdc := vr_numberdc + 1;

              -- Chamar rotina de criação da crapinf
              pc_atualiza_crapinf(pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdagenci => pr_tab_cratext(vr_chaveext).cdagenci
                                 ,pr_indespac => pr_tab_cratext(vr_chaveext).indespac
                                 ,pr_tpdocmto => pr_tab_cratext(vr_chaveext).tpdocmto
                                 ,pr_nrdconta => 0
                                 ,pr_des_erro => vr_des_erro);

              -- Testar saída de erro
              IF vr_des_erro IS NOT NULL THEN
                -- Gerar exceção
                RAISE vr_exc_erro;
              END IF;
            END IF;
            -- Gerar ultima linha do remetente
            vr_dsultlin := 'ORDEM:'||to_char(pr_tab_cratext(vr_chaveext).nrdordem,'fm000')
                          || '        TIPO:'||to_char(pr_tab_cratext(vr_chaveext).tpdocmto,'fm000')
                          || '        SEQUENCIA:'||gene0002.fn_mask(pr_tab_cratext(vr_chaveext).nrseqint,'999.999');
            -- Enviar informações da empresa
            pc_escreve_clob(RPAD(SUBSTR(pr_tab_cratext(vr_chaveext).nmempres,1,20),20,' ')||SUBSTR(pr_tab_cratext(vr_chaveext).nmsecext,1,25));
            -- Enviar agência e conta
            pc_escreve_clob(RPAD(SUBSTR(pr_tab_cratext(vr_chaveext).nmagenci,1,24),24,' ')||'CONTA/DV: '||gene0002.fn_mask_conta(pr_tab_cratext(vr_chaveext).nrdconta));
            -- Linha em branco
            pc_escreve_clob(' ');
            -- Enviar ao arquivo o destinatário
            pc_escreve_clob(pr_tab_cratext(vr_chaveext).nmprimtl);
            -- Data de emissão
            pc_escreve_clob('EMISSAO:'||to_char(pr_tab_cratext(vr_chaveext).dtemissa,'dd/mm/yyyy'));
            -- Incluir a ultima linha do cabeçalho
            pc_escreve_clob(vr_dsultlin);
            -- Incluir todo o bloco de mensagens padrão
            pc_escreve_clob(vr_tab_dsmsgext(1));
            pc_escreve_clob(vr_tab_dsmsgext(2));
            pc_escreve_clob(vr_tab_dsmsgext(3));
            pc_escreve_clob(vr_tab_dsmsgext(4));
            pc_escreve_clob(vr_tab_dsmsgext(5));
            pc_escreve_clob(vr_tab_dsmsgext(6));
            pc_escreve_clob(vr_tab_dsmsgext(7));
            -- Incluir imagem do logo externo e logo vazio
            pc_escreve_clob(pr_imlogoex);
            pc_escreve_clob(vr_imgvazio);
            -- Linha em branco
            pc_escreve_clob(' ');
          END IF;

          -- Incluir informações internas (padrão para todos tipos de envio)
          pc_escreve_clob(pr_imlogoin);
          -- Se houverem dados internos
          IF pr_tab_cratext(vr_chaveext).dsintern.COUNT > 0 THEN
            -- Busca das informações internas gravadas no vetor passado
            FOR vr_ind_int IN pr_tab_cratext(vr_chaveext).dsintern.FIRST..pr_tab_cratext(vr_chaveext).dsintern.LAST-1 LOOP
              -- Envia ao arquivo a informação do vetor do registro
              pc_escreve_clob(pr_tab_cratext(vr_chaveext).dsintern(vr_ind_int));
            END LOOP;
          END IF;

          -- Chamar rotina de criação da crapinf
          pc_atualiza_crapinf(pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_cdagenci => pr_tab_cratext(vr_chaveext).cdagenci
                             ,pr_indespac => pr_tab_cratext(vr_chaveext).indespac
                             ,pr_tpdocmto => pr_tab_cratext(vr_chaveext).tpdocmto
                             ,pr_nrdconta => pr_tab_cratext(vr_chaveext).nrdconta
                             ,pr_des_erro => vr_des_erro);

          -- Testar saída de erro
          IF vr_des_erro IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_erro;
          END IF;
          -- Buscar a próxima chave a processar
          vr_chaveext := pr_tab_cratext.NEXT(vr_chaveext);
        END LOOP;

        -- Antes de fechar o arquivo aberto, enviar um caracter de quebra de página
        -- que segundo a Engecopy é necessário para que não haja perda do sequenciamento
        BEGIN
          pc_escreve_clob(chr(12));
        EXCEPTION
          WHEN OTHERS THEN
            -- Ignorar em caso de erro
            NULL;
        END;

        -- Gerar arquivo com o conteúdo do CLOB
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                     ,pr_caminho  => pr_dsdireto
                                     ,pr_arquivo  => vr_nmarquiv
                                     ,pr_des_erro => vr_des_erro);
        IF vr_des_erro IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        IF vr_des_erro IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Liberando a mem¿ria alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
      END IF;

      -- Se criou algum documento
      IF vr_numberdc > 0 THEN
        -- Chamar gravação da tabela de documentos impressos
        pc_atualiza_gndcimp(pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_nmarquiv => vr_nmarquiv
                           ,pr_numberdc => vr_numberdc
                           ,pr_numerseq => vr_numerseq
                           ,pr_dscritic => vr_des_erro);
        -- Se houve erro
        IF vr_des_erro IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN --> Erro tratado
        -- Efetuar rollback
        ROLLBACK;
        -- Concatenar o erro previamente montado e retornar
        pr_des_erro := 'FORM0001.pc_gera_dados_inform --> ' || vr_des_erro;
      WHEN OTHERS THEN -- Gerar log de erro
        -- Efetuar rollback
        ROLLBACK;
        -- Retornar o erro contido na sqlerrm
        pr_des_erro := 'FORM0001.pc_gera_dados_inform --> : '|| sqlerrm;
    END;
  END pc_gera_dados_inform;

  /* Rotina de envio dos arquivos para Blucopy */
  PROCEDURE pc_envia_dados_blucopy(pr_cdcooper    IN crapcop.cdcooper%TYPE   --> Coop conectada
                                  ,pr_cdprogra    IN crapprg.cdprogra%TYPE   --> Programa que solicitou o envio
                                  ,pr_dslstarq    IN VARCHAR2                --> Lista de arquivos a enviar
                                  ,pr_dsasseml    IN VARCHAR2                --> Assunto do e-mail de envio
                                  ,pr_dscoreml    IN VARCHAR2                --> Corpo com as informações do e-mail
                                  ,pr_des_erro    OUT VARCHAR2) IS           --> Erro no processo


  BEGIN
    --    Programa: pc_envia_dados_blucopy (antigo trecho da Fontes/crps217.p)
    --    Sistema : Conta-Corrente - Cooperativa de Credito
    --    Sigla   : CRED
    --    Autor   : Marcos (Supero)
    --    Data    : Nov/2012                         Ultima atualizacao: 12/03/2014
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado pelos programas que utilizam o envio de
    --                informacoes para a Blucopy.
    --
    --    Objetivo  : Chamar rotina de zip do arquivo e envio dos arquivos para Blucopy
    --
    --    Observações: Em necessidade de alterar os e-mails que recebem o extrato, é
    --                 necessário ajustar o parâmetro de sistema EMAIL_EXT_ENGECOPY
    --
    --    Alteracoes: 29/11/2012 - Conversão de Progress >> Oracle PLSQL
    --
    --                26/06/2013 - Generalização da rotina para utilização em diversos
    --                             programas e não somente no pc_crps217 (Marcos-Supero)
    --
    --                12/03/2014 - Incluir chamada da rotina GENE0003.pc_converte_arquivo
    --                             ao invés de apenas copiar os arquivos ( Renato - Supero )

    DECLARE
      -- Var para trabalhar sobre a lista de arquivos
      vr_dslstarq VARCHAR2(4000);
      -- Var para criar uma lista com os contratos passados
      vr_split_arquiv GENE0002.typ_split;
      -- Busca do diretório do path do diretório converte
      vr_dsdrconv VARCHAR2(4000) := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Coop
                                                         ,pr_cdcooper => pr_cdcooper
                                                         ,pr_nmsubdir => 'converte');
      -- Variaveis para armazenar o path e nome do arquivo separadamente
      vr_direto  VARCHAR2(300);
      vr_arquivo VARCHAR2(300);
      -- Var para montar o nome do arquivo sem extensão, pois utilizaremos a compactação Zip
      vr_nmdarqui_semext VARCHAR2(200);
      -- Var final para incluir os arquivos zipados para envio de e-mail
      vr_dslstarq_email VARCHAR2(4000);
    BEGIN
      -- Substituir possiveis "," para ";", e fazer o split somente por ";"
      vr_dslstarq := REPLACE(pr_dslstarq,',',';');
      -- Separar a lista de arquivos
      vr_split_arquiv := gene0002.fn_quebra_string(vr_dslstarq,';');
      -- Se não foi enviado nenhum arquivo
      IF vr_split_arquiv.COUNT = 0 THEN
        -- Gerar erro pois pelo menos um arquivo devia ter sido enviado
        vr_des_erro := 'Nenhum arquivo foi solicitado para envio na pr_dslstarq: '||pr_dslstarq;
        RAISE vr_exc_erro;
      ELSE
        -- Para cada arquivo da lista
        FOR vr_cont IN vr_split_arquiv.FIRST..vr_split_arquiv.LAST LOOP
          -- Separar o path e o nome do arquivo do path completo
          gene0001.pc_separa_arquivo_path(pr_caminho => vr_split_arquiv(vr_cont)
                                         ,pr_direto  => vr_direto
                                         ,pr_arquivo => vr_arquivo);

          -- Realizar a conversão do arquivo
          GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper
                                      ,pr_nmarquiv => vr_split_arquiv(vr_cont)
                                      ,pr_nmarqenv => vr_arquivo
                                      ,pr_des_erro => vr_des_erro);

          IF vr_des_erro IS NOT NULL THEN
            -- O comando shell executou com erro, gerar log e sair do processo
            vr_des_erro := 'Erro ao converter arquivo '||vr_split_arquiv(vr_cont)||': '|| vr_des_erro;
            RAISE vr_exc_erro;
          END IF;

          -- Guardar o nome do arquivo sem a extensão
          vr_nmdarqui_semext := SUBSTR(vr_arquivo,1,INSTR(vr_arquivo,'.')-1);
          -- Chamar rotina de zip da Cecred
          gene0002.pc_zipcecred(pr_cdcooper => pr_cdcooper                                  --> Cooperativa conectada
                               ,pr_tpfuncao => 'A'
                               ,pr_dsorigem => vr_dsdrconv||'/'||vr_arquivo                 --> Lista de arquivos a compactar (separados por espaço)
                               ,pr_dsdestin => vr_dsdrconv||'/'||vr_nmdarqui_semext||'.zip' --> Caminho para o arquivo Zip a gerar
                               ,pr_dspasswd => NULL
                               ,pr_des_erro => vr_des_erro);
          -- Testar erro
          IF pr_des_erro IS NOT NULL THEN
            -- O comando shell executou com erro, gerar log e sair do processo
            RAISE vr_exc_erro;
          END IF;
          -- Adicionar o novo arquivo agora zipado a lista de arquivos para enviar por e-mail
          vr_dslstarq_email := vr_dslstarq_email || vr_dsdrconv||'/'||vr_nmdarqui_semext||'.zip' || ';';
        END LOOP; -- Fim varredura dos arquivos
        -- Chamar o agendamento deste e-mail
        gene0003.pc_solicita_email(pr_cdcooper    => pr_cdcooper
                                  ,pr_cdprogra    => pr_cdprogra
                                  ,pr_des_destino => NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'EMAIL_EXT_ENGECOPY'),'vendas@blucopy.com.br;variaveis@blucopy.com.br')
                                  ,pr_flg_remove_anex => 'N' --> Manter os anexos
                                  ,pr_des_assunto => pr_dsasseml
                                  ,pr_des_corpo   => pr_dscoreml
                                  ,pr_des_anexo   => vr_dslstarq_email
                                  ,pr_des_erro    => vr_des_erro);
        -- Se houver erro
        IF vr_des_erro IS NOT NULL THEN
          -- Levantar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN --> Erro tratado
        -- Efetuar rollback
        ROLLBACK;
        -- Concatenar o erro previamente montado e retornar
        pr_des_erro := 'FORM0001.pc_envia_dados_blucopy --> ' || vr_des_erro;
      WHEN OTHERS THEN -- Gerar log de erro
        -- Efetuar rollback
        ROLLBACK;
        -- Retornar o erro contido na sqlerrm
        pr_des_erro := 'FORM0001.pc_envia_dados_blucopy --> : '|| sqlerrm;
    END;
  END pc_envia_dados_blucopy;

  /* Chamar rotina de upload dos arquivos para Postmix */
  PROCEDURE pc_envia_dados_postmix(pr_cdcooper    IN crapcop.cdcooper%TYPE
                                  ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE
                                  ,pr_nmarqdat    IN VARCHAR2
                                  ,pr_nmarqenv    IN VARCHAR2
                                  ,pr_inaguard    IN VARCHAR2
                                  ,pr_des_erro    OUT VARCHAR2) IS
  BEGIN
    --    Programa: pc_envia_dados_postmix (antigo includes/envia_dados_postmix.i)
    --    Sistema : Conta-Corrente - Cooperativa de Credito
    --    Sigla   : CRED
    --    Autor   : Gabriel
    --    Data    : Abril/2008                         Ultima atualizacao: 26/05/2014
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado pelos programas que utilizam o envio de
    --                informacoes para a PostMix.
    --
    --    Objetivo  : Chamar rotina de upload dos arquivos para Postmix e colocar
    --                o registro do arquivo que foi gravado na gndcimp para enviado.
    --    Observacao: Para executar o UPLOAD e aguardar que o mesmo seja finalizado,
    --                eh necessario chamar esta includes com o argumento AGUARDA
    --                conforme exemplo:
    --                { includes/envia_dados_postmix.i &AGUARDA="SIM" }
    --
    --                Caso o UPLOAD deva ser feito em modo background, a chamada nao
    --                devera conter o argumento conforme exemplo:
    --               { includes/envia_dados_postmix.i }
    --
    --    Observações: Em necessidade de alterar o caminho do script, é
    --                 necessário ajustar o parâmetro de sistema SCRIPT_POSTMIX
    --
    --    Alteracoes: 15/08/2008 - Incluido argumento AGUARDA (Evandro/Gabriel).
    --
    --                15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
    --                             nos parametros do script upload_postmix.sh (Elton).
    --
    --                29/11/2012 - Conversão de Progress >> Oracle PLSQL
    --                
    --                26/05/2014 - Troca do teste de base, para contemplar apenas o parâmetro
    --                             db_name_produc (Marcos-Supero)
    
    DECLARE
      -- Busca do diretório conforme a cooperativa conectada
      CURSOR cr_crapcop IS
        SELECT cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      vr_dsdircop crapcop.dsdircop%TYPE;
      -- Comando a executar
      vr_dsscript VARCHAR2(1000);
    BEGIN
      -- Buscar nome do diretório no cadastro da cooperativa
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO vr_dsdircop;
      CLOSE cr_crapcop;
      -- Montar comando do Shell de envio usando o parâmetro de sistema
      vr_dsscript := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_POSTMIX'),'/usr/local/cecred/bin/upload_postmix.sh');
      -- Adicionar o nome do arquivo e o diretório da cooperativa
      vr_dsscript := vr_dsscript || ' ' ||pr_nmarqenv|| ' ' ||vr_dsdircop;
      -- Se foi solicitado para aguardar
      IF pr_inaguard = 'S' THEN
        -- Adicionar ao script o caracter &
        vr_dsscript := vr_dsscript || ' &';
      END IF;
      -- Somente executar o Script quando conectado em produção
      IF gene0001.fn_database_name = gene0001.fn_param_sistema('CRED',pr_cdcooper,'DB_NAME_PRODUC') THEN
        -- Executa o comando no shell
        gene0001.pc_OScommand_Shell(pr_des_comando => vr_dsscript
                                   ,pr_typ_saida   => vr_typ_said
                                   ,pr_des_saida   => vr_des_erro);
      END IF;
      -- Se houve saida com erro OU out
      IF vr_typ_said IN('ERR') THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        vr_des_erro := 'Erro ao executar o comando de envio do arquivo '||pr_nmarqenv||': ' || vr_des_erro;
        RAISE vr_exc_erro;
      END IF;
      -- Apenas incrementa a quantidade de documentos
      BEGIN
        UPDATE gndcimp imp
           SET imp.flgenvio = 1 -- Enviado
         WHERE imp.cdcooper = pr_cdcooper
           AND imp.dtmvtolt = pr_dtmvtolt
           AND imp.nmarquiv = pr_nmarqdat
           AND imp.flgenvio = 0; -- Não Enviado
      EXCEPTION
        WHEN OTHERS THEN
          vr_des_erro := 'Erro ao atualizar registro na tabela gndcimp (Coop:'||pr_cdcooper||',Data:'||pr_dtmvtolt||',Arquivo:'||pr_nmarqdat||'). Detalhes: '||sqlerrm;
          RAISE vr_exc_erro;
      END;
    EXCEPTION
      WHEN vr_exc_erro THEN --> Erro tratado
        -- Efetuar rollback
        ROLLBACK;
        -- Concatenar o erro previamente montado e retornar
        pr_des_erro := 'FORM0001.pc_envia_dados_postmix --> ' || vr_des_erro;
      WHEN OTHERS THEN -- Gerar log de erro
        -- Efetuar rollback
        ROLLBACK;
        -- Retornar o erro contido na sqlerrm
        pr_des_erro := 'FORM0001.pc_envia_dados_postmix --> : '|| sqlerrm;
    END;
  END pc_envia_dados_postmix;

  -- Gerar os dados para a frente e verso dos informativos gerados
  PROCEDURE pc_gera_dados_inform_1(pr_cdcooper    IN crapcop.cdcooper%TYPE
                                  ,pr_cdacesso    IN craptab.cdacesso%TYPE
                                  ,pr_qtmaxarq    IN INTEGER
                                  ,pr_nrarquiv    IN OUT INTEGER
                                  ,pr_dsdireto    IN VARCHAR2
                                  ,pr_nmarqdat    IN VARCHAR2
                                  ,pr_tab_cratext IN OUT FORM0001.typ_tab_cratext
                                  ,pr_imlogoex    IN VARCHAR2
                                  ,pr_imlogoin    IN VARCHAR2
                                  ,pr_impostal    IN VARCHAR2
                                  ,pr_imcorre1    IN VARCHAR2
                                  ,pr_imgvazio    IN VARCHAR2
                                  ,pr_des_erro    OUT VARCHAR2 ) IS

    /* ...............................................................................................

      Programa: pc_gera_dados_inform       Antigo: includes/gera_dados_inform_1.i
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Julio
      Data    : Outubro/2006                     Ultima atualizacao: 20/10/2013

      Dados referentes ao programa:

      Frequencia:
      Objetivo  : Gerar os dados para a frente e verso dos informativos gerados
                  atraves do FORMPRINT. Um formulario por pagina (frente e verso)

      Alteracoes: 10/04/2007 - Aumentado format do campo cratext.dsintern, e
                               incluido tratamento para divisao de arquivo quando
                               aux_qtmaxarq = 500 (Diego).

                  09/07/2007 - Aumentado format das variaveis que recebem caminhos
                               de imagens (Diego).

                  20/10/2013 -  Conversão da rotina de Progress > Oracle PLSQL (Renato-Supero).

    ............................................................................................... */

    -- REGISTROS

    -- VARIÁVEIS
    vr_ind_arq  utl_file.file_type;      --> Handle para escrita no arquivo
    vr_cratext  FORM0001.typ_reg_cratext;--> Registro
    vr_chaveext VARCHAR(140);            --> Chave Hash
    vr_nrpagina INTEGER;                 --> Número de páginas
    vr_dsultlin VARCHAR2(1000);          --> Descrição da ultima linha no quadro de remetente
    vr_nmarquiv VARCHAR2(100);           --> Nome montado do arquivo
    vr_qtintern NUMBER;                  --> Indice para o vetor interno
    vr_nrsequen NUMBER := 0;             --> Sequencia

  BEGIN

    -- Somente continuar se existem informações no vetor
    IF pr_tab_cratext.COUNT = 0 THEN
      -- Indica que não será possível gerar nenhum arquivo
      pr_nrarquiv := 0;
    ELSE
      -- Buscar mensagem externa do informativo
      -- Buscar dados de CPMF na tabela de parâmetros
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => pr_cdacesso
                                               ,pr_tpregist => 1);         

      -- Se encontrar
      IF TRIM(vr_dstextab) IS NOT NULL THEN
        -- Montar a mensagem quebrando o conteudo do campo
        vr_tab_dsmsgext(1) := SUBSTR(vr_dstextab,001,50);
        vr_tab_dsmsgext(2) := SUBSTR(vr_dstextab,051,50);
        vr_tab_dsmsgext(3) := SUBSTR(vr_dstextab,101,50);
        vr_tab_dsmsgext(4) := SUBSTR(vr_dstextab,151,50);
        vr_tab_dsmsgext(5) := SUBSTR(vr_dstextab,201,50);
        vr_tab_dsmsgext(6) := SUBSTR(vr_dstextab,251,50);
        vr_tab_dsmsgext(7) := SUBSTR(vr_dstextab,301,50);
      ELSE
        -- Limpar o vetor de mensagem
        vr_tab_dsmsgext(1) := '';
        vr_tab_dsmsgext(2) := '';
        vr_tab_dsmsgext(3) := '';
        vr_tab_dsmsgext(4) := '';
        vr_tab_dsmsgext(5) := '';
        vr_tab_dsmsgext(6) := '';
        vr_tab_dsmsgext(7) := '';
      END IF;

      -- Zerar número da página
      vr_nrpagina := 0;

      -- Para informativos que geram arquivos muito grandes, dividir em *01.dat
      IF pr_qtmaxarq > 0 THEN
        -- Usar sequenciamento
        vr_nmarquiv := pr_nmarqdat||'01.dat';
        pr_nrarquiv := 1;
      ELSE
        --  Usar o nome enviado
        vr_nmarquiv := pr_nmarqdat;
      END IF;

      -- Tenta abrir o arquivo para envio das informações
      gene0001.pc_abre_arquivo(pr_nmdireto => pr_dsdireto     --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv     --> Nome do arquivo
                              ,pr_tipabert => 'W'             --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arq      --> Handle do arquivo aberto
                              ,pr_des_erro => vr_des_erro);

      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Guardar o registro inicial do vetor
      vr_chaveext := pr_tab_cratext.FIRST;

      -- Buscar todos os registros da tabela CRATEXT
      LOOP
        -- Incrementar o número de página
        vr_nrpagina := vr_nrpagina + 1;
        vr_nrsequen := vr_nrsequen + 1;
        -- Atualizar a sequencia interna com o número da página atual
        pr_tab_cratext(vr_chaveext).nrsequen := vr_nrsequen;
        pr_tab_cratext(vr_chaveext).nrseqint := vr_nrpagina;

        -- utiliza uma variavel para o registro
        vr_cratext := pr_tab_cratext(vr_chaveext);

        -- Para informativos que geram arquivos muito grande, divir em *01.dat, *02.dat ...
        IF (pr_qtmaxarq > 0) AND MOD(vr_nrpagina,pr_qtmaxarq) = 0 THEN

          -- Tenta fechar o arquivo aberto
          BEGIN
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq);
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Problema ao fechar o arquivo '||vr_nmarquiv||' do diretório: '||pr_dsdireto||'. Erro --> '||sqlerrm;
              RAISE vr_exc_erro;
          END;

          -- Criar novo arquivo
          pr_nrarquiv := pr_nrarquiv + 1;
          -- Abrir o novo arquivo para envio das informações
          -- Adicionar o sequencial
          vr_nmarquiv := pr_nmarqdat || to_char(pr_nrarquiv,'fm00') || '.dat';
          -- Tenta abrir o arquivo para envio das informações
          gene0001.pc_abre_arquivo(pr_nmdireto => pr_dsdireto    --> Diretório do arquivo
                                  ,pr_nmarquiv => vr_nmarquiv      --> Nome do arquivo
                                  ,pr_tipabert => 'W'              --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_ind_arq    --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_des_erro);
          IF vr_des_erro IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

        END IF;

        -- Verifica o tipo do documento
        IF vr_cratext.tpdocmto = 5 THEN
          -- Montar a linha
          vr_dsultlin := 'ORDEM:'
                       ||gene0002.fn_mask(vr_cratext.nrdordem, '999')
                       ||'   TIPO:'
                       ||gene0002.fn_mask(vr_cratext.tpdocmto, '999')
                       ||' - '
                       ||gene0002.fn_mask(vr_cratext.nrdconta, '99999999')
                       ||'  SEQUENCIA:'
                       ||gene0002.fn_mask(vr_cratext.nrsequen,'999.999');
        ELSE
          -- Montar a linha
          vr_dsultlin := 'ORDEM:'
                       ||gene0002.fn_mask(vr_cratext.nrdordem, '999')
                       ||'        TIPO:'
                       ||gene0002.fn_mask(vr_cratext.tpdocmto, '999')
                       ||'        SEQUENCIA:'
                       ||gene0002.fn_mask(vr_cratext.nrsequen,'999.999');
        END IF;

        -- Verificar o tipo de despacho
        IF vr_cratext.indespac = 1 THEN -- Correio
          -- Escrever as linhas no arquivo
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_cratext.nmprimtl ,50, ' ')  );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_cratext.dsender1 ,50, ' ')  );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, 'BAIRRO: '||RPAD( vr_cratext.dsender2 ,50, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, 'CEP: '||vr_cratext.nrcepend||
                                                     '           '||
                                                     'EMISSAO: '||to_char(vr_cratext.dtemissa,'dd/mm/yyyy') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_dsultlin        ,50, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(1) ,50, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(2) ,50, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(3) ,50, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(4) ,50, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(5) ,50, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(6) ,50, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(7) ,50, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( TRIM(pr_imlogoex)  ,80, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( TRIM(pr_impostal)  ,80, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( TRIM(pr_imcorre1)  ,80, ' ') );

        ELSE -- SESSÃO

          -- Escrever as linhas no arquivo
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_cratext.nmempres ,20, ' ')||
                                                     RPAD( vr_cratext.nmsecext ,25, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_cratext.nmagenci ,24, ' ')||
                                                     'CONTA/DV: '||gene0002.fn_mask(vr_cratext.nrdconta,'zzzz.zz9.9')|| chr(13) );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_cratext.nmprimtl ,40, ' ') );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, 'EMISSAO:'||to_char(vr_cratext.dtemissa,'dd/mm/yyyy')|| chr(13) );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_dsultlin        ,60, ' ')  );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(1) ,60, ' ')  );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(2) ,60, ' ')  );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(3) ,60, ' ')  );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(4) ,60, ' ')  );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(5) ,60, ' ')  );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(6) ,60, ' ')  );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_tab_dsmsgext(7) ,60, ' ')  );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( TRIM(pr_imlogoex)  ,80, ' ')  );
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( TRIM(pr_imgvazio)  ,80, ' ')  );
          -- Linha em branco
          gene0001.pc_escr_linha_arquivo(vr_ind_arq, '' );
        END IF;

        -- Imagem
        gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( TRIM(pr_imlogoin)  ,132, ' ') );

        IF vr_cratext.dsintern.COUNT() > 0 THEN
          -- Inicializa
          vr_qtintern := 1;

          -- Percorrer o array interno
          LOOP
            -- Se existe registro
            IF vr_cratext.dsintern.EXISTS(vr_qtintern) THEN
              -- Sai se encontrar o caracter de finalização
              EXIT WHEN vr_cratext.dsintern(vr_qtintern) = '#';

              -- Imprimir a linha no arquivo
              gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( vr_cratext.dsintern(vr_qtintern)  ,100, ' ') );
            ELSE
              -- Linha em branco
              gene0001.pc_escr_linha_arquivo(vr_ind_arq, RPAD( ' ' ,100, ' ') );
            END IF;

            -- Sai quando for o último registro a processar
            EXIT WHEN vr_cratext.dsintern.LAST() = vr_qtintern;
            -- Não utiliza o next, pois deve imprimir linhas em branco
            vr_qtintern := vr_qtintern + 1; -- vr_cratext.dsintern.NEXT(vr_qtintern);
          END LOOP;
        END IF;

        -- Sai quando chegar no ultimo registro
        EXIT WHEN pr_tab_cratext.LAST = vr_chaveext;
        vr_chaveext := pr_tab_cratext.NEXT(vr_chaveext);
      END LOOP; -- FIM pr_tab_cratext

      -- Fechar o arquivo aberto
      BEGIN
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq);
      EXCEPTION
        WHEN OTHERS THEN
          vr_des_erro := 'Problema ao fechar o arquivo '||vr_nmarquiv||' do diretório: '||pr_dsdireto||'. Erro --> '||sqlerrm;
          RAISE vr_exc_erro;
      END;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN --> Erro tratado
      -- Efetuar rollback
      ROLLBACK;
      -- Concatenar o erro previamente montado e retornar
      pr_des_erro := 'FORM0001.pc_gera_dados_inform_1 --> ' || vr_des_erro;
    WHEN OTHERS THEN -- Gerar log de erro
      -- Efetuar rollback
      ROLLBACK;
      -- Retornar o erro contido na sqlerrm
      pr_des_erro := 'FORM0001.pc_gera_dados_inform_1 --> : '|| sqlerrm;
  END pc_gera_dados_inform_1;

  /* Executar comandos para geracao e impressao de formularios FormPrint */
  PROCEDURE pc_gera_formprint(pr_nmscript  IN VARCHAR2
                             ,pr_dsformsk  IN VARCHAR2
                             ,pr_nmarqdat  IN VARCHAR2
                             ,pr_nmarqimp  IN VARCHAR2
                             ,pr_dsdestin  IN VARCHAR2
                             ,pr_dssubarq  IN VARCHAR2
                             ,pr_dssubrel  IN VARCHAR2
                             ,pr_nmforimp  IN VARCHAR2
                             ,pr_flgexect  IN NUMBER  /* 0 = FALSE e 1 = TRUE */
                             ,pr_des_erro OUT VARCHAR2) IS

    /* ..................................................................................

       Programa: pc_gera_formprint        Antigo: fontes/gera_formprint.p
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Julio
       Data    : junho/2007                        Ultima atualizacao: 25/02/2014

       Dados referentes ao programa:

       Frequencia: (Batch).
       Objetivo  : Criar e executar script para geracao e impressao de formularios
                   FormPrint, tudo em background.

       Alteracao : 31/08/2007 - Criacao de arquivo de controle para execucao do
                                script (Julio).

                   13/09/2007 - Chamada para o script ControleLicensa.sh, solucao
                                para o problema de licensas de uso simultaneo do
                                FormPrint (Julio)

                   02/05/2008 - Permissao de gravacao para o arquivos FormPrint.tmp
                                (Julio)

                   20/09/2013 - Conversão Progress >> Oracle PL/SQL (Renato - Supero).

                   22/01/2014 - Implementar a geração do script ".sh", para caso haja a
                                necessidade de execução manual (Renato - Supero)

                   03/01/2014 - Retirado comando fila de impressão (Tiago).

                   03/01/2014 - Replicação da manutenção progress 02/2014 (Odirlei-AMcom).
    .....................................................................................*/

    -- VARIÁVEIS
    vr_ind_arq     utl_file.file_type;      --> Handle para escrita no arquivo

    vr_nrarquiv    INTEGER;
    vr_des_erro    VARCHAR2(4000);
    vr_dsdestin    VARCHAR2(200);

  BEGIN

    -- Define o nome do arquivo
    vr_nrarquiv := TRUNC(dbms_random.value * 100000) + to_number(TO_CHAR(SYSDATE,'SSSSS'));

    -- Diretorio: retira a ultima barra caso seja o ultimo digito
    IF substr(pr_dsdestin,length(pr_dsdestin)) = '/' THEN
      vr_dsdestin := substr(pr_dsdestin,0,length(pr_dsdestin)-1);
    ELSE
      vr_dsdestin := pr_dsdestin;
    END IF;
    -- Diretorio: deixa apenas a pasta
    WHILE ( instr(vr_dsdestin,'/') > 0 ) LOOP
      vr_dsdestin := substr( vr_dsdestin , instr(vr_dsdestin,'/')+1 );
    END LOOP;

    -- Abrir o arquivo para montar o script
    gene0001.pc_abre_arquivo(pr_nmdireto => pr_dsdestin||pr_dssubarq --> Diretório do arquivo
                            ,pr_nmarquiv => pr_nmscript     --> Nome do arquivo
                            ,pr_tipabert => 'A'             --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_ind_arq      --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro);

    -- Verifica se houve algum erro
    IF vr_des_erro IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Defini as permissões para novos arquivos criados
    -- COMANDO
    vr_tbscript(vr_tbscript.count()+1) := 'umask a=rwx';
    -- ARQUIVO
    gene0001.pc_escr_linha_arquivo(vr_ind_arq, 'umask a=rwx');

    -- cria o arquivo FormPrint
    -- COMANDO
    vr_tbscript(vr_tbscript.count()+1) := '> '||pr_dsdestin||'controles/FormPrint_'||to_char(vr_nrarquiv, 'FM000000')||'.Exec';
    -- ARQUIVO
    gene0001.pc_escr_linha_arquivo(vr_ind_arq, '> controles/FormPrint_'||to_char(vr_nrarquiv, 'FM000000')||'.Exec');

    -- Executar formPrint
    /* Deve ser executado desta forma:
         /usr/local/bin/exec_comando_oracle.sh  FormPrint -f /usr/coop/viacredi/laser/crrl351.lfm < /usr/coop/viacredi/arq/crrl351_3008_09.dat  > /usr/coop/viacredi/rl/crrl351_09.lst 2>>/tmp/FormPrint.tmp

       Explicando:
           O script pega todos os parâmetros depois da palavra FormPrint e executa como parâmetro
           para o aplicativo FormPrint no HPUX. As funcionalidades do script
           "/usr/local/bin/ControleLicenca.sh"  eu inclui dentro do exec_comando_oracle.sh,
           então não precisa mais ser executado pelo oracle quando for utilizado o script
           exec_comando_oracle.sh . */
    vr_tbscript(vr_tbscript.count()+1) := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                   ,pr_cdacesso => 'SCRIPT_EXEC_SHELL')||
                                         ' FormPrint -f '||pr_dsdestin||pr_dsformsk||
                                                ' \< '||pr_dsdestin||pr_dssubarq||pr_nmarqdat||' \> '||
                                                pr_dsdestin||'rl/'||pr_nmarqimp;

    -- ARQUIVO - Validador de lincenças do FormPrint
    gene0001.pc_escr_linha_arquivo(vr_ind_arq, '/usr/local/bin/ControleLicenca.sh');
    -- ARQUIVO - Executar formPrint
    gene0001.pc_escr_linha_arquivo(vr_ind_arq, 'FormPrint -f '||pr_dsformsk||
                                                ' < '||pr_dssubarq||pr_nmarqdat||' > '||
                                                'rl/'||pr_nmarqimp||
                                                ' 2>>/tmp/FormPrint.tmp');

    -- Mover arquivo - O Substr elimina o sub-diretório
    -- COMANDO
    vr_tbscript(vr_tbscript.count()+1) := 'mv '||pr_dsdestin||pr_dssubarq||pr_nmarqdat||' '||pr_dsdestin||'salvar/'||pr_nmarqdat;
    -- ARQUIVO
    gene0001.pc_escr_linha_arquivo(vr_ind_arq, 'mv '||pr_dssubarq||pr_nmarqdat||' salvar/'||pr_nmarqdat);

    -- Remove o arquivo
    -- COMANDO
    vr_tbscript(vr_tbscript.count()+1) := 'rm '||pr_dsdestin||'controles/FormPrint_'||to_char(vr_nrarquiv, 'FM000000')||'.Exec';
    -- ARQUIVO
    gene0001.pc_escr_linha_arquivo(vr_ind_arq, 'rm controles/FormPrint_'||to_char(vr_nrarquiv, 'FM000000')||'.Exec');

    -- Fechar o arquivo aberto
    BEGIN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq);
    EXCEPTION
      WHEN OTHERS THEN
        vr_des_erro := 'Problema ao fechar arquivo. Erro --> '||sqlerrm;
        RAISE vr_exc_erro;
    END;

    -- Se o arquivo pode ser executado
    IF pr_flgexect = 1 THEN

      -- Executar as chamadas do FormPrint para gerar os arquivos LST
      FOR ind IN 1..NVL(vr_tbscript.LAST,0) LOOP

        -- Executa o comando Shell
        gene0001.pc_OScommand_Shell(pr_des_comando => vr_tbscript(ind)
                                   ,pr_flg_aguard  => 'N'
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_des_erro);

      END LOOP;

      -- Percorre o registro com os comandos LP e executa os mesmos
      FOR ind IN 1..NVL(vr_tbcommand.LAST,0) LOOP

        -- Executar o comando LP
        GENE0001.pc_OScommand_LP(pr_des_comando => vr_tbcommand(ind)
                                ,pr_flg_aguard  => 'N'
                                ,pr_typ_saida   => vr_typ_said
                                ,pr_des_saida   => vr_des_erro);

        -- Testar erro
        IF vr_typ_said = 'ERR' THEN
          -- Adicionar o erro na variavel de erros
          pr_des_erro := 'Erro ao executar LP --> '||vr_des_erro;
          RAISE vr_exc_erro;
        END IF;

        -- Apaga o comando executado
        vr_tbcommand.DELETE(ind);

      END LOOP;

    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN --> Erro tratado
      -- Concatenar o erro previamente montado e retornar
      pr_des_erro := 'FORM0001.pc_gera_formprint --> ' || vr_des_erro;
    WHEN OTHERS THEN -- Gerar log de erro
      -- Retornar o erro contido na sqlerrm
      pr_des_erro := 'FORM0001.pc_gera_formprint --> ' || sqlerrm;
  END pc_gera_formprint;

END FORM0001;
/
