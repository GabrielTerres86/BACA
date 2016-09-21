/* .............................................................................

   Programa: fontes/cncoop.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei Bunde (Precise IT)
   Data    : Dezembro/2008                        Ultima atualizacao: 26/11/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Pesquisa do CPF/CNPJ ou Nome do associado nas
               cooperativas

   Alteracoes: 15/12/2010 - Alterado format de "x(34)" para "x(50)"
                            Kbase-Willian.
                            
               15/12/2010 - Mudança da chamada do fontes/inicia.p e do 
                            tratamento PROMPT-FOR  da variável tel_tppesqui 
                            (Vitor). 
                            
               26/11/2013 - Alterado coluna da aux_wfassoci.nrcpfcgc de
                            CPF/CGC para CPF/CNPJ. (Reinert)
               
               08/10/2014 - alteração para exibir todas as contas que um cooperado 
                            tem na cooperativa(Felipe)

............................................................................*/ 

{ includes/var_online.i }
                                
DEFINE  VARIABLE    aux_nobrowse    AS  LOGICAL   INIT FALSE        NO-UNDO.
                                  
DEFINE  VARIABLE    aux_dsdircop    AS  CHARACTER                   NO-UNDO.

DEFINE  VARIABLE    tel_nmprimtl    AS  CHARACTER FORMAT "x(50)"    NO-UNDO. 
DEFINE  VARIABLE    tel_nrcpfcgc    AS  DECIMAL   FORMAT "zzzzzzzzzzzzzz"
                                                                    NO-UNDO.

DEFINE  VARIABLE    tel_tppesqui    AS  INTEGER INITIAL 1
                    VIEW-AS RADIO-SET HORIZONTAL
                    RADIO-BUTTONS "Numero do CPF/CNPJ", 1 ,"Nome do Titular", 2.

DEFINE NEW SHARED   TEMP-TABLE  aux_wfassoci                        NO-UNDO
                                FIELD nrdconta LIKE crapass.nrdconta
                                FIELD nmprimtl LIKE crapass.nmprimtl
                                FIELD nrcpfcgc AS CHARACTER FORMAT "x(18)"
                                FIELD idseqttl LIKE crapttl.idseqttl
                                FIELD nmrescop LIKE crapcop.nmrescop.

DEFINE QUERY aux_qrassoci FOR aux_wfassoci.

DEFINE BROWSE aux_bwassoci QUERY aux_qrassoci NO-LOCK               
              DISPLAY aux_wfassoci.nrdconta LABEL "CONTA"
                      aux_wfassoci.nmprimtl LABEL "NOME"     FORMAT "x(34)"     
                      aux_wfassoci.nrcpfcgc LABEL "CPF/CNPJ"
                      aux_wfassoci.idseqttl LABEL "Tit."
                      aux_wfassoci.nmrescop LABEL "COOPERATIVA"
                      WITH 12 DOWN NO-LABEL TITLE "ASSOCIADO(S) ENCONTRADO(S)"
                      WIDTH 80.

FORM SKIP(2)
     "Procurar por:" AT 10 tel_tppesqui NO-LABEL AUTO-RETURN SKIP(2)   
     WITH TITLE glb_tldatela SIDE-LABEL ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY
          FRAME fr_opcao.

FORM tel_nrcpfcgc AT 8
     WITH SIDE-LABEL ROW 10 COLUMN 2 SIZE 78 BY 5 OVERLAY NO-BOX 
                     FRAME fr_nrcpfcgc.   

FORM tel_nmprimtl AT 2
     WITH SIDE-LABEL ROW 10 COLUMN 2 SIZE 78 BY 5 OVERLAY NO-BOX 
                     FRAME fr_nmprimtl.   
                     
FORM aux_bwassoci WITH WIDTH 80 ROW 6 NO-BOX OVERLAY FRAME fr_consulta.        
ON ANY-KEY OF tel_tppesqui DO:

   IF KEYFUNCTION(LASTKEY) = "CURSOR-LEFT" THEN
      DO:
          tel_tppesqui = 1.
          DISP tel_tppesqui WITH FRAME fr_opcao.
      END.
   ELSE
   IF KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT" THEN
      DO:
          tel_tppesqui = 2.
          DISP tel_tppesqui WITH FRAME fr_opcao.
      END.

