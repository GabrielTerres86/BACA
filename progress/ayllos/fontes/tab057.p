/*.............................................................................

   Programa: Fontes/tab057.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla  : CRED
   Autor  : Lucas Lunelli 
   Data   : Março/2013                             Ultima alteracao: 19/09/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Manipular sequencial de Arquivos SICREDI.
               Softdesk 48406.
   
   Alteracoes: 23/06/2013 - Incluido campo Seq. Arq. Importacao Debitos
                            (James).
   
               24/09/2013 - Incluir campo Seq. Arq. Atualizacao Consorcios.
                          - Remover campo Seq. Arq. Importacao Debitos.
                            (Lucas R.)
               
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)             
               

.............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                          NO-UNDO.
DEF VAR aux_seqarfat AS INTE  FORMAT "zzzzz9"                       NO-UNDO.
DEF VAR aux_seqtrife AS INTE  FORMAT "zzzzz9"                       NO-UNDO.
DEF VAR aux_seqimpde AS INTE  FORMAT "zzzzz9"                       NO-UNDO.
DEF VAR aux_seqconso AS INTE  FORMAT "zzzzz9"                       NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     glb_cddopcao AT 5 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                        HELP "Entre com a opcao desejada (C,A)."
                        VALIDATE(CAN-DO("C,A",glb_cddopcao),
                                     "014 - Opcao errada.")
     WITH ROW 5 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_tab057.

FORM aux_seqarfat AT 10 LABEL "Seq. Arq. Arrec. Faturas"
     HELP "Entre com sequencial do arq. de Arrecadacao de Faturas."
     SKIP(1)
     aux_seqtrife AT 11 LABEL "Seq. Arq. Trib. Federal"
     HELP "Entre com sequencial do arq. de Tribut. Federal."
     SKIP(1)
     aux_seqconso AT 2 LABEL "Seq. Arq. Atualizacao Consorcios"
     HELP "Entre com o sequencial do arq. de Atualizacao Consorcio."
     WITH ROW 9 COLUMN 10 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_dados.

VIEW FRAME f_moldura. 
PAUSE(0).

RUN fontes/inicia.p. 

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

tab057:
DO WHILE TRUE:
    
    IF  glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END. 

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        UPDATE glb_cddopcao WITH FRAME f_tab057.

        LEAVE.

    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO: 
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "TAB057"   THEN
                DO: 
                    HIDE FRAME f_tab057.
                    RETURN.
                END.
            ELSE
                 NEXT.
         END.

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND         
                       craptab.nmsistem = "CRED"        AND         
                       craptab.tptabela = "GENERI"      AND         
                       craptab.cdempres = 00            AND         
                       craptab.cdacesso = "ARQSICREDI"  AND
                       craptab.tpregist = 00
                       NO-LOCK NO-ERROR.

    IF  glb_cddopcao = "C" THEN
        DO:
            IF  NOT AVAIL craptab THEN
                DO:
                    ASSIGN glb_cdcritic = 55.
                    VIEW FRAME f_dados.
                    NEXT tab057.
                END.
                
            ASSIGN aux_seqarfat = INT(SUBSTR(craptab.dstextab,1,6))
                   aux_seqtrife = INT(SUBSTR(craptab.dstextab,8,6))
                   aux_seqconso = INT(SUBSTR(craptab.dstextab,15,6)).
                   

            DISPLAY aux_seqarfat
                    aux_seqtrife
                    aux_seqconso
                    WITH FRAME f_dados.

        END.    

    IF  glb_cddopcao = "A" THEN
        DO:
            IF  NOT AVAIL craptab THEN
                DO:
                    ASSIGN glb_cdcritic = 55.
                    VIEW FRAME f_dados.
                    NEXT tab057.
                END.

            ASSIGN aux_seqarfat = INT(SUBSTR(craptab.dstextab,1,6))
                   aux_seqtrife = INT(SUBSTR(craptab.dstextab,8,6))
                   aux_seqconso = INT(SUBSTR(craptab.dstextab,15,6)).
                   
            DISPLAY aux_seqarfat
                    aux_seqtrife
                    aux_seqconso
                    WITH FRAME f_dados.

            DO  WHILE TRUE ON ENDKEY UNDO, NEXT tab057:

                UPDATE aux_seqarfat
                       aux_seqtrife
                       aux_seqconso
                       WITH FRAME f_dados.

                ASSIGN aux_confirma = "N".
                RUN fontes/confirma.p (INPUT  "",
                                       OUTPUT aux_confirma).
                
                IF  aux_confirma <> "S" THEN
                    NEXT.
    
                DO TRANSACTION ON ENDKEY UNDO, LEAVE:
    
                    DO aux_contador = 1 TO 10:
    
                        FIND craptab WHERE 
                             craptab.cdcooper = glb_cdcooper  AND         
                             craptab.nmsistem = "CRED"        AND         
                             craptab.tptabela = "GENERI"      AND         
                             craptab.cdempres = 00            AND         
                             craptab.cdacesso = "ARQSICREDI"  AND
                             craptab.tpregist = 00
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                        IF  NOT AVAILABLE craptab THEN
                            IF  LOCKED craptab THEN
                                DO:
                                      RUN sistema/generico/procedures/b1wgen9999.p
			                          PERSISTENT SET h-b1wgen9999.

                                	  RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                									 INPUT "banco",
                                									 INPUT "craptab",
                                									 OUTPUT par_loginusr,
                                									 OUTPUT par_nmusuari,
                                									 OUTPUT par_dsdevice,
                                									 OUTPUT par_dtconnec,
                                									 OUTPUT par_numipusr).
                                
                                	  DELETE PROCEDURE h-b1wgen9999.
                                
                                	  ASSIGN aux_dadosusr = 
                                			 "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                		DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                			MESSAGE aux_dadosusr.
                                			PAUSE 3 NO-MESSAGE.
                                			LEAVE.
                                		END.
                                
                                	   ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                							  " - " + par_nmusuari + ".".
                                
                                		HIDE MESSAGE NO-PAUSE.
                                
                                		DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                			MESSAGE aux_dadosusr.
                                			PAUSE 5 NO-MESSAGE.
                                			LEAVE.
                                		END.
                                
                                		glb_cdcritic = 0.
                                		NEXT.
                                END.
                            ELSE
                                DO:
                                    ASSIGN glb_cdcritic = 55.
                                    LEAVE.
                                END.    
                        ELSE
                            ASSIGN glb_cdcritic = 0.
                       
                        LEAVE.
                       
                    END.  /*  Fim do DO .. TO  */
                       
                    IF  glb_cdcritic > 0 THEN
                        NEXT.
                       
                    ASSIGN craptab.dstextab = STRING(aux_seqarfat,"999999") + " " +
                                              STRING(aux_seqtrife,"999999") + " " +
                                              STRING(aux_seqconso,"999999").
                END.

                LEAVE.

            END.
        END.
END.
