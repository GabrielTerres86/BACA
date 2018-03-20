/* ............................................................................

   Programa: fontes/crps410.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Setembro/2004                   Ultima atualizacao: 13/09/2017

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 082.  
               Gerar arquivo com ALTERACOES CADASTRAIS (COO405) dos associados
               para enviar ao Banco do Brasil.
               Relatorios:   381 - Enviados

   Alteracoes: 29/07/2005 - Alterada mensagem Log referente critica 847        
                            (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               13/10/2005 - Alterado para nao imprimir relatorio para
                            Viacredi (Diego).
             
               17/10/2005 - Efetuado acerto tipo de pessoa(registro 06)
                            (Mirtes)
               
               20/10/2005 - Efetuado acerto tipo de pessoa (qdo alt.-reg.06)
                            (Mirtes)

               20/10/2005 - Incluido inclusao 2.titular qdo tp.arq.552(Mirtes)
               
               31/10/2005 - Separado o PUT do tipo de registro pra nao
                            invalidar o arquivo todo (Evandro).
                            
               01/11/2005 - Alterado limite de registros por arquivo (Evandro).
                            
               03/11/2005 - Corrigida leitura do bloqueio da craptab (Evandro).
               
               18/11/2005 - Adequacao a pessoas juridicas, uma vez que, foram
                            removidos registros da crapttl;
                          - Utilizacao do COO552 para controle de titulares
                            (Evandro).
                            
               29/11/2005 - Acerto para EXCLUSAO de titulares (Evandro).
               
               02/12/2005 - Controle de duplicidade na crabeca (Evandro).
               
               12/12/2005 - Acerto na duplicidade da crabeca (Evandro).
                            
               15/12/2005 - Previsao exclusao cooperado(Mirtes).
               
               10/01/2006 - Correcao das mensagens para o LOG (Evandro).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               15/03/2006 - Verificar se o registro 'crapeca' ja existe antes
                            da criacao (Evandro).

               03/04/2006 - Concertada clausula OR do FOR EACH, pondo entre
                            parenteses (Diego).

               26/06/2006 - Envio atualizacao cadastral(Problema CPF)(Mirtes)
               
               29/06/2006 - Modificado endereco para socios com Cartao BB
                            (Diego).

               25/07/2006 - Alterado condicao da variavel aux_cddocttl para 
                            receber valor 31 quando igual a "CH" (David).
                            
               19/10/2006 - Nao gerar comandos bloqueio/desbloqueio(Mirtes)
               
               24/10/2006 - Modificado envio de endereco(tipo 7), para a
                            Cecrisacred (Diego).
                            
              16/11/2006 - Modificado envio de endereco(tipo 7), para a 
                           Concredi - Tarefa 9455(Mirtes).
                           
              20/11/2006 - Nao criticar cadastro incompleto se for fazer
                           exclusao da conta ITG (Evandro).
                           
              29/11/2006 - Criticar qdo tipo de conta for Individual e tiver
                           mais de um titular (Ze).

              18/12/2006 - Endereco Cooperativa(Credcrea e Credifiesc)(Mirtes)
              
              26/12/2006 - Tratamento para a leitura dos dados do conjuge
                           (Evandro).
                           
              28/05/2007 - Retirado a vinculacao da execucao do imprim.p
                           com o codigo da cooperativa(Guilherme).
              
              16/08/2007 - Pega data de abertura de conta mais antiga no SFN
                           para mandar no arquivo (Elton).

              22/10/2007 - Alteracao no FOR EACH crapalt para melhoria de 
                           performance (Julio)
                           
              14/03/2008 - Nao gerar Encerramento de Conta ITG., substituido
                           por COO409 - crps503 (Diego).

              19/02/2008 - Nao solicitar atualizacao cadastral para os         
                           registros reativados(Mirtes)
                           
              30/03/2009 - Na inclusao/exclusao ou alteracao de dados se possuir
                           cartao BB enviar registro 7(atualizacao cadastral)
                           independente de qual cooperativa(Guilherme).
                           
              03/08/2009 - Pegar nome de talao da crapjur e nao utilizar mais
                           o programa abreviar.p (David).
                           
              14/12/2009 - Alterada clausula where do find na crapjur (linha 955)
                           motivo: tabela comparada fora do escopo (Fernando). 
                           
              16/12/2009 - Eliminado campo crapttl.cdmodali (Diego).       
                         
              23/05/2011 - Substituido campo crapttl.nranores por 
                           crapenc.dtinires. (Fabricio)
                           
              24/06/2011 - Ajuste na alteracao acima. Faltou ler registro
                           da crapenc (David).
                           
              11/07/2011 - Utilizar nova funcao f_endereco_ctaitg declarada na
                           include endereco_conta_itg.i para configurar endereco
                           do cooperado para envio ao BB (David).             
                           
              28/07/2011 - Envio endereco cooperado(Isara)        
              
              12/11/2012 - Retirar matches dos find/for each (Gabriel).      
              
              17/10/2013 - Alterado para variável aux_incasprp receber dados da
                           crapenc. 
                         - Alterada coluna de PAC para PA. (Reinert)
              
              22/01/2014 - Incluir VALIDATE crabeca, crapeca (Lucas R.)
              
              11/02/2014 - Retirado consulta a tabela crawcrd pois nao era
                           utilizada e forcava desvio desnecessario na
                           execucao (Tiago).
                           
              12/06/2014 - (Chamado 117414) - Alteraçao das informaçoes do conjuge da crapttl 
                           para utilizar somente crapcje. 
                           (Tiago Castro - RKAM)
                           
              19/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                           PRJ339 - CRM (Odirlei-AMcom)  

              13/09/2017 - Ajuste para retirar o uso de campos removidos da tabela
                           crapass, crapttl, crapjur (Adriano - P339).

              07/03/2018 - Substituida verificado "cdtipcta igual a 1, 2, 7, 8..." por 
                           "cdcatego = 1". PRJ366 (Lombardi).

                           
.............................................................................*/

{ includes/var_batch.i }  

DEF STREAM str_1.

