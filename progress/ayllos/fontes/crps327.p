/* ..........................................................................

   Programa: Fontes/crps327.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo        
   Data    : Setembro/2002                   Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 1 - ordem 4.
               Processamento de devolucoes dos depositos em cheques que foram
               devolvidos.
               Emite relatorio 277 e 276.

   Alteracoes: 28/12/2002 - Verificar se o LCM esta cadastrado antes de Cria-lo
                            (Ze Eduardo).
               08/01/2003 - Tratar contas isentas de tarifa (Deborah)
               
               12/02/2003 - Tratamento de nrcheque iguais (Ze Eduardo).
               
               06/05/2003 - Tratamento de cheques bloqueados (Ze Eduardo).
               
               28/05/2003 - Acerto no historico crapdpb (Ze Eduardo).
               
               26/06/2003 - Acerto na data liberacao do bloq. (Ze Eduardo).
               
               26/06/2003 - Atualizacao no cadastro de crapcec. (Ze Eduardo).
               
               07/07/2003 - Tratamento erro quando nao achar o arq. (Ze).
               
               30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            craplcm (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               07/10/2005 - Alterado para ler tbm na tabela crapali o codigo
                            da cooperativa (Diego).
                            
               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder 
                          
               18/04/2007 - Alterado relatorio 277, para imprimir 2 vias na
                            mesma folha (Elton).
               
               01/06/2007 - Efetuar apenas 1 copia de impressao ref. rel.277
                            (Guilherme).
                            
               06/06/2007 - Verifica se eh devolucao de cheque descontado
                            e lanca com o historico 399 (Ze).
                            
               04/07/2007 - Envia email avisando que nao existe arquivo para
                            ser integrado (Elton).
               
               27/08/2007 - Nao enviar email(Guilherme).
               
               12/08/2008 - Estava gerando o total na primeira pagina(Guilherme)

               16/09/2008 - Retirado log no proc_batch.log quando cheque for
                            inexistente, gerar nova critica no caso de
                            caracteres invalidos e incluido conta do cheque
                            no form f_lanc_erro_276 (Gabriel).
               
               13/04/2009 - Alterada a forma de verificar se o registro lido eh
                            o trailer do arquivo (Elton).

               06/08/2009 - Diferenciar do lanctos BB e Bancoob atraves do
                            campo craplcm.dsidenti  (Ze).
                            
               05/03/2010 - Tratamento para cheques custodiados (Ze).

               15/09/2010 - Acertar nome do arquivo a ser lido. Estava
                            entrando arquivos da nossa IF (Magui).
                            
               01/10/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               31/10/2013 - Alterado para nao utilizar telefone da crapass mas 
                            sim da craptfc.
                          - Alterado totalizador de 99 para 999. (Reinert)
                          
               21/01/2014 - Incluir VALIDATE craplot, craplcm (Lucas R.) 

	           24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).


............................................................................. */

DEF STREAM str_1.   /*  Para relatorio - 277        */
DEF STREAM str_2.   /*  Para relatorio - 276 PA     */
DEF STREAM str_3.   /*  Para relatorio - 276 TOTAL  */
DEF STREAM str_4.   /*  Para arquivo                */
DEF STREAM str_5.   /*  Para arquivo                */

{ includes/var_batch.i }   
{ sistema/generico/includes/b1wgen0200tt.i }

DEF TEMP-TABLE crawrel                                               NO-UNDO
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrfonres AS CHAR
    FIELD cdcmpchq LIKE crapchd.cdcmpchq 
    FIELD cdagechq LIKE crapchd.cdagechq
    FIELD cdbanchq LIKE crapchd.cdbanchq
    FIELD nrctachq LIKE crapchd.nrctachq
    FIELD nrcheque LIKE crapchd.nrcheque
    FIELD nralinea AS INTEGER
    FIELD vlcheque LIKE crapchd.vlcheque
    INDEX crawrel1 AS PRIMARY
          cdagenci nrdconta nrcheque.


DEF TEMP-TABLE rel277                                                NO-UNDO
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nmsegntl LIKE crapttl.nmextttl
    FIELD nrfonres AS CHAR
    FIELD cdbanchq LIKE crapchd.cdbanchq
    FIELD nrcheque LIKE crapchd.nrcheque
    FIELD nralinea AS INTEGER
    FIELD vlcheque LIKE crapchd.vlcheque
    FIELD auxaline AS CHAR
    FIELD auxqtdch AS INTEGER
    FIELD totchequ AS DECIMAL.

                      
DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR                                  NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.
                                                                           
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqdeb AS CHAR                                  NO-UNDO.
DEF        VAR aux_setlinha AS CHAR    FORMAT "x(161)"               NO-UNDO.
DEF        VAR tab_nmarquiv AS CHAR    FORMAT "x(25)"   EXTENT 99    NO-UNDO.
DEF        VAR i            AS INT                                   NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgrejei AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgerro2 AS LOGICAL                               NO-UNDO.

DEF        VAR aux_diarefer AS INT                                   NO-UNDO.
DEF        VAR aux_mesrefer AS INT                                   NO-UNDO.
DEF        VAR aux_anorefer AS INT                                   NO-UNDO.
DEF        VAR aux_dtauxili AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqrl1 AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqrl2 AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrodomes AS CHAR                                  NO-UNDO.
DEF        VAR aux_contareg AS INT                                   NO-UNDO.
DEF        VAR aux_vltarifa AS DECIMAL                               NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_dsalinea AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrcheque AS DECIMAL                               NO-UNDO.
 
DEF        VAR aux_qtdecheq AS INT                                   NO-UNDO.
DEF        VAR aux_totdcheq AS DECIMAL                               NO-UNDO.
DEF        VAR tot_qtdecheq AS INT                                   NO-UNDO.
DEF        VAR tot_totdcheq AS DECIMAL                               NO-UNDO.
DEF        VAR aux_lscontas AS CHAR                                  NO-UNDO.   

DEF        VAR aux_cdbanchq AS INT                                   NO-UNDO.
DEF        VAR aux_cdagechq AS INT                                   NO-UNDO.
DEF        VAR aux_nrctachq AS DEC                                   NO-UNDO.
DEF        VAR aux_nrdocheq AS INT                                   NO-UNDO.

