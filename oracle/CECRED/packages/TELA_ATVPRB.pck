CREATE OR REPLACE PACKAGE CECRED.TELA_ATVPRB AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATVPRB                        
  --  Sistema  : Rotina para gravar informações de Operações Ativo Problematico
  --  Sigla    : ATVPRB
  --  Autor    : Rangel Decker
  --  Data     : Marco/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Atualização e cadastro de Operações Ativo Problematico

  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Tabela para guardar os motivos de ativos problematicos */
  TYPE typ_motivos IS RECORD
    (cdmotivor tbgen_motivo.idmotivo%TYPE
    ,dsmotivo  tbgen_motivo.dsmotivo%TYPE);

  /* Tabela para guardar os motivos de ativos problematicos */
  TYPE typ_tab_motivos IS TABLE OF typ_motivos INDEX BY PLS_INTEGER;

  PROCEDURE pc_valida_informacoes(pr_cdcooper  IN crapepr.cdcooper%TYPE --Cooperativa
                                  ,pr_nrdconta IN crapepr.nrdconta%TYPE --Conta
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --Contrato Emprestimo
                                  ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                  ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2);

   PROCEDURE pc_consulta ( pr_cdcooper  IN tbcadast_ativo_probl.cdcooper%TYPE   --Cooperativa
                          ,pr_nrdconta IN tbcadast_ativo_probl.nrdconta%TYPE  --Conta
                          ,pr_nrctremp IN tbcadast_ativo_probl.nrctremp%TYPE  --Contrato Emprestimo
                          ,pr_cdmotivo IN tbcadast_ativo_probl.cdmotivo%TYPE  --Codigo do moitvo
                          ,pr_datainic IN VARCHAR2 --Data de Inclusao Inicio
                          ,pr_datafina IN VARCHAR2 --Data de Inclusao Fim
                          ,pr_pagina   IN NUMBER   --Nr da Pagina
                          ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                          ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK



   PROCEDURE pc_consulta_historico ( pr_cdcooper IN tbhist_ativo_probl.cdcooper%TYPE --Cooperativa
                                     ,pr_nrdconta IN tbhist_ativo_probl.nrdconta%TYPE --Conta
                                     ,pr_nrctremp IN tbhist_ativo_probl.nrctremp%TYPE --Contrato Emprestimo
                                     ,pr_cdmotivo IN tbhist_ativo_probl.cdmotivo%TYPE --Codigo do motivo
                                     ,pr_datainic IN VARCHAR2 --Data inicio
                                     ,pr_datafina IN VARCHAR2 --Data fim
                                     ,pr_pagina   IN NUMBER   --Nr da Pagina
                                     ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK

   PROCEDURE pc_gera_log(pr_cdoperad IN crapope.cdoperad%TYPE
                         ,pr_tipdolog IN INTEGER
                         ,pr_cdcooper IN NUMBER
                         ,pr_nrconta  IN NUMBER
                         ,pr_dsdcampo IN VARCHAR2
                         ,pr_vlrcampo IN VARCHAR2
                         ,pr_vlcampo2 IN VARCHAR2);


  PROCEDURE pc_alteracao(pr_cdcooper  IN crapepr.cdcooper%TYPE --Codigo Cooperativa
                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE --Numero da Conta
                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE --Conta base
                        ,pr_cdmotivo IN NUMBER                 --Codigo motivo
                        ,pr_dsobserv  IN VARCHAR2              -- Observação
                        ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro  OUT VARCHAR2);           --Saida OK/NOK


  PROCEDURE pc_exclusao (pr_cdcooper  IN crapepr.cdcooper%TYPE --Codigo Cooperativa
                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE --Numero da Conta
                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE --Conta base
                         ,pr_cdmotivo IN NUMBER                -- Codigo do Motivo
                        ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro  OUT VARCHAR2);            --Saida OK/NOK

  PROCEDURE pc_inclusao (pr_cdcooper  IN crapepr.cdcooper%TYPE --Codigo Cooperativa
                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE --Numero da Conta
                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE --Conta base
                        ,pr_cdmotivo IN NUMBER                 --Codigo motivo
                        ,pr_dsobserv  IN VARCHAR2              -- Observação
                        ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro  OUT VARCHAR2);           --Saida OK/NOK


   PROCEDURE pc_busca_motivos_probl( pr_tipo      IN VARCHAR2
                                     ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK

END TELA_ATVPRB;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATVPRB AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_ATVPRB                          
   Sistema : Cadastro - Tela Ativo Problematico
   Sigla   : ATVPRB 

   Autor   : Rangel Decker - AMcom
   Data    : Marco/2018                       Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Centralizar rotinas da Tela Ativo Problematico

   Alteracoes:
  ---------------------------------------------------------------------------------------------------------------*/

  -- Variavel temporária para LOG
  vr_dslogtel VARCHAR2(32767) := '';


  PROCEDURE pc_gera_log(pr_cdoperad IN crapope.cdoperad%TYPE
                       ,pr_tipdolog IN INTEGER
                       ,pr_cdcooper IN NUMBER
                       ,pr_nrconta  IN NUMBER
                       ,pr_dsdcampo IN VARCHAR2
                       ,pr_vlrcampo IN VARCHAR2
                       ,pr_vlcampo2 IN VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_gera_log                            
    Sistema  : Cadastro - Tela Ativo Problematico
    Sigla    : ATVPRB
    Autor    : Rangel Decker - AMcom
    Data     : Marco/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia : Sempre que for chamado
    Objetivo   : Procedure para gerar log

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

   BEGIN

     CASE pr_tipdolog
       WHEN 1 THEN
         vr_dslogtel := vr_dslogtel
                     || to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                     || ' -->  Operador ' || pr_cdoperad || ' - '
                     || 'Incluiu a conta '|| pr_nrconta  || ' como ativo problemático.'
                     || 'Na cooperativa ' || pr_cdcooper  ;

       WHEN 2 THEN
         vr_dslogtel := vr_dslogtel
                     || to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                     || ' -->  Operador '|| pr_cdoperad || ' - '
                     || 'Incluiu campo ' || pr_dsdcampo
                     || ' com valor ' || pr_vlrcampo || '.';

       WHEN 3 THEN
         vr_dslogtel := vr_dslogtel
                     || to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                     || ' -->  Operador '|| pr_cdoperad || ' - '
                     || 'Alterou a conta'|| pr_nrconta
                     || 'Da cooperativa' || pr_cdcooper ||'.' ;

      WHEN 4 THEN
         vr_dslogtel := vr_dslogtel
                     || to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                     || ' -->  Operador ' || pr_cdoperad || ' - '
                     || 'Alterou a conta '|| pr_nrconta  || 'da cooperativa '||pr_cdcooper
                     || ', campo ' || pr_dsdcampo || ' de ' || pr_vlrcampo
                     || ' para '   || pr_vlcampo2 || '.';


       WHEN 5 THEN
         vr_dslogtel := vr_dslogtel
                     || to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                     || ' -->  Operador '|| pr_cdoperad || ' - '
                     || 'Excluiu a operação de ativo problematico para conta '
                     || pr_nrconta ||'da cooperativa'||pr_cdcooper|| '.';

       ELSE NULL;

     END CASE;

     -- Incluir quebra de linha
     vr_dslogtel := vr_dslogtel || chr(10);

      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log  => vr_dslogtel,
                                 pr_nmarqlog => 'atvprb.log',
                                 pr_flfinmsg => 'N');

   EXCEPTION
     WHEN OTHERS THEN
       -- Não havia tratamento anterior no retorno da mesma
       NULL;
   END pc_gera_log;

  PROCEDURE pc_alteracao(pr_cdcooper  IN crapepr.cdcooper%TYPE --Codigo Cooperativa
                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE --Numero da Conta
                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE --Conta base
                        ,pr_cdmotivo  IN NUMBER                --Codigo motivo
                        ,pr_dsobserv  IN VARCHAR2              -- Observação
                        ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro  OUT VARCHAR2)IS          --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_alteracao                           
    Sistema  : Cadastro - Tela Ativo Problematico
    Sigla    : ATVPRB
    Autor    : Rangel Decker -AMcom
    Data     : Marco/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia : Sempre que for chamado
    Objetivo   : Altera cadastro Operação Ativo Problematico

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/


    -- Variaveis de log

    vr_cdoperad VARCHAR2(100);
    vr_nmdcampo VARCHAR2(100);
    vr_des_erro VARCHAR2(10);

    --Controle de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;


  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'ATVPRB'
                              ,pr_action => null);

    -- Recupera dados de log para consulta posterior
 /*   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);*/

    -- Verifica se houve erro recuperando informacoes de log
    IF vr_dscritic IS NOT NULL THEN

      RAISE vr_exc_erro;
    END IF;

    TELA_ATVPRB.pc_valida_informacoes(pr_cdcooper   => pr_cdcooper --Cooperativa
                                      ,pr_nrdconta  => pr_nrdconta --Conta
                                      ,pr_nrctremp  => pr_nrctremp --Contrato Emprestimo
                                      ,pr_cdcritic => vr_cdcritic --Cõdigo da critica
                                      ,pr_dscritic => vr_dscritic --Descrção da critica
                                      ,pr_nmdcampo => vr_nmdcampo --Nome do campo de retorno
                                      ,pr_des_erro => vr_des_erro); --Retorno OK;NOK

    IF vr_des_erro <> 'OK'      OR
       nvl(vr_cdcritic,0) <> 0  OR
       vr_dscritic IS NOT NULL  THEN

      RAISE vr_exc_erro;

    END IF;

    --Realiza a alteração do registro de convenio
    BEGIN

      UPDATE tbcadast_ativo_probl tbap
      SET    tbap.cdmotivo  = pr_cdmotivo,
             tbap.dsobserv  = pr_dsobserv
      WHERE  tbap.cdcooper  = pr_cdcooper
      AND    tbap.nrdconta  = pr_nrdconta
      AND    tbap.nrctremp  = pr_nrctremp
      AND    tbap.cdmotivo  = pr_cdmotivo
      AND    tbap.idativo   = 1;

    EXCEPTION
      WHEN OTHERS THEN
        --Monta mensagem de erro
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel atualizar a operação - ' || sqlerrm;

        RAISE vr_exc_erro;

    END;

    -- Geração de LOG
     pc_gera_log (pr_cdoperad => vr_cdoperad
                ,pr_tipdolog => 3
                ,pr_cdcooper => pr_cdcooper
                ,pr_nrconta  => pr_nrdconta
                ,pr_dsdcampo => ''
                ,pr_vlrcampo => ''
                ,pr_vlcampo2 => '');

   pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 4
               ,pr_cdcooper => pr_cdcooper
               ,pr_nrconta  => pr_nrdconta
               ,pr_dsdcampo => 'Motivo'
               ,pr_vlrcampo => pr_cdmotivo
               ,pr_vlcampo2 => '');



   pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 4
               ,pr_cdcooper => pr_cdcooper
               ,pr_nrconta  => pr_nrdconta
               ,pr_dsdcampo => 'Observacao'
               ,pr_vlrcampo => pr_dsobserv
               ,pr_vlcampo2 => '');



    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    pr_des_erro := 'OK';

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>'||pr_dscritic ||'</Erro></Root>');

      ROLLBACK;

    WHEN OTHERS THEN

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:='Erro na pc_alteracao --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>'||pr_dscritic || '</Erro></Root>');

      ROLLBACK;



  END pc_alteracao;

  PROCEDURE pc_exclusao (pr_cdcooper  IN crapepr.cdcooper%TYPE --Codigo Cooperativa
                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE --Numero da Conta
                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE --Conta base
                        ,pr_cdmotivo IN NUMBER                -- Codigo do Motivo
                        ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro  OUT VARCHAR2)IS          --Saida OK/NOK)

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_exclusao                            
    Sistema  : Cadastro - Tela Ativo Problematico
    Sigla    : ATVPRB
    Autor    : Rangel Decker AMcom
    Data     : Marco/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia : Sempre que for chamado
    Objetivo   : Desativa a situação de ativo problematico.

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);


    -- Variaveis de log
    vr_cdoperad VARCHAR2(100);
    vr_des_erro VARCHAR2(100);
    vr_nmdcampo VARCHAR2(100);

    -- Variável genérica de calendário com base no cursor da btch0001
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;

  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'ATVPRB'
                              ,pr_action => null);

    -- Recupera dados de log para consulta posterior
 /*   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
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
    END IF;*/

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

        -- Busca critica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;



   -- Verifica se houve erro recuperando informacoes de log
     TELA_ATVPRB.pc_valida_informacoes(pr_cdcooper   => pr_cdcooper --Cooperativa
                                      ,pr_nrdconta  => pr_nrdconta --Conta
                                      ,pr_nrctremp  => pr_nrctremp --Contrato Emprestimo
                                      ,pr_cdcritic => vr_cdcritic --Cõdigo da critica
                                      ,pr_dscritic => vr_dscritic --Descrção da critica
                                      ,pr_nmdcampo => vr_nmdcampo --Nome do campo de retorno
                                      ,pr_des_erro => vr_des_erro); --Retorno OK

    IF vr_des_erro <> 'OK'      OR
       nvl(vr_cdcritic,0) <> 0  OR
       vr_dscritic IS NOT NULL  THEN

      RAISE vr_exc_erro;

    END IF;

    BEGIN

      UPDATE tbcadast_ativo_probl tbap
      SET    tbap.dtexclus = rw_crapdat.dtmvtolt,
             tbap.idativo  = 0
      WHERE  tbap.cdcooper = pr_cdcooper
      AND    tbap.nrdconta = pr_nrdconta
      AND    tbap.nrctremp = pr_nrctremp
      AND    tbap.cdmotivo = pr_cdmotivo;

    EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel excluir o(s) registro(s).'||SQLERRM;

          RAISE vr_exc_erro;
    END;




    pc_gera_log (pr_cdoperad => vr_cdoperad
                ,pr_tipdolog => 5
                ,pr_cdcooper => pr_cdcooper
                ,pr_nrconta => pr_nrdconta
                ,pr_dsdcampo => ''
                ,pr_vlrcampo => ''
                ,pr_vlcampo2 => '');

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    pr_des_erro := 'OK';

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN

      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;


      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>'||pr_dscritic ||'</Erro></Root>');

      ROLLBACK;

    WHEN OTHERS THEN

      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_exclusao --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' ||pr_dscritic || '</Erro></Root>');

      ROLLBACK;

  END pc_exclusao;

  PROCEDURE pc_inclusao (pr_cdcooper  IN crapepr.cdcooper%TYPE --Codigo Cooperativa
                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE --Numero da Conta
                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE --Conta base
                        ,pr_cdmotivo IN NUMBER                --Codigo motivo
                        ,pr_dsobserv  IN VARCHAR2              -- Observação
                        ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK
   /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_inclusao                            
    Sistema  : Cadastro - Tela Ativo Problematico
    Sigla    : ATVPRB
    Autor    : Rangel Decker - AMcom
    Data     : Marco/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia:  Sempre que for chamado
    Objetivo   : Inclui cadastro operações ativo problematico.

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

    --Variaveis locais
    vr_cdoperad VARCHAR2(100);
    vr_nmdcampo VARCHAR2(100);
    vr_des_erro VARCHAR2(10);

    vr_dtrefere     DATE;                   --> Data de referência do processo

    vr_verifica NUMBER;

    --Variaveis de critica
    vr_exc_erro EXCEPTION;
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);

    -- Variável genérica de calendário com base no cursor da btch0001
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;



  BEGIN

   -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'ATVPRB'
                              ,pr_action => null);


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

        -- Busca critica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

  -- Recupera dados de log para consulta posterior
    /*gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);*/


   -- Verifica se houve erro recuperando informacoes de log
     TELA_ATVPRB.pc_valida_informacoes(pr_cdcooper   => pr_cdcooper --Cooperativa
                                      ,pr_nrdconta  => pr_nrdconta --Conta
                                      ,pr_nrctremp  => pr_nrctremp --Contrato Emprestimo
                                      ,pr_cdcritic => vr_cdcritic --Cõdigo da critica
                                      ,pr_dscritic => vr_dscritic --Descrção da critica
                                      ,pr_nmdcampo => vr_nmdcampo --Nome do campo de retorno
                                      ,pr_des_erro => vr_des_erro); --Retorno OK

    IF vr_des_erro <> 'OK'      OR
       nvl(vr_cdcritic,0) <> 0  OR
       vr_dscritic IS NOT NULL  THEN

      RAISE vr_exc_erro;

    END IF;

    -- Verifica se o registro já existe
    BEGIN
      SELECT 1 INTO vr_verifica
      FROM tbcadast_ativo_probl tbap
      WHERE tbap.cdcooper = pr_cdcooper
      AND   tbap.nrdconta = pr_nrdconta
      AND   tbap.nrctremp = pr_nrctremp
      AND   tbap.cdmotivo = pr_cdmotivo
      AND   tbap.idativo =1;

     EXCEPTION
      WHEN OTHERS THEN
         vr_verifica:=0;

    END;

     IF vr_verifica >0 THEN
        vr_dscritic :='Ja existe motivo ativo para conta: '||pr_nrdconta||' e contrato: '||pr_nrctremp;
        RAISE vr_exc_erro;
     END IF;

     --Incluir registro de operações ativo problematico
     BEGIN

     INSERT INTO tbcadast_ativo_probl(cdcooper,
                                      nrdconta,
                                      nrctremp,
                                      dtinclus,
                                      cdmotivo,
                                      dsobserv)
      VALUES(pr_cdcooper,
             pr_nrdconta,
             pr_nrctremp,
             rw_crapdat.dtmvtolt,
             pr_cdmotivo,
             pr_dsobserv
             );

    EXCEPTION
      WHEN OTHERS THEN

        --Monta mensagem de erro
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel incluir a operacao.' || SQLERRM;

        RAISE vr_exc_erro;

    END;

  -- Geração de LOG
    pc_gera_log (pr_cdoperad => vr_cdoperad
                ,pr_tipdolog => 1
                ,pr_cdcooper => pr_cdcooper
                ,pr_nrconta  => pr_nrdconta
                ,pr_dsdcampo => ''
                ,pr_vlrcampo => ''
                ,pr_vlcampo2 => '');



    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 2
               ,pr_cdcooper => pr_cdcooper
               ,pr_nrconta  => pr_nrdconta
               ,pr_dsdcampo => 'Contrato'
               ,pr_vlrcampo => pr_nrctremp
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 2
               ,pr_cdcooper => pr_cdcooper
               ,pr_nrconta  => pr_nrdconta
               ,pr_dsdcampo => 'Data Inclusao'
               ,pr_vlrcampo => rw_crapdat.dtmvtolt
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog  => 2
               ,pr_cdcooper => pr_cdcooper
               ,pr_nrconta  => pr_nrdconta
               ,pr_dsdcampo  => 'Motivo'
               ,pr_vlrcampo  => pr_cdmotivo
               ,pr_vlcampo2  => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
                ,pr_tipdolog => 2
                ,pr_cdcooper => pr_cdcooper
                ,pr_nrconta  => pr_nrdconta
                ,pr_dsdcampo => 'Observacao'
                ,pr_vlrcampo => pr_dsobserv
                ,pr_vlcampo2 => '');

     pc_gera_log(pr_cdoperad => vr_cdoperad
                ,pr_tipdolog => 6
                ,pr_cdcooper => pr_cdcooper
                ,pr_nrconta  => pr_nrdconta
                ,pr_dsdcampo => 'Ativo'
                ,pr_vlrcampo => 1
                ,pr_vlcampo2 => '');

    pr_des_erro := 'OK';

    COMMIT;

   EXCEPTION
    WHEN vr_exc_erro THEN  BEGIN

      pr_des_erro := 'NOK';

      -- Erro

      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>'||pr_dscritic||'</Erro></Root>');



      ROLLBACK;
    END;

    WHEN OTHERS THEN   BEGIN

      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_inclusao --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||pr_dscritic||
                                     '<Root><Erro></Erro></Root>');


      ROLLBACK;

    END;
  END pc_inclusao;


  PROCEDURE pc_gera_log_arquivo(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_dscritic OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_gera_log_arquivo                            
    Sistema  : Cadastro - Tela Ativo Problematico
    Sigla    : ATVPRB
    Autor    : Rangel Decker AMcom
    Data     : Marco/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo   :Procedure para gerar log 

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

   BEGIN

     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                               ,pr_ind_tipo_log => 2 -- Erro tratato
                               ,pr_nmarqlog     => 'atvprb.log'
                               ,pr_des_log      => rtrim(vr_dslogtel,chr(10)));
   EXCEPTION
    WHEN OTHERS THEN

      pr_dscritic := 'Erro ao gravar LOG: '||SQLERRM;

   END pc_gera_log_arquivo;


  PROCEDURE pc_valida_informacoes(pr_cdcooper IN crapepr.cdcooper%TYPE --Cooperativa
                                  ,pr_nrdconta IN crapepr.nrdconta%TYPE --Conta
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --Contrato Emprestimo
                                  ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                  ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_valida_informacoes                            
    Sistema  : Cadastro - Tela Ativo Problematico
    Sigla    : ATVPRB
    Autor    : Rangel Decker - AMCom
    Data     : Marco/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia:  Sempre que for chamado
    Objetivo   : Validações das  informações para cadastro e atualizações

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

    --Cursor para encontrar a cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;


    --Cursor para encontrar o contrato de emprestimo
    CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                     ,pr_nrdconta IN crapepr.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE)IS
    SELECT epr.cdcooper
      FROM crapepr epr
     WHERE epr.cdcooper = pr_cdcooper
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp;

    rw_crapepr cr_crapepr%ROWTYPE;


    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;

  BEGIN

    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);

    FETCH cr_crapcop INTO rw_crapcop;

    IF cr_crapcop%NOTFOUND THEN

        --Fecha o cursor
        CLOSE cr_crapcop;

        -- Montar mensagem de critica
        vr_cdcritic := 1070;

        -- Busca critica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_erro;

      ELSE
        CLOSE cr_crapcop;

      END IF;

     OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrctremp => pr_nrctremp);

     FETCH cr_crapepr INTO rw_crapepr;

     IF cr_crapepr%NOTFOUND THEN

        --Fecha o cursor
        CLOSE cr_crapepr;

        -- Montar mensagem de critica
        vr_cdcritic := 484;

        -- Busca critica
        vr_dscritic :='Conta ou contrato nao encontrados.';--gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_erro;

      ELSE
        CLOSE cr_crapepr;
      END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN

      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN

      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_valida_informacoes --> '|| SQLERRM;

  END pc_valida_informacoes;


  PROCEDURE pc_consulta ( pr_cdcooper  IN tbcadast_ativo_probl.cdcooper%TYPE   --Cooperativa
                          ,pr_nrdconta IN tbcadast_ativo_probl.nrdconta%TYPE  --Conta
                          ,pr_nrctremp IN tbcadast_ativo_probl.nrctremp%TYPE  --Contrato Emprestimo
                          ,pr_cdmotivo IN tbcadast_ativo_probl.cdmotivo%TYPE  --Codigo do moitvo
                          ,pr_datainic IN VARCHAR2 --Data de Inclusao Inicio
                          ,pr_datafina IN VARCHAR2 --Data de Inclusao Fim
                          ,pr_pagina   IN NUMBER   --Nr da Pagina
                          ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                          ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK

     /* .............................................................................
      Programa: pc_consulta
      Sistema : Cadastro - Tela Ativo Problematico
      Sigla   : ATVPRB
      Autor   : Rangel Decker
      Data    : Marco/2018                       Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para buscar dados da tela Cadastro de Operações Ativo Problematico

      Alteracoes:
      ..............................................................................*/

    -- Busca dados do cooperado
        CURSOR cr_tcap (pr_cdcooper NUMBER
                       ,pr_nrdconta NUMBER
                       ,pr_nrctremp NUMBER
                       ,pr_regini   NUMBER
                       ,pr_regfim   NUMBER) IS

        SELECT * FROM (
         SELECT  tcap.cdcooper,
                 tcap.nrdconta,
                 tcap.nrctremp,
                 to_char(tcap.dtinclus,'dd/mm/yyyy') dtinclus,
                 to_char(tcap.dtexclus,'dd/mm/yyyy') dtexclus,
                 tcap.cdmotivo,
                 tbmtv.dsmotivo,
                 tcap.dsobserv,
                 tcap.idativo,
                 ROW_NUMBER() OVER (ORDER BY dtinclus) Row_Num
          FROM tbcadast_ativo_probl tcap,
               tbgen_motivo tbmtv
          WHERE tcap.cdcooper  = pr_cdcooper
          AND   tbmtv.idmotivo = tcap.cdmotivo
          AND   tbmtv.cdproduto = 42
          AND tcap.nrdconta = DECODE(pr_nrdconta, 0, tcap.nrdconta, pr_nrdconta)
          AND tcap.nrctremp = DECODE(pr_nrctremp, 0, tcap.nrctremp, pr_nrctremp)
          AND tcap.cdmotivo = DECODE(pr_cdmotivo, 0, tcap.cdmotivo, pr_cdmotivo)
          AND tcap.dtinclus BETWEEN to_date(pr_datainic,'DD/MM/YYYY') AND to_date(pr_datafina,'DD/MM/YYYY'))
          WHERE Row_Num BETWEEN pr_regini AND pr_regfim;

        rw_tcap cr_tcap%ROWTYPE;

        -- Variável de críticas
        vr_exc_erro  EXCEPTION;
        vr_cdcritic  INTEGER;
        vr_dscritic  VARCHAR2(1000);

        -- Variaveis auxiliares
        vr_auxconta  INTEGER :=0; -- Contador auxiliar p/ posicao no XML
        vr_RegTotal  INTEGER :=0;
        vr_nrlinhas  INTEGER :=8;
        vr_auxinicial  INTEGER :=0;
        vr_auxfinal    INTEGER :=0 ;




    BEGIN
          pr_des_erro := 'OK';

          vr_auxinicial := ((pr_pagina - 1)*vr_nrlinhas) + 1;
          vr_auxfinal   := (pr_pagina* vr_nrlinhas);

          SELECT  count(*) INTO vr_RegTotal
          FROM tbcadast_ativo_probl tcap,
               tbgen_motivo tbmtv
          WHERE tcap.cdcooper  = pr_cdcooper
          AND   tbmtv.idmotivo = tcap.cdmotivo
          AND   tbmtv.cdproduto = 42
          AND tcap.nrdconta = DECODE(pr_nrdconta, 0, tcap.nrdconta, pr_nrdconta)
          AND tcap.nrctremp = DECODE(pr_nrctremp, 0, tcap.nrctremp, pr_nrctremp)
          AND tcap.cdmotivo = DECODE(pr_cdmotivo, 0, tcap.cdmotivo, pr_cdmotivo)
          AND tcap.dtinclus BETWEEN to_date(pr_datainic,'DD/MM/YYYY') AND to_date(pr_datafina,'DD/MM/YYYY');


          -- Incluir nome
         GENE0001.pc_informa_acesso(pr_module => 'ATVPRB'
                                   ,pr_action => null);



          -- Criar cabecalho do XML
          pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                 ,pr_tag_pai  => 'Root'
                                 ,pr_posicao  => 0
                                 ,pr_tag_nova => 'Dados'
                                 ,pr_tag_cont => NULL
                                 ,pr_des_erro => vr_dscritic);


         FOR rw_tcap IN cr_tcap (pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrctremp => pr_nrctremp,
                                 pr_regini   => vr_auxinicial,
                                 pr_regfim   => vr_auxfinal
                                 ) LOOP

          -- Consulta as informações

           GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  =>  0
                                ,pr_tag_nova => 'registro'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => vr_dscritic);


          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'registro'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'cdcooper'
                                ,pr_tag_cont => rw_tcap.cdcooper
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'registro'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'nrdconta'
                                ,pr_tag_cont => rw_tcap.nrdconta
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'registro'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'nrctremp'
                                ,pr_tag_cont => rw_tcap.nrctremp
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'registro'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dtinclus'
                                ,pr_tag_cont => rw_tcap.dtinclus
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'registro'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dtexclus'
                                ,pr_tag_cont => rw_tcap.dtexclus
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'registro'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'cdmotivo'
                                ,pr_tag_cont => rw_tcap.cdmotivo
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'registro'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dsmotivo'
                                ,pr_tag_cont => rw_tcap.dsmotivo
                                ,pr_des_erro => vr_dscritic);


          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'registro'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dsobserv'
                                ,pr_tag_cont => rw_tcap.dsobserv
                                ,pr_des_erro => vr_dscritic);

         vr_auxconta := vr_auxconta + 1;

       END LOOP;


     gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'RgInicio'
                            ,pr_tag_cont => vr_auxinicial
                            ,pr_des_erro => vr_dscritic);


      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'TmPagina'
                            ,pr_tag_cont => vr_nrlinhas
                            ,pr_des_erro => vr_dscritic);


      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'QtRegist'
                            ,pr_tag_cont => vr_RegTotal
                            ,pr_des_erro => vr_dscritic);

        EXCEPTION
          WHEN vr_exc_erro THEN
          -- Retorno não OK
          pr_des_erro := 'NOK';

          IF NVL(vr_cdcritic,0) > 0 THEN
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;

          -- Erro
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

          -- Existe para satisfazer exigência da interface.
          pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em consultar operacao. ' || SQLERRM;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;

    END  pc_consulta;

    PROCEDURE pc_consulta_historico ( pr_cdcooper IN tbhist_ativo_probl.cdcooper%TYPE --Cooperativa
                                     ,pr_nrdconta IN tbhist_ativo_probl.nrdconta%TYPE --Conta
                                     ,pr_nrctremp IN tbhist_ativo_probl.nrctremp%TYPE --Contrato Emprestimo
                                     ,pr_cdmotivo IN tbhist_ativo_probl.cdmotivo%TYPE --Codigo do motivo
                                     ,pr_datainic IN VARCHAR2 --Data inicio
                                     ,pr_datafina IN VARCHAR2 --Data fim
                                     ,pr_pagina   IN NUMBER   --Nr da Pagina
                                     ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK

   /* .............................................................................
    Programa: pc_consulta_historico
    Sistema : Cadastro - Tela Ativo Problematico
    Sigla   : ATVPRB 
    Autor   : Diego Simas
    Data    : Marco/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para listar o historico dos ativos problematicos
                enviado ao arquivo 3040 -  Tela ATVPRB

    Alteracoes:

    ..............................................................................*/

    -- Busca dados do historico do ativo problematico
       CURSOR cr_thap (pr_cdcooper NUMBER
                      ,pr_nrdconta NUMBER
                      ,pr_nrctremp NUMBER
                      ,pr_cdmotivo NUMBER
                      ,pr_regini   NUMBER
                      ,pr_regfim   NUMBER
                      ,pr_datainic VARCHAR2
                      ,pr_datafina VARCHAR2) IS
        SELECT * FROM
           ( SELECT thap.cdcooper,
                    thap.nrdconta,
                    thap.nrctremp,
                    to_char(thap.dtinreg ,'dd/mm/yyyy')  dtinreg,
                    to_char(thap.dthistreg,'dd/mm/yyyy') dthistreg,
                    thap.cdmotivo,
                    tbmtv.dsmotivo,
                    thap.dsobserv,
                    thap.idtipo_envio,
                    ROW_NUMBER() OVER (ORDER BY dthistreg) Row_Num
              FROM tbhist_ativo_probl thap,
                   tbgen_motivo tbmtv
             WHERE thap.cdcooper = pr_cdcooper
             AND thap.cdmotivo = tbmtv.idmotivo
             AND tbmtv.cdproduto = 42
             AND thap.nrdconta = decode(pr_nrdconta, 0, thap.nrdconta, pr_nrdconta)
             AND thap.nrctremp = decode(pr_nrctremp, 0, thap.nrctremp, pr_nrctremp)
             AND thap.cdmotivo = decode(pr_cdmotivo, 0, thap.cdmotivo, pr_cdmotivo)
             AND thap.dthistreg BETWEEN to_date(pr_datainic,'DD/MM/YYYY') AND to_date(pr_datafina,'DD/MM/YYYY'))
             WHERE Row_Num BETWEEN pr_regini AND pr_regfim;



        rw_thap cr_thap%ROWTYPE;

      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);

      -- Variaveis auxiliares
      vr_flgfound   BOOLEAN;
      vr_tipo_envio VARCHAR2(100);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_des_erro VARCHAR2(100);
      vr_nmdcampo VARCHAR2(100);

      -- Variaveis auxiliares
      vr_auxconta    INTEGER :=0; -- Contador auxiliar p/ posicao no XML
      vr_auxinicial  INTEGER :=0;
      vr_auxfinal    INTEGER :=0 ;
      vr_RegTotal    INTEGER :=0;
      vr_nrlinhas    INTEGER :=8;

    BEGIN
        pr_des_erro := 'OK';

        vr_auxinicial := ((pr_pagina - 1)*vr_nrlinhas) + 1;
        vr_auxfinal   := (pr_pagina* vr_nrlinhas);


        SELECT  count(*) INTO vr_RegTotal
         FROM tbhist_ativo_probl thap,
              tbgen_motivo tbmtv
        WHERE thap.cdcooper = pr_cdcooper
          AND thap.cdmotivo = tbmtv.idmotivo
          AND tbmtv.cdproduto = 42
          AND thap.nrdconta = decode(pr_nrdconta, 0, thap.nrdconta, pr_nrdconta)
          AND thap.nrctremp = decode(pr_nrctremp, 0, thap.nrctremp, pr_nrctremp)
          AND thap.cdmotivo = decode(pr_cdmotivo, 0, thap.cdmotivo, pr_cdmotivo)
          AND thap.dthistreg BETWEEN to_date(pr_datainic,'DD/MM/YYYY') AND to_date(pr_datafina,'DD/MM/YYYY');

       -- Incluir nome
       GENE0001.pc_informa_acesso(pr_module => 'ATVPRB'
                                ,pr_action => null);

       -- Criar cabecalho do XML
       pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

       gene0007.pc_insere_tag(pr_xml      => pr_retxml
                             ,pr_tag_pai  => 'Root'
                             ,pr_posicao  => 0
                             ,pr_tag_nova => 'Dados'
                             ,pr_tag_cont => NULL
                             ,pr_des_erro => vr_dscritic);



       FOR rw_thap IN cr_thap (pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => pr_nrdconta,
                               pr_nrctremp => pr_nrctremp,
                               pr_cdmotivo => pr_cdmotivo,
                               pr_regini   => vr_auxinicial,
                               pr_regfim   => vr_auxfinal,
                               pr_datainic => pr_datainic,
                               pr_datafina => pr_datafina) LOOP

        IF rw_thap.idtipo_envio = 1 THEN
           -- Envio de forma automática
           vr_tipo_envio := 'A';
        ELSE
           -- Envio de forma manual
           vr_tipo_envio := 'M';
        END IF;

        -- Consulta as informações

        GENE0007.pc_insere_tag(pr_xml       => pr_retxml
                               ,pr_tag_pai  => 'Dados'
                               ,pr_posicao  =>  0
                               ,pr_tag_nova => 'registro'
                               ,pr_tag_cont => NULL
                               ,pr_des_erro => vr_dscritic);


        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'registro'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdcooper'
                              ,pr_tag_cont => rw_thap.cdcooper
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'registro'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'nrdconta'
                              ,pr_tag_cont => rw_thap.nrdconta
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'registro'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'nrctremp'
                              ,pr_tag_cont => rw_thap.nrctremp
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'registro'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dataEnvio'
                              ,pr_tag_cont => rw_thap.dthistreg
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'registro'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'codMotivo'
                              ,pr_tag_cont => rw_thap.cdmotivo
                              ,pr_des_erro => vr_dscritic);


        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'registro'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsMotivo'
                              ,pr_tag_cont => rw_thap.dsmotivo
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'registro'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'tipoEnvio'
                              ,pr_tag_cont => vr_tipo_envio
                              ,pr_des_erro => vr_dscritic);

         vr_auxconta := vr_auxconta + 1;

       END LOOP;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'RgInicio'
                            ,pr_tag_cont => vr_auxinicial
                            ,pr_des_erro => vr_dscritic);


      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'TmPagina'
                            ,pr_tag_cont => vr_nrlinhas
                            ,pr_des_erro => vr_dscritic);


      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'QtRegist'
                            ,pr_tag_cont => vr_RegTotal
                            ,pr_des_erro => vr_dscritic);

      EXCEPTION
        WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_erro := 'NOK';

        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em consultar operacao. ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

    END  pc_consulta_historico;

    PROCEDURE pc_busca_motivos_probl(pr_tipo      IN VARCHAR2
                                     ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

   Programa : pc_busca_motivos_probl                           
    Sistema  : Ativos Problematicos
    Sigla    : ATVPRB
    Autor    : Rangel Decker
    Data     : Marco/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia:  Sempre que for chamado
    Objetivo   : Pesquisa de motivos de ativos problematicos para cadastro.

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

   CURSOR cr_tbmtv IS
   SELECT 'M' tipo,
           tbmtv.idmotivo cdmotivo,
           tbmtv.dsmotivo
    FROM   tbgen_motivo tbmtv
    WHERE  tbmtv.cdproduto = 42
    AND     tbmtv.idmotivo in(60,62,63,64,65) -- Manuais
    UNION
    SELECT 'T' tipo,   -- Todos
           tbmtv.idmotivo cdmotivo,
           tbmtv.dsmotivo
    FROM   tbgen_motivo tbmtv
    WHERE  tbmtv.cdproduto = 42;

     -- Variável de críticas
     vr_exc_erro  EXCEPTION;
     vr_cdcritic  INTEGER;
     vr_dscritic  VARCHAR2(1000);

     -- Variaveis auxiliares
     vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

   BEGIN

     -- Criar cabecalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

    FOR rw_tbmtv IN cr_tbmtv LOOP


      IF pr_tipo =rw_tbmtv.tipo THEN
        -- Carrega os dados
         gene0007.pc_insere_tag(pr_xml       => pr_retxml
                               ,pr_tag_pai  => 'Dados'
                               ,pr_posicao  =>  0
                               ,pr_tag_nova => 'registro'
                               ,pr_tag_cont => NULL
                               ,pr_des_erro => vr_dscritic);



          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'registro'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'cdmotivo'
                                ,pr_tag_cont => rw_tbmtv.cdmotivo
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'registro'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dsmotivo'
                                ,pr_tag_cont =>  rw_tbmtv.dsmotivo
                                ,pr_des_erro => vr_dscritic);

         vr_auxconta := vr_auxconta + 1;
     END IF;

    END LOOP;

    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);




    EXCEPTION
    WHEN OTHERS THEN   BEGIN

     pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_motivo --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||pr_dscritic ||'<Root><Erro></Erro></Root>');

    END;

  END pc_busca_motivos_probl;
END TELA_ATVPRB;
/