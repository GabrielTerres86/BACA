/* ..........................................................................

   Programa: fontes/dirfv.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Fevereiro/2005                    Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Ayllos.
   Objetivo  : Atende a solicitacao 50 ordem _. 
               Tela para visualizacao dos dados para DIRF.

   Alteracoes: 27/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               24/01/2006 - Incluido o total do ano para cada CPF/CGC (Julio)
               
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               12/09/2006 - Alteracao nos helps dos campos da tela (Elton).

               12/02/2007 - Totalizadores nao estavam sendo zerados para os 
                            relatorios (Julio).
                            
               28/02/2011 - Inclusao dos novos campos para atender novo layout
                            da DIRF 2011 (GATI - Daniel/Eder)
                            
               20/04/2011 - Inclusao de linha de TOTAL na visualizacao de tela
                          - Ordenacao dos meses apresentados (GATI).
                          
               20/01/2012 - Correcao na consulta DETALHADA por CPF/CNPJ
                            (Diego).
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
............................................................................ */

{ includes/var_online.i }

DEF STREAM str_1.

DEF   VAR tel_nranocal LIKE crapdrf.nranocal                         NO-UNDO.
DEF   VAR tel_tpdbusca AS CHAR FORMAT "x(14)"                        NO-UNDO.
DEF   VAR tel_tpdinfor AS CHAR FORMAT "x(14)"                        NO-UNDO.
DEF   VAR tel_nrcpfbnf LIKE crapdrf.nrcpfbnf                         NO-UNDO.
DEF   VAR tel_cdretenc LIKE crapdrf.cdretenc                         NO-UNDO.
DEF   VAR tel_tpimpres AS LOG  FORMAT "TELA/RELATORIO"  INIT TRUE    NO-UNDO.
DEF   VAR tel_nrcpfbn2 AS CHAR FORMAT "x(18)"                        NO-UNDO.

DEF   VAR aux_cddbusca AS INT                                        NO-UNDO.
DEF   VAR aux_dsdbusca AS CHAR EXTENT 3  FORMAT "x(12)"
                                         INIT ["CPF/CNPJ",
                                               "COD.RETENCAO",
                                               "TODOS"]              NO-UNDO.
DEF   VAR aux_cddinfor AS INT                                        NO-UNDO.
DEF   VAR aux_dsdinfor AS CHAR EXTENT 3  FORMAT "x(14)"
                                         INIT ["TOTAL POR COD.",
                                               "SOMADO",
                                               "DETALHADO"]          NO-UNDO.
DEF   VAR aux_contador AS INT                                        NO-UNDO.
DEF   VAR aux_confirma AS CHAR FORMAT "x"                            NO-UNDO. 
DEF   VAR aux_ultlinha AS INT                                        NO-UNDO.
DEF   VAR aux_dsorireg AS CHAR                                       NO-UNDO.
DEF   VAR aux_tporireg AS INT                                        NO-UNDO.
DEF   VAR aux_nrcpfbnf LIKE crapvir.nrcpfbnf                         NO-UNDO.
DEF   VAR aux_nrseqdig LIKE crapvir.nrseqdig                         NO-UNDO.
DEF   VAR aux_nmextmes AS CHAR FORMAT "X(12)"                        NO-UNDO.
DEF   VAR aux_nrmesref AS INTE                                       NO-UNDO.

DEF   VAR tot_vlrentri AS DECI FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF   VAR tot_vlcomimp AS DECI FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF   VAR tot_vltriexi AS DECI FORMAT "zzz,zzz,zz9.99"               NO-UNDO.
DEF   VAR tot_vlrenise AS DECI FORMAT "zzz,zzz,zz9.99"               NO-UNDO.

DEF   VAR aux_vlrentri LIKE tot_vlrentri                             NO-UNDO.
DEF   VAR aux_vlcomimp LIKE tot_vlcomimp                             NO-UNDO.
DEF   VAR aux_vltriexi LIKE tot_vltriexi                             NO-UNDO.
DEF   VAR aux_vlrenise LIKE tot_vlrenise                             NO-UNDO.


DEF   VAR tel_dspessoa AS CHAR EXTENT 3  INIT ["FISICA","JURIDICA",
                                               "AMBAS"]              NO-UNDO.

DEF   VAR tel_vlrdrtrt AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdrtpo AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdrtpp AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdrtdp AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdrtpa AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrrtirf AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdcjaa AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdcjac AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdesrt AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdespo AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdespp AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdesdp AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdespa AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdesir AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdesdj AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrridac AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrriirp AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrdriap AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrrimog AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF   VAR tel_vlrrip65 AS DEC FORMAT "zzz,zzz,zz9.99"                NO-UNDO.

DEF   VAR txt_rendtrib AS CHAR FORMAT "X(17)" 
                               INIT "Rend. Tributaveis" VIEW-AS TEXT NO-UNDO.

DEF   VAR txt_compimpo AS CHAR FORMAT "X(23)"
                               INIT "Compens. Imp. Dec. Jud."
                               VIEW-AS TEXT                          NO-UNDO. 

DEF   VAR txt_tribexig AS CHAR FORMAT "X(22)" 
                               INIT "Trib. Exigib. Suspensa"
                               VIEW-AS TEXT                          NO-UNDO.

DEF   VAR txt_rendisen AS CHAR FORMAT "X(19)" 
                               INIT "Rendimentos Isentos" 
                               VIEW-AS TEXT                          NO-UNDO.

/* lista dos codigos de retencao */
DEF QUERY q_retencao FOR gnrdirf.
DEF BROWSE b_retencao QUERY q_retencao
    DISPLAY gnrdirf.cdretenc NO-LABEL FORMAT "9999"
            gnrdirf.dsretenc NO-LABEL FORMAT "x(52)"
            tel_dspessoa[gnrdirf.inpessoa] NO-LABEL 
            WITH 10 DOWN.

DEF TEMP-TABLE cratdrf                                               NO-UNDO
    FIELD nranocal LIKE crapdrf.nranocal
    FIELD cdretenc LIKE crapdrf.cdretenc
    FIELD nrcpfbnf LIKE crapdrf.nrcpfbnf
    FIELD inpessoa LIKE crapdrf.inpessoa
    FIELD nrseqdig LIKE crapdrf.nrseqdig
    FIELD nmbenefi LIKE crapdrf.nmbenefi
    FIELD dsorireg AS CHAR.

DEF TEMP-TABLE cratvir                                               NO-UNDO
    LIKE crapvir
    INDEX ch_crapvir2 cdcooper
                      nranocal
                      cdretenc
                      nrcpfbnf
                      nrseqdig.

DEF TEMP-TABLE ttcabeca                                              NO-UNDO
    FIELD nranocal LIKE crapvir.nranocal
    FIELD cdretenc LIKE crapvir.cdretenc
    FIELD dsretenc LIKE gnrdirf.dsretenc
    FIELD nrcpfbnf LIKE crapvir.nrcpfbnf
    FIELD dscpfbnf AS   CHAR  FORMAT "x(18)"
    FIELD nmbenefi LIKE crapdrf.nmbenefi
    FIELD nrseqdig LIKE crapvir.nrseqdig
    INDEX ttcabeca1 nranocal cdretenc nrcpfbnf nrseqdig.

DEF TEMP-TABLE ttdetalh                                              NO-UNDO
    FIELD nranocal LIKE crapvir.nranocal
    FIELD cdretenc LIKE crapvir.cdreten
    FIELD nrcpfbnf LIKE crapvir.nrcpfbnf
    FIELD nrseqdig LIKE crapvir.nrseqdig
    FIELD nrmesref LIKE crapvir.nrmesref
    FIELD nmextmes AS CHAR  FORMAT "X(12)"
    FIELD vlrdrtrt AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdrtpo AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdrtpp AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdrtdp AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdrtpa AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrrtirf AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdcjaa AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdcjac AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdesrt AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdespo AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdespp AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdesdp AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdespa AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdesir AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdesdj AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrridac AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrriirp AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdriap AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrrimog AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrrip65 AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrtotrt AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrtotcj AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrtotes AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD vlrtotri AS DEC FORMAT "zzz,zzz,zz9.99"
    INDEX ttdetalh1 nranocal cdretenc nrcpfbnf nrseqdig nrmesref.

/* lista de registros */
DEF QUERY q_dirf FOR cratdrf.
DEF BROWSE b_dirf QUERY q_dirf
    DISPLAY cratdrf.nranocal COLUMN-LABEL "ANO"
            cratdrf.cdretenc COLUMN-LABEL "COD"
            cratdrf.nrcpfbnf COLUMN-LABEL "CPF/CNPJ"
            cratdrf.nmbenefi COLUMN-LABEL "NOME"        FORMAT "x(30)"
            cratdrf.dsorireg COLUMN-LABEL "ORIGEM"      FORMAT "x(10)"
            WITH 8 DOWN NO-BOX.

DEF TEMP-TABLE w_valores                                             NO-UNDO
    FIELD nrmesref AS INTE
    FIELD nmextmes AS CHAR    FORMAT "x(12)"
    FIELD vlrentri AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD vlcomimp AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD vltriexi AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD vlrenise AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    INDEX w_valores1 nrmesref.

