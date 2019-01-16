/* ............................................................................

   Programa: fontes/crps394.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro                 
   Data    : Junho/2004                         Ultima atualizacao: 21/07/2016

   Dados referentes ao programa:

   Frequencia: Diario
   Objetivo  : Atende a solicitacao 1
               Emitir relacao de cheques compensados a conferir, separados por 
               P.A.C. (crrl353_PAC).               

   Alteracoes: 23/09/2004 - Modificar para nao imprimir no PAC 1 (Ze Eduardo).
   
               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "for each" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
               
               11/11/2010 - Realizado a inclusao do campo nrdbanco (Adriano).
               
               12/04/2011 - Alterar o campo crapfdc.nrdbanco para 
                            craplcm.cdbccxlt (Ze).
               
               07/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
               
               07/11/2013 - Alterado totalizador de PAs de 99 para 999. 
                            (Guilherme Gielow) 
                            
               30/06/2014 - Adicionado campo cdcoptfn na temp-table w-crapass.
                            (Reinert)                             
             
               21/07/2016 - Ajustes referentes a Melhoria 69 - Devolucao automatica 
                            de cheques (Lucas Ranghetti #484923)
							
			   14/01/2019 - Gerar o relatório 353 - Relação de Cheques na intranet.
			                (Wagner - Sustentação - #SCTASK0035560).
							
............................................................................ */

DEF STREAM str_1. /* Relatorio */


{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ includes/var_batch.i "NEW" }   

DEF    VAR rel_dsagenci       AS CHAR   FORMAT "x(21)"          NO-UNDO.
DEF    VAR rel_nmempres AS CHAR FORMAT "x(15)"                  NO-UNDO.
DEF    VAR rel_nmresemp AS CHAR FORMAT "x(15)"                  NO-UNDO.
DEF    VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5         NO-UNDO.
DEF    VAR rel_nrmodulo AS INT  FORMAT "9"                      NO-UNDO.
DEF    VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5
                            INIT ["DEP. A VISTA   ","CAPITAL        ",
                                  "EMPRESTIMOS    ","DIGITACAO      ",
                                  "GENERICO       "]            NO-UNDO.

DEF    VAR aux_nmarqimp       AS CHAR                           NO-UNDO.
DEF    VAR aux_i-occ          AS INT                            NO-UNDO.
DEF    VAR aux_de-valor       AS DEC                            NO-UNDO.
DEF    VAR aux_vlmaxcom       AS DEC                            NO-UNDO.
DEF    VAR aux_cdagectl       LIKE crapcop.cdagectl EXTENT 99   NO-UNDO.
DEF    VAR aux_dsacolhe       AS CHAR                           NO-UNDO.

DEF    VAR aux_qtdevolu AS INT                                  NO-UNDO.
DEF    VAR aux_cdcritic AS INT                                  NO-UNDO.
DEF    VAR aux_dscritic AS CHAR                                 NO-UNDO.
DEF    VAR aux_flgdevolu_autom AS INT                           NO-UNDO.
DEF    VAR aux_vlsldrgt AS DEC                                  NO-UNDO.
DEF    VAR aux_vlsldtot AS DEC                                  NO-UNDO.
DEF    VAR aux_vlsldapl AS DEC                                  NO-UNDO.
DEF    VAR aux_vltotrda AS DEC                                  NO-UNDO.
DEF    VAR aux_vltotrpp AS DEC                                  NO-UNDO.

DEF    VAR h-b1wgen0081       AS HANDLE                         NO-UNDO.
DEF    VAR h-b1wgen0006       AS HANDLE                         NO-UNDO.

DEF TEMP-TABLE w-crapass
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdbanco LIKE craplcm.cdbanchq
    FIELD nrdconta LIKE craplcm.nrdconta
    FIELD nrdocmto LIKE craplcm.nrdocmto
    FIELD vllanmto LIKE craplcm.vllanmto
    FIELD cdcoptfn LIKE craplcm.cdcoptfn
    FIELD flgautom AS CHAR FORMAT "x(3)"
    FIELD flaplica AS CHAR FORMAT "x(3)"
    FIELD qtdevolu AS INT     
    INDEX ch-agconta  AS UNIQUE PRIMARY
          cdagenci
          nrdbanco
          nrdconta
          nrdocmto.

FORM HEADER 
     "PA: "    
     rel_dsagenci FORMAT "x(21)" NO-LABEL
     SKIP(2)
     WITH NO-BOX PAGE-TOP SIDE-LABELS WIDTH 132 FRAME f_agencia.

