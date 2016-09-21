/* ............................................................................

   Programa: Fontes/sldepr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/94.                       Ultima atualizacao: 19/08/2015'    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para montar o saldo dos emprestimos e mostrar o extrato
               dos mesmos para a tela ATENDA.

   Alteracoes: 11/05/95 - Alterado para solicitar a data de calculo do empres-
                          timo (Edson).

               17/10/96 - Alterado para tratar o calculo dos emprestimos toman-
                          do como base a quantidade de dias para a liberacao do
                          novo emprestimo (Edson).

               20/11/96 - Alterar a mascara do campo nrctremp (Odair).

               11/04/97 - Alterado para descontar o valor provisionado no
                          cheque salario (Edson).

               14/01/98 - Alterado para permitir consulta das informacoes
                          complementares dos emprestimos (Edson).

               05/03/98 - Alterado para utilizar qtprecal no lugar de qtprepag
                          (Edson).

               16/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               08/03/2001  - Mostrar se ha prestacoes com pagamento parcial e 
                             colocado o valor a regularizar e os meses decorri
                             dos (Deborah).

               23/03/2001 - Ajustes na ultima alteracao (Deborah). 

               30/03/2001 - Incluido tratamento quando nao houver o registro
                            no crawepr (Deborah).

               25/06/2001 - Incluir tratamento do prejuizo (Margarete).

               05/03/2002 - Tratamento D+1 (Margarete).

               07/05/2002 - Novos campos na consulta do prejuizo (Margarete).

               23/03/2003 - Incluir tratamento da Concredi (Margarete).

               18/07/2003 - Quando acabou o prazo para pagamento jogar no
                            a regularizar o saldo devedor (Margarete).
               
             30/06/2004 - Prever avalistas terceiros(Mirtes) 

             06/08/2004 - Passar a usar includes/gera_workper.i (Margarete).

             17/12/2004 - Demonstrado Qtd.Aditivos(Mirtes).

             23/03/2005 - Incluido campo inc_nrctremp(gera_workepr.i)(Mirtes).

             29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                          tabela crapadt (Diego).
           
             03/02/2006 - Unificacao dos Bancos - SQLWorks - Andre

             09/02/2006 - Inclusao do EMPTY TEMP-TABLE na TEMP-TABLE workepr - 
                          SQLWorks - Fernando.
                          
             02/03/2006 - Nao pedir a data de calculo do emprestimo (Evandro).
             
             30/05/2006 - Desabilitado o trecho de codigo que faz referencia
                          a tabela crapfol (Julio)
                        
             20/12/2006 - Incluido campo workepr.vlrabono (Elton).

             15/04/2008 - Novo Browse Atenda - Retirado comentarios(Sidnei)
             
             23/04/2008 - Alterado formato do campo "qtpreemp" de "z9" para 
                          "zz9" - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
             01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
                        
                        - Incluida opcao de imprimir (Gabriel).

             16/01/2009 - Evitar estouro de campo Valor (Gabriel).
             
             10/12/2009 - Nao listar emprestimos liquidados inliquid = 1
                          (Guilherme).
                          
             16/03/2010 - No browse dos emprestimos, considerar a busca
                          pelo campo 'Manter após Liq.' da LCREDI (Gabriel).
                                
             21/09/2010 - Usar includes var_internet.i (Gabriel).
             
             27/05/2011 - Adaptado para o uso de BO. (Gabriel Capoia/DB1)
             
             06/10/2011 - Adicionado campo Taxa Mensal, logo acima do campo
                          Taxa de Juros. (GATI - Oliver)
                          
             31/01/2013 - Incluir campo tt-dados-epr.dsidenti no browser de 
                          consulta (Lucas R.).
                          
             24/02/2014 - Adicionado param. de paginacao em proc. 
                            obtem-dados-emprestimos em BO 0002.(Jorge) 
                            
             05/03/2014 - Incluido os campos da Multa, Juros de Mora e 
                          Total Pagar (James)
                          
             28/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                          posicoes (Tiago/Gielow SD137074).   
                          
             03/11/2014 - Incluso novos campos no form f_preju, projeto
                          Transf. prejuizo (Daniel/Oscar).         
                          
             30/12/2014 - Alterado Format dos campos tt-dados-epr.vlemprst, 
                          vlsdeved (Lucas R./Thiago #237128)
                          
             26/01/2015 - Alterado o formato do campo nrctremp para 8 
                          caracters (Kelvin - 233714)

             23/04/2015 - Alteracao do label "Saldo" para "Saldo Liquida", 
                          e soma 'Saldo Devedor' com 'Multa' e 'Juros Mora'. 
                          (Jaison/Gielow - SD: 262029)
                          
             19/08/2015 - Adicionado novo formato no campo qtmesdec conforme
                          solicitado no chamado 312250 (Kelvin).

............................................................................ */