DEF     VAR aux_nmarqimp AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nmarqrel AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nrtextab AS INT                                      NO-UNDO.
DEF     VAR aux_nrregist AS INT                                      NO-UNDO.
DEF     VAR aux_nrtotcli AS INT                                      NO-UNDO.
DEF     VAR aux_dsdlinha AS CHAR      FORMAT "x(150)"                NO-UNDO.
DEF     VAR aux_dtinires AS CHAR                                     NO-UNDO.
DEF     VAR aux_dstelefo AS CHAR                                     NO-UNDO.
DEF     VAR aux_cdsexotl AS CHAR                                     NO-UNDO.
DEF     VAR aux_contador AS INT                                      NO-UNDO.
DEF     VAR aux_cddocttl AS INT       FORMAT "99"                    NO-UNDO.
DEF     VAR aux_dtabtcct AS DATE                                     NO-UNDO.
DEF     VAR aux_usatalao AS LOGICAL                                  NO-UNDO.
DEF     VAR aux_bloqueio AS INT                                      NO-UNDO.
DEF     VAR aux_cdaltera AS INT                                      NO-UNDO.
DEF     VAR aux_nrdconta LIKE crapass.nrdconta                       NO-UNDO.
/* nome do arquivo de log */
DEF     VAR aux_nmarqlog AS CHAR                                     NO-UNDO.
DEF     VAR aux_idseqttl LIKE crapttl.idseqttl                       NO-UNDO.
DEF     VAR aux_nrcpfcgc LIKE crapttl.nrcpfcgc                       NO-UNDO.
DEF     VAR aux_inpessoa LIKE crapttl.inpessoa                       NO-UNDO.
DEF     VAR aux_dtnasttl LIKE crapttl.dtnasttl                       NO-UNDO.
DEF     VAR aux_nmextttl LIKE crapttl.nmextttl                       NO-UNDO.
DEF     VAR aux_nmtalttl LIKE crapttl.nmtalttl                       NO-UNDO.
DEF     VAR aux_tpnacion LIKE crapttl.tpnacion                       NO-UNDO.
DEF     VAR aux_dsnatura LIKE crapttl.dsnatura                       NO-UNDO.
DEF     VAR aux_nrdocttl LIKE crapttl.nrdocttl                       NO-UNDO.
DEF     VAR aux_cdoedttl AS CHAR                                     NO-UNDO.
DEF     VAR aux_dtemdttl LIKE crapttl.dtemdttl                       NO-UNDO.
DEF     VAR aux_cdestcvl LIKE crapttl.cdestcvl                       NO-UNDO.
DEF     VAR aux_cdfrmttl LIKE crapttl.cdfrmttl                       NO-UNDO.
DEF     VAR aux_grescola LIKE crapttl.grescola                       NO-UNDO.
DEF     VAR aux_cdnatopc LIKE crapttl.cdnatopc                       NO-UNDO.
DEF     VAR aux_cdocpttl LIKE crapttl.cdocpttl                       NO-UNDO.
DEF     VAR aux_nmmaettl LIKE crapttl.nmmaettl                       NO-UNDO.
DEF     VAR aux_nmpaittl LIKE crapttl.nmpaittl                       NO-UNDO.
DEF     VAR aux_nmconjug LIKE crapcje.nmconjug                       NO-UNDO.
DEF     VAR aux_nrcpfcjg LIKE crapcje.nrcpfcjg                       NO-UNDO.
DEF     VAR aux_dtnasccj LIKE crapcje.dtnasccj                       NO-UNDO.
DEF     VAR aux_nrcpfemp LIKE crapttl.nrcpfemp                       NO-UNDO.
DEF     VAR aux_tpcttrab LIKE crapttl.tpcttrab                       NO-UNDO.
DEF     VAR aux_dtadmemp LIKE crapttl.dtadmemp                       NO-UNDO.
DEF     VAR aux_nmextemp LIKE crapttl.nmextemp                       NO-UNDO.
DEF     VAR aux_dsproftl LIKE crapttl.dsproftl                       NO-UNDO.
DEF     VAR aux_cdnvlcgo LIKE crapttl.cdnvlcgo                       NO-UNDO.
DEF     VAR aux_incasprp LIKE crapenc.incasprp                       NO-UNDO.
DEF     VAR h-b1wgen0052b AS HANDLE                                  NO-UNDO.

DEF     VAR rel_dsagenci AS CHAR                                     NO-UNDO.
DEF     VAR rel_nmempres AS CHAR      FORMAT "x(15)"                 NO-UNDO.
DEF     VAR rel_nmresemp AS CHAR      FORMAT "x(15)"                 NO-UNDO.
DEF     VAR rel_nmrelato AS CHAR      FORMAT "x(40)" EXTENT 5        NO-UNDO.
DEF     VAR rel_nrmodulo AS INT       FORMAT "9"                     NO-UNDO.
DEF     VAR rel_nmmodulo AS CHAR      FORMAT "x(15)" EXTENT 5
                            INIT ["DEP. A VISTA   ","CAPITAL        ",
                                  "EMPRESTIMOS    ","DIGITACAO      ",
                                  "GENERICO       "]                 NO-UNDO.

DEF     VAR aux_dtabtcc2 AS DATE      FORMAT "99/99/9999"            NO-UNDO.

DEF NEW SHARED VAR shr_inpessoa AS INT                               NO-UNDO.  

DEF BUFFER crabass FOR crapass.
DEF BUFFER crabeca FOR crapeca.
DEF BUFFER crabalt FOR crapalt.
DEF BUFFER crabttl FOR crapttl.

/* para os titulares que foram enviados */
DEF TEMP-TABLE w_enviados                                            NO-UNDO
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD nmextttl LIKE crapttl.nmextttl
    INDEX w_enviados1
          cdagenci
          nrdconta
          idseqttl.

/* Para a "juncao" das alteracoes em uma soh alteracao */
DEF TEMP-TABLE cratalt NO-UNDO LIKE crapalt.


FORM rel_dsagenci           AT   4  LABEL "PA"             FORMAT "x(21)"
     w_enviados.nrdconta    AT  31  LABEL "Conta/DV"
     w_enviados.nrdctitg    AT  47  LABEL "Conta de Integracao"
     w_enviados.nmextttl    AT  72  LABEL "Nome do Titular"
     w_enviados.idseqttl    AT 118  LABEL "Titularidade"
     WITH DOWN NO-LABELS WIDTH 132 FRAME f_enviados.


ASSIGN glb_cdprogra = "crps410"
       glb_flgbatch = FALSE
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

{ includes/endereco_conta_itg.i }

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).
         RETURN.
     END.


ASSIGN aux_dstelefo = REPLACE(SUBSTRING(crapcop.nrtelvoz,6,9),"-","").
                                             /* Telefone Cooperativa */
                                             
/* Verifica o bloqueio do arquivo */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "NRARQMVITG"   AND
                   craptab.tpregist = 405            NO-LOCK NO-ERROR.

IF   NOT AVAIL craptab   THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> " + aux_nmarqlog).

         RUN fontes/fimprg.p.                   
         RETURN.
     END.    
ELSE
     IF INT(SUBSTR(craptab.dstextab,07,01)) = 1 THEN
        DO:
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                             " - COO405 - " + glb_cdprogra + "' --> '"  +
                             "PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS" +
                             " >> " + aux_nmarqlog).
              
           RUN fontes/fimprg.p.                   
           RETURN.
        END.
 

RUN abre_arquivo.

/* Reenvio de registros que tiveram erro - INCLUSAO/EXCLUSAO de titulares */
FOR EACH crapeca WHERE crapeca.cdcooper = glb_cdcooper       AND
                       crapeca.tparquiv = 552                AND
                       crapeca.dscritic BEGINS "EFETUANDO"   
                       EXCLUSIVE-LOCK TRANSACTION:

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                       crapass.nrdconta = crapeca.nrdconta  NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapass   THEN
         NEXT.
         
    /* Pessoa FISICA */
    IF   crapass.inpessoa = 1   THEN
         DO:
             FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                crapttl.nrdconta = crapeca.nrdconta   AND
                                crapttl.idseqttl = crapeca.idseqttl   AND
                                crapttl.indnivel = 4   /* cad. completo */
                                NO-LOCK NO-ERROR.
                       
             IF   NOT AVAILABLE crapttl   THEN
                  DO:
                      /* Se for uma inclusao, gera um erro */
                      IF   crapeca.dscritic MATCHES "*INCLUSAO*"   THEN
                           DO:
                              FIND FIRST crabeca WHERE 
                                                 crabeca.cdcooper = 
                                                          glb_cdcooper      AND
                                                 crabeca.nrdconta =
                                                          crapeca.nrdconta  AND
                                                 crabeca.tparquiv = 505     AND
                                                 crabeca.nrseqarq = 0       AND
                                                 crabeca.nrdcampo = 0
                                                 NO-LOCK NO-ERROR.
                                                       
                              IF   NOT AVAILABLE crabeca   THEN
                                   DO:
                                      CREATE crabeca.
                                      ASSIGN crabeca.nrdconta = 
                                                crapass.nrdconta
                                             crabeca.tparquiv = 505
                                             crabeca.dscritic = "Titular " +
                                                STRING(crapeca.idseqttl,"9") + 
                                                " com cadastro incompleto"
                                             crabeca.cdcooper = glb_cdcooper
                                             crabeca.nrseqarq = 0
                                             crabeca.nrdcampo = 0.
                                      VALIDATE crabeca.
                                      NEXT.
                                   END.
                           END.
                      ELSE
                           DO:
                               /* Como o registro do titular nao existe mais,
                                  pega os dados necessarios da conta */
                                  
                               ASSIGN aux_idseqttl = 2
                                      aux_nrdconta = crapass.nrdconta.
                           END.
                  END.
             ELSE
                  DO:
                     /* Busca o conjuge */
                     FIND crapcje WHERE crapcje.cdcooper = crapttl.cdcooper
                                    AND crapcje.nrdconta = crapttl.nrdconta
                                    AND crapcje.idseqttl = crapttl.idseqttl
                                    NO-LOCK NO-ERROR.
                                    
                     IF   AVAILABLE crapcje   THEN
                          DO:
                             /* Verifica se o conjuge eh associado */
                             FIND FIRST crabttl WHERE crabttl.cdcooper = 
                                                        crapcje.cdcooper   AND
                                                      crabttl.nrdconta =
                                                        crapcje.nrctacje
                                                        NO-LOCK NO-ERROR.
                                                      
                             IF   AVAILABLE crabttl   THEN
                                  ASSIGN aux_nmconjug = crabttl.nmextttl
                                         aux_nrcpfcjg = crabttl.nrcpfcgc
                                         aux_dtnasccj = crabttl.dtnasttl.
                             ELSE
                                  ASSIGN aux_nmconjug = crapcje.nmconjug
                                         aux_nrcpfcjg = crapcje.nrcpfcjg
                                         aux_dtnasccj = crapcje.dtnasccj.
                          END.   
                     ELSE
                          ASSIGN aux_nmconjug = ""
                                 aux_nrcpfcjg = 0
                                 aux_dtnasccj = glb_dtmvtolt.

                     /* tempo de residencia */
                     FIND FIRST crapenc WHERE 
                          crapenc.cdcooper = glb_cdcooper      AND
                          crapenc.nrdconta = crapass.nrdconta  AND
                          crapenc.idseqttl = 1                 AND
                          crapenc.cdseqinc = 1                 NO-LOCK NO-ERROR.

                     IF  AVAILABLE crapenc      AND 
                         crapenc.dtinires <> ?  THEN
                         ASSIGN aux_dtinires = STRING(MONTH(crapenc.dtinires),"99") +
                                               STRING(YEAR(crapenc.dtinires),"9999")
                                aux_incasprp = crapenc.incasprp.
                     ELSE
                         aux_dtinires = STRING(MONTH(glb_dtmvtolt),"99") +
                                        STRING(YEAR(glb_dtmvtolt),"9999").
                            
                            /* sexo */
                     ASSIGN aux_cdsexotl = IF   crapttl.cdsexotl = 1  THEN "M" 
                                                                      ELSE "F"
                     
                            /* Codigo do documento */
                            aux_cddocttl = IF  crapttl.tpdocttl = "CI"  THEN
                                               20
                                           ELSE
                                           IF  crapttl.tpdocttl = "CH"  THEN
                                               31
                                           ELSE
                                               21

                            aux_nrdconta = crapttl.nrdconta
                            aux_idseqttl = crapttl.idseqttl
                            aux_nrcpfcgc = crapttl.nrcpfcgc
                            aux_inpessoa = crapttl.inpessoa
                            aux_dtnasttl = crapttl.dtnasttl
                            aux_nmextttl = crapttl.nmextttl
                            aux_nmtalttl = crapttl.nmtalttl
                            aux_tpnacion = crapttl.tpnacion
                            aux_dsnatura = crapttl.dsnatura
                            aux_nrdocttl = crapttl.nrdocttl
                            aux_dtemdttl = crapttl.dtemdttl
                            aux_cdestcvl = crapttl.cdestcvl
                            aux_cdfrmttl = crapttl.cdfrmttl
                            aux_grescola = crapttl.grescola
                            aux_cdnatopc = crapttl.cdnatopc
                            aux_cdocpttl = crapttl.cdocpttl
                            aux_nmmaettl = crapttl.nmmaettl
                            aux_nmpaittl = crapttl.nmpaittl
                            aux_nrcpfemp = crapttl.nrcpfemp
                            aux_tpcttrab = crapttl.tpcttrab
                            aux_dtadmemp = crapttl.dtadmemp
                            aux_nmextemp = crapttl.nmextemp
                            aux_dsproftl = crapttl.dsproftl
                            aux_cdnvlcgo = crapttl.cdnvlcgo.
                            
                            /* Retornar orgao expedidor */
                            IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                                RUN sistema/generico/procedures/b1wgen0052b.p 
                                    PERSISTENT SET h-b1wgen0052b.

                            ASSIGN aux_cdoedttl = "".
                            RUN busca_org_expedidor IN h-b1wgen0052b 
                                               ( INPUT crapttl.idorgexp,
                                                OUTPUT aux_cdoedttl,
                                                OUTPUT glb_cdcritic, 
                                                OUTPUT glb_dscritic).

                            DELETE PROCEDURE h-b1wgen0052b.   

                            IF  RETURN-VALUE = "NOK" THEN
                            DO:
                                ASSIGN aux_cdoedttl = 'NAO CADAST'.
                            END.
                  END.
         END.
    ELSE
         /* Pessoa JURIDICA ou conta ADMINISTRATIVA - EXCLUSAO DE TITULAR */
         DO:
             FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper     AND
                                crapjur.nrdconta = crapeca.nrdconta   
                                NO-LOCK NO-ERROR.
                       
             IF   NOT AVAILABLE crapjur   THEN
                  DO:
                      /* Se for uma inclusao, gera um erro */
                      IF   crapeca.dscritic MATCHES "*INCLUSAO*"   THEN
                           DO:
                              FIND FIRST crabeca WHERE 
                                         crabeca.cdcooper = glb_cdcooper     AND
                                         crabeca.nrdconta = crapeca.nrdconta AND
                                         crabeca.tparquiv = 505              AND
                                         crabeca.nrseqarq = 0                AND
                                         crabeca.nrdcampo = 0
                                         NO-LOCK NO-ERROR.
                                                       
                              IF   NOT AVAILABLE crabeca   THEN
                                   DO:
                                      CREATE crabeca.
                                      ASSIGN crabeca.nrdconta = crapass.nrdconta
                                             crabeca.tparquiv = 505
                                             crabeca.dscritic = "Associado " +
                                                     "com cadastro incompleto"
                                             crabeca.cdcooper = glb_cdcooper
                                             crabeca.nrseqarq = 0
                                             crabeca.nrdcampo = 0.
                                      VALIDATE crabeca.
                                      NEXT.
                                   END.
                           END.
                      ELSE
                           DO:
                               /* Como o registro do titular nao existe mais,
                                  pega os dados necessarios da conta */
                                  
                               ASSIGN aux_idseqttl = 2
                                      aux_nrdconta = crapass.nrdconta.
                           END.
                  END.
             ELSE     
                  ASSIGN aux_nrdconta = crapass.nrdconta
                         aux_cdsexotl = ""
                         aux_dtinires = ""
                         aux_cddocttl = 0
                         aux_idseqttl = 2
                         aux_nrcpfcgc = 0
                         aux_inpessoa = 2
                         aux_dtnasttl = crapass.dtnasctl
                         aux_nmextttl = crapass.nmprimtl
                         aux_nmtalttl = crapjur.nmtalttl
                         aux_tpnacion = 0
                         aux_dsnatura = ""
                         aux_nrdocttl = ""
                         aux_cdoedttl = ""
                         aux_dtemdttl = glb_dtmvtolt
                         aux_cdestcvl = 0
                         aux_cdfrmttl = 0
                         aux_grescola = 0
                         aux_cdnatopc = 0
                         aux_cdocpttl = 0
                         aux_nmmaettl = ""
                         aux_nmpaittl = ""
                         aux_nmconjug = ""
                         aux_nrcpfcjg = 0
                         aux_dtnasccj = glb_dtmvtolt
                         aux_nrcpfemp = 0
                         aux_tpcttrab = 0
                         aux_dtadmemp = glb_dtmvtolt
                         aux_nmextemp = ""
                         aux_dsproftl = ""
                         aux_cdnvlcgo = 0
                         aux_incasprp = 0.
         END.       
    
    RUN verifica_remessa.
    
    ASSIGN aux_dtabtcc2 = ?.

    /* Data de abertura de conta mais antiga no SFN */
    FOR EACH crapsfn WHERE  crapsfn.cdcooper = glb_cdcooper     AND
                            crapsfn.nrcpfcgc = crapass.nrcpfcgc AND
                            crapsfn.tpregist = 1                NO-LOCK
                                BY crapsfn.dtabtcct DESCENDING:
    
        ASSIGN aux_dtabtcc2 = crapsfn.dtabtcct.                        
                            
    END.
    
    IF  crapass.dtabtcct <> ? AND 
        crapass.dtabtcct <  crapass.dtadmiss THEN
        ASSIGN aux_dtabtcct = crapass.dtabtcct. 
    ELSE
        ASSIGN aux_dtabtcct = crapass.dtadmiss.
    
    IF  aux_dtabtcc2 <> ? AND 
        aux_dtabtcc2 <  aux_dtabtcct THEN
        ASSIGN aux_dtabtcct = aux_dtabtcc2.
    
   
    /* registro tipo 1 */
    ASSIGN aux_nrregist = aux_nrregist + 1
           aux_nrtotcli = aux_nrtotcli + 1
           aux_usatalao = IF crapass.cdsitdct = 1 THEN YES
                                                  ELSE NO
           aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),"x(7)") +
                          STRING(SUBSTRING(crapass.nrdctitg,8,1),"x(1)").
                          
    IF   crapeca.dscritic MATCHES "*INCLUSAO*"   THEN
         aux_dsdlinha = aux_dsdlinha + "3".
    ELSE
         aux_dsdlinha = aux_dsdlinha + "5".
                                   
    ASSIGN aux_dsdlinha = aux_dsdlinha +
                          "0" +
                          STRING(aux_usatalao,"S/N") +
                          STRING(aux_dtabtcct,"99999999") +
                          STRING(aux_idseqttl,"9") +
                          STRING(aux_nrdconta,"99999999") +
                          "         " +
                          "0000". /* Cod. modalidade */
                          /* o restante sao brancos */
                                       
    PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
    PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.

    /* Na exculsao precisa somente do tipo 1 */
    IF   crapeca.dscritic MATCHES "*INCLUSAO*"   THEN
         DO:
            /* registro tipo 2 */
            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                   "x(7)") +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                   "x(1)") +
                                  STRING(aux_nrcpfcgc,"99999999999999")  +
                                  STRING(aux_inpessoa,"9")   +
                                  STRING(aux_dtnasttl,"99999999")  +
                                  STRING(aux_nmextttl,"x(50)")     +
                                  STRING(aux_nmtalttl,"x(25)").
                                  /* o restante sao brancos */
                                       
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "02".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.

            /* registro tipo 3 */                
            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                           "x(7)") +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                           "x(1)") +
                                  STRING(aux_cdsexotl,"x(1)")         +
                                  STRING(aux_tpnacion,"99")       + 
                                  STRING(aux_dsnatura,"x(25)")    + 
                                  STRING(aux_cddocttl,"99")           +
                                  STRING(aux_nrdocttl,"x(20)")    + 
                                  STRING(aux_cdoedttl,"x(15)")    +
                                  STRING(aux_dtemdttl,"99999999") +
                                  STRING(aux_cdestcvl,"99")       +
                                  "01" +
                                  STRING(aux_cdfrmttl,"999")      +
                                  STRING(aux_grescola,"999")      +
                                  STRING(aux_cdnatopc,"999")      +
                                  STRING(aux_cdocpttl,"999")      +
                                  "000000000000100"                   +
                                  STRING(MONTH(glb_dtmvtolt),"99")    +
                                  STRING(YEAR(glb_dtmvtolt),"9999").
                        
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "03".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
                 
                
            /* registro tipo 4 */
            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                   "x(7)") +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                   "x(1)") +
                                  STRING(aux_nmmaettl,"x(50)")    +
                                  STRING(aux_nmpaittl,"x(50)").
                                  /* o restante sao brancos */ 
                                      
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "04".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
                 
            IF   aux_nmconjug <> ""   THEN 
                 DO:
                     /* registro tipo 5 */
                     ASSIGN aux_nrregist = aux_nrregist + 1
                            aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,
                                                  1,7),"x(7)") +
                                           STRING(SUBSTRING(crapass.nrdctitg,
                                                  8,1),"x(1)") +
                                           STRING(aux_nrcpfcjg,"99999999999") +
                                           STRING(aux_dtnasccj,"99999999")    +
                                           STRING(aux_nmconjug,"x(50)").
                                           /* o restante sao brancos */ 
                                       
                     PUT STREAM str_1  aux_nrregist FORMAT "99999" "05".
                     PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
                 END.
                 
            /* registro tipo 6 */
            ASSIGN  glb_nrcalcul = aux_nrcpfemp.

            RUN fontes/cpfcgc.p.

            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                   "x(7)") +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                   "x(1)") +
                                  STRING(aux_tpcttrab,"9")                   +
                                  STRING(shr_inpessoa,"9")                   +
                                  STRING(aux_nrcpfemp,"99999999999999").

            IF   aux_dtadmemp <> ?   THEN
                 aux_dsdlinha = aux_dsdlinha + 
                                STRING(MONTH(aux_dtadmemp),"99")  +
                                STRING(YEAR(aux_dtadmemp),"9999").
            ELSE            
                 aux_dsdlinha = aux_dsdlinha + "      ".
                                       
            aux_dsdlinha = aux_dsdlinha +
                           STRING(aux_nmextemp,"x(50)")       +
                           STRING(aux_dsproftl,"x(50)")       +
                           STRING(aux_cdnvlcgo,"9").
                           /* o restante sao brancos */ 
                                       
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "06".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.

            /* registro tipo 7 */
            ASSIGN aux_nrregist = aux_nrregist + 1.

            FIND FIRST crapenc WHERE crapenc.cdcooper = glb_cdcooper      AND
                                     crapenc.nrdconta = crapass.nrdconta  AND
                                     crapenc.idseqttl = 1                 AND
                                     crapenc.cdseqinc = 1                 
                                     NO-LOCK NO-ERROR.
                                      
            IF   AVAILABLE crapenc   THEN
                 ASSIGN aux_dsdlinha = 
                                   STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                    "x(7)") +
                                   STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                    "x(1)") +
                                   STRING(f_endereco_ctaitg(
                                            INPUT crapenc.dsendere,
                                            INPUT crapenc.nrendere,
                                            INPUT crapenc.nrdoapto,
                                            INPUT crapenc.cddbloco),"x(35)") +
                                   STRING(crapenc.nmbairro,"x(30)")          +
                                   STRING(crapenc.nrcepend,"99999999")       +
                                   SUBSTRING(crapcop.nrtelvoz,2,2)           +
                                   STRING(aux_dstelefo,"x(9)")               +
                                   STRING(crapenc.nrcxapst,"999999999")      +
                                   STRING(aux_incasprp,"99")                 +
                                   STRING(aux_dtinires,"x(6)").
                                   /* o restante sao brancos */
            ELSE
                 /* Endereco da Cooperativa */
                 ASSIGN aux_dsdlinha = 
                                  STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                   "x(7)") +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                   "x(1)") +
                                  STRING((crapcop.dsendcop + ", "           +
                                  STRING(crapcop.nrendcop)),"x(35)")        +
                                  STRING(crapcop.nmbairro,"x(30)")          +
                                  STRING(crapcop.nrcepend,"99999999")       +
                                  SUBSTRING(crapcop.nrtelvoz,2,2)           +
                                  STRING(aux_dstelefo,"x(9)")               +
                                  STRING(crapcop.nrcxapst,"999999999")      +
                                  STRING(aux_incasprp,"99")                 +
                                  STRING(aux_dtinires,"x(6)").
                                  /* o restante sao brancos */ 
                                  
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "07".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.

            /* registro tipo 8 */
            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                   "x(7)") +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                   "x(1)") +
                                  STRING(aux_idseqttl,"9")                   +
                                  SUBSTRING(crapcop.nrtelvoz,2,2)            +
                                  STRING(aux_dstelefo,"x(9)").
                                  /* o restante sao brancos */ 
                                  
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "08".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.

         END. /* Fim INCLUSAO */

    CREATE w_enviados.
    ASSIGN w_enviados.cdagenci = crapass.cdagenci
           w_enviados.nrdconta = crapass.nrdconta
           w_enviados.nrdctitg = crapass.nrdctitg
           w_enviados.idseqttl = aux_idseqttl
           w_enviados.nmextttl = aux_nmextttl.

    DELETE crapeca.

    /* atualiza a data de envio da crapass */
    DO WHILE TRUE:

       FIND crabass WHERE crabass.cdcooper = glb_cdcooper  AND
                          crabass.nrdconta = crapass.nrdconta
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
             
       IF   NOT AVAILABLE crabass   THEN
            DO:
                IF   LOCKED crabass    THEN
                     DO:
                         glb_cdcritic = 72.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
            END.          
       ELSE
            glb_cdcritic = 0.

       LEAVE.

    END.  /*  Fim do DO .. TO  */

    IF   glb_cdcritic > 0 THEN
         RETURN.

    ASSIGN crabass.dtectitg = glb_dtmvtolt.
                      
