/*..............................................................................

    Programa: Fontes/crps264.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Elton/Ze Eduardo
    Data    : Marco/07.                       Ultima atualizacao: 09/07/2019 
    
    Dados referentes ao programa:

    Frequencia: Diario (Batch).
    Objetivo  : Atende a solicitacao 78.
                Efetuar o lote de devolucoes e taxas de devolucoes para contra-
                ordem e gerar arquivo de devolucoes.
                Relatorio 219.

    Alteracoes: 22/05/2007 - Nao gera arquivo para BANCOOB quando nao houverem
                             devolucoes de cheques (Elton).
                             
                28/05/2007 - Acerto na selecao do relatorio de devolucao (Ze).
                
                18/06/2007 - Acerto na geracao do arquivo do Bancoob e 
                             Listagem (Ze).
                             
                31/07/2007 - Adicionado tipo de conta ao relatorio (Guilherme).
                
                20/08/2007 - Acerto para o BANCOOB, Desconto e Custodia (Ze).
                
                24/09/2007 - Acerto para Desconto de Cheques e Custodia (Ze).
                
                07/03/2008 - Tratar cheque BANCOOB lancado por fora(landpv) (Ze)
                
                01/09/2008 - Alteracao CDEMPRES (Kbase).
                
                           - Mostrar mensagem com um contador de registros
                             para maior interacao com o usuario e na procedure
                             gera_lancamento alterar o 'RETURN' para 'UNDO 
                             TRANS_1, RETURN' (Gabriel).
                             
                11/12/2008 - Incluir o CriaPDF para o rel. 219 (Ze).
                
                21/01/2009 - Verifica se possui registros com lock antes
                             de executar a devolucao (Ze).
                             
                27/04/2009 - Definir bloco de Transacao e remove CONTACONVE
                             nao mais utilizada (Ze).
                             
                30/09/2009 - Adaptacoes projeto IF CECRED (Guilherme).
                
                26/11/2009 - Inclusao de tratamento para Devolucoes banco CECRED
                             de Compe (Guilherme/Precise)

                12/01/2010 - Inclusao do codigo 573 no CAN-DO do 338
                             (Guilherme/Precise)
                             
                06/08/2010 - Acertos para devolucao CECRED (Ze).
                             
                23/08/2010 - Alterar parametro de selecao de Cheques Cecred (Ze)

                21/09/2010 - Acerto na selecao dos reg. 085 (Ze).
                
                04/10/2010 - Identificar quando lancamento foi enviado para
                             ABBC na 1a ou 2a Devolucao (Ze).
                             
                25/10/2010 - Ajuste no relatorio crrl219 - Compe ABBC (Ze).

                19/11/2010 - Ajuste no relatorio crrl219 - Inclusao coluna
                             Noturna/Diurna (Guilherme/Supero).
                             
                11/01/2011 - Ajuste para a Migracao do PAC VIACREDI (Ze).
                
                08/02/2011 - Ajuste para incluir no arquivo 085 cheques
                             cancelados, talonario nao retirado,... (Ze).

                18/04/2011 - Alterado layout de relatório quando for 
                             Cheques Cecred (Isara - RKAM).
                             
                19/04/2011 - Acerto para incluir os cheques rejeitados na
                             integracao da Compe no arquivo Cecred (Ze).
                             
                27/05/2011 - Incluir CriaPDF no rel. 219 da 085 e incluir o
                             campo dstipcta no rel. 219_4 e 219_5 (Magui/Ze).
                             
                30/05/2011 - Ajuste para criar 219_4, 219_5 nas coops singulares,
                             utilizar o imprim_unif 
                           - Ajuste layout relatorio 219_4, 219_5 (Guilherme).
                           
                10/06/2011 - Realizado verificao em locked quando for criado
                             o craplcm e o crapavs (Adriano). 
                             
                15/07/2011 - Ajuste para dev. das contas transferidas (Ze).
                
                05/04/2012 - Tratado na procedure gera_arquivo_cecred
                             os registros com crapdev.nrdconta = 0;
                             (cdcritic = 9 ou 108).
                             Criado esses registros no relatorio 219 como
                             "Rejeitado". (Fabricio)
                        
                18/06/2012 - Alteracao na leitura da craptco (David Kruger).
                
                15/08/2012 - Alterado posições do cdtipchq de 52,2 para 148,3 
                            (Lucas R.).
                            
                27/08/2012 - Removido parametro p-flghrexe e adicionado os
                             codigos de devolucao 5 e 6, ao parametro 
                             p-cddevolu. Ambos, devolucao CECRED. (Fabricio)
                
                28/08/2012 - Tratamento campo crapcop.nmrescop "x(20)" (Diego).
                
                06/09/2012 - Realizado tratamento para devolucao VLB nas
                             procedures gera_lancamento e gera_arquivo_cecred.
                             Criada a procedure envia_mensagem_spb, para as
                             devolucoes VLB. (Fabricio)
                             
                20/12/2012 - Adaptacao para a Migracao AltoVale (Ze).
                
                17/01/2013 - Enviar email para 
                             juliana.carla@viacredialtovale.coop.br quando
                             for devolucao 085 e cdcooper = 1. (Fabricio)
                             
                20/02/2013 - Ajuste no gncpchq para TCO - Trf. 41667 (Ze).
                             
                21/03/2013 - Ajustes referentes ao Projeto tarifas - fase 2
                             Grupo de cheque (Lucas R.)
                             
                10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).
                            
                09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).            
                           
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               13/11/2013 - Tratamento para Migracao para Viacredi (Ze).
               
               17/12/2013 - Corrigido para enviar email para suporte@viacredi
                            quando cdcooper = 2 e data a partir de 02/01/2014.
                            (Fabricio)
                            
               20/01/2014 - Incluir VALIDATE craplot, craplcm, gncpdev e 
                            gnmvcen (Lucas R.)
                            
               19/03/2014 - Efetuada correcao na leitura da tabela craplcm ref.
                            conta migrada, antes de efetuar lancamento de 
                            devolucao (Diego).
                            
               31/10/2014 - Incluso tratamento para incorporacao VIACON e
                            SCRMIL (Daniel). 
                            
               02/12/2014 - Alterado para zerar variavel aux_vldtotal a cada 
                            arquivo de cheques devolvidos gerado. (Reinert)

               19/12/2014 - Efetuado acerto na procedure 'gera_arquivo_cecred'
                            na abertura/fechamento do arquivo (Diego).
                            
               19/01/2015 - Adição dos parâmetros "arq" e "coop" na chamada do
                            fonte mqcecred_envia.pl. (Dionathan)
                            
               11/03/2015 - Incluido tratamento para as contas migradas.(James)
               
               16/07/2015 - Ajustar os log para informar o que está acontecendo no 
                            processo ao invés de imprimir MESSAGE que poluem o 
                            proc_batch (Douglas - Chamado 307649)

               29/10/2015 - Inclusao do indicador estado de crise. (Jaison/Andrino)
							
			   16/11/2015 - Incluido Fato Gerador no parametro cdpesqbb na procedure
							cria_lan_auto_tarifa, Projeto Tarifas (Jean Michel).
                            
               25/11/2015 - Alterar e-mail "juliana.carla@viacredialtovale.coop.br" 
                            para "suporte@viacredialtovale.coop.br" (Lucas Ranghetti #359073)
                          - Alterar glb_nmrescop para buscar da cecred, alterado log do
                            proc_batch para o proc_message (Lucas Ranghetti #359051)
                            
               07/12/2015 - #367740 Criado o tratamento para o historico 1874 assim como eh
                            feito com o historico 1873 (Carlos)
                            
               14/12/2015 Inicializar variavel aux_dsorigem para nao apresentar 
                          descricao errada, qnd valor deve ser em branco 
                          SD351285 (Odirlei-AMcom)   
                          
               05/05/2016 - Adicionado validacao para que na devolucao diaria 
                            "p-cddevolu = 5" nao sejam considerados as devolucoes
                            com valor superior ao parametro VALORESVLB
                            (Douglas - Chamado 414930)
                            
              21/07/2016 - Ajustes referentes a Melhoria 69 - Devolucao automatica 
                           de cheques (Lucas Ranghetti #484923)

              16/09/2016 - #520378 Incluido o parametro ISPB na chamada de grava-log-ted em 
                            envia_arquivo_xml (Carlos)

              11/10/2016 - Acesso da tela PRCCTL DEVOLU em todas cooperativas SD381526 (Tiago/Elton)
              
              28/11/2016 - Alterar parametro da busca da tabela crapcst que estava errado 
                           (Lucas Ranghetti/Elton)

			        02/12/2016 - Incorporacao Transulcred (Guilherme/SUPERO)
                           
              05/12/2016 - Ajuste para criar lançamento com o historico 399 para a Diurna e Noturna.
                           Também validar alinea 35 - Melhoria 69 (Lucas Ranghetti/Elton)
                           
              16/12/2016 - Substituido o histórico 399 pelo 351 na devoluçao de 
                           cheques de custódia para a conta do beneficiario (Elton).             
                           
              03/02/2017 - Incluir dtlibera para as consultas de cheques em custodia/desconto
                           (Lucas Ranghetti #600012)
                           
	            30/03/2017 - Gerar lançamentos de cheques descontados ou custodiados de 
			                     operações entre cooperados no arquivo AAMMDD_CRITICAS.txt
						               P307 - (Jonatas - Supero)
                           
              04/04/2017 - Incluir validacao para contas migradas na procedure gera_lancamento 
                           (Lucas Ranghetti #620180)	   

              19/04/2017 - Substituir o dtlibera das consultas de cheques em custodia/desconto
                           por dtdevolu = ? (Lucas Ranghetti #640682)

              08/05/2017 - Incluso tratativa crapcst.nrborder = 0 nas duas leituras
			               FOR LAST crapcst (Daniel - Projeto 300) 
                           
              13/06/2017 - Ajustes para o novo formato de devoluçao de Sessao Única, de 
                           Fraudes/Impedimentos e remoçao do processo de devoluçao VLB.
                           PRJ367 - Compe Sessao Unica (Lombardi)
              
              13/07/2017 - Alterar a situação do insitchq das tabelas crapcdb e crapcst
                           para 3 depois que criar o craplcm (Lucas Ranghetti #659855)

              01/09/2017 - SD737676 - Alteracao de comentario fazendo mencao a arquivo 
			               nao gerado por esta procedure (Marcos-Supero)

              05/09/2017 - Ajuste para apresentar novamente a conta do associado na coluna Benefic
						   no relatorio de cheques 085
						   (Adriano - SD 744959).

              06/03/2018 - Ajuste para buscar a descricao do tipo de conta do oracle. PRJ366 (Lombardi)

			  10/03/2018 - Removida procedure envia_arquivo_xml - Compe Sessao Unica (Diego).

			  11/05/2018 - Ajuste para processar cheques com alinea 35, os mesmos nao estavam
			               sendo processados e nao apareciam no Relatorio 219.
			               Chamado SCTASK0012893 - Gabriel (Mouts).

			  26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

        04/07/2018 - Ajuste referente SCTASK0018345

              16/07/2018 - Incluido critica no arquivo CRITICASDEVOLU.txt para alínea 37
                           conforme tarefa SCTASK0010890. (Reinert)
                           
              27/07/2018 - Adicionado histórico 5210 na crítica da alínea 37 do arquivo
                           CRITICASDEVOLU.txt (Reinert).

              14/08/2018 - Tratamento de devolucoes automaticas, insitdev = 2, setando seus 
			               valores para insitdev = 1, desta forma registros irao constar no 
						   Relatorio 219. Chamado PRB0040059 - Gabriel (Mouts).

              06/09/2018 - Cheques com devolucao de historico 573 nao estavam sendo
                           processados com sucesso. Feito tratamento para receber
                           devolucoes automaticas, feitas pelo pc_crps533, corretamente.
                           Chamado SCTASK0027900 - Gabriel (Mouts).

              13/11/2018 - Chamada da rotina para gerar o estorno da tarifa de ADP
                           quando ocorre a devolucao de cheque, deixando a conta com
                           a situacao regularizada - Adriano (Supero) - PRJ435.

              07/12/2018 - Melhoria no processo de devoluções de cheques.
                           Alcemir Mout's (INC0022559).

              15/03/2019 - Adicionada flag de reapresentacao automatica de cheque.
                          (Lucas H. - Supero)
	          20/05/2019 - Ajuste para que, quando nao encontrar a conta de um registro de devolucao,
			               o programa nao sera abortado. Sera encaminhando um e-mail para a equipe 
						   de compensacao (Com copia para a  sustentacao) informando
						   qual o cheque com problema e que a devolucao deve ser feita por carta
						   (Adriano - PRB0041791).
			        04/06/2019 - P565.1-RF20 - Inclusao do histórico 2973-DEV.CH.DEP na proc gera_lancamento.
                           (Fernanda Kelli de Oliveira - AMCom)
						   
			        09/07/2019 - P565.1-RF20 - Retirar o valor do cheque devolvido da tabela de bloqueados - CRAPDPB na proc gera_lancamento.
                           (Fernanda Kelli de Oliveira - AMCom)                           

              30/07/2019 - PJ565 - Validaçoes e gravaçao da estrutura tabema nossa remessa - Renato Cordeiro - AMcom
						   
..............................................................................*/

{ sistema/generico/includes/var_oracle.i }

DEF INPUT  PARAM p-cdcooper AS INT                                   NO-UNDO.
DEF INPUT  PARAM p-cddevolu AS INT                                   NO-UNDO.

/* Valores do parametro p-cddevolu:
   1 = BANCOOB
   2 = CONTA BASE (BB)
   3 = CONTA INTEGRACAO (BB)
   4 = CHEQUE VLB  (CECRED)
   5 = 1a EXECUCAO (CECRED)
   6 = 2a EXECUCAO (CECRED)
*/

{ includes/var_batch.i }   
{ sistema/generico/includes/var_internet.i }

DEF STREAM str_1. /* Relatorios */
DEF STREAM str_2. /* Arquivos   */
DEF STREAM str_3. /* Arquivo Contábil */


DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR res_nrdctabb AS INT                                   NO-UNDO.
DEF        VAR res_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR res_cdhistor AS INT                                   NO-UNDO.

DEF        VAR tab_txdevchq AS DECIMAL                               NO-UNDO.

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nmdbanco AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

/* variaveis para conta de integracao */
DEF        BUFFER crabass5 FOR crapass.
DEF        VAR aux_nrctaass AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR aux_ctpsqitg LIKE craplcm.nrdctabb                    NO-UNDO.
DEF        VAR aux_nrdctitg LIKE crapass.nrdctitg                    NO-UNDO.

DEF        VAR rel_nrcpfcgc AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmrescop AS CHAR EXTENT 2                         NO-UNDO.
DEF        VAR aux_nmcidade AS CHAR                                  NO-UNDO.
DEF        VAR rel_qtchqdev AS INT                                   NO-UNDO.
DEF        VAR rel_vlchqdev AS DECI    FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR aux_qtpalavr AS INT                                   NO-UNDO.
DEF        VAR aux_contapal AS INT                                   NO-UNDO.
DEF        VAR aux_cdbanchq AS INT                                   NO-UNDO.

DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_cdcooper AS INT                                   NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqlog AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqdev AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrdigitg AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtmovime AS CHAR                                  NO-UNDO.
DEF        VAR aux_vldevolu AS DECI                                  NO-UNDO.
DEF        VAR aux_valorvlb AS DECI                                  NO-UNDO.
DEF        VAR flg_devolbcb AS LOG                                   NO-UNDO.

DEF        VAR aux_cdhistor AS CHAR                                  NO-UNDO.

DEF        VAR h-b1wgen0153 AS HANDLE                                NO-UNDO.
DEF        VAR aux_cdhisest AS INTE                                  NO-UNDO.
DEF        VAR aux_dtdivulg AS DATE                                  NO-UNDO.
DEF        VAR aux_dtvigenc AS DATE                                  NO-UNDO.
DEF        VAR aux_cdtarifa AS CHAR                                  NO-UNDO.
DEF        VAR par_dscritic LIKE crapcri.dscritic                    NO-UNDO.
DEF        VAR aux_vltarifa  AS DECIMAL FORMAT "zz9.99"              NO-UNDO.
DEF        VAR aux_cdfvlcop AS INTE                                  NO-UNDO.
/*variaveis da taxa bacen*/
DEF        VAR aux_cdhisbac AS INTE                                  NO-UNDO.
DEF        VAR aux_cdtarbac AS CHAR                                  NO-UNDO.
DEF        VAR aux_vltarbac AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR aux_cdfvlbac AS INTE                                  NO-UNDO.
DEF        VAR aux_nrctalcm AS INTE                                  NO-UNDO.

DEF        VAR aux_nrdconta_tco AS INTE                              NO-UNDO. 
DEF        VAR aux_cdagectl AS INTE                                  NO-UNDO. 
DEF        VAR aux_cdcopant AS INTE                                  NO-UNDO.    

DEF        VAR vr_nrdconta  AS INTE                                  NO-UNDO. 
DEF        VAR vr_cdcooper  AS INTE                                  NO-UNDO. 
DEF        VAR vr_cdagectl  AS INTE                                  NO-UNDO. 

/*variaveis da arquivo contábil AAMMDD_CRITICADEVOLU.txt*/
DEF        VAR aux_nmarqcri AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqcop AS CHAR                                  NO-UNDO.
DEF        VAR aux_linhaarq AS CHAR                                  NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_flcraptco AS LOGICAL                              NO-UNDO.

DEF        VAR aux_dstipcta AS CHAR                                  NO-UNDO.
DEF        VAR aux_des_erro AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.

DEF        VAR aux_flgreapr AS INT                                   NO-UNDO.
					
DEF        VAR aux_cdcritic AS INTEGER                               NO-UNDO.
DEF        VAR vr_gera_devolu_coop3 AS CHAR                          NO-UNDO.

/*P565.1-RF20*/
DEF        VAR aux2_cdhistor AS INTE                                 NO-UNDO.
DEF        BUFFER craplcm1 FOR craplcm.

DEF BUFFER crabcop FOR crapcop.
DEF BUFFER crabtco FOR craptco.

DEF TEMP-TABLE tt-relchdv NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta     
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD cdpesqui LIKE crapdev.cdpesqui
    FIELD nrcheque LIKE crapdev.nrcheque
    FIELD vllanmto LIKE crapdev.vllanmto
    FIELD cdalinea LIKE crapdev.cdalinea
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD cdoperad LIKE crapope.cdoperad
    FIELD dsorigem AS CHAR FORMAT "x(13)"
    FIELD dstipcta AS CHAR FORMAT "x(15)"
    FIELD benefici AS CHAR FORMAT "x(10)"
    FIELD flgreapr AS CHAR FORMAT "x(3)"
    INDEX nrdconta IS PRIMARY nrdconta
          nrcheque. 

FUNCTION f_ver_contaitg RETURN INTEGER(INPUT  par_nrdctitg AS CHAR):

    IF   par_nrdctitg = "" THEN
         RETURN 0.
    ELSE
         DO:
             IF   CAN-DO("1,2,3,4,5,6,7,8,9,0",
                         SUBSTR(par_nrdctitg,LENGTH(par_nrdctitg),1)) THEN
                  RETURN INTEGER(STRING(par_nrdctitg,"99999999")).
             ELSE
                  RETURN INTEGER(SUBSTR(STRING(par_nrdctitg,"99999999"),
                                        1,LENGTH(par_nrdctitg) - 1) + "0").
         END.

END. /* FUNCTION */



 { includes/proc_conta_integracao.i }

ASSIGN glb_cdprogra = "crps264"
       glb_flgbatch = false.


RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
    RETURN.


/*Devido a mudancas na tela PRCCTL que podera ser acessada
 por outras coops alem da CECRED é necessario que este
 ASSIGN permaneça para um funcionamento correto*/
ASSIGN glb_cdcooper = 3.
  
IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.
       
/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_message.log").
         RETURN.
     END.                      

ASSIGN aux_nmcidade = TRIM(crapcop.nmcidade)
       res_nrdctabb = INTEGER(SUBSTRING(glb_dsrestar,01,08))
       res_nrdocmto = INTEGER(SUBSTRING(glb_dsrestar,10,07))
       res_cdhistor = INTEGER(SUBSTRING(glb_dsrestar,18,03)).

ASSIGN vr_gera_devolu_coop3 = "N".
IF p-cdcooper = 3 AND p-cddevolu = 5 THEN
   DO:
      ASSIGN vr_gera_devolu_coop3 = "S".
      RUN gera_arquivo_cecred.
      RETURN.
   END.

CASE p-cddevolu:

    /*  BANCOOB  */
    WHEN 1 THEN  aux_cdbanchq = 756.

    /*  CONTA BASE  */
    WHEN 2 THEN  aux_cdbanchq = 1.

    /*  CONTA INTEGRACAO  */
    WHEN 3 THEN  aux_cdbanchq = 1.

    /*  CECRED  */
    WHEN 4 OR WHEN 5 OR WHEN 6 THEN  aux_cdbanchq = crapcop.cdbcoctl.

END CASE.

/*............................................................................*/
/* Leitura da tabela com o valor definido para cheque VLB */ 
FIND craptab WHERE craptab.cdcooper = p-cdcooper    AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 0             AND
                   craptab.cdacesso = "VALORESVLB"  AND
                   craptab.tpregist = 0             
                   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " CRED-GENERI-00-VALORESVLB-001 " +
                           " >> log/proc_message.log").
         RETURN.
     END.