DEF        VAR h-b1wgen0200 AS HANDLE                                NO-UNDO.
DEF        VAR aux_incrineg AS INT                                   NO-UNDO.
DEF        VAR aux_cdcritic AS INT                                   NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.

FORM aux_setlinha  FORMAT "x(161)"
     WITH FRAME AA WIDTH 161 NO-BOX NO-LABELS.

FORM SKIP(1) 
     crawrel.cdagenci   AT 02  FORMAT "zz9"             LABEL "PA"
     crawrel.nrdconta   AT 16  FORMAT "zzzz,zz9,9"      LABEL "CONTA/DV"
     " - "              AT 36
     crawrel.nmprimtl   AT 42  FORMAT "x(37)"           NO-LABEL
     SKIP
     crawrel.nrfonres   AT 16  FORMAT "x(40)"           LABEL "FONE"
     SKIP(1)
     "RELACAO DE CHEQUES DEVOLVIDOS:"   AT 01                
     SKIP(1)
     "BANCO"            AT 01                           
     "CHEQUE"           AT 16                           
     "ALINEA"           AT 30                           
     "VALOR"            AT 76                           
     SKIP(1)
     WITH NO-BOX DOWN SIDE-LABELS WIDTH 80 FRAME f_cabec_277.

FORM crawrel.cdbanchq   AT 01  FORMAT "zz9"          
     crawrel.nrcheque   AT 15  FORMAT "zzz,zzz,zzz,zz9"
     crawrel.nralinea   AT 33  FORMAT "z9"
     " - "              AT 35
     aux_dsalinea       AT 38  FORMAT "x(25)"
     crawrel.vlcheque   AT 68  FORMAT "zz,zzz,zz9.99"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lanc_277.

FORM SKIP(1)
     "TOTAL -->"        AT 01
     aux_qtdecheq       AT 15  FORMAT "zzz,zz9"               NO-LABEL
     aux_totdcheq       AT 63  FORMAT "zzz,zzz,zzz,zz9.99"    NO-LABEL
     SKIP(3)  
     "TERMO    DE    RECEBIMENTO"   AT 28
     SKIP(3)
  "Declaro   para  os  devidos  fins,  ter  recebido  o(s)  documento(s)  acima"
     AT 5   SKIP(1)
     "especificado(s) em ____/____/______ ."  AT 01
     "Tarifa para cada cheque  R$"   AT 39
     aux_vltarifa       AT 70 FORMAT "zz9.99"                 NO-LABEL
     SKIP(3)
     "TITULAR"             AT 01 SKIP(5)         
     "-----------------------------------"       AT 01 
     "-------------------------"                 AT 50
     SKIP 
     crawrel.nmprimtl     AT 01  FORMAT "x(40)"         NO-LABEL
     "Cadastro e Visto"   AT 56
     crawrel.nrdconta     AT 01  FORMAT "zzzz,zz9,9"    LABEL "CONTA/DV"
     WITH NO-BOX SIDE-LABEL DOWN WIDTH 80 FRAME f_total_277.

FORM SKIP(1)
     "TOTAL -->"        AT 01
     aux_qtdecheq       AT 15  FORMAT "zzz,zz9"               NO-LABEL
     aux_totdcheq       AT 63  FORMAT "zzz,zzz,zzz,zz9.99"    NO-LABEL
     SKIP(3)   
     "TERMO    DE    RECEBIMENTO"   AT 28
     SKIP(3)
  "Declaro   para  os  devidos  fins,  ter  recebido  o(s)  documento(s)  acima"
     AT 5   SKIP(1)
     "especificado(s) em ____/____/______ ."  AT 01  
     SKIP(3)
     "TITULAR"             AT 01 SKIP(5)  
     "-----------------------------------"       AT 01 
     "-------------------------"                 AT 50
     SKIP 
     crawrel.nmprimtl     AT 01  FORMAT "x(40)"         NO-LABEL
     "Cadastro e Visto"   AT 56
     crawrel.nrdconta     AT 01  FORMAT "zzzz,zz9,9"    LABEL "CONTA/DV"
     WITH NO-BOX SIDE-LABEL DOWN WIDTH 80 FRAME f_total_isento_277.

/****Para 2 via ****/

FORM SKIP(1) 
     rel277.cdagenci    AT 02  FORMAT "zz9"             LABEL "PA"
     rel277.nrdconta    AT 16  FORMAT "zzzz,zz9,9"      LABEL "CONTA/DV"
     " - "              AT 36
     rel277.nmprimtl    AT 42  FORMAT "x(37)"           NO-LABEL
     SKIP
     rel277.nrfonres    AT 16  FORMAT "x(40)"           LABEL "FONE"
     SKIP(1)
     "RELACAO DE CHEQUES DEVOLVIDOS:"   AT 01                
     SKIP(1)
     "BANCO"            AT 01                           
     "CHEQUE"           AT 16                           
     "ALINEA"           AT 30                           
     "VALOR"            AT 76                           
     SKIP(1)
     WITH NO-BOX DOWN SIDE-LABELS WIDTH 80 FRAME f_cabec_rel277.

FORM rel277.cdbanchq    AT 01  FORMAT "zz9"          
     rel277.nrcheque    AT 15  FORMAT "zzz,zzz,zzz,zz9"
     rel277.nralinea    AT 33  FORMAT "z9"
     " - "              AT 35
     rel277.auxaline    AT 38  FORMAT "x(25)"
     rel277.vlcheque    AT 68  FORMAT "zz,zzz,zz9.99"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lanc_rel277.

