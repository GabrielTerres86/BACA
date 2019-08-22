/* ..........................................................................

   Programa: Fontes/conscrp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Julho/2010                          Ultima atualizacao: 02/08/2016

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
                                                        
               05/04/2012 - Incluido index crapopf2 na consulta da data-base
                            e aumentado o format do campo tel_vlopevnc.
                            (Irlan)
               
               21/05/2012 - Implementado tratamento crapces (Tiago).    
               
               10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).    
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                          terminal (Tiago-RKAM).
                                                  
               25/06/2014 - Ajuste leitura CRAPRIS (Daniel) SoftDesk 137892. 

               02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel.
                            (Jaison/Anderson)

............................................................................. */

{includes/var_online.i }  

{includes/gg0000.i}
    
DEF  VAR  aux_cddopcao  AS CHAR.

DEF  VAR  tel_tpconsul  AS INTE FORMAT "9"                            NO-UNDO.
DEF  VAR  tel_nrcpfcgc  AS DECI FORMAT "zzzzzzzzzzzzzz9"              NO-UNDO.
DEF  VAR  tel_cdagenci  AS INTE FORMAT "zz9"                          NO-UNDO.
DEF  VAR  tel_nrdconta  AS INTE                                       NO-UNDO.
                                                                      
DEF  VAR  aux_nrcpfcgc  AS DECI FORMAT "zzz,zzz,zzz,zz9"              NO-UNDO.
DEF  VAR  aux_nrdconta  AS INTE                                       NO-UNDO.
DEF  VAR  aux_dtrefere  AS DATE                                       NO-UNDO.
DEF  VAR  aux_flgdelog  AS LOGI                                       NO-UNDO.
DEF  VAR  aux_contador  AS INTE                                       NO-UNDO.
DEF  VAR  aux_regexist  AS  LOGICAL                                   NO-UNDO.
                                                                      
DEF  VAR  tel_vlopesfn  AS DECI                                       NO-UNDO.
DEF  VAR  tel_vlopevnc  AS DECI                                       NO-UNDO.
DEF  VAR  tel_vlopeprj  AS DECI                                       NO-UNDO.
DEF  VAR  tel_vlopcoop  AS DECI FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF  VAR  tel_vlopbase  AS DECI FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF  VAR  tel_dtrefere  AS CHAR                                       NO-UNDO.
DEF  VAR  tel_dtrefere2 AS CHAR                                       NO-UNDO.
DEF  VAR  tel_qtopesfn  LIKE crapopf.qtopesfn                         NO-UNDO.
DEF  VAR  tel_qtifssfn  LIKE crapopf.qtifssfn                         NO-UNDO.

DEF  VAR  aux_nmarqimp  AS  CHAR                                      NO-UNDO.
DEF  VAR  tel_vlvencto  AS  DECI  FORMAT "->>,>>>,>>9.99" EXTENT 24   NO-UNDO.
DEF  VAR  aux_confirma  AS  LOGI  FORMAT "S/N"                        NO-UNDO.

/* variaveis cabecalho */
DEF  VAR  rel_nmempres    AS CHAR FORMAT "x(15)"                      NO-UNDO.
DEF  VAR  rel_nmrelato    AS CHAR FORMAT "x(40)" EXTENT 5             NO-UNDO.
DEF  VAR  rel_nrmodulo    AS INT  FORMAT "9"                          NO-UNDO.
DEF  VAR  rel_nmmodulo    AS CHAR FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                      "EMPRESTIMOS    ","DIGITACAO      ",
                                      "GENERICO       "]              NO-UNDO.
DEF  VAR  rel_nmmesref    AS CHAR FORMAT "x(014)"                     NO-UNDO.
DEF  VAR  rel_nmresemp    AS CHAR FORMAT "x(15)"                      NO-UNDO.

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
                                                                      
/* variaveis para modalidades - opcao M */                            
DEF VAR aux_reganter AS CHAR FORMAT "x(02)"                           NO-UNDO.
DEF VAR aux_dsdopcao AS CHAR EXTENT 2 INIT ["Detalhar Modalidade",    
                                            "Detalhar Vencimento"]    NO-UNDO.
DEF VAR aux_iddopcao AS INTE                                          NO-UNDO.
DEF VAR aux_qtopcoes AS INTE                                          NO-UNDO.
/*************************************************************************/ 

/* variaveis para historico - opcao H */
DEF VAR aux_dtrefsum AS CHAR FORMAT "x(08)"                          NO-UNDO.
/*************************************************************************/ 

DEF NEW SHARED VAR shr_inpessoa AS INT                               NO-UNDO.

/*** Definição de Temp-Table ***/
DEF TEMP-TABLE tt-contas 
         FIELD cdagenci AS INTE FORMAT "zz9"
         FIELD nrdconta AS INTE FORMAT "zzzz,zzz,z"
         FIELD nrcpfcgc AS DECI 
         FIELD nmprimtl AS CHAR FORMAT "x(35)"
         FIELD tpdconta AS CHAR FORMAT "x(15)"
         FIELD idseqttl LIKE crapttl.idseqttl.

DEF TEMP-TABLE tt-modalidade NO-UNDO
    FIELD cdmodali AS CHAR FORMAT "x(02)"
    FIELD dsmodali AS CHAR FORMAT "x(40)"
    FIELD vlvencto LIKE crapvop.vlvencto.

DEF TEMP-TABLE tt-detmodal NO-UNDO
    FIELD cdmodali LIKE crapvop.cdmodali
    FIELD dssubmod AS CHAR FORMAT "x(40)"
    FIELD vlvencto LIKE crapvop.vlvencto.

DEF TEMP-TABLE tt-venmodal NO-UNDO
    FIELD cdmodali LIKE crapvop.cdmodali
    FIELD dsmodali AS CHAR FORMAT "x(40)"
    FIELD vlvencto AS DECI FORMAT "->>,>>>,>>9.99"  EXTENT 24
    FIELD vencimen AS CHAR.

DEF TEMP-TABLE tt-historico NO-UNDO
    FIELD dtrefere AS CHAR 
    FIELD vlvencto AS DECI FORMAT "->>,>>>,>>9.99"
    FIELD dsdbacen AS CHAR FORMAT "x(43)"
    FIELD dtcomple LIKE crapopf.dtrefere.

DEF TEMP-TABLE tt-ordenada NO-UNDO LIKE tt-historico.

DEF TEMP-TABLE tt-fluxo NO-UNDO
    FIELD cdvencto LIKE crapvop.cdvencto
    FIELD elemento AS INT.

DEF TEMP-TABLE tt-venc-fluxo NO-UNDO
    FIELD cdmodali AS CHAR FORMAT "x(02)"
    FIELD dsmodali LIKE gnmodal.dsmodali
    FIELD vlvencto LIKE crapvop.vlvencto.

DEF STREAM str_1.

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
     HELP "Informe o numero de conta/dv do cooperado."
     WITH WITH SIDE-LABELS OVERLAY ROW 6 COLUMN 32 WIDTH 25 NO-BOX
     FRAME f_consulta_conta.

FORM tel_nrcpfcgc LABEL "Numero do CPF/CNPJ"  
     HELP "Informe o numero CPF/CNPJ do cooperado."
     VALIDATE(tel_nrcpfcgc > 0,"780 - Nao ha associados com este CPF/CNPJ.")
     WITH SIDE-LABELS OVERLAY  ROW 6 COLUMN 32 WIDTH 37 NO-BOX
     FRAME f_consulta_cpf.

FORM "Data Base Bacen:" tel_dtrefere 
     SKIP
     "Qt.Oper.      Qt. IFs          Op.SFN"      
     "Op.Venc.            Op. Prej"             AT 47
     SKIP
     tel_qtopesfn       FORMAT "zzz9"
     tel_qtifssfn       FORMAT "zzz9"           AT 16
     "R$"                                       AT 24
     tel_vlopesfn       FORMAT ">>,>>>,>>9.99"     
     "R$"                                       AT 44
     tel_vlopevnc       FORMAT "z,zzz,zz9.99"
     "R$"                                       AT 61
     tel_vlopeprj       FORMAT "zz,zzz,zz9.99"     
     SKIP(1)
     "OP.COOP.ATUAL: R$"  tel_vlopcoop
     aux_dtrefere       FORMAT "99/99/9999"     AT 36 
     SKIP
     "OP.COOP.BACEN: R$"  tel_vlopbase
     tel_dtrefere2                              AT 36 
     WITH FRAME f_dados NO-LABEL NO-BOX ROW 15 COLUMN 3 OVERLAY.
     
FORM "CPF/CNPJ :"        tt-contas.nrcpfcgc  FORMAT "zzzzzzzzzzzzzzz" 
     "-" tt-contas.nmprimtl 
     SKIP
     "CONTA/DV :     "   tt-contas.nrdconta
     SKIP
     "DATA BASE:       " tel_dtrefere  
     SKIP(1)
     WITH COLUMN 4 NO-LABEL NO-BOX FRAME f_fluxo_cab.
                 
FORM
    "A VENCER"                                        AT 01
    "VALOR"                                           AT 30
    "VENCIDOS"                                        AT 38
    "VALOR"                                           AT 65
    "Ate 30 dias"                                     AT 01
    tel_vlvencto[1]  VIEW-AS FILL-IN NO-LABEL AT 21     
    "de 1 a 14 dias"                                  AT 38     
    tel_vlvencto[13] VIEW-AS FILL-IN NO-LABEL AT 56      
    "de 31 a 60 dias"                                 AT 01
    tel_vlvencto[2]  VIEW-AS FILL-IN NO-LABEL AT 21
    "de 15 a 30 dias"                                 AT 38     
    tel_vlvencto[14] VIEW-AS FILL-IN NO-LABEL AT 56
    "de 61 a 90 dias"                                 AT 01
    tel_vlvencto[3]  VIEW-AS FILL-IN NO-LABEL AT 21
    "de 31 a 60 dias"                                 AT 38     
    tel_vlvencto[15] VIEW-AS FILL-IN NO-LABEL AT 56
    "de 91 a 180 dias"                                AT 01
    tel_vlvencto[4]  VIEW-AS FILL-IN NO-LABEL AT 21
    "de 61 a 90 dias"                                 AT 38     
    tel_vlvencto[16] VIEW-AS FILL-IN NO-LABEL AT 56
    "de 181 a 360 dias"                               AT 01
    tel_vlvencto[5]  VIEW-AS FILL-IN NO-LABEL AT 21
    "de 91 a 120 dias"                                AT 38     
    tel_vlvencto[17] VIEW-AS FILL-IN NO-LABEL AT 56
    "de 361 a 720 dias"                               AT 01
    tel_vlvencto[6]  VIEW-AS FILL-IN NO-LABEL AT 21
    "de 121 a 150 dias"                               AT 38     
    tel_vlvencto[18] VIEW-AS FILL-IN NO-LABEL AT 56
    "de 721 a 1080 dias"                              AT 01
    tel_vlvencto[7]  VIEW-AS FILL-IN NO-LABEL AT 21
    "de 151 a 180 dias"                               AT 38      
    tel_vlvencto[19] VIEW-AS FILL-IN NO-LABEL AT 56
    "de 1081 a 1440 dias"                             AT 01
    tel_vlvencto[8]  VIEW-AS FILL-IN NO-LABEL AT 21
    "de 181 a 240 dias"                               AT 38
    tel_vlvencto[20] VIEW-AS FILL-IN NO-LABEL AT 56
    "de 1441 a 1800 dias"                             AT 01
    tel_vlvencto[9]  VIEW-AS FILL-IN NO-LABEL AT 21
    "de 241 a 300 dias"                               AT 38
    tel_vlvencto[21] VIEW-AS FILL-IN NO-LABEL AT 56
    "de 1801 a 5400 dias"                             AT 01
    tel_vlvencto[10] VIEW-AS FILL-IN NO-LABEL AT 21
    "de 301 a 360 dias"                               AT 38
    tel_vlvencto[22] VIEW-AS FILL-IN NO-LABEL AT 56
    "acima de 5400 dias"                              AT 01
    tel_vlvencto[11] VIEW-AS FILL-IN NO-LABEL AT 21     
    "de 361 a 540 dias"                               AT 38
    tel_vlvencto[23] VIEW-AS FILL-IN NO-LABEL AT 56     
    "com prazo indeterm."                             AT 01
    tel_vlvencto[12] VIEW-AS FILL-IN NO-LABEL AT 21
    "acima de 540 dias"                               AT 38
    tel_vlvencto[24] VIEW-AS FILL-IN NO-LABEL AT 56
    SKIP(2)
    WITH NO-LABEL OVERLAY ROW 7 COLUMN 3 WIDTH 76 FRAME f_fluxo.   

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

/*** Frame Detalhar Vencimento ***/
DEF FRAME f_modalidade_venc
    tt-venmodal.vencimen VIEW-AS EDITOR SIZE 72 BY 13.5 BUFFER-LINES 16 NO-LABEL
    HELP "Pressione SETA P/ BAIXO ou SETA P/ CIMA para visualizar os venc"
    SKIP(2)
    WITH NO-LABEL OVERLAY ROW 7 COLUMN 3 WIDTH 76 TITLE COLOR NORMAL " Vencimentos ".

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
    tt-modalidade.cdmodali   NO-LABEL 
    "-"
    tt-modalidade.dsmodali   NO-LABEL
    SKIP(1)
    b_detmodal
    HELP "Pressione ENTER para visualizar os vencimentos"
    WITH ROW 9 CENTERED OVERLAY TITLE COLOR NORMAL " Submodalidade ".
/***********************************/

/*** Browse opcao "H" ***/
DEF QUERY q_opcaoh FOR tt-ordenada SCROLLING.

DEF BROWSE b_opcaoh QUERY q_opcaoh
   DISPLAY tt-ordenada.dtrefere COLUMN-LABEL "Data Base"  
           tt-ordenada.vlvencto COLUMN-LABEL "Op. SFN"      
           tt-ordenada.dsdbacen COLUMN-LABEL "Obs."                    
           WITH 10 DOWN NO-BOX WIDTH 73.   

FORM b_opcaoh
    WITH ROW 8 CENTERED OVERLAY WIDTH 76 TITLE COLOR NORMAL " Historico " 
    FRAME f_historico.
/***********************************/

/*** Frame Detalhar Vencimento ***/
DEF FRAME f_modalidade_venc
    tt-venmodal.vencimen VIEW-AS EDITOR SIZE 72 BY 13.5 BUFFER-LINES 16 NO-LABEL
    HELP "Pressione SETA P/ BAIXO ou SETA P/ CIMA para visualizar os venc"
    SKIP(2)
    WITH NO-LABEL OVERLAY ROW 7 COLUMN 3 WIDTH 76 TITLE COLOR NORMAL " Vencimentos ".

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
    aux_qtopcoes = 2.

    IF KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT" THEN
    DO:
        aux_iddopcao = aux_iddopcao + 1.

        IF aux_iddopcao > aux_qtopcoes THEN
           aux_iddopcao = 1.
        
        CHOOSE FIELD aux_dsdopcao[aux_iddopcao] PAUSE 0
            WITH FRAME f_opcoes.
    END.
    ELSE
    IF KEYFUNCTION(LASTKEY) = "CURSOR-LEFT" THEN
    DO: 
        aux_iddopcao = aux_iddopcao - 1.
 
        IF aux_iddopcao < 1 THEN
           aux_iddopcao = aux_qtopcoes.

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
            FOR EACH crapvop NO-LOCK
               WHERE crapvop.nrcpfcgc             = tt-contas.nrcpfcgc  
                 AND crapvop.dtrefere            >= aux_dtrefere
                 AND SUBSTR(crapvop.cdmodali,1,2) = tt-modalidade.cdmodali
            BREAK BY crapvop.cdmodali:

                IF FIRST-OF(crapvop.cdmodali) THEN
                DO:
                    CREATE tt-detmodal.
                    ASSIGN tt-detmodal.cdmodali = crapvop.cdmodali 
                           tt-detmodal.vlvencto = crapvop.vlvencto.
                    
                    FOR FIRST gnsbmod NO-LOCK
                        WHERE gnsbmod.cdmodali = SUBSTR(crapvop.cdmodali,1,2)
                          AND gnsbmod.cdsubmod = SUBSTR(crapvop.cdmodali,3,2):
                        tt-detmodal.dssubmod = gnsbmod.dssubmod.
                    END.
                END.
                ELSE
                    tt-detmodal.vlvencto = tt-detmodal.vlvencto + crapvop.vlvencto.
            END.

            IF CAN-FIND(FIRST tt-detmodal) THEN
            DO:
                HIDE FRAME f_opcoes.

                OPEN QUERY q_detmodal FOR EACH tt-detmodal.

                DISPLAY tt-modalidade.cdmodali 
                        tt-modalidade.dsmodali
                    WITH FRAME f_modalidade_det.
    
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    UPDATE b_detmodal WITH FRAME f_modalidade_det.
                    LEAVE.
                END.
            END.

            IF CAN-FIND(FIRST tt-detmodal) THEN
                EMPTY TEMP-TABLE tt-detmodal.
        END.

        /*** Acionar a opcao Detalhar Vencimento ***/
        WHEN 2 THEN
        DO:
            IF CAN-FIND(FIRST tt-modalidade) THEN
            DO: 
                HIDE FRAME f_opcoes.
                RUN mostra_vencimento (INPUT tt-modalidade.cdmodali).
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
    
    RUN mostra_vencimento (INPUT tt-detmodal.cdmodali).
    
END.
/************************************************************/

ON ANY-PRINTABLE OF tel_vlvencto
DO: 
    IF CAN-DO("0,1,2,3,4,5,6,7,8,9,-",KEYLABEL(LASTKEY)) THEN
        RETURN NO-APPLY.
END.

/********** Mostrar o vencimento de cada fluxo **********/
ON ENTER OF tel_vlvencto[1] 
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 1:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[2]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 2:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[3]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 3:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[4]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 4:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[5]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 5:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[6]         
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 6:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[7]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 7:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[8]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 8:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[9]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 9:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[10]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 10:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[11]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 11:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[12]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 12:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[13]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 13:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[14]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 14:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[15]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 15:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[16]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 16:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[17]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 17:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[18]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 18:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[19]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 19:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[20]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 20:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[21]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 21:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[22]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 22:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[23]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 23:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
    END.
END.

