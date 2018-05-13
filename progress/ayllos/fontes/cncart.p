/* ............................................................................

   Programa: fontes/cncart.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei (Precise IT)
   Data    : Novembro/2008                     Ultima atualizacao: 28/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Pesquisa de cartao de credito nas cooperativas.

   Alteracoes: 28/05/2009 - Substituidos comandos WORKFILE por TEMP-TABLE e 
                            FOR EACH/DELETE por EMPTY TEMP-TABLE (Diego).
                            
               19/08/2010 - Mudança da chamada do fontes/inicia.p e do 
                            tratamento PROMPT-FOR  da variável tel_tpcrdpes 
                            (Vitor).
                            
               28/09/2010 - Incluida a opcao de busca pelo nome completo do
                            titular da conta (Vitor). 
                            
                          - Incluida a visualizacao do nome impresso no cartao
                            quando escolhida a opcao de busca por titular da 
                            conta e vice-versa (Vitor).
                            
               04/10/2010 - Incluida a visualizacao do PAC do cooperado
                            (Vitor).  
                            
               02/03/2011 - Inclusão da opcão "enc" (crawcrd.insitcrd = 6) e
                            LOCK para a tabela crawcrd
                            (Isara - RKAM)       
                            
               13/09/2011 - Alterado para utilizar a procedure busca-cartao 
                            da BO 28 (Henrique).
                            
               14/11/2011 - Incluido parametros a serem passados na chamada da
                            procedure busca-cartao (Adriano).       
                            
              08/02/2013 - Ajustado tamanho do campo situacao cartao atendendo chamado
                            43350 (Daniel).      
   
              29/04/2013 - Incluido opcao para fazer pesquisa do cartão através 
                           da conta ITG (Daniele).
                           
              24/05/2013 -  Adicionado conta ITG em todas as opcoes(Daniele).               
              
              28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
.............................................................................*/ 
{ includes/var_online.i  }

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/var_internet.i }

DEFINE  VARIABLE    aux_nobrowse    AS  LOGICAL   INIT FALSE                    NO-UNDO.

DEFINE  VARIABLE    tel_nmtitcrd    AS  CHARACTER FORMAT "x(40)"                NO-UNDO.       

DEFINE  VARIABLE    tel_nrcartao    AS  DECIMAL   FORMAT "9999,9999,9999,9999"  NO-UNDO.
                                                                   
DEFINE  VARIABLE    tel_nmprimtl    AS CHARACTER  FORMAT "x(40)"                NO-UNDO.

DEFINE VARIABLE     tel_nrdctitg    AS DECIMAL  FORMAT "9,999,999"              NO-UNDO. 

DEFINE  VARIABLE    aux_qtregist    AS INTEGER                                  NO-UNDO.

DEFINE VARIABLE     aux_nrdctitg   AS CHARACTER                                 NO-UNDO.
  
DEFINE  VARIABLE    tel_tpcrdpes    AS  INTEGER INITIAL 1
                    VIEW-AS RADIO-SET HORIZONTAL
                    RADIO-BUTTONS "Numero do Cartao", 1 ,"Nome do Titular", 2 ,"Nome do Plastico", 3,"Conta ITG" , 4 .

DEF VAR h-b1wgen0028 AS HANDLE                                                  NO-UNDO.

DEFINE QUERY q-cartao FOR tt-cartao.

DEFINE BROWSE b-cartao QUERY q-cartao NO-LOCK               
              DISPLAY tt-cartao.nrdconta LABEL "NRD.CONTA"       
                      TRIM (tt-cartao.nmtitcrd) LABEL "TITULAR DO CARTAO" 
                                        FORMAT "x(21)"
                      tt-cartao.nmrescop LABEL "COOPERATIVA"
                      tt-cartao.cdadmcrd LABEL "ADM"    
                      tt-cartao.insitcrd LABEL "SITUAC" FORMAT "x(6)"
                      tt-cartao.nrcrcard LABEL "NUMERO CARTAO"
                      WITH 10 DOWN NO-LABEL TITLE "CARTOES ENCONTRADOS"
                      WIDTH 80.

FORM SKIP(2)
     "Procurar por:" AT 1  SKIP (2) tel_tpcrdpes NO-LABEL AUTO-RETURN SKIP(2)   
     WITH TITLE "PROCURA DE CARTAO DE CREDITO POR COOPERATIVA"
          SIDE-LABEL ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY FRAME fr_opcao.  

FORM tel_nrcartao AT 8
     WITH SIDE-LABEL ROW 10 COLUMN 2 SIZE 78 BY 5 OVERLAY NO-BOX 
                     FRAME fr_nrcartao.   /*numero do cartao*/

FORM tel_nmprimtl AT 2
     WITH SIDE-LABEL ROW 10 COLUMN 2 SIZE 78 BY 5 OVERLAY NO-BOX 
                     FRAME fr_nmprimtl.   /*nome do titular*/

