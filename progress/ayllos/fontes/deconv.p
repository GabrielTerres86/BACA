/* .............................................................................

   Programa: Fontes/deconv.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego   
   Data    : Janeiro/2005                     Ultima Atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Imprimir Declaracao/Autorizacao Convenios.

   ALTERACAO : 17/01/2006 - Acrescentada critica referente contas encerradas
                            (Diego).
                            
               10/02/2006 - Unificacao dos bancos - SQLWorks - Eder   
                         
               20/02/2006 - Alterado layout Declaracao (Diego).

               20/11/2006 - Alterado layout da declaracao (Elton).

               18/12/2006 - Efetuado acerto identificador(Mirtes).
               
               22/12/2006 - Alterado label e help da tela (Elton).
               
               24/10/2007 - Alterado o titulo da declaracao (Gabriel).

               07/03/2008 - Incluida opcao por titular da conta (Gabriel).
               
               17/06/2008 - Retirar paragrafo que trata da autorizacao do 
                            Convenio Unimed Litoral (Gabriel).
                          
                          - Alterado para incluir novo convenio para o INPG 
                            (Gabriel). 
               
               22/07/2008 - Alterado para tratar o campo gnconve.flgautdb     
                            (Gabriel)
                            
               28/04/2010 - Alterado o programa para carregar a TT de convenio
                            e incluir a opcao 900 cartao Bradesco Visa (Gati). 
                            
               08/07/2010 - Permitir impressao da declaracao somente para
                            convenios utilizados pela cooperativa (Diego).
                            
               13/05/2011 - Transformar o codigo para usar a BO 0099 (Gabriel)             

               16/04/2012 - Fonte substituido por deconvp.p (Tiago). 
               
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0059tt.i &BD-GEN=SIM }
{ sistema/generico/includes/b1wgen0099tt.i }

    

DEF   VAR tel_nrdconta AS INTE FORMAT "zzzz,zzz,9"                   NO-UNDO.
DEF   VAR tel_nmprimtl AS CHAR FORMAT "x(40)"                        NO-UNDO.
DEF   VAR tel_cdconven LIKE gnconve.cdconven                         NO-UNDO.
DEF   VAR tel_nmempres LIKE gnconve.nmempres                         NO-UNDO.
DEF   VAR tel_idseqttl LIKE crapttl.idseqttl                         NO-UNDO.
                                                                     
DEF   VAR aux_cddopcao AS CHAR                                       NO-UNDO.
DEF   VAR aux_confirma AS CHAR FORMAT "!(1)"                         NO-UNDO.
DEF   VAR aux_nmendter AS CHAR FORMAT "x(20)"                        NO-UNDO.

/* Variaveis Impressao */
DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF   VAR aux_contador AS INTE                                       NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF   VAR aux_flgescra AS LOGI                                       NO-UNDO.
DEF   VAR tel_dsimprim AS CHAR        FORMAT "x(8)" INIT "Imprimir"  NO-UNDO.
DEF   VAR tel_dscancel AS CHAR        FORMAT "x(8)" INIT "Cancelar"  NO-UNDO.
DEF   VAR par_flgfirst AS LOGI        INIT TRUE                      NO-UNDO.
DEF   VAR par_flgrodar AS LOGI        INIT TRUE                      NO-UNDO.
DEF   VAR par_flgcance AS LOGI                                       NO-UNDO.

DEF   VAR par_nmarqpdf AS CHAR                                       NO-UNDO.
DEF   VAR par_qtregist AS INTE                                       NO-UNDO.
DEF   VAR par_nmdcampo AS CHAR                                       NO-UNDO.

DEF   VAR h-b1wgen0059 AS HANDLE                                     NO-UNDO.
DEF   VAR h-b1wgen0099 AS HANDLE                                     NO-UNDO.


DEF QUERY  q_convenio FOR tt-gnconve.

DEF BROWSE b_convenio QUERY q_convenio
      DISP SPACE(5)
           tt-gnconve.cdconven COLUMN-LABEL "Convenio"
           SPACE(1)
           tt-gnconve.nmempres COLUMN-LABEL "Nome"
           WITH 9 DOWN OVERLAY.    

DEF  QUERY q_titulares FOR tt-titulares.

