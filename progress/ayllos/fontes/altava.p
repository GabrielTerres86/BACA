/* .............................................................................

   Programa: Fontes/altava.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/93.                         Ultima atualizacao: 02/12/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ALTAVA - Alteracao dos avalistas do emprestimo.

   Alteracoes: 16/08/94 - Alterado para impedir o cadastramento de avalistas de-
                          mitidos. (Deborah).

               19/11/96 - Alterado para arrumar a picture de nrctremp (Odair).

               31/10/97 - Tratar idade dos avalistas (Odair)

               04/03/98 - Tratar datas (Odair)

               25/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               04/09/2003 - Alterado para aceitar alterar apenas um aval
                            (Edson).

               25/06/2004 - Permitir alterar avalistas Terceiros(Mirtes)
               
               17/08/2004 - Incluido campos cidade/uf/cep(Evandro).
               
               30/08/2004 - Incluida a possibilidade de impressao do TERMO
                            ADITIVO, quando for alterado algum avalista
                            (Evandro).
                            
               04/11/2004 - Incluida a "colocacao" do nome do avalista na
                            tabela CRAPADI e modificado o layout da impressao
                            para poder perfurar na lateral esquerda da folha
                            (Evandro).
                            
               10/12/2004 - Incluido titulo do aditivo na impressao (Evandro).
               
               17/12/2004 - Incluido codigo e nome do operador;
                            Imprimir 2 vias (Evandro).
                            
               22/12/2004 - Alterado tamanho do numero do aditivo na impressao;
                            (Evandro).

               23/06/2005 - Alimentado campo cdcooper das tabelas crapavl,
                            crapavt,crapadt,crapadi (Diego). 

               20/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapadt (Diego).
                            
               10/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                            
               19/05/2006 - Modificados campos referente endereco para a
                            estrutura crapenc (Diego).
               07/04/2008 - Alterado o formato do campo "qtpreemp" de "z9" 
                            para "zz9" 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               05/08/2009 - Alterado campos nmdsecao e cdgraupr (crapass) 
                            para a tabela crapttl - Paulo - Precise
                            
               30/11/2010 - 001 - Alterado format de "x(40)" para "x(50)"
                            KBASE - Kamila Ploharski de Oliveira
                            
               29/04/2011 - Snclusão de CEP integrado, variaveis nrendere, 
                            complend e nrcxapst para avalistas. (André - DB1)
                            
               14/07/2011 - Voltar atras quando F4/END-ERROR no programa que
                            trata dos avalistas (Gabriel).    
                                     
               14/12/2011 - Adaptado fonte para o uso de BO. 
                            (Rogerius Militao - DB1 ).
                            
               28/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Andrino-RKAM)
                            
               06/06/2014 - Adicionado novos campos inpessoa e dtnascto
                            para avalista 1 e 2 (Daniel)             
                            
               17/11/2014 - Impressao a traves da BO b1wgen0115 (Aditivos)
                            (Jonata-RKAM).             
                                             
               25/05/2015 - Incluir glb_cdagenci na grava_dados 
                           (Lucas Ranghetti #288277)

               02/12/2015 - Retirar find da crapope na procedure Grava_Dados
                            (Lucas Ranghetti #366888 )
............................................................................. */

{ sistema/generico/includes/b1wgen0126tt.i }
{ sistema/generico/includes/var_internet.i }

{ includes/ctremp.i "NEW"}
{ includes/var_online.i }
{ includes/var_atenda.i "NEW"}
{ includes/var_altava.i "NEW"}


DEF VAR h-b1wgen0126 AS HANDLE                                         NO-UNDO.

DEF            VAR aux_nrctremx AS INTE                                NO-UNDO.

DEF            VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"  NO-UNDO.
DEF            VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"  NO-UNDO.

DEF            VAR aux_confirma AS CHAR FORMAT "!"                     NO-UNDO.
DEF NEW SHARED VAR aux_ddmesnov AS INT                                 NO-UNDO.
DEF NEW SHARED VAR tel_dtdpagto AS DATE                                NO-UNDO.
DEF NEW SHARED VAR tel_flgpagto AS LOGI                                NO-UNDO.

