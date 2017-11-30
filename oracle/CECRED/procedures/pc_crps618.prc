CREATE OR REPLACE PROCEDURE CECRED.pc_crps618(pr_cdcooper  IN craptab.cdcooper%type,
                                              pr_nrdconta  IN crapcob.nrdconta%TYPE,                                              
                                              pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                              pr_dscritic OUT VARCHAR2) AS

  /******************************************************************************
    Programa: pc_crps618 (Antigo: fontes/crps618.p) 
    Sistema : Cobranca - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Rafael
    Data    : janeiro/2012.                     Ultima atualizacao: 20/09/2017
 
    Dados referentes ao programa:
 
    Frequencia: Diario.
    Objetivo  : Buscar confirmacao de registro dos titulos na CIP.
                Registrar titulos na CIP a partir de novembro/2013.
    
    Observacoes: O script /usr/local/cecred/bin/crps618.pl executa este 
                 programa para verificar o registro/rejeicao dos titulos 
                 na CIP enviados no dia.
                 
                 Horario de execucao: todos os dias, das 6:00h as 22:00h
                                      a cada 15 minutos.
                                      
    Alteracoes: 27/08/2013 - Alterado busca de registros de titulos utilizando
                             a data do movimento anterior (Rafael).
                             
                21/10/2013 - Incluido parametro novo na prep-retorno-cooperado
                             ref. ao numero de remessa do arquivo (Rafael).
                             
                15/11/2013 - Mudanças no processo de registro dos titulos na 
                             CIP: a partir da liberaçao de novembro/2013, os
                             titulos gerados serao registrados por este 
                             programa definidos pela CRON. O campo 
                             "crapcob.insitpro" irá utilizar os seguintes 
                             valores:
                             0 -> sacado comum (nao DDA);
                             1 -> sacado a verificar se é DDA;
                             2 -> Enviado a CIP;
                             3 -> Sacado DDA OK;
                             4 -> nao haverá mais -> retornar a "zero";
                             
                03/12/2013 - Incluido nome da temp-table tt-remessa-dda nos 
                             campos onde faltavam o nome da tabela. (Rafael)
                             
                30/12/2013 - Ajuste na leitura/gravacao das informacoes dos
                             titulos ref. ao DDA. (Rafael)     
                
                14/01/2014 - Alteracao referente a integracao Progress X 
                             Dataserver Oracle 
                             Inclusao do VALIDATE ( Andre Euzebio / SUPERO)  
                             
                03/02/2014 - Ajuste Projeto Novo Fator de Vencimento (Daniel).
                
                27/05/2014 - Aumentado o tempo para decurso de prazo de titulos 
                             DDA de 22 para 59 dias (Tiago SD138818).
                             
                17/07/2014 - Alterado forma de gravacao do tipo de multa para
                             garantir a confirmacao do registro na CIP. (Rafael)
                             
                12/02/2014 - Incluido restriçao para nao enviar cobrança para a cabine 
                             no qual o valor ultrapasse 9.999.999,99, pois a cabine
                             existe essa limitaçao de valor e apresentará falha nao 
                             tratada SD-250064 (Odirlei-AMcom)
                             
                28/04/2015 - Ajustar indicador de alt de valor ref a boletos
                             vencidos DDA para "N" -> Sacado nao pode alterar
                             o valor de boleto vencido. (SD 279793 - Rafael)
                             
                29/05/2015 - Concatenar motivo "A4" para titulos DDA no registro
                             de confirmacao de retorno na crapret.
                           - Enviar titulo Cooperativa/EE ao DDA quando já
                             enviado para a PG. (Projeto 219 - Rafael)
                                                         
                31/07/2015 - Ajuste para retirar o caminho absoluto na chamada
                             de fontes
                             (Adriano - SD 314469).
                                                                         
                18/08/2015 - Ajuste na data limite de pagto para boletos do 
                             convenio "EMPRESTIMO" - Projeto 210 (Rafael).
                             
                14/11/2016 - CONVERSÃO PROGRESS >> ORACLE (Renato Darosci - Supero)
                
                01/12/2016 - Alterado para enviar como texto informativo o conteudo do campo
                             dsinform, ao inves do campo dsdinstr
                             Heitor (Mouts) - Chamado 564818

                27/12/2016 - Tratamentos para Nova Plataforma de Cobrança
                             PRJ340 - NPC (Odirlei-AMcom)
                             
                12/07/2017 - Retirado cobranca de tarifa após a rejeição do 
                             boleto DDA na CIP (Rafael)
                             
                14/07/2017 - Retirado verificação do inproces da crapdat. Dessa forma
                             o programa pode ser executado todos os dias. (Rafael)

                20/09/2017 - Ajustado para que e a validação de envio do titulo para a CIP
                             seja feita com duas variáveis, pois caso o pagador não seja DDA
                             e o primeiro titulo identificado como dentro da faixa de ROLLOUT,
                             todos os titulos que serão processados em seguida tambem serão
                             registrados (Douglas - Chamado 756559)

                20/10/2017 - O boleto foi gerado pela Conta Online para integração on-line
                             com a CIP. No mesmo momento a rotina de carga normal também estava
                             inicou a execução. O boleto foi enviado tanto pela processo normal
                             quanto pela carga on-line. Incluída verificação do IDTITLEG para
                             evitar envio de título já registrado. (SD#777146 - AJFink)

                09/11/2017 - Inclusão de chamada da procedure npcb0002.pc_libera_sessao_sqlserver_npc.
                             (SD#791193 - AJFink)

  ******************************************************************************/
  -- CONSTANTES
  vr_cdprogra     CONSTANT VARCHAR2(10) := 'crps618';     -- Nome do programa
  vr_vllimcab     CONSTANT NUMBER       := 99999999.99;    -- Define o valor limite da cabine
  vr_cdoperad     CONSTANT VARCHAR2(10) := '1';           -- Código do operador - verificar se será fixo ou parametro

  -- CURSORES 
  -- Buscar as cooperativas para processamento
  -- Quanto a cooperativa do parametro for 3, ira processar todas as coops 
  -- exceto CECRED, quando outra cooperativa for informada, gerar para a propria
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
         , cop.cdbcoctl
         , cop.cdagectl
      FROM crapcop cop
     WHERE (pr_cdcooper = 3 AND cop.cdcooper <> 3 AND cop.flgativo = 1) -- batch
        OR (pr_cdcooper <> 3 AND cop.cdcooper = pr_cdcooper) -- registro online
     ORDER BY cop.cdcooper;           
  
  -- Buscar os títulos a serem registrados na CIP
  CURSOR cr_titulos_carga (pr_cdcooper crapcop.cdcooper%TYPE
                          ,pr_cdbcoctl crapcop.cdbcoctl%TYPE
                          ,pr_vlrollou crapcob.vltitulo%TYPE
                          ,pr_dtmvtolt crapcob.dtmvtolt%TYPE) IS 
                          
    SELECT COUNT(1)     OVER (PARTITION BY cob.nrinssac) nrqtdreg
         , ROW_NUMBER() OVER (PARTITION BY cob.nrinssac
                                  ORDER BY cob.nrinssac) nrseqreg
         -- CRAPCOB
         , cob.rowid    rowidcob
         , cob.cdcooper
         , cob.nrdconta
         , cob.cdtpinsc
         , cob.inemiten
         , cob.inemiexp
         , cob.vltitulo
         , cob.nrcnvcob
         , cob.nrdocmto
         , cob.idopeleg
         , cob.idtitleg 
         , cob.dtvencto
         , cob.cdbandoc
         , cob.cdcartei
         , cob.tpjurmor
         , cob.cddespec 
         , cob.nrnosnum
         , cob.cdtpinav
         , cob.nrinsava
         , cob.nmdavali
         , cob.dsdoccop
         , cob.flgdprot
         , cob.qtdiaprt
         , cob.vlabatim
         , cob.vljurdia
         , cob.tpdmulta
         , cob.vlrmulta
         , cob.vldescto
         , cob.dsinform
         , cob.flgaceit
         , cob.inpagdiv
         , decode(cob.vlminimo,0,NULL,cob.vlminimo) vlminimo
         , cob.dtbloque
         -- CRAPCCO
         , cco.cddbanco
         , cco.dsorgarq
         -- CRAPSAB
         , sab.nrinssac
         , sab.nmdsacad
         , sab.dsendsac
         , sab.nmcidsac
         , sab.cdufsaca
         , sab.nrcepsac
         -- CRAPASS
         , ass.inpessoa
         , ass.nrcpfcgc
         , ass.nmprimtl
      FROM crapcco cco
         , crapceb ceb
         , crapass ass
         , crapcob cob
         , crapsab sab
     WHERE ceb.cdcooper = cco.cdcooper
       AND ceb.nrconven = cco.nrconven
       AND ass.cdcooper = ceb.cdcooper
       AND ass.nrdconta = ceb.nrdconta
       AND cob.cdcooper = ceb.cdcooper
       AND cob.nrcnvcob = ceb.nrconven
       AND cob.nrdconta = ceb.nrdconta
       AND cob.flgregis = 1 -- TRUE 
