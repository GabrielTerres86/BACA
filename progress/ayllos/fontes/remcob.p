/*............................................................................

  Programa: Fontes/remcob.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Fabricio
  Data    : Abril/2011                       Ultima Atualizacao: 15/09/2017

  Dados referentes ao programa:

  Frequencia: Diario (on-line).
  Objetivo  : Mostrar a tela REMCOB, Geracao de Remessa Bancaria.
  
  *****************************************************************************
  * Observacao: Comentar script ArquivosBB.envia.pl antes de realizar testes. *
  *****************************************************************************
  
  Alteracoes:   26/04/2011 - Geracao de relatorio(sintetico) de acompanhamento, 
                             baseado na tela de resumo; por cooperativa. 
                             (Fabricio)
                             
                13/05/2011 - Geracao da segunda parte do relatorio(analitico);
                             por ocorrencia, ordenado por PAC. (Fabricio)
                             
                10/06/2011 - Ajustes na rotina de retorno ao cooperado
                             (Rafael)
                             
                20/07/2011 - Enviar arquivo apos geracao utilizando o script
                             /usr/local/cecred/bin/ArquivosBB.envia.pl
                           - Leituras do craprem estavam sem NO-LOCK e sem 
                             nome da tabela no BY
                           - Leitura crapass estava sem NO-LOCK
                           - Mesclado comandos ASSIGN (Guilherme).
                           
                25/07/2011 - Substituido os campos crapcob.nrinsava e 
                             crapcob.nmdavali, por, crapass.nrcpfcgc e 
                             crapass.nmprimtl, respectivamente; isto, no 
                             segmento "Q". (Fabricio)
                             
                02/08/2011 - Disponibilizado relatorio crrl596 na intranet
                             (Adriano).
                             
                15/08/2011 - Executar rotina verifica_sacado_dda antes de
                             gerar a remessa de tituos ao banco (Rafael).
                             
                23/08/2011 - Alterado retorna_apenas_dv. Trazer DV "X" 
                             quando for DV "zero" (Rafael).
                             
                01/09/2011 - Incluido data de descto. Estava fixo "0"
                             (Rafael).
                             
                28/09/2011 - Fixado aceite como "N". (Rafael).
                
                03/10/2011 - Incluido calculo DV Banco do Brasil (Rafael).
                
                21/10/2011 - Fixado agencia 34207 p/ todas as cooperativas
                             (Rafael).
                             
                09/11/2011 - Alterado aux_nmrescop p/ aux_dsdircop. Sistema
                             precisa utilizar dsdircop para gravar arquivo
                             de remessa. (Rafael).
                             
                12/12/2011 - Utilizar dtdocmto se vencto for menor que a 
                             data de emissao. (Rafael).
                             
                06/08/2013 - Adicionado formato de valor na string do valor de
                             desconto do titulo (Rafael).
                             
                05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (André Euzébio - Supero).
                             
                31/10/2013 - Executar script ArquivosBB.envia.pl somente
                             se o servidor for o "pkgprod" (Rafael).
                           - Adicionado parametro do numero do arquivo
                             remessa enviado pelo cooperado para os convenios
                             "IMPRESSO PELO SOFTWARE" - 085 (Rafael).
                
                22/11/2013 - Todos os boletos gerados pelo cooperado no 
                             modelo "Banco emite e expede", irao para o BB
                             sem a verificacao de sacado DDA. (Rafael)
                             
                17/12/2013 - Inclusao de VALIDATE crabcob (Carlos)
                
                
                07/01/2014 - Ajuste leituras tabela crapcob (Daniel).
                
                02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                             Cedente por Beneficiário e  Sacado por Pagador 
                             Chamado 229313 (Jean Reddiga - RKAM).    
                           
                31/07/2015 - Ajuste para retirar o caminho absoluto na chamada
                             de fontes
                             (Adriano - SD 314469).
                                                                           
                25/11/2015 - Incluido log na prcctl da REMCOB processada
                             manualmente (Tiago SD338533).

                15/09/2017 - Alteracao da Agencia do Banco do Brasil. (Jaison/Elton - M459)

..........................................................................*/
DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.
DEF STREAM str_4.
DEF STREAM str_log.

DEF VAR tel_nrdbanco AS INT FORMAT "zz9"         NO-UNDO.
DEF VAR tel_dtremess AS DATE FORMAT "99/99/9999" NO-UNDO.

/* Variaveis auxiliares */
DEF VAR aux_cddopcao AS CHAR                         NO-UNDO.
DEF VAR aux_qtdtitu  AS INT  FORMAT "zzz,zz9"        NO-UNDO.
DEF VAR aux_valtitu  AS DECI FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF VAR aux_qtdgeral AS INT  FORMAT "zzz,zz9"        NO-UNDO.
DEF VAR aux_valgeral AS DECI FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF VAR aux_gerareme AS CHAR FORMAT "!(1)"  INIT "N" NO-UNDO.

/* Relatorios */
DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                   NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5          NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                       NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                        INIT ["DEP. A VISTA   ","CAPITAL        ",
                              "EMPRESTIMOS    ","DIGITACAO      ",
                              "GENERICO       "]                 NO-UNDO.


{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0087tt.i }

FORM WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela
    FRAME f_moldura.

FORM glb_cddopcao LABEL "Opcao" AUTO-RETURN
    HELP "Informe a opcao desejada (I, C)."
    VALIDATE (CAN-DO("I,C", glb_cddopcao), "014 - Opcao errada.")
     tel_nrdbanco LABEL "Banco" AT 20
     tel_dtremess LABEL "Data"  AT 40
    WITH ROW 6 COLUMN 3 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.


DEF TEMP-TABLE tt-resumo NO-UNDO
    FIELD tt_codi   AS INT  FORMAT "zz9"
    FIELD tt_info   AS CHAR FORMAT "x(40)"
    FIELD tt_qtd    AS INT FORMAT "zzz,zz9"
    FIELD tt_val    AS DECI FORMAT "zzz,zzz,zz9.99".

DEF QUERY q-resumo FOR tt-resumo SCROLLING.

DEF BROWSE b-resumo QUERY q-resumo
    DISP tt-resumo.tt_codi COLUMN-LABEL "Cód."
         tt-resumo.tt_info COLUMN-LABEL "Descrição"
         tt-resumo.tt_qtd  COLUMN-LABEL "Qtd"
         tt-resumo.tt_val  COLUMN-LABEL "Valor"
    WITH 5 DOWN TITLE "Resumo" WIDTH 75.


FORM SKIP
     b-resumo HELP "Pressione <F1> para prosseguir ou <F4> para sair."
    SKIP(1)
     "Total"     AT 9
    aux_qtdgeral AT 50 NO-LABEL
    aux_valgeral AT 58 NO-LABEL
    WITH ROW 8 CENTERED NO-BOX OVERLAY WIDTH 75 FRAME f_resumo.

FORM 
    "Verificando Titulos DDA. Aguarde..."
    WITH ROW 12 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FUNCTION visualiza_resumo RETURNS LOGICAL(INPUT par_nrdbanco AS INT,
                                          INPUT par_dtremess AS DATE,
                                          INPUT par_cddopcao AS CHAR) FORWARD.



VIEW FRAME f_moldura.
PAUSE 0.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic =  0.

DO WHILE TRUE:
    ASSIGN glb_cdprogra = "REMCOB"
           glb_flgbatch = FALSE.

    RUN fontes/inicia.p.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE glb_cddopcao WITH FRAME f_opcao.
        LEAVE.
    END.

    IF KEYFUNCTION (LASTKEY) = "END-ERROR"   THEN      /* F4 ou Fim  */
    DO:
        RUN fontes/novatela.p.
     
        IF CAPS(glb_nmdatela) <> "REMCOB"   THEN
        DO:
            HIDE FRAME f_opcao.
            RETURN.
        END.

        NEXT.
    END.

    IF aux_cddopcao <> glb_cddopcao   THEN
    DO:
        { includes/acesso.i }
        aux_cddopcao = glb_cddopcao.
    END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        IF glb_cdcritic <> 0   THEN
        DO:
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.     
        END.

        /*UPDATE tel_nrdbanco WITH FRAME f_opcao.*/
        ASSIGN tel_nrdbanco = 001.           
        DISP tel_nrdbanco WITH FRAME f_opcao.

        IF CAN-DO ("C", glb_cddopcao) THEN
        DO:
            UPDATE tel_dtremess WITH FRAME f_opcao.

            IF visualiza_resumo(INPUT tel_nrdbanco,
                                INPUT tel_dtremess,
                                INPUT glb_cddopcao) THEN
                UPDATE b-resumo WITH FRAME f_resumo.
           

        END.
        ELSE
        IF CAN-DO ("I", glb_cddopcao) THEN
        DO:
            ASSIGN tel_dtremess = glb_dtmvtolt.
            DISP tel_dtremess WITH FRAME f_opcao.

            UPDATE tel_dtremess WITH FRAME f_opcao.

            VIEW FRAME f_aguarde.

            /* Nao havera mais tratamentos para boletos DDA */
            /* Todo os boletos gerados "Banco Emite e Expede"
               irao para o BB */
            /* RUN verifica_sacado_dda(INPUT tel_dtremess). */

            HIDE FRAME f_aguarde NO-PAUSE.

            IF visualiza_resumo(INPUT tel_nrdbanco,
                                INPUT tel_dtremess,
                                INPUT glb_cddopcao) THEN
            DO:
                UPDATE b-resumo WITH FRAME f_resumo.

                DO WHILE TRUE:
                    MESSAGE "Confirma geracao da Remessa?"
                    UPDATE aux_gerareme.
                
                    IF aux_gerareme = "S" OR aux_gerareme = "N" THEN
                        LEAVE.

                END.
                
                IF aux_gerareme = "S" THEN
                DO:
                    DO TRANSACTION ON ERROR UNDO, RETRY:                    

                        RUN gera_remessa(INPUT tel_nrdbanco,
                                         INPUT tel_dtremess).

                        ASSIGN glb_cdrelato = 596.

                        RUN gera_relatorio(INPUT tel_nrdbanco,
                                           INPUT tel_dtremess).
                                    
                        IF  OS-GETENV("PKGNAME") = "pkgprod" OR 
                            OS-GETENV("PKGNAME") = "PKGPROD" THEN
                            UNIX SILENT VALUE("/usr/local/cecred/" +
                                              "bin/ArquivosBB.envia.pl").
                          
                        RUN verifica_log.
                    END.
                END.
            END.
        END.

    END.


