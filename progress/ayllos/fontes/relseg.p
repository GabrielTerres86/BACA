/*.............................................................................

  Programa: Fontes/relseg.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Gabriel
  Data    : Fevereiro/2009                     Ultima Atualizacao: 18/02/2014

  Dados referente ao programa:
  
  Frequencia: Diario (on-line).
  Objetivo  : Mostrar a tela RELSEG. Relatorio gerencial e taxas de seguros.
              As 3 modalidades de seguro (Vida, auto e residencial).

  Alteracoes: 12/06/2009 - Mostrar o geral de todos os seguros no relatorio
                           gerencial (Gabriel).
                           
              27/10/2009 - Alterado para utilizar a BO b1wgen0045.p que sera
                           agrupadora das funcoes compartilhadas com o CRPS524
                           
              17/12/2012 - Ajustes no seguro residencial e vida (David Kruger). 
              
              22/02/2013 - Relatorios estao sendo gerados na b1wgen0045 que
                           tambem serão usados para a web. (David Kruger).     
                           
              30/04/2013 - Removido DELETE PROCEDURE b1wgen9999 do incio da
                           Transacao (Lucas R.) 
                           
              06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
              10/01/2014 - Alterada critica "015 - Agencia nao cadastrada"
                           para "962 - PA nao cadastrado". (Reinert)
                           
              18/02/2014 - Impressão em .txt para Tp.Relat 5 (Lucas).

..............................................................................*/

DEF STREAM str_1.

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }


/* Variaveis auxiliares */
DEF   VAR aux_nmarqimp AS   CHAR                                       NO-UNDO.
DEF   VAR aux_nmarqpdf AS   CHAR                                       NO-UNDO.
DEF   VAR aux_cddopcao AS   CHAR                                       NO-UNDO.
DEF   VAR aux_confirma AS   LOGI  FORMAT "S/N"                         NO-UNDO.
DEF   VAR aux_contador AS   INTE                                       NO-UNDO.
DEF   VAR aux_nmdcampo AS   CHAR                                       NO-UNDO.


/* Variaveis da tela */
DEF   VAR tel_cdagenci AS   INTE                                       NO-UNDO.
DEF   VAR tel_inexprel AS   INTE                                       NO-UNDO.
DEF   VAR tel_cddopcao AS   LOGI  FORMAT "T/I"                         NO-UNDO.
DEF   VAR tel_tprelato AS   INTE                                       NO-UNDO.
DEF   VAR tel_dtiniper AS   DATE                                       NO-UNDO.
DEF   VAR tel_dtfimper AS   DATE                                       NO-UNDO.

DEF   VAR aux_recid1 AS ROWID          NO-UNDO.
DEF   VAR aux_recid2 AS ROWID          NO-UNDO.
DEF   VAR aux_recid3 AS ROWID          NO-UNDO.

DEF   VAR tel_vlrdecom1 AS DECI        NO-UNDO.
DEF   VAR tel_vlrdecom2 AS DECI        NO-UNDO.
DEF   VAR tel_vlrdecom3 AS DECI        NO-UNDO.

DEF   VAR tel_vlrdeiof1 AS DECI        NO-UNDO.
DEF   VAR tel_vlrdeiof2 AS DECI        NO-UNDO.
DEF   VAR tel_vlrdeiof3 AS DECI        NO-UNDO.

DEF   VAR tel_dsrelato AS   CHAR FORMAT "x(59)" VIEW-AS COMBO-BOX LIST-ITEMS
      "1 - Seguro auto por PA.",
      "2 - Seguro vida por PA.",
      "3 - Seguro residencial por PA.","4 - Gerencial - consolidado seguros auto,vida e residencial." NO-UNDO.

DEF   VAR tel_vlrapoli AS   DECI                                       NO-UNDO.

/* Variaveis para gerar o relatorio Receitas Seguros */
DEF   VAR rel_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"                NO-UNDO.
DEF   VAR rel_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"                NO-UNDO.

DEF   VAR pac_qtseguro AS   INTE                                       NO-UNDO.
DEF   VAR pac_vllanmto AS   DECI  FORMAT "z,zzz,zz9.99"                NO-UNDO.
DEF   VAR pac_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"                NO-UNDO.
DEF   VAR pac_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"                NO-UNDO.

DEF   VAR tot_qtseguro AS   INTE  FORMAT "   z,zzz,zz9"                NO-UNDO.
DEF   VAR tot_vllanmto AS   DECI  FORMAT "z,zzz,zz9.99"                NO-UNDO.
DEF   VAR tot_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"                NO-UNDO.
DEF   VAR tot_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"                NO-UNDO.

