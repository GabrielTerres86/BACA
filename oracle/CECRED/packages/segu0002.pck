CREATE OR REPLACE PACKAGE CECRED.SEGU0002 AS


  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : SEGU0002
  --  Sistema  : Procedimentos para Seguros
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - Supero
  --  Data     : Junho/2016.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para integração de Seguros via WS
  --
  ---------------------------------------------------------------------------------------------------------------
 
  /* Retornar a lista de possíveis titulares e dependentes para contratação de seguro */
  PROCEDURE pc_ws_busca_dados_coop (pr_dsusuari  IN VARCHAR2              --> Código do usuário da requisição
                                   ,pr_dsdsenha  IN VARCHAR2              --> Código do usuário da requisição
                                   ,pr_idparcei  IN NUMBER                --> Código do Parceiro a enviar as informações de Seguro
                                   ,pr_cdagecop  IN crapcop.cdagectl%TYPE --> Código da agência da Cooperativa na central 
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da conta para contratação do seguro
                                   ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK
  
  /* Adicionar informação de novo seguro ao Ayllos */
  PROCEDURE pc_ws_add_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Código do usuário da requisição
                                     ,pr_dsdsenha            IN VARCHAR2              --> Código do usuário da requisição
                                     ,pr_idparcei            IN NUMBER                --> Código do Parceiro a enviar as informações de Seguro
                                     ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Código da agência da Cooperativa na central 
                                     ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratação do seguro
                                     
                                     ,pr_nrproposta          IN VARCHAR2 --> Número da proposta do seguro
                                     ,pr_nrapolice           IN VARCHAR2 --> Número da apólice de seguro
                                     ,pr_nmsegurado          IN VARCHAR2 --> Nome do segurado do seguro
                                     ,pr_nrcpfcnpj_segurado  IN VARCHAR2 --> Número do CPF ou CNPJ do segurado do seguro
                                     ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro contratado
                                     ,pr_dtinivigen          IN VARCHAR2 --> Data de início da vigência do contrato
                                     ,pr_dtfimvigen          IN VARCHAR2 --> Data de término da vigência do contrato
                                     ,pr_vlcapital_franquia  IN VARCHAR2 --> Valor de capital ou franquia do contrato
                                     ,pr_dsplano             IN VARCHAR2 --> Descritivo do plano contratado
                                     ,pr_vltot_premio_liquid IN VARCHAR2 --> Valor do prêmio líquido contratado
                                     ,pr_vltot_premio        IN VARCHAR2 --> Valor do prêmio contratado
                                     ,pr_qtparcelas          IN VARCHAR2 --> Quantidade de parcelas para pagamento do seguro
                                     ,pr_vlparcelas          IN VARCHAR2 --> Valor das parcelas para pagamento do seguro
                                     ,pr_dtdebito            IN VARCHAR2 --> Dia de débito das parcelas para pagamento do seguro
                                     ,pr_cdsitseguro         IN VARCHAR2 --> Código da situação do seguro
                                     ,pr_cdsegura            IN VARCHAR2 --> Código da seguradora vinculada ao seguro
                                     ,pr_comissao            IN VARCHAR2 --> Valor da comissão do contrato
                                     ,pr_dsobserva           IN VARCHAR2 --> Descrição da observação do contrato
                                     ,pr_array_benef         IN VARCHAR2 -->  Array com informações dos beneficiários do seguro
                                     
                                     ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);         -->  Saida OK/NOK
  
  /* Efetuar endosso de seguro existente no Ayllos */
  PROCEDURE pc_ws_end_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Codigo do usuario da requisicao
                                     ,pr_dsdsenha            IN VARCHAR2              --> Codigo do usuario da requisicao
                                     ,pr_idparcei            IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                     ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                     ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                     
                                     ,pr_nrproposta          IN VARCHAR2 --> Número da proposta do seguro
                                     ,pr_nrapolice           IN VARCHAR2 --> Número da apolice de seguro
                                     ,pr_nrendosso           IN VARCHAR2 --> Número do endosso do seguro
                                     ,pr_nmsegurado          IN VARCHAR2 --> Nome do segurado do seguro
                                     ,pr_nrcpfcnpj_segurado  IN VARCHAR2 --> Número do CPF ou CNPJ do segurado do seguro
                                     ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro contratado
                                     ,pr_dtinivigen          IN VARCHAR2 --> Data de início da vigência do contrato
                                     ,pr_dtfimvigen          IN VARCHAR2 --> Data de término da vigência do contrato
                                     ,pr_vlcapital_franquia  IN VARCHAR2 --> Valor de capital ou franquia do contrato
                                     ,pr_dsplano             IN VARCHAR2 --> Descritivo do plano contratado
                                     ,pr_vltot_premio_liquid IN VARCHAR2 --> Valor do prêmio líquido contratado
                                     ,pr_vltot_premio        IN VARCHAR2 --> Valor do prêmio contratado
                                     ,pr_qtparcelas          IN VARCHAR2 --> Quantidade de parcelas para pagamento do seguro
                                     ,pr_vlparcelas          IN VARCHAR2 --> Valor das parcelas para pagamento do seguro
                                     ,pr_dtdebito            IN VARCHAR2 --> Dia de débito das parcelas para pagamento do seguro
                                     ,pr_cdsitseguro         IN VARCHAR2 --> Codigo da situacao do seguro
                                     ,pr_comissao            IN VARCHAR2 --> Valor da comissao do contrato
                                     ,pr_dsobserva           IN VARCHAR2 --> Descricao da observacao do contrato
                                     ,pr_array_benef         IN VARCHAR2 -->  Array com informacoes dos beneficiarios do seguro
                                     
                                     ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da crítica
                                     ,pr_dscritic OUT VARCHAR2           --> Descricao da crítica
                                     ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);         -->  Saida OK/NOK
  
  /* Efetuar endosso de seguro existente no Ayllos */
  PROCEDURE pc_ws_canc_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Codigo do usuario da requisicao
                                      ,pr_dsdsenha            IN VARCHAR2              --> Codigo do usuario da requisicao
                                      ,pr_idparcei            IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                      ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                      ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                      
                                      ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro contratado
                                      ,pr_nrapolice           IN VARCHAR2 --> Número da apolice de seguro
                                      ,pr_nrendosso           IN VARCHAR2 --> Número do endosso do seguro
                                      ,pr_dtfimvigen          IN VARCHAR2 --> Data de término da vigência do contrato
                                      ,pr_dsobserva           IN VARCHAR2 --> Descricao da observacao do contrato
                                      
                                      ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da crítica
                                      ,pr_dscritic OUT VARCHAR2           --> Descricao da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);         -->  Saida OK/NOK
  
  /* Efetuar renovação de seguro existente no Ayllos */
  PROCEDURE pc_ws_reno_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Código do usuário da requisição
                                      ,pr_dsdsenha            IN VARCHAR2              --> Código do usuário da requisição
                                      ,pr_idparcei            IN NUMBER                --> Código do Parceiro a enviar as informações de Seguro
                                      ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Código da agência da Cooperativa na central 
                                      ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratação do seguro
                                      
                                      ,pr_nrproposta          IN VARCHAR2 --> Número da proposta do seguro
                                      ,pr_nrapolice           IN VARCHAR2 --> Número da apólice de seguro
                                      ,pr_nrapolice_anterior  IN VARCHAR2 --> Número da apólice anterior de seguro
                                      ,pr_nrendosso           IN VARCHAR2 --> Número do endosso do seguro
                                      ,pr_nmsegurado          IN VARCHAR2 --> Nome do segurado do seguro
                                      ,pr_nrcpfcnpj_segurado  IN VARCHAR2 --> Número do CPF ou CNPJ do segurado do seguro
                                      ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro renovado
                                      ,pr_dtinivigen          IN VARCHAR2 --> Data de início da vigência do contrato
                                      ,pr_dtfimvigen          IN VARCHAR2 --> Data de término da vigência do contrato
                                      ,pr_vlcapital_franquia  IN VARCHAR2 --> Valor de capital ou franquia do contrato
                                      ,pr_dsplano             IN VARCHAR2 --> Descritivo do plano contratado
                                      ,pr_vltot_premio_liquid IN VARCHAR2 --> Valor do prêmio líquido contratado
                                      ,pr_vltot_premio        IN VARCHAR2 --> Valor do prêmio contratado
                                      ,pr_qtparcelas          IN VARCHAR2 --> Quantidade de parcelas para pagamento do seguro
                                      ,pr_vlparcelas          IN VARCHAR2 --> Valor das parcelas para pagamento do seguro
                                      ,pr_dtdebito            IN VARCHAR2 --> Dia de débito das parcelas para pagamento do seguro
                                      ,pr_cdsegura            IN VARCHAR2 --> Código da seguradora vinculada ao seguro
                                      ,pr_comissao            IN VARCHAR2 --> Valor da comissão do contrato
                                      ,pr_dsobserva           IN VARCHAR2 --> Descrição da observação do contrato
                                      ,pr_array_benef         IN VARCHAR2 -->  Array com informações dos beneficiários do seguro            -->  Array com informações dos beneficiários do seguro
                                      
                                      ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);         -->  Saida OK/NOK
  
  /* Efetuar vencimento de seguro existente no Ayllos */
  PROCEDURE pc_ws_venc_contrato_seguro(pr_dsusuari  IN VARCHAR2              --> Código do usuário da requisição
                                      ,pr_dsdsenha  IN VARCHAR2              --> Código do usuário da requisição
                                      ,pr_idparcei  IN NUMBER                --> Código do Parceiro a enviar as informações de Seguro
                                      ,pr_cdagecop  IN crapcop.cdagectl%TYPE --> Código da agência da Cooperativa na central 
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da conta para contratação do seguro
                                      
                                      ,pr_tpseguro  IN VARCHAR2 --> Tipo do seguro contratado
                                      ,pr_nrapolice IN VARCHAR2 --> Número da apólice de seguro
                                      ,pr_dsobserva IN VARCHAR2 --> Descrição da observação do contrato
                                    
                                      ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);         -->  Saida OK/NOK
  


