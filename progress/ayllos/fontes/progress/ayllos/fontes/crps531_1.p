/* ............................................................................
   
   Programa: Fontes/crps531_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Setembro/2009.                     Ultima atualizacao: 05/01/2017
   
   Dados referentes ao programa: Fonte extraido e adaptado para execucao em
                                 paralelo. Fonte original crps531.p.

   Frequencia : Sempre que for chamado.
   Objetivo   : Integrar mensagens(TED/TEC) recebidas via SPB.
   
   Observacao : Quando o processo diario ainda estiver executando na cooperativa
                de destino, a mensagem nao sera processada e permanecera no 
                diretorio /integra ate que finalize o processo. 
                
   Alteracoes: 14/02/2012 - Tratar PAG0143R2 que ira substituir a PAG0106R2
                            (Diego). 
                            
               27/02/2012 - Tratamento novo catalogo de mensagens V. 3.05,
                            eliminadas mensagens STR0009R2, PAG0109R2, 
                            STR0009R1, PAG0109R1, PAG0106R2 (Gabriel).
                            
               10/04/2012 - Chamada da procedure grava-log-ted para os tipos de
                            mensagens: ENVIADO OK, ENVIADO NOK, REJEITADA OK,
                                       RECEBIDA OK, RECEBIDA NOK. (Fabricio)
               
               08/05/2012 - Incluida procedure processa_conta_transferida
                            para processamento doc/ted de conta transferida
                            entre cooperativas (Tiago).
                            
               08/06/2012 - Gravar devolucao com numero de documento da mensagem
                            original enviada pelo Legado. Na Rejeicao ja estava
                            fazendo isto (Diego).             
                            
               29/06/2012 - Ajuste Log TED (David).  
               
               30/07/2012 - Inclusão de novos parametros na procedure grava-log-ted
                            campos: cdagenci = 0, nrdcaixa = 0, 
                            cdoperad = "1" (Lucas R.).          
                            
               04/12/2012 - Incluir origem da mensagem no numero de controle
                            (Diego).  
                            
               28/01/2013 - Corrigido aux_nrdocmto para pegar ultimos 8 
                            caracteres do Numero de Controle das mensagens 
                            recebidas de outros bancos (Diego).                
                            
               18/03/2013 - Tratamento para recebimento da STR0026R2 - VR Boleto.
                            (Fabricio)
                            
               04/07/2013 - Ajustes na rotina de recebimento STR0026R2 referente
                            ao VR Boleto. (Rafael)
                            
               01/11/2013 - Aumento FORMAT campo aux_idprogra "zzzz9" (Diego).
               
               12/12/2013 - Tratamento na procedure processa_conta_transferida
                            para contas migradas Acredi >> Viacredi; geracao
                            de arquivo. (Fabricio)
                            
               07/01/2014 - Ajustado find da crapcob para utilizar indice (Daniel). 
               
               13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                            
               28/01/2014 - Alterado para utilizar b-crapdat.dtmvtolt
                            na geracao do arquivo de teds migradas. (Fabricio)
                            
               18/02/2014 - Alterado na procedure gera_logspb_transferida para
                            passar como conta do credito na chamada da
                            procedure grava-log-ted, o numero da conta na
                            cooperativa destino. (Fabricio)
                            
               21/03/2014 - Alterado o Format das contas migradas na procedure
                            gera_logspb_transferida. (Reinert)
                            
               20/05/2014 - Retirado criacao do registro de lote (fara apenas
                            leitura e atualizacao do registro criado
                            anteriormente; pelo crps531).
                            (Chamado 158826) - (Fabricio)
                            
               26/06/2014 - Desprezar estorno de TED de repasse de convenios.
                            (Fabricio - PRJ 019).
                            
               23/10/2014 - Incluir a hora no lancamento da craplcm 
                            (Jonata-RKAM).             
                            
               05/11/2014 - Mover mensagem para o /salvar e deletar objetos xml
                            criados, quando estorno de TED de repasse de
                            convenios (STR0007/STR0020). (Fabricio)
                            
               14/11/2014 - Alteração na procedure processa_conta_transferida 
                            para tratar a incormporação da CREDIMILSUL e 
                            ACREDI (Vanessa) SD SD223543
               
               17/11/2014 - Alteração do E-mail destino dos alertas de 
                            pagamentos de VR Boleto  (Kelvin)
                            
               03/12/2014 - Nao verificar data do sistema na cooperativa antiga
                            que foi incorporada (Diego).
                            
               08/01/2015 - Tratado para devolver mensagens que apresentem 
                            alguma inconsistencia, destinadas a coop. antiga 
                            incorporada. Estavam sendo geradas mensagens de 
                            devolucao ainda pela coop. antiga, porem as mesmas
                            nao eram integradas na Cabine, pois eram geradas
                            com a data da coop. antiga. A Cabine integra somente
                            mensagens do dia atual. Este tratamento eh valido
                            enquanto a coop. antiga permanecer ativa no nosso 
                            sistema(crapcop.flgativo = TRUE) (Diego).
                
               19/01/2015 - Adição dos parâmetros "arq" e "coop" na chamada do
                            fonte mqcecred_envia.pl. (Dionathan)
               13/04/2015 - Inclusão parametro na  procedure proc_opera_st para 
                            tratar as alterações solicitadas no SD271603 FDR041 
                            (Vanessa)
                                         
               26/05/2015 - Alterado para tratar mensagens de portabilidade de 
                            credito. (Reinert).
                            
               10/07/2015 - Validar se a cooperativa esta ativa no sistema,
                            crapcop.flgativo (Diego).             
               
               21/07/2015 - Alterações relacionadas ao Projeto Nova FOLHAIB (Vanessa). 
                            
               11/08/2015 - Ajustado proc. verifica_conta, adicionado verificacao 
                            caso conta seja migrada, fazer validacao da conta
                            nova. (Jorge/Rodrigo) - SD 308188
                                                                         
               18/09/2015 - Tratamento na procedure processa_conta_transferida
                            para contas migradas Viacredi >> Alto Vale
                            (Douglas - Chamado 288683)
                            
               22/10/2015 - Adicionado verificacao do cpf do TED com o cpf da
                            conta em proc. verifica_conta. 
                            (Jorge/Elton) - SD 338096

               29/10/2015 - Inclusao de verificacao estado de crise. 
                            (Jaison/Andrino)

               10/12/2015 - Ajustado a rotina importa_xml para substituir
                            o caracter especial chr(216) e chr(248) por "O"
                            pois caracter invalida o xml, fazendo que as informacoes
                            depois dessa tag sejam ignoradas. 
                            SD347591 (Odirlei-AMcom)

               08/01/2015 - Alterado procedimento pc_solicita_email para chamar
                            a rotina convertida na b1wgen0011.p 
                            SD356863 (Odirlei-AMcom)

               02/02/2016 - Adicionar tratamento para nao permitir realizar
                            TED/TEC das contas migradas ACREDI >> VIACREDI
                            (Douglas - Chamado 366322)

               11/05/2016 - Adicionar tratamento para nao permitir realizar
                            TED/TEC das contas migradas VIACREDI >> ALTO VALE
                            (Douglas - Chamado 406267)
                            
               30/05/2016 - Adicionar tipo de pessoa juridica na pesquisa de contas
                            da verifica_conta (Douglas - Chamado 406267)
               
			   05/07/2016 - Ajuste para considerar inpessoa > 1 ao validar contas
							juridicas (Adriano - SD 480514).
               
               
			   14/09/2016 - Ajuste para utilizar uma sequence na geracao do numero
			                de controle, garantindo sua unicidade
						   (Adriano - SD 518645).
    
	           01/12/2016 - Tratamento credito TED/TEC Transposul (Diego). 

			   05/01/2017 - Ajuste para retirada de caracterer especiais
							(Adriano - SD 556053)
							
             #######################################################
             ATENCAO!!! Ao incluir novas mensagens para recebimento, 
             lembrar de tratar a procedure gera_erro_xml.
             #######################################################
............................................................................ */

{ includes/var_batch.i  "NEW" }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen0046tt.i } 
{ sistema/generico/includes/b1wgen0002tt.i } 
{ sistema/generico/includes/b1wgen0084att.i }
{ includes/var_cobregis.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.
DEF STREAM str_2. /*  Para arquivo XML de erro  */ 
DEF STREAM str_3. /*  Para retirar caracteres especiais */

DEF TEMP-TABLE tt-descontar LIKE tt-titulos.
DEF TEMP-TABLE tt-erro-bo NO-UNDO LIKE craperr.

DEF TEMP-TABLE tt-conv-arq NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD dtmvtolt LIKE crapdat.dtmvtolt
    FIELD cdagenci LIKE crapage.cdagenci
    FIELD cdbccxlt LIKE craplot.cdbccxlt
    FIELD nrdolote LIKE craplot.nrdolote
    FIELD nrconven LIKE crapcco.nrconven
    INDEX tt-con-arq1 cdcooper nrconven.

/* Variaveis para controle da execucao em paralelo */
DEF VAR aux_idparale      AS INT                                    NO-UNDO.
DEF VAR aux_idprogra      AS INT                                    NO-UNDO.
DEF VAR h_paralelo        AS HANDLE                                 NO-UNDO.
DEF VAR h-b1wgen0011      AS HANDLE                                 NO-UNDO.

DEF VAR aux_nmarqori      AS CHAR                                   NO-UNDO.
DEF VAR aux_nmarquiv      AS CHAR                                   NO-UNDO.
DEF VAR aux_nmarqxml      AS CHAR                                   NO-UNDO.
DEF VAR aux_nmarqlog      AS CHAR                                   NO-UNDO.
DEF VAR aux_contador      AS INT                                    NO-UNDO.
DEF VAR aux_contado1      AS INT                                    NO-UNDO.
DEF VAR aux_contado2      AS INT                                    NO-UNDO.
DEF VAR aux_contlock      AS INT                                    NO-UNDO.
DEF VAR aux_dscritic      AS CHAR                                   NO-UNDO.
DEF VAR aux_des_erro      AS CHAR                                   NO-UNDO.
DEF VAR aux_textoxml      AS CHAR    EXTENT 20                      NO-UNDO.
DEF VAR aux_nrdocmto      AS DEC                                    NO-UNDO.
DEF VAR aux_nrctacre      AS INT                                    NO-UNDO.
DEF VAR aux_hsubnode      AS INT                                    NO-UNDO.
DEF VAR aux_msgderro      AS CHAR                                   NO-UNDO.
DEF VAR aux_dadosdeb      AS CHAR                                   NO-UNDO.
DEF VAR aux_codierro      AS INT                                    NO-UNDO.
DEF VAR aux_cdtiptrf      AS INT                                    NO-UNDO.
DEF VAR aux_msgdelog      AS CHAR                                   NO-UNDO.
DEF VAR aux_tplogerr      AS INT                                    NO-UNDO.
DEF VAR aux_dsarqenv      AS CHAR                                   NO-UNDO.
DEF VAR aux_nrdolote      AS INT  INIT 10115                        NO-UNDO.
DEF VAR aux_tplotmov      AS INT  INIT 1                            NO-UNDO.
DEF VAR aux_cdagenci      AS INT  INIT 1                            NO-UNDO.

DEF VAR aux_tagCABInf     AS LOGICAL                                NO-UNDO.
DEF VAR aux_NrOperacao    AS CHAR                                   NO-UNDO.
DEF VAR aux_CdLegado      AS CHAR                                   NO-UNDO.
DEF VAR aux_CodMsg        AS CHAR                                   NO-UNDO.
DEF VAR aux_NumCtrlIF     AS CHAR                                   NO-UNDO.
DEF VAR aux_NumCtrlRem    AS CHAR                                   NO-UNDO.
DEF VAR aux_CodDevTransf  AS CHAR                                   NO-UNDO.
DEF VAR aux_VlrLanc       AS CHAR                                   NO-UNDO.
DEF VAR aux_DtMovto       AS CHAR                                   NO-UNDO.
DEF VAR aux_ISPBIFDebtd   AS CHAR                                   NO-UNDO.
DEF VAR aux_BancoDeb      AS INT                                    NO-UNDO.
DEF VAR aux_AgDebtd       AS CHAR                                   NO-UNDO.
DEF VAR aux_CtDebtd       AS CHAR                                   NO-UNDO.
DEF VAR aux_CNPJ_CPFDeb   AS CHAR                                   NO-UNDO.
DEF VAR aux_NomCliDebtd   AS CHAR                                   NO-UNDO.
DEF VAR aux_ISPBIFCredtd  AS CHAR                                   NO-UNDO.
DEF VAR aux_BancoCre      AS INT                                    NO-UNDO.
DEF VAR aux_AgCredtd      AS CHAR                                   NO-UNDO.
DEF VAR aux_CtCredtd      AS CHAR                                   NO-UNDO.
DEF VAR aux_CNPJ_CPFCred  AS CHAR                                   NO-UNDO.
DEF VAR aux_CNPJ_CPFCred2 AS CHAR                                   NO-UNDO.
DEF VAR aux_NomCliCredtd  AS CHAR                                   NO-UNDO.
DEF VAR aux_NumCodBarras  AS CHAR                                   NO-UNDO.
DEF VAR aux_NUPortdd      AS CHAR                                   NO-UNDO.
DEF VAR aux_CodProdt      AS CHAR                                   NO-UNDO.  

DEF VAR aux_dtinispb      AS CHAR                                   NO-UNDO.                                              
DEF VAR aux_TpPessoaCred  AS CHAR                                   NO-UNDO.
DEF VAR aux_SitLanc       AS CHAR                                   NO-UNDO.
DEF VAR aux_nrispbif      AS INT                                    NO-UNDO.
DEF VAR aux_cddbanco      AS INT                                    NO-UNDO.
DEF VAR aux_nmdbanco      AS CHAR                                   NO-UNDO.
DEF VAR aux_msgrejei      AS CHAR                                   NO-UNDO.
DEF VAR aux_dsdehist      AS CHAR                                   NO-UNDO.
DEF VAR aux_descrica      AS CHAR                                   NO-UNDO.
DEF VAR aux_dsdircop      AS CHAR                                   NO-UNDO.

DEF VAR aux_nrconven      AS INT                                    NO-UNDO.
DEF VAR aux_nrdconta      AS INT                                    NO-UNDO.
DEF VAR aux_flgvenci      AS LOGI                                   NO-UNDO.
DEF VAR aux_vlrjuros      AS DECI                                   NO-UNDO.
DEF VAR aux_vlrmulta      AS DECI                                   NO-UNDO.
DEF VAR aux_vldescto      AS DECI                                   NO-UNDO.
DEF VAR aux_vlabatim      AS DECI                                   NO-UNDO.
DEF VAR aux_vlfatura      AS DECI                                   NO-UNDO.
DEF VAR aux_liqaposb      AS LOGI                                   NO-UNDO.
DEF VAR aux_cdbanpag      AS INT                                    NO-UNDO.
DEF VAR aux_dsmotivo      AS CHAR                                   NO-UNDO.
DEF VAR aux_nrretcoo      AS INT                                    NO-UNDO.
DEF VAR aux_cdageinc      AS INT                                    NO-UNDO.
DEF VAR aux_nrctremp      AS DECI                                   NO-UNDO.
DEF VAR aux_tpemprst      AS INT                                    NO-UNDO.
DEF VAR aux_qtregist      AS INTE                                   NO-UNDO.
DEF VAR aux_vlsldliq      AS DECI                                   NO-UNDO.

DEF VAR aux_cdcooper      AS INTE                                   NO-UNDO.
DEF VAR aux_dtintegr      AS DATE                                   NO-UNDO.
DEF VAR aux_flestcri      AS INTE                                   NO-UNDO.
DEF VAR aux_inestcri      AS INTE                                   NO-UNDO.

DEF VAR log_msgderro      AS CHAR                                   NO-UNDO. 
DEF VAR aux_flgderro      AS LOGICAL                                NO-UNDO.
DEF VAR aux_nrctrole      AS CHAR                                   NO-UNDO.
DEF VAR aux_flgcriti      AS LOG                                    NO-UNDO.
DEF VAR aux_flgrespo      AS INTE                                   NO-UNDO.
DEF VAR aux_nmlogprt      AS CHAR                                   NO-UNDO.

/*Variáveis da FOLHAIB*/
DEF VAR aux_flgopfin    AS LOGICAL                                  NO-UNDO.
DEF VAR aux_nrridlfp    LIKE craplcs.nrridlfp                       NO-UNDO.
DEF VAR aux_ponteiro    AS INT                                      NO-UNDO.
DEF VAR aux_dsmensag    AS CHAR                                     NO-UNDO.
DEF VAR aux_emaildes    AS CHAR                                     NO-UNDO.
DEF VAR b1wgen0011      AS HANDLE                                   NO-UNDO.

/* Variáveis utilizadas para receber clob da rotina no oracle */
DEF VAR xDoc          AS HANDLE   NO-UNDO.   
DEF VAR xRoot         AS HANDLE   NO-UNDO.  
DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
DEF VAR xField        AS HANDLE   NO-UNDO. 
DEF VAR xText         AS HANDLE   NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR NO-UNDO.

/*  Variaveis para importacao do XML */ 
DEF VAR hDoc              AS HANDLE                                 NO-UNDO.
DEF VAR hRoot             AS HANDLE                                 NO-UNDO.
DEF VAR hNode             AS HANDLE                                 NO-UNDO.
DEF VAR hSubNode          AS HANDLE                                 NO-UNDO.
DEF VAR hSubNode2         AS HANDLE                                 NO-UNDO.
DEF VAR hNameTag          AS HANDLE                                 NO-UNDO.
DEF VAR hTextTag          AS HANDLE                                 NO-UNDO.
DEF VAR hTextTag2         AS HANDLE                                 NO-UNDO.

DEF VAR b1wgen0046        AS HANDLE                                 NO-UNDO.
DEF VAR b1wgen0050        AS HANDLE                                 NO-UNDO.
DEF VAR h-b1wgen0089      AS HANDLE                                 NO-UNDO.
DEF VAR h-b1wgen0030      AS HANDLE                                 NO-UNDO.
DEF VAR h-b1wgen0002      AS HANDLE                                 NO-UNDO.
DEF VAR h-b1wgen0136      AS HANDLE                                 NO-UNDO.
DEF VAR h-b1wgen0043      AS HANDLE                                 NO-UNDO.
DEF VAR h-b1wgen0171      AS HANDLE                                 NO-UNDO.
DEF VAR h-b1wgen0084a     AS HANDLE                                 NO-UNDO.

/* Buffers para as cooperativas de destino */
DEF BUFFER crabcop FOR crapcop.
DEF BUFFER crabdat FOR crapdat.
DEF BUFFER crablot FOR craplot.
DEF BUFFER b-craplot FOR craplot. /* Credito conta corrente Portabilidade */
DEF BUFFER b-crabcop FOR crapcop. /* Portabilidade */ 
DEF BUFFER b-crabdat FOR crapdat. /* Portabilidade */ 
DEF BUFFER m-crabcop FOR crapcop. /* Incorporacao */

DEFINE TEMP-TABLE crawarq                                           NO-UNDO
       FIELD nrsequen AS INTEGER
       FIELD nmarquiv AS CHAR
       INDEX crawarq1 AS PRIMARY
             nrsequen nmarquiv.

DEF TEMP-TABLE tt-estado-crise                                      NO-UNDO
    FIELD cdcooper AS INTE
    FIELD dtintegr AS DATE
    FIELD inestcri AS INTE.

ASSIGN glb_cdprogra = "crps531"
       glb_cdcooper = 3.  /*CECRED*/

/* INICIO DO ESTADO DE CRISE */

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

/* Efetuar a chamada a rotina Oracle */
RUN STORED-PROCEDURE pc_estado_crise
aux_handproc = PROC-HANDLE NO-ERROR (INPUT "S"              /* Identificador para verificar processo (N – Nao / S – Sim) */
                                    ,OUTPUT 0               /* Identificador estado de crise (0 - Nao / 1 - Sim) */
                                    ,OUTPUT ?).             /* XML com informacoes das cooperativas */

/* Fechar o procedimento para buscarmos o resultado */ 
CLOSE STORED-PROC pc_estado_crise
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

ASSIGN aux_flestcri = 0
       aux_flestcri = pc_estado_crise.pr_inestcri
                      WHEN pc_estado_crise.pr_inestcri <> ?.

/* Se estiver em estado de crise */
IF  aux_flestcri > 0  THEN
    DO:
        CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
        CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
        CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
        CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
        CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

        /* Buscar o XML na tabela de retorno da procedure Progress */ 
        ASSIGN xml_req = pc_estado_crise.pr_clobxmlc.
        
        /* Efetuar a leitura do XML*/ 
        SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
        PUT-STRING(ponteiro_xml,1) = xml_req. 
         
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
        xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
        DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        
            xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
            IF xRoot2:SUBTYPE <> "ELEMENT"   THEN 
             NEXT. 
        
            IF xRoot2:NUM-CHILDREN > 0 THEN
               CREATE tt-estado-crise.
        
            DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
            
                xRoot2:GET-CHILD(xField,aux_cont).
                    
                IF xField:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 
                
                xField:GET-CHILD(xText,1).                   
        
                ASSIGN aux_cdcooper = INTE(xText:NODE-VALUE) WHEN xField:NAME = "cdcooper"
                       aux_dtintegr = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtintegr"
                       aux_inestcri = INTE(xText:NODE-VALUE) WHEN xField:NAME = "inestcri".   
            END.            
        
            ASSIGN tt-estado-crise.cdcooper = aux_cdcooper
                   tt-estado-crise.dtintegr = aux_dtintegr
                   tt-estado-crise.inestcri = aux_inestcri.
        END.                
        
        SET-SIZE(ponteiro_xml) = 0. 
        
        DELETE OBJECT xDoc. 
        DELETE OBJECT xRoot. 
        DELETE OBJECT xRoot2. 
        DELETE OBJECT xField. 
        DELETE OBJECT xText.
    END.

/* FIM DO ESTADO DE CRISE */

/* recebe os parametros de sessao (criterio de separacao) ***/
ASSIGN aux_idparale = INT(ENTRY(1,SESSION:PARAMETER))
       aux_idprogra = INT(ENTRY(2,SESSION:PARAMETER)) 
       aux_nmarquiv = ENTRY(3,SESSION:PARAMETER).     

/* Cooperativa - CECRED */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         ASSIGN glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RUN finaliza_paralelo.
         QUIT.
     END. 

/* Data - CECRED */
FIND crapdat WHERE crapdat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
IF   NOT AVAIL crapdat THEN 
     DO:
         ASSIGN glb_cdcritic = 1.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  + 
                           glb_dscritic + " >> log/proc_batch.log").
         RUN finaliza_paralelo.
         QUIT.
     END. 
     
ASSIGN aux_contador = 0
       glb_dtmvtolt = crapdat.dtmvtolt
       glb_dtmvtopr = crapdat.dtmvtopr.

/* Reseta as variaveis */
ASSIGN aux_dtintegr = glb_dtmvtolt
       aux_inestcri = 0.

INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.
                   
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   IMPORT STREAM str_1 UNFORMATTED aux_nmarquiv.

   ASSIGN aux_contador = aux_contador + 1.
   
   CREATE crawarq.
   ASSIGN crawarq.nrsequen = aux_contador
          crawarq.nmarquiv = aux_nmarquiv.
          
END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.
   
