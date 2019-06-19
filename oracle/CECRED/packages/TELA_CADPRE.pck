CREATE OR REPLACE PACKAGE CECRED.TELA_CADPRE AS
  
  /* Gravar os dados da CADPRE */
  PROCEDURE pc_grava_cadpre(pr_inpessoa   IN crappre.inpessoa%TYPE  --> Codigo do tipo de pessoa
                           ,pr_cdfinemp   IN crappre.cdfinemp%TYPE  --> Codigo da Finalidade
                           ,pr_vllimmin   IN crappre.vllimmin%TYPE  --> Limite minimo
                           ,pr_vllimctr   IN crappre.vllimctr%TYPE  --> Limite minimo para contratacao
                           ,pr_vlmulpli   IN crappre.vlmulpli%TYPE  --> Valor multiplo
                           ,pr_qtdiavig   IN crappre.qtdiavig%TYPE  --> Quantidade de dias maximo de vigencia
                           ,pr_vllimman   IN crappre.vllimman%TYPE  --> Valor limite máximo para cargas manuais
                           ,pr_vllimaut   IN crappre.vllimaut%TYPE  --> Valor limite máximo para cargas automaticas
                           ,pr_dslstali   IN crappre.dslstali%TYPE  --> Lista com codigos de alineas de devolucao de cheque
                           ,pr_qtdevolu   IN crappre.qtdevolu%TYPE  --> Quantidade de devolucoes de cheque
                           ,pr_qtdiadev   IN crappre.qtdiadev%TYPE  --> Quantidade de dias para calc. devolucao de cheque
                           ,pr_vldiadev   IN crappre.vldiadev%TYPE  --> Valor de devoluções de cheque
                           ,pr_qtctaatr   IN crappre.qtctaatr%TYPE  --> Quantidade de dias de conta corrente em atraso
                           ,pr_vlctaatr   IN crappre.vlctaatr%TYPE  --> Valor de atraso em conta corrente
                           ,pr_qtepratr   IN crappre.qtepratr%TYPE  --> Quantidade de dias de emprestimo em atraso
                           ,pr_vlepratr   IN crappre.vlepratr%TYPE  --> Valor de emprestimo em atraso
                           ,pr_qtestour   IN crappre.qtestour%TYPE  --> Quantidade de estouros de conta
                           ,pr_qtdiaest   IN crappre.qtdiaest%TYPE  --> Quantidade de dias para calc. estouro de conta
                           ,pr_vldiaest   IN crappre.vldiaest%TYPE  --> Valor de estouro em conta
                           ,pr_qtavlatr   IN crappre.qtavlatr%TYPE  --> Operações como avalista Quantidade de dias em atraso
                           ,pr_vlavlatr   IN crappre.vlavlatr%TYPE  --> Operações como avalista Valor em atraso
                           ,pr_qtavlope   IN crappre.qtavlope%TYPE  --> Operações como avalista Quantidade de operações em atraso
                           ,pr_qtcjgatr   IN crappre.qtcjgatr%TYPE  --> Conjuge Quantidade de dias em atraso
                           ,pr_vlcjgatr   IN crappre.vlcjgatr%TYPE  --> Conjuge Valor em atraso
                           ,pr_qtcjgope   IN crappre.qtcjgope%TYPE  --> Conjuge Quantidade de operações em atraso 
                           ,pr_qtcarcre   IN crappre.qtcarcre%TYPE  --> Quantidade de dias em atraso de cartão de credito
                           ,pr_vlcarcre   IN crappre.vlcarcre%TYPE  --> Valor de atraso de cartão de credito
                           ,pr_qtdtitul   IN crappre.qtdtitul%TYPE  --> Quantidade de dias de atraso de titulos
                           ,pr_vltitulo   IN crappre.vltitulo%TYPE  --> Valor em atraso de desconto de titulos
                          
                           ,pr_xmllog     IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo
                           
  /* Buscar os dados da CADPRE */
  PROCEDURE pc_busca_cadpre(pr_inpessoa   IN crappre.inpessoa%TYPE  --> Codigo do tipo de pessoa
                          
                           ,pr_xmllog     IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo                           
  
  
END TELA_CADPRE;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADPRE AS
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_CADPRE
  --    Autor   : Marcos Martini
  --    Data    : Janeiro/2018                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela CADPRE (Ayllos Web)
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------
  
  -- Log
  vr_nmarquiv CONSTANT VARCHAR2(10) := 'cadpre';
  
  -- Variaveis da mensageria
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);
  
  --Controle de erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_saida EXCEPTION;
  
  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
  SELECT cdcooper
        ,nmrescop
        ,vlmaxleg
    FROM crapcop 
   WHERE cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Procedimento para inclusão de LOGTEL quando valor alterado
  PROCEDURE pr_gera_log_se_altera(pr_cdcooper IN NUMBER              --> Cop da alteração
                                 ,pr_cdoperad IN VARCHAR2            --> Ope da alteração 
                                 ,pr_dslabcam IN VARCHAR2            --> Label do campo
                                 ,pr_vlrantes IN VARCHAR2            --> Valor antes
                                 ,pr_vlrdepoi IN VARCHAR2            --> Valor depois
                                 ,pr_dscritic OUT VARCHAR2) IS       --> Saida
  BEGIN
    -- Se houve alteração
    IF pr_vlrantes <> pr_vlrdepoi THEN
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log  => 1
                                ,pr_des_log       => to_char(SYSDATE,'dd/mm/yyyy hh24:mi:ss')
                                                  || ' -->  Operador ' || pr_cdoperad 
                                                  || ' alterou o campo "'||pr_dslabcam||'"' 
                                                  || ' de '|| pr_vlrantes || ' para ' || pr_vlrdepoi||'.'
                                ,pr_nmarqlog      => vr_nmarquiv);
    END IF;
  EXCEPTION 
    WHEN OTHERS THEN
      pr_dscritic := 'CADPRE - Erro na rotina de LOG --> '||SQLERRM;  
  END;
  
  
  /* Gravar os dados da CADPRE */
  PROCEDURE pc_grava_cadpre(pr_inpessoa   IN crappre.inpessoa%TYPE  --> Codigo do tipo de pessoa
                           ,pr_cdfinemp   IN crappre.cdfinemp%TYPE  --> Codigo da Finalidade
                           ,pr_vllimmin   IN crappre.vllimmin%TYPE  --> Limite minimo
                           ,pr_vllimctr   IN crappre.vllimctr%TYPE  --> Limite minimo para contratacao
                           ,pr_vlmulpli   IN crappre.vlmulpli%TYPE  --> Valor multiplo
                           ,pr_qtdiavig   IN crappre.qtdiavig%TYPE  --> Quantidade de dias maximo de vigencia
                           ,pr_vllimman   IN crappre.vllimman%TYPE  --> Valor limite máximo para cargas manuais
                           ,pr_vllimaut   IN crappre.vllimaut%TYPE  --> Valor limite máximo para cargas automaticas
                           ,pr_dslstali   IN crappre.dslstali%TYPE  --> Lista com codigos de alineas de devolucao de cheque
                           ,pr_qtdevolu   IN crappre.qtdevolu%TYPE  --> Quantidade de devolucoes de cheque
                           ,pr_qtdiadev   IN crappre.qtdiadev%TYPE  --> Quantidade de dias para calc. devolucao de cheque
                           ,pr_vldiadev   IN crappre.vldiadev%TYPE  --> Valor de devoluções de cheque
                           ,pr_qtctaatr   IN crappre.qtctaatr%TYPE  --> Quantidade de dias de conta corrente em atraso
                           ,pr_vlctaatr   IN crappre.vlctaatr%TYPE  --> Valor de atraso em conta corrente
                           ,pr_qtepratr   IN crappre.qtepratr%TYPE  --> Quantidade de dias de emprestimo em atraso
                           ,pr_vlepratr   IN crappre.vlepratr%TYPE  --> Valor de emprestimo em atraso
                           ,pr_qtestour   IN crappre.qtestour%TYPE  --> Quantidade de estouros de conta
                           ,pr_qtdiaest   IN crappre.qtdiaest%TYPE  --> Quantidade de dias para calc. estouro de conta
                           ,pr_vldiaest   IN crappre.vldiaest%TYPE  --> Valor de estouro em conta
                           ,pr_qtavlatr   IN crappre.qtavlatr%TYPE  --> Operações como avalista Quantidade de dias em atraso
                           ,pr_vlavlatr   IN crappre.vlavlatr%TYPE  --> Operações como avalista Valor em atraso
                           ,pr_qtavlope   IN crappre.qtavlope%TYPE  --> Operações como avalista Quantidade de operações em atraso
                           ,pr_qtcjgatr   IN crappre.qtcjgatr%TYPE  --> Conjuge Quantidade de dias em atraso
                           ,pr_vlcjgatr   IN crappre.vlcjgatr%TYPE  --> Conjuge Valor em atraso
                           ,pr_qtcjgope   IN crappre.qtcjgope%TYPE  --> Conjuge Quantidade de operações em atraso 
                           ,pr_qtcarcre   IN crappre.qtcarcre%TYPE  --> Quantidade de dias em atraso de cartão de credito
                           ,pr_vlcarcre   IN crappre.vlcarcre%TYPE  --> Valor de atraso de cartão de credito
                           ,pr_qtdtitul   IN crappre.qtdtitul%TYPE  --> Quantidade de dias de atraso de titulos
                           ,pr_vltitulo   IN crappre.vltitulo%TYPE  --> Valor em atraso de desconto de titulos
                          
                           ,pr_xmllog     IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_grava_cadpre
     Sistema : Cartoes de Credito - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/19.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de Update tela CADPRE.

     Observacao: -----

     Alteracoes: 

     ..............................................................................*/ 
    DECLARE

      -- Selecionar os dados
      CURSOR cr_crappre(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT inpessoa
              ,cdfinemp
              ,vllimmin
              ,vllimctr
              ,vlmulpli
              ,qtdiavig
              ,dslstali
              ,qtdevolu
              ,qtdiadev
              ,vllimman
              ,vllimaut
              ,vldiadev
              ,qtctaatr
              ,vlctaatr
              ,qtepratr
              ,vlepratr
              ,qtestour
              ,qtdiaest
              ,vldiaest
              ,qtavlatr
              ,vlavlatr
              ,qtavlope
              ,qtcjgatr
              ,vlcjgatr
              ,qtcjgope
              ,qtcarcre
              ,vlcarcre
              ,qtdtitul
              ,vltitulo
          FROM crappre 
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa;
      rw_crappre cr_crappre%ROWTYPE;

      -- Selecionar os dados da Finalidade
      CURSOR cr_crapfin (pr_cdcooper IN crapfin.cdcooper%TYPE
                        ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
        SELECT cdfinemp
              ,dsfinemp
              ,flgstfin
          FROM crapfin 
         WHERE cdcooper = pr_cdcooper
           AND cdfinemp = pr_cdfinemp;
      rw_crapfin cr_crapfin%ROWTYPE;

    BEGIN
      -- Buscar dados da mensageria
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao 
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
          
      -- Valida o operador
      EMPR0002.pc_valida_operador(pr_cdcooper => vr_cdcooper
                                 ,pr_cdoperad => vr_cdoperad
                                 ,pr_dscritic => vr_dscritic);
      -- Se possui critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
           
        
      -- Cursor com os dados da Regra
      OPEN cr_crappre(pr_cdcooper => vr_cdcooper);
      FETCH cr_crappre 
       INTO rw_crappre;
      -- Se nao encontrar
      IF cr_crappre%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_crappre;
        vr_dscritic := 'Regra nao encontrada.';
        RAISE vr_exc_saida;
      END IF;
      -- Fecha o cursor
      CLOSE cr_crappre;

      -- Busca cooperativa
      OPEN cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop 
       INTO rw_crapcop;
      -- Fecha o cursor
      CLOSE cr_crapcop;
      
      -- Validar finalidade
      OPEN cr_crapfin (pr_cdcooper => vr_cdcooper
                      ,pr_cdfinemp => pr_cdfinemp);
      FETCH cr_crapfin
       INTO rw_crapfin;
      -- Se nao encontrar
      IF cr_crapfin%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_crapfin;
        vr_dscritic := 'Finalidade nao encontrada.';
        RAISE vr_exc_saida;
      END IF;
      -- Fecha o cursor
      CLOSE cr_crapfin;

      BEGIN
        -- Tentar efetuar o update
        UPDATE crappre 
           SET cdfinemp = pr_cdfinemp
              ,vllimmin = pr_vllimmin
              ,vllimctr = pr_vllimctr
              ,vlmulpli = pr_vlmulpli
              ,qtdiavig = pr_qtdiavig
              ,vllimman = pr_vllimman
              ,vllimaut = pr_vllimaut
              ,dslstali = pr_dslstali
              ,qtdevolu = pr_qtdevolu
              ,qtdiadev = pr_qtdiadev
              ,vldiadev = pr_vldiadev
              ,qtctaatr = pr_qtctaatr
              ,vlctaatr = pr_vlctaatr
              ,qtepratr = pr_qtepratr
              ,vlepratr = pr_vlepratr
              ,qtestour = pr_qtestour
              ,qtdiaest = pr_qtdiaest
              ,vldiaest = pr_vldiaest
              ,qtavlatr = pr_qtavlatr
              ,vlavlatr = pr_vlavlatr
              ,qtavlope = pr_qtavlope
              ,qtcjgatr = pr_qtcjgatr
              ,vlcjgatr = pr_vlcjgatr
              ,qtcjgope = pr_qtcjgope
              ,qtcarcre = pr_qtcarcre
              ,vlcarcre = pr_vlcarcre
              ,qtdtitul = pr_qtdtitul
              ,vltitulo = pr_vltitulo
            WHERE cdcooper = vr_cdcooper
              AND inpessoa = pr_inpessoa;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao atualizar Regra: ' || sqlerrm;
          RAISE vr_exc_saida;
      END;
  
      -- Checagem de alteração de campos para log
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Codigo da Finalidade'
                           ,rw_crappre.cdfinemp
                           ,pr_cdfinemp
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Limite Minimo Ofertado'
                           ,rw_crappre.vllimmin
                           ,pr_vllimmin
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Limite Minimo Contratacao'
                           ,rw_crappre.vllimctr
                           ,pr_vllimctr
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;      
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Valores Multiplos de'
                           ,rw_crappre.vlmulpli
                           ,pr_vlmulpli
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Quantidade de dias maximo de vigencia'
                           ,rw_crappre.qtdiavig
                           ,pr_qtdiavig
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Valor Limite para cargas Manuais'
                           ,rw_crappre.vllimman
                           ,pr_vllimman
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Valor Limite para cargas Automaticas'
                           ,rw_crappre.vllimaut
                           ,pr_vllimaut
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;      
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Alineas de Devolucoes'
                           ,rw_crappre.dslstali
                           ,pr_dslstali
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;  
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Quantidade de devolucoes Cheques'
                           ,rw_crappre.qtdevolu
                           ,pr_qtdevolu
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF; 
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Periodo de devolucoes Cheques'
                           ,rw_crappre.qtdiadev
                           ,pr_qtdiadev
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;      
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Valor de devolucoes Cheques'
                           ,rw_crappre.vldiadev
                           ,pr_vldiadev
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;      
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Dias Conta Corrente em Atraso'
                           ,rw_crappre.qtctaatr
                           ,pr_qtctaatr
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Valor de Atraso em Conta Corrente'
                           ,rw_crappre.vlctaatr
                           ,pr_vlctaatr
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;      
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Dias Emprestimo em Atraso'
                           ,rw_crappre.qtepratr
                           ,pr_qtepratr
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Valor de Atraso em Emprestimo'
                           ,rw_crappre.vlepratr
                           ,pr_vlepratr
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Qtde Estouro'
                           ,rw_crappre.qtestour
                           ,pr_qtestour
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Valor de Estouro'
                           ,rw_crappre.vldiaest
                           ,pr_vldiaest
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Qtde Dias Estouro'
                           ,rw_crappre.qtdiaest
                           ,pr_qtdiaest
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;      
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Qtde Dias Atrasos como Avalista'
                           ,rw_crappre.qtavlatr
                           ,pr_qtavlatr
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Valor de Atraso como Avalista'
                           ,rw_crappre.vlavlatr
                           ,pr_vlavlatr
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Qtde Atraso como Avalista '
                           ,rw_crappre.qtdiaest
                           ,pr_qtdiaest
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Qtde Dias Atrasos Conjuge'
                           ,rw_crappre.qtcjgatr
                           ,pr_qtcjgatr
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Valor de Atraso Conjuge'
                           ,rw_crappre.vlcjgatr
                           ,pr_vlcjgatr
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Qtde Atraso Conjuge '
                           ,rw_crappre.qtcjgope
                           ,pr_qtcjgope
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Qtde Dias Atrasos Cartao Credito'
                           ,rw_crappre.qtcarcre
                           ,pr_qtcarcre
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Valor de Atraso Cartao Credito'
                           ,rw_crappre.vlcarcre
                           ,pr_vlcarcre
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Qtde Dias Atrasos Desconto Titulo'
                           ,rw_crappre.qtdtitul
                           ,pr_qtdtitul
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      pr_gera_log_se_altera(vr_cdcooper
                           ,vr_cdoperad
                           ,'Valor de Atraso Desconto Titulo'
                           ,rw_crappre.vltitulo
                           ,pr_vltitulo
                           ,vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
        
      -- Gravação
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_cadpre;
  
  /* Buscar os dados da CADPRE */
  PROCEDURE pc_busca_cadpre(pr_inpessoa   IN crappre.inpessoa%TYPE  --> Codigo do tipo de pessoa
                          
                           ,pr_xmllog     IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_busca_cadpre
     Sistema : Cartoes de Credito - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Marcos Martini
     Data    : Janeiro/19.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina consulta da tela CADPRE.

     Observacao: -----

     Alteracoes: 

     ..............................................................................*/ 
    DECLARE

      -- Selecionar os dados
      CURSOR cr_crappre(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT inpessoa
              ,cdfinemp
              ,vllimmin
              ,vllimctr
              ,vlmulpli
              ,qtdiavig
              ,dslstali
              ,qtdevolu
              ,qtdiadev
              ,vllimman
              ,vllimaut
              ,vldiadev
              ,qtctaatr
              ,vlctaatr
              ,qtepratr
              ,vlepratr
              ,qtestour
              ,qtdiaest
              ,vldiaest
              ,qtavlatr
              ,vlavlatr
              ,qtavlope
              ,qtcjgatr
              ,vlcjgatr
              ,qtcjgope
              ,qtcarcre
              ,vlcarcre
              ,qtdtitul
              ,vltitulo
          FROM crappre 
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa;
      rw_crappre cr_crappre%ROWTYPE;

      -- Selecionar os dados da Finalidade
      CURSOR cr_crapfin (pr_cdcooper IN crapfin.cdcooper%TYPE
                        ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
      SELECT cdfinemp
            ,dsfinemp
            ,flgstfin
        FROM crapfin 
       WHERE cdcooper = pr_cdcooper
         AND cdfinemp = pr_cdfinemp;
      rw_crapfin cr_crapfin%ROWTYPE;

    BEGIN
      -- Buscar dados da mensageria
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao 
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
          
      -- Valida o operador
      EMPR0002.pc_valida_operador(pr_cdcooper => vr_cdcooper
                                 ,pr_cdoperad => vr_cdoperad
                                 ,pr_dscritic => vr_dscritic);
      -- Se possui critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
        
      -- Cursor com os dados da Regra
      OPEN cr_crappre(pr_cdcooper => vr_cdcooper);
      FETCH cr_crappre 
       INTO rw_crappre;
      -- Se nao encontrar
      IF cr_crappre%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_crappre;
        vr_dscritic := 'Regra nao encontrada.';
        RAISE vr_exc_saida;
      END IF;
      -- Fecha o cursor
      CLOSE cr_crappre;

      -- Busca cooperativa
      OPEN cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop 
       INTO rw_crapcop;
      -- Fecha o cursor
      CLOSE cr_crapcop;
      
      -- Validar finalidade
      OPEN cr_crapfin (pr_cdcooper => vr_cdcooper
                      ,pr_cdfinemp => rw_crappre.cdfinemp);
      FETCH cr_crapfin
       INTO rw_crapfin;
      -- Se nao encontrar
      IF cr_crapfin%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_crapfin;
        vr_dscritic := 'Finalidade nao encontrada.';
        RAISE vr_exc_saida;
      END IF;
      -- Fecha o cursor
      CLOSE cr_crapfin;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdfinemp', pr_tag_cont => rw_crappre.cdfinemp, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dsfinemp', pr_tag_cont => rw_crapfin.dsfinemp, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimmin', pr_tag_cont => rw_crappre.vllimmin, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimctr', pr_tag_cont => rw_crappre.vllimctr, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlmulpli', pr_tag_cont => rw_crappre.vlmulpli, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiavig', pr_tag_cont => rw_crappre.qtdiavig, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimman', pr_tag_cont => rw_crappre.vllimman, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimaut', pr_tag_cont => rw_crappre.vllimaut, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dslstali', pr_tag_cont => rw_crappre.dslstali, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdevolu', pr_tag_cont => rw_crappre.qtdevolu, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiadev', pr_tag_cont => rw_crappre.qtdiadev, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vldiadev', pr_tag_cont => rw_crappre.vldiadev, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtctaatr', pr_tag_cont => rw_crappre.qtctaatr, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlctaatr', pr_tag_cont => rw_crappre.vlctaatr, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtepratr', pr_tag_cont => rw_crappre.qtepratr, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlepratr', pr_tag_cont => rw_crappre.vlepratr, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtestour', pr_tag_cont => rw_crappre.qtestour, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiaest', pr_tag_cont => rw_crappre.qtdiaest, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vldiaest', pr_tag_cont => rw_crappre.vldiaest, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtavlatr', pr_tag_cont => rw_crappre.qtavlatr, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlavlatr', pr_tag_cont => rw_crappre.vlavlatr, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtavlope', pr_tag_cont => rw_crappre.qtavlope, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtcjgatr', pr_tag_cont => rw_crappre.qtcjgatr, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlcjgatr', pr_tag_cont => rw_crappre.vlcjgatr, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtcjgope', pr_tag_cont => rw_crappre.qtcjgope, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtcarcre', pr_tag_cont => rw_crappre.qtcarcre, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlcarcre', pr_tag_cont => rw_crappre.vlcarcre, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdtitul', pr_tag_cont => rw_crappre.qtdtitul, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vltitulo', pr_tag_cont => rw_crappre.vltitulo, pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_cadpre;  
  
END TELA_CADPRE;
/
