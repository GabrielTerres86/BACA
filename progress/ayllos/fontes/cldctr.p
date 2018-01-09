/*.............................................................................

   Programa: Fontes/cldctr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : ADRIANO
   Data    : JUNHO/2011                          Ultima Atualizacao: 22/07/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Analise de movimentacao X renda.
   
   Alteracoes: 20/07/2011 - Alterado format do campo tt-creditos.ultrenda
                            para inteiro (Adriano).
   
               19/09/2011 - Incluidas as opcoes P e T (Henrique).
   
               10/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               03/12/2013 - Inclusao de VALIDATE crapfld (Carlos)

               17/12/2014 - Remover filtro crapass.cdagenci na carrega-creditos
                            quando pesquisar da crapcld. A informaçao da agencia 
                            deve ser carregado com a o valor que está na 
                            crapcld.cdagenci (Douglas - Chamado 143945)

               26/05/2015 - Adicionar na opçao "P" o campo de controle que filtra
                            se a listagem deve apresentar os fechamentos
                            diários ou mensais (Douglas - Chamado 282637)
              
               22/07/2015 - Ajustar o format do campo e a geraçao do arquivo para
                            gerar com extensao ".csv" (Douglas - Chamado 310866)   
               
               05/12/2017 - Melhoria 458 ajuste para pegar parametros da tabela 
                            tbcc_monitoramento_parametos - Antonio R. Jr(Mouts)
..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1. 
    
/* ............................... TEMP-TABLES ............................... */
DEF TEMP-TABLE tt-creditos NO-UNDO
    FIELD cdcooper LIKE glb_cdcooper
    FIELD nrdconta LIKE crapcld.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD inpessoa AS CHAR             
    FIELD vlrendim LIKE crapcld.vlrendim 
                                         FORMAT "zzz,zzz,zz9.99"
    FIELD vltotcre LIKE crapcld.vltotcre 
                                         FORMAT "zzz,zzz,zz9.99"
    FIELD cddjusti LIKE crapcld.cddjusti
    FIELD dsdjusti AS CHAR               FORMAT "x(40)"
    FIELD nmresage AS CHAR
    FIELD ultrenda AS INT                FORMAT "zzz,zzz,zz9"
    FIELD dsstatus AS CHAR               FORMAT "x(10)"
    FIELD opeenvcf LIKE crapcld.opeenvcf
    FIELD cdoperad LIKE crapcld.cdoperad
    FIELD dsobserv LIKE crapcld.dsobserv
    FIELD dsobsctr LIKE crapcld.dsobsctr
    FIELD infrepcf AS CHAR.
    
DEF TEMP-TABLE tt-atividade NO-UNDO
    FIELD cdcooper LIKE crapcld.cdcooper COLUMN-LABEL "COOP"
    FIELD nrdconta LIKE crapcld.nrdconta
    FIELD dtmvtolt LIKE crapcld.dtmvtolt
    FIELD tpvincul LIKE crapass.tpvincul 
    FIELD cdagenci LIKE crapass.cdagenci 
    FIELD vlrendim LIKE crapcld.vlrendim COLUMN-LABEL "Rendimento" 
                                         FORMAT "zzzzz,zz9.99"
    FIELD vltotcre LIKE crapcld.vltotcre COLUMN-LABEL "Credito"  
    FIELD qtultren AS   INT              COLUMN-LABEL "Credito/Renda"
    FIELD cddjusti LIKE crapcld.cddjusti 
    FIELD dsdjusti LIKE crapcld.dsdjusti 
    FIELD infrepcf AS   CHAR             COLUMN-LABEL "COAF"
    FIELD dsobserv LIKE crapcld.dsobserv
    FIELD dsobsctr LIKE crapcld.dsobsctr
    FIELD dsstatus AS   CHAR             COLUMN-LABEL "Status".

DEF TEMP-TABLE tt-pesquisa NO-UNDO
    FIELD cdcooper LIKE crapcld.cdcooper COLUMN-LABEL "COOP"
    FIELD cdagenci AS   INTE             COLUMN-LABEL "PA"
    FIELD nrdconta LIKE crapcld.nrdconta
    FIELD dtmvtolt LIKE crapcld.dtmvtolt
    FIELD vlrendim LIKE crapcld.vlrendim COLUMN-LABEL "Rendimento"   
                                         FORMAT "zzzz,zzz,zz9.99"
    FIELD vltotcre LIKE crapcld.vltotcre COLUMN-LABEL "Credito"      
                                         FORMAT "zzzz,zzz,zz9.99"
    FIELD qtultren AS   INT              COLUMN-LABEL "Cred/Renda"
                                         FORMAT "zz,zzz,zz9"
    FIELD dsstatus AS   CHAR             COLUMN-LABEL "Status"
    FIELD dsdjusti LIKE crapcld.dsdjusti
    FIELD infrepcf AS   CHAR             COLUMN-LABEL "COAF".


DEF TEMP-TABLE tt-fchmto NO-UNDO
    FIELD nmrescop AS CHAR               FORMAT "x(18)"
    FIELD dtmvtolt LIKE crapcld.dtmvtolt
    FIELD operador LIKE glb_cdoperad. 
    

/* ............................. QUERYS/BROWSES .............................. */
DEF QUERY q-creditos   FOR tt-creditos.
DEF QUERY q-fechamento FOR tt-fchmto.
DEF QUERY q-pesquisa   FOR tt-pesquisa.
DEF QUERY q-atividade  FOR tt-atividade.

DEF BROWSE b-creditos QUERY q-creditos
    DISP tt-creditos.cdcooper COLUMN-LABEL "Coop"
         tt-creditos.nrdconta COLUMN-LABEL "Conta"         
         tt-creditos.vlrendim COLUMN-LABEL "Rendimento"    
         tt-creditos.vltotcre COLUMN-LABEL "Credito"
         tt-creditos.ultrenda COLUMN-LABEL "Credito/Renda" SPACE (1)
         tt-creditos.dsstatus COLUMN-LABEL "Status"
         WITH 05 DOWN NO-BOX.

DEF BROWSE b-fechamento QUERY q-fechamento
     DISP tt-fchmto.nmrescop COLUMN-LABEL "Cooperativa"
          tt-fchmto.dtmvtolt COLUMN-LABEL "Data Fechamento"
          tt-fchmto.operador COLUMN-LABEL "Ope" 
          WITH 06 DOWN WIDTH 49 NO-BOX.

DEF BROWSE b-pesquisa QUERY q-pesquisa
    DISP tt-pesquisa.cdcooper FORMAT "z9"                COLUMN-LABEL "Coop" 
         tt-pesquisa.cdagenci FORMAT "zz9"
         tt-pesquisa.dtmvtolt FORMAT "99/99/9999"
         tt-pesquisa.nrdconta
         tt-pesquisa.vlrendim FORMAT "zzzz,zzz,zz9.99"
         tt-pesquisa.vltotcre FORMAT "zzzz,zzz,zz9.99"
         tt-pesquisa.qtultren FORMAT "zz,zzz,zz9"         
         WITH 06 DOWN NO-BOX.

DEF BROWSE b-atividade QUERY q-atividade
    DISP tt-atividade.cdcooper FORMAT "z9"               COLUMN-LABEL "Coop" 
         tt-atividade.cdagenci FORMAT "zz9"
         tt-atividade.dtmvtolt FORMAT "99/99/9999"
         tt-atividade.nrdconta
         tt-atividade.vlrendim FORMAT "zzzz,zz9.99"
         tt-atividade.vltotcre FORMAT "zzzz,zzz,zz9.99"
         tt-atividade.qtultren FORMAT "zzz,zzz,zz9"
         WITH 06 DOWN NO-BOX.

/* ................................ VARIAVEIS ................................ */
DEF VAR aux_nmresage AS CHAR                                        NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                        NO-UNDO.
DEF VAR aux_linhalog AS CHAR                                        NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "(!)"                           NO-UNDO.
DEF VAR aux_dsstatus AS CHAR FORMAT "x(10)"                         NO-UNDO.
DEF VAR aux_dtfecham AS DATE                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR aux_contcoop AS INTE                                        NO-UNDO.
DEF VAR aux_fldexist AS LOG                                         NO-UNDO.
DEF VAR aux_flgerror AS LOG                                         NO-UNDO.
DEF VAR aux_cldexist AS LOG                                         NO-UNDO.
DEF VAR aux_fldgrava AS LOG                                         NO-UNDO.

