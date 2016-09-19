/* ..........................................................................
 
   Programa: fontes/proposta_analise.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Julho/2010                         Ultima atualizacao: 02/12/2014
   
   Dados referente ao programa:
   
   Frequencia: Diario(On-line)
   Objetivo  : Tratar dos campos da analise das propostas de credito.
   
   Alteracoes: 18/08/2014 - Projeto Automatização de Consultas em Propostas
                            de Crédito (Jonata-RKAM).                    
                            
               02/12/2014 - Nao deixar alterar dados do 2. titular
                            (Jonata-RKAM)                                                                        
............................................................................ */
                                    
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen9999tt.i } 
{ sistema/generico/includes/b1wgen0056tt.i }
  
{ includes/var_online.i   } 
{ includes/var_proposta.i }
                             
DEF INPUT PARAM par_cdcooper  AS INTE                               NO-UNDO.
DEF INPUT PARAM par_nrdconta  AS INTE                               NO-UNDO.
DEF INPUT PARAM par_inpessoa  AS INTE                               NO-UNDO.
DEF INPUT PARAM TABLE         FOR tt-itens-topico-rating.
DEF INPUT-OUTPUT PARAM TABLE  FOR tt-dados-analise.


FIND FIRST tt-dados-analise EXCLUSIVE-LOCK NO-ERROR.


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   par_inpessoa = 1   THEN   /* Pessoa fisica */
        DO: 
            tel_nrpatlvr =
                "Patr. pessoal livre        :".

            ASSIGN tt-dados-analise.nrperger:HIDDEN = TRUE.
        END.
   ELSE                           /* Pessoa juridica */
        DO:
            tel_nrpatlvr = 
                "Patr. garant./sócios s/onus:".

            ASSIGN tt-dados-analise.dtoutris:HIDDEN = TRUE
                   tt-dados-analise.vlsfnout:HIDDEN = TRUE. 
        END.
               
   PAUSE 0.

   /* Mostrar as descricoes dos campos */
   DISPLAY tel_nrpatlvr 
           tt-dados-analise.dsgarope 
           tt-dados-analise.dsliquid 
           tt-dados-analise.dspatlvr 
           tt-dados-analise.dsperger
           WITH FRAME f_analise_proposta.

   /* Se possui dados das operacoes financeiras do proprio cooperado */
   IF   tt-dados-analise.flgcentr   THEN
        DISPLAY tt-dados-analise.dtdrisco
                tt-dados-analise.vltotsfn
                tt-dados-analise.qtopescr
                tt-dados-analise.qtifoper
                tt-dados-analise.vlopescr
                tt-dados-analise.vlrpreju
                WITH FRAME f_analise_proposta.

   /* Se possui dados das operacoes financeiras do 2o Tit. / Conjuge */
   IF  tt-dados-analise.flgcoout  AND
       par_inpessoa = 1  THEN
       DISPLAY tt-dados-analise.vlsfnout 
               tt-dados-analise.dtoutris 
               WITH FRAME f_analise_proposta. 

   PAUSE 0.

   DISPLAY tt-dados-analise.dtoutris 
           tt-dados-analise.vlsfnout
           WITH FRAME f_analise_proposta.

   /* Atualizar certos campos se nao tem dados das operacoes financeiras      */
   /* Quando informacoes do proprio cooperado (NOT tt-dados-analise.flgcentr) */

   /* Quando informacoes do 2o Titular / Conjuge */
   /* (NOT tt-dados-analise.flgcoout )*/ 

   UPDATE tt-dados-analise.dtdrisco WHEN NOT tt-dados-analise.flgcentr
          tt-dados-analise.qtopescr WHEN NOT tt-dados-analise.flgcentr
          tt-dados-analise.qtifoper WHEN NOT tt-dados-analise.flgcentr
          tt-dados-analise.vltotsfn WHEN NOT tt-dados-analise.flgcentr
          tt-dados-analise.vlopescr WHEN NOT tt-dados-analise.flgcentr
          tt-dados-analise.vlrpreju WHEN NOT tt-dados-analise.flgcentr                
          tt-dados-analise.nrgarope 
          tt-dados-analise.nrliquid
          tt-dados-analise.nrpatlvr
          tt-dados-analise.nrperger WHEN par_inpessoa = 2
          
          WITH FRAME f_analise_proposta

   EDITING:

     READKEY.

     IF   LASTKEY = KEYCODE("F7")   THEN
          DO:
              /* Atribuir já os valores modificados */
              DO WITH FRAME f_analise_proposta:

                 ASSIGN tt-dados-analise.nrgarope
                        tt-dados-analise.nrliquid
                        tt-dados-analise.nrpatlvr
                        tt-dados-analise.nrperger.
              END.
              
              IF   FRAME-FIELD = "nrgarope"   THEN
                   DO:
                       b-craprad:HELP =
                           "Pressione <ENTER> p/ selecionar a garantia.".
                           
                         IF   par_inpessoa = 1   THEN
                              RUN sequencia_rating
                                     (INPUT 2,
                                      INPUT 2,
                               INPUT-OUTPUT tt-dados-analise.nrgarope,
                               INPUT-OUTPUT tt-dados-analise.dsgarope).
                         ELSE
                              RUN sequencia_rating 
                                     (INPUT 4,
                                      INPUT 2,
                               INPUT-OUTPUT tt-dados-analise.nrgarope,
                               INPUT-OUTPUT tt-dados-analise.dsgarope).
      
                         DISPLAY tt-dados-analise.nrgarope
                                 tt-dados-analise.dsgarope    
                                 WITH FRAME f_analise_proposta.                            
                   END.
              ELSE
              IF   FRAME-FIELD = "nrliquid"   THEN
                   DO:
                       b-craprad:HELP = "Pressione <ENTER> p/ selecionar" +
                              
                                           " a liquidez das garantias.".
            
                       IF   par_inpessoa = 1   THEN
                            RUN sequencia_rating 
                                     (INPUT 2,
                                      INPUT 3,
                               INPUT-OUTPUT tt-dados-analise.nrliquid,
                               INPUT-OUTPUT tt-dados-analise.dsliquid).
                       ELSE
                            RUN sequencia_rating
                                     (INPUT 4,
                                      INPUT 3,
                               INPUT-OUTPUT tt-dados-analise.nrliquid,
                               INPUT-OUTPUT tt-dados-analise.dsliquid).
                  
                       DISPLAY tt-dados-analise.nrliquid
                               tt-dados-analise.dsliquid
                               WITH FRAME f_analise_proposta.
                   END.
              ELSE
              IF   FRAME-FIELD = "nrpatlvr"   THEN
                   DO:  
                       b-craprad:HELP = "Pressione <ENTER> p/ selecionar " +
                                        "o patrimonio pessoal.".
                          
                       IF   par_inpessoa = 1   THEN
                            RUN sequencia_rating 
                                     (INPUT 1,
                                      INPUT 8,
                               INPUT-OUTPUT tt-dados-analise.nrpatlvr,
                               INPUT-OUTPUT tt-dados-analise.dspatlvr).
                       ELSE
                            RUN sequencia_rating
                                     (INPUT 3,
                                      INPUT 9,
                               INPUT-OUTPUT tt-dados-analise.nrpatlvr,
                               INPUT-OUTPUT tt-dados-analise.dspatlvr).
                      
                          DISPLAY tt-dados-analise.nrpatlvr
                                  tt-dados-analise.dspatlvr
                                  WITH FRAME f_analise_proposta.
                   END.
              ELSE
              IF   FRAME-FIELD = "nrperger"   THEN
                   DO:
                       b-craprad:HELP = "Pressione <ENTER> p/ selecionar " +
                                         "a percepcao geral.".
                        
                       RUN sequencia_rating 
                                     (INPUT 3,
                                      INPUT 11,
                               INPUT-OUTPUT tt-dados-analise.nrperger,
                               INPUT-OUTPUT tt-dados-analise.dsperger).
                        
                       DISPLAY tt-dados-analise.nrperger
                               tt-dados-analise.dsperger 
                               WITH FRAME f_analise_proposta.
                   END.
              ELSE
                   APPLY LASTKEY.             
       
          END. /* Fim F7 */
     ELSE
          APPLY LASTKEY.
   
   END. /* Fim do EDITING */ 

   /* Validar campos do RATING */
   RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT SET h-b1wgen0043.

   IF   NOT VALID-HANDLE(h-b1wgen0043)   THEN
        DO:
            MESSAGE "Handle invalido para a BO b1wgen0043.".
            PAUSE 2 NO-MESSAGE.
            NEXT.
        END.

   RUN valida-itens-rating IN h-b1wgen0043 (INPUT  par_cdcooper,
                                            INPUT  0,
                                            INPUT  0,
                                            INPUT  glb_cdoperad,
                                            INPUT  glb_dtmvtolt,
                                            INPUT  par_nrdconta,
                                            INPUT  tt-dados-analise.nrgarope,
                                            INPUT  1, /*(nrinfcad */ 
                                            INPUT  tt-dados-analise.nrliquid,
                                            INPUT  tt-dados-analise.nrpatlvr,
                                            INPUT  tt-dados-analise.nrperger,
                                            INPUT  1, /* Titular */
                                            INPUT  1, /* Ayllos*/
                                            INPUT  glb_nmdatela,
                                            INPUT  FALSE,
                                            OUTPUT TABLE tt-erro).
   DELETE PROCEDURE h-b1wgen0043.

   IF   RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAILABLE tt-erro   THEN
                 MESSAGE tt-erro.dscritic.
            ELSE
                 MESSAGE "Erro na validacao dos campos do Rating.".
            
            PAUSE 2 NO-MESSAGE.
            NEXT.   
        END.

   LEAVE.

