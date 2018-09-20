/* .............................................................................

   Programa: Fontes/identi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 14/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IDENTI - Identificao do usuario perante o sistema.

   Alteracoes: 07/08/95 - Incluida rotina que questiona o usuario se no terminal
                          dele existe uma impressora conectada (Edson).

               21/03/97 - Alterado para emitir mensagem quando a compensacao
                          do Banco do Brasil nao foi integrada no PROCESSO
                          (Edson).

               06/10/98 - Tratar tabela do dolar (Deborah).
               
               19/07/2000 - Mudar o acesso a tabela do dolar (Odair)
               
               23/03/2003 - Alterar faixa de lotes reservados para incluir a 
                            CONCREDI (Junior).
                            
               28/07/2004 - Tratamento para nao abrir a DOLTAB para o 
                            super usuario (Julio)

               10/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               05/02/2007 - Desabilitar alerta sobre cfadastramento do dolar
                            (Julio)

               20/08/2007 - Sair da tela digitando FIM(Mirtes)
                            
               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               02/06/2010 - Alterado para emitir mensagem para todas as 
                            cooperativas (Vitor)

               19/01/2012 - Incluido campo PAC Trabalho (Tiago).
               
               14/08/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                            a escrita ser� PA (Andr� Euz�bio - Supero).

			   23/12/2016 - P341-Automatiza��o BACENJUD - Altera��o para que 
			                o programa passe a utilizar a descri��o do departamento
							da tabela CRAPDPO (Renato Darosci).

			   23/08/2017 - Alteracao referente a validacao do usuario apenas pelo AD.
							Removido campo operador no ambiente de producao.
							Removido campo senha. (PRJ339 - Reinert)

............................................................................. */
{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }

DEF        VAR tel_cdoperad AS CHAR FORMAT "x(10)"                   NO-UNDO.
DEF        VAR tel_cdpactra LIKE crapope.cdpactra                    NO-UNDO.
DEF        VAR tel_cddsenha AS CHAR FORMAT "x(10)"                   NO-UNDO.
DEF        VAR tel_nmdatela AS CHAR FORMAT "x(6)"                    NO-UNDO.

DEF        VAR tel_dsmensag AS CHAR FORMAT "x(78)"                   NO-UNDO.

DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
DEF        VAR aux_dsdepart AS CHAR                                  NO-UNDO.

DEF        VAR aux_dtdoltab AS DATE FORMAT "99/99/9999"              NO-UNDO.

DEF        VAR h-b1wgen0000 AS HANDLE                                NO-UNDO.

FORM SKIP(5)
     tel_cdoperad AT 27 LABEL "Codigo do Operador" AUTO-RETURN
                        HELP "Informe o seu codigo de operador."
     SKIP(1)
     glb_nmdatela AT 33 LABEL "Nome da Tela" AUTO-RETURN
       HELP "Informe o nome da tela desejada ou FIM para sair sistema AYLLOS."
     SKIP(1)
     tel_cdpactra AT 33 LABEL "PA trabalho" AUTO-RETURN
                               HELP "Informe o PA de trabalho do operador."
     SKIP(5)
     tel_dsmensag AT  1 NO-LABEL
     WITH ROW 4 SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80 FRAME f_identi.
     
glb_nmdatela = "".

DO WHILE TRUE ON ENDKEY UNDO, RETRY:

   RUN fontes/inicia.p.
 
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "CONFIG"       AND
                      craptab.cdempres = glb_cdcooper   AND
                      craptab.cdacesso = "CONVTALOES"   AND
                      craptab.tpregist = 001            NO-LOCK NO-ERROR.
 
   IF   NOT AVAILABLE craptab   THEN
        DO:
            glb_cdcritic = 652.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 5 NO-MESSAGE.
            QUIT.
        END.
        
   IF   INT(craptab.dstextab) > 0   THEN
        DO:

            FIND crapban WHERE crapban.cdbccxlt = INT(craptab.dstextab)
                               NO-LOCK NO-ERROR.
                               
            IF   NOT AVAILABLE crapban   THEN
                 DO:
                     glb_cdcritic = 57.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic "-" STRING(craptab.dstextab,"x(3)") .
                     PAUSE 5 NO-MESSAGE.
                     QUIT.
                 END.
