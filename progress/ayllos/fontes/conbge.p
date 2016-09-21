/* ............................................................................

   Programa: Fontes/conbge.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei (Precise)
   Data    : Abril/2009                         Ultima alteracao: 29/05/2014
   
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Tela para consultar informacoes da base de grupo economico
   
   Atualizacoes: 25/08/2010 - Corrigir erro de cratbge nao disponivel.
                              Desconsiderar os intervenientes anuentes 
                              (Gabriel).      
                              
                 06/09/2010 - Considerar os intervenientes anuentes
                              (Irlan).
                              
                 15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                              na leitura e gravacao dos arquivos (Elton).
                              
                 29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................ */

{ includes/var_online.i }

DEF VAR tel_nrcpfcgc AS DEC  FORMAT "zzzzzzzzzzzzz9"                NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR FORMAT "x(50)"                         NO-UNDO.
DEF VAR aux_stimeout AS INT                                         NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF VAR aux_query    AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                        NO-UNDO.
DEF VAR aux_dstpdev  AS CHAR FORMAT "x(10)"                         NO-UNDO.
DEF VAR aux_tpdsaldo AS CHAR FORMAT "x(14)"                         NO-UNDO.
DEF VAR tel_vlfiltro AS INT  FORMAT ">>>>>>>9"                      NO-UNDO.
DEF VAR tel_vltotal  AS INT  FORMAT ">>>>>>>>>>"                    NO-UNDO.
DEF VAR tel_nmdeved  AS CHAR FORMAT "x(50)"                         NO-UNDO.
                                                                    
DEF VAR aux_vltotbge AS DEC                                         NO-UNDO.                               

DEF VAR tel_nmdopcao AS LOGI FORMAT "ARQUIVO/IMPRESSAO" INIT TRUE   NO-UNDO.

DEF VAR resp         AS LOGI FORMAT "SIM/NAO" INIT FALSE
                        LABEL " Confirma geracao da base de grupo economico ?"
                        NO-UNDO.

DEF VAR aux_dslinha  AS CHAR   FORMAT "x(75)"                       NO-UNDO.

DEF STREAM str_1. /* Arquivo importado */

DEF TEMP-TABLE cratbge
    FIELD cdcooper LIKE crapbge.cdcooper
    FIELD nrdconta LIKE crapbge.nrdconta 
    FIELD nrctrato LIKE crapbge.nrctrato 
    FIELD vldsaldo LIKE crapbge.vldsaldo 
    FIELD tpdsaldo LIKE crapbge.tpdsaldo 
    FIELD dtmvtolt LIKE crapbge.dtmvtolt 
    FIELD nrcpfcgc LIKE crapbge.nrcpfcgc
    FIELD tpddeved LIKE crapbge.tpddeved
    INDEX cratbge1 AS PRIMARY cdcooper nrdconta nrctrato nrcpfcgc.

DEF TEMP-TABLE crattot
    FIELD cdcooper LIKE crapbge.cdcooper
    FIELD nrcpfcgc LIKE crapbge.nrcpfcgc
    FIELD vldsaldo LIKE crapbge.vldsaldo
    INDEX crattot1 AS PRIMARY UNIQUE cdcooper nrcpfcgc.

DEF QUERY q_crapbge FOR cratbge.
 
DEF BROWSE b_crapbge QUERY q_crapbge 
    DISP cratbge.nrcpfcgc COLUMN-LABEL "CPF"
         aux_dstpdev      COLUMN-LABEL "Tp Devedor"
         cratbge.nrdconta COLUMN-LABEL "Conta"     
         aux_tpdsaldo     COLUMN-LABEL "Tp Operacao"
         cratbge.nrctrato COLUMN-LABEL "Contrato"
         cratbge.vldsaldo COLUMN-LABEL "Valor"      FORMAT ">>>>>,>>9.99"
         WITH 7 DOWN WIDTH 78 SCROLLBAR-VERTICAL.


  

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.


