/*
!!!!!!ATENCAO!!!!! Quando incluir um novo numero de lote, inclui-lo tambem
na procedure critica_numero_lote da BO sistema/generico/procedures/b1wgen9999.p
 .............................................................................

   Programa: Includes/critica_numero_lote.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Outubro/2003.                   Ultima atualizacao:  30/08/2017
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criticar numeros de lotes na criacao do lote.

   Alteracoes:  13/11/2006 - Incluido lote 8008(Mirtes)
   
                02/10/2009 - Aumento na numeracao dos lotes: 3200 e 3300 
                             (Diego).
                             
                23/03/2011 - Incluido lote 10115 (Adriano).
                
                31/01/2012 - Reservar faixa de lote para novo empréstimo (Oscar).
                
                30/05/2014 - Incluir nrdolote = 6651 - Softdesk 147220 
                             (Lucas R.)
                             
                21/07/2014 - Incluido lote 50001, 50002 e 50003. (James).
                
				11/08/2014 - Incluido lotes:
                             * 8500: Credito de nova aplicacao
                             * 8501: Debito de nova aplicacao
                             * 8502: Debito de resgate de aplicacao
                             * 8503: Credito de resgate de aplicacao
                             * 8504: Debito de vencimento de aplicacao
                             * 8505: Credito de vencimento de aplicacao
                             * 8506: Credito de provisao de aplicacao.
                             (Reinert)

                25/08/2014 - Incluir lote 6650 para que chame a critica 261
                             (Daniele).
                             
                01/10/2014 - Incluir novo lote 6400 (Lucas R. - #205006)
                
                20/02/2015 - Incluido lote 7050.
                             (Chamado 229249 # PRJ Melhoria) - (Fabricio)
							 
                17/08/2016 - Incluir lote 10119 - Melhoria 69 (Lucas Ranghetti #484923)							 
							
                26/09/2016 - Incluir lotes da M211 para nao exclusao (Jonata-RKAM)
                
                13/01/2016 - Incluir lotes 44000 estorno TED analise de fraude.
                             PRJ335 - Analise de fraudes (Odirlei-AMcom)

                18/07/2017 - Incluir o lote 650003 e 650004. (Jaison/James - PRJ298)

				30/08/2017 - Ajuste para incluir o lote 7600
					         (Adriano - SD 746815).
............................................................................. */

