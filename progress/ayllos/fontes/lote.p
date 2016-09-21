/* .............................................................................

   Programa: Fontes/lote.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                    Ultima atualizacao: 13/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LOTE.

   Alteracoes: 08/06/94 - No tipo de lote 6 permitir que a data do debito seja
                          no maximo 60 dias a partir da data atual.

               22/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               31/07/95 - Alterado para permitir a digitacao dos lote p/agencia
                          (Deborah).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               07/03/01 - Incluido tratamento do boletim caixa (Margarete).
               
             20/09/2001 - Eliminar histor 21 quando 386 (Margarete).

             19/03/2003 - Incluir tratamento da Concredi (Margarete).

             14/03/2005 - Associacao LOTE(opcao "0") Desabilitada(Mirtes).
             
             26/08/2005 - Tratar situacao do PAC (Edson).
         
             27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

             13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada
                          do programa fontes/valida_situacao_pac.p - SQLWorks
                          Fernando.
                          
             19/12/2007 - Possibilitar informar data na consulta(Guilherme).

             18/08/2008 - Alterado para nao permitir exclusao de lotes quando
                          sua data eh diferente ao do banco (Gabriel).
                          
             24/11/2010 - Bloquear opcoes A, E e I quando Banco/Caixa for
                          400 (David).
                            
             15/04/2011 - Nao criticar banco/caixa com crapban (Magui).
             
             26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                          para crapbcl (Adriano).
                          
             15/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)
             
             13/01/2015 - #228483 Retirada a validacao de PA quando a opcao for
                          de consulta ou alteracao (valida_situacao_pac.p) 
                          (Carlos)
             
............................................................................. */

{ includes/var_online.i }

{ includes/var_lote.i "NEW" }

{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0134 AS HANDLE                                       NO-UNDO.

ASSIGN tel_dtmvtolt = glb_dtmvtolt
       glb_cddopcao = "I"
       glb_cdcritic = 0

       glb_cdagenci = 0
       glb_cdbccxlt = 0
       glb_nrdolote = 0.
FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "TAXATABELA"   AND
                   craptab.tpregist = 0              NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     tab_inusatab = FALSE.
ELSE
     tab_inusatab = IF SUBSTRING(craptab.dstextab,1,1) = "0"
                       THEN FALSE
                       ELSE TRUE.

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 1,
                       OUTPUT aux_lsconta1).

/*  Le tabela com as contas convenio do Banco do Brasil - talao transf.*/

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 2,
                       OUTPUT aux_lsconta2).