ASSIGN aux_vldevolu = DECIMAL(ENTRY(3, craptab.dstextab, ";"))
       aux_valorvlb = DECIMAL(ENTRY(2, craptab.dstextab, ";")).

IF   p-cddevolu >= 4 THEN
     RUN verifica_locks.

IF   RETURN-VALUE = "NOK"   THEN
     DO:
         DO TRANSACTION:
            FIND crapsol WHERE crapsol.cdcooper = p-cdcooper   AND
                               crapsol.dtrefere = glb_dtmvtolt AND
                               crapsol.nrsolici = 78           AND
                               crapsol.nrseqsol = p-cddevolu
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            DELETE crapsol.                 
         END. /* Fim da Transacao */
         
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" +
                           " Devolucoes NAO processadas. " +
                           " Coop: " +  STRING(p-cdcooper) + 
                           " >> log/proc_message.log").

     END.
ELSE     
     DO: 
         
         /* Gerar log informando o inicio do processo de devolução dos cheques*/
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" +
                           "Inicio do processo - " + 
                           " Coop: " + STRING(p-cdcooper) + 
                           " >> log/proc_message.log").
         
         RUN gera_lancamento.
         
         IF   RETURN-VALUE = "OK"   THEN
              DO: 

                  /* 
                
				  Alterado logica do programa Crps533 para criar lancamentos
                  de devolucao  automatica,  parametrizado como insitdev = 2.
                  Neste ponto  estaremos fazendo o tratamento  dos registros
                  com insitdev  2, voltando  para o  valor  padronizado de 1.
                  Desta  forma  as  devolucoes  automaticas irao  constar no
                  Relatorio 219 gerado. Chamado PRB0040059.
                
			  	  */
			  
                  RUN trata_dev_automatica(INPUT p-cdcooper).
				  
                       /* BANCOOB        CONTA BASE        INTEGRACAO */
                  IF   p-cddevolu = 1 OR p-cddevolu = 2 OR p-cddevolu = 3 THEN
                       RUN gera_impressao.
         
                  IF   RETURN-VALUE = "OK"   THEN
                       DO:
                           IF   p-cddevolu = 1      THEN     /* BANCOOB */
                                RUN gera_arquivo_bancoob.
                           ELSE
                           IF   p-cddevolu = 3      THEN     /* CONTA ITG */
                                RUN gera_arquivo_ctaitg.
                           ELSE
                           IF   p-cddevolu = 5      OR
                                p-cddevolu = 6      THEN     /*   CECRED   */
                                DO:
                                    RUN gera_arquivo_cecred.
                                END.
                       
                           /* Gerar log com o fim da execução */ 
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                             glb_cdprogra + "' --> '" +
                                             " Devolucoes processadas. " +
                                             " Coop: " + STRING(p-cdcooper) + 
                                             " >> log/proc_message.log").

                       END.
              END.         
     END.         
/* .......................................................................... */

