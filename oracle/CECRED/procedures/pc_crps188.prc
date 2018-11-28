CREATE OR REPLACE PROCEDURE CECRED.pc_crps188(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Coop conectada
                                             ,pr_flgresta IN PLS_INTEGER            --> Indicador para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  /* ............................................................................
   Programa: PC_CRPS188 (Antigo Fontes/crps188.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/97.                       Ultima atualizacao: 16/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de cobranca de anuidade CrediCard.

   Alteracoes: 27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               08/12/97 - Alterar para ler a tabela de valores de anuidade com
                          data da proposta <= data da tabela (Odair).

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               11/08/98 - Acerto na rotina de cobranca da primeira anuidade 
                          (Acerto na ordem de acesso da tabela e na baixa da
                           parcela paga). (Deborah)

               29/09/98 - Acerto no historico do debito da anuidade (Deborah).
               
               22/03/2005 - Alteracao na indentificacao do lancamento
                            nrdocmto = 8 ultimos digitos do numero do cartao
                            (Julio).                            

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapavs (Diego).
                            
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder        
                    
               30/05/2007 - Desprezar cartoes BB(Mirtes)
               
               23/09/2011 - Adicionado controle de cobranca de anuidade
                            (Evandro).
                            
               16/01/2014 - Inclusao de VALIDATE craplot, craplcm e crapavs 
                            (Carlos)
  
               16/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel)
  
               30/05/2015 - Alterado a conversão da data lida da tabela CRAPTAB,
                            pois a tabela tem a data em formato DD/MM/AAAA e o programa
                            estava lendo como MM/DD/AAAA.  (Renato - Supero)

               29/05/2018 - Alteração INSERT na craplcm pela chamada da rotina LANC0001
                            PRJ450 - Renato Cordeiro (AMcom)         
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
  
  -- Buscar informações da tabela generica   
  CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE
                    ,pr_cdacesso IN craptab.cdacesso%TYPE) IS
    -- Verifica se deve executar
    SELECT tab.dstextab
          ,ROWID
      FROM craptab tab
     WHERE tab.cdcooper        = pr_cdcooper
       AND upper(tab.nmsistem) = 'CRED'
       AND upper(tab.tptabela) = 'USUARI'
       AND tab.cdempres        = 11
       AND upper(tab.cdacesso) = pr_cdacesso;
  rw_craptab cr_craptab%ROWTYPE; 
  
  -- Buscar informações da proposta do cartão de credito
  CURSOR cr_crawcrd (pr_cdcooper IN crawcrd.cdcooper%TYPE
                    ,pr_dtmvtolt IN crawcrd.dtmvtolt%TYPE ) IS
    SELECT crd.nrdconta
          ,crd.qtparcan
          ,crd.qtanuida
          ,crd.cdcooper
          ,crd.vlanuida
          ,crd.cdadmcrd
          ,crd.nrcrcard
          ,crd.dtanuida
          ,crd.ROWID
          ,crd.inanuida  
          ,crd.dtentreg        
      FROM crawcrd crd
     WHERE crd.cdcooper  = pr_cdcooper
       AND crd.dtanuida <= pr_dtmvtolt
       AND crd.inanuida  = 0                
       AND crd.insitcrd  = 4              
       AND crd.cdadmcrd NOT IN (83,84,85,86,87,88 );  
       -- 83	Banco do Brasil Administradora de Cartões
       -- 85	Banco do Brasil Administradora de Cartões
       -- 87	Banco do Brasil Administradora de Cartões
       -- 84,86,88 Não encontrei na CRAPADC

  -- Buscar dados da administradora do cartão
  CURSOR cr_crapadc (pr_cdcooper IN crapadc.cdcooper%TYPE
                    ,pr_cdadmcrd IN crapadc.cdadmcrd%TYPE ) IS
    SELECT adc.inanuida
      FROM crapadc adc
     WHERE adc.cdcooper = pr_cdcooper
       AND adc.cdadmcrd = pr_cdadmcrd;
  rw_crapadc cr_crapadc%ROWTYPE;  
  
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
  
  -- Cursor Leitura Associado
  CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.inpessoa,
           ass.nrdconta,
           ass.cdsecext,
           ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS188';

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  
  -- Indicativo de Anuidade
  vr_inanuida NUMBER := 0;
  
  vr_regexist BOOLEAN;
  
  vr_cdacesso craptab.cdacesso%TYPE;
  vr_cdhistor craphis.cdhistor%TYPE;
  
  vr_dtanuida DATE;
  vr_dtrefere DATE;
  
  vr_vlanuida NUMBER := 0;
  vr_qtparcan NUMBER := 0;
  vr_qtanuida NUMBER := 0;
  
  vr_rowid     ROWID;
  vr_nmtabela  VARCHAR2(100);
  vr_incrineg  INTEGER;

  vr_rw_craplot  lanc0001.cr_craplot%ROWTYPE;
  vr_tab_retorno lanc0001.typ_reg_retorno;

   
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
  
  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  -- Buscar propostas do cartão de credito
  FOR rw_crawcrd IN cr_crawcrd(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP 
                               
    -- Selecionar Dados Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => rw_crawcrd.nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- Se nao encontrou associado
    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic:= 9; -- 9 - Associado nao cadastrado.
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                    gene0002.fn_mask(rw_crawcrd.nrdconta,'zzzz.zzz.9');
      -- Fechar Cursor
      CLOSE cr_crapass;
        
      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic);
                                                      
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      
      --Proximo Registro
      CONTINUE;
    END IF;
      
    --Fechar Cursor
    CLOSE cr_crapass; 
    -- incializar variaveis
    vr_vlanuida := rw_crawcrd.vlanuida;
    vr_qtparcan := rw_crawcrd.qtparcan; 
    vr_inanuida := rw_crawcrd.inanuida; 
    vr_dtanuida := rw_crawcrd.dtanuida; 
    vr_qtanuida := rw_crawcrd.qtanuida; 
                                  
    IF rw_crawcrd.qtparcan = 0 AND rw_crawcrd.qtanuida > 0 THEN
       
      -- Verifica controle de cobranca de anuidade
      OPEN cr_crapadc(pr_cdcooper => rw_crawcrd.cdcooper
                     ,pr_cdadmcrd => rw_crawcrd.cdadmcrd);
      FETCH cr_crapadc INTO rw_crapadc;                
                       
      IF cr_crapadc%NOTFOUND THEN
        vr_inanuida := 3; -- Padrao (Cobrar de Todos) 
      ELSE
        vr_inanuida := rw_crapadc.inanuida;
      END IF; 
      
      -- Fechar Cursor
      CLOSE cr_crapadc;  
      
      IF vr_inanuida = 0 OR                                 -- Isenta Todos
        (vr_inanuida = 1 AND rw_crapass.inpessoa <> 1) OR   -- Isenta Pessoa Juridica
        (vr_inanuida = 2 AND rw_crapass.inpessoa = 1)  THEN -- Isenta Pessoa Fisica 
           
        vr_vlanuida := 0;
        vr_qtparcan := 0; 
           
        vr_regexist := TRUE;
      ELSE
      
        -- Monta Codigo de Acesso para Buscar Anuidade
        vr_cdacesso := 'ANUIDCART' || TRIM(to_char(rw_crawcrd.cdadmcrd,'9'));
        vr_regexist := FALSE;
                
        -- Procura Valor da Anuidade na Tabela
        FOR rw_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper,
                                     pr_cdacesso => vr_cdacesso) LOOP 
       
          -- Monta data de Referencia  --> 30/05/2015 - Alterado o dia por mês, pois estava lendo a data
                                       --               de forma errada. (Renato - Supero)
          vr_dtrefere := to_date( SUBSTR(rw_craptab.dstextab,14,2) || '/' ||
                                  SUBSTR(rw_craptab.dstextab,17,2) || '/' ||
                                  SUBSTR(rw_craptab.dstextab,20,4),'DD/MM/YYYY');
                            
          IF rw_crapdat.dtmvtolt < vr_dtrefere THEN
            -- Proximo Registro
            CONTINUE;
          END IF;  
          
          -- Valor Anuidade                           
          vr_vlanuida := to_number(SUBSTR(rw_craptab.dstextab,4,9));
          
          -- Quantidade Parcelas Anuidade
          vr_qtparcan := to_number(SUBSTR(rw_craptab.dstextab,1,2));
          vr_regexist := TRUE;
                            
          EXIT;
        END LOOP; 
                             
        IF NOT vr_regexist THEN
          vr_cdcritic := 539; -- 539 - Falta tabela de anuidade Credicard.
          RAISE vr_exc_fimprg;
        END IF;
        
      END IF;
     
    END IF;
    
    IF vr_vlanuida > 0 AND vr_qtparcan > 0 THEN
      
      -- Verifica Existencia de Lote
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_cdagenci => 1
                     ,pr_cdbccxlt => 100
                     ,pr_nrdolote => 8452);
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
                             ,nrseqdig)
                     VALUES  (pr_cdcooper
                             ,rw_crapdat.dtmvtolt
                             ,1
                             ,100
                             ,8452
                             ,1
                             ,0)
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

      IF rw_crawcrd.cdadmcrd = 1 THEN
        vr_cdhistor := 174; -- 174 - Anuidade Credicard
      ELSE  
        vr_cdhistor := 298; -- 298 - Anuidade Cartão Cecred Visa Bradesco
      END IF;  

      -- Cria Registro na CRAPLCM
      BEGIN

        lanc0001.pc_gerar_lancamento_conta(
                    pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => rw_craplot.dtmvtolt
                   ,pr_cdagenci => rw_craplot.cdagenci
                   ,pr_cdbccxlt => rw_craplot.cdbccxlt
                   ,pr_nrdolote => rw_craplot.nrdolote
                   ,pr_nrdconta => rw_crapass.nrdconta
                   ,pr_nrdctabb => rw_crapass.nrdconta
                   ,pr_nrdctitg => GENE0002.FN_MASK(rw_crapass.nrdconta, '99999999')
                   ,pr_nrdocmto => to_number(SUBSTR(to_char(rw_crawcrd.nrcrcard),9,8))
                   ,pr_cdhistor => vr_cdhistor
                   ,pr_nrseqdig => rw_craplot.nrseqdig + 1
                   ,pr_vllanmto => vr_vlanuida
                   ,pr_tab_retorno => vr_tab_retorno
                   ,pr_incrineg => vr_incrineg
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic
                   );

           if (nvl(vr_cdcritic,0) <> 0 or trim(vr_dscritic) is not null) then
              RAISE vr_exc_saida;
           end if;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela craplcm. ' || SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;
          
      --Atualizar capa do Lote
      BEGIN
        UPDATE craplot SET craplot.vlinfodb = NVL(rw_craplot.vlinfodb,0) + NVL(vr_vlanuida,0)
                          ,craplot.vlcompdb = NVL(rw_craplot.vlcompdb,0) + NVL(vr_vlanuida,0)
                          ,craplot.qtinfoln = NVL(rw_craplot.qtinfoln,0) + 1
                          ,craplot.qtcompln = NVL(rw_craplot.qtcompln,0) + 1
                          ,craplot.nrseqdig = NVL(rw_craplot.nrseqdig,0) + 1
        WHERE craplot.ROWID = rw_craplot.ROWID;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela craplot. '||SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;
          
      -- Criar novo registro
      BEGIN
        INSERT INTO crapavs(dtmvtolt
                           ,cdagenci
                           ,cdempres
                           ,cdhistor
                           ,cdsecext
                           ,dtdebito
                           ,dtrefere
                           ,insitavs
                           ,nrdconta
                           ,nrseqdig
                           ,nrdocmto
                           ,vllanmto
                           ,tpdaviso
                           ,vldebito
                           ,vlestdif
                           ,flgproce
                           ,cdcooper)
          VALUES(rw_crapdat.dtmvtolt
                ,rw_crapass.cdagenci
                ,0
                ,vr_cdhistor
                ,rw_crapass.cdsecext
                ,rw_crapdat.dtmvtolt
                ,rw_crapdat.dtmvtolt
                ,0
                ,rw_crapass.nrdconta
                ,rw_craplot.nrseqdig + 1
                ,to_number(SUBSTR(to_char(rw_crawcrd.nrcrcard),9,8))
                ,vr_vlanuida
                ,2
                ,0
                ,0
                ,0
                ,pr_cdcooper);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao gravar em CRAPAVS: ' || SQLERRM;              
          RAISE vr_exc_saida;
      END;
          
    END IF;
    
    IF vr_qtparcan > 0 THEN
      vr_qtparcan := vr_qtparcan - 1;
    END IF;  
    
    IF vr_qtparcan > 0 THEN
      vr_qtanuida := rw_crawcrd.qtanuida;
      
      -- Calcula data Anuidade
      vr_dtanuida := gene0005.fn_calc_data(pr_dtmvtolt => rw_crawcrd.dtanuida --> Data do movimento
                                          ,pr_qtmesano => 1                   --> Quantidade a acumular
                                          ,pr_tpmesano => 'M'                 --> Tipo Mes ou Ano
                                          ,pr_des_erro => vr_dscritic);
    ELSE
      vr_qtanuida := rw_crawcrd.qtanuida + 1; 
      
      -- Calcula data Anuidade
      vr_dtanuida := gene0005.fn_calc_data(pr_dtmvtolt => rw_crawcrd.dtentreg --> Data do movimento
                                          ,pr_qtmesano => vr_qtanuida         --> Quantidade a acumular
                                          ,pr_tpmesano => 'A'                 --> Tipo Mes ou Ano
                                          ,pr_des_erro => vr_dscritic);
      
    END IF;
    
    -- Ajusta Indicativo de Anuidade
    IF to_char(rw_crapdat.dtmvtolt,'MM') = to_char(vr_dtanuida,'MM') AND
       to_char(rw_crapdat.dtmvtolt,'YYYY') =  to_char(vr_dtanuida,'YYYY') THEN
      vr_inanuida := 0;
    ELSE
      vr_inanuida := 1;
    END IF;
    
    BEGIN
      -- Atualiza registros do Cartão 
      UPDATE crawcrd SET crawcrd.vlanuida = vr_vlanuida
                        ,crawcrd.qtparcan = vr_qtparcan
                        ,crawcrd.inanuida = vr_inanuida
                        ,crawcrd.dtanuida = vr_dtanuida
                        ,crawcrd.qtanuida = vr_qtanuida
      WHERE crawcrd.ROWID = rw_crawcrd.ROWID;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar tabela craplot. '||SQLERRM;
        --Sair do programa
        RAISE vr_exc_saida;
    END;
                               
  END LOOP;                            

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
END pc_crps188;
/
