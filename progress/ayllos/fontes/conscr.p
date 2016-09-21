/* ..........................................................................

   Programa: Fontes/conscr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Julho/2010                         Ultima atualizacao: 29/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CONSCR (CONSULTA CENTRAL DE RISCO).
               Relatorio: crrl569.lst
   
   Alteracoes: 24/08/2010 - Verifica data base toda vez que for feita selecao 
                            no browser;
                          - Alterado os indices de consulta da tabela crapris 
                            (Elton).
                            
               14/09/2010 - Incluido opcao "F" - fluxo dos vencimentos (Elton).
                
               24/09/2010 - Alterado formato das variaveis tel_vlopcoop,
                            tel_vlopbase (Adriano).
                            
               18/05/2011 - Incluidas as opcoes "M" e "H"
                          - Remodelada a opcao "F"
                            (Isara - RKAM).
                            
               09/08/2011 - Alterado o format do campo tel_vlopeprj para 
                            "zzz,zzz,zz9.99" (Adriano).
                            
               28/11/2011 - Adaptado fonte para o uso de BO. 
                            (Rogerius Militao - DB1 ).
                            
               17/04/2012 - Removido chamada para banco generico e substituido 
                            programa conscr.p por conscrp.p (Elton).                            
                            
               20/06/2012 - Incluida coluna 'Limite Credito' na opcao 'F' e
                            'M' (Tiago). 
                            
               07/08/2012 - Reajustado os forms de fluxo (Tiago).  
               
               29/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).    
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................ */

{ sistema/generico/includes/b1wgen0125tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }  
{ includes/gg0000.i }
    
DEF VAR h-b1wgen0125 AS HANDLE                                        NO-UNDO.

DEF  VAR  aux_cddopcao  AS CHAR.
                            
DEF  VAR  tel_tpconsul  AS  INTE FORMAT "9"                           NO-UNDO.
DEF  VAR  tel_nrcpfcgc  AS  DECI FORMAT "zzzzzzzzzzzzzz9"             NO-UNDO.
DEF  VAR  tel_cdagenci  AS  INTE FORMAT "zz9"                         NO-UNDO.
DEF  VAR  tel_nrdconta  AS  INTE                                      NO-UNDO.
                                                                      
DEF  VAR  aux_nrcpfcgc  AS  DECI FORMAT "zzz,zzz,zzz,zz9"             NO-UNDO.
DEF  VAR  aux_nrdconta  AS  INTE                                      NO-UNDO.
                                                                      
DEF  VAR  aux_contador  AS  INTE                                      NO-UNDO.
DEF  VAR  aux_nmarqimp  AS  CHAR                                      NO-UNDO.
DEF  VAR  aux_nmarqpdf  AS  CHAR                                      NO-UNDO.

DEF  VAR  tel_dsvencto  AS  CHAR  FORMAT "x(20)"          EXTENT 28   NO-UNDO.
DEF  VAR  tel_vlvencto  AS  DECI  FORMAT "->>,>>>,>>9.99" EXTENT 28   NO-UNDO.

DEF  VAR  aux_msgretor  AS  CHAR                                      NO-UNDO.

/* variaveis para impressao - opcao F */
DEF  VAR  par_flgrodar AS LOGICAL INIT TRUE                           NO-UNDO.
DEF  VAR  par_flgfirst AS LOGICAL INIT TRUE                           NO-UNDO.
DEF  VAR  par_flgcance AS LOGICAL                                     NO-UNDO.
DEF  VAR  tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"       NO-UNDO.
DEF  VAR  tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"       NO-UNDO.
DEF  VAR  aux_nmendter AS CHAR    FORMAT "x(20)"                      NO-UNDO.
DEF  VAR  aux_dscomand AS CHAR                                        NO-UNDO.
DEF  VAR  aux_flgescra AS LOGICAL                                     NO-UNDO.
DEF  VAR  aux_nmoperad AS CHAR    FORMAT "x(24)"                      NO-UNDO.
DEF  VAR  tel_hrtransa AS CHAR                                        NO-UNDO.
DEF  VAR  aux_tavencer AS CHAR    INITIAL "A VENCER"                  NO-UNDO.                                                                      
DEF  VAR  aux_tlimcred AS CHAR FORMAT "x(14)"   INIT "LIMITE CREDITO" NO-UNDO.
DEF  VAR  aux_tvencido AS CHAR    INITIAL "VENCIDOS"                  NO-UNDO.

/* variaveis para modalidades - opcao M */
DEF  VAR  aux_vencimen  AS  CHAR                                      NO-UNDO.
DEF  VAR  aux_cdmodali  LIKE crapvop.cdmodali                         NO-UNDO.  
DEF  VAR  aux_dsmodali  AS  CHAR FORMAT "x(40)"                       NO-UNDO.

DEF  VAR aux_dsdopcao AS CHAR EXTENT 2 INIT ["Detalhar Modalidade",    
                                             "Detalhar Vencimento"]   NO-UNDO.
DEF  VAR aux_iddopcao AS INTE                                         NO-UNDO.
DEF VAR aux_qtopcoes AS INTE                                          NO-UNDO.
/*************************************************************************/ 

/*** Definição de FORM ***/
FORM glb_cddopcao LABEL "Opcao" 
     HELP '"C"onsulta, "F"luxo, "R"impressao, "M"odalidade, "H"istorico'
     VALIDATE(glb_cddopcao = "C" OR
              glb_cddopcao = "F" OR
              glb_cddopcao = "R" OR
              glb_cddopcao = "M" OR
              glb_cddopcao = "H","014 - Opcao errada.")
     tel_tpconsul LABEL "Consulta"  AT 15
     VALIDATE(CAN-DO("1,2,3",tel_tpconsul),"014 - Opcao errada.")
     WITH SIDE-LABELS WIDTH 27 ROW 6 COLUMN 3 NO-BOX OVERLAY FRAME f_consulta.