FOR EACH crawarq NO-LOCK BY crawarq.nrsequen:
    
    /**  Objetos utilizados na leitura do XML  **/
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF  hRoot.
    CREATE X-NODEREF  hNode. 
    CREATE X-NODEREF  hSubNode. 
    CREATE X-NODEREF  hSubNode2.
    CREATE X-NODEREF  hNameTag.
    CREATE X-NODEREF  hTextTag.
    CREATE X-NODEREF  hTextTag2.
    
    ASSIGN aux_CodMsg        = ""
           aux_NrOperacao    = ""
           aux_NumCtrlRem    = "" 
           aux_NumCtrlIF     = ""
           aux_ISPBIFDebtd   = ""
           aux_BancoDeb      = 0
           aux_AgDebtd       = "" 
           aux_CtDebtd       = ""
           aux_CNPJ_CPFDeb   = ""
           aux_NomCliDebtd   = ""
           aux_ISPBIFCredtd  = ""
           aux_BancoCre      = 0
           aux_AgCredtd      = ""
           aux_CtCredtd      = ""
           aux_CNPJ_CPFCred  = ""
           aux_CNPJ_CPFCred2 = ""
           aux_NomCliCredtd  = ""
           aux_TpPessoaCred  = ""
           aux_CodDevTransf  = ""
           aux_VlrLanc       = ""
           aux_DtMovto       = ""
           aux_SitLanc       = ""
           aux_dadosdeb      = ""
           aux_codierro      = 0
           aux_tagCABInf     = FALSE
           aux_nrctacre      = 0
           aux_nrdocmto      = 0
           aux_tplogerr      = 0
           aux_nmarqxml      = SUBSTRING(crawarq.nmarquiv,
                               R-INDEX(crawarq.nmarquiv,"/") + 1)
           aux_flgderro      = FALSE
           aux_nrctrole      = ""
           aux_cdageinc      = 0  /* Agencia antiga incorporada */
           aux_nrctremp      = 0
           aux_tpemprst      = 2
           aux_qtregist      = 0
           aux_vlsldliq      = 0.
                              
    EMPTY TEMP-TABLE tt-situacao-if.   

    RUN importa_xml.
    
    IF   RETURN-VALUE = "NOK"  THEN
         DO:    
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - "
                               + glb_cdprogra + "' --> '"
                               + "Erro ao descriptografar arquivo."
                                   + " >> log/proc_batch.log").
             RUN deleta_objetos.
             NEXT.
         END.
             
    /* Se o xml conter a TAG <CABInfSituacao>, pode ser mensagem com erro de
       inconsistencia de dados (STR0005E,STR0008E,STR0037E,PAG0107E,PAG0108E,
       PAG0137E) ou mensagen de controle da JD.
       No caso da TAG <CABInfCancelamento, a mensagem refere-se a uma rejeicao
       gerada pela Cabine. Todas sao mensagens de retorno ref. alguma mensagem 
       enviada pela cooperativa */
    
    IF   aux_tagCABInf THEN   
         DO:         
             /* Busca cooperativa da destino */
             FIND crabcop WHERE 
                  crabcop.cdagectl = INT(SUBSTRING(aux_NumCtrlIF,8,4)) 
                  NO-LOCK NO-ERROR.

             IF   AVAIL crabcop   THEN
                  DO:
                      IF  aux_flestcri > 0  THEN
                      DO:
                          FIND tt-estado-crise WHERE tt-estado-crise.cdcooper = crabcop.cdcooper
                                               NO-LOCK NO-ERROR.
                          IF  AVAIL tt-estado-crise THEN
                              DO:
                                 ASSIGN aux_dtintegr = tt-estado-crise.dtintegr
                                        aux_inestcri = tt-estado-crise.inestcri.
                              END.
                      END.
                      /* Se nao estiver em estado de crise verifica processo */
                      RUN verifica_processo_crise.
                      IF   RETURN-VALUE <> "OK"   THEN
                           NEXT.

                      IF  aux_CodMsg <> ""  THEN   
                          DO:
                              IF  aux_CodMsg MATCHES "*E" THEN   
                                  DO:
                                      ASSIGN log_msgderro = "Inconsistencia " +
                                                            "dados: " +
                                                            aux_msgderro + ".".
                                                   
                                      RUN gera_logspb (INPUT "REJEITADA OK",
                                                       INPUT log_msgderro,
                                                       INPUT TIME). 
                                  END.
                              ELSE
                                  DO: 
                                      /** Rejeitada pela Cabine. Vem com mesmo
                                          CodMsg da mensagem gerada pela
                                          cooperativa **/ 
                                      RUN trata_lancamentos.
                                      NEXT.
                                  END.
                          END.
                      ELSE
                           RUN gera_logspb (INPUT "RETORNO JD OK",
                                            INPUT "",
                                            INPUT TIME).
                  END.
             ELSE
                  DO:
                      RUN verifica_processo.

                      IF   RETURN-VALUE <> "OK"   THEN
                           NEXT.

                      /* CECRED */ 
                      RUN trata_cecred (INPUT SUBSTRING(aux_NumCtrlIF,8,4)).
                  END.      
                                         
             RUN salva_arquivo.                         
             RUN deleta_objetos.      
             NEXT.
         END.      

    /* Verifica as Mensagens de Recebimento */     
    IF  NOT(CAN-DO
        ("PAG0101," +     /* Situacao IF */

         "STR0018,STR0019," +  /* Exclusao/Inclusao IF */  
        
         "STR0005R2,STR0007R2,STR0008R2,PAG0107R2," +
         "PAG0108R2,PAG0143R2," +     /* TED */

         "STR0037R2,PAG0137R2," +     /* TEC */
         
         "STR0010R2,PAG0111R2," +     /* Devolucao TED/TEC enviado com erro */
                   
         "STR0004R1,STR0005R1,STR0008R1,STR0037R1," + 
         "PAG0107R1,PAG0108R1,PAG0137R1," + /* Confirma envio */
         "STR0010R1,PAG0111R1," + /*Confirma devolucao enviada*/
         "STR0026R2," + /* Recebimento VR Boleto */
         "STR0047R1,STR0048R1,STR0047R2",aux_CodMsg)) THEN /* Portabilidade de Credito */
         DO:
             
             RUN verifica_processo.

             IF   RETURN-VALUE <> "OK"   THEN
                  NEXT.

             /* CECRED */
             RUN trata_cecred (INPUT "").
             RUN salva_arquivo.                   
             RUN deleta_objetos.
             NEXT.         
         END.

    /* VR Boleto */
    IF  CAN-DO("STR0026R2",aux_CodMsg) THEN
         DO:
             
             /* Trazer arquivo de log mqcecred_processa */
             RUN log_mqcecred.

             /* Se nao estiver em estado de crise verifica processo */
             RUN verifica_processo_crise.

             IF  RETURN-VALUE <> "OK" THEN
                 NEXT.

             ASSIGN aux_nrconven = INT(SUBSTR(aux_NumCodBarras, 20, 6))
                    aux_nrdconta = INT(SUBSTR(aux_NumCodBarras, 26, 8))
                    aux_nrdocmto = INT(SUBSTR(aux_NumCodBarras, 34, 9)).

             FOR EACH crabcop NO-LOCK:

                 FIND crapcco WHERE crapcco.cdcooper = crabcop.cdcooper AND
                                    crapcco.nrconven = aux_nrconven     AND
                                    crapcco.dsorgarq <> "MIGRACAO"
                                    NO-LOCK NO-ERROR.

                 IF AVAIL crapcco THEN
                     LEAVE.

             END.
             

             IF  NOT AVAIL crapcco THEN
             DO:
                 /* enviar mensagem STR0010 */
                 ASSIGN aux_codierro = 2
                        aux_dsdehist = "Convenio do VR Boleto nao encontrado.".
  
                 RUN gera_erro_xml (INPUT aux_dsdehist).
                 RUN salva_arquivo.
                 RUN deleta_objetos.

                 NEXT.
             END.

             FIND crapcob WHERE crapcob.cdcooper = crapcco.cdcooper AND
                                crapcob.cdbandoc = crapcco.cddbanco AND
                                crapcob.nrdctabb = crapcco.nrdctabb AND
                                crapcob.nrcnvcob = crapcco.nrconven AND
                                crapcob.nrdconta = aux_nrdconta     AND
                                crapcob.nrdocmto = aux_nrdocmto
                                NO-LOCK NO-ERROR.

             IF NOT AVAIL crapcob THEN
             DO:
                 /* enviar mensagem STR0010 */
                ASSIGN aux_codierro = 2
                       aux_dsdehist = "VR Boleto nao encontrado.".

                RUN gera_erro_xml (INPUT aux_dsdehist).
                RUN salva_arquivo.
                RUN deleta_objetos.

                NEXT.
             END.

             IF  aux_flestcri > 0  THEN
                 DO:
                     FIND tt-estado-crise WHERE tt-estado-crise.cdcooper = crapcob.cdcooper
                                          NO-LOCK NO-ERROR.
                         IF  AVAIL tt-estado-crise THEN
                         DO:
                            ASSIGN aux_dtintegr = tt-estado-crise.dtintegr
                                   aux_inestcri = tt-estado-crise.inestcri.
                         END.
                 END.

             IF  crapcob.incobran = 5 THEN
                 DO:
                     /* enviar mensagem STR0010 */
                    ASSIGN aux_codierro = 2
                           aux_dsdehist = "VR Boleto ja foi pago.".

                    RUN gera_erro_xml (INPUT aux_dsdehist).
                    RUN salva_arquivo.
                    RUN deleta_objetos.

                    NEXT.
                 END.

             /* variaveis de calculo para juros/multa */ 
             ASSIGN aux_vlrjuros = 0
                    aux_vlrmulta = 0
                    aux_vldescto = 0
                    aux_vlabatim = crapcob.vlabatim
                    aux_vlfatura = crapcob.vltitulo.

             /* Calcula juros caso o titulo esteja vencido */
             RUN verifica-vencimento-titulo(INPUT crapcob.cdcooper,
                                            INPUT crapcob.dtvencto,
                                           OUTPUT aux_flgvenci).

             /* calculo de abatimento deve ser antes da aplicacao de 
                juros e multa */
             IF aux_vlabatim > 0 THEN
                ASSIGN aux_vlfatura = aux_vlfatura - aux_vlabatim.

             /* trata o desconto */
             /* se concede apos o vencimento */
             IF  (crapcob.cdmensag = 2)  THEN
                ASSIGN aux_vldescto = crapcob.vldescto
                       aux_vlfatura = aux_vlfatura - aux_vldescto.

             /* verifica se o titulo esta vencido */
             IF  aux_flgvenci  THEN
             DO:
                /* MULTA PARA ATRASO */
                IF  crapcob.tpdmulta = 1  THEN /* Valor */
                    ASSIGN aux_vlrmulta = crapcob.vlrmulta
                           aux_vlfatura   = aux_vlfatura + aux_vlrmulta.
                ELSE
                IF  crapcob.tpdmulta = 2  THEN /* % de multa do valor  do boleto */
                    ASSIGN aux_vlrmulta = (crapcob.vlrmulta * aux_vlfatura) / 100
                           aux_vlfatura   = aux_vlfatura + aux_vlrmulta.

                /* MORA PARA ATRASO */
                IF  crapcob.tpjurmor = 1  THEN /* dias */
                    ASSIGN aux_vlrjuros = crapcob.vljurdia * (aux_dtintegr - crapcob.dtvencto)
                           aux_vlfatura = aux_vlfatura + aux_vlrjuros.
                ELSE
                IF  crapcob.tpjurmor = 2  THEN /* mes */
                    ASSIGN aux_vlrjuros = (crapcob.vltitulo * 
                                          ((crapcob.vljurdia / 100) / 30) * 
                                           (aux_dtintegr - crapcob.dtvencto))
                           aux_vlfatura = aux_vlfatura + aux_vlrjuros.
               
             END.
             ELSE
             DO:
                /* se concede apos vencto, ja calculou */
                IF  crapcob.cdmensag <> 2  THEN
                    ASSIGN aux_vldescto = crapcob.vldescto
                           aux_vlfatura = aux_vlfatura - aux_vldescto.
             END.

             IF (crapcob.incobran = 3 AND
                (crapcob.insitcrt = 0 OR crapcob.insitcrt = 1)) THEN
                ASSIGN aux_liqaposb = TRUE.

             RUN sistema/generico/procedures/b1wgen0089.p
             PERSISTENT SET h-b1wgen0089.

             IF  NOT VALID-HANDLE (h-b1wgen0089)  THEN
             DO:
                UNIX SILENT VALUE("echo " + 
                                   STRING(TIME,"HH:MM:SS") + " - "
                                   + glb_cdprogra + "' --> '"
                                   + "Handle invalido para b1wgen0089."
                                   + " >> log/proc_batch.log").
                                   
                RUN deleta_objetos.
                NEXT.
             END.

             FIND FIRST crapban WHERE crapban.nrispbif = INT(aux_ISPBIFDebtd)
                                                   NO-LOCK NO-ERROR.
             
             IF NOT AVAIL crapban THEN
             DO:
                 /* enviar mensagem STR0010 */
                 ASSIGN aux_codierro = 2
                        aux_dsdehist = "Agencia nao encontrada.".

                 RUN gera_erro_xml (INPUT aux_dsdehist).

                 RUN salva_arquivo.
                 RUN deleta_objetos.

                 NEXT.
             END.

             ASSIGN aux_cdbanpag = crapban.cdbccxlt
                    aux_dsmotivo = "04". /* compensacao eletronica */

             /* se não for liquidacao de titulo já pago, então liq normal */
             IF NOT aux_liqaposb THEN
                RUN proc-liquidacao IN h-b1wgen0089 
                      (INPUT ROWID(crapcob),
                       INPUT 0, /* nrnosnum */ 
                       INPUT aux_cdbanpag,
                       INPUT INT(aux_AgDebtd),
                       INPUT crapcob.vltitulo,
                       INPUT 0, /* vlliquid */
                       INPUT aux_VlrLanc,
                       INPUT 0,
                       INPUT aux_vldescto + aux_vlabatim,
                       INPUT aux_vlrjuros + aux_vlrmulta,
                       INPUT 0,
                       INPUT 0,
                       INPUT aux_dtintegr,
                       INPUT aux_dtintegr,
                       INPUT 6, /* cdocorre */
                       INPUT aux_dsmotivo,
                       INPUT aux_dtintegr,
                       INPUT "1",
                       INPUT 0, /* compe */
                       INPUT aux_inestcri,
                      OUTPUT aux_nrretcoo,
                      OUTPUT glb_cdcritic,
                      INPUT-OUTPUT TABLE tt-lcm-consolidada,
                      INPUT-OUTPUT TABLE tt-descontar)
                      NO-ERROR.
             ELSE
                RUN proc-liquidacao-apos-bx IN h-b1wgen0089 
                      (INPUT ROWID(crapcob),
                       INPUT 0, /* nrnosnum */ 
                       INPUT aux_cdbanpag,
                       INPUT INT(aux_AgDebtd),
                       INPUT crapcob.vltitulo,
                       INPUT 0, /* vlliquid */
                       INPUT aux_VlrLanc,
                       INPUT 0,
                       INPUT aux_vldescto + aux_vlabatim,
                       INPUT 0 /* juros + multa */,
                       INPUT 0,
                       INPUT 0,
                       INPUT aux_dtintegr,
                       INPUT aux_dtintegr,
                       INPUT 17, /* cdocorre */
                       INPUT aux_dsmotivo,
                       INPUT aux_dtintegr,
                       INPUT "1",
                       INPUT 0, /* compe */
                       INPUT aux_inestcri,
                      OUTPUT aux_nrretcoo,
                      OUTPUT glb_cdcritic,
                      INPUT-OUTPUT TABLE tt-lcm-consolidada)
                      NO-ERROR.

            IF  ERROR-STATUS:ERROR THEN
                DO:
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + glb_cdprogra + "' --> '"  +
                                      ERROR-STATUS:GET-MESSAGE(1) + 
                                      " >> " + aux_nmarqlog).
                    RUN salva_arquivo.
                    RUN deleta_objetos.
                    NEXT.
                END.

             /* controle para lancamento consolidado na conta corrente */
             IF  NOT CAN-FIND (tt-conv-arq WHERE 
                               tt-conv-arq.cdcooper = crapcco.cdcooper AND
                               tt-conv-arq.nrconven = crapcco.nrconven) THEN
             DO:
                CREATE tt-conv-arq.
                ASSIGN tt-conv-arq.cdcooper = crapcco.cdcooper
                       tt-conv-arq.dtmvtolt = aux_dtintegr
                       tt-conv-arq.cdagenci = crapcco.cdagenci
                       tt-conv-arq.cdbccxlt = crapcco.cdbccxlt
                       tt-conv-arq.nrdolote = crapcco.nrdolote
                       tt-conv-arq.nrconven = crapcco.nrconven.
             END.

             /** Realiza os Lancamentos na conta do cooperado */
             FOR EACH tt-conv-arq NO-LOCK:
                 
                RUN realiza-lancto-cooperado
                            IN h-b1wgen0089 (INPUT tt-conv-arq.cdcooper,
                                             INPUT tt-conv-arq.dtmvtolt,
                                             INPUT tt-conv-arq.cdagenci,
                                             INPUT tt-conv-arq.cdbccxlt,
                                             INPUT tt-conv-arq.nrdolote,
                                             INPUT tt-conv-arq.nrconven,
                                             INPUT TABLE tt-lcm-consolidada).

                IF  RETURN-VALUE = "NOK" THEN
                    DO:
                        IF  VALID-HANDLE(h-b1wgen0089) THEN
                            DELETE PROCEDURE h-b1wgen0089.

                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '"  +
                                          "Erro ao creditar cooperado" + 
                                          " >> " + aux_nmarqlog).
                        RUN salva_arquivo.
                        RUN deleta_objetos.
                        NEXT.
                    END.
             END.

             IF  VALID-HANDLE(h-b1wgen0089) THEN
                DELETE PROCEDURE h-b1wgen0089.
             
             /* realiza liquidacao dos titulos descontados (se houver) */
             FOR EACH tt-descontar NO-LOCK BREAK BY tt-descontar.nrdconta:

                CREATE tt-titulos.
                BUFFER-COPY tt-descontar TO tt-titulos.

                IF  LAST-OF(tt-descontar.nrdconta)  THEN
                DO:

                    RUN sistema/generico/procedures/b1wgen0030.p
                        PERSISTENT SET h-b1wgen0030.
                    
                    IF  NOT VALID-HANDLE(h-b1wgen0030) THEN
                        DO:
                            UNIX SILENT VALUE("echo " + 
                                               STRING(TIME,"HH:MM:SS") + " - "
                                               + glb_cdprogra + "' --> '"
                                               + "Handle invalido para b1wgen0030."
                                               + " >> log/proc_batch.log").

                            RUN salva_arquivo.
                            RUN deleta_objetos.
                            NEXT.
                        END.   


                    RUN efetua_baixa_titulo IN h-b1wgen0030
                                             (INPUT glb_cdcooper,
                                              INPUT 0,   /* agencia */
                                              INPUT 0,   /* nro-caixa */  
                                              INPUT 0,   /* operador */
                                              INPUT aux_dtintegr, 
                                              INPUT 1, /* aux_idorigem = 1 AYLLOS */
                                              INPUT tt-descontar.nrdconta,
                                              INPUT 1,  
                                              INPUT TABLE  tt-titulos,
                                             OUTPUT TABLE tt-erro-bo).

                    IF  VALID-HANDLE(h-b1wgen0030) THEN
                        DELETE PROCEDURE h-b1wgen0030.

                    EMPTY TEMP-TABLE tt-titulos.

                END. /* IF  LAST-OF(tt-descontar.nrdconta) */

             END. /* Final baixa de titulos com desconto (FOR EACH tt-descontar) */

             RUN salva_arquivo.
             RUN deleta_objetos.
             NEXT.

         END. /* Fim tratamento VR Boleto */
                                            
    /* Trata IFs operantes no SPB */ 
    
    IF   CAN-DO("PAG0101,STR0018,STR0019",aux_CodMsg)   THEN
         DO:
             
             RUN sistema/generico/procedures/b1wgen0046.p
                 PERSISTENT SET b1wgen0046.
                                     
             IF  NOT VALID-HANDLE (b1wgen0046)  THEN
                 DO:
                     UNIX SILENT VALUE("echo " + 
                                       STRING(TIME,"HH:MM:SS") + " - "
                                       + glb_cdprogra + "' --> '"
                                       + "Handle invalido para h-b1wgen0046."
                                       + " >> log/proc_batch.log").
                                       
                     RUN deleta_objetos.
                     NEXT.
                 END.

             /* Trazer arquivo de log mqcecred_processa */
             RUN log_mqcecred.

             IF   aux_CodMsg = "PAG0101"  THEN
                  DO:
                    IF CAPS(aux_CodProdt) = "TED" THEN
                      DO:
                          RUN proc_pag0101 IN b1wgen0046 (INPUT glb_cdprogra,
                                                          INPUT aux_nmarqxml,
                                                          INPUT aux_nmarqlog,
                                                          INPUT TABLE tt-situacao-if).
                                                          
                          IF  RETURN-VALUE = "OK"  THEN
                              RUN gera_logspb (INPUT "PAG0101",
                                               INPUT "",
                                               INPUT TIME).
                      END.
             ELSE
                  DO:
                         RUN salva_arquivo.
                         RUN deleta_objetos.
                         NEXT.
                      END.
                    END.
             ELSE
                  DO:
                 
                    aux_dtinispb = SUBSTR(aux_dtinispb, 9, 2) + "/" + SUBSTR(aux_dtinispb, 6, 2) + "/" + SUBSTR(aux_dtinispb, 1, 4).
                    RUN proc_opera_str IN b1wgen0046 (INPUT glb_cdprogra,
                                                      INPUT aux_nmarqxml,
                                                      INPUT aux_nmarqlog,
                                                      INPUT aux_CodMsg,
                                                      INPUT aux_nrispbif,
                                                      INPUT aux_cddbanco,
                                                      INPUT aux_nmdbanco,
                                                      INPUT aux_dtinispb).
                  
                      IF   RETURN-VALUE = "OK"  THEN
                           DO:
                               IF  aux_CodMsg = "STR0018"  THEN
                                   RUN gera_logspb (INPUT "SPB-STR-IF",
                                                    INPUT "Exclusao IF STR",
                                                    INPUT TIME).
                               ELSE
                                   RUN gera_logspb (INPUT "SPB-STR-IF",
                                                    INPUT "Inclusao IF STR",
                                                    INPUT TIME).
                           END.
                  END.
                  
             IF VALID-HANDLE(b1wgen0046) THEN
                DELETE PROCEDURE b1wgen0046.
             
             RUN salva_arquivo.
             RUN deleta_objetos.
             NEXT.
         END.

    /* Verifica se cooperativa de destino eh valida */
    IF   aux_CodMsg MATCHES "*R1"  OR  CAN-DO("STR0010R2,PAG0111R2",aux_CodMsg) THEN
         DO:       
             INT(SUBSTRING(aux_NumCtrlIF,8,4)) NO-ERROR.  /* Agencia */

             IF   ERROR-STATUS:ERROR   THEN   /* Caracter invalido */ 
                  ASSIGN aux_flgderro = TRUE.
             ELSE
                  DO: /* Busca cooperativa de destino */
                      FIND crabcop WHERE 
                           crabcop.cdagectl = INT(SUBSTR(aux_NumCtrlIF,8,4))
                           NO-LOCK NO-ERROR.

                      IF   NOT AVAIL crabcop   THEN
                           ASSIGN aux_flgderro = TRUE.
                  END.
                       
             IF   aux_flgderro  THEN
                  DO:
                      RUN verifica_processo.

                      IF   RETURN-VALUE <> "OK"   THEN
                           NEXT.

                      /* CECRED */
                      RUN trata_cecred (INPUT SUBSTRING(aux_NumCtrlIF,8,4)).                      
                      RUN salva_arquivo.                   
                      RUN deleta_objetos.
                      NEXT.
                  END.
         END.
    ELSE
         DO:
             INT(aux_AgCredtd) NO-ERROR.

             IF   ERROR-STATUS:ERROR   THEN   /* Caracter invalido */ 
                  ASSIGN aux_flgderro = TRUE. 
             ELSE
                  /* Busca cooperativa de destino */ 
                  FIND crabcop WHERE crabcop.cdagectl = INT(aux_AgCredtd)  AND
                                     crabcop.flgativo = TRUE
                                     NO-LOCK NO-ERROR.
                                        
             IF   NOT AVAIL crabcop   THEN
			      DO:
				      /* Tratamento incorporacao TRANSULCRED */ 
                      IF   INT(aux_AgCredtd) = 116 and
					       TODAY < 03/21/2017 THEN   /* Data de corte */ 
						   DO:
                               ASSIGN aux_cdageinc = INT(aux_AgCredtd)
                                      aux_AgCredtd = "0108".

							   /* Busca cooperativa de destino (nova) */ 
                               FIND crabcop WHERE crabcop.cdagectl = INT(aux_AgCredtd)
							        NO-LOCK NO-ERROR.
					       END.		    
				      ELSE
					       ASSIGN aux_flgderro = TRUE.
				  END.
             
             IF  aux_flestcri > 0  THEN
                 DO:
                     FIND tt-estado-crise WHERE tt-estado-crise.cdcooper = crabcop.cdcooper
                                          NO-LOCK NO-ERROR.
                     IF  AVAIL tt-estado-crise THEN
                         DO:
                            ASSIGN aux_dtintegr = tt-estado-crise.dtintegr
                                   aux_inestcri = tt-estado-crise.inestcri.
                         END.
                 END.
             
             /*** IFs incorporadas foram desativadas(crapcop.flgativo = FALSE)
             ELSE
                  DO:
                      /* Tratamento incorporacao CONCREDI e CREDIMILSUL */ 
                      IF   INT(aux_AgCredtd) = 103 THEN 
                           ASSIGN aux_cdageinc = INT(aux_AgCredtd)
                                  aux_AgCredtd = "0101"
                                  aux_nrctainc = INT(aux_CtCredtd).
                      ELSE
                      IF   INT(aux_AgCredtd) = 114 THEN
                           ASSIGN aux_cdageinc = INT(aux_AgCredtd)
                                  aux_AgCredtd = "0112"
                                  aux_nrctainc = INT(aux_CtCredtd).
                                  
                      /* Busca cooperativa de destino */ 
                      FIND crabcop WHERE crabcop.cdagectl = INT(aux_AgCredtd)
                                         NO-LOCK NO-ERROR.

                  END.
             **************************************************************/
             
             IF   aux_flgderro  THEN
                  DO:                        
                      RUN verifica_processo.

                      IF   RETURN-VALUE <> "OK"   THEN 
                           NEXT.

                      RUN trata_cecred (INPUT aux_AgCredtd).
                      RUN salva_arquivo.
                      RUN deleta_objetos.
                      NEXT.
                  END.
             ELSE 
                  DO:               
                      RUN verifica_processo.
                        
                      IF   RETURN-VALUE <> "OK"   THEN
                           NEXT.
                 
                      ASSIGN aux_dsdehist = "".
                      
                      /* Verifica se a conta eh valida */ 
                      RUN verifica_conta.
                       
                     
                      IF  aux_codierro <> 0  THEN
                          DO:                       
                              /* Busca data do sistema */ 
                              FIND FIRST crabdat WHERE 
                                         crabdat.cdcooper = crabcop.cdcooper  
                                         NO-LOCK NO-ERROR.

                              IF   NOT AVAIL crabdat THEN 
                                   DO:
                                       ASSIGN glb_cdcritic = 1.
                                       RUN fontes/critic.p.
                                       UNIX SILENT VALUE("echo " +
                                                         STRING(TIME,"HH:MM:SS") +
                                                         " - " + glb_cdprogra + 
                                                         "' --> '"  + 
                                                         glb_dscritic + 
                                                         " >> log/proc_batch.log").
                                       RUN deleta_objetos.
                                       NEXT.
                                   END.
                              
                              /* Cria registro da mensagem recebida com ERRO */
                              RUN cria_gnmvcen (INPUT crabcop.cdagectl,
                                                INPUT crabdat.dtmvtolt,
                                                INPUT aux_CodMsg,
                                                INPUT "C", 
                                                INPUT DEC(aux_VlrLanc)).
             
                              FIND craptab WHERE 
                                   craptab.cdcooper = 0            AND
                                   craptab.nmsistem = "CRED"       AND
                                   craptab.tptabela = "GENERI"     AND
                                   craptab.cdempres = 0            AND
                                   craptab.cdacesso = "CDERROSSPB" AND
                                   craptab.tpregist = aux_codierro
                                   NO-LOCK NO-ERROR.
                                
                              IF   AVAIL craptab THEN
                                   ASSIGN log_msgderro = craptab.dstextab.

                              RUN gera_erro_xml (INPUT aux_dsdehist).

                              RUN salva_arquivo.
                              RUN deleta_objetos.
                              NEXT.
                          END.
                  END.
         END.
    
    IF   aux_CodMsg  MATCHES "*R1"  THEN  /* Confirmacao */
         DO:        
             /* Busca data do sistema */ 
             FIND FIRST crabdat WHERE crabdat.cdcooper = crabcop.cdcooper  
                                      NO-LOCK NO-ERROR.

             IF   NOT AVAIL crabdat THEN 
                  DO:
                     ASSIGN glb_cdcritic = 1.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " +
                                       STRING(TIME,"HH:MM:SS") + 
                                       " - " + glb_cdprogra + 
                                       "' --> '"  + glb_dscritic + 
                                       " >> log/proc_batch.log").
                     RUN deleta_objetos.
                     NEXT.
                  END.            

             /* Passar para o o proximo  quando processo estiver rodando */ 
             RUN verifica_processo.

             IF   RETURN-VALUE <> "OK"   THEN
                  NEXT.
        
             /* Cria registro das movimentacoes no SPB */
             RUN cria_gnmvcen (INPUT crabcop.cdagectl,
                               INPUT crabdat.dtmvtolt,
                               INPUT aux_CodMsg,
                               INPUT " ",
                               INPUT 0).

             /* Nao gravamos o Numero de Controle das mensagens de 
                devolucao(STR0010/PAG0111) geradas pelo Legado,
                sendo assim, apenas logamos o recebimento da R1 */
                 
             IF   NOT(CAN-DO("STR0010R1,PAG0111R1",aux_CodMsg))  THEN
                  DO:                 
                      IF  SUBSTRING(aux_NumCtrlIF,1,1) = "1"  THEN /* TED */
                          DO:
                              DO aux_contlock = 1 TO 10:

                                 FIND craptvl WHERE 
                                      craptvl.cdcooper = crabcop.cdcooper  AND
                                      craptvl.tpdoctrf = 3                 AND 
                                      craptvl.idopetrf = aux_NumCtrlIF
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                      
                                 IF   NOT AVAIL craptvl   THEN
                                      IF   LOCKED craptvl    THEN
                                           DO:
                                               aux_dscritic = 
                                                "Registro craptvl sendo alterado".
                                               PAUSE 1 NO-MESSAGE.
                                               NEXT.
                                           END.
                                      ELSE 
                                           DO:
                                               ASSIGN aux_dscritic = 
                                                "Numero de Controle invalido".
                                               LEAVE.
                                           END.

                                 ASSIGN aux_dscritic = "".
                                 LEAVE.

                              END.

                              IF   LOCKED craptvl   THEN
                                   NEXT.

                              IF   NOT AVAIL craptvl   THEN
                                   DO:
                                       RUN gera_logspb (INPUT "RETORNO SPB",
                                                        INPUT aux_dscritic,
                                                        INPUT TIME).
                                                             
                                       RUN salva_arquivo.
                                       RUN deleta_objetos.
                                       NEXT.
                                   END.

                              /* Cancelado ou Rejeitado */
                              IF  CAN-DO("5,9,14,15",aux_SitLanc)  THEN
                                  DO:
                                      RUN gera_logspb 
                                         (INPUT "ENVIADA NAO OK",
                                          INPUT "Situacao Lancamento: " +
                                                aux_SitLanc,
                                          INPUT TIME).
                                      
                                      RUN salva_arquivo.
                                      RUN deleta_objetos.
                                      NEXT.
                                  END.
                              ELSE
                                   ASSIGN craptvl.flgopfin = TRUE. /*Finaliz.*/
                          END.
                      ELSE     
                      IF  SUBSTRING(aux_NumCtrlIF,1,1) = "2"  THEN /* TEC */
                          DO:
                              DO aux_contlock = 1 TO 10:

                                 FIND FIRST craplcs WHERE 
                                            craplcs.cdcooper = crabcop.cdcooper  AND
                                            craplcs.idopetrf = aux_NumCtrlIF 
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                              
                                 IF   NOT AVAIL craplcs    THEN
                                      IF   LOCKED craplcs   THEN
                                           DO:
                                               ASSIGN aux_dscritic = 
                                                "Registro craplcs sendo alterado.".
                                               PAUSE 1 NO-MESSAGE.
                                               NEXT.
                                           END.
                                       ELSE
                                           DO:
                                               ASSIGN aux_dscritic = 
                                                "Numero de Controle invalido".
                                               LEAVE.
                                           END.

                                 ASSIGN aux_dscritic = "".
                                 LEAVE.

                              END.

                              IF   LOCKED craplcs   THEN
                                   NEXT.

                              IF   NOT AVAIL craplcs  THEN
                                   DO:
                                       RUN gera_logspb 
                                         (INPUT "RETORNO SPB",
                                          INPUT aux_dscritic,
                                          INPUT TIME).
                                           
                                       RUN salva_arquivo.
                                       RUN deleta_objetos.
                                       NEXT.
                                   END.
                              
                              /* Cancelado ou Rejeitado */
                              IF  CAN-DO("5,9,14,15",aux_SitLanc)  THEN
                                  DO:
                                      RUN gera_logspb 
                                         (INPUT "ENVIADA NAO OK",
                                          INPUT "Situacao Lancamento: " +
                                                aux_SitLanc,
                                          INPUT TIME).

                                      RUN salva_arquivo.
                                      RUN deleta_objetos.
                                      NEXT.
                                  END.
                              ELSE
                                  DO:
                                     ASSIGN craplcs.flgopfin = TRUE. /* Finaliz.*/
                                     /*Alteração FOLHAIB*/
                                     IF craplcs.nrridlfp <> 0 THEN
                                     DO: 
                                         FIND FIRST craplfp WHERE 
                                            craplfp.cdcooper = craplcs.cdcooper  AND
                                            RECID(craplfp)   = craplcs.nrridlfp 
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                         
                                         IF AVAIL craplfp THEN
                                         DO:
                                             ASSIGN craplfp.idsitlct = 'T'
                                                    craplfp.dsobslct = ? .  
                                         END.
                                  END.
                                        
                              END.
                                 
                          END.
                      ELSE
                      IF  SUBSTRING(aux_NumCtrlIF,1,1) <> "3"  THEN /*STR0004*/
                           DO:
                               RUN gera_logspb 
                                   (INPUT "RETORNO SPB",
                                    INPUT "Identificador TED/TEC invalido",
                                    INPUT TIME).
                                       
                               RUN salva_arquivo.
                               RUN deleta_objetos.
                               NEXT. 
                           END.
                  END.
                  
             /* SUCESSO */ 
             RUN gera_logspb (INPUT "RETORNO SPB",
                              INPUT "",
                              INPUT TIME).
                              
             RUN salva_arquivo.
             RUN deleta_objetos.
         END.
    ELSE      
        RUN trata_lancamentos. 
         