END. /* FIM do DO WHILE TRUE */

HIDE FRAME f_analise_proposta.


PROCEDURE sequencia_rating:
                                                                      
    DEF INPUT        PARAM par_nrtopico AS INTE                       NO-UNDO.
    DEF INPUT        PARAM par_nritetop AS INTE                       NO-UNDO.
                                                                      
    DEF INPUT-OUTPUT PARAM par_nrseqite AS INTE                       NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_dssequte AS CHAR                       NO-UNDO.
                                                                      
    DEF VAR                aux_nrdindex AS INTE                       NO-UNDO.

    /* Posicionar no Item entrado */
    ON ENTRY OF b-craprad IN FRAME f_craprad DO: 
                    
       FIND tt-itens-topico-rating WHERE 
            tt-itens-topico-rating.nrtopico = par_nrtopico   AND
            tt-itens-topico-rating.nritetop = par_nritetop   AND
            tt-itens-topico-rating.nrseqite = par_nrseqite
            NO-LOCK NO-ERROR.

       IF   AVAIL  tt-itens-topico-rating THEN
            REPOSITION q-craprad TO ROWID ROWID(tt-itens-topico-rating).

    END.

    ON RETURN OF b-craprad IN FRAME f_craprad DO:

        IF   NOT AVAIL tt-itens-topico-rating THEN
             APPLY "GO".

        ASSIGN par_nrseqite = tt-itens-topico-rating.nrseqite.

        /* Tratamento para o Patrimonio livre */
        IF   (par_nrtopico = 1  AND
              par_nritetop = 8) OR
             (par_nrtopico = 3  AND
              par_nritetop = 9)  THEN
              DO:
                  par_dssequte = REPLACE(tt-itens-topico-rating.dsseqite,"..","").

                  APPLY "GO".
                  
                  RETURN.

              END.

        /* Verifica se tem um '.' na descricao   */
        aux_nrdindex = INDEX(tt-itens-topico-rating.dsseqite,".").  
                 
        IF   aux_nrdindex  >= 1  THEN /* Se tem, pegar ate ele */
             par_dssequte = 
                   SUBSTRING(tt-itens-topico-rating.dsseqite,1,aux_nrdindex).             
        ELSE       
             par_dssequte = tt-itens-topico-rating.dsseqite.

        APPLY "GO".

    END.

    OPEN QUERY q-craprad 
        FOR EACH tt-itens-topico-rating WHERE 
                 tt-itens-topico-rating.nrtopico = par_nrtopico   AND
                 tt-itens-topico-rating.nritetop = par_nritetop   NO-LOCK.
                            
    IF   NUM-RESULTS("q-craprad")  = 0  THEN
         RETURN.
          
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
       UPDATE b-craprad 
              WITH FRAME f_craprad.
       LEAVE.
         
    END.
   
    HIDE FRAME f_craprad.    

END PROCEDURE.


/* ......................................................................... */