FORM "PA:" 
     tel_cdagenci     NO-LABEL      
     HELP "Informe numero do PA."
     WITH WIDTH 10 ROW 6 COLUMN 32 OVERLAY NO-BOX FRAME f_consulta_pac.

FORM tel_nrdconta LABEL "Conta/dv"   FORMAT "zzzz,zzz,9"
     HELP "Informe o numero da conta ou <F7> para pesquisar."
     WITH WITH SIDE-LABELS OVERLAY ROW 6 COLUMN 32 WIDTH 25 NO-BOX
     FRAME f_consulta_conta.

FORM tel_nrcpfcgc LABEL "Numero do CPF/CNPJ"  
     HELP "Informe o numero CPF/CNPJ do cooperado."
     VALIDATE(tel_nrcpfcgc > 0,"780 - Nao ha associados com este CPF/CNPJ.")
     WITH SIDE-LABELS OVERLAY  ROW 6 COLUMN 32 WIDTH 37 NO-BOX
     FRAME f_consulta_cpf.

FORM "Data Base Bacen:" tt-complemento.dtrefere 
     SKIP
     "Qt.Oper.      Qt. IFs          Op.SFN"      
     "Op.Venc.            Op. Prej"                                AT 47
     SKIP
     tt-complemento.qtopesfn               FORMAT "zzz9"
     tt-complemento.qtifssfn               FORMAT "zzz9"           AT 16
     "R$"                                                          AT 24
     tt-complemento.vlopesfn               FORMAT ">>,>>>,>>9.99"     
     "R$"                                                          AT 44
     tt-complemento.vlopevnc               FORMAT "zzz,zz9.99"
     "R$"                                                          AT 60
     tt-complemento.vlopeprj               FORMAT "zzz,zzz,zz9.99"     
     SKIP(1)
     "OP.COOP.ATUAL: R$"  tt-complemento.vlopcoop
     tt-complemento.dtrefaux    FORMAT "99/99/9999"     AT 36 
     SKIP
     "OP.COOP.BACEN: R$"  tt-complemento.vlopbase
     tt-complemento.dtrefer2                            AT 36 
     WITH FRAME f_dados NO-LABEL NO-BOX ROW 15 COLUMN 3 OVERLAY.

FORM
    aux_tavencer                                      AT 01
    "VALOR"                                           AT 30
    aux_tlimcred                                      AT 36
    "VALOR"                                           AT 65
    tel_dsvencto[1]                                   AT 01
    tel_vlvencto[1]  VIEW-AS FILL-IN NO-LABEL AT 21     
    tel_dsvencto[13]                                  AT 36     
    tel_vlvencto[13] VIEW-AS FILL-IN NO-LABEL AT 56      
    tel_dsvencto[2]                                   AT 01
    tel_vlvencto[2]  VIEW-AS FILL-IN NO-LABEL AT 21
    tel_dsvencto[14]                                  AT 36     
    tel_vlvencto[14] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[3]                                   AT 01
    tel_vlvencto[3]  VIEW-AS FILL-IN NO-LABEL AT 21
    tel_dsvencto[15]                                  AT 36     
    tel_vlvencto[15] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[4]                                   AT 01
    tel_vlvencto[4]  VIEW-AS FILL-IN NO-LABEL AT 21
    tel_dsvencto[16]                                  AT 36     
    tel_vlvencto[16] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[5]                                   AT 01
    tel_vlvencto[5]  VIEW-AS FILL-IN NO-LABEL AT 21    
    ""                                                AT 36
    ""                                                AT 65
    tel_dsvencto[6]                                   AT 01
    tel_vlvencto[6]  VIEW-AS FILL-IN NO-LABEL AT 21
    aux_tvencido                                      AT 36
    ""                                                AT 65
    tel_dsvencto[7]                                   AT 01
    tel_vlvencto[7]  VIEW-AS FILL-IN NO-LABEL AT 21
    tel_dsvencto[17]                                  AT 36     
    tel_vlvencto[17] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[8]                                   AT 01
    tel_vlvencto[8]  VIEW-AS FILL-IN NO-LABEL AT 21
    tel_dsvencto[18]                                  AT 36     
    tel_vlvencto[18] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[9]                                   AT 01
    tel_vlvencto[9]  VIEW-AS FILL-IN NO-LABEL AT 21
    tel_dsvencto[19]                                  AT 36      
    tel_vlvencto[19] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[10]                                   AT 01
    tel_vlvencto[10]  VIEW-AS FILL-IN NO-LABEL AT 21
    tel_dsvencto[20]                                  AT 36
    tel_vlvencto[20] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[11]                                  AT 01
    tel_vlvencto[11] VIEW-AS FILL-IN NO-LABEL AT 21
    tel_dsvencto[21]                                  AT 36
    tel_vlvencto[21] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[12]                                  AT 01
    tel_vlvencto[12] VIEW-AS FILL-IN NO-LABEL AT 21     
    tel_dsvencto[22]                                  AT 36
    tel_vlvencto[22] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[23]                                  AT 36
    tel_vlvencto[23] VIEW-AS FILL-IN NO-LABEL AT 56     
    tel_dsvencto[24]                                  AT 36
    tel_vlvencto[24] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[25]                                  AT 36
    tel_vlvencto[25] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[26]                                  AT 36
    tel_vlvencto[26] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[27]                                  AT 36
    tel_vlvencto[27] VIEW-AS FILL-IN NO-LABEL AT 56
    tel_dsvencto[28]                                  AT 36
    tel_vlvencto[28] VIEW-AS FILL-IN NO-LABEL AT 56
    SKIP(2)
    WITH NO-LABEL OVERLAY ROW 7 COLUMN 3 WIDTH 76 FRAME f_fluxo.   

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