DEF VAR tel_tpoperac AS CHAR                                        NO-UNDO.
DEF VAR tel_tpdsaida AS CHAR FORMAT "!"                             NO-UNDO.
DEF VAR tel_inpessoa AS CHAR FORMAT "x(10)"                         NO-UNDO.
DEF VAR tel_infrepcf AS CHAR FORMAT "x(14)"                         NO-UNDO.
DEF VAR tel_nmresage AS CHAR FORMAT "x(15)"                         NO-UNDO.
DEF VAR tel_dsdjusti AS CHAR FORMAT "x(60)"                         NO-UNDO.
DEF VAR tel_cdcooper AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX
                     INNER-LINES 11 NO-UNDO.
DEF VAR tel_dtrefini AS DATE                                        NO-UNDO.
DEF VAR tel_dtreffim AS DATE                                        NO-UNDO.
DEF VAR tel_dtmvtolt AS DATE FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR tel_vldirfis AS DECI FORMAT "zz,zzz,zz9.99"                 NO-UNDO.
DEF VAR tel_vldirjur AS DECI FORMAT "zz,zzz,zz9.99"                 NO-UNDO.
DEF VAR tel_cdstatus AS INTE FORMAT "9"                             NO-UNDO.
DEF VAR tel_cdincoaf AS INTE FORMAT "9"                             NO-UNDO.
DEF VAR tel_cdtipcld AS INTE FORMAT "9"                             NO-UNDO.
DEF VAR tel_cddjusti LIKE crapcld.cddjusti                          NO-UNDO.
DEF VAR tel_dsobserv LIKE crapcld.dsobserv 							NO-UNDO.
DEF VAR tel_dsobsctr LIKE crapcld.dsobsctr                          NO-UNDO.
DEF VAR tel_cdoperad LIKE crapcld.cdoperad                          NO-UNDO.
DEF VAR tel_opeenvcf LIKE crapcld.opeenvcf                          NO-UNDO.
DEF VAR tel_nrdconta LIKE crapass.nrdconta                          NO-UNDO.
DEF VAR tel_nmprimtl LIKE crapass.nmprimtl FORMAT "x(40)"           NO-UNDO.

/* Variaveis para a include cabrel132_1.i */
DEF   VAR rel_nmempres   AS CHAR  FORMAT "x(15)"                     NO-UNDO.
DEF   VAR rel_nmrelato   AS CHAR  FORMAT "x(40)" EXTENT 5            NO-UNDO.
DEF   VAR rel_nrmodulo   AS INT   FORMAT "9"                         NO-UNDO.
DEF   VAR rel_nmmodulo   AS CHAR  FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

/* Variaveis para impressao */
DEF VAR aux_nmarquiv    AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqimp    AS CHAR                                     NO-UNDO.
DEF VAR aux_dscaminh    AS CHAR                                     NO-UNDO.
DEF VAR aux_nmendter    AS CHAR                                     NO-UNDO.
DEF VAR aux_dscomand    AS CHAR                                     NO-UNDO.
DEF VAR tel_dsimprim    AS CHAR    FORMAT "x(08)" INIT "Imprimir"   NO-UNDO.
DEF VAR tel_dscancel    AS CHAR    FORMAT "x(08)" INIT "Cancelar"   NO-UNDO.
DEF VAR aux_flgescra    AS LOGICAL                                  NO-UNDO.
DEF VAR par_flgfirst    AS LOGICAL                                  NO-UNDO.
DEF VAR par_flgrodar    AS LOGICAL                                  NO-UNDO.
DEF VAR par_flgcance    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_textocom    AS CHAR    FORMAT "x(1000)"                 NO-UNDO.
DEF VAR aux_textodis    AS CHAR    FORMAT "x(60)"                   NO-UNDO.

    
/* ............................... FORMULARIOS ............................... */
FORM aux_dscaminh FORMAT "x(15)"
     aux_nmarquiv FORMAT "x(20)"
     WITH NO-LABEL OVERLAY ROW 12 CENTERED FRAME f_arquivo.

FORM "Coop"             AT 01
     "PA"               AT 07
     "Data"             AT 16
     "Conta/DV"         AT 23
     "Renda"            AT 42
     "Creditos"         AT 55
     "Creditos/Renda"   AT 64
     "Status"           AT 84
     "COAF"             AT 100      
     SKIP
     "----"
     "---"
     "----------"
     "----------"
     "---------------"
     "---------------"
     "--------------"
     "-----------"
     "-------------"
     WITH WIDTH 132 NO-BOX NO-LABEL FRAME f_retorno_tit.

FORM tt-atividade.cdcooper                       FORMAT "zzz9"
     tt-atividade.cdagenci                       FORMAT "zz9"
     tt-atividade.dtmvtolt                       FORMAT "99/99/9999"
     tt-atividade.nrdconta
     tt-atividade.vlrendim
     tt-atividade.vltotcre
     tt-atividade.qtultren   AT 68
     tt-atividade.dsstatus                       FORMAT "x(12)"
     tt-atividade.infrepcf                       FORMAT "x(15)"
     WITH WIDTH 132 DOWN NO-BOX NO-LABEL FRAME f_atividade_retorno.

FORM "     Justificativa:" aux_textodis
     WITH WIDTH 132 DOWN NO-BOX NO-LABEL FRAME f_atividade_justifc.

FORM "        Comp.Justi:" aux_textodis
     WITH WIDTH 132 DOWN NO-BOX NO-LABEL FRAME f_atividade_justifcc.

FORM "      Parecer Sede:" aux_textodis
     WITH WIDTH 132 DOWN NO-BOX NO-LABEL FRAME f_atividade_justifcs.
	 
FORM "                   " aux_textodis
     WITH WIDTH 132 DOWN NO-BOX NO-LABEL FRAME f_atividade_justifi.

FORM "           Vinculo:" tt-atividade.tpvincul
     SKIP(1)
     WITH WIDTH 132 DOWN NO-BOX NO-LABEL FRAME f_atividade_vinculo.

FORM tt-pesquisa.cdcooper                       FORMAT "zzz9"
     tt-pesquisa.cdagenci                       FORMAT "zz9"
     tt-pesquisa.dtmvtolt                       FORMAT "99/99/9999"
     tt-pesquisa.nrdconta
     tt-pesquisa.vlrendim
     tt-pesquisa.vltotcre
     tt-pesquisa.qtultren   AT 68
     tt-pesquisa.dsstatus                       FORMAT "x(12)"
     tt-pesquisa.infrepcf   FORMAT "x(15)"
     WITH WIDTH 132 DOWN NO-BOX NO-LABEL FRAME f_pesquisa_retorno.

FORM "     Justificativa:" aux_textodis
     WITH WIDTH 132 DOWN NO-BOX NO-LABEL FRAME f_pesquisa_justifc.

FORM "                   " aux_textodis
     WITH WIDTH 132 DOWN NO-BOX NO-LABEL FRAME f_pesquisa_justifi.

FORM b-creditos
     WITH ROW 6  OVERLAY CENTERED FRAME f_credito.

FORM b-fechamento
     WITH ROW 8 OVERLAY CENTERED FRAME f_fechamento.

FORM b-atividade
     WITH ROW 7 OVERLAY WIDTH 78 CENTERED FRAME f_atividade.

FORM b-pesquisa
     WITH ROW 8 OVERLAY WIDTH 79 CENTERED FRAME f_pesquisa.

FORM tel_nmprimtl LABEL "Nome" 
     tel_nmresage LABEL "PA"        AT 57
     SKIP
     tel_inpessoa LABEL "Tp.Pessoa" 
     tel_cdoperad LABEL "Ope.PA."   AT 24
     tel_opeenvcf LABEL "Ope.Sede"  AT 57
     SKIP
     "Cd/Just.:"
     tel_cddjusti NO-LABEL 
     tel_dsdjusti NO-LABEL 
     SKIP
     tel_dsobserv LABEL "Comp.Justi"
     SKIP
     tel_infrepcf LABEL "COAF" AT 7
     SKIP 
     tel_dsobsctr LABEL "Parecer Sede"
     WITH OVERLAY ROW 15 COLUMN 2 NO-BOX SIDE-LABELS FRAME f_credito_detalhe.

