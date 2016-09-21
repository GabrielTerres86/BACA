/* .............................................................................

   Programa: Fontes/conbdc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Novembro/2004                     Ultima alteracao: 26/11/2013
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Demonstrar Borderos que tiverem o percentual de cheques
               excedidos no contrato.(Relatorio 377)

   Alteracoes : 01/08/2005 - Critica de CPF no SPC(Mirtes)   
              
                20/09/2005 - Alterado para ler tbm  codigo da cooperativa na 
                             tabela crapabc (Diego).

                03/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane
                 
                22/01/2007 - Alterado formato das variaveis do tipo DATE de
                             "99/99/99" para "99/99/9999" (Elton).
                
                10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (André Euzébio - Supero).             
                             
                26/11/2013 - Alterado de "CPF/CGC" para "CPF/CNPJ" em
                             w_movtos.dsrestri. (Reinert)                             
............................................................................. */

{ includes/var_online.i }

DEF STREAM str_1.

DEF        VAR tel_cdagenci AS INT    FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_dtmvtolt AS DATE   FORMAT "99/99/9999"            NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR   FORMAT "!"                     NO-UNDO.
DEF        VAR aux_cdagefim LIKE crapass.cdagenci                    NO-UNDO.
DEF        VAR aux_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF        VAR aux_percentu AS DEC                                   NO-UNDO.
DEF        VAR aux_vltotcdb AS DEC                                   NO-UNDO.
DEF        VAR aux_vlutlcpf AS DEC                                   NO-UNDO.
DEF        VAR aux_qtdevchq AS INTE                                  NO-UNDO.
DEF        VAR aux_nrsequen AS INTE                                  NO-UNDO.
DEF        VAR aux_dscpfcgc AS CHAR    FORMAT "x(14)"                NO-UNDO.

DEF    TEMP-TABLE w_movtos                                           NO-UNDO
           FIELD nrdconta LIKE crapass.nrdconta
           FIELD nrborder LIKE crapbdc.nrborder
           FIELD vllimite LIKE craplim.vllimite
           FIELD percentu AS DEC  
           FIELD cdagenci LIKE crapass.cdagenci
           FIELD dtlibbdc LIKE crapbdc.dtlibbdc
           FIELD insitbdc LIKE crapbdc.insitbdc
           FIELD vltotcdb   AS DEC
           FIELD vltotemi   AS DEC
           FIELD nrcpfcgc LIKE crapabc.nrcpfcgc
           FIELD qtdevchq   AS INTE
           FIELD dsrestri   AS CHAR FORMAT "x(90)"
           FIELD vlutlcpf   AS DEC
           INDEX w_movtos1
                 cdagenci
                 nrdconta
                 nrborder.