/*    Variaveis para impressao  */
DEF   VAR tel_dsimprim AS   CHAR  FORMAT "x(8)" INIT "Imprimir"        NO-UNDO.
DEF   VAR tel_dscancel AS   CHAR  FORMAT "x(8)" INIT "Cancelar"        NO-UNDO.
DEF   VAR aux_nmendter AS   CHAR                                       NO-UNDO.
DEF   VAR aux_flgescra AS   LOGI                                       NO-UNDO.
DEF   VAR aux_dscomand AS   CHAR                                       NO-UNDO.
DEF   VAR par_flgrodar AS   LOGI                                       NO-UNDO.
DEF   VAR par_flgfirst AS   LOGI                                       NO-UNDO.
DEF   VAR par_flgcance AS   LOGI                                       NO-UNDO.

/***Cabecalho****/
DEF   VAR rel_nmresemp AS   CHAR  FORMAT "x(15)"                       NO-UNDO.
DEF   VAR rel_nmrelato AS   CHAR  FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF   VAR rel_nrmodulo AS   INTE  FORMAT     "9"                       NO-UNDO.
DEF   VAR rel_nmempres AS   CHAR  FORMAT "x(15)"                       NO-UNDO.
DEF   VAR rel_nmmodulo AS   CHAR  FORMAT "x(15)" EXTENT 5
                                  INIT ["","","","",""]                NO-UNDO.

/* w-seguro */
/*Temp-table de seguros esta na sistema/generico/includes/b1wgen0045tt.i */
{ sistema/generico/includes/b1wgen0045tt.i }
DEF VAR h-b1wgen0045 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.

FORM SKIP(1)
     glb_cddopcao     AT 35 LABEL "Opcao"           AUTO-RETURN
         HELP "Entre com a opcao desejada (A, C ou R )."
         VALIDATE (CAN-DO("A,C,R",glb_cddopcao),"Opcao incorreta.")
         
     SKIP(3)
    
     tel_vlrdecom1  AT 08 LABEL "SEGURO AUTO: Comissao"       FORMAT " z9.99"
         HELP "Entre com a comissao do seguro AUTO."

     tel_vlrdeiof1  AT 26 LABEL "IOF"                         FORMAT " z9.99"
         HELP "Entre com o valor do IOF do seguro AUTO."  
              
     tel_vlrapoli     AT 22 LABEL "Apolice"                     FORMAT "zz9.99"
         HELP "Entre com a apolice do seguro AUTO."
                 
     SKIP(1)

     tel_vlrdecom2  AT 08 LABEL "SEGURO VIDA: Comissao"       FORMAT " z9.99"
         HELP "Entre com a comissao do seguro VIDA."
               
     tel_vlrdeiof2  AT 26 LABEL "IOF" 
         HELP "Entre com o valor do IOF do seguro VIDA."         FORMAT " z9.99"
            
     SKIP(1)

     tel_vlrdecom3  AT 01 LABEL "SEGURO RESIDENCIAL: Comissao" FORMAT " z9.99"
         HELP "Entre com a comissao do seguro RESIDENCIAL."
                 
     tel_vlrdeiof3  AT 26 LABEL "IOF"                          FORMAT " z9.99"
         HELP "Entre com o valor do IOF do seguro RESIDENCIAL."  

     SKIP(2)

     WITH ROW 4 SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_relseg.

FORM tel_dsrelato     AT 01 LABEL "Relatorio"
        HELP "Utilize as <SETAS> p/ selecionar o relatorio desejado."
        
     SKIP(1)        
         
     tel_cdagenci     AT 02 LABEL "PA"             FORMAT "zz9"
        HELP "Entre com o pa ou 0 <ZERO> p/ todos."
        VALIDATE(tel_cdagenci = 0 OR
                 CAN-FIND(crapage WHERE crapage.cdcooper = glb_cdcooper   AND
                                        crapage.cdagenci = tel_cdagenci),
                 "962 - PA nao cadastrado.")
     
     tel_dtiniper     AT 16 LABEL "De" FORMAT "99/99/9999"
        HELP "Entre com o periodo inicial."
        VALIDATE (tel_dtiniper <> ?,"013 - Data errada.")
     
     tel_dtfimper     AT 31 LABEL "a"   FORMAT "99/99/9999"
        HELP "Entre com o periodo final."
        VALIDATE (tel_dtfimper <> ?,"013 - Data errada.")

     WITH CENTERED NO-BOX ROW 8 SIDE-LABELS WIDTH 74 OVERLAY FRAME f_relatorios.