--       AND cob.insitpro IN (0,1)
--       AND cob.inenvcip IN (0,1,2)
       AND cob.incobran = 0
       AND cob.dtdpagto is null
       AND cob.dtvencto >= pr_dtmvtolt 
       AND cob.vltitulo >= pr_vlrollou
       AND nvl(cob.nrdident,0) = 0
       AND nvl(cob.idtitleg,0) = 0 /*SD#777146*/
       AND sab.cdcooper = cob.cdcooper
       AND sab.nrdconta = cob.nrdconta
       AND sab.nrinssac = cob.nrinssac
       AND cco.flgregis = 1 -- TRUE
       AND cco.cdcooper = pr_cdcooper
       AND cco.cddbanco = pr_cdbcoctl       
     ORDER BY cob.nrinssac;
  
  -- Buscar os títulos a serem registrados na CIP
  CURSOR cr_titulos(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_cdbcoctl crapcop.cdbcoctl%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE
                   ,pr_dtmvtoan crapcob.dtmvtolt%TYPE
                   ,pr_dtmvtolt crapcob.dtmvtolt%TYPE) IS 
    SELECT COUNT(1)     OVER (PARTITION BY cob.nrinssac) nrqtdreg
         , ROW_NUMBER() OVER (PARTITION BY cob.nrinssac
                                  ORDER BY cob.nrinssac) nrseqreg
         -- CRAPCOB
         , cob.rowid    rowidcob
         , cob.cdcooper
         , cob.nrdconta
         , cob.cdtpinsc
         , cob.inemiten
         , cob.inemiexp
         , cob.vltitulo
         , cob.nrcnvcob
         , cob.nrdocmto
         , cob.idopeleg
         , cob.idtitleg 
         , cob.dtvencto
         , cob.cdbandoc
         , cob.cdcartei
         , cob.tpjurmor
         , cob.cddespec 
         , cob.nrnosnum
         , cob.cdtpinav
         , cob.nrinsava
         , cob.nmdavali
         , cob.dsdoccop
         , cob.flgdprot
         , cob.qtdiaprt
         , cob.vlabatim
         , cob.vljurdia
         , cob.tpdmulta
         , cob.vlrmulta
         , cob.vldescto
         , cob.dsinform
         , cob.flgaceit
         , cob.inpagdiv
         , decode(cob.vlminimo,0,NULL,cob.vlminimo) vlminimo
         , cob.dtbloque
         -- CRAPCCO
         , cco.cddbanco
         , cco.dsorgarq
         -- CRAPSAB
         , sab.nrinssac
         , sab.nmdsacad
         , sab.dsendsac
         , sab.nmcidsac
         , sab.cdufsaca
         , sab.nrcepsac
         -- CRAPASS
         , ass.inpessoa
         , ass.nrcpfcgc
         , ass.nmprimtl         
      FROM crapcco cco
         , crapceb ceb
         , crapass ass
         , crapcob cob
         , crapsab sab
     WHERE ceb.cdcooper = cco.cdcooper
       AND ceb.nrconven = cco.nrconven
       AND ass.cdcooper = ceb.cdcooper
       AND ass.nrdconta = ceb.nrdconta
       AND cob.cdcooper = ceb.cdcooper
       AND cob.nrcnvcob = ceb.nrconven
       AND cob.nrdconta = ceb.nrdconta
       AND cob.flgregis = 1 -- TRUE 