END.

ON RETURN OF tel_nrcpfcgc, tel_nmprimtl DO:

   FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:
 
       ASSIGN aux_dsdircop = crapcop.dsdircop.
    
       HIDE MESSAGE NO-PAUSE.  

            DO:
                MESSAGE COLOR NORMAL "Procurando associado na " 
                                     crapcop.nmrescop "...".

                IF   INT(tel_tppesqui:SCREEN-VALUE IN FRAME fr_opcao) = 1  THEN
                     RUN busca_informacao (INPUT crapcop.cdcooper,
                                           INPUT 1,  
                                           INPUT tel_nrcpfcgc:SCREEN-VALUE).
                ELSE
                     RUN busca_informacao (INPUT crapcop.cdcooper,
                                           INPUT 2,
                                           INPUT tel_nmprimtl:SCREEN-VALUE).
            END.
                                 
       HIDE MESSAGE NO-PAUSE.  
   END.

   APPLY "F1".
END.

ON RETURN OF tel_tppesqui DO:
   APPLY "F1".
END.

ON END-ERROR OF aux_bwassoci DO:
   aux_nobrowse = TRUE.
   APPLY "F1".
END.

VIEW FRAME fr_opcao.
PAUSE(0).

glb_cddopcao = "C".

RUN fontes/inicia.p.

DO WHILE TRUE:
   
   /*FOR EACH aux_wfassoci:
       DELETE aux_wfassoci.
   END.*/
   
   EMPTY TEMP-TABLE aux_wfassoci.

      DO  WHILE TRUE ON ENDKEY UNDO, LEAVE :
          PROMPT-FOR tel_tppesqui WITH FRAME fr_opcao.
          LEAVE.
      END.
   
   /*   F4 OU FIM    */
   IF   (KEYFUNCTION(LASTKEY) = "END-ERROR") AND (NOT aux_nobrowse) THEN     
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CNCOOP"   THEN
                 DO:      
                     HIDE FRAME fr_opcao NO-PAUSE.
                     HIDE FRAME fr_nrcpfcgc NO-PAUSE.
                     HIDE FRAME fr_nmprimtl NO-PAUSE.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
   ELSE
        { includes/acesso.i }
 
   aux_nobrowse = FALSE.

   IF   INT(tel_tppesqui:SCREEN-VALUE) = 1   THEN
        PROMPT-FOR tel_nrcpfcgc LABEL "Digite o numero do CPF/CNPJ para procura"
                   WITH FRAME fr_nrcpfcgc.
   ELSE        
   IF   INT(tel_tppesqui:SCREEN-VALUE) = 2   THEN
        PROMPT-FOR tel_nmprimtl LABEL "Digite o nome do associado"
                   WITH FRAME fr_nmprimtl.

   OPEN QUERY aux_qrassoci FOR EACH aux_wfassoci BY aux_wfassoci.nmprimtl.
   
   SET aux_bwassoci WITH FRAME fr_consulta.    

   CLOSE QUERY aux_qrassoci.
   
END.

/* ......................................................................... */

PROCEDURE busca_informacao:

DEFINE INPUT PARAMETER par_cdcooper AS INTEGER                   NO-UNDO.
DEFINE INPUT PARAMETER par_tipopesq AS INTEGER                   NO-UNDO.
DEFINE INPUT PARAMETER par_dsassoci AS CHARACTER                 NO-UNDO.

DEFINE VARIABLE aux_nrcpfcgc        AS DECIMAL INIT 0            NO-UNDO.
FIND FIRST crapcop
     WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

IF   par_tipopesq = 1   THEN
     aux_nrcpfcgc = DECIMAL(par_dsassoci).
ELSE
     par_dsassoci = TRIM(par_dsassoci).


  /** Verificar se é um CPF ou CNPJ */
    DEFINE VARIABLE aux_tamanho AS INTEGER NO-UNDO.
    ASSIGN aux_tamanho = LENGTH(string(aux_nrcpfcgc)).


