/*
 * Programa wpgd0049a.p - Acompanhamento do PPR
*/
/*****************************************************************************

 Alterações: 08/05/2009 - Criação programa (Martin)
 
             26/06/2009 - Criadas variáveis para receber valor de função e 
                          atribuir ao campo da tabela (Diego).
                                                                          
             05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                          busca na gnapses de CONTAINS para MATCHES
                          (Guilherme Maba).

             28/11/2012 - Substituir tabela "gncoper" por "crapcop"
                          (David Kruger).
                          
             04/04/2013 - Alteração para receber logo na alto vale,
                          recebendo nome de viacrediav e buscando com
                          o respectivo nome (David Kruger).       
                          
**************************************************************************** */

create widget-pool.

DEFINE TEMP-TABLE tt-PPR NO-UNDO
       FIELD cdAgencia  AS INT 
       FIELD descEvento AS CHAR
       FIELD data       AS DATE
       FIELD periodo    AS CHAR
       FIELD meta       AS INT
       FIELD resultado  AS INT
       FIELD diferenca  AS INT
       FIELD rstInteg   AS INT
       FIELD mtaCurso   AS INT      
       FIELD rstCurso   AS INT   
       FIELD mtaEvento  AS INT   
       FIELD rstEvento  AS INT      
       FIELD rstAssembl AS INT
       INDEX idx cdAgencia data.

DEFINE TEMP-TABLE tt-subtotal NO-UNDO
       FIELD cdAgenci  AS INT
       FIELD nvoAssoc   AS INT
       FIELD mtaKits    AS INT
       FIELD rstKits    AS INT
       FIELD difKits    AS INT
       FIELD mtaAssembl AS INT
       FIELD rstAssembl AS INT
       FIELD difAssembl AS INT
       FIELD mtaInteg   AS INT
       FIELD rstInteg   AS INT
       FIELD difInteg   AS INT
       FIELD mtaCurso   AS INT
       FIELD rstCurso   AS INT
       FIELD difCurso   AS INT
       FIELD mtaEvento  AS INT
       FIELD rstEvento  AS INT
       FIELD difEvento  AS INT
       INDEX idx cdAgenci.

DEFINE TEMP-TABLE tt-total NO-UNDO
       FIELD mtaKits    AS INT
       FIELD rstKits    AS INT
       FIELD difKits    AS INT
       FIELD mtaAssembl AS INT
       FIELD rstAssembl AS INT
       FIELD difAssembl AS INT
       FIELD mtaInteg   AS INT
       FIELD rstInteg   AS INT
       FIELD difInteg   AS INT
       FIELD mtaCurso   AS INT
       FIELD rstCurso   AS INT
       FIELD difCurso   AS INT
       FIELD mtaEvento  AS INT
       FIELD rstEvento  AS INT
       FIELD difEvento  AS INT.

DEFINE VARIABLE cookieEmUso                  AS CHARACTER.
DEFINE VARIABLE permiteExecutar              AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao        AS CHARACTER.
DEFINE VARIABLE msgsDeErro                   AS CHARACTER.

DEFINE VARIABLE idEvento                     AS INTEGER.
DEFINE VARIABLE cdCooper                     AS INTEGER.
DEFINE VARIABLE iAgencias                    AS INTEGER. 
DEFINE VARIABLE cdAgenci                     AS INTEGER.
DEFINE VARIABLE grupAgencia                  AS CHARACTER.
DEFINE VARIABLE descAgencia                  AS CHARACTER. 
DEFINE VARIABLE dtAnoAge                     AS INTEGER.
DEFINE VARIABLE nrPeriodo                    AS INTEGER.
DEFINE VARIABLE pctInteg                     AS DECIMAL.
DEFINE VARIABLE pctKits                      AS DECIMAL.
DEFINE VARIABLE pctAssembleia                AS DECIMAL.
DEFINE VARIABLE pctPPR1                      AS DECIMAL.
DEFINE VARIABLE pctPPR2                      AS DECIMAL.
DEFINE VARIABLE tipoRelat                    AS CHARACTER.
DEFINE VARIABLE dataInicial                  AS DATE.
DEFINE VARIABLE dataFinal                    AS DATE.
DEFINE VARIABLE dtaFimPer                    AS DATE.
DEFINE VARIABLE dtaIniPer                    AS DATE.
DEFINE VARIABLE mesPeriodo                   AS CHARACTER.
DEFINE VARIABLE tipoDeRelatorio              AS INTEGER.
DEFINE VARIABLE consideraEventosForaDaAgenda AS LOGICAL.
DEFINE VARIABLE nomeDoRelatorio              AS CHARACTER.

DEFINE VARIABLE imagemDoProgrid              AS CHARACTER.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER.

DEFINE VARIABLE auxiliar                     AS CHARACTER.
DEFINE VARIABLE facilitador                  AS CHARACTER.
DEFINE VARIABLE facilitadores                AS CHARACTER.
DEFINE VARIABLE nomeDaAgencia                AS CHARACTER.
DEFINE VARIABLE localDoEvento1               AS CHARACTER.
DEFINE VARIABLE localDoEvento2               AS CHARACTER.

DEFINE VARIABLE ajuste                       AS INTEGER.
DEFINE VARIABLE conta                        AS INTEGER.
DEFINE VARIABLE conta2                       AS INTEGER.
DEFINE VARIABLE corEmUso                     AS CHARACTER.
DEFINE VARIABLE dscMes                       AS CHARACTER INITIAL ["JANEIRO,FEVEREIRO,MARÇO,ABRIL,MAIO,JUNHO,JULHO,AGOSTO,SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO"].
DEFINE VARIABLE situacao                     AS CHARACTER INITIAL ["Pendente,Confirmado,Desistente,Excedente,Cancelado"].
DEFINE VARIABLE sobreNomeDoEvento            AS CHARACTER.
DEFINE VARIABLE valorDaVerba                 AS DECIMAL.
DEFINE VARIABLE totalVagas                   AS INT.
DEFINE VARIABLE geralVagas                   AS INT.

