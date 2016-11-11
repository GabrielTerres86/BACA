/* .............................................................................
   
    Programa: sistema/internet/fontes/wcrm0002c_xml.p
    Autor(a): David
    Data    : Agosto/2010                     Ultima Atualizacao: 28/10/2016
    
    Dados referentes ao programa:
   
    Frequencia: Conforme acionado pelo InternetBank
    Objetivo  : Listar agenda de eventos por mes
   
    Alteracoes: 28/10/2016 - Inclusão da chamada da procedure pc_informa_acesso_progrid
							 para gravar log de acesso. (Jean Michel)
 
..............................................................................*/
 
{ sistema/generico/includes/var_log_progrid.i }
 
CREATE WIDGET-POOL.

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_dtanoage AS INTE                                           NO-UNDO.
DEF VAR aux_nrmesini AS INTE                                           NO-UNDO.
DEF VAR aux_nrmeseve AS INTE                                           NO-UNDO.

DEF VAR aux_dsmeseve AS CHAR EXTENT 12
    INIT ["JANEIRO","FEVEREIRO","MARÇO","ABRIL","MAIO","JUNHO",
          "JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"] NO-UNDO.

DEF VAR xDoc         AS HANDLE                                         NO-UNDO.
DEF VAR xRoot        AS HANDLE                                         NO-UNDO.
DEF VAR xNodeErro    AS HANDLE                                         NO-UNDO.
DEF VAR xNodeMes     AS HANDLE                                         NO-UNDO.
DEF VAR xTagEvento   AS HANDLE                                         NO-UNDO.
DEF VAR xText        AS HANDLE                                         NO-UNDO.

DEF TEMP-TABLE tt-eventos NO-UNDO
    FIELD nrmeseve LIKE crapadp.nrmeseve
    FIELD nmevento LIKE crapedp.nmevento.

/** Include para usar os comandos para WEB **/
{src/web2/wrap-cgi.i}

/** Configura a saída como XML **/
OUTPUT-CONTENT-TYPE ("text/xml":U).

ASSIGN aux_cdcooper = INTE(GET-VALUE("aux_cdcooper"))
       aux_dtanoage = INTE(GET-VALUE("aux_dtanoage"))
       aux_nrmesini = INTE(GET-VALUE("aux_nrmesini")).

IF  aux_nrmesini < 1   OR
    aux_nrmesini > 12  THEN
    ASSIGN aux_nrmesini = 1.

RUN insere_log_progrid("WPGD0002c_xml.p",STRING(aux_cdcooper) + "|" + STRING(aux_dtanoage) + "|" + STRING(aux_nrmesini)).

CREATE X-DOCUMENT xDoc.
CREATE X-NODEREF  xRoot.
CREATE X-NODEREF  xNodeErro.
CREATE X-NODEREF  xNodeMes.
CREATE X-NODEREF  xTagEvento.
CREATE X-NODEREF  xText.

xDoc:CREATE-NODE(xRoot,"CECRED","ELEMENT").
xDoc:APPEND-CHILD(xRoot).

FIND gnpapgd WHERE gnpapgd.cdcooper = aux_cdcooper AND
                   gnpapgd.idevento = 1            AND /** Progrid **/
                   gnpapgd.dtanoage = aux_dtanoage NO-LOCK NO-ERROR.

IF  NOT AVAILABLE gnpapgd  THEN
    DO:
        xDoc:CREATE-NODE(xNodeErro,"ERRO","ELEMENT").
        xRoot:APPEND-CHILD(xNodeErro).
        xDoc:CREATE-NODE(xText,"","TEXT").
        xNodeErro:APPEND-CHILD(xText).
        xText:NODE-VALUE = "A agenda para esse ano ainda não esta liberada. " +
                           "Aguarde mais alguns dias!".
    END. 

DO aux_nrmeseve = aux_nrmesini TO 12:

    xDoc:CREATE-NODE(xNodeMes,"MES","ELEMENT").
    xRoot:APPEND-CHILD(xNodeMes).
    xNodeMes:SET-ATTRIBUTE("NMMESEVE",aux_dsmeseve[aux_nrmeseve]).

    FOR EACH crapadp WHERE crapadp.idevento  = 1             AND /** Progrid **/
                           crapadp.cdcooper  = aux_cdcooper  AND 
                           crapadp.dtanoage  = aux_dtanoage  AND 
                           crapadp.dtlibint <= TODAY         AND
                           crapadp.dtretint >= TODAY         AND   
                           crapadp.nrmeseve  = aux_nrmeseve
                           NO-LOCK BREAK BY crapadp.cdevento:

        IF  FIRST-OF(crapadp.cdevento)  THEN
            DO:
                FIND crapedp WHERE crapedp.idevento = crapadp.idevento AND
                                   crapedp.cdcooper = crapadp.cdcooper AND
                                   crapedp.dtanoage = crapadp.dtanoage AND
                                   crapedp.cdevento = crapadp.cdevento 
                                   NO-LOCK NO-ERROR.
    
                IF  AVAILABLE crapedp  THEN
                    DO:
                        xDoc:CREATE-NODE(xTagEvento,"EVENTO","ELEMENT").
                        xNodeMes:APPEND-CHILD(xTagEvento).
                        xDoc:CREATE-NODE(xText,"","TEXT").
                        xTagEvento:APPEND-CHILD(xText).
                        xText:NODE-VALUE = crapedp.nmevento.
                    END.
            END.                                    
    
    END. /** Fim do FOR EACH crapadp **/

END.

xDoc:SAVE("STREAM","WEBSTREAM").

DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xNodeErro.
DELETE OBJECT xNodeMes.
DELETE OBJECT xTagEvento.
DELETE OBJECT xText.

/*............................................................................*/
