CREATE OR REPLACE PACKAGE cecred.tela_autori IS

  PROCEDURE pc_busca_fone_sms_debaut(pr_nrdconta IN craptfc.nrdconta%TYPE
                                     
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_mantem_fone_sms_debaut(pr_nrdconta IN craptfc.nrdconta%TYPE
                                     ,pr_nrdddtfc IN craptfc.nrdddtfc%TYPE
                                     ,pr_nrtelefo IN craptfc.nrtelefo%TYPE
                                     ,pr_flgacsms IN craptfc.flgacsms%TYPE
                                      
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_exclui_fone_sms_debaut(pr_nrdconta IN craptfc.nrdconta%TYPE
  
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2); --> Erros do processo
                                     

  PROCEDURE pc_busca_fone_sms_debaut_car(pr_cdcooper IN craptfc.cdcooper%TYPE
                                        ,pr_nrdconta IN craptfc.nrdconta%TYPE
                                        ,pr_idorigem IN NUMBER
                                        
                                        ,pr_nrdddtfc OUT VARCHAR2
                                        ,pr_nrtelefo OUT VARCHAR2
                                        ,pr_dsmsgsms OUT VARCHAR2
                                         
                                        ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2); --> Mensagem Erro

  PROCEDURE pc_mantem_fone_sms_debaut_car(pr_cdcooper IN craptfc.cdcooper%TYPE
                                         ,pr_nrdconta IN craptfc.nrdconta%TYPE
                                         ,pr_idorigem IN NUMBER
                                         ,pr_nrdddtfc IN craptfc.nrdddtfc%TYPE
                                         ,pr_nrtelefo IN craptfc.nrtelefo%TYPE
                                         ,pr_flgacsms IN craptfc.flgacsms%TYPE
                                         
                                         ,pr_qtdregis OUT VARCHAR2
                                          
                                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2); --> Mensagem Erro

  PROCEDURE pc_exclui_fone_sms_debaut_car(pr_cdcooper IN craptfc.cdcooper%TYPE
                                         ,pr_nrdconta IN craptfc.nrdconta%TYPE
                                         ,pr_idorigem IN NUMBER
                                         
                                         ,pr_qtdregis OUT VARCHAR2
                                         
                                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2); --> Mensagem Erro

END tela_autori;
/
CREATE OR REPLACE PACKAGE BODY cecred.tela_autori IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_AUTORI
  --  Sistema  : Ayllos Web
  --  Autor    : Dionathan Henchel
  --  Data     : Abril - 2016.                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela AUTORI
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  vr_nmdatela VARCHAR(6) := 'AUTORI';

  PROCEDURE pc_busca_fone_sms_debaut(pr_nrdconta IN craptfc.nrdconta%TYPE
                                     
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
    Programa: pc_busca_fone_sms_debaut
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Abril/2016                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar o telefone cadastrado para recebimento de sms de débito automático
    
    Alteracoes: -----
    ..............................................................................*/
  
    -- Busca o telefone cadastrado para recebimento de SMS de débito automático
    CURSOR cr_craptfc(pr_cdcooper IN craptfc.cdcooper%TYPE
                     ,pr_nrdconta IN craptfc.nrdconta%TYPE) IS
      SELECT tfc.nrdddtfc
            ,tfc.nrtelefo
        FROM craptfc tfc
       WHERE tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.flgacsms = 1
       ORDER BY tfc.cdseqtfc;
    rw_craptfc cr_craptfc%ROWTYPE;
    
    -- Busca se a cooperativa cobra tarifa de SMS
    CURSOR cr_flgcobra_tarifa(pr_cdcooper IN tbgen_sms_param.cdcooper%TYPE) IS
    SELECT prm.flgcobra_tarifa
      FROM tbgen_sms_param prm
     WHERE prm.cdcooper = pr_cdcooper
       AND prm.cdproduto = 10; -- Débito Automático
    vr_flgcobra_tarifa tbgen_sms_param.flgcobra_tarifa%TYPE;

  
    -- Variaveis auxiliares
    vr_retxml   VARCHAR2(4000);
    vr_dsmsgsms tbgen_mensagem.dsmensagem%TYPE;
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
  
  BEGIN
  
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    -- Busca os dados de telefone do cooperado para retornar
    OPEN cr_craptfc(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
   FETCH cr_craptfc
    INTO rw_craptfc;
   CLOSE cr_craptfc;
  
    -- Busca a mensagem para retornar e exibir em tela
    vr_dsmsgsms := gene0003.fn_buscar_mensagem(pr_cdcooper        => vr_cdcooper
                                              ,pr_cdproduto       => 10 -- Débito Automatico
                                              ,pr_cdtipo_mensagem => 1);
                                              
    --Verifica se a coopertiva cobra tarifa, pois neste caso deverá concatenar outra mensagem no retorno
    OPEN cr_flgcobra_tarifa(pr_cdcooper => vr_cdcooper);
   FETCH cr_flgcobra_tarifa
    INTO vr_flgcobra_tarifa;
   CLOSE cr_flgcobra_tarifa;
   
    IF vr_flgcobra_tarifa = 1 THEN
      vr_dsmsgsms := vr_dsmsgsms || '#' || -- Separador # para separar as mensagens
                     gene0003.fn_buscar_mensagem(pr_cdcooper        => vr_cdcooper
                                                ,pr_cdproduto       => 10 -- Débito Automatico
                                                ,pr_cdtipo_mensagem => 2);
   END IF;
  
    -- Cria o XML de retorno
    vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
    vr_retxml := vr_retxml || '<Root>';
    vr_retxml := vr_retxml || '<Dados>';
    vr_retxml := vr_retxml || '<nrdddtfc>' || rw_craptfc.nrdddtfc || '</nrdddtfc>';
    vr_retxml := vr_retxml || '<nrtelefo>' || rw_craptfc.nrtelefo || '</nrtelefo>';
    vr_retxml := vr_retxml || '<dsmsgsms>' || vr_dsmsgsms || '</dsmsgsms>';
    vr_retxml := vr_retxml || '</Dados>';
    vr_retxml := vr_retxml || '</Root>';
  
    pr_retxml := xmltype.createxml(vr_retxml);
  
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      -- Retorno não OK
      pr_des_erro := 'NOK';
    
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      -- Retorno não OK
      pr_des_erro := 'NOK';
    
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    
  END pc_busca_fone_sms_debaut;

  PROCEDURE pc_mantem_fone_sms_debaut(pr_nrdconta IN craptfc.nrdconta%TYPE
                                     ,pr_nrdddtfc IN craptfc.nrdddtfc%TYPE
                                     ,pr_nrtelefo IN craptfc.nrtelefo%TYPE
                                     ,pr_flgacsms IN craptfc.flgacsms%TYPE
                                      
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  
    /* .............................................................................
    
    Programa: pc_mantem_fone_sms_debaut
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Abril/2016                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para incluir/alterar o telefone para recebimento de sms de débito automático
    
    Alteracoes: -----
    ..............................................................................*/
  
    -- Variaveis auxiliares
    vr_retxml VARCHAR2(4000);
    vr_prgqfalt craptfc.prgqfalt%TYPE;
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_auxconta INTEGER := 0; -- Contador auxiliar p/ registros atualizados
  
  BEGIN
    
    IF pr_nrdddtfc IS NULL OR pr_nrdddtfc = 0 THEN
      pr_nmdcampo := 'nrdddtfc';
      vr_dscritic := 'DDD nao informado.';
      RAISE vr_exc_saida;
    END IF;
    
    IF pr_nrtelefo IS NULL OR pr_nrtelefo = 0 THEN
      pr_nmdcampo := 'nrtelefo';
      vr_dscritic := 'Telefone nao informado.';
      RAISE vr_exc_saida;
    END IF;
    
    IF LENGTH(pr_nrtelefo) < 8 THEN
      pr_nmdcampo := 'nrtelefo';
      vr_dscritic := 'Telefone deve possuir no minimo 8 digitos.';
      RAISE vr_exc_saida;
    END IF;
    
    IF pr_nrdddtfc NOT BETWEEN 11 AND 99 THEN
      pr_nmdcampo := 'nrdddtfc';
      vr_dscritic := 'DDD invalido.';
      RAISE vr_exc_saida;
    END IF;
    
    IF SUBSTR(pr_nrtelefo,1,1) NOT IN ('7','8','9') THEN -- Verifica se é um celular válido
      pr_nmdcampo := 'nrtelefo';
      vr_dscritic := 'O telefone informado nao e um celular valido.';
      RAISE vr_exc_saida;
    END IF;
  
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    -- EXECUTA INSERÇÃO/ALTERAÇÃO DO TELEFONE QUE RECEBE SMS
    BEGIN
    
      -- Antes de atualizar o registro novo, seta flgacsms = 0 para todos os telefones
      -- da conta, para que nunca existam 2 telefones cadastrados para receber sms
      UPDATE craptfc tfc
         SET tfc.flgacsms = 0
       WHERE tfc.cdcooper = vr_cdcooper
         AND tfc.nrdconta = pr_nrdconta;
      
      -- Busca o programa que fez a alteração a partir do IDORIGEM
      vr_prgqfalt := CASE vr_idorigem
                       WHEN 1 THEN 'A' -- Ayllos
                       WHEN 2 THEN 'C' -- Caixa Online
                       WHEN 3 THEN 'I' -- Internet Bank
                       WHEN 4 THEN 'T' -- TAA
                       WHEN 5 THEN 'A' -- Ayllos Web
                     END;
    
      -- Caso o telefone já existe, altera a flag, senão, cria um registro novo com a flag setada
      MERGE INTO craptfc tfc
      USING (SELECT 1
               FROM dual) s
      ON (tfc.cdcooper = vr_cdcooper
      AND tfc.nrdconta = pr_nrdconta
      AND tfc.nrtelefo = pr_nrtelefo)
      
      WHEN MATCHED THEN
        UPDATE
           SET tfc.prgqfalt = vr_prgqfalt
              ,tfc.flgacsms = pr_flgacsms
         WHERE tfc.idseqttl =
               (SELECT MIN(tfc2.idseqttl)
                  FROM craptfc tfc2
                 WHERE tfc2.cdcooper = tfc.cdcooper
                   AND tfc2.nrdconta = tfc.nrdconta
                   AND tfc2.nrtelefo = tfc.nrtelefo) -- Validação extra para garantir que apenas um titular fique com a flag setada, mesmo se mais titulares possuírem o mesmo fone.
        
      
      WHEN NOT MATCHED THEN
        INSERT
          (tfc.cdcooper
          ,tfc.nrdconta
          ,tfc.idseqttl
          ,tfc.cdseqtfc
          ,tfc.nrdddtfc
          ,tfc.nrtelefo
          ,tfc.tptelefo
          ,tfc.prgqfalt
          ,tfc.idorigem
          ,tfc.flgacsms)
        VALUES
          (vr_cdcooper
          ,pr_nrdconta
          ,1 -- Titular fixo
          ,(SELECT NVL(MAX(tfc2.cdseqtfc),0)+1
              FROM craptfc tfc2
             WHERE tfc2.cdcooper = vr_cdcooper
               AND tfc2.nrdconta = pr_nrdconta
               AND tfc2.idseqttl = 1) -- Busca o próximo sequencial para o campo CDSEQTFC
          ,pr_nrdddtfc
          ,pr_nrtelefo
          ,2 -- Celular
          ,vr_prgqfalt
          ,1 -- Cooperado
          ,pr_flgacsms -- Envia SMS
           );
    
      vr_auxconta := SQL%ROWCOUNT;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Ocorreu um erro ao alterar o registro.';
        RAISE vr_exc_saida;
    END;
  
    IF vr_auxconta = 0 THEN
      vr_dscritic := 'Nenhum registro alterado.';
      RAISE vr_exc_saida;
    END IF;
  
    -- Cria o XML de retorno
    vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
    vr_retxml := vr_retxml || '<Root>';
    vr_retxml := vr_retxml || '<qtdregis>' || vr_auxconta || '</qtdregis>';
    vr_retxml := vr_retxml || '</Root>';
  
    pr_retxml := xmltype.createxml(vr_retxml);
  
    COMMIT;
  
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      -- Retorno não OK
      pr_des_erro := 'NOK';
    
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      -- Retorno não OK
      pr_des_erro := 'NOK';
    
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    
  END pc_mantem_fone_sms_debaut;

  PROCEDURE pc_exclui_fone_sms_debaut(pr_nrdconta IN craptfc.nrdconta%TYPE
  
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  
    /* .............................................................................
    
    Programa: pc_exclui_fone_sms_debaut
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Abril/2016                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para remover o telefone cadastrado para recebimento de sms de débito automático
    
    Alteracoes: -----
    ..............................................................................*/
  
    -- Variaveis auxiliares
    vr_retxml VARCHAR2(4000);
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_auxconta INTEGER := 0; -- Contador auxiliar p/ registros atualizados
  
  BEGIN
  
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    -- EXECUTA INSERÇÃO/ALTERAÇÃO DO TELEFONE QUE RECEBE SMS
    BEGIN
    
      -- Seta as flags de todos os telefones cadastrados para 0 (Não receber SMS)
      UPDATE craptfc tfc
         SET tfc.flgacsms = 0
       WHERE tfc.cdcooper = vr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.flgacsms <> 0;
    
      vr_auxconta := SQL%ROWCOUNT;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Ocorreu um erro ao excluir o registro.';
        RAISE vr_exc_saida;
    END;
  
    IF vr_auxconta = 0 THEN
      vr_dscritic := 'Nenhum registro excluido.';
      RAISE vr_exc_saida;
    END IF;
  
    -- Cria o XML de retorno
    vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
    vr_retxml := vr_retxml || '<Root>';
    vr_retxml := vr_retxml || '<qtdregis>' || vr_auxconta || '</qtdregis>';
    vr_retxml := vr_retxml || '</Root>';
  
    pr_retxml := xmltype.createxml(vr_retxml);
  
    COMMIT;
  
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      -- Retorno não OK
      pr_des_erro := 'NOK';
    
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      -- Retorno não OK
      pr_des_erro := 'NOK';
    
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' ||
                     SQLERRM;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      ROLLBACK;
    
  END pc_exclui_fone_sms_debaut;
  
  FUNCTION fn_gera_xml_envio_caracter(pr_cdcooper IN NUMBER DEFAULT NULL
                                     ,pr_nmprogra IN VARCHAR2 DEFAULT ' '
                                     ,pr_nmeacao  IN VARCHAR2 DEFAULT ' '
                                     ,pr_cdagenci IN VARCHAR2 DEFAULT ' '
                                     ,pr_nrdcaixa IN VARCHAR2 DEFAULT ' '
                                     ,pr_idorigem IN VARCHAR2 DEFAULT ' '
                                     ,pr_cdoperad IN VARCHAR2 DEFAULT NULL) RETURN xmltype IS
    /* .............................................................................
    
    Programa: fn_gera_xml_envio_caracter
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Abril/2016                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Função para transformar os parâmetros das rotinas _car para xml de entrada nas rotinas do ayllos web
    
    Alteracoes: -----
    ..............................................................................*/
    vr_retxml VARCHAR2(4000);
    
  BEGIN
    
  
    -- Cria o XML de input, para passar os parâmetros genéricos
    vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
    vr_retxml := vr_retxml || '<Root>';
    vr_retxml := vr_retxml || '<params>';
    vr_retxml := vr_retxml || '<cdcooper>' || pr_cdcooper || '</cdcooper>';
    vr_retxml := vr_retxml || '<nmprogra>' || pr_nmprogra || '</nmprogra>';
    vr_retxml := vr_retxml || '<nmeacao>'  || pr_nmeacao  || '</nmeacao>';
    vr_retxml := vr_retxml || '<cdagenci>' || pr_cdagenci || '</cdagenci>';
    vr_retxml := vr_retxml || '<nrdcaixa>' || pr_nrdcaixa || '</nrdcaixa>';
    vr_retxml := vr_retxml || '<idorigem>' || pr_idorigem || '</idorigem>';
    vr_retxml := vr_retxml || '<cdoperad>' || pr_cdoperad || '</cdoperad>';
    vr_retxml := vr_retxml || '</params>';
    vr_retxml := vr_retxml || '</Root>';
    
    RETURN xmltype.createxml(vr_retxml);
  END;

  PROCEDURE pc_busca_fone_sms_debaut_car(pr_cdcooper IN craptfc.cdcooper%TYPE
                                        ,pr_nrdconta IN craptfc.nrdconta%TYPE
                                        ,pr_idorigem IN NUMBER
                                        
                                        ,pr_nrdddtfc OUT VARCHAR2
                                        ,pr_nrtelefo OUT VARCHAR2
                                        ,pr_dsmsgsms OUT VARCHAR2
                                         
                                        ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS --> Mensagem Erro
    /* .............................................................................
    
    Programa: pc_busca_fone_sms_debaut
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Abril/2016                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Chamada caracter para procedure tela_autori.pc_busca_fone_sms_debaut
    
    Alteracoes: -----
    ..............................................................................*/
  
    vr_retxml xmltype;
    pr_xmllog VARCHAR2(4000);
  
  BEGIN
    
    -- Cria o XML de entrada, para passar os parâmetros genéricos para a procedure do AyllosWeb
    vr_retxml := fn_gera_xml_envio_caracter(pr_cdcooper => pr_cdcooper
                                           ,pr_idorigem => pr_idorigem);
   
    -- Rotina para buscar o telefone cadastrado para recebimento de sms de débito automático
    pc_busca_fone_sms_debaut(pr_nrdconta => pr_nrdconta
                             
                            ,pr_xmllog   => pr_xmllog
                            ,pr_cdcritic => pr_cdcritic
                            ,pr_dscritic => pr_dscritic
                            ,pr_retxml   => vr_retxml
                            ,pr_nmdcampo => pr_nmdcampo
                            ,pr_des_erro => pr_des_erro);
  
    pr_nrdddtfc := gene0007.fn_valor_tag(vr_retxml,0,'nrdddtfc');
    pr_nrtelefo := gene0007.fn_valor_tag(vr_retxml,0,'nrtelefo');
    pr_dsmsgsms := gene0007.fn_valor_tag(vr_retxml,0,'dsmsgsms');
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro chamar obter tela_autori.pc_busca_fone_sms_debaut: ' ||
                     SQLERRM;
    
  END pc_busca_fone_sms_debaut_car;

  PROCEDURE pc_mantem_fone_sms_debaut_car(pr_cdcooper IN craptfc.cdcooper%TYPE
                                         ,pr_nrdconta IN craptfc.nrdconta%TYPE
                                         ,pr_idorigem IN NUMBER
                                         ,pr_nrdddtfc IN craptfc.nrdddtfc%TYPE
                                         ,pr_nrtelefo IN craptfc.nrtelefo%TYPE
                                         ,pr_flgacsms IN craptfc.flgacsms%TYPE
                                         
                                         ,pr_qtdregis OUT VARCHAR2
                                          
                                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS --> Mensagem Erro
    /* .............................................................................
    
    Programa: pc_busca_fone_sms_debaut
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Abril/2016                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Chamada caracter para procedure tela_autori.pc_mantem_fone_sms_debaut
    
    Alteracoes: -----
    ..............................................................................*/
  
    vr_retxml xmltype;
    pr_xmllog VARCHAR2(4000);
  
  BEGIN
    
    -- Cria o XML de entrada, para passar os parâmetros genéricos para a procedure do AyllosWeb
    vr_retxml := fn_gera_xml_envio_caracter(pr_cdcooper => pr_cdcooper
                                           ,pr_idorigem => pr_idorigem);
    
    -- Rotina para incluir/alterar o telefone para recebimento de sms de débito automático
    pc_mantem_fone_sms_debaut(pr_nrdconta => pr_nrdconta
                             ,pr_nrdddtfc => pr_nrdddtfc
                             ,pr_nrtelefo => pr_nrtelefo
                             ,pr_flgacsms => pr_flgacsms
                             
                             ,pr_xmllog   => pr_xmllog
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_retxml   => vr_retxml
                             ,pr_nmdcampo => pr_nmdcampo
                             ,pr_des_erro => pr_des_erro);
    
    pr_qtdregis := gene0007.fn_valor_tag(vr_retxml,0,'qtdregis');
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro chamar obter tela_autori.pc_busca_fone_sms_debaut: ' ||
                     SQLERRM;
    
  END pc_mantem_fone_sms_debaut_car;

  PROCEDURE pc_exclui_fone_sms_debaut_car(pr_cdcooper IN craptfc.cdcooper%TYPE
                                         ,pr_nrdconta IN craptfc.nrdconta%TYPE
                                         ,pr_idorigem IN NUMBER
    
                                         ,pr_qtdregis OUT VARCHAR2
                                         
                                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS --> Mensagem Erro
    /* .............................................................................
    
    Programa: pc_busca_fone_sms_debaut
    Sistema : Ayllos Web
    Autor   : Dionathan Henchel
    Data    : Abril/2016                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Chamada caracter para procedure tela_autori.pc_busca_fone_sms_debaut
    
    Alteracoes: -----
    ..............................................................................*/
  
    vr_retxml xmltype;
    pr_xmllog VARCHAR2(4000);
  
  BEGIN
    
    -- Cria o XML de entrada, para passar os parâmetros genéricos para a procedure do AyllosWeb
    vr_retxml := fn_gera_xml_envio_caracter(pr_cdcooper => pr_cdcooper
                                           ,pr_idorigem => pr_idorigem);
    
    -- Rotina para buscar o telefone cadastrado para recebimento de sms de débito automático
    pc_exclui_fone_sms_debaut(pr_nrdconta => pr_nrdconta
                              
                             ,pr_xmllog   => pr_xmllog
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_retxml   => vr_retxml
                             ,pr_nmdcampo => pr_nmdcampo
                             ,pr_des_erro => pr_des_erro);
  
    pr_qtdregis := gene0007.fn_valor_tag(vr_retxml,0,'qtdregis');
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro chamar obter tela_autori.pc_exclui_fone_sms_debaut: ' ||
                     SQLERRM;
    
  END pc_exclui_fone_sms_debaut_car;

END tela_autori;
/
