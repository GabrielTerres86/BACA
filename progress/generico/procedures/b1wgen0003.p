
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------------+-------------------------------------------+
  | Rotina Progress                       | Rotina Oracle PLSQL                       |
  +---------------------------------------+-------------------------------------------+
  | blwgen0003.consulta-lancamento        | EXTR0002.pc_consulta_lancamento           |
  | b1wgen0003.fn_dia_util_anterior       | EXTR0002.fn_dia_util_anterior             |
  +------------------------------------------+----------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/* .............................................................................

   Programa: b1wgen0003.p
   Autora  : Junior.
   Data    : 20/10/2005                     Ultima atualizacao: 09/08/2017
   

   Dados referentes ao programa:

   Objetivo  : BO LANCAMENTOS FUTUROS E CHEQUES NAO COMPENSADOS
               Adaptado de fontes/sldlau.p.

   Alteracoes: 10/03/2006 - Mostrar somente o residuo do emprestimo quando for
                            o caso (Evandro).
                            
               19/05/2006 - Incluido codigo da cooperativa nas leituras das
                            tabelas (Diego).
                            
               26/03/2007 - Incluida a procedure "selecao_cheques_pendentes"
                            para gerar uma temp-table com os cheques pendentes
                            do cooperado (Evandro).

               03/08/2007 - Definicoes de temp-tables para include (David)
                          - Considerar lancamentos de internet nos lancamentos
                            futuros, quando for pela internet (Evandro).

               15/02/2008 - Incluir parametros e gerar log para procedure 
                            "selecao_cheques_pendentes" (David).
                          - Igualar consulta-lancamento ao fontes/sldlau.p.
                            (Guilherme).

               25/04/2008 - Quando saldo devedor menor que a parcela no mes
                            nao mostrava corretamente (Magui).

               19/05/2008 - Adaptacao para agendamentos (David).

               18/06/2008 - Nao utilizar parametro crapage.qtddlslf se for
                            cdcooper = 3 (David).
               
               09/07/2008 - Quando folha mostrava 01/01/1099 no debito (Magui).
               
               29/09/2008 - Alteracao no Consulta-lancamento para p-origem = 4
                            CASH FOTON - valor dos lancamentos futuros (Ze).
                            
               30/10/2008 - Incluir o historico 359 Est. Debito nos historico
                            utilizado pelo CASH para o final de semana (Ze).
                            
               10/11/2008 - Dar empty temp-table, return "ok", e
                            limpar variaveis de erro (Guilherme).
                            
               07/11/2008 - Troca do Histor. 359 p/ 767 (Estorno Debito) (Ze).
               
               10/03/2009 - Somente grava na TEMP-TABLE "tt-lancamento_futuro"
                            os seguros que nao sao conveniados (Elton).
                            
               01/09/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).             
                            
               17/12/2009 - Acerto na consulta de debitos futuros para seguros 
                           (David).

               10/02/2010 - Inclusao do cdhistor 573 no CAN-DO onde ha cdhistor
                            338 (Guilherme/Precise)
                            
               14/06/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                            (Diego).
                          - Tratamento para PAC 91 - TAA  (Elton).
                          
               03/11/2010 - Inclusao de históricos 918(Saque) e 920(Estorno)
                            utilizados pelo TAA compartilhado (Henrique);
                          - Incluidos tipos de conta 12, 13, 14 e 15 para ficar
                            equivalente ao bancoob (Evandro).

               01/01/2011 - Incluir his 14 e 44 na lista de desprezo da
                            lautom (Magui).
                            
               04/02/2011 - Incluir parametro par_flgcondc na procedure 
                            obtem-dados-emprestimos  (Gabriel - DB1).
                            
               03/06/2011 - Ajustada posicao do cdpesqbb para a gendamento
                            (Evandro).
                            
               27/10/2011 - Tratar seguro renovado (Diego).             
               
               09/12/2011 - Sustaçao provisória (André R./Supero).          
               
               23/01/2013 - Incluir nova condicao para tratar IOF 
                            crapsld.vliofmes > 0 (Lucas R.).
                            
               27/03/2013 - Ajustes referentes ao projeto tarifas fase 2 
                            Grupo de Cheque (Lucas R.).         
                            
               20/04/2013 - Transferencia intercooperativa (Gabriel).        
               
               11/07/2013 - Tratamento para históricos 1009 e 1011 e remoçao do
                            histórico fixo 1162 nas procedures 'obtem-saldo-dia'
                            e 'consulta-extrato' (Lucas).
                            
               28/08/2013 - Listar o valor pendente do plano de cotas ate
                            um dia antes do debito da parcela atual. (Fabricio)
                            
               30/09/2013 - Tratamento para Imunidade Tributaria (Ze).
               
               10/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               18/12/2013 - Adicionado validate para tabela crapfdc (Tiago).
               
               13/01/2014 - Alterado codigo da critica para 962 ao nao 
                            encontrar PA. (Reinert)
                            
               24/02/2014 - Adicionado param. de paginacao em procedure
                            obtem-dados-emprestimos em BO 0002.(Jorge)  
                            
               12/03/2014 - Ajuste na procedure "consulta-lancamento"
                            para trazer o valor da multa e juros de mora para
                            o novo tipo de emprestimo (James)
                            
               03/04/2014 - Alterado atribuicao de 
                            tt-lancamento_futuro.dtmvtolt na leitura da
                            crappla; de: crappla.dtdpagto / 
                            para: crapdat.dtmvtolt. (Fabricio)
                            
               27/05/2014 - Ajustado o campo tt-lancamento_futuro.nrdocmto,
                            pois o mesmo estava vindo com 22 posicoes
                            (Andrino - RKAM)
							
			   26/09/2014 - Nova procedure consulta-lancamento-periodo,
                            Chamado 161874 - (Jonathan - RKAM)

			   30/10/2014 - Alterado procedure consulta-lancamento-periodo
                            para validar o histórico 530 e se foi realizado ONLINE
                            (Douglas - Projeto Captação Internet 2014/2)
                            
			   03/11/2014 - Adicionado tratamento para ignorar os lançamentos futuros 
                            do histórico 15 e da tabela 'de-para' da Cabal na 
                            consulta-lancamento-periodo (Douglas - Solicitação Oscar)
                            
               04/11/2014 - Ajuste no extrato de lançamentos futuros (Jean Michel).

               26/11/2014 - Ajuste no filtro da crapavs (Jonata-RKAM).
               
               16/03/2015 - Ajustando o numero de documento da tabela crapavs
                            para ter o mesmo tratamento da do campo nrdocmto
                            
               06/10/2015 - Alteracoes referentes a exclusao de lautom de 
                            faturas  (Tiago/Rodrigo Melhoria 126)
                           
               07/10/2015 - Adicionado tratamento para ignorar os lançamentos futuros 
                            para os historicos de estorno de pagamento de emprestimo 
                            do tipo PP. (James)
                            
               04/11/2015 - Ajuste na rotina consulta-lancamento-periodo na consulta
                            na tabela crappla, incluindo os parenteses no filtro da data 
                            de periodo para nao duplicar o DB.COTAS SD354816 (Odirlei-AMcom)
                             
               26/11/2015 - Ajustando a consulta dos lancto futuros para mostrar
                            os lacto de folha de pagamento (Andre Santos - SUPERO)
                                        
               27/01/2016 - Remover lançamentos de salário com valor zerado dos 
                            lancamentos futuros na consulta-lancamento-periodo
                            (Marcos-Supero)      
                            
               28/01/2016 - Correcao na busca dos lancamentos de credito de Folha
                            de pagamento devido a duplicidade nos registros em 
                            query ma formada (Marcos-Supero)  
                                        
               26/02/2016 - Mostrar titulos vencidos na lautom (craptdb)
			                (Tiago/Rodrigo melhoria 116). 
               22/02/2016 - Incluir procedure consulta-lancto-car, fazer a procedure 
                            consulta-lancamento chamar a consulta-lancto-car 
                            Projeto melhoria 157 (Lucas Ranghetti #330322)
                                       
               24/02/2016 - Alterada a origem da informação da quantidade de dias de Float, que 
							antes estava na tabela CRAPCCO para a tabela CRAPCEB.
                            Alterado para buscar o campo qtdfloat da tabela crapcco 
                            para a tabela crapceb. Projeto 213 - Reciprocidade (Lombardi)
			   
               23/03/2016 - Adicionado origem 4(TAA) para armazenar a variavel
                            aux_dtddlslf na procedure consulta-lancamento (Lucas Ranghetti #411852)

               27/04/2016 - Incluir campo genrecid na consulta-lancto-car(Lucas Ranghetti/Fabricio)

               27/05/2016 - Inclusao na consulta-lancto-car: fldebito, cdagenci, 
                            cdbccxlt, nrdolote, nrseqdig. (Jaison/James)


			   28/06/2016 - Incluir conta na busca do maximo Float na consulta-lancamento-periodo
			                (Marcos-Supero #477843)

               09/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

         05/10/2017 - Ajuste para desconsiderar a situacao da folha de pagamento quando esta em 
                      Transacao Pendente (Rafael Monteiro - Mouts)

............................................................................ */

{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0003tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_vllandeb AS DECI                                           NO-UNDO.
DEF VAR aux_vllautom AS DECI                                           NO-UNDO.
DEF VAR aux_vllaudeb AS DECI                                           NO-UNDO.
DEF VAR aux_vllaucre AS DECI                                           NO-UNDO.
DEF VAR aux_vlestorn AS DECI                                           NO-UNDO.
DEF VAR aux_resulta1 AS DECI                                           NO-UNDO.
DEF VAR aux_resulta2 AS DECI                                           NO-UNDO.
DEF VAR aux_resulta3 AS DECI                                           NO-UNDO.
DEF VAR aux_resulta4 AS DECI                                           NO-UNDO.
DEF VAR aux_txjuresp AS DECI DECIMALS 10                               NO-UNDO.
DEF VAR aux_txjurneg AS DECI DECIMALS 10                               NO-UNDO.
DEF VAR aux_txjursaq AS DECI DECIMALS 10                               NO-UNDO.
DEF VAR tab_txcpmfcc AS DECI                                           NO-UNDO.
DEF VAR tab_txrdcpmf AS DECI                                           NO-UNDO.

DEF VAR aux_dtultdia AS DATE                                           NO-UNDO. 
DEF VAR tab_dtinipmf AS DATE                                           NO-UNDO.
DEF VAR tab_dtfimpmf AS DATE                                           NO-UNDO.
DEF VAR tab_dtiniabo AS DATE                                           NO-UNDO.

DEF VAR aux_contadct AS INTE                                           NO-UNDO.
DEF VAR tab_indabono AS INTE                                           NO-UNDO.
DEF VAR aux_sequen   AS INTE                                           NO-UNDO.
DEF VAR i-cod-erro   AS INTE                                           NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR c-dsc-erro   AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_vlpresta LIKE crapepr.vlsdeved                             NO-UNDO.
DEF VAR aux_dtfatura LIKE crapdat.dtmvtolt                             NO-UNDO.

/******************************************************************************/
/**          Função para retornar o ultimo dia com base no QTDFLOAT          **/
/**--------------------------------------------------------------------------**/
/**  AUTOR: Renato Darosci - Supero                                          **/
/**  DATA.: 12/08/2014                                                       **/
/******************************************************************************/
FUNCTION fn_dia_util_anterior RETURN DATE
 (INPUT  p-cdcooper AS INTE,
  INPUT  p-dtvencto AS DATE,
  INPUT  p-qtdddias AS INTE).
  
    DEF VAR   aux_qtdddias  AS INTE.
    DEF VAR   aux_dtvencto  AS DATE.

    ASSIGN aux_qtdddias = p-qtdddias
           aux_dtvencto = p-dtvencto.

    DO WHILE aux_qtdddias > 0:

      aux_dtvencto = aux_dtvencto - 1.

      IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtvencto)))            OR
          CAN-FIND(crapfer WHERE crapfer.cdcooper = p-cdcooper  AND
          crapfer.dtferiad = aux_dtvencto)  THEN
      DO:
          NEXT.
      END.

      aux_qtdddias = aux_qtdddias - 1.
	  
   END. /** Fim do DO WHILE TRUE **/

   RETURN aux_dtvencto.
END.

FUNCTION fn_dia_util_posterior RETURN DATE
 (INPUT  p-cdcooper AS INTE,
  INPUT  p-dtvencto AS DATE,
  INPUT  p-qtdddias AS INTE).
  
    DEF VAR   aux_qtdddias  AS INTE.
    DEF VAR   aux_dtvencto  AS DATE.

    ASSIGN aux_qtdddias = p-qtdddias
           aux_dtvencto = p-dtvencto.

    IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtvencto)))            OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = p-cdcooper  AND
        crapfer.dtferiad = aux_dtvencto)  THEN
        DO:
        
            DO WHILE aux_qtdddias > 0:
        
              aux_dtvencto = aux_dtvencto + 1.
        
              IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtvencto)))            OR
                  CAN-FIND(crapfer WHERE crapfer.cdcooper = p-cdcooper  AND
                  crapfer.dtferiad = aux_dtvencto)  THEN
              DO:
                  NEXT.
              END.
        
              aux_qtdddias = aux_qtdddias - 1.
        	  
            END. /** Fim do DO WHILE TRUE **/
        END.

   RETURN aux_dtvencto.
END.

PROCEDURE consulta-lancamento.

    DEF INPUT        PARAM p-cdcooper      AS INTE.
    DEF INPUT        PARAM p-cod-agencia   AS INTE.
    DEF INPUT        PARAM p-nro-caixa     AS INTE.                     
    DEF INPUT        PARAM p-cod-operador  AS CHAR.                

    DEF INPUT        PARAM p-nro-conta     AS INTE.
    DEF INPUT        PARAM p-origem        AS INTE. 

    DEF INPUT        PARAM p-idseqttl      AS INTE.
    DEF INPUT        PARAM p-nmdatela      AS CHAR.
    DEF INPUT        PARAM p-flgerlog      AS LOGI.

    DEF OUTPUT       PARAM TABLE FOR  tt-totais-futuros.
    DEF OUTPUT       PARAM TABLE FOR  tt-erro.
    DEF OUTPUT       PARAM TABLE FOR  tt-lancamento_futuro.

    RUN consulta-lancto-car(INPUT p-cdcooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT p-cod-operador,
                            INPUT p-nro-conta,
                            INPUT p-origem,
                            INPUT p-idseqttl,
                            INPUT p-nmdatela,
                            INPUT p-flgerlog,
                            INPUT ?,  /* DTINIPER */
                            INPUT ?,  /* DTFIMPER */
                            INPUT "", /* INDEBCRE */
                           OUTPUT TABLE tt-totais-futuros, 
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-lancamento_futuro).     
                          
     IF  RETURN-VALUE <> "OK" THEN
         RETURN "NOK".
         
     RETURN "OK".