FORM tel_nmtitcrd AT 2
     WITH SIDE-LABEL ROW 10 COLUMN 2 SIZE 78 BY 5 OVERLAY NO-BOX 
                     FRAME fr_nmtitcrd.   /*nome do plastico*/

FORM tel_nrdctitg AT 4
     WITH SIDE-LABEL ROW 10 COLUMN 2 SIZE 78 BY 5 OVERLAY NO-BOX
                     FRAME fr_nrdctitg.   /****conta ITG*****/  
                     
FORM b-cartao WITH WIDTH 80 ROW 6 CENTERED NO-BOX OVERLAY FRAME fr_consulta.

FORM "Titular da conta:" AT 1
     tt-cartao.nmextttl  FORMAT "x(20)" AT 19 
     "PA:"               AT 41
     tt-cartao.cdagenci  AT 44
     "Conta ITG:"        AT 50 
     tt-cartao.nrdctitg  AT 62
     WITH WIDTH 78 ROW 20 COLUMN 2 NO-BOX NO-LABEL OVERLAY FRAME fr_cdagenci.

FORM "Titular da conta:" AT 1
     tt-cartao.nmextttl  FORMAT "x(20)" AT 19
     "PA:"               AT 41
     tt-cartao.cdagenci  AT 44
     "Conta ITG:"        AT 49    
     tt-cartao.nrdctitg  AT 61
     WITH WIDTH 78 ROW 20 COLUMN 2 NO-BOX NO-LABEL OVERLAY FRAME fr_nmtitular.

FORM "Titular da conta:" AT 1
     tt-cartao.nmextttl  FORMAT "x(20)" AT 19
     "Conta ITG:"        AT 40         
     tt-cartao.nrdctitg  AT 51
     "PA:"               AT 65
     tt-cartao.cdagenci  AT 68
     WITH WIDTH 78 ROW 20 COLUMN 2 NO-BOX NO-LABEL OVERLAY FRAME  fr_nmplastico.

FORM "Titular da conta:"  AT 1           
     tt-cartao.nmextttl   FORMAT "x(20)" AT 19
     "Conta ITG:"         AT 40   
     tt-cartao.nrdctitg   AT 51
     "PA:"               AT 65 
     tt-cartao.cdagenci   AT 68
     WITH   WIDTH 78 ROW 20 COLUMN 2 NO-BOX NO-LABEL OVERLAY FRAME fr_nrdaconitg.  

ON ANY-KEY OF tel_tpcrdpes DO:

   IF KEYFUNCTION(LASTKEY) = "CURSOR-LEFT" THEN
      DO:
          tel_tpcrdpes = tel_tpcrdpes - 1.

          IF tel_tpcrdpes < 1 THEN
             tel_tpcrdpes = 4 .

          DISP tel_tpcrdpes WITH FRAME fr_opcao.
      END.
   ELSE
   IF KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT" THEN
      DO:
          tel_tpcrdpes = tel_tpcrdpes + 1.

          IF tel_tpcrdpes > 4 THEN
             tel_tpcrdpes = 1.

          DISP tel_tpcrdpes WITH FRAME fr_opcao.
      END.

END.

ON RETURN OF tel_nrcartao, tel_nmprimtl, tel_nmtitcrd , tel_nrdctitg DO:

    MESSAGE "Buscando cartoes...".
    PAUSE 0.
    
    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h-b1wgen0028.

    IF  INT(tel_tpcrdpes:SCREEN-VALUE IN FRAME fr_opcao) = 1  THEN
        RUN busca-cartao IN h-b1wgen0028 (INPUT glb_cdcooper,
                                          INPUT 1,  
                                          INPUT tel_nrcartao:SCREEN-VALUE,
                                          INPUT 9999999,
                                          INPUT 1,
                                          INPUT TRUE,
                                          INPUT glb_dsdepart,
                                          OUTPUT aux_qtregist,
                                          OUTPUT TABLE tt-cartao,
                                          OUTPUT TABLE tt-erro).
    ELSE
    IF  INT(tel_tpcrdpes:SCREEN-VALUE IN FRAME fr_opcao) = 2  THEN
        RUN busca-cartao IN h-b1wgen0028 (INPUT glb_cdcooper,
                                          INPUT 2,
                                          INPUT tel_nmprimtl:SCREEN-VALUE,
                                          INPUT 9999999,
                                          INPUT 1,
                                          INPUT TRUE,
                                          INPUT glb_dsdepart,
                                          OUTPUT aux_qtregist,
                                          OUTPUT TABLE tt-cartao,
                                          OUTPUT TABLE tt-erro).
    ELSE
        
    IF  INT(tel_tpcrdpes:SCREEN-VALUE IN FRAME fr_opcao) = 3  THEN
        RUN busca-cartao IN h-b1wgen0028 (INPUT glb_cdcooper,
                                          INPUT 3,
                                          INPUT tel_nmtitcrd:SCREEN-VALUE,
                                          INPUT 9999999,
                                          INPUT 1,
                                          INPUT TRUE,
                                          INPUT glb_dsdepart,
                                          OUTPUT aux_qtregist,
                                          OUTPUT TABLE tt-cartao,
                                          OUTPUT TABLE tt-erro).
    
  ELSE
    IF  INT(tel_tpcrdpes:SCREEN-VALUE IN FRAME fr_opcao) = 4  THEN
        RUN busca-cartao IN h-b1wgen0028 (INPUT glb_cdcooper,
                                          INPUT 4,
                                          INPUT (REPLACE(STRING(tel_nrdctitg:SCREEN-VALUE), ".", "" )), 
                                          INPUT 9999999,
                                          INPUT 1,
                                          INPUT TRUE,
                                          INPUT glb_dsdepart,
                                          OUTPUT aux_qtregist,
                                          OUTPUT TABLE tt-cartao,
                                          OUTPUT TABLE tt-erro). 
   

    DELETE PROCEDURE h-b1wgen0028.
    
    APPLY "F1".
