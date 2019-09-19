/* .............................................................................

   Programa: b1wgen0012.p                  
   Autora  : Ze Eduardo
   Data    : 20/11/2006                        Ultima atualizacao: 13/04/2018

   Dados referentes ao programa:

   Objetivo  : BO GERA ARQUIVO DE TEDS, DOCTOS, TITULOS e CHEQUES
   Alteracoes: 10/12/2007 - Alterado BO para receber informacoes via temp-table
                            e nao efetuar leitura de tabela de Trasf-salarios
                            (Sidnei - Supero).

               01/04/2009 - Incluido calculo do digito verificador nas contas
                            de destino do Banco do Brasil para se adequar ao
                            uso do digito "X" (Elton).

               08/06/2009 - Caso o digito verificador nas contas de destino do
                            Banco do Brasil for igual a "X", passar como 0 para
                            o fontes/digbbx.p (Fernando).

               14/12/2009 - Ajustado o comando unix para mover o arquivo
                            gerado para o salvar (Fernando).

               26/02/2010 - Criacao de Procedures para Gerar, Consultar e 
                            Reativar registros de Doctos, Titulos e Compel.
                            (Guilherme/Supero)
                            
               31/05/2010 - Acerto na geracao de DOCS (Guilherme).
               
               02/06/2010 - Nao remover registros ja enviados (Guilherme).

               15/06/2010 - Tratamento para PAC 91 - TAA conforme PAC 90 
                            (Elton).
                            
               17/06/2010 - Alterado extensão do arquivo de 2 para 3 posições
                           (Jonatas/Supero).
                            
               18/06/2010 - Acerto do digito verificador para contas ITG
                            (Fernando).
                            
               28/06/2010 - Alteracao para envio do arquivo do PAC 90 (Ze).
               
               06/08/2010 - Retirar procedure de gerar_devolu (Ze).
               
               30/08/2010 - Incluido caminho completo no destino dos arquivos
                            do diretorio "arq" (Elton).

               09/09/2010 - Alterada a procedure consultar_devolu, para
                            processar indevarq e nao mais insitdev
                            (Guilherme/Supero)
                            
               18/11/2010 - Incluido procedures visualiza_cheques_previa e 
                            emite_protocolo_previa (Elton).
               03/12/2010 - Criacao das procedures gerar_compel_prcctl e 
                            reativar_compel_prcctl, afim de separar os
                            processamentos (Guilherme/Supero)
               20/01/2011 - Incluido novo parametro na procedure 
                            gerar_arquivos_cecred (Elton).
                          - Tratar geração de arquivos Custodia e Descto Cheq
                            p/ Compe Imagem (Guilherme).
               04/03/2011 - Tratar geracao de arquivo da Tela DIGITA(Guilherme)
               09/03/2011 - Alterada para usar a crapcdb no desconto de cheque
                            da opcao B da COMPEL (Gabriel).          
               11/03/2011 - Alterado nrdolote para nrborder na procedure
                            gerar_compel_dscchq (Adriano).             
               16/03/2011 - Tratamentos para forca tarefa de digitalizacao de
                            cheques em custodia e desconto (Guilherme).
               29/03/2011 - Alterar de 25/03 para 15/04 (Ze).             
               19/05/2011 - Retirada verificacoes referente ao dia 20/05/2011
                            (Elton).
               29/07/2011 - Ajuste na geracao do arquivo COMPEL via PRCCTL (Ze)
               26/09/2011 - Tratamento para Rotina 66 e alteracao no nome da
                            previa para Custodia e Desconto (Ze).
               28/09/2011 - Aplicacao de testes de digitalizacao para cheques
                            da propria cooperativa - Somente Coop. 4 (Ze).
               06/10/2011 - Incluido crapcop.dsdircop antes do spool na geracao
                            do arquivo na procedure visualiza_cheques_previa 
                            (Elton).             
               07/10/2011 - Alterar diretorio spool para
                            /usr/coop/sistema/siscaixa/web/spool (Fernando).
               22/12/2011 - Tratamento para o DOC C - Trf. 44310 (Ze).
               02/01/2012 - Alteracao Temporario para enviar os titulos pagos
                            no dia 30/12/2011 no TAA. No dia 03/01 voltei a
                            versao anterior (Ze).
               13/02/2012 - Alteracao para que todas as coops possam digitalizar
                            cheques da propria cooperativa (ZE).
               16/02/2012 - Alterado a procedure gerar_titulo para gerar o 
                            o arquivo informando o crapage.cdagepac ao inves
                            do crapcop.cdagectl (Adriano).
               07/03/2012 - Correcao Tarefa 44310. Quando DOC C de conta
                            conjunta, enviar segundo titular como remetente, e 
                            nao destinatario (Diego).
               30/03/2012 - Informar no arq COB605 quando pagto DDA. (Rafael)

               03/04/2012 - TIB DDA - Gravacao flgpgdda na GNCPTIT
                            (Guilherme/Supero)

                23/08/2012 - Procedure gerar_arquivo_cecred - Inclusao da 
                             geracao arquivos TIC604
                           - Nova procedure reativar_tic604
                             (Guilherm/Supero)
                             
               17/10/2012 - Incluido contador de registros nas procedures,
                            gerar_compel_prcctl, gerar_doctos, gerar_titulo e
                            gerar_tic604. (Fabricio)

               25/10/2012 - Considerar cheques com a data de liberacao 
                            acima de D+3 na procedure gerar_tic604 (Ze).
                            
               31/10/2012 - Tratamento para DLL Kofax Antiga (Ze).

               31/10/2012 - Criada procedure gerar_compel_altoVale, para tratar
                            dos cheques das contas migradas 
                            (Viacredi -> Alto Vale). (Fabricio)
                            
               23/01/2013 - Acerto nas procedures 'gerar_compel_prcctl' e 
                            'gerar_compel' ref. cheques de conta
                            migrada(VIACREDI) (Diego).
                            
               07/03/2013 - Ajuste na TIC (Ze).
               
               26/03/2013 - Ajuste na TIC (Ze).
               
               25/04/2013 - Ajuste no tratamento de Exclusive-lock 
                            (David Kruger).
                            
               27/05/2013 - Conforme circular INFO-CIP 009/2013, foi extinto
                            TD 44 e 144 dos titulos Nossa Remessa. (Rafael)
                          - Ao reativar titulos, desconsiderar VR Boletos, pois
                            não deverão ser reenviados. (Rafael)
                            
               13/08/2013 - Nova forma de chamar as agências, alterado para
                          "Posto de Atendimento" (PA). (André Santos - SUPERO)
                              
               12/09/2013 - Bloquear resgate de cheques caso estiver sendo
                            enviado para a compe - Task 84413 (Rafael).
                            
               23/10/2013 - Alterado na procedure gerar_tic604, no TRAILER
                            do arquivo, de FIL("0", 17) para aux_totvlchq.
                            (Fabricio)
                            
               19/12/2013 - Adicionado validate para as tabelas gncpdoc,
                            gncptit, gncpchq, gncptic, b-craptab (Tiago).
                            
               26/12/2013 - Tratamento migracao AcrediCoop (Ze).             
               
               13/01/2014 - Alterada critica "015 - Agencia nao cadastrada" para
                            "962 - PA nao cadastrado". (Reinert)
                            
               15/01/2014 - Ajustes na leitura da tabela craptco, nas procedures
                            gerar_compel e gerar_compel_prcctl.
                            Nao verificar a craptco se nao for uma conta
                            nossa(Sistema CECRED). (Fabricio)
                            
               04/07/2014 - Aumento do format do numero do bordero para o nome
                            do arquivo na procedure gerar_compel_dscchq (Carlos)
                            
               11/07/2014 - #177846 Modificado o inicio do nome do arquivo na 
                            procedure gerar_compel_dscchq de "desconto-" para 
                            "desc-" (Carlos)
                            
               21/07/2014 - Alterada procedure gerar_compel_prcctl para tratar
                            deposito intercooperativa. (Reinert)                            
                            
               05/08/2014 - Adicionado coluna "Agencia" na procedure 
                            visualiza_cheques_previa. (Reinert)
                            
               12/08/2014 - Ajustes na geracao dos arquivos TIC604 e DCR605 
                            para tratar a Unificacao das SIRC's; 018.
                            (Chamado 146058) - (Fabricio)
                            
               23/09/2014 - Alterada procedure gerar_compel para tratar deposito 
                            intercooperativa. (Reinert)     
                            
               18/12/2014 - Ajustado para incluir o valor 0 na verificacao da
                            insittit, ajuste solicitado Rafael. Retirado tratamento
                            incorporacao efetuado na leitura da crapcst (Daniel).   
                            
               23/01/2015 - Ajustes para substituir as tabs "OPEVIACUSTOD" e "VIACUSTOD" 
                            pela tab "OPEDIGITEXC", pois as anteriores nao permitiam
                            cadastrar os cooperados com letra ex. f0030123
                            SD 239679  (Odirlei-AMcom)       
               
               26/01/2015 - Ajustes na rotina gerar_doctos, para não pular a geração
                            do arquivo quando encontrado critica SD 243042(Odirlei-AMcom)
               
               07/03/2016 - #407136 - Incluido novo filtro ao verificar se o operador
                            pertence a forca tarefa da VIACREDI. Estava considerando de forma
                            parcial (Ex: Operador 294 e 2941). (Heitor - RKAM)

               30/05/2016 - Adicionado campo de codigo identificador no layout do BB
                            nas procedures gerar_compel_prcctl, gerar_compel_dscchq,
                            gerar_compel_custodia, gerar_compel, gerar_digita e 
                            gerar_compel_altoVale (Douglas - Chamado 445731) 

                           20/07/2016 - Alteracao do caminho onde serao salvos os arquivos
                                                        de truncagem com nomes("caixa-*", "desc-*" e "custodia-*"). 
                                                        SD 476097. Carlos Rafael Tanholi.

               04/11/2016 - Cheques custodiados deverao ter o numero do bordero
                            igual a zero. (Projeto 300 - Rafael)                                                         

               12/12/2016 - Ajuste gerar_titulo Nova Plataforma de Cobrana. PRJ340 - NPC (Odirlei-AMcom)
               
               23/01/2017 - Realizado merge com a PROD ref ao projeto 300 (Rafael)                            
               
               31/05/2017 - Ajustado código da agencia do PA ao enviar arquivo COB605. (Rafael)
                        
               17/08/2017 - #738442 Retiradas as mensagens informativas 
                            "Verificando registros para geracao de arquivo(s)" (Carlos)

                           27/09/2017 - Ajuste na tratativa PG_CX, em casos especificos estava ficava na
                                        variavel aux_dschqctl o valor do cheque anterior. (Daniel - Chamado 753756) 

               24/11/2017 - Retirado (nrborder = 0) e feita validacao para verificar
                            se o cheque esta em bordero de desconto efetivado
                            antes de prosseguir com a custodia
                            Rotina gerar_digita (Tiago/Adriano #766582)      
                                                        
                           13/04/2018 - Removidas validacoes de valor do cheque - COMPE SESSAO UNICA (Diego)          
                                         
               30/07/2019 - PJ565 - Validaçoes e gravaçao da estrutura tabema nossa remessa - Renato Cordeiro - AMcom
               
               ............................................................................. */

{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF TEMP-TABLE crattem                                                  NO-UNDO
         FIELD cdseqarq       AS INTEGER
         FIELD nrdolote       AS INTEGER
         FIELD cddbanco       AS INTEGER
         FIELD nmarquiv       AS CHAR
         FIELD nrrectit       AS RECID
         FIELD nrdconta       LIKE crapccs.nrdconta
         FIELD cdagenci       LIKE crapccs.cdagenci
         FIELD cdbantrf       LIKE crapccs.cdbantrf
         FIELD cdagetrf       LIKE crapccs.cdagetrf
         FIELD nrctatrf       LIKE crapccs.nrctatrf
         FIELD nrdigtrf       LIKE crapccs.nrdigtrf
         FIELD nmfuncio       LIKE crapccs.nmfuncio
         FIELD nrcpfcgc       LIKE crapccs.nrcpfcgc
         FIELD nrdocmto       LIKE craplcs.nrdocmto
         FIELD vllanmto       LIKE craplcs.vllanmto
         FIELD dtmvtolt       LIKE craplcs.dtmvtolt
         FIELD tppessoa       AS INT FORMAT "9"
         INDEX crattem1 cdseqarq nrdolote.

DEF TEMP-TABLE crawage                                                  NO-UNDO
         FIELD  cdcooper      LIKE crapage.cdcooper
         FIELD  cdagenci      LIKE crapage.cdagenci
         FIELD  nmresage      LIKE crapage.nmresage
         FIELD  nmcidade      LIKE crapage.nmcidade 
         FIELD  cdbandoc      LIKE crapage.cdbandoc
         FIELD  cdbantit      LIKE crapage.cdbantit
         FIELD  cdagecbn      LIKE crapage.cdagecbn
         FIELD  cdbanchq      LIKE crapage.cdbanchq
         FIELD  cdcomchq      LIKE crapage.cdcomchq.

DEFINE TEMP-TABLE tt-titulos                                            NO-UNDO
         FIELD qttitrec       AS INT
         FIELD vltitrec       AS DEC
         FIELD qttitrgt       AS INT
         FIELD vltitrgt       AS DEC
         FIELD qttiterr       AS INT
         FIELD vltiterr       AS DEC
         FIELD qttitprg       AS INT
         FIELD vltitprg       AS DEC
         FIELD qttitcxa       AS INT
         FIELD vltitcxa       AS DEC
         FIELD qttitulo       AS INT
         FIELD vltitulo       AS DEC.
                              
DEFINE TEMP-TABLE tt-compel                                             NO-UNDO
         FIELD qtchdcxi       AS INT
         FIELD qtchdcxs       AS INT
         FIELD qtchdcxg       AS INT
         FIELD qtchdcsi       AS INT
         FIELD qtchdcss       AS INT
         FIELD qtchdcsg       AS INT
         FIELD qtchddci       AS INT
         FIELD qtchddcs       AS INT
         FIELD qtchddcg       AS INT
         FIELD qtchdtti       AS INT
         FIELD qtchdtts       AS INT
         FIELD qtchdttg       AS INT
         FIELD vlchdcxi       AS DEC
         FIELD vlchdcxs       AS DEC
         FIELD vlchdcxg       AS DEC
         FIELD vlchdcsi       AS DEC
         FIELD vlchdcss       AS DEC
         FIELD vlchdcsg       AS DEC
         FIELD vlchddci       AS DEC
         FIELD vlchddcs       AS DEC
         FIELD vlchddcg       AS DEC
         FIELD vlchdtti       AS DEC
         FIELD vlchdtts       AS DEC
         FIELD vlchdttg       AS DEC.

DEFINE TEMP-TABLE tt-doctos                                             NO-UNDO
         FIELD cdagenci       LIKE craptvl.cdagenci
         FIELD cdbccxlt       LIKE craptvl.cdbccxlt
         FIELD nrdolote       LIKE craptvl.nrdolote
         FIELD nrdconta       LIKE craptvl.nrdconta
         FIELD nrdocmto       LIKE craptvl.nrdocmto
         FIELD vldocrcb       LIKE craptvl.vldocrcb.

DEFINE TEMP-TABLE tt-custdesc
         FIELD cdcmpchq       AS INT  /* Compe Destino    */
         FIELD cdbanchq       AS INT  /* Banco Destino    */
         FIELD cdagechq       AS INT  /* Agencia Destino  */
         FIELD nrctachq       AS DECI /* Nr Conta Destino */
         FIELD nrcheque       AS INT  /* Nr Documento     */
         FIELD tpcptdoc       AS INT /* Tp Capt Cheque ?? */
         FIELD cdbanapr       AS INT  /* Banco Apresent.  */
         FIELD cdageapr       AS INT  /* Agencia Apresent */
         FIELD cdagedep       AS INT  /* Agencia Deposito */
         FIELD nrdconta       AS INT  /* Conta Deposito   */
         FIELD cdcmpapr       AS INT  /* Compe Acolhimento*/
         FIELD dtlibera       AS DATE /* Data Boa         */
         FIELD cdcmpori       AS INT  /* Compe Origem     */
         FIELD cdtpddoc       AS INT  /* Tipo Docmto TD   */
         FIELD cdagedv2       AS INT  /* DV AGE */
         FIELD cdctadv1       AS INT  /* DV CONTA */
         FIELD cdchqdv3       AS INT  /* DV CHEQUE */
         FIELD dstipfic       AS CHAR /* TIPIFICACAO */
         FIELD dsdocmc7       AS CHAR
         FIELD vlcheque       AS DECI. /* VALOR */

DEF      BUFFER crabtvl       FOR craptvl.
DEF      BUFFER crabtit       FOR craptit.
DEF      BUFFER crabchd       FOR crapchd.
DEF      BUFFER crabcst       FOR crapcst.
DEF      BUFFER crabcdb       FOR crapcdb.

DEF      VAR aux_sequen       AS INTE                                   NO-UNDO.
DEF      VAR aux_dsorgarq     AS CHAR                                   NO-UNDO.
DEF      VAR aux_qtregarq     AS INT                                    NO-UNDO.
DEF      VAR aux_digitage     AS CHAR                                   NO-UNDO.
DEF      VAR aux_vltotarq     AS DECIMAL                                NO-UNDO.
DEF      VAR aux_cdsequen     AS INT                                    NO-UNDO.
DEF      VAR aux_hrarquiv     AS CHAR                                   NO-UNDO.
DEF      VAR aux_nmarquiv     AS CHAR                                   NO-UNDO.
DEF      VAR aux_tpdoctrf     AS CHAR   FORMAT "x(01)"                  NO-UNDO.
DEF      VAR aux_vltotdoc     AS DECIMAL                                NO-UNDO.
DEF      VAR aux_nmpesrcb     LIKE craptvl.nmpesrcb                     NO-UNDO.
DEF      VAR aux_cpfcgrcb     LIKE craptvl.cpfcgrcb                     NO-UNDO.
DEF      VAR aux_nmpesemi     LIKE craptvl.nmpesemi                     NO-UNDO.
DEF      VAR aux_cpfcgemi     LIKE craptvl.cpfcgemi                     NO-UNDO.
DEF      VAR aux_contador     AS INT                                    NO-UNDO.
DEF      VAR aux_qttitcxa     AS INT                                    NO-UNDO.
DEF      VAR aux_qttitprg     AS INT                                    NO-UNDO.
DEF      VAR aux_vltitcxa     AS DECIMAL                                NO-UNDO.
DEF      VAR aux_vltitprg     AS DECIMAL                                NO-UNDO.
DEF      VAR aux_cdcooper     AS INT                                    NO-UNDO.
DEF      VAR aux_dscooper     AS CHAR                                   NO-UNDO.
DEF      VAR aux_nmdatela     AS CHAR                                   NO-UNDO.
DEF      VAR aux_nmarqlog     AS CHAR                                   NO-UNDO.
DEF      VAR aux_nmprgexe     AS CHAR                                   NO-UNDO.
DEF      VAR aux_dscomand     AS CHAR                                   NO-UNDO.
DEF      VAR aux_dsdirmic     AS CHAR                                   NO-UNDO.
DEF      VAR aux_retorno      AS CHAR                                   NO-UNDO.
DEF      VAR aux_mes          AS CHAR                                   NO-UNDO.   
DEF      VAR aux_contador2    AS INTE                                   NO-UNDO.

DEF      VAR aux_cdcritic     AS INTEGER                                NO-UNDO.
DEF      VAR aux_dscritic     AS CHARACTER                              NO-UNDO.
DEF      VAR aux_dtmvtolt     AS DATE                                   NO-UNDO.


/*............................................................................*/

FUNCTION calc_prox_tres_dia_uteis RETURNS DATE(INPUT par_data AS DATE):

    /* Calcular proximo dia util da data do parametro */
       
    DEF VAR tmp_dtrefere    AS DATE                         NO-UNDO.
    DEF VAR aux_dtultdia    AS DATE                         NO-UNDO.
    DEF VAR aux_contadia    AS INT                          NO-UNDO.
    
    tmp_dtrefere = par_data.

    DO aux_contadia = 1 TO 3:
    
             
      /* Pega o ultimo dia util antes de ontem */
          
      tmp_dtrefere = tmp_dtrefere + 1.
      
      DO  WHILE TRUE:

          IF   WEEKDAY(tmp_dtrefere) = 1   OR
               WEEKDAY(tmp_dtrefere) = 7   THEN
               DO:
                  tmp_dtrefere = tmp_dtrefere + 1.
                  NEXT.
               END.
                                    
          FIND crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                             crapfer.dtferiad = tmp_dtrefere
                             NO-LOCK NO-ERROR.
                                                            
          IF   AVAILABLE crapfer   THEN
               DO:
                  tmp_dtrefere = tmp_dtrefere + 1.
                  NEXT.
               END.

          LEAVE.
        
      END.  /*  Fim do DO WHILE TRUE  */
    
    END.
    
    IF   par_data = aux_dtultdia THEN
         tmp_dtrefere = tmp_dtrefere + 1.
    
    RETURN tmp_dtrefere.

END FUNCTION.  

 
PROCEDURE gera-arquivo-ted-doc:

   DEF VAR aux_dtmvtolt AS CHAR                                       NO-UNDO.
   DEF VAR aux_qtarquiv AS INT                                        NO-UNDO.
   DEF VAR aux_qtregarq AS INT                                        NO-UNDO.
   DEF VAR aux_hrarquiv AS CHAR                                       NO-UNDO.
   DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
   DEF VAR aux_cdsequen AS INT                                        NO-UNDO.
   DEF VAR aux_nrconven AS CHAR                                       NO-UNDO.
   DEF VAR aux_qtdoclot AS INT                                        NO-UNDO.
   DEF VAR aux_vltotlot AS DECIMAL                                    NO-UNDO.
   DEF VAR aux_vlarq_01 AS CHAR       FORMAT "x(07)"                  NO-UNDO.
   DEF VAR aux_vlarq_02 AS CHAR       FORMAT "x(06)"                  NO-UNDO.
   DEF VAR aux_cdseqarq AS INT                                        NO-UNDO.
   DEF VAR aux_digitage AS CHAR                                       NO-UNDO.
   DEF VAR aux_qtlinarq AS INT                                        NO-UNDO.
   DEF VAR aux_contador AS INT                                        NO-UNDO.

   DEF VAR glb_nrcalcul AS DEC                                        NO-UNDO.
   DEF VAR glb_dsdctitg AS CHAR                                       NO-UNDO.
   DEF VAR glb_stsnrcal AS LOGICAL                                    NO-UNDO.
      
   DEF INPUT  PARAM TABLE FOR crattem.
   DEF INPUT  PARAM p-cdcooper AS INTE.
   DEF INPUT  PARAM p-dtmvtolt AS DATE.
   DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.

   ASSIGN aux_dtmvtolt = STRING(DAY(p-dtmvtolt),"99") +
                         STRING(MONTH(p-dtmvtolt),"99") +
                         STRING(YEAR(p-dtmvtolt),"9999")
          aux_qtarquiv = 0
          aux_qtregarq = 0.
                                     
   FIND crapcop WHERE crapcop.cdcooper = p-cdcooper   NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crapcop   THEN
        DO:
            par_dscritic = "794 - Cooperativa Invalida.".
            RETURN "NOK".
        END.    

   FIND craptab WHERE craptab.cdcooper = p-cdcooper    AND
                      craptab.nmsistem = "CRED"        AND
                      craptab.tptabela = "CONFIG"      AND
                      craptab.cdempres = 00            AND
                      craptab.cdacesso = "COMPELBBDC"  AND
                      craptab.tpregist = 000 
                      NO-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            par_dscritic = "055 - Tabela nao cadastrada.".
            RETURN "NOK".
        END.                                    
                            
   ASSIGN aux_nrconven = SUBSTR(craptab.dstextab,1,20)
          aux_cdsequen = INTEGER(SUBSTR(craptab.dstextab,22,06)).
/*        aux_cdseqarq = INTEGER(SUBSTR(craptab.dstextab,29,06)) */
          
   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".
   
   FOR EACH crattem USE-INDEX crattem1 NO-LOCK 
                    BREAK BY crattem.cdseqarq BY crattem.nrdolote:

       FIND crapage WHERE crapage.cdcooper = p-cdcooper     AND
                          crapage.cdagenci = crattem.cdagenci NO-LOCK NO-ERROR.
       
       IF   NOT AVAILABLE crapage THEN
            DO:
                par_dscritic = "962 - PA nao cadastrado".
                RETURN "NOK".
            END.
       
       IF   FIRST-OF(crattem.cdseqarq)  THEN
            DO:
                ASSIGN aux_qtregarq = 0
                       aux_hrarquiv = SUBSTR(STRING(time, "HH:MM:SS"), 1,2) +
                                      SUBSTR(STRING(time, "HH:MM:SS"), 4,2) +
                                      SUBSTR(STRING(time, "HH:MM:SS"), 7,2)
                       aux_qtarquiv = aux_qtarquiv + 1
                       aux_nmarquiv = crattem.nmarquiv
                       aux_cdseqarq = crattem.cdseqarq.
                       
                IF   SEARCH(aux_dscooper + "arq/" + aux_nmarquiv) <> ?   THEN 
                     DO:
                         par_dscritic = "459 - Arquivo ja existe " +
                                        aux_nmarquiv.
                         RETURN "NOK".
                     END.
                                               
                OUTPUT STREAM str_1 TO VALUE(aux_dscooper + "arq/" + aux_nmarquiv).
                
                /*   Header do Arquivo    */
                
                ASSIGN aux_cdsequen = aux_cdsequen + 1.
                
                PUT STREAM str_1
                           "00100000"
                           FILL(" ",09)      FORMAT "x(09)"
                           "2"
                           crapcop.nrdocnpj  FORMAT "99999999999999"
                           aux_nrconven      FORMAT "x(20)"
                           crapcop.cdagedbb  FORMAT "999999"
                           crapcop.nrctabbd  FORMAT "9999999999999"
                           " "               FORMAT "x(01)"
                           crapcop.nmrescop  FORMAT "x(30)"
                           "BANCO DO BRASIL"
                           FILL(" ",25)      FORMAT "x(25)"
                           "1"
                           aux_dtmvtolt      FORMAT "x(08)"
                           aux_hrarquiv      FORMAT "x(06)"
                           aux_cdsequen      FORMAT "999999"
                           "03000000"
                           FILL(" ",54)      FORMAT "x(54)" 
                           "000000000000000" SKIP.
            END.

       IF   FIRST-OF(crattem.nrdolote)  THEN
            DO:
                ASSIGN aux_qtdoclot = 0
                       aux_vltotlot = 0.
                                       
                /*   Header do Lote    */
                
                ASSIGN aux_vlarq_02 =  "1C9803".
                IF   crattem.cdbantrf = 1 THEN
                     ASSIGN aux_vlarq_02 = "1C9801".  /* BANCO BRASIL */
                    
                PUT STREAM str_1
                           "001"
                           crattem.nrdolote  FORMAT "9999"
                           aux_vlarq_02      FORMAT "x(06)"
                           "020 2"
                           crapcop.nrdocnpj  FORMAT "99999999999999"
                           aux_nrconven      FORMAT "x(20)"
                           crapcop.cdagedbb  FORMAT "999999"
                           crapcop.nrctabbd  FORMAT "9999999999999"
                           " "               FORMAT "x(01)"
                           crapcop.nmrescop  FORMAT "x(30)"
                           FILL(" ",40)      FORMAT "x(40)"
                           crapcop.dsendcop  FORMAT "x(30)"
                           crapcop.nrendcop  FORMAT "99999"
                           FILL(" ",15)      FORMAT "x(15)"
                           crapcop.nmcidade  FORMAT "x(20)"
                           crapcop.nrcepend  FORMAT "99999999" 
                           crapcop.cdufdcop  FORMAT "!(2)"
                           FILL(" ",08)      FORMAT "x(08)" 
                           "0000000000"      SKIP.
            END.
       
       ASSIGN aux_qtdoclot = aux_qtdoclot + 1
              aux_vltotlot = aux_vltotlot + crattem.vllanmto
              aux_qtregarq = aux_qtregarq + 1 
              aux_digitage = " ".
       
       IF   crattem.cdbantrf = 1 THEN
            DO:
                ASSIGN glb_nrcalcul = crattem.cdagetrf * 10.
                RUN fontes/digbbx.p (INPUT  glb_nrcalcul,
                                     OUTPUT glb_dsdctitg,
                                     OUTPUT glb_stsnrcal).
                
                ASSIGN aux_digitage = SUBSTR(glb_dsdctitg,8,1).
                
                /*** Calculo do digito verificador da conta de destino ***/
                ASSIGN glb_nrcalcul = DEC(STRING(crattem.nrctatrf) +
                                          crattem.nrdigtrf) NO-ERROR.
                                          
                /*** Caso o digito verificador da conta seja X ***/
                IF   ERROR-STATUS:ERROR   THEN
                     ASSIGN glb_nrcalcul = DEC(STRING(crattem.nrctatrf) + "0").
                
                RUN fontes/digbbx.p (INPUT  glb_nrcalcul,
                                     OUTPUT glb_dsdctitg,
                                     OUTPUT glb_stsnrcal).

                ASSIGN crattem.nrdigtrf =
                               SUBSTR(glb_dsdctitg,LENGTH(glb_dsdctitg),1).
            END.       

       ASSIGN aux_vlarq_01 = "A000700".
       
       IF   crattem.cdbantrf = 1 THEN        /* BANCO BRASIL */
            ASSIGN aux_vlarq_01 = "A000000".
          
       PUT STREAM str_1 "001"
                        crattem.nrdolote               FORMAT "9999"
                        "3"
                        aux_qtdoclot                   FORMAT "99999"
                        aux_vlarq_01                   FORMAT "x(07)"
                        crattem.cdbantrf               FORMAT "999"
/* Agencia s/Digito */  crattem.cdagetrf               FORMAT "99999"
/* Digito da Agencia */ aux_digitage                   FORMAT "x(01)"
/* Conta s/Digito */    crattem.nrctatrf               FORMAT "999999999999"
/* Digito da Conta*/    crattem.nrdigtrf               FORMAT "x(01)"
/* Digito Ag/Conta */   " "                            FORMAT "x(01)"
                        crattem.nmfuncio               FORMAT "x(30)"
                        STRING(crattem.nrdocmto)       FORMAT "x(20)"
                        DAY(crattem.dtmvtolt)          FORMAT "99"
                        MONTH(crattem.dtmvtolt)        FORMAT "99"
                        YEAR(crattem.dtmvtolt)         FORMAT "9999"
                        "BRL"
                        "000000000000000"
                        crattem.vllanmto * 100         FORMAT "999999999999999"
                        FILL(" ",20)      FORMAT "x(20)"
                        FILL(" ",8)       FORMAT "x(08)"
                        "000000000000000"
                        FILL(" ",52)      FORMAT "x(52)"
                        "0"
                        "0000000000"      SKIP.
 
       ASSIGN aux_qtdoclot = aux_qtdoclot + 1
              aux_qtregarq = aux_qtregarq + 1.

       PUT STREAM str_1 "001"
                        crattem.nrdolote               FORMAT "9999"
                        "3"
                        aux_qtdoclot                   FORMAT "99999"
                        "B   "
                        crattem.tppessoa               FORMAT "9"
                        crattem.nrcpfcgc               FORMAT "99999999999999"
                        FILL(" ",30)                   FORMAT "x(30)"
                        "00000"                        FORMAT "99999"
                        FILL(" ",50)                   FORMAT "x(50)"
                        "00000"                        FORMAT "99999"
                        "     "                        FORMAT "x(05)"
                        "00000000"                     FORMAT "99999999"
                        "000000000000000"              FORMAT "999999999999999"
                        "000000000000000"              FORMAT "999999999999999"
                        "000000000000000"              FORMAT "999999999999999"
                        "000000000000000"              FORMAT "999999999999999"
                        "000000000000000"              FORMAT "999999999999999"
                        FILL(" ",30)                   FORMAT "x(30)" SKIP.  
                                                 
       IF   LAST-OF(crattem.nrdolote) THEN
            DO:
                /*   Trailer do Lote   */
                PUT STREAM str_1 
                           "001"
                           crattem.nrdolote          FORMAT "9999"
                           "5         "
                           (aux_qtdoclot + 2)        FORMAT "999999"
                           (aux_vltotlot * 100)      FORMAT "999999999999999999"
                           "000000000000000000000000"
                           FILL(" ",165)             FORMAT "x(165)"
                           "0000000000"
                           SKIP.
            END.
            
       IF   LAST-OF(crattem.cdseqarq) THEN
            DO:
                aux_qtlinarq = aux_qtregarq + (crattem.nrdolote * 2) + 2.
                
                /*   Trailer do Arquivo   */
                
                PUT STREAM str_1 "00199999         "
                                 crattem.nrdolote    FORMAT "999999"
                                 aux_qtlinarq        FORMAT "999999"
                                 "000000"
                                 FILL(" ",205)       FORMAT "x(205)" 
                                 SKIP.
                
                OUTPUT STREAM str_1 CLOSE.
                                        
                UNIX SILENT VALUE("ux2dos " + aux_dscooper + "arq/" + aux_nmarquiv + 
                                  " > /micros/" + crapcop.dsdircop + 
                                "/compel/" + aux_nmarquiv + " 2>/dev/null").
                                              
                UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarquiv +
                                  " /usr/coop/" + crapcop.dsdircop +
                                  "/salvar 2>/dev/null").
                                                            
            END.
       
   END.  /*  Fim do FOR EACH -- crattem  */

   DO TRANSACTION ON ENDKEY UNDO, LEAVE:
      
      /*   Atualiza a sequencia da remessa  */
               
      DO aux_contador = 1 TO 10:

         FIND craptab WHERE craptab.cdcooper = p-cdcooper    AND
                            craptab.nmsistem = "CRED"        AND
                            craptab.tptabela = "CONFIG"      AND
                            craptab.cdempres = 00            AND
                            craptab.cdacesso = "COMPELBBDC"  AND
                            craptab.tpregist = 000
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craptab   THEN
              IF   LOCKED craptab   THEN
                   DO:
                       par_dscritic = 
                              "077 - Tabela sendo alterada p/ outro terminal.".
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO:
                       par_dscritic = "055 - Tabela nao cadastrada.".
                       RETURN "NOK".
                   END.    
         ELSE
              par_dscritic = "".
         
         LEAVE.

      END.  /*  Fim do DO .. TO  */

      IF   par_dscritic <> "" THEN
           RETURN "NOK".

      craptab.dstextab = SUBSTR(craptab.dstextab,1,20) + " " +
                         STRING(aux_cdsequen,"999999") + " " +
                         STRING(aux_cdseqarq,"999999").
                        
   END. /* TRANSACTION */

END PROCEDURE.
/*............................................................................*/

