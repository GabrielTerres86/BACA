/* .............................................................................

   Programa: Fontes/beinss.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Outubro/2007                        Ultima alteracao: 10/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela BEINSS
               Permitir a consulta dos beneficios recebidos por um determinado
               beneficiario como tambem a movimentacao dos seus beneficios. 
                  
   Alteracao : 04/03/2008 - Incluida coluna especie nos dados dos beneficios
                            (Gabriel).
                            
               31/03/2008 - Exibir os beneficios quando informado o CPF;
                          - Tirada coluna do CPF do browse de nomes (Evandro).
                          
               07/05/2008 - Incluido o PAC no FRAME f_dados2 (Evandro)
                          
                          - Novo campo NB/NIT para busca do beneficiario
                            (Gabriel).

               09/09/2008 - Nao obrigar a informar o campo PAC, listar todos
                            quando nao informado (Gabriel).

               03/12/2008 - Alterado o campo nrdocpcd para dsdocpcd (rosangela).
               
               23/03/2010 - Verificar a data de validade do procurador. 
                            Mostrar esta data na tela. (Gabriel)
                            
               23/05/2011 - Adaptacao para uso de BO. (André - DB1)
               
               23/12/2011 - Ajuste referente a handle preso (Adriano).
               
               08/01/2013 - Realizado a chamada da funcao verificacao_bloqueio 
                            referente ao projeto Prova de Vida (Adriano)

               10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
............................................................................. */
{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0091tt.i }

DEF VAR aux_cddopcao AS CHAR                                    NO-UNDO.

DEF VAR tel_nmrecben         LIKE crapcbi.nmrecben              NO-UNDO.
DEF VAR tel_cdagenci         LIKE crapcbi.cdagenci              NO-UNDO.
DEF VAR tel_nrcpfcgc         LIKE crapcbi.nrcpfcgc              NO-UNDO.
DEF VAR tel_nrcpf    AS CHAR FORMAT "x(18)"                     NO-UNDO.
DEF VAR tel_nrprocur         LIKE crapcbi.nrrecben              NO-UNDO. 
DEF VAR tel_nrbenefi         LIKE crapcbi.nrbenefi              NO-UNDO.
DEF VAR tel_nrrecben         LIKE crapcbi.nrrecben              NO-UNDO.
DEF VAR tel_dsendben         LIKE crapcbi.dsendben              NO-UNDO.
DEF VAR tel_nmbairro         LIKE crapcbi.nmbairro              NO-UNDO.
DEF VAR tel_nrcepend         LIKE crapcbi.nrcepend              NO-UNDO.
DEF VAR tel_dtnasben         LIKE crapcbi.dtnasben              NO-UNDO.
DEF VAR tel_nmmaeben         LIKE crapcbi.nmmaeben              NO-UNDO.
DEF VAR tel_dtatuend         LIKE crapcbi.dtatuend              NO-UNDO.
DEF VAR tel_nmprimtl         LIKE crapass.nmprimtl              NO-UNDO.
DEF VAR tel_dtdinici         LIKE crapcbi.dtmvtolt              NO-UNDO.
DEF VAR tel_dtdfinal         LIKE crapcbi.dtmvtolt              NO-UNDO.

DEF VAR h-b1wgen0091 AS HANDLE                                  NO-UNDO.

DEF VAR aux_nmprocur         LIKE crappbi.nmprocur              NO-UNDO.
DEF VAR aux_dsdocpcd         LIKE crappbi.dsdocpcd              NO-UNDO.
DEF VAR aux_cdoedpcd         LIKE crappbi.cdoedpcd              NO-UNDO.
DEF VAR aux_cdufdpcd         LIKE crappbi.cdufdpcd              NO-UNDO.
DEF VAR aux_dtvalprc         LIKE crappbi.dtvalprc              NO-UNDO.
DEF VAR aux_nrbenefi AS DECI                                    NO-UNDO.
DEF VAR aux_nrrecben AS DECI                                    NO-UNDO.
DEF VAR aux_tpbloque AS INT                                     NO-UNDO.