ON RETURN OF tel_dsrelato IN FRAME f_relatorios DO:

    tel_tprelato = INTEGER(SUBSTRING(tel_dsrelato:SCREEN-VALUE,1,1)).
    
    APPLY "GO".

END.

/*............................................................................*/
IF NOT VALID-HANDLE(h-b1wgen9999) THEN
   RUN sistema/generico/procedures/b1wgen9999.p
       PERSISTENT SET h-b1wgen9999.

 IF  VALID-HANDLE(h-b1wgen9999)  THEN
     DO:
       RUN p-conectagener IN h-b1wgen9999.

       IF  RETURN-VALUE = "OK"  THEN 
           DO:

              IF NOT VALID-HANDLE(h-b1wgen0045) THEN
                 RUN sistema/generico/procedures/b1wgen0045.p
                     PERSISTENT SET h-b1wgen0045.
              
              IF  NOT VALID-HANDLE(h-b1wgen0045)  THEN
               DO:
                  glb_nmdatela = "RELSEG".
                  BELL.
                  MESSAGE "Handle invalido para BO b1wgen0045.".
                  IF (glb_conta_script = 0) THEN
                      PAUSE 3 NO-MESSAGE.
              
                  RETURN.
               END.
           END.
     END.
 ELSE 
    DO:
        glb_nmdatela = "RELSEG".
        BELL.
        MESSAGE "Nao foi possivel efetuar conexao com o " +
                 "banco generico.".
        IF (glb_conta_script = 0) THEN
           PAUSE 3 NO-MESSAGE.
        RETURN.
    END.
/*............................................................................*/

ASSIGN glb_cddopcao = "C"
       glb_cdcritic =  0.