END SEGU0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.SEGU0002 AS

  /*-------------------------------------------------------------------------------------------------------------
  
    Programa : SEGU0002
    Sistema  : Procedimentos para Seguros
    Sigla    : CRED
    Autor    : Marcos Martini - Supero
    Data     : Junho/2016.                
  
   Frequencia: -----                                                        Última alteração: 18/04/2017
   Objetivo  : Procedimentos para integracao de Seguros via WS
  
   Alterações: 18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).


  -------------------------------------------------------------------------------------------------------------*/
  
  /* Busca da Cooperativa conforme cdagectl */
  CURSOR cr_crapcop(pr_cdagectl crapcop.cdagectl%TYPE) IS
    SELECT cdcooper
      FROM crapcop
     WHERE cdagectl = pr_cdagectl
       AND flgativo = 1   --> Somente ativas
       AND cdcooper <> 3; --> Nao considerar a central
  rw_crapcop cr_crapcop%ROWTYPE;     
  
  /* Busca dados do cooperado */
  CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT nmprimtl
          ,cdagenci
          ,nrcpfcgc
          ,inpessoa
          ,dtnasctl
      FROM crapass
     WHERE cdcooper = pr_cdcooper 
       AND nrdconta = pr_nrdconta
       AND dtdemiss IS NULL; --> Nao podem ser demitidos                 
  rw_crapass cr_crapass%ROWTYPE;
  
  /* Verificar se apolice anterior ja existe */
  CURSOR cr_tbseg_contratos(pr_cdcooper crapcop.cdcooper%TYPE
                           ,pr_nrdconta crapass.nrdconta%TYPE
                           ,pr_tpseguro tbseg_contratos.tpseguro%TYPE
                           ,pr_nrapolic tbseg_contratos.nrapolice%TYPE
                           ,pr_indsitua tbseg_contratos.indsituacao%TYPE DEFAULT NULL) IS
    SELECT idcontrato
      FROM tbseg_contratos
     WHERE cdcooper  = pr_cdcooper /* Cooperativa da requisicao */
       AND nrdconta  = pr_nrdconta /* Oriunda da requisicao */
       AND tpseguro  = pr_tpseguro /* Tipo do Seguro */
       AND nrApolice = pr_nrApolic /* Oriunda da requisicao */
       AND indsituacao = nvl(pr_indsitua,indsituacao);  /* Somente comparar se enviada */
  rw_tbseg cr_tbseg_contratos%ROWTYPE;     
  
  /* Novo procedimento que efetua as validacoes basicas a partir das requisicoes via WS de Seguros */
  PROCEDURE pc_valida_requisi_wsseguros (pr_dsusuari IN VARCHAR2               --> Codigo do usuario da requisicao
                                        ,pr_dsdsenha IN VARCHAR2               --> Codigo do usuario da requisicao
                                        ,pr_idparcei IN NUMBER                 --> Codigo do Parceiro a enviar as informacoes de Seguro
                                        ,pr_cdagecop IN crapcop.cdagectl%TYPE  --> Codigo da agência da Cooperativa na central 
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da conta para contratacao do seguro
                                        ,pr_cdcooper OUT crapcop.cdcooper%TYPE --> Cooperativa ref ao cdagecop
                                        ,pr_cdretorn OUT NUMBER                --> Codigo de retorno
                                        ,pr_dsmsgret OUT VARCHAR2) IS          --> Descricao do erro
  BEGIN
    /* .............................................................................

       Programa: pc_valida_requisi_wsseguros
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que efetua as validacoes basicas a 
                   partir das requisicoes via WS de Seguros

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Chaves de acesso
      vr_chavecli VARCHAR2(200);
      vr_chavereq VARCHAR2(200);
      -- Validacao de sistema parceiro
      CURSOR cr_parceiro IS
        SELECT 1
          FROM tbseg_parceiro par
         WHERE par.cdparceiro = pr_idparcei -- Oriundo da requisicao
           AND par.flgativo   = 1;         -- Somente ativos;
      vr_inachou NUMBER;   
      -- Calendario
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;    
    BEGIN
      -- Primeiramente vamos verificar se a chave de acesso esta de acordo com o usuario 
      -- e senha recebidos da requisicao ao WebService, como as credenciais de acesso 
      -- estarao armazenadas criptografa em Base64, devemos montar o conjunto usuario:senha 
      -- para comparacao: 
      --'d3NzZWd1cm9zOlVIZGtRMlZqY21Wa1YxTlRaV2N5TURFMg==';
      vr_chavecli := utl_encode.text_encode(pr_dsusuari || ':' || pr_dsdsenha
                                           ,'WE8ISO8859P1', UTL_ENCODE.BASE64);
      
      -- Retornar o parâmetro de sistema com as credencias aceitas:
      vr_chavereq := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'CHAVE_WS_SEGUROS');

      -- Retornar erro 401 caso a string montada seja diferente da parametrizada:
      IF vr_chavecli <> vr_chavereq THEN
        PR_CDRETORN := 401;
        PR_DSMSGRET := 'Credenciais de acesso invalidas.';
        RETURN;
      END IF;
      
      -- Validar o sistema parceiro recebido:
      vr_inachou := 0;
      OPEN cr_parceiro;
      FETCH cr_parceiro
       INTO vr_inachou;      
      -- Nao existindo
      IF cr_parceiro%NOTFOUND THEN
        -- Retornar erro e sair da rotina
        CLOSE cr_parceiro;
        pr_cdretorn := 402;
        pr_dsmsgret := 'Campo idParceiro invalido. Sistema parceiro inexistente ou inativo.';
        RETURN;
      ELSE
        CLOSE cr_parceiro;
      END IF;  
      
      -- Validar agência (cooperativa) enviada
      OPEN cr_crapcop(pr_cdagectl => pr_cdagecop);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Nao existindo
      IF cr_crapcop%NOTFOUND THEN
        -- Retornar erro e sair da rotina
        CLOSE cr_crapcop;
        pr_cdretorn := 402;
        pr_dsmsgret := 'Campo cdAgeCoop invalido. Agencia inexistente ou inativa';
        RETURN;
      ELSE
        CLOSE cr_crapcop;
      END IF;   
      
      -- Retornar a cooperativa
      pr_cdcooper := rw_crapcop.cdcooper;
      
      -- Apos encontrar a cooperativa solicitada, devemos verificar se a mesma 
      -- esta com o processo em execucao, através de busca na CRAPDAT:
      OPEN btch0001.cr_crapdat(rw_crapcop.cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      
      -- Se processo em execucao
      IF rw_crapdat.inproces > 1 THEN
        pr_cdretorn := 403;
        pr_dsmsgret := 'Processo em execucao – integracao nao permitida.';
        RETURN;
      END IF;
      
      -- Passadas as validacoes iniciais, devemos garantir a existência 
      -- do Cooperado através de consulta na CRAPASS:
      OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass
       INTO rw_crapass;
      -- Nao existindo
      IF cr_crapass%NOTFOUND THEN
        -- Retornar erro e sair da rotina
        CLOSE cr_crapass;
        pr_cdretorn := 402;
        pr_dsmsgret := 'Campo nrConta invalido. Conta inexistente ou inativa';
        RETURN;
      ELSE
        CLOSE cr_crapass;
      END IF;  
      
      -- Chegado ao final, apos o sucesso em todos os testes, retornaremos o sucesso:
      pr_cdretorn := 202; 
      pr_dsmsgret := 'OK';

    EXCEPTION
       WHEN OTHERS THEN
         pr_cdretorn := 402;
         pr_dsmsgret := 'SEGU0002.pc_valida_requisi_wsseguros - Erro nao tratado: ' || SQLERRM;
    END;
  END pc_valida_requisi_wsseguros; 
  
    /* Validacao de informacao recebida e obrigatória */
  PROCEDURE pc_valida_obrigatorio(pr_dstxtval IN VARCHAR2      --> Valor a ser convertido
                                 ,pr_nmdcampo IN VARCHAR2      --> Nome do campo
                                 ,pr_cdretorn OUT NUMBER       --> Codigo de retorno
                                 ,pr_dsmsgret OUT VARCHAR2) IS --> Descricao do erro
  /* .............................................................................

       Programa: pc_valida_obrigatorio
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que validará se o campo é obrigatório ou não

       Alteracoes:

    ..............................................................................*/
  BEGIN  
    BEGIN
      -- Gerar erro quando campo não recebido
      IF TRIM(pr_dstxtval) IS NULL THEN
        pr_cdretorn := 402;
        pr_dsmsgret := 'Campo '||pr_nmdcampo||' eh obrigatorio.';
        RETURN;
      END IF;      
      -- Sucesso na checagem
      pr_cdretorn := 202;  
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno padrao
        pr_cdretorn := 402;
        pr_dsmsgret := 'Campo '||pr_nmdcampo||' eh obrigatorio.';
    END;
  END pc_valida_obrigatorio;   
  
  /* Validacao de informacao recebida como texto a ser convertida para valor/quantidade */
  PROCEDURE pc_valida_char_para_valor(pr_dstxtval IN VARCHAR2      --> Valor a ser convertido
                                     ,pr_nmdcampo IN VARCHAR2      --> Nome do campo
                                     ,pr_flobriga IN VARCHAR2      --> Obrigatório ou não
                                     ,pr_nrvalcnv OUT NUMBER       --> Valor convertido
                                     ,pr_cdretorn OUT NUMBER       --> Codigo de retorno
                                     ,pr_dsmsgret OUT VARCHAR2) IS --> Descricao do erro
  /* .............................................................................

       Programa: pc_valida_char_para_valor
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que efetuara a conversao do campo para valor/quantidade
                   e retornara erro montado em caso de problema

       Alteracoes:

    ..............................................................................*/
  BEGIN  
    BEGIN
      -- Testar obrigatoriedade
      IF pr_flobriga = 'S' THEN
        -- Direcionar a rotina de checagem
        pc_valida_obrigatorio(pr_dstxtval,pr_nmdcampo,pr_cdretorn,pr_dsmsgret);
        -- Retornar em caso de erro
        IF pr_cdretorn <> 202 THEN
          RETURN;
        END IF;
      END IF;
      -- Chamar rotina para conversão respeitando separadores decimais e unidade
      pr_nrvalcnv := gene0002.fn_char_para_number(pr_dsnumtex => pr_dstxtval);
      -- Se existia valor e a conversão retornou null, houve erro
      IF pr_dstxtval IS NOT NULL AND pr_nrvalcnv IS NULL THEN
        pr_cdretorn := 402;
        pr_dsmsgret := 'Campo '||pr_nmdcampo||' nao eh um valor valido';
      ELSE
        -- Sucesso na conversao
        pr_cdretorn := 202;  
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno padrao
        pr_cdretorn := 402;
        pr_dsmsgret := 'Campo '||pr_nmdcampo||' nao eh um valor valido';
    END;
  END pc_valida_char_para_valor;   
  
  /* Validacao de informacao recebida como texto a ser convertida para numero */
  PROCEDURE pc_valida_char_para_numero(pr_dstxtval IN VARCHAR2      --> Valor a ser convertido
                                      ,pr_nmdcampo IN VARCHAR2      --> Nome do campo
                                      ,pr_flobriga IN VARCHAR2      --> Obrigatório ou não
                                      ,pr_nrvalcnv OUT NUMBER       --> Valor convertido
                                      ,pr_cdretorn OUT NUMBER       --> Codigo de retorno
                                      ,pr_dsmsgret OUT VARCHAR2) IS --> Descricao do erro
  /* .............................................................................

       Programa: pc_valida_char_para_numero
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que efetuara a conversao do campo para numero
                   e retornara erro montado em caso de problema

       Alteracoes:

    ..............................................................................*/
  BEGIN  
    DECLARE
      vr_txtnumber VARCHAR2(1000);
    BEGIN
      -- Testar obrigatoriedade
      IF pr_flobriga = 'S' THEN
        -- Direcionar a rotina de checagem
        pc_valida_obrigatorio(pr_dstxtval,pr_nmdcampo,pr_cdretorn,pr_dsmsgret);
        -- Retornar em caso de erro
        IF pr_cdretorn <> 202 THEN
          RETURN;
        END IF;
      END IF;
      -- Primeiramente substituimos todos caracteres , . / e -
      vr_txtnumber := REPLACE(REPLACE(REPLACE(REPLACE(pr_dstxtval,',',''),'.',''),'/',''),'-','');
      -- Efetuar conversao para number
      pr_nrvalcnv := to_number(vr_txtnumber);
      -- Sucesso na conversao
      pr_cdretorn := 202;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno padrao
        pr_cdretorn := 402;
        pr_dsmsgret := 'Campo '||pr_nmdcampo||' nao eh um numerico valido';
    END;
  END pc_valida_char_para_numero; 
  
  /* Validacao de informacao recebida como texto a ser convertida para number */
  PROCEDURE pc_valida_char_para_date(pr_dstxtval IN VARCHAR2      --> Valor a ser convertido
                                    ,pr_nmdcampo IN VARCHAR2      --> Nome do campo
                                    ,pr_flobriga IN VARCHAR2      --> Obrigatório ou não
                                    ,pr_dtvalcnv OUT DATE         --> Valor convertido
                                    ,pr_cdretorn OUT NUMBER       --> Codigo de retorno
                                    ,pr_dsmsgret OUT VARCHAR2) IS --> Descricao do erro
  /* .............................................................................

       Programa: pc_valida_char_para_date
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que efetuara a conversao do campo para Data
                   e retornara erro montado em caso de problema

       Alteracoes:

    ..............................................................................*/

    vr_exception EXCEPTION;
    
  BEGIN  
    
    BEGIN
      -- Testar obrigatoriedade
      IF pr_flobriga = 'S' THEN
        -- Direcionar a rotina de checagem
        pc_valida_obrigatorio(pr_dstxtval,pr_nmdcampo,pr_cdretorn,pr_dsmsgret);
        -- Retornar em caso de erro
        IF pr_cdretorn <> 202 THEN
          RETURN;
        END IF;
      END IF;
      -- Efetuar conversao para number
      pr_dtvalcnv := to_date(pr_dstxtval,'dd/mm/rrrr');
      IF pr_dstxtval IS NULL THEN
         RAISE vr_exception;
      END IF;
      -- Sucesso na conversao
      pr_cdretorn := 202;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno padrao
        pr_cdretorn := 402;
        pr_dsmsgret := 'Campo '||pr_nmdcampo||' nao e uma data valida';
    END;
  END pc_valida_char_para_date;
  
  /* Validacao da seguradora enviada */
  PROCEDURE pc_valida_seguradora(pr_cdcooper IN  crapcop.cdcooper%TYPE         --> Coop da requisicao
                                ,pr_cdsegura IN  tbseg_contratos.cdsegura%TYPE --> Seguradora da requisicao
                                ,pr_cdretorn OUT NUMBER       --> Codigo de retorno
                                ,pr_dsmsgret OUT VARCHAR2) IS --> Descricao do erro
  /* .............................................................................

       Programa: pc_valida_seguradora
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que efetuara a validacao da seguradora informada

       Alteracoes:

    ..............................................................................*/
  BEGIN  
    DECLARE
      CURSOR cr_segura IS
        SELECT 1
          FROM crapcsg
         WHERE cdcooper = pr_cdcooper /* Cooperativa da requisicao */
           AND cdsegura = pr_cdSegura /* Oriunda da requisicao */
           AND flgativo = 1; /* Somente ativas */
      vr_flgexis NUMBER;     
    BEGIN
      -- Verificar se a seguradora é valida
      OPEN cr_segura;
      FETCH cr_segura
       INTO vr_flgexis;
      -- Se nao for encontrado registro
      IF cr_segura%NOTFOUND THEN
        CLOSE cr_segura;
        --Retornar erro conforme: 
        pr_cdretorn := 402;
        pr_dsmsgret := 'Campo cdSegura invalido. Seguradora inexistente ou inativa.';        
      ELSE
        CLOSE cr_segura;
        -- Sucesso na verificacao
        pr_cdretorn := 202;  
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno padrao
        pr_cdretorn := 402;
        pr_dsmsgret := 'Campo cdSegura nao e um numero valido: '||SQLERRM;
    END;
  END pc_valida_seguradora;  
  
  
  /* Nova funcao que efetuara a criacao do retorno XML para a requisicao do WS. */
  PROCEDURE pc_monta_retorno_ws (pr_cdretorn IN NUMBER                  --> Codigo de retorno
                                ,pr_dsmsgret IN VARCHAR2                --> Texto
                                ,pr_dsxmlret IN OUT NOCOPY XmlType) IS  --> XML de retorno da requisicao
  BEGIN
    /* .............................................................................

       Programa: pc_monta_retorno_ws
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que efetuara a criacao 
                   do retorno XML para a requisicao do WS. 

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Tratamento de erro
      vr_des_erro VARCHAR2(4000);
    BEGIN
      -- Primeiramente criaremos o XmlType
      pr_dsxmlret := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      -- Apos adicionaremos a tag Root as tags idStatus e msgDetalhe:
      gene0007.pc_insere_tag(pr_xml => pr_dsxmlret
                            ,pr_tag_pai => 'Root'
                            ,pr_posicao => 0
                            ,pr_tag_nova => 'idStatus'
                            ,pr_tag_cont => pr_cdretorn 
                            ,pr_des_erro => vr_des_erro);
      gene0007.pc_insere_tag(pr_xml => pr_dsxmlret
                            ,pr_tag_pai => 'Root'
                            ,pr_posicao => 0
                            ,pr_tag_nova => 'msgDetalhe'
                            ,pr_tag_cont => pr_dsmsgret  
                            ,pr_des_erro => vr_des_erro);
    EXCEPTION
      WHEN OTHERS THEN
        -- criar XML com erro tratado
        pr_dsxmlret := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
        -- Apos adicionaremos na tag Root as tags idStatus e msgDetalhe o erro capturado:
        gene0007.pc_insere_tag(pr_xml => pr_dsxmlret
                              ,pr_tag_pai => 'Root'
                              ,pr_posicao => 0
                              ,pr_tag_nova => 'idStatus'
                              ,pr_tag_cont => 402 
                              ,pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_dsxmlret
                              ,pr_tag_pai => 'Root'
                              ,pr_posicao => 0
                              ,pr_tag_nova => 'msgDetalhe'
                              ,pr_tag_cont => 'segu0002.pc_monta_retorno_ws - Erro nao tratado -> '||sqlerrm  
                              ,pr_des_erro => vr_des_erro);

    END;
  END pc_monta_retorno_ws; 
  
  /* Retornar a lista de possíveis titulares e dependentes para contratacao de seguro */
  PROCEDURE pc_busca_dados_cooperado (pr_dsusuari IN VARCHAR2              --> Codigo do usuario da requisicao
                                     ,pr_dsdsenha IN VARCHAR2              --> Codigo do usuario da requisicao
                                     ,pr_idparcei IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                     ,pr_cdagecop IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                     ,pr_dsxmlret OUT NOCOPY XmlType) IS   --> XML de retorno da requisicao)
  BEGIN
    /* .............................................................................

       Programa: pc_busca_dados_cooperado
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao: 24/07/2017

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que recebera Agencia da Cooperativa e Conta
                   e retornar a lista de possíveis titulares e dependentes para 
                   contratacao de seguro.

       Alteracoes: 10/10/2016 - P333.1 - Inclusao da TAG de pessoa politicamente exposta
                                e dos outros rendimentos ao salário dos associados (Marcos-Supero)

				   18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                    crapass, crapttl, crapjur 
							   (Adriano - P339).

                   24/07/2017 - Removido cdoedptl campo nao utilizado.
                                PRJ339-CRM  (Odirlei-AMcom)             

    ..............................................................................*/
    DECLARE
      -- Cooperativa
      vr_cdcooper crapcop.cdcooper%TYPE;
      -- COntadores
      vr_qtdtitular NUMBER;
      vr_qtddepend  NUMBER;
      -- Testes de retorno de rotinas
      vr_cdretorn NUMBER;
      vr_dsmsgret VARCHAR2(2000);
      vr_des_erro VARCHAR2(4000);
      -- Devemos buscar os dados do cadastro de titulares, com busca na CRAPTTL:
      CURSOR cr_crapttl(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT idseqttl
              ,gene0002.fn_mask_cpf_cnpj(nrcpfcgc,1) nrcpfcgc
              ,nmextttl
              ,decode(cdgraupr,0,'T',6,'O',2,'P',3,'F','C') cdgraupr
              ,tpdocttl
              ,nrdocttl
              ,to_char(dtemdttl,'dd/mm/rrrr') dtemdttl
              ,decode(cdestcvl,12,'U',1,'S',7,'D',6,'P',5,'V','C') cdestcvl
              ,to_char(dtnasttl,'dd/mm/rrrr') dtnasttl
              ,cdsexotl
              ,nvl(trim(dsproftl),'-') dsproftl
              ,vlsalari + vldrendi##1 + vldrendi##2 + vldrendi##3
                        + vldrendi##4 + vldrendi##5 + vldrendi##6 vlsalari
              ,inpolexp
          FROM crapttl 
         WHERE cdcooper = pr_cdcooper 
           AND nrdconta = pr_nrdconta --> Oriundo da requisicao
         ORDER BY idseqttl;
      
      -- BUsca dados de conjugue
      CURSOR cr_crapcje(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_idseqttl crapttl.idseqttl%TYPE) IS 
       SELECT nrctacje
             ,nmconjug
             ,nrcpfcjg
             ,dtnasccj
         FROM crapcje 
        WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta
          AND idseqttl = pr_idseqttl;
      rw_crapcje cr_crapcje%ROWTYPE;
         
      -- Busca de endereco
      CURSOR cr_crapenc(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_tpendass crapenc.tpendass%TYPE
                       ,pr_idseqttl crapttl.idseqttl%TYPE) IS                       
        SELECT dsendere||decode(nrendere,0,NULL,', '||nrendere)||decode(complend,' ',NULL,', '||complend)  dsendere
              ,nmbairro
              ,nmcidade
              ,cdufende
              ,nrcepend
          FROM crapenc
         WHERE cdcooper = pr_cdcooper --> Encontrado acima
           AND nrdconta = pr_nrdconta --> Oriunda da requisicao
           AND idseqttl = pr_idseqttl --> Encontrado no loop da TTL
           AND tpendass = pr_tpendass;--> 09 - Comercial e 10-Residencial
      rw_crapenc cr_crapenc%ROWTYPE;

      -- Busca de telefone
      CURSOR cr_craptfc(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_tptelefo craptfc.tptelefo%TYPE
                       ,pr_idseqttl crapttl.idseqttl%TYPE) IS
        SELECT nrdddtfc
              ,nrtelefo
          FROM craptfc
         WHERE cdcooper = pr_cdcooper --> Encontrado acima
           AND nrdconta = pr_nrdconta --> Oriunda da requisicao
           AND tptelefo = nvl(pr_tptelefo,tptelefo) --> Pode ou não vir 
           AND idseqttl = pr_idseqttl --> Encontrado no loop da TTL
         ORDER BY tptelefo;           --> Ordernar por Residencial, Celular, Comercial e Contato
      rw_craptfc cr_craptfc%ROWTYPE;      
      
      -- Busca dos dependentes
      CURSOR cr_crapdep(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT nmdepend
              ,to_char(dtnascto,'dd/mm/rrrr') dtnascto
              ,decode(tpdepend,1,'C',2,'C',3,'F',4,'F','P') tpdepend
          FROM crapdep 
         WHERE cdcooper = pr_cdcooper  --> Encontrado acima
           AND nrdconta = pr_nrdconta --> Oriundo da requisicao
           AND tpdepend IN(1,2,3,4,9); -- Conjuge, Companheiro, Filho, Enteado e Pais
           
      -- Busca dados de pessoa jurídica
      CURSOR cr_crapjur(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT jur.nmextttl
              ,ram.nmrmativ
          FROM crapjur jur
              ,gnrativ ram
         WHERE jur.cdcooper = pr_cdcooper
           AND jur.nrdconta = pr_nrdconta
           AND jur.cdrmativ = ram.cdrmativ;     
      rw_jur cr_crapjur%ROWTYPE;
    BEGIN
      -- Primeiramente acionaremos a rotina das validacoes basicas:
      pc_valida_requisi_wsseguros(PR_DSUSUARI => pr_dsusuari
                                 ,PR_DSDSENHA => pr_dsdsenha
                                 ,PR_IDPARCEI => pr_idparcei
                                 ,PR_CDAGECOP => pr_cdagecop
                                 ,PR_NRDCONTA => pr_nrdconta
                                 ,pr_cdcooper => vr_cdcooper
                                 ,PR_CDRETORN => vr_cdretorn
                                 ,PR_DSMSGRET => vr_dsmsgret);
      -- Se o retorno nao for codigo 202
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      -- Prosseguindo, iremos buscar o PA do Cooperado através de consulta na CRAPASS:
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass
       INTO rw_crapass;
      CLOSE cr_crapass;
      -- Iniciar a montagem da resposta com:
      pc_monta_retorno_ws(202,'OK',pr_dsxmlret); 
      -- Apos, adicionaremos a tag cdAgenci:
      gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cdAgenci'
                            ,pr_tag_cont => rw_crapass.cdagenci
                            ,pr_des_erro => vr_des_erro);
      -- Para pessoa física
      IF rw_crapass.inpessoa = 1 THEN
        -- Entao iniciamos o envio dos Titulares, criando o atributo Titulares
        -- como Array e iniciando o contador de titulares:
        vr_qtdtitular := -1;
        -- Apos, devemos buscar os dados do cadastro de titulares, com busca na CRAPTTL:
        FOR rw_ttl IN cr_crapttl(pr_cdcooper => vr_cdcooper) LOOP
          --- Para cada registro encontrado, incrementar o contador e criar novo registro no Array:
          vr_qtdtitular := vr_qtdtitular + 1;
          -- Sair se ja tivermos enviado 4 titulares
          EXIT WHEN vr_qtdtitular >= 4;
          -- Iniciar tag titular
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Root'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'Titular'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => vr_des_erro);
          -- Enviar tag nrCPF
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_qtdtitular
                                ,pr_tag_nova => 'nrCPF'
                                ,pr_tag_cont => rw_ttl.nrcpfcgc
                                ,pr_des_erro => vr_des_erro);
          
          -- Enviar tag nmTitular
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_qtdtitular
                                ,pr_tag_nova => 'nmTitular'
                                ,pr_tag_cont => rw_ttl.nmextttl
                                ,pr_des_erro => vr_des_erro);
          
          -- Enviar tag cdGrauPar
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_qtdtitular
                                ,pr_tag_nova => 'cdGrauPar'
                                ,pr_tag_cont => rw_ttl.cdgraupr
                                ,pr_des_erro => vr_des_erro);
          
          -- Enviar tag tpDocIdenti
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_qtdtitular
                                ,pr_tag_nova => 'tpDocIdenti'
                                ,pr_tag_cont => rw_ttl.tpdocttl
                                ,pr_des_erro => vr_des_erro);
          
          -- Enviar tag nrDocIdenti
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_qtdtitular
                                ,pr_tag_nova => 'nrDocIdenti'
                                ,pr_tag_cont => rw_ttl.nrdocttl
                                ,pr_des_erro => vr_des_erro);
          
          -- Enviar tag dtExpedDoc
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_qtdtitular
                                ,pr_tag_nova => 'dtExpedDoc'
                                ,pr_tag_cont => rw_ttl.dtemdttl
                                ,pr_des_erro => vr_des_erro);
          
          -- Enviar tag dsEstadoCivil
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_qtdtitular
                                ,pr_tag_nova => 'cdEstadoCivil'
                                ,pr_tag_cont => rw_ttl.cdestcvl
                                ,pr_des_erro => vr_des_erro);
          
          -- Enviar tag dtNascto
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_qtdtitular
                                ,pr_tag_nova => 'dtNascto'
                                ,pr_tag_cont => rw_ttl.dtnasttl
                                ,pr_des_erro => vr_des_erro);
          
          -- Enviar tag cdSexo
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_qtdtitular
                                ,pr_tag_nova => 'cdSexo'
                                ,pr_tag_cont => rw_ttl.cdsexotl
                                ,pr_des_erro => vr_des_erro);
          
          -- Enviar tag dsOcupacao
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_qtdtitular
                                ,pr_tag_nova => 'dsOcupacao'
                                ,pr_tag_cont => rw_ttl.dsproftl
                                ,pr_des_erro => vr_des_erro);
          
          -- Enviar tag vlSalari
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_qtdtitular
                                ,pr_tag_nova => 'vlSalari'
                                ,pr_tag_cont => rw_ttl.vlsalari
                                ,pr_des_erro => vr_des_erro);
                                
          -- Enviar tag inPolitExp
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Titular'
                                ,pr_posicao  => vr_qtdtitular
                                ,pr_tag_nova => 'inPolitExp'
                                ,pr_tag_cont => rw_ttl.inpolexp
                                ,pr_des_erro => vr_des_erro);          
          
          -- Busca do Conjugue do Titular atual
          OPEN cr_crapcje(pr_cdcooper => vr_cdcooper
                         ,pr_idseqttl => rw_ttl.idseqttl);
          FETCH cr_crapcje
           INTO rw_crapcje;
          -- Se encontrar
          IF cr_crapcje%FOUND THEN 
            CLOSE cr_crapcje;
            
            -- Se o titular está em outra conta
            IF rw_crapcje.nrctacje <> 0 THEN 
              -- Buscaremos os dados na outra conta  
              OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => rw_crapcje.nrctacje);
              FETCH cr_crapass
               INTO rw_crapass;
              CLOSE cr_crapass;
              
              -- Enviar tag nmConjuge
              gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                    ,pr_tag_pai  => 'Titular'
                                    ,pr_posicao  => vr_qtdtitular
                                    ,pr_tag_nova => 'nmConjuge'
                                    ,pr_tag_cont => rw_crapass.nmprimtl
                                    ,pr_des_erro => vr_des_erro);  
                                    
              -- Enviar tag nrCpfConjuge
              gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                    ,pr_tag_pai  => 'Titular'
                                    ,pr_posicao  => vr_qtdtitular
                                    ,pr_tag_nova => 'nrCpfConjuge'
                                    ,pr_tag_cont => rw_crapass.nrcpfcgc
                                    ,pr_des_erro => vr_des_erro); 
                                    
              -- Enviar tag dtNasctoConjuge
              gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                    ,pr_tag_pai  => 'Titular'
                                    ,pr_posicao  => vr_qtdtitular
                                    ,pr_tag_nova => 'dtNasctoConjuge'
                                    ,pr_tag_cont => to_char(rw_crapass.dtnasctl,'dd/mm/rrrr')
                                    ,pr_des_erro => vr_des_erro);
            
            ELSE -- Usar os dados da CRAPCJE mesmo 
            
              -- Enviar tag nmConjuge
              gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                    ,pr_tag_pai  => 'Titular'
                                    ,pr_posicao  => vr_qtdtitular
                                    ,pr_tag_nova => 'nmConjuge'
                                    ,pr_tag_cont => rw_crapcje.nmconjug
                                    ,pr_des_erro => vr_des_erro);  
                                    
              -- Enviar tag nrCpfConjuge
              gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                    ,pr_tag_pai  => 'Titular'
                                    ,pr_posicao  => vr_qtdtitular
                                    ,pr_tag_nova => 'nrCpfConjuge'
                                    ,pr_tag_cont => rw_crapcje.nrcpfcjg
                                    ,pr_des_erro => vr_des_erro); 
                                    
              -- Enviar tag dtNasctoConjuge
              gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                    ,pr_tag_pai  => 'Titular'
                                    ,pr_posicao  => vr_qtdtitular
                                    ,pr_tag_nova => 'dtNasctoConjuge'
                                    ,pr_tag_cont => to_char(rw_crapcje.dtnasccj,'dd/mm/rrrr')
                                    ,pr_des_erro => vr_des_erro);
            END IF;                      
          ELSE 
            CLOSE cr_crapcje;
          END IF;
          
          -- Ainda para cada registro de titular devemos buscar seu endereco:
          OPEN cr_crapenc(pr_cdcooper => vr_cdcooper
                         ,pr_tpendass => 10 -- Residencial
                         ,pr_idseqttl => rw_ttl.idseqttl);
          FETCH cr_crapenc
           INTO rw_crapenc;
          -- Se encontrar
          IF cr_crapenc%FOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapenc;
            -- -- Enviar tag dsEndere
            gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                  ,pr_tag_pai  => 'Titular'
                                  ,pr_posicao  => vr_qtdtitular
                                  ,pr_tag_nova => 'dsEndere'
                                  ,pr_tag_cont => rw_crapenc.dsendere
                                  ,pr_des_erro => vr_des_erro);

            -- Enviar tag nmBairro
            gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                  ,pr_tag_pai  => 'Titular'
                                  ,pr_posicao  => vr_qtdtitular
                                  ,pr_tag_nova => 'nmBairro'
                                  ,pr_tag_cont => rw_crapenc.nmbairro
                                  ,pr_des_erro => vr_des_erro);

            -- Enviar tag nmCidade
            gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                  ,pr_tag_pai  => 'Titular'
                                  ,pr_posicao  => vr_qtdtitular
                                  ,pr_tag_nova => 'nmCidade'
                                  ,pr_tag_cont => rw_crapenc.nmcidade
                                  ,pr_des_erro => vr_des_erro);

            -- Enviar tag cdUF
            gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                  ,pr_tag_pai  => 'Titular'
                                  ,pr_posicao  => vr_qtdtitular
                                  ,pr_tag_nova => 'cdUF'
                                  ,pr_tag_cont => rw_crapenc.cdufende
                                  ,pr_des_erro => vr_des_erro);

            -- Enviar tag nrCEP
            gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                  ,pr_tag_pai  => 'Titular'
                                  ,pr_posicao  => vr_qtdtitular
                                  ,pr_tag_nova => 'nrCEP'
                                  ,pr_tag_cont => rw_crapenc.nrcepend
                                  ,pr_des_erro => vr_des_erro);

          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapenc;
          END IF;                
          -- Para concluir a busca dos dados do titular, buscar pelo menos um telefone:
          OPEN cr_craptfc(pr_cdcooper => vr_cdcooper
                         ,pr_tptelefo => NULL
                         ,pr_idseqttl => rw_ttl.idseqttl);
          FETCH cr_craptfc
           INTO rw_craptfc;
          -- Se encontrar
          IF cr_craptfc%FOUND THEN
            -- Fechar o cursor
            CLOSE cr_craptfc;
            -- Enviar as tags abaixo (enviar apenas o primeiro registro encontrado):
            -- Enviar tag nrDDDTelefone
            gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                  ,pr_tag_pai  => 'Titular'
                                  ,pr_posicao  => vr_qtdtitular
                                  ,pr_tag_nova => 'nrDDDTelefone'
                                  ,pr_tag_cont => rw_craptfc.nrdddtfc
                                  ,pr_des_erro => vr_des_erro);

            -- Enviar tag nrTelefo
            gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                  ,pr_tag_pai  => 'Titular'
                                  ,pr_posicao  => vr_qtdtitular
                                  ,pr_tag_nova => 'nrTelefo'
                                  ,pr_tag_cont => rw_craptfc.nrtelefo
                                  ,pr_des_erro => vr_des_erro);

          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_craptfc;
          END IF;
        END LOOP; -- Fim leitura titulares
      
        -- Ao final da listagem dos titulares, também iremos retornar os possíveis dependentes da conta
        vr_qtddepend := -1;
        FOR rw_dep IN cr_crapdep(pr_cdcooper => vr_cdcooper) LOOP
          -- Em cada registro da consulta, incrementar o contador e criar 
          -- registro no array com os atributos:
          vr_qtddepend := vr_qtddepend + 1;
          
          -- registro TAG Pai "Dependente"
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Root'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'Dependente'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => vr_des_erro);          
          
          -- Enviar tag nmDepend
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Dependente'
                                ,pr_posicao  => vr_qtddepend
                                ,pr_tag_nova => 'nmDepend'
                                ,pr_tag_cont => rw_dep.nmdepend
                                ,pr_des_erro => vr_des_erro);
          
          -- Enviar tag dtNascto
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Dependente'
                                ,pr_posicao  => vr_qtddepend
                                ,pr_tag_nova => 'dtNascto'
                                ,pr_tag_cont => rw_dep.dtnascto
                                ,pr_des_erro => vr_des_erro);

          -- Enviar tag cdGrauPar
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Dependente'
                                ,pr_posicao  => vr_qtddepend
                                ,pr_tag_nova => 'cdGrauPar'
                                ,pr_tag_cont => rw_dep.tpdepend
                                ,pr_des_erro => vr_des_erro);
        END LOOP;
      ELSE -- Para pessoas jurídicas  
        -- Busca dos dados de pessoa jurírica
        OPEN cr_crapjur(pr_cdcooper => vr_cdcooper);
        FETCH cr_crapjur
         INTO rw_jur;
        CLOSE cr_crapjur;
        -- Iniciar tag Juridica
        gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Juridica'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_des_erro);
        -- Enviar tag nrCPF
        gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                              ,pr_tag_pai  => 'Juridica'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrCNPJ'
                              ,pr_tag_cont => rw_crapass.nrcpfcgc
                              ,pr_des_erro => vr_des_erro);
          
        -- Enviar tag nmTitular
        gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                              ,pr_tag_pai  => 'Juridica'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsRazaoSocial'
                              ,pr_tag_cont => rw_jur.nmextttl
                              ,pr_des_erro => vr_des_erro);
          
        -- Enviar tag cdGrauPar
        gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                              ,pr_tag_pai  => 'Juridica'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsRamoAtivid'
                              ,pr_tag_cont => rw_jur.nmrmativ
                              ,pr_des_erro => vr_des_erro);
        -- Ainda para cada registro de titular devemos buscar seu endereco:
        OPEN cr_crapenc(pr_cdcooper => vr_cdcooper        
                       ,pr_tpendass => 09 -- Comercial
                       ,pr_idseqttl => 1);
        FETCH cr_crapenc
         INTO rw_crapenc;
        -- Se encontrar
        IF cr_crapenc%FOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapenc;
          -- -- Enviar tag dsEndere
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Juridica'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'dsEndere'
                                ,pr_tag_cont => rw_crapenc.dsendere
                                ,pr_des_erro => vr_des_erro);

          -- Enviar tag nmBairro
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Juridica'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'nmBairro'
                                ,pr_tag_cont => rw_crapenc.nmbairro
                                ,pr_des_erro => vr_des_erro);

          -- Enviar tag nmCidade
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Juridica'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'nmCidade'
                                ,pr_tag_cont => rw_crapenc.nmcidade
                                ,pr_des_erro => vr_des_erro);

          -- Enviar tag cdUF
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Juridica'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'cdUF'
                                ,pr_tag_cont => rw_crapenc.cdufende
                                ,pr_des_erro => vr_des_erro);

          -- Enviar tag nrCEP
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Juridica'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'nrCEP'
                                ,pr_tag_cont => rw_crapenc.nrcepend
                                ,pr_des_erro => vr_des_erro);

        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapenc;
        END IF;                
        -- Para concluir a busca dos dados do titular, buscar pelo menos um telefone:
        OPEN cr_craptfc(pr_cdcooper => vr_cdcooper
                       ,pr_tptelefo => 3 -- Comercial
                       ,pr_idseqttl => 1);
        FETCH cr_craptfc
         INTO rw_craptfc;
        -- Se encontrar
        IF cr_craptfc%FOUND THEN
          -- Fechar o cursor
          CLOSE cr_craptfc;
          -- Enviar as tags abaixo (enviar apenas o primeiro registro encontrado):
          -- Enviar tag nrDDDTelefone
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Juridica'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'nrDDDTelefone'
                                ,pr_tag_cont => rw_craptfc.nrdddtfc
                                ,pr_des_erro => vr_des_erro);

          -- Enviar tag nrTelefo
          gene0007.pc_insere_tag(pr_xml      => pr_dsxmlret
                                ,pr_tag_pai  => 'Juridica'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'nrTelefo'
                                ,pr_tag_cont => rw_craptfc.nrtelefo
                                ,pr_des_erro => vr_des_erro);

        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_craptfc;
        END IF;      
      END IF;  
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Acontecendo algum erro (when-others), devemos recriar o xml 
        -- e enviar o erro tratado e retornar:
        pc_monta_retorno_ws(402,'segu0002.pc_busca_cooperado_seguro – Erro nao tratado -> '||sqlerrm,pr_dsxmlret);
        RETURN;
    END;
  END pc_busca_dados_cooperado;   
  
  /* Retornar a lista de possíveis titulares e dependentes para contratacao de seguro */
  PROCEDURE pc_ws_busca_dados_coop (pr_dsusuari  IN VARCHAR2              --> Codigo do usuario da requisicao
                                   ,pr_dsdsenha  IN VARCHAR2              --> Codigo do usuario da requisicao
                                   ,pr_idparcei  IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                   ,pr_cdagecop  IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                   ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descricao da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
  BEGIN
    /* .............................................................................

       Programa: pc_ws_busca_dados_coop
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Lucas Lombardi
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que recebera Agencia da Cooperativa e Conta
                   e retornar a lista de possíveis titulares e dependentes para 
                   contratacao de seguro.


       Alteracoes:

    ..............................................................................*/
    DECLARE
        
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      --Variaveis de Criticas
      vr_dscritic VARCHAR2(4000);
      
    BEGIN
        
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
      
      pc_busca_dados_cooperado (pr_dsusuari => pr_dsusuari

                               ,pr_dsdsenha => pr_dsdsenha
                               ,pr_idparcei => pr_idparcei
                               ,pr_cdagecop => pr_cdagecop
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_dsxmlret => pr_retxml);
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Acontecendo algum erro (when-others), devemos recriar o xml 
        -- e enviar o erro tratado e retornar:
        pc_monta_retorno_ws(402,'segu0002.pc_ws_busca_dados_coop – Erro nao tratado -> **(' || to_char(pr_idparcei) || ')**' ||sqlerrm,pr_retxml);
        RETURN;
    END;
  END pc_ws_busca_dados_coop;  
  
  /* Adicionar informacao de novo seguro ao Ayllos */
  PROCEDURE pc_adiciona_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Codigo do usuario da requisicao
                                       ,pr_dsdsenha            IN VARCHAR2              --> Codigo do usuario da requisicao
                                       ,pr_idparcei            IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                       ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                       ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                       
                                       ,pr_nrproposta          IN VARCHAR2 --> Número da proposta do seguro
                                       ,pr_nrapolice           IN VARCHAR2 --> Número da apolice de seguro
                                       ,pr_nmsegurado          IN VARCHAR2 --> Nome do segurado do seguro
                                       ,pr_nrcpfcnpj_segurado  IN VARCHAR2 --> Número do CPF ou CNPJ do segurado do seguro
                                       ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro contratado
                                       ,pr_dtinivigen          IN VARCHAR2 --> Data de início da vigência do contrato
                                       ,pr_dtfimvigen          IN VARCHAR2 --> Data de término da vigência do contrato
                                       ,pr_vlcapital_franquia  IN VARCHAR2 --> Valor de capital ou franquia do contrato
                                       ,pr_dsplano             IN VARCHAR2 --> Descritivo do plano contratado
                                       ,pr_vltot_premio_liquid IN VARCHAR2 --> Valor do prêmio líquido contratado
                                       ,pr_vltot_premio        IN VARCHAR2 --> Valor do prêmio contratado
                                       ,pr_qtparcelas          IN VARCHAR2 --> Quantidade de parcelas para pagamento do seguro
                                       ,pr_vlparcelas          IN VARCHAR2 --> Valor das parcelas para pagamento do seguro
                                       ,pr_dtdebito            IN VARCHAR2 --> Dia de débito das parcelas para pagamento do seguro
                                       ,pr_cdsitseguro         IN VARCHAR2 --> Codigo da situacao do seguro
                                       ,pr_cdsegura            IN VARCHAR2 --> Codigo da seguradora vinculada ao seguro
                                       ,pr_comissao            IN VARCHAR2 --> Valor da comissao do contrato
                                       ,pr_dsobserva           IN VARCHAR2 --> Descricao da observacao do contrato
                                       ,pr_array_benef         IN OUT XmlType  -->  Array com informacoes dos beneficiarios do seguro
                                       
                                       ,pr_dsxmlret            OUT NOCOPY XmlType) IS   --> XML de retorno da requisicao
  BEGIN
    /* .............................................................................

       Programa: pc_adiciona_contrato_seguro 
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que adicionara ao historico Ayllos uma nova
                   contratacao de seguro com as informacoes oriundas de WS. 

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Testes de retorno de rotinas
      vr_cdretorn NUMBER;
      vr_dsmsgret VARCHAR2(2000);
      vr_cdcooper crapcop.cdcooper%TYPE;
      -- Campos para conversao de texto em numero e data
      vr_nrproposta          tbseg_contratos.nrproposta%TYPE;       
      vr_nrapolice           tbseg_contratos.nrapolice%TYPE;
      vr_nrcpfcnpj_segurado  tbseg_contratos.nrcpf_cnpj_segurado%TYPE;
      vr_dtinivigen          tbseg_contratos.dtinicio_vigencia%TYPE;
      vr_dtfimvigen          tbseg_contratos.dttermino_vigencia%TYPE;
      vr_vlcapital_franquia  tbseg_contratos.vlcapital%TYPE;
      vr_vltot_premio_liquid tbseg_contratos.vlpremio_liquido%TYPE;
      vr_vltot_premio        tbseg_contratos.vlpremio_total%TYPE;
      vr_qtparcelas          tbseg_contratos.qtparcelas%TYPE;
      vr_vlparcelas          tbseg_contratos.vlparcela%TYPE;
      vr_dtdebito            tbseg_contratos.nrdiadebito%TYPE;
      vr_cdsegura            tbseg_contratos.cdsegura%TYPE;
      vr_comissao            tbseg_contratos.percomissao%TYPE;
      vr_stsnrcal            BOOLEAN;
      vr_inpessoa            NUMBER;
      -- Beneficiarios
      vr_tab_benef           gene0007.typ_tab_tagxml;
      vr_idx_benef           PLS_INTEGER;
      vr_dat_benef_teste     DATE;
      vr_per_partic_teste    NUMBER;
      -- Contrato a inserir
      vr_idcontrato          tbseg_contratos.idcontrato%TYPE;
    BEGIN
      -- Primeiramente acionaremos a rotina das validacoes basicas:
      pc_valida_requisi_wsseguros(PR_DSUSUARI => pr_dsusuari
                                 ,PR_DSDSENHA => pr_dsdsenha
                                 ,PR_IDPARCEI => pr_idparcei
                                 ,PR_CDAGECOP => pr_cdagecop
                                 ,PR_NRDCONTA => pr_nrdconta
                                 ,pr_cdcooper => vr_cdcooper
                                 ,PR_CDRETORN => vr_cdretorn
                                 ,PR_DSMSGRET => vr_dsmsgret);
      -- Se o retorno nao for codigo 202
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;  
      -- Validar campos texto obrigatórios
      pc_valida_obrigatorio(pr_nmsegurado,'nmSegurado',vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      
      -- Validar os campos numéricos recebidos
      pc_valida_char_para_numero(pr_nrproposta,'nrProposta','S',vr_nrproposta,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_numero(pr_nrapolice,'nrApolice','S',vr_nrapolice,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_numero(pr_nrcpfcnpj_segurado,'nrCpfCnpjSegurado','S',vr_nrcpfcnpj_segurado,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_valor(pr_vlcapital_franquia,'vlCapitalFranquia','S',vr_vlcapital_franquia,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_valor(pr_vltot_premio_liquid,'vlTotPremioLiq','S',vr_vltot_premio_liquid,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_valor(pr_vltot_premio,'vlTotPremio','S',vr_vltot_premio,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_valor(pr_qtparcelas,'qtParcelas','S',vr_qtparcelas,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_valor(pr_vlparcelas,'vlParcelas','S',vr_vlparcelas,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_valor(pr_dtdebito,'dtDebito','S',vr_dtdebito,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;      
      pc_valida_char_para_valor(pr_cdsegura,'cdSegura','S',vr_cdsegura,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF; 
      pc_valida_char_para_valor(pr_comissao,'prComissao','S',vr_comissao,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      
      -- Validar os campos data recebidos
      pc_valida_char_para_date(pr_dtinivigen,'dtIniVigen','S',vr_dtinivigen,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF; 
      pc_valida_char_para_date(pr_dtfimvigen,'dtFimVigen','N',vr_dtfimvigen,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      
      -- Validar se CPF/CNPJ enviados sao validos
      gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_nrcpfcnpj_segurado
                                 ,pr_stsnrcal => vr_stsnrcal
                                 ,pr_inpessoa => vr_inpessoa);
      IF NOT vr_stsnrcal THEN
        -- Retornar erro conforme:
        pc_monta_retorno_ws(402,'Campo nrCpfCnpjSegurado invalido. CPF/CNPJ invalidos.',pr_dsxmlret);
        RETURN;
      END IF;
      
      -- Devemos validar também os campos de domínio: pr_tpSeguro, pr_cdSitSeguro e pr_cdGrauPar:
      IF nvl(pr_tpSeguro,' ') not in('V','G','P','A','R') THEN
        -- Retornar erro conforme:
        pc_monta_retorno_ws(402,'Campo tpSeguro invalido. Informar [V]ida Individual, Vida [G]rupo, [P]restamista, [A]uto ou [R]esidência.',pr_dsxmlret);
        RETURN;
      END IF;  
      IF nvl(pr_cdSitSeguro,' ') not in('A','V','C','R') THEN
        -- Retornar erro conforme:
        pc_monta_retorno_ws(402,'Campo cdSitSeguro invalido. Informar [A]tivo, [V]encido, [C]ancelado ou [R]enovado.',pr_dsxmlret);
        RETURN;
      END IF;
      -- Validar a seguradora informada
      pc_valida_seguradora(vr_cdcooper,vr_cdsegura,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      -- Buscar o registro dos beneficiarios
      -- Estrutura:
      --   <Root>
      --     <beneficiarios>
      --       <nmBenefici/>
      --       <dtNascto/>
      --       <cdGrauPar/>
      --       <prpartici/>
      --     </beneficiarios>
      --   </Root> 
      gene0007.pc_itera_nodos('/beneficiarios/*',pr_array_benef,pr_list_nodos => vr_tab_benef, pr_des_erro => vr_dsmsgret);
      IF vr_dsmsgret IS NOT NULL THEN
        -- Montar retorno
        pc_monta_retorno_ws(402,'Array Beneficiarios invalido --> ' || vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      -- Se encontrado registro
      IF vr_tab_benef.count > 0 THEN    
        -- A lista de tags deve ser multipla de 4, pois cada registro possui quatro atributos
        IF mod(vr_tab_benef.count,4) > 0 THEN
          -- Montar retorno
          pc_monta_retorno_ws(402,'Array Beneficiarios invalido --> Nao recebidos quatro atributos por registro' || vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;
        -- Iterar sob o registro dos beneficiarios
        -- Lembrar que a pc_itera_nodos trara todos os atributos
        -- no mesmo nivel, ou seja, teremos de 0..3 as informacoes
        -- do primeiro benef, de 4..7 do segundo, e assim até chegarmos 
        -- ao ultimo beneficiario
        vr_idx_benef := 0;
        LOOP
          -- Campo texto obrigatório
          pc_valida_obrigatorio(vr_tab_benef(vr_idx_benef).tag,'nmBenefici',vr_cdretorn,vr_dsmsgret);
          IF vr_cdretorn <> 202 THEN
            -- Devemos finalizar montando o retorno e sair da execucao:
            pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
            RETURN;
          END IF;
          -- Validar a data de nascimento do beneficiario
          pc_valida_char_para_date(vr_tab_benef(vr_idx_benef+1).tag,'dtNascto','S',vr_dat_benef_teste,vr_cdretorn,vr_dsmsgret);
          IF vr_cdretorn <> 202 THEN
            -- Devemos finalizar montando o retorno e sair da execucao:
            pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
            RETURN;
          END IF;          
          -- Validar grau de parentesco
          IF length(TRIM(nvl(vr_tab_benef(vr_idx_benef+2).tag,' '))) > 10 THEN
            -- Retornar erro conforme:
            pc_monta_retorno_ws(402,'Campo cdGrauPar invalido. Informar apenas 10 caracteres.',pr_dsxmlret);
            RETURN;
          END IF;  
          -- Validar percentual de participacao
          pc_valida_char_para_valor(vr_tab_benef(vr_idx_benef+3).tag,'prPartici','S',vr_per_partic_teste,vr_cdretorn,vr_dsmsgret);
          IF vr_cdretorn <> 202 THEN
            -- Devemos finalizar montando o retorno e sair da execucao:
            pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
            RETURN;
          END IF;            
          -- Incrementar + 4 para passar a ler o proximo benef
          vr_idx_benef := vr_idx_benef + 4;
          -- Sair quando o o idx for superior a quantidade de tags retornadas
          EXIT WHEN vr_idx_benef+1 > vr_tab_benef.count;
        END LOOP;
      END IF;
      -- Devemos verificar se a apolice solicitada ja nao foi criada anteriormente e está ativa
      OPEN cr_tbseg_contratos(pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_tpseguro => pr_tpseguro
                             ,pr_nrapolic => vr_nrapolice
                             ,pr_indsitua => 'A');
      FETCH cr_tbseg_contratos
       INTO rw_tbseg;
      -- Se encontrou
      IF cr_tbseg_contratos%FOUND THEN
        CLOSE cr_tbseg_contratos;
        -- Retornar erro
        pc_monta_retorno_ws(402,'Campo nrApolice invalida. Apolice ja existente para a conta solicitada.',pr_dsxmlret);
        RETURN;
      ELSE
        CLOSE cr_tbseg_contratos;
      END IF; 
      -- Passadas as validacoes, podemos inserir as informacoes na tabela de contratos de seguros:
      BEGIN
        INSERT INTO tbseg_contratos(cdparceiro
                                   ,tpseguro
                                   ,nrproposta
                                   ,nrapolice
                                   ,cdcooper
                                   ,nrdconta
                                   ,nrcpf_cnpj_segurado
                                   ,nmsegurado
                                   ,dtinicio_vigencia
                                   ,dttermino_vigencia
                                   ,cdsegura
                                   ,dsplano
                                   ,indsituacao
                                   ,vlpremio_liquido
                                   ,vlpremio_total
                                   ,nrdiadebito
                                   ,qtparcelas
                                   ,vlparcela
                                   ,vlcapital
                                   ,percomissao
                                   ,dsobservacao
                                   ,dtmvtolt)
                             VALUES(pr_idparcei
                                   ,pr_tpseguro
                                   ,vr_nrproposta
                                   ,vr_nrapolice
                                   ,vr_cdcooper -- Encontrada acima
                                   ,pr_nrdconta
                                   ,vr_nrcpfcnpj_segurado
                                   ,pr_nmSegurado
                                   ,vr_dtinivigen
                                   ,vr_dtfimvigen
                                   ,vr_cdsegura
                                   ,pr_dsPlano
                                   ,pr_cdSitSeguro
                                   ,vr_vltot_premio_liquid
                                   ,vr_vltot_premio
                                   ,vr_dtdebito
                                   ,vr_qtparcelas
                                   ,vr_vlparcelas
                                   ,vr_vlcapital_franquia
                                   ,vr_comissao
                                   ,pr_dsObserva
                                   ,sysdate)
                          RETURNING idcontrato
                               INTO vr_idcontrato; -- Guardar id Criado para insercao de dependentes
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar erro conforme:
          pc_monta_retorno_ws(402,'Erro na insercao do Seguro: '||sqlerrm,pr_dsxmlret);
          ROLLBACK;
          RETURN;
      END;
      -- Prosseguindo, se tiver havido envio de beneficiarios no Array beneficiario, devemos analisar 
      -- cada um dos registros do Array, e para cada registro, efetuar o insert abaixo: 
      IF vr_tab_benef.count > 0 THEN    
        -- Iterar sob o registro dos beneficiarios
        -- Lembrar que a pc_itera_nodos trara todos os atributos
        -- no mesmo nivel, ou seja, teremos de 0..3 as informacoes
        -- do primeiro benef, de 4..7 do segundo, e assim até chegarmos 
        -- ao ultimo beneficiario
        vr_idx_benef := 0;
        LOOP
          -- Validar a data de nascimento do beneficiario
          BEGIN
            INSERT INTO tbseg_vida_benefici(idcontrato
                                           ,idbenefici
                                           ,nmbenefici
                                           ,dtnascimento
                                           ,dsgrau_parente
                                           ,perparticipacao)
                                     VALUES(vr_idcontrato       -- Alimentado no insert acima
                                           ,1+(vr_idx_benef/4)  -- Idx do Loop
                                           ,vr_tab_benef(vr_idx_benef).tag
                                           ,to_date(vr_tab_benef(vr_idx_benef+1).tag,'dd/mm/rrrr')
                                           ,vr_tab_benef(vr_idx_benef+2).tag
                                           ,to_number(vr_tab_benef(vr_idx_benef+3).tag)); 
          EXCEPTION
            WHEN OTHERS THEN
              -- Retornar erro conforme:
              pc_monta_retorno_ws(402,'Erro na insercao do Beneficiario Seguro: '||sqlerrm,pr_dsxmlret);
              ROLLBACK;
              RETURN;
          END;
          -- Incrementar + 4 para passar a ler o proximo benef
          vr_idx_benef := vr_idx_benef + 4;
          -- Sair quando o o idx for superior a quantidade de tags retornadas
          EXIT WHEN vr_idx_benef+1 > vr_tab_benef.count;
        END LOOP;
      END IF;
      
      -- Ao final, se a insercao do seguro tiver ocorrido com sucesso, retornamos a resposta com:
      pc_monta_retorno_ws(202,'Contrato aceito – informacao integrada ao Ayllos',pr_dsxmlret);
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        -- Acontecendo algum erro (when-others), devemos recriar o xml 
        -- e enviar o erro tratado e retornar:
        pc_monta_retorno_ws(402,'segu0002.pc_adiciona_contrato_seguro – Erro nao tratado -> '||sqlerrm,pr_dsxmlret);
        RETURN;
    END;
  END pc_adiciona_contrato_seguro;
  
  /* Adicionar informacao de novo seguro ao Ayllos */
  PROCEDURE pc_ws_add_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Codigo do usuario da requisicao
                                     ,pr_dsdsenha            IN VARCHAR2              --> Codigo do usuario da requisicao
                                     ,pr_idparcei            IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                     ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                     ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                     
                                     ,pr_nrproposta          IN VARCHAR2 --> Número da proposta do seguro
                                     ,pr_nrapolice           IN VARCHAR2 --> Número da apolice de seguro
                                     ,pr_nmsegurado          IN VARCHAR2 --> Nome do segurado do seguro
                                     ,pr_nrcpfcnpj_segurado  IN VARCHAR2 --> Número do CPF ou CNPJ do segurado do seguro
                                     ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro contratado
                                     ,pr_dtinivigen          IN VARCHAR2 --> Data de início da vigência do contrato
                                     ,pr_dtfimvigen          IN VARCHAR2 --> Data de término da vigência do contrato
                                     ,pr_vlcapital_franquia  IN VARCHAR2 --> Valor de capital ou franquia do contrato
                                     ,pr_dsplano             IN VARCHAR2 --> Descritivo do plano contratado
                                     ,pr_vltot_premio_liquid IN VARCHAR2 --> Valor do prêmio líquido contratado
                                     ,pr_vltot_premio        IN VARCHAR2 --> Valor do prêmio contratado
                                     ,pr_qtparcelas          IN VARCHAR2 --> Quantidade de parcelas para pagamento do seguro
                                     ,pr_vlparcelas          IN VARCHAR2 --> Valor das parcelas para pagamento do seguro
                                     ,pr_dtdebito            IN VARCHAR2 --> Dia de débito das parcelas para pagamento do seguro
                                     ,pr_cdsitseguro         IN VARCHAR2 --> Codigo da situacao do seguro
                                     ,pr_cdsegura            IN VARCHAR2 --> Codigo da seguradora vinculada ao seguro
                                     ,pr_comissao            IN VARCHAR2 --> Valor da comissao do contrato
                                     ,pr_dsobserva           IN VARCHAR2 --> Descricao da observacao do contrato
                                     ,pr_array_benef         IN VARCHAR2 -->  Array com informacoes dos beneficiarios do seguro
                                     
                                     ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da crítica
                                     ,pr_dscritic OUT VARCHAR2           --> Descricao da crítica
                                     ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS       -->  Saida OK/NOK
  BEGIN
    /* .............................................................................

       Programa: pc_ws_add_contrato_seguro 
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Lucas Lombardi
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que adicionara ao historico Ayllos uma nova
                   contratacao de seguro com as informacoes oriundas de WS. 

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_array_benef xmltype;
      
      vr_teste CLOB;
      
      --Variaveis de Criticas
      vr_dscritic VARCHAR2(4000);
      
    BEGIN
      
      --Informa acesso para exibir a formatacao correta
	    gene0001.pc_informa_acesso(pr_module => 'TELA_ADEPAC');
	
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
      
      vr_array_benef := XMLType.createXML(substr(pr_array_benef
                                                ,10
                                                ,(length(pr_array_benef) - 12)));
      
      vr_teste := vr_array_benef.getClobVal();
      
      pc_adiciona_contrato_seguro(pr_dsusuari            => pr_dsusuari           

                                 ,pr_dsdsenha            => pr_dsdsenha           
                                 ,pr_idparcei            => pr_idparcei           
                                 ,pr_cdagecop            => pr_cdagecop           
                                 ,pr_nrdconta            => pr_nrdconta           
                                 ,pr_nrproposta          => pr_nrproposta         
                                 ,pr_nrapolice           => pr_nrapolice          
                                 ,pr_nmsegurado          => pr_nmsegurado         
                                 ,pr_nrcpfcnpj_segurado  => pr_nrcpfcnpj_segurado 
                                 ,pr_tpseguro            => pr_tpseguro           
                                 ,pr_dtinivigen          => pr_dtinivigen         
                                 ,pr_dtfimvigen          => pr_dtfimvigen         
                                 ,pr_vlcapital_franquia  => pr_vlcapital_franquia 
                                 ,pr_dsplano             => pr_dsplano            
                                 ,pr_vltot_premio_liquid => pr_vltot_premio_liquid
                                 ,pr_vltot_premio        => pr_vltot_premio       
                                 ,pr_qtparcelas          => pr_qtparcelas         
                                 ,pr_vlparcelas          => pr_vlparcelas         
                                 ,pr_dtdebito            => pr_dtdebito           
                                 ,pr_cdsitseguro         => pr_cdsitseguro        
                                 ,pr_cdsegura            => pr_cdsegura           
                                 ,pr_comissao            => pr_comissao           
                                 ,pr_dsobserva           => pr_dsobserva          
                                 ,pr_array_benef         => vr_array_benef
                                 ,pr_dsxmlret            => pr_retxml);
    EXCEPTION
      WHEN OTHERS THEN
        -- Acontecendo algum erro (when-others), devemos recriar o xml 
        -- e enviar o erro tratado e retornar:
        pc_monta_retorno_ws(402,'segu0002.pc_ws_add_contrato_seguro – Erro nao tratado -> '||sqlerrm,pr_retxml);
        RETURN;
    END;
  END pc_ws_add_contrato_seguro;    
   
  
  /* Efetuar endosso de seguro existente no Ayllos */
  PROCEDURE pc_endosso_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Codigo do usuario da requisicao
                                      ,pr_dsdsenha            IN VARCHAR2              --> Codigo do usuario da requisicao
                                      ,pr_idparcei            IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                      ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                      ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                      
                                      ,pr_nrproposta          IN VARCHAR2 --> Número da proposta do seguro
                                      ,pr_nrapolice           IN VARCHAR2 --> Número da apolice de seguro
                                      ,pr_nrendosso           IN VARCHAR2 --> Número do endosso do seguro
                                      ,pr_nmsegurado          IN VARCHAR2 --> Nome do segurado do seguro
                                      ,pr_nrcpfcnpj_segurado  IN VARCHAR2 --> Número do CPF ou CNPJ do segurado do seguro
                                      ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro contratado
                                      ,pr_dtinivigen          IN VARCHAR2 --> Data de início da vigência do contrato
                                      ,pr_dtfimvigen          IN VARCHAR2 --> Data de término da vigência do contrato
                                      ,pr_vlcapital_franquia  IN VARCHAR2 --> Valor de capital ou franquia do contrato
                                      ,pr_dsplano             IN VARCHAR2 --> Descritivo do plano contratado
                                      ,pr_vltot_premio_liquid IN VARCHAR2 --> Valor do prêmio líquido contratado
                                      ,pr_vltot_premio        IN VARCHAR2 --> Valor do prêmio contratado
                                      ,pr_qtparcelas          IN VARCHAR2 --> Quantidade de parcelas para pagamento do seguro
                                      ,pr_vlparcelas          IN VARCHAR2 --> Valor das parcelas para pagamento do seguro
                                      ,pr_dtdebito            IN VARCHAR2 --> Dia de débito das parcelas para pagamento do seguro
                                      ,pr_cdsitseguro         IN VARCHAR2 --> Codigo da situacao do seguro
                                      ,pr_comissao            IN VARCHAR2 --> Valor da comissao do contrato
                                      ,pr_dsobserva           IN VARCHAR2 --> Descricao da observacao do contrato
                                      ,pr_array_benef         IN OUT XmlType               -->  Array com informacoes dos beneficiarios do seguro
                                      
                                      ,pr_dsxmlret            OUT NOCOPY XmlType) IS   --> XML de retorno da requisicao)
  BEGIN
    /* .............................................................................

       Programa: pc_endosso_contrato_seguro 
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que atualizara o historico Ayllos um endosso 
                   da contratacao de seguro com as informacoes oriundas de WS. 

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Testes de retorno de rotinas
      vr_cdretorn NUMBER;
      vr_dsmsgret VARCHAR2(2000);
      vr_cdcooper crapcop.cdcooper%TYPE;
      -- Campos para conversao de texto em numero e data
      vr_nrproposta          tbseg_contratos.nrproposta%TYPE;       
      vr_nrapolice           tbseg_contratos.nrapolice%TYPE;
      vr_nrendosso           tbseg_contratos.nrendosso%TYPE;
      vr_nrcpfcnpj_segurado  tbseg_contratos.nrcpf_cnpj_segurado%TYPE;
      vr_dtinivigen          tbseg_contratos.dtinicio_vigencia%TYPE;
      vr_dtfimvigen          tbseg_contratos.dttermino_vigencia%TYPE;
      vr_vlcapital_franquia  tbseg_contratos.vlcapital%TYPE;
      vr_vltot_premio_liquid tbseg_contratos.vlpremio_liquido%TYPE;
      vr_vltot_premio        tbseg_contratos.vlpremio_total%TYPE;
      vr_qtparcelas          tbseg_contratos.qtparcelas%TYPE;
      vr_vlparcelas          tbseg_contratos.vlparcela%TYPE;
      vr_dtdebito            tbseg_contratos.nrdiadebito%TYPE;
      vr_comissao            tbseg_contratos.percomissao%TYPE;
      vr_stsnrcal            BOOLEAN;
      vr_inpessoa            NUMBER;
      -- Beneficiarios
      vr_tab_benef           gene0007.typ_tab_tagxml;
      vr_idx_benef           PLS_INTEGER;
      vr_dat_benef_teste     DATE;
      vr_per_partic_teste    NUMBER;
    BEGIN
      -- Primeiramente acionaremos a rotina das validacoes basicas:
      pc_valida_requisi_wsseguros(PR_DSUSUARI => pr_dsusuari
                                 ,PR_DSDSENHA => pr_dsdsenha
                                 ,PR_IDPARCEI => pr_idparcei
                                 ,PR_CDAGECOP => pr_cdagecop
                                 ,PR_NRDCONTA => pr_nrdconta
                                 ,pr_cdcooper => vr_cdcooper
                                 ,PR_CDRETORN => vr_cdretorn
                                 ,PR_DSMSGRET => vr_dsmsgret);
      -- Se o retorno nao for codigo 202
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;  
      -- Validar os campos numéricos recebidos
      IF pr_nrproposta IS NOT NULL THEN
        pc_valida_char_para_numero(pr_nrproposta,'nrProposta','N',vr_nrproposta,vr_cdretorn,vr_dsmsgret);
        IF vr_cdretorn <> 202 THEN
          -- Devemos finalizar montando o retorno e sair da execucao:
          pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;
      END IF;
      pc_valida_char_para_numero(pr_nrapolice,'nrApolice','S',vr_nrapolice,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_numero(pr_nrendosso,'nrEndosso','S',vr_nrendosso,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      IF pr_nrcpfcnpj_segurado IS NOT NULL THEN
        pc_valida_char_para_numero(pr_nrcpfcnpj_segurado,'nrCpfCnpjSegurado','N',vr_nrcpfcnpj_segurado,vr_cdretorn,vr_dsmsgret);
        IF vr_cdretorn <> 202 THEN
          -- Devemos finalizar montando o retorno e sair da execucao:
          pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;
      END IF;
      IF pr_vlcapital_franquia IS NOT NULL THEN  
        pc_valida_char_para_valor(pr_vlcapital_franquia,'vlCapitalFranquia','N',vr_vlcapital_franquia,vr_cdretorn,vr_dsmsgret);
        IF vr_cdretorn <> 202 THEN
          -- Devemos finalizar montando o retorno e sair da execucao:
          pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;
      END IF;  
      IF pr_vltot_premio_liquid IS NOT NULL THEN
        pc_valida_char_para_valor(pr_vltot_premio_liquid,'vlTotPremioLiq','N',vr_vltot_premio_liquid,vr_cdretorn,vr_dsmsgret);
        IF vr_cdretorn <> 202 THEN
          -- Devemos finalizar montando o retorno e sair da execucao:
          pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;
      END IF;  
      IF pr_vltot_premio IS NOT NULL THEN
        pc_valida_char_para_valor(pr_vltot_premio,'vlTotPremio','N',vr_vltot_premio,vr_cdretorn,vr_dsmsgret);
        IF vr_cdretorn <> 202 THEN
          -- Devemos finalizar montando o retorno e sair da execucao:
          pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;
      END IF;
      IF pr_qtparcelas IS NOT NULL THEN
        pc_valida_char_para_valor(pr_qtparcelas,'qtParcelas','N',vr_qtparcelas,vr_cdretorn,vr_dsmsgret);
        IF vr_cdretorn <> 202 THEN
          -- Devemos finalizar montando o retorno e sair da execucao:
          pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;
      END IF;
      IF pr_vlparcelas IS NOT NULL THEN
        pc_valida_char_para_valor(pr_vlparcelas,'vlParcelas','N',vr_vlparcelas,vr_cdretorn,vr_dsmsgret);
        IF vr_cdretorn <> 202 THEN
          -- Devemos finalizar montando o retorno e sair da execucao:
          pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;
      END IF;
      IF pr_dtdebito IS NOT NULL THEN
        pc_valida_char_para_valor(pr_dtdebito,'dtDebito','N',vr_dtdebito,vr_cdretorn,vr_dsmsgret);
        IF vr_cdretorn <> 202 THEN
          -- Devemos finalizar montando o retorno e sair da execucao:
          pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;      
      END IF;
      IF pr_comissao IS NOT NULL THEN
        pc_valida_char_para_valor(pr_comissao,'prComissao','N',vr_comissao,vr_cdretorn,vr_dsmsgret);
        IF vr_cdretorn <> 202 THEN
          -- Devemos finalizar montando o retorno e sair da execucao:
          pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;
      END IF;
      
      -- Validar os campos data recebidos
      IF pr_dtinivigen IS NOT NULL THEN
        pc_valida_char_para_date(pr_dtinivigen,'dtIniVigen','N',vr_dtinivigen,vr_cdretorn,vr_dsmsgret);
        IF vr_cdretorn <> 202 THEN
          -- Devemos finalizar montando o retorno e sair da execucao:
          pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF; 
      END IF;
      IF pr_dtfimvigen IS NOT NULL THEN  
        pc_valida_char_para_date(pr_dtfimvigen,'dtFimVigen','N',vr_dtfimvigen,vr_cdretorn,vr_dsmsgret);
        IF vr_cdretorn <> 202 THEN
          -- Devemos finalizar montando o retorno e sair da execucao:
          pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;
      END IF;  
        
      -- Validar se CPF/CNPJ enviados sao validos
      IF vr_nrcpfcnpj_segurado IS NOT NULL THEN
        gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_nrcpfcnpj_segurado
                                   ,pr_stsnrcal => vr_stsnrcal
                                   ,pr_inpessoa => vr_inpessoa);
        IF NOT vr_stsnrcal THEN
          -- Retornar erro conforme:
          pc_monta_retorno_ws(402,'Campo nrCpfCnpjSegurado invalido. CPF/CNPJ invalidos.',pr_dsxmlret);
          RETURN;
        END IF;
      END IF;  

      -- Devemos validar também os campos de domínio: pr_tpSeguro, pr_cdSitSeguro e pr_cdGrauPar:
      IF nvl(pr_tpSeguro,' ') not in('V','G','P','A','R') THEN
        -- Retornar erro conforme:
        pc_monta_retorno_ws(402,'Campo tpSeguro invalido. Informar [V]ida Individual, Vida [G]rupo, [P]restamista, [A]uto ou [R]esidência.',pr_dsxmlret);
        RETURN;
      END IF;  
      
      IF pr_cdSitSeguro IS NOT NULL THEN
        IF pr_cdSitSeguro not in('A','V','C','R') THEN
          -- Retornar erro conforme:
          pc_monta_retorno_ws(402,'Campo cdSitSeguro invalido. Informar [A]tivo, [V]encido, [C]ancelado ou [R]enovado.',pr_dsxmlret);
          RETURN;
        END IF;
      END IF;
        
      -- Buscar o registro dos beneficiarios
      -- Estrutura:
      --   <Root>
      --     <beneficiarios>
      --       <nmBenefici/>
      --       <dtNascto/>
      --       <cdGrauPar/>
      --       <prpartici/>
      --     </beneficiarios>
      --   </Root> 
      gene0007.pc_itera_nodos('/beneficiarios/*',pr_array_benef,pr_list_nodos => vr_tab_benef, pr_des_erro => vr_dsmsgret);
      IF vr_dsmsgret IS NOT NULL THEN
        -- Montar retorno
        pc_monta_retorno_ws(402,'Array Beneficiarios invalido --> ' || vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      -- Se encontrado registro
      IF vr_tab_benef.count > 0 THEN    
        -- A lista de tags deve ser multipla de 4, pois cada registro possui quatro atributos
        IF mod(vr_tab_benef.count,4) > 0 THEN
          -- Montar retorno
          pc_monta_retorno_ws(402,'Array Beneficiarios invalido --> Nao recebidos quatro atributos por registro' || vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;
        -- Iterar sob o registro dos beneficiarios
        -- Lembrar que a pc_itera_nodos trara todos os atributos
        -- no mesmo nivel, ou seja, teremos de 0..3 as informacoes
        -- do primeiro benef, de 4..7 do segundo, e assim até chegarmos 
        -- ao ultimo beneficiario
        vr_idx_benef := 0;
        LOOP
          -- Campo texto obrigatório
          pc_valida_obrigatorio(vr_tab_benef(vr_idx_benef).tag,'nmBenefici',vr_cdretorn,vr_dsmsgret);
          IF vr_cdretorn <> 202 THEN
            -- Devemos finalizar montando o retorno e sair da execucao:
            pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
            RETURN;
          END IF;
          -- Validar a data de nascimento do beneficiario
          pc_valida_char_para_date(vr_tab_benef(vr_idx_benef+1).tag,'dtNascto','S',vr_dat_benef_teste,vr_cdretorn,vr_dsmsgret);
          IF vr_cdretorn <> 202 THEN
            -- Devemos finalizar montando o retorno e sair da execucao:
            pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
            RETURN;
          END IF;          
          -- Validar grau de parentesco
          IF length(trim(nvl(vr_tab_benef(vr_idx_benef+2).tag,' '))) > 10 THEN
            -- Retornar erro conforme:
            pc_monta_retorno_ws(402,'Campo cdGrauPar invalido. Informar apenas 10 caracteres.',pr_dsxmlret);
            RETURN;
          END IF;  
          -- Validar percentual de participacao
          pc_valida_char_para_valor(vr_tab_benef(vr_idx_benef+3).tag,'prPartici','S',vr_per_partic_teste,vr_cdretorn,vr_dsmsgret);
          IF vr_cdretorn <> 202 THEN
            -- Devemos finalizar montando o retorno e sair da execucao:
            pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
            RETURN;
          END IF;            
          -- Incrementar + 4 para passar a ler o proximo benef
          vr_idx_benef := vr_idx_benef + 4;
          -- Sair quando o o idx for superior a quantidade de tags retornadas
          EXIT WHEN vr_idx_benef+1 > vr_tab_benef.count;
        END LOOP;
      END IF;
      
      -- Devemos garantir que a apolice solicitada existe e está ativa
      OPEN cr_tbseg_contratos(pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_tpseguro => pr_tpseguro
                             ,pr_nrapolic => vr_nrapolice
                             ,pr_indsitua => 'A');
      FETCH cr_tbseg_contratos
       INTO rw_tbseg;
      -- Se encontrou
      IF cr_tbseg_contratos%NOTFOUND THEN
        CLOSE cr_tbseg_contratos;
        -- Retornar erro
        pc_monta_retorno_ws(402,'Campo nrApolice invalida. Apolice inexistente para a conta solicitada.',pr_dsxmlret);
        RETURN;
      ELSE
        CLOSE cr_tbseg_contratos;
      END IF; 
      -- Passadas as validacoes, podemos atualizar as informacoes na tabela de contratos de seguros:
      BEGIN
        UPDATE tbseg_contratos
           SET cdparceiro          = pr_idparcei
              ,nrproposta          = nvl(vr_nrproposta,nrproposta) -- Somente se recebido
              ,nrendosso           = vr_nrendosso
              ,nrcpf_cnpj_segurado = nvl(vr_nrcpfcnpj_segurado,nrcpf_cnpj_segurado) -- Somente se recebido
              ,nmsegurado          = nvl(pr_nmSegurado,nmsegurado) -- Somente se recebido
              ,dtinicio_vigencia   = nvl(vr_dtinivigen,dtinicio_vigencia) -- Somente se recebido
              ,dttermino_vigencia  = nvl(vr_dtfimvigen,dttermino_vigencia) -- Somente se recebido
              ,dsplano             = nvl(pr_dsPlano,dsplano) -- Somente se recebido
              ,indsituacao         = nvl(pr_cdSitSeguro,indsituacao) -- Somente se recebido
              ,vlpremio_liquido    = nvl(vr_vltot_premio_liquid,vlpremio_liquido) -- Somente se recebido
              ,vlpremio_total      = nvl(vr_vltot_premio,vlpremio_total) -- Somente se recebido
              ,nrdiadebito         = nvl(vr_dtdebito,nrdiadebito) -- Somente se recebido
              ,qtparcelas          = nvl(vr_qtparcelas,qtparcelas) -- Somente se recebido
              ,vlparcela           = nvl(vr_vlparcelas,vlparcela) -- Somente se recebido
              ,vlcapital           = nvl(vr_vlcapital_franquia,vlcapital) -- Somente se recebido
              ,percomissao         = nvl(vr_comissao,percomissao) -- Somente se recebido
              ,dsobservacao        = nvl(pr_dsObserva,dsobservacao) -- Somente se recebido
              ,dtmvtolt            = SYSDATE
         WHERE idcontrato = rw_tbseg.idcontrato;                               
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar erro conforme:
          pc_monta_retorno_ws(402,'Erro no Endosso do Seguro: '||sqlerrm,pr_dsxmlret);
          ROLLBACK;
          RETURN;
      END;
      -- Prosseguindo, se tiver havido envio de beneficiarios no Array beneficiario, devemos analisar 
      -- cada um dos registros do Array, e para cada registro, efetuar o insert abaixo: 
      IF vr_tab_benef.count > 0 THEN    
        -- Eliminar configuracao de beneficiarios anterior
        BEGIN
          DELETE tbseg_vida_benefici
           WHERE idcontrato = rw_tbseg.idcontrato;
        EXCEPTION
          WHEN OTHERS THEN
            -- Retornar erro conforme:
            pc_monta_retorno_ws(402,'Erro na recriacao dos beneficiarios do endosso do Seguro: '||sqlerrm,pr_dsxmlret);
            ROLLBACK;
            RETURN;        
        END;
        -- Iterar sob o registro dos beneficiarios
        -- Lembrar que a pc_itera_nodos trara todos os atributos
        -- no mesmo nivel, ou seja, teremos de 0..3 as informacoes
        -- do primeiro benef, de 4..7 do segundo, e assim até chegarmos 
        -- ao ultimo beneficiario
        vr_idx_benef := 0;
        LOOP
          -- Validar a data de nascimento do beneficiario
          BEGIN
            INSERT INTO tbseg_vida_benefici(idcontrato
                                           ,idbenefici
                                           ,nmbenefici
                                           ,dtnascimento
                                           ,dsgrau_parente
                                           ,perparticipacao)
                                     VALUES(rw_tbseg.idcontrato -- Encontrato na busca pela apolice
                                           ,1+(vr_idx_benef/4)  -- Idx do Loop
                                           ,vr_tab_benef(vr_idx_benef).tag
                                           ,to_date(vr_tab_benef(vr_idx_benef+1).tag,'dd/mm/rrrr')
                                           ,vr_tab_benef(vr_idx_benef+2).tag
                                           ,to_number(vr_tab_benef(vr_idx_benef+3).tag)); 
          EXCEPTION
            WHEN OTHERS THEN
              -- Retornar erro conforme:
              pc_monta_retorno_ws(402,'Erro na recriacao dos beneficiarios do endosso do Seguro: '||sqlerrm,pr_dsxmlret);
              ROLLBACK;
              RETURN;
          END;
          -- Incrementar + 4 para passar a ler o proximo benef
          vr_idx_benef := vr_idx_benef + 4;
          -- Sair quando o o idx for superior a quantidade de tags retornadas
          EXIT WHEN vr_idx_benef+1 > vr_tab_benef.count;
        END LOOP;
      END IF;
      
      -- Ao final, se a insercao do seguro tiver ocorrido com sucesso, retornamos a resposta com:
      pc_monta_retorno_ws(202,'Endosso aceito – informacao integrada ao Ayllos',pr_dsxmlret);
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        -- Acontecendo algum erro (when-others), devemos recriar o xml 
        -- e enviar o erro tratado e retornar:
        pc_monta_retorno_ws(402,'segu0002.pc_endosso_contrato_seguro – Erro nao tratado -> '||sqlerrm,pr_dsxmlret);
        RETURN;
    END;
  END pc_endosso_contrato_seguro;     
  
  /* Efetuar endosso de seguro existente no Ayllos */
  PROCEDURE pc_ws_end_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Codigo do usuario da requisicao
                                     ,pr_dsdsenha            IN VARCHAR2              --> Codigo do usuario da requisicao
                                     ,pr_idparcei            IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                     ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                     ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                     
                                     ,pr_nrproposta          IN VARCHAR2 --> Número da proposta do seguro
                                     ,pr_nrapolice           IN VARCHAR2 --> Número da apolice de seguro
                                     ,pr_nrendosso           IN VARCHAR2 --> Número do endosso do seguro
                                     ,pr_nmsegurado          IN VARCHAR2 --> Nome do segurado do seguro
                                     ,pr_nrcpfcnpj_segurado  IN VARCHAR2 --> Número do CPF ou CNPJ do segurado do seguro
                                     ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro contratado
                                     ,pr_dtinivigen          IN VARCHAR2 --> Data de início da vigência do contrato
                                     ,pr_dtfimvigen          IN VARCHAR2 --> Data de término da vigência do contrato
                                     ,pr_vlcapital_franquia  IN VARCHAR2 --> Valor de capital ou franquia do contrato
                                     ,pr_dsplano             IN VARCHAR2 --> Descritivo do plano contratado
                                     ,pr_vltot_premio_liquid IN VARCHAR2 --> Valor do prêmio líquido contratado
                                     ,pr_vltot_premio        IN VARCHAR2 --> Valor do prêmio contratado
                                     ,pr_qtparcelas          IN VARCHAR2 --> Quantidade de parcelas para pagamento do seguro
                                     ,pr_vlparcelas          IN VARCHAR2 --> Valor das parcelas para pagamento do seguro
                                     ,pr_dtdebito            IN VARCHAR2 --> Dia de débito das parcelas para pagamento do seguro
                                     ,pr_cdsitseguro         IN VARCHAR2 --> Codigo da situacao do seguro
                                     ,pr_comissao            IN VARCHAR2 --> Valor da comissao do contrato
                                     ,pr_dsobserva           IN VARCHAR2 --> Descricao da observacao do contrato
                                     ,pr_array_benef         IN VARCHAR2 -->  Array com informacoes dos beneficiarios do seguro
                                     
                                     ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da crítica
                                     ,pr_dscritic OUT VARCHAR2           --> Descricao da crítica
                                     ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS       -->  Saida OK/NOK
  BEGIN
    /* .............................................................................

       Programa: pc_ws_end_contrato_seguro 
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Lucas Lombardi
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que atualizara o historico Ayllos um endosso 
                   da contratacao de seguro com as informacoes oriundas de WS. 

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_array_benef xmltype;
      
      vr_teste CLOB;
      
      --Variaveis de Criticas
      vr_dscritic VARCHAR2(4000);
      
    BEGIN
      
      --Informa acesso para exibir a formatacao correta
	    gene0001.pc_informa_acesso(pr_module => 'TELA_ADEPAC');
	
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
      
      vr_array_benef := XMLType.createXML(substr(pr_array_benef
                                                ,10
                                                ,(length(pr_array_benef) - 12)));
      
      vr_teste := vr_array_benef.getClobVal();
      
      pc_endosso_contrato_seguro(pr_dsusuari            => pr_dsusuari           
                                ,pr_dsdsenha            => pr_dsdsenha           
                                ,pr_idparcei            => pr_idparcei           
                                ,pr_cdagecop            => pr_cdagecop           
                                ,pr_nrdconta            => pr_nrdconta           
                                ,pr_nrproposta          => pr_nrproposta         
                                ,pr_nrapolice           => pr_nrapolice          
                                ,pr_nrendosso           => pr_nrendosso          
                                ,pr_nmsegurado          => pr_nmsegurado         
                                ,pr_nrcpfcnpj_segurado  => pr_nrcpfcnpj_segurado 
                                ,pr_tpseguro            => pr_tpseguro
                                ,pr_dtinivigen          => pr_dtinivigen         
                                ,pr_dtfimvigen          => pr_dtfimvigen         
                                ,pr_vlcapital_franquia  => pr_vlcapital_franquia 
                                ,pr_dsplano             => pr_dsplano            
                                ,pr_vltot_premio_liquid => pr_vltot_premio_liquid
                                ,pr_vltot_premio        => pr_vltot_premio       
                                ,pr_qtparcelas          => pr_qtparcelas         
                                ,pr_vlparcelas          => pr_vlparcelas         
                                ,pr_dtdebito            => pr_dtdebito           
                                ,pr_cdsitseguro         => pr_cdsitseguro        
                                ,pr_comissao            => pr_comissao           
                                ,pr_dsobserva           => pr_dsobserva          
                                ,pr_array_benef         => vr_array_benef
                                ,pr_dsxmlret            => pr_retxml);
    EXCEPTION
      WHEN OTHERS THEN
        -- Acontecendo algum erro (when-others), devemos recriar o xml 
        -- e enviar o erro tratado e retornar:
        pc_monta_retorno_ws(402,'segu0002.pc_ws_add_contrato_seguro – Erro nao tratado -> '||sqlerrm,pr_retxml);
        RETURN;
    END;
  END pc_ws_end_contrato_seguro;       
  
  /* Efetuar cancelamento de seguro existente no Ayllos */
  PROCEDURE pc_cancela_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Codigo do usuario da requisicao
                                      ,pr_dsdsenha            IN VARCHAR2              --> Codigo do usuario da requisicao
                                      ,pr_idparcei            IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                      ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                      ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                    
                                      ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro contratado
                                      ,pr_nrapolice           IN VARCHAR2 --> Número da apolice de seguro
                                      ,pr_nrendosso           IN VARCHAR2 --> Número do endosso do seguro
                                      ,pr_dtfimvigen          IN VARCHAR2 --> Data de término da vigência do contrato
                                      ,pr_dsobserva           IN VARCHAR2 --> Descricao da observacao do contrato
                                    
                                      ,pr_dsxmlret            OUT NOCOPY XmlType) IS   --> XML de retorno da requisicao)
  BEGIN
    /* .............................................................................

       Programa: pc_cancela_contrato_seguro 
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que atualizara o historico Ayllos com cancelamento da 
                   contratacao de seguro com as informacoes oriundas de WS. 

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Testes de retorno de rotinas
      vr_cdretorn NUMBER;
      vr_dsmsgret VARCHAR2(2000);
      vr_cdcooper crapcop.cdcooper%TYPE;
      -- Campos para conversao de texto em numero e data
      vr_nrapolice           tbseg_contratos.nrapolice%TYPE;
      vr_nrendosso           tbseg_contratos.nrendosso%TYPE;
      vr_dtfimvigen          tbseg_contratos.dttermino_vigencia%TYPE;
      
    BEGIN
      -- Primeiramente acionaremos a rotina das validacoes basicas:
      pc_valida_requisi_wsseguros(PR_DSUSUARI => pr_dsusuari
                                 ,PR_DSDSENHA => pr_dsdsenha
                                 ,PR_IDPARCEI => pr_idparcei
                                 ,PR_CDAGECOP => pr_cdagecop
                                 ,PR_NRDCONTA => pr_nrdconta
                                 ,pr_cdcooper => vr_cdcooper
                                 ,PR_CDRETORN => vr_cdretorn
                                 ,PR_DSMSGRET => vr_dsmsgret);
      -- Se o retorno nao for codigo 202
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;  
      -- Validar os campos numéricos recebidos
      pc_valida_char_para_numero(pr_nrapolice,'nrApolice','S',vr_nrapolice,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_numero(pr_nrendosso,'nrEndosso','S',vr_nrendosso,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      
      -- Validar os campos data recebidos
      pc_valida_char_para_date(pr_dtfimvigen,'dtFimVigen','S',vr_dtfimvigen,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;

      -- Devemos validar também os campos de domínio: pr_tpSeguro
      IF nvl(pr_tpSeguro,' ') not in('V','G','P','A','R') THEN
        -- Retornar erro conforme:
        pc_monta_retorno_ws(402,'Campo tpSeguro invalido. Informar [V]ida Individual, Vida [G]rupo, [P]restamista, [A]uto ou [R]esidência.',pr_dsxmlret);
        RETURN;
      END IF;  
      
      
      -- Devemos garantir que a apolice solicitada existe
      OPEN cr_tbseg_contratos(pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_tpseguro => pr_tpseguro
                             ,pr_nrapolic => vr_nrapolice
                             ,pr_indsitua => 'A'); /*Somente ativas*/
      FETCH cr_tbseg_contratos
       INTO rw_tbseg;
      -- Se encontrou
      IF cr_tbseg_contratos%NOTFOUND THEN
        CLOSE cr_tbseg_contratos;
        -- Retornar erro
        pc_monta_retorno_ws(402,'Campo nrApolice invalida. Apolice inexistente ou Inativa para a conta solicitada.',pr_dsxmlret);
        RETURN;
      ELSE
        CLOSE cr_tbseg_contratos;
      END IF; 
      
      -- Passadas as validacoes, podemos atualizar as informacoes na tabela de contratos de seguros:
      BEGIN
        UPDATE tbseg_contratos
           SET cdparceiro          = pr_idparcei
              ,nrendosso           = nvl(vr_nrendosso,nrendosso) -- Somente se recebido
              ,dttermino_vigencia  = vr_dtfimvigen
              ,indsituacao         = 'C' --> Cancelada
              ,dsobservacao        = pr_dsObserva 
              ,dtmvtolt            = SYSDATE
         WHERE idcontrato = rw_tbseg.idcontrato;                               
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar erro conforme:
          pc_monta_retorno_ws(402,'Erro na Expiracacao do Seguro: '||sqlerrm,pr_dsxmlret);
          ROLLBACK;
          RETURN;
      END;
      
      -- Ao final, se a insercao do seguro tiver ocorrido com sucesso, retornamos a resposta com:
      pc_monta_retorno_ws(202,'Cancelamento aceito – informacao integrada ao Ayllos',pr_dsxmlret);
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        -- Acontecendo algum erro (when-others), devemos recriar o xml 
        -- e enviar o erro tratado e retornar:
        pc_monta_retorno_ws(402,'segu0002.pc_cancela_contrato_seguro – Erro nao tratado -> '||sqlerrm,pr_dsxmlret);
        RETURN;
    END;
  END pc_cancela_contrato_seguro;       
  
  /* Efetuar cancelamento de seguro existente no Ayllos */
  PROCEDURE pc_ws_canc_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Codigo do usuario da requisicao
                                      ,pr_dsdsenha            IN VARCHAR2              --> Codigo do usuario da requisicao
                                      ,pr_idparcei            IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                      ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                      ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                      
                                      ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro contratado
                                      ,pr_nrapolice           IN VARCHAR2 --> Número da apolice de seguro
                                      ,pr_nrendosso           IN VARCHAR2 --> Número do endosso do seguro
                                      ,pr_dtfimvigen          IN VARCHAR2 --> Data de término da vigência do contrato
                                      ,pr_dsobserva           IN VARCHAR2 --> Descricao da observacao do contrato
                                      
                                      ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da crítica
                                      ,pr_dscritic OUT VARCHAR2           --> Descricao da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2) IS       -->  Saida OK/NOK
  BEGIN
    /* .............................................................................

       Programa: pc_ws_canc_contrato_seguro 
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Lucas Lombardi
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que atualizara o historico Ayllos com cancelamento da 
                   contratacao de seguro com as informacoes oriundas de WS. 

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_array_benef xmltype;
      
      vr_teste CLOB;
      
      --Variaveis de Criticas
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_des_erro VARCHAR2(3);
      
    BEGIN
      
      --Informa acesso para exibir a formatacao correta
	    gene0001.pc_informa_acesso(pr_module => 'TELA_ADEPAC');
	
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
      
      pc_cancela_contrato_seguro(pr_dsusuari   => pr_dsusuari           
                                ,pr_dsdsenha   => pr_dsdsenha           
                                ,pr_idparcei   => pr_idparcei           
                                ,pr_cdagecop   => pr_cdagecop           
                                ,pr_nrdconta   => pr_nrdconta           
                                ,pr_tpseguro   => pr_tpseguro
                                ,pr_nrapolice  => pr_nrapolice          
                                ,pr_nrendosso  => pr_nrendosso          
                                ,pr_dtfimvigen => pr_dtfimvigen         
                                ,pr_dsobserva  => pr_dsobserva          
                                ,pr_dsxmlret   => pr_retxml);
    EXCEPTION
      WHEN OTHERS THEN
        -- Acontecendo algum erro (when-others), devemos recriar o xml 
        -- e enviar o erro tratado e retornar:
        pc_monta_retorno_ws(402,'segu0002.pc_ws_canc_contrato_seguro – Erro nao tratado -> '||sqlerrm,pr_retxml);
        RETURN;
    END;
  END pc_ws_canc_contrato_seguro;    
  
  /* Efetuar renovacao de seguro existente no Ayllos */
  PROCEDURE pc_renova_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Codigo do usuario da requisicao
                                     ,pr_dsdsenha            IN VARCHAR2              --> Codigo do usuario da requisicao
                                     ,pr_idparcei            IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                     ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                     ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                     
                                     ,pr_nrproposta          IN VARCHAR2 --> Número da proposta do seguro
                                     ,pr_nrapolice           IN VARCHAR2 --> Número da apolice de seguro
                                     ,pr_nrapolice_anterior  IN VARCHAR2 --> Número da apolice anterior de seguro
                                     ,pr_nrendosso           IN VARCHAR2 --> Número do endosso do seguro
                                     ,pr_nmsegurado          IN VARCHAR2 --> Nome do segurado do seguro
                                     ,pr_nrcpfcnpj_segurado  IN VARCHAR2 --> Número do CPF ou CNPJ do segurado do seguro
                                     ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro renovado
                                     ,pr_dtinivigen          IN VARCHAR2 --> Data de início da vigência do contrato
                                     ,pr_dtfimvigen          IN VARCHAR2 --> Data de término da vigência do contrato
                                     ,pr_vlcapital_franquia  IN VARCHAR2 --> Valor de capital ou franquia do contrato
                                     ,pr_dsplano             IN VARCHAR2 --> Descritivo do plano contratado
                                     ,pr_vltot_premio_liquid IN VARCHAR2 --> Valor do prêmio líquido contratado
                                     ,pr_vltot_premio        IN VARCHAR2 --> Valor do prêmio contratado
                                     ,pr_qtparcelas          IN VARCHAR2 --> Quantidade de parcelas para pagamento do seguro
                                     ,pr_vlparcelas          IN VARCHAR2 --> Valor das parcelas para pagamento do seguro
                                     ,pr_dtdebito            IN VARCHAR2 --> Dia de débito das parcelas para pagamento do seguro
                                     ,pr_cdsegura            IN VARCHAR2 --> Codigo da seguradora vinculada ao seguro
                                     ,pr_comissao            IN VARCHAR2 --> Valor da comissao do contrato
                                     ,pr_dsobserva           IN VARCHAR2 --> Descricao da observacao do contrato
                                     ,pr_array_benef         IN OUT XmlType               -->  Array com informacoes dos beneficiarios do seguro
                                      
                                     ,pr_dsxmlret            OUT NOCOPY XmlType) IS   --> XML de retorno da requisicao)
  BEGIN
    /* .............................................................................

       Programa: pc_renova_contrato_seguro 
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que atualizara o historico Ayllos com uma renovacao
                   da contratacao de seguro com as informacoes oriundas de WS. 


       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Testes de retorno de rotinas
      vr_cdretorn NUMBER;
      vr_dsmsgret VARCHAR2(2000);
      vr_cdcooper crapcop.cdcooper%TYPE;
      -- Campos para conversao de texto em numero e data
      vr_nrproposta          tbseg_contratos.nrproposta%TYPE;       
      vr_nrapolice           tbseg_contratos.nrapolice%TYPE;
      vr_nrapolice_anterior  tbseg_contratos.nrapolice_renovacao%TYPE;
      vr_nrendosso           tbseg_contratos.nrendosso%TYPE;
      vr_nrcpfcnpj_segurado  tbseg_contratos.nrcpf_cnpj_segurado%TYPE;
      vr_dtinivigen          tbseg_contratos.dtinicio_vigencia%TYPE;
      vr_dtfimvigen          tbseg_contratos.dttermino_vigencia%TYPE;
      vr_vlcapital_franquia  tbseg_contratos.vlcapital%TYPE;
      vr_vltot_premio_liquid tbseg_contratos.vlpremio_liquido%TYPE;
      vr_vltot_premio        tbseg_contratos.vlpremio_total%TYPE;
      vr_qtparcelas          tbseg_contratos.qtparcelas%TYPE;
      vr_vlparcelas          tbseg_contratos.vlparcela%TYPE;
      vr_dtdebito            tbseg_contratos.nrdiadebito%TYPE;
      vr_cdsegura            tbseg_contratos.cdsegura%TYPE;
      vr_comissao            tbseg_contratos.percomissao%TYPE;
      vr_stsnrcal            BOOLEAN;
      vr_inpessoa            NUMBER;
      -- Beneficiarios
      vr_tab_benef           gene0007.typ_tab_tagxml;
      vr_idx_benef           PLS_INTEGER;
      vr_dat_benef_teste     DATE;
      vr_per_partic_teste    NUMBER;
      -- Contrato a inserir
      vr_idcontrato          tbseg_contratos.idcontrato%TYPE;      
    BEGIN
      -- Primeiramente acionaremos a rotina das validacoes basicas:
      pc_valida_requisi_wsseguros(PR_DSUSUARI => pr_dsusuari
                                 ,PR_DSDSENHA => pr_dsdsenha
                                 ,PR_IDPARCEI => pr_idparcei
                                 ,PR_CDAGECOP => pr_cdagecop
                                 ,PR_NRDCONTA => pr_nrdconta
                                 ,pr_cdcooper => vr_cdcooper
                                 ,PR_CDRETORN => vr_cdretorn
                                 ,PR_DSMSGRET => vr_dsmsgret);
      -- Se o retorno nao for codigo 202
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;  
      
      -- Validar campos texto obrigatórios
      pc_valida_obrigatorio(pr_nmsegurado,'nmSegurado',vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      
      pc_valida_obrigatorio(pr_dsplano,'dsPlano',vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      
      -- Validar os campos numéricos recebidos
      pc_valida_char_para_numero(pr_nrproposta,'nrProposta','S',vr_nrproposta,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_numero(pr_nrapolice,'nrApolice','S',vr_nrapolice,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_numero(pr_nrapolice_anterior,'nrApoliceAnterior','S',vr_nrapolice_anterior,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_numero(pr_nrendosso,'nrEndosso','S',vr_nrendosso,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_numero(pr_nrcpfcnpj_segurado,'nrCpfCnpjSegurado','S',vr_nrcpfcnpj_segurado,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_valor(pr_vlcapital_franquia,'vlCapitalFranquia','S',vr_vlcapital_franquia,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_valor(pr_vltot_premio_liquid,'vlTotPremioLiq','S',vr_vltot_premio_liquid,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_valor(pr_vltot_premio,'vlTotPremio','S',vr_vltot_premio,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_valor(pr_qtparcelas,'qtParcelas','S',vr_qtparcelas,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_valor(pr_vlparcelas,'vlParcelas','S',vr_vlparcelas,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      pc_valida_char_para_valor(pr_dtdebito,'dtDebito','S',vr_dtdebito,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;      
      pc_valida_char_para_valor(pr_cdsegura,'cdSegura','S',vr_cdsegura,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;       
      pc_valida_char_para_valor(pr_comissao,'prComissao','S',vr_comissao,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      
      -- Validar os campos data recebidos
      pc_valida_char_para_date(pr_dtinivigen,'dtIniVigen','S',vr_dtinivigen,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF; 
      pc_valida_char_para_date(pr_dtfimvigen,'dtFimVigen','N',vr_dtfimvigen,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      
      -- Validar se CPF/CNPJ enviados sao validos
      gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_nrcpfcnpj_segurado
                                 ,pr_stsnrcal => vr_stsnrcal
                                 ,pr_inpessoa => vr_inpessoa);
      IF NOT vr_stsnrcal THEN
        -- Retornar erro conforme:
        pc_monta_retorno_ws(402,'Campo nrCpfCnpjSegurado invalido. CPF/CNPJ invalidos.',pr_dsxmlret);
        RETURN;
      END IF;

      -- Devemos validar também os campos de domínio: pr_tpSeguro, pr_cdSitSeguro e pr_cdGrauPar:
      IF nvl(pr_tpSeguro,' ') not in('V','G','P','A','R') THEN
        -- Retornar erro conforme:
        pc_monta_retorno_ws(402,'Campo tpSeguro invalido. Informar [V]ida Individual, Vida [G]rupo, [P]restamista, [A]uto ou [R]esidência.',pr_dsxmlret);
        RETURN;
      END IF;        

      -- Validar a seguradora informada
      pc_valida_seguradora(vr_cdcooper,vr_cdsegura,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;      
      

      -- Buscar o registro dos beneficiarios
      -- Estrutura:
      --   <Root>
      --     <beneficiarios>
      --       <nmBenefici/>
      --       <dtNascto/>
      --       <cdGrauPar/>
      --       <prpartici/>
      --     </beneficiarios>
      --   </Root> 
      gene0007.pc_itera_nodos('/beneficiarios/*',pr_array_benef,pr_list_nodos => vr_tab_benef, pr_des_erro => vr_dsmsgret);
      IF vr_dsmsgret IS NOT NULL THEN
        -- Montar retorno
        pc_monta_retorno_ws(402,'Array Beneficiarios invalido --> ' || vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      -- Se encontrado registro
      IF vr_tab_benef.count > 0 THEN    
        -- A lista de tags deve ser multipla de 4, pois cada registro possui quatro atributos
        IF mod(vr_tab_benef.count,4) > 0 THEN
          -- Montar retorno
          pc_monta_retorno_ws(402,'Array Beneficiarios invalido --> Nao recebidos quatro atributos por registro' || vr_dsmsgret,pr_dsxmlret);
          RETURN;
        END IF;
        -- Iterar sob o registro dos beneficiarios
        -- Lembrar que a pc_itera_nodos trara todos os atributos
        -- no mesmo nivel, ou seja, teremos de 0..3 as informacoes
        -- do primeiro benef, de 4..7 do segundo, e assim até chegarmos 
        -- ao ultimo beneficiario
        vr_idx_benef := 0;
        LOOP
          -- Campo texto obrigatório
          pc_valida_obrigatorio(vr_tab_benef(vr_idx_benef).tag,'nmBenefici',vr_cdretorn,vr_dsmsgret);
          IF vr_cdretorn <> 202 THEN
            -- Devemos finalizar montando o retorno e sair da execucao:
            pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
            RETURN;
          END IF;
          -- Validar a data de nascimento do beneficiario
          pc_valida_char_para_date(vr_tab_benef(vr_idx_benef+1).tag,'dtNascto','S',vr_dat_benef_teste,vr_cdretorn,vr_dsmsgret);
          IF vr_cdretorn <> 202 THEN
            -- Devemos finalizar montando o retorno e sair da execucao:
            pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
            RETURN;
          END IF;          
          -- Validar grau de parentesco
          IF length(trim(nvl(vr_tab_benef(vr_idx_benef+2).tag,' '))) > 10 THEN
            -- Retornar erro conforme:
            pc_monta_retorno_ws(402,'Campo cdGrauPar invalido. Informar apenas 10 caracteres.',pr_dsxmlret);
            RETURN;
          END IF;  
          -- Validar percentual de participacao
          pc_valida_char_para_valor(vr_tab_benef(vr_idx_benef+3).tag,'prPartici','S',vr_per_partic_teste,vr_cdretorn,vr_dsmsgret);
          IF vr_cdretorn <> 202 THEN
            -- Devemos finalizar montando o retorno e sair da execucao:
            pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
            RETURN;
          END IF;            
          -- Incrementar + 4 para passar a ler o proximo benef
          vr_idx_benef := vr_idx_benef + 4;
          -- Sair quando o o idx for superior a quantidade de tags retornadas
          EXIT WHEN vr_idx_benef+1 > vr_tab_benef.count;
        END LOOP;
      END IF;
      
      -- Devemos garantir que a apolice anterior solicitada existe
      OPEN cr_tbseg_contratos(pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_tpseguro => pr_tpseguro
                             ,pr_nrapolic => vr_nrapolice_anterior);
      FETCH cr_tbseg_contratos
       INTO rw_tbseg;
      -- Se encontrou
      IF cr_tbseg_contratos%NOTFOUND THEN
        CLOSE cr_tbseg_contratos;
        -- Retornar erro
        pc_monta_retorno_ws(402,'Campo nrApoliceAnterior invalida. Apolice inexistente para a conta solicitada.',pr_dsxmlret);
        RETURN;
      ELSE
        CLOSE cr_tbseg_contratos;
      END IF; 
            
      -- Atualizar a apolice anterior para inativa
      BEGIN
        UPDATE tbseg_contratos
           SET cdparceiro          = pr_idparcei
              ,indsituacao         = 'R' --> Renovada
              ,dsobservacao        = nvl(pr_dsObserva,dsobservacao) -- Somente se recebido
              ,dtmvtolt            = SYSDATE
         WHERE idcontrato = rw_tbseg.idcontrato;  /* Antiga */                              
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar erro conforme:
          pc_monta_retorno_ws(402,'Erro na Renovacao do Seguro Antigo: '||sqlerrm,pr_dsxmlret);
          ROLLBACK;
          RETURN;
      END;
      
      -- Devemos verificar se a apolice nova solicitada ja nao foi criada anteriormente:
      OPEN cr_tbseg_contratos(pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_tpseguro => pr_tpseguro
                             ,pr_nrapolic => vr_nrapolice
                             ,pr_indsitua => 'A');
      FETCH cr_tbseg_contratos
       INTO rw_tbseg;
      -- Se encontrou
      IF cr_tbseg_contratos%FOUND THEN
        CLOSE cr_tbseg_contratos;
        -- Retornar erro
        pc_monta_retorno_ws(402,'Campo nrApolice invalida. Apolice ja existente e ativa para a conta solicitada.',pr_dsxmlret);
        ROLLBACK;
        RETURN;
      ELSE
        CLOSE cr_tbseg_contratos;
      END IF;
      
      /* Inserir novo contrato renovado */      
      BEGIN
        INSERT INTO tbseg_contratos(cdparceiro
                                   ,tpseguro
                                   ,nrproposta
                                   ,nrapolice
                                   ,nrendosso
                                   ,cdcooper
                                   ,nrdconta
                                   ,nrcpf_cnpj_segurado
                                   ,nmsegurado
                                   ,nrapolice_renovacao
                                   ,dtinicio_vigencia
                                   ,dttermino_vigencia
                                   ,cdsegura
                                   ,dsplano
                                   ,indsituacao
                                   ,vlpremio_liquido
                                   ,vlpremio_total
                                   ,nrdiadebito
                                   ,qtparcelas
                                   ,vlparcela
                                   ,vlcapital
                                   ,percomissao
                                   ,dsobservacao
                                   ,dtmvtolt)
                             VALUES(pr_idparcei
                                   ,pr_tpseguro
                                   ,vr_nrproposta
                                   ,vr_nrapolice
                                   ,vr_nrendosso
                                   ,vr_cdcooper -- Encontrada acima
                                   ,pr_nrdconta
                                   ,vr_nrcpfcnpj_segurado
                                   ,pr_nmSegurado
                                   ,vr_nrapolice_anterior
                                   ,vr_dtinivigen
                                   ,vr_dtfimvigen
                                   ,vr_cdsegura
                                   ,pr_dsPlano
                                   ,'A' -- Ativo
                                   ,vr_vltot_premio_liquid
                                   ,vr_vltot_premio
                                   ,vr_dtdebito
                                   ,vr_qtparcelas
                                   ,vr_vlparcelas
                                   ,vr_vlcapital_franquia
                                   ,vr_comissao
                                   ,pr_dsObserva
                                   ,sysdate)
                          RETURNING idcontrato
                               INTO vr_idcontrato; -- Guardar id Criado para insercao de dependentes
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar erro conforme:
          pc_monta_retorno_ws(402,'Erro na criacao do Seguro Renovado: '||sqlerrm,pr_dsxmlret);
          ROLLBACK;
          RETURN;
      END;
      
      -- Prosseguindo, se tiver havido envio de beneficiarios no Array beneficiario, devemos analisar 
      -- cada um dos registros do Array, e para cada registro, efetuar o insert abaixo: 
      IF vr_tab_benef.count > 0 THEN    
        -- Iterar sob o registro dos beneficiarios
        -- Lembrar que a pc_itera_nodos trara todos os atributos
        -- no mesmo nivel, ou seja, teremos de 0..3 as informacoes
        -- do primeiro benef, de 4..7 do segundo, e assim até chegarmos 
        -- ao ultimo beneficiario
        vr_idx_benef := 0;
        LOOP
          -- Validar a data de nascimento do beneficiario
          BEGIN
            INSERT INTO tbseg_vida_benefici(idcontrato
                                           ,idbenefici
                                           ,nmbenefici
                                           ,dtnascimento
                                           ,dsgrau_parente
                                           ,perparticipacao)
                                     VALUES(vr_idcontrato -- Encontrato na busca pela apolice
                                           ,1+(vr_idx_benef/4)  -- Idx do Loop
                                           ,vr_tab_benef(vr_idx_benef).tag
                                           ,to_date(vr_tab_benef(vr_idx_benef+1).tag,'dd/mm/rrrr')
                                           ,vr_tab_benef(vr_idx_benef+2).tag
                                           ,to_number(vr_tab_benef(vr_idx_benef+3).tag)); 
          EXCEPTION
            WHEN OTHERS THEN
              -- Retornar erro conforme:
              pc_monta_retorno_ws(402,'Erro na criacao dos beneficiarios do Seguro Renovado: '||sqlerrm,pr_dsxmlret);
              ROLLBACK;
              RETURN;
          END;
          -- Incrementar + 4 para passar a ler o proximo benef
          vr_idx_benef := vr_idx_benef + 4;
          -- Sair quando o o idx for superior a quantidade de tags retornadas
          EXIT WHEN vr_idx_benef+1 > vr_tab_benef.count;
        END LOOP;
      END IF;
      
      -- Ao final, se a insercao do seguro tiver ocorrido com sucesso, retornamos a resposta com:
      pc_monta_retorno_ws(202,'Contrato renovado – informacao integrada ao Ayllos',pr_dsxmlret);
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        -- Acontecendo algum erro (when-others), devemos recriar o xml 
        -- e enviar o erro tratado e retornar:
        pc_monta_retorno_ws(402,'segu0002.pc_renova_contrato_seguro – Erro nao tratado -> '||sqlerrm,pr_dsxmlret);
        RETURN;
    END;
  END pc_renova_contrato_seguro;      
  
  /* Efetuar renovacao de seguro existente no Ayllos */
  PROCEDURE pc_ws_reno_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Codigo do usuario da requisicao
                                      ,pr_dsdsenha            IN VARCHAR2              --> Codigo do usuario da requisicao
                                      ,pr_idparcei            IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                      ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                      ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                      
                                      ,pr_nrproposta          IN VARCHAR2 --> Número da proposta do seguro
                                      ,pr_nrapolice           IN VARCHAR2 --> Número da apolice de seguro
                                      ,pr_nrapolice_anterior  IN VARCHAR2 --> Número da apolice anterior de seguro
                                      ,pr_nrendosso           IN VARCHAR2 --> Número do endosso do seguro
                                      ,pr_nmsegurado          IN VARCHAR2 --> Nome do segurado do seguro
                                      ,pr_nrcpfcnpj_segurado  IN VARCHAR2 --> Número do CPF ou CNPJ do segurado do seguro
                                      ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro renovado
                                      ,pr_dtinivigen          IN VARCHAR2 --> Data de início da vigência do contrato
                                      ,pr_dtfimvigen          IN VARCHAR2 --> Data de término da vigência do contrato
                                      ,pr_vlcapital_franquia  IN VARCHAR2 --> Valor de capital ou franquia do contrato
                                      ,pr_dsplano             IN VARCHAR2 --> Descritivo do plano contratado
                                      ,pr_vltot_premio_liquid IN VARCHAR2 --> Valor do prêmio líquido contratado
                                      ,pr_vltot_premio        IN VARCHAR2 --> Valor do prêmio contratado
                                      ,pr_qtparcelas          IN VARCHAR2 --> Quantidade de parcelas para pagamento do seguro
                                      ,pr_vlparcelas          IN VARCHAR2 --> Valor das parcelas para pagamento do seguro
                                      ,pr_dtdebito            IN VARCHAR2 --> Dia de débito das parcelas para pagamento do seguro
                                      ,pr_cdsegura            IN VARCHAR2 --> Codigo da seguradora vinculada ao seguro
                                      ,pr_comissao            IN VARCHAR2 --> Valor da comissao do contrato
                                      ,pr_dsobserva           IN VARCHAR2 --> Descricao da observacao do contrato
                                      ,pr_array_benef         IN VARCHAR2 -->  Array com informacoes dos beneficiarios do seguro            -->  Array com informacoes dos beneficiarios do seguro
                                      
                                      ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da crítica
                                      ,pr_dscritic OUT VARCHAR2           --> Descricao da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2) IS       -->  Saida OK/NOK
  BEGIN
    /* .............................................................................

       Programa: pc_ws_canc_contrato_seguro 
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Lucas Lombardi
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que atualizara o historico Ayllos com uma renovacao
                   da contratacao de seguro com as informacoes oriundas de WS.  

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_array_benef xmltype;
      
      vr_teste CLOB;
      
      --Variaveis de Criticas
      vr_dscritic VARCHAR2(4000);
      
    BEGIN
      
      --Informa acesso para exibir a formatacao correta
	    gene0001.pc_informa_acesso(pr_module => 'TELA_ADEPAC');
	
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
      
      vr_array_benef := XMLType.createXML(substr(pr_array_benef
                                                ,10
                                                ,(length(pr_array_benef) - 12)));
      
      vr_teste := vr_array_benef.getClobVal();
      
      pc_renova_contrato_seguro(pr_dsusuari            => pr_dsusuari           
                               ,pr_dsdsenha            => pr_dsdsenha           
                               ,pr_idparcei            => pr_idparcei           
                               ,pr_cdagecop            => pr_cdagecop           
                               ,pr_nrdconta            => pr_nrdconta           
                               ,pr_nrproposta          => pr_nrproposta         
                               ,pr_nrapolice           => pr_nrapolice          
                               ,pr_nrapolice_anterior  => pr_nrapolice_anterior 
                               ,pr_nrendosso           => pr_nrendosso          
                               ,pr_nmsegurado          => pr_nmsegurado         
                               ,pr_nrcpfcnpj_segurado  => pr_nrcpfcnpj_segurado 
                               ,pr_tpseguro            => pr_tpseguro           
                               ,pr_dtinivigen          => pr_dtinivigen         
                               ,pr_dtfimvigen          => pr_dtfimvigen         
                               ,pr_vlcapital_franquia  => pr_vlcapital_franquia 
                               ,pr_dsplano             => pr_dsplano            
                               ,pr_vltot_premio_liquid => pr_vltot_premio_liquid
                               ,pr_vltot_premio        => pr_vltot_premio       
                               ,pr_qtparcelas          => pr_qtparcelas         
                               ,pr_vlparcelas          => pr_vlparcelas         
                               ,pr_dtdebito            => pr_dtdebito           
                               ,pr_cdsegura            => pr_cdsegura           
                               ,pr_comissao            => pr_comissao           
                               ,pr_dsobserva           => pr_dsobserva          
                               ,pr_array_benef         => vr_array_benef        
                               ,pr_dsxmlret            => pr_retxml);
    EXCEPTION
      WHEN OTHERS THEN
        -- Acontecendo algum erro (when-others), devemos recriar o xml 
        -- e enviar o erro tratado e retornar:
        pc_monta_retorno_ws(402,'segu0002.pc_ws_canc_contrato_seguro – Erro nao tratado -> '||sqlerrm,pr_retxml);
        RETURN;
    END;
  END pc_ws_reno_contrato_seguro;     
  
  /* Efetuar vencimento de seguro existente no Ayllos */
  PROCEDURE pc_vence_contrato_seguro(pr_dsusuari            IN VARCHAR2              --> Codigo do usuario da requisicao
                                    ,pr_dsdsenha            IN VARCHAR2              --> Codigo do usuario da requisicao
                                    ,pr_idparcei            IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                    ,pr_cdagecop            IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                    ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                    
                                    ,pr_tpseguro            IN VARCHAR2 --> Tipo do seguro contratado
                                    ,pr_nrapolice           IN VARCHAR2 --> Número da apolice de seguro
                                    ,pr_dsobserva           IN VARCHAR2 --> Descricao da observacao do contrato
                                    
                                    ,pr_dsxmlret            OUT NOCOPY XmlType) IS   --> XML de retorno da requisicao)
  BEGIN
    /* .............................................................................

       Programa: pc_vence_contrato_seguro 
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que atualizara o historico Ayllos com o vencimento de 
                   contratacao de seguro sem renovacao com as informacoes oriundas de WS 

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Testes de retorno de rotinas
      vr_cdretorn NUMBER;
      vr_dsmsgret VARCHAR2(2000);
      vr_cdcooper crapcop.cdcooper%TYPE;
      -- Campos para conversao de texto em numero e data
      vr_nrapolice           tbseg_contratos.nrapolice%TYPE;
    BEGIN
      -- Primeiramente acionaremos a rotina das validacoes basicas:
      pc_valida_requisi_wsseguros(PR_DSUSUARI => pr_dsusuari
                                 ,PR_DSDSENHA => pr_dsdsenha
                                 ,PR_IDPARCEI => pr_idparcei
                                 ,PR_CDAGECOP => pr_cdagecop
                                 ,PR_NRDCONTA => pr_nrdconta
                                 ,pr_cdcooper => vr_cdcooper
                                 ,PR_CDRETORN => vr_cdretorn
                                 ,PR_DSMSGRET => vr_dsmsgret);
      -- Se o retorno nao for codigo 202
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;  
      -- Validar os campos numéricos recebidos
      pc_valida_char_para_numero(pr_nrapolice,'nrApolice','S',vr_nrapolice,vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      
      -- Validar campos texto obrigatórios
      pc_valida_obrigatorio(pr_dsobserva,'dsObserva',vr_cdretorn,vr_dsmsgret);
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execucao:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_dsxmlret);
        RETURN;
      END IF;
      
      -- Devemos validar também os campos de domínio: pr_tpSeguro
      IF nvl(pr_tpSeguro,' ') not in('V','G','P','A','R') THEN
        -- Retornar erro conforme:
        pc_monta_retorno_ws(402,'Campo tpSeguro invalido. Informar [V]ida Individual, Vida [G]rupo, [P]restamista, [A]uto ou [R]esidência.',pr_dsxmlret);
        RETURN;
      END IF;  
      
      -- Devemos garantir que a apolice solicitada existe
      OPEN cr_tbseg_contratos(pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_tpseguro => pr_tpseguro
                             ,pr_nrapolic => vr_nrapolice
                             ,pr_indsitua => 'A'); /*Somente ativas*/
      FETCH cr_tbseg_contratos
       INTO rw_tbseg;
      -- Se encontrou
      IF cr_tbseg_contratos%NOTFOUND THEN
        CLOSE cr_tbseg_contratos;
        -- Retornar erro
        pc_monta_retorno_ws(402,'Campo nrApolice invalida. Apolice inexistente ou Inativa para a conta solicitada.',pr_dsxmlret);
        RETURN;
      ELSE
        CLOSE cr_tbseg_contratos;
      END IF; 
      -- Passadas as validacoes, podemos atualizar as informacoes na tabela de contratos de seguros:
      BEGIN
        UPDATE tbseg_contratos
           SET cdparceiro          = pr_idparcei
              ,indsituacao         = 'V' --> Vencidaq
              ,dsobservacao        = pr_dsObserva 
              ,dtmvtolt            = SYSDATE
         WHERE idcontrato = rw_tbseg.idcontrato;                               
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar erro conforme:
          pc_monta_retorno_ws(402,'Erro na Expiracacao do Seguro: '||sqlerrm,pr_dsxmlret);
          ROLLBACK;
          RETURN;
      END;
      
      -- Ao final, se a insercao do seguro tiver ocorrido com sucesso, retornamos a resposta com:
      pc_monta_retorno_ws(202,'Vencimento aceito – informacao integrada ao Ayllos',pr_dsxmlret);
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        -- Acontecendo algum erro (when-others), devemos recriar o xml 
        -- e enviar o erro tratado e retornar:
        pc_monta_retorno_ws(402,'segu0002.pc_vence_contrato_seguro – Erro nao tratado -> '||sqlerrm,pr_dsxmlret);
        RETURN;
    END;
  END pc_vence_contrato_seguro;       

  /* Efetuar vencimento de seguro existente no Ayllos */
  PROCEDURE pc_ws_venc_contrato_seguro(pr_dsusuari  IN VARCHAR2              --> Codigo do usuario da requisicao
                                      ,pr_dsdsenha  IN VARCHAR2              --> Codigo do usuario da requisicao
                                      ,pr_idparcei  IN NUMBER                --> Codigo do Parceiro a enviar as informacoes de Seguro
                                      ,pr_cdagecop  IN crapcop.cdagectl%TYPE --> Codigo da agência da Cooperativa na central 
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da conta para contratacao do seguro
                                      
                                      ,pr_tpseguro  IN VARCHAR2 --> Tipo do seguro contratado
                                      ,pr_nrapolice IN VARCHAR2 --> Número da apolice de seguro
                                      ,pr_dsobserva IN VARCHAR2 --> Descricao da observacao do contrato
                                    
                                      ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da crítica
                                      ,pr_dscritic OUT VARCHAR2           --> Descricao da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2) IS       -->  Saida OK/NOK
  BEGIN
    /* .............................................................................

       Programa: pc_ws_canc_contrato_seguro 
       Sistema : Seguros
       Sigla   : CRED
       Autor   : Lucas Lombardi
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que atualizara o historico Ayllos com o vencimento de 
                   contratacao de seguro sem renovacao com as informacoes oriundas de WS 

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_array_benef xmltype;
      
      vr_teste CLOB;
      
      --Variaveis de Criticas
      vr_dscritic VARCHAR2(4000);
      
    BEGIN
      
      --Informa acesso para exibir a formatacao correta
	    gene0001.pc_informa_acesso(pr_module => 'TELA_ADEPAC');
	
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
     
      pc_vence_contrato_seguro(pr_dsusuari  => pr_dsusuari           
                              ,pr_dsdsenha  => pr_dsdsenha           
                              ,pr_idparcei  => pr_idparcei           
                              ,pr_cdagecop  => pr_cdagecop           
                              ,pr_nrdconta  => pr_nrdconta           
                              ,pr_tpseguro  => pr_tpseguro
                              ,pr_nrapolice => pr_nrapolice         
                              ,pr_dsobserva => pr_dsobserva          
                              ,pr_dsxmlret  => pr_retxml);
    EXCEPTION
      WHEN OTHERS THEN
        -- Acontecendo algum erro (when-others), devemos recriar o xml 
        -- e enviar o erro tratado e retornar:
        pc_monta_retorno_ws(402,'segu0002.pc_ws_canc_contrato_seguro – Erro nao tratado -> '||sqlerrm,pr_retxml);
        RETURN;
    END;
  END pc_ws_venc_contrato_seguro;     

END SEGU0002;
/