FORM SKIP(1)
     tel_nrprocur AT 2  LABEL "NB/NIT"
           HELP "Informe o NB ou o NIT para a procura do beneficiario."

     tel_nrcpfcgc AT 32  LABEL "CPF"
           HELP "Informe o CPF ou pressione <ENTER> para procurar por nome."
     tel_cdagenci AT 55 LABEL "PA"
           HELP "Informe o PA credenciado ao INSS ou 0 <zero> para todos."
     SKIP
     tel_nmrecben AT 2 LABEL "Nome"  
           HELP "Informe o nome do beneficiario ou pressione <ENTER> p/ listar."
     SKIP(1)
     tel_dtnasben AT 2  LABEL "Data nascimento"
     tel_nmmaeben AT 32 LABEL "Nome mae"
                        FORMAT "x(36)"
     SKIP                   
     tel_dsendben AT 2  LABEL "Endereco"   
                        FORMAT "x(38)"
     tel_nmbairro AT 54 LABEL "Bairro"
                        FORMAT "x(15)"
     SKIP
     tel_nrcepend AT 2 LABEL "CEP"
     tel_dtatuend AT 18 LABEL "Ultima atualizacao de endereco"
     WITH ROW 5 COLUMN 2 OVERLAY SIDE-LABELS WIDTH 78 NO-BOX FRAME f_beinss.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     tel_dtdinici AT 02 LABEL "Inicio periodo"
                        HELP "Informe a data inicial."
     VALIDATE (tel_dtdinici <> ?, "Informe a data inicial do periodo.")
     tel_dtdfinal AT 30 LABEL "Final periodo"  
                        HELP "Informe a data final."
     VALIDATE (tel_dtdfinal <> ?, "Informe a data final do periodo.")
     SKIP(1)
     tel_nrcpf    AT 02 LABEL "CPF"   
     tel_nmrecben AT 26 LABEL "Nome"
     SKIP
     tel_nrbenefi AT 02 LABEL "NB"
     tel_nrrecben AT 26 LABEL "NIT"
     SKIP(11)
     WITH ROW 4 OVERLAY SIDE-LABELS TITLE glb_tldatela WIDTH 80 FRAME f_dados.

FORM 
    "                        ---Dados do Procurador---" SKIP
    "  Nome                                          RG OE         UF Validade"
    SKIP
    aux_nmprocur NO-LABEL AT 3 FORMAT "x(35)"
    aux_dsdocpcd NO-LABEL                 
    aux_cdoedpcd NO-LABEL
    aux_cdufdpcd NO-LABEL
    aux_dtvalprc NO-LABEL      FORMAT "99/99/99" 
    SKIP(1)
    WITH ROW 17 COLUMN 3 OVERLAY SIDE-LABELS NO-BOX WIDTH 73 FRAME f_dadosp.
     
FORM "                      ---Beneficio sem Procurador---" SKIP
     SKIP(3)
     WITH ROW 17 COLUMN 3 OVERLAY SIDE-LABELS NO-BOX 
     WIDTH 73 FRAME f_dadospn.

DEF QUERY q_dados2 FOR tt-lancred.

DEF BROWSE b_dados2 QUERY q_dados2
    DISP tt-lancred.nrbenefi FORMAT "zzzzzzzzz9"     COLUMN-LABEL "NB"
         tt-lancred.dtinipag FORMAT "99/99/9999"     COLUMN-LABEL "Inicio val"          
         tt-lancred.dtfimpag FORMAT "99/99/9999"     COLUMN-LABEL "Final val"           
         tt-lancred.vlliqcre FORMAT "zzz,zzz,zz9.99" COLUMN-LABEL "Credito"             
         tt-lancred.tpmepgto FORMAT "x(16)"     COLUMN-LABEL "Meio de pagamento"   
         tt-lancred.nrdconta FORMAT "zzzzzzz,9"      COLUMN-LABEL "Conta/dv"            
         tt-lancred.dtdpagto FORMAT "99/99/9999"     COLUMN-LABEL "Data pgto"           
         tt-lancred.flgcredi FORMAT "x(12)"          COLUMN-LABEL "Situacao"               
         tt-lancred.dtflgcre FORMAT "99/99/9999"     COLUMN-LABEL "Data sit"              
         tt-lancred.cdagenci FORMAT "zz9"            COLUMN-LABEL "PA"                 
         tt-lancred.dsespeci FORMAT "x(39)" COLUMN-LABEL "Descricao do beneficio"
         WITH 3 DOWN WIDTH 74 NO-BOX.