PROCEDURE gerar_arquivos_cecred:

   DEF INPUT  PARAM par_nmprgexe AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdageini AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdagefim AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_nrdolote AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_nrdcaixa AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdbccxlt AS CHAR                              NO-UNDO.
   
   DEF OUTPUT PARAM ret_cdcritic AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_qtarquiv AS INT                               NO-UNDO. 
   DEF OUTPUT PARAM ret_totregis AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_vlrtotal AS DEC                               NO-UNDO.

   ASSIGN aux_nmdatela = par_nmdatela
          aux_nmprgexe = par_nmprgexe
          aux_dtmvtolt = par_dtmvtolt
          aux_nmarqlog = "/usr/coop/cecred/log/prcctl_" +
                         STRING(YEAR(par_dtmvtolt),"9999") +
                         STRING(MONTH(par_dtmvtolt),"99") +
                         STRING(DAY(par_dtmvtolt),"99") + ".log".

   IF  par_nmprgexe = "COMPEL" THEN
       /* bloquear resgate de cheque durante envio para ABBC */
       RUN bloquear-resgate-cheque (INPUT par_cdcooper,
                                    INPUT "S").
   CASE par_nmprgexe:
        WHEN "COMPEL" THEN DO:
            IF   par_nmdatela = "PRCCTL" THEN
                 RUN gerar_compel_prcctl(INPUT  par_dtmvtolt,
                                         INPUT  par_cdcooper,
                                         INPUT  par_cdageini,
                                         INPUT  par_cdagefim,
                                         INPUT  par_cdoperad,
                                         INPUT  par_nmdatela,
                                         INPUT  par_nrdolote,  
                                         INPUT  par_cdbccxlt,
                                         OUTPUT ret_cdcritic,
                                         OUTPUT ret_qtarquiv,
                                         OUTPUT ret_totregis,
                                         OUTPUT ret_vlrtotal).
            ELSE
            IF   par_nmdatela = "COMPEL_DSC"  THEN
                 RUN gerar_compel_dscchq(INPUT  par_dtmvtolt,
                                         INPUT  par_cdcooper,
                                         INPUT  par_cdageini,
                                         INPUT  par_cdoperad,
                                         INPUT  par_nmdatela,
                                         INPUT  par_nrdcaixa,
                                         INPUT  par_cdbccxlt,
                                         INPUT  par_nrdolote,
                                         OUTPUT ret_cdcritic,
                                         OUTPUT ret_qtarquiv,
                                         OUTPUT ret_totregis,
                                         OUTPUT ret_vlrtotal).
            ELSE
            IF   par_nmdatela = "COMPEL_CST"  THEN
                 RUN gerar_compel_custodia(INPUT  par_dtmvtolt,
                                           INPUT  par_cdcooper,
                                           INPUT  par_cdageini,
                                           INPUT  par_cdoperad,
                                           INPUT  par_nmdatela,
                                           INPUT  par_nrdcaixa,
                                           INPUT  par_cdbccxlt,
                                           INPUT  par_nrdolote,
                                           OUTPUT ret_cdcritic,
                                           OUTPUT ret_qtarquiv,
                                           OUTPUT ret_totregis,
                                           OUTPUT ret_vlrtotal).
            ELSE
                 RUN gerar_compel(INPUT  par_dtmvtolt,
                                  INPUT  par_cdcooper,
                                  INPUT  par_cdageini,
                                  INPUT  par_cdoperad,
                                  INPUT  par_nmdatela,
                                  INPUT  par_nrdcaixa,
                                  INPUT  par_cdbccxlt,
                                  OUTPUT ret_cdcritic,
                                  OUTPUT ret_qtarquiv,
                                  OUTPUT ret_totregis,
                                  OUTPUT ret_vlrtotal).
        END.
        WHEN "DIGITA" THEN
            RUN gerar_digita(INPUT  par_dtmvtolt,
                             INPUT  par_cdcooper,
                             INPUT  par_cdageini,
                             INPUT  par_cdoperad,
                             INPUT  par_nmdatela,
                             INPUT  par_nrdcaixa,
                             INPUT  par_cdbccxlt,
                             OUTPUT ret_cdcritic,
                             OUTPUT ret_qtarquiv,
                             OUTPUT ret_totregis,
                             OUTPUT ret_vlrtotal).
        WHEN "DOCTOS" THEN
            RUN gerar_doctos(INPUT  par_dtmvtolt,
                             INPUT  par_cdcooper,
                             INPUT  par_cdageini,
                             INPUT  par_cdagefim,
                             INPUT  par_cdoperad,
                             OUTPUT ret_cdcritic,
                             OUTPUT ret_qtarquiv,
                             OUTPUT ret_totregis).
        
        WHEN "TITULO" THEN
            RUN gerar_titulo(INPUT  par_dtmvtolt,
                             INPUT  par_cdcooper,
                             INPUT  par_cdageini,
                             INPUT  par_cdagefim,
                             INPUT  par_cdoperad,
                             OUTPUT ret_cdcritic,
                             OUTPUT ret_qtarquiv,
                             OUTPUT ret_totregis).
        WHEN "TIC" THEN
            RUN gerar_tic604(INPUT  par_dtmvtolt,
                             INPUT  par_cdcooper,
                             INPUT  par_cdageini,
                             INPUT  par_cdagefim,
                             INPUT  par_cdoperad,
                             OUTPUT ret_cdcritic,
                             OUTPUT ret_qtarquiv,
                             OUTPUT ret_totregis).

   END CASE.

   IF  par_nmprgexe = "COMPEL" THEN
       /* desbloquear resgate de cheque após envio para ABBC */
       RUN bloquear-resgate-cheque (INPUT par_cdcooper,
                                    INPUT "N").
   
   IF   ret_cdcritic <> 0 THEN
        RETURN "NOK".
   ELSE
        RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE gerar_doctos:

   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdageini AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdagefim AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
  
   DEF OUTPUT PARAM ret_cdcritic AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_qtarquiv AS INT                               NO-UNDO. 
   DEF OUTPUT PARAM ret_totregis AS INT                               NO-UNDO.

   DEF VAR aux_mes      AS CHAR                                       NO-UNDO.
   DEF VAR glb_nrcalcul AS DEC                                        NO-UNDO.
   DEF VAR glb_dsdctitg AS CHAR                                       NO-UNDO.
   DEF VAR glb_stsnrcal AS LOGICAL                                    NO-UNDO.
   DEF VAR aux_flgerror AS LOGICAL                                    NO-UNDO.

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcop THEN
        DO:
            ret_cdcritic = 651.
            RUN fontes/critic.p.
            RETURN.
        END.

   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

   /* Remove os arquivos temporarios */
   UNIX SILENT VALUE("rm " + aux_dscooper + "arq/3*.* 2>/dev/null").

   /* Contadores de arquivo e registros */
   ASSIGN ret_qtarquiv = 0
          ret_totregis = 0.

    FOR EACH craptvl WHERE craptvl.cdcooper  = par_cdcooper    AND
                          craptvl.dtmvtolt  = par_dtmvtolt    AND
                          craptvl.flgenvio  = FALSE           AND
                          craptvl.tpdoctrf <> 3               AND
                          craptvl.cdagenci >= par_cdageini    AND
                          craptvl.cdagenci <= par_cdagefim,   
       EACH crapage WHERE crapage.cdcooper = craptvl.cdcooper AND
                          crapage.cdagenci = craptvl.cdagenci AND
                          crapage.cdbandoc = crapcop.cdbcoctl NO-LOCK
                          BREAK BY craptvl.cdagenci
                                BY craptvl.cdbccrcb :

       IF   FIRST-OF(craptvl.cdagenci)  THEN
            DO:
                ASSIGN aux_qtregarq = 0
                       aux_vltotarq = 0
                       aux_cdsequen = 1
                       aux_hrarquiv = SUBSTR(STRING(TIME,"HH:MM:SS"),1,2) +
                                      SUBSTR(STRING(TIME,"HH:MM:SS"),4,2) 
                       ret_qtarquiv = ret_qtarquiv + 1.

                /* Nome Arquivo definido por ABBC 3agenMDD.Nxx         */
                /* 3    - Fixo
                   agen - Cod Agen Central crapcop.cdagectl
                   M    - Mes Movim.(1-9 = Jan-Set) O=Out N=Nov D=Dez
                   xxx   - Numero do PAC                               */
                
                IF   MONTH(craptvl.dtmvtolt) > 9 THEN
                     CASE MONTH(craptvl.dtmvtolt):
                          WHEN 10 THEN aux_mes = "O".
                          WHEN 11 THEN aux_mes = "N".
                          WHEN 12 THEN aux_mes = "D".
                     END CASE.
                ELSE aux_mes = STRING(MONTH(craptvl.dtmvtolt),"9").    
                
                aux_nmarquiv = "3"                                +
                               STRING(crapcop.cdagectl,"9999")    +
                               aux_mes                            + 
                               STRING(DAY(craptvl.dtmvtolt),"99") +
                               "."                                +
                               STRING(craptvl.cdagenci, "999").

                IF   SEARCH(aux_dscooper + "arq/" + aux_nmarquiv) <> ?   THEN
                     DO:
                         BELL.
                         HIDE MESSAGE NO-PAUSE.
                         ret_cdcritic = 459.
                         RETURN "NOK".
                     END.

                OUTPUT STREAM str_1 TO VALUE(aux_dscooper + "arq/" +
                                             aux_nmarquiv).

                /* Header do Arquivo */
                PUT STREAM str_1
                           FILL("0",20)        FORMAT "x(20)"
                           "DCR605"            FORMAT "x(6)"
                           crapcop.cdbcoctl    FORMAT "999"
                           crapcop.nrdivctl    FORMAT "9"
                           YEAR(par_dtmvtolt)  FORMAT "9999"
                           MONTH(par_dtmvtolt) FORMAT "99"
                           DAY(par_dtmvtolt)   FORMAT "99"
                           "018"
                           "1"                 FORMAT "x(1)"
                           crapage.cdcomchq    FORMAT "999"
                           "0001"              FORMAT "x(4)"
                           YEAR(TODAY)         FORMAT "9999"
                           MONTH(TODAY)        FORMAT "99"
                           DAY(TODAY)          FORMAT "99"
                           aux_hrarquiv        FORMAT "9999"
                           FILL(" ",8)         FORMAT "x(8)"
                           " "                 FORMAT "x(1)"
                           FILL(" ",177)       FORMAT "x(177)"
                           aux_cdsequen        FORMAT "99999999"
                           SKIP.
            END.
   
       /* iniciar variavel de controle de erros*/
       ASSIGN aux_flgerror = FALSE.

       FIND crapagb WHERE crapagb.cdageban = craptvl.cdagercb AND
                          crapagb.cddbanco = craptvl.cdbccrcb NO-LOCK NO-ERROR.
                          
       IF  NOT AVAILABLE crapagb THEN DO:

           IF aux_nmdatela = "PRCCTL" THEN
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                  " - Coop:" + STRING(par_cdcooper,"99") +
                                  " - Processar:" + aux_nmprgexe +
                                  " Ref: " + STRING(par_dtmvtolt,"99/99/9999") +
                                  " DOC " + STRING(craptvl.nrdocmto) + " - " +
                                  " Agencia destino nao cadastrada: " +
                                  STRING(craptvl.cdagercb,"zzz9") + " Banco: " +
                                  STRING(craptvl.cdbccrcb,"zzz9") +
                                  " >> " + aux_nmarqlog).
           ELSE 
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                  " Ref: " + STRING(par_dtmvtolt,"99/99/9999") +
                                  " DOC " + STRING(craptvl.nrdocmto) + " - " +
                                  " Agencia destino nao cadastrada: " +
                                  STRING(craptvl.cdagercb,"zzz9") + " Banco: " +
                                  STRING(craptvl.cdbccrcb,"zzz9") +
                                  " >> " + aux_dscooper + "log/doctos.log").
           /* sinalizar que encontrou erros*/
           ASSIGN aux_flgerror = TRUE.
       END.
        
       /* Apenas gerar linha se não gerou erro*/
       IF aux_flgerror = FALSE THEN
       DO:
       
           ASSIGN aux_cdsequen = aux_cdsequen + 1
                  aux_tpdoctrf = IF   craptvl.tpdoctrf = 1 THEN
                                      "4"
                                 ELSE "5"
                  glb_nrcalcul = craptvl.cdagercb * 10.
                  
           RUN fontes/digbbx.p(INPUT  glb_nrcalcul,
                               OUTPUT glb_dsdctitg,
                               OUTPUT glb_stsnrcal).
         
           ASSIGN aux_digitage = SUBSTR(glb_dsdctitg,8,1)
                  aux_qtregarq = aux_qtregarq + 1
                  ret_totregis = ret_totregis + 1
                  aux_vltotarq = aux_vltotarq + craptvl.vldocrcb
                  aux_vltotdoc = aux_vltotdoc + craptvl.vldocrcb.  
                        
           IF   aux_digitage = "X" THEN
                aux_digitage = "0".
           
           ASSIGN aux_nmpesrcb = craptvl.nmpesrcb
                  aux_cpfcgrcb = craptvl.cpfcgrcb
                  aux_nmpesemi = craptvl.nmpesemi
                  aux_cpfcgemi = craptvl.cpfcgemi.
    
           
           IF   craptvl.tpdoctrf = 1 THEN   /* DOC C */
                DO:
                    IF   craptvl.cpfcgrcb = craptvl.cpfcgemi AND
                         craptvl.cpfsgemi > 0                THEN
                         ASSIGN aux_nmpesemi = REPLACE(craptvl.nmsegemi,"E/OU","") 
                                aux_cpfcgemi = craptvl.cpfsgemi.
                END.
               
               
           /* Detalhe do Arquivo */
           PUT STREAM str_1
               "018"
               craptvl.cdbccrcb                     FORMAT "999"
               craptvl.cdagercb                     FORMAT "9999"
               aux_digitage                         FORMAT "x(1)"
               craptvl.nrcctrcb                     FORMAT "9999999999999"
               craptvl.nrdocmto                     FORMAT "999999"
               craptvl.vldocrcb * 100               FORMAT "999999999999999999"
               aux_nmpesrcb                         FORMAT "x(40)"
               aux_cpfcgrcb                         FORMAT "99999999999999"
               IF   craptvl.tpdctacr = 0 THEN 
                    STRING("01","99")               
               ELSE STRING(craptvl.tpdctacr,"99")   FORMAT "99"
               craptvl.cdfinrcb                     FORMAT "99"
               FILL(" ",11)                         FORMAT "x(11)"
               "018"
               crapcop.cdbcoctl                     FORMAT "999"
               crapcop.cdagectl                     FORMAT "9999"
               string(crapcop.nrdivctl)             FORMAT "x(1)" /* DV (?) */
               craptvl.nrdconta                     FORMAT "9999999999999"
               aux_nmpesemi                         FORMAT "x(40)"
               aux_cpfcgemi                         FORMAT "99999999999999"
               IF   craptvl.tpdctadb = 0 THEN 
                    STRING("01","99") 
               ELSE STRING(craptvl.tpdctadb,"99")   FORMAT "99"
               "SC"                                 FORMAT "x(2)"
               FILL(" ",3)                          FORMAT "x(3)"
               aux_tpdoctrf                         FORMAT "9"
               FILL(" ",5)                          FORMAT "x(5)"
               aux_qtregarq                         FORMAT "999999"
               YEAR(par_dtmvtolt)                   FORMAT "9999"
               MONTH(par_dtmvtolt)                  FORMAT "99"
               DAY(par_dtmvtolt)                    FORMAT "99"
               crapage.cdcomchq                     FORMAT "999"
               "0001"                               FORMAT "x(4)"
               "000000000"                          FORMAT "x(9)"
               "00"                                 FORMAT "x(2)"
               "045"                                FORMAT "x(3)"
               FILL(" ",4)                          FORMAT "x(4)"
               aux_cdsequen                         FORMAT "99999999"
               SKIP.                  
       
           /* CRIACAO DA TABELA GENERICA - GNCPDOC */
           CREATE gncpdoc.
           ASSIGN gncpdoc.cdcooper = par_cdcooper
                  gncpdoc.cdagenci = craptvl.cdagenci
                  gncpdoc.dtmvtolt = par_dtmvtolt
                  gncpdoc.cdcmpchq = crapage.cdcomchq
                  gncpdoc.cdbccrcb = craptvl.cdbccrcb
                  gncpdoc.cdagercb = craptvl.cdagercb
                  gncpdoc.dvagenci = aux_digitage
                  gncpdoc.nrcctrcb = craptvl.nrcctrcb
                  gncpdoc.nrdocmto = craptvl.nrdocmto
                  gncpdoc.vldocmto = craptvl.vldocrcb
                  gncpdoc.nmpesrcb = aux_nmpesrcb
                  gncpdoc.cpfcgrcb = aux_cpfcgrcb
                  gncpdoc.tpdctacr = craptvl.tpdctacr
                  gncpdoc.cdfinrcb = craptvl.cdfinrcb
                  gncpdoc.cdagectl = crapcop.cdagectl
                  gncpdoc.nrdconta = craptvl.nrdconta
                  gncpdoc.nmpesemi = aux_nmpesemi
                  gncpdoc.cpfcgemi = aux_cpfcgemi
                  gncpdoc.tpdctadb = craptvl.tpdctadb
                  gncpdoc.tpdoctrf = aux_tpdoctrf
                  gncpdoc.qtdregen = aux_qtregarq
                  gncpdoc.nmarquiv = aux_nmarquiv
                  gncpdoc.cdoperad = par_cdoperad
                  gncpdoc.hrtransa = TIME
                  gncpdoc.cdtipreg = 1
                  gncpdoc.flgconci = NO
                  gncpdoc.nrseqarq = aux_cdsequen
                  gncpdoc.cdcritic = 0
                  gncpdoc.cdmotdev = 0
                  gncpdoc.flgpcctl = NO.
           VALIDATE gncpdoc.
    
           /* Atualiza campo cdbcoenv da TVL - Inicio */
           
           DO aux_contador2 = 1 TO 10:
           
              FIND crabtvl WHERE RECID(crabtvl) = RECID(craptvl) 
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                   IF NOT AVAILABLE crabtvl   THEN
                      IF LOCKED crabtvl THEN
                         DO:
                            ret_cdcritic = 077.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                         END.
                      ELSE
                         DO:
                            ret_cdcritic = 055.
                            RETURN "NOK".
                         END.    
    
              ASSIGN crabtvl.cdbcoenv = crapcop.cdbcoctl
                     crabtvl.flgenvio = TRUE
                     ret_cdcritic = 0.
           
              RELEASE crabtvl.
              LEAVE.
    
           END. /* fim do contador */
    
           IF   ret_cdcritic <> 0   THEN
                RETURN "NOK".
       END. /* fim IF aux_flgerror */

       /* finalizar arquivo se for o ultimo registro da agencia
          e o arquivo possui uma linha*/
       IF   LAST-OF(craptvl.cdagenci) AND
            aux_qtregarq > 0 THEN 

            DO:
                ASSIGN aux_cdsequen = aux_cdsequen + 1.
                
                /* Trailer do Arquivo */
                PUT STREAM str_1 
                           FILL("9",20)        FORMAT "x(20)"
                           "DCR605"
                           crapcop.cdbcoctl    FORMAT "999" /*aqui*/ 
                           crapcop.nrdivctl    FORMAT "9"
                           YEAR(par_dtmvtolt)  FORMAT "9999"
                           MONTH(par_dtmvtolt) FORMAT "99"
                           DAY(par_dtmvtolt)   FORMAT "99"
                           "018"
                           "1"                 FORMAT "x(1)"
                           crapage.cdcomchq    FORMAT "999"
                           "0001"              FORMAT "x(4)"
                           YEAR(TODAY)         FORMAT "9999"
                           MONTH(TODAY)        FORMAT "99"
                           DAY(TODAY)          FORMAT "99"
                           aux_hrarquiv        FORMAT "9999"
                           FILL(" ",8)         FORMAT "x(8)"
                           " "                 FORMAT "x(1)"
                           aux_qtregarq        FORMAT "99999999"
                           aux_vltotarq * 100  FORMAT "999999999999999999"
                           FILL(" ",151)       FORMAT "x(151)"
                           aux_cdsequen        FORMAT "99999999"
                           SKIP.
                                                      
                OUTPUT STREAM str_1 CLOSE.

                /* Copia para o /micros */
                UNIX SILENT VALUE("ux2dos " + aux_dscooper + "arq/" + aux_nmarquiv + 
                                  ' | tr -d "\032"' + 
                                  " > /micros/" + crapcop.dsdircop +
                                  "/abbc/" + aux_nmarquiv + " 2>/dev/null").

                /* move para o salvar */
                UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarquiv + " " +
                                   aux_dscooper + "salvar/" + aux_nmarquiv + "_" +
                                   STRING(TIME,"99999") + " 2>/dev/null").

                RUN pi_alterar_situacao_arquivos (INPUT  craptvl.cdcooper,
                                                  INPUT  craptvl.cdagenci,
                                                  INPUT  "DOCTOS",
                                                  INPUT  1,
                                                  INPUT  0,
                                                  OUTPUT ret_cdcritic).
       END.

       HIDE MESSAGE NO-PAUSE.

   END. /* Fim do FOR EACH */
   
   IF aux_nmdatela = "PRCCTL" THEN
      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                        " - Coop:" + STRING(par_cdcooper,"99") +
                        " - Processar:" + aux_nmprgexe +
                        " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                        " - Valor total: " + 
                        STRING(aux_vltotdoc,"zzz,zzz,zz9.99") +
                        " - Qtd. arquivos: " + STRING(ret_qtarquiv, "zzz9") +
                        " >> " + aux_nmarqlog).
   ELSE
      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                        " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                        " - Valor total: " + 
                        STRING(aux_vltotdoc,"zzz,zzz,zz9.99") +
                        " - Qtd. arquivos: " + STRING(ret_qtarquiv, "zzz9") +
                        " >> " + aux_dscooper + "log/doctos.log").
   
/*    END. /* Fim da TRANSACTION */ */

END PROCEDURE.

/*............................................................................*/

PROCEDURE gerar_titulo:

   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdageini AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdagefim AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
   
   DEF OUTPUT PARAM ret_cdcritic AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_qtarquiv AS INT                               NO-UNDO. 
   DEF OUTPUT PARAM ret_totregis AS INT                               NO-UNDO.

   DEF VAR aux_mes      AS CHAR                                       NO-UNDO.
   DEF VAR glb_nrcalcul AS DEC                                        NO-UNDO.
   DEF VAR glb_dsdctitg AS CHAR                                       NO-UNDO.
   DEF VAR glb_stsnrcal AS LOGICAL                                    NO-UNDO.
   DEF VAR aux_nrseqarq AS INT                                        NO-UNDO.
   DEF VAR aux_nrsqarhd AS INT    /* nr seq arq aux */  INIT 1        NO-UNDO.
   DEF VAR aux_nrdolote AS INTE                                       NO-UNDO.
   DEF VAR aux_nrseqdig AS INTE                                       NO-UNDO.
   DEF VAR aux_tpcaptur AS INTE                                       NO-UNDO.
   DEF VAR aux_tpdocmto AS CHAR                                       NO-UNDO.
   DEF VAR aux_cdfatven AS DEC                                        NO-UNDO.
   DEF VAR aux_cdsituac AS INT                                        NO-UNDO.
   DEF VAR aux_nrdahora AS INT                                        NO-UNDO.
   DEF VAR aux_nrispbif_rem AS INT                                    NO-UNDO.
   DEF VAR aux_nrispbif AS INT                                        NO-UNDO.   
   
   DEF VAR vr_cdagenci  AS INT                                        NO-UNDO.
   DEF BUFFER crabage   FOR crapage.
   

   ASSIGN aux_qttitcxa = 0
          aux_qttitprg = 0
          aux_vltitcxa = 0
          aux_vltitprg = 0.

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                      NO-LOCK NO-ERROR.

   IF NOT AVAILABLE crapcop THEN
      DO:
          ret_cdcritic = 651.
          RUN fontes/critic.p.
          RETURN.

      END.

   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

   /* Remove os arquivos temporarios */
   UNIX SILENT VALUE("rm " + aux_dscooper + "arq/2*.* 2>/dev/null").

   FOR EACH craptit WHERE (craptit.cdcooper = par_cdcooper       AND
                          craptit.dtdpagto  = par_dtmvtolt       AND
                          CAN-DO("0,2,4",STRING(craptit.insittit)) AND
                          craptit.tpdocmto  = 20                 AND
                          (((craptit.cdagenci >= par_cdageini    AND
                          craptit.cdagenci <= par_cdagefim)      AND
                          craptit.cdagenci <> 90                 AND
                          craptit.cdagenci <> 91)                OR
                         (craptit.cdagenci  = 90                 AND
                          par_cdageini      = 90)                OR
                         (craptit.cdagenci  = 91                 AND
                          par_cdageini      = 91))               AND
                          craptit.intitcop  = 0                  AND
                          craptit.flgenvio  = NO)                
                          NO-LOCK,
       EACH crapage WHERE crapage.cdcooper = craptit.cdcooper AND
                          crapage.cdagenci = craptit.cdagenci AND
                          crapage.cdbantit = crapcop.cdbcoctl
                          NO-LOCK BREAK BY craptit.cdagenci
                                         BY craptit.cdbccxlt 
                                          BY craptit.nrdolote: 

       IF FIRST-OF(craptit.cdagenci) THEN
          DO:
              ASSIGN aux_vltotarq = 0 
                     aux_qtregarq = 0
                     aux_nrseqarq = 1
                     aux_nrsqarhd = aux_nrsqarhd + 1
                     ret_qtarquiv = ret_qtarquiv + 1.

              /* Nome Arquivo definido por ABBC 2agenMDD.Nxx         */
              /* 2    - Fixo
                 agen - Cod Agen Central crapcop.cdagectl
                 M    - Mes Movim.(1-9 = Jan-Set) O=Out N=Nov D=Dez
                 xxx   - Numero do PAC                               */
             
              IF MONTH(craptit.dtmvtolt) > 9 THEN
                 CASE MONTH(craptit.dtmvtolt):

                      WHEN 10 THEN aux_mes = "O".
                      WHEN 11 THEN aux_mes = "N".
                      WHEN 12 THEN aux_mes = "D".

                 END CASE.
              ELSE 
                 aux_mes = STRING(MONTH(craptit.dtmvtolt),"9").

              IF craptit.cdagenci = 90 OR
                 craptit.cdagenci = 91 THEN
                 aux_nmarquiv = "8"                                +
                                STRING(crapcop.cdagectl,"9999")    +
                                aux_mes                            +
                                STRING(DAY(craptit.dtmvtolt),"99") +
                                "."                                +
                                STRING(craptit.cdagenci, "999").
              ELSE
                 aux_nmarquiv = "2"                                +
                                STRING(crapcop.cdagectl,"9999")    +
                                aux_mes                            +
                                STRING(DAY(craptit.dtmvtolt),"99") +
                                "."                                +
                                STRING(craptit.cdagenci, "999").
 

              IF SEARCH(aux_dscooper + "arq/" + aux_nmarquiv) <> ? THEN
                 DO:
                     BELL.
                     HIDE MESSAGE NO-PAUSE.
                     MESSAGE "Arquivo ja existe: " + aux_dscooper 
                             + "arq/" aux_nmarquiv.
                     ret_cdcritic = 459.
                     RETURN.

                 END.
              
              /* Buscar ISPB do banco */
              FIND FIRST crapban 
                   WHERE crapban.cdbccxlt = crapcop.cdbcoctl
                   NO-LOCK NO-ERROR .
              
              IF AVAILABLE crapban THEN
                DO:
                  ASSIGN aux_nrispbif_rem = crapban.nrispbif.
                END.              
                   
              
              OUTPUT STREAM str_1 TO VALUE(aux_dscooper + "arq/" + 
                                           aux_nmarquiv).
          
              PUT STREAM str_1
                  FILL("0",47)         FORMAT "x(47)"      /* CONTROLE DO HEADER */
                  "COB605"                                 /* NOME   */
                  "0000001 "           FORMAT "x(7)"       /* VERSAO */
                  FILL(" ",4)          FORMAT "x(4)"       /* FILLER */
                  "3"                                      /* Ind. Remes */
                  YEAR(par_dtmvtolt)   FORMAT "9999"       /* DATA FORMATO */
                  MONTH(par_dtmvtolt)  FORMAT "99"         /* YYYYMMDD*/
                  DAY(par_dtmvtolt)    FORMAT "99"
                  FILL(" ",58)         FORMAT "x(58)"      /* FILLER */
                  aux_nrispbif_rem     FORMAT "99999999"   /* ISPB Remetente*/  
                  FILL(" ",11)         FORMAT "x(11)"      /* FILLER */
                  aux_nrseqarq         FORMAT "9999999999" /* SEQUENCIAL 1 */
                  SKIP.
                  
                  /* Layout antigo
                  FILL("0",47)         FORMAT "x(47)" /* CONTROLE DO HEADER */
                  "COB605"                             /* NOME   */
                  crapage.cdcomchq     FORMAT "999"    /* COMPE  */
                  "0001"                               /* VERSAO */
                  crapcop.cdbcoctl     FORMAT "999"    /* BANCO  */
                  crapcop.nrdivctl     FORMAT "9"      /* DV     */
                  "3"                                  /* Ind. Remes */
                  YEAR(par_dtmvtolt)   FORMAT "9999"   /* DATA FORMATO */
                  MONTH(par_dtmvtolt)  FORMAT "99"     /* YYYYMMDD*/
                  DAY(par_dtmvtolt)    FORMAT "99"
                  FILL(" ",77)         FORMAT "x(77)"  /* FILLER */
                  aux_nrseqarq         FORMAT "9999999999"  /* SEQUENCIAL 1 */
                  SKIP.
                  */
                  

          END.

       IF FIRST-OF(craptit.nrdolote)  THEN
          ASSIGN aux_nrdolote = craptit.nrdolote
                 aux_nrseqdig = 1.

       /* Atualiza campo cdbcoenv da TIT - Inicio */
       
       DO aux_contador2 = 1 TO 10:
           
           FIND crabtit WHERE RECID(crabtit) = RECID(craptit) 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE crabtit THEN
              IF LOCKED crabtit THEN
                 DO:
                    ret_cdcritic = 077.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                 END.
              ELSE
                 DO:
                    ret_cdcritic = 055.
                    RETURN "NOK".
                 END.   
           
           ASSIGN crabtit.cdbcoenv = crapcop.cdbcoctl
                  crabtit.flgenvio = TRUE
                  ret_cdcritic = 0.

           RELEASE crabtit.
           LEAVE.

       END. /* fim do contador */
    
       IF   ret_cdcritic <> 0   THEN
            RETURN "NOK".

       /* Atualiza campo cdbcoenv da TIT - Fim */

       ASSIGN aux_nrseqarq = aux_nrseqarq + 1
              aux_qtregarq = aux_qtregarq + 1
              aux_vltotarq = aux_vltotarq + craptit.vldpagto.
                     
       IF CAN-DO("0,2", STRING(craptit.insittit)) THEN       /*  Titulo programado  */
          ASSIGN aux_qttitprg = aux_qttitprg + 1
                 aux_vltitprg = aux_vltitprg + craptit.vldpagto.
       ELSE
          ASSIGN aux_qttitcxa = aux_qttitcxa + 1
                 aux_vltitcxa = aux_vltitcxa + craptit.vldpagto.
                   
       /* Tipo de captura */       
       IF craptit.cdagenci = 90   THEN /* PAC INTERNET */
          aux_tpcaptur = 3. /* titulos liquidados via internet */
       ELSE
       IF craptit.cdagenci = 91   THEN  /* PAC TAA */
          aux_tpcaptur = 2. /* titulos liquidados via TAA */
       ELSE
          aux_tpcaptur = 1. /* titulos liquidados no caixa */
                
       ASSIGN aux_tpdocmto = "40".
    
       /* pagamento pelo canal DDA */
       IF  craptit.flgpgdda THEN 
           ASSIGN aux_tpdocmto = "1" + aux_tpdocmto.
       ELSE
           ASSIGN aux_tpdocmto = "0" + aux_tpdocmto.

       /* Fator Vencimento */
       ASSIGN aux_cdfatven = DECIMAL(SUBSTR(
                             STRING(craptit.dscodbar,"99999999999999"),6,4)).

       /* Buscar ISPB do banco */
       FIND FIRST crapban 
           WHERE crapban.cdbccxlt = craptit.cdbandst
           NO-LOCK NO-ERROR.
      
       IF AVAILABLE crapban THEN
         DO:
           ASSIGN aux_nrispbif = crapban.nrispbif.
         END.
       ELSE
         DO:
           ASSIGN aux_nrispbif = craptit.nrispbds.
         END.
       
       
       IF craptit.cdagenci = 90   OR   /* PAC INTERNET */
          craptit.cdagenci = 91   THEN /* PAC TAA       */
          PUT STREAM str_1
              SUBSTR(craptit.dscodbar,01,44) FORMAT "x(44)" /* Cod. Barras */
              aux_tpdocmto           FORMAT "x(2)"         /* Tip Docto */
              crapage.cdcomchq       FORMAT "999"           /* Filler */
              aux_tpcaptur           FORMAT "9"             /* Tipo de captura */ 
              " "                    FORMAT "x(6)"          /* Filler */    
              crapcop.cdagectl       FORMAT "9999"
              aux_nrdolote           FORMAT "9999999"       /* NUMERO LOTE */
              aux_nrseqdig           FORMAT "999"           /* SEQ NO LOTE */
              YEAR(par_dtmvtolt)     FORMAT "9999"          /* DATA FORMATO */
              MONTH(par_dtmvtolt)    FORMAT "99"            /* YYYYMMDD*/
              DAY(par_dtmvtolt)      FORMAT "99"
              "      "               FORMAT "x(6)"          /* CENTRO PROCES */
              craptit.vldpagto * 100 FORMAT "999999999999"  /* VALOR LIQ. */
              "0000001"              FORMAT "x(7)"          /* VERSAO */
              aux_nrsqarhd           FORMAT "9999999999"    /* SEQ. do arquivo troca */
              " "                    FORMAT "x(18)"         /* Filler */    
              aux_nrispbif_rem       FORMAT "99999999"      /* ISPB recebedor   */
              aux_nrispbif           FORMAT "99999999"      /* ISPB favorecido  */                          
              aux_tpdocmto           FORMAT "x(3)"              
              aux_nrseqarq           FORMAT "9999999999"
              SKIP.
              
          
              /* Layout antigo
              SUBSTR(craptit.dscodbar,01,44) FORMAT "x(44)" /* Cod. Barras */
              aux_tpdocmto           FORMAT "x(2)"         /* Tip Docto */
              crapage.cdcomchq       FORMAT "999"
              aux_tpcaptur           FORMAT "9"
              "00"                   FORMAT "x(2)"
              " "                    FORMAT "x(1)"
              crapcop.cdbcoctl       FORMAT "999"
              crapcop.cdagectl       FORMAT "9999"
              aux_nrdolote           FORMAT "9999999"  /* NUMERO LOTE */
              aux_nrseqdig           FORMAT "999"      /* SEQ NO LOTE */
              YEAR(par_dtmvtolt)     FORMAT "9999"     /* DATA FORMATO */
              MONTH(par_dtmvtolt)    FORMAT "99"       /* YYYYMMDD*/
              DAY(par_dtmvtolt)      FORMAT "99"
              "      "               FORMAT "x(6)"     /* CENTRO PROCES */
              craptit.vldpagto * 100 FORMAT "999999999999"   /* VALOR LIQ. */
              crapage.cdcomchq       FORMAT "999"      /* COMPE  */
              "0001"                 FORMAT "x(4)"     /* VERSAO */
              aux_nrsqarhd           FORMAT "9999999999"
              aux_tpdocmto           FORMAT "x(3)"
              FILL(" ",34)           FORMAT "x(34)"    /* FILLER */
              aux_nrseqarq           FORMAT "9999999999"
              SKIP.*/
       ELSE
          PUT STREAM str_1
              SUBSTR(craptit.dscodbar,01,44) FORMAT "x(44)" /* Cod. Barras */
              aux_tpdocmto           FORMAT "x(2)"          /* Tip Docto */
              crapage.cdcomchq       FORMAT "999"
              aux_tpcaptur           FORMAT "9"             /* Tipo de captura */ 
              " "                    FORMAT "x(6)"          /* Filler */    
              crapage.cdagepac       FORMAT "9999"          /* Agencia remetente */
              aux_nrdolote           FORMAT "9999999"       /* NUMERO LOTE */
              aux_nrseqdig           FORMAT "999"           /* SEQ NO LOTE */
              YEAR(par_dtmvtolt)     FORMAT "9999"          /* DATA FORMATO */
              MONTH(par_dtmvtolt)    FORMAT "99"            /* YYYYMMDD*/
              DAY(par_dtmvtolt)      FORMAT "99"
              "      "               FORMAT "x(6)"     /* CENTRO PROCES */
              craptit.vldpagto * 100 FORMAT "999999999999"   /* VALOR LIQ. */
              "0000001"              FORMAT "x(7)"       /* VERSAO */
              aux_nrsqarhd           FORMAT "9999999999" /* SEQ. do arquivo troca */
              " "                    FORMAT "x(18)"         /* Filler */    
              aux_nrispbif_rem       FORMAT "99999999"      /* ISPB recebedor   */
              aux_nrispbif           FORMAT "99999999"      /* ISPB favorecido  */                          
              aux_tpdocmto           FORMAT "x(3)"              
              aux_nrseqarq           FORMAT "9999999999"
              SKIP.
              
          
              /* Layout antigo
              craptit.cdbandst       FORMAT "999"      /* BANCO DESTINO */
              craptit.cddmoeda       FORMAT "9"        /* CODIGO MOEDA  */
              craptit.nrdvcdbr       FORMAT "9"        /* DIG. COD.BARRA */
              aux_cdfatven           FORMAT "9999"     /* Fator de venc. */
              craptit.vltitulo * 100 FORMAT "9999999999"    /* VALOR TITULO */
              SUBSTR(craptit.dscodbar,20,25) FORMAT "x(25)" /* CAMPO LIVRE */
              aux_tpdocmto           FORMAT "x(2)"     /* Tip Docto */
              crapage.cdcomchq       FORMAT "999"
              aux_tpcaptur           FORMAT "9"
              "00"                   FORMAT "x(2)"
              " "                    FORMAT "x(1)"
              crapcop.cdbcoctl       FORMAT "999"
              crapage.cdagepac       FORMAT "9999"
              aux_nrdolote           FORMAT "9999999"  /* NUMERO LOTE */
              aux_nrseqdig           FORMAT "999"      /* SEQ NO LOTE */
              YEAR(par_dtmvtolt)     FORMAT "9999"     /* DATA FORMATO */
              MONTH(par_dtmvtolt)    FORMAT "99"       /* YYYYMMDD*/
              DAY(par_dtmvtolt)      FORMAT "99"
              "      "               FORMAT "x(6)"     /* CENTRO PROCES */
              craptit.vldpagto * 100 FORMAT "999999999999"   /* VALOR LIQ. */
              crapage.cdcomchq       FORMAT "999"      /* COMPE  */
              "0001"                 FORMAT "x(4)"     /* VERSAO */
              aux_nrsqarhd           FORMAT "9999999999"
              FILL(" ",34)           FORMAT "x(34)"    /* FILLER */
              aux_tpdocmto           FORMAT "x(3)"
              aux_nrseqarq           FORMAT "9999999999"
              SKIP.*/
       
       /* Criacao da tabela Generica - GNCPTIT */
       CREATE gncptit.

       ASSIGN gncptit.cdcooper = par_cdcooper
              gncptit.cdagenci = craptit.cdagenci
              gncptit.dtmvtolt = par_dtmvtolt
              gncptit.cdbandst = craptit.cdbandst
              gncptit.cddmoeda = craptit.cddmoeda
              gncptit.nrdvcdbr = craptit.nrdvcdbr
              gncptit.dscodbar = craptit.dscodbar
              gncptit.tpcaptur = aux_tpcaptur
              gncptit.cdagectl = crapage.cdagepac
              gncptit.nrdolote = aux_nrdolote
              gncptit.nrseqdig = aux_nrseqdig
              gncptit.vldpagto = craptit.vldpagto
              gncptit.tpdocmto = INTEGER(aux_tpdocmto)
              gncptit.nrseqarq = aux_nrseqarq
              gncptit.nmarquiv = aux_nmarquiv
              gncptit.cdoperad = par_cdoperad
              gncptit.hrtransa = TIME
              gncptit.vltitulo = craptit.vltitulo
              gncptit.cdtipreg = 1
              gncptit.flgconci = NO
              gncptit.cdcritic = 0
              gncptit.cdmotdev = 0
              gncptit.flgpcctl = NO
              gncptit.cdfatven = aux_cdfatven
              gncptit.flgpgdda = craptit.flgpgdda.
       VALIDATE gncptit.

       ASSIGN aux_nrseqdig = aux_nrseqdig + 1.

       IF aux_nrseqdig > 999  THEN
          ASSIGN aux_nrseqdig = 1.

       IF LAST-OF(craptit.cdagenci) THEN
          DO:
              aux_nrseqarq = aux_nrseqarq + 1.
              ret_totregis = ret_totregis + aux_qtregarq.

              PUT STREAM str_1
                  FILL("9",47)         FORMAT "x(47)" /* Constante de 9 */
                  "COB605"                            /* Constante COB605 */
                  "0000001"                            /* VERSAO */
                  FILL(" ",4)          FORMAT "x(4)"   /* FILLER */
                  "3"                                  /* Ind. Remes */
                  YEAR(par_dtmvtolt)   FORMAT "9999"   /* DATA FORMATO */
                  MONTH(par_dtmvtolt)  FORMAT "99"     /* YYYYMMDD*/
                  DAY(par_dtmvtolt)    FORMAT "99"
                  aux_vltotarq * 100   FORMAT "99999999999999999" /* VL Arq */
                  FILL(" ",41)         FORMAT "x(41)"  /* FILLER */
                  aux_nrispbif_rem     FORMAT "99999999"   /* ISPB Remetente*/  
                  FILL(" ",11)         FORMAT "x(11)"  /* FILLER */
                  aux_nrseqarq         FORMAT "9999999999"  /* SEQUENCIA */
                  SKIP.
                  
                  
              /*  layout antigo
                  FILL("9",47)         FORMAT "x(47)" /* Constante de 9 */
                  "COB605"                            /* Constante COB605 */                                    
                  crapage.cdcomchq     FORMAT "999"   /* COMPE  */
                  "0001"                              /* VERSAO */
                  crapcop.cdbcoctl     FORMAT "999"    /* BANCO  */
                  crapcop.nrdivctl     FORMAT "9"      /* DV     */
                  "3"                                  /* Ind. Remes */
                  YEAR(par_dtmvtolt)   FORMAT "9999"   /* DATA FORMATO */
                  MONTH(par_dtmvtolt)  FORMAT "99"     /* YYYYMMDD*/
                  DAY(par_dtmvtolt)    FORMAT "99"
                  aux_vltotarq * 100   FORMAT "99999999999999999" /* VL Arq */
                  FILL(" ",60)         FORMAT "x(60)"  /* FILLER */
                  aux_nrseqarq         FORMAT "9999999999"  /* SEQUENCIA */
                  SKIP.*/

              OUTPUT STREAM str_1 CLOSE.

              
              /* Copia para o /micros */
              UNIX SILENT VALUE("ux2dos " + aux_dscooper + "arq/" + 
                                aux_nmarquiv + 
                                ' | tr -d "\032"' + 
                                " > /micros/" + crapcop.dsdircop +
                                "/abbc/" + aux_nmarquiv + " 2>/dev/null").

              /* move para o salvar */
              UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + 
                                 aux_nmarquiv + " " + 
                                 aux_dscooper + "salvar/" + aux_nmarquiv + 
                                 "_" + STRING(TIME,"99999") + " 2>/dev/null").
                

              RUN pi_alterar_situacao_arquivos (INPUT  craptit.cdcooper,
                                                INPUT  craptit.cdagenci,
                                                INPUT  "TITULO",
                                                INPUT  1,
                                                INPUT  0,
                                                OUTPUT ret_cdcritic).

              DO:

                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                     /* Efetuar a chamada a rotina Oracle  */
                     RUN STORED-PROCEDURE pc_checa_titulos
                         aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper 
                                                             ,INPUT aux_nmarquiv
                                                             ,INPUT crapcop.cdagectl
                                                             ,INPUT craptit.cdagenci
                                                             ,INPUT par_dtmvtolt
                                                             ,INPUT aux_qtregarq
                                                             ,INPUT aux_vltotarq
                                                             ,OUTPUT 0
                                                             ,OUTPUT "").

                     /* Fechar o procedimento para buscarmos o resultado */ 
                     CLOSE STORED-PROC pc_checa_titulos
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                     { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                    
                     ASSIGN aux_dscritic = ""
                            aux_dscritic = pc_checa_titulos.pr_dscritic
                                           WHEN pc_checa_titulos.pr_dscritic <> ?
                            aux_cdcritic = 0
                            aux_cdcritic = pc_checa_titulos.pr_cdcritic
                                           WHEN pc_checa_titulos.pr_cdcritic <> ?.

              END. /* execuçao comp0001.pc_checa_titulos*/

       END. /* last-of craptit.cdagenci*/

       HIDE MESSAGE NO-PAUSE.

   END.  /*  Fim do FOR EACH -- craptit  */

   IF ret_cdcritic > 0   THEN
      RETURN.

   /* gravar tabela */
   ASSIGN par_cdagefim = IF par_cdageini = 0 THEN 
                            9999
                         ELSE 
                            par_cdageini.
   
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   IF aux_nmdatela = "PRCCTL" THEN
      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                        " - Coop:" + STRING(par_cdcooper,"99") +
                        " - Processar:" + aux_nmprgexe +
                        " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                        " - Progr: " + STRING(aux_qttitprg,"zzz,zz9") +
                        " " + STRING(aux_vltitprg,"zzz,zzz,zz9.99") +
                        " >> " + aux_nmarqlog).
   ELSE
      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                        " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                        " - Caixa: " + 
                        STRING(aux_qttitcxa,"zzz,zz9") +
                        " " + STRING(aux_vltitcxa,"zzz,zzz,zz9.99") +
                        " - Progr: " + STRING(aux_qttitprg,"zzz,zz9") +
                        " " + STRING(aux_vltitprg,"zzz,zzz,zz9.99") +
                        " >> " + aux_dscooper + "log/titulos.log").

   END. /* TRANSACTION */

