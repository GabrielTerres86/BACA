/* .............................................................................

   Programa: wcrm0002_xml.p
Sistema : Conta-Corrente - Cooperativa de Credito
Sigla   : CRED
Autor   : Evandro
   Data    : Maio/2006                   Ultima Atualizacao: 05/10/2015

Dados referentes ao programa:

Frequencia: Diario (internet)
   Objetivo  : Gerar arquivo XML para a tela wcrm0002

   Alteracoes: 26/09/2007 - Substituida informação da craptab(LOCALIDADE) pela 
                            crapage (Diego).

               04/11/2008 - Inclusao do widget-pool (Martin).

               24/11/2011 - Ajuste no ano da agenda (David).

               23/07/2014 - Alterar descricao PAC para Posto de Atendimento, 
                            nas mensagens emitidas ao usuário.
                            (Chamado 162280) - (Fabricio
                            
		05/10/2015 - Incluida verificacao de qtmaxtur na crapeap antes
								 da atribuicao da crapedp Projeto 229 (Jean Michel).

..............................................................................*/

CREATE WIDGET-POOL.

DEFINE VARIABLE par_cdcooper AS INTEGER                               NO-UNDO.
DEFINE VARIABLE par_cdevento AS INTEGER                               NO-UNDO.
DEFINE VARIABLE par_cdageagr AS INTEGER                               NO-UNDO.
DEFINE VARIABLE par_nrmeseve AS INTEGER                               NO-UNDO.

DEFINE VARIABLE aux_dsmeseve AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dsstaeve AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dscritic AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_flgexist AS LOGICAL         INIT FALSE            NO-UNDO.
DEFINE VARIABLE aux_tppartic AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_nmcidade AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_tpevento AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dtanoage LIKE gnpapgd.dtanoage                    NO-UNDO.
DEFINE VARIABLE aux_cdagenci LIKE crapagp.cdagenci                    NO-UNDO.
DEFINE VARIABLE aux_qtmaxtur AS INTEGER                               NO-UNDO.

/* Variaveis de controle do XML */
DEFINE VARIABLE xDoc         AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot        AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot2       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xField       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xText        AS HANDLE                                NO-UNDO.

DEFINE BUFFER crabedp FOR crapedp.

DEF VAR vetormes     AS CHAR EXTENT 12
INITIAL ["JANEIRO","FEVEREIRO","MARÇO","ABRIL","MAIO","JUNHO",
"JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"].


/* Cria um campo com seu valor no XML */
FUNCTION criaCampo RETURNS LOGICAL
  (INPUT nomeCampo  AS CHAR,
  INPUT textoCampo AS CHAR):

  xDoc:CREATE-NODE(xField,CAPS(nomeCampo),"ELEMENT").
    xRoot2:APPEND-CHILD(xField).
  xDoc:CREATE-NODE(xText,"","TEXT").
  xField:APPEND-CHILD(xText).
  xText:NODE-VALUE = STRING(textoCampo).

  RETURN TRUE.

END FUNCTION.

/* Include para usar os comandos para WEB */
{src/web2/wrap-cgi.i}

/* Configura a saída como XML */
OUTPUT-CONTENT-TYPE ("text/xml":U).

ASSIGN par_cdcooper = INT(GET-VALUE("aux_cdcooper"))
par_cdevento = INT(GET-VALUE("aux_cdevento"))
       par_cdageagr = INT(GET-VALUE("aux_cdagenci"))
       par_nrmeseve = INT(GET-VALUE("aux_nrmeseve")).


CREATE X-DOCUMENT xDoc.
CREATE X-NODEREF  xRoot.
CREATE X-NODEREF  xRoot2.
CREATE X-NODEREF  xField.
CREATE X-NODEREF  xText.

  /* Cria a raiz principal */
xDoc:CREATE-NODE( xRoot, "CECRED", "ELEMENT" ).
  xDoc:APPEND-CHILD( xRoot ).