DEF QUERY q_nome FOR tt-benefic.

DEF BROWSE b_nome QUERY q_nome
    DISP tt-benefic.nmrecben COLUMN-LABEL "Nome"        FORMAT "x(30)"
         tt-benefic.nrbenefi COLUMN-LABEL "NB"
         tt-benefic.dtnasben COLUMN-LABEL "Nascimento"
         tt-benefic.nmmaeben COLUMN-LABEL "Nome da mae" FORMAT "x(25)"
         tt-benefic.dtatucad COLUMN-LABEL "Dt.Alt.Cad"  FORMAT "99/99/9999"
         WITH 6 DOWN WIDTH 76 NO-BOX SCROLLBAR-VERTICAL.

DEF FRAME f_nome
          b_nome  
    HELP "Pressione <ENTER> p/ detalhar ou <SETAS> p/ navegar."
    WITH CENTERED OVERLAY ROW 11 TITLE " Nomes ".     

DEF FRAME f_dados2
          b_dados2  
    HELP "Pressione <F4> p/ sair ou <SETAS> p/ navegar."
    WITH CENTERED OVERLAY ROW 10 TITLE " Dados do Beneficio ".     


ON RETURN OF b_nome IN FRAME f_nome
   DO:         
      DISABLE b_nome WITH FRAME f_nome.
      HIDE FRAME f_nome.
      
      ASSIGN tel_dtdinici = ?
             tel_dtdfinal = ?.
  
      RUN busca_beneficio.

      ENABLE b_nome WITH FRAME f_nome.
       
      PAUSE 0.
      
     APPLY "ENTRY" TO b_nome IN FRAME f_nome.       
       
   END. /* Fim do ON ENTER */

ON  VALUE-CHANGED, ENTRY OF b_nome
    DO:
        ASSIGN tel_cdagenci = tt-benefic.cdagenci
               tel_nrcpfcgc = tt-benefic.nrcpfcgc
               tel_nmrecben = tt-benefic.nmrecben
               tel_dsendben = tt-benefic.dsendben
               tel_nmbairro = tt-benefic.nmbairro
               tel_nrcepend = tt-benefic.nrcepend
               tel_dtnasben = tt-benefic.dtnasben
               tel_nmmaeben = tt-benefic.nmmaeben
               tel_dtatuend = tt-benefic.dtatuend
               /* Variaveis usadas na query */
               tel_nrrecben = tt-benefic.nrrecben
               tel_nrbenefi = tt-benefic.nrbenefi.

        DISPLAY tel_cdagenci
                tel_nrcpfcgc
                tel_nmrecben
                tel_dsendben
                tel_nmbairro
                tel_nrcepend
                tel_dtnasben
                tel_nmmaeben
                tel_dtatuend
                tel_cdagenci
                WITH FRAME f_beinss.
                      
    END. /* Fim do ON VALEU-CHANGED */

ON VALUE-CHANGED, ENTRY OF b_dados2
   DO:
      IF AVAIL tt-lancred AND tt-lancred.flgexist = TRUE THEN
         DO:
            DISPLAY tt-lancred.nmprocur @ aux_nmprocur 
                    tt-lancred.dsdocpcd @ aux_dsdocpcd
                    tt-lancred.cdoedpcd @ aux_cdoedpcd
                    tt-lancred.cdufdpcd @ aux_cdufdpcd
                    tt-lancred.dtvalprc @ aux_dtvalprc
                    WITH FRAME f_dadosp.
         END.           
      ELSE 
         VIEW FRAME f_dadospn.
      
   END. /* Fim do ON VALUE-CHANGED */   

ASSIGN glb_cdcritic = 0
       glb_cddopcao = "C".

RUN fontes/inicia.p.

VIEW FRAME f_moldura.

PAUSE 0. 

IF NOT VALID-HANDLE(h-b1wgen0091)  THEN
   RUN sistema/generico/procedures/b1wgen0091.p 
       PERSISTENT SET h-b1wgen0091.