END PROCEDURE.

/*............................................................................*/

PROCEDURE gerar_compel:

   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdagenci AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_nrdcaixa AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdbccxlt AS CHAR                              NO-UNDO.
   DEF OUTPUT PARAM ret_cdcritic AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_qtarquiv AS INT                               NO-UNDO. 
   DEF OUTPUT PARAM ret_totregis AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_vlrtotal AS DEC                               NO-UNDO.

   DEF VAR          aux_mes      AS CHAR                              NO-UNDO.
   DEF VAR          glb_nrcalcul AS DEC                               NO-UNDO.
   DEF VAR          glb_dsdctitg AS CHAR                              NO-UNDO.
   DEF VAR          glb_stsnrcal AS LOGICAL                           NO-UNDO.
   DEF VAR          aux_flgerror AS LOGICAL                           NO-UNDO.
   DEF VAR          aux_nrseqarq AS INT                               NO-UNDO.
   DEF VAR          aux_nmarqdat AS CHAR   FORMAT "x(20)"             NO-UNDO.
   DEF VAR          aux_totqtchq AS INT                               NO-UNDO.
   DEF VAR          aux_totvlchq AS DECIMAL                           NO-UNDO.
   DEF VAR          aux_cdsituac AS INT                               NO-UNDO.
   DEF VAR          aux_nrdahora AS INT                               NO-UNDO.
   DEF VAR          aux_cdcomchq AS INT                               NO-UNDO.
   DEF VAR          aux_cdagedst LIKE crapchd.cdagedst                NO-UNDO.
   DEF VAR          aux_flgdepin AS LOGICAL                           NO-UNDO.
   DEF VAR          aux_nrdconta LIKE crapchd.nrdconta                NO-UNDO.

   DEF VAR          aux_nrprevia AS INT    INIT 0                     NO-UNDO.
   DEF VAR          aux_hrprevia AS INT    INIT 0                     NO-UNDO.
   DEF VAR          aux_exetrunc AS LOGI   INIT NO                    NO-UNDO.
   DEF VAR          aux_dschqctl AS CHAR                              NO-UNDO.
   DEF VAR          aux_nrdlote1 AS INT                               NO-UNDO.
   DEF VAR          aux_nrdlote2 AS INT                               NO-UNDO.
   DEF VAR          aux_nrdlote3 AS INT                               NO-UNDO.
   
   DEF VAR          aux_nrctachq AS CHAR   FORMAT "x(12)"             NO-UNDO.

   DEF VAR          aux_cdcopant AS INTE                              NO-UNDO.

   DEF BUFFER crabage FOR crapage.
   DEF BUFFER b-gncpchq FOR gncpchq.

   ASSIGN aux_flgerror = FALSE
          aux_retorno  = ""
          aux_nrdlote1 = 11000 + par_nrdcaixa
          aux_nrdlote2 = 28000 + par_nrdcaixa
          aux_nrdlote3 = 30000 + par_nrdcaixa.

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcop THEN
        DO:
            ret_cdcritic = 651.
            RETURN.
        END.

   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".


   FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "EXETRUNCAGEM" AND
                      craptab.tpregist = par_cdagenci   NO-LOCK NO-ERROR.
                      
   IF   NOT AVAIL craptab THEN
        aux_exetrunc = NO.
   ELSE
        aux_exetrunc = IF   craptab.dstextab = "NAO" THEN 
                            NO 
                       ELSE YES.
                      
   IF   NOT aux_exetrunc THEN       
        DO:
            ret_cdcritic = 782.
            RETURN.
        END.


    /*** BUSCA PASTA DE DESTINO **/
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = "MICROTRUNC" AND
                       craptab.tpregist = par_cdagenci NO-LOCK NO-ERROR.
                  
    IF   NOT AVAIL craptab THEN
         aux_dsdirmic = "".
    ELSE
         aux_dsdirmic = craptab.dstextab.

    IF   aux_dsdirmic = "" THEN
         DO:
             ret_cdcritic = 782.
             RETURN.
         END.


   FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                      craptab.nmsistem = "CRED"        AND
                      craptab.tptabela = "USUARI"      AND
                      craptab.cdempres = 11            AND
                      craptab.cdacesso = "MAIORESCHQ"  AND
                      craptab.tpregist = 01 NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            ret_cdcritic = 55.
            RETURN.
        END.
    
    ASSIGN aux_nrprevia = 0. 

    FOR EACH crapchd  WHERE crapchd.cdcooper  = par_cdcooper        AND
                            crapchd.dtmvtolt  = par_dtmvtolt        AND
                            crapchd.cdagenci  = par_cdagenci        AND
                     CAN-DO(par_cdbccxlt,STRING(crapchd.cdbccxlt))  AND 
                           (crapchd.nrdolote  = aux_nrdlote1        OR 
                            crapchd.nrdolote  = aux_nrdlote2        OR 
                            crapchd.nrdolote  = aux_nrdlote3)       NO-LOCK 
                            BY crapchd.nrprevia:
    
       ASSIGN aux_nrprevia = crapchd.nrprevia. 
    
    END.
    
    ASSIGN aux_nrprevia = aux_nrprevia + 1
           aux_hrprevia = TIME.
      
    TRANS_1:
    DO TRANSACTION ON ERROR UNDO:
       
       FOR EACH crapchd WHERE crapchd.cdcooper = par_cdcooper               AND
                              crapchd.dtmvtolt = par_dtmvtolt               AND
                              crapchd.cdagenci = par_cdagenci               AND
                              CAN-DO(par_cdbccxlt, STRING(crapchd.cdbccxlt))AND
                             (crapchd.nrdolote = aux_nrdlote1               OR
                              crapchd.nrdolote = aux_nrdlote2               OR
                              crapchd.nrdolote = aux_nrdlote3)              AND
                              CAN-DO("0,2",STRING(crapchd.insitchq))        AND
                              crapchd.insitprv = 0                NO-LOCK,
           EACH crapage WHERE crapage.cdcooper  = crapchd.cdcooper    AND
                              crapage.cdagenci  = crapchd.cdagenci    AND
                              crapage.cdbanchq  = crapcop.cdbcoctl
                              NO-LOCK BREAK BY crapchd.cdagenci:

           IF   FIRST-OF(crapchd.cdagenci)  THEN
                DO:
                    ASSIGN aux_nrseqarq = 1.
                    
                    /*             Nome Arquivo  
                    
                       custodia-001-20101203-999999.txt
                       desconto-001-20101203-888888.txt
                       custodia/desconto - string identificador
                       001               - PAC
                       20101203          - Data Mvto. (AAAAMMMDD)
                       999999/888888     - Lote     
                       .txt              - extensao 
                           
                       caixa-001-010-20101203.001
                       caixa             - string identificador
                       001               - PAC
                       010               - Caixa (atraves do lote)
                       20101203          - Data Mvto. (AAAAMMDD)
                       .
                       001               - Nr. da Previa */

                    aux_nmarqdat = "caixa-" +
                                   STRING(crapchd.cdagenci,"999") + "-" +
                                   SUBSTR(STRING(crapchd.nrdolote,"99999"),3,3)
                                   + "-" +
                                   STRING(YEAR(crapchd.dtmvtolt),"9999") +
                                   STRING(MONTH(crapchd.dtmvtolt),"99")  +
                                   STRING(DAY(crapchd.dtmvtolt),"99") + "." +
                                   STRING(aux_nrprevia,"999").

                    IF   SEARCH(aux_dscooper + "arq/" + aux_nmarqdat) <> ? THEN
                         UNIX SILENT VALUE("rm " + aux_dscooper + "arq/" +
                                           aux_nmarqdat  + " 2>/dev/null").      
                    OUTPUT STREAM str_1 TO VALUE(aux_dscooper + "arq/" +
                                                 aux_nmarqdat).

                    PUT STREAM str_1  FILL("0",47)        FORMAT "x(47)"
                                      "CEL605"            
                                      crapage.cdcomchq    FORMAT "999"
                                      "0001"              /* VERSAO */
                                      crapcop.cdbcoctl    FORMAT "999"
                                      crapcop.nrdivctl    FORMAT "9"   /* DV */
                                      "2"                 /* Ind. Remes */
                                      YEAR(par_dtmvtolt)  FORMAT "9999"
                                      MONTH(par_dtmvtolt) FORMAT "99"
                                      DAY(par_dtmvtolt)    FORMAT "99"
                                      FILL(" ",77)         FORMAT "x(77)"
                                      aux_nrseqarq         FORMAT "9999999999"
                                      SKIP.

                    ASSIGN aux_totqtchq = 0
                           aux_totvlchq = 0.

                END.  /*  Fim  do  FIRST-OF()  */

           ASSIGN aux_nrseqarq = aux_nrseqarq + 1.

           /*  Identifica se o cheque eh da propria cooperativa  */
       
           FIND crapfdc WHERE crapfdc.cdcooper = crapchd.cdcooper AND
                              crapfdc.cdbanchq = crapchd.cdbanchq AND
                              crapfdc.cdagechq = crapchd.cdagechq AND
                              crapfdc.nrctachq = crapchd.nrctachq AND
                              crapfdc.nrcheque = crapchd.nrcheque
                              USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
       
           IF   AVAILABLE crapfdc THEN
                DO:
                    ASSIGN aux_dschqctl = "PG_CX ".
                
                    IF   crapchd.cdbanchq = 1    AND
                         crapchd.cdagechq = 3420 THEN
                         ASSIGN aux_nrctachq = "0070" +    /* Grupo SETEC */
                                         STRING(crapchd.nrctachq,"99999999").
                    ELSE
                         aux_nrctachq = STRING(crapchd.nrctachq,"999999999999").
                END.
           ELSE
                DO:
                    IF   (crapchd.cdcooper = 1  OR    /* Tratamento VIACREDI */
                          crapchd.cdcooper = 16) AND  /* Tratamento ALTOVALE */
                        /* Se o tamanho do nro da conta for maior que 8 entao
                           nao eh uma conta nossa */
                         LENGTH(STRING(crapchd.nrctachq)) <= 8 THEN  
                         DO:
                             IF crapchd.cdcooper = 1 THEN
                                 ASSIGN aux_cdcopant = 2.
                             ELSE
                                 ASSIGN aux_cdcopant = 1.

                             FIND FIRST craptco WHERE 
                                  craptco.cdcopant  = aux_cdcopant          AND
                                  craptco.nrctaant = INTE(crapchd.nrctachq) AND
                                  craptco.tpctatrf  = 1                     AND
                                  craptco.flgativo  = TRUE
                                  USE-INDEX craptco2
                                  NO-LOCK NO-ERROR.
                              
                             IF   AVAILABLE craptco THEN
                                  DO:
                                      FIND crapfdc WHERE 
                                         crapfdc.cdcooper = craptco.cdcopant AND
                                         crapfdc.cdbanchq = crapchd.cdbanchq AND
                                         crapfdc.cdagechq = crapchd.cdagechq AND
                                         crapfdc.nrctachq = crapchd.nrctachq AND
                                         crapfdc.nrcheque = crapchd.nrcheque
                                         USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
       
                                      IF   AVAILABLE crapfdc THEN
                                           /* Para nao receber arquivo de 
                                           retorno na VIACREDI */  
                                           ASSIGN aux_dschqctl = "PG_CX "
                                                  aux_nrctachq = 
                                                     STRING(crapchd.nrctachq,
                                                            "999999999999").
                                  END.
                         END.
                END.
                
           IF   NOT AVAILABLE crapfdc THEN     
                ASSIGN aux_dschqctl = FILL(" ",6)
                       aux_nrctachq = STRING(crapchd.nrctachq,"999999999999").

           IF   crapchd.cdagedst <> 0 THEN /* Deposito intercooperativa */
                ASSIGN aux_cdagedst = crapchd.cdagedst
                       aux_flgdepin = TRUE
                       aux_nrdconta = crapchd.nrctadst.
           ELSE
                ASSIGN aux_cdagedst = crapcop.cdagectl
                       aux_flgdepin = FALSE
                       aux_nrdconta = crapchd.nrdconta.

           PUT STREAM str_1
               crapchd.cdcmpchq         FORMAT "999"          /* COMPE */
               crapchd.cdbanchq         FORMAT "999"          /* BANCO DEST */
               crapchd.cdagechq         FORMAT "9999"         /* AGEN. DEST */
               crapchd.nrddigv2         FORMAT "9"            /* DV 2 */
               aux_nrctachq             FORMAT "x(12)"        /* NR CONTA */
               crapchd.nrddigv1         FORMAT "9"            /* DV 1*/
               crapchd.nrcheque         FORMAT "999999"       /* NR DOCTO */
               crapchd.nrddigv3         FORMAT "9"            /* DV 3 */
               "  "                     FORMAT "x(2)"         /* FILLER */
               (crapchd.vlcheque * 100) FORMAT "99999999999999999" /* VL CHQ*/
               crapchd.cdtipchq         FORMAT "9"            /* TIPIFICACAO */
               "1 "                     FORMAT "x(2)"         /* TIPO CTA */
               "00"                     FORMAT "x(2)"         /* FILLER */
               crapcop.cdbcoctl         FORMAT "999"
               crapcop.cdagectl         FORMAT "9999"
               aux_cdagedst             FORMAT "9999"
               aux_nrdconta             FORMAT "999999999999" /* NR CTA DEPOS */
               crapage.cdcomchq         FORMAT "999"          /* COMPE  */
               YEAR(par_dtmvtolt)       FORMAT "9999"         /* DATA FORMATO */
               MONTH(par_dtmvtolt)      FORMAT "99"           /* YYYYMMDD*/
               DAY(par_dtmvtolt)        FORMAT "99"
               FILL("0",7)              FORMAT "x(7)"         /* NR LOTE*/
               FILL("0",3)              FORMAT "x(3)"         /* SEQ. LOTE*/ 
               aux_dschqctl             FORMAT "x(6)"
               /* Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0" */
               FILL("0",24) + "1"   FORMAT "x(25)"  /* CODIGO IDENTIFICADOR */
               FILL(" ",17)         FORMAT "x(17)"  /* FILLER (diminuido para 17) */
               IF   (crapchd.vlcheque >= 
                     DECIMAL(SUBSTR(craptab.dstextab,01,15))) THEN
                    "030"
               ELSE "034" FORMAT "x(3)"         /* TIPO DE DOCUMENTO - TD */
               aux_nrseqarq             FORMAT "9999999999"
               SKIP. 
         
           /* CRIACAO DA TABELA GENERICA - GNCPCHQ*/
            CREATE gncpchq.
            ASSIGN gncpchq.cdcooper = par_cdcooper
                   gncpchq.cdagenci = crapchd.cdagenci
                   gncpchq.dtmvtolt = par_dtmvtolt
                   gncpchq.cdagectl = crapcop.cdagectl
                   gncpchq.cdbanchq = crapchd.cdbanchq
                   gncpchq.cdagechq = crapchd.cdagechq
                   gncpchq.nrctachq = crapchd.nrctachq
                   gncpchq.nrcheque = crapchd.nrcheque
                   gncpchq.nrddigv2 = crapchd.nrddigv2
                   gncpchq.cdcmpchq = crapchd.cdcmpchq
                   gncpchq.cdtipchq = crapchd.cdtipchq
                   gncpchq.nrddigv1 = crapchd.nrddigv1
                   gncpchq.vlcheque = crapchd.vlcheque
                   gncpchq.nrdconta = IF aux_flgdepin THEN 0 ELSE crapchd.nrdconta
                   gncpchq.nmarquiv = aux_nmarqdat
                   gncpchq.cdoperad = par_cdoperad
                   gncpchq.hrtransa = TIME
                   gncpchq.cdtipreg = 1
                   gncpchq.flgconci = NO
                   gncpchq.nrseqarq = aux_nrseqarq
                   gncpchq.cdbccxlt = crapchd.cdbccxlt  
                   gncpchq.nrdolote = crapchd.nrdolote
                   gncpchq.nrprevia = aux_nrprevia
    
                   gncpchq.cdcritic = 0
                   gncpchq.cdalinea = 0
                   gncpchq.flgpcctl = NO
                   gncpchq.nrddigv3 = crapchd.nrddigv3
                   gncpchq.cdtipdoc = IF   crapchd.vlcheque >=
                                           DEC(SUBSTR(
                                           craptab.dstextab,01,15)) THEN
                                           30
                                      ELSE 34
                   gncpchq.cdagedst = aux_cdagedst
                   gncpchq.nrctadst = crapchd.nrctadst.
                                 
           FIND FIRST crabage WHERE crabage.cdcooper = par_cdcooper AND
                                    crabage.flgdsede = YES  
                                    NO-LOCK NO-ERROR.
                                
           IF   NOT AVAIL crabage THEN
                aux_cdcomchq = 0.
           ELSE
                aux_cdcomchq = crabage.cdcomchq.
           
           ASSIGN  gncpchq.flcmpnac =     
                   IF   aux_cdcomchq = crapchd.cdcmpchq THEN 
                        NO
                   ELSE YES.

           VALIDATE gncpchq.     
           /* Atualiza campo cdbcoenv da CHD - Inicio */
           
           DO aux_contador2 = 1 TO 10:

               FIND crabchd WHERE RECID(crabchd) = RECID(crapchd) 
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.


               IF NOT AVAILABLE crabchd THEN
                  IF LOCKED crabchd THEN
                     DO:
                         ret_cdcritic = 077.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                  ELSE
                     DO:
                        ret_cdcritic = 055.
                        RETURN "NOK".
                     END.

               ASSIGN crabchd.nrprevia = aux_nrprevia
                      crabchd.hrprevia = aux_hrprevia
                      crabchd.insitprv = 1
                      crabchd.flgenvio = TRUE  
                      crabchd.cdbcoenv = crapcop.cdbcoctl
                      ret_cdcritic = 0.
               
               RELEASE crabchd.
               LEAVE.

           END. /* fim do contador */

           IF   ret_cdcritic <> 0   THEN
                RETURN "NOK".

           /* Atualiza campo cdbcoenv da CHD - Fim */

           ASSIGN aux_totqtchq = aux_totqtchq + 1
                  aux_totvlchq = aux_totvlchq + (crapchd.vlcheque * 100).

           IF   ((crapchd.tpdmovto = 1)                       AND
                 (DECIMAL(SUBSTR(craptab.dstextab,01,15)) > 
                                           crapchd.vlcheque)) OR
                ((crapchd.tpdmovto = 2)                       AND
                 (DECIMAL(SUBSTR(craptab.dstextab,01,15)) < 
                                           crapchd.vlcheque)) THEN
                DO:
                     ret_cdcritic = 711.
                           
                     IF aux_flgdepin THEN
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                           " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                           " Parametro do cheque superior alterado" +
                           " Cheque: " + STRING(crapchd.nrcheque,"999999") +
                           " Agencia destino: " + STRING(crapchd.cdagedst) +
                           " Conta: " + STRING(crapchd.nrctadst,
                           "999999999999") + " >> " + aux_dscooper +
                           "log/compel.log").
                     ELSE                                                    
                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                              " Parametro do cheque superior alterado" +
                              " Cheque: " + STRING(crapchd.nrcheque,"999999") +
                              " Conta: " + STRING(crapchd.nrdconta,
                              "999999999999") + " >> " + aux_dscooper +
                              "log/compel.log").

                     aux_flgerror = TRUE.
                     LEAVE.
                END.

           IF   LAST-OF(crapchd.cdagenci) THEN
                DO:
                    ASSIGN ret_vlrtotal = ret_vlrtotal + aux_totvlchq
                           ret_qtarquiv = ret_qtarquiv + 1
                           aux_nrseqarq = aux_nrseqarq + 1.

                    PUT STREAM str_1
                        FILL("9",47)            FORMAT "x(47)" /* HEADER */
                        "CEL605"                               /* NOME   */
                        crapage.cdcomchq        FORMAT "999"   /* COMPE  */
                        "0001"                                 /* VERS   */
                        crapcop.cdbcoctl        FORMAT "999"   /* BANCO  */
                        crapcop.nrdivctl        FORMAT "9"     /* DV     */
                        "2"                                    /* Ind. Rem. */
                        YEAR(par_dtmvtolt)      FORMAT "9999"
                        MONTH(par_dtmvtolt)     FORMAT "99"    /* YYYYMMDD*/
                        DAY(par_dtmvtolt)       FORMAT "99"
                        aux_totvlchq            FORMAT "99999999999999999"
                        FILL(" ",60)            FORMAT "x(60)" /* FILLER */
                        aux_nrseqarq            FORMAT "9999999999"  /* SEQ. */
                        SKIP.

                    OUTPUT STREAM str_1 CLOSE.
                    
                    /* Copia o arquivo para o micro que possui o scanner */
                    aux_dscomand =    
                             "/usr/local/cecred/bin/EnviaArquivoTruncagem.sh " +
                             aux_dsdirmic + " " +
                             "CEL " + 
                             "digit01 " +
                             "cecred.coop.br/digitalizar " +
                             aux_nmarqdat + " " +
                             crapcop.dsdircop + " " +
                             STRING(par_cdagenci,"9999") +
                             " 2>/dev/null".

                    INPUT THROUGH VALUE(aux_dscomand).

                    /*  Prever tratamento de Erro */

                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        IMPORT UNFORMATTED aux_retorno.
                        
                        IF   aux_retorno <> ""  THEN
                             LEAVE.
                    END.

                    IF   aux_retorno <> "" THEN
                         DO:
                             ret_cdcritic = 678.

                             UNIX SILENT VALUE("rm " + aux_dscooper + "arq/" +
                                                aux_nmarqdat  + " 2>/dev/null").
                             UNDO TRANS_1, LEAVE.
                         END.
                    ELSE 
                         /* move para o salvar */
                         UNIX SILENT VALUE("mv " + aux_dscooper + "arq/"     +
                                           aux_nmarqdat + " " + aux_dscooper +
                                           "salvar/truncagem/" + aux_nmarqdat + "_"    +
                                           STRING(TIME,"99999")              + 
                                           " 2>/dev/null").
                                   
                END.  /*  Fim do LAST-OF()  */
       END.   /*  Fim do FOR EACH  */
       
   END. /** Fim DO TRANSACTION **/

   /*  Caso haja algum problema na geracao do arquivo  */
   IF   aux_flgerror THEN        
        DO TRANSACTION ON ENDKEY UNDO, LEAVE: 
       
           FOR EACH gncpchq WHERE gncpchq.cdcooper = par_cdcooper   AND
                                  gncpchq.dtmvtolt = par_dtmvtolt   AND
                                  gncpchq.cdtipreg = 1              AND
                                  gncpchq.cdagenci = par_cdagenci   AND
                      CAN-DO(par_cdbccxlt,STRING(gncpchq.cdbccxlt)) AND
                                 (gncpchq.nrdolote = aux_nrdlote1   OR
                                  gncpchq.nrdolote = aux_nrdlote2   OR
                                  gncpchq.nrdolote = aux_nrdlote3)  AND
                                  gncpchq.nrprevia = aux_nrprevia 
                                  NO-LOCK:
               
               DO aux_contador2 = 1 TO 10:

                  FIND b-gncpchq WHERE RECID(b-gncpchq) = RECID(gncpchq)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF NOT AVAILABLE b-gncpchq THEN
                     IF LOCKED b-gncpchq THEN
                        DO:
                            ret_cdcritic = 077.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                     ELSE
                        DO:
                           ret_cdcritic = 055.
                           RETURN "NOK".
                        END.    
                  ELSE
                     ret_cdcritic = 0.

                  DELETE b-gncpchq.
                  LEAVE.

               END. /* fim do contador */

               IF ret_cdcritic > 0 THEN
                  RETURN.

           END. /* fim do FOR Each */

        END.   /* TRANSACTION */  
             
             
   IF  ret_cdcritic > 0 THEN
       RETURN.

   DO  TRANSACTION ON ENDKEY UNDO, LEAVE:
       
       DO aux_contador2 = 1 TO 10:
       
          FIND LAST crapbcx WHERE crapbcx.cdcooper = par_cdcooper AND
                                  crapbcx.dtmvtolt = par_dtmvtolt AND
                                  crapbcx.cdagenci = par_cdagenci AND
                                  crapbcx.nrdcaixa = par_nrdcaixa AND
                                  crapbcx.cdopecxa = par_cdoperad
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF NOT AVAILABLE crapbcx THEN
             IF LOCKED crapbcx THEN
                DO:
                    ret_cdcritic = 077.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
             ELSE
                .    
          ELSE
             DO:
                 ASSIGN crapbcx.qtchqprv = 0
                        ret_cdcritic = 0.
             END.

          LEAVE.

       END.  /* fim do contador */

   END.

   IF ret_cdcritic > 0 THEN
      RETURN.

END PROCEDURE.