PROCEDURE gera_lancamento:

    DEF VAR aux_verifloc AS INTEGER NO-UNDO.    
    DEFINE VARIABLE     aux_dscritic    AS CHAR                     NO-UNDO.

	DEF VAR h-b1wgen0011 AS HANDLE                                  NO-UNDO.
	
    IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
        RUN sistema/generico/procedures/b1wgen0153.p 
            PERSISTENT SET h-b1wgen0153.

    TRANS_1:
    /* TCO = Transferencia de contas */
    FOR EACH crapdev WHERE crapdev.cdcooper = p-cdcooper   AND                            
                           crapdev.insitdev = 0 EXCLUSIVE-LOCK
                           TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

        /* Se conta for maior que zero */
        IF  crapdev.nrdconta > 0 THEN
            DO:
                ASSIGN aux_flcraptco = FALSE.
                
        FIND FIRST crapass WHERE crapass.cdcooper = crapdev.cdcooper AND
                                 crapass.nrdconta = crapdev.nrdconta
                                 NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass THEN
            DO:
                /* Tratamento para cheques migrados aonde o formulário do cheque 
                   encontra-se na cooperativa antiga. */
                FIND crabtco WHERE crabtco.cdcopant = crapdev.cdcooper AND
                                   crabtco.nrctaant = crapdev.nrdctabb AND
                                   crabtco.nrdconta = crapdev.nrdconta AND
                                   crabtco.tpctatrf = 1                AND
                                   crabtco.flgativo = TRUE
                                   NO-LOCK NO-ERROR.
                                  
                IF  NOT AVAILABLE crabtco THEN
                    DO:
                glb_cdcritic = 251.
                RUN fontes/critic.p. 

								IF NOT VALID-HANDLE(h-b1wgen0011) THEN
									RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.

								RUN enviar_email_completo IN h-b1wgen0011 (INPUT glb_cdcooper,
																		   INPUT glb_cdprogra,
																		   INPUT "cpd@ailos.coop.br",
																		   INPUT "compe@ailos.coop.br,sustentacao@ailos.coop.br",
																		   INPUT "CRPS264 - Devolucoes de cheque - Problemas no processo",
																		   INPUT "",			
																		   INPUT "",
																		   INPUT "\nO programa crps264.p nao conseguiu efetuar a devolucao do cheque:"+											         
																				 "\nCooperativa: " + STRING(crapdev.cdcooper) + "," + 	
																				 "\nConta: " + STRING(crapdev.nrdconta,"zzzzzz,zz9,9") + "," +
																				 "\nCheque: " + STRING(crapdev.nrcheque) +	"," +
																				 "\nAlinea: " + STRING(crapdev.cdalinea) +	"," +
																				 "\nMotivo: " + glb_dscritic +	"," +
																				 "\n<b> Necessario efetuar a devolucao manualmente, atraves de carta.</b>" + 
																				 "\n\n\n" + 
																				 "<u>Dados tecnicos:</u> \n" + 
																				 "NRDCONTA: " + string(crapdev.nrdconta)  + ",\n" + 
																				 "NRDCTABB: " + string(crapdev.nrdctabb)  + ",\n" + 
																				 "CDHISTOR: " + string(crapdev.cdhistor)  + ",\n" + 
																				 "VLLANMTO: " + string(crapdev.vllanmto)  + ",\n" + 
																				 "CDALINEA: " + string(crapdev.cdalinea)  + ",\n" + 
																				 "INSITDEV: " + string(crapdev.insitdev)  + ",\n" + 
																				 "CDBCCXLT: " + string(crapdev.cdbccxlt)  + ",\n" + 
																				 "DTMVTOLT: " + string(crapdev.dtmvtolt)  + ",\n" + 
																				 "CDOPERAD: " + string(crapdev.cdoperad)  + ",\n" + 
																				 "NRDCTACR: " + string(crapdev.nrdctacr)  + ",\n" + 
																				 "NRDOLOTE: " + string(crapdev.nrdolote)  + ",\n" + 
																				 "CDBANCHQ: " + string(crapdev.cdbanchq)  + ",\n" + 
																				 "CDPESQUI: " + string(crapdev.cdpesqui)  + ",\n" + 
																				 "CDAGECHQ: " + string(crapdev.cdagechq)  + ",\n" + 
																				 "CDCOOPER: " + string(crapdev.cdcooper)  + ",\n" + 
																				 "NRCTACHQ: " + string(crapdev.nrctachq)  + ",\n" + 
																				 "INDCTITG: " + string(crapdev.indctitg)  + ",\n" + 
																				 "NRDCTITG: " + string(crapdev.nrdctitg)  + ",\n" + 
																				 "INDEVARQ: " + string(crapdev.indevarq)  + ",\n" + 
																				 "NRCHEQUE: " + string(crapdev.nrcheque)  + ",\n" + 
																				 "CDBANDEP: " + string(crapdev.cdbandep)  + ",\n" + 
																				 "CDAGEDEP: " + string(crapdev.cdagedep)  + ",\n" + 
																				 "NRCTADEP: " + string(crapdev.nrctadep)  + ".\n", 
																		   INPUT TRUE).
								
								ASSIGN glb_cdcritic = 0
									   glb_dscritic = "".
								
								IF  VALID-HANDLE(h-b1wgen0011) THEN
									DELETE OBJECT h-b1wgen0011.

								/* Elimina o registro da crapdev.*/
								DELETE crapdev.
								 
								NEXT.

            END.
                ELSE
                    DO:
                         ASSIGN aux_flcraptco = TRUE.

                         FIND crapass WHERE crapass.cdcooper = crabtco.cdcopant 
                                        AND crapass.nrdconta = crabtco.nrctaant
                                        NO-LOCK NO-ERROR.
                         
                         IF  NOT AVAILABLE crapass THEN
                             DO:
                                 glb_cdcritic = 251.
                                 RUN fontes/critic.p. 
										
										IF NOT VALID-HANDLE(h-b1wgen0011) THEN
											RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.
												
										RUN enviar_email_completo IN h-b1wgen0011 (INPUT glb_cdcooper,
																				   INPUT glb_cdprogra,
																				   INPUT "cpd@ailos.coop.br",
																				   INPUT "compe@ailos.coop.br,sustentacao@ailos.coop.br",
																				   INPUT "CRPS264 - Devolucoes de cheque - Problemas no processo",
																				   INPUT "",			
																				   INPUT "",
																				   INPUT "\nO programa crps264.p nao conseguiu efetuar a devolucao do cheque:"+											         
																						 "\nCooperativa: " + STRING(crapdev.cdcooper) +	"," +
																						 "\nConta: " + STRING(crapdev.nrdconta,"zzzzzz,zz9,9") +	"," +
																						 "\nCheque: " + STRING(crapdev.nrcheque) +	"," +
																						 "\nAlinea: " + STRING(crapdev.cdalinea) +	"," +
																						 "\nMotivo: " + glb_dscritic +	"," +
																						 "\n<b> Necessario efetuar a devolucao manualmente, atraves de carta.</b>" + 
																						 "\n\n\n" + 
																						 "<u>Dados tecnicos:</u> \n" +  
																						 "NRDCONTA: " + string(crapdev.nrdconta)  + ",\n" + 
																						 "NRDCTABB: " + string(crapdev.nrdctabb)  + ",\n" + 
																						 "CDHISTOR: " + string(crapdev.cdhistor)  + ",\n" + 
																						 "VLLANMTO: " + string(crapdev.vllanmto)  + ",\n" + 
																						 "CDALINEA: " + string(crapdev.cdalinea)  + ",\n" + 
																						 "INSITDEV: " + string(crapdev.insitdev)  + ",\n" + 
																						 "CDBCCXLT: " + string(crapdev.cdbccxlt)  + ",\n" + 
																						 "DTMVTOLT: " + string(crapdev.dtmvtolt)  + ",\n" + 
																						 "CDOPERAD: " + string(crapdev.cdoperad)  + ",\n" + 
																						 "NRDCTACR: " + string(crapdev.nrdctacr)  + ",\n" + 
																						 "NRDOLOTE: " + string(crapdev.nrdolote)  + ",\n" + 
																						 "CDBANCHQ: " + string(crapdev.cdbanchq)  + ",\n" + 
																						 "CDPESQUI: " + string(crapdev.cdpesqui)  + ",\n" + 
																						 "CDAGECHQ: " + string(crapdev.cdagechq)  + ",\n" + 
																						 "CDCOOPER: " + string(crapdev.cdcooper)  + ",\n" + 
																						 "NRCTACHQ: " + string(crapdev.nrctachq)  + ",\n" + 
																						 "INDCTITG: " + string(crapdev.indctitg)  + ",\n" + 
																						 "NRDCTITG: " + string(crapdev.nrdctitg)  + ",\n" + 
																						 "INDEVARQ: " + string(crapdev.indevarq)  + ",\n" + 
																						 "NRCHEQUE: " + string(crapdev.nrcheque)  + ",\n" + 
																						 "CDBANDEP: " + string(crapdev.cdbandep)  + ",\n" + 
																						 "CDAGEDEP: " + string(crapdev.cdagedep)  + ",\n" + 
																						 "NRCTADEP: " + string(crapdev.nrctadep)  + ".\n", 
																				   INPUT TRUE).
										
										ASSIGN glb_cdcritic = 0
										       glb_dscritic = "".
										
										IF  VALID-HANDLE(h-b1wgen0011) THEN
										    DELETE OBJECT h-b1wgen0011.
								
										/* Elimina o registro da crapdev.*/
										DELETE crapdev.
                             
										NEXT.
                             
                             END.
									 
                    END.
							
            END.

        ASSIGN glb_cdcritic = 0    
               glb_inrestar = 0
               aux_nrdconta_tco = 0
               aux_cdagectl = 0
               aux_cdcopant = 0.
            
        IF  crapdev.cdpesqui = "TCO" THEN
            DO:
                FIND craptco WHERE craptco.cdcopant = p-cdcooper       AND
                                   craptco.nrctaant = crapdev.nrdconta AND
                                   craptco.tpctatrf = 1                AND
                                   craptco.flgativo = TRUE
                                   NO-LOCK NO-ERROR.
                                        
                IF   AVAILABLE craptco THEN
                     ASSIGN aux_cdcooper = craptco.cdcooper
                            aux_nrdconta = craptco.nrdconta
                            aux_nrctalcm = craptco.nrdconta.
                ELSE
                     ASSIGN aux_cdcooper = p-cdcooper
                            aux_nrdconta = crapdev.nrdconta
                            aux_nrctalcm = crapdev.nrdctabb.
            END.
        ELSE
        DO:
            IF  aux_flcraptco THEN
                ASSIGN aux_cdcooper = crabtco.cdcooper
                       aux_nrdconta = crapdev.nrdconta
                       aux_nrctalcm = crapdev.nrdconta.
            ELSE
            ASSIGN aux_cdcooper = p-cdcooper
                   aux_nrdconta = crapdev.nrdconta
                   aux_nrctalcm = crapdev.nrdctabb.

            /* VIACON - Se for conta migrada das cooperativas 4 ou 15 devera
            tratar aux_nrctalcm para receber a nova conta. O campo
            crapdev.nrdctabb contem o numero da conta cheque */ 
            IF  p-cdcooper = 1  OR    /* Viacredi    */
                p-cdcooper = 13 OR    /* Scrcred     */
                p-cdcooper = 9  THEN  /* Transulcred */ DO:

                RUN verifica_incorporacao(INPUT  p-cdcooper,
                                          INPUT  crapdev.nrdconta,
                                          INPUT  crapdev.nrcheque,
                                          OUTPUT aux_cdcopant,
                                          OUTPUT aux_nrdconta_tco,
                                          OUTPUT aux_cdagectl).

                /* Se aux_nrdconta_tco > 0 eh incorporacao */
                IF aux_nrdconta_tco > 0 THEN
                    ASSIGN aux_nrctalcm = crapdev.nrdconta. 
               
            END.
                
        END.

                
                
        IF  crapass.inpessoa = 1 THEN
            DO:
                ASSIGN aux_cdtarifa = "DEVOLCHQPF" 
                       aux_cdtarbac = "DEVCHQBCPF". 
            END.
          
        ELSE
            DO:
                ASSIGN aux_cdtarifa = "DEVOLCHQPJ" 
                       aux_cdtarbac = "DEVCHQBCPJ". 
            END.
            
        IF  aux_cdtarifa = "DEVOLCHQPF" OR aux_cdtarifa = "DEVOLCHQPJ" THEN
            DO:
                RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                                (INPUT  p-cdcooper,
                                                 INPUT  aux_cdtarifa,
                                                 INPUT  1, 
                                                 INPUT  glb_cdprogra,
                                                 OUTPUT aux_cdhistor,
                                                 OUTPUT aux_cdhisest,
                                                 OUTPUT aux_vltarifa,
                                                 OUTPUT aux_dtdivulg,
                                                 OUTPUT aux_dtvigenc,
                                                 OUTPUT aux_cdfvlcop,
                                                 OUTPUT TABLE tt-erro).
                
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:                                              
                       FIND FIRST tt-erro NO-LOCK NO-ERROR.

                       IF AVAIL tt-erro THEN  
                          UNIX SILENT VALUE("echo " + 
                               STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '"
                               + tt-erro.dscritic +  
                               " >> log/proc_message.log").   

                       IF  VALID-HANDLE(h-b1wgen0153) THEN
                           DELETE OBJECT h-b1wgen0153.
        
                       UNDO TRANS_1, RETURN "NOK".
                    END.
                
            END.
        
        /* BUSCA INFORMACOES TAXA BACEN*/
        IF  aux_cdtarbac = "DEVCHQBCPJ" OR aux_cdtarbac = "DEVCHQBCPF" THEN
            DO:
                RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                                (INPUT  p-cdcooper,
                                                 INPUT  aux_cdtarbac,
                                                 INPUT  1, 
                                                 INPUT  glb_cdprogra,
                                                 OUTPUT aux_cdhisbac,
                                                 OUTPUT aux_cdhisest,
                                                 OUTPUT aux_vltarbac,
                                                 OUTPUT aux_dtdivulg,
                                                 OUTPUT aux_dtvigenc,
                                                 OUTPUT aux_cdfvlbac,
                                                 OUTPUT TABLE tt-erro).
                
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF AVAIL tt-erro THEN 
                           UNIX SILENT VALUE("echo " + 
                                STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '"
                                + tt-erro.dscritic +  
                                " >> log/proc_message.log").   
                       
                       IF  VALID-HANDLE(h-b1wgen0153) THEN
                           DELETE OBJECT h-b1wgen0153.
        
                       UNDO TRANS_1, RETURN "NOK".
                    END.
                
            END.
               
        CASE p-cddevolu:

            /*  BANCOOB  */
            WHEN 1 THEN  IF   crapdev.cdbanchq <> 756 THEN
                              NEXT.

            /*  CONTA BASE  */
            WHEN 2 THEN DO:
                            IF   crapdev.cdbanchq <> 1  THEN
                                 NEXT.

                            ASSIGN aux_ctpsqitg = crapdev.nrdctabb.
             
                            RUN existe_conta_integracao.
                            
                            IF   aux_nrdctitg <> ""   THEN
                                 NEXT.
                        END.
                            
            /*  CONTA INTEGRACAO  */
            WHEN 3 THEN DO:
                            IF   crapdev.cdbanchq <> 1  THEN
                                 NEXT.

                            ASSIGN aux_ctpsqitg =
                                            f_ver_contaitg(crapdev.nrdctitg).

                            RUN existe_conta_integracao.
                            
                            IF   aux_nrdctitg = ""   THEN
                                 NEXT.
                        END.                

            /*  CECRED */
            WHEN 5 OR WHEN 6 THEN DO:
                            
                    IF   crapdev.cdbanchq <> crapcop.cdbcoctl THEN
                        NEXT.

            END.

        END CASE.

        /* Historicos que indicam cheque devolvido */
        IF   CAN-DO("47,191,338,573",STRING(crapdev.cdhistor))  THEN
             DO:
                 glb_nrcalcul = 
                          INT(SUBSTR(STRING(crapdev.nrcheque,"9999999"),1,6)).

                 DO WHILE TRUE:

                    FIND crapfdc WHERE crapfdc.cdcooper = p-cdcooper        AND
                                       crapfdc.cdbanchq = crapdev.cdbanchq  AND
                                       crapfdc.cdagechq = crapdev.cdagechq  AND
                                       crapfdc.nrctachq = crapdev.nrctachq  AND
                                       crapfdc.nrcheque = INT(glb_nrcalcul)
                                       USE-INDEX crapfdc1
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE crapfdc   THEN
                         IF  LOCKED crapfdc   THEN
                              DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                         ELSE
                              DO:
                                  glb_cdcritic = 268. 
                                  LEAVE.
                              END.
                         
                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */

                 IF   glb_cdcritic > 0   THEN
                      DO:
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '"  +
                                            glb_dscritic +
                                            "COOP: " + STRING(crapdev.cdcooper) +
                                            "CTA: " + STRING(crapdev.nrdconta) +
                                            "CBS: " + STRING(crapdev.nrdctabb) +
                                            "DOC: " + STRING(crapdev.nrcheque) +
                                            " >> log/proc_message.log").
                          
                          IF  VALID-HANDLE(h-b1wgen0153) THEN
                              DELETE OBJECT h-b1wgen0153. 

                          UNDO TRANS_1, RETURN "NOK".
                      END.

                 /*  Leitura do lote de devolucao de cheque  */
                 DO WHILE TRUE:

                    IF   p-cddevolu = 1 THEN       /*  BANCOOB  */
                         FIND craplot WHERE craplot.cdcooper = aux_cdcooper AND
                                            craplot.dtmvtolt = glb_dtmvtolt AND
                                            craplot.cdagenci = aux_cdagenci AND
                                            craplot.cdbccxlt = aux_cdbccxlt AND
                                            craplot.nrdolote = 10110
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    ELSE
                    IF   p-cddevolu = 2 THEN       /*  CONTA BASE  */
                         FIND craplot WHERE craplot.cdcooper = aux_cdcooper AND
                                            craplot.dtmvtolt = glb_dtmvtolt AND
                                            craplot.cdagenci = aux_cdagenci AND
                                            craplot.cdbccxlt = aux_cdbccxlt AND
                                            craplot.nrdolote = 8451
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    ELSE
                    IF   p-cddevolu = 3 THEN       /*  CONTA INTEGRACAO  */
                         FIND craplot WHERE craplot.cdcooper = aux_cdcooper AND
                                            craplot.dtmvtolt = glb_dtmvtolt AND
                                            craplot.cdagenci = aux_cdagenci AND
                                            craplot.cdbccxlt = aux_cdbccxlt AND
                                            craplot.nrdolote = 10109
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    ELSE
                    IF   p-cddevolu = 5 OR
                         p-cddevolu = 6 THEN       /*  CECRED  */
                         FIND craplot WHERE craplot.cdcooper = aux_cdcooper AND
                                            craplot.dtmvtolt = glb_dtmvtolt AND
                                            craplot.cdagenci = aux_cdagenci AND
                                            craplot.cdbccxlt = aux_cdbccxlt AND
                                            craplot.nrdolote = 10117
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE craplot   THEN
                         IF   LOCKED craplot   THEN
                              DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                         ELSE
                              DO:
                                  CREATE craplot.
                                  ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                         craplot.cdagenci = aux_cdagenci
                                         craplot.cdbccxlt = aux_cdbccxlt
                                         craplot.tplotmov = 1
                                         craplot.cdcooper = aux_cdcooper.

                                  CASE p-cddevolu:
                                      WHEN 1 THEN craplot.nrdolote = 10110.
                                      WHEN 2 THEN craplot.nrdolote = 8451.
                                      WHEN 3 THEN craplot.nrdolote = 10109.
                                      WHEN 5 OR WHEN 6 THEN 
                                                  craplot.nrdolote = 10117.
                                  END CASE.
                              END.
                    LEAVE.
                 END.  /*  Fim do DO WHILE TRUE  */

                 /* FIND na craplcm deve ser feito na cooperativa atual com a 
                    conta nova. Como o registro crapdev de conta MIGRADA eh 
                    alimentado com a conta antiga(crapdev.nrdctabb), e antes
                    estava utilizando crapdev.nrdctabb independente de conta
                    migrada, poderia encontrar um lancamento em outra conta 
                    da VIACREDI, com o mesmo numero da conta antiga na ACREDI, 
                    e nao faria esta devolucao */ 

                 DO aux_verifloc = 1 TO 10:
                                                      
                    /* VIACON - aux_nrctalcm deve conter a nova conta se for conta incorporada  */ 
                    FIND craplcm WHERE craplcm.cdcooper = aux_cdcooper     AND
                                       craplcm.dtmvtolt = craplot.dtmvtolt AND
                                       craplcm.cdagenci = craplot.cdagenci AND
                                       craplcm.cdbccxlt = craplot.cdbccxlt AND
                                       craplcm.nrdolote = craplot.nrdolote AND
                                       craplcm.nrdctabb = aux_nrctalcm     AND
                                       craplcm.nrdocmto = crapdev.nrcheque  
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                       
                    IF   NOT AVAIL craplcm THEN
                         DO:
                             IF   LOCKED craplcm THEN
                                  DO:
                                      glb_cdcritic = 77.
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                             ELSE
                                  DO: 
                                      glb_cdcritic = 0.
                                      LEAVE.
                                  END.
                         END.
                    ELSE
                         DO:
                             glb_cdcritic = 92.
                             LEAVE.
                         END.
                 END.

                 IF   glb_cdcritic <> 0 THEN
                      DO:
                          RUN fontes/critic.p.
                          PAUSE(2) NO-MESSAGE.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '"  +
                                            glb_dscritic +
                                            " Coop: " + STRING(aux_cdcooper) + 
                                            " Data: " + STRING(craplot.dtmvtolt) +
                                            " Lote: " + STRING(craplot.nrdolote) + 
                                            " CTA: " + STRING(aux_nrctalcm) +
                                            " CBS: " + STRING(crapdev.nrdctabb) +
                                            " DOC: " + STRING(crapdev.nrcheque) +
                                            " >> log/proc_message.log").

                          glb_cdcritic = 0.

                          IF  VALID-HANDLE(h-b1wgen0153) THEN
                              DELETE OBJECT h-b1wgen0153.

                          UNDO, RETURN "NOK".
                      END.
                                             
                 /* VIACON - cria lancamento na coop atual */

                 CREATE craplcm.
                 ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                        craplcm.cdagenci = craplot.cdagenci
                        craplcm.cdbccxlt = craplot.cdbccxlt
                        craplcm.nrdolote = craplot.nrdolote
                        craplcm.nrdconta = aux_nrdconta
                        craplcm.nrdctabb = aux_nrctalcm
                        craplcm.nrdocmto = crapdev.nrcheque
                        craplcm.cdhistor = crapdev.cdhistor
                        craplcm.nrseqdig = craplot.nrseqdig + 1
                        craplcm.vllanmto = crapdev.vllanmto
                        craplcm.cdoperad = crapdev.cdoperad
                        craplcm.cdpesqbb = IF   crapdev.cdalinea <> 0 THEN
                                                STRING(crapdev.cdalinea)
                                           ELSE "21"
                        craplcm.cdcooper = aux_cdcooper
                        craplcm.cdbanchq = crapdev.cdbanchq
                        craplcm.cdagechq = crapdev.cdagechq
                        craplcm.nrctachq = crapdev.nrctachq
                        
                        craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
                        craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto
                        craplot.qtinfoln = craplot.qtinfoln + 1
                        craplot.qtcompln = craplot.qtcompln + 1
                        craplot.nrseqdig = craplot.nrseqdig + 1

                        crapfdc.incheque = crapfdc.incheque - 5
                        crapfdc.dtliqchq = ?
                        crapfdc.vlcheque = 0
                        crapfdc.vldoipmf = 0 NO-ERROR.

                 VALIDATE craplot.

                 IF   crapfdc.cdbantic <> 0 THEN
                      ASSIGN crapfdc.cdbantic = 0
                             crapfdc.cdagetic = 0
                             crapfdc.nrctatic = 0
                             crapfdc.dtlibtic = ?
                             crapfdc.dtatutic = ?.

                 IF   p-cddevolu = 2  OR   /* Conta Base */
                      p-cddevolu = 3  THEN /* Conta Integracao */
                      craplcm.nrdctitg = crapdev.nrdctitg.
                 ELSE     
                      craplcm.nrdctitg = "".


                 IF   p-cddevolu = 5 OR p-cddevolu = 6 THEN
                      DO:
                          ASSIGN craplcm.nrdctitg = "".
                          
                          /* Atribui Valor para Alinea na GNCPCHQ */
                          FIND LAST gncpchq WHERE 
                                       gncpchq.cdcooper = aux_cdcooper     AND
                                       gncpchq.dtmvtolt = crapfdc.dtliqchq AND
                                       gncpchq.cdbanchq = crapfdc.cdbanchq AND
                                       gncpchq.cdagechq = crapdev.cdagechq AND
                                       gncpchq.nrctachq = crapdev.nrctachq AND
                                       gncpchq.nrcheque = INT(crapdev.nrcheque)
                                       AND
                                      (gncpchq.cdtipreg = 3                OR
                                       gncpchq.cdtipreg = 4)               AND
                                       gncpchq.vlcheque = crapdev.vllanmto
                                       USE-INDEX gncpchq1 EXCLUSIVE-LOCK
                                       NO-ERROR.

                          IF    AVAILABLE gncpchq THEN
                                DO:
                                    IF   crapdev.cdalinea <> 0 THEN
                                         gncpchq.cdalinea = crapdev.cdalinea.
                                    ELSE 
                                         gncpchq.cdalinea = 21.
                                END.
                                
                          IF    p-cddevolu = 5 THEN  /* 1a devolucao - 13:30* */
                                DO:
                                    crapdev.indevarq = 2.   /* Envia */
                                END.
                          ELSE /* 2a devolucao – 19:00 – Sessao de Prevencao a Fraudes e Impedimentos*/
                               /* Somente alineas 20, 21, 24, 25, 28, 30, 35 e 70 */
                               /* Na segunda Devolucao envia todos com o 
                                  indicador = 1, para saber quem ja foi env. */
                               crapdev.indevarq = 1.  /* Envia */
                               
                          craplcm.dsidenti = STRING(crapdev.indevarq,"9").
                      END.
                 ELSE
                      craplcm.dsidenti = "2".

                VALIDATE craplcm.
                        
             END.
        ELSE             /*  taxa de devolucao de cheque  */
        IF   crapdev.cdhistor = 46  AND
             crapass.inpessoa <> 3 THEN
             DO:
               IF (aux_cdtarifa = "DEVOLCHQPF"  OR 
                   aux_cdtarifa = "DEVOLCHQPJ") AND 
                   aux_vltarifa > 0             THEN
                   DO:

                        RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                                (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta, 
                                                 INPUT glb_dtmvtolt,
                                                 INPUT aux_cdhistor, 
                                                 INPUT aux_vltarifa,
                                                 INPUT crapdev.cdoperad,
                                                 INPUT 1, /*cdagenci*/
                                                 INPUT 100, /* par_cdbccxlt */
                                                 INPUT 8452, /*par_nrdolote */
                                                 INPUT 1,   /* par_tpdolote */
                                                 INPUT crapdev.nrcheque,
                                                 INPUT crapdev.nrdctabb,
                                                 INPUT crapdev.nrdctitg,
                                                 INPUT "Fato gerador tarifa:" + STRING(crapdev.nrcheque),  /*par_cdpesqbb*/
                                                 INPUT crapdev.cdbanchq,   
                                                 INPUT crapdev.cdagechq,   
                                                 INPUT crapdev.nrctachq,   
                                                 INPUT FALSE, /*par_flgaviso*/
                                                 INPUT 0,  /*par_tpaviso*/
                                                 INPUT aux_cdfvlcop,
                                                 INPUT glb_inproces,
                                                 OUTPUT TABLE tt-erro).
                                              
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                               FIND FIRST tt-erro NO-LOCK NO-ERROR.

                               IF AVAIL tt-erro THEN  
                                  UNIX SILENT VALUE("echo " + 
                                       STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '"
                                       + tt-erro.dscritic +  
                                       " >> log/proc_message.log").     

                               IF  VALID-HANDLE(h-b1wgen0153) THEN
                                   DELETE OBJECT h-b1wgen0153.

                               UNDO TRANS_1, RETURN "NOK".
                           END.
                   END.

               /*cria lancamento para tarifa dev cheque- Taxa BACEN*/     
               IF (aux_cdtarbac = "DEVCHQBCPJ"  OR 
                   aux_cdtarbac = "DEVCHQBCPF") AND 
                   aux_vltarbac > 0             THEN
                   DO:

                       RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                               (INPUT aux_cdcooper,
                                                INPUT aux_nrdconta, 
                                                INPUT glb_dtmvtolt,
                                                INPUT aux_cdhisbac, 
                                                INPUT aux_vltarbac,
                                                INPUT crapdev.cdoperad,
                                                INPUT 1, /*cdagenci*/
                                                INPUT 100, /* par_cdbccxlt */
                                                INPUT 8452, /*par_nrdolote */
                                                INPUT 1,   /* par_tpdolote */
                                                INPUT 0, /*nrdocmto*/
                                                INPUT crapdev.nrdctabb,
                                                INPUT crapdev.nrdctitg,
                                                INPUT "Fato gerador tarifa:" + STRING(crapdev.nrcheque),  /*par_cdpesqbb*/
                                                INPUT crapdev.cdbanchq,   
                                                INPUT crapdev.cdagechq,   
                                                INPUT crapdev.nrctachq,   
                                                INPUT FALSE, /*par_flgaviso*/
                                                INPUT 0,  /*par_tpaviso*/
                                                INPUT aux_cdfvlbac,
                                                INPUT glb_inproces,
                                                OUTPUT TABLE tt-erro).
                                             
                       IF  RETURN-VALUE = "NOK"  THEN
                           DO:
                              FIND FIRST tt-erro NO-LOCK NO-ERROR.

                              IF AVAIL tt-erro THEN 
                                 UNIX SILENT VALUE("echo " + 
                                      STRING(TIME,"HH:MM:SS") +
                                      " - " + glb_cdprogra + "' --> '"
                                      + tt-erro.dscritic +  
                                      " >> log/proc_message.log").    

                              IF  VALID-HANDLE(h-b1wgen0153) THEN
                                  DELETE OBJECT h-b1wgen0153.
                            
                              UNDO TRANS_1, RETURN "NOK".
                          END.
                   END. /*fim do if taxa bacen*/
                     END. /* Fim do historico 46 */

        ASSIGN crapdev.insitdev = 1 /* 1 = devolvido */
               crapdev.indctitg = IF   p-cddevolu = 3 THEN  /*  CONTA ITG  */
                                       TRUE
                                  ELSE FALSE.
                                  
                /* iremos verificar se registro criado na craplcm anteriormente é historico 47, 
                   caso seja devmos criar outro com o 399 - DEVOLUCAO DE CHEQUE DESCONTADO */
                IF  crapdev.cdhistor = 47 AND 
                   (p-cddevolu = 5 OR p-cddevolu = 6) THEN
                    DO:                     
                       
                       FIND CURRENT craplot NO-LOCK NO-ERROR.                        
                       RELEASE craplot.
                       
                       /* Desconto */
                       FOR LAST crapcdb FIELDS(cdcooper nrdconta nrcheque cdbanchq cdagechq nrctachq insitchq) 
                                         WHERE crapcdb.cdcooper = aux_cdcooper
                                           AND crapcdb.cdcmpchq = crapfdc.cdcmpchq
                                           AND crapcdb.cdbanchq = crapfdc.cdbanchq
                                           AND crapcdb.cdagechq = crapfdc.cdagechq                                          
                                           AND crapcdb.nrctachq = crapfdc.nrctachq
                                           AND crapcdb.nrcheque = crapfdc.nrcheque
                                           AND CAN-DO("0,2",STRING(crapcdb.insitchq))
                                           AND NOT CAN-DO("0,2",STRING(crapcdb.insitana)) /* Inclusao Paulo Martins - Mouts (SCTASK0018345)*/
                                           AND crapcdb.dtdevolu = ?
                                           EXCLUSIVE-LOCK:
                       END.                        
                       
                       IF  AVAILABLE crapcdb THEN          
                           DO:                               
                               /* criar lancamento com o historico 399 e historico 10119 */
                               DO  WHILE TRUE:
                        
                                   FIND craplot WHERE craplot.cdcooper = aux_cdcooper AND
                                                      craplot.dtmvtolt = glb_dtmvtolt AND
                                                      craplot.cdagenci = aux_cdagenci AND
                                                      craplot.cdbccxlt = aux_cdbccxlt AND
                                                      craplot.nrdolote = 10119
                                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                   IF   NOT AVAILABLE craplot   THEN
                                        IF   LOCKED craplot   THEN
                                             DO:
                                                 PAUSE 1 NO-MESSAGE.
                                                 NEXT.
                                             END.
                                        ELSE
                                             DO:
                                                 CREATE craplot.
                                                 ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                                        craplot.cdagenci = aux_cdagenci
                                                        craplot.cdbccxlt = aux_cdbccxlt
                                                        craplot.tplotmov = 1
                                                        craplot.cdcooper = aux_cdcooper
                                                        craplot.nrdolote = 10119.                                                 
                                             END.                   
                                  LEAVE.
                               END.
                               
                               DO aux_verifloc = 1 TO 10:
                                                              
                                  /* VIACON - aux_nrctalcm deve conter a nova conta se for conta incorporada  */ 
                                  FIND craplcm WHERE craplcm.cdcooper = aux_cdcooper     AND
                                                     craplcm.dtmvtolt = craplot.dtmvtolt AND
                                                     craplcm.cdagenci = craplot.cdagenci AND
                                                     craplcm.cdbccxlt = craplot.cdbccxlt AND
                                                     craplcm.nrdolote = craplot.nrdolote AND
                                                     craplcm.nrdctabb = aux_nrctalcm     AND
                                                     craplcm.nrdocmto = crapcdb.nrcheque  
                                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                     
                                  IF   NOT AVAIL craplcm THEN
                                       DO:
                                           IF   LOCKED craplcm THEN
                                                DO:
                                                    glb_cdcritic = 77.
                                                    PAUSE 1 NO-MESSAGE.
                                                    NEXT.
                                                END.
                                           ELSE
                                                DO: 
                                                    glb_cdcritic = 0.
                                                    LEAVE.
                                                END.
                                       END.
                                  ELSE
                                       DO:
                                           glb_cdcritic = 92.
                                           LEAVE.
                                       END.
                               END.

                               IF   glb_cdcritic <> 0 THEN
                                    DO:
                                        RUN fontes/critic.p.
                                        PAUSE(2) NO-MESSAGE.
                                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                                          " - " + glb_cdprogra + "' --> '"  +
                                                          glb_dscritic +
                                                          " Coop: " + STRING(aux_cdcooper) + 
                                                          " Data: " + STRING(craplot.dtmvtolt) +
                                                          " Lote: " + STRING(craplot.nrdolote) + 
                                                          " CTA: " + STRING(aux_nrctalcm) +
                                                          " CBS: " + STRING(crapdev.nrdctabb) +
                                                          " DOC: " + STRING(crapdev.nrcheque) +
                                                          " >> log/proc_message.log").

                                        glb_cdcritic = 0.

                                        UNDO, RETURN "NOK".
                               END.
                               
                               CREATE craplcm.
                               ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                                      craplcm.cdagenci = craplot.cdagenci
                                      craplcm.cdbccxlt = craplot.cdbccxlt
                                      craplcm.nrdolote = craplot.nrdolote
                                      craplcm.nrdconta = crapcdb.nrdconta
                                      craplcm.nrdctabb = aux_nrctalcm
                                      craplcm.nrdocmto = crapcdb.nrcheque
                                      craplcm.cdhistor = 399
                                      craplcm.nrseqdig = craplot.nrseqdig + 1
                                      craplcm.vllanmto = crapdev.vllanmto
                                      craplcm.cdoperad = crapdev.cdoperad
                                      craplcm.cdpesqbb = IF   crapdev.cdalinea <> 0 THEN
                                                              STRING(crapdev.cdalinea)
                                                         ELSE "21"
                                      craplcm.cdcooper = crapcdb.cdcooper
                                      craplcm.cdbanchq = crapcdb.cdbanchq
                                      craplcm.cdagechq = crapcdb.cdagechq
                                      craplcm.nrctachq = crapcdb.nrctachq
                                      craplcm.hrtransa = TIME
                                      
                                      craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
                                      craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto
                                      craplot.qtinfoln = craplot.qtinfoln + 1
                                      craplot.qtcompln = craplot.qtcompln + 1
                                      craplot.nrseqdig = craplot.nrseqdig + 1 NO-ERROR.

                               VALIDATE craplot.
                               VALIDATE craplcm.
                               
                               ASSIGN crapcdb.insitchq = 3.  /* Devolvido */
                           END.
                       ELSE /* nao encontrou crapcdb */
                           DO:
                              /* Custodia */
                              FOR LAST crapcst FIELDS(cdcooper nrdconta nrcheque cdbanchq cdagechq nrctachq insitchq) 
                                                WHERE crapcst.cdcooper = aux_cdcooper
                                                  AND crapcst.cdcmpchq = crapfdc.cdcmpchq
                                                  AND crapcst.cdbanchq = crapfdc.cdbanchq
                                                  AND crapcst.cdagechq = crapfdc.cdagechq
                                                  AND crapcst.nrctachq = crapfdc.nrctachq
                                                  AND crapcst.nrcheque = crapfdc.nrcheque
                                                  AND CAN-DO("0,2",STRING(crapcst.insitchq))
												  AND crapcst.dtdevolu = ?
												  AND crapcst.nrborder = 0
                                                  EXCLUSIVE-LOCK:
                              END.
                        
                              IF  AVAILABLE crapcst THEN
                                  DO:
                                      /* criar lancamento com o historico 351 e lote 10119 */
                                      DO  WHILE TRUE:
                                
                                          FIND craplot WHERE craplot.cdcooper = aux_cdcooper AND
                                                             craplot.dtmvtolt = glb_dtmvtolt AND
                                                             craplot.cdagenci = aux_cdagenci AND
                                                             craplot.cdbccxlt = aux_cdbccxlt AND
                                                             craplot.nrdolote = 10119
                                                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                          IF   NOT AVAILABLE craplot   THEN
                                               IF   LOCKED craplot   THEN
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT.
                                                    END.
                                               ELSE
                                                    DO:
                                                        CREATE craplot.
                                                        ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                                               craplot.cdagenci = aux_cdagenci
                                                               craplot.cdbccxlt = aux_cdbccxlt
                                                               craplot.tplotmov = 1
                                                               craplot.cdcooper = aux_cdcooper
                                                               craplot.nrdolote = 10119.                                                        
                                                    END.                   
                                         LEAVE.
                                      END.
                                      
                                      DO  aux_verifloc = 1 TO 10:
                                                              
                                          /* VIACON - aux_nrctalcm deve conter a nova conta se for conta incorporada  */ 
                                          FIND craplcm WHERE craplcm.cdcooper = aux_cdcooper     AND
                                                             craplcm.dtmvtolt = craplot.dtmvtolt AND
                                                             craplcm.cdagenci = craplot.cdagenci AND
                                                             craplcm.cdbccxlt = craplot.cdbccxlt AND
                                                             craplcm.nrdolote = craplot.nrdolote AND
                                                             craplcm.nrdctabb = aux_nrctalcm     AND
                                                             craplcm.nrdocmto = crapcst.nrcheque  
                                                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                             
                                          IF   NOT AVAIL craplcm THEN
                                               DO:
                                                   IF   LOCKED craplcm THEN
                                                        DO:
                                                            glb_cdcritic = 77.
                                                            PAUSE 1 NO-MESSAGE.
                                                            NEXT.
                                                        END.
                                                   ELSE
                                                        DO: 
                                                            glb_cdcritic = 0.
                                                            LEAVE.
                                                        END.
                                               END.
                                          ELSE
                                               DO:
                                                   glb_cdcritic = 92.
                                                   LEAVE.
                                               END.
                                       END.

                                       IF   glb_cdcritic <> 0 THEN
                                            DO:
                                                RUN fontes/critic.p.
                                                PAUSE(2) NO-MESSAGE.
                                                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                                                  " - " + glb_cdprogra + "' --> '"  +
                                                                  glb_dscritic +
                                                                  " Coop: " + STRING(aux_cdcooper) + 
                                                                  " Data: " + STRING(craplot.dtmvtolt) +
                                                                  " Lote: " + STRING(craplot.nrdolote) + 
                                                                  " CTA: " + STRING(aux_nrctalcm) +
                                                                  " CBS: " + STRING(crapdev.nrdctabb) +
                                                                  " DOC: " + STRING(crapdev.nrcheque) +
                                                                  " >> log/proc_message.log").

                                                glb_cdcritic = 0.
                                                UNDO, RETURN "NOK".
                                       END.
                                      
									                     /*P565.1-RF20 Se encontrar um lançamento anterior com o histórico 2662, 
                                         faz um lançamento pelo histórico 2973, senao faz pelo histórico 351 */
                                       FIND FIRST craplcm1 
                                            WHERE craplcm1.cdcooper = aux_cdcooper     AND
                                                  craplcm1.nrdconta = crapcst.nrdconta AND
                                                  craplcm1.nrdocmto = crapcst.nrdocmto AND
                                                  craplcm1.cdhistor = 2662   /*DEPOSITO DE CHEQUES EM CUSTODIA*/                                                         
                                                  NO-LOCK NO-ERROR.

                                           IF AVAILABLE craplcm1 THEN
                                           DO:
                                             ASSIGN  aux2_cdhistor = 2973. /*DEVOLUCAO DE CHEQUE ACOLHIDO EM DEPOSITO - SALDO BLOQUEADO*/
                                             
                                             /*Buscar o registro bloqueado*/
                                             FIND FIRST crapdpb  WHERE crapdpb.cdcooper = aux_cdcooper
                                                                   AND crapdpb.dtmvtolt = craplcm1.dtmvtolt
                                                                   AND crapdpb.cdagenci = craplcm1.cdagenci    
                                                                   AND crapdpb.cdbccxlt = craplcm1.cdbccxlt 
                                                                   AND crapdpb.nrdolote = craplcm1.nrdolote  
                                                                   AND crapdpb.nrdconta = craplcm1.nrdconta
                                                                   AND crapdpb.nrdocmto = craplcm1.nrdocmto
                                                                   EXCLUSIVE-LOCK  NO-ERROR.
                                                                   
                                             IF AVAILABLE crapdpb THEN
                                             DO:  
                                               ASSIGN crapdpb.vllanmto = crapdpb.vllanmto - crapdev.vllanmto.
                                               VALIDATE crapdpb.
                                             END.
                                           END.  
                                           ELSE
                                             ASSIGN  aux2_cdhistor = 351.  /*DEVOLUCAO DE CHEQUE ACOLHIDO EM DEPOSITO - SALDO LIBERADO*/
                                      
                                      CREATE craplcm.
                                      ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                                             craplcm.cdagenci = craplot.cdagenci
                                             craplcm.cdbccxlt = craplot.cdbccxlt
                                             craplcm.nrdolote = craplot.nrdolote
                                             craplcm.nrdconta = crapcst.nrdconta
                                             craplcm.nrdctabb = aux_nrctalcm
                                             craplcm.nrdocmto = crapcst.nrcheque
                                             craplcm.cdhistor = aux2_cdhistor  /*P565.1-RF20*/
                                             craplcm.nrseqdig = craplot.nrseqdig + 1
                                             craplcm.vllanmto = crapdev.vllanmto
                                             craplcm.cdoperad = crapdev.cdoperad
                                             craplcm.cdpesqbb = IF   crapdev.cdalinea <> 0 THEN
                                                                     STRING(crapdev.cdalinea)
                                                                ELSE "21"
                                             craplcm.cdcooper = crapcst.cdcooper
                                             craplcm.cdbanchq = crapcst.cdbanchq
                                             craplcm.cdagechq = crapcst.cdagechq
                                             craplcm.nrctachq = crapcst.nrctachq
                                             craplcm.hrtransa = TIME
                                             
                                             craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
                                             craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto
                                             craplot.qtinfoln = craplot.qtinfoln + 1
                                             craplot.qtcompln = craplot.qtcompln + 1
                                             craplot.nrseqdig = craplot.nrseqdig + 1 NO-ERROR.
                                    
                                      VALIDATE craplot.
                                      VALIDATE craplcm.
                                      
                                      ASSIGN crapcst.insitchq = 3.  /* Devolvido */
                                  END.
                           END.
                    END. /* crapdev.cdhistor = 47 */
        
        IF   crapdev.cdpesqui = "TCO" THEN
             ASSIGN aux_cdcooper = p-cdcooper
                    aux_nrdconta = crapdev.nrdconta.
            END.
        ELSE /* Conta = 0 */
            DO:                  
                /*  CECRED */
                /* Diurna e Noturna */
                IF  p-cddevolu = 5 OR p-cddevolu = 6 THEN                             
                    DO:
                        IF  crapdev.cdbanchq <> crapcop.cdbcoctl THEN
                            NEXT.    
                    END.
              /*ELSE Estava impedindo que cheques com alinea 35 
				     tivessem seus campos atualizados para serem 
					 processados e constarem no Relatorio 219 */ 
                  /* Verificar se alinea do cheque devolvido é 35 */
                  IF  crapdev.cdalinea = 35 THEN
                      ASSIGN crapdev.insitdev = 1
                             crapdev.indevarq = 2.
            END.
        
        VALIDATE crapdev.
		
        IF crapdev.nrdconta > 0 THEN
        DO:
            /*Inicio tratamento estorno da tarifa de ADP*/
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
            /* Procedure para gerar o estorno da tarifa de ADP quando aplicavel */
            RUN STORED-PROCEDURE pc_estorno_tarifa_adp
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT crapdev.cdcooper, /* Cooperativa */
                                         INPUT crapdev.nrdconta, /* Nr. da conta */
                                         OUTPUT ""). /* Descricao do erro */
            
            CLOSE STORED-PROC pc_estorno_tarifa_adp
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                  
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_dscritic = pc_estorno_tarifa_adp.pr_dscritic
                                      WHEN pc_estorno_tarifa_adp.pr_dscritic <> ?.
            
            IF  aux_dscritic <> ""  THEN
                DO:
                     ASSIGN glb_dscritic = aux_dscritic.
                     RUN fontes/critic.p.
                     PAUSE(2) NO-MESSAGE.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '"  +
                                       glb_dscritic +
                                       " Coop: " + STRING(crapdev.cdcooper) + 
                                       " Conta: " + STRING(crapdev.nrdconta) +
                                       " >> log/proc_message.log").

                      glb_cdcritic = 0.
                      UNDO, RETURN "NOK".
                END.
            /*Fim tratamento estorno da tarifa ADP*/
        END.
            
    END.  /*  Fim do FOR EACH e da transacao  */
    
    IF  VALID-HANDLE(h-b1wgen0153) THEN
        DELETE OBJECT h-b1wgen0153.

    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */
    