END. /* Fim das INCLUSOES ou EXCLUSOES */

EMPTY TEMP-TABLE cratalt.

/* Reune todas as alteracoes a serem enviadas em somente uma alteracao */

FOR EACH crapalt WHERE 
        (crapalt.cdcooper = glb_cdcooper   AND
         crapalt.flgctitg = 0)  OR

        (crapalt.cdcooper = glb_cdcooper   AND
         crapalt.flgctitg = 4)             NO-LOCK
         BREAK BY crapalt.nrdconta
                  BY crapalt.dtaltera:

    IF   crapalt.dsaltera MATCHES ("*reativacao conta-itg*")   THEN
         NEXT.

    IF   crapalt.dsaltera MATCHES ("*exclusao conta-itg*")     THEN
         NEXT.

    FIND cratalt WHERE cratalt.cdcooper = glb_cdcooper      AND
                       cratalt.nrdconta = crapalt.nrdconta
                       EXCLUSIVE-LOCK NO-ERROR.

    IF   NOT AVAIL cratalt   THEN
         DO:
             CREATE cratalt.
             ASSIGN cratalt.cdcooper = crapalt.cdcooper
                    cratalt.cdoperad = crapalt.cdoperad
                    cratalt.dsaltera = crapalt.dsaltera
                    cratalt.dtaltera = crapalt.dtaltera
                    cratalt.flgctitg = crapalt.flgctitg
                    cratalt.nrdconta = crapalt.nrdconta
                    cratalt.tpaltera = crapalt.tpaltera.
         END.
    ELSE
         DO:
             /* Verifica as outras alteracoes para juntar as "diferencas" */

             /* Alteracao de Bloqueio/Desbloqueio */
             IF   CAN-DO(crapalt.dsaltera,"blq/dblq")       AND
                  NOT CAN-DO(cratalt.dsaltera,"blq/dblq")   THEN
                  ASSIGN cratalt.dsaltera = cratalt.dsaltera + "blq/dblq,".

         END.
