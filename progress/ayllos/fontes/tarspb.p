/* ..........................................................................

   Programa: Fontes/tarspb.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI - Eder J. Venâncio
   Data    : Outubro/2010                        Ultima atualizacao: 02/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TARSPB (IMPORTACAO DE TARIFAS CIP-SITRAF).
               
   Alteracoes: 04/11/2010 - Inclusao de importacao de arquivo com tarifas
                            BACEN (GATI - Eder) .
                            
               05/05/2011 - Alterado procedure que trata da importacao do 
                            arquivo xml_bacen para atender ao novo layout
                            (Adriano).       
               
               05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)  
                            
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

               03/04/2018 - Correçao na tela TARSPB para, na importaçao da tarifa, 
                            validar se os dados do arquivo sao condizentes ao período informado. 
                            Exemplo do chamado usuário estava importando informaçoes de 12/2017 
                            e informando na tela 01/2018.
                            Chamado 845846 - Everton (Mouts)

............................................................................. */

{includes/var_online.i }  

DEF TEMP-TABLE tt-tarifxml NO-UNDO 
    FIELD c-DtRef    AS CHAR FORMAT "X(10)"
    FIELD c-CodMsgOr AS CHAR
    FIELD c-Desc     AS CHAR FORMAT "X(60)"
    FIELD c-TpTar    AS CHAR
    FIELD c-Qtd      AS CHAR
    FIELD c-Vlr      AS CHAR
    FIELD d-Qtd      AS DECI FORMAT ">>9.9999"
    FIELD d-Vlr      AS DECI FORMAT ">>9.9999"
    FIELD d-DtRef    AS DATE FORMAT "99/99/9999".

DEF  VAR aux_cddopcao AS CHAR                                     NO-UNDO.
DEF  VAR tel_mesdbase AS INTE FORMAT "99"                         NO-UNDO.
DEF  VAR tel_anodbase AS INTE FORMAT "9999"                       NO-UNDO.
DEF  VAR tel_cdorigem AS INTE FORMAT "9"                          NO-UNDO.
DEF  VAR tel_dsorigem AS CHAR FORMAT "x(10)"                      NO-UNDO.
DEF  VAR aux_dirimpor AS CHAR                                     NO-UNDO.
DEF  VAR aux_nmarquiv AS CHAR                                     NO-UNDO.
DEF  VAR aux_nmarqpes AS CHAR                                     NO-UNDO.
DEF  VAR aux_nmarqdir AS CHAR                                     NO-UNDO.
DEF  VAR aux_dstiparq AS CHAR                                     NO-UNDO.
DEF  VAR aux_confirma AS LOGI FORMAT "S/N"                        NO-UNDO.
DEF  VAR aux_contador AS INTE                                     NO-UNDO. 
DEF  VAR aux_contado2 AS INTE                                     NO-UNDO.
DEF  VAR aux_diaddata AS INTE                                     NO-UNDO.
DEF  VAR aux_mesddata AS INTE                                     NO-UNDO.
DEF  VAR aux_anoddata AS INTE                                     NO-UNDO.
DEF  VAR aux_encontra AS LOGI                                     NO-UNDO.
DEF  VAR aux_database AS DATE                                     NO-UNDO.
DEF  VAR aux_dtiniper AS DATE                                     NO-UNDO.
DEF  VAR aux_dtfimper AS DATE                                     NO-UNDO.
DEF  VAR aux_nmendter AS CHAR FORMAT "x(20)"                      NO-UNDO.
DEF  VAR aux_nmarqimp AS CHAR                                     NO-UNDO.
DEF  VAR aux_stmesano AS CHAR FORMAT "x(7)"                       NO-UNDO.

/* Variaveis para importacao XML */
DEF  VAR xml_buffertt AS HANDLE                                   NO-UNDO.
DEF  VAR xml_document AS HANDLE                                   NO-UNDO.
DEF  VAR xml_rootnode AS HANDLE                                   NO-UNDO.
DEF  VAR xml_nodeprin AS HANDLE                                   NO-UNDO.
DEF  VAR xml_children AS HANDLE                                   NO-UNDO.
DEF  VAR xml_registro AS HANDLE                                   NO-UNDO.
DEF  VAR xml_nomcampo AS CHAR                                     NO-UNDO.
DEF  VAR xml_valcampo AS CHAR                                     NO-UNDO.
DEF  VAR xml_confirma AS LOGI                                     NO-UNDO.