PROCEDURE gerar_digita:

   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdagenci AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_nrdcaixa AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdbccxlt AS CHAR                              NO-UNDO.
   DEF OUTPUT PARAM ret_cdcritic AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_qtarquiv AS INT                               NO-UNDO. 
   DEF OUTPUT PARAM ret_totregis AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_vlrtotal AS DEC                               NO-UNDO.

   DEF VAR          aux_mes      AS CHAR                              NO-UNDO.
   DEF VAR          glb_nrcalcul AS DEC                               NO-UNDO.
   DEF VAR          glb_dsdctitg AS CHAR                              NO-UNDO.
   DEF VAR          glb_stsnrcal AS LOGICAL                           NO-UNDO.
   DEF VAR          aux_flgerror AS LOGICAL                           NO-UNDO.
   DEF VAR          aux_nrseqarq AS INT                               NO-UNDO.
   DEF VAR          aux_nmarqdat AS CHAR   FORMAT "x(20)"             NO-UNDO.
   DEF VAR          aux_totqtchq AS INT                               NO-UNDO.
   DEF VAR          aux_totvlchq AS DECIMAL                           NO-UNDO.
   DEF VAR          aux_cdsituac AS INT                               NO-UNDO.
   DEF VAR          aux_nrdahora AS INT                               NO-UNDO.
   DEF VAR          aux_cdcomchq AS INT                               NO-UNDO.

   DEF VAR          aux_dschqctl AS CHAR                              NO-UNDO.
   
   DEF VAR          aux_nrctachq AS CHAR   FORMAT "x(12)"             NO-UNDO.

   DEF VAR          aux_dsprefx  AS CHAR                              NO-UNDO.
   DEF VAR          aux_lgdigit  AS LOG        INIT FALSE             NO-UNDO.

   DEF VAR          aux_nrdigdv1 AS CHAR                              NO-UNDO.
   DEF VAR          aux_nrdigdv2 AS CHAR                              NO-UNDO.
   DEF VAR          aux_nrdigdv3 AS CHAR                              NO-UNDO.
   DEF VAR          flg_fctarefa AS LOGICAL                           NO-UNDO.
   DEF VAR          aux_flcustod AS LOGICAL                           NO-UNDO.
   DEF VAR          aux_dtliber1 AS DATE                              NO-UNDO.
   DEF VAR          aux_dtliber2 AS DATE                              NO-UNDO.
   DEF VAR          aux_cdagemic AS INT                               NO-UNDO.
   DEF VAR          aux_vlchqmai AS DEC                               NO-UNDO.
   DEF VAR          aux_postext  AS INT                               NO-UNDO.
   DEF VAR          aux_match    AS CHAR                              NO-UNDO.

   DEF BUFFER crabage FOR crapage.

   ASSIGN aux_flgerror = FALSE
          aux_retorno  = "".
       
   CASE par_nmdatela:
       WHEN "DIGITA_CST" THEN ASSIGN aux_dsprefx = "custodia".
       WHEN "DIGITA_DSC" THEN ASSIGN aux_dsprefx = "desconto".
   END CASE.

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcop THEN
        DO:
            ret_cdcritic = 651.
            RETURN.
        END.

   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/"
          flg_fctarefa = FALSE.

   
   
   /* tratamento para verificar se o operador esta na 
      forca tarefa da viacredi */
   IF   par_cdcooper = 1  THEN
        DO:
             aux_match = "*#".
             aux_match = aux_match + par_cdoperad.
             aux_match = aux_match + "|*".

            /*registro de operadorese destinos especificos
              para digitalização*/
             FIND craptab WHERE 
                  craptab.cdcooper = par_cdcooper   AND
                  craptab.nmsistem = "CRED"         AND
                  craptab.tptabela = "GENERI"       AND
                  craptab.cdempres = 0              AND
                  craptab.cdacesso = "OPEDIGITEXC"  AND
                  craptab.tpregist = 0              AND
                  craptab.dstextab MATCHES (aux_match)
                  NO-LOCK NO-ERROR.
                
             ASSIGN aux_dsdirmic = "".
    
             IF   AVAILABLE craptab THEN
             DO:
                 ASSIGN aux_postext = INDEX(craptab.dstextab,"#" +
                                      par_cdoperad ).
                 /*verificar se o cdoperad esta 
                   cadastrado na tab*/
                 IF  aux_postext > 0  THEN
                 DO:
                     /* extrair caminho da tab*/
                     ASSIGN aux_dsdirmic = 
                            ENTRY(2,
                                  ENTRY(1,SUBSTR(craptab.dstextab,aux_postext)
                                       ,";")
                                  ,"|")
                            aux_dsdirmic =
                                SUBSTR(aux_dsdirmic,3,40)
                            flg_fctarefa = TRUE.
                 END.
             END. /* Fim IF AVAILABLE craptab*/ 
        END.

   IF   NOT flg_fctarefa  THEN
        DO:
            IF   par_cdagenci = 0 THEN
                 DO:
                     FIND FIRST crabage WHERE 
                                crabage.cdcooper = par_cdcooper AND
                                crabage.flgdsede = YES  
                                NO-LOCK NO-ERROR.
            
                     IF   AVAILABLE crabage THEN
                          aux_cdagemic = crabage.cdagenci.
                 END.
            ELSE
                 aux_cdagemic = par_cdagenci.         
                             
            /*** BUSCA PASTA DE DESTINO **/
            FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                               craptab.nmsistem = "CRED"        AND
                               craptab.tptabela = "GENERI"      AND
                               craptab.cdempres = 0             AND
                               craptab.cdacesso = "MICROCUSTOD" AND
                               craptab.tpregist = aux_cdagemic
                               NO-LOCK NO-ERROR.
                     
            IF   NOT AVAIL craptab THEN
                 aux_dsdirmic = "".
            ELSE
                 aux_dsdirmic = SUBSTR(craptab.dstextab,3,40).
        END.
   
   IF   aux_dsdirmic = "" THEN
        DO:
            ret_cdcritic = 782.
            RETURN.
        END.

   /* Calcula Datas de Liberacao */
   ASSIGN aux_dtliber1 = par_dtmvtolt
          aux_dtliber2 = par_dtmvtolt.
          
   DO WHILE TRUE:   
   
      ASSIGN aux_dtliber1 = aux_dtliber1 - 1.
      
      IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtliber1)))              OR
           CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper   AND
                                  crapfer.dtferiad = aux_dtliber1)  THEN
           NEXT.
                                               
      LEAVE.
   END.
   

   FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                      craptab.nmsistem = "CRED"        AND
                      craptab.tptabela = "USUARI"      AND
                      craptab.cdempres = 11            AND
                      craptab.cdacesso = "MAIORESCHQ"  AND
                      craptab.tpregist = 01 NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            ret_cdcritic = 55.
            RETURN.
        END.
   ELSE    
        aux_vlchqmai = DECIMAL(SUBSTR(craptab.dstextab,01,15)).        

    FIND FIRST crabage WHERE crabage.cdcooper = par_cdcooper AND
                             crabage.flgdsede = YES  
                             NO-LOCK NO-ERROR.
                                    
    IF   NOT AVAIL crabage THEN
         aux_cdcomchq = 0.
    ELSE
         aux_cdcomchq = crabage.cdcomchq.

    aux_flcustod = TRUE.


    TRANS_1:
    DO TRANSACTION ON ERROR UNDO:

       IF  aux_dsprefx = "custodia"  THEN
           DO:
               FOR EACH crapcst WHERE crapcst.cdcooper = par_cdcooper  AND
                                      crapcst.dtlibera > aux_dtliber1  AND
                                      crapcst.dtlibera <= aux_dtliber2 AND
                                      crapcst.insitprv = 0             AND                                      
                                    ((par_cdagenci <> 0                AND
                                      crapcst.cdagenci = par_cdagenci) OR
                                      par_cdagenci = 0)                AND
                                     (crapcst.insitchq = 0             OR
                                      crapcst.insitchq = 2)
                                      NO-LOCK BREAK BY crapcst.cdcooper:
    
                    IF crapcst.nrborder <> 0 THEN
                       DO:
                          /*Se estiver em um bordero de descto efetivado nao 
                            considerar para a custodia*/
                          FIND crapcdb
                            WHERE crapcdb.cdcooper = crapcst.cdcooper
                              AND crapcdb.nrdconta = crapcst.nrdconta
                              AND crapcdb.dtlibera = crapcst.dtlibera
                              AND crapcdb.dtlibbdc <> ?
                              AND crapcdb.cdcmpchq = crapcst.cdcmpchq
                              AND crapcdb.cdbanchq = crapcst.cdbanchq
                              AND crapcdb.cdagechq = crapcst.cdagechq
                              AND crapcdb.nrctachq = crapcst.nrctachq
                              AND crapcdb.nrcheque = crapcst.nrcheque
                              AND crapcdb.dtdevolu = ?  
                              AND crapcdb.nrborder = crapcst.nrborder NO-LOCK NO-ERROR.
                              
                          IF AVAILABLE(crapcdb) THEN
                             NEXT.
                       END.    
    
                    IF   FIRST-OF(crapcst.cdcooper)  THEN
                         DO:
                             ASSIGN aux_nrseqarq = 1
                        
                             /*             Nome Arquivo  
                               digita-custodia-001-20101203.txt
                               digita-desconto-001-20101203.txt
                               digita            - string identificador
                               custodia/desconto - string identificador
                               20101203          - Data Mvto. (AAAAMMMDD)
                               .
                               TXT               - Lote     */
                        
                                    aux_nmarqdat = 
                                       "digita-" +  aux_dsprefx + "-" +
                                       STRING(YEAR(par_dtmvtolt),"9999") +
                                       STRING(MONTH(par_dtmvtolt),"99")  +
                                       STRING(DAY(par_dtmvtolt),"99") 
                                       + ".txt".
    
                             IF   SEARCH(aux_dscooper + "arq/" + aux_nmarqdat)
                                  <> ? THEN
                                  DO:
                                      BELL.
                                      HIDE MESSAGE NO-PAUSE.
                                      MESSAGE "Arquivo ja existe:" aux_nmarqdat.
                                      ret_cdcritic = 459.
                                      aux_flgerror = TRUE.
                                      LEAVE.
                                  END.
    
                             OUTPUT STREAM str_1 TO VALUE(
                                                     aux_dscooper + "arq/" +
                                                     aux_nmarqdat).
    
                             IF   aux_flcustod THEN
                                  PUT STREAM str_1             
                                          FILL("0",47)        FORMAT "x(47)"
                                          "CUS605"            
                                          aux_cdcomchq        FORMAT "999"
                                          "0001"              /* VERSAO */
                                          crapcop.cdbcoctl    FORMAT "999"
                                          crapcop.nrdivctl    FORMAT "9" /*DV*/
                                          "2"                 /* Ind. Remes */
                                          YEAR(par_dtmvtolt)  FORMAT "9999"
                                          MONTH(par_dtmvtolt) FORMAT "99"
                                          DAY(par_dtmvtolt)   FORMAT "99"
                                          FILL(" ",77)        FORMAT "x(77)"
                                          aux_nrseqarq        
                                                            FORMAT "9999999999"
                                          SKIP.
                             ELSE
                                  PUT STREAM str_1             
                                          FILL("0",47)        FORMAT "x(47)"
                                          "CEL605"            
                                          aux_cdcomchq        FORMAT "999"
                                          "0001"              /* VERSAO */
                                          crapcop.cdbcoctl    FORMAT "999"
                                          crapcop.nrdivctl    FORMAT "9" /*DV*/
                                          "2"                 /* Ind. Remes */
                                          YEAR(par_dtmvtolt)  FORMAT "9999"
                                          MONTH(par_dtmvtolt) FORMAT "99"
                                          DAY(par_dtmvtolt)   FORMAT "99"
                                          FILL(" ",77)        FORMAT "x(77)"
                                          aux_nrseqarq        
                                                            FORMAT "9999999999"
                                          SKIP.
                             
                             
                             ASSIGN aux_totqtchq = 0
                                    aux_totvlchq = 0.
    
                         END.  /*  Fim  do  FIRST-OF()  */
    
                    ASSIGN aux_nrseqarq = aux_nrseqarq + 1.
    
                    IF   crapcst.inchqcop = 1  THEN
                         aux_dschqctl = "PG_CX ".
                    ELSE
                         aux_dschqctl = "      ".

                    IF   crapcst.cdbanchq = 1 THEN
                         aux_nrctachq = "0" + SUBSTRING(crapcst.dsdocmc7,22,11).
                    ELSE
                         aux_nrctachq = STRING(crapcst.nrctachq,"999999999999").
                      
                    ASSIGN aux_nrdigdv2 = SUBSTRING(crapcst.dsdocmc7,9,1)
                           aux_nrdigdv1 = SUBSTRING(crapcst.dsdocmc7,22,1)
                           aux_nrdigdv3 = SUBSTRING(crapcst.dsdocmc7,33,1).
    
                    IF   aux_flcustod THEN
                         PUT STREAM str_1
                             crapcst.cdcmpchq    FORMAT "999"   /* COMPE */
                             crapcst.cdbanchq    FORMAT "999"   /* BANCO DEST */
                             crapcst.cdagechq    FORMAT "9999"  /* AGEN. DEST */
                             aux_nrdigdv2        FORMAT "9"     /* DV 2 */ 
                             aux_nrctachq        FORMAT "x(12)" /* NR CONTA */
                             aux_nrdigdv1        FORMAT "9"     /* DV 1*/
                             crapcst.nrcheque    FORMAT "999999"  /* NR DOCTO */
                             aux_nrdigdv3        FORMAT "9"     /* DV 3 */
                             "  "                FORMAT "x(2)"  /* FILLER */
                             (crapcst.vlcheque * 100) 
                                            FORMAT "99999999999999999" /* VL */
                             SUBSTRING(crapcst.dsdocmc7,20,1)
                                            FORMAT "9"         /* TIPIFICACAO */
                             "11"                FORMAT "x(2)"  /* ENTRADA */
                             "00"                FORMAT "x(2)"     /* FILLER */
                             crapcop.cdbcoctl    FORMAT "999"
                             crapcop.cdagectl    FORMAT "9999"
                             crapcop.cdagectl    FORMAT "9999"
                             crapcst.nrdconta    FORMAT "999999999999"
                             aux_cdcomchq        FORMAT "999"
                             YEAR(crapcst.dtlibera)  FORMAT "9999"   
                             MONTH(crapcst.dtlibera) FORMAT "99"      
                             DAY(crapcst.dtlibera)   FORMAT "99"
                             FILL("0",7)         FORMAT "x(7)"   /* NR LOTE*/
                             FILL("0",3)         FORMAT "x(3)"   /* SEQ. LOTE */
                             aux_dschqctl        FORMAT "x(6)"
                             /* Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0" */
                             FILL("0",24) + "1"   FORMAT "x(25)"  /* CODIGO IDENTIFICADOR */
                             FILL(" ",17)         FORMAT "x(17)"  /* FILLER (diminuido para 17) */
                             IF   (crapcst.vlcheque >= aux_vlchqmai) THEN
                                  "030"
                             ELSE "034"          FORMAT "x(3)"  /* TD */
                             aux_nrseqarq        FORMAT "9999999999"
                             SKIP. 
                    ELSE
                         PUT STREAM str_1
                             crapcst.cdcmpchq    FORMAT "999"   /* COMPE */
                             crapcst.cdbanchq    FORMAT "999"   /* BANCO DEST */
                             crapcst.cdagechq    FORMAT "9999"  /* AGEN. DEST */
                             aux_nrdigdv2        FORMAT "9"     /* DV 2 */ 
                             aux_nrctachq        FORMAT "x(12)" /* NR CONTA */
                             aux_nrdigdv1        FORMAT "9"     /* DV 1*/
                             crapcst.nrcheque    FORMAT "999999"  /* NR DOCTO */
                             aux_nrdigdv3        FORMAT "9"     /* DV 3 */
                             "  "                FORMAT "x(2)"  /* FILLER */
                            (crapcst.vlcheque * 100) 
                                            FORMAT "99999999999999999" /* VL*/
                             SUBSTRING(crapcst.dsdocmc7,20,1)
                                            FORMAT "9"         /* TIPIFICACAO */
                            "10"                FORMAT "x(2)"  /* TIPO CTA */
                            "00"                FORMAT "x(2)"     /* FILLER */
                            crapcop.cdbcoctl    FORMAT "999"
                            crapcop.cdagectl    FORMAT "9999"
                            crapcop.cdagectl    FORMAT "9999"
                            crapcst.nrdconta    FORMAT "999999999999"
                            aux_cdcomchq        FORMAT "999"
                            YEAR(par_dtmvtolt)  FORMAT "9999"   
                            MONTH(par_dtmvtolt) FORMAT "99"      
                            DAY(par_dtmvtolt)   FORMAT "99"
                            FILL("0",7)         FORMAT "x(7)"   /* NR LOTE*/
                            FILL("0",3)         FORMAT "x(3)"   /* SEQ. LOTE */
                            aux_dschqctl        FORMAT "x(6)"
                            /* Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0" */
                            FILL("0",24) + "1"   FORMAT "x(25)"  /* CODIGO IDENTIFICADOR */
                            FILL(" ",17)         FORMAT "x(17)"  /* FILLER (diminuido para 17) */
                            IF   (crapcst.vlcheque >= aux_vlchqmai) THEN
                                 "030"
                            ELSE "034"          FORMAT "x(3)"   /* TD */
                            aux_nrseqarq        FORMAT "9999999999"
                            SKIP.
                    
                    ASSIGN aux_totqtchq = aux_totqtchq + 1
                           aux_totvlchq = aux_totvlchq + 
                                          (crapcst.vlcheque * 100).
    
                    IF   LAST-OF(crapcst.cdcooper) THEN
                         DO:
                             ASSIGN ret_vlrtotal = ret_vlrtotal + 
                                                   (aux_totvlchq / 100)
                                    ret_qtarquiv = ret_qtarquiv + 1
                                    aux_nrseqarq = aux_nrseqarq + 1.
    
                             IF   aux_flcustod THEN
                                  PUT STREAM str_1
                                      FILL("9",47)          FORMAT "x(47)"
                                      "CUS605"
                                      aux_cdcomchq          FORMAT "999"
                                      "0001"
                                      crapcop.cdbcoctl      FORMAT "999"
                                      crapcop.nrdivctl      FORMAT "9"
                                      "2"
                                      YEAR(par_dtmvtolt)    FORMAT "9999"
                                      MONTH(par_dtmvtolt)   FORMAT "99"
                                      DAY(par_dtmvtolt)     FORMAT "99"
                                      (aux_totvlchq * 100)    
                                                  FORMAT "99999999999999999"
                                      FILL(" ",60)          FORMAT "x(60)"
                                      aux_nrseqarq          FORMAT "9999999999"
                                      SKIP.
                             ELSE
                                  PUT STREAM str_1
                                      FILL("9",47)          FORMAT "x(47)"
                                      "CEL605"
                                      aux_cdcomchq          FORMAT "999"
                                      "0001"
                                      crapcop.cdbcoctl      FORMAT "999"
                                      crapcop.nrdivctl      FORMAT "9"
                                      "2"
                                      YEAR(par_dtmvtolt)    FORMAT "9999"
                                      MONTH(par_dtmvtolt)   FORMAT "99"
                                      DAY(par_dtmvtolt)     FORMAT "99"
                                      (aux_totvlchq * 100)    
                                                  FORMAT "99999999999999999"
                                      FILL(" ",60)          FORMAT "x(60)"
                                      aux_nrseqarq          FORMAT "9999999999"
                                      SKIP.

                             OUTPUT STREAM str_1 CLOSE.
    
                            
                            IF   aux_flcustod THEN
                                 /* Copia o arquivo p/ micro do scanner */
                                 aux_dscomand =    
                              "/usr/local/cecred/bin/EnviaArquivoTruncagem.sh "
                              + aux_dsdirmic + " " + "CUS " + "digit01 " +
                              "cecred.coop.br/digitalizar " + aux_nmarqdat + 
                              " " + crapcop.dsdircop + " " +
                              STRING(par_cdagenci,"9999") + " 2>/dev/null".
                            ELSE
                                 aux_dscomand =    
                              "/usr/local/cecred/bin/EnviaArquivoTruncagem.sh "
                              + aux_dsdirmic + " " + "CEL " + "digit01 " +
                              "cecred.coop.br/digitalizar " + aux_nmarqdat + 
                              " " + crapcop.dsdircop + " " +
                              STRING(par_cdagenci,"9999") + " 2>/dev/null".
                            
                            INPUT THROUGH VALUE(aux_dscomand).
                            
                            /*  Prever tratamento de Erro */
    
                            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                IMPORT UNFORMATTED aux_retorno.

                                IF  aux_retorno <> ""  THEN
                                    LEAVE.
                            END.
    
                            IF   aux_retorno <> "" THEN
                                 DO:
                                     ret_cdcritic = 678.
    
                                     UNIX SILENT VALUE("rm " + aux_dscooper + 
                                                       "arq/" + aux_nmarqdat  + 
                                                       " 2>/dev/null").
                                     UNDO TRANS_1, LEAVE.
                                 END.
                            ELSE
                                 /* move para o salvar */
                                 UNIX SILENT VALUE("mv " + aux_dscooper + 
                                                   "arq/" +
                                                   aux_nmarqdat + " " + 
                                                   aux_dscooper + "salvar/" + 
                                                   aux_nmarqdat + "_"  +
                                                   STRING(TIME,"99999") + 
                                                   " 2>/dev/null").
                                       
                         END.  /*  Fim do LAST-OF()  */
               END.   /*  Fim do FOR EACH  */

           END.
       ELSE
       
       IF  aux_dsprefx = "desconto" THEN
           DO:
               FOR EACH crapcdb WHERE crapcdb.cdcooper =  par_cdcooper  AND
                                      crapcdb.dtlibera >  aux_dtliber1  AND
                                      crapcdb.dtlibera <= aux_dtliber2  AND
                                      crapcdb.dtlibbdc <> ?             AND
                                      crapcdb.insitprv = 0              AND
                                    ((par_cdagenci <> 0                 AND
                                      crapcdb.cdagenci = par_cdagenci)  OR
                                      par_cdagenci = 0)                 AND
                                     (crapcdb.insitchq = 0              OR
                                      crapcdb.insitchq = 2)
                                      NO-LOCK BREAK BY crapcdb.cdcooper:

                   IF   FIRST-OF(crapcdb.cdcooper)  THEN
                        DO:
                            ASSIGN aux_nrseqarq = 1

                            /*             Nome Arquivo  
                                   digita-custodia-001-20101203.txt
                                   digita            - string identificador
                                   custodia/desconto - string identificador
                                   20110203          - Data Mvto. (AAAAMMMDD)
                                   .
                                   TXT  */

                                   aux_nmarqdat = 
                                        "digita-" + aux_dsprefx + "-" +
                                        STRING(YEAR(par_dtmvtolt),"9999") +
                                        STRING(MONTH(par_dtmvtolt),"99")  +
                                        STRING(DAY(par_dtmvtolt),"99") 
                                        + ".txt".

                            IF   SEARCH(aux_dscooper + "arq/" + aux_nmarqdat) 
                                 <> ? THEN
                                 DO:
                                     BELL.
                                     HIDE MESSAGE NO-PAUSE.
                                     MESSAGE "Arquivo ja existe:" aux_nmarqdat.
                                     ret_cdcritic = 459.
                                     aux_flgerror = TRUE.
                                     LEAVE.
                                 END.

                            OUTPUT STREAM str_1 TO VALUE(aux_dscooper + "arq/"
                                                         + aux_nmarqdat).

                            IF   aux_flcustod THEN
                                 PUT STREAM str_1 
                                            FILL("0",47)        FORMAT "x(47)"
                                            "CUS605"            
                                            aux_cdcomchq        FORMAT "999"
                                            "0001"
                                            crapcop.cdbcoctl    FORMAT "999"
                                            crapcop.nrdivctl    FORMAT "9"
                                            "2"
                                            YEAR(par_dtmvtolt)  FORMAT "9999"
                                            MONTH(par_dtmvtolt) FORMAT "99"
                                            DAY(par_dtmvtolt)   FORMAT "99"
                                            FILL(" ",77)        FORMAT "x(77)"
                                            aux_nrseqarq        
                                                           FORMAT "9999999999"
                                            SKIP.
                            ELSE
                                 PUT STREAM str_1 
                                            FILL("0",47)        FORMAT "x(47)"
                                            "CEL605"            
                                            aux_cdcomchq        FORMAT "999"
                                            "0001"
                                            crapcop.cdbcoctl    FORMAT "999"
                                            crapcop.nrdivctl    FORMAT "9"
                                            "2"
                                            YEAR(par_dtmvtolt)  FORMAT "9999"
                                            MONTH(par_dtmvtolt) FORMAT "99"
                                            DAY(par_dtmvtolt)   FORMAT "99"
                                            FILL(" ",77)        FORMAT "x(77)"
                                            aux_nrseqarq        
                                                           FORMAT "9999999999"
                                            SKIP.
           

                            ASSIGN aux_totqtchq = 0
                                   aux_totvlchq = 0.

                        END.  /*  Fim  do  FIRST-OF()  */

                   ASSIGN aux_nrseqarq = aux_nrseqarq + 1.

                   /*  Identifica se o cheque eh da propria cooperativa  */

                   IF   crapcdb.inchqcop = 1  THEN
                        aux_dschqctl = "PG_CX ".
                   ELSE
                        aux_dschqctl = "      ".
               
                   IF   crapcdb.cdbanchq = 1 THEN
                        aux_nrctachq = "0" + SUBSTRING(crapcdb.dsdocmc7,22,11).
                   ELSE
                        aux_nrctachq = STRING(crapcdb.nrctachq,"999999999999").

                   ASSIGN aux_nrdigdv2 = SUBSTRING(crapcdb.dsdocmc7,9,1)
                          aux_nrdigdv1 = SUBSTRING(crapcdb.dsdocmc7,22,1)
                          aux_nrdigdv3 = SUBSTRING(crapcdb.dsdocmc7,33,1).

                   IF   aux_flcustod THEN
                        PUT STREAM str_1
                            crapcdb.cdcmpchq   FORMAT "999"    /* COMPE */
                            crapcdb.cdbanchq   FORMAT "999"    /* BANCO DEST */
                            crapcdb.cdagechq   FORMAT "9999"   /* AGEN. DEST */
                            aux_nrdigdv2       FORMAT "9"      /* DV 2 */ 
                            aux_nrctachq       FORMAT "x(12)"  /* NR CONTA */
                            aux_nrdigdv1       FORMAT "9"      /* DV 1*/
                            crapcdb.nrcheque   FORMAT "999999" /* NR DOCTO */
                            aux_nrdigdv3       FORMAT "9"      /* DV 3 */
                            "  "               FORMAT "x(2)"   /* FILLER */
                           (crapcdb.vlcheque * 100) FORMAT "99999999999999999" 
                            SUBSTRING(crapcdb.dsdocmc7,20,1)
                                               FORMAT "9"      /* TIPIFICACAO */
                            "11"                               /* ENTRADA */
                            "00"               FORMAT "x(2)"   /* FILLER */
                            crapcop.cdbcoctl   FORMAT "999"
                            crapcop.cdagectl   FORMAT "9999"
                            crapcop.cdagectl   FORMAT "9999"
                            crapcdb.nrdconta   FORMAT "999999999999"
                            aux_cdcomchq       FORMAT "999"             
                            YEAR(crapcdb.dtlibera)  FORMAT "9999" 
                            MONTH(crapcdb.dtlibera) FORMAT "99"
                            DAY(crapcdb.dtlibera)   FORMAT "99"
                            FILL("0",7)        FORMAT "x(7)"   
                            FILL("0",3)           FORMAT "x(3)"        
                            aux_dschqctl          FORMAT "x(6)"
                            /* Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0" */
                            FILL("0",24) + "1"   FORMAT "x(25)"  /* CODIGO IDENTIFICADOR */
                            FILL(" ",17)         FORMAT "x(17)"  /* FILLER (diminuido para 17) */
                            IF   (crapcdb.vlcheque >= aux_vlchqmai) THEN
                                 "030"
                            ELSE "034"            FORMAT "x(3)"  /* TD */
                            aux_nrseqarq          FORMAT "9999999999"
                            SKIP.
                   ELSE
                        PUT STREAM str_1
                            crapcdb.cdcmpchq   FORMAT "999"    /* COMPE */
                            crapcdb.cdbanchq   FORMAT "999"    /* BANCO DEST */
                            crapcdb.cdagechq   FORMAT "9999"   /* AGEN. DEST */
                            aux_nrdigdv2       FORMAT "9"      /* DV 2 */ 
                            aux_nrctachq       FORMAT "x(12)"  /* NR CONTA */
                            aux_nrdigdv1       FORMAT "9"      /* DV 1*/
                            crapcdb.nrcheque   FORMAT "999999" /* NR DOCTO */
                            aux_nrdigdv3       FORMAT "9"      /* DV 3 */
                            "  "               FORMAT "x(2)"   /* FILLER */
                           (crapcdb.vlcheque * 100) FORMAT "99999999999999999" 
                            SUBSTRING(crapcdb.dsdocmc7,20,1)
                                               FORMAT "9"      /* TIPIFICACAO */
                            "10"               FORMAT "x(2)"   /* TIPO CTA */
                            "00"               FORMAT "x(2)"   /* FILLER */
                            crapcop.cdbcoctl   FORMAT "999"
                            crapcop.cdagectl   FORMAT "9999"
                            crapcop.cdagectl   FORMAT "9999"
                            crapcdb.nrdconta   FORMAT "999999999999"
                            aux_cdcomchq       FORMAT "999"             
                            YEAR(par_dtmvtolt)  FORMAT "9999" 
                            MONTH(par_dtmvtolt) FORMAT "99"
                            DAY(par_dtmvtolt)   FORMAT "99"
                            FILL("0",7)        FORMAT "x(7)"   
                            FILL("0",3)        FORMAT "x(3)"        
                            aux_dschqctl       FORMAT "x(6)"
                            /* Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0" */
                            FILL("0",24) + "1"   FORMAT "x(25)"  /* CODIGO IDENTIFICADOR */
                            FILL(" ",17)         FORMAT "x(17)"  /* FILLER (diminuido para 17) */
                            IF   (crapcdb.vlcheque >= aux_vlchqmai) THEN
                                 "030"
                            ELSE "034"         FORMAT "x(3)"  /* TD */
                            aux_nrseqarq       FORMAT "9999999999"
                            SKIP.

                   ASSIGN aux_totqtchq = aux_totqtchq + 1
                          aux_totvlchq = aux_totvlchq + 
                                         (crapcdb.vlcheque * 100).

                   IF   LAST-OF(crapcdb.cdcooper) THEN
                        DO:
                            ASSIGN ret_vlrtotal = ret_vlrtotal + 
                                                 (aux_totvlchq / 100)
                                   ret_qtarquiv = ret_qtarquiv + 1
                                   aux_nrseqarq = aux_nrseqarq + 1.

                            IF   aux_flcustod THEN
                                 PUT STREAM str_1
                                     FILL("9",47)            FORMAT "x(47)"
                                     "CUS605"
                                     aux_cdcomchq            FORMAT "999"
                                     "0001"
                                     crapcop.cdbcoctl        FORMAT "999"
                                     crapcop.nrdivctl        FORMAT "9"
                                     "2"
                                     YEAR(par_dtmvtolt)      FORMAT "9999"
                                     MONTH(par_dtmvtolt)     FORMAT "99"
                                     DAY(par_dtmvtolt)       FORMAT "99"
                                     aux_totvlchq            
                                               FORMAT "99999999999999999"
                                     FILL(" ",60)            FORMAT "x(60)"
                                     aux_nrseqarq            FORMAT "9999999999"
                                     SKIP.
                            ELSE
                                 PUT STREAM str_1
                                     FILL("9",47)            FORMAT "x(47)"
                                     "CEL605"
                                     aux_cdcomchq            FORMAT "999"
                                     "0001"
                                     crapcop.cdbcoctl        FORMAT "999"
                                     crapcop.nrdivctl        FORMAT "9"
                                     "2"
                                     YEAR(par_dtmvtolt)      FORMAT "9999"
                                     MONTH(par_dtmvtolt)     FORMAT "99"
                                     DAY(par_dtmvtolt)       FORMAT "99"
                                     aux_totvlchq            
                                               FORMAT "99999999999999999"
                                     FILL(" ",60)            FORMAT "x(60)"
                                     aux_nrseqarq            FORMAT "9999999999"
                                     SKIP.
                                                    
                                                                 
                            OUTPUT STREAM str_1 CLOSE.

                            IF   aux_flcustod THEN
                             /* Copia o arquivo p/ micro do scanner */
                                 aux_dscomand =    
                               "/usr/local/cecred/bin/EnviaArquivoTruncagem.sh "
                               + aux_dsdirmic + " " + "CUS " + "digit01 " +
                               "cecred.coop.br/digitalizar " + aux_nmarqdat + 
                               " " + crapcop.dsdircop + " " +
                               STRING(par_cdagenci,"9999") + " 2>/dev/null".
                            ELSE
                                 /* Copia o arquivo p/ micro do scanner */
                                 aux_dscomand =    
                               "/usr/local/cecred/bin/EnviaArquivoTruncagem.sh "
                               + aux_dsdirmic + " " + "CEL " + "digit01 " +
                               "cecred.coop.br/digitalizar " + aux_nmarqdat + 
                               " " + crapcop.dsdircop + " " +
                               STRING(par_cdagenci,"9999") + " 2>/dev/null".
                           
                            
                            INPUT THROUGH VALUE(aux_dscomand).

                            /*  Prever tratamento de Erro */

                            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      
                                IMPORT UNFORMATTED  aux_retorno.
                                IF  aux_retorno <> ""  THEN
                                    LEAVE.
                            END.

                            IF   aux_retorno <> "" THEN
                                 DO:
                                     ret_cdcritic = 678.

                                     UNIX SILENT VALUE("rm " + aux_dscooper + 
                                                       "arq/" + aux_nmarqdat + 
                                                       " 2>/dev/null").
                                     UNDO TRANS_1, LEAVE.
                                 END.
                            ELSE
                                 /* move para o salvar */
                                 UNIX SILENT VALUE("mv " + aux_dscooper + 
                                                   "arq/" + aux_nmarqdat + 
                                                   " " + aux_dscooper +
                                                   "salvar/" + aux_nmarqdat +
                                                   "_" + STRING(TIME,"99999") +
                                                  " 2>/dev/null").

                        END.  /*  Fim do LAST-OF()  */
               END.   /*  Fim do FOR EACH  */
           END.
       
   END. /** Fim DO TRANSACTION **/

             
END PROCEDURE.