ON ENTER OF tel_vlvencto[24]
DO:
    FOR FIRST tt-fluxo
        WHERE tt-fluxo.elemento = 24:

        RUN mostra_vencimento_fluxo(INPUT tt-fluxo.cdvencto).
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
            RUN mostra_dados.
            ASSIGN aux_flgdelog = TRUE.
            RUN gera_log.
       END.
   ELSE 
   IF  glb_cddopcao = "F" THEN
   DO:
       RUN mostra_fluxo.
       RUN solicita_impressao.
       HIDE FRAME f_fluxo.
   END.
   ELSE    
   IF  glb_cddopcao = "R" THEN /** Impressao **/
       APPLY "GO".
   ELSE
   IF glb_cddopcao = "M" THEN /* Modalidades */
       RUN mostra_modalidade.
   ELSE
   IF glb_cddopcao = "H" THEN /* Historico */
   DO:
       RUN mostra_historico.
   END.
END.

/** Seleciona consulta por Conta/dv **/
ON RETURN OF b_contas_cpf DO:

   IF  glb_cddopcao = "C" THEN   /** Consulta **/
       DO:  
           PAUSE 0 NO-MESSAGE. 
           RUN mostra_dados. 
           ASSIGN aux_flgdelog = TRUE.
           RUN gera_log.
       END.
   ELSE
   IF  glb_cddopcao = "F" THEN   /** Fluxo **/
   DO:
       RUN mostra_fluxo. 
       RUN solicita_impressao.
       HIDE FRAME f_fluxo.
   END.
   ELSE                    
   IF  glb_cddopcao = "R" THEN   /** Impressao **/
       APPLY "GO".    
   ELSE
   IF  glb_cddopcao = "M" THEN /* Modalidades */
       RUN mostra_modalidade.
   ELSE
   IF glb_cddopcao = "H" THEN /* Historico */
       RUN mostra_historico.
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
                  LEAVE.
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
        
    /*** Faz critica para as opcoes "C" e "F" 
         quando tipo de consulta for 3 (Por PA) ***/ 
    IF  glb_cddopcao = "C" OR
        glb_cddopcao = "F" THEN 
        DO:          
            IF  tel_tpconsul = 3 THEN
                DO:
                    glb_cdcritic = 14.
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic.
                    BELL.               
                    glb_cdcritic = 0.   
                    NEXT.
                END.
        END.  

    RUN verifica_data_base. 
    
    PAUSE 0. 
    
    IF  tel_tpconsul = 1 THEN        /**CPF/CNPJ**/
        DO:  
             UPDATE  tel_nrcpfcgc
                     WITH FRAME f_consulta_cpf. 
             
             /***** VALIDA CPF *******/
             IF  tel_nrcpfcgc > 0   THEN
                 DO:  
                      glb_nrcalcul = tel_nrcpfcgc.
                      
                      RUN fontes/cpfcgc.p.
                      
                      IF   NOT glb_stsnrcal   THEN
                           DO:
                               glb_cdcritic = 27.
                               RUN fontes/critic.p.
                               MESSAGE glb_dscritic.
                               BELL.               
                               glb_cdcritic = 0.   
                               NEXT.
                           END.
                 END.
                                
             RUN mostra_contas.

             /** Verifica se existe CPF/CNPJ **/
             IF  aux_regexist = FALSE THEN 
                 DO:
                      glb_cdcritic = 780.
                      RUN fontes/critic.p.
                      MESSAGE glb_dscritic.
                      BELL.               
                      glb_cdcritic = 0.   
                      NEXT.                  
                 END. 
        END.
    ELSE                  
    IF  tel_tpconsul = 2 THEN   /**Conta**/
        DO: 
            UPDATE tel_nrdconta WITH FRAME f_consulta_conta.

            FIND  crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                crapass.nrdconta = tel_nrdconta AND
                                crapass.dtdemiss = ? 
                                NO-LOCK NO-ERROR.
            
            IF  NOT AVAIL crapass THEN
                DO:
                   glb_cdcritic = 064.
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   BELL.
                   glb_cdcritic = 0.
                   NEXT.                
                END.
                        
            RUN mostra_contas.
        END.      
        
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
                    
                    FIND crapage WHERE    crapage.cdcooper = glb_cdcooper AND
                                          crapage.cdagenci = tel_cdagenci AND
                                         (crapage.insitage = 1 OR /* Ativo */
                                          crapage.insitage = 3)   /* Temporariamente Indisponivel */
                                          NO-LOCK NO-ERROR.
                                       
                    IF  NOT AVAIL crapage THEN
                        DO:
                             glb_cdcritic = 856.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             NEXT.
                        END.
                END.                                                   
                                             
                RUN fontes/conscr_r.p (INPUT aux_nrcpfcgc, 
                                       INPUT aux_nrdconta,  
                                       INPUT tel_cdagenci).
        END.  

    IF  NOT aux_flgdelog THEN
        RUN gera_log.
END.
                         
PROCEDURE mostra_contas:

    IF  tel_tpconsul = 1 THEN    /** CPF/CNPJ **/
        DO: /** Pessoa Fisica **/             
            FOR EACH crapttl WHERE  crapttl.cdcooper = glb_cdcooper         AND
                                    crapttl.nrcpfcgc = tel_nrcpfcgc:
                    
                FIND crapass WHERE  crapass.cdcooper = glb_cdcooper         AND
                                    crapass.nrdconta = crapttl.nrdconta     AND
                                    crapass.dtdemiss = ?  NO-LOCK NO-ERROR.
                    
                IF  AVAIL crapass THEN
                    DO:                
                        FIND craptip WHERE  craptip.cdcooper = glb_cdcooper AND
                                            craptip.cdtipcta = crapass.cdtipcta
                                            NO-LOCK NO-ERROR.

                        IF   AVAIL craptip THEN     
                            DO:                    
                                CREATE  tt-contas.
                                ASSIGN  tt-contas.nrdconta = crapttl.nrdconta
                                        tt-contas.cdagenci = crapass.cdagenci
                                        tt-contas.nmprimtl = crapttl.nmextttl
                                        tt-contas.tpdconta = craptip.dstipcta
                                        tt-contas.idseqttl = crapttl.idseqttl
                                        tt-contas.nrcpfcgc = crapttl.nrcpfcgc
                                        aux_regexist       = TRUE
                                        aux_contador = aux_contador + 1.
                            END.
                        ELSE   
                            DO:
                                  glb_cdcritic = 17.
                                  RUN fontes/critic.p.
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  NEXT.
                            END.
                    END.                                                   
            END.
            
            /*** Pessoa Juridica ***/
            FOR EACH crapass WHERE  crapass.cdcooper = glb_cdcooper     AND
                                    crapass.nrcpfcgc = tel_nrcpfcgc     AND
                                    crapass.inpessoa = 2                AND
                                    crapass.dtdemiss = ? NO-LOCK: 
            
                FIND craptip WHERE  craptip.cdcooper = glb_cdcooper     AND
                                    craptip.cdtipcta = crapass.cdtipcta
                                    NO-LOCK NO-ERROR.

                IF  AVAIL craptip THEN
                    DO:                    
                          CREATE  tt-contas.
                          ASSIGN  tt-contas.nrdconta = crapass.nrdconta
                                  tt-contas.cdagenci = crapass.cdagenci
                                  tt-contas.nmprimtl = crapass.nmprimtl
                                  tt-contas.tpdconta = craptip.dstipcta
                                  tt-contas.nrcpfcgc = crapass.nrcpfcgc
                                  tt-contas.idseqttl = 1 
                                  aux_regexist       = TRUE
                                  aux_contador       = aux_contador + 1.
                    END.
                ELSE   
                    DO: 
                        glb_cdcritic = 17.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.    
            END.
            
            IF  aux_regexist = FALSE THEN
                NEXT.
        
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
                            RUN mostra_dados.       
                        
                            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                DISPLAY  b_contas WITH FRAME f_contas. 
                                LEAVE.                     
                            END.             
                       END.
                   ELSE 
                   IF  glb_cddopcao = "F" THEN  
                   DO:
                       RUN mostra_fluxo.
                       RUN solicita_impressao.
                       HIDE FRAME f_fluxo.
                   END.
                   ELSE
                   IF glb_cddopcao = "M" THEN
                       RUN mostra_modalidade.
                   ELSE
                   IF glb_cddopcao = "H" THEN 
                       RUN mostra_historico.
                END.
        END.
    ELSE
    IF  tel_tpconsul = 2 THEN    /** Conta **/
        DO:        
            FOR EACH crapttl WHERE  crapttl.cdcooper = glb_cdcooper and
                                    crapttl.nrdconta = tel_nrdconta:

                 FIND craptip WHERE  craptip.cdcooper = glb_cdcooper AND
                                     craptip.cdtipcta = crapass.cdtipcta
                                     NO-LOCK NO-ERROR.

                 IF  AVAIL craptip THEN
                     DO:                    
                         CREATE tt-contas.
                         ASSIGN tt-contas.nrdconta = crapttl.nrdconta
                                tt-contas.cdagenci = crapass.cdagenci
                                tt-contas.nmprimtl = crapttl.nmextttl
                                tt-contas.tpdconta = craptip.dstipcta
                                tt-contas.idseqttl = crapttl.idseqttl
                                tt-contas.nrcpfcgc = crapttl.nrcpfcgc
                                aux_contador = aux_contador + 1. 
                     END.
                 ELSE   
                     DO: 
                        glb_cdcritic = 17.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                     END.    
            END.
            
            /*** Pessoa Juridica ***/
            FOR EACH crapass WHERE  crapass.cdcooper = glb_cdcooper     AND
                                    crapass.nrdconta = tel_nrdconta     AND
                                    crapass.inpessoa = 2                AND
                                    crapass.dtdemiss = ?            NO-LOCK:
                
                FIND craptip WHERE  craptip.cdcooper = glb_cdcooper AND
                                    craptip.cdtipcta = crapass.cdtipcta
                                    NO-LOCK NO-ERROR.

                IF  AVAIL craptip THEN
                    DO:                    
                          CREATE  tt-contas.
                          ASSIGN  tt-contas.nrdconta = crapass.nrdconta
                                  tt-contas.cdagenci = crapass.cdagenci
                                  tt-contas.nmprimtl = crapass.nmprimtl
                                  tt-contas.tpdconta = craptip.dstipcta
                                  tt-contas.nrcpfcgc = crapass.nrcpfcgc
                                  tt-contas.idseqttl = 1. 
                                  
                          ASSIGN aux_contador = aux_contador + 1. 
                    END.
                ELSE   
                    DO: 
                        glb_cdcritic = 17.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.   
            END.       
             
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
                            RUN mostra_dados.       
                        
                            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                DISPLAY b_contas_cpf WITH FRAME f_contas_cpf.
                                LEAVE.                     
                            END.                                     
                        END.
                    ELSE    
                    IF  glb_cddopcao = "F" THEN  
                    DO:
                        RUN mostra_fluxo.
                        RUN solicita_impressao.
                        HIDE FRAME f_fluxo.
                    END.
                    ELSE
                    IF glb_cddopcao = "M" THEN
                        RUN mostra_modalidade.
                    ELSE
                    IF glb_cddopcao = "H" THEN 
                        RUN mostra_historico.
                END.
        END.        /** Fim tel_tpconsul = 2 **/