END.

/* --------------------------------------------------------------------------*/

FUNCTION visualiza_resumo RETURNS LOGICAL(INPUT par_nrdbanco AS INT,
                                          INPUT par_dtremess AS DATE,
                                          INPUT par_cddopcao AS CHAR):

    DEF VAR aux_contador AS INT NO-UNDO.

    ASSIGN aux_qtdgeral = 0
           aux_valgeral = 0
           aux_contador = 0.

    EMPTY TEMP-TABLE tt-resumo.

    CLEAR FRAME f_resumo ALL NO-PAUSE.
    HIDE FRAME f_resumo.
    HIDE BROWSE b-resumo.

    FOR EACH crapcre WHERE crapcre.dtmvtolt = par_dtremess
                       AND crapcre.intipmvt = 1 /* remessa */
                       AND crapcre.flgproce = (par_cddopcao = "C")
                       AND crapcre.cdcooper <> 3 NO-LOCK:

        FIND crapcco WHERE crapcco.cdcooper = crapcre.cdcooper
                       AND crapcco.nrconven = crapcre.nrcnvcob
                       AND crapcco.flgregis = TRUE
                       AND crapcco.dsorgarq = 'PROTESTO'
                       AND crapcco.cddbanco = par_nrdbanco NO-LOCK NO-ERROR.

        IF AVAIL crapcco THEN
            aux_contador = aux_contador + 1.
    END.
    
    IF aux_contador = 0 THEN
    DO:
        MESSAGE "Nao ha lancamentos para este banco/data!" VIEW-AS ALERT-BOX.
        RETURN NO.
    END.

    /* Lote de remessa – CRAPCRE */
    FOR EACH crapcre WHERE crapcre.dtmvtolt = tel_dtremess
                       AND crapcre.intipmvt =  1 /* remessa */
                       AND crapcre.cdcooper <> 3
                       AND crapcre.flgproce = (par_cddopcao = "C") NO-LOCK,

        EACH crapcco WHERE crapcco.cdcooper = crapcre.cdcooper
                       AND crapcco.nrconven = crapcre.nrcnvcob
                       AND crapcco.flgregis = TRUE
                       AND crapcco.dsorgarq = 'PROTESTO'
                       AND crapcco.cddbanco = par_nrdbanco NO-LOCK,

        /* DF titulos do lote de remessa – CRAPREM */
        EACH craprem WHERE craprem.cdcooper = crapcco.cdcooper
                       AND craprem.nrcnvcob = crapcco.nrconven
                       AND craprem.nrremret = crapcre.nrremret
                       AND craprem.nrdconta > 0
                       AND craprem.nrseqreg > 0 NO-LOCK
                           BREAK BY craprem.cdocorre:

            /* Busca o valor do titulo correspondente */
            FIND crapcob WHERE crapcob.cdcooper = craprem.cdcooper
                           AND crapcob.nrdconta = craprem.nrdconta
                           AND crapcob.cdbandoc = crapcco.cddbanco
                           AND crapcob.nrdctabb = crapcco.nrdctabb 
                           AND crapcob.nrcnvcob = craprem.nrcnvcob
                           AND crapcob.nrdocmto = craprem.nrdocmto
                           AND crapcob.flgregis = TRUE NO-LOCK NO-ERROR.

            IF AVAIL crapcob THEN
            DO:
                ASSIGN aux_qtdtitu = aux_qtdtitu + 1
                       aux_valtitu = aux_valtitu + crapcob.vltitu.

                IF LAST-OF(craprem.cdocorre) THEN
                DO:
                    /* Busca a descricao da ocorrencia */
                    FIND crapoco WHERE crapoco.cdcooper = craprem.cdcooper
                                   AND crapoco.cddbanco = crapcco.cddbanco
                                   AND crapoco.cdocorre = craprem.cdocorre
                                   AND crapoco.tpocorre = 1 /* remessa */
                                                            NO-LOCK NO-ERROR.

                    IF AVAIL crapoco THEN
                    DO:
                        CREATE tt-resumo.
                        ASSIGN tt-resumo.tt_codi = craprem.cdocorre
                               tt-resumo.tt_info = crapoco.dsocorre
                               tt-resumo.tt_qtd  = aux_qtdtitu
                               tt-resumo.tt_val  = aux_valtitu
                               aux_qtdgeral = aux_qtdgeral + aux_qtdtitu
                               aux_valgeral = aux_valgeral + aux_valtitu
                               aux_qtdtitu = 0
                               aux_valtitu = 0.
                    END.

                END.

            END.

    END.

    OPEN QUERY q-resumo FOR EACH tt-resumo.

    ENABLE b-resumo WITH FRAME f_resumo.

    DISP aux_qtdgeral
         aux_valgeral
        WITH FRAME f_resumo.

    RETURN YES.

END FUNCTION.

FUNCTION calcula_dv_bb RETURN CHAR (INPUT par_valor AS CHAR):
    DEF        VAR aux_digito   AS CHAR    INIT ""                   NO-UNDO.
    DEF        VAR aux_posicao  AS INT     INIT 0                    NO-UNDO.
    DEF        VAR aux_peso     AS INT     INIT 9                    NO-UNDO.
    DEF        VAR aux_calculo  AS INT     INIT 0                    NO-UNDO.
    DEF        VAR aux_resto    AS INT     INIT 0                    NO-UNDO.

    DO  aux_posicao = LENGTH(STRING(par_valor)) TO 1 BY -1:
    
        aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(par_valor),
                                                aux_posicao,1)) * aux_peso).
    
        aux_peso = aux_peso - 1.
    
        IF   aux_peso = 1   THEN
             aux_peso = 9.
    
    END.  /*  Fim do DO .. TO  */

    aux_resto = aux_calculo MODULO 11.

    IF aux_resto > 0 AND aux_resto < 10 THEN
       aux_digito = STRING(aux_resto,"9").
    ELSE IF aux_resto = 10 THEN 
       aux_digito = "X".
    ELSE IF aux_resto = 0 THEN 
       aux_digito = "0".

    RETURN aux_digito.

END FUNCTION.

FUNCTION retorna_apenas_dv RETURNS CHAR(INPUT par_valor AS CHAR):

    DEF VAR aux_valor2  AS CHAR NO-UNDO.

    ASSIGN aux_valor2 = SUBSTR(par_valor, 1, LENGTH(par_valor) - 1)
           /*aux_valor2 = REPLACE(aux_valor2, "0", "X").*/
           aux_valor2 = calcula_dv_bb(aux_valor2).

    RETURN aux_valor2.

END FUNCTION.

FUNCTION retorna_sem_dv RETURNS CHAR(INPUT par_valor AS CHAR):

    DEF VAR aux_valor2  AS CHAR NO-UNDO.

    ASSIGN aux_valor2 = SUBSTR(par_valor, 1, LENGTH(par_valor) - 1).

    RETURN aux_valor2.

END FUNCTION.

FUNCTION retorna_complemento RETURNS CHAR   (INPUT par_valor AS CHAR,
                                             INPUT par_zero  AS LOGICAL,
                                             INPUT par_size  AS INT):

    DEF VAR aux_count AS INT NO-UNDO.
    DEF VAR aux_count2 AS INT NO-UNDO.
    
    ASSIGN aux_count = par_size - LENGTH(par_valor)
           aux_count2 = 1.
    
    IF par_zero THEN
    DO:
        DO WHILE aux_count2 <= aux_count:
            ASSIGN par_valor = "0" + par_valor
                   aux_count2 = aux_count2 + 1.
        END.
    END.
    ELSE
    DO:
        DO WHILE aux_count2 <= aux_count:
            ASSIGN par_valor = par_valor + " "
                   aux_count2 = aux_count2 + 1.
        END.
    END.

    RETURN par_valor.

END FUNCTION.

/* 
    Verificar no arquivo de log se houve erro no envio 
    Caso sim, mostrar a mensagem na tela
*/
PROCEDURE verifica_log.

    DEFINE VARIABLE aux_nmarqlog AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_setlinha AS CHARACTER   NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + 
                          "/log/ArquivosBB.envia." + 
                          STRING(YEAR(tel_dtremess),"9999") +
                          STRING(MONTH(tel_dtremess),"99") +
                          STRING(DAY(tel_dtremess),"99") + ".log".
                   
    IF SEARCH(aux_nmarqlog) <>  ? THEN
       DO:                       
          INPUT STREAM str_log 
                THROUGH VALUE("ls " + aux_nmarqlog + " 2> /dev/null") NO-ECHO.

          SET STREAM str_log aux_nmarqlog FORMAT "x(60)".

          INPUT STREAM str_log FROM VALUE(aux_nmarqlog) NO-ECHO.   
            
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              IMPORT STREAM str_log UNFORMATTED aux_setlinha.          

              IF  SUBSTR(aux_setlinha,1,1) <> "["  THEN
                  LEAVE.
                   
              MESSAGE SUBSTR(aux_setlinha,38,LENGTH(aux_setlinha) - 38)
                  VIEW-AS ALERT-BOX.
          END.
                  
          INPUT STREAM str_log CLOSE.
       END.   
    
END PROCEDURE.