DEF            VAR tel_nrctremp AS INT  FORMAT "zz,zzz,zz9"            NO-UNDO.
DEF            VAR tel_nrraval1 AS INT  FORMAT "z,zz9"                 NO-UNDO.
DEF            VAR tel_nrraval2 AS INT  FORMAT "z,zz9"                 NO-UNDO.
DEF            VAR tel_nmprimtl AS CHAR FORMAT "x(50)"                 NO-UNDO. 
DEF            VAR tel_cdpesqui AS CHAR FORMAT "x(22)"                 NO-UNDO.
DEF            VAR tel_nmdaval1 AS CHAR FORMAT "x(42)"                 NO-UNDO.
DEF            VAR tel_nmdaval2 AS CHAR FORMAT "x(42)"                 NO-UNDO.
DEF            VAR aux_cdagenci AS INTE                                NO-UNDO.

FORM SKIP(1)
     tel_nrdconta             AT  2 LABEL "Conta/dv" AUTO-RETURN
                                    HELP "Informe a Conta/DV ou F7 para pesquisar."
     tel_nmprimtl             AT 26 LABEL "Titular" FORMAT "x(40)"
     SKIP(1)                
     tel_nrctremp             AT  2 LABEL "Contrato" AUTO-RETURN
                              HELP "Informe o numero do contrato ou F7 para listar."
     tt-contrato.dslcremp     AT 23 LABEL "L. Credito"
     SKIP
     tt-contrato.dsfinemp     AT 23 LABEL "Finalidade"
     SKIP(1)
     tt-contrato.vlemprst     AT  2 LABEL "Valor emprestado"
     tt-contrato.vlpreemp     AT 40 LABEL "Prestacao"
     tt-contrato.qtpreemp     AT 70 LABEL "Qtd"
     SKIP(8)
     WITH ROW 4 NO-LABELS SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80
          FRAME f_altava.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE " IMPRESSAO DO TERMO ADITIVO " FRAME f_atencao.

FORM "Aguarde... Imprimindo TERMO ADITIVO..."
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

