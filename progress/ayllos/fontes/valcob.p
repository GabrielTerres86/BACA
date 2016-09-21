/* ............................................................................

   Programa: Fontes/valcob.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Setembro/2007                    Ultima atualizacao: 25/03/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Validar arquivos de cobranca.

   Alteracoes: 03/06/2009 - Alterado programa retirar as regras de negocio e 
                            implementando na BO B1wgen0010. 
                            (Sidnei - Precise IT)
                            
               15/07/2009 - Alteracao CDOPERAD
                          - Converter arquivo na importacao "dos2ux" (Diego).
                          
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).    
   
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0010tt.i }

DEF STREAM str_2.

DEF BUFFER crabcco FOR crapcco.

DEF        VAR aux_dscriti1 AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR aux_dscriti2 AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR aux_erronume AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nmprimtl AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrcnvcob AS INT                                   NO-UNDO.
DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_dsdoccop LIKE crapcob.dsdoccop                    NO-UNDO.
DEF        VAR aux_contaerr AS INT                                   NO-UNDO.
DEF        VAR aux_contalin AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nmarqint AS CHAR                                  NO-UNDO.

DEF        VAR tel_nmarqint AS CHAR    FORMAT "x(68)"                NO-UNDO.
DEF        VAR tel_dsdopcao AS LOGICAL FORMAT "Arquivo/Tela"         NO-UNDO.
DEF        VAR tel_diretori AS CHAR    FORMAT "x(50)"                NO-UNDO.

DEF        VAR h-b1wgen0010 AS HANDLE                                NO-UNDO.

FORM SKIP(1)
     glb_cddopcao  AT  2  LABEL "Opcao"
                          HELP "Informe a opcao desejada (I)"
                          VALIDATE(CAN-DO("I",glb_cddopcao),
                                   "014 - Opcao errada.")
     WITH ROW 4 OVERLAY DOWN WIDTH 80 TITLE glb_tldatela SIDE-LABELS 
     FRAME f_moldura.


FORM "Nome do arquivo a ser validado:" AT 5
     SKIP(1)
     tel_nmarqint   AT 5  NO-LABEL
        HELP  "Informe o diretorio do arquivo para validar as informacoes."
        VALIDATE(INPUT tel_nmarqint <> "", "375 - O campo deve ser preenchido.")
     WITH WIDTH 78 OVERLAY ROW 8 CENTERED SIDE-LABELS NO-BOX 
          FRAME f_importa_arq.
          
FORM SKIP(1)
     tel_dsdopcao LABEL "Visualizar em" 
                  HELP "Informe  (T)ela  ou  (A)rquivo."
     SKIP(2)
     tel_diretori LABEL "Destino" 
     WITH WIDTH 70 COLUMN 6 ROW 12 NO-BOX OVERLAY SIDE-LABELS 
     FRAME f_opcao.
         
VIEW FRAME f_moldura.
PAUSE(0).

ASSIGN glb_cddopcao = "I".

RUN fontes/inicia.p.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      UPDATE glb_cddopcao WITH FRAME f_moldura.
      
      IF   NOT CAN-DO("TI",glb_dsdepart)   THEN
           DO:
               glb_cdcritic = 36.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               NEXT.
           END. 
      
      LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "VALCOB"   THEN
                 DO:
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
        
   
   UPDATE tel_nmarqint WITH FRAME f_importa_arq.

   IF   SEARCH(tel_nmarqint) = ?   THEN
        DO:
            glb_cdcritic = 182.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
            NEXT.  
        END.      
      
   ASSIGN aux_nmarqint = SUBSTRING(tel_nmarqint,1,R-INDEX(tel_nmarqint,".") - 1)
                         + ".TXT".
                               
   UNIX SILENT VALUE("dos2ux " + tel_nmarqint + " > " + aux_nmarqint +
                     " 2> /dev/null").
                     
   RUN sistema/generico/procedures/b1wgen0010.p PERSISTENT SET h-b1wgen0010.

   IF  NOT VALID-HANDLE(h-b1wgen0010)  THEN
       DO:
           BELL.
           MESSAGE "Handle invalido para BO b1wgen0010.".
           PAUSE 3 NO-MESSAGE.
        
           NEXT.
       END.
   ELSE
       DO:
           RUN valida-arquivo-cobranca IN h-b1wgen0010
                                         (INPUT glb_cdcooper,
                                          INPUT aux_nmarqint,
                                          OUTPUT TABLE tt-rejeita).
           DELETE PROCEDURE h-b1wgen0010.
           
           FIND FIRST tt-rejeita NO-LOCK NO-ERROR.
           IF NOT AVAIL tt-rejeita THEN
              DO:
                  MESSAGE "Arquivo encontra-se CORRETO !" VIEW-AS ALERT-BOX.
                  LEAVE.
              END.
           ELSE   
              DO:
                  HIDE tel_diretori IN FRAME f_opcao.
                  UPDATE tel_dsdopcao WITH FRAME f_opcao.   
            
                  IF   tel_dsdopcao  THEN  /* Arquivo  */
                       UPDATE tel_diretori WITH FRAME f_opcao.
              END.
       END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            HIDE FRAME f_opcao.
            NEXT.
        END.
      
   IF   tel_dsdopcao = TRUE  THEN  /* Arquivo */ 
        RUN p_rejeitados (INPUT FALSE).
   ELSE                            /* Tela */
        RUN p_rejeitados (INPUT TRUE).

   /* apaga arquivo */                            
   UNIX SILENT VALUE("rm " + aux_nmarqint + " 2> /dev/null").  

