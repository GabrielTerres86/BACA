/* ..........................................................................

   Programa: Fontes/cadtax.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Julho/2007                      Ultima atualizacao: 30/11/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CADTAX 
              (Cadastro de aplicacoes, periodos e faixas RDC).

   
   Alteracoes: 10/09/2007 - Campo Dias Carencia movido do item "Tipos" para o
                            item "Periodos". 
                          - Eliminadas criticas de controle referentes aos
                            periodos das aplicacoes (Elton).

               26/10/2007 - Incluida a opcao "Acumula".
                          - Usar campo craptab.cdempres para colocar o tipo de
                            aplicacao que usara a cumulatividade e usar o campo
                            craptab.tpregist com os tipos de aplicacao que
                            serao olhadas para se buscar a nova taxa (Elton).
               
               05/11/2007 - Incluido log para inclusoes, alteracoes e exclusoes
                            dos periodos e das faixas (Elton).

               23/01/2009 - Retirada permissao do operador 996, e permitido
                            ao 979 (Gabriel).
                            
               11/05/2009 - Alteracao CDOPERAD (Kbase).
                        
               14/08/2009 - Adicionar campo "Renumera Maior Cdi/Poup". Este 
                            campo so sera utilizado quando crapdtc.tpaplrdc = 2
                            (Fernando).

               20/07/2010 - Permitir taxas maximas e minimas iguais (Magui).
               
               23/08/2013 - Alteração clausula consultas crapdtc e 
                            implementeção da opção P (Lucas).
                            
               02/12/2013 - Inclusao de VALIDATE crapdtc, crapttx, crapftx 
                            e craptab (inclui, acumula) (Carlos)
                            
               08/04/2014 - Ajuste WHOLE-INDEX nas leituras da crapttx
                            (Adriano).
                            
               21/07/2014 - Inclusao da opcao "PCAPTA" na opcao "ACUMULA",
                            projeto de captação. (Jean Michel)    
                            
               04/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)          
                           
               30/11/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
............................................................................. */

{ includes/var_online.i  }

DEF NEW SHARED VAR shr_tpaplica  LIKE crapdtc.tpaplica        NO-UNDO.
DEF NEW SHARED VAR shr_dsextapl  LIKE crapdtc.dsextapl        NO-UNDO.
DEF NEW SHARED VAR shr_cdperapl  LIKE crapttx.cdperapl        NO-UNDO.
DEF NEW SHARED VAR shr_tptaxrdc  LIKE crapttx.tptaxrdc        NO-UNDO.

/*****TIPO***/
DEF VAR tel_cddopcao AS CHAR FORMAT "!(1)"                          NO-UNDO.
DEF VAR tel_tptaxrdc AS INTE format "z9"                            NO-UNDO.
DEF VAR tel_tpaplrdc LIKE crapdtc.tpaplrdc                          NO-UNDO.
DEF VAR tel_dsaplica AS CHAR FORMAT "x(06)"                         NO-UNDO.
DEF VAR tel_dsextapl AS CHAR FORMAT "x(20)"                         NO-UNDO.
DEF VAR tel_vlminapl LIKE crapdtc.vlminapl                          NO-UNDO.
DEF VAR tel_vlmaxapl LIKE crapdtc.vlmaxapl                          NO-UNDO.
DEF VAR tel_flgstrdc LIKE crapdtc.flgstrdc                          NO-UNDO.

/******PERIODO******/
DEF VAR tel_cdperapl LIKE crapttx.cdperapl                          NO-UNDO.
DEF VAR tel_qtdiaini LIKE crapttx.qtdiaini                          NO-UNDO.
DEF VAR tel_qtdiafim LIKE crapttx.qtdiafim                          NO-UNDO.
DEF VAR tel_qtdiacar LIKE crapdtc.qtdiacar                          NO-UNDO.

/*********FAIXAS*********/
DEF VAR tel_vlfaxini AS DECIMAL  FORMAT "zzz,zz9.99"                NO-UNDO.
DEF VAR tel_vlfaxfim LIKE craplcm.vllanmto                          NO-UNDO.
DEF VAR tel_perapltx LIKE crapftx.perapltx                          NO-UNDO.
DEF VAR tel_perrdttx LIKE crapftx.perrdttx                          NO-UNDO.

/************LOG******************/
DEF VAR aux_qtdiacar AS INT NO-UNDO. 
DEF VAR aux_qtdiaini AS INT NO-UNDO.
DEF VAR aux_qtdiafim AS INT NO-UNDO.
DEF VAR aux_perapltx LIKE crapftx.perapltx                          NO-UNDO.
DEF VAR aux_perrdttx LIKE crapftx.perrdttx                          NO-UNDO.

/*******************ACUMULA********************/
DEF VAR tel_flgrdmpp   AS LOG     FORMAT "Sim/Nao"                  NO-UNDO.
DEF VAR tel_flgpcapt   AS LOG     FORMAT "Sim/Nao"                  NO-UNDO.
DEF VAR tel_flgrdc30   AS LOG     FORMAT "Sim/Nao"                  NO-UNDO.
DEF VAR tel_flgrdc60   AS LOG     FORMAT "Sim/Nao"                  NO-UNDO.
DEF VAR tel_flgrdpre   AS LOG     FORMAT "Sim/Nao"                  NO-UNDO.
DEF VAR tel_flgrdpos   AS LOG     FORMAT "Sim/Nao"                  NO-UNDO.

DEF VAR reg_dsdopcao AS CHAR    FORMAT "x(24)" EXTENT 4
                     INIT["Tipos","Periodos","Faixas","Acumula"]    NO-UNDO.

DEF VAR reg_dsaltera AS CHAR                   INIT "ALTERAR"       NO-UNDO.

DEF VAR aux_contador AS INT                                         NO-UNDO.

DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                       NO-UNDO. 
DEF VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF VAR aux_dtfimtax AS DATE                                        NO-UNDO.
DEF VAR aux_dtcalcul AS DATE                                        NO-UNDO.   
DEF VAR aux_flgalter AS LOG                                         NO-UNDO.
DEF VAR tel_dsperapl AS CHAR                                        NO-UNDO.
DEF VAR tel_flgrncdi AS LOG     FORMAT "SIM/NAO"                    NO-UNDO.

DEF  VAR aux_dadosusr AS CHAR                                       NO-UNDO.
DEF  VAR par_loginusr AS CHAR                                       NO-UNDO.
DEF  VAR par_nmusuari AS CHAR                                       NO-UNDO.
DEF  VAR par_dsdevice AS CHAR                                       NO-UNDO.
DEF  VAR par_dtconnec AS CHAR                                       NO-UNDO.
DEF  VAR par_numipusr AS CHAR                                       NO-UNDO.
DEF  VAR h-b1wgen9999 AS HANDLE                                     NO-UNDO.

DEF TEMP-TABLE cratttx  NO-UNDO LIKE crapttx.
DEF TEMP-TABLE cratftx  NO-UNDO LIKE crapftx.

DEF BUFFER crabdtc FOR crapdtc.
       
DEF TEMP-TABLE w_faixas                                              NO-UNDO
    FIELD tptaxrdc  AS INT                   
    FIELD cdperapl  LIKE crapttx.cdperapl
    FIELD vlfaxini  AS DECIMAL  FORMAT "zzz,zz9.99"
    FIELD vlfaxfim  AS DECIMAL  FORMAT "zzz,zzz,zz9.99"
    FIELD perapltx  AS DECIMAL  FORMAT "zz9.999999"
    FIELD perrdttx  AS DECIMAL  FORMAT "zz9.999999".

DEF TEMP-TABLE tt-rdcpos NO-UNDO
    FIELD dsaplica AS CHAR FORMAT "X(12)"
    FIELD qtinicar AS INTE FORMAT "zz9"
    FIELD qtfincar AS INTE FORMAT "zz9"
    FIELD tpaplica AS INTE 
    FIELD vliniapl AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD vlfinapl AS DECI FORMAT "zzz,zzz,zz9.99".

DEF TEMP-TABLE tt-rdcpos-log LIKE tt-rdcpos.

DEF BUFFER w_faixas2 FOR w_faixas.

DEF QUERY q_faixas FOR w_faixas.
                                             
DEF BROWSE b_faixas QUERY q_faixas
    DISPLAY 
            w_faixas.vlfaxini  COLUMN-LABEL "DE"       
            SPACE(4)
            w_faixas.vlfaxfim  COLUMN-LABEL "ATE"
            SPACE(4)            
            w_faixas.perapltx  COLUMN-LABEL "%Vencto"
            SPACE(5)
            w_faixas.perrdttx  COLUMN-LABEL "%Resgat"
            SPACE(5)
            WITH 5 DOWN NO-BOX.

DEF QUERY q_periodos FOR cratttx.

DEF BROWSE b_periodos QUERY q_periodos
    DISPLAY cratttx.tptaxrdc  COLUMN-LABEL "Aplicacao" SPACE(7) 
            cratttx.cdperapl  COLUMN-LABEL "Periodo"   SPACE(7)
            cratttx.qtdiacar  COLUMN-LABEL "Carencia"  SPACE(7)   
            cratttx.qtdiaini  COLUMN-LABEL "Inicio"    SPACE(7)
            cratttx.qtdiafim  COLUMN-LABEL "Fim"       SPACE(6) 
            WITH 4 DOWN NO-BOX.

FORM reg_dsdopcao[1] FORMAT "x(5)" SPACE (10)
     reg_dsdopcao[2] FORMAT "x(8)" SPACE (10)
     reg_dsdopcao[3] FORMAT "x(6)" SPACE (10)
     reg_dsdopcao[4] FORMAT "x(7)"
     WITH ROW 19 COLUMN 2 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_opcao.

FORM "  Produto   "                      AT 2
     " Carencia  "                       AT 15
     "             Valores             " AT 27 
     SKIP
     "------------"                      AT 2
     "-----------"                       AT 15
     "---------------------------------" AT 27
     SKIP
     WITH ROW 9 COLUMN 12 NO-LABELS NO-BOX OVERLAY FRAME f_produtos-rdcpos-cabecalho.

FORM tt-rdcpos.dsaplica 
     tt-rdcpos.qtinicar AT 14
     "ate"
     tt-rdcpos.qtfincar AT 22
     tt-rdcpos.vliniapl AT 26
     "ate"
     tt-rdcpos.vlfinapl
     WITH ROW 11 COLUMN 13 NO-LABELS 5 DOWN NO-BOX OVERLAY FRAME f_produtos-rdcpos.

FORM reg_dsaltera FORMAT "x(07)"
     WITH ROW 19 COLUMN 2 NO-LABELS CENTERED NO-BOX OVERLAY FRAME f_opcao-altera-rdcpos.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.
 
/*** Frame da opcao Tipos ***/

FORM SKIP(2)
     glb_cddopcao LABEL "Opcao"                    AT 08
     HELP "Informe a opcao desejada (A, C, E, I ou P)."
              VALIDATE (CAN-DO("A,C,E,I,P", glb_cddopcao), 
                                "014 - Opcao errada.")
    WITH FRAME f_cddopcao SIDE-LABELS ROW 5 WIDTH 78 CENTERED OVERLAY NO-BOX.

FORM SKIP(1)
     tel_tptaxrdc LABEL "Tipo"                     AT 20
                  HELP "Informe o tipo da aplicacao."
                  VALIDATE (tel_tptaxrdc <> 0,
                           "Tipo de aplicacao deve ser maior que '0'.")
     SKIP(1)
     tel_tpaplrdc LABEL "Pre/Pos"                  AT 17
                  VALIDATE (CAN-DO("1,2",tel_tpaplrdc),
                            "Tipo RDC deve ser '1' para Pre ou '2' para Pos .")
     HELP "Informe o tipo de RDC (1-Pre, 2-Pos)."
     tel_dsextapl LABEL "Descricao"                AT 15
                        HELP "Informe a descricao da aplicacao."
     tel_dsaplica LABEL "Desc.Resumida"            AT 11
                        HELP "Informe a descricao resumida."
     tel_vlminapl LABEL "Valor Minimo"             AT 12
                        HELP "Informe o valor minimo da aplicacao."
     tel_vlmaxapl LABEL "Valor Maximo"             AT 12
                        VALIDATE ((tel_vlmaxapl > tel_vlminapl),
                        "Valor maximo deve ser maior que valor minimo.")
                        HELP "Informe o valor maximo da aplicacao."
     tel_flgstrdc LABEL "Situacao"                 AT 16
                        HELP "Informe a situacao 'Bloqueada/Liberada'."
     tel_flgrncdi LABEL "Renumera Maior Cdi/Poup"  AT 01
                        
     SKIP(1)
     "           Tipos          Periodos          Faixas          Acumula"
     SKIP(1)            
     WITH FRAME f_tipo SIDE-LABELS ROW 8 WIDTH 78 CENTERED OVERLAY NO-BOX.


FORM SKIP(1)
     "Tipo: " AT 3 tel_tptaxrdc 
              HELP "Informe o tipo de aplicacao."
     tel_dsaplica 
     SKIP(1)
     b_periodos
     WITH FRAME f_periodo   NO-LABEL 
     TITLE "PERIODOS CAPTACAO" OVERLAY ROW 9 WIDTH  60 CENTERED.

/*** Frame para Inclusao de periodo ***/
FORM SKIP(1)
     tel_tptaxrdc LABEL "Tipo" 
                  HELP "Informe o tipo de aplicacao."
     tel_cdperapl LABEL "Cod.Periodo" 
     HELP "Informe o codigo do periodo da aplicacao."
     SKIP(1)
     tel_qtdiacar LABEL "Dias de Carencia"
     tel_qtdiaini LABEL "Qtd Dias Inicial"
     tel_qtdiafim LABEL "Qtd Dias Final"
     SKIP(1)
     WITH FRAME f_inclui_periodo TITLE "PERIODOS CAPTACAO" 1 COLUMN 
     ROW 9 WIDTH 60 CENTERED OVERLAY.
                                                            

FORM SKIP(1)
     tel_tptaxrdc LABEL "Tipo" AT 3 
                  HELP  "Informe o tipo da aplicacao." 
                  tel_dsaplica     
                  SPACE(7)     
     tel_cdperapl LABEL "Periodo"
                  HELP  "Informe o periodo da aplicacao."
                  tel_dsperapl   
     SKIP(1)
     b_faixas
     WITH FRAME f_faixas NO-LABEL SIDE-LABELS COLUMN 5
     WIDTH 72 TITLE "FAIXAS CAPTACAO" OVERLAY ROW 9.


/*** Frame da opcao "Acumula"  ***/
FORM SKIP(1)
     tel_tptaxrdc  AT 8 LABEL "Tipo"  
                   HELP "Informe o tipo da aplicacao ou F7 para listar."
                   FORMAT "z9"        
     tel_dsaplica AT 17   NO-LABEL
     SKIP(2)
     tel_flgpcapt    AT 8   LABEL "0 -    PCAPTA"
     tel_flgrdc60    AT 35  LABEL "3 -    RDCA60"
     SKIP(1)
     tel_flgrdc30    AT 8   LABEL "1 -    RDCA30"
     tel_flgrdpre    AT 35  LABEL "7 -    RDCPRE"    
     SKIP(1)
     tel_flgrdmpp    AT 8   LABEL "2 - POUP.PROG"
     tel_flgrdpos    AT 35  LABEL "8 -    RDCPOS"
     SKIP(1)
     WITH FRAME f_acumula ROW 9 OVERLAY SIDE-LABELS COLUMN 7
                          WIDTH 62 TITLE "ACUMULA CAPTACAO".

