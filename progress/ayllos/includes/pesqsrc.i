/* .............................................................................

   Programa: includes/pesqsrc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson  (Guilherme)
   Data    : Outubro/92.    (Maio/2007)        Ultima atualizacao: 12/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de pesquisa por numero da tela PESQSR.

   Alteracoes: 29/05/2007 - Alterado de pesqbbn.i para pesqsrn.i com suas 
                            respectivas, frames e nomes (Guilherme).
               28/06/2007 - Efetuado acerto critica (Mirtes)
               
               05/11/2007 - Alimentar tel_nmdsecao do ttl.nmdsecao(Guilherme).

               22/02/2008 - Valor tel_cdturnos a partir de ttl.cdturnos
                            (Gabriel).
                            
               15/07/2010 - Incluir historicos 524 e 572 (Guilherme).
               
               27/08/2010 - Incluir tratamento da Compe 085 - ABBC (Ze).
               
               23/09/2010 - Incluir o historico 621 (Ze).
               
               01/07/2014 - Incluir campo "Age.Acl." na "ORIGEM DO LANCAMENTO".
                            (Reinert)
                            
               18/09/2014 - Integracao cooperativas 4 e 15 (Vanessa)
               
               12/08/2015 - Projeto Reformulacao cadastral
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

   UPDATE tel_nrdocmto 
          tel_nrdctabb 
          tel_cdbaninf WITH FRAME f_pesqsr.

   glb_nrcalcul = tel_nrdocmto.

   RUN fontes/digfun.p.

   IF   NOT glb_stsnrcal   THEN
        DO:
            glb_cdcritic = 8.
            NEXT-PROMPT tel_nrdocmto WITH FRAME f_pesqsr.
            NEXT.
        END.

   glb_nrcalcul = tel_nrdctabb.
   
   RUN fontes/digfun.p.

   IF   NOT glb_stsnrcal   THEN
        DO:
            glb_cdcritic = 8.
            NEXT-PROMPT tel_nrdctabb WITH FRAME f_pesqsr.
            NEXT.
        END.

   ASSIGN tel_dtmvtolt = ?
          tel_cdagenci = 0
          tel_cdbccxlt = 0
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
          tel_cdagetfn = 0
          aux_flgretor = FALSE
          aux_regexist = FALSE
          aux_ctamigra = FALSE.


   /* verifica se a conta base eh conta integracao */
   ASSIGN aux_ctpsqitg = tel_nrdctabb.
   RUN existe_conta_integracao.

   RUN fontes/digbbx.p (INPUT  tel_nrdctabb,
                        OUTPUT glb_dsdctitg,
                        OUTPUT glb_stsnrcal).
  
   IF   NOT glb_stsnrcal   THEN
        DO:
            MESSAGE "DIGITO ERRADO".
            NEXT.
        END.

   glb_nrchqsdv = INT(SUBSTR(STRING(tel_nrdocmto,"9999999"),1,6)).

   IF   tel_cdbaninf = 756   THEN
        ASSIGN tel_cdagechq = crapcop.cdagebcb.
   ELSE
        IF  tel_cdbaninf = 85 THEN
            DO:
                ASSIGN tel_cdagechq = crapcop.cdagectl.
    
                /*VERIFICA SE É CONTA MIGRADA*/
                FIND FIRST craptco WHERE craptco.cdcooper = glb_cdcooper AND 
                                         craptco.nrctaant = tel_nrdctabb AND
                                         craptco.flgativo = TRUE 
                                         NO-LOCK NO-ERROR.
                IF   AVAILABLE craptco  THEN
                     DO:
                         IF  craptco.cdcopant = 4 OR craptco.cdcopant = 15 THEN
                             DO:
                                 ASSIGN aux_ctamigra = TRUE. 
                                
                                 /* PESQUISA A AGENCIA DA CONTA MIGRADA*/
                                 FIND crapcop WHERE 
                                      crapcop.cdcooper = craptco.cdcopant 
                                      NO-LOCK NO-ERROR.
                             END.
                     END.
            END.
        ELSE
             ASSIGN tel_cdagechq = crapcop.cdageitg.
            
   IF aux_ctamigra  THEN
       DO:
           FIND crapfdc WHERE (crapfdc.cdcooper = glb_cdcooper AND /*PESQUISA COM AS DUAS AGENCIAS*/
                              crapfdc.cdbanchq = tel_cdbaninf  AND
                              (crapfdc.cdagechq = tel_cdagechq OR
                               crapfdc.cdagechq = crapcop.cdagectl)   AND
                              crapfdc.nrctachq = tel_nrdctabb         AND
                              crapfdc.nrcheque = glb_nrchqsdv)
                             
                              NO-LOCK NO-ERROR.
      END.
      
   ELSE
         
       FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                      crapfdc.cdbanchq = tel_cdbaninf   AND
                      crapfdc.cdagechq = tel_cdagechq   AND
                      crapfdc.nrctachq = tel_nrdctabb   AND
                      crapfdc.nrcheque = glb_nrchqsdv
                      USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
       
   IF   NOT AVAILABLE crapfdc   THEN
        DO:
            glb_cdcritic = 244.
            NEXT.
        END.

   ASSIGN tel_nrdconta = crapfdc.nrdconta
          tel_cdagechq = crapfdc.cdagechq.

   FIND crapass WHERE crapass.cdcooper = crapfdc.cdcooper AND
                      crapass.nrdconta = crapfdc.nrdconta NO-LOCK NO-ERROR.
  
   IF   NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 9.
            NEXT.
        END.

   ASSIGN tel_nmprimtl = crapass.nmprimtl
          tel_nrfonemp = crapass.nrfonemp
          tel_nrramemp = crapass.nrramemp.

   FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND
                      crapttl.nrdconta = crapass.nrdconta AND
                      crapttl.idseqttl = 1  NO-LOCK NO-ERROR.
   
   IF   AVAILABLE crapttl   THEN
        ASSIGN  tel_cdturnos = crapttl.cdturnos.
   
   ELSE
        ASSIGN tel_cdturnos = 0. 
   
   FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                      crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapage   THEN
        tel_dsagenci = STRING(crapass.cdagenci,"zz9") + " - " + FILL("*",15).
   ELSE
        tel_dsagenci = STRING(crapass.cdagenci,"zz9") + " - " +
                       crapage.nmresage.
   /*
   IF   CAN-DO("0,1,2",STRING(crapfdc.incheque))   THEN
        glb_cdcritic = 99.
   ELSE
   */
   IF   crapfdc.incheque = 8   THEN
        glb_cdcritic = 320.
   ELSE
   IF   CAN-DO("0,1,2,5,6,7",STRING(crapfdc.incheque))   THEN
        DO:
            MESSAGE "Aguarde... Lendo lancamentos!".
            PAUSE 1 NO-MESSAGE.

           glb_cdcritic = IF crapfdc.incheque = 5
                              THEN 97
                              ELSE IF crapfdc.incheque = 6
                                      THEN 96
                                      ELSE 257.

            FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND 
                                   craplcm.nrdconta = crapass.nrdconta   AND
                                   craplcm.nrdocmto = tel_nrdocmto       AND
                                  (craplcm.cdhistor = 50   OR
                                   craplcm.cdhistor = 56   OR
                                   craplcm.cdhistor = 59   OR
                                   craplcm.cdhistor = 21   OR
                                   craplcm.cdhistor = 26   OR
                                   craplcm.cdhistor = 313  OR
                                   craplcm.cdhistor = 524  OR
                                   craplcm.cdhistor = 572  OR
                                   craplcm.cdhistor = 340  OR
                                   craplcm.cdhistor = 521  OR
                                   craplcm.cdhistor = 526  OR
                                   craplcm.cdhistor = 621)
                                   USE-INDEX craplcm2 
                                   NO-LOCK ON ENDKEY UNDO, LEAVE:

                IF   aux_flgretor   THEN
                     PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".

                ASSIGN tel_dtmvtolt = craplcm.dtmvtolt
                       tel_cdagenci = craplcm.cdagenci
                       tel_cdbccxlt = craplcm.cdbccxlt
                       tel_nrdolote = craplcm.nrdolote
                       tel_vllanmto = craplcm.vllanmto
                       tel_cdpesqbb = craplcm.cdpesqbb
                       tel_nrseqimp = craplcm.nrseqdig 
                       tel_vldoipmf = DEC(TRUNC(crapfdc.vlcheque * 0.0038 , 2))
                       tel_cdbanchq = STRING(craplcm.cdbanchq,"zzz9") + "-" +
                                      STRING(craplcm.cdagechq,"9999")
                       tel_sqlotchq = craplcm.sqlotchq
                       tel_cdcmpchq = craplcm.cdcmpchq
                       tel_nrlotchq = craplcm.nrlotchq
                       tel_nrctachq = craplcm.nrctachq
                       tel_cdagetfn = IF craplcm.cdcoptfn <> 0 THEN 
                                         aux_cdagectl[craplcm.cdcoptfn] 
                                      ELSE
                                          0
                       aux_flgretor = TRUE
                       aux_regexist = TRUE. 


                HIDE MESSAGE NO-PAUSE.

                COLOR DISPLAY MESSAGES tel_dscritic WITH FRAME f_pesqsr.

                DISPLAY glb_cddopcao tel_nrdocmto tel_nrdctabb
                        tel_nmprimtl tel_dsagenci 
                        tel_cdturnos tel_nrfonemp tel_nrramemp
                        tel_dscritic tel_dtmvtolt tel_cdagenci
                        tel_cdbccxlt tel_nrdolote tel_nrdconta
                        tel_vllanmto tel_cdpesqbb tel_nrseqimp
                        tel_vldoipmf tel_cdagetfn tel_cdbanchq 
                        tel_sqlotchq tel_cdcmpchq tel_nrlotchq 
                        tel_nrctachq tel_cdagechq WITH FRAME f_pesqsr.

            END.  /*  Fim do FOR EACH  */

            IF   NOT aux_regexist   THEN
                 glb_cdcritic = 242.
        END.
   ELSE
        DO:
            glb_cdcritic = 127.
            NEXT-PROMPT tel_nrdctabb WITH FRAME f_pesqsr.
            NEXT.
        END.

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
   
   DISPLAY glb_cddopcao tel_nrdocmto tel_nrdctabb tel_nmprimtl
           tel_dsagenci tel_cdturnos tel_nrfonemp
           tel_nrramemp tel_dscritic tel_dtmvtolt tel_cdagenci
           tel_cdbccxlt tel_nrdolote tel_nrdconta tel_vllanmto
           tel_cdpesqbb tel_nrseqimp tel_vldoipmf tel_cdagetfn
           tel_cdbanchq tel_sqlotchq tel_cdcmpchq tel_nrlotchq 
           tel_nrctachq tel_cdagechq
           WITH FRAME f_pesqsr.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */


