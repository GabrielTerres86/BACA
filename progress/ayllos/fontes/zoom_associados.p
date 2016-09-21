/*.............................................................................

   Programa: fontes/zoom_associados.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Dezembro/2004                       Ultima alteracao: 12/08/2015
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom do nome dos titular.

   Alteracoes: 06/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
   
               13/02/2006 - Inclusao do parametro par_cdcooper para unificacao
                            dos bancos de dados - SQLWorks - Andre

               05/10/2006 - Consertado para nao gerar erro no "ON RETURN", 
                            caso nao retorne nenhum registro (Diego).

               30/10/2006 - Inclusao de consulta por conta integracao (David).

               26/07/2007 - Adaptacao deste programa para a tela nome (Julio)
               
               07/08/2007 - Alterei a pesquisa por pessoa juridica atraves do 
                            crapass novamente, porque a tabela crapjur possui
                            apenas nome fantasia. (Julio).
               
               10/08/2007 - Acerto do HIDE FRAME f_associado (Diego).

               17/08/2007 - Alteracao da pesquisa por pessoa juridica atraves 
                            do crapjur, foi criado novo campo e novo indice 
                            tipo "word" para esta pesquisa (Julio).
                            
               25/10/2007 - Usar nmdsecao para pessoa fisica a partir da crapttl
                            e "" para pessoa juridica (Guilherme).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).

               16/02/2009 - Correcao na consulta por conta integracao (David).
               
               08/05/2009 - Mostrar somente os associados da cooperativa em
                            questao (Evandro).
                            
               19/05/2010 - Adaptado para usar BO (Jose Luis, DB1)
               
               27/09/2010 - Incluido a opcao de organizar para ordenar por nome
                            do coop. ou, por numero da conta. Trazendo o numero
                            do pac antes do nome do coop (Adriano).
                            
               06/01/2011 - Incluido FORMAT para o campo tt-titular.nmextttl
                            (Diego).
                            
               24/10/2011 - Adicionado a opçao de pesquisa por CPF/CNPJ 
                            (Rogerius Militao).
                            
               15/08/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               26/12/2013 - Alterado FORMAT da tel_cdagenci para "999". (Reinert)
               
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
               
............................................................................. */

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/var_online.i }
{ includes/gg0000.i}

DEF INPUT  PARAM par_cdcooper AS INT                             NO-UNDO.
DEF OUTPUT PARAM par_nrdconta AS INT                             NO-UNDO.

DEF VAR tel_nmprimtl AS CHAR  FORMAT "x(40)"                     NO-UNDO.
DEF VAR tel_nrdctitg AS CHAR  FORMAT "x.xxx.xxx-x"               NO-UNDO.
DEF VAR tel_opnmprim AS CHAR  INIT  "Nome do Titular"            NO-UNDO.
DEF VAR tel_opctaitg AS CHAR  INIT  "Conta Integracao"           NO-UNDO.
DEF VAR tel_opcpfcgc AS CHAR  INIT  "CPF/CNPJ"                   NO-UNDO. 
DEF VAR tel_cdagenci AS INT   INIT 0                             NO-UNDO.
DEF VAR tel_tppesttl AS INT   INIT 0                             NO-UNDO.
DEF VAR aux_cdpesqui AS INT   INIT 0                             NO-UNDO.
DEF VAR tel_tpdorgan AS INT   INIT 1                             NO-UNDO.
DEF VAR tel_nrcpfcgc AS DECI  INIT "" FORMAT "99999999999999"    NO-UNDO.

DEF QUERY  bgnetcvla-q FOR tt-titular. 
DEF BROWSE bgnetcvla-b QUERY bgnetcvla-q
      DISP cdagenci                    COLUMN-LABEL "PA" 
           nrdconta                    COLUMN-LABEL "Conta/dv"
           nmpesttl    FORMAT "x(40)"  COLUMN-LABEL "Nome Pesquisado"
           nrdctitg                    COLUMN-LABEL "Conta/ITG"
           WITH 7 DOWN OVERLAY TITLE " Associados ".