PROCEDURE gerar_compel_custodia:
    
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdbccxlt AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrdolote AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                               NO-UNDO.
    DEF OUTPUT PARAM ret_qtarquiv AS INT                               NO-UNDO. 
    DEF OUTPUT PARAM ret_totregis AS INT                               NO-UNDO.
    DEF OUTPUT PARAM ret_vlrtotal AS DEC                               NO-UNDO.
    
    DEF VAR          aux_mes      AS CHAR                              NO-UNDO.
    DEF VAR          aux_nrseqarq AS INT                               NO-UNDO.
    DEF VAR          aux_nmarqdat AS CHAR   FORMAT "x(20)"             NO-UNDO.
    DEF VAR          aux_totqtcst AS INT                               NO-UNDO.
    DEF VAR          aux_totvlcst AS DECIMAL                           NO-UNDO.
    DEF VAR          aux_nrctachq AS CHAR   FORMAT "x(12)"             NO-UNDO.
    DEF VAR          aux_nrdigdv1 AS CHAR                              NO-UNDO.
    DEF VAR          aux_nrdigdv2 AS CHAR                              NO-UNDO.
    DEF VAR          aux_nrdigdv3 AS CHAR                              NO-UNDO.
    DEF VAR          aux_flcooper AS LOGICAL                           NO-UNDO.
    DEF VAR          aux_cdagenci AS INT                               NO-UNDO.
    DEF VAR          flg_fctarefa AS LOGICAL                           NO-UNDO.
    DEF VAR          aux_cdcmpchq AS INT                               NO-UNDO.
    DEF VAR          aux_dschqctl AS CHAR                              NO-UNDO.
    DEF VAR          aux_vlchqmai AS DEC                               NO-UNDO.
    DEF VAR          aux_postext  AS INT                               NO-UNDO.
    DEF VAR          aux_match    AS CHAR                              NO-UNDO.
    
    DEF BUFFER crabage FOR crapage.
    DEF BUFFER b-crapcst FOR crapcst.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcop THEN
         DO:
             ret_cdcritic = 651.
             RETURN.
         END.
    
    ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".
    
    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper AND
                       crapage.cdagenci = par_cdagenci     NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapage  THEN
         DO:
             ret_cdcritic = 962.
             RETURN.
         END.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MAIORESCHQ"  AND
                       craptab.tpregist = 01 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             ret_cdcritic = 55.
             RETURN.
         END.
    ELSE    
         aux_vlchqmai = DECIMAL(SUBSTR(craptab.dstextab,01,15)). 

    FIND FIRST crabage WHERE crabage.cdcooper = par_cdcooper AND
                             crabage.flgdsede = YES  
                             NO-LOCK NO-ERROR.
                                    
    IF   NOT AVAIL crabage THEN
         aux_cdcmpchq = 0.
    ELSE
         aux_cdcmpchq = crabage.cdcomchq.

    
    IF   MONTH(par_dtmvtolt) > 9 THEN
         CASE MONTH(par_dtmvtolt):
              WHEN 10 THEN aux_mes = "O".
              WHEN 11 THEN aux_mes = "N".
              WHEN 12 THEN aux_mes = "D".
         END CASE.
    ELSE
         aux_mes = STRING(MONTH(par_dtmvtolt),"9").    
    
    /* Nome Arquivo  */
    /* custodia-001-20111231-999999.txt
       PAC    - 999
       Data   - AAAAMMDD - Data do Movto
       NrLote - 999999 - Nr do Lote
       .txt */
    ASSIGN aux_nrseqarq = 1
           aux_nmarqdat = "custodia-"                        +
                          STRING(par_cdagenci,"999")         +
                          "-" + 
                          STRING(YEAR(par_dtmvtolt),"9999")  +
                          STRING(MONTH(par_dtmvtolt),"99")   +
                          STRING(DAY(par_dtmvtolt),"99")     +
                          "-"                                +
                          STRING(par_nrdolote, "999999")     +
                          ".txt".

    TRANS_1:
    DO TRANSACTION ON ERROR UNDO:

       FOR EACH crapcst WHERE crapcst.cdcooper  = par_cdcooper AND
                              crapcst.dtmvtolt  = par_dtmvtolt AND
                              crapcst.cdagenci  = par_cdagenci AND
                              crapcst.insitprv  = 0            AND
                              crapcst.nrdolote  = par_nrdolote AND
                             (crapcst.insitchq  = 0            OR
                              crapcst.insitchq  = 2)
                              NO-LOCK BREAK BY crapcst.dtmvtolt:
                              
           IF   FIRST-OF(crapcst.dtmvtolt) THEN
                DO:
                    OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqdat).
    
                    PUT STREAM str_1  FILL("0",47)         FORMAT "x(47)"
                         "CUS605"                           /* NOME   */
                         aux_cdcmpchq         FORMAT "999"  /* COMPE  */
                         "0001"                             /* VERSAO */
                         crapcop.cdbcoctl     FORMAT "999"  /* BANCO */
                         crapcop.nrdivctl     FORMAT "9"    /* DV    */
                         "2"                           /* Ind. Remes */
                         YEAR(par_dtmvtolt)   FORMAT "9999" /* DATA */
                         MONTH(par_dtmvtolt)  FORMAT "99"   /*YYYYMMDD*/
                         DAY(par_dtmvtolt)    FORMAT "99"
                         FILL(" ",77)         FORMAT "x(77)"
                         aux_nrseqarq         FORMAT "9999999999"
                         SKIP.
                END.
                              
           /*   Identificar se o cheque eh da COOPER  */
           IF   par_cdcooper = 1     AND
                aux_flcooper = FALSE THEN
                DO:
                    /*  Para os cheques do PAC 1 ou 27 digitaliza na Sede */
              
                    IF  crapcst.nrdconta = 85448 AND
                        (par_cdagenci = 1        OR
                         par_cdagenci = 27)      THEN
                         aux_flcooper = TRUE.
                END.

           IF   crapcst.cdbanchq = crapcop.cdbcoctl  AND
                crapcst.cdagechq = crapcop.cdagectl  THEN
                ASSIGN aux_dschqctl = "PG_CX ".
           ELSE
                DO:
                    IF   par_cdcooper     = 16 AND
                         crapcst.inchqcop = 1  THEN
                         ASSIGN aux_dschqctl = "PG_CX ".
                    ELSE
                         ASSIGN aux_dschqctl = "      ".
                END.
                
                
           ASSIGN aux_nrseqarq = aux_nrseqarq + 1
                  ret_totregis = ret_totregis + 1
                  aux_totvlcst = aux_totvlcst + crapcst.vlcheque
                  ret_vlrtotal = ret_vlrtotal + crapcst.vlcheque.

           IF   crapcst.cdbanchq = 1 THEN
                aux_nrctachq = "0" + SUBSTRING(crapcst.dsdocmc7,22,11).
           ELSE
                aux_nrctachq = STRING(crapcst.nrctachq,"999999999999").

           ASSIGN aux_nrdigdv2 = SUBSTRING(crapcst.dsdocmc7,9,1)
                  aux_nrdigdv1 = SUBSTRING(crapcst.dsdocmc7,22,1)
                  aux_nrdigdv3 = SUBSTRING(crapcst.dsdocmc7,33,1).
           
           PUT STREAM str_1  
               crapcst.cdcmpchq         FORMAT "999"    /* COMPE  */
               crapcst.cdbanchq         FORMAT "999"    /* BANCO DESTINO */
               crapcst.cdagechq         FORMAT "9999"   /* AGEN. DESTINO */
               aux_nrdigdv2             FORMAT "9"      /* DV 2 */
               aux_nrctachq             FORMAT "x(12)"  /* NR CONTA */
               aux_nrdigdv1             FORMAT "9"      /* DV 1*/
               crapcst.nrcheque         FORMAT "999999" /* NR DOCTO */
               aux_nrdigdv3             FORMAT "9"      /* DV 3 */
               "  "                     FORMAT "x(2)"   /* UF */
               (crapcst.vlcheque * 100) FORMAT "99999999999999999" /* VL CHQ*/
               SUBSTRING(crapcst.dsdocmc7,20,1)
                                        FORMAT "x(1)"   /* TIPIFICACAO */
               "11"                     FORMAT "x(2)"   /* ENTRADA */
               "00"                     FORMAT "x(2)"   /* FILLER */
               crapcop.cdbcoctl         FORMAT "999"
               crapcop.cdagectl         FORMAT "9999"
               crapcop.cdagectl         FORMAT "9999"
               crapcst.nrdconta         FORMAT "999999999999" /* NR CONTA */
               aux_cdcmpchq             FORMAT "999"    /* COMPE  */
               YEAR(crapcst.dtlibera)   FORMAT "9999"   /* DATA FORMATO */
               MONTH(crapcst.dtlibera)  FORMAT "99"     /* YYYYMMDD*/
               DAY(crapcst.dtlibera)    FORMAT "99"
               FILL("0",7)              FORMAT "x(7)"   /* NR LOTE*/
               FILL("0",3)              FORMAT "x(3)"   /* SEQ. LOTE*/ 
               aux_dschqctl             FORMAT "x(6)"   /* CENTRO PROCESSADOR */
               /* Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0" */
               FILL("0",24) + "1"       FORMAT "x(25)"  /* CODIGO IDENTIFICADOR */
               FILL(" ",17)             FORMAT "x(17)"  /* FILLER (diminuido para 17) */
               IF   (crapcst.vlcheque >= aux_vlchqmai) THEN
                    "030"
               ELSE "034"               FORMAT "x(3)"   /* TD */
               aux_nrseqarq             FORMAT "9999999999"
               SKIP.
        
           IF   LAST-OF(crapcst.dtmvtolt) THEN
                DO:
                    ASSIGN aux_nrseqarq = aux_nrseqarq + 1
                           ret_qtarquiv = ret_qtarquiv + 1.

                    PUT STREAM str_1
                        FILL("9",47)            FORMAT "x(47)" /* HEADER */
                        "CUS605"                               /* NOME   */
                        aux_cdcmpchq            FORMAT "999"   /* COMPE  */
                        "0001"                                 /* VERS   */
                        crapcop.cdbcoctl        FORMAT "999"   /* BANCO  */ 
                        crapcop.nrdivctl        FORMAT "9"     /* DV     */
                        "1"                                    /* Ind. Rem. */
                        YEAR(par_dtmvtolt)      FORMAT "9999"  /* DATA FORM */
                        MONTH(par_dtmvtolt)     FORMAT "99"    /* YYYYMMDD*/
                        DAY(par_dtmvtolt)       FORMAT "99"
                        (aux_totvlcst * 100)    FORMAT "99999999999999999"
                        FILL(" ",60)            FORMAT "x(60)" /* FILLER */
                        aux_nrseqarq            FORMAT "9999999999"  /* SEQ */
                        SKIP.
    
                    OUTPUT STREAM str_1 CLOSE.
                    
                    
                    /* tratamento para verificar o operador esta na forca 
                       tarefa da viacredi */
                    IF   par_cdcooper = 1  THEN
                         DO:
                             aux_match = "*#".
                             aux_match = aux_match + par_cdoperad.
                             aux_match = aux_match + "|*".

                             /*registro de operadorese destinos especificos
                              para digitalização*/
                             FIND craptab WHERE 
                                  craptab.cdcooper = par_cdcooper   AND
                                  craptab.nmsistem = "CRED"         AND
                                  craptab.tptabela = "GENERI"       AND
                                  craptab.cdempres = 0              AND
                                  craptab.cdacesso = "OPEDIGITEXC"  AND
                                  craptab.tpregist = 0              AND
                                  craptab.dstextab MATCHES (aux_match)
                                  NO-LOCK NO-ERROR.
                                
                             ASSIGN aux_dsdirmic = "".

                             IF   AVAILABLE craptab THEN
                                 DO:
                                     ASSIGN aux_postext = INDEX(craptab.dstextab,"#" +
                                                          par_cdoperad + "|" ).
                                     /*verificar se o cdoperad esta 
                                       cadastrado na tab*/
                                     IF  aux_postext > 0  THEN
                                     DO:
                                         /* extrair caminho da tab*/
                                         ASSIGN aux_dsdirmic = 
                                                ENTRY(2,
                                                      ENTRY(1,SUBSTR(craptab.dstextab,aux_postext)
                                                           ,";")
                                                      ,"|")
                                                aux_dsdirmic =
                                                    SUBSTR(aux_dsdirmic,3,40)
                                                flg_fctarefa = TRUE.
                                     END.
                                 END.
                         END.

                    IF   NOT flg_fctarefa  THEN
                         DO:
                             IF   aux_flcooper THEN
                                  aux_cdagenci = 1.
                             ELSE
                                  aux_cdagenci = par_cdagenci.
             
                             /*** BUSCA PASTA DE DESTINO **/
                             FIND craptab WHERE 
                                  craptab.cdcooper = par_cdcooper  AND
                                  craptab.nmsistem = "CRED"        AND
                                  craptab.tptabela = "GENERI"      AND
                                  craptab.cdempres = 0             AND
                                  craptab.cdacesso = "MICROCUSTOD" AND
                                  craptab.tpregist = par_cdagenci
                                  NO-LOCK NO-ERROR.

                             IF   NOT AVAILABLE craptab THEN
                                  aux_dsdirmic = "".
                             ELSE
                                  aux_dsdirmic = SUBSTR(craptab.dstextab,3,40).
                         END.

                    IF   aux_dsdirmic = "" THEN
                         DO:
                             ret_cdcritic = 782.
                             UNIX SILENT VALUE("rm " + aux_dscooper + "arq/" +
                                               aux_nmarqdat  + " 2>/dev/null").
                             UNDO TRANS_1, LEAVE.
                         END.

                    /* Copia o arquivo para o micro que possui o scanner */
                   
                    aux_dscomand = 
                        "/usr/local/cecred/bin/EnviaArquivoTruncagem.sh " +
                        aux_dsdirmic + " " + "CUS " + "digit01 " +
                        "cecred.coop.br/digitalizar " + aux_nmarqdat + " " +
                        crapcop.dsdircop + " " + STRING(par_cdagenci,"9999") +
                        " 2>/dev/null".

                    INPUT THROUGH VALUE(aux_dscomand).

                    /*  Prever tratamento de Erro */

                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        IMPORT UNFORMATTED aux_retorno.
                        
                        IF   aux_retorno <> ""  THEN
                             LEAVE.
                    END.

                    IF   aux_retorno <> "" THEN
                         DO:
                             ret_cdcritic = 678.

                             UNIX SILENT VALUE("rm " + aux_dscooper + "arq/" +
                                         aux_nmarqdat  + " 2>/dev/null").
                             UNDO TRANS_1, LEAVE.
                         END.
                    ELSE
                         /* move para o salvar */
                         UNIX SILENT VALUE(
                              "mv " + aux_dscooper + "arq/"     +
                              aux_nmarqdat + " " + aux_dscooper +
                              "salvar/truncagem/" + aux_nmarqdat + "_"    +
                              STRING(TIME,"99999")              + 
                              " 2>/dev/null").
                END.
       END.
    END.
       
    IF   ret_cdcritic > 0 THEN
         RETURN.

    DO  TRANSACTION ON ENDKEY UNDO, LEAVE:
      
        FOR EACH crapcst WHERE crapcst.cdcooper = par_cdcooper AND
                               crapcst.dtmvtolt = par_dtmvtolt AND
                               crapcst.cdagenci = par_cdagenci AND
                               crapcst.insitprv = 0            AND
                               crapcst.nrdolote = par_nrdolote AND
                              (crapcst.insitchq = 0            OR
                               crapcst.insitchq = 2)
                               NO-LOCK:
            
            DO aux_contador2 = 1 TO 10:

               FIND b-crapcst WHERE RECID(b-crapcst) = RECID(crapcst)
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               
               IF NOT AVAILABLE b-crapcst THEN
                  DO:
                    IF LOCKED b-crapcst THEN
                        DO:
                          ret_cdcritic = 077.
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                        END.
                  END.
               ELSE
                  ASSIGN b-crapcst.insitprv = 1
                         b-crapcst.dtprevia = TODAY
                         ret_cdcritic = 0.

               LEAVE.

            END. /* fim do contador */

            IF ret_cdcritic > 0 THEN
               RETURN.

            
        END. /* fim do for each */

    END. /* fim do TRANSACTION */
    
END PROCEDURE.


PROCEDURE gerar_compel_dscchq:

    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdbccxlt AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_nrborder AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                               NO-UNDO.
    DEF OUTPUT PARAM ret_qtarquiv AS INT                               NO-UNDO. 
    DEF OUTPUT PARAM ret_totregis AS INT                               NO-UNDO.
    DEF OUTPUT PARAM ret_vlrtotal AS DEC                               NO-UNDO.
    
    DEF VAR          aux_mes      AS CHAR                              NO-UNDO.
    DEF VAR          aux_nrseqarq AS INT                               NO-UNDO.
    DEF VAR          aux_nmarqdat AS CHAR   FORMAT "x(20)"             NO-UNDO.
    DEF VAR          aux_totqtdsc AS INT                               NO-UNDO.
    DEF VAR          aux_totvldsc AS DECIMAL                           NO-UNDO.
    DEF VAR          aux_nrctachq AS CHAR   FORMAT "x(12)"             NO-UNDO.
    DEF VAR          aux_nrdigdv1 AS CHAR                              NO-UNDO.
    DEF VAR          aux_nrdigdv2 AS CHAR                              NO-UNDO.
    DEF VAR          aux_nrdigdv3 AS CHAR                              NO-UNDO.
    DEF VAR          flg_fctarefa AS LOGICAL                           NO-UNDO.
    DEF VAR          aux_flcooper AS LOGICAL                           NO-UNDO.
    DEF VAR          aux_cdagenci AS INT                               NO-UNDO.
    DEF VAR          aux_cdcmpchq AS INT                               NO-UNDO.
    DEF VAR          aux_dschqctl AS CHAR                              NO-UNDO.
    DEF VAR          aux_vlchqmai AS DEC                               NO-UNDO.
    DEF VAR          aux_postext  AS INT                               NO-UNDO.
    DEF VAR          aux_match    AS CHAR                              NO-UNDO.
    
    DEF BUFFER crabage FOR crapage.
    DEF BUFFER b-crapcdb FOR crapcdb.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcop THEN
         DO:
             ret_cdcritic = 651.
             RETURN.
         END.
    
    ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".
    
    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper AND
                       crapage.cdagenci = par_cdagenci     NO-LOCK NO-ERROR.
    
    IF   NOT AVAIL crapage  THEN
         DO:
             ret_cdcritic = 962.
             RETURN.
         END.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MAIORESCHQ"  AND
                       craptab.tpregist = 01 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             ret_cdcritic = 55.
             RETURN.
         END.
    ELSE    
         aux_vlchqmai = DECIMAL(SUBSTR(craptab.dstextab,01,15)).  

    FIND FIRST crabage WHERE crabage.cdcooper = par_cdcooper AND
                             crabage.flgdsede = YES  
                             NO-LOCK NO-ERROR.
                                    
    IF   NOT AVAIL crabage THEN
         aux_cdcmpchq = 0.
    ELSE
         aux_cdcmpchq = crabage.cdcomchq.

     
    IF   MONTH(par_dtmvtolt) > 9 THEN
         CASE MONTH(par_dtmvtolt):
              WHEN 10 THEN aux_mes = "O".
              WHEN 11 THEN aux_mes = "N".
              WHEN 12 THEN aux_mes = "D".
         END CASE.
    ELSE
         aux_mes = STRING(MONTH(par_dtmvtolt),"9").    

    /* Nome Arquivo  */
    /* desc-001-20111231-9999999.txt
       PAC    - 999
       Data   - AAAAMMDD - Data do Movto
       NrLote - 999999 - Nr do Lote  
       .txt */
    ASSIGN aux_nrseqarq = 1
           aux_nmarqdat = "desc-"                        +
                          STRING(par_cdagenci,"999")         +
                          "-" + 
                          STRING(YEAR(par_dtmvtolt),"9999")  +
                          STRING(MONTH(par_dtmvtolt),"99")   +
                          STRING(DAY(par_dtmvtolt),"99")     +
                          "-"                                +
                          STRING(par_nrborder, "9999999")     +
                          ".txt"
           flg_fctarefa = FALSE.


    TRANS_1:
    DO TRANSACTION ON ERROR UNDO:

       FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper AND
                              crapcdb.dtlibbdc = par_dtmvtolt AND
                              crapcdb.cdagenci = par_cdagenci AND
                              crapcdb.insitprv = 0            AND
                              crapcdb.nrborder = par_nrborder AND
                             (crapcdb.insitchq = 0            OR
                              crapcdb.insitchq = 2)
                              NO-LOCK BREAK BY crapcdb.nrborder:
    
           IF   FIRST-OF(crapcdb.nrborder) THEN
                DO:
                    OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqdat).

                    PUT STREAM str_1  FILL("0",47)         FORMAT "x(47)"
                         "CUS605"                           /* NOME   */
                         aux_cdcmpchq         FORMAT "999"  /* COMPE  */
                         "0001"                             /* VERSAO */
                         crapcop.cdbcoctl     FORMAT "999"  /* BANCO */
                         crapcop.nrdivctl     FORMAT "9"    /* DV    */
                         "2"                           /* Ind. Remes */
                         YEAR(par_dtmvtolt)   FORMAT "9999" /* DATA */
                         MONTH(par_dtmvtolt)  FORMAT "99"   /*YYYYMMDD*/
                         DAY(par_dtmvtolt)    FORMAT "99"
                         FILL(" ",77)         FORMAT "x(77)"
                         aux_nrseqarq         FORMAT "9999999999"
                         SKIP.
                END.
     
           ASSIGN aux_nrseqarq = aux_nrseqarq + 1
                  ret_totregis = ret_totregis + 1
                  aux_totvldsc = aux_totvldsc + crapcdb.vlcheque
                  ret_vlrtotal = ret_vlrtotal + crapcdb.vlcheque.
        
           
           IF   crapcdb.cdbanchq = crapcop.cdbcoctl  AND
                crapcdb.cdagechq = crapcop.cdagectl  THEN
                ASSIGN aux_dschqctl = "PG_CX ".
           ELSE
                DO:
                    IF   par_cdcooper     = 16 AND
                         crapcdb.inchqcop = 1  THEN
                         ASSIGN aux_dschqctl = "PG_CX ".
                    ELSE
                         ASSIGN aux_dschqctl = "      ".
                END.
 
           /*   Identificar se o cheque eh da COOPER  */
           IF   par_cdcooper = 1     AND
                aux_flcooper = FALSE THEN
                DO:
                    /*  Para os cheques do PAC 1 ou 27 digitaliza na Sede */
              
                    IF  crapcdb.nrdconta = 85448 AND
                        (par_cdagenci = 1        OR
                         par_cdagenci = 27)      THEN
                         aux_flcooper = TRUE.
                END.

           
           IF   crapcdb.cdbanchq = 1 THEN
                aux_nrctachq = "0" + SUBSTRING(crapcdb.dsdocmc7,22,11).
           ELSE
                aux_nrctachq = STRING(crapcdb.nrctachq,"999999999999").

           ASSIGN aux_nrdigdv2 = SUBSTRING(crapcdb.dsdocmc7,9,1)
                  aux_nrdigdv1 = SUBSTRING(crapcdb.dsdocmc7,22,1)
                  aux_nrdigdv3 = SUBSTRING(crapcdb.dsdocmc7,33,1).
               
           PUT STREAM str_1
               crapcdb.cdcmpchq         FORMAT "999"    /* COMPE  */
               crapcdb.cdbanchq         FORMAT "999"    /* BANCO DESTINO */
               crapcdb.cdagechq         FORMAT "9999"   /* AGEN. DESTINO */
               aux_nrdigdv2             FORMAT "9"       /* DV 2 */
               aux_nrctachq             FORMAT "999999999999" /* NR CONTA */
               aux_nrdigdv1             FORMAT "9"      /* DV 1*/
               crapcdb.nrcheque         FORMAT "999999" /* NR DOCTO */
               aux_nrdigdv3             FORMAT "9"      /* DV 3 */
               "  "                     FORMAT "x(2)"   /* UF */
              (crapcdb.vlcheque * 100)  FORMAT "99999999999999999" /* VL CHQ*/
               SUBSTRING(crapcdb.dsdocmc7,20,1)
                                        FORMAT "x(1)"   /* TIPIFICACAO */
               "11"                     FORMAT "x(2)"   /* ENTRADA */
               "00"                     FORMAT "x(2)"   /* FILLER */
               crapcop.cdbcoctl         FORMAT "999"
               crapcop.cdagectl         FORMAT "9999"
               crapcop.cdagectl         FORMAT "9999"
               crapcdb.nrdconta         FORMAT "999999999999" /* NR CONTA */
               aux_cdcmpchq             FORMAT "999"    /* COMPE  */
               YEAR(crapcdb.dtlibera)   FORMAT "9999"   /* DATA FORMATO */
               MONTH(crapcdb.dtlibera)  FORMAT "99"     /* YYYYMMDD*/
               DAY(crapcdb.dtlibera)    FORMAT "99"
               FILL("0",7)              FORMAT "x(7)"   /* NR LOTE*/
               FILL("0",3)              FORMAT "x(3)"   /* SEQ. LOTE*/ 
               aux_dschqctl             FORMAT "x(6)"   /* CENTRO PROCESSADOR */
               /* Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0" */
               FILL("0",24) + "1"       FORMAT "x(25)"  /* CODIGO IDENTIFICADOR */
               FILL(" ",17)             FORMAT "x(17)"  /* FILLER (diminuido para 17) */
               IF   (crapcdb.vlcheque >= aux_vlchqmai) THEN
                    "030"
               ELSE "034"               FORMAT "x(3)"   /* TD */
               aux_nrseqarq             FORMAT "9999999999"
               SKIP.
        
           IF   LAST-OF(crapcdb.nrborder) THEN
                DO:
                    ASSIGN aux_nrseqarq = aux_nrseqarq + 1
                           ret_qtarquiv = ret_qtarquiv + 1.

                    PUT STREAM str_1
                        FILL("9",47)            FORMAT "x(47)" /* HEADER */
                        "CUS605"                               /* NOME   */
                        aux_cdcmpchq            FORMAT "999"   /* COMPE  */
                        "0001"                                 /* VERS   */
                        crapcop.cdbcoctl        FORMAT "999"   /* BANCO  */ 
                        crapcop.nrdivctl        FORMAT "9"     /* DV     */
                        "1"                                    /* Ind. Rem. */
                        YEAR(par_dtmvtolt)      FORMAT "9999"  /* DATA FORM */
                        MONTH(par_dtmvtolt)     FORMAT "99"    /* YYYYMMDD*/
                        DAY(par_dtmvtolt)       FORMAT "99"
                        (aux_totvldsc * 100)    FORMAT "99999999999999999"
                        FILL(" ",60)            FORMAT "x(60)" /* FILLER */
                        aux_nrseqarq            FORMAT "9999999999"  /* SEQ */
                        SKIP.
    
                    OUTPUT STREAM str_1 CLOSE.

                    /* tratamento para verificar o operador esta na forca 
                       tarefa da viacredi */
                    IF   par_cdcooper = 1  THEN
                         DO:
                             aux_match = "*#".
                             aux_match = aux_match + par_cdoperad.
                             aux_match = aux_match + "|*".

                             /*registro de operadorese destinos especificos
                              para digitalização*/
                             FIND craptab WHERE 
                                  craptab.cdcooper = par_cdcooper   AND
                                  craptab.nmsistem = "CRED"         AND
                                  craptab.tptabela = "GENERI"       AND
                                  craptab.cdempres = 0              AND
                                  craptab.cdacesso = "OPEDIGITEXC"  AND
                                  craptab.tpregist = 0              AND
                                  craptab.dstextab MATCHES (aux_match)
                                  NO-LOCK NO-ERROR.
                                
                             ASSIGN aux_dsdirmic = "".

                             IF   AVAILABLE craptab THEN
                                 DO:
                                     ASSIGN aux_postext = INDEX(craptab.dstextab,"#" +
                                                          par_cdoperad ).
                                     /*verificar se o cdoperad esta 
                                       cadastrado na tab*/
                                     IF  aux_postext > 0  THEN
                                     DO:
                                         /* extrair caminho da tab*/
                                         ASSIGN aux_dsdirmic = 
                                                ENTRY(2,
                                                      ENTRY(1,SUBSTR(craptab.dstextab,aux_postext)
                                                           ,";")
                                                      ,"|")
                                                aux_dsdirmic =
                                                    SUBSTR(aux_dsdirmic,3,40)
                                                flg_fctarefa = TRUE.
                                     END.
                                 END.
                             
                         END.

                    IF   NOT flg_fctarefa  THEN
                         DO:
                             IF   aux_flcooper THEN
                                  aux_cdagenci = 1.
                             ELSE
                                  aux_cdagenci = par_cdagenci.
             
                             /*** BUSCA PASTA DE DESTINO **/
                             FIND craptab WHERE 
                                  craptab.cdcooper = par_cdcooper  AND
                                  craptab.nmsistem = "CRED"        AND
                                  craptab.tptabela = "GENERI"      AND
                                  craptab.cdempres = 0             AND
                                  craptab.cdacesso = "MICROCUSTOD" AND
                                  craptab.tpregist = par_cdagenci
                                  NO-LOCK NO-ERROR.

                             IF   NOT AVAILABLE craptab THEN
                                  aux_dsdirmic = "".
                             ELSE
                                  aux_dsdirmic = SUBSTR(craptab.dstextab,3,40).
                         END.

                    IF   aux_dsdirmic = "" THEN
                         DO:
                             ret_cdcritic = 782.
                             UNIX SILENT VALUE("rm " + aux_dscooper + "arq/" +
                                               aux_nmarqdat  + " 2>/dev/null").
                             UNDO TRANS_1, LEAVE.
                         END.

                    
                    /* Copia o arquivo para o micro que possui o scanner */
                    aux_dscomand =
                        "/usr/local/cecred/bin/EnviaArquivoTruncagem.sh " +
                        aux_dsdirmic + " " + "CUS " + "digit01 " +
                        "cecred.coop.br/digitalizar " + aux_nmarqdat + " " +
                        crapcop.dsdircop + " " + STRING(par_cdagenci,"9999") +
                        " 2>/dev/null".
                                                
                    INPUT THROUGH VALUE(aux_dscomand).

                    /*  Prever tratamento de Erro */
                    
                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        
                        IMPORT UNFORMATTED aux_retorno.
                        
                        IF   aux_retorno <> ""  THEN
                             LEAVE.
                    END.

                    IF   aux_retorno <> "" THEN
                         DO:
                             ret_cdcritic = 678.

                             UNIX SILENT VALUE("rm " + aux_dscooper + "arq/" +
                                         aux_nmarqdat  + " 2>/dev/null").
                             UNDO TRANS_1, LEAVE.
                         END.
                    ELSE
                         /* move para o salvar */
                         UNIX SILENT VALUE(
                              "mv " + aux_dscooper + "arq/"     +
                              aux_nmarqdat + " " + aux_dscooper +
                              "salvar/truncagem/" + aux_nmarqdat + "_"    +
                              STRING(TIME,"99999")              +
                              " 2>/dev/null").
                END.
       END.
    END.

    IF   ret_cdcritic > 0 THEN
         RETURN.
         
    DO  TRANSACTION ON ENDKEY UNDO, LEAVE:
        FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper AND
                               crapcdb.dtlibbdc = par_dtmvtolt AND
                               crapcdb.cdagenci = par_cdagenci AND
                               crapcdb.insitprv = 0            AND
                               crapcdb.nrborder = par_nrborder AND
                              (crapcdb.insitchq = 0            OR
                               crapcdb.insitchq = 2)
                               NO-LOCK: 
            
            DO aux_contador2 = 1 TO 10:

               FIND b-crapcdb WHERE RECID(b-crapcdb) = RECID(crapcdb)
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF NOT AVAILABLE b-crapcdb THEN
                   DO:
                      IF LOCKED b-crapcdb THEN
                         DO:
                            ret_cdcritic = 077.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                         END.
                   END.
               ELSE
                  ASSIGN b-crapcdb.insitprv = 1
                         b-crapcdb.dtprevia = TODAY
                         ret_cdcritic = 0.

               LEAVE.

            END. /* fim do contador */

            IF ret_cdcritic > 0 THEN
               RETURN.
            
        END. /* fim do for each */

    END. /* fim do TRANSACTION */

END PROCEDURE.



/* .......................................................................... */