PROCEDURE gera_remessa.

    DEF INPUT PARAM par_nrdbanco AS INT  NO-UNDO.
    DEF INPUT PARAM par_dtremess AS DATE NO-UNDO.

    DEF VAR aux_dsdircop AS CHAR FORMAT "x(15)"  NO-UNDO.
    DEF VAR aux_linhaarq AS CHAR FORMAT "x(240)" NO-UNDO.
    DEF VAR aux_cddbanco AS CHAR FORMAT "x(3)"   NO-UNDO.
    DEF VAR aux_nrsequen AS INT                  NO-UNDO.
    DEF VAR aux_qtdlinha AS INT                  NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR FORMAT "x(40)"  NO-UNDO.

    /* variaveis teste CECRED */
    DEF VAR aux_nrdocnpj LIKE crapcop.nrdocnpj   NO-UNDO.
    DEF VAR aux_cdagedbb LIKE crapcop.cdagedbb   NO-UNDO.
    DEF VAR aux_nrctabbd LIKE crapcop.nrctabbd   NO-UNDO.
    DEF VAR aux_nmextcop AS CHAR                 NO-UNDO.
    DEF VAR aux_chave    AS CHAR                 NO-UNDO.

    DEF VAR h-b1wgen0088 AS HANDLE NO-UNDO.

    DO TRANSACTION:

        /* testes CECRED
        FIND FIRST crapcop NO-LOCK WHERE cdcooper = 3.
        
        ASSIGN aux_nrdocnpj = crapcop.nrdocnpj
               aux_nmrescop = LOWER(crapcop.nmrescop)
               aux_cdagedbb = crapcop.cdagedbb
               aux_nrctabbd = crapcop.nrctabbd
               aux_nmextcop = crapcop.nmextcop.
        */
        
        FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:

            RUN gera_log_execucao(INPUT 'REMCOB',
                                  INPUT "Inicio execucao",
                                  INPUT crapcop.cdcooper,
                                  INPUT "TODAS").

            ASSIGN aux_nrdocnpj = crapcop.nrdocnpj
                   aux_dsdircop = LOWER(crapcop.dsdircop)
                   aux_nrctabbd = crapcop.nrctabbd
                   aux_nmextcop = crapcop.nmextcop
                   aux_nrsequen = 1
                   aux_qtdlinha = 1.
        
            
            /* Lote de remessa – CRAPCRE */
            FOR EACH crapcre WHERE crapcre.cdcooper = crapcop.cdcooper
                               AND crapcre.dtmvtolt = par_dtremess
                               AND crapcre.intipmvt =  1 /* remessa */
                               AND crapcre.cdcooper <> 3
                               AND crapcre.flgproce = FALSE EXCLUSIVE-LOCK,
        
                /* Parametros da cobranca - busca o convenio */
                EACH crapcco WHERE crapcco.cdcooper = crapcre.cdcooper
                               AND crapcco.nrconven = crapcre.nrcnvcob
                               AND crapcco.flgregis = TRUE
                               AND crapcco.dsorgarq = 'PROTESTO'
                               AND crapcco.cddbanco = par_nrdbanco NO-LOCK:

                    ASSIGN aux_cdagedbb = crapcco.cdagedbb.

                    INPUT STREAM str_3 THROUGH VALUE( "grep " + aux_dsdircop + 
                            " /usr/local/cecred/etc/TabelaDeCooperativas " + 
                            "| cut -d: -f 10" + " 2> /dev/null") NO-ECHO.
    
                    SET STREAM str_3 aux_chave FORMAT "x(20)".
        
                    ASSIGN aux_nmarquiv = "ied240." + trim(aux_chave) + "." + 
                          string(day(TODAY), "99") +
                          string(month(TODAY),"99") +
                          substr(string(year(TODAY), "9999"),3,2) +
                          substr(string(time,"HH:MM:SS"),1,2) +
                          substr(string(time,"HH:MM:SS"),4,2) +
                          substr(string(time,"HH:MM:SS"),7,2) +
                          substr(string(now),21,03) + /* milesimos de segundo */
                          ".bco001." + 
                          "c" + string(aux_nrdocnpj,"99999999999999")
                           crapcre.nmarquiv = aux_nmarquiv.
            
                    OUTPUT STREAM str_2 TO VALUE 
                            ("/usr/coop/" + aux_dsdircop + "/arq/" + aux_nmarquiv).
        
                    /* Gravacao do header do arquivo - layout FEBRABAN pag. 17 */
                    ASSIGN aux_linhaarq = /* Codigo do banco */  
                                          "001"                       + 
                                          /* Lote de servico */
                                          "0000"                      + 
                                          /* Tipo de registro */
                                          "0"                         + 
                                          /* Uso exclusivo */
                                          retorna_complemento("", FALSE, 9) + 
                                          /* Tipo insc empresa (2 = CNPJ) */ 
                                          "2"                         + 
                                          /* Nro insc empresa */
        /*REPLACE(STRING(crapcop.nrdocnpj), ".", "")                    + */
                                          REPLACE(STRING(aux_nrdocnpj, 
                                                      "99999999999999"), ".", "") + 
                                          /* Cod. convenio banco */
                                          /* "001417019" = fixo exigido pelo banco */
        retorna_complemento(REPLACE(STRING(crapcco.nrconven, "999999999") +  
                                    "0014" + 
                                    STRING(crapcco.cdcartei, "99") + 
                                    STRING(crapcco.nrvarcar, "999"), ".", ""), FALSE, 20) + 
                                          /* Ag da conta */
        retorna_complemento
        /*(retorna_sem_dv(REPLACE(STRING(crapcop.cdagedbb), ".", "")), TRUE, 5)    + */
        (retorna_sem_dv(REPLACE(STRING(aux_cdagedbb), ".", "")), TRUE, 5)    + 
                                          /* DV da agencia */
        retorna_complemento
        /*(retorna_apenas_dv(REPLACE(STRING(crapcop.cdagedbb), ".", "")), FALSE, 1) + */
        (retorna_apenas_dv(REPLACE(STRING(aux_cdagedbb), ".", "")), FALSE, 1) + 
                                          /* Nro da C/C */
        retorna_complemento
        (retorna_sem_dv(REPLACE(STRING(crapcco.nrdctabb), ".", "")), TRUE, 12)    + 
                                          /* DV da C/C */
        retorna_complemento
        (retorna_apenas_dv(REPLACE(STRING(crapcco.nrdctabb), ".", "")), FALSE, 1) + 
                                          /* DV Ag/Conta */
                                          retorna_complemento("", FALSE, 1)       + 
                                          /* Nome da Empresa */
	    /*SUBSTR(crapcop.nmextcop, 1, 30)                               + */
        SUBSTR(aux_nmextcop, 1, 30)                               + 
                                          /* Nome do banco */
        retorna_complemento("BANCO DO BRASIL", FALSE, 30)             + 
                                          /* Uso Exclusivo */
        retorna_complemento("", FALSE, 10)                            + 
                                          /* Codigo Remessa (1 = remessa) */
                                          "1"                         + 
                                          /* Data Geração Arq */
        /*STRING(par_dtremess, "99999999")                              + */
        STRING(TODAY, "99999999")                              + 
                                          /* Hora da Geração Arq */
        REPLACE(STRING(TIME, "HH:MM:SS"), ":", "")                    + 
                                          /* Nro Remessa */
        STRING(crapcre.nrremret, "999999")                            +
                                          /* Layout do Arq */
	    	                              "084"                       + 
                                          /* Densidade Grav Arq */
	                                      "00000"                     + 
                                          /* Reservado Banco */
        retorna_complemento("", FALSE, 20)                            + 
                                          /* Reservado Empresa */
	    retorna_complemento("", FALSE, 20)                            + 
                                          /* Uso exclusivo */
        retorna_complemento("", FALSE, 29).

                                                  
                PUT STREAM str_2 aux_linhaarq SKIP.

                ASSIGN aux_linhaarq = ""
                       aux_qtdlinha = aux_qtdlinha + 1


                /* Gravacao do header do lote - layout FEBRABAN pag. 52 */

                       aux_linhaarq = /* Cód Banco Compe */
                                      "001"                                +
                                      /* Lote de Serviço */
                                      "0001"                               +
                                     /* Tipo de Registro */
                                      "1"                                  +
                                     /* Tipo de Operação */
                                      "R" /* remessa */                    +
                                     /* Tipo de Serviço */
                                      "01"                                 +
                                     /* Uso Exclusivo */
                                retorna_complemento("", FALSE, 2)          +
                                     /* Layout Lote */
                                      "043"                                +
                                     /* Uso Exclusivo */
                                retorna_complemento("", FALSE, 1)          +
                                     /* Tipo Insc. Empresa */
                                      "2" /* CNPJ */                       +
                                     /* Nro Insc Empresa */
/*retorna_complemento(REPLACE(STRING(crapcop.nrdocnpj), ".", ""), TRUE, 15)  +*/
retorna_complemento(REPLACE(STRING(aux_nrdocnpj), ".", ""), TRUE, 15)  +
                                     /* Cód. Convenio Bco */
         retorna_complemento(REPLACE(STRING(crapcco.nrconven, "999999999") + 
                     "0014" + 
                     STRING(crapcco.cdcartei, "99") + 
                     STRING(crapcco.nrvarcar, "999") + 
                     "  ", ".", ""), FALSE, 20)
                     /*"TS", ".", ""), FALSE, 20)*/ + /* TS para testes */
                                     /* Ag da conta */
retorna_complemento
     /*(retorna_sem_dv(REPLACE(STRING(crapcop.cdagedbb), ".", "")), TRUE, 5) +*/
    (retorna_sem_dv(REPLACE(STRING(aux_cdagedbb), ".", "")), TRUE, 5) +
                                     /* DV da agencia */
retorna_complemento
 /*(retorna_apenas_dv(REPLACE(STRING(crapcop.cdagedbb), ".", "")), FALSE, 1) +*/
(retorna_apenas_dv(REPLACE(STRING(aux_cdagedbb), ".", "")), FALSE, 1) +
                                     /* Nro da C/C */