END.  /*  Fim do DO WHILE TRUE  */

/*............................................................................*/

PROCEDURE p_rejeitados.

   DEF INPUT PARAM par_operacao AS LOGICAL                           NO-UNDO.

   DEF VAR aux_dslocali AS CHAR                                      NO-UNDO.
   DEF VAR aux_nmendter AS CHAR                                      NO-UNDO.

   FORM "CRITICAS ARQUIVO DE REMESSA"
        SKIP(1)
        WITH NO-BOX CENTERED FRAME f_titulo.
        
   FORM tt-rejeita.dscritic  FORMAT "x(78)"
        SKIP(1) 
        WITH NO-BOX NO-LABEL FRAME f_critica.

   FORM tt-rejeita.seqdetal  FORMAT "99999" 
        tt-rejeita.dscritic  FORMAT "x(70)"
        SKIP(1) 
        WITH NO-BOX NO-LABEL FRAME f_critica_detalhe.

   INPUT THROUGH basename `tty` NO-ECHO.
   SET aux_nmendter WITH FRAME f_terminal.
   INPUT CLOSE.        
   
   aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                         aux_nmendter.

   UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
   ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

   OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp).

   DISPLAY STREAM str_2 WITH FRAME f_titulo.
   
   FOR EACH tt-rejeita BREAK BY tt-rejeita.cdseqcri:

       IF   tt-rejeita.seqdetal <> ""  THEN         
            DO:
                DISPLAY STREAM str_2 tt-rejeita.seqdetal tt-rejeita.dscritic
                        WITH FRAME f_critica_detalhe.  
                        
                DOWN STREAM str_2 WITH FRAME  f_critica_detalhe. 
            END.
       ELSE 
            DO:
                DISPLAY STREAM str_2 tt-rejeita.dscritic WITH FRAME f_critica. 
                
                DOWN STREAM str_2 WITH FRAME f_critica. 
            END.
                                                     
   END.
   
   OUTPUT STREAM str_2 CLOSE.

   IF   par_operacao  THEN
        RUN visualiza_erros. 
   ELSE
        DO:
            UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + tel_diretori).
            MESSAGE "Arquivo gerado com sucesso !" VIEW-AS ALERT-BOX.
        END.
   
   HIDE FRAME f_opcao.
   
END PROCEDURE.

PROCEDURE visualiza_erros.

DEF VAR edi_ficha   AS CHAR VIEW-AS EDITOR SIZE 80 BY 15 PFCOLOR 0.     

DEF FRAME fra_ficha 
    edi_ficha  HELP "Pressione <F4> ou <END> para finalizar" 
    WITH SIZE 78 BY 15 ROW 6 COLUMN 2 USE-TEXT NO-BOX NO-LABELS OVERLAY.     

PAUSE 0. 

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   ENABLE edi_ficha WITH FRAME fra_ficha.
   DISPLAY edi_ficha WITH FRAME fra_ficha.
   
   ASSIGN edi_ficha:READ-ONLY IN FRAME fra_ficha = TRUE.
  
   IF   edi_ficha:INSERT-FILE(aux_nmarqimp)   THEN
        DO:
            ASSIGN edi_ficha:CURSOR-LINE IN FRAME fra_ficha = 1.
            WAIT-FOR GO OF edi_ficha IN FRAME fra_ficha. 
            
        END.
 
END.

HIDE MESSAGE NO-PAUSE.

ASSIGN edi_ficha:SCREEN-VALUE = "".

CLEAR FRAME fra_ficha ALL.

HIDE FRAME fra_ficha NO-PAUSE.


END PROCEDURE.

/*............................................................................*/