/*define temporaria para permitir ordenação das colunas*/
DEFINE TEMP-TABLE tt-crapadp NO-UNDO
     FIELD dsmeseve AS   CHARACTER 
     FIELD nmevento LIKE crapedp.nmevento
     FIELD cdevento LIKE crapadp.cdevento
     FIELD nrmeseve LIKE crapadp.nrmeseve
     FIELD nrseqdig LIKE crapadp.nrseqdig
     FIELD nmresage LIKE crapage.nmresage 
     FIELD cdagenci LIKE crapagp.cdagenci 
     FIELD dtanoage LIKE gnpapgd.dtanoage 
     FIELD cdpartic LIKE crapedp.tppartic
     FIELD flgcompr LIKE crapedp.flgcompr
     FIELD qtmaxtur LIKE crapedp.qtmaxtur
     FIELD prfreque LIKE crapedp.prfreque
     FIELD dtinieve LIKE crapadp.dtinieve
     FIELD dtfineve LIKE crapadp.dtfineve
     FIELD dspartic AS   CHARACTER 
     FIELD dsstaeve AS   CHARACTER
     FIELD dsevento AS   CHARACTER
     FIELD nmcidade AS   CHARACTER.

EMPTY TEMP-TABLE tt-crapadp.

/* A agenda mostrada será sempre a do ano vigente */
ASSIGN aux_dtanoage = YEAR(TODAY).