FORM glb_cddopcao AT 02 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, G, R)"
                        VALIDATE(CAN-DO("C,G,R",glb_cddopcao),
                                 "014 - Opcao errada.")
     tel_nrcpfcgc AT 12 LABEL "CPF"
                        HELP "Entre com o nro do CPF para consultar"
     tel_nmprimtl AT 32 NO-LABEL FORMAT "X(25)"
     tel_vlfiltro AT 60 LABEL "Valor"
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_param.

     
FORM glb_cddopcao AT 02 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, R)"
                        VALIDATE(CAN-DO("C,R",glb_cddopcao),
                                 "014 - Opcao errada.")
     tel_nrcpfcgc AT 12 LABEL "CPF"   
                        HELP "Entre com o nro do CPF para consultar"
     tel_nmprimtl AT 32 NO-LABEL FORMAT "X(25)"
     tel_vlfiltro AT 60 LABEL "Valor" skip
     tel_nmdopcao AT 12 LABEL "Saida"
                        HELP "(A)rquivo ou (I)mpressao."
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_param_rel.


FORM tel_nmdeved  AT 07 LABEL "Nome " FORMAT "X(25)"
     tel_vltotal  AT 56 LABEL "Valor" FORMAT ">>>>>,>>>,>>9.99"
     WITH ROW 19 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS 
     FRAME f_param_rodape.


DEF FRAME f_crapbge
          b_crapbge
    WITH NO-BOX CENTERED OVERLAY ROW 7.


ON ROW-DISPLAY OF b_crapbge DO:

       /* Tipo de Operacao */
       IF cratbge.tpdsaldo = 1   THEN
          ASSIGN aux_tpdsaldo:SCREEN-VALUE 
                 IN BROWSE b_crapbge = "Emprestimo".
       ELSE 
          IF cratbge.tpdsaldo = 2 THEN
             ASSIGN aux_tpdsaldo:SCREEN-VALUE
                    IN BROWSE b_crapbge = "Desc.Cheque".
       ELSE 
          IF cratbge.tpdsaldo = 3 THEN
             ASSIGN aux_tpdsaldo:SCREEN-VALUE
                    IN BROWSE b_crapbge = "Desc.Titulos".
       ELSE 
          IF cratbge.tpdsaldo = 4 THEN
             ASSIGN aux_tpdsaldo:SCREEN-VALUE
                    IN BROWSE b_crapbge = "Cartao".
       ELSE 
          IF cratbge.tpdsaldo = 5 THEN
             ASSIGN aux_tpdsaldo:SCREEN-VALUE
                    IN BROWSE b_crapbge = "Credito Liq".
       ELSE 
          IF cratbge.tpdsaldo = 6 THEN
             ASSIGN aux_tpdsaldo:SCREEN-VALUE
                    IN BROWSE b_crapbge = "Limite Credito".
       ELSE 
          IF cratbge.tpdsaldo = 7 THEN
             ASSIGN aux_tpdsaldo:SCREEN-VALUE
                    IN BROWSE b_crapbge = "Aplicacoes".
       ELSE 
          IF cratbge.tpdsaldo = 8 THEN
             ASSIGN aux_tpdsaldo:SCREEN-VALUE
                    IN BROWSE b_crapbge = "Poup. Progr".
       
                                               
       /*** Tipo de Devedor ***/
       IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "1"   THEN
          ASSIGN aux_dstpdev:SCREEN-VALUE 
                 IN BROWSE b_crapbge = "Devedor".
       ELSE 
          IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "2"   THEN
             ASSIGN aux_dstpdev:SCREEN-VALUE
                    IN BROWSE b_crapbge = "Conjuge".
       ELSE 
          IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "3"   THEN
             ASSIGN aux_dstpdev:SCREEN-VALUE
                    IN BROWSE b_crapbge = "2o Titular".
       ELSE 
          IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "4"   THEN
             ASSIGN aux_dstpdev:SCREEN-VALUE
                    IN BROWSE b_crapbge = "Resp. Legal".
       ELSE 
          IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "5"   THEN
             ASSIGN aux_dstpdev:SCREEN-VALUE
                    IN BROWSE b_crapbge = "Avalista".
       ELSE 
          IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "6"   THEN
             ASSIGN aux_dstpdev:SCREEN-VALUE
                    IN BROWSE b_crapbge = "Aval. Terc".
       ELSE                                         
          IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "7"   THEN
             ASSIGN aux_dstpdev:SCREEN-VALUE
                    IN BROWSE b_crapbge = "Procurad.".
   END.


