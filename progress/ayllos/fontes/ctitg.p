/* .............................................................................

   Programa: Fontes/ctitg.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Setembro/2004.                  Ultima atualizacao: 12/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CTITG.

   Alteracoes: 28/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               18/03/2005 - Feitas melhorias em relacao ao campo da conta de
                            integracao e ao FOR EACH (Evandro).
                            
               29/06/2005 - Modificado o modo de exibicao das contas (Evandro).
               
               01/08/2005 - Alterado o UPDATE do campo da conta (Evandro).

               04/08/2005 - Alterado para fazer ordenacao por nome (Diego).
                            
               25/08/2005 - Nao verificar digito(problema digito x)(Mirtes).
              
               25/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               25/10/2007 - Mostrar secao a partir da ttl.nmdsecao(Guilherme).
               
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               24/04/2009 - Acertar logica de FOR EACH que utiliza OR (David).
               
               03/02/2010 - Inserido FORMAT "x(40)" para crapass.nmprimtl
                            (Diego).
                            
               13/08/2013 - Nova forma de chamar as agencias, alterado para
                         "Posto de Atendimento" (PA). (André Santos - SUPERO)             
               
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". 
                          - Alterado FORMAT da variavel tel_cdagenci para "zz9"
                            (Reinert)
                            
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
............................................................................. */
{ includes/var_online.i }

DEF        VAR tel_nrcpfcgc AS CHAR    FORMAT "x(18)"                NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_dsagenci AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR tel_nrdctitg AS CHAR    FORMAT "x.xxx.xxx-x"          NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_flgctitg AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cdempres AS INT                                   NO-UNDO.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     tel_nrdctitg AT 04 LABEL "Conta de Integracao"
                        HELP "Informe a conta de integracao / 0 para todas"
                        
     tel_cdagenci AT 60 LABEL "PA" 
                        HELP "Entre com o PA a ser pesquisado ou 0 para todos"
                        VALIDATE(CAN-FIND(crapage WHERE crapage.cdcooper =
                                                        glb_cdcooper       AND
                                                        crapage.cdagenci = 
                                                  INPUT tel_cdagenci) OR
                                                  INPUT tel_cdagenci = 0,
                                 "962 - PA nao cadastrado.")
     SKIP(1)
     "Conta/Itg Titular/Nascimento/Demissao/CPF"    AT  4
     "PA/Secao/Empresa"                            AT 56 
     WITH ROW 5 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_ctitg.

FORM SKIP(1)
     crapass.nrdconta AT  3
     crapass.nmprimtl      FORMAT "x(40)"
     tel_dsagenci      
     SKIP
     crapass.nrdctitg AT 2
     crapass.dtnasctl AT 14 
     crapass.dtdemiss       FORMAT "99/99/9999"
     tel_nrcpfcgc     
     aux_cdempres           FORMAT "zzzz9"
     WITH ROW 09 COLUMN 2 OVERLAY 4 DOWN NO-LABEL NO-BOX FRAME f_dados.

VIEW FRAME f_moldura.
PAUSE(0).

glb_cdcritic = 0.