/*  Le tabela com as contas convenio do Banco do Brasil - chq.salario */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 3,
                       OUTPUT aux_lsconta3).

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DISPLAY tel_dtmvtolt WITH FRAME f_lote.

   NEXT-PROMPT tel_cdagenci WITH FRAME f_lote.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN tel_dtmvtolt = glb_dtmvtolt.

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao WITH FRAME f_lote.
      
      DISPLAY tel_dtmvtolt WITH FRAME f_lote.
      
      IF   glb_cddopcao = "C"   THEN
           UPDATE tel_dtmvtolt WITH FRAME f_lote.

      UPDATE tel_cdagenci tel_cdbccxlt tel_nrdolote WITH FRAME f_lote.

      IF  glb_cddopcao <> "C" AND
          glb_cddopcao <> "A"  THEN
      RUN fontes/valida_situacao_pac.p (INPUT  glb_cdcooper,
                                        INPUT  tel_cdagenci, 
                                        OUTPUT glb_cdcritic).

      IF   glb_cdcritic > 0   THEN
           NEXT.
      
      IF   CAN-DO("11,30,31,500",STRING(tel_cdbccxlt))   AND
           CAN-DO("A,E,I",glb_cddopcao)   AND
           tel_cdagenci <> 11   THEN  /* boletim de caixa -   EDSON PAC1 */ 
           DO:
               IF   glb_cddopcao <> "I"   THEN
                    DO:
             
                        FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                           craplot.dtmvtolt = tel_dtmvtolt   AND
                                           craplot.cdagenci = tel_cdagenci   AND
                                           craplot.cdbccxlt = tel_cdbccxlt   AND
                                           craplot.nrdolote = tel_nrdolote
                                           NO-LOCK NO-ERROR.
                      
                        IF   NOT AVAILABLE craplot   THEN
                             DO:
                                 glb_cdcritic = 60.
                                 NEXT.
                             END.
                             
                        ASSIGN tel_nrdcaixa = craplot.nrdcaixa
                               tel_cdopecxa = craplot.cdopecxa.
                    END.
               ELSE
                    UPDATE tel_nrdcaixa tel_cdopecxa WITH FRAME f_caixa.
           END.
      /*
      EDITING:

         aux_stimeout = 0.

         DO WHILE TRUE:

            READKEY PAUSE 1.

            IF   LASTKEY = -1   THEN
                 DO:
                     aux_stimeout = aux_stimeout + 1.

                     IF   aux_stimeout > glb_stimeout   THEN
                          QUIT.

                     NEXT.
                 END.

            APPLY LASTKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

      END.  /*  Fim do EDITING  */
      */

      tel_nmoperad = " ".

      IF   aux_cddopcao = "C" AND glb_cddopcao <> "C"  THEN
           DISPLAY tel_nmoperad WITH FRAME f_lote.

      IF   glb_cddopcao <> "C" THEN
           DO:
               HIDE FRAME f_debito.
               PAUSE(0).
           END.

      IF   NOT CAN-FIND(crapage WHERE crapage.cdcooper = glb_cdcooper    AND
                                      crapage.cdagenci = tel_cdagenci)   THEN
           DO:
               glb_cdcritic = 15.
               NEXT-PROMPT tel_cdagenci WITH FRAME f_lote.
               NEXT.
           END.

      /* Eliminado para separar o movimento por filial

      IF   tel_cdagenci > 1   THEN       /* So' aceita agencia = 1 */
           DO:
               glb_cdcritic = 134.
               NEXT-PROMPT tel_cdagenci WITH FRAME f_lote.
               NEXT.
           END.
      */

      IF   NOT CAN-FIND(crapbcl WHERE crapbcl.cdbccxlt = tel_cdbccxlt)   THEN
           DO:
               glb_cdcritic = 57.
               NEXT-PROMPT tel_cdbccxlt WITH FRAME f_lote.
               NEXT.
           END.

      IF   tel_nrdolote = 0   THEN
           DO:
               glb_cdcritic = 58.
               NEXT-PROMPT tel_nrdolote WITH FRAME f_lote.
               NEXT.
           END.
      
      IF  CAN-DO("E,A",glb_cddopcao) THEN
          DO:

              RUN sistema/generico/procedures/b1wgen0134.p
                               PERSISTENT SET h-b1wgen0134.
    
              RUN valida_lote_emprst_tipo1 IN h-b1wgen0134
                    (INPUT glb_cdcooper,
                     INPUT glb_cdagenci,
                     INPUT 0,
                     INPUT 0,
                     INPUT tel_nrdolote,
                     OUTPUT TABLE tt-erro).
    
              DELETE PROCEDURE h-b1wgen0134.
    
              IF RETURN-VALUE = "OK"   THEN
                 DO:
    
                     ASSIGN glb_cdcritic = 261.
                     NEXT-PROMPT tel_nrdolote WITH FRAME f_lote.
                     NEXT.
    
                 END.
                
          END.


      /** Quando Banco/Caixa = 400, permitir somente a Consulta **/
      IF   tel_cdbccxlt  = 400  AND
           glb_cddopcao <> "C"  THEN
           DO:
               MESSAGE "Operacao bloqueada para Banco/Caixa 400.".
               NEXT-PROMPT tel_cdbccxlt WITH FRAME f_lote.
               NEXT.
           END.
      
      IF   CAN-DO("11,30,31,500",STRING(tel_cdbccxlt))   AND
           tel_cdagenci <> 11    THEN  /* boletim de caixa -   EDSON PAC1 */ 
           DO:
               IF   TRIM(tel_cdopecxa) <> ""   THEN
                    DO:

                        FIND crapope WHERE crapope.cdcooper = glb_cdcooper  AND
                                           crapope.cdoperad = tel_cdopecxa
                                           NO-LOCK NO-ERROR.
                     
                        IF   NOT AVAILABLE crapope   THEN
                             DO:
                                 glb_cdcritic = 67.
                                 NEXT-PROMPT tel_cdopecxa WITH FRAME f_caixa.
                                 NEXT.
                             END.
                    
                        IF   crapope.cdsitope <> 1   THEN
                             DO:
                                 glb_cdcritic = 627.
                                 NEXT-PROMPT tel_cdopecxa WITH FRAME f_caixa.
                                 NEXT.
                             END.    
                    END.
                    
               IF   NOT CAN-DO("C,O",glb_cddopcao)   AND
                    tel_nrdcaixa > 0                 THEN             
                    DO:

                        FIND LAST crapbcx WHERE 
                                  crapbcx.cdcooper = glb_cdcooper   AND                                            crapbcx.dtmvtolt = glb_dtmvtolt   AND
                                  crapbcx.cdagenci = tel_cdagenci   AND
                                  crapbcx.nrdcaixa = tel_nrdcaixa   AND
                                  crapbcx.cdopecxa = tel_cdopecxa
                                  NO-LOCK NO-ERROR. 
                     
                        IF   NOT AVAILABLE crapbcx   THEN
                             DO:
                                 glb_cdcritic = 698.
                                 NEXT-PROMPT tel_nrdcaixa WITH FRAME f_caixa.
                                 NEXT.
                             END. 
                        ELSE
                             IF   crapbcx.cdsitbcx <> 1   THEN
                                  DO:
                                      glb_cdcritic = 699.
                                      NEXT-PROMPT tel_nrdcaixa 
                                                  WITH FRAME f_caixa.
                                      NEXT.
                                  END.
                    END.
           END.
      ELSE
      IF   glb_cddopcao = "O"   THEN
           DO:
               glb_cdcritic = 708.
               NEXT-PROMPT glb_cddopcao WITH FRAME f_lote.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "LOTE"   THEN
                 DO:
                     HIDE FRAME f_caixa.
                     HIDE FRAME f_lote.
                     HIDE FRAME f_debito.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A" THEN
        RUN fontes/lotea.p.
   ELSE
   IF   glb_cddopcao = "C" THEN
        RUN fontes/lotec.p.
   ELSE
   IF   glb_cddopcao = "E" THEN
        RUN fontes/lotee.p.
   ELSE
   IF   glb_cddopcao = "I" THEN
        RUN fontes/lotei.p.
   ELSE
   IF   glb_cddopcao = "O" THEN
        MESSAGE "Opcao Desabilitada".
        /*
        RUN fontes/loteo.p.
        */
   IF   glb_nmdatela <> "LOTE"   THEN
        RETURN.

END.  /*  Fim do DO WHILE TRUE  */

/* ......................................................................... */