INICIO: DO  WHILE TRUE:

    ASSIGN tel_nrprocur = 0
           tel_nrcpfcgc = 0
           tel_cdagenci = 0
           tel_nmrecben = "".
   
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
       IF glb_cdcritic > 0   THEN
          DO:
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              ASSIGN glb_cdcritic = 0.

          END.
   
       ASSIGN tel_nrprocur = 0
              tel_nrcpfcgc = 0
              tel_cdagenci = 0
              tel_nmrecben = ""
              tel_dsendben = ""
              tel_nmbairro = ""
              tel_nrcepend = 0
              tel_dtnasben = ?
              tel_nmmaeben = ""
              tel_dtatuend = ?.
     
       DISPLAY tel_nrprocur
               tel_nrcpfcgc 
               tel_cdagenci
               tel_nmrecben
               tel_dsendben
               tel_nmbairro
               tel_nrcepend
               tel_dtnasben
               tel_nmmaeben
               tel_dtatuend
               WITH FRAME f_beinss.
     
       HIDE FRAME f_dadospn.
       
       IF aux_cddopcao <> glb_cddopcao   THEN
          DO:
              { includes/acesso.i }
              aux_cddopcao = glb_cddopcao.
          END.

       DO WHILE TRUE:

          EMPTY TEMP-TABLE tt-benefic.

          HIDE FRAME f_dadosp
               FRAME f_dadospn.

          UPDATE tel_nrprocur 
                 WITH FRAME f_beinss.
    
          IF tel_nrprocur <> 0  THEN
             DO:
                 RUN busca-dados.

                 IF RETURN-VALUE <> "OK" THEN
                    NEXT Inicio.

             END.
         
          IF NOT TEMP-TABLE tt-benefic:HAS-RECORDS  THEN
             UPDATE tel_nrcpfcgc WITH FRAME f_beinss.
          ELSE
             LEAVE.
    
          IF tel_nrcpfcgc <> 0  THEN
             DO:
                 RUN busca-dados.

                 IF RETURN-VALUE <> "OK" THEN
                    NEXT Inicio.

             END.
    
          IF  NOT TEMP-TABLE tt-benefic:HAS-RECORDS  THEN
              UPDATE tel_cdagenci tel_nmrecben WITH FRAME f_beinss.
          ELSE 
              LEAVE.
          
          RUN busca-dados.

          IF RETURN-VALUE <> "OK" THEN
             NEXT Inicio.
    
          LEAVE.

       END.

       OPEN QUERY q_nome FOR EACH tt-benefic NO-LOCK.
    
       ENABLE b_nome WITH FRAME f_nome.

       PAUSE 0.
    
       WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

       IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
          DO:
              HIDE FRAME f_nome.
              NEXT.

          END.

       HIDE FRAME f_nome.

       HIDE MESSAGE NO-PAUSE.

       LEAVE.
     
    END. /* Fim do DO WHILE TRUE */

    IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
       DO:
           RUN fontes/novatela.p.

           IF CAPS(glb_nmdatela) <> "BEINSS"   THEN
              DO:
                  DISABLE b_nome WITH FRAME f_nome.
                  DISABLE b_dados2 WITH FRAME f_dados2.
                  HIDE FRAME f_procurador
                       FRAME f_beinss
                       FRAME f_dados2
                       FRAME f_dados
                       FRAME f_moldura.

                  IF  VALID-HANDLE(h-b1wgen0091)  THEN
                      DELETE OBJECT h-b1wgen0091.

                  RETURN.
              END.
           ELSE
              LEAVE.

       END.

END.

IF VALID-HANDLE(h-b1wgen0091)  THEN
   DELETE OBJECT h-b1wgen0091.