FOR EACH crapagp WHERE crapagp.idevento = 1 /*Progrid*/ AND  
                       crapagp.cdcooper = par_cdcooper  AND
                       crapagp.dtanoage = aux_dtanoage  AND  
                      (crapagp.cdagenci = par_cdageagr  OR 
                       par_cdageagr = 0              )  NO-LOCK,
   FIRST crapage WHERE crapage.cdcooper = crapagp.cdcooper AND
                       crapage.cdagenci = crapagp.cdagenci NO-LOCK:
                     
  
   ASSIGN par_cdageagr = crapagp.cdageagr
          aux_cdagenci = crapagp.cdagenci
          aux_nmcidade = crapage.nmcidade
          aux_qtmaxtur = 1.
                  
   /* Eventos agendados */
   FOR EACH crapadp WHERE crapadp.idevento = 1 /*Progrid*/   AND   
                          crapadp.dtanoage = aux_dtanoage    AND
                          crapadp.cdcooper = par_cdcooper    AND 
                          crapadp.dtlibint <= TODAY          AND
                          crapadp.dtretint >= TODAY          AND   
                         (crapadp.cdagenci = par_cdageagr    OR
                           par_cdageagr     = 0) /*Todos*/   AND 
                         (crapadp.cdevento = par_cdevento    OR
                           par_cdevento     = 0) /*Todos*/   AND 
                         (crapadp.nrmeseve = par_nrmeseve    OR
                           par_nrmeseve     = 0) /*Todos*/   NO-LOCK:
                     
  /* Nome do evento */
  FIND crapedp WHERE crapedp.idevento = crapadp.idevento   AND
  crapedp.cdcooper = crapadp.cdcooper   AND
  crapedp.dtanoage = crapadp.dtanoage   AND
  crapedp.cdevento = crapadp.cdevento   NO-LOCK NO-ERROR.
  
       
  IF   crapedp.tpevento = 1 OR   /*curso*/
  crapedp.tpevento = 3 OR   /*gincana*/
  crapedp.tpevento = 4 OR   /*palestra*/
  crapedp.tpevento = 5 THEN /*teatro*/
  DO:
    /* Tipo de evento curso, palestar .... */
    FIND FIRST craptab WHERE craptab.cdcooper = 0              AND
    craptab.nmsistem = "CRED"         AND
    craptab.tptabela = "CONFIG"       AND
    craptab.cdempres = 0              AND
    craptab.cdacesso = "PGTPEVENTO"   AND
    craptab.tpregist = 0              NO-LOCK NO-ERROR.
    IF AVAILABLE craptab THEN
                   ASSIGN aux_tpevento = ENTRY(LOOKUP(STRING(crapedp.tpevento), craptab.dstextab) - 1, craptab.dstextab).
    ELSE
                   ASSIGN aux_tpevento = "".
  END.
  ELSE
            ASSIGN aux_tpevento = "Evento".

       /* Participacao */
       FIND FIRST craptab WHERE craptab.cdcooper = 0              AND
                                craptab.nmsistem = "CRED"         AND
                                craptab.tptabela = "CONFIG"       AND
                                craptab.cdempres = 0              AND
                                craptab.cdacesso = "PGTPPARTIC"   AND
                                craptab.tpregist = 0              NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE crapedp   OR
            NOT AVAILABLE crapage   OR
            NOT AVAILABLE craptab   THEN
            NEXT.

       /* Situacao das inscricoes */
       IF   crapadp.idstaeve = 2 /*cancelado*/ OR   
            crapadp.idstaeve = 4 /*encerrado*/ OR   
            crapadp.idstaeve = 5 /*realizado*/ THEN
            aux_dsstaeve = "ENCERRADAS".
       ELSE
       IF   crapadp.idstaeve = 1 /*agendado*/    OR   
            crapadp.idstaeve = 3 /*transferido*/ OR   
            crapadp.idstaeve = 6 /*acrescido*/   THEN
            aux_dsstaeve = "ABERTAS".
       ELSE 
            aux_dsstaeve = "".
  
  /* Mes do evento */
  IF   crapadp.dtinieve = ?   THEN
  aux_dsmeseve = vetormes[crapadp.nrmeseve].
  ELSE
  DO:
    IF   crapadp.dtinieve <> crapadp.dtfineve   THEN
                      aux_dsmeseve = /*string(crapadp.dtinieve) + 
                                     " a " +
                                     STRING(crapadp.dtfineve).*/
                      STRING(DAY(crapadp.dtinieve),"99") + "/" +
                                     STRING(MONTH(crapadp.dtinieve),"99") + 
    " a " +
                                     STRING(crapadp.dtfineve).
                                    /* STRING(DAY(crapadp.dtfineve),"99") + "/" +
                                     STRING(MONTH(crapadp.dtfineve),"99").*/
	
        ELSE
                      aux_dsmeseve = string(crapadp.dtinieve).
                                     /*STRING(DAY(crapadp.dtinieve),"99") + "/" +
                                     STRING(MONTH(crapadp.dtinieve),"99").*/
        
      END.
  
  FIND FIRST crapeap WHERE crapeap.cdcooper = crapadp.cdcooper AND
  crapeap.idevento = crapadp.idevento AND
  crapeap.cdevento = crapadp.cdevento AND
  crapeap.dtanoage = crapadp.dtanoage AND
  crapeap.cdagenci = crapadp.cdagenci NO-LOCK.
  
  IF AVAILABLE crapeap THEN
  DO:
    IF crapeap.qtmaxtur > 0 THEN
    ASSIGN aux_qtmaxtur = crapeap.qtmaxtur.
    ELSE
    DO:
      /* para a frequencia minima */
      FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND
      crabedp.cdcooper = crapadp.cdcooper AND
      crabedp.dtanoage = crapadp.dtanoage AND
      crabedp.cdevento = crapadp.cdevento NO-LOCK.
      IF AVAILABLE crabedp THEN
      DO:
        IF crabedp.qtmaxtur > 0 THEN
        ASSIGN aux_qtmaxtur = crabedp.qtmaxtur.
        ELSE
        DO:
          FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND
          crabedp.cdcooper = 0 AND
          crabedp.dtanoage = 0 AND
          crabedp.cdevento = crapadp.cdevento NO-LOCK.
          
          IF AVAILABLE crabedp THEN
          ASSIGN aux_qtmaxtur = crabedp.qtmaxtur.
        END.
      END.
    END.
  END.
  ELSE
  DO:
    /* para a frequencia minima */
    FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND
    crabedp.cdcooper = crapadp.cdcooper AND
    crabedp.dtanoage = crapadp.dtanoage AND
    crabedp.cdevento = crapadp.cdevento NO-LOCK.
    IF AVAILABLE crabedp THEN
    DO:
      IF crabedp.qtmaxtur > 0 THEN
      ASSIGN aux_qtmaxtur = crabedp.qtmaxtur.
      ELSE
      DO:
        FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND
        crabedp.cdcooper = 0 AND
        crabedp.dtanoage = 0 AND
        crabedp.cdevento = crapadp.cdevento NO-LOCK.
        
        IF AVAILABLE crapedp THEN
        ASSIGN aux_qtmaxtur = crabedp.qtmaxtur.
      END.
    END.
  END.
  
  /****************/
       /*carrega a tabela temporária*/
       CREATE tt-crapadp.
       ASSIGN tt-crapadp.dtanoage = aux_dtanoage
              tt-crapadp.dsmeseve = aux_dsmeseve
              tt-crapadp.dtinieve = crapadp.dtinieve
              tt-crapadp.dtfineve = crapadp.dtfineve
              tt-crapadp.nmevento = crapedp.nmevento
              tt-crapadp.qtmaxtur = aux_qtmaxtur
              tt-crapadp.cdevento = crapadp.cdevento
              tt-crapadp.nrseqdig = crapadp.nrseqdig
              tt-crapadp.nrmeseve = crapadp.nrmeseve
              tt-crapadp.nmresage = crapage.nmresage
              tt-crapadp.cdagenci = crapadp.cdagenci
              tt-crapadp.cdpartic = crapedp.tppartic
              tt-crapadp.flgcompr = crapedp.flgcompr
              tt-crapadp.dsevento = CAPS(SUBSTRING(aux_tpevento,1,1)) + LC(SUBSTRING(aux_tpevento,2))
              tt-crapadp.dspartic = ENTRY(LOOKUP(STRING(crapedp.tppartic), craptab.dstextab) - 1, craptab.dstextab)
              tt-crapadp.dsstaeve = aux_dsstaeve
              tt-crapadp.prfreque = crapedp.prfreque
              tt-crapadp.nmcidade = aux_nmcidade.
  
   END.