END.

/* Finaliza execucao do programa em paralelo */ 
RUN finaliza_paralelo.
 

PROCEDURE gera_erro_xml:

  DEF INPUT PARAM par_dsdehist AS CHAR                              NO-UNDO.


  DEF VAR aux_cdagectl LIKE crapcop.cdagectl                        NO-UNDO.
  DEF VAR aux_cdcooper LIKE crapcop.cdcooper                        NO-UNDO.


  ASSIGN aux_cdcooper = IF   AVAIL crabcop   THEN
                             crabcop.cdcooper 
                        ELSE 
                             crapcop.cdcooper.

  FIND crabdat WHERE crabdat.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.

  IF   NOT AVAIL crabdat THEN 
       DO:
           ASSIGN glb_cdcritic = 1.
           RUN fontes/critic.p.
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                             " - " + glb_cdprogra + "' --> '"  + 
                             glb_dscritic + " >> log/proc_batch.log").
           RETURN.
       END.
  
  ASSIGN aux_cdagectl = IF   AVAIL crabcop   THEN     
                             crabcop.cdagectl 
                        ELSE                          
                             crapcop.cdagectl 
         aux_dsdircop = IF   AVAIL crabcop   THEN 
                             crabcop.dsdircop
                        ELSE
                             crapcop.dsdircop      
         aux_nmarquiv  = "/usr/coop/" + aux_dsdircop +
                         "/integra/msge_cecred_" + STRING(YEAR(TODAY),"9999")
                         + STRING(MONTH(TODAY),"99") + STRING(DAY(TODAY),"99")
                         + STRING(TIME,"99999") + 
                         /* para evitar duplicidade devido paralelismo */
                         SUBSTRING(STRING(NOW),21,3) + 
						 STRING(NEXT-VALUE(SEQ_TEDENVIO),"999") + ".xml"
                        
         aux_VlrLanc   = REPLACE(aux_VlrLanc,",",".")
         aux_CdLegado  = STRING(aux_cdagectl)
         aux_cdtiptrf  = IF   CAN-DO("STR0037R2,PAG0137R2",aux_CodMsg)  THEN
                              2   /* TEC */
                         ELSE 1   /* TED */
         aux_NumCtrlIF = STRING(aux_cdtiptrf,"9") + 
                         SUBSTRING(STRING(YEAR(crabdat.dtmvtolt)),3) +
                         STRING(MONTH(crabdat.dtmvtolt),"99") + 
                         STRING(DAY(crabdat.dtmvtolt),"99") +
                         STRING(aux_cdagectl,"9999")  + 
                         STRING(TIME,"99999") + 
                         /* para evitar duplicidade devido paralelismo */
                         STRING(NEXT-VALUE(SEQ_TEDENVIO),"999") +
                         "A". /* origem AYLLOS */ 
         aux_dsarqenv = "". 
                              
  ASSIGN aux_textoxml[1] = "<SISMSG>"
         aux_textoxml[2] = "<SEGCAB>" 
         aux_textoxml[3] = "<CD_LEGADO>" + aux_CdLegado + "</CD_LEGADO>"
         aux_textoxml[4] = "<TP_MANUT>I</TP_MANUT>"
         aux_textoxml[5] = "<CD_STATUS>D</CD_STATUS>"
         aux_textoxml[6] = "<NR_OPERACAO>" + aux_NumCtrlIF + "</NR_OPERACAO>"
         aux_textoxml[7] = "<FL_DEB_CRED>D</FL_DEB_CRED>"
         aux_textoxml[8] = "</SEGCAB>".
                                                
  
  IF   CAN-DO("STR0005R2,STR0007R2,STR0008R2,STR0026R2,STR0037R2",aux_CodMsg)
         THEN
       ASSIGN aux_textoxml[9]  = "<STR0010>"
              aux_textoxml[10] = "<CodMsg>STR0010</CodMsg>"
              aux_textoxml[11] = "<NumCtrlIF>" + aux_NumCtrlIF + "</NumCtrlIF>"
              aux_textoxml[12] = "<ISPBIFDebtd>" + aux_ISPBIFCredtd +
                                 "</ISPBIFDebtd>"
              aux_textoxml[13] = "<ISPBIFCredtd>" + aux_ISPBIFDebtd +
                                 "</ISPBIFCredtd>"
              aux_textoxml[14] = "<VlrLanc>" + aux_VlrLanc + "</VlrLanc>"
              aux_textoxml[15] = "<CodDevTransf>" + STRING(aux_codierro) +
                                 "</CodDevTransf>"
              aux_textoxml[16] = "<NumCtrlSTROr>" + aux_NumCtrlRem +
                                 "</NumCtrlSTROr>"
              /* Descricao Critica */   
              aux_textoxml[17] = "<Hist>" + par_dsdehist + "</Hist>" 
              aux_textoxml[18] = "<DtMovto>" + aux_DtMovto + "</DtMovto>"
              aux_textoxml[19] = "</STR0010>".
  ELSE
  IF   CAN-DO("PAG0107R2,PAG0108R2,PAG0137R2,PAG0143R2",
              aux_CodMsg)  THEN 
       ASSIGN aux_textoxml[9]  = "<PAG0111>"
              aux_textoxml[10] = "<CodMsg>PAG0111</CodMsg>"
              aux_textoxml[11] = "<NumCtrlIF>" + aux_NumCtrlIF + "</NumCtrlIF>"
              aux_textoxml[12] = "<ISPBIFDebtd>" + aux_ISPBIFCredtd +
                                 "</ISPBIFDebtd>"
              aux_textoxml[13] = "<ISPBIFCredtd>" + aux_ISPBIFDebtd +
                                 "</ISPBIFCredtd>"
              aux_textoxml[14] = "<VlrLanc>" + aux_VlrLanc + "</VlrLanc>"
              aux_textoxml[15] = "<CodDevTransf>" + STRING(aux_codierro) +
                                 "</CodDevTransf>"
              aux_textoxml[16] = "<NumCtrlPAGOr>" + aux_NumCtrlRem +
                                 "</NumCtrlPAGOr>"
              /* Descricao Critica */
              aux_textoxml[17] = "<Hist>" + par_dsdehist + "</Hist>"  
              aux_textoxml[18] = "<DtMovto>" + aux_DtMovto + "</DtMovto>"
              aux_textoxml[19] = "</PAG0111>".              
  ELSE
  IF (aux_CodMsg = "STR0047R2") THEN
      ASSIGN aux_textoxml[9]  = "<STR0048>"
              aux_textoxml[10] = "<CodMsg>STR0048</CodMsg>"
              aux_textoxml[11] = "<NumCtrlIF>" + aux_NumCtrlIF + "</NumCtrlIF>"
              aux_textoxml[12] = "<ISPBIFDebtd>" + aux_ISPBIFCredtd +
                                 "</ISPBIFDebtd>"
              aux_textoxml[13] = "<ISPBIFCredtd>" + aux_ISPBIFDebtd +
                                 "</ISPBIFCredtd>"      
              aux_textoxml[14] = "<VlrLanc>" + aux_VlrLanc + "</VlrLanc>"
              aux_textoxml[15] = "<CodDevPortdd>" + STRING(aux_codierro) +
                                 "</CodDevPortdd>"
              aux_textoxml[16] = "<NumCtrlSTROr>" + aux_NumCtrlRem +
                                 "</NumCtrlSTROr>" +
                                 "<ISPBPrestd>29011780</ISPBPrestd>"
              /* Descricao Critica */
              aux_textoxml[17] = "<Hist>" + par_dsdehist + "</Hist>"  
              aux_textoxml[18] = "<DtMovto>" + aux_DtMovto + "</DtMovto>"
              aux_textoxml[19] = "</STR0048>".              

  ASSIGN aux_textoxml[20] = "</SISMSG>".

  OUTPUT STREAM str_2 TO VALUE (aux_nmarquiv).

  DO   aux_contador = 1 TO 20:
  
       PUT STREAM str_2 UNFORMATTED aux_textoxml[aux_contador].
       
       /* String que recebe a mensagem enviada por buffer */
       ASSIGN aux_dsarqenv = aux_dsarqenv + aux_textoxml[aux_contador].
  END.
  
  OUTPUT STREAM str_2 CLOSE.
  
  /* move XML de erro para o diretorio salvar */
  UNIX SILENT VALUE ("mv " + aux_nmarquiv + " /usr/coop/" + 
                     aux_dsdircop + "/salvar/").

  /* envia XML de erro para fila */ 
  UNIX SILENT VALUE ("/usr/bin/sudo /usr/local/cecred/bin/mqcecred_envia.pl"
                     + " --msg='" + aux_dsarqenv + "'"
                     + " --coop='" + STRING(glb_cdcooper) + "'"
                     + " --arq='" + aux_nmarquiv + "'").

  ASSIGN aux_VlrLanc  = REPLACE(aux_VlrLanc,".",",").


  /*** Tratamento incorporação Transposul ***/
  /* Necessario retornar os valores originais para apresentar no LOG */ 
  IF   aux_cdageinc > 0 THEN /* Agencia incorporada */ 
       ASSIGN aux_AgCredtd = STRING(aux_cdageinc,"9999").
  
  RUN gera_logspb (INPUT "RECEBIDA",
                   INPUT log_msgderro,
                   INPUT TIME).

  /* Cria registro da mensagem Devolvida */
  RUN cria_gnmvcen (INPUT aux_cdagectl,
                    INPUT crabdat.dtmvtolt,
                    INPUT SUBSTRING(aux_textoxml[10],9,7), /*CodMsg*/
                    INPUT "C",
                    INPUT DEC(aux_VlrLanc)).
  
END PROCEDURE.
    

PROCEDURE deleta_objetos.
  
    DELETE OBJECT hTextTag2.  
    DELETE OBJECT hTextTag.  
    DELETE OBJECT hNameTag.
    DELETE OBJECT hSubNode2.
    DELETE OBJECT hSubNode.
    DELETE OBJECT hNode.
    DELETE OBJECT hRoot.
    DELETE OBJECT hDoc.

END PROCEDURE.


PROCEDURE importa_xml.
     
   DEF VAR aux_setlinha AS CHAR                                     NO-UNDO.
   DEF VAR aux_setlinh2 AS CHAR                                     NO-UNDO.

   ASSIGN aux_nmarqori = aux_nmarquiv
          aux_nmarquiv = "".
   
   
   INPUT STREAM str_1 THROUGH VALUE  
      ("/usr/local/cecred/bin/mqcecred_descriptografa.pl --descriptografa='" + 
       crawarq.nmarquiv + "'"). 
   

   /* Obtem arquivo temporario descriptografado */ 
   IMPORT STREAM str_1 UNFORMATTED aux_nmarquiv.

   IF   TRIM(aux_nmarquiv) = ""  THEN
        RETURN "NOK".
            
   /* Importar arquivo para retirar caracteres especiais */
   INPUT STREAM str_3 FROM VALUE ( aux_nmarquiv ) NO-ECHO. 

   ASSIGN aux_setlinh2 = "".

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_3 UNFORMATTED aux_setlinha.

        RUN fontes/substitui_caracter.p (INPUT-OUTPUT aux_setlinha).
        
        /* Substituir caracter especial 216 e 248 por "O" */
        ASSIGN aux_setlinha = REPLACE(REPLACE(aux_setlinha,CHR(216),"O"),CHR(248),"o").
		
		/* Substituir caracter especial 230 e 207 por "" */
        ASSIGN aux_setlinha = REPLACE(REPLACE(aux_setlinha,CHR(230),""),CHR(207),"").
        
		ASSIGN aux_setlinh2 = aux_setlinh2 + aux_setlinha.
        
   END.  
   
   INPUT STREAM str_3 CLOSE.
   INPUT STREAM str_1 CLOSE.

   /* Remover arquivo com caracteres especiais */
   UNIX SILENT VALUE ("rm " + aux_nmarquiv + " 2>/dev/null" ).

   /* Criar um novo no mesmo caminho sem os caracteres especiais */
   OUTPUT STREAM str_3 TO VALUE (aux_nmarquiv).
   
   PUT STREAM str_3 UNFORMATTED aux_setlinh2 .

   OUTPUT STREAM str_3 CLOSE.

   /** Metodo para importar o arquivo XML **/
   hDoc:LOAD("FILE",aux_nmarquiv,FALSE).
   
   /** Obtem TAG Root "SISMSG" do XML **/
   hDoc:GET-DOCUMENT-ELEMENT(hRoot).
   
   /** Le todos os Sub-nodos de SISMSG */
   DO aux_contador = 1 TO hRoot:NUM-CHILDREN:
  
      /** Obtem o Sub-nodo de SISMSG */
      hRoot:GET-CHILD(hNode,aux_contador).
      
      IF   hNode:SUBTYPE <> 'ELEMENT' THEN
           NEXT.           

      IF  hNode:NAME = "SEGCAB" THEN 
          /** Efetua leitura dos dados do SEGCAB (Header) **/
          DO aux_contado1 = 1 TO hNode:NUM-CHILDREN:
    
             hNode:GET-CHILD(hNameTag,aux_contado1). 
            
             IF   hNameTag:SUBTYPE <> 'ELEMENT' THEN
                  NEXT.

             IF   hNameTag:NAME = "NR_OPERACAO"  THEN 
                  DO:
                      hNameTag:GET-CHILD(hTextTag,1) NO-ERROR.
                           
                      /* Se nao vier conteudo na TAG */ 
                      IF   ERROR-STATUS:ERROR             OR  
                           ERROR-STATUS:NUM-MESSAGES > 0  THEN
                           NEXT.
                      
                      ASSIGN aux_NrOperacao = hTextTag:NODE-VALUE.
                  END.                         
          END. 
      ELSE  
      IF  hNode:NAME = "CABInfSituacao"  OR 
          hNode:NAME = "CABInfCancelamento"  THEN
          /* Inconsistencia dados, Resposta da JD ou Rejeicao da cabine*/
          RUN trata_CABInf. 
      ELSE   
      IF  hNode:NAME = "PAG0101"  OR  hNode:NAME = "STR0018"  OR
          hNode:NAME = "STR0019"  THEN
          RUN trata_IFs.
      ELSE
      IF  hNode:NAME = "STR0047R2" THEN
          RUN trata_portabilidade.
      ELSE
          RUN trata_dados_transferencia.
            
   END. /** Fim do DO ... TO **/    
                   
   /* remove arquivo temporario descriptografado */ 
   UNIX SILENT VALUE ("rm " + aux_nmarquiv).  

   RETURN "OK".
   
END PROCEDURE.

PROCEDURE trata_portabilidade. 

    ASSIGN aux_CodMsg = "STR0047R2".

    /** Le todos os Sub-nodos de STR0047R2 */
    DO aux_contador = 1 TO hNode:NUM-CHILDREN:
  
        /** Obtem o Sub-nodo de STR0047R2 */
        hNode:GET-CHILD(hSubNode,aux_contador).
      
        IF  hSubNode:SUBTYPE <> 'ELEMENT' THEN
            NEXT.           

        hSubNode:GET-CHILD(hSubNode2,1) NO-ERROR.

        /* Numero de Controle do Remetente */
        IF  hSubNode:NAME = "NumCtrlSTR" THEN 
            ASSIGN aux_NumCtrlRem = hSubNode2:NODE-VALUE.

        IF  hSubNode:NAME = "ISPBIFDebtd" THEN 
            ASSIGN aux_ISPBIFDebtd = hSubNode2:NODE-VALUE.

        IF  hSubNode:NAME = "ISPBIFCredtd" THEN 
            ASSIGN aux_ISPBIFCredtd = hSubNode2:NODE-VALUE.
        
        /* Deve vir agencia 100 - CECRED */ 
        IF  hSubNode:NAME = "AgCredtd" THEN 
            ASSIGN aux_AgCredtd = hSubNode2:NODE-VALUE.

        IF  hSubNode:NAME = "NUPortdd" THEN
            ASSIGN aux_NUPortdd = hSubNode2:NODE-VALUE.        

        IF  hSubNode:NAME = "DtMovto" THEN
            ASSIGN aux_DtMovto = hSubNode2:NODE-VALUE.
            
        IF  hSubNode:NAME = "VlrLanc" THEN 
            ASSIGN aux_VlrLanc = hSubNode2:NODE-VALUE
                   aux_VlrLanc = REPLACE(aux_VlrLanc,".",",").        

        IF  hSubNode:NAME = "Grupo_STR0047R2_AgtFinancDebtd" THEN
            DO:

                DO aux_contado2 = 1 TO hSubNode:NUM-CHILDREN:

                    hSubNode:GET-CHILD(hNameTag,aux_contado2).
                    
                    IF  hNameTag:SUBTYPE <> 'ELEMENT' THEN
                        NEXT.         
                               
                    hNameTag:GET-CHILD(hTextTag,1).
                        
                    IF  hNameTag:NAME = "CtDebtd" THEN
                        ASSIGN aux_CtDebtd = hTextTag:NODE-VALUE.        

                END.

            END.        
            
        IF  hSubNode:NAME = "Grupo_STR0047R2_AgtFinancCredtd" THEN
            DO:

                DO aux_contado2 = 1 TO hSubNode:NUM-CHILDREN:

                    hSubNode:GET-CHILD(hNameTag,aux_contado2).
                    
                    IF  hNameTag:SUBTYPE <> 'ELEMENT' THEN
                        NEXT.         
                               
                    hNameTag:GET-CHILD(hTextTag,1).

                    /* Deve vir conta da coop. filiada */ 
                    IF  hNameTag:NAME = "CtCredtd" THEN
                        ASSIGN aux_CtCredtd = hTextTag:NODE-VALUE.   

                    /* Deve vir CNPJ da coop. filiada */ 
                    IF  hNameTag:NAME = "CNPJCliCredtd" THEN
                        ASSIGN aux_CNPJ_CPFCred = hTextTag:NODE-VALUE.   
                        
                    IF  hNameTag:NAME = "NomCliCredtd" THEN
                        ASSIGN aux_NomCliCredtd = hTextTag:NODE-VALUE.       

                END.

            END.        

    END.   

END PROCEDURE.


PROCEDURE verifica_conta.

   DEF VAR val_cdcooper AS INTE                                 NO-UNDO.
   DEF VAR val_nrdconta AS DECI                                 NO-UNDO.
   DEF VAR val_tppessoa AS CHAR                                 NO-UNDO.
   DEF VAR val_nrcpfcgc AS DECI                                 NO-UNDO.

   DEFINE BUFFER b-crapcop FOR crapcop.
   DEFINE BUFFER b-crapdat FOR crapdat. 
   DEFINE BUFFER b-crapass FOR crapass.
   DEFINE BUFFER b-crapttl FOR crapttl.

   ASSIGN val_cdcooper = crabcop.cdcooper
          val_nrdconta = DECI(aux_CtCredtd)
          val_tppessoa = IF   aux_CodMsg = "STR0047R2"  THEN
                              "J" /* Conta das filiadas na CECRED */ 
                         ELSE aux_TpPessoaCred
          val_nrcpfcgc = DEC(aux_CNPJ_CPFCred).

   IF   LENGTH(STRING(DEC(val_nrdconta))) > 9  THEN
        ASSIGN aux_codierro = 2  /*Conta invalida*/
               aux_dsdehist = "Conta informada invalida.".
   ELSE
        DO:
           /* IFs incorporadas foram desativadas (crapcop.flgativo = FALSE
           /* Tratamento incorporacao CONCREDI e CREDIMILSUL */
           IF  aux_cdageinc = 103 OR aux_cdageinc = 114  THEN
               DO:
                   FIND craptco WHERE 
                        craptco.cdcooper = crabcop.cdcooper  AND
                        craptco.nrctaant = INT(aux_CtCredtd) AND
                       (craptco.cdcopant = 4 OR
                        craptco.cdcopant = 15) NO-LOCK NO-ERROR.
         
                   IF   AVAIL craptco THEN
                        /*Nova conta*/
                        ASSIGN aux_CtCredtd = STRING(craptco.nrdconta).
                   ELSE
                        DO:
                            ASSIGN aux_codierro = 2 /*Conta invalida*/
                                   aux_dsdehist = "Conta informada invalida.".

                            RETURN "NOK".
                        END.
                       
               END.
           *************************************************************/

		   /* Incorporada Transulcred */ 
		   IF   aux_cdageinc > 0  THEN
		        DO:
				    /* identifica cooperativa antiga */ 
					FIND m-crabcop WHERE m-crabcop.cdagectl = aux_cdageinc NO-LOCK NO-ERROR. 

				    FIND craptco WHERE 
                         craptco.cdcooper = val_cdcooper  AND
                         craptco.nrctaant = val_nrdconta  AND
                         craptco.cdcopant = m-crabcop.cdcooper  NO-LOCK NO-ERROR.

                   IF   AVAIL craptco THEN
                        /*Nova conta*/
                        ASSIGN val_nrdconta = craptco.nrdconta.
                   ELSE
                        DO:
                            ASSIGN aux_codierro = 2 /*Conta invalida*/
                                   aux_dsdehist = "Conta informada invalida.".

                            RETURN "NOK".
                        END.
			    END.
           ELSE
		        DO:
				   /* -----  VALIDA CONTA MIGRADA ------- */

				   FIND craptco WHERE craptco.cdcopant = val_cdcooper AND
									  craptco.nrctaant = val_nrdconta AND
									  craptco.flgativo = TRUE         AND
									  craptco.tpctatrf = 1   
									  NO-LOCK NO-ERROR.
            
				   IF  AVAIL(craptco) THEN
				   DO:  
					   /* Verificar se conta foi migrada ACREDI >> VIACREDI */
					   IF  craptco.cdcooper = 1 AND   /* VIACREDI */
						   craptco.cdcopant = 2 THEN  /* ACREDI */
					   DO:
						   ASSIGN aux_codierro = 1. /* Conta encerrada */
						   RETURN "NOK".
					   END.
 
					   /* Verificar se conta foi migrada VIACREDI >> ALTO VALE */
					   IF  craptco.cdcooper = 16 AND   /* ALTO VALE */
						   craptco.cdcopant = 1  THEN  /* VIACREDI */
					   DO:
						   ASSIGN aux_codierro = 1. /* Conta encerrada */
						   RETURN "NOK".
					   END.

					   /* validacao da conta migrada */
					   ASSIGN val_cdcooper = craptco.cdcooper
							  val_nrdconta = craptco.nrdconta.

					   /* Busca cooperativa onde a conta foi transferida */ 
					   FIND b-crapcop WHERE b-crapcop.cdcooper = val_cdcooper
											NO-LOCK NO-ERROR.

					   IF  NOT AVAIL(b-crapcop) THEN
					   DO:
						   ASSIGN aux_codierro = 99
								  aux_dsdehist = "Cooperativa migrada nao encontrada.".
						   RETURN "NOK".
					   END.
               
					   /* Busca data na cooperativa onde a conta foi transferida */ 
					   FIND b-crapdat WHERE b-crapdat.cdcooper = val_cdcooper
											NO-LOCK NO-ERROR.
    
					   IF  NOT AVAIL(b-crapdat) THEN
					   DO:
						   ASSIGN aux_codierro = 99
								  aux_dsdehist = "Data da cooperativa migrada " +
												 "nao encontrada.".
						   RETURN "NOK".
					   END.

					   /* Verifica se conta transferida existe */ 
					   FIND crapass WHERE crapass.cdcooper = val_cdcooper  AND
										  crapass.nrdconta = val_nrdconta
										  NO-LOCK NO-ERROR.
    
					   IF   NOT AVAIL crapass THEN
					   DO:
						   ASSIGN aux_codierro = 99
								   aux_dsdehist = "Conta migrada nao encontrada.".
						   RETURN "NOK".
					   END.

					   ASSIGN val_tppessoa = IF crapass.inpessoa = 1 THEN "F" ELSE "J"
							  val_nrcpfcgc = crapass.nrcpfcgc.
               
					   /* Verifica cpf da TED com o cpf da conta */
					   FIND FIRST b-crapttl WHERE b-crapttl.cdcooper = val_cdcooper
											  AND b-crapttl.nrdconta = val_nrdconta
											  AND b-crapttl.nrcpfcgc = val_nrcpfcgc
											  NO-LOCK NO-ERROR.
					   /* Se nao achar, verifica novamente na conta */ 
					   IF NOT AVAIL b-crapttl THEN
					   DO:
						   FIND b-crapass WHERE b-crapass.cdcooper = val_cdcooper
											AND b-crapass.nrdconta = val_nrdconta
											AND b-crapass.nrcpfcgc = val_nrcpfcgc
											NO-LOCK NO-ERROR.
						   IF  NOT AVAIL b-crapass THEN
						   DO:
							   ASSIGN aux_codierro = 3. /*CPF divergente*/
							   RETURN "NOK". 
						   END.
					   END. 
				   END. /* IF avail craptco */
           
				   /*-----  FIM CONTA MIGRADA -------*/
				END.
               
               /* Pessoa Fisica */
           IF   val_tppessoa = "F" OR CAN-DO("STR0037R2,PAG0137R2",aux_CodMsg) THEN
                DO:                                                   
                    FIND FIRST crapttl WHERE crapttl.cdcooper = val_cdcooper AND
                                             crapttl.nrdconta = val_nrdconta AND
                                             crapttl.nrcpfcgc = val_nrcpfcgc
                                             NO-LOCK NO-ERROR.
               
                    IF   NOT AVAIL crapttl  THEN
                         DO:
                             /* Verifica se o problema esta na conta ou CPF */
                             FIND FIRST crapttl WHERE 
                                        crapttl.cdcooper = val_cdcooper AND
                                        crapttl.nrdconta = val_nrdconta
                                        NO-LOCK NO-ERROR.
                                       
                             IF   NOT AVAIL crapttl  THEN
                                  ASSIGN aux_codierro = 2 /*Conta invalida*/
                                         aux_dsdehist = "Conta informada invalida.".  
                             ELSE
                                  ASSIGN aux_codierro = 3.  /*CPF divergente*/
                         END.
                    ELSE
                         DO:
                             FIND crapass WHERE 
                                  crapass.cdcooper = val_cdcooper      AND
                                  crapass.nrdconta = val_nrdconta 
                                  NO-LOCK NO-ERROR.
                                       
                             IF   AVAIL crapass  AND  crapass.dtelimin <> ?  THEN 
                                  ASSIGN aux_codierro = 1.  /* Conta encerrada */
                         END.
           
                END.
           ELSE       
                DO: /* Pessoa Juridica */ 
                    FIND crapass WHERE crapass.cdcooper = val_cdcooper AND
                                       crapass.nrdconta = val_nrdconta AND
                                       crapass.nrcpfcgc = val_nrcpfcgc AND
                                       crapass.inpessoa > 1
                                       NO-LOCK NO-ERROR.
                                       
                    IF   NOT AVAIL crapass  THEN 
                         DO:
                             /* Verifica se o problema esta na conta ou CNPJ */
                             FIND crapass WHERE
                                  crapass.cdcooper = val_cdcooper AND
                                  crapass.nrdconta = val_nrdconta AND
                                  crapass.inpessoa > 1
                                  NO-LOCK NO-ERROR.
           
                             IF   NOT AVAIL crapass THEN
                                  ASSIGN aux_codierro = 2  /*Conta invalida*/
                                         aux_dsdehist = "Conta informada invalida.".                       
                             ELSE
                                  IF   aux_CodMsg = "STR0047R2"  THEN 
                                       /* Portabilidade nao trata codigo de devolucao
                                          por divergencia de CNPJ */
                                       ASSIGN aux_codierro = 0. 
                                  ELSE
                                       ASSIGN aux_codierro = 3.  /*CNPJ divergente*/
                         END.
                    ELSE
                         IF   crapass.dtelimin <> ?  THEN
                              ASSIGN aux_codierro = 1.  /* Conta encerrada */
                END.
        END.

    RETURN "OK".   
                                  