END. /* Fim do FOR EACH */


/* Envio das alteracoes */
FOR EACH  cratalt NO-LOCK,
    FIRST crapass WHERE crapass.cdcooper  = glb_cdcooper       AND
                        crapass.nrdconta  = cratalt.nrdconta   AND
                        crapass.nrdctitg <> ""                 NO-LOCK
                        TRANSACTION
                        BY cratalt.nrdconta:

    /* Pessoa FISICA */
    IF   crapass.inpessoa = 1   THEN
         DO:

             /* Verifica se tem algum titular com cadastro INCOMPLETO */
             FIND FIRST crapttl WHERE crapttl.cdcooper  = glb_cdcooper       AND
                                      crapttl.nrdconta  = crapass.nrdconta   AND
                                      crapttl.indnivel <> 4
                                      NO-LOCK NO-ERROR.
                       
             /* nao processa as alter. do associado */
             IF   AVAILABLE crapttl  THEN
                  DO:
                     FOR EACH crapalt WHERE 
                              crapalt.cdcooper = glb_cdcooper       AND
                              crapalt.nrdconta = crapass.nrdconta   AND
                              crapalt.flgctitg = 0
                              EXCLUSIVE-LOCK:
                                   
                         ASSIGN crapalt.flgctitg = 4.  /* reprocessar */
                     END.

                     FIND FIRST crapeca WHERE crapeca.cdcooper = 
                                                          glb_cdcooper      AND
                                              crapeca.nrdconta =
                                                          crapass.nrdconta  AND
                                              crapeca.tparquiv = 505     AND
                                              crapeca.nrseqarq = 0       AND
                                              crapeca.nrdcampo = 0
                                              NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE crapeca   THEN
                          DO:
                             CREATE crapeca.
                             ASSIGN crapeca.nrdconta = crapass.nrdconta
                                    crapeca.tparquiv = 505
                                    crapeca.dscritic = "Titular " +
                                               STRING(crapttl.idseqttl,"9") + 
                                               " com cadastro incompleto"
                                    crapeca.cdcooper = glb_cdcooper
                                    crapeca.nrseqarq = 0
                                    crapeca.nrdcampo = 0.
                             VALIDATE crapeca.
                          END.
                     NEXT.
                  END.
        
                  
             /*   Verifica Se Tipo de Conta Individual e possui mais 
                  de um Titular  */
             FIND LAST crapttl WHERE crapttl.cdcooper = glb_cdcooper AND
                                     crapttl.nrdconta = crapass.nrdconta
                                     NO-LOCK NO-ERROR.
                      
             IF   AVAILABLE crapttl   THEN
                  DO:
                      IF crapass.cdcatego = 1 AND
                         crapttl.idseqttl > 1 THEN
                           DO:
                               FOR EACH crapalt WHERE 
                                        crapalt.cdcooper = glb_cdcooper     AND
                                        crapalt.nrdconta = crapass.nrdconta AND
                                        crapalt.flgctitg = 0
                                        EXCLUSIVE-LOCK:
                                   
                                   ASSIGN crapalt.flgctitg = 4. /*reprocessar*/
                               END.

                               FIND FIRST crapeca WHERE 
                                        crapeca.cdcooper = glb_cdcooper     AND
                                        crapeca.nrdconta = crapass.nrdconta AND
                                        crapeca.tparquiv = 505              AND
                                        crapeca.nrseqarq = 0                AND
                                        crapeca.nrdcampo = 0
                                        NO-LOCK NO-ERROR.

                               IF   NOT AVAILABLE crapeca   THEN
                                    DO:
                                      CREATE crapeca.
                                      ASSIGN crapeca.nrdconta = crapass.nrdconta
                                             crapeca.tparquiv = 505
                                             crapeca.dscritic = 
                                               "Tipo de Conta nao aceita Mais" +
                                               "Titulares "
                                             crapeca.cdcooper = glb_cdcooper
                                             crapeca.nrseqarq = 0
                                             crapeca.nrdcampo = 0.
                                      VALIDATE crapeca.
                                    END.
                               NEXT.
                           END.
                  END.             
         END. 
    ELSE
         /* Pessoa JURIDICA ou conta ADMINISTRATIVA */
         DO:
             FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper     AND
                                crapjur.nrdconta = cratalt.nrdconta   
                                NO-LOCK NO-ERROR.
                       
             IF   AVAILABLE crapjur   THEN
                  aux_nmtalttl = crapjur.nmtalttl.
             ELSE
                  aux_nmtalttl = "".
                  
             ASSIGN aux_cdsexotl = ""
                    aux_dtinires = ""
                    aux_cddocttl = 0
                    aux_idseqttl = 1
                    aux_nrcpfcgc = crapass.nrcpfcgc
                    aux_inpessoa = 2
                    aux_dtnasttl = crapass.dtnasctl
                    aux_nmextttl = crapass.nmprimtl
                    aux_tpnacion = 0
                    aux_dsnatura = ""
                    aux_nrdocttl = ""
                    aux_cdoedttl = ""
                    aux_dtemdttl = glb_dtmvtolt
                    aux_cdestcvl = 0
                    aux_cdfrmttl = 0
                    aux_grescola = 0
                    aux_cdnatopc = 0
                    aux_cdocpttl = 0
                    aux_nmmaettl = ""
                    aux_nmpaittl = ""
                    aux_nmconjug = ""
                    aux_nrcpfcjg = 0
                    aux_dtnasccj = glb_dtmvtolt
                    aux_nrcpfemp = 0
                    aux_tpcttrab = 0
                    aux_dtadmemp = glb_dtmvtolt
                    aux_nmextemp = ""
                    aux_dsproftl = ""
                    aux_cdnvlcgo = 0
                    aux_incasprp = 0.
         END.

    /* atualiza as alteracoes como enviadas */
    FOR EACH crapalt WHERE crapalt.cdcooper = glb_cdcooper       AND
                           crapalt.nrdconta = crapass.nrdconta   AND
                          (crapalt.flgctitg = 0                  OR
                           crapalt.flgctitg = 4)
                           EXCLUSIVE-LOCK:

        ASSIGN crapalt.flgctitg = 1.
    END.
    

    /* atualiza a data de envio da crapass */
    DO WHILE TRUE:

       FIND crabass WHERE crabass.cdcooper = glb_cdcooper AND
                          crabass.nrdconta = crapass.nrdconta
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
             
       IF   NOT AVAILABLE crabass   THEN
            DO:
                IF   LOCKED craptab   THEN
                     DO:
                         glb_cdcritic = 72.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
            END.          
       ELSE
            glb_cdcritic = 0.

       LEAVE.

    END.  /*  Fim do DO .. TO  */

    IF   glb_cdcritic > 0 THEN
         RETURN.

    ASSIGN crabass.dtectitg = glb_dtmvtolt.

    /* Eliminar criticas anteriores */

    FOR EACH crapeca WHERE crapeca.cdcooper = glb_cdcooper       AND
                           crapeca.nrdconta = crapass.nrdconta   AND
                           crapeca.tparquiv = 505 
                           EXCLUSIVE-LOCK:
        DELETE crapeca.
    END.                      
       
    RUN verifica_remessa.
    
    ASSIGN aux_dtabtcc2 = ?.
    
    /* Data de abertura de conta mais antiga no SFN */
    FOR EACH crapsfn WHERE  crapsfn.cdcooper = glb_cdcooper     AND
                            crapsfn.nrcpfcgc = crapass.nrcpfcgc AND
                            crapsfn.tpregist = 1                NO-LOCK
                                BY crapsfn.dtabtcct DESCENDING:
    
        ASSIGN aux_dtabtcc2 = crapsfn.dtabtcct.                        
                            
    END.
    
    IF  crapass.dtabtcct <> ? AND 
        crapass.dtabtcct <  crapass.dtadmiss THEN
        ASSIGN aux_dtabtcct = crapass.dtabtcct. 
    ELSE
        ASSIGN aux_dtabtcct = crapass.dtadmiss.
    
    IF  aux_dtabtcc2 <> ? AND 
        aux_dtabtcc2 <  aux_dtabtcct THEN
        ASSIGN aux_dtabtcct = aux_dtabtcc2.
    
    
    /* Pessoa JURIDICA */
    IF   crapass.inpessoa <> 1   THEN
         DO:
             RUN gera_arquivo.
             NEXT.
         END.
    
    FOR EACH crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                           crapttl.nrdconta = crapass.nrdconta   NO-LOCK:

        /* Busca o conjuge */
        FIND crapcje WHERE crapcje.cdcooper = crapttl.cdcooper   AND
                           crapcje.nrdconta = crapttl.nrdconta   AND
                           crapcje.idseqttl = crapttl.idseqttl
                           NO-LOCK NO-ERROR.
                                    
        IF   AVAILABLE crapcje   THEN
             DO:
                 /* Verifica se o conjuge eh associado */
                 FIND FIRST crabttl WHERE crabttl.cdcooper = crapcje.cdcooper
                                      AND crabttl.nrdconta = crapcje.nrctacje
                                          NO-LOCK NO-ERROR.
                                                      
                 IF   AVAILABLE crabttl   THEN
                      ASSIGN aux_nmconjug = crabttl.nmextttl
                             aux_nrcpfcjg = crabttl.nrcpfcgc
                             aux_dtnasccj = crabttl.dtnasttl.
                 ELSE
                      ASSIGN aux_nmconjug = crapcje.nmconjug
                             aux_nrcpfcjg = crapcje.nrcpfcjg
                             aux_dtnasccj = crapcje.dtnasccj.
             END.
        ELSE
             ASSIGN aux_nmconjug = ""
                    aux_nrcpfcjg = 0
                    aux_dtnasccj = glb_dtmvtolt.

        /* tempo de residencia */
        FIND FIRST crapenc WHERE crapenc.cdcooper = glb_cdcooper     AND
                                 crapenc.nrdconta = crapass.nrdconta AND
                                 crapenc.idseqttl = 1                AND
                                 crapenc.cdseqinc = 1                
                                 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapenc      AND 
            crapenc.dtinires <> ?  THEN
            ASSIGN aux_dtinires = STRING(MONTH(crapenc.dtinires), "99") +
                                  STRING(YEAR(crapenc.dtinires), "9999")
                   aux_incasprp = crapenc.incasprp.
        ELSE
            aux_dtinires = STRING(MONTH(glb_dtmvtolt), "99") +
                           STRING(YEAR(glb_dtmvtolt), "9999").
               
               /* sexo */
        ASSIGN aux_cdsexotl = IF   crapttl.cdsexotl = 1  THEN "M" 
                                                         ELSE "F"
                     
               /* Codigo do documento */
               aux_cddocttl = IF   crapttl.tpdocttl = "CI"   THEN
                                   20
                              ELSE
                              IF   crapttl.tpdocttl = "CH"   THEN
                                   31
                              ELSE
                                   21
                                                                  
               aux_idseqttl = crapttl.idseqttl
               aux_nrcpfcgc = crapttl.nrcpfcgc
               aux_inpessoa = crapttl.inpessoa
               aux_dtnasttl = crapttl.dtnasttl
               aux_nmextttl = crapttl.nmextttl
               aux_nmtalttl = crapttl.nmtalttl
               aux_tpnacion = crapttl.tpnacion
               aux_dsnatura = crapttl.dsnatura
               aux_nrdocttl = crapttl.nrdocttl
               aux_dtemdttl = crapttl.dtemdttl
               aux_cdestcvl = crapttl.cdestcvl
               aux_cdfrmttl = crapttl.cdfrmttl
               aux_grescola = crapttl.grescola
               aux_cdnatopc = crapttl.cdnatopc
               aux_cdocpttl = crapttl.cdocpttl
               aux_nmmaettl = crapttl.nmmaettl
               aux_nmpaittl = crapttl.nmpaittl
               aux_nrcpfemp = crapttl.nrcpfemp
               aux_tpcttrab = crapttl.tpcttrab
               aux_dtadmemp = crapttl.dtadmemp
               aux_nmextemp = crapttl.nmextemp
               aux_dsproftl = crapttl.dsproftl
               aux_cdnvlcgo = crapttl.cdnvlcgo.
               
        /* Retornar orgao expedidor */
        IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p 
                PERSISTENT SET h-b1wgen0052b.

        ASSIGN aux_cdoedttl = "".
        RUN busca_org_expedidor IN h-b1wgen0052b 
                           ( INPUT crapttl.idorgexp,
                            OUTPUT aux_cdoedttl,
                            OUTPUT glb_cdcritic, 
                            OUTPUT glb_dscritic).

        DELETE PROCEDURE h-b1wgen0052b.   

        IF  RETURN-VALUE = "NOK" THEN
        DO:
            ASSIGN aux_cdoedttl = 'NAO CADAST'.
        END.       

        RUN gera_arquivo.
        
        IF   aux_cdaltera = 1   OR    /* Alteracao de bloqueio */
             aux_cdaltera = 2   THEN  /* Encerramento da conta ITG */
             LEAVE.                   /* Somente pro 1o titular */
   END.
         
