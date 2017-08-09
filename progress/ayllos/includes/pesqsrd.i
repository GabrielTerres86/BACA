/* .............................................................................

   Programa: includes/pesqsrd.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Junho/2007                      Ultima atualizacao: 19/08/2015
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina da Opcao 'D' da tela PESQSR.

   Alteracoes: 05/11/2007 - Alterado nmdsecao(crapass)p/ttl.nmdsecao 
                            (Guilherme).

               22/02/2008 - Alterado tel_cdturnos a partir de ttl.cdturnos
                            (Gabriel).
                            
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "for each" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               27/08/2010 - Incluir tratamento da Compe 085 - ABBC (Ze).
               
               01/07/2014 - Incluir campo "Age.Acl." na "ORIGEM DO LANCAMENTO".
                            (Reinert)
                            
               19/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
............................................................................. */

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   glb_cdcritic > 0    THEN
        DO:
            CLEAR FRAME f_pesqsr NO-PAUSE.
            DISPLAY glb_cddopcao WITH FRAME f_pesqsr.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   UPDATE tel_dtmvtolt
          tel_nrdconta
          tel_nrdocmto
          WITH FRAME f_pesqsr.

   ASSIGN tel_dtmvtolt = ?
          tel_cdagenci = 0
          tel_cdbccxlt = 0
          tel_cdbaninf = 0
          tel_nrdolote = 0
          tel_vllanmto = 0
          tel_nrseqimp = 0
          tel_vldoipmf = 0
          tel_cdpesqbb = ""
          tel_cdbanchq = ""
          tel_sqlotchq = 0
          tel_cdcmpchq = 0
          tel_nrlotchq = 0
          tel_nrctachq = 0
          tel_cdagechq = 0
          tel_cdbaninf = 0
          tel_cdagetfn = 0
          aux_flgretor = FALSE
          aux_regexist = FALSE.

                       
   FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                      crapass.nrdconta = tel_nrdconta 
                      NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crapass THEN
        DO:
            glb_cdcritic = 9.
            NEXT.
        END.
   
   ASSIGN   tel_nrdctabb_x  = " " 
            tel_nrdctabb    = 0.

   IF   tel_cdbccxlt = 756   OR
        tel_cdbccxlt = 85    THEN
        tel_nrdctabb = crapass.nrdconta.
   ELSE
        tel_nrdctabb_x = crapass.nrdctitg.
   
   /* FIND para alimentacao nmdsecao e cdturnos */
   FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND
                      crapttl.nrdconta = crapass.nrdconta AND
                      crapttl.idseqttl = 1  NO-LOCK NO-ERROR.
   
   IF   AVAILABLE crapttl   THEN
        ASSIGN tel_cdturnos = crapttl.cdturnos.
   ELSE
        ASSIGN tel_cdturnos = 0.
   
   ASSIGN tel_nmprimtl = crapass.nmprimtl
          tel_nrfonemp = crapass.nrfonemp
          tel_nrramemp = crapass.nrramemp.
  
   FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                      crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapage   THEN
        tel_dsagenci = STRING(crapass.cdagenci,"zz9") + " - " + FILL("*",15).
   ELSE
        tel_dsagenci = STRING(crapass.cdagenci,"zz9") + " - " +
                       crapage.nmresage.

   FOR EACH craplcm NO-LOCK WHERE
            craplcm.cdcooper = crapass.cdcooper   AND 
            craplcm.nrdconta = crapass.nrdconta   AND 
            craplcm.nrdocmto = tel_nrdocmto       AND
           (craplcm.cdbccxlt = 1   OR
            craplcm.cdbccxlt = 756 OR
            craplcm.cdbccxlt = 85),
       FIRST craphis NO-LOCK WHERE
             craphis.cdcooper = glb_cdcooper      AND
             craphis.cdhistor = craplcm.cdhistor  AND
             craphis.indebcre = "C"               AND
            (craphis.dshistor MATCHES "*TED*" OR
             craphis.dshistor MATCHES "*TEC*"  OR  
             craphis.dshistor MATCHES "*DOC*")
             ON ENDKEY UNDO, LEAVE:
        IF   aux_flgretor   THEN
             PAUSE MESSAGE
                  "Tecle <Entra> para continuar ou <Fim> para encerrar".
            
                ASSIGN tel_dtmvtolt = craplcm.dtmvtolt
                       tel_cdagenci = craplcm.cdagenci
                       tel_cdbccxlt = craplcm.cdbccxlt
                       tel_cdbaninf = craplcm.cdbccxlt
                       tel_nrdolote = craplcm.nrdolote
                       tel_vllanmto = craplcm.vllanmto
                       tel_cdpesqbb = craplcm.cdpesqbb
                       tel_nrseqimp = craplcm.nrseqdig 
                       tel_vldoipmf = DEC(TRUNC(tel_vllanmto * 0.0038 , 2))
                       tel_cdbanchq = STRING(craplcm.cdbanchq,"zzz9") + "-" +
                                      STRING(craplcm.cdagechq,"9999")
                       tel_sqlotchq = craplcm.sqlotchq
                       tel_cdcmpchq = craplcm.cdcmpchq
                       tel_nrlotchq = craplcm.nrlotchq
                       tel_nrctachq = craplcm.nrctachq
                       aux_flgretor = TRUE
                       aux_regexist = TRUE. 

       RUN fontes/critic.p.

       HIDE MESSAGE NO-PAUSE.

       COLOR DISPLAY MESSAGES tel_dscritic WITH FRAME f_pesqsr.

       IF   tel_cdbccxlt = 756  OR
            tel_cdbccxlt = 85   THEN
            DISPLAY tel_nrdctabb WITH FRAME f_pesqsr.
       ELSE
            DISPLAY tel_nrdctabb_x @ tel_nrdctabb WITH FRAME f_pesqsr.
       
       DISPLAY glb_cddopcao tel_nrdocmto  
               tel_nmprimtl tel_dsagenci 
               tel_cdturnos tel_nrfonemp tel_nrramemp
               tel_dscritic tel_dtmvtolt tel_cdagenci
               tel_cdbaninf
               tel_cdbccxlt tel_nrdolote tel_nrdconta 
               tel_vllanmto tel_cdpesqbb tel_nrseqimp
               tel_vldoipmf tel_cdagetfn tel_cdbanchq 
               tel_sqlotchq tel_cdcmpchq tel_nrlotchq 
               tel_nrctachq WITH FRAME f_pesqsr.

   END.  /*  Fim do FOR EACH  */

   IF   NOT aux_regexist   THEN
        glb_cdcritic = 11.
 
   IF   aux_regexist   THEN
        DO:
            glb_cdcritic = 0.
            NEXT.
        END.
   
   IF  glb_cdcritic > 0 THEN
       DO:
          RUN fontes/critic.p.
          NEXT.
       END.

   HIDE MESSAGE NO-PAUSE.

   COLOR DISPLAY MESSAGES tel_dscritic WITH FRAME f_pesqsr.

   glb_cdcritic = 0.
   
   IF   tel_cdbccxlt = 756  OR
        tel_cdbccxlt = 85   THEN
        DISPLAY tel_nrdctabb WITH FRAME f_pesqsr.
   ELSE
        DISPLAY tel_nrdctabb_x @ tel_nrdctabb WITH FRAME f_pesqsr.
 
    DISPLAY glb_cddopcao tel_nrdocmto  tel_nmprimtl
           tel_dsagenci tel_cdturnos tel_nrfonemp
           tel_nrramemp tel_dscritic tel_dtmvtolt tel_cdagenci
           tel_cdbaninf
           tel_cdbccxlt tel_nrdolote tel_nrdconta tel_vllanmto
           tel_cdpesqbb tel_nrseqimp tel_vldoipmf tel_cdagetfn
           tel_cdbanchq tel_sqlotchq tel_cdcmpchq tel_nrlotchq 
           tel_nrctachq WITH FRAME f_pesqsr.

END.  /*  Fim do DO WHILE TRUE  */
/* .......................................................................... */
