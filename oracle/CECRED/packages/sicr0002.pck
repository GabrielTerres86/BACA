create or replace package cecred.SICR0002 is
  /*..............................................................................

     Programa: SICR0002
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Ranghetti
     Data    : Junho/2014                       Ultima atualizacao: 27/10/2016

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Procedimentos para os débitos automáticos dos convênios do Sicredi que não tiveram saldo no
                 processo noturno.

     Alteracoes: 12/02/2015 - Tratamento na procedure pc_consulta_convenios_wt para listar a partir de agora
                              tambem os convenios nossos (CECRED) que nao foram debitados no processo
                              noturno por insuficiencia de fundos. 
                              (Chamado 229249 - PRJ Melhoria) - (Fabricio)
                              
                 27/03/2015 - Ajustado para na gravacao do campo craplcm.cdpesqbb 
                              (procedure pc_cria_lancamentos_deb), gravar as informacoes
                              da mesma forma que quando gravado pelo pc_crps123.prc e/ou
                              pelo pc_crps509.prc (pos-liberacao). (Fabricio)
                              
                 30/03/2015 - Alterado na leitura da craplau para buscar as datas de
                              pagamentos tambem menores que a data atual, isto
                              para os casos de pagamentos com data no final de
                              semana. (Ajustes pos-liberacao # PRJ Melhoria) - 
                              (Fabricio)
                              
                 31/08/2015 - Incluir Hora da transação na inclusão da tabela craplcm 
                              (Lucas Ranghetti #324864)
                  
                 18/11/2015 - Alterado para que ao criar lancamentos seja atualizado
                              a dtultdeb da tabela crapatr conforme solicitado no 
                              chamado 322424 (Kelvin).

        				 30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
                 
                 04/07/2016 - Incluir critica "Lancamento ja efetivado pela DEBNET/DEBSIC." para lancamentos 
                              ja efetuados (Lucas Ranghetti #474938)

                 08/07/2016 - Alteracao na pc_consulta_convenios_wt para buscar apenas
                              débitos de convênios que não foram efetivados no dia.
                              SD 483180. (Carlos Rafael Tanholi)   
							  
					       02/08/2016 - Corrigi a forma de tratamento dos lancamentos da craplau filtrados, para
							                considerar aqueles com data de pagamento nos finais de semana.
                              SD 497612 (Carlos Rafael Tanholi) 
                             
                 27/10/2016 - SD509982 - Ajuste leitura registros DEBCON (Guilherme/SUPERO)			        
  ......................................................................................................... */

  -- Efetuar consulta dos debitos
  PROCEDURE pc_consulta_convenios_wt(pr_cdcooper    IN crapcop.cdcooper%TYPE,     --> Cooperativa
                                     pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE,     --> Data do movimento
                                     pr_cdcritic   OUT PLS_INTEGER,     --> Codigo de Erro
                                     pr_dscritic   OUT VARCHAR2);                 --> Descricao de Erro

  -- Criar lançamentos de debitos automaticos na tabela craplcm conforme dados buscados do progress da tela DEBCON
  PROCEDURE pc_cria_lancamentos_deb(pr_cdcooper IN crapcop.cdcooper%TYPE,     --> Cooperativa
                                    pr_dtmvtolt IN DATE,                      --> Data do movimento
                                    pr_cdhistor IN craplau.cdhistor%TYPE,     --> Codigo do historico
                                    pr_cdagenci IN crapass.cdagenci%TYPE,     --> Agencia PA
                                    pr_nrdconta IN crapass.nrdconta%TYPE,     --> conta/dv
                                    pr_vllanaut IN craplau.vllanaut%TYPE,     --> Valor lancamento
                                    pr_nrdocmto IN VARCHAR2,                  --> Documento
                                    pr_cdcritic OUT PLS_INTEGER,    --> Codigo de Erro
                                    pr_dscritic OUT VARCHAR2);                --> Descricao de Erro