ON VALUE-CHANGED OF b_crapbge DO:
       
      DISP  ""               @ tel_nmdeved
             aux_vltotbge     @ tel_vltotal
             WITH FRAME f_param_rodape.

      IF   NOT AVAIL cratbge   THEN
           NEXT.
      
      IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "1"   THEN
          DO:
                /*** Tipo de Devedor ***/
                FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                     AND crapass.nrcpfcgc = cratbge.nrcpfcgc
                                      NO-LOCK NO-ERROR.
      
                IF   AVAIL crapass  THEN
                     DISP  crapass.nmprimtl @ tel_nmdeved
                           aux_vltotbge     @ tel_vltotal
                           WITH FRAME f_param_rodape.
          END.
       ELSE 
       IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "2"   THEN
          DO:
                /* conjuge */
                FIND FIRST crapcje WHERE crapcje.cdcooper = glb_cdcooper
                                     AND crapcje.nrcpfcjg = cratbge.nrcpfcgc
                                      NO-LOCK NO-ERROR.
      
                IF   AVAIL crapcje THEN
                     DISP  crapcje.nmconjug @ tel_nmdeved
                           aux_vltotbge     @ tel_vltotal
                           WITH FRAME f_param_rodape.
          END.
       ELSE 
       IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "3"   THEN
          DO:
                /* 2o titular */
                FIND FIRST crapttl WHERE crapttl.cdcooper = glb_cdcooper
                                     AND crapttl.nrcpfcgc = cratbge.nrcpfcgc
                                      NO-LOCK NO-ERROR.
                IF AVAIL crapttl THEN
                   DISP  crapttl.nmextttl @ tel_nmdeved
                         aux_vltotbge     @ tel_vltotal
                         WITH FRAME f_param_rodape.
                    
          END.
       ELSE 
       IF CAN-DO("4,6,7", SUBSTR(STRING(cratbge.tpddeved), 1, 1)) THEN
          DO:
                /* Responsavel Legal, procurador e avalista terceiro */
                FIND FIRST crapavt WHERE crapavt.cdcooper = glb_cdcooper
                                     AND crapavt.nrcpfcgc = cratbge.nrcpfcgc
                                      NO-LOCK NO-ERROR.
      
                IF   AVAIL crapavt  THEN
                     DISP  crapavt.nmdavali @ tel_nmdeved
                           aux_vltotbge     @ tel_vltotal
                           WITH FRAME f_param_rodape.
          END.
       ELSE 
       IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "5"   THEN
          DO:
                 /* Avalista cooperado */
                 FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                     AND crapass.nrcpfcgc = cratbge.nrcpfcgc
                                      NO-LOCK NO-ERROR.
      
                IF   AVAIL crapass  THEN
                     DISP  crapass.nmprimtl @ tel_nmdeved
                           aux_vltotbge     @ tel_vltotal
                           WITH FRAME f_param_rodape.
          END.
   END.

VIEW FRAME f_moldura.

PAUSE(0).

/* Usado para criticar acesso aos operadadores */
glb_cddopcao = "C".