/*** Frame Detalhar Vencimento ***/
DEF FRAME f_modalidade_venc
    aux_vencimen VIEW-AS EDITOR SIZE 72 BY 13.5 BUFFER-LINES 22 NO-LABEL
    HELP "Pressione SETA P/ BAIXO ou SETA P/ CIMA para visualizar os venc"
    SKIP(2)
    WITH NO-LABEL OVERLAY ROW 7 COLUMN 3 WIDTH 76 TITLE COLOR NORMAL " 
    Vencimentos ".

/*** Browse Modalidades ***/
DEF QUERY q_opcaom FOR tt-modalidade.

DEF BROWSE b_opcaom QUERY q_opcaom
   DISPLAY tt-modalidade.cdmodali COLUMN-LABEL "Cod."       FORMAT "x(02)"
           tt-modalidade.dsmodali COLUMN-LABEL "Descricao"  FORMAT "x(40)"
           tt-modalidade.vlvencto COLUMN-LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"  
           WITH 7 DOWN NO-BOX WIDTH 73.

FORM b_opcaom
    WITH ROW 9 CENTERED OVERLAY TITLE COLOR NORMAL " Modalidades " 
    FRAME f_modalidade.

FORM aux_dsdopcao[1]  FORMAT "x(19)"
     SPACE(6)
     aux_dsdopcao[2]  FORMAT "x(19)"
     WITH ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.
/********************************************/

/*** Browse Detalhar Modalidade ***/
DEF QUERY q_detmodal FOR tt-detmodal.

DEF BROWSE b_detmodal QUERY q_detmodal
   DISPLAY tt-detmodal.cdmodali COLUMN-LABEL "Cod." 
           tt-detmodal.dssubmod COLUMN-LABEL "Descricao"
           tt-detmodal.vlvencto COLUMN-LABEL "Valor"      
           WITH 4 DOWN NO-BOX WIDTH 65.

DEF FRAME f_modalidade_det
    SKIP(1)
    "Modalidade Principal: " AT 03
    aux_cdmodali   NO-LABEL 
    "-"
    aux_dsmodali   NO-LABEL
    SKIP(1)
    b_detmodal
    HELP "Pressione ENTER para visualizar os vencimentos"
    WITH ROW 9 CENTERED OVERLAY TITLE COLOR NORMAL " Submodalidade ".
/***********************************/

/*** Browse opcao "H" ***/
DEF QUERY q_opcaoh FOR tt-historico SCROLLING.

DEF BROWSE b_opcaoh QUERY q_opcaoh
   DISPLAY tt-historico.dtrefere COLUMN-LABEL "Data Base"  
           tt-historico.vlvencto COLUMN-LABEL "Op. SFN"      
           tt-historico.dsdbacen COLUMN-LABEL "Obs."                    
           WITH 10 DOWN NO-BOX WIDTH 73.   

FORM b_opcaoh
    WITH ROW 8 CENTERED OVERLAY WIDTH 76 TITLE COLOR NORMAL " Historico " 
    FRAME f_historico.
/***********************************/

/*** Browse Vencimentos Fluxo ***/
DEF QUERY q_opcaof FOR tt-venc-fluxo.

DEF BROWSE b_opcaof QUERY q_opcaof
   DISPLAY tt-venc-fluxo.cdmodali COLUMN-LABEL "Cod."       FORMAT "x(02)"
           tt-venc-fluxo.dsmodali COLUMN-LABEL "Descricao"  FORMAT "x(40)"
           tt-venc-fluxo.vlvencto COLUMN-LABEL "Valor"      FORMAT "zzz,zzz,zz9.99"
           WITH 7 DOWN NO-BOX WIDTH 73.

FORM b_opcaof
    WITH ROW 9 CENTERED OVERLAY TITLE COLOR NORMAL " Vencimentos " 
    FRAME f_venc_fluxo.
/***********************************/

/*** Navegar pelas opções do browse Modalidades ***/
ON ANY-KEY OF b_opcaom IN FRAME f_modalidade
DO:
    ASSIGN aux_qtopcoes = 2.

    IF KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT" THEN
    DO:
        ASSIGN aux_iddopcao = aux_iddopcao + 1.

        IF aux_iddopcao > aux_qtopcoes THEN
           ASSIGN aux_iddopcao = 1.
        
        CHOOSE FIELD aux_dsdopcao[aux_iddopcao] PAUSE 0
            WITH FRAME f_opcoes.
    END.
    ELSE
    IF KEYFUNCTION(LASTKEY) = "CURSOR-LEFT" THEN
    DO: 
        ASSIGN aux_iddopcao = aux_iddopcao - 1.
 
        IF aux_iddopcao < 1 THEN
           ASSIGN aux_iddopcao = aux_qtopcoes.

        CHOOSE FIELD aux_dsdopcao[aux_iddopcao] PAUSE 0
            WITH FRAME f_opcoes.
    END.

    IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        HIDE FRAME f_modalidade.
END.

/************************************************************/ 

/*** Manipular as opcoes do browse Modalidades ***/
ON RETURN OF b_opcaom
DO:
    CASE aux_iddopcao:
        /*** Acionar a opcao Detalhar Modalidade ***/
        WHEN 1 THEN
        DO: 
            RUN Busca_Modalidade_Detalhe.
        END.

        /*** Acionar a opcao Detalhar Vencimento ***/
        WHEN 2 THEN
        DO:
            IF CAN-FIND(FIRST tt-modalidade) THEN
            DO: 
                HIDE FRAME f_opcoes.
                ASSIGN aux_cdmodali = tt-modalidade.cdmodali.
                RUN Busca_Modalidade_Vencimento.

                HIDE FRAME f_modalidade_venc.
                HIDE FRAME f_opcoes.

            END.
        END.
    END CASE.

    IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
    DO:
        HIDE FRAME f_modalidade_det.
        VIEW FRAME f_opcoes.
    END.
END.

/************************************************************/

/*** Manipular a opcao Detalhar Modalidade ***/
ON RETURN OF b_detmodal
DO:
    HIDE FRAME f_opcoes.
    ASSIGN aux_cdmodali = tt-detmodal.cdmodali.
    RUN Busca_Modalidade_Vencimento.

    HIDE FRAME f_modalidade_venc.
    HIDE FRAME f_opcoes.