/* lista dos valores de cada mes */
DEF QUERY q_detalhe FOR w_valores.
DEF BROWSE b_detalhe QUERY q_detalhe
    DISPLAY w_valores.nmextmes COLUMN-LABEL "MES"
            w_valores.vlrentri COLUMN-LABEL "REND. TRIBUT."
            w_valores.vlcomimp COLUMN-LABEL "COMPENS. IMP."
            w_valores.vltriexi COLUMN-LABEL "TRIBUT. EXIG."
            w_valores.vlrenise COLUMN-LABEL "REND. ISENTOS"
            WITH 8 DOWN NO-BOX WIDTH 75.

DEFINE RECTANGLE rtg_rendtrib 
    EDGE-CHARS 1
    GRAPHIC-EDGE
    NO-FILL
    SIZE 25 BY 9.

DEFINE RECTANGLE rtg_compimpo 
    EDGE-CHARS 1
    GRAPHIC-EDGE
    NO-FILL
    SIZE 25 BY 9.

DEFINE RECTANGLE rtg_tribexig 
    EDGE-CHARS 1
    GRAPHIC-EDGE
    NO-FILL
    SIZE 25 BY 9.

DEFINE RECTANGLE rtg_rendisen 
    EDGE-CHARS 1
    GRAPHIC-EDGE
    NO-FILL
    SIZE 77 BY 4.

FORM SKIP(1)

     rtg_rendtrib AT ROW  2 COL  1
     txt_rendtrib AT ROW  2 COL  5
     tel_vlrdrtrt AT ROW  3 COL  3 LABEL "RTRT"
     tel_vlrdrtpo AT ROW  4 COL  3 LABEL "RTPO"
     tel_vlrdrtpp AT ROW  5 COL  3 LABEL "RTPP"
     tel_vlrdrtdp AT ROW  6 COL  3 LABEL "RTDP"
     tel_vlrdrtpa AT ROW  7 COL  3 LABEL "RTPA"
     tel_vlrrtirf AT ROW  8 COL  2 LABEL "RTIRF"
                              
     rtg_compimpo AT ROW  2 COL 27
     txt_compimpo AT ROW  2 COL 28
     tel_vlrdcjaa AT ROW  3 COL 29 LABEL "CJAA"
     tel_vlrdcjac AT ROW  4 COL 29 LABEL "CJAC"
                              
     rtg_tribexig AT ROW  2 COL 53
     txt_tribexig AT ROW  2 COL 54
     tel_vlrdesrt AT ROW  3 COL 55 LABEL "ESRT"
     tel_vlrdespo AT ROW  4 COL 55 LABEL "ESPO" 
     tel_vlrdespp AT ROW  5 COL 55 LABEL "ESPP"
     tel_vlrdesdp AT ROW  6 COL 55 LABEL "ESDP"
     tel_vlrdespa AT ROW  7 COL 55 LABEL "ESPA"
     tel_vlrdesir AT ROW  8 COL 55 LABEL "ESIR"
     tel_vlrdesdj AT ROW  9 COL 55 LABEL "ESDJ"

     rtg_rendisen AT ROW 11 COL  1
     txt_rendisen AT ROW 11 COL  4
     tel_vlrridac AT ROW 12 COL  2 LABEL "RIDAC"
     tel_vlrriirp AT ROW 12 COL 28 LABEL "RIIRP"
     tel_vlrdriap AT ROW 12 COL 55 LABEL "RIAP"
     tel_vlrrimog AT ROW 13 COL  2 LABEL "RIMOG"
     tel_vlrrip65 AT ROW 13 COL 28 LABEL "RIP65"
     WITH WIDTH 80 OVERLAY ROW 5 CENTERED NO-LABELS SIDE-LABELS
     TITLE "DETALHE DADOS DIRF" FRAME f_digitacao.


FORM SKIP(1)
     tel_nranocal    AT 30  LABEL "Ano"
         HELP "Informe o ano que deseja pesquisar ou '0' zero para todos."
     SKIP(1)
     tel_tpdbusca    AT 20  LABEL "Tipo da Busca"
         HELP "Selecione o tipo de busca (use setas para cima ou para baixo)."
     SKIP(1)
     tel_tpdinfor    AT 21  LABEL "Tipo de Inf."
         HELP "Selecione o tipo de informacao (use setas p/cima ou p/baixo)."
     SKIP(1)
     tel_tpimpres    AT 22  LABEL "Imprimir em"
         HELP "Selecione 'Tela' p/visualizar ou 'Relatorio' p/imprimir." 
     SKIP(1)
     tel_nrcpfbnf    AT 25  LABEL "CPF/CNPJ"
     tel_cdretenc    AT 21  LABEL "Cod.Retencao"
     SKIP(4)
     WITH WIDTH 78 OVERLAY ROW 5 CENTERED NO-LABELS SIDE-LABELS 
          TITLE "VISUALIZACAO DE DADOS DIRF" FRAME f_visualizar.

FORM b_dirf      
         HELP "Pressione ENTER p/ detalhar | DELETE p/ excluir | F4 p/ sair"
     WITH NO-LABELS OVERLAY ROW 10 CENTERED FRAME f_dirf.

FORM b_retencao  HELP "Pressione ENTER para selecionar / F4 para sair"
     WITH NO-BOX NO-LABELS OVERLAY ROW 10 CENTERED FRAME f_codigos.

FORM cratdrf.nranocal AT  8 LABEL "ANO"
     SKIP
     cratdrf.cdretenc AT  5 LABEL "CODIGO"
     "-"
     gnrdirf.dsretenc AT 20 NO-LABEL            FORMAT "x(56)"
     SKIP
     tel_nrcpfbn2     AT  3 LABEL "CPF/CNPJ"
     SKIP
     cratdrf.nmbenefi AT  7 LABEL "NOME"
     SKIP(1)
     b_detalhe        AT  1 HELP "ENTER para detalhar valores / F4 para sair"
     WITH NO-BOX NO-LABELS SIDE-LABELS OVERLAY ROW 6 CENTERED WIDTH 76
          FRAME f_detalhe.

FORM SKIP(1)
     tel_nrcpfbnf    AT  5  LABEL "CPF/CNPJ"
                            HELP "Informe o CPF/CNPJ do beneficiario"
                            VALIDATE(INPUT tel_nrcpfbnf > 0,
                                     "375 - O campo deve ser preenchido.")
     SKIP
     tel_cdretenc    AT  8  LABEL "Cod.Retencao"
                           HELP "Informe o codigo de retencao / F7 para listar"
                           VALIDATE(CAN-FIND(gnrdirf WHERE gnrdirf.cdretenc =
                                                           INPUT tel_cdretenc),
                                    "Codigo de Retencao nao encontrado")
     SKIP(1)
     WITH NO-LABELS SIDE-LABELS OVERLAY ROW 10 CENTERED WIDTH 35 
          FRAME f_cpf_cod.