retorna_complemento
    (retorna_sem_dv(REPLACE(STRING(crapcco.nrdctabb), ".", "")), TRUE, 12) + 
                                     /* DV da C/C */
retorna_complemento
 (retorna_apenas_dv(REPLACE(STRING(crapcco.nrdctabb), ".", "")), FALSE, 1) + 
                                     /* DV Ag/Conta */
                                      retorna_complemento("", FALSE, 1)    + 
                                     /* Nome da Empresa */
	                            /*SUBSTR(crapcop.nmextcop, 1, 30)            +*/
                                SUBSTR(aux_nmextcop, 1, 30)            +
                                     /* Mensagem 1 */
                                retorna_complemento("", FALSE, 40)         +
                                     /*  Mensagem 2 */
                                retorna_complemento("", FALSE, 40)         +
                                     /* Nro Remessa */
                                STRING(crapcre.nrremret, "99999999")       +
                                     /* Data gravacao */
                                /*STRING(par_dtremess, "99999999")           +*/
                                STRING(TODAY, "99999999")           +    
                                    /* Dt do Crédito */
                                retorna_complemento("", TRUE, 8)           +
                                   /* Uso Exclusivo */
                                retorna_complemento("", FALSE, 33).


                PUT STREAM str_2 aux_linhaarq SKIP.

                ASSIGN aux_qtdlinha = aux_qtdlinha + 1.

                IF NOT VALID-HANDLE(h-b1wgen0088) THEN
                   RUN sistema/generico/procedures/b1wgen0088.p
                           PERSISTENT SET h-b1wgen0088.

                /* DF titulos do lote de remessa */
                FOR EACH craprem WHERE craprem.cdcooper = crapcco.cdcooper
                                   AND craprem.nrcnvcob = crapcco.nrconven
                                   AND craprem.nrremret = crapcre.nrremret
                                   AND craprem.nrdconta > 0
                                   AND craprem.nrseqreg > 0 NO-LOCK 
                                            BY craprem.cdocorre 
                                            BY craprem.nrseqreg:

                    FIND crapcob WHERE crapcob.cdcooper = craprem.cdcooper
                                   AND crapcob.nrdconta = craprem.nrdconta
                                   AND crapcob.cdbandoc = crapcco.cddbanco
                                   AND crapcob.nrdctabb = crapcco.nrdctabb
                                   AND crapcob.nrcnvcob = craprem.nrcnvcob
                                   AND crapcob.nrdocmto = craprem.nrdocmto
                                   AND crapcob.flgregis = TRUE 
                                                            NO-LOCK NO-ERROR.

                    IF AVAIL crapcob THEN
                    DO:

                        FIND crapass WHERE crapass.cdcooper = crapcob.cdcooper
                                       AND crapass.nrdconta = crapcob.nrdconta
                                       NO-LOCK NO-ERROR.

                        /* se titulo for pedido de remessa - logar */
                        IF craprem.cdocorre = 1 THEN
                        DO:
                            RUN cria-log-cobranca IN h-b1wgen0088
                                  (INPUT ROWID(crapcob),
                                   INPUT glb_cdoperad,
                                   INPUT par_dtremess,
                                   INPUT "Enviado ao BB - Remessa " + STRING(crapcre.nrremret)).
                        END.

                        ASSIGN aux_linhaarq = ""

                        /* Gravacao das informacoes do titulo - 
                                                       layout FEBRABAN p. 53 */
                        /* Segmento P */

                               aux_linhaarq = /* Banco */
                                             "001"                           +
                                              /* Lote de Serviço */
                                             "0001"                          +
                                              /* Tipo de Registro */
                                             "3"                             +
                                              /* Nro Seq Reg Lote */
                                             STRING(aux_nrsequen, "99999")   +
                                              /* Segmento */
                                             "P"                             +
                                              /* Uso Exclusivo */
                              retorna_complemento("", FALSE, 1)              +
                                              /* Cód Movimento Rem */
                                             STRING(craprem.cdocorre, "99")  +
                                              /* Ag da conta */
retorna_complemento
       /*(retorna_sem_dv(REPLACE(STRING(crapcop.cdagedbb), ".", "")), TRUE, 5) +*/
        (retorna_sem_dv(REPLACE(STRING(aux_cdagedbb), ".", "")), TRUE, 5) +
                                              /* DV da agencia */
retorna_complemento
   /*(retorna_apenas_dv(REPLACE(STRING(crapcop.cdagedbb), ".", "")), FALSE, 1) +*/
    (retorna_apenas_dv(REPLACE(STRING(aux_cdagedbb), ".", "")), FALSE, 1) +
                                              /* Nro da C/C */
retorna_complemento
 (retorna_sem_dv(REPLACE(STRING(crapcco.nrdctabb), ".", "")), TRUE, 12)      + 
                                              /* DV da C/C */
retorna_complemento
 (retorna_apenas_dv(REPLACE(STRING(crapcco.nrdctabb), ".", "")), FALSE, 1)   + 
                                              /* DV Ag/Conta */
                                           retorna_complemento("", FALSE, 1) +
                                              /* Nosso número */
                            retorna_complemento(crapcob.nrnosnum, FALSE, 20) +
                                              /* Cód. Carteira */
                                             /*STRING(crapcco.nrvarcar, "9")   +*/
                                             "7" + /* 7=Cob Simples - Cart 17 */
                                             /* Forma Cad Tit Banco */
                                             "1" /*com registro */           +
                                             /* Tipo de Documento */
                                             "2" /* escritural */            +
                                             /* Ident Emiss Bloqueto */                                      
                                             /*STRING(crapcob.inemiten, "9")   +*/
                                             "1" + /* banco emite e expede */
                                             /* Ident Distribuição */
                                             /*STRING(crapcob.inemiten, "9")   +*/
                                             "1" + /* banco distribui */
                                             /* Nro Documento */
                            retorna_complemento(crapcob.dsdoccop, FALSE, 15) +
                                             /* Vencimento */
                            STRING(crapcob.dtvencto, "99999999")             +
                                             /* Valor do Título */
retorna_complemento
    (REPLACE(REPLACE(STRING(crapcob.vltitulo,"999999999.99"), ".", ""), 
                                             ",", ""), TRUE, 15) +
                                             /* Ag. Cobradora */
                                             "00000"                         +
                                             /* DV Ag. Cobradora */
                                             "0".
                                             /* Especie Titulo */
                        IF crapcob.cddespec = 1 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "02".
                        ELSE
                        IF crapcob.cddespec = 2 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "04".
                        ELSE
                        IF crapcob.cddespec = 3 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "12".
                        ELSE
                        IF crapcob.cddespec = 4 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "21".
                        ELSE
                        IF crapcob.cddespec = 5 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "23".
                        ELSE
                        IF crapcob.cddespec = 6 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "17".
                        ELSE
                        IF crapcob.cddespec = 7 THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "99".

                        /* Ident Titulo Aceite */
                        /*IF crapcob.flgaceit = TRUE THEN
                            ASSIGN aux_linhaarq = aux_linhaarq + "A".
                        ELSE
                            ASSIGN aux_linhaarq = aux_linhaarq + "N".*/

                        /* Fixado Aceite como "N" */
                        ASSIGN aux_linhaarq = aux_linhaarq + "N".

                        ASSIGN aux_linhaarq = aux_linhaarq +
                                             /* Data Emissão Tit */
                            (IF  crapcob.dtmvtolt < crapcob.dtvencto THEN
                                STRING(crapcob.dtmvtolt, "99999999")
                            ELSE
                                STRING(crapcob.dtdocmto, "99999999"))      +
                                             /* Cód Juros Mora 
                             1 = Valor por dia, 2 = Valor mensal, 3 = Isento */
                            STRING(crapcob.tpjurmor, "9")                 +
                                             /* Data Juros Mora */
                            retorna_complemento("", TRUE, 8)              +
                                             /* Juros Mora */
retorna_complemento
    (REPLACE(REPLACE(STRING(crapcob.vljurdia, "999.99"), ".", ""), ",", ""), TRUE, 15) +
                                             /* Cód Desc. 1 */
                          (IF (crapcob.vldescto > 0) THEN  "1" ELSE "0")  +
                                             /* Data Desc. 1 */
      retorna_complemento((IF crapcob.vldescto > 0 THEN 
                              STRING(crapcob.dtvencto,"99999999") ELSE ""), TRUE, 8) +
                                             /* Desconto 1 */
retorna_complemento
    (REPLACE(REPLACE(STRING(crapcob.vldescto,"9999999999999.99"), 
                     ".", ""), ",", ""), TRUE, 15) +
                                             /* Vlr IOF */
                            retorna_complemento("", TRUE, 15).

                                             /* Vlr Abatimento */
                        IF craprem.cdocorre = 4 THEN /* concessao abatimento */
                            ASSIGN aux_linhaarq = aux_linhaarq +