/*** EVENTOS DOS BROWSERS ***/                    
ON  RETURN  OF b_faixas DO:
               
    HIDE MESSAGE NO-PAUSE.
    
    IF   glb_cddopcao = "C"   THEN
         LEAVE.
    ELSE
    IF   glb_cddopcao = "I"   THEN
         RUN inclui_faixas.
    ELSE
    IF   glb_cddopcao = "E"   THEN
         RUN exclui_faixas.
    ELSE      
    IF   glb_cddopcao = "A"   THEN
         RUN altera_faixas.
    
    RUN atualiza_faixas.      
    
    OPEN  QUERY q_faixas FOR EACH w_faixas WHERE 
                                  w_faixas.tptaxrdc = tel_tptaxrdc   AND
                                  w_faixas.cdperapl = tel_cdperapl
                                  BY w_faixas.vlfaxini.
END.                             

ON  RETURN  OF b_periodos DO:
               
    HIDE MESSAGE NO-PAUSE.
    
    IF   glb_cddopcao = "C"   THEN
         LEAVE.
    ELSE      
    IF   glb_cddopcao = "A"   THEN
         DO:
            IF crapdtc.tpaplrdc = 1 THEN /** RDCPRE **/
               DO:
                    MESSAGE "Nao eh possivel alterar!" 
                            "Utilize a opcao de exclusao.".
                    BELL.
               END.
            ELSE
               RUN altera_periodos. 
         END.
    ELSE
    IF   glb_cddopcao = "E"   THEN
         RUN exclui_periodos.

    OPEN  QUERY q_periodos FOR EACH cratttx WHERE 
                                    cratttx.cdcooper = glb_cdcooper AND
                                    cratttx.tptaxrdc = tel_tptaxrdc.   
END.


VIEW FRAME f_moldura.
PAUSE 0.