END.

/************************************************************/

ON ANY-PRINTABLE OF tel_vlvencto
DO: 
    IF CAN-DO("0,1,2,3,4,5,6,7,8,9,-",KEYLABEL(LASTKEY)) THEN
        RETURN NO-APPLY.
END.

/********** Mostrar o vencimento de cada fluxo **********/
ON ENTER OF tel_vlvencto
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = SELF:INDEX:
        
        IF  tt-fluxo.vlvencto <> 0 THEN
            RUN Busca_Fluxo_Vencimento.

    END.

END.

/************************************************************/

/*** Consulta por CPF/CNPJ ***/
DEF QUERY q_contas FOR tt-contas.         

/** Lista as contas referente ao CPF informado**/
DEF BROWSE b_contas QUERY q_contas
            DISPLAY tt-contas.cdagenci  LABEL "PA"
                    tt-contas.nrdconta  LABEL "Conta/dv"
                    tt-contas.nmprimtl  LABEL "Titular"
                    tt-contas.tpdconta  LABEL "Tipo Conta"
                    tt-contas.idseqttl  LABEL "Seq."  
                    WITH 2 DOWN NO-BOX.

DEF  FRAME f_contas  
     SKIP(1) 
     b_contas   
     HELP "Selecione a Conta/dv  desejado."    
     WITH  OVERLAY WIDTH 77  COL 3 ROW 9 NO-BOX.
                  
/*** Consulta por Conta/dv ***/
DEF QUERY q_contas_cpf FOR tt-contas.                   

/** Lista os CPF's dos titulares referente a conta informada**/
DEF BROWSE b_contas_cpf QUERY q_contas_cpf
            DISPLAY tt-contas.cdagenci  LABEL "PA"
                    tt-contas.nrcpfcgc  LABEL "CPF/CNPJ" 
                                        FORMAT "zzzzzzzzzzzzzzz" 
                    tt-contas.nmprimtl  LABEL "Titular"  FORMAT "x(30)"
                    tt-contas.tpdconta  LABEL "Tipo Conta"
                    tt-contas.idseqttl  LABEL "Seq."  
            WITH 2 DOWN NO-BOX.

DEF FRAME f_contas_cpf  
      SKIP(1) 
      b_contas_cpf   
      HELP "Selecione o CPF/CNPJ desejado."    
      WITH  OVERLAY WIDTH 77  COL 3 ROW 9 NO-BOX.

/** Seleciona Consulta por CPF/CNPJ **/
ON RETURN OF b_contas DO:
     
   IF  glb_cddopcao = "C" THEN
       DO:
            RUN Busca_Complemento.
       END.
   ELSE 
   IF  glb_cddopcao = "F" THEN
   DO:
       RUN Busca_Fluxo.
       RUN Imprimir_Fluxo.
       HIDE FRAME f_fluxo.
   END.
   ELSE    
   IF  glb_cddopcao = "R" THEN /** Impressao **/
       APPLY "GO".
   ELSE
   IF  glb_cddopcao = "M" THEN /* Modalidades */
       RUN Busca_Modalidade.
   ELSE
   IF glb_cddopcao = "H" THEN /* Historico */
   DO:
        RUN Busca_Historico.
   END.
END.

/** Seleciona consulta por Conta/dv **/
ON RETURN OF b_contas_cpf DO:

   IF  glb_cddopcao = "C" THEN   /** Consulta **/
       DO:  
           PAUSE 0 NO-MESSAGE. 
           RUN Busca_Complemento.
       END.
   ELSE
   IF  glb_cddopcao = "F" THEN   /** Fluxo **/
   DO:
       RUN Busca_Fluxo.
       RUN Imprimir_Fluxo.
       HIDE FRAME f_fluxo.
   END.
   ELSE                    
   IF  glb_cddopcao = "R" THEN   /** Impressao **/
       APPLY "GO".    
   ELSE
   IF  glb_cddopcao = "M" THEN /* Modalidades */
       RUN Busca_Modalidade.
   ELSE
   IF  glb_cddopcao = "H" THEN /* Historico */
       RUN Busca_Historico. 
END.

/*** Inicio do programa ***/

ASSIGN glb_cddopcao = "C".

VIEW FRAME f_moldura.
 
PAUSE (0).

DO  WHILE TRUE  ON ENDKEY UNDO, LEAVE :         
                                         
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:                                     
        UPDATE   glb_cddopcao WITH FRAME f_consulta.
        LEAVE.
    END.
        
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         DO: 
             RUN  fontes/novatela.p.
             IF   CAPS(glb_nmdatela) <> "CONSCR"   THEN
                  DO:
                     IF  VALID-HANDLE(h-b1wgen0125)  THEN
                         DELETE PROCEDURE h-b1wgen0125.

                    LEAVE.
                END.

             ELSE
                  NEXT.
         END.
            
    IF   aux_cddopcao <> glb_cddopcao   THEN
         DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao
                   glb_cdcritic = 0.
         END.  
    
    RUN verifica_help.    

    UPDATE tel_tpconsul WITH FRAME f_consulta.

    RUN limpa_campos.
        
    IF  tel_tpconsul = 1 THEN   /**CPF/CNPJ**/
        DO:  
             UPDATE  tel_nrcpfcgc WITH FRAME f_consulta_cpf. 
        END.
    ELSE                  
    IF  tel_tpconsul = 2 THEN   /**Conta**/
        DO: 
            UPDATE tel_nrdconta WITH FRAME f_consulta_conta 
            EDITING:
                READKEY.
                IF  FRAME-FIELD = "tel_nrdconta"   AND
                    LASTKEY = KEYCODE("F7")        THEN
                    DO: 
                        RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                      OUTPUT aux_nrdconta).

                        IF  aux_nrdconta > 0   THEN
                            DO:
                                ASSIGN tel_nrdconta = aux_nrdconta.
                                DISPLAY tel_nrdconta 
                                    WITH FRAME f_consulta_conta.
                                PAUSE 0.
                                APPLY "RETURN".
                            END.
                    END.
                ELSE
                    APPLY LASTKEY.

            END.  /*  Fim do EDITING  */

        END.      
            
    RUN Busca_Dados.
    
    IF  RETURN-VALUE <> "OK" THEN
        NEXT.
    
    IF  AVAIL tt-contas THEN
        ASSIGN aux_nrcpfcgc = tt-contas.nrcpfcgc
               aux_nrdconta = tt-contas.nrdconta.

    /** Impressao **/
    IF  glb_cddopcao = "R" THEN 
        DO:
            IF  tel_tpconsul = 3 THEN /** PA **/
                DO:                     
                    UPDATE  tel_cdagenci 
                            WITH FRAME f_consulta_pac.
                    
                END.                                                   
                                             
                RUN Imprimir_Risco.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

        END.  

