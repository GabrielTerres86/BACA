/* .............................................................................

   Programa: wcrm0007_xml.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Anderson Fossa
   Data    : 17/03/2016                  Ultima Atualizacao: 24/06/2016

   Dados referentes ao programa:

   Frequencia: On-line (internet)
   Objetivo  : Gerar arquivo XML para a tela wcrm0007 e wcrm0007a

   Alteracoes: 24/06/2016 - Alterado para exibir o curso se estiver ativo em pelo
                            menos 1 PA SD468459. (Odirlei-AMcom)
                            
               23/09/2016 - Ajuste para exibir corretamente o caracter de de marcador
                            SD525341(Odirlei-AMcom)
..............................................................................*/

CREATE WIDGET-POOL.

DEFINE VARIABLE par_cdcooper LIKE crapedp.cdcooper                    NO-UNDO.
DEFINE VARIABLE par_cdevento LIKE crapedp.cdevento                    NO-UNDO.
DEFINE VARIABLE par_nmevento LIKE crapedp.nmevento                    NO-UNDO.
DEFINE VARIABLE par_idevento LIKE crapedp.idevento                    NO-UNDO.
DEFINE VARIABLE par_dtanoage LIKE crapedp.dtanoage                    NO-UNDO.

DEFINE VARIABLE aux_dscritic AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_flgexist AS LOGICAL         INIT FALSE            NO-UNDO.
DEFINE VARIABLE aux_dtanoage LIKE gnpapgd.dtanoage                    NO-UNDO.

/* Variaveis de controle do XML */
DEFINE VARIABLE xDoc         AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot        AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot2       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xField       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xText        AS HANDLE                                NO-UNDO.

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
       par_idevento = INT(GET-VALUE("aux_idevento"))
       par_dtanoage = INT(GET-VALUE("aux_dtanoage"))
       par_nmevento = STRING(GET-VALUE("aux_nmevento")).


CREATE X-DOCUMENT xDoc.
CREATE X-NODEREF  xRoot.
CREATE X-NODEREF  xRoot2.
CREATE X-NODEREF  xField.
CREATE X-NODEREF  xText.

/* Cria a raiz principal */
xDoc:CREATE-NODE( xRoot, "CECRED", "ELEMENT" ).
xDoc:APPEND-CHILD( xRoot ).

/*define temporaria para permitir ordenação das colunas*/
DEFINE TEMP-TABLE tt-crapedp NO-UNDO
       /* Campos chave */
       FIELD tt-idevento LIKE crapedp.idevento
       FIELD tt-cdevento LIKE crapedp.cdevento
       FIELD tt-dtanoage LIKE crapedp.dtanoage 
       
       FIELD tt-nmevento LIKE crapedp.nmevento
       FIELD tt-dscarhor LIKE crapedp.dscarhor
       FIELD tt-dsconteu LIKE crapedp.dsconteu.

EMPTY TEMP-TABLE tt-crapedp.

ASSIGN aux_dtanoage = par_dtanoage.
IF aux_dtanoage = 0 THEN
  ASSIGN aux_dtanoage = YEAR(TODAY).

ListaEad:
FOR EACH crapedp WHERE crapedp.cdcooper = par_cdcooper AND
                       crapedp.dtanoage = aux_dtanoage AND
                      (crapedp.cdevento = par_cdevento OR par_cdevento = 0) AND
                      (crapedp.idevento = par_idevento OR par_idevento = 0) AND
                      (  /* Filtro nome do evento */
                        par_nmevento = " " OR 
                        par_nmevento = ?   OR
                        crapedp.nmevento MATCHES "*" + par_nmevento + "*") AND
                       crapedp.cdevento >= 50000 NO-LOCK:

    /* Apenas listar o evento se encontrar o curso ativo em algum PA
       Na plataforma EAD nao existe distincao se turmas por PA */
    FIND FIRST crapadp WHERE crapadp.cdcooper = crapedp.cdcooper AND
                            crapadp.idevento = crapedp.idevento AND
                            crapadp.dtanoage = crapedp.dtanoage AND
                            crapadp.cdevento = crapedp.cdevento AND
                           (crapadp.idstaeve = 1 AND
                            crapadp.dtfineve > TODAY) NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE crapadp THEN
      NEXT ListaEad.
    
    CREATE tt-crapedp.
    ASSIGN tt-idevento = crapedp.idevento
           tt-cdevento = crapedp.cdevento
           tt-dtanoage = crapedp.dtanoage
           tt-nmevento = CAPS(crapedp.nmevento)
           tt-dscarhor = IF (crapedp.dscarhor = ? or crapedp.dscarhor = " ") THEN
                            "00:00"
                         ELSE
                            crapedp.dscarhor
           tt-dsconteu = crapedp.dsconteu.
END.


/* Inicia a geração do XML através da tabela temporaria */
/* A tabela temporaria foi criada somente para permitir a ordenação das colunas*/

FOR EACH tt-crapedp NO-LOCK
    BY tt-idevento
    BY tt-cdevento:

    tt-dsconteu = REPLACE(tt-dsconteu,'•','<br>&bull;&nbsp;').

    /* Cria o nó PROGRAMACAO */
    xDoc:CREATE-NODE( xRoot2, "CURSOS_EAD", "ELEMENT" ).
    xRoot:APPEND-CHILD( xRoot2 ).
    
    criaCampo("IDEVENTO",STRING(tt-idevento)).
    criaCampo("CDEVENTO",STRING(tt-cdevento)).
    criaCampo("DTANOAGE",STRING(tt-dtanoage)).
    criaCampo("NMEVENTO",STRING(tt-nmevento)).
    criaCampo("DSCARHOR",STRING(tt-dscarhor)).
    /* criaCampo("DSCONTEU","<![CDATA[" + STRING(tt-dsconteu) + "]]>"). */
    criaCampo("DSCONTEU",STRING(tt-dsconteu)).
        
    aux_flgexist = TRUE.

END.

/* Se não encontrou registros, gera TAG de erro */
IF   NOT aux_flgexist   THEN
     DO:
         IF aux_dscritic = "" THEN
           ASSIGN aux_dscritic = "Nenhum registro encontrado!".
        
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