{ sistema/generico/includes/var_internet.i }
 
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/ctremp.i }
{ includes/var_proepr.i "NEW"}
    
DEF BUFFER crabass FOR crapass.

DEF        VAR h-b1wgen0002 AS HANDLE                                NO-UNDO.

DEF INPUT  PARAM par_flgextra AS LOGICAL                             NO-UNDO.
DEF INPUT  PARAM par_qtdialib AS INT                                 NO-UNDO.

DEF        VAR tab_diapagto AS INT                                   NO-UNDO.
DEF        VAR tab_indpagto AS INT                                   NO-UNDO.
DEF        VAR tab_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR tab_dtlimcal AS DATE                                  NO-UNDO.
DEF        VAR tab_flgfolha AS LOGICAL                               NO-UNDO.
DEF        VAR tab_inusatab AS LOGICAL                               NO-UNDO.

DEF        VAR ant_vlsdeved AS DECIMAL                               NO-UNDO.

DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dtinipag AS DATE                                  NO-UNDO.

DEF        VAR aux_contaseg AS INT                                   NO-UNDO.
DEF        VAR aux_nrrecepr AS INT                                   NO-UNDO.

DEF        VAR aux_vldescto AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlprovis AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txaplica AS DECIMAL DECIMALS 4                    NO-UNDO.
DEF        VAR aux_vlmoefix AS DECIMAL DECIMALS 4                    NO-UNDO.
DEF        VAR aux_vlsldliq AS DECIMAL                               NO-UNDO.

/*** Variaveis para usar includes/gera_workepr.i ***/

DEF        VAR inc_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR inc_dtcalcul AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR inc_nrctremp LIKE crapepr.nrctremp                    NO-UNDO.

DEF        VAR aux_qtregist AS INTE                                  NO-UNDO. 

/*** Definicoes do browse de emprestimo ***/
DEF VAR aux_query    AS CHAR                                         NO-UNDO.

DEF VAR aux_tpemprst AS CHAR FORMAT "X(1)"                           NO-UNDO.

DEFINE QUERY q_workepr FOR tt-dados-epr.

DEF BROWSE b_workepr QUERY q_workepr 
    DISP tt-dados-epr.dsidenti COLUMN-LABEL ""            FORMAT "x(1)"
         tt-dados-epr.cdlcremp COLUMN-LABEL "Lin"         FORMAT "9999"
         tt-dados-epr.cdfinemp COLUMN-LABEL "Fin"         FORMAT "999"
         tt-dados-epr.nrctremp COLUMN-LABEL "Contrato"    FORMAT "zz,zzz,zz9"
         tt-dados-epr.dtmvtolt COLUMN-LABEL "Data"        FORMAT "99/99/99"
         tt-dados-epr.vlemprst COLUMN-LABEL "Emprestado"  FORMAT "zzzzz,zz9.99"
         tt-dados-epr.qtpreemp COLUMN-LABEL "Parc"        FORMAT "zz9"
         tt-dados-epr.vlpreemp COLUMN-LABEL "Valor"       FORMAT "zzzz,zz9.99"
         tt-dados-epr.vlsdeved COLUMN-LABEL "Saldo"       FORMAT "zzzzz,zz9.99-"
         WITH 9 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

DEF FRAME f_workepr
          b_workepr  
    HELP "Pressione <ENTER> p/ detalhes ou <SETAS> p/ outras informacoes "
    WITH NO-BOX CENTERED OVERLAY ROW 9 .