END.
                         

/*........................... PROCEDURE INTERNAS ...........................*/

PROCEDURE Busca_Dados:
    
    EMPTY TEMP-TABLE tt-contas.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0125) THEN
        RUN sistema/generico/procedures/b1wgen0125.p
            PERSISTENT SET h-b1wgen0125.

    RUN Busca_Dados IN h-b1wgen0125
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_tpconsul,
          INPUT tel_nrcpfcgc,
          INPUT tel_nrdconta,
          INPUT TRUE, /* flgerlog */
         OUTPUT aux_contador,
         OUTPUT TABLE tt-contas,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0125)  THEN
        DELETE PROCEDURE h-b1wgen0125.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
            
            RETURN "NOK".  
        END.
    ELSE
        DO:
            IF  tel_tpconsul = 1 THEN    /** CPF/CNPJ **/
                DO: /** Pessoa Fisica **/
    
                    OPEN QUERY q_contas FOR EACH tt-contas.
    
                    IF  aux_contador > 1 THEN
                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            UPDATE  b_contas WITH FRAME f_contas. 
                            LEAVE.                     
                        END.             
                    ELSE    
                        DO:
                           IF  glb_cddopcao = "C" THEN
                               DO:
                                    RUN Busca_Complemento.
    
                                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        DISPLAY  b_contas WITH FRAME f_contas. 
                                        LEAVE.                     
                                    END.             
                               END.
                           ELSE 
                           IF  glb_cddopcao = "F" THEN  
                           DO:
                               RUN Busca_Fluxo.
                               RUN Imprimir_Fluxo.
                               HIDE FRAME f_fluxo.
                           END.
                           ELSE
                           IF  glb_cddopcao = "M" THEN
                               RUN Busca_Modalidade.
                           ELSE
                           IF  glb_cddopcao = "H" THEN
                               RUN Busca_Historico.
                        END.
                END.
            ELSE
            IF  tel_tpconsul = 2 THEN    /** Conta **/
                DO: 
    
                    OPEN QUERY q_contas_cpf FOR EACH tt-contas.
    
                    IF  aux_contador > 1 THEN  
                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            UPDATE b_contas_cpf WITH FRAME f_contas_cpf.
                            LEAVE.                     
                        END.              
                    ELSE 
                        DO:
                            IF  glb_cddopcao = "C" THEN
                                DO:
                                    RUN Busca_Complemento.
    
                                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        DISPLAY b_contas_cpf 
                                            WITH FRAME f_contas_cpf.
                                        LEAVE.                     
                                    END.                                     
                                END.
                            ELSE    
                            IF  glb_cddopcao = "F" THEN  
                            DO:
                                RUN Busca_Fluxo.
                                RUN Imprimir_Fluxo.
                                HIDE FRAME f_fluxo.
                            END.
                            ELSE
                            IF  glb_cddopcao = "M" THEN
                                RUN Busca_Modalidade.
                            ELSE
                            IF  glb_cddopcao = "H" THEN
                                RUN Busca_Historico.
                        END.
                END.        /** Fim tel_tpconsul = 2 **/

        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */


PROCEDURE Busca_Complemento:
        
    ASSIGN aux_msgretor = "".

    EMPTY TEMP-TABLE tt-complemento.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0125) THEN
        RUN sistema/generico/procedures/b1wgen0125.p
            PERSISTENT SET h-b1wgen0125.

    RUN Busca_Complemento IN h-b1wgen0125
        ( INPUT glb_cdcooper,
          INPUT glb_cdoperad,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tt-contas.nrcpfcgc,
          INPUT tt-contas.nrdconta,
          INPUT TRUE,
         OUTPUT aux_msgretor,
         OUTPUT TABLE tt-complemento,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0125)  THEN
        DELETE PROCEDURE h-b1wgen0125.

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

            FIND FIRST tt-complemento NO-ERROR.
             
            IF  AVAILABLE tt-complemento THEN
                DISPLAY  tt-complemento.dtrefere
                         tt-complemento.qtopesfn 
                         tt-complemento.qtifssfn 
                         tt-complemento.vlopesfn
                         tt-complemento.vlopevnc
                         tt-complemento.vlopeprj
                         tt-complemento.vlopcoop
                         tt-complemento.dtrefaux 
                         tt-complemento.vlopbase
                         tt-complemento.dtrefer2
                         WITH FRAME f_dados.

            IF  aux_msgretor <> "" THEN
                MESSAGE aux_msgretor.
    END.

    RETURN "OK".

END PROCEDURE. /* Busca_Complemento */

