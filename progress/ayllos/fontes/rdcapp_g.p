
/* .............................................................................

   Programa: Fontes/rdcapp_g.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Junho/2001.                       Ultima atualizacao: 21/06/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento do resgate da poupanca programada.

   Alteracoes: 16/09/2004 - Incluido FLAG CI - Conta Investimento, Alterado
                            alinhamento dos campos e incluida exibicao dos
                            campos CI e Resgate (Evandro).

               05/07/2005 - Alimentado campo cdcooper das tabelas craplot e 
                            craplrg (Diego).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               05/09/2006 - Alterado para habilitar a opcao 
                            "Resgate Saldo para a CI" em aplicacoes antigas, se
                            data do resgate for maior que 01/10/2006 (Diego).
                            
               08/05/2008 - Data vcto da RPP(Guilherme).             
               
               28/04/2010 - Passar para um browse dinamico.
                            Utilizar a BO de poupança (Gabriel)
                            
               21/06/2011 - Alterada flag de log de FALSE  p/ TRUE
                            em BO b1wgen0006 (Jorge).
               
............................................................................. */

DEF INPUT PARAM par_nrctrrpp AS INTE                                 NO-UNDO.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_rdcapp.i }

{ sistema/generico/includes/var_internet.i }

DEF    VAR tel_dsresgat AS CHAR    INIT "Resgates"     FORMAT "x(08)" NO-UNDO.
DEF    VAR tel_dscancel AS CHAR    INIT "Cancelamento" FORMAT "x(12)" NO-UNDO.
DEF    VAR tel_dsproxim AS CHAR    INIT "Proximos"     FORMAT "x(08)" NO-UNDO.

DEF    VAR tel_flgctain AS LOGICAL FORMAT "S/N"                       NO-UNDO.
DEF    VAR tel_tpresgat AS CHAR    FORMAT "x"                         NO-UNDO.
DEF    VAR tel_dtresgat AS DATE                                       NO-UNDO.
DEF    VAR tel_vlresgat AS DECIMAL FORMAT "zzz,zzz,zz9.99"            NO-UNDO.

DEF    VAR aux_confirma AS CHAR    FORMAT "!"                         NO-UNDO.
DEF    VAR aux_flgconsl AS LOGICAL                                    NO-UNDO. 

DEF    VAR h-b1wgen0006 AS HANDLE                                     NO-UNDO.

DEF    VAR aut_cdopera2 AS CHAR                                       NO-UNDO.
DEF    VAR aut_cddsenha AS CHAR                                       NO-UNDO.
DEF    VAR aut_flgsenha AS LOGICAL                                    NO-UNDO.

DEF    VAR aux_cdoperad AS CHAR                                       NO-UNDO.

DEF    VAR aux_vlresgat AS DECIMAL                                    NO-UNDO.


FORM SKIP(1)
     tel_dsresgat AT 05 
     tel_dscancel AT 24
     tel_dsproxim AT 47         
     SKIP(1)
     WITH ROW 14 COLUMN 44 OVERLAY CENTERED  WIDTH 60
     NO-LABELS TITLE COLOR NORMAL " Resgates " FRAME f_opcao.
     
FORM SKIP(1)
     tel_tpresgat  AT 5 LABEL "Tipo de resgate (T/P)" AUTO-RETURN     
                   HELP "Entre com o tipo de resgate (Total/Parcial)."
                   VALIDATE(tel_tpresgat = "T" OR tel_tpresgat = "P"
                            ,"014 - Opcao errada.")
     SKIP(1)
     tel_vlresgat  AT 10 FORMAT "zzz,zzz,zz9.99" LABEL "Valor do resgate"
                   AUTO-RETURN  HELP "Entre com o valor do resgate."
                   VALIDATE(tel_vlresgat > 0,"269 - Valor errado.")
     SKIP(1)
     tel_dtresgat  AT 11 FORMAT "99/99/9999" LABEL "Data do resgate" 
                   AUTO-RETURN  HELP "Entre com a data do resgate."
                   VALIDATE (tel_dtresgat <> ? OR tel_dtresgat > glb_dtmvtolt, 
                             "013 - Data errada.")
     SKIP(1)
     tel_flgctain AT 7  LABEL "Resgatar Saldo para a CI?"
                   AUTO-RETURN HELP "Entre Sim/Nao - Conta Investimento"
     SKIP(1)            
     WITH ROW 10 COLUMN 44 CENTERED WIDTH 60  OVERLAY SIDE-LABELS
         TITLE COLOR NORMAL " Resgate de Poupanca Programada " FRAME f_resgate.

 
ASSIGN aux_cdoperad = glb_cdoperad.

RUN sistema/generico/procedures/b1wgen0006.p 
                    PERSISTENT SET h-b1wgen0006.