DO WHILE TRUE:

   RELEASE craptab.

   RUN proc_esconde.  /* Esconde campos dependendo a opcao */
 
   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
            CLEAR FRAME f_relseg ALL NO-PAUSE.
        END.
   
   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_relseg.

      IF   aux_cddopcao <> glb_cddopcao   THEN
           DO:
               { includes/acesso.i }
           
                aux_cddopcao = glb_cddopcao.
           END.
           
      LEAVE.     

   END. /* Fim do DO WHILE TRUE */ 

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN         /*  F4 ou Fim  */
        DO:
            RUN fontes/novatela.p.
        
            IF   CAPS(glb_nmdatela) <> "RELSEG"   THEN
                 DO:
                     HIDE FRAME f_relseg.
                    
                     IF VALID-HANDLE(h-b1wgen9999) THEN
                        DELETE OBJECT h-b1wgen9999.

                     IF VALID-HANDLE(h-b1wgen0045) THEN
                        DELETE OBJECT h-b1wgen0045.

                     RETURN.
                 END.
            NEXT.
        END.

   IF   glb_cddopcao = "C"   THEN
        DO:
            RUN proc_traz_dados. /* Traz dados de IOF, comissao e/ou Apolice */

            IF   RETURN-VALUE = "NOK"   THEN    /* Nao encontrada */
                 NEXT.

            DISPLAY tel_vlrdecom1   tel_vlrdeiof1   tel_vlrapoli
                    tel_vlrdecom2   tel_vlrdeiof2
                    tel_vlrdecom3   tel_vlrdeiof3   WITH FRAME f_relseg.

        END. /* Fim da opcao C */
   ELSE
   IF   glb_cddopcao = "A"   THEN
        DO:         
            /* IOF, comissao e apolice */
            RUN proc_traz_dados_exclusivos 
                IN h-b1wgen0045 (INPUT glb_cdcooper,
                                 INPUT glb_cdagenci,
                                 INPUT 0, /* nrdcaixa */
                                 INPUT glb_cdoperad,
                                 INPUT glb_nmdatela,
                                 INPUT 1, /* AYLLOS */
                                 INPUT glb_dtmvtolt,
                                 OUTPUT tel_vlrdecom1,
                                 OUTPUT tel_vlrdecom2,
                                 OUTPUT tel_vlrdecom3,
                                 OUTPUT tel_vlrdeiof1,
                                 OUTPUT tel_vlrdeiof2,
                                 OUTPUT tel_vlrdeiof3,
                                 OUTPUT aux_recid1,
                                 OUTPUT aux_recid2,
                                 OUTPUT aux_recid3,
                                 OUTPUT tel_vlrapoli,
                                 OUTPUT TABLE tt-erro).  

            IF RETURN-VALUE <> "OK" THEN
               DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                  IF AVAIL tt-erro THEN
                     MESSAGE tt-erro.dscritic.
                  ELSE
                     MESSAGE "Nao foi possivel realizar a consulta".
        
                  PAUSE(2)NO-MESSAGE.
                  HIDE MESSAGE.
                  NEXT.
               END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
               UPDATE tel_vlrdecom1   tel_vlrdeiof1   tel_vlrapoli
                      tel_vlrdecom2   tel_vlrdeiof2
                      tel_vlrdecom3   tel_vlrdeiof3   WITH FRAME f_relseg.
           
               LEAVE.
               
            END. /* Atualizacao dos campos da craptab */
           
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                   DO:
                       CLEAR FRAME f_relseg ALL NO-PAUSE.
                       NEXT.
                   END. 


         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               aux_confirma = NO.
               glb_cdcritic = 78.
               RUN fontes/critic.p.
               MESSAGE glb_dscritic UPDATE aux_confirma.
               glb_cdcritic = 0.
               LEAVE.
                                                
            END. 
               
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 NOT aux_confirma                     THEN
                 DO:
                     glb_cdcritic = 79.
                     LEAVE.
                 END.
                
            /* Grava os novos dados na craptab */
            RUN proc_grava_dados 
                IN h-b1wgen0045(INPUT glb_cdcooper,
                                INPUT glb_cdagenci,
                                INPUT 0, /* nrdcaixa */
                                INPUT glb_cdoperad,
                                INPUT glb_nmdatela,
                                INPUT 1, /* AYLLOS */
                                INPUT glb_dtmvtolt,
                                INPUT tel_vlrdecom1,
                                INPUT tel_vlrdecom2,
                                INPUT tel_vlrdecom3,
                                INPUT tel_vlrdeiof1,
                                INPUT tel_vlrdeiof2,
                                INPUT tel_vlrdeiof3,
                                INPUT aux_recid1,
                                INPUT aux_recid2,
                                INPUT aux_recid3,
                                INPUT tel_vlrapoli,
                                OUTPUT TABLE tt-erro).   

            IF RETURN-VALUE <> "OK" THEN
               DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                  IF AVAIL tt-erro THEN
                     MESSAGE tt-erro.dscritic.
                  ELSE
                     MESSAGE "Nao foi possivel realizar a consulta".
        
                  PAUSE(2)NO-MESSAGE.
                  HIDE MESSAGE.
                  NEXT.
               END.
              
            CLEAR FRAME f_relseg ALL NO-PAUSE.
            
        END. /* Fim da opcao A */
   ELSE
   IF   glb_cddopcao = "R"   THEN
        DO:
            RUN proc_esconde. /* Esconde campos  */

            DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
            
               UPDATE tel_dsrelato WITH FRAME f_relatorios.
               LEAVE.
            
            END.  /* Fim do DO WHILE TRUE */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                     HIDE FRAME f_relatorios.
                     NEXT.
                 END.

            RUN proc_relatorio.
           

        END. /* Fim da opcao R */ 

END. /* Fim do DO WHILE TRUE */


/*............................................................................*/

RUN p_desconectagener IN h-b1wgen9999.

IF VALID-HANDLE(h-b1wgen0045) THEN
   DELETE OBJECT h-b1wgen0045.

IF VALID-HANDLE(h-b1wgen9999) THEN
   DELETE OBJECT h-b1wgen9999.

/*............................................................................*/



PROCEDURE proc_traz_dados:      /* 1 - AUTO, 2 - VIDA, 3 - RESIDENCIAL */


        RUN busca_dados_seg IN h-b1wgen0045 (INPUT glb_cdcooper,
                                             INPUT glb_cdagenci,
                                             INPUT 0, /* nrdcaixa */
                                             INPUT glb_cdoperad,
                                             INPUT glb_nmdatela,
                                             INPUT 1, /* AYLLOS */
                                             INPUT glb_dtmvtolt,
                                             OUTPUT tel_vlrdecom1,
                                             OUTPUT tel_vlrdecom2,
                                             OUTPUT tel_vlrdecom3,
                                             OUTPUT tel_vlrdeiof1,
                                             OUTPUT tel_vlrdeiof2,
                                             OUTPUT tel_vlrdeiof3,
                                             OUTPUT aux_recid1,
                                             OUTPUT aux_recid2,
                                             OUTPUT aux_recid3,
                                             OUTPUT tel_vlrapoli,
                                             OUTPUT TABLE tt-erro).


        IF RETURN-VALUE <> "OK" THEN
           DO:
              FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
              IF AVAIL tt-erro THEN
                 MESSAGE tt-erro.dscritic.
              ELSE
                MESSAGE "Nao foi possivel realizar a consulta".
        
              PAUSE(2)NO-MESSAGE.
              HIDE MESSAGE.
              NEXT.
           END.

    RETURN "OK".
    