FORM SKIP(1)
     "TOTAL -->"        AT 01
     rel277.auxqtdch    AT 15  FORMAT "zzz,zz9"               NO-LABEL
     rel277.totchequ    AT 63  FORMAT "zzz,zzz,zzz,zz9.99"    NO-LABEL
     SKIP(2)  
     "TERMO    DE    RECEBIMENTO"   AT 28
     SKIP(3)
  "Declaro   para  os  devidos  fins,  ter  recebido  o(s)  documento(s)  acima"
     AT 5   SKIP(1)
     "especificado(s) em ____/____/______ ."  AT 01      
     SKIP(3)
     "TITULAR"             AT 01 SKIP(5)          
     "-----------------------------------"       AT 01 
     "-------------------------"                 AT 50
     SKIP 
     rel277.nmprimtl      AT 01  FORMAT "x(40)"         NO-LABEL
     "Cadastro e Visto"   AT 56
     rel277.nrdconta      AT 01  FORMAT "zzzz,zz9,9"    LABEL "CONTA/DV"
     WITH NO-BOX SIDE-LABEL DOWN WIDTH 80 FRAME f_total_isento_rel277.

FORM SKIP(1)
     "TOTAL -->"        AT 01
     rel277.auxqtdch    AT 15  FORMAT "zzz,zz9"               NO-LABEL
     rel277.totchequ    AT 63  FORMAT "zzz,zzz,zzz,zz9.99"    NO-LABEL
     SKIP(2)  
     "TERMO    DE    RECEBIMENTO"   AT 28
     SKIP(3)
  "Declaro   para  os  devidos  fins,  ter  recebido  o(s)  documento(s)  acima"
     AT 5   SKIP(1)
     "especificado(s) em ____/____/______ ."  AT 01      
     "Tarifa para cada cheque  R$"   AT 39
     aux_vltarifa       AT 70 FORMAT "zz9.99"                 NO-LABEL
     SKIP(3)
     "TITULAR"             AT 01 SKIP(5)          
     "-----------------------------------"       AT 01 
     "-------------------------"                 AT 50
     SKIP 
     rel277.nmprimtl      AT 01  FORMAT "x(40)"         NO-LABEL
     "Cadastro e Visto"   AT 56
     rel277.nrdconta      AT 01  FORMAT "zzzz,zz9,9"    LABEL "CONTA/DV"
     WITH NO-BOX SIDE-LABEL DOWN WIDTH 80 FRAME f_total_rel277.


FORM SKIP(3)
     "DEVOLUCOES NAO PROCESSADAS"      AT 28
     SKIP(3)
     WITH NO-BOX WIDTH 80 FRAME f_cabec_erro_276.

FORM crawrel.nmprimtl   AT 01  FORMAT "x(40)"       LABEL "DESCRICAO DO ERRO"
     crawrel.nrdconta   AT 62  FORMAT "zzz,zz9,9"   LABEL "CONTA/DV"
     SKIP
     crawrel.cdcmpchq   AT 01  FORMAT "zz9"         LABEL "COMP."
     crawrel.cdbanchq   AT 21  FORMAT "zz9"         LABEL "BANCO"
     crawrel.cdagechq   AT 39  FORMAT "zzz9"        LABEL "AGENCIA"
     crawrel.vlcheque   AT 57  FORMAT "zz,zzz,zzz,zz9.99"  LABEL "VALOR"
     SKIP
     crawrel.nralinea   AT 01  FORMAT "z9"          LABEL "ALINEA"
     crawrel.nrcheque   AT 21  FORMAT "zzz,zzz,zzz,zz9"     LABEL "CHEQUE"
     SKIP(2)
     WITH NO-BOX DOWN SIDE-LABEL WIDTH 80 FRAME f_lanc_erro_276.

FORM SKIP(3)
     "RESUMO DAS DEVOLUCOES"     AT 20
     "   -    PA"                AT 42
     crawrel.cdagenci            AT 53   FORMAT "z9"
     crapage.nmresage            AT 57   FORMAT "x(15)"
     SKIP(3)
     "CONTA/DV"         AT 03
     "NOME"             AT 13
     "BANCO"            AT 47                           
     "CHEQUE"           AT 54                           
     "ALINEA"           AT 61                           
     "VALOR"            AT 76                           
     SKIP(1)
     WITH NO-BOX NO-LABEL WIDTH 80 FRAME f_cabec_276.

FORM crawrel.nrdconta   AT 01  FORMAT "zzzz,zz9,9"
     crawrel.nmprimtl   AT 13  FORMAT "x(33)"
     crawrel.cdbanchq   AT 49  FORMAT "zz9"          
     crawrel.nrcheque   AT 53  FORMAT "zzz,zzz,zzz,zz9"
     crawrel.nralinea   AT 64  FORMAT "z9"
     crawrel.vlcheque   AT 68  FORMAT "zz,zzz,zz9.99"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lanc_276.

FORM SKIP(1)
     "TOTAL -->"        AT 01
     aux_qtdecheq       AT 53  FORMAT "zzz,zz9"          
     aux_totdcheq       AT 63  FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_total_276.

FORM SKIP(7)
     "------------------------------"   AT 49
     SKIP
     "Visto do Coordenador"             AT 54
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_visto_276.

FORM SKIP(2)
     "TOTAL GERAL -->"  AT 01
     tot_qtdecheq       AT 53  FORMAT "zzz,zz9"          
     tot_totdcheq       AT 63  FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_total_geral_276.


/* Conforme numero de cheques impressos */
FORM SKIP(3)
     "----------------------------------------------------------------------"
     "----------" AT 71
     SKIP(2)
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_tracejado1.
     
FORM SKIP(4)
     "----------------------------------------------------------------------"
     "----------" AT 71
     SKIP(2)
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_tracejado2.
     
FORM SKIP(5)
     "----------------------------------------------------------------------"
     "----------" AT 71
     SKIP(2)
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_tracejado3.


ASSIGN glb_cdprogra = "crps327"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.           

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.

/* Tabela que contem o historico a procurar no lcm */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "VLTARIF351"  AND
                   craptab.tpregist = 1             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " CRED-USUARI-00-VLTARIF351-001 " +
                           " >> log/proc_batch.log").
         RETURN.
     END.

aux_vltarifa = DECI(craptab.dstextab) * 1.

IF   glb_nmtelant = "COMPEFORA"   THEN
     ASSIGN aux_dtauxili = STRING(YEAR(glb_dtmvtoan),"9999") +
                           STRING(MONTH(glb_dtmvtoan),"99") +
                           STRING(DAY(glb_dtmvtoan),"99").