PROCEDURE gera_impressao:

    DEF VAR aux_nmarqtmp AS CHAR    FORMAT "x(40)"                NO-UNDO.
    DEF VAR aux_tprelato AS INT                                   NO-UNDO.
    DEF VAR aux_nmrelato AS CHAR                                  NO-UNDO.
    DEF VAR aux_cdrelato AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR    FORMAT "x(40)"                NO-UNDO.
    DEF VAR aux_dsdevolu AS CHAR    FORMAT "x(6)"                 NO-UNDO.

    FORM SKIP(3)
         aux_nmcidade    FORMAT "x(14)" "," 
         glb_dtmvtolt    FORMAT "99/99/9999"
         "."  
         SKIP(1)
         "Ao" SKIP
         aux_nmdbanco    FORMAT "x(20)"
         SKIP(3)
         "Solicitamos devolucao dos cheques do dia"
         glb_dtmvtoan FORMAT "99/99/9999"
         "abaixo relacionados."
         SKIP(2)
         WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_brasil.
    
    FORM "Banco  Age. Cta. Cheque    Cheque         Valor Alinea Titular(es)"
         SKIP
         "CPF/CNPJ/CONTA/PESQUISA"                  AT 56
         SKIP
         "----------------------------------------" AT 1
         "----------------------------------------" AT 41
         WITH NO-BOX NO-LABELS FRAME f_cabecalho.
       
    FORM crapdev.cdbanchq  FORMAT "z,zz9"          AT 01   NO-LABEL
         crapdev.cdagechq  FORMAT "z,zz9"          AT 07   NO-LABEL
         aux_nrdctitg      FORMAT "9.999.999-X"    AT 13   NO-LABEL
         crapdev.nrcheque  FORMAT "zzz,zz9,9"      AT 25   NO-LABEL
         crapdev.vllanmto  FORMAT "zz,zzz,zz9.99"  AT 35   NO-LABEL
         crapdev.cdalinea  FORMAT "z9"             AT 51   NO-LABEL
         crapass.nmprimtl  FORMAT "x(25)"          AT 56   NO-LABEL 
         SKIP
         rel_nrcpfcgc      FORMAT "x(18)"          AT 56   NO-LABEL
         crapdev.nrdconta  FORMAT "zzzz,zzz,9"     AT 75   NO-LABEL
         SKIP
         crapdev.cdpesqui  FORMAT "x(55)"          AT 56   NO-LABEL
         WITH NO-BOX WIDTH 132 NO-LABELS DOWN FRAME f_lanctos.
 
    FORM SKIP(3)
         "  TOTAL   "
         rel_qtchqdev 
         rel_vlchqdev
         SKIP(2)
         "  Atenciosamente"
         SKIP(2)
         rel_nmrescop[1] FORMAT "x(40)"
         SKIP
         rel_nmrescop[2] FORMAT "x(40)"
         WITH NO-BOX NO-LABELS FRAME f_fim.
     
    FORM SKIP(3)
         "  TOTAL   "
         rel_qtchqdev 
         rel_vlchqdev
         WITH NO-BOX NO-LABELS FRAME f_fim_resumido.
    
    FORM "Relacao dos cheques devolvidos no dia" AT 20
         glb_dtmvtolt  NO-LABEL FORMAT "99/99/9999"
         SKIP(2)
         WITH NO-LABELS FRAME f_relacao.

    FORM crapass.nrdconta LABEL "Conta/dv"
         crapass.nmprimtl LABEL "Titular"       FORMAT "x(40)" 
         aux_dstipcta     LABEL "Tipo de conta" 
         crapdev.nrctachq LABEL "Conta Cheque"  FORMAT "zzzz,zz9,9"
         crapdev.nrcheque LABEL "Cheque"        FORMAT "zzz,zz9,9"
         crapdev.vllanmto LABEL "Valor"         FORMAT "zzzz,zz9.99"
         crapdev.cdalinea LABEL "Al"            FORMAT "z9"
         crapass.cdagenci LABEL "Pa"            FORMAT "zz9"
         crapope.nmoperad LABEL "Operador"      FORMAT "x(20)"
         WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_todos.

    /* Titulo do relatorio deve ser CECRED */
    FIND crabcop WHERE crabcop.cdcooper = 3 NO-LOCK NO-ERROR.

    IF  NOT AVAIL crabcop THEN
        DO:
             glb_cdcritic = 651.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '"  +
                               glb_dscritic + " >> logo/proc_bath").
             RETURN "NOK".
         END.

    ASSIGN glb_nmrescop = crabcop.nmrescop.

    { includes/cabrel080_1.i }

    /*** Busca dados da cooperativa ***/
    FIND crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop  THEN
         DO:
             glb_cdcritic = 651.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '"  +
                               glb_dscritic + " >> logo/proc_bath").
             RETURN "NOK".
         END.    

    ASSIGN aux_nmcidade = TRIM(crapcop.nmcidade)
           aux_nmarquiv = "rl/crrl219_" + STRING(p-cddevolu,"9") + ".lst".
            
    CASE p-cddevolu:
         /*  BANCOOB  */
         WHEN 1 THEN aux_nmarqdev = "devolu_bancoob.txt".

         /*  CONTA BASE  */
         WHEN 2 THEN aux_nmarqdev = "devolu_base.txt".

         /*  CONTA INTEGRACAO  */
         WHEN 3 THEN aux_nmarqdev = "devolu_itg.txt".
    END CASE.     

    OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv) PAGED PAGE-SIZE 80.

    VIEW STREAM str_1 FRAME f_cabrel080_1.

    /*  Relacao para o envio ao Banco do Brasil (sem Desconto e Custodia)  */
    
    FOR EACH crapdev WHERE crapdev.cdcooper = p-cdcooper          AND
                           crapdev.cdbanchq = aux_cdbanchq        AND
                           crapdev.insitdev = 1                   AND
                           crapdev.cdhistor <> 46                 AND
                           crapdev.cdalinea > 0                   AND
                           crapdev.cdpesqui = ""                  NO-LOCK,
        EACH crapass WHERE crapass.cdcooper = p-cdcooper          AND
                           crapass.nrdconta = crapdev.nrdconta    AND
                         ((p-cddevolu = 1)                        OR
                          (p-cddevolu = 2                         AND
                           crapass.nrdctitg <> crapdev.nrdctitg)  OR
                          (p-cddevolu = 3                         AND
                           crapass.nrdctitg = crapdev.nrdctitg))  NO-LOCK
                           BREAK BY crapdev.cdbccxlt
                                    BY crapdev.nrdctabb
                                        BY crapdev.nrcheque:

        IF   FIRST-OF(crapdev.cdbccxlt) OR 
             LINE-COUNTER(str_1) > 80   THEN
             DO:
                  IF  FIRST-OF(crapdev.cdbccxlt) THEN
                      ASSIGN rel_qtchqdev = 0
                             rel_vlchqdev = 0.

                  CASE p-cddevolu:
                      WHEN 1 THEN aux_nmdbanco = "BANCOOB".
                      OTHERWISE   aux_nmdbanco = "BANCO DO BRASIL".
                  END CASE.

                  DISPLAY STREAM str_1 aux_nmcidade glb_dtmvtolt
                                       aux_nmdbanco glb_dtmvtoan  
                                       WITH FRAME f_brasil.

                  VIEW STREAM str_1 FRAME f_cabecalho.
             END.

        IF   p-cddevolu = 2                     AND    /*  CONTA BASE  */
             crapdev.cdhistor =  47             AND        
             crapdev.dtmvtolt <> glb_dtmvtolt   THEN
             NEXT.
    
        IF   crapass.inpessoa = 1 THEN
             ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
        ELSE
             ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
             
        ASSIGN rel_qtchqdev = rel_qtchqdev + 1
               rel_vlchqdev = rel_vlchqdev + crapdev.vllanmto.
          
        IF   p-cddevolu = 3 THEN                 /*  CONTA INTEGRACAO  */
             DISPLAY STREAM str_1  
                     crapdev.cdbanchq   crapdev.cdagechq
                     crapdev.nrdctitg @ aux_nrdctitg
                     crapdev.nrcheque   crapdev.vllanmto   
                     crapdev.cdalinea   crapass.nmprimtl   
                     crapdev.nrdconta   rel_nrcpfcgc
                     WITH FRAME f_lanctos.
        ELSE                                   /*  CONTA BASE  E  BANCOOB  */
             DO:
                 RUN fontes/digbbx.p(INPUT  crapdev.nrctachq,
                                     OUTPUT glb_dsdctitg,
                                     OUTPUT glb_stsnrcal). 
                 aux_nrdctitg = glb_dsdctitg.
                      
                 DISPLAY STREAM str_1
                     crapdev.cdbanchq   crapdev.cdagechq
                     aux_nrdctitg       crapdev.nrcheque
                     crapdev.vllanmto   crapdev.cdalinea
                     crapass.nmprimtl WHEN
                               (CAN-DO("12,13",STRING(crapdev.cdalinea)) OR
                               (crapdev.cdalinea = 11                    AND 
                                crapdev.cdbccxlt = 756)                  OR
                               (crapdev.cdalinea = 11                    AND 
                                crapdev.cdbccxlt = crapcop.cdbcoctl))
                     rel_nrcpfcgc WHEN 
                               (CAN-DO("12,13",STRING(crapdev.cdalinea)) OR
                               (crapdev.cdalinea = 11                    AND 
                                crapdev.cdbccxlt = 756)                  OR
                               (crapdev.cdalinea = 11                    AND 
                                crapdev.cdbccxlt = crapcop.cdbcoctl))
                     WITH FRAME f_lanctos.
             END.        

        DOWN STREAM str_1 WITH FRAME f_lanctos.

        IF   LAST-OF(crapdev.cdbccxlt) THEN
             DO:
                 /* Rotina p/ dividir campo crapcop.nmextcop em duas Strings */

                 ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ")
                                       / 2
                        rel_nmrescop = "".

                 DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):

                    IF   aux_contapal <= aux_qtpalavr   THEN
                         rel_nmrescop[1] = rel_nmrescop[1] +
                                           (IF TRIM(rel_nmrescop[1]) = ""
                                           THEN "" ELSE " ") +
                                       ENTRY(aux_contapal,crapcop.nmextcop," ").
                    ELSE
                         rel_nmrescop[2] = rel_nmrescop[2] +
                                           (IF TRIM(rel_nmrescop[2]) = ""
                                           THEN "" ELSE " ") +
                                       ENTRY(aux_contapal,crapcop.nmextcop," ").
                 END.  /*  Fim DO .. TO  */ 

                 ASSIGN rel_nmrescop[1] = FILL(" ",20 - 
                                             INT(LENGTH(rel_nmrescop[1]) / 2)) +
                                             rel_nmrescop[1]
                        rel_nmrescop[2] = FILL(" ",20 - 
                                             INT(LENGTH(rel_nmrescop[2]) / 2)) +
                                             rel_nmrescop[2].
                 /*  Fim da Rotina  */

                 DISPLAY STREAM str_1 rel_qtchqdev rel_vlchqdev rel_nmrescop
                                      WITH FRAME f_fim.

                 PAGE STREAM str_1.
             END.

    END.  /** Fim do FOR EACH crapdev **/

    /*  Relacao somente para Desconto de Cheques e Custodia  */
    FOR EACH crapdev WHERE crapdev.cdcooper = p-cdcooper          AND
                           crapdev.cdbanchq = aux_cdbanchq        AND
                           crapdev.insitdev = 1                   AND
                           crapdev.cdhistor <> 46                 AND
                           crapdev.cdalinea > 0                   AND
                          (crapdev.cdpesqui <> ""                 AND
                           crapdev.cdpesqui <> "TCO")             NO-LOCK, 
        EACH crapass WHERE crapass.cdcooper = p-cdcooper          AND
                           crapass.nrdconta = crapdev.nrdconta    AND
                         ((p-cddevolu = 1)                        OR
                          (p-cddevolu = 2                         AND
                           crapass.nrdctitg <> crapdev.nrdctitg)  OR
                          (p-cddevolu = 3                         AND
                           crapass.nrdctitg = crapdev.nrdctitg))  NO-LOCK
                           BREAK BY crapdev.cdbccxlt
                                    BY crapdev.nrdctabb
                                       BY crapdev.nrcheque:

        IF   FIRST-OF(crapdev.cdbccxlt) OR 
             LINE-COUNTER(str_1) > 80   THEN
             DO:
                  IF  FIRST-OF(crapdev.cdbccxlt) THEN
                      ASSIGN rel_qtchqdev = 0
                             rel_vlchqdev = 0.

                  IF   p-cddevolu = 1 THEN
                       aux_nmdbanco = "BANCOOB".
                  ELSE
                       aux_nmdbanco = "BANCO DO BRASIL".

                  DISPLAY STREAM str_1 aux_nmcidade glb_dtmvtolt
                                       aux_nmdbanco glb_dtmvtoan  
                                       WITH FRAME f_brasil.

                  VIEW STREAM str_1 FRAME f_cabecalho.
             END.

        IF   p-cddevolu = 2                     AND    /*  CONTA BASE  */
             crapdev.cdhistor =  47             AND        
             crapdev.dtmvtolt <> glb_dtmvtolt   THEN
             NEXT.

        IF   crapass.inpessoa = 1 THEN
             ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
        ELSE
             ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

        ASSIGN rel_qtchqdev = rel_qtchqdev + 1
               rel_vlchqdev = rel_vlchqdev + crapdev.vllanmto.

        IF   p-cddevolu = 3 THEN          /*  CONTA INTEGRACAO  */
             DISPLAY STREAM str_1  
                     crapdev.cdbanchq   crapdev.cdagechq
                     crapdev.nrdctitg @ aux_nrdctitg
                     crapdev.nrcheque   crapdev.vllanmto   
                     crapdev.cdalinea   crapass.nmprimtl   
                     crapdev.nrdconta   rel_nrcpfcgc
                     crapdev.cdpesqui   WITH FRAME f_lanctos.
        ELSE                             /*  CONTA BASE, BANCOOB E CECRED  */
             DO:
                 RUN fontes/digbbx.p(INPUT  crapdev.nrctachq,
                                     OUTPUT glb_dsdctitg,
                                     OUTPUT glb_stsnrcal). 
                 aux_nrdctitg = glb_dsdctitg.
                      
                 DISPLAY STREAM str_1  
                     crapdev.cdbanchq   crapdev.cdagechq
                     aux_nrdctitg       crapdev.nrcheque
                     crapdev.vllanmto   crapdev.cdalinea
                     crapass.nmprimtl WHEN
                                    (CAN-DO("12,13",STRING(crapdev.cdalinea)) OR
                                    (crapdev.cdalinea = 11    AND 
                                     crapdev.cdbccxlt = 756)                  OR
                                    (crapdev.cdalinea = 11    AND 
                                     crapdev.cdbccxlt = crapcop.cdbcoctl))
                     rel_nrcpfcgc WHEN 
                                    (CAN-DO("12,13",STRING(crapdev.cdalinea)) OR
                                    (crapdev.cdalinea = 11 AND 
                                     crapdev.cdbccxlt = 756)                  OR
                                    (crapdev.cdalinea = 11    AND 
                                     crapdev.cdbccxlt = crapcop.cdbcoctl))
                     crapdev.cdpesqui       WITH FRAME f_lanctos.
             END.        

        DOWN STREAM str_1 WITH FRAME f_lanctos.

        IF   LAST-OF(crapdev.cdbccxlt) THEN
             DO:
                 DISPLAY STREAM str_1 rel_qtchqdev rel_vlchqdev rel_nmrescop
                                      WITH FRAME f_fim.

                 PAGE STREAM str_1.
             END.

    END.  /** Fim do FOR EACH crapdev **/

    DISPLAY STREAM str_1 glb_dtmvtolt WITH FRAME f_relacao.

    FOR EACH crapdev WHERE crapdev.cdcooper = p-cdcooper          AND
                           crapdev.cdbanchq = aux_cdbanchq        AND
                           crapdev.insitdev = 1                   AND
                           crapdev.cdhistor <> 46                 AND
                           crapdev.cdalinea > 0                   AND
                           crapdev.cdpesqui <> "TCO"              NO-LOCK, 
        EACH crapass WHERE crapass.cdcooper = p-cdcooper          AND
                           crapass.nrdconta = crapdev.nrdconta    AND
                         ((p-cddevolu = 1)                        OR
                          (p-cddevolu = 2                         AND
                           crapass.nrdctitg <> crapdev.nrdctitg)  OR
                          (p-cddevolu = 3                         AND
                           crapass.nrdctitg = crapdev.nrdctitg))  NO-LOCK,
        EACH crapope WHERE crapope.cdcooper = p-cdcooper          AND
                           crapope.cdoperad = crapdev.cdoperad    NO-LOCK
                           BREAK BY crapdev.cdbccxlt
                                 BY crapdev.nrdctabb
                                 BY crapdev.nrcheque:

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
        RUN STORED-PROCEDURE pc_descricao_tipo_conta
          aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                   INPUT crapass.cdtipcta, /* Tipo de conta */
                                  OUTPUT "",               /* Descrição do Tipo de conta */
                                  OUTPUT "",               /* Flag Erro */
                                  OUTPUT "").              /* Descrição da crítica */
        
        CLOSE STORED-PROC pc_descricao_tipo_conta
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
        ASSIGN aux_dstipcta = ""
               aux_des_erro = ""
               aux_dscritic = ""
               aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                               WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
               aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                               WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
               aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                               WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
 
        IF aux_des_erro = "NOK"  THEN
           DO:
               glb_dscritic = aux_dscritic.
               UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                 glb_cdprogra + "' --> '" + glb_dscritic +
                                 " CRED-GENERI-00-VALORESVLB-001 " +
                                 " >> log/proc_message.log").
               RETURN.
           END.

        IF   LINE-COUNTER(str_1) > 80 THEN
             DO:
                 PAGE STREAM str_1.
                 DISPLAY STREAM str_1 glb_dtmvtolt WITH FRAME f_relacao.
             END.    

        IF   FIRST-OF(crapdev.cdbccxlt) THEN
             ASSIGN rel_qtchqdev = 0
                    rel_vlchqdev = 0.

        DISPLAY STREAM str_1 crapass.nrdconta  crapass.nmprimtl
                             aux_dstipcta      crapdev.nrctachq
                             crapdev.nrcheque  crapdev.vllanmto
                             crapdev.cdalinea  crapass.cdagenci
                             crapope.nmoperad  WITH FRAME f_todos.
        DOWN STREAM str_1 WITH FRAME f_todos.
             
             
        ASSIGN rel_qtchqdev = rel_qtchqdev + 1
               rel_vlchqdev = rel_vlchqdev + crapdev.vllanmto.

        IF   LAST-OF(crapdev.cdbccxlt) THEN
             DO:
                 DISPLAY STREAM str_1 rel_qtchqdev  rel_vlchqdev 
                                      rel_nmrescop  WITH FRAME f_fim_resumido.
       
                 PAGE STREAM str_1.
             END.
    END.                          

    OUTPUT STREAM str_1 CLOSE.

    /*  Salvar copia relatorio para "/rlnsv"  */
    UNIX SILENT VALUE("cp " + aux_nmarquiv + " rlnsv").

    UNIX SILENT VALUE("ux2dos " + aux_nmarquiv + " > /micros/" + 
                      crapcop.dsdircop + "/devolu/" + aux_nmarqdev).
    
    /* Gerar log da copia de arquivos */
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                      glb_cdprogra + "' --> '" +
                      " Cooperativa: " + STRING(p-cdcooper) +
                      " Executado os comandos: " + 
                      " Copiar arquivo " + aux_nmarquiv + " para  rlnsv " +
                      " e UX2DOS " + aux_nmarquiv + " para /micros/" + 
                      crapcop.dsdircop + "/devolu/" + aux_nmarqdev +
                      " >> log/proc_message.log").

    ASSIGN aux_tprelato = 0
           aux_nmrelato = " ".

    FIND craprel WHERE craprel.cdcooper = p-cdcooper AND
                       craprel.cdrelato = 219
                       NO-LOCK NO-ERROR.

    IF   AVAIL craprel  THEN
         DO:
             IF   craprel.tprelato = 2   THEN
                  ASSIGN aux_tprelato = 1.

             ASSIGN aux_nmrelato = craprel.nmrelato.
         END.

    ASSIGN aux_cdrelato = SUBSTR(aux_nmarquiv,
                          R-INDEX(aux_nmarquiv,"/") + 1)
           aux_nmarqtmp = "tmppdf/" + aux_cdrelato + ".txt"
           aux_nmarqpdf = SUBSTR(aux_cdrelato,1,
                                 LENGTH(aux_cdrelato) - 4) + ".pdf".

    OUTPUT STREAM str_2 TO VALUE (aux_nmarqtmp).

    PUT STREAM str_2 crapcop.nmrescop FORMAT "X(20)"                  ";"
                     STRING(YEAR(glb_dtmvtolt),"9999") FORMAT "x(04)" ";"
                     STRING(MONTH(glb_dtmvtolt),"99")  FORMAT "x(02)" ";"
                     STRING(DAY(glb_dtmvtolt),"99")    FORMAT "x(02)" ";"
                     STRING(aux_tprelato,"z9")         FORMAT "x(02)" ";"
                     aux_nmarqpdf                                     ";"
                     CAPS(aux_nmrelato)                FORMAT "x(50)" ";"
                     SKIP.

    OUTPUT STREAM str_2 CLOSE.

    UNIX SILENT VALUE("echo script/CriaPDF.sh " + aux_nmarquiv + " NAO 132col " +
                      STRING(YEAR(glb_dtmvtolt),"9999") + "_" + 
                      STRING(MONTH(glb_dtmvtolt),"99") + "/" + 
                      STRING(DAY(glb_dtmvtolt),"99") + " >> log/CriaPDF.log").
    
    UNIX SILENT VALUE("script/CriaPDF.sh " + aux_nmarquiv + " NAO 132col " +
                      STRING(YEAR(glb_dtmvtolt),"9999") + "_" + 
                      STRING(MONTH(glb_dtmvtolt),"99") + "/" + 
                      STRING(DAY(glb_dtmvtolt),"99")).

    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */

PROCEDURE gera_arquivo_ctaitg:

  DEF        VAR aux_cdseqarq AS INT                                   NO-UNDO.
  DEF        VAR aux_cdseqchq AS INT                                   NO-UNDO.
  DEF        VAR aux_nmarqdat AS CHAR                                  NO-UNDO.
  DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
  
  ASSIGN aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") +
                        STRING(MONTH(glb_dtmvtolt),"99") + 
                        STRING(DAY(glb_dtmvtolt),"99") + ".log".
  
  FIND craptab WHERE craptab.cdcooper = p-cdcooper    AND
                     craptab.nmsistem = "CRED"        AND
                     craptab.tptabela = "GENERI"      AND
                     craptab.cdempres = 00            AND
                     craptab.cdacesso = "NRARQMVITG"  AND
                     craptab.tpregist = 407           NO-LOCK NO-ERROR.

  IF   NOT AVAILABLE craptab   THEN
       DO:
           glb_cdcritic = 393.
           RUN fontes/critic.p.
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                             glb_cdprogra + "' --> '" + glb_dscritic + " >> " +
                             aux_nmarqlog).
           RETURN "NOK".
       END.    

  IF   INT(SUBSTR(craptab.dstextab,07,01)) = 1 THEN
       DO:
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                             glb_cdprogra + "' --> '"  +
                             "PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS" + " >> "
                             + aux_nmarqlog).
           RUN fontes/fimprg.p.
           RETURN "NOK".
       END.

  ASSIGN aux_cdseqarq = INTEGER(SUBSTR(craptab.dstextab,01,05))
         aux_flgfirst = TRUE
         aux_dtmovime = STRING(DAY(glb_dtmvtolt),"99") +
                        STRING(MONTH(glb_dtmvtolt),"99") +
                        STRING(YEAR(glb_dtmvtolt),"9999").

  FOR EACH crapdev WHERE crapdev.cdcooper = p-cdcooper     AND
                         crapdev.cdhistor <> 46            AND 
                         crapdev.insitdev = 1              AND
                         crapdev.indctitg = TRUE           AND
                         crapdev.cdalinea > 0              AND
                         crapdev.cdbccxlt = 1              AND
                         crapdev.cdpesqui = ""             NO-LOCK
                         BY crapdev.nrdctabb
                         BY crapdev.nrcheque:

      IF   aux_flgfirst  THEN
           DO:
               ASSIGN aux_cdseqchq = 0
                      aux_nmarqdat = "coo407" +
                                     STRING(DAY(glb_dtmvtolt),"99") + 
                                     STRING(MONTH(glb_dtmvtolt),"99") +
                                     STRING(aux_cdseqarq,"99999") + ".rem".

               IF   SEARCH("arq/" + aux_nmarqdat) <> ? THEN
                    UNIX SILENT VALUE("rm arq/" + aux_nmarqdat + 
                                      " 2>/dev/null").
                       
               OUTPUT STREAM str_2 TO VALUE("arq/" + aux_nmarqdat).
                
               /* ------------   Header do Arquivo   ------------  */

               PUT STREAM str_2 "0000000"
                                crapcop.cdageitg     FORMAT "9999"
                                crapcop.nrctaitg     FORMAT "99999999"
                                "COO407  "
                                aux_cdseqarq         FORMAT "99999"
                                aux_dtmovime         FORMAT "x(08)"
                                crapcop.cdcnvitg     FORMAT "999999999"
                                FILL(" ",21)         FORMAT "x(21)" 
                                SKIP.
             
               ASSIGN aux_flgfirst = FALSE.

           END.  /*  Fim  do  aux_flgfirst  */

      /*  limite maximo de registros  */

      IF   aux_cdseqchq > 1998 THEN 
           DO:
               /* ------------   Trailer do Arquivo   ------------  */
                 
               PUT STREAM str_2 "9999999"
                                (aux_cdseqchq + 2)    FORMAT "999999999"
                                FILL(" ",54)          FORMAT "x(54)" 
                                SKIP.
                 
               OUTPUT STREAM str_2 CLOSE.

               glb_cdcritic = 847.
               RUN fontes/critic.p.

               UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                                 glb_cdprogra + "' --> '"  + glb_dscritic + 
                                 "  " + aux_nmarqdat + " >> " + aux_nmarqlog).

               UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqdat + 
                                 ' | tr -d "\032"' + " > /micros/" +
                                 crapcop.dsdircop + "/compel/" + aux_nmarqdat +
                                 " 2>/dev/null").

               UNIX SILENT VALUE("mv arq/" + aux_nmarqdat + 
                                 " salvar 2>/dev/null").
                 
               ASSIGN aux_flgfirst = TRUE
                      aux_cdseqarq = aux_cdseqarq + 1.

               NEXT.
           END.
              
      FIND crapass WHERE crapass.cdcooper = p-cdcooper       AND
                         crapass.nrdconta = crapdev.nrdconta 
                         NO-LOCK NO-ERROR.
     
      IF   NOT AVAILABLE crapass THEN
           DO:
               glb_cdcritic = 009.
               RUN fontes/critic.p.
           
               UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                                 glb_cdprogra + "' --> '"  + glb_dscritic + " "
                                 + aux_nmarqdat + " >> log/proc_message.log").
                                 
               UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                 glb_cdprogra + "' --> '" + glb_dscritic +
                                 "  " + aux_nmarqdat + " >> " + aux_nmarqlog).
               glb_cdcritic = 0.
               NEXT.
           END.
      
      ASSIGN aux_cdseqchq = aux_cdseqchq + 1.
    
      ASSIGN glb_nrcalcul = INT(SUBSTR(STRING(crapdev.nrcheque,"9999999"),1,6)).
      
      PUT STREAM str_2 aux_cdseqchq              FORMAT "99999"
                       "01"
                       crapass.nrdctitg          FORMAT "9999999X"
                       "01"                   /* Incluir a Devolucao */
                       glb_nrcalcul              FORMAT "999999"
                       (crapdev.vllanmto * 100)  FORMAT "99999999999999999"
                       crapdev.cdalinea          FORMAT "9999"
                       crapdev.nrdconta          FORMAT "99999999"
                       FILL(" ",18)              FORMAT "x(18)" 
                       SKIP.
  END.

  IF   NOT aux_flgfirst THEN  /*  gerou algum arquivo  */
       DO:
           /* ------------   Trailer do Arquivo   ------------  */
                 
           PUT STREAM str_2 "9999999"
                            (aux_cdseqchq + 2)    FORMAT "999999999"
                            FILL(" ",54)          FORMAT "x(54)" 
                            SKIP.

           OUTPUT STREAM str_2 CLOSE.

           glb_cdcritic = 847.
           RUN fontes/critic.p.
            
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '"  + glb_dscritic + "  " +
                             aux_nmarqdat + " >> " + aux_nmarqlog).
           
           UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqdat + 
                             ' | tr -d "\032"' + " > /micros/" +
                             crapcop.dsdircop + "/compel/" + aux_nmarqdat + 
                             " 2>/dev/null").
           
           UNIX SILENT VALUE("mv arq/" + aux_nmarqdat + " salvar 2>/dev/null"). 
              
           DO TRANSACTION ON ENDKEY UNDO, LEAVE:

              /*   Atualiza a sequencia da remessa  */
               
              DO WHILE TRUE:

                 FIND craptab WHERE craptab.cdcooper = p-cdcooper   AND
                                    craptab.nmsistem = "CRED"       AND
                                    craptab.tptabela = "GENERI"     AND
                                    craptab.cdempres = 00           AND
                                    craptab.cdacesso = "NRARQMVITG" AND
                                    craptab.tpregist = 407
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE craptab   THEN
                      IF   LOCKED craptab   THEN
                           DO:
                               glb_cdcritic = 77.
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                           END.
                      ELSE
                           DO:
                               glb_cdcritic = 55.
                               LEAVE.
                           END.    
                 ELSE
                      glb_cdcritic = 0.

                 LEAVE.
            
              END.  /*  Fim do DO .. TO  */

              IF   glb_cdcritic > 0 THEN
                   DO:
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                        " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " >> " + aux_nmarqlog).
                      RETURN "NOK".
                   END.

              SUBSTR(craptab.dstextab,1,5) = STRING(aux_cdseqarq + 1, "99999").
           END.          /*  Transaction  */
       END.         /*  fim do aux_flgfirst  */

       RETURN "OK".

END PROCEDURE.

/* .......................................................................... */

PROCEDURE gera_arquivo_bancoob:

   DEF VAR aux_linhadet AS CHAR                                       NO-UNDO.
   DEF VAR aux_nrsequen AS INT                                        NO-UNDO.
   DEF VAR aux_vldtotal AS DEC                                        NO-UNDO.

   ASSIGN aux_dtmovime = STRING(YEAR(glb_dtmvtolt),"9999") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(DAY(glb_dtmvtolt),"99")
          aux_nmarqdev = "dev" + STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(DAY(glb_dtmvtolt),"99") + ".rem".
                         
   ASSIGN aux_nrsequen = 2
          aux_vldtotal = 0
          flg_devolbcb = FALSE.
   
   FOR EACH crapdev WHERE crapdev.cdcooper = p-cdcooper        AND
                          crapdev.cdbanchq = 756               AND
                          crapdev.insitdev = 1                 AND
                          crapdev.cdhistor <> 46               AND
                          crapdev.cdalinea > 0                 AND
                          crapdev.cdpesqui = ""                NO-LOCK,
       EACH crapass WHERE crapass.cdcooper = p-cdcooper        AND
                          crapass.nrdconta = crapdev.nrdconta  NO-LOCK
                          BREAK BY crapdev.nrctachq
                                BY crapdev.nrcheque:
       
       FIND LAST craplcm WHERE craplcm.cdcooper = p-cdcooper              AND
                               craplcm.nrdconta = crapdev.nrdconta        AND
                               craplcm.nrdocmto = crapdev.nrcheque        AND
                               craplcm.cdbccxlt = crapdev.cdbccxlt        AND
                               craplcm.nrdctabb = crapdev.nrdctabb        AND
                              CAN-DO("313,340,358,521,1873,1874",STRING(craplcm.cdhistor))
                              USE-INDEX craplcm2 NO-LOCK  NO-ERROR. 

       IF   AVAILABLE craplcm THEN
            DO:      
                IF flg_devolbcb = FALSE THEN 
                   DO:
                       OUTPUT STREAM str_2 TO VALUE("arq/" + aux_nmarqdev).
                       PUT STREAM str_2 FILL("0",47)         FORMAT "x(47)"
                                        "CEL605"
                                        "452000175601"
                                        aux_dtmovime         FORMAT "x(08)"
                                        FILL(" ",77)         FORMAT "x(77)"
                                        "0000000001"
                                        SKIP.
                
                       ASSIGN flg_devolbcb = TRUE.
                   END.

                aux_linhadet = SUBSTR(craplcm.cdpesqbb,1,53) + 
                               STRING(crapdev.cdalinea,"99") + 
                               SUBSTR(craplcm.cdpesqbb,56,95) +
                               STRING(aux_nrsequen,"9999999999").

                PUT STREAM str_2 aux_linhadet FORMAT "x(160)".

                PUT STREAM str_2 SKIP.

                ASSIGN aux_nrsequen = aux_nrsequen + 1
                       aux_vldtotal = aux_vldtotal + crapdev.vllanmto.

            END.
   END. 

   IF flg_devolbcb = TRUE THEN
      DO:
          PUT STREAM str_2 FILL("9",47)         FORMAT "x(47)"
                           "CEL605"
                           "452000175601"
                           aux_dtmovime         FORMAT "x(08)"
                           (aux_vldtotal * 100) FORMAT "99999999999999999"
                           FILL(" ",60)         FORMAT "x(60)"
                           aux_nrsequen         FORMAT "9999999999"
                           SKIP.

          OUTPUT STREAM str_2 CLOSE.

          UNIX SILENT VALUE("mv arq/" + aux_nmarqdev + " salvar 2>/dev/null").

          UNIX SILENT VALUE("ux2dos salvar/" + aux_nmarqdev + " > /micros/" +
                             crapcop.dsdircop + "/bancoob/" + aux_nmarqdev).
      END.

END PROCEDURE.

/*........................................................................... */