END PROCEDURE.  /* Fim da procedure proc_traz_dados */


PROCEDURE proc_relatorio:

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
          UPDATE tel_cdagenci
                 tel_dtiniper  
                 tel_dtfimper WITH FRAME f_relatorios
       
          EDITING:

             READKEY.

             APPLY LAST-KEY.

             IF GO-PENDING  THEN
                DO:  
                    EMPTY TEMP-TABLE tt-erro.

                    MESSAGE "Aguarde... Gerando Relatorio...".

                    ASSIGN INPUT tel_cdagenci
                                 tel_dtiniper
                                 tel_dtfimper.                

                    RUN inicia-relatorio IN 
                        h-b1wgen0045(INPUT glb_cdcooper,
                                     INPUT glb_cdagenci,
                                     INPUT 0, /* nrdcaixa */
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT 1, /* AYLLOS */
                                     INPUT glb_dtmvtolt,
                                     INPUT tel_tprelato,
                                     INPUT tel_cdagenci,
                                     INPUT tel_dtiniper,
                                     INPUT tel_dtfimper,
                                     INPUT tel_inexprel,
                                     OUTPUT aux_nmdcampo,
                                     OUTPUT aux_nmarqpdf,
                                     OUTPUT aux_nmarqimp,
                                     OUTPUT TABLE tt-erro).

                    HIDE MESSAGE NO-PAUSE.
                    
                    IF RETURN-VALUE <> "OK" THEN
                       DO:
                           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                           
                           IF AVAIL tt-erro THEN
                              DO:
                                 MESSAGE tt-erro.dscritic.  
                                 {sistema/generico/includes/foco_campo.i
                                         &VAR-GERAL="sim"
                                         &NOME-FRAME="f_relatorios"
                                         &NOME-CAMPO=aux_nmdcampo }
                              END.
                           ELSE
                              MESSAGE "Nao foi possivel realizar a consulta".
                        
                           PAUSE(2)NO-MESSAGE.
                           HIDE MESSAGE.
                           NEXT.
                       END.

                      
                END. /* FIM DO GO PENDING */
                   
          END. /* FIM DO EDITING */

         LEAVE. 
          
      END.  /* Fim do DO WHILE TRUE */
       
      IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
         NEXT.

      ASSIGN tel_cddopcao = TRUE
             par_flgrodar = TRUE.  /* Imprime ... */

      HIDE MESSAGE NO-PAUSE.

      FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                               NO-LOCK NO-ERROR.
       
       
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         MESSAGE "(T)erminal ou (I)mpressora" UPDATE tel_cddopcao.
        
         IF tel_cddopcao   THEN
            DO:
               RUN fontes/visrel.p(INPUT aux_nmarqimp).
            END.

         { includes/impressao.i }
          
         LEAVE.

      END.
       
      IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
         NEXT.

END PROCEDURE.

    
PROCEDURE proc_esconde:

    IF   NOT CAN-DO("C,A",glb_cddopcao)   THEN
         DO: 
             tel_vlrapoli:VISIBLE  IN FRAME f_relseg = FALSE.           
             tel_vlrdecom1:VISIBLE IN FRAME f_relseg = FALSE.
             tel_vlrdecom2:VISIBLE IN FRAME f_relseg = FALSE.
             tel_vlrdecom3:VISIBLE IN FRAME f_relseg = FALSE.
                         
             tel_vlrdeiof1:VISIBLE IN FRAME f_relseg = FALSE.
             tel_vlrdeiof2:VISIBLE IN FRAME f_relseg = FALSE.
             tel_vlrdeiof3:VISIBLE IN FRAME f_relseg = FALSE.
             
         END.

    tel_dsrelato:VISIBLE IN FRAME f_relatorios = FALSE.
    tel_cdagenci:VISIBLE IN FRAME f_relatorios = FALSE.
    tel_dtiniper:VISIBLE IN FRAME f_relatorios = FALSE.
    tel_dtfimper:VISIBLE IN FRAME f_relatorios = FALSE.
      
END PROCEDURE.                                                        
/*............................................................................*/
