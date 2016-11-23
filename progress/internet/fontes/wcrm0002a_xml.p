/* .............................................................................
   Programa: wcrm0002a_xml.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
Data    : Junho/2006                      Ultima Atualizacao: 29/10/2015
   
   Dados referentes ao programa:
   
   Frequencia: Diario (internet)
   Objetivo  : Gerar arquivo XML para a tela wcrm0002a
   
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)
   
               04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).

               19/12/2012 - Tratar nova estrutura gnappob (Gabriel). 
 
05/10/2015 - Incluida verificacao de qtmaxtur na crapeap antes
da atribuicao da crapedp Projeto 229 (Jean Michel).

29/10/2015 - Incluida verificação e tratamento para os dias de
semana do evento, PRJ 229 (Jean Michel)
			   							
			   28/10/2016 - Inclusão da chamada da procedure pc_informa_acesso_progrid
							para gravar log de acesso. (Jean Michel)
..............................................................................*/
 
{ sistema/generico/includes/var_log_progrid.i }
 
create widget-pool.
 
DEFINE VARIABLE par_cdcooper AS INTEGER                               NO-UNDO.
DEFINE VARIABLE par_cdevento AS INTEGER                               NO-UNDO.
DEFINE VARIABLE par_cdagenci AS INTEGER                               NO-UNDO.
DEFINE VARIABLE par_nrseqdig AS INTEGER                               NO-UNDO.
DEFINE VARIABLE aux_dsmeseve AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dsobjeti AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dsconteu AS CHARACTER                             NO-UNDO.
/*DEFINE VARIABLE aux_conteudo AS CHARACTER                             NO-UNDO.*/
DEFINE VARIABLE aux_qtcarhor AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_nmfacili AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dscurric AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dshroeve AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dsdiaeve AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dslocali AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dsendloc AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_nmbailoc AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_nmcidloc AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dsevento AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dscdiase AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_contador AS INTEGER                               NO-UNDO.
DEFINE VARIABLE aux_qtmaxtur AS INTEGER                               NO-UNDO.

DEFINE BUFFER crabedp FOR crapedp.

/* Variaveis de controle do XML */
DEFINE VARIABLE xDoc         AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot        AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xField       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xText        AS HANDLE                                NO-UNDO.
DEF VAR vetormes     AS CHAR EXTENT 12
       INITIAL ["JANEIRO","FEVEREIRO","MARÇO","ABRIL","MAIO","JUNHO",
                "JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"].
/* Cria um campo com seu valor no XML */


FUNCTION criaCampo RETURNS LOGICAL
    (INPUT nomeCampo  AS CHAR,
     INPUT textoCampo AS CHAR):
    xDoc:CREATE-NODE(xField,CAPS(nomeCampo),"ELEMENT").
    xRoot:APPEND-CHILD(xField).
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
       par_cdagenci = INT(GET-VALUE("aux_cdagenci"))
       par_nrseqdig = INT(GET-VALUE("aux_nrseqdig"))
       aux_dsobjeti = "INDEFINIDO"
       aux_dsconteu = "INDEFINIDO"
       aux_qtcarhor = "INDEFINIDO"
       aux_nmfacili = "INDEFINIDO"
       aux_dscurric = " "
       aux_dslocali = "INDEFINIDO"
       aux_dsendloc = "INDEFINIDO"
       aux_nmbailoc = "INDEFINIDO"
       aux_nmcidloc = "INDEFINIDO".
       
RUN insere_log_progrid("WPGD0002a_xml.p",STRING(par_cdcooper) + "|" + STRING(par_cdagenci)).
       
       /*aux_conteudo = "".*/
CREATE X-DOCUMENT xDoc.
CREATE X-NODEREF  xRoot.
CREATE X-NODEREF  xField.
CREATE X-NODEREF  xText.
/* Evento agendado */
FIND crapadp WHERE crapadp.idevento = 1 /*Progrid*/   AND
                   crapadp.cdcooper = par_cdcooper    AND
                   crapadp.cdagenci = par_cdagenci    AND
                   crapadp.cdevento = par_cdevento    AND
                   crapadp.nrseqdig = par_nrseqdig    NO-LOCK NO-ERROR.