PROCEDURE gera_arquivo_cecred:

   DEF VAR aux_linhadet AS CHAR                                       NO-UNDO.
   DEF VAR aux_nrsequen AS INT                                        NO-UNDO.
   DEF VAR aux_vldtotal AS DEC                                        NO-UNDO.
   DEF VAR aux_mes      AS CHAR                                       NO-UNDO.
   DEF VAR aux_extensao AS CHAR                                       NO-UNDO.
   DEF VAR aux_dscooper AS CHAR                                       NO-UNDO.
   DEF VAR aux_cdcmpchq AS INT                                        NO-UNDO.
   DEF VAR aux_dsorigem AS CHAR    FORMAT "x(13)"                     NO-UNDO.
   DEF VAR aux_totqtcax AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
   DEF VAR aux_totvlcax AS DEC     FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
   DEF VAR aux_totqtdiu AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
   DEF VAR aux_totvldiu AS DEC     FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
   DEF VAR aux_totqtnot AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
   DEF VAR aux_totvlnot AS DEC     FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.

   DEF VAR aux_totqt        AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
   DEF VAR aux_totvl        AS DEC     FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
   DEF VAR aux_totqtdiu_age AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
   DEF VAR aux_totvldiu_age AS DEC     FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
   DEF VAR aux_totqtnot_age AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
   DEF VAR aux_totvlnot_age AS DEC     FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.

   DEF VAR aux_totqtdes AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
   DEF VAR aux_totvldes AS DEC     FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
   DEF VAR aux_totqtrej AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
   DEF VAR aux_totvlrej AS DEC     FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
   DEF VAR aux_totalqtd AS INT     FORMAT "zzz,zz9"                   NO-UNDO.
   DEF VAR aux_totalvlr AS DEC     FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
   DEF VAR aux_nmarqchq AS CHAR                                       NO-UNDO.
   DEF VAR aux_tprelato AS INT                                        NO-UNDO.
   DEF VAR aux_nmrelato AS CHAR                                       NO-UNDO.
   DEF VAR aux_cdrelato AS CHAR                                       NO-UNDO.
   DEF VAR aux_nmarqtmp AS CHAR    FORMAT "x(40)"                     NO-UNDO.
   DEF VAR aux_nmarqpdf AS CHAR    FORMAT "x(40)"                     NO-UNDO.
   DEF VAR aux_dstipcta AS CHAR    FORMAT "x(15)"                     NO-UNDO.
   DEF VAR aux_indevarq AS INT                                        NO-UNDO.
   DEF VAR aux_dssufarq AS CHAR                                       NO-UNDO.
   DEF VAR aux_cdbandep AS INT                                        NO-UNDO.
   DEF VAR aux_cdagedep AS INT                                        NO-UNDO.
   DEF VAR aux_cdtipdoc AS INT                                        NO-UNDO.
   DEF var aux_horatran AS INT                                        NO-UNDO.
   DEF VAR aux_primeira AS LOGICAL                                    NO-UNDO.          

   DEF VAR h-b1wgen0011 AS HANDLE                                     NO-UNDO.

   DEF VAR aux_tparquiv AS INT                                        NO-UNDO.

   DEF BUFFER b-crapdev FOR crapdev.
   
   DEF VAR vr_gerou_arquivo AS INT                                    NO-UNDO.
   
   FORM "Relacao dos cheques 085 devolvidos no dia" AT 20
         glb_dtmvtolt  NO-LABEL FORMAT "99/99/9999"
         SKIP(2)
         WITH NO-LABELS FRAME f_relacao.

   FORM "Conta/dv"       AT 01  
        "Titular"        AT 12 
        "Tipo de Conta"  AT 50
        "Cheque"         AT 66 
        "Valor"          AT 76 
        "Al"             AT 91 
        "PA"             AT 94 
        "Operador"       AT 98
        "Origem"         AT 107
        "Benefic."       AT 121
        "Reap.Aut.Cheq." AT 132
        SKIP          
        "Pesquisa"       AT 12
        SKIP
        "---------- -------------------------------------"         AT 01
        "--------------- --------- -------------- -- --- --------" AT 50
        "------------- ---------- --------------"                  AT 107
        WITH DOWN NO-BOX NO-LABELS WIDTH 234 FRAME f_cabec.

   FORM tt-relchdv.nrdconta AT 01  FORMAT "zzzz,zzz,9"                     
        tt-relchdv.nmprimtl AT 12  FORMAT "x(37)"                          
        tt-relchdv.dstipcta AT 50  FORMAT "x(15)"
        tt-relchdv.nrcheque AT 66  FORMAT "zzz,zzz,9"                      
        tt-relchdv.vllanmto AT 76  FORMAT "zzz,zzz,zz9.99"                 
        tt-relchdv.cdalinea AT 91  FORMAT "99"                             
        tt-relchdv.cdagenci AT 94  FORMAT "z99"                            
        tt-relchdv.cdoperad AT 98  FORMAT "x(08)"                          
        tt-relchdv.dsorigem AT 107 FORMAT "x(13)"                          
        tt-relchdv.benefici AT 121 FORMAT "x(10)"
        tt-relchdv.flgreapr AT 132 FORMAT "X(3)" 
        tt-relchdv.cdpesqui AT 012 FORMAT "x(37)"                          
        WITH DOWN NO-BOX NO-LABELS WIDTH 234 FRAME f_todos_cecred.

   FORM SKIP(1)
        "Quantidade"                                 AT 62   
        "Valor"                                      AT 86   
        SKIP(1)
        "TOTAL DE DEVOLUCOES CAIXA: "                AT 35
        aux_totqtcax                                 AT 65
        aux_totvlcax                                 AT 73
        SKIP(1)
        "TOTAL DE DEVOLUCOES NO ARQUIVO DIURNO: "    AT 23
        aux_totqtdiu                                 AT 65
        aux_totvldiu                                 AT 73
        SKIP(1)
        "TOTAL DE DEVOLUCOES NO ARQUIVO FRAUDE: "    AT 23
        aux_totqtnot                                 AT 65
        aux_totvlnot                                 AT 73
        SKIP(1)
        "TOTAL DE DEVOLUCOES NO CUSTODIA/DESCONTO: " AT 20
        aux_totqtdes                                 AT 65
        aux_totvldes                                 AT 73
        SKIP
        "-----------------------------"              AT 62
        SKIP(1)
        "TOTAL DE DEVOLUCOES: "                      AT 41
        aux_totalqtd                                 AT 65
        aux_totalvlr                                 AT 73
        SKIP(3)
        "TOTAL DE DEVOLUCOES COM ALINEA 37: "        AT 27
        aux_totqtrej                                 AT 65
        aux_totvlrej                                 AT 73

        
        WITH DOWN NO-BOX NO-LABELS WIDTH 234 FRAME f_totais.
   
   FIND FIRST crapage WHERE crapage.cdcooper = p-cdcooper AND 
                            crapage.flgdsede = TRUE
                            NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapage AND vr_gera_devolu_coop3 <> "S" THEN
        DO:
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                              glb_cdprogra + "' --> '" +
                              " PA Sede nao cadastrado." +
                              " Avise a Equipe de Suporte do AILOS." +
                              " Coop: " + STRING(p-cdcooper) +
                              " >> log/proc_message.log").
            RETURN "NOK".
        END.
   
   ASSIGN aux_dtmovime = STRING(YEAR(glb_dtmvtolt),"9999") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(DAY(glb_dtmvtolt),"99")
          aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".
   
   /* Nome Arquivo definido por ABBC 1agenMDD.DVD */
   /* 1    - Fixo
      agen - Cod Agen Central crapcop.cdagectl
      M    - Mes Movim.(1-9 = Jan-Set) O=Out N=Nov D=Dez
      N    - Fixo
      xx   - Numero do PA */

   IF   MONTH(glb_dtmvtolt) > 9 THEN
        CASE MONTH(glb_dtmvtolt):
             WHEN 10 THEN aux_mes = "O".
             WHEN 11 THEN aux_mes = "N".
             WHEN 12 THEN aux_mes = "D".
        END CASE.
   ELSE
        aux_mes = STRING(MONTH(glb_dtmvtolt),"9").

   /* 1a Exec = DVD | 2a Exec = DVT */

   IF   p-cddevolu = 5 THEN /* 1a Exec */
        ASSIGN aux_extensao = ".DVD"
               aux_nmarqchq = "rl/crrl219_5.lst"
               aux_nmarqdev = "devolu_cecred_diurna.txt"
               aux_dssufarq = "1".
   ELSE                     /* 2a Exec */
        ASSIGN aux_extensao = ".DVT"
               aux_nmarqchq = "rl/crrl219_6.lst"
               aux_nmarqdev = "devolu_cecred_noturna.txt"
               aux_dssufarq = "1".

   
   ASSIGN aux_nmarquiv = STRING(aux_dssufarq,"X(1)") + 
                         STRING(crapcop.cdagectl,"9999") + aux_mes +
                         STRING(DAY(glb_dtmvtolt),"99") +  aux_extensao.

   ASSIGN aux_nrsequen = 2
          aux_vldtotal = 0
          flg_devolbcb = FALSE.

   { includes/cabrel234_1.i }

   OUTPUT STREAM str_1 TO VALUE(aux_dscooper + aux_nmarqchq) PAGED PAGE-SIZE 84.

   VIEW STREAM str_1 FRAME f_cabrel234_1.
   
   ASSIGN aux_totqtcax = 0
          aux_totvlcax = 0
          aux_totqtdiu = 0
          aux_totvldiu = 0
          aux_totqtnot = 0
          aux_totvlnot = 0

          aux_totqtdiu_age = 0
          aux_totvldiu_age = 0
          aux_totqtnot_age = 0
          aux_totvlnot_age = 0

          aux_totqtdes = 0
          aux_totvldes = 0
          aux_totqtrej = 0
          aux_totvlrej = 0
          aux_totalqtd = 0
          aux_totalvlr = 0
          aux_tprelato = 1
          aux_primeira = TRUE
          aux_contador = 0.
   
   FOR EACH crapdev WHERE crapdev.cdcooper = p-cdcooper        AND
                          crapdev.cdbanchq = crapcop.cdbcoctl  AND
                          (
                            (crapdev.insitdev = 1) OR (vr_gera_devolu_coop3 = "S" AND crapdev.insitdev <> 2)
                          ) AND
                          crapdev.cdhistor <> 46               AND
                          crapdev.cdalinea > 0                 NO-LOCK
                          BREAK BY crapdev.cdagechq    
                                BY crapdev.nrctachq
                                BY crapdev.nrcheque:
       
       /* Inicializar variavel*/
       ASSIGN aux_dsorigem = "".

       IF FIRST-OF(crapdev.cdagechq) THEN
       DO:
           IF aux_primeira = TRUE  THEN
           DO:
               /* Nao executa*/
           END.
           ELSE
           DO:
               IF  flg_devolbcb = TRUE THEN
                   DO:
                       PUT STREAM str_2 FILL("9",47)         FORMAT "x(47)"
                                     "CEL605"
                                     crapage.cdcomchq     FORMAT "999"
                                     "0001"
                                     crapcop.cdbcoctl     FORMAT "999" /*BANCO*/
                                     crapcop.nrdivctl     FORMAT "9"   /* DV  */
                                     "1"
                                     aux_dtmovime         FORMAT "x(08)"
                                     (aux_vldtotal * 100) FORMAT "99999999999999999"
                                     FILL(" ",60)         FORMAT "x(60)"
                                     aux_nrsequen         FORMAT "9999999999"
                                     SKIP.
                 
                        OUTPUT STREAM str_2 CLOSE.
                        ASSIGN aux_vldtotal = 0.
                 
                        UNIX SILENT VALUE("ux2dos " + aux_dscooper + "arq/" + aux_nmarquiv +
                                          " > /micros/" + crapcop.dsdircop + "/abbc/" +
                                          aux_nmarquiv).
                                          
                        UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarquiv + 
                                          " " + aux_dscooper + "salvar/" + aux_nmarquiv + 
                                          "_" + STRING(TIME,"99999") + " 2>/dev/null").

                        /* Gerar log dos arquivos */
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                          glb_cdprogra + "' --> '" +
                                          " Cooperativa: " + STRING(p-cdcooper) +
                                          " Executado os comandos: " + 
                                          "  UX2DOS " + aux_dscooper + "arq/" + 
                                             aux_nmarquiv + " para /micros/" + 
                                          crapcop.dsdircop + "/abbc/" + aux_nmarquiv +
                                          " e mover " + aux_dscooper + "arq/" + aux_nmarquiv + 
                                          " para " + aux_dscooper + "salvar/" + aux_nmarquiv + 
                                          "_" + STRING(TIME,"99999") +
                                          " >> log/proc_message.log").
                   END.
           END.                     

           ASSIGN flg_devolbcb = FALSE
                  aux_nmarquiv = STRING(aux_dssufarq,"X(1)") + 
                                 STRING(crapdev.cdagechq,"9999") + aux_mes +
                                 STRING(DAY(glb_dtmvtolt),"99") +  aux_extensao
                  aux_nrsequen = 2
                  aux_primeira = FALSE.

       END.

       IF  p-cdcooper = 1  OR    /* Viacredi    */
           p-cdcooper = 13 OR    /* Scrcred     */
           p-cdcooper = 9  THEN  /* Transulcred */ DO:

            RUN verifica_incorporacao(INPUT  p-cdcooper,
                                      INPUT  crapdev.nrdconta,
                                      INPUT  crapdev.nrcheque,
                                      OUTPUT aux_cdcopant,
                                      OUTPUT aux_nrdconta_tco,
                                      OUTPUT aux_cdagectl).
        END.


       /* Diego - Devolucoes automaticas alinea 37, não geram lançamento de 
       devolução na conta do cooperado, serão apenas retornadas no arquivo 
       de devolução  */
       
       IF   crapdev.nrdconta = 0 THEN
            DO:
                CREATE tt-relchdv.
                ASSIGN tt-relchdv.nrdconta = 0
                       tt-relchdv.nmprimtl = ""
                       tt-relchdv.cdpesqui = ""
                       tt-relchdv.nrcheque = crapdev.nrcheque
                       tt-relchdv.vllanmto = crapdev.vllanmto
                       tt-relchdv.cdalinea = crapdev.cdalinea
                       tt-relchdv.cdagenci = 1
                       tt-relchdv.cdoperad = crapdev.cdoperad
                       tt-relchdv.dstipcta = ""
                       aux_dsorigem        = "".       

                IF vr_gera_devolu_coop3 = "S" THEN
                      ASSIGN aux_dsorigem = "Arq. Diurno"
                             aux_totqtdiu = aux_totqtdiu + 1
                             aux_totvldiu = aux_totvldiu +
                                            crapdev.vllanmto
                             aux_totqtdiu_age = aux_totqtdiu_age + 1
                             aux_totvldiu_age = aux_totvldiu_age +
                                                crapdev.vllanmto.
                ELSE
                CASE crapdev.indevarq:
                     WHEN 1 THEN 
                               ASSIGN aux_dsorigem = "Arq. Fraude"
                                    aux_totqtnot = aux_totqtnot + 1
                                    aux_totvlnot = aux_totvlnot +
                                                     crapdev.vllanmto
                                      aux_totqtnot_age = aux_totqtdiu_age + 1
                                      aux_totvlnot_age = aux_totvlnot_age +
                                                   crapdev.vllanmto.
           
                     WHEN 2 THEN 
                             ASSIGN aux_dsorigem = "Arq. Diurno"
                                    aux_totqtdiu = aux_totqtdiu + 1
                                    aux_totvldiu = aux_totvldiu +
                                                     crapdev.vllanmto
                                      aux_totqtdiu_age = aux_totqtdiu_age + 1
                                      aux_totvldiu_age = aux_totvldiu_age +
                                                   crapdev.vllanmto.
                END CASE.     

                ASSIGN aux_totqtrej = aux_totqtrej + 1                
                       aux_totvlrej = aux_totvlrej + crapdev.vllanmto
                       tt-relchdv.dsorigem = aux_dsorigem.
              
                IF   p-cddevolu = 5 THEN
                     DO:
                         IF   crapdev.indevarq <> 2 AND vr_gera_devolu_coop3 <> "S" THEN
                              NEXT.
                     END.
                ELSE
                IF   p-cddevolu = 6 AND crapdev.cdalinea = 37 THEN
                     DO:
                        IF aux_contador = 0 THEN
                           DO:
                              ASSIGN aux_contador = aux_contador + 1.

                              ASSIGN aux_nmarqcri = SUBSTRING(STRING(YEAR(glb_dtmvtolt),'9999'),3,2) + 
                                                    STRING(MONTH(glb_dtmvtolt),'99')   +
                                                    STRING(DAY(glb_dtmvtolt),'99') + '_CRITICADEVOLU.txt'.
             
                              OUTPUT STREAM str_3 TO VALUE("/usr/coop/" + crapcop.dsdircop + "/contab/" + aux_nmarqcri) APPEND.                               
                             
                          END.          
                          
                          ASSIGN aux_linhaarq = STRING(YEAR(glb_dtmvtolt),"9999") + 
                                                STRING(MONTH(glb_dtmvtolt),"99")   +
                                                STRING(DAY(glb_dtmvtolt),"99")     + "," +
                                                STRING(DAY(glb_dtmvtolt),"99") +
                                                STRING(MONTH(glb_dtmvtolt),"99")  +
                                                SUBSTRING(STRING(YEAR(glb_dtmvtolt),"9999"),3,2) + "," +
                                                "4958,1773," +
                                                TRIM(REPLACE(STRING(tt-relchdv.vllanmto,"zzzzzzzzzzzzz9.99"),",",".")) + 
                                                ",5210," +
                                                '"' + "VALOR REF. DEVOLUCAO DO CHEQUE N. " + STRING(crapdev.nrcheque,"9999999") + 
                                                ", PELA ALINEA 37, PARA REGULARIZACAO DE CRITICA DO RELATORIO 526" + '"'.                            
                                                
                          PUT STREAM str_3 aux_linhaarq FORMAT "x(250)" SKIP.
                          
                          IF   crapdev.indevarq <> 1 THEN
                               NEXT.                          
                     END.
                ELSE
                IF   crapdev.indevarq <> 1 THEN
                     NEXT.

                IF   flg_devolbcb = FALSE THEN 
                     DO: 
                         OUTPUT STREAM str_2 TO VALUE(aux_dscooper + "arq/" +
                                                      aux_nmarquiv).
 
                         PUT STREAM str_2 FILL("0",47)     FORMAT "x(47)"
                                          "CEL605"
                                          crapage.cdcomchq FORMAT "999"
                                          "0001"
                                          crapcop.cdbcoctl FORMAT "999"
                                          crapcop.nrdivctl FORMAT "9"   /* DV */
                                          "1"              /* Ind. Remes */
                                          aux_dtmovime     FORMAT "x(08)"
                                          FILL(" ",77)     FORMAT "x(77)"
                                          "0000000001"
                                          SKIP.
                         
                         ASSIGN flg_devolbcb = TRUE.
                     END.
                
                IF   crapdev.dtmvtolt < glb_dtmvtoan THEN
                     aux_cdcmpchq = INT(SUBSTR(crapdev.cdpesqui,01,3)).
                ELSE
                     aux_cdcmpchq = INT(SUBSTR(crapdev.cdpesqui,79,3)).
                                
                aux_linhadet = SUBSTR(crapdev.cdpesqui,1,53) +
                               STRING(crapdev.cdalinea,"99") +
                               SUBSTR(crapdev.cdpesqui,56,23) +
                               STRING(aux_cdcmpchq,"999") +
                               SUBSTR(crapdev.cdpesqui,82,69) +
                               STRING(aux_nrsequen,"9999999999").

                PUT STREAM str_2 aux_linhadet FORMAT "x(160)".

                PUT STREAM str_2 SKIP.

                ASSIGN aux_nrsequen = aux_nrsequen + 1
                       aux_vldtotal = aux_vldtotal + crapdev.vllanmto.
                 
				/*Quando vem um mesmo cheque na seguencia
                  existe a possibilidade de haver chave duplicada
                  para isso, é verificado se já existe na gncpdev
                  caso exista deve ser incrementado a hora
                  para então fazer o create na gncpdev*/
   
			    aux_horatran = TIME.
				
				FIND LAST gncpdev WHERE gncpdev.cdcooper = crapdev.cdcooper AND 
                                         gncpdev.dtmvtolt = DATE(
                                                                INT(SUBSTR(crapdev.cdpesqui,86,2)),
                                                                INT(SUBSTR(crapdev.cdpesqui,88,2)),
                                                                INT(SUBSTR(crapdev.cdpesqui,82,4))) AND
										 gncpdev.cdbanchq = INT(SUBSTR(crapdev.cdpesqui,4,3))       AND 
										 gncpdev.cdagechq = INT(SUBSTR(crapdev.cdpesqui,7,4))       AND
									     gncpdev.nrctachq = DEC(SUBSTR(crapdev.cdpesqui,12,12))     AND 
										 gncpdev.nrcheque = INT(SUBSTR(crapdev.cdpesqui,25,6))      AND 
										 gncpdev.cdtipreg = 1                                       