END.
	
/* Inicia a geração do XML através da tabela temporaria */
/* A tabela temporaria foi criada somente para permitir a ordenação das colunas*/

FOR EACH tt-crapadp NO-LOCK
                BY tt-crapadp.nrmeseve
                  BY tt-crapadp.dtinieve
                    BY tt-crapadp.dtfineve
                      BY tt-crapadp.nmevento
                        BY tt-crapadp.nmresage:

    /* Cria o nó PROGRAMACAO */
    xDoc:CREATE-NODE( xRoot2, "PROGRAMACAO", "ELEMENT" ).
    xRoot:APPEND-CHILD( xRoot2 ).
    
    /* Agenda */
    criaCampo("DTANOAGE",STRING(tt-crapadp.dtanoage)).

    /* Data */
    criaCampo("DTMESEVE",tt-crapadp.dsmeseve).

    /* Evento -> Codigo e sequencial */
    criaCampo("NMEVENTO",STRING(tt-crapadp.nmevento)).
    xField:SET-ATTRIBUTE("CDEVENTO",STRING(tt-crapadp.cdevento)).
    xField:SET-ATTRIBUTE("NRSEQDIG",STRING(tt-crapadp.nrseqdig)).

    /* tipo de evento palestra, curso...*/
    criaCampo("DSEVENTO",tt-crapadp.dsevento).

    /* Pac -> Codigo */
    criaCampo("NMRESAGE",STRING(tt-crapadp.nmresage)).
    xField:SET-ATTRIBUTE("CDAGENCI",STRING(tt-crapadp.cdagenci)).
    
    /* Vagas */
    criaCampo("QTMAXTUR",STRING(tt-crapadp.qtmaxtur)).
    xField:SET-ATTRIBUTE("QTMAXTUR",STRING(tt-crapadp.qtmaxtur)).
    
    /* Participação */
    criaCampo("TPPARTIC", tt-crapadp.dspartic).
    xField:SET-ATTRIBUTE("CDPARTIC",STRING(tt-crapadp.cdpartic)).

    /* Termo de Compromisso */
    criaCampo("FLGCOMPR", string(tt-crapadp.flgcompr)).
    
    /* Status das inscrições */
    criaCampo("IDSTAEVE",tt-crapadp.dsstaeve).

    /* Percentual de frequencia exigido */
    criaCampo("PRFREQUE",string(tt-crapadp.prfreque)).     

    /* Pac -> Codigo */
    criaCampo("NMCIDADE",STRING(tt-crapadp.nmcidade)).
        
    aux_flgexist = TRUE.