DEFINE VARIABLE iQtQstDevolvido              AS INT NO-UNDO.
DEFINE VARIABLE iQtQstDevolTotal             AS INT NO-UNDO.

DEFINE VARIABLE aux_nmrescop                 AS CHARACTER NO-UNDO.

DEFINE BUFFER bfCraptab FOR Craptab.
DEFINE BUFFER bfCrapadp FOR Crapadp.
DEFINE BUFFER bfCrapage FOR crapage.

                           
/*****************************************************************************/
/*   Bloco de includes                                                       */
/*****************************************************************************/

{src/web/method/wrap-cgi.i}

/*****************************************************************************/
/*   Bloco de funçoes                                                        */
/*****************************************************************************/

FUNCTION erroNaValidacaoDoLogin RETURNS LOGICAL (opcao AS CHARACTER):

    IF opcao = "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
       {&out} '<script language="Javascript">' SKIP
              '   top.close(); ' SKIP
              '   window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes");' SKIP
              '</script>' SKIP.

    IF opcao = "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
       DO: 
          DELETE-COOKIE("cookie-usuario-em-uso",?,?).
          {&out} '<script language="Javascript">' SKIP
                 '   top.close(); ' SKIP
                 '   window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes");' SKIP
                 '</script>' SKIP.
       END.

    RETURN TRUE.

END FUNCTION. /* erroNaValidacaoDoLogin RETURNS LOGICAL () */

FUNCTION fn-eventoPeriodo RETURNS CHARACTER (meses AS CHAR):
    IF lookup(string(crapadp.nrmeseve,"99"),meses) > 0 THEN DO:
       RETURN string(crapadp.nrmeseve) + ",1". 
    END.
    ELSE IF lookup(string(crapadp.nrmesage,"99"),meses) > 0 THEN DO: 
        RETURN string(crapadp.nrmesage) + ",0". 
    END.
    ELSE DO:
        RETURN "".
    END.
END.

FUNCTION fn-dscEvento RETURN CHARACTER ():
    FIND FIRST Crapedp WHERE Crapedp.IdEvento = Crapadp.IdEvento AND
                             Crapedp.CdCooper = Crapadp.CdCooper AND
                             Crapedp.DtAnoAge = Crapadp.DtAnoAge AND
                             Crapedp.CdEvento = crapadp.cdEvento NO-LOCK NO-ERROR.
    IF AVAILABLE Crapedp THEN 
       RETURN Crapedp.NmEvento.
    ELSE
       RETURN "".
END.

FUNCTION fn-dscPeriodo RETURN CHARACTER (mes AS INT,tipo AS INT):
    DEF VAR dtaEvento AS CHAR NO-UNDO.
    IF tipo = 1 THEN DO:
        IF crapadp.dtinieve <> ? THEN DO:
           ASSIGN dtaEvento = STRING(crapadp.dtinieve,"99/99/9999").
           IF crapadp.dtfineve <> ? THEN DO:
              ASSIGN dtaEvento = dtaEvento + " - " + STRING(crapadp.dtfineve,"99/99/9999").
           END.
           RETURN dtaEvento.
        END.
        ELSE DO:
           RETURN entry(mes,dscMes).
        END.
    END.
    ELSE DO:
        IF crapadp.dtinieve <> ? THEN DO:
           RETURN string(crapadp.dtinieve,"99/99/9999").
        END.
        ELSE DO:
           RETURN STRING((DATE((mes + 1),01,dtanoage) - 1),"99/99/9999").
        END.
    END.
END.

/* function fn-frequencias
Chamada pela funcao fn-qtdEvento.
*/
FUNCTION fn-frequencias RETURN CHARACTER (tipo AS INT,id-evento AS int,evento AS INT,agencia AS INT):
    DEF VAR inscritos    AS INT NO-UNDO.
    DEF VAR faltantes    AS INT NO-UNDO.
    DEF VAR retorno      AS CHAR NO-UNDO.

    IF tipo = 2 AND crapadp.cdevento <> 13 THEN RETURN "0,0".

    FIND FIRST Crapedp WHERE Crapedp.IdEvento = id-evento AND
                             Crapedp.CdCooper = Crapadp.CdCooper AND
                             Crapedp.DtAnoAge = Crapadp.DtAnoAge AND
                             Crapedp.CdEvento = evento NO-LOCK NO-ERROR.
    IF (tipo = 3 AND crapedp.tppartic = 4)
    OR (tipo = 4 AND crapedp.tppartic <> 4) THEN 
        RETURN "0,0".

    FOR EACH crapidp WHERE crapidp.idevento = id-evento         AND
                           crapidp.cdcooper = Crapadp.CdCooper  AND 
                           crapidp.dtanoage = Crapadp.DtAnoAge  AND 
                           crapidp.cdagenci = agencia           AND 
                           crapidp.cdevento = evento            AND 
                           crapidp.nrseqeve = Crapadp.nrSeqDig  AND 
                           crapidp.idstains = 2 NO-LOCK: 
         ASSIGN inscritos = inscritos + 1.
        /* *** Se incricao cofirmada e inscricoes encerradas e evento NAO CANCELADO, verifica faltas ****/
        IF Crapidp.IdStaIns = 2  AND Crapidp.QtFalEve > 0 AND Crapadp.idstaeve <> 2 /*Cancelado*/ THEN DO:
           IF ((crapidp.qtfaleve * 100) / Crapadp.QtDiaEve) > (100 - crapedp.prfreque) THEN DO:
              ASSIGN faltantes = faltantes + 1.
           END.
        END.    
    END.
    ASSIGN retorno = STRING(crapedp.qtmaxtur).
    /* Se o evento já ocorreu e NAO FOI CANCELADO, conta os que COMPARECERAM */
    IF crapadp.dtfineve  < TODAY AND
       crapadp.idstaeve <> 2     THEN DO:
       ASSIGN retorno = retorno + "," + STRING((inscritos - faltantes)).
    END.
    ELSE DO:
       ASSIGN retorno = retorno + ",0".
    END.
    RETURN retorno.
END.