FORM bgnetcvla-b HELP "Use <TAB> para navegar"
     WITH NO-BOX CENTERED OVERLAY ROW 7 FRAME f_alterar.

FORM "Conta/dv:"         tt-titular.nrdconta 
     "-"                 tt-titular.nmextttl FORMAT "x(40)"
     "Emp:"              tt-titular.cdempres FORMAT "zzzz9"    
     SKIP
     "PA:"              tt-titular.dsagenci FORMAT "x(20)" 
     "Conta Itg.:"       tt-titular.nrdctitg 
     "  "                tt-titular.nrdocttl FORMAT "x(25)"
     SKIP
     "Nasc.:"            tt-titular.dtnasttl FORMAT "99/99/9999" 
     "        Demissao:" tt-titular.dtdemiss FORMAT "99/99/9999"
     WITH WIDTH 78 ROW 18 COLUMN 2 OVERLAY NO-LABEL NO-BOX FRAME f_dados.

FORM SKIP(1)
     tel_opnmprim NO-LABEL AT 7 FORMAT "x(15)"
                  HELP "Pesquisar por nome do associado."
     SPACE(4)
     tel_opctaitg NO-LABEL       FORMAT "x(16)"
                  HELP "Pesquisar por conta integracao."

     SPACE(4)
     tel_opcpfcgc NO-LABEL       FORMAT "x(8)"
                  HELP "Pesquisar por CPF/CNPJ do associado."

     SKIP(1)
     tel_nmprimtl LABEL " Nome a pesquisar" 
                  HELP "Informe o nome ou parte dele para efetuar a pesquisa."
     SKIP(1)
     tel_tppesttl LABEL "Tipo Pesquisa" AT 5       FORMAT "9"
                  HELP "0-Titulares, 1-Conjuge, 2-Pai, 3-Mae, 4-Pessoa Juridica"
                  VALIDATE( 
                  ( aux_cdpesqui = 1 AND tel_tppesttl >= 0 AND tel_tppesttl <= 4 ) OR
                  ( aux_cdpesqui = 3 AND tel_tppesttl >= 1 AND tel_tppesttl <= 2 ), 
                    "513 - Tipo errado")  

     SPACE(6)
     tel_cdagenci LABEL "PA" FORMAT "999"
                  HELP "Informe o PA a ser pesquisado ou 0 para todos"
     tel_tpdorgan LABEL "Organizar" FORMAT "9"
                  HELP "1-Nome, 2-Numero da Conta"
                  VALIDATE (tel_tpdorgan = 1 OR tel_tpdorgan = 2,
                            "513 - Tipo errado" )
     
     SKIP(1)
     tel_nrdctitg LABEL " Conta Integracao"
                  HELP "Informe a conta integracao para efetuar a pesquisa."

     SKIP(1)
     tel_nrcpfcgc LABEL "         CPF/CNPJ"
                  HELP "Informe o CPF/CNPJ para efetuar a pesquisa."
                 VALIDATE (tel_nrcpfcgc > 0, "027 - CPF/CNPJ com erro." )


     SKIP(1)
     WITH ROW 8 CENTERED SIDE-LABELS OVERLAY
          TITLE COLOR NORMAL " Pesquisa de Associados "
          FRAME f_associado.

ON VALUE-CHANGED, ENTRY OF bgnetcvla-b DO:
   IF   glb_cdprogra = "NOME"   THEN
        DO:
            DISPLAY 
                tt-titular.nrdconta tt-titular.nmextttl tt-titular.dsagenci
                tt-titular.nrdctitg tt-titular.nrdocttl tt-titular.dtdemiss
                WITH FRAME f_dados.          

            IF  tel_tppesttl < 4   THEN
                DISPLAY tt-titular.dtnasttl 
                        tt-titular.cdempres WITH FRAME f_dados. 
        END.
END.