END.

PROCEDURE consulta-lancto-car.

    DEF INPUT        PARAM p-cdcooper      AS DECIMAL.  
    DEF INPUT        PARAM p-cod-agencia   AS DECIMAL. 
    DEF INPUT        PARAM p-nro-caixa     AS DECIMAL.            
    DEF INPUT        PARAM p-cod-operador  AS CHAR.        
                                                     
    DEF INPUT        PARAM p-nro-conta     AS DECIMAL.   
    DEF INPUT        PARAM p-origem        AS DECIMAL.   
                                                     
    DEF INPUT        PARAM p-idseqttl      AS DECIMAL.   
    DEF INPUT        PARAM p-nmdatela      AS CHAR.  
    DEF INPUT        PARAM p-flgerlog      AS LOGI.  
                                                     
    DEF INPUT        PARAM p-dtiniper    AS DATE.
    DEF INPUT        PARAM p-dtfimper    AS DATE.
    DEF INPUT        PARAM p-indebcre    AS CHAR.

    DEF OUTPUT       PARAM TABLE FOR  tt-totais-futuros.
    DEF OUTPUT       PARAM TABLE FOR  tt-erro.
    DEF OUTPUT       PARAM TABLE FOR  tt-lancamento_futuro.
    
    /* Variaveis lancamento futuro */
    DEF VAR aux_dtmvtolt AS DATE      NO-UNDO.   
    DEF VAR aux_dshistor AS CHAR      NO-UNDO.   
    DEF VAR aux_nrdocmto AS CHAR      NO-UNDO.   
    DEF VAR aux_indebcre AS CHAR      NO-UNDO.   
    DEF VAR aux_vllanmto AS DEC       NO-UNDO.   
    DEF VAR aux_dsmvtolt AS CHAR      NO-UNDO.   
    DEF VAR aux_dstabela AS CHAR      NO-UNDO.   
    DEF VAR aux_cdhistor AS INT       NO-UNDO.   
   
    /* Variaveis totais */
    DEF VAR aux_vllautom AS DEC       NO-UNDO.   
    DEF VAR aux_vllaudeb AS DEC       NO-UNDO.   
    DEF VAR aux_vllaucre AS DEC       NO-UNDO.     
        
    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO. 
    DEF VAR xml_req2      AS LONGCHAR NO-UNDO. 
    
     /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */     
                                     
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                 
    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_consulta_lancto_car
       aux_handproc = PROC-HANDLE NO-ERROR(INPUT p-cdcooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT p-nro-conta,
                                           INPUT p-origem,
                                           INPUT p-idseqttl,
                                           INPUT p-nmdatela,
                                           INPUT IF p-flgerlog THEN 1 ELSE 0,
                                           INPUT p-dtiniper, 
                                           INPUT p-dtfimper, 
                                           INPUT p-indebcre, 
                                           OUTPUT "",  /* dscritic */
                                           OUTPUT 0,   /* cdcritic */
                                           OUTPUT ?,  /* clobxmlc_totais */
                                           OUTPUT ?). /* clobxml  */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_consulta_lancto_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    /*************************************************************/
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_consulta_lancto_car.pr_clobxmlc
           xml_req2 = pc_consulta_lancto_car.pr_clobxmlc_totais.     
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_consulta_lancto_car.pr_cdcritic 
                          WHEN pc_consulta_lancto_car.pr_cdcritic <> ?
           aux_dscritic = pc_consulta_lancto_car.pr_dscritic 
                          WHEN pc_consulta_lancto_car.pr_dscritic <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.     
            RETURN "NOK".
            
        END.       
        
    EMPTY TEMP-TABLE tt-lancamento_futuro.
    EMPTY TEMP-TABLE tt-totais-futuros.           
    
    /********** BUSCAR LANCAMENTOS **********/
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req.    
    
    IF  ponteiro_xml <> ? THEN
        DO: 
           xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE) NO-ERROR. 
           xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
            
           DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
               
               xRoot:GET-CHILD(xRoot2,aux_cont_raiz) NO-ERROR. 

               IF  xRoot2:SUBTYPE <> "ELEMENT"   THEN 
                   NEXT.            

               IF xRoot2:NUM-CHILDREN > 0 THEN
                  CREATE tt-lancamento_futuro.
                  
               DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 

                   xRoot2:GET-CHILD(xField,aux_cont). 

                   IF xField:SUBTYPE <> "ELEMENT" THEN 
                       NEXT. 

                   xField:GET-CHILD(xText,1).                    
                        
                 ASSIGN tt-lancamento_futuro.dshistor = xText:NODE-VALUE WHEN xField:NAME = "dshistor"         
                        tt-lancamento_futuro.nrdocmto = xText:NODE-VALUE WHEN xField:NAME = "nrdocmto"
                        tt-lancamento_futuro.indebcre = xText:NODE-VALUE WHEN xField:NAME = "indebcre"
                        tt-lancamento_futuro.dsmvtolt = xText:NODE-VALUE WHEN xField:NAME = "dsmvtolt"
                        tt-lancamento_futuro.dstabela = xText:NODE-VALUE WHEN xField:NAME = "dstabela"                        
                        tt-lancamento_futuro.vllanmto = DEC(xText:NODE-VALUE) WHEN xField:NAME = "vllanmto"                 
                        tt-lancamento_futuro.cdhistor = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdhistor"
                        tt-lancamento_futuro.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt"
                        tt-lancamento_futuro.genrecid = INT(xText:NODE-VALUE)  WHEN xField:NAME = "genrecid"
                        tt-lancamento_futuro.fldebito = INT(xText:NODE-VALUE)  WHEN xField:NAME = "fldebito"
                        tt-lancamento_futuro.cdagenci = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdagenci"
                        tt-lancamento_futuro.cdbccxlt = INT(xText:NODE-VALUE)  WHEN xField:NAME = "cdbccxlt"
                        tt-lancamento_futuro.nrdolote = INT(xText:NODE-VALUE)  WHEN xField:NAME = "nrdolote"
                        tt-lancamento_futuro.nrseqdig = INT(xText:NODE-VALUE)  WHEN xField:NAME = "nrseqdig"
                        tt-lancamento_futuro.dtrefere = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtrefere".
               END.              
             
           END.    
           
           SET-SIZE(ponteiro_xml) = 0.    
        END.           
    
    /************** BUSCAR TOTAIS *********/
    
    /* Efetuar a leitura do XML */ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req2) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req2. 
    
    IF  ponteiro_xml <> ? THEN
        DO: 
           xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE) NO-ERROR. 
           xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
            
           DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
               
               xRoot:GET-CHILD(xRoot2,aux_cont_raiz) NO-ERROR. 

               IF  xRoot2:SUBTYPE <> "ELEMENT"   THEN 
                   NEXT.            

               IF xRoot2:NUM-CHILDREN > 0 THEN
                  CREATE tt-totais-futuros.
                  
               DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 

                   xRoot2:GET-CHILD(xField,aux_cont). 

                   IF xField:SUBTYPE <> "ELEMENT" THEN 
                       NEXT. 

                   xField:GET-CHILD(xText,1).                    
                    
                 ASSIGN tt-totais-futuros.vllautom = DEC(xText:NODE-VALUE)  WHEN xField:NAME = "vllautom"
                        tt-totais-futuros.vllaudeb = DEC(xText:NODE-VALUE)  WHEN xField:NAME = "vllaudeb"
                        tt-totais-futuros.vllaucre = DEC(xText:NODE-VALUE)  WHEN xField:NAME = "vllaucre". 
                   
               END.              
             
           END.    
           
           SET-SIZE(ponteiro_xml) = 0.    
        END.        
    
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
        
    RETURN "OK".                                     

END.


