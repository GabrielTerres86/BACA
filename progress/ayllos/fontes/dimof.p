/* ..........................................................................

   Programa: Fontes/dimof.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Novembro/2008                    Ultima atualizacao: 07/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela DIMOF
   
   Alteracoes: 04/12/2013 - Inclusao de VALIDATE crapsol (Carlos)
   
               07/01/2015 - Criar solicitacao com ano em 4 digitos (DD/MM/YYYY) 
                            no parametro crapsol.dsparam (David).
                
............................................................................. */

{includes/var_online.i}

DEF  VAR aux_dtperiod AS DATE FORMAT "99/99/9999"   NO-UNDO.
DEF  VAR aux_anoperio AS INTE FORMAT "9999"         NO-UNDO.
DEF  VAR aux_cddopcao AS CHAR                       NO-UNDO.

DEF  VAR aux_confirma AS LOGI FORMAT "S/N"          NO-UNDO.
DEF  VAR aux_flgsenha AS LOGI                       NO-UNDO.
DEF  VAR aux_cdoperad AS CHAR                       NO-UNDO.

DEF  VAR aux_contador AS INTE                       NO-UNDO.
DEF  VAR aux_dscritic AS CHAR                       NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     "Opcao:"           AT 5
     glb_cddopcao       AT 12 NO-LABEL AUTO-RETURN
                        HELP "Informe a opcao desejada (C), (S) ou (X)."
                        VALIDATE (CAN-DO("C,S,X",glb_cddopcao), 
                                         "014 - Opcao errada.") 
    
     aux_dtperiod       AT 20 
                        LABEL "Data"
                        HELP  "Informe a data de inicio do periodo."
                        
     aux_anoperio       AT 40
                        LABEL "Ano"
                        HELP  "Informe o ano para inicio da consulta."
     WITH OVERLAY NO-BOX NO-LABEL SIDE-LABEL ROW 5 COLUMN 2 FRAME f_dados.
     
DEF QUERY q_dimof FOR crapmof.

DEF BROWSE b_dimof QUERY q_dimof
    DISP crapmof.dtiniper FORMAT "99/99/9999" COLUMN-LABEL "Ini Per"
         crapmof.dtfimper FORMAT "99/99/9999" COLUMN-LABEL "Fim Per"
         crapmof.flgenvio                     COLUMN-LABEL "Status"
         crapmof.dtenvarq FORMAT "99/99/9999" COLUMN-LABEL "Envio Arq"
         crapmof.dtenvpbc FORMAT "99/99/9999" COLUMN-LABEL "Envio ao BC"
    WITH 8 DOWN.

FORM b_dimof HELP "Utilize as SETAS para navegar"
     WITH OVERLAY NO-BOX NO-LABEL SIDE-LABEL ROW 8 COLUMN 10 FRAME f_browse.  

VIEW FRAME f_moldura.
PAUSE (0).

ASSIGN glb_cddopcao = "C".