END.

RUN fecha_arquivo.

RUN rel_enviados. /* relatorio de titulares enviados */

RUN fontes/fimprg.p.

PROCEDURE abre_arquivo.

   ASSIGN aux_nrtextab = INTEGER(SUBSTRING(craptab.dstextab,1,5))
          aux_nmarqimp = "coo405" +
                         STRING(DAY(glb_dtmvtolt),"99") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(aux_nrtextab,"99999") + ".rem"
          aux_nrregist = 0
          aux_nrtotcli = 0.
       
   OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarqimp).

   /* header */
   ASSIGN aux_dsdlinha = "0000000"  +
                         STRING(crapcop.cdageitg,"9999") + 
                         STRING(crapcop.nrctaitg,"99999999") + 
                         "COO405  " + 
                         STRING(aux_nrtextab,"99999")  +
                         STRING(glb_dtmvtolt,"99999999")  +
                         STRING(crapcop.cdcnvitg,"999999999") + 
                         STRING(crapcop.cdmasitg,"99999").
                      
   PUT STREAM str_1  aux_dsdlinha SKIP.

END PROCEDURE.

PROCEDURE fecha_arquivo.

   /* trailer */
                         /* total de registros + header + trailer */
   ASSIGN aux_nrregist = aux_nrregist + 2
          aux_dsdlinha = "9999999"  +
                         "        " + 
                         STRING(aux_nrtotcli,"99999") + 
                         STRING(aux_nrregist,"999999999").
                         /* o restante sao brancos */
                         
   PUT STREAM str_1 aux_dsdlinha.

   OUTPUT STREAM str_1 CLOSE.

   /* verifica se o arquivo gerado nao tem registros "detalhe" */
   IF   aux_nrregist <= 2   THEN
        DO:
            UNIX SILENT VALUE("rm arq/" + aux_nmarqimp + " 2>/dev/null"). 
            LEAVE.        
        END.
     
   glb_cdcritic = 847.
   RUN fontes/critic.p.
            
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                     " - COO405 - " + glb_cdprogra + "' --> '"  + 
                     glb_dscritic + " - " + aux_nmarqimp +  
                     " >> " + aux_nmarqlog).
      
   /* copia o arquivo para diretorio "compel" para poder ser enviado ao BB */
   UNIX SILENT VALUE("ux2dos < arq/" + aux_nmarqimp +  
                     ' | tr -d "\032"' +  
                     " > /micros/" + crapcop.dsdircop +
                     "/compel/" + aux_nmarqimp + " 2>/dev/null").  

   UNIX SILENT VALUE("mv arq/" + aux_nmarqimp + " salvar 2>/dev/null"). 

   /* Atualizacao da craptab */
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "NRARQMVITG"   AND
                      craptab.tpregist = 405            NO-ERROR.
                   
   ASSIGN SUBSTRING(craptab.dstextab,1,5) = STRING(aux_nrtextab + 1,"99999").
 