ON RETURN OF b_dirf DO:

    IF   NOT AVAILABLE cratdrf   THEN
         RETURN.
    
    /* Tratamento de CPF/CGC */
    IF   cratdrf.nrcpfbnf > 0   THEN
         DO:
            IF   cratdrf.inpessoa = 1   THEN
                 ASSIGN  tel_nrcpfbn2 = STRING(cratdrf.nrcpfbnf,"99999999999")
                         tel_nrcpfbn2 = STRING(tel_nrcpfbn2,
                                                        "    xxx.xxx.xxx-xx").
            ELSE
                 ASSIGN  tel_nrcpfbn2 = STRING(cratdrf.nrcpfbnf,
                                                        "99999999999999")
                         tel_nrcpfbn2 = STRING(tel_nrcpfbn2,
                                                        "xx.xxx.xxx/xxxx-xx").
         END.
    ELSE
         ASSIGN tel_nrcpfbn2 = "".


    HIDE FRAME f_dirf NO-PAUSE.

    /* limpar a tabela temporaria */
    EMPTY TEMP-TABLE w_valores.
    ASSIGN tot_vlrentri = 0
           tot_vlcomimp = 0
           tot_vltriexi = 0
           tot_vlrenise = 0.

    CASE aux_cddinfor:
         WHEN 1 THEN /* TOTAL POR COD. */ 
              ASSIGN aux_nrseqdig = ?.
         WHEN 2 THEN /* SOMADO */         
              ASSIGN aux_nrseqdig = ?.
         WHEN 3 THEN /* DETALHADO */      
              ASSIGN aux_nrseqdig = cratdrf.nrseqdig .
    END CASE. /* CASE aux_cddinfor: */

    FOR EACH cratvir WHERE
             cratvir.cdcooper = glb_cdcooper                        AND
             cratvir.nranocal = cratdrf.nranocal                    AND 
             cratvir.cdretenc = cratdrf.cdretenc                    AND 
            (cratvir.nrcpfbnf = cratdrf.nrcpfbnf
             OR cratdrf.nrcpfbnf = 0)                               AND
            ((aux_nrseqdig <> ? AND cratvir.nrseqdig = aux_nrseqdig)
             OR aux_nrseqdig = ?)                                   NO-LOCK:
    
        CASE cratvir.nrmesref:
             WHEN  1 THEN ASSIGN aux_nmextmes = "JANEIRO".
             WHEN  2 THEN ASSIGN aux_nmextmes = "FEVEREIRO".
             WHEN  3 THEN ASSIGN aux_nmextmes = "MARCO".
             WHEN  4 THEN ASSIGN aux_nmextmes = "ABRIL".
             WHEN  5 THEN ASSIGN aux_nmextmes = "MAIO".
             WHEN  6 THEN ASSIGN aux_nmextmes = "JUNHO".
             WHEN  7 THEN ASSIGN aux_nmextmes = "JULHO".
             WHEN  8 THEN ASSIGN aux_nmextmes = "AGOSTO".
             WHEN  9 THEN ASSIGN aux_nmextmes = "SETEMBRO".
             WHEN 10 THEN ASSIGN aux_nmextmes = "OUTUBRO".
             WHEN 11 THEN ASSIGN aux_nmextmes = "NOVEMBRO".
             WHEN 12 THEN ASSIGN aux_nmextmes = "DEZEMBRO".
             WHEN 13 THEN ASSIGN aux_nmextmes = "13o.SALARIO".
        END CASE.

        FIND w_valores WHERE
             w_valores.nrmesref = cratvir.nrmesref NO-ERROR.
        IF   NOT AVAIL w_valores   THEN
             DO:
                CREATE w_valores.
                ASSIGN w_valores.nrmesref = cratvir.nrmesref.
             END.

        ASSIGN w_valores.nmextmes = aux_nmextmes

               aux_vlrentri       = cratvir.vlrdrtrt / 100 +
                                    cratvir.vlrdrtpo / 100 +
                                    cratvir.vlrdrtpp / 100 +
                                    cratvir.vlrdrtdp / 100 +
                                    cratvir.vlrdrtpa / 100 +
                                    cratvir.vlrrtirf / 100 
                                  
               aux_vlcomimp       = cratvir.vlrdcjaa / 100 +
                                    cratvir.vlrdcjac / 100
                                  
               aux_vltriexi       = cratvir.vlrdesrt / 100 +
                                    cratvir.vlrdespo / 100 +
                                    cratvir.vlrdespp / 100 +
                                    cratvir.vlrdesdp / 100 +
                                    cratvir.vlrdespa / 100 +
                                    cratvir.vlrdesir / 100 +
                                    cratvir.vlrdesdj / 100
                                  
               aux_vlrenise       = cratvir.vlrridac / 100 +
                                    cratvir.vlrriirp / 100 +
                                    cratvir.vlrdriap / 100 +
                                    cratvir.vlrrimog / 100 +
                                    cratvir.vlrrip65 / 100

               w_valores.vlrentri = w_valores.vlrentri + aux_vlrentri
               w_valores.vlcomimp = w_valores.vlcomimp + aux_vlcomimp
               w_valores.vltriexi = w_valores.vltriexi + aux_vltriexi
               w_valores.vlrenise = w_valores.vlrenise + aux_vlrenise

               tot_vlrentri       = tot_vlrentri + aux_vlrentri
               tot_vlcomimp       = tot_vlcomimp + aux_vlcomimp
               tot_vltriexi       = tot_vltriexi + aux_vltriexi
               tot_vlrenise       = tot_vlrenise + aux_vlrenise.

    END. /* FOR EACH cratvir */

    /* Registro com os totais */
    CREATE w_valores.
    ASSIGN w_valores.nrmesref = 14
           w_valores.nmextmes = "TOTAL"
           w_valores.vlrentri = tot_vlrentri
           w_valores.vlcomimp = tot_vlcomimp
           w_valores.vltriexi = tot_vltriexi
           w_valores.vlrenise = tot_vlrenise.
    
    OPEN QUERY q_detalhe FOR EACH w_valores NO-LOCK BY w_valores.nrmesref.
    
    FIND gnrdirf WHERE gnrdirf.cdretenc = cratdrf.cdretenc NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE gnrdirf   THEN
         DO:
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 MESSAGE "Codigo de retencao nao cadastrado!".
                 PAUSE(2) NO-MESSAGE.
                 LEAVE.
             END.
             
             APPLY "END-ERROR".
         END.

    HIDE tel_nrcpfbn2     IN FRAME f_detalhe.
    HIDE cratdrf.nmbenefi IN FRAME f_detalhe.

    DISPLAY cratdrf.nranocal
            cratdrf.cdretenc
            gnrdirf.dsretenc
            tel_nrcpfbn2      WHEN tel_nrcpfbn2     <> ""
            cratdrf.nmbenefi  WHEN cratdrf.nmbenefi <> ""
            WITH FRAME f_detalhe.
    
    DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
         UPDATE b_detalhe WITH FRAME f_detalhe.
    END.
    
    HIDE FRAME f_digitacao NO-PAUSE.
    HIDE FRAME f_detalhe   NO-PAUSE.
    VIEW FRAME f_dirf.
END.

ON RETURN OF b_detalhe
DO:
    ASSIGN tel_vlrdrtrt = 0  
           tel_vlrdrtpo = 0  
           tel_vlrdrtpp = 0  
           tel_vlrdrtdp = 0  
           tel_vlrdrtpa = 0  
           tel_vlrrtirf = 0    
           tel_vlrdcjaa = 0                    
           tel_vlrdcjac = 0                    
           tel_vlrdesrt = 0  
           tel_vlrdespo = 0    
           tel_vlrdespp = 0                    
           tel_vlrdesdp = 0  
           tel_vlrdespa = 0  
           tel_vlrdesir = 0  
           tel_vlrdesdj = 0  
           tel_vlrridac = 0     
           tel_vlrriirp = 0   
           tel_vlrdriap = 0     
           tel_vlrrimog = 0                     
           tel_vlrrip65 = 0.

    FOR EACH cratvir WHERE
             cratvir.cdcooper = glb_cdcooper                        AND
             cratvir.nranocal = cratdrf.nranocal                    AND 
             cratvir.cdretenc = cratdrf.cdretenc                    AND
            (cratvir.nrcpfbnf = cratdrf.nrcpfbnf
             OR cratdrf.nrcpfbnf = 0)                               AND
           ((w_valores.nrmesref < 14 AND cratvir.nrmesref = w_valores.nrmesref)
             OR w_valores.nrmesref = 14)                            AND
           ((aux_nrseqdig    <> ? AND cratvir.nrseqdig = aux_nrseqdig)
             OR aux_nrseqdig = ?)                                   NO-LOCK:

         ASSIGN tel_vlrdrtrt = tel_vlrdrtrt + cratvir.vlrdrtrt / 100
                tel_vlrdrtpo = tel_vlrdrtpo + cratvir.vlrdrtpo / 100
                tel_vlrdrtpp = tel_vlrdrtpp + cratvir.vlrdrtpp / 100
                tel_vlrdrtdp = tel_vlrdrtdp + cratvir.vlrdrtdp / 100
                tel_vlrdrtpa = tel_vlrdrtpa + cratvir.vlrdrtpa / 100
                tel_vlrrtirf = tel_vlrrtirf + cratvir.vlrrtirf / 100 
                tel_vlrdcjaa = tel_vlrdcjaa + cratvir.vlrdcjaa / 100 
                tel_vlrdcjac = tel_vlrdcjac + cratvir.vlrdcjac / 100 
                tel_vlrdesrt = tel_vlrdesrt + cratvir.vlrdesrt / 100
                tel_vlrdespo = tel_vlrdespo + cratvir.vlrdespo / 100 
                tel_vlrdespp = tel_vlrdespp + cratvir.vlrdespp / 100 
                tel_vlrdesdp = tel_vlrdesdp + cratvir.vlrdesdp / 100
                tel_vlrdespa = tel_vlrdespa + cratvir.vlrdespa / 100
                tel_vlrdesir = tel_vlrdesir + cratvir.vlrdesir / 100
                tel_vlrdesdj = tel_vlrdesdj + cratvir.vlrdesdj / 100
                tel_vlrridac = tel_vlrridac + cratvir.vlrridac / 100 
                tel_vlrriirp = tel_vlrriirp + cratvir.vlrriirp / 100 
                tel_vlrdriap = tel_vlrdriap + cratvir.vlrdriap / 100 
                tel_vlrrimog = tel_vlrrimog + cratvir.vlrrimog / 100 
                tel_vlrrip65 = tel_vlrrip65 + cratvir.vlrrip65 / 100.
    END.

    ASSIGN FRAME f_digitacao:TITLE = "DETALHE DADOS DIRF - " +
                                     w_valores.nmextmes.
    
    DISP txt_rendtrib    
         tel_vlrdrtrt       
         tel_vlrdrtpo       
         tel_vlrdrtpp       
         tel_vlrdrtdp       
         tel_vlrdrtpa       
         tel_vlrrtirf      
                        
         txt_compimpo  
         tel_vlrdcjaa       
         tel_vlrdcjac       
                        
         txt_tribexig    
         tel_vlrdesrt       
         tel_vlrdespo       
         tel_vlrdespp       
         tel_vlrdesdp       
         tel_vlrdespa       
         tel_vlrdesir       
         tel_vlrdesdj       
         
         txt_rendisen   
         tel_vlrridac      
         tel_vlrriirp      
         tel_vlrdriap       
         tel_vlrrimog      
         tel_vlrrip65
         WITH FRAME f_digitacao.

    DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
         PAUSE MESSAGE "Pressione qualquer tecla para continuar...".
         LEAVE.
    END.

    HIDE FRAME f_digitacao NO-PAUSE.
