CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps508 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps508 (Fontes/crps508.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Gabriel
       Data    : Abril/2008                     Ultima atualizacao: 28/04/2014

       Dados referentes ao programa:

       Frequencia: Diario
       Objetivo  : Solicitacao 002.
                   Listar as poupancas programadas com vencimento daqui a 5 dias
                   uteis.
                   Relatorio 481.

       Alteracoes: 02/08/2013 - Alterado para pegar o telefone da tabela 
                                craptfc ao invés da crapass (James).
                            
                   09/10/2013 - Incluir TEMP-TABLE tt-erro para Tratamento 
                                para Imunidade Tributaria na poupanca.i (Ze).
                            
                   05/11/2013 - Instanciado h-b1wgen0159 fora da poupanca.i
                                (Lucas R.)                        
                            
                   23/12/2013 - Alterado totalizador de PAs de 99 para 999. 
                                (Reinert)          
                                
                   28/04/2014 - Conversão Progress >> Oracle PLSQL (Tiago Castro - RKAM)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS508';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- variaveis para data do periodo
      vr_dtvenini DATE;
      vr_dtvenfim DATE;

      -- gravar informacoes do tipo e nro telefones
      vr_tptelefo INTEGER;
      vr_nrtelefo VARCHAR2(500);
      
      vr_dextabi  craptab.dstextab%TYPE;      --> Armazenar execução para cálculo de poupança
      vr_vlsdpoup craprpp.vlsdrdpp%type := 0; --> Valor de poupança acumulado

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Buscar dados do cadastro de poupança programada
      CURSOR cr_craprpp IS
        SELECT  craprpp.cdagenci
               ,craprpp.nrdconta
               ,craprpp.nrctrrpp
               ,craprpp.rowid
               ,craprpp.dtvctopp
        FROM    craprpp 
        WHERE   craprpp.cdcooper =  pr_cdcooper   
        AND     craprpp.dtvctopp >  vr_dtvenini   
        AND     craprpp.dtvctopp <= vr_dtvenfim 
        ORDER BY  craprpp.cdagenci,
                  craprpp.nrdconta,
                  craprpp.nrctrrpp;
      
      --Busca informações do PA
      CURSOR cr_crapage(pr_cdagenci IN craprpp.cdagenci%TYPE)  IS
        SELECT  crapage.nmresage
        FROM    crapage 
        WHERE   crapage.cdcooper = pr_cdcooper   
        AND     crapage.cdagenci = pr_cdagenci;
      
      -- Busca informações do Associado
      CURSOR cr_crapass(pr_nrdconta IN craprpp.nrdconta%TYPE) IS
        SELECT  crapass.inpessoa
               ,crapass.nrdconta
               ,crapass.cdagenci
               ,crapass.nmprimtl
        FROM    crapass 
        WHERE   crapass.cdcooper = pr_cdcooper       
        AND     crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Busca nros de telefone do associado
      CURSOR cr_craptfc (pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_tptelefo IN craptfc.tptelefo%TYPE ) IS
        SELECT  craptfc.nrdddtfc
               ,craptfc.nrtelefo
        FROM    craptfc 
        WHERE   craptfc.cdcooper = pr_cdcooper       
        AND     craptfc.nrdconta = pr_nrdconta  
        AND     craptfc.tptelefo = pr_tptelefo;
      rw_craptfc cr_craptfc%ROWTYPE;
      
      -- Busca dados de taxas
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE            --> Código cooperativa
                       ,pr_nmsistem IN craptab.nmsistem%TYPE            --> Nome sistema
                       ,pr_tptabela IN craptab.tptabela%TYPE            --> Tipo tabela
                       ,pr_cdempres IN craptab.cdempres%TYPE            --> código empresa
                       ,pr_cdacesso IN craptab.cdacesso%TYPE            --> Código acesso
                       ,pr_tpregist IN craptab.tpregist%TYPE) IS        --> Tipo de registro
        SELECT substr(cb.dstextab, 49, 15) dstextabs
              ,cb.dstextab
        FROM craptab cb
        WHERE cb.cdcooper = pr_cdcooper
        AND cb.nmsistem = pr_nmsistem
        AND cb.tptabela = pr_tptabela
        AND cb.cdempres = pr_cdempres
        AND cb.cdacesso = pr_cdacesso
        AND cb.tpregist = pr_tpregist;
      rw_craptab cr_craptab%ROWTYPE;
      
      
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- guarda inforcaoes para gerar relatorio
      TYPE typ_reg_relato IS
        RECORD ( cdagenci craprpp.cdagenci%TYPE -- PA
                ,nrdconta craprpp.nrdconta%TYPE -- CONTA/DV
                ,nmprimtl crapass.nmprimtl%TYPE -- TITULAR
                ,nrctrrpp craprpp.nrctrrpp%TYPE -- NR.POUPANCA
                ,dtvctopp craprpp.dtvctopp%TYPE -- DT.VENCTO
                ,vlsdpoup NUMBER                -- VALOR
                ,nrtelefo VARCHAR2(50)          -- FONE/RAMAL
                );
      TYPE typ_tab_relato IS
        TABLE OF typ_reg_relato
          INDEX BY VARCHAR2(25); --> 05 PA + 10 Conta + 10 NR.POUPANCA
      vr_tab_relato typ_tab_relato;      
      vr_des_chave  VARCHAR2(25); --chave da PLtable

      ------------------------------- VARIAVEIS -------------------------------
      
      vr_contador NUMBER := 0;  -- contador para validar data a vencer com 5 dias uteis
      
      -- Variaveis para os XMLs e relatórios
      vr_clobxml     CLOB;                -- Clob para conter o XML de dados
      vr_nom_direto  VARCHAR2(200);       -- Diretório para gravação do arquivo      
      vr_nmresage crapage.nmresage%TYPE;  -- Nome do PA
      vr_nmarqim  VARCHAR2(25);           -- Nome do relatorio
      
      --------------------------- SUBROTINAS INTERNAS --------------------------
      
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;
      
      
      --------------- VALIDACOES INICIAIS -----------------
    
    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      -- Buscar informações para cálculo de poupança
      OPEN cr_craptab(pr_cdcooper, 'CRED', 'CONFIG', 0, 'PERCIRAPLI', 0);
      FETCH cr_craptab INTO rw_craptab;
      CLOSE cr_craptab;
      vr_dextabi := rw_craptab.dstextab;
      
      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      vr_dtvenini := rw_crapdat.dtmvtoan;-- seta data movimento anterior
      vr_dtvenfim := rw_crapdat.dtmvtolt;-- seta data movimento atual
      --calculo do periodo
      WHILE vr_contador < 5 --calcula data inicial + 5 dias uteis
      LOOP
        vr_dtvenini := vr_dtvenini + 1;--soma 1 dia a data inicial
        --verifica se a data calculada é dia util
        vr_dtvenini := gene0005.fn_valida_dia_util( pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => vr_dtvenini);
        vr_contador := vr_contador + 1;--soma mais um ao contador de dias
      END LOOP;
      vr_contador := 0;--zera contador de dias 
      WHILE vr_contador < 5--calcula data final com + 5 dias uteis
      LOOP
        vr_dtvenfim := vr_dtvenfim + 1;--soma 1 dia a data final
        --verifica se a data calculada é um dia util
        vr_dtvenfim := gene0005.fn_valida_dia_util( pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => vr_dtvenfim);
        vr_contador := vr_contador + 1;--soma mais um ao contador de dias
      END LOOP;
      -- Busca cadastro de poupanca programada
      FOR rw_craprpp IN cr_craprpp
      LOOP
        EXIT WHEN cr_craprpp%NOTFOUND;
        vr_nrtelefo := NULL;
        OPEN cr_crapass(rw_craprpp.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN-- verifica se encontrou cadastro do associado
          CLOSE cr_crapass;
          --gera critica
          pr_cdcritic := 9;
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);          
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic||' Conta/dv: '
                                                       || gene0002 .fn_mask_conta(pr_nrdconta => rw_craprpp.nrdconta)
                                                       ||' Nr.Poupanca: '||gene0002.fn_mask(pr_dsorigi => rw_craprpp.nrctrrpp
                                                                                           ,pr_dsforma => 'zzz.zz9'));
          continue;--proximo registro
        END IF;
        CLOSE cr_crapass;
        IF rw_crapass.inpessoa = 1   THEN -- verifica se pessoa é fisica
          vr_tptelefo := 1;-- Tipo telefone residencial
        ELSE
          vr_tptelefo := 3;-- Tipo telefone Comercial
        END IF;
        -- Busca cadastro de telefones do associado
        OPEN cr_craptfc(rw_crapass.nrdconta,vr_tptelefo );
        FETCH cr_craptfc INTO rw_craptfc;
        IF cr_craptfc%FOUND THEN --verifica se existe telefone cadastrado
          vr_nrtelefo := rw_craptfc.nrdddtfc||rw_craptfc.nrtelefo;-- DDD + nro telefone
        END IF;
        CLOSE cr_craptfc;
        -- Busca cadastro de telefones do tipo 2 do associado
        OPEN cr_craptfc(rw_crapass.nrdconta,2 );
        FETCH cr_craptfc INTO rw_craptfc;
        IF cr_craptfc%FOUND THEN--verifica se existe telefone cadastrado
          IF  trim(vr_nrtelefo) IS NOT NULL THEN -- verifica se existe telefone armazenado
            vr_nrtelefo := vr_nrtelefo ||'/';--adiciona barra ao final para adicionar mais telefones
          ELSE 
            vr_nrtelefo := rw_craptfc.nrdddtfc;--seta nro do telefone a variavel
          END IF;
          vr_nrtelefo := vr_nrtelefo ||rw_craptfc.nrtelefo;--adiciona o DDD + telefone
        END IF;
        CLOSE cr_craptfc;        
        IF trim(vr_nrtelefo) IS NULL THEN -- verifica se existe telefone armazenado
          IF rw_crapass.inpessoa = 1   THEN -- verifica se é pessoa fisica
            vr_tptelefo := 3; -- Tipo telefone Comercial
          ELSE
            vr_tptelefo := 1; -- Tipo telefone Residencial
          END IF;
          -- Busca cadastro de telefones do associado
          OPEN cr_craptfc(rw_crapass.nrdconta, vr_tptelefo);
          FETCH cr_craptfc INTO rw_craptfc;
          IF cr_craptfc%FOUND THEN -- verifica se encontrou telefone
            vr_nrtelefo := rw_craptfc.nrdddtfc||rw_craptfc.nrtelefo;--adiciona o DDD + telefone
          ELSE
            vr_nrtelefo := NULL;--seta variavel como nulla
          END IF;
          CLOSE cr_craptfc; 
        END IF;
        --busca calculo do saldo da aplicacao ate a data do movimento
        apli0001.pc_calc_poupanca(pr_cdcooper  => pr_cdcooper
                                 ,pr_dstextab  => vr_dextabi
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_inproces  => rw_crapdat.inproces
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dtmvtopr  => rw_crapdat.dtmvtopr
                                 ,pr_rpp_rowid => rw_craprpp.rowid
                                 ,pr_vlsdrdpp  => vr_vlsdpoup 
                                 ,pr_cdcritic  => vr_cdcritic
                                 ,pr_des_erro  => vr_dscritic
                                 );
        -- Verificar se ocorreram erros no cálculo de poupança
        IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
          --gera critica
          vr_cdcritic := 0;
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' ||
                                                        vr_dscritic || '. ');

          RAISE vr_exc_saida;
        END IF;
        -- popula PLTable
        vr_des_chave := lpad(rw_craprpp.cdagenci,5,'0')||lpad(rw_crapass.nrdconta,10,'0')||lpad(rw_craprpp.nrctrrpp,10,'0');
        vr_tab_relato(vr_des_chave).cdagenci  := rw_craprpp.cdagenci;  -- PA
        vr_tab_relato(vr_des_chave).nrdconta  := rw_crapass.nrdconta;  -- Conta
        vr_tab_relato(vr_des_chave).nmprimtl  := rw_crapass.nmprimtl;  --Titular
        vr_tab_relato(vr_des_chave).nrctrrpp  := rw_craprpp.nrctrrpp;  -- Nr Poupanca
        vr_tab_relato(vr_des_chave).dtvctopp  := rw_craprpp.dtvctopp;  -- Dt. Vencimento
        vr_tab_relato(vr_des_chave).vlsdpoup  := vr_vlsdpoup;          -- Valor
        vr_tab_relato(vr_des_chave).nrtelefo  := vr_nrtelefo;          -- Telefones        
      END LOOP;
      --busca diretorio padrao da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');
      -- Com a tabela do relatorio povoada, iremos varre-la para gerar o xml de base ao relatorio
      vr_des_chave := vr_tab_relato.first;
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');
      WHILE vr_des_chave IS NOT NULL LOOP -- varre a tabela temporaria para montar xml
        --verifica se é o primeiro registro ou alterou o nro do PA
        IF vr_des_chave = vr_tab_relato.first OR vr_tab_relato(vr_des_chave).cdagenci <> vr_tab_relato(vr_tab_relato.PRIOR(vr_des_chave)).cdagenci THEN
          OPEN cr_crapage(vr_tab_relato(vr_des_chave).cdagenci);--busca nome PA
          FETCH cr_crapage INTO vr_nmresage;
          CLOSE cr_crapage;
          IF vr_nmresage IS NULL THEN
            vr_nmresage := '- PA NAO CADASTRADO.';
          END IF; 
          --gera linha com nome do PA         
          pc_escreve_clob(vr_clobxml,'<pac cdagenci="'||lpad(vr_tab_relato(vr_des_chave).cdagenci,3,' ')||'" nmresage="'||vr_nmresage||'">');
          vr_nmarqim := '/crrl481_'||lpad(vr_tab_relato(vr_des_chave).cdagenci,3, '0')||'.lst';
        END IF;
        --monta xml
        pc_escreve_clob(vr_clobxml,'<contas>'
                                 ||'    <pa>'||vr_tab_relato(vr_des_chave).cdagenci||'</pa>'
                                 ||'    <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_relato(vr_des_chave).nrdconta))||'</nrdconta>'
                                 ||'    <titular>'||substr(vr_tab_relato(vr_des_chave).nmprimtl,1,40)||'</titular>'
                                 ||'    <nr_poupanca>'||ltrim(gene0002.fn_mask(vr_tab_relato(vr_des_chave).nrctrrpp, 'zzz.zzz'))||'</nr_poupanca>'
                                 ||'    <vencimento>'||to_char(vr_tab_relato(vr_des_chave).dtvctopp,'dd/mm/yyyy')||'</vencimento>'
                                 ||'    <valor>'||vr_tab_relato(vr_des_chave).vlsdpoup||'</valor>'
                                 ||'    <fone>'||vr_tab_relato(vr_des_chave).nrtelefo||'</fone>'
                                 ||'</contas>') ;
                                 
        --se for ultimo ou mudar PA, fecha tag e gera solicitacao relatorio
        IF vr_des_chave = vr_tab_relato.last OR vr_tab_relato(vr_des_chave).cdagenci <> vr_tab_relato(vr_tab_relato.NEXT(vr_des_chave)).cdagenci THEN
          -- Gerar a tag do PA
          pc_escreve_clob(vr_clobxml,'</pac>');
          -- Encerrar tag raiz
          pc_escreve_clob(vr_clobxml,'</raiz>');

          --Gera Relatorio crrl481.lst
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                     ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/raiz/pac/contas'                   --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl481.jasper'                     --> Arquivo de layout do iReport
                                     ,pr_dsparams  => null                                 --> Sem parâmetros
                                     ,pr_dsarqsaid => vr_nom_direto||vr_nmarqim            --> Arquivo final com o path
                                     ,pr_qtcoluna  => 132                                  --> 132 colunas
                                     ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                     ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                                    --> Número de cópias
                                     ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                     ,pr_des_erro  => vr_dscritic);                       --> Saída com erro

          IF vr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_saida;
          END IF;
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_clobxml);
          dbms_lob.freetemporary(vr_clobxml);
          -- Iniciar clob/XML para proximo PA
          dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
          pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');
        END IF;
        -- Buscar o proximo
        vr_des_chave := vr_tab_relato.NEXT(vr_des_chave);
      END LOOP;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
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
    END;

  END pc_crps508;
/