FORM aux_dsacolhe         AT 8     FORMAT "x(10)"        LABEL "AGE.ACOLHEDORA"
     w-crapass.nrdbanco   AT 23    FORMAT "z,zz9"              LABEL "BANCO"
     w-crapass.nrdconta   AT 29    FORMAT "zzzz,zzz,9"         LABEL "CONTA/DV"
     w-crapass.nrdocmto   AT 40    FORMAT "zz,zzz,zz9"         LABEL "DOCUMENTO"
     w-crapass.vllanmto   AT 51    FORMAT "zzz,zzz,zzz,zz9.99" LABEL "VALOR"     
     w-crapass.flgautom   AT 70    FORMAT "x(3)"               LABEL "DEV.AUT."
     w-crapass.flaplica   AT 79    FORMAT "x(3)"               LABEL "APLICACOES"
     w-crapass.qtdevolu   AT 90    FORMAT "zz,zzz,zz9"         LABEL "DEVOLUCOES"
     WITH NO-BOX DOWN NO-LABELS WIDTH 132 FRAME f_cheqs.

glb_cdprogra = "crps394".
glb_cdrelato = 353.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.
  
{ includes/cabrel132_1.i }

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "MAIORESCHQ"   AND
                   craptab.tpregist = 001
                   NO-LOCK NO-ERROR.

IF   AVAILABLE craptab   THEN
     ASSIGN aux_vlmaxcom =  DECIMAL(SUBSTRING(craptab.dstextab,34,15)).
ELSE 
     ASSIGN aux_vlmaxcom = 0.
  
FOR EACH crapcop FIELDS (cdcooper cdagectl) NO-LOCK:

    ASSIGN aux_cdagectl[crapcop.cdcooper] = crapcop.cdagectl.

END.