ASSIGN glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      HIDE FRAME f_param_rodape.
 
      HIDE FRAME f_param_rel.
                 
      HIDE FRAME f_param.
 
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.
      
      UPDATE glb_cddopcao
             WITH FRAME f_param.
             
      IF   aux_cddopcao <> glb_cddopcao   THEN
           DO:
               { includes/acesso.i }
               aux_cddopcao = glb_cddopcao.
           END. 

      IF glb_cddopcao = "C" THEN
         DO:
             UPDATE tel_nrcpfcgc 
                    WITH FRAME f_param.
    
         END.
      ELSE 
         IF glb_cddopcao = "R" THEN
             DO:
                 UPDATE tel_nrcpfcgc 
                        WITH FRAME f_param_rel.
             END.
         ELSE
         IF glb_cddopcao = "G" THEN
            DO:           
                 UPDATE resp WITH ROW 22 COLUMN 15 NO-BOX OVERLAY
                                  SIDE-LABELS FRAME f_resp.
                 HIDE FRAME f_resp.
       
                 IF resp THEN 
                    RUN gerar_base.
            END.

      IF CAN-DO("C,R",glb_cddopcao)   THEN
         DO:
             ASSIGN tel_nmprimtl = "".
             IF tel_nrcpfcgc = 0 THEN
                DO:
                   IF glb_cddopcao = "C" THEN
                      DISPLAY "Todos" @ tel_nmprimtl WITH FRAME f_param.
                   ELSE
                      DISPLAY "Todos" @ tel_nmprimtl WITH FRAME f_param_rel.      
                END.
             ELSE
             DO:
                 FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                      AND crapass.nrcpfcgc = tel_nrcpfcgc
                                       NO-LOCK NO-ERROR.
      
                 IF   NOT AVAIL crapass  THEN
                      DO:
                         glb_cdcritic = 9.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                      END.
                 ELSE
                      DO:
                          ASSIGN tel_nmprimtl = crapass.nmprimtl.
                          IF glb_cddopcao = "C" THEN
                             DISPLAY tel_nmprimtl WITH FRAME f_param.
                          ELSE
                             DISPLAY tel_nmprimtl WITH FRAME f_param_rel.
                      END.
             END.
             
             IF glb_cddopcao = "C" THEN
                DO:
                    UPDATE tel_vlfiltro
                      WITH FRAME f_param.
                END.
             ELSE 
             IF glb_cddopcao = "R" THEN
                DO:
                    UPDATE tel_vlfiltro
                           tel_nmdopcao
                      WITH FRAME f_param_rel.
                END.
         END.
      
      IF glb_cddopcao = "C" THEN
         DO:
             RUN criar-tt-crapbge.
             aux_query = "FOR EACH cratbge NO-LOCK BY cratbge.nrcpfcgc".
             QUERY q_crapbge:QUERY-CLOSE().
             QUERY q_crapbge:QUERY-PREPARE(aux_query).

             MESSAGE "Aguarde...".
             QUERY q_crapbge:QUERY-OPEN().
         
             HIDE MESSAGE NO-PAUSE.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                ENABLE b_crapbge WITH FRAME f_crapbge.

                APPLY "VALUE-CHANGED" TO b_crapbge.

                WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                                        
                HIDE FRAME f_crapbge.
                HIDE FRAME f_param_rodape.
             
                HIDE MESSAGE NO-PAUSE.
                LEAVE.

             END.  /*  Fim do DO WHILE TRUE  */
         END.
      ELSE
         IF glb_cddopcao = "R" THEN
            DO:
                RUN criar-tt-crapbge.
                RUN executa_relatorio.
            END.    
           
    END.  /*  Fim do DO WHILE TRUE  */

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  /*   F4 OU FIM   */
         DO:
               RUN fontes/novatela.p.
               IF   CAPS(glb_nmdatela) <> "DSCUSR"  THEN
                   DO:
                        HIDE FRAME f_param.
                        HIDE FRAME f_moldura.
                        RETURN.
                   END.
               ELSE
                   NEXT.
         END.
END.