/*** Magui em 21/12/2005 a compe entrou com nrdolote 7041 correto 7030 ***/
            
            FIND FIRST craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                                     craplot.dtmvtolt = glb_dtmvtoan       AND
                                     craplot.cdagenci = 1                  AND
                                     craplot.cdbccxlt = crapban.cdbccxlt   AND
                                    (craplot.nrdolote > 7000               AND
                                     craplot.nrdolote < 7042)              AND
                                     craplot.tplotmov = 1 
                                     NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craplot   THEN
                 DO:
                     FIND FIRST craplot WHERE 
                                craplot.cdcooper = glb_cdcooper       AND
                                craplot.dtmvtolt = glb_dtmvtolt       AND
                                craplot.cdagenci = 1                  AND
                                craplot.cdbccxlt = crapban.cdbccxlt   AND
                               (craplot.nrdolote > 7000               AND
                                craplot.nrdolote < 7042)              AND
                                craplot.tplotmov = 1 
                                NO-LOCK NO-ERROR.

                     IF   AVAILABLE craplot   THEN
                          tel_dsmensag = " COMPENSACAO " +
                          /*
                                         SUBSTR(crapban.nmresbcc,1,16) +
                          */  
                                          " REF. " +
                                         STRING(glb_dtmvtoan,"99/99/9999") +
                                         " OK! LISTE NEGATIVOS (IMPREL)".
                     ELSE
                          tel_dsmensag = "---> COMPENSACAO " +
                           /* 
                                         SUBSTR(crapban.nmresbcc,1,16) +
                           */  
                                          " REF. " +
                                         STRING(glb_dtmvtoan,"99/99/9999") +
                                         " NAO ESTA INTEGRADA  <---".
                 END.
            ELSE
                 tel_dsmensag = "".
        END.
        
   IF   tel_dsmensag <> "" THEN
        DO:
            tel_dsmensag = FILL(" ",INT((78 - LENGTH(tel_dsmensag)) / 2)) +
                           tel_dsmensag.
            
            COLOR DISPLAY MESSAGE tel_dsmensag WITH FRAME f_identi.
            DISPLAY tel_dsmensag WITH FRAME f_identi.
        END.

   /* Ambiente de producao nao informa operador*/
   IF TRIM(OS-GETENV("PKGNAME")) = "pkgprod" THEN                
      DO:
         ASSIGN tel_cdoperad = OS-GETENV("USER").
         DISPLAY tel_cdoperad WITH FRAME f_identi.

         UPDATE glb_nmdatela 
                tel_cdpactra WITH FRAME f_identi
         EDITING:

            IF FRAME-FIELD = "tel_cdpactra" AND 
               CAN-DO("RETURN,CURSOR-DOWN,TAB",KEYFUNCTION(LASTKEY)) THEN
               DO:
                  RUN sistema/generico/procedures/b1wgen0000.p 
                      PERSISTENT SET h-b1wgen0000.

            IF NOT VALID-HANDLE(h-b1wgen0000)  THEN
               MESSAGE "Handle invalido h-b1wgen0000".

            RUN consulta-pac-ope IN h-b1wgen0000
                                  (INPUT  glb_cdcooper,
                                   INPUT  1,
                                   INPUT  0,
                                   INPUT  INPUT tel_cdoperad,
                                   INPUT  0,
                                   OUTPUT tel_cdpactra).

            DELETE PROCEDURE h-b1wgen0000. 

            DISPLAY tel_cdpactra WITH FRAME f_identi.    
         END.

      aux_stimeout = 0.

      DO WHILE TRUE:

         READKEY PAUSE 1.

         IF   LASTKEY = -1   THEN
              DO:
                  aux_stimeout = aux_stimeout + 1.

                  IF   aux_stimeout > glb_stimeout  THEN
                       QUIT.

                  NEXT.
              END.

         APPLY LASTKEY.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

         END.  /*  Fim do EDITING  */                
      END.
   ELSE
      DO:
         UPDATE tel_cdoperad  
                glb_nmdatela 
                tel_cdpactra WITH FRAME f_identi            
         EDITING:
         
            IF FRAME-FIELD = "glb_nmdatela" AND 
               CAN-DO("RETURN,CURSOR-DOWN,TAB",KEYFUNCTION(LASTKEY)) THEN
               DO:
                  RUN sistema/generico/procedures/b1wgen0000.p 
                      PERSISTENT SET h-b1wgen0000.

                  IF NOT VALID-HANDLE(h-b1wgen0000)  THEN
                     MESSAGE "Handle invalido h-b1wgen0000".
                                   
                  RUN consulta-pac-ope IN h-b1wgen0000
                                        (INPUT  glb_cdcooper,
                                         INPUT  1,
                                         INPUT  0,
                                         INPUT  INPUT tel_cdoperad,
                                         INPUT  0,
                                         OUTPUT tel_cdpactra).

                  DELETE PROCEDURE h-b1wgen0000. 

                  DISPLAY tel_cdpactra WITH FRAME f_identi.    
               END.

            aux_stimeout = 0.

            DO WHILE TRUE:

               READKEY PAUSE 1.

               IF   LASTKEY = -1   THEN
                    DO:
                        aux_stimeout = aux_stimeout + 1.

                        IF   aux_stimeout > glb_stimeout  THEN
                             QUIT.

                        NEXT.
                    END.

               APPLY LASTKEY.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

         END.  /*  Fim do EDITING  */
      END.


   IF  glb_nmdatela = "FIM" THEN LEAVE.
   
   
   FIND crapope WHERE crapope.cdcooper = glb_cdcooper  AND
                      crapope.cdoperad = tel_cdoperad  NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapope   THEN
        DO:
            glb_cdcritic = 67.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   IF   crapope.cdsitope <> 1   THEN
        DO:
            glb_cdcritic = 627.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   IF   NOT CAN-DO("1,3",STRING(crapope.tpoperad))   THEN
        DO:
            glb_cdcritic = 36.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.
   
   RUN sistema/generico/procedures/b1wgen0000.p PERSISTENT SET h-b1wgen0000.
   
   IF  NOT VALID-HANDLE(h-b1wgen0000)  THEN
        DO:
          MESSAGE "Handle invalido h-b1wgen0000".
        END.
   
   RUN valida-pac-trabalho IN h-b1wgen0000
                                  (INPUT glb_cdcooper,
                                   INPUT 1,
                                   INPUT 0,
                                   INPUT tel_cdoperad,
                                   INPUT 0,
                                   INPUT tel_cdpactra,
                                   INPUT ?,
                                   OUTPUT TABLE tt-erro). 

   IF  RETURN-VALUE = "NOK"  THEN
       DO:
           DELETE PROCEDURE h-b1wgen0000. 

           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                       
           IF  AVAILABLE tt-erro  THEN
               ASSIGN glb_dscritic = tt-erro.dscritic.
            
           BELL.
           MESSAGE glb_dscritic.                        
           NEXT-PROMPT tel_cdpactra WITH FRAME f_identi.
           NEXT.
       END.
        
   DELETE PROCEDURE h-b1wgen0000.
   
   /* LOCALIZAR DSDEPART COM BASE NO CDDEPART DO OPERAD */
    FIND FIRST crapdpo
         WHERE crapdpo.cdcooper = glb_cdcooper
           AND crapdpo.cddepart = crapope.cddepart
       NO-LOCK NO-ERROR.

   IF   AVAILABLE crapdpo   THEN
       ASSIGN aux_dsdepart = crapdpo.dsdepart.
   ELSE
       ASSIGN aux_dsdepart = "".

   { includes/termimpr.i }          /*  Verifica se tem impressora conectada  */
 
   ASSIGN glb_nmtelant = glb_nmdatela
          glb_nmdatela = CAPS(glb_nmdatela)
          glb_cdoperad = crapope.cdoperad
		  glb_cddepart = crapope.cddepart 
          glb_dsdepart = aux_dsdepart
          glb_nmoperad = crapope.nmoperad
          glb_cdagenci = tel_cdpactra
          aux_dtdoltab = ?.

   HIDE FRAME f_identi   NO-PAUSE.

   RETURN.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