DEF  BROWSE b_titulares QUERY q_titulares
     DISP   tt-titulares.idseqttl
            tt-titulares.nrdconta COLUMN-LABEL "Conta/dv"
            tt-titulares.nmextttl COLUMN-LABEL "Titulares" FORMAT "x(40)"
            WITH 2 DOWN OVERLAY. 


FORM WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela          
          ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY WITH FRAME f_moldura.
                       
FORM SKIP(1)    
     glb_cddopcao LABEL "Opcao"          AT 5
         HELP "Informe  R  para Declaracao."
         VALIDATE(CAN-DO("R", glb_cddopcao),"014 - Opcao errada.")
     SKIP(4)
     SPACE(7)
     tel_cdconven LABEL "Cod.Convenio"  
         HELP "Informe o numero do convenio ou pressione F7 para listar."
                
     tel_nmempres FORMAT "x(20)"
     SKIP
     SPACE(11)
     tel_nrdconta LABEL "Conta/dv"
         HELP "Informe o numero da conta."                  
     SPACE(5)
     tel_idseqttl NO-LABEL
     SPACE(1)
     tel_nmprimtl NO-LABEL FORMAT "x(40)"
     WITH ROW 5 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_convenio.

DEF FRAME f_convenioc
          b_convenio HELP "Use as <SETAS> para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

DEF FRAME f_titulares                                                    
          b_titulares HELP "Use as <SETAS> para navegar e <F4> para sair"
          WITH NO-BOX CENTERED OVERLAY ROW 14.


/* Retorna convenio */    
ON RETURN OF b_convenio DO: 

   IF   NOT AVAILABLE tt-gnconve  THEN
        RETURN.
       
   ASSIGN tel_cdconven = tt-gnconve.cdconven
          tel_nmempres = tt-gnconve.nmempres.
       
   DISPLAY tel_cdconven tel_nmempres WITH FRAME f_convenio.
       
   APPLY "GO".
END.

ON RETURN OF b_titulares DO:
           
    APPLY "GO".

END.   

ON ITERATION-CHANGED, ENTRY OF b_titulares DO:

    ASSIGN  tel_idseqttl = tt-titulares.idseqttl
            tel_nmprimtl = tt-titulares.nmextttl.
       
    DISPLAY tel_idseqttl 
            tel_nmprimtl WITH FRAME f_convenio.
END. 


RUN sistema/generico/procedures/b1wgen0059.p PERSISTENT SET h-b1wgen0059.

RUN busca-gnconve IN h-b1wgen0059 (INPUT glb_cdcooper,
                                   INPUT 0,
                                   INPUT "",
                                   INPUT 999999,
                                   INPUT 1,
                                  OUTPUT par_qtregist,
                                  OUTPUT TABLE tt-gnconve).
DELETE PROCEDURE h-b1wgen0059.


VIEW FRAME f_moldura. 
PAUSE(0). 
ASSIGN glb_cddopcao = "R".