DEF FRAME f_emprest.
DEF FRAME f_preju.

FORM SKIP    
     tt-dados-epr.nrctremp AT  6 LABEL "Contrato" FORMAT "z,zzz,zzz,zzz,zz9"
     tt-dados-epr.cdpesqui AT 42 LABEL "Pesquisa"
     SKIP
     tt-dados-epr.qtaditiv AT  3 LABEL "Qt.Aditivos" FORMAT "              zz9"
     tt-dados-epr.txmensal AT 39 LABEL "Taxa Mensal" FORMAT "    zz9.999999"
     SKIP 
     tt-dados-epr.vlemprst AT  4 LABEL "Emprestado" FORMAT "zz,zzz,zzz,zz9.99-"
     tt-dados-epr.txjuremp AT 37 LABEL "Taxa de Juros"
     SKIP
     aux_vlsldliq          AT  1 LABEL "Saldo Liquida" FORMAT "zz,zzz,zzz,zz9.99-"
     tt-dados-epr.vljurmes AT 38 LABEL "Juros do Mes"
     SKIP
     tt-dados-epr.vlpreemp AT  5 LABEL "Prestacao" FORMAT "zz,zzz,zzz,zz9.99-"
     tt-dados-epr.vljuracu AT 34 LABEL "Juros Acumulados"
     SKIP
     tt-dados-epr.vlprepag AT  3 LABEL "Pago no Mes" FORMAT "zz,zzz,zzz,zz9.99-"
     tt-dados-epr.dspreapg AT 34 LABEL "Prest.pagas/Tot."
     tt-dados-epr.vlpreapg AT  3 LABEL "Parc. Pagar" FORMAT "zz,zzz,zzz,zz9.99-"
     tt-dados-epr.qtmesdec AT 34 LABEL "Meses decorridos" FORMAT "            zzz,zz9-"
     SKIP
     tt-dados-epr.vlmtapar AT 09 LABEL "Multa" FORMAT "zz,zzz,zzz,zz9.99-"
     SKIP
     tt-dados-epr.vlmrapar AT 04 LABEL "Juros Mora" FORMAT "zz,zzz,zzz,zz9.99-"
     SKIP
     tt-dados-epr.vltotpag AT  3 LABEL "Total Pagar" FORMAT "zz,zzz,zzz,zz9.99-"
     tt-dados-epr.dslcremp AT  2 LABEL "L. Credito"
     tt-dados-epr.dsfinemp AT 40 LABEL "Finalidade"
     SKIP
     "Avais:"         AT  2
     tt-dados-epr.dsdaval1 AT  9 NO-LABEL
     tt-dados-epr.dsdaval2 AT 40 NO-LABEL
     SKIP
     tel_dsdpagto     AT  2 NO-LABEL
     tel_prejuizo     AT 40 NO-LABEL
     tel_imprimir     AT 50 NO-LABEL
     tel_dsdemais     AT 60 NO-LABEL
     tel_extratos     AT 70 NO-LABEL
     WITH ROW 7 CENTERED NO-LABELS SIDE-LABELS OVERLAY
          TITLE epr_dttitulo FRAME f_emprest.