DO WHILE TRUE:
    
   RUN fontes/inicia.p.

   ASSIGN tel_nrdctitg = "00000000"
          tel_cdagenci = 0.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      ASSIGN aux_flgctitg = YES.

      HIDE tel_cdagenci IN FRAME f_ctitg.
      
      UPDATE tel_nrdctitg WITH FRAME f_ctitg
   
      
      EDITING:
      
          DO WHILE TRUE:
            
             READKEY PAUSE 1.
      
             /* retringe a somente estes caracteres */
             IF   FRAME-FIELD = "tel_nrdctitg" THEN
                  IF   NOT CAN-DO("0,1,2,3,4,5,6,7,8,9,x,RETURN,TAB," + 
                                  "BACKSPACE,DELETE-CHARACTER,BACK-TAB," +
                                  "CURSOR-LEFT,END-ERROR,HELP",
                                  KEYFUNCTION(LASTKEY))  THEN                   
                       LEAVE.
                
             APPLY LASTKEY.
            
             LEAVE. 

          END. /* FIM DO WHILE */
      END. /* FIM DO EDITING */    


      /* preenche com ZEROS o que nao foi digitado */
      DO WHILE SUBSTRING(tel_nrdctitg,8,1) = "" :

         DO aux_contador = 8 TO 2 BY -1:
            ASSIGN SUBSTRING(tel_nrdctitg,aux_contador,1) =
                            SUBSTRING(tel_nrdctitg,aux_contador - 1,1).
         END.
   
         SUBSTRING(tel_nrdctitg,1,1) = "0".
   
      END.

      DISPLAY tel_nrdctitg WITH FRAME f_ctitg.
      
      IF   tel_nrdctitg = "00000000"    THEN
           UPDATE tel_cdagenci WITH FRAME f_ctitg.           
           
      LEAVE.
      
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "CTITG"   THEN
                 DO:
                     HIDE FRAME f_ctitg.
                     HIDE FRAME f_dados.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   /* zerar variaveis de controle */ 
   ASSIGN aux_regexist = FALSE
          aux_flgretor = FALSE
          aux_contador = 0.
          
   CLEAR FRAME f_dados ALL NO-PAUSE.
   
   FOR EACH crapass WHERE (crapass.cdcooper  = glb_cdcooper AND
                           SUBSTR(crapass.nrdctitg,1,7) =   
                           SUBSTR(tel_nrdctitg,1,7)) OR   
                          (crapass.cdcooper  = glb_cdcooper AND
                           tel_nrdctitg      = "00000000"   AND 
                           crapass.nrdctitg <> ""           AND
                          (crapass.cdagenci  = tel_cdagenci OR   
                           tel_cdagenci      = 0))                           
                           NO-LOCK BY crapass.cdagenci BY crapass.nmprimtl:

       IF   crapass.inpessoa = 1   THEN 
            DO:
                FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                   crapttl.nrdconta = crapass.nrdconta   AND
                                   crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
       
                IF   AVAIL crapttl  THEN
                     ASSIGN aux_cdempres = crapttl.cdempres.
            END.
       ELSE
            DO:
                FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                   crapjur.nrdconta = crapass.nrdconta
                                   NO-LOCK NO-ERROR.
        
                IF   AVAIL crapjur  THEN
                     ASSIGN aux_cdempres = crapjur.cdempres.
            END.

       RUN lista.

       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  
            LEAVE.
   END.            


   IF   NOT aux_regexist   THEN
        DO:
            glb_cdcritic = 838.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
         END.

END.


PROCEDURE lista.

    ASSIGN aux_regexist = TRUE
           aux_contador = aux_contador + 1.

    IF   aux_contador = 1   THEN
         IF   aux_flgretor   THEN
              DO:
                  PAUSE MESSAGE
                  "Tecle <Entra> para continuar ou <Fim> para encerrar".
                      CLEAR FRAME f_dados ALL NO-PAUSE.
              END.
         ELSE
              aux_flgretor = TRUE.

    FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                       crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapage   THEN
         tel_dsagenci = "nao cadastrado - " +
                         STRING(crapass.cdagenci,"zz9").
    ELSE
         tel_dsagenci = STRING(crapage.cdagenci,"zz9") + " - " +
                               crapage.nmresage.
                               
    /* tratamento para o CPF */    
    IF   LENGTH(STRING(crapass.nrcpfcgc)) < 12 THEN
         ASSIGN tel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                tel_nrcpfcgc = STRING(tel_nrcpfcgc,"xxx.xxx.xxx-xx").
    ELSE
         ASSIGN tel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                tel_nrcpfcgc = STRING(tel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
                               
    
    FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND
                       crapttl.nrdconta = crapass.nrdconta AND
                       crapttl.idseqttl = 1  NO-LOCK NO-ERROR.
                       
    IF   AVAILABLE crapttl   THEN
         DISPLAY crapass.nrdconta   crapass.nmprimtl   tel_dsagenci
                 crapass.dtnasctl   crapass.nrdctitg
                 crapass.dtdemiss WHEN crapass.dtdemiss <> ?
                 tel_nrcpfcgc   aux_cdempres
                 WITH FRAME f_dados.
    ELSE
         DISPLAY crapass.nrdconta   crapass.nmprimtl   tel_dsagenci
                 crapass.dtnasctl   crapass.nrdctitg
                 crapass.dtdemiss WHEN crapass.dtdemiss <> ?
                 tel_nrcpfcgc  aux_cdempres
                 WITH FRAME f_dados.
    
    IF   aux_contador = 4   THEN
         aux_contador = 0.
    ELSE
         DOWN WITH FRAME f_dados.
         
END PROCEDURE.      

/*...........................................................................*/