ASSIGN glb_cddopcao = "C".


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
   RUN fontes/inicia.p.
     
   tel_flgrncdi:VISIBLE IN FRAME f_tipo = FALSE.
   
   DO  WHILE TRUE ON ENDKEY UNDO, LEAVE :   
       HIDE FRAME f_tipo NO-PAUSE.
       HIDE FRAME f_opcao NO-PAUSE.
       HIDE FRAME f_acumula NO-PAUSE.
       HIDE FRAME f_produtos-rdcpos NO-PAUSE.
       HIDE FRAME f_opcao-altera-rdcpos NO-PAUSE.
       HIDE FRAME f_produtos-rdcpos-cabecalho NO-PAUSE.

       UPDATE glb_cddopcao WITH FRAME f_cddopcao.
       LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            RUN  fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "CADTAX"   THEN
                 DO:
                    HIDE FRAME f_tipo.  
                    RETURN.                 
                 END.
            ELSE
                 NEXT.
        END.         
                                        
   IF   glb_cddepart <> 20 AND  /* "TI                   */
        glb_cddepart <> 14 AND  /* "PRODUTOS             */
        glb_cddepart <>  9 AND  /* "COORD.PRODUTOS       */
        glb_cddepart <>  8 AND  /* "COORD.ADM/FINANCEIRO */
        CAN-DO("A,E,I,P",glb_cddopcao)          THEN
        DO:
             ASSIGN glb_cdcritic = 323.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             ASSIGN glb_cdcritic = 0.
             NEXT.
        END.
    
   IF   aux_cddopcao <> INPUT glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = INPUT glb_cddopcao.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
  
     HIDE FRAME f_periodo NO-PAUSE.
     HIDE FRAME f_inclui_periodo NO-PAUSE.
     HIDE FRAME f_faixas NO-PAUSE.
     HIDE FRAME f_inclui_faixa NO-PAUSE.
     HIDE FRAME f_altera_periodos NO-PAUSE.
     HIDE FRAME f_altera_faixas NO-PAUSE.

     IF glb_cddopcao  <> "P" THEN
        DO:
            RUN limpa_tipo. 
            PAUSE 0.

            DISPLAY reg_dsdopcao[1] 
                    reg_dsdopcao[2] 
                    reg_dsdopcao[3]  
                    reg_dsdopcao[4] WITH   FRAME f_opcao.

            CHOOSE FIELD reg_dsdopcao[1] reg_dsdopcao[2] 
                         reg_dsdopcao[3] reg_dsdopcao[4] WITH FRAME f_opcao.    
                  
        END.
     ELSE
        DO:
            HIDE FRAME f_tipo NO-PAUSE.
            RUN produtos-rdcpos.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                DISPLAY reg_dsaltera WITH FRAME f_opcao-altera-rdcpos.
                CHOOSE FIELD reg_dsaltera WITH FRAME f_opcao-altera-rdcpos.

                IF  FRAME-VALUE = reg_dsaltera THEN
                    DO:
                        RUN atualiza-produtos-rdcpos.
                        LEAVE.
                    END.
                    
            END.

            LEAVE.
        END.
        
     IF glb_cddopcao  = "C" THEN
        DO:     /** Consulta Tipos **/
            IF  FRAME-VALUE = reg_dsdopcao[1] THEN
                DO:               
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE  :
                  
                      UPDATE tel_tptaxrdc WITH FRAME f_tipo
                                          
                      EDITING:
                         READKEY.
           
                         IF  LASTKEY = KEYCODE("F7") THEN
                             DO:
                                IF FRAME-FIELD = "tel_tptaxrdc" THEN
                                   DO:    
                                      shr_tpaplica = INPUT tel_tptaxrdc.
         
                                      RUN fontes/zoom_tipo_aplica.p.
                          
                                      IF shr_tpaplica <> 0  THEN
                                         DO:     
                                            ASSIGN tel_tptaxrdc = shr_tpaplica.
                                            DISPLAY tel_tptaxrdc 
                                                    WITH FRAME f_tipo.
                                            
                                            NEXT-PROMPT tel_tptaxrdc 
                                                        WITH FRAME f_tipo.
                                         END.
                                   END.     
                             END.
                         ELSE 
                             APPLY LASTKEY.
                        
                      END.    /**Fim EDITING **/
                      
                      FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                        (crapdtc.tpaplrdc = 1            OR 
                                         crapdtc.tpaplrdc = 2)           AND
                                         crapdtc.tpaplica = tel_tptaxrdc 
                                         NO-LOCK NO-ERROR. 
                    
                      IF  AVAIL crapdtc THEN
                          ASSIGN tel_tpaplrdc = crapdtc.tpaplrdc
                                 tel_dsextapl = crapdtc.dsextapl
                                 tel_dsaplica = crapdtc.dsaplica
                                 tel_vlminapl = crapdtc.vlminapl
                                 tel_vlmaxapl = crapdtc.vlmaxapl
                                 tel_flgstrdc = crapdtc.flgstrdc.
                      ELSE
                          DO:
                             glb_cdcritic = 426.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.
                             RUN limpa_tipo.  
                             NEXT.
                          END.

                      IF   tel_tpaplrdc = 2   THEN
                           DO:
                              FIND craptab WHERE 
                                   craptab.cdcooper = glb_cdcooper  AND     
                                   craptab.nmsistem = "CRED"        AND     
                                   craptab.tptabela = "USUARI"      AND     
                                   craptab.cdempres = 11            AND     
                                   craptab.cdacesso = "MXRENDIPOS"  AND     
                                   craptab.tpregist = 1 NO-LOCK NO-ERROR.

                              IF   AVAILABLE craptab   THEN
                                   DO: 
                                       aux_dtfimtax = DATE(ENTRY(2,
                                                         craptab.dstextab,";")).
     
                                      IF   aux_dtfimtax > glb_dtmvtolt   THEN
                                           ASSIGN tel_flgrncdi = TRUE.
                                      ELSE
                                           ASSIGN tel_flgrncdi = FALSE.
                                   END.
                              ELSE
                                   ASSIGN tel_flgrncdi = FALSE.
                           
                              DISPLAY tel_tpaplrdc tel_dsextapl
                                      tel_dsaplica tel_vlminapl
                                      tel_vlmaxapl tel_flgrncdi
                                      tel_flgstrdc WITH FRAME f_tipo.
                           END.
                      ELSE                          
                           DO:
                              /* Somente para tel_tpaplrdc = 2 esta variavel
                                 deve ser visualizada */
                              tel_flgrncdi:VISIBLE IN FRAME f_tipo = FALSE.
                              
                              DISPLAY tel_tpaplrdc tel_dsextapl 
                                      tel_dsaplica tel_vlminapl 
                                      tel_vlmaxapl 
                                      tel_flgstrdc WITH FRAME f_tipo.
                           END.
                   END.  /** Fim WHILE TRUE **/   

                END. /** Fim Consulta Tipos **/
            
            /** Consulta Periodos **/
            IF  FRAME-VALUE = reg_dsdopcao[2] THEN
                DO:
                   
                   RUN limpa_periodos.
                   
                   DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                          
                       UPDATE  tel_tptaxrdc  WITH FRAME f_periodo.
                           
                       FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                         (crapdtc.tpaplrdc = 1            OR 
                                          crapdtc.tpaplrdc = 2)           AND
                                          crapdtc.tpaplica = tel_tptaxrdc 
                                          NO-LOCK NO-ERROR.
                  
                       IF  AVAIL crapdtc THEN
                           DO:     
                               ASSIGN tel_dsaplica = "- " + crapdtc.dsaplica.
                               DISPLAY tel_dsaplica FORMAT "x(8)" 
                                       WITH FRAME f_periodo.
                               
                               RUN carrega_periodos.

                               OPEN QUERY q_periodos 
                                    FOR EACH cratttx WHERE 
                                             cratttx.cdcooper = glb_cdcooper AND
                                             cratttx.tptaxrdc = tel_tptaxrdc
                                             NO-LOCK.
                               DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                   UPDATE b_periodos WITH FRAME f_periodo.     
                               END.
                           END.
                       ELSE
                           DO:
                               glb_cdcritic = 426.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               glb_cdcritic = 0.
                               ASSIGN tel_dsaplica = "".
                               DISPLAY tel_dsaplica WITH FRAME f_periodo.
                               NEXT.
                           END.
                   END. /** Fim DO WHILE TRUE **/
                
                END.  /** Fim consulta periodos **/

            /*** Consulta Faixas ***/
            IF FRAME-VALUE = reg_dsdopcao[3] THEN
               DO:             
                  RUN limpa_faixas. 
                    
                  DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                      UPDATE  tel_tptaxrdc WITH FRAME f_faixas.
                        
                      /*** limpa campo periodo **/
                      ASSIGN tel_cdperapl = 0 
                             tel_dsperapl = "".
                      DISPLAY tel_cdperapl tel_dsperapl WITH FRAME f_faixas.
                      
                      DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
                          FIND crapdtc WHERE 
                                       crapdtc.cdcooper = glb_cdcooper AND
                                      (crapdtc.tpaplrdc = 1            OR 
                                       crapdtc.tpaplrdc = 2)           AND
                                       crapdtc.tpaplica = tel_tptaxrdc
                                       NO-LOCK NO-ERROR.
                        
                          IF AVAIL crapdtc THEN
                             DO:
                             
                                ASSIGN tel_dsaplica = "- " + crapdtc.dsaplica.
                                DISPLAY tel_dsaplica FORMAT "x(8)" 
                                        WITH FRAME f_faixas.
                                
                                UPDATE tel_cdperapl WITH FRAME f_faixas.
                                
                                FIND crapttx WHERE 
                                             crapttx.cdcooper = glb_cdcooper AND
                                             crapttx.tptaxrdc = tel_tptaxrdc AND
                                             crapttx.cdperapl = tel_cdperapl
                                             NO-LOCK NO-ERROR.
                            
                                IF  AVAIL crapttx THEN
                                    DO:
                                        ASSIGN 
                                            tel_dsperapl =  "- "    +
                                            STRING(crapttx.qtdiaini) + " a " +
                                            STRING(crapttx.qtdiafim) + " dias".
                                            DISPLAY tel_dsperapl FORMAT "x(20)"
                                                    WITH FRAME f_faixas.
                                        
                                        RUN carrega_faixas.
                                           
                                        OPEN  QUERY q_faixas 
                                              FOR EACH w_faixas WHERE 
                                                       w_faixas.tptaxrdc = 
                                                       tel_tptaxrdc        AND
                                                       w_faixas.cdperapl = 
                                                       tel_cdperapl 
                                                       BY w_faixas.vlfaxini.
                                       
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                                           UPDATE b_faixas WITH FRAME f_faixas.
                                        END.
                                    END.
                                ELSE
                                    DO:
                                      glb_cdcritic = 892.
                                      RUN fontes/critic.p.
                                      BELL.
                                      MESSAGE glb_dscritic.
                                      glb_cdcritic = 0.
                                      ASSIGN tel_dsperapl = "".
                                      DISPLAY tel_dsperapl WITH FRAME f_faixas.
                                      NEXT.
                                    END.
                             END.
                          ELSE
                              DO:
                                  glb_cdcritic = 426.
                                  RUN fontes/critic.p.
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  glb_cdcritic = 0.
                                  ASSIGN tel_dsaplica = "".
                                  DISPLAY tel_dsaplica WITH FRAME f_faixas.
                                  LEAVE.
                              END.
                       
                      END. /** WHILE TRUE **/                 
                    
                  END. /** Fim do WHILE TRUE **/
               
               END. /** Fim Consulta Faixas **/
            
            /*** Consulta Acumula ***/
            IF  FRAME-VALUE = reg_dsdopcao[4] THEN
                DO:               
                    DO WHILE TRUE:
                    
                       UPDATE tel_tptaxrdc WITH FRAME f_acumula
                       EDITING:
                         READKEY.
           
                         IF  LASTKEY = KEYCODE("F7") THEN
                             DO:
                                IF FRAME-FIELD = "tel_tptaxrdc" THEN
                                   DO:    
                                      shr_tpaplica = INPUT tel_tptaxrdc.
         
                                      RUN fontes/zoom_tipo_aplica.p.
                          
                                      IF shr_tpaplica <> 0  THEN
                                         DO:     
                                            ASSIGN tel_tptaxrdc = shr_tpaplica.
                                            DISPLAY tel_tptaxrdc 
                                                    WITH FRAME f_acumula.
                                            
                                            NEXT-PROMPT tel_tptaxrdc 
                                                        WITH FRAME f_acumula.
                                         END.
                                   END.     
                                   RUN limpa_acumula.
                             END.
                         ELSE 
                             APPLY LASTKEY.
                        
                       END.    /**Fim EDITING **/
                       
                       FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                         (crapdtc.tpaplrdc = 1            OR 
                                          crapdtc.tpaplrdc = 2)           AND
                                          crapdtc.tpaplica = tel_tptaxrdc 
                                          NO-LOCK NO-ERROR.
                       
                       IF  AVAIL crapdtc THEN
                           ASSIGN tel_dsaplica = "- " + crapdtc.dsaplica.
                       ELSE    
                           DO:
                               glb_cdcritic = 426.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               glb_cdcritic = 0.
                               tel_dsaplica = "".
                               RUN limpa_acumula.
                               NEXT.
                           END.                
                       
                       DISPLAY  tel_tptaxrdc 
                                tel_dsaplica FORMAT "x(8)"
                                WITH FRAME f_acumula.
                    
                       FIND FIRST craptab WHERE 
                                  craptab.cdcooper = glb_cdcooper     AND
                                  craptab.nmsistem = "CRED"           AND
                                  craptab.cdempres = tel_tptaxrdc     AND
                                  craptab.tptabela = "GENERI"         AND
                                  craptab.cdacesso = "SOMAPLTAXA"
                                  NO-LOCK NO-ERROR.
                          
                       IF   AVAIL craptab   THEN                         
                            DO:
                                /* FOR EACH para alimentar as variaveis 
                                   que serao  mostradas na tela */
                               FOR EACH craptab WHERE 
                                        craptab.cdcooper = glb_cdcooper     AND
                                        craptab.nmsistem = "CRED"           AND
                                        craptab.cdempres = tel_tptaxrdc     AND
                                        craptab.tptabela = "GENERI"         AND
                                        craptab.cdacesso = "SOMAPLTAXA"
                                        NO-LOCK:
                                    
                                   IF   craptab.tpregist = 0   THEN
                                        DO:
                                            IF  craptab.dstextab = "SIM"  THEN
                                                tel_flgpcapt = TRUE.
                                            ELSE
                                                tel_flgpcapt = FALSE.
                                        END.

                                   IF   craptab.tpregist = 1   THEN
                                        DO:
                                            IF  craptab.dstextab = "SIM"  THEN
                                                tel_flgrdc30 = TRUE.
                                            ELSE
                                                tel_flgrdc30 = FALSE.
                                        END.
            
                                   IF   craptab.tpregist = 2   THEN
                                        DO:
                                            IF  craptab.dstextab = "SIM"   THEN
                                                tel_flgrdmpp = TRUE.
                                            ELSE
                                                tel_flgrdmpp = FALSE.
                                        END.
               
                                   IF   craptab.tpregist = 3   THEN
                                        DO:
                                            IF  craptab.dstextab = "SIM"   THEN
                                                tel_flgrdc60 = TRUE.
                                            ELSE
                                                tel_flgrdc60 = FALSE.
                                        END.
      
                                   IF  craptab.tpregist = 7   THEN
                                       DO:
                                           IF  craptab.dstextab = "SIM"   THEN
                                               tel_flgrdpre = TRUE.
                                           ELSE
                                               tel_flgrdpre = FALSE.
                                       END.
           
                                   IF  craptab.tpregist = 8  THEN
                                       DO:
                                           IF   craptab.dstextab = "SIM"   THEN
                                                tel_flgrdpos = TRUE.
                                           ELSE
                                                tel_flgrdpos = FALSE.
                                       END.
      
                               END. /* Fim do FOR EACH */
          
                               DISPLAY  tel_flgpcapt
                                        tel_flgrdc30
                                        tel_flgrdmpp
                                        tel_flgrdc60
                                        tel_flgrdpre
                                        tel_flgrdpos
                                        WITH FRAME f_acumula.
                            END.
                       ELSE
                          DO:
                              BELL.
                              MESSAGE "Acumulatividade nao cadastrada" 
                                      "para esta aplicacao.".
                              RUN limpa_acumula.
                          END.
                    
                    END.  /** Fim WHILE TRUE **/
                
                END.   /** Fim Consulta Acumula **/

        END. /** Fim IF glb_cddopcao = "C" **/
    
     IF glb_cddopcao = "I" THEN
        DO:   
           /** Inclui Tipos **/
           IF  FRAME-VALUE = reg_dsdopcao[1] THEN
               DO:
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                     UPDATE tel_tptaxrdc WITH FRAME f_tipo
                     EDITING:
                          READKEY.
           
                          IF LASTKEY = KEYCODE("F7") THEN
                             DO:
                                IF FRAME-FIELD = "tel_tptaxrdc" THEN
                                   DO:      
                                      shr_tpaplica = INPUT tel_tptaxrdc.
                                      RUN fontes/zoom_tipo_aplica.p.
                          
                                      IF shr_tpaplica <> 0  THEN
                                         DO:     
                                            ASSIGN tel_tptaxrdc = shr_tpaplica.
                                            DISPLAY tel_tptaxrdc 
                                                    WITH FRAME f_tipo.
                                            
                                            NEXT-PROMPT tel_tptaxrdc 
                                                        WITH FRAME f_tipo.
                                         END.
                                   END.     
                             END.
                          ELSE 
                              APPLY LASTKEY.
                     END. /**Fim EDITING **/
    
                     tel_flgrncdi:VISIBLE IN FRAME f_tipo = FALSE.                   
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                  
                        IF CAN-DO("1,2,3,4,5,6", STRING(tel_tptaxrdc)) THEN
                           DO:
                              ASSIGN glb_cdcritic = 873.
                              RUN fontes/critic.p.
                              RUN limpa_tipo.
                              BELL.
                              MESSAGE glb_dscritic.
                              LEAVE.
                           END.
                  
                        FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                          (crapdtc.tpaplrdc = 1            OR 
                                           crapdtc.tpaplrdc = 2)           AND
                                           crapdtc.tpaplica = tel_tptaxrdc 
                                           NO-LOCK NO-ERROR.
                    
                        IF  NOT AVAIL crapdtc THEN
                            DO:

                               RUN limpa_tipo.
                               
                               UPDATE tel_tpaplrdc WITH FRAME f_tipo.
                               
                               /* Remunera maior CDI/POUP apenas quando for
                                  RDCPOS */
                               IF   tel_tpaplrdc = 2   THEN
                                    DO:
                                        UPDATE tel_dsextapl tel_dsaplica  
                                               tel_vlminapl tel_vlmaxapl  
                                               tel_flgstrdc tel_flgrncdi  
                                               WITH FRAME f_tipo.
                                       
                                        RUN proc_renumera_cdi.
                                    END.
                               ELSE
                                    UPDATE tel_dsextapl tel_dsaplica  
                                           tel_vlminapl tel_vlmaxapl  
                                           tel_flgstrdc WITH FRAME f_tipo.

                               IF   glb_cdcritic > 0   THEN
                                    DO:
                                       RUN fontes/critic.p.
                                       RUN limpa_tipo.
                                       BELL.
                                       MESSAGE glb_dscritic.
                                       LEAVE.
                                    END.
                                    
                               FIND FIRST crapdtc WHERE 
                                          crapdtc.cdcooper = glb_cdcooper AND
                                         (crapdtc.tpaplrdc = 1            OR 
                                          crapdtc.tpaplrdc = 2)           AND
                                          crapdtc.tpaplrdc = tel_tpaplrdc
                                          NO-LOCK NO-ERROR.
                               
                               IF  AVAIL crapdtc THEN 
                                   DO:
                                        glb_cdcritic = 894.
                                        RUN fontes/critic.p.
                                        BELL.
                                        MESSAGE glb_dscritic.
                                        glb_cdcritic = 0.
                                        NEXT.
                                   END.
                                      
                               CREATE crapdtc.
                               ASSIGN crapdtc.cdcooper = glb_cdcooper 
                                      crapdtc.tpaplica = tel_tptaxrdc
                                      crapdtc.tpaplrdc = tel_tpaplrdc
                                      crapdtc.dsextapl = UPPER(tel_dsextapl)
                                      crapdtc.dsaplica = UPPER(tel_dsaplica)
                                      crapdtc.vlminapl = tel_vlminapl
                                      crapdtc.vlmaxapl = tel_vlmaxapl
                                      crapdtc.flgstrdc = tel_flgstrdc.

                               VALIDATE crapdtc.

                               LEAVE.
                            END.
                        ELSE 
                            DO:
                                ASSIGN glb_cdcritic = 873.
                                RUN fontes/critic.p.
                                RUN limpa_tipo.
                                BELL.
                                MESSAGE glb_dscritic.
                                LEAVE.
                            END.
                     END. /** Fim WHILE TRUE **/
                  END. /** Fim WHILE TRUE **/
               END.  /** Fim Inclui Tipos **/
           
           /** Inclui Periodos **/
           IF  FRAME-VALUE = reg_dsdopcao[2] THEN
               DO:   
                  DO  WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                      ASSIGN tel_tptaxrdc = 0.

                      CLEAR FRAME f_inclui_periodo.
                      
                      UPDATE tel_tptaxrdc WITH FRAME f_inclui_periodo.
                      
                      FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                        (crapdtc.tpaplrdc = 1            OR 
                                         crapdtc.tpaplrdc = 2)           AND
                                         crapdtc.tpaplica = tel_tptaxrdc 
                                         NO-LOCK  NO-ERROR.
                      
                      IF AVAIL crapdtc THEN
                         DO:     
                             RUN carrega_periodos.
                                              
                             DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                     
                                 ASSIGN  tel_cdperapl = 0
                                         tel_qtdiacar = 0
                                         tel_qtdiaini = 0 
                                         tel_qtdiafim = 0.
                                 
                                 DISPLAY tel_qtdiacar 
                                         WITH FRAME f_inclui_periodo.    
                                 
                                 IF  crapdtc.tpaplrdc = 1 THEN   /**RDCPRE**/
                                     DO:
                                        FIND LAST  crapttx WHERE 
                                                   crapttx.cdcooper =
                                                             glb_cdcooper AND
                                                   crapttx.tptaxrdc = 
                                                             tel_tptaxrdc 
                                                   NO-LOCK NO-ERROR.
                                        IF AVAIL crapttx THEN
                                           ASSIGN 
                                                   tel_cdperapl =
                                                           crapttx.cdperapl + 1
                                                   tel_qtdiaini =
                                                           crapttx.qtdiafim + 1.
                                        ELSE
                                            ASSIGN tel_cdperapl = 1
                                                   tel_qtdiaini = 1.
                                            
                                        DISPLAY tel_cdperapl 
                                                tel_qtdiaini
                                                WITH FRAME f_inclui_periodo.
                                        
                                        UPDATE  tel_qtdiafim 
                                                WITH FRAME f_inclui_periodo.
                                     
                                     END.
                                 ELSE            /**Aplicacao RDCPOS**/
                                     UPDATE  tel_cdperapl
                                             tel_qtdiacar 
                                             tel_qtdiaini
                                             tel_qtdiafim 
                                             WITH FRAME f_inclui_periodo.
                                
                                 FIND crapttx WHERE 
                                      crapttx.cdcooper = glb_cdcooper AND
                                      crapttx.tptaxrdc = tel_tptaxrdc AND
                                      crapttx.cdperapl = tel_cdperapl
                                      NO-LOCK NO-ERROR.
                                 
                                 IF  AVAIL crapttx THEN
                                     DO:
                                        MESSAGE "Periodo ja existente!".
                                        BELL.
                                        NEXT.
                                     END.
                                 
                                 IF  tel_cdperapl = 0 THEN
                                     DO:
                                        MESSAGE 
                                             "Periodo deve ser maior que '0'.".
                                        BELL.
                                        NEXT.
                                     END.
                                 
                                 IF  tel_qtdiafim < tel_qtdiaini OR
                                     tel_qtdiafim = 0            THEN
                                     DO:
                                        glb_cdcritic = 895.
                                        RUN fontes/critic.p.
                                        BELL.
                                        MESSAGE glb_dscritic.
                                        glb_cdcritic = 0.
                                        NEXT.
                                     END.
                                 
                                 CREATE crapttx.
                                 ASSIGN crapttx.cdcooper = glb_cdcooper
                                        crapttx.tptaxrdc = tel_tptaxrdc
                                        crapttx.cdperapl = tel_cdperapl
                                        crapttx.qtdiacar = tel_qtdiacar
                                        crapttx.qtdiaini = tel_qtdiaini
                                        crapttx.qtdiafim = tel_qtdiafim.

                                 VALIDATE crapttx.

                                 RUN gera_log_periodo.
                             
                             END. /** Fim WHILE TRUE **/
                            
                             EMPTY TEMP-TABLE cratttx.
                         END.
                      ELSE
                          DO:
                               glb_cdcritic = 426.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               glb_cdcritic = 0.
                               NEXT.                       
                          END.
                      
                  END. /** Fim WHILE TRUE **/
               END.  /** Fim Inclui Periodos **/
           
           /** Inclui Faixas **/
           IF FRAME-VALUE = reg_dsdopcao[3] THEN
              DO:
                 RUN limpa_faixas.
                 DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:  
                     UPDATE  tel_tptaxrdc WITH FRAME f_faixas.
                   
                     CLOSE QUERY q_faixas.
                     
                     ASSIGN  tel_cdperapl = 0
                             tel_dsperapl = "".
                     DISPLAY tel_dsperapl WITH FRAME f_faixas. 
                     
                     DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                         
                         FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                           (crapdtc.tpaplrdc = 1            OR 
                                            crapdtc.tpaplrdc = 2)           AND
                                            crapdtc.tpaplica = tel_tptaxrdc
                                            NO-LOCK NO-ERROR.
                                           
                         IF AVAIL crapdtc THEN
                            DO:
                               ASSIGN tel_dsaplica = "- " + crapdtc.dsaplica.
                               DISPLAY tel_dsaplica FORMAT "x(8)" 
                                        WITH FRAME f_faixas.
                               
                               UPDATE tel_cdperapl WITH FRAME f_faixas.
                               
                               FIND crapttx WHERE 
                                            crapttx.cdcooper = glb_cdcooper AND
                                            crapttx.tptaxrdc = tel_tptaxrdc AND
                                            crapttx.cdperapl = tel_cdperapl
                                            NO-LOCK NO-ERROR.
                                           
                               IF  AVAIL crapttx THEN
                                   DO:
                                       ASSIGN 
                                          tel_dsperapl =  "- "    +
                                          STRING(crapttx.qtdiaini) + " a " +
                                          STRING(crapttx.qtdiafim) + " dias".
                                          DISPLAY tel_dsperapl FORMAT "x(20)"
                                          WITH FRAME f_faixas.
                                       
                                       RUN carrega_faixas.
                                    
                                       OPEN  QUERY q_faixas 
                                                   FOR EACH w_faixas WHERE 
                                                   w_faixas.tptaxrdc = 
                                                            tel_tptaxrdc AND
                                                   w_faixas.cdperapl =
                                                            tel_cdperapl 
                                                   BY w_faixas.vlfaxini.
                                        
                                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                                          UPDATE b_faixas WITH FRAME f_faixas. 
                                       END. 
                                   END.
                               ELSE
                                   DO:
                                       glb_cdcritic = 892.
                                       RUN fontes/critic.p.
                                       BELL.
                                       MESSAGE glb_dscritic.
                                       glb_cdcritic = 0.
                                       ASSIGN tel_dsperapl = "".
                                       DISPLAY tel_dsperapl WITH FRAME f_faixas.
                                       NEXT.
                                   END.
                            END.
                         ELSE
                            DO:
                                glb_cdcritic = 426.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                ASSIGN  tel_dsaplica = ""
                                        tel_cdperapl = 0.
                                DISPLAY tel_cdperapl 
                                        tel_dsaplica WITH FRAME f_faixas.
                                LEAVE.
                            END.

                     END. /** Fim WHILE TRUE  **/
                 END. /** Fim WHILE TRUE **/
              END.  /** Fim Inclui Faixas **/
        
           /** Inclui Acumula **/
           IF  FRAME-VALUE = reg_dsdopcao[4] THEN
               DO:
                   DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       RUN limpa_acumula.
                       
                       UPDATE tel_tptaxrdc WITH FRAME f_acumula 
                       EDITING:
                          READKEY.
           
                          IF LASTKEY = KEYCODE("F7") THEN
                             DO:
                                IF FRAME-FIELD = "tel_tptaxrdc" THEN
                                   DO:    
                                      shr_tpaplica = INPUT tel_tptaxrdc.
         
                                      RUN fontes/zoom_tipo_aplica.p.
                          
                                      IF shr_tpaplica <> 0  THEN
                                         DO:     
                                            ASSIGN tel_tptaxrdc = shr_tpaplica.
                                            DISPLAY tel_tptaxrdc 
                                                    WITH FRAME f_acumula.
                                            
                                            NEXT-PROMPT tel_tptaxrdc 
                                                        WITH FRAME f_acumula.
                                         END.
                                         RUN limpa_acumula.
                                   END.     
                             END.
                          ELSE 
                             APPLY LASTKEY.
                        
                       END.    /**Fim EDITING **/
                      
                       FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                         (crapdtc.tpaplrdc = 1            OR 
                                          crapdtc.tpaplrdc = 2)           AND
                                          crapdtc.tpaplica = tel_tptaxrdc
                                          NO-LOCK NO-ERROR.
                       IF  AVAIL crapdtc THEN
                           RUN inclui_acumula.
                       ELSE
                           DO:
                               glb_cdcritic = 426.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               glb_cdcritic = 0.
                               tel_dsaplica = "".
                               RUN limpa_acumula.  
                               NEXT.
                           END.
                       
                   END. /** Fim WHILE TRUE **/
               END. /** Fim Inclui Acumula **/ 
        END. /** Fim IF "I" **/
       
     IF glb_cddopcao = "A" THEN
        DO: 
              /** Altera Tipo **/
           IF  FRAME-VALUE = reg_dsdopcao[1] THEN
               DO:
                  DO WHILE TRUE  ON ENDKEY UNDO, LEAVE  :
                     
                     UPDATE tel_tptaxrdc WITH FRAME f_tipo
                    
                     EDITING:
                         READKEY.
           
                         IF  LASTKEY = KEYCODE("F7") THEN
                             DO:
                                IF FRAME-FIELD = "tel_tptaxrdc" THEN
                                   DO:    
                                      shr_tpaplica = INPUT tel_tptaxrdc.
         
                                      RUN fontes/zoom_tipo_aplica.p.
                          
                                      IF shr_tpaplica <> 0  THEN
                                         DO:     
                                            ASSIGN tel_tptaxrdc = shr_tpaplica.
                                            DISPLAY tel_tptaxrdc 
                                                    WITH FRAME f_tipo.
                                            
                                            NEXT-PROMPT tel_tptaxrdc 
                                                        WITH FRAME f_tipo.
                                         END.
                                   END.     
                             END.
                         ELSE 
                            APPLY LASTKEY.
                      
                     END.    /**Fim EDITING **/
                     
                     tel_flgrncdi:VISIBLE IN FRAME f_tipo = FALSE.
                     
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE TRANSACTION:
                    
                        DO aux_contador = 1 TO 10:
                        
                           FIND crapdtc WHERE 
                                crapdtc.cdcooper = glb_cdcooper AND
                               (crapdtc.tpaplrdc = 1            OR 
                                crapdtc.tpaplrdc = 2)           AND
                                crapdtc.tpaplica = tel_tptaxrdc 
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 
                    
                           IF  AVAIL crapdtc THEN
                               ASSIGN tel_tpaplrdc = crapdtc.tpaplrdc
                                      tel_dsextapl = crapdtc.dsextapl
                                      tel_dsaplica = crapdtc.dsaplica
                                      tel_vlminapl = crapdtc.vlminapl
                                      tel_vlmaxapl = crapdtc.vlmaxapl
                                      tel_flgstrdc = crapdtc.flgstrdc
                                      
                                      glb_cdcritic = 0.
                           ELSE    
                               IF   LOCKED crapdtc   THEN
                                    DO:
                                        RUN sistema/generico/procedures/b1wgen9999.p
                                        PERSISTENT SET h-b1wgen9999.
                                        
                                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapdtc),
                                        					 INPUT "banco",
                                        					 INPUT "crapdtc",
                                        					 OUTPUT par_loginusr,
                                        					 OUTPUT par_nmusuari,
                                        					 OUTPUT par_dsdevice,
                                        					 OUTPUT par_dtconnec,
                                        					 OUTPUT par_numipusr).
                                        
                                        DELETE PROCEDURE h-b1wgen9999.
                                        
                                        ASSIGN aux_dadosusr = 
                                        "077 - Tabela sendo alterada p/ outro terminal.".
                                        
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        MESSAGE aux_dadosusr.
                                        PAUSE 3 NO-MESSAGE.
                                        LEAVE.
                                        END.
                                        
                                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                        			  " - " + par_nmusuari + ".".
                                        
                                        HIDE MESSAGE NO-PAUSE.
                                        
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        MESSAGE aux_dadosusr.
                                        PAUSE 5 NO-MESSAGE.
                                        LEAVE.
                                        END.

                                       NEXT.
                                    END.
                               ELSE
                                    glb_cdcritic = 426.
                              
                        END. /* Fim do DO TO */       
                        
                        IF   glb_cdcritic > 0   THEN
                             DO:
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                RUN limpa_tipo.
                                LEAVE.
                             END.   

                        /* Calcular primeiro dia util do mes. Pode-se alterar
                           o campo Renumera Maior Cdi/Poup apenas no primeiro
                           dia util do mes */
                        ASSIGN aux_dtcalcul = DATE(MONTH(glb_dtmvtolt),01,
                                                           YEAR(glb_dtmvtolt)).
                  
                        DO WHILE TRUE:
                           IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtcalcul)))  OR
                               CAN-FIND(crapfer WHERE 
                                        crapfer.cdcooper = glb_cdcooper AND
                                        crapfer.dtferiad = aux_dtcalcul   ) THEN
                               DO:
                                  ASSIGN aux_dtcalcul = aux_dtcalcul + 1.
                                  NEXT.
                               END.
                          
                           LEAVE.
                        END.  /*  Fim do DO WHILE TRUE  */

                        IF   tel_tpaplrdc = 2   THEN
                             DO:
                                FIND craptab WHERE 
                                     craptab.cdcooper = glb_cdcooper  AND     
                                     craptab.nmsistem = "CRED"        AND     
                                     craptab.tptabela = "USUARI"      AND     
                                     craptab.cdempres = 11            AND     
                                     craptab.cdacesso = "MXRENDIPOS"  AND     
                                     craptab.tpregist = 1 NO-LOCK NO-ERROR.

                                IF   AVAILABLE craptab   THEN
                                     DO: 
                                         aux_dtfimtax = DATE(ENTRY(2,
                                                         craptab.dstextab,";")).
     
                                        IF   aux_dtfimtax > glb_dtmvtolt   THEN
                                             ASSIGN tel_flgrncdi = TRUE
                                                    aux_flgalter = TRUE.
                                        ELSE
                                             ASSIGN tel_flgrncdi = FALSE.
                                     
                                        
                                     END.
                                ELSE
                                     ASSIGN tel_flgrncdi = FALSE
                                            aux_flgalter = TRUE.
                             
                                IF   aux_dtcalcul <> glb_dtmvtolt   THEN
                                     MESSAGE "Alterar renumeracao Cdi/Poup"
                                          "apenas no primeiro dia util do mes.".
                             
                                DISPLAY tel_flgrncdi WITH FRAME f_tipo.
                             END.

                        /* Se nao exister a craptab ou exister e a data do fim
                           da vigencia for maior que a atual, entao o craptab
                           pode ser criada/alterada - somente para
                           tel_tpaplrdc = 2 - apenas primeiro dia util do mes*/
                        IF   aux_flgalter AND aux_dtcalcul = glb_dtmvtolt  THEN
                             DO:
                                ASSIGN aux_flgalter = FALSE.
                                
                                UPDATE  tel_tpaplrdc  tel_dsextapl
                                        tel_dsaplica  tel_vlminapl
                                        tel_vlmaxapl  tel_flgstrdc
                                        tel_flgrncdi  WITH FRAME f_tipo.

                                /* cria/altera craptab */
                                RUN proc_renumera_cdi.
                             END.
                        ELSE 
                             /* Demais tipos de aplicacoes */
                             UPDATE  tel_tpaplrdc  tel_dsextapl
                                     tel_dsaplica  tel_vlminapl
                                     tel_vlmaxapl  tel_flgstrdc
                                     WITH FRAME f_tipo.
                        
                        IF   glb_cdcritic > 0   THEN
                             DO:
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                RUN limpa_tipo.
                                LEAVE.
                             END.
                        
                        /***Verifica se ja existe uma aplicacao pre ou pos ***/ 
                        FIND FIRST crabdtc WHERE 
                                           crabdtc.cdcooper =  glb_cdcooper AND
                                           crabdtc.tpaplica <> tel_tptaxrdc AND
                                           crabdtc.tpaplrdc =  tel_tpaplrdc
                                           NO-LOCK NO-ERROR.
                          
                        IF  AVAIL crabdtc THEN 
                            DO:
                               glb_cdcritic = 894.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               glb_cdcritic = 0.
                               NEXT.
                            END.

                        ASSIGN crapdtc.tpaplrdc = tel_tpaplrdc
                               crapdtc.dsextapl = UPPER(tel_dsextapl) 
                               crapdtc.dsaplica = UPPER(tel_dsaplica) 
                               crapdtc.vlminapl = tel_vlminapl
                               crapdtc.vlmaxapl = tel_vlmaxapl
                               crapdtc.flgstrdc = tel_flgstrdc.
                        LEAVE.
                     END.
                  END. /** Fim do WHILE TRUE **/
               END.  /** Fim Altera Tipos **/
           
               /** Altera Periodo **/
           IF  FRAME-VALUE = reg_dsdopcao[2] THEN
               DO:
                   RUN limpa_periodos.
                       
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                   
                      UPDATE  tel_tptaxrdc WITH FRAME f_periodo.
                              
                      FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                        (crapdtc.tpaplrdc = 1            OR 
                                         crapdtc.tpaplrdc = 2)           AND
                                         crapdtc.tpaplica = tel_tptaxrdc 
                                         NO-LOCK NO-ERROR.
                  
                      IF AVAIL crapdtc THEN
                         DO:
                             ASSIGN tel_dsaplica = "- " + crapdtc.dsaplica.
                             DISPLAY tel_dsaplica FORMAT "x(8)" 
                                     WITH FRAME f_periodo.
                             
                             RUN carrega_periodos.
                                
                             OPEN QUERY q_periodos 
                                  FOR EACH cratttx WHERE 
                                           cratttx.cdcooper = glb_cdcooper AND
                                           cratttx.tptaxrdc = tel_tptaxrdc
                                           NO-LOCK.
                                   
                             DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:       
                                 UPDATE b_periodos WITH FRAME f_periodo.
                             END.
                         END.
                      ELSE
                          DO:
                              glb_cdcritic = 426.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              CLOSE QUERY q_periodos.
                              ASSIGN tel_dsaplica = "".
                              DISPLAY tel_dsaplica WITH FRAME f_periodo.
                              NEXT.
                          END.
                       
                   END. /** fim do WHILE TRUE **/     
               END.  /** Fim Altera Periodos **/ 
               
           /** Altera Faixas **/
           IF  FRAME-VALUE = reg_dsdopcao[3] THEN
               DO:
                  RUN limpa_faixas.
                  
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
                     EMPTY TEMP-TABLE cratftx.

                     UPDATE tel_tptaxrdc WITH FRAME f_faixas.
                     
                     /** limpa campos do periodo **/
                     ASSIGN  tel_cdperapl = 0
                             tel_dsperapl = "". 
                     DISPLAY tel_cdperapl tel_dsperapl WITH FRAME f_faixas.
                      
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                
                        FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                          (crapdtc.tpaplrdc = 1            OR 
                                           crapdtc.tpaplrdc = 2)           AND
                                           crapdtc.tpaplica = tel_tptaxrdc
                                           NO-LOCK NO-ERROR.
                  
                        IF AVAIL crapdtc THEN
                           DO:
                               ASSIGN tel_dsaplica = "- " + crapdtc.dsaplica.
                               DISPLAY tel_dsaplica FORMAT "x(8)" 
                                       WITH FRAME f_faixas.
                               
                               UPDATE tel_cdperapl WITH FRAME f_faixas.                               
                               FIND crapttx WHERE 
                                            crapttx.cdcooper = glb_cdcooper AND
                                            crapttx.tptaxrdc = tel_tptaxrdc AND
                                            crapttx.cdperapl = tel_cdperapl
                                            NO-LOCK NO-ERROR.
                         
                               IF  AVAIL crapttx THEN 
                                   DO:
                                       ASSIGN 
                                       tel_dsperapl =  "- "          +
                                            STRING(crapttx.qtdiaini) + " a " +
                                            STRING(crapttx.qtdiafim) + " dias".
                                            DISPLAY tel_dsperapl FORMAT "x(20)"
                                                    WITH FRAME f_faixas.
                                       
                                       RUN carrega_faixas.
                  
                                       OPEN  QUERY q_faixas 
                                             FOR EACH w_faixas WHERE 
                                                      w_faixas.tptaxrdc = 
                                                               tel_tptaxrdc AND
                                                      w_faixas.cdperapl = 
                                                               tel_cdperapl 
                                                      BY w_faixas.vlfaxini.
                                  
                                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                          UPDATE  b_faixas WITH FRAME f_faixas. 
                                       END.
                                    
                                   END.
                               ELSE
                                   DO:
                                        glb_cdcritic = 892.
                                        RUN fontes/critic.p.
                                        BELL.
                                        MESSAGE glb_dscritic.
                                        glb_cdcritic = 0.
                                        ASSIGN tel_dsperapl = "".
                                        DISPLAY tel_dsperapl 
                                                WITH FRAME f_faixas. 
                                        NEXT.
                                   END.
                           END.
                        ELSE
                           DO:
                              glb_cdcritic = 426.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              ASSIGN tel_dsaplica = "".
                              DISPLAY tel_dsaplica WITH FRAME f_faixas.
                              LEAVE.                       
                           END.     
                     
                     END. /** FIM  WHILE TRUE **/
                  END. /** Fim WHILE TRUE **/
               END. /** Fim Altera Faixas **/
        
           /** Altera Acumula **/
           IF  FRAME-VALUE = reg_dsdopcao[4] THEN
               DO:
                   DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       RUN limpa_acumula.
                       
                       UPDATE tel_tptaxrdc WITH FRAME f_acumula 
                       EDITING:
                          READKEY.
           
                          IF LASTKEY = KEYCODE("F7") THEN
                             DO:
                                IF FRAME-FIELD = "tel_tptaxrdc" THEN
                                   DO:    
                                      shr_tpaplica = INPUT tel_tptaxrdc.
         
                                      RUN fontes/zoom_tipo_aplica.p.
                          
                                      IF shr_tpaplica <> 0  THEN
                                         DO:     
                                            ASSIGN tel_tptaxrdc = shr_tpaplica.
                                            DISPLAY tel_tptaxrdc 
                                                    WITH FRAME f_acumula.
                                            
                                            NEXT-PROMPT tel_tptaxrdc 
                                                        WITH FRAME f_acumula.
                                         END.
                                      RUN limpa_acumula.
                                   END.     
                             END.
                          ELSE 
                             APPLY LASTKEY.
                        
                       END.    /**Fim EDITING **/
                       RUN limpa_acumula.
                       
                       FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                         (crapdtc.tpaplrdc = 1            OR 
                                          crapdtc.tpaplrdc = 2)           AND
                                          crapdtc.tpaplica = tel_tptaxrdc
                                          NO-LOCK NO-ERROR.
                       
                       IF  AVAIL crapdtc THEN
                           RUN altera_acumula. 
                       ELSE
                           DO:
                               glb_cdcritic = 426.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               glb_cdcritic = 0.
                               tel_dsaplica = "".
                               RUN limpa_acumula.  
                               NEXT.
                           END.
                       
                   END. /** Fim WHILE TRUE **/  
               END.  /** Fim Altera Acumula **/   
        
        END. /** Fim "A" **/

     IF glb_cddopcao = "E" THEN
        DO:    /** Exclui Tipo **/
            IF  FRAME-VALUE = reg_dsdopcao[1] THEN
                DO:
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      UPDATE tel_tptaxrdc WITH FRAME f_tipo.
                    
                      FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                        (crapdtc.tpaplrdc = 1            OR 
                                         crapdtc.tpaplrdc = 2)           AND
                                         crapdtc.tpaplica = tel_tptaxrdc 
                                         EXCLUSIVE-LOCK NO-ERROR. 
                    
                      IF  AVAIL crapdtc THEN
                          ASSIGN tel_tpaplrdc = crapdtc.tpaplrdc
                                 tel_dsextapl = crapdtc.dsextapl
                                 tel_dsaplica = crapdtc.dsaplica
                                 tel_vlminapl = crapdtc.vlminapl
                                 tel_vlmaxapl = crapdtc.vlmaxapl
                                 tel_flgstrdc = crapdtc.flgstrdc.
                      ELSE
                          DO:
                              glb_cdcritic = 426.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              RUN limpa_tipo.   
                              NEXT.
                          END.
                                                
                      DISPLAY tel_tpaplrdc tel_dsextapl 
                              tel_dsaplica tel_vlminapl 
                              tel_vlmaxapl tel_flgstrdc 
                              WITH FRAME f_tipo.
                                                      
                      FIND FIRST crapttx WHERE 
                                         crapttx.cdcooper = glb_cdcooper AND
                                         crapttx.tptaxrdc = tel_tptaxrdc
                                         NO-LOCK NO-ERROR.
                    
                      IF  AVAIL crapttx THEN
                          DO:
                              glb_cdcritic = 898.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              NEXT.
                          END.
                        
                      RUN confirma.
                        
                      IF  aux_confirma <> "S"   THEN
                          DO:
                              glb_cdcritic = 0.
                              NEXT.
                          END.
                 
                      DELETE crapdtc.                     
                      ASSIGN tel_tptaxrdc = 0.
                      RUN limpa_tipo.
                   END. /** Fim WHILE TRUE **/
                END. /** Fim Exclui Tipo **/
            
             /** Exclui Periodos **/
            IF  FRAME-VALUE = reg_dsdopcao[2] THEN
                DO:
                   RUN limpa_periodos.
                   
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      
                      UPDATE  tel_tptaxrdc    
                              WITH FRAME f_periodo.
                      
                      FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                        (crapdtc.tpaplrdc = 1            OR 
                                         crapdtc.tpaplrdc = 2)           AND
                                         crapdtc.tpaplica = tel_tptaxrdc 
                                         NO-LOCK NO-ERROR.
                  
                      IF AVAIL crapdtc THEN
                         DO:
                            ASSIGN  tel_dsaplica = "- " + crapdtc.dsaplica.
                            DISPLAY tel_dsaplica FORMAT "x(8)" 
                                    WITH FRAME f_periodo.
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                               
                               EMPTY TEMP-TABLE cratttx.
                               RUN carrega_periodos.
                                
                               OPEN QUERY q_periodos 
                                    FOR EACH cratttx WHERE 
                                             cratttx.cdcooper = glb_cdcooper AND
                                             cratttx.tptaxrdc = tel_tptaxrdc
                                             NO-LOCK BY cratttx.cdperapl.
                                   
                               DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:       
                                   UPDATE b_periodos WITH FRAME f_periodo.
                               END.
                                       
                               LEAVE.
                            END. /** fim WHILE TRUE **/
                         END.
                      ELSE
                          DO:
                              glb_cdcritic = 426.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              ASSIGN tel_dsaplica = "".
                              DISPLAY tel_dsaplica WITH FRAME f_periodo.
                              NEXT.
                          END.
                   END. /** Fim WHILE TRUE **/
                END. /** Fim Exclui Periodos **/
            
            /** Exclui Faixas **/            
            IF  FRAME-VALUE = reg_dsdopcao[3] THEN
                DO:             
                   RUN limpa_faixas. 
                    
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                      EMPTY TEMP-TABLE cratftx.

                      UPDATE  tel_tptaxrdc WITH FRAME f_faixas.
                      
                      /*** limpa campo periodo  ***/                  
                      ASSIGN  tel_cdperapl = 0 
                              tel_dsperapl = "".
                      DISPLAY tel_cdperapl 
                              tel_dsperapl WITH FRAME f_faixas.  
                      
                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                         FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                                           (crapdtc.tpaplrdc = 1            OR 
                                            crapdtc.tpaplrdc = 2)           AND
                                            crapdtc.tpaplica = tel_tptaxrdc
                                            NO-LOCK NO-ERROR.
                         
                         IF AVAIL crapdtc THEN
                            DO:
                               ASSIGN tel_dsaplica = "- " + crapdtc.dsaplica.
                               DISPLAY tel_dsaplica FORMAT "x(8)" 
                                       WITH FRAME f_faixas.
                               
                               UPDATE  tel_cdperapl WITH FRAME f_faixas.
                               
                               FIND crapttx WHERE 
                                            crapttx.cdcooper = glb_cdcooper AND
                                            crapttx.tptaxrdc = tel_tptaxrdc AND
                                            crapttx.cdperapl = tel_cdperapl
                                            NO-LOCK NO-ERROR.
                            
                               IF AVAIL crapttx THEN
                                  DO:
                                     ASSIGN tel_dsperapl =  "- "    +
                                            STRING(crapttx.qtdiaini) + " a " +
                                            STRING(crapttx.qtdiafim) + " dias".
                                            DISPLAY tel_dsperapl FORMAT "x(20)"
                                            WITH FRAME f_faixas.
                                     
                                     RUN carrega_faixas.
                                       
                                     OPEN  QUERY q_faixas 
                                           FOR EACH w_faixas WHERE 
                                                    w_faixas.tptaxrdc = 
                                                               tel_tptaxrdc AND
                                                    w_faixas.cdperapl = 
                                                               tel_cdperapl 
                                                    BY w_faixas.vlfaxini.
                                        
                                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        UPDATE b_faixas WITH FRAME f_faixas.   
                                     END.      

                                  END.
                               ELSE
                                  DO:
                                       glb_cdcritic = 892.
                                       RUN fontes/critic.p.
                                       BELL.
                                       MESSAGE glb_dscritic.
                                       glb_cdcritic = 0.
                                       ASSIGN tel_dsperapl = "".
                                       DISPLAY tel_dsperapl WITH FRAME f_faixas.
                                       NEXT.
                                  END.
                            END.
                         ELSE
                             DO:
                                glb_cdcritic = 426.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                ASSIGN tel_dsaplica = "".
                                DISPLAY tel_dsaplica WITH FRAME f_faixas.
                                LEAVE.                         
                             END.
                       
                      END. /** Fim WHILE TRUE  **/             
                   END. /** Fim WHILE TRUE **/
                END.  /** Fim Exclui Faixas **/      
            
            /** Exclui Acumula **/
            IF  FRAME-VALUE = reg_dsdopcao[4] THEN
                DO:
                    BELL.
                    MESSAGE "Nao eh possivel excluir acumulatividade das"
                            "aplicacoes.".
                    PAUSE 3 NO-MESSAGE.
                END. /** Fim Exclui Acumula **/       
        
        END. /** Fim IF "E" **/     
   END.  
   
