CREATE OR REPLACE PACKAGE CECRED.TELA_CONSPB AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_CONSPB
  --    Autor   : Jose Dill - Mouts
  --    Data    : Fevereiro/2019                      Ultima Atualizacao:   /  /
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Atender as necessidades da tela CONSPB, responsável pela conciliação dos dados entre
  --                o AIMARO x JDSPB. Construido para o Projeto 475
  --
  --    Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  PROCEDURE pc_executar_conciliacao_mnl(pr_tipo_msg   IN VARCHAR2       --> Tipo de mensagem (E - Enviadas, R - Recebidas, T - Todas)
                              ,pr_dtmensagem_de   IN VARCHAR2              --> Data inicial do período
                              ,pr_dtmensagem_ate  IN VARCHAR2              --> Data final do período
                              ,pr_dsendere        IN VARCHAR2              --> Endereço de e-mail para envio do CSV
                              ,pr_retxml          IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                              ,pr_cdcritic       OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic       OUT VARCHAR2              --> Descrição da crítica
                              ,pr_des_erro       OUT VARCHAR2  );          --> Saida OK/NOK

 
END TELA_CONSPB;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CONSPB AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_CONSPB
  --    Autor   : Jose Dill - Mouts
  --    Data    : Fevereiro/2019                      Ultima Atualizacao:   /  /
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Atender as necessidades da tela CONSPB, responsável pela conciliação dos dados entre
  --                o AIMARO x JDSPB. Construido para o Projeto 475
  --
  --    Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

 

  -- Variaveis retornadas da gene0004.pc_extrai_dados
  vr_cdcooper      INTEGER;
  vr_cdoperad      VARCHAR2(100);
  vr_nmdatela      VARCHAR2(100);
  vr_nmeacao       VARCHAR2(100);
  vr_cdagenci      VARCHAR2(100);
  vr_nrdcaixa      VARCHAR2(100);
  vr_idorigem      VARCHAR2(100);

  vr_xml_temp      VARCHAR2(32726) := '';
  vr_clob          CLOB;
  vr_varchar2      VARCHAR2(32726) := '';

  -- Variável de críticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(32000);

  
 

  
  PROCEDURE pc_executar_conciliacao_mnl(pr_tipo_msg   IN VARCHAR2       --> Tipo de mensagem (E - Enviadas, R - Recebidas, T - Todas)
                              ,pr_dtmensagem_de   IN VARCHAR2                  --> Data inicial do período
                              ,pr_dtmensagem_ate  IN VARCHAR2                  --> Data final do período
                              ,pr_dsendere        IN VARCHAR2              --> Endereço de e-mail para envio do CSV
                              ,pr_retxml          IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                              ,pr_cdcritic       OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic       OUT VARCHAR2              --> Descrição da crítica
                              ,pr_des_erro       OUT VARCHAR2) IS          --> Saida OK/NOK

    /* .............................................................................
    Programa: pc_executar_conciliacao
    Sistema : Sistema Pagamentos Brasileiros - Cooperativa de Credito
    Sigla   : SPB
    Autor   : Jose Dill
    Data    : Fevereiro/2019                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Executa a rotina de conciliação diária e contingencial

    Alteracoes:
    ............................................................................. */
    --Controle de erro
    vr_exc_erro EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper      INTEGER;
    vr_cdoperad      VARCHAR2(100);
    vr_nmdatela      VARCHAR2(100);
    vr_nmeacao       VARCHAR2(100);
    vr_cdagenci      VARCHAR2(100);
    vr_nrdcaixa      VARCHAR2(100);
    vr_idorigem      VARCHAR2(100);
    
    -- Variáveis de controle
    vr_qtd_reg_env       INTEGER;
    vr_qtd_reg_rec       INTEGER;

    vr_dtmensagem_de    DATE;
    vr_dtmensagem_ate   DATE;

  BEGIN -- Inicio pc_buscar_mensagens
    gene0001.pc_informa_acesso(pr_module => 'CONSPB'
                              ,pr_action => NULL);

    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      vr_cdcooper := 3;
    END IF;
    -- Validações dos parâmetros
    IF pr_dsendere IS NULL THEN
      vr_dscritic:= 'Endereço de e-mail obrigatório!';   
      RAISE vr_exc_erro;   
    END IF;
    --    
    IF pr_dtmensagem_de is null or pr_dtmensagem_ate is null THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Período DE e/ou  ATE deve ser informado!';
      RAISE vr_exc_erro;
    END IF;
    --
    Begin
      vr_dtmensagem_de := NVL(TO_DATE(pr_dtmensagem_de ,'dd/mm/yyyy'),TO_DATE('25-09-2018','dd-mm-yyyy'));
      vr_dtmensagem_ate:= NVL(TO_DATE(pr_dtmensagem_ate,'dd-mm-yyyy'),TO_DATE('01-12-2999','dd-mm-yyyy'));
    Exception
      When others Then
      vr_cdcritic := 0;
      vr_dscritic := 'Erro no formato das datas do período! '||sqlerrm;
      RAISE vr_exc_erro;
    End;
    If (vr_dtmensagem_ate - vr_dtmensagem_de) > 6 then
      vr_cdcritic := 0;
      vr_dscritic := 'Período informado deve ser igual ou inferior a 7 dias!';
      RAISE vr_exc_erro;
    End If;
    
    -- Validar se existem registros no Aimaro para o período estabelecido
    IF pr_tipo_msg IN ('E','T') THEN
      vr_qtd_reg_env :=0;
      SELECT count(*) INTO vr_qtd_reg_env
      FROM tbspb_msg_enviada tma
      WHERE TRUNC(tma.dhmensagem) BETWEEN vr_dtmensagem_de
                               AND vr_dtmensagem_ate;
    END IF;
    --
    IF pr_tipo_msg in ('R','T') THEN
    vr_qtd_reg_rec :=0;
    SELECT count(*) INTO vr_qtd_reg_rec
    FROM tbspb_msg_recebida tma
    WHERE TRUNC(tma.dhmensagem) BETWEEN vr_dtmensagem_de
                             AND vr_dtmensagem_ate;   
    END IF;                                                  
    --
    IF vr_qtd_reg_env = 0 and vr_qtd_reg_rec = 0 and pr_tipo_msg = 'T' THEN
       vr_dscritic:= 'Não há dados no Aimaro para este período solicitado!'; 
       RAISE vr_exc_erro;  
    ELSIF vr_qtd_reg_env = 0 and pr_tipo_msg = 'E' THEN
       vr_dscritic:= 'Não há dados de mensagens enviadas no Aimaro para este período solicitado!';   
       RAISE vr_exc_erro;  
    ELSIF vr_qtd_reg_rec = 0 and pr_tipo_msg = 'R' THEN
       vr_dscritic:= 'Não há dados de mensagens recebidas no Aimaro para este período solicitado!';
       RAISE vr_exc_erro;  
    END IF;  

    -- Validar se existem registros no JDSBP para o período estabelecido
    --*****************ATENCAO - TABELAS JD NAO CRIADAS*****************
    IF pr_tipo_msg IN ('E','T') THEN
      vr_qtd_reg_env :=0;
      SELECT count(*) INTO vr_qtd_reg_env
      FROM tbspb_msg_enviada tma
      WHERE TRUNC(tma.dhmensagem) BETWEEN vr_dtmensagem_de
                               AND vr_dtmensagem_ate;
    END IF;
    --
    IF pr_tipo_msg in ('R','T') THEN
    vr_qtd_reg_rec :=0;
    SELECT count(*) INTO vr_qtd_reg_rec
    FROM tbspb_msg_recebida tma
    WHERE TRUNC(tma.dhmensagem) BETWEEN vr_dtmensagem_de
                             AND vr_dtmensagem_ate;   
    END IF;                                                  
    --
    IF vr_qtd_reg_env = 0 and vr_qtd_reg_rec = 0 and pr_tipo_msg = 'T' THEN
       vr_dscritic:= 'Não há dados na JD para este período solicitado!'; 
       RAISE vr_exc_erro;  
    ELSIF vr_qtd_reg_env = 0 and pr_tipo_msg = 'E' THEN
       vr_dscritic:= 'Não há dados de mensagens enviadas na JD para este período solicitado!';   
       RAISE vr_exc_erro;  
    ELSIF vr_qtd_reg_rec = 0 and pr_tipo_msg = 'R' THEN
       vr_dscritic:= 'Não há dados de mensagens recebidas na JD para este período solicitado!';
       RAISE vr_exc_erro;  
    END IF;    
    -- Chamar o JOB
    -- Montar o bloco PLSQL que será executado
    -- Ou seja, executaremos a geração do arquivo CSV
    DECLARE
      vr_dsplsql    VARCHAR2(32000);
      vr_dhexecucao VARCHAR2(100);
      vr_jobname    VARCHAR2(1000);
    BEGIN
      vr_dsplsql := 'DECLARE'||chr(13)
                 || '  vr_cdcritic NUMBER;'||chr(13)
                 || '  vr_dscritic VARCHAR2(4000);'||chr(13)
                 || '  vr_retxml   XMLTYPE;'||chr(13)
                 || '  vr_nmdcampo VARCHAR2(4000);'||chr(13)
                 || '  vr_des_erro VARCHAR2(4000);'||chr(13)
                 || 'BEGIN'||chr(13)
                 || '  cecred.sspb0002.pc_gera_conciliacao_spb '
                  || '               (pr_tipo_concilacao   => '''||            'M'||''''
                 || '               ,pr_tipo_mensagem   => '''||            pr_tipo_msg||''''
                 || '               ,pr_data_ini        => '''||            pr_dtmensagem_de||''''
                 || '               ,pr_data_fim        => '''||            pr_dtmensagem_ate||''''
                 || '               ,pr_dsendere        => '''||            pr_dsendere||''''
                 || '               ,pr_cdcritic        => vr_cdcritic'
                 || '               ,pr_dscritic        => vr_dscritic);'
                 || '  COMMIT;'
                 || 'END;';
                 
                                   
      -- Montar o prefixo do código do programa para o jobname
      vr_dhexecucao := TO_CHAR(sysdate,'YYYY_MM_DD');
      vr_jobname    := 'CONSPB_'||vr_dhexecucao||'$';
      -- Faz a chamada ao programa paralelo atraves de JOB
      GENE0001.pc_submit_job(pr_cdcooper  => vr_cdcooper  --> Código da cooperativa
                            ,pr_cdprogra  => 'CONSPB'     --> Código do programa
                            ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                            ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                            ,pr_interva   => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                            ,pr_jobname   => vr_jobname   --> Nome randomico criado
                            ,pr_des_erro  => pr_dscritic);
      -- Testar saida com erro
      IF pr_dscritic IS NOT NULL THEN
        -- Levantar exceçao
        RAISE vr_exc_erro;
      END IF;
    END;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_LOGSPB.pc_buscar_mensagens_opcao_c_m --> ' ||SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_executar_conciliacao_mnl;

 


 
END TELA_CONSPB;
/