/* function fn-qtdEvento
Parametro tipo:
1- Obtem vagas ofertadas e comparecimentos no geral
2- Obtem vagas ofertadas e comparecimentos para eventos de comparecimento
3- Obtem vagas ofertadas e comparecimentos para eventos exclusivo de cooperados
4- Obtem vagas ofertadas e comparecimentos para eventos exclusivo da comunidade
5- Obtem vagas ofertadas e comparecimentos para pre-assembleias e asssembleias
*/
FUNCTION fn-qtdEvento RETURN CHARACTER (tipo AS INT):
    DEF VAR inscritos    AS INT NO-UNDO.
    DEF VAR faltantes    AS INT NO-UNDO.
    DEF VAR comparecidos AS INT NO-UNDO.
    DEF VAR retorno      AS CHAR NO-UNDO.
    DEF VAR quantidades  AS CHAR NO-UNDO.

    IF tipo < 5 THEN DO:
       RETURN fn-frequencias(tipo,1,crapadp.cdevento,crapadp.cdagenci).
    END.
    ELSE DO:
       /** pre-assembleias **/
       ASSIGN quantidades  = fn-frequencias(tipo,2,4,crapadp.cdagenci)
              inscritos    = INT(ENTRY(1,quantidades))
              comparecidos = INT(ENTRY(2,quantidades))
       /** assembleias **/
              quantidades  = fn-frequencias(tipo,2,9,0)
              inscritos    = inscritos + INT(ENTRY(1,quantidades))
              comparecidos = comparecidos + INT(ENTRY(2,quantidades)).
       RETURN STRING(inscritos) + "," + STRING(comparecidos).
    END.
END.

/* fn-calculaMesCorreto
Chamado pela função fn-novoAssociado  */
FUNCTION fn-calculaMesCorreto RETURNS DATE ():
    DEF VAR dtaFinal AS DATE NO-UNDO.

    IF YEAR(TODAY) > dtAnoAge THEN DO:
        IF nrPeriodo = 1 THEN DO:
           ASSIGN dtaFinal = (DATE(07,01,dtAnoAge) - 1).
        END.
        ELSE DO:
           ASSIGN dtaFinal = DATE(12,31,dtAnoAge).
        END.
    END.
    ELSE IF YEAR(TODAY) < dtAnoAge THEN DO:
        ASSIGN dtaFinal = DATE(01,01,dtAnoAge).
    END.
    ELSE DO:
        IF MONTH(TODAY) <= 6 THEN DO:
           IF nrPeriodo = 1 THEN DO:
              ASSIGN dtaFinal = DATE(MONTH(TODAY),1,dtAnoAge) - 1.
           END.
           ELSE DO:
              ASSIGN dtaFinal = DATE(08,1,dtAnoAge) - 1.
           END.
        END.
        ELSE DO:
           IF nrPeriodo = 1 THEN DO:
              ASSIGN dtaFinal = DATE(7,1,dtAnoAge) - 1.
           END.
           ELSE DO:
              ASSIGN dtaFinal = DATE(MONTH(TODAY),1,dtAnoAge) - 1.
           END.
        END.
    END.
    RETURN dtaFinal.
END.

/*  fn-nvoAssociado
Parametro Tipo:
1 - le registros para checagem de novos cooperados
2 - le registros para checagem de assembleia
*/
FUNCTION fn-nvoAssociado RETURNS INTEGER (tipo AS INT,pAgenci AS INT):
     DEF VAR qtTotal     AS INT  NO-UNDO.
     DEF VAR dtaFinal    AS DATE NO-UNDO. 

     IF tipo = 1 THEN DO:
        dtafinal = fn-calculaMesCorreto().
     END.
     ELSE DO:
         ASSIGN dtaFinal   = DATE(03,01,dtAnoAge) - 1.
         IF NOT CAN-FIND(FIRST crapger WHERE crapger.cdcooper  = cdCooper
                                         AND crapger.dtrefere  = dtaFinal
                                         AND crapger.cdagenci  = pAgenci) THEN DO:
            ASSIGN dtaFinal = fn-calculaMesCorreto().
         END.
     END.
     FIND LAST crapger WHERE crapger.cdcooper = cdCooper
                         AND crapger.dtrefere <= dtaFinal
                         AND crapger.cdagenci = pAgenci
                   NO-LOCK NO-ERROR.
     IF AVAIL crapger THEN
        ASSIGN dtaFinal = crapger.dtrefere.
     IF YEAR(dtaFinal) <> dtAnoAge AND tipo = 2 THEN
        RETURN 0.
     ELSE DO:
        FOR EACH crapger WHERE crapger.cdcooper = cdCooper
                           AND crapger.dtrefere = dtaFinal
                           AND crapger.cdagenci = pAgenci
                         NO-LOCK:
            ASSIGN qtTotal = qtTotal + crapger.qtAssoci.
        END.
        RETURN qtTotal.
     END.
END.

FUNCTION fn-qstDevolvidos RETURNS INTEGER(pAgencia AS INT):
    DEF VAR devolvidos AS INTEGER NO-UNDO.
    DEF VAR dtaInicial AS DATE NO-UNDO.
    DEF VAR dtaFinal   AS DATE NO-UNDO.

    IF nrPeriodo = 1 THEN DO:
       ASSIGN dtaInicial = DATE(01,01,dtanoage)
              dtaFinal   = DATE(06,30,dtanoage).
    END.
    ELSE DO:
       ASSIGN dtaInicial = DATE(07,01,dtanoage)
              dtaFinal   = DATE(12,31,dtanoage).
    END.
    FOR EACH crapkbq WHERE crapkbq.idevento = idEvento
                       AND crapkbq.cdcooper = cdCooper
                       AND crapkbq.cdagenci = pAgencia
                       AND crapkbq.tpdeitem = 3
                       AND crapkbq.dtdenvio >= dtaInicial
                       AND crapkbq.dtdenvio <= dtaFinal
                     NO-LOCK:
        ASSIGN devolvidos = devolvidos + crapkbq.qtdenvio.
    END.
    RETURN devolvidos.
END.