PROCEDURE busca_beneficio:

   ASSIGN aux_tpbloque = 0.

   IF AVAIL tt-benefic   THEN
      DO:
         ASSIGN tel_nrcpf = STRING(tt-benefic.nrcpfcgc,"99999999999")
                tel_nrcpf = STRING(tel_nrcpf,"xxx.xxx.xxx-xx")
                tel_nmrecben = tt-benefic.nmrecben
                tel_nrrecben = tt-benefic.nrrecben
                tel_nrbenefi = tt-benefic.nrbenefi.
              
         DISPLAY tel_nrcpf
                 tel_nmrecben
                 tel_nrrecben
                 tel_nrbenefi
                 WITH FRAME f_dados.

         ASSIGN aux_tpbloque = DYNAMIC-FUNCTION("verificacao_bloqueio" 
                                                IN h-b1wgen0091,
                                                INPUT glb_cdcooper,
                                                INPUT 0, /*nrdcaixa*/
                                                INPUT glb_cdagenci,
                                                INPUT glb_cdoperad,
                                                INPUT glb_nmdatela, 
                                                INPUT 1, /*ayllos*/
                                                INPUT glb_dtmvtolt,
                                                INPUT tel_nrcpfcgc,
                                                INPUT tel_nrprocur,
                                                INPUT 1 /*Qlqr beneficio*/).
                       
         /*Bloqueio por falta de comprovacao de vida ou comprovacao ainda 
           nao efetuada*/
         IF aux_tpbloque = 1 OR
            aux_tpbloque = 2 THEN
            MESSAGE "Beneficiario com prova de vida pendente. Efetue " + 
                    "comprovacao através da COMPVI.".
         ELSE /*Menos de 60 dias para expirar o perido de um ano da comprovacao*/
            IF aux_tpbloque = 3 THEN
               MESSAGE "Este beneficiario devera efetuar a comprovacao "    + 
                       "de vida para este beneficio. A falta de renovacao " + 
                       "implicara no bloqueio do beneficio pelo INSS.".
                                     
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
             UPDATE tel_dtdinici
                    tel_dtdfinal
                    WITH FRAME f_dados.

             HIDE MESSAGE NO-PAUSE.
             
             RUN busca-beneficio IN h-b1wgen0091(INPUT glb_cdcooper,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT glb_cdoperad,
                                                 INPUT tt-benefic.nrrecben,
                                                 INPUT tt-benefic.nrbenefi,
                                                 INPUT tel_dtdinici,
                                                 INPUT tel_dtdfinal,
                                                 INPUT glb_dtmvtolt,
                                                 OUTPUT TABLE tt-erro,
                                                 OUTPUT TABLE tt-lancred ).
               
             IF RETURN-VALUE <> "OK"  THEN
                DO:
                   FIND FIRST tt-erro NO-ERROR.
                  
                   IF AVAILABLE tt-erro THEN
                      MESSAGE tt-erro.dscritic.
                  
                   LEAVE.

                END.
           
         
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
                OPEN QUERY q_dados2 FOR EACH tt-lancred NO-LOCK.
               
                ENABLE b_dados2 WITH FRAME f_dados2.
               
                PAUSE 0.
                
                APPLY "ENTRY" TO b_dados2 IN FRAME f_dados2.
               
                WAIT-FOR "F4" OF b_dados2. 
               
                IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                   DO:
                      DISABLE b_nome WITH FRAME f_nome.
                      HIDE FRAME f_nome.
                   END.
               
                LEAVE.
              
            END. /* Fim do DO WHILE */
         
         END. /* Fim do DO WHILE */ 
         
         HIDE FRAME f_procurador.
         HIDE FRAME f_dados2.
         HIDE FRAME f_dados.
         HIDE FRAME f_nome.
                        
      END. /* Fim do IF */

END PROCEDURE.


PROCEDURE busca-dados:

    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.

    MESSAGE "Aguarde... buscando beneficiarios.".

    RUN busca-benefic-beinss IN h-b1wgen0091(INPUT glb_cdcooper,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT tel_nmrecben,
                                             INPUT tel_cdagenci,
                                             INPUT tel_nrcpfcgc,
                                             INPUT tel_nrprocur,
                                             INPUT 9999999,
                                             INPUT 1,
                                             OUTPUT aux_qtregist,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-benefic ).

    HIDE MESSAGE NO-PAUSE.

    IF RETURN-VALUE <> "OK"           OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
           FIND FIRST tt-erro NO-ERROR.
         
           IF AVAILABLE tt-erro THEN
              MESSAGE tt-erro.dscritic.
         
           RETURN "NOK".

       END.

    RETURN "OK".

END PROCEDURE.
/* .......................................................................... */