FORM 
     SKIP(1)
     "Transferido em:    " AT 5  tt-dados-epr.dtprejuz FORMAT "99/99/9999"
     "Valor do Abono:" AT 40 tt-dados-epr.vlrabono FORMAT "zzz,zzz,zz9.99-"
     SKIP
     "Prejuizo Original:" AT 2 tt-dados-epr.vlprejuz FORMAT "zzz,zzz,zz9.99-"
     "Juros do Mes:" AT 42 tt-dados-epr.vljrmprj FORMAT "zzz,zzz,zz9.99-" 
     SKIP 
     "Sld.Prej.Original:" AT 2 tt-dados-epr.slprjori FORMAT "zzz,zzz,zz9.99-"
     "Juros Acumulados:" AT 38 tt-dados-epr.vljraprj FORMAT "zzz,zzz,zz9.99-"
     SKIP
     "Valores Pagos:"   AT 6  tt-dados-epr.vlrpagos FORMAT "zzz,zzz,zz9.99-"
     "Acrescimos:"      AT 44 tt-dados-epr.vlacresc FORMAT "zzz,zzz,zz9.99-"
     SKIP
     "Multa:"             AT 14  tt-dados-epr.vlttmupr FORMAT "zzz,zzz,zz9.99-"
     "Juros de Mora:"     AT 41 tt-dados-epr.vlttjmpr FORMAT "zzz,zzz,zz9.99-" 
     SKIP
     "Vlr. Pg. Multa:"    AT 5  tt-dados-epr.vlpgmupr FORMAT "zzz,zzz,zz9.99-"
     "Vlr.Pg.Juros Mora:" AT 37 tt-dados-epr.vlpgjmpr FORMAT "zzz,zzz,zz9.99-" 
     SKIP
     "Saldo Atualizado:" AT 38 tt-dados-epr.vlsdprej FORMAT "zzz,zzz,zz9.99-" 
     SKIP(1)
     WITH ROW 10 NO-LABELS CENTERED SIDE-LABELS OVERLAY 
          TITLE "Prejuizos do Contrato" FRAME f_preju.

EMPTY TEMP-TABLE tt-dados-epr. 

ASSIGN inc_nrdconta = tel_nrdconta
       inc_dtcalcul = tel_dtcalcul.

/* busca informacoes de emprestimo e prestacoes (para nao 
   utilizar mais a include "gera workepr.i") - (Gabriel/DB1) */

 IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
     RUN sistema/generico/procedures/b1wgen0002.p
         PERSISTENT SET h-b1wgen0002.

 RUN obtem-dados-emprestimos IN h-b1wgen0002
     ( INPUT glb_cdcooper,
       INPUT 0,  /** agencia **/
       INPUT 0,  /** caixa **/
       INPUT glb_cdoperad,
       INPUT "sldepr.p",
       INPUT 1,  /** origem **/
       INPUT inc_nrdconta,
       INPUT 1,  /** idseqttl **/
       INPUT glb_dtmvtolt,
       INPUT glb_dtmvtopr,
       INPUT inc_dtcalcul,
       INPUT 0, /** Contrato **/
       INPUT "sldepr.p",
       INPUT glb_inproces,
       INPUT FALSE, /** Log **/
       INPUT TRUE,
       INPUT 0, /** nriniseq **/
       INPUT 0, /** nrregist **/
      OUTPUT aux_qtregist,
      OUTPUT TABLE tt-erro,
      OUTPUT TABLE tt-dados-epr ).


 IF  VALID-HANDLE(h-b1wgen0002) THEN
     DELETE OBJECT h-b1wgen0002.

 IF  RETURN-VALUE = "NOK"  THEN
     DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF  AVAILABLE tt-erro  THEN
             ASSIGN glb_dscritic = tt-erro.dscritic.
         ELSE
             ASSIGN glb_dscritic = "Erro no carregamento"
                                  + " de emprestimos.".
        
         RETURN "NOK".
     END.
             