PROCEDURE criar-tt-crapbge.

   ASSIGN aux_vltotbge = 0.
   EMPTY TEMP-TABLE crattot.
   EMPTY TEMP-TABLE cratbge.
   
   /* ler base de analise de grupo economico para consistir 
      filtro de valor */
   FOR EACH crapbge NO-LOCK WHERE crapbge.cdcooper = glb_cdcooper
                              AND (crapbge.nrcpfcgc = tel_nrcpfcgc
                               OR  tel_nrcpfcgc = 0)
                         BREAK BY crapbge.nrcpfcgc BY crapbge.tpddeved:
       
       ASSIGN aux_vltotbge = aux_vltotbge + crapbge.vldsaldo.
   
       IF LAST-OF(crapbge.nrcpfcgc) THEN
          DO:
               IF aux_vltotbge >= tel_vlfiltro THEN
                  DO:
                      CREATE crattot.
                      ASSIGN crattot.cdcooper = crapbge.cdcooper
                             crattot.nrcpfcgc = crapbge.nrcpfcgc
                             crattot.vldsaldo = crapbge.vldsaldo.
                  END.
                  
               ASSIGN aux_vltotbge = 0.
          END.
                             
   END.

   ASSIGN aux_vltotbge = 0.

   /* ler base de analise de grupo economico e inserir conforme 
      filtros da tela */
   FOR EACH crapbge NO-LOCK WHERE crapbge.cdcooper = glb_cdcooper
                              AND (crapbge.nrcpfcgc = tel_nrcpfcgc
                               OR  tel_nrcpfcgc = 0)
                         BREAK BY crapbge.nrcpfcgc BY crapbge.tpddeved:
       
       FIND FIRST crattot WHERE crattot.cdcooper = glb_cdcooper
                            AND crattot.nrcpfcgc = crapbge.nrcpfcgc 
                                NO-LOCK NO-ERROR.
             
       IF AVAIL crattot THEN
          DO:
                 CREATE cratbge.
                 ASSIGN cratbge.cdcooper = crapbge.cdcooper
                        cratbge.nrdconta = crapbge.nrdconta
                        cratbge.nrctrato = crapbge.nrctrato
                        cratbge.vldsaldo = crapbge.vldsaldo
                        cratbge.tpdsaldo = crapbge.tpdsaldo
                        cratbge.dtmvtolt = crapbge.dtmvtolt
                        cratbge.nrcpfcgc = crapbge.nrcpfcgc
                        cratbge.tpddeved = crapbge.tpddeved.
   
                 ASSIGN aux_vltotbge = aux_vltotbge + crapbge.vldsaldo.   
          END.
                             
   END.

END PROCEDURE.