END.

 /***************************PROCEDURES***************************************/

PROCEDURE produtos-rdcpos:

    DEF VAR aux_contador AS INTE  INIT 0                                NO-UNDO.
    DEF VAR aux_contado2 AS INTE  INIT 0                                NO-UNDO.

    EMPTY TEMP-TABLE tt-rdcpos.

    VIEW FRAME f_produtos-rdcpos-cabecalho.

    FOR EACH crapdtc WHERE crapdtc.cdcooper = glb_cdcooper AND
                           crapdtc.tpaplrdc = 3            NO-LOCK:

        CREATE tt-rdcpos.
        ASSIGN tt-rdcpos.dsaplica = crapdtc.dsaplica 
               tt-rdcpos.qtinicar = crapdtc.qtdiacar
               tt-rdcpos.qtfincar = crapdtc.qtmaxcar
               tt-rdcpos.vliniapl = crapdtc.vlminapl  
               tt-rdcpos.vlfinapl = crapdtc.vlmaxapl
               tt-rdcpos.tpaplica = crapdtc.tpaplica
               aux_contador       = aux_contador + 1.         

        CREATE tt-rdcpos-log.
        BUFFER-COPY tt-rdcpos TO tt-rdcpos-log.

    END.

    DO WHILE aux_contador < 4: /* 4 Produtos Fixo */

        CREATE tt-rdcpos.
        ASSIGN tt-rdcpos.dsaplica = ""
               tt-rdcpos.qtinicar = 0
               tt-rdcpos.qtfincar = 0
               tt-rdcpos.vliniapl = 0
               tt-rdcpos.vlfinapl = 0
               tt-rdcpos.tpaplica = 0
               aux_contador       = aux_contador + 1.

    END.

    FOR EACH tt-rdcpos NO-LOCK:

        DISPLAY tt-rdcpos.dsaplica
                tt-rdcpos.qtinicar
                tt-rdcpos.qtfincar
                tt-rdcpos.vliniapl
                tt-rdcpos.vlfinapl WITH FRAME f_produtos-rdcpos.

        ASSIGN aux_contado2 = aux_contado2 + 1.

        IF  aux_contado2 = aux_contador THEN
            LEAVE.

        DOWN WITH FRAME f_produtos-rdcpos. 
            
    END.

    ASSIGN aux_contado2 = 0.

    FOR EACH tt-rdcpos NO-LOCK.

        ASSIGN aux_contado2 = aux_contado2 + 1.

        IF  aux_contado2 = aux_contador THEN
            LEAVE.

        UP WITH FRAME f_produtos-rdcpos.
        DISPLAY "" WITH FRAME f_produtos-rdcpos.

    END.
    