ELSE
     ASSIGN aux_dtauxili = STRING(YEAR(glb_dtmvtolt),"9999") +
                           STRING(MONTH(glb_dtmvtolt),"99") +
                           STRING(DAY(glb_dtmvtolt),"99").

/* Tabela que contem as contas isentas de tarifa */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "ISTARIF351"  AND
                   craptab.tpregist = 1             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     aux_lscontas = "".
ELSE                   
     aux_lscontas = craptab.dstextab.
                              
ASSIGN  aux_nmarqdeb = "integra/1" + string(crapcop.cdagebcb,"9999") + "*DV*".
        aux_contador = 0.
                    
INPUT STREAM str_4 THROUGH VALUE( "ls " + aux_nmarqdeb + " 2> /dev/null")
      NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_4 aux_nmarquiv FORMAT "x(40)" .
  
   UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " +
                      aux_nmarquiv + ".q 2> /dev/null").

   ASSIGN aux_contador = aux_contador + 1
          tab_nmarquiv[aux_contador] = aux_nmarquiv.
   
END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_4 CLOSE.

IF   aux_contador = 0 THEN
     DO:
         glb_cdcritic = 258.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").

         RUN fontes/fimprg.p.
         RETURN.                
     END.

DO  i = 1 TO aux_contador:
      
    ASSIGN aux_contareg = 1
           aux_flgrejei = FALSE.
           
    glb_cdcritic = 219.
    RUN fontes/critic.p.
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '" +
                       glb_dscritic + "' --> '" + tab_nmarquiv[i] +
                      " >> log/proc_batch.log").
    
    glb_cdcritic = 0.

    INPUT STREAM str_5 FROM VALUE(tab_nmarquiv[i] + ".q") NO-ECHO.

    SET STREAM str_5 aux_setlinha  WITH FRAME AA WIDTH 161.
    
    IF    SUBSTR(aux_setlinha,48,06) <> "CEL615" THEN
          glb_cdcritic = 473.
    ELSE
    IF    INTEGER(SUBSTR(aux_setlinha,151,10)) <> aux_contareg THEN
          glb_cdcritic = 166.       
    ELSE              
    IF   SUBSTR(aux_setlinha,66,08) <> aux_dtauxili THEN
         glb_cdcritic = 013.
   
    IF    glb_cdcritic <> 0 THEN
          DO:
              RUN fontes/critic.p.
              aux_nmarquiv = "integra/err" + SUBSTR(tab_nmarquiv[i],12,29).
              UNIX SILENT VALUE("rm " + tab_nmarquiv[i] + ".q 2> /dev/null").
              UNIX SILENT VALUE("mv " + tab_nmarquiv[i] + " " + aux_nmarquiv).
              UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '" +
                                glb_dscritic + " " + tab_nmarquiv[i] + " Seq." +
                                STRING(aux_contareg, "9999") +
                                " >> log/proc_batch.log").
              glb_cdcritic = 0.
              NEXT.
          END.

     
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_5 aux_setlinha WITH FRAME AA WIDTH 161.

       ASSIGN aux_contareg = aux_contareg + 1.
       
       /*  Verifica se eh final do Arquivo  */
       
       IF   SUBSTR(aux_setlinha,1,10)  = "9999999999" AND   
            SUBSTR(aux_setlinha,48,06) = "CEL615"     THEN
            DO:            
                IF    INTEGER(SUBSTR(aux_setlinha,151,10)) <> aux_contareg THEN
                      glb_cdcritic = 166.
        
                IF    glb_cdcritic <> 0 THEN
                      DO:
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " " + tab_nmarquiv[i] + " Seq." +
                               STRING(aux_contareg, "9999") +
                               " >> log/proc_batch.log").
                        
                          ASSIGN glb_cdcritic = 0
                                 aux_flgrejei = TRUE.
                           
                          CREATE crawrel.
                          ASSIGN 
                             crawrel.cdagenci = 0
                             crawrel.nrdconta = INT(SUBSTR(aux_setlinha,67,12))
                             crawrel.nmprimtl = glb_dscritic
                             crawrel.nralinea = INT(SUBSTR(aux_setlinha,54,02))
                             crawrel.cdcmpchq = INT(SUBSTR(aux_setlinha,01,03))
                             crawrel.cdbanchq = INT(SUBSTR(aux_setlinha,04,03))
                             crawrel.cdagechq = INT(SUBSTR(aux_setlinha,07,04))
                             crawrel.nrctachq = DEC(SUBSTR(aux_setlinha,12,12))
                             crawrel.nrcheque = INT(SUBSTR(aux_setlinha,25,06))
                             crawrel.vlcheque = 
                                   (DECIMAL(SUBSTR(aux_setlinha,34,17)) / 100).
                      END.

                LEAVE.
            END.
          
       IF   INTEGER(SUBSTR(aux_setlinha,151,10)) <> aux_contareg THEN
            glb_cdcritic = 166.
       
       IF   glb_cdcritic <> 0 THEN
            DO:
                RUN fontes/critic.p.
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '" +
                                  glb_dscritic + " " + tab_nmarquiv[i] 
                                  + " Seq." + STRING(aux_contareg, "9999")
                                  + " >> log/proc_batch.log").
            
                ASSIGN glb_cdcritic = 0
                       aux_flgrejei = TRUE.
           
                CREATE crawrel.
                ASSIGN crawrel.cdagenci = 0
                       crawrel.nrdconta = INT(SUBSTR(aux_setlinha,67,12))
                       crawrel.nmprimtl = glb_dscritic
                       crawrel.nralinea = INT(SUBSTR(aux_setlinha,54,02))
                       crawrel.cdcmpchq = INT(SUBSTR(aux_setlinha,01,03))
                       crawrel.cdbanchq = INT(SUBSTR(aux_setlinha,04,03))
                       crawrel.cdagechq = INT(SUBSTR(aux_setlinha,07,04))
                       crawrel.nrctachq = DEC(SUBSTR(aux_setlinha,12,12))
                       crawrel.nrcheque = INT(SUBSTR(aux_setlinha,25,06))
                       crawrel.vlcheque = 
                              (DECIMAL(SUBSTR(aux_setlinha,34,17)) / 100).
                
                NEXT.
                 
            END.

       ASSIGN aux_cdbanchq = INT(SUBSTR(aux_setlinha,04,03))
              aux_cdagechq = INT(SUBSTR(aux_setlinha,07,04))
              aux_nrctachq = DEC(SUBSTR(aux_setlinha,12,12))
              aux_nrdocheq = INT(SUBSTR(aux_setlinha,25,06)) NO-ERROR.

       IF   ERROR-STATUS:ERROR   THEN
            DO:
                glb_cdcritic = 843.
            END.
       ELSE     
            DO:
                FIND FIRST crapchd WHERE
                           crapchd.cdcooper = glb_cdcooper   AND
                           crapchd.cdbanchq = aux_cdbanchq   AND
                           crapchd.cdagechq = aux_cdagechq   AND
                           crapchd.nrctachq = aux_nrctachq   AND
                           crapchd.nrcheque = aux_nrdocheq
                           USE-INDEX crapchd4 NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE crapchd THEN
                     glb_cdcritic = 244.
            
            END.
       
       IF   glb_cdcritic <> 0 THEN
            DO:
               RUN fontes/critic.p.
                
               ASSIGN glb_cdcritic = 0
                      aux_flgrejei = TRUE.
                 
               CREATE crawrel.
               ASSIGN crawrel.cdagenci = 0
                      crawrel.nrdconta = INT(SUBSTR(aux_setlinha,67,12))
                      crawrel.nmprimtl = glb_dscritic
                      crawrel.nralinea = INT(SUBSTR(aux_setlinha,54,02))
                      crawrel.cdcmpchq = INT(SUBSTR(aux_setlinha,01,03))
                      crawrel.cdbanchq = aux_cdbanchq
                      crawrel.cdagechq = aux_cdagechq
                      crawrel.nrctachq = aux_nrctachq
                      crawrel.nrcheque = aux_nrdocheq
                      crawrel.vlcheque = 
                      (DECIMAL(SUBSTR(aux_setlinha,34,17)) / 100).

               NEXT.
                     
            END.
            
       FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                          crapass.nrdconta = crapchd.nrdconta  NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE crapass THEN
            glb_cdcritic = 009.
       
       FIND crapdpb WHERE crapdpb.cdcooper = glb_cdcooper       AND
                          crapdpb.dtmvtolt = crapchd.dtmvtolt   AND
                          crapdpb.cdagenci = crapchd.cdagenci   AND
                          crapdpb.cdbccxlt = crapchd.cdbccxlt   AND
                          crapdpb.nrdolote = crapchd.nrdolote   AND
                          crapdpb.nrdconta = crapchd.nrdconta   AND
                          crapdpb.nrdocmto = crapchd.nrdocmto
                          USE-INDEX crapdpb1 NO-ERROR.
                          
       IF   NOT AVAILABLE crapdpb THEN
            aux_cdhistor = 351.
       ELSE
            DO:
                IF   crapdpb.inlibera = 1 THEN
                     DO:
                         IF   crapdpb.dtliblan <= glb_dtmvtolt THEN
                              aux_cdhistor = 351.
                         ELSE
                              DO:
                                  CASE crapdpb.cdhistor:
                               
                                       WHEN 3   THEN aux_cdhistor = 24.
                                       WHEN 4   THEN aux_cdhistor = 27.
                                       WHEN 357 THEN aux_cdhistor = 657.
                                       OTHERWISE     aux_cdhistor = 351.
                         
                                  END CASE.
                              END.    
                     END.
                ELSE
                     aux_cdhistor = 351.
            END.
       
       IF   crapchd.cdbccxlt = 700 THEN  /*  desconto de cheques  */
            aux_cdhistor = 399.
       
       DO TRANSACTION:

          DO WHILE TRUE:

             FIND craplot WHERE craplot.cdcooper = glb_cdcooper     AND
                                craplot.dtmvtolt = glb_dtmvtolt     AND
                                craplot.cdagenci = 1                AND
                                craplot.cdbccxlt = 100              AND
                                craplot.nrdolote = 4650
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF   NOT AVAILABLE craplot   THEN
                  IF   LOCKED craplot   THEN
                       DO:
                           PAUSE 2 NO-MESSAGE.
                           NEXT.
                       END.
                  ELSE
                       DO:
                           CREATE craplot.
                           ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                  craplot.dtmvtopg = glb_dtmvtopr
                                  craplot.cdagenci = 1
                                  craplot.cdbccxlt = 100
                                  craplot.cdoperad = "1"
                                  craplot.nrdolote = 4650
                                  craplot.tplotmov = 1
                                  craplot.tpdmoeda = 1
                                  craplot.cdcooper = glb_cdcooper.
                       END.

                  LEAVE.

          END.  /*  Fim do DO WHILE TRUE  */

          ASSIGN aux_nrcheque = crapchd.nrcheque.

          DO WHILE TRUE:

             FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper         AND
                                craplcm.dtmvtolt = glb_dtmvtolt         AND
                                craplcm.cdagenci = 1                    AND
                                craplcm.cdbccxlt = 100                  AND
                                craplcm.nrdolote = 4650                 AND
                                craplcm.nrdctabb = crapchd.nrdconta     AND
                                craplcm.nrdocmto = aux_nrcheque     
                                USE-INDEX craplcm1
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

             IF   AVAILABLE craplcm THEN
                  aux_nrcheque = (aux_nrcheque + 1000000).
             ELSE
                  LEAVE.
          
          END.  /*  Fim do DO WHILE TRUE  */

          IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
            RUN sistema/generico/procedures/b1wgen0200.p
              PERSISTENT SET h-b1wgen0200.

          RUN gerar_lancamento_conta_comple IN h-b1wgen0200
            (INPUT glb_dtmvtolt                                 /* par_dtmvtolt */
            ,INPUT 1                                            /* par_cdagenci */
            ,INPUT 100                                          /* par_cdbccxlt */
            ,INPUT 4650                                         /* par_nrdolote */
            ,INPUT crapchd.nrdconta                             /* par_nrdconta */
            ,INPUT aux_nrcheque                                 /* par_nrdocmto */
            ,INPUT aux_cdhistor                                 /* par_cdhistor */
            ,INPUT craplot.nrseqdig + 1                         /* par_nrseqdig */
            ,INPUT (DECIMAL(SUBSTR(aux_setlinha,34,17)) / 100)  /* par_vllanmto */
            ,INPUT crapchd.nrdconta                             /* par_nrdctabb */
            ,INPUT SUBSTR(aux_setlinha,54,02)                   /* par_cdpesqbb */
            ,INPUT 0                                            /* par_vldoipmf */
            ,INPUT 0                                            /* par_nrautdoc */
            ,INPUT 0                                            /* par_nrsequni */
            ,INPUT crapchd.cdbanchq                             /* par_cdbanchq */
            ,INPUT crapchd.cdcmpchq                             /* par_cdcmpchq */
            ,INPUT crapchd.cdagechq                             /* par_cdagechq */
            ,INPUT crapchd.nrctachq                             /* par_nrctachq */
            ,INPUT 0                                            /* par_nrlotchq */
            ,INPUT 0                                            /* par_sqlotchq */
            ,INPUT ""                                           /* par_dtrefere */
            ,INPUT ""                                           /* par_hrtransa */
            ,INPUT 0                                            /* par_cdoperad */
            ,INPUT "BCB"                                        /* par_dsidenti */
            ,INPUT glb_cdcooper                                 /* par_cdcooper */
            ,INPUT STRING(crapchd.nrdconta,"99999999")          /* par_nrdctitg */
            ,INPUT ""                                           /* par_dscedent */
            ,INPUT 0                                            /* par_cdcoptfn */
            ,INPUT 0                                            /* par_cdagetfn */
            ,INPUT 0                                            /* par_nrterfin */
            ,INPUT 0                                            /* par_nrparepr */
            ,INPUT 0                                            /* par_nrseqava */
            ,INPUT 0                                            /* par_nraplica */
            ,INPUT 0                                            /* par_cdorigem */
            ,INPUT 0                                            /* par_idlautom */
            /* CAMPOS OPCIONAIS DO LOTE                                                            */
            ,INPUT 0                              /* Processa lote                                 */
            ,INPUT 0                              /* Tipo de lote a movimentar                     */
            /* CAMPOS DE SAÍDA                                                                     */
            ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
            ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
            ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
            ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */

          IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + glb_cdprogra + "' --> " +
                              aux_dscritic + "'" +
                              " nrdconta" + STRING(crapchd.nrdconta,"99999999") +
                              " nrcheque" + STRING(aux_nrcheque,"99999999") +
                              " >> log/proc_batch.log").
            ASSIGN glb_cdcritic = 0
                   aux_flgrejei = TRUE.

            CREATE crawrel.
            ASSIGN crawrel.cdagenci = 1
                   crawrel.nrdconta = crapchd.nrdconta
                   crawrel.nmprimtl = aux_dscritic
                   crawrel.nrfonres = ""
                   crawrel.cdcmpchq = crapchd.cdcmpchq
                   crawrel.cdagechq = crapchd.cdagechq
                   crawrel.cdbanchq = crapchd.cdbanchq
                   crawrel.nrctachq = crapchd.nrctachq
                   crawrel.nrcheque = aux_nrcheque
                   crawrel.nralinea = INTEGER(SUBSTR(aux_setlinha,54,02))
                   crawrel.vlcheque = (DECIMAL(SUBSTR(aux_setlinha,34,17)) / 100).

            NEXT.
          END.

          IF  VALID-HANDLE(h-b1wgen0200) THEN
            DELETE PROCEDURE h-b1wgen0200.

          ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                 craplot.qtcompln = craplot.qtcompln + 1
                 craplot.qtinfoln = craplot.qtinfoln + 1
                 craplot.vlcompdb = craplot.vlcompdb +
                                     (DECIMAL(SUBSTR(aux_setlinha,34,17)) / 100)
                 craplot.vlcompcr = 0
                 craplot.vlinfodb = craplot.vlcompdb
                 craplot.vlinfocr = 0. 
          
          VALIDATE craplot.

          /*   Tratamento de Cheques Bloqueados  */
          IF   craplcm.cdhistor = 24    OR
               craplcm.cdhistor = 27    OR
               craplcm.cdhistor = 657   THEN
               DO:
                    IF   craplcm.vllanmto = crapdpb.vllanmto THEN
                         crapdpb.inlibera = 2.   /* Dep. Estornado */
                    ELSE
                         /*  Deposito com varios cheques */
                         crapdpb.vllanmto = (crapdpb.vllanmto - 
                                            craplcm.vllanmto). 
               END.

          CREATE crawrel.
          ASSIGN crawrel.cdagenci = crapass.cdagenci
                 crawrel.nrdconta = crapchd.nrdconta
                 crawrel.nmprimtl = crapass.nmprimtl
                 crawrel.cdbanchq = crapchd.cdbanchq
                 crawrel.nrcheque = crapchd.nrcheque
                 crawrel.nralinea = INTEGER(SUBSTR(aux_setlinha,54,02))
                 crawrel.vlcheque = crapchd.vlcheque.

          IF crapass.inpessoa = 1 THEN
             FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                  WHERE craptfc.cdcooper = crapass.cdcooper
                                  AND   craptfc.nrdconta = crapass.nrdconta
                                  AND   craptfc.tptelefo = 1
                                  NO-LOCK:
                    ASSIGN crawrel.nrfonres = STRING(craptfc.nrdddtfc) +
                                              STRING(craptfc.nrtelefo).
             END.
          ELSE
              FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                              WHERE craptfc.cdcooper = crapass.cdcooper
                              AND   craptfc.nrdconta = crapass.nrdconta
                              AND   craptfc.tptelefo = 3
                              NO-LOCK:
                  ASSIGN crawrel.nrfonres = STRING(craptfc.nrdddtfc) +
                                            STRING(craptfc.nrtelefo).
              END.

                                  
          /*   Atualizacao no Cadastro de Emitentes de Cheques  */
          
          FIND crapcec WHERE crapcec.cdcooper = glb_cdcooper        AND
                             crapcec.cdcmpchq = crapchd.cdcmpchq    AND
                             crapcec.cdbanchq = crapchd.cdbanchq    AND
                             crapcec.cdagechq = crapchd.cdagechq    AND
                             crapcec.nrctachq = crapchd.nrctachq    AND
                             crapcec.nrdconta = 0
                             EXCLUSIVE-LOCK NO-ERROR.
 
          IF   AVAILABLE crapcec THEN
               ASSIGN crapcec.dtultdev = glb_dtmvtolt
                      crapcec.qtchqdev = crapcec.qtchqdev + 1.
    
       END.   /*    Fim do Transaction   */

    END.  /*   Fim  do DO WHILE TRUE  */

    INPUT STREAM str_5 CLOSE.

    UNIX SILENT VALUE("mv " + tab_nmarquiv[i] + " salvar"). 
    UNIX SILENT VALUE("rm " + tab_nmarquiv[i] + ".q 2> /dev/null").

    glb_cdcritic = IF   aux_flgrejei THEN 
                        191 
                   ELSE 
                        190.
 
    RUN fontes/critic.p.
    
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '" +
                      glb_dscritic + "' --> '" +  tab_nmarquiv[i] +
                      " >> log/proc_batch.log").