FUNCTION relatorioPPR RETURNS LOGICAL ():
    DEF VAR linhasspan AS INT NO-UNDO. 
    
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP.
    {&out} '      <tr>' SKIP
           '         <td class="tdCab1" colspan="5">PARTICIPAÇÃO SOCIAL</td>' SKIP
           '      </tr>' SKIP.

    ASSIGN corEmUso = "#FFFFFF"
           linhasspan = IF nrPeriodo = 1 THEN 4 ELSE 3.
       
    FOR EACH tt-ppr
        BREAK BY tt-ppr.cdagenci
              BY tt-ppr.data
              BY tt-ppr.periodo:
          
        IF FIRST-OF(tt-ppr.CdAgenci) THEN DO:
           FIND Crapage WHERE Crapage.CdCooper = cdCooper AND Crapage.CdAgenci = tt-ppr.CdAgenci NO-LOCK NO-ERROR.
           RUN agrupaAgencias(crapage.cdagenci,
                              (IF AVAILABLE Crapage THEN trim(crapage.NmResAge) ELSE ("Agencia " + STRING(Cdagenci,"999"))),
                              OUTPUT descAgencia, OUTPUT grupAgencia).
           {&out} '      <tr>' SKIP
                  '         <td class="tdCab2" colspan="5">PAC: ' tt-ppr.CdAgenci ' - '  descAgencia '</td>' SKIP
                  '      </tr>' SKIP.

           {&out} '      <tr class="tdCab3">' SKIP
                  '         <td>Descrição do evento</td>' SKIP
                  '         <td align="center">Período</td>' SKIP
                  '         <td align="center">Meta</td>' SKIP
                  '         <td align="center">Resultado</td>' SKIP
                  '         <td align="center">Diferença</td>' SKIP
                  '      </tr>' SKIP.
        END.
               
        {&out} '      <tr bgcolor="' corEmUso '">' SKIP
               '         <td width="35%">' tt-ppr.descEvento '</td>' SKIP
               '         <td align="center">' tt-ppr.periodo '</td>' SKIP
               '         <td align="center">' tt-ppr.meta '</td>' SKIP
               '         <td align="center">' tt-ppr.resultado '</td>' SKIP
               '         <td align="center">' tt-ppr.diferenca '</td>' SKIP
               '      </tr>' SKIP.
        
        IF corEmUso = "#FFFFFF" THEN
           ASSIGN corEmUso = "#F5F5F5".
        ELSE
           ASSIGN corEmUso = "#FFFFFF".
        
        IF LAST-OF(tt-ppr.cdagenci) THEN DO:
           FIND FIRST tt-subtotal WHERE tt-subtotal.cdagenci = tt-ppr.cdagenci.
           {&out} '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP 
                  '      <tr><td colspan="5" align="center" height="1%" bgColor="black"></td></tr>' SKIP.
           {&out} '      <tr bgcolor="' corEmUso '" colspan="5">' SKIP
                  '         <td width="35%" colspan="5">SUBTOTAL</td>' SKIP
                  '      </tr>' SKIP.
           {&out} '      <tr class="tdCab3">' SKIP
                  '         <td>Participações NOVOS Cooperados - Integrações</td>' SKIP
                  '         <td align="center" valign="center" rowspan="' linhasspan '">' string(pctPPR1,">9.99") '% do PPR</td>' SKIP
                  '         <td align="center">' string(tt-subtotal.mtaInteg,"->>>>>9") '</td>' SKIP
                  '         <td align="center">' string(tt-subtotal.rstInteg,"->>>>>9") '</td>' SKIP
                  '         <td align="center">' STRING(tt-subtotal.difInteg,"->>>>>9") '</td>' SKIP
                  '      </tr>' SKIP.
           {&out} '      <tr class="tdCab3">' SKIP
                  '         <td>Participações NOVOS Cooperados - Kits</td>' SKIP
                  '         <td align="center">' string(tt-subtotal.mtaKits,"->>>>>9") '</td>' SKIP
                  '         <td align="center">' string(tt-subtotal.rstKits,"->>>>>9") '</td>' SKIP
                  '         <td align="center">' STRING(tt-subtotal.difKits,"->>>>>9") '</td>' SKIP
                  '      </tr>' SKIP.
           {&out} '      <tr class="tdCab3">' SKIP
                  '         <td>Cursos e Palestras (cooperados e comunidades)</td>' SKIP
                  '         <td align="center">' string(tt-subtotal.mtaCurso,"->>>>>9") '</td>' SKIP
                  '         <td align="center">' string(tt-subtotal.rstCurso,"->>>>>9") '</td>' SKIP
                  '         <td align="center">' STRING(tt-subtotal.difCurso,"->>>>>9") '</td>' SKIP
                  '      </tr>' SKIP.
           IF nrPeriodo = 1 THEN
              {&out} '      <tr class="tdCab3">' SKIP
                     '         <td>Pré-Assembléia e Assembléia Geral</td>' SKIP
                     '         <td align="center">' string(tt-subtotal.mtaAssembl,"->>>>>9") '</td>' SKIP
                     '         <td align="center">' string(tt-subtotal.rstAssembl,"->>>>>9") '</td>' SKIP
                     '         <td align="center">' STRING(tt-subtotal.difAssembl,"->>>>>9") '</td>' SKIP
                     '      </tr>' SKIP.
           {&out} '      <tr class="tdCab3">' SKIP
                  '         <td>Eventos comunidade (participação somente comunidade)</td>' SKIP
                  '         <td align="center">' string(pctPPR2,">9.99") '% do PPR</td>' SKIP
                  '         <td align="center">' string(tt-subtotal.mtaEvento,"->>>>>9") '</td>' SKIP
                  '         <td align="center">' string(tt-subtotal.rstEvento,"->>>>>9") '</td>' SKIP
                  '         <td align="center">' STRING(tt-subtotal.difEvento,"->>>>>9") '</td>' SKIP
                  '      </tr>' SKIP.

           {&out} '      <tr><td colspan="11" align="center"> &nbsp; </td></tr>' SKIP.
                                            
        END.

        IF LAST(tt-ppr.cdagenci) THEN DO:
            FIND FIRST tt-total.
            {&out} '      <tr><td colspan="5" align="center"> &nbsp; </td></tr>' SKIP 
                   '      <tr><td colspan="5" align="center" height="1%" bgColor="black"></td></tr>' SKIP.
            {&out} '      <tr bgcolor="' corEmUso '" colspan="5">' SKIP
                   '          <td width="35%" colspan="5">TOTAL GERAL</td>' SKIP
                   '      </tr>' SKIP.
            {&out} '      <tr class="tdCab3">' SKIP
                   '         <td>Participações NOVOS Cooperados - Integrações</td>' SKIP
                   '         <td align="center" valign="center" rowspan="' linhasspan '">' string(pctPPR1,">9.99") '% do PPR</td>' SKIP
                   '         <td align="center">' string(tt-total.mtaInteg,"->>>>>9") '</td>' SKIP
                   '         <td align="center">' string(tt-total.rstInteg,"->>>>>9") '</td>' SKIP
                   '         <td align="center">' STRING(tt-total.difInteg,"->>>>>9") '</td>' SKIP
                   '      </tr>' SKIP.
            {&out} '      <tr class="tdCab3">' SKIP
                   '         <td>Participações NOVOS Cooperados - Kits</td>' SKIP
                   '         <td align="center">' string(tt-total.mtaKits,"->>>>>9") '</td>' SKIP
                   '         <td align="center">' string(tt-total.rstKits,"->>>>>9") '</td>' SKIP
                   '         <td align="center">' STRING(tt-total.difKits,"->>>>>9") '</td>' SKIP
                   '      </tr>' SKIP.
            {&out} '      <tr class="tdCab3">' SKIP
                   '         <td>Cursos e Palestras (cooperados e comunidades)</td>' SKIP
                   '         <td align="center">' string(tt-total.mtaCurso,"->>>>>9") '</td>' SKIP
                   '         <td align="center">' string(tt-total.rstCurso,"->>>>>9") '</td>' SKIP
                   '         <td align="center">' STRING(tt-total.difCurso,"->>>>>9") '</td>' SKIP
                   '      </tr>' SKIP.
            IF nrPeriodo = 1 THEN
               {&out} '      <tr class="tdCab3">' SKIP
                      '         <td>Pré-Assembléia e Assembléia Geral</td>' SKIP
                      '         <td align="center">' string(tt-total.mtaAssembl,"->>>>>9") '</td>' SKIP
                      '         <td align="center">' string(tt-total.rstAssembl,"->>>>>9") '</td>' SKIP
                      '         <td align="center">' STRING(tt-total.difAssembl,"->>>>>9") '</td>' SKIP
                      '      </tr>' SKIP.
            {&out} '      <tr class="tdCab3">' SKIP
                   '         <td>Eventos comunidade (participação somente comunidade)</td>' SKIP
                   '         <td align="center">' string(pctPPR2,">9.99") '% do PPR</td>' SKIP
                   '         <td align="center">' string(tt-total.mtaEvento,"->>>>>9") '</td>' SKIP
                   '         <td align="center">' string(tt-total.rstEvento,"->>>>>9") '</td>' SKIP
                   '         <td align="center">' STRING(tt-total.difEvento,"->>>>>9") '</td>' SKIP
                   '      </tr>' SKIP.
        END.
            
    END. /* FOR EACH tt-ppr  */
    
    {&out} '   </table>' SKIP.

    RETURN TRUE.