IF   par_flgextra   THEN
     DO:

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            ON ENTER OF b_workepr IN FRAME f_workepr DO:
                  
                IF  NOT AVAILABLE tt-dados-epr  THEN
                   LEAVE.

               HIDE FRAME f_workepr.
               HIDE MESSAGE NO-PAUSE.

               ASSIGN aux_nrrecepr = tt-dados-epr.nrdrecid
                      aux_nrctremp = tt-dados-epr.nrctremp
                      epr_dttitulo = " Emprestimo calculado ate " +
                                     (IF tel_dtcalcul = ?
                                         THEN "Hoje"
                                      ELSE STRING(tel_dtcalcul,"99/99/9999")) +
                                         " "
                      tel_dsdpagto = IF tt-dados-epr.flgpagto
                                     THEN "Debito em C/C vinculado"+
                                          " ao credito da folha"
                                     ELSE "Debito em C/C no dia " +
                                          STRING
                                            (DAY(tt-dados-epr.dtdpagto),"99") +
                                           " (" + STRING(tt-dados-epr.dtdpagto,
                                                           "99/99/9999") + ")".

               IF  tt-dados-epr.inprejuz > 0   THEN
                   ASSIGN tel_prejuizo = "Prejuizo".
               ELSE
                   ASSIGN tel_prejuizo = "".

               ASSIGN aux_vlsldliq = tt-dados-epr.vlsdeved +
                                     tt-dados-epr.vlmtapar +
                                     tt-dados-epr.vlmrapar.

               DISPLAY tt-dados-epr.nrctremp
                       tt-dados-epr.qtaditiv
                       tt-dados-epr.vlemprst aux_vlsldliq
                       tt-dados-epr.vlpreemp tt-dados-epr.vlprepag 
                       tt-dados-epr.txmensal
                       tt-dados-epr.cdpesqui tt-dados-epr.txjuremp 
                       tt-dados-epr.vljurmes tt-dados-epr.vljuracu
                       tt-dados-epr.dspreapg tt-dados-epr.dslcremp 
                       tt-dados-epr.dsfinemp tt-dados-epr.dsdaval1 
                       tt-dados-epr.dsdaval2 tel_dsdpagto
                       tt-dados-epr.vlpreapg tt-dados-epr.qtmesdec
                       tt-dados-epr.vlmtapar tt-dados-epr.vlmrapar 
                       tt-dados-epr.vltotpag
                       tel_prejuizo tel_imprimir tel_dsdemais tel_extratos 
                       WITH FRAME f_emprest.

               IF  tt-dados-epr.vlprovis > 0   THEN
                   MESSAGE "Valor provisionado no cheque salario:"
                        TRIM(STRING(tt-dados-epr.vlprovis,"zzz,zzz,zz9.99")).
            
               IF  tt-dados-epr.inprejuz = 0   THEN
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

                      CHOOSE FIELD tel_imprimir tel_dsdemais tel_extratos 
                                   WITH FRAME f_emprest.

                      { includes/sldepr_opcoes.i }
                       
                   END.  /*  Fim do DO WHILE TRUE  */
               ELSE 
                    
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE.
                    
                       CHOOSE FIELD tel_prejuizo tel_dsdemais 
                                    tel_imprimir tel_extratos
                                    WITH FRAME f_emprest.
                                 
                       IF  FRAME-VALUE = tel_prejuizo   THEN
                           DO:
                               DISPLAY tt-dados-epr.vljraprj  
                                       tt-dados-epr.vlprejuz
                                       tt-dados-epr.vlsdprej  /* Saldo preju*/
                                       tt-dados-epr.dtprejuz
                                       tt-dados-epr.vljrmprj  
                                       tt-dados-epr.vlacresc
                                       tt-dados-epr.vlrpagos  
                                       tt-dados-epr.slprjori
                                       tt-dados-epr.vlrabono 
                                       tt-dados-epr.vlttmupr 
                                       tt-dados-epr.vlttjmpr
                                       tt-dados-epr.vlpgmupr
                                       tt-dados-epr.vlpgjmpr 
                                       WITH FRAME f_preju.
                               PAUSE MESSAGE "Tecle algo para continuar...".
                           END.
                       ELSE
                           { includes/sldepr_opcoes.i }
                 
                    END. /* Fim do DO WHILE TRUE */
            
                HIDE FRAME f_emprest NO-PAUSE.
                HIDE FRAME f_preju   NO-PAUSE.
                HIDE MESSAGE NO-PAUSE.

                ENABLE b_workepr WITH FRAME f_workepr.
            
                IF  aux_nrctatos = 1   THEN
                    LEAVE.

            END. /* ON ENTER of BROWSER */

            aux_query = "FOR EACH tt-dados-epr".

            QUERY q_workepr:QUERY-CLOSE().
            QUERY q_workepr:QUERY-PREPARE(aux_query).

            MESSAGE "Aguarde...".

            QUERY q_workepr:QUERY-OPEN().
            
            HIDE MESSAGE NO-PAUSE.
            
            ENABLE b_workepr WITH FRAME f_workepr.

            WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
            
            HIDE FRAME f_workepr.

            HIDE MESSAGE NO-PAUSE.
            
            LEAVE.
         
         END.  /*  Fim do DO WHILE TRUE  */

         RETURN.
     END.
/* ......................................................................... */

