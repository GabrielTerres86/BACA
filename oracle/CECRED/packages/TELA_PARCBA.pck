CREATE OR REPLACE PACKAGE CECRED.TELA_PARCBA is
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_PARCBA
  --  Sistema  : Rotinas para a tela PARCBA - Historico de manutenção do cadastro de pessoa
  --  Sigla    : TELA_PARCBA
  --  Autor    : Alcemir Junior - Mout's
  --  Data     : SETEMBRO/2018.                   Ultima atualizacao: 
  --  projeto  : 421 
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para a tela PARCBA - Cadastro parametros transações Bancoob x AILOS
  --
  -- Alteracoes:   
  --  
  ---------------------------------------------------------------------------------------------------------------*/
  
   
  --------->>>> PROCUDURES/FUNCTIONS <<<<----------
    
  --> Buscar dados dos parametros cadastrados
  PROCEDURE pc_consulta_transacao_bancoob (pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE
                                          ,pr_cdhistor IN tbcontab_conc_bancoob.cdhistor%TYPE                                   
                                          ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG 
                                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);        --> Erros do processo

  --> Buscar dados dos parametros cadastr ados
 PROCEDURE pc_consulta_historico_ailos (pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE  
                                        ,pr_cdhistor IN craphis.cdhistor%TYPE  
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG 
                                        ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);        --> Erros do processo


PROCEDURE pc_insere_parametro(pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE  
                             ,pr_dstransa IN tbcontab_transa_bancoob.dstransa%TYPE  
                             ,pr_cdhistor IN tbcontab_conc_bancoob.cdhistor%TYPE
                             ,pr_indebcre_transa IN tbcontab_conc_bancoob.indebcre%TYPE
                             ,pr_indebcre_histor IN tbcontab_conc_bancoob.indebcre%TYPE
                             ,pr_lscdhistor IN VARCHAR2
                             ,pr_lsindebcre IN VARCHAR2
                             ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG 
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);                                    
                                                                           

PROCEDURE pc_deleta_transacao_bancoob(pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE  
                                       ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG 
                                       ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);

PROCEDURE pc_deleta_historico_ailos(pr_cdhistor IN tbcontab_conc_bancoob.cdhistor%TYPE 
                                   ,pr_cdtransa IN tbcontab_conc_bancoob.cdtransa%TYPE 
                                   ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG 
                                   ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);
                                                                                
                                                                                                                    
  PROCEDURE pc_insere_tarifa(pr_cdhistor    IN     tbcontab_prm_his_tarifa.cdhistor%TYPE
                            ,pr_dscontabil  IN     tbcontab_prm_his_tarifa.dscontabil%TYPE
                            ,pr_nrctadeb_pf IN     tbcontab_prm_his_tarifa.nrctadeb_pf%TYPE
                            ,pr_nrctacrd_pf IN     tbcontab_prm_his_tarifa.nrctacrd_pf%TYPE
                            ,pr_nrctadeb_pj IN     tbcontab_prm_his_tarifa.nrctadeb_pj%TYPE
                            ,pr_nrctacrd_pj IN     tbcontab_prm_his_tarifa.nrctacrd_pj%TYPE
                            ,pr_xmllog      IN     VARCHAR2           --> XML com informações de LOG
                            ,pr_cdcritic       OUT PLS_INTEGER       --> Código da crítica
                            ,pr_dscritic       OUT VARCHAR2          --> Descrição da crítica
                            ,pr_retxml      IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo       OUT VARCHAR2          --> Nome do campo com erro
                            ,pr_des_erro       OUT VARCHAR2);

  PROCEDURE pc_consulta_tarifa_bancoob(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);
                                                                                                                                                                   
  PROCEDURE pc_exclui_tarifa_bancoob(pr_cdhistor    IN     tbcontab_prm_his_tarifa.cdhistor%TYPE
                                    ,pr_xmllog      IN     VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic       OUT PLS_INTEGER       --> Código da crítica
                                    ,pr_dscritic       OUT VARCHAR2          --> Descrição da crítica
                                    ,pr_retxml      IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo       OUT VARCHAR2          --> Nome do campo com erro
                                    ,pr_des_erro       OUT VARCHAR2);

  PROCEDURE pc_executa_conciliacao(pr_dtmvtolt IN VARCHAR2           --> Campo data inserido - Melhoria RITM0011945
                                  ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);