/***** Variaveis de impressao - utilizadas em impressao.i *****/
DEF  VAR aux_flgescra AS LOGI                                     NO-UNDO.
DEF  VAR par_flgfirst AS LOGI INIT TRUE                           NO-UNDO.
DEF  VAR par_flgcance AS LOGI                                     NO-UNDO.
DEF  VAR aux_dscomand AS CHAR                                     NO-UNDO.
DEF  VAR par_flgrodar AS LOGI INIT TRUE                           NO-UNDO.
DEF  VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"       NO-UNDO.
DEF  VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"       NO-UNDO.
/**************************************************************/

DEF    VAR rel_nmresemp       AS CHAR                           NO-UNDO.
DEF    VAR rel_nmrelato       AS CHAR   EXTENT 5                NO-UNDO.
DEF    VAR rel_nrmodulo       AS INT                            NO-UNDO.

DEF STREAM str_1.

FORM glb_cddopcao LABEL "Opcao" 
     HELP 'Informe "I" para importacao ou "R" para impressao.'
     VALIDATE(glb_cddopcao = "I" OR glb_cddopcao = "R","014 - Opcao errada.")
     WITH SIDE-LABELS WIDTH 27 ROW 6 COLUMN 3 NO-BOX OVERLAY FRAME f_consulta.

FORM tel_cdorigem LABEL "Origem"
     HELP 'Informe 1 para CIPSITRAF ou 2 para BACEN'
     VALIDATE(tel_cdorigem = 1 OR tel_cdorigem = 2,"014 - Opcao errada.")
     tel_dsorigem NO-LABEL
     SPACE(5)
     tel_mesdbase LABEL "Periodo Base"
     VALIDATE(tel_mesdbase >= 1 AND tel_mesdbase <= 12,
              "Para o campo mes, informe um valor entre 1 e 12")
     "/"
     tel_anodbase NO-LABEL
     VALIDATE(tel_anodbase > 0,
              "Para o campo ano, informe um valor maior que 0")
     WITH ROW 6 COLUMN 32 OVERLAY NO-BOX FRAME f_dados SIDE-LABELS.

FORM "Aguarde... Imprimindo relatorio de tarifas CIP-SITRAF!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM crapetf.dtrefere  COLUMN-LABEL "Data Ref."
     crapetf.qttarifa  COLUMN-LABEL "Qtde."
     crapetf.tptarifa  COLUMN-LABEL "Tipo"
     crapetf.vltarifa  COLUMN-LABEL "Valor"
     WITH FRAME f_impressao DOWN NO-BOX STREAM-IO.

FORM crapetf.dsmensag  COLUMN-LABEL "MENSAGEM"
     crapetf.qttarifa  COLUMN-LABEL "QTDE"
     crapetf.vltarifa  COLUMN-LABEL "VALOR"
     WITH FRAME f_impressao2 DOWN NO-BOX STREAM-IO.

FORM tel_cdorigem    LABEL "Origem"
     "-"
     tel_dsorigem NO-LABEL 
     SKIP
     aux_stmesano    LABEL "Data Base"
     WITH SIDE-LABELS FRAME f_info_relat NO-BOX STREAM-IO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

/** Listar as tarifas do periodo antes de imprimir para conferencia **/
DEF QUERY q_crapetf FOR crapetf.    

DEF BROWSE b_tarifas QUERY q_crapetf
    DISPLAY crapetf.dsmensag  COLUMN-LABEL "Mensagem"
            crapetf.dtrefere  COLUMN-LABEL "Data Ref."
            crapetf.qttarifa  COLUMN-LABEL "Qtde."    
            crapetf.tptarifa  COLUMN-LABEL "Tipo"
            crapetf.vltarifa  COLUMN-LABEL "Valor"
            WITH 8 DOWN OVERLAY.