ASSIGN glb_cddopcao = "A"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.
   CLEAR FRAME f_altava NO-PAUSE. 
   ASSIGN tel_nrdconta = 0.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_nrdconta WITH FRAME f_altava
      EDITING:
          READKEY.
          IF  FRAME-FIELD = "tel_nrdconta" AND
              LASTKEY = KEYCODE("F7")      THEN
              DO: 
                  RUN fontes/zoom_associados.p ( INPUT glb_cdcooper,
                                                OUTPUT aux_nrdconta).

                  IF  aux_nrdconta > 0 THEN
                      DO:
                          ASSIGN tel_nrdconta = aux_nrdconta.
                          DISPLAY tel_nrdconta WITH FRAME f_altava.
                          PAUSE 0.
                          APPLY "RETURN".
                      END.
              END.
          ELSE
              APPLY LASTKEY.

      END.  /*  Fim do EDITING  */
        
      RUN Busca_Dados.

      IF  RETURN-VALUE <> "OK" THEN
          NEXT.
      ELSE
          DO:
              ASSIGN tel_nrctremp = 0.
              LEAVE.
          END.

   END.  /*  Fim do WHILE TRUE  */
    
   /*   F4 OU FIM   */
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "altava"   THEN
                 DO:
                     IF  VALID-HANDLE(h-b1wgen0126)  THEN
                         DELETE PROCEDURE h-b1wgen0126.

                     HIDE FRAME f_altava.
                     RETURN.
                 END.
            ELSE
                DO:
                     NEXT.
                END.
        END.

   IF  aux_cddopcao <> glb_cddopcao   THEN
       DO:
           { includes/acesso.i}
           ASSIGN aux_cddopcao = glb_cddopcao.
       END.
    
   DO WHILE TRUE:
        
       IF   aux_nrctatos = 1   THEN
            DO:
                NEXT-PROMPT tel_dtcalcul WITH FRAME f_altava.
                ASSIGN tel_nrctremp = aux_nrctremp.
             END.
       ELSE
            DO:
               UPDATE tel_nrctremp WITH FRAME f_altava
               EDITING:
                   READKEY.
                   IF  LASTKEY = KEYCODE("F7")   THEN
                       DO:
                           RUN fontes/zoom_emprestimos.p 
                               ( INPUT glb_cdcooper,
                                 INPUT 0,           
                                 INPUT 0,           
                                 INPUT glb_cdoperad,
                                 INPUT tel_nrdconta,
                                 INPUT glb_dtmvtolt,
                                 INPUT glb_dtmvtopr,
                                 INPUT glb_inproces,
                                OUTPUT aux_nrctremx ).
      
                           IF  aux_nrctremx > 0   THEN
                               DO:
                                   ASSIGN tel_nrctremp = aux_nrctremx.
                                   DISPLAY tel_nrctremp WITH FRAME f_altava.
                                   PAUSE 0.
                                   APPLY "RETURN".
                               END.
                       END.
                   ELSE
                       APPLY LASTKEY.
      
               END.  /*  Fim do EDITING  */
            END. /* ELSE */

       ASSIGN pro_nrctaav1     = 0
              pro_nmdaval1     = " "
              pro_cpfcgc1      = 0
              pro_tpdocav1     = " " 
              pro_dscpfav1     = " "
              pro_nmcjgav1     = " "
              pro_cpfccg1      = 0
              pro_tpdoccj1     = " " 
              pro_dscfcav1     = " "
              pro_dsendav1[1]  = " "
              pro_dsendav1[2]  = " "
              pro_nrfonres1    = " "
              pro_dsdemail1    = " "
              pro_nmcidade1    = " "
              pro_cdufresd1    = " "
              pro_nrcepend1    = 0
              pro_nrendere1    = 0
              pro_nrcxapst1    = 0
              pro_complend1    = ""
              pro_inpessoa1    = 0
              pro_dtnascto1    = ?
              pro_dspessoa1    = "".

       ASSIGN pro_nrctaav2     = 0  
              pro_nmdaval2     = " " 
              pro_cpfcgc2      = 0
              pro_tpdocav2     = " "
              pro_dscpfav2     = " "
              pro_nmcjgav2     = " "
              pro_cpfccg2      = 0
              pro_tpdoccj2     = " " 
              pro_dscfcav2     = " "
              pro_dsendav2[1]  = " "
              pro_dsendav2[2]  = " "
              pro_nrfonres2    = " "
              pro_dsdemail2    = " "
              pro_nmcidade2    = " "
              pro_cdufresd2    = " "
              pro_nrcepend2    = 0
              pro_nrendere2    = 0     
              pro_nrcxapst2    = 0     
              pro_complend2    = ""
              pro_inpessoa2    = 0
              pro_dtnascto2    = ?
              pro_dspessoa2    = "".

      RUN Busca_Contrato.

      IF  RETURN-VALUE <> "OK"  THEN
          DO:
              NEXT-PROMPT tel_nrctremp WITH FRAME f_altava.
              NEXT.
          END.

      RUN fontes/altava_a.p.

      IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
          DO:
              IF  aux_nrctatos = 1 THEN
                  LEAVE.
              ELSE    
                  NEXT.
          END.

      RUN fontes/confirma.p (INPUT "",
                            OUTPUT aux_confirma).

      IF  aux_confirma <> "S" THEN
          NEXT.
      
      RUN Grava_Dados.

      IF  RETURN-VALUE <> "OK" THEN
          NEXT.

      IF  aux_nrctatos = 1   THEN
          LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

END.  /*  Fim do DO WHILE TRUE  */

/* Remove handle*/
IF  VALID-HANDLE(h-b1wgen0126)  THEN
    DELETE PROCEDURE h-b1wgen0126.

/* .......................................................................... */
/* ........................... PROCEDURE INTERNAS ........................... */

PROCEDURE Busca_Dados:
    
    EMPTY TEMP-TABLE tt-infoass.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0126) THEN
        RUN sistema/generico/procedures/b1wgen0126.p
            PERSISTENT SET h-b1wgen0126.

    RUN Busca_Dados IN h-b1wgen0126
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT tel_nrdconta,
          INPUT TRUE, /* flgerlog */
         OUTPUT aux_nrctatos,
         OUTPUT aux_nrctremp,
         OUTPUT TABLE tt-infoass,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0126)  THEN
        DELETE PROCEDURE h-b1wgen0126.

    /* mostra o nome do associado */
    FIND FIRST tt-infoass NO-ERROR.
    
    IF  AVAIL tt-infoass THEN
        ASSIGN tel_nmprimtl = tt-infoass.nmprimtl.
    ELSE
        ASSIGN tel_nmprimtl = "".

    DISPLAY tel_nmprimtl WITH FRAME f_altava.


    /* mostra a critica */
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */


PROCEDURE Busca_Contrato:
    
    EMPTY TEMP-TABLE tt-contrato.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0126) THEN
        RUN sistema/generico/procedures/b1wgen0126.p
            PERSISTENT SET h-b1wgen0126.

    RUN Busca_Contrato IN h-b1wgen0126
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT tel_nrdconta,
          INPUT tel_nrctremp,
          INPUT TRUE, /* flgerlog */
         OUTPUT TABLE tt-contrato,
         OUTPUT TABLE tt-contrato-avalista,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0126)  THEN
        DELETE PROCEDURE h-b1wgen0126.

    /* Mostra a critica */
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
            RETURN "NOK".  
        END.
    ELSE
        DO:
            /* Dados do contrato */
            FIND FIRST tt-contrato NO-ERROR.
            IF  AVAIL tt-contrato THEN
                DO:
                    ASSIGN tel_nrctremp = tt-contrato.nrctremp.  
                    DISPLAY tel_nrctremp
                            tt-contrato.dslcremp  
                            tt-contrato.dsfinemp
                            tt-contrato.vlemprst
                            tt-contrato.vlpreemp
                            tt-contrato.qtpreemp
                            WITH FRAME f_altava.
                END.
                         
            /* Dados do avalista 1 */
            FIND FIRST tt-contrato-avalista WHERE tt-contrato-avalista.nrindice = 1 NO-ERROR.
            IF  AVAIL tt-contrato-avalista THEN
                DO:
                    ASSIGN pro_nrctaav1    = tt-contrato-avalista.nrctaava 
                           pro_nmdaval1    = tt-contrato-avalista.nmdavali
                           pro_dsendav1[1] = tt-contrato-avalista.dsendava[1]
                           pro_nmcjgav1    = tt-contrato-avalista.nmcjgava
                           pro_nmcidade1   = tt-contrato-avalista.nmcidade
                           pro_nrcepend1   = tt-contrato-avalista.nrcepend
                           pro_nrcxapst1   = tt-contrato-avalista.nrcxapst
                           pro_dscpfav1    = tt-contrato-avalista.dscpfava 
                           pro_dsendav1[2] = tt-contrato-avalista.dsendava[2] 
                           pro_dscfcav1    = tt-contrato-avalista.dscfcava
                           pro_cdufresd1   = tt-contrato-avalista.cdufende
                           pro_nrendere1   = tt-contrato-avalista.nrendere
                           pro_complend1   = tt-contrato-avalista.complend
                           pro_cpfcgc1     = tt-contrato-avalista.nrcpfcgc   
                           pro_tpdocav1    = tt-contrato-avalista.tpdocava
                           pro_cpfccg1     = tt-contrato-avalista.nrcpfcjg
                           pro_tpdoccj1    = tt-contrato-avalista.tpdoccjg
                           pro_nrfonres1   = tt-contrato-avalista.nrfonres
                           pro_dsdemail1   = tt-contrato-avalista.dsdemail
                           pro_inpessoa1   = tt-contrato-avalista.inpessoa
                           pro_dtnascto1   = tt-contrato-avalista.dtnascto.

                    IF pro_inpessoa1 = 1   THEN
                          pro_dspessoa1 = "FISICA".
                    ELSE
                      IF pro_inpessoa1 = 2   THEN
                         pro_dspessoa1 = "JURIDICA".
                      ELSE
                         pro_dspessoa1 = "".

                    DISPLAY pro_dsendav1[1]
                            pro_dsendav1[2]
                            pro_nmcidade1
                            pro_cdufresd1
                            pro_nrctaav1   
                            pro_nmdaval1  
                            pro_cpfcgc1
                            pro_tpdocav1
                            pro_dscpfav1
                            pro_nmcjgav1 
                            pro_cpfccg1
                            pro_tpdoccj1
                            pro_dscfcav1
                            pro_nrcepend1
                            pro_nrendere1
                            pro_complend1
                            pro_nrcxapst1
                            pro_nrfonres1
                            pro_dsdemail1
                            pro_inpessoa1
                            pro_dtnascto1
                            WITH FRAME f_promissoria1.
                END.

            /* Dados avalista 2 */
            FIND FIRST tt-contrato-avalista WHERE tt-contrato-avalista.nrindice = 2 NO-ERROR.
            IF  AVAIL tt-contrato-avalista THEN
                DO:
                    ASSIGN pro_nrctaav2    = tt-contrato-avalista.nrctaava 
                           pro_nmdaval2    = tt-contrato-avalista.nmdavali
                           pro_dsendav2[1] = tt-contrato-avalista.dsendava[1]
                           pro_nmcjgav2    = tt-contrato-avalista.nmcjgava
                           pro_nmcidade2   = tt-contrato-avalista.nmcidade
                           pro_nrcepend2   = tt-contrato-avalista.nrcepend
                           pro_nrcxapst2   = tt-contrato-avalista.nrcxapst
                           pro_dscpfav2    = tt-contrato-avalista.dscpfava 
                           pro_dsendav2[2] = tt-contrato-avalista.dsendava[2] 
                           pro_dscfcav2    = tt-contrato-avalista.dscfcava
                           pro_cdufresd2   = tt-contrato-avalista.cdufende
                           pro_nrendere2   = tt-contrato-avalista.nrendere
                           pro_complend2   = tt-contrato-avalista.complend
                           pro_cpfcgc2     = tt-contrato-avalista.nrcpfcgc   
                           pro_tpdocav2    = tt-contrato-avalista.tpdocava
                           pro_cpfccg2     = tt-contrato-avalista.nrcpfcjg
                           pro_tpdoccj2    = tt-contrato-avalista.tpdoccjg
                           pro_nrfonres2   = tt-contrato-avalista.nrfonres
                           pro_dsdemail2   = tt-contrato-avalista.dsdemail
                           pro_inpessoa2   = tt-contrato-avalista.inpessoa
                           pro_dtnascto2   = tt-contrato-avalista.dtnascto.

                    IF pro_inpessoa1 = 1   THEN
                          pro_dspessoa1 = "FISICA".
                    ELSE
                      IF pro_inpessoa1 = 2   THEN
                         pro_dspessoa1 = "JURIDICA".
                      ELSE
                         pro_dspessoa1 = "".

                    DISPLAY pro_dsendav2[1]
                            pro_dsendav2[2]
                            pro_nmcidade2
                            pro_cdufresd2
                            pro_nrctaav2   
                            pro_nmdaval2  
                            pro_cpfcgc2
                            pro_tpdocav2
                            pro_dscpfav2
                            pro_nmcjgav2 
                            pro_cpfccg2
                            pro_tpdoccj2
                            pro_dscfcav2
                            pro_nrcepend2
                            pro_nrendere2
                            pro_complend2
                            pro_nrcxapst2
                            pro_nrfonres2
                            pro_dsdemail2
                            pro_inpessoa2
                            pro_dtnascto2
                            WITH FRAME f_promissoria2.
                END.

        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Contrato */