FOR EACH craphis WHERE craphis.cdcooper = glb_cdcooper      AND
                       craphis.dshistor MATCHES "ch*comp*"  NO-LOCK:
                       
    FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper      AND
                           craplcm.dtmvtolt = glb_dtmvtolt      AND
                           craplcm.dtrefere = glb_dtmvtolt      AND
                           craplcm.cdhistor = craphis.cdhistor  AND
                           craplcm.vllanmto >= aux_vlmaxcom     
                           NO-LOCK USE-INDEX craplcm4,
        
        FIRST  crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                             crapass.nrdconta = craplcm.nrdconta 
                             NO-LOCK:

        /** Saldo das aplicacoes **/
        IF  NOT VALID-HANDLE(h-b1wgen0081) THEN
            RUN sistema/generico/procedures/b1wgen0081.p 
                PERSISTENT SET h-b1wgen0081.
       
        IF  VALID-HANDLE(h-b1wgen0081)  THEN
            DO:
                ASSIGN aux_vlsldtot = 0
                       aux_vltotrda = 0
                       aux_vltotrpp = 0.
                       
                
                RUN obtem-dados-aplicacoes IN h-b1wgen0081
                                          (INPUT craplcm.cdcooper,
                                           INPUT glb_cdagenci,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT glb_nmdatela,
                                           INPUT 1,
                                           INPUT crapass.nrdconta,
                                           INPUT 1,
                                           INPUT 0,
                                           INPUT glb_nmdatela,
                                           INPUT FALSE,
                                           INPUT ?,
                                           INPUT ?,
                                           OUTPUT aux_vlsldtot,
                                           OUTPUT TABLE tt-saldo-rdca,
                                           OUTPUT TABLE tt-erro).
            
                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        IF VALID-HANDLE(h-b1wgen0081) THEN
                            DELETE OBJECT h-b1wgen0081.
                        
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                     
                        IF  AVAILABLE tt-erro  THEN
                            ASSIGN aux_dscritic = tt-erro.dscritic.
                        ELSE
                            ASSIGN aux_dscritic = "Erro nos dados das aplicacoes.".
                            
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                           glb_cdprogra + "' --> '" +
                                           aux_dscritic + "' --> '" +
                                           " Conta/dv: " + STRING(crapass.nrdconta,"zzzz,zzz,9") +
                                           " Doc.: "     + STRING(craplcm.nrdocmto) +
                                           " Banco: "    + STRING(craplcm.cdbanchq) +
                                           " Agencia: "  + STRING(craplcm.cdagechq) +
                                           " Valor: "    + STRING(craplcm.vllanmto) +
                                           " >> log/proc_message.log").                                                 
                    END.                  

                ASSIGN aux_vlsldapl = aux_vlsldtot.
                
                IF  VALID-HANDLE(h-b1wgen0081) THEN
                    DELETE OBJECT h-b1wgen0081.
            END.
            
            
            DO WHILE TRUE:
               /*Busca Saldo Novas Aplicacoes*/
               
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
                  aux_handproc = PROC-HANDLE NO-ERROR
                                          (INPUT craplcm.cdcooper, /* Código da Cooperativa */
                                           INPUT '1',            /* Código do Operador */
                                           INPUT glb_nmdatela, /* Nome da Tela */
                                           INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                           INPUT craplcm.nrdconta, /* Número da Conta */
                                           INPUT 1,            /* Titular da Conta */
                                           INPUT 0,            /* Número da Aplicação / Parâmetro Opcional */
                                           INPUT glb_dtmvtolt, /* Data de Movimento */
                                           INPUT 0,            /* Código do Produto */
                                           INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
                                           INPUT 0,            /* Identificador de Log (0 – Não / 1 – Sim) */
                                          OUTPUT 0,            /* Saldo Total da Aplicação */
                                          OUTPUT 0,            /* Saldo Total para Resgate */
                                          OUTPUT 0,            /* Código da crítica */
                                          OUTPUT "").          /* Descrição da crítica */
                
                CLOSE STORED-PROC pc_busca_saldo_aplicacoes
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_vlsldtot = 0
                       aux_vlsldrgt = 0
                       aux_cdcritic = pc_busca_saldo_aplicacoes.pr_cdcritic 
                                       WHEN pc_busca_saldo_aplicacoes.pr_cdcritic <> ?
                       aux_dscritic = pc_busca_saldo_aplicacoes.pr_dscritic
                                       WHEN pc_busca_saldo_aplicacoes.pr_dscritic <> ?
                       aux_vlsldtot = pc_busca_saldo_aplicacoes.pr_vlsldtot
                                       WHEN pc_busca_saldo_aplicacoes.pr_vlsldtot <> ?
                       aux_vlsldrgt = pc_busca_saldo_aplicacoes.pr_vlsldrgt
                                       WHEN pc_busca_saldo_aplicacoes.pr_vlsldrgt <> ?.

                IF  aux_cdcritic <> 0   OR
                    aux_dscritic <> ""  THEN
                    DO:
                        IF  aux_dscritic = "" THEN
                            DO:
                               FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                                  NO-LOCK NO-ERROR.
                            
                               IF AVAIL crapcri THEN
                                  ASSIGN aux_dscritic = crapcri.dscritic.
                            
                            END.
                    
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                        glb_cdprogra + "' --> '" +
                                        aux_dscritic + "' --> '" +
                                        " Conta/dv: " + STRING(crapass.nrdconta,"zzzz,zzz,9") +
                                        " Doc.: "     + STRING(craplcm.nrdocmto) +
                                        " Banco: "    + STRING(craplcm.cdbanchq) +
                                        " Agencia: "  + STRING(craplcm.cdagechq) +
                                        " Valor: "    + STRING(craplcm.vllanmto) +
                                        " >> log/proc_message.log").                                           
                    END.
                    
                LEAVE.
           END.
           /*Fim Busca Saldo Novas Aplicacoes*/            
            
            RUN sistema/generico/procedures/b1wgen0006.p 
                PERSISTENT SET h-b1wgen0006.

            RUN consulta-poupanca IN h-b1wgen0006 (INPUT craplcm.cdcooper,
                                                   INPUT 0,
                                                   INPUT 0,
                                                   INPUT glb_cdoperad,
                                                   INPUT glb_nmdatela,
                                                   INPUT 1, /* Ayllos */
                                                   INPUT craplcm.nrdconta,
                                                   INPUT 1, /* Titular */
                                                   INPUT 0, /* Todos os Contratos*/
                                                   INPUT glb_dtmvtolt,
                                                   INPUT glb_dtmvtopr,
                                                   INPUT glb_inproces,
                                                   INPUT glb_cdprogra,
                                                   INPUT FALSE,
                                                   OUTPUT aux_vltotrpp,
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT TABLE tt-dados-rpp).
                                                   
            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    IF  VALID-HANDLE(h-b1wgen0006) THEN
                        DELETE OBJECT h-b1wgen0006.
                    
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN aux_dscritic = "Erro nos dados das aplicacoes.".
                        
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                       glb_cdprogra + "' --> '" +
                                       aux_dscritic + "' --> '" +
                                       " Conta/dv: " + STRING(crapass.nrdconta,"zzzz,zzz,9") +
                                       " Doc.: "     + STRING(craplcm.nrdocmto) +
                                       " Banco: "    + STRING(craplcm.cdbanchq) +
                                       " Agencia: "  + STRING(craplcm.cdagechq) +
                                       " Valor: "    + STRING(craplcm.vllanmto) +
                                       " >> log/proc_message.log").                                                 
                END.       
              
            IF  VALID-HANDLE(h-b1wgen0006) THEN
                DELETE OBJECT h-b1wgen0006.  
                                        
            ASSIGN aux_vltotrda = aux_vltotrpp + aux_vlsldapl + aux_vlsldrgt.            

        /* Verificar se e devolucao automatica / CADA0003 */
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
        
        RUN STORED-PROCEDURE pc_verifica_sit_dev
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT craplcm.cdcooper, /* Código da Cooperativa */                                     
                                 INPUT crapass.nrdconta, /* Número da Conta */                                     
                                OUTPUT 0).               /* flgdevolu_autom 0 - Nao/ 1 - Sim */
      
        CLOSE STORED-PROC pc_verifica_sit_dev
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_flgdevolu_autom = 0
               aux_flgdevolu_autom = pc_verifica_sit_dev.pr_flgdevolu_autom 
                                     WHEN pc_verifica_sit_dev.pr_flgdevolu_autom <> ?.
           
        ASSIGN aux_qtdevolu = 0.   
           
        /* Quantidade de devolucoes que o cheque ja teve */
        FOR EACH crapneg WHERE crapneg.cdcooper = craplcm.cdcooper
                           AND crapneg.nrdconta = craplcm.nrdconta
                           AND crapneg.cdhisest = 1                           
                           AND crapneg.nrdocmto = craplcm.nrdocmto
                           AND crapneg.vlestour = craplcm.vllanmto
                           NO-LOCK:
                           
           ASSIGN aux_qtdevolu = aux_qtdevolu + 1.
        END.                           

        CREATE w-crapass.
        ASSIGN w-crapass.cdagenci = crapass.cdagenci
               w-crapass.nrdbanco = craplcm.cdbccxlt 
               w-crapass.nrdconta = craplcm.nrdconta
               w-crapass.nrdocmto = craplcm.nrdocmto
               w-crapass.vllanmto = craplcm.vllanmto
               w-crapass.cdcoptfn = craplcm.cdcoptfn
               w-crapass.flgautom = IF aux_flgdevolu_autom = 1 THEN
                                    "SIM" ELSE "NAO"
               w-crapass.qtdevolu = aux_qtdevolu
               w-crapass.flaplica = IF craplcm.vllanmto < aux_vltotrda THEN
                                    "SIM" ELSE "NAO".

    END.     
