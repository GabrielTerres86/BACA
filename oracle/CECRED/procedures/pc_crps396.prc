CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps396 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps396 (Fontes/crps396.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Evandro
       Data    : Junho/2004                     Ultima atualizacao: 31/03/2014

       Dados referentes ao programa:

       Frequencia: Mensal.
       Objetivo  : Atende a solicitacao 4.
                   Emitir relatorios de Saque de Capital (356) e Saque de
                   Capital Demitidos (357).

       Alteracoes: 06/09/2005 - Alterado titulo, e acrescentado campo p/ motivo
                                demissao - relatorio 357 (Diego).
                            
                   06/09/2005 - Alterado titulo, e acrescentados campos p/         
                                assinatura - relatorio 356 (Diego).

                   17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
                   18/05/2006 - Alterado para ordenar relatorios por PAC, e 
                                incluidos campos codigo e nome do operador (Diego).
                            
                   25/01/2007 - Alterado formato das variaveis do tipo DATE de
                                "99/99/99" para "99/99/9999" (Elton).
                            
                   06/02/2008 - Incluido quantidade de saques no final do relatorio
                                (Elton).              
                            
                   11/03/2011 - Acerto no calculo aux_dtdemiss (Magui).
  
                   16/06/2011 - Acerto qtdade demitidos(rel.356) (Mirtes)
               
                   30/08/2011 - Retirado condicao crapass.dtdemiss >= aux_dtdemiss.
                                Utilizado, somente se demitidos (Adriano).
                            
                   03/01/2012 - Incluso o no-lock na leitura das 
                                tabelas 'craplcm' e 'crapass' (Lucas).
                            
                   30/07/2013 - Incluido valor total e quantidade de demitidos ou 
                                ativos por PA nos relatórios 356 e 357. (Reinert)
                                
                   31/03/2014 - Conversão Progress >> Oracle PLSQL (Tiago Castro - RKAM)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS396';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_dtiniper   DATE;

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
      
      CURSOR cr_craplcm IS --lancamentos em deposito a vista
        SELECT   vllanmto
                ,nrdconta
                ,cdoperad
                ,dtmvtolt
        FROM    craplcm 
        WHERE   craplcm.cdcooper  = pr_cdcooper   
        AND     craplcm.cdhistor  = 354 
        AND     craplcm.dtmvtolt >= vr_dtiniper   
        AND     craplcm.dtmvtolt <= rw_crapdat.dtmvtolt
        ORDER   BY craplcm.cdagenci,
                   craplcm.dtmvtolt,
                   craplcm.nrdconta,
                   craplcm.vllanmto;

      CURSOR cr_crapass(pr_nrdconta IN craplcm.nrdconta%TYPE) IS --cadastro de associados
        SELECT   nrdconta
                ,dtdemiss
                ,cdagenci
                ,nmprimtl
                ,cdmotdem
        FROM    crapass 
        WHERE   crapass.cdcooper = pr_cdcooper   
        AND     crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      CURSOR cr_crapope(pr_cdoperad IN craplcm.cdoperad%TYPE)  IS --cadastro de operadores
        SELECT   cdoperad
                ,nmoperad
        FROM    crapope 
        WHERE   crapope.cdcooper = pr_cdcooper     
        AND     crapope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;
      
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      TYPE typ_reg_capital IS --crrl356
        RECORD ( cdagenci crapass.cdagenci%TYPE
                ,dtmvtolt craplcm.dtmvtolt%TYPE
                ,nrdconta crapass.nrdconta%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE
                ,vllanmto craplcm.vllanmto%TYPE
                ,operador VARCHAR2(50));
      TYPE typ_tab_capital IS
        TABLE OF typ_reg_capital
          INDEX BY VARCHAR2(50); --> 05 PA + 20 Dt Vigencia + 10 Conta + 10 valor + 5 seq
      vr_tab_capital typ_tab_capital;
      vr_des_chave  VARCHAR2(50);
      
      TYPE typ_reg_demitidos IS --crrl357
        RECORD ( cdagenci crapass.cdagenci%TYPE
                ,dtmvtolt craplcm.dtmvtolt%TYPE
                ,nrdconta crapass.nrdconta%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE
                ,cdmotdem NUMBER
                ,dtdemiss crapass.dtdemiss%TYPE
                ,vllanmto craplcm.vllanmto%TYPE
                ,dsmotdem VARCHAR2(50)
                ,operador VARCHAR2(50));
      TYPE typ_tab_demitidos IS
        TABLE OF typ_reg_demitidos
          INDEX BY VARCHAR2(50); --> 05 PA + 20 Dt Vigencia + 10 Conta + 10 valor + 5 seq
      vr_tab_demitidos typ_tab_demitidos;
      vr_des_chave1  VARCHAR2(50);
      ------------------------------- VARIAVEIS -------------------------------

      vr_operador VARCHAR2(50);
      vr_dsmotdem VARCHAR2(1000);
      vr_cdmotdem NUMBER;
      -- Variaveis para os XMLs e relatórios
      vr_clobxml     CLOB;   -- Clob para conter o XML de dados
      vr_nom_direto  VARCHAR2(200); -- Diretório para gravação do arquivo
      vr_nmarqim    VARCHAR2(25);  
      vr_gerar      BOOLEAN := FALSE;
      vr_cont       NUMBER := 1;
      
      
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
      -- Chama a rotina sem passar o motivo de demissão para carregar o registro de memória
      CADA0001.pc_busca_motivo_demissao(pr_cdcooper => pr_cdcooper
                                       ,pr_cdmotdem => NULL
                                       ,pr_dsmotdem => vr_dsmotdem
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_des_erro => vr_dscritic);
      vr_dscritic := NULL;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      --monta a data inicial como o 1 dia do mes referencia
      vr_dtiniper := to_date(lpad(to_char(rw_crapdat.dtmvtolt,'mm'),2,'0')||
                     '01'||to_char(rw_crapdat.dtmvtolt,'yyyy'), 'mmddyyyy');
      FOR rw_craplcm IN cr_craplcm -- busca lancamentos de deposito a vista
      LOOP
        EXIT WHEN cr_craplcm%NOTFOUND;
        OPEN cr_crapass(rw_craplcm.nrdconta);--busca conta do associado
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;
        OPEN cr_crapope(rw_craplcm.cdoperad); --busca cadastro de operadores
        FETCH cr_crapope INTO rw_crapope;
        IF cr_crapope%FOUND THEN -- monta nome operador se cd_operador foi encontrado
          vr_operador := rw_crapope.cdoperad||'-'||rw_crapope.nmoperad;
        END IF;
        CLOSE cr_crapope;
        
        /* usado para pegar os ativos */
        IF trim(rw_crapass.dtdemiss) IS NULL THEN          
          --monta temp table ativos
          vr_des_chave := lpad(rw_crapass.cdagenci,5,'0')||to_char(rw_craplcm.dtmvtolt,'yyyymmdd')||lpad(rw_crapass.nrdconta,10,'0')||lpad(to_char(rw_craplcm.vllanmto,'fm999,990.90'),10,'0')||lpad(vr_cont,5, '0');
          vr_tab_capital(vr_des_chave).cdagenci := rw_crapass.cdagenci;-- PA
          vr_tab_capital(vr_des_chave).dtmvtolt := rw_craplcm.dtmvtolt;--data
          vr_tab_capital(vr_des_chave).nrdconta := rw_crapass.nrdconta;-- Conta
          vr_tab_capital(vr_des_chave).nmprimtl := rw_crapass.nmprimtl;-- Nome Associado
          vr_tab_capital(vr_des_chave).vllanmto := rw_craplcm.vllanmto; --valor
          vr_tab_capital(vr_des_chave).operador := vr_operador; --operador
        ELSE -- demitidos
          --busca motivo demissao          
          cada0001.pc_busca_motivo_demissao(pr_cdcooper => pr_cdcooper
                                           ,pr_cdmotdem => rw_crapass.cdmotdem
                                           ,pr_dsmotdem => vr_dsmotdem
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_des_erro => vr_dscritic
                                           );         
          --monta temp table demitidos 
          vr_des_chave1 := lpad(rw_crapass.cdagenci,5,'0')||to_char(rw_craplcm.dtmvtolt,'yyyymmdd')||lpad(rw_crapass.nrdconta,10,'0')||lpad(rw_craplcm.vllanmto,10,'0')||lpad(vr_cont,5, '0');          
          vr_tab_demitidos(vr_des_chave1).cdagenci := rw_crapass.cdagenci;-- PA
          vr_tab_demitidos(vr_des_chave1).dtmvtolt := rw_craplcm.dtmvtolt;--data
          vr_tab_demitidos(vr_des_chave1).nrdconta := rw_crapass.nrdconta;-- Conta
          vr_tab_demitidos(vr_des_chave1).nmprimtl := rw_crapass.nmprimtl;-- Nome Associado
          vr_tab_demitidos(vr_des_chave1).dtdemiss := rw_crapass.dtdemiss; -- data demissao
          vr_tab_demitidos(vr_des_chave1).vllanmto := rw_craplcm.vllanmto; --valor
          vr_tab_demitidos(vr_des_chave1).cdmotdem:= rw_crapass.cdmotdem;
          vr_tab_demitidos(vr_des_chave1).dsmotdem := lpad(rw_crapass.cdmotdem,2,'0')||' - '||vr_dsmotdem; -- motivo demissao
          vr_tab_demitidos(vr_des_chave1).operador := vr_operador; --operador
        END IF;
        --sequence temp table
        vr_cont := vr_cont + 1;
      END LOOP;
      -- Com a tabela do relatorio povoada, iremos varre-la para gerar o xml de base ao relatorio
      --gera crrl356
      vr_des_chave := vr_tab_capital.first;
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');
      WHILE vr_des_chave IS NOT NULL LOOP -- varre a tabela temporaria para montar xml
        --monta xml
        pc_escreve_clob(vr_clobxml,'<pas>'
                                 ||'  <pa>'     ||vr_tab_capital(vr_des_chave).cdagenci||'</pa>'
                                 ||'  <data>'   ||to_char(vr_tab_capital(vr_des_chave).dtmvtolt,'dd/mm/yyyy')||'</data>'
                                 ||'  <conta>'  ||LTRIM(gene0002.fn_mask_conta(vr_tab_capital(vr_des_chave).nrdconta))||'</conta>'
                                 ||'  <titular>'||substr(vr_tab_capital(vr_des_chave).nmprimtl,1,40)||'</titular>'
                                 ||'  <valor>'  ||vr_tab_capital(vr_des_chave).vllanmto||'</valor>'
                                 ||'  <operador>'||substr(vr_tab_capital(vr_des_chave).operador,1,35)||'</operador>'
                                 ||'</pas>') ;
        IF vr_des_chave = vr_tab_capital.last THEN
          pc_escreve_clob(vr_clobxml,'</raiz>');
        END IF;
        -- Buscar o proximo
        vr_des_chave := vr_tab_capital.NEXT(vr_des_chave);
        vr_gerar := TRUE;        
      END LOOP;
      IF vr_gerar = FALSE THEN
        pc_escreve_clob(vr_clobxml,'</raiz>');
      END IF;
      vr_nmarqim := '/crrl356.lst';
      --busca diretorio padrao da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');
      --gera relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                              --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/pas'                          --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl356.jasper'                     --> Arquivo de layout do iReport
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
      
      --gera crrl357
      -- Com a tabela do relatorio povoada, iremos varre-la para gerar o xml de base ao relatorio
      vr_des_chave1 := vr_tab_demitidos.first;
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');
      vr_gerar := FALSE;
      WHILE vr_des_chave1 IS NOT NULL LOOP -- varre a tabela temporaria para montar xml
        --monta xml
        pc_escreve_clob(vr_clobxml,'<pas>'
                                 ||'  <pa>'      ||vr_tab_demitidos(vr_des_chave1).cdagenci||'</pa>'
                                 ||'  <data>'    ||to_char(vr_tab_demitidos(vr_des_chave1).dtmvtolt,'dd/mm/yyyy')||'</data>'
                                 ||'  <conta>'   ||LTRIM(gene0002.fn_mask_conta(vr_tab_demitidos(vr_des_chave1).nrdconta))||'</conta>'
                                 ||'  <titular>' ||substr(vr_tab_demitidos(vr_des_chave1).nmprimtl,1,28)||'</titular>'
                                 ||'  <dtdemiss>'||to_char(vr_tab_demitidos(vr_des_chave1).dtdemiss,'dd/mm/yyyy')||'</dtdemiss>'
                                 ||'  <valor>'   ||vr_tab_demitidos(vr_des_chave1).vllanmto||'</valor>'
                                 ||'  <dsmotdem>'||vr_tab_demitidos(vr_des_chave1).dsmotdem||'</dsmotdem>'
                                 ||'  <operador>'||substr(vr_tab_demitidos(vr_des_chave1).operador,1,21)||'</operador>'
                                 ||'</pas>') ;
        IF vr_des_chave1 = vr_tab_demitidos.last THEN
          pc_escreve_clob(vr_clobxml,'</raiz>');
        END IF;
        -- Buscar o proximo
        vr_des_chave1 := vr_tab_demitidos.NEXT(vr_des_chave1);        
        vr_gerar := TRUE;
      END LOOP;
      IF vr_gerar = FALSE THEN
        pc_escreve_clob(vr_clobxml,'</raiz>');
      END IF;
      vr_nmarqim := '/crrl357.lst';
     
      --gera relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                              --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/pas'                          --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl357.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||vr_nmarqim            --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 2                                    --> Qual a seq do cabrel
                                 ,pr_des_erro  => vr_dscritic);                       --> Saída com erro

      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);

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

  END pc_crps396;
/