END PROCEDURE.


PROCEDURE verifica_remessa.

   /* verifica se e possivel colocar os registros dos titulares da conta */
   FIND LAST crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND
                           crapttl.nrdconta = crapass.nrdconta NO-LOCK NO-ERROR.

   ASSIGN /* quantidade de titulares */
          aux_contador = IF  AVAILABLE crapttl  THEN crapttl.idseqttl
                                                ELSE 1
          /* quantidade de titulares * 7 registros cada titular */
          aux_contador = aux_contador * 7.
   
   /* Limite de 49990 registros */
   IF   aux_nrregist > (49988 - aux_contador)   THEN
        DO:
            RUN fecha_arquivo.
            RUN abre_arquivo.
            RUN verifica_remessa.   /* para ver se no novo arquivo aberto */
                                    /* pode incluir os registros          */
        END.
   
END PROCEDURE.

PROCEDURE rel_enviados.

    ASSIGN aux_nmarqrel = "rl/crrl381.lst"
           aux_contador = 0.

    { includes/cabrel132_1.i }  /* Monta o cabecalho */
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) PAGED PAGE-SIZE 84.
    
    VIEW STREAM str_1 FRAME f_cabrel132_1.
       
    FOR EACH w_enviados NO-LOCK USE-INDEX w_enviados1
                                BREAK BY w_enviados.cdagenci
                                        BY w_enviados.nrdconta:
    
        IF   FIRST-OF(w_enviados.cdagenci)   THEN
             DO:
                 FIND crapage WHERE crapage.cdcooper = glb_cdcooper        AND
                                    crapage.cdagenci = w_enviados.cdagenci
                                    NO-LOCK NO-ERROR.
                                
                 rel_dsagenci = STRING(crapage.cdagenci,"zz9") + " - " +
                                crapage.nmresage.
             END.
    
        DISPLAY STREAM str_1
                rel_dsagenci          WHEN FIRST-OF(w_enviados.cdagenci)
                w_enviados.nrdconta   WHEN FIRST-OF(w_enviados.nrdconta)
                w_enviados.nrdctitg   WHEN FIRST-OF(w_enviados.nrdconta)
                w_enviados.idseqttl   
                w_enviados.nmextttl
                WITH FRAME f_enviados.
            
        DOWN STREAM str_1 WITH FRAME f_enviados.
    
        IF   LAST-OF(w_enviados.nrdconta)   THEN  /*pular linha a cada conta*/
             PUT STREAM str_1 SKIP(1).
            
        aux_contador = aux_contador + 1.

    END.

    PUT STREAM str_1 "TOTAL DE TITULARES: " AT 5
                     aux_contador FORMAT "zzz,zz9" SKIP.
                 
    OUTPUT STREAM str_1 CLOSE.

    ASSIGN glb_nrcopias = 1
           glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarqrel.
    
    RUN fontes/imprim.p. 
     
END PROCEDURE.

