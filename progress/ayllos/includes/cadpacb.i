/* .............................................................................

   Programa: Includes/cadpacb.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes   
   Data    : Marco/2004                      Ultima Atualizacao: 15/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao de Boletim de Caixa da tela 
               CADPAC(Cadastramento de PAC)

   Alteracoes: 08/11/2004 - Nao permitir data de criacao de novo caixa
                            maior ou igual a atual (Margarete).

               03/05/2005 - Incluido cod. Cooperativa(Mirtes). 
               
               03/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)  
                            
               15/01/2014 - Alterada critica "15 - Agencia nao cadastrada" para
                            "962 - PA nao cadastrado". (Reinert)
............................................................................. */

FIND crapage WHERE crapage.cdcooper = glb_cdcooper    AND
                   crapage.cdagenci = tel_cdagenci    NO-LOCK NO-ERROR NO-WAIT.
                    
IF   NOT AVAILABLE crapage   THEN
     DO:
         glb_cdcritic = 962.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_pac.
         DISPLAY  tel_cdagenci WITH FRAME f_pac.
         NEXT.
     END.
                             
DO  TRANSACTION ON ENDKEY UNDO, LEAVE:

    ASSIGN tel_nrdcaixa = 0
           tel_cdopecxa = " "
           tel_dtmvtolt = ?.
           
    DISPLAY tel_nrdcaixa
            tel_cdopecxa
            tel_dtmvtolt
            WITH FRAME f_boletim.
           
    SET tel_nrdcaixa
        WITH FRAME f_boletim.
             
    ASSIGN aux_recid = ?.
    
    FIND FIRST crapbcx WHERE crapbcx.cdcooper  = glb_cdcooper    AND
                             crapbcx.dtmvtolt <> ?               AND
                             crapbcx.cdagenci  =  tel_cdagenci   AND
                             crapbcx.nrdcaixa  =  tel_nrdcaixa   AND
                             crapbcx.nrseqdig  > 0 
                             USE-INDEX crapbcx4 NO-LOCK NO-ERROR.

    IF  AVAIL crapbcx THEN
        DO:
           ASSIGN tel_cdopecxa = crapbcx.cdopecxa
                  tel_dtmvtolt = crapbcx.dtmvtolt.
           
           ASSIGN aux_recid = RECID(crapbcx).
           
           DISPLAY tel_cdopecxa
                   tel_dtmvtolt
                   WITH FRAME f_boletim.
        END.

    FIND FIRST craplcx WHERE craplcx.cdcooper  = glb_cdcooper   AND
                             craplcx.dtmvtolt <> ?              AND
                             craplcx.cdagenci  =  tel_cdagenci  AND
                             craplcx.nrdcaixa  =  tel_nrdcaixa 
                             USE-INDEX craplcx3 NO-LOCK NO-ERROR.
    
    IF  AVAIL craplcx THEN
        DO:
           MESSAGE "Boletim em uso. Nao pode ser alterado".
           PROMPT-FOR tel_nrdcaixa  WITH FRAME f_boletim.
           NEXT.
        END.
    
    DO  WHILE TRUE:
                   
        SET    tel_cdopecxa
               tel_dtmvtolt
               WITH FRAME f_boletim.
        
        FIND crapope WHERE crapope.cdcooper = glb_cdcooper  AND
                           crapope.cdoperad = tel_cdopecxa  NO-LOCK NO-ERROR.
                           
        IF  NOT AVAIL crapope THEN
            DO:
               glb_cdcritic = 67.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               PROMPT-FOR tel_cdopecxa WITH FRAME f_boletim.
               NEXT.
            END.
        IF  tel_dtmvtolt = ? THEN
            DO:
               glb_cdcritic = 13.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               PROMPT-FOR tel_dtmvtolt WITH FRAME f_boletim.
               NEXT.
            END.

        IF  tel_dtmvtolt >= glb_dtmvtolt   THEN
            DO:
               glb_cdcritic = 13.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               PROMPT-FOR tel_dtmvtolt WITH FRAME f_boletim.
               NEXT.
            END.
        
        LEAVE.

    END.

    IF  aux_recid <> ? THEN
        DO:

           FIND crapbcx WHERE RECID(crapbcx) = aux_recid 
                              EXCLUSIVE-LOCK NO-ERROR.
        END.
    ELSE
        DO:
           CREATE crapbcx.
           ASSIGN crapbcx.cdagenci  = tel_cdagenci
                  crapbcx.cdopecxa  = tel_cdopecxa
                  crapbcx.nrdcaixa  = tel_nrdcaixa
                  crapbcx.cdsitbcx  = 2 /* Fechado */
                  crapbcx.nrdlacre  = crapbcx.nrdcaixa
                  crapbcx.nrdmaqui  = crapbcx.nrdcaixa
                  crapbcx.nrseqdig  = 1
                  crapbcx.cdcooper  = glb_cdcooper.
          
       END.
    
    ASSIGN crapbcx.cdopecxa = tel_cdopecxa
           crapbcx.dtmvtolt = tel_dtmvtolt.
    
    VALIDATE crapbcx.
END. /* Fim da transacao */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_boletim NO-PAUSE.

/* .......................................................................... */


