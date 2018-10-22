CREATE OR REPLACE PROCEDURE CECRED.pc_crps277(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Coop conectada
                                             ,pr_flgresta IN PLS_INTEGER            --> Indicador para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  /* ............................................................................
   Programa: PC_CRPS277 (Antigo Fontes/crps277.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair 
   Data    : Outubro/1999                    Ultima atualizacao: 06/08/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 005.
               Ordem 28.
               Debitar em conta corrente as faturas de VISA.
               Processa mas nao gera lcm dos craplau referente ao cartao BB.

   Alteracoes: 28/02/2005 - Concatenar codigo do historico com numero de seq.
                            do registro para controle de restart (Julio).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapdcd (Diego).
                                
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.       
               
               04/06/2008 - Campo dsorigem nas leituras da craplau (David)

               14/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - paulo
                            
               02/06/2011 - incluido no for each a condição - 
                            craplau.dsorigem <> "TAA" (Evandro).
                            
               03/10/2011 - Tratamento para evitar o duplicates no create
                            da tabela craplcm (Ze).
                            
               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. Adicionado tratamento para cartoes BB.
                            (Fabricio)
                            
               29/10/2012 - Desprezar os registros de lançamentos automaticos
                            se conta antiga for transferida 
                            (faturas Cecred Visa).(Irlan)
               
               04/01/2013 - Incluido condicao (craptco.tpctatrf <> 3) na busca
                            da craptco (Tiago).         
                            
               03/06/2013 - Incluido no FOR EACH craplau a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)
               
               20/01/2014 - Incluir VALIDATE crapdcd, craplot, craplcm (Lucas R) 
               
               31/03/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
  
               17/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel)
               
               03/06/2015 - Ajustes emergenciais devido conversão progress (Odirlei-AMcom)
               
               28/09/2015 - incluido nas consultas da craplau
                            craplau.dsorigem <> "CAIXA" (Lombardi).

               20/05/2016 - Incluido nas consultas da craplau
                            craplau.dsorigem <> "TRMULTAJUROS". (Jaison/James)

               02/03/2017 - Incluido nas consultas da craplau 
                            craplau.dsorigem <> "ADIOFJUROS" (Lucas Ranghetti M338.1)

              06/08/2018 - PJ450 - TRatamento do nao pode debitar, crítica de negócio, 
                           após chamada da rotina de geraçao de lançamento em CONTA CORRENTE.
                           Alteração específica neste programa acrescentando o tratamento para a origem
                           BLQPREJU
                           (Renato Cordeiro - AMcom)
  ............................................................................. */
  
  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Cursor genérico de calendário
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  
   -- Cursor Lote
  CURSOR cr_crablot(pr_cdcooper IN craplot.cdcooper%TYPE,
                    pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                    pr_dtmvtopr IN craplot.dtmvtopg%TYPE,
                    pr_nrctares IN crapres.nrdconta%TYPE) IS
   SELECT lot.cdcooper
         ,lot.cdagenci
         ,lot.cdbccxlt
         ,lot.nrdolote
         ,lot.dtmvtolt
     FROM craplot lot                 
    WHERE lot.cdcooper  = pr_cdcooper  
      AND lot.dtmvtopg >  pr_dtmvtolt
      AND lot.dtmvtopg <= pr_dtmvtopr
      AND lot.tplotmov  = 17           
      AND lot.nrdolote > 6869          
      AND lot.nrdolote >= pr_nrctares
      ORDER BY lot.cdhistor;  
    
   -- Buscar lançamentos /* USE-INDEX craplcm1 */ 
   CURSOR cr_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE,
                     pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                     pr_cdagenci IN craplcm.cdagenci%TYPE,
                     pr_cdbccxlt IN craplcm.cdbccxlt%TYPE,
                     pr_nrdolote IN craplcm.nrdolote%TYPE,
                     pr_nrdctabb IN craplcm.nrdctabb%TYPE,
                     pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
   SELECT /*+ INDEX (lcm craplcm##craplcm1) */
          lcm.cdcooper
     FROM craplcm lcm                 
    WHERE lcm.cdcooper = pr_cdcooper  
      AND lcm.dtmvtolt = pr_dtmvtolt
      AND lcm.cdagenci = pr_cdagenci
      AND lcm.cdbccxlt = pr_cdbccxlt           
      AND lcm.nrdolote = pr_nrdolote         
      AND lcm.nrdctabb = pr_nrdctabb
      AND lcm.nrdocmto = pr_nrdocmto;
  rw_craplcm cr_craplcm%ROWTYPE; 
  
   -- buscar lançamentos automaticos   
   CURSOR cr_craplau(pr_cdcooper IN craplau.cdcooper%TYPE,
                     pr_dtmvtolt IN craplau.dtmvtolt%TYPE,
                     pr_cdagenci IN craplau.cdagenci%TYPE,
                     pr_cdbccxlt IN craplau.cdbccxlt%TYPE,
                     pr_nrdolote IN craplau.nrdolote%TYPE,
                     pr_dsrestar IN crapres.dsrestar%TYPE) IS
     SELECT lau.cdcooper
           ,lau.nrseqlan
           ,lau.cdhistor
           ,lau.vllanaut
           ,lau.nrdolote
           ,lau.nrdconta
           ,lau.nrdocmto
           ,lau.nrcrcard
           ,lau.rowid
       FROM craplau lau
      WHERE lau.cdcooper = pr_cdcooper
        AND lau.dtmvtolt = pr_dtmvtolt      
        AND lau.cdagenci = pr_cdagenci      
        AND lau.cdbccxlt = pr_cdbccxlt      
        AND lau.nrdolote = pr_nrdolote      
        AND lau.nrseqlan > to_number(NVL(pr_dsrestar, '0'))
        AND lau.dsorigem NOT IN ('CAIXA'
                                ,'INTERNET'
                                ,'TAA'
                                ,'PG555'
                                ,'CARTAOBB'
                                ,'BLOQJUD'
                                ,'DAUT BANCOOB'
                                ,'TRMULTAJUROS'
                                ,'BLQPREJU'
                                ,'ADIOFJUROS')
        ORDER BY lau.cdhistor;
  
  -- Cursor Lote
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE,
                    pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                    pr_cdagenci IN craplot.cdagenci%TYPE,
                    pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                    pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT lot.cdcooper
          ,lot.dtmvtolt
          ,lot.cdagenci
          ,lot.cdbccxlt
          ,lot.nrdolote
          ,lot.tplotmov
          ,lot.nrseqdig
          ,lot.rowid
          ,lot.qtcompln
          ,lot.qtinfoln
          ,lot.vlcompdb
          ,lot.vlinfodb
     FROM craplot lot
    WHERE lot.cdcooper = pr_cdcooper
      AND lot.dtmvtolt = pr_dtmvtolt
      AND lot.cdagenci = pr_cdagenci
      AND lot.cdbccxlt = pr_cdbccxlt
      AND lot.nrdolote = pr_nrdolote; 
  rw_craplot cr_craplot%ROWTYPE;
  
  -- Cursor para Verificar se Conta Migrada
  CURSOR cr_craptco(pr_cdcooper IN craptco.cdcooper%TYPE,
                    pr_nrdconta IN craptco.nrctaant%TYPE) IS
    SELECT tco.nrdconta
          ,tco.cdcooper
     FROM craptco tco
    WHERE tco.cdcopant = pr_cdcooper
      AND tco.nrctaant = pr_nrdconta            
      AND tco.flgativo = 1 -- TRUE
      AND tco.tpctatrf <> 3;
  rw_craptco cr_craptco%ROWTYPE; 

  -- Buscar Cadastro de debitos do cartao de credito
  CURSOR cr_crapdcd(pr_cdcooper IN crapdcd.cdcooper%TYPE,
                    pr_nrdconta IN crapdcd.nrdconta%TYPE,
                    pr_nrcrcard IN crapdcd.nrcrcard%TYPE,
                    pr_dtdebito IN crapdcd.dtdebito%TYPE) IS
                    
    SELECT dcd.ROWID
          ,dcd.vldebito 
     FROM crapdcd dcd
    WHERE dcd.cdcooper = pr_cdcooper 
      AND dcd.nrdconta = pr_nrdconta           
      AND dcd.nrcrcard = pr_nrcrcard
      AND dcd.dtdebito = pr_dtdebito;
  rw_crapdcd cr_crapdcd%ROWTYPE;    
      
  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS277';

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  
  vr_nrdocmto NUMBER := 0;
  
  -- Variaveis de Controle de Restart
  vr_nrctares  INTEGER:= 0;
  vr_inrestar  INTEGER:= 0;
  vr_dsrestar  crapres.dsrestar%TYPE;
  
  vr_busca BOOLEAN := TRUE;
BEGIN

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                            ,pr_action => NULL);
                              
  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop;
  FETCH cr_crapcop INTO rw_crapcop;
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
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  -- Se não encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE BTCH0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic:= 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
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
  
  -- Tratamento e retorno de valores de restart
  BTCH0001.pc_valida_restart(pr_cdcooper => pr_cdcooper
                            ,pr_cdprogra => vr_cdprogra
                            ,pr_flgresta => pr_flgresta
                            ,pr_nrctares => vr_nrctares
                            ,pr_dsrestar => vr_dsrestar
                            ,pr_inrestar => vr_inrestar
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_des_erro => vr_dscritic);
  --Se ocrreu erro na validacao do restart
  IF vr_dscritic IS NOT NULL THEN
   --Levantar Excecao
   RAISE vr_exc_saida;
  END IF;
  
  IF vr_inrestar = 0 THEN
    vr_nrctares := 0;
  END IF;
  
  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

  -- Leitura Lançamentos
  FOR rw_crablot IN cr_crablot(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt,
                               pr_dtmvtopr => rw_crapdat.dtmvtopr,
                               pr_nrctares => vr_nrctares) LOOP 
                               
    -- Leitura dos lançamentos automaticos                           
    FOR rw_craplau IN cr_craplau(pr_cdcooper => rw_crablot.cdcooper,
                                 pr_dtmvtolt => rw_crablot.dtmvtolt,
                                 pr_cdagenci => rw_crablot.cdagenci,
                                 pr_cdbccxlt => rw_crablot.cdbccxlt,
                                 pr_nrdolote => rw_crablot.nrdolote,
                                 pr_dsrestar => vr_dsrestar) LOOP  
                             
      -- Desprezar a fatura do dia 01/01/2013 
      -- Lancamento automatico existirá na  Viacredi,
      -- porém débito será na Altovale (craplau tb foi crida na Altovale)                                         
      IF rw_craplau.cdhistor = 293 THEN 
        
        -- Verifica se Conta Migrada
        OPEN cr_craptco(pr_cdcooper => rw_craplau.cdcooper,
                        pr_nrdconta => rw_craplau.nrdconta);
        FETCH cr_craptco INTO rw_craptco; 

        -- Caso seja Conta Migrada
        IF cr_craptco%FOUND THEN
          CLOSE cr_craptco;
          -- Proximo Registro
          CONTINUE;
        END IF;  
        CLOSE cr_craptco;

      END IF;

      IF vr_inrestar > 0 THEN
        vr_dsrestar := '0';                                               
      END IF;  
      
      -- Verifica Existencia de Lote
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => rw_crapdat.dtmvtopr
                     ,pr_cdagenci => 1
                     ,pr_cdbccxlt => 100
                     ,pr_nrdolote => 8459);
      FETCH cr_craplot INTO rw_craplot;
      
      IF cr_craplot%NOTFOUND THEN
          
        -- Fechar Cursor
        CLOSE cr_craplot; 
      
        BEGIN
          --Inserir a capa do lote retornando informacoes para uso posterior
          INSERT INTO craplot(cdcooper
                             ,dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,tplotmov
                             ,nrseqdig
                             ,cdoperad)
                     VALUES  (pr_cdcooper
                             ,rw_crapdat.dtmvtopr
                             ,1
                             ,100
                             ,8459
                             ,1
                             ,0
                             ,1)
                     RETURNING cdcooper
                              ,dtmvtolt
                              ,cdagenci
                              ,cdbccxlt
                              ,nrdolote
                              ,tplotmov
                              ,nrseqdig
                              ,ROWID
                     INTO  rw_craplot.cdcooper
                          ,rw_craplot.dtmvtolt
                          ,rw_craplot.cdagenci
                          ,rw_craplot.cdbccxlt
                          ,rw_craplot.nrdolote
                          ,rw_craplot.tplotmov
                          ,rw_craplot.nrseqdig
                          ,rw_craplot.rowid;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na tabela craplot. '|| SQLERRM;
            --Sair do programa
            RAISE vr_exc_saida;
        END;  
      
      ELSE
        -- Apenas Fechar Cursor
        CLOSE cr_craplot; 
      END IF; 
      
      vr_nrdocmto := to_number(to_char(rw_craplau.cdhistor) || to_char(rw_craplau.nrdocmto));
      
      vr_busca := TRUE;

      WHILE vr_busca LOOP
        -- Busca o Numero do Docuemnto a Ser usado para criar Registro na craplcm
        OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => rw_craplot.dtmvtolt
                        ,pr_cdagenci => rw_craplot.cdagenci
                        ,pr_cdbccxlt => rw_craplot.cdbccxlt
                        ,pr_nrdolote => rw_craplot.nrdolote
                        ,pr_nrdctabb => rw_craplau.nrdconta
                        ,pr_nrdocmto => vr_nrdocmto);
                        
        FETCH cr_craplcm INTO rw_craplcm;
        IF cr_craplcm%NOTFOUND THEN
          -- Fecha Cursor  
          CLOSE cr_craplcm;  
        
          EXIT;
        END IF;
        
        vr_nrdocmto := (vr_nrdocmto + 1000000);
        
        -- Fecha Cursor
        CLOSE cr_craplcm;
        
      END LOOP;

      -- Cria Registro na CRAPLCM
      BEGIN
        INSERT INTO craplcm(cdcooper
                           ,dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,nrdconta
                           ,nrdctabb
                           ,nrdctitg
                           ,nrdocmto
                           ,cdhistor
                           ,nrseqdig
                           ,vllanmto)
                   VALUES  (pr_cdcooper
                           ,rw_craplot.dtmvtolt
                           ,rw_craplot.cdagenci
                           ,rw_craplot.cdbccxlt
                           ,rw_craplot.nrdolote
                           ,rw_craplau.nrdconta
                           ,rw_craplau.nrdconta
                           ,GENE0002.FN_MASK(rw_craplau.nrdconta, '99999999')
                           ,vr_nrdocmto
                           ,rw_craplau.cdhistor
                           ,rw_craplot.nrseqdig + 1
                           ,rw_craplau.vllanaut);

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela craplcm. ' || SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;
        
      --Atualizar capa do Lote
      BEGIN
        UPDATE craplot SET craplot.vlinfodb = NVL(rw_craplot.vlinfodb,0) + rw_craplau.vllanaut
                          ,craplot.vlcompdb = NVL(rw_craplot.vlcompdb,0) + rw_craplau.vllanaut
                          ,craplot.qtinfoln = NVL(rw_craplot.qtinfoln,0) + 1
                          ,craplot.qtcompln = NVL(rw_craplot.qtcompln,0) + 1
                          ,craplot.nrseqdig = NVL(rw_craplot.nrseqdig,0) + 1
        WHERE craplot.ROWID = rw_craplot.ROWID;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela craplot. ' || SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;
          
      --Atualizar craplau com a data do debito
      BEGIN
        UPDATE craplau SET craplau.dtdebito = rw_crapdat.dtmvtopr
         WHERE craplau.ROWID = rw_craplau.ROWID;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela craplau. ' || SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;
      
      OPEN cr_crapdcd(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => rw_craplau.nrdconta 
                     ,pr_nrcrcard => rw_craplau.nrcrcard
                     ,pr_dtdebito => rw_crapdat.dtmvtopr );
      FETCH cr_crapdcd INTO rw_crapdcd;               
                     
                        
      IF cr_crapdcd%NOTFOUND THEN
        -- Fecha Cursor  
        CLOSE cr_crapdcd; 
        
        BEGIN
          --Inserir a capa do lote retornando informacoes para uso posterior
          INSERT INTO crapdcd(dtdebito
                             ,nrdconta
                             ,nrcrcard
                             ,cdcooper
                             ,vldebito)
                     VALUES  (rw_crapdat.dtmvtopr
                             ,rw_craplau.nrdconta
                             ,rw_craplau.nrcrcard
                             ,pr_cdcooper
                             ,rw_crapdcd.vldebito + rw_craplau.vllanaut);
                     

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na tabela crapdcd. '|| SQLERRM;
            --Sair do programa
            RAISE vr_exc_saida;
        END; 
        
      ELSE
        -- Fecha Cursor  
        CLOSE cr_crapdcd; 
        
        --Atualizar capa do Lote
        BEGIN
          UPDATE crapdcd SET crapdcd.vldebito = ( rw_crapdcd.vldebito + rw_craplau.vllanaut )
           WHERE crapdcd.ROWID = rw_crapdcd.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela crapdcd. ' || SQLERRM;
            --Sair do programa
            RAISE vr_exc_saida;
        END;
      END IF;
      
      -- Atualizar controle de restart  
      BEGIN
        UPDATE crapres 
           SET crapres.nrdconta = rw_craplau.nrdolote
              ,crapres.dsrestar = to_char(rw_craplau.cdhistor) || to_char(rw_craplau.nrseqlan)
         WHERE crapres.cdcooper = pr_cdcooper
           AND upper(crapres.cdprogra) = vr_cdprogra;

        --Se nao atualizou nada
        IF SQL%ROWCOUNT = 0 THEN
           --Buscar mensagem de erro da critica
           vr_cdcritic := 151;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           --Sair do programa
           RAISE vr_exc_saida;
         END IF;

       EXCEPTION
         WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar tabela crapres. '||SQLERRM;
         --Sair do programa
         RAISE vr_exc_saida;
       END;
         
       -- Salvar Registro Processado
       COMMIT;
    
    END LOOP;                          
  END LOOP;   
  
  -- atualizar como processado o lautom
  BEGIN
    UPDATE craplau
       SET craplau.insitlau = 2, 
           craplau.dtdebito = rw_crapdat.dtmvtolt
     WHERE craplau.cdcooper = pr_cdcooper
       AND craplau.dtmvtopg > rw_crapdat.dtmvtoan
       AND craplau.dtmvtopg <= rw_crapdat.dtmvtolt
       AND craplau.dtdebito IS NULL
       AND craplau.dsorigem = 'CARTAOBB';
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Não foi possivel alterar craplau CARTAOBB:'|| SQLERRM;
      RAISE vr_exc_saida;
  END;
                                                    

  -- Processo OK, devemos chamar a fimprg
  BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informacoes no banco de dados
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN

    -- Se retornou apenas o codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Busca Descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Se foi gerado critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

      -- Envio Centralizado de Log de Erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- ERRO TRATATO
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                    ' -' || vr_cdprogra || ' --> ' ||
                                                    vr_dscritic);

    END IF;

    -- Chamos o pc_valida_fimprg para encerrar o processo sem parar a cadeia
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salva informações no banco de dados
    COMMIT;
      
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END pc_crps277;
/