/************************************************************************
   Objetivo  : Geracao de base de dados para analise de informacoes de 
               grupo economico (popula tabela crapbge).
*************************************************************************/
PROCEDURE gerar_base.

   DEF VAR aux_tpddeved AS INT FORMAT ">>9" NO-UNDO.
   DEF BUFFER b-crapass for crapass.
   DEF BUFFER b-crapbge for crapbge.
   
   MESSAGE "Aguarde, Base de Dados estah sendo gerada .....".
   
   FOR EACH crapbge WHERE crapbge.cdcooper = glb_cdcooper EXCLUSIVE-LOCK:
       DELETE crapbge.
   END. 

   FOR EACH crapsdv WHERE crapsdv.cdcooper = glb_cdcooper
                   AND crapsdv.tpdsaldo <> 7  /* Aplicacoes */
                   AND crapsdv.tpdsaldo <> 8  /* Poupanca Programada */
                       NO-LOCK,
       FIRST crapass WHERE crapass.cdcooper = crapsdv.cdcooper
                       AND crapass.nrdconta = crapsdv.nrdconta
                           NO-LOCK:
       
        /*** informacoes do DEVEDOR ***/
        RUN insere (INPUT crapass.nrcpfcgc
                   ,INPUT 10).
                      
        /*** informacoes de titulares ***/
        FOR EACH crapttl WHERE crapttl.cdcooper = glb_cdcooper
                           AND crapttl.nrdconta = crapsdv.nrdconta
                           AND crapttl.idseqttl > 1 /* conjuge do 1o titular */    
                           NO-LOCK:
              
               ASSIGN aux_tpddeved = INT('3' + TRIM(STRING(crapttl.idseqttl))).
               
               RUN insere (INPUT crapttl.nrcpfcgc
                          ,INPUT aux_tpddeved).
        END.
    
        /*** informacoes do Conjuge ***/
        FOR EACH crapcje WHERE crapcje.cdcooper = glb_cdcooper
                           AND crapcje.nrdconta = crapsdv.nrdconta
                           AND crapcje.idseqttl = 1 /* conjuge do 1o titular */
                           NO-LOCK:
        
            /* desconsiderar quando nao possuir CPF */                
            IF crapcje.nrcpfcjg <> 0 THEN
               DO:
                   /* Verificar se para o CPF ja foi inserido como 2o Titular.
                      Em caso positivo, nao eh necessario inserir o Conjuge    */
                   FIND FIRST b-crapbge NO-LOCK
                        WHERE b-crapbge.cdcooper = glb_cdcooper
                          AND b-crapbge.nrcpfcgc = crapcje.nrcpfcjg NO-ERROR.
                   
                   IF NOT AVAIL b-crapbge THEN
                          RUN insere (INPUT crapcje.nrcpfcjg
                                     ,INPUT 20).
               END.
        END.                    
 
        /*** informacoes de responsavel legal ***/
        ASSIGN aux_tpddeved = 40.
        FOR EACH crapavt WHERE crapavt.cdcooper = glb_cdcooper
                           AND crapavt.nrdconta = crapsdv.nrdconta
                           AND crapavt.nrctremp = crapsdv.nrctrato
                           AND crapavt.tpctrato = 7 NO-LOCK:
        
            IF crapavt.nrcpfcgc <> 0 THEN
               DO:   
                   ASSIGN aux_tpddeved = aux_tpddeved + 1.
               
                   RUN insere (INPUT crapavt.nrcpfcgc
                              ,INPUT aux_tpddeved).
               END.
        END.

        /*** informacoes de Avalista ***/
        ASSIGN aux_tpddeved = 50.
        FOR EACH crapavl WHERE crapavl.cdcooper = glb_cdcooper
                           AND crapavl.nrdconta = crapsdv.nrdconta /* conta */
                           AND crapavl.nrctravd = crapsdv.nrctrato /* contrato */
                           AND crapavl.tpctrato = crapsdv.tpdsaldo  NO-LOCK
          ,FIRST b-crapass WHERE b-crapass.cdcooper = crapavl.cdcooper
                             AND b-crapass.nrdconta = crapavl.nrdconta NO-LOCK:
        
               /* verificar se contrato esta ativo */
               
               ASSIGN aux_tpddeved = aux_tpddeved + 1.
               
               RUN insere (INPUT b-crapass.nrcpfcgc
                          ,INPUT aux_tpddeved).                       
        END.

        /*** informacoes de avalista nao cooperado ***/
        ASSIGN aux_tpddeved = 60.
        
        FOR EACH crapavt WHERE crapavt.cdcooper = glb_cdcooper
                           AND crapavt.nrdconta = crapsdv.nrdconta
                           AND crapavt.nrctremp = crapsdv.nrctrato
                           AND (crapavt.tpctrato <> 5 AND
                                crapavt.tpctrato <> 6 AND 
                                crapavt.tpctrato <> 7) NO-LOCK:
        
               IF crapavt.nrcpfcgc <> 0 THEN
                  DO:
                     ASSIGN aux_tpddeved = aux_tpddeved + 1.
               
                     RUN insere (INPUT crapavt.nrcpfcgc
                                ,INPUT aux_tpddeved).                       
                  END.
        END.

        /*** informacoes de procuradores ***/
        ASSIGN aux_tpddeved = 70.

        FOR EACH crapavt WHERE crapavt.cdcooper = glb_cdcooper
                           AND crapavt.nrdconta = crapsdv.nrdconta
                           AND crapavt.nrctremp = crapsdv.nrctrato
                           AND crapavt.tpctrato = 6 NO-LOCK:
        
            IF crapavt.nrcpfcgc <> 0 THEN
               DO:   
                   ASSIGN aux_tpddeved = aux_tpddeved + 1.
               
                   RUN insere (INPUT crapavt.nrcpfcgc
                              ,INPUT aux_tpddeved).
               END.
        END.

   END.

   HIDE MESSAGE NO-PAUSE.
   MESSAGE "Base de Dados gerada com sucesso .....".

END PROCEDURE.