END PROCEDURE.

PROCEDURE grava-rdcpos:

    DEF VAR aux_tpaplica AS INTE                                        NO-UNDO.

    FOR EACH tt-rdcpos NO-LOCK.

        IF  tt-rdcpos.dsaplica <> "" THEN
            DO:

                FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper       AND
                                   crapdtc.tpaplica = tt-rdcpos.tpaplica AND
                                   crapdtc.tpaplrdc = 3           
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                IF  AVAIL crapdtc THEN
                    DO:
                        ASSIGN crapdtc.dsextapl = UPPER(tt-rdcpos.dsaplica)
                               crapdtc.dsaplica = UPPER(tt-rdcpos.dsaplica)
                               crapdtc.qtdiacar = tt-rdcpos.qtinicar
                               crapdtc.qtmaxcar = tt-rdcpos.qtfincar
                               crapdtc.vlminapl = tt-rdcpos.vliniapl
                               crapdtc.vlmaxapl = tt-rdcpos.vlfinapl.
                    END.
                ELSE
                    DO:
                        FIND LAST crapdtc WHERE crapdtc.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
        
                        IF  AVAIL crapdtc  THEN
                            aux_tpaplica = crapdtc.tpaplica + 1.
                        ELSE
                            aux_tpaplica = 1.
        
                        CREATE crapdtc.
                        ASSIGN crapdtc.cdcooper = glb_cdcooper 
                               crapdtc.tpaplica = aux_tpaplica
                               crapdtc.tpaplrdc = 3 /* Produtos Captacao RDCPOS */
                               crapdtc.dsextapl = UPPER(tt-rdcpos.dsaplica)
                               crapdtc.dsaplica = UPPER(tt-rdcpos.dsaplica)
                               crapdtc.qtdiacar = tt-rdcpos.qtinicar       
                               crapdtc.qtmaxcar = tt-rdcpos.qtfincar       
                               crapdtc.vlminapl = tt-rdcpos.vliniapl       
                               crapdtc.vlmaxapl = tt-rdcpos.vlfinapl       
                               crapdtc.flgstrdc = TRUE.

                        VALIDATE crapdtc.
                    END.
            END.
        ELSE
            DO:
                IF  tt-rdcpos.tpaplica > 0 THEN
                    DO:
                        FIND crapdtc WHERE crapdtc.cdcooper = glb_cdcooper       AND
                                           crapdtc.tpaplica = tt-rdcpos.tpaplica AND
                                           crapdtc.tpaplrdc = 3           
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF  AVAIL crapdtc THEN
                            DELETE crapdtc.
                    END.
            END.
    END.
    IF  AVAIL crapdtc THEN
        DO:
            FIND CURRENT crapdtc NO-LOCK.
            RELEASE crapdtc.
        END.
        
    RUN gera_log_produtos_rdcpos.

END PROCEDURE.

PROCEDURE valida-rdcpos:

    DEFINE BUFFER b-tt-rdcpos FOR tt-rdcpos.

    FOR EACH tt-rdcpos NO-LOCK.

        IF  tt-rdcpos.dsaplica <> "" THEN
            DO:
                IF  tt-rdcpos.qtinicar = 0 OR
                    tt-rdcpos.qtfincar = 0 OR
                    tt-rdcpos.vliniapl = 0 OR
                    tt-rdcpos.vlfinapl = 0 THEN
                    DO:
                        ASSIGN glb_dscritic = "Todos os campos do produto " + tt-rdcpos.dsaplica + " devem ser informados.".
                        RETURN "NOK".
                    END.

                IF  (tt-rdcpos.qtinicar > tt-rdcpos.qtfincar) OR
                    (tt-rdcpos.vliniapl > tt-rdcpos.vlfinapl) THEN
                    DO:
                        ASSIGN glb_dscritic = "Produto " + tt-rdcpos.dsaplica + " com limites incorretos.".
                        RETURN "NOK".
                    END.

                IF CAN-FIND (b-tt-rdcpos WHERE (b-tt-rdcpos.dsaplica <> ""                  AND
                                                b-tt-rdcpos.dsaplica <> tt-rdcpos.dsaplica) AND
                                                b-tt-rdcpos.qtinicar =  tt-rdcpos.qtinicar  AND
                                                b-tt-rdcpos.qtfincar =  tt-rdcpos.qtfincar  AND
                                                b-tt-rdcpos.vliniapl =  tt-rdcpos.vliniapl  AND
                                                b-tt-rdcpos.vlfinapl =  tt-rdcpos.vlfinapl 
                                                NO-LOCK) THEN
                    DO:

                        ASSIGN glb_dscritic = "Produto " + tt-rdcpos.dsaplica + " com faixa presente em outro produto.".
                        RETURN "NOK".
                    END.

                FIND b-tt-rdcpos WHERE b-tt-rdcpos.dsaplica = tt-rdcpos.dsaplica NO-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL b-tt-rdcpos THEN
                    DO:
                        ASSIGN glb_dscritic = "Produto " + tt-rdcpos.dsaplica + " com nome ja utilizado por outro produto.".
                        RETURN "NOK".
                    END.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE atualiza-produtos-rdcpos:

    DEF VAR aux_totalreg AS INTE  INIT 0                                NO-UNDO.
    DEF VAR aux_totatual AS INTE  INIT 0                                NO-UNDO.
    DEF VAR aux_contdown AS INTE  INIT 0                                NO-UNDO.
    DEF VAR aux_contador AS INTE  INIT 0                                NO-UNDO.

    FOR EACH tt-rdcpos NO-LOCK.
        ASSIGN aux_totalreg = aux_totalreg + 1.
    END.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN aux_totatual = 0
               aux_contdown = 0.

        FOR EACH tt-rdcpos NO-LOCK.
            
            UPDATE  tt-rdcpos.dsaplica
                    tt-rdcpos.qtinicar
                    tt-rdcpos.qtfincar
                    tt-rdcpos.vliniapl
                    tt-rdcpos.vlfinapl WITH FRAME f_produtos-rdcpos.

            ASSIGN aux_totatual = aux_totatual + 1.
        
            IF  aux_totatual = aux_totalreg THEN
                LEAVE.
        
            DOWN WITH FRAME f_produtos-rdcpos.
        
            ASSIGN aux_contdown = aux_contdown + 1.
        
        END.

        IF  aux_contdown > 0 THEN
            DO aux_contador = aux_contdown TO 1 BY -1: 
                UP WITH FRAME f_produtos-rdcpos.
                DISPLAY "" WITH FRAME f_produtos-rdcpos.
            END.

        IF  aux_totatual = 4 THEN
            DO:
                RUN valida-rdcpos.
            
                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

                RUN grava-rdcpos.

            END.

        LEAVE.

    END.    

END PROCEDURE.

PROCEDURE limpa_tipo.

    ASSIGN tel_tpaplrdc = 0
           tel_dsextapl = ""
           tel_dsaplica = ""
           tel_vlminapl = 0
           tel_vlmaxapl = 0
           tel_flgstrdc = NO.
       
    DISPLAY tel_tpaplrdc  tel_dsextapl  tel_dsaplica 
            tel_vlminapl  tel_vlmaxapl  tel_flgstrdc 
            WITH FRAME f_tipo.
                                 
END PROCEDURE.