PROCEDURE gerar_compel_prcctl:

   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdageini AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdagefim AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_nrdolote AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdbccxlt AS INT                               NO-UNDO.

   DEF OUTPUT PARAM ret_cdcritic AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_qtarquiv AS INT                               NO-UNDO. 
   DEF OUTPUT PARAM ret_totregis AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_vlrtotal AS DEC                               NO-UNDO.

   DEF VAR          aux_mes      AS CHAR                              NO-UNDO.
   DEF VAR          glb_nrcalcul AS DEC                               NO-UNDO.
   DEF VAR          glb_dsdctitg AS CHAR                              NO-UNDO.
   DEF VAR          glb_stsnrcal AS LOGICAL                           NO-UNDO.
   DEF VAR          aux_flgerror AS LOGICAL                           NO-UNDO.
   DEF VAR          aux_nrseqarq AS INT                               NO-UNDO.
   DEF VAR          aux_nmarqdat AS CHAR   FORMAT "x(20)"             NO-UNDO.
   DEF VAR          aux_totqtchq AS INT                               NO-UNDO.
   DEF VAR          aux_totvlchq AS DECIMAL                           NO-UNDO.
   DEF VAR          aux_totvlchq_valida AS DECIMAL                    NO-UNDO.
   DEF VAR          aux_cdsituac AS INT                               NO-UNDO.
   DEF VAR          aux_nrdahora AS INT                               NO-UNDO.
   DEF VAR          aux_cdcomchq AS INT                               NO-UNDO.
   DEF VAR          aux_cdagedst LIKE crapchd.cdagedst                NO-UNDO.
   DEF VAR          aux_flgdepin AS LOGICAL                           NO-UNDO.
   DEF VAR          aux_nrdconta LIKE crapchd.nrdconta                NO-UNDO.

   DEF VAR          aux_nrprevia AS INT    INIT 0                     NO-UNDO.
   DEF VAR          aux_hrprevia AS INT    INIT 0                     NO-UNDO.
   DEF VAR          aux_exetrunc AS LOGI   INIT NO                    NO-UNDO.
   DEF VAR          aux_dschqctl AS CHAR                              NO-UNDO.
   DEF VAR          aux_contador AS INTE                              NO-UNDO.

   DEF VAR          aux_cdcopant AS INTE NO-UNDO.

   DEF BUFFER b-gncpchq FOR gncpchq.
   ASSIGN aux_flgerror = FALSE.

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcop THEN
        DO:
            ret_cdcritic = 651.
            RUN fontes/critic.p.
            RETURN.
        END.

   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

   /* Remove os arquivos temporarios */
   UNIX SILENT VALUE("rm " + aux_dscooper + "arq/1*.* 2>/dev/null").

   FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                      craptab.nmsistem = "CRED"        AND
                      craptab.tptabela = "USUARI"      AND
                      craptab.cdempres = 11            AND
                      craptab.cdacesso = "MAIORESCHQ"  AND
                      craptab.tpregist = 01 NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            ret_cdcritic = 55.
            RETURN.
        END.

   FOR EACH crapchd WHERE crapchd.cdcooper  = par_cdcooper       AND
                          crapchd.dtmvtolt  = par_dtmvtolt       AND
                          crapchd.cdagenci >= par_cdageini       AND
                          crapchd.cdagenci <= par_cdagefim       AND
                          CAN-DO("0,2",STRING(crapchd.insitchq)) NO-LOCK,
       EACH crapage WHERE crapage.cdcooper  = crapchd.cdcooper   AND
                          crapage.cdagenci  = crapchd.cdagenci   AND
                          crapage.cdbanchq  = crapcop.cdbcoctl
                          NO-LOCK BREAK BY crapchd.cdagenci:

       IF   FIRST-OF(crapchd.cdagenci)  THEN
            DO:

               /* Nome Arquivo definido por ABBC 1agenMDD.Nxx         */
               /* 1    - Fixo
                  agen - Cod Agen Central crapcop.cdagectl
                  M    - Mes Movim.(1-9 = Jan-Set) O=Out N=Nov D=Dez
                  xxx   - Numero do PAC                               */

               IF   MONTH(crapchd.dtmvtolt) > 9 THEN
                    CASE MONTH(crapchd.dtmvtolt):
                         WHEN 10 THEN aux_mes = "O".
                         WHEN 11 THEN aux_mes = "N".
                         WHEN 12 THEN aux_mes = "D".
                    END CASE.
               ELSE
                    aux_mes = STRING(MONTH(crapchd.dtmvtolt),"9").    

               ASSIGN aux_nrseqarq = 1
                      aux_nmarqdat = "1"                         +
                              STRING(crapcop.cdagectl,"9999")    +
                              aux_mes                            + 
                              STRING(DAY(crapchd.dtmvtolt),"99") +
                              "."                                +
                              STRING(crapchd.cdagenci, "999").

               IF   SEARCH(aux_dscooper + "arq/" + aux_nmarqdat) <> ? THEN
                    DO:
                        BELL.
                        HIDE MESSAGE NO-PAUSE.
                        MESSAGE "Arquivo ja existe:" aux_nmarqdat.
                        ret_cdcritic = 459.
                        aux_flgerror = TRUE.
                        LEAVE.
                    END.

               OUTPUT STREAM str_1 TO VALUE(aux_dscooper + "arq/" +
                                            aux_nmarqdat).

               PUT STREAM str_1  FILL("0",47)         FORMAT "x(47)"
                                 "CEL605"                           /* NOME   */
                                 crapage.cdcomchq     FORMAT "999"  /* COMPE  */
                                 "0001"                             /* VERSAO */
                                 crapcop.cdbcoctl     FORMAT "999"  /* BANCO */
                                 crapcop.nrdivctl     FORMAT "9"    /* DV    */
                                 "2"                           /* Ind. Remes */
                                 YEAR(par_dtmvtolt)   FORMAT "9999" /* DATA */
                                 MONTH(par_dtmvtolt)  FORMAT "99"   /*YYYYMMDD*/
                                 DAY(par_dtmvtolt)    FORMAT "99"
                                 FILL(" ",77)         FORMAT "x(77)"
                                 aux_nrseqarq         FORMAT "9999999999"
                                 SKIP.

               ASSIGN aux_totqtchq = 0
                      aux_totvlchq = 0
                      aux_totvlchq_valida = 0.

            END.  /*  Fim  do  FIRST-OF()  */

       ASSIGN aux_nrseqarq = aux_nrseqarq + 1.

       /*  Identifica se o cheque eh da propria cooperativa  */
       
       FIND crapfdc WHERE crapfdc.cdcooper = crapchd.cdcooper AND
                          crapfdc.cdbanchq = crapchd.cdbanchq AND
                          crapfdc.cdagechq = crapchd.cdagechq AND
                          crapfdc.nrctachq = crapchd.nrctachq AND
                          crapfdc.nrcheque = crapchd.nrcheque
                          USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
       
       IF   AVAILABLE crapfdc THEN
            ASSIGN aux_dschqctl = "PG_CX ".
       ELSE
            DO:
                IF   (crapchd.cdcooper = 1  OR    /* Tratamento VIACREDI */
                      crapchd.cdcooper = 16) AND  /* Tratamento ALTOVALE */
                     /* Se o tamanho do nro da conta for maior que 8 entao
                        nao eh uma conta nossa */
                     LENGTH(STRING(crapchd.nrctachq)) <= 8 THEN
                     DO: 
                         IF crapchd.cdcooper = 1 THEN
                             aux_cdcopant = 2.
                         ELSE
                             aux_cdcopant = 1.
                         
                         FIND FIRST craptco WHERE 
                                            craptco.cdcopant = aux_cdcopant AND
                                            craptco.nrctaant = INTE(crapchd.nrctachq) AND
                                            craptco.tpctatrf  = 1           AND
                                            craptco.flgativo  = TRUE
                                            USE-INDEX craptco2
                                            NO-LOCK NO-ERROR.
                         
                         IF   AVAIL craptco  THEN
                              DO:
                                  FIND crapfdc WHERE 
                                       crapfdc.cdcooper = craptco.cdcopant AND
                                       crapfdc.cdbanchq = crapchd.cdbanchq AND
                                       crapfdc.cdagechq = crapchd.cdagechq AND
                                       crapfdc.nrctachq = crapchd.nrctachq AND
                                       crapfdc.nrcheque = crapchd.nrcheque
                                       USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                                  IF   AVAIL crapfdc THEN
                                       /* Para nao receber arquivo de retorno 
                                       na VIACREDI */ 
                                       ASSIGN aux_dschqctl = "PG_CX ".
                                                              ELSE
                                                                       ASSIGN aux_dschqctl = "      ".

                              END.
                         ELSE
                              ASSIGN aux_dschqctl = "      ".
                     END.
                ELSE
                     aux_dschqctl = "      ".
            END.
       
       IF   crapchd.cdagedst <> 0 THEN /* Deposito intercooperativa */
            ASSIGN aux_cdagedst = crapchd.cdagedst
                   aux_flgdepin = TRUE
                   aux_nrdconta = crapchd.nrctadst.
       ELSE
            ASSIGN aux_cdagedst = crapcop.cdagectl
                   aux_flgdepin = FALSE
                   aux_nrdconta = crapchd.nrdconta.

       PUT STREAM str_1  
           crapchd.cdcmpchq         FORMAT "999"    /* COMPE  */
           crapchd.cdbanchq         FORMAT "999"    /* BANCO DESTINO */
           crapchd.cdagechq         FORMAT "9999"   /* AGEN. DESTINO */
           crapchd.nrddigv2         FORMAT "9"      /* DV 2 */
           crapchd.nrctachq         FORMAT "999999999999" /* NR CONTA */
           crapchd.nrddigv1         FORMAT "9"      /* DV 1*/
           crapchd.nrcheque         FORMAT "999999" /* NR DOCTO */
           crapchd.nrddigv3         FORMAT "9"      /* DV 3 */
           "  "                     FORMAT "x(2)"   /* FILLER */
           (crapchd.vlcheque * 100) FORMAT "99999999999999999" /* VL CHQ*/
           crapchd.cdtipchq         FORMAT "9"      /* TIPIFICACAO */
           "1 "                     FORMAT "x(2)"   /* TIPO CTA */
           "00"                     FORMAT "x(2)"   /* FILLER */
           crapcop.cdbcoctl         FORMAT "999"
           crapcop.cdagectl         FORMAT "9999"
           aux_cdagedst             FORMAT "9999"
           aux_nrdconta             FORMAT "999999999999" /* NR CONTA DEPOS.*/
           crapage.cdcomchq         FORMAT "999"    /* COMPE  */
           YEAR(par_dtmvtolt)       FORMAT "9999"   /* DATA FORMATO */
           MONTH(par_dtmvtolt)      FORMAT "99"     /* YYYYMMDD*/
           DAY(par_dtmvtolt)        FORMAT "99"
           FILL("0",7)              FORMAT "x(7)"   /* NR LOTE*/
           FILL("0",3)              FORMAT "x(3)"   /* SEQ. LOTE*/ 
           aux_dschqctl             FORMAT "x(6)"
           /* Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0" */
           FILL("0",24) + "1"       FORMAT "x(25)"  /* CODIGO IDENTIFICADOR */
           FILL(" ",17)             FORMAT "x(17)"  /* FILLER (diminuido para 17) */
           IF (crapchd.vlcheque >= DECIMAL(SUBSTR(craptab.dstextab,01,15))) THEN
                "030"
           ELSE "034"               FORMAT "x(3)"   /* TIPO DE DOCUMENTO - TD */
           aux_nrseqarq             FORMAT "9999999999"
           SKIP.

       /* CRIACAO DA TABELA GENERICA - GNCPCHQ*/
       CREATE gncpchq.
       ASSIGN gncpchq.cdcooper = par_cdcooper
              gncpchq.cdagenci = crapchd.cdagenci
              gncpchq.dtmvtolt = par_dtmvtolt
              gncpchq.cdagectl = crapcop.cdagectl
              gncpchq.cdbanchq = crapchd.cdbanchq
              gncpchq.cdagechq = crapchd.cdagechq
              gncpchq.nrctachq = crapchd.nrctachq
              gncpchq.nrcheque = crapchd.nrcheque
              gncpchq.nrddigv2 = crapchd.nrddigv2
              gncpchq.cdcmpchq = crapchd.cdcmpchq
              gncpchq.cdtipchq = crapchd.cdtipchq
              gncpchq.nrddigv1 = crapchd.nrddigv1
              gncpchq.vlcheque = crapchd.vlcheque
              gncpchq.nrdconta = IF aux_flgdepin THEN 0 ELSE crapchd.nrdconta 
              gncpchq.nmarquiv = aux_nmarqdat
              gncpchq.cdoperad = par_cdoperad
              gncpchq.hrtransa = TIME
              gncpchq.cdtipreg = 1
              gncpchq.flgconci = NO
              gncpchq.nrseqarq = aux_nrseqarq
              gncpchq.cdcritic = 0
              gncpchq.cdalinea = 0
              gncpchq.flgpcctl = NO
              gncpchq.nrddigv3 = crapchd.nrddigv3
              gncpchq.cdtipdoc = IF crapchd.vlcheque >=
                                    DEC(SUBSTR(craptab.dstextab,01,15)) THEN
                                    30
                                 ELSE 34
              gncpchq.cdagedst = aux_cdagedst
              gncpchq.nrctadst = crapchd.nrctadst.
       VALIDATE gncpchq.

       /* Atualiza campo cdbcoenv da CHD - Inicio */
       
       DO aux_contador2 = 1 TO 10:

          FIND crabchd WHERE RECID(crabchd) = RECID(crapchd) 
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF NOT AVAILABLE crabchd THEN
             IF LOCKED crabchd THEN
                DO:
                    ret_cdcritic = 077.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
             ELSE
                 DO:
                     ret_cdcritic = 055.
                     RETURN "NOK".
                 END.    
          ELSE
             ASSIGN crabchd.cdbcoenv = crapcop.cdbcoctl
                    crabchd.flgenvio = TRUE
                    ret_cdcritic = 0. 

          RELEASE crabchd.
          LEAVE.

       END. /* fim do contador */

       IF ret_cdcritic > 0 THEN
          RETURN.

       /* Atualiza campo cdbcoenv da CHD - Fim */

       ASSIGN aux_totqtchq = aux_totqtchq + 1
              aux_totvlchq = aux_totvlchq + (crapchd.vlcheque * 100)
              aux_totvlchq_valida = aux_totvlchq_valida + crapchd.vlcheque.

       IF   ((crapchd.tpdmovto = 1) AND
             (DECIMAL(SUBSTR(craptab.dstextab,01,15)) > crapchd.vlcheque)) OR
            ((crapchd.tpdmovto = 2) AND
             (DECIMAL(SUBSTR(craptab.dstextab,01,15)) < crapchd.vlcheque)) THEN
             DO:
                  ret_cdcritic = 711.

                  IF aux_nmdatela = "PRCCTL" THEN
                     DO:
                         IF aux_flgdepin THEN
                            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                               " - Coop:" + STRING(par_cdcooper,"99") +
                               " - Processar:" + aux_nmprgexe +
                               " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                               " Parametro do cheque superior alterado" +
                               " Cheque: " + STRING(crapchd.nrcheque,"999999") +
                               " Agencia destino: " + STRING(crapchd.cdagedst) +
                               " Conta: " + STRING(crapchd.nrctadst,
                               "999999999999") + 
                               " >> " + aux_nmarqlog).
                         ELSE
                             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                   " - Coop:" + STRING(par_cdcooper,"99") +
                                   " - Processar:" + aux_nmprgexe +
                                   " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                                   " Parametro do cheque superior alterado" +
                                   " Cheque: " + STRING(crapchd.nrcheque,"999999") +
                                   " Conta: " + STRING(crapchd.nrdconta,
                                   "999999999999") + " >> " + aux_nmarqlog).
                     END.
                  ELSE
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                          " Parametro do cheque superior alterado" +
                          " Cheque: " + STRING(crapchd.nrcheque,"999999") +
                          " Conta: " + STRING(crapchd.nrdconta,
                          "999999999999") + " >> " + aux_dscooper +
                          "log/compel.log").

                  aux_flgerror = TRUE.
                  LEAVE.
             END.

       IF   LAST-OF(crapchd.cdagenci) THEN
            DO:
                ASSIGN ret_vlrtotal = ret_vlrtotal + aux_totvlchq
                       ret_qtarquiv = ret_qtarquiv + 1
                       aux_nrseqarq = aux_nrseqarq + 1.

                PUT STREAM str_1
                    FILL("9",47)            FORMAT "x(47)" /* HEADER */
                    "CEL605"                               /* NOME   */
                    crapage.cdcomchq        FORMAT "999"   /* COMPE  */
                    "0001"                                 /* VERS   */
                    crapcop.cdbcoctl        FORMAT "999"   /* BANCO  */ 
                    crapcop.nrdivctl        FORMAT "9"     /* DV     */
                    "2"                                    /* Ind. Rem. */
                    YEAR(par_dtmvtolt)      FORMAT "9999"  /* DATA FORMATO */
                    MONTH(par_dtmvtolt)     FORMAT "99"    /* YYYYMMDD*/
                    DAY(par_dtmvtolt)       FORMAT "99"
                    aux_totvlchq            FORMAT "99999999999999999"
                    FILL(" ",60)            FORMAT "x(60)" /* FILLER */
                    aux_nrseqarq            FORMAT "9999999999"  /* SEQUENCIA */
                    SKIP.

                OUTPUT STREAM str_1 CLOSE.

                /* Copia para o /micros */
                UNIX SILENT VALUE("ux2dos " + aux_dscooper + "arq/" + 
                                  aux_nmarqdat + ' | tr -d "\032"' + 
                                  " > /micros/" + crapcop.dsdircop + 
                                  "/abbc/" + aux_nmarqdat + " 2>/dev/null").

                /* move para o salvar */
                UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarqdat
                                  + " " + aux_dscooper + "salvar/" +
                                  aux_nmarqdat + "_" + STRING(TIME,"99999") + 
                                  " 2>/dev/null").

                RUN pi_alterar_situacao_arquivos (INPUT  crapchd.cdcooper,
                                                  INPUT  crapchd.cdagenci,
                                                  INPUT  "COMPEL",
                                                  INPUT  1,
                                                  INPUT  0,
                                                  OUTPUT ret_cdcritic).
                DO:

                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                   /* Efetuar a chamada a rotina Oracle  */
                   RUN STORED-PROCEDURE pc_checa_compel
                       aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper 
                                                           ,INPUT aux_nmarqdat
                                                           ,INPUT crapcop.cdagectl
                                                           ,INPUT crapchd.cdagenci
                                                           ,INPUT par_dtmvtolt
                                                           ,INPUT aux_totqtchq
                                                           ,INPUT aux_totvlchq_valida
                                                           ,OUTPUT 0
                                                           ,OUTPUT "").

                   /* Fechar o procedimento para buscarmos o resultado */ 
                   CLOSE STORED-PROC pc_checa_compel
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                  
                   ASSIGN aux_dscritic = ""
                          aux_dscritic = pc_checa_compel.pr_dscritic
                                         WHEN pc_checa_compel.pr_dscritic <> ?
                          aux_cdcritic = 0
                          aux_cdcritic = pc_checa_compel.pr_cdcritic
                                         WHEN pc_checa_compel.pr_cdcritic <> ?.

                END. /* execuçao comp0001.pc_checa_compel*/
            END.  /*  Fim do LAST-OF()  */

       HIDE MESSAGE NO-PAUSE.

   END.   /*  Fim do FOR EACH  */

   /*  Gravar na Tabela  */
   IF   NOT aux_flgerror THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

              /*  Atualiza se a compensacao foi rodada  */

              FOR EACH crapage WHERE crapage.cdcooper  = par_cdcooper     AND
                                     crapage.cdagenci >= par_cdageini     AND
                                     crapage.cdagenci <= par_cdagefim     AND
                                     crapage.cdbanchq  = crapcop.cdbcoctl
                                     NO-LOCK:

                  DO aux_contador = 1 TO 10:

                     FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                                        craptab.nmsistem = "CRED"        AND
                                        craptab.tptabela = "GENERI"      AND
                                        craptab.cdempres = 00            AND
                                        craptab.cdacesso = "HRTRCOMPEL"  AND
                                        craptab.tpregist = crapage.cdagenci
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                     IF   NOT AVAILABLE craptab   THEN
                          IF  LOCKED craptab   THEN
                              DO:
                                 ret_cdcritic = 77.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                              END.
                          ELSE
                              DO:
                                 ret_cdcritic = 55.
                                 LEAVE.
                              END.    
                     ELSE
                         ret_cdcritic = 0.

                     LEAVE.

                  END.  /*  Fim do DO .. TO  */

                  IF   ret_cdcritic > 0 THEN
                       RETURN.

                  ASSIGN aux_cdsituac = 1
                         aux_nrdahora = INT(SUBSTR(craptab.dstextab,3,5))

                         craptab.dstextab = STRING(aux_cdsituac,"9") + " " +
                                            STRING(aux_nrdahora,"99999").
                  RELEASE craptab.

              END.  /* for each crapage */

              IF   aux_nmdatela = "PRCCTL" THEN
                   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                           " - Coop:" + STRING(par_cdcooper,"99") +
                           " - Processar:" + aux_nmprgexe +
                           " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                           " - Valor total: " + 
                           STRING(ret_vlrtotal / 100,"zzz,zzz,zz9.99") +
                           " - Qtd. arquivos: " + STRING(ret_qtarquiv, "zzz9") +
                           " >> " + aux_nmarqlog).
              ELSE
                   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                           " - Valor total: " + 
                           STRING(ret_vlrtotal / 100,"zzz,zzz,zz9.99") +
                           " - Qtd. arquivos: " + STRING(ret_qtarquiv, "zzz9") +
                           " >> " + aux_dscooper + "log/compel.log").

            END. /* TRANSACTION */
        END.  /*  Fim do aux_flgerror  */
   ELSE
        /*  Caso haja algum problema na geracao do arquivo  */
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:
               
               FOR EACH gncpchq WHERE gncpchq.cdcooper =  par_cdcooper AND
                                      gncpchq.dtmvtolt =  par_dtmvtolt AND
                                      gncpchq.cdtipreg =  1            AND
                                      gncpchq.cdagenci >= par_cdageini AND
                                      gncpchq.cdagenci <= par_cdagefim
                                      NO-LOCK:
                      
                   DO aux_contador2 = 1 TO 10:
                   
                      FIND b-gncpchq WHERE RECID(b-gncpchq) = RECID(gncpchq)
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                   
                      IF NOT AVAILABLE b-gncpchq THEN
                         IF LOCKED b-gncpchq THEN
                            DO:
                                ret_cdcritic = 077.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                         ELSE
                            DO:
                               ret_cdcritic = 055.
                               RETURN "NOK".
                            END.    
                      ELSE
                         ret_cdcritic = 0.
                   
                      DELETE b-gncpchq.
                      LEAVE.
                   
                   END. /* fim do contador */

                   IF ret_cdcritic > 0 THEN
                      RETURN.
                       
               END. /* fim do for each */

            END.   /* TRANSACTION */

        END.

END PROCEDURE.


PROCEDURE gerar_compel_altoVale:

   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.

   DEF OUTPUT PARAM ret_cdcritic AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_qtarquiv AS INT                               NO-UNDO. 
   DEF OUTPUT PARAM ret_totregis AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_vlrtotal AS DEC                               NO-UNDO.

   DEF VAR          aux_mes      AS CHAR                              NO-UNDO.
   DEF VAR          glb_nrcalcul AS DEC                               NO-UNDO.
   DEF VAR          glb_dsdctitg AS CHAR                              NO-UNDO.
   DEF VAR          glb_stsnrcal AS LOGICAL                           NO-UNDO.
   DEF VAR          aux_flgerror AS LOGICAL                           NO-UNDO.
   DEF VAR          aux_nrseqarq AS INT                               NO-UNDO.
   DEF VAR          aux_nmarqdat AS CHAR   FORMAT "x(20)"             NO-UNDO.
   DEF VAR          aux_totqtchq AS INT                               NO-UNDO.
   DEF VAR          aux_totvlchq AS DECIMAL                           NO-UNDO.
   DEF VAR          aux_cdsituac AS INT                               NO-UNDO.
   DEF VAR          aux_nrdahora AS INT                               NO-UNDO.
   DEF VAR          aux_cdcomchq AS INT                               NO-UNDO.

   DEF VAR          aux_nrprevia AS INT    INIT 0                     NO-UNDO.
   DEF VAR          aux_hrprevia AS INT    INIT 0                     NO-UNDO.
   DEF VAR          aux_exetrunc AS LOGI   INIT NO                    NO-UNDO.
   DEF VAR          aux_dschqctl AS CHAR                              NO-UNDO.

   DEF VAR          aux_flgfirst AS LOGICAL                           NO-UNDO.
   
   ASSIGN aux_flgerror = FALSE.

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapcop THEN
        DO:
            ret_cdcritic = 651.
            RUN fontes/critic.p.
            RETURN.
        END.

   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

   /* Remove os arquivos temporarios */
   UNIX SILENT VALUE("rm " + aux_dscooper + "arq/1*.* 2>/dev/null").

   FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                      craptab.nmsistem = "CRED"        AND
                      craptab.tptabela = "USUARI"      AND
                      craptab.cdempres = 11            AND
                      craptab.cdacesso = "MAIORESCHQ"  AND
                      craptab.tpregist = 01 NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            ret_cdcritic = 55.
            RETURN.
        END.

   ASSIGN aux_contador = 0
          aux_flgfirst = TRUE.

   FOR EACH crapchd WHERE crapchd.cdcooper  = 1                  AND
                          crapchd.dtmvtolt  = par_dtmvtolt       AND
                          CAN-DO("0,2",STRING(crapchd.insitchq)) NO-LOCK:

       IF   crapchd.cdbccxlt <> 600   AND
            crapchd.cdbccxlt <> 700   THEN
            NEXT.
            
       IF   crapchd.cdbanchq <> 85    OR
            crapchd.cdagechq <> 101   THEN
            NEXT.

       FIND FIRST craptco WHERE craptco.cdcopant = crapchd.cdcooper      AND
                                craptco.nrctaant = INT(crapchd.nrctachq) AND
                                craptco.tpctatrf = 1                     AND
                                craptco.flgativo = TRUE
                                NO-LOCK NO-ERROR.
    
       IF   NOT AVAILABLE craptco THEN 
            NEXT.
       
       IF   aux_flgfirst  THEN
            DO:
                 aux_flgfirst = FALSE.
                 
                 /* Nome Arquivo definido por ABBC 1agenMDD.Nxx         */
                 /* 1    - Fixo
                    agen - Cod Agen Central crapcop.cdagectl
                    M    - Mes Movim.(1-9 = Jan-Set) O=Out N=Nov D=Dez
                    xxx   - Numero do PAC                               */

                 IF   MONTH(crapchd.dtmvtolt) > 9 THEN
                      CASE MONTH(crapchd.dtmvtolt):
                           WHEN 10 THEN aux_mes = "O".
                           WHEN 11 THEN aux_mes = "N".
                           WHEN 12 THEN aux_mes = "D".
                      END CASE.
                 ELSE
                      aux_mes = STRING(MONTH(crapchd.dtmvtolt),"9").    

                 ASSIGN aux_nrseqarq = 1
                        aux_nmarqdat = "1"                                +
                                       "0115"                             +
                                       aux_mes                            + 
                                       STRING(DAY(crapchd.dtmvtolt),"99") +
                                       "."                                +
                                       "099".

                 OUTPUT STREAM str_1 TO VALUE(aux_dscooper + "compel/" +
                                              aux_nmarqdat).
 
                 PUT STREAM str_1  
                            FILL("0",47)         FORMAT "x(47)"
                            "CEL605"                              /* NOME   */
                            "016"                                 /* COMPE  */
                            "0001"                                /* VERSAO */
                            crapcop.cdbcoctl     FORMAT "999"     /* BANCO */
                            crapcop.nrdivctl     FORMAT "9"       /* DV    */
                            "2"                                   /* Ind. Rem */
                            YEAR(par_dtmvtolt)   FORMAT "9999"    /* DATA */
                            MONTH(par_dtmvtolt)  FORMAT "99"      /*YYYYMMDD*/
                            DAY(par_dtmvtolt)    FORMAT "99"
                            FILL(" ",77)         FORMAT "x(77)"
                            aux_nrseqarq         FORMAT "9999999999"
                            SKIP.

                 ASSIGN aux_totqtchq = 0
                        aux_totvlchq = 0.
                                    
            END.  /*  Fim  do  FIRST-OF()  */

       ASSIGN aux_nrseqarq = aux_nrseqarq + 1
              aux_dschqctl = FILL(" ",6).
       
       PUT STREAM str_1  
                crapchd.cdcmpchq         FORMAT "999"    /* COMPE  */
                crapchd.cdbanchq         FORMAT "999"    /* BANCO DESTINO */
                crapchd.cdagechq         FORMAT "9999"   /* AGENCIA */
                crapchd.nrddigv2         FORMAT "9"      /* DV 2 */
                crapchd.nrctachq         FORMAT "999999999999" /* NR CONTA */
                crapchd.nrddigv1         FORMAT "9"      /* DV 1*/
                crapchd.nrcheque         FORMAT "999999" /* NR DOCTO */
                crapchd.nrddigv3         FORMAT "9"      /* DV 3 */
                "  "                     FORMAT "x(2)"   /* FILLER */
               (crapchd.vlcheque * 100)  FORMAT "99999999999999999" /* VL CHQ*/
                crapchd.cdtipchq         FORMAT "9"      /* TIPIFICACAO */
                "1 "                     FORMAT "x(2)"   /* TIPO CTA */
                "00"                     FORMAT "x(2)"   /* FILLER */
                crapcop.cdbcoctl         FORMAT "999"
                crapcop.cdagectl         FORMAT "9999"
                crapcop.cdagectl         FORMAT "9999"
                crapchd.nrdconta         FORMAT "999999999999" /* CONTA DEP.*/
                "016"                    FORMAT "999"    /* COMPE  */
                YEAR(par_dtmvtolt)       FORMAT "9999"   /* DATA FORMATO */
                MONTH(par_dtmvtolt)      FORMAT "99"     /* YYYYMMDD*/
                DAY(par_dtmvtolt)        FORMAT "99"
                FILL("0",7)              FORMAT "x(7)"   /* NR LOTE*/
                FILL("0",3)              FORMAT "x(3)"   /* SEQ. LOTE*/ 
                aux_dschqctl             FORMAT "x(6)"
                /* Adicionado o CODIGO IDENTIFICADOR, sempre "1" preenchido com "0" */
                FILL("0",24) + "1"   FORMAT "x(25)"  /* CODIGO IDENTIFICADOR */
                FILL(" ",17)         FORMAT "x(17)"  /* FILLER (diminuido para 17) */
                IF   (crapchd.vlcheque >= 
                      DEC(SUBSTR(craptab.dstextab,01,15))) THEN
                     "030"
                ELSE "034"               FORMAT "x(3)"   /* TIPO DE DOCUMENTO */
                aux_nrseqarq             FORMAT "9999999999"
                SKIP.
       
       
       /* CRIACAO DA TABELA GENERICA - GNCPCHQ*/
       CREATE gncpchq.
       ASSIGN gncpchq.cdcooper = 16
              gncpchq.cdagenci = crapchd.cdagenci
              gncpchq.dtmvtolt = par_dtmvtolt
              gncpchq.cdagectl = crapcop.cdagectl
              gncpchq.cdbanchq = crapchd.cdbanchq
              gncpchq.cdagechq = 0115
              gncpchq.nrctachq = crapchd.nrctachq
              gncpchq.nrcheque = crapchd.nrcheque
              gncpchq.nrddigv2 = crapchd.nrddigv2
              gncpchq.cdcmpchq = crapchd.cdcmpchq
              gncpchq.cdtipchq = crapchd.cdtipchq
              gncpchq.nrddigv1 = crapchd.nrddigv1
              gncpchq.vlcheque = crapchd.vlcheque
              gncpchq.nrdconta = crapchd.nrdconta
              gncpchq.nmarquiv = aux_nmarqdat
              gncpchq.cdoperad = par_cdoperad
              gncpchq.hrtransa = TIME
              gncpchq.cdtipreg = 1
              gncpchq.flgconci = NO
              gncpchq.nrseqarq = aux_nrseqarq
              gncpchq.cdcritic = 0
              gncpchq.cdalinea = 0
              gncpchq.flgpcctl = NO
              gncpchq.nrddigv3 = crapchd.nrddigv3.
              gncpchq.cdtipdoc = IF crapchd.vlcheque >=
                                     DEC(SUBSTR(craptab.dstextab,01,15)) THEN
                                          30
                                     ELSE 34.
       VALIDATE gncpchq.   

       /* Atualiza campo cdbcoenv da CHD - Fim */

       ASSIGN aux_totqtchq = aux_totqtchq + 1
              aux_totvlchq = aux_totvlchq + (crapchd.vlcheque * 100).

       IF   ((crapchd.tpdmovto = 1) AND
             (DEC(SUBSTR(craptab.dstextab,01,15)) > crapchd.vlcheque)) OR
            ((crapchd.tpdmovto = 2) AND
             (DEC(SUBSTR(craptab.dstextab,01,15)) < crapchd.vlcheque)) THEN
            DO:
                ret_cdcritic = 711.

                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                           " Parametro do cheque superior alterado" +
                           " Cheque: " + STRING(crapchd.nrcheque,"999999") +
                           " Conta: " + STRING(crapchd.nrdconta,
                           "999999999999") + " >> " + aux_dscooper +
                           "log/compel.log").

                aux_flgerror = TRUE.
                LEAVE.
            END.
        
   END.   /*  Fim do FOR EACH  */


   IF   aux_flgfirst = FALSE THEN
        DO:
            ASSIGN ret_vlrtotal = ret_vlrtotal + aux_totvlchq
                   ret_qtarquiv = ret_qtarquiv + 1
                   aux_nrseqarq = aux_nrseqarq + 1.

            PUT STREAM str_1
                       FILL("9",47)            FORMAT "x(47)" /* HEADER */
                       "CEL605"                               /* NOME   */
                       "016"                                  /* COMPE  */
                       "0001"                                 /* VERS   */
                       crapcop.cdbcoctl        FORMAT "999"   /* BANCO  */ 
                       crapcop.nrdivctl        FORMAT "9"     /* DV     */
                       "2"                                    /* Ind. Rem. */
                       YEAR(par_dtmvtolt)      FORMAT "9999"  
                       MONTH(par_dtmvtolt)     FORMAT "99"    /* YYYYMMDD*/
                       DAY(par_dtmvtolt)       FORMAT "99"
                       aux_totvlchq            FORMAT "99999999999999999"
                       FILL(" ",60)            FORMAT "x(60)" /* FILLER */
                       aux_nrseqarq            FORMAT "9999999999"  /* SEQ */
                       SKIP.

            OUTPUT STREAM str_1 CLOSE.

            /* Copia para o /micros */
            UNIX SILENT VALUE("ux2dos " + aux_dscooper + "compel/" + 
                              aux_nmarqdat + ' | tr -d "\032"' + 
                              " > /micros/" + crapcop.dsdircop + 
                              "/abbc/" + aux_nmarqdat + 
                              " 2>/dev/null").

            /* move para o salvar */
            UNIX SILENT VALUE("mv " + aux_dscooper + "compel/" +
                              aux_nmarqdat + " " + aux_dscooper +
                              "salvar/" + aux_nmarqdat + "_" +
                              STRING(TIME,"99999") + " 2>/dev/null").

        END.  /*  Fim do LAST-OF()  */

END PROCEDURE.
        
/*............................................................................*/