PROCEDURE Busca_Fluxo:
    
    PAUSE 0 NO-MESSAGE.

    ASSIGN aux_msgretor = "".

    EMPTY TEMP-TABLE tt-fluxo.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0125) THEN
        RUN sistema/generico/procedures/b1wgen0125.p
            PERSISTENT SET h-b1wgen0125.

    RUN Busca_Fluxo IN h-b1wgen0125
        ( INPUT tt-contas.nrcpfcgc,
         OUTPUT aux_msgretor,
         OUTPUT TABLE tt-fluxo,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0125)  THEN
        DELETE PROCEDURE h-b1wgen0125.

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

            ASSIGN tel_dsvencto = "".
            ASSIGN tel_vlvencto = 0.
                       /*tiago*/
            FOR EACH tt-fluxo:
                ASSIGN tel_dsvencto[tt-fluxo.elemento] = tt-fluxo.dsvencto.
                ASSIGN tel_vlvencto[tt-fluxo.elemento] = tt-fluxo.vlvencto.
            END.
        END.

    RUN verifica_help.

    IF  aux_msgretor <> "" THEN
        MESSAGE aux_msgretor.
    ELSE
        DO:
            DISPLAY aux_tavencer aux_tlimcred
                    aux_tvencido tel_dsvencto WITH FRAME f_fluxo.
            UPDATE aux_tavencer  aux_tlimcred
                   aux_tvencido  tel_vlvencto WITH FRAME f_fluxo.
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Fluxo */

PROCEDURE Busca_Fluxo_Vencimento:
    
    EMPTY TEMP-TABLE tt-venc-fluxo.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0125) THEN
        RUN sistema/generico/procedures/b1wgen0125.p
            PERSISTENT SET h-b1wgen0125.

    RUN Busca_Fluxo_Vencimento IN h-b1wgen0125
        ( INPUT tt-contas.nrcpfcgc,
          INPUT tt-fluxo.cdvencto,
         OUTPUT TABLE tt-venc-fluxo,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0125)  THEN
        DELETE PROCEDURE h-b1wgen0125.

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

            HIDE FRAME f_fluxo.
    
            /* Mostrar o browse */
            IF CAN-FIND(FIRST tt-venc-fluxo) THEN
            DO:
                OPEN QUERY q_opcaof FOR EACH tt-venc-fluxo.
    
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    UPDATE b_opcaof WITH FRAME f_venc_fluxo.
                    LEAVE.
                END.
            END.
    
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            DO:
                HIDE FRAME f_venc_fluxo.
                VIEW FRAME f_fluxo.
            END.
    
            IF CAN-FIND(FIRST tt-venc-fluxo) THEN
                EMPTY TEMP-TABLE tt-venc-fluxo.

        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Fluxo_Vencimento */

PROCEDURE Imprimir_Fluxo:
    
    DEF  VAR  aux_confirma  AS  LOGI  FORMAT "S/N"                    NO-UNDO.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            MESSAGE "Deseja imprimir?(S/N)" UPDATE aux_confirma .
    
            IF  aux_confirma = TRUE THEN
                DO:
    
                    EMPTY TEMP-TABLE tt-erro.
                
                    INPUT THROUGH basename `tty` NO-ECHO.
                        SET aux_nmendter WITH FRAME f_terminal.
                    INPUT CLOSE.
                    
                    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                          aux_nmendter.
                
                    IF  NOT VALID-HANDLE(h-b1wgen0125) THEN
                        RUN sistema/generico/procedures/b1wgen0125.p
                            PERSISTENT SET h-b1wgen0125.
                
                    RUN Imprimir_Fluxo IN h-b1wgen0125
                        ( INPUT glb_cdcooper,
                          INPUT glb_cdagenci,
                          INPUT 0,
                          INPUT 1,
                          INPUT glb_dtmvtolt,
                          INPUT aux_nmendter,
                          INPUT tt-contas.nrcpfcgc,
                          INPUT tt-contas.nmprimtl,
                          INPUT tt-contas.nrdconta,
                         OUTPUT aux_nmarqimp,
                         OUTPUT aux_nmarqpdf,
                         OUTPUT TABLE tt-erro).
                
                    IF  VALID-HANDLE(h-b1wgen0125)  THEN
                        DELETE PROCEDURE h-b1wgen0125.
                
                    IF  RETURN-VALUE <> "OK" OR 
                        TEMP-TABLE tt-erro:HAS-RECORDS THEN
                        DO:
                            FIND FIRST tt-erro NO-ERROR.
                
                            IF  AVAILABLE tt-erro THEN
                                MESSAGE tt-erro.dscritic.
                
                            PAUSE.
                                   
                            RETURN "NOK".  
                        END.
                    ELSE
                        DO:
                            ASSIGN glb_nrdevias    = 1
                                   glb_cdempres    = 11
                                   glb_nmformul    = "80col"
                                   glb_cdrelato[1] = 569
                                   par_flgrodar = TRUE.

                            FIND FIRST crapass 
                                WHERE crapass.nrdconta=tt-contas.nrdconta 
                                NO-LOCK NO-ERROR.
                            { includes/impressao.i }/*  Rotina de impressao  */
                        END.
    
                END. /* IF  aux_confirma = TRUE THEN */

        END. /* IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN */

    RETURN "OK".

END PROCEDURE. /* Imprimir_Fluxo */

PROCEDURE Imprimir_Risco:
    
    EMPTY TEMP-TABLE tt-erro.

    INPUT THROUGH basename `tty` NO-ECHO.
        SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    IF  NOT VALID-HANDLE(h-b1wgen0125) THEN
        RUN sistema/generico/procedures/b1wgen0125.p
            PERSISTENT SET h-b1wgen0125.

    RUN Imprimir_Risco IN h-b1wgen0125
        ( INPUT glb_cdcooper,
          INPUT 0, 
          INPUT 0, 
          INPUT glb_nmdatela,
          INPUT glb_cdoperad,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT aux_nmendter,
          INPUT glb_cddopcao,
          INPUT tel_tpconsul,
          INPUT aux_nrcpfcgc,
          INPUT aux_nrdconta,
          INPUT tel_cdagenci,
          INPUT YES, /* erro */
          INPUT YES, /* log  */
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0125)  THEN
        DELETE PROCEDURE h-b1wgen0125.

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
            FIND FIRST crapass 
                WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
            { includes/impressao.i }           /*  Rotina de impressao  */
        END.
    
    RETURN "OK".