IF   par_tipopesq = 1 THEN
  DO:

    IF aux_tamanho <= 12 THEN
            /** SE FOR CPF*/
            DO:
                    FOR EACH crapttl NO-LOCK  WHERE crapttl.nrcpfcgc = aux_nrcpfcgc AND crapttl.cdcooper = par_cdcooper BY crapttl.nrdconta  BY  crapttl.idseqttl:
                        
                            CREATE aux_wfassoci.
                                   ASSIGN aux_wfassoci.nmrescop = crapcop.nmrescop
                                   aux_wfassoci.nrdconta = crapttl.nrdconta
                                   aux_wfassoci.idseqttl = crapttl.idseqttl
                                   aux_wfassoci.nmprimtl = crapttl.nmextttl.
                
                        /* Tratamento de CPF/CGC  */
                              ASSIGN  aux_wfassoci.nrcpfcgc =
                                           STRING(crapttl.nrcpfcgc,"99999999999")
                                      aux_wfassoci.nrcpfcgc = 
                                           STRING(aux_wfassoci.nrcpfcgc,"    xxx.xxx.xxx-xx").
                        
                      
                     END.
            END.

        ELSE
            /** SE FOR UM CNPJ */
            DO:
            
                    
                    FOR EACH crapass NO-LOCK WHERE  crapass.nrcpfcgc = aux_nrcpfcgc AND  crapass.cdcooper = par_cdcooper:
                        
                            CREATE aux_wfassoci.
                                   ASSIGN aux_wfassoci.nmrescop = crapcop.nmrescop
                                   aux_wfassoci.nrdconta = crapass.nrdconta
                                   aux_wfassoci.idseqttl = 1
                                   aux_wfassoci.nmprimtl = crapass.nmprimtl NO-ERROR. 
                
                        /* Tratamento de CPF/CGC  */
                        
                              ASSIGN  aux_wfassoci.nrcpfcgc =
                                           STRING(crapass.nrcpfcgc ,"99999999999999")
                                      aux_wfassoci.nrcpfcgc =
                                           STRING(aux_wfassoci.nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
                      
                    END.
            END.
   END.
ELSE

       /** LOCALIZAR POR NOME */
       DO:
                 
       /**PEGAR NOME PESSOA FISICA*/
                FOR EACH crapttl WHERE 
                              crapttl.cdcooper = par_cdcooper AND
                              crapttl.nmextttl MATCHES("*" + par_dsassoci + "*") NO-LOCK:  
                               
                                      CREATE aux_wfassoci.
                                                ASSIGN
                                                aux_wfassoci.nmrescop = crapcop.nmrescop
                                                aux_wfassoci.nrdconta = crapttl.nrdconta
                                                aux_wfassoci.idseqttl = crapttl.idseqttl
                                                aux_wfassoci.nmprimtl = crapttl.nmextttl NO-ERROR .
                                             /* Tratamento de CPF/CGC */
                                             
                                                  ASSIGN  aux_wfassoci.nrcpfcgc = STRING(crapttl.nrcpfcgc,"99999999999")
                                                          aux_wfassoci.nrcpfcgc = STRING(aux_wfassoci.nrcpfcgc,"    xxx.xxx.xxx-xx").
                                             
                END.
       
       
       
                    
                  /*PEGAR PESSOA JURIDICA */
                  FOR EACH crapass WHERE 
                              crapass.cdcooper = par_cdcooper AND
                              crapass.nmprimtl MATCHES("*" + par_dsassoci + "*") AND crapass.INPESSOA >= 2 NO-LOCK:  
                               
                                      CREATE aux_wfassoci.
                                                ASSIGN
                                                aux_wfassoci.nmrescop = crapcop.nmrescop
                                                aux_wfassoci.nrdconta = crapass.nrdconta
                                                aux_wfassoci.idseqttl = 1
                                                aux_wfassoci.nmprimtl = crapass.nmprimtl NO-ERROR.
                                                 
                                                  ASSIGN  aux_wfassoci.nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                                                         aux_wfassoci.nrcpfcgc = STRING(aux_wfassoci.nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
                END.
      END.
       
       
       
END PROCEDURE.