PROCEDURE gera_arquivo:
        
    aux_bloqueio = 0.
    
    IF   aux_bloqueio <> 0   THEN
         aux_cdaltera = 1.  /* Altera dados da conta - bloqueio/desbloqueio */
    ELSE
         aux_cdaltera = 4.  /* Altera dados do titular */
    
    /* registro tipo 1 */
    ASSIGN aux_nrregist = aux_nrregist + 1
           aux_nrtotcli = aux_nrtotcli + 1
           aux_usatalao = IF crapass.cdsitdct = 1 THEN YES
                                                  ELSE NO

           aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),"x(7)") +
                          STRING(SUBSTRING(crapass.nrdctitg,8,1),"x(1)") +
                          STRING(aux_cdaltera,"9") +
                          STRING(aux_bloqueio,"9") +
                          STRING(aux_usatalao,"S/N") +
                          STRING(aux_dtabtcct,"99999999") +
                          STRING(aux_idseqttl,"9") +
                          STRING(cratalt.nrdconta,"99999999") +
                          "         " +      
                          "0000". /* Cod. modalidade */
                          /* o restante sao brancos */
                                   
    PUT STREAM str_1  aux_nrregist FORMAT "99999" "01".
    PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.

    /* registro tipo 2 */
    ASSIGN aux_nrregist = aux_nrregist + 1
           aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),"x(7)") +
                          STRING(SUBSTRING(crapass.nrdctitg,8,1),"x(1)") +
                          STRING(aux_nrcpfcgc,"99999999999999")  +
                          STRING(aux_inpessoa,"9")   +
                          STRING(aux_dtnasttl,"99999999")  +
                          STRING(aux_nmextttl,"x(50)")     +
                          STRING(aux_nmtalttl,"x(25)").
                          /* o restante sao brancos */
                                   
    PUT STREAM str_1  aux_nrregist FORMAT "99999" "02".
    PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.

    /* Somente pessoa FISICA */
    IF   aux_inpessoa = 1   THEN
         DO:
            /* registro tipo 3 */
            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                         "x(7)")                          +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                         "x(1)")                          +
                                  STRING(aux_cdsexotl,"x(1)")             +
                                  STRING(aux_tpnacion,"99")               + 
                                  STRING(aux_dsnatura,"x(25)")            + 
                                  STRING(aux_cddocttl,"99")               +
                                  STRING(aux_nrdocttl,"x(20)")            +  
                                  STRING(aux_cdoedttl,"x(15)")            +
                                  STRING(aux_dtemdttl,"99999999")         +
                                  STRING(aux_cdestcvl,"99")               +
                                  "01"                                    +
                                  STRING(aux_cdfrmttl,"999")              +
                                  STRING(aux_grescola,"999")              +
                                  STRING(aux_cdnatopc,"999")              +
                                  STRING(aux_cdocpttl,"999")              +
                                  "000000000000100"                       +
                                  STRING(MONTH(glb_dtmvtolt),"99")        +
                                  STRING(YEAR(glb_dtmvtolt),"9999").
                    
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "03".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
             
            /* registro tipo 4 */
            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                         "x(7)")                          +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                         "x(1)")                          +
                                  STRING(aux_nmmaettl,"x(50)")            +
                                  STRING(aux_nmpaittl,"x(50)").
                                  /* o restante sao brancos */ 
                                   
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "04".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
             

            IF   aux_nmconjug <> ""   THEN 
                 DO:
                     /* registro tipo 5 */
                     ASSIGN aux_nrregist = aux_nrregist + 1
                            aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,
                                                            1,7),"x(7)")      +
                                           STRING(SUBSTRING(crapass.nrdctitg,
                                                            8,1),"x(1)")      +
                                           STRING(aux_nrcpfcjg,"99999999999") +
                                           STRING(aux_dtnasccj,"99999999")    +
                                           STRING(aux_nmconjug,"x(50)").
                                           /* o restante sao brancos */ 
                                   
                     PUT STREAM str_1  aux_nrregist FORMAT "99999" "05".
                     PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.
                 END.
             
            /* registro tipo 6 */
            ASSIGN glb_nrcalcul = aux_nrcpfemp.

            RUN fontes/cpfcgc.p.

            ASSIGN aux_nrregist = aux_nrregist + 1
                   aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                         "x(7)")                          +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                         "x(1)")                          +
                                  STRING(aux_tpcttrab,"9")                +
                                  STRING(shr_inpessoa,"9")                +
                                  STRING(aux_nrcpfemp,"99999999999999").

            IF   aux_dtadmemp <> ?   THEN
                 aux_dsdlinha = aux_dsdlinha + 
                                STRING(MONTH(aux_dtadmemp),"99")  +
                                STRING(YEAR(aux_dtadmemp),"9999").
            ELSE
                 aux_dsdlinha = aux_dsdlinha + "      ".
                                   
            aux_dsdlinha = aux_dsdlinha +
                           STRING(aux_nmextemp,"x(50)")       +
                           STRING(aux_dsproftl,"x(50)")       +
                           STRING(aux_cdnvlcgo,"9").
                           /* o restante sao brancos */ 
                                   
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "06".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.

            /* registro tipo 7 */
            ASSIGN aux_nrregist = aux_nrregist + 1.
                   
            FIND FIRST crapenc WHERE crapenc.cdcooper = glb_cdcooper      AND
                                     crapenc.nrdconta = crapass.nrdconta  AND
                                     crapenc.idseqttl = 1                 AND
                                     crapenc.cdseqinc = 1 
                                     NO-LOCK NO-ERROR.

            IF   AVAILABLE crapenc  THEN
                 ASSIGN aux_dsdlinha =
                                    STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                     "x(7)")                 +
                                    STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                     "x(1)")                 +
                                    STRING(f_endereco_ctaitg(
                                            INPUT crapenc.dsendere,
                                            INPUT crapenc.nrendere,
                                            INPUT crapenc.nrdoapto,
                                            INPUT crapenc.cddbloco),"x(35)") +
                                    STRING(crapenc.nmbairro,"x(30)")         +
                                    STRING(crapenc.nrcepend,"99999999")      +
                                    SUBSTRING(crapcop.nrtelvoz,2,2)          +
                                    STRING(aux_dstelefo,"x(9)")              +
                                    STRING(crapenc.nrcxapst,"999999999")     +
                                    STRING(aux_incasprp,"99")                +
                                    STRING(aux_dtinires,"x(6)").
                                    /* o restante sao brancos */ 
            ELSE
                 /* Endereco da Cooperativa */
                 ASSIGN aux_dsdlinha = 
                                  STRING(SUBSTRING(crapass.nrdctitg,1,7),
                                                   "x(7)") +
                                  STRING(SUBSTRING(crapass.nrdctitg,8,1),
                                                   "x(1)") +
                                  STRING((crapcop.dsendcop + ", "           +
                                  STRING(crapcop.nrendcop)),"x(35)")        +
                                  STRING(crapcop.nmbairro,"x(30)")          +
                                  STRING(crapcop.nrcepend,"99999999")       +
                                  SUBSTRING(crapcop.nrtelvoz,2,2)           +
                                  STRING(aux_dstelefo,"x(9)")               +
                                  STRING(crapcop.nrcxapst,"999999999")      +
                                  STRING(aux_incasprp,"99")                 +
                                  STRING(aux_dtinires,"x(6)").
                                  /* o restante sao brancos */
                              
            PUT STREAM str_1  aux_nrregist FORMAT "99999" "07".
            PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.

         END. /* Fim - Pessoa FISICA */

    /* registro tipo 8 */
    ASSIGN aux_nrregist = aux_nrregist + 1
           aux_dsdlinha = STRING(SUBSTRING(crapass.nrdctitg,1,7),"x(7)") +
                          STRING(SUBSTRING(crapass.nrdctitg,8,1),"x(1)") +
                          STRING(aux_idseqttl,"9")                   +
                          SUBSTRING(crapcop.nrtelvoz,2,2)                +
                          STRING(aux_dstelefo,"x(9)").
                          /* o restante sao brancos */ 
                              
    PUT STREAM str_1  aux_nrregist FORMAT "99999" "08".
    PUT STREAM str_1  aux_dsdlinha FORMAT "x(143)" SKIP.

         
    FIND FIRST w_enviados WHERE w_enviados.nrdconta = crapass.nrdconta  AND
                                w_enviados.idseqttl = aux_idseqttl
                                NO-LOCK NO-ERROR.
                                
    IF   AVAILABLE w_enviados   THEN
         RETURN.
    
    CREATE w_enviados.
    ASSIGN w_enviados.cdagenci = crapass.cdagenci
           w_enviados.nrdconta = crapass.nrdconta
           w_enviados.nrdctitg = crapass.nrdctitg
           w_enviados.idseqttl = aux_idseqttl
           w_enviados.nmextttl = aux_nmextttl.
    
END PROCEDURE.

/*...........................................................................*/