END PROCEDURE. /* Imprimir_Risco */


PROCEDURE Busca_Historico:
    
    EMPTY TEMP-TABLE tt-historico.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0125) THEN
        RUN sistema/generico/procedures/b1wgen0125.p
            PERSISTENT SET h-b1wgen0125.

    RUN Busca_Historico IN h-b1wgen0125
        ( INPUT tt-contas.nrcpfcgc,
         OUTPUT TABLE tt-historico,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0125)  THEN
        DELETE PROCEDURE h-b1wgen0125.

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

            HIDE FRAME f_modalidade.
            HIDE FRAME f_opcoes.
            HIDE FRAME f_modalidade_det.
    
            OPEN QUERY q_opcaoh FOR EACH tt-historico.
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE b_opcaoh WITH FRAME f_historico.
                LEAVE.
            END.
    
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                HIDE FRAME f_historico.
    
            IF  CAN-FIND(FIRST tt-historico) THEN
                EMPTY TEMP-TABLE tt-historico.
    
        END.


    RETURN "OK".

END PROCEDURE. /* Busca_Historico */

PROCEDURE Busca_Modalidade:
    
    PAUSE 0 NO-MESSAGE.

    ASSIGN aux_msgretor = "".

    EMPTY TEMP-TABLE tt-modalidade.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0125) THEN
        RUN sistema/generico/procedures/b1wgen0125.p
            PERSISTENT SET h-b1wgen0125.

    RUN Busca_Modalidade IN h-b1wgen0125
        ( INPUT tt-contas.nrcpfcgc,
         OUTPUT aux_msgretor,
         OUTPUT TABLE tt-modalidade,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0125)  THEN
        DELETE PROCEDURE h-b1wgen0125.

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
            IF  aux_msgretor <> "" THEN
                MESSAGE aux_msgretor.
            ELSE
                DO:
                    /* Mostrar o browse */
                    IF CAN-FIND(FIRST tt-modalidade) THEN
                    DO:
                        ASSIGN aux_iddopcao = 1.
            
                        OPEN QUERY q_opcaom FOR EACH tt-modalidade.
            
                        DISPLAY aux_dsdopcao WITH FRAME f_opcoes.
            
                        CHOOSE FIELD aux_dsdopcao[aux_iddopcao] PAUSE 0
                            WITH FRAME f_opcoes.
            
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            UPDATE b_opcaom WITH FRAME f_modalidade.
                            LEAVE.
                        END.
                    END.
            
                    IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                        HIDE FRAME f_opcoes.
            
                    IF CAN-FIND(FIRST tt-modalidade) THEN
                        EMPTY TEMP-TABLE tt-modalidade.

                END.

        END.


    RETURN "OK".

END PROCEDURE. /* Busca_Modalidade */

PROCEDURE Busca_Modalidade_Detalhe:
    
    EMPTY TEMP-TABLE tt-detmodal.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0125) THEN
        RUN sistema/generico/procedures/b1wgen0125.p
            PERSISTENT SET h-b1wgen0125.

    RUN Busca_Modalidade_Detalhe IN h-b1wgen0125
        ( INPUT tt-contas.nrcpfcgc,
          INPUT tt-modalidade.cdmodali,
         OUTPUT aux_cdmodali, 
         OUTPUT aux_dsmodali, 
         OUTPUT TABLE tt-detmodal,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0125)  THEN
        DELETE PROCEDURE h-b1wgen0125.

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

            IF CAN-FIND(FIRST tt-detmodal) THEN
            DO:
                HIDE FRAME f_opcoes.
    
                OPEN QUERY q_detmodal FOR EACH tt-detmodal.
    
                DISPLAY aux_cdmodali 
                        aux_dsmodali
                    WITH FRAME f_modalidade_det.
    
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    UPDATE b_detmodal WITH FRAME f_modalidade_det.
                    LEAVE.
                END.
            END.
    
            IF  CAN-FIND(FIRST tt-detmodal) THEN
                EMPTY TEMP-TABLE tt-detmodal.

        END.


    RETURN "OK".

END PROCEDURE. /* Busca_Modalidade_Detalhe */