END PROCEDURE.                                   

PROCEDURE trata_cecred.

   DEF INPUT PARAM par_cdagectl AS CHAR  NO-UNDO.

   IF   par_cdagectl <> ""  THEN
        DO:
            INT(par_cdagectl) NO-ERROR.
   
            IF   ERROR-STATUS:ERROR = FALSE  THEN
                 /* Busca cooperativa de destino */
                 FIND FIRST crabcop WHERE 
                            crabcop.cdagectl = INT(par_cdagectl)  AND
                            crabcop.flgativo = TRUE
                            NO-LOCK NO-ERROR.
             
            /* Se mensagem nao pertence a nenhuma Coop. */
            IF   ERROR-STATUS:ERROR  OR  NOT AVAIL crabcop  THEN
                 DO:
                     FIND craptab WHERE craptab.cdcooper = 0            AND
                                        craptab.nmsistem = "CRED"       AND
                                        craptab.tptabela = "GENERI"     AND
                                        craptab.cdempres = 0            AND
                                        craptab.cdacesso = "CDERROSSPB" AND
                   /*Agencia invalida*/ craptab.tpregist = 2
                                        NO-LOCK NO-ERROR.
                                
                     IF   AVAIL craptab THEN
                          ASSIGN log_msgderro = craptab.dstextab.                                   

                     /* Nao criar gnmvcen para CABInf */
                     IF   aux_tagCABInf = FALSE  THEN
                          RUN cria_gnmvcen (INPUT crapcop.cdagectl,
                                            INPUT crapdat.dtmvtolt,
                                            INPUT aux_CodMsg,
                                            INPUT "C",
                                            INPUT DEC(aux_VlrLanc)).
                                            
                     IF   aux_CodMsg MATCHES "*R2"  THEN
                          DO:
                               /* Agencia invalida */  
                              ASSIGN aux_codierro = 2
                                     aux_dsdehist = 
                                  "Agencia de destino invalida.".

                              RUN gera_erro_xml (INPUT aux_dsdehist).
                          END.
                     ELSE
                     DO:
                         RUN gera_logspb (INPUT "RECEBIDA",
                                          INPUT log_msgderro,
                                          INPUT TIME).
                     END.

                 END.
        END.
   ELSE     
        DO:

            ASSIGN log_msgderro = "Mensagem nao prevista".
            
            RUN gera_logspb (INPUT "RECEBIDA",
                             INPUT log_msgderro,
                             INPUT TIME).
        END.
   
END.

PROCEDURE gera_logspb_transferida.

    /*****************************************************************
     * Cuidar ao mecher no log, pois os espacamentos e formats estao *
     * ajustados para que a tela LOGSPB pegue os dados com SUBSTRING * 
     *****************************************************************/
         
    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper        NO-UNDO.
    DEF  INPUT PARAM par_cdbcoctl LIKE crapcop.cdbcoctl        NO-UNDO.
    DEF  INPUT PARAM par_cdagectl LIKE crapcop.cdagectl        NO-UNDO.
    DEF  INPUT PARAM par_dsdircop LIKE crapcop.dsdircop        NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt        NO-UNDO.
    DEF  INPUT PARAM par_tipodlog AS CHAR                      NO-UNDO.
    DEF  INPUT PARAM par_msgderro AS CHAR                      NO-UNDO.
    DEF  INPUT PARAM par_hrtransa AS INTE                      NO-UNDO.

    DEF VARIABLE    aux_nmpesrcb LIKE craptvl.nmpesrcb         NO-UNDO.
        
    /* Trazer arquivo de log do mqcecred_processa */
    ASSIGN aux_nmarqlog = "/usr/coop/" + par_dsdircop + "/log/" + 
                          "mqcecred_processa_" + 
                          STRING(par_dtmvtolt,"999999") + ".log".    
    
    IF  par_tipodlog = "RECEBIDA"  THEN  
        DO:
            FIND FIRST crapban WHERE crapban.nrispbif = INT(aux_ISPBIFDebtd) 
                       NO-LOCK NO-ERROR.

            IF   AVAIL crapban  THEN
                 ASSIGN aux_BancoDeb = crapban.cdbccxlt.

            ASSIGN aux_BancoCre = par_cdbcoctl. /* Banco CECRED */

            IF   aux_NumCtrlRem <> ""  THEN
                 ASSIGN aux_nrctrole = aux_NumCtrlRem.
            ELSE
                 ASSIGN aux_nrctrole = aux_NumCtrlIF.          

            IF  par_msgderro <> " "  THEN
                DO:
                    UNIX SILENT VALUE 
                    ("echo " + '"' + STRING(TODAY,"99/99/9999") + 
                     " - " + STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra + 
                     " - RECEBIDA NAO OK    --> " + 
                     "Arquivo " + STRING(aux_nmarqxml,"x(40)") + 
                     ". Evento: " + STRING(aux_CodMsg,"x(9)") +
                     ", Motivo Erro: " + STRING(par_msgderro,"x(90)") +
                     ", Numero Controle: " + STRING(aux_nrctrole,"x(20)") + 
                     ", Hora: " + STRING(TIME,"HH:MM:SS") + 
                     ", Valor: " + STRING(DEC(aux_VlrLanc),"zzz,zzz,zz9.99") + 
                     ", Banco Remet.: " + STRING(aux_BancoDeb,"zz9") +
                     ", Agencia Remet.: " + STRING(aux_AgDebtd,"x(4)") + 
                     ", Conta Remet.: " + STRING(aux_CtDebtd,
                                                 "xxxxxxxxxxxxxx") +
                     ", Nome Remet.: " + STRING(aux_NomCliDebtd,"x(40)") + 
                     ", CPF/CNPJ Remet.: " + 
                     STRING(DEC(aux_CNPJ_CPFDeb),"zzzzzzzzzzzzz9") + 
                     ", Banco Dest.: " + STRING(aux_BancoCre,"zz9") + 
                     ", Agencia Dest.: " + STRING(aux_AgCredtd,"x(4)") + 
                     ", Conta Dest.: " +  STRING(craptco.nrdconta,"zzzzzzzzzzzzz9") +
                     ", Nome Dest .: " + STRING(aux_NomCliCredtd,"x(40)")  + 
                     ", CPF/CNPJ Dest.: " +
                     STRING(DEC(aux_CNPJ_CPFCred),"zzzzzzzzzzzzz9") +
                     '"' +  ". >> " + aux_nmarqlog).

                    RUN sistema/generico/procedures/b1wgen0050.p 
                                          PERSISTENT SET b1wgen0050.

                    IF  VALID-HANDLE(b1wgen0050)  THEN DO:
                        RUN grava-log-ted IN b1wgen0050 
                                           (INPUT par_cdcooper,
                                            INPUT TODAY,
                                            INPUT TIME,
                                            INPUT 1, /* origem */
                                            INPUT glb_cdprogra,
                                            INPUT 4, 
                                            INPUT aux_nmarqxml,
                                            INPUT aux_CodMsg,
                                            INPUT aux_nrctrole,
                                            INPUT DEC(aux_VlrLanc),
                                            INPUT aux_BancoCre,
                                            INPUT aux_AgCredtd,
                                            INPUT STRING(craptco.nrdconta),
                                            INPUT aux_NomCliCredtd,
                                            INPUT DEC(aux_CNPJ_CPFCred),
                                            INPUT aux_BancoDeb,
                                            INPUT aux_AgDebtd,
                                            INPUT aux_CtDebtd,
                                            INPUT aux_NomCliDebtd,
                                            INPUT DEC(aux_CNPJ_CPFDeb),
                                            INPUT "",
                                            INPUT par_msgderro,
                                            INPUT 0, /*cdagenci*/
                                            INPUT 0, /*nrdcaixa*/
                                            INPUT "1",
                                            INPUT aux_ISPBIFDebtd,
                                            INPUT aux_inestcri).
                        IF VALID-HANDLE(b1wgen0050) THEN
                            DELETE PROCEDURE b1wgen0050.             
                    END.
                END.
            ELSE
                DO:
                   UNIX SILENT VALUE 
                   ("echo " + '"' + STRING(TODAY,"99/99/9999") + " - " +
                    STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra + 
                    " - RECEBIDA OK        --> "  + 
                    "Arquivo " + STRING(aux_nmarqxml,"x(40)") + 
                    ". Evento: " + STRING(aux_CodMsg,"x(9)") +
                    ", Numero Controle: " + STRING(aux_nrctrole,"x(20)") +
                    ", Hora: " + STRING(TIME,"HH:MM:SS") + 
                    ", Valor: " + STRING(DEC(aux_VlrLanc),"zzz,zzz,zz9.99") + 
                    ", Banco Remet.: " + STRING(aux_BancoDeb,"zz9") +
                    ", Agencia Remet.: " + STRING(aux_AgDebtd,"x(4)") + 
                    ", Conta Remet.: " + STRING(aux_CtDebtd,
                                                "xxxxxxxxxxxxxx") +
                    ", Nome Remet.: " + STRING(aux_NomCliDebtd,"x(40)") + 
                    ", CPF/CNPJ Remet.: " + 
                     STRING(DEC(aux_CNPJ_CPFDeb),"zzzzzzzzzzzzz9") +  
                    ", Banco Dest.: " + STRING(aux_BancoCre,"zz9") + 
                    ", Agencia Dest.: " + STRING(aux_AgCredtd,"x(4)") + 
                    ", Conta Dest.: " + STRING(craptco.nrdconta,"zzzzzzzzzzzzz9") +
                    ", Nome Dest .: " + STRING(aux_NomCliCredtd,"x(40)")  + 
                    ", CPF/CNPJ Dest.: " +
                     STRING(DEC(aux_CNPJ_CPFCred),"zzzzzzzzzzzzz9") +
                    '"' +  ". >> " + aux_nmarqlog).

                    RUN sistema/generico/procedures/b1wgen0050.p 
                                          PERSISTENT SET b1wgen0050.

                    IF  VALID-HANDLE(b1wgen0050)  THEN DO:
                        RUN grava-log-ted IN b1wgen0050 
                                           (INPUT par_cdcooper,
                                            INPUT TODAY,
                                            INPUT par_hrtransa,
                                            INPUT 1, /* origem */
                                            INPUT glb_cdprogra,
                                            INPUT 3, 
                                            INPUT aux_nmarqxml,
                                            INPUT aux_CodMsg,
                                            INPUT aux_nrctrole,
                                            INPUT DEC(aux_VlrLanc),
                                            INPUT aux_BancoCre,
                                            INPUT aux_AgCredtd,
                                            INPUT STRING(craptco.nrdconta),
                                            INPUT aux_NomCliCredtd,
                                            INPUT DEC(aux_CNPJ_CPFCred),
                                            INPUT aux_BancoDeb,
                                            INPUT aux_AgDebtd,
                                            INPUT aux_CtDebtd,
                                            INPUT aux_NomCliDebtd,
                                            INPUT DEC(aux_CNPJ_CPFDeb),
                                            INPUT "",
                                            INPUT par_msgderro,
                                            INPUT 0, /*cdagenci*/
                                            INPUT 0, /*nrdcaixa*/
                                            INPUT "1",
                                            INPUT aux_ISPBIFDebtd,
                                            INPUT aux_inestcri).
                        IF VALID-HANDLE(b1wgen0050) THEN
                            DELETE PROCEDURE b1wgen0050.             
                    END.
                END.
        END.

END PROCEDURE.


PROCEDURE gera_logspb.

   /*****************************************************************
    * Cuidar ao mecher no log, pois os espacamentos e formats estao *
    * ajustados para que a tela LOGSPB pegue os dados com SUBSTRING * 
    *****************************************************************/
   
   DEF INPUT PARAM par_tipodlog AS CHAR    NO-UNDO.
   DEF INPUT PARAM par_msgderro AS CHAR    NO-UNDO.
   DEF INPUT PARAM par_hrtransa AS INTE    NO-UNDO.

   DEFINE VARIABLE aux_cdcooper LIKE crapcop.cdcooper         NO-UNDO.
   DEFINE VARIABLE aux_cdbcoctl LIKE crapcop.cdbcoctl         NO-UNDO.
   DEFINE VARIABLE aux_cdagectl LIKE crapcop.cdagectl         NO-UNDO.
   DEFINE VARIABLE aux_nmpesrcb LIKE craptvl.nmpesrcb         NO-UNDO.

   IF   AVAIL crabcop   THEN
        ASSIGN aux_cdcooper = crabcop.cdcooper
               aux_cdbcoctl = crabcop.cdbcoctl 
               aux_cdagectl = crabcop.cdagectl.
   ELSE 
        ASSIGN aux_cdcooper = crapcop.cdcooper
               aux_cdbcoctl = crapcop.cdbcoctl   
               aux_cdagectl = crapcop.cdagectl.  
                     
   /* Trazer arquivo de log do mqcecred_processa */
   RUN log_mqcecred.

   /* Confirmacao da JD */
   IF  par_tipodlog = "RETORNO JD OK"  THEN  
       UNIX SILENT VALUE ("echo " + '"' + STRING(TODAY,"99/99/9999") + 
                          " - " + STRING(TIME,"HH:MM:SS") + " - " +
                          glb_cdprogra + " - RETORNO JD OK      --> "  +
                          "Arquivo " + STRING(aux_nmarqxml,"x(40)") +
                          ". Numero Controle: " + STRING(aux_NumCtrlIF,"x(20)")
                          + '"' + ". >> " + aux_nmarqlog).
   ELSE
   IF  par_tipodlog = "RETORNO SPB"  OR  
       par_tipodlog = "REJEITADA NAO OK"  THEN
       DO:
           IF  par_msgderro <> " "  THEN
               DO:
                   IF  par_tipodlog = "RETORNO SPB"  THEN
                       ASSIGN par_tipodlog = "RETORNO SPB NAO OK".
                   
                   UNIX SILENT VALUE 
                         ("echo " + '"' + STRING(TODAY,"99/99/9999") +
                          " - " + STRING(TIME,"HH:MM:SS") + " - " +
                          glb_cdprogra + " - " + STRING(par_tipodlog,"x(18)") +
                          " --> " +
                          "Arquivo " + STRING(aux_nmarqxml,"x(40)") + 
                          ". Evento: " + STRING(aux_CodMsg,"x(9)") +
                          ", Motivo Erro: " + STRING(par_msgderro,"x(90)") + 
                          ", Numero Controle: " + STRING(aux_NumCtrlIF,"x(20)")
                          +  '"' + ". >> " + aux_nmarqlog).
               END.
           ELSE
               UNIX SILENT VALUE 
                         ("echo " + '"' + STRING(TODAY,"99/99/9999") + 
                          " - " + STRING(TIME,"HH:MM:SS") + " - " +
                          glb_cdprogra + " - RETORNO SPB OK     --> " +
                          "Arquivo " + STRING(aux_nmarqxml,"x(40)") + 
                          ". Evento: " + STRING(aux_CodMsg,"x(9)") +
                          ", Numero Controle: " + STRING(aux_NumCtrlIF,"x(20)")
                          + '"' + ". >> " + aux_nmarqlog). 
       END.
   ELSE
   /*  STR0010R2, PAG0111R2, R1 canceladas/rejeitadas,  Mensagens de
       Inconsistencia de dados, e Rejeitadas pela Cabine  */
   IF  par_tipodlog = "ENVIADA NAO OK"  OR   
       par_tipodlog = "REJEITADA OK"  THEN  
       DO:
           IF  INT(SUBSTRING(aux_NumCtrlIF,1,1)) = 1  THEN /* TED */
               DO:
                   FIND craptvl WHERE craptvl.cdcooper = aux_cdcooper  AND
                                      craptvl.tpdoctrf = 3             AND 
                                      craptvl.idopetrf = aux_NumCtrlIF
                                      NO-LOCK NO-ERROR.
                                               
                   IF  AVAIL craptvl  THEN
                       DO:
                           aux_nmpesrcb = craptvl.nmpesrcb.

                           RUN fontes/substitui_caracter.p
                                     (INPUT-OUTPUT aux_nmpesrcb). 
                           
                           UNIX SILENT VALUE 
                         ("echo " + '"' + STRING(TODAY,"99/99/9999") + 
                          " - " + STRING(TIME,"HH:MM:SS") + " - " +
                          glb_cdprogra + " - " + STRING(par_tipodlog,"x(18)") +
                          " --> "  +
                          "Arquivo " + STRING(aux_nmarqxml,"x(40)") + 
                          ". Evento: " + STRING(aux_CodMsg,"x(9)") + 
                          ", Motivo Erro: " + STRING(par_msgderro,"x(90)") +
                          ", Numero Controle: " + STRING(aux_NumCtrlIF,"x(20)")
                          + ", Hora: " + STRING(TIME,"HH:MM:SS") + 
                          ", Valor: " + 
                          STRING(craptvl.vldocrcb,"zzz,zzz,zz9.99") + 
                          ", Banco Remet.: " + 
                          STRING(aux_cdbcoctl,"zz9") + 
                          ", Agencia Remet.: " + 
                          STRING(aux_cdagectl,"zzz9") + 
                          ", Conta Remet.: " + 
                          STRING(craptvl.nrdconta,"zzzzzzzz9") + 
                          ", Nome Remet.: " + 
                          STRING(craptvl.nmpesemi,"x(40)") + 
                          ", CPF/CNPJ Remet.: " + 
                          STRING(craptvl.cpfcgemi,"zzzzzzzzzzzzz9") + 
                          ", Banco Dest.: " + 
                          STRING(craptvl.cdbccrcb,"zz9") + 
                          ", Agencia Dest.: " + 
                          STRING(craptvl.cdagercb,"zzz9") + 
                          ", Conta Dest.: " + 
                          STRING(STRING(craptvl.nrcctrcb),"xxxxxxxxxxxxxx") + 
                          ", Nome Dest.: " + 
                          STRING(aux_nmpesrcb,"x(40)") + 
                          ", CPF/CNPJ Dest.: " + 
                          STRING(craptvl.cpfcgrcb,"zzzzzzzzzzzzz9") + 
                          '"' + ". >> " + aux_nmarqlog). 

                          IF  par_tipodlog = "ENVIADA NAO OK" THEN
                          DO:
                              RUN sistema/generico/procedures/b1wgen0050.p 
                                          PERSISTENT SET b1wgen0050.

                              IF  VALID-HANDLE(b1wgen0050)  THEN DO:
                                  RUN grava-log-ted IN b1wgen0050 
                                               (INPUT aux_cdcooper,
                                                INPUT TODAY,
                                                INPUT TIME,
                                                INPUT 1, /* origem */
                                                INPUT glb_cdprogra,
                                                INPUT 2, 
                                                INPUT aux_nmarqxml,
                                                INPUT aux_CodMsg,
                                                INPUT aux_NumCtrlIF,
                                                INPUT craptvl.vldocrcb,
                                                INPUT aux_cdbcoctl,
                                                INPUT aux_cdagectl,
                                                INPUT STRING(craptvl.nrdconta),
                                                INPUT craptvl.nmpesemi,
                                                INPUT craptvl.cpfcgemi,
                                                INPUT craptvl.cdbccrcb,
                                                INPUT craptvl.cdagercb,
                                                INPUT STRING(craptvl.nrcctrcb),
                                                INPUT aux_nmpesrcb,
                                                INPUT craptvl.cpfcgrcb,
                                                INPUT "",
                                                INPUT par_msgderro,
                                                INPUT 0, /*cdagenci*/
                                                INPUT 0, /*nrdcaixa*/
                                                INPUT "1",
                                                INPUT aux_ISPBIFCredtd,
                                                INPUT aux_inestcri).                                                
                                  IF VALID-HANDLE(b1wgen0050) THEN
                                    DELETE PROCEDURE b1wgen0050.
                              END.
                          END.
                          ELSE
                          DO:
                              /* No XML da mensagem REJEITADA nao contem dados
                                 da operação, apenas o numero de controle, que 
                                 utilizamos para buscar os dados na craptvl.
                                 Como nao gravamos o ISPB nesta tabela, vamos
                                 conseguir obter/logar somente o ISPB das IFs 
                                 com código de banco*/
                              FIND FIRST crapban WHERE 
                                         crapban.cdbccxlt = craptvl.cdbccrcb 
                                         NO-LOCK NO-ERROR.

                              IF   AVAIL crapban  THEN
                                   ASSIGN aux_ISPBIFCredtd = STRING(crapban.nrispbif).

                              RUN sistema/generico/procedures/b1wgen0050.p 
                                          PERSISTENT SET b1wgen0050.

                              IF  VALID-HANDLE(b1wgen0050)  THEN DO:
                                  RUN grava-log-ted IN b1wgen0050 
                                               (INPUT aux_cdcooper,
                                                INPUT TODAY,
                                                INPUT TIME,
                                                INPUT 1, /* origem */
                                                INPUT glb_cdprogra,
                                                INPUT 5, 
                                                INPUT aux_nmarqxml,
                                                INPUT aux_CodMsg,
                                                INPUT aux_NumCtrlIF,
                                                INPUT craptvl.vldocrcb,
                                                INPUT aux_cdbcoctl,
                                                INPUT aux_cdagectl,
                                                INPUT STRING(craptvl.nrdconta),
                                                INPUT craptvl.nmpesemi,
                                                INPUT craptvl.cpfcgemi,
                                                INPUT craptvl.cdbccrcb,
                                                INPUT craptvl.cdagercb,
                                                INPUT STRING(craptvl.nrcctrcb),
                                                INPUT aux_nmpesrcb,
                                                INPUT craptvl.cpfcgrcb,
                                                INPUT "",
                                                INPUT par_msgderro,
                                                INPUT 0, /*cdagenci*/
                                                INPUT 0, /*nrdcaixa*/
                                                INPUT "1",
                                                INPUT aux_ISPBIFCredtd,
                                                INPUT aux_inestcri).                                               
                                 IF VALID-HANDLE(b1wgen0050) THEN
                                    DELETE PROCEDURE b1wgen0050.
                              END.
                          END.
                        END.
               END.
           ELSE
               DO:
                   FIND FIRST craplcs WHERE 
                              craplcs.cdcooper = aux_cdcooper  AND
                              craplcs.idopetrf = aux_NumCtrlIF 
                              NO-LOCK NO-ERROR.
                               
                   IF  AVAIL craplcs  THEN
                       DO:
                           FIND crapccs WHERE  
                                crapccs.cdcooper = aux_cdcooper  AND
                                crapccs.nrdconta = craplcs.nrdconta
                                NO-LOCK NO-ERROR.
                                        
                           IF  AVAIL crapccs  THEN
                           DO:

                               UNIX SILENT VALUE 
                               ("echo " + '"' + STRING(TODAY,"99/99/9999") + 
                                " - " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + " - " +
                                STRING(par_tipodlog,"x(18)") + " --> "  +
                                "Arquivo " + STRING(aux_nmarqxml,"x(40)") + 
                                ". Evento: " + STRING(aux_CodMsg,"x(9)") +
                                ", Motivo Erro: " +
                                STRING(par_msgderro,"x(90)") +
                                ", Numero Controle: " + 
                                STRING(aux_NumCtrlIF,"x(20)") + 
                                ", Hora: " + STRING(TIME,"HH:MM:SS") + 
                                ", Valor: " + 
                                STRING(craplcs.vllanmto,"zzz,zzz,zz9.99") + 
                                ", Banco Remet.: " + 
                                STRING(aux_cdbcoctl,"zz9") + 
                                ", Agencia Remet.: " + 
                                STRING(aux_cdagectl,"zzz9") + 
                                ", Conta Remet.: " + 
                                STRING(craplcs.nrdconta,"zzzzzzzz9") + 
                                ", Nome Remet.: " + 
                                STRING(crapccs.nmfuncio,"x(40)") + 
                                ", CPF/CNPJ Remet.: " + 
                                STRING(crapccs.nrcpfcgc,"zzzzzzzzzzzzz9") + 
                                ", Banco Dest.: " + 
                                STRING(crapccs.cdbantrf,"zz9") + 
                                ", Agencia Dest.: " + 
                                STRING(crapccs.cdagetrf,"zzz9") +
                                ", Conta Dest.: " +
                                STRING(STRING(crapccs.nrctatrf) +
                                       crapccs.nrdigtrf, "xxxxxxxxxxxxxx") +
                                ", Nome Dest.: " + 
                                STRING(crapccs.nmfuncio,"x(40)") + 
                                ", CPF/CNPJ Dest.:" + 
                                STRING(crapccs.nrcpfcgc,"zzzzzzzzzzzzz9") + 
                                '"' + ". >> " + aux_nmarqlog).

                               IF  par_tipodlog = "ENVIADA NAO OK" THEN
                               DO:
                                   RUN sistema/generico/procedures/b1wgen0050.p 
                                          PERSISTENT SET b1wgen0050.

                                   IF  VALID-HANDLE(b1wgen0050)  THEN DO: 
                                       RUN grava-log-ted IN b1wgen0050 
                                                (INPUT aux_cdcooper,
                                                 INPUT TODAY,
                                                 INPUT TIME,
                                                 INPUT 1, /* origem */
                                                 INPUT glb_cdprogra,
                                                 INPUT 2, 
                                                 INPUT aux_nmarqxml,
                                                 INPUT aux_CodMsg,
                                                 INPUT aux_NumCtrlIF,
                                                 INPUT craplcs.vllanmto,
                                                 INPUT aux_cdbcoctl,
                                                 INPUT aux_cdagectl,
                                                 INPUT STRING(craplcs.nrdconta),
                                                 INPUT crapccs.nmfuncio,
                                                 INPUT crapccs.nrcpfcgc,
                                                 INPUT crapccs.cdbantrf,
                                                 INPUT crapccs.cdagetrf,
                                                 INPUT STRING(crapccs.nrctatrf)
                                                     + STRING(crapccs.nrdigtrf),
                                                 INPUT crapccs.nmfuncio,
                                                 INPUT crapccs.nrcpfcgc,
                                                 INPUT "",
                                                 INPUT par_msgderro,
                                                 INPUT 0, /*cdagenci*/
                                                 INPUT 0, /*nrdcaixa*/
                                                 INPUT "1",
                                                INPUT aux_ISPBIFCredtd,
                                                INPUT aux_inestcri).
                                      IF VALID-HANDLE(b1wgen0050) THEN
                                        DELETE PROCEDURE b1wgen0050.
                                   END.
                               END.
                               ELSE
                               DO:
                                   RUN sistema/generico/procedures/b1wgen0050.p 
                                          PERSISTENT SET b1wgen0050.

                                   IF  VALID-HANDLE(b1wgen0050)  THEN DO:
                                       RUN grava-log-ted IN b1wgen0050 
                                                (INPUT aux_cdcooper,
                                                 INPUT TODAY,
                                                 INPUT TIME,
                                                 INPUT 1, /* origem */
                                                 INPUT glb_cdprogra,
                                                 INPUT 5, 
                                                 INPUT aux_nmarqxml,
                                                 INPUT aux_CodMsg,
                                                 INPUT aux_NumCtrlIF,
                                                 INPUT craplcs.vllanmto,
                                                 INPUT aux_cdbcoctl,
                                                 INPUT aux_cdagectl,
                                                 INPUT STRING(craplcs.nrdconta),
                                                 INPUT crapccs.nmfuncio,
                                                 INPUT crapccs.nrcpfcgc,
                                                 INPUT crapccs.cdbantrf,
                                                 INPUT crapccs.cdagetrf,
                                                 INPUT STRING(crapccs.nrctatrf)
                                                     + STRING(crapccs.nrdigtrf),
                                                 INPUT crapccs.nmfuncio,
                                                 INPUT crapccs.nrcpfcgc,
                                                 INPUT "",
                                                 INPUT par_msgderro,
                                                 INPUT 0, /*cdagenci*/
                                                 INPUT 0, /*nrdcaixa*/
                                                 INPUT "1",
                                                INPUT aux_ISPBIFCredtd,
                                                INPUT aux_inestcri).
                                      IF VALID-HANDLE(b1wgen0050) THEN
                                        DELETE PROCEDURE b1wgen0050.
                                   END.
                               END.
                           END.
                       END.
               END.
       END.
   ELSE
   IF  par_tipodlog = "RECEBIDA"  THEN  
       DO:
           FIND FIRST crapban WHERE crapban.nrispbif = INT(aux_ISPBIFDebtd) 
                      NO-LOCK NO-ERROR.
           
           IF   AVAIL crapban  THEN
                ASSIGN aux_BancoDeb = crapban.cdbccxlt.
                
           ASSIGN aux_BancoCre = aux_cdbcoctl. /* Banco CECRED */
           
           IF   aux_NumCtrlRem <> ""  THEN
                ASSIGN aux_nrctrole = aux_NumCtrlRem.
           ELSE
                ASSIGN aux_nrctrole = aux_NumCtrlIF.          

           IF  par_msgderro <> " "  THEN
               DO:
                   UNIX SILENT VALUE 
                   ("echo " + '"' + STRING(TODAY,"99/99/9999") + 
                    " - " + STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra + 
                    " - RECEBIDA NAO OK    --> " + 
                    "Arquivo " + STRING(aux_nmarqxml,"x(40)") + 
                    ". Evento: " + STRING(aux_CodMsg,"x(9)") +
                    ", Motivo Erro: " + STRING(par_msgderro,"x(90)") +
                    ", Numero Controle: " + STRING(aux_nrctrole,"x(20)") + 
                    ", Hora: " + STRING(TIME,"HH:MM:SS") + 
                    ", Valor: " + STRING(DEC(aux_VlrLanc),"zzz,zzz,zz9.99") + 
                    ", Banco Remet.: " + STRING(aux_BancoDeb,"zz9") +
                    ", Agencia Remet.: " + STRING(aux_AgDebtd,"x(4)") + 
                    ", Conta Remet.: " + STRING(aux_CtDebtd,
                                                "xxxxxxxxxxxxxx") +
                    ", Nome Remet.: " + STRING(aux_NomCliDebtd,"x(40)") + 
                    ", CPF/CNPJ Remet.: " + 
                    STRING(DEC(aux_CNPJ_CPFDeb),"zzzzzzzzzzzzz9") + 
                    ", Banco Dest.: " + STRING(aux_BancoCre,"zz9") + 
                    ", Agencia Dest.: " + STRING(aux_AgCredtd,"x(4)") + 
                    ", Conta Dest.: " + STRING(aux_CtCredtd,"xxxxxxxxxxxxxx") +
                    ", Nome Dest .: " + STRING(aux_NomCliCredtd,"x(40)")  + 
                    ", CPF/CNPJ Dest.: " +
                    STRING(DEC(aux_CNPJ_CPFCred),"zzzzzzzzzzzzz9") +
                    '"' +  ". >> " + aux_nmarqlog).

                    RUN sistema/generico/procedures/b1wgen0050.p 
                                          PERSISTENT SET b1wgen0050.

                    IF  VALID-HANDLE(b1wgen0050)  THEN DO:
                        RUN grava-log-ted IN b1wgen0050 
                                           (INPUT aux_cdcooper,
                                            INPUT TODAY,
                                            INPUT TIME,
                                            INPUT 1, /* origem */
                                            INPUT glb_cdprogra,
                                            INPUT 4, 
                                            INPUT aux_nmarqxml,
                                            INPUT aux_CodMsg,
                                            INPUT aux_nrctrole,
                                            INPUT DEC(aux_VlrLanc),
                                            INPUT aux_BancoCre,
                                            INPUT aux_AgCredtd,
                                            INPUT aux_CtCredtd,
                                            INPUT aux_NomCliCredtd,
                                            INPUT DEC(aux_CNPJ_CPFCred),
                                            INPUT aux_BancoDeb,
                                            INPUT aux_AgDebtd,
                                            INPUT aux_CtDebtd,
                                            INPUT aux_NomCliDebtd,
                                            INPUT DEC(aux_CNPJ_CPFDeb),
                                            INPUT "",
                                            INPUT par_msgderro,
                                            INPUT 0, /*cdagenci*/
                                            INPUT 0, /*nrdcaixa*/
                                            INPUT "1",
                                            INPUT aux_ISPBIFDebtd,
                                            INPUT aux_inestcri).
                        IF VALID-HANDLE(b1wgen0050) THEN
                            DELETE PROCEDURE b1wgen0050.             
                    END. 
               END.
           ELSE
               DO:
                  UNIX SILENT VALUE 
                  ("echo " + '"' + STRING(TODAY,"99/99/9999") + " - " +
                   STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra + 
                   " - RECEBIDA OK        --> "  + 
                   "Arquivo " + STRING(aux_nmarqxml,"x(40)") + 
                   ". Evento: " + STRING(aux_CodMsg,"x(9)") +
                   ", Numero Controle: " + STRING(aux_nrctrole,"x(20)") +
                   ", Hora: " + STRING(TIME,"HH:MM:SS") + 
                   ", Valor: " + STRING(DEC(aux_VlrLanc),"zzz,zzz,zz9.99") + 
                   ", Banco Remet.: " + STRING(aux_BancoDeb,"zz9") +
                   ", Agencia Remet.: " + STRING(aux_AgDebtd,"x(4)") + 
                   ", Conta Remet.: " + STRING(aux_CtDebtd,
                                               "xxxxxxxxxxxxxx") +
                   ", Nome Remet.: " + STRING(aux_NomCliDebtd,"x(40)") + 
                   ", CPF/CNPJ Remet.: " + 
                    STRING(DEC(aux_CNPJ_CPFDeb),"zzzzzzzzzzzzz9") +  
                   ", Banco Dest.: " + STRING(aux_BancoCre,"zz9") + 
                   ", Agencia Dest.: " + STRING(aux_AgCredtd,"x(4)") + 
                   ", Conta Dest.: " + STRING(aux_CtCredtd,"xxxxxxxxxxxxxx") +
                   ", Nome Dest .: " + STRING(aux_NomCliCredtd,"x(40)")  + 
                   ", CPF/CNPJ Dest.: " +
                    STRING(DEC(aux_CNPJ_CPFCred),"zzzzzzzzzzzzz9") +
                   '"' +  ". >> " + aux_nmarqlog).

                   RUN sistema/generico/procedures/b1wgen0050.p 
                                          PERSISTENT SET b1wgen0050.

                    IF  VALID-HANDLE(b1wgen0050)  THEN DO:
                        RUN grava-log-ted IN b1wgen0050 
                                           (INPUT aux_cdcooper,
                                            INPUT TODAY,
                                            INPUT par_hrtransa,
                                            INPUT 1, /* origem */
                                            INPUT glb_cdprogra,
                                            INPUT 3, 
                                            INPUT aux_nmarqxml,
                                            INPUT aux_CodMsg,
                                            INPUT aux_nrctrole,
                                            INPUT DEC(aux_VlrLanc),
                                            INPUT aux_BancoCre,
                                            INPUT aux_AgCredtd,
                                            INPUT aux_CtCredtd,
                                            INPUT aux_NomCliCredtd,
                                            INPUT DEC(aux_CNPJ_CPFCred),
                                            INPUT aux_BancoDeb,
                                            INPUT aux_AgDebtd,
                                            INPUT aux_CtDebtd,
                                            INPUT aux_NomCliDebtd,
                                            INPUT DEC(aux_CNPJ_CPFDeb),
                                            INPUT "",
                                            INPUT par_msgderro,
                                            INPUT 0, /*cdagenci*/
                                            INPUT 0, /*nrdcaixa*/
                                            INPUT "1",
                                            INPUT aux_ISPBIFDebtd,
                                            INPUT aux_inestcri).
                        IF VALID-HANDLE(b1wgen0050) THEN
                            DELETE PROCEDURE b1wgen0050.             
                    END.
               END.
       END.
   ELSE
   IF  par_tipodlog = "SPB-STR-IF"  THEN
       UNIX SILENT VALUE ("echo " + '"' + STRING(TODAY,"99/99/9999") + 
                          " - " + STRING(TIME,"HH:MM:SS") + " - " +
                          glb_cdprogra + " - " + STRING(aux_CodMsg,"x(18)") +
                          " --> "  +
                          "Arquivo " + STRING(aux_nmarqxml,"x(40)") + ". " +
                          par_msgderro + " => ISPB " + STRING(aux_nrispbif) + 
                          '"' + ". >> " + aux_nmarqlog).  
   ELSE
   IF  par_tipodlog = "PAG0101"  THEN
       UNIX SILENT VALUE ("echo " + '"' + STRING(TODAY,"99/99/9999") + 
                          " - " + STRING(TIME,"HH:MM:SS") + " - " +
                          glb_cdprogra + " - " + STRING(aux_CodMsg,"x(18)") +
                          " --> "  +
                          "Arquivo " + STRING(aux_nmarqxml,"x(40)") + " " +                          
                          '"' + ". >> " + aux_nmarqlog).  