PROCEDURE Grava_Dados:
    
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0126) THEN
        RUN sistema/generico/procedures/b1wgen0126.p
            PERSISTENT SET h-b1wgen0126.

    RUN Grava_Dados IN h-b1wgen0126
        ( INPUT glb_cdcooper,
          INPUT glb_cdagenci,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT glb_dtmvtolt,
          INPUT 1, /* idorigem */
          INPUT tel_nrdconta,
          INPUT tel_nrctremp,
          INPUT pro_nrctaav1, 
          INPUT pro_cpfcgc1,  
          INPUT pro_nmdaval1, 
          INPUT pro_cpfccg1,  
          INPUT pro_nmcjgav1, 
          INPUT pro_tpdoccj1, 
          INPUT pro_dscfcav1, 
          INPUT pro_tpdocav1, 
          INPUT pro_dscpfav1, 
          INPUT pro_dsendav1[1], 
          INPUT pro_dsendav1[2], 
          INPUT pro_nrfonres1,
          INPUT pro_dsdemail1,
          INPUT pro_nmcidade1,
          INPUT pro_cdufresd1,
          INPUT pro_nrcepend1,
          INPUT pro_nrendere1,
          INPUT pro_complend1,
          INPUT pro_nrcxapst1,
          INPUT pro_inpessoa1,
          INPUT pro_dtnascto1,
          INPUT pro_nrctaav2, 
          INPUT pro_cpfcgc2,  
          INPUT pro_nmdaval2, 
          INPUT pro_cpfccg2,  
          INPUT pro_nmcjgav2, 
          INPUT pro_tpdoccj2, 
          INPUT pro_dscfcav2, 
          INPUT pro_tpdocav2, 
          INPUT pro_dscpfav2, 
          INPUT pro_dsendav2[1], 
          INPUT pro_dsendav2[2], 
          INPUT pro_nrfonres2,
          INPUT pro_dsdemail2,
          INPUT pro_nmcidade2,
          INPUT pro_cdufresd2,
          INPUT pro_nrcepend2,
          INPUT pro_nrendere2,
          INPUT pro_complend2,
          INPUT pro_nrcxapst2,
          INPUT pro_inpessoa2,
          INPUT pro_dtnascto2,
          INPUT TRUE, /* flgerlog */
         OUTPUT TABLE tt-contrato-imprimir,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0126)  THEN
        DELETE PROCEDURE h-b1wgen0126.

    /* Mostra a critica */
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
             PAUSE.
                   
            RETURN "NOK".  
        END.
    ELSE
        IF  TEMP-TABLE tt-contrato-imprimir:HAS-RECORDS THEN
            DO:

              DISPLAY tel_dsimprim tel_dscancel WITH FRAME f_atencao.
              CHOOSE FIELD tel_dsimprim tel_dscancel WITH FRAME f_atencao.

              IF   FRAME-VALUE = tel_dsimprim   THEN
                   DO:

                       VIEW FRAME f_aguarde.
                       PAUSE 3 NO-MESSAGE.
                       HIDE FRAME f_aguarde NO-PAUSE.

                       FOR EACH tt-contrato-imprimir:

                           RUN Gera_Impressao(INPUT tt-contrato-imprimir.nrcpfava,
                                              INPUT tt-contrato-imprimir.nmdavali,
                                              INPUT tt-contrato-imprimir.uladitiv).

                       END. /* FOR EACH tt-contrato-imprimir: */

                   END. /* FRAME-VALUE = tel_dsimprim */

            END. /* FRAME-VALUE = tel_dsimprim  */

    RETURN "OK".