PROCEDURE gerar_tic604:

    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdageini AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdagefim AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM ret_cdcritic AS INT                               NO-UNDO.
    DEF OUTPUT PARAM ret_qtarquiv AS INT                               NO-UNDO. 
    DEF OUTPUT PARAM ret_totregis AS INT                               NO-UNDO.

    DEF VAR aux_mes      AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqdat AS CHAR   FORMAT "x(20)"                      NO-UNDO.
    DEF VAR glb_nrcalcul AS DEC                                        NO-UNDO.
    DEF VAR glb_dsdctitg AS CHAR                                       NO-UNDO.
    DEF VAR glb_stsnrcal AS LOGICAL                                    NO-UNDO.
    DEF VAR aux_nrseqarq AS INT                                        NO-UNDO.
    DEF VAR aux_contareg AS INT     INIT 0                             NO-UNDO.
    DEF VAR aux_nrseqdig AS INTE                                       NO-UNDO.
    DEF VAR aux_cdcomchq AS INT                                        NO-UNDO.
    DEF VAR aux_totvlchq AS DECI                                       NO-UNDO.
    DEF VAR aux_totdlote AS DECI                                       NO-UNDO.
    DEF VAR aux_dtlibera AS DATE                                       NO-UNDO.
    
    DEF BUFFER b-crapcst FOR crapcst.
    DEF BUFFER b-crapcdb FOR crapcdb.

    EMPTY TEMP-TABLE tt-custdesc.

    ASSIGN aux_totvlchq = 0
           aux_contador = 0.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
               NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop THEN
        DO:
          ret_cdcritic = 651.
          RUN fontes/critic.p.
          RETURN.

    END.

    /* Posiciona DAT */
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper
               NO-LOCK NO-ERROR.

    ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/"
           par_dtmvtolt = crapdat.dtmvtolt
           aux_dtlibera = calc_prox_tres_dia_uteis(par_dtmvtolt).

    /* Remove os arquivos temporarios */
    UNIX SILENT VALUE("rm " + aux_dscooper + "arq/TIC604*.* 2>/dev/null").


    /* Cheques - Custodia - Nao Enviados e Situacao 0 ou 2  - Inclusao */
    FOR EACH crapcst WHERE crapcst.cdcooper = par_cdcooper     AND
                           crapcst.dtmvtolt = crapdat.dtmvtoan AND
                           crapcst.nrborder = 0                
                           NO-LOCK:
        
        DO aux_contador2 = 1 TO 10:

           FIND b-crapcst WHERE RECID(b-crapcst) = RECID(crapcst)
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               
           IF NOT AVAILABLE b-crapcst THEN
              DO:
                 IF LOCKED b-crapcst THEN
                    DO:
                        ret_cdcritic = 077.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                 ELSE
                    DO:
                       ret_cdcritic = 055.
                       RETURN "NOK".
                    END.
              END.
           ELSE
              IF b-crapcst.dtenvtic = ?                 AND
                 b-crapcst.inchqcop = 0                 AND
                 b-crapcst.dtlibera >= aux_dtlibera     AND
                 b-crapcst.dtdevolu = ?                 AND
                (b-crapcst.insitchq = 0                 OR
                 b-crapcst.insitchq = 2)                THEN
                 DO:
                     FIND FIRST crapage WHERE crapage.cdcooper  = b-crapcst.cdcooper
                                          AND crapage.cdagenci  = b-crapcst.cdagenci
                                          AND crapage.cdbanchq  = crapcop.cdbcoctl
                                          NO-LOCK NO-ERROR.
                    
                     IF   AVAIL crapage THEN
                          aux_cdcomchq = crapage.cdcomchq.
                     ELSE
                          aux_cdcomchq = 16.
                    
                    
                     CREATE tt-custdesc.
                     ASSIGN tt-custdesc.cdcmpchq = b-crapcst.cdcmpchq
                            tt-custdesc.cdbanchq = b-crapcst.cdbanchq
                            tt-custdesc.cdagechq = b-crapcst.cdagechq
                            tt-custdesc.nrctachq = b-crapcst.nrctachq
                            tt-custdesc.nrcheque = b-crapcst.nrcheque
                            tt-custdesc.tpcptdoc = b-crapcst.tpcptdoc
                            tt-custdesc.cdbanapr = crapcop.cdbcoctl
                            tt-custdesc.cdageapr = crapcop.cdagectl
                            tt-custdesc.nrdconta = b-crapcst.nrdconta
                            tt-custdesc.cdcmpapr = aux_cdcomchq
                            tt-custdesc.dtlibera = b-crapcst.dtlibera
                            tt-custdesc.cdcmpori = aux_cdcomchq
                            tt-custdesc.dsdocmc7 = b-crapcst.dsdocmc7
                            tt-custdesc.vlcheque = b-crapcst.vlcheque
                            tt-custdesc.cdagedv2 = INT(SUBSTR(b-crapcst.dsdocmc7,9,1))
                            tt-custdesc.cdctadv1 = INT(SUBSTR(b-crapcst.dsdocmc7,22,1))
                            tt-custdesc.cdchqdv3 = INT(SUBSTR(b-crapcst.dsdocmc7,33,1))
                            tt-custdesc.dstipfic = SUBSTR(b-crapcst.dsdocmc7,20,1)
                            tt-custdesc.cdtpddoc = 960. /* TD INCLUSAO */
                    
                     ASSIGN aux_contador = aux_contador + 1
                            aux_totvlchq = aux_totvlchq + (b-crapcst.vlcheque * 100).
                    
                     /* Marcar CST como GERADO */
                     ASSIGN b-crapcst.dtenvtic = par_dtmvtolt
                            ret_cdcritic = 0.
                    
                 END.

           LEAVE.

        END. /* fim do contador */

        IF ret_cdcritic > 0 THEN
           RETURN.

    END. /* fim do for each */


    /* Cheques - Custodia - Ja Enviados e Situacao 1  - Exclusao */
    FOR EACH crapcst WHERE crapcst.cdcooper = par_cdcooper     AND
                           crapcst.dtdevolu = crapdat.dtmvtoan AND
                           crapcst.nrborder = 0
                            NO-LOCK:
         
        DO aux_contador2 = 1 TO 10:

           FIND b-crapcst WHERE RECID(b-crapcst) = RECID(crapcst)
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               
           IF NOT AVAILABLE b-crapcst THEN
              DO:
                 IF LOCKED b-crapcst THEN
                    DO:
                        ret_cdcritic = 077.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                 ELSE
                    DO:
                       ret_cdcritic = 055.
                       RETURN "NOK".
                    END.
              END.
           ELSE
              IF b-crapcst.dtenvtic <> ?                AND
                 b-crapcst.inchqcop = 0                 AND
                 b-crapcst.dtlibera >= aux_dtlibera     AND
                 b-crapcst.insitchq = 1                 THEN
                 DO:
                     FIND FIRST crapage WHERE crapage.cdcooper  = b-crapcst.cdcooper
                                          AND crapage.cdagenci  = b-crapcst.cdagenci
                                          AND crapage.cdbanchq  = crapcop.cdbcoctl
                                          NO-LOCK NO-ERROR.
             
                     IF   AVAIL crapage THEN
                          aux_cdcomchq = crapage.cdcomchq.
                     ELSE
                          aux_cdcomchq = 16.
             
                     CREATE tt-custdesc.
                     ASSIGN tt-custdesc.cdcmpchq = b-crapcst.cdcmpchq
                            tt-custdesc.cdbanchq = b-crapcst.cdbanchq
                            tt-custdesc.cdagechq = b-crapcst.cdagechq
                            tt-custdesc.nrctachq = b-crapcst.nrctachq
                            tt-custdesc.nrcheque = b-crapcst.nrcheque
                            tt-custdesc.tpcptdoc = b-crapcst.tpcptdoc
                            tt-custdesc.cdbanapr = crapcop.cdbcoctl
                            tt-custdesc.cdageapr = crapcop.cdagectl
                            tt-custdesc.cdcmpapr = aux_cdcomchq
                            tt-custdesc.cdcmpori = aux_cdcomchq
                            tt-custdesc.dsdocmc7 = b-crapcst.dsdocmc7
                            tt-custdesc.cdagedv2 = INT(SUBSTR(b-crapcst.dsdocmc7,9,1))
                            tt-custdesc.cdctadv1 = INT(SUBSTR(b-crapcst.dsdocmc7,22,1))
                            tt-custdesc.cdchqdv3 = INT(SUBSTR(b-crapcst.dsdocmc7,33,1))
                            tt-custdesc.dstipfic = SUBSTR(b-crapcst.dsdocmc7,20,1)
                            tt-custdesc.nrdconta = b-crapcst.nrdconta
                            tt-custdesc.dtlibera = b-crapcst.dtlibera
                            tt-custdesc.cdtpddoc = 966. /* TD EXCLUSAO */

                     IF  b-crapcst.vlchqant <> 0 THEN
                         ASSIGN tt-custdesc.vlcheque = b-crapcst.vlchqant.
                     ELSE
                         ASSIGN tt-custdesc.vlcheque = b-crapcst.vlcheque.
             
                     ASSIGN aux_contador = aux_contador + 1
                            aux_totvlchq = aux_totvlchq + (b-crapcst.vlcheque * 100).
             
                      /* Marcar CST como GERADO */
                     ASSIGN b-crapcst.dtenvtic = par_dtmvtolt.

                 END.

           ASSIGN ret_cdcritic = 0.
           LEAVE.

        END. /* fim do contador */

        IF ret_cdcritic > 0 THEN
           RETURN.

    END. /* fim do for each */
    

    /* Cheques - Desconto - Nao Enviados - Situacao 0 ou 2 - INCLUSAO */
    FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper     AND
                           crapcdb.dtmvtolt = crapdat.dtmvtoan
                           NO-LOCK:
        
        DO aux_contador2 = 1 TO 10:

           FIND b-crapcdb WHERE RECID(b-crapcdb) = RECID(crapcdb)
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE b-crapcdb THEN
              DO:
                 IF LOCKED b-crapcdb THEN
                    DO:
                       ret_cdcritic = 077.
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                    END.
              END.
           ELSE
              IF b-crapcdb.dtenvtic = ?                 AND
                 b-crapcdb.inchqcop = 0                 AND
                 b-crapcdb.dtlibera >= aux_dtlibera     AND
                 b-crapcdb.dtdevolu = ?                 AND
                 b-crapcdb.dtlibbdc <> ?                AND
                (b-crapcdb.insitchq = 0                 OR
                 b-crapcdb.insitchq = 2)                THEN
                 DO:
                     FIND FIRST crapage WHERE crapage.cdcooper = b-crapcdb.cdcooper
                                          AND crapage.cdagenci = b-crapcdb.cdagenci
                                          AND crapage.cdbanchq = crapcop.cdbcoctl
                                          NO-LOCK NO-ERROR.

                     IF   AVAIL crapage THEN
                          aux_cdcomchq = crapage.cdcomchq.
                     ELSE
                          aux_cdcomchq = 16.

                     CREATE tt-custdesc.
                     ASSIGN tt-custdesc.cdcmpchq = b-crapcdb.cdcmpchq
                            tt-custdesc.cdbanchq = b-crapcdb.cdbanchq
                            tt-custdesc.cdagechq = b-crapcdb.cdagechq
                            tt-custdesc.nrctachq = b-crapcdb.nrctachq
                            tt-custdesc.nrcheque = b-crapcdb.nrcheque
                            tt-custdesc.tpcptdoc = b-crapcdb.tpcptdoc
                            tt-custdesc.cdbanapr = crapcop.cdbcoctl
                            tt-custdesc.cdageapr = crapcop.cdagectl
                            tt-custdesc.nrdconta = b-crapcdb.nrdconta
                            tt-custdesc.cdcmpapr = aux_cdcomchq
                            tt-custdesc.dtlibera = b-crapcdb.dtlibera
                            tt-custdesc.cdcmpori = aux_cdcomchq
                            tt-custdesc.dsdocmc7 = b-crapcdb.dsdocmc7
                            tt-custdesc.vlcheque = b-crapcdb.vlcheque
                            tt-custdesc.cdagedv2 = INT(SUBSTR(b-crapcdb.dsdocmc7,9,1))
                            tt-custdesc.cdctadv1 = 
                                               INT(SUBSTR(b-crapcdb.dsdocmc7,22,1))
                            tt-custdesc.cdchqdv3 = 
                                               INT(SUBSTR(b-crapcdb.dsdocmc7,33,1))
                            tt-custdesc.dstipfic = SUBSTR(b-crapcdb.dsdocmc7,20,1)
                            tt-custdesc.cdtpddoc = 960. /* INCLUSAO */
                   
                     ASSIGN aux_contador = aux_contador + 1
                            aux_totvlchq = aux_totvlchq + (b-crapcdb.vlcheque * 100).
                   
                     /* Marcar CST como GERADO */
                     ASSIGN b-crapcdb.dtenvtic = par_dtmvtolt.

                 END.

           ASSIGN ret_cdcritic = 0.
           LEAVE.

        END. /* fim do contador */

        IF ret_cdcritic > 0 THEN
           RETURN.

    END. /* fim do for each */

    /* Cheques - Desconto - Ja Enviados - Situacao 1 - EXCLUSAO */
    FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper     AND
                           crapcdb.dtdevolu = crapdat.dtmvtoan
                           NO-LOCK:
        
        DO aux_contador2 = 1 TO 10:

           FIND b-crapcdb WHERE RECID(b-crapcdb) = RECID(crapcdb)
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE b-crapcdb THEN
              DO:
                 IF LOCKED b-crapcdb THEN
                    DO:
                       ret_cdcritic = 077.
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                    END.
              END.
           ELSE
               IF b-crapcdb.dtenvtic <> ?                AND
                  b-crapcdb.inchqcop = 0                 AND
                  b-crapcdb.dtlibera >= aux_dtlibera     AND
                  b-crapcdb.dtlibbdc <> ?                AND
                  b-crapcdb.insitchq = 1                 THEN
                  DO:
                      FIND FIRST crapage WHERE crapage.cdcooper  = b-crapcdb.cdcooper
                                           AND crapage.cdagenci  = b-crapcdb.cdagenci
                                           AND crapage.cdbanchq  = crapcop.cdbcoctl
                                           NO-LOCK NO-ERROR.

                      IF AVAIL crapage THEN
                         aux_cdcomchq = crapage.cdcomchq.
                      ELSE
                         aux_cdcomchq = 16.
                  
                      CREATE tt-custdesc.
                      ASSIGN tt-custdesc.cdcmpchq = b-crapcdb.cdcmpchq
                             tt-custdesc.cdbanchq = b-crapcdb.cdbanchq
                             tt-custdesc.cdagechq = b-crapcdb.cdagechq
                             tt-custdesc.nrctachq = b-crapcdb.nrctachq
                             tt-custdesc.nrcheque = b-crapcdb.nrcheque
                             tt-custdesc.tpcptdoc = b-crapcdb.tpcptdoc
                             tt-custdesc.cdbanapr = crapcop.cdbcoctl
                             tt-custdesc.cdageapr = crapcop.cdagectl
                             tt-custdesc.nrdconta = b-crapcdb.nrdconta
                             tt-custdesc.cdcmpapr = aux_cdcomchq
                             tt-custdesc.dtlibera = b-crapcdb.dtlibera
                             tt-custdesc.cdcmpori = aux_cdcomchq
                             tt-custdesc.dsdocmc7 = b-crapcdb.dsdocmc7
                             tt-custdesc.vlcheque = b-crapcdb.vlcheque
                             tt-custdesc.cdagedv2 = 
                                               INT(SUBSTR(b-crapcdb.dsdocmc7,9,1))
                             tt-custdesc.cdctadv1 = 
                                               INT(SUBSTR(b-crapcdb.dsdocmc7,22,1))
                             tt-custdesc.cdchqdv3 = 
                                               INT(SUBSTR(b-crapcdb.dsdocmc7,33,1))
                             tt-custdesc.dstipfic = SUBSTR(b-crapcdb.dsdocmc7,20,1)
                             tt-custdesc.cdtpddoc = 966. /* EXCLUSAO */
                  
                      IF   b-crapcdb.vlchqant <> 0 THEN
                           ASSIGN tt-custdesc.vlcheque = b-crapcdb.vlchqant.
                      ELSE
                           ASSIGN tt-custdesc.vlcheque = b-crapcdb.vlcheque.
                  
                      ASSIGN aux_contador = aux_contador + 1
                             aux_totvlchq = aux_totvlchq + (b-crapcdb.vlcheque * 100).
                  
                      /* Marcfar CST como GERADO */
                      ASSIGN b-crapcdb.dtenvtic = par_dtmvtolt.

                  END. 

           ASSIGN ret_cdcritic = 0.
           LEAVE.

        END. /* fim do contador */ 

        IF ret_cdcritic > 0 THEN
           RETURN.

    END. /* fim do for each */

    /* Nao existem cheques em custodia */
    IF   aux_contador = 0 THEN 
         RETURN.

    IF   MONTH(par_dtmvtolt) > 9 THEN
         CASE MONTH(par_dtmvtolt):

              WHEN 10 THEN aux_mes = "O".
              WHEN 11 THEN aux_mes = "N".
              WHEN 12 THEN aux_mes = "D".

         END CASE.
    ELSE
         aux_mes = STRING(MONTH(par_dtmvtolt),"9").

        
    /* Nome do Arquivo */
    ASSIGN aux_nmarqdat = "1" + STRING(crapcop.cdagectl,"9999") +
                           aux_mes + STRING(DAY(par_dtmvtolt),"99") + ".CNN".

    ASSIGN aux_vltotarq = 0 
           aux_nrseqarq = 1
           ret_qtarquiv = 1
           ret_totregis = aux_contador.
                    
    IF  SEARCH(aux_dscooper + "arq/" + aux_nmarqdat) <> ? THEN
        DO:
            BELL.
            HIDE MESSAGE NO-PAUSE.
            /*
            MESSAGE "Arquivo ja existe: " + aux_dscooper 
                 + "arq/" aux_nmarqdat.
            */     
            ret_cdcritic = 459.
            RETURN.
        END.

    IF  ret_cdcritic > 0   THEN
        RETURN.

    OUTPUT STREAM str_1 TO VALUE(TRIM(aux_dscooper + "arq/" + aux_nmarqdat)).

    /* Geracao do HEADER */
    PUT STREAM str_1
        FILL("0",47)         FORMAT "x(47)"       /* CONTROLE DO HEADER */
        "TIC604"                                  /* NOME   */
        "018"
        crapcop.cdagectl     FORMAT "9999"        /* VERSAO */
        crapcop.cdbcoctl     FORMAT "999"         /* BANCO  */
        " "                                       /* BRANCO  */  
        "1"                                       /* Ind. Remes */
        YEAR(par_dtmvtolt)   FORMAT "9999"        /* DATA FORMATO */
        MONTH(par_dtmvtolt)  FORMAT "99"          /* YYYYMMDD*/
        DAY(par_dtmvtolt)    FORMAT "99"
        FILL(" ",77)         FORMAT "x(77)"       /* FILLER BRANCO */
        aux_nrseqarq         FORMAT "9999999999"  /* SEQUENCIAL 1 */
        FILL(" ",40)         FORMAT "x(40)"       /* FILLER BRANCO */
        SKIP.

    /** GERACAO DETALHES ARQUIVO */
    FOR EACH tt-custdesc NO-LOCK
             BREAK BY tt-custdesc.cdcmpchq
                      BY tt-custdesc.cdbanchq
                         BY tt-custdesc.cdtpddoc:

        ASSIGN aux_nrseqarq = aux_nrseqarq + 1
               aux_contareg = aux_contareg + 1
               aux_totdlote = aux_totdlote + tt-custdesc.vlcheque.

        PUT STREAM str_1
            tt-custdesc.cdcmpchq         FORMAT "999"     /* LOCAL DESTINO */
            tt-custdesc.cdbanchq         FORMAT "999"     /* BCO DESTINO   */
            tt-custdesc.cdagechq         FORMAT "9999"    /* AGE DESTINO   */
            tt-custdesc.cdagedv2         FORMAT "9"       /* DV2*/
            tt-custdesc.nrctachq         FORMAT "999999999999"
            tt-custdesc.cdctadv1         FORMAT "9"       /* DV1 */
            tt-custdesc.nrcheque         FORMAT "999999"
            tt-custdesc.cdchqdv3         FORMAT "9"       /* DV3 */
            crapcop.cdufdcop             FORMAT "x(2)"
            (tt-custdesc.vlcheque * 100) FORMAT "99999999999999999" /* VALOR */
            tt-custdesc.dstipfic         FORMAT "x(1)"    /* TIPIFICACAO */
            "    "                       FORMAT "x(4)"    /* BRANCOS */
            tt-custdesc.cdbanapr         FORMAT "999"     /* BCO APRES */
            tt-custdesc.cdageapr         FORMAT "9999"    /* AGE APRES */
            tt-custdesc.cdageapr         FORMAT "9999"    /* AGE DEPOS */
            tt-custdesc.nrdconta         FORMAT "999999999999"
            tt-custdesc.cdcmpapr         FORMAT "999"     /* LOCAL ACOLHIM */
            YEAR(par_dtmvtolt)           FORMAT "9999"    /* DATA FORMATO */
            MONTH(par_dtmvtolt)          FORMAT "99"         /* YYYYMMDD*/
            DAY(par_dtmvtolt)            FORMAT "99"
            "0000001"                    FORMAT "x(7)"    /* LOTE */
            "001"                        FORMAT "x(3)"    /* SEQ LOTE */
            "000000"                     FORMAT "x(6)"    /* CTR PROCES */
            FILL("0",25)                 FORMAT "x(25)"   /* Nr IDENTIFIC */
            YEAR(tt-custdesc.dtlibera)   FORMAT "9999"    /* DATA FORMATO */
            MONTH(tt-custdesc.dtlibera)  FORMAT "99"         /* YYYYMMDD*/
            DAY(tt-custdesc.dtlibera)    FORMAT "99"         /* DATA BOA*/
            "  "                         FORMAT "x(2)"    /* BRANCO */
            "018"
            crapcop.cdagectl             FORMAT "9999"    /* VERSAO */
            tt-custdesc.cdtpddoc         FORMAT "999"     /* TP DOCMTO */
            aux_nrseqarq                 FORMAT "9999999999"
            FILL(" ",40)                 FORMAT "x(40)"
            SKIP.

        /* CRIACAO DA TABELA GENERICA - GNCPTIC*/
        CREATE gncptic.
        ASSIGN gncptic.cdcooper = par_cdcooper
               gncptic.dttransa = par_dtmvtolt
               gncptic.cdtipreg = 1 /* NOSSA REMESSA */
               gncptic.cdtipdoc = tt-custdesc.cdtpddoc
               gncptic.cdagenci = tt-custdesc.cdageapr
               gncptic.dsdocmc7 = tt-custdesc.dsdocmc7
               gncptic.cdocorre = 0
               gncptic.hrtransa = TIME
               gncptic.nrdconta = tt-custdesc.nrdconta
               gncptic.cdcmpchq = tt-custdesc.cdcmpchq
               gncptic.cdbanchq = tt-custdesc.cdbanchq
               gncptic.cdagechq = tt-custdesc.cdagechq
               gncptic.nrctachq = tt-custdesc.nrctachq
               gncptic.nrcheque = tt-custdesc.nrcheque
               gncptic.vlcheque = tt-custdesc.vlcheque.
        VALIDATE gncptic.

        IF  aux_contareg >= 400 THEN 
            DO:
                 ASSIGN aux_contareg = 0
                        aux_nrseqarq = aux_nrseqarq + 1.
    
                 /* Fechamento*/
                 PUT STREAM str_1
                     "018"
                     STRING(tt-custdesc.cdbanchq,"999")      FORMAT "x(3)"
                     FILL("9",27)                            FORMAT "X(27)"
                     (aux_totdlote * 100) FORMAT "99999999999999999"
                     FILL(" ",5)                             FORMAT "X(5)"
                     STRING(tt-custdesc.cdbanapr,"999")      FORMAT "x(3)"
                     FILL(" ",23)                            FORMAT "X(23)"
                     YEAR(par_dtmvtolt)   FORMAT "9999"    /* DATA FORMATO */
                     MONTH(par_dtmvtolt)  FORMAT "99"         /* YYYYMMDD*/
                     DAY(par_dtmvtolt)    FORMAT "99"
                     "0000001"                               FORMAT "x(7)"    
                     "999"                                   FORMAT "x(3)"    
                     "000000"                                FORMAT "x(6)"    
                     FILL(" ",35)                            FORMAT "x(35)"
                     "018"
                     STRING(crapcop.cdagectl,"9999")         FORMAT "x(4)"
                     STRING(tt-custdesc.cdtpddoc,"999")      FORMAT "x(3)"
                     STRING(aux_nrseqarq,"9999999999")       FORMAT "x(10)"
                     FILL(" ",40)                            FORMAT "x(40)"
                     SKIP.

                 ASSIGN aux_totdlote = 0.
                 
                 NEXT.
       END.
       
       IF   LAST-OF(tt-custdesc.cdcmpchq) OR 
            LAST-OF(tt-custdesc.cdbanchq) OR 
            LAST-OF(tt-custdesc.cdtpddoc) THEN 
            DO:
                ASSIGN aux_contareg = 0
                       aux_nrseqarq = aux_nrseqarq + 1.
    
                /* Fechamento*/
                PUT STREAM str_1
                     "018"
                     STRING(tt-custdesc.cdbanchq,"999")      FORMAT "x(3)"
                     FILL("9",27)                            FORMAT "X(27)"
                     (aux_totdlote * 100) FORMAT "99999999999999999"
                     FILL(" ",5)                             FORMAT "X(5)"
                     STRING(tt-custdesc.cdbanapr,"999")      FORMAT "x(3)"
                     FILL(" ",23)                            FORMAT "X(23)"
                     YEAR(par_dtmvtolt)   FORMAT "9999"    /* DATA FORMATO */
                     MONTH(par_dtmvtolt)  FORMAT "99"         /* YYYYMMDD*/
                     DAY(par_dtmvtolt)    FORMAT "99"
                     "0000001"                               FORMAT "x(7)"    
                     "999"                                   FORMAT "x(3)"    
                     "000000"                                FORMAT "x(6)"    
                     FILL(" ",35)                            FORMAT "x(35)"
                     "018"
                     STRING(crapcop.cdagectl,"9999")         FORMAT "x(4)"
                     STRING(tt-custdesc.cdtpddoc,"999")      FORMAT "x(3)"
                     STRING(aux_nrseqarq,"9999999999")       FORMAT "x(10)"
                     FILL(" ",40)                            FORMAT "x(40)"
                     SKIP.
       
                ASSIGN aux_totdlote = 0.
            END.
       

       IF   aux_nrseqdig > 999  THEN
            ASSIGN aux_nrseqdig = 1.

    END.  /*  Fim do FOR EACH -- tt-custdesc */


    /* Geracao do TRAILER */
    ASSIGN aux_nrseqarq = aux_nrseqarq + 1.

    PUT STREAM str_1
        FILL("9",47)         FORMAT "x(47)"       /* CONTROLE DO HEADER */
        "TIC604"                                  /* NOME   */
        "018"
        crapcop.cdagectl     FORMAT "9999"        /* VERSAO */
        crapcop.cdbcoctl     FORMAT "999"         /* BANCO  */
        " "                                       /* BRANCO  */  
        "1"                                       /* Ind. Remes */
        YEAR(par_dtmvtolt)   FORMAT "9999"        /* DATA FORMATO */
        MONTH(par_dtmvtolt)  FORMAT "99"             /* YYYYMMDD*/
        DAY(par_dtmvtolt)    FORMAT "99"
        aux_totvlchq         FORMAT "99999999999999999" /* TOTAL VALOR CHQ */
        FILL(" ",60)         FORMAT "x(60)"       /* FILLER BRANCO */
        aux_nrseqarq         FORMAT "9999999999"  /* SEQUENCIAL */
        FILL(" ",40)         FORMAT "x(40)"       /* FILLER BRANCO */
        SKIP.


    OUTPUT STREAM str_1 CLOSE.

    /* Copia para o /micros */
    UNIX SILENT VALUE("ux2dos " + aux_dscooper + "arq/" + 
                      aux_nmarqdat + ' | tr -d "\032"' + 
                      " > /micros/" + crapcop.dsdircop + 
                      "/abbc/" + aux_nmarqdat + " 2>/dev/null").

    /* move para o salvar */
    UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarqdat +
                      " " + aux_dscooper + "salvar/" +
                      aux_nmarqdat + "_" + STRING(TIME,"99999") + 
                      " 2>/dev/null").


    IF   aux_nmdatela = "PRCCTL" THEN
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                           " - Coop:" + STRING(par_cdcooper,"99") +
                           " - Processar:" + aux_nmprgexe +
                           " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                           " - Progr: " + STRING(ret_totregis,"zzz,zz9") +
                           " " + STRING(aux_totvlchq,"zzz,zzz,zz9.99") +
                           " >> " + aux_nmarqlog).
    ELSE
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - Ref.: " + STRING(par_dtmvtolt,"99/99/9999") +
                           " - Progr: " + STRING(ret_totregis,"zzz,zz9") +
                           " " + STRING(aux_totvlchq,"zzz,zzz,zz9.99") +
                           " >> " + aux_dscooper + "log/tic604.log").

END PROCEDURE.

/*............................................................................*/

PROCEDURE consultar_titulos:

    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdageini AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdagefim AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdbcoenv AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_flgenvio AS LOG                               NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-titulos.

    EMPTY TEMP-TABLE tt-titulos.
    
    CREATE tt-titulos.
    
    FOR EACH craptit WHERE (craptit.cdcooper = par_cdcooper     AND
                           craptit.dtdpagto  = par_dtmvtolt     AND 
                           craptit.tpdocmto  = 20               AND
                        (((craptit.cdagenci >= par_cdageini     AND
                           craptit.cdagenci <= par_cdagefim)    AND
                           craptit.cdagenci <> 90               AND
                           craptit.cdagenci <> 91)              OR
                           (craptit.cdagenci = 90               AND
                           par_cdageini      = 90)              OR
                          (craptit.cdagenci  = 91               AND
                           par_cdageini      = 91))             AND
                           craptit.intitcop  = 0                AND
                  CAN-DO(par_cdbcoenv,STRING(craptit.cdbcoenv)) AND
                            craptit.flgenvio  = par_flgenvio)    NO-LOCK, 
        EACH crapage WHERE crapage.cdcooper = craptit.cdcooper  AND
                           crapage.cdagenci = craptit.cdagenci  NO-LOCK:   

       IF   craptit.insittit = 4   THEN
            DO:
                ASSIGN tt-titulos.qttitcxa = tt-titulos.qttitcxa + 1
                       tt-titulos.vltitcxa = tt-titulos.vltitcxa +
                                               craptit.vldpagto.
                NEXT.
            END.

       ASSIGN tt-titulos.qttitrec = tt-titulos.qttitrec + 1
              tt-titulos.vltitrec = tt-titulos.vltitrec + craptit.vldpagto.
                    
       IF   craptit.insittit = 1   THEN
            ASSIGN tt-titulos.qttitrgt = tt-titulos.qttitrgt - 1
                   tt-titulos.vltitrgt = tt-titulos.vltitrgt -
                                           craptit.vldpagto.
       ELSE
       IF   CAN-DO("0,2",STRING(craptit.insittit))   THEN
            ASSIGN tt-titulos.qttitprg = tt-titulos.qttitprg + 1
                   tt-titulos.vltitprg = tt-titulos.vltitprg +
                                           craptit.vldpagto.
       ELSE      
       IF   craptit.insittit = 3   THEN
            ASSIGN tt-titulos.qttiterr = tt-titulos.qttiterr - 1
                   tt-titulos.vltiterr = tt-titulos.vltiterr -
                                           craptit.vldpagto.
                     
   END.  /*  Fim do FOR EACH  --  Leitura do craptit  */

   IF   tt-titulos.qttitprg <> (tt-titulos.qttitrec +
                                  tt-titulos.qttitrgt +
                                  tt-titulos.qttiterr)   OR
        tt-titulos.vltitprg <> (tt-titulos.vltitrec +
                                  tt-titulos.vltitrgt +
                                  tt-titulos.vltiterr)   THEN
        DO:
            MESSAGE "ERRO - Informe o CPD ==> Qtd: "
                    STRING(tt-titulos.qttitrec + tt-titulos.qttitrgt +
                                          tt-titulos.qttiterr,"zzz,zz9-")
                    " Valor: " 
                    STRING(tt-titulos.vltitrec + tt-titulos.vltitrgt +
                           tt-titulos.vltiterr,"zzz,zzz,zz9.99-") .
        END.
  
   ASSIGN tt-titulos.qttitulo = tt-titulos.qttitprg + tt-titulos.qttitcxa
          tt-titulos.vltitulo = tt-titulos.vltitprg + tt-titulos.vltitcxa.


END PROCEDURE.

/*............................................................................*/

