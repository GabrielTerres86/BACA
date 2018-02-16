CREATE OR REPLACE PACKAGE CECRED.TELA_CONVEN IS

  /*--------------------------------------------------------------------------
  --
  --  Programa : TELA_CONVEN
  --  Sistema  : Rotinas utilizadas pela Tela CONVEN
  --  Sigla    : COBR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Dezembro - 2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela CONVEN
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------*/

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------
  
  
  ------------------------------------ ROTINAS ------------------------------
  --> Rotina para consultar dados para a tela CONVEN
  PROCEDURE pc_buscar_dados_conven_web
                           (pr_cddopcao IN VARCHAR2              --> Opcoes da tela 
                           ,pr_cdempcon IN crapcon.cdempcon%TYPE --> Codigo empresa do convenio
                           ,pr_cdsegmto IN crapcon.cdsegmto%TYPE --> Codigo de segmento
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Erros do processo    
                           
  --> Rotina para gravar dados para a tela CONVEN
  PROCEDURE pc_gravar_dados_conven_web
                           (pr_cddopcao IN VARCHAR2              --> Opcao da operacao
                           ,pr_cdempcon IN crapcon.cdempcon%TYPE --> Codigo empresa do convenio
                           ,pr_cdsegmto IN crapcon.cdsegmto%TYPE --> Codigo de segmento
                           ,pr_nmrescon IN crapcon.nmrescon%TYPE --> Nome resumido do convenio
                           ,pr_nmextcon IN crapcon.nmextcon%TYPE --> Nome extenso do convenio
                           ,pr_cdhistor IN crapcon.cdhistor%TYPE --> Codigo do historicp
                           ,pr_nrdolote IN crapcon.nrdolote%TYPE --> Numero do lote
                           ,pr_flginter IN crapcon.flginter%TYPE --> identificador de pagamento na internet                           
                           ,pr_tparrecd IN crapcon.tparrecd%TYPE --> Tipo de arrecadacao
                           ,pr_flgaccec IN crapcon.flgaccec%TYPE --> Identif. aceita na cecred
                           ,pr_flgacsic IN crapcon.flgacsic%TYPE --> Identif. aceita na Sicredi
                           ,pr_flgacbcb IN crapcon.flgacbcb%TYPE --> Identif. aceita na bancoob
                           
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);           --> Erros do processo                           
                                                                                              
END TELA_CONVEN;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CONVEN IS
  /*--------------------------------------------------------------------------
  --
  --  Programa : TELA_CONVEN
  --  Sistema  : Rotinas utilizadas pela Tela CONVEN
  --  Sigla    : COBR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Dezembro - 2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela CONVEN
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------*/
  
  --> Rotina para consultar dados para a tela CONVEN
  PROCEDURE pc_buscar_dados_conven_web
                           (pr_cddopcao IN VARCHAR2              --> Opcoes da tela 
                           ,pr_cdempcon IN crapcon.cdempcon%TYPE --> Codigo empresa do convenio
                           ,pr_cdsegmto IN crapcon.cdsegmto%TYPE --> Codigo de segmento
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_buscar_dados_conven_web
        Sistema : CECRED
        Sigla   : COBR
        Autor   : Odirlei Busana
        Data    : Dezembro/2017.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar dados para a tela CONVEN

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      
      ---------->> CURSORES <<--------
      --> Buscar dados do convenio
      CURSOR cr_crapcon ( pr_cdcooper IN crapope.cdcooper%TYPE,
                          pr_cdempcon IN crapcon.cdempcon%TYPE,
                          pr_cdsegmto IN crapcon.cdsegmto%TYPE) IS
        SELECT *
          FROM crapcon con 
         WHERE con.cdcooper = pr_cdcooper 
           AND con.cdempcon = pr_cdempcon 
           AND con.cdsegmto = pr_cdsegmto;
      rw_crapcon cr_crapcon%ROWTYPE;
      
      --> Buscar departamento do operado
      CURSOR cr_crapope ( pr_cdcooper IN crapope.cdcooper%TYPE,
                          pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT ope.cddepart
          FROM crapope ope
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;
      
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdcoptel crapcop.cdcooper%TYPE;
      vr_dsalerta VARCHAR2(500);
      
      vr_retxml   CLOB;
      

    BEGIN

      pr_des_erro := 'OK';
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
        RAISE vr_exc_erro;
      END IF;
      
      vr_dsalerta := NULL;
      
      IF pr_cddopcao <> 'C' THEN
        --> Buscar departamento do operado
        OPEN cr_crapope ( pr_cdcooper => vr_cdcooper,
                          pr_cdoperad => vr_cdoperad);
        FETCH cr_crapope INTO rw_crapope;
        IF cr_crapope%NOTFOUND THEN
          CLOSE cr_crapope;
          vr_cdcritic := 67; --067 - Operador nao cadastrado.
          RAISE vr_exc_erro;          
        ELSE
          CLOSE cr_crapope;
        END IF;
        
        IF rw_crapope.cddepart NOT IN (20, --> TI
                                       11, --> FINANCEIRO
                                       4)  --> COMPE
           AND 
           vr_cdoperad NOT IN ('126','979','30097') THEN
          vr_dsalerta := GENE0001.fn_busca_critica(pr_cdcritic => 36);
        END IF;

      
      END IF;
      
      -- Criar cabeçalho do XML
      vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                   '<root><Dados><inf>';
                   
      --> Buscar dados
      OPEN cr_crapcon (pr_cdcooper => vr_cdcooper,
                       pr_cdempcon => pr_cdempcon,
                       pr_cdsegmto => pr_cdsegmto);
                       
      FETCH cr_crapcon INTO rw_crapcon;
      IF cr_crapcon%NOTFOUND THEN
        CLOSE cr_crapcon;
        --> apresentar critica apenas para diferente de Insersao
        IF pr_cddopcao <> 'I' THEN          
          vr_cdcritic := 40; -- 040 - Empresa nao cadastrada.
          RAISE vr_exc_erro;        
        END IF;
        
        vr_retxml := vr_retxml ||
                    '<dsalerta>' || vr_dsalerta  || '</dsalerta>' ;
        
        
      ELSE
        CLOSE cr_crapcon;
        vr_retxml := vr_retxml ||
                    '<cdempcon>' || rw_crapcon.cdempcon  || '</cdempcon>' ||
                    '<cdsegmto>' || rw_crapcon.cdsegmto  || '</cdsegmto>' ||                    
                    '<nmrescon>' || rw_crapcon.nmrescon  || '</nmrescon>' ||
                    '<nmextcon>' || rw_crapcon.nmextcon  || '</nmextcon>' ||
                    '<cdhistor>' || rw_crapcon.cdhistor  || '</cdhistor>' ||
                    '<nrdolote>' || rw_crapcon.nrdolote  || '</nrdolote>' ||
                    '<flginter>' || rw_crapcon.flginter  || '</flginter>' ||
                    '<flgcnvsi>' || rw_crapcon.flgcnvsi  || '</flgcnvsi>' ||
                    '<cpfcgrcb>' || rw_crapcon.cpfcgrcb  || '</cpfcgrcb>' ||
                    '<cdbccrcb>' || rw_crapcon.cdbccrcb  || '</cdbccrcb>' ||
                    '<cdagercb>' || rw_crapcon.cdagercb  || '</cdagercb>' ||
                    '<nrccdrcb>' || rw_crapcon.nrccdrcb  || '</nrccdrcb>' ||
                    '<cdfinrcb>' || rw_crapcon.cdfinrcb  || '</cdfinrcb>' ||
                    '<tparrecd>' || nvl(rw_crapcon.tparrecd,0)  || '</tparrecd>' ||
                    '<flgaccec>' || nvl(rw_crapcon.flgaccec,0)  || '</flgaccec>' ||
                    '<flgacsic>' || nvl(rw_crapcon.flgacsic,0)  || '</flgacsic>' ||
                    '<flgacbcb>' || nvl(rw_crapcon.flgacbcb,0)  || '</flgacbcb>' 
                    --'<cnpescto>' || rw_crapcon.cnpescto  || '</cnpescto>' 
                    ;
                    
        IF vr_dsalerta IS NOT NULL THEN
          IF rw_crapcon.flgacsic = 1 THEN
            IF pr_cddopcao = 'A' AND vr_cdcooper <> 3 THEN
              vr_dsalerta := 'Convênios SICREDI não podem ser alterados.';  
            ELSIF pr_cddopcao = 'E' THEN
              vr_dsalerta := 'Convênios SICREDI não podem ser excluidos.';
            ELSIF pr_cddopcao = 'X' THEN
              vr_dsalerta := 'Não e possivel replicar convênios SICREDI.';  
            END IF;          
          END IF;              
        END IF;
        vr_retxml := vr_retxml ||
                    '<dsalerta>' || vr_dsalerta  || '</dsalerta>' ;
        
      END IF;

      vr_retxml := vr_retxml || '</inf></Dados></root>';
      pr_retxml := xmltype.createxml(vr_retxml);



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
  END pc_buscar_dados_conven_web;
  
  --> Rotina para gravar dados para a tela CONVEN
  PROCEDURE pc_gravar_dados_conven_web
                           (pr_cddopcao IN VARCHAR2              --> Opcao da operacao
                           ,pr_cdempcon IN crapcon.cdempcon%TYPE --> Codigo empresa do convenio
                           ,pr_cdsegmto IN crapcon.cdsegmto%TYPE --> Codigo de segmento
                           ,pr_nmrescon IN crapcon.nmrescon%TYPE --> Nome resumido do convenio
                           ,pr_nmextcon IN crapcon.nmextcon%TYPE --> Nome extenso do convenio
                           ,pr_cdhistor IN crapcon.cdhistor%TYPE --> Codigo do historicp
                           ,pr_nrdolote IN crapcon.nrdolote%TYPE --> Numero do lote
                           ,pr_flginter IN crapcon.flginter%TYPE --> identificador de pagamento na internet                           
                           ,pr_tparrecd IN crapcon.tparrecd%TYPE --> Tipo de arrecadacao
                           ,pr_flgaccec IN crapcon.flgaccec%TYPE --> Identif. aceita na cecred
                           ,pr_flgacsic IN crapcon.flgacsic%TYPE --> Identif. aceita na Sicredi
                           ,pr_flgacbcb IN crapcon.flgacbcb%TYPE --> Identif. aceita na bancoob
                           
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_gravar_dados_conven_web
        Sistema : CECRED
        Sigla   : COBR
        Autor   : Odirlei Busana
        Data    : Dezembro/2017.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para gravar dados para a tela CONVEN

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      
      ---------->> CURSORES <<--------
      --> Buscar dados do convenio
      CURSOR cr_crapcon ( pr_cdcooper IN crapope.cdcooper%TYPE,
                          pr_cdempcon IN crapcon.cdempcon%TYPE,
                          pr_cdsegmto IN crapcon.cdsegmto%TYPE) IS
        SELECT con.*,
               con.rowid   
          FROM crapcon con 
         WHERE con.cdcooper = pr_cdcooper 
           AND con.cdempcon = pr_cdempcon 
           AND con.cdsegmto = pr_cdsegmto
           FOR UPDATE NOWAIT;
      rw_crapcon cr_crapcon%ROWTYPE;
      
      --> Validar historico
      CURSOR cr_craphis (pr_cdcooper craphis.cdcooper%TYPE,
                         pr_cdhistor craphis.cdhistor%TYPE) IS
        SELECT his.dshistor
          FROM craphis his
         WHERE his.cdcooper = pr_cdcooper
           AND his.cdhistor = pr_cdhistor;
      rw_craphis cr_craphis%ROWTYPE;
      
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdcoptel crapcop.cdcooper%TYPE;
      
      vr_retxml   CLOB;
      vr_fcrapcon BOOLEAN := FALSE;
      vr_dsmensag VARCHAR2(100) := NULL;
      vr_dscdolog VARCHAR2(1000);
      
      ------------->>> SUB-ROTINAS <<<-----------
      PROCEDURE pr_gera_log_conven ( pr_cdcooper  IN NUMBER
                                    ,pr_dscdolog  IN VARCHAR2) IS
      BEGIN
        
        btch0001.pc_gera_log_batch( pr_cdcooper     => pr_cdcooper,
                                    pr_ind_tipo_log => 1,
                                    pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS') ||
                                                       ' Operador: '|| vr_cdoperad ||
                                                       ' --> '||pr_dscdolog,
                                    pr_nmarqlog     => 'conven',
                                    pr_flfinmsg     => 'N');
      
      END pr_gera_log_conven;

    BEGIN

      pr_des_erro := 'OK';
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
        RAISE vr_exc_erro;
      END IF;
      
      -- Criar cabeçalho do XML
      vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                   '<root><Dados><inf>';
                   
      
      --> Verificar registro em uso
      FOR i IN 1 .. 10 LOOP
        BEGIN
          --> Buscar dados
          OPEN cr_crapcon (pr_cdcooper => vr_cdcooper,
                           pr_cdempcon => pr_cdempcon,
                           pr_cdsegmto => pr_cdsegmto);
                           
          FETCH cr_crapcon INTO rw_crapcon;
          vr_fcrapcon := cr_crapcon%FOUND;
          CLOSE cr_crapcon;
          pr_dscritic := NULL;
          EXIT;
          
        EXCEPTION
          WHEN OTHERS THEN
          
            -- setar critica caso for o ultimo
            IF i = 10 THEN
              vr_dscritic := '077 - Tabela sendo alterada p/ outro terminal.';
            END IF;
          
            -- aguardar 0,5 seg. antes de tentar novamente
            sys.dbms_lock.sleep(1);
        END;
      
      END LOOP;
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      --> Validar historico
      OPEN cr_craphis (pr_cdcooper => vr_cdcooper,
                       pr_cdhistor => pr_cdhistor);
      FETCH cr_craphis INTO rw_craphis;
      
      IF cr_craphis%NOTFOUND THEN
        CLOSE cr_craphis;
        vr_cdcritic := 526; -- Historico nao encontrado.
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_craphis;
                       
      IF pr_cddopcao = 'A' THEN
        IF vr_fcrapcon = FALSE THEN
          vr_cdcritic := 558; -- 558 - Empresa nao e conveniada.
          RAISE vr_exc_erro;        
        ELSE
        
          --> Verificar se convenio é Sicredi
          IF rw_crapcon.flgacsic = 1 AND vr_cdcooper <> 3 THEN
            vr_dscritic := 'Convênios Sicredi nao podem ser alterados.';  
            RAISE vr_exc_erro;
          END IF;
        
          --> atualizar convenio
          BEGIN
            UPDATE crapcon con
              SET  con.nmrescon = UPPER(pr_nmrescon)
                  ,con.nmextcon = UPPER(pr_nmextcon)
                  ,con.cdhistor = nvl(pr_cdhistor,0)
                  ,con.nrdolote = nvl(pr_nrdolote,0)
                  ,con.flginter = nvl(pr_flginter,0)
                  ,con.tparrecd = nvl(pr_tparrecd,0)
                  ,con.flgaccec = nvl(pr_flgaccec,0)
                  ,con.flgacsic = nvl(pr_flgacsic,0)
                  ,con.flgacbcb = nvl(pr_flgacbcb,0)
             WHERE con.rowid = rw_crapcon.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel atualizar convenio: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          
          
          vr_dscdolog := 'alterou no Convenio ' || pr_cdempcon ||', Segmento '||pr_cdsegmto||',';
          
          --> Nome fantasia da empresa a ser conveniada.
          IF nvl(pr_nmrescon,'') <> nvl(rw_crapcon.nmrescon,'') THEN
            pr_gera_log_conven (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' o Nome fantasia ' ||rw_crapcon.nmrescon ||
                                                 ' para '|| pr_nmrescon);
          END IF;
          
          --> razao social da empresa a ser conveniada. 
          IF nvl(pr_nmextcon,'') <> nvl(rw_crapcon.nmextcon,'') THEN
            pr_gera_log_conven (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' a Razao social ' ||rw_crapcon.nmextcon ||
                                                 ' para '|| pr_nmextcon);
          END IF;
          
          --> Codigo do historico do lancamento.
          IF nvl(pr_cdhistor,'') <> nvl(rw_crapcon.cdhistor,'') THEN
            pr_gera_log_conven (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' o Historico ' ||rw_crapcon.cdhistor ||
                                                 ' para '|| pr_cdhistor);
          END IF;
          
          --> Numero do lote.
          IF nvl(pr_nrdolote,'') <> nvl(rw_crapcon.nrdolote,'') THEN
            pr_gera_log_conven (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' o Numero do lote ' ||rw_crapcon.nrdolote ||
                                                 ' para '|| pr_nrdolote);
          END IF;
          
          --> indica se o pagamento pode ser feito pela internet 
          IF nvl(pr_flginter,'') <> nvl(rw_crapcon.flginter,'') THEN
            pr_gera_log_conven (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' a Indicador de pagamento na internet ' || CASE rw_crapcon.flginter WHEN 1 THEN 'Sim' ELSE 'Não' END ||
                                                 ' para '||  CASE pr_flginter WHEN 1 THEN 'Sim' ELSE 'Não' END );
          END IF;
          
          --> tipo de arrecadacao efetuada na cooperativa (1-sicredi/ 2-bancoob/ 3-cecred) 
          IF nvl(pr_tparrecd,'') <> nvl(rw_crapcon.tparrecd,'') THEN
            pr_gera_log_conven (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' o Indicador de arrecadação ' ||
                                                  CASE rw_crapcon.tparrecd 
                                                       WHEN 1 THEN 'SICREDI' 
                                                       WHEN 2 THEN 'BANCOOB' 
                                                       WHEN 3 THEN 'CECRED' 
                                                       ELSE NULL END||
                                                 ' para '|| CASE pr_tparrecd 
                                                                 WHEN 1 THEN 'SICREDI' 
                                                                 WHEN 2 THEN 'BANCOOB' 
                                                                 WHEN 3 THEN 'CECRED' 
                                                                 ELSE NULL END);
          END IF;
          
          --> indicador de arrecadacao na cecred  (0-nao aceita/ 1-aceita) 
          IF nvl(pr_flgaccec,'') <> nvl(rw_crapcon.flgaccec,'') THEN
            pr_gera_log_conven (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' o Indicador de aceitação na CECRED ' || CASE rw_crapcon.flgaccec WHEN 1 THEN 'Sim' ELSE 'Não' END ||
                                                 ' para '|| CASE pr_flgaccec WHEN 1 THEN 'Sim' ELSE 'Não' END);
          END IF;
          
          --> indicador de arrecadacao na cecred  (0-nao aceita/ 1-aceita) 
          IF nvl(pr_flgacsic,'') <> nvl(rw_crapcon.flgacsic,'') THEN
            pr_gera_log_conven (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' o Indicador de aceitação na SICREDI ' || CASE rw_crapcon.flgacsic WHEN 1 THEN 'Sim' ELSE 'Não' END ||
                                                 ' para '||  CASE pr_flgacsic WHEN 1 THEN 'Sim' ELSE 'Não' END);
          END IF;
          
          --> indicador de arrecadacao na cecred  (0-nao aceita/ 1-aceita) 
          IF nvl(pr_flgacbcb,'') <> nvl(rw_crapcon.flgacbcb,'') THEN
            pr_gera_log_conven (pr_cdcooper => vr_cdcooper
                               ,pr_dscdolog => vr_dscdolog ||
                                                 ' o Indicador de aceitação na BANCOOB ' || CASE rw_crapcon.flgacbcb WHEN 1 THEN 'Sim' ELSE 'Não' END ||
                                                 ' para '||  CASE pr_flgacbcb WHEN 1 THEN 'Sim' ELSE 'Não' END);
          END IF;
          vr_dsmensag := 'Registros atualizados com sucesso.';
        
        END IF;
        
      --> INCLUSAO
      ELSIF pr_cddopcao = 'I' THEN
        IF vr_fcrapcon = TRUE THEN
          vr_dscritic := 'Empresa já cadastrada.';
          RAISE vr_exc_erro;        
        ELSE
          --> Inserir convenio
          BEGIN
            INSERT INTO crapcon 
                       (cdcooper,
                        cdempcon,
                        cdsegmto,
                        nmrescon,
                        nmextcon,
                        cdhistor,
                        nrdolote,
                        flginter,
                        tparrecd,
                        flgaccec,
                        flgacsic,
                        flgacbcb)
                VALUES( vr_cdcooper,
                        pr_cdempcon,
                        pr_cdsegmto,                        
                        UPPER(pr_nmrescon), 
                        UPPER(pr_nmextcon),
                        nvl(pr_cdhistor,0),
                        nvl(pr_nrdolote,0),
                        nvl(pr_flginter,0),
                        nvl(pr_tparrecd,0),
                        nvl(pr_flgaccec,0),
                        nvl(pr_flgacsic,0),
                        nvl(pr_flgacbcb,0));
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel inserir convenio: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          
          --> Gerar log  
          pr_gera_log_conven (pr_cdcooper => vr_cdcooper
                             ,pr_dscdolog => 'Incluido Convenio ' || pr_cdempcon ||', Segmento '||pr_cdsegmto);
          
          
          vr_dsmensag := 'Registros incluso com sucesso.';
        END IF;
      --> EXCLUSAO
      ELSIF pr_cddopcao = 'E' THEN
        IF vr_fcrapcon = FALSE THEN
          vr_cdcritic := 558; -- 558 - Empresa nao e conveniada.
          RAISE vr_exc_erro;        
        ELSE
          
          --> Verificar se convenio é Sicredi
          IF rw_crapcon.flgacsic = 1 THEN
            vr_dscritic := 'Convênios Sicredi nao podem ser excluidos.';  
            RAISE vr_exc_erro;
          END IF;
        
          --> Excluir convenio
          BEGIN
            DELETE crapcon con
             WHERE con.rowid = rw_crapcon.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel excluir convenio: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          
          --> Gerar log  
          pr_gera_log_conven (pr_cdcooper => vr_cdcooper
                             ,pr_dscdolog => 'Excluido Convênio ' || rw_crapcon.cdempcon ||', Segmento '||rw_crapcon.cdsegmto);
                             
          vr_dsmensag := 'Registros excluido com sucesso.';
        
        END IF;
        
      --> REPLICAÇÃO
      ELSIF pr_cddopcao = 'X' THEN
        
        IF vr_fcrapcon = FALSE THEN
          vr_cdcritic := 558; -- 558 - Empresa nao e conveniada.
          RAISE vr_exc_erro;        
        ELSE
          
          --> Verificar se convenio é Sicredi
          IF rw_crapcon.flgacsic = 1 THEN
            vr_dscritic := 'Convênios Sicredi não podem ser excluidos.';  
            RAISE vr_exc_erro;
          END IF;
          
          BEGIN
            --> Primeiro atualizar os existentes
            UPDATE crapcon con 
               SET nmextcon = rw_crapcon.nmextcon, 
                   nmrescon = rw_crapcon.nmrescon, 
                   cdhistor = rw_crapcon.cdhistor, 
                   nrdolote = rw_crapcon.nrdolote, 
                   dspescto = rw_crapcon.dspescto, 
                   cdbccrcb = rw_crapcon.cdbccrcb, 
                   cdagercb = rw_crapcon.cdagercb, 
                   cpfcgrcb = rw_crapcon.cpfcgrcb, 
                   nrccdrcb = rw_crapcon.nrccdrcb, 
                   cdfinrcb = rw_crapcon.cdfinrcb, 
                   flginter = rw_crapcon.flginter, 
                   flgcnvsi = rw_crapcon.flgcnvsi, 
                   tparrecd = rw_crapcon.tparrecd, 
                   flgaccec = rw_crapcon.flgaccec, 
                   flgacsic = rw_crapcon.flgacsic, 
                   flgacbcb = rw_crapcon.flgacbcb            
             WHERE con.cdempcon = pr_cdempcon
               AND con.cdsegmto = pr_cdsegmto;
            
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel replicar convenio(alteracao): '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          
          --> Replicar convenio
          BEGIN
            --> incluir os faltantes
            INSERT INTO crapcon
                        ( cdempcon, 
                          nmextcon, 
                          nmrescon, 
                          cdhistor, 
                          nrdolote, 
                          dspescto, 
                          cdbccrcb, 
                          cdagercb, 
                          cpfcgrcb, 
                          nrccdrcb, 
                          cdfinrcb, 
                          cdcooper, 
                          cdsegmto, 
                          flginter, 
                          flgcnvsi, 
                          tparrecd, 
                          flgaccec, 
                          flgacsic, 
                          flgacbcb)
                 SELECT  cdempcon
                        ,nmextcon
                        ,nmrescon
                        ,cdhistor
                        ,nrdolote
                        ,dspescto
                        ,cdbccrcb
                        ,cdagercb
                        ,cpfcgrcb
                        ,nrccdrcb
                        ,cdfinrcb
                        ,cop.cdcooper
                        ,cdsegmto
                        ,flginter
                        ,flgcnvsi
                        ,tparrecd
                        ,flgaccec
                        ,flgacsic
                        ,flgacbcb
                    FROM crapcon con
                        ,crapcop cop
                   WHERE con.rowid = rw_crapcon.rowid
                     AND NOT EXISTS( SELECT 1 
                                       FROM crapcon con2
                                       --> listar apenas as coops que ainda nao 
                                       --> possuem convenio
                                      WHERE con2.cdcooper = cop.cdcooper 
                                        AND con2.cdempcon = con.cdempcon
                                        AND con2.cdsegmto = con.cdsegmto );             
              
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel replicar convenio(inclusao): '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          
          
          --> Gerar log  
          pr_gera_log_conven (pr_cdcooper => vr_cdcooper
                             ,pr_dscdolog => 'Replicado dados do Convenio ' || rw_crapcon.cdempcon ||' , Segmento '||rw_crapcon.cdsegmto||' para as demais cooperativas.');
          
          vr_dsmensag := 'Registros replicados com sucesso.';
        
        END IF;  
      
      END IF;
      
      -- Cria o XML de retorno
      vr_retxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>';
      vr_retxml := vr_retxml || '<Root><Dados>';
      vr_retxml := vr_retxml || '<mensagem>'|| vr_dsmensag ||' </mensagem>';
      vr_retxml := vr_retxml || '</Dados></Root>';
    
      pr_retxml := xmltype.createxml(vr_retxml);
    
      COMMIT;
    
      pr_des_erro := 'OK';


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
  END pc_gravar_dados_conven_web;
  
  
                                   
  
END TELA_CONVEN;
/