PROCEDURE insere.

   DEF INPUT PARAMETER pnrcpfcgc AS DEC FORMAT "zzzzzzzzzzzzz9" NO-UNDO.
   DEF INPUT PARAMETER ptpddeved AS INT FORMAT "zz9"            NO-UNDO.


   CREATE crapbge.
   ASSIGN crapbge.cdcooper = crapsdv.cdcooper
          crapbge.nrdconta = crapsdv.nrdconta 
          crapbge.nrctrato = crapsdv.nrctrato 
          crapbge.vldsaldo = crapsdv.vldsaldo 
          crapbge.tpdsaldo = crapsdv.tpdsaldo 
          crapbge.dtmvtolt = crapsdv.dtmvtolt 
          crapbge.dsdlinha = crapsdv.dsdlinha
          crapbge.dsfinali = crapsdv.dsfinali   
          crapbge.cdlcremp = crapsdv.cdlcremp
          crapbge.qtdriclq = crapsdv.qtdriclq
          crapbge.nrcpfcgc = pnrcpfcgc      
          crapbge.tpddeved = ptpddeved.

END PROCEDURE.


PROCEDURE executa_relatorio:

   DEF VAR aux_flgexist AS LOGICAL                                  NO-UNDO.
   DEF VAR aux_confirma AS CHAR FORMAT "x(1)"                       NO-UNDO.
   DEF VAR par_flgcance AS LOGICAL                                  NO-UNDO.
   DEF VAR par_flgrodar AS LOGICAL    INIT TRUE                     NO-UNDO.
   DEF VAR par_flgfirst AS LOGICAL    INIT TRUE                     NO-UNDO.
                    
   DEF VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
   DEF VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar"      NO-UNDO. 
   DEF VAR tel_nmarquiv AS CHAR  FORMAT "x(25)"                     NO-UNDO.
   DEF VAR tel_nmdireto AS CHAR  FORMAT "x(20)"                     NO-UNDO.
                    
   DEF VAR aux_flgescra AS LOGICAL                                  NO-UNDO.
   DEF VAR aux_dscomand AS CHAR                                     NO-UNDO.
   DEF VAR aux_contador AS INT                                      NO-UNDO.
                    
   DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
   DEF VAR aux_nmendter AS CHAR FORMAT "x(20)"                      NO-UNDO.   
                    
   DEF VAR rel_nmempres AS CHAR  FORMAT "x(15)"                     NO-UNDO.
   DEF VAR rel_nmrelato AS CHAR  FORMAT "x(40)" EXTENT 5            NO-UNDO.
   DEF VAR rel_nrmodulo AS INT   FORMAT "9"                         NO-UNDO.
                    
   DEF VAR rel_nmresemp AS CHAR                                     NO-UNDO.
   DEF VAR rel_nmmodulo AS CHAR  FORMAT "x(15)" EXTENT 5
                                    INIT ["DEP. A VISTA   ",
                                                "CAPITAL        ",
                                                "EMPRESTIMOS    ",
                                                "DIGITACAO      ",
                                                "GENERICO       "]  NO-UNDO.
   
   FORM cratbge.nrcpfcgc AT 02 LABEL "CPF"
        aux_dstpdev      AT 18 LABEL "Tp Devedor"
        cratbge.nrdconta AT 29 LABEL "Conta"     
        aux_tpdsaldo     AT 40 LABEL "Tp Operacao"
        cratbge.nrctrato AT 55 LABEL "Contrato"
        cratbge.vldsaldo AT 65 LABEL "Valor"      FORMAT ">>>>>,>>9.99"
        WITH ROW 12 COLUMN 2 NO-BOX NO-LABELS 9 DOWN OVERLAY FRAME f_lanctos.


   FORM "Diretorio:   "     AT 5
        tel_nmdireto          
        tel_nmarquiv        HELP "Informe o nome do arquivo."
        WITH OVERLAY ROW 10 NO-LABEL NO-BOX COLUMN 2 FRAME f_diretorio.

    INPUT THROUGH basename `tty` NO-ECHO.

    SET aux_nmendter WITH FRAME f_terminal.

    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.
    
    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
    IF  tel_nmdopcao  THEN
        DO:
            ASSIGN tel_nmdireto = "/micros/" + crapcop.dsdircop + "/".
            
            DISP tel_nmdireto WITH FRAME f_diretorio.
            
            UPDATE tel_nmarquiv WITH FRAME f_diretorio.
            
            ASSIGN aux_nmarqimp = tel_nmdireto + tel_nmarquiv.
        END.
    ELSE
        ASSIGN aux_nmarqimp = "rl/crrl514.lst" .
   
    /* Inicializa Variaveis Relatorio */
       ASSIGN glb_cdcritic = 0
              glb_cdrelato[1] = 514.
             
    { includes/cabrel080_1.i }
   
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 80.
   
    VIEW STREAM str_1 FRAME f_cabrel080_1.

     
    FOR EACH cratbge NO-LOCK:

       /* Tipo de Operacao */
       IF cratbge.tpdsaldo = 1   THEN
          ASSIGN aux_tpdsaldo = "Emprestimo".
       ELSE 
          IF cratbge.tpdsaldo = 2 THEN
             ASSIGN aux_tpdsaldo = "Desc.Cheque".
       ELSE 
          IF cratbge.tpdsaldo = 3 THEN
             ASSIGN aux_tpdsaldo = "Desc.Titulos".
       ELSE 
          IF cratbge.tpdsaldo = 4 THEN
             ASSIGN aux_tpdsaldo = "Cartao". 
       ELSE 
          IF cratbge.tpdsaldo = 5 THEN
             ASSIGN aux_tpdsaldo = "Credito Liq".
       ELSE 
          IF cratbge.tpdsaldo = 6 THEN
             ASSIGN aux_tpdsaldo = "Limite Credito".
       ELSE 
          IF cratbge.tpdsaldo = 7 THEN
             ASSIGN aux_tpdsaldo  = "Aplicacoes".
       ELSE 
          IF cratbge.tpdsaldo = 8 THEN
             ASSIGN aux_tpdsaldo = "Poup. Progr".
                                               
       /*** Tipo de Devedor ***/
       IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "1"   THEN
          ASSIGN aux_dstpdev = "Devedor".
       ELSE 
          IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "2"   THEN
             ASSIGN aux_dstpdev = "Conjuge".
       ELSE 
          IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "3"   THEN
             ASSIGN aux_dstpdev = "2o Titular".
       ELSE 
          IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "4"   THEN
             ASSIGN aux_dstpdev = "Resp. Legal".
       ELSE 
          IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "5"   THEN
             ASSIGN aux_dstpdev = "Avalista".
       ELSE 
          IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "6"   THEN
             ASSIGN aux_dstpdev = "Aval. Terc".
       ELSE                                         
          IF SUBSTR(STRING(cratbge.tpddeved), 1, 1)  = "7"   THEN
             ASSIGN aux_dstpdev  = "Procurad.".
            
       DISPLAY STREAM str_1 cratbge.nrcpfcgc 
                            aux_dstpdev
                            cratbge.nrdconta 
                            aux_tpdsaldo
                            cratbge.nrctrato 
                            cratbge.vldsaldo 
                            WITH FRAME f_lanctos.
                              
       DOWN STREAM str_1 WITH FRAME f_lanctos.
                
       ASSIGN aux_flgexist = TRUE.

    END.
            
    OUTPUT STREAM str_1 CLOSE.    /* fim do arquivo */
            
    IF  tel_nmdopcao  THEN
        DO:
            UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + aux_nmarqimp + 
                              "_copy").
                                           
            UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + "_copy" +
                              ' | tr -d "\032" > ' + aux_nmarqimp +
                              " 2>/dev/null").
                        
            UNIX SILENT VALUE("rm " + aux_nmarqimp + "_copy").

            BELL.
            MESSAGE "Arquivo gerado com sucesso no diretorio: " + aux_nmarqimp.
            PAUSE 3 NO-MESSAGE.
        END.
    ELSE
        IF  aux_flgexist  THEN
            DO:
                RUN confirma.
                IF  aux_confirma = "S"  THEN
                    DO:
                        ASSIGN  glb_nmformul = "80col"
                                glb_nrcopias = 1
                                glb_nmarqimp = aux_nmarqimp.
                        
                        FIND FIRST crapass NO-LOCK WHERE 
                                   crapass.cdcooper = glb_cdcooper NO-ERROR. 
                    
                        { includes/impressao.i }
                    END.
            END.
        ELSE
            DO:
                ASSIGN glb_cdcritic = 263.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.
            
    HIDE FRAME f_diretorio.
    HIDE FRAME f_dados.

END PROCEDURE.

/* .......................................................................... */
