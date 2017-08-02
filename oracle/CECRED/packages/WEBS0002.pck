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
  /*---------------------------------------------------------------------------
  
    Programa : WEBS0002
    Sistema  : Rotinas referentes ao WebService de propostas
    Sigla    : WEBS
    Autor    : Guilherme/SUPERO
    Data     : Abril/2016.                   Ultima atualizacao: 18/04/2017
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Centralizar rotinas relacionadas ao WebService de Cooperado
  
   Alteracoes: 18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
  
  -------------------------------------------------------------------------*/

  vr_exc_saida    EXCEPTION;


 PROCEDURE pc_verifica_cooperado_ret(pr_status   IN PLS_INTEGER           --> Status
                                    ,pr_nrdocnpj IN crapcop.nrdocnpj%TYPE --> CNPJ da Cooperativa
                                    ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE --> CPF/CNPJ a ser consultado
                                    ,pr_inpessoa IN VARCHAR2              --> Tipo de Pessoa => F-Fisica / J-Juridioca / R-Raiz
                                    ,pr_retxml   OUT NOCOPY XMLType) IS    --> Arquivo de retorno do XML
  BEGIN
    /* .............................................................................
     Programa: pc_ret_verifica_cooperado
     Sistema : Rotinas referentes ao WebService
     Sigla   : WEBS
     Autor   : Guilherme/SUPERO
     Data    : Abril/16.                    Ultima atualizacao: 18/04/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Gerar RETORNO para a Verificação de Cooperado

     Observacao: -----
     
     Alteracoes: 14/07/2016 - SD488098 - Ajustes para retorno de outros titulares
                                       - Retorno da raiz recebendo CNPJ completo (Marcos-Supero)
     
				 18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).
     
     ..............................................................................*/
    DECLARE

      -- Tratamento de erros
      vr_status   NUMBER;
      vr_des_erro VARCHAR2(10000);
      
      vr_cont_ass NUMBER := -1;
      vr_cont_enc NUMBER := -1;            
      
      /* Validação da Cooperativa */
      CURSOR cr_crapcop (pr_nrdocnpj crapcop.nrdocnpj%TYPE)IS
        SELECT cop.cdcooper
          FROM crapcop cop
         WHERE cop.nrdocnpj = pr_nrdocnpj;
        rw_crapcop cr_crapcop%ROWTYPE;

      /* Validação do Associado */
      CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE
                        ,pr_inpessoa VARCHAR2)IS
        SELECT nrcpfcgc
              ,row_number() OVER(PARTITION BY nrcpfcgc ORDER BY nrcpfcgc) nrdordem
              ,nrdconta
              ,substr(nmprimtl,1,60) nmprimtl
              ,decode(inpessoa,1,'F','J') inpessoa
              ,idseqttl
          FROM (      SELECT ttl.nrcpfcgc
                            ,ass.nrdconta
                            ,ttl.nmextttl nmprimtl
                            ,ttl.inpessoa  
                            ,ttl.idseqttl                  
                        FROM crapass ass
                            ,crapttl ttl
                       WHERE pr_inpessoa = 'F'
                         AND ass.cdcooper = ttl.cdcooper
                         AND ass.nrdconta = ttl.nrdconta
                         AND ttl.cdcooper = pr_cdcooper
                         AND ttl.nrcpfcgc = pr_nrcpfcgc
                         AND ass.inpessoa = 1
                         AND ass.dtdemiss IS NULL --> Não podem ser demitidos         
                         
                      UNION
                      
                      SELECT ass.nrcpfcgc
                            ,ass.nrdconta
                            ,ass.nmprimtl
                            ,ass.inpessoa
                            ,1   idseqttl
                        FROM crapass ass
                       WHERE pr_inpessoa = 'J'
                         AND ass.cdcooper = pr_cdcooper
                         AND ass.nrcpfcgc = pr_nrcpfcgc
                         AND ass.inpessoa = 2
                         AND dtdemiss IS NULL --> Não podem ser demitidos         
                      
                      UNION
                      
                      SELECT ass.nrcpfcgc
                            ,ass.nrdconta
                            ,ass.nmprimtl
                            ,ass.inpessoa
                            ,1   idseqttl
                        FROM crapass ass
                       WHERE pr_inpessoa = 'R'
                         AND ass.cdcooper = pr_cdcooper
                         AND substr(to_char(ass.nrcpfcgc),1,LENGTH(ass.nrcpfcgc)-6) = substr(to_char(pr_nrcpfcgc),1,LENGTH(pr_nrcpfcgc)-6)
                         AND ass.inpessoa = 2  -- Busca pela Raiz CNPJ
                         AND ass.dtdemiss IS NULL --> Não podem ser demitidos  
               );
         
      vr_flgachou BOOLEAN := FALSE;

      /* Busca dos endereços do Cooperado */
      CURSOR cr_endereco(pr_cdcooper crapass.cdcooper%TYPE
                        ,pr_nrdconta crapass.nrcpfcgc%TYPE
                        ,pr_idseqttl crapttl.idseqttl%TYPE) IS
      SELECT (enc.dsendere||', '|| enc.nrendere) AS dsendere
            ,enc.nmbairro
            ,enc.nmcidade
            ,enc.nrcepend
            ,enc.cdufende
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.idseqttl = pr_idseqttl
         AND enc.dsendere <> ' '; -- Desprezar endereços incompletos
      
      /* PLTable para evitar endereços repetidos */
      TYPE typ_tab_endere IS
        TABLE OF PLS_INTEGER
          INDEX BY VARCHAR2(100);
      vr_tab_endere typ_tab_endere;
        
      
    BEGIN

      
      --> Buscar Cooperativa pelo CNPJ
      OPEN cr_crapcop(pr_nrdocnpj => pr_nrdocnpj);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Caso nao encontrar abortar proceso
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_status   := 202;
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapcop;

 
      --> Buscar Associados
      FOR rw_crapass IN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper
                                  ,pr_nrcpfcgc => pr_nrcpfcgc
                                  ,pr_inpessoa => pr_inpessoa) LOOP

        -- No primeiro registro
        IF NOT vr_flgachou THEN 
          -- Ativar flag de encontro
          vr_flgachou := TRUE;

          -- Inicializar o XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Root'    
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'status'     
                                ,pr_tag_cont => pr_status  
                                ,pr_des_erro => vr_des_erro);
        END IF;

        -- Someente No primeiro registro do CPF/CNPJ
        IF rw_crapass.nrdordem = 1 THEN
          
          -- Limpar pltable dos endereços
          vr_tab_endere.delete;
        
          -- Incrementar contador de associados
          vr_cont_ass := vr_cont_ass + 1;
          
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
                               , pr_tag_cont => rw_crapass.nmprimtl
                               , pr_des_erro => vr_des_erro);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                               , pr_tag_pai  => 'Cooperado'
                               , pr_posicao  => vr_cont_ass
                               , pr_tag_nova => 'InPessoa'
                               , pr_tag_cont => rw_crapass.inpessoa
                               , pr_des_erro => vr_des_erro);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                               , pr_tag_pai  => 'Cooperado'
                               , pr_posicao  => vr_cont_ass
                               , pr_tag_nova => 'flCooperado'
                               , pr_tag_cont => 'S'
                               , pr_des_erro => vr_des_erro);
          
          -- Verificar os Endereços do Cooperado
          FOR rw_endereco IN cr_endereco(rw_crapcop.cdcooper
                                        ,rw_crapass.nrdconta
                                        ,rw_crapass.idseqttl) LOOP

            -- Somente enviar ao XML se o endereço não existe na pltable de endereços
            IF NOT vr_tab_endere.exists(rpad(rw_endereco.nrcepend,10,'0')||rw_endereco.dsendere) THEN
              -- Contador de Nr de Endereços do Associado (Niveis)
              vr_cont_enc := vr_cont_enc + 1;            

              -- Inclui o mesmo na pltable
              vr_tab_endere(rpad(rw_endereco.nrcepend,10,'0')||rw_endereco.dsendere) := vr_cont_enc;  
            
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
            END IF;                       

          END LOOP; -- LOOP CRAPENC
        
        END IF;  
        
        -- Continuar buscando as próximas contas somente para pesquisas por Raiz
        IF pr_inpessoa <> 'R' THEN
          EXIT;
        END IF;
        
      END LOOP; -- LOOP CRAPASS
      
      -- Caso nao encontrar abortar proceso
      IF NOT vr_flgachou THEN
        vr_status   := 202;
        RAISE vr_exc_saida;
      END IF;        

      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'     , pr_posicao => 0, pr_tag_nova => 'status'     , pr_tag_cont => vr_status  , pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'     , pr_posicao => 0, pr_tag_nova => 'Cooperado'  , pr_tag_cont => NULL       , pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'nrCpfCnpj'  , pr_tag_cont => pr_nrcpfcgc, pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'InPessoa'   , pr_tag_cont => pr_inpessoa, pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'flCooperado', pr_tag_cont => 'N'        , pr_des_erro => vr_des_erro);

        
      WHEN OTHERS THEN
        vr_status   := 401;        
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'     , pr_posicao => 0, pr_tag_nova => 'status'     , pr_tag_cont => vr_status  , pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'     , pr_posicao => 0, pr_tag_nova => 'Cooperado'  , pr_tag_cont => NULL       , pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'nrCpfCnpj'  , pr_tag_cont => pr_nrcpfcgc, pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'InPessoa'   , pr_tag_cont => pr_inpessoa, pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'flCooperado', pr_tag_cont => 'N'        , pr_des_erro => vr_des_erro);
        
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
      vr_des_erro     VARCHAR2(1000);

      vr_chavereq     VARCHAR2(10000);      --> Cliente ID
      vr_chavecli     VARCHAR2(10000);      --> Cliente ID
      vr_status       PLS_INTEGER;          --> Status
      

    BEGIN

      -- Vamos verificar a chave de acesso (Desenvolvimento/Producao)
      vr_chavecli    := utl_encode.text_encode(pr_usuario || ':' || pr_senha,'WE8ISO8859P1', UTL_ENCODE.BASE64);
      vr_chavereq := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'IDWEBSERVICE_WEBJUD');
      -- Condicao para verificar se o cliente tem acesso
      IF vr_chavecli <> vr_chavereq THEN
        -- Montar mensagem de critica
        vr_status      := 401;
        RAISE vr_exc_saida;
      END IF;


      -- So chega aqui quando for SUCESSO na validação do usuario
      vr_status := 202;
      pc_verifica_cooperado_ret(pr_status   => vr_status      --> Status
                               ,pr_nrdocnpj => pr_nrdocnpj
                               ,pr_nrcpfcgc => pr_nrcpfcgc
                               ,pr_inpessoa => pr_inpessoa
                               ,pr_retxml   => pr_retxml);

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Gera retorno
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'     , pr_posicao => 0, pr_tag_nova => 'status'     , pr_tag_cont => vr_status  , pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'     , pr_posicao => 0, pr_tag_nova => 'Cooperado'  , pr_tag_cont => NULL       , pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'nrCpfCnpj'  , pr_tag_cont => pr_nrcpfcgc, pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'InPessoa'   , pr_tag_cont => pr_inpessoa, pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'flCooperado', pr_tag_cont => 'N'        , pr_des_erro => vr_des_erro);

      WHEN OTHERS THEN
        -- Gera retorno da proposta para a esteira
        vr_status      := 401;
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'     , pr_posicao => 0, pr_tag_nova => 'status'     , pr_tag_cont => vr_status  , pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root'     , pr_posicao => 0, pr_tag_nova => 'Cooperado'  , pr_tag_cont => NULL       , pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'nrCpfCnpj'  , pr_tag_cont => pr_nrcpfcgc, pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'InPessoa'   , pr_tag_cont => pr_inpessoa, pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Cooperado', pr_posicao => 0, pr_tag_nova => 'flCooperado', pr_tag_cont => 'N'        , pr_des_erro => vr_des_erro);
    END;

  END pc_verifica_cooperado;

END WEBS0002;
/