PROCEDURE consulta-lancamento-periodo.

    DEF INPUT        PARAM p-cdcooper      AS INTE.
    DEF INPUT        PARAM p-cod-agencia   AS INTE.
    DEF INPUT        PARAM p-nro-caixa     AS INTE.                     
    DEF INPUT        PARAM p-cod-operador  AS CHAR.                

    DEF INPUT        PARAM p-nro-conta     AS INTE.
    DEF INPUT        PARAM p-origem        AS INTE. 

    DEF INPUT        PARAM p-idseqttl      AS INTE.
    DEF INPUT        PARAM p-nmdatela      AS CHAR.
    DEF INPUT        PARAM p-flgerlog      AS LOGI.

    DEF INPUT        PARAM par_dtiniper    AS DATE.
    DEF INPUT        PARAM par_dtfimper    AS DATE.
    DEF INPUT        PARAM par_indebcre    AS CHAR.

    DEF OUTPUT       PARAM TABLE FOR  tt-totais-futuros.
    DEF OUTPUT       PARAM TABLE FOR  tt-erro.
    DEF OUTPUT       PARAM TABLE FOR  tt-lancamento_futuro.
                                                   
    DEF VAR h-b1wgen0153 AS HANDLE NO-UNDO.
 
    DEF VAR aux_cdhistaa AS INTE NO-UNDO.
    DEF VAR aux_cdhsetaa AS INTE NO-UNDO.
    DEF VAR aux_cdhisint AS INTE NO-UNDO.
    DEF VAR aux_cdhseint AS INTE NO-UNDO.

    DEF VAR aux_ponteiro AS INTE NO-UNDO.

    DEF VAR aux_vltarpro AS DECI NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE NO-UNDO.
    DEF VAR aux_cdbattaa AS CHAR NO-UNDO.
    DEF VAR aux_cdbatint AS CHAR NO-UNDO.
    DEF VAR aux_cdhishcb AS CHAR NO-UNDO.

    DEF VAR aux_dtrefere AS DATE           NO-UNDO.     
    DEF VAR aux_dtddlslf AS DATE           NO-UNDO.
    DEF VAR aux_lshistor AS CHAR           NO-UNDO.
    DEF VAR aux_flgimune AS LOG            NO-UNDO.
    DEF VAR aux_qtregist AS INTE           NO-UNDO.
    DEF VAR aux_dtdpagto AS DATE           NO-UNDO.

    DEF VAR aux_qtdfloat AS INTE           NO-UNDO.
    DEF VAR aux_vldpagto AS DECI           NO-UNDO.
    DEF VAR aux_qtdpagto AS INTE           NO-UNDO.

    DEF VAR aux_cdhistor AS DECI           NO-UNDO.
    DEF VAR tel_dshistor AS CHAR           NO-UNDO.
    DEF VAR aux_cdhisest AS INTE           NO-UNDO.
    DEF VAR aux_vltarifa AS DECI           NO-UNDO.

    DEF VAR aux_vllanmto AS DECI           NO-UNDO.

    DEF VAR h-b1wgen0002 AS HANDLE         NO-UNDO.
    DEF VAR h-b1wgen0159 AS HANDLE         NO-UNDO.
    
    EMPTY TEMP-TABLE tt-lancamento_futuro.
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-totais-futuros.

    /** Atribui descricao da origem e da transacao **/
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_vllautom = 0
           aux_vllaudeb = 0
           aux_vllaucre = 0
           aux_dsorigem = TRIM(ENTRY(p-origem,des_dorigens,","))
           aux_dstransa = "Consulta lancamentos futuros.".
              
    FIND FIRST crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAIL crapdat THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
           {sistema/generico/includes/b1wgen0001.i}

           RUN proc_gerar_log (INPUT p-cdcooper,
                               INPUT p-cod-operador,
                               INPUT "",
                               INPUT aux_dsorigem,
                               INPUT aux_dstransa,
                               INPUT FALSE,
                               INPUT p-idseqttl,
                               INPUT p-nmdatela,
                               INPUT p-nro-conta,
                              OUTPUT aux_nrdrowid).
           
           RETURN "NOK".
        END. 

    /*  .....................................................................
        Especifico para CASH - FOTON .......... Utilizado a Mesma Analise da
        versao anterior do sistema Cash (Progress) descrito no saldo_ass.p   */ 

    IF  p-origem = 4 THEN
        DO:
            ASSIGN aux_vllautom = 0.
            
            FIND crapass WHERE crapass.cdcooper = p-cdcooper  AND
                               crapass.nrdconta = p-nro-conta NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapass  THEN
                DO:
                    ASSIGN i-cod-erro = 3 
                           c-dsc-erro = " ".
           
                    {sistema/generico/includes/b1wgen0001.i}

                    RUN proc_gerar_log (INPUT p-cdcooper,
                                        INPUT p-cod-operador,
                                        INPUT "",
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT p-idseqttl,
                                        INPUT p-nmdatela,
                                        INPUT p-nro-conta,
                                        OUTPUT aux_nrdrowid).
           
                    RETURN "NOK".
                END.
            
            FIND crapsld WHERE crapsld.cdcooper = p-cdcooper  AND
                               crapsld.nrdconta = p-nro-conta NO-LOCK NO-ERROR.
   
            IF   NOT AVAILABLE crapsld   THEN
                 DO:
                    CREATE tt-totais-futuros.
                    ASSIGN tt-totais-futuros.vllautom = 0.

                    RETURN "OK".
                 END.
                            
            /*  Nao calcula programados para quem movimenta com talao 
                de cheques  */
    
            IF  CAN-DO('1,2,3,4,8,9,10,11,12,13,14,15',STRING(crapass.cdtipcta)) AND
                crapass.cdsitdct = 1  THEN
                DO:
                    CREATE tt-totais-futuros.
                    ASSIGN tt-totais-futuros.vllautom = 0.

                    RETURN "OK".
                END.
                
            /*  Para associados sem talao de cheques e sem o crédito da folha 
                no mes  */

            IF  crapsld.vltsallq = 0   THEN
                DO:
                    FIND FIRST craplcm WHERE 
                               craplcm.cdcooper = p-cdcooper       AND
                               craplcm.nrdconta = p-nro-conta      AND
                               craplcm.dtmvtolt = crapdat.dtmvtolt AND
                              (craplcm.cdhistor = 7                OR
                               craplcm.cdhistor = 8)
                               USE-INDEX craplcm2 NO-LOCK NO-ERROR.
                        
                     IF   NOT AVAILABLE craplcm   THEN
                          DO:
                               CREATE tt-totais-futuros.
                               ASSIGN tt-totais-futuros.vllautom = 0.

                               RETURN "OK".
                          END.
                          
                END.

            /*  Parcela de seguro  */

            FOR EACH crapseg WHERE crapseg.cdcooper = p-cdcooper   AND
                                   crapseg.nrdconta = p-nro-conta  AND
                                   crapseg.indebito = 0            AND
                                  (crapseg.cdsitseg = 1 OR
                                  (crapseg.cdsitseg = 3 AND
                                   crapseg.tpseguro = 11))         AND
                                   MONTH(crapseg.dtdebito) = 
                                          MONTH(crapdat.dtmvtolt)  AND
                                   YEAR(crapseg.dtdebito) = 
                                          YEAR(crapdat.dtmvtolt)   NO-LOCK:

                aux_vllautom = aux_vllautom + crapseg.vlpreseg.

            END.  /* FOR EACH SEGURO */

            /*  Parcela de poupança programada  */

            FOR EACH craprpp WHERE craprpp.cdcooper = p-cdcooper         AND
                                   craprpp.nrdconta = p-nro-conta        AND
                                  (craprpp.cdsitrpp = 1                  OR
                                  (craprpp.cdsitrpp = 2                  AND
                                   craprpp.dtrnirpp = craprpp.dtdebito)) AND
                                   MONTH(craprpp.dtdebito) = 
                                          MONTH(crapdat.dtmvtolt)        AND
                                   YEAR(craprpp.dtdebito) =
                                          YEAR(crapdat.dtmvtolt)     NO-LOCK:

                aux_vllautom = aux_vllautom + craprpp.vlprerpp.

            END. /* FOR EACH POUPANCA PROGRAMADA */

            /*  Parcela do plano de capital  */

            FOR EACH crappla WHERE crappla.cdcooper  = p-cdcooper   AND
                                   crappla.nrdconta  = p-nro-conta  AND
                                   crappla.tpdplano  = 1            AND
                                   crappla.cdsitpla  = 1            AND
              /* Plano C/C */      crappla.flgpagto  = FALSE        AND
                                   crappla.indpagto  = 0      NO-LOCK:

                IF   crappla.vlpenden > 0 THEN
                     DO:
                         IF   crappla.dtdpagto <> crapdat.dtmvtolt  THEN
                              ASSIGN aux_vllautom = aux_vllautom +
                                                    crappla.vlpenden.
                     END.

                IF   MONTH(crappla.dtdpagto) = MONTH(crapdat.dtmvtolt)
                       AND
                     YEAR(crappla.dtdpagto) = YEAR(crapdat.dtmvtolt) 
                       THEN
                     ASSIGN aux_vllautom = aux_vllautom + 
                                           crappla.vlprepla.
                    
            END.

            CREATE tt-totais-futuros.
            ASSIGN tt-totais-futuros.vllautom = aux_vllautom.

            RETURN "OK".
        END.
        /* ................    fim do p-origem = 4 - CASH   ................ */

    aux_dtultdia = ((DATE(MONTH(crapdat.dtmvtolt),28,YEAR(crapdat.dtmvtolt)) +
                   4) - DAY(DATE(MONTH(crapdat.dtmvtolt),28,
                   YEAR(crapdat.dtmvtolt)) + 4)).
    
    IF  (p-origem = 3   OR    /** INTERNET **/
         p-origem = 4)  AND   /** TAA      **/
        p-cdcooper <> 3 THEN  /** CECRED   **/
        DO:
            FIND crapage WHERE crapage.cdcooper = p-cdcooper    AND
                               crapage.cdagenci = p-cod-agencia 
                               NO-LOCK NO-ERROR.
                       
            IF  NOT AVAILABLE crapage  THEN
                DO:
                    ASSIGN i-cod-erro = 962
                           c-dsc-erro = " ".
           
                    { sistema/generico/includes/b1wgen0001.i }

                    RUN proc_gerar_log (INPUT p-cdcooper,
                                        INPUT p-cod-operador,
                                        INPUT "",
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT p-idseqttl,
                                        INPUT p-nmdatela,
                                        INPUT p-nro-conta,
                                       OUTPUT aux_nrdrowid).
                      
                    RETURN "NOK".
                END.
 
            ASSIGN aux_dtddlslf = aux_datdodia + crapage.qtddlslf.
        END.
        
    /*  Busca tabela com a taxa do CPMF */
    FIND craptab WHERE craptab.cdcooper = p-cdcooper         AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "USUARI"           AND
                       craptab.cdempres = 11                 AND
                       craptab.cdacesso = "CTRCPMFCCR"       AND
                       craptab.tpregist = 1                  
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             ASSIGN i-cod-erro = 641 
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}
             
             RUN proc_gerar_log (INPUT p-cdcooper,
                                 INPUT p-cod-operador,
                                 INPUT "",
                                 INPUT aux_dsorigem,
                                 INPUT aux_dstransa,
                                 INPUT FALSE,
                                 INPUT p-idseqttl,
                                 INPUT p-nmdatela,
                                 INPUT p-nro-conta,
                                OUTPUT aux_nrdrowid).

             RETURN "NOK".
         END.
 
    ASSIGN tab_dtinipmf = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                               INT(SUBSTRING(craptab.dstextab,1,2)),
                               INT(SUBSTRING(craptab.dstextab,7,4)))
           tab_dtfimpmf = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                               INT(SUBSTRING(craptab.dstextab,12,2)),
                               INT(SUBSTRING(craptab.dstextab,18,4)))
           tab_txcpmfcc = IF crapdat.dtmvtolt >= tab_dtinipmf AND
                             crapdat.dtmvtolt <= tab_dtfimpmf 
                             THEN DECIMAL(SUBSTR(craptab.dstextab,23,13))
                             ELSE 0
           tab_txrdcpmf = IF crapdat.dtmvtolt >= tab_dtinipmf AND
                             crapdat.dtmvtolt <= tab_dtfimpmf 
                             THEN DECIMAL(SUBSTR(craptab.dstextab,38,13))
                             ELSE 1
           tab_indabono = INTE(SUBSTR(craptab.dstextab,51,1))  /* 0 = abona
                                                              1 = nao abona */
           tab_dtiniabo = DATE(INT(SUBSTRING(craptab.dstextab,56,2)),
                               INT(SUBSTRING(craptab.dstextab,53,2)),
                               INT(SUBSTRING(craptab.dstextab,59,4))). /* data
                                                        de inicio do abono */

    ASSIGN aux_vllandeb = aux_vllautom.
    /*Carrega taxa de juros do cheque especial, 
               da multa c/c, multa s/saque bloq. */

    FIND craptab WHERE craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "USUARI"       AND
                       craptab.cdempres = 11             AND
                       craptab.cdacesso = "JUROSNEGAT"   AND
                       craptab.tpregist = 1              AND
                       craptab.cdcooper = p-cdcooper
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
            ASSIGN i-cod-erro = 162 
                   c-dsc-erro = " ".
           
           {sistema/generico/includes/b1wgen0001.i}
           
           RUN proc_gerar_log (INPUT p-cdcooper,
                               INPUT p-cod-operador,
                               INPUT "",
                               INPUT aux_dsorigem,
                               INPUT aux_dstransa,
                               INPUT FALSE,
                               INPUT p-idseqttl,
                               INPUT p-nmdatela,
                               INPUT p-nro-conta,
                              OUTPUT aux_nrdrowid).

           RETURN "NOK".
         END.

    aux_txjurneg = DECIMAL(SUBSTRING(craptab.dstextab,1,10)) / 100.

    FIND craptab WHERE craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "USUARI"       AND
                       craptab.cdempres = 11             AND
                       craptab.cdacesso = "JUROSSAQUE"   AND
                       craptab.tpregist = 1              AND
                       craptab.cdcooper = p-cdcooper
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
            ASSIGN i-cod-erro = 162
                   c-dsc-erro = " ".
           
           {sistema/generico/includes/b1wgen0001.i}
           
           RUN proc_gerar_log (INPUT p-cdcooper,
                               INPUT p-cod-operador,
                               INPUT "",
                               INPUT aux_dsorigem,
                               INPUT aux_dstransa,
                               INPUT FALSE,
                               INPUT p-idseqttl,
                               INPUT p-nmdatela,
                               INPUT p-nro-conta,
                              OUTPUT aux_nrdrowid).

           RETURN "NOK".
         END.

    aux_txjursaq = DECIMAL(SUBSTRING(craptab.dstextab,1,10)) / 100.  

    FIND craptab WHERE craptab.cdcooper = p-cdcooper   AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = "HSTCHEQUES" AND
                       craptab.tpregist = 0            NO-LOCK NO-ERROR.
                
    IF  AVAILABLE craptab   THEN
        aux_lshistor = craptab.dstextab.
    ELSE
        aux_lshistor = "999".

    FOR EACH craplau WHERE craplau.cdcooper = p-cdcooper            AND
                           craplau.nrdconta = p-nro-conta           AND
                           craplau.dtmvtopg > 04/30/97              AND
                           ((craplau.dtmvtopg >= par_dtiniper       AND 
                             craplau.dtmvtopg <= par_dtfimper)      OR 
                             par_dtiniper = ? AND par_dtfimper = ?) AND
                           craplau.dtdebito = ?                     NO-LOCK
                           USE-INDEX craplau2:

        IF   p-cdcooper <> 3                  AND
            (p-cod-agencia = 90  /*Internet*/ OR
             p-cod-agencia = 91) /* TAA */    AND
             craplau.dtmvtopg > aux_dtddlslf  THEN
             NEXT.
             
        IF   craplau.cdhistor = 21 OR     /* Tratar cheques da Consumo */
             craplau.cdhistor = 26 THEN
             IF   DAY(crapdat.dtmvtolt) < 16 THEN
             IF   MONTH(craplau.dtmvtopg) <> MONTH(crapdat.dtmvtolt) THEN
                  NEXT.
              
        FIND craphis WHERE craphis.cdcooper = p-cdcooper                         AND
                           craphis.cdhistor = craplau.cdhistor                   NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craphis   THEN
             DO:
                 ASSIGN i-cod-erro = 80 
                        c-dsc-erro = " ".
             
                {sistema/generico/includes/b1wgen0001.i}
      
                RUN proc_gerar_log (INPUT p-cdcooper,
                                    INPUT p-cod-operador,
                                    INPUT "",
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT p-idseqttl,
                                    INPUT p-nmdatela,
                                    INPUT p-nro-conta,
                                   OUTPUT aux_nrdrowid).

                RETURN "NOK".
             END.

        IF   craphis.indebfol > 0 THEN
             NEXT.

        IF   CAN-DO("1,2,3,4,5",STRING(craphis.inhistor))   THEN
             ASSIGN aux_vllautom = aux_vllautom + craplau.vllanaut
                    aux_vllaucre = aux_vllaucre + craplau.vllanaut.
        ELSE
        IF   CAN-DO("11,12,13,14,15",STRING(craphis.inhistor))  THEN
             ASSIGN aux_vllautom = aux_vllautom - craplau.vllanaut
                    aux_vllaudeb = aux_vllaudeb + craplau.vllanaut.
        ELSE
             DO:
                ASSIGN i-cod-erro = 83 
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}
                
                RUN proc_gerar_log (INPUT p-cdcooper,
                                    INPUT p-cod-operador,
                                    INPUT "",
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT p-idseqttl,
                                    INPUT p-nmdatela,
                                    INPUT p-nro-conta,
                                   OUTPUT aux_nrdrowid).

                RETURN "NOK".
             END.

        IF (craphis.indebcre = par_indebcre OR par_indebcre = "") THEN
	        DO:
                CREATE tt-lancamento_futuro.
                ASSIGN tt-lancamento_futuro.dtmvtolt = craplau.dtmvtopg
                       tt-lancamento_futuro.dsmvtolt =
                                     STRING(craplau.dtmvtopg,"99/99/9999")
                       tt-lancamento_futuro.dshistor = craphis.dshistor
                       tt-lancamento_futuro.nrdocmto = 
                                IF LENGTH(STRING(craplau.nrdocmto)) < 10
                                   THEN STRING(craplau.nrdocmto,"zzzzzzz,zz9")
                                   ELSE 
                            SUBSTR(STRING(craplau.nrdocmto,"9999999999999999999999999"),
                                   15,11)
                       tt-lancamento_futuro.indebcre = craphis.indebcre
                       tt-lancamento_futuro.vllanmto = craplau.vllanaut
                       tt-lancamento_futuro.dstabela = "craplau"
                       tt-lancamento_futuro.genrecid = RECID(craplau)
                       tt-lancamento_futuro.cdhistor = craplau.cdhistor.
                       
              
                IF  craphis.cdhistor = 508  THEN  /* Pagtos INTERNET */
                    ASSIGN tt-lancamento_futuro.dshistor = tt-lancamento_futuro.dshistor
                                                           + " - "  + craplau.dscedent.
                
                IF  CAN-DO("375,376,377,537,538,539,771,772,1009",
                           STRING(craplau.cdhistor))  THEN
                    tt-lancamento_futuro.nrdocmto = STRING(craplau.nrctadst,
                                                       "zzzzz,zzz,9").
            END.
        

    END.  /*  Fim do FOR EACH -- Leitura do craplau */

    /* Lancamentos de Debito de Folha */
    FOR EACH crappfp WHERE crappfp.cdcooper = p-cdcooper
                       AND crappfp.idsitapr > 3 /* Aprovados */
                       AND crappfp.idsitapr <> 6 /*Transacao Pendente*/
                       AND crappfp.flsitdeb = 0 /* Ainda nao debitado */
                       NO-LOCK
       ,EACH craplfp WHERE craplfp.cdcooper = crappfp.cdcooper
                       AND craplfp.cdempres = crappfp.cdempres
                       AND craplfp.nrseqpag = crappfp.nrseqpag
                       NO-LOCK
       ,EACH crapemp WHERE crapemp.cdcooper = crappfp.cdcooper
                       AND crapemp.cdempres = crappfp.cdempres
                       AND crapemp.nrdconta = p-nro-conta
                       NO-LOCK
       ,EACH crapofp WHERE crapofp.cdcooper = craplfp.cdcooper
                       AND crapofp.cdorigem = craplfp.cdorigem
                       NO-LOCK
       ,EACH craphis WHERE craphis.cdcooper = crapofp.cdcooper
                   AND (
                        (    crapemp.idtpempr = 'C'
                         AND craphis.cdhistor = crapofp.cdhsdbcp
                        )
                     OR (    crapemp.idtpempr = 'O'
                         AND craphis.cdhistor = crapofp.cdhisdeb
                       )
                       )
                   NO-LOCK BREAK BY craplfp.cdorigem:
        
        /* Acumulamos o valor de cada lancamento */
        ASSIGN aux_vllanmto = aux_vllanmto + craplfp.vllancto.

        IF  LAST-OF(craplfp.cdorigem) THEN DO:

            IF  CAN-DO("1,2,3,4,5",STRING(craphis.inhistor))   THEN
                ASSIGN aux_vllautom = aux_vllautom + crappfp.vllctpag
                       aux_vllaucre = aux_vllaucre + crappfp.vllctpag.
            ELSE
            IF  CAN-DO("11,12,13,14,15",STRING(craphis.inhistor))  THEN
                ASSIGN aux_vllautom = aux_vllautom - crappfp.vllctpag
                       aux_vllaudeb = aux_vllaudeb + crappfp.vllctpag.
            ELSE DO:
                ASSIGN i-cod-erro = 83 
                       c-dsc-erro = " ".
               
                {sistema/generico/includes/b1wgen0001.i}
                    
                RUN proc_gerar_log (INPUT p-cdcooper,
                                    INPUT p-cod-operador,
                                    INPUT "",
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT p-idseqttl,
                                    INPUT p-nmdatela,
                                    INPUT p-nro-conta,
                                    OUTPUT aux_nrdrowid).
    
                RETURN "NOK".
            END.                

            CREATE tt-lancamento_futuro.
            ASSIGN tt-lancamento_futuro.dtmvtolt = crappfp.dtdebito
                   tt-lancamento_futuro.dshistor = craphis.dshistor    
                   tt-lancamento_futuro.nrdocmto = STRING(crappfp.nrseqpag,"zzz,zzz,zz9")
                   tt-lancamento_futuro.indebcre = craphis.indebcre
                   tt-lancamento_futuro.vllanmto = aux_vllanmto
                   tt-lancamento_futuro.cdhistor = craphis.cdhistor               
                   tt-lancamento_futuro.dstabela = "CRAPPFP-DEBITO"
                   tt-lancamento_futuro.genrecid = RECID(crappfp)
                   tt-lancamento_futuro.dsmvtolt = STRING(crappfp.dtdebito,"99/99/9999").

            /* Zeramos a variavel */
            ASSIGN aux_vllanmto = 0.
        END.

    END. /* FIM do FOR Lancamentos de Debito de Folha */

    /* Lancamentos de Debitos de Tarifas */
    FOR EACH crappfp WHERE crappfp.cdcooper =  p-cdcooper
                       AND crappfp.idsitapr > 3 /* Aprovados */
                       AND crappfp.idsitapr <> 6 /*Transacao Pendente*/
                       AND crappfp.flsittar = 0 /* Ainda nao debitado a tarifa */
                       AND crappfp.vltarapr > 0 /* Com tarifa a cobrar */
                       NO-LOCK
       ,EACH crapemp WHERE crapemp.cdcooper = crappfp.cdcooper
                       AND crapemp.cdempres = crappfp.cdempres
                       AND crapemp.nrdconta = p-nro-conta
                       NO-LOCK BY crappfp.nrseqpag:

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /*** Faz a busca do historico da transação ***/
        RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
                         aux_ponteiro = PROC-HANDLE
           
        ("SELECT folh0001.fn_histor_tarifa_folha(" + STRING(crapemp.cdcooper) + ","
                                                   + STRING(crapemp.cdcontar) + ","
                                                   + STRING(crappfp.idopdebi) + ","
                                                   + STRING(crappfp.vllctpag) + ") FROM dual").
        
        FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
            ASSIGN aux_cdhistor = DECI(proc-text).
        END.
        
        CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
              WHERE PROC-HANDLE = aux_ponteiro.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        FIND FIRST craphis WHERE craphis.cdcooper = p-cdcooper
                             AND craphis.cdhistor = aux_cdhistor
                             NO-LOCK NO-ERROR.
    
        IF  AVAIL craphis THEN
            ASSIGN tel_dshistor = craphis.dshistor.
        ELSE DO:
            ASSIGN i-cod-erro = 83 
                   c-dsc-erro = " ".
           
            {sistema/generico/includes/b1wgen0001.i}
                
            RUN proc_gerar_log (INPUT p-cdcooper,
                                INPUT p-cod-operador,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT p-idseqttl,
                                INPUT p-nmdatela,
                                INPUT p-nro-conta,
                                OUTPUT aux_nrdrowid).
    
            RETURN "NOK".
        END.

        IF  CAN-DO("1,2,3,4,5",STRING(craphis.inhistor))   THEN
            ASSIGN aux_vllautom = aux_vllautom + (crappfp.qtlctpag * crappfp.vltarapr)
                   aux_vllaucre = aux_vllaucre + (crappfp.qtlctpag * crappfp.vltarapr).
        ELSE
        IF  CAN-DO("11,12,13,14,15",STRING(craphis.inhistor))  THEN
            ASSIGN aux_vllautom = aux_vllautom - (crappfp.qtlctpag * crappfp.vltarapr)
                   aux_vllaudeb = aux_vllaudeb + (crappfp.qtlctpag * crappfp.vltarapr).
        ELSE DO:
            ASSIGN i-cod-erro = 83 
                   c-dsc-erro = " ".
           
            {sistema/generico/includes/b1wgen0001.i}
                
            RUN proc_gerar_log (INPUT p-cdcooper,
                                INPUT p-cod-operador,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT p-idseqttl,
                                INPUT p-nmdatela,
                                INPUT p-nro-conta,
                                OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.                

        CREATE tt-lancamento_futuro.
        ASSIGN tt-lancamento_futuro.dtmvtolt = crappfp.dtcredit
               tt-lancamento_futuro.dshistor = tel_dshistor
               tt-lancamento_futuro.nrdocmto = STRING(crappfp.nrseqpag,"zzz,zzz,zz9")
               tt-lancamento_futuro.indebcre = craphis.indebcre
               tt-lancamento_futuro.vllanmto = (crappfp.qtlctpag * crappfp.vltarapr)
               tt-lancamento_futuro.cdhistor = aux_cdhistor
               tt-lancamento_futuro.dstabela = "CRAPPFP-TARIFA"
               tt-lancamento_futuro.genrecid = RECID(crappfp)
               tt-lancamento_futuro.dsmvtolt = STRING(crappfp.dtcredit,"99/99/9999").

    END. /* FIM do FOR Lancamentos de Debitos de Tarifas */

    /* Lancamentos de Creditos de Folha */
    FOR EACH crappfp WHERE crappfp.cdcooper =  p-cdcooper
                       AND crappfp.idsitapr > 3 /* Aprovados */
                       AND crappfp.idsitapr <> 6 /*Transacao Pendente*/
                       AND crappfp.flsitcre = 0 /* Pagamento ainda não creditado */
                       NO-LOCK
       ,EACH craplfp WHERE craplfp.cdcooper = crappfp.cdcooper
                       AND craplfp.cdempres = crappfp.cdempres
                       AND craplfp.nrseqpag = crappfp.nrseqpag
                       AND craplfp.idsitlct = "L" /* Somente os lançados*/
                       AND craplfp.idtpcont = "C" /* Somente associados Cecred */
                       AND craplfp.vllancto > 0   /* Remover lançamentos zerados */
                       AND craplfp.nrdconta = p-nro-conta
                       NO-LOCK
       ,EACH crapemp WHERE crapemp.cdcooper = crappfp.cdcooper
                       AND crapemp.cdempres = crappfp.cdempres
                       NO-LOCK
       ,EACH crapofp WHERE crapofp.cdcooper = craplfp.cdcooper
                       AND crapofp.cdorigem = craplfp.cdorigem
                       NO-LOCK
       ,EACH craphis WHERE craphis.cdcooper = crapofp.cdcooper
                       AND (
                            (    crapemp.idtpempr = 'C'
                             AND craphis.cdhistor = crapofp.cdhscrcp
                            )
                          OR(    crapemp.idtpempr = 'O'
                             AND craphis.cdhistor = crapofp.cdhiscre
                            )
                           )
                       NO-LOCK BY craplfp.nrseqlfp:

        IF  CAN-DO("1,2,3,4,5",STRING(craphis.inhistor))   THEN
            ASSIGN aux_vllautom = aux_vllautom + craplfp.vllancto
                   aux_vllaucre = aux_vllaucre + craplfp.vllancto.
        ELSE
        IF  CAN-DO("11,12,13,14,15",STRING(craphis.inhistor))  THEN
            ASSIGN aux_vllautom = aux_vllautom - craplfp.vllancto
                   aux_vllaudeb = aux_vllaudeb + craplfp.vllancto.
        ELSE DO:
            ASSIGN i-cod-erro = 83 
                   c-dsc-erro = " ".
           
            {sistema/generico/includes/b1wgen0001.i}
                
            RUN proc_gerar_log (INPUT p-cdcooper,
                                INPUT p-cod-operador,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT p-idseqttl,
                                INPUT p-nmdatela,
                                INPUT p-nro-conta,
                                OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.

        CREATE tt-lancamento_futuro.
        ASSIGN tt-lancamento_futuro.dtmvtolt = crappfp.dtcredit
               tt-lancamento_futuro.dshistor = craphis.dshistor
               tt-lancamento_futuro.nrdocmto = STRING(crappfp.nrseqpag,"zzzz9") + STRING(craplfp.nrseqlfp,"999999")
               tt-lancamento_futuro.indebcre = craphis.indebcre
               tt-lancamento_futuro.vllanmto = craplfp.vllancto
               tt-lancamento_futuro.cdhistor = craphis.cdhistor
               tt-lancamento_futuro.dstabela = "CRAPLFP"
               tt-lancamento_futuro.genrecid = RECID(craplfp)
               tt-lancamento_futuro.dsmvtolt = STRING(crappfp.dtcredit,"99/99/9999").

    END. /* FIM do FOR Lancamentos de Creditos de Folha */
    
    ASSIGN aux_dtrefere = crapdat.dtmvtolt - DAY(crapdat.dtmvtolt).

    FOR EACH crapavs WHERE crapavs.cdcooper = p-cdcooper          AND
                           crapavs.nrdconta = p-nro-conta         AND
                           CAN-DO("1,3",STRING(crapavs.tpdaviso)) AND
                           crapavs.insitavs = 0                   AND
                          (crapavs.flgproce = FALSE OR
                          (crapavs.cdhistor = 108   AND
                           crapavs.dtrefere = aux_dtrefere)) NO-LOCK:

       
        /* Se os periodos foram informados, filtrar por eles */
        IF   par_dtiniper <> ?       AND
             par_dtfimper <> ?       AND
             crapavs.dtdebito <> ?   AND
            (crapavs.dtdebito < par_dtiniper   OR
             crapavs.dtdebito > par_dtfimper)  THEN
              NEXT.   

        FIND craphis WHERE craphis.cdcooper = p-cdcooper                          AND
                           craphis.cdhistor = crapavs.cdhistor                    NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craphis   THEN
             DO:
                 ASSIGN i-cod-erro = 80 
                        c-dsc-erro = " ".
            
                {sistema/generico/includes/b1wgen0001.i}

                RUN proc_gerar_log (INPUT p-cdcooper,
                                    INPUT p-cod-operador,
                                    INPUT "",
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT p-idseqttl,
                                    INPUT p-nmdatela,
                                    INPUT p-nro-conta,
                                   OUTPUT aux_nrdrowid).
             
                RETURN "NOK".
             END.

         
        /* Se foi informado credito ou debito, filtrar */
        IF   par_indebcre <> ""                    AND
             NOT par_indebcre = craphis.indebcre   THEN
            NEXT.
             

        IF   CAN-DO("1,2,3,4,5",STRING(craphis.inhistor))   THEN
             ASSIGN aux_vllautom = aux_vllautom + (crapavs.vllanmto - 
                                   crapavs.vldebito)
                    aux_vllaucre = aux_vllaucre + (crapavs.vllanmto - 
                                   crapavs.vldebito).
        ELSE
        IF   CAN-DO("11,12,13,14,15",STRING(craphis.inhistor))  THEN
             ASSIGN aux_vllautom = aux_vllautom - (crapavs.vllanmto - 
                                   crapavs.vldebito)
                    aux_vllaudeb = aux_vllaudeb + (crapavs.vllanmto - 
                                   crapavs.vldebito).
        ELSE
             DO:
                 ASSIGN i-cod-erro = 83 
                        c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}
                
                RUN proc_gerar_log (INPUT p-cdcooper,
                                    INPUT p-cod-operador,
                                    INPUT "",
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT p-idseqttl,
                                    INPUT p-nmdatela,
                                    INPUT p-nro-conta,
                                   OUTPUT aux_nrdrowid).                

                RETURN "NOK".
             END.                
               
        CREATE tt-lancamento_futuro.
        ASSIGN tt-lancamento_futuro.dtmvtolt = IF   crapavs.tpdaviso = 1
                                        THEN 01/01/1099
                                        ELSE crapavs.dtdebito
               tt-lancamento_futuro.dshistor = craphis.dshistor
               tt-lancamento_futuro.nrdocmto = IF LENGTH(STRING(crapavs.nrdocmto)) < 10
                                               THEN STRING(crapavs.nrdocmto,"zzz,zzz,zz9")
                                               ELSE 
                               SUBSTR(STRING(crapavs.nrdocmto,"9999999999999999999999999")
                                            ,15,11)
               tt-lancamento_futuro.indebcre = craphis.indebcre
               tt-lancamento_futuro.vllanmto = 
                              crapavs.vllanmto - crapavs.vldebito
               tt-lancamento_futuro.cdhistor = crapavs.cdhistor               
               tt-lancamento_futuro.dstabela = "crapavs"
               tt-lancamento_futuro.genrecid = RECID(crapavs)
               tt-lancamento_futuro.dsmvtolt = 
                                    IF crapavs.tpdaviso = 1   THEN
                                       "FOLHA"
                                    ELSE
                                       STRING(crapavs.dtdebito,"99/99/9999")
                                       .
    END.  /*  Fim do FOR EACH -- Leitura dos avisos */
                              
    FOR EACH crapseg WHERE crapseg.cdcooper  = p-cdcooper              AND
                           crapseg.nrdconta  = p-nro-conta             AND
                         ((crapseg.tpseguro <> 4  AND 
                           crapseg.cdsitseg  = 1) OR
                          (crapseg.tpseguro  = 11 AND
                           crapseg.cdsitseg  = 3))                     AND
                           crapseg.indebito  = 0                       AND
                           crapseg.flgconve  = FALSE                   AND  
                     MONTH(crapseg.dtdebito) = MONTH(crapdat.dtmvtolt) AND
                      YEAR(crapseg.dtdebito) = YEAR(crapdat.dtmvtolt)  NO-LOCK:
                                 
        /* Se os periodos foram informados, filtrar por eles */
        IF   par_dtiniper <> ?   AND
             par_dtfimper <> ?   AND
            (crapseg.dtdebito < par_dtiniper   OR
             crapseg.dtdebito > par_dtfimper)  THEN
             NEXT. 

        /* Se for somente credito, desconsiderar */
        IF   par_indebcre = "C"   THEN
             NEXT.

        CREATE tt-lancamento_futuro.
        ASSIGN tt-lancamento_futuro.dtmvtolt = crapseg.dtdebito
               tt-lancamento_futuro.dsmvtolt = 
                                    STRING(crapseg.dtdebito,"99/99/9999")
               tt-lancamento_futuro.dshistor = IF crapseg.tpseguro = 1 OR
                                           crapseg.tpseguro = 11
                                          THEN "SEGURO CASA"
                                          ELSE IF crapseg.tpseguro = 2
                                                  THEN "SEGURO AUTO"
                                                  ELSE "SEGURO VIDA"
               tt-lancamento_futuro.nrdocmto = 
                            STRING(crapseg.nrctrseg,"zzz,zzz,zz9")
               tt-lancamento_futuro.indebcre = "D"
               tt-lancamento_futuro.vllanmto = crapseg.vlpreseg.

        ASSIGN aux_vllautom = aux_vllautom - crapseg.vlpreseg
               aux_vllaudeb = aux_vllaudeb + crapseg.vlpreseg.

    END.  /* FOR EACH SEGURO */

    FOR EACH craprpp WHERE craprpp.cdcooper  = p-cdcooper              AND
                           craprpp.nrdconta  = p-nro-conta             AND
                          (craprpp.cdsitrpp  = 1                       OR
                          (craprpp.cdsitrpp  = 2                       AND
                           craprpp.dtrnirpp  = craprpp.dtdebito))      AND
                     MONTH(craprpp.dtdebito) = MONTH(crapdat.dtmvtolt) AND
                      YEAR(craprpp.dtdebito) = YEAR(crapdat.dtmvtolt)  NO-LOCK:

        /* Se os periodos foram informados, filtrar por eles */
        IF   par_dtiniper <> ?   AND
             par_dtfimper <> ?   AND
            (craprpp.dtdebito < par_dtiniper   OR
             craprpp.dtdebito > par_dtfimper)  THEN
             NEXT. 

        /* Se for somente credito, desconsiderar */
        IF   par_indebcre = "C"   THEN
             NEXT.

        CREATE tt-lancamento_futuro.
        ASSIGN tt-lancamento_futuro.dtmvtolt = craprpp.dtdebito
               tt-lancamento_futuro.dsmvtolt = 
                                    STRING(craprpp.dtdebito,"99/99/9999")
               tt-lancamento_futuro.dshistor = "DB.POUP.PROGR"
               tt-lancamento_futuro.nrdocmto = 
                            STRING(craprpp.nrctrrpp,"zzz,zzz,zz9")
               tt-lancamento_futuro.indebcre = "D"
               tt-lancamento_futuro.vllanmto = craprpp.vlprerpp.

        ASSIGN aux_vllautom = aux_vllautom - craprpp.vlprerpp
               aux_vllaudeb = aux_vllaudeb + craprpp.vlprerpp.

    END. /* FOR EACH POUPANCA PROGRAMADA */


    /* Busca saldo total de emprestimos */
    RUN sistema/generico/procedures/b1wgen0002.p
        PERSISTENT SET h-b1wgen0002.

    IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
        DO:
            ASSIGN i-cod-erro = 0 
                   c-dsc-erro = "Handle invalido para BO b1wgen0002.".
            
            { sistema/generico/includes/b1wgen0001.i }

            RUN proc_gerar_log (INPUT p-cdcooper,
                                INPUT p-cod-operador,
                                INPUT c-dsc-erro,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT p-idseqttl,
                                INPUT p-nmdatela,
                                INPUT p-nro-conta,
                               OUTPUT aux_nrdrowid).
             
            RETURN "NOK".
        END.
        
    RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT p-cdcooper,
                                                 INPUT p-cod-agencia,
                                                 INPUT p-nro-caixa,
                                                 INPUT p-cod-operador,
                                                 INPUT p-nmdatela,
                                                 INPUT p-origem,
                                                 INPUT p-nro-conta,
                                                 INPUT p-idseqttl,
                                                 INPUT crapdat.dtmvtolt,
                                                 INPUT crapdat.dtmvtopr,
                                                 INPUT ?,
                                                 INPUT 0,
                                                 INPUT "B1WGEN0003",
                                                 INPUT crapdat.inproces,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /*par_flgcondc*/
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).
                                             
    DELETE PROCEDURE h-b1wgen0002.
    
    IF  RETURN-VALUE = "NOK"  THEN                                        
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
            IF  AVAILABLE tt-erro  THEN
                c-dsc-erro = tt-erro.dscritic.
            ELSE
                c-dsc-erro = "Nao foi possivel concluir a requisicao".
                
            RUN proc_gerar_log (INPUT p-cdcooper,
                                INPUT p-cod-operador,
                                INPUT c-dsc-erro,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT p-idseqttl,
                                INPUT p-nmdatela,
                                INPUT p-nro-conta,
                               OUTPUT aux_nrdrowid).                

            RETURN "NOK".
        END.                                   
             
    FOR EACH tt-dados-epr NO-LOCK:

        IF   tt-dados-epr.vlsdeved <= 0   OR 
             tt-dados-epr.flgpagto = TRUE THEN
             NEXT.

        IF   par_indebcre = "C"    THEN
             NEXT.

        IF tt-dados-epr.tpemprst = 1 OR   /* PP */
           tt-dados-epr.tpemprst = 2 THEN /* POS */
           DO:
               /* Valor da parcela vencida */
               IF tt-dados-epr.vlprvenc > 0 THEN
                  DO:
                      /* Se os periodos foram informados, filtrar por eles */
                      IF   (par_dtiniper = ?   AND
                            par_dtfimper = ?)  OR
                           (tt-dados-epr.dtdpagto >= par_dtiniper   AND
                            tt-dados-epr.dtdpagto <= par_dtfimper)  THEN
                            DO:
                                CREATE tt-lancamento_futuro.
                                ASSIGN tt-lancamento_futuro.dtmvtolt = tt-dados-epr.dtdpagto
                                       tt-lancamento_futuro.dsmvtolt = 
                                                 STRING(tt-dados-epr.dtdpagto,"99/99/9999")
                                       tt-lancamento_futuro.dshistor = "DB.EMPRESTIMO"
                                       tt-lancamento_futuro.nrdocmto = 
                                                 STRING(tt-dados-epr.nrctremp,"zzz,zzz,zz9")
                                       tt-lancamento_futuro.indebcre = "D"
                                       tt-lancamento_futuro.vllanmto = tt-dados-epr.vlprvenc.
                                    
                                ASSIGN aux_vllautom = aux_vllautom - tt-dados-epr.vlprvenc
                                       aux_vllaudeb = aux_vllaudeb + tt-dados-epr.vlprvenc.
                            END.

                  END. /* END IF tt-dados-epr.vlprvenc > 0 */

               /* Valor da parcela a vencer */ 
               IF tt-dados-epr.vlpraven > 0 THEN
                  DO:
                     ASSIGN aux_dtdpagto = DATE(MONTH(crapdat.dtmvtolt),
                                                DAY(tt-dados-epr.dtdpagto),
                                                YEAR(crapdat.dtmvtolt)).
                     
                     /* Se os periodos foram informados, filtrar por eles */
                     IF   (par_dtiniper = ?   AND
                           par_dtfimper = ?)  OR
                          (aux_dtdpagto >= par_dtiniper   AND
                           aux_dtdpagto <= par_dtfimper)  THEN
                           DO:
                               CREATE tt-lancamento_futuro.
                               ASSIGN tt-lancamento_futuro.dtmvtolt = aux_dtdpagto
                                      tt-lancamento_futuro.dsmvtolt = 
                                             STRING(aux_dtdpagto,"99/99/9999")
                                      tt-lancamento_futuro.dshistor = "DB.EMPRESTIMO"
                                      tt-lancamento_futuro.nrdocmto = 
                                             STRING(tt-dados-epr.nrctremp,"zzz,zzz,zz9")
                                      tt-lancamento_futuro.indebcre = "D"
                                      tt-lancamento_futuro.vllanmto = tt-dados-epr.vlpraven.
                                   
                               ASSIGN aux_vllautom = aux_vllautom - tt-dados-epr.vlpraven
                                      aux_vllaudeb = aux_vllaudeb + tt-dados-epr.vlpraven.
                           END.

                  END. /* END IF tt-dados-epr.vlpraven > 0 */
              
           END. /* END IF tt-dados-epr.tpemprst = 1 ou 2 */
        ELSE
           DO:
              /**  Magui quando a pessoa estava em atraso nao mostrava tudo */
              ASSIGN aux_vlpresta = 0.
       
              IF tt-dados-epr.dtdpagto <= crapdat.dtmvtolt  THEN
                 ASSIGN aux_vlpresta = tt-dados-epr.vlpreapg.
              ELSE
                 IF MONTH(tt-dados-epr.dtdpagto) = MONTH(crapdat.dtmvtolt) AND
                    YEAR(tt-dados-epr.dtdpagto)  = YEAR(crapdat.dtmvtolt)  THEN
                    DO: 
                       IF tt-dados-epr.dtdpagto > crapdat.dtmvtolt   THEN
                          DO:
                            IF tt-dados-epr.vlsdeved < tt-dados-epr.vlpreemp   AND 
                              (tt-dados-epr.qtmesdec >= tt-dados-epr.qtpreemp  OR
                               tt-dados-epr.qtprecal >= tt-dados-epr.qtmesdec) THEN
                               ASSIGN aux_vlpresta = tt-dados-epr.vlsdeved.
                            ELSE  
                               ASSIGN aux_vlpresta = tt-dados-epr.vlpreemp.
                          END.
                       ELSE     
                          ASSIGN aux_vlpresta = tt-dados-epr.vlpreapg.
                    END.
                    
              IF   aux_vlpresta <= 0   THEN
                   NEXT.

              /* Se os periodos foram informados, filtrar por eles */
              IF   par_dtiniper <> ?   AND
                   par_dtfimper <> ?   AND
                  (tt-dados-epr.dtdpagto < par_dtiniper   OR
                   tt-dados-epr.dtdpagto > par_dtfimper)  THEN
                   NEXT. 

              CREATE tt-lancamento_futuro.
              ASSIGN tt-lancamento_futuro.dtmvtolt = tt-dados-epr.dtdpagto
                     tt-lancamento_futuro.dsmvtolt = 
                                      STRING(tt-dados-epr.dtdpagto,"99/99/9999")
                     tt-lancamento_futuro.dshistor = "DB.EMPRESTIMO"
                     tt-lancamento_futuro.nrdocmto = 
                                      STRING(tt-dados-epr.nrctremp,"zzz,zzz,zz9")
                     tt-lancamento_futuro.indebcre = "D"
                     tt-lancamento_futuro.vllanmto = aux_vlpresta.
                  
              ASSIGN aux_vllautom = aux_vllautom - aux_vlpresta
                     aux_vllaudeb = aux_vllaudeb + aux_vlpresta.

           END. /* END ELSE */

        /* Vamos verificar se existe Juros de Mora para pagar */
        IF tt-dados-epr.vlmrapar > 0 THEN
           DO:
              /* Se os periodos foram informados, filtrar por eles */
              IF   (par_dtiniper = ?   AND
                    par_dtfimper = ?)  OR
                   (tt-dados-epr.dtdpagto >= par_dtiniper   AND
                    tt-dados-epr.dtdpagto <= par_dtfimper)  THEN
                    DO:
                        CREATE tt-lancamento_futuro.
                        ASSIGN tt-lancamento_futuro.dtmvtolt = tt-dados-epr.dtdpagto
                               tt-lancamento_futuro.dsmvtolt = 
                                                    STRING(tt-dados-epr.dtdpagto,"99/99/9999")
                               tt-lancamento_futuro.dshistor = "JUROS DE MORA"
                               tt-lancamento_futuro.nrdocmto = 
                                                STRING(tt-dados-epr.nrctremp,"zzz,zzz,zz9")
                               tt-lancamento_futuro.indebcre = "D"
                               tt-lancamento_futuro.vllanmto = tt-dados-epr.vlmrapar.
                      
                        ASSIGN aux_vllautom = aux_vllautom - tt-dados-epr.vlmrapar
                               aux_vllaudeb = aux_vllaudeb + tt-dados-epr.vlmrapar.
                    END.

           END. /* END IF tt-dados-epr.vlmrapar > 0 */

        /* Vamos verificar se existe Multa para pagar */
        IF tt-dados-epr.vlmtapar > 0 THEN
           DO:
               /* Se os periodos foram informados, filtrar por eles */
               IF   (par_dtiniper = ?   AND
                     par_dtfimper = ?)  OR
                    (tt-dados-epr.dtdpagto >= par_dtiniper   AND
                     tt-dados-epr.dtdpagto <= par_dtfimper)  THEN
                     DO:
                         CREATE tt-lancamento_futuro.
                         ASSIGN tt-lancamento_futuro.dtmvtolt = tt-dados-epr.dtdpagto
                                tt-lancamento_futuro.dsmvtolt = 
                                                     STRING(tt-dados-epr.dtdpagto,"99/99/9999")
                                tt-lancamento_futuro.dshistor = "MULTA"
                                tt-lancamento_futuro.nrdocmto = 
                                                 STRING(tt-dados-epr.nrctremp,"zzz,zzz,zz9")
                                tt-lancamento_futuro.indebcre = "D"
                                tt-lancamento_futuro.vllanmto = tt-dados-epr.vlmtapar.
                         
                         ASSIGN aux_vllautom = aux_vllautom - tt-dados-epr.vlmtapar
                                aux_vllaudeb = aux_vllaudeb + tt-dados-epr.vlmtapar.
                     END.

           END. /* END IF tt-dados-epr.vlmtapar > 0 */
                                   
    END.

    ASSIGN aux_resulta1 = 0
           aux_resulta2 = 0
           aux_resulta3 = 0
           aux_resulta4 = 0.

    ASSIGN aux_contadct = 0.

    FIND crapsld WHERE crapsld.nrdconta = p-nro-conta AND
                       crapsld.cdcooper = p-cdcooper  NO-LOCK NO-ERROR.

    IF   AVAILABLE crapsld AND 
         (crapdat.dtmvtolt >= par_dtiniper       AND 
          crapdat.dtmvtolt <= par_dtfimper)  OR 
         (par_dtiniper = ?                       AND
          par_dtfimper = ?) THEN
         DO:
             IF   crapsld.vlsmnmes <> 0 THEN
                  DO:
                      IF (par_indebcre = "D" OR par_indebcre = "") THEN
                          DO:
                              ASSIGN aux_resulta1 =
                                 (crapsld.vlsmnmes * aux_txjurneg) * -1
                                   
                                     aux_contadct =  aux_contadct + 1.
                          
                              CREATE tt-lancamento_futuro.
                              ASSIGN tt-lancamento_futuro.dtmvtolt = crapdat.dtmvtolt
                                     tt-lancamento_futuro.dsmvtolt =
                                        STRING(crapdat.dtmvtolt,"99/99/9999")
                                     tt-lancamento_futuro.dshistor = 
                                                  "PRV. TAXA C/C NEG."
                                     tt-lancamento_futuro.nrdocmto =
                                                    STRING(aux_contadct,"zzzzzzz,zz9")
                                     tt-lancamento_futuro.indebcre = "D"
                                     tt-lancamento_futuro.vllanmto = aux_resulta1 .
                          END.
                  END.
     
             IF   crapsld.vlsmnesp <> 0 OR 
                 (MONTH(crapdat.dtmvtolt) <> MONTH(crapdat.dtmvtoan) AND 
                  crapsld.vljuresp <> 0) THEN 
                  DO:
                      FIND LAST craplim WHERE 
                                craplim.cdcooper = p-cdcooper        AND
                                craplim.nrdconta = crapsld.nrdconta  AND
                                craplim.tpctrlim = 1                 AND
                                craplim.insitlim = 2 
                                USE-INDEX craplim2 NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE craplim THEN
                           DO:
                               FIND LAST craplim WHERE 
                                         craplim.cdcooper = p-cdcooper       AND
                                         craplim.nrdconta = crapsld.nrdconta AND
                                         craplim.tpctrlim = 1                AND
                                         craplim.insitlim = 3 
                                         USE-INDEX craplim2 NO-LOCK NO-ERROR.
                                        
                               IF   NOT AVAILABLE craplim THEN
                                    DO:
                                       ASSIGN i-cod-erro = 105
                                              c-dsc-erro = "".
           
                             {sistema/generico/includes/b1wgen0001.i}
                             
                                       RUN proc_gerar_log (INPUT p-cdcooper,
                                                           INPUT p-cod-operador,
                                                           INPUT "",
                                                           INPUT aux_dsorigem,
                                                           INPUT aux_dstransa,
                                                           INPUT FALSE,
                                                           INPUT p-idseqttl,
                                                           INPUT p-nmdatela,
                                                           INPUT p-nro-conta,
                                                          OUTPUT aux_nrdrowid).

                                       RETURN "NOK".
                                    END.

                           END.

                      FIND craplrt WHERE craplrt.cdcooper = p-cdcooper       AND
                                         craplrt.cddlinha = craplim.cddlinha  
                                         NO-LOCK NO-ERROR.
                       
                      IF   NOT AVAILABLE craplrt THEN
                           DO:
                               ASSIGN i-cod-erro = 363
                                      c-dsc-erro = " ".
           
                              {sistema/generico/includes/b1wgen0001.i}

                               RUN proc_gerar_log (INPUT p-cdcooper,
                                                   INPUT p-cod-operador,
                                                   INPUT "",
                                                   INPUT aux_dsorigem,
                                                   INPUT aux_dstransa,
                                                   INPUT FALSE,
                                                   INPUT p-idseqttl,
                                                   INPUT p-nmdatela,
                                                   INPUT p-nro-conta,
                                                  OUTPUT aux_nrdrowid).
                               
                               RETURN "NOK".
                           END.
                      
                      IF   (par_indebcre = "D" OR par_indebcre = "") THEN
                           DO: 
                               ASSIGN aux_contadct =  aux_contadct + 1.

                               IF MONTH(crapdat.dtmvtolt) <> MONTH(crapdat.dtmvtoan) THEN /* Primeiro Útil */
                                 ASSIGN aux_resulta2 = crapsld.vljuresp.
                               ELSE
                                 ASSIGN aux_resulta2 = (crapsld.vlsmnesp * (craplrt.txmensal / 100)) * -1.

                               CREATE tt-lancamento_futuro.
                               ASSIGN tt-lancamento_futuro.dtmvtolt = crapdat.dtmvtolt
                                      tt-lancamento_futuro.dsmvtolt =
                                         STRING(crapdat.dtmvtolt,"99/99/9999")
                                      tt-lancamento_futuro.dshistor = 
                                                   "PRV. JUROS CH.ESP."
                                      tt-lancamento_futuro.nrdocmto =
                                                     STRING(aux_contadct,"zzzzzzz,zz9")
                                      tt-lancamento_futuro.indebcre = "D"
                                      tt-lancamento_futuro.vllanmto = aux_resulta2.
                           END.
                  END.
     
             IF   crapsld.vlsmnblq <> 0                      AND 
                 (par_indebcre = "D" OR par_indebcre = "")   THEN 
                  DO:
                      ASSIGN aux_resulta3 = (crapsld.vlsmnblq * aux_txjursaq) * -1
                             aux_contadct =  aux_contadct + 1.
           
                      CREATE tt-lancamento_futuro.
                      ASSIGN tt-lancamento_futuro.dtmvtolt = crapdat.dtmvtolt
                             tt-lancamento_futuro.dsmvtolt =
                                STRING(crapdat.dtmvtolt,"99/99/9999")
                             tt-lancamento_futuro.dshistor = 
                                          "PRV. JR.SAQ.DEP.BL"
                             tt-lancamento_futuro.nrdocmto = 
                                            STRING(aux_contadct,"zzzzzzz,zz9")
                             tt-lancamento_futuro.indebcre = "D"
                             tt-lancamento_futuro.vllanmto = aux_resulta3.
                  END.

             /* caso exista valor iof sera criado registro para debito */
             RUN sistema/generico/procedures/b1wgen0159.p
                           PERSISTENT SET h-b1wgen0159.

             RUN verifica-imunidade-tributaria IN h-b1wgen0159(
                                  INPUT p-cdcooper,
                                  INPUT p-nro-conta,
                                  INPUT crapdat.dtmvtolt,
                                  INPUT FALSE,
                                  INPUT 0,
                                  INPUT 0,
                                 OUTPUT aux_flgimune,
                                 OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h-b1wgen0159.

             IF   NOT aux_flgimune AND crapsld.vliofmes > 0   AND 
                  (par_indebcre = "D" OR par_indebcre = "")   THEN
                  DO:
                      ASSIGN aux_resulta4 = crapsld.vliofmes
                             aux_contadct =  aux_contadct + 1.
           
                      CREATE tt-lancamento_futuro.
                      ASSIGN tt-lancamento_futuro.dtmvtolt = crapdat.dtmvtolt
                             tt-lancamento_futuro.dsmvtolt =
                                STRING(crapdat.dtmvtolt,"99/99/9999")
                             tt-lancamento_futuro.dshistor = 
                                          "PRV. IOF S/EMPR.CC"
                             tt-lancamento_futuro.nrdocmto = 
                                            STRING(aux_contadct,"zzzzzzz,zz9")
                             tt-lancamento_futuro.indebcre = "D"
                             tt-lancamento_futuro.vllanmto = aux_resulta4.
                  END.

         END.

    ASSIGN aux_vllautom = aux_vllautom - (aux_resulta1 + aux_resulta2 +
                          aux_resulta3 + aux_resulta4)
           aux_vllaudeb = aux_vllaudeb + (aux_resulta1 + aux_resulta2 +
                          aux_resulta3 + aux_resulta4).                    
    
    FOR EACH crappla WHERE crappla.cdcooper = p-cdcooper  AND
                           crappla.nrdconta = p-nro-conta AND
                           crappla.tpdplano = 1           AND
                           crappla.cdsitpla = 1           AND
                           crappla.indpagto = 0       NO-LOCK:

        /* Se for somente creditos, desconsiderar */
        IF   par_indebcre = "C"   THEN
             NEXT.

        IF crappla.flgpagto THEN /* debito em folha */
        DO:
            IF   crappla.vlpenden > 0                   AND 
                ((crapdat.dtmvtolt >= par_dtiniper       AND 
                  crapdat.dtmvtolt <= par_dtfimper)  OR 
                (par_dtiniper = ?                       AND
                 par_dtfimper = ?))                      THEN
                 DO:
                     CREATE tt-lancamento_futuro.
                     ASSIGN tt-lancamento_futuro.dtmvtolt = crapdat.dtmvtolt
                            tt-lancamento_futuro.dsmvtolt = 
                                             STRING(crapdat.dtmvtolt,"99/99/9999")
                            tt-lancamento_futuro.dshistor = "DB.COTAS PENDENTE"
                            tt-lancamento_futuro.nrdocmto = 
                                             STRING(crappla.nrctrpla,"zzz,zzz,zz9")
                            tt-lancamento_futuro.indebcre = "D"
                            tt-lancamento_futuro.vllanmto = crappla.vlpenden.
                 
                     ASSIGN aux_vllautom = aux_vllautom - crappla.vlpenden
                            aux_vllaudeb = aux_vllaudeb + crappla.vlpenden.
                 END.
            ELSE
                /* O Valor da parcela mensal do plano ja esta sendo contabilizada
                   na leitura da tabela crapavs(tpdaviso = 1) */
                NEXT.
        END.
        ELSE /* debito em conta */
        DO:
            IF crappla.vlpenden > 0 THEN
            DO:
                /* No dia do debito da parcela do plano nao mostra valor
                   pendente */ 
                IF   crappla.dtdpagto <> crapdat.dtmvtolt   AND
                    ((crapdat.dtmvtolt >= par_dtiniper      AND 
                      crapdat.dtmvtolt <= par_dtfimper)     OR 
                     (par_dtiniper = ?                      AND
                      par_dtfimper = ?) )                   THEN
                     DO:
                         CREATE tt-lancamento_futuro.
                         ASSIGN tt-lancamento_futuro.dtmvtolt = crapdat.dtmvtolt
                                tt-lancamento_futuro.dsmvtolt = 
                                                 STRING(crapdat.dtmvtolt,"99/99/9999")
                                tt-lancamento_futuro.dshistor = "DB.COTAS PENDENTE"
                                tt-lancamento_futuro.nrdocmto = 
                                                 STRING(crappla.nrctrpla,"zzz,zzz,zz9")
                                tt-lancamento_futuro.indebcre = "D"
                                tt-lancamento_futuro.vllanmto = crappla.vlpenden.
                    
                         ASSIGN aux_vllautom = aux_vllautom - crappla.vlpenden
                                aux_vllaudeb = aux_vllaudeb + crappla.vlpenden.
                     END.
            END.

            IF MONTH(crappla.dtdpagto) = MONTH(crapdat.dtmvtolt)  AND
                YEAR(crappla.dtdpagto) =  YEAR(crapdat.dtmvtolt) THEN
            DO:
                IF  (crappla.dtdpagto >= par_dtiniper       AND 
                     crappla.dtdpagto <= par_dtfimper)  OR 
                    (par_dtiniper = ?                       AND
                     par_dtfimper = ?)                      THEN
                     DO:
                         CREATE tt-lancamento_futuro.
                         ASSIGN tt-lancamento_futuro.dtmvtolt = crappla.dtdpagto
                                tt-lancamento_futuro.dsmvtolt = 
                                                 STRING(crappla.dtdpagto,"99/99/9999")
                                tt-lancamento_futuro.dshistor = "DB.COTAS     "
                                tt-lancamento_futuro.nrdocmto = 
                                                 STRING(crappla.nrctrpla,"zzz,zzz,zz9")
                                tt-lancamento_futuro.indebcre = "D"
                                tt-lancamento_futuro.vllanmto = crappla.vlprepla.
                         
                         ASSIGN aux_vllautom = aux_vllautom - crappla.vlprepla
                                aux_vllaudeb = aux_vllaudeb + crappla.vlprepla.
                     END.
            END.
        END.
    END.

    /*FATURAS DE CARTAO DE CREDITO SICOOB*/
    FOR EACH tbcrd_fatura
       WHERE tbcrd_fatura.cdcooper = p-cdcooper
         AND tbcrd_fatura.nrdconta = p-nro-conta
         AND tbcrd_fatura.insituacao = 1
         AND tbcrd_fatura.vlpendente > 0
         AND ((tbcrd_fatura.dtvencimento >= par_dtiniper
         AND   tbcrd_fatura.dtvencimento <= par_dtfimper) OR
               par_dtiniper = ? AND par_dtfimper = ?) NO-LOCK:
        

        FIND craphis WHERE craphis.cdcooper = p-cdcooper
                       AND craphis.cdhistor = 1545
                       NO-LOCK NO-ERROR.

        IF  NOT AVAIL(craphis) THEN
            DO:
                ASSIGN i-cod-erro = 80 
                       c-dsc-erro = " ".
    
                {sistema/generico/includes/b1wgen0001.i}
    
                RUN proc_gerar_log (INPUT p-cdcooper,
                                    INPUT p-cod-operador,
                                    INPUT "",
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT p-idseqttl,
                                    INPUT p-nmdatela,
                                    INPUT p-nro-conta,
                                   OUTPUT aux_nrdrowid).
    
                RETURN "NOK".
            END.
                                     

        IF  fn_dia_util_posterior(INPUT  crapdat.cdcooper,
                                  INPUT  tbcrd_fatura.dtvencimento,
                                  INPUT  1) > crapdat.dtmvtolt THEN
            DO:
                aux_dtfatura = tbcrd_fatura.dtvencimento.
            END.
        ELSE
            DO:         
                IF  fn_dia_util_posterior(INPUT  crapdat.cdcooper,
                                          INPUT  tbcrd_fatura.dtvencimento,
                                          INPUT  1) = crapdat.dtmvtolt THEN
                    DO:
                        aux_dtfatura = fn_dia_util_posterior(INPUT  crapdat.cdcooper,
                                                             INPUT  crapdat.dtmvtolt,
                                                             INPUT  1).
                    END.
                ELSE
                    DO:
                        aux_dtfatura = crapdat.dtmvtolt.
                    END.
            END.
                            
        CREATE tt-lancamento_futuro.
        ASSIGN tt-lancamento_futuro.dstabela = "tbcrd_fatura"
               tt-lancamento_futuro.cdhistor = 1545
               tt-lancamento_futuro.dtmvtolt = aux_dtfatura
               tt-lancamento_futuro.dshistor = craphis.dshistor
               tt-lancamento_futuro.nrdocmto = tbcrd_fatura.dsdocumento
               tt-lancamento_futuro.indebcre = craphis.indebcre
               tt-lancamento_futuro.vllanmto = tbcrd_fatura.vlpendente
               tt-lancamento_futuro.genrecid = RECID(tbcrd_fatura)
               tt-lancamento_futuro.dsmvtolt = STRING(aux_dtfatura,"99/99/9999").

        ASSIGN aux_vllautom = aux_vllautom - tbcrd_fatura.vlpendente
               aux_vllaudeb = aux_vllaudeb + tbcrd_fatura.vlpendente.
    END.
    /*FIM FATURAS CARTAO CREDITO SICOOB*/


    /*  Subscricao de capital do mes  */
    FOR EACH crapsdc WHERE crapsdc.cdcooper = p-cdcooper    AND
                           crapsdc.nrdconta = p-nro-conta   AND
                           crapsdc.indebito = 0             AND
                           crapsdc.dtrefere <= aux_dtultdia 
                           NO-LOCK:

        /* Se for somente credito, desconsiderar */
        IF   par_indebcre = "C"   THEN
             NEXT.

        /* Se os periodos foram informados, filtrar por eles */
        IF   par_dtiniper <> ?   AND
             par_dtfimper <> ?   AND
            (crapsdc.dtrefere < par_dtiniper   OR
             crapsdc.dtrefere > par_dtfimper)  THEN
             NEXT. 

        CREATE tt-lancamento_futuro.
        ASSIGN tt-lancamento_futuro.dtmvtolt = crapsdc.dtrefere
               tt-lancamento_futuro.dsmvtolt =
                  STRING(crapsdc.dtrefere,"99/99/9999")
               tt-lancamento_futuro.dshistor = IF crapsdc.tplanmto = 1
                                          THEN "CAPITAL INICIAL"
                                          ELSE "PLANO CAPITAL INICIAL"
               tt-lancamento_futuro.nrdocmto = 
                            STRING(crapsdc.nrseqdig,"zzz,zzz,zz9")
               tt-lancamento_futuro.indebcre = "D"
               tt-lancamento_futuro.vllanmto = crapsdc.vllanmto.
    
        ASSIGN aux_vllautom = aux_vllautom - crapsdc.vllanmto
               aux_vllaudeb = aux_vllaudeb + crapsdc.vllanmto.
                       
    END.  /*  Fim do FOR EACH -- crapsdc  */ 

    FIND crapass WHERE crapass.cdcooper = p-cdcooper  AND
                       crapass.nrdconta = p-nro-conta NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass  THEN
        DO:
            ASSIGN i-cod-erro = 9
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }
         
            RUN proc_gerar_log (INPUT p-cdcooper,
                                INPUT p-cod-operador,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT p-idseqttl,
                                INPUT p-nmdatela,
                                INPUT p-nro-conta,
                               OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END. 
    
    /* Obtem históricos de tarifas */
    IF  crapass.inpessoa = 1 THEN
        ASSIGN aux_cdbattaa = "TROUTTAAPF"  /* Pessoa Física via TAA      */
               aux_cdbatint = "TROUTINTPF". /* Pessoa Física via Internet */
    ELSE
        ASSIGN aux_cdbattaa = "TROUTTAAPJ"  /* Pessoa Jurídica via TAA      */
               aux_cdbatint = "TROUTINTPJ". /* Pessoa Jurídica via Internet */

    IF  NOT VALID-HANDLE(h-b1wgen0153)  THEN
        RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT 
            SET h-b1wgen0153.
                                                    
    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                   (INPUT p-cdcooper,
                                    INPUT aux_cdbattaa,
                                    INPUT 1, 
                                    INPUT "", /* cdprogra */
                                   OUTPUT aux_cdhistaa,
                                   OUTPUT aux_cdhsetaa,
                                   OUTPUT aux_vltarpro,
                                   OUTPUT aux_dtdivulg,
                                   OUTPUT aux_dtvigenc,
                                   OUTPUT aux_cdfvlcop,
                                   OUTPUT TABLE tt-erro).

    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                   (INPUT p-cdcooper,
                                    INPUT aux_cdbatint,
                                    INPUT 1, 
                                    INPUT "", /* cdprogra */ 
                                   OUTPUT aux_cdhisint,
                                   OUTPUT aux_cdhseint,
                                   OUTPUT aux_vltarpro,
                                   OUTPUT aux_dtdivulg,
                                   OUTPUT aux_dtvigenc,
                                   OUTPUT aux_cdfvlcop,
                                   OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0153) THEN
        DELETE OBJECT h-b1wgen0153.   
   
    /** Busca os historicos da tabela 'de-para' da Cabal */
    ASSIGN aux_cdhishcb = "".
    FOR EACH craphcb FIELDS(cdhistor) NO-LOCK:
        ASSIGN aux_cdhishcb = aux_cdhishcb + "," + STRING(craphcb.cdhistor).
    END.

    /* Verifica lancamentos com historicos de internet para
       contabilizar no valor de lancamentos futuros */
    FOR EACH craplcm WHERE craplcm.cdcooper = p-cdcooper   AND
                           craplcm.nrdconta = p-nro-conta  AND
                           craplcm.dtmvtolt > aux_datdodia NO-LOCK:
        
        IF  p-cdcooper <> 3                  AND
           (p-cod-agencia = 90  /*Internet*/ OR
            p-cod-agencia = 91) /** TAA **/  AND
            craplcm.dtmvtolt > aux_dtddlslf  THEN
            NEXT.

        /* Adicionado o tratamento para ignorar os lançamentos futuros do histórico 15
           e da busca dos historicos da tabela 'de-para' da Cabal */
        IF  CAN-DO("15,316,450,767,918,920,1706,1706,1715,1718,1721,1706,1709,1712,1706," +
                   "1706,1715,1719,1722,1710,1713" + STRING(aux_cdhishcb) ,STRING(craplcm.cdhistor)) OR
           (CAN-DO("375,376,377,537,538,539,771,772,14,44",STRING(craplcm.cdhistor)) AND
            SUBSTR(craplcm.cdpesqbb,54,8) = "") OR
           (CAN-DO("1009,1011," + STRING(aux_cdhistaa) + "," + STRING(aux_cdhisint),
                   STRING(craplcm.cdhistor)) AND
            SUBSTR(craplcm.cdpesqbb,15,8) = "") OR
            /* Verificar o histórico 530 e se foi realizado ONLINE */
            (craplcm.cdhistor = 530 AND craplcm.cdpesqbb = "ONLINE") THEN
            NEXT.
            
        FIND craphis WHERE craphis.cdcooper = p-cdcooper   AND
                           craphis.cdhistor = craplcm.cdhistor  
                           NO-LOCK NO-ERROR.
                
        IF   NOT AVAILABLE craphis   THEN
             DO:
                 ASSIGN i-cod-erro = 80 
                        c-dsc-erro = " ".
             
                {sistema/generico/includes/b1wgen0001.i}
      
                RUN proc_gerar_log (INPUT p-cdcooper,
                                    INPUT p-cod-operador,
                                    INPUT "",
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT p-idseqttl,
                                    INPUT p-nmdatela,
                                    INPUT p-nro-conta,
                                   OUTPUT aux_nrdrowid).

                RETURN "NOK".
             END.
                      
        /* Se foi informado credito ou debito, filtrar */
        IF   par_indebcre <> ""   AND
             craphis.indebcre <> par_indebcre   THEN
             NEXT.
            
        /* Se os periodos foram informados, filtrar por eles */ 
        IF   par_dtiniper <> ?   AND                            
             par_dtfimper <> ?   AND                            
            (craplcm.dtmvtolt < par_dtiniper   OR               
             craplcm.dtmvtolt > par_dtfimper)  THEN             
             NEXT.                                              

        CREATE tt-lancamento_futuro.
        ASSIGN tt-lancamento_futuro.dtmvtolt = craplcm.dtmvtolt
               tt-lancamento_futuro.dsmvtolt =
                  STRING(craplcm.dtmvtolt,"99/99/9999")
               tt-lancamento_futuro.indebcre = craphis.indebcre
               tt-lancamento_futuro.vllanmto = craplcm.vllanmto.
                        
        IF   craphis.cdhistor = 508   THEN  /* Pagtos INTERNET */
             tt-lancamento_futuro.dshistor = craphis.dshistor + 
                                             " - "  + craplcm.dscedent.
        ELSE
             tt-lancamento_futuro.dshistor = 
                        IF  CAN-DO("24,27,47,78,156,191,~338,351,399,573,657",
                            STRING(craplcm.cdhistor))  THEN
                            craphis.dshistor + craplcm.cdpesqbb
                        ELSE 
                            craphis.dshistor.

        /* Para saque e saque compartilhado  pega o numero do documento e a hora*/
        IF  craplcm.cdhistor = 316 OR craplcm.cdhistor = 918 THEN
            tt-lancamento_futuro.nrdocmto = STRING(craplcm.nrdocmto,"zzzz9") 
                                            + " " +
                                            STRING(INTE(craplcm.nrdocmto),
                                                   "HH:MM").
        ELSE
        IF  CAN-DO("375,376,377,537,538,539,771,772",
                   STRING(craplcm.cdhistor))  THEN
            tt-lancamento_futuro.nrdocmto = STRING(INTE(SUBSTR(craplcm.cdpesqbb,
                                                   45,8)),"zzzzz,zzz,9").
        ELSE
        IF  CAN-DO("104,302,303",STRING(craplcm.cdhistor))  THEN
            IF  INTE(craplcm.cdpesqbb) > 0  THEN
                tt-lancamento_futuro.nrdocmto = STRING(INTE(craplcm.cdpesqbb),
                                                       "zzzzz,zzz,9").
            ELSE
                tt-lancamento_futuro.nrdocmto = STRING(craplcm.nrdocmto,
                                                       "zzz,zzz,zz9").   
        ELSE     
        IF  craplcm.cdhistor = 418  THEN
            tt-lancamento_futuro.nrdocmto = "    " +
                                            STRING(SUBSTR(craplcm.cdpesqbb,
                                                          60,07)).
        ELSE
        IF  CAN-DO("567,568,569,773,774",STRING(craplcm.cdhistor))  THEN
            tt-lancamento_futuro.nrdocmto = STRING(INTE(SUBSTR(craplcm.cdpesqbb,
                                              50,8)),"zzzzz,zzz,9").
        ELSE
        IF  CAN-DO("1009,1011,1163,1167," + 
                   STRING(aux_cdhistaa) + "," + STRING(aux_cdhsetaa) + "," +
                   STRING(aux_cdhisint) + "," + STRING(aux_cdhseint),
                   STRING(craplcm.cdhistor))  THEN
            tt-lancamento_futuro.nrdocmto = STRING(craplcm.nrdctabb,
                                           "zzzzz,zzz,9").
        ELSE
            tt-lancamento_futuro.nrdocmto = IF  craplcm.cdhistor = 100  THEN
                                                IF  craplcm.cdpesqbb <> ""  THEN
                                                    craplcm.cdpesqbb
                                                ELSE 
                                                    STRING(craplcm.nrdocmto,
                                                           "zzzzzzz,zz9")
                                            ELSE 
                                            IF  CAN-DO(aux_lshistor,
                                                STRING(craplcm.cdhistor))  THEN 
                                                STRING(craplcm.nrdocmto,
                                                       "zzzzz,zz9,9")
                                            ELSE 
                                            IF  LENGTH(STRING(craplcm.nrdocmto))
                                                < 10  THEN
                                                STRING(craplcm.nrdocmto,
                                                       "zzzzzzz,zz9")
                                            ELSE
                                                SUBSTR(STRING(craplcm.nrdocmto,
                                                 "99999999999999999999"),10,11).
                                        
        IF   CAN-DO("1,2,3,4,5",STRING(craphis.inhistor))   THEN
             ASSIGN aux_vllautom = aux_vllautom + craplcm.vllanmto
                    aux_vllaucre = aux_vllaucre + craplcm.vllanmto.
        ELSE
        IF   CAN-DO("11,12,13,14,15",STRING(craphis.inhistor))  THEN
             ASSIGN aux_vllautom = aux_vllautom - craplcm.vllanmto
                    aux_vllaudeb = aux_vllaudeb + craplcm.vllanmto.
        ELSE
             DO:
                ASSIGN i-cod-erro = 83 
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}
                
                RUN proc_gerar_log (INPUT p-cdcooper,
                                    INPUT p-cod-operador,
                                    INPUT "",
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT p-idseqttl,
                                    INPUT p-nmdatela,
                                    INPUT p-nro-conta,
                                   OUTPUT aux_nrdrowid).

                RETURN "NOK".
             END.

    END. /*Fim do for CRAPLCM*/

    /* busca lancamentos de tarifas agendados e pendentes para listar */
    FOR EACH craplat WHERE craplat.cdcooper = p-cdcooper  AND
                           craplat.nrdconta = p-nro-conta AND
                           craplat.insitlat = 1 /* Pendente */ 
                           NO-LOCK:

        FIND craphis WHERE craphis.cdcooper = p-cdcooper       AND
                           craphis.cdhistor = craplat.cdhistor NO-LOCK NO-ERROR.
                
        IF  NOT AVAILABLE craphis THEN
            DO:
                ASSIGN i-cod-erro = 80 
                       c-dsc-erro = " ".
            
               {sistema/generico/includes/b1wgen0001.i}
      
               RUN proc_gerar_log (INPUT p-cdcooper,
                                   INPUT p-cod-operador,
                                   INPUT "",
                                   INPUT aux_dsorigem,
                                   INPUT aux_dstransa,
                                   INPUT FALSE,
                                   INPUT p-idseqttl,
                                   INPUT p-nmdatela,
                                   INPUT p-nro-conta,
                                  OUTPUT aux_nrdrowid).

               RETURN "NOK".
            END.

        IF ((craphis.indebcre = par_indebcre OR par_indebcre = "") AND
           ((craplat.dtmvtolt >= par_dtiniper AND craplat.dtmvtolt <= par_dtfimper) OR
         	 par_dtiniper = ? AND par_dtfimper = ?)) THEN
          	 DO:
                 CREATE tt-lancamento_futuro.
                 ASSIGN tt-lancamento_futuro.dtmvtolt = craplat.dtmvtolt
                        tt-lancamento_futuro.dsmvtolt = 
                                             STRING(craplat.dtmvtolt,"99/99/9999")
                        tt-lancamento_futuro.dshistor = craphis.dshistor
                        tt-lancamento_futuro.nrdocmto = IF craplat.nrdocmto > 0 THEN
                                                           STRING(craplat.nrdocmto,
                                                                  "zzz,zzz,zz9")
                                                        ELSE
                                                           STRING(craplat.idseqlat,
                                                                  "zzz,zzz,zz9")                                                                                                                 
                        tt-lancamento_futuro.indebcre = craphis.indebcre
                        tt-lancamento_futuro.vllanmto = craplat.vltarifa.

                 ASSIGN aux_vllautom = aux_vllautom - craplat.vltarifa
                        aux_vllaudeb = aux_vllaudeb + craplat.vltarifa.
             END.
        
    END. /* Fim do for CRAPLAT */
        
    /* Renato(Supero) - 12/08/2014 - Buscar maior float de cobrança 085 */
   
    aux_qtdfloat = 0.   
	 
    FOR EACH crapcco WHERE crapcco.cdcooper = p-cdcooper
		               AND crapcco.cddbanco = 085 NO-LOCK
       ,EACH crapceb WHERE crapceb.cdcooper = crapcco.cdcooper
		               AND crapceb.nrdconta = p-nro-conta 
                      AND crapceb.nrconven = crapcco.nrconven NO-LOCK
                       BY crapceb.qtdfloat DESC:
		  
        aux_qtdfloat = crapceb.qtdfloat.
        LEAVE.
    END.
   
    /* Buscar o ultimo dia útil baseado na quantidade de dias de Float */
    aux_dtrefere = fn_dia_util_anterior(p-cdcooper, crapdat.dtmvtolt, aux_qtdfloat).
   
   /* buscar os títulos pagos com data de crédito já gravada */
   FOR EACH crapcco WHERE crapcco.cdcooper = p-cdcooper
		              AND crapcco.cddbanco = 085 NO-LOCK
      ,EACH crapceb WHERE crapceb.cdcooper = crapcco.cdcooper
		              AND crapceb.nrdconta = p-nro-conta
		              AND crapceb.nrconven = crapcco.nrconven NO-LOCK
      ,EACH crapret WHERE crapret.cdcooper = crapceb.cdcooper
		              AND crapret.nrdconta = crapceb.nrdconta
		              AND crapret.nrcnvcob = crapceb.nrconven
		              AND crapret.dtocorre >= aux_dtrefere
		              AND crapret.dtcredit >= crapdat.dtmvtolt
		              AND crapret.flcredit = 0  /* FALSE */
		              AND (crapret.cdocorre = 6   OR
                           crapret.cdocorre = 17)
		              AND crapret.vlrpagto > 0  NO-LOCK 
		            BREAK BY crapcco.nrconven
		                  BY crapceb.qtdfloat
				          BY crapret.dtcredit:
				
	   IF  FIRST-OF(crapret.dtcredit) THEN DO:
           ASSIGN aux_vldpagto = 0
                  aux_qtdpagto = 0.
	   END.
	                                              
       /* Se os periodos foram informados, filtrar por eles */   
       IF   (par_dtiniper = ?                   AND                              
             par_dtfimper = ?)  OR                               
            (crapret.dtcredit >= par_dtiniper   AND                 
             crapret.dtcredit <= par_dtfimper)  AND 
             NOT par_indebcre = "D" THEN               
             DO:
                  ASSIGN aux_vldpagto = aux_vldpagto + crapret.vlrpagto
                         aux_qtdpagto = aux_qtdpagto + 1.
             END.
               	
       IF   LAST-OF(crapret.dtcredit) THEN 
            DO:
                /* Se os periodos foram informados, filtrar por eles */  
                IF   (par_dtiniper = ?                   AND             
                      par_dtfimper = ?)  OR                              
                     (crapret.dtcredit >= par_dtiniper   AND             
                      crapret.dtcredit <= par_dtfimper)  AND             
                      NOT par_indebcre = "D" THEN                        
                      DO:                                                
                          CREATE tt-lancamento_futuro.
                          ASSIGN tt-lancamento_futuro.dtmvtolt = crapret.dtcredit
                                 tt-lancamento_futuro.dsmvtolt = STRING(crapret.dtcredit,"99/99/9999")
                                 tt-lancamento_futuro.dshistor = "CRED.COBRANCA - " + TRIM(STRING(crapcco.nrconven, "z,zzz,zz9"))
                                 tt-lancamento_futuro.nrdocmto = TRIM(STRING(aux_qtdpagto,"z,zzz,zz9"))
                                 tt-lancamento_futuro.indebcre = "C"
                                 tt-lancamento_futuro.vllanmto = aux_vldpagto.		  
    		             
                          ASSIGN aux_vllautom = aux_vllautom + aux_vldpagto
                                 aux_vllaucre = aux_vllaucre + aux_vldpagto.
                      END.
            END.
					
   END.

   /* busca lancamentos de tarifas agendados e pendentes para listar */
   FOR EACH craptdb WHERE craptdb.cdcooper = p-cdcooper       AND
                          craptdb.nrdconta = p-nro-conta      AND
                          craptdb.insittit = 4                AND 
                          craptdb.dtvencto < crapdat.dtmvtolt AND 
                          craptdb.dtdpagto = ?                NO-LOCK:

       IF  (craptdb.dtvencto >= par_dtiniper AND craptdb.dtvencto <= par_dtfimper) OR
           (par_dtiniper = ? AND par_dtfimper = ?) THEN
            DO:

                FIND craphis WHERE craphis.cdcooper = p-cdcooper       AND
                                   craphis.cdhistor = 591 /*DEB.TIT.VENC*/ NO-LOCK NO-ERROR.
    
                IF  NOT AVAILABLE craphis THEN
                    DO:
                        ASSIGN i-cod-erro = 80 
                               c-dsc-erro = " ".
    
                       {sistema/generico/includes/b1wgen0001.i}
    
                       RUN proc_gerar_log (INPUT p-cdcooper,
                                           INPUT p-cod-operador,
                                           INPUT "",
                                           INPUT aux_dsorigem,
                                           INPUT aux_dstransa,
                                           INPUT FALSE,
                                           INPUT p-idseqttl,
                                           INPUT p-nmdatela,
                                           INPUT p-nro-conta,
                                          OUTPUT aux_nrdrowid).
    
                       RETURN "NOK".
            END.
					
                FIND crapcob WHERE crapcob.cdcooper = craptdb.cdcooper
                               AND crapcob.cdbandoc = craptdb.cdbandoc
                               AND crapcob.nrdctabb = craptdb.nrdctabb
                               AND crapcob.nrcnvcob = craptdb.nrcnvcob
                               AND crapcob.nrdconta = craptdb.nrdconta
                               AND crapcob.nrdocmto = craptdb.nrdocmto
                               NO-LOCK NO-ERROR.

                CREATE tt-lancamento_futuro.
                ASSIGN tt-lancamento_futuro.dtmvtolt = craptdb.dtvencto
                       tt-lancamento_futuro.dsmvtolt = 
                                            STRING(craptdb.dtvencto,"99/99/9999")
                       tt-lancamento_futuro.dshistor = craphis.dshistor
                       tt-lancamento_futuro.nrdocmto = STRING( DECIMAL( SUBSTR( crapcob.nrnosnum , LENGTH(crapcob.nrnosnum) - 8, 9 ) ),  "zzz,zzz,zz9.999")
                       tt-lancamento_futuro.indebcre = craphis.indebcre
                       tt-lancamento_futuro.vllanmto = craptdb.vltitulo.

                ASSIGN aux_vllautom = aux_vllautom - craptdb.vltitulo
                       aux_vllaudeb = aux_vllaudeb + craptdb.vltitulo.
   END.

   END. /* Fim do for CRAPLAT */

    aux_vllandeb = aux_vllandeb - aux_vllautom.
    
    IF   aux_vllandeb > 0 THEN
         aux_vllautom = aux_vllautom - (TRUNC(aux_vllandeb * tab_txcpmfcc,2)).
     
    IF   aux_vllautom < 0 THEN
         aux_vllautom = TRUNC(aux_vllautom * (1 + tab_txcpmfcc),2).
    ELSE
         aux_vllautom = TRUNC(aux_vllautom * tab_txrdcpmf,2).

    CREATE tt-totais-futuros.
    ASSIGN tt-totais-futuros.vllautom = aux_vllautom
           tt-totais-futuros.vllaudeb = aux_vllaudeb
           tt-totais-futuros.vllaucre = aux_vllaucre.

    IF   p-flgerlog   THEN
         RUN proc_gerar_log (INPUT p-cdcooper,
                             INPUT p-cod-operador,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT p-idseqttl,
                             INPUT p-nmdatela,
                             INPUT p-nro-conta,
                            OUTPUT aux_nrdrowid).
                                   
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**           Procedure para listar cheques pendentes do cooperado           **/
/******************************************************************************/
PROCEDURE selecao_cheques_pendentes:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_qtcheque AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_qtcordem AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR cratfdc.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE cratfdc.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consulta cheques nao compensados".

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR. 
    
    IF  NOT AVAIL crapdat THEN
        DO:
            ASSIGN aux_cdcritic = 1
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

           RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_dscritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
           
           RETURN "NOK".
        END. 

    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_dscritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT FALSE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.

    FOR EACH crapfdc WHERE crapfdc.cdcooper = crapass.cdcooper AND
                           crapfdc.nrdconta = crapass.nrdconta AND
                           crapfdc.dtretchq <> ?               NO-LOCK:
    
        IF  NOT CAN-DO("0,1,2,8",STRING(crapfdc.incheque))  THEN
            NEXT.

        CREATE cratfdc.
        ASSIGN cratfdc.dtemschq = crapfdc.dtemschq
               cratfdc.dtretchq = crapfdc.dtretchq
               cratfdc.nrdctabb = crapfdc.nrdctabb
               cratfdc.nrcheque = INT(STRING(crapfdc.nrcheque) +
                                      STRING(crapfdc.nrdigchq)).

        
    
        IF  crapfdc.incheque = 1 OR crapfdc.incheque = 2  THEN
            DO:
                FIND crapcor WHERE crapcor.cdcooper = crapfdc.cdcooper AND
                                   crapcor.cdbanchq = crapfdc.cdbanchq AND
                                   crapcor.cdagechq = crapfdc.cdagechq AND
                                   crapcor.nrctachq = crapfdc.nrctachq AND
                                   /** cheque com o digito **/
                                   crapcor.nrcheque = cratfdc.nrcheque AND
                                   crapcor.flgativo = TRUE
                                   NO-LOCK NO-ERROR.
    
                IF  NOT AVAILABLE crapcor  THEN
                    cratfdc.dsobserv = "CHEQUE COM CONTRA-ORDEM".
                ELSE
                    DO:
                        FIND craphis WHERE craphis.cdcooper = par_cdcooper   AND
                                           craphis.cdhistor = crapcor.cdhistor
                                           NO-LOCK NO-ERROR.
    
                        IF  NOT AVAILABLE craphis  THEN
                            DO:
                                ASSIGN aux_cdcritic = 526
                                       aux_dscritic = "".
                   
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,       /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                               
                                RUN proc_gerar_log (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_idseqttl,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_nrdrowid).
            
                                RETURN "NOK".
                            END.
        
                        ASSIGN cratfdc.dsobserv = craphis.dshistor.
                    END.
            END.
        ELSE
            cratfdc.dsobserv = IF  crapfdc.incheque = 0  THEN
                                   ""
                               ELSE
                               IF  crapfdc.incheque = 8  THEN 
                                   "CHEQUE CANCELADO"
                               ELSE 
                                   "NAO IDENTIFICADO".
    
        IF  crapfdc.tpcheque = 2  THEN
            ASSIGN cratfdc.chqtaltb = YES.
        ELSE
            ASSIGN cratfdc.chqtaltb = NO.
             
        /** Quantidade de cheques e quantidade de contra-ordens **/
        ASSIGN par_qtcheque = par_qtcheque + 1
               par_qtcordem = IF  crapfdc.incheque = 1  THEN
                                  par_qtcordem + 1
                              ELSE 
                                  par_qtcordem.

        VALIDATE crapfdc.
    END. /** Fim do FOR EACH crapfdc **/

    RUN proc_gerar_log (INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT "",
                        INPUT aux_dsorigem,
                        INPUT aux_dstransa,
                        INPUT TRUE,
                        INPUT par_idseqttl,
                        INPUT par_nmdatela,
                        INPUT par_nrdconta,
                       OUTPUT aux_nrdrowid).
    
    RETURN "OK".

END PROCEDURE.
  
/* b1wgen0003.p */
/* .......................................................................... */