END.

ON "DELETE" OF b_dirf DO:

    IF   CAN-FIND(crapdrf where crapdrf.cdcooper = glb_cdcooper      AND
                                crapdrf.nranocal = cratdrf.nranocal  AND
                                crapdrf.tpregist = 1                 AND
                                TRIM(crapdrf.dsobserv) <> "")        THEN
         DO:
             MESSAGE "A DIRF para o ano calendario em questao"
                     "ja esta finalizada!".
             PAUSE NO-MESSAGE.
             HIDE MESSAGE.
             LEAVE.
         END.                       

    /* verificacao de autorizacao */
    ASSIGN glb_cddopcao = "E".
    
    { includes/acesso.i }
    
    IF   NOT AVAILABLE cratdrf   THEN
         RETURN.
    
    IF   aux_cddinfor <> 3   THEN   /* se estiverem agrupados */
         DO:
            MESSAGE "Ha registros agrupados! Todos que foram digitados"
                    "serao excluidos!".
         END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       aux_confirma = "N".
       glb_cdcritic = 78.
       RUN fontes/critic.p.
       BELL.
       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
       LEAVE.
    END.

    IF   aux_confirma <> "S"   THEN
         NEXT.

    FOR EACH crapdrf WHERE crapdrf.cdcooper = glb_cdcooper      AND
                           crapdrf.nranocal = cratdrf.nranocal  AND
                           crapdrf.cdretenc = cratdrf.cdretenc  AND
                         ((aux_cddinfor = 3                     AND 
                           crapdrf.nrcpfbnf = cratdrf.nrcpfbnf  AND
                           crapdrf.nrseqdig = cratdrf.nrseqdig) OR
                          (aux_cddinfor = 2                     AND 
                           crapdrf.nrcpfbnf = cratdrf.nrcpfbnf) OR
                           aux_cddinfor = 1)                    EXCLUSIVE-LOCK:

        IF   aux_cddinfor = 3        AND
             crapdrf.tporireg <> 2   THEN
             DO:
                MESSAGE "Somente eh permitido excluir registros digitados!".
                RETURN.
             END.

        IF   aux_cddinfor = 2 OR aux_cddinfor = 3   THEN     
             DO:
                 FOR EACH crapvir WHERE 
                          crapvir.cdcooper = crapdrf.cdcooper  AND
                          crapvir.nrcpfbnf = crapdrf.nrcpfbnf  AND
                          crapvir.nranocal = crapdrf.nranocal  AND
                          crapvir.cdretenc = crapdrf.cdretenc  EXCLUSIVE-LOCK
                          USE-INDEX crapvir1:
                          
                     IF  aux_cddinfor = 2 OR
                        (aux_cddinfor = 3 AND 
                         crapvir.nrseqdig = crapdrf.nrseqdig)   THEN
                         DO:                                            
                             DELETE crapvir.
                         END.
                 END.          
             END.
        ELSE
             IF   aux_cddinfor = 1   THEN
                  DO:
                      FOR EACH crapvir WHERE 
                               crapvir.cdcooper = crapdrf.cdcooper  AND
                               crapvir.nranocal = crapdrf.nranocal  AND
                               crapvir.cdretenc = crapdrf.cdretenc
                               EXCLUSIVE-LOCK  USE-INDEX crapvir1:
      
                          DELETE crapvir.     
                      END.
                  END.
        
        DELETE crapdrf.
    
    END.  
    
    /* linha que foi deletada */
    aux_ultlinha = CURRENT-RESULT-ROW("q_dirf").
    
    RUN pi_carrega_temp_dados.
    
    /* reposiciona o browse */
    REPOSITION q_dirf TO ROW aux_ultlinha.
END.

ON RETURN OF b_retencao DO:

    tel_cdretenc = gnrdirf.cdretenc.
    DISPLAY tel_cdretenc WITH FRAME f_cpf_cod.

    APPLY "GO".
END.

ON VALUE-CHANGED OF b_dirf DO:

    HIDE MESSAGE NO-PAUSE.
END.

ON LEAVE OF tel_tpdbusca DO:

   ASSIGN tel_nrcpfbnf = 0
          tel_cdretenc = 0.
   
   HIDE tel_nrcpfbnf IN FRAME f_cpf_cod.
   HIDE tel_cdretenc IN FRAME f_cpf_cod.
   HIDE tel_nrcpfbnf IN FRAME f_visualizar.
   HIDE tel_cdretenc IN FRAME f_visualizar.
   
   PAUSE(0).
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       IF   aux_cddbusca = 1   THEN    /* CPF/CNPJ */
            UPDATE tel_nrcpfbnf WITH FRAME f_cpf_cod.
       ELSE
       IF   aux_cddbusca = 2   THEN    /* COD RETENCAO */
            UPDATE tel_cdretenc WITH FRAME f_cpf_cod
            
            EDITING:
            
                DO WHILE TRUE:
                     
                    READKEY PAUSE 1.
                  
                    IF   LASTKEY = KEYCODE("F7")        AND
                         FRAME-FIELD = "tel_cdretenc"   THEN
                         DO:
                             OPEN QUERY q_retencao FOR EACH gnrdirf NO-LOCK.
                            
                             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                UPDATE b_retencao WITH FRAME f_codigos.
                                LEAVE.
                             END.
                     
                             HIDE FRAME f_codigos.
                             NEXT.
                         END.

                    APPLY LASTKEY.
                           
                    LEAVE.

                END. /* fim DO WHILE */
            END. /* fim do EDITING */

       LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            ASSIGN aux_cddbusca = 3
                   tel_tpdbusca = aux_dsdbusca[aux_cddbusca].
                   
            DISPLAY tel_tpdbusca WITH FRAME f_visualizar.
        END.
   ELSE
        DO:
            /* mostra o campo escolhido na tela */
            IF   tel_nrcpfbnf > 0   THEN
                 DISPLAY tel_nrcpfbnf WITH FRAME f_visualizar.
            ELSE
            IF   tel_cdretenc > 0   THEN
                 DISPLAY tel_cdretenc WITH FRAME f_visualizar.
        END.

END.

ASSIGN glb_cddopcao = "V"
       aux_cddbusca = IF   aux_cddbusca = 0   THEN
                           3           /* para iniciar o tipo como TODOS */
                      ELSE aux_cddbusca
       aux_cddinfor = IF   aux_cddinfor = 0   THEN
                           3           /* para iniciar com DETALHADO */
                      ELSE aux_cddinfor.

{ includes/acesso.i }

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     RETURN.

ASSIGN tel_tpdbusca = aux_dsdbusca[aux_cddbusca]
       tel_tpdinfor = aux_dsdinfor[aux_cddinfor].

HIDE MESSAGE NO-PAUSE.


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   HIDE tel_nrcpfbnf IN FRAME f_visualizar.
   HIDE tel_cdretenc IN FRAME f_visualizar.
   
   UPDATE tel_nranocal          
          tel_tpdbusca
          tel_tpdinfor
          tel_tpimpres
          WITH FRAME f_visualizar

   EDITING:
            
       DO WHILE TRUE:
               
           READKEY PAUSE 1.
             
           /* rolagem do tipo de busca */
           IF   FRAME-FIELD = "tel_tpdbusca"  THEN
                DO:
                   IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   THEN
                        aux_cddbusca = aux_cddbusca + 1.
                   ELSE
                   IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"   THEN
                        aux_cddbusca = aux_cddbusca - 1.
                
                   /* para rolar as opcoes infinitamente */
                   IF   aux_cddbusca = 4   THEN
                        aux_cddbusca = 1.
                   ELSE
                   IF   aux_cddbusca = 0   THEN
                        aux_cddbusca = 3.
              
                   tel_tpdbusca = aux_dsdbusca[aux_cddbusca].
                   
                   DISPLAY tel_tpdbusca WITH FRAME f_visualizar.
                END.
                
           /* rolagem do tipo de informacao */
           IF   FRAME-FIELD = "tel_tpdinfor"  THEN
                DO:
                   IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   THEN
                        aux_cddinfor = aux_cddinfor + 1.
                   ELSE
                   IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"   THEN
                        aux_cddinfor = aux_cddinfor - 1.
                
                   /* para rolar as opcoes infinitamente */
                   IF   aux_cddinfor = 4   THEN
                        aux_cddinfor = 1.
                   ELSE
                   IF   aux_cddinfor = 0   THEN
                        aux_cddinfor = 3.
              
                   tel_tpdinfor = aux_dsdinfor[aux_cddinfor].
                   
                   DISPLAY tel_tpdinfor WITH FRAME f_visualizar.
                END.
                
           /* rolagem do tipo de impressao */
           IF   FRAME-FIELD = "tel_tpimpres"  THEN
                IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                     KEYFUNCTION(LASTKEY) = "CURSOR-UP"     THEN
                     DO:
                        tel_tpimpres = NOT tel_tpimpres.
                        DISPLAY tel_tpimpres WITH FRAME f_visualizar.
                     END.
           
           /* para nao trocar de campo */
           IF   NOT KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   AND
                NOT KEYFUNCTION(LASTKEY) = "CURSOR-UP"     THEN
                APPLY LASTKEY.
                          
           LEAVE.

       END. /* fim DO WHILE */
   END. /* fim do EDITING */

   MESSAGE "Aguarde...".
   RUN pi_carrega_temp_dados.
   
   IF   tel_tpimpres = YES   THEN       /* impressao na TELA */
        DO:
           HIDE MESSAGE NO-PAUSE.
           PAUSE(0).
         
           UPDATE b_dirf WITH FRAME f_dirf.
        END.
   ELSE
        RUN gera_rel.