END.   /*   Fim  do DO TO   */

/***   Geracao dos Avisos de Devolucao - 277   ***/

{ includes/cabrel080_1.i }

aux_flgfirst = TRUE.

FOR EACH crawrel USE-INDEX crawrel1 BREAK BY crawrel.cdagenci 
                                             BY crawrel.nrdconta:    
                                              
    IF   crawrel.cdagenci = 0 THEN   
         NEXT.                            
    
    IF   aux_flgfirst THEN
         DO:
             aux_nmarqimp = "rl/crrl277.lst".
    
             OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 85.

             VIEW STREAM str_1 FRAME f_cabrel080_1.

             ASSIGN aux_flgfirst = FALSE.
         END.
    
    IF   FIRST-OF(crawrel.nrdconta) THEN
         DO:
             ASSIGN aux_qtdecheq = 0
                    aux_totdcheq = 0.
         
             DISPLAY STREAM str_1 crawrel.cdagenci crawrel.nrdconta
                                  crawrel.nmprimtl crawrel.nrfonres
                                  WITH FRAME f_cabec_277.
         
         END.

    ASSIGN aux_qtdecheq = aux_qtdecheq + 1
           aux_totdcheq = aux_totdcheq + crawrel.vlcheque.
    
    FIND crapali WHERE crapali.cdalinea = crawrel.nralinea  NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapali THEN 
         aux_dsalinea = "NAO CADASTRADA".
    ELSE
         aux_dsalinea = crapali.dsalinea.
    
    DISPLAY STREAM str_1 crawrel.cdbanchq  crawrel.nrcheque
                         crawrel.nralinea  aux_dsalinea
                         crawrel.vlcheque  
                         WITH FRAME f_lanc_277.

    DOWN STREAM str_1 WITH FRAME f_lanc_277.

    CREATE rel277.
    ASSIGN rel277.cdagenci = crawrel.cdagenci
           rel277.nrdconta = crawrel.nrdconta
           rel277.nmprimtl = crawrel.nmprimtl
           rel277.nrfonres = crawrel.nrfonres 
           rel277.cdbanchq = crawrel.cdbanchq
           rel277.nrcheque = crawrel.nrcheque
           rel277.nralinea = crawrel.nralinea
           rel277.vlcheque = crawrel.vlcheque
           rel277.auxaline = aux_dsalinea
           rel277.auxqtdch = aux_qtdecheq
           rel277.totchequ = aux_totdcheq.
      
      
    IF   LAST-OF(crawrel.nrdconta) THEN
         DO:           
             IF   CAN-DO(aux_lscontas,STRING(crawrel.nrdconta)) THEN
                  DISPLAY STREAM str_1 aux_qtdecheq     aux_totdcheq
                                       crawrel.nmprimtl crawrel.nrdconta
                                       WITH FRAME f_total_isento_277.
             ELSE           
                  DISPLAY STREAM str_1 aux_qtdecheq     aux_totdcheq
                          aux_vltarifa crawrel.nmprimtl crawrel.nrdconta
                                       WITH FRAME f_total_277.
             
             IF   aux_qtdecheq > 3  THEN
                  PAGE STREAM str_1.
             ELSE
             IF   aux_qtdecheq = 1  THEN
                  DO:                               
                      DISPLAY STREAM str_1 WITH FRAME f_tracejado3.
                      DISPLAY STREAM str_1 WITH FRAME f_cabrel080_1.
                  END.
             ELSE
             IF   aux_qtdecheq = 2  THEN
                  DO:
                      DISPLAY STREAM str_1 WITH FRAME f_tracejado2.
                      DISPLAY STREAM str_1 WITH FRAME f_cabrel080_1.
                  END.
             ELSE
                  IF   aux_qtdecheq = 3  THEN
                       DO: 
                           DISPLAY STREAM str_1 WITH FRAME f_tracejado1.
                           DISPLAY STREAM str_1 WITH FRAME f_cabrel080_1.
                       END.
         
         
             FOR EACH rel277 BREAK BY rel277.cdagenci
                                      BY rel277.nrdconta:

                 IF   FIRST-OF(rel277.nrdconta)  THEN
                      DO:
                          DISPLAY STREAM str_1 rel277.cdagenci
                                               rel277.nrdconta
                                               rel277.nmprimtl
                                               rel277.nrfonres
                                               WITH FRAME f_cabec_rel277. 
                      END.        
       
                 DISPLAY STREAM str_1 rel277.cdbanchq  rel277.nrcheque
                                      rel277.nralinea  rel277.auxaline
                                      rel277.vlcheque  
                                      WITH FRAME f_lanc_rel277.
                                  
                 DOWN STREAM str_1 WITH FRAME f_lanc_rel277. 
               
                 IF   LAST-OF(rel277.nrdconta)  THEN
                      DO:
                         IF   CAN-DO(aux_lscontas,STRING(rel277.nrdconta)) THEN
                              DISPLAY STREAM str_1 rel277.auxqtdch     
                                                   rel277.totchequ
                                                   rel277.nmprimtl 
                                                   rel277.nrdconta
                                               WITH FRAME f_total_isento_rel277.
                         ELSE           
                              DISPLAY STREAM str_1 rel277.auxqtdch     
                                                   rel277.totchequ
                                                   aux_vltarifa
                                                   rel277.nmprimtl
                                                   rel277.nrdconta
                                                   WITH FRAME f_total_rel277.
                          
                         IF   rel277.auxqtdch > 3  THEN
                              PAGE STREAM str_1.                             
                      END.
             END.
             
             EMPTY TEMP-TABLE  rel277.
         
         END.
    