END.
      
FOR EACH w-crapass NO-LOCK
    BREAK BY w-crapass.cdagenci 
          BY w-crapass.nrdbanco
          BY w-crapass.nrdconta
          BY w-crapass.nrdocmto:
       
       IF FIRST-OF(w-crapass.cdagenci) THEN
          DO:
             
             FIND crapage WHERE crapage.cdcooper = glb_cdcooper       AND
                                crapage.cdagenci = w-crapass.cdagenci
                                NO-LOCK NO-ERROR.
             
             ASSIGN rel_dsagenci = STRING(w-crapass.cdagenci,"zz9") + " - "
                                             + crapage.nmresage
                    aux_nmarqimp = "rl/crrl353_" + 
                             STRING(w-crapass.cdagenci,"999") + ".lst".
             
             OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
             VIEW STREAM str_1 FRAME f_cabrel132_1.
 
             VIEW STREAM str_1 rel_dsagenci FRAME f_agencia.

          END.
          
       IF   w-crapass.cdcoptfn <> 0 THEN
            ASSIGN aux_dsacolhe = STRING(aux_cdagectl[w-crapass.cdcoptfn]).
       ELSE
            ASSIGN aux_dsacolhe = "999-Outras".
       
       DISPLAY STREAM str_1 aux_dsacolhe
                            w-crapass.nrdconta
                            w-crapass.nrdbanco
                            w-crapass.nrdocmto
                            w-crapass.vllanmto
                            w-crapass.flgautom
                            w-crapass.flaplica
                            w-crapass.qtdevolu
                            WITH FRAME f_cheqs.
       DOWN STREAM str_1 WITH FRAME f_cheqs.
               
       IF LAST-OF(w-crapass.cdagenci) THEN
          DO:
             OUTPUT STREAM str_1 CLOSE.

             ASSIGN glb_nrcopias = 1
                    glb_nmformul = "132col"
                    glb_nmarqimp = aux_nmarqimp.
					
			 RUN fontes/imprim.p.
			 
          END.
END.

RUN fontes/fimprg.p. 
 
/*............................................................................*/