END.
	
/* Se não encontrou registros, gera TAG de erro */
IF   NOT aux_flgexist   THEN
     DO:
         /* Escolheu UM EVENTO */
         IF   par_cdevento <> 0   THEN
              DO:
                  /* Escolheu UM PAC */
                  IF   par_cdageagr <> 0   THEN
                       DO:
                           /* Escolheu UM MES */
                           IF   par_nrmeseve <> 0   THEN
                                aux_dscritic = "Este evento não é oferecido neste mês pelo Posto de Atendimento escolhido!".
                           ELSE
                                /* Escolheu TODOS MESES */
                                aux_dscritic = "Este evento não é oferecido pelo Posto de Atendimento escolhido!".
                       END.
                  /* Escolheu TODOS PAC'S */
                  ELSE
                       DO:
                           /* Escolheu UM MES */
                           IF   par_nrmeseve <> 0   THEN
                                aux_dscritic = "Este evento não é oferecido no mês escolhido!".
                           ELSE
                                /* Escolheu TODOS MESES */
                                aux_dscritic = "Este evento ainda não está liberado!".
                       END.
              END.
         /* Escolheu TODOS EVENTOS */
         ELSE
              DO:
                  /* Escolheu UM PAC */
                  IF   par_cdageagr <> 0   THEN
                       DO:
                           /* Escolheu UM MES */
                           IF   par_nrmeseve <> 0   THEN
                                aux_dscritic = "Não há eventos oferecidos neste mês pelo Posto de Atendimento escolhido!".
                           ELSE
                                /* Escolheu TODOS MESES */
                                aux_dscritic = "Não há eventos oferecidos pelo Posto de Atendimento escolhido!".
END.
                  /* Escolheu TODOS PAC'S */
ELSE
DO:
                           /* Escolheu UM MES */
                           IF   par_nrmeseve <> 0   THEN
                                aux_dscritic = "Não há eventos oferecidos no mês escolhido!".
                           ELSE
                                /* Escolheu TODOS MESES */
                                /*aux_dscritic = "Não há eventos oferecidos!".*/
                               aux_dscritic = "A agenda do Progrid ainda não está liberada!".
                       END.
              END.
  
    
  /* Cria o elemento de erro no XML */
         xDoc:CREATE-NODE( xRoot2, "ERRO", "ELEMENT" ).
         xRoot:APPEND-CHILD( xRoot2 ).
  xDoc:CREATE-NODE(xText,"","TEXT").
         xRoot2:APPEND-CHILD(xText).
         xText:NODE-VALUE = aux_dscritic.
     END.

	
xDoc:SAVE("STREAM","WEBSTREAM").

DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xField.
DELETE OBJECT xText.
  
/* .......................................................................... */