/*                     AND 
										 gncpdev.hrtransa = aux_horatran										 */
                                         NO-LOCK NO-ERROR.
										
		        IF AVAIL gncpdev THEN
               aux_horatran =  gncpdev.hrtransa + 1.
				
                /* CRIACAO da GNCPCHQ */
                CREATE gncpdev.
                ASSIGN gncpdev.cdcooper = crapdev.cdcooper
                       gncpdev.cdagenci = 0
                       gncpdev.dtmvtolt = DATE(
                                             INT(SUBSTR(crapdev.cdpesqui,86,2)),
                                             INT(SUBSTR(crapdev.cdpesqui,88,2)),
                                             INT(SUBSTR(crapdev.cdpesqui,82,4)))
                       gncpdev.cdagectl = DEC(SUBSTR(crapdev.cdpesqui,7,4))
                       gncpdev.cdbanchq = INT(SUBSTR(crapdev.cdpesqui,4,3))
                       gncpdev.cdagechq = INT(SUBSTR(crapdev.cdpesqui,7,4))
                       gncpdev.nrctachq = DEC(SUBSTR(crapdev.cdpesqui,12,12))
                       gncpdev.nrcheque = INT(SUBSTR(crapdev.cdpesqui,25,6))
                       gncpdev.nrddigv2 = INT(SUBSTR(crapdev.cdpesqui,11,1))
                       gncpdev.nrddigv3 = INT(SUBSTR(crapdev.cdpesqui,31,1))
                       gncpdev.cdcmpchq = INT(SUBSTR(crapdev.cdpesqui,1,3))
                       gncpdev.cdtipchq = INT(SUBSTR(crapdev.cdpesqui,148,3))
                       gncpdev.nrddigv1 = INT(SUBSTR(crapdev.cdpesqui,24,1))
                       gncpdev.vlcheque = DEC(SUBSTR(crapdev.cdpesqui,34,17))
                                          / 100
                       /* VIACON - gravar conta nova */
                       gncpdev.nrdconta = IF aux_nrdconta_tco > 0 THEN
                                             crapdev.nrdconta
                                          ELSE INT(SUBSTR(crapdev.cdpesqui,12,9))
                       gncpdev.nmarquiv = aux_nmarquiv
                       gncpdev.cdoperad = glb_cdoperad
                       gncpdev.hrtransa = aux_horatran
                       gncpdev.cdtipreg = 1
                       gncpdev.flgconci = NO
                       gncpdev.nrseqarq = aux_nrsequen
                       gncpdev.cdcritic = 0
                       gncpdev.cdalinea = crapdev.cdalinea
                       gncpdev.cdperdev = IF p-cddevolu = 6 THEN
                                               1
                                          ELSE 2. /* 1-Noturna / 2-Diurna */
                VALIDATE gncpdev.
                
                NEXT.
       
            END.
       ELSE
            DO:
                /* VIACON - ler conta na coop nova */
                FIND crapass WHERE crapass.cdcooper = p-cdcooper     AND
                                   crapass.nrdconta = crapdev.nrdconta
                                   NO-LOCK NO-ERROR.

                /* Tratamento para cheques migrados aonde o formulário do cheque 
                   encontra-se na cooperativa antiga. */
                IF   NOT AVAILABLE crapass THEN                     
                     FIND crapass WHERE crapass.cdcooper = p-cdcooper     AND
                                        crapass.nrdconta = crapdev.nrdctabb
                                        NO-LOCK NO-ERROR.
       
                IF  AVAILABLE crapass  THEN
                     DO:
                         
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                        RUN STORED-PROCEDURE pc_descricao_tipo_conta
                          aux_handproc = PROC-HANDLE NO-ERROR
                                                  (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                   INPUT crapass.cdtipcta, /* Tipo de conta */
                                                  OUTPUT "",               /* Descrição do Tipo de conta */
                                                  OUTPUT "",               /* Flag Erro */
                                                  OUTPUT "").              /* Descrição da crítica */
                        
                        CLOSE STORED-PROC pc_descricao_tipo_conta
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                        
                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                 
                        ASSIGN aux_dstipcta = ""
                               aux_des_erro = ""
                               aux_dscritic = ""
                               aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                                               WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
                               aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                                               WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
                               aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                                               WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
                          
                        IF aux_des_erro = "NOK"  THEN
                              aux_dstipcta = "NAO ENCONTRADO".
                           
                        
                     END.
                ELSE
                    aux_dstipcta = "NAO ENCONTRADO".
           
                CREATE tt-relchdv.
                ASSIGN tt-relchdv.nrdconta = crapass.nrdconta WHEN AVAILABLE crapass
                       tt-relchdv.nmprimtl = crapass.nmprimtl WHEN AVAILABLE crapass
                       tt-relchdv.cdpesqui = crapdev.cdpesqui
                       tt-relchdv.nrcheque = crapdev.nrcheque
                       tt-relchdv.vllanmto = crapdev.vllanmto
                       tt-relchdv.cdalinea = crapdev.cdalinea
                       tt-relchdv.cdagenci = crapass.cdagenci WHEN AVAILABLE crapass
                       tt-relchdv.cdoperad = crapdev.cdoperad
                       tt-relchdv.dstipcta = aux_dstipcta.
                       
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                RUN STORED-PROCEDURE pc_busca_reapre_cheque
                  aux_handproc = PROC-HANDLE NO-ERROR
                                          (INPUT p-cdcooper, /* cooperativa */
                                           INPUT tt-relchdv.nrdconta, /* conta */
                                           OUTPUT 0).               /* Flag */
                
                CLOSE STORED-PROC pc_busca_reapre_cheque
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
         
                ASSIGN aux_flgreapr = pc_busca_reapre_cheque.pr_flgreapre_autom 
                                       WHEN pc_busca_reapre_cheque.pr_flgreapre_autom <> ?.
              
                IF aux_flgreapr = 1 THEN
                    ASSIGN tt-relchdv.flgreapr = "SIM".
                ELSE 
                    ASSIGN tt-relchdv.flgreapr = "NAO".
                  
                IF aux_des_erro = "NOK"  THEN
                   DO:
                       glb_dscritic = aux_dscritic.
                       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                         glb_cdprogra + "' --> '" + glb_dscritic +
                                         " CRED-GENERI-00-VALORESVLB-001 " +
                                         " >> log/proc_message.log").
                       RETURN.
                   END.
             
                       
            END.
                      
       IF   crapdev.cdpesqui = "" THEN
            DO:
                /* VIACON - ler com o numero da conta cheque e agencia do 
                cheque se for conta incorporada */

                /* Se aux_nrdconta_tco > 0 eh incorporada */
                IF aux_nrdconta_tco > 0 THEN 
                   DO:
                       FIND LAST gncpchq WHERE 
                             gncpchq.cdcooper = p-cdcooper       AND
                             gncpchq.dtmvtolt = glb_dtmvtoan     AND
                             gncpchq.cdbanchq = crapcop.cdbcoctl AND
                             gncpchq.cdagechq = aux_cdagectl     AND
                             gncpchq.nrctachq = aux_nrdconta_tco AND
                             gncpchq.nrcheque = crapdev.nrcheque AND
                            (gncpchq.cdtipreg = 3                OR
                             gncpchq.cdtipreg = 4)               AND
                             gncpchq.vlcheque = crapdev.vllanmto
                             NO-LOCK NO-ERROR.

                       IF NOT AVAIL gncpchq THEN
                          FIND LAST gncpchq WHERE 
                                gncpchq.cdcooper = p-cdcooper       AND
                                gncpchq.dtmvtolt = glb_dtmvtoan     AND
                                gncpchq.cdbanchq = crapcop.cdbcoctl AND
                                gncpchq.cdagechq = crapcop.cdagectl AND
                                gncpchq.nrctachq = crapdev.nrdconta AND
                                gncpchq.nrcheque = crapdev.nrcheque AND
                               (gncpchq.cdtipreg = 3                OR
                                gncpchq.cdtipreg = 4)               AND
                                gncpchq.vlcheque = crapdev.vllanmto
                                NO-LOCK NO-ERROR.

                   END.
                ELSE

                FIND LAST gncpchq WHERE 
                          gncpchq.cdcooper = p-cdcooper       AND
                          gncpchq.dtmvtolt = glb_dtmvtoan     AND
                          gncpchq.cdbanchq = crapcop.cdbcoctl AND
                          gncpchq.cdagechq = crapcop.cdagectl AND
                          gncpchq.nrctachq = crapdev.nrdconta AND
                          gncpchq.nrcheque = crapdev.nrcheque AND
                         (gncpchq.cdtipreg = 3                OR
                          gncpchq.cdtipreg = 4)               AND
                          gncpchq.vlcheque = crapdev.vllanmto
                          NO-LOCK NO-ERROR.
                                   
                IF  NOT AVAILABLE gncpchq THEN                   
                    DO:
                        /* Tratamento para cheques migrados aonde o formulário do cheque 
                           encontra-se na cooperativa antiga. */
                        FIND craptco WHERE craptco.cdcopant = p-cdcooper
                                       AND craptco.nrctaant = crapdev.nrdctabb
                                       AND craptco.nrdconta = crapdev.nrdconta
                                       AND craptco.flgativo = TRUE
                                       NO-LOCK NO-ERROR.
                                       
                        IF  AVAILABLE craptco THEN
                            DO:
                                FIND LAST gncpchq WHERE 
                                          gncpchq.cdcooper = craptco.cdcooper AND
                                          gncpchq.dtmvtolt = glb_dtmvtoan     AND
                                          gncpchq.cdbanchq = crapcop.cdbcoctl AND
                                          gncpchq.cdagechq = crapcop.cdagectl AND
                                          gncpchq.nrctachq = crapdev.nrdctabb AND
                                          gncpchq.nrcheque = crapdev.nrcheque AND
                                         (gncpchq.cdtipreg = 3                OR
                                          gncpchq.cdtipreg = 4)               AND
                                          gncpchq.vlcheque = crapdev.vllanmto
                                          NO-LOCK NO-ERROR.
                            END.
                    END.
                                   
                IF   NOT AVAILABLE gncpchq THEN
                     DO:
                         ASSIGN tt-relchdv.dsorigem = "Caixa"
                                aux_totqtcax = aux_totqtcax + 1
                                aux_totvlcax = aux_totvlcax +
                                               crapdev.vllanmto
                                aux_totalqtd = aux_totqtcax + aux_totqtnot +
                                               aux_totqtdiu + aux_totqtdes
                                aux_totalvlr = aux_totvlcax + aux_totvlnot +
                                               aux_totvldiu + aux_totvldes.

                         NEXT.
                     END.
            END.
       ELSE
            IF   crapdev.cdpesqui = "TCO" THEN /* Contas transferidas */
                 DO: /* Tabela de contas transferidas entre cooperativas */
                     FIND craptco WHERE craptco.cdcopant = crapdev.cdcooper AND
                                        craptco.nrctaant = crapdev.nrdconta AND
                                        craptco.tpctatrf = 1                AND
                                        craptco.flgativo = TRUE
                                        NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE craptco THEN
                          NEXT.
                     
                     FIND LAST gncpchq WHERE 
                               gncpchq.cdcooper = craptco.cdcooper AND
                               gncpchq.dtmvtolt = glb_dtmvtoan     AND
                               gncpchq.cdbanchq = crapcop.cdbcoctl AND
                               gncpchq.cdagechq = crapcop.cdagectl AND
                               gncpchq.nrctachq = craptco.nrctaant AND
                               gncpchq.nrcheque = crapdev.nrcheque AND
                               gncpchq.cdtipreg = 4                AND
                               gncpchq.vlcheque = crapdev.vllanmto
                               NO-LOCK NO-ERROR.
                                   
                     IF   NOT AVAILABLE gncpchq THEN
                          DO:
                               FIND LAST gncpchq WHERE 
                                         gncpchq.cdcooper = craptco.cdcopant AND
                                         gncpchq.dtmvtolt = glb_dtmvtoan     AND
                                         gncpchq.cdbanchq = crapcop.cdbcoctl AND
                                         gncpchq.cdagechq = crapcop.cdagectl AND
                                         gncpchq.nrctachq = craptco.nrctaant AND
                                         gncpchq.nrcheque = crapdev.nrcheque AND
                                         gncpchq.cdtipreg = 3                AND
                                         gncpchq.vlcheque = crapdev.vllanmto
                                         NO-LOCK NO-ERROR.
                                   
                               IF   NOT AVAILABLE gncpchq THEN
                                    DO:
                                        ASSIGN tt-relchdv.dsorigem = "Caixa"
                                               aux_totqtcax = aux_totqtcax + 1
                                               aux_totvlcax = aux_totvlcax +
                                                              crapdev.vllanmto
                                               aux_totalqtd = aux_totqtcax + 
                                                              aux_totqtnot +
                                                              aux_totqtdiu + 
                                                              aux_totqtdes
                                               aux_totalvlr = aux_totvlcax + 
                                                              aux_totvlnot +
                                                              aux_totvldiu + 
                                                              aux_totvldes.
                                        NEXT.
                                    END.    
                          END.
                 END.

       IF   crapdev.cdpesqui <> ""    AND                          
            crapdev.cdpesqui <> "TCO" THEN
            ASSIGN aux_dsorigem = "Custod/Descto"
                   aux_totqtdes = aux_totqtdes + 1                
                   aux_totvldes = aux_totvldes + crapdev.vllanmto.
       ELSE
            DO:
                CASE crapdev.indevarq:
                         WHEN 1 THEN ASSIGN aux_dsorigem = "Arq. Fraude"
                                            aux_totqtnot = aux_totqtnot + 1
                                            aux_totvlnot = aux_totvlnot +
                                                           crapdev.vllanmto
                                            aux_totqtnot_age = aux_totqtnot_age + 1
                                            aux_totvlnot_age = aux_totvlnot_age +
                                                           crapdev.vllanmto.
           
                         WHEN 2 THEN 
                         DO: 
                            ASSIGN aux_dsorigem = "Arq. Diurno"
                                   aux_totqtdiu = aux_totqtdiu + 1
                                   aux_totvldiu = aux_totvldiu +
                                                  crapdev.vllanmto
                                   aux_totqtdiu_age = aux_totqtdiu_age + 1
                                   aux_totvldiu_age = aux_totvldiu_age +
                                                  crapdev.vllanmto.
                         END.
                END CASE.     
            END.
               

       ASSIGN aux_totalqtd = aux_totqtcax + aux_totqtnot + 
                             aux_totqtdiu + aux_totqtdes
              aux_totalvlr = aux_totvlcax + aux_totvlnot + 
                             aux_totvldiu + aux_totvldes.
     
       tt-relchdv.dsorigem = aux_dsorigem.
       
       IF  crapdev.cdpesqui <> ""    AND
            crapdev.cdpesqui <> "TCO" THEN
           DO:                
               glb_nrcalcul = INT(SUBSTRING(STRING(crapdev.nrcheque,"9999999"),1,6)).
               
               FIND crapfdc WHERE crapfdc.cdcooper = p-cdcooper
                              AND crapfdc.cdbanchq = crapdev.cdbanchq
                              AND crapfdc.cdagechq = crapdev.cdagechq
                              AND crapfdc.nrctachq = crapdev.nrctachq
                              AND crapfdc.nrcheque = INT(glb_nrcalcul)
                              USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                              
                IF  AVAILABLE crapfdc THEN
                    DO:
                       /* Desconto */
                       FOR LAST crapcdb FIELDS(nrdconta) 
                                         WHERE crapcdb.cdcooper = crapfdc.cdcooper
                                           AND crapcdb.cdcmpchq = crapfdc.cdcmpchq
                                           AND crapcdb.cdbanchq = crapfdc.cdbanchq
                                           AND crapcdb.cdagechq = crapfdc.cdagechq                                          
                                           AND crapcdb.nrctachq = crapfdc.nrctachq
                                           AND crapcdb.nrcheque = crapfdc.nrcheque
                                           AND CAN-DO("0,2,3",STRING(crapcdb.insitchq))
                                           AND NOT CAN-DO("0,2",STRING(crapcdb.insitana)) /* Inclusao Paulo Martins - Mouts (SCTASK0018345)*/
                                           AND crapcdb.dtdevolu = ?
                                           NO-LOCK:
                       END.                        
                       
                       IF  AVAILABLE crapcdb THEN          
                           ASSIGN tt-relchdv.benefici = STRING(crapcdb.nrdconta,"zzzz,zzz,9").
                       ELSE
                           DO:
                              /* Custodia */
                              FOR LAST crapcst FIELDS(nrdconta) 
                                                WHERE crapcst.cdcooper = crapfdc.cdcooper
                                                  AND crapcst.cdcmpchq = crapfdc.cdcmpchq
                                                  AND crapcst.cdbanchq = crapfdc.cdbanchq
                                                  AND crapcst.cdagechq = crapfdc.cdagechq
                                                  AND crapcst.nrctachq = crapfdc.nrctachq
                                                  AND crapcst.nrcheque = crapfdc.nrcheque
                                                  AND CAN-DO("0,2,3",STRING(crapcst.insitchq))
												  AND crapcst.dtdevolu = ?
												  AND crapcst.nrborder = 0
                                                  NO-LOCK:
                              END.
                        
                              /* Se encontrou cheque em custodia */ 
                              IF  AVAILABLE crapcst THEN          
                                  ASSIGN tt-relchdv.benefici = STRING(crapcst.nrdconta,"zzzz,zzz,9").
                              ELSE
                                  ASSIGN tt-relchdv.benefici = " ".
                           END.                                 
                    END.       
                   
                    IF p-cddevolu = 6 THEN
                       DO:
                          IF aux_contador = 0 THEN
                             DO:
                                ASSIGN aux_contador = aux_contador + 1.

                                ASSIGN aux_nmarqcri = SUBSTRING(STRING(YEAR(glb_dtmvtolt),'9999'),3,2) + 
                                                      STRING(MONTH(glb_dtmvtolt),'99')   +
                                                      STRING(DAY(glb_dtmvtolt),'99') + '_CRITICADEVOLU.txt'.
               
                                OUTPUT STREAM str_3 TO VALUE("/usr/coop/" + crapcop.dsdircop + "/contab/" + aux_nmarqcri) APPEND.                               
                               
                            END.           
       																									  
                          ASSIGN aux_linhaarq = "20" + SUBSTRING(STRING(YEAR(glb_dtmvtolt),"9999"),3,2) + 
                                                STRING(MONTH(glb_dtmvtolt),"99")   +
                                                STRING(DAY(glb_dtmvtolt),"99")     + "," +
                                                STRING(DAY(glb_dtmvtolt),"99") +
                                                STRING(MONTH(glb_dtmvtolt),"99")  +
                                                SUBSTRING(STRING(YEAR(glb_dtmvtolt),"9999"),3,2) + "," +
                                                "1411,4958," +
                                                TRIM(REPLACE(STRING(tt-relchdv.vllanmto,"zzzzzzzzzzzzz9.99"),",",".")) +
                                                ",5210," +
                                                '"' + "ACERTO ENTRE CONTAS DEVIDO A DEVOLUCAO DE CHEQUE " + STRING(crapdev.nrcheque,"9999999") + 
                                                " DO COOPERADO DE C/C " + TRIM(REPLACE(STRING(crapdev.nrctachq,"zzzz,zzz,9"),",",".")) + 
                                                " CUSTODIADO/DESCONTADO PELO COOPERADO DE C/C " + TRIM(REPLACE(STRING(tt-relchdv.nrdconta,"zzzz,zzz,9"),",",".")) +
                                                " (CONFORME CRITICA NO RELATORIO 219)" + '"'.
                                          
                          PUT STREAM str_3 aux_linhaarq FORMAT "x(250)" SKIP.
                          
                       END.
                   
               NEXT.
           END.    										     
       
       IF   p-cddevolu = 5 AND (vr_gera_devolu_coop3 <> "S") THEN
            DO:
                 IF   crapdev.indevarq <> 2 THEN
                      NEXT.
            END.
       ELSE
            IF   crapdev.indevarq <> 1 THEN
                 NEXT.

       IF   AVAILABLE gncpchq THEN
            DO:
                IF   flg_devolbcb = FALSE THEN 
                     DO: 
                        OUTPUT STREAM str_2 TO VALUE(aux_dscooper + "arq/" +
                                                      aux_nmarquiv).
 
                         PUT STREAM str_2 FILL("0",47)     FORMAT "x(47)"
                                          "CEL605"
                                          crapage.cdcomchq FORMAT "999"
                                          "0001"
                                          crapcop.cdbcoctl FORMAT "999"
                                          crapcop.nrdivctl FORMAT "9"   /* DV */
                                          "1"              /* Ind. Remes */
                                          aux_dtmovime     FORMAT "x(08)"
                                          FILL(" ",77)     FORMAT "x(77)"
                                          "0000000001"
                                          SKIP.
                         
                         ASSIGN flg_devolbcb = TRUE.
                     END.
                
                IF   gncpchq.dtmvtolt < glb_dtmvtoan THEN
                     aux_cdcmpchq = INT(SUBSTR(gncpchq.dsidenti,01,3)).
                ELSE
                     aux_cdcmpchq = INT(SUBSTR(gncpchq.dsidenti,79,3)).
                
                
                aux_linhadet = SUBSTR(gncpchq.dsidenti,1,53) +
                               STRING(crapdev.cdalinea,"99") +
                               SUBSTR(gncpchq.dsidenti,56,23) +
                               STRING(aux_cdcmpchq,"999") +
                               SUBSTR(gncpchq.dsidenti,82,69) +
                               STRING(aux_nrsequen,"9999999999").

                PUT STREAM str_2 aux_linhadet FORMAT "x(160)".

                PUT STREAM str_2 SKIP.
        
                ASSIGN aux_nrsequen = aux_nrsequen + 1
                       aux_vldtotal = aux_vldtotal + crapdev.vllanmto.
                
                IF   crapdev.cdpesqui = "TCO" THEN /* Contas transferidas */
                     DO:
                         FIND craptco WHERE 
                                      craptco.cdcopant = p-cdcooper       AND
                                      craptco.nrctaant = crapdev.nrdconta AND
                                      craptco.tpctatrf = 1                AND
                                      craptco.flgativo = TRUE
                                      NO-LOCK NO-ERROR.
                                         
                         IF   AVAILABLE craptco THEN
                              ASSIGN aux_cdcooper = craptco.cdcooper
                                     aux_nrdconta = craptco.nrdconta.
                         ELSE
                              ASSIGN aux_cdcooper = p-cdcooper
                                     aux_nrdconta = crapdev.nrdconta.
                     END.
                ELSE
                     ASSIGN aux_cdcooper = p-cdcooper
                            aux_nrdconta = crapdev.nrdconta.


				/*Quando vem um mesmo cheque na seguencia
                  existe a possibilidade de haver chave duplicada
                  para isso, é verificado se já existe na gncpdev
                  caso exista deve ser incrementado a hora
                  para então fazer o create na gncpdev*/


                aux_horatran = TIME.
				
				FIND LAST gncpdev WHERE gncpdev.cdcooper = crapdev.cdcooper AND 
                                         gncpdev.dtmvtolt = DATE(
                                                                INT(SUBSTR(crapdev.cdpesqui,86,2)),
                                                                INT(SUBSTR(crapdev.cdpesqui,88,2)),
                                                                INT(SUBSTR(crapdev.cdpesqui,82,4))) AND
										 gncpdev.cdbanchq = INT(SUBSTR(crapdev.cdpesqui,4,3))       AND 
										 gncpdev.cdagechq = INT(SUBSTR(crapdev.cdpesqui,7,4))       AND
									     gncpdev.nrctachq = DEC(SUBSTR(crapdev.cdpesqui,12,12))     AND 
										 gncpdev.nrcheque = INT(SUBSTR(crapdev.cdpesqui,25,6))      AND 
										 gncpdev.cdtipreg = 1                                     /*  AND 
										 gncpdev.hrtransa = aux_horatran										 */
                                         NO-LOCK NO-ERROR.
										
		        IF AVAIL gncpdev THEN
              aux_horatran =  gncpdev.hrtransa + 1.
                   
                /* CRIACAO da GNCPCHQ */
                CREATE gncpdev.
                ASSIGN gncpdev.cdcooper = aux_cdcooper
                       gncpdev.cdagenci = gncpchq.cdagenci
                       gncpdev.dtmvtolt =
                                      DATE(INT(SUBSTR(gncpchq.dsidenti,86,2)),
                                           INT(SUBSTR(gncpchq.dsidenti,88,2)),
                                           INT(SUBSTR(gncpchq.dsidenti,82,4)))
                       gncpdev.cdagectl = DEC(SUBSTR(gncpchq.dsidenti,7,4))
                       gncpdev.cdbanchq = INT(SUBSTR(gncpchq.dsidenti,4,3))
                       gncpdev.cdagechq = INT(SUBSTR(gncpchq.dsidenti,7,4))
                       gncpdev.nrctachq = DEC(SUBSTR(gncpchq.dsidenti,12,12))
                       gncpdev.nrcheque = INT(SUBSTR(gncpchq.dsidenti,25,6))
                       gncpdev.nrddigv2 = INT(SUBSTR(gncpchq.dsidenti,11,1))
                       gncpdev.nrddigv3 = INT(SUBSTR(gncpchq.dsidenti,31,1))
                       gncpdev.cdcmpchq = INT(SUBSTR(gncpchq.dsidenti,1,3))
                       gncpdev.cdtipchq = INT(SUBSTR(gncpchq.dsidenti,148,3))
                       gncpdev.nrddigv1 = INT(SUBSTR(gncpchq.dsidenti,24,1))
                       gncpdev.vlcheque = DEC(SUBSTR(gncpchq.dsidenti,34,17))
                                          / 100
                       /* VIACON - gravar numero da nova conta */
                       gncpdev.nrdconta = IF aux_nrdconta_tco > 0 THEN 
                                             crapdev.nrdconta
                                          ELSE INT(SUBSTR(gncpchq.dsidenti,12,12))
                       gncpdev.nmarquiv = aux_nmarquiv
                       gncpdev.cdoperad = glb_cdoperad
                       gncpdev.hrtransa = aux_horatran
                       gncpdev.cdtipreg = 1
                       gncpdev.flgconci = NO
                       gncpdev.nrseqarq = aux_nrsequen
                       gncpdev.cdcritic = 0
                       gncpdev.cdalinea = crapdev.cdalinea
                       gncpdev.cdperdev = IF p-cddevolu = 6 THEN
                                               1
                                          ELSE
                                               2. /* 1-Noturna / 2-Diurna */
                VALIDATE gncpdev.
                              
            END.


   END. /*FOR EACH crapdev&=*/

   IF vr_gerou_arquivo = 1 AND (aux_totqtnot_age > 0 OR aux_totqtdiu_age > 0) THEN
   DO:

      CASE p-cddevolu:
           WHEN 6 THEN 
                   ASSIGN aux_totqt = aux_totqtnot_age
                          aux_totvl = aux_totvlnot_age
                          aux_tparquiv = 2.
           WHEN 5 THEN 
                   ASSIGN aux_totqt = aux_totqtdiu_age
                          aux_totvl = aux_totvldiu_age
                          aux_tparquiv = 1.
      END CASE.     
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
           /* Efetuar a chamada a rotina Oracle  */
           RUN STORED-PROCEDURE pc_checa_devolu
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT p-cdcooper 
                                                   ,INPUT aux_nmarquiv
                                                   ,INPUT 0   /* crapcop.cdagectl */
                                                   ,INPUT 0   /* crapass.cdagenci */
                                                   ,INPUT glb_dtmvtolt
                                                   ,INPUT aux_totqt
                                                   ,INPUT aux_totvl
                                                   ,INPUT aux_tparquiv
                                                   ,OUTPUT 0
                                                   ,OUTPUT "").

           /* Fechar o procedimento para buscarmos o resultado */ 
           CLOSE STORED-PROC pc_checa_devolu
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
          
           ASSIGN aux_dscritic = ""
                  aux_dscritic = pc_checa_devolu.pr_dscritic
                                 WHEN pc_checa_devolu.pr_dscritic <> ?
                  aux_cdcritic = 0
                  aux_cdcritic = pc_checa_devolu.pr_cdcritic
                                 WHEN pc_checa_devolu.pr_cdcritic <> ?.

           ASSIGN aux_totqtdiu_age = 0
                  aux_totvldiu_age = 0
                  aux_totqtnot_age = 0
                  aux_totvlnot_age = 0.
   END.

   IF vr_gera_devolu_coop3 = "S" THEN
   DO:
   
      FOR EACH b-crapdev WHERE b-crapdev.cdcooper = p-cdcooper     AND
                               b-crapdev.cdbanchq = crapcop.cdbcoctl  AND
                               (
                                 (b-crapdev.insitdev = 1) OR (vr_gera_devolu_coop3 = "S")
                               ) AND
                               b-crapdev.cdhistor <> 46               AND
                               b-crapdev.cdalinea > 0:
          ASSIGN b-crapdev.insitdev = 1.
      END.
   END.
   
   IF aux_contador > 0 THEN
      DO:
          OUTPUT STREAM str_3 CLOSE.
   
          ASSIGN aux_nmarqcop = SUBSTRING(STRING(YEAR(glb_dtmvtolt),'9999'),3,2) + 
                                STRING(MONTH(glb_dtmvtolt),'99')   +
                                STRING(DAY(glb_dtmvtolt),'99') + '_' + 
						                    STRING(p-cdcooper,'99') +
						                    '_CRITICADEVOLU.txt'.   
   
          UNIX SILENT VALUE("ux2dos " + "/usr/coop/" + crapcop.dsdircop + "/contab/" + aux_nmarqcri + " > " +
                            "/usr/sistemas/arquivos_contabeis/ayllos/" + aux_nmarqcop + " 2>/dev/null").
      END.
   
   IF   flg_devolbcb = TRUE THEN
        DO:
            PUT STREAM str_2 FILL("9",47)         FORMAT "x(47)"
                             "CEL605"
                             crapage.cdcomchq     FORMAT "999"
                             "0001"
                             crapcop.cdbcoctl     FORMAT "999" /*BANCO*/
                             crapcop.nrdivctl     FORMAT "9"   /* DV  */
                             "1"
                             aux_dtmovime         FORMAT "x(08)"
                             (aux_vldtotal * 100) FORMAT "99999999999999999"
                             FILL(" ",60)         FORMAT "x(60)"
                             aux_nrsequen         FORMAT "9999999999"
                             SKIP.

            OUTPUT STREAM str_2 CLOSE.

            UNIX SILENT VALUE("ux2dos " + aux_dscooper + "arq/" + aux_nmarquiv +
                              " > /micros/" + crapcop.dsdircop + "/abbc/" +
                              aux_nmarquiv).
                              
            UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarquiv + 
                              " " + aux_dscooper + "salvar/" + aux_nmarquiv + 
                              "_" + STRING(TIME,"99999") + " 2>/dev/null").

            /* Gerar log dos arquivos */
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                              glb_cdprogra + "' --> '" +
                              " Cooperativa: " + STRING(p-cdcooper) +
                              " Executado os comandos: " + 
                              "  UX2DOS " + aux_dscooper + "arq/" + 
                                 aux_nmarquiv + " para /micros/" + 
                              crapcop.dsdircop + "/abbc/" + aux_nmarquiv +
                              " e mover " + aux_dscooper + "arq/" + aux_nmarquiv + 
                              " para " + aux_dscooper + "salvar/" + aux_nmarquiv + 
                              "_" + STRING(TIME,"99999") +
                              " >> log/proc_message.log").
        END.
   
   /* VIACON - O relatorio contera informacao de contas da cooperativa e contas incorporadas */
   FOR EACH tt-relchdv
       BREAK BY tt-relchdv.cdagenci
             BY tt-relchdv.dsorigem
             BY tt-relchdv.nrdconta:

       IF   FIRST (tt-relchdv.nrdconta) THEN
            DO:
                DISPLAY STREAM str_1 glb_dtmvtolt WITH FRAME f_relacao.
                DISPLAY STREAM str_1 WITH FRAME f_cabec.
            END.

       DISPLAY STREAM str_1  tt-relchdv.nrdconta   tt-relchdv.nmprimtl
                             tt-relchdv.dstipcta   tt-relchdv.nrcheque
                             tt-relchdv.vllanmto   tt-relchdv.cdalinea
                             tt-relchdv.cdagenci   tt-relchdv.cdoperad
                             tt-relchdv.dsorigem   tt-relchdv.benefici
                             tt-relchdv.cdpesqui   tt-relchdv.flgreapr
                             WITH FRAME f_todos_cecred.

       DOWN STREAM str_1 WITH FRAME f_todos_cecred.

       IF   LAST (tt-relchdv.nrdconta) THEN
            DISPLAY STREAM str_1  aux_totqtcax   aux_totvlcax   aux_totqtdiu
                                  aux_totvldiu   aux_totqtnot   aux_totvlnot
                                  aux_totqtdes   aux_totvldes   aux_totqtrej
                                  aux_totvlrej   aux_totalqtd   aux_totalvlr
                                  WITH FRAME f_totais.
   END.

   OUTPUT STREAM str_1 CLOSE.

   /*  Salvar copia relatorio para "/rlnsv"  */
   UNIX SILENT VALUE("cp " + aux_dscooper + aux_nmarqchq + " " + 
                           aux_dscooper + "rlnsv").

   UNIX SILENT VALUE("ux2dos " + aux_dscooper + aux_nmarqchq + " > /micros/" + 
                     crapcop.dsdircop + "/devolu/" + aux_nmarqdev).
      
   /* Gerar log dos arquivos */
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                     glb_cdprogra + "' --> '" +
                     " Cooperativa: " + STRING(p-cdcooper) +
                     " Executado os comandos: " + 
                     " Copiar arquivo " + aux_nmarqchq + " para rlnsv" +
                     " e UX2DOS " + aux_dscooper + aux_nmarqchq + 
                     " para /micros/" + crapcop.dsdircop + 
                     "/devolu/" + aux_nmarqdev +
                     " >> log/proc_message.log").
   
   IF p-cdcooper = 1 OR
      p-cdcooper = 2 THEN
   DO:
       RUN sistema/generico/procedures/b1wgen0011.p 
                                                PERSISTENT SET h-b1wgen0011.

       IF VALID-HANDLE(h-b1wgen0011) THEN
       DO:
           RUN converte_arquivo IN h-b1wgen0011(INPUT p-cdcooper,
                                                INPUT aux_dscooper + 
                                                      aux_nmarqchq,
                                                INPUT aux_nmarqdev).

           IF p-cdcooper = 1 THEN
               RUN enviar_email_completo IN h-b1wgen0011(
                                         INPUT p-cdcooper,
                                         INPUT "crps264",
                                         INPUT "cpd@ailos.coop.br",
                                         INPUT 
                                         "suporte@viacredialtovale.coop.br",
                                         INPUT "Relatorio de Devolucoes " + 
                                               "Cheques AILOS",
                                         INPUT "",
                                         INPUT aux_nmarqdev,
                                         INPUT "",
                                         INPUT FALSE).
           ELSE
           IF glb_dtmvtolt >= 01/02/2014 THEN
               RUN enviar_email_completo IN h-b1wgen0011(
                                         INPUT p-cdcooper,
                                         INPUT "crps264",
                                         INPUT "cpd@ailos.coop.br",
                                         INPUT "suporte@viacredi.coop.br",
                                         INPUT "Relatorio de Devolucoes " + 
                                               "Cheques AILOS",
                                         INPUT "",
                                         INPUT aux_nmarqdev,
                                         INPUT "",
                                         INPUT FALSE).

           DELETE PROCEDURE h-b1wgen0011.
       END.
   END.

   ASSIGN glb_nmformul = "234col"
          glb_nmarqimp = aux_dscooper + aux_nmarqchq
          glb_nrcopias = 1.

   RUN fontes/imprim_unif.p (INPUT p-cdcooper).
                