DEF  FRAME f_tarifas 
     b_tarifas
     HELP "Pressione ENTER para imprimir TOTAIS ou <END>/<F4> para sair"
     WITH OVERLAY COL 5 ROW 9 NO-BOX.

ASSIGN glb_cdrelato[1] = 577
       glb_cddopcao    = "I".

{ includes/cabrel080_1.i }
          
VIEW FRAME f_moldura.

PAUSE (0).

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
IF   AVAIL crapcop   THEN
     ASSIGN aux_dirimpor = "~/micros~/" + crapcop.dsdircop + "~/spb~/".
ELSE
     ASSIGN aux_dirimpor = "~/micros~/cecred~/spb~/".

bloco_principal:
DO  WHILE TRUE  ON ENDKEY UNDO, LEAVE:
    
    RUN fontes/inicia.p.
    
    HIDE FRAME f_tarifas.
                                         
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:                                     
        UPDATE   glb_cddopcao WITH FRAME f_consulta.
        LEAVE.
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         DO: 
             RUN  fontes/novatela.p.
             IF   CAPS(glb_nmdatela) <> "TARSPB"   THEN
                  LEAVE.
             ELSE
                  NEXT.
         END.
            
    IF   aux_cddopcao <> glb_cddopcao   THEN
         DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao
                   glb_cdcritic = 0.
         END.  
    
    PAUSE 0. 

    UPDATE tel_cdorigem
           WITH FRAME f_dados.
 
    CASE tel_cdorigem:
        WHEN 1 THEN /* CIPSITRAF */ ASSIGN tel_dsorigem = "CIP-SITRAF".
        WHEN 2 THEN /* BACEN */     ASSIGN tel_dsorigem = "BACEN".
    END CASE.

    DISP tel_dsorigem
         WITH FRAME f_dados.

    UPDATE tel_mesdbase tel_anodbase
           WITH FRAME f_dados.
    
    ASSIGN aux_dtiniper = DATE(tel_mesdbase,01,tel_anodbase).
    IF   tel_mesdbase = 12 THEN
         ASSIGN aux_dtfimper = DATE(12,31,tel_anodbase).
    ELSE
         ASSIGN aux_dtfimper = DATE(tel_mesdbase + 1,01,tel_anodbase) - 1.

    CASE tel_cdorigem:
        WHEN 1 THEN /* CIPSITRAF */
               ASSIGN aux_nmarqpes = "CIPSITRAF_" + STRING(tel_mesdbase,"99") + 
                                     STRING(tel_anodbase,"9999") + ".XML".

        WHEN 2 THEN /* BACEN */
               ASSIGN aux_nmarqpes = "BACEN_" + STRING(tel_mesdbase,"99") + 
                                     STRING(tel_anodbase,"9999") + ".XML".
    END CASE.

    /* para encontrar o arquivo mesmo com minusculas ou maiusculas */
    RUN pi_procura_arquivo.

    IF   glb_cddopcao = "I"   THEN /* Importacao */
         DO:
             IF   SEARCH(aux_dirimpor + aux_nmarquiv) = ?          AND
                  SEARCH(aux_dirimpor + LOWER(aux_nmarquiv)) = ?   THEN
                  DO:
                      ASSIGN glb_cdcritic = 0
                             glb_dscritic = "Nao ha arquivo de tarifas " +
                                            tel_dsorigem + 
                                            " para o periodo base " +
                                            STRING(tel_mesdbase,"99") + "~/" +
                                            STRING(tel_anodbase,"9999").
                      MESSAGE glb_dscritic.
                      BELL.               
                      NEXT.
                  END.

             ASSIGN aux_encontra = NO.

             /* Verifica se periodo ja foi importado */
             bloco_periodo_importado:
             DO   aux_database = aux_dtiniper TO aux_dtfimper:
                  IF   CAN-FIND(FIRST crapetf WHERE
                            crapetf.dtrefere = aux_database   AND
                            crapetf.cdorigem = tel_cdorigem) THEN
                       DO:
                           ASSIGN aux_encontra = YES.
                       
                           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       
                               ASSIGN aux_confirma = NO
                                      glb_cdcritic = 0
                                      glb_dscritic = 
                                          "Periodo base informado ja " +
                                          "importado. Confirma "       +
                                          "reimportacao?".
                               BELL.
                               MESSAGE COLOR NORMAL glb_dscritic 
                                       UPDATE aux_confirma.
                               
                               LEAVE.
                           
                           END.
                           
                           IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                               aux_confirma <> YES                 THEN
                               DO:
                                   ASSIGN glb_cdcritic = 79.
                                   RUN fontes/critic.p.
                                   ASSIGN glb_cdcritic = 0.
                                   BELL.
                                   MESSAGE glb_dscritic.
                           
                                   NEXT bloco_principal.
                               END.
                       
                           LEAVE bloco_periodo_importado.
                       END. /* IF   CAN-FIND(FIRST crapetf WHERE.. */
             END.

             IF   aux_encontra = NO   THEN
                  DO:
             
                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                          ASSIGN aux_confirma = NO
                                 glb_cdcritic = 0
                                 glb_dscritic = 
                                     "Confirma importacao do periodo base " + 
                                     STRING(tel_mesdbase,"99") + "~/" +
                                     STRING(tel_anodbase,"9999") + " ?".
                          BELL.
                          MESSAGE COLOR NORMAL glb_dscritic 
                                  UPDATE aux_confirma.
                          
                          LEAVE.
                      
                      END.
                      
                      IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                          aux_confirma <> YES                 THEN
                          DO:
                              ASSIGN glb_cdcritic = 79.
                              RUN fontes/critic.p.
                              ASSIGN glb_cdcritic = 0.
                              BELL.
                              MESSAGE glb_dscritic.
                              NEXT bloco_principal.
                          END.
                  END. /* IF   aux_encontra = NO (periodo ainda nao importado */

             CASE tel_cdorigem:
                 WHEN 1 THEN RUN pi_importa_xml_CIP-SITRAF.
                 WHEN 2 THEN RUN pi_importa_xml_BACEN.
             END CASE.
             
             /* Elimina registros do periodo a ser importado */
             DO   aux_database = aux_dtiniper TO aux_dtfimper:
                  FOR EACH crapetf WHERE
                           crapetf.dtrefere = aux_database    AND 
                           crapetf.cdorigem = tel_cdorigem    EXCLUSIVE-LOCK:
                      DELETE crapetf.
                  END.
             END.

             FOR EACH tt-tarifxml:

				 IF (tt-tarifxml.d-DtRef < aux_dtiniper) OR (tt-tarifxml.d-DtRef > aux_dtfimper) THEN
                     DO:
 					   ASSIGN glb_cdcritic = 0
                              glb_dscritic = "Data dos registros não conferem com parâmetros digitados. Registro a ser importado: Mês:" +
											STRING(MONTH(tt-tarifxml.d-DtRef), "99") + " - Ano:" +
                                            STRING(YEAR(tt-tarifxml.d-DtRef)).
                       MESSAGE glb_dscritic.
                       BELL.               
                       NEXT.	
                    END.
					                 
                 CREATE crapetf.
                 ASSIGN crapetf.cdorigem = tel_cdorigem
                        crapetf.dsmensag = tt-tarifxml.c-CodMsgOr
                        crapetf.dtrefere = tt-tarifxml.d-DtRef
                        crapetf.qttarifa = tt-tarifxml.d-Qtd
                        crapetf.tptarifa = tt-tarifxml.c-TpTar
                        crapetf.vltarifa = tt-tarifxml.d-Vlr.
                VALIDATE crapetf.
             END.

             UNIX SILENT VALUE("mv " + aux_dirimpor + aux_nmarquiv + 
                               " salvar 2> /dev/null").

             MESSAGE "Importacao do periodo base " + 
                     STRING(tel_mesdbase,"99") + "~/" +
                     STRING(tel_anodbase,"9999") + " realizada com sucesso !".
         END.
    ELSE
    IF   glb_cddopcao = "R"   THEN /* Impressao */
         DO:
             OPEN QUERY q_crapetf 
                 FOR EACH crapetf WHERE
                          crapetf.cdorigem  = tel_cdorigem   AND
                          crapetf.dtrefere >= aux_dtiniper   AND 
                          crapetf.dtrefere <= aux_dtfimper.

             IF   QUERY q_crapetf:NUM-RESULTS > 0   THEN
                  DO:
                      ENABLE b_tarifas WITH FRAME f_tarifas.
                      WAIT-FOR RETURN, END-ERROR OF b_tarifas.

                      IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                          NEXT.

                      VIEW FRAME f_aguarde.

                      INPUT THROUGH basename `tty` NO-ECHO.

                      SET aux_nmendter WITH FRAME f_terminal.
                      
                      INPUT CLOSE.
                      
                      aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                            aux_nmendter.
                      
                      UNIX SILENT VALUE("rm rl/" + aux_nmendter + 
                                        "* 2> /dev/null").
                      
                      ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + 
                                            STRING(TIME) + ".ex".
                      
                      OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED 
                                                                 PAGE-SIZE 84.
                      VIEW STREAM str_1 FRAME f_cabrel080_1.
                      
                      aux_stmesano = STRING(MONTH(aux_dtiniper), "99") + "/" +
                                     STRING(YEAR(aux_dtiniper)).
                      
                      DISP STREAM str_1
                           tel_cdorigem 
                           tel_dsorigem
                           aux_stmesano
                           SKIP(1)
                           WITH FRAME f_info_relat.
                      
                      FOR EACH crapetf WHERE 
                               crapetf.cdorigem  = tel_cdorigem   AND
                               crapetf.dtrefere >= aux_dtiniper   AND 
                               crapetf.dtrefere <= aux_dtfimper   NO-LOCK
                          BREAK BY crapetf.dsmensag:
                             
                          ACCUM crapetf.qttarifa (TOTAL BY crapetf.dsmensag).
                          ACCUM crapetf.vltarifa (TOTAL BY crapetf.dsmensag).

                          IF   LAST-OF(crapetf.dsmensag)   THEN
                               DO: 
                                   DISP STREAM str_1
                                        crapetf.dsmensag
                                        ACCUM TOTAL BY crapetf.dsmensag 
                                              crapetf.qttarifa @ 
                                              crapetf.qttarifa
                                        ACCUM TOTAL BY crapetf.dsmensag
                                              crapetf.vltarifa @
                                              crapetf.vltarifa
                                        WITH FRAME f_impressao2.
                                   DOWN STREAM str_1 WITH FRAME f_impressao2.
                               END.
                      END.

                      UNDERLINE
                           STREAM str_1
                           crapetf.vltarifa
                           WITH FRAME f_impressao2.
                      DOWN STREAM str_1 WITH FRAME f_impressao2.

                      DISP STREAM str_1
                           ACCUM TOTAL crapetf.vltarifa @ crapetf.vltarifa
                           WITH FRAME f_impressao2.
                      DOWN STREAM str_1 WITH FRAME f_impressao2.
                                                                            
                      OUTPUT STREAM str_1 CLOSE.

                      HIDE FRAME f_aguarde NO-PAUSE.
                      
                      MESSAGE "Imprimindo relatorio de tarifas do periodo...".

                      FIND FIRST crapass WHERE 
                                 crapass.cdcooper = glb_cdcooper NO-LOCK.
                      { includes/impressao.i } 
                      
                  END.
             ELSE
                  DO:
                       MESSAGE "Nao ha registros para o periodo base " + 
                               "informado !".
                       NEXT.
                  END.
         END.