END PROCEDURE. /* Grava_Dados */

PROCEDURE Gera_Impressao:
    
    DEF  INPUT PARAM par_nrcpfava AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_uladitiv AS INTE                           NO-UNDO.

    DEF  VAR  aux_nmarqimp  AS  CHAR                                NO-UNDO.
    DEF  VAR  aux_nmarqpdf  AS  CHAR                                NO-UNDO.
    DEF  VAR  aux_nmendter  AS  CHAR FORMAT "x(20)"                 NO-UNDO.
    DEF  VAR  par_flgrodar  AS  LOGI INIT TRUE                      NO-UNDO.
    DEF  VAR  par_flgfirst  AS  LOGI INIT TRUE                      NO-UNDO.
    DEF  VAR  par_flgcance  AS  LOGI                                NO-UNDO.
    DEF  VAR aux_dscomand AS CHAR                                   NO-UNDO.
    DEF  VAR aux_flgescra AS LOGI                                   NO-UNDO.
    DEF  VAR h-b1wgen0115 AS HANDLE                                 NO-UNDO.                                                               

    EMPTY TEMP-TABLE tt-erro.

    INPUT THROUGH basename `tty` NO-ECHO.
        SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    IF  NOT VALID-HANDLE(h-b1wgen0115) THEN
        RUN sistema/generico/procedures/b1wgen0115.p
            PERSISTENT SET h-b1wgen0115.

    RUN Gera_Impressao IN h-b1wgen0115
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT 1,
          INPUT glb_nmdatela,
          INPUT glb_cdprogra,
          INPUT glb_cdoperad,
          INPUT aux_nmendter,
          INPUT 4,
          INPUT par_uladitiv,
          INPUT tel_nrctremp,
          INPUT tel_nrdconta,
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_inproces,
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0115)  THEN
        DELETE PROCEDURE h-b1wgen0115.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            PAUSE.
                   
            RETURN "NOK".  
        END.
    ELSE
        DO:
            ASSIGN glb_nmformul = '132col'
                   glb_nrdevias = 2 
                   par_flgrodar = TRUE.

            FIND FIRST crapass 
                WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
            { includes/impressao.i }           /*  Rotina de impressao  */
        END.
    
    RETURN "OK".

END PROCEDURE. /* Gera_Impressao */