FORM "      Vinculo:" tt-atividade.tpvincul
     "      COAF:" tt-atividade.infrepcf    FORMAT "x(15)"
     "    Status:" tt-atividade.dsstatus    FORMAT "x(10)"
     SKIP
     "Justificativa:" tt-atividade.cddjusti
     "-"              tt-atividade.dsdjusti FORMAT "x(55)"
     SKIP
     "   Comp.Justi:"tt-atividade.dsobserv  FORMAT "x(55)"
     SKIP
     " Parecer Sede:" tt-atividade.dsobsctr FORMAT "x(55)"
     WITH OVERLAY ROW 17 COLUMN 2 NO-BOX NO-LABEL FRAME f_atividade_detalhe.

FORM SKIP
     "Justificativa:" tt-pesquisa.dsdjusti 
     SKIP
     "         COAF:" tt-pesquisa.infrepcf   FORMAT "x(12)"
                                    HELP "Informar/Nao Informar"
     SKIP
     "       Status:" tt-pesquisa.dsstatus   FORMAT "x(10)"
     WITH OVERLAY ROW 18 COLUMN 2 NO-BOX NO-LABEL FRAME f_pesquisa_detalhe.

FORM SPACE (1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80
     TITLE " Analise de movimentacao X renda" FRAME f_moldura.
    
FORM SKIP
     tel_dtrefini LABEL "Inicial" AUTO-RETURN       AT 03
        HELP "Informe a data inicial"
        VALIDATE (INPUT tel_dtrefini <> ? , 
                  "Data nao informada.")
     tel_dtreffim LABEL "Final" AUTO-RETURN         AT 23
        HELP "Informe a data final"
        VALIDATE (INPUT tel_dtreffim <> ? OR
                  INPUT tel_dtrefini < tel_dtreffim,                  
                  "Data inicial deve ser menor que a final.")
     tel_tpdsaida LABEL "Saida" AUTO-RETURN         AT 42
        HELP "T-TELA,I-IMPRESSORA,A-ARQUIVO"
        VALIDATE (CAN-DO("A,I,T",tel_tpdsaida),"Saida Invalida.")
     WITH ROW 6 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_cldctr_t.

FORM SKIP
     tel_nrdconta LABEL "Conta/DV" AUTO-RETURN      AT 03
     tel_dtrefini LABEL "Inicial"  AUTO-RETURN      AT 24
        HELP "Informe a data inicial"
        VALIDATE (INPUT tel_dtrefini <> ? , 
                  "Data nao informada.")
     tel_dtreffim LABEL "Final" AUTO-RETURN         AT 45
        HELP "Informe a data final"
        VALIDATE (INPUT tel_dtreffim <> ? OR
                  INPUT tel_dtrefini < tel_dtreffim,                  
                  "Data inicial deve ser menor que a final.")
     SKIP 
     tel_cdstatus LABEL "Status" AUTO-RETURN        AT 05
        HELP "1-TODOS,2-EM ANALISE,3-FECHADO"
        VALIDATE (CAN-DO("1,2,3",tel_cdstatus),"Status Invalido.")
     tel_cdincoaf LABEL "COAF" AUTO-RETURN          AT 27
        HELP "1-TODOS,2-JA INFORMADO"
        VALIDATE (CAN-DO("1,2",tel_cdincoaf),"Codigo Invalido.")
     tel_cdtipcld LABEL "Controle" AUTO-RETURN      AT 42
        HELP "1-DIARIO,2-MENSAL"
        VALIDATE (CAN-DO("1,2",tel_cdtipcld),"Controle Invalido.")
     tel_tpdsaida LABEL "Saida" AUTO-RETURN         AT 61
        HELP "T-TELA,I-IMPRESSORA,A-ARQUIVO"
        VALIDATE (CAN-DO("A,I,T",tel_tpdsaida),"Saida Invalida.")
    WITH ROW 6 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_cldctr_p.

FORM SKIP tel_dtmvtolt LABEL "Data"
        HELP "Informe a data desejada"
        VALIDATE (INPUT tel_dtmvtolt <> ?, "Data invalida") 
     WITH ROW 5 COLUMN 64 NO-BOX SIDE-LABELS OVERLAY FRAME f_cldctr.

FORM SKIP 
     glb_cddopcao LABEL "Opcao" AUTO-RETURN
        HELP "(C,F,P,T)"
        VALIDATE (CAN-DO("C,F,P,T",glb_cddopcao),"014 - Opcao Errada.")    AT 3
     tel_tpoperac LABEL "Operacao"                                         AT 14
     tel_cdcooper LABEL "Cooperativa" 
     WITH ROW 5 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_cddopcao.

/* ................................. EVENTOS ................................. */

DEF BUFFER b-crapfld1 FOR crapfld.

ON "ENTRY" OF b-atividade DO:
    APPLY "VALUE-CHANGED" TO b-atividade.
END.

ON "VALUE-CHANGED" OF b-atividade DO:    

    DISP tt-atividade.tpvincul
         tt-atividade.infrepcf
         tt-atividade.dsstatus
         tt-atividade.cddjusti
         tt-atividade.dsdjusti
         tt-atividade.dsobserv          
         tt-atividade.dsobsctr
         WITH FRAME f_atividade_detalhe.

END.

ON "ENTRY" OF b-pesquisa DO:
    APPLY "VALUE-CHANGED" TO b-pesquisa.
END.

ON "VALUE-CHANGED" OF b-pesquisa DO:    

    DISP tt-pesquisa.dsdjusti 
         tt-pesquisa.infrepcf 
         tt-pesquisa.dsstatus
         WITH FRAME f_pesquisa_detalhe.

END.

ON "ENTRY" OF b-creditos DO:
    
    APPLY "VALUE-CHANGED" TO b-creditos.

END.

ON "VALUE-CHANGED" OF b-creditos DO:

    ASSIGN tel_nmprimtl = tt-creditos.nmprimtl
           tel_inpessoa = tt-creditos.inpessoa
           tel_cddjusti = tt-creditos.cddjusti
           tel_dsdjusti = tt-creditos.dsdjusti
           tel_dsobserv = tt-creditos.dsobserv
           tel_dsobsctr = tt-creditos.dsobsctr
           tel_nmresage = tt-creditos.nmresage
           tel_cdoperad = tt-creditos.cdoperad
           tel_opeenvcf = tt-creditos.opeenvcf
           tel_infrepcf = tt-creditos.infrepcf.
           
               
    DISP tel_nmprimtl 
         tel_inpessoa 
         tel_cddjusti 
         tel_dsdjusti   
         tel_dsobserv 
         tel_dsobsctr
         tel_nmresage
         tel_cdoperad
         tel_opeenvcf
         tel_infrepcf
         WITH FRAME f_credito_detalhe.

END.

ON RETURN OF tel_cdcooper DO:

   ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE
          aux_contador = 0.

   APPLY "GO".
END.

FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK BY crapcop.dsdircop:

    IF aux_contcoop = 0 THEN
       ASSIGN aux_nmcooper = "TODAS,0," + CAPS(crapcop.dsdircop) + "," +
                             STRING(crapcop.cdcooper)
              aux_contcoop = 1.
    ELSE
       ASSIGN aux_nmcooper = aux_nmcooper + "," + CAPS(crapcop.dsdircop)
                             + "," + STRING(crapcop.cdcooper).
END.

ASSIGN tel_cdcooper:LIST-ITEM-PAIRS IN FRAME f_cddopcao = aux_nmcooper
       tel_cdcooper = "0".

/* ........................................................................... */

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_cddopcao.
PAUSE(0).

ASSIGN glb_cddopcao = "C"
       tel_tpoperac = "Credito"
       aux_dscaminh = "/micros/cecred/".

DO WHILE TRUE: 

    RUN fontes/inicia.p.

    ASSIGN tel_cdcooper = "0".

    DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
        
        HIDE FRAME f_cldctr_p NO-PAUSE.
        HIDE FRAME f_cldctr_t NO-PAUSE.
        HIDE FRAME f_cldctr   NO-PAUSE.

        UPDATE glb_cddopcao WITH FRAME f_cddopcao.

        { includes/acesso.i }

        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "CLDCTR"  THEN
                DO:
                    HIDE FRAME f_cddopcao.
                    HIDE FRAME f_moldura.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.
    
    IF  glb_cddopcao = "C" THEN
        DO:
            HIDE FRAME f_cldctr_p NO-PAUSE.
            HIDE FRAME f_cldctr_t NO-PAUSE.
            VIEW FRAME f_cldctr.  
        END.
    ELSE
    IF  glb_cddopcao = "F" THEN
        DO:
            HIDE FRAME f_cldctr_p NO-PAUSE.
            HIDE FRAME f_cldctr_t NO-PAUSE.
            VIEW FRAME f_cldctr.
        END.
    ELSE
    IF  glb_cddopcao = "P" THEN
        DO:
            HIDE FRAME f_cldctr   NO-PAUSE.
            HIDE FRAME f_cldctr_t NO-PAUSE.
            VIEW FRAME f_cldctr_p.  
        END.
    ELSE
    IF  glb_cddopcao = "T" THEN
        DO:
            HIDE FRAME f_cldctr   NO-PAUSE.    
            HIDE FRAME f_cldctr_p NO-PAUSE.
            VIEW FRAME f_cldctr_t.  
        END.
        
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:        
        
        DISP tel_tpoperac WITH FRAME f_cddopcao.
          
        DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

            UPDATE tel_cdcooper WITH FRAME f_cddopcao.

            LEAVE.
        END.

        IF  glb_cddopcao = "F" THEN
            DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
                    UPDATE tel_dtmvtolt WITH FRAME f_cldctr.

                    FIND FIRST crapcld WHERE crapcld.dtmvtolt = tel_dtmvtolt 
                                         AND crapcld.cdtipcld = 1
                                         NO-LOCK NO-ERROR.

                    IF  AVAIL crapcld THEN
                        LEAVE.
                    ELSE
                        DO:
                            MESSAGE "Data invalida.".
                            NEXT.
                        END.
                END.
            
                IF  KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                    DO:
                        CLEAR FRAME f_cddopcao NO-PAUSE.
                        LEAVE. 
                    END.

                EMPTY TEMP-TABLE tt-fchmto.

                FOR EACH crapfld WHERE crapfld.dtmvtolt = tel_dtmvtolt      
                                   AND crapfld.cdtipcld = 4 /* DIARIO CENTRAL */
                                   NO-LOCK,
                    FIRST crapcop WHERE crapcop.cdcooper = crapfld.cdcooper
                                        NO-LOCK:

                     CREATE tt-fchmto.
                     ASSIGN tt-fchmto.nmrescop = STRING(crapfld.cdcooper) + 
                                                 " - " + crapcop.nmrescop
                            tt-fchmto.dtmvtolt = crapfld.dtmvtolt
                            tt-fchmto.operador = crapfld.cdoperad.
                END. /* FOR EAHC crapfld */
          
                FIND FIRST tt-fchmto NO-LOCK NO-ERROR.
               
                IF  AVAIL tt-fchmto THEN
                    DO:
                        MESSAGE "Operacao ja realizada para " + 
                                " esta(s) cooperativa(s).".
                 
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            OPEN QUERY q-fechamento FOR EACH tt-fchmto.
                       
                            UPDATE b-fechamento WITH FRAME f_fechamento.
                            LEAVE.
                       
                        END.
                       
                        CLOSE QUERY q-fechamento.
                   
                        HIDE MESSAGE NO-PAUSE.
                        HIDE FRAME f_fechamento NO-PAUSE.
                    END.
                
                IF  KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                    DO: 
                        CLEAR FRAME f_cddopcao NO-PAUSE.
                        LEAVE. 
                    END.

                ASSIGN aux_fldexist = FALSE
                       aux_fldgrava = FALSE
                       aux_cldexist = FALSE
                       aux_flgerror = FALSE.
             
                EMPTY TEMP-TABLE tt-fchmto.

                RUN fontes/confirma.p (INPUT "Confirmar operacao?",
                                       OUTPUT aux_confirma).
            
                IF  aux_confirma = "S" THEN
                    DO TRANSACTION: 
                        IF  INT(tel_cdcooper) <> 0 THEN
                            DO: 
                                FIND b-crapfld1 
                                WHERE b-crapfld1.cdcooper = INT(tel_cdcooper) 
                                  AND b-crapfld1.dtmvtolt = tel_dtmvtolt      
                                  AND b-crapfld1.cdtipcld = 1 /* DIARIO COOP */
                                  NO-LOCK NO-ERROR.

                                IF  NOT AVAIL b-crapfld1 THEN
                                    DO:
                                        MESSAGE "A Cooperativa ainda nao " + 
                                                "efetuou o fechamento.".
                         
                                        PAUSE (2) NO-MESSAGE.
                                        HIDE MESSAGE NO-PAUSE. 
                                        NEXT.
                                    END.
                                ELSE
                                IF  b-crapfld1.dtdenvcf = ? THEN
                                    DO:
                                        MESSAGE "A central ainda nao digitou "
                                                " as informacoes no COAF.".
                         
                                        PAUSE (2) NO-MESSAGE.
                                        HIDE MESSAGE NO-PAUSE. 
                                        NEXT.
                                    END.

                                DO aux_contador = 1 TO 10:
                         
                                    FIND crapfld WHERE 
                                       crapfld.cdcooper = INT(tel_cdcooper) AND
                                       crapfld.dtmvtolt = tel_dtmvtolt      AND
                                       crapfld.cdtipcld = 4 /* DIARIO CENTRAL */
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.                    
                         
                                    IF  NOT AVAIL crapfld THEN
                                        DO:
                                            IF  LOCKED crapfld THEN
                                                DO:
                                                    PAUSE NO-MESSAGE.
                                                    NEXT.
                                                END.
                                            ELSE   
                                                DO:
                                                    aux_fldexist = TRUE.
                                                    LEAVE.
                                                END.
                                        END.
                                END. /* FIM DO aux_contador */
                         
                                IF  aux_fldexist = TRUE THEN
                                    DO:
                                        CREATE crapfld.
                              
                                        ASSIGN crapfld.cdcooper = INT(tel_cdcooper)
                                               crapfld.dtmvtolt = tel_dtmvtolt
                                               crapfld.cdoperad = glb_cdoperad
                                               crapfld.cdtipcld = 4 /* DIARIO CENTRAL */
                                               crapfld.hrtransa = TIME
                                               crapfld.dttransa = TODAY.

                                        VALIDATE crapfld.

                                        FIND crapcop 
                                        WHERE crapcop.cdcooper = INT(tel_cdcooper)
                                        NO-LOCK NO-ERROR.

                                        CREATE tt-fchmto.
                               
                                        ASSIGN tt-fchmto.nmrescop = 
                                                    STRING(INT(tel_cdcooper)) +
                                                    " - " + crapcop.nmrescop
                                               tt-fchmto.dtmvtolt = tel_dtmvtolt
                                               tt-fchmto.operador = glb_cdoperad.
                               
                                        MESSAGE "O fechamento foi realizado " +
                                                "com sucesso.".

                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                            OPEN QUERY q-fechamento 
                                                    FOR EACH tt-fchmto.
                              
                                            UPDATE b-fechamento 
                                                    WITH FRAME f_fechamento.
                                            LEAVE.
                                        END.
                                 
                                        CLOSE QUERY q-fechamento.
                         
                                        HIDE MESSAGE NO-PAUSE.
                                        HIDE FRAME f_fechamento NO-PAUSE.
                                    END.
                                ELSE
                                    DO:
                                        MESSAGE "O fechamento desta operacao " +
                                                "ja foi realizado no dia " + 
                                                STRING(tel_dtmvtolt).
                         
                                        PAUSE (2) NO-MESSAGE.
                                        HIDE MESSAGE NO-PAUSE.
                                    END.   
                            END.
                        ELSE     
                            DO:
                                FOR EACH crapcop WHERE crapcop.cdcooper <> 3 
                                                 NO-LOCK:

                                    FIND FIRST crapcld 
                                    WHERE crapcld.cdcooper = crapcop.cdcooper 
                                      AND crapcld.dtmvtolt = tel_dtmvtolt
                                      NO-LOCK NO-ERROR.

                                    IF  AVAIL crapcld THEN
                                        DO:
                                            aux_cldexist = TRUE.

                                            FIND b-crapfld1 
                                            WHERE b-crapfld1.cdcooper = crapcop.cdcooper 
                                              AND b-crapfld1.dtmvtolt = tel_dtmvtolt     
                                              AND b-crapfld1.cdtipcld = 1 /* DIARIO COOP */
                                              NO-LOCK NO-ERROR.
                                 
                                            IF  NOT AVAIL b-crapfld1 THEN
                                                DO:
                                                    MESSAGE "A Cooperativa " + 
                                                            crapcop.nmrescop + 
                                                            " ainda "        +
                                                            "nao efetuou o " +
                                                            "fechamento.".
                                 
                                                    PAUSE.
                                                    HIDE MESSAGE NO-PAUSE.
                                                        NEXT.
                                                END.
                                            ELSE
                                            IF  b-crapfld1.dtdenvcf = ? THEN
                                                DO:
                                                    MESSAGE "A central ainda"  +
                                                            " nao digitou as " +
                                                            "informacoes no "  +
                                                            " COAF para a "    + 
                                                            crapcop.nmrescop   +
                                                            ".".
                                 
                                                    PAUSE.
                                                    HIDE MESSAGE NO-PAUSE.
                                                    NEXT.
                                                END.
                                 
                                            DO aux_contador = 1 TO 10:
                                                                     
                                                FIND crapfld 
                                                WHERE crapfld.cdcooper = crapcop.cdcooper 
                                                  AND crapfld.dtmvtolt = tel_dtmvtolt     
                                                  AND crapfld.cdtipcld = 4 /* DIARIO CENTRAL */
                                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                               
                                                IF  NOT AVAIL crapfld THEN
                                                    DO:
                                                    IF  LOCKED crapfld THEN
                                                        DO:
                                                            PAUSE NO-MESSAGE.
                                                            NEXT.
                                                        END.
                                                    ELSE   
                                                    DO:
                                                        ASSIGN aux_fldexist = TRUE
                                                               aux_fldgrava = TRUE.
                                                        LEAVE.
                                                    END.
                                                    END.
                                                ELSE
                                                    DO:
                                                        ASSIGN aux_fldgrava = FALSE
                                                               aux_flgerror = TRUE.
                                                    END.
                                            END.
                              
                                            IF  aux_fldgrava = TRUE THEN
                                            DO: 
                                                CREATE crapfld.
                                         
                                                ASSIGN crapfld.cdcooper = crapcop.cdcooper
                                                       crapfld.dtmvtolt = tel_dtmvtolt
                                                       crapfld.cdoperad = glb_cdoperad
                                                       crapfld.cdtipcld = 4 /* DIARIO CENTRAL */
                                                       crapfld.hrtransa = TIME
                                                       crapfld.dttransa = TODAY.
                                                
                                                VALIDATE crapfld.

                                                CREATE tt-fchmto.
                                                
                                                ASSIGN tt-fchmto.nmrescop = 
                                                        STRING(crapcop.cdcooper) 
                                                        + " - " + 
                                                        crapcop.nmrescop
                                                        tt-fchmto.dtmvtolt = 
                                                                tel_dtmvtolt
                                                        tt-fchmto.operador = 
                                                                glb_cdoperad.
                                            END.
                                        END.
                                END.
                       
                                IF  aux_cldexist = FALSE THEN
                                    DO:
                                        MESSAGE "Creditos de lavagem de " + 
                                                "dinheiro nao foram criados.".
                            
                                        PAUSE (2) NO-MESSAGE.
                                        HIDE MESSAGE NO-PAUSE.
                                    END.
                                ELSE
                                IF  aux_fldexist = TRUE THEN
                                    DO:
                                        MESSAGE "O fechamento foi realizado " + 
                                                "com sucesso.".
                         
                                        FIND FIRST tt-fchmto NO-LOCK NO-ERROR.
                         
                                        IF  AVAIL tt-fchmto THEN
                                            DO:
                                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                    OPEN QUERY q-fechamento 
                                                         FOR EACH tt-fchmto.
                              
                                                    UPDATE b-fechamento 
                                                        WITH FRAME f_fechamento.

                                                LEAVE.
                                            END.
                                        END.
                                 
                                        CLOSE QUERY q-fechamento.
                         
                                        HIDE MESSAGE NO-PAUSE.
                                        HIDE FRAME f_fechamento NO-PAUSE.
                                    END.
                                ELSE
                                    DO: 
                                        IF  aux_flgerror = TRUE THEN
                                            DO:
                                                MESSAGE "O fechamento desta " +
                                                        " operacao ja foi "   +
                                                        "realizado no dia "   + 
                                                        STRING(tel_dtmvtolt).
                              
                                                PAUSE (2) NO-MESSAGE.
                                                HIDE MESSAGE NO-PAUSE.
                                            END.
                                    END.
                            END.
                END.

                RELEASE crapfld.
            END. 
        ELSE
        IF  glb_cddopcao = "C" THEN
            DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    ASSIGN tel_dtmvtolt = ?.

                    UPDATE tel_dtmvtolt WITH FRAME f_cldctr.

                    FIND FIRST crapcld WHERE crapcld.dtmvtolt = tel_dtmvtolt 
                                         AND crapcld.cdtipcld = 1
                                         NO-LOCK NO-ERROR.

                    IF  AVAIL crapcld THEN
                        LEAVE.
                    ELSE
                        DO:
                            MESSAGE "Data invalida.".
                            NEXT.
                        END.
                END.
            
                IF  KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                    DO:
                        CLEAR FRAME f_cddopcao NO-PAUSE.
                        LEAVE. 
                    END.

                RUN carrega-creditos (INPUT INT(tel_cdcooper)).
       
                HIDE FRAME f_credito NO-PAUSE.
                HIDE FRAME f_credito_detalhe NO-PAUSE.
                CLEAR FRAME f_cldctr   NO-PAUSE.
            END.
        ELSE
        IF  glb_cddopcao = "P" THEN
            DO:
                ASSIGN tel_nrdconta = 0
                       tel_dtrefini = ?
                       tel_dtreffim = glb_dtmvtolt
                       tel_cdstatus = 1 
                       tel_cdincoaf = 1
                       tel_cdtipcld = 2
                       tel_tpdsaida = "T".    
                    
                UPDATE tel_nrdconta
                       tel_dtrefini
                       tel_dtreffim
                       tel_cdstatus
                       tel_cdincoaf
                       tel_cdtipcld
                       tel_tpdsaida
                       WITH FRAME f_cldctr_p.
                        
                RUN carrega_pesquisa (INPUT INT(tel_cdcooper)).
                HIDE FRAME f_pesquisa NO-PAUSE.
                HIDE FRAME f_pesquisa_detalhe NO-PAUSE.
                CLEAR FRAME f_cldctr_p NO-PAUSE.
            END.
        ELSE
        IF  glb_cddopcao = "T" THEN
            DO:
                ASSIGN tel_dtrefini = ?
                       tel_dtreffim = glb_dtmvtolt
                       tel_tpdsaida = "T".

                UPDATE tel_dtrefini
                       tel_dtreffim
                       tel_tpdsaida
                       WITH FRAME f_cldctr_t.

                RUN carrega_atividade (INPUT INT(tel_cdcooper)).
                HIDE FRAME f_atividade NO-PAUSE.
                HIDE FRAME f_atividade_detalhe NO-PAUSE.
                CLEAR FRAME f_cldctr_t NO-PAUSE.
            END.

       CLEAR FRAME f_cddopcao NO-PAUSE.
       LEAVE.

    END.

    CLEAR FRAME f_cddopcao NO-PAUSE.
    CLEAR FRAME f_cldctr   NO-PAUSE.
    CLEAR FRAME f_cldctr_p NO-PAUSE.
    CLEAR FRAME f_cldctr_t NO-PAUSE.

END. /* Fim do DO WHILE TRUE */

/* ............................... PROCEDURES ............................... */
PROCEDURE carrega_atividade:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper NO-UNDO.
    
    EMPTY TEMP-TABLE tt-atividade.
    
    FOR EACH crapcop WHERE (par_cdcooper = 0        AND
                            crapcop.cdcooper <> 3)  OR
                            crapcop.cdcooper = par_cdcooper NO-LOCK:

        FOR EACH crapcld WHERE crapcld.cdcooper =  crapcop.cdcooper AND
                               crapcld.dtmvtolt >= tel_dtrefini     AND
                               crapcld.dtmvtolt <= tel_dtreffim     NO-LOCK:
        
            FIND crapfld WHERE crapfld.cdcooper = crapcld.cdcooper  AND
                               crapfld.dtmvtolt = tel_dtmvtolt      AND
                               crapfld.cdtipcld = 1 /* DIARIO COOP */
                               NO-LOCK NO-ERROR.
        
            IF  AVAIL crapfld THEN
                ASSIGN aux_dsstatus = "Fechado".
            ELSE
                ASSIGN aux_dsstatus = "Em analise".
        
            FIND crapass WHERE crapass.cdcooper = crapcld.cdcooper AND
                               crapass.nrdconta = crapcld.nrdconta 
                               NO-LOCK NO-ERROR.
        
            IF  AVAIL crapass THEN
                DO:
                    IF  crapass.tpvincul = "FU" OR   /* funcionario da cooperativa*/
                        crapass.tpvincul = "CA" OR   /* conselho de administracao */
                        crapass.tpvincul = "CF" OR   /* conselho fiscal */
                        crapass.tpvincul = "CC" OR   /* conselho da central */
                        crapass.tpvincul = "CO" OR   /* comite cooperativa */
                        crapass.tpvincul = "FC" OR   /* funcionario da central */
                        crapass.tpvincul = "FO" OR   /* funcionario de outras coop*/
                        crapass.tpvincul = "ET" THEN /* estagiario terceiro */ 
                        DO:
        
                            CREATE tt-atividade.
                            ASSIGN tt-atividade.cdcooper = crapcld.cdcooper
                                   tt-atividade.nrdconta = crapcld.nrdconta
                                   tt-atividade.dtmvtolt = crapcld.dtmvtolt
                                   tt-atividade.tpvincul = crapass.tpvincul
                                   tt-atividade.cdagenci = crapcld.cdagenci
                                   tt-atividade.vlrendim = crapcld.vlrendim
                                   tt-atividade.vltotcre = crapcld.vltotcre
                                   tt-atividade.qtultren = crapcld.vltotcre / 
                                                           crapcld.vlrendim
                                   tt-atividade.cddjusti = crapcld.cddjusti   
                                   tt-atividade.dsdjusti = crapcld.dsdjusti  
                                   tt-atividade.infrepcf = 
                                                IF  crapcld.infrepcf = 0 THEN
                                                    "Nao Informar"
                                                ELSE
                                                IF  crapcld.infrepcf = 1 THEN
                                                    "Informar"
                                                ELSE 
                                                IF  crapcld.infrepcf = 2 THEN
                                                    "Ja informado"
                                                ELSE
                                                    ""
                                   tt-atividade.dsobserv = crapcld.dsobserv
                                   tt-atividade.dsobsctr = crapcld.dsobsctr
                                   tt-atividade.dsstatus = aux_dsstatus.
                                
                            ASSIGN aux_dsstatus = "".
        
                        END.
                END. /*FIM IF AVAIL */
            ELSE
                NEXT.
        
        END. /* FIM FOR EACH crapcld */
    END. /* FIM FOR EACH crapcop */

    FIND FIRST tt-atividade NO-LOCK NO-ERROR.

    IF  AVAIL tt-atividade THEN
        DO:
            IF  tel_tpdsaida = "T" THEN
                DO:
                    OPEN QUERY q-atividade FOR EACH tt-atividade 
                                           BY tt-atividade.cdcooper
                                           BY tt-atividade.cdagenci
                                           BY tt-atividade.dtmvtolt
                                           BY tt-atividade.nrdconta.
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b-atividade WITH FRAME f_atividade.
                        LEAVE.
                    END.

                    HIDE FRAME f_atividade_detalhe.
                    CLOSE QUERY q-atividade.
                END.
            ELSE
                DO:
                    /* Inicializa Variaveis Relatorio */
                    ASSIGN glb_cdcritic = 0
                           glb_cdempres = 11
                           glb_cdrelato[1] = 611.

                    { includes/cabrel132_1.i }

                    IF  tel_tpdsaida = "A" THEN
                        DO:
                            ASSIGN aux_nmarquiv = "".

                            DISP aux_dscaminh WITH FRAME f_arquivo.

                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                UPDATE aux_nmarquiv WITH FRAME f_arquivo.

                                LEAVE.
                            END.
                            
                            HIDE FRAME f_arquivo NO-PAUSE.

                            IF aux_nmarquiv = "" THEN
                                RETURN "NOK".

                            ASSIGN aux_nmarquiv = "/micros/cecred/" +
                                                  aux_nmarquiv.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_nmarquiv = "rl/cldsed_" + STRING(TIME) 
                                                  + ".lst". 
                        END.
                        
                    OUTPUT STREAM str_1 TO VALUE (aux_nmarquiv) 
                                           PAGED PAGE-SIZE 84.

                    VIEW STREAM str_1 FRAME f_cabrel132_1.
                    VIEW STREAM str_1 FRAME f_retorno_tit.

                    FOR EACH tt-atividade NO-LOCK BY tt-atividade.cdcooper
                                                  BY tt-atividade.cdagenci
                                                  BY tt-atividade.dtmvtolt
                                                  BY tt-atividade.nrdconta:

                        DISP STREAM str_1 tt-atividade.cdcooper
                                          tt-atividade.cdagenci
                                          tt-atividade.dtmvtolt
                                          tt-atividade.nrdconta
                                          tt-atividade.vlrendim
                                          tt-atividade.vltotcre
                                          tt-atividade.qtultren
                                          tt-atividade.dsstatus
                                          tt-atividade.infrepcf
                                          WITH FRAME f_atividade_retorno.

                        DOWN STREAM str_1 WITH FRAME f_atividade_retorno.

                        /* dsdjusti */
                        ASSIGN aux_textocom = tt-atividade.dsdjusti.
                        ASSIGN aux_textodis = SUBSTRING(aux_textocom,1,60).
                        ASSIGN aux_textocom = SUBSTRING(aux_textocom,61).
                        
                        DISP STREAM str_1 aux_textodis WITH FRAME f_atividade_justifc.
                        DOWN STREAM str_1 WITH FRAME f_atividade_justifc.
                        
                        DO WHILE aux_textocom <> "":
                          ASSIGN aux_textodis = SUBSTRING(aux_textocom,1,60).
                          ASSIGN aux_textocom = SUBSTRING(aux_textocom,61).
                          
                          DISP STREAM str_1 aux_textodis WITH FRAME f_atividade_justifi.
                          DOWN STREAM str_1 WITH FRAME f_atividade_justifi.
                    END.

                        /* dsobserv */
                        ASSIGN aux_textocom = tt-atividade.dsobserv.
                        ASSIGN aux_textodis = SUBSTRING(aux_textocom,1,60).
                        ASSIGN aux_textocom = SUBSTRING(aux_textocom,61).
                        
                        DISP STREAM str_1 aux_textodis WITH FRAME f_atividade_justifcc.
                        DOWN STREAM str_1 WITH FRAME f_atividade_justifcc.
                        
                        DO WHILE aux_textocom <> "":
                          ASSIGN aux_textodis = SUBSTRING(aux_textocom,1,60).
                          ASSIGN aux_textocom = SUBSTRING(aux_textocom,61).
                          
                          DISP STREAM str_1 aux_textodis WITH FRAME f_atividade_justifi.
                          DOWN STREAM str_1 WITH FRAME f_atividade_justifi.
                        END.
                        
                        /* dsobsctr */
                        ASSIGN aux_textocom = tt-atividade.dsobsctr.
                        ASSIGN aux_textodis = SUBSTRING(aux_textocom,1,60).
                        ASSIGN aux_textocom = SUBSTRING(aux_textocom,61).
                        
                        DISP STREAM str_1 aux_textodis WITH FRAME f_atividade_justifcs.
                        DOWN STREAM str_1 WITH FRAME f_atividade_justifcs.
                        
                        DO WHILE aux_textocom <> "":
                          ASSIGN aux_textodis = SUBSTRING(aux_textocom,1,60).
                          ASSIGN aux_textocom = SUBSTRING(aux_textocom,61).
                          
                          DISP STREAM str_1 aux_textodis WITH FRAME f_atividade_justifi.
                          DOWN STREAM str_1 WITH FRAME f_atividade_justifi.
                        END.
                        
                        /* Vinculo */
                        DISP STREAM str_1 tt-atividade.tpvincul
                            WITH FRAME f_atividade_vinculo.

                        DOWN STREAM str_1 WITH 
                            FRAME f_atividade_vinculo.

                    END.

                    OUTPUT STREAM str_1 CLOSE.

                    IF  tel_tpdsaida = "I" THEN
                        DO:
                            ASSIGN aux_nmarqimp = aux_nmarquiv
                                   glb_nmformul = "132col"
                                   glb_nrcopias = 1
                                   par_flgrodar = TRUE.

                            /* Somente para a impressao */
                            FIND FIRST crapass 
                                 WHERE crapass.cdcooper = glb_cdcooper 
                                 NO-LOCK NO-ERROR.

                            { includes/impressao.i }
                            
                        END.
                END.

        END.
    ELSE
        MESSAGE "Nao existem lancamentos a serem listados.".

END PROCEDURE. /* carrega_atividade */

PROCEDURE carrega_pesquisa:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper NO-UNDO.

    EMPTY TEMP-TABLE tt-pesquisa.

    FOR EACH crapcop WHERE (par_cdcooper = 0        AND
                            crapcop.cdcooper <> 3)  OR
                            crapcop.cdcooper = par_cdcooper NO-LOCK:
    
        FOR EACH crapcld WHERE crapcld.cdcooper =  crapcop.cdcooper AND
                              (tel_cdincoaf = 1                     OR
                               crapcld.infrepcf = tel_cdincoaf)     AND
                               crapcld.dtmvtolt >= tel_dtrefini     AND
                               crapcld.dtmvtolt <= tel_dtreffim     AND
                              (tel_nrdconta     = 0                 OR
                               crapcld.nrdconta = tel_nrdconta)     AND
                               crapcld.cdtipcld = tel_cdtipcld
                               NO-LOCK:
        
            FIND crapfld WHERE crapfld.cdcooper = crapcld.cdcooper  AND
                               crapfld.dtmvtolt = crapcld.dtmvtolt  AND
                               crapfld.cdtipcld = 1 /* DIARIO COOP */
                               NO-LOCK NO-ERROR.
        
            IF  AVAIL crapfld THEN
                DO:
                    IF  tel_cdstatus = 2 THEN
                        NEXT.
        
                    ASSIGN aux_dsstatus = "Fechado".
                END.
            ELSE
                DO:
                    IF  tel_cdstatus = 3 THEN
                        NEXT.
        
                    ASSIGN aux_dsstatus = "Em analise".
                END.
        
            CREATE tt-pesquisa.
            ASSIGN tt-pesquisa.cdcooper = crapcld.cdcooper
                   tt-pesquisa.cdagenci = crapcld.cdagenci
                   tt-pesquisa.dtmvtolt = crapcld.dtmvtolt
                   tt-pesquisa.nrdconta = crapcld.nrdconta
                   tt-pesquisa.vlrendim = crapcld.vlrendim
                   tt-pesquisa.vltotcre = crapcld.vltotcre
                   tt-pesquisa.qtultren = IF crapcld.vlrendim > 0 THEN
                                             crapcld.vltotcre / crapcld.vlrendim   
                                          ELSE
                                             0
                   tt-pesquisa.dsstatus = aux_dsstatus
                   tt-pesquisa.dsdjusti = crapcld.dsdjusti
                   tt-pesquisa.infrepcf = IF crapcld.infrepcf = 0 THEN
                                             "Nao Informar"
                                          ELSE
                                          IF crapcld.infrepcf = 1 THEN
                                             "Informar"
                                          ELSE 
                                          IF crapcld.infrepcf = 2 THEN
                                             "Ja informado"
                                          ELSE
                                             "".
        
        END. /* FIM FOR EACH crapcld */
    END. /* FIM FOR EACH crapcop */

    FIND FIRST tt-pesquisa NO-LOCK NO-ERROR.

    IF  AVAIL tt-pesquisa THEN
        DO:
            CASE tel_tpdsaida:
                /* Exibir na tela */
                WHEN "T" THEN
                DO:
                    OPEN QUERY q-pesquisa FOR EACH tt-pesquisa 
                                              BY tt-pesquisa.cdcooper
                                              BY tt-pesquisa.cdagenci
                                              BY tt-pesquisa.dtmvtolt
                                              BY tt-pesquisa.nrdconta.
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b-pesquisa WITH FRAME f_pesquisa.
                        LEAVE.
                    END.
    
                    HIDE FRAME f_pesquisa_detalhe.
                    CLOSE QUERY q-pesquisa.
    
                END.

                /* Imprimir */
                WHEN "I" THEN
                DO:
                    /* Inicializa Variaveis Relatorio */
                    ASSIGN glb_cdcritic = 0
                           glb_cdempres = 11
                           glb_cdrelato[1] = 610.
    
                    { includes/cabrel132_1.i }
    
                    ASSIGN aux_nmarquiv = "rl/cldsed_" + STRING(TIME) 
                                          + ".lst". 
    
                    OUTPUT STREAM str_1 TO VALUE (aux_nmarquiv) 
                                           PAGED PAGE-SIZE 84.
    
                    VIEW STREAM str_1 FRAME f_retorno_tit.
    
                    FOR EACH tt-pesquisa NO-LOCK BY tt-pesquisa.cdcooper
                                                 BY tt-pesquisa.cdagenci
                                                 BY tt-pesquisa.dtmvtolt
                                                 BY tt-pesquisa.nrdconta:
    
                        DISP STREAM str_1 tt-pesquisa.cdcooper
                                          tt-pesquisa.cdagenci
                                          tt-pesquisa.dtmvtolt
                                          tt-pesquisa.nrdconta
                                          tt-pesquisa.vlrendim
                                          tt-pesquisa.vltotcre
                                          tt-pesquisa.qtultren
                                          tt-pesquisa.dsstatus
                                          tt-pesquisa.infrepcf
                                          WITH FRAME f_pesquisa_retorno.
    
                        DOWN STREAM str_1 WITH FRAME f_pesquisa_retorno.
    
                        ASSIGN aux_textocom = tt-pesquisa.dsdjusti.
                        ASSIGN aux_textodis = SUBSTRING(aux_textocom,1,60).
                        ASSIGN aux_textocom = SUBSTRING(aux_textocom,61).

                        DISP STREAM str_1 aux_textodis WITH FRAME f_pesquisa_justifc.
                        DOWN STREAM str_1 WITH FRAME f_pesquisa_justifc.
            
                        DO WHILE aux_textocom <> "":
                          ASSIGN aux_textodis = SUBSTRING(aux_textocom,1,60).
                          ASSIGN aux_textocom = SUBSTRING(aux_textocom,61).
              
                          DISP STREAM str_1 aux_textodis WITH FRAME f_pesquisa_justifi.
                          DOWN STREAM str_1 WITH FRAME f_pesquisa_justifi.
                        END.
                    END.
    
                    OUTPUT STREAM str_1 CLOSE.
    
                    ASSIGN aux_nmarqimp = aux_nmarquiv
                           glb_nmformul = "132col"
                           glb_nrcopias = 1
                           par_flgrodar = TRUE.
    
                    /* Somente para a impressao */
                    FIND FIRST crapass 
                         WHERE crapass.cdcooper = glb_cdcooper 
                         NO-LOCK NO-ERROR.
    
                    { includes/impressao.i }
                END.
    
                /* Gerar Arquivo */
                WHEN "A" THEN
                DO:
                    ASSIGN aux_nmarquiv = "".
    
                    DISP aux_dscaminh WITH FRAME f_arquivo.
    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
                        UPDATE aux_nmarquiv WITH FRAME f_arquivo.
    
                        LEAVE.
                    END.
    
                    HIDE FRAME f_arquivo NO-PAUSE.
    
                    IF aux_nmarquiv = "" THEN
                        RETURN "NOK".
    
                    ASSIGN aux_nmarquiv = "/micros/cecred/" + 
                                          aux_nmarquiv + ".csv".
    
                    OUTPUT TO value(aux_nmarquiv).
    
                    PUT UNFORM "Coop;PA;Data;Conta/DV;Renda;Creditos;" + 
                               "Creditos/Renda;Status;COAF;Justificativa" 
                               SKIP.
    
                    FOR EACH tt-pesquisa NO-LOCK BY tt-pesquisa.cdcooper
                                                 BY tt-pesquisa.cdagenci
                                                 BY tt-pesquisa.dtmvtolt
                                                 BY tt-pesquisa.nrdconta:
    
                        PUT UNFORM TRIM(STRING(tt-pesquisa.cdcooper,"z9"))  ";"
                                   TRIM(STRING(tt-pesquisa.cdagenci,"zz9")) ";"
                                   TRIM(STRING(tt-pesquisa.dtmvtolt,"99/99/9999")) ";"
                                   TRIM(STRING(tt-pesquisa.nrdconta,"zzzz,zzz,9")) ";"
                                   TRIM(STRING(tt-pesquisa.vlrendim,"zzzz,zzz,zz9.99")) ";"
                                   TRIM(STRING(tt-pesquisa.vltotcre,"zzzz,zzz,zz9.99")) ";"
                                   TRIM(STRING(tt-pesquisa.qtultren,"zz,zzz,zz9")) ";"
                                   TRIM(tt-pesquisa.dsstatus) ";"
                                   TRIM(tt-pesquisa.infrepcf) ";"
                                   TRIM(tt-pesquisa.dsdjusti) ";"
                                   SKIP.
                    END.
    
                    OUTPUT CLOSE.
                END.
            END CASE.
        END.
    ELSE
        MESSAGE "Nao existem lancamentos a serem listados.".

END PROCEDURE. /* carrega_pesquisa */

PROCEDURE carrega-creditos:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper NO-UNDO.

    DEF VAR aux_dsstatus AS CHAR                       NO-UNDO.

    EMPTY TEMP-TABLE tt-creditos.
               
    FOR EACH crapcld WHERE (IF par_cdcooper = 0 THEN 
                              (crapcld.dtmvtolt = tel_dtmvtolt AND
                               crapcld.cdtipcld = 1) ELSE
                              (crapcld.cdcooper = par_cdcooper AND
                               crapcld.dtmvtolt = tel_dtmvtolt AND
                               crapcld.cdtipcld = 1))
                               NO-LOCK:
                 
        FIND crapass WHERE crapass.cdcooper = crapcld.cdcooper AND
                           crapass.nrdconta = crapcld.nrdconta
                           NO-LOCK NO-ERROR.

        FIND crapage WHERE crapage.cdcooper = crapcld.cdcooper AND
                           crapage.cdagenci = crapcld.cdagenci
                           NO-LOCK NO-ERROR.

        IF AVAIL crapage THEN
           aux_nmresage = STRING(crapage.cdagenci) + " - " + crapage.nmresage.
                           
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }          
          /* Efetuar a chamada a rotina Oracle */ 
          RUN STORED-PROCEDURE pc_consultar_parmon_pld_car
           aux_handproc = PROC-HANDLE NO-ERROR 
                       ( INPUT glb_cdcooper /* pr_cdcooper --> Codigo da cooperativa */                                             
                        /* --------- OUT --------- */
                        ,OUTPUT 0          /* pr_vllimite --> Retorno da operacao     */
                        ,OUTPUT 0          /* pr_vlcredito_diario_pf --> Retorno da operacao     */
                        ,OUTPUT 0          /* pr_vlcredito_diario_pj --> Retorno da operacao     */
                        ,OUTPUT 0          /* pr_cdcritic --> Codigo da critica  */
                        ,OUTPUT "" ).      /* pr_dscritic --> Descriçao da critica    */
          
          /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_consultar_parmon_pld_car
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN tel_vldirfis = pc_consultar_parmon_pld_car.pr_vlcredito_diario_pf
                     WHEN pc_consultar_parmon_pld_car.pr_vlcredito_diario_pf <> ?.
          
          ASSIGN tel_vldirjur = pc_consultar_parmon_pld_car.pr_vlcredito_diario_pj
                     WHEN pc_consultar_parmon_pld_car.pr_vlcredito_diario_pj <> ?.  
        
        FIND crapfld WHERE crapfld.cdcooper = crapcld.cdcooper AND   
                           crapfld.dtmvtolt = tel_dtmvtolt     AND
                           crapfld.cdtipcld = 1 /* DIARIO COOP */
                           NO-LOCK NO-ERROR.

        IF AVAIL crapfld THEN
           aux_dsstatus = "Fechado".
        ELSE
           aux_dsstatus = "Em Analise".


        IF AVAIL crapass AND
           (crapass.inpessoa = 1 AND 
           (crapcld.vltotcre / crapcld.vlrendim) > tel_vldirfis) OR
           (crapass.inpessoa = 2 AND 
           (crapcld.vltotcre / crapcld.vlrendim) > tel_vldirjur) THEN
           DO: 
              CREATE tt-creditos.
             
              ASSIGN tt-creditos.cdcooper = crapcld.cdcooper
                     tt-creditos.nrdconta = crapcld.nrdconta
                     tt-creditos.vlrendim = crapcld.vlrendim
                     tt-creditos.vltotcre = crapcld.vltotcre
                     tt-creditos.cddjusti = crapcld.cddjusti
                     tt-creditos.dsdjusti = crapcld.dsdjusti  
                     tt-creditos.opeenvcf = crapcld.opeenvcf
                     tt-creditos.nmresage = aux_nmresage
                     tt-creditos.nmprimtl = crapass.nmprimtl
                     tt-creditos.ultrenda = (crapcld.vltotcre / crapcld.vlrendim)
                     tt-creditos.dsstatus = aux_dsstatus
                     tt-creditos.cdoperad = crapcld.cdoperad
                     tt-creditos.dsobserv = crapcld.dsobserv
                     tt-creditos.dsobsctr = crapcld.dsobsctr
                     tt-creditos.nmprimtl = crapass.nmprimtl 
                     tt-creditos.infrepcf = IF crapcld.infrepcf = 0 THEN
                                               "Nao Informar"
                                            ELSE
                                            IF crapcld.infrepcf = 1 THEN
                                               "Informar"
                                            ELSE 
                                            IF crapcld.infrepcf = 2 THEN
                                               "Ja informado"
                                            ELSE
                                               ""
                     tt-creditos.inpessoa = IF crapass.inpessoa = 1 THEN
                                               STRING(crapass.inpessoa) + "-FISICA"
                                            ELSE
                                               STRING(crapass.inpessoa) + "-JURIDICA".
                     
                 

           END.

    END.

    FIND FIRST tt-creditos NO-LOCK NO-ERROR.

    IF  AVAIL tt-creditos THEN
        DO: 
            OPEN QUERY q-creditos FOR EACH tt-creditos BY tt-creditos.cdcooper 
                                                        BY tt-creditos.nrdconta.

            UPDATE b-creditos WITH FRAME f_credito.
            
            HIDE FRAME f_credito_detalhe.
        END.
    ELSE
      MESSAGE "Nao existem lancamentos a serem listados.".
         

END PROCEDURE. /* FIM carrega-creditos */


/*************************************************************************/