END. /* DO  WHILE TRUE  ON ENDKEY UNDO, LEAVE: (bloco_principal) */
 
PROCEDURE pi_importa_xml_CIP-SITRAF:
    /***********************************************************************
        Objetivo: importar arquivo xml com tarifas CIP-SITRAF
    ***********************************************************************/

    EMPTY TEMP-TABLE tt-tarifxml.

    CREATE X-DOCUMENT xml_document.
    CREATE X-NODEREF  xml_rootnode.
    CREATE X-NODEREF  xml_nodeprin.

    xml_document:LOAD("file":U, aux_dirimpor + aux_nmarquiv, FALSE) NO-ERROR.

    /* Inicia a leitura dos nos */
    xml_document:GET-DOCUMENT-ELEMENT(xml_rootnode).

    /* Processa Filhos */
    CREATE BUFFER xml_buffertt FOR TABLE "tt-tarifxml".

    CREATE X-NODEREF xml_children.
    CREATE X-NODEREF xml_registro.

    xml_document:GET-CHILD(xml_rootnode,1).

    DO aux_contador = 1 TO xml_rootnode:NUM-CHILDREN:
        xml_rootnode:GET-CHILD(xml_nodeprin,aux_contador).
        IF xml_nodeprin:NAME = "Repet_Tar" THEN
            LEAVE.
    END.

    IF xml_nodeprin:NAME = "Repet_Tar" THEN DO:
        DO aux_contador = 1 TO xml_nodeprin:NUM-CHILDREN:

            xml_nodeprin:GET-CHILD(xml_children,aux_contador).
            
            IF xml_children:NAME = "Grupo_Tar" THEN DO:

                xml_buffertt:BUFFER-CREATE.

                DO aux_contado2 = 1 TO xml_children:NUM-CHILDREN:
                    xml_children:GET-CHILD(xml_registro,aux_contado2).
                
                    IF xml_registro:NAME = '#text' THEN NEXT.
                
                    ASSIGN 
                       xml_nomcampo = "c-" + xml_registro:NAME
                       xml_confirma = xml_registro:GET-CHILD(xml_registro,1)
                       xml_valcampo = 
                           IF xml_confirma AND 
                              xml_registro:SUBTYPE = "Text" THEN 
                              REPLACE(xml_registro:NODE-VALUE,"%20"," ") 
                           ELSE ''
                       xml_buffertt:BUFFER-FIELD(xml_nomcampo):BUFFER-VALUE() =
                        xml_valcampo.
                END.

            END.
        END.
    END.

    DELETE OBJECT xml_children.
    DELETE OBJECT xml_rootnode.
    DELETE OBJECT xml_nodeprin.
    DELETE OBJECT xml_registro.

    /* Atribui campos da temp-table tt-tarifxml */
    FOR EACH tt-tarifxml:

        ASSIGN 
            tt-tarifxml.d-Qtd   = DECIMAL(REPLACE(tt-tarifxml.c-Qtd,".",","))
            tt-tarifxml.d-Vlr   = DECIMAL(REPLACE(tt-tarifxml.c-Vlr,".",","))
            aux_diaddata        = INT(ENTRY(3,tt-tarifxml.c-DtRef,"-"))
            aux_mesddata        = INT(ENTRY(2,tt-tarifxml.c-DtRef,"-"))
            aux_anoddata        = INT(ENTRY(1,tt-tarifxml.c-DtRef,"-"))
            tt-tarifxml.d-DtRef = DATE(aux_mesddata,
                                       aux_diaddata,
                                       aux_anoddata).
    END.