END SICR0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.sicr0002 AS

  /*..............................................................................

     Programa: SICR0002
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Ranghetti
     Data    : Junho/2014                       Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Procedimentos para os débitos automáticos dos convênios do Sicredi que não tiveram saldo no
                 processo noturno.

     Alteracoes: 12/02/2015 - Tratamento na procedure pc_consulta_convenios_wt para listar a partir de agora
                              tambem os convenios nossos (CECRED) que nao foram debitados no processo
                              noturno por insuficiencia de fundos. 
                              (Chamado 229249 - PRJ Melhoria) - (Fabricio)
                              
                 27/03/2015 - Ajustado para na gravacao do campo craplcm.cdpesqbb 
                              (procedure pc_cria_lancamentos_deb), gravar as informacoes
                              da mesma forma que quando gravado pelo pc_crps123.prc e/ou
                              pelo pc_crps509.prc (pos-liberacao). (Fabricio)
                              
                 30/03/2015 - Alterado na leitura da craplau para buscar as datas de
                              pagamentos tambem menores que a data atual, isto
                              para os casos de pagamentos com data no final de
                              semana. (Ajustes pos-liberacao # PRJ Melhoria) - 
                              (Fabricio)
                              
                 31/08/2015 - Incluir Hora da transação na inclusão da tabela craplcm 
                              (Lucas Ranghetti #324864)
                  
                 18/11/2015 - Alterado para que ao criar lancamentos seja atualizado
                              a dtultdeb da tabela crapatr conforme solicitado no 
                              chamado 322424 (Kelvin).

                 30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
                 
                 04/07/2016 - Incluir critica "Lancamento ja efetivado pela DEBNET/DEBSIC." para lancamentos
                              ja efetuados na procedure pc_cria_lancamentos_deb (Lucas Ranghetti #474938)
                              
                 08/07/2016 - Alteracao na pc_consulta_convenios_wt para buscar apenas
                              débitos de convênios que não foram efetivados no dia.
                              SD 483180. (Carlos Rafael Tanholi)   
							  
					       02/08/2016 - Corrigi a forma de tratamento dos lancamentos da craplau filtrados, para
							                considerar aqueles com data de pagamento nos finais de semana.
                              SD 497612 (Carlos Rafael Tanholi) 	
                              
                 08/08/2016 - Ajuste pc_consulta_convenios_wt para grava na wt a data do agendamento do pagamento
                              para a correta busca do lançamento ao criar o lançamento de debito. (Odirlei - AMcom)
                              
                 06/09/2016 - Incluir tratamento para lock do lote na procedure 
                              pc_cria_lancamentos_deb (Lucas Ranghetti #518312)
                              
                 20/09/2016 - Alterar leitura da craplot para usar o rw_crapdat.dtmvtolt na procedure 
                              pc_cria_lancamentos_deb (Lucas Ranghetti/Fabricio #524588)
                              
                 11/10/2016 - Incluir valor do lancamento como parametro na verificacao da 
                              craplau (Lucas Ranghetti #537385)
                              
                 27/10/2016 - SD509982 - Ajuste leitura registros DEBCON (Guilherme/SUPERO)
                 
                 10/03/2017 - Ajuste na procedure pc_cria_lancamentos_deb na hora do update da
                              craplau utilizar o vllanaut como filtro pois estava retornando
                              mais de um registro (Tiago/Fabricio SD615681).

        				 13/04/2017 - Ajuste devido a importação de arquivos de débito automático com o layout FEBRABAN na versão 5
				                      (Jonata - RKAM / M311). 
                              
                 18/10/2017 - Ajustar rotina para debitar os consorcios tambem (Lucas Ranghetti #739738)
  ......................................................................................................... */

  -- VARIAVEIS A UTILIZAR
  /* Tratamento de erro */
  vr_des_erro   VARCHAR2(4000);
  vr_exc_erro   EXCEPTION;

  -- VARIAVEIS DE ERRO
  vr_cdcritic crapcri.cdcritic%TYPE := 0;
  vr_dscritic VARCHAR2(4000);

  -- VARIAVEIS DE EXCECAO
  vr_exc_saida EXCEPTION;

  /* Erro em chamadas da pc_gera_erro */
  vr_des_reto VARCHAR2(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  -- nome empresa conveniada
  vr_nmempres crapscn.dsnomcnv%TYPE;
  
  -- codigo convenio / codigo empresa (convenio Sicredi)
  vr_cdempres crapscn.cdempres%TYPE;

  vr_dtmvtolt date;
  vr_nrdocmto varchar2(25);
  vr_nrseqdig number;
  vr_dtmvtopg DATE;
  vr_dtmovini craplau.dtmvtopg%TYPE; 

  -- DECLARAÇÃO DE CURSORES
 
  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
 
  -- Cursor de lançamentos automáticos
  CURSOR cr_craplau (pr_cdcooper IN crapcop.cdcooper%TYPE,
                     pr_dtmovini IN craplau.dtmvtopg%TYPE,
                     pr_dtmvtopg IN crapdat.dtmvtolt%TYPE,
                     pr_lshistor IN VARCHAR2) IS
    SELECT lau.cdcooper
          ,lau.dtmvtolt
          ,lau.dtmvtopg
          ,lau.cdtiptra
          ,lau.vllanaut
          ,lau.dttransa
          ,lau.nrdocmto
          ,lau.dslindig
          ,lau.dsorigem
          ,lau.idseqttl
          ,lau.nrdconta
          ,lau.dscedent
          ,lau.hrtransa
          ,lau.cdhistor
          ,lau.cdempres
          ,lau.cdagenci
					,lau.cdcritic
					,lau.insitlau
          ,ROWID
          ,lau.progress_recid
    FROM  craplau lau
    WHERE lau.cdcooper  = pr_cdcooper
    AND   lau.dtmvtopg BETWEEN pr_dtmovini AND pr_dtmvtopg
		AND  ((lau.insitlau  = 1  AND
           lau.cdcritic  IN (717,964,967,1003)
          )    OR
		      (lau.insitlau  = 3     AND
          lau.cdcritic  = 967)
          )			
    AND   ',' || pr_lshistor || ',' LIKE ('%,' || lau.cdhistor || ',%'); -- Retorna historicos passados na listagem
    rw_craplau cr_craplau%ROWTYPE;

  -- Verificar se lançamento automático ja foi processado
  CURSOR cr_craplau_2 (pr_cdcooper IN crapcop.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE,
                       pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                       pr_cdhistor IN INTEGER,
                       pr_nrdocmto IN NUMBER,
                       pr_vllanaut IN NUMBER) IS
    SELECT lau.progress_recid
    FROM  craplau lau
    WHERE lau.cdcooper = pr_cdcooper
    AND   lau.nrdconta = pr_nrdconta
    AND   lau.dtmvtopg = pr_dtmvtolt
    AND   lau.cdhistor = pr_cdhistor
    AND   lau.nrdocmto = pr_nrdocmto
    AND   lau.insitlau <> 1
    AND   lau.dtdebito IS NOT NULL
    AND   lau.vllanaut = pr_vllanaut;
    rw_craplau_2 cr_craplau_2%ROWTYPE;

  -- BUSCA DOS DADOS DE LOTES
  CURSOR cr_craplot(pr_cdcooper IN crapcop.cdcooper%TYPE,
                    pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                    pr_cdagenci IN crapass.cdagenci%TYPE) IS
    SELECT lot.cdcooper,
           lot.cdagenci,
           lot.cdbccxlt,
           lot.dtmvtolt,
           lot.nrdolote,
           lot.qtcompln,
           lot.qtinfoln,
           lot.tplotmov,
           lot.vlcompcr,
           lot.vlcompdb,
           lot.vlinfocr,
           lot.vlinfodb,
           lot.nrseqdig,
           lot.cdbccxpg,
           lot.rowid
      FROM craplot lot
     WHERE lot.cdcooper = pr_cdcooper
	  	 AND lot.dtmvtolt = pr_dtmvtolt
		   AND lot.cdagenci = pr_cdagenci
			 AND lot.cdbccxlt = 100
			 AND lot.nrdolote = 6651
       FOR UPDATE NOWAIT;
  rw_craplot cr_craplot%ROWTYPE;

  -- BUSCA DADOS DE LANCAMENTOS
  CURSOR cr_craplcm(pr_cdcooper IN crapcop.cdcooper%TYPE,
                    pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                    pr_nrdconta IN craplcm.nrdconta%TYPE,
                    pr_nrdocmto IN craplcm.nrdocmto%TYPE,
                    pr_cdhistor IN craplcm.cdhistor%TYPE) IS
    SELECT lcm.nrdolote
      FROM craplcm lcm
     WHERE lcm.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
       AND lcm.nrdconta = pr_nrdconta  -- CONTA/DV
       AND lcm.dtmvtolt = pr_dtmvtolt  -- DATA DE MOVIMENTACAO
       AND lcm.cdhistor = pr_cdhistor  -- HISTORICO
       AND lcm.nrdocmto = pr_nrdocmto  -- NUMERO DO DOCUMENTO
       AND lcm.nrdolote = 6651;        -- NUMERO DO LOTE
  rw_craplcm cr_craplcm%ROWTYPE;
    
  CURSOR cr_crapatr(pr_cdcooper IN crapatr.cdcooper%TYPE,
                    pr_nrdconta IN crapatr.nrdconta%TYPE,
                    pr_cdhistor IN crapatr.cdhistor%TYPE,
                    pr_cdrefere IN crapatr.cdrefere%TYPE,
                    pr_nrdocmto IN crapatr.cdrefere%TYPE) IS
    SELECT atr.dtfimatr
          ,atr.cdrefere
          ,atr.dtultdeb
          ,atr.rowid
          ,atr.flgmaxdb
          ,atr.vlrmaxdb
          ,atr.cdempcon
          ,atr.cdsegmto
          ,atr.dshisext
      FROM crapatr atr
     WHERE atr.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
       AND atr.nrdconta = pr_nrdconta -- NUMERO DA CONTA
       AND atr.cdhistor = pr_cdhistor -- CODIGO DO HISTORICO
       AND atr.cdrefere IN( pr_cdrefere, pr_nrdocmto); -- COD. REFERENCIA
  rw_crapatr cr_crapatr%ROWTYPE;     
  
  CURSOR cr_crapcns (pr_cdcooper IN crapcop.cdcooper%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE) IS
   SELECT s.progress_recid
     FROM crapcns s
    WHERE s.cdcooper = pr_cdcooper
      AND s.nrdconta = pr_nrdconta;
   rw_crapcns cr_crapcns%ROWTYPE;

  /* Efetua consulta para listar todos os débitos automáticos dos convênios do Sicredi que não tiveram saldo no
   processo noturno anterior para realizar o lançamento do débito.
   Utiliza gravacao em tabelas para serem chamadas diretamente atraves de rotinas progress */
  PROCEDURE pc_consulta_convenios_wt(pr_cdcooper    IN crapcop.cdcooper%TYPE,     --> Cooperativa
                                     pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE,     --> Data do movimento
                                     pr_cdcritic   OUT PLS_INTEGER,     --> Codigo de Erro
                                     pr_dscritic   OUT VARCHAR2) IS               --> Descricao de Erro
      vr_lshistor VARCHAR2(1000);
    
    PROCEDURE pc_retorna_lista_historicos (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                           pr_lshistor OUT VARCHAR2) IS
                                           
      CURSOR cr_craphis (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT craphis.cdhistor FROM craphis, gnconve WHERE
        craphis.cdhistor = gnconve.cdhisdeb AND
        craphis.cdcooper = pr_cdcooper      AND
        craphis.inautori = 1                AND /*Debito Automatico*/
        gnconve.flgativo = 1;
    BEGIN
      pr_lshistor := '1019,1230,1231,1232,1233,1234';
      FOR vr_craphis IN cr_craphis (pr_cdcooper) LOOP
        pr_lshistor := pr_lshistor || ',' || to_char(vr_craphis.cdhistor);
      END LOOP;
    END pc_retorna_lista_historicos;

  BEGIN
    -- Limpa a tabela temporaria de interface       
    BEGIN
      DELETE wt_convenios_debitos;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao excluir wt_convenios_debitos: '||SQLERRM;
        RETURN;
    END;
    
    pc_retorna_lista_historicos (pr_cdcooper, vr_lshistor);

    -- Data anterior util
    vr_dtmovini := gene0005.fn_valida_dia_util(pr_cdcooper,
                                               (pr_dtmvtolt - 1), -- 1 dia anterior
                                               'A',    -- Anterior
                                               TRUE,   -- Feriado
                                               FALSE); -- Desconsiderar 31/12
    -- Adiciona mais um 1 dia na data inicial, para pegar finais de semana e feriados
    vr_dtmovini := vr_dtmovini + 1;

    -- Faz a busca dos registros na craplau
    FOR rw_craplau IN cr_craplau(pr_cdcooper => pr_cdcooper,
                                 pr_dtmovini => vr_dtmovini,
                                 pr_dtmvtopg => pr_dtmvtolt, 
                                 pr_lshistor => vr_lshistor) LOOP

      IF rw_craplau.cdhistor = 1019 THEN      
        SELECT crapscn.dsnomcnv INTO vr_nmempres 
          FROM crapscn
        WHERE crapscn.cdempres = rw_craplau.cdempres;        
        vr_cdempres := rw_craplau.cdempres;
        
      ELSIF rw_craplau.cdhistor IN(1230,1231,1232,1233,1234) THEN
        vr_cdempres := rw_craplau.cdempres;
        CASE rw_craplau.cdhistor
          WHEN 1230 THEN vr_nmempres:= 'CONSORCIO - MOTO';
          WHEN 1231 THEN vr_nmempres:= 'CONSORCIO - AUTO';
          WHEN 1232 THEN vr_nmempres:= 'CONSORCIO - PESADOS';
          WHEN 1233 THEN vr_nmempres:= 'CONSORCIO - IMOVEIS';
          WHEN 1234 THEN vr_nmempres:= 'CONSORCIO - SERVICOS';
        END CASE;         
      ELSE
        SELECT gnconve.nmempres, TO_CHAR(gnconve.cdconven) INTO vr_nmempres, vr_cdempres
          FROM gnconve
        WHERE gnconve.cdhisdeb = rw_craplau.cdhistor;
      END IF;

      -- criar registro na tabela wt_convenios que sera usada no progress
      BEGIN 
        INSERT INTO wt_convenios_debitos
          (cdcooper,
           cdagenci,
           nrdconta,
           dtmvtolt,
           cdhistor,
           vllanmto,
           nrdocmto,
           cdempres,
           nmempres,
					 insitlau,
					 cdcritic)
         VALUES
           (rw_craplau.cdcooper,
            rw_craplau.cdagenci,
            rw_craplau.nrdconta,
            rw_craplau.dtmvtopg,
            rw_craplau.cdhistor,
            rw_craplau.vllanaut,
            rw_craplau.nrdocmto,
            vr_cdempres,
            vr_nmempres,
						rw_craplau.insitlau,
						rw_craplau.cdcritic);
      EXCEPTION
        -- se ocorreu erro gera critica
        WHEN OTHERS THEN          
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao inserir na tabela wt_convenios_debitos: '||SQLERRM;            
          RETURN;
      END;  
            
    END LOOP;    
  -- COMMIT;
  END pc_consulta_convenios_wt;

  -- Criar lançamentos de debitos automaticos na tabela craplcm conforme dados buscados do progress da tela DEBCON
  PROCEDURE pc_cria_lancamentos_deb(pr_cdcooper IN crapcop.cdcooper%TYPE,     --> Cooperativa
                                    pr_dtmvtolt IN DATE,                      --> Data do movimento
                                    pr_cdhistor IN craplau.cdhistor%TYPE,     --> Codigo do historico
                                    pr_cdagenci IN crapass.cdagenci%TYPE,     --> Agencia PA
                                    pr_nrdconta IN crapass.nrdconta%TYPE,     --> conta/dv
                                    pr_vllanaut IN craplau.vllanaut%TYPE,     --> Valor lancamento
                                    pr_nrdocmto IN VARCHAR2,                  --> Documento
                                    pr_cdcritic OUT PLS_INTEGER,              --> Codigo de Erro
                                    pr_dscritic OUT VARCHAR2) IS              --> Descricao de Erro  
  /*---------------------------------------------------------------------------------------------------------------
   Programa : pc_cria_lancamentos_deb
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : 
   Data    :                        Ultima atualizacao: 18/10/2017
  
   Dados referentes ao programa:
  
   Frequencia: Sempre que chamado
   Objetivo  : Procedimento para realizar debito do debito automatico pela tela DEBCON
  
   Alteracoes: 12/07/2016 - Incluir criação do protocolo.
                            PRJ320 - Oferta DebAut (Odirlei-AMcom)
  
               27/07/2016 - Desabilitar temporariamente a criação do protocolo devido existir
                            diferença no tamanho do campo de protocolo entre  a tabela crappro e crapaut
                            acarretando erro ao atualizar tabela crapaut.
                            PRJ320 - Oferta Debaut (Odirlei-AMcom) 
  
               08/08/2016 - Ajustado para utilizar a data do parametro como data do agendamento do pagamento(craplau.dtmvtopg)
                            e buscar a data do movimento da cooperativa para geração do lote e lcm (Odirlei-AMcom)
                            
               06/09/2016 - Incluir tratamento para lock do lote (Lucas Ranghetti #518312)
               
               20/09/2016 - Alterar leitura da craplot para usar o rw_crapdat.dtmvtolt (Lucas Ranghetti/Fabricio #524588)
               
               11/10/2016 - Incluir valor do lancamento como parametro na verificacao da craplau (Lucas Ranghetti #537385)
               
               18/10/2017 - Ajustar rotina para debitar os consorcios tambem (Lucas Ranghetti #739738)
  --------------------------------------------------------------------------------------------------------------------*/ 
  
   ---------->>> CURSORES <<<--------
    --> Selecionar Informacoes Convenios
    CURSOR cr_crapcon (pr_cdcooper IN crapcon.cdcooper%type
                      ,pr_cdempcon IN crapcon.cdempcon%type
                      ,pr_cdsegmto IN crapcon.cdsegmto%type) IS
      SELECT crapcon.nmextcon,
             crapcon.nmrescon
        FROM crapcon
       WHERE crapcon.cdcooper = pr_cdcooper
         AND crapcon.cdempcon = pr_cdempcon
         AND crapcon.cdsegmto = pr_cdsegmto;
    rw_crapcon cr_crapcon%ROWTYPE;	
    
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    ---------->>> VARIAVEIS <<<--------
    vr_lau_dsorigem  craplau.dsorigem%TYPE;
    vr_lau_cdcoptfn  craplau.cdcoptfn%TYPE;
    vr_lau_cdagetfn  craplau.cdagetfn%TYPE;
    vr_lau_nrterfin  craplau.nrterfin%TYPE;
    vr_lau_nrcpfope  craplau.nrcpfope%TYPE;
    vr_lau_nrcpfpre  craplau.nrcpfpre%TYPE;
    vr_lau_nmprepos  craplau.nmprepos%TYPE;
    vr_lau_nrcrcard  craplau.nrcrcard%TYPE;
    
    -- Protocolo
    vr_dsinfor1  crappro.dsinform##1%TYPE;
    vr_dsinfor2  crappro.dsinform##1%TYPE;
    vr_dsinfor3  crappro.dsinform##1%TYPE;
    vr_dsprotoc  crappro.dsprotoc%TYPE;
    vr_nrdolote_sms NUMBER;
      
    -- Autenticação
    vr_dslitera  crapaut.dslitera%TYPE;
    vr_nrautdoc  crapaut.nrsequen%TYPE;
    vr_nrdrecid  ROWID;
    
  BEGIN                           
               
    --Verificar se o lancamento automatico existe
    OPEN cr_craplau_2 (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_dtmvtolt => pr_dtmvtolt,
                       pr_cdhistor => pr_cdhistor,
                       pr_nrdocmto => pr_nrdocmto,
                       pr_vllanaut => pr_vllanaut);
    FETCH cr_craplau_2 INTO rw_craplau_2;
    
    IF cr_craplau_2%FOUND THEN
      CLOSE cr_craplau_2;
      vr_cdcritic:= 0; --  Lancamento ja efetivado pela DEBNET/DEBSIC 
      vr_dscritic:= 'Lancamento ja efetivado pela DEBNET/DEBSIC/DEBCNS.'; 
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_craplau_2;
    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
                
    -- Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 5 seg.
    FOR i IN 1..50 LOOP
      BEGIN
        -- Leitura do lote
        OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                         pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                         pr_cdagenci  => pr_cdagenci);
        FETCH cr_craplot INTO rw_craplot;
        vr_dscritic := NULL;
        EXIT;
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_craplot%ISOPEN THEN
            CLOSE cr_craplot;
          END IF;
           
          -- setar critica caso for o ultimo
          IF i = 50 THEN
            vr_dscritic:= 'Registro de lote 6651 em uso. Tente novamente.';
          END IF;
          -- aguardar 0,1 seg. antes de tentar novamente
          sys.dbms_lock.sleep(0.1);
      END;
    END LOOP;
          
    -- se encontrou erro ao buscar lote, abortar programa
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- SE NÃO ENCONTRAR
    IF cr_craplot%NOTFOUND THEN
      -- FECHAR O CURSOR
      CLOSE cr_craplot;
      -- A primeira vez o sequencial do lote sera 0
      vr_nrseqdig := 0;
      -- CASO NAO ENCONTRE O LOTE, INSERE
      BEGIN
        INSERT INTO craplot
          (dtmvtolt,
           cdagenci,
           cdbccxlt,
           nrdolote,
           cdbccxpg,
           tplotmov,
           nrseqdig,
           cdcooper)
        VALUES
          (rw_crapdat.dtmvtolt,
           pr_cdagenci,
           100, -- cdbccxlt
           6651, -- nrdolote
           11, -- cdbccxpg
           1, -- tplotmov
           vr_nrseqdig,
           pr_cdcooper)
        RETURNING craplot.dtmvtolt,
                  craplot.cdagenci,
                  craplot.cdbccxlt,
                  craplot.nrdolote,
                  craplot.cdbccxpg,
                  craplot.tplotmov,
                  craplot.cdcooper,
                  craplot.nrseqdig,
                  craplot.rowid
           INTO   rw_craplot.dtmvtolt,
                  rw_craplot.cdagenci,
                  rw_craplot.cdbccxlt,
                  rw_craplot.nrdolote,
                  rw_craplot.cdbccxpg,
                  rw_craplot.tplotmov,
                  rw_craplot.cdcooper,
                  rw_craplot.nrseqdig,
                  rw_craplot.rowid;

      -- VERIFICA SE HOUVE PROBLEMA NA INSERCAO DE REGISTROS
      EXCEPTION
        WHEN OTHERS THEN
          -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
          vr_dscritic := 'Erro ao inserir na tabela craplot: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    ELSE
      -- FECHAR O CURSOR
      CLOSE cr_craplot;
      -- INCREMENTAR sequencial do lote
      vr_nrseqdig := rw_craplot.nrseqdig + 1;
      -- se ja existe lote INCREMENTAR sequencial
      BEGIN
        UPDATE craplot
          SET nrseqdig = vr_nrseqdig
          WHERE craplot.rowid = rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
          vr_dscritic := 'Erro ao atualizar a tabela craplot: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;    

    -- BUSCA REGISTRO REFERENTES A LOTES
    OPEN cr_craplcm(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => rw_crapdat.dtmvtolt,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrdocmto => pr_nrdocmto,
                    pr_cdhistor => pr_cdhistor);

    FETCH cr_craplcm INTO rw_craplcm;

    -- SE NÃO ENCONTRAR
    IF cr_craplcm%NOTFOUND THEN
      -- FECHAR O CURSOR
      CLOSE cr_craplcm;
      
      ---> Gerar autenticação do pagamento
      CXON0000.pc_grava_autenticacao_internet 
                        (pr_cooper       => pr_cdcooper
                        ,pr_nrdconta     => pr_nrdconta
                        ,pr_idseqttl     => 1            --Sequencial do titular
                        ,pr_cod_agencia  => rw_craplot.cdagenci --Codigo Agencia
                        ,pr_nro_caixa    => 900          --Numero do caixa
                        ,pr_cod_operador => 996          --Codigo Operador

                        ,pr_valor        => pr_vllanaut  --Valor da transacao
                        ,pr_docto        => pr_nrdocmto  --Numero documento
                        ,pr_operacao     => TRUE         --Indicador Operacao Debito
                        ,pr_status       => '1'          --Status da Operacao - Online
                        ,pr_estorno      => FALSE        --Indicador Estorno
                        ,pr_histor       => pr_cdhistor  --Historico Debito (Sicredi é 1019 pode passar fixo)

                        ,pr_data_off     => NULL         --Data Transacao
                        ,pr_sequen_off   => 0            --Sequencia
                        ,pr_hora_off     => 0            --Hora transacao
                        ,pr_seq_aut_off  => 0            --Sequencia automatica
                        ,pr_cdempres     => NULL         --Descricao Observacao

                        ,pr_literal      => vr_dslitera  --Descricao literal lcm
                        ,pr_sequencia    => vr_nrautdoc  --Sequencia
                        ,pr_registro     => vr_nrdrecid  --ROWID do registro debito
                        ,pr_cdcritic     => vr_cdcritic  --Código do erro
                        ,pr_dscritic     => vr_dscritic);--Descricao do erro
          
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro na autenticacao do pagamento: '||vr_dscritic;
        RAISE vr_exc_erro;
      END IF;  
      
      BEGIN
        INSERT INTO craplcm
            (cdcooper,
             dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdconta,
             nrdctabb,
             nrdocmto,
             cdhistor,
             vllanmto,
             nrseqdig,
             nrautdoc,
             cdpesqbb,
             hrtransa) -- Gravar a hora da transação em segundos
        VALUES
          (pr_cdcooper,
           rw_craplot.dtmvtolt,
           rw_craplot.cdagenci,  -- cdagenci
           rw_craplot.cdbccxlt,  -- cdbccxlt
           rw_craplot.nrdolote,  -- nrdolote           
           pr_nrdconta,
           pr_nrdconta, -- nrdctabb
           pr_nrdocmto,
           pr_cdhistor,
           pr_vllanaut,
           nvl(rw_craplot.nrseqdig,0) + 1,
           vr_nrautdoc,
           'Lote ' || TO_CHAR(pr_dtmvtolt, 'dd') || '/' ||
           TO_CHAR(pr_dtmvtolt, 'mm') || '-' ||
           to_char(gene0002.fn_mask(pr_cdagenci, '999')) || '-' ||
           to_char(gene0002.fn_mask(rw_craplot.cdbccxlt, '999')) || '-' ||
           to_char(gene0002.fn_mask(rw_craplot.nrdolote, '999999')) || '-' ||
           to_char(gene0002.fn_mask(rw_craplot.nrseqdig, '99999'))  || '-' ||
           to_char(pr_nrdocmto),
           to_char(SYSDATE,'sssss'));

      -- VERIFICA SE HOUVE PROBLEMA NA INCLUSÃO DO REGISTRO
      EXCEPTION
        WHEN OTHERS THEN
          -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
          vr_dscritic := 'Erro ao inserir na tabela craplcm: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      -- ATUALIZACAO DE REGISTROS DE LOTES
      BEGIN
        UPDATE craplot
           SET qtcompln = nvl(qtcompln,0) + 1,
               vlcompdb = nvl(vlcompdb,0) + nvl(pr_vllanaut,0),
               qtinfoln = nvl(qtinfoln,0) + 1,
               vlinfodb = nvl(vlinfodb,0) + nvl(pr_vllanaut,0),
               nrseqdig = nvl(nrseqdig,0) + 1
         WHERE craplot.rowid = rw_craplot.rowid;
      -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
      EXCEPTION
        WHEN OTHERS THEN
          -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
          vr_dscritic := 'Problema ao atualizar registro na tabela CRAPLOT: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      BEGIN
        -- ATUALIZA REGISTROS DE LANCAMENTOS AUTOMATICOS CONFORME PARAMETROS
        UPDATE craplau
           SET insitlau = 2,
               dtdebito = rw_craplot.dtmvtolt,
							 cdcritic = 0
         WHERE craplau.cdcooper  = pr_cdcooper AND
               craplau.dtmvtopg  = pr_dtmvtolt AND
              (craplau.insitlau  = 1           OR
							 craplau.insitlau  = 3         ) AND
               craplau.nrdconta  = pr_nrdconta AND
               to_char(craplau.nrdocmto) = pr_nrdocmto AND
               craplau.cdhistor = pr_cdhistor  AND 
               craplau.vllanaut = pr_vllanaut
         RETURNING craplau.dsorigem,
                   craplau.cdcoptfn,
                   craplau.cdagetfn,
                   craplau.nrterfin,
                   craplau.nrcpfope,
                   craplau.nrcpfpre,
                   craplau.nmprepos,
                   craplau.nrcrcard
              INTO vr_lau_dsorigem,
                   vr_lau_cdcoptfn,
                   vr_lau_cdagetfn,
                   vr_lau_nrterfin,
                   vr_lau_nrcpfope,
                   vr_lau_nrcpfpre,
                   vr_lau_nmprepos,
                   vr_lau_nrcrcard;

        -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela craplau: '||SQLERRM;
          RAISE vr_exc_erro;
      END;  -- fim do update craplau
      
      IF pr_cdhistor NOT IN (1230,1231,1232,1233,1234) THEN
        -- Atualiza data do último débito da autorização
        OPEN cr_crapatr(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_cdhistor => pr_cdhistor,                       
                        pr_cdrefere => nvl(vr_lau_nrcrcard,0),
                        pr_nrdocmto => pr_nrdocmto);
        FETCH cr_crapatr INTO rw_crapatr;

        IF cr_crapatr%NOTFOUND THEN
          -- FECHAR O CURSOR
          CLOSE cr_crapatr;
          -- retorna erro para procedure chamadora
          vr_dscritic := 'Autorizacao de debito nao encontrada.';
          RAISE vr_exc_erro;
        ELSE
          -- FECHAR O CURSOR
          CLOSE cr_crapatr;

          -- VERIFICA DATA DO ULTIMO DEBITO
          IF NVL(to_char(rw_crapatr.dtultdeb,'MMYYYY'),'0') <> to_char(rw_craplot.dtmvtolt,'MMYYYY') THEN          BEGIN
              -- ATUALIZA CADASTRO DAS AUTORIZACOES DE DEBITO EM CONTA
              UPDATE crapatr
                 SET dtultdeb = rw_craplot.dtmvtolt -- ATUALIZA DATA DO ULTIMO DEBITO
               WHERE ROWID = rw_crapatr.rowid;
            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZAÇÃO DO REGISTRO
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao atualizar registro na tabela CRAPATR: ' || sqlerrm;
                RAISE vr_exc_erro;
            END;
          END IF;
          
          /* TEMPORARIAMENTE NÃO SERÁ GERADO PROTOCOLO para os pr_nrdocmto > 15
               DEVIDO EXISTIR DIFERENÇA NO TAMANHO DO CAMPO DE PROTOCOLO ENTRE A TABELA CRAPPRO E CRAPAUT
          */
          -- Para historicos de consorcio, não deve gerar também, contem 20 posições o documento
          IF length(pr_nrdocmto) <= 15 THEN
            rw_crapcon := NULL;
            --> Buscar o nome do convenio
            OPEN cr_crapcon (pr_cdcooper => pr_cdcooper
                            ,pr_cdempcon => rw_crapatr.cdempcon
                            ,pr_cdsegmto => rw_crapatr.cdsegmto);
            --Posicionar no proximo registro
            FETCH cr_crapcon INTO rw_crapcon;                  
            CLOSE cr_crapcon; 
            
            -- GERAR PROTOCOLO
            -->Campos gravados na crappro para visualizacao na internet
            vr_dsinfor1 := 'Pagamento';
            vr_dsinfor2 := ' ';
            vr_dsinfor3 := 'Convênio: '||rw_crapcon.nmextcon||
                           '#Número Identificador:'||rw_crapatr.cdrefere ||'#'|| rw_crapatr.dshisext;

            --> Se TAA 
            IF vr_lau_dsorigem = 'TAA' THEN
              vr_dsinfor3:= vr_dsinfor3 ||'#TAA: '||gene0002.fn_mask(vr_lau_cdcoptfn,'9999')||'/'||
                                                    gene0002.fn_mask(vr_lau_cdagetfn,'9999')||'/'||
                                                    gene0002.fn_mask(vr_lau_nrterfin,'9999');
            END IF;
            --> Gera um protocolo para o pagamento
            GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper          --> Código da cooperativa
                                      ,pr_dtmvtolt => rw_craplot.dtmvtolt  --> Data movimento
                                      ,pr_hrtransa => gene0002.fn_busca_time --> Hora da transação
                                      ,pr_nrdconta => pr_nrdconta          --> Número da conta
                                      ,pr_nrdocmto => pr_nrdocmto          --> Número do documento
                                      ,pr_nrseqaut => vr_nrautdoc          --> Número da sequencia
                                      ,pr_vllanmto => pr_vllanaut          --> Valor lançamento
                                      ,pr_nrdcaixa => 900                  --> Número do caixa
                                      ,pr_gravapro => TRUE                 --> Controle de gravação do crappro
                                      ,pr_cdtippro => 15 -- convenio       --> Código do tipo protocolo
                                      ,pr_dsinfor1 => vr_dsinfor1          --> Descrição 1
                                      ,pr_dsinfor2 => vr_dsinfor2          --> Descrição 2
                                      ,pr_dsinfor3 => vr_dsinfor3          --> Descrição 3
                                      ,pr_dscedent => rw_crapcon.nmextcon  --> Descritivo Cedente
                                      ,pr_flgagend => FALSE                --> Controle de agenda
                                      ,pr_nrcpfope => vr_lau_nrcpfope      --> Número de operação
                                      ,pr_nrcpfpre => vr_lau_nrcpfpre      --> Número pré operação
                                      ,pr_nmprepos => vr_lau_nmprepos      --> Nome
                                      ,pr_dsprotoc => vr_dsprotoc          --> Descrição do protocolo
                                      ,pr_dscritic => vr_dscritic          --> Descrição crítica
                                      ,pr_des_erro => vr_des_erro);        --> Descrição dos erros de processo
            --Se ocorreu erro
            IF vr_dscritic IS NOT NULL OR vr_des_erro IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
                  
            --> Armazena protocolo na autenticacao 
            BEGIN
              UPDATE crapaut 
                 SET crapaut.dsprotoc = vr_dsprotoc
               WHERE crapaut.ROWID = vr_nrdrecid;
            EXCEPTION
              WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar registro da autenticacao. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END;                
          END IF;
        END IF;
      ELSE -- Consorcios
      
         -- Validar se existe conta consorcio
         OPEN cr_crapcns(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
         FETCH cr_crapcns INTO rw_crapcns;        
         
         IF cr_crapcns%NOTFOUND THEN
          -- FECHAR O CURSOR
          CLOSE cr_crapcns;
          -- retorna erro para procedure chamadora
          vr_dscritic := 'Conta consorcio nao cadastrada.';
          RAISE vr_exc_erro;
        ELSE
          -- FECHAR O CURSOR
          CLOSE cr_crapcns;
        END IF;
      END IF;
    ELSE
      -- FECHAR O CURSOR DA CRAPLCM
      CLOSE cr_craplcm;
    END IF; -- fim do notfound craplcm
    
    -- Gravar as informações no banco
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
       ROLLBACK;
       pr_cdcritic := nvl(vr_cdcritic,0);
       pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      ROLLBACK;
      -- Retorna o erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado em sicr0002.pc_cria_lancamentos_debitos --> '||SQLERRM;

  END pc_cria_lancamentos_deb;

END sicr0002;
/