END PROCEDURE.


PROCEDURE trata_CABInf.

   ASSIGN aux_tagCABInf = TRUE.
                
   /** Busca nodos filhos **/
   DO  aux_contado1 = 1 TO hNode:NUM-CHILDREN:
    
       /** Obtem a TAG **/
       hNode:GET-CHILD(hNameTag,aux_contado1).
            
       IF   hNameTag:SUBTYPE <> 'ELEMENT' THEN
            NEXT.

       IF   hNameTag:NAME = "CodMsg"  THEN
            DO:
                /** Obtem conteudo da TAG **/
                hNameTag:GET-CHILD(hTextTag,1).
                
                ASSIGN aux_CodMsg = hTextTag:NODE-VALUE.
            END.
       ELSE
       IF   hNameTag:NAME = "NumCtrlIF"  THEN
            DO:
                /** Obtem conteudo da TAG **/
                hNameTag:GET-CHILD(hTextTag,1).
                         
                /** Numero de Controle da Cooperativa **/
                ASSIGN aux_NumCtrlIF = hTextTag:NODE-VALUE.
            END.
       ELSE
       IF   hNameTag:NAME = "GrupoTagErro" THEN  /* Erro de inconsistencia */ 
            /** Busca nodos filhos **/
            DO  aux_contado2 = 1 TO hNameTag:NUM-CHILDREN:
                         
                /** Obtem a TAG **/
                hNameTag:GET-CHILD(hTextTag,aux_contado2).
                         
                IF   hTextTag:SUBTYPE <> 'ELEMENT' THEN
                     NEXT.
                                
                IF   hTextTag:NAME = "CodErro"  THEN
                     DO:
                         /** Obtem conteudo da TAG **/ 
                         hTextTag:GET-CHILD(hTextTag2,1).
                                    
                         /** Armazena o codigo do erro **/
                         IF   aux_msgderro <> " "  THEN
                              ASSIGN aux_msgderro = aux_msgderro + ", " +
                                                    hTextTag2:NODE-VALUE.
                         ELSE
                              ASSIGN aux_msgderro = hTextTag2:NODE-VALUE.
                     END.                

                IF   hTextTag:NAME = "TagErro"  THEN
                     DO:
                         /** Obtem conteudo da TAG **/ 
                         hTextTag:GET-CHILD(hTextTag2,1).
                                    
                         /** Armazena o nome das TAGS que apresentaram erro **/
                         ASSIGN aux_msgderro = aux_msgderro + "-" +
                                               hTextTag2:NODE-VALUE.
                     END.
            END.
   END.
                         
END PROCEDURE.


PROCEDURE trata_IFs.

   ASSIGN aux_nrispbif = 0
          aux_cddbanco = 0
          aux_nmdbanco = "".
   
   /** Busca nodos filhos de PAG0101/STR0018/STR0019 **/               
   DO  aux_contado1 = 1 TO hNode:NUM-CHILDREN:
    
       /** Obtem a TAG **/
       hNode:GET-CHILD(hSubNode,aux_contado1).
                                             
       IF   hSubNode:SUBTYPE <> 'ELEMENT' THEN
            NEXT.                     

       IF   hSubNode:NAME = "Grupo_PAG0101_SitIF"  THEN    
            DO:
                ASSIGN aux_CodMsg = "PAG0101".
                                                                                                          
                CREATE tt-situacao-if.
                        
                /** Busca os dados da IF Ativa **/
                DO aux_contado2 = 1 TO hSubNode:NUM-CHILDREN:
                         
                   hSubNode:GET-CHILD(hNameTag,aux_contado2).
                                         
                   IF  hNameTag:SUBTYPE <> 'ELEMENT' THEN
                       NEXT.         
                               
                   hNameTag:GET-CHILD(hTextTag,1).
                        
                   IF   hNameTag:NAME = "ISPBIF" THEN
                        ASSIGN tt-situacao-if.nrispbif =
                                              INT(hTextTag:NODE-VALUE).
                   ELSE
                        ASSIGN tt-situacao-if.cdsitope =
                                              INT(hTextTag:NODE-VALUE).
                                                                                                                                           
                END.            
            END.
       ELSE
            DO:
                 /** Obtem conteudo da Tag  **/
                 hSubNode:GET-CHILD(hSubNode2,1) NO-ERROR.
                 
                 ASSIGN aux_descrica = hSubNode2:NODE-VALUE.

                 IF   hSubNode:NAME = "CodMsg"  THEN
                      ASSIGN aux_CodMsg = aux_descrica.
                 ELSE
                 IF   hSubNode:NAME = "CodProdt"  THEN
                      ASSIGN aux_CodProdt = aux_descrica.
                 ELSE
                 IF   hSubNode:NAME = "ISPBPartIncld_Altd"  OR
                      hSubNode:NAME = "ISPBPartExcl"  THEN
                      ASSIGN aux_nrispbif = INT(aux_descrica).
                 ELSE
                 IF   hSubNode:NAME = "NumCodIF"  THEN
                      ASSIGN aux_cddbanco = INT(aux_descrica).
                 ELSE
                 IF   hSubNode:NAME = "NomPart"  THEN
                      ASSIGN aux_nmdbanco = aux_descrica.
                  ELSE
                 IF   hSubNode:NAME = "DtIniOp"  THEN
                      ASSIGN aux_dtinispb = aux_descrica.
            END.
   END.

END PROCEDURE.


PROCEDURE trata_dados_transferencia.

   /** Efetua leitura dos dados da mensagem **/
   DO  aux_contado1 = 1 TO hNode:NUM-CHILDREN:
            
       /** Obtem a TAG **/
       hNode:GET-CHILD(hNameTag,aux_contado1).
                  
       IF   hnametag:SUBTYPE <> 'ELEMENT'  THEN
            NEXT.
                  
       /** Obtem conteudo da Tag  **/
       hNameTag:GET-CHILD(hTextTag,1) NO-ERROR.
              
       ASSIGN aux_descrica = hTextTag:NODE-VALUE.

       IF   hNameTag:NAME = "CodMsg"  THEN
            DO:
                ASSIGN aux_CodMsg = aux_descrica.
                
                /* Nas mensagens de devolucao, o Numero de Controle Original
                   gerado pela cooperativa eh obtido pela TAG <NR_OPERACAO> */
                   
                IF   CAN-DO("STR0010R2,PAG0111R2",aux_CodMsg)  THEN
                     ASSIGN aux_NumCtrlIF = aux_NrOperacao.
                
            END.
       ELSE                
       IF   hNameTag:NAME = "NumCtrlIF"  THEN
            /* Numero de Controle da Cooperativa */
            ASSIGN aux_NumCtrlIF = aux_descrica.
       ELSE
       IF   hNameTag:NAME = "NumCtrlSTR"  OR
            hNameTag:NAME = "NumCtrlPAG"   THEN
            /* Numero de Controle do Remetente */
            ASSIGN aux_NumCtrlRem = aux_descrica.
       ELSE
       IF   hNameTag:NAME = "ISPBIFDebtd"  THEN
            ASSIGN aux_ISPBIFDebtd = aux_descrica.
       ELSE
       IF   hNameTag:NAME = "AgDebtd"           OR
            hNameTag:NAME = "CtDebtd"           OR
            hNameTag:NAME = "CPFCliDebtd"       OR   /* esta nas TEC'S */ 
            hNameTag:NAME = "CNPJ_CPFCliDebtd"  OR 
            hNameTag:NAME = "CNPJ_CPFCliDebtdTitlar1"  OR
            hNameTag:NAME = "CNPJ_CPFCliDebtdTitlar2"  OR
            hNameTag:NAME = "CNPJ_CPFRemet"            THEN    
            DO:
                IF   hNameTag:NAME = "AgDebtd"  THEN
                     ASSIGN aux_AgDebtd = aux_descrica.
                ELSE
                IF   hNameTag:NAME = "CtDebtd"  THEN
                     ASSIGN aux_CtDebtd = aux_descrica.
                ELSE
                IF   hNameTag:NAME = "CPFCliDebtd"  THEN
                     ASSIGN aux_CNPJ_CPFCred = aux_descrica
                            aux_CNPJ_CPFDeb  = aux_descrica. 
                ELSE
                IF   hNameTag:NAME = "CNPJ_CPFCliDebtd"  OR
                     hNameTag:NAME = "CNPJ_CPFCliDebtdTitlar1"  OR 
                     hNameTag:NAME = "CNPJ_CPFCliDebtdTitlar2"  OR
                     hNameTag:NAME = "CNPJ_CPFRemet"  THEN
                     DO:
                         ASSIGN aux_CNPJ_CPFDeb  = aux_descrica.
                     END.
                       
                IF   aux_dadosdeb = ""  THEN
                     ASSIGN aux_dadosdeb = hNameTag:NAME + ":" +
                                           aux_descrica.
                ELSE
                     ASSIGN aux_dadosdeb = aux_dadosdeb + " / " +
                                           hNameTag:NAME + ":" +
                                           aux_descrica.
            END.
       ELSE
       IF   hNameTag:NAME = "NomCliDebtd"  OR
            hNameTag:NAME = "NomCliDebtdTitlar1"  OR
            hNameTag:NAME = "NomRemet"  THEN
            DO:
                ASSIGN aux_NomCliDebtd = aux_descrica.
                       
                /* Transferencia entre mesma titularidade */
                IF   CAN-DO
                    ("STR0037R2,PAG0137R2,",aux_CodMsg) THEN
                    DO:
                        ASSIGN aux_NomCliCredtd = aux_descrica.
                    END.
                     
            END.
       ELSE
       IF   hNameTag:NAME = "NomCliCredtd"  OR
            hNameTag:NAME = "NomDestinatario"  OR  
            hNameTag:NAME = "NomCliCredtdTitlar1"  THEN
            DO:
                ASSIGN aux_NomCliCredtd = aux_descrica.
            END.
       ELSE
       IF   hNameTag:NAME = "ISPBIFCredtd" THEN
            ASSIGN aux_ISPBIFCredtd = aux_descrica.
       ELSE
       IF   hNameTag:NAME = "AgCredtd"  THEN                            
            ASSIGN aux_AgCredtd = aux_descrica.
       ELSE
       IF   hNameTag:NAME = "TpPessoaCredtd"  OR
            hNameTag:NAME = "TpPessoaDestinatario"  THEN  
            ASSIGN aux_TpPessoaCred = aux_descrica.
       ELSE
       IF  hNameTag:NAME = "CNPJ_CPFCliCredtd"  OR
           hNameTag:NAME = "CNPJ_CPFDestinatario"  OR   
           hNameTag:NAME = "CNPJ_CPFCliCredtdTitlar1"  THEN  
           ASSIGN aux_CNPJ_CPFCred = aux_descrica.
       ELSE
       IF  hNameTag:NAME = "CtCredtd"  THEN
           ASSIGN aux_CtCredtd = aux_descrica.
       ELSE
       IF  hNameTag:NAME = "VlrLanc"  THEN 
           ASSIGN aux_VlrLanc = aux_descrica
                  aux_VlrLanc = REPLACE(aux_VlrLanc,".",",").
       ELSE
       IF  hNameTag:NAME = "NumCodBarras" THEN
           DO:
               IF aux_CodMsg = "STR0026R2" THEN
                  ASSIGN aux_NumCodBarras = aux_descrica.
           END.
       ELSE
       IF  hNameTag:NAME = "SitLancSTR"  OR 
           hNameTag:NAME = "SitLancPAG"  THEN
           ASSIGN aux_SitLanc = aux_descrica.
       ELSE
       IF  hNameTag:NAME = "CodDevTransf"  THEN
           ASSIGN aux_CodDevTransf = aux_descrica.
       ELSE
       IF  hNameTag:NAME = "DtMovto"  THEN
           ASSIGN aux_DtMovto = aux_descrica.
                   
   END.

END PROCEDURE.


