create or replace package cecred.tela_tab057 is

  -- Created : 19/01/2018 14:14:05
  -- Purpose : Centralizar rotinas relacionadas a tela TAB057
  
  -- Definição do tipo de registro
  TYPE typ_reg_crapcon IS
  RECORD (cdempres tbconv_arrecadacao.cdempres%TYPE
         ,nmextcon crapcon.nmextcon%TYPE
         );

  -- Definição do tipo de tabela registro
  TYPE typ_tab_crapcon IS TABLE OF typ_reg_crapcon INDEX BY PLS_INTEGER;
  
  -- Rotina para buscar a lista de cooperativas
  PROCEDURE pc_lista_cooperativas(pr_cdcooper IN     crapcop.cdcooper%TYPE -- Código da Cooperativa
                                 ,pr_flgativo IN     crapcop.flgativo%TYPE -- Flag Ativo         
                                 ,pr_xmllog   IN     VARCHAR2              -- XML com informações de LOG
                                 ,pr_cdcritic OUT    PLS_INTEGER           -- Código da crítica
                                 ,pr_dscritic OUT    VARCHAR2              -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype        -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT    VARCHAR2              -- Nome do campo com erro
                                 ,pr_des_erro OUT    VARCHAR2              -- Descricao do Erro
                                 );
  -- Rotina para buscar os sequenciais Sicredi
  PROCEDURE pc_busca_seq_sicredi(pr_cdcooper IN     craptab.cdcooper%TYPE -- Código da cooperativa
                                ,pr_xmllog   IN     VARCHAR2              -- XML com informações de LOG
                                ,pr_cdcritic OUT    PLS_INTEGER           -- Código da crítica
                                ,pr_dscritic OUT    VARCHAR2              -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype        -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT    VARCHAR2              -- Nome do campo com erro
                                ,pr_des_erro OUT    VARCHAR2              -- Descrição do Erro
                                );
  -- Rotina para atualizar os sequenciais Sicredi
  PROCEDURE pc_atualiza_seq_sicredi(pr_cdcooper IN     craptab.cdcooper%TYPE -- Código da cooperativa
                                   ,pr_seqarfat IN     NUMBER                -- Seq. Arq. Arrec. Faturas
                                   ,pr_seqtrife IN     NUMBER                -- Seq. Arq. Trib. Federal
                                   ,pr_seqconso IN     NUMBER                -- Seq. Arq. Atualização Consórcios
                                   ,pr_xmllog   IN     VARCHAR2              -- XML com informações de LOG
                                   ,pr_cdcritic OUT    PLS_INTEGER           -- Código da crítica
                                   ,pr_dscritic OUT    VARCHAR2              -- Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype        -- Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT    VARCHAR2              -- Nome do campo com erro
                                   ,pr_des_erro OUT    VARCHAR2              -- Descrição do Erro
                                   );
  -- Rotina para listar os convênios
  PROCEDURE pc_lista_convenios(pr_cdcooper IN  crapcon.cdcooper%TYPE            -- Código da cooperativa
                              ,pr_cdempres IN  tbconv_arrecadacao.cdempres%TYPE -- Código do convênio
                              ,pr_nmextcon IN  crapcon.nmextcon%TYPE            -- Descrição do convênio
                              ,pr_nriniseq IN PLS_INTEGER                       -- Numero inicial do registro para enviar
                              ,pr_nrregist IN PLS_INTEGER                       -- Numero de registros que deverao ser retornados
                              ,pr_xmllog   IN VARCHAR2                          -- XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                      -- Código da crítica
                              ,pr_dscritic OUT VARCHAR2                         -- Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType                -- Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                         -- Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2                         -- Erros do processo
                              );
  --