DEF    TEMP-TABLE w_lista                                            NO-UNDO   
           FIELD nrsequen   AS INTE             
           FIELD dslinhas   AS CHAR FORMAT "x(74)".
 
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  3 LABEL "Opcao" AUTO-RETURN
                   HELP "Informe a opcao desejada (C,ou R)."
                        VALIDATE(CAN-DO("C,R",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_conbdc.

FORM tel_dtmvtolt AT 1 LABEL "  Referencia" 
                       HELP "Entre com a data de referencia do movimento."
     tel_cdagenci      LABEL "         PA"
                 HELP "Entre com o numero do PA ou 0 para todos os PA's."
     WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere.
  
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

DEF QUERY q_lista     FOR w_lista.
                                     
DEF BROWSE b_lista  QUERY q_lista  
    DISP  w_lista.dslinhas    COLUMN-LABEL
          "PA  Data            Conta    Bordero         Limite   "
          WITH 9 DOWN.

DEF FRAME f_lista_b  
          SKIP(1)
          b_lista  
 HELP "SETAS/PAGE UP/PAGE DOWN/TAB p/navegar  -  <F4>/<END> p/fim"
          WITH NO-BOX /*CENTERED*/ OVERLAY ROW 7.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_dtmvtolt = glb_dtmvtolt.

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               ASSIGN glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_conbdc.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "CONBDC"  THEN
                 DO:
                     HIDE FRAME f_refere  NO-PAUSE.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "C"   THEN
        DO:
           UPDATE tel_dtmvtolt
                  tel_cdagenci
                  WITH FRAME f_refere.

           ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                                 THEN 9999
                                 ELSE tel_cdagenci.

           RUN gera_movtos_pesquisa.
           RUN gera_movtos_query.
           
           OPEN QUERY q_lista  
           
           FOR EACH w_lista  NO-LOCK
                            BY w_lista.nrsequen.
           ENABLE b_lista WITH FRAME f_lista_b.

           WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                         
           HIDE FRAME f_lista_b. 
               
           HIDE MESSAGE NO-PAUSE.

           ASSIGN aux_confirma = "N".
           DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      
                MESSAGE COLOR NORMAL
                        "Deseja listar  a pesquisa(S/N)?:"
                        UPDATE aux_confirma.
     
                LEAVE.

           END. /* fim do DO WHILE */
                            
           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                aux_confirma <> "S"                  THEN
                NEXT.
    
           RUN fontes/conbdc_r.p (INPUT tel_dtmvtolt, 
                                  INPUT tel_cdagenci).
       
        END.
   ELSE              
   IF   glb_cddopcao = "R"   THEN                              /*  Relatorio  */
        DO:
            HIDE FRAME f_refere NO-PAUSE.
            
            ASSIGN tel_dtmvtolt = glb_dtmvtolt
                   tel_cdagenci = 0.
        
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               UPDATE tel_dtmvtolt
                      tel_cdagenci
                      WITH FRAME f_refere.
               
               ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                                     THEN 9999
                                     ELSE tel_cdagenci.
                     
               
               RUN fontes/conbdc_r.p (INPUT tel_dtmvtolt, 
                                      INPUT tel_cdagenci).                       
             END.  /*  Fim do DO WHILE TRUE  */
         
            HIDE FRAME f_refere.
        END.
        
END.  /*  Fim do DO WHILE TRUE  */




PROCEDURE gera_movtos_pesquisa.

 /*FOR EACH w_movtos:
       DELETE w_movtos.
   END. */
   
   EMPTY TEMP-TABLE w_movtos.
   
   FOR EACH  crapbdc WHERE crapbdc.cdcooper  = glb_cdcooper        AND
                           crapbdc.dtlibbdc <> ?                   AND
                           crapbdc.dtlibbdc >= tel_dtmvtolt        NO-LOCK,
     
       FIRST  crapass WHERE crapass.cdcooper  = glb_cdcooper        AND
                            crapass.nrdconta  = crapbdc.nrdconta    AND
                            crapass.cdagenci >= tel_cdagenci        AND
                            crapass.cdagenci <= aux_cdagefim        NO-LOCK,
   
       FIRST  craplim WHERE  craplim.cdcooper  = glb_cdcooper        AND
                             craplim.nrdconta   = crapass.nrdconta   AND
                             craplim.nrctrlim   = crapbdc.nrctrlim   AND
                             craplim.tpctrlim   = 2                  AND
                             craplim.insitlim   = 2                  NO-LOCK: 

       /* Valor maximo por contrato excedido */
       aux_vltotcdb = 0.
    
       FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper       AND
                              crapcdb.nrdconta = crapbdc.nrdconta   AND
                              crapcdb.insitchq = 2                  AND
                              crapcdb.dtlibera > crapbdc.dtlibbdc   NO-LOCK:
           
            aux_vltotcdb = aux_vltotcdb + crapcdb.vlcheque.
       END.
               
       FOR EACH crapabc WHERE 
                crapabc.cdcooper = glb_cdcooper                           AND
                crapabc.nrborder = crapbdc.nrborder                       AND
                crapabc.nrdconta = crapass.nrdconta                       AND
                crapabc.nrcpfcgc > 0                                      AND
              ((crapabc.dsrestri = "Valor maximo por emitente excedido."  OR
                crapabc.dsrestri = "Percentual de cheques do emitente " +
                                   "excedido no contrato."                OR
                crapabc.dsrestri = "Valor maximo por contrato excedido."  OR
                crapabc.dsrestri = "CPF consta no SPC"                    OR
                crapabc.dsrestri = "Quantidade de cheques devolvidos  " +
                                   "do emitente excedido"))             
                NO-LOCK
                BREAK BY crapabc.nrcpfcgc:                         
               
           IF  FIRST-OF(crapabc.nrcpfcgc) THEN
               DO:

                  ASSIGN aux_vlutlcpf   = 0.
                  
                  FOR EACH crapcdb WHERE 
                           crapcdb.cdcooper = glb_cdcooper       AND
                           crapcdb.nrborder = crapbdc.nrborder   AND
                           crapcdb.nrdconta = crapbdc.nrdconta   AND
                           crapcdb.dtdevolu = ?                  AND
                           crapcdb.nrcpfcgc = crapabc.nrcpfcgc   NO-LOCK:
                           
                      ASSIGN aux_vlutlcpf =
                             aux_vlutlcpf + crapcdb.vlcheque.
                  END.

                  aux_qtdevchq = 0.
                
                  FOR EACH crapcec WHERE
                           crapcec.cdcooper = glb_cdcooper     AND
                           crapcec.nrcpfcgc = crapabc.nrcpfcgc NO-LOCK:
                           
                      ASSIGN aux_qtdevchq   = aux_qtdevchq +
                                              crapcec.qtchqdev.
                  END.
               END.    

               ASSIGN aux_percentu = 
                         ((aux_vlutlcpf / craplim.vllimite) * 100).
      
               CREATE w_movtos.
               ASSIGN w_movtos.nrdconta = crapass.nrdconta
                      w_movtos.nrborder = crapbdc.nrborder
                      w_movtos.vllimite = craplim.vllimite
                      w_movtos.percentu = aux_percentu
                      w_movtos.cdagenci = crapass.cdagenci
                      w_movtos.dtlibbdc = crapbdc.dtlibbdc
                      w_movtos.insitbdc = crapbdc.insitbdc
                      w_movtos.vltotcdb = aux_vltotcdb
                      w_movtos.nrcpfcgc = crapabc.nrcpfcgc
                      w_movtos.qtdevchq = aux_qtdevchq
                      w_movtos.dsrestri = crapabc.dsrestri
                      w_movtos.vlutlcpf = aux_vlutlcpf.
          END. /* for each crapabc */
   END.

END PROCEDURE.



PROCEDURE gera_movtos_query.
   
/*  FOR EACH w_lista:
       DELETE w_lista.
   END.*/
   
   EMPTY TEMP-TABLE w_lista.

   ASSIGN aux_nrsequen = 0.
   FOR EACH w_movtos NO-LOCK , 

       FIRST crapage WHERE
             crapage.cdcooper = glb_cdcooper      AND
             crapage.cdagenci = w_movtos.cdagenci NO-LOCK,
      
       FIRST crapass WHERE
             crapass.cdcooper = glb_cdcooper      AND
             crapass.nrdconta = w_movtos.nrdconta NO-LOCK
             BREAK BY w_movtos.cdagenci
                      BY w_movtos.dtlibbdc
                         BY w_movtos.nrdconta 
                            BY w_movtos.nrborder 
                               BY w_movtos.nrcpfcgc
                                  BY w_movtos.dsrestri:
       
       IF  FIRST-OF(w_movtos.cdagenci) OR
           FIRST-OF(w_movtos.dtlibbdc) OR
           FIRST-OF(w_movtos.nrdconta) OR
           FIRST-OF(w_movtos.nrborder) THEN
           DO:
              IF  aux_nrsequen > 0 THEN
                  DO:
                     ASSIGN aux_nrsequen = aux_nrsequen + 1.
                     CREATE  w_lista.
                     ASSIGN  w_lista.nrsequen = aux_nrsequen.
                     ASSIGN  w_lista.dslinhas = " ".
                  END.

              ASSIGN aux_nrsequen = aux_nrsequen + 1.
              CREATE w_lista.
              ASSIGN w_lista.nrsequen = aux_nrsequen.
              ASSIGN w_lista.dslinhas =
                         STRING(w_movtos.cdagenci,"zz9")         + " " +
                         STRING(w_movtos.dtlibbdc,"99/99/9999")  + " " +  
                         STRING(w_movtos.nrdconta,"zzzz,zz9,9")  + " " +    
                         STRING(w_movtos.nrborder,"z,zzz,zz9")   + " " +  
                         STRING(w_movtos.vllimite,"zzzz,zzz,zz9.99").    
            
           END.
                          
       IF  FIRST-OF(w_movtos.nrcpfcgc)  OR
           FIRST-OF(w_movtos.dsrestri) THEN
           DO:

             IF  w_movtos.dsrestri BEGINS "Perc" THEN
                 ASSIGN w_movtos.dsrestri = " "
                        w_movtos.dsrestri = "Perc.Excedido     " +
                           TRIM(w_movtos.dsrestri) +  " Vlr. "  +
                           TRIM(STRING(w_movtos.vlutlcpf,"zz,zzz,zz9.99")) +
                           " Perc. " + 
                           TRIM(STRING(w_movtos.percentu,"zz9.99")).
             ELSE
             IF  w_movtos.dsrestri BEGINS "Quan" THEN
                 ASSIGN w_movtos.dsrestri = " "
                        w_movtos.dsrestri = "Devol.Excedida    " +
                           TRIM(w_movtos.dsrestri) + " Vlr. " +
                           TRIM(STRING(w_movtos.vlutlcpf,"zz,zzz,zz9.99")) +
                           " Qtd. " + 
                           TRIM(STRING(w_movtos.qtdevchq,"zzz9")).
             ELSE
             IF  w_movtos.dsrestri BEGINS
                            "Valor maximo por contrato excedido." THEN
                 ASSIGN w_movtos.dsrestri = " " 
                        w_movtos.dsrestri = "Contrato Excedido " +
                           TRIM(w_movtos.dsrestri) + " Vlr. " +
                           TRIM(STRING(w_movtos.vltotcdb,"zz,zzz,zz9.99")).
             ELSE
             IF  w_movtos.dsrestri BEGINS
                            "Valor maximo por emitente excedido."  THEN
                 ASSIGN w_movtos.dsrestri = " "
                        w_movtos.dsrestri = "Valor Excedido    " +
                           TRIM(w_movtos.dsrestri) + " Vlr. " +
                           TRIM(STRING(w_movtos.vlutlcpf,"zz,zzz,zz9.99")).

             IF   LENGTH(TRIM(STRING(w_movtos.nrcpfcgc))) > 11   THEN
                  DO:
                     ASSIGN aux_dscpfcgc =
                            STRING(w_movtos.nrcpfcgc,"99999999999999")
                            aux_dscpfcgc = 
                            STRING(aux_dscpfcgc,"xx.xxx.xxx/xxxx-xx").
                  END.
             ELSE
                  DO:
                     ASSIGN glb_nrcalcul = w_movtos.nrcpfcgc.
            
                     RUN fontes/cpffun.p.
           
                     IF   glb_stsnrcal   THEN
                          ASSIGN aux_dscpfcgc =
                                 STRING(w_movtos.nrcpfcgc,"99999999999")
                                 aux_dscpfcgc = 
                                 STRING(aux_dscpfcgc,"xxx.xxx.xxx-xx").
                      ELSE
                          ASSIGN aux_dscpfcgc =
                                 STRING(w_movtos.nrcpfcgc,"99999999999999")
                                 aux_dscpfcgc = 
                                 STRING(aux_dscpfcgc,"xx.xxx.xxx/xxxx-xx").
                  END.        

             ASSIGN w_movtos.dsrestri = "CPF/CNPJ - " + 
                                        aux_dscpfcgc + " " +
                                        w_movtos.dsrestri.
             ASSIGN aux_nrsequen = aux_nrsequen + 1.
             CREATE  w_lista.
             ASSIGN  w_lista.nrsequen = aux_nrsequen.
             ASSIGN  w_lista.dslinhas = w_movtos.dsrestri.
           END.
   END.
END PROCEDURE.


/* ........................................................................  */