END.

PROCEDURE verifica_data_base:
    
    /** Tabela crapopf nao possui cdcooper **/
    FIND LAST crapopf USE-INDEX crapopf2 NO-LOCK NO-ERROR.

    IF  AVAIL crapopf THEN
        ASSIGN aux_dtrefere = crapopf.dtrefere.                
           
    CASE (MONTH(aux_dtrefere)):    
        WHEN 1 THEN         
            ASSIGN tel_dtrefere = "Jan/"+ STRING(YEAR(aux_dtrefere)).           
        WHEN 2 THEN         
            ASSIGN tel_dtrefere = "Fev/"+ STRING(YEAR(aux_dtrefere)).          
        WHEN 3 THEN         
            ASSIGN tel_dtrefere = "Mar/"+ STRING(YEAR(aux_dtrefere)).          
        WHEN 4 THEN         
            ASSIGN tel_dtrefere = "Abr/"+ STRING(YEAR(aux_dtrefere)).        
        WHEN 5 THEN         
            ASSIGN tel_dtrefere = "Mai/"+ STRING(YEAR(aux_dtrefere)).       
        WHEN 6 THEN         
            ASSIGN tel_dtrefere = "Jun/"+ STRING(YEAR(aux_dtrefere)).        
        WHEN 7 THEN         
            ASSIGN tel_dtrefere = "Jul/"+ STRING(YEAR(aux_dtrefere)).
        WHEN 8 THEN         
            ASSIGN tel_dtrefere = "Ago/"+ STRING(YEAR(aux_dtrefere)).    
        WHEN 9 THEN         
            ASSIGN tel_dtrefere = "Set/"+ STRING(YEAR(aux_dtrefere)).    
        WHEN 10 THEN         
            ASSIGN tel_dtrefere = "Out/"+ STRING(YEAR(aux_dtrefere)).    
        WHEN 11 THEN         
            ASSIGN tel_dtrefere = "Nov/"+ STRING(YEAR(aux_dtrefere)).          
        WHEN 12 THEN         
            ASSIGN tel_dtrefere = "Dez/"+ STRING(YEAR(aux_dtrefere)).    
    END CASE.    
    
END PROCEDURE.

PROCEDURE limpa_campos.

    ASSIGN  tel_nrcpfcgc = 0
            aux_nrcpfcgc = 0 
            tel_nrdconta = 0 
            aux_dtrefere = ?
            tel_dtrefere = ""
            tel_vlopesfn = 0
            tel_vlopevnc = 0
            tel_vlopeprj = 0
            tel_vlopcoop = 0
            tel_vlopbase = 0
            tel_cdagenci = 0            
            aux_contador = 0
            tel_qtopesfn = 0
            tel_qtifssfn = 0
            aux_regexist = FALSE
            aux_flgdelog = FALSE. 

    EMPTY TEMP-TABLE tt-contas.  
    EMPTY TEMP-TABLE tt-modalidade.
    EMPTY TEMP-TABLE tt-detmodal.
    EMPTY TEMP-TABLE tt-historico.
    EMPTY TEMP-TABLE tt-ordenada.
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
END.

PROCEDURE mostra_dados:

    DEF VAR aux_dtultdma AS DATE NO-UNDO.
     
    /** Necessario verificar data base novamente no caso do usuario 
        consultar mais contas ou cpf's sem sair do browser **/
    RUN verifica_data_base. 
            
    /** crapopf nao possui cdcooper **/         
    FIND LAST crapopf WHERE crapopf.nrcpfcgc  = tt-contas.nrcpfcgc   AND
                            crapopf.dtrefere >= aux_dtrefere
                            NO-LOCK NO-ERROR.           
    
    IF  NOT AVAIL(crapopf) THEN        
        DO:

            FIND crapces WHERE crapces.nrcpfcgc  = tt-contas.nrcpfcgc AND
                               crapces.dtrefere  = aux_dtrefere       
                               NO-LOCK NO-ERROR.
                               
            IF  NOT AVAIL(crapces) THEN
                DO:
                    MESSAGE "Informacoes do BACEN deste CPF/CNPJ " +
                            "nao estao disponiveis.".
                END.               

        END.
        
    IF  AVAIL crapopf THEN
        DO:               
             ASSIGN tel_qtopesfn = crapopf.qtopesfn
                    tel_qtifssfn = crapopf.qtifssfn.
            
             FOR EACH crapvop  WHERE  
                               crapvop.nrcpfcgc = tt-contas.nrcpfcgc AND
                               crapvop.dtrefere = crapopf.dtrefere
                               NO-LOCK:
                    
                 ASSIGN tel_vlopesfn = tel_vlopesfn + crapvop.vlvencto.
                      
                 /** Operacoes vencidas **/
                 IF  crapvop.cdvencto >= 205 AND
                     crapvop.cdvencto <= 290 THEN
                     ASSIGN tel_vlopevnc = tel_vlopevnc + crapvop.vlvencto.

                 /** Operacoes em Prejuizo **/
                 IF  crapvop.cdvencto >= 310 AND
                     crapvop.cdvencto <= 330 THEN
                     ASSIGN tel_vlopeprj = tel_vlopeprj + crapvop.vlvencto.
             END.
             
             ASSIGN aux_dtrefere = crapopf.dtrefere.       
             
             /*** Operacoes Coop. Data Base ***/
             FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper         AND
                                    crapris.nrcpfcgc = tt-contas.nrcpfcgc   AND
                                    crapris.nrdconta = tt-contas.nrdconta   AND
                                    crapris.dtrefere = aux_dtrefere         AND
                                    crapris.inddocto = 1            
                                    USE-INDEX crapris1  NO-LOCK:
                                    
                 ASSIGN  tel_vlopbase = tel_vlopbase + crapris.vldivida.
                 
             END.
             
        END. 

    /* Ultimo dia do mes passado */
    ASSIGN aux_dtultdma = glb_dtmvtolt - DAY(glb_dtmvtolt).

    FIND LAST crapris WHERE crapris.cdcooper = glb_cdcooper AND
                            crapris.inddocto = 1            AND 
                            crapris.dtrefere <= aux_dtultdma 
                            NO-LOCK NO-ERROR.
    
    IF  AVAIL crapris THEN                                 
        ASSIGN aux_dtrefere = crapris.dtrefere.
                 
    FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper       AND
                           crapris.nrcpfcgc = tt-contas.nrcpfcgc AND
                           crapris.dtrefere = aux_dtrefere       AND
                           crapris.nrdconta = tt-contas.nrdconta AND
                           crapris.inddocto = 1 
                           USE-INDEX crapris1 NO-LOCK:
                                    
        ASSIGN  tel_vlopcoop = tel_vlopcoop + crapris.vldivida.
    END.                   

    ASSIGN tel_dtrefere2 = tel_dtrefere. 

    DISPLAY  tel_dtrefere
             tel_qtopesfn 
             tel_qtifssfn 
             tel_vlopesfn
             tel_vlopevnc
             tel_vlopeprj
             tel_vlopcoop
             aux_dtrefere 
             tel_vlopbase
             tel_dtrefere2 
             WITH FRAME f_dados.
    
    ASSIGN    tel_qtopesfn = 0
              tel_qtifssfn = 0
              tel_vlopesfn = 0
              tel_vlopevnc = 0
              tel_vlopeprj = 0
              tel_vlopcoop = 0
              tel_vlopbase = 0.
             
END PROCEDURE.

