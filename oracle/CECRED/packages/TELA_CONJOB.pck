CREATE OR REPLACE PACKAGE CECRED.TELA_CONJOB AS

   /*
   Programa: TELA_CONJOB
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Andreatta - MOUTs
   Data    : Junho/2018                       Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: On-line
   Objetivo  : Manter as rotinas para a tela CONJOB

   Alteracoes:

   */


   /* Procedimento para retornar os parâmetros gravados em Sistema */
   PROCEDURE pc_busca_parametros(pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Procedimento para retornar os parâmetros gravados em Sistema */
  PROCEDURE pc_gravacao_parametros(pr_nmjobmaster   in varchar2 -- Nome do JOB Master
                                  ,pr_numminjob     in varchar2 -- Numero de JOBs por Minuto
                                  ,pr_flmailhab     in varchar2 -- Envio por email habilitado
                                  ,pr_flarqhab      in varchar2 -- Log em Arquivo habilitado
                                  ,pr_qtjobporhor0  in varchar2 -- Quantidade de Jobs das 00 as 01
                                  ,pr_qtjobporhor1  in varchar2 -- Quantidade de Jobs das 01 as 02
                                  ,pr_qtjobporhor2  in varchar2 -- Quantidade de Jobs das 02 as 03
                                  ,pr_qtjobporhor3  in varchar2 -- Quantidade de Jobs das 03 as 04
                                  ,pr_qtjobporhor4  in varchar2 -- Quantidade de Jobs das 04 as 05
                                  ,pr_qtjobporhor5  in varchar2 -- Quantidade de Jobs das 05 as 06
                                  ,pr_qtjobporhor6  in varchar2 -- Quantidade de Jobs das 06 as 07
                                  ,pr_qtjobporhor7  in varchar2 -- Quantidade de Jobs das 07 as 08
                                  ,pr_qtjobporhor8  in varchar2 -- Quantidade de Jobs das 08 as 09
                                  ,pr_qtjobporhor9  in varchar2 -- Quantidade de Jobs das 09 as 10
                                  ,pr_qtjobporhor10 in varchar2 -- Quantidade de Jobs das 10 as 11
                                  ,pr_qtjobporhor11 in varchar2 -- Quantidade de Jobs das 11 as 12
                                  ,pr_qtjobporhor12 in varchar2 -- Quantidade de Jobs das 12 as 13
                                  ,pr_qtjobporhor13 in varchar2 -- Quantidade de Jobs das 13 as 14
                                  ,pr_qtjobporhor14 in varchar2 -- Quantidade de Jobs das 14 as 15
                                  ,pr_qtjobporhor15 in varchar2 -- Quantidade de Jobs das 15 as 16
                                  ,pr_qtjobporhor16 in varchar2 -- Quantidade de Jobs das 16 as 17
                                  ,pr_qtjobporhor17 in varchar2 -- Quantidade de Jobs das 17 as 18
                                  ,pr_qtjobporhor18 in varchar2 -- Quantidade de Jobs das 18 as 19
                                  ,pr_qtjobporhor19 in varchar2 -- Quantidade de Jobs das 19 as 20
                                  ,pr_qtjobporhor20 in varchar2 -- Quantidade de Jobs das 20 as 21
                                  ,pr_qtjobporhor21 in varchar2 -- Quantidade de Jobs das 21 as 22
                                  ,pr_qtjobporhor22 in varchar2 -- Quantidade de Jobs das 22 as 23
                                  ,pr_qtjobporhor23 in varchar2 -- Quantidade de Jobs das 23 as 00
                                  ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Tratar o retorno dos valores cadastrados para o JOB enviado para alteração em tela posteriormente */
  PROCEDURE pc_consulta_job(pr_nmjob    IN VARCHAR2           -- Nome do JOB
                           ,pr_tpconsul IN NUMBER             -- Tipo da Consulta (1-Completa.2-Resumida)
                           ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                           ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                           ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Excluir JOB enviado */
  PROCEDURE pc_excluir_job(pr_nmjob    IN VARCHAR2           -- Nome do JOB
                          ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                          ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                          ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Gravar (inserir ou alterar) informações do JOB conforme preenchimento em tela PHP */
  PROCEDURE pc_mantem_job(pr_tpmantem             in varchar2 -- Tipo (Inserir ou Alterar)
                         ,pr_nmjob                in varchar2 -- Nome
                         ,pr_dsdetalhe            in varchar2 -- Descrição detalhada
                         ,pr_dsprefixo_jobs       in varchar2 -- Prefixo Jobs
                         ,pr_idativo              in varchar2 -- Id Ativo Inativo
                         ,pr_idperiodici_execucao in varchar2 -- Periodicidade
                         ,pr_tpintervalo          in varchar2 -- Tipo do Intervalo
                         ,pr_qtintervalo          in varchar2 -- Quantidade de Minutos
                         ,pr_dsdias_habilitados   in varchar2 -- Dias Habilitados
                         ,pr_dtprox_execucao      in varchar2 -- Data da proxima execução
                         ,pr_hrprox_execucao      in varchar2 -- Hora da proxima execução
                         ,pr_hrjanela_exec_ini    in varchar2 -- Janela de execução inicial
                         ,pr_hrjanela_exec_fim    in varchar2 -- Janela de execução final
                         ,pr_flaguarda_processo   in varchar2 -- Aguardar processo central finalizar
                         ,pr_flexecuta_feriado    in varchar2 -- Executa em Feriados
                         ,pr_flsaida_email        in varchar2 -- SAida em Email
                         ,pr_dsdestino_email      in varchar2 -- Email
                         ,pr_flsaida_log          in varchar2 -- SAida em Arquivo
                         ,pr_dsnome_arq_log       in varchar2 -- Arquivo
                         ,pr_dscodigo_plsql       in varchar2 -- Codigo PLSLQ a executar
                         ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                         ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                         ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Retornar todos os eventos de LOG do JOB enviado */
  PROCEDURE pc_consulta_log_jobs(pr_cdcooper  in number            -- Cooperativa
                                ,pr_nmjob     in varchar2          -- Nome JOB
                                ,pr_data_de   in varchar2          -- Data De
                                ,pr_data_ate  in varchar2          -- Data Até
                                ,pr_id_result in varchar2          -- ID Resultado
                                ,pr_nrregist IN INTEGER            -- Quantidade de registros
                                ,pr_nriniseq IN INTEGER            -- Qunatidade inicial
                                ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK
                                
  /* Executar o processo controlador acionado pelo JOB Master */
  PROCEDURE pc_controlador_master;

END TELA_CONJOB;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CONJOB AS
   
   /* Constante do nome do arquivo */
   vr_nmarqlog CONSTANT VARCHAR2(100) := 'conjob';
   
   /* Vetor de Periodicidades */
   TYPE typ_vet_period IS TABLE OF VARCHAR2(20) INDEX BY VARCHAR2(1);
   vr_vet_period typ_vet_period;
   
   /* Vetor de dias da semana */   
   TYPE typ_vet_dias IS TABLE OF VARCHAR2(3) INDEX BY PLS_INTEGER;
   vr_vet_dias typ_vet_dias;
   
   -- Pragma para capturar JOB inexistente
   vr_exc_job_nao_existe EXCEPTION;
   PRAGMA EXCEPTION_INIT( vr_exc_job_nao_existe, -27475 );

   --Variaveis de Criticas
   vr_cdcritic INTEGER;
   vr_dscritic VARCHAR2(4000);
   --Variaveis de Excecoes
   vr_exc_erro  EXCEPTION;
   
   /* Função para buscar texto da periodicidade */
   FUNCTION fn_des_periodic(pr_idperiodici IN VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
     IF vr_vet_period.count = 0 THEN
       vr_vet_period('R') := 'Recorrente';
       vr_vet_period('D') := 'Diaria';
       vr_vet_period('S') := 'Semanal';
       vr_vet_period('Q') := 'Quinzenal';
       vr_vet_period('M') := 'Mensal';
       vr_vet_period('T') := 'Trimestral';
       vr_vet_period('E') := 'Semestral';
       vr_vet_period('A') := 'Anual';
     END IF;
     IF vr_vet_period.exists(pr_idperiodici) THEN
       RETURN vr_vet_period(pr_idperiodici);
     ELSE
       RETURN 'Indefinida';
     END IF;
   END;
   
   /* Função para mostrar textualmente os dias selecionados  */
   FUNCTION fn_dsdias_habilitados(pr_dsdias_habilitados IN VARCHAR2) RETURN VARCHAR2 IS
     vr_dsdias VARCHAR2(100);
   BEGIN
     IF vr_vet_dias.count = 0 THEN
       vr_vet_dias(1) := 'Dom';
       vr_vet_dias(2) := 'Seg';
       vr_vet_dias(3) := 'Ter';
       vr_vet_dias(4) := 'Qua';
       vr_vet_dias(5) := 'Qui';
       vr_vet_dias(6) := 'Sex';
       vr_vet_dias(7) := 'Sab';       
     END IF;
     FOR vr_idx IN 1..7 LOOP
       IF substr(pr_dsdias_habilitados,vr_idx,1) = '1' THEN
         vr_dsdias := vr_dsdias || vr_vet_dias(vr_idx) || ',';
       END IF;
     END LOOP;
     RETURN rtrim(vr_dsdias,',');
   END;
   
   /* Procedimento para retornar os parâmetros gravados em Sistema */
   PROCEDURE pc_busca_parametros(pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_busca_parametros
    Autor    : Andreatta - Mouts
    Data     : Junho/2018                            Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Busca parâmetros do sistema para retornar a tela PHP

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;

    --Separacao de valores por hora para vetor
    vr_txhorarios   gene0002.typ_split;


  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CONJOB'
                              ,pr_action => 'pc_busca_parametros');

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

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Raiz/>');

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Raiz'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'Dados'
      ,pr_tag_cont => NULL
      ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'nmjobmaster'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'NOME_JOB_BATCH_MASTER')
      ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'numminjob'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'NUM_MIN_JOB_BATCH_MASTER')
      ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'flmailhab'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'FL_MAIL_JOB_BATCH_MASTER')
      ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'flarqhab'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',0,'FL_ARQV_JOB_BATCH_MASTER')
      ,pr_des_erro => vr_dscritic);

    -- Converter texto da base em vetor de posições
    vr_txhorarios
           := gene0002.fn_quebra_string
                       (gene0001.fn_param_sistema('CRED',0,'QT_JB_HORA_BATCH_MASTER'), ';');

    -- Para cada posição
    for vr_posicao in 0..23 loop

      GENE0007.pc_insere_tag
            (pr_xml      => pr_retxml
            ,pr_tag_pai  => 'Dados'
            ,pr_posicao  => 0
            ,pr_tag_nova => 'qtjobporhor'||vr_posicao
            ,pr_tag_cont => vr_txhorarios(vr_posicao+1)
            ,pr_des_erro => vr_dscritic);

    End loop;

    -- Retorno OK
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN

      -- Propagar Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_parametros --> '|| SQLERRM;
      pr_des_erro:= 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  END pc_busca_parametros;

  /* Procedimento para retornar os parâmetros gravados em Sistema */
  PROCEDURE pc_gravacao_parametros(pr_nmjobmaster   in varchar2 -- Nome do JOB Master
                                  ,pr_numminjob     in varchar2 -- Numero de JOBs por Minuto
                                  ,pr_flmailhab     in varchar2 -- Envio por email habilitado
                                  ,pr_flarqhab      in varchar2 -- Log em Arquivo habilitado
                                  ,pr_qtjobporhor0  in varchar2 -- Quantidade de Jobs das 00 as 01
                                  ,pr_qtjobporhor1  in varchar2 -- Quantidade de Jobs das 01 as 02
                                  ,pr_qtjobporhor2  in varchar2 -- Quantidade de Jobs das 02 as 03
                                  ,pr_qtjobporhor3  in varchar2 -- Quantidade de Jobs das 03 as 04
                                  ,pr_qtjobporhor4  in varchar2 -- Quantidade de Jobs das 04 as 05
                                  ,pr_qtjobporhor5  in varchar2 -- Quantidade de Jobs das 05 as 06
                                  ,pr_qtjobporhor6  in varchar2 -- Quantidade de Jobs das 06 as 07
                                  ,pr_qtjobporhor7  in varchar2 -- Quantidade de Jobs das 07 as 08
                                  ,pr_qtjobporhor8  in varchar2 -- Quantidade de Jobs das 08 as 09
                                  ,pr_qtjobporhor9  in varchar2 -- Quantidade de Jobs das 09 as 10
                                  ,pr_qtjobporhor10 in varchar2 -- Quantidade de Jobs das 10 as 11
                                  ,pr_qtjobporhor11 in varchar2 -- Quantidade de Jobs das 11 as 12
                                  ,pr_qtjobporhor12 in varchar2 -- Quantidade de Jobs das 12 as 13
                                  ,pr_qtjobporhor13 in varchar2 -- Quantidade de Jobs das 13 as 14
                                  ,pr_qtjobporhor14 in varchar2 -- Quantidade de Jobs das 14 as 15
                                  ,pr_qtjobporhor15 in varchar2 -- Quantidade de Jobs das 15 as 16
                                  ,pr_qtjobporhor16 in varchar2 -- Quantidade de Jobs das 16 as 17
                                  ,pr_qtjobporhor17 in varchar2 -- Quantidade de Jobs das 17 as 18
                                  ,pr_qtjobporhor18 in varchar2 -- Quantidade de Jobs das 18 as 19
                                  ,pr_qtjobporhor19 in varchar2 -- Quantidade de Jobs das 19 as 20
                                  ,pr_qtjobporhor20 in varchar2 -- Quantidade de Jobs das 20 as 21
                                  ,pr_qtjobporhor21 in varchar2 -- Quantidade de Jobs das 21 as 22
                                  ,pr_qtjobporhor22 in varchar2 -- Quantidade de Jobs das 22 as 23
                                  ,pr_qtjobporhor23 in varchar2 -- Quantidade de Jobs das 23 as 00
                                  ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_gravacao_parametros
    Autor    : Andreatta - Mouts
    Data     : Junho/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Gravar parâmetros do sistema conforme preenchimento em tela PHP

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis para validar conversão dos dados enviados
    vr_teste_num NUMBER;

    -- Lista de paralelos por hora
    vr_texto_lista_paralelos varchar2(4000);
    
    -- Variaveis para LOG
    vr_dsvlrprm VARCHAR2(4000);
    vr_qtminprm VARCHAR2(4000);
    vr_dsnomprm VARCHAR2(4000);
    

  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CONJOB'
                              ,pr_action => 'pc_gravacao_parametros');

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

    IF trim(pr_nmjobmaster) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Nome JOB Master deve ser informado!');
      RAISE vr_exc_erro;
    END IF;

    IF trim(pr_numminjob) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Intervalo Execução JOB Master deve ser informado!');
      RAISE vr_exc_erro;
    END IF;

    -- Converter numero em texto para Number
    BEGIN
      vr_teste_num := TO_NUMBER (pr_numminjob);
    EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := 'Intervalo Execução JOB Master inválido ['|| pr_numminjob ||'] Inválida! Informar um número inteiro de 1 até 1440';
      RAISE vr_exc_erro;
    END;

    -- Montaremos uma lista das quantidades de paralelo por hora pois é gravado apenas um campo separado por vírgula:
    vr_texto_lista_paralelos := pr_qtjobporhor0||';'
                             || pr_qtjobporhor1||';'
                             || pr_qtjobporhor2||';'
                             || pr_qtjobporhor3||';'
                             || pr_qtjobporhor4||';'
                             || pr_qtjobporhor5||';'
                             || pr_qtjobporhor6||';'
                             || pr_qtjobporhor7||';'
                             || pr_qtjobporhor8||';'
                             || pr_qtjobporhor9||';'
                             || pr_qtjobporhor10||';'
                             || pr_qtjobporhor11||';'
                             || pr_qtjobporhor12||';'
                             || pr_qtjobporhor13||';'
                             || pr_qtjobporhor14||';'
                             || pr_qtjobporhor15||';'
                             || pr_qtjobporhor16||';'
                             || pr_qtjobporhor17||';'
                             || pr_qtjobporhor18||';'
                             || pr_qtjobporhor19||';'
                             || pr_qtjobporhor20||';'
                             || pr_qtjobporhor21||';'
                             || pr_qtjobporhor22||';'
                             || pr_qtjobporhor23||';';

    -- Atualizaremos a tabela CRAPPRM se não encontrarmos nenhum erro nas validações acima.
    BEGIN

      vr_qtminprm := gene0001.fn_param_sistema('CRED',0,'NUM_MIN_JOB_BATCH_MASTER');
      IF vr_qtminprm <> vr_teste_num THEN 
        UPDATE crapprm
           SET dsvlrprm = vr_teste_num
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'NUM_MIN_JOB_BATCH_MASTER'; 
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o parâmetro "Intervalo Execução JOB Master" de ' || vr_qtminprm
                                                   || ' para ' || vr_teste_num || '.');
      END IF;   
      
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',0,'FL_MAIL_JOB_BATCH_MASTER');
      IF vr_dsvlrprm <> pr_flmailhab THEN 
        UPDATE crapprm
           SET dsvlrprm = pr_flmailhab
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'FL_MAIL_JOB_BATCH_MASTER'; 
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o parâmetro "Tipo de Aviso / Saída Habilitada: Email" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_flmailhab || '.');
      END IF; 
      
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',0,'FL_ARQV_JOB_BATCH_MASTER');
      IF vr_dsvlrprm <> pr_flarqhab THEN 
        UPDATE crapprm
           SET dsvlrprm = pr_flarqhab
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'FL_ARQV_JOB_BATCH_MASTER'; 
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o parâmetro "Tipo de Aviso / Saída Habilitada: LOG" de ' || vr_dsvlrprm
                                                   || ' para ' || pr_flarqhab || '.');
      END IF; 
      
      vr_dsvlrprm := gene0001.fn_param_sistema('CRED',0,'QT_JB_HORA_BATCH_MASTER');
      IF vr_dsvlrprm <> vr_texto_lista_paralelos THEN 
        
        UPDATE crapprm
           SET dsvlrprm = vr_texto_lista_paralelos
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'QT_JB_HORA_BATCH_MASTER'; 
        
        -- Montar texto dos horários alterados
        FOR vr_idx IN 1..24 LOOP
          IF gene0002.fn_busca_entrada(vr_idx,vr_dsvlrprm,';') <> gene0002.fn_busca_entrada(vr_idx,vr_texto_lista_paralelos,';') THEN
            -- Gerar LOG
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => vr_nmarqlog
                                      ,pr_flfinmsg     => 'N'
                                      ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                       || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                       || 'Alterou o parâmetro "Quantidade máxima de paralelos das: '
                                                       || to_char(vr_idx-1,'fm00')||':00 até '|| to_char(vr_idx,'fm00')||':00"'
                                                       || ' de '||gene0002.fn_busca_entrada(vr_idx,vr_dsvlrprm,';')||' para '||gene0002.fn_busca_entrada(vr_idx,vr_texto_lista_paralelos,';')||'.');  
          END IF;
        END LOOP;
      END IF;
      
      vr_dsnomprm := gene0001.fn_param_sistema('CRED',0,'NOME_JOB_BATCH_MASTER');
      IF vr_dsnomprm <> pr_nmjobmaster THEN 
        UPDATE crapprm
           SET dsvlrprm = pr_nmjobmaster
         WHERE nmsistem = 'CRED'
           AND cdcooper = 0
           AND cdacesso = 'NOME_JOB_BATCH_MASTER'; 
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o parâmetro "Nome Job Master" de ' || vr_dsnomprm
                                                   || ' para ' || pr_nmjobmaster || '.');
      END IF;  
      
      -- Se foi alterado nome do JOB Master ou intervalo
      IF vr_dsnomprm <> pr_nmjobmaster THEN
        -- Remover o JOB anterior
        begin
          dbms_scheduler.drop_job(job_name => vr_dsnomprm);
        exception 
          WHEN vr_exc_job_nao_existe then
            null;
        end;
        -- Vamos recriar o mesmo
        sys.dbms_scheduler.create_job(job_name            => pr_nmjobmaster
                                     ,job_type            => 'PLSQL_BLOCK'
                                     ,job_action          => 'BEGIN                                    
                                                  CECRED.tela_conjob.pc_controlador_master;
                                                  END;'
                                     ,start_date          => systimestamp
                                     ,repeat_interval     => 'FREQ=MINUTELY;INTERVAL='||pr_numminjob
                                     ,end_date            => to_date(null)
                                     ,job_class           => 'DEFAULT_JOB_CLASS'
                                     ,enabled             => TRUE
                                     ,auto_drop           => TRUE
                                     ,comments            => 'JOB Master do sistema CONJOB');
      -- Se alterado intervalo em minutos do Master
      ELSIF vr_qtminprm <> pr_numminjob THEN 
        begin
          DBMS_SCHEDULER.SET_ATTRIBUTE(name      => pr_nmjobmaster
                                      ,attribute => 'repeat_interval'
                                      ,value     => 'FREQ=MINUTELY;INTERVAL='||pr_numminjob);
        exception 
          WHEN vr_exc_job_nao_existe then
            -- Vamos recriar o mesmo
            sys.dbms_scheduler.create_job(job_name            => pr_nmjobmaster
                                         ,job_type            => 'PLSQL_BLOCK'
                                         ,job_action          => 'BEGIN                                    
                                                      CECRED.tela_conjob.pc_controlador_master;
                                                      END;'
                                         ,start_date          => systimestamp
                                         ,repeat_interval     => 'FREQ=MINUTELY;INTERVAL='||pr_numminjob
                                         ,end_date            => to_date(null)
                                         ,job_class           => 'DEFAULT_JOB_CLASS'
                                         ,enabled             => TRUE
                                         ,auto_drop           => TRUE
                                         ,comments            => 'JOB Master do sistema CONJOB');
        end;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        RAISE vr_exc_erro;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na gravação dos Parâmetros de Configuração de JOBs: '||sqlerrm;
        RAISE vr_exc_erro;
    END;
    -- Gravar no banco
    COMMIT;
    -- Retorno OK
    pr_des_erro := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Propagar Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK';
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravacao_parametros --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  END pc_gravacao_parametros;

  /* Tratar o retorno dos valores cadastrados para o JOB enviado para alteração em tela posteriormente */
  PROCEDURE pc_consulta_job(pr_nmjob    IN VARCHAR2           -- Nome do JOB
                           ,pr_tpconsul IN NUMBER             -- Tipo da Consulta (1-Completa.2-Resumida)
                           ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                           ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                           ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_consulta_job
    Autor    : Andreatta - Mouts
    Data     : Junho/2018                            Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Tratar o retorno dos valores cadastrados para o JOB enviado para alteração em tela posteriormente

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_auxconta PLS_INTEGER := 0;

    --Busca do JOB enviado
    Cursor cr_job is
      Select *
        From tbgen_batch_jobs
       Where nmjob = decode(pr_nmjob,'',nmjob,pr_nmjob);
    rw_job cr_job%rowtype;

  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CONJOB'
                              ,pr_action => 'pc_consulta_job');

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
    
    IF pr_tpconsul = 1 and pr_nmjob IS NULL THEN
      vr_dscritic := 'JOB inexistente!';
      RAISE vr_exc_erro;
    END IF;

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Raiz/>');

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Raiz'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'Dados'
      ,pr_tag_cont => NULL
      ,pr_des_erro => vr_dscritic);

    IF pr_tpconsul = 2 THEN
      
      FOR rw_job IN cr_job LOOP 
      
        GENE0007.pc_insere_tag
          (pr_xml      => pr_retxml
          ,pr_tag_pai  => 'Dados'
          ,pr_posicao  => 0
          ,pr_tag_nova => 'jobs'
          ,pr_tag_cont => NULL
          ,pr_des_erro => vr_dscritic); 
        
        GENE0007.pc_insere_tag
          (pr_xml      => pr_retxml
          ,pr_tag_pai  => 'jobs'
          ,pr_posicao  => vr_auxconta
          ,pr_tag_nova => 'nmjob'
          ,pr_tag_cont => rw_job.nmjob
          ,pr_des_erro => vr_dscritic);
          
          vr_auxconta := nvl(vr_auxconta,0) + 1;
        
      END LOOP;  
        
    END IF;    

    -- Somente na completa
    IF pr_tpconsul = 1 THEN
      
      -- Buscar o JOB enviado
      OPEN cr_job;
      FETCH cr_job
       INTO rw_job;
      -- Se não encontrou
      IF cr_job%notfound THEN
        CLOSE cr_job;
        -- Sair com erro
        vr_cdcritic := 0;
        vr_dscritic := 'JOB inexistente!';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_job;
      END IF;
      
      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'nmjob'
        ,pr_tag_cont => rw_job.nmjob
        ,pr_des_erro => vr_dscritic);

      -- Enviar o restante das informações
      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'dsdetalhe'
        ,pr_tag_cont => '<![CDATA['||rw_job.dsdetalhe||']]>'
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'dsprefixo_jobs'
        ,pr_tag_cont => rw_job.dsprefixo_jobs
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'idativo'
        ,pr_tag_cont => rw_job.idativo
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'idperiodici_execucao'
        ,pr_tag_cont => rw_job.idperiodici_execucao
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'tpintervalo'
        ,pr_tag_cont => rw_job.tpintervalo
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'qtintervalo'
        ,pr_tag_cont => rw_job.qtintervalo
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'dsdias_habilitados'
        ,pr_tag_cont => rw_job.dsdias_habilitados
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'dtprox_execucao'
        ,pr_tag_cont => to_char(rw_job.dtprox_execucao,'dd/mm/rrrr')
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'hrprox_execucao'
        ,pr_tag_cont => to_char(rw_job.dtprox_execucao,'hh24:mi')
        ,pr_des_erro => vr_dscritic);
        
      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'hrjanela_exec_ini'
        ,pr_tag_cont => rw_job.hrjanela_exec_ini
        ,pr_des_erro => vr_dscritic);
        
      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'hrjanela_exec_fim'
        ,pr_tag_cont => rw_job.hrjanela_exec_fim
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'flaguarda_processo'
        ,pr_tag_cont => rw_job.flaguarda_processo
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'flexecuta_feriado'
        ,pr_tag_cont => rw_job.flexecuta_feriado
        ,pr_des_erro => vr_dscritic);


      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'flsaida_email'
        ,pr_tag_cont => rw_job.flsaida_email
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'dsdestino_email'
        ,pr_tag_cont => '<![CDATA['||rw_job.dsdestino_email||']]>'
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'flsaida_log'
        ,pr_tag_cont => rw_job.flsaida_log
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'dsnome_arq_log'
        ,pr_tag_cont => rw_job.dsnome_arq_log
        ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag
        (pr_xml      => pr_retxml
        ,pr_tag_pai  => 'Dados'
        ,pr_posicao  => 0
        ,pr_tag_nova => 'dscodigo_plsql'
        ,pr_tag_cont => '<![CDATA['||rw_job.dscodigo_plsql||']]>'
        ,pr_des_erro => vr_dscritic);

    END IF;

    -- Retorno OK
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN

      -- Propagar Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_job --> '|| SQLERRM;
      pr_des_erro:= 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  END pc_consulta_job;

  /* Excluir JOB enviado */
  PROCEDURE pc_excluir_job(pr_nmjob    IN VARCHAR2           -- Nome do JOB
                          ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                          ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                          ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_excluir_job
    Autor    : Andreatta - Mouts
    Data     : Junho/2018                            Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Excluir JOB enviado

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Busca do JOB enviado
    Cursor cr_job is
      Select *
        From tbgen_batch_jobs
       Where nmjob = pr_nmjob;
    rw_job cr_job%rowtype;

    -- Busca se o JOB já foi executado alguma vez
    Cursor cr_exec is
      Select *
        From tbgen_prglog
       Where cdprograma = pr_nmjob;
    rw_exec cr_exec%rowtype; 

  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CONJOB'
                              ,pr_action => 'pc_excluir_job');

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

    -- Buscar o JOB enviado
    OPEN cr_job;
    FETCH cr_job
     INTO rw_job;
    -- Se não encontrou
    IF cr_job%notfound THEN
      CLOSE cr_job;
      -- Sair com erro
      vr_cdcritic := 0;
      vr_dscritic := 'JOB inexistente!';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_job;
    END IF;

    -- Buscar se o JOB enviado já não foi executado
    OPEN cr_exec;
    FETCH cr_exec
     INTO rw_exec;
    CLOSE cr_exec;

    -- Se encontrou
    IF rw_exec.cdprograma IS NOT NULL THEN
      -- Sair com erro
      vr_cdcritic := 0;
      vr_dscritic := 'JOB já foi executado pelo menos uma vez, não será possível Excluir! Sugerimos atualizar o cadastro e inativar o mesmo!';
      RAISE vr_exc_erro;
    END IF;

    -- Passadas as validações poderemos excluir o JOB em questão:
    BEGIN
      DELETE tbgen_batch_jobs
       WHERE nmjob = pr_nmjob;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na exclusão do JOB '||pr_nmjob||' --> '||sqlerrm;
        RAISE vr_exc_erro;
    END;
    
    -- Remover o JOB do Banco
    begin
      dbms_scheduler.drop_job(job_name => rw_job.dsprefixo_jobs);
    exception 
      WHEN vr_exc_job_nao_existe then
        null;
    end;
    
    -- Geração de LOG
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => vr_nmarqlog
                              ,pr_flfinmsg     => 'N'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                               || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                               || 'Excluiu o JOB ' || pr_nmjob || '.');
    
    -- Gravar no banco
    COMMIT;

    -- Retorno OK
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN

      -- Propagar Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_excluir_job --> '|| SQLERRM;
      pr_des_erro:= 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  END pc_excluir_job;

  /* Gravar (inserir ou alterar) informações do JOB conforme preenchimento em tela PHP */
  PROCEDURE pc_mantem_job(pr_tpmantem             in varchar2 -- Tipo (Inserir ou Alterar)
                         ,pr_nmjob                in varchar2 -- Nome
                         ,pr_dsdetalhe            in varchar2 -- Descrição detalhada
                         ,pr_dsprefixo_jobs       in varchar2 -- Prefixo Jobs
                         ,pr_idativo              in varchar2 -- Id Ativo Inativo
                         ,pr_idperiodici_execucao in varchar2 -- Periodicidade
                         ,pr_tpintervalo          in varchar2 -- Tipo do Intervalo
                         ,pr_qtintervalo          in varchar2 -- Quantidade de Minutos
                         ,pr_dsdias_habilitados   in varchar2 -- Dias Habilitados
                         ,pr_dtprox_execucao      in varchar2 -- Data da proxima execução
                         ,pr_hrprox_execucao      in varchar2 -- Hora da proxima execução
                         ,pr_hrjanela_exec_ini    in varchar2 -- Janela de execução inicial
                         ,pr_hrjanela_exec_fim    in varchar2 -- Janela de execução final
                         ,pr_flaguarda_processo   in varchar2 -- Aguardar processo central finalizar
                         ,pr_flexecuta_feriado    in varchar2 -- Executa em Feriados
                         ,pr_flsaida_email        in varchar2 -- SAida em Email
                         ,pr_dsdestino_email      in varchar2 -- Email
                         ,pr_flsaida_log          in varchar2 -- SAida em Arquivo
                         ,pr_dsnome_arq_log       in varchar2 -- Arquivo
                         ,pr_dscodigo_plsql       in varchar2 -- Codigo PLSLQ a executar
                         ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                         ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                         ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_mantem_job
    Autor    : Andreatta - Mouts
    Data     : Junho/2018                            Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Gravar (inserir ou alterar) informações do JOB conforme preenchimento em tela PHP

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_idativo NUMBER(1);
    
    -- Variaveis para validar conversão dos dados enviados
    vr_dtprox_execucao DATE;

    --Busca do JOB enviado
    Cursor cr_job is
      Select *
        From tbgen_batch_jobs
       Where nmjob = pr_nmjob;
    rw_job cr_job%rowtype;

    --Busca outro JOB com mesmo prefixo ou nome e ativo
    Cursor cr_outro_job is
      SELECT nmjob
        FROM tbgen_batch_jobs
       WHERE (pr_tpmantem = 'I' OR nmjob <> pr_nmjob)
         AND (nmjob = pr_nmjob OR dsprefixo_jobs = pr_dsprefixo_jobs);
    rw_outro_job cr_outro_job%rowtype; 
    
  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CONJOB'
                              ,pr_action => 'pc_mantem_job');

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

    IF trim(pr_nmjob) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Job deve ser informado!');
      RAISE vr_exc_erro;
    END IF;

    IF trim(pr_dsprefixo_jobs) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Prefixo Jobs no Banco deve ser informado!');
      RAISE vr_exc_erro;
    END IF;

    IF pr_idperiodici_execucao = 'R' THEN
      IF trim(pr_tpintervalo) IS NULL THEN
        vr_dscritic := gene0007.fn_convert_db_web('Tipo do Intervalo deve ser informado!');
        RAISE vr_exc_erro;
      END IF;
      IF trim(pr_qtintervalo) IS NULL THEN
        IF pr_tpintervalo = 'H' THEN
          vr_dscritic := gene0007.fn_convert_db_web('Quantidade de Horas Intervalo deve ser informado!');
        ELSE
          vr_dscritic := gene0007.fn_convert_db_web('Quantidade de Minutos Intervalo deve ser informado!');
        END IF;
        RAISE vr_exc_erro;
      END IF;
    END IF;

    IF trim(pr_dsdias_habilitados) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Dias Habilitados deve ser informado!');
      RAISE vr_exc_erro;
    END IF;

    IF trim(pr_dtprox_execucao) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Data Próxima Execução deve ser informada!');
      RAISE vr_exc_erro;
    END IF;

    IF trim(pr_hrprox_execucao) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Hora Próxima Execução deve ser informada!');
      RAISE vr_exc_erro;
    END IF;

    IF trim(pr_dscodigo_plsql) IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Codigo PLSQL deve ser informado!');
      RAISE vr_exc_erro;
    END IF;

    IF pr_flsaida_email = 'S' THEN
      IF trim(pr_dsdestino_email) IS NULL THEN
        vr_dscritic := gene0007.fn_convert_db_web('Pelo menos um Email deve ser informado!');
        RAISE vr_exc_erro;
      END IF;
    END IF;

    IF pr_flsaida_log = 'S' THEN
      IF trim(pr_dsnome_arq_log) IS NULL THEN
        vr_dscritic := gene0007.fn_convert_db_web('Nome Arquivo LOG deve ser informado!');
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- ID do JOB é obrigatório para Atualização:
    IF pr_tpmantem = 'A' THEN
      -- Buscar o JOB enviado
      OPEN cr_job;
      FETCH cr_job
       INTO rw_job;
      -- Se não encontrou
      IF cr_job%notfound THEN
        CLOSE cr_job;
        -- Sair com erro
        vr_cdcritic := 0;
        vr_dscritic := gene0007.fn_convert_db_web('JOB inexistente!');
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_job;
      END IF;
    END IF;

    -- Efetuaremos validações de domínio para cada campo:
    IF pr_idativo NOT IN ('S','N') THEN
      vr_dscritic := gene0007.fn_convert_db_web('Campo Ativo inválido!');
      RAISE vr_exc_erro;
    END IF;

    IF pr_idperiodici_execucao NOT IN ('R','D','S','Q','M','T','E','A') THEN
      vr_dscritic := gene0007.fn_convert_db_web('Campo Periodicidade Execução inválido!');
      RAISE vr_exc_erro;
    END IF;

    IF NVL(pr_tpintervalo,' ') NOT IN (' ','H','M') THEN
      vr_dscritic := gene0007.fn_convert_db_web('Campo Intervalo inválido!');
      RAISE vr_exc_erro;
    END IF;

    IF pr_tpintervalo = 'H' AND pr_qtintervalo NOT BETWEEN 1 AND 23 THEN
      vr_dscritic := gene0007.fn_convert_db_web('Campo Intervalo inválido! Informe quantidade de horas entre 01 e 23');
      RAISE vr_exc_erro;
    ELSIF pr_tpintervalo = 'M' AND pr_qtintervalo NOT BETWEEN 1 AND 59 THEN
      vr_dscritic := gene0007.fn_convert_db_web('Campo Intervalo inválido! Informe quantidade de minutos entre 01 e 59');
      RAISE vr_exc_erro;
    END IF;

    IF pr_dsdias_habilitados = '0000000' OR length(pr_dsdias_habilitados) < 7 THEN
      vr_dscritic := gene0007.fn_convert_db_web('Campo Dias Habilitados inválido! Selecione pelo menos um dia para Execução');
      RAISE vr_exc_erro;
    END IF;

    IF pr_flexecuta_feriado NOT IN (0,1) THEN
      vr_dscritic := gene0007.fn_convert_db_web('Campo Executar em Feriados inválido!');
      RAISE vr_exc_erro;
    END IF;

    IF pr_flsaida_email = 'S' AND pr_dsdestino_email IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Campo Destino inválido! Informe destino de Emails para a Saída por Emails');
      RAISE vr_exc_erro;
    ELSIF pr_flsaida_log = 'S' AND pr_dsnome_arq_log IS NULL THEN
      vr_dscritic := gene0007.fn_convert_db_web('Campo Nome Arq inválido! Informe Nome do Arquivo para a Saída por LOG');
      RAISE vr_exc_erro;
    END IF;

    -- Caso job ativo
    IF pr_idativo = 'S' THEN
      -- Não pode haver outro JOB ativo com mesmo nome ou prefixo JOB
      OPEN cr_outro_job;
      FETCH cr_outro_job
       INTO rw_outro_job;
      IF cr_outro_job%found THEN
        CLOSE cr_outro_job;
        vr_dscritic := gene0007.fn_convert_db_web('Prefixo ou Nome já utilizados no JOB id ')||rw_outro_job.nmjob;
        RAISE vr_Exc_erro;
      ELSE
        CLOSE cr_outro_job;
      END IF;
    END IF;

    -- Converter data em texto para data
    BEGIN
      vr_dtprox_execucao := to_date(pr_dtprox_execucao||pr_hrprox_execucao,'dd/mm/rrrrhh24:mi');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := gene0007.fn_convert_db_web('Data e Hora da Próxima Execução Inválidas!');
        RAISE vr_exc_erro;
    END;

    -- Data deve estar no futuro
    IF vr_dtprox_execucao < sysdate THEN
      vr_dscritic := gene0007.fn_convert_db_web('Data e Hora da Próxima Execução Inválidas! Favor informar data futura!');
      RAISE vr_exc_erro;
    END IF;
      
    -- Se execução não for Recorrente e foi enviada uma janela de execução
    IF pr_idperiodici_execucao <> 'R' AND (pr_hrjanela_exec_ini is not null or pr_hrjanela_exec_fim is not null) THEN
      vr_dscritic := gene0007.fn_convert_db_web('Janela de Execução é permitida apenas para Periodicidade Recorrente!');
      RAISE vr_exc_erro;
    END IF;
    
    -- Se enviado Janea de execução
    IF pr_hrjanela_exec_ini is not null or pr_hrjanela_exec_fim is not null THEN
      -- Ambos devem ser informados
      IF pr_hrjanela_exec_ini is null THEN
        vr_dscritic := gene0007.fn_convert_db_web('Ao informar janela de execução final, o horário final é obrigatório!');
        RAISE vr_exc_erro; 
      ELSIF pr_hrjanela_exec_fim is null THEN
        vr_dscritic := gene0007.fn_convert_db_web('Ao informar janela de execução inicial, o horário final é obrigatório!');
        RAISE vr_exc_erro;      
      END IF;
      -- Inicio deve ser inferior ao final
      IF pr_hrjanela_exec_fim <= pr_hrjanela_exec_ini THEN
        vr_dscritic := gene0007.fn_convert_db_web('Janela de execução inválida! Favor informar horário inicial inferior ao horário final!');
        RAISE vr_exc_erro;  
      END IF;
    END IF;
    
    -- Se não executar em feriados e foi selecionado um feriado
    IF pr_flexecuta_feriado = 0 AND gene0005.fn_valida_dia_util(pr_cdcooper  => 3
                                                               ,pr_dtmvtolt  => vr_dtprox_execucao
                                                               ,pr_tipo      => 'P') <> trunc(vr_dtprox_execucao) THEN
      vr_dscritic := gene0007.fn_convert_db_web('Data e Hora da Próxima Execução Inválidas! Favor informar data útil ou selecione para executar em feriados');
      RAISE vr_exc_erro;
    END IF;
    
    -- Checar se a data da proxima execução está dentro de um dos dias selecionados
    -- na lista de dias em que o JOB pode executar
    IF substr(pr_dsdias_habilitados,to_char(vr_dtprox_execucao,'d'),1) <> '1' THEN
      vr_dscritic := gene0007.fn_convert_db_web('Data da Próxima Execução Inválida! Você não selecionou uma data '
                  || 'de acordo com os dias habilitados['||fn_dsdias_habilitados(pr_dsdias_habilitados)||']');
      RAISE vr_exc_erro;      
    END IF;
    
    -- Validar se o prefixo de jobs pode ser usados
    declare
      vr_nmjob varchar2(100);
    begin
      -- Gerar nome para o JOB no banco
      vr_nmjob := dbms_scheduler.generate_job_name(pr_dsprefixo_jobs);
    exception
      when others then
        vr_dscritic := gene0007.fn_convert_db_web('Prefixo Jobs Inválido! Favor informar um prefixo que não termine em Número, sem caracteres especiais e com até 18 caracteres!');
        RAISE vr_exc_erro;
    end;
    
    -- Validaremos se o código PLSQL informado é um código válido:
    declare
      wIdCursor Integer;
      vDsPlsql VARCHAR2(4000);
    BEGIN
      -- Mensageria troca >= e <= por tags
      vDsPlsql := REPLACE(REPLACE(REPLACE(pr_dscodigo_plsql,'&lt;','<'),'&gt;','>'),'&apos;','''');
      -- Tenta executar dinamicamente o bloco montado
      wIdCursor:= dbms_sql.open_cursor;
      dbms_sql.parse(wIdCursor,vDsPlsql,1);
      if dbms_sql.is_open(wIdCursor) then
        dbms_sql.close_cursor(wIdCursor);
      end if;
    exception
      when others then
        vr_dscritic := gene0007.fn_convert_db_web('Código PLSQL Inválido, favor corrigir : ')||substr(SQLERRM,1,instr(SQLERRM,':',1,2));
        RAISE vr_exc_erro;
    end;
    
    -- Após todas as validações, gravar na tabela conforme o tipo da chamada:
    IF pr_tpmantem = 'A' THEN
      BEGIN

        UPDATE tbgen_batch_jobs
           SET dsdetalhe = gene0007.fn_convert_web_db(pr_dsdetalhe)
              ,dsprefixo_jobs = pr_dsprefixo_jobs
              ,idativo = decode(pr_idativo,'S',1,0)
              ,idperiodici_execucao = pr_idperiodici_execucao
              ,tpintervalo = pr_tpintervalo
              ,qtintervalo = pr_qtintervalo
              ,dsdias_habilitados = pr_dsdias_habilitados
              ,dtprox_execucao = vr_dtprox_execucao
              ,hrjanela_exec_ini = pr_hrjanela_exec_ini 
              ,hrjanela_exec_fim = pr_hrjanela_exec_fim 
              ,flaguarda_processo = pr_flaguarda_processo 
              ,flexecuta_feriado = pr_flexecuta_feriado
              ,flsaida_email = pr_flsaida_email
              ,dsdestino_email = pr_dsdestino_email
              ,flsaida_log = pr_flsaida_log
              ,dsnome_arq_log = pr_dsnome_arq_log
              ,dscodigo_plsql = REPLACE(REPLACE(REPLACE(pr_dscodigo_plsql,'&lt;','<'),'&gt;','>'),'&apos;','''')
              ,cdoperad_alteracao = vr_cdoperad
              ,dtalteracao = sysdate
         WHERE nmjob = pr_nmjob;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := gene0007.fn_convert_db_web('Erro na atualiação das informações do JOB: ')||sqlerrm;
          RAISE vr_exc_erro;
      END;
      
      IF pr_dsprefixo_jobs <> rw_job.dsprefixo_jobs THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Prefixo JOBs" de ' || rw_job.dsprefixo_jobs
                                                   || ' para ' || pr_dsprefixo_jobs || '.');
      END IF;
      
      IF pr_idativo = 'S' THEN
        vr_idativo := 1;
      ELSE
        vr_idativo := 0;    
      END IF;
      
      -- Geração de LOG somente quando alterado
      IF vr_idativo <> rw_job.idativo THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Ativo" de ' || rw_job.idativo
                                                   || ' para ' || pr_idativo || '.');        
      END IF;
      
      IF gene0007.fn_convert_web_db(pr_dsdetalhe) <> rw_job.dsdetalhe THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Descrição Detalhada" de ' || rw_job.dsdetalhe
                                                   || ' para ' || pr_dsdetalhe || '.');
      END IF;
      
      IF pr_idperiodici_execucao <> rw_job.idperiodici_execucao THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Periodicidade Execução" de ' || fn_des_periodic(rw_job.idperiodici_execucao)
                                                   || ' para ' || fn_des_periodic(pr_idperiodici_execucao) || '.');
      END IF;
      
      IF pr_tpintervalo <> rw_job.tpintervalo THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Intervalo (Tipo)" de ' || rw_job.tpintervalo
                                                   || ' para ' || pr_tpintervalo || '.');
      END IF;
      
      IF pr_qtintervalo <> rw_job.qtintervalo THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Intervalo (Tempo)" de ' || rw_job.qtintervalo
                                                   || ' para ' || pr_qtintervalo || '.');
      END IF;
      
      IF pr_dsdias_habilitados <> rw_job.dsdias_habilitados THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Dias Habilitados" de ' || fn_dsdias_habilitados(rw_job.dsdias_habilitados)
                                                   || ' para ' || fn_dsdias_habilitados(pr_dsdias_habilitados) || '.');
      END IF;
      
      IF vr_dtprox_execucao <> rw_job.dtprox_execucao THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Próxima Execução" de ' || to_char(rw_job.dtprox_execucao,'DD/MM/RRRR hh24:mi')
                                                   || ' para ' || to_char(vr_dtprox_execucao,'DD/MM/RRRR hh24:mi') || '.');
      END IF;
      
      IF pr_hrjanela_exec_ini <> rw_job.hrjanela_exec_ini THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Janela de Execução Inicial" de ' || rw_job.hrjanela_exec_ini
                                                   || ' para ' || pr_hrjanela_exec_ini || '.');
      END IF;
      
      IF pr_hrjanela_exec_fim <> rw_job.hrjanela_exec_fim THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Janela de Execução Final" de ' || rw_job.hrjanela_exec_fim
                                                   || ' para ' || pr_hrjanela_exec_fim || '.');
      END IF;
      
      IF pr_flaguarda_processo <> rw_job.flaguarda_processo THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Aguardar Processo Finalizar?" de ' || rw_job.flaguarda_processo
                                                   || ' para ' || pr_flaguarda_processo || '.');
      END IF;
      
      IF pr_flexecuta_feriado <> rw_job.flexecuta_feriado THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Executa em Feriados?" de ' || rw_job.flexecuta_feriado
                                                   || ' para ' || pr_flexecuta_feriado || '.');
      END IF;
      
      IF pr_flsaida_email <> rw_job.flsaida_email THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Tipo de Aviso/Saida Habilitada (Email)" de ' || rw_job.flsaida_email
                                                   || ' para ' || pr_flsaida_email || '.');
      END IF;
      
      IF pr_dsdestino_email <> rw_job.dsdestino_email THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Email" de ' || rw_job.dsdestino_email
                                                   || ' para ' || pr_dsdestino_email || '.');
      END IF;
      
      IF pr_flsaida_log <> rw_job.flsaida_log THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Tipo de Aviso/Saida Habilitada (LOG)" de ' || rw_job.flsaida_log
                                                   || ' para ' || pr_flsaida_log || '.');
      END IF;
      
      IF pr_dsnome_arq_log <> rw_job.dsnome_arq_log THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Nome Arq" de ' || rw_job.dsnome_arq_log
                                                   || ' para ' || pr_dsnome_arq_log || '.');
      END IF;
      
      IF REPLACE(REPLACE(REPLACE(pr_dscodigo_plsql,'&lt;','<'),'&gt;','>'),'&apos;','''') <> rw_job.dscodigo_plsql THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                   || 'Alterou o JOB campo "Codigo PLSQL" de ' || rw_job.dscodigo_plsql || chr(13)
                                                   || ' para ' || pr_dscodigo_plsql || '.');
      END IF;      
      
    ELSE
      BEGIN
        INSERT INTO tbgen_batch_jobs
                    (nmjob
                    ,dsdetalhe
                    ,dsprefixo_jobs
                    ,idativo
                    ,idperiodici_execucao
                    ,tpintervalo
                    ,qtintervalo
                    ,dsdias_habilitados
                    ,dtprox_execucao
                    ,hrjanela_exec_ini 
                    ,hrjanela_exec_fim 
                    ,flaguarda_processo
                    ,flexecuta_feriado
                    ,flsaida_email
                    ,dsdestino_email
                    ,flsaida_log
                    ,dsnome_arq_log
                    ,dscodigo_plsql
                    ,cdoperad_criacao
                    ,dtcriacao)
              VALUES(pr_nmjob
                    ,pr_dsdetalhe
                    ,pr_dsprefixo_jobs
                    ,decode(pr_idativo,'S',1,0)
                    ,pr_idperiodici_execucao
                    ,pr_tpintervalo
                    ,pr_qtintervalo
                    ,pr_dsdias_habilitados
                    ,vr_dtprox_execucao
                    ,pr_hrjanela_exec_ini 
                    ,pr_hrjanela_exec_fim 
                    ,pr_flaguarda_processo
                    ,pr_flexecuta_feriado
                    ,pr_flsaida_email
                    ,pr_dsdestino_email
                    ,pr_flsaida_log
                    ,pr_dsnome_arq_log
                    ,pr_dscodigo_plsql
                    ,vr_cdoperad
                    ,sysdate);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na inserção das informações do JOB: '||sqlerrm;
          RAISE vr_exc_erro;
      END;
      
            -- Geração de LOG
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o "JOB" com ' || pr_nmjob || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Ativo" com ' || pr_idativo || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Descrição Detalhada" com ' || pr_dsdetalhe || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Prefixo JOBs" com ' || pr_dsprefixo_jobs || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Periodicidade Execução" de ' || fn_des_periodic(rw_job.idperiodici_execucao)
                                                 || ' para ' || fn_des_periodic(pr_idperiodici_execucao) || '.');

      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Intervalo (Tipo)" com ' || pr_tpintervalo || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Intervalo (Tempo)" com ' || pr_qtintervalo || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Dias Habilitados" com ' || fn_dsdias_habilitados(pr_dsdias_habilitados) || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Próxima Execução" com ' || to_char(vr_dtprox_execucao,'DD/MM/RRRR hh24:mi') || '.');
      
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Janela Execução Inicial" com ' || pr_hrjanela_exec_ini || '.');
                                                
     btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Janela Execução Final" com ' || pr_hrjanela_exec_fim || '.'); 
      
     btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Aguardar Processo Finalizar?" com ' || pr_flaguarda_processo || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Executa em Feriados?" com ' || pr_flexecuta_feriado || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Tipo de Aviso/Saida Habilitada (Email)" com ' || pr_flsaida_email || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Email" com ' || pr_dsdestino_email || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Tipo de Aviso/Saida Habilitada (LOG)" com ' || pr_flsaida_log || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Nome Arq" com ' || pr_dsnome_arq_log || '.');
                                                 
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_flfinmsg     => 'N'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                 || 'Inseriu o JOB campo "Codigo PLSQL" com ' || pr_dscodigo_plsql || '.');
      
    END IF;

    -- Gravar no banco
    COMMIT;

    -- Retorno OK
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN

      -- Propagar Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_mantem_job --> '|| SQLERRM;
      pr_des_erro:= 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  END pc_mantem_job;

  /* Retornar todos os eventos de LOG do JOB enviado */
  PROCEDURE pc_consulta_log_jobs(pr_cdcooper  in number            -- Cooperativa
                                ,pr_nmjob     in varchar2          -- Nome JOB
                                ,pr_data_de   in varchar2          -- Data De
                                ,pr_data_ate  in varchar2          -- Data Até
                                ,pr_id_result in varchar2          -- ID Resultado
                                ,pr_nrregist IN INTEGER            -- Quantidade de registros
                                ,pr_nriniseq IN INTEGER            -- Qunatidade inicial
                                ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_consulta_log_jobs
    Autor    : Andreatta - Mouts
    Data     : Junho/2018                            Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Retornar todos os eventos de LOG do JOB enviado

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis gerais
    vr_contador PLS_INTEGER := 0;
    vr_datade   date;
    vr_dataat   date;

    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    vr_qtregist INTEGER;
    
    -- Busca dos Logs do Arquivo
    CURSOR cr_logs is
      select log.cdcooper||'-'||cop.nmrescop dscooper
            ,log.cdprograma
            ,log.dhinicio
            ,log.dhfim
            ,log.flgsucesso
            ,CASE 
              WHEN log.flgsucesso = 0 THEN 'Erro'
              WHEN NOT oco.dsmensagem IS NULL THEN 'Erro'
              WHEN log.dhfim IS NULL THEN 'Abortado/Em Exec.'
              ELSE 'Sucesso'
             END dsflgsucesso
            ,oco.dhocorrencia
            ,oco.dsmensagem
        from crapcop      cop
            ,tbgen_prglog log
            ,tbgen_prglog_ocorrencia oco
       where log.cdcooper = cop.cdcooper
         AND log.idprglog = oco.idprglog (+)
         AND cop.cdcooper = DECODE(pr_cdcooper,0,cop.cdcooper,pr_cdcooper)
         AND upper(log.cdprograma) = upper(Nvl(pr_nmjob,log.cdprograma))
         AND trunc(log.dhinicio) >= vr_datade
         AND trunc(nvl(nvl(log.dhfim,oco.dhocorrencia),log.dhinicio)) <= vr_dataat
       ORDER BY log.dhinicio DESC;

  BEGIN
    
    --Inicializar Variaveis
    vr_qtregist:= 0;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CONJOB'
                              ,pr_action => 'pc_consulta_log_jobs');

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
    
    -- Validar JOB
    /*IF pr_nmjob IS NULL THEN
      vr_dscritic := 'Nome do JOB é obrigatório!';
      RAISE vr_exc_Erro;
    END IF;*/
    
    -- Validar os parâmetros data
    IF trim(pr_data_de) IS NULL THEN
      vr_dscritic := 'Data de é obrigatória!';
      RAISE vr_exc_Erro;
    ELSE
      Begin
        vr_datade := to_date(pr_data_de,'dd/mm/rrrr');
      Exception
        When others then
          vr_dscritic := 'Data de ['||pr_data_de||'] inválida!';
          RAISE vr_exc_Erro;
      End;
    END IF;

    -- Validar os parâmetros data
    IF pr_data_ate IS NULL THEN
      vr_dscritic := 'Data até é obrigatória!';
      RAISE vr_exc_Erro;
    ELSE
      Begin
        vr_dataat := to_date(pr_data_ate,'dd/mm/rrrr');
      Exception
        When others then
          vr_dscritic := 'Data até ['||pr_data_ate||'] inválida!';
          RAISE vr_exc_Erro;
      End;
    END IF;

    -- Se enviada as duas datas, temos de validar se até não é inferior a De
    IF vr_datade > vr_dataat THEN
      vr_dscritic := 'Data De não pode ser superior a Data Até!';
      RAISE vr_exc_Erro;
    /*ELSIF vr_dataat - vr_datade > 7 THEN
      vr_dscritic := 'Período de datas não pode ser superior a 7 dias!';
      RAISE vr_exc_Erro;*/
    END IF;
    
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'lstlogs',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);

    -- Retornar os LOGS
    FOR rw_log IN cr_logs LOOP

      -- Caso data tenha sido informado
      /*IF vr_datade IS NOT NULL OR vr_dataat IS NOT NULL THEN
        -- Garantir data de e até quando temos as duas
        IF vr_datade IS NOT NULL AND vr_dataat IS NOT NULL THEN
          IF rw_log.dhinicio NOT BETWEEN vr_datade AND vr_dataat
          AND nvl(rw_log.dhfim,rw_log.dhinicio) NOT BETWEEN vr_datade AND vr_dataat THEN
            -- Ignorar este
            CONTINUE;
          END IF;
        -- Garantir somente Data De
        ELSIF vr_datade IS NOT NULL THEN
          IF rw_log.dhinicio < vr_datade
          AND nvl(rw_log.dhfim,rw_log.dhinicio) < vr_datade THEN
            -- Ignorar este arquivo
            CONTINUE;
          END IF;
        -- Garantir somente data até
        ELSIF vr_dataat IS NOT NULL THEN
          IF rw_log.dhinicio > vr_dataat
          AND nvl(rw_log.dhfim,rw_log.dhinicio) > vr_dataat THEN
            -- Ignorar este arquivo
            CONTINUE;
          END IF;
        END IF;
      END IF;*/
      
      -- Tratar flag de sucesso
      IF pr_id_result <> -1 THEN
        IF pr_id_result = 0 AND rw_log.dsflgsucesso <> 'Erro'
        OR pr_id_result = 1 AND rw_log.dsflgsucesso <> 'Sucesso' THEN
          CONTINUE;
        END IF;
      END IF;
      
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF;
      
      --Numero Registros
      IF vr_nrregist > 0 THEN
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'lstlogs',pr_posicao => 0,pr_tag_nova => 'log',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'log',pr_posicao => vr_contador, pr_tag_nova => 'dscooper', pr_tag_cont => rw_log.dscooper, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'log',pr_posicao => vr_contador, pr_tag_nova => 'nmjob', pr_tag_cont => rw_log.cdprograma, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'log',pr_posicao => vr_contador, pr_tag_nova => 'dtlog_ini', pr_tag_cont => TO_CHAR(rw_log.dhinicio,'dd/mm/yyyy')||'<BR>'||TO_CHAR(rw_log.dhinicio,'HH24:MI:SS'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'log',pr_posicao => vr_contador, pr_tag_nova => 'dtlog_fim', pr_tag_cont => TO_CHAR(rw_log.dhfim,'dd/mm/yyyy')||'<BR>'||TO_CHAR(rw_log.dhfim,'HH24:MI:SS'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'log',pr_posicao => vr_contador, pr_tag_nova => 'dtocorre', pr_tag_cont => TO_CHAR(rw_log.dhocorrencia,'dd/mm/yyyy')||'<BR>'||TO_CHAR(rw_log.dhocorrencia,'HH24:MI:SS'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'log',pr_posicao => vr_contador, pr_tag_nova => 'dsresult', pr_tag_cont => rw_log.dsflgsucesso, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'log',pr_posicao => vr_contador, pr_tag_nova => 'dslog', pr_tag_cont => rw_log.dsmensagem, pr_des_erro => vr_dscritic);                        
                                
        vr_contador := vr_contador + 1;
        
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;
    
    END LOOP;
    
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'lstlogs'           --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_Erro;
    END IF;

    -- Retorno OK
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN

      -- Propagar Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_log_jobs --> '|| SQLERRM;
      pr_des_erro:= 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  END pc_consulta_log_jobs;
  
  /* Executar o processo controlador acionado pelo JOB Master */
  PROCEDURE pc_controlador_master IS
  BEGIN
    /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_controlador_master
    Autor    : Andreatta - Mouts
    Data     : Julho/2018                            Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Ser acionado pelo processo controlador e checar a programação de todos
                 os Jobs, submetendo-os assim que a data da próxima execução for expirada

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/
    DECLARE
      -- Calendário
      rw_crapdat btch0001.cr_crapdat%rowtype;
      -- Busca de todos os JOBS ativos cadastrados e com data de execução expirada
      CURSOR cr_job IS
        SELECT * 
          FROM tbgen_batch_jobs jb
         WHERE jb.idativo = 1
           AND jb.dtprox_execucao <= SYSDATE;
      vr_nmjob VARCHAR2(100);   
      vr_qtdia NUMBER;        
    BEGIN
      -- Busca calendário da Central para verificar se o processo está rodando
      open btch0001.cr_crapdat(3);
      fetch btch0001.cr_crapdat
       into rw_crapdat;
      close btch0001.cr_crapdat;      
      -- validar se está liberado o paralelismo neste momento 
      IF gene0002.fn_busca_entrada(to_char(SYSDATE,'hh24')+1
                                  ,gene0001.fn_param_sistema('CRED',0,'QT_JB_HORA_BATCH_MASTER')
                                  ,';') = 0 THEN
        -- O programa só vai ser executado assim que achar uma janela com execução de no mínimo 1 job
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' -->  Processo Controlador não execeutará nenhum JOB. ' 
                                                   || ' Motivo: Quantidade de JOBS paralelos liberados para o horário é 0(zero).');
        -- SAir
        RETURN;
      END IF;
      -- Buscar cada JOB
      FOR rw_job IN cr_job LOOP
        -- CAso o JOB esteja configurado para aguardar o processo da Central finalizar
        -- e o mesmo estiver em execução ainda
        if rw_job.flaguarda_processo = 'S' and rw_crapdat.inproces <> 1 THEN
          -- Apenas Geração de LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => vr_nmarqlog
                                    ,pr_flfinmsg     => 'N'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                     || ' -->  Processo Controlador pulou o JOB ' || rw_job.nmjob 
                                                     || ' nome '||vr_nmjob||' pois o processo na Central '
                                                     || ' ainda está em execução.');
          -- Permanecerá expirado aguardando o momento que o processo finalizará
          continue;
        end if;
        -- Calcularemos a data e hora da próxima execução
        IF rw_job.idperiodici_execucao = 'R' THEN
          -- Caso tenhamos janela de execução e a mesma estiver expirada
          IF rw_job.hrjanela_exec_fim IS NOT NULL AND to_char(sysdate,'hh24:mi') > rw_job.hrjanela_exec_fim then
            -- Calcular a diferença entre o início da janela no próximo dia e a data expirada
            vr_qtdia := to_date(to_char(sysdate+1,'ddmmrr')||rw_job.hrjanela_exec_ini,'ddmmrrhh24:mi') - rw_job.dtprox_execucao;
          ELSE
            -- Observar quantidade de horas/minutos da recorrencia
            IF rw_job.tpintervalo = 'M' THEN
              -- Checar na fração de dia que equivale aos minutos
              vr_qtdia := 1/24/60 * rw_job.qtintervalo;
            ELSE            
              -- Checar na fração de dia que equivale as horas
              vr_qtdia := 1/24 * rw_job.qtintervalo;
            END IF;
          END IF;
        -- Todos outros casos Somaremos sempre x dias
        ELSIF rw_job.idperiodici_execucao = 'D' THEN
          -- Diária
          vr_qtdia := 1;
        ELSIF rw_job.idperiodici_execucao = 'S' THEN  
          -- Semanal
          vr_qtdia := 7;          
        ELSIF rw_job.idperiodici_execucao = 'Q' THEN
          -- Quinzenal
          vr_qtdia := 15;          
        ELSIF rw_job.idperiodici_execucao = 'M' THEN
          -- Mensal
          vr_qtdia := 30;          
        ELSIF rw_job.idperiodici_execucao = 'T' THEN
          -- Trimestral
          vr_qtdia := 90;          
        ELSIF rw_job.idperiodici_execucao = 'E' THEN
          -- Semestral
          vr_qtdia := 180;
        ELSE
          -- Anual
          vr_qtdia := 365;
        END IF;
        
        -- Adicionar a quantidade de dias montada acima, para recorrentes,
        -- não usa a data gravada, mas o sysdate, assim evitamos reexecuções em duplicidade
        IF rw_job.idperiodici_execucao = 'R' THEN
          rw_job.dtprox_execucao := to_date(to_char(SYSDATE,'ddmmrrhh24mi'),'ddmmrrhh24:mi') + vr_qtdia;
        ELSE
          rw_job.dtprox_execucao := rw_job.dtprox_execucao + vr_qtdia;
        END IF;
        
        -- Caso o JOB seja muito antigo, vamos garantir que ele não fique 
        -- em data do passado, pois isso faria com que ele fosse executado novamente
        rw_job.dtprox_execucao := greatest(rw_job.dtprox_execucao
                                 ,to_date(to_char(SYSDATE,'ddmmrrhh24mi'),'ddmmrrhh24:mi'));
        -- Temos de garantir que o mesmo seja um dia util (Se não executa em feriados)
        -- e que o dia esteja naquela lista de dias habilitados
        LOOP
          -- Sair quando acharmos a data OK
          EXIT WHEN substr(rw_job.dsdias_habilitados,to_char(rw_job.dtprox_execucao,'d'),1) = '1'
                AND(rw_job.flexecuta_feriado = 0 AND gene0005.fn_valida_dia_util(pr_cdcooper  => 3
                                                                                ,pr_dtmvtolt  => rw_job.dtprox_execucao
                                                                                ,pr_tipo      => 'P') = trunc(rw_job.dtprox_execucao)
                    OR rw_job.flexecuta_feriado = 1);
          -- Se não saiu acima iremos somar mais um dia
          rw_job.dtprox_execucao := rw_job.dtprox_execucao + 1;
        END LOOP;
        -- Atualizaremos o JOB gravando quando o mesmo será executado novamente
        BEGIN
          UPDATE tbgen_batch_jobs
             SET dtprox_execucao = rw_job.dtprox_execucao
           WHERE nmjob = rw_job.nmjob;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Ao atualizar data da proxima execucao do JOB: '||rw_job.nmjob||' --> '||SQLERRM;
            RAISE vr_exc_erro;
        END;
        -- Para jobs recorrentes com janela de execução expirada
        IF rw_job.idperiodici_execucao = 'R' AND rw_job.hrjanela_exec_fim IS NOT NULL 
        AND to_char(sysdate,'hh24:mi') > rw_job.hrjanela_exec_fim THEN  
          -- Apenas Geração de LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => vr_nmarqlog
                                    ,pr_flfinmsg     => 'N'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                     || ' -->  Processo Controlador Reprogramou o JOB ' || rw_job.nmjob 
                                                     || ' nome '||vr_nmjob||' para proxima execucao em '
                                                     ||to_char(rw_job.dtprox_execucao,'dd/mm/rrrr hh24:mi')
                                                     || ' pois a janela de execução para o dia expirou.');
        ELSE
          -- Gerar nome para o JOB no banco
          vr_nmjob := dbms_scheduler.generate_job_name(substr(rw_job.dsprefixo_jobs,1,18));
          -- Chamar a rotina padrão do banco (dbms_scheduler.create_job)
          dbms_scheduler.create_job(job_name        => vr_nmjob              --> Nome do JOB
                                   ,job_type        => 'PLSQL_BLOCK'         --> Indica que é um bloco PLSQL
                                   ,job_action      => rw_job.dscodigo_plsql --> Bloco PLSQL para execução
                                   ,start_date      => SYSTIMESTAMP          --> Data/hora para executar
                                   ,repeat_interval => NULL                  --> Função para calculo da próxima execução, ex: 'sysdate+1'
                                   ,job_class       => 'DEFAULT_JOB_CLASS'   --> Classe do JOB
                                   ,auto_drop       => TRUE                  --> Quando não houver mais agendamentos, "dropar"
                                   ,enabled         => TRUE                  --> Criar o JOB já ativando-o
                                   ,comments        => rw_job.dsdetalhe);    --> Descrição detalhada
          -- Geração de LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => vr_nmarqlog
                                    ,pr_flfinmsg     => 'N'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                     || ' -->  Processo Controlador Submeteu o JOB ' || rw_job.nmjob 
                                                     || ' com nome '||vr_nmjob||' e programou sua proxima execucao para '
                                                     ||to_char(rw_job.dtprox_execucao,'dd/mm/rrrr hh24:mi')|| '.');
        END IF;
        -- Efetuar gravação
        commit;
      END LOOP;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' --> Erro na execucao do processo controlador - ' || vr_dscritic || '.');
                                       
      WHEN OTHERS THEN 
        -- Gerar LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_flfinmsg     => 'N'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                   || ' --> Erro na execução do processo controlador: '||SQLERRM|| '.');
    END;  
  END pc_controlador_master;

END TELA_CONJOB;
/
