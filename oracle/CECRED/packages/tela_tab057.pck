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
  -- Rotina para buscar o sequencial Bancoob na craptab
  PROCEDURE pc_busca_seq_bancoob(pr_cdcooper IN     gncontr.cdcooper%TYPE -- Código da Cooperativa
                                ,pr_cdempres IN     gncontr.cdconven%TYPE -- Código da Empresa
                                ,pr_xmllog   IN     VARCHAR2              -- XML com informações de LOG
                                ,pr_cdcritic OUT    PLS_INTEGER           -- Código da crítica
                                ,pr_dscritic OUT    VARCHAR2              -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype        -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT    VARCHAR2              -- Nome do campo com erro
                                ,pr_des_erro OUT    VARCHAR2              -- Descricao do Erro
                                );
  -- Rotina para atualizar os sequenciais Bancoob
  PROCEDURE pc_atualiza_seq_bancoob(pr_cdcooper IN     craptab.cdcooper%TYPE            -- Código da cooperativa
                                   ,pr_cdempres IN     tbconv_arrecadacao.cdempres%TYPE -- Código do convênio
                                   ,pr_seqarnsa IN     NUMBER                           -- Seq. Arq. Arrec. Faturas
                                   ,pr_xmllog   IN     VARCHAR2                         -- XML com informações de LOG
                                   ,pr_cdcritic OUT    PLS_INTEGER                      -- Código da crítica
                                   ,pr_dscritic OUT    VARCHAR2                         -- Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype                   -- Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT    VARCHAR2                         -- Nome do campo com erro
                                   ,pr_des_erro OUT    VARCHAR2                         -- Descrição do Erro
                                   );
  -- Rotina paa listar as arrecadações
  PROCEDURE pc_lista_arrecadacoes(pr_cdcooper IN     gncontr.cdcooper%TYPE -- Código da Cooperativa
                                 ,pr_cdempres IN     gncontr.cdconven%TYPE -- Código da Empresa
                                 ,pr_dtiniper IN     VARCHAR2              -- Data início
                                 ,pr_dtfimper IN     VARCHAR2              -- Data fim
                                 ,pr_nriniseq IN     NUMBER                -- Registro inicial
                                 ,pr_nrregist IN     NUMBER                -- Número de registros a ser retornado
                                 ,pr_xmllog   IN     VARCHAR2              -- XML com informações de LOG
                                 ,pr_cdcritic OUT    PLS_INTEGER           -- Código da crítica
                                 ,pr_dscritic OUT    VARCHAR2              -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype        -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT    VARCHAR2              -- Nome do campo com erro
                                 ,pr_des_erro OUT    VARCHAR2              -- Descricao do Erro
                                 );
  --
  -- Gerar relatorio de criticas de arrecadacao do Bancoob
  PROCEDURE pc_relat_critica_ret( pr_cdcoptel IN     gncontr.cdcooper%TYPE -- Código da Cooperativa
                                 ,pr_cdconven IN     gncontr.cdconven%TYPE -- Código da Empresa
                                 ,pr_dtmvtolt IN     VARCHAR2              -- Data do movimento
                                 ,pr_nrsequen IN     NUMBER                -- Numero sequencial NSA
                                 ,pr_xmllog   IN     VARCHAR2              -- XML com informações de LOG
                                 ,pr_cdcritic OUT    PLS_INTEGER           -- Código da crítica
                                 ,pr_dscritic OUT    VARCHAR2              -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype        -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT    VARCHAR2              -- Nome do campo com erro
                                 ,pr_des_erro OUT    VARCHAR2);              -- Descricao do Erro

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
    --
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
      pr_des_erro := 'OK';
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
      SELECT DISTINCT 
             tbconv_arrecadacao.cdempres
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
      -- Loop das convênios
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
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina pc_lista_convenios: ' || SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  END pc_lista_convenios;
  
  -- Rotina para buscar o sequencial Bancoob na craptab
  PROCEDURE pc_busca_seq_bancoob(pr_cdcooper IN     gncontr.cdcooper%TYPE -- Código da Cooperativa
                                ,pr_cdempres IN     gncontr.cdconven%TYPE -- Código da Empresa
                                ,pr_xmllog   IN     VARCHAR2              -- XML com informações de LOG
                                ,pr_cdcritic OUT    PLS_INTEGER           -- Código da crítica
                                ,pr_dscritic OUT    VARCHAR2              -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype        -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT    VARCHAR2              -- Nome do campo com erro
                                ,pr_des_erro OUT    VARCHAR2              -- Descricao do Erro
                                ) IS
    -- ..........................................................................
    --
    --  Programa : pc_busca_seq_bancoob
    --  Sistema  : Rotina para buscar os sequenciais Bancoob
    --  Sigla    : tab057
    --  Data     : Janeiro/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar os sequenciais Bancoob
    --
    --  Alteracoes: 
    -- .............................................................................
    CURSOR cr_sequencias IS
      SELECT to_number(SUBSTR(craptab.dstextab,1,6)) seqarnsa
        FROM craptab
       WHERE UPPER(nmsistem) = 'CRED'
         AND UPPER(tptabela) = 'GENERI'
         AND UPPER(cdacesso) = 'ARQBANCOOB'
         AND tpregist = 00
         AND cdempres = pr_cdempres
         AND cdcooper = pr_cdcooper;
      --
      rw_sequencias cr_sequencias%ROWTYPE;
      -- Variáveis locais
      vr_contador INTEGER := 0;
    
      -- Variáveis de crítica
      vr_dscritic crapcri.dscritic%TYPE;
      --
  BEGIN
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
                            ,pr_tag_nova => 'seqarnsa'
                            ,pr_tag_cont => rw_sequencias.seqarnsa
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
        pr_des_erro := 'Erro geral em TELA_TAB057.PC_BUSCA_SEQ_BANCOOB: ' || SQLERRM;
        pr_dscritic := 'Erro geral em TELA_TAB057.PC_BUSCA_SEQ_BANCOOB: ' || SQLERRM;
  END pc_busca_seq_bancoob;
  
  -- Rotina para atualizar os sequenciais Bancoob
  PROCEDURE pc_atualiza_seq_bancoob(pr_cdcooper IN     craptab.cdcooper%TYPE            -- Código da cooperativa
                                   ,pr_cdempres IN     tbconv_arrecadacao.cdempres%TYPE -- Código do convênio
                                   ,pr_seqarnsa IN     NUMBER                           -- Seq. Arq. Arrec. Faturas
                                   ,pr_xmllog   IN     VARCHAR2                         -- XML com informações de LOG
                                   ,pr_cdcritic OUT    PLS_INTEGER                      -- Código da crítica
                                   ,pr_dscritic OUT    VARCHAR2                         -- Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype                   -- Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT    VARCHAR2                         -- Nome do campo com erro
                                   ,pr_des_erro OUT    VARCHAR2                         -- Descrição do Erro
                                   ) IS
    -- ..........................................................................
    --
    --  Programa : pc_atualiza_seq_bancoob
    --  Sistema  : Rotina para atualizar os sequenciais Bancoob
    --  Sigla    : tab057
    --  Data     : Janeiro/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Atualizar os sequenciais Bancoob
    --
    --  Alteracoes: 
    -- .............................................................................
    -- VARIÁVEIS
    vr_cdcooper    NUMBER;
    vr_nmdatela    varchar2(25);
    vr_nmeacao     varchar2(25);
    vr_cdagenci    varchar2(25);
    vr_nrdcaixa    varchar2(25);
    vr_idorigem    varchar2(25);
    vr_cdoperad    varchar2(25);
    vr_dscritic    varchar2(2000);
    vr_cdcritic    NUMBER;
    vr_exc_erro    EXCEPTION;
    --
    vr_dstextab    craptab.dstextab%TYPE;
    vr_dsdircop    crapcop.dsdircop%TYPE;
    vr_nmoperad    crapope.nmoperad%TYPE;
    vr_tab_crapcon typ_tab_crapcon;
    -- Variável do arquivo log
    vr_input_log   utl_file.file_type;
    --
  BEGIN
    -- extrair informações padrão do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml 
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao 
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);
    
    -- Rotina para buscar os convênios
    pc_busca_convenios( pr_cdcooper     => pr_cdcooper    -- Código da cooperativa
                       ,pr_cdempres     => pr_cdempres    -- Código do convênio
                       ,pr_nmextcon     => NULL           -- Descrição do convênio
                       ,pr_tab_crapcon  => vr_tab_crapcon -- PLTABLE com os dados
                       ,pr_cdcritic     => vr_cdcritic    -- Codigo da crítica
                       ,pr_dscritic     => vr_dscritic);  -- Descricao da crítica

    IF nvl(vr_cdcritic,0) > 0 OR   
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;      
    END IF;   
    
    IF vr_tab_crapcon.count = 0 THEN
      vr_dscritic := 'Não há convênio de Arrecadação com o código informado.';
      RAISE vr_exc_erro;      
    END IF;
   
   
    --
    BEGIN
      SELECT substr(craptab.dstextab, 0, 6)
        INTO vr_dstextab
        FROM craptab
       WHERE nmsistem = 'CRED'
         AND tptabela = 'GENERI'
         AND cdacesso = 'ARQBANCOOB'
         AND tpregist = 00
         AND cdempres = pr_cdempres
         AND cdcooper = pr_cdcooper; 
    EXCEPTION
      WHEN no_data_found THEN
        BEGIN
          INSERT INTO craptab
                      ( nmsistem, 
                        tptabela, 
                        cdempres, 
                        cdacesso, 
                        tpregist, 
                        dstextab, 
                        cdcooper)
               VALUES ( 'CRED',                    -- nmsistem
                        'GENERI',                  -- tptabela
                        pr_cdempres,               -- cdempres
                        'ARQBANCOOB',              -- cdacesso
                        00,                        -- tpregist
                        lpad(pr_seqarnsa, 6, '0'), -- dstextab
                        pr_cdcooper);              -- cdcooper
                
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir sequencial: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
    
    END;
    --
    UPDATE craptab
       SET craptab.dstextab = lpad(pr_seqarnsa, 6, '0') || ' ' || substr(craptab.dstextab, 8, 8)
     WHERE nmsistem = 'CRED'
       AND tptabela = 'GENERI'
       AND cdacesso = 'ARQBANCOOB'
       AND tpregist = 00
       AND cdempres = pr_cdempres
       AND cdcooper = pr_cdcooper;
    --
    SELECT crapope.nmoperad
      INTO vr_nmoperad
      FROM crapope
     WHERE crapope.cdoperad = vr_cdoperad
       AND crapope.cdcooper = pr_cdcooper;
    -- Abre o arquivo de log em modo de gravação
    gene0001.pc_abre_arquivo(pr_nmdireto => gene0001.fn_diretorio(pr_tpdireto => 'C'         -- IN
                                                                 ,pr_cdcooper => pr_cdcooper -- IN
                                                                 ,pr_nmsubdir => '/log'      -- IN
                                                                 ) -- IN -- Diretório do arquivo
                            ,pr_nmarquiv => 'tab057.log'           -- IN -- Nome do arquivo
                            ,pr_tipabert => 'A'                    -- IN -- Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_input_log           -- IN -- Handle do arquivo aberto
                            ,pr_des_erro => pr_dscritic            -- IN -- Erro
                            );
    -- Escrever o log no arquivo
    gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_log -- Handle do arquivo aberto
                                  ,pr_des_text  => to_char(SYSDATE, 'DD/MM/YYYY - HH24:MI:SS') || ' - TAB057 - Operador ' || vr_cdoperad || ' - ' || vr_nmoperad || ' alterou a sequência do convênio ' || pr_cdempres || ' de ' || vr_dstextab || ' para ' || lpad(pr_seqarnsa, 6, '0') || '.'   -- Texto para escrita
                                  );
    -- Fechar Arquivo log
    BEGIN
      --
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_log); --> Handle do arquivo aberto;
      --
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Problema ao fechar o log </usr/coop/<nmcoop>/log/tab057.log>: ' || SQLERRM;
    END;
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
    
      -- Atribui exceção para os parametros de crítica
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
      
      pr_des_erro := 'NOK';
      
    
    WHEN OTHERS THEN
      -- Atribui exceção para os parametros de crítica
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na TELA_TAB057.pc_atualiza_seq_bancoob: ' || SQLERRM;
      
      pr_des_erro := 'NOK';
      
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_atualiza_seq_bancoob;
  
  -- Rotina para listar as arrecadações
  PROCEDURE pc_lista_arrecadacoes(pr_cdcooper IN     gncontr.cdcooper%TYPE -- Código da Cooperativa
                                 ,pr_cdempres IN     gncontr.cdconven%TYPE -- Código da Empresa
                                 ,pr_dtiniper IN     VARCHAR2              -- Data início
                                 ,pr_dtfimper IN     VARCHAR2              -- Data fim
                                 ,pr_nriniseq IN     NUMBER                -- Registro inicial
                                 ,pr_nrregist IN     NUMBER                -- Número de registros a ser retornado
                                 ,pr_xmllog   IN     VARCHAR2              -- XML com informações de LOG
                                 ,pr_cdcritic OUT    PLS_INTEGER           -- Código da crítica
                                 ,pr_dscritic OUT    VARCHAR2              -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype        -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT    VARCHAR2              -- Nome do campo com erro
                                 ,pr_des_erro OUT    VARCHAR2              -- Descricao do Erro
                                 ) IS
    -- ..........................................................................
    --
    --  Programa : pc_lista_arrecadacoes
    --  Sistema  : Rotinas para listar as arrecadações
    --  Sigla    : tab057
    --  Data     : Janeiro/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de arrecadações.
    --
    --  Alteracoes: 
    -- .............................................................................
    --
    -- Lista as arrecadações
    CURSOR cr_arrecad(pr_cdcooper gncontr.cdcooper%TYPE -- Código da Cooperativa
                     ,pr_cdempres gncontr.cdconven%TYPE -- Código da Empresa
                     ,pr_dtiniper DATE                  -- Data início
                     ,pr_dtfimper DATE                  -- Data fim
                     ) IS
      SELECT crapcop.cdcooper
            ,crapcop.nmrescop
            ,gncontr.cdconven
            ,gncontr.dtmvtolt
            ,gncontr.qtdoctos
            ,gncontr.vldoctos
            ,gncontr.vltarifa
            ,gncontr.vlapagar
            ,gncontr.nrsequen
            ,gncontr.nmarquiv
            ,gncontr.cdsitret
        FROM gncontr
            ,crapcop
       WHERE gncontr.cdcooper = crapcop.cdcooper
         AND gncontr.tpdcontr = 6 -- Bancoob
         AND gncontr.cdcooper = (CASE WHEN pr_cdcooper = 0 THEN gncontr.cdcooper ELSE pr_cdcooper END)
         AND gncontr.cdconven = (CASE WHEN pr_cdempres = 0 THEN gncontr.cdconven ELSE pr_cdempres END)
         AND gncontr.dtmvtolt BETWEEN pr_dtiniper AND pr_dtfimper;
    --
    rw_arrecad cr_arrecad%ROWTYPE;
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    --
    vr_qt_reg   NUMBER;
    vr_nr_ctrl  NUMBER;
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_dssitret VARCHAR2(100);
    -- Totais
    vr_qttotdoc NUMBER;
    vr_qttotarr NUMBER;
    vr_qttottar NUMBER;
    vr_qttotpag NUMBER;
    --
    vr_exc_saida EXCEPTION;
    --
  BEGIN
    --
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    /*gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            );
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    --*/
    OPEN cr_arrecad(pr_cdcooper => pr_cdcooper
                   ,pr_cdempres => pr_cdempres
                   ,pr_dtiniper => to_date(pr_dtiniper, 'DD/MM/RRRR')
                   ,pr_dtfimper => to_date(pr_dtfimper, 'DD/MM/RRRR')
                   );
    --
    vr_qt_reg  := 0;
    vr_nr_ctrl := 0;
    -- Inicializa totalizadores
    vr_qttotdoc := 0;
    vr_qttotarr := 0;
    vr_qttottar := 0;
    vr_qttotpag := 0;
    --
    LOOP
      --
      FETCH cr_arrecad INTO rw_arrecad;
      EXIT WHEN cr_arrecad%NOTFOUND;
      --
      IF vr_qt_reg = 0 THEN
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic
                              );
        --
      END IF;
      IF (vr_qt_reg + 1) >= pr_nriniseq AND (vr_qt_reg + 1) <= ((pr_nriniseq + pr_nrregist) - 1) THEN
        -- Insere as tags
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
                              ,pr_posicao  => vr_nr_ctrl
                              ,pr_tag_nova => 'nmrescop'
                              ,pr_tag_cont => rw_arrecad.nmrescop
                              ,pr_des_erro => vr_dscritic
                              );
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_nr_ctrl
                              ,pr_tag_nova => 'cdcooper'
                              ,pr_tag_cont => rw_arrecad.cdcooper
                              ,pr_des_erro => vr_dscritic
                              );
        
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_nr_ctrl
                              ,pr_tag_nova => 'cdconven'
                              ,pr_tag_cont => rw_arrecad.cdconven
                              ,pr_des_erro => vr_dscritic
                              );
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_nr_ctrl
                              ,pr_tag_nova => 'dtmvtolt'
                              ,pr_tag_cont => to_char(rw_arrecad.dtmvtolt, 'DD/MM/YYYY')
                              ,pr_des_erro => vr_dscritic
                              );
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_nr_ctrl
                              ,pr_tag_nova => 'qtdoctos'
                              ,pr_tag_cont => rw_arrecad.qtdoctos
                              ,pr_des_erro => vr_dscritic
                              );
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_nr_ctrl
                              ,pr_tag_nova => 'vldoctos'
                              ,pr_tag_cont => rw_arrecad.vldoctos
                              ,pr_des_erro => vr_dscritic
                              );
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_nr_ctrl
                              ,pr_tag_nova => 'vltarifa'
                              ,pr_tag_cont => rw_arrecad.vltarifa
                              ,pr_des_erro => vr_dscritic
                              );
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_nr_ctrl
                              ,pr_tag_nova => 'vlapagar'
                              ,pr_tag_cont => rw_arrecad.vlapagar
                              ,pr_des_erro => vr_dscritic
                              );
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_nr_ctrl
                              ,pr_tag_nova => 'nrsequen'
                              ,pr_tag_cont => rw_arrecad.nrsequen
                              ,pr_des_erro => vr_dscritic
                              );
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_nr_ctrl
                              ,pr_tag_nova => 'nmarquiv'
                              ,pr_tag_cont => rw_arrecad.nmarquiv
                              ,pr_des_erro => vr_dscritic
                              );
                              
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_nr_ctrl
                              ,pr_tag_nova => 'cdsitret'
                              ,pr_tag_cont => rw_arrecad.cdsitret
                              ,pr_des_erro => vr_dscritic
                              );
        --
                            
        CASE rw_arrecad.cdsitret
          WHEN 0 THEN vr_dssitret := 'Nao trata retorno';
          WHEN 1 THEN vr_dssitret := 'Pendente de retorno';
          WHEN 2 THEN vr_dssitret := 'Arquivo processado com sucesso';
          WHEN 3 THEN vr_dssitret := 'Arquivo processado com inconsistencia';
          WHEN 4 THEN vr_dssitret := 'Arquivo rejeitado';
          WHEN 5 THEN vr_dssitret := 'Arquivo de retorno inválido';
          ELSE vr_dssitret := 'Sesc. nao encontrada.';
        END CASE;  
        
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'inf'
                              ,pr_posicao  => vr_nr_ctrl
                              ,pr_tag_nova => 'dssitret'
                              ,pr_tag_cont => vr_dssitret
                              ,pr_des_erro => vr_dscritic
                              );  
        
        
        --
        vr_nr_ctrl := vr_nr_ctrl + 1;
        --
      END IF;
      --
      vr_qttotdoc := vr_qttotdoc + rw_arrecad.qtdoctos;
      vr_qttotarr := vr_qttotarr + rw_arrecad.vldoctos;
      vr_qttottar := vr_qttottar + rw_arrecad.vltarifa;
      vr_qttotpag := vr_qttotpag + rw_arrecad.vlapagar;
      --
      vr_qt_reg := vr_qt_reg + 1;
      --
    END LOOP;
    -- Quantidade total de registros
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Qtdregis'
                          ,pr_tag_cont => vr_qt_reg
                          ,pr_des_erro => vr_dscritic
                          );
    -- Quantidade total de documentos
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'qttotdoc'
                          ,pr_tag_cont => vr_qttotdoc
                          ,pr_des_erro => vr_dscritic
                          );
    -- Quantidade total arrecadado
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'qttotarr'
                          ,pr_tag_cont => vr_qttotarr
                          ,pr_des_erro => vr_dscritic
                          );
    -- Quantidade total de tarifas
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'qttottar'
                          ,pr_tag_cont => vr_qttottar
                          ,pr_des_erro => vr_dscritic
                          );
    -- Quantidade total de pagamentos
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'qttotpag'
                          ,pr_tag_cont => vr_qttotpag
                          ,pr_des_erro => vr_dscritic
                          );
    --
    CLOSE cr_arrecad;
    --
    /*IF vr_qt_reg = 0 THEN
      -- Atribui crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Dados nao encontrados!';
      RAISE vr_exc_saida;
      --
    END IF;*/
    --
  EXCEPTION
    /*WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        --
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --
      ELSE
        --
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        --
      END IF;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');*/
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_lista_arrecadacoes;
  
  --
  -- Gerar relatorio de criticas de arrecadacao do Bancoob
  PROCEDURE pc_relat_critica_ret( pr_cdcoptel IN     gncontr.cdcooper%TYPE -- Código da Cooperativa
                                 ,pr_cdconven IN     gncontr.cdconven%TYPE -- Código da Empresa
                                 ,pr_dtmvtolt IN     VARCHAR2              -- Data do movimento
                                 ,pr_nrsequen IN     NUMBER                -- Numero sequencial NSA
                                 ,pr_xmllog   IN     VARCHAR2              -- XML com informações de LOG
                                 ,pr_cdcritic OUT    PLS_INTEGER           -- Código da crítica
                                 ,pr_dscritic OUT    VARCHAR2              -- Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype        -- Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT    VARCHAR2              -- Nome do campo com erro
                                 ,pr_des_erro OUT    VARCHAR2              -- Descricao do Erro
                                 ) IS
    -- ..........................................................................
    --
    --  Programa : pc_relat_critica_ret
    --  Sistema  : Rotinas para listar as arrecadações
    --  Autor    : Odirlei Busana - AMcom
    --  Sigla    : tab057
    --  Data     : Janeiro/2018.                   Ultima atualizacao: 18/10/2018
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Gerar relatorio de criticas de arrecadacao do Bancoob
    --
    --  Alteracoes: 25/07/2018 - Alterado busca do nome de arquivos de retorno para CECRED
    --							             devido a mudança de marca ainda não tratada no parceiro Bancoob.
		--							 						 (Reinert)
    --
		--              18/10/2018 - Alterado busca do nome de arquivos de retorno para AILOS
		--                           novamente. (Reinert)
    -- .............................................................................
    --
    
    -- Busca dos dados da cooperativa central
    CURSOR cr_crapcop_central (pr_cdcooper INTEGER) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.cdagebcb 
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;     
    rw_crapcop_central cr_crapcop_central%ROWTYPE;   


    -- Lista as arrecadações
    CURSOR cr_gncontr(pr_cdcooper gncontr.cdcooper%TYPE -- Código da Cooperativa
                     ,pr_cdempres gncontr.cdconven%TYPE -- Código da Empresa
                     ,pr_dtmvtolt gncontr.dtmvtolt%TYPE -- Data início
                     ,pr_nrsequen gncontr.nrsequen%TYPE -- Data fim
                     ) IS
      SELECT cop.nmrescop
            ,cop.cdagectl
            ,cop.cdagebcb
            ,ctr.cdconven
            ,ctr.dtmvtolt
            ,ctr.qtdoctos
            ,ctr.vldoctos
            ,ctr.vltarifa
            ,ctr.vlapagar
            ,ctr.nrsequen
            ,ctr.nmarquiv
            ,ctr.cdsitret
        FROM gncontr ctr
            ,crapcop cop
       WHERE ctr.cdcooper = cop.cdcooper
         AND ctr.cdcooper = pr_cdcooper
         AND ctr.cdconven = pr_cdempres
         AND ctr.dtmvtolt = pr_dtmvtolt
         AND ctr.tpdcontr = 6
         AND ctr.nrsequen = pr_nrsequen;
    
    rw_gncontr cr_gncontr%ROWTYPE;
    
    --> Buscar registro de inconsistencia
    CURSOR cr_tbincons (pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_dtmvtolt DATE,
                        pr_nmarqret VARCHAR2) IS
      SELECT inc.dsinconsist,
             inc.dsregistro_referencia 
        FROM tbgen_inconsist inc
       WHERE inc.cdcooper        = pr_cdcooper 
         AND inc.idinconsist_grp = 5
         AND inc.dtmvtolt        = pr_dtmvtolt
         AND (inc.dsregistro_referencia like '%'||pr_nmarqret||'%');
    
    -- Cursor da data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;


    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    --
    vr_qt_reg   NUMBER;
    vr_nr_ctrl  NUMBER;
    
    vr_cdprogra VARCHAR2(40) := 'TAB057';
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dtmvtolt DATE;
    vr_nmarqret VARCHAR2(100);
    
    vr_dssitret    VARCHAR2(100);
    vr_tab_reg    gene0002.typ_split;
    vr_tab_campos gene0002.typ_split;
    vr_nrseqret   VARCHAR2(100);
    vr_flgexist   BOOLEAN;
    vr_des_reto   VARCHAR2(100);
    vr_tab_erro   gene0001.typ_tab_erro;
    
    --
    vr_exc_saida EXCEPTION;
    --
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_dsdireto  VARCHAR2(100);
    vr_nmdrelat  VARCHAR2(100);
    vr_dscomand  VARCHAR2(200);
    vr_typ_saida VARCHAR2(200);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
    
    
  BEGIN
    --
    pr_des_erro := 'OK';
    
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            );
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    -- Busca dos dados da cooperativa central
    OPEN cr_crapcop_central (pr_cdcooper => 3);
    FETCH cr_crapcop_central INTO rw_crapcop_central;
    IF cr_crapcop_central%NOTFOUND THEN
      CLOSE cr_crapcop_central;
      vr_dscritic := 'Cooperativa central nao encontrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapcop_central;
    END IF;
    
    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
    
    
    vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');
    
    OPEN cr_gncontr(pr_cdcooper => pr_cdcoptel
                   ,pr_cdempres => pr_cdconven
                   ,pr_dtmvtolt => vr_dtmvtolt
                   ,pr_nrsequen => pr_nrsequen);
    FETCH cr_gncontr INTO rw_gncontr;
    IF cr_gncontr%NOTFOUND THEN
      CLOSE cr_gncontr;
      vr_dscritic := 'Registro de controle nao encontrado';
      RAISE vr_exc_saida;
      
    ELSE
      CLOSE cr_gncontr;
    END IF;
    
    --> Montar nome do arquivo de retorno
    /*
    9999 – código da agência  cdagebcb + “-” - Fixo + “RT” – Fixo 
        +  9999999999 – código do convênio 
        + AAAAMMDD – Data da geração do arquivo + NSA – número sequencial único do arquivo com 3 dígitos  + “.RET” 
    
    */
    
    vr_nmarqret := to_char(rw_gncontr.cdagebcb,'fm0000')       ||
                   '-RT'                                       ||
                   to_char(rw_gncontr.cdconven,'fm0000000000') ||  
                   to_char(rw_gncontr.dtmvtolt,'RRRRMMDD')     ||
                   substr(LPAD(rw_gncontr.nrsequen,10,0),-3)   ||
                   '.'||rw_crapcop_central.nmrescop            ||
                   '.RET';
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
    vr_flgexist := FALSE;
    --> Buscar registro de inconsistencia
    FOR rw_tbincons IN cr_tbincons ( pr_cdcooper => pr_cdcoptel,
                                     pr_dtmvtolt => rw_gncontr.dtmvtolt,
                                     pr_nmarqret => vr_nmarqret) LOOP
      vr_flgexist := TRUE;                              
      vr_nrseqret := NULL;
      vr_tab_reg := gene0002.fn_quebra_string(rw_tbincons.dsregistro_referencia,'<br>');
      
      IF vr_tab_reg.count > 1 THEN
        FOR id_reg IN vr_tab_reg.first..vr_tab_reg.last LOOP 
          vr_tab_campos := gene0002.fn_quebra_string(vr_tab_reg(id_reg),':');
          
          IF vr_tab_campos(1) = 'NSR' THEN
            vr_nrseqret := vr_tab_campos(2);          
          END IF;
          
        END LOOP;
      
      END IF;
      
      pc_escreve_xml('<arquivos>
                          <retorno>
                             <nmarquiv>'|| vr_nmarqret                               ||'</nmarquiv>
                             <dtmvtolt>'|| to_char(rw_gncontr.dtmvtolt,'DD/MM/RRRR') ||'</dtmvtolt>
                             <dsincons>'|| rw_tbincons.dsinconsist                   ||'</dsincons>
                             <nrseqret>'|| lpad(vr_nrseqret,8,'0')                   ||'</nrseqret>
                          </retorno>
                      </arquivos>');                                 
                                     
    END LOOP;
    
    IF vr_flgexist = FALSE THEN
      vr_dscritic := 'Ocorrências para o arquivo '||vr_nmarqret|| ' não econtrada, Verifique critica na tela CONINC.';
      RAISE vr_exc_saida;    
    END IF;
    
    -- Finalizar o agrupador do relatório
    pc_escreve_xml('</raiz>',TRUE);      

    -- Busca do diretório base da cooperativa para PDF
    vr_dsdireto := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                         ,pr_cdcooper => vr_cdcooper
                                         ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    vr_nmdrelat := 'crrl737_'||vr_cdoperad||'_'||to_char(SYSDATE,'SSSSS')||'.pdf';
    
    -- Efetuar solicitação de geração de relatório --
    gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper         --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                               ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/raiz/arquivos/retorno'    --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl737.jasper'    --> Arquivo de layout do iReport
                               ,pr_cdrelato  => 737 
                               ,pr_dsparams  => NULL                --> Sem parametros
                               ,pr_dsarqsaid => vr_dsdireto||'/'||vr_nmdrelat --> Arquivo final com código da agência
                               ,pr_qtcoluna  => 132                 --> 132 colunas
                               ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                               ,pr_flg_impri => 'N'                 --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                   --> Número de cópias
                               ,pr_flg_gerar => 'S'                 --> gerar relat na hora
                               ,pr_nrvergrl  => 1                   --> versao do gerador de relatorio 
                               ,pr_des_erro  => vr_dscritic);       --> Saída com erro
    -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;
    
    --O ireport já irá gerar o relatório em formato pdf e por isso, iremos apenas
    --envia-lo ao servidor web.           
    gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_nmarqpdf => vr_dsdireto||'/'||vr_nmdrelat
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);

    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
              
      --Se tem erro na tabela 
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_dscritic:= 'Erro ao enviar arquivo para web.';  
      END IF; 
              
      --Sair 
      RAISE vr_exc_saida;
              
    END IF;                 
         
    --Eliminar arquivo impressao
    IF gene0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||vr_nmdrelat) THEN 
                                                      
      --Excluir arquivo de impressao
       vr_dscomand := 'rm '||vr_dsdireto||'/'||vr_nmdrelat||' 2>/dev/null';

      --Executar o comando no unix
      gene0001.pc_OScommand (pr_typ_comando => 'S'
                            ,pr_des_comando => vr_dscomand
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_dscritic);
                                  
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel excluir arq.: '|| vr_dscritic;
                            
        -- retornando ao programa chamador
        RAISE vr_exc_saida;
      END IF;
           
    END IF;
          
    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'nmarqpdf'
                          ,pr_tag_cont => vr_nmdrelat
                          ,pr_des_erro => vr_dscritic);
                                   
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;  
            
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    
    COMMIT;
                                     
  EXCEPTION
    WHEN vr_exc_saida THEN
    
      IF vr_cdcritic <> 0 AND
         vr_dscritic IS NULL THEN
        --
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --
      ELSE
        --
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        --
      END IF;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                     
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_relat_critica_ret;
  
  
END tela_tab057;
/