PROCEDURE consultar_doctos:

    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdageini AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdagefim AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_cdbcoenv AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM par_flgenvio AS LOG                               NO-UNDO.
    DEF INPUT  PARAM par_flgtpdoc AS LOG                               NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-doctos.

    EMPTY TEMP-TABLE tt-doctos.
    
    FOR EACH  craptvl
       WHERE  craptvl.cdcooper  = par_cdcooper
         AND  craptvl.dtmvtolt  = par_dtmvtolt
         AND((par_flgtpdoc      = YES /* DOC */
         AND  craptvl.tpdoctrf <> 3)
          OR (par_flgtpdoc      = NO  /* TED */
         AND  craptvl.tpdoctrf  = 3))
         AND  craptvl.cdagenci >= par_cdageini
         AND  craptvl.cdagenci <= par_cdagefim
         AND CAN-DO(par_cdbcoenv,STRING(craptvl.cdbcoenv))
         AND  craptvl.flgenvio  = par_flgenvio NO-LOCK
          BY craptvl.cdagenci
          BY craptvl.nrdolote
          BY craptvl.vldocrcb.


        CREATE tt-doctos.
        ASSIGN tt-doctos.cdagenci = craptvl.cdagenci
               tt-doctos.cdbccxlt = craptvl.cdbccxlt
               tt-doctos.nrdolote = craptvl.nrdolote
               tt-doctos.nrdconta = craptvl.nrdconta
               tt-doctos.nrdocmto = craptvl.nrdocmto
               tt-doctos.vldocrcb = craptvl.vldocrcb.
    END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE consultar_devolu:

    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF OUTPUT PARAM ret_qtdevolv AS INT     INIT 0                    NO-UNDO.
    DEF OUTPUT PARAM ret_qtadevol AS INT     INIT 0                    NO-UNDO.


    FOR EACH crapdev
       WHERE crapdev.cdcooper = par_cdcooper NO-LOCK:

        CASE crapdev.indevarq:
            WHEN 1 THEN ret_qtdevolv = ret_qtdevolv + 1.
            WHEN 2 THEN ret_qtadevol = ret_qtadevol + 1.
        END CASE.
    END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE reativar_arquivos_cecred:

   DEF INPUT  PARAM par_nmprgexe AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdageini AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_flgtpdoc AS LOG                               NO-UNDO.
   DEF INPUT  PARAM par_doctos   AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_nmdatela AS CHAR                              NO-UNDO.
   DEF INPUT  PARAM par_nrprevia AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_nrdcaixa AS INT                               NO-UNDO.           
   DEF INPUT  PARAM par_cdbccxlt AS CHAR                              NO-UNDO.    
   DEF INPUT  PARAM par_tpdevolu AS CHAR                              NO-UNDO.

   DEF OUTPUT PARAM ret_cdcritic AS INTE                              NO-UNDO.

   DEF          VAR aux_cdagefim AS INT                               NO-UNDO.


   ASSIGN aux_nmdatela = par_nmdatela
          aux_nmprgexe = par_nmprgexe
          aux_nmarqlog = "/usr/coop/cecred/log/prcctl_" +
                         STRING(YEAR(par_dtmvtolt),"9999") +
                         STRING(MONTH(par_dtmvtolt),"99") +
                         STRING(DAY(par_dtmvtolt),"99") + ".log".


   ASSIGN aux_cdagefim = IF par_cdageini = 0 
                         THEN 9999
                         ELSE par_cdageini.

   CASE par_nmprgexe:
       WHEN "COMPEL" THEN DO:
           
           IF par_nmdatela = "PRCCTL" THEN
               RUN reativar_compel_prcctl (INPUT  par_cdcooper,
                                           INPUT  par_dtmvtolt,
                                           INPUT  par_cdageini,
                                           INPUT  aux_cdagefim,
                                           OUTPUT ret_cdcritic).

           ELSE
               RUN reativar_compel (INPUT  par_cdcooper,
                                    INPUT  par_dtmvtolt,
                                    INPUT  par_cdageini,
                                    INPUT  par_nrprevia,
                                    INPUT  par_nrdcaixa, 
                                    INPUT  par_cdbccxlt,
                                    OUTPUT ret_cdcritic).

           IF   RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
       END.

       WHEN "DOCTOS" THEN DO:
           RUN reativar_doctos (INPUT  par_cdcooper,
                                INPUT  par_dtmvtolt,
                                INPUT  par_cdageini,
                                INPUT  aux_cdagefim,
                                INPUT  par_flgtpdoc,
                                INPUT  par_doctos,
                                OUTPUT ret_cdcritic).

           IF RETURN-VALUE <> "OK" THEN
              RETURN "NOK".

       END.

       WHEN "TITULO" THEN DO:
           RUN reativar_titulos(INPUT  par_cdcooper,
                                INPUT  par_dtmvtolt,
                                INPUT  par_cdageini,
                                INPUT  aux_cdagefim,
                                OUTPUT ret_cdcritic).

           IF RETURN-VALUE <> "OK" THEN
              RETURN "NOK".

       END.

       WHEN "TIC" THEN DO:
           RUN reativar_tic604(INPUT  par_cdcooper,
                               INPUT  par_dtmvtolt,
                               OUTPUT ret_cdcritic).

           IF RETURN-VALUE <> "OK" THEN
              RETURN "NOK".

       END.

       WHEN "DEVOLU" THEN DO:
           RUN reativar_devolu_prcctl(INPUT  par_cdcooper,
                                      INPUT  par_dtmvtolt,
                                      INPUT  par_cdageini,
                                      INPUT  aux_cdagefim,
                                      INPUT  par_tpdevolu,
                                      OUTPUT ret_cdcritic).

           IF RETURN-VALUE <> "OK" THEN
              RETURN "NOK".

       END.

   END CASE.  

   RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE reativar_doctos:

   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdageini AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdagefim AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_flgtpdoc AS LOG                               NO-UNDO.
   DEF INPUT  PARAM par_doctos   AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_cdcritic AS INTE                              NO-UNDO.

   DEF   VAR  aux_cdcritic       AS INT                               NO-UNDO.

   FOR EACH craptvl WHERE craptvl.cdcooper = par_cdcooper     AND
                          craptvl.dtmvtolt = par_dtmvtolt     AND
                          craptvl.flgenvio = TRUE             AND  
                        ((par_flgtpdoc     = YES /* DOC */  AND 
                          craptvl.tpdoctrf <> 3)            OR
                         (par_flgtpdoc     = NO  /* TED */  AND
                          craptvl.tpdoctrf  = 3))           AND
                          craptvl.cdagenci >= par_cdageini  AND
                          craptvl.cdagenci <= par_cdagefim  AND
                         (craptvl.nrdocmto  = par_doctos    OR
                          par_doctos = 0)                     NO-LOCK,
       EACH crapage WHERE crapage.cdcooper = craptvl.cdcooper AND
                          crapage.cdagenci = craptvl.cdagenci NO-LOCK
                  BREAK BY craptvl.cdagenci:

       /* Nao reativar registros caso o pac nao seja cdbandoc = 85 - 14/06/10 */
       IF aux_nmdatela = "PRCCTL"  AND crapage.cdbandoc <> 85 THEN NEXT.
       
       DO aux_contador2 = 1 TO 10:
  
           FIND crabtvl WHERE RECID(crabtvl) = RECID(craptvl) 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE crabtvl   THEN
              IF LOCKED crabtvl   THEN
                 DO: 
                    ret_cdcritic = 077.
                    PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
              ELSE
                 DO:
                    ret_cdcritic = 055.
                    RETURN "NOK".
                 END.
           ELSE
              ASSIGN crabtvl.flgenvio = FALSE
                     crabtvl.cdbcoenv = 0
                     ret_cdcritic = 0.

           RELEASE crabtvl.
           LEAVE.

       END. /* fim do contador */

       IF ret_cdcritic > 0 THEN
          RETURN "NOK".

       IF LAST-OF (craptvl.cdagenci) THEN
           RUN pi_alterar_situacao_arquivos (INPUT  craptvl.cdcooper,
                                             INPUT  craptvl.cdagenci,
                                             INPUT  "DOCTOS",
                                             INPUT  0,
                                             INPUT  0,
                                             OUTPUT aux_cdcritic).
   END. /* Fim do For Each */

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

   IF aux_nmdatela = "PRCCTL" THEN
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                " - Coop:" + STRING(par_cdcooper,"99") +
                " - Processar:" + aux_nmprgexe +
                " - DOC/TEC REGERADOS -  PA de " + 
                STRING(par_cdageini) + " ate " + STRING(par_cdagefim) +
                " - Data: " + STRING(par_dtmvtolt,"99/99/9999") +
                " >> " + aux_nmarqlog).
   ELSE
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                " - " + STRING(par_dtmvtolt,"99/99/9999") +
                " - DOC/TEC REGERADOS -  PA de " + 
                STRING(par_cdageini) + " ate " + STRING(par_cdagefim) +
                " - Data: " + STRING(par_dtmvtolt,"99/99/9999") +
                " >> " + aux_dscooper + "log/doctos.log").

   RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE reativar_titulos:

   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdageini AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdagefim AS INT                               NO-UNDO.
   DEF OUTPUT PARAM ret_cdcritic AS INTE                              NO-UNDO.

   DEF   VAR  aux_cdcritic       AS INT                               NO-UNDO.
   DEF   VAR  aux_cdagenci       AS INT                               NO-UNDO.

   ASSIGN aux_cdagenci = par_cdageini.
   DO WHILE aux_cdagenci <= par_cdagefim:
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                   /* Efetuar a chamada a rotina Oracle  */
                   RUN STORED-PROCEDURE pc_checa_titulo
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                   ,INPUT " "
                                                   ,INPUT 0
                                                   ,INPUT aux_cdagenci
                                                   ,INPUT par_dtmvtolt
                                                   ,INPUT 0
                                                   ,INPUT 0
                                                   ,OUTPUT 0
                                                   ,OUTPUT "").

               /* Fechar o procedimento para buscarmos o resultado */ 
               CLOSE STORED-PROC pc_checa_titulo
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
          
               ASSIGN aux_dscritic = ""
                  aux_dscritic = pc_checa_titulo.pr_dscritic
                                 WHEN pc_checa_titulo.pr_dscritic <> ?
                  aux_cdcritic = 0
                  aux_cdcritic = pc_checa_titulo.pr_cdcritic
                                 WHEN pc_checa_titulo.pr_cdcritic <> ?.

               ASSIGN aux_cdagenci = aux_cdagenci + 1.

          END.



   FOR EACH craptit WHERE craptit.cdcooper  = par_cdcooper        AND
                          craptit.dtdpagto  = par_dtmvtolt        AND
                          CAN-DO("0,2,4",STRING(craptit.insittit))  AND
                          craptit.tpdocmto  = 20                  AND
                          craptit.cdagenci >= par_cdageini        AND
                          craptit.cdagenci <= par_cdagefim        AND
                          craptit.intitcop  = 0                   AND
                          craptit.vldpagto <  250000              AND
                          craptit.flgenvio  = YES                 NO-LOCK,
       EACH crapage WHERE crapage.cdcooper  = craptit.cdcooper    AND
                          crapage.cdagenci  = craptit.cdagenci    NO-LOCK
                 BREAK BY craptit.cdagenci:

       /* Nao reativar registros caso o pac nao seja cdbantit = 85 */
       IF aux_nmdatela = "PRCCTL"  AND crapage.cdbantit <> 85 THEN NEXT.
       
       DO aux_contador2 = 1 TO 10:
           FIND crabtit WHERE RECID(crabtit) = RECID(craptit) 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
           IF NOT AVAILABLE crabtit   THEN
              IF LOCKED crabtit   THEN
                 DO: 
                    ret_cdcritic = 077.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                 END.
              ELSE
                 DO:
                    ret_cdcritic = 055.
                    RETURN "NOK".
                 END.
           ELSE
               ASSIGN crabtit.flgenvio = FALSE
                      crabtit.cdbcoenv = 0
                      ret_cdcritic = 0.

           RELEASE crabtit.
           LEAVE.

       END. /* Fim do contador */

       IF ret_cdcritic > 0 THEN
          RETURN "NOK".

       IF LAST-OF (craptit.cdagenci) THEN
       DO:
           RUN pi_alterar_situacao_arquivos (INPUT  craptit.cdcooper,
                                             INPUT  craptit.cdagenci,
                                             INPUT  "TITULO",
                                             INPUT  0,
                                             INPUT  4,
                                             OUTPUT aux_cdcritic).
       END.
   END.

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

   IF aux_nmdatela = "PRCCTL" THEN
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                " - Coop:" + STRING(par_cdcooper,"99") +
                " - Processar:" + aux_nmprgexe +
                " - TITULOS REGERADOS -  PA de " + 
                STRING(par_cdageini) + " ate " + STRING(par_cdagefim) +
                " - Dt Pgto: " + STRING(par_dtmvtolt,"99/99/9999") +
                " >> " + aux_nmarqlog).
   ELSE
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                " - " + STRING(TODAY,"99/99/9999") +
                " - TITULOS REGERADOS - PA de " + 
                STRING(par_cdageini) +
                " ate " + STRING(par_cdagefim) +
                " - Dt Pgto: " + STRING(par_dtmvtolt,"99/99/9999") +
                " >> " + aux_dscooper + "log/titulos.log").

   RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE reativar_compel:

   DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdagenci AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_nrprevia AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_nrdcaixa AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_cdbccxlt AS CHAR                              NO-UNDO.
  
   DEF OUTPUT PARAM ret_cdcritic AS INTE                              NO-UNDO.

   DEF   VAR  aux_cdcritic       AS INTE                              NO-UNDO.
   DEF   VAR  aux_nrdlote1       AS INTE                              NO-UNDO.
   DEF   VAR  aux_nrdlote2       AS INTE                              NO-UNDO.
   DEF   VAR  aux_nrdlote3       AS INTE                              NO-UNDO.

   DEF   VAR  aux_qtchqprv       AS INTE                              NO-UNDO.

   FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   ASSIGN   aux_nrdlote1 = 11000 + par_nrdcaixa
            aux_nrdlote2 = 28000 + par_nrdcaixa
            aux_nrdlote3 = 30000 + par_nrdcaixa
            aux_qtchqprv = 0.

   FOR EACH crapchd WHERE crapchd.cdcooper = par_cdcooper           AND
                          crapchd.dtmvtolt = par_dtmvtolt           AND
                          crapchd.cdagenci = par_cdagenci           AND
                    CAN-DO(par_cdbccxlt,STRING(crapchd.cdbccxlt))   AND
                         (crapchd.nrdolote = aux_nrdlote1    OR
                          crapchd.nrdolote = aux_nrdlote2    OR
                          crapchd.nrdolote = aux_nrdlote3)          AND
                          crapchd.nrprevia = par_nrprevia           AND  
                    CAN-DO("0,2",STRING(crapchd.insitchq))   AND
                          crapchd.insitprv = 1              NO-LOCK,
       EACH crapage WHERE crapage.cdcooper  = crapchd.cdcooper   AND
                          crapage.cdagenci  = crapchd.cdagenci   AND
                          crapage.cdbanchq  = crapcop.cdbcoctl
                          NO-LOCK BREAK BY crapchd.cdagenci:
   
       DO aux_contador2 = 1 TO 10:

           FIND crabchd WHERE RECID(crabchd) = RECID(crapchd) 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE crabchd THEN
              IF LOCKED crabchd THEN
                 DO:
                    ret_cdcritic = 077.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                 END.
              ELSE
                 DO:
                    ret_cdcritic = 055.
                    RETURN "NOK".
                 END.    
           ELSE
              ASSIGN crabchd.cdbcoenv = 0
                     crabchd.flgenvio = FALSE
                     crabchd.nrprevia = 0
                     crabchd.hrprevia = 0
                     crabchd.insitprv = 0
                     aux_qtchqprv     = aux_qtchqprv + 1
                     ret_cdcritic = 0.

           RELEASE crabchd.
           LEAVE.

       END. /* fim do contador */

       IF ret_cdcritic > 0 THEN
          RETURN "NOK".

       IF LAST-OF (crapchd.cdagenci) THEN
           RUN pi_alterar_situacao_arquivos (INPUT  crapchd.cdcooper,
                                             INPUT  crapchd.cdagenci,
                                             INPUT  "COMPEL",
                                             INPUT  0,
                                             INPUT  0,
                                             OUTPUT aux_cdcritic).
   END.  /* fim do FOR EACH */
    
   DO aux_contador2 = 1 TO 10:

      FIND LAST crapbcx  WHERE  crapbcx.cdcooper = par_cdcooper      AND
                                crapbcx.dtmvtolt = par_dtmvtolt      AND
                                crapbcx.cdagenci = par_cdagenci      AND
                                crapbcx.nrdcaixa = par_nrdcaixa      
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF NOT AVAILABLE crapbcx THEN
         IF LOCKED crapbcx THEN
            DO:
               ret_cdcritic = 077.
               PAUSE 1 NO-MESSAGE.
               NEXT.
            END.
         ELSE
            DO:
                ret_cdcritic = 055.
                RETURN "NOK".
            END.    
      ELSE
         ASSIGN crapbcx.qtchqprv = aux_qtchqprv
                ret_cdcritic = 0.

      LEAVE.   

   END. /* fim do contador */

   IF ret_cdcritic > 0 THEN
      RETURN "NOK".
                           
   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                     " - " + STRING(TODAY,"99/99/9999") +
                     " - CHEQUES REGERADOS - PA " + 
                     STRING(par_cdagenci) + 
                     " - Data: " + STRING(par_dtmvtolt,"99/99/9999") +
                     " >> " + aux_dscooper + "log/compel.log").

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE reativar_compel_prcctl:

   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdageini AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdagefim AS INT                               NO-UNDO.

   DEF OUTPUT PARAM ret_cdcritic AS INTE                              NO-UNDO.

   DEF   VAR  aux_cdcritic       AS INT                               NO-UNDO.
   DEF   VAR  aux_cdagenci       AS INT                               NO-UNDO.
   
   ASSIGN aux_cdagenci = par_cdageini.
   DO WHILE aux_cdagenci <= par_cdagefim:
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                   /* Efetuar a chamada a rotina Oracle  */
                   RUN STORED-PROCEDURE pc_checa_compel
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                   ,INPUT " "
                                                   ,INPUT 0
                                                   ,INPUT aux_cdagenci
                                                   ,INPUT par_dtmvtolt
                                                   ,INPUT 0
                                                   ,INPUT 0
                                                   ,OUTPUT 0
                                                   ,OUTPUT "").

               /* Fechar o procedimento para buscarmos o resultado */ 
               CLOSE STORED-PROC pc_checa_compel
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
          
               ASSIGN aux_dscritic = ""
                  aux_dscritic = pc_checa_compel.pr_dscritic
                                 WHEN pc_checa_compel.pr_dscritic <> ?
                  aux_cdcritic = 0
                  aux_cdcritic = pc_checa_compel.pr_cdcritic
                                 WHEN pc_checa_compel.pr_cdcritic <> ?.

               ASSIGN aux_cdagenci = aux_cdagenci + 1.

          END.


   FOR EACH crapchd WHERE crapchd.cdcooper = par_cdcooper     AND
                          crapchd.dtmvtolt = par_dtmvtolt     AND
                          crapchd.cdagenci >= par_cdageini    AND
                          crapchd.cdagenci <= par_cdagefim    AND
                          crapchd.flgenvio = YES              NO-LOCK    
                          USE-INDEX crapchd3,
       EACH crapage WHERE crapage.cdcooper = crapchd.cdcooper AND
                          crapage.cdagenci = crapchd.cdagenci NO-LOCK
                 BREAK BY crapchd.cdagenci:

       /* Nao reativar registros caso o pac nao seja cdbanchq = 85 */
       IF aux_nmdatela = "PRCCTL"  AND crapage.cdbanchq <> 85 THEN NEXT.
       
       DO aux_contador2 = 1 TO 10:

           FIND crabchd WHERE RECID(crabchd) = RECID(crapchd) 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE crabchd THEN
              IF LOCKED crabchd THEN
                 DO: 
                    ret_cdcritic = 077.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                 END.
              ELSE
                DO:
                   ret_cdcritic = 055.
                   RETURN "NOK".
                END.
           ELSE
              ASSIGN crabchd.flgenvio = NO
                     crabchd.cdbcoenv = 0
                     ret_cdcritic = 0.

           RELEASE crabchd.
           LEAVE.

       END. /* fim do contador */

       IF ret_cdcritic > 0 THEN
          RETURN "NOK".

       IF LAST-OF (crapchd.cdagenci) THEN
       DO:
           RUN pi_alterar_situacao_arquivos (INPUT  crapchd.cdcooper,
                                             INPUT  crapchd.cdagenci,
                                             INPUT  "COMPEL",
                                             INPUT  0,
                                             INPUT  3,
                                             OUTPUT aux_cdcritic).

       END.
   END.  /* fim do FOR EACH */

   FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

   IF aux_nmdatela = "PRCCTL" THEN
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                " - Coop:" + STRING(par_cdcooper,"99") +
                " - Processar:" + aux_nmprgexe +
                " - CHEQUES REGERADOS -  PA de " +
                STRING(par_cdageini) + " ate " + STRING(par_cdagefim) +
                " - Data: " + STRING(par_dtmvtolt,"99/99/9999") +
                " >> " + aux_nmarqlog).
   ELSE
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                " - " + STRING(TODAY,"99/99/9999") +
                " - CHEQUES REGERADOS -  PA de " + 
                STRING(par_cdageini) + " ate " + STRING(par_cdagefim) +
                " - Data: " + STRING(par_dtmvtolt,"99/99/9999") +
                " >> " + aux_dscooper + "log/compel.log").

   RETURN "OK".

END PROCEDURE.

PROCEDURE reativar_devolu_prcctl:

   { sistema/generico/includes/var_oracle.i }

   DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF INPUT  PARAM par_cdageini AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_cdagefim AS INT                               NO-UNDO.
   DEF INPUT  PARAM par_tpdevolu AS CHAR                              NO-UNDO.

   DEF OUTPUT PARAM ret_cdcritic AS INTE                              NO-UNDO.

   DEF   VAR  aux_cdcritic       AS INT                               NO-UNDO.
   DEF   VAR  aux_nrseqsol       AS INT                               NO-UNDO.
   DEF   VAR  aux_tparquiv       AS INT                               NO-UNDO.

   IF par_tpdevolu = "Diurna" THEN
      ASSIGN aux_nrseqsol = 5
             aux_tparquiv = 1.
   ELSE
      ASSIGN aux_nrseqsol = 6
             aux_tparquiv = 2.

   FIND crapsol WHERE 
        crapsol.cdcooper = par_cdcooper AND
        crapsol.dtrefere = par_dtmvtolt AND
        crapsol.nrsolici = 78           AND
        crapsol.nrseqsol = aux_nrseqsol
   EXCLUSIVE-LOCK NO-ERROR.

   IF  AVAILABLE crapsol THEN
       DELETE crapsol.

       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
           /* Efetuar a chamada a rotina Oracle  */
           RUN STORED-PROCEDURE pc_checa_devolu
       aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper 
                                           ,INPUT " "
                                           ,INPUT 0
                                           ,INPUT 0
                                           ,INPUT par_dtmvtolt
                                           ,INPUT 0
                                           ,INPUT 0
                                           ,INPUT aux_tparquiv
                                           ,OUTPUT 0
                                           ,OUTPUT "").

   /* Fechar o procedimento para buscarmos o resultado */ 
   CLOSE STORED-PROC pc_checa_devolu
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
  
   ASSIGN aux_dscritic = ""
          aux_dscritic = pc_checa_devolu.pr_dscritic
                         WHEN pc_checa_devolu.pr_dscritic <> ?
          aux_cdcritic = 0
          aux_cdcritic = pc_checa_devolu.pr_cdcritic
                         WHEN pc_checa_devolu.pr_cdcritic <> ?.

/*
   FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

   IF aux_nmdatela = "PRCCTL" THEN
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                " - Coop:" + STRING(par_cdcooper,"99") +
                " - Processar:" + aux_nmprgexe +
                " DEVOLUCAO " + par_tpdevolu + " - Reativar DEVOLU (opcao X)",
                " - Data: " + STRING(par_dtmvtolt,"99/99/9999") +
                " >> " + aux_nmarqlog).
   ELSE
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                " - " + STRING(TODAY,"99/99/9999") +
                " - CHEQUES REGERADOS -  PA de " + 
                STRING(par_cdageini) + " ate " + STRING(par_cdagefim) +
                " - Data: " + STRING(par_dtmvtolt,"99/99/9999") +
                " >> " + aux_dscooper + "log/compel.log").
*/


END PROCEDURE.

/*............................................................................*/

PROCEDURE reativar_tic604:

   DEF INPUT  PARAM par_cdcooper AS INTE                              NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF OUTPUT PARAM ret_cdcritic AS INTE                              NO-UNDO.



   FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
   FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.


   /* Cheques - Custodia - Nao Enviados e Situacao 0 ou 2  - Inclusao */
   FOR EACH crapcst WHERE crapcst.cdcooper = par_cdcooper      AND
                          crapcst.dtmvtolt = crapdat.dtmvtoan  AND
                          crapcst.dtenvtic = crapdat.dtmvtolt  AND
                          crapcst.nrborder = 0
                          NO-LOCK:
      
       DO aux_contador2 = 1 TO 10:

           FIND crabcst WHERE RECID(crabcst) = RECID(crapcst) 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE crabcst   THEN
              IF LOCKED crabcst   THEN
                 DO: 
                     ret_cdcritic = 077.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
              ELSE
                 DO:
                    ret_cdcritic = 055.
                    RETURN "NOK".
                 END.
           ELSE
               ASSIGN crabcst.dtenvtic = ?
                      ret_cdcritic = 0.

           RELEASE crabcst.
           LEAVE.

       END. /* fim do contador */

       IF ret_cdcritic > 0 THEN
          RETURN "NOK".

   END. /* fim do for each */


   /* Cheques - Desconto - Nao Enviados - Situacao 0 ou 2 - INCLUSAO */
   FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper      AND
                          crapcdb.dtmvtolt = crapdat.dtmvtoan  AND
                          crapcdb.dtenvtic = crapdat.dtmvtolt
                          NO-LOCK:
       
       DO aux_contador2 = 1 TO 10:

           FIND crabcdb WHERE RECID(crabcdb) = RECID(crapcdb) 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE crabcdb   THEN
              IF LOCKED crabcdb   THEN
                 DO: 
                     ret_cdcritic = 077.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
              ELSE
                 DO:
                    ret_cdcritic = 055.
                    RETURN "NOK".
                 END.
           ELSE
              ASSIGN crabcdb.dtenvtic = ?
                     ret_cdcritic = 0.

           RELEASE crabcdb.
           LEAVE.

       END. /* fim do contador */

       IF ret_cdcritic > 0 THEN
          RETURN "NOK".

   END. /* fim do for each */
                       
   ASSIGN aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                     " - " + STRING(TODAY,"99/99/9999") +
                     " - CHEQUES CST/CDB REGERADOS" + 
                     " - Data: " + STRING(par_dtmvtolt,"99/99/9999") +
                     " >> " + aux_dscooper + "log/tic604.log").

   RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE verifica_hora_execucao:
/*  Parametro de entrada:                                                    */
/*  1 Hr Ini Per. 1 | 2 Hr Fim Per. 1 | 3 Hr Ini Per. 2 | 4 Hr Fim Per. 2    */
 DEF INPUT  PARAM par_posicao  AS INTE  NO-UNDO.
/* Verifica se a hora de execucao atual eh maior que a hora gravada          */
/* nos parametros da craptab                                                 */
/* YES = Maior que o parametro                                               */
/* NO  = Menor que o parametro                                               */
 DEF OUTPUT PARAM ret_execucao AS LOGI  NO-UNDO.


 FIND craptab WHERE craptab.cdcooper = aux_cdcooper
                AND craptab.nmsistem = "CRED"
                AND craptab.tptabela = "GENERI"
                AND craptab.cdempres = 0
                AND craptab.cdacesso = "HRTRDEVOLU"
                AND craptab.tpregist = 0
    NO-LOCK NO-ERROR.
 
 IF NOT AVAIL craptab THEN DO:
    IF TIME  >= INT(57600) THEN /* 16 Horas */
     ret_execucao = YES.
     ELSE ret_execucao = NO.
 END.
 ELSE DO:
     IF TIME >= INT(ENTRY(par_posicao,craptab.dstextab,";")) THEN
     ret_execucao = YES.
     ELSE ret_execucao = NO.
 END.


END PROCEDURE.

/*........................................................................... */

PROCEDURE pi_alterar_situacao_arquivos:

   DEF INPUT  PARAM par_cdcooper    AS INT                              NO-UNDO.
   DEF INPUT  PARAM par_cdagenci    AS INT                              NO-UNDO.
   DEF INPUT  PARAM par_programa    AS CHAR                             NO-UNDO.
   DEF INPUT  PARAM par_cdsituac    AS INT                              NO-UNDO.
   DEF INPUT  PARAM par_tparquiv    AS INT                              NO-UNDO.
   DEF OUTPUT PARAM ret_cdcritic    AS INT                              NO-UNDO.

   DEF VAR         aux_cdacesso     AS CHAR                             NO-UNDO.
   DEF VAR         aux_nrdahora     AS INT                              NO-UNDO.
   DEF BUFFER      crabtab FOR craptab.

   ASSIGN aux_cdacesso = "HRTR" + par_programa.

   DO TRANSACTION ON ENDKEY UNDO, LEAVE:
      DO aux_contador = 1 TO 10:
    
          FIND crabtab WHERE crabtab.cdcooper = par_cdcooper      AND
                             crabtab.nmsistem = "CRED"            AND
                             crabtab.tptabela = "GENERI"          AND
                             crabtab.cdempres = 00                AND
                             crabtab.cdacesso = aux_cdacesso      AND
                             crabtab.tpregist = par_cdagenci
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
          IF   NOT AVAILABLE crabtab   THEN
               IF   LOCKED crabtab   THEN
                    DO:
                       ret_cdcritic = 77.
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                    END.
               ELSE
                    DO:
                       ret_cdcritic = 55.
                       LEAVE.
                    END.    
                       
         ELSE
              ret_cdcritic = 0.
    
         LEAVE.
    
      END.  /*  Fim do DO .. TO  */
    
      IF   ret_cdcritic > 0 THEN
           RETURN.

      /* 1 - Processado     - "B" */
      /* 0 - Nao Processado - "X" */
    
      ASSIGN aux_nrdahora     = INT(SUBSTR(crabtab.dstextab,3,5))
             crabtab.dstextab = STRING(par_cdsituac,"9") + " " + 
                                STRING(aux_nrdahora,"99999") + " " +
                                SUBSTR(crabtab.dstextab,9).
      RELEASE crabtab.
  END.

END PROCEDURE.


PROCEDURE visualiza_cheques_previa:

    DEF INPUT  PARAM p-cooper        AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM p-cod-operador  AS CHAR                    NO-UNDO. 
    DEF INPUT  PARAM p-cod-agencia   AS INTE                    NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa     AS INTE                    NO-UNDO.
    DEF INPUT  PARAM p-nro-cdbccxlt  AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM p-nro-previa    AS INTE                    NO-UNDO.
    DEF OUTPUT PARAM p-nome-arquivo  AS CHAR                    NO-UNDO.
    
    DEF VAR aux_nmarqimp AS CHAR                                NO-UNDO.
    DEF VAR tot_qtcheque AS INTE                                NO-UNDO.
    DEF VAR tot_vlcheque AS DECI    FORMAT "z,zzz,zz9.99"       NO-UNDO.

    DEF VAR aux_nrdlote1 AS INTE                                NO-UNDO.
    DEF VAR aux_nrdlote2 AS INTE                                NO-UNDO.
    DEF VAR aux_nrdlote3 AS INTE                                NO-UNDO.


    FORM  "DATA                PA         CXA           OPERADOR"
          SKIP(1)
          crapdat.dtmvtolt  FORMAT "99/99/9999"
          p-cod-agencia      AT 13
          p-nro-caixa        AT 25
          p-cod-operador     AT 46 
          WITH NO-LABELS NO-BOX WIDTH 132 FRAME f_cab STREAM-IO.
    
    FORM  crapcop.cdagectl COLUMN-LABEL "Agencia"
          crapchd.nrdconta COLUMN-LABEL "Conta/dv"
          crapchd.nrdocmto
          crapchd.dsdocmc7
          crapchd.vlcheque
          crapchd.nrseqdig 
          WITH DOWN WIDTH 96 FRAME f_cheques.

    FORM  tot_qtcheque LABEL "Quantidade Cheques"
          tot_vlcheque LABEL "Valor Total Cheques" AT 46
          WITH DOWN WIDTH 90 NO-LABEL SIDE-LABELS FRAME f_total.


    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.      

    ASSIGN aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" + 
                          crapcop.dsdircop      + 
                          STRING(p-cod-agencia) + 
                          STRING(p-nro-caixa)   + 
                          "b1018.txt".  /* Nome Fixo  */
             
    ASSIGN p-nome-arquivo = "spool/" + 
                            crapcop.dsdircop      + 
                            STRING(p-cod-agencia) + 
                            STRING(p-nro-caixa)   + 
                            "b1018.txt".  /* Nome Fixo  */.
                                           
    ASSIGN aux_nrdlote1 = 11000 + p-nro-caixa
           aux_nrdlote2 = 28000 + p-nro-caixa  /** Cheques Rotina 14 **/
           aux_nrdlote3 = 30000 + p-nro-caixa. /** Cheques Rotina 66 **/

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    DISPLAY STREAM str_1    crapdat.dtmvtolt  
                            p-cod-agencia 
                            p-nro-caixa 
                            p-cod-operador
                            WITH FRAME f_cab.
   
    FOR EACH crapchd WHERE  crapchd.cdcooper = crapcop.cdcooper      AND
                            crapchd.dtmvtolt = crapdat.dtmvtolt      AND
                            crapchd.cdagenci = p-cod-agencia         AND
                            crapchd.nrprevia = p-nro-previa          AND
                            crapchd.cdoperad = p-cod-operador        AND
                            CAN-DO(p-nro-cdbccxlt,STRING(crapchd.cdbccxlt)) AND                            
                            (crapchd.nrdolote = aux_nrdlote1          OR
                            crapchd.nrdolote = aux_nrdlote2          OR
                            crapchd.nrdolote = aux_nrdlote3)         NO-LOCK
                            BY  crapchd.nrdconta
                                BY  crapchd.nrdocmto:
        
        ASSIGN  tot_qtcheque = tot_qtcheque + 1
                tot_vlcheque = tot_vlcheque + crapchd.vlcheque.
        
        DISPLAY STREAM str_1 
                crapchd.cdagedst WHEN crapchd.cdagedst <> 0 @ crapcop.cdagectl
                crapcop.cdagectl WHEN crapchd.cdagedst  = 0
                crapchd.nrctadst WHEN crapchd.cdagedst <> 0 @ crapchd.nrdconta 
                crapchd.nrdconta WHEN crapchd.cdagedst  = 0
                crapchd.nrdocmto
                crapchd.dsdocmc7
                crapchd.vlcheque
                crapchd.nrseqdig WITH FRAME f_cheques.

        DOWN WITH FRAME f_cheques.
        
    END.  /*  for each crapchd */
    
    DISPLAY STREAM str_1  tot_qtcheque 
                          tot_vlcheque WITH FRAME f_total.
   
    OUTPUT  STREAM str_1 CLOSE.

    RETURN "OK".
    
END PROCEDURE.


PROCEDURE emite_protocolo_previa:

    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-data          AS DATE.
    DEF INPUT  PARAM p-cod-operador  AS CHAR. 
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-nro-previa    AS INTE.
    DEF INPUT  PARAM p-hra-previa    AS CHAR.
    DEF INPUT  PARAM p-qtd-previa    AS INTE.
    DEF INPUT  PARAM p-vlr-previa    AS DECI.
    DEF OUTPUT PARAM p-dsliteral  AS CHAR.
    
    DEF VAR c-literal       AS CHAR FORMAT "x(44)" EXTENT 35.
    DEF VAR aux_nmarquiv    AS CHAR FORMAT "x(40)".

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR. 
    
    ASSIGN aux_nmarquiv = "caixa-"                          +
                          STRING(p-cod-agencia,"999")       +
                          "-"                               + 
                          STRING(p-nro-caixa,"999")         +
                          "-"                               + 
                          STRING(YEAR(p-data),"9999")       +
                          STRING(MONTH(p-data),"99")        +
                          STRING(DAY(p-data),"99")          +
                          "."                               +
                          STRING(p-nro-previa, "999").

    ASSIGN c-literal = " "
           c-literal[01]  = TRIM(crapcop.nmrescop) + " - " + 
                            TRIM(crapcop.nmextcop,"x(20)")
           c-literal[02]  = " "
           c-literal[03]  = STRING(crapdat.dtmvtolt,"99/99/99") + " " + 
                            STRING(TIME,"HH:MM:SS") +  "  PA " +
                            STRING(p-cod-agencia,"999") + "  CAIXA: " + 
                            STRING(p-nro-caixa,"Z99") + "/" +
                            SUBSTR(p-cod-operador,1,10)
           c-literal[04]  = " "
           c-literal[05]  = "        ** DETALHE DA PREVIA ** "  
           c-literal[06]  = " "
           c-literal[07]  = "NUMERO PREVIA: " + STRING(p-nro-previa,"z999") + 
                            "  HORARIO PREVIA: " + p-hra-previa
           c-literal[08]  = " "
           c-literal[09]  = "QTD. CHEQUES : " + STRING(p-qtd-previa,">>99") + 
                            "  VALOR TOTAL: R$ " + TRIM(STRING(p-vlr-previa,">>>>,>>9.99"))
           c-literal[10]  = " "
           c-literal[11]  = "ARQUIVO      : " + aux_nmarquiv
           c-literal[12]  = " "
           c-literal[13]  = " "
           c-literal[14]  = " "
           c-literal[15]  = " "
           c-literal[16]  = " "
           c-literal[17]  = " "
           c-literal[18]  = " "
           c-literal[19]  = " "
           c-literal[20]  = " "
           c-literal[21]  = " ".
           

    ASSIGN  p-dsliteral =    STRING(c-literal[01],"x(48)")  +
                             STRING(c-literal[02],"x(48)")  +
                             STRING(c-literal[03],"x(48)")  +
                             STRING(c-literal[04],"x(48)")  +
                             STRING(c-literal[05],"x(48)")  + 
                             STRING(c-literal[06],"x(48)")  +
                             STRING(c-literal[07],"x(48)")  +
                             STRING(c-literal[08],"x(48)")  +
                             STRING(c-literal[09],"x(48)")  +
                             STRING(c-literal[10],"x(48)")  +
                             STRING(c-literal[11],"x(48)")  +
                             STRING(c-literal[12],"x(48)")  +
                             STRING(c-literal[13],"x(48)")  +
                             STRING(c-literal[14],"x(48)")  +
                             STRING(c-literal[15],"x(48)")  +
                             STRING(c-literal[16],"x(48)")  +
                             STRING(c-literal[17],"x(48)")  +
                             STRING(c-literal[18],"x(48)")  +
                             STRING(c-literal[19],"x(48)")  +
                             STRING(c-literal[20],"x(48)")  +
                             STRING(c-literal[21],"x(48)").

END PROCEDURE.

PROCEDURE bloquear-resgate-cheque:

    DEF BUFFER b-craptab FOR craptab.

    DEF INPUT  PARAM par_cdcooper AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_dsresgat AS CHAR                              NO-UNDO.
    /* par_dsresgat: S = Bloquear resgate de cheque
                     N = Desbloquear resgate de cheque */

    FIND b-craptab WHERE  
         b-craptab.cdcooper = par_cdcooper AND
         b-craptab.nmsistem = "CRED"       AND
         b-craptab.tptabela = "USUARI"     AND
         b-craptab.cdempres = 11           AND
         b-craptab.cdacesso = "BLQRESGCHQ" AND
         b-craptab.tpregist = 00           
         NO-LOCK NO-ERROR.

    IF  NOT AVAIL b-craptab THEN
        DO:
            CREATE b-craptab.
            ASSIGN b-craptab.cdcooper = par_cdcooper
                   b-craptab.nmsistem = "CRED"      
                   b-craptab.tptabela = "USUARI"    
                   b-craptab.cdempres = 11          
                   b-craptab.cdacesso = "BLQRESGCHQ"
                   b-craptab.tpregist = 00
                   b-craptab.dstextab = par_dsresgat.
            VALIDATE b-craptab.
        END.
    ELSE
    DO:
        FIND CURRENT b-craptab EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
        IF  AVAIL(b-craptab) THEN 
            DO:
                ASSIGN b-craptab.dstextab = par_dsresgat.
    
                FIND CURRENT b-craptab NO-LOCK NO-ERROR.
    
                RELEASE b-craptab.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */



