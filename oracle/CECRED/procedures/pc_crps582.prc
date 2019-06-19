CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS582 (pr_cdcooper  IN crapcop.cdcooper%TYPE
                                       ,pr_flgresta  IN PLS_INTEGER
                                       ,pr_stprogra OUT PLS_INTEGER
                                       ,pr_infimsol OUT PLS_INTEGER
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT VARCHAR2) AS
/* .............................................................................
   Programa: PC_CRPS582                        Antigo: Fontes/crps582.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vitor/Magui
   Data    : Outubro/2010                      Ultima atualizacao: 05/06/2019

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Rodar na solicitacao 4. Ordem 40.
               Fluxo de compensacao BB, CECRED e Bancoob.

   Alteracoes: Ajuste nos dados apresentados e geracao de arquivo para EXCEL
               (Ze).

               01/03/2011 - Incluir o fontes/imprim.p (Ze).

               01/04/2011 - Ajuste no envio por email do arq. CSV - Excel (Ze).

               21/07/2011 - Alterado format dos campos vlr_nossodoc, vlr_seudoc
                            para "zz,zzz,zz9.99" (Adriano).

               01/08/2011 - Ajuste no envio por email do arq. CSV - Excel (Ze).

               24/10/2013 - Conversao Progress => Oracle (Gabriel).

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

               05/06/2019 - Inserido novo Historico 2973 em retorno de cheques devovidos de deposito CECRED (Luis Fagundes/AMCOM)
............................................................................. */

  -- Variaveis de uso no programa
  vr_cdprogra crapprg.cdprogra%TYPE := 'CRPS582';  -- Codigo do presente programa
  vr_dtinimes    DATE;                             -- Data inicio base
  vr_dtfimmes    DATE;                             -- Data fim base
  vr_dtmvtolt    DATE;                             -- Data para leitura das tabelas
  vr_dsdchave    VARCHAR2(20);                     -- Chave para pl table do relatorio
  vr_cddbanco    NUMBER;                           -- Codigo do Banco
  vr_nmdbanco    VARCHAR2(100);                    -- Nome do Banco
  vr_bk_cddbanco NUMBER;                           -- Backup do codigo do banco
  vr_dtrefere    VARCHAR2(50);                     -- Data par relatorio
  vr_diaseman    VARCHAR2(50);                     -- Dia da semana
  vr_cdcritic    crapcri.cdcritic%TYPE;            -- Codigo de critica
  vr_dscritic    VARCHAR2(2000);                   -- Descricao de critica
  vr_des_xml     CLOB;                             -- XML do relatorio
  vr_arquivo_txt UTL_FILE.file_type;               -- Arquivo crrl579.csv
  vr_nmdiretorio VARCHAR2(50);                     -- Diretorio do crrl579.csv
  vr_email_dest  VARCHAR2(100);                    -- Email do destinatario crrl579.csv
  vr_exc_saida   EXCEPTION;                        -- Tratamento de excecao parando a cadeia
  vr_exc_fimprg  EXCEPTION;                        -- Tratamento de excecao sem parar a cadeia

  -- Cursor da cooperativa logada
  CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT cop.cdcooper
          ,cop.dsdircop
      FROM crapcop cop
     WHERE cop.cdcooper = NVL(pr_cdcooper,cop.cdcooper);

  -- Cursor para leitura de lancamentos
  CURSOR cr_craplcm (pr_cdcooper craplcm.cdcooper%TYPE
                    ,pr_dtmvtolt craplcm.dtmvtolt%TYPE) IS
    SELECT lcm.vllanmto
          ,lcm.cdhistor
          ,lcm.nrdctitg
          ,lcm.dsidenti
          ,lcm.nrdctabb
          ,lcm.cdbanchq
          ,lcm.nrdolote
      FROM craplcm lcm
     WHERE lcm.cdcooper = pr_cdcooper
       AND lcm.dtmvtolt = pr_dtmvtolt
       /* Históricos buscados:
         24 - CH.DEV.PRC.           27 - CH.DEV.FPR.             47 - CHQ.DEVOL.
         50 - CHEQUE COMP.          56 - CHQ.SAL.COMP            59 - CHQ.TRF.COMP.
         78 - CH.DEV.TRF.           97 - CR.IMP.RENDA           156 - CHQ.DEVOL.
        191 - CHQ.DEVOL.           266 - CRED. COBRANCA         313 - CHEQUE COMP.
        314 - CREDITO DOC          319 - CREDITO DOC            338 - CHQ.DEVOL.
        339 - DOC SEG.SAUDE        340 - CHQ.TRF.COMP.          345 - DEPOS.BANCOOB
        351 - DEV.CH.DEP.          399 - DEV.CH.DESCTO          445 - DEP. COMP. BL
        519 - CREDITO TEC          524 - CHEQUE COMP.           551 - TEC SALARIO
        572 - CHQ.TRF.COMP.        573 - CHQ.DEVOL.             575 - CREDITO DOC
        578 - CREDITO TED          651 - CREDITO TED            657 - CH.DEV.CUST.
        799 - CREDITO TEC         2973 - DEV.CH.DEP.BLQ 
       */
       AND lcm.cdhistor IN (24,27,47,50,56,59,78,97,156,191,266,313,314,319,338,339,340,345,351,2973,399,445,519,524,551,572,573,575,578,651,657,799) ;

  -- Cursor para a Remessa - DOC/TED
  CURSOR cr_craptvl (pr_cdcooper craptvl.cdcooper%TYPE
                    ,pr_dtmvtolt craptvl.dtmvtolt%TYPE) IS
    SELECT tvl.vldocrcb
          ,tvl.tpdoctrf
          ,tvl.cdbcoenv
      FROM craptvl tvl
     WHERE tvl.cdcooper = pr_cdcooper
       AND tvl.dtmvtolt = pr_dtmvtolt
       AND tvl.cdbcoenv != 0;

  -- Cursor para leitura de titulos
  CURSOR cr_craptit (pr_cdcooper craptvl.cdcooper%TYPE
                    ,pr_dtmvtolt craptvl.dtmvtolt%TYPE) IS
    SELECT tit.vldpagto
          ,tit.dtdpagto
          ,age.cdbantit
      FROM craptit tit
          ,crapage age
     WHERE tit.cdcooper = pr_cdcooper    -- Cooperativa
       AND tit.dtdpagto = pr_dtmvtolt    -- Data de pagamento
       AND tit.tpdocmto = 20             -- Tipo de documento
       AND tit.intitcop = 0              -- Tipo de titulo recebido (0 = Outros bancos)
       AND tit.flgenvio = 1              -- Indica se o registro ja foi enviado para o BANCO(BB)
       AND age.cdcooper = tit.cdcooper   -- Cooperativa
       AND age.cdagenci = tit.cdagenci   -- PAC
       AND age.cdbantit IN (1,756,85);   -- Banco COMPE Titulo

  -- Cursor para leitura de cheques
  CURSOR cr_crapchd (pr_cdcooper craptvl.cdcooper%TYPE
                    ,pr_dtmvtolt craptvl.dtmvtolt%TYPE) IS
    SELECT chd.dtmvtolt
          ,age.cdbanchq
          ,chd.vlcheque
      FROM crapchd chd
          ,crapage age
     WHERE chd.cdcooper = pr_cdcooper  -- Cooperativa
       AND chd.dtmvtolt = pr_dtmvtolt  -- Data de movimento
       AND chd.inchqcop = 0            -- Tipo de cheque recebido (0 = Outros bancos)
       AND chd.flgenvio = 1            -- Indica se o registro ja foi enviado para o BANCO(BB)
       AND age.cdcooper = chd.cdcooper -- Cooperativa
       AND age.cdagenci = chd.cdagenci -- PAC
       AND age.cdbanchq IN (1,756,85); -- Banco COMPE Titulo

  -- Record para acumlar valores totais
  TYPE typ_reg_totais IS
    RECORD(vlrseuted   NUMBER(20,2)
          ,vlrseudoc   NUMBER(20,2)
          ,vlrsuacob   NUMBER(20,2)
          ,vlrsuacobvl NUMBER(20,2)
          ,vlrsuacompe NUMBER(20,2)
          ,vlrsuacomp2 NUMBER(20,2)
          ,vlrdevrecen NUMBER(20,2)
          ,vlrdevenvin NUMBER(20,2)
          ,vlrdevenvid NUMBER(20,2)
          ,vlrnossodoc NUMBER(20,2)
          ,vlrnossoted NUMBER(20,2)
          ,vlrnossacob NUMBER(20,2)
          ,vlrnoscobvl NUMBER(20,2)
          ,vlrnossarem NUMBER(20,2)
          ,vlrnossare2 NUMBER(20,2)
          ,vlrdevreced NUMBER(20,2));

  TYPE typ_tab_totais IS
    TABLE OF typ_reg_totais
          INDEX BY VARCHAR2(20); -- Obs. A chave é o codigo do banco concatenada a data

  vr_tab_totais typ_tab_totais;

  -- Dados da cooperativa
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Dados da data da cooperativa logada
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  PROCEDURE pc_traz_chave(pr_cddbanco IN NUMBER
                         ,pr_dtmvtolt IN DATE
                         ,pr_dsdchave OUT VARCHAR2) IS
  BEGIN

    -- Cria chave unica para a PL Table
    pr_dsdchave := lpad(to_char(pr_cddbanco),4,'0') || to_char(pr_dtmvtolt,'ddmmyyyy');

    -- Inicializar valores se nao existir ainda
    IF  NOT vr_tab_totais.EXISTS(pr_dsdchave)  THEN
      vr_tab_totais(pr_dsdchave).vlrseuted := 0;
    END IF;

  END;

  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
  BEGIN
    dbms_lob.writeappend(vr_des_xml, LENGTH(pr_des_dados), pr_des_dados);
  END;

BEGIN

   -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                            ,pr_action => NULL);

  -- Obter os dados da cooperativa logada
  OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);

  FETCH cr_crapcop INTO rw_crapcop;

  -- Se cooperativa nao encontrada, gera critica para o log
  IF  cr_crapcop%notfound   THEN

    vr_cdcritic := 651;

    CLOSE cr_crapcop;

    RAISE vr_exc_saida;

  END IF;

  CLOSE cr_crapcop;

  -- Obter dados da data da cooperativa
  OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);

  FETCH btch0001.cr_crapdat INTO rw_crapdat;

  -- Se nao exisitir a data da cooperativa, obter critica e jogar para o log
  IF  btch0001.cr_crapdat%notfound  THEN

    vr_cdcritic := 1;

    CLOSE btch0001.cr_crapdat;

    RAISE vr_exc_saida;

  END IF;

  CLOSE btch0001.cr_crapdat;

  -- Realizar as validacoes do iniprg
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);

  -- Se possui critica, buscar a descricao e jogar ao log
  IF  vr_cdcritic <> 0  THEN
    RAISE vr_exc_saida;
  END IF;

  -- Data de inicio e fim para leitura das tabelas
  vr_dtinimes := rw_crapdat.dtinimes;
  vr_dtfimmes := rw_crapdat.dtmvtolt;

  -- Percorre todas as cooperativas
  FOR rw_crapcop IN cr_crapcop (pr_cdcooper => NULL) LOOP

    vr_dtmvtolt := vr_dtinimes;

    -- Loop para datas, percorrer o mes inteiro
    LOOP

      -- Se terminou a leitura no mes, finaliza Loop
      IF  vr_dtmvtolt > vr_dtfimmes  THEN
        EXIT;
      END IF;

      -- Nossa Remessa - Doc/Ted
      FOR rw_craptvl IN cr_craptvl (pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_dtmvtolt => vr_dtmvtolt) LOOP

        -- Trazer chave para a pl table
        pc_traz_chave(pr_cddbanco => rw_craptvl.cdbcoenv
                     ,pr_dtmvtolt => vr_dtmvtolt
                     ,pr_dsdchave => vr_dsdchave);
        -- DOC
        IF  rw_craptvl.tpdoctrf <> 3 THEN
          vr_tab_totais(vr_dsdchave).vlrnossodoc := nvl(vr_tab_totais(vr_dsdchave).vlrnossodoc,0) + rw_craptvl.vldocrcb;
        ELSE  -- TED
          vr_tab_totais(vr_dsdchave).vlrnossoted := nvl(vr_tab_totais(vr_dsdchave).vlrnossoted,0) + rw_craptvl.vldocrcb;
        END IF;

      END LOOP;

      -- Leitura dos lancamentos
      FOR rw_craplcm IN cr_craplcm (pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_dtmvtolt => vr_dtmvtolt) LOOP

        -- Sua remessa doc/tec bancoob - nao possui ted
        IF  rw_craplcm.cdhistor IN (97,319,339,345,445,519,551)  THEN

          pc_traz_chave(pr_cddbanco => 756
                       ,pr_dtmvtolt => vr_dtmvtolt
                       ,pr_dsdchave => vr_dsdchave);
          -- TEC
          IF  rw_craplcm.cdhistor IN (519,551)  THEN
            vr_tab_totais(vr_dsdchave).vlrseuted := nvl(vr_tab_totais(vr_dsdchave).vlrseuted,0) + rw_craplcm.vllanmto;
          ELSE
          -- DOC
            vr_tab_totais(vr_dsdchave).vlrseudoc := nvl(vr_tab_totais(vr_dsdchave).vlrseudoc,0) + rw_craplcm.vllanmto;
          END IF;
        END IF;

        -- Sua Remessa Doc/Ted Cecred
        IF  rw_craplcm.cdhistor IN (575,578,799)  THEN

          -- Retornar a chave para PL Table
          pc_traz_chave(pr_cddbanco => 85
                       ,pr_dtmvtolt => vr_dtmvtolt
                       ,pr_dsdchave => vr_dsdchave);

          -- TED/TEC
          IF  rw_craplcm.cdhistor IN (578,799)  THEN
            vr_tab_totais(vr_dsdchave).vlrseuted := nvl(vr_tab_totais(vr_dsdchave).vlrseuted,0) + rw_craplcm.vllanmto;
          ELSE
          -- DOC
            vr_tab_totais(vr_dsdchave).vlrseudoc := nvl(vr_tab_totais(vr_dsdchave).vlrseudoc,0) + rw_craplcm.vllanmto;
          END IF;
        END IF;

        -- Sua remessa doc/ted bb
        IF  rw_craplcm.cdhistor IN (314,651)  THEN

          -- Retornar a chave para PL Table
          pc_traz_chave(pr_cddbanco => 1
                       ,pr_dtmvtolt => vr_dtmvtolt
                       ,pr_dsdchave => vr_dsdchave);
          -- TED
          IF  rw_craplcm.cdhistor = 651  THEN
            vr_tab_totais(vr_dsdchave).vlrseuted := nvl(vr_tab_totais(vr_dsdchave).vlrseuted,0) + rw_craplcm.vllanmto;
          ELSE
          -- DOC
            vr_tab_totais(vr_dsdchave).vlrseudoc := nvl(vr_tab_totais(vr_dsdchave).vlrseudoc,0) + rw_craplcm.vllanmto;
          END IF;
        END IF;

        --  Titulo (Cobranca) Sua Remessa - Somente BB Possui
        IF  rw_craplcm.cdhistor = 266  THEN

          -- Retornar a chave para PL Table
          pc_traz_chave(pr_cddbanco => 1
                       ,pr_dtmvtolt => vr_dtmvtolt
                       ,pr_dsdchave => vr_dsdchave);
          -- Titulo menor
          IF  rw_craplcm.vllanmto < 5000  THEN
            vr_tab_totais(vr_dsdchave).vlrsuacob := nvl(vr_tab_totais(vr_dsdchave).vlrsuacob,0) + rw_craplcm.vllanmto;
          END IF;
          -- Titulo maior
          IF  rw_craplcm.vllanmto >= 5000  THEN
            vr_tab_totais(vr_dsdchave).vlrsuacobvl := nvl(vr_tab_totais(vr_dsdchave).vlrsuacobvl,0) + rw_craplcm.vllanmto;
          END IF;

        END IF;

        --  Cheque sua remessa - Bancoob
        IF  rw_craplcm.cdhistor IN (313,340)
        AND rw_craplcm.nrdctitg = ' '  THEN

          -- Retornar a chave para PL Table
          pc_traz_chave(pr_cddbanco => 756
                       ,pr_dtmvtolt => vr_dtmvtolt
                       ,pr_dsdchave => vr_dsdchave);
          -- Cheque maior
          IF  rw_craplcm.vllanmto >= 300  THEN
            vr_tab_totais(vr_dsdchave).vlrsuacompe := nvl(vr_tab_totais(vr_dsdchave).vlrsuacompe,0) + rw_craplcm.vllanmto;
          END IF;

          -- Cheque menor
          IF  rw_craplcm.vllanmto < 300  THEN
            vr_tab_totais(vr_dsdchave).vlrsuacomp2 := nvl(vr_tab_totais(vr_dsdchave).vlrsuacomp2,0) + rw_craplcm.vllanmto;
          END IF;

        END IF;

        -- Cheque sua remessa - CECRED
        IF  rw_craplcm.cdhistor IN (524,572)
        AND rw_craplcm.nrdctitg = ' '  THEN
          -- Retornar a chave para PL Table
          pc_traz_chave(pr_cddbanco => 85
                       ,pr_dtmvtolt => vr_dtmvtolt
                       ,pr_dsdchave => vr_dsdchave);
          -- Cheque maior
          IF  rw_craplcm.vllanmto >= 300  THEN
            vr_tab_totais(vr_dsdchave).vlrsuacompe := nvl(vr_tab_totais(vr_dsdchave).vlrsuacompe,0) + rw_craplcm.vllanmto;
          END IF;

          -- Cheque menor
          IF  rw_craplcm.vllanmto < 300  THEN
            vr_tab_totais(vr_dsdchave).vlrsuacomp2 := nvl(vr_tab_totais(vr_dsdchave).vlrsuacomp2,0) + rw_craplcm.vllanmto;
          END IF;
        END IF;

        -- Cheque Sua Remessa - Bb
        IF  rw_craplcm.cdhistor IN (50,56,59)
        AND rw_craplcm.nrdctabb <> 0  THEN
          -- Retornar a chave para PL Table
          pc_traz_chave(pr_cddbanco => 1
                       ,pr_dtmvtolt => vr_dtmvtolt
                       ,pr_dsdchave => vr_dsdchave);
          -- Cheque maior
          IF  rw_craplcm.vllanmto >= 300  THEN
            vr_tab_totais(vr_dsdchave).vlrsuacompe := nvl(vr_tab_totais(vr_dsdchave).vlrsuacompe,0) + rw_craplcm.vllanmto;
          END IF;

          -- Cheque menor
          IF  rw_craplcm.vllanmto < 300  THEN
            vr_tab_totais(vr_dsdchave).vlrsuacomp2 := nvl(vr_tab_totais(vr_dsdchave).vlrsuacomp2,0) + rw_craplcm.vllanmto;
          END IF;
        END IF;

        -- Devolucao Recebida - BB
        IF  rw_craplcm.cdhistor IN (24,27,351,399,657)
        AND rw_craplcm.dsidenti = 'BB'  THEN
          -- Retornar a chave para PL Table
          pc_traz_chave(pr_cddbanco => 1
                       ,pr_dtmvtolt => vr_dtmvtolt
                       ,pr_dsdchave => vr_dsdchave);

          vr_tab_totais(vr_dsdchave).vlrdevrecen := nvl(vr_tab_totais(vr_dsdchave).vlrdevrecen,0) + rw_craplcm.vllanmto;

        END IF;

        -- Devolucao recebida - BCB
        IF  rw_craplcm.cdhistor IN (24,27,351,399,657)
        AND rw_craplcm.dsidenti = 'BCB'  THEN
          -- Obter chave da PL TABLE
          pc_traz_chave(pr_cddbanco => 756
                       ,pr_dtmvtolt => vr_dtmvtolt
                       ,pr_dsdchave => vr_dsdchave);

          vr_tab_totais(vr_dsdchave).vlrdevrecen := nvl(vr_tab_totais(vr_dsdchave).vlrdevrecen,0) + rw_craplcm.vllanmto;

        END IF;

        -- Devolucao recebida - CECRED(085)
        IF  rw_craplcm.cdhistor IN (24,27,351,2973,399,657)
        AND rw_craplcm.dsidenti = 'CTL'  THEN
          pc_traz_chave(pr_cddbanco => 85
                       ,pr_dtmvtolt => vr_dtmvtolt
                       ,pr_dsdchave => vr_dsdchave);

          vr_tab_totais(vr_dsdchave).vlrdevrecen := nvl(vr_tab_totais(vr_dsdchave).vlrdevrecen,0) + rw_craplcm.vllanmto;

        END IF;

        -- Devolucao Enviada - BB
        IF  rw_craplcm.cdhistor IN (47,78,156,191,338,573)
        AND rw_craplcm.cdbanchq = 1
        AND rw_craplcm.nrdolote IN (8451,10109) THEN
          -- Obter chave da PL TABLE
          pc_traz_chave(pr_cddbanco => 1
                        ,pr_dtmvtolt => vr_dtmvtolt
                        ,pr_dsdchave => vr_dsdchave);

          vr_tab_totais(vr_dsdchave).vlrdevenvin := nvl(vr_tab_totais(vr_dsdchave).vlrdevenvin,0) + rw_craplcm.vllanmto;

        END IF;

        -- Devolucao Enviada - BCB
        IF  rw_craplcm.cdhistor IN (47,78,156,191,338,573)
        AND rw_craplcm.cdbanchq = 756
        AND rw_craplcm.nrdolote IN (8451,10110) THEN
          -- Obter chave da PL TABLE
          pc_traz_chave(pr_cddbanco => 756
                        ,pr_dtmvtolt => vr_dtmvtolt
                        ,pr_dsdchave => vr_dsdchave);

          vr_tab_totais(vr_dsdchave).vlrdevenvin := nvl(vr_tab_totais(vr_dsdchave).vlrdevenvin,0) + rw_craplcm.vllanmto;

        END IF;

        -- Devolucao Enviada - Cecred
        IF  rw_craplcm.cdhistor IN (47,78,156,191,338,573)
        AND rw_craplcm.cdbanchq = 85
        AND rw_craplcm.nrdolote IN (8451,10117) THEN
          pc_traz_chave(pr_cddbanco => 85
                        ,pr_dtmvtolt => vr_dtmvtolt
                        ,pr_dsdchave => vr_dsdchave);
          -- Noturna = 1
          IF  rw_craplcm.dsidenti = '1'  THEN
            vr_tab_totais(vr_dsdchave).vlrdevenvin := nvl(vr_tab_totais(vr_dsdchave).vlrdevenvin,0) + rw_craplcm.vllanmto;
          ELSIF rw_craplcm.dsidenti = '2'  THEN -- Diurna  = 2
            vr_tab_totais(vr_dsdchave).vlrdevenvid := nvl(vr_tab_totais(vr_dsdchave).vlrdevenvid,0) + rw_craplcm.vllanmto;
          END IF;

        END IF;

      END LOOP; -- Fim leitura craplcm

      -- Titulo (cobranca) nossa remessa
      FOR rw_craptit IN cr_craptit (pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_dtmvtolt => vr_dtmvtolt) LOOP
        -- Obter chave da PL TABLE
        pc_traz_chave(pr_cddbanco => rw_craptit.cdbantit
                     ,pr_dtmvtolt => rw_craptit.dtdpagto
                     ,pr_dsdchave => vr_dsdchave);
        -- Titulos menores
        IF  rw_craptit.vldpagto < 5000  THEN
          vr_tab_totais(vr_dsdchave).vlrnossacob := nvl(vr_tab_totais(vr_dsdchave).vlrnossacob,0) + rw_craptit.vldpagto;
        END IF;
        -- Titulos maiores
        IF  rw_craptit.vldpagto >= 5000  THEN
          vr_tab_totais(vr_dsdchave).vlrnoscobvl := nvl(vr_tab_totais(vr_dsdchave).vlrnoscobvl,0) + rw_craptit.vldpagto;
        END IF;

      END LOOP;

      -- Cheque - Nossa Remessa
      FOR rw_crapchd IN cr_crapchd (pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_dtmvtolt => vr_dtmvtolt) LOOP
        -- Obter chave da PL TABLE
        pc_traz_chave(pr_cddbanco => rw_crapchd.cdbanchq
                     ,pr_dtmvtolt => rw_crapchd.dtmvtolt
                     ,pr_dsdchave => vr_dsdchave);

        -- Cheques maiores
        IF  rw_crapchd.vlcheque >= 300  THEN
          vr_tab_totais(vr_dsdchave).vlrnossarem := nvl(vr_tab_totais(vr_dsdchave).vlrnossarem,0) + rw_crapchd.vlcheque;
        END IF;

        -- Cheques menores
        IF  rw_crapchd.vlcheque < 300  THEN
          vr_tab_totais(vr_dsdchave).vlrnossare2 := nvl(vr_tab_totais(vr_dsdchave).vlrnossare2,0) + rw_crapchd.vlcheque;
        END IF;

      END LOOP;

      vr_dtmvtolt := vr_dtmvtolt + 1;

    END LOOP;

  END LOOP;

  -- Buscar o diretorio /rl
  vr_nmdiretorio := gene0001.fn_diretorio( pr_tpdireto => 'C'
                                          ,pr_cdcooper => pr_cdcooper);

  -- Abre arquivo crrl579.csv
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdiretorio||'/rl', --> Diretório do arquivo
                           pr_nmarquiv => 'crrl579.csv',  --> Nome do arquivo
                           pr_tipabert => 'W',            --> Modo de abertura (R,W,A)
                           pr_utlfileh => vr_arquivo_txt, --> Handle do arquivo aberto
                           pr_des_erro => vr_dscritic);   --> Retorno da critica

  -- Se retornou erro
  IF  vr_dscritic IS NOT NULL  THEN
    RAISE vr_exc_saida;
  END IF;

  -- Cabecalho do crrl579.csv
  gene0001.pc_escr_linha_arquivo(vr_arquivo_txt,'BANCO;DATA;DIA SEMANA;CHQ MAIOR SR;CHQ MAIOR NR;CHQ MENOR SR;CHQ MENOR NR;' ||
                                                'DEV REC DIURNA;DEV REC NOTURNA;DEV ENV DIURNA;DEV ENV NOTURNA;DOC SR;DOC NR;' ||
                                                'TED SR;TED NR;COBRANCA SR;COBRANCA NR;COBRANCA VL SR;COBRANCA VL NR;');

   -- Abrir arquivo para XML do relatorio 579
  vr_des_xml := null;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');

  -- Limpar codigo do banco
  vr_bk_cddbanco := 0;
  -- Obtem a primeira chave da pl table
  vr_dsdchave := vr_tab_totais.FIRST;

  -- Percorrer os registros do relatorio
  WHILE vr_dsdchave IS NOT NULL LOOP

    -- Se a chave nao existe, proximo
    IF  NOT vr_tab_totais.EXISTS(vr_dsdchave)  THEN
      CONTINUE;
    END IF;

    -- Obter o codigo do banco
    vr_cddbanco := to_number(substr(vr_dsdchave,0,4));
    vr_dtmvtolt := to_date (substr(vr_dsdchave,5,8),'dd/mm/yyyy');

    -- Se mudou de banco
    IF  vr_bk_cddbanco <> vr_cddbanco  THEN

      -- Fechar TAG do banco
      IF  vr_bk_cddbanco <> 0  THEN
         pc_escreve_xml('</banco>');
      END IF;

      -- Obter o nome do banco
      IF  vr_cddbanco = 1  THEN
        vr_nmdbanco := 'BANCO DO BRASIL - ';
      ELSIF
        vr_cddbanco = 85  THEN
        vr_nmdbanco := 'CEDRED - ';
      ELSE
        vr_nmdbanco := 'BANCOOB - ';
      END IF;

      -- Concatenar o codigo do banco
      vr_nmdbanco := vr_nmdbanco || vr_cddbanco;

      -- Abrir TAG do banco
      pc_escreve_xml('<banco nmdbanco= "' || vr_nmdbanco || '" cddbanco="' || vr_cddbanco ||  '" >');

    END IF;

    -- Data referencia para relatorio
    vr_dtrefere := to_char(vr_dtmvtolt,'dd') || '/' ||  substr(gene0001.vr_vet_nmmesano(to_char(vr_dtmvtolt,'MM')),0,3);

    -- Dia da semana
    vr_diaseman := to_char(vr_dtmvtolt,'d') || 'a';

    pc_escreve_xml('<fluxo>'||
                     '<dtrefere>'    || vr_dtrefere                            || '</dtrefere>'     ||
                     '<diaseman>'    || vr_diaseman                            || '</diaseman>'     ||
                     '<vlrsuacompe>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrsuacompe,0),'fm999G999G990D00') || '</vlrsuacompe>'  ||
                     '<vlrnossarem>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrnossarem,0),'fm999G999G990D00') || '</vlrnossarem>'  ||
                     '<vlrsuacomp2>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrsuacomp2,0),'fm999G999G990D00') || '</vlrsuacomp2>'  ||
                     '<vlrnossare2>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrnossare2,0),'fm999G999G990D00') || '</vlrnossare2>'  ||
                     '<vlrdevreced>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrdevreced,0),'fm999G999G990D00') || '</vlrdevreced>'  ||
                     '<vlrdevrecen>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrdevrecen,0),'fm999G999G990D00') || '</vlrdevrecen>'  ||
                     '<vlrdevenvid>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrdevenvid,0),'fm999G999G990D00') || '</vlrdevenvid>'  ||
                     '<vlrdevenvin>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrdevenvin,0),'fm999G999G990D00') || '</vlrdevenvin>'  ||
                     '<vlrseudoc>'   || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrseudoc,0),'fm999G999G990D00')   || '</vlrseudoc>'   ||
                     '<vlrnossodoc>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrnossodoc,0),'fm999G999G990D00') || '</vlrnossodoc>' ||
                     '<vlrseuted>'   || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrseuted,0),'fm999G999G990D00')   || '</vlrseuted>'   ||
                     '<vlrnossoted>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrnossoted,0),'fm999G999G990D00') || '</vlrnossoted>'  ||
                     '<vlrsuacob >'  || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrsuacob,0),'fm999G999G990D00')   || '</vlrsuacob>'   ||
                     '<vlrnossacob>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrnossacob,0),'fm999G999G990D00') || '</vlrnossacob>' ||
                     '<vlrsuacobvl>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrsuacobvl,0),'fm999G999G990D00') || '</vlrsuacobvl>' ||
                     '<vlrnoscobvl>' || to_char(nvl(vr_tab_totais(vr_dsdchave).vlrnoscobvl,0),'fm999G999G990D00') || '</vlrnoscobvl>' ||
                   '</fluxo>');

    -- Escrever detalhe do .csv
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_cddbanco || ';' ||
                                                   vr_dtrefere || ';' ||
                                                   vr_diaseman || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrsuacompe,0) || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrnossarem,0) || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrsuacomp2,0) || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrnossare2,0) || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrdevreced,0) || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrdevrecen,0) || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrdevenvid,0) || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrdevenvin,0) || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrseudoc,0)   || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrnossodoc,0) || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrseuted,0)   || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrnossoted,0) || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrsuacob,0)   || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrnossacob,0) || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrsuacobvl,0) || ';' ||
                                                   nvl(vr_tab_totais(vr_dsdchave).vlrnoscobvl,0) || ';');

    -- Salvar o ultimo codigo do banco
    vr_bk_cddbanco := vr_cddbanco;
    -- Obtem a proxima chave na sequencia
    vr_dsdchave := vr_tab_totais.NEXT(vr_dsdchave);

  END LOOP;

  -- Fechar Tag do banco
  IF  vr_bk_cddbanco <> 0  THEN
    pc_escreve_xml('</banco>');
  END IF;

  -- Fecha a tag principal para encerrar o XML
  pc_escreve_xml('</raiz>');

  -- Criar o arquivo no diretorio especificado
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                             ,pr_cdprogra  => vr_cdprogra
                             ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                             ,pr_dsxml     => vr_des_xml
                             ,pr_dsxmlnode => '/raiz'
                             ,pr_dsjasper  => 'crrl579.jasper'
                             ,pr_dsparams  => ''
                             ,pr_dsarqsaid => vr_nmdiretorio||'/rl/crrl579.lst'
                             ,pr_flg_gerar => 'N'
                             ,pr_qtcoluna  => 234
                             ,pr_sqcabrel  => 1
                             ,pr_cdrelato  => 579
                             ,pr_flg_impri => 'S'
                             ,pr_nmformul  => '234col'
                             ,pr_nrcopias  => 1
                             ,pr_dspathcop => NULL
                             ,pr_dsmailcop => NULL
                             ,pr_dsassmail => NULL
                             ,pr_dscormail => NULL
                             ,pr_des_erro  => vr_dscritic);

  -- Se retornou erro, encerrar
  IF  vr_dscritic IS NOT NULL  THEN
    RAISE vr_exc_saida;
  END IF;

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);

  -- Fechar o arquivo crrl579.csv
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_txt);

  -- Email do destinatario
  vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL579.CSV');

  -- Se achou e-mail, enviar
  IF  vr_email_dest IS NOT NULL  THEN
    -- Converter o arquiovo para envio
    gene0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper
                                ,pr_nmarquiv => vr_nmdiretorio||'/rl/crrl579.csv'
                                ,pr_nmarqenv => 'crrl579.csv'
                                ,pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NULL THEN
      -- Enviar arquivo .csv por email
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => vr_cdprogra
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'Fluxo de compensacao BB/Bancoob/Ailos'
                                ,pr_des_corpo       => NULL
                                ,pr_des_anexo       => vr_nmdiretorio||'/converte/crrl579.csv'
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
    END IF;

  END IF;

  -- Se retornou erro, encerrar
  IF  vr_dscritic IS NOT NULL  THEN
    RAISE vr_exc_saida;
  END IF;

  -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  COMMIT;

EXCEPTION

  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;

  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;

  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;

END PC_CRPS582;
/