RUN valida-resgate IN h-b1wgen0006 (INPUT glb_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT glb_cdoperad,
                                    INPUT glb_nmdatela,
                                    INPUT 1, /* Origem */
                                    INPUT tel_nrdconta,
                                    INPUT 1, /* Titular */
                                    INPUT par_nrctrrpp,
                                    INPUT glb_dtmvtolt,
                                    INPUT glb_dtmvtopr,
                                    INPUT glb_inproces,
                                    INPUT glb_cdprogra,
                                    INPUT "",
                                    INPUT 0,
                                    INPUT ?,
                                    INPUT TRUE,
                                    INPUT TRUE,
                                    OUTPUT aux_vlsldrpp,
                                    OUTPUT TABLE tt-erro). 
DELETE PROCEDURE h-b1wgen0006.

IF   RETURN-VALUE <> "OK"   THEN
     DO:    
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF   AVAIL tt-erro   THEN
              MESSAGE tt-erro.dscritic.

         RETURN.
     END.


DO WHILE TRUE:

   CLEAR FRAME f_opcao ALL NO-PAUSE.
   
   CLEAR FRAME f_resgate ALL NO-PAUSE.

   ASSIGN tel_tpresgat = " "
          tel_dtresgat = ?
          tel_vlresgat = 0
          tel_flgctain = no. 
          
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_cddopcao = " ".
      
      DISPLAY tel_dsresgat tel_dscancel tel_dsproxim WITH FRAME f_opcao.

      CHOOSE FIELD tel_dsresgat
             HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
                   tel_dscancel
             HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
                   tel_dsproxim
             HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
             WITH FRAME f_opcao.

      IF   FRAME-VALUE = tel_dsresgat  THEN
           aux_cddopcao = "R".
      ELSE
           IF   FRAME-VALUE = tel_dscancel  THEN
                aux_cddopcao = "C".         
           ELSE
                 IF   FRAME-VALUE = tel_dsproxim  THEN
                     aux_cddopcao = "P".         

      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        DO: 
            HIDE FRAME f_opcao.
            LEAVE.
        END.
      
   IF   aux_cddopcao = "R" THEN /* Resgatar */
        DO:            
            CLEAR FRAME f_resgat ALL NO-PAUSE.
            
            tel_tpresgat = "T".

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_tpresgat WITH FRAME f_resgate.
               LEAVE.

            END.
   
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM   */
                 DO:
                     HIDE FRAME f_resgate.
                     NEXT.
                 END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF   tel_tpresgat = "T" THEN
                    DO:
                        tel_vlresgat = 0.

                        DISPLAY tel_vlresgat WITH FRAME f_resgate.
                        
                        DO WHILE TRUE:
                            
                            UPDATE tel_dtresgat  WITH FRAME f_resgate.
                            LEAVE.     
                            
                        END.
                    END.
               ELSE
                    DO:
                        UPDATE tel_vlresgat WITH FRAME f_resgate.
                                                 
                        DO WHILE TRUE:
                            
                            UPDATE tel_dtresgat WITH FRAME f_resgate.
                            LEAVE.     
                            
                        END.     
                                                      
                    END.  /*    Fim do IF  */

               ASSIGN tel_flgctain = NO.

               UPDATE tel_flgctain WITH FRAME f_resgate.
               
               RUN sistema/generico/procedures/b1wgen0006.p
                                    PERSISTEN SET h-b1wgen0006.

               RUN valida-resgate IN h-b1wgen0006 (INPUT glb_cdcooper,
                                                   INPUT 0,
                                                   INPUT 0,
                                                   INPUT glb_cdoperad,
                                                   INPUT glb_nmdatela,
                                                   INPUT 1, /* Origem */
                                                   INPUT tel_nrdconta,
                                                   INPUT 1, /* Titular */
                                                   INPUT par_nrctrrpp,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT glb_dtmvtopr,
                                                   INPUT glb_inproces,
                                                   INPUT glb_cdprogra,
                                                   INPUT tel_tpresgat,
                                                   INPUT tel_vlresgat,
                                                   INPUT tel_dtresgat,
                                                   INPUT FALSE,
                                                   INPUT TRUE,
                                                   OUTPUT aux_vlsldrpp,
                                                   OUTPUT TABLE tt-erro).
               DELETE PROCEDURE h-b1wgen0006.

               IF   RETURN-VALUE <> "OK"   THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF   AVAIL tt-erro   THEN
                             MESSAGE tt-erro.dscritic.

                        NEXT.
                    END.

               /* TIAGO 
                  validar limite alcada aqui */

               IF  tel_vlresgat = 0 AND
                   aux_vlsldrpp > 0 THEN
                   ASSIGN aux_vlresgat = aux_vlsldrpp. /*resgate total*/
               ELSE
                   ASSIGN aux_vlresgat = tel_vlresgat. /*resgate parcial*/


               EMPTY TEMP-TABLE tt-erro.

               RUN sistema/generico/procedures/b1wgen0006.p
                                    PERSISTEN SET h-b1wgen0006.

               RUN validar-limite-resgate 
                   IN h-b1wgen0006( INPUT glb_cdcooper, /*cooperativa*/
                                    INPUT 1,            /*origem*/
                                    INPUT glb_nmdatela, /*nome da tela*/
                                    INPUT 1,            /*titular*/
                                    INPUT tel_nrdconta, /*conta*/
                                    INPUT aux_vlresgat, /*valor resgate*/
                                    INPUT glb_cdoperad, /*operador*/
                                    INPUT "",           /*senha operad*/
                                    INPUT 0,            /*validar senha*/
                                    OUTPUT TABLE tt-erro ).

               DELETE PROCEDURE h-b1wgen0006.

               IF   RETURN-VALUE = "NOK"  THEN
                    DO:

                       FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                       IF  AVAIL tt-erro   THEN
                           DO:
                             BELL.
                             MESSAGE tt-erro.dscritic.
                             PAUSE 3 NO-MESSAGE.
                           END.      

                       ASSIGN aut_cdopera2 = "".
                       /* necessita da senha do operador */
                       RUN fontes/pedesenha.p ( INPUT glb_cdcooper,
                                                INPUT 1,
                                                OUTPUT aut_flgsenha,
                                                OUTPUT aut_cdopera2).
               
                       IF  NOT aut_flgsenha   THEN
                           NEXT.

                       EMPTY TEMP-TABLE tt-erro.

                       RUN sistema/generico/procedures/b1wgen0006.p
                                            PERSISTEN SET h-b1wgen0006.

                       RUN validar-limite-resgate 
                           IN h-b1wgen0006( INPUT glb_cdcooper, /*cooperativa*/
                                            INPUT 1,            /*origem*/
                                            INPUT glb_nmdatela, /*nome da tela*/
                                            INPUT 1,            /*titular*/
                                            INPUT tel_nrdconta, /*conta*/
                                            INPUT aux_vlresgat, /*valor resgate*/
                                            INPUT aut_cdopera2, /*operador*/
                                            INPUT "",           /*senha operad*/
                                            INPUT 0,            /*validar senha*/
                                            OUTPUT TABLE tt-erro ).

                       DELETE PROCEDURE h-b1wgen0006.

                       IF   RETURN-VALUE = "NOK"  THEN
                            DO:

                               FIND FIRST tt-erro NO-LOCK NO-ERROR.

                               IF  AVAIL tt-erro   THEN
                                   DO:
                                       BELL.
                                       MESSAGE tt-erro.dscritic.
                                       PAUSE 3 NO-MESSAGE.
                                       NEXT.
                                   END.      
                            END.
                       ELSE
                           DO:
                                ASSIGN aux_cdoperad = aut_cdopera2.
                           END.
                    END.

               /* Confirmaçao dos dados */
               RUN fontes/confirma.p (INPUT "",
                                      OUTPUT aux_confirma).

               IF   aux_confirma <> "S"    THEN
                    LEAVE.
                   
               RUN sistema/generico/procedures/b1wgen0006.p
                                    PERSISTEN SET h-b1wgen0006.
                
               RUN efetuar-resgate IN h-b1wgen0006 (INPUT glb_cdcooper,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT aux_cdoperad,
                                                    INPUT glb_nmdatela,
                                                    INPUT 1, /* Origem */
                                                    INPUT tel_nrdconta,
                                                    INPUT 1, /* Titular */
                                                    INPUT par_nrctrrpp,
                                                    INPUT glb_dtmvtolt,
                                                    INPUT glb_dtmvtopr,
                                                    INPUT tel_tpresgat,
                                                    INPUT tel_vlresgat,
                                                    INPUT tel_dtresgat,
                                                    INPUT tel_flgctain,
                                                    INPUT TRUE,
                                                    OUTPUT TABLE tt-erro).
               DELETE PROCEDURE h-b1wgen0006.

               IF   RETURN-VALUE <> "OK"   THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF   AVAIL tt-erro   THEN
                             MESSAGE tt-erro.dscritic.

                        NEXT.

                    END.
                                               
               LEAVE.

            END.  /*  Fim do DO WHILE  */

            HIDE FRAME f_resgate.
            
        END.  /*  Fim Opcao 'R'esgate  */
   ELSE 
   IF   aux_cddopcao = "C" OR   /* Cancelar */
        aux_cddopcao = "P" THEN /* Proximos */
        RUN fontes/rdcapp_g2.p  (INPUT  aux_cddopcao,
                                 INPUT  tel_nrdconta,
                                 INPUT  par_nrctrrpp,
                                 OUTPUT aux_flgconsl).
                                 
   HIDE FRAME f_opcao.
   
END.  /*    Fim do DO WHILE    */         
         
/* .......................................................................... */