IF   AVAILABLE crapadp   THEN
     DO:
         /* Cria a raiz principal */
         xDoc:CREATE-NODE( xRoot, "EVENTO", "ELEMENT" ).
         xDoc:APPEND-CHILD( xRoot ).
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
                     ASSIGN aux_dsevento = ENTRY(LOOKUP(STRING(crapedp.tpevento), craptab.dstextab) - 1, craptab.dstextab).
                  ELSE
                     ASSIGN aux_dsevento = "".
              END.
         ELSE
              ASSIGN aux_dsevento = "Evento".                                                                                                                        
         
         /* Nome do PAC */
         FIND crapage WHERE crapage.cdcooper = crapadp.cdcooper   AND
                            crapage.cdagenci = crapadp.cdagenci   NO-LOCK NO-ERROR.
         /* Mes do evento */
         IF   crapadp.dtinieve = ?   THEN
              aux_dsmeseve = vetormes[crapadp.nrmeseve].
         ELSE
              DO:
	
                  IF   crapadp.dtinieve <> crapadp.dtfineve   THEN
                       aux_dsmeseve = STRING(crapadp.dtinieve,"99/99/99") +
                                      " a " +
                                      STRING(crapadp.dtfineve,"99/99/99").
                  ELSE
                       aux_dsmeseve = STRING(crapadp.dtinieve,"99/99/99").
              END.
         
         /* Horário do evento */
         aux_dshroeve = IF crapadp.dshroeve = "" THEN "INDEFINIDO"
                        ELSE crapadp.dshroeve.
         /* Dias do evento */
         aux_dsdiaeve = IF crapadp.dsdiaeve = "" THEN "INDEFINIDO"
                        ELSE crapadp.dsdiaeve.
  
	
  /*ALTERACAO JEAN 29/10/2015*/
  DO aux_contador = 1 TO NUM-ENTRIES(aux_dsdiaeve,","):
    
    IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 1 THEN
    DO:
      ASSIGN aux_dscdiase = aux_dscdiase + ", Segunda-Feira".
    END.
    
    IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 2 THEN
    DO:
      ASSIGN aux_dscdiase = aux_dscdiase + ", Terça-Feira".
    END.
    
    IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 3 THEN
    DO:
      ASSIGN aux_dscdiase = aux_dscdiase + ", Quarta-Feira".
    END.
    
    IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 4 THEN
    DO:
      ASSIGN aux_dscdiase = aux_dscdiase + ", Quinta-Feira".
    END.
    
    IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 5 THEN
    DO:
      ASSIGN aux_dscdiase = aux_dscdiase + ", Sexta-Feira".
    END.
    
    IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 6 THEN
    DO:
      ASSIGN aux_dscdiase = aux_dscdiase + ", Sábado".
    END.
    
    IF INT(ENTRY(aux_contador,aux_dsdiaeve,",")) = 0 THEN
    DO:
      ASSIGN aux_dscdiase = aux_dscdiase + ", Domingo".
    END.
  END.
  
  ASSIGN aux_dscdiase = TRIM(aux_dscdiase).
  
  IF SUBSTRING(aux_dscdiase,1,1) = "," then
  DO:
    ASSIGN aux_dscdiase = SUBSTRING(aux_dscdiase,2).
  END.
  
  IF SUBSTRING(aux_dscdiase,LENGTH(aux_dscdiase) - 1,1) = "," then
  DO:
    ASSIGN aux_dscdiase = SUBSTRING(aux_dscdiase,1,LENGTH(aux_dscdiase) - 1).
  END.
  
  ASSIGN aux_dscdiase = aux_dscdiase + "."
  aux_dsdiaeve = aux_dscdiase.
  
  /*ALTERACAO JEAN 29/10/2015*/
  
         /* Custo do evento */
         FIND FIRST crapcdp WHERE crapcdp.idevento = crapadp.idevento   AND
                                  crapcdp.cdcooper = crapadp.cdcooper   AND
                                  crapcdp.cdagenci = crapadp.cdagenci   AND
                                  crapcdp.dtanoage = crapadp.dtanoage   AND
                                  crapcdp.cdevento = crapadp.cdevento
                                  NO-LOCK NO-ERROR.
         IF   AVAILABLE crapcdp   THEN
              DO:
	
                  /* Fornecedor ("pertence" a TODAS as cooperativas) */
                  FIND gnapfdp WHERE gnapfdp.idevento = crapadp.idevento   AND
                                     gnapfdp.cdcooper = 0                  AND
                                     gnapfdp.nrcpfcgc = crapcdp.nrcpfcgc
                                     NO-LOCK NO-ERROR.
                  IF   AVAILABLE gnapfdp   THEN
                       DO:
		
                           /* Proposta do fornecedor ("pertence" a TODAS as cooperativas) */
                           FIND gnappdp WHERE gnappdp.idevento = crapadp.idevento   AND
                                              gnappdp.cdcooper = 0                  AND
                                              gnappdp.nrcpfcgc = crapcdp.nrcpfcgc   AND
                                              gnappdp.nrpropos = crapcdp.nrpropos
                                              NO-LOCK NO-ERROR.

                           IF   AVAILABLE gnappdp    THEN
                                DO:
			
                                    FIND gnappob WHERE
                                         gnappob.idevento = gnappdp.idevento 
                                                                AND 
                                         gnappob.cdcooper = gnappdp.cdcooper
                                                                AND
                                         gnappob.nrcpfcgc = gnappdp.nrcpfcgc
                                                                AND
                                         gnappob.nrpropos = gnappdp.nrpropos
                                         NO-LOCK NO-ERROR.
                                                                 
                                    IF   AVAIl gnappob   THEN
                                         ASSIGN aux_dsobjeti = 
                                                    gnappob.dsobjeti.
                                           
                                    ASSIGN aux_dsconteu = gnappdp.dsconteu
                                           aux_qtcarhor = 
                                            STRING(gnappdp.qtcarhor,"99.99")
                                           aux_qtcarhor = 
                                            REPLACE(aux_qtcarhor,",",":") + 
                                                                " HORAS"
                                           aux_nmfacili = ""
                                           aux_dscurric = "".
                                    /* Facilitador(es) da proposta */
                                    FOR EACH gnfacep WHERE gnfacep.idevento = gnappdp.idevento   AND
                                                           gnfacep.cdcooper = 0                  AND
                                                           gnfacep.nrcpfcgc = gnappdp.nrcpfcgc   AND
                                                           gnfacep.nrpropos = gnappdp.nrpropos   NO-LOCK:
                                        /* Cadastro do facilitador */
                                        FIND gnapfep WHERE gnapfep.idevento = gnfacep.idevento   AND
                                                           gnapfep.cdcooper = 0                  AND
                                                           gnapfep.nrcpfcgc = gnfacep.nrcpfcgc   AND
                                                           gnapfep.cdfacili = gnfacep.cdfacili   NO-LOCK NO-ERROR.
                                        IF   AVAILABLE gnapfep   THEN
          ASSIGN aux_nmfacili = aux_nmfacili + gnapfep.nmfacili + "#"
                                             aux_dscurric = aux_dscurric + gnapfep.dscurric + "#".
                                    END.
                                    IF   aux_nmfacili = ""    THEN
                                         aux_nmfacili = "INDEFINIDO".
                                    ELSE
        /*Tira o ultimo ";" */
        ASSIGN aux_nmfacili = SUBSTRING(aux_nmfacili,1,LENGTH(aux_nmfacili) - 1)
                                         aux_dscurric = SUBSTRING(aux_dscurric,1,LENGTH(aux_dscurric) - 1).
        
                                END.
                       END.
              END.
              
         /* Local do Evento */
         FIND crapldp WHERE crapldp.idevento = crapadp.idevento   AND
                            crapldp.cdcooper = crapadp.cdcooper   AND
                            crapldp.cdagenci = crapadp.cdagenci   AND
                            crapldp.nrseqdig = crapadp.cdlocali   NO-LOCK NO-ERROR.
         IF   AVAILABLE crapldp   THEN
              ASSIGN aux_dslocali = crapldp.dslocali
                     aux_dsendloc = crapldp.dsendloc
                     aux_nmbailoc = crapldp.nmbailoc
                     aux_nmcidloc = crapldp.nmcidloc.
                     
         /* rosangela*/
         
         /*DO aux_contador = 1 TO LENGTH(aux_dsconteu):*/
            /* Troca o ENTER por '\n' */
         /*   IF   KEYCODE(SUBSTRING(aux_dsconteu,aux_contador,1)) = 10   THEN
                  aux_conteudo = aux_conteudo + "~\n".
            ELSE
                  aux_conteudo = aux_conteudo + SUBSTRING(aux_dsconteu,aux_contador,1).
         END.*/
         /* rosangela fim */
                 
         /*criaCampo("NMEVENTO",CAPS(SUBSTRING(crapedp.nmevento,1,1)) + LC(SUBSTRING(crapedp.nmevento,2))).*/
         criaCampo("NMEVENTO",STRING(crapedp.nmevento)).
         criaCampo("DTMESEVE",aux_dsmeseve).
         /*criaCampo("NMRESAGE",CAPS(SUBSTRING(crapage.nmresage,1,1)) + LC(SUBSTRING(crapage.nmresage,2))).*/
         criaCampo("NMRESAGE",STRING(crapage.nmresage)).
         /*criaCampo("DSOBJETI",CAPS(SUBSTRING(aux_dsobjeti,1,1)) + LC(SUBSTRING(aux_dsobjeti,2))).*/
  
         criaCampo("DSOBJETI",STRING(aux_dsobjeti)).
  
  /*criaCampo("DSCONTEU",CAPS(SUBSTRING(aux_dsconteu,1,1)) + LC(SUBSTRING(aux_dsconteu,2))). */
  
         criaCampo("DSCONTEU",STRING(aux_dsconteu)).
  
         criaCampo("QTCARHOR",aux_qtcarhor).
  
         DO aux_contador = 1 TO NUM-ENTRIES(aux_nmfacili,"#"):
            /*criaCampo("NMFACILI",ENTRY(aux_contador,aux_nmfacili,";")).*/
            criaCampo("NMFACILI",ENTRY(aux_contador,aux_nmfacili,"#")).
            xField:SET-ATTRIBUTE("DSCURRIC",ENTRY(aux_contador,aux_dscurric,"#")).
         END.
    
  /***************/
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
  
         /*criaCampo("DSCURRIC",gnapfep.dscurric).*/
  criaCampo("QTMAXTUR",STRING(aux_qtmaxtur) + " VAGAS").
         criaCampo("DSDIAEVE",aux_dsdiaeve).
         criaCampo("DTEXTEVE",aux_dsmeseve).
         criaCampo("DSHOREVE",aux_dshroeve).
	
         /*
         criaCampo("DSLOCALI",CAPS(SUBSTRING(aux_dslocali,1,1)) + LC(SUBSTRING(aux_dslocali,2))).
         criaCampo("DSENDLOC",CAPS(SUBSTRING(aux_dsendloc,1,1)) + LC(SUBSTRING(aux_dsendloc,2))).
         criaCampo("NMBAILOC",CAPS(SUBSTRING(aux_nmbailoc,1,1)) + LC(SUBSTRING(aux_nmbailoc,2))).
         criaCampo("NMCIDLOC",CAPS(SUBSTRING(aux_nmcidloc,1,1)) + LC(SUBSTRING(aux_nmcidloc,2))).*/
         criaCampo("DSLOCALI",STRING(aux_dslocali)).
         criaCampo("DSENDLOC",STRING(aux_dsendloc)).
         criaCampo("NMBAILOC",STRING(aux_nmbailoc)).
         criaCampo("NMCIDLOC",STRING(aux_nmcidloc)).
                                 criaCampo("DSEVENTO",CAPS(SUBSTRING(aux_dsevento,1,1)) + LC(SUBSTRING(aux_dsevento,2))).
	
     END.
ELSE
     DO:
         /* Cria o elemento de erro no XML */
         xDoc:CREATE-NODE( xRoot, "ERRO", "ELEMENT" ).
         xDoc:APPEND-CHILD( xRoot ).
         xDoc:CREATE-NODE(xText,"","TEXT").
         xRoot:APPEND-CHILD(xText).
         xText:NODE-VALUE = "Registro não encontrado!".
	
     END.
xDoc:SAVE("STREAM","WEBSTREAM").
DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xField.
DELETE OBJECT xText.
/* .......................................................................... */