END. /* fim do DO WHILE principal */

HIDE FRAME f_visualizar NO-PAUSE.

PROCEDURE pi_carrega_temp_dados:

    /* limpa a temp-table */
    EMPTY TEMP-TABLE cratdrf.
    EMPTY TEMP-TABLE cratvir.

    FOR EACH crapdrf WHERE
             crapdrf.cdcooper = glb_cdcooper                        AND
             crapdrf.tpregist = 2                                   AND
            (crapdrf.nranocal = tel_nranocal OR tel_nranocal = 0)   AND
           ((aux_cddbusca = 1 AND crapdrf.nrcpfbnf = tel_nrcpfbnf)  OR
            (aux_cddbusca = 2 AND crapdrf.cdretenc = tel_cdretenc)  OR
             aux_cddbusca = 3)                                      NO-LOCK
             BREAK BY crapdrf.nranocal
                      BY crapdrf.cdretenc
                         BY crapdrf.nrcpfbnf:
                                               
        IF  (aux_cddinfor = 1   AND   FIRST-OF(crapdrf.cdretenc))   OR
            (aux_cddinfor = 2   AND   FIRST-OF(crapdrf.nrcpfbnf))   OR
             aux_cddinfor = 3                                       THEN
             ASSIGN aux_tporireg = crapdrf.tporireg
                    aux_dsorireg = "".
                    
        /* se tiverem tipos diferentes entao sao AGRUPADOS */
        IF   aux_tporireg <> crapdrf.tporireg   THEN
             aux_dsorireg = "AGRUPADOS".

        IF  (aux_cddinfor = 1   AND   NOT LAST-OF(crapdrf.cdretenc))   OR
            (aux_cddinfor = 2   AND   NOT LAST-OF(crapdrf.nrcpfbnf))   THEN
             NEXT.

        CREATE cratdrf.
        ASSIGN cratdrf.nranocal = crapdrf.nranocal
               cratdrf.cdretenc = crapdrf.cdretenc
               cratdrf.nrcpfbnf = IF aux_cddinfor  = 1 AND
                                     aux_cddbusca  <> 1 THEN 
                                     0
                                  ELSE 
                                     crapdrf.nrcpfbnf
               cratdrf.inpessoa = crapdrf.inpessoa
               cratdrf.nmbenefi = IF aux_cddinfor  = 1 AND
                                     aux_cddbusca  <> 1 THEN
                                     ""
                                  ELSE
                                     crapdrf.nmbenefi
               cratdrf.nrseqdig = crapdrf.nrseqdig.

        
        /* Descricao da origem do registro */
        IF   aux_dsorireg = ""   THEN
             DO:
                IF   crapdrf.tporireg = 1   THEN
                     aux_dsorireg = "AYLLOS".
                ELSE
                IF   crapdrf.tporireg = 2   THEN
                     aux_dsorireg = "DIGITACAO".
                ELSE
                     aux_dsorireg = "INTEGRACAO".
             END.
             
        ASSIGN cratdrf.dsorireg = aux_dsorireg.

        /* Cria cratvir */
        /*FOR EACH crapvir OF crapdrf NO-LOCK:*/
        IF   cratdrf.nrcpfbnf <> 0  THEN
             DO:
                 FOR EACH crapvir WHERE
                          crapvir.cdcooper = crapdrf.cdcooper   AND 
                          crapvir.nranocal = cratdrf.nranocal   AND 
                          crapvir.cdretenc = cratdrf.cdretenc   AND 
                          crapvir.nrcpfbnf = cratdrf.nrcpfbnf   AND
                        ((aux_cddinfor = 3 AND   /* DETALHADO */
                          crapvir.nrseqdig = cratdrf.nrseqdig) OR
                          aux_cddinfor <> 3)  NO-LOCK:
                          
                     CREATE cratvir.
                     BUFFER-COPY crapvir TO cratvir.
                 END.
             END.
        ELSE
             DO:
                 FOR EACH crapvir WHERE
                          crapvir.cdcooper = crapdrf.cdcooper   AND 
                          crapvir.nranocal = cratdrf.nranocal   AND 
                          crapvir.cdretenc = cratdrf.cdretenc
                          NO-LOCK:
                          
                     CREATE cratvir.
                     BUFFER-COPY crapvir TO cratvir.
                 END.             
             END.
    END.                                               

    OPEN QUERY q_dirf FOR EACH cratdrf.

END. /* PROCEDURE pi_carrega_temp_dados: */

