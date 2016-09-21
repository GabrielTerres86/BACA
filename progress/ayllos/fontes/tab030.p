/* .............................................................................

   Programa: Fontes/tab030.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Abril/2004                        Ultima alteracao: 22/04/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela tab030 - Valor a ser desconsiderado no arrastao
               (Risco -  Principio Materialidade)

   Alteracoes: 01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
   
               03/08/2011 - Incluido campo "Valor Salario Minimo"
                            (Adriano).
                            
              18/11/2011 - Adaptado para trabalhar com a BO129 (Lucas).
               
              25/05/2012 - Incluido campo diasatrs(dias atraso para relatorio)
                           (Tiago).            
                           
              22/04/2013 - Incluido o parametro "Dias atraso para 
                           inadimplência:" (Adriano).
                             
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR tel_vllimite AS DECIMAL FORMAT "zzzzz9.99"            NO-UNDO.
DEF VAR tel_vlsalmin AS DECIMAL FORMAT "zzzz,zz9.99"          NO-UNDO.
DEF VAR tel_diasatrs AS INT     FORMAT "zz9"                  NO-UNDO.
DEF VAR tel_atrsinad AS INT     FORMAT "zzz9"                 NO-UNDO.

DEF VAR aux_dstextab AS CHAR                                  NO-UNDO. 
DEF VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.

DEF VAR aux_contador AS INT                                   NO-UNDO.

DEF VAR h-b1wgen0129 AS HANDLE                                NO-UNDO.


FORM SKIP(1)
     "Opcao: " glb_cddopcao AUTO-RETURN FORMAT "!"
                        HELP "Entre com a opcao desejada (A,C)."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(2)
     "Valor a ser Desconsiderado(Arrasto):" AT 12 
     tel_vllimite AT 51
                  HELP "Valor a ser desconsiderado(Menor ou Igual)"
     SKIP(1)
     "Valor salario minimo: " AT 27
     tel_vlsalmin AT 49
                  HELP "Informe o salario minimo."
     SKIP
     "(atualiza todas as cooperativas)" AT  16
     SKIP(1)
     "Dias atraso para relatorio de provisao:" AT 9
     tel_diasatrs AT 57
                  HELP "Informe quantidade de dias de atraso."
     SKIP
     "(Adiantamento a Depositantes)"  AT 19
     SKIP(1)
     "Dias atraso para inadimplencia:" AT 17
     tel_atrsinad AT 56
                  HELP "Informe quantidade de dias de atraso."
     SKIP
     "(Relatorio de Provisao)"  AT 25
     SKIP(2)
     WITH ROW 4 OVERLAY NO-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_tab030.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:
     
    RUN fontes/inicia.p.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IF  glb_cdcritic > 0   THEN
            DO:
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                CLEAR FRAME f_tab030 NO-PAUSE.
                ASSIGN glb_cdcritic = 0.

            END.

        UPDATE glb_cddopcao  WITH FRAME f_tab030.

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "TAB030"   THEN
                 DO:
                     HIDE FRAME f_tab030.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
    
    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

    IF NOT VALID-HANDLE(h-b1wgen0129) THEN
       RUN sistema/generico/procedures/b1wgen0129.p 
           PERSISTENT SET h-b1wgen0129.
            
    RUN busca_tab030 IN h-b1wgen0129 (INPUT glb_cdcooper,
                                      INPUT 0, /* Agencia*/
                                      INPUT 0, /* Caixa  */
                                      INPUT glb_cdoperad,
                                      OUTPUT tel_vllimite,
                                      OUTPUT tel_vlsalmin,
                                      OUTPUT tel_diasatrs,
                                      OUTPUT tel_atrsinad,
                                      OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0129) THEN
       DELETE PROCEDURE h-b1wgen0129.

    /* Verifica se a Procedure retornou erro */
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-erro  THEN
                MESSAGE tt-erro.dscritic.

            NEXT.
        END.

    DISPLAY tel_vllimite 
            tel_vlsalmin 
            tel_diasatrs 
            tel_atrsinad
            WITH FRAME f_tab030.

    IF  glb_cddopcao = "A" THEN 
        DO:

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                UPDATE tel_vllimite 
                       tel_vlsalmin 
                       tel_diasatrs
                       tel_atrsinad
                       WITH FRAME f_tab030.

                LEAVE.
    
            END.
               
            ASSIGN aux_confirma = "N".

            RUN fontes/confirma.p (INPUT  "",
                                   OUTPUT aux_confirma).
        
            IF  aux_confirma = "S" THEN 
                DO:
                    IF NOT VALID-HANDLE(h-b1wgen0129) THEN  
                       RUN sistema/generico/procedures/b1wgen0129.p 
                           PERSISTENT SET h-b1wgen0129.
    
                    RUN altera_tab030 IN h-b1wgen0129 (INPUT glb_cdcooper,
                                                       INPUT 0, /* Agencia*/
                                                       INPUT 0, /* Caixa  */
                                                       INPUT glb_cdoperad,
                                                       INPUT "tab030",
                                                       INPUT 1, /* Ayllos */
                                                       INPUT glb_dtmvtolt, 
                                                       INPUT TRUE, /* Gerar log */
                                                       INPUT aux_dstextab,
                                                       INPUT glb_dsdepart,
                                                       INPUT tel_vllimite,
                                                       INPUT tel_vlsalmin,
                                                       INPUT tel_diasatrs,
                                                       INPUT tel_atrsinad,
                                                       OUTPUT TABLE tt-erro).
    
                    IF VALID-HANDLE(h-b1wgen0129) THEN
                       DELETE PROCEDURE h-b1wgen0129.
    
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                            IF  AVAILABLE tt-erro  THEN
                                MESSAGE tt-erro.dscritic.
    
                            NEXT.

                        END.

                END.    

        END.                

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
