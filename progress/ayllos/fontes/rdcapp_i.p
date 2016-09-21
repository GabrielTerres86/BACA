/* .............................................................................

   Programa: Fontes/rdcapp_i.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                       Ultima atualizacao: 26/12/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da inclusao da poupanca programada.

   Alteracoes: 03/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               09/11/98 - Tratar situacao em prejuizo (Deborah).

             24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                          titular (Eduardo).

             08/02/2001 - Aplicacoes RDCA60 e Poup. Progr. apos o dia 28 do
                          mes. (Eduardo).

             17/06/2003 - Critica valor maximo prestacao (Margarete).
             
             31/07/2003 - Inclusao da rotina ver_cadastro e alterada a chamada
                          do ver_capital, para a entrada da tela (Julio).

             16/09/2004 - Alterado alinhamento dos campos (Evandro).

             05/07/2005 - Alimentado campo cdcoopoer da tabela crawrpp (Diego).

             31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando.   

             24/09/2007 - Conversao de rotina ver_capital para BO
                          (Sidnei/Precise)
                          
             22/04/2008 - Vencimento de poupanca programada (Guilherme).   
                 
             15/01/2009 - Acertar critica da data vencto (Magui).     
             
             27/04/2010 - Retirar uso da tabela de estudo da poupança.
                          Usar a BO de poupança  (Gabriel)
                          
             21/06/2011 - Alterada flag de log de FALSE  p/ TRUE
                            em BO b1wgen0006 (Jorge).
                            
             26/12/2011 - Alterações nos valores iniciais das variáveis (Lucas) .
............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_rdcapp.i }

{ sistema/generico/includes/var_internet.i }


DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                      NO-UNDO.

DEF VAR par_nrdrowid AS ROWID                                   NO-UNDO.
DEF VAR aux_antdtini AS DATE                                    NO-UNDO.
DEF VAR aux_nmcampos AS CHAR                                    NO-UNDO.

DEF VAR h-b1wgen0006 AS HANDLE                                  NO-UNDO.

FORM SKIP(1)
     tel_dtinirpp LABEL "Dia do Aniversario/Mes e Ano do Inicio"
     HELP "Entre com o dia do aniversario, o mes e o ano do inicio da poupanca."
                  VALIDATE(tel_dtinirpp <> ?,"013 - Data errada.")
     SKIP(1)
     tel_diadtvct LABEL "Dia/Mes/Ano Vencimento" 
     SPACE(0) "/" SPACE(0)
     tel_mesdtvct NO-LABEL 
     HELP "Entre com o mes de vencimento."
                  VALIDATE(tel_mesdtvct >= 1 AND tel_mesdtvct <= 12, 
                           "269 - Valor errado.")  
     SPACE(0) "/" SPACE(0)
     tel_anodtvct NO-LABEL
     HELP "Entre com o ano de vencimento."
     
     SKIP(1)
     tel_vlprerpp FORMAT "zzz,zzz,zz9.99" LABEL "Valor da prestacao"
                  HELP "Entre com o valor da prestacao da poupanca programda."
                  VALIDATE(tel_vlprerpp > 0,
                           "208 - Valor da prestacao errado.")
    SKIP(1)
    tel_tpemiext  FORMAT "9"              LABEL "Tipo de impressao do extrato" 
        HELP "Como receber o extrato (1-individual,2-todas,3-nao emite)."
     WITH ROW 10 CENTERED OVERLAY SIDE-LABELS
          TITLE COLOR NORMAL " Inclusao de Poupanca Programada "
          FRAME f_inclusao.


 RUN sistema/generico/procedures/b1wgen0006.p
                     PERSISTENT SET h-b1wgen0006.


   RUN obtem-dados-inclusao IN h-b1wgen0006
                            (INPUT glb_cdcooper,
                             INPUT 0,
                             INPUT 0,
                             INPUT glb_cdoperad,
                             INPUT glb_nmdatela,
                             INPUT 1, /* Origem */
                             INPUT tel_nrdconta,
                             INPUT 1, /* Titular */
                             INPUT glb_dtmvtolt,
                             INPUT glb_cdprogra,
                             INPUT TRUE,
                             INPUT-OUTPUT tel_dtinirpp,
                             OUTPUT tel_dtmaxvct,
                             OUTPUT tel_tpemiext,
                             OUTPUT TABLE tt-erro).

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO:
         DELETE PROCEDURE h-b1wgen0006.
         RETURN.
     END.

   IF  RETURN-VALUE <> "OK"   THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
         IF   AVAIL tt-erro   THEN
              MESSAGE tt-erro.dscritic.
              DELETE PROCEDURE h-b1wgen0006.
   
         RETURN.
       END.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   ASSIGN aux_antdtini = tel_dtinirpp.
   UPDATE tel_dtinirpp WITH FRAME f_inclusao.