PROCEDURE trata_lancamentos.

   DEF VAR aux_cdhistor AS INT.
   DEF VAR aux_hrtransa AS INTE.
   DEF VAR aux_dtmvtolt AS DATE.
     
   /* Se nao estiver em estado de crise verifica processo */
   RUN verifica_processo_crise.
   IF   RETURN-VALUE <> "OK"   THEN
        RETURN.       
                                
   ASSIGN aux_dtmvtolt = IF   aux_flestcri = 0
                         THEN crabdat.dtmvtolt
                         ELSE aux_dtintegr.

   /* Agencia CECRED -  Banco CECRED */  
   DO aux_contlock = 1 TO 10:
  
      FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper  AND
                         craplot.dtmvtolt = aux_dtmvtolt      AND
                         craplot.cdagenci = aux_cdagenci      AND
                         craplot.cdbccxlt = crabcop.cdbcoctl  AND
                         craplot.nrdolote = aux_nrdolote 
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      IF    NOT AVAIL craplot  THEN
            IF   LOCKED craplot   THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                LEAVE.
                 
      
   END.

   IF   NOT AVAIL craplot   THEN
        DO: 
            RUN deleta_objetos.
            RETURN.
        END.

   /**** Como no campo CodMsg do XML de rejeicao vem o codigo da 
         mensagem gerada pela cooperativa, sera gravado 
         gnmvcen.dsmensag = MSGREJ quando a rejeicao ocorrer com
         sucesso, e ERROREJ quando nao ocorrer por alguma critica. 
         Esta informacao sera utilizada para contabilizacao das 
         mensagens rejeitadas no relatorio crrl536. No LOG ira constar
         o codigo da mensagem original. ****/

   IF   aux_tagCABInf THEN  /* Rejeitada pela cabine */
        DO:
            /* Gera devolucao com mesmo numero de documento da mensagem gerada
               pelo Legado */
            ASSIGN aux_nrdocmto = DEC(SUBSTRING(aux_NumCtrlIF,
                                            LENGTH(aux_NumCtrlIF) - 8,8))
                   aux_msgrejei = aux_CodMsg.
            
            IF  CAN-DO("STR0010,PAG0111,STR0048",aux_CodMsg)  THEN
                DO:
                    RUN gera_logspb (INPUT "REJEITADA OK",
                                     INPUT "Rejeitada pela cabine",
                                     INPUT TIME).

                    ASSIGN aux_CodMsg = "MSGREJ".
                    
                    /* Cria registro das movimentacoes no SPB */
                    RUN cria_gnmvcen (INPUT crabcop.cdagectl,
                                      INPUT crabdat.dtmvtolt,
                                      INPUT aux_CodMsg,
                                      INPUT "C",
                                      INPUT DEC(aux_VlrLanc)).

                    RUN salva_arquivo. 
                    RUN deleta_objetos.
                    NEXT.
                
                END.
        END.
   ELSE
   IF   CAN-DO("STR0010R2,PAG0111R2",aux_CodMsg)  THEN
        /* Gera devolucao com mesmo numero de documento da mensagem gerada
           pelo Legado */
        ASSIGN aux_nrdocmto = DEC(SUBSTRING(aux_NumCtrlIF,
                                            LENGTH(aux_NumCtrlIF) - 8,8)).
   ELSE
   IF   LENGTH(aux_NumCtrlRem) >= 7 THEN
        ASSIGN aux_nrdocmto = DEC(SUBSTRING(aux_NumCtrlRem,
                                            LENGTH(aux_NumCtrlRem) - 7)).


        
        /* Estorno TEC */       
   IF  (CAN-DO("STR0010R2,PAG0111R2",aux_CodMsg)  OR aux_tagCABInf)  AND  
        SUBSTRING(aux_NumCtrlIF,1,1) = "2"  THEN      
        DO:
            DO aux_contlock = 1 TO 10:

               /* Busca numero da conta a CREDITAR */
               FIND FIRST craplcs WHERE 
                          craplcs.cdcooper = crabcop.cdcooper  AND
                          craplcs.idopetrf = aux_NumCtrlIF 
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        
               IF   NOT AVAIL craplcs    THEN
                    IF   LOCKED craplcs   THEN
                         DO:
                             ASSIGN aux_dscritic = 
                                 "Registro craplcs sendo alterado".
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                         END.
                    ELSE
                         DO:
                            ASSIGN aux_dscritic = 
                                "Numero de Controle invalido".
                            LEAVE.
                         END.

               ASSIGN aux_dscritic = "".
               LEAVE.

            END.

            IF   LOCKED craplcs   THEN
                 NEXT.

            IF   NOT AVAIL craplcs  THEN
                 DO:
                     IF   aux_tagCABInf  THEN
                          DO: 
                              RUN gera_logspb
                                  (INPUT "REJEITADA NAO OK",
                                   INPUT aux_dscritic,
                                   INPUT TIME).
                                   
                              ASSIGN aux_CodMsg = "ERROREJ".
                          END.
                     ELSE
                          RUN gera_logspb
                                  (INPUT "RETORNO SPB",
                                   INPUT aux_dscritic,
                                   INPUT TIME).

                     /* Cria registro das movimentacoes no SPB */
                     RUN cria_gnmvcen (INPUT crabcop.cdagectl,
                                       INPUT crabdat.dtmvtolt,
                                       INPUT aux_CodMsg,
                                       INPUT "C",
                                       INPUT DEC(aux_VlrLanc)).
                         
                     RUN salva_arquivo.
                     RUN deleta_objetos.
                     NEXT.
                 END.

            /* Tratamento para a nova FOLHAIB*/
           IF craplcs.nrridlfp <> 0 THEN
            DO:
               IF   aux_tagCABInf  THEN
                 ASSIGN aux_VlrLanc      = STRING(craplcs.vllanmto)
                        craplcs.flgopfin = TRUE   /*Finaliz.*/
                        aux_flgopfin     = FALSE. /* Registro Devolução que não chegou a IF*/ 
                        
                ELSE
                    ASSIGN aux_flgopfin = TRUE.  
               
                ASSIGN aux_nrctacre = craplcs.nrdconta.
                
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
               /*** Faz a busca do historico da transação ***/
               RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
                   aux_ponteiro = PROC-HANDLE
                   ("SELECT gene0001.fn_param_sistema('CRED','" +
                    STRING(crabcop.cdcooper) + "','FOLHAIB_HIST_REC_TECSAL') FROM dual").
            
               FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
                   ASSIGN aux_cdhistor = INT(proc-text).
               END.
            
               CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
                   WHERE PROC-HANDLE = aux_ponteiro.
            
               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

               
               ASSIGN aux_nrridlfp = craplcs.nrridlfp.

        
                /* Verificar se ja existe Lancamento*/
                FIND craplcs WHERE craplcs.cdcooper = crabcop.cdcooper AND
                                   craplcs.dtmvtolt = crabdat.dtmvtolt AND
                                   craplcs.nrdconta = aux_nrctacre     AND
                                   craplcs.cdhistor = aux_cdhistor     AND
                                   craplcs.nrdocmto = aux_nrdocmto
                                   NO-LOCK NO-ERROR.
                            
                IF  AVAIL craplcs  THEN
                    DO:
                        ASSIGN log_msgderro = 
                               "Lancamento ja existe! Conta: " +
                               STRING(aux_nrctacre) + 
                               ", Valor: " + 
                               STRING(craplcs.vllanmto,"zzz,zzz,zz9.99")
                               + ", Lote: " + STRING(aux_nrdolote) +
                               ", Doc.: " + STRING(aux_nrdocmto).
                        
                        IF   aux_tagCABInf  THEN
                             DO:
                                 RUN gera_logspb (INPUT "REJEITADA NAO OK",
                                                  INPUT log_msgderro,
                                                  INPUT TIME).
                                 
                                 ASSIGN aux_CodMsg = "ERROREJ".
                             END.
                        ELSE
                             RUN gera_logspb (INPUT "RETORNO SPB",
                                              INPUT log_msgderro,
                                              INPUT TIME).
                                     
                        /* Cria registro das movimentacoes no SPB */
                        RUN cria_gnmvcen (INPUT crabcop.cdagectl,
                                          INPUT crabdat.dtmvtolt,
                                          INPUT aux_CodMsg,
                                          INPUT "C",
                                          INPUT craplcs.vllanmto).
    
                        RUN salva_arquivo.  
                        RUN deleta_objetos.
                        NEXT.
                    END.
                
                  

                CREATE craplcs.
                ASSIGN craplcs.cdcooper = crabcop.cdcooper
                       craplcs.dtmvtolt = crabdat.dtmvtolt
                       craplcs.nrdconta = aux_nrctacre
                       
                       /* Estorno TEC */
                       craplcs.cdhistor = aux_cdhistor
                       craplcs.nrdocmto = aux_nrdocmto
                       craplcs.vllanmto = DEC(aux_VlrLanc)
                       craplcs.nrdolote = craplot.nrdolote 
                       craplcs.cdbccxlt = craplot.cdbccxlt
                       craplcs.cdagenci = craplot.cdagenci
                       craplcs.flgenvio = NO
                       craplcs.flgopfin = aux_flgopfin
                       craplcs.cdopetrf = "1"
                       craplcs.cdopecrd = "1"
                       craplcs.cdsitlcs = 1
                       craplcs.dttransf = crabdat.dtmvtolt
                       craplcs.hrtransf = TIME
                       craplcs.idopetrf = aux_NumCtrlIF
                       craplcs.nmarqenv = ""
                       craplcs.nrautdoc = 0
                       craplcs.nrridlfp = aux_nrridlfp.
                VALIDATE craplcs.       
    
                ASSIGN craplot.vlcompcr = craplot.vlcompcr + 
                                          craplcs.vllanmto
                       craplot.vlinfocr = craplot.vlinfocr +
                                          craplcs.vllanmto.
                
    
                IF  aux_tagCABInf  THEN
                DO:
                    ASSIGN aux_CodMsg = "MSGREJ".
                    
                     FIND crapccs WHERE  
                                crapccs.cdcooper = craplcs.cdcooper  AND
                                crapccs.nrdconta = craplcs.nrdconta
                                NO-LOCK NO-ERROR.
                                
                    /*ENVIAR E-MAIL informando o financeiro*/

                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                   
                   /*** Faz a busca do destinatario do email ***/
                   RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
                       aux_ponteiro = PROC-HANDLE
                       ("SELECT gene0001.fn_param_sistema('CRED','" +
                        STRING(crabcop.cdcooper) + "','FOLHAIB_EMAIL_ALERT_FIN') FROM dual").
                
                   FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
                       ASSIGN aux_emaildes = STRING(proc-text).
                   END.
               
                   CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
                       WHERE PROC-HANDLE = aux_ponteiro.
                
                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                    ASSIGN aux_dsmensag = "Ola, houve rejeicao na cabine da seguinte operacao TEC Salario: <br><br>" +
                                          " Conta/Dv: " + STRING(craplcs.nrdconta)   + " <br>" +
                                          " PA: " + STRING(craplcs.cdagenci)         + " <br>" +
                                          " Dt.Credito: " + STRING(craplcs.dtmvtolt) + " <br>" +
                                          " Dt.Transferencia: " + STRING(craplcs.dttransf) + " <br>" +
                                          " Valor: " + STRING(craplcs.vllanmto)  + " <br>" +
                                          " Age: " + STRING(crapccs.cdagetrf)    + " <br>" +
                                          " Conta TRF: " + STRING(crapccs.nrctatrf) + ". <br><br>" +
                                          " Lembramos que voce tera o dia de hoje e o proximo dia util para reprocessa-la na tela TRFSAL opcao X. " + 
                                          " Do contrario este lancamento sera devolvido automaticamente para a Empresa. " +
                                          " Voce tambem podera utilizar a opcao E para efetuar o Estorno antecipado, caso nao deseje esperar ate o final do proximo dia util para o devido estorno. <br><br> " +
                                          " Atenciosamente, <br> " +
                                          " Sistemas Cecred.".                                                        
                                                        
                  /* Enviar e-mail informando para a empresa a falta de saldo. */
                  RUN sistema/generico/procedures/b1wgen0011.p
                     PERSISTENT SET b1wgen0011.
                  
                  RUN solicita_email_oracle IN b1wgen0011
                                 ( INPUT  crabcop.cdcooper    /* par_cdcooper         */
                                  ,INPUT  "FOLH0001"          /* par_cdprogra         */
                                  ,INPUT  TRIM(aux_emaildes)  /* par_des_destino      */
                                  ,INPUT  "Folha de Pagamento - Rejeicao TEC na Cabine"         /* par_des_assunto      */
                                  ,INPUT  aux_dsmensag        /* par_des_corpo        */
                                  ,INPUT  ""                  /* par_des_anexo        */
                                  ,INPUT  "N"                 /* par_flg_remove_anex  */
                                  ,INPUT  "N"                 /* par_flg_remete_coop  */
                                  ,INPUT  ""                  /* par_des_nome_reply   */
                                  ,INPUT  ""                  /* par_des_email_reply  */
                                  ,INPUT  "N"                 /* par_flg_log_batch    */
                                  ,INPUT  "S"                 /* par_flg_enviar       */
                                  ,OUTPUT aux_dscritic        /* par_des_erro         */
                                   ).
                  
                  DELETE PROCEDURE b1wgen0011. 
                
                  IF aux_dscritic <> "" THEN
                  DO:
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - FOLH0001 ' --> '"  +
                                            "Erro ao rodar: " + 
                                            "'" + aux_dscritic + "'" + " >> log/proc_batch.log").
                    aux_dscritic = "".
                  END.

                END.                     
                
                /* Cria registro das movimentacoes no SPB */
                RUN cria_gnmvcen (INPUT crabcop.cdagectl,
                                  INPUT crabdat.dtmvtolt,
                                  INPUT aux_CodMsg,
                                  INPUT "C",
                                  INPUT DEC(aux_VlrLanc)).

             END.
            ELSE /*Procedimento normal*/
            DO:
                IF   aux_tagCABInf  THEN
                     ASSIGN aux_VlrLanc      = STRING(craplcs.vllanmto)
                            craplcs.flgopfin = TRUE /*Finaliz.*/
                            aux_cdhistor     = 887. /* Estorno TEC Rejeitado*/
                ELSE
                     ASSIGN aux_cdhistor = 801. 
                     
                ASSIGN aux_nrctacre = craplcs.nrdconta.
                       
                /* Verificar se ja existe Lancamento*/
                FIND craplcs WHERE craplcs.cdcooper = crabcop.cdcooper AND
                                   craplcs.dtmvtolt = crabdat.dtmvtolt AND
                                   craplcs.nrdconta = aux_nrctacre     AND
                                   craplcs.cdhistor = aux_cdhistor     AND
                                   craplcs.nrdocmto = aux_nrdocmto
                                   NO-LOCK NO-ERROR.
                            
                IF  AVAIL craplcs  THEN
                    DO:
                        ASSIGN log_msgderro = 
                               "Lancamento ja existe! Conta: " +
                               STRING(aux_nrctacre) + 
                               ", Valor: " + 
                               STRING(craplcs.vllanmto,"zzz,zzz,zz9.99")
                               + ", Lote: " + STRING(aux_nrdolote) +
                               ", Doc.: " + STRING(aux_nrdocmto).
                        
                        IF   aux_tagCABInf  THEN
                             DO:
                                 RUN gera_logspb (INPUT "REJEITADA NAO OK",
                                                  INPUT log_msgderro,
                                                  INPUT TIME).
                                 
                                 ASSIGN aux_CodMsg = "ERROREJ".
                             END.
                        ELSE
                             RUN gera_logspb (INPUT "RETORNO SPB",
                                              INPUT log_msgderro,
                                              INPUT TIME).
                                     
                        /* Cria registro das movimentacoes no SPB */
                        RUN cria_gnmvcen (INPUT crabcop.cdagectl,
                                          INPUT crabdat.dtmvtolt,
                                          INPUT aux_CodMsg,
                                          INPUT "C",
                                          INPUT craplcs.vllanmto).
    
                        RUN salva_arquivo.  
                        RUN deleta_objetos.
                        NEXT.
                    END.
    
                CREATE craplcs.
                ASSIGN craplcs.cdcooper = crabcop.cdcooper
                       craplcs.dtmvtolt = crabdat.dtmvtolt
                       craplcs.nrdconta = aux_nrctacre
                       
                       /* Estorno TEC */
                       craplcs.cdhistor = aux_cdhistor
                       craplcs.nrdocmto = aux_nrdocmto
                       craplcs.vllanmto = DEC(aux_VlrLanc)
                       craplcs.nrdolote = craplot.nrdolote 
                       craplcs.cdbccxlt = craplot.cdbccxlt
                       craplcs.cdagenci = craplot.cdagenci
                       craplcs.flgenvio = TRUE
                       craplcs.flgopfin = TRUE
                       craplcs.cdopetrf = "1"
                       craplcs.cdopecrd = "1"
                       craplcs.cdsitlcs = 1
                       craplcs.dttransf = crabdat.dtmvtolt
                       craplcs.hrtransf = TIME
                       craplcs.idopetrf = aux_NumCtrlIF
                       craplcs.nmarqenv = ""
                       craplcs.nrautdoc = 0.
                VALIDATE craplcs.       
    
                ASSIGN craplot.vlcompcr = craplot.vlcompcr + 
                                          craplcs.vllanmto
                       craplot.vlinfocr = craplot.vlinfocr +
                                          craplcs.vllanmto.
                
    
                IF   aux_tagCABInf  THEN
                     ASSIGN aux_CodMsg = "MSGREJ".
                
                /* Cria registro das movimentacoes no SPB */
                RUN cria_gnmvcen (INPUT crabcop.cdagectl,
                                  INPUT crabdat.dtmvtolt,
                                  INPUT aux_CodMsg,
                                  INPUT "C",
                                  INPUT DEC(aux_VlrLanc)).
            END.
         /*******************/
            
        END.                     
   ELSE     
        /* Eh ESTORNO de TED ou CREDITO de TED/TEC */
        DO: 
            /* Verifica se dados do pagamento da portabilidade conferem.
               Caso contrario gera devolucao(STR0048) */
            IF  aux_CodMsg = "STR0047R2"  THEN
                DO:
                   /* Identifica a IF Credora Original(Coop. Filiada) */ 
                   FIND FIRST b-crabcop WHERE
                              b-crabcop.nrctactl = INT(aux_CtCredtd) /*c/c filiada na Central*/
                        NO-LOCK NO-ERROR.

                   IF  NOT AVAIL b-crabcop THEN
                       DO:
                           ASSIGN log_msgderro = "Erro de sistema: Registro da cooperativa nao encontrado.".
            
                           RUN gera_logspb (INPUT "RECEBIDA",
                                            INPUT log_msgderro,
                                            INPUT TIME).
                 
                           RUN salva_arquivo.
                           RUN deleta_objetos.
                           NEXT.
                       END.

                   FIND b-crabdat WHERE b-crabdat.cdcooper = b-crabcop.cdcooper NO-LOCK NO-ERROR.

                   IF  NOT AVAIL b-crabdat THEN
                       DO:
                           ASSIGN log_msgderro = "Erro de sistema: Registro de data nao encontrado.".
            
                           RUN gera_logspb (INPUT "RECEBIDA",
                                            INPUT log_msgderro,
                                            INPUT TIME).
                 
                           RUN salva_arquivo.
                           RUN deleta_objetos.
                           NEXT.
                       END.
                       
                   /* LOG de erros na cooperativa filiada ref. operacao de Liquidacao */        
                   ASSIGN aux_nmlogprt = "/usr/coop/" + b-crabcop.dsdircop + 
                                         "/log/logprt.log".    

                   /* Busca o registro de portabilidade aprovada na coop. 
                      filiada */ 
                   FIND FIRST tbepr_portabilidade WHERE 
                              tbepr_portabilidade.cdcooper = b-crabcop.cdcooper AND
                              tbepr_portabilidade.nrunico_portabilidade = aux_NUPortdd
                              NO-LOCK NO-ERROR.
                       
                   IF   AVAIL tbepr_portabilidade THEN
                        DO:            
                           /* Identifica o contrato a ser liquidado */ 
                           FIND crapepr WHERE 
                                crapepr.cdcooper = tbepr_portabilidade.cdcooper AND
                                crapepr.nrdconta = tbepr_portabilidade.nrdconta AND
                                crapepr.nrctremp = tbepr_portabilidade.nrctremp
                                NO-LOCK NO-ERROR.                       
       
                           IF  AVAIL crapepr THEN
                               DO:
                                   FIND crapass WHERE 
                                        crapass.cdcooper = crapepr.cdcooper  AND
                                        crapass.nrdconta = crapepr.nrdconta  
                                        NO-LOCK NO-ERROR.

                                   ASSIGN aux_nrctremp = crapepr.nrctremp
                                          aux_tpemprst = crapepr.tpemprst. /*PP ou TR*/
                      
                                   RUN sistema/generico/procedures/b1wgen0002.p
                                       PERSISTENT SET h-b1wgen0002.
                      
                                   IF  NOT VALID-HANDLE (h-b1wgen0002)  THEN
                                       DO:
                                           ASSIGN log_msgderro = "Erro de sistema: Handle invalido para h-b1wgen0002".
            
                                           RUN gera_logspb (INPUT "RECEBIDA",
                                                            INPUT log_msgderro,
                                                            INPUT TIME).
                                       
                                           RUN salva_arquivo.
                                           RUN deleta_objetos.
                                           NEXT. 
                                       END.    
                               END.
        
                           RUN obtem-dados-emprestimos IN h-b1wgen0002
                                ( INPUT crapepr.cdcooper,
                                  INPUT 0,   /** agencia **/
                                  INPUT 0,   /** caixa **/
                                  INPUT "1", /** operador **/
                                  INPUT "crps531_1.p",
                                  INPUT 1,   /** origem **/
                                  INPUT crapepr.nrdconta,
                                  INPUT 1,   /** idseqttl **/
                                  INPUT b-crabdat.dtmvtolt,
                                  INPUT b-crabdat.dtmvtopr,
                                  INPUT b-crabdat.dtmvtolt,
                                  INPUT crapepr.nrctremp, /** Contrato **/
                                  INPUT "crps531_1.p",
                                  INPUT 1,
                                  INPUT FALSE, /** Log **/
                                  INPUT TRUE,
                                  INPUT 0, /** nriniseq **/
                                  INPUT 0, /** nrregist **/
                                 OUTPUT aux_qtregist,
                                 OUTPUT TABLE tt-erro-bo,
                                 OUTPUT TABLE tt-dados-epr ).
        
                           IF  VALID-HANDLE(h-b1wgen0002) THEN
                               DELETE PROCEDURE h-b1wgen0002.

                           FIND FIRST tt-erro-bo NO-ERROR.

                           IF  AVAIL tt-erro-bo THEN
                               DO:
                                   ASSIGN log_msgderro = "Erro de sistema: " + tt-erro-bo.dscritic.
            
                                   RUN gera_logspb (INPUT "RECEBIDA",
                                                    INPUT log_msgderro,
                                                    INPUT TIME).
                                       
                                   RUN salva_arquivo.
                                   RUN deleta_objetos.
                                   NEXT. 
                               END.
        
                           FIND FIRST tt-dados-epr NO-ERROR.
        
                           IF  AVAIL tt-dados-epr THEN                            
                               ASSIGN aux_vlsldliq = tt-dados-epr.vlsdeved +
                                                     tt-dados-epr.vlmtapar +
                                                     tt-dados-epr.vlmrapar.

                           /* 1. Verifica se o valor do pagamento confere com o 
                              saldo devedor */ 
                           IF  aux_vlsldliq <> DECI(aux_VlrLanc) THEN
                               DO:
                                   ASSIGN aux_codierro = 79
                                          log_msgderro = "Portabilidade recusada por divergencia de valor.".
                                                                             
                                   /* Gera devolucao STR0048 */ 
                                   RUN gera_erro_xml (INPUT log_msgderro).
                                             /*
                                   FIND crapban WHERE crapban.cdbccxlt = 85 NO-LOCK NO-ERROR.

                                   /* Cancela portabilidade no JDCTC */ 
                                   RUN cancela_portabilidade (INPUT crapepr.cdcooper,                          /* Cod. Cooperativa */
                                                              INPUT 7,                                         /* Tipo de servico(1-Proponente/2-Credora) */
                                                              INPUT "LEG",                                     /* Cod. Legado */
                                                              INPUT crapban.nrispbif,                          /* Nr. ISPB IF */
                                                              INPUT SUBSTRING(STRING(b-crabcop.nrdocnpj, 
                                                                    "99999999999999"), 1, 8),                  /* Identificador Participante Administrado */
                                                              INPUT SUBSTRING(STRING(b-crabcop.nrdocnpj, 
                                                                    "99999999999999"), 1, 8),                  /* CNPJ Base IF Credora Original Contrato */
                                                              INPUT tbepr_portabilidade.nrunico_portabilidade, /* Número único da portabilidade na CTC */                                               
                                                              OUTPUT aux_flgrespo,                             /* 1 - Se o registro na JDCTC for atualizado com sucesso */
                                                              OUTPUT aux_des_erro,                             /* Indicador erro OK/NOK */
                                                              OUTPUT aux_dscritic).                            /* Descricao do erro */
                                   
                                   IF  aux_des_erro <> "OK" OR 
                                       aux_flgrespo <> 1    THEN
                                       DO:
                                          IF aux_dscritic = "" THEN
                                             ASSIGN aux_dscritic = "Erro ao cancelar a portabilidade no JDCTC.".
                
                                           UNIX SILENT VALUE("echo '" + STRING(glb_dtmvtolt, "99/99/9999") + " "
                                                             + STRING(TIME,"HH:MM:SS") +
                                                             " => Liquidacao " + 
                                                             "|" + TRIM(STRING(crapass.cdagenci, "zzz9")) +       /* PA */
                                                             "|" + TRIM(STRING(crapepr.nrdconta, "zzzz,zz9,9")) + /* Conta */
                                                             "|" + TRIM(STRING(crapepr.nrctremp, "zzzzzzzzz9")) + /* Contrato */
                                                             "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) + /* Portabilidade */
                                                             "|" + aux_dscritic +                           /* Erro */
                                                             "' >> " + aux_nmlogprt).
                                       END.    */

                                   UNIX SILENT VALUE("echo '" + STRING(glb_dtmvtolt, "99/99/9999") + " "
                                                             + STRING(TIME,"HH:MM:SS") +
                                                             " => Liquidacao " + 
                                                             "|" + TRIM(STRING(crapass.cdagenci, "zzz9")) +       /* PA */
                                                             "|" + TRIM(STRING(crapepr.nrdconta, "zzzz,zz9,9")) + /* Conta */
                                                             "|" + TRIM(STRING(crapepr.nrctremp, "zzzzzzzzz9")) + /* Contrato */
                                                             "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) + /* Portabilidade */
                                                             "|Cancelar=>" + log_msgderro +                           /* Erro */
                                                             "' >> " + aux_nmlogprt).

                                   RUN salva_arquivo.
                                   RUN deleta_objetos.
                                   NEXT.
                               END.            

                           /* 2. Verifica se contrato ja foi liquidado */ 
                           IF  crapepr.inliquid = 1  THEN 
                               DO:
                                  ASSIGN aux_codierro = 84
                                         log_msgderro = "Operação de portabilidade já liquidada pelo credor original.". 
        
                                  /* Gera devolucao STR0048 */
                                  RUN gera_erro_xml (INPUT log_msgderro).
        
                                  /*FIND crapban WHERE crapban.cdbccxlt = 85 NO-LOCK NO-ERROR.
                                  
                                  RUN cancela_portabilidade (INPUT crapepr.cdcooper,                          /* Cod. Cooperativa */
                                                             INPUT 7,                                         /* Tipo de servico(1-Proponente/2-Credora) */
                                                             INPUT "LEG",                                     /* Cod. Legado */
                                                             INPUT crapban.nrispbif,                          /* Nr. ISPB IF */
                                                             INPUT SUBSTRING(STRING(b-crabcop.nrdocnpj, 
                                                                    "99999999999999"), 1, 8),                 /* Identificador Participante Administrado */
                                                             INPUT SUBSTRING(STRING(b-crabcop.nrdocnpj, 
                                                                    "99999999999999"), 1, 8),                 /* CNPJ Base IF Credora Original Contrato */
                                                             INPUT tbepr_portabilidade.nrunico_portabilidade, /* Número único da portabilidade na CTC */                                               
                                                             OUTPUT aux_flgrespo,                             /* 1 - Se o registro na JDCTC for atualizado com sucesso */
                                                             OUTPUT aux_des_erro,                             /* Indicador erro OK/NOK */
                                                             OUTPUT aux_dscritic).                            /* Descricao do erro */
                                  
                                  IF  aux_des_erro <> "OK" OR 
                                      aux_flgrespo <> 1    THEN
                                      DO:
                                          IF aux_dscritic = "" THEN
                                             ASSIGN aux_dscritic = "Erro ao cancelar a portabilidade no JDCTC.".
                                
                                          UNIX SILENT VALUE("echo '" + STRING(glb_dtmvtolt, "99/99/9999") + " "
                                                             + STRING(TIME,"HH:MM:SS") +
                                                             " => Liquidacao " + 
                                                             "|" + TRIM(STRING(crapass.cdagenci, "zzz9")) +       /* PA */
                                                             "|" + TRIM(STRING(crapepr.nrdconta, "zzzz,zz9,9")) + /* Conta */
                                                             "|" + TRIM(STRING(crapepr.nrctremp, "zzzzzzzzz9")) + /* Contrato */
                                                             "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) + /* Portabilidade */
                                                             "|" + aux_dscritic +                           /* Erro */
                                                             "' >> " + aux_nmlogprt).
                                      END.
                                    */
                                  UNIX SILENT VALUE("echo '" + STRING(glb_dtmvtolt, "99/99/9999") + " "
                                                             + STRING(TIME,"HH:MM:SS") +
                                                             " => Liquidacao " + 
                                                             "|" + TRIM(STRING(crapass.cdagenci, "zzz9")) +       /* PA */
                                                             "|" + TRIM(STRING(crapepr.nrdconta, "zzzz,zz9,9")) + /* Conta */
                                                             "|" + TRIM(STRING(crapepr.nrctremp, "zzzzzzzzz9")) + /* Contrato */
                                                             "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) + /* Portabilidade */
                                                             "|Cancelar=>" + log_msgderro +                           /* Erro */
                                                             "' >> " + aux_nmlogprt).

                                  RUN salva_arquivo.
                                  RUN deleta_objetos.
                                  NEXT.
                               END.

                           /* 3. Verifica se pagamento esta sendo efetuado na mesma data que a IF
                              Credora Original(neste caso a coop. filiada) aprovou a portabilidade */ 
                           IF  tbepr_portabilidade.dtaprov_portabilidade <> DATE(ENTRY(3, aux_DtMovto, "-") + 
                                                                                ENTRY(2, aux_DtMovto, "-") +
                                                                                ENTRY(1, aux_DtMovto, "-")) THEN                            
                               DO:
                                   ASSIGN aux_codierro = 83
                                          log_msgderro = "Pagamento em data inválida.".  
        
                                   /* Gera devolucao STR0048 */
                                   RUN gera_erro_xml (INPUT log_msgderro).

                                   /*FIND crapban WHERE crapban.cdbccxlt = 85 NO-LOCK NO-ERROR.

                                   RUN cancela_portabilidade (INPUT crapepr.cdcooper,                          /* Cod. Cooperativa */
                                                              INPUT 7,                                         /* Tipo de servico(1-Proponente/2-Credora) */
                                                              INPUT "LEG",                                     /* Cod. Legado */
                                                              INPUT crapban.nrispbif,                          /* Nr. ISPB IF */
                                                              INPUT SUBSTRING(STRING(b-crabcop.nrdocnpj, 
                                                                    "99999999999999"), 1, 8),                  /* Identificador Participante Administrado */
                                                              INPUT SUBSTRING(STRING(b-crabcop.nrdocnpj, 
                                                                    "99999999999999"), 1, 8),                  /* CNPJ Base IF Credora Original Contrato */
                                                              INPUT tbepr_portabilidade.nrunico_portabilidade, /* Número único da portabilidade na CTC */                                               
                                                              OUTPUT aux_flgrespo,                             /* 1 - Se o registro na JDCTC for atualizado com sucesso */
                                                              OUTPUT aux_des_erro,                             /* Indicador erro OK/NOK */
                                                              OUTPUT aux_dscritic).                            /* Descricao do erro */
                                   
                                   IF  aux_des_erro <> "OK" OR 
                                       aux_flgrespo <> 1    THEN
                                       DO:
                                           IF aux_dscritic = "" THEN
                                              ASSIGN aux_dscritic = "Erro ao cancelar a portabilidade no JDCTC.".
                
                                           UNIX SILENT VALUE("echo '" + STRING(glb_dtmvtolt, "99/99/9999") + " "
                                                             + STRING(TIME,"HH:MM:SS") +
                                                             " => Liquidacao " + 
                                                             "|" + TRIM(STRING(crapass.cdagenci, "zzz9")) +       /* PA */
                                                             "|" + TRIM(STRING(crapepr.nrdconta, "zzzz,zz9,9")) + /* Conta */
                                                             "|" + TRIM(STRING(crapepr.nrctremp, "zzzzzzzzz9")) + /* Contrato */
                                                             "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) + /* Portabilidade */
                                                             "|" + aux_dscritic +                           /* Erro */
                                                             "' >> " + aux_nmlogprt).
                                       END.
                                     */

                                   UNIX SILENT VALUE("echo '" + STRING(glb_dtmvtolt, "99/99/9999") + " "
                                                     + STRING(TIME,"HH:MM:SS") +
                                                     " => Liquidacao " + 
                                                     "|" + TRIM(STRING(crapass.cdagenci, "zzz9")) +       /* PA */
                                                     "|" + TRIM(STRING(crapepr.nrdconta, "zzzz,zz9,9")) + /* Conta */
                                                     "|" + TRIM(STRING(crapepr.nrctremp, "zzzzzzzzz9")) + /* Contrato */
                                                     "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) + /* Portabilidade */
                                                     "|" + aux_dscritic +                           /* Erro */
                                                     "' >> " + aux_nmlogprt).

                                   RUN salva_arquivo.
                                   RUN deleta_objetos.
                                   NEXT.
                               END.
                        END.                    
                   ELSE    
                       DO:
                           ASSIGN aux_codierro = 78
                                  log_msgderro = "Portabilidade não localizada.".
                 
                           /* Gera devolucao STR0048 */
                           RUN gera_erro_xml (INPUT log_msgderro).  
                                           
                           RUN salva_arquivo.
                           RUN deleta_objetos.
                           NEXT.
                       END.
                END.
         
            /* Caso seja estorno de TED de repasse de convenio entao despreza*/
            IF CAN-DO("STR0007,STR0020",aux_CodMsg) THEN
            DO:
                RUN salva_arquivo.
                RUN deleta_objetos.
                NEXT.
            END.

            IF  CAN-DO("STR0010R2,PAG0111R2",aux_CodMsg) OR aux_tagCABInf  THEN
                DO:
                    DO aux_contlock = 1 TO 10:

                       /* Busca numero da conta a CREDITAR */
                       FIND craptvl WHERE 
                            craptvl.cdcooper = crabcop.cdcooper  AND
                            craptvl.tpdoctrf = 3                 AND
                            craptvl.idopetrf = aux_NumCtrlIF
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                         
                       IF   NOT AVAIL craptvl    THEN
                            IF   LOCKED craptvl   THEN
                                 DO:
                                     ASSIGN aux_dscritic = 
                                         "Registro craptvl sendo alterado".
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT.
                                 END.
                            ELSE
                                 DO:
                                     ASSIGN aux_dscritic =
                                         "Numero de Controle invalido".
                                     LEAVE.
                                 END.

                       ASSIGN aux_dscritic = "".
                       LEAVE.

                    END.

                    IF  LOCKED craptvl   THEN
                        NEXT.

                    IF  NOT AVAIL craptvl  THEN
                        DO:
                            IF  aux_tagCABInf  THEN
                                DO:
                                    RUN gera_logspb 
                                        (INPUT "REJEITADA NAO OK",
                                         INPUT aux_dscritic,
                                         INPUT TIME).
                                         
                                    ASSIGN aux_CodMsg = "ERROREJ".
                                END.
                            ELSE
                                RUN gera_logspb 
                                       (INPUT "RETORNO SPB",
                                        INPUT aux_dscritic,
                                        INPUT TIME).
                                 
                            /* Cria registro das movimentacoes no SPB */
                            RUN cria_gnmvcen (INPUT crabcop.cdagectl,
                                              INPUT aux_dtmvtolt,
                                              INPUT aux_CodMsg,
                                              INPUT "C",
                                              INPUT DEC(aux_VlrLanc)).
                    
                            RUN salva_arquivo.
                            RUN deleta_objetos.
                            NEXT.
                        END.
                    
                    IF   aux_tagCABInf  THEN
                         ASSIGN aux_VlrLanc      = STRING(craptvl.vldocrcb)
                                craptvl.flgopfin = TRUE. /*Finaliz.*/
                    
                    ASSIGN aux_nrctacre = craptvl.nrdconta.

                    /* Logar Estorno TED de nao cooperado */
                    IF  aux_nrctacre = 0  THEN
                        DO:
                            IF  aux_tagCABInf  THEN
                                DO:
                                    RUN gera_logspb 
                                            (INPUT "REJEITADA OK",
                                             INPUT "Rejeitada pela cabine",
                                             INPUT TIME).

                                    ASSIGN aux_CodMsg = "MSGREJ".
                                END.
                            ELSE
                                 DO:
                                     RUN motivo_devolucao.
                                     
                                     RUN gera_logspb (INPUT "ENVIADA NAO OK",
                                                      INPUT log_msgderro,
                                                      INPUT TIME).
                                 END.

                            /* Cria registro das movimentacoes no SPB */
                            RUN cria_gnmvcen (INPUT crabcop.cdagectl,
                                              INPUT aux_dtmvtolt,
                                              INPUT aux_CodMsg,
                                              INPUT "C",
                                              INPUT DEC(aux_VlrLanc)).

                            RUN salva_arquivo.
                            RUN deleta_objetos.
                            NEXT.
                        END.
                END.
            ELSE
                 /* Conta a creditar */
                 ASSIGN aux_nrctacre = INT(aux_CtCredtd).
            
            ASSIGN aux_flgcriti = FALSE.
           
		    /* Se existir craptco eh uma conta incorporada ou migrada,
			   conforme validacao efetuada na procedure verifica_conta. */ 
            IF   AVAIL craptco  THEN
			     DO:
					 RUN processa_conta_transferida(INPUT crabcop.cdcooper,
							                        INPUT aux_nrctacre,
										            INPUT DEC(aux_VlrLanc)).
           
				     RUN deleta_objetos.
			         NEXT.
				 END.
            ELSE
			     DO:
                    /* Verificar se ja existe Lancamento*/
					FIND craplcm WHERE craplcm.cdcooper = crabcop.cdcooper AND
									   craplcm.dtmvtolt = craplot.dtmvtolt AND
									   craplcm.cdagenci = craplot.cdagenci AND
									   craplcm.cdbccxlt = craplot.cdbccxlt AND
									   craplcm.nrdolote = craplot.nrdolote AND
									   craplcm.nrdctabb = aux_nrctacre     AND
									   craplcm.nrdocmto = aux_nrdocmto
									   NO-LOCK NO-ERROR.
             
					IF  AVAIL craplcm  THEN
						DO:
							IF  CAN-DO("STR0010R2,PAG0111R2",aux_CodMsg)  OR 
								aux_tagCABInf  THEN
								DO:
									ASSIGN log_msgderro = 
										   "Lancamento ja existe! Conta: " +
										   STRING(aux_nrctacre) + 
										   ", Valor: " + 
										   STRING(craplcm.vllanmto,"zzz,zzz,zz9.99")
										   + ", Lote: " + STRING(craplot.nrdolote) +
										   ", Doc.: " + STRING(aux_nrdocmto). 
                        
									IF  aux_tagCABInf  THEN
										DO:
											RUN gera_logspb 
												(INPUT "REJEITADA NAO OK",
												 INPUT log_msgderro,
												 INPUT TIME).
                                         
											ASSIGN aux_CodMsg = "ERROREJ".
										END.
									ELSE
										RUN gera_logspb (INPUT "RETORNO SPB",
														 INPUT log_msgderro,
														 INPUT TIME).

									/* Cria registro das movimentacoes no SPB */
									RUN cria_gnmvcen (INPUT crabcop.cdagectl,
													  INPUT aux_dtmvtolt,
													  INPUT aux_CodMsg,
													  INPUT "C",
													  INPUT DEC(aux_VlrLanc)).
								END.
							ELSE
								DO:
									/* Cria registro das movimentacoes no SPB */
									RUN cria_gnmvcen (INPUT crabcop.cdagectl,
													  INPUT aux_dtmvtolt,
													  INPUT aux_CodMsg,
													  INPUT "C",
													  INPUT DEC(aux_VlrLanc)).
                          
									ASSIGN log_msgderro = 
									"Lancamento ja existe! Lote: " + 
									STRING(craplot.nrdolote) +
									", Doc.: " + STRING(aux_nrdocmto).
                           
									RUN gera_logspb (INPUT "RECEBIDA",
													 INPUT log_msgderro,
													 INPUT TIME).
								END.
                                        
							RUN salva_arquivo.  
							RUN deleta_objetos.
							NEXT.
						END.

					ASSIGN aux_hrtransa = TIME.
   
					CREATE craplcm.
					ASSIGN craplcm.cdcooper = crabcop.cdcooper
						   craplcm.dtmvtolt = craplot.dtmvtolt
						   craplcm.cdagenci = craplot.cdagenci
						   craplcm.cdbccxlt = craplot.cdbccxlt
						   craplcm.nrdolote = craplot.nrdolote
						   craplcm.nrdconta = aux_nrctacre
						   craplcm.nrdctabb = craplcm.nrdconta
						   craplcm.nrdocmto = aux_nrdocmto
          
						   craplcm.cdhistor = 
									   /* Estorno TED */ 
								  IF   CAN-DO("STR0010R2,PAG0111R2",aux_CodMsg) THEN 
									   600
								  ELSE /* Estorno TED Rejeitada*/
								  IF   aux_tagCABInf  THEN
									   887
								  ELSE
									   /* Credito TEC */ 
								  IF   CAN-DO("STR0037R2,PAG0137R2",aux_CodMsg)  THEN
									   799
								  ELSE 
								  IF   aux_CodMsg = "STR0047R2"  THEN
									   1921
								  ELSE
									  /* Credito TED */ 
									   578
          
						   craplcm.vllanmto = DEC(aux_VlrLanc)
						   craplcm.nrseqdig = craplot.nrseqdig + 1
						   craplcm.cdpesqbb = 
								 IF  CAN-DO("STR0010R2,PAG0111R2",aux_CodMsg)  THEN
									 aux_CodDevTransf /*Cod. estorno*/
								 ELSE 
								 IF  aux_tagCABInf  THEN
									 "TED/TEC rejeitado coop"
								 ELSE
								 IF  aux_CodMsg = "STR0047R2" THEN
									 "CRED TED PORT"
								 ELSE
									 aux_dadosdeb /* Dados do Remetente */
						   craplcm.cdoperad = "1"
						   craplcm.hrtransa = aux_hrtransa.

					VALIDATE craplcm.
                         
					ASSIGN craplot.vlcompcr = craplot.vlcompcr + 
											  craplcm.vllanmto
						   craplot.vlinfocr = craplot.vlinfocr +
											  craplcm.vllanmto.
            
					IF   aux_tagCABInf THEN
						 ASSIGN aux_CodMsg = "MSGREJ".
            
					/* Cria registro das movimentacoes no SPB */
					RUN cria_gnmvcen (INPUT crabcop.cdagectl,
									  INPUT aux_dtmvtolt,
									  INPUT aux_CodMsg,
									  INPUT "C",
									  INPUT DEC(aux_VlrLanc)).
                 END.
        END.
            
   ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
          craplot.qtcompln = craplot.qtcompln + 1
          craplot.qtinfoln = craplot.qtinfoln + 1.
           
   /* SUCESSO */ 
   
   IF   CAN-DO("STR0010R2,PAG0111R2",aux_CodMsg) OR aux_tagCABInf THEN
        DO:
            IF   aux_tagCABInf THEN
                 DO:
                     ASSIGN aux_CodMsg = aux_msgrejei.
                     
                     RUN gera_logspb (INPUT "REJEITADA OK",
                                      INPUT "Rejeitada pela cabine",
                                      INPUT TIME).
                 END.
            ELSE
                 DO:
                     RUN motivo_devolucao.
            
                     RUN gera_logspb (INPUT "ENVIADA NAO OK",
                                      INPUT log_msgderro,
                                      INPUT TIME).
                 END.
        END.
   ELSE
   /* Liquidar contrato de empréstimo após receber pagamento da portabilidade */
   IF   aux_CodMsg = "STR0047R2" THEN
        DO:                                       
            /* Leitura do Lote na cooperativa do contrato referente ao 
               crédito do saldo devedor*/
            DO aux_contlock = 1 TO 10:

                FIND b-craplot WHERE b-craplot.cdcooper = b-crabcop.cdcooper AND
                                     b-craplot.dtmvtolt = b-crabdat.dtmvtolt AND
                                     b-craplot.cdagenci = 1                  AND
                                     b-craplot.cdbccxlt = 100                AND
                                     b-craplot.nrdolote = 600030 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                IF  NOT AVAIL b-craplot  THEN
                    IF  LOCKED b-craplot   THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            CREATE b-craplot.
                            ASSIGN b-craplot.cdcooper = b-crabcop.cdcooper
                                   b-craplot.dtmvtolt = b-crabdat.dtmvtolt
                                   b-craplot.cdagenci = 1               
                                   b-craplot.cdbccxlt = 100             
                                   b-craplot.nrdolote = 600030          
                                   b-craplot.tplotmov = 1.
                            
                        END.
            END.

            /* Verificar se ja existe Lancamento na conta do cooperado */
            FIND craplcm WHERE craplcm.cdcooper = b-crabcop.cdcooper           AND
                               craplcm.dtmvtolt = b-craplot.dtmvtolt             AND
                               craplcm.cdagenci = b-craplot.cdagenci             AND
                               craplcm.cdbccxlt = b-craplot.cdbccxlt             AND
                               craplcm.nrdolote = b-craplot.nrdolote             AND
                               craplcm.nrdctabb = tbepr_portabilidade.nrdconta AND
                               craplcm.nrdocmto = aux_nrctremp
                               NO-LOCK NO-ERROR.
    
            IF  AVAIL craplcm  THEN
                DO:                
                    ASSIGN aux_dscritic = "Lancamento ja existe!" + 
                                          " Conta: " + STRING(tbepr_portabilidade.nrdconta) + 
                                          " Contrato: " + STRING(aux_nrctremp).

                    UNIX SILENT VALUE("echo '" + STRING(b-crabdat.dtmvtolt, "99/99/9999") + " "
                                      + STRING(TIME,"HH:MM:SS") +
                                      " => Liquidacao " + 
                                      "|" + TRIM(STRING(crapass.cdagenci, "zzz9")) +       /* PA */
                                      "|" + TRIM(STRING(crapepr.nrdconta, "zzzz,zz9,9")) + /* Conta */
                                      "|" + TRIM(STRING(aux_nrctremp, "zzzzzzzzz9")) +     /* Contrato */
                                      "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) + /* Portabilidade */
                                      "|" + aux_dscritic +                           /* Erro */
                                      "' >> " + aux_nmlogprt).
                    
                END.
            ELSE
                DO:
                    /* Emprestimo PP */       
                    IF  aux_tpemprst = 1 THEN
                        DO:
                            RUN liquida_contrato_emprestimo_novo
                                   (INPUT b-crabcop.cdcooper,
                                    INPUT tbepr_portabilidade.nrdconta,
                                    INPUT aux_nrctremp,
                                    INPUT b-crabdat.dtmvtolt,
                                    INPUT b-crabdat.dtmvtoan, 
                                    INPUT crapass.cdagenci,
                                    INPUT b-craplot.cdagenci).
                
                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    RUN salva_arquivo.
                                    RUN deleta_objetos.
                                    RETURN "OK".
                                END. 
                        END.
                    /* TR */
                    ELSE
                        DO:
                            RUN liquida_contrato_emprestimo_antigo
                                   (INPUT b-crabcop.cdcooper,
                                    INPUT tbepr_portabilidade.nrdconta,
                                    INPUT aux_nrctremp,
                                    INPUT b-crabdat.dtmvtolt).
                
                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    RUN salva_arquivo.
                                    RUN deleta_objetos.
                                    RETURN "OK".
                                END.

                        END.
                
                    ASSIGN aux_hrtransa = TIME.
                    
                    /* Credita valor da TED na conta do cooperado */
                    CREATE craplcm.
                    ASSIGN craplcm.cdcooper = b-crabcop.cdcooper
                           craplcm.dtmvtolt = b-craplot.dtmvtolt
                           craplcm.cdagenci = b-craplot.cdagenci
                           craplcm.cdbccxlt = b-craplot.cdbccxlt
                           craplcm.nrdolote = b-craplot.nrdolote
                           craplcm.nrdconta = tbepr_portabilidade.nrdconta
                           craplcm.nrdctabb = tbepr_portabilidade.nrdconta
                           craplcm.nrdocmto = aux_nrctremp
               
                           craplcm.cdhistor = 1918
                           craplcm.vllanmto = DEC(aux_VlrLanc)
                           craplcm.nrseqdig = b-craplot.nrseqdig + 1
                           craplcm.cdpesqbb = "CRED TED PORT"
                           craplcm.cdoperad = "1"
                           craplcm.hrtransa = aux_hrtransa.
    
                    VALIDATE craplcm.
                 
                    ASSIGN b-craplot.vlcompcr = b-craplot.vlcompcr + 
                                                craplcm.vllanmto
                           b-craplot.vlinfocr = b-craplot.vlinfocr +
                                                craplcm.vllanmto
                           b-craplot.nrseqdig = b-craplot.nrseqdig + 1.  
                        
                    /* Atualiza data da liquidacao do contrato por portabilidade */ 
                    FIND tbepr_portabilidade WHERE 
                         tbepr_portabilidade.cdcooper = b-crabcop.cdcooper AND
                         tbepr_portabilidade.nrunico_portabilidade = aux_NUPortdd
                         EXCLUSIVE-LOCK NO-ERROR.                                       
                
                    IF  AVAIL tbepr_portabilidade THEN
                        ASSIGN tbepr_portabilidade.dtliquidacao = b-crabdat.dtmvtolt.
                    
                    FIND crapban WHERE crapban.cdbccxlt = 85 NO-LOCK NO-ERROR.            
                
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                
                    /* Atualiza situacao da portabilidade para Concluida no JDCTC */ 
                    RUN STORED-PROCEDURE pc_atualizar_situacao
                        aux_handproc = PROC-HANDLE NO-ERROR
                                         (INPUT crabcop.cdcooper,           /* Cód. Cooperativa */
                                          INPUT 2,                          /* Tipo de servico(1-Proponente/2-Credora) */
                                          INPUT "LEG",                      /* Codigo Legado */
                                          INPUT STRING(crapban.nrispbif),   /* Numero ISPB IF */
                                          INPUT "1",                        /* Nr. controle (verificar) */
                                          INPUT STRING(aux_NUPortdd),       /* Numero Portabilidade CTC */                                  
                                          INPUT "PL5",                      /* Codigo Situacao Titulo */
                                         OUTPUT 0,                          /* 1 - Se o registro na JDCTC for atualizado com sucesso */
                                         OUTPUT "",                         /* Indicador erro OK/NOK */
                                         OUTPUT "").                        /* Descricao do erro */
                
                    CLOSE STORED-PROC pc_atualizar_situacao 
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                
                    ASSIGN aux_flgrespo = pc_atualizar_situacao.pr_flgrespo
                                          WHEN pc_atualizar_situacao.pr_flgrespo <> ?
                           aux_des_erro = pc_atualizar_situacao.pr_des_erro
                                          WHEN pc_atualizar_situacao.pr_des_erro <> ?
                           aux_dscritic = pc_atualizar_situacao.pr_dscritic 
                                          WHEN pc_atualizar_situacao.pr_dscritic <> ?.                                      
                
                    IF  aux_des_erro <> "OK"  OR
                        aux_flgrespo <> 1     THEN
                        DO:                                  
                            IF  aux_dscritic = "" THEN
                                ASSIGN aux_dscritic = "Erro ao atualizar situacao da portabilidade no JDCTC.".
                
                            RUN fontes/substitui_caracter.p 
                                (INPUT-OUTPUT aux_dscritic).  

                            UNIX SILENT VALUE("echo '" + STRING(b-crabdat.dtmvtolt, "99/99/9999") + " "
                                                    + STRING(TIME,"HH:MM:SS") +
                                                    " => Liquidacao " + 
                                                    "|" + TRIM(STRING(crapass.cdagenci, "zzz9")) +        /* PA */
                                                    "|" + TRIM(STRING(crapepr.nrdconta, "zzzz,zz9,9")) +  /* Conta */
                                                    "|" + TRIM(STRING(aux_nrctremp, "zzzzzzzzz9")) +      /* Contrato */
                                                    "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) + /* Portabilidade */
                                                    "|" + aux_dscritic +                            /* Erro */
                                                    "' >> " + aux_nmlogprt).
                        END.

                    RUN gera_logspb (INPUT "RECEBIDA",
                                     INPUT "",
                                     INPUT aux_hrtransa).
                END.
        END.                       
   ELSE
        RUN gera_logspb (INPUT "RECEBIDA",
                         INPUT "",
                         INPUT aux_hrtransa).

   RUN salva_arquivo. 
   RUN deleta_objetos.

