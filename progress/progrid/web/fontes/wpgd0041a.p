/*
Programa wpgd0041a.p - Ficha de Avaliação (chamado a partir dos dados de wpgd0041)

Alterações: 28/01/2008 - Efetuado acerto na contagem de Participantes (Diego).

            01/02/2008 - Ordenar leitura pelo campo crapgap.nrordgru (Diego).

            03/11/2008 - Incluido o widget-pool (Martin).

            10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

            05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
            busca na gnapses de CONTAINS para MATCHES
            (Guilherme Maba).

            09/07/2012 - Tratamento do campo dsobserv para banco Oracle
            (Lucas R.).

            05/09/2012 - Retirado tratamento do campo dsobserv (Tiago).

            28/11/2012 - Substituir tabela "gncoper" por "crapcop"
            (David Kruger).

            04/04/2013 - Alteração para receber logo na alto vale,
            recebendo nome de viacrediav e buscando com
            o respectivo nome (David Kruger).

            04/09/2013 - Nova forma de chamar as agências, de PAC agora
            a escrita será PA (André Euzébio - Supero).

            17/06/2015 - Melhorias OQS (Gabriel-RKAM).

            11/08/2015 - Ordenaçao da craptem pela descriçao do tema (Vanessa).

            26/08/2015 - Ajustes de homologaçao (Vanessa).

            21/06/2016 - Inclusao de Tipo de Relatorio, Prj. 229 RF 05
            (Jean Michel).

            30/08/2016 - Correçao para exibiçao do tipo de evento. (Jean Michel).

            09/09/2016 - Incluida a opcao de geração de todos relatórios
            quando o tipo for "TABULADA", Prj. 229. (Jean Michel).

******************************************************************************/

create widget-pool.

/*****************************************************************************/
/*   Bloco de variaveis                                                      */
/*****************************************************************************/

DEFINE VARIABLE cookieEmUso                  AS CHARACTER.
DEFINE VARIABLE permiteExecutar              AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao        AS CHARACTER.
DEFINE VARIABLE msgsDeErro                   AS CHARACTER.

DEFINE VARIABLE aux_idEvento                 AS INTEGER.
DEFINE VARIABLE aux_cdCooper                 AS INTEGER.
DEFINE VARIABLE aux_cdAgenci                 AS INTEGER.
DEFINE VARIABLE aux_dtAnoAge                 AS INTEGER.
DEFINE VARIABLE aux_nrseqdig                 AS INTEGER.
DEFINE VARIABLE aux_cdevento                 AS INTEGER.
DEFINE VARIABLE aux_nmfacili                 AS CHARACTER.
DEFINE VARIABLE aux_dslocali                 AS CHARACTER.
DEFINE VARIABLE tipoDeRelatorio              AS INTEGER.
DEFINE VARIABLE nomeDoRelatorio              AS CHARACTER.
DEFINE VARIABLE aux_nmresage                 AS CHARACTER.
DEFINE VARIABLE aux_dtinieve                 AS CHARACTER  FORMAT "x(10)".
DEFINE VARIABLE aux_tldatelaTAB                 AS CHARACTER  EXTENT 3
INIT ["Avaliação do Evento",
  "Avaliação do PA",
    "Avaliação do Fornecedor"].
      
DEFINE VARIABLE aux_tldatela                 AS CHARACTER  EXTENT 2
INIT ["Avaliação do Evento",
  "Avaliação Tabulada"].
        
DEFINE VARIABLE aux_tprelsel                 AS CHARACTER  EXTENT 3
INIT ["Cooperado",
"Cooperativa",
"Fornecedor"].