END TELA_PARCBA;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARCBA IS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_PARCBA
  --  Sistema  : Rotinas para a tela HISPES - Historico de manutenção do cadastro de pessoa
  --  Sigla    : TELA_PARCBA
  --  Autor    : Alcemir Junior - Mout's
  --  Data     : SETEMBRO/2018.                   Ultima atualizacao: 
  --  Projeto  : 421
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para a tela PARCBA - Cadastro parametros transações Bancoob x AILOS
  --
  -- Alteracoes:   
  --    
  --  RITM0011945 - Gabriel (Mouts) 15/04/2019 - Adicionado campo dtmvtolt (executa carga)
  ---------------------------------------------------------------------------------------------------------------*/

  
  --> Buscar transacoes bancoob
  PROCEDURE pc_consulta_transacao_bancoob (pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE      
                                          ,pr_cdhistor IN tbcontab_conc_bancoob.cdhistor%TYPE                                   
                                          ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................
    
        Programa: pc_consulta_transacao_bancoob
        Sistema : CECRED
        Sigla   : TELA_PARCBA
        Autor   : Alcemir Junior - Mout's
        Data    : 21/09/2018.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Buscar transacoes bancoob
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------   
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);      
      
      
      --> variaveis auxiliares 
      vr_des_xml         CLOB;  
      vr_texto_completo  VARCHAR2(32600); 
      vr_flgexist        BOOLEAN;
      
      ---------->> CURSORES <<--------
      --> Buscar transacao bancoob
      CURSOR cr_transacao (pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE
                          ,pr_cdhistor IN tbcontab_conc_bancoob.cdhistor%TYPE) IS
        SELECT ttb.cdtransa,
               ttb.dstransa,
               ttb.indebcre
        FROM tbcontab_transa_bancoob ttb   
        FULL OUTER JOIN tbcontab_conc_bancoob tcb ON (tcb.cdtransa = ttb.cdtransa)      
        WHERE ttb.cdtransa = nvl(pr_cdtransa,ttb.cdtransa) AND tcb.cdhistor = nvl(pr_cdhistor,tcb.cdhistor)
        GROUP BY ttb.cdtransa, ttb.dstransa,ttb.indebcre
        ORDER BY ttb.cdtransa;
        
      -- cursor para buscar transações bancoob   
      CURSOR cr_transa_bancoob (pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE) IS
       SELECT ttb.cdtransa,
              ttb.dstransa,
              ttb.indebcre FROM tbcontab_transa_bancoob ttb
       WHERE ttb.cdtransa = nvl(pr_cdtransa,ttb.cdtransa)
       ORDER BY ttb.cdtransa;
      rw_transa_bancoob cr_transa_bancoob%ROWTYPE; 
      
            
       
      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    
    BEGIN
    
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;
         
      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');
      
      -- caso for informado apenas o cdtransa ou se não for informado nada
      IF (pr_cdtransa IS NOT NULL AND pr_cdhistor IS NULL) OR 
         (pr_cdtransa IS NULL AND pr_cdhistor IS NULL) THEN
        
        FOR rw_transa_bancoob  IN cr_transa_bancoob(pr_cdtransa => pr_cdtransa) LOOP

          BEGIN
            pc_escreve_xml( '<transacao>
                             <cdtransa>'|| rw_transa_bancoob.cdtransa ||'</cdtransa>'||
                            '<dstransa>'|| rw_transa_bancoob.dstransa ||'</dstransa>'||
                            '<indebcre>'|| rw_transa_bancoob.indebcre ||'</indebcre>'||
                            '</transacao>');   
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Erro ao montar tabela de transações'||
                           ': '||SQLERRM;
            RAISE vr_exc_erro;               
          END;                         
        END LOOP;
        
      ELSE  
        FOR rw_transacao  IN cr_transacao(pr_cdtransa => pr_cdtransa
                                         ,pr_cdhistor => pr_cdhistor) LOOP

          BEGIN
            pc_escreve_xml( '<transacao>
                             <cdtransa>'|| rw_transacao.cdtransa ||'</cdtransa>'||
                            '<dstransa>'|| rw_transacao.dstransa ||'</dstransa>'||
                            '<indebcre>'|| rw_transacao.indebcre ||'</indebcre>'||
                            '</transacao>');   
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Erro ao montar tabela de transações'||
                           ': '||SQLERRM;
            RAISE vr_exc_erro;               
          END;                         
        END LOOP;                     
        
      END IF;
      
      pc_escreve_xml('</Dados>',TRUE);
      pr_retxml := xmltype.createxml(vr_des_xml);        
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
                                 
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consulta_transacao_bancoob;
 
  --> Buscar dados dos parametros cadastrados
  PROCEDURE pc_consulta_historico_ailos (pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE  
                                        ,pr_cdhistor IN craphis.cdhistor%TYPE  
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG 
                                        ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS
  
      /* .............................................................................
    
        Programa: pc_consulta_transacao_bancoob
        Sistema : CECRED
        Sigla   : TELA_PARCBA
        Autor   : Alcemir Junior - Mout's
        Data    : 21/09/2018.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Buscar transacoes bancoob
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------   
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);      
      
      
      --> variaveis auxiliares 
      vr_des_xml         CLOB;  
      vr_texto_completo  VARCHAR2(32600); 
      vr_flgexist        BOOLEAN;
      
      ---------->> CURSORES <<--------
      --> Buscar transacao bancoob
      CURSOR cr_historico (pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE) IS
       SELECT tcb.cdhistor,h.dsexthst,tcb.indebcre FROM tbcontab_conc_bancoob tcb
        LEFT JOIN craphis h ON (h.cdhistor = tcb.cdhistor)
       WHERE h.cdcooper = 3
         AND  tcb.cdtransa = pr_cdtransa;

      CURSOR cr_craphis (pr_cdhistor IN craphis.cdhistor%TYPE) IS
       SELECT his.dsexthst
            , tar.dscontabil
            , tar.nrctadeb_pf
            , tar.nrctacrd_pf
            , tar.nrctadeb_pj
            , tar.nrctacrd_pj
         FROM tbcontab_prm_his_tarifa tar
            , craphis his
        WHERE tar.cdhistor (+) = his.cdhistor
          AND his.cdcooper = 3
         AND  his.cdhistor = pr_cdhistor;         
      
      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    
    BEGIN
    
      pr_des_erro := 'OK';
         
      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');
      
      
      IF pr_cdhistor IS NOT NULL THEN 
        BEGIN
          FOR rw_craphis IN cr_craphis(pr_cdhistor => pr_cdhistor) LOOP  
            pc_escreve_xml( '<historico>
                             <dshistor>'|| rw_craphis.dsexthst ||'</dshistor>'||
                            '<dscontabil>'|| rw_craphis.dscontabil ||'</dscontabil>'||
                            '<nrctadeb_pf>'|| rw_craphis.nrctadeb_pf ||'</nrctadeb_pf>'||
                            '<nrctacrd_pf>'|| rw_craphis.nrctacrd_pf ||'</nrctacrd_pf>'||
                            '<nrctadeb_pj>'|| rw_craphis.nrctadeb_pj ||'</nrctadeb_pj>'||
                            '<nrctacrd_pj>'|| rw_craphis.nrctacrd_pj ||'</nrctacrd_pj>'||
                            '</historico>');   
          END LOOP;                          
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao montar tabela de historicos Ailos'||
                         ': '||SQLERRM;
          RAISE vr_exc_erro;               
        END;      
      ELSE      
        FOR rw_historico IN cr_historico(pr_cdtransa => pr_cdtransa) LOOP

          BEGIN
            pc_escreve_xml( '<historico>
                             <cdhistor>'|| rw_historico.cdhistor ||'</cdhistor>'||
                            '<dshistor>'|| rw_historico.dsexthst ||'</dshistor>'||
                            '<indebcre>'|| rw_historico.indebcre ||'</indebcre>'||
                            '</historico>');   
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Erro ao montar tabela de historicos Ailos'||
                           ': '||SQLERRM;
            RAISE vr_exc_erro;               
          END;                         
        END LOOP;                     
        
      END IF;
      pc_escreve_xml('</Dados>',TRUE);
      pr_retxml := xmltype.createxml(vr_des_xml);        
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
                                 
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consulta_historico_ailos;
     
PROCEDURE pc_deleta_transacao (pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE,
                               pr_cdcritic OUT NUMBER,
                               pr_dscritic OUT VARCHAR2) IS 
/* .............................................................................
    
  Programa: pc_deleta_transacao
  Sistema : CECRED
  Sigla   : TELA_PARCBA
  Autor   : Alcemir Junior - Mout's
  Data    : 21/09/2018.                    Ultima atualizacao: --/--/----
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
    
  Objetivo  : deletar transacao bancoob
    
  Observacao: -----
    
  Alteracoes:
..............................................................................*/
BEGIN
   BEGIN
        
    DELETE tbcontab_conc_bancoob
    WHERE cdtransa = pr_cdtransa;
        
    DELETE tbcontab_transa_bancoob
    WHERE cdtransa = pr_cdtransa;
        
    COMMIT;                    
        
   EXCEPTION
     WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao deletar transação bancoob. Tente novamente!';        
   
   END;   
    
END pc_deleta_transacao;     

PROCEDURE pc_insere_parametro(pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE  
                             ,pr_dstransa IN tbcontab_transa_bancoob.dstransa%TYPE  
                             ,pr_cdhistor IN tbcontab_conc_bancoob.cdhistor%TYPE
                             ,pr_indebcre_transa IN tbcontab_conc_bancoob.indebcre%TYPE
                             ,pr_indebcre_histor IN tbcontab_conc_bancoob.indebcre%TYPE
                             ,pr_lscdhistor IN VARCHAR2
                             ,pr_lsindebcre IN VARCHAR2
                             ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG 
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS
      /* .............................................................................
    
        Programa: pc_consulta_transacao_bancoob
        Sistema : CECRED
        Sigla   : TELA_PARCBA
        Autor   : Alcemir Junior - Mout's
        Data    : 21/09/2018.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Buscar transacoes bancoob
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------   
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);      
      
      CURSOR cr_transacao (pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE) IS
      
      SELECT ttb.cdtransa,
               ttb.dstransa,
               ttb.indebcre
          FROM tbcontab_transa_bancoob ttb
           WHERE ttb.cdtransa = pr_cdtransa;
      rw_transacao cr_transacao%ROWTYPE;                                                    
      
      --> variaveis auxiliares 
      vr_des_xml         CLOB;  
      vr_texto_completo  VARCHAR2(32600); 
      vr_flgexist        BOOLEAN;
      vr_tab_lscdhistor gene0002.typ_split;
      vr_tab_lsindebcre gene0002.typ_split;      
      
      ---------->> CURSORES <<--------
      
      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    
    BEGIN
    
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;
     
      -- antes de inserir devemos deletar a transação
      pc_deleta_transacao(pr_cdtransa => pr_cdtransa, 
                          pr_cdcritic => vr_cdcritic,
                          pr_dscritic => vr_dscritic);
    
      IF TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
      END IF; 

     vr_tab_lscdhistor := gene0002.fn_quebra_string(pr_lscdhistor,';');
     vr_tab_lsindebcre := gene0002.fn_quebra_string(pr_lsindebcre,';');
    
     BEGIN
       
       IF pr_cdtransa IS NOT NULL THEN 
          
           UPDATE tbcontab_transa_bancoob
            SET  dstransa = pr_dstransa,
                 indebcre = pr_indebcre_transa          
            WHERE cdtransa = pr_cdtransa;
            
          
                 
        IF SQL%ROWCOUNT = 0 THEN                                             
          COMMIT;
                  
                  INSERT INTO tbcontab_transa_bancoob 
                  (cdtransa,
                   dstransa,
                   indebcre)
                   VALUES
                  (pr_cdtransa,
                   pr_dstransa,
                   pr_indebcre_transa);                           
                
            END IF;
                             
        COMMIT;
                           
        END IF;      
       
      IF vr_tab_lscdhistor.count() > 0 THEN 
                                                               
        FOR idx IN vr_tab_lscdhistor.first..vr_tab_lscdhistor.last LOOP
          
         
           UPDATE tbcontab_conc_bancoob
           SET cdhistor = vr_tab_lscdhistor(idx),
               indebcre = vr_tab_lsindebcre(idx)        
           WHERE cdhistor = vr_tab_lscdhistor(idx)
            AND  cdtransa = pr_cdtransa;   
                       
           IF SQL%ROWCOUNT = 0 THEN 
                                    
             COMMIT;                           
                 
             OPEN cr_transacao (pr_cdtransa => pr_cdtransa);
              FETCH cr_transacao INTO rw_transacao;
             
             IF cr_transacao%NOTFOUND THEN
                
                  CLOSE cr_transacao;
                  
                  INSERT INTO tbcontab_transa_bancoob 
                  (cdtransa,
                   dstransa,
                   indebcre)
                   VALUES
                  (pr_cdtransa,
                   pr_dstransa,
                   pr_indebcre_transa);
                     
                COMMIT;                                 
                        
             END IF;
             
             CLOSE cr_transacao;  
               
             INSERT INTO tbcontab_conc_bancoob 
               (cdtransa,
                cdhistor,
                indebcre)    
             VALUES
                (pr_cdtransa,
                 vr_tab_lscdhistor(idx),
                 vr_tab_lsindebcre(idx));                                                                                                                          
                
           END IF;
           
           COMMIT;
               
        END LOOP;
            
         END IF;  
         
     COMMIT;
       
     EXCEPTION
       WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao parametrizar. Tente novamente!' || SQLERRM;
          RAISE vr_exc_erro;          
     END; 
     
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;      
  
  END pc_insere_parametro;   
    
  
  PROCEDURE pc_deleta_transacao_bancoob(pr_cdtransa IN tbcontab_transa_bancoob.cdtransa%TYPE  
                                        ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG 
                                        ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS
      /* .............................................................................
    
        Programa: pc_consulta_transacao_bancoob
        Sistema : CECRED
        Sigla   : TELA_PARCBA
        Autor   : Alcemir Junior - Mout's
        Data    : 21/09/2018.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Buscar transacoes bancoob
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------   
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);      
      
      
      --> variaveis auxiliares 
      vr_des_xml         CLOB;  
      vr_texto_completo  VARCHAR2(32600); 
      vr_flgexist        BOOLEAN;
      
      ---------->> CURSORES <<--------
      
      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    
    BEGIN
    
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;
         
            
      BEGIN
        
        DELETE tbcontab_conc_bancoob
        WHERE cdtransa = pr_cdtransa;
        COMMIT;
        
        DELETE tbcontab_transa_bancoob
        WHERE cdtransa = pr_cdtransa;
        COMMIT;                    
        
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao deletar transação bancoob. Tente novamente!';
          RAISE vr_exc_erro;
      END;
    
                                
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;      
  
  END pc_deleta_transacao_bancoob;

PROCEDURE pc_deleta_historico_ailos(pr_cdhistor IN tbcontab_conc_bancoob.cdhistor%TYPE  
                                   ,pr_cdtransa IN tbcontab_conc_bancoob.cdtransa%TYPE
                                   ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG 
                                   ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS
      /* .............................................................................
    
        Programa: pc_consulta_transacao_bancoob
        Sistema : CECRED
        Sigla   : TELA_PARCBA
        Autor   : Alcemir Junior - Mout's
        Data    : 21/09/2018.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Buscar transacoes bancoob
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------   
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);      
      
      
      --> variaveis auxiliares 
      vr_des_xml         CLOB;  
      vr_texto_completo  VARCHAR2(32600); 
      vr_flgexist        BOOLEAN;
      
      ---------->> CURSORES <<--------
      
      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    
    BEGIN
    
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;
         
            
      BEGIN
        IF pr_cdhistor IS NOT NULL THEN 
          
          DELETE tbcontab_conc_bancoob
          WHERE cdhistor = pr_cdhistor;
            
        END IF;
        
        IF pr_cdtransa IS NOT NULL THEN
                                        
          DELETE tbcontab_conc_bancoob
          WHERE cdtransa = pr_cdtransa;  
                                        
        END IF;  
        
        COMMIT;
                                                     
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao deletar historico Ailos. Tente novamente!';
          RAISE vr_exc_erro;
      END;
    
                                 
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;      
  
  END pc_deleta_historico_ailos;
    
  PROCEDURE pc_insere_tarifa(pr_cdhistor    IN     tbcontab_prm_his_tarifa.cdhistor%TYPE
                            ,pr_dscontabil  IN     tbcontab_prm_his_tarifa.dscontabil%TYPE
                            ,pr_nrctadeb_pf IN     tbcontab_prm_his_tarifa.nrctadeb_pf%TYPE
                            ,pr_nrctacrd_pf IN     tbcontab_prm_his_tarifa.nrctacrd_pf%TYPE
                            ,pr_nrctadeb_pj IN     tbcontab_prm_his_tarifa.nrctadeb_pj%TYPE
                            ,pr_nrctacrd_pj IN     tbcontab_prm_his_tarifa.nrctacrd_pj%TYPE
                            ,pr_xmllog      IN     VARCHAR2           --> XML com informações de LOG
                            ,pr_cdcritic       OUT PLS_INTEGER       --> Código da crítica
                            ,pr_dscritic       OUT VARCHAR2          --> Descrição da crítica
                            ,pr_retxml      IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo       OUT VARCHAR2          --> Nome do campo com erro
                            ,pr_des_erro       OUT VARCHAR2) IS
      /* .............................................................................

        Programa: pc_insere_tarifa
        Sistema : CECRED
        Sigla   : TELA_PARCBA
        Autor   : Heitor Schmitt - Mout's
        Data    : 03/11/2018.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Inserir parametros de tarifas BANCOOB

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;

     BEGIN
       INSERT INTO tbcontab_prm_his_tarifa(cdhistor,
                                           dscontabil,
                                           nrctadeb_pf,
                                           nrctacrd_pf,
                                           nrctadeb_pj,
                                           nrctacrd_pj)
                                   VALUES (pr_cdhistor,
                                           pr_dscontabil,
                                           pr_nrctadeb_pf,
                                           pr_nrctacrd_pf,
                                           pr_nrctadeb_pj,
                                           pr_nrctacrd_pj);
     EXCEPTION
       WHEN dup_val_on_index THEN
         BEGIN
           UPDATE tbcontab_prm_his_tarifa t
              SET t.dscontabil  = pr_dscontabil
                , t.nrctadeb_pf = pr_nrctadeb_pf
                , t.nrctacrd_pf = pr_nrctacrd_pf
                , t.nrctadeb_pj = pr_nrctadeb_pj
                , t.nrctacrd_pj = pr_nrctacrd_pj
            WHERE t.cdhistor    = pr_cdhistor;
         END;
       WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao parametrizar. Tente novamente!' || SQLERRM;
          RAISE vr_exc_erro;
     END;

     COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_insere_tarifa;
  
  PROCEDURE pc_consulta_tarifa_bancoob(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_tarifa_bancoob
        Sistema : CECRED
        Sigla   : TELA_PARCBA
        Autor   : Heitor Schmitt - Mout's
        Data    : 03/11/2018.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Buscar tarifas bancoob

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
     
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);


      --> variaveis auxiliares
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600);

      ---------->> CURSORES <<--------
      --> Buscar transacao bancoob
      CURSOR cr_tarifa IS
        SELECT tar.cdhistor
             , tar.dscontabil
             , tar.nrctadeb_pf
             , tar.nrctacrd_pf
             , tar.nrctadeb_pj
             , tar.nrctacrd_pj
          FROM tbcontab_prm_his_tarifa tar
         ORDER BY tar.cdhistor;

      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    BEGIN
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;

      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;

      -- Criar cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<Dados>');

      FOR rw_tarifa IN cr_tarifa LOOP
        BEGIN
          pc_escreve_xml( '<tarifa>
                           <cdhistor>'|| rw_tarifa.cdhistor ||'</cdhistor>'||
                          '<dscontabil>'|| rw_tarifa.dscontabil ||'</dscontabil>'||
                          '<nrctadeb_pf>'|| rw_tarifa.nrctadeb_pf ||'</nrctadeb_pf>'||
                          '<nrctacrd_pf>'|| rw_tarifa.nrctacrd_pf ||'</nrctacrd_pf>'||
                          '<nrctadeb_pj>'|| rw_tarifa.nrctadeb_pj ||'</nrctadeb_pj>'||
                          '<nrctacrd_pj>'|| rw_tarifa.nrctacrd_pj ||'</nrctacrd_pj>'||
                          '</tarifa>');
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao montar tabela de tarifas'||': '||SQLERRM;
          RAISE vr_exc_erro;
        END;
      END LOOP;

      pc_escreve_xml('</Dados>',TRUE);
      pr_retxml := xmltype.createxml(vr_des_xml);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
  EXCEPTION
    WHEN vr_exc_erro THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consulta_tarifa_bancoob;
  
  PROCEDURE pc_exclui_tarifa_bancoob(pr_cdhistor    IN     tbcontab_prm_his_tarifa.cdhistor%TYPE
                                    ,pr_xmllog      IN     VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic       OUT PLS_INTEGER       --> Código da crítica
                                    ,pr_dscritic       OUT VARCHAR2          --> Descrição da crítica
                                    ,pr_retxml      IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo       OUT VARCHAR2          --> Nome do campo com erro
                                    ,pr_des_erro       OUT VARCHAR2) IS
      /* .............................................................................

        Programa: pc_exclui_tarifa_bancoob
        Sistema : CECRED
        Sigla   : TELA_PARCBA
        Autor   : Heitor Schmitt - Mout's
        Data    : 03/11/2018.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Excluir parametros de tarifas BANCOOB

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;

     BEGIN
       DELETE tbcontab_prm_his_tarifa t
        WHERE t.cdhistor = pr_cdhistor;
     EXCEPTION
       WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao excluir parametro. Tente novamente!' || SQLERRM;
          RAISE vr_exc_erro;
     END;

     COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_exclui_tarifa_bancoob;
  
  PROCEDURE pc_executa_conciliacao(pr_dtmvtolt IN VARCHAR2           --> Campo data inserido - Melhoria RITM0011945
                                  ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS
    vr_cdprogra      VARCHAR2(100) := 'JBCONTAB_PRCCTB';
    vr_jobname       VARCHAR2(100);
    vr_nmarqlog      VARCHAR2(100);
    vr_idparale      INTEGER; 
    vr_dsplsql       VARCHAR2(1000);
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(1000);
    vr_exc_erro      EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcoplog INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dtmvtolt date;    
  BEGIN
    pr_des_erro := 'OK';

    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcoplog,
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
      RAISE vr_exc_erro;
    END IF;

    vr_jobname := vr_cdprogra ||'_$';

    vr_dsplsql := 'declare 
                     vr_cdcritic integer; 
                     vr_dscritic varchar2(4000); 
                   begin 
                     cont0002.pc_processa_arquivo_bancoob (pr_cdcooper  => 3
                                                          ,pr_dtmvtolt  => '||case when     pr_dtmvtolt is null then 'null'
                                                                                   else 'to_date('''||pr_dtmvtolt||''',''dd/mm/yyyy'')' end||'      
                                                          ,pr_cdcritic  => vr_cdcritic
                                                          ,pr_dscritic  => vr_dscritic);
                  
                   end;';

    -- Faz a chamada ao programa paralelo atraves de JOB
    gene0001.pc_submit_job(pr_cdcooper => 3            --> Código da cooperativa
                          ,pr_cdprogra => vr_cdprogra  --> Código do programa
                          ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                          ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                          ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                          ,pr_jobname  => vr_jobname   --> Nome randomico criado
                          ,pr_des_erro => vr_dscritic);    

    -- Testar saida com erro
    IF vr_dscritic is not null THEN 
      -- Levantar exceçao
      raise vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END;
END TELA_PARCBA;
/