IF  ({1}nrdolote > 1350   AND       /* CMC-7 e Codigo de Barras */
     {1}nrdolote < 1450)  OR
     {1}nrdolote = 2701   OR        /* Reajuste do limite de credito */
    ({1}nrdolote > 320000 AND       /* Cash Dispenser */
     {1}nrdolote < 330000) OR
    ({1}nrdolote > 3200   AND       /* Cash Dispenser */
     {1}nrdolote < 3300)  OR
     {1}nrdolote = 4154   OR        /* Lote de debito de seguro de vida */
     {1}nrdolote = 4500   OR        /* Lote de liberacao de custodia  */
     {1}nrdolote = 4501   OR        /* Lote de liberacao de cheq. descontos  */
     {1}nrdolote = 4600   OR        /* Lote de liberacao de titulos  */
     {1}nrdolote = 4650   OR        /* Lote de devolucao de cheques  */
    ({1}nrdolote > 5010   AND
     {1}nrdolote < 6000)  OR        /* Creditos de emprestimos */
    ({1}nrdolote > 6599   AND       /* Integracao telesc/samae/etc  */
     {1}nrdolote < 6626)  OR        
     {1}nrdolote = 7000   OR        /* Transferencia de conta-corrente */
    ({1}nrdolote > 7000   AND       /* Compensacao do Banco do Brasil */
     {1}nrdolote < 7010)  OR
    ({1}nrdolote > 7010   AND       /* Compensacao Bancoob */
     {1}nrdolote < 7020)  OR
    ({1}nrdolote > 7020   AND       /* Compensacao Caixa */
     {1}nrdolote < 7030)  OR
    ({1}nrdolote > 7099   AND       /* Transf. de cheque salario p/vala */
     {1}nrdolote < 7200)  OR
     {1}nrdolote = 7200   OR        /* Baixa de saldo de c/c dos demitidos */
	 {1}nrdolote = 7600   OR        /* Lote devolucao contra-ordem */
     {1}nrdolote = 8001   OR        /* Capital Inicial */
     {1}nrdolote = 8002   OR        /* Transferencia de capital */
     {1}nrdolote = 8003   OR        /* Correcao monetaria */
     {1}nrdolote = 8004   OR        /* Credito de juros sobre capital */
     {1}nrdolote = 8005   OR        /* Para credito de RETORNO E CMI */
     {1}nrdolote = 8006   OR        /* Baixa de saldo de capital dos dem. */
     {1}nrdolote = 8007   OR        /* Ajuste de C.M. na final do trimestre */
     {1}nrdolote = 8008   OR        /* Transferencia de Conta(TELA TRANSF)*/
     {1}nrdolote = 8350   OR        /* Sobras de emprestimos */
     {1}nrdolote = 8351   OR        /* Sobras de emprestimos no c/c */
     {1}nrdolote = 8360   OR        /* Juros de emprestimos */
     {1}nrdolote = 8361   OR        /* Juros sobre prejuizos */
     {1}nrdolote = 8370   OR        /* Abono de emprestimos */
     {1}nrdolote = 8380   OR        /* Rendimento de Aplicacoes RDCA */
     {1}nrdolote = 8381   OR        /* Rendimento Ref Resgates RDCA */
     {1}nrdolote = 8382   OR        /* Rendimento Ref Resgates RDCA */
     {1}nrdolote = 8383   OR        /* Provisao Mensal de Rendim. RPP */
     {1}nrdolote = 8384   OR        /* Rendimento e credito no RPP */
     {1}nrdolote = 8390   OR        /* Resgate de Aplicacoes RDCA */
     {1}nrdolote = 8391   OR        /* Perdas nos Resgates RDCA  */
     {1}nrdolote = 8450   OR        /* Multa e juros de conta-corrente */
     {1}nrdolote = 8451   OR        /* Devolucoes automat. por contra-ordem */
     {1}nrdolote = 8452   OR        /* Tarifas  */
     {1}nrdolote = 8453   OR        /* Liquidacao de Emprestimos */
     {1}nrdolote = 8454   OR        /* Debito de plano em conta-corrente */
     {1}nrdolote = 8455   OR        /* Credito de planos de capital */
     {1}nrdolote = 8456   OR        /* C/C Cr. emp. e Db. liquidacao */
     {1}nrdolote = 8457   OR        /* C/C Db. Prest. Emprestimo */
     {1}nrdolote = 8458   OR        /* C/C Deb. Plano saude Bradesco Hering */
     {1}nrdolote = 8459   OR        /* Debitos Credicard */
     {1}nrdolote = 8460   OR        /* I.P.M.F. */
     {1}nrdolote = 8461   OR        /* Abono C.P.M.F */
     {1}nrdolote = 8462   OR        /* Debito em conta de convenios */
     {1}nrdolote = 8463   OR        /* Lancamentos de cobranca */
     {1}nrdolote = 8464   OR        /* Credito capital ref debito em conta */
     {1}nrdolote = 8470   OR        /* Debitos ref. Aplicacoes Financeiras */
     {1}nrdolote = 8473   OR        /* Debitos ref.Aplic. RDCA e RPP */
     {1}nrdolote = 8474   OR        /* Creditos ref.Aplic. RDCA e RPP */
     {1}nrdolote = 8475   OR        /* Transf. emprestimos para conta adm  */
     {1}nrdolote = 8476   OR        /* Base CPMF cobertura de saldo devedor */
     {1}nrdolote = 8477   OR        /* Para credito de desconto de cheques  */
    ({1}nrdolote > 8010   AND       /* Creditos de planos de capital */
     {1}nrdolote < 8999)  OR
    ({1}nrdolote > 600000  AND      /* Novo empréstimo */
     {1}nrdolote < 650000) OR       /* Novo empréstimo */
     {1}nrdolote > 9010   OR        /* Creditos de pagamento */
     {1}nrdolote = 10115  OR        /* Cadastramento das devoluções de TED's */
     {1}nrdolote = 50001  OR        /* Crédito no valor contratado em conta */
     {1}nrdolote = 50002  OR        /* IOF credito pre-aprovado */
     {1}nrdolote = 50003  OR        /* Tarifa do pre-aprovado */
     {1}nrdolote = 6651   OR        /* Debitos que nao foram efetuados no proc. not.*/
     {1}nrdolote = 6650   OR        /* Numero do lote reservado para o sistema.*/
     {1}nrdolote = 6400   OR        /* Agendamento de debito automatico */
	 {1}nrdolote = 8500   OR        /* Crédito de nova aplicação            */
     {1}nrdolote = 8501   OR        /* Débito de nova aplicação             */
     {1}nrdolote = 8502   OR        /* Débito de resgate de aplicação       */
     {1}nrdolote = 8503   OR        /* Crédito de resgate de aplicação      */
     {1}nrdolote = 8504   OR        /* Débito de vencimento de aplicação    */
     {1}nrdolote = 8505   OR        /* Crédito de vencimento de aplicação   */
     {1}nrdolote = 8506   OR        /* Crédito de provisão de aplicação     */
     {1}nrdolote = 6651   OR   /*Debitos nao efetuados no processo noturno (e efetuados pela DEBCON)*/
     {1}nrdolote = 7050   OR   /*Debitos automaticos nao efetuados no processo noturno (apenas convenios CECRED; efetuados pela DEBNET).*/
	 {1}nrdolote = 650001 OR		/* Acordos do CYBER */
	 {1}nrdolote = 650002 OR		/* Acordos do CYBER */
	 {1}nrdolote = 10119  OR   /* Lote devolução - Melhoria 69 */ 
     {1}nrdolote = 44000  OR   /* Lote Estorno TED analise de fraude */    
	 ({1}nrdolote >= 8482  AND      /* TEDS Sicredi */
     {1}nrdolote <= 8486) OR
     {1}nrdolote = 650003 OR        /* Pagamento de contrato do Price Pos-Fixado */
     {1}nrdolote = 650004 THEN      /* Pagamento de contrato do Price Pos-Fixado */
	 
	 
     glb_cdcritic = 261.

