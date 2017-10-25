/* .............................................................................

   Programa: Fontes/tab092.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla  : CRED
   Autor  : Lucas         
   Data   : Fevereiro/2012                       Ultima alteracao: 21/08/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Manipular dados relativos ao Informe de Rendimentos.

   Alteracoes: 13/12/2013 - Alteracao referente a integracao Progress X
                            Dataserver Oracle
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                            
               25/02/2014 - Liberar departamento SUPORTE (Diego).
               
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).    

               07/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                                                        
               21/08/2017 - Adicionado log de alteracoes. (Rafael Faria-Supero')                        
                            
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR aux_cdcooper AS INT                 NO-UNDO.
DEF VAR aux_desccoop AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX               
                        INNER-LINES 11                     NO-UNDO.
DEF VAR aux_dstextab AS CHAR FORMAT "x(50)" NO-UNDO.
DEF VAR aux_ano      AS CHAR FORMAT "9999"  NO-UNDO.
DEF VAR aux_nmrescop AS CHAR FORMAT "x(18)" NO-UNDO.
DEF VAR aux_regrepet AS CHAR                NO-UNDO.
DEF VAR aux_regindis AS CHAR                NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"  NO-UNDO.
DEF VAR aux_msgdelog AS CHAR                NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     glb_cddopcao AT 5 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                        HELP "Entre com a opcao desejada (C,I)."
                        VALIDATE(CAN-DO("C,I",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 5 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_tab092.

FORM SKIP(1)
     aux_desccoop AT 1 LABEL "Coop." FORMAT "x(10)"
     WITH ROW 5 COLUMN 20 OVERLAY SIDE-LABELS NO-BOX NO-LABEL FRAME f_desccoop.
     

FORM SKIP(1)
     aux_ano LABEL "Ano"
            HELP "Informe o ano a ser consultado."
            VALIDATE(NOT CAN-DO("", aux_ano),
                           "Insira um ano.")
     SKIP(1)
     aux_dstextab LABEL "Registro"
     WITH ROW 10 COLUMN 10 OVERLAY SIDE-LABELS NO-BOX NO-LABEL FRAME f_ctab092.


FORM SKIP(1)   
     aux_ano LABEL "Ano"
            HELP "Informe o ano para a inclusão."
            VALIDATE(NOT CAN-DO(" ", aux_ano),
                           "Insira um ano.")
     WITH ROW 10 COLUMN 10 OVERLAY SIDE-LABELS NO-BOX  NO-LABEL FRAME f_itab092.

VIEW FRAME f_moldura. 
PAUSE(0).

RUN fontes/inicia.p. 

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END. 
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        UPDATE glb_cddopcao WITH FRAME f_tab092.
      
        IF  glb_cddepart <> 20   AND  /* TI            */
            glb_cddepart <> 14   AND  /* PRODUTOS      */
            glb_cddepart <>  6   AND  /* CONTABILIDADE */        
            glb_cddopcao <> "C"  THEN
            DO:
               glb_cdcritic = 36.
               RUN fontes/critic.p.
               MESSAGE glb_dscritic.
               PAUSE 2 NO-MESSAGE.
               glb_cdcritic = 0.
               NEXT.
            END.
        LEAVE.
   END. 
                             
   IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO: 
            RUN fontes/novatela.p.
            IF CAPS(glb_nmdatela) <> "TAB092"   THEN
               DO: 
                   HIDE FRAME f_tab092.
                   RETURN.
               END.
            ELSE
               NEXT.
        END.
   
   RUN pi_carrega_cooperativas.

   ON   RETURN OF aux_desccoop
        DO:
            ASSIGN aux_cdcooper = INT(aux_desccoop:SCREEN-VALUE 
                                                IN FRAME f_desccoop).
            APPLY "GO".
        END.

   IF   glb_cddopcao = "C" THEN
        DO:
            
            ASSIGN aux_nmrescop = ""
                   aux_dstextab = ""
                   glb_cddopcao = "C"
                   aux_ano = "".

            DISP aux_desccoop WITH FRAME f_desccoop.
            DISP aux_dstextab aux_ano aux_nmrescop WITH FRAME f_ctab092.
       
            UPDATE  aux_desccoop WITH FRAME f_desccoop.
            UPDATE  aux_ano      WITH FRAME f_ctab092.
			
            ASSIGN aux_msgdelog = "Operador " + STRING(glb_cdoperad) + 
                                  ", Operacao " + glb_cddopcao +
								  ", Coop " + STRING(aux_cdcooper) +
								  ", Ano " + STRING(aux_ano).

            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " + 
			                   STRING(TIME,"HH:MM:SS") + " - " +
							   aux_msgdelog + " >> log/TAB092.log").			
       
            FIND craptab WHERE    craptab.cdcooper = aux_cdcooper  AND         
                                  craptab.nmsistem = "CRED"        AND         
                                  craptab.tptabela = "GENERI"      AND         
                                  craptab.cdempres = 00            AND         
                                  craptab.cdacesso = "IRENDA" + aux_ano  AND
                                  craptab.tpregist = 1
                                  NO-LOCK NO-ERROR.
               
            /* Verifica Disponibilidade da Tabela */
            IF AVAIL craptab THEN
               DO:
                   ASSIGN aux_dstextab = craptab.dstextab.
                   DISP aux_ano aux_dstextab WITH FRAME f_ctab092.
            END.
            ELSE 
               DO:
                   MESSAGE "Registro de " + aux_ano + " não cadastrado.".
                   CLEAR FRAME f_ctab092.
            END.

        END. /* Caso C */
   ELSE 
        DO: 
            CLEAR FRAME f_ctab092.
            HIDE FRAME f_ctab092.
            
            ASSIGN aux_ano = STRING(YEAR(glb_dtmvtolt)).
          
            DISP aux_desccoop WITH FRAME f_desccoop.
          
            UPDATE aux_desccoop WITH FRAME f_desccoop.
            UPDATE aux_ano WITH FRAME f_itab092.    
           
		    ASSIGN aux_msgdelog = "Operador " + STRING(glb_cdoperad) + 
                                  ", Operacao " + glb_cddopcao +
								  ", Coop " + STRING(aux_cdcooper) +
								  ", Ano " + STRING(aux_ano).
		   
            /* Não TODOS */
            IF aux_cdcooper <> 0 THEN
               DO:
          
                   FIND craptab WHERE   craptab.cdcooper = aux_cdcooper        AND         
                                        craptab.nmsistem = "CRED"              AND         
                                        craptab.tptabela = "GENERI"            AND         
                                        craptab.cdempres = 00                  AND         
                                        craptab.cdacesso = "IRENDA" + aux_ano  AND
                                        craptab.tpregist = 1
                                        NO-LOCK NO-ERROR.
                   
                   IF AVAIL craptab THEN
                      DO:
                         MESSAGE "Registro do ano " + aux_ano + " já criado.".
                         CLEAR FRAME f_itab092.
                 
                      END.
                   ELSE 
                      DO:
                         RELEASE craptab.
                       
                          /* Busca registro do ano anterior para alimentar dstextab */
                         FIND craptab WHERE craptab.cdcooper = aux_cdcooper                         AND         
                                            craptab.nmsistem = "CRED"                               AND         
                                            craptab.tptabela = "GENERI"                             AND         
                                            craptab.cdempres = 00                                   AND         
                                            craptab.cdacesso = "IRENDA" + STRING(INT(aux_ano) - 1)  AND
                                            craptab.tpregist = 1
                                            NO-LOCK NO-ERROR.
                       
                         IF  AVAIL craptab THEN
                             DO:
                                 ASSIGN aux_dstextab = craptab.dstextab
                                        aux_confirma = "N".
                                
                                 RUN fontes/confirma.p (INPUT  "",
                                                        OUTPUT aux_confirma).
                                
                                 IF  aux_confirma = "S" THEN
                                     DO:
                                         CREATE  craptab.
                                         ASSIGN  craptab.cdcooper = aux_cdcooper          
                                                 craptab.nmsistem = "CRED"                
                                                 craptab.tptabela = "GENERI"              
                                                 craptab.cdempres = 00                    
                                                 craptab.cdacesso = "IRENDA" + aux_ano
                                                 craptab.tpregist = 1            
                                                 craptab.dstextab = aux_dstextab.
                                         VALIDATE craptab.
										 
										 UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                                                            STRING(TIME,"HH:MM:SS") + " - " +
                                                            aux_msgdelog + " >> log/TAB092.log").

                                         MESSAGE "Registro de " + aux_ano + " criado com sucesso.".
                                         CLEAR FRAME f_itab092.
                                         LEAVE.
                                     END.
                                 ELSE
                                     CLEAR FRAME f_itab092.
                             END.
                        ELSE 
                             DO:
                                 MESSAGE "Registro do ano anterior não disponível.".
                                 CLEAR FRAME f_itab092.
                             END.
                      END.
               END.    
            ELSE   /* TODOS */
               DO:
                   FIND LAST crapcop NO-LOCK.

                   ASSIGN  aux_cdcooper = crapcop.cdcooper
                           aux_confirma = "N".
                 
                   RUN fontes/confirma.p (INPUT  "",
                                          OUTPUT aux_confirma).
                             
                   IF aux_confirma = "S" THEN
                      DO:
                         
                         DO WHILE aux_cdcooper > 0:
                             
                             FIND craptab  WHERE  craptab.cdcooper = aux_cdcooper        AND         
                                                  craptab.nmsistem = "CRED"              AND         
                                                  craptab.tptabela = "GENERI"            AND         
                                                  craptab.cdempres = 00                  AND         
                                                  craptab.cdacesso = "IRENDA" + aux_ano  AND
                                                  craptab.tpregist = 1
                                                  NO-LOCK NO-ERROR.
                                
                             IF  AVAIL craptab THEN
                                 DO: 
                                     ASSIGN aux_cdcooper = aux_cdcooper - 1.
                                     RELEASE craptab.
                                     NEXT.
                                 END.
                             ELSE 
                                 DO:
                                     RELEASE craptab.

                                     /* Busca registro do ano anterior para alimentar dstextab */
                                     FIND craptab WHERE craptab.cdcooper = aux_cdcooper                         AND         
                                                        craptab.nmsistem = "CRED"                               AND         
                                                        craptab.tptabela = "GENERI"                             AND         
                                                        craptab.cdempres = 00                                   AND         
                                                        craptab.cdacesso = "IRENDA" + STRING(INT(aux_ano) - 1)  AND
                                                        craptab.tpregist = 1
                                                        EXCLUSIVE-LOCK NO-ERROR.
                                 
                                     IF  AVAIL craptab THEN
                                         DO:
                                             ASSIGN aux_dstextab = craptab.dstextab.
                                          
                                             CREATE  craptab.
                                             ASSIGN  craptab.cdcooper = aux_cdcooper          
                                                     craptab.nmsistem = "CRED"                
                                                     craptab.tptabela = "GENERI"              
                                                     craptab.cdempres = 00                    
                                                     craptab.cdacesso = "IRENDA" + aux_ano
                                                     craptab.tpregist = 1            
                                                     craptab.dstextab = aux_dstextab.
                                             VALIDATE craptab.

                                         END.

                                     ASSIGN aux_cdcooper = aux_cdcooper - 1.
                                     
                                 END.
                          
                         END.
						 
						 UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + " - " +
                                           STRING(TIME,"HH:MM:SS") + " - " +
                                           aux_msgdelog + " >> log/TAB092.log").
						 
                         MESSAGE "Operação finalizada.".
                         PAUSE 3 NO-MESSAGE.
                          
                         CLEAR FRAME f_itab092.
                         LEAVE.
                          
                      END.
                   ELSE
                      CLEAR FRAME f_itab092.
               END.
                        
        END. /* END opcao I */
END.


PROCEDURE pi_carrega_cooperativas:

    DEFINE VARIABLE aux_nmcooper AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.
    
    FOR EACH crapcop NO-LOCK:
    
        IF glb_cddopcao = "I" AND
           aux_contador = 0   THEN
             ASSIGN aux_nmcooper = "TODAS,0,".

        IF   aux_contador = 0 THEN
             ASSIGN aux_nmcooper = aux_nmcooper + CAPS(crapcop.nmrescop) + "," +
                                                  STRING(crapcop.cdcooper)
                    aux_contador = 1.
        ELSE
              ASSIGN aux_nmcooper = aux_nmcooper           + "," + 
                                    CAPS(crapcop.nmrescop) + "," + 
                                    STRING(crapcop.cdcooper).
    END.

    ASSIGN aux_desccoop:LIST-ITEM-PAIRS IN FRAME f_desccoop = aux_nmcooper.

    RETURN "OK".

END PROCEDURE.