PROCEDURE gera_log:

    IF  glb_cddopcao = "C" THEN
        DO:
             UNIX SILENT VALUE("echo " +    STRING(glb_dtmvtolt,"99/99/9999") + 
                               " - " + STRING(TIME,"HH:MM:SS") +
                               " - CONSULTA ' --> '"  +
                               " Operador: " + glb_cdoperad +
                               " consultou CPF_CNPJ: " +
                               STRING(tt-contas.nrcpfcgc, "zzzzzzzzzzzzzz9") +
                               " Conta: " + 
                               STRING(tt-contas.nrdconta, "zzzz,zz9,9") +
                               " >> log/conscr.log").
        END.
    ELSE 
        IF  glb_cddopcao = "R" THEN
            DO:
                IF  tel_cdagenci = 0  THEN
                    UNIX SILENT VALUE("echo " +  
                               STRING(glb_dtmvtolt,"99/99/9999") + 
                               " - " + STRING(TIME,"HH:MM:SS") +
                               " - IMPRESSAO ' --> '"  +
                               " Operador: " + glb_cdoperad +
                               " imprimiu CPF_CNPJ: " +
                               STRING(tt-contas.nrcpfcgc, "zzzzzzzzzzzzzz9") +
                               " Conta: " + 
                               STRING(aux_nrdconta, "zzzz,zz9,9") +
                               " >> log/conscr.log").
                ELSE
                    UNIX SILENT VALUE("echo " +    
                               STRING(glb_dtmvtolt,"99/99/9999") + 
                               " - " + STRING(TIME,"HH:MM:SS") +
                               " - IMPRESSAO ' --> '"  +
                               " Operador: " + glb_cdoperad +
                               " imprimiu PA: " +
                               STRING(tel_cdagenci, "zz9") +
                               " Cooperativa: " + 
                               STRING(glb_cdcooper, "zz9") +
                               " >> log/conscr.log").
            END.

END PROCEDURE.

PROCEDURE mostra_fluxo:

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        PAUSE 0 NO-MESSAGE.
    
        ASSIGN tel_vlvencto = 0. 

        /** Necessario verificar data base novamente no caso do usuario 
            consultar mais contas ou cpf's sem sair do browser **/
        RUN verifica_data_base. 
        
        /** crapopf nao possui cdcooper **/         
        FIND LAST crapopf NO-LOCK
            WHERE crapopf.nrcpfcgc  = tt-contas.nrcpfcgc   
              AND crapopf.dtrefere >= aux_dtrefere NO-ERROR.           
              
        IF  NOT AVAIL(crapopf) THEN
            DO:
                FIND crapces WHERE crapces.nrcpfcgc  = tt-contas.nrcpfcgc AND
                                   crapces.dtrefere  = aux_dtrefere
                                   NO-LOCK NO-ERROR.
                                                              
                IF  NOT AVAIL(crapces) THEN
                    DO:
                        MESSAGE "Informacoes do BACEN deste CPF/CNPJ " +
                                "nao estao disponiveis.".
                    END.
                                            
            END.              
              
        IF AVAIL crapopf THEN
        DO:  
            FOR EACH crapvop NO-LOCK 
               WHERE crapvop.nrcpfcgc = tt-contas.nrcpfcgc 
                 AND crapvop.dtrefere = crapopf.dtrefere:

                CREATE tt-fluxo.
                ASSIGN tt-fluxo.cdvencto = crapvop.cdvencto.

                CASE crapvop.cdvencto:
                     WHEN 110 THEN
                          ASSIGN tel_vlvencto[1]   = tel_vlvencto[1] + crapvop.vlvencto
                                 tt-fluxo.elemento = 1.
                     WHEN 120 THEN
                          ASSIGN tel_vlvencto[2]   = tel_vlvencto[2] + crapvop.vlvencto
                                 tt-fluxo.elemento = 2.
                     WHEN 130 THEN
                          ASSIGN tel_vlvencto[3]   = tel_vlvencto[3] + crapvop.vlvencto
                                 tt-fluxo.elemento = 3.
                     WHEN 140 THEN
                          ASSIGN tel_vlvencto[4]   = tel_vlvencto[4] + crapvop.vlvencto
                                 tt-fluxo.elemento = 4.
                     WHEN 150 THEN
                          ASSIGN tel_vlvencto[5]   = tel_vlvencto[5] + crapvop.vlvencto
                                 tt-fluxo.elemento = 5.
                     WHEN 160 THEN
                          ASSIGN tel_vlvencto[6]   = tel_vlvencto[6] + crapvop.vlvencto
                                 tt-fluxo.elemento = 6.
                     WHEN 165 THEN
                          ASSIGN tel_vlvencto[7]   = tel_vlvencto[7] + crapvop.vlvencto
                                 tt-fluxo.elemento = 7.
                     WHEN 170 THEN
                          ASSIGN tel_vlvencto[8]   = tel_vlvencto[8] + crapvop.vlvencto
                                 tt-fluxo.elemento = 8.
                     WHEN 175 THEN
                          ASSIGN tel_vlvencto[9]   = tel_vlvencto[9] + crapvop.vlvencto 
                                 tt-fluxo.elemento = 9.
                     WHEN 180 THEN
                          ASSIGN tel_vlvencto[10]  = tel_vlvencto[10] + crapvop.vlvencto
                                 tt-fluxo.elemento = 10.
                     WHEN 190 THEN
                          ASSIGN tel_vlvencto[11]  = tel_vlvencto[11] + crapvop.vlvencto
                                 tt-fluxo.elemento = 11.
                     WHEN 199 THEN
                          ASSIGN tel_vlvencto[12]  = tel_vlvencto[12] + crapvop.vlvencto
                                 tt-fluxo.elemento = 12.
                     WHEN 205 THEN
                          ASSIGN tel_vlvencto[13]  = tel_vlvencto[13] + crapvop.vlvencto
                                 tt-fluxo.elemento = 13.
                     WHEN 210 THEN
                          ASSIGN tel_vlvencto[14]  = tel_vlvencto[14] + crapvop.vlvencto
                                 tt-fluxo.elemento = 14.
                     WHEN 220 THEN
                          ASSIGN tel_vlvencto[15]  = tel_vlvencto[15] + crapvop.vlvencto
                                 tt-fluxo.elemento = 15.
                     WHEN 230 THEN
                          ASSIGN tel_vlvencto[16]  = tel_vlvencto[16] + crapvop.vlvencto
                                 tt-fluxo.elemento = 16.
                     WHEN 240 THEN
                          ASSIGN tel_vlvencto[17]  = tel_vlvencto[17] + crapvop.vlvencto
                                 tt-fluxo.elemento = 17.
                     WHEN 245 THEN
                          ASSIGN tel_vlvencto[18]  = tel_vlvencto[18] + crapvop.vlvencto
                                 tt-fluxo.elemento = 18.
                     WHEN 250 THEN
                          ASSIGN tel_vlvencto[19]  = tel_vlvencto[19] + crapvop.vlvencto
                                 tt-fluxo.elemento = 19.
                     WHEN 255 THEN
                          ASSIGN tel_vlvencto[20]  = tel_vlvencto[20] + crapvop.vlvencto
                                 tt-fluxo.elemento = 20.
                     WHEN 260 THEN
                          ASSIGN tel_vlvencto[21]  = tel_vlvencto[21] + crapvop.vlvencto
                                 tt-fluxo.elemento = 21.
                     WHEN 270 THEN
                          ASSIGN tel_vlvencto[22]  = tel_vlvencto[22] + crapvop.vlvencto
                                 tt-fluxo.elemento = 22.
                     WHEN 280 THEN
                          ASSIGN tel_vlvencto[23]  = tel_vlvencto[23] + crapvop.vlvencto
                                 tt-fluxo.elemento = 23.
                     WHEN 290 THEN
                          ASSIGN tel_vlvencto[24]  = tel_vlvencto[24] + crapvop.vlvencto
                                 tt-fluxo.elemento = 24.
                END CASE.
            END.
            
            ASSIGN aux_dtrefere = crapopf.dtrefere. 

        END. /** Fim avail crapopf **/

        RUN verifica_help.

        UPDATE tel_vlvencto WITH FRAME f_fluxo.

    END.

END PROCEDURE.

PROCEDURE mostra_modalidade:

    PAUSE 0 NO-MESSAGE.

    /** Necessario verificar data base novamente no caso do usuario 
        consultar mais contas ou cpf's sem sair do browser **/
    RUN verifica_data_base.
    
    FIND LAST crapopf 
        WHERE crapopf.nrcpfcgc  = tt-contas.nrcpfcgc   
          AND crapopf.dtrefere >= aux_dtrefere NO-LOCK NO-ERROR. 
          
    IF  NOT AVAIL(crapopf) THEN
        DO:
            FIND crapces WHERE crapces.nrcpfcgc  = tt-contas.nrcpfcgc AND
                               crapces.dtrefere  = aux_dtrefere
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL(crapces) THEN
                DO:
                    MESSAGE "Informacoes do BACEN deste CPF/CNPJ " +
                             "nao estao disponiveis.".
                END.
                                                    
        END.          
          
    IF AVAIL crapopf THEN
    DO: 
        aux_reganter = "".
    
        FOR EACH crapvop NO-LOCK
           WHERE crapvop.nrcpfcgc  = tt-contas.nrcpfcgc  
             AND crapvop.dtrefere >= aux_dtrefere:
    
            IF NOT aux_reganter = SUBSTR(crapvop.cdmodali,1,2) THEN
            DO:
                CREATE tt-modalidade.
                ASSIGN tt-modalidade.cdmodali = SUBSTR(crapvop.cdmodali,1,2)
                       tt-modalidade.vlvencto = tt-modalidade.vlvencto + crapvop.vlvencto.

                FOR LAST gnmodal FIELDS(dsmodali) NO-LOCK
                   WHERE gnmodal.cdmodali = SUBSTR(crapvop.cdmodali,1,2):
                    tt-modalidade.dsmodali = gnmodal.dsmodali.
                END.
            END.
            ELSE
                tt-modalidade.vlvencto = tt-modalidade.vlvencto + crapvop.vlvencto.
    
            aux_reganter = SUBSTR(crapvop.cdmodali,1,2).
        END.
    
    END.
    
    /* Mostrar o browse */
    IF CAN-FIND(FIRST tt-modalidade) THEN
    DO:
        aux_iddopcao = 1.

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