DO  WHILE TRUE:

    RUN fontes/inicia.p.
    
    DISPLAY glb_cddopcao WITH FRAME f_dados.
    
    HIDE aux_dtperiod aux_anoperio IN FRAME f_dados NO-PAUSE.
    
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
        UPDATE glb_cddopcao WITH FRAME f_dados.
        
        LEAVE.
    END.                     

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN  fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "DIMOF"  THEN
                LEAVE.
            ELSE
                NEXT.
        END.
      
    IF  aux_cddopcao <> glb_cddopcao  THEN
         DO:  
             { includes/acesso.i }
             ASSIGN aux_cddopcao = glb_cddopcao
                    glb_cdcritic = 0.
         END.     
         
    IF  glb_cddopcao <> "C"  THEN
        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
            UPDATE aux_dtperiod WITH FRAME f_dados.
            LEAVE.
        END.
    ELSE
        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
            UPDATE aux_anoperio WITH FRAME f_dados.
            LEAVE.
        END.
        
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN        
        NEXT.
        
    IF  glb_cddopcao = "S"  THEN
        DO:
            /* Critica solicitacao do periodo seguinte */
            IF  aux_dtperiod > DATE(MONTH(glb_dtmvtolt + 6),
                                    DAY(glb_dtmvtolt),
                                    YEAR(glb_dtmvtolt)) THEN
                DO:
                    MESSAGE "Nao permitido solicitar para o periodo seguinte.".
                    NEXT.
                END.
            
            FIND crapmof WHERE crapmof.cdcooper = glb_cdcooper AND
                               crapmof.dtiniper = aux_dtperiod NO-LOCK NO-ERROR.
            
            IF  NOT AVAIL crapmof  THEN
                DO:
                    MESSAGE "Registro de DIMOF para o periodo nao encontrado.".
                    NEXT.
                END.
                                      
            IF  crapmof.flgenvio  THEN
                DO:
                    MESSAGE "Envio do arquivo ja efetuado. Utilize opcao 'X'.".
                    NEXT.
                END.
            
            IF  CAN-FIND(crapsol WHERE crapsol.cdcooper = glb_cdcooper      AND
                                       crapsol.nrsolici = 105               AND
                                       crapsol.dtrefere = crapmof.dtiniper) THEN
                DO:
                    MESSAGE "Solicitacao ja realizada!".
                    NEXT.
                END.
                                        
            ASSIGN aux_confirma = FALSE.

            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                glb_cdcritic = 78.
                RUN fontes/critic.p.
                glb_cdcritic = 0.
                BELL.
                MESSAGE glb_dscritic UPDATE aux_confirma.
                LEAVE.
                
            END.
            
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                NOT aux_confirma THEN
                DO:
                    glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    glb_cdcritic = 0.
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.
            
            /* Cria a solicitacao para rodar o programa no processo noturno */
            DO TRANSACTION:
            
                 CREATE crapsol.
                 ASSIGN crapsol.nrsolici = 105
                        crapsol.dtrefere = glb_dtmvtolt
                        crapsol.nrseqsol = 01
                        crapsol.cdempres = 11
                        crapsol.dsparame = STRING(crapmof.dtiniper,"99/99/9999")
                        crapsol.insitsol = 1                    
                        crapsol.nrdevias = 1
                        crapsol.cdcooper = glb_cdcooper.
                 
                 VALIDATE crapsol.

                 MESSAGE "Operacao efetuada com sucesso!".
            END.
        
        END.
    ELSE
    IF  glb_cddopcao = "X"  THEN
        DO TRANSACTION:

            glb_dscritic = "".
            
            DO  aux_contador = 1 TO 8:
            
                FIND crapmof WHERE crapmof.cdcooper = glb_cdcooper AND
                                   crapmof.dtiniper = aux_dtperiod 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                IF  NOT AVAIL crapmof  THEN
                    DO:
                        IF  LOCKED crapmof  THEN
                            DO:
                               ASSIGN glb_dscritic = "Registro de DIMOF esta " +
                                                     "em uso. " +
                                                     "Tente novamente.".  
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                            END.
                        ELSE
                            DO:
                               ASSIGN glb_dscritic = "Registro de DIMOF para " +
                                                     "o periodo" +
                                                     " nao encontrado.".  
                               NEXT.
                            END.
                    END.
            
            END.
            
            IF  glb_dscritic <> ""  THEN
                DO:
                    MESSAGE glb_dscritic.
                    glb_dscritic = "".
                    NEXT.
                END.
                                      
            IF  NOT crapmof.flgenvio  THEN
                DO:
                    MESSAGE "Operacao ja desfeita.".
                    NEXT.
                END.

            /* Periodo anterior Pede senha do coordenador */
            IF  aux_dtperiod < DATE(MONTH(glb_dtmvtolt - 6),
                                    DAY(glb_dtmvtolt),
                                    YEAR(glb_dtmvtolt)) THEN
                DO:

                    MESSAGE "Peca a liberacao ao Coordenador/Gerente...".
                    PAUSE 2 NO-MESSAGE.

                    RUN fontes/pedesenha.p (INPUT glb_cdcooper,  
                                            INPUT 2, 
                                           OUTPUT aux_flgsenha,
                                           OUTPUT aux_cdoperad).
             
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        NEXT.
                
                    IF  NOT aux_flgsenha  THEN
                        NEXT.
                
                END.
            
            ASSIGN aux_confirma = FALSE.
    
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                ASSIGN glb_cdcritic = 78.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic UPDATE aux_confirma.
                LEAVE.
    
            END.

            IF  KEY-FUNCTION(LASTKEY) = "END-ERROR" OR 
                NOT aux_confirma  THEN
                DO:
                    ASSIGN glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    NEXT.
                END.
            
            ASSIGN crapmof.flgenvio = FALSE.
            
            MESSAGE "Operacao efetuada com sucesso!".
            
        END.
    ELSE
        DO:
            IF  aux_anoperio = 0 THEN
                OPEN QUERY q_dimof  FOR EACH crapmof 
                                       WHERE crapmof.cdcooper = glb_cdcooper 
                                       NO-LOCK.
            ELSE
                OPEN QUERY q_dimof  FOR EACH crapmof
                                       WHERE crapmof.cdcooper = glb_cdcooper AND
                                       YEAR(crapmof.dtiniper) >= aux_anoperio
                                       NO-LOCK.
            
            IF  QUERY q_dimof:NUM-RESULTS = 0  THEN
                DO:
                    CLOSE QUERY q_dimof.
                    BELL.
                    MESSAGE "Nenhum registro de DIMOF encontrado.".
                    NEXT.
                END.
            
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                UPDATE b_dimof WITH FRAME f_browse.

                LEAVE.
            
            END.
            
            CLOSE QUERY q_dimof.

            HIDE FRAME f_browse NO-PAUSE.
        END.    
        
END. /* Fim do DO WHILE TRUE */

/* .......................................................................... */