END PROCEDURE.


/*........................................................................... */

PROCEDURE verifica_locks:

   DEF VAR aux_nrdrecid AS INT                                        NO-UNDO.
   DEF VAR aux_nmusuari AS CHAR                                       NO-UNDO.
   DEF VAR aux_contador AS INT                                        NO-UNDO.
   DEF VAR aux_nrdolote AS INT                                        NO-UNDO.

   DEF BUFFER crawdev FOR crapdev.
       
   FOR EACH crapdev WHERE crapdev.cdcooper = p-cdcooper   AND
                          crapdev.nrdconta > 0            AND
                          crapdev.insitdev = 0            AND
                          crapdev.cdbanchq = aux_cdbanchq NO-LOCK:
                       
       ASSIGN aux_nrdrecid = RECID(crapdev).

       FIND crawdev OF crapdev EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    
       IF   LOCKED crawdev THEN
            DO:
                RUN acha_lock (INPUT  aux_nrdrecid, INPUT  "crapdev",
                               OUTPUT aux_nmusuari). 
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                  glb_cdprogra + "' --> '" +
                                  " Registro utilizando por " + aux_nmusuari +
                                  " Avise a Equipe de Suporte do AILOS" +
                                  " Coop: " + STRING(p-cdcooper) +
                                  " Banco do Cheque: " + STRING(aux_cdbanchq) +
                                  " Tabela: crapdev " +
                                  " RECID: " + STRING(aux_nrdrecid) +
                                  " >> log/proc_message.log").
                RETURN "NOK".
            END.
      ELSE
            DO:
                IF   CAN-DO("47,191,338,573",STRING(crapdev.cdhistor)) AND p-cdcooper <> 3 THEN
                     DO:
                         glb_nrcalcul = 
                           INT(SUBSTR(STRING(crapdev.nrcheque,"9999999"),1,6)).

                         FIND crapfdc WHERE 
                              crapfdc.cdcooper = p-cdcooper        AND
                              crapfdc.cdbanchq = crapdev.cdbanchq  AND
                              crapfdc.cdagechq = crapdev.cdagechq  AND
                              crapfdc.nrctachq = crapdev.nrctachq  AND
                              crapfdc.nrcheque = INT(glb_nrcalcul)
                              USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                         IF  NOT AVAILABLE crapfdc   THEN
                              DO:
                                  glb_cdcritic = 268. 
                                  RUN fontes/critic.p.
                                  UNIX SILENT VALUE("echo " +
                                       STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '"  +
                                       glb_dscritic +
                                       " Coop: " + STRING(p-cdcooper) +
                                       " CTA: " + STRING(crapdev.nrdconta) +
                                       " CBS: " + STRING(crapdev.nrdctabb) +
                                       " DOC: " + STRING(crapdev.nrcheque) +
                                       " Avise a Equipe de Suporte do AILOS" +
                                       " >> log/proc_message.log").
                                  glb_cdcritic = 0.
                                  RETURN "NOK".
                              END.
                         ELSE
                              DO:
                                  aux_nrdrecid = RECID(crapfdc).
                   
                                  FIND CURRENT crapfdc EXCLUSIVE-LOCK 
                                                       NO-WAIT NO-ERROR.

                                  IF  LOCKED crapfdc   THEN
                                       DO:
                                           RUN acha_lock (INPUT  aux_nrdrecid, 
                                                          INPUT  "crapfdc",
                                                          OUTPUT aux_nmusuari). 

                                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                                             glb_cdprogra + "' --> '" +
                                                             " Registro utilizando por " + aux_nmusuari +
                                                             " Avise a Equipe de Suporte do AILOS" +
                                                             " Coop: " + STRING(p-cdcooper) +
                                                             " CTA: " + STRING(crapdev.nrdconta) +
                                                             " CBS: " + STRING(crapdev.nrdctabb) +
                                                             " DOC: " + STRING(crapdev.nrcheque) +
                                                             " Tabela: crapfdc " +
                                                             " RECID: " + STRING(aux_nrdrecid) +
                                                             " >> log/proc_message.log").
                                           RETURN "NOK".
                                       END.
                              END.         
                     END.
            END.
   END.                       

   DO aux_contador = 1 TO 2:

      IF   aux_contador = 1 THEN
           DO:
               CASE p-cddevolu:
                  WHEN 1 THEN aux_nrdolote = 10110. /*  BANCOOB  */
                  WHEN 2 THEN aux_nrdolote = 8451.  /*  CONTA BASE */
                  WHEN 3 THEN aux_nrdolote = 10109. /*  CONTA INTEGRACAO  */
                  WHEN 4 THEN aux_nrdolote = 10117. /*  CECRED */
               END CASE.
           END.
      ELSE
           IF   aux_contador = 2 THEN
                aux_nrdolote = 8452.
   
      FIND craplot WHERE craplot.cdcooper = p-cdcooper   AND
                         craplot.dtmvtolt = glb_dtmvtolt AND
                         craplot.cdagenci = aux_cdagenci AND
                         craplot.cdbccxlt = aux_cdbccxlt AND
                         craplot.nrdolote = aux_nrdolote NO-LOCK NO-ERROR.

      IF   AVAILABLE craplot THEN
           DO:
               aux_nrdrecid = RECID(craplot).
                  
               FIND CURRENT craplot EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

               IF   LOCKED craplot   THEN
                    DO:
                        RUN acha_lock(INPUT  aux_nrdrecid, 
                                      INPUT  "craplot",
                                      OUTPUT aux_nmusuari). 
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                          glb_cdprogra + "' --> '" +
                                          " Registro utilizando por " + aux_nmusuari +
                                          " Avise a Equipe de Suporte do AILOS" +
                                          " Coop: " + STRING(p-cdcooper) +
                                          " Tabela: craplot " +
                                          " RECID: " + STRING(aux_nrdrecid) +
                                          " >> log/proc_message.log").
                        RETURN "NOK".
                    END.
           END.      
   END.               
                    
   RETURN "OK".

END PROCEDURE.


PROCEDURE acha_lock:

   DEF INPUT  PARAM par_recid    AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_nmtabela AS CHAR                              NO-UNDO.
   DEF OUTPUT PARAM par_nmusuari AS CHAR                              NO-UNDO.

   FIND FIRST _file WHERE _file-name = par_nmtabela NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE _file   THEN
        RETURN.
     
   FIND FIRST _lock WHERE _lock-table = _file._file-number   AND
                          _lock-recid = par_recid NO-LOCK NO-ERROR.
                       
   IF   NOT AVAILABLE _lock   THEN
        RETURN.

   ASSIGN par_nmusuari = _lock._lock-name.

   LEAVE.
    
END PROCEDURE.


PROCEDURE verifica_incorporacao:

    DEF INPUT  PARAM par_cdcooper  AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta  AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrcheque  LIKE crapdev.nrcheque                NO-UNDO. 
    DEF OUTPUT PARAM par_cdcooptco LIKE craptco.cdcooper                NO-UNDO.
    DEF OUTPUT PARAM par_contatco  LIKE crapdev.nrdconta                NO-UNDO.
    DEF OUTPUT PARAM par_cdagectl  LIKE crabcop.cdagectl                NO-UNDO.

    DEF VAR aux_cdagechq          AS INTE                              NO-UNDO. 

    ASSIGN par_contatco = 0. /* Se retornar 0 nao eh conta incorporada */

    FIND craptco WHERE craptco.cdcooper = par_cdcooper     AND
                       craptco.nrdconta = par_nrdconta     AND
                       craptco.tpctatrf = 1                AND
                       craptco.flgativo = TRUE
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE craptco THEN DO:

        CASE par_cdcooper:
            WHEN 1  THEN            /* VIACREDI       */
               aux_cdagechq = 103.  /* -> CONCREDI    */
            WHEN 13 THEN            /* SCRCRED        */
               aux_cdagechq = 114.  /* -> CREDIMILSUL */
            WHEN 9  THEN            /* TRANSPOCRED    */
               aux_cdagechq = 116.  /* -> TRANSULCRED */
        END CASE.

        FIND FIRST crapfdc
             WHERE crapfdc.cdcooper = par_cdcooper
               AND crapfdc.cdbanchq = 085
               AND crapfdc.cdagechq = aux_cdagechq
               AND crapfdc.nrctachq = craptco.nrctaant
               AND crapfdc.nrcheque = INT(SUBSTR
                                        (STRING(par_nrcheque,"9999999"),1,6))
                           USE-INDEX crapfdc1
                           NO-LOCK NO-ERROR NO-WAIT.

        IF AVAIL(crapfdc) THEN 
        DO:
            ASSIGN par_contatco  = craptco.nrctaant
                   par_cdcooptco = craptco.cdcopant.

            FIND FIRST crabcop 
                 WHERE crabcop.cdcooper = craptco.cdcopant
                 NO-LOCK NO-ERROR.

            ASSIGN par_cdagectl =  crabcop.cdagectl.
                  

        END.

    END.

END PROCEDURE.

/* .......................................................................... */

PROCEDURE trata_dev_automatica:

  DEF INPUT  PARAM par_cdcooper  AS INT                               NO-UNDO.

  FOR EACH crapdev WHERE crapdev.cdcooper = par_cdcooper AND
                         crapdev.insitdev = 2            EXCLUSIVE-LOCK:

    ASSIGN crapdev.insitdev = 1
           crapdev.indevarq = 2.

  END.

END PROCEDURE.

/*........................................................................... */