end tela_tab057;
/
create or replace package body cecred.tela_tab057 is

  -- Rotina para buscar a lista de cooperativas
  PROCEDURE pc_lista_cooperativas(pr_cdcooper IN     crapcop.cdcooper%TYPE -- Código da Cooperativa
                                 ,pr_flgativo IN     crapcop.flgativo%TYPE -- Flag Ativo         
                                 ,pr_xmllog   IN     VARCHAR2              -- XML com informações de LOG
                                 ,pr_cdcritic OUT    PLS_INTEGER           -- Código da crítica
                                 ,pr_dscritic OUT    VARCHAR2              -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype        -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT    VARCHAR2              -- Nome do campo com erro
                                 ,pr_des_erro OUT    VARCHAR2              -- Descricao do Erro
                                 ) IS
    -- ..........................................................................
    --
    --  Programa : pc_lista_cooperativas
    --  Sistema  : Rotinas para listar as cooperativas do sistema
    --  Sigla    : tab057
    --  Data     : Janeiro/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de cooperativas no sistema.
    --
    --  Alteracoes: 
    -- .............................................................................
  BEGIN
    --
    DECLARE
      -- Cursores
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
              ,INITCAP(cop.nmrescop) nmrescop
              ,cop.flgativo
          FROM crapcop cop
         WHERE (cop.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
           AND cop.flgativo  = pr_flgativo
         ORDER BY cop.nmrescop;
      rw_crapcop cr_crapcop%ROWTYPE;
    
      -- Variáveis locais
      vr_contador INTEGER := 0;
    
      -- Variáveis de crítica
      vr_dscritic crapcri.dscritic%TYPE;
      --
    BEGIN
      --
      FOR rw_crapcop IN cr_crapcop LOOP
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'inf'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic
                              );
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'cdcooper'
                              ,pr_tag_cont => rw_crapcop.cdcooper
                              ,pr_des_erro => vr_dscritic
                              );
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nmrescop'
                              ,pr_tag_cont => rw_crapcop.nmrescop
                              ,pr_des_erro => vr_dscritic
                              );
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'flgativo'
                              ,pr_tag_cont => rw_crapcop.flgativo
                              ,pr_des_erro => vr_dscritic
                              );
        --
        vr_contador := vr_contador + 1;
        --
      END LOOP;
      --
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em TELA_TAB057.PC_LISTA_COOPERATIVAS: ' || SQLERRM;
        pr_dscritic := 'Erro geral em TELA_TAB057.PC_LISTA_COOPERATIVAS: ' || SQLERRM;
    END;
    --
  END pc_lista_cooperativas;
  
  -- Rotina para buscar os sequenciais Sicredi
  PROCEDURE pc_busca_seq_sicredi(pr_cdcooper IN     craptab.cdcooper%TYPE -- Código da cooperativa
                                ,pr_xmllog   IN     VARCHAR2              -- XML com informações de LOG
                                ,pr_cdcritic OUT    PLS_INTEGER           -- Código da crítica
                                ,pr_dscritic OUT    VARCHAR2              -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype        -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT    VARCHAR2              -- Nome do campo com erro
                                ,pr_des_erro OUT    VARCHAR2              -- Descrição do Erro
                                ) IS
    -- ..........................................................................
    --
    --  Programa : pc_busca_seq_sicredi
    --  Sistema  : Rotina para buscar os sequenciais Sicredi
    --  Sigla    : tab057
    --  Data     : Janeiro/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar os sequenciais Sicredi
    --
    --  Alteracoes: 
    -- .............................................................................
    CURSOR cr_sequencias IS
      SELECT to_number(SUBSTR(craptab.dstextab,1,6))  seqarfat
            ,to_number(SUBSTR(craptab.dstextab,8,6))  seqtrife
            ,to_number(SUBSTR(craptab.dstextab,15,6)) seqconso
        FROM craptab
       WHERE craptab.cdcooper = pr_cdcooper
         AND craptab.nmsistem = 'CRED'
         AND craptab.tptabela = 'GENERI'
         AND craptab.cdempres = 00
         AND craptab.cdacesso = 'ARQSICREDI'
         AND craptab.tpregist = 00;
      --
      rw_sequencias cr_sequencias%ROWTYPE;
      -- Variáveis locais
      vr_contador INTEGER := 0;
    
      -- Variáveis de crítica
      vr_dscritic crapcri.dscritic%TYPE;
      --
  BEGIN
    --
    --pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><root></root>');
    --
    FOR rw_sequencias IN cr_sequencias LOOP
      --
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inf'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic
                            );
      --
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'seqarfat'
                            ,pr_tag_cont => rw_sequencias.seqarfat
                            ,pr_des_erro => vr_dscritic
                            );
      --
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'seqtrife'
                            ,pr_tag_cont => rw_sequencias.seqtrife
                            ,pr_des_erro => vr_dscritic
                            );
      --
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inf'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'seqconso'
                            ,pr_tag_cont => rw_sequencias.seqconso
                            ,pr_des_erro => vr_dscritic
                            );
      --
      vr_contador := vr_contador + 1;
      --
    END LOOP;
    --
  EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em TELA_TAB057.PC_BUSCA_SEQ_SICREDI: ' || SQLERRM;
        pr_dscritic := 'Erro geral em TELA_TAB057.PC_BUSCA_SEQ_SICREDI: ' || SQLERRM;
  END pc_busca_seq_sicredi;
  
  -- Rotina para atualizar os sequenciais Sicredi
  PROCEDURE pc_atualiza_seq_sicredi(pr_cdcooper IN     craptab.cdcooper%TYPE -- Código da cooperativa
                                   ,pr_seqarfat IN     NUMBER                -- Seq. Arq. Arrec. Faturas
                                   ,pr_seqtrife IN     NUMBER                -- Seq. Arq. Trib. Federal
                                   ,pr_seqconso IN     NUMBER                -- Seq. Arq. Atualização Consórcios
                                   ,pr_xmllog   IN     VARCHAR2              -- XML com informações de LOG
                                   ,pr_cdcritic OUT    PLS_INTEGER           -- Código da crítica
                                   ,pr_dscritic OUT    VARCHAR2              -- Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype        -- Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT    VARCHAR2              -- Nome do campo com erro
                                   ,pr_des_erro OUT    VARCHAR2              -- Descrição do Erro
                                   ) IS
    -- ..........................................................................
    --
    --  Programa : pc_atualiza_seq_sicredi
    --  Sistema  : Rotina para atualizar os sequenciais Sicredi
    --  Sigla    : tab057
    --  Data     : Janeiro/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Atualizar os sequenciais Sicredi
    --
    --  Alteracoes: 
    -- .............................................................................
  BEGIN
    --
    UPDATE craptab
       SET craptab.dstextab = LPAD(pr_seqarfat, 6, '0') || ' ' || 
                              LPAD(pr_seqtrife, 6, '0') || ' ' || 
                              LPAD(pr_seqconso, 6, '0')
     WHERE craptab.cdcooper = pr_cdcooper
       AND craptab.nmsistem = 'CRED'
       AND craptab.tptabela = 'GENERI'
       AND craptab.cdempres = 00
       AND craptab.cdacesso = 'ARQSICREDI'
       AND craptab.tpregist = 00;
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- Atribui exceção para os parametros de crítica
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na TELA_TAB057.pc_atualiza_seq_sicredi: ' || SQLERRM;
      
      pr_des_erro := 'NOK';
      
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_atualiza_seq_sicredi;
  
  -- Rotina para buscar os convênios
  PROCEDURE pc_busca_convenios(pr_cdcooper     IN  crapcon.cdcooper%TYPE DEFAULT 0  -- Código da cooperativa
                              ,pr_cdempres     IN  tbconv_arrecadacao.cdempres%TYPE -- Código do convênio
                              ,pr_nmextcon     IN  crapcon.nmextcon%TYPE            -- Descrição do convênio
                              ,pr_tab_crapcon  OUT typ_tab_crapcon                  -- PLTABLE com os dados
                              ,pr_cdcritic     OUT PLS_INTEGER                      -- Codigo da crítica
                              ,pr_dscritic     OUT VARCHAR2                         -- Descricao da crítica
                              ) IS
    /* .............................................................................

    Programa: pc_busca_convenios
    Sistema : Ayllos Web
    Data    : Janeiro/2018                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os convênios.

    Alteracoes: -----
    ..............................................................................*/
    
    -- Selecionar os convênios
    CURSOR cr_convenios(pr_cdcooper crapcon.cdcooper%TYPE            -- Código da cooperativa
                       ,pr_cdempres tbconv_arrecadacao.cdempres%TYPE -- Código do convênio
                       ,pr_nmextcon crapcon.nmextcon%TYPE            -- Descrição do convênio
                       ) IS
      SELECT tbconv_arrecadacao.cdempres
            ,crapcon.nmextcon
        FROM tbconv_arrecadacao
            ,crapcon
       WHERE tbconv_arrecadacao.cdempcon      = crapcon.cdempcon
         AND tbconv_arrecadacao.cdsegmto      = crapcon.cdsegmto
         AND tbconv_arrecadacao.tparrecadacao = 2
         AND (TRIM(pr_nmextcon)               IS NULL OR 
              UPPER(crapcon.nmextcon)         LIKE '%' || upper(pr_nmextcon) || '%')
         AND tbconv_arrecadacao.cdempres      = NVL(pr_cdempres, tbconv_arrecadacao.cdempres)
         AND crapcon.cdcooper                 = decode(pr_cdcooper, 0, crapcon.cdcooper, pr_cdcooper)
      ORDER BY crapcon.nmextcon;
    rw_convenios cr_convenios%ROWTYPE;

    -- Variaveis Gerais
    vr_indice NUMBER := 0;

  BEGIN
    -- Limpa PLTABLE
    pr_tab_crapcon.DELETE;

    -- Percorrer todas as cidades
    FOR rw_convenios IN cr_convenios(pr_cdcooper => pr_cdcooper
                                    ,pr_cdempres => pr_cdempres
                                    ,pr_nmextcon => pr_nmextcon
                                    ) LOOP
      -- Incrementa o indice
      vr_indice := vr_indice + 1;

      -- Carrega os dados na PLTRABLE
      pr_tab_crapcon(vr_indice).cdempres := rw_convenios.cdempres;
      pr_tab_crapcon(vr_indice).nmextcon := rw_convenios.nmextcon;
      --
    END LOOP;
    --
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina da tela tela_tab057.pc_busca_convenios: ' || SQLERRM;
  END pc_busca_convenios;
  
  -- Rotina para listar os convênios
  PROCEDURE pc_lista_convenios(pr_cdcooper IN  crapcon.cdcooper%TYPE            -- Código da cooperativa
                              ,pr_cdempres IN  tbconv_arrecadacao.cdempres%TYPE -- Código do convênio
                              ,pr_nmextcon IN  crapcon.nmextcon%TYPE            -- Descrição do convênio
                              ,pr_nriniseq IN PLS_INTEGER                       -- Numero inicial do registro para enviar
                              ,pr_nrregist IN PLS_INTEGER                       -- Numero de registros que deverao ser retornados
                              ,pr_xmllog   IN VARCHAR2                          -- XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                      -- Código da crítica
                              ,pr_dscritic OUT VARCHAR2                         -- Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType                -- Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                         -- Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2                         -- Erros do processo
                              ) IS
    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;

    -- Variaveis gerais
    vr_contador PLS_INTEGER := 0;
    vr_posreg   PLS_INTEGER := 0;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;

    -- Vetor para armazenar os dados da tabela
    vr_tab_crapcon typ_tab_crapcon;
    --
  BEGIN
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

    -- Busca os convênios
    pc_busca_convenios(pr_cdcooper     => pr_cdcooper    -- in
                      ,pr_cdempres     => pr_cdempres    -- in
                      ,pr_nmextcon     => pr_nmextcon    -- in
                      ,pr_tab_crapcon  => vr_tab_crapcon -- out
                      ,pr_cdcritic     => vr_cdcritic    -- out
                      ,pr_dscritic     => vr_dscritic    -- out
                      );

    -- Se retornou erro
    IF vr_dscritic IS NOT NULL THEN
      --
      RAISE vr_exc_saida;
      --
    END IF;

    -- Se nao possuir nenhum registro, envia a quantidade de registros zerada
    IF vr_tab_crapcon.COUNT = 0 THEN
      --
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Servico qtregist="0">'
                             );
      --
    ELSE
      -- Loop das cidades
      FOR vr_ind IN 1..vr_tab_crapcon.COUNT LOOP
        -- Incrementa o contador de registros
        vr_posreg := vr_posreg + 1;

        -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
        IF vr_posreg = 1 THEN
          --
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<Servico qtregist="' || vr_tab_crapcon.COUNT || '">'
                                 );
          --
        END IF;

        -- Enviar somente se a linha for superior a linha inicial
        IF nvl(pr_nriniseq,0) <= vr_posreg THEN
          -- Carrega os dados
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<inf>'||
                                                          '<cdempres>' || vr_tab_crapcon(vr_ind).cdempres ||'</cdempres>'||
                                                          '<nmextcon>' || vr_tab_crapcon(vr_ind).nmextcon ||'</nmextcon>'||
                                                       '</inf>'
                                 );

          --
          vr_contador := vr_contador + 1;
          --
        END IF;

        -- Deve-se sair se o total de registros superar o total solicitado
        EXIT WHEN vr_contador > nvl(pr_nrregist,99999);
        --
      END LOOP;
      --
    END IF;

    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Servico></Dados>'
                           ,pr_fecha_xml      => TRUE
                           );

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina pc_lista_convenios: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  END pc_lista_convenios;
  --
END tela_tab057;
/