END PROCEDURE.

PROCEDURE mostra_vencimento:

    DEF INPUT PARAM p_cdmodali AS CHAR FORMAT "x(04)" NO-UNDO.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        /** Necessario verificar data base novamente no caso do usuario 
            consultar mais contas ou cpf's sem sair do browser **/
        RUN verifica_data_base. 

        FIND LAST crapopf NO-LOCK
            WHERE crapopf.nrcpfcgc             = tt-contas.nrcpfcgc   
              AND crapopf.dtrefere            >= aux_dtrefere NO-ERROR.           
        IF AVAIL crapopf THEN
        DO:
            IF LENGTH(p_cdmodali) = 2 THEN
            DO:
                FOR EACH crapvop NO-LOCK
                   WHERE crapvop.nrcpfcgc             = crapopf.nrcpfcgc 
                     AND crapvop.dtrefere             = crapopf.dtrefere
                     AND SUBSTR(crapvop.cdmodali,1,2) = p_cdmodali:
                    
                    IF NOT CAN-FIND(FIRST tt-venmodal
                                    WHERE tt-venmodal.cdmodali = SUBSTR(crapvop.cdmodali,1,2)) THEN
                    DO:
                        CREATE tt-venmodal.
                        ASSIGN tt-venmodal.cdmodali = p_cdmodali.

                        FOR LAST gnmodal FIELDS(dsmodali) NO-LOCK
                           WHERE gnmodal.cdmodali = SUBSTR(crapvop.cdmodali,1,2):
                            tt-venmodal.dsmodali = gnmodal.dsmodali.
                        END.
                    END.

                    IF CAN-FIND(FIRST tt-venmodal) THEN
                    DO:
                        CASE crapvop.cdvencto:
                            WHEN 110 THEN
                                ASSIGN tt-venmodal.vlvencto[1] = tt-venmodal.vlvencto[1] + crapvop.vlvencto.
                            WHEN 120 THEN
                                ASSIGN tt-venmodal.vlvencto[2] = tt-venmodal.vlvencto[2] + crapvop.vlvencto.
                            WHEN 130 THEN
                                ASSIGN tt-venmodal.vlvencto[3] = tt-venmodal.vlvencto[3] + crapvop.vlvencto.
                            WHEN 140 THEN
                                ASSIGN tt-venmodal.vlvencto[4] = tt-venmodal.vlvencto[4] + crapvop.vlvencto.
                            WHEN 150 THEN
                                ASSIGN tt-venmodal.vlvencto[5] = tt-venmodal.vlvencto[5] + crapvop.vlvencto.
                            WHEN 160 THEN
                                ASSIGN tt-venmodal.vlvencto[6] = tt-venmodal.vlvencto[6] + crapvop.vlvencto.
                            WHEN 165 THEN
                                ASSIGN tt-venmodal.vlvencto[7] = tt-venmodal.vlvencto[7] + crapvop.vlvencto.
                            WHEN 170 THEN
                                ASSIGN tt-venmodal.vlvencto[8] = tt-venmodal.vlvencto[8] + crapvop.vlvencto.
                            WHEN 175 THEN
                                ASSIGN tt-venmodal.vlvencto[9] = tt-venmodal.vlvencto[9] + crapvop.vlvencto.
                            WHEN 180 THEN
                                ASSIGN tt-venmodal.vlvencto[10] = tt-venmodal.vlvencto[10] + crapvop.vlvencto.
                            WHEN 190 THEN
                                ASSIGN tt-venmodal.vlvencto[11] = tt-venmodal.vlvencto[11] + crapvop.vlvencto.
                            WHEN 199 THEN
                                ASSIGN tt-venmodal.vlvencto[12] = tt-venmodal.vlvencto[12] + crapvop.vlvencto.
                            WHEN 205 THEN
                                ASSIGN tt-venmodal.vlvencto[13] = tt-venmodal.vlvencto[13] + crapvop.vlvencto.
                            WHEN 210 THEN
                                ASSIGN tt-venmodal.vlvencto[14] = tt-venmodal.vlvencto[14] + crapvop.vlvencto.
                            WHEN 220 THEN
                                ASSIGN tt-venmodal.vlvencto[15] = tt-venmodal.vlvencto[15] + crapvop.vlvencto.
                            WHEN 230 THEN
                                ASSIGN tt-venmodal.vlvencto[16] = tt-venmodal.vlvencto[16] + crapvop.vlvencto.
                            WHEN 240 THEN
                                ASSIGN tt-venmodal.vlvencto[17] = tt-venmodal.vlvencto[17] + crapvop.vlvencto.
                            WHEN 245 THEN
                                ASSIGN tt-venmodal.vlvencto[18] = tt-venmodal.vlvencto[18] + crapvop.vlvencto.
                            WHEN 250 THEN
                                ASSIGN tt-venmodal.vlvencto[19] = tt-venmodal.vlvencto[19] + crapvop.vlvencto.
                            WHEN 255 THEN
                                ASSIGN tt-venmodal.vlvencto[20] = tt-venmodal.vlvencto[20] + crapvop.vlvencto.
                            WHEN 260 THEN
                                ASSIGN tt-venmodal.vlvencto[21] = tt-venmodal.vlvencto[21] + crapvop.vlvencto.
                            WHEN 270 THEN
                                ASSIGN tt-venmodal.vlvencto[22] = tt-venmodal.vlvencto[22] + crapvop.vlvencto.
                            WHEN 280 THEN
                                ASSIGN tt-venmodal.vlvencto[23] = tt-venmodal.vlvencto[23] + crapvop.vlvencto.
                            WHEN 290 THEN
                                ASSIGN tt-venmodal.vlvencto[24] = tt-venmodal.vlvencto[24] + crapvop.vlvencto.
                        END CASE.
    
                        ASSIGN tt-venmodal.vencimen = ""                                                        + CHR(10) +
                               "Modalidade Principal: " + tt-venmodal.cdmodali + " - " + tt-venmodal.dsmodali   + CHR(10) +  
                               ""                                                                               + CHR(10) +
                               "A VENCER                    VALOR      VENCIDOS                  VALOR"         + CHR(10) +  
                               "Ate 30 dias        "      +   string(tt-venmodal.vlvencto[1],"zzz,zzz,zz9.99")  +        
                               "      de 1 a 14 dias   " +   string(tt-venmodal.vlvencto[13],"zzz,zzz,zz9.99")  + CHR(10) +  
                               "de 31 a 60 dias    "      +   string(tt-venmodal.vlvencto[2],"zzz,zzz,zz9.99")  +
                               "      de 15 a 30 dias  " +   string(tt-venmodal.vlvencto[14],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 61 a 90 dias    "      +   string(tt-venmodal.vlvencto[3],"zzz,zzz,zz9.99")  +
                               "      de 31 a 60 dias  " +   string(tt-venmodal.vlvencto[15],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 91 a 180 dias   "      +   string(tt-venmodal.vlvencto[4],"zzz,zzz,zz9.99")  +
                               "      de 61 a 90 dias  " +   string(tt-venmodal.vlvencto[16],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 181 a 360 dias  "      +   string(tt-venmodal.vlvencto[5],"zzz,zzz,zz9.99")  +
                               "      de 91 a 120 dias " +   string(tt-venmodal.vlvencto[17],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 361 a 720 dias  "      +   string(tt-venmodal.vlvencto[6],"zzz,zzz,zz9.99")  +
                               "      de 121 a 150 dias" +   string(tt-venmodal.vlvencto[18],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 721 a 1080 dias "      +   string(tt-venmodal.vlvencto[7],"zzz,zzz,zz9.99")  +
                               "      de 151 a 180 dias" +   string(tt-venmodal.vlvencto[19],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 1081 a 1440 dias"      +   string(tt-venmodal.vlvencto[8],"zzz,zzz,zz9.99")  +
                               "      de 181 a 240 dias" +   string(tt-venmodal.vlvencto[20],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 1441 a 1800 dias"      +   string(tt-venmodal.vlvencto[9],"zzz,zzz,zz9.99")  +
                               "      de 241 a 300 dias" +   string(tt-venmodal.vlvencto[21],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 1801 a 5400 dias"      +   string(tt-venmodal.vlvencto[10],"zzz,zzz,zz9.99") +
                               "      de 301 a 360 dias" +   string(tt-venmodal.vlvencto[22],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "acima de 5400 dias "      +   string(tt-venmodal.vlvencto[11],"zzz,zzz,zz9.99") +
                               "      de 361 a 540 dias" +   string(tt-venmodal.vlvencto[23],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "com prazo indeterm."      +   string(tt-venmodal.vlvencto[12],"zzz,zzz,zz9.99") +
                               "      acima de 540 dias" +   string(tt-venmodal.vlvencto[24],"zzz,zzz,zz9.99"). 
                    END.
                END.
            END.
            ELSE
            DO:
                FOR EACH crapvop NO-LOCK
                   WHERE crapvop.nrcpfcgc = crapopf.nrcpfcgc 
                     AND crapvop.dtrefere = crapopf.dtrefere
                     AND crapvop.cdmodali = p_cdmodali:
                    
                    IF NOT CAN-FIND(FIRST tt-venmodal
                                    WHERE tt-venmodal.cdmodali = crapvop.cdmodali) THEN
                    DO:
                        CREATE tt-venmodal.
                        ASSIGN tt-venmodal.cdmodali = p_cdmodali.

                        FOR FIRST gnsbmod FIELDS(dssubmod) NO-LOCK
                            WHERE gnsbmod.cdmodali = SUBSTR(crapvop.cdmodali,1,2)
                              AND gnsbmod.cdsubmod = SUBSTR(crapvop.cdmodali,3,2):
                            tt-venmodal.dsmodali = gnsbmod.dssubmod.
                        END.
                    END.

                    IF CAN-FIND(FIRST tt-venmodal) THEN
                    DO:
                        CASE crapvop.cdvencto:
                            WHEN 110 THEN
                                ASSIGN tt-venmodal.vlvencto[1] = tt-venmodal.vlvencto[1] + crapvop.vlvencto.
                            WHEN 120 THEN
                                ASSIGN tt-venmodal.vlvencto[2] = tt-venmodal.vlvencto[2] + crapvop.vlvencto.
                            WHEN 130 THEN
                                ASSIGN tt-venmodal.vlvencto[3] = tt-venmodal.vlvencto[3] + crapvop.vlvencto.
                            WHEN 140 THEN
                                ASSIGN tt-venmodal.vlvencto[4] = tt-venmodal.vlvencto[4] + crapvop.vlvencto.
                            WHEN 150 THEN
                                ASSIGN tt-venmodal.vlvencto[5] = tt-venmodal.vlvencto[5] + crapvop.vlvencto.
                            WHEN 160 THEN
                                ASSIGN tt-venmodal.vlvencto[6] = tt-venmodal.vlvencto[6] + crapvop.vlvencto.
                            WHEN 165 THEN
                                ASSIGN tt-venmodal.vlvencto[7] = tt-venmodal.vlvencto[7] + crapvop.vlvencto.
                            WHEN 170 THEN
                                ASSIGN tt-venmodal.vlvencto[8] = tt-venmodal.vlvencto[8] + crapvop.vlvencto.
                            WHEN 175 THEN
                                ASSIGN tt-venmodal.vlvencto[9] = tt-venmodal.vlvencto[9] + crapvop.vlvencto.
                            WHEN 180 THEN
                                ASSIGN tt-venmodal.vlvencto[10] = tt-venmodal.vlvencto[10] + crapvop.vlvencto.
                            WHEN 190 THEN
                                ASSIGN tt-venmodal.vlvencto[11] = tt-venmodal.vlvencto[11] + crapvop.vlvencto.
                            WHEN 199 THEN
                                ASSIGN tt-venmodal.vlvencto[12] = tt-venmodal.vlvencto[12] + crapvop.vlvencto.
                            WHEN 205 THEN
                                ASSIGN tt-venmodal.vlvencto[13] = tt-venmodal.vlvencto[13] + crapvop.vlvencto.
                            WHEN 210 THEN
                                ASSIGN tt-venmodal.vlvencto[14] = tt-venmodal.vlvencto[14] + crapvop.vlvencto.
                            WHEN 220 THEN
                                ASSIGN tt-venmodal.vlvencto[15] = tt-venmodal.vlvencto[15] + crapvop.vlvencto.
                            WHEN 230 THEN
                                ASSIGN tt-venmodal.vlvencto[16] = tt-venmodal.vlvencto[16] + crapvop.vlvencto.
                            WHEN 240 THEN
                                ASSIGN tt-venmodal.vlvencto[17] = tt-venmodal.vlvencto[17] + crapvop.vlvencto.
                            WHEN 245 THEN
                                ASSIGN tt-venmodal.vlvencto[18] = tt-venmodal.vlvencto[18] + crapvop.vlvencto.
                            WHEN 250 THEN
                                ASSIGN tt-venmodal.vlvencto[19] = tt-venmodal.vlvencto[19] + crapvop.vlvencto.
                            WHEN 255 THEN
                                ASSIGN tt-venmodal.vlvencto[20] = tt-venmodal.vlvencto[20] + crapvop.vlvencto.
                            WHEN 260 THEN
                                ASSIGN tt-venmodal.vlvencto[21] = tt-venmodal.vlvencto[21] + crapvop.vlvencto.
                            WHEN 270 THEN
                                ASSIGN tt-venmodal.vlvencto[22] = tt-venmodal.vlvencto[22] + crapvop.vlvencto.
                            WHEN 280 THEN
                                ASSIGN tt-venmodal.vlvencto[23] = tt-venmodal.vlvencto[23] + crapvop.vlvencto.
                            WHEN 290 THEN
                                ASSIGN tt-venmodal.vlvencto[24] = tt-venmodal.vlvencto[24] + crapvop.vlvencto.
                        END CASE.
    
                        ASSIGN tt-venmodal.vencimen = ""                                                        + CHR(10) +
                               "Modalidade Principal: " + tt-venmodal.cdmodali + " - " + tt-venmodal.dsmodali   + CHR(10) +  
                               ""                                                                               + CHR(10) +
                               "A VENCER                    VALOR      VENCIDOS                  VALOR"         + CHR(10) +  
                               "Ate 30 dias        "      +   string(tt-venmodal.vlvencto[1],"zzz,zzz,zz9.99")  +        
                               "      de 1 a 14 dias   " +   string(tt-venmodal.vlvencto[13],"zzz,zzz,zz9.99")  + CHR(10) +  
                               "de 31 a 60 dias    "      +   string(tt-venmodal.vlvencto[2],"zzz,zzz,zz9.99")  +
                               "      de 15 a 30 dias  " +   string(tt-venmodal.vlvencto[14],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 61 a 90 dias    "      +   string(tt-venmodal.vlvencto[3],"zzz,zzz,zz9.99")  +
                               "      de 31 a 60 dias  " +   string(tt-venmodal.vlvencto[15],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 91 a 180 dias   "      +   string(tt-venmodal.vlvencto[4],"zzz,zzz,zz9.99")  +
                               "      de 61 a 90 dias  " +   string(tt-venmodal.vlvencto[16],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 181 a 360 dias  "      +   string(tt-venmodal.vlvencto[5],"zzz,zzz,zz9.99")  +
                               "      de 91 a 120 dias " +   string(tt-venmodal.vlvencto[17],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 361 a 720 dias  "      +   string(tt-venmodal.vlvencto[6],"zzz,zzz,zz9.99")  +
                               "      de 121 a 150 dias" +   string(tt-venmodal.vlvencto[18],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 721 a 1080 dias "      +   string(tt-venmodal.vlvencto[7],"zzz,zzz,zz9.99")  +
                               "      de 151 a 180 dias" +   string(tt-venmodal.vlvencto[19],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 1081 a 1440 dias"      +   string(tt-venmodal.vlvencto[8],"zzz,zzz,zz9.99")  +
                               "      de 181 a 240 dias" +   string(tt-venmodal.vlvencto[20],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 1441 a 1800 dias"      +   string(tt-venmodal.vlvencto[9],"zzz,zzz,zz9.99")  +
                               "      de 241 a 300 dias" +   string(tt-venmodal.vlvencto[21],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "de 1801 a 5400 dias"      +   string(tt-venmodal.vlvencto[10],"zzz,zzz,zz9.99") +
                               "      de 301 a 360 dias" +   string(tt-venmodal.vlvencto[22],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "acima de 5400 dias "      +   string(tt-venmodal.vlvencto[11],"zzz,zzz,zz9.99") +
                               "      de 361 a 540 dias" +   string(tt-venmodal.vlvencto[23],"zzz,zzz,zz9.99")  + CHR(10) + 
                               "com prazo indeterm."      +   string(tt-venmodal.vlvencto[12],"zzz,zzz,zz9.99") +
                               "      acima de 540 dias" +   string(tt-venmodal.vlvencto[24],"zzz,zzz,zz9.99"). 
                    END.
                END.
            END.
            
            ASSIGN aux_dtrefere = crapopf.dtrefere.       
            
        END. /** Fim avail crapopf **/
        ELSE      
            MESSAGE "Informacoes do BACEN deste CPF/CNPJ nao estao disponiveis.".

        FOR EACH tt-venmodal:

            UPDATE tt-venmodal.vencimen WITH FRAME f_modalidade_venc.
        END.

        HIDE FRAME f_modalidade_venc.
        HIDE FRAME f_opcoes.
        
        IF CAN-FIND(FIRST tt-venmodal) THEN
            EMPTY TEMP-TABLE tt-venmodal.

        LEAVE.
    END.

END PROCEDURE.

PROCEDURE mostra_historico:

    DEF VAR aux_vlvencto LIKE crapvop.vlvencto NO-UNDO.
    DEF VAR aux_dtmesref AS INT                NO-UNDO.
    DEF VAR aux_dtanoref AS INT                NO-UNDO.
    DEF VAR aux_dtmesfim AS DATE               NO-UNDO.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 

        RUN verifica_data_base. 

        ASSIGN aux_dtmesref = MONTH(aux_dtrefere)
               aux_dtanoref =  YEAR(aux_dtrefere). 

        DO aux_contador = 1 TO 8:

            /************ ENCONTRA O ÚLTIMO DIA DE CADA MÊS ************/
            ASSIGN aux_dtmesfim = DATE(aux_dtmesref,01,aux_dtanoref) + 32        
                   aux_dtmesfim = aux_dtmesfim - DAY(aux_dtmesfim).  

            FIND LAST crapopf NO-LOCK
                 WHERE crapopf.nrcpfcgc = tt-contas.nrcpfcgc
                   AND crapopf.dtrefere = aux_dtmesfim NO-ERROR.
                   
            IF  NOT AVAIL(crapopf) THEN
                DO:
                    FIND crapces 
                         WHERE crapces.nrcpfcgc  = tt-contas.nrcpfcgc AND
                               crapces.dtrefere  = aux_dtmesfim
                               NO-LOCK NO-ERROR.

                IF  NOT AVAIL(crapces) THEN
                    DO:
                        RUN verifica_data_historico(INPUT aux_dtmesfim).
                                    
                        CREATE tt-historico.
                        ASSIGN tt-historico.dtrefere = aux_dtrefsum
                               tt-historico.vlvencto = 0
                               tt-historico.dsdbacen = "Informacoes do BACEN "                                                      + "nao estao disponiveis"
                               tt-historico.dtcomple = aux_dtmesfim.                    
                    END.
                ELSE
                    DO:
                        RUN verifica_data_historico(INPUT crapces.dtrefere).
                        
                        CREATE tt-historico.
                        ASSIGN tt-historico.dtrefere = aux_dtrefsum
                               tt-historico.vlvencto = 0
                               tt-historico.dsdbacen = ""
                               tt-historico.dtcomple = crapces.dtrefere.
                    END.
                                                    
            END.
            ELSE       
            DO:
                IF AVAIL crapopf THEN
                DO:
                    ASSIGN aux_vlvencto = 0
                           aux_dtrefsum = "".
    
                    FOR EACH crapvop NO-LOCK
                      WHERE crapvop.nrcpfcgc = crapopf.nrcpfcgc
                        AND crapvop.dtrefere = crapopf.dtrefere:
    
                        aux_vlvencto = aux_vlvencto + crapvop.vlvencto.
                    END.
    
                    RUN verifica_data_historico(INPUT crapopf.dtrefere).
    
                    CREATE tt-historico.
                    ASSIGN tt-historico.dtrefere = aux_dtrefsum
                           tt-historico.vlvencto = aux_vlvencto
                           tt-historico.dsdbacen = ""
                           tt-historico.dtcomple = crapopf.dtrefere.
                END.    
            END.
            IF aux_dtmesref = 1 THEN
                ASSIGN aux_dtmesref = 12
                       aux_dtanoref = aux_dtanoref - 1.  
            ELSE
                ASSIGN aux_dtmesref = aux_dtmesref - 1.
        END.

        FOR EACH tt-historico
            BREAK BY tt-historico.dtcomple DESC:

            CREATE tt-ordenada.
            ASSIGN tt-ordenada.dtrefere = tt-historico.dtrefere  
                   tt-ordenada.vlvencto = tt-historico.vlvencto  
                   tt-ordenada.dsdbacen = tt-historico.dsdbacen.  
        END.

        HIDE FRAME f_modalidade.
        HIDE FRAME f_opcoes.
        HIDE FRAME f_modalidade_det.

        OPEN QUERY q_opcaoh FOR EACH tt-ordenada.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            UPDATE b_opcaoh WITH FRAME f_historico.
            LEAVE.
        END.

        IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            HIDE FRAME f_historico.

        IF CAN-FIND(FIRST tt-historico) THEN
            EMPTY TEMP-TABLE tt-historico.

        IF CAN-FIND(FIRST tt-ordenada) THEN
            EMPTY TEMP-TABLE tt-ordenada.

        LEAVE.
    END.

END PROCEDURE.

PROCEDURE verifica_data_historico:   

    DEF INPUT PARAM p_dtrefere LIKE crapopf.dtrefere NO-UNDO. 
           
    CASE (MONTH(p_dtrefere)):    
        WHEN 1 THEN         
            ASSIGN aux_dtrefsum = "Jan/"+ STRING(YEAR(p_dtrefere)).           
        WHEN 2 THEN         
            ASSIGN aux_dtrefsum = "Fev/"+ STRING(YEAR(p_dtrefere)).          
        WHEN 3 THEN         
            ASSIGN aux_dtrefsum = "Mar/"+ STRING(YEAR(p_dtrefere)).          
        WHEN 4 THEN         
            ASSIGN aux_dtrefsum = "Abr/"+ STRING(YEAR(p_dtrefere)).        
        WHEN 5 THEN         
            ASSIGN aux_dtrefsum = "Mai/"+ STRING(YEAR(p_dtrefere)).       
        WHEN 6 THEN         
            ASSIGN aux_dtrefsum = "Jun/"+ STRING(YEAR(p_dtrefere)).        
        WHEN 7 THEN         
            ASSIGN aux_dtrefsum = "Jul/"+ STRING(YEAR(p_dtrefere)).
        WHEN 8 THEN         
            ASSIGN aux_dtrefsum = "Ago/"+ STRING(YEAR(p_dtrefere)).    
        WHEN 9 THEN         
            ASSIGN aux_dtrefsum = "Set/"+ STRING(YEAR(p_dtrefere)).    
        WHEN 10 THEN         
            ASSIGN aux_dtrefsum = "Out/"+ STRING(YEAR(p_dtrefere)).    
        WHEN 11 THEN         
            ASSIGN aux_dtrefsum = "Nov/"+ STRING(YEAR(p_dtrefere)).          
        WHEN 12 THEN         
            ASSIGN aux_dtrefsum = "Dez/"+ STRING(YEAR(p_dtrefere)).    
    END CASE.    
    
END PROCEDURE.

PROCEDURE mostra_vencimento_fluxo:

    DEF INPUT PARAM p_cdvencto LIKE crapvop.vlvencto NO-UNDO.
    
    DEF VAR aux_vlvencto LIKE crapvop.vlvencto NO-UNDO.

    aux_vlvencto = 0.

    FOR EACH crapvop  
       WHERE crapvop.nrcpfcgc = tt-contas.nrcpfcgc 
         AND crapvop.dtrefere = crapopf.dtrefere 
         AND crapvop.cdvencto = p_cdvencto NO-LOCK
         BREAK BY SUBSTRING(crapvop.cdmodali,1,2):

        aux_vlvencto = aux_vlvencto + crapvop.vlvencto.

        IF LAST-OF(SUBSTRING(crapvop.cdmodali,1,2)) THEN
        DO:
            CREATE tt-venc-fluxo.
            ASSIGN tt-venc-fluxo.cdmodali = SUBSTRING(crapvop.cdmodali,1,2)
                   tt-venc-fluxo.vlvencto = aux_vlvencto
                   aux_vlvencto           = 0.

            FIND FIRST gnmodal NO-LOCK
                 WHERE gnmodal.cdmodali = SUBSTRING(crapvop.cdmodali,1,2) NO-ERROR.
            IF AVAIL gnmodal THEN
                tt-venc-fluxo.dsmodali = gnmodal.dsmodali.
        END.
    END.

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

END PROCEDURE.

PROCEDURE solicita_impressao:

    VIEW FRAME f_fluxo.

    READKEY.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
    DO:
        MESSAGE "Deseja imprimir?(S/N)" UPDATE aux_confirma .
        HIDE FRAME f_fluxo.

        IF  aux_confirma = TRUE THEN
        DO:
            ASSIGN  glb_cdcritic    = 0
                    glb_nrdevias    = 1
                    glb_cdempres    = 11
                    glb_nmformul    = "80col"
                    glb_cdrelato[1] = 569
                    par_flgrodar = TRUE.

            INPUT THROUGH basename `tty` NO-ECHO.
            SET aux_nmendter WITH FRAME f_terminal.
            INPUT CLOSE.
            
            aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                  aux_nmendter.

            UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

            ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

            { includes/cabrel080_1.i }

            VIEW STREAM str_1 FRAME f_cabrel080_1.

            DISPLAY STREAM str_1  tt-contas.nrcpfcgc
                                  tt-contas.nmprimtl
                                  tt-contas.nrdconta
                                  tel_dtrefere
                                  WITH FRAME f_fluxo_cab.

            DISPLAY STREAM str_1 tel_vlvencto WITH FRAME f_fluxo.

            OUTPUT STREAM str_1 CLOSE.

            /*** Necessario para a impressao ***/
            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

            { includes/impressao.i }
        END.

        LEAVE.
    END.

END PROCEDURE.