END PROCEDURE. /* PROCEDURE pi_importa_xml_CIP-SITRAF */

PROCEDURE pi_importa_xml_BACEN:
    /***********************************************************************
        Objetivo: importar arquivo xml com tarifas BACEN
    ***********************************************************************/

    EMPTY TEMP-TABLE tt-tarifxml.

    CREATE X-DOCUMENT xml_document.
    CREATE X-NODEREF  xml_rootnode.
    CREATE X-NODEREF  xml_nodeprin.

    xml_document:LOAD("file":U, aux_dirimpor + aux_nmarquiv, FALSE) NO-ERROR.

    /* Inicia a leitura dos nos */
    xml_document:GET-DOCUMENT-ELEMENT(xml_rootnode).

    /* Processa Filhos */
    CREATE BUFFER xml_buffertt FOR TABLE "tt-tarifxml".

    CREATE X-NODEREF xml_children.
    CREATE X-NODEREF xml_registro.

    
    xml_document:GET-CHILD(xml_rootnode,1).
    DO   aux_contador = 1 TO xml_rootnode:NUM-CHILDREN:
         xml_rootnode:GET-CHILD(xml_nodeprin,aux_contador).
         IF   xml_nodeprin:NAME = "SISMSG"   THEN
              LEAVE.
    END.
    
    IF   xml_nodeprin:NAME = "SISMSG"   THEN
         DO   aux_contador = 1 TO xml_nodeprin:NUM-CHILDREN:
              xml_nodeprin:GET-CHILD(xml_rootnode,aux_contador).
              IF   xml_rootnode:NAME = "STR0035R1"   THEN
                   LEAVE.
         END. 
    
    IF xml_rootnode:NAME = "STR0035R1"   THEN 
       DO aux_contador = 1 TO xml_rootnode:NUM-CHILDREN:
          xml_rootnode:GET-CHILD(xml_children,aux_contador).
          IF xml_children:NAME = "Grupo_STR0035R1_Tar"   THEN
             DO:
                xml_buffertt:BUFFER-CREATE.

                DO aux_contado2 = 1 TO xml_children:NUM-CHILDREN:
                   xml_children:GET-CHILD(xml_registro,aux_contado2).
                   IF xml_registro:NAME = '#text' THEN NEXT. 
                    
                   ASSIGN 
                       xml_nomcampo = "c-" + xml_registro:NAME
                       xml_confirma = xml_registro:GET-CHILD(xml_registro,1)
                       xml_valcampo = 
                           IF xml_confirma AND 
                              xml_registro:SUBTYPE = "Text" THEN 
                              REPLACE(xml_registro:NODE-VALUE,"%20"," ") 
                           ELSE ''
                       xml_buffertt:BUFFER-FIELD(xml_nomcampo):BUFFER-VALUE() =
                       xml_valcampo.
                           
                END.

             END.
           
       END. 

    DELETE OBJECT xml_children.
    DELETE OBJECT xml_rootnode.
    DELETE OBJECT xml_nodeprin.
    DELETE OBJECT xml_registro.

    /* Atribui campos da temp-table tt-tarifxml */
    FOR EACH tt-tarifxml:

        ASSIGN 
            tt-tarifxml.d-Qtd   = DECIMAL(REPLACE(tt-tarifxml.c-Qtd,".",","))
            tt-tarifxml.d-Vlr   = DECIMAL(REPLACE(tt-tarifxml.c-Vlr,".",","))
            aux_diaddata        = INT(ENTRY(3,tt-tarifxml.c-DtRef,"-"))
            aux_mesddata        = INT(ENTRY(2,tt-tarifxml.c-DtRef,"-"))
            aux_anoddata        = INT(ENTRY(1,tt-tarifxml.c-DtRef,"-"))
            tt-tarifxml.d-DtRef = DATE(aux_mesddata,
                                       aux_diaddata,
                                       aux_anoddata).
    END.

END PROCEDURE. /* PROCEDURE pi_importa_xml_BACEN */

PROCEDURE pi_procura_arquivo:
    /***********************************************************************
        Objetivo: verificar arquivos xml do diretorio de origem
                  (criada para nao diferenciar maiusculas e minusculas)
    ***********************************************************************/

    INPUT FROM OS-DIR (aux_dirimpor).

    REPEAT:
       IMPORT aux_nmarqdir ^ aux_dstiparq.
    
       IF   aux_dstiparq <> "F"   THEN 
            NEXT.
    
       IF   ENTRY(NUM-ENTRIES(aux_nmarqdir,"."),
                  aux_nmarqdir,".") <> "xml"   THEN 
            NEXT.
    
       IF aux_nmarqdir = aux_nmarqpes THEN
          ASSIGN aux_nmarquiv = aux_nmarqdir.
    END.
    
    INPUT CLOSE.

END PROCEDURE. /* PROCEDURE pi_procura_arquivo: */