PROCEDURE limpa_periodos.

    FIND crapdtc WHERE  crapdtc.cdcooper = glb_cdcooper AND
                       (crapdtc.tpaplrdc = 1            OR 
                        crapdtc.tpaplrdc = 2)           AND
                        crapdtc.tpaplica = tel_tptaxrdc NO-LOCK NO-ERROR.
   
    IF AVAIL crapdtc THEN
       ASSIGN tel_dsaplica = "- " + crapdtc.dsaplica.
     
    DISPLAY tel_tptaxrdc 
            tel_dsaplica
            WITH FRAME f_periodo.
    
    CLOSE QUERY q_periodos.

END PROCEDURE.


PROCEDURE limpa_faixas.
    
    CLOSE QUERY q_faixas.
    
    FIND crapdtc WHERE  crapdtc.cdcooper = glb_cdcooper AND
                       (crapdtc.tpaplrdc = 1            OR 
                        crapdtc.tpaplrdc = 2)           AND
                        crapdtc.tpaplica = tel_tptaxrdc NO-LOCK NO-ERROR.
   
    IF AVAIL crapdtc THEN
       ASSIGN tel_dsaplica = "- " + crapdtc.dsaplica.
    
    ASSIGN  tel_cdperapl = 0
            tel_dsperapl = "".
    
    DISPLAY tel_dsaplica  tel_cdperapl
            tel_dsperapl
            WITH FRAME f_faixas.
END.


PROCEDURE limpa_acumula.

    FIND crapdtc WHERE  crapdtc.cdcooper = glb_cdcooper AND
                       (crapdtc.tpaplrdc = 1            OR 
                        crapdtc.tpaplrdc = 2)           AND
                        crapdtc.tpaplica = tel_tptaxrdc NO-LOCK NO-ERROR.
   
    IF  AVAIL crapdtc THEN
        ASSIGN tel_dsaplica = "- " + crapdtc.dsaplica.
            
    ASSIGN   tel_flgpcapt = NO
             tel_flgrdc30 = NO
             tel_flgrdmpp = NO
             tel_flgrdc60 = NO
             tel_flgrdpre = NO
             tel_flgrdpos = NO.
    
    DISPLAY  tel_dsaplica                         
             " "  @ tel_flgpcapt
             " "  @ tel_flgrdc30 
             " "  @ tel_flgrdmpp 
             " "  @ tel_flgrdc60 
             " "  @ tel_flgrdpre 
             " "  @ tel_flgrdpos
             WITH FRAME f_acumula.
    
END PROCEDURE.


PROCEDURE altera_periodos.

    FORM SKIP(1)
         tel_tptaxrdc      AT  12  LABEL "Tipo"
         cratttx.cdperapl  AT  34  LABEL "Periodo"    SKIP(1)
         cratttx.qtdiacar  AT  4   LABEL "Carencia"  
         cratttx.qtdiaini  AT  23  LABEL "Inicio"
         cratttx.qtdiafim  AT  42  LABEL "Final"      SKIP(2)
         WITH ROW 11 CENTERED SIDE-LABELS OVERLAY WIDTH 58
         TITLE " Alteracao de Periodo " FRAME f_altera_periodos.

    IF NOT AVAIL cratttx THEN
       LEAVE.
    
    DISPLAY  tel_tptaxrdc 
             cratttx.cdperapl
             cratttx.qtdiacar
             WITH FRAME f_altera_periodos.
    
    /**** Variaveis utilizadas no LOG ****/
    ASSIGN  aux_qtdiacar = cratttx.qtdiacar
            aux_qtdiaini = cratttx.qtdiaini
            aux_qtdiafim = cratttx.qtdiafim.
    
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
        IF  crapdtc.tpaplrdc = 1 THEN   /**Aplicacao PRE**/
            UPDATE  cratttx.qtdiaini
                    cratttx.qtdiafim 
                    WITH FRAME f_altera_periodos.
        ELSE                           /**Aplicacao POS**/
             UPDATE cratttx.qtdiacar  
                    cratttx.qtdiaini
                    cratttx.qtdiafim 
                    WITH FRAME f_altera_periodos.
        
        IF  cratttx.qtdiaini > cratttx.qtdiafim OR
            cratttx.qtdiafim = 0                THEN
            DO:
                glb_cdcritic = 895.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
                NEXT.
            END.
        
        FIND crapttx WHERE  crapttx.cdcooper = cratttx.cdcooper AND
                            crapttx.tptaxrdc = cratttx.tptaxrdc AND
                            crapttx.cdperapl = cratttx.cdperapl
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                        
        ASSIGN crapttx.qtdiacar = cratttx.qtdiacar
               crapttx.qtdiaini = cratttx.qtdiaini
               crapttx.qtdiafim = cratttx.qtdiafim.
        
        /** Gera log para os campos alterados **/
        
        IF aux_qtdiacar <> crapttx.qtdiacar THEN
           RUN gera_log_periodo.
        IF aux_qtdiaini <> crapttx.qtdiaini THEN
           RUN gera_log_periodo.
        IF aux_qtdiafim <> crapttx.qtdiafim THEN
           RUN gera_log_periodo.
        
        LEAVE.   
    END.

END PROCEDURE.

PROCEDURE exclui_periodos.
    
    IF NOT AVAIL cratttx THEN
       LEAVE.
    
    FIND crapttx WHERE  crapttx.cdcooper = glb_cdcooper     AND
                        crapttx.tptaxrdc = cratttx.tptaxrdc AND
                        crapttx.cdperapl = cratttx.cdperapl 
                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
    IF  crapdtc.tpaplrdc = 1 THEN  /** Aplicacao RDCPRE **/
        DO:
           FIND LAST crapttx WHERE crapttx.cdcooper = glb_cdcooper AND
                                   crapttx.tptaxrdc = cratttx.tptaxrdc
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
           IF  crapttx.cdperapl <> cratttx.cdperapl THEN
               DO:
                   MESSAGE "Somente eh permitido excluir o ultimo periodo!".
                   BELL.
                   LEAVE.
               END. 
        
        END.
    
    
    FIND FIRST crapftx WHERE crapftx.cdcooper = glb_cdcooper AND
                             crapftx.tptaxrdc = tel_tptaxrdc AND
                             crapftx.cdperapl = cratttx.cdperapl 
                             NO-LOCK NO-ERROR.
          
    IF  AVAIL crapftx THEN
        DO:
            glb_cdcritic = 903.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.
         
    RUN confirma.
          
    IF  aux_confirma <> "S"   THEN
        DO:
            glb_cdcritic = 0.
            LEAVE.
        END.
    
    RUN gera_log_periodo.      
    
    DELETE cratttx.  /*** Deleta dados do browse ***/
    DELETE crapttx.  /*** Deleta dados da tabela ***/       
    
    

END PROCEDURE.

PROCEDURE carrega_periodos.

      EMPTY TEMP-TABLE cratttx.
      
      FOR EACH crapttx WHERE crapttx.cdcooper = glb_cdcooper AND
                             crapttx.tptaxrdc = tel_tptaxrdc NO-LOCK:
          CREATE  cratttx.
          ASSIGN  cratttx.cdcooper = crapttx.cdcooper
                  cratttx.tptaxrdc = crapttx.tptaxrdc
                  cratttx.cdperapl = crapttx.cdperapl
                  cratttx.qtdiacar = crapttx.qtdiacar 
                  cratttx.qtdiaini = crapttx.qtdiaini
                  cratttx.qtdiafim = crapttx.qtdiafim.
      END.

END.


PROCEDURE carrega_faixas.
 
    EMPTY TEMP-TABLE w_faixas.    
    EMPTY TEMP-TABLE cratftx.
    /* carrega todas as taxas */
    FOR EACH crapftx WHERE crapftx.cdcooper = glb_cdcooper     AND
                           crapftx.tptaxrdc = tel_tptaxrdc     AND
                           crapftx.cdperapl = tel_cdperapl     NO-LOCK
                           BY crapftx.vlfaixas:
      
        CREATE w_faixas.
        ASSIGN w_faixas.tptaxrdc  = tel_tptaxrdc    
               w_faixas.cdperapl  = tel_cdperapl    
               w_faixas.vlfaxini  = crapftx.vlfaixas 
               w_faixas.vlfaxfim  = 999999999.99     
               w_faixas.perapltx  = crapftx.perapltx
               w_faixas.perrdttx  = crapftx.perrdttx .
    
        CREATE cratftx. 
        ASSIGN cratftx.cdcooper = glb_cdcooper
               cratftx.tptaxrdc = tel_tptaxrdc
               cratftx.cdperapl = tel_cdperapl
               cratftx.vlfaixas = crapftx.vlfaixas
               cratftx.perapltx = crapftx.perapltx
               cratftx.perrdttx = crapftx.perrdttx.
    
    END.

    /* atribuir o valores finais de cada taxa */
    FOR EACH w_faixas.

        FIND FIRST w_faixas2 WHERE w_faixas2.tptaxrdc = w_faixas.tptaxrdc   AND
                                   w_faixas2.cdperapl = w_faixas.cdperapl   AND
                                   w_faixas2.vlfaxini > w_faixas.vlfaxini    
                                   NO-LOCK NO-ERROR.
                       
        IF   AVAILABLE w_faixas2   THEN
             w_faixas.vlfaxfim = w_faixas2.vlfaxini - 0.01.
    END.
                               
END.


PROCEDURE atualiza_faixas.

    EMPTY TEMP-TABLE w_faixas.    
    /* carrega todas as taxas */
    FOR EACH cratftx WHERE cratftx.cdcooper = glb_cdcooper     AND
                           cratftx.tptaxrdc = tel_tptaxrdc     AND
                           cratftx.cdperapl = tel_cdperapl     NO-LOCK
                           BY cratftx.vlfaixas:
      
        CREATE w_faixas.
        ASSIGN w_faixas.tptaxrdc  = tel_tptaxrdc    
               w_faixas.cdperapl  = tel_cdperapl    
               w_faixas.vlfaxini  = cratftx.vlfaixas 
               w_faixas.vlfaxfim  = 999999999.99     
               w_faixas.perapltx  = cratftx.perapltx
               w_faixas.perrdttx  = cratftx.perrdttx.
    END.

    /* atribuir o valores finais de cada taxa */
    FOR EACH w_faixas.

        FIND FIRST w_faixas2 WHERE w_faixas2.tptaxrdc = w_faixas.tptaxrdc   AND
                                   w_faixas2.cdperapl = w_faixas.cdperapl   AND
                                   w_faixas2.vlfaxini > w_faixas.vlfaxini    
                                   NO-LOCK NO-ERROR.
                       
        IF   AVAILABLE w_faixas2   THEN
             w_faixas.vlfaxfim = w_faixas2.vlfaxini - 0.01.
    END.

END PROCEDURE.



PROCEDURE inclui_faixas.

    /* ultima faixa/taxa */
    DEF VAR tel_iniulfxa AS DECIMAL     FORMAT "zzz,zz9.99"         NO-UNDO.
    DEF VAR tel_fimulfxa AS DECIMAL     FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
    DEF VAR tel_perulapl AS DECIMAL     FORMAT "zz9.999999"         NO-UNDO.
    DEF VAR tel_perulrdt AS DECIMAL     FORMAT "zz9.999999"         NO-UNDO.
    DEF VAR aux_controle AS INTEGER                                 NO-UNDO.

    FORM SKIP(1)
         "ULTIMA FAIXA/TAXA"   AT 3
         SKIP
         "De:"                 AT 8
         tel_iniulfxa        
         "Ate:"                AT 30 
         tel_fimulfxa        
         SKIP
         "%Vencto:"            AT 3
         tel_perulapl         
         "%Resgate:"           AT 25   SPACE (5)
         tel_perulrdt         
         SKIP(1)
         "NOVA FAIXA/TAXA"     AT  3
         SKIP
         "De:"                 AT 8
         tel_vlfaxini   HELP "Informe o valor inicial da faixa." 
         "Ate: 999.999.999,99" AT 30
         SKIP
         "%Vencto:"            AT 3
         tel_perapltx   HELP "Informe o valor (%) do Vencimento."
         "%Resgate:"           AT 25   SPACE (5)
         tel_perrdttx   HELP "Informe o valor (%) do Resgate."
         SKIP(1)
         WITH ROW 10 CENTERED SIDE-LABELS NO-LABELS OVERLAY WIDTH 60
              TITLE " Inclusao de Nova Faixa/Taxa " FRAME f_inclui_faixa.

    ASSIGN  tel_vlfaxini = 0
            tel_perapltx = 0
            tel_perrdttx = 0.
    DISPLAY tel_vlfaxini tel_perapltx tel_perrdttx WITH FRAME f_inclui_faixa.
    
    FIND LAST w_faixas WHERE w_faixas.tptaxrdc = tel_tptaxrdc AND
                             w_faixas.cdperapl = tel_cdperapl 
                             NO-LOCK NO-ERROR.
    
    IF   AVAILABLE w_faixas   THEN
         ASSIGN tel_iniulfxa = w_faixas.vlfaxini
                tel_fimulfxa = w_faixas.vlfaxfim
                tel_perulapl = w_faixas.perapltx
                tel_perulrdt = w_faixas.perrdttx.
                 
    DISPLAY tel_iniulfxa
            tel_fimulfxa
            tel_perulapl
            tel_perulrdt
            WITH FRAME f_inclui_faixa.                                   
    
    FIND FIRST w_faixas NO-LOCK NO-ERROR.

     /*** Primeira inclusao **/
    IF  NOT AVAIL w_faixas THEN
        DO:
            ASSIGN tel_vlfaxini = 0.
            DISPLAY tel_vlfaxini WITH FRAME f_inclui_faixa.
            UPDATE  tel_perapltx 
                    WITH FRAME f_inclui_faixa.
            
            /**** Aplicacao POS ***/
            IF  crapdtc.tpaplrdc <> 1 THEN
                DO:
                   UPDATE tel_perrdttx 
                          WITH FRAME f_inclui_faixa. 
                END.
        END.
    ELSE 
        DO: 
            UPDATE tel_vlfaxini
                   tel_perapltx
                   WITH FRAME f_inclui_faixa.
            
            /**** Se for aplicacao POS atualiza %Resgat***/
            IF  crapdtc.tpaplrdc <> 1 THEN
                DO:
                   UPDATE tel_perrdttx 
                          WITH FRAME f_inclui_faixa. 
                END.
        END.
          
    CREATE w_faixas.
    ASSIGN w_faixas.vlfaxini = tel_vlfaxini
           w_faixas.perapltx = tel_perapltx
           w_faixas.perrdttx = tel_perrdttx.
          
    /* validacao da nova faixa */
   
    FIND FIRST w_faixas2 WHERE w_faixas2.tptaxrdc = tel_tptaxrdc       AND
                               w_faixas2.cdperapl = tel_cdperapl       AND
                               w_faixas2.vlfaxini = w_faixas.vlfaxini
                               NO-LOCK NO-ERROR.
                              
    /* verifica se ja existe essa faixa */
    IF   AVAILABLE w_faixas2   THEN
         DO:
             glb_cdcritic = 899.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             NEXT.
         END.
    ELSE        /* verifica se a taxa (porcentagem) esta correta */
         DO:
             FIND FIRST w_faixas2 WHERE 
                                  w_faixas2.tptaxrdc = tel_tptaxrdc   AND
                                  w_faixas2.cdperapl = tel_cdperapl   AND
                                  w_faixas2.vlfaxini > w_faixas.vlfaxini
                                  NO-LOCK NO-ERROR.
                                       
             IF   AVAILABLE w_faixas2   THEN
                  DO:                            
                     IF   w_faixas.perapltx >= w_faixas2.perapltx   THEN
                          DO:
                              glb_cdcritic = 900.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              NEXT.
                          END.
                  END.
                                                  
             FIND LAST w_faixas2 WHERE w_faixas2.tptaxrdc = tel_tptaxrdc   AND
                                       w_faixas2.cdperapl = tel_cdperapl   AND
                                       w_faixas2.vlfaxini < w_faixas.vlfaxini
                                       NO-LOCK NO-ERROR.
                                       
             IF   AVAILABLE w_faixas2   THEN
                  DO:
                      IF   w_faixas.perapltx <= w_faixas2.perapltx   THEN
                           DO:
                              glb_cdcritic = 900.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic.
                              glb_cdcritic = 0.
                              NEXT.
                           END.
                  END.
         END.
         
    /** %Vencto deve ser maior que %Resgat  **/
    IF  w_faixas.perapltx < w_faixas.perrdttx THEN
        DO:
            glb_cdcritic = 901.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END. 

    CREATE crapftx.
    ASSIGN crapftx.cdcooper = glb_cdcooper
           crapftx.tptaxrdc = tel_tptaxrdc
           crapftx.cdperapl = tel_cdperapl
           crapftx.vlfaixas = w_faixas.vlfaxini
           crapftx.perapltx = w_faixas.perapltx
           crapftx.perrdttx = w_faixas.perrdttx.
    
    VALIDATE crapftx.
    

    RUN gera_log_faixas.
    
    RUN carrega_faixas.
    
    LEAVE.