PROCEDURE Busca_Modalidade_Vencimento:
    
    EMPTY TEMP-TABLE tt-fluxo.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0125) THEN
        RUN sistema/generico/procedures/b1wgen0125.p
            PERSISTENT SET h-b1wgen0125.

    RUN Busca_Modalidade_Vencimento IN h-b1wgen0125
        ( INPUT tt-contas.nrcpfcgc,
          INPUT aux_cdmodali,
         OUTPUT aux_cdmodali,
         OUTPUT aux_dsmodali,
         OUTPUT aux_msgretor,
         OUTPUT TABLE tt-fluxo,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0125)  THEN
        DELETE PROCEDURE h-b1wgen0125.

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
    
           IF  aux_msgretor <> "" THEN
                MESSAGE aux_msgretor.
           ELSE
                DO:
                    ASSIGN tel_dsvencto = "".
                    ASSIGN tel_vlvencto = 0.
            
                    FOR EACH tt-fluxo:
                        ASSIGN tel_dsvencto[tt-fluxo.elemento] = 
                            tt-fluxo.dsvencto.
                        ASSIGN tel_vlvencto[tt-fluxo.elemento] = 
                            tt-fluxo.vlvencto.
                    END.
        
                    ASSIGN aux_vencimen = "" + CHR(10)  +
                    "Modalidade Principal: " + aux_cdmodali + " - " + 
                    aux_dsmodali               + CHR(10)  + " " + CHR(10) + 
                    "A VENCER                    VALOR  LIMITE DE CREDITO             VALOR"     + CHR(10)  +  
                    tel_dsvencto[1]  + "        " + string(tel_vlvencto[1],"zzz,zzz,zz9.99")   + "  " +       
                    SUBSTR(tel_dsvencto[13],1,21) + ""      + string(tel_vlvencto[13],"zzz,zzz,zz9.99")  + CHR(10)  +  
                    tel_dsvencto[2]  + "    "     + string(tel_vlvencto[2],"zzz,zzz,zz9.99")   + "  " +  
                    SUBSTR(tel_dsvencto[14],1,21) + ""       + string(tel_vlvencto[14],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    tel_dsvencto[3]  + "    "     + string(tel_vlvencto[3],"zzz,zzz,zz9.99")   + "  " +  
                    SUBSTR(tel_dsvencto[15],1,21) + ""       + string(tel_vlvencto[15],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    tel_dsvencto[4]  + "   "      + string(tel_vlvencto[4],"zzz,zzz,zz9.99")   + "  " +  
                    SUBSTR(tel_dsvencto[16],1,21) + ""       + string(tel_vlvencto[16],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    tel_dsvencto[5]  + "  "       + string(tel_vlvencto[5],"zzz,zzz,zz9.99")   + CHR(10) +
                    tel_dsvencto[6]  + "  "       + string(tel_vlvencto[6],"zzz,zzz,zz9.99")   + "  " +
                    "VENCIDOS                      "   +  CHR(10) +
                    tel_dsvencto[7]  + " "        + string(tel_vlvencto[7],"zzz,zzz,zz9.99")   + "  " + 
                    tel_dsvencto[17] + "       "  + string(tel_vlvencto[17],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    tel_dsvencto[8]  + ""         + string(tel_vlvencto[8],"zzz,zzz,zz9.99")   + "  " +  
                    tel_dsvencto[18] + "      "   + string(tel_vlvencto[18],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    tel_dsvencto[9]  + ""         + string(tel_vlvencto[9],"zzz,zzz,zz9.99")   + "  "     +
                    tel_dsvencto[19] + "      "   + string(tel_vlvencto[19],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    tel_dsvencto[10] + ""         + string(tel_vlvencto[10],"zzz,zzz,zz9.99")  + "  " +
                    tel_dsvencto[20] + "      "   + string(tel_vlvencto[20],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    tel_dsvencto[11] + " "        + string(tel_vlvencto[11],"zzz,zzz,zz9.99")  + "  " +  
                    tel_dsvencto[21] + "     "    + string(tel_vlvencto[21],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    tel_dsvencto[12] + ""         + string(tel_vlvencto[12],"zzz,zzz,zz9.99")  + "  " +  
                    tel_dsvencto[22] + "    "     + string(tel_vlvencto[22],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    "                                   " +
                    tel_dsvencto[23] + "    "     + string(tel_vlvencto[23],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    "                                   " +
                    tel_dsvencto[24] + "    "     + string(tel_vlvencto[24],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    "                                   " +
                    tel_dsvencto[25] + "    "     + string(tel_vlvencto[25],"zzz,zzz,zz9.99")  + CHR(10)  +
                    "                                   " +
                    tel_dsvencto[26] + "    "     + string(tel_vlvencto[26],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    "                                   " +
                    tel_dsvencto[27] + "    "     + string(tel_vlvencto[27],"zzz,zzz,zz9.99")  + CHR(10)  + 
                    "                                   " +
                    tel_dsvencto[28] + "    "     + string(tel_vlvencto[28],"zzz,zzz,zz9.99").
                    UPDATE aux_vencimen WITH FRAME f_modalidade_venc.
                    
                    HIDE FRAME f_modalidade_venc.
                    HIDE FRAME f_opcoes.
                    
                    IF  CAN-FIND(FIRST tt-fluxo) THEN
                        EMPTY TEMP-TABLE tt-fluxo.

                END.

        END.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Modalidade_Vencimento */

PROCEDURE limpa_campos.

    ASSIGN  tel_nrcpfcgc = 0
            aux_nrcpfcgc = 0 
            tel_nrdconta = 0 
            tel_cdagenci = 0            
            aux_contador = 0.

    EMPTY TEMP-TABLE tt-contas.  
    EMPTY TEMP-TABLE tt-modalidade.
    EMPTY TEMP-TABLE tt-detmodal.
    EMPTY TEMP-TABLE tt-historico.
    EMPTY TEMP-TABLE tt-venc-fluxo.
    EMPTY TEMP-TABLE tt-fluxo.
    HIDE FRAME f_contas.                     
    HIDE FRAME f_contas_cpf.    
    HIDE FRAME f_dados.
    HIDE FRAME f_consulta_cpf.
    HIDE FRAME f_consulta_conta. 
    HIDE FRAME f_fluxo. 
    HIDE FRAME f_modalidade.
    HIDE FRAME f_opcoes.
    HIDE FRAME f_modalidade_det.
    HIDE FRAME f_historico.
    HIDE FRAME f_venc_fluxo.
      
END PROCEDURE.

PROCEDURE verifica_help:

    IF  glb_cddopcao = "C" OR
        glb_cddopcao = "F" OR 
        glb_cddopcao = "M" OR 
        glb_cddopcao = "H" THEN 
        ASSIGN  tel_tpconsul:HELP 
                IN FRAME f_consulta = "1-CPF/CNPJ, 2-Conta Corrente".
    ELSE
    IF  glb_cddopcao = "R" THEN
        ASSIGN tel_tpconsul:HELP 
               IN FRAME f_consulta = "1-CPF/CNPJ, 2-Conta Corrente, 3-PA".     

    ASSIGN tel_vlvencto[1]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[2]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[3]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[4]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[5]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[6]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[7]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[8]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[9]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[10]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[11]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[12]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[13]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[14]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[15]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[16]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[17]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[18]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[19]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[20]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[21]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[22]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[23]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid."
           tel_vlvencto[24]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid.".
           tel_vlvencto[25]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid.".
           tel_vlvencto[26]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid.".
           tel_vlvencto[27]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid.".
           tel_vlvencto[28]:HELP IN FRAME f_fluxo = 
           "Pressione TAB para navegar e ENTER para visualizar as modalid.".

END.