/* Apenas chama a Procedure caso haja alteração no valor da 'tel_dtinirpp' */   
   IF aux_antdtini <> ? AND
      aux_antdtini <> tel_dtinirpp THEN DO:
      
       RUN obtem-dados-inclusao IN h-b1wgen0006
                            (INPUT glb_cdcooper,
                             INPUT 0,
                             INPUT 0,
                             INPUT glb_cdoperad,
                             INPUT glb_nmdatela,
                             INPUT 1, /* Origem */
                             INPUT tel_nrdconta,
                             INPUT 1, /* Titular */
                             INPUT glb_dtmvtolt,
                             INPUT glb_cdprogra,
                             INPUT TRUE,
                             INPUT-OUTPUT tel_dtinirpp,
                             OUTPUT tel_dtmaxvct,
                             OUTPUT tel_tpemiext,
                             OUTPUT TABLE tt-erro).

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO:
         DELETE PROCEDURE h-b1wgen0006.
         RETURN.
     END.
     
   
   IF  RETURN-VALUE <> "OK"   THEN
       DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
   
         IF   AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
                DELETE PROCEDURE h-b1wgen0006.
   
         RETURN.
       END.
   END.


   ASSIGN tel_diadtvct = DAY  (tel_dtmaxvct)
          tel_mesdtvct = MONTH(tel_dtmaxvct)
          tel_anodtvct = YEAR (tel_dtmaxvct).
          
   DISPLAY tel_anodtvct 
           tel_mesdtvct
           tel_diadtvct WITH FRAME f_inclusao.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
       UPDATE tel_mesdtvct 
              tel_anodtvct  
              tel_vlprerpp
              tel_tpemiext
              WITH FRAME f_inclusao. 
       LEAVE.
        
   END. /* Fim do DO WHILE */
   
   IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
       NEXT.

   RUN validar-dados-inclusao IN h-b1wgen0006
                                (INPUT glb_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT glb_cdoperad,
                                 INPUT glb_nmdatela,
                                 INPUT 1, /* Origem */
                                 INPUT tel_nrdconta,
                                 INPUT 1, /* Titular */
                                 INPUT glb_dtmvtolt,
                                 INPUT tel_dtinirpp,
                                 INPUT tel_mesdtvct,
                                 INPUT tel_anodtvct,
                                 INPUT tel_vlprerpp,
                                 INPUT tel_tpemiext,   
                                 INPUT TRUE,
                                 OUTPUT aux_nmcampos,
                                 OUTPUT TABLE tt-erro).


   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO:
         DELETE PROCEDURE h-b1wgen0006.
         RETURN.
     END.
      
   IF   RETURN-VALUE <> "OK"   THEN
        DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF   AVAIL tt-erro   THEN
              MESSAGE tt-erro.dscritic.
           
            NEXT.
        END.

   /* Confirmaçao dos dados */
   RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).

   IF   aux_confirma <> "S"   THEN
        NEXT.
        

   RUN incluir-poupanca-programada IN h-b1wgen0006
                                      (INPUT glb_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT glb_cdoperad,
                                       INPUT glb_nmdatela,
                                       INPUT 1, /* Origem */
                                       INPUT tel_nrdconta,
                                       INPUT 1, /* Titular */
                                       INPUT glb_dtmvtolt,
                                       INPUT tel_dtinirpp,
                                       INPUT tel_mesdtvct,
                                       INPUT tel_anodtvct,
                                       INPUT tel_vlprerpp,
                                       INPUT tel_tpemiext,
                                       INPUT TRUE,
                                       OUTPUT par_nrdrowid,
                                       OUTPUT TABLE tt-erro).

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO:
         DELETE PROCEDURE h-b1wgen0006.
         RETURN.
     END.

   IF   RETURN-VALUE <> "OK"   THEN
        DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
         IF   AVAIL tt-erro  THEN
              MESSAGE tt-erro.dscritic.
              DELETE PROCEDURE h-b1wgen0006.
         NEXT.
        END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

    DELETE PROCEDURE h-b1wgen0006.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO:
         HIDE FRAME f_inclusao NO-PAUSE.
         RETURN.
     END.

/* Impressao */
RUN fontes/rdcapp_n.p (INPUT par_nrdrowid).

HIDE FRAME f_inclusao NO-PAUSE.

/* .......................................................................... */