END PROCEDURE.  

  
PROCEDURE altera_faixas.
    
    FORM SKIP(1)
         w_faixas.vlfaxini    AT  3  LABEL "     De"
         w_faixas.vlfaxfim    AT 25  LABEL "   Ate"
         SKIP(1)
         w_faixas.perapltx    AT  3  LABEL "%Vencto"
                                     HELP "Informe o valor (%) da Taxa"
         SPACE(5)
         w_faixas.perrdttx           LABEL "%Resgate"
         SKIP(1)
         WITH ROW 11 CENTERED SIDE-LABELS OVERLAY WIDTH 68
              TITLE " Alteracao de Taxa " FRAME f_altera_faixas.
    
    IF NOT AVAIL w_faixas THEN
       LEAVE.
    
    DISPLAY w_faixas.vlfaxini
            w_faixas.vlfaxfim        
            WITH FRAME f_altera_faixas.

    DO WHILE TRUE:
             
       /** Variaveis utilizadas no LOG **/
       ASSIGN aux_perapltx = w_faixas.perapltx
              aux_perrdttx = w_faixas.perrdttx.
       
       /** Aplicacao POS **/
       IF  crapdtc.tpaplrdc <> 1 THEN
           UPDATE w_faixas.perapltx
                  w_faixas.perrdttx 
                  WITH FRAME f_altera_faixas.
       ELSE
            DO:  /** Aplicacao PRE **/
               DISPLAY w_faixas.perrdttx 
                       WITH FRAME f_altera_faixas.                
               UPDATE w_faixas.perapltx
                      WITH FRAME f_altera_faixas.
            END.
       
       /* verifica se a porcentagem esta correta */

       FIND FIRST w_faixas2 WHERE w_faixas2.tptaxrdc = tel_tptaxrdc     AND
                                  w_faixas2.cdperapl = tel_cdperapl     AND
                                  w_faixas2.vlfaxini > w_faixas.vlfaxini
                                  NO-LOCK NO-ERROR.
                                       
       IF   AVAILABLE w_faixas2   THEN
            DO:
               IF   w_faixas.perapltx >= w_faixas2.perapltx   THEN
                    DO:
                        glb_cdcritic = 900.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                       
                    END.
            END.
                                                   
       FIND LAST w_faixas2 WHERE w_faixas2.tptaxrdc  = tel_tptaxrdc   AND
                                 w_faixas2.cdperapl  = tel_cdperapl   AND
                                 w_faixas2.vlfaxini  < w_faixas.vlfaxini
                                 NO-LOCK NO-ERROR.
       
       IF   AVAILABLE w_faixas2   THEN
            DO:
                IF   w_faixas.perapltx <= w_faixas2.perapltx   THEN
                     DO:  
                         glb_cdcritic = 900.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         NEXT.  
                     END.
            END.
         
       /** %Vencto deve ser maior que %Resgat  **/
       IF  w_faixas.perapltx < w_faixas.perrdttx THEN
           DO:
               glb_cdcritic = 901.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               NEXT.
           END.

      
       FIND crapftx WHERE crapftx.cdcooper = glb_cdcooper AND
                          crapftx.tptaxrdc = tel_tptaxrdc AND
                          crapftx.cdperapl = tel_cdperapl AND
                          crapftx.vlfaixas = w_faixas.vlfaxini
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                      
       ASSIGN  crapftx.perapltx = w_faixas.perapltx
               crapftx.perrdttx = w_faixas.perrdttx
               glb_cdcritic = 0.
       
       /*** Gera LOG para os campos alterados **/
       IF  crapftx.perapltx <> aux_perapltx THEN
           RUN gera_log_faixas.
       IF  crapftx.perrdttx <> aux_perrdttx THEN
           RUN gera_log_faixas.
           
       RUN carrega_faixas.  
       
       LEAVE.
    
    END. /**Fim WHILE TRUE***/  

END PROCEDURE.


PROCEDURE exclui_faixas.
    
    IF NOT AVAIL w_faixas THEN  
       LEAVE.
    
    IF   w_faixas.vlfaxini = 0   THEN
         DO:
            FIND LAST crapftx WHERE crapftx.cdcooper = glb_cdcooper AND
                                    crapftx.tptaxrdc = tel_tptaxrdc AND
                                    crapftx.cdperapl = tel_cdperapl AND
                                    crapftx.vlfaixas <> w_faixas.vlfaxini 
                                    NO-LOCK NO-ERROR.
            IF  AVAIL crapftx THEN 
                DO:
                    glb_cdcritic = 902.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    NEXT.
                   
                END.
         END.
  
    FIND crapftx WHERE crapftx.cdcooper = glb_cdcooper AND
                       crapftx.tptaxrdc = tel_tptaxrdc AND
                       crapftx.cdperapl = tel_cdperapl AND
                       crapftx.vlfaixas = w_faixas.vlfaxini
                       NO-ERROR.
    
    RUN confirma.
          
    IF  aux_confirma <> "S"   THEN
        DO:
            glb_cdcritic = 0.
            LEAVE.
        END.
    
    RUN gera_log_faixas. 
    
    DELETE crapftx. 
    
    RUN carrega_faixas.   
    
    LEAVE.
END. 

/******Acumulatividade******/
PROCEDURE inclui_acumula:

       /* Verifica se ja tem um registro da aplicacao */
       FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                craptab.nmsistem = "CRED"           AND
                                craptab.cdempres = tel_tptaxrdc     AND
                                craptab.tptabela = "GENERI"         AND
                                craptab.cdacesso = "SOMAPLTAXA" 
                                NO-LOCK NO-ERROR.

       IF AVAILABLE craptab   THEN
          DO:
             MESSAGE "910 - Cumulatividade ja cadastrada." +
                     " Use opcao A para alterar.".
             BELL.
             NEXT.
          END.  
       ELSE
          DO:     
             RUN limpa_acumula.
             
             UPDATE  tel_flgpcapt
                     tel_flgrdc30 
                     tel_flgrdmpp 
                     tel_flgrdc60 
                     tel_flgrdpre 
                     tel_flgrdpos
                     WITH FRAME f_acumula.
           
             RUN confirma.
        
             IF aux_confirma = "S"   THEN
                DO: 
                   CREATE craptab.
                   ASSIGN craptab.cdcooper = glb_cdcooper     
                          craptab.nmsistem = "CRED"           
                          craptab.cdempres = tel_tptaxrdc                
                          craptab.tptabela = "GENERI"         
                          craptab.cdacesso = "SOMAPLTAXA"     
                          craptab.tpregist = 0
                          craptab.dstextab = IF tel_flgpcapt = TRUE THEN "SIM"
                                             ELSE "NAO".
                   VALIDATE craptab.

                   CREATE craptab.
                   ASSIGN craptab.cdcooper = glb_cdcooper     
                          craptab.nmsistem = "CRED"           
                          craptab.cdempres = tel_tptaxrdc                
                          craptab.tptabela = "GENERI"         
                          craptab.cdacesso = "SOMAPLTAXA"     
                          craptab.tpregist = 1
                          craptab.dstextab = IF tel_flgrdc30 = TRUE THEN "SIM"
                                             ELSE "NAO".
                   VALIDATE craptab.

                   CREATE craptab.
                   ASSIGN craptab.cdcooper = glb_cdcooper     
                          craptab.nmsistem = "CRED"           
                          craptab.cdempres = tel_tptaxrdc               
                          craptab.tptabela = "GENERI"         
                          craptab.cdacesso = "SOMAPLTAXA"     
                          craptab.tpregist = 2
                          craptab.dstextab = IF tel_flgrdmpp = TRUE THEN "SIM"
                                             ELSE "NAO".
                   VALIDATE craptab.

                   CREATE craptab.
                   ASSIGN craptab.cdcooper = glb_cdcooper     
                          craptab.nmsistem = "CRED"           
                          craptab.cdempres = tel_tptaxrdc                
                          craptab.tptabela = "GENERI"         
                          craptab.cdacesso = "SOMAPLTAXA"     
                          craptab.tpregist = 3
                          craptab.dstextab = IF tel_flgrdc60 = TRUE THEN "SIM"
                                             ELSE "NAO".
                   VALIDATE craptab.

                   CREATE craptab.
                   ASSIGN craptab.cdcooper = glb_cdcooper     
                          craptab.nmsistem = "CRED"           
                          craptab.cdempres = tel_tptaxrdc                
                          craptab.tptabela = "GENERI"         
                          craptab.cdacesso = "SOMAPLTAXA"     
                          craptab.tpregist = 7
                          craptab.dstextab = IF tel_flgrdpre = TRUE THEN "SIM"
                                             ELSE "NAO".
                   VALIDATE craptab.

                   CREATE craptab.
                   ASSIGN craptab.cdcooper = glb_cdcooper     
                          craptab.nmsistem = "CRED"           
                          craptab.cdempres = tel_tptaxrdc                
                          craptab.tptabela = "GENERI"         
                          craptab.cdacesso = "SOMAPLTAXA"     
                          craptab.tpregist = 8
                          craptab.dstextab = IF tel_flgrdpos = TRUE THEN "SIM"
                                             ELSE "NAO".
                   VALIDATE craptab.

                   MESSAGE "909 - Dados para cumulatividade atualizados" +
                           " com sucesso.".
                END.    
    
          END. /* Fim do NOT AVAILABLE */

END PROCEDURE.

PROCEDURE altera_acumula:

  FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                           craptab.nmsistem = "CRED"           AND
                           craptab.cdempres = tel_tptaxrdc     AND
                           craptab.tptabela = "GENERI"         AND
                           craptab.cdacesso = "SOMAPLTAXA"
                           NO-LOCK NO-ERROR.
                           
  IF   AVAIL craptab   THEN                         
       DO:
          /* FOR EACH para alimentar as variaveis que irao mostrar na tela */
          FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                 craptab.nmsistem = "CRED"           AND
                                 craptab.cdempres = tel_tptaxrdc     AND
                                 craptab.tptabela = "GENERI"         AND
                                 craptab.cdacesso = "SOMAPLTAXA"
                                 NO-LOCK:
              
              IF   craptab.tpregist = 0   THEN
                   DO:
              

                      IF   craptab.dstextab = "SIM"   THEN
                           tel_flgpcapt = TRUE.
                      ELSE
                           tel_flgpcapt = FALSE.
                   END.

              IF   craptab.tpregist = 1   THEN
                   DO:
              
                      IF   craptab.dstextab = "SIM"   THEN
                           tel_flgrdc30 = TRUE.
                      ELSE
                           tel_flgrdc30 = FALSE.
                   END.
            
              IF   craptab.tpregist = 2   THEN
                   DO:
                      IF   craptab.dstextab = "SIM"   THEN
                           tel_flgrdmpp = TRUE.
                      ELSE
                           tel_flgrdmpp = FALSE.
                   END.
               
              IF   craptab.tpregist = 3   THEN
                   DO:
                      IF   craptab.dstextab = "SIM"   THEN
                           tel_flgrdc60 = TRUE.
                      ELSE
                           tel_flgrdc60 = FALSE.
                   END.
      
              IF   craptab.tpregist = 7   THEN
                   DO:
                      IF   craptab.dstextab = "SIM"   THEN
                           tel_flgrdpre = TRUE.
                      ELSE
                           tel_flgrdpre = FALSE.
                   END.
           
              IF   craptab.tpregist = 8  THEN
                   DO:
                      IF   craptab.dstextab = "SIM"   THEN
                           tel_flgrdpos = TRUE.
                      ELSE
                           tel_flgrdpos = FALSE.
                   END.
      
          END. /* Fim do FOR EACH */
          
          UPDATE  tel_flgpcapt
                  tel_flgrdc30 
                  tel_flgrdmpp 
                  tel_flgrdc60 
                  tel_flgrdpre 
                  tel_flgrdpos
                  WITH FRAME f_acumula.             
                 
          RUN confirma.
            
          IF aux_confirma = "S"   THEN
             DO: 
                DO aux_contador = 1 TO 10:
                   FOR EACH craptab WHERE 
                                    craptab.cdcooper = glb_cdcooper     AND
                                    craptab.nmsistem = "CRED"           AND
                                    craptab.cdempres = tel_tptaxrdc     AND
                                    craptab.tptabela = "GENERI"         AND
                                    craptab.cdacesso = "SOMAPLTAXA"
                                    EXCLUSIVE-LOCK:

                       /*--------- 
                       Verifica se ha diferenca do informado na tela com o da
                       tabela se houver entao grava o novo registro na tabela 
                       e gera o log.
                       -----------*/ 
                       IF  craptab.tpregist = 0   THEN
                           DO:
                              IF  tel_flgpcapt = TRUE      AND
                                  craptab.dstextab = "NAO" THEN
                                  DO:
                                      ASSIGN craptab.dstextab = "SIM".
                                      RUN gerar_log.
                                  END.   
                              ELSE IF   tel_flgpcapt     = FALSE   AND
                                        craptab.dstextab = "SIM"   THEN
                                        DO:
                                            ASSIGN craptab.dstextab = "NAO".
                                            RUN gerar_log.
                                        END.
                           END. 

                       IF  craptab.tpregist = 1   THEN
                           DO:
                              IF  tel_flgrdc30 = TRUE      AND
                                  craptab.dstextab = "NAO" THEN
                                  DO:
                                      ASSIGN craptab.dstextab = "SIM".
                                      RUN gerar_log.
                                  END.   
                              ELSE IF   tel_flgrdc30     = FALSE   AND
                                        craptab.dstextab = "SIM"   THEN
                                        DO:
                                            ASSIGN craptab.dstextab = "NAO".
                                            RUN gerar_log.
                                        END.
                           END.     
                       IF  craptab.tpregist = 2   THEN
                           DO:
                              IF  tel_flgrdmpp     = TRUE    AND
                                  craptab.dstextab = "NAO"   THEN
                                  DO:
                                     ASSIGN craptab.dstextab = "SIM".
                                     RUN gerar_log.
                                  END.
                              ELSE IF  tel_flgrdmpp     = FALSE   AND
                                       craptab.dstextab = "SIM"   THEN
                                        DO:
                                            ASSIGN craptab.dstextab = "NAO".
                                            RUN gerar_log.
                                        END.
                           END.
                       IF   craptab.tpregist = 3   THEN
                            DO:
                                IF  tel_flgrdc60     = TRUE    AND
                                    craptab.dstextab = "NAO"   THEN
                                    DO:
                                        ASSIGN craptab.dstextab = "SIM".
                                        RUN gerar_log.
                                    END.
                                ELSE IF   tel_flgrdc60     = FALSE   AND
                                          craptab.dstextab = "SIM"   THEN
                                          DO:
                                             ASSIGN craptab.dstextab = "NAO".
                                             RUN gerar_log.
                                          END.
                            END.
                       IF  craptab.tpregist = 7   THEN
                           DO:
                              IF  tel_flgrdpre     = TRUE    AND
                                  craptab.dstextab = "NAO"   THEN
                                  DO:
                                     ASSIGN craptab.dstextab = "SIM".
                                     RUN gerar_log.
                                  END.
                              ELSE IF  tel_flgrdpre     = FALSE   AND
                                       craptab.dstextab = "SIM"   THEN
                                       DO:
                                           ASSIGN craptab.dstextab = "NAO".
                                           RUN gerar_log.
                                       END.
                           END.
                       IF   craptab.tpregist = 8   THEN
                            DO:
                                IF  tel_flgrdpos     = TRUE    AND
                                    craptab.dstextab = "NAO"   THEN
                                    DO:
                                        ASSIGN craptab.dstextab = "SIM".
                                        RUN gerar_log.
                                    END.
                                ELSE IF tel_flgrdpos     = FALSE   AND
                                        craptab.dstextab = "SIM"   THEN
                                        DO:
                                            ASSIGN craptab.dstextab = "NAO".
                                            RUN gerar_log.
                                        END.
                            END.
          
                   END. /* Fim do FOR EACH */    

                   LEAVE.
     
                END. /* Fim do DO .. TO */
  
                MESSAGE "909 - Dados para cumulatividade atualizados com"
                        "sucesso.".
  
                RELEASE craptab.
  
             END. /** Fim aux_confirma **/
                      
       END. /* Fim do IF AVAIL */
  ELSE
      DO:
          MESSAGE "908 - Cumulatividade nao cadastrada para esse tipo de"
                  "aplicacao.".
          BELL.
      END.