retorna_complemento
    (REPLACE(REPLACE(STRING(crapcob.vlabatim,"9999999999999.99"), 
                        ".", ""), ",", ""), TRUE, 15).
                        ELSE
                            ASSIGN aux_linhaarq = aux_linhaarq +
                                          retorna_complemento("0", TRUE, 15).

                                             /* Uso Empresa Ced */
                        ASSIGN aux_linhaarq = aux_linhaarq +
                            /*retorna_complemento(crapcob.dsusoemp, FALSE, 25).*/
                            retorna_complemento(STRING(crapcob.nrcnvcob, "9999999") + 
                                                STRING(crapcob.nrdconta, "99999999") + 
                                                STRING(crapcob.nrdocmto, "999999999"),
                                                FALSE, 25).

                                             /* Código p/ Protesto */
                        IF crapcob.flgdprot = TRUE THEN
                           ASSIGN aux_linhaarq = aux_linhaarq + "1".
                        ELSE
                           ASSIGN aux_linhaarq = aux_linhaarq + "3".

                                             /* Nro Dias Protesto */
                        ASSIGN aux_linhaarq = aux_linhaarq +
                               (IF crapcob.qtdiaprt = 5 AND 
                                   crapcob.flgdprot THEN "06"
                                ELSE (IF crapcob.qtdiaprt >= 6 AND 
                                        crapcob.flgdprot THEN
                                        STRING(crapcob.qtdiaprt, "99")
                                      ELSE "00"))
                                             +
                                             /* Cód p/ baixa/devol */
                                             /* não baixar / não devolver */
                                             "2"                             +
                                             /* Prazo p/ baixa/devol */
                                             "000"                           +
                                             /* Código da Moeda */
                                             "09" /* Real */                 +
                                             /* Nro do Contrato */
                                        retorna_complemento("", TRUE, 10)    +
                                             /* Uso Exclusivo */
                                        retorna_complemento("", FALSE, 1).


                        PUT STREAM str_2 aux_linhaarq SKIP.

                        ASSIGN aux_linhaarq = ""
                               aux_qtdlinha = aux_qtdlinha + 1.

                        FIND crapsab WHERE crapsab.cdcooper = crapcob.cdcooper
                                       AND crapsab.nrdconta = crapcob.nrdconta
                                       AND crapsab.nrinssac = crapcob.nrinssac
                                                            NO-LOCK NO-ERROR.

                        IF AVAIL crapsab THEN
                        DO:
                            /* Gravacao das informacoes do titulo - 
                                                       layout FEBRABAN p. 54 */
                            /* Segmento Q */

                            ASSIGN aux_nrsequen = aux_nrsequen + 1

                                   aux_linhaarq = /* Banco na Compe */
                                                  "001"                      +
                                                  /* Lote de serviço */
                                                  "0001"                     +
                                                  /* Tipo de Registro */
                                                  "3"                        +
                                                  /* Nro Seq Reg Lote */
                                               STRING(aux_nrsequen, "99999") +
                                                  /* Segmento */
                                                  "Q"                        +
                                                  /* Uso exclusivo */
                                           retorna_complemento("", FALSE, 1) +
                                                  /* Cód Mov. Remessa */
                                              STRING(craprem.cdocorre, "99") +
                                                  /* Tipo Insc. */
                                              STRING(crapsab.cdtpinsc, "9")  +
                                                  /* Numero Insc. */
                    retorna_complemento(STRING(crapsab.nrinssac), TRUE, 15)  +
                                                  /* Nome Pagador */
            retorna_complemento(SUBSTR(crapsab.nmdsacad, 1, 40), FALSE, 40)  +
                                                  /* Endereço Pagador */
retorna_complemento(SUBSTR(crapsab.dsendsac + " " + 
                           STRING(crapsab.nrendsac) + "-" + 
                           crapsab.complend, 1, 40), FALSE, 40) +
                                                  /* Bairro do Pagador */
            retorna_complemento(SUBSTR(crapsab.nmbaisac, 1, 15), FALSE, 15)  +
                                                  /* CEP + Sufixo CEP */
                                        STRING(crapsab.nrcepsac, "99999999") +
                                                  /* Cidade */
            retorna_complemento(SUBSTR(crapsab.nmcidsac, 1, 15), FALSE, 15)  +
                                                  /* UF */
            retorna_complemento(SUBSTR(crapsab.cdufsaca, 1, 2), FALSE, 2)    +
                                                  /* Tipo Insc. Avalista */
                                              STRING(crapass.inpessoa, "9")  +
                                                  /* Nro Insc. Avalista */
                    retorna_complemento(STRING(crapass.nrcpfcgc), TRUE, 15)  +
                                                  /* Nome Sac/Avalista */
            retorna_complemento(SUBSTR(crapass.nmprimtl, 1, 40), FALSE, 40)  +
                                                  /* Banco Corresp */
                                                  "000"                      +
                                                  /* Nosso num. Corresp. */
                                          retorna_complemento("", FALSE, 20) +
                                                  /* Uso exclusivo */
                                          retorna_complemento("", FALSE, 8).


                            PUT STREAM str_2 aux_linhaarq SKIP.

                            ASSIGN aux_linhaarq = ""
                                   aux_qtdlinha = aux_qtdlinha + 1.

                        END.

                        /* Quando titulo tiver vlr multa > 0 e for remessa, 
                           entao gravar segmento "R" - Rafael Cechet 15/04/2011 */
                        IF crapcob.vlrmulta > 0 AND craprem.cdocorre = 1 THEN
                        DO:
                            /* Gravacao das informacoes do titulo - 
                                                       layout FEBRABAN p. 55 */
                            /* Segmento R */

                            ASSIGN aux_nrsequen = aux_nrsequen + 1 

                                   aux_linhaarq = /* Banco na Compe */
                                                  "001"                      +
                                                  /* Lote de serviço */
                                                  "0001"                     +
                                                  /* Tipo de Registro */
                                                  "3"                        +
                                                  /* Nro Seq Reg Lote */
                                               STRING(aux_nrsequen, "99999") +
                                                  /* Segmento */
                                                  "R"                        +
                                                  /* Uso exclusivo */
                                           retorna_complemento("", FALSE, 1) +
                                                  /* Cód Mov. Remessa */
                                           STRING(craprem.cdocorre, "99") +
                                                  /* Cód Desc. 2 */
                                           retorna_complemento("0", FALSE, 1) +
                                                  /* Data Desc 2. */
                                            retorna_complemento("", TRUE, 8) +
                                                  /* Vlr Desc 2. */
                                           retorna_complemento("", TRUE, 15) +
                                                  /* Cód Desc. 3 */
                                           retorna_complemento("0", FALSE, 1) +
                                                  /* Data Desc 3. */
                                            retorna_complemento("", TRUE, 8) +
                                                  /* Vlr Desc 3. */
                                           retorna_complemento("", TRUE, 15) +
                                                  /* Cód Multa */
                     retorna_complemento(string(crapcob.tpdmulta), FALSE, 1) +
                                                  /* Data Multa */
                                            retorna_complemento("", TRUE, 8) +
                                                  /* Vlr Multa */
                     retorna_complemento
                    (REPLACE(REPLACE(STRING(crapcob.vlrmulta,"999999999.99"), 
                        ".", ""), ",", ""), TRUE, 15) + 
                                                  /* Informacoes ao Pagador */
                                           retorna_complemento("", FALSE, 10) +
                                                  /* Informacoes 3 */
                                           retorna_complemento("", FALSE, 40) +
                                                  /* Informacoes 4 */
                                           retorna_complemento("", FALSE, 40) +
                                                  /* Uso Exclusivo CNAB */
                                           retorna_complemento("", FALSE, 20) +
                                                  /* Cod Ocorr Pagador */
                                           retorna_complemento("0", TRUE, 8) +
                                                  /* Cod Banco Cta Deb */
                                           retorna_complemento("0", TRUE, 3) +
                                                  /* Cod Agencia Cta Deb */
                                           retorna_complemento("0", TRUE, 5) +
                                                  /* DV Cta Deb */
                                           retorna_complemento("", FALSE, 1) +
                                                  /* Cta Corrente Deb */
                                          retorna_complemento("0", TRUE, 12) +
                                                  /* DV Cta Deb */
                                           retorna_complemento("", FALSE, 1) +
                                                  /* DV Ag/Cta Deb */
                                           retorna_complemento("", FALSE, 1) +
                                                  /* Ind aviso 2=nao emite */
                                          retorna_complemento("2", FALSE, 1) +
                                                  /* uso exclusivo CNAB */
                                           retorna_complemento("", FALSE, 9).

                            PUT STREAM str_2 aux_linhaarq SKIP.

                            ASSIGN aux_linhaarq = ""
                                   aux_qtdlinha = aux_qtdlinha + 1.

                        END.

                    END.

                    ASSIGN aux_nrsequen = aux_nrsequen + 1.

                END.
            
                /* Gravacao do Trailer de Lote – layout Febraban p. 64 */

                ASSIGN aux_nrsequen = aux_nrsequen + 1

                       aux_linhaarq = /* Cód Banco Compe */
                                      "001" +
                                      /* Lote de serviço */
                                      "0001" +
                                      /* Tipo de registro */
                                      "5"    +
                                      /* Uso exclusivo */
                                    retorna_complemento("", FALSE, 9) +
                                      /* Qtd de registros lote */
                                     STRING(aux_nrsequen, "999999")   +
                                      /* Qtd Tit em Cob Simp */
                                    retorna_complemento("", TRUE, 6)  +
                                      /* Vlr Tit em Cob Simp */
                                    retorna_complemento("", TRUE, 17) +
                                      /* Qtd Tit Cob Vinc. */
                                    retorna_complemento("", TRUE, 6)  +
                                      /* Vlr Tit Cob Vinc. */
                                    retorna_complemento("", TRUE, 17) +
                                      /* Qtd Tit Cob Cauc. */
                                    retorna_complemento("", TRUE, 6)  +
                                      /* Vlr Tit Cob Cauc. */
                                    retorna_complemento("", TRUE, 17) +
                                      /* Qtd Tit Cob Desc */
                                    retorna_complemento("", TRUE, 6)  +
                                      /* Vlr Tit Cob Desc. */
                                    retorna_complemento("", TRUE, 17) +
                                      /* Nro do aviso Lcto */
                                    retorna_complemento("", TRUE, 8)  +
                                      /* Uso exclusivo */
                                    retorna_complemento("", TRUE, 117).


                PUT STREAM str_2 aux_linhaarq SKIP.

                ASSIGN aux_linhaarq = ""
                       aux_qtdlinha = aux_qtdlinha + 1

                /* Gravacao do Trailer de Arquivo – layout Febraban p. 18 */

                       aux_linhaarq = /* Cód Banco Compe */
                                      "001" +
                                      /* Lote de serviço */
                                      "9999" +
                                      /* Tipo de registro */
                                      "9"    +
                                      /* Uso exclusivo */
                                      retorna_complemento("", FALSE, 9) +
                                      /* Qtd Lotes no arquivo */
                                      "000001"                          +
                                      /* Qtd registros */
                                      STRING(aux_qtdlinha, "999999")    +
                                      /* Qtd Contas p/ conc */
                                      STRING(0, "999999")               +
                                      /* Uso exclusivo */
                                      retorna_complemento("", FALSE, 205).


                PUT STREAM str_2 aux_linhaarq SKIP.

                ASSIGN crapcre.flgproce = TRUE.

                OUTPUT STREAM str_2 CLOSE.

                UNIX SILENT VALUE ("mv /usr/coop/" + aux_dsdircop + "/arq/" + 
                                   aux_nmarquiv + 
                          " /usr/coop/" + aux_dsdircop + "/compbb/remessa/" +
                          /*"ied240." + trim(aux_chave) + "." + 
                          string(day(TODAY), "99") +
                          string(month(TODAY),"99") +
                          substr(string(year(TODAY), "9999"),3,2) +
                          substr(string(time,"HH:MM:SS"),1,2) +
                          substr(string(time,"HH:MM:SS"),4,2) +
                          substr(string(time,"HH:MM:SS"),7,2) +
                          substr(string(now),21,03) + /* milesimos de segundo */
                          ".bco001." + 
                          "c" + string(aux_nrdocnpj,"99999999999999") +*/
                          aux_nmarquiv + 
                          " 2> /dev/null").

            END.

            RUN gera_log_execucao(INPUT 'REMCOB',
                                  INPUT "Fim execucao",
                                  INPUT crapcop.cdcooper,
                                  INPUT "TODAS").

        END.
    END. /* END DO TRANSACTION */

    IF VALID-HANDLE(h-b1wgen0088) THEN
    DO:
        DELETE PROCEDURE h-b1wgen0088.
    END.

    MESSAGE "Remessa(s) gerada(s) com sucesso!" VIEW-AS ALERT-BOX.