DEFINE VARIABLE vetormes     AS CHAR EXTENT 12
INITIAL ["Janeiro","Fevereiro","Março","Abril","Maio","Junho",
"Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].


DEFINE VARIABLE imagemDoProgrid              AS CHARACTER.
DEFINE VARIABLE imagemDaCooperativa          AS CHARACTER.
DEFINE VARIABLE nomeDaCooperativa            AS CHARACTER.
DEFINE VARIABLE aux_nmrescop                 AS CHARACTER.

DEFINE BUFFER crabrap FOR craprap.

/* Controles do desenho da ficha de avaliação */
DEFINE VARIABLE aux_nrdoitem  AS INTEGER   INIT 0   NO-UNDO.
DEFINE VARIABLE aux_nrtopico  AS INTEGER   INIT 0   NO-UNDO.
DEFINE VARIABLE aux_nrromano  AS CHARACTER          NO-UNDO.
DEFINE VARIABLE aux_flgexist  AS LOGICAL   INIT NO  NO-UNDO.
DEFINE VARIABLE aux_flgsuges  AS LOGICAL   INIT NO NO-UNDO.
DEFINE VARIABLE aux_cont_tema AS INTEGER.
DEFINE VARIABLE aux_tema_tab  AS INTEGER.
DEFINE VARIABLE aux_flgtabela AS LOGICAL   INIT FALSE NO-UNDO.
DEFINE VARIABLE aux_tprelato  AS INTEGER              NO-UNDO.

DEFINE VARIABLE aux_nmtipeve AS CHARACTER NO-UNDO.
DEFINE VARIABLE aux_contador AS INTEGER NO-UNDO INIT 0.
DEFINE VARIABLE aux_todosrel AS LOGICAL NO-UNDO INIT FALSE.
DEFINE VARIABLE aux_conttema AS INTEGER NO-UNDO INIT 0.
        
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
        
FUNCTION EmBranco RETURNS LOGICAL ():
  
  ASSIGN aux_nrdoitem = 0
  aux_nrtopico = 0
  aux_flgexist = NO
  aux_nrromano = "I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII,XIII,XIV,XV,XVI,XVII,XVIII,XIX,XX".
  
  /* Respostas das avaliações */
  FOR EACH  craprap WHERE craprap.idevento = aux_idevento   AND
    craprap.cdcooper = aux_cdcooper   AND
    craprap.cdagenci = aux_cdagenci   AND
    craprap.dtanoage = aux_dtanoage   AND
    craprap.nrseqeve = aux_nrseqdig   NO-LOCK,
    
    /* Grupo de avaliações */
    FIRST crapgap WHERE crapgap.idevento = craprap.idevento   AND
    crapgap.cdcooper = 0                  AND
    crapgap.cdgruava = craprap.cdgruava   AND
    crapgap.tprelgru = aux_tprelato NO-LOCK,
    
    /* Item de avaliações */
    FIRST crapiap WHERE crapiap.idevento = craprap.idevento   AND
    crapiap.cdcooper = 0                  AND
    crapiap.cdgruava = craprap.cdgruava   AND
    crapiap.cditeava = craprap.cditeava   NO-LOCK
    BREAK BY craprap.dtanoage
    BY crapgap.tpiteava /*NOVO*/
    BY crapgap.nrordgru /*NOVO*/
    BY craprap.cdgruava:
    ASSIGN aux_flgexist = YES.
    
    /* Item Alternativo */
    IF   crapgap.tpiteava = 1   THEN
    DO:
      IF   FIRST-OF(craprap.cdgruava)   THEN
      DO:
        aux_nrdoitem = aux_nrdoitem + 1.
        
        {&out} '<br>'                                                                            SKIP
        '<table class="tab2" border="1" borderColor="#000000" width="100%">'              SKIP
        '  <tr>'                                                                          SKIP
        '    <td>'                                                                        SKIP
        '      &nbsp;&nbsp;' ENTRY(aux_nrdoitem,aux_nrromano) " - " crapgap.dsgruava      SKIP
        '    </td>'                                                                       SKIP
        '    <td align="center" width="60">'                                              SKIP
        '      Ótimo<br>'                                                                 SKIP
        '      <img src="/cecred/images/geral/otimo.jpg">'                                SKIP
        '    </td>'                                                                       SKIP
        '    <td align="center" width="60">'                                              SKIP
        '      Bom<br>'                                                                   SKIP
        '      <img src="/cecred/images/geral/bom.jpg">'                                  SKIP
        '    </td>'                                                                       SKIP
        '    <td align="center" width="60">'                                              SKIP
        '      Regular<br>'                                                               SKIP
        '      <img src="/cecred/images/geral/regular.jpg">'                              SKIP
        '    </td>'                                                                       SKIP
        '    <td align="center" width="60">'                                              SKIP
        '      Insuficiente<br>'                                                          SKIP
        '      <img src="/cecred/images/geral/insuficiente.jpg">'                         SKIP
        '    </td>'                                                                       SKIP
        '  </tr>'                                                                         SKIP.
        
        aux_nrtopico = 0.
      END.
      
      aux_nrtopico = aux_nrtopico + 1.
      
      {&out} '  <tr height="30">'                                                             SKIP
      '    <td  class="tab2">'                                                         SKIP
      '      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' aux_nrtopico ") " crapiap.dsiteava  SKIP
      '    </td>'                                                                      SKIP
      '    <td class="tab2">'                                                          SKIP
      '      &nbsp;'                                                                   SKIP
      '    </td>'                                                                      SKIP
      '    <td class="tab2">'                                                          SKIP
      '      &nbsp;'                                                                   SKIP
      '    </td>'                                                                      SKIP
      '    <td class="tab2">'                                                          SKIP
      '      &nbsp;'                                                                   SKIP
      '    </td>'                                                                      SKIP
      '    <td class="tab2">'                                                          SKIP
      '      &nbsp;'                                                                   SKIP
      '    </td>'                                                                      SKIP
      '  </tr>'                                                                        SKIP.
      
      IF LAST-OF(craprap.cdgruava)   THEN
      {&out} '</table>'  SKIP
      '<br>'      SKIP.
    END.
    ELSE /* Item Descritivo */
    DO:
      
      IF FIRST-OF(craprap.cdgruava)   THEN
      {&out} '<table width="100%">'    SKIP
      '  <tr>'                  SKIP
      '    <td>'                SKIP
      crapgap.dsgruava   SKIP
      '    </td>'               SKIP
      '  </tr>'                 SKIP.
      
      {&out} '  <tr>'                       SKIP
      '    <td class="tab2">'        SKIP
      '      &nbsp;'                 SKIP
      '    </td>'                    SKIP
      '  </tr>'                      SKIP
      '  <tr>'                       SKIP
      '    <td class="tab2">'        SKIP
      '      <li>' crapiap.dsiteava  SKIP
      '    </td>'                    SKIP
      '  </tr>'                      SKIP
      '  <tr>'                       SKIP
      '    <td class="tab2">'        SKIP
      '      <hr>'                   SKIP
      '    </td>'                    SKIP
      '  </tr>'                      SKIP
      '  <tr>'                       SKIP
      '    <td class="tab2">'        SKIP
      '      <hr>'                   SKIP
      '    </td>'                    SKIP
      '  </tr>'                      SKIP
      '  <tr>'                       SKIP
      '    <td class="tab2">'        SKIP
      '      <hr>'                   SKIP
      '    </td>'                    SKIP
      '  </tr>'                      SKIP
      '  <tr>'                       SKIP
      '    <td class="tab2">'        SKIP
      '      <hr>'                   SKIP
      '    </td>'                    SKIP
      '  </tr>'                      SKIP.
      
      IF LAST-OF(craprap.cdgruava) THEN
      {&out} '</table>'  SKIP
      '<br>'      SKIP.
      
      IF LAST-OF(craprap.dtanoage) THEN
      ASSIGN aux_flgsuges = TRUE.
      
      ASSIGN aux_cont_tema = 0.
      
      FOR EACH craptem WHERE craptem.idrelava = "S"
        AND craptem.idsittem = "A"
        AND craptem.idrespub = "N" NO-LOCK
        BREAK BY craptem.dstemeix
        BY craptem.cdeixtem:
        ASSIGN aux_cont_tema = aux_cont_tema + 1.
      END.
      
      ASSIGN aux_tema_tab  = aux_cont_tema / 2
      aux_cont_tema = 0.
      
      IF aux_flgsuges THEN
      DO:
        /* Imprimir as sugestoes */
        
        IF aux_tprelato = 1 THEN
        DO:
          FOR EACH craptem WHERE craptem.idrelava = "S" AND craptem.idsittem = "A" AND craptem.idrespub = "N" NO-LOCK
            BREAK BY craptem.dstemeix
            BY craptem.cdeixtem:
            
            IF FIRST(craptem.cdeixtem)   THEN
            DO:
              ASSIGN aux_flgsuges = FALSE.
              
              {&out} '<table width="100%">'
              ' <tr>'
              '    <td style="width:60px;">'
              '          Sugestões'
              '    </td>'
              '    <td class="tab2">'
              '      - Assinale abaixo os Temas que'
              '        sejam do seu interesse:'
                '    </td>'
                ' </tr>'
                '</table>'
                '<tr><table width="50%" style="float:left;">'.
              END.
              
              IF aux_cont_tema < aux_tema_tab THEN
              DO:
                
                {&out} '<tr>'
                '   <td style="width:25px; font-size: 25px;">'
                '       &#10065;'
                '   </td>'
                '   <td class="tab2">'
                craptem.dstemeix
                '   </td>'
                '</tr>'.
                ASSIGN aux_cont_tema = aux_cont_tema + 1
                aux_flgtabela = TRUE.
              END.
              ELSE
              DO:
                IF aux_flgtabela THEN
                DO:
                  {&out} '</tr></table><table width="50%"  style="float:right;"><tr>'.
                  ASSIGN aux_flgtabela = FALSE.
                  
                END.
                
                {&out} '   <td style="width:25px; font-size: 25px;">'
                '       &#10065;'
                '   </td>'
                '   <td class="tab2">'
                craptem.dstemeix
                '   </td>'
                '</tr>'.
              END.
              
              IF LAST (craptem.cdeixtem)   THEN
              {&out} '</tr></table></table>'.
              
            END. /* FOR EACH craptem */
            
          END. /*aux_tprelato = 1*/
          
        END. /* aux_flgsuges */
        
      END. /* ELSE */
    END.
    
    IF NOT aux_flgexist   THEN
    ASSIGN msgsDeErro = msgsDeErro + "-> Não há Tópicos e/ou Itens a serem avaliados.<br>".
    
    RETURN TRUE.
  END.
          
FUNCTION PercentualDoItem RETURNS CHAR (INPUT par_cdgruava AS INTEGER,  /* Grupo da avaliação */
  INPUT par_cditeava AS INTEGER,  /* Item da avaliação */
  INPUT par_vldoitem AS INTEGER): /* Valor do item a ser contado 1-Ótimo, 2-Bom, 3-Regular, 4-Insuficiente e 5-Não Respondidos */
  
  DEFINE VARIABLE aux_qtdoitem AS INTEGER  INIT 0           NO-UNDO.  /* Total de respostas do item */
  DEFINE VARIABLE aux_ttavalia AS INTEGER  INIT 0           NO-UNDO.  /* Total de respostas do evento */
  
  FOR EACH crabrap WHERE crabrap.idevento = aux_idevento                        AND
    crabrap.cdcooper = aux_cdcooper                        AND
    (crabrap.cdagenci = aux_cdagenci                        OR
    aux_cdagenci     = 0) /*TODOS*/                        AND
    crabrap.dtanoage = aux_dtanoage                        AND
    (crabrap.nrseqeve = aux_nrseqdig                        OR
    (aux_nrseqdig = 0 AND crabrap.cdevento = aux_cdEvento)) AND
    crabrap.cdgruava = par_cdgruava                        AND
    crabrap.cditeava = par_cditeava                        NO-LOCK:
    
    /* Total de respostas do evento */
    aux_ttavalia = aux_ttavalia + crabrap.qtavares.
    
    /* Ótimo */
    IF   par_vldoitem = 1   THEN
    aux_qtdoitem = aux_qtdoitem + crabrap.qtavaoti.
    ELSE
    /* Bom */
    IF   par_vldoitem = 2   THEN
    aux_qtdoitem = aux_qtdoitem + crabrap.qtavabom.
    ELSE
    /* Regular */
    IF   par_vldoitem = 3   THEN
    aux_qtdoitem = aux_qtdoitem + crabrap.qtavareg.
    ELSE
    /* Insuficiente */
    IF   par_vldoitem = 4   THEN
    aux_qtdoitem = aux_qtdoitem + crabrap.qtavains.
    ELSE
    /* Não Respondidos */
    IF   par_vldoitem = 5   THEN
    aux_qtdoitem = aux_qtdoitem + (crabrap.qtavares - (crabrap.qtavaoti +
    crabrap.qtavabom +
    crabrap.qtavareg +
    crabrap.qtavains)).
  END.
  
  IF   (aux_qtdoitem * 100) / aux_ttavalia <> ?   AND
  (aux_qtdoitem * 100) / aux_ttavalia >  0   THEN
  RETURN STRING((aux_qtdoitem * 100) / aux_ttavalia,"zz9.99") + "%".
  ELSE
  RETURN "".
END.          
          
FUNCTION Tabulada RETURNS LOGICAL ():
  
  DEFINE VARIABLE aux_cdageant AS INTEGER         NO-UNDO.
  DEFINE VARIABLE aux_nrseqant AS INTEGER         NO-UNDO.
  DEFINE VARIABLE aux_contador AS INTEGER         NO-UNDO.
  
  DEFINE VARIABLE flg_cdgruava AS LOGICAL         NO-UNDO.
  DEFINE VARIABLE flg_cditeava AS LOGICAL         NO-UNDO.
  
  DEFINE VARIABLE tot_qtpartic AS INTEGER EXTENT 7 NO-UNDO.
  DEFINE VARIABLE tot_qtavares AS INTEGER         NO-UNDO.
  DEFINE VARIABLE tot_qtsugeve AS INTEGER         NO-UNDO.
  
  ASSIGN aux_nrdoitem = 0
  aux_nrtopico = 0
  aux_flgexist = NO
  aux_nrromano = "I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII,XIII,XIV,XV,XVI,XVII,XVIII,XIX,XX".
  
  /* Respostas das avaliações - Alternativas */
  FOR EACH  craprap WHERE craprap.idevento = aux_idEvento      AND
    craprap.cdcooper = aux_cdCooper      AND
    (craprap.cdagenci = aux_cdAgenci      OR
    aux_cdagenci     = 0) /*TODOS*/      AND
    craprap.dtanoage = aux_dtAnoAge      AND
    (craprap.nrseqeve = aux_nrseqdig      OR
    (aux_nrseqdig = 0 AND craprap.cdevento = aux_cdEvento)) NO-LOCK,
    
    /* Grupo de avaliações */
    FIRST crapgap WHERE crapgap.idevento = craprap.idevento         AND
    crapgap.cdcooper = 0                        AND
    crapgap.cdgruava = craprap.cdgruava         AND
    crapgap.tpiteava = 1 /* Item Alternativo */ AND
    crapgap.tprelgru = aux_tprelato NO-LOCK,
    
    /* Item de avaliações */
    FIRST crapiap WHERE crapiap.idevento = craprap.idevento   AND
    crapiap.cdcooper = 0                  AND
    crapiap.cdgruava = craprap.cdgruava   AND
    crapiap.cditeava = craprap.cditeava   NO-LOCK
    BREAK BY crapgap.nrordgru
    BY craprap.nrseqeve
    BY crapgap.tpiteava
    BY craprap.cdagenci
    BY craprap.cdgruava
    BY craprap.cditeava:
    
    ASSIGN aux_conttema = aux_conttema + 1.
    
    /* controle para mostrar os ítens somente uma vez (quando são todos os PA) */
    IF   aux_cdageant = 0   THEN
    aux_cdageant = craprap.cdagenci.
    
    IF   aux_cdageant <> craprap.cdagenci   THEN
    LEAVE.    
    
    /* controle para mostrar os ítens somente uma vez (quando são varios eventos no PA) */
    IF   aux_nrseqant = 0   THEN
    aux_nrseqant = craprap.nrseqeve.
    
    IF   aux_nrseqant <> craprap.nrseqeve   THEN
    LEAVE.
    
    aux_flgexist = YES.
    
    IF   FIRST-OF(craprap.cdgruava)   THEN
    DO:
      aux_nrdoitem = aux_nrdoitem + 1.
      
      {&out} '<br>'                                                                        SKIP
      '<table class="tab2" border="1" borderColor="#000000" width="100%">'          SKIP
      '  <tr>'                                                                      SKIP
      '    <td>'                                                                    SKIP
      '      &nbsp;&nbsp;' ENTRY(aux_nrdoitem,aux_nrromano) " - " crapgap.dsgruava  SKIP
      '    </td>'                                                                   SKIP
      '    <td align="center" width="65">'                                          SKIP
      '      Ótimo<br>'                                                             SKIP
      '      <img src="/cecred/images/geral/otimo.jpg">'                            SKIP
      '    </td>'                                                                   SKIP
      '    <td align="center" width="65">'                                          SKIP
      '      Bom<br>'                                                               SKIP
      '      <img src="/cecred/images/geral/bom.jpg">'                              SKIP
      '    </td>'                                                                   SKIP
      '    <td align="center" width="65">'                                          SKIP
      '      Regular<br>'                                                           SKIP
      '      <img src="/cecred/images/geral/regular.jpg">'                          SKIP
      '    </td>'                                                                   SKIP
      '    <td align="center" width="65">'                                          SKIP
      '      Insuficiente<br>'                                                      SKIP
      '      <img src="/cecred/images/geral/insuficiente.jpg">'                     SKIP
      '    </td>'                                                                   SKIP
      '    <td align="center" width="65">'                                          SKIP
      '      Não<br>Respondidos'                                                    SKIP
      '    </td>'                                                                   SKIP
      '  </tr>'                                                                     SKIP.
      
      aux_nrtopico = 0.
    END.
    
    aux_nrtopico = aux_nrtopico + 1.
    
    {&out} '  <tr height="30">'                                                                   SKIP
    '    <td  class="tab2">'                                                               SKIP
    '      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' aux_nrtopico ") " crapiap.dsiteava        SKIP
    '    </td>'                                                                            SKIP
    '    <td class="tab2" align="center">'                                                 SKIP
    PercentualDoItem(craprap.cdgruava,craprap.cditeava,1)
    '    </td>'                                                                            SKIP
    '    <td class="tab2" align="center">'                                                 SKIP
    PercentualDoItem(craprap.cdgruava,craprap.cditeava,2)
    '    </td>'                                                                            SKIP
    '    <td class="tab2" align="center">'                                                 SKIP
    PercentualDoItem(craprap.cdgruava,craprap.cditeava,3)
    '    </td>'                                                                            SKIP
    '    <td class="tab2" align="center">'                                                 SKIP
    PercentualDoItem(craprap.cdgruava,craprap.cditeava,4)
    '    </td>'                                                                            SKIP
    '    <td class="tab2" align="center">'                                                 SKIP
    PercentualDoItem(craprap.cdgruava,craprap.cditeava,5)
    '    </td>'                                                                            SKIP
    '  </tr>'                                                                              SKIP.
    
    IF   LAST-OF(craprap.cdgruava)   THEN
    {&out} '</table>' SKIP.
  END.
  
  /* Total de participantes e de avaliações respondidas */
  /* O comando abaixo foi comentado, pq nos casos de palestra que não existem alternativas,
  somente descritivas, o relatório não estava mostrando nada.
  IF   aux_flgexist   THEN
  DO:    */
  /* Total de participantes */
  FOR EACH crapidp WHERE crapidp.idevento = aux_idevento  AND
    crapidp.cdcooper = aux_cdcooper  AND
    crapidp.dtanoage = aux_dtanoage  AND
    (crapidp.cdagenci = aux_cdAgenci  OR
    aux_cdagenci     = 0) /*TODOS*/  AND
    (crapidp.nrseqeve = aux_nrseqdig  OR
    (aux_nrseqdig = 0 AND crapidp.cdevento = aux_cdEvento))
    NO-LOCK:
    
    IF   Crapidp.IdStaIns > 0 AND Crapidp.IdStaIns < 6  THEN
    ASSIGN tot_qtpartic[Crapidp.IdStaIns] = tot_qtpartic[Crapidp.IdStaIns] + 1.
    
    /* *** Nome e dados extras do evento *** */
    FIND FIRST Crapedp WHERE Crapedp.IdEvento = Crapidp.IdEvento  AND
    Crapedp.CdCooper = Crapidp.CdCooper  AND
    Crapedp.DtAnoAge = Crapidp.DtAnoAge  AND
    Crapedp.CdEvento = Crapidp.CdEvento
    NO-LOCK NO-ERROR.
    
    /* *** Se inscricao cofirmada e inscricoes encerradas e evento NAO CANCELADO, verifica faltas ****/
    IF   Crapidp.IdStaIns = 2  AND Crapidp.QtFalEve > 0  AND Crapadp.idstaeve <> 2 /*Cancelado*/  THEN
    DO:
      IF   ((crapidp.qtfaleve * 100) / Crapadp.QtDiaEve) > (100 - crapedp.prfreque)  THEN
      ASSIGN tot_qtpartic[6] = tot_qtpartic[6] + 1.
    END.
    
  END.
  
  /* Se o evento já ocorreu e NAO FOI CANCELADO, conta os que COMPARECERAM */
  IF   crapadp.dtfineve  < TODAY   AND
  crapadp.idstaeve  <> 2  THEN
  ASSIGN tot_qtpartic[7] = tot_qtpartic[2] - tot_qtpartic[6].
  
  ASSIGN tot_qtavares = 0.
  
  /* Total de avaliações respondidas */
  FOR EACH  craprap WHERE craprap.idevento = aux_idEvento
    AND craprap.cdcooper = aux_cdcooper
    AND (craprap.cdagenci = aux_cdagenci
    OR aux_cdagenci = 0)
    AND craprap.dtanoage = aux_dtanoage
    AND craprap.nrseqeve = aux_nrseqdig  NO-LOCK,
    
    /* Grupo de avaliações */
    FIRST crapgap WHERE crapgap.idevento = craprap.idevento
    AND crapgap.cdcooper = 0
    AND crapgap.cdgruava = craprap.cdgruava
    AND crapgap.tprelgru = aux_tprelato
    AND crapgap.tpiteava = 1 NO-LOCK
    BREAK BY crapgap.tprelgru:
    
    IF FIRST-OF(crapgap.tprelgru) THEN
    DO:
      ASSIGN tot_qtavares = craprap.qtavares.
      LEAVE.
    END.
  END.
  
  {&OUT} '<table class="tab2" border="1" borderColor="#000000" width="100%">'   SKIP
  '  <tr>'                                                               SKIP
  '    <td class="tdCab3">'                                              SKIP
  '      &nbsp;' tot_qtpartic[7] FORMAT "z,zz9" ' PARTICIPANTES - ' tot_qtavares FORMAT "z,zz9" ' AVALIAÇÕES RESPONDIDAS'  SKIP
  '    </td>'                                                            SKIP
  '  </tr>'                                                              SKIP
  '</table>'                                                             SKIP
  '<br>'                                                                 SKIP.
  
  /* Respostas das avaliações - Descritivas */
  FOR EACH  craprap WHERE craprap.idevento = aux_idEvento      AND
    craprap.cdcooper = aux_cdCooper      AND
    (craprap.cdagenci = aux_cdAgenci      OR
    aux_cdagenci     = 0) /*TODOS*/      AND
    craprap.dtanoage = aux_dtAnoAge      AND
    (craprap.nrseqeve = aux_nrseqdig      OR
    (aux_nrseqdig = 0 AND craprap.cdevento = aux_cdEvento)) NO-LOCK,
    
    /* Grupo de avaliações */
    FIRST crapgap WHERE crapgap.idevento = craprap.idevento         AND
    crapgap.cdcooper = 0                        AND
    crapgap.cdgruava = craprap.cdgruava         AND
    crapgap.tpiteava = 2 /* Item Descritivo */  AND
    crapgap.tprelgru = aux_tprelato NO-LOCK,
    
    /* Item de avaliações */
    FIRST crapiap WHERE crapiap.idevento = craprap.idevento   AND
    crapiap.cdcooper = 0                  AND
    crapiap.cdgruava = craprap.cdgruava   AND
    crapiap.cditeava = craprap.cditeava   NO-LOCK
    BREAK BY crapgap.nrordgru
    BY craprap.cdgruava
    BY craprap.cditeava
    BY craprap.cdagenci
    BY craprap.nrseqeve:
    
    IF   FIRST-OF(craprap.cdgruava)   THEN
    flg_cdgruava = YES.
    
    IF   FIRST-OF(craprap.cditeava)   THEN
    flg_cditeava = YES.
    
    IF   craprap.dsobserv <> ""   THEN
    DO:
      IF   flg_cdgruava   THEN
      DO:
        {&out} '<table cellspacing="0" cellpadding="0" width="100%">'    SKIP
        '  <tr>'                  SKIP
        '    <td>'                SKIP
        crapgap.dsgruava   SKIP
        '    </td>'               SKIP
        '  </tr>'                 SKIP.
        
        flg_cdgruava = NO.
      END.
      
      IF   flg_cditeava   THEN
      DO:
        {&out} '  <tr>'                              SKIP
        '    <td class="tab3">'               SKIP
        '      &nbsp;'                        SKIP
        '    </td>'                           SKIP
        '  </tr>'                             SKIP
        '  <tr>'                              SKIP
        '    <td class="tab3">'               SKIP
        '      <li>' crapiap.dsiteava         SKIP
        '    </td>'                           SKIP
        '  </tr>'                             SKIP
        '  <tr>'                              SKIP
        '    <td class="tab3">'               SKIP
        '      &nbsp;'                        SKIP
        '    </td>'                           SKIP
        '  </tr>'                             SKIP.
        
        flg_cditeava = NO.
      END.
      
      {&out} '  <tr>'                              SKIP
      '    <td class="tab3">'               SKIP
      '      &nbsp;&nbsp;&nbsp;&nbsp;'      SKIP.
      
      DO aux_contador = 1 TO LENGTH(craprap.dsobserv):
        
        /* Controle de quebra de linha */
        IF   KEY-CODE(SUBSTRING(craprap.dsobserv,aux_contador,1)) = 10   THEN
        {&out} '<br>'                     SKIP
        '&nbsp;&nbsp;&nbsp;&nbsp;' SKIP.
        ELSE
        {&out} SUBSTRING(craprap.dsobserv,aux_contador,1).
      END.
      
      {&out} '    </td>' SKIP
      '  </tr>'   SKIP.
    END.
    
    IF   LAST-OF(craprap.cdgruava)   THEN
    {&out} '</table>'  SKIP
    '<br>'      SKIP.
  END.
  
  IF NOT aux_todosrel OR (aux_todosrel AND aux_tprelato = 1) THEN
    DO:
      ASSIGN aux_flgexist = NO.
      
      /* Sugestões Analisadas Modelo Antigo*/
      {&out} '<div id="div_analisadas_eve_' + STRING(aux_conttema) + '" name="div_analisadas_' + STRING(aux_conttema) + '">' SKIP
      '<table cellspacing="0" cellpadding="0" width="100%">' SKIP
      '  <tr>'                                               SKIP
      '    <td colspan="2">'                                 SKIP
      '      SUGESTÕES ANALISADAS - EVENTOS'                 SKIP
      '    </td>'                                            SKIP
      '  </tr>'                                              SKIP
      '  <tr>'                                               SKIP
      '    <td colspan="2">'                                 SKIP
      '      &nbsp;'                                         SKIP
      '    </td>'                                            SKIP
      '  </tr>'                                              SKIP
      '  <tr>' SKIP
      '    <td width="15">' SKIP
      '     &nbsp;' SKIP
      '    </td>' SKIP
      '    <td>' SKIP
      '      <table class="tab2" border="1" borderColor="#000000" width="300">' SKIP
      '        <tr>' SKIP
      '          <td class="tdCab3">' SKIP
      '            &nbsp;EVENTO' SKIP
      '          </td>' SKIP
      '          <td class="tdCab3" align="center">' SKIP
      '            QTD' SKIP
      '          </td>' SKIP
      '        </tr>'  SKIP.
      
      /* Respostas das avaliações - para pegar todos os nrseqdig envolvidos */
      FOR EACH  craprap WHERE craprap.idevento = aux_idEvento      AND
        craprap.cdcooper = aux_cdCooper      AND
        (craprap.cdagenci = aux_cdAgenci      OR
        aux_cdagenci     = 0) /*TODOS*/      AND
        craprap.dtanoage = aux_dtAnoAge      AND
        (craprap.nrseqeve = aux_nrseqdig      OR
        (aux_nrseqdig = 0 AND craprap.cdevento = aux_cdEvento)) NO-LOCK
        BREAK BY craprap.nrseqeve:
        
        IF   NOT FIRST-OF(craprap.nrseqeve)   THEN
        NEXT.
        
        /* Sugestões de origem 7 onde a sugestão era analisada por evento (modelo antigo)*/
        FOR EACH crapsdp  WHERE crapsdp.idevento = craprap.idevento          AND
          crapsdp.cdcooper = craprap.cdcooper          AND
          crapsdp.cdagenci = craprap.cdagenci          AND
          crapsdp.nrmsgint = craprap.nrseqeve          AND
          crapsdp.cdevento <> ?                        AND
          crapsdp.cdevento <> 0                        AND
          (crapsdp.nrseqtem = ? or crapsdp.nrseqtem = 0) AND /*Adicionado Márcio*/
          crapsdp.cdorisug = 7  /*Avaliação evento*/   AND
          crapsdp.flgsugca <> YES                  NO-LOCK,
          
          /* Busca o nome do EVENTO que a sugestão foi associada */
          FIRST crapedp WHERE crapedp.idevento = craprap.idevento   AND
          crapedp.cdcooper = 0                  AND
          crapedp.dtanoage = 0                  AND
          crapedp.cdevento = crapsdp.cdevento   NO-LOCK
          
          BREAK BY crapedp.nmevento:
          
          IF   FIRST-OF(crapedp.nmevento)   THEN
          tot_qtsugeve = 0.
          
          tot_qtsugeve =  tot_qtsugeve + crapsdp.qtsugeve.
          
          IF   LAST-OF(crapedp.nmevento)    THEN
          DO:
            {&out} '  <tr>'                                  SKIP
            '    <td class="tab2">'                   SKIP
            '      &nbsp;' crapedp.nmevento             SKIP
            '    </td>' SKIP
            '    <td class="tab2" align="center">' SKIP
            tot_qtsugeve SKIP
            '    </td>' SKIP
            '  </tr>' SKIP.
            
            ASSIGN aux_flgexist = YES.

          END.
        END.
        
      END.
      
      {&out} '      </table>' SKIP
      '    </td>'      SKIP
      '  </tr>'        SKIP
      '</table>'       SKIP
      '<br>'           SKIP
      '<br>'           SKIP
      '</div>'         SKIP.
    END.
    
  /* Se não houveram sugestões, esconde a div */
  IF NOT aux_flgexist THEN
  DO:
    {&out} '<script language="JavaScript">' SKIP
    'document.getElementById("div_analisadas_eve_' + STRING(aux_conttema) + '").style.display = "none";' SKIP
    '</script>' SKIP.
    ASSIGN aux_conttema = aux_conttema + 1.
  END.
  
  ASSIGN tot_qtsugeve = 0
         aux_flgexist = NO.
  
  IF NOT aux_todosrel OR (aux_todosrel AND aux_tprelato = 1) THEN
  DO:
    /* Início Alteracao Márcio*/
    /* Sugestões Analisadas Modelo Antigo*/
    {&out} '<div id="div_analisadas_tema_' + STRING(aux_conttema) + '" name="div_analisadas_' + STRING(aux_conttema) + '">'                              SKIP
    '<table cellspacing="0" cellpadding="0" width="100%">'    SKIP
    '  <tr>'                                                  SKIP
    '    <td colspan="2">'                                                SKIP
    '      SUGESTÕES ANALISADAS - TEMAS'                              SKIP
    '    </td>'                                               SKIP
    '  </tr>'                                                 SKIP
    '  <tr>'                                                  SKIP
    '    <td colspan="2">'                                                SKIP
    '      &nbsp;'                                            SKIP
    '    </td>'                                               SKIP
    '  </tr>'                                                 SKIP
    '  <tr>' SKIP
    '    <td width="15">' SKIP
    '     &nbsp;' SKIP
    '    </td>' SKIP
    '    <td>' SKIP
    '      <table class="tab2" border="1" borderColor="#000000" width="300">' SKIP
    '        <tr>' SKIP
    '          <td class="tdCab3">' SKIP
    '            &nbsp;TEMA' SKIP
    '          </td>' SKIP
    '          <td class="tdCab3" align="center">' SKIP
    '            QTD' SKIP
    '          </td>' SKIP
    '        </tr>'  SKIP.
    
    /* Respostas das avaliações - para pegar todos os nrseqdig envolvidos */
    FOR EACH  craprap WHERE craprap.idevento = aux_idEvento      AND
      craprap.cdcooper = aux_cdCooper      AND
      (craprap.cdagenci = aux_cdAgenci      OR
      aux_cdagenci     = 0) /*TODOS*/      AND
      craprap.dtanoage = aux_dtAnoAge      AND
      (craprap.nrseqeve = aux_nrseqdig      OR
      (aux_nrseqdig = 0 AND craprap.cdevento = aux_cdEvento)) NO-LOCK
      BREAK BY craprap.nrseqeve:
      
      IF   NOT FIRST-OF(craprap.nrseqeve)   THEN
      NEXT.
      
      /* Sugestões de origem 7 ou 8 onde a sugestão é analisada por tema (modelo novo)*/
      FOR EACH crapsdp  WHERE crapsdp.idevento = craprap.idevento          AND
        crapsdp.cdcooper = craprap.cdcooper          AND
        crapsdp.cdagenci = craprap.cdagenci          AND
        crapsdp.nrmsgint = craprap.nrseqeve          AND
        (crapsdp.nrseqtem <> ? and crapsdp.nrseqtem <> 0) AND
        (crapsdp.cdorisug = 7 or crapsdp.cdorisug = 8) /*Avaliação evento*/   AND
        crapsdp.flgsugca <> YES                  NO-LOCK,
        
        /* Busca o nome do TEMA que a sugestão foi associada */
        FIRST craptem WHERE craptem.idevento = craprap.idevento   AND
        craptem.cdcooper = 0                  AND
        craptem.nrseqtem = crapsdp.nrseqtem   NO-LOCK
        
        BREAK BY craptem.dstemeix:
        
        IF   FIRST-OF(craptem.dstemeix)   THEN
        tot_qtsugeve = 0.
        
        tot_qtsugeve =  tot_qtsugeve + crapsdp.qtsugeve.
        
        IF   LAST-OF(craptem.dstemeix)    THEN
        DO:
          {&out} '  <tr>'                                  SKIP
          '    <td class="tab2">'                   SKIP
          '      &nbsp;' craptem.dstemeix             SKIP
          '    </td>' SKIP
          '    <td class="tab2" align="center">' SKIP
          tot_qtsugeve SKIP
          '    </td>' SKIP
          '  </tr>' SKIP.
          
          ASSIGN aux_flgexist = YES.
        END.
      END.
      
    END.
    
    {&out} '      </table>' SKIP
    '    </td>'      SKIP
    '  </tr>'        SKIP
    '</table>'       SKIP
    '<br>'           SKIP
    '<br>'           SKIP
    '</div>'         SKIP.
  END.
    
  /* Se não houveram sugestões, esconde a div */
  IF NOT aux_flgexist THEN
  DO:
    {&out} '<script language="JavaScript">' SKIP
    'document.getElementById("div_analisadas_tema_' + STRING(aux_conttema) + '").style.display = "none";' SKIP
    '</script>' SKIP.
    ASSIGN aux_conttema = aux_conttema + 1.
  END.
  
  ASSIGN aux_flgexist = NO.
  
  /* Fim Alteracao Márcio*/
  
  IF NOT aux_todosrel OR (aux_todosrel AND aux_tprelato = 1) THEN
  DO:
    /* Sugestões Não Analisadas */
    {&out} '<div id="div_nao_analisadas_' + STRING(aux_conttema) + '" name="div_nao_analisadas_' + STRING(aux_conttema) + '">' SKIP
    '<table cellspacing="0" cellpadding="0" width="100%">'    SKIP
    '  <tr>'                                                  SKIP
    '    <td>'                                                SKIP
    '      SUGESTÕES NÃO ANALISADAS'                          SKIP
    '    </td>'                                               SKIP
    '  </tr>'                                                 SKIP
    '  <tr>'                                                  SKIP
    '    <td>'                                                SKIP
    '      &nbsp;'                                            SKIP
    '    </td>'                                               SKIP
    '  </tr>'                                                 SKIP.
    
    /* Respostas das avaliações - para pegar todos os nrseqdig envolvidos */
    FOR EACH  craprap WHERE craprap.idevento = aux_idEvento      AND
      craprap.cdcooper = aux_cdCooper      AND
      (craprap.cdagenci = aux_cdAgenci      OR
      aux_cdagenci     = 0) /*TODOS*/      AND
      craprap.dtanoage = aux_dtAnoAge      AND
      (craprap.nrseqeve = aux_nrseqdig      OR
      (aux_nrseqdig = 0 AND craprap.cdevento = aux_cdEvento)) NO-LOCK
      BREAK BY craprap.nrseqeve:
      
      IF   NOT FIRST-OF(craprap.nrseqeve)   THEN
      NEXT.
      
      /* Sugestões */
      FOR EACH crapsdp WHERE crapsdp.idevento = craprap.idevento          AND
        crapsdp.cdcooper = craprap.cdcooper          AND
        crapsdp.cdagenci = craprap.cdagenci          AND
        crapsdp.nrmsgint = craprap.nrseqeve          AND
        ((crapsdp.cdevento = ?  OR
        crapsdp.cdevento = 0) AND
        (crapsdp.nrseqtem = ?  OR
        crapsdp.nrseqtem = 0)
        )                      AND
        crapsdp.cdorisug = 7  /*Avaliação evento*/   AND
        crapsdp.flgsugca <> YES                  NO-LOCK:
        
        ASSIGN aux_flgexist = YES.
        
        {&out} '  <tr>'                                  SKIP
        '    <td class="tab2">'                   SKIP
        '      <li style="margin-left:15px;">'      SKIP.
        
        DO aux_contador = 1 TO LENGTH(crapsdp.dssugeve):
          
          /* Controle de quebra de linha */
          IF   KEY-CODE(SUBSTRING(crapsdp.dssugeve,aux_contador,1)) = 10   THEN
          {&out} '<br>'                     SKIP
          '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' SKIP.
          ELSE
          {&out} SUBSTRING(crapsdp.dssugeve,aux_contador,1).
        END.
        
        {&out} '&nbsp;&nbsp;(Qtd: ' crapsdp.qtsugeve ')' SKIP
        '    </td>'                   SKIP
        '  </tr>'                     SKIP.
      END.
      
    END.
    
    {&out} '</table>'  SKIP
    '<br>'      SKIP
    '</div>'    SKIP.
  END.
    
  /* Se não houveram sugestões, esconde a div */
  IF NOT aux_flgexist THEN
  DO:
    {&out} '<script language="JavaScript">' SKIP
    'document.getElementById("div_nao_analisadas_' + STRING(aux_conttema) + '").style.display = "none";' SKIP
    '</script>' SKIP.
    ASSIGN aux_conttema = aux_conttema + 1.
  END.
  
  ASSIGN aux_flgexist = NO.
         
  RETURN TRUE.
END.
          
FUNCTION cabecalho RETURNS LOGICAL ():
  
  {&out} '<html>' SKIP
  '<head>' SKIP
  '<title>Progrid - Avaliação Tabulada</title>' SKIP.
  
  {&out} '<style>' SKIP
  '   body         ~{ background-color: #FFFFFF; }' SKIP
  '   td           ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
  '   .tdCab1      ~{ background-color: #B1B1B1; font-family: Arial, Helvetica, sans-serif; font-size: 14px; font-weight: bold; }' SKIP
  '   .tdCab2      ~{ background-color: #C6C6C6; font-family: Arial, Helvetica, sans-serif; font-size: 12px; font-weight: bold; }' SKIP
  '   .tdCab3      ~{ background-color: #DBDBDB; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
  '   .tdLabel     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: bold; }' SKIP
  '   .tdDados     ~{ font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: normal; border-bottom: #000000 0px solid }' SKIP
  '   .tdTitulo1   ~{ font-family: Verdana; font-size: 24px; font-weight: normal;}' SKIP
  '   .tdTitulo2   ~{ font-family: Verdana; font-size: 16px; font-weight: bold;}' SKIP
  '   .tdTitulo3   ~{ font-family: Arial; font-size: 11px; font-weight: normal;}' SKIP
  '   .tab1        ~{ border-collapse:collapse; border-top: #000000 1px solid; border-bottom: #000000 1px solid; border-right: #000000 1px solid; border-left: #000000 1px solid; }' SKIP
  '   .tab2        ~{ border-collapse:collapse; font-weight: normal; }' SKIP
  '   .tab3        ~{ border-collapse:collapse; font-weight: normal;font-size: 13px; }' SKIP
  '</style>' SKIP.
  
  {&out} '</head>' SKIP
  '<body bgcolor="#FFFFFF" topmargin="0" marginwidth="0" marginheight="0">' SKIP
  '<div align="center">' SKIP.
  
  RETURN TRUE.
  
END FUNCTION.
          
FUNCTION cabecalhoLogo RETURNS LOGICAL ():
  
  IF NOT aux_todosrel OR (aux_todosrel AND aux_tprelato = 2) THEN
  DO:
    /* *** Botoes de fechar e imprimir *** */
    {&out} '<div align="right" id="botoes">' SKIP
    '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
    '      <tr>' SKIP
    '         <td align="right">' SKIP
    '            <img src="/cecred/images/botoes/btn_fechar.gif" alt="Fechar esta janela" style="cursor: hand" onClick="top.close()">' SKIP
    '            <img src="/cecred/images/botoes/btn_imprimir.gif" alt="Imprimir" style="cursor: hand" onClick="alert(~'ATENÇÃO! Certifique-se que a página esteja como papel A4.~'); document.all.botoes.style.visibility = ~'hidden~'; print(); document.all.botoes.style.visibility = ~'visible~';">' SKIP
    '         </td>' SKIP
    '      </tr>' SKIP
    '   </table>' SKIP
    '</div>' SKIP.
    
    {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%">' SKIP
    '      <tr>' SKIP
    '         <td class="tdprogra" colspan="5" align="right">wpgd0041a - ' TODAY '</td>' SKIP
    '      </tr>' SKIP
    '   </table>' SKIP.
  END.
  
  /* *** Logo *** */
  {&out} '   <table border="0" cellspacing="0" cellpadding="0" width="100%" class="tab1">' SKIP
  '      <tr>' SKIP
  '         <td align="center"><img src="' imagemDoProgrid '" border="0"></td>' SKIP.
  
  {&out} '         <td class="tdTitulo1" colspan="4" align="center">' nomeDaCooperativa ' - ' aux_tldatelaTAB[aux_tprelato] ' - ' aux_dtAnoAge '</td>' SKIP.
  
  {&out} '         <td align="center"><img src="' imagemDaCooperativa '" border="0"></td>' SKIP
  '      </tr>' SKIP
  '      <tr>' SKIP
  '        <td colspan="6">&nbsp;</td>' SKIP
  '      </tr>' SKIP
  '      <tr>' SKIP.
  
  IF craptab.dstextab = "" THEN
  ASSIGN aux_nmtipeve = "EVENTO".
  ELSE
  IF NUM-ENTRIES(craptab.dstextab) >= 2 THEN
  DO:
    ASSIGN aux_nmtipeve = "EVENTO".
    DO aux_contador = 2 TO NUM-ENTRIES(craptab.dstextab) BY 2:
      IF INTEGER(ENTRY(aux_contador,craptab.dstextab)) = crapedp.tpevento THEN
      ASSIGN aux_nmtipeve = ENTRY(aux_contador - 1,craptab.dstextab).
    END.
  END.
  ELSE
  ASSIGN aux_nmtipeve = "EVENTO".            
  
  {&out} '         <td align="center" class="tdTitulo2" colspan="6">' UPPER(aux_nmtipeve) ': ' crapedp.nmevento '</td>' SKIP
  '      </tr>' SKIP
  '      <tr>' SKIP
  '        <td colspan="6">&nbsp;</td>' SKIP
  '      </tr>' SKIP
  '      <tr>' SKIP
  '         <td align="left" class="tdTitulo3" colspan="4">&nbsp;&nbsp;PA: ' aux_nmresage '</td>' SKIP
  '         <td align="right" class="tdTitulo3" colspan="2">DATA: ' aux_dtinieve '&nbsp;&nbsp;</td>' SKIP
  '      </tr>' SKIP
  '      <tr>' SKIP
  '         <td align="left" class="tdTitulo3" colspan="6">&nbsp;&nbsp;' aux_nmfacili '</td>' SKIP
  '      </tr>' SKIP
  '      <tr>' SKIP
  '         <td align="left" class="tdTitulo3" colspan="6">&nbsp;&nbsp;' aux_dslocali '</td>' SKIP
  '      </tr>' SKIP.
  
  {&out} '<tr>' SKIP
  '   <td align="left" class="tdTitulo3" colspan="6">&nbsp;&nbsp;TIPO DE RELATÓRIO: &nbsp;&nbsp;' aux_tprelsel[aux_tprelato] '</td>' SKIP
  '</tr>' SKIP.
              
  {&out} '   </table>' SKIP.
  
  IF aux_todosrel AND aux_tprelato <> 3 THEN
  {&out} '<br style="page-break-after: always">' SKIP.
  
  RETURN TRUE.
  
END FUNCTION. /* cabecalho RETURNS LOGICAL () */
          
FUNCTION relatorio RETURNS LOGICAL ():
  
  CASE tipoDeRelatorio:
    WHEN 1 THEN
      EmBranco().
    WHEN 2 THEN
      Tabulada().
    OTHERWISE
      msgsDeErro = msgsDeErro + "-> Tipo de relatório ainda não implementado.<br>".
  END CASE.
  
  IF   msgsDeErro <> ""   THEN
  {&out} '   <table border="0" cellspacing="1" cellpadding="1">' SKIP
  '      <tr>' SKIP
  '         <td>' msgsDeErro '</td>' SKIP
  '      </tr>' SKIP
  '   </table>' SKIP.
    
  RETURN TRUE.
  
END FUNCTION.
          
FUNCTION rodape RETURNS LOGICAL ():
  
  {&out}    '</div>' SKIP
  '</body>' SKIP
  '</html>' SKIP.
  
  RETURN TRUE.
  
END FUNCTION.
          
/*****************************************************************************/
/*   Bloco de principal do programa                                          */
/*****************************************************************************/

output-content-type("text/html").

ASSIGN cookieEmUso = GET-COOKIE("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + cookieEmUso + "*" NO-LOCK:
  LEAVE.
END.

RUN PermissaoDeAcesso("", OUTPUT IdentificacaoDaSessao, OUTPUT permiteExecutar).

IF permiteExecutar = "1" OR permiteExecutar = "2"
THEN
erroNaValidacaoDoLogin(permiteExecutar).
ELSE
DO:
  ASSIGN aux_idEvento    = INTEGER(GET-VALUE("parametro1"))
  aux_cdCooper    = INTEGER(GET-VALUE("parametro2"))
  aux_cdAgenci    = INTEGER(GET-VALUE("parametro3"))
  aux_dtAnoAge    = INTEGER(GET-VALUE("parametro4"))
  aux_nrseqdig    = INTEGER(GET-VALUE("parametro5"))
  tipoDeRelatorio = INTEGER(GET-VALUE("parametro6"))
  aux_cdevento    = INTEGER(GET-VALUE("parametro7"))
  aux_tprelato    = INTEGER(GET-VALUE("parametro8"))NO-ERROR.
  
  FIND crapcop WHERE crapcop.cdcooper = aux_cdCooper NO-LOCK NO-ERROR.
  
  IF AVAILABLE crapcop   THEN
  DO:
    ASSIGN imagemDoProgrid      = "/cecred/images/geral/logo_cecred.gif"
    nomeDaCooperativa    = TRIM(crapcop.nmrescop).
    
    IF INDEX(crapcop.nmrescop, " ") <> 0  THEN
    DO:
      aux_nmrescop = LC(TRIM(crapcop.nmrescop)).
      SUBSTRING( aux_nmrescop, (INDEX(aux_nmrescop, " ")),1) = "_".
      imagemDaCooperativa =  "/cecred/images/admin/logo_" +  aux_nmrescop.
    END.
    ELSE
    imagemDaCooperativa  = "/cecred/images/admin/logo_" + TRIM(LC(crapcop.nmrescop)) + ".gif" .
    
  END.
  
  FIND FIRST crapadp WHERE crapadp.idevento = aux_idevento   AND
  crapadp.cdcooper = aux_cdcooper   AND
  (crapadp.nrseqdig = aux_nrseqdig   OR
  aux_nrseqdig = 0 AND crapadp.cdevento = aux_cdevento)
  NO-LOCK NO-ERROR.
  
  IF   aux_cdagenci = 0   THEN
  ASSIGN aux_nmresage = "TODOS OS PA'S"
  aux_dtinieve = "TODAS AS OCORRÊNCIAS".
  ELSE
  DO:
    IF   aux_nrseqdig = 0   THEN
    aux_dtinieve = "TODAS AS OCORRÊNCIAS".
    ELSE
    DO:
      IF   crapadp.dtinieve = ?   THEN
      aux_dtinieve = vetormes[crapadp.nrmeseve].
      ELSE
      aux_dtinieve = STRING(crapadp.dtinieve,"99/99/9999").
    END.
    
    
    /* Busca o PA */
    FIND crapage WHERE crapage.cdcooper = crapadp.cdcooper   AND
    crapage.cdagenci = aux_cdagenci   NO-LOCK NO-ERROR.
    
    aux_nmresage = crapage.nmresage.
    
    /* se for PROGRID, verifica se há PA's agrupados */
    IF   crapadp.idevento = 1    THEN
    FOR EACH crapagp WHERE crapagp.cdcooper  = crapadp.cdcooper  AND
      crapagp.dtanoage  = crapadp.dtanoage  AND
      crapagp.cdagenci <> crapagp.cdageagr  AND
      crapagp.cdageagr  = aux_cdagenci      NO-LOCK:
      
      FIND crapage WHERE crapage.cdcooper = crapagp.cdcooper   AND
      crapage.cdagenci = crapagp.cdagenci   NO-LOCK NO-ERROR.
      
      ASSIGN aux_nmresage = aux_nmresage + " ~/ " + crapage.nmresage.
    END.
  END.
  
  /* Busca o nome do EVENTO */
  FIND crapedp WHERE crapedp.idevento = crapadp.idevento   AND
  crapedp.cdcooper = crapadp.cdcooper   AND
  crapedp.dtanoage = crapadp.dtanoage   AND
  crapedp.cdevento = crapadp.cdevento   NO-LOCK NO-ERROR.
  
  /* Busca o Tipo do Evento */
  FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
  craptab.nmsistem = "CRED"          AND
  craptab.tptabela = "CONFIG"        AND
  craptab.cdempres = 0               AND
  craptab.cdacesso = "PGTPEVENTO"    AND
  craptab.tpregist = 0               NO-LOCK NO-ERROR.
  
  ASSIGN aux_nmfacili = ""
  aux_dslocali = "".
  
  IF   aux_cdagenci <> 0   AND
  aux_nrseqdig <> 0   THEN
  DO:
    /* custo do evento */
    FIND crapcdp WHERE crapcdp.idevento  = crapadp.idevento    AND
    crapcdp.cdcooper  = crapadp.cdcooper    AND
    crapcdp.cdagenci  = crapadp.cdagenci    AND
    crapcdp.dtanoage  = crapadp.dtanoAge    AND
    crapcdp.tpcuseve  = 1 /* direto */      AND
    crapcdp.cdevento  = crapadp.cdevento    AND
    crapcdp.cdcuseve  = 1 /* honorários */  NO-LOCK NO-ERROR.
    
    IF   AVAILABLE crapcdp   THEN
    DO:
      /* proposta do evento */
      FIND gnappdp WHERE gnappdp.idevento = crapcdp.idevento   AND
      gnappdp.cdcooper = 0                  AND
      gnappdp.nrcpfcgc = crapcdp.nrcpfcgc   AND
      gnappdp.nrpropos = crapcdp.nrpropos   NO-LOCK NO-ERROR.
      
      IF   AVAILABLE gnappdp   THEN
      DO:
        /* Localiza e trata facilitador */
        FOR EACH gnfacep WHERE gnfacep.idevento = gnappdp.idevento   AND
          gnfacep.cdcooper = 0                  AND
          gnfacep.nrcpfcgc = Gnappdp.nrcpfcgc   AND
          gnfacep.nrpropos = Gnappdp.nrpropos   NO-LOCK:
          
          FIND gnapfep WHERE gnapfep.idevento = gnfacep.idevento   AND
          gnapfep.cdcooper = 0                  AND
          gnapfep.nrcpfcgc = gnfacep.nrcpfcgc   AND
          gnapfep.cdfacili = gnfacep.cdfacili   NO-LOCK NO-ERROR.
          
          IF   AVAILABLE gnapfep   THEN
          aux_nmfacili = aux_nmfacili + gnapfep.nmfacili + ", ".
        END.
        
        /* tira a ultima "," */
        aux_nmfacili = SUBSTRING(aux_nmfacili,1,LENGTH(aux_nmfacili) - 2).
        aux_nmfacili = "FACILITADOR(ES): " + aux_nmfacili.
      END.
    END.
    
    /* Local do evento */
    FIND crapldp WHERE crapldp.idevento = crapadp.idevento   AND
    crapldp.cdcooper = crapadp.cdcooper   AND
    crapldp.cdagenci = crapadp.cdagenci   AND
    crapldp.nrseqdig = crapadp.cdlocali   NO-LOCK NO-ERROR.
    
    IF   AVAILABLE crapldp   THEN
    aux_dslocali = "LOCAL: " + crapldp.dslocali.
  END.
  
  IF NOT aux_tprelato = 4 THEN
  DO:
    cabecalho().
    cabecalhoLogo().
    relatorio().
    rodape().
  END.
  ELSE
  DO:
    ASSIGN aux_tprelato = 2
    aux_todosrel = TRUE.
    DO WHILE TRUE:
      
      IF aux_tprelato = 2 THEN
      cabecalho().
      
      cabecalhoLogo().
      relatorio().
      
      IF aux_tprelato = 1 THEN
      DO:
        rodape().
        LEAVE.
      END.
      
      ASSIGN aux_tprelato = aux_tprelato + 1.
      
      IF aux_tprelato = 4 THEN
      ASSIGN aux_tprelato = 1.
      
    END.
  END. /* FIM ELSE */
END.
          
PROCEDURE PermissaoDeAcesso:
  {includes/wpgd0009.i}
END PROCEDURE.