RUN fontes/inicia.p.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
    ASSIGN tel_cdconven = 0
           tel_nmempres = ""
           tel_nrdconta = 0 
           tel_idseqttl = 0
           tel_nmprimtl = "".

    DISPLAY tel_cdconven
            tel_nmempres
            tel_nrdconta
            "" @ tel_idseqttl 
            tel_nmprimtl WITH FRAME f_convenio.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
      UPDATE  glb_cddopcao WITH FRAME f_convenio.
      LEAVE.
        
   END.
      
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "DECONV"   THEN
                 DO:
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
        
   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.  
      
      
   IF   glb_cddopcao = "R"  THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                              
               ASSIGN tel_cdconven = 0
                      tel_nmempres = ""
                      tel_nrdconta = 0 
                      tel_idseqttl = 0
                      tel_nmprimtl = "".

               DISPLAY tel_cdconven
                       tel_nmempres
                       tel_nrdconta
                       "" @ tel_idseqttl 
                       tel_nmprimtl WITH FRAME f_convenio.

               UPDATE tel_cdconven 
                      tel_nrdconta WITH FRAME f_convenio
               
               EDITING:
                       
                  READKEY.
               
                  IF   LASTKEY = KEYCODE("F7")   AND
                       FRAME-FIELD = "tel_cdconven"   THEN
                       DO:
                           HIDE MESSAGE.

                           OPEN QUERY q_convenio FOR EACH tt-gnconve NO-LOCK.
                             
                           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                              UPDATE b_convenio WITH FRAME f_convenioc.
                              LEAVE.
                           END.
                           
                           HIDE FRAME f_convenioc.
                       END.
                  ELSE
                       APPLY LASTKEY.
        
                  IF   GO-PENDING  THEN
                       DO:
                           RUN valida.

                           IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    { sistema/generico/includes/foco_campo.i
                                                  &VAR-GERAL=SIM
                                                  &NOME-FRAME="f_convenio"
                                                  &NOME-CAMPO=par_nmdcampo }   
                                END.

                       END.

               END. /* fim do EDITING */               
               
               DISPLAY tel_nmempres WITH FRAME f_convenio.
               
               FIND FIRST tt-titulares NO-LOCK NO-ERROR.
               
               IF   tt-titulares.inpessoa = 1   THEN   /* Fisica */
                    DO:
                        OPEN QUERY q_titulares FOR EACH tt-titulares. 
                
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           UPDATE b_titulares WITH FRAME f_titulares.
                           LEAVE.
                        END.   
               
                        HIDE FRAME f_titulares.
              
                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                             NEXT.
                    END.
               ELSE     /* Pessoa juridica */
                    DO: 
                        tel_nmprimtl = tt-titulares.nmextttl.
                        
                        DISP tel_nmprimtl WITH FRAME f_convenio.
                    END.
                    
               RUN fontes/confirma.p (INPUT "",
                                     OUTPUT aux_confirma).                   

               IF   aux_confirma <> "S"   THEN
                    NEXT.
                 
               INPUT THROUGH basename `tty` NO-ECHO.
               SET aux_nmendter WITH FRAME f_terminal.
               INPUT CLOSE.
               
               aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                     aux_nmendter. 
                                            
               RUN sistema/generico/procedures/b1wgen0099.p
                   PERSISTENT SET h-b1wgen0099.

               RUN gera-declaracao IN h-b1wgen0099 
                                   (INPUT glb_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT glb_cdoperad,
                                    INPUT glb_nmdatela,
                                    INPUT 1, /* Ayllos*/
                                    INPUT tel_nrdconta,
                                    INPUT tel_idseqttl,
                                    INPUT tel_cdconven,
                                    INPUT aux_nmendter,
                                    INPUT glb_dtmvtolt,
                                    INPUT FALSE,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT aux_nmarqimp,
                                   OUTPUT par_nmarqpdf).
            
               DELETE PROCEDURE h-b1wgen0099.

               IF   RETURN-VALUE <> "OK"   THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF   AVAIL tt-erro   THEN
                             MESSAGE tt-erro.dscritic.
                        ELSE
                             MESSAGE "Erro na impressao da declaracao.".

                        NEXT.
                    END.

               ASSIGN glb_nmformul = "80col".
                        
               FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                        NO-LOCK NO-ERROR.

               { includes/impressao.i }
                   
            END.     

        END.     
END.

PROCEDURE valida.

    /* Pegar os valores digitados na tela */
    DO WITH FRAME f_convenio:
        ASSIGN tel_nrdconta
               tel_cdconven.
    END.

    RUN sistema/generico/procedures/b1wgen0099.p PERSISTENT SET h-b1wgen0099.
               
    RUN valida-traz-titulares IN h-b1wgen0099 (INPUT glb_cdcooper,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT glb_cdoperad,
                                               INPUT glb_nmdatela,
                                               INPUT 1, /* Ayllos*/
                                               INPUT tel_nrdconta,
                                               INPUT tel_cdconven,
                                               INPUT glb_dtmvtolt,
                                               INPUT FALSE,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT par_nmdcampo,
                                              OUTPUT tel_nmempres,
                                              OUTPUT TABLE tt-titulares).
    DELETE PROCEDURE h-b1wgen0099.
                       
    IF   RETURN-VALUE <> "OK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   AVAIL tt-erro   THEN
                 MESSAGE tt-erro.dscritic.
             ELSE
                 MESSAGE "Erro na listagem dos titulares.".

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/* .......................................................................... */