--       AND cob.insitpro = 1 
       AND cob.inenvcip = 1
       AND cob.dtmvtolt BETWEEN pr_dtmvtoan AND pr_dtmvtolt
       AND cob.incobran = 0
       AND (cob.nrdconta = pr_nrdconta OR NVL(pr_nrdconta,0) = 0)
       AND ((NVL(pr_nrdconta,0) > 0 AND cob.inregcip = 1) OR
            (NVL(pr_nrdconta,0) = 0 ))
       AND nvl(cob.nrdident,0) = 0
       AND nvl(cob.idtitleg,0) = 0 /*SD#777146*/
       AND sab.cdcooper = cob.cdcooper
       AND sab.nrdconta = cob.nrdconta
       AND sab.nrinssac = cob.nrinssac
       AND cco.flgregis = 1 -- TRUE
       AND cco.cdcooper = pr_cdcooper
       AND cco.cddbanco = pr_cdbcoctl
     ORDER BY cob.nrinssac;
    
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
  -- VARIÁVEIS
  vr_tb_remessa_dda     DDDA0001.typ_tab_remessa_dda;
  vr_tb_retorno_dda     DDDA0001.typ_tab_retorno_dda;
  
  vr_tppessoa           VARCHAR2(1);
  vr_flgsacad           NUMBER;
  vr_flgrollout         INTEGER;
  vr_cdcritic           NUMBER;
  vr_dscritic           VARCHAR2(1000);
  vr_des_erro           VARCHAR2(10);
  vr_insitpro           NUMBER;

  vr_tpdenvio           INTEGER;
  vr_flgerlog           BOOLEAN;
  vr_cdcooper           crapcop.cdcooper%TYPE;
  
  -- EXCEPTIONS
  vr_exc_saida          EXCEPTION;     
       
  
  PROCEDURE pc_atualiza_status_envio_dda(pr_tab_remessa_dda IN OUT DDDA0001.typ_tab_remessa_dda
                                        ,pr_tpdenvio        IN INTEGER  --> tipo de envio(0-Normal/Batch, 1-Online, 2-Carga inicial)    
                                        ,pr_cdcritic       OUT INTEGER
                                        ,pr_dscritic       OUT VARCHAR2) IS
    vr_index     INTEGER;
    vr_exc_saida EXCEPTION;
    vr_cdcooper  crapcob.cdcooper%TYPE;
    vr_nrdconta  crapcob.cdcooper%TYPE;
    vr_nrcnvcob  crapcob.cdcooper%TYPE;
    vr_nrdocmto  crapcob.cdcooper%TYPE;
    vr_dscmplog  VARCHAR2(200);
    
    
  BEGIN
        
    vr_index := pr_tab_remessa_dda.FIRST;
      
    WHILE vr_index IS NOT NULL LOOP      

      -- Verifica se ocorreu erro
      IF TRIM(pr_tab_remessa_dda(vr_index).dscritic) IS NOT NULL THEN
        -- Atualizar CRAPCOB 
        BEGIN
          UPDATE crapcob
             SET flgcbdda = 0 -- FALSE
               , insitpro = 0
               , idtitleg = 0
               , idopeleg = 0
               , inenvcip = 0 -- não enviar
               , dhenvcip = null
           WHERE ROWID = pr_tab_remessa_dda(vr_index).rowidcob;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro[1] ao atualizar CRAPCOB: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE      
        -- Atualizar CRAPCOB 
        BEGIN
          UPDATE crapcob
             SET flgcbdda = 1 -- TRUE
               , insitpro = 2 -- recebido JD
               , inenvcip = 2 -- enviado
               , dhenvcip = SYSDATE
           WHERE ROWID = pr_tab_remessa_dda(vr_index).rowidcob
           RETURNING cdcooper,nrdconta,nrcnvcob,nrdocmto
                INTO vr_cdcooper,vr_nrdconta,vr_nrcnvcob,vr_nrdocmto;           
            
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro[2] ao atualizar CRAPCOB: '||SQLERRM;
            RAISE vr_exc_saida;
        END;      
        
        --Definir complemento do log conforme tipo de envio
        vr_dscmplog := NULL;
        IF pr_tpdenvio = 1 THEN
          vr_dscmplog := ' online';
        ELSIF pr_tpdenvio = 2 THEN
          vr_dscmplog := ' carga NPC';
        END IF;
        
        -- Incluir o log do boleto
        BEGIN 
          INSERT INTO crapcol(cdcooper
                             ,nrdconta
                             ,nrcnvcob
                             ,nrdocmto
                             ,dslogtit
                             ,cdoperad
                             ,dtaltera
                             ,hrtransa)
                       VALUES(vr_cdcooper   -- cdcooper 
                             ,vr_nrdconta   -- nrdconta 
                             ,vr_nrcnvcob   -- nrcnvcob 
                             ,vr_nrdocmto   -- nrdocmto 
                             ,'Titulo enviado a CIP'||vr_dscmplog   -- dslogtit 
                             ,'1'                      -- cdoperad 
                             ,TRUNC(SYSDATE)           -- dtaltera 
                             ,GENE0002.fn_busca_time); -- hrtransa 
        EXCEPTION 
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao gerar Log do boleto: '||SQLERRM;
            RETURN;
        END;
        
        
            
      END IF; /* fim - return_value */       
          
      vr_index := pr_tab_remessa_dda.NEXT(vr_index);      
    END LOOP;
        
  EXCEPTION 
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel atualizar crapcob status DDA: '||SQLERRM;  
       
  END pc_atualiza_status_envio_dda;  
  
  --> Rotina para controlar geração da carga inicial do NPC
  PROCEDURE pc_carga_inic_npc(pr_cdcooper IN crapcop.cdcooper%TYPE,
                              pr_cdbcoctl IN crapcop.cdbcoctl%TYPE,      
                              pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE,
                              pr_cdagectl   IN crapcop.cdagectl%TYPE,
                              pr_dscritic  OUT VARCHAR2) IS
  
    vr_dstextab     craptab.dstextab%TYPE;  
    vr_tab_campos   gene0002.typ_split;  
    vr_dscritic     VARCHAR2(4000);
    
  
  BEGIN
  
    --> Buscar dados
    vr_dstextab := TABE0001.fn_busca_dstextab
                                     (pr_cdcooper => pr_cdcooper
                                     ,pr_nmsistem => 'CRED'
                                     ,pr_tptabela => 'GENERI'
                                     ,pr_cdempres => 0
                                     ,pr_cdacesso => 'ROLLOUT_CIP_CARGA'
                                     ,pr_tpregist => 0); 
      
    vr_tab_campos:= gene0002.fn_quebra_string(vr_dstextab,';');
    
    IF vr_tab_campos.count > 0 THEN
      --> Verificar se esta no dia da cargar inicial da faixa de rollout
      --> e se ainda nao rodou a carga
      IF to_date(vr_tab_campos(2),'DD/MM/RRRR') = pr_rw_crapdat.dtmvtolt AND 
         vr_tab_campos(1) = 0 THEN
         
        vr_tb_remessa_dda.DELETE();
        vr_tb_retorno_dda.DELETE(); 
         
        -- Buscar titulos que atendem a regra de rollout da carga inicial
        FOR rw_titulos IN cr_titulos_carga(pr_cdcooper => pr_cdcooper
                                          ,pr_cdbcoctl => pr_cdbcoctl
                                          ,pr_vlrollou => vr_tab_campos(3)
                                          ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt) LOOP        

          -- Tratamento para nao enviar para a cabine pois a cabine existe essa limitaçao de valor 
          IF rw_titulos.vltitulo > vr_vllimcab THEN 
            -- Devido a limitação da cabine, indica como não sendo sacado DDA
            vr_insitpro := 0;
             
            -- Cria o log da cobrança
            PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_titulos.rowidcob
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_dtmvtolt => SYSDATE
                                         ,pr_dsmensag => 'Falha no envio para a CIP (valor superior ao suportado)'
                                         ,pr_des_erro => vr_des_erro
                                         ,pr_dscritic => vr_dscritic);
          
            -- Se ocorrer erro
            IF vr_des_erro <> 'OK' THEN
              RAISE vr_exc_saida;
            END IF;
          END IF; -- FIM: rw_titulos.vltitulo > vr_vllimcab        


          -- Rotina para criação de titulo
          DDDA0001.pc_cria_remessa_dda(pr_rowid_cob => rw_titulos.rowidcob
                                     , pr_tpoperad => 'I'
                                     , pr_tpdbaixa => NULL
                                     , pr_dtvencto => rw_titulos.dtvencto
                                     , pr_vldescto => rw_titulos.vldescto
                                     , pr_vlabatim => rw_titulos.vlabatim
                                     , pr_flgdprot => (CASE rw_titulos.flgdprot WHEN 0 THEN FALSE ELSE TRUE END)
                                     , pr_tab_remessa_dda => vr_tb_remessa_dda
                                     , pr_cdcritic => vr_cdcritic
                                     , pr_dscritic => vr_dscritic);
                                  
          IF trim(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;
                               
                                            
        END LOOP;  
        
        -- Realizar a remessa de títulos DDA
        DDDA0001.pc_remessa_tit_tab_dda(pr_tab_remessa_dda => vr_tb_remessa_dda
                                       ,pr_tab_retorno_dda => vr_tb_retorno_dda
                                       ,pr_cdcritic        => vr_cdcritic
                                       ,pr_dscritic        => vr_dscritic);
        
        -- Verificar se ocorreu erro
        IF trim(vr_dscritic) IS NOT NULL THEN
          pr_dscritic := 'Erro na rotina PC_REMESSA_TITULOS_DDA[carga NPC]: '||vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
        
        -- Atualizar status da remessa de títulos DDA      
        pc_atualiza_status_envio_dda(pr_tab_remessa_dda => vr_tb_remessa_dda
                                    ,pr_tpdenvio        => 2
                                    ,pr_cdcritic        => vr_cdcritic
                                    ,pr_dscritic        => vr_dscritic);
                                    
        -- Verificar se ocorreu erro
        IF trim(vr_dscritic) IS NOT NULL THEN
          pr_dscritic := 'Erro na rotina PC_ATUALIZA_STATUS_ENVIO_DDA[carga NPC]: '||vr_dscritic;
          RAISE vr_exc_saida;
        END IF;                                  
              
        --> Atualizar tab para informar que ja gerou dados da carga
        BEGIN
          UPDATE craptab tab
             SET tab.dstextab = '1'||SUBSTR(tab.dstextab,2)
           WHERE cdcooper        = pr_cdcooper 
             AND upper(nmsistem) = 'CRED'
             AND upper(tptabela) = 'GENERI'
             AND cdempres        = 0
             AND upper(cdacesso) = 'ROLLOUT_CIP_CARGA'
             AND tpregist        = 0; 
          
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tab ROLLOUT_CIP_CARGA: '|| SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- limpar temptables
        vr_tb_remessa_dda.DELETE();
        vr_tb_retorno_dda.DELETE(); 
        
        --> commitar carga
        COMMIT;  
      END IF;     
       
    END IF;
    
  EXCEPTION 
    WHEN vr_exc_saida THEN
      
      -- limpar temptables
      vr_tb_remessa_dda.DELETE();
      vr_tb_retorno_dda.DELETE();       
      
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN

      -- limpar temptables
      vr_tb_remessa_dda.DELETE();
      vr_tb_retorno_dda.DELETE(); 
      
      pr_dscritic := 'Não foi possivel gerar carga inicial: '||SQLERRM;
  END pc_carga_inic_npc;
  
  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    vr_dscritic_aux VARCHAR2(4000);
  BEGIN
  
    --> Apenas gerar log se for processo batch/job ou erro  
    IF nvl(pr_nrdconta,0) = 0 OR  pr_dstiplog = 'E' THEN
    
      vr_dscritic_aux := pr_dscritic;
      
      --> Se é erro e possui conta, concatenar o numero da conta no erro
      IF pr_nrdconta <> 0 THEN
        vr_dscritic_aux := vr_dscritic_aux||' - Conta: '||pr_nrdconta;
      END IF;
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_cdprogra    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => vr_dscritic_aux    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
  
    END IF;
  END pc_controla_log_batch;
  
  /**********************************************************/
   
BEGIN
  
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_'||UPPER(vr_cdprogra),
                             pr_action => vr_cdprogra);
      
 
  -- Percorrer as cooperativas
  FOR rw_crapcop IN cr_crapcop LOOP
  
    /* Busca data do sistema */ 
    OPEN  BTCH0001.cr_crapdat(rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Verificar se existe informação, e gerar erro caso não exista
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
    -- Fechar 
    CLOSE BTCH0001.cr_crapdat;
    
    -- Log de início da execução
    pc_controla_log_batch(pr_cdcooper  => rw_crapcop.cdcooper,
                          pr_dstiplog  => 'I');
    
    --> variavel apenas para controle do log, caso seja abortado o programa
    vr_cdcooper := rw_crapcop.cdcooper;
    
    /* DESNECESSÁRIO POIS O LOOP JÁ EH POR COOPERATIVA
    -- Verifica se a cooperativa esta cadastrada 
    OPEN  cr_crapcop(vr_cdcooper);
    FETCH cr_crapcop INTO vr_inregist;
    
    -- Verificar se existe informação, e gerar erro caso não exista
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapcop;
      -- Gerar exceção
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcop; */
    
    
    --> Marcar processo como chamada online
    --tipo de envio(0-normal/batch, 1-online,2-carga inicial)
    vr_tpdenvio := 0;
    
    IF pr_nrdconta > 0 THEN
      vr_tpdenvio := 1;
    END IF;
    
    IF vr_tpdenvio = 0 THEN
      --> Controlar geração da carga inicial do NPC
      pc_carga_inic_npc(pr_cdcooper   => rw_crapcop.cdcooper,
                        pr_cdbcoctl   => rw_crapcop.cdbcoctl,      
                        pr_rw_crapdat => rw_crapdat,
                        pr_cdagectl   => rw_crapcop.cdagectl,
                        pr_dscritic   => vr_dscritic);

      -- Verifica se ocorreu erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;

    -- Limpar registros de memória
    vr_tb_remessa_dda.DELETE();
    vr_tb_retorno_dda.DELETE();

    -- Inicializar ROLLOUT e o sacado DDA
    vr_flgrollout := 0;
    vr_flgsacad   := 0;
    vr_insitpro   := 0; -- nao eh sacado DDA 
    
    -- Rotina para registrar os títulos na CIP
    FOR rw_titulos IN cr_titulos(pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
      
      -- Inicializar o ROLLOUT a cada titulo
      vr_flgrollout := 0;
      vr_insitpro   := 0; -- nao eh sacado DDA 
      
      -- Se for o primeiro NRINSSAC
      IF rw_titulos.nrseqreg = 1 THEN
        -- Inicializar a FLAG DDA para cada sacado
        vr_flgsacad := 0;
          
        -- Verificar o tipo da inscrição
        IF rw_titulos.cdtpinsc = 1 THEN
          vr_tppessoa := 'F'; /*Fisica*/
        ELSE
          vr_tppessoa := 'J'; /*Juridica*/
        END IF;

        -- Chamar rotina para realizar as verificações do SAcado
        DDDA0001.pc_verifica_sacado_dda(pr_tppessoa => vr_tppessoa
                                       ,pr_nrcpfcgc => rw_titulos.nrinssac
                                       ,pr_flgsacad => vr_flgsacad
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

        -- Verifica se ocorreu erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
          
      END IF; -- FIM: rw_titulos.nrseqreg = 1

      -- Se titulo Cooperativa/EE e nao foi enviado ainda para a PG, nao enviar ao DDA 
      IF rw_titulos.inemiten  = 3   AND 
         rw_titulos.inemiexp <> 2   THEN 
        CONTINUE; -- Passar para o próximo registro
      END IF;

      -- Tratamento para nao enviar para a cabine pois a cabine existe essa limitaçao de valor 
      IF rw_titulos.vltitulo > vr_vllimcab THEN 
        -- Devido a limitação da cabine, indica como não sendo sacado DDA
        vr_insitpro := 0;
         
        -- Cria o log da cobrança
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_titulos.rowidcob
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dtmvtolt => SYSDATE
                                     ,pr_dsmensag => 'Falha no envio para a CIP (valor superior ao suportado)'
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
      
        -- Se ocorrer erro
        IF vr_des_erro <> 'OK' THEN
          RAISE vr_exc_saida;
        END IF;
      END IF; -- FIM: rw_titulos.vltitulo > vr_vllimcab
      
      --> Verificar rollout da plataforma de cobrança
      vr_flgrollout := NPCB0001.fn_verifica_rollout 
                                 ( pr_cdcooper     => rw_titulos.cdcooper, --> Codigo da cooperativa
                                   pr_dtmvtolt     => rw_crapdat.dtmvtolt, --> Data de movimento
                                   pr_vltitulo     => rw_titulos.vltitulo, --> Valor do titulo
                                   pr_tpdregra     => 1);                  --> Tipo de regra de rollout(1-registro,2-pagamento)      
      
      -- Verifica sacado - Se TRUE
      IF vr_flgsacad = 1 OR vr_flgrollout = 1 THEN
        vr_insitpro := 2;   -- enviar/enviado p/ CIP
      ELSE
        vr_insitpro := 0;   -- nao eh sacado DDA 
      END IF;

      -- Se sacado for DDA, entao titulo eh DDA 
      IF vr_insitpro = 2 THEN
        
        DDDA0001.pc_cria_remessa_dda(pr_rowid_cob => rw_titulos.rowidcob
                                   , pr_tpoperad => 'I'
                                   , pr_tpdbaixa => NULL
                                   , pr_dtvencto => rw_titulos.dtvencto
                                   , pr_vldescto => rw_titulos.vldescto
                                   , pr_vlabatim => rw_titulos.vlabatim
                                   , pr_flgdprot => (CASE rw_titulos.flgdprot WHEN 0 THEN FALSE ELSE TRUE END)
                                   , pr_tab_remessa_dda => vr_tb_remessa_dda
                                   , pr_cdcritic => vr_cdcritic
                                   , pr_dscritic => vr_dscritic);
              
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      
      ELSE
        -- Atualizar CRAPCOB 
        BEGIN
          UPDATE crapcob
             SET flgcbdda = 0 -- FALSE
               , insitpro = 0
               , inenvcip = 0 -- não enviar
               , dhenvcip = NULL
               , inregcip = 0 -- sem registro na CIP
           WHERE ROWID = rw_titulos.rowidcob;
                     
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro[3] ao atualizar CRAPCOB: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;
    END LOOP;  
        
    -- Realizar a remessa de títulos DDA
    DDDA0001.pc_remessa_tit_tab_dda(pr_tab_remessa_dda => vr_tb_remessa_dda
                                   ,pr_tab_retorno_dda => vr_tb_retorno_dda
                                   ,pr_cdcritic        => vr_cdcritic
                                   ,pr_dscritic        => vr_dscritic);
    
    -- Verificar se ocorreu erro
    IF trim(vr_dscritic) IS NOT NULL THEN
      pr_dscritic := 'Erro na rotina PC_REMESSA_TITULOS_DDA: '||vr_dscritic;
      RAISE vr_exc_saida;
    END IF;
    
    -- Atualizar status da remessa de títulos DDA      
    pc_atualiza_status_envio_dda(pr_tab_remessa_dda => vr_tb_remessa_dda
                                ,pr_tpdenvio        => vr_tpdenvio
                                ,pr_cdcritic        => vr_cdcritic
                                ,pr_dscritic        => vr_dscritic);
                                  
    -- Verificar se ocorreu erro
    IF trim(vr_dscritic) IS NOT NULL THEN
      pr_dscritic := 'Erro na rotina PC_ATUALIZA_STATUS_ENVIO_DDA: '||vr_dscritic;
      RAISE vr_exc_saida;
    END IF;                                      
    
    -- Rotina para buscar o "OK" da CIP
    vr_tb_remessa_dda.DELETE();
    vr_tb_retorno_dda.DELETE();
        
    -- Log de início da execução
    pc_controla_log_batch(pr_cdcooper  => rw_crapcop.cdcooper,
                          pr_dstiplog  => 'F');
    
                                                  
    --> Gravar dados a cada cooperativa (batch)
    IF nvl(pr_nrdconta,0) = 0 THEN
      COMMIT;
      npcb0002.pc_libera_sessao_sqlserver_npc;
    END IF;
    
  END LOOP; -- Fim loop cooperativas    
  
EXCEPTION
  
  WHEN vr_exc_saida THEN
    
    -- Rotina para buscar o "OK" da CIP
    vr_tb_remessa_dda.DELETE();
    vr_tb_retorno_dda.DELETE();
  
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    
    -- Log de erro início da execução
    pc_controla_log_batch(pr_cdcooper  => vr_cdcooper,
                          pr_dstiplog  => 'F',
                          pr_dscritic  => pr_dscritic);
    
    
    -- Efetuar rollback
    IF nvl(pr_nrdconta,0) = 0 THEN
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc;
    END IF;
    
  WHEN OTHERS THEN
    
    -- Rotina para buscar o "OK" da CIP
    vr_tb_remessa_dda.DELETE();
    vr_tb_retorno_dda.DELETE();
  
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    
    -- Log de erro início da execução
    pc_controla_log_batch(pr_cdcooper  => vr_cdcooper,
                          pr_dstiplog  => 'F',
                          pr_dscritic  => pr_dscritic);
    
    -- Efetuar rollback
    IF nvl(pr_nrdconta,0) = 0 THEN
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc;
    END IF;
END pc_crps618;
/