END.   /*   Fim  do rel.  crrl277  */
 
IF   NOT aux_flgfirst THEN
     DO:
         OUTPUT STREAM str_1 CLOSE.
 
         ASSIGN glb_nrcopias = 1
                glb_nmformul = "80col"
                glb_nmarqimp = aux_nmarqimp.
                     
         RUN fontes/imprim.p.        
     END.
 
/***   Geracao do Resumo das Devolucoes - 276   ***/

ASSIGN aux_flgfirst = TRUE    
       aux_flgerro2 = TRUE
       tot_qtdecheq = 0
       tot_totdcheq = 0        
       aux_qtdecheq = 0
       aux_totdcheq = 0.

{ includes/cabrel080_2.i }
{ includes/cabrel080_3.i }

FOR EACH crawrel USE-INDEX crawrel1 BREAK BY crawrel.cdagenci
                                             BY crawrel.nrdconta:    
    
    IF   aux_flgfirst THEN
         DO:
             ASSIGN aux_nmarqrl1 = "rl/crrl276_999.lst"
                    aux_flgfirst = FALSE.
             
             OUTPUT STREAM str_2 TO VALUE(aux_nmarqrl1) PAGED PAGE-SIZE 84.

             VIEW STREAM str_2 FRAME f_cabrel080_2.
         END.
    
    IF   crawrel.cdagenci = 0 THEN
         DO:
             IF   aux_flgerro2 THEN
                  DO:
                      VIEW STREAM str_2 FRAME f_cabec_erro_276.
                      aux_flgerro2 = FALSE.
                  END.

             ASSIGN tot_qtdecheq = tot_qtdecheq + 1
                    tot_totdcheq = tot_totdcheq + crawrel.vlcheque.

             DISPLAY STREAM str_2 crawrel.nmprimtl crawrel.nrdconta
                                  crawrel.cdcmpchq crawrel.cdbanchq
                                  crawrel.cdagechq crawrel.vlcheque           
                                  crawrel.nralinea crawrel.nrcheque
                                  WITH FRAME f_lanc_erro_276.

             DOWN STREAM str_2 WITH FRAME f_lanc_erro_276.
             
             NEXT.
         END.
    
    IF   FIRST-OF(crawrel.cdagenci) THEN
         DO:
             aux_nmarqrl2 = "rl/crrl276_" + STRING(crawrel.cdagenci,"999") +
                            ".lst".
    
             OUTPUT STREAM str_3 TO VALUE(aux_nmarqrl2) PAGED PAGE-SIZE 84.

             VIEW STREAM str_3 FRAME f_cabrel080_3.

             ASSIGN aux_qtdecheq = 0
                    aux_totdcheq = 0.
         
             FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                                crapage.cdagenci = crawrel.cdagenci 
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAILABLE crapage THEN
                  DO:
                      glb_cdcritic = 015.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - " + glb_cdprogra + "' --> '" +
                                        glb_dscritic + "  " + 
                                        aux_nmarqrl2 + " " +
                                        " >> log/proc_batch.log").
                      glb_cdcritic = 0.
                      NEXT.
                  END.
             
             DISPLAY STREAM str_2 crawrel.cdagenci crapage.nmresage
                                  WITH FRAME f_cabec_276.
             
             DISPLAY STREAM str_3 crawrel.cdagenci crapage.nmresage
                                  WITH FRAME f_cabec_276.
         END.

    DISPLAY STREAM str_2 crawrel.nrdconta  crawrel.nmprimtl
                         crawrel.cdbanchq  crawrel.nrcheque
                         crawrel.nralinea  crawrel.vlcheque
                         WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lanc_276.
 
    DISPLAY STREAM str_3 crawrel.nrdconta  crawrel.nmprimtl
                         crawrel.cdbanchq  crawrel.nrcheque
                         crawrel.nralinea  crawrel.vlcheque
                         WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lanc_276.
                     
    DOWN STREAM str_2 WITH FRAME f_lanc_276.
    
    DOWN STREAM str_3 WITH FRAME f_lanc_276.

    ASSIGN aux_qtdecheq = aux_qtdecheq + 1
           aux_totdcheq = aux_totdcheq + crawrel.vlcheque
           tot_qtdecheq = tot_qtdecheq + 1
           tot_totdcheq = tot_totdcheq + crawrel.vlcheque.
        
    IF   LINE-COUNTER(str_2) > 77 THEN
         PAGE STREAM str_2.
         
    IF   LINE-COUNTER(str_3) > 77 THEN
         PAGE STREAM str_3.
 
    IF   LAST-OF(crawrel.cdagenci) THEN
         DO:
             DISPLAY STREAM str_2 aux_qtdecheq aux_totdcheq 
                     WITH FRAME f_total_276.
       
             DISPLAY STREAM str_3 aux_qtdecheq aux_totdcheq 
                     WITH FRAME f_total_276.

             DISPLAY STREAM str_3 WITH FRAME f_visto_276.
       
             OUTPUT STREAM str_3 CLOSE.
         END.
                           
END.   /*   Fim  do rel.  crrl276  */
 
IF   tot_qtdecheq > 0 THEN
     DO:
         DISPLAY STREAM str_2 tot_qtdecheq tot_totdcheq 
                     WITH FRAME f_total_geral_276.
       
         OUTPUT STREAM str_2 CLOSE.
 
         ASSIGN glb_nrcopias = 1
                glb_nmformul = "80col"
                glb_nmarqimp = aux_nmarqrl1.
                    
         RUN fontes/imprim.p.  
     END.

RUN fontes/fimprg.p.

/*.......................................................................... */