END.

PROCEDURE proc_renumera_cdi:

   DO aux_contador = 1 TO 10 TRANSACTION:     
        
      FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                         craptab.nmsistem = "CRED"       AND
                         craptab.tptabela = "USUARI"     AND
                         craptab.cdempres = 11           AND
                         craptab.cdacesso = "MXRENDIPOS" AND
                         craptab.tpregist = 1 EXCLUSIVE-LOCK NO-ERROR.
                                            
      IF   AVAILABLE craptab   THEN
           DO:
              ASSIGN aux_dtfimtax = DATE(ENTRY(2,craptab.dstextab,";")).
                                               
              IF   tel_flgrncdi = FALSE    THEN
                   DO:
                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          MESSAGE "A alteracao na renumeracao Cdi/Poup nao" 
                                  "podera ser refeita.".         
                          ASSIGN aux_confirma = "N"
                                 glb_cdcritic = 78.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                          glb_cdcritic = 0.
                          LEAVE.
                       END.

                       IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                            aux_confirma <> "S"                    THEN
                            DO:
                               ASSIGN glb_cdcritic = 79.
                               LEAVE.
                            END.

                       craptab.dstextab = ENTRY(1,craptab.dstextab,";") + ";" +
                                          STRING(glb_dtmvtolt,"99/99/9999").
                   END.
           END.
       ELSE
           IF   LOCKED craptab   THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                    					 INPUT "banco",
                    					 INPUT "craptab",
                    					 OUTPUT par_loginusr,
                    					 OUTPUT par_nmusuari,
                    					 OUTPUT par_dsdevice,
                    					 OUTPUT par_dtconnec,
                    					 OUTPUT par_numipusr).
                    
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    ASSIGN aux_dadosusr = 
                    "077 - Tabela sendo alterada p/ outro terminal.".
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 3 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                    			  " - " + par_nmusuari + ".".
                    
                    HIDE MESSAGE NO-PAUSE.
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 5 NO-MESSAGE.
                    LEAVE.
                    END.

                   NEXT.
                END.
           ELSE   
                DO: 
                   IF   tel_flgrncdi = FALSE   THEN
                        RETURN.
                
                   CREATE craptab.
                   ASSIGN craptab.cdcooper = glb_cdcooper 
                          craptab.nmsistem = "CRED"             
                          craptab.tptabela = "USUARI"           
                          craptab.cdempres = 11                 
                          craptab.cdacesso = "MXRENDIPOS"       
                          craptab.tpregist = 1
                          craptab.dstextab = STRING(glb_dtmvtolt, "99/99/9999") 
                                             + ";" +  "01/01/9999".
                END.
      LEAVE.
   END. /* Fim do DO TO */

   RELEASE craptab.
                                    
END PROCEDURE.

PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
             LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END. /* Mensagem de confirmacao */

END PROCEDURE.


PROCEDURE gera_log_periodo:

    DEF VAR aux_dsdtexto AS CHAR                                NO-UNDO.
    
    IF  glb_cddopcao = "I" THEN
        DO:
            UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                              " " + STRING(TIME,"HH:MM:SS") + "' --> '"  +
                              " Operador " + glb_cdoperad +
                              " incluiu o periodo " + STRING(crapttx.cdperapl) +
                              " da aplicacao: " + STRING(crapttx.tptaxrdc) + 
                              " - " + crapdtc.dsaplica + " >> log/cadtax.log").
        END.

    
    IF  glb_cddopcao = "E" THEN
        DO:
            UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                              " " + STRING(TIME,"HH:MM:SS") + "' --> '"  +
                              " Operador " + glb_cdoperad +
                              " excluiu o periodo " + STRING(crapttx.cdperapl) +
                              " da aplicacao: " + STRING(crapttx.tptaxrdc) + 
                              " - " + crapdtc.dsaplica + " >> log/cadtax.log").
        END.
    
    
    IF  glb_cddopcao = "A" THEN
        DO:
           IF  crapttx.qtdiacar <> aux_qtdiacar THEN
               DO:
                    ASSIGN  aux_dsdtexto =  " '('Carencia de : " +        
                                            STRING(aux_qtdiacar) + " para " +  
                                            STRING(crapttx.qtdiacar) + 
                                            " dias')'" 
                            aux_qtdiacar = crapttx.qtdiacar.
               END.  
           ELSE
               IF  crapttx.qtdiaini <> aux_qtdiaini THEN
                   DO:
                      ASSIGN  aux_dsdtexto = " '('Inicio de : " + 
                                             STRING(aux_qtdiaini) + " para " +
                                             STRING(crapttx.qtdiaini) + 
                                             " dias')'"
                              aux_qtdiaini = crapttx.qtdiaini.
                   END.
               ELSE
                  IF crapttx.qtdiafim <> aux_qtdiafim THEN
                     DO:
                        ASSIGN aux_dsdtexto = " '('Fim de : " + 
                                              STRING(aux_qtdiafim) + " para " +
                                              STRING(crapttx.qtdiafim) +  
                                              " dias')'"
                               aux_qtdiafim = crapttx.qtdiafim.
                     END.
         
           UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " " +
                             STRING(TIME,"HH:MM:SS") + "' --> '"  +
                             " Operador " + glb_cdoperad +
                             " alterou o periodo " + STRING(crapttx.cdperapl) + 
                             " da aplicacao: " + STRING(crapttx.tptaxrdc) + 
                             " - " + crapdtc.dsaplica +  aux_dsdtexto + 
                             " >> log/cadtax.log").
        
        END. /** Fim glb_cddopcao = "A" **/

END PROCEDURE.


PROCEDURE gera_log_faixas:

    DEF VAR aux_dsdtexto AS CHAR                                NO-UNDO.
    
    IF  glb_cddopcao = "I" THEN
        DO:       
            UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                              " " + STRING(TIME,"HH:MM:SS") + "' --> '"  +
                              " Operador " + glb_cdoperad +
                              " incluiu a faixa " + STRING(crapftx.vlfaixas) +
                              " do periodo " + STRING(crapftx.cdperapl) + 
                              " da aplicacao: " + STRING(crapftx.tptaxrdc) +
                              " - " + crapdtc.dsaplica + " >> log/cadtax.log").
        END.
    
    IF  glb_cddopcao = "E" THEN
        DO:
            UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                              " " + STRING(TIME,"HH:MM:SS") + "' --> '"  +
                              " Operador " + glb_cdoperad +
                              " excluiu a faixa " + STRING(crapftx.vlfaixas) +
                              " do periodo " + STRING(crapftx.cdperapl) + 
                              " da aplicacao: " + STRING(crapftx.tptaxrdc) +
                              " - " + crapdtc.dsaplica + " >> log/cadtax.log").
        END.


    IF  glb_cddopcao = "A" THEN
        DO: 
            IF  crapftx.perapltx <> aux_perapltx THEN
                DO:
                    ASSIGN aux_dsdtexto = "'(' %Vencto de: " +
                                          STRING(aux_perapltx) +
                                          " para " + STRING(crapftx.perapltx) +
                                          "')'"
                           aux_perapltx = crapftx.perapltx.
                
                END.
            ELSE
                IF  crapftx.perrdttx <> aux_perrdttx THEN
                    DO:
                        ASSIGN aux_dsdtexto = "'(' %Resgate de: " +
                                              STRING(aux_perrdttx) +
                                              " para " + 
                                              STRING(crapftx.perrdttx) +  "')'"
                               aux_perrdttx = crapftx.perrdttx.
                    END.
            
            UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                              " " + STRING(TIME,"HH:MM:SS") + "' --> '"  +
                              " Operador " + glb_cdoperad +
                              " alterou a faixa " + STRING(crapftx.vlfaixas) +
                              " do periodo " + STRING(crapftx.cdperapl) + 
                              " da aplicacao: " + STRING(crapftx.tptaxrdc) +
                              " - " + crapdtc.dsaplica + aux_dsdtexto  +
                              " >> log/cadtax.log").        
        END.

END PROCEDURE.

/*** LOG para Acumulatividade ***/
PROCEDURE gerar_log.

   RUN gera_arquivo_log(INPUT tel_tptaxrdc    ,
                        INPUT craptab.tpregist,
                        INPUT craptab.dstextab).

END PROCEDURE.

PROCEDURE gera_arquivo_log:

    DEF INPUT PARAM par_cdempres LIKE craptab.cdempres              NO-UNDO.
    DEF INPUT PARAM par_tpregist LIKE craptab.tpregist              NO-UNDO.    
    DEF INPUT PARAM par_dstextab LIKE craptab.dstextab              NO-UNDO.
    
    DEF VAR aux_tipoapli AS CHAR FORMAT "x(9)"                      NO-UNDO.
    DEF VAR aux_dsprodut AS CHAR FORMAT "x(10)"                      NO-UNDO.
    DEF VAR aux_tipode           LIKE craptab.dstextab              NO-UNDO.

    IF   par_dstextab = "SIM"   THEN
          aux_tipode = "NAO".
    ELSE
          aux_tipode = "SIM".
          
    IF   par_tpregist = 0   THEN   
         aux_dsprodut = " (PCAPTA - ".
    IF   par_tpregist = 1   THEN   
         aux_dsprodut = " (RDCA30 - ".
    IF   par_tpregist = 2   THEN
         aux_dsprodut = " (RDPP   - ".
    IF   par_tpregist = 3   THEN
         aux_dsprodut = " (RDCA60 - ".
    IF   par_tpregist = 7   THEN   
         aux_dsprodut = " (RDCPRE - ".
    IF   par_tpregist = 8   THEN
         aux_dsprodut = " (RDCPOS - ".
    
    IF   par_cdempres = 0   THEN
         aux_tipoapli = " - PCAPTA".
    IF   par_cdempres = 1   THEN
         aux_tipoapli = " - RDCA30".
    IF   par_cdempres = 2   THEN
         aux_tipoapli = " - RDPP  ".
    IF   par_cdempres = 3   THEN
         aux_tipoapli = " - RDCA60".
    IF   par_cdempres = 7   THEN
         aux_tipoapli = " - RDCPRE".
    IF   par_cdempres = 8   THEN
         aux_tipoapli = " - RDCPOS".     
         
    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " " +
                      STRING(TIME,"HH:MM:SS") + "' --> '"  +
                      " Operador " + glb_cdoperad +
                      " alterou a cumulatividade da aplicacao: '" + 
                      STRING(par_cdempres) + aux_tipoapli + aux_dsprodut +
                      "' de " + aux_tipode + " para " + par_dstextab + "').'" + 
                      " >> log/cadtax.log").
                     
END PROCEDURE.

PROCEDURE gera_log_produtos_rdcpos:

    DEF VAR aux_dsdtexto AS CHAR                                NO-UNDO.
    DEF VAR aux_flgalter AS LOGI  INIT FALSE                    NO-UNDO.

    FOR EACH tt-rdcpos NO-LOCK.

        ASSIGN aux_dsdtexto = "".
        
        FIND tt-rdcpos-log WHERE tt-rdcpos-log.tpaplica = tt-rdcpos.tpaplica
                                 NO-LOCK NO-ERROR NO-WAIT.

        IF  AVAIL tt-rdcpos-log THEN
            DO:
                IF  tt-rdcpos.dsaplica <> tt-rdcpos-log.dsaplica THEN
                    DO:
                        ASSIGN aux_flgalter = TRUE.

                        UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " " +
                                           STRING(TIME,"HH:MM:SS") + "' --> '"  +
                                           " Operador " + glb_cdoperad +
                                           " alterou o nome do produto de " + 
                                           STRING(tt-rdcpos-log.dsaplica, "X(12)") + " para " + UPPER(STRING(tt-rdcpos.dsaplica, "X(12)")) + "." +
                                           " >> log/cadtax.log").
                    END.
                
                IF  tt-rdcpos.qtinicar <> tt-rdcpos-log.qtinicar OR
                    tt-rdcpos.qtfincar <> tt-rdcpos-log.qtfincar THEN
                    DO:
                        aux_dsdtexto = "Periodo de carencia de " + STRING(tt-rdcpos-log.qtinicar, "zz9") + " ate " + STRING(tt-rdcpos-log.qtfincar, "zz9") + " para " +
                                                                   STRING(tt-rdcpos.qtinicar, "zz9") + " ate " + STRING(tt-rdcpos.qtfincar, "zz9").
                    END.
                
                IF  tt-rdcpos.vliniapl <> tt-rdcpos-log.vliniapl OR
                    tt-rdcpos.vlfinapl <> tt-rdcpos-log.vlfinapl THEN
                    DO:
                        aux_dsdtexto = aux_dsdtexto + " Faixa de Valores de " + STRING(tt-rdcpos-log.vliniapl, "zzz,zzz,zz9.99") + " ate " + STRING(tt-rdcpos-log.vlfinapl, "zzz,zzz,zz9.99") + " para " +
                                                                                STRING(tt-rdcpos.vliniapl, "zzz,zzz,zz9.99") + " ate " + STRING(tt-rdcpos.vlfinapl, "zzz,zzz,zz9.99").
                    END.
                
                IF  aux_dsdtexto <> "" THEN
                    DO:
                        ASSIGN aux_flgalter = TRUE.

                        UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " " +
                                           STRING(TIME,"HH:MM:SS") + "' --> '"  +
                                           " Operador " + glb_cdoperad +
                                           " alterou o produto " + 
                                           UPPER(STRING(tt-rdcpos.dsaplica, "X(12)")) + " - " + aux_dsdtexto + "." + 
                                           " >> log/cadtax.log").
                    END.
            END.
        ELSE
            IF  tt-rdcpos.dsaplica <> "" THEN
                DO:
                    ASSIGN aux_flgalter = TRUE.

                    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " " +
                                       STRING(TIME,"HH:MM:SS") + "' --> '"  +
                                       " Operador " + glb_cdoperad +
                                       " criou o produto " + 
                                       UPPER(STRING(tt-rdcpos.dsaplica, "X(12)")) + "." + 
                                       " >> log/cadtax.log").
                END.
    END.

    IF  aux_flgalter THEN
        MESSAGE "Registros alterados com sucesso.".


END PROCEDURE.
 