END PROCEDURE.


PROCEDURE cria_gnmvcen:

    DEFINE INPUT PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT PARAMETER par_dsmensag AS CHARACTER   NO-UNDO.
    DEFINE INPUT PARAMETER par_dsdebcre AS CHARACTER   NO-UNDO.
    DEFINE INPUT PARAMETER par_vllanmto AS DECIMAL     NO-UNDO.
        
    CREATE gnmvcen.
    ASSIGN gnmvcen.cdagectl = par_cdagenci
           gnmvcen.dtmvtolt = par_dtmvtolt
           gnmvcen.dsmensag = par_dsmensag
           gnmvcen.dsdebcre = par_dsdebcre
           gnmvcen.vllanmto = par_vllanmto.
    VALIDATE gnmvcen.
END.

PROCEDURE processa_conta_transferida:
                     
    DEFINE INPUT  PARAM par_cdcopant AS INTEGER          NO-UNDO.
    DEFINE INPUT  PARAM par_nrctaant AS INTEGER          NO-UNDO.
    DEFINE INPUT  PARAM par_vlrlanct AS DECIMAL          NO-UNDO.

    DEFINE VARIABLE aux_contlock    AS INTEGER           NO-UNDO.
    DEFINE VARIABLE aux_nmarqimp    AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE aux_horario     AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE aux_hrtransa    AS INTE              NO-UNDO.
    DEFINE VARIABLE aux_strmigra    AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE aux_dtmvtolt    AS DATE              NO-UNDO.
    DEFINE BUFFER b-crapcop         FOR crapcop.
    DEFINE BUFFER b-crapdat         FOR crapdat.

    FORM aux_horario      AT 03 COLUMN-LABEL "HORARIO"
         craplcm.vllanmto AT 12 COLUMN-LABEL "VALOR"
         craptco.nrctaant AT 33 COLUMN-LABEL "CONTA ORIGEM"
         craptco.nrdconta AT 47 COLUMN-LABEL "CONTA DESTINO"
         WITH FRAME f_teds_migradas.

    ASSIGN aux_hrtransa = TIME.
    
    FIND craptco WHERE craptco.cdcopant = par_cdcopant AND
                       craptco.nrctaant = par_nrctaant AND
                       craptco.flgativo = TRUE         AND
                       craptco.tpctatrf = 1
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL(craptco)  THEN
	    DO:
		    /* No caso de TED destinada a uma IF incorporada,
			   o parametro par_cdcopant contera o codigo da 
			   nova IF */ 
		    FIND craptco WHERE craptco.cdcooper = par_cdcopant AND
						       craptco.nrctaant = par_nrctaant AND
						       craptco.flgativo = TRUE         AND
                               craptco.tpctatrf = 1
                               NO-LOCK NO-ERROR.
		END.

    IF  AVAIL(craptco) THEN
        DO:                                 
            /* Busca cooperativa onde a conta foi transferida */ 
            FIND b-crapcop WHERE b-crapcop.cdcooper = craptco.cdcooper
                                 NO-LOCK NO-ERROR.

            IF  NOT AVAIL(b-crapcop) THEN
                DO:
                    RETURN "NOK".
                END.

            /* Busca data na cooperativa onde a conta foi transferida */ 
            FIND b-crapdat WHERE b-crapdat.cdcooper = craptco.cdcooper.

            IF  NOT AVAIL(b-crapdat) THEN
                DO:
                    RETURN "NOK".
                END.
                     
            ASSIGN aux_dtmvtolt = IF   aux_flestcri = 0
                                  THEN b-crapdat.dtmvtolt
                                  ELSE aux_dtintegr.

            /* verifica se processo ja finalizou na coop de destino */
            IF   TODAY > aux_dtmvtolt AND
                 aux_flestcri = 0     THEN    
                 DO: 
                      RETURN "NOK".
                 END.     
                         
            /* Verifica se conta transferida existe */ 
            FIND crapass WHERE crapass.cdcooper = craptco.cdcooper  AND
                               crapass.nrdconta = craptco.nrdconta
                               NO-LOCK NO-ERROR.

            IF   NOT AVAIL crapass THEN
                 DO:
                     /* Cria registro das movimentacoes no SPB */
                     RUN cria_gnmvcen (INPUT b-crapcop.cdagectl,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_CodMsg,
                                       INPUT "C",
                                       INPUT DEC(aux_VlrLanc)).
            
                     ASSIGN log_msgderro = 
                                "Registro(crapass) de conta transferida " + 
                                "nao encontrado". 
            
                     RUN gera_logspb_transferida(INPUT b-crapcop.cdcooper,
                                                 INPUT b-crapcop.cdbcoctl,
                                                 INPUT b-crapcop.cdagectl,
                                                 INPUT b-crapcop.dsdircop,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT "RECEBIDA",
                                                 INPUT log_msgderro,
                                                 INPUT aux_hrtransa).
                     
                     UNIX SILENT VALUE 
                          ("mv " + crawarq.nmarquiv + " /usr/coop/" + b-crapcop.dsdircop
                           + "/salvar/" + aux_nmarqxml). 
                     
                     RETURN "NOK".
                 END.

        END.
    ELSE
        DO:
            RETURN "NOK".
        END.
        
    DO  aux_contlock = 1 TO 10:
        
        FIND crablot WHERE crablot.cdcooper = b-crapcop.cdcooper  AND
                           crablot.dtmvtolt = aux_dtmvtolt        AND
                           crablot.cdagenci = aux_cdagenci        AND
                           crablot.cdbccxlt = b-crapcop.cdbcoctl  AND
                           crablot.nrdolote = aux_nrdolote 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
             
        IF  NOT AVAIL  crablot   THEN
            IF  LOCKED crablot   THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
            ELSE
                LEAVE.
               

        LEAVE.

    END.

    IF  NOT AVAIL crablot   THEN
        DO:
            RETURN "NOK".
        END.

    /* Verificar se ja existe Lancamento*/
    FIND craplcm WHERE craplcm.cdcooper = b-crapcop.cdcooper AND
                       craplcm.dtmvtolt = crablot.dtmvtolt AND
                       craplcm.cdagenci = crablot.cdagenci AND
                       craplcm.cdbccxlt = crablot.cdbccxlt AND
                       craplcm.nrdolote = crablot.nrdolote AND
                       craplcm.nrdctabb = craptco.nrdconta AND
                       craplcm.nrdocmto = aux_nrdocmto
                       NO-LOCK NO-ERROR.


    IF  AVAIL craplcm  THEN
        DO: 
            /* Cria registro das movimentacoes no SPB */
            RUN cria_gnmvcen (INPUT b-crapcop.cdagectl,
                              INPUT aux_dtmvtolt,
                              INPUT aux_CodMsg,
                              INPUT "C",
                              INPUT DEC(aux_VlrLanc)).

            ASSIGN log_msgderro = "Lancamento ja existe! Lote: " + 
                                  STRING(crablot.nrdolote)       +
                                  ", Doc.: " + STRING(aux_nrdocmto).

            RUN gera_logspb_transferida(INPUT b-crapcop.cdcooper,
                                        INPUT b-crapcop.cdbcoctl,
                                        INPUT b-crapcop.cdagectl,
                                        INPUT b-crapcop.dsdircop,
                                        INPUT aux_dtmvtolt,
                                        INPUT "RECEBIDA",
                                        INPUT log_msgderro,
                                        INPUT aux_hrtransa).
            
            UNIX SILENT VALUE 
                 ("mv " + crawarq.nmarquiv + " /usr/coop/" + b-crapcop.dsdircop
                  + "/salvar/" + aux_nmarqxml). 
            
            RETURN "OK".
        END.

    CREATE craplcm.
    ASSIGN craplcm.cdcooper = b-crapcop.cdcooper
           craplcm.dtmvtolt = crablot.dtmvtolt
           craplcm.cdagenci = crablot.cdagenci
           craplcm.cdbccxlt = crablot.cdbccxlt
           craplcm.nrdolote = crablot.nrdolote
           craplcm.nrdconta = craptco.nrdconta
           craplcm.nrdctabb = craplcm.nrdconta
           craplcm.nrdocmto = aux_nrdocmto

           craplcm.cdhistor = 
                       /* Credito TEC */ 
                  IF   CAN-DO("STR0037R2,PAG0137R2",aux_CodMsg)  THEN
                       799
                  ELSE /* Credito TED */ 
                       578

           craplcm.vllanmto = par_vlrlanct
           craplcm.nrseqdig = crablot.nrseqdig + 1
           craplcm.cdpesqbb = aux_dadosdeb /* Dados do Remetente */
           craplcm.cdoperad = "1"
           craplcm.hrtransa = aux_hrtransa.
    VALIDATE craplcm.

    ASSIGN crablot.vlcompcr = crablot.vlcompcr + 
                              craplcm.vllanmto
           crablot.vlinfocr = crablot.vlinfocr +
                              craplcm.vllanmto.
    

    ASSIGN  crablot.nrseqdig = crablot.nrseqdig + 1
            crablot.qtcompln = crablot.qtcompln + 1
            crablot.qtinfoln = crablot.qtinfoln + 1.
       
    /* Cria registro das movimentacoes no SPB */
    RUN cria_gnmvcen (INPUT b-crapcop.cdagectl,
                      INPUT aux_dtmvtolt,
                      INPUT aux_CodMsg,
                      INPUT "C",
                      INPUT par_vlrlanct).

    RUN gera_logspb_transferida(INPUT b-crapcop.cdcooper,
                                INPUT b-crapcop.cdbcoctl,
                                INPUT b-crapcop.cdagectl,
                                INPUT b-crapcop.dsdircop,
                                INPUT aux_dtmvtolt,
                                INPUT "RECEBIDA",
                                INPUT " ",
                                INPUT aux_hrtransa).
    
    IF craptco.cdcopant = 1 OR     /* Migracao VIACREDI >> Alto Vale */
       craptco.cdcopant = 2 OR     /* Migracao ACREDI >> VIACREDI */
       craptco.cdcopant = 4 OR     /* Incorporação CONCREDI >> VIACREDI */
       craptco.cdcopant = 15 OR    /* Incorporação CREDIMILSUL >>  SCRCRED */
	   craptco.cdcopant = 17 THEN  /* Incorporação TRANSULCRED >>  TRANSPOCRED */
    DO: 
        
        IF  craptco.cdcopant = 1 THEN
            ASSIGN aux_strmigra = "TEDs MIGRADAS: VIACREDI --> VIACREDI AV".
        ELSE IF  craptco.cdcopant = 2 THEN
            ASSIGN aux_strmigra = "TEDs MIGRADAS: ACREDI --> VIACREDI".
        ELSE IF craptco.cdcopant = 4   THEN
            ASSIGN aux_strmigra = "TEDs MIGRADAS: CONCREDI --> VIACREDI".
        ELSE IF craptco.cdcopant = 15  THEN
            ASSIGN aux_strmigra = "TEDs MIGRADAS: CREDIMILSUL --> SCRCRED".
	    ELSE IF craptco.cdcopant = 17  THEN
		    ASSIGN aux_strmigra = "TEDs MIGRADAS: TRANSULCRED --> TRANSPOCRED".
        
        ASSIGN aux_horario = STRING(TIME, "HH:MM:SS").
    
        ASSIGN aux_nmarqimp = "/usr/coop/cecred/log/teds_migradas" +
                               STRING(craptco.cdcopant, "99")     +
                               STRING(DAY(aux_dtmvtolt), "99")     +
                               STRING(MONTH(aux_dtmvtolt), "99")   +
                               STRING(YEAR(aux_dtmvtolt), "9999")  +
                               ".lst".
    
        IF SEARCH(aux_nmarqimp) = ? THEN
        DO:
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).
    
            PUT STREAM str_1 SKIP(1) 
                             aux_strmigra FORMAT "x(40)" AT 10
                             SKIP(2).
    
            DISP STREAM str_1 aux_horario
                              craplcm.vllanmto
                              craptco.nrctaant
                              craptco.nrdconta
            WITH FRAME f_teds_migradas.
    
            OUTPUT STREAM str_1 CLOSE.
        END.
        ELSE
        DO:
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) APPEND.
    
            
            PUT STREAM str_1 aux_horario      AT 03
                             craplcm.vllanmto AT 12
                             craptco.nrctaant AT 35
                             craptco.nrdconta AT 50
                             SKIP.
    
            OUTPUT STREAM str_1 CLOSE.
        END.
    END.

    UNIX SILENT VALUE
         ("mv " + crawarq.nmarquiv + " /usr/coop/" + b-crapcop.dsdircop
          + "/salvar/" + aux_nmarqxml). 

    RETURN "OK".