END PROCEDURE.

PROCEDURE gera_relatorio.

    DEF INPUT PARAM par_nrdbanco AS INT  NO-UNDO.
    DEF INPUT PARAM par_dtremess AS DATE NO-UNDO.

    DEF VAR aux_nmarquiv AS CHAR                         NO-UNDO.
    DEF VAR aux_vltitulo AS DECI FORMAT "zzz,zzz,zz9.99" NO-UNDO.
    DEF VAR aux_qtdtitul AS INT  FORMAT "zz9"            NO-UNDO.
    DEF VAR aux_vldescon AS DECI FORMAT "zzz,zz9.99"     NO-UNDO.
    DEF VAR aux_vlabatim AS DECI FORMAT "zzz,zz9.99"     NO-UNDO.
    DEF VAR aux_cdrelato AS CHAR                         NO-UNDO.
    DEF VAR aux_nmarqtmp AS CHAR                         NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                         NO-UNDO.
    DEF VAR aux_tprelato AS INT                          NO-UNDO.
    DEF VAR aux_nmrelato AS CHAR                         NO-UNDO.
            


    { includes/cabrel132_1.i }

    DO TRANSACTION:

        FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:

            /* Lote de remessa – CRAPCRE */
            FOR EACH crapcre WHERE crapcre.dtmvtolt = tel_dtremess
                               AND crapcre.intipmvt =  1 /* remessa */
                               AND crapcre.cdcooper = crapcop.cdcooper
                               AND crapcre.flgproce = TRUE /*faba*/ NO-LOCK,
        
                EACH crapcco WHERE crapcco.cdcooper = crapcre.cdcooper
                               AND crapcco.nrconven = crapcre.nrcnvcob
                               AND crapcco.flgregis = TRUE
                               AND crapcco.dsorgarq = 'PROTESTO'
                               AND crapcco.cddbanco = par_nrdbanco NO-LOCK:
                    
                    
                    ASSIGN aux_qtdgeral = 0
                           aux_valgeral = 0
                           glb_nmrescop = crapcop.nmrescop
                           aux_nmarquiv = "crrl596_" 
                                          + STRING(crapcco.nrconven)
                                          + "_"
                                          + STRING(crapcre.nrremret)
                                          + ".lst".
            
                    OUTPUT STREAM str_1 TO VALUE("/usr/coop/" + 
                                                  crapcop.dsdircop 
                                                  + "/rl/" + aux_nmarquiv) 
                                                            PAGED PAGE-SIZE 84.
                    
                    VIEW STREAM str_1 FRAME f_cabrel132_1.
                    
                    DISP STREAM str_1 "Destino: Cobranca" 
                                      SKIP(1)
                                      "Arquivo: compbb/remessa/" crapcre.nmarquiv 
                                      FORMAT "X(50)" AT 25 NO-LABEL
                                      SKIP(1)
                                      "Data:" tel_dtremess FORMAT "99/99/9999"
                                                                      NO-LABEL
                                      SPACE(5)
                                      "Banco: 001"
                                      SPACE(5)
                                      "Tipo: Remessa"
                                      SPACE(5)
                                      "Convenio:" 
                                      crapcco.nrconven AT 64 NO-LABEL
                                      SKIP(2).

                    DOWN STREAM str_1.

        
                    /* DF titulos do lote de remessa – CRAPREM */
                    FOR EACH craprem WHERE craprem.cdcooper = crapcco.cdcooper
                                       AND craprem.nrcnvcob = crapcco.nrconven
                                       AND craprem.nrremret = crapcre.nrremret
                                       AND craprem.nrdconta > 0
                                       AND craprem.nrseqreg > 0 NO-LOCK 
                                                                BREAK BY 
                                                              craprem.cdocorre:

                        /* Busca o valor do titulo correspondente */
                        FIND crapcob WHERE crapcob.cdcooper = craprem.cdcooper
                                       AND crapcob.nrdconta = craprem.nrdconta
                                       AND crapcob.cdbandoc = crapcco.cddbanco
                                       AND crapcob.nrdctabb = crapcco.nrdctabb 
                                       AND crapcob.nrcnvcob = craprem.nrcnvcob
                                       AND crapcob.nrdocmto = craprem.nrdocmto
                                       AND crapcob.flgregis = TRUE NO-LOCK 
                                                                   NO-ERROR.
        
                        IF AVAIL crapcob THEN
                        DO:
                            ASSIGN aux_qtdtitu = aux_qtdtitu + 1
                                   aux_valtitu = aux_valtitu + crapcob.vltitu.
        
                            IF LAST-OF(craprem.cdocorre) THEN
                            DO:
                                /* Busca a descricao da ocorrencia */
                                FIND crapoco WHERE crapoco.cdcooper = 
                                                                craprem.cdcooper
                                               AND crapoco.cddbanco = 
                                                                crapcco.cddbanco
                                               AND crapoco.cdocorre = 
                                                                craprem.cdocorre
                                               AND crapoco.tpocorre = 1 
                                                                /* remessa */
                                                               NO-LOCK NO-ERROR.
        
                                IF AVAIL crapoco THEN
                                DO:
                                    DISP STREAM str_1 craprem.cdocorre 
                                                      COLUMN-LABEL "Cod."
                                                      FORMAT "zz9"            
                                                      crapoco.dsocorre
                                                      COLUMN-LABEL "Descricao"
                                                      FORMAT "x(40)"
                                                      aux_qtdtitu
                                                      COLUMN-LABEL "Qtd"
                                                      FORMAT "zzz,zz9"
                                                      aux_valtitu
                                                      COLUMN-LABEL "Valor"
                                                      FORMAT "zzz,zzz,zz9.99".
        
                                    ASSIGN aux_qtdgeral = aux_qtdgeral + 
                                                          aux_qtdtitu 
                                           aux_valgeral = aux_valgeral + 
                                                          aux_valtitu 
        
                                           aux_qtdtitu = 0
                                           aux_valtitu = 0.
                                END.
        
                            END.
        
                        END.

                    END.

                    PUT STREAM str_1 SKIP(2)
                                     "Total"      AT 06
                                     aux_qtdgeral AT 47
                                     aux_valgeral AT 55
                                     SKIP(1).

                    /*----------- GERACAO DO ANALITICO ---------------------*/
                    
                    ASSIGN aux_qtdtitul = 0
                           aux_vltitulo = 0
                           aux_vldescon = 0
                           aux_vlabatim = 0.

                    FOR EACH craprem WHERE craprem.cdcooper = crapcco.cdcooper
                                       AND craprem.nrcnvcob = crapcco.nrconven
                                       AND craprem.nrremret = crapcre.nrremret
                                       AND craprem.nrdconta > 0
                                       AND craprem.nrseqreg > 0,

                        EACH crapass WHERE craprem.cdcooper = crapass.cdcooper
                                       AND craprem.nrdconta = crapass.nrdconta
                                           NO-LOCK  BREAK BY craprem.cdocorre 
                                                          BY crapass.cdagenci:
                        
                        FIND crapcob WHERE crapcob.cdcooper = craprem.cdcooper
                                       AND crapcob.nrdconta = craprem.nrdconta
                                       AND crapcob.cdbandoc = crapcco.cddbanco
                                       AND crapcob.nrdctabb = crapcco.nrdctabb
                                       AND crapcob.nrcnvcob = craprem.nrcnvcob
                                       AND crapcob.nrdocmto = craprem.nrdocmto
                                       AND crapcob.flgregis = TRUE NO-LOCK 
                                                                   NO-ERROR.
        
                        IF AVAIL crapcob THEN
                        DO:
                            IF FIRST-OF(craprem.cdocorre) THEN
                            DO:
                                /* Busca a descricao da ocorrencia */
                                FIND crapoco WHERE crapoco.cdcooper = 
                                                                craprem.cdcooper
                                               AND crapoco.cddbanco = 
                                                                crapcco.cddbanco
                                               AND crapoco.cdocorre = 
                                                                craprem.cdocorre
                                               AND crapoco.tpocorre = 1 
                                                                /* remessa */
                                                               NO-LOCK NO-ERROR.

                                IF AVAIL crapoco THEN
                                DO:
                                    DISP STREAM str_1 SKIP(2)
                                                      "Ocorrencia:"
                                                      craprem.cdocorre 
                                                        NO-LABEL FORMAT "zz9"
                                                      "-"
                                                      crapoco.dsocorre NO-LABEL
                                                      SKIP(2).

                                    PUT STREAM str_1 "PA"          AT 04
                                                      "Nr. Conta"  AT 08
                                                      "CPF/CNPJ"   AT 24
                                                      "Boleto"     AT 35
                                                      "Doc. Coop"  AT 43
                                                      "Vencto"     AT 62
                                                      "Vlr Titulo" AT 79
                                                      "Desc."      AT 97
                                                      "Abat."      AT 110
                                                      SKIP.
                                END.
                            END.

                            FIND crapsab WHERE crapsab.cdcooper =
                                               crapcob.cdcooper
                                           AND crapsab.nrdconta = 
                                               crapcob.nrdconta
                                           AND crapsab.nrinssac = 
                                               crapcob.nrinssac NO-LOCK 
                                                                NO-ERROR.

                            IF AVAIL crapsab THEN
                            DO:
                                PUT STREAM str_1 crapass.cdagenci
                                                     AT 03
                                                  crapcob.nrdconta
                                                     AT 07
                                                  crapsab.nrinssac
                                                     AT 17
                                                  crapcob.nrdocmto 
                                                     AT 32
                                                  crapcob.dsdoccop 
                                                     AT 43
                                                  crapcob.dtvencto 
                                                     AT 58
                                                  crapcob.vltitulo 
                                                     FORMAT "zzz,zzz,zz9.99" 
                                                     AT 75
                                                  crapcob.vldescto
                                                     FORMAT "zzz,zz9.99" 
                                                     AT 92
                                                  crapcob.vlabatim
                                                     FORMAT "zzz,zz9.99"
                                                     AT 105.

                                ASSIGN aux_qtdtitul = aux_qtdtitul + 1
                                       aux_vltitulo = aux_vltitulo + 
                                                            crapcob.vltitulo
                                       aux_vldescon = aux_vldescon + 
                                                            crapcob.vldescto
                                       aux_vlabatim = aux_vlabatim + 
                                                            crapcob.vlabatim.

                                IF LAST-OF(craprem.cdocorre) THEN
                                DO:
                                    
                                    PUT STREAM str_1 SKIP(1)
                                                     "Total" AT 12
                                                     aux_qtdtitul AT 29 
                                                     aux_vltitulo AT 75 
                                                     aux_vldescon AT 92
                                                     aux_vlabatim AT 105.


                                    ASSIGN aux_qtdtitul = 0
                                           aux_vltitulo = 0
                                           aux_vldescon = 0
                                           aux_vlabatim = 0.
                                END.
                            END.
                                              
                        END.
                    END.

                    OUTPUT STREAM str_1 CLOSE.
                           
                    UNIX SILENT VALUE("cp " + "/usr/coop/" + crapcop.dsdircop + 
                                      "/rl/" + aux_nmarquiv + 
                                      " /usr/coop/" + crapcop.dsdircop + "/rlnsv").

                    ASSIGN aux_tprelato = 0
                           aux_nmrelato = " ".

                    FIND craprel WHERE craprel.cdcooper = crapcop.cdcooper AND
                                       craprel.cdrelato = 596
                                       NO-LOCK NO-ERROR.

                    IF   AVAIL craprel  THEN
                         DO:
                             IF   craprel.tprelato = 2   THEN
                                  ASSIGN aux_tprelato = 1.
                   
                             ASSIGN aux_nmrelato = craprel.nmrelato.
                         END.
                   
                    ASSIGN aux_cdrelato = aux_nmarquiv
                           aux_nmarqtmp = "tmppdf/" + aux_cdrelato + ".txt"
                           aux_nmarqpdf = SUBSTR(aux_cdrelato,1,
                                          LENGTH(aux_cdrelato) - 4) + ".pdf".
                   
                    OUTPUT STREAM str_4 TO VALUE (aux_nmarqtmp).
                    
                    PUT STREAM str_4 crapcop.nmrescop                                 ";"
                                     STRING(YEAR(glb_dtmvtolt),"9999") FORMAT "x(04)" ";"
                                     STRING(MONTH(glb_dtmvtolt),"99")  FORMAT "x(02)" ";"
                                     STRING(DAY(glb_dtmvtolt),"99")    FORMAT "x(02)" ";"
                                     STRING(aux_tprelato,"z9")         FORMAT "x(02)" ";"
                                     aux_nmarqpdf                                     ";"
                                     CAPS(aux_nmrelato)                FORMAT "x(50)" ";"
                                     SKIP.
                   
                    OUTPUT STREAM str_4 CLOSE.
                   
                    
                    UNIX SILENT VALUE("echo script/CriaPDF.sh "               + 
                                      "/usr/coop/" + crapcop.dsdircop         + 
                                      "/rl/"                                  +
                                      aux_nmarquiv + " NAO 132col "           +
                                      STRING(YEAR(glb_dtmvtolt),"9999") + "_" + 
                                      STRING(MONTH(glb_dtmvtolt),"99") + "/"  + 
                                      STRING(DAY(glb_dtmvtolt),"99") + " "    + 
                                      crapcop.dsdircop                        + 
                                      " >> log/CriaPDF.log").
                    
                    UNIX SILENT VALUE("/usr/coop/" + crapcop.dsdircop         + 
                                      "/script/CriaPDF.sh "                   +
                                      "/usr/coop/" + crapcop.dsdircop         + 
                                      "/rl/"                                  +
                                      aux_nmarquiv + " NAO 132col "           +
                                      STRING(YEAR(glb_dtmvtolt),"9999") + "_" + 
                                      STRING(MONTH(glb_dtmvtolt),"99") + "/"  + 
                                      STRING(DAY(glb_dtmvtolt),"99") + " "    + 
                                      crapcop.dsdircop).
                   
                    ASSIGN glb_nrcopias = 1
            	           glb_nmformul = "132col"
		                   glb_nmarqimp = "/usr/coop/" + crapcop.dsdircop 
                                          + "/rl/" + aux_nmarquiv.
        
	                RUN fontes/imprim_unif.p (INPUT crapcop.cdcooper).
        
            END.
            
        END.
        
    END. /* END DO TRANSACTION */