PROCEDURE gera_rel:

    DEF    VAR aux_nmarqimp     AS CHAR                               NO-UNDO.
    DEF    VAR aux_nmendter     AS CHAR    FORMAT "x(20)"             NO-UNDO.
    DEF    VAR aux_totpagin     AS INT                                NO-UNDO.
    DEF    VAR aux_regexist     AS LOGICAL                            NO-UNDO.

    DEF    VAR rel_vlrendim     AS DECIMAL EXTENT 14                  NO-UNDO.
    DEF    VAR rel_vldeduca     AS DECIMAL EXTENT 14                  NO-UNDO.
    DEF    VAR rel_vlimpost     AS DECIMAL EXTENT 14                  NO-UNDO.
    DEF    VAR rel_dsopcoes     AS CHAR                               NO-UNDO.
    
    /* variaveis para includes/impressao.i */
    DEF    VAR par_flgrodar     AS LOGICAL INIT TRUE                  NO-UNDO.
    DEF    VAR aux_flgescra     AS LOGICAL                            NO-UNDO.
    DEF    VAR aux_dscomand     AS CHAR                               NO-UNDO.
    DEF    VAR par_flgfirst     AS LOGICAL INIT TRUE                  NO-UNDO.
    DEF    VAR tel_dsimprim     AS CHAR FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
    DEF    VAR tel_dscancel     AS CHAR FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
    DEF    VAR par_flgcance     AS LOGICAL                            NO-UNDO.

    FORM HEADER
         crapcop.nmrescop
         "- RELACAO DOS DADOS DIRF"
         rel_dsopcoes           FORMAT "x(80)"
         "PAG.:"       AT 122
         PAGE-NUMBER(str_1)     FORMAT "99999"
         SKIP(2)
         WITH PAGE-TOP NO-BOX NO-LABELS WIDTH 132 FRAME f_cab.
    
    FORM ttcabeca.nranocal AT  8 LABEL "ANO"
         ttcabeca.cdretenc AT 41 LABEL "CODIGO"
         "-"
         ttcabeca.dsretenc AT 56 NO-LABEL            FORMAT "x(70)"
         WITH DOWN NO-BOX SIDE-LABELS WIDTH 132 FRAME f_rel.

    FORM SKIP(1) "RENDIMENTOS TRIBUTAVEIS" SKIP(1)
         WITH DOWN NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_cab_rendtrib.

    FORM ttdetalh.nmextmes COLUMN-LABEL "MES"
         ttdetalh.vlrdrtrt COLUMN-LABEL "RTRT"
         ttdetalh.vlrdrtpo COLUMN-LABEL "RTPO"
         ttdetalh.vlrdrtpp COLUMN-LABEL "RTPP"
         ttdetalh.vlrdrtdp COLUMN-LABEL "RTDP"
         ttdetalh.vlrdrtpa COLUMN-LABEL "RTPA"
         ttdetalh.vlrrtirf COLUMN-LABEL "RTIRF"
         WITH DOWN NO-BOX WIDTH 132 FRAME f_det_rendtrib NO-UNDERLINE.

    FORM SKIP(1) "COMPENSACAO DE IMPOSTO POR DECISAO JUDICIAL" SKIP(1)
         WITH DOWN NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_cab_compimpo.

    FORM ttdetalh.nmextmes COLUMN-LABEL "MES"
         ttdetalh.vlrdcjac COLUMN-LABEL "CJAC"
         ttdetalh.vlrdcjaa COLUMN-LABEL "CJAA"
         WITH DOWN NO-BOX WIDTH 132 FRAME f_det_compimpo NO-UNDERLINE.

    FORM SKIP(1) "TRIBUTACAO COM EXIGIBILIDADE SUSPENSA" SKIP(1)
         WITH DOWN NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_cab_tribexib.

    FORM ttdetalh.nmextmes COLUMN-LABEL "MES"
         ttdetalh.vlrdesrt COLUMN-LABEL "ESRT"
         ttdetalh.vlrdespo COLUMN-LABEL "ESPO"
         ttdetalh.vlrdespp COLUMN-LABEL "ESPP"
         ttdetalh.vlrdesdp COLUMN-LABEL "ESDP"
         ttdetalh.vlrdespa COLUMN-LABEL "ESPA"
         ttdetalh.vlrdesir COLUMN-LABEL "ESIR"
         ttdetalh.vlrdesdj COLUMN-LABEL "ESDJ"
         WITH DOWN NO-BOX WIDTH 132 FRAME f_det_tribexib NO-UNDERLINE.

    FORM SKIP(1) "RENDIMENTOS ISENTOS" SKIP(1)
         WITH DOWN NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_cab_rendisen.

    FORM ttdetalh.nmextmes COLUMN-LABEL "MES" 
         ttdetalh.vlrridac COLUMN-LABEL "RIDAC"
         ttdetalh.vlrriirp COLUMN-LABEL "RIIRP"
         ttdetalh.vlrdriap COLUMN-LABEL "RIAP"
         ttdetalh.vlrrimog COLUMN-LABEL "RIMOG"
         ttdetalh.vlrrip65 COLUMN-LABEL "RIP65"
         WITH DOWN NO-BOX WIDTH 132 FRAME f_det_rendisen NO-UNDERLINE.

    EMPTY TEMP-TABLE ttdetalh.
    EMPTY TEMP-TABLE ttcabeca.

    FOR EACH cratdrf:

        CASE aux_cddinfor:
             WHEN 1 THEN /* TOTAL POR COD. */ 
                  ASSIGN aux_nrseqdig = ?.
             WHEN 2 THEN /* SOMADO */         
                  ASSIGN aux_nrseqdig = ?.
             WHEN 3 THEN /* DETALHADO */      
                  ASSIGN aux_nrseqdig = cratdrf.nrseqdig .
        END CASE. /* CASE aux_cddinfor: */
        

        FOR EACH cratvir WHERE
                 cratvir.cdcooper = glb_cdcooper                        AND
                 cratvir.nranocal = cratdrf.nranocal                    AND 
                 cratvir.cdretenc = cratdrf.cdretenc                    AND 
                (cratvir.nrcpfbnf = cratdrf.nrcpfbnf
                 OR cratdrf.nrcpfbnf = 0)                               AND
                ((aux_nrseqdig <> ? AND cratvir.nrseqdig = aux_nrseqdig)
                 OR aux_nrseqdig = ?)                                   NO-LOCK:
            
            IF   cratvir.vlrdrtrt = 0   AND
                 cratvir.vlrdrtpo = 0   AND 
                 cratvir.vlrdrtpp = 0   AND
                 cratvir.vlrdrtdp = 0   AND
                 cratvir.vlrdrtpa = 0   AND
                 cratvir.vlrrtirf = 0   AND
                 cratvir.vlrdcjaa = 0   AND
                 cratvir.vlrdcjac = 0   AND
                 cratvir.vlrdesrt = 0   AND
                 cratvir.vlrdespo = 0   AND
                 cratvir.vlrdespp = 0   AND
                 cratvir.vlrdesdp = 0   AND
                 cratvir.vlrdespa = 0   AND
                 cratvir.vlrdesir = 0   AND
                 cratvir.vlrdesdj = 0   AND
                 cratvir.vlrridac = 0   AND
                 cratvir.vlrriirp = 0   AND
                 cratvir.vlrdriap = 0   AND
                 cratvir.vlrrimog = 0   AND
                 cratvir.vlrrip65 = 0   THEN NEXT.

            FIND ttcabeca WHERE 
                 ttcabeca.nranocal = cratdrf.nranocal   AND
                 ttcabeca.cdretenc = cratdrf.cdretenc   AND
                 ttcabeca.nrcpfbnf = cratdrf.nrcpfbnf   AND 
                 ttcabeca.nrseqdig = aux_nrseqdig       NO-ERROR.
            IF   NOT AVAIL ttcabeca   THEN
                 DO:
                     CREATE ttcabeca.
                     ASSIGN ttcabeca.nranocal = cratdrf.nranocal
                            ttcabeca.cdretenc = cratdrf.cdretenc
                            ttcabeca.nrcpfbnf = cratdrf.nrcpfbnf
                            ttcabeca.nrseqdig = aux_nrseqdig.
    
                     FIND gnrdirf WHERE 
                          gnrdirf.cdretenc = cratdrf.cdretenc 
                          NO-LOCK NO-ERROR.
                     IF   AVAIL gnrdirf   THEN
                          ASSIGN ttcabeca.dsretenc = gnrdirf.dsretenc
                                 ttcabeca.dsretenc = 
                                   REPLACE(ttcabeca.dsretenc,CHR(10)," ")
                                 ttcabeca.dsretenc = 
                                   REPLACE(ttcabeca.dsretenc,CHR(13)," ").
    
                     FIND crapdrf WHERE
                          crapdrf.cdcooper = glb_cdcooper       AND
                          crapdrf.nrseqdig = cratdrf.nrseqdig   AND
                          crapdrf.cdretenc = cratdrf.cdretenc   AND
                          crapdrf.nranocal = cratdrf.nranocal   AND
                          crapdrf.nrcpfbnf = cratdrf.nrcpfbnf
                          NO-LOCK NO-ERROR.
                     
                     IF   AVAIL crapdrf   THEN
                          DO:
                              ASSIGN ttcabeca.nmbenefi = crapdrf.nmbenefi.
                              /* Tratamento de CPF/CGC */
                              IF   cratdrf.nrcpfbnf > 0   THEN
                                   DO:
                                      IF crapdrf.inpessoa = 1   THEN
                                         ASSIGN ttcabeca.dscpfbnf = 
                                            STRING(ttcabeca.nrcpfbnf,
                                                   "99999999999")
                                                ttcabeca.dscpfbnf = 
                                            STRING(ttcabeca.dscpfbnf,
                                               "    xxx.xxx.xxx-xx").
                                      ELSE
                                         ASSIGN ttcabeca.dscpfbnf = 
                                             STRING(ttcabeca.nrcpfbnf,
                                                    "99999999999999")
                                                ttcabeca.dscpfbnf =
                                            STRING(ttcabeca.dscpfbnf,
                                               "xx.xxx.xxx/xxxx-xx").
                                   END.
                              ELSE
                                   ASSIGN ttcabeca.dscpfbnf = "".
                          END.
                     ELSE
                          ASSIGN ttcabeca.nmbenefi = ""
                                 ttcabeca.dscpfbnf = 
                                   STRING(ttcabeca.nrcpfbnf,
                                          "99999999999")
                                 ttcabeca.dscpfbnf = 
                                   STRING(ttcabeca.dscpfbnf,
                                          "    xxx.xxx.xxx-xx").

                 END. /* IF   NOT AVAIL ttcabeca */

            FIND ttdetalh WHERE
                 ttdetalh.nranocal = ttcabeca.nranocal   AND
                 ttdetalh.cdretenc = ttcabeca.cdretenc   AND 
                 ttdetalh.nrcpfbnf = ttcabeca.nrcpfbnf   AND 
                 ttdetalh.nrseqdig = ttcabeca.nrseqdig   AND 
                 ttdetalh.nrmesref = cratvir.nrmesref    NO-ERROR.
            IF   NOT AVAIL ttdetalh  THEN
                 DO:
                     CREATE ttdetalh.
                     ASSIGN ttdetalh.nranocal = ttcabeca.nranocal
                            ttdetalh.cdretenc = ttcabeca.cdretenc 
                            ttdetalh.nrcpfbnf = ttcabeca.nrcpfbnf 
                            ttdetalh.nrseqdig = ttcabeca.nrseqdig 
                            ttdetalh.nrmesref = cratvir.nrmesref.
    
                     CASE cratvir.nrmesref:
                         WHEN  1 THEN ASSIGN ttdetalh.nmextmes = "JANEIRO".
                         WHEN  2 THEN ASSIGN ttdetalh.nmextmes = "FEVEREIRO".
                         WHEN  3 THEN ASSIGN ttdetalh.nmextmes = "MARCO".
                         WHEN  4 THEN ASSIGN ttdetalh.nmextmes = "ABRIL".
                         WHEN  5 THEN ASSIGN ttdetalh.nmextmes = "MAIO".
                         WHEN  6 THEN ASSIGN ttdetalh.nmextmes = "JUNHO".
                         WHEN  7 THEN ASSIGN ttdetalh.nmextmes = "JULHO".
                         WHEN  8 THEN ASSIGN ttdetalh.nmextmes = "AGOSTO".
                         WHEN  9 THEN ASSIGN ttdetalh.nmextmes = "SETEMBRO".
                         WHEN 10 THEN ASSIGN ttdetalh.nmextmes = "OUTUBRO".
                         WHEN 11 THEN ASSIGN ttdetalh.nmextmes = "NOVEMBRO".
                         WHEN 12 THEN ASSIGN ttdetalh.nmextmes = "DEZEMBRO".
                         WHEN 13 THEN ASSIGN ttdetalh.nmextmes = "13o.SALARIO".
                     END CASE.
                 END.

            ASSIGN 
                ttdetalh.vlrdrtrt = ttdetalh.vlrdrtrt + cratvir.vlrdrtrt / 100
                ttdetalh.vlrdrtpo = ttdetalh.vlrdrtpo + cratvir.vlrdrtpo / 100
                ttdetalh.vlrdrtpp = ttdetalh.vlrdrtpp + cratvir.vlrdrtpp / 100
                ttdetalh.vlrdrtdp = ttdetalh.vlrdrtdp + cratvir.vlrdrtdp / 100
                ttdetalh.vlrdrtpa = ttdetalh.vlrdrtpa + cratvir.vlrdrtpa / 100
                ttdetalh.vlrrtirf = ttdetalh.vlrrtirf + cratvir.vlrrtirf / 100
                ttdetalh.vlrdcjaa = ttdetalh.vlrdcjaa + cratvir.vlrdcjaa / 100
                ttdetalh.vlrdcjac = ttdetalh.vlrdcjac + cratvir.vlrdcjac / 100
                ttdetalh.vlrdesrt = ttdetalh.vlrdesrt + cratvir.vlrdesrt / 100
                ttdetalh.vlrdespo = ttdetalh.vlrdespo + cratvir.vlrdespo / 100
                ttdetalh.vlrdespp = ttdetalh.vlrdespp + cratvir.vlrdespp / 100
                ttdetalh.vlrdesdp = ttdetalh.vlrdesdp + cratvir.vlrdesdp / 100
                ttdetalh.vlrdespa = ttdetalh.vlrdespa + cratvir.vlrdespa / 100
                ttdetalh.vlrdesir = ttdetalh.vlrdesir + cratvir.vlrdesir / 100
                ttdetalh.vlrdesdj = ttdetalh.vlrdesdj + cratvir.vlrdesdj / 100
                ttdetalh.vlrridac = ttdetalh.vlrridac + cratvir.vlrridac / 100
                ttdetalh.vlrriirp = ttdetalh.vlrriirp + cratvir.vlrriirp / 100
                ttdetalh.vlrdriap = ttdetalh.vlrdriap + cratvir.vlrdriap / 100
                ttdetalh.vlrrimog = ttdetalh.vlrrimog + cratvir.vlrrimog / 100
                ttdetalh.vlrrip65 = ttdetalh.vlrrip65 + cratvir.vlrrip65 / 100
                ttdetalh.vlrtotrt = ttdetalh.vlrtotrt + cratvir.vlrdrtrt / 100 
                                                      + cratvir.vlrdrtpo / 100 
                                                      + cratvir.vlrdrtpp / 100 
                                                      + cratvir.vlrdrtdp / 100 
                                                      + cratvir.vlrdrtpa / 100 
                                                      + cratvir.vlrrtirf / 100
                ttdetalh.vlrtotcj = ttdetalh.vlrtotcj + cratvir.vlrdcjaa / 100
                                                      + cratvir.vlrdcjac / 100
                ttdetalh.vlrtotes = ttdetalh.vlrtotes + cratvir.vlrdesrt / 100
                                                      + cratvir.vlrdespo / 100
                                                      + cratvir.vlrdespp / 100
                                                      + cratvir.vlrdesdp / 100
                                                      + cratvir.vlrdespa / 100
                                                      + cratvir.vlrdesir / 100
                                                      + cratvir.vlrdesdj / 100
                ttdetalh.vlrtotri = ttdetalh.vlrtotri + cratvir.vlrridac / 100 
                                                      + cratvir.vlrriirp / 100
                                                      + cratvir.vlrdriap / 100 
                                                      + cratvir.vlrrimog / 100
                                                      + cratvir.vlrrip65 / 100.

        END. /* FOR EACH cratvir */

    END. /* FOR EACH cratdrf */
    
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.     
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter. 

    UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
    ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

    /* junta as opcoes de filtro usadas para a listagem */
    rel_dsopcoes = "(FILTRO USADO: " + TRIM(tel_tpdbusca) + "/" +
                   TRIM(tel_tpdinfor).

    IF   tel_nranocal > 0   THEN
         rel_dsopcoes = rel_dsopcoes + "/" + STRING(tel_nranocal,"9999") + ")".
    ELSE
         rel_dsopcoes = rel_dsopcoes + ")".
         
    rel_dsopcoes = rel_dsopcoes + " - REF. " + STRING(glb_dtmvtolt,"99/99/9999")
                   + " EM " + STRING(TODAY,"99/99/9999").
    
    aux_regexist = FALSE.
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 74.
    
    VIEW STREAM str_1 FRAME f_cab.

    FOR EACH ttcabeca BY ttcabeca.nranocal
                         BY ttcabeca.cdretenc
                             BY ttcabeca.nrcpfbnf
                                BY ttcabeca.nrseqdig:

        IF   aux_regexist = TRUE   THEN
             PUT STREAM str_1 SKIP(2).

        ASSIGN aux_regexist = YES.

        DISP STREAM str_1
             ttcabeca.nranocal
             ttcabeca.cdretenc
             ttcabeca.dsretenc
             WITH FRAME f_rel.
        
        IF   ttcabeca.nrcpfbnf <> 0   THEN
             PUT STREAM str_1 
                 "CPF/CNPJ: "       AT  3
                 ttcabeca.dscpfbnf
                 "NOME: "           AT 43
                 ttcabeca.nmbenefi
                 SKIP(1).
        ELSE 
            PUT STREAM str_1 
                SKIP(1).

        /* Valores de rendimentos tributaveis */
        IF   CAN-FIND(FIRST ttdetalh WHERE
                      ttdetalh.nranocal = ttcabeca.nranocal   AND
                      ttdetalh.cdretenc = ttcabeca.cdretenc   AND 
                      ttdetalh.nrcpfbnf = ttcabeca.nrcpfbnf   AND 
                      ttdetalh.nrseqdig = ttcabeca.nrseqdig   AND
                      ttdetalh.vlrtotrt  > 0 )                THEN
             DO:
                 DISP STREAM str_1
                      WITH FRAME f_cab_rendtrib.
                 DOWN STREAM str_1 WITH FRAME f_cab_rendtrib.
                 
                 FOR EACH ttdetalh WHERE
                          ttdetalh.nranocal = ttcabeca.nranocal   AND
                          ttdetalh.cdretenc = ttcabeca.cdretenc   AND 
                          ttdetalh.nrcpfbnf = ttcabeca.nrcpfbnf   AND 
                          ttdetalh.nrseqdig = ttcabeca.nrseqdig   
                          BY ttdetalh.nrmesref:

                     DISP STREAM str_1
                          ttdetalh.nmextmes
                          ttdetalh.vlrdrtrt
                          ttdetalh.vlrdrtpo
                          ttdetalh.vlrdrtpp
                          ttdetalh.vlrdrtdp
                          ttdetalh.vlrdrtpa
                          ttdetalh.vlrrtirf
                          WITH FRAME f_det_rendtrib.
                     DOWN STREAM str_1 WITH FRAME f_det_rendtrib.

                     ACCUM ttdetalh.vlrdrtrt (TOTAL).
                     ACCUM ttdetalh.vlrdrtpo (TOTAL).
                     ACCUM ttdetalh.vlrdrtpp (TOTAL).
                     ACCUM ttdetalh.vlrdrtdp (TOTAL).
                     ACCUM ttdetalh.vlrdrtpa (TOTAL).
                     ACCUM ttdetalh.vlrrtirf (TOTAL).
                 END.

                 DISP STREAM str_1
                      "TOTAL"                       @ ttdetalh.nmextmes
                      ACCUM TOTAL ttdetalh.vlrdrtrt @ ttdetalh.vlrdrtrt
                      ACCUM TOTAL ttdetalh.vlrdrtpo @ ttdetalh.vlrdrtpo
                      ACCUM TOTAL ttdetalh.vlrdrtpp @ ttdetalh.vlrdrtpp
                      ACCUM TOTAL ttdetalh.vlrdrtdp @ ttdetalh.vlrdrtdp
                      ACCUM TOTAL ttdetalh.vlrdrtpa @ ttdetalh.vlrdrtpa
                      ACCUM TOTAL ttdetalh.vlrrtirf @ ttdetalh.vlrrtirf
                      WITH FRAME f_det_rendtrib.
                 DOWN STREAM str_1 WITH FRAME f_det_rendtrib.

             END. /* Fim Valores de rendimentos tributaveis */

        /* Valores de compensacao juridica */
        IF   CAN-FIND(FIRST ttdetalh WHERE
                      ttdetalh.nranocal = ttcabeca.nranocal   AND
                      ttdetalh.cdretenc = ttcabeca.cdretenc   AND 
                      ttdetalh.nrcpfbnf = ttcabeca.nrcpfbnf   AND 
                      ttdetalh.nrseqdig = ttcabeca.nrseqdig   AND
                      ttdetalh.vlrtotcj  > 0)                 THEN
             DO:
                 DISP STREAM str_1
                      WITH FRAME f_cab_compimpo.
                 DOWN STREAM str_1 WITH FRAME f_cab_compimpo.
                 
                 FOR EACH ttdetalh WHERE
                          ttdetalh.nranocal = ttcabeca.nranocal   AND
                          ttdetalh.cdretenc = ttcabeca.cdretenc   AND 
                          ttdetalh.nrcpfbnf = ttcabeca.nrcpfbnf   AND 
                          ttdetalh.nrseqdig = ttcabeca.nrseqdig   
                          BY ttdetalh.nrmesref:

                     DISP STREAM str_1
                          ttdetalh.nmextmes
                          ttdetalh.vlrdcjac
                          ttdetalh.vlrdcjaa
                          WITH FRAME f_det_compimpo.
                     DOWN STREAM str_1 WITH FRAME f_det_compimpo.

                     ACCUM ttdetalh.vlrdcjac (TOTAL).
                     ACCUM ttdetalh.vlrdcjaa (TOTAL).
                 END.

                 DISP STREAM str_1
                      "TOTAL"                       @ ttdetalh.nmextmes
                      ACCUM TOTAL ttdetalh.vlrdcjac @ ttdetalh.vlrdcjac
                      ACCUM TOTAL ttdetalh.vlrdcjaa @ ttdetalh.vlrdcjaa
                      WITH FRAME f_det_compimpo.
                 DOWN STREAM str_1 WITH FRAME f_det_compimpo.

             END. /* Fim Valores de rendimentos tributaveis */

        /* Valores DE EXIGIBILIDADE SUSPENSA Daniel*/
        IF   CAN-FIND(FIRST ttdetalh WHERE
                      ttdetalh.nranocal = ttcabeca.nranocal   AND
                      ttdetalh.cdretenc = ttcabeca.cdretenc   AND 
                      ttdetalh.nrcpfbnf = ttcabeca.nrcpfbnf   AND 
                      ttdetalh.nrseqdig = ttcabeca.nrseqdig   AND
                      ttdetalh.vlrtotes  > 0)                 THEN
             DO:
                 DISP STREAM str_1
                      WITH FRAME f_cab_tribexib.
                 DOWN STREAM str_1 WITH FRAME f_cab_tribexib.

                 FOR EACH ttdetalh WHERE
                              ttdetalh.nranocal = ttcabeca.nranocal   AND
                              ttdetalh.cdretenc = ttcabeca.cdretenc   AND 
                              ttdetalh.nrcpfbnf = ttcabeca.nrcpfbnf   AND 
                              ttdetalh.nrseqdig = ttcabeca.nrseqdig   
                              BY ttdetalh.nrmesref:

                     DISP STREAM str_1
                              ttdetalh.nmextmes
                              ttdetalh.vlrdesrt
                              ttdetalh.vlrdespo
                              ttdetalh.vlrdespp
                              ttdetalh.vlrdesdp
                              ttdetalh.vlrdespa
                              ttdetalh.vlrdesir
                              ttdetalh.vlrdesdj
                              WITH FRAME f_det_tribexib.
                         DOWN STREAM str_1 WITH FRAME f_det_tribexib.

                     ACCUM ttdetalh.vlrdesrt (TOTAL).
                     ACCUM ttdetalh.vlrdespo (TOTAL).
                     ACCUM ttdetalh.vlrdespp (TOTAL).
                     ACCUM ttdetalh.vlrdesdp (TOTAL).
                     ACCUM ttdetalh.vlrdespa (TOTAL).
                     ACCUM ttdetalh.vlrdesir (TOTAL).
                     ACCUM ttdetalh.vlrdesdj (TOTAL).
                 END.

                 DISP STREAM str_1
                      "TOTAL"                       @ ttdetalh.nmextmes
                      ACCUM TOTAL ttdetalh.vlrdesrt @ ttdetalh.vlrdesrt
                      ACCUM TOTAL ttdetalh.vlrdespo @ ttdetalh.vlrdespo
                      ACCUM TOTAL ttdetalh.vlrdespp @ ttdetalh.vlrdespp
                      ACCUM TOTAL ttdetalh.vlrdesdp @ ttdetalh.vlrdesdp
                      ACCUM TOTAL ttdetalh.vlrdespa @ ttdetalh.vlrdespa
                      ACCUM TOTAL ttdetalh.vlrdesir @ ttdetalh.vlrdesir
                      ACCUM TOTAL ttdetalh.vlrdesdj @ ttdetalh.vlrdesdj
                      WITH FRAME f_det_tribexib.
                 DOWN STREAM str_1 WITH FRAME f_det_tribexib.
             END.

        /* Valores DE RENDIMENTOS ISENTOS Daniel*/
        IF   CAN-FIND(FIRST ttdetalh WHERE
                      ttdetalh.nranocal = ttcabeca.nranocal   AND
                      ttdetalh.cdretenc = ttcabeca.cdretenc   AND 
                      ttdetalh.nrcpfbnf = ttcabeca.nrcpfbnf   AND 
                      ttdetalh.nrseqdig = ttcabeca.nrseqdig   AND
                      ttdetalh.vlrtotri  > 0)                 THEN
             DO:
                 DISP STREAM str_1
                      WITH FRAME f_cab_rendisen.
                 DOWN STREAM str_1 WITH FRAME f_cab_rendisen.
                
                 FOR EACH ttdetalh WHERE
                              ttdetalh.nranocal = ttcabeca.nranocal   AND
                              ttdetalh.cdretenc = ttcabeca.cdretenc   AND 
                              ttdetalh.nrcpfbnf = ttcabeca.nrcpfbnf   AND 
                              ttdetalh.nrseqdig = ttcabeca.nrseqdig   
                              BY ttdetalh.nrmesref:


                      DISP STREAM str_1
                              ttdetalh.nmextmes
                              ttdetalh.vlrridac
                              ttdetalh.vlrriirp
                              ttdetalh.vlrdriap
                              ttdetalh.vlrrimog
                              ttdetalh.vlrrip65
                              WITH FRAME f_det_rendisen.
                         DOWN STREAM str_1 WITH FRAME f_det_rendisen.
                       
                         
                      ACCUM ttdetalh.vlrridac (TOTAL).
                      ACCUM ttdetalh.vlrriirp (TOTAL).
                      ACCUM ttdetalh.vlrdriap (TOTAL).
                      ACCUM ttdetalh.vlrrimog (TOTAL).
                      ACCUM ttdetalh.vlrrip65 (TOTAL).
                 END.

                 DISP STREAM str_1
                      "TOTAL"                       @ ttdetalh.nmextmes
                      ACCUM TOTAL ttdetalh.vlrridac @ ttdetalh.vlrridac
                      ACCUM TOTAL ttdetalh.vlrriirp @ ttdetalh.vlrriirp
                      ACCUM TOTAL ttdetalh.vlrdriap @ ttdetalh.vlrdriap
                      ACCUM TOTAL ttdetalh.vlrrimog @ ttdetalh.vlrrimog
                      ACCUM TOTAL ttdetalh.vlrrip65 @ ttdetalh.vlrrip65
                      WITH FRAME  f_det_rendisen.
                 DOWN STREAM str_1 WITH FRAME  f_det_rendisen.

             END.
    END. /* FOR EACH ttcabeca */

    aux_totpagin = PAGE-NUMBER(str_1).
    
    OUTPUT STREAM str_1 CLOSE.

    HIDE MESSAGE NO-PAUSE.

    IF   aux_regexist = FALSE   THEN
         DO:
            MESSAGE "Nao ha registros a serem listados!".
            NEXT.
         END.

    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       aux_confirma = "N".
       MESSAGE "O Arquivo gerado possui" aux_totpagin "pagina(s)!"
               "Deseja imprimi-lo?" UPDATE aux_confirma.
       LEAVE.
    END.

    IF   aux_confirma <> "S"   THEN
         NEXT.

    /* somente para includes/impressao.i */
    FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
    ASSIGN glb_nmformul = "132col"
           glb_nrcopias = 1.
    
    { includes/impressao.i }

END PROCEDURE. /* PROCEDURE gera_rel: */


/* ......................................................................... */