END.

PROCEDURE motivo_devolucao.

   INT(aux_CodDevTransf) NO-ERROR.

   IF   ERROR-STATUS:ERROR  THEN
        ASSIGN log_msgderro = aux_CodDevTransf + " - Outros".
   ELSE
        DO:
            FIND craptab WHERE craptab.cdcooper = 0            AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "GENERI"     AND
                               craptab.cdempres = 0            AND
                               craptab.cdacesso = "CDERROSSPB" AND
                               craptab.tpregist = INT(aux_CodDevTransf)
                               NO-LOCK NO-ERROR.
                                
            IF   AVAIL craptab THEN
                 ASSIGN log_msgderro = STRING(craptab.tpregist) + " - " +
                                       craptab.dstextab.
            ELSE
                 ASSIGN log_msgderro = aux_CodDevTransf + " - Outros".
        END.

END PROCEDURE.

PROCEDURE log_mqcecred:

     DEF VAR aux_cdcooper LIKE crapcop.cdcooper                        NO-UNDO.


     ASSIGN aux_cdcooper = IF   AVAIL crabcop   THEN
                                crabcop.cdcooper   
                           ELSE
                                crapcop.cdcooper.

     FIND crabdat WHERE crabdat.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
     
     IF   NOT AVAIL crabdat THEN 
          DO:
              ASSIGN glb_cdcritic = 1.
              RUN fontes/critic.p.
              UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '"  + 
                                glb_dscritic + " >> log/proc_batch.log").
              RETURN.
          END. 

     ASSIGN aux_dsdircop = IF   AVAIL crabcop   THEN
                                crabcop.dsdircop
                           ELSE
                                crapcop.dsdircop.

     /* Para estas mensagens nao e necessario aguardar processo */
     IF   CAN-DO("PAG0101,STR0018,STR0019",aux_CodMsg)   THEN
       ASSIGN aux_nmarqlog = "/usr/coop/" + 
                            aux_dsdircop + "/log/" + "mqcecred_processa_" +
                            STRING(TODAY,"999999") + ".log".
     ELSE
       ASSIGN aux_nmarqlog = "/usr/coop/" + 
                            aux_dsdircop + "/log/" + "mqcecred_processa_" +
                            STRING(crabdat.dtmvtolt,"999999") + ".log".

END PROCEDURE.


PROCEDURE salva_arquivo:

    ASSIGN aux_dsdircop = IF   AVAIL crabcop   THEN
                               crabcop.dsdircop
                          ELSE
                               crapcop.dsdircop.

    UNIX SILENT VALUE ("mv " + crawarq.nmarquiv + " /usr/coop/" + aux_dsdircop +
                       "/salvar/" + aux_nmarqxml). 

END PROCEDURE.

/* Verificar se o processo esta ainda executando */
PROCEDURE verifica_processo:

    DEF VAR aux_cdcooper AS INTE                                      NO-UNDO.


    ASSIGN aux_cdcooper = IF   AVAIL crabcop   THEN
                               crabcop.cdcooper
                          ELSE
                               crapcop.cdcooper.
    
    FIND crabdat WHERE crabdat.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
        
    IF   TODAY > crabdat.dtmvtolt   THEN    
         DO:
             RUN deleta_objetos.
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.

/* Verificar se o processo esta ainda executando em estado de crise */
PROCEDURE verifica_processo_crise:

    /* Se nao estiver em estado de crise */
    IF  aux_flestcri = 0  THEN
        DO:
            RUN verifica_processo.
    
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
        END.

    /* Verifica as Mensagens de Recebimento */     
    IF  aux_flestcri > 0 AND
        NOT(CAN-DO
        ("STR0005R2,STR0007R2,STR0008R2,PAG0107R2," +
         "PAG0108R2,PAG0143R2," +     /* TED */
         "STR0037R2,PAG0137R2," +     /* TEC */
         "STR0026R2," +               /* VR Boleto */
         
         "STR0005,PAG0107,STR0008,PAG0108," +  /* Rejeitadas */
         "PAG0137,STR0037," +                  /* Rejeitadas */
         "STR0026", aux_CodMsg)) THEN          /* Rejeitada */
         DO:
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.

/* mesma procedure usada na b2crap14 e no crps538, se alterar aqui
   nao esquecer de alterar nos outros dois tambem */
PROCEDURE verifica-vencimento-titulo:

    DEF  INPUT PARAM p-cod-cooper     AS INTE NO-UNDO.
    DEF  INPUT PARAM p-dt-vencto      AS DATE NO-UNDO.

    DEF OUTPUT PARAM p-critica-data   AS LOGI NO-UNDO.

    DEF VAR dt-dia-util               AS DATE NO-UNDO.

    p-critica-data = FALSE.
    
    FIND crapdat WHERE crapdat.cdcooper = p-cod-cooper NO-LOCK NO-ERROR.

    /** Pagamento no dia **/
    IF  p-dt-vencto > crapdat.dtmvtocd  THEN
        RETURN.
        
    IF  crapdat.dtmvtoan < p-dt-vencto  THEN
        RETURN.

    p-critica-data = TRUE.
    
    /** Tratamento para permitir pagamento no primeiro dia util do **/
    /** ano de titulos vencidos no ultimo dia util do ano anterior **/
    IF  YEAR(crapdat.dtmvtoan) <> YEAR(crapdat.dtmvtocd)  THEN
        DO: 
            dt-dia-util = DATE(12,31,YEAR(crapdat.dtmvtoan)).
           
            /** Se dia 31/12 for segunda-feira obtem data do sabado **/
            /** para aceitar vencidos do ultimo final de semana     **/
            IF  WEEKDAY(dt-dia-util) = 2  THEN
                dt-dia-util = DATE(12,29,YEAR(crapdat.dtmvtoan)).
            ELSE
            /** Se dia 31/12 for domingo, o ultimo dia util e 29/12 **/
            IF  WEEKDAY(dt-dia-util) = 1  THEN
                dt-dia-util = DATE(12,29,YEAR(crapdat.dtmvtoan)).
            ELSE
            /** Se dia 31/12 for sabado, o ultimo dia util e 30/12 **/
            IF  WEEKDAY(dt-dia-util) = 7  THEN
                dt-dia-util = DATE(12,30,YEAR(crapdat.dtmvtoan)).

            /** Verifica se pode aceitar o titulo vencido **/
            IF  p-dt-vencto >= dt-dia-util  THEN
                p-critica-data = FALSE.
        END.

END PROCEDURE.


PROCEDURE finaliza_paralelo.

    RUN sistema/generico/procedures/bo_paralelo.p PERSISTENT SET h_paralelo.
        
    RUN finaliza_paralelo IN h_paralelo (INPUT aux_idparale,
                                         INPUT aux_idprogra).
                                         
    IF VALID-HANDLE(h_paralelo) THEN
        DELETE PROCEDURE h_paralelo.
                                
    UNIX SILENT VALUE("echo " + 
                      STRING(TODAY,"99/99/9999") + " - " +
                      STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' -->    '" +
                      "Fim da Execucao Paralela - " + 
                      "Seq.: " + STRING(aux_idprogra,"zzzz9") + " - " + 
                      "Mensagem: " + aux_nmarqori  + 
                      " >> /usr/coop/" + crapcop.dsdircop + "/log/crps531_" +   
                      STRING(crapdat.dtmvtolt,"99999999") + ".log").                      
    QUIT.                  
    
END PROCEDURE.

PROCEDURE liquida_contrato_emprestimo_antigo.

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.

    DEF VAR aux_txjuremp AS DECI                                    NO-UNDO.
    DEF VAR aux_inusatab AS LOG                                     NO-UNDO.
    DEF VAR aux_flgerro  AS LOG                                     NO-UNDO.

    ASSIGN aux_flgerro = TRUE.
    
    DO TRANSACTION ON ERROR UNDO, LEAVE:
    
       FIND crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                          crapepr.nrdconta = par_nrdconta AND
                          crapepr.nrctremp = par_nrctremp EXCLUSIVE-LOCK NO-ERROR.
    
       IF  AVAIL crapepr THEN
           DO:
               FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                                  craptab.nmsistem = "CRED"        AND
                                  craptab.tptabela = "USUARI"      AND
                                  craptab.cdempres = 11            AND
                                  craptab.cdacesso = "TAXATABELA"  AND
                                  craptab.tpregist = 0             NO-LOCK NO-ERROR.
    
               IF   NOT AVAILABLE craptab   THEN
                    aux_inusatab = FALSE.
               ELSE
                    aux_inusatab = IF SUBSTRING(craptab.dstextab,1,1) = "0"
                                      THEN FALSE
                                      ELSE TRUE.
    
               /* Nao debitar os emprestimos com emissao de boletos */ 
               FIND craplcr WHERE craplcr.cdcooper = par_cdcooper      AND
                                  craplcr.cdlcremp = crapepr.cdlcremp  AND
                                  craplcr.cdusolcr = 2   NO-LOCK NO-ERROR.
    
               IF  AVAIL craplcr THEN
                   DO:
                       UNIX SILENT VALUE("echo '" + string(par_dtmvtolt, "99/99/9999") + " " +
                                         STRING(TIME,"HH:MM:SS") +
                                         " => Liquidacao " + 
                                         "|" + TRIM(STRING(crapepr.cdagenci, "zzz9")) +
                                         "|" + TRIM(STRING(crapepr.nrdconta, "zzzz,zz9,9")) +
                                         "|" + TRIM(STRING(crapepr.nrctremp, "zzzzzzzzz9")) +
                                         "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) +
                                         "|Emprestimo com emissao de boleto - LCR: " +
                                         STRING(crapepr.cdlcremp,"zz9") +
                                         "' >> " + aux_nmlogprt).
                       UNDO.
                   END.
    
               IF  aux_inusatab THEN
                   DO:
                       FIND craplcr WHERE craplcr.cdcooper = par_cdcooper     AND
                                          craplcr.cdlcremp = crapepr.cdlcremp  
                                          NO-LOCK NO-ERROR.
           
                       IF   NOT AVAILABLE craplcr   THEN
                            DO:
                                glb_cdcritic = 363.
                                RUN fontes/critic.p.
                                UNIX SILENT VALUE("echo '" + string(par_dtmvtolt, "99/99/9999") + " "
                                               + STRING(TIME,"HH:MM:SS") +
                                               " => Liquidacao " + 
                                               "|" + TRIM(STRING(crapepr.cdagenci, "zzz9")) +
                                               "|" + TRIM(STRING(crapepr.nrdconta, "zzzz,zz9,9")) +
                                               "|" + TRIM(STRING(crapepr.nrctremp, "zzzzzzzzz9")) +
                                               "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) +
                                               "|" + glb_dscritic + " - LCR: " +
                                               STRING(crapepr.cdlcremp,"zz9") +
                                               "' >> " + aux_nmlogprt).
                                UNDO.
                            END.
                       ELSE
                            aux_txjuremp = craplcr.txdiaria.
                   END.
               ELSE
                   aux_txjuremp = crapepr.txjuremp.
    
               ASSIGN crapepr.inliquid = 1
                      crapepr.dtultpag = par_dtmvtolt
                      crapepr.txjuremp = aux_txjuremp.
    
               DO aux_contlock = 1 TO 10:
    
                   FIND craplot WHERE craplot.cdcooper = par_cdcooper      AND
                                      craplot.dtmvtolt = par_dtmvtolt      AND
                                      craplot.cdagenci = 1                 AND
                                      craplot.cdbccxlt = 100               AND
                                      craplot.nrdolote = 8453 
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
                   IF  NOT AVAIL craplot  THEN
                       DO:
                           IF  LOCKED craplot   THEN
                               DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT.
                               END.
                           ELSE
                               DO:
                                   CREATE craplot.
                                   ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                          craplot.cdagenci = 1
                                          craplot.cdbccxlt = 100
                                          craplot.nrdolote = 8453
                                          craplot.tplotmov = 1
                                          craplot.nrseqdig = 0
                                          craplot.vlcompcr = 0
                                          craplot.vlinfocr = 0
                                          craplot.cdhistor = 0
                                          craplot.cdoperad = "1"
                                          craplot.dtmvtopg = ?
                                          craplot.cdcooper = par_cdcooper.
                                    VALIDATE craplot.
       
                               END.
                       END.
                   ELSE
                       LEAVE.
               END.
               
               FIND craplem WHERE 
                    craplem.cdcooper = par_cdcooper       AND
                    craplem.dtmvtolt = par_dtmvtolt       AND  
                    craplem.cdagenci = 1                  AND
                    craplem.cdbccxlt = 100                AND
                    craplem.nrdolote = craplot.nrdolote   AND
                    craplem.nrdconta = crapepr.nrdconta   AND
                    craplem.nrdocmto = aux_nrctremp
                    NO-LOCK NO-ERROR.
    
               IF  NOT AVAIL craplem THEN
                   DO:
                       CREATE craplem.            
                       ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                              craplot.qtcompln = craplot.qtcompln + 1
                              craplot.qtinfoln = craplot.qtcompln
                              craplot.vlcompcr = craplot.vlcompcr + DEC(aux_VlrLanc)
                              craplot.vlinfocr = craplot.vlcompcr
                              craplem.cdagenci = craplot.cdagenci
           
                              craplem.cdbccxlt = craplot.cdbccxlt
                              craplem.nrdolote = craplot.nrdolote
                              craplem.cdhistor = 095
                              craplem.dtmvtolt = par_dtmvtolt
                              craplem.dtpagemp = par_dtmvtolt
                              craplem.nrctremp = crapepr.nrctremp
                              craplem.nrdconta = crapepr.nrdconta
                              craplem.nrdocmto = aux_nrctremp
                              craplem.nrseqdig = craplot.nrseqdig
                              craplem.txjurepr = aux_txjuremp
                              craplem.vllanmto = DEC(aux_VlrLanc)
                              craplem.vlpreemp = crapepr.vlpreemp
                              craplem.cdcooper = par_cdcooper.
                       VALIDATE craplem.
                   END.
    
               FIND craplot WHERE craplot.cdcooper = par_cdcooper      AND
                                  craplot.dtmvtolt = par_dtmvtolt      AND
                                  craplot.cdagenci = 1                 AND
                                  craplot.cdbccxlt = 100               AND
                                  craplot.nrdolote = 8457
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                                        
               IF   NOT AVAILABLE craplot   THEN
                    DO:
                        CREATE craplot.
                        ASSIGN craplot.dtmvtolt = par_dtmvtolt
                               craplot.cdagenci = 1
                               craplot.cdbccxlt = 100
                               craplot.nrdolote = 8457
                               craplot.tplotmov = 1
                               craplot.nrseqdig = 0
                               craplot.vlcompcr = 0
                               craplot.vlinfocr = 0
                               craplot.cdhistor = 0
                               craplot.cdoperad = "1"
                               craplot.dtmvtopg = ?
                               craplot.cdcooper = par_cdcooper.
                        VALIDATE craplot.
                    END.
    
               CREATE craplcm.
               ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                      craplot.qtcompln = craplot.qtcompln + 1
                      craplot.qtinfoln = craplot.qtcompln
                      craplot.vlcompdb = craplot.vlcompdb + DEC(aux_VlrLanc)
                      craplot.vlinfodb = craplot.vlcompdb
        
                      craplcm.cdagenci = craplot.cdagenci
                      craplcm.cdbccxlt = craplot.cdbccxlt
                      craplcm.cdhistor = 108
                      craplcm.dtmvtolt = par_dtmvtolt
                      craplcm.cdpesqbb = ""
                      craplcm.nrdconta = crapepr.nrdconta
                      craplcm.nrdctabb = crapepr.nrdconta
                      craplcm.nrdctitg = STRING(crapepr.nrdconta,"99999999")
                      craplcm.nrdocmto = crapepr.nrctremp
                      craplcm.nrdolote = craplot.nrdolote
                      craplcm.nrseqdig = craplot.nrseqdig
                      craplcm.vllanmto = DEC(aux_VlrLanc)
                      craplcm.cdcooper = par_cdcooper.
               VALIDATE craplcm.
        
               /* Eliminar avisos de débito pendentes */ 
               FOR EACH crapavs WHERE crapavs.cdcooper = par_cdcooper     AND
                                      crapavs.nrdconta = craplcm.nrdconta AND
                                      crapavs.cdhistor = 108              AND
                                      crapavs.insitavs = 0                AND 
                                      crapavs.dtrefere >= par_dtmvtolt
                                      EXCLUSIVE-LOCK:
                   DELETE crapavs.
               END.
        
               RUN sistema/generico/procedures/b1wgen0043.p
                                    PERSISTENT SET h-b1wgen0043.
        
               /* Desativar o Rating associado a esta operaçao */
               RUN desativa_rating IN h-b1wgen0043 
                               (INPUT par_cdcooper,
                                INPUT 0,
                                INPUT 0,
                                INPUT "1",
                                INPUT b-crabdat.dtmvtolt,
                                INPUT b-crabdat.dtmvtopr,
                                INPUT crapepr.nrdconta,
                                INPUT 90, /* Emprestimo*/ 
                                INPUT crapepr.nrctremp,
                                INPUT TRUE,
                                INPUT 1,
                                INPUT 1,
                                INPUT "crps531_1",
                                INPUT b-crabdat.inproces,
                                INPUT FALSE,
                                OUTPUT TABLE tt-erro-bo).
                   
               IF VALID-HANDLE(h-b1wgen0043) THEN
                   DELETE PROCEDURE h-b1wgen0043.
        
               FIND FIRST tt-erro-bo NO-ERROR.
        
               IF  AVAIL tt-erro-bo THEN
                   DO:
                       UNIX SILENT VALUE("echo '" + STRING(par_dtmvtolt, "99/99/9999") + " "
                                         + STRING(TIME,"HH:MM:SS") +
                                         " => Liquidacao " + 
                                         "|" + TRIM(STRING(crapepr.cdagenci, "zzz9")) +
                                         "|" + TRIM(STRING(crapepr.nrdconta, "zzzz,zz9,9")) +
                                         "|" + TRIM(STRING(crapepr.nrctremp, "zzzzzzzzz9")) +
                                         "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) +
                                         "|" + tt-erro-bo.dscritic  + 
                                         "' >> " + aux_nmlogprt).
                                         
                       UNDO.
                   END.
        
               RUN sistema/generico/procedures/b1wgen0171.p
                        PERSISTENT SET h-b1wgen0171.
        
               /* GRAVAMES */ 
               RUN solicita_baixa_automatica IN h-b1wgen0171
                            (INPUT par_cdcooper,
                             INPUT crapepr.nrdconta,
                             INPUT crapepr.nrctremp,
                             INPUT par_dtmvtolt,
                            OUTPUT TABLE tt-erro-bo).
               
               IF VALID-HANDLE(h-b1wgen0171) THEN
                   DELETE PROCEDURE h-b1wgen0171.
        
               ASSIGN aux_flgerro = FALSE.
           END.
    END.

    IF   aux_flgerro = FALSE THEN
         RETURN "OK".
    ELSE
         RETURN "NOK".
    
END PROCEDURE.


PROCEDURE liquida_contrato_emprestimo_novo.

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO. 
    DEF INPUT PARAM par_nrdconta AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO. 
    DEF INPUT PARAM par_dtmvtoan AS DATE                            NO-UNDO.   
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO. 
    DEF INPUT PARAM par_cdagelot AS INTE                            NO-UNDO. 

    DEF VAR aux_flgerro  AS LOG                                     NO-UNDO.

    ASSIGN aux_flgerro = TRUE.
    
    DO TRANSACTION ON ERROR UNDO, LEAVE:

       RUN sistema/generico/procedures/b1wgen0084a.p
                                 PERSISTENT SET h-b1wgen0084a.
       
       IF  NOT VALID-HANDLE (h-b1wgen0084a)  THEN
           DO:
               ASSIGN aux_dscritic = "Handle invalido para h-b1wgen0084a.".
       
               UNIX SILENT VALUE("echo '" + STRING(par_dtmvtolt, "99/99/9999") + " "
                                  + STRING(TIME,"HH:MM:SS") +
                                  " => Liquidacao " + 
                                  "|" + TRIM(STRING(par_cdagenci, "zzz9")) +       /* PA */
                                  "|" + TRIM(STRING(par_nrdconta, "zzzz,zz9,9")) + /* Conta */
                                  "|" + TRIM(STRING(par_nrctremp, "zzzzzzzzz9")) +     /* Contrato */
                                  "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) + /* Portabilidade */
                                  "|" + aux_dscritic +                           /* Erro */
                                  "' >> " + aux_nmlogprt).
       
               UNDO.
           END.
       
       RUN busca_pagamentos_parcelas IN h-b1wgen0084a
                           (INPUT par_cdcooper,
                            INPUT par_cdagelot,
                            INPUT 0,
                            INPUT "1",
                            INPUT "crps531_1",
                            INPUT 1,
                            INPUT par_nrdconta,
                            INPUT 1,
                            INPUT par_dtmvtolt,
                            INPUT FALSE,
                            INPUT par_nrctremp,
                            INPUT par_dtmvtoan,
                            INPUT 0, /* Todas */
                           OUTPUT TABLE tt-erro-bo,
                           OUTPUT TABLE tt-pagamentos-parcelas,
                           OUTPUT TABLE tt-calculado).
       
       IF  VALID-HANDLE(h-b1wgen0084a) THEN
           DELETE PROCEDURE h-b1wgen0084a.
            
       FIND FIRST tt-erro-bo NO-ERROR.
       
       IF  AVAIL tt-erro-bo THEN
           DO:
               UNIX SILENT VALUE("echo '" + STRING(par_dtmvtolt, "99/99/9999") + " "
                                 + STRING(TIME,"HH:MM:SS") +
                                 " => Liquidacao " + 
                                 "|" + TRIM(STRING(par_cdagenci, "zzz9")) +       /* PA */
                                 "|" + TRIM(STRING(par_nrdconta, "zzzz,zz9,9")) + /* Conta */
                                 "|" + TRIM(STRING(par_nrctremp, "zzzzzzzzz9")) +     /* Contrato */
                                 "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) + /* Portabilidade */
                                 "|" + tt-erro-bo.dscritic +                    /* Erro */
                                 "' >> " + aux_nmlogprt).                                   
       
               UNDO.
           END.
            
       RUN sistema/generico/procedures/b1wgen0136.p
                                     PERSISTENT SET h-b1wgen0136.
        
       IF  NOT VALID-HANDLE (h-b1wgen0136)  THEN
           DO:
               ASSIGN aux_dscritic = "Handle invalido para h-b1wgen0084a.".
       
               UNIX SILENT VALUE("echo '" + STRING(par_dtmvtolt, "99/99/9999") + " "
                               + STRING(TIME,"HH:MM:SS") +
                               " => Liquidacao " + 
                               "|" + TRIM(STRING(par_cdagenci, "zzz9")) +       /* PA */
                               "|" + TRIM(STRING(par_nrdconta, "zzzz,zz9,9")) + /* Conta */
                               "|" + TRIM(STRING(par_nrctremp, "zzzzzzzzz9")) +     /* Contrato */
                               "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) + /* Portabilidade */
                               "|" + aux_dscritic +                           /* Erro */
                               "' >> " + aux_nmlogprt).
               UNDO.
           END.
       
       RUN efetua_liquidacao_empr IN h-b1wgen0136
                       (INPUT par_cdcooper,
                        INPUT par_cdagelot,
                        INPUT 0,
                        INPUT "1",
                        INPUT "crps531_1",
                        INPUT 1,
                        INPUT 1,
                        INPUT par_nrdconta,
                        INPUT 1,
                        INPUT par_dtmvtolt,
                        INPUT FALSE,
                        INPUT par_nrctremp,
                        INPUT par_dtmvtoan,
                        INPUT FALSE,
                        INPUT TABLE tt-pagamentos-parcelas,
                        INPUT 0,
                        OUTPUT TABLE tt-erro-bo).
       
       IF  VALID-HANDLE(h-b1wgen0136) THEN
           DELETE PROCEDURE h-b1wgen0136.
       
       IF  RETURN-VALUE <> "OK"   THEN
           DO:
              FIND FIRST tt-erro-bo NO-ERROR.
              
              IF  AVAIL tt-erro-bo THEN
                  UNIX SILENT VALUE("echo '" + STRING(par_dtmvtolt, "99/99/9999") + " "
                                     + STRING(TIME,"HH:MM:SS") +
                                     " => Liquidacao " + 
                                     "|" + TRIM(STRING(par_cdagenci, "zzz9")) +       /* PA */
                                     "|" + TRIM(STRING(par_nrdconta, "zzzz,zz9,9")) + /* Conta */
                                     "|" + TRIM(STRING(par_nrctremp, "zzzzzzzzz9")) +     /* Contrato */
                                     "|" + TRIM(STRING(DECIMAL(aux_NUPortdd), "zzzzzzzzzzzzzzzzzzzz9")) + /* Portabilidade */
                                     "|" + tt-erro-bo.dscritic +                    /* Erro */
                                     "' >> " + aux_nmlogprt).
                 
              UNDO.
           END.

        ASSIGN aux_flgerro = FALSE.
        
    END. /*TRANSACTION*/

    IF   aux_flgerro = FALSE THEN
         RETURN "OK".
    ELSE
         RETURN "NOK".

END PROCEDURE.

PROCEDURE cancela_portabilidade.

    DEF INPUT   PARAM par_cdcooper LIKE crapcop.cdcooper      NO-UNDO.
    DEF INPUT   PARAM par_idservic AS INTE                    NO-UNDO.
    DEF INPUT   PARAM par_cdlegado AS CHAR                    NO-UNDO.
    DEF INPUT   PARAM par_nrispbif AS DECI                    NO-UNDO.
    DEF INPUT   PARAM par_inparadm AS DECI                    NO-UNDO.
    DEF INPUT   PARAM par_cnpjifcr AS DECI                    NO-UNDO.
    DEF INPUT   PARAM par_nuportld AS CHAR                    NO-UNDO.
    DEF OUTPUT  PARAM par_flgrespo AS INTE                    NO-UNDO.
    DEF OUTPUT  PARAM par_des_erro AS CHAR                    NO-UNDO.
    DEF OUTPUT  PARAM par_dscritic AS CHAR                    NO-UNDO.  

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_cancelar_portabilidade
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,               /* Cód Cooperativa*/
                          INPUT par_idservic,               /* Tipo de servico(1-Proponente/2-Credora) */
                          INPUT par_cdlegado,               /* Codigo Legado */
                          INPUT par_nrispbif,               /* Numero ISPB IF */
                          INPUT par_inparadm,               /* Identificador Participante Administrado */
                          INPUT par_cnpjifcr,               /* CNPJ Base IF Credora Original Contrato */
                          INPUT par_nuportld,               /* Numero Portabilidade CTC */
                          INPUT "002",                      /* Motivo Cancelamento Portabilidade */
                         OUTPUT 0,                          /* 1 - Se o registro na JDCTC for atualizado com sucesso */
                         OUTPUT "",                         /* Indicador erro OK/NOK */
                         OUTPUT "").                        /* Descricao do erro */
    
    CLOSE STORED-PROC pc_cancelar_portabilidade
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN par_flgrespo = pc_cancelar_portabilidade.pr_flgrespo
                          WHEN pc_cancelar_portabilidade.pr_flgrespo <> ?
           par_des_erro = pc_cancelar_portabilidade.pr_des_erro
                          WHEN pc_cancelar_portabilidade.pr_des_erro <> ?
           par_dscritic = pc_cancelar_portabilidade.pr_dscritic 
                          WHEN pc_cancelar_portabilidade.pr_dscritic <> ?.

    RUN fontes/substitui_caracter.p 
        (INPUT-OUTPUT par_dscritic).  
    
END PROCEDURE.