END PROCEDURE.

PROCEDURE verifica_sacado_dda:

    DEF INPUT PARAM par_dtremess AS DATE NO-UNDO.

    DEF VAR h-b1wgen0087 AS HANDLE NO-UNDO.
    DEF VAR h-b1wgen0088 AS HANDLE NO-UNDO.
    DEF VAR h-b1wgen0090 AS HANDLE NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE NO-UNDO.

    DEF VAR aux_nrdocmto AS DECIMAL FORMAT "zzz,zzz,9" NO-UNDO.
    DEF BUFFER crabcob FOR crapcob.

    DO TRANSACTION:       

        EMPTY TEMP-TABLE tt-remessa-dda.
        EMPTY TEMP-TABLE tt-retorno-dda.
        
        FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:

            FOR EACH crapcco WHERE crapcco.cdcooper = crapcop.cdcooper
                               AND crapcco.dsorgarq = "INTERNET"
                               AND crapcco.cddbanco = 085
               ,EACH crapcob WHERE crapcob.cdcooper = crapcco.cdcooper
                               AND crapcob.nrcnvcob = crapcco.nrconven
                               AND crapcob.nrdctabb = crapcco.nrdctabb
                               AND crapcob.cdbandoc = crapcco.cddbanco
                               AND crapcob.nrdconta > 0
                               AND crapcob.flgregis = TRUE
                               AND crapcob.dtmvtolt >= par_dtremess
                               AND crapcob.insitpro >= 1 /* Pagador DDA */
                               AND crapcob.insitpro <= 2 
                               AND crapcob.incobran = 0 /* em aberto */
                               NO-LOCK: 

                FIND crapban WHERE crapban.cdbccxlt = crapcob.cdbandoc
                    NO-LOCK NO-ERROR.

                IF NOT AVAIL crapban THEN
                DO:
                    glb_dscritic = "Erro na crapban. Favor verificar".
                    BELL.
                    MESSAGE glb_dscritic.     
                    PAUSE 2 NO-MESSAGE.
                    RETURN "NOK".
                END.

                /* carrega temp remessa-dda para verificacao */
                CREATE tt-remessa-dda.
                ASSIGN tt-remessa-dda.nrispbif = crapban.nrispbif
                       tt-remessa-dda.cdlegado = "LEG"
                       tt-remessa-dda.idtitleg = STRING(crapcob.idtitleg)
                       tt-remessa-dda.idopeleg = crapcob.idopeleg
                       tt-remessa-dda.insitpro = crapcob.insitpro.
            END.

            
        END.
        /* conectar no banco da JD */
        RUN sistema/generico/procedures/b1wgen9999.p
                                                PERSISTENT SET h-b1wgen9999.
        RUN p-conectajddda IN h-b1wgen9999.

        RUN sistema/generico/procedures/b1wgen0087.p 
                                        PERSISTENT SET h-b1wgen0087.

        IF NOT VALID-HANDLE(h-b1wgen0087) THEN
        DO:
            glb_dscritic = "Handle invalido para a BO b1wgen0087.".
            BELL.
            MESSAGE glb_dscritic.     
            PAUSE 2 NO-MESSAGE.
            NEXT.
        END.

        RUN Retorno-Operacao-Titulos-DDA IN h-b1wgen0087
                                            (INPUT TABLE tt-remessa-dda,
                                             OUTPUT TABLE tt-retorno-dda).

        DELETE PROCEDURE h-b1wgen0087.       

        FOR EACH tt-retorno-dda WHERE tt-retorno-dda.insitpro = 4 
                                                            /* EJ/EC erro */
                                                                    NO-LOCK:

            FIND FIRST crapcob WHERE crapcob.idtitleg = DECI(tt-retorno-dda.idtitleg)
                 USE-INDEX crapcob7.

            IF AVAIL crapcob THEN
            DO:
                ASSIGN crapcob.insitpro = 0 /* Pagador comum */
                       crapcob.flgcbdda = FALSE.

                IF NOT VALID-HANDLE(h-b1wgen0088) THEN
                   RUN sistema/generico/procedures/b1wgen0088.p
                                               PERSISTENT SET h-b1wgen0088.

                IF NOT VALID-HANDLE(h-b1wgen0088) THEN
                DO:
                    glb_dscritic = "Handle invalido para a BO b1wgen0088.".
                    BELL.
                    MESSAGE glb_dscritic.     
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.

                RUN cria-log-cobranca IN h-b1wgen0088
                      (INPUT ROWID(crapcob),
                       INPUT glb_cdoperad,
                       INPUT par_dtremess,
                       INPUT "Titulo Rejeitado na CIP" ).

                IF crapcob.inemiten = 2 THEN /* cooperado emite e expede */
                DO:
                    ASSIGN crapcob.incobran = 4. /* titulo rejeitado */

                    /* gerar retorno de entrada rejeitada ao cooperado */
                    RUN sistema/generico/procedures/b1wgen0090.p PERSISTENT 
                        SET h-b1wgen0090.

                    IF  NOT VALID-HANDLE(h-b1wgen0090) THEN
                        DO:
                            RETURN "NOK".
                        END.

                    FIND FIRST crapcop WHERE crapcop.cdcooper = crapcob.cdcooper
                        NO-LOCK NO-ERROR.

                    RUN prep-retorno-cooperado 
                        IN h-b1wgen0090 (INPUT ROWID(crapcob),
                                         INPUT 3, /* ent rejeitada */
                                         INPUT "",
                                         INPUT 0,
                                         INPUT crapcop.cdbcoctl,
                                         INPUT crapcop.cdagectl,
                                         INPUT par_dtremess,
                                         INPUT glb_cdoperad,
                                         INPUT crapcob.nrremass).

                    DELETE PROCEDURE h-b1wgen0090.
                END.

                IF crapcob.inemiten = 1 THEN /* banco emite e expede */
                DO:
                    ASSIGN crapcob.incobran = 4. /* titulo rejeitado */

                    IF NOT VALID-HANDLE(h-b1wgen0088) THEN
                       RUN sistema/generico/procedures/b1wgen0088.p
                           PERSISTENT SET h-b1wgen0088.

                    IF NOT VALID-HANDLE(h-b1wgen0088) THEN
                    DO:
                        glb_dscritic = "Handle invalido para a BO b1wgen0088.".
                        BELL.
                        MESSAGE glb_dscritic.     
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.

                    RUN cria-log-cobranca IN h-b1wgen0088
                                      (INPUT ROWID(crapcob),
                                       INPUT glb_cdoperad,
                                       INPUT par_dtremess,
                                       INPUT "Titulo Rejeitado - Pagador Comum").

                    /* buscar convenio Banco do Brasil */
                    FIND crapcco WHERE crapcco.cdcooper = crapcob.cdcooper
                                   AND crapcco.cddbanco = 001
                                   AND crapcco.flgativo = TRUE
                                   AND crapcco.flgregis = TRUE
                                                         /* cob. Registrada */
                                   AND crapcco.flginter = TRUE /* internet */
                                   AND crapcco.dsorgarq = "INTERNET"
                                   NO-LOCK NO-ERROR.

                    IF AVAIL crapcco THEN
                    DO:
                        /* buscar o convenio cadastrado do cooperado */
                        FIND crapceb WHERE crapceb.cdcooper = crapcco.cdcooper
                                       AND crapceb.nrdconta = crapcob.nrdconta
                                       AND crapceb.nrconven = crapcco.nrconven
                                       NO-LOCK NO-ERROR.                        

                        IF AVAIL crapceb THEN
                        DO:
                            /* buscar o ultimo titulo do documento do cooperado
                                                            no novo convenio */
                            FIND LAST crabcob 
                                    WHERE crabcob.cdcooper = crapceb.cdcooper
                                      AND crabcob.nrdconta = crapceb.nrdconta
                                      AND crabcob.nrcnvcob = crapcco.nrconven
                                      AND crabcob.nrdctabb = crapcco.nrdctabb
                                      AND crabcob.cdbandoc = crapcco.cddbanco
                                      NO-LOCK NO-ERROR.

                            IF AVAIL crabcob THEN
                            DO:
                                ASSIGN aux_nrdocmto = crabcob.nrdocmto + 1.

                                CREATE crabcob.
                                BUFFER-COPY crapcob 
                                     EXCEPT crapcob.nrcnvcob crapcob.nrdocmto 
                                            crapcob.incobran crapcob.cdcartei 
                                            crapcob.nrnosnum crapcob.cdbandoc
                                            crapcob.nrdctabb
                                         TO crabcob 
                                     ASSIGN crabcob.nrcnvcob = crapcco.nrconven
                                            crabcob.cdbandoc = crapcco.cddbanco
                                            crabcob.nrdctabb = crapcco.nrdctabb
                                            crabcob.cdcartei = crapcco.cdcartei
                                            crabcob.incobran = 0                                                                                    
                                            crabcob.nrdocmto = aux_nrdocmto
                                            crabcob.nrnosnum = 
                                     STRING(crapcco.nrconven, "9999999") + 
                                     STRING(crapceb.nrcnvceb, "9999") + 
                                     STRING(aux_nrdocmto, "999999").
                                VALIDATE crabcob.

                                RUN gera_pedido_remessa IN h-b1wgen0088
                                                     (INPUT ROWID(crabcob),
                                                      INPUT par_dtremess,
                                                      INPUT glb_cdoperad).

                                RUN cria-log-cobranca IN h-b1wgen0088
                                      (INPUT ROWID(crabcob),
                                       INPUT glb_cdoperad,
                                       INPUT par_dtremess,
                                       INPUT "Titulo Gerado - Pagador nao DDA").

                            END.

                        END.
                    END.
                END.
            END.
        END.

        /* desconectar banco JD */
        IF VALID-HANDLE(h-b1wgen9999) THEN
        DO:
            RUN p-desconectajddda IN h-b1wgen9999.
            DELETE PROCEDURE h-b1wgen9999.
        END.

        FOR EACH tt-retorno-dda WHERE tt-retorno-dda.insitpro = 3 
                                                       /* RC - Registro CIP */
                                                                NO-LOCK:

            FIND crapcob WHERE crapcob.idtitleg = DECI(tt-retorno-dda.idtitleg)
                                                 USE-INDEX crapcob7 
                                                 NO-ERROR.

            IF AVAIL crapcob THEN
            DO:
                ASSIGN crapcob.insitpro = tt-retorno-dda.insitpro
                       crapcob.flgcbdda = TRUE.

                IF NOT VALID-HANDLE(h-b1wgen0088) THEN
                   RUN sistema/generico/procedures/b1wgen0088.p
                       PERSISTENT SET h-b1wgen0088.

                RUN cria-log-cobranca IN h-b1wgen0088
                      (INPUT ROWID(crapcob),
                       INPUT glb_cdoperad,
                       INPUT par_dtremess,
                       INPUT "Titulo Registrado - CIP").

                /* gerar retorno de entrada confirmada ao cooperado */
                RUN sistema/generico/procedures/b1wgen0090.p PERSISTENT 
                    SET h-b1wgen0090.

                IF  NOT VALID-HANDLE(h-b1wgen0090) THEN
                    DO:
                        RETURN "NOK".
                    END.

                FIND FIRST crapcop WHERE crapcop.cdcooper = crapcob.cdcooper
                    NO-LOCK NO-ERROR.

                RUN prep-retorno-cooperado IN h-b1wgen0090 (INPUT ROWID(crapcob),
                                                            INPUT 2,
                                                            /* A4 = Pagador DDA */
                                                            INPUT "A4", 
                                                            INPUT 0,
                                                            INPUT crapcop.cdbcoctl,
                                                            INPUT crapcop.cdagectl,
                                                            INPUT par_dtremess,
                                                            INPUT glb_cdoperad,
                                                            INPUT crapcob.nrremass).
                DELETE PROCEDURE h-b1wgen0090.

            END.                                               

        END.

        IF VALID-HANDLE(h-b1wgen0088) THEN
        DO:
            DELETE PROCEDURE h-b1wgen0088.
        END.

    END.

END PROCEDURE.

/* LOG de execuaco dos programas */
PROCEDURE gera_log_execucao:

    DEF INPUT PARAM par_nmprgexe    AS  CHAR        NO-UNDO.
    DEF INPUT PARAM par_indexecu    AS  CHAR        NO-UNDO.
    DEF INPUT PARAM par_cdcooper    AS  INT         NO-UNDO.
    DEF INPUT PARAM par_tpexecuc    AS  CHAR        NO-UNDO.
    
    DEF VAR aux_nmarqlog            AS  CHAR        NO-UNDO.

    ASSIGN aux_nmarqlog = "log/prcctl_" + STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(DAY(glb_dtmvtolt),"99") + ".log".
    
    UNIX SILENT VALUE("echo " + "Manual - " + 
                      STRING(TIME,"HH:MM:SS") + "' --> '"  +
                      "Coop.:" + STRING(par_cdcooper) + " '" +  
                      par_tpexecuc + "' - '" + 
                      par_nmprgexe + "': " + 
                      par_indexecu +  
                      " >> " + aux_nmarqlog).

    RETURN "OK".  
END PROCEDURE.