END.

ON RETURN OF tel_tpcrdpes DO:
   APPLY "F1".
END.

ON END-ERROR OF b-cartao DO:
   aux_nobrowse = TRUE.
   APPLY "F1".
END.

ON ENTRY OF b-cartao DO: 
    APPLY "VALUE-CHANGED" TO b-cartao.
END.

ON VALUE-CHANGED OF b-cartao IN FRAME fr_consulta DO: 
    
    IF  tel_tpcrdpes = 1 THEN
        DISP tt-cartao.nmextttl
             tt-cartao.cdagenci
             /*tt-cartao.nmtitcrd*/
             tt-cartao.nrdctitg /* alterado*/ 
             WITH FRAME fr_cdagenci.
    ELSE

    IF  tel_tpcrdpes = 2 THEN   /*3*/
        DISP tt-cartao.nmextttl
             tt-cartao.cdagenci
            /*tt-cartao.nmtitcrd*/ 
             tt-cartao.nrdctitg /*alterado*/
             WITH FRAME fr_nmtitular.


    ELSE
    
      
    IF  tel_tpcrdpes = 3 THEN  /*2*/
        DISP tt-cartao.nmextttl
             tt-cartao.cdagenci
             tt-cartao.nrdctitg /*alterado*/
             WITH FRAME fr_nmplastico. 


    ELSE
    
    IF  tel_tpcrdpes = 4 THEN
        DISP tt-cartao.nrdctitg
             tt-cartao.cdagenci
             tt-cartao.nmextttl  /*alterado*/
             WITH FRAME fr_nrdaconitg. 
END.

VIEW FRAME fr_opcao.
PAUSE(0).

glb_cddopcao = "C".

RUN fontes/inicia.p.

DO WHILE TRUE:     

   DO  WHILE TRUE ON ENDKEY UNDO, LEAVE :
        PROMPT-FOR tel_tpcrdpes WITH FRAME fr_opcao.
        LEAVE.
   END.

   /*   F4 OU FIM    */
   IF   (KEYFUNCTION(LASTKEY) = "END-ERROR") THEN     
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CNCART"   THEN
                 DO:      
                     HIDE FRAME fr_opcao    NO-PAUSE.
                     HIDE FRAME fr_nrcartao NO-PAUSE.
                     HIDE FRAME fr_nmextttl NO-PAUSE.
                     HIDE FRAME fr_nmtitcrd NO-PAUSE.
                     HIDE FRAME fr_nrdctitg NO-PAUSE.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
   ELSE
        { includes/acesso.i }

   aux_nobrowse = FALSE.         

   IF   INT(tel_tpcrdpes:SCREEN-VALUE) = 1   THEN
        PROMPT-FOR tel_nrcartao LABEL "Digite o numero do cartao para procura"
                   WITH FRAME fr_nrcartao.

   IF   INT(tel_tpcrdpes:SCREEN-VALUE) = 2   THEN
        PROMPT-FOR tel_nmprimtl LABEL "Digite o nome do titular da conta"
                   WITH FRAME fr_nmprimtl.
           
   IF   INT(tel_tpcrdpes:SCREEN-VALUE) = 3   THEN
        PROMPT-FOR tel_nmtitcrd LABEL "Digite o nome impresso no cartao"
                   WITH FRAME fr_nmtitcrd.
   IF  INT(tel_tpcrdpes:SCREEN-VALUE) =  4   THEN
        PROMPT-FOR tel_nrdctitg LABEL "Digite o numero da conta ITG sem digito verificador"
        WITH FRAME fr_nrdctitg. 

   FIND FIRST tt-cartao NO-LOCK NO-ERROR.

   IF NOT AVAIL tt-cartao THEN
      DO:
        
       
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
       
         IF  AVAIL tt-erro THEN
             MESSAGE tt-erro.dscritic.
         ELSE
             MESSAGE "Nenhum cartao foi encontrado.".
         
         NEXT.
      END.

   OPEN QUERY q-cartao FOR EACH tt-cartao NO-LOCK.
   
   SET b-cartao WITH FRAME fr_consulta.

   CLOSE QUERY q-cartao.
END.

/* .......................................................................... */
