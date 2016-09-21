CREATE OR REPLACE PACKAGE CECRED.WEBS0002 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : WEBS0002
  --  Sistema  : Rotinas referentes ao WebService de Consulta Cooperado
  --  Sigla    : CRED
  --  Autor    : Guilherme/SUPERO
  --  Data     : Abril/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de Cooperados
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  
  
  PROCEDURE pc_verifica_cooperado(pr_usuario  IN VARCHAR2              --> Usuario
                                 ,pr_senha    IN VARCHAR2              --> Senha
                                 ,pr_nrdocnpj IN crapcop.nrdocnpj%TYPE --> CNPJ da Cooperativa
                                 ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE --> CPF/CNPJ a ser consultado
                                 ,pr_inpessoa IN VARCHAR2              --> Tipo de Pessoa => F-Fisica / J-Juridioca / R-Raiz
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2
                                 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

END WEBS0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.WEBS0002 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : WEBS0002
  --  Sistema  : Rotinas referentes ao WebService de propostas
  --  Sigla    : WEBS
  --  Autor    : Guilherme/SUPERO
  --  Data     : Abril/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de Cooperado
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  vr_exc_saida    EXCEPTION;


 PROCEDURE pc_verifica_cooperado_ret(pr_status   IN PLS_INTEGER           --> Status
                                    ,pr_nrdocnpj IN crapcop.nrdocnpj%TYPE --> CNPJ da Cooperativa
                                    ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE --> CPF/CNPJ a ser consultado
                                    ,pr_inpessoa IN VARCHAR2              --> Tipo de Pessoa => F-Fisica / J-Juridioca / R-Raiz
                                    ,pr_dscritic IN VARCHAR2 DEFAULT NULL --> Descricao da critica
                                    ,pr_retxml   OUT NOCOPY XMLType) IS    --> Arquivo de retorno do XML
  BEGIN
    /* .............................................................................
     Programa: pc_ret_verifica_cooperado
     Sistema : Rotinas referentes ao WebService
     Sigla   : WEBS
     Autor   : Guilherme/SUPERO
     Data    : Abril/16.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Gerar RETORNO para a Verificação de Cooperado

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE

      -- Tratamento de erros
      vr_dscritic VARCHAR2(10000);
      vr_status   NUMBER;
      vr_des_erro VARCHAR2(10000);
      
      vr_cont_ass NUMBER:=0;
      vr_cont_enc NUMBER:=0;            
      
      vr_inpessoa VARCHAR2(1);
      

      CURSOR cr_crapcop (pr_nrdocnpj crapcop.nrdocnpj%TYPE)IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.nrdocnpj = pr_nrdocnpj;
      rw_crapcop cr_crapcop%ROWTYPE;


      CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE
                        ,pr_inpessoa VARCHAR2)IS
        SELECT MIN(nrdconta) nrdconta
              ,MIN(nmprimtl) nmprimtl
              ,MIN(inpessoa) inpessoa
              ,nrcpfcgc
        FROM (SELECT ass.nrdconta
                    ,ass.nmprimtl
                    ,ass.nrcpfcgc
                    ,ass.inpessoa
                FROM crapass ass
               WHERE pr_inpessoa IN ('F','J')
                 AND ass.cdcooper = pr_cdcooper
                 AND ass.nrcpfcgc = pr_nrcpfcgc
                 AND ass.inpessoa = DECODE(pr_inpessoa,'F',1,2)
                 AND dtdemiss IS NULL --> Não podem ser demitidos         
              UNION
              SELECT ass.nrdconta
                    ,ass.nmprimtl
                    ,ass.nrcpfcgc
                    ,ass.inpessoa
                FROM crapass ass
               WHERE pr_inpessoa = 'R'
                 AND ass.cdcooper = pr_cdcooper
                 AND substr(to_char(ass.nrcpfcgc),1,LENGTH(ass.nrcpfcgc)-6) = pr_nrcpfcgc
                 AND ass.inpessoa = 2  -- Busca pela Raiz CNPJ
                 AND ass.dtdemiss IS NULL --> Não podem ser demitidos  
              )
              GROUP BY nrcpfcgc;
         
      rw_crapass cr_crapass%ROWTYPE;


      CURSOR cr_endereco(pr_cdcooper crapass.cdcooper%TYPE
                        ,pr_nrdconta crapass.nrcpfcgc%TYPE)IS
      SELECT (enc.dsendere||', '|| enc.nrendere) AS dsendere
            ,enc.nmbairro
            ,enc.nmcidade
            ,enc.nrcepend
            ,enc.cdufende
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.idseqttl = 1
         AND enc.dsendere <> ' '; -- Desprezar endereços incompletos

        

    BEGIN

      -- É para enviar retorno com ERRO
      IF NVL(pr_dscritic,' ') <> ' ' THEN

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'     , pr_posicao => 0, pr_tag_nova => 'status'     , pr_tag_cont => pr_status  , pr_des_erro => vr_des_erro);
--        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'     , pr_posicao => 0, pr_tag_nova => 'dsCritic'   , pr_tag_cont => pr_dscritic, pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'     , pr_posicao => 0, pr_tag_nova => 'Cooperado'  , pr_tag_cont => NULL       , pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'nrCpfCnpj'  , pr_tag_cont => pr_nrcpfcgc, pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'InPessoa'   , pr_tag_cont => pr_inpessoa, pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'flCooperado', pr_tag_cont => 'N'        , pr_des_erro => vr_des_erro);

      ELSE -- Gerar retorno com sucesso

        --> Buscar Cooperativa pelo CNPJ
        OPEN cr_crapcop(pr_nrdocnpj => pr_nrdocnpj);
        FETCH cr_crapcop INTO rw_crapcop;

        -- Caso nao encontrar abortar proceso
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          vr_status   := 202;
          vr_dscritic := 'Nr do CNPJ invalido!';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapcop;


        --> Buscar Associado
        OPEN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nrcpfcgc => pr_nrcpfcgc
                        ,pr_inpessoa => pr_inpessoa);

        FETCH cr_crapass INTO rw_crapass;

        -- Caso nao encontrar abortar proceso
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_status   := 202;
          vr_dscritic := gene0001.fn_busca_critica(9);
          RAISE vr_exc_saida;
        END IF;


        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'    , pr_posicao => 0, pr_tag_nova => 'status'     , pr_tag_cont => pr_status  , pr_des_erro => vr_des_erro);
--        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'    , pr_posicao => 0, pr_tag_nova => 'dsCritic'   , pr_tag_cont => pr_dscritic, pr_des_erro => vr_des_erro);

        -- Para cada Cooperado que encontrar com CPF/CNPJ
        LOOP        

          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS ou NÃO FOR 'R'
          EXIT 
             WHEN cr_crapass%NOTFOUND
               OR (vr_cont_ass = 1 AND pr_inpessoa <> 'R'); -- Se nao for RAIZ, só pega o 1o Associado


          IF rw_crapass.inpessoa = 1 THEN
            vr_inpessoa := 'F';
          ELSE
            vr_inpessoa := 'J';
          END IF;

          -- TAG Pai "Cooperado"
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                               , pr_tag_pai  => 'Root'
                               , pr_posicao  => 0
                               , pr_tag_nova => 'Cooperado'
                               , pr_tag_cont => NULL
                               , pr_des_erro => vr_des_erro);

          -- TAGs filhos do "Cooperado"
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                               , pr_tag_pai  => 'Cooperado'
                               , pr_posicao  => vr_cont_ass
                               , pr_tag_nova => 'nrCpfCnpj'
                               , pr_tag_cont => rw_crapass.nrcpfcgc
                               , pr_des_erro => vr_des_erro);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                               , pr_tag_pai  => 'Cooperado'
                               , pr_posicao  => vr_cont_ass
                               , pr_tag_nova => 'NmPrimTl'
                               , pr_tag_cont => substr(rw_crapass.nmprimtl,1,60)
                               , pr_des_erro => vr_des_erro);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                               , pr_tag_pai  => 'Cooperado'
                               , pr_posicao  => vr_cont_ass
                               , pr_tag_nova => 'InPessoa'
                               , pr_tag_cont => vr_inpessoa
                               , pr_des_erro => vr_des_erro);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                               , pr_tag_pai  => 'Cooperado'
                               , pr_posicao  => vr_cont_ass
                               , pr_tag_nova => 'flCooperado'
                               , pr_tag_cont => 'S'
                               , pr_des_erro => vr_des_erro);
            
          -- Verificar os Endereços do Cooperado
          FOR rw_endereco IN cr_endereco(rw_crapcop.cdcooper
                                        ,rw_crapass.nrdconta) LOOP

            -- TAG Pai "Logrado"
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                 , pr_tag_pai  => 'Cooperado'
                                 , pr_posicao  => vr_cont_ass
                                 , pr_tag_nova => 'Logrado'
                                 , pr_tag_cont => NULL
                                 , pr_des_erro => vr_des_erro);

            -- TAGs filhos do "Logrado"
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                 , pr_tag_pai  => 'Logrado'
                                 , pr_posicao  => vr_cont_enc
                                 , pr_tag_nova => 'dsEndere'
                                 , pr_tag_cont => substr(rw_endereco.dsendere,1,40)
                                 , pr_des_erro => vr_des_erro);

            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                 , pr_tag_pai  => 'Logrado'
                                 , pr_posicao  => vr_cont_enc
                                 , pr_tag_nova => 'nmBairro'
                                 , pr_tag_cont => substr(rw_endereco.nmbairro,1,40)
                                 , pr_des_erro => vr_des_erro);

            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                 , pr_tag_pai  => 'Logrado'
                                 , pr_posicao  => vr_cont_enc
                                 , pr_tag_nova => 'nmCidade'
                                 , pr_tag_cont => substr(rw_endereco.nmcidade,1,25)
                                 , pr_des_erro => vr_des_erro);

            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                 , pr_tag_pai  => 'Logrado'
                                 , pr_posicao  => vr_cont_enc
                                 , pr_tag_nova => 'nrCEPEnd'
                                 , pr_tag_cont => rw_endereco.nrcepend
                                 , pr_des_erro => vr_des_erro);

            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                 , pr_tag_pai  => 'Logrado'
                                 , pr_posicao  => vr_cont_enc
                                 , pr_tag_nova => 'cdUFEnde'
                                 , pr_tag_cont => rw_endereco.cdufende
                                 , pr_des_erro => vr_des_erro);

            -- Contador de Nr de Endereços do Associado (Niveis)
            vr_cont_enc := vr_cont_enc + 1;
              
          END LOOP; -- LOOP CRAPENC

          -- Contador de Nr de Associados (Niveis)
          vr_cont_ass := vr_cont_ass + 1;

          FETCH cr_crapass INTO rw_crapass;

        END LOOP; -- LOOP CRAPASS

      END IF; -- Fim IF dscritic <> ''
      
      IF cr_crapass%ISOPEN THEN
        CLOSE cr_crapass;
      END IF;



    EXCEPTION
      WHEN vr_exc_saida THEN
        IF cr_crapass%ISOPEN THEN
          CLOSE cr_crapass;
        END IF;
        -- Gera retorno da proposta para a esteira
        pc_verifica_cooperado_ret(pr_status   => vr_status      --> Status
                                 ,pr_nrdocnpj => pr_nrdocnpj
                                 ,pr_nrcpfcgc => pr_nrcpfcgc
                                 ,pr_inpessoa => pr_inpessoa
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_retxml   => pr_retxml);

      WHEN OTHERS THEN
        IF cr_crapass%ISOPEN THEN
          CLOSE cr_crapass;
        END IF;
        vr_status   := 401;
        vr_dscritic := SQLERRM;
        -- Gera retorno da proposta para a esteira
        pc_verifica_cooperado_ret(pr_status   => vr_status      --> Status
                                 ,pr_nrdocnpj => pr_nrdocnpj
                                 ,pr_nrcpfcgc => pr_nrcpfcgc
                                 ,pr_inpessoa => pr_inpessoa
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_retxml   => pr_retxml);
    END;

  END pc_verifica_cooperado_ret;



  PROCEDURE pc_verifica_cooperado(pr_usuario  IN VARCHAR2              --> Usuario
                                 ,pr_senha    IN VARCHAR2              --> Senha
                                 ,pr_nrdocnpj IN crapcop.nrdocnpj%TYPE --> CNPJ da Cooperativa
                                 ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE --> CPF/CNPJ a ser consultado
                                 ,pr_inpessoa IN VARCHAR2              --> Tipo de Pessoa => F-Fisica / J-Juridioca / R-Raiz
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................
     Programa: pc_verifica_cooperado
     Sistema : Rotinas referentes ao WebService
     Sigla   : WEBS
     Autor   : Guilherme/SUPERO
     Data    : Abril/16.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Entrada para consultar dados do Cooperado

     Observacao: -----

     Alteracoes:

     ..............................................................................*/
    DECLARE

      -- Tratamento de erros
      vr_dscritic     crapcri.dscritic%TYPE;
      vr_des_reto     VARCHAR2(3);

      vr_chavereq     VARCHAR2(10000);      --> Cliente ID
      vr_chavecli     VARCHAR2(10000);      --> Cliente ID
      vr_status       PLS_INTEGER;          --> Status
      vr_msg_detalhe  VARCHAR2(10000);      --> Detalhe da mensagem


    BEGIN

      -- Vamos verificar a chave de acesso (Desenvolvimento/Producao)
      vr_dscritic    := NULL;
      vr_chavecli    := utl_encode.text_encode(pr_usuario || ':' || pr_senha,'WE8ISO8859P1', UTL_ENCODE.BASE64);
      vr_chavereq := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'IDWEBSERVICE_WEBJUD');
      -- Condicao para verificar se o cliente tem acesso
      IF vr_chavecli <> vr_chavereq THEN
        -- Montar mensagem de critica
        vr_status      := 401;
        vr_msg_detalhe := 'Credenciais de acesso nao autorizada.';
        RAISE vr_exc_saida;
      END IF;


      -- So chega aqui quando for SUCESSO na validação do usuario
      vr_status := 202;
      pc_verifica_cooperado_ret(pr_status   => vr_status      --> Status
                               ,pr_nrdocnpj => pr_nrdocnpj
                               ,pr_nrcpfcgc => pr_nrcpfcgc
                               ,pr_inpessoa => pr_inpessoa
                               ,pr_dscritic => vr_msg_detalhe
                               ,pr_retxml   => pr_retxml);

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Gera retorno
        pc_verifica_cooperado_ret(pr_status   => vr_status      --> Status
                                 ,pr_nrdocnpj => pr_nrdocnpj
                                 ,pr_nrcpfcgc => pr_nrcpfcgc
                                 ,pr_inpessoa => pr_inpessoa
                                 ,pr_dscritic => vr_msg_detalhe
                                 ,pr_retxml   => pr_retxml);
      WHEN OTHERS THEN
        -- Gera retorno da proposta para a esteira
        vr_status      := 401;
        vr_dscritic    := SQLERRM;
        pc_verifica_cooperado_ret(pr_status   => vr_status      --> Status
                                 ,pr_nrdocnpj => pr_nrdocnpj
                                 ,pr_nrcpfcgc => pr_nrcpfcgc
                                 ,pr_inpessoa => pr_inpessoa
                                 ,pr_dscritic => vr_msg_detalhe
                                 ,pr_retxml   => pr_retxml);
    END;

  END pc_verifica_cooperado;

END WEBS0002;
/