END FUNCTION. /* inscricoesNosEventosPorPac RETURNS LOGICAL () */


FUNCTION montaTela RETURNS LOGICAL ():
    DEF VAR prmExcel AS CHAR NO-UNDO.

    {&out} '<html>' SKIP
           '<head>' SKIP
           '<title>Progrid - PPR</title>' SKIP.

    {&out} '<style>' SKIP
           '   body         ~{ background-color: #FFFFFF; }' SKIP
           '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdCab1      ~{ background-color: #B1B1B1; font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; }' SKIP
           '   .tdCab2      ~{ background-color: #C6C6C6; font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; }' SKIP
           '   .tdCab3      ~{ background-color: #DBDBDB; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdLabel     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
           '   .tdDados     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-bottom: #000000 0px solid }' SKIP
           '   .tdTitulo1   ~{ font-family: Verdana; font-size: 24px; font-weight: normal;}' SKIP
           '   .tab1        ~{ border-collapse:collapse; border-top: #000000 1px solid; border-bottom: #000000 1px solid; border-right: #000000 1px solid; border-left: #000000 1px solid; }' SKIP
           '</style>' SKIP.

    {&out} '</head>' SKIP
           '<body bgcolor="#FFFFFF" topmargin="0" marginwidth="0" marginheight="0">' SKIP
           '<div align="center">' SKIP.
    
    /* *** Botoes de fechar e imprimir *** */
    IF tipoRelat = "HTML" THEN DO:
        ASSIGN prmExcel     =  "wpgd0049a" + 
                               "?parametro1=" + get-value("parametro1") +  
                               "&parametro2=" + get-value("parametro2") +  
                               "&parametro3=" + get-value("parametro3") +
                               "&parametro4=" + get-value("parametro4") +
                               "&parametro5=" + get-value("parametro5") +
                               "&parametro6=" + get-value("parametro6") +
                               "&parametro7=" + get-value("parametro7") +
                               "&parametro8=" + get-value("parametro8") +
                               "&parametro9=" + get-value("parametro9") +
                               "&parametro10=" + get-value("parametro10") +
                               "&parametro11=EXCEL".           

        {&out} '<div align="right" id="botoes">' SKIP
               '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
               '      <tr>' SKIP
               '         <td align="right">' SKIP
               '            <img src="/cecred/images/botoes/btn_excel.gif" alt="Exportar para Excel" style="cursor: hand" onClick="window.open(~'' prmExcel '~',~'excel~',~'toolbar=no,location=no,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes,top=10,left=10,width=640,height=400~');">' SKIP
               '            <img src="/cecred/images/botoes/btn_fechar.gif" alt="Fechar esta janela" style="cursor: hand" onClick="top.close()">' SKIP
               '            <img src="/cecred/images/botoes/btn_imprimir.gif" alt="Imprimir" style="cursor: hand" onClick="document.all.botoes.style.visibility = ~'hidden~'; print(); document.all.botoes.style.visibility = ~'visible~';">' SKIP
               '         </td>' SKIP
               '      </tr>' SKIP
               '   </table>' SKIP
               '</div>' SKIP.
    END.

    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
           '      <tr>' SKIP
           '         <td class="tdprogra" colspan="5" align="right">wpgd0049a - ' TODAY '</td>' SKIP
           '   </table>' SKIP. 

    /* *** Logo *** */
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP.
    IF tipoRelat = "HTML" THEN
       {&out} '      <tr>' SKIP
              '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP
              '         <td class="tdTitulo1" colspan="3" align="center">PPR PARTICIPAÇÃO SOCIAL</td>' SKIP
              '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
              '      </tr>' SKIP.
    ELSE 
       {&out} '      <tr>' SKIP
              '         <td class="tdTitulo1" colspan="5" align="center">PPR PARTICIPAÇÃO SOCIAL</td>' SKIP
              '      </tr>' SKIP.
    {&out} '      <tr>' SKIP
           '         <td align="center" colspan="5"> &nbsp; </td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" colspan="5">' STRING(nrPeriodo) 'o Semestre de ' STRING(dtAnoAge,"9999") '</td>' SKIP
           '      </tr>' SKIP
           '      <tr>' SKIP
           '         <td align="center" colspan="5">'
           'PARÂMETROS <&nbsp;'
           'Integração: ' STRING(pctInteg,">9.99") '%&nbsp;-&nbsp;'
           'Kits: ' STRING(pctKits,">9.99") '%&nbsp;-&nbsp;'
           'Assembléia: ' STRING(pctAssembleia,">9.99") '%&nbsp;>'
           '</td>' SKIP
           '      </tr>' SKIP
           '   </table>' SKIP. 

    {&out} '<br>' SKIP.


    FIND FIRST tt-PPR NO-LOCK NO-ERROR.
    IF AVAILABLE tt-PPR
       THEN
           DO:
              relatorioPPR(). 
           END.

    IF msgsDeErro <> ""
       THEN
           {&out} '   <table border="0" cellspacing="1" cellpadding="1">' SKIP
                  '      <tr>' SKIP
                  '         <td>' msgsDeErro '</td>' SKIP
                  '      </tr>' SKIP
                  '   </table>' SKIP.

    {&out} '</div>' SKIP
           '</body>' SKIP
           '</html>' SKIP.

    RETURN TRUE.

