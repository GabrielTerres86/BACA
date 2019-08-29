CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS674
                          ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                           ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                           ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                           ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                           ,pr_cdoperad IN crapnrc.cdoperad%TYPE   --> Código do operador
                           ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                           ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN

/* ..........................................................................

       Programa: pc_crps674
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Lucas Lunelli
       Data    : Março/2014.                     Ultima atualizacao: 12/04/2018

       Dados referentes ao programa:

       Frequencia: Diário.
       Objetivo  : Atende a solicitacao 40, Ordem 1.
                   Lançamentos de Débitos Automáticos (Bancoob/CABAL).

       Alteracoes: 
                   04/09/2014 - Alterar para buscar pela data em que o documento 
                                deve ser pago conforme ServiceDesk 197249 ( Renato - Supero )
                                Também foi alterado a regra para buscar os registros
                                desde o próximo dia do ultimo processo até o dia em 
                                questão. Isso foi feito para que registros que tenham
                                data de pagamento para sabado ou domingo, por exemplo,
                                ou feriados, sejam também processados pelo programa.
																
                   11/09/2014 - Atualiza registro de Lançamento Automático para 
                                        'Não efetivado' em caso da falta de saldo por parte
                                                      do cooperado (Lucas Lunelli)
                                
                   23/09/2014 - Alterar o craplot.tplotmov (de 17 para 1) quando o lote 
                                for criado. Desta forma, com tipo de lote 1, os relatórios 
                                em questão considerarão este movimento. (Renato - Supero)
                                
                  12/01/2014 - Criação do relatório  com os cartões que estavam com lançamentos 
                               de débito automático da fatura (total e mínimo) programados na 
                               Lautom e que não foram debitados devido a saldo insuficiente no
                               momento da tentativa de débito SD236429 (Vanessa)
						      
                  26/02/2014 - Correção para gerar o .lst ao invés do .pdf (Vanessa)
                  
                  02/03/2014 - Ajuste no cursor cr_crawcrd -> crd.tpdpagto: 1 - 'Debito CC Total'
                               2 - 'Debito CC Minimo' e  3 - 'Boleto' (Vanessa).
                               
                  16/04/2015 - Retirado valores bloqueados do saldo disponível
                               (Lucas Ranghetti #276097)
                               
                  23/04/2015 - Ajustada chamada da pc_obtem_saldo_dia, para melhorar
                               performace (Odirlei-AMcom)   
                  12/04/2018 - Incluido a chamada do programa ccrd0003.pc_debita_fatura 
                               passando como parametro o nome do programa 'REPIQUE', 
                               Esse programa será chamado pelo debitador, não sendo mais chamado
                               pelo JOB e nem na cadeia noturna.
                               Projeto Debitador Único Josiane Stiehler (AMcom)          
    ............................................................................ */

    DECLARE
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------

      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS674';       --> Código do programa
      vr_dsdireto   VARCHAR2(200);                                     --> Caminho
      vr_dsdirarq   VARCHAR2(200);                                     --> Caminho e nome do arquivo      
      vr_dsdireto_rlnsv  VARCHAR2(200);                                --> Caminho /rlnsv
     
      vr_tab_sald   EXTR0001.typ_tab_saldos;                           --> Temp-Table com o saldo do dia
      vr_ind_sald   PLS_INTEGER;                                       --> Indice sobre a temp-table vr_tab_sald
      vr_vlsddisp   NUMBER(17,2);                                      --> Valor de saldo disponivel			
      vr_idxrel     INTEGER DEFAULT 0;  
      
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);  
	    vr_des_erro   VARCHAR2(4000);
      vr_tab_erro   GENE0001.typ_tab_erro; 
     
      
      -- Variáveis locais do bloco
      vr_xml_clobxml       CLOB;
      vr_xml_des_erro      VARCHAR2(4000);
      
      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper				      
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
     
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
						
      -- cursor para retornar lançamentos automáticos
      CURSOR cr_craplau (pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                         pr_dtmvtoan IN crapdat.dtmvtoan%TYPE) IS
      SELECT lau.cdcooper
            ,lau.dtmvtolt
            ,ass.cdagenci
            ,lau.cdbccxlt
            ,lau.nrdolote
            ,lau.nrdctabb
            ,lau.nrdocmto
            ,lau.vllanaut
            ,lau.dtmvtopg
            ,lau.nrdconta
            ,lau.cdhistor
            ,lau.nrseqdig
            ,lau.dsorigem
            ,lau.nrcrcard
            ,lau.insitlau
            ,lau.nrseqlan
            ,lau.ROWID
            ,ass.vllimcre
            ,ass.nmprimtl
            ,ass.inpessoa
      
        FROM craplau lau
            ,crapass ass
       WHERE lau.cdcooper = pr_cdcooper AND
           -- Alterar para buscar pela data em que o documento deve ser pago ( Renato - Supero - SD 197249 )
           --   A regra foi alterada e deverá ser validado esta situação. Mais informações nos comentários gerais da rotina.
                 -- lau.dtmvtolt = pr_dtmvtolt             AND	--	****  Regra antiga  ****
          (lau.dtmvtopg BETWEEN (pr_dtmvtoan + 1) AND pr_dtmvtolt) AND 
                       lau.insitlau = 1                       AND   
                       lau.nrdolote = 6900                    AND
                       lau.dsorigem = 'DAUT BANCOOB'          AND
                       ass.cdcooper = lau.cdcooper            AND
                       ass.nrdconta = lau.nrdconta            AND
                       ass.dtelimin IS NULL  
        ORDER BY lau.cdcooper			      
				,ass.cdagenci
                ,lau.nrdconta;
      rw_craplau cr_craplau%ROWTYPE;
			
			-- cursor para verificar a existência de lote
      CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE,
			                   pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS			
      SELECT lot.nrseqdig
            ,lot.qtcompln
            ,lot.qtinfoln
            ,lot.vlcompdb
            ,lot.ROWID
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = 1
         AND lot.cdbccxlt = 100
         AND lot.nrdolote = 6901;
			rw_craplot cr_craplot%ROWTYPE;

      -- cursor para verificar as informações do relatorio
      CURSOR cr_crawcrd (pr_cdcooper IN crapcop.cdcooper%TYPE,
			                   pr_nrdconta IN crawcrd.nrdconta%TYPE,
                         pr_nrcrcard IN crawcrd.nrcrcard%TYPE,
                         pr_inpessoa IN crapass.inpessoa%TYPE) IS	
                         	 
        SELECT crd.cdcooper,
         crd.nrdconta,
         crd.cdadmcrd,
         LPAD(adc.nmresadm,30,' ') AS nmadmcrd,   
         crd.tpdpagto,
         CASE crd.tpdpagto
           WHEN 1 THEN 'Debito CC Total'
           WHEN 2 THEN 'Debito CC Minimo'
           WHEN 3 THEN 'Boleto'
         END AS dsformpg,      
         --LISTAGG('(' || lpad(tfc.nrdddtfc,2,0) || ')' || TO_CHAR(tfc.nrtelefo) || ' ') WITHIN GROUP (ORDER BY tfc.cdcooper,tfc.nrdconta) as nrtelefo
         '(' || lpad(tfc.nrdddtfc,2,0) || ')' || TO_CHAR(tfc.nrtelefo) AS nrtelefo      
        FROM crawcrd crd, 
             craptfc tfc,
             crapadc adc
        WHERE crd.cdcooper = tfc.cdcooper
          AND crd.nrdconta = tfc.nrdconta
          AND crd.cdcooper = adc.cdcooper
          AND crd.cdadmcrd = adc.cdadmcrd
          AND crd.cdcooper = pr_cdcooper 
          AND crd.nrdconta = pr_nrdconta
          
          AND TO_CHAR(crd.nrcctitg) = TO_CHAR(pr_nrcrcard)
                       
         ORDER BY  CASE pr_inpessoa
           WHEN 1 THEN  Row_Number() over(order by tfc.tptelefo ASC)
           WHEN 2 THEN  Row_Number() over(order by tfc.tptelefo DESC)
           ELSE Row_Number() over(order by tfc.tptelefo ASC)
         END  ;    
      rw_crawcrd cr_crawcrd%ROWTYPE;
      
      -- cursor para retornar lançamentos automáticos não efetuados
      CURSOR cr_craplau_naoefetuados (pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
       SELECT lau.cdcooper
             ,ass.cdagenci
             ,lau.nrdconta
             ,lau.nrdctabb
             ,lau.nrdocmto
             ,lau.vllanaut
             ,lau.dslindig AS vlsddisp
             ,lau.nrcrcard
             ,ass.nmprimtl
             ,ass.inpessoa
             ,ass.vllimcre
       
         FROM craplau lau
             ,crapass ass
        WHERE lau.dtdebito = pr_dtmvtolt
          AND lau.insitlau = 4
          AND lau.nrdolote = 6900
          AND lau.dsorigem = 'DAUT BANCOOB'
          AND ass.cdcooper = lau.cdcooper
          AND ass.nrdconta = lau.nrdconta
          AND ass.dtdemiss IS NULL
        ORDER BY lau.cdcooper
                ,ass.cdagenci
                ,lau.nrdconta;
			rw_craplau_naoefetuados cr_craplau_naoefetuados%ROWTYPE;
      
      --temptable para armazenar informações para o relatorio
      TYPE typ_tab_reg_relat is record
          (cdcooper crapcop.cdcooper%TYPE,
           cdagenci crapage.cdagenci%TYPE,
           nrdconta crapsda.nrdconta%TYPE,
           nrdctabb craplau.nrdctabb%TYPE,
           nrdocmto craplau.nrdocmto%TYPE,
           nmprimtl crapass.nmprimtl%TYPE,
           cdadmcrd crapadc.cdadmcrd%TYPE,
           nmadmcrd crapadc.nmadmcrd%TYPE,
           dsformpg varchar(250),
           vllanaut rw_craplau.vllanaut%TYPE,   
           vlsddisp crapsda.vlsddisp%TYPE,
           vllimcre crapass.vllimcre%TYPE,
           nrtelefo varchar(400) 
           );

      TYPE typ_tab_relat IS
       TABLE OF typ_tab_reg_relat
       INDEX BY PLS_INTEGER; 
      vr_tab_relat typ_tab_relat;
       
       -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        -- ESCREVE DADOS NA VARIAVEL vr_clobxml QUE IRA CONTER OS DADOS DO XML
        dbms_lob.writeappend(vr_xml_clobxml, length(pr_des_dados), pr_des_dados);
      END;
        
    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se nao encontrar
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
			         
      -- Validacoes iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel nao for 0
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      vr_cdcritic := 0;
      vr_dscritic := NULL;

      IF pr_cdcooper <> 3 THEN

         -- Chama a rotina de debito de fatura - Repique
         -- Projeto debitador único 
         ccrd0003.pc_debita_fatura(pr_cdcooper => pr_cdcooper,
                                   pr_cdprogra => 'REPIQUE',
                                   pr_cdoperad => 1,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_fatrowid => NULL,
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic);
                                         
         IF vr_cdcritic > 0 OR
            vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
         END IF;

         ccrd0003.pc_debita_fatura(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_fatrowid => NULL -- pegar todas
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
                                   
         IF vr_cdcritic > 0 OR
            vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
         END IF;    

         ccrd0003.pc_rel_nao_efetuados(pr_cdcooper => pr_cdcooper
                                      ,pr_cdprogra => vr_cdprogra
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt                                    
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);                            

         IF vr_cdcritic > 0 OR
            vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
         END IF;   
                 
         
      END IF;    
      

      
      -- Processo OK, devemos chamar a fimprg
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

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                      || vr_cdprogra || ' --> '
                                                                      || vr_dscritic );
        END IF;
											
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

        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

     WHEN OTHERS THEN

        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina PC_CRPS674: '|| sqlerrm;
        -- Efetuar rollback
        ROLLBACK;

    END;    
		
END PC_CRPS674;
/