ON RETURN OF bgnetcvla-b 
   DO:
       IF   AVAILABLE tt-titular  THEN
            par_nrdconta = tt-titular.nrdconta.
          
       CLOSE QUERY bgnetcvla-q.               
       APPLY "END-ERROR" TO bgnetcvla-b.
   END.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   ASSIGN tel_nrdctitg = "00000000".

   DISPLAY tel_opnmprim tel_opctaitg tel_opcpfcgc WITH FRAME f_associado.
   
   CHOOSE FIELD tel_opnmprim tel_opctaitg tel_opcpfcgc WITH FRAME f_associado.

   IF   FRAME-VALUE = tel_opnmprim   THEN
        DO:
            ASSIGN aux_cdpesqui = 1.

            tel_tppesttl:HELP = "0-Titulares, 1-Conjuge, 2-Pai, 3-Mae, 4-Pessoa Juridica".

            UPDATE tel_nmprimtl tel_tppesttl tel_cdagenci tel_tpdorgan WITH FRAME f_associado.

            IF   TRIM(tel_nmprimtl) = ""   THEN
                 NEXT.
        END.
   ELSE
   IF   FRAME-VALUE = tel_opctaitg   THEN
        DO:
            ASSIGN aux_cdpesqui = 2.

            UPDATE tel_tpdorgan tel_nrdctitg WITH FRAME f_associado.

            DO WHILE LENGTH(tel_nrdctitg) < 8:
               tel_nrdctitg = "0" + tel_nrdctitg.
            END.

            DISPLAY tel_nrdctitg WITH FRAME f_associado.
             
        END.
   ELSE
   IF   FRAME-VALUE = tel_opcpfcgc   THEN
        DO:
            ASSIGN aux_cdpesqui = 3.

            tel_tppesttl:HELP = "1-Pessoa Fisica, 2-Pessoa Juridica".
            
            UPDATE  tel_tppesttl tel_cdagenci  tel_tpdorgan  tel_nrcpfcgc WITH FRAME f_associado.


        END.
   

   /* Verifica se o banco generico ja esta conectado */
   ASSIGN aux_flggener = f_verconexaogener().

   IF  aux_flggener OR f_conectagener()  THEN
       DO: 
          IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
              RUN sistema/generico/procedures/b1wgen0059.p
                  PERSISTENT SET h-b1wgen0059.

          RUN zoom-associados IN h-b1wgen0059
              ( INPUT par_cdcooper,   /*  cdcooper */
                INPUT tel_cdagenci,   /*  cdagpesq */
                INPUT aux_cdpesqui,   /*  cdpesqui */
                INPUT tel_nmprimtl,   /*  nmdbusca */
                INPUT tel_tppesttl,   /*  tpdapesq */
                INPUT tel_nrdctitg,   /*  nrdctitg */
                INPUT tel_tpdorgan,   /*  tpdorgan */
                INPUT tel_nrcpfcgc,   /*  nrcpfcgc */
                INPUT YES,            /*  flgpagin */
                INPUT 9999999,        /*  nrregist */
                INPUT 1,              /*  nriniseq */
               OUTPUT aux_qtregist,
               OUTPUT TABLE tt-titular ).

          DELETE OBJECT h-b1wgen0059.

          IF  NOT aux_flggener  THEN
              RUN p_desconectagener.
       END. 
   
   OPEN QUERY bgnetcvla-q FOR EACH tt-titular NO-LOCK.
       
  
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_associado NO-PAUSE.  
       
IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     DO:
         par_nrdconta = 0.
         RETURN.
     END.

IF   CAN-FIND(FIRST tt-titular)   THEN
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        SET bgnetcvla-b WITH FRAME f_alterar.
        LEAVE.
      
     END.  /*  Fim do DO WHILE TRUE  */
ELSE
     DO:
         glb_cdcritic = 407.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         PAUSE(2) NO-MESSAGE.
     END.

glb_cdcritic = 0.

HIDE FRAME f_alterar NO-PAUSE.

/* .......................................................................... */