END FUNCTION. /* montaTela RETURNS LOGICAL () */

/*****************************************************************************/
/*   Bloco de principal do programa                                          */
/*****************************************************************************/

ASSIGN cookieEmUso = GET-COOKIE("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + cookieEmUso + "*" NO-LOCK:
    LEAVE.
END.

RUN PermissaoDeAcesso("", OUTPUT IdentificacaoDaSessao, OUTPUT permiteExecutar).

IF permiteExecutar = "1" OR permiteExecutar = "2" THEN
   erroNaValidacaoDoLogin(permiteExecutar).
ELSE DO:
   ASSIGN idEvento                     = INTEGER(GET-VALUE("parametro1"))
          cdCooper                     = INTEGER(GET-VALUE("parametro2"))
          cdAgenci                     = INTEGER(GET-VALUE("parametro3"))
          dtAnoAge                     = INTEGER(GET-VALUE("parametro4"))
          nrPeriodo                    = INTEGER(GET-VALUE("parametro5"))
          pctInteg                     = DEC(GET-VALUE("parametro6"))
          pctKits                      = DEC(GET-VALUE("parametro7"))
          pctAssembleia                = DEC(GET-VALUE("parametro8")) 
          pctPpr1                      = DEC(GET-VALUE("parametro9")) 
          pctPpr2                      = DEC(GET-VALUE("parametro10")) 
          tipoRelat                    = GET-VALUE("parametro11")
          NO-ERROR.          

   IF tipoRelat = "HTML" THEN
      output-content-type("text/html").
   ELSE
      output-content-type("application/x-msexcel"). 

   /* *** Localiza os eventos que satisfazem ao filtro (apenas custos diretos) *** */
   IF nrPeriodo = 1 THEN 
      ASSIGN dtaIniPer = DATE(01,01,dtAnoAge)
             dtaFimPer = DATE(06,30,dtAnoAge)
             mesPeriodo = "01,02,03,04,05,06".
   ELSE 
      ASSIGN dtaIniPer = DATE(07,01,dtAnoAge)
             dtaFimPer = DATE(12,31,dtAnoAge)
             mesPeriodo = "07,08,09,10,11,12".
   IF cdAgenci = 0  THEN DO: /* Todos os PAC´s */
       FOR EACH crapage WHERE crapage.cdCooper = cdCooper NO-LOCK:
           RUN agrupaAgencias(crapage.cdagenci,
                              (IF AVAILABLE Crapage THEN trim(crapage.NmResAge) ELSE ("Agencia " + STRING(Cdagenci,"999"))),
                              OUTPUT descAgencia, OUTPUT grupAgencia).
           DO iAgencias = 1 TO NUM-ENTRIES(grupAgencia):
               FOR EACH Crapadp WHERE Crapadp.IdEvento = idEvento  AND
                                      Crapadp.CdCooper = cdCooper  AND
                                      crapadp.cdAgenci = int(entry(iAgencias,grupAgencia)) AND
                                      Crapadp.DtAnoAge = dtAnoAge  NO-LOCK
                                BREAK BY crapadp.idevento 
                                      BY crapadp.cdcooper
                                      BY crapadp.cdagenci:
                   RUN pi-criaPPR(crapage.cdagenci).
               END.
           END.
           RUN pi-criaSubTOTAL(crapage.cdagenci).
       END.
       RUN pi-criaTOTAL.
   END.
   ELSE DO:
       FIND Crapage WHERE Crapage.CdCooper = CdCooper AND Crapage.CdAgenci = CdAgenci NO-LOCK NO-ERROR.
       RUN agrupaAgencias(crapage.cdagenci,
                          (IF AVAILABLE Crapage THEN trim(crapage.NmResAge) ELSE ("Agencia " + STRING(Cdagenci,"999"))),
                          OUTPUT descAgencia, OUTPUT grupAgencia).

       DO iAgencias = 1 TO NUM-ENTRIES(grupAgencia):
          FOR EACH Crapadp WHERE Crapadp.IdEvento = idEvento      AND
                                 Crapadp.CdCooper = cdCooper      AND
                                 Crapadp.CdAgenci = int(entry(iAgencias,grupAgencia)) AND 
                                 Crapadp.DtAnoAge = dtAnoAge      NO-LOCK
                           BREAK BY crapadp.idevento 
                                 BY crapadp.cdcooper
                                 BY crapadp.cdagenci:
              RUN pi-criaPPR(cdAgenci).
          END.
       END.
       RUN pi-criaSubTOTAL(cdAgenci).
       RUN pi-criaTOTAL.
   END.
   FIND crapcop WHERE crapcop.cdcooper = cdCooper NO-LOCK NO-ERROR.

   IF AVAILABLE crapcop THEN
      DO:
          ASSIGN imagemDoProgrid      = "/cecred/images/geral/logo_cecred.gif"
                 nomedacooperativa    = TRIM(crapcop.nmrescop)
                 nomeDoRelatorio      = " - PPR PARTICIPACAO SOCIAL - " + STRING(nrPeriodo,"9") + "o SEMESTRE DE " + STRING(dtAnoAge,"9999").
         
          IF INDEX(crapcop.nmrescop, " ") <> 0  THEN
             DO: 
                aux_nmrescop = LC(TRIM(crapcop.nmrescop)).
                SUBSTRING( aux_nmrescop, (INDEX(aux_nmrescop, " ")),1) = "_".
                imagemDaCooperativa =  "/cecred/images/admin/logo_" +  aux_nmrescop.
             END.
          ELSE
             imagemDaCooperativa  = "/cecred/images/admin/logo_" + TRIM(LC(crapcop.nmrescop)) + ".gif" .
            
      END.
  
   montaTela(). 
END.
          
/*****************************************************************************/
/*                                                                           */
/*   Bloco de procdures                                                      */
/*                                                                           */
/*****************************************************************************/

PROCEDURE PermissaoDeAcesso :

    {includes/wpgd0009.i}

END PROCEDURE.

PROCEDURE agrupaAgencias:
    DEF INPUT PARAM pAgencia    AS INT NO-UNDO.
    DEF INPUT PARAM descEntrada AS CHAR NO-UNDO.
    DEF OUTPUT PARAM descSaida  AS CHAR NO-UNDO.
    DEF OUTPUT PARAM codAgencias AS CHAR NO-UNDO.

    /* Agrupa agencias */
    ASSIGN descSaida = descEntrada
           codAgencias = STRING(pAgencia). 
    IF CAN-FIND(FIRST crapadp WHERE crapadp.idevento = 1         AND
                                    crapadp.cdcooper = cdCooper  AND
                                    crapadp.dtanoage = dtAnoAge  AND 
                                    crapadp.cdagenci = pAgencia) THEN DO:
       FOR EACH crapadp WHERE crapadp.idevento = 1 AND
                crapadp.cdcooper = cdCooper        AND
                crapadp.dtanoage = dtAnoAge        AND 
                crapadp.cdagenci = pAgencia  NO-LOCK:
           IF CAN-FIND(FIRST crapagp WHERE crapagp.idevento  = crapadp.idevento AND
                                           crapagp.cdcooper  = crapadp.cdcooper  AND
                                           crapagp.dtanoage  = crapadp.dtanoage  AND
                                           crapagp.cdagenci <> crapagp.cdageagr  AND
                                           crapagp.cdageagr  = crapadp.cdagenci) THEN DO:
              FOR EACH crapagp WHERE crapagp.idevento  = crapadp.idevento  AND
                                     crapagp.cdcooper  = crapadp.cdcooper  AND
                                     crapagp.dtanoage  = crapadp.dtanoage  AND
                                     crapagp.cdagenci <> crapagp.cdageagr  AND
                                     crapagp.cdageagr  = crapadp.cdagenci  NO-LOCK:
                  FIND BFCrapage WHERE BFCrapage.cdcooper  = crapagp.cdcooper   AND
                                       BFCrapage.cdagenci  = crapagp.cdagenci   NO-LOCK NO-ERROR.
                  ASSIGN descSaida = descSaida + "~/" + BFCrapage.nmresage
                         codAgencias = codAgencias + "," + string(BFCrapage.cdagenci).
              END.
              LEAVE.
           END.
       END.
    END.
END.

PROCEDURE pi-criaPPR:
    DEF INPUT PARAM pAgencia AS INT NO-UNDO.

    DEF VAR mesEvento AS INT NO-UNDO.
    DEF VAR assumeResultado AS CHAR NO-UNDO.
    DEF VAR evtPeriodo AS CHAR NO-UNDO.        
    DEF VAR quantidades AS CHAR NO-UNDO.
        DEF VAR aux_dscEvento AS CHAR NO-UNDO.
        DEF VAR aux_dscPeriodo AS CHAR NO-UNDO.

    ASSIGN evtPeriodo = fn-eventoPeriodo(mesPeriodo)
           mesEvento = int(entry(1,evtPeriodo))
           assumeResultado = ENTRY(2,evtPeriodo).

    IF mesEvento <> 0 THEN DO:
       FIND tt-ppr WHERE tt-ppr.cdagenci = pAgencia
                     AND tt-ppr.data     = DATE(fn-dscPeriodo(mesEvento,2))
                   NO-ERROR.
       IF NOT AVAIL tt-ppr THEN DO:
           ASSIGN aux_dscEvento     = fn-dscEvento()
                  aux_dscPeriodo    = fn-dscPeriodo(mesEvento,2)
                  aux_dscPeriodo    = fn-dscPeriodo(mesEvento,1).
                  
           CREATE tt-ppr.
           ASSIGN tt-ppr.cdagenci   = pAgencia
                  tt-ppr.descEvento = aux_dscEvento
                  tt-ppr.data       = DATE(aux_dscPeriodo)
                  tt-ppr.periodo    = aux_dscPeriodo.
       END.
       ASSIGN quantidades       = fn-qtdEvento(1)
              tt-ppr.meta       = tt-ppr.meta + INT(ENTRY(1,quantidades))
              tt-ppr.resultado  = tt-ppr.resultado + (IF assumeResultado = "0" THEN 0 ELSE INT(ENTRY(2,quantidades)))
              tt-ppr.diferenca  = tt-ppr.resultado - tt-ppr.meta
              quantidades       = fn-qtdEvento(2)
              tt-ppr.rstInteg   = tt-ppr.rstInteg + INT(ENTRY(2,quantidades))
              quantidades       = fn-qtdEvento(3)
              tt-ppr.mtaCurso   = tt-ppr.mtaCurso + INT(ENTRY(1,quantidades))
              tt-ppr.rstCurso   = tt-ppr.rstCurso + INT(ENTRY(2,quantidades))
              quantidades       = fn-qtdEvento(4)
              tt-ppr.mtaEvento  = tt-ppr.mtaEvento + INT(ENTRY(1,quantidades))
              tt-ppr.rstEvento  = tt-ppr.rstEvento + INT(ENTRY(2,quantidades))
              quantidades       = fn-qtdEvento(5)
              tt-ppr.rstAssembl = tt-ppr.rstAssembl + INT(ENTRY(2,quantidades)).
    END.
END.

PROCEDURE pi-criaSubTOTAL:
    DEF INPUT PARAM pAgencia AS INT NO-UNDO.

    DEF VAR quantidades AS CHAR NO-UNDO.
    DEF VAR variavelAux AS DEC  NO-UNDO.
        DEF VAR aux_nvoAssoc AS INT NO-UNDO.
        DEF VAR aux_rstKits AS INT NO-UNDO.

    ASSIGN aux_nvoAssoc           = fn-nvoAssociado(1,pAgencia)
           aux_rstKits            = fn-qstDevolvidos(pAgencia)
           variavelAux            = (fn-nvoAssociado(2,pAgencia) * 
                                     pctAssembleia / 100).


    CREATE tt-subtotal.
    ASSIGN tt-subtotal.cdAgenci   = pAgencia
           tt-subtotal.nvoAssoc   = aux_nvoAssoc
           variavelAux            = (tt-subtotal.nvoAssoc * pctKits / 100)
           tt-subtotal.mtaKits    = (IF variavelAux <> TRUNC(variavelAux,0) 
                                    THEN (TRUNC(variavelAux,0) + 1) 
                                    ELSE variavelAux)
                   tt-subtotal.rstKits    = aux_rstKits
           variavelAux            = (tt-subtotal.nvoAssoc * pctInteg / 100)
           tt-subtotal.mtaInteg   = tt-subtotal.nvoAssoc
           tt-subtotal.rstInteg   = (IF variavelAux <> TRUNC(variavelAux,0) 
                                    THEN (TRUNC(variavelAux,0) + 1) 
                                    ELSE variavelAux)
           tt-subtotal.mtaAssembl = (IF variavelAux <> TRUNC(variavelAux,0) 
                                     THEN (TRUNC(variavelAux,0) + 1) 
                                     ELSE variavelAux).

    FOR EACH tt-ppr WHERE tt-ppr.cdagenci = pAgencia:
        ASSIGN tt-subtotal.mtaCurso   = tt-subtotal.mtaCurso   + tt-ppr.mtaCurso
               tt-subtotal.rstCurso   = tt-subtotal.rstCurso   + tt-ppr.rstCurso
               tt-subtotal.mtaEvento  = tt-subtotal.mtaEvento  + tt-ppr.mtaEvento
               tt-subtotal.rstEvento  = tt-subtotal.rstEvento  + tt-ppr.rstEvento
               tt-subtotal.rstAssembl = tt-subtotal.rstAssembl + tt-ppr.rstAssembl.
    END.
    ASSIGN tt-subtotal.difKits    = tt-subtotal.rstKits    - tt-subtotal.mtaKits   
           tt-subtotal.difAssembl = tt-subtotal.rstAssembl - tt-subtotal.mtaAssembl
           tt-subtotal.difInteg   = tt-subtotal.rstInteg   - tt-subtotal.mtaInteg  
           tt-subtotal.difCurso   = tt-subtotal.rstCurso   - tt-subtotal.mtaCurso  
           tt-subtotal.difEvento  = tt-subtotal.rstEvento  - tt-subtotal.mtaEvento. 

END.

PROCEDURE pi-criaTOTAL:
    CREATE tt-TOTAL.
    FOR EACH tt-subtotal:
        ASSIGN tt-total.mtaKits    = tt-total.mtaKits    + tt-subtotal.mtaKits   
               tt-total.rstKits    = tt-total.rstKits    + tt-subtotal.rstKits   
               tt-total.difKits    = tt-total.difKits    + tt-subtotal.difKits   
               tt-total.mtaAssembl = tt-total.mtaAssembl + tt-subtotal.mtaAssembl
               tt-total.rstAssembl = tt-total.rstAssembl + tt-subtotal.rstAssembl
               tt-total.difAssembl = tt-total.difAssembl + tt-subtotal.difAssembl
               tt-total.mtaInteg   = tt-total.mtaInteg   + tt-subtotal.mtaInteg  
               tt-total.rstInteg   = tt-total.rstInteg   + tt-subtotal.rstInteg  
               tt-total.difInteg   = tt-total.difInteg   + tt-subtotal.difInteg  
               tt-total.mtaCurso   = tt-total.mtaCurso   + tt-subtotal.mtaCurso  
               tt-total.rstCurso   = tt-total.rstCurso   + tt-subtotal.rstCurso  
               tt-total.difCurso   = tt-total.difCurso   + tt-subtotal.difCurso  
               tt-total.mtaEvento  = tt-total.mtaEvento  + tt-subtotal.mtaEvento 
               tt-total.rstEvento  = tt-total.rstEvento  + tt-subtotal.rstEvento 
               tt-total.difEvento  = tt-total.difEvento  + tt-subtotal.difEvento.
   END.
END.
