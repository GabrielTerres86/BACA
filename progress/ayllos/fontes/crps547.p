/* .............................................................................

   Programa: fontes/crps547.p
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Dezembro/2009                       Ultima atualizacao: 13/03/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Gerar relatório do fechamento diario do SPB X Ayllos.
               Relatorio 536.

   Observacao: Executado no processo diario. Cadeia Exclusiva.
               Solicitacao => 1 Ordem => 14 (Somente processo da Cecred).

   Alteracoes: 20/04/2009 - Solicitado pela Karina o tratamento de novas
                            mensagens:
                            STR0005R2,STR0007R2,STR0025R2,STR0028R2,STR0034R2
                            STR0006R2 e PAG0105R2
                            PAG0107R2,PAG0106R2,PAG0121R2,PAG0124R2,PAG0134R2
                            STR0006,STR0025,STR0028,STR0034
                            PAG0105,PAG0121,PAG0124,PAG0134
                            (Guilherme).
                            
               26/05/2010 - Enviar relatorio 536 para financeiro@cecred.coop.br 
                            (David)   
                            
               30/06/2010 - Mostrar mensagens Rejeitadas (Diego).       
               
               03/08/2010 - Tratar mensagens STR0005R2,STR0007R2, PAG0107R2,
                            PAG0106R2 (Diego).
                            
               06/05/2011 - Com a inclusao do codigo da Agencia das mensagens
                            de devolucao no arquivo da JD, efetuado tratamento
                            para mostra-las no relatorio => CABINE (Diego).   
                            
               14/02/2012 - Tratar PAG0143R2 que ira substituir a PAG0106R2
                            (Diego).                                    
                            
               27/02/2012 - Retirar mensagens nao mais necessarias (Gabriel).
               
               21/06/2012 - Substituida gncoper por crapcop (Tiago)
                          - Tratar mensagens STR0039R2 e PAG0142R2 (Diego).
                          
               13/03/2013 - Retirar STR0028,STR0028R2,PAG0124,PAG0124R2.
                            (Gabriel).           
                          
............................................................................. */


{ includes/var_batch.i } 

DEF STREAM str_1.

DEF TEMP-TABLE tt-lancto NO-UNDO
    FIELD cdagectl AS INTE
    FIELD dsmensag AS CHAR
    FIELD envokstr AS DECI
    FIELD envokpag AS DECI
    FIELD envdestr AS DECI
    FIELD envdepag AS DECI
    FIELD recokstr AS DECI
    FIELD recokpag AS DECI
    FIELD recdestr AS DECI
    FIELD recdepag AS DECI
    FIELD aylenvok AS DECI
    FIELD aylenvde AS DECI
    FIELD aylrecok AS DECI
    FIELD aylrecde AS DECI
    FIELD aylrejei AS DECI
    INDEX tt-lancto1 AS PRIMARY cdagectl.

DEF TEMP-TABLE tt-rej NO-UNDO
    FIELD cdagenci AS INTE FORMAT "zzz9"
    FIELD dsmensag AS CHAR FORMAT "x(20)" 
    FIELD vllanmto AS DECI FORMAT "zzzz,zzz,zz9.99-".

DEFINE VARIABLE aux_cdagectl AS INTEGER                                NO-UNDO.
DEFINE VARIABLE tot_cooperdb AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE tot_coopercr AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE tot_cabinedb AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE tot_cabinecr AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE tot_strcabdb AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE tot_pagcabdb AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE tot_strcabcr AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE tot_pagcabcr AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE tot_gercabdb AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE tot_gercabcr AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE tot_gerayldb AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE tot_geraylcr AS DECIMAL                                NO-UNDO.
DEFINE VARIABLE aux_dscooper AS CHARACTER FORMAT "x(60)"               NO-UNDO.
DEFINE VARIABLE aux_dsagenci AS CHARACTER FORMAT "x(21)"               NO-UNDO.
DEFINE VARIABLE aux_totrejei AS DECIMAL                                NO-UNDO.

DEFINE VARIABLE rel_nrmodulo AS INT      FORMAT "9"                    NO-UNDO.
DEFINE VARIABLE rel_nmmodulo AS CHAR     FORMAT "x(15)" EXTENT 5
                                         INIT ["DEP. A VISTA   ",
                                               "CAPITAL        ",
                                               "EMPRESTIMOS    ",
                                               "DIGITACAO      ",
                                               "GENERICO       "]      NO-UNDO.

DEFINE VARIABLE rel_nmempres AS CHAR     FORMAT "x(15)"                NO-UNDO.
DEFINE VARIABLE rel_nmrelato AS CHAR     FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF VAR h-b1wgen0011 AS HANDLE                                         NO-UNDO.

FORM
    "CABINE FINANCEIRA" AT  20
    "SISTEMA AYLLOS"    AT  82
    SKIP
    "----------------------------------------------------------" AT 01
    "---------------------------------------------------" AT 64
    SKIP
    "Debito"                  AT  34
    "Credito"                 AT  52
    "Debito"                  AT  91
    "Credito"                 AT 108
    WITH WIDTH 132 NO-LABEL FRAME f_header_fechamento.

FORM
    aux_dscooper              AT  01
    SKIP
    "STR - TED/TEC Enviadas"  AT  01 
    tt-lancto.envokstr        AT  25 FORMAT "zzzz,zzz,zz9.99-"
    "TED/TEC Enviadas"        AT  64 
    tt-lancto.aylenvok        AT  82 FORMAT "zzzz,zzz,zz9.99-"
    SKIP
    "PAG - TED/TEC Enviadas"  AT  01 
    tt-lancto.envokpag        AT  25 FORMAT "zzzz,zzz,zz9.99-"
    SKIP
    "STR - Dev. Enviadas"     AT  01 
    tt-lancto.envdestr        AT  25 FORMAT "zzzz,zzz,zz9.99-"
    "Dev. Enviadas"           AT  64
    tt-lancto.aylenvde        AT  82 FORMAT "zzzz,zzz,zz9.99-"
    SKIP
    "PAG - Dev. Enviadas"     AT  01 
    tt-lancto.envdepag        AT  25 FORMAT "zzzz,zzz,zz9.99-"
    SKIP
    "STR - TED/TEC Recebidas" AT  01 
    tt-lancto.recokstr        AT  44 FORMAT "zzzz,zzz,zz9.99-"
    "TED/TEC Recebidas"       AT  64 
    tt-lancto.aylrecok        AT 100 FORMAT "zzzz,zzz,zz9.99-"
    SKIP
    "PAG - TED/TEC Recebidas" AT  01 
    tt-lancto.recokpag        AT  44 FORMAT "zzzz,zzz,zz9.99-"
    SKIP
    "STR - Dev. Recebidas"    AT  01 
    tt-lancto.recdestr        AT  44 FORMAT "zzzz,zzz,zz9.99-"
    "Dev. Recebidas"          AT  64 
    tt-lancto.aylrecde        AT 100 FORMAT "zzzz,zzz,zz9.99-"
    SKIP
    "PAG - Dev. Recebidas"    AT  01 
    tt-lancto.recdepag        AT  44 FORMAT "zzzz,zzz,zz9.99-"
    SKIP
    "Rejeitadas Coop."        AT  64 
    tt-lancto.aylrejei        AT 100 FORMAT "zzzz,zzz,zz9.99-"
    SKIP
    "---------------"        AT  25
    "---------------"        AT  44
    "---------------"        AT  82
    "---------------"        AT  100
    SKIP
    "TOTAL -------->>"        AT  01 
    tot_cabinedb              AT  25 FORMAT "zzzz,zzz,zz9.99-"
    tot_cabinecr              AT  44 FORMAT "zzzz,zzz,zz9.99-"
    tot_cooperdb              AT  82 FORMAT "zzzz,zzz,zz9.99-"
    tot_coopercr              AT 100 FORMAT "zzzz,zzz,zz9.99-"
    SKIP(2)
    WITH DOWN WIDTH 132 NO-LABEL FRAME f_fechamento.

FORM
    "TOTAL STR"   AT  01 
    tot_strcabdb  AT  25 FORMAT "zzzz,zzz,zz9.99-"
    tot_strcabcr  AT  44 FORMAT "zzzz,zzz,zz9.99-"
    SKIP
    "TOTAL PAG"   AT  01
    tot_pagcabdb  AT  25 FORMAT "zzzz,zzz,zz9.99-"
    tot_pagcabcr  AT  44 FORMAT "zzzz,zzz,zz9.99-"
    SKIP
    "TOTAL GERAL" AT  01
    tot_gercabdb  AT  25 FORMAT "zzzz,zzz,zz9.99-"
    tot_gercabcr  AT  44 FORMAT "zzzz,zzz,zz9.99-"
    tot_gerayldb  AT  82 FORMAT "zzzz,zzz,zz9.99-"
    tot_geraylcr  AT 100 FORMAT "zzzz,zzz,zz9.99-"
    WITH WIDTH 132 NO-LABEL FRAME f_totais.

FORM 
    SKIP(2)
    "----------------- NAO INTEGRADAS NO AYLLOS -----------------" AT 01
    WITH WIDTH 132 NO-LABEL FRAME f_header_rejeitados.

FORM 
    aux_dsagenci    AT 01 COLUMN-LABEL "Agencia"
    tt-rej.dsmensag AT 23 COLUMN-LABEL "Mensagem"
    tt-rej.vllanmto AT 45 COLUMN-LABEL "Valor "   FORMAT "zzzz,zzz,zz9.99-"
    WITH DOWN WIDTH 132 FRAME f_rejeitados.
    
FORM 
    "TOTAL -------->>" AT 01
    aux_totrejei       AT 45 FORMAT "zzzz,zzz,zz9.99-"
    WITH WIDTH 132 NO-LABEL FRAME f_tot_rejeitados.

ASSIGN glb_cdprogra = "crps547".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.

EMPTY TEMP-TABLE tt-lancto.

/* Movimentacoes registradas pelo cabine financeira - JD */
FOR EACH gnmvspb WHERE gnmvspb.dtmensag = glb_dtmvtolt NO-LOCK:

    IF  gnmvspb.dsdebcre = "D"  THEN
        ASSIGN aux_cdagectl = gnmvspb.cdagendb.
    ELSE
        ASSIGN aux_cdagectl = gnmvspb.cdagencr.
    
    /* Se nao for mensagens das cooperativas filiadas cria rejeitadas */
    FIND crapcop WHERE crapcop.cdagectl = aux_cdagectl NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL crapcop  THEN
        DO:
            CREATE tt-rej.
            ASSIGN tt-rej.cdagenci = aux_cdagectl
                   tt-rej.dsmensag = gnmvspb.dsmensag
                   tt-rej.vllanmto = gnmvspb.vllanmto.
            NEXT.
        END.
    
    FIND FIRST tt-lancto WHERE tt-lancto.cdagectl = aux_cdagectl
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAIL tt-lancto  THEN
        DO:
            IF  NOT LOCKED tt-lancto  THEN 
                DO:
                    CREATE tt-lancto.
                    ASSIGN tt-lancto.cdagectl = aux_cdagectl.
                END.
        END.
    
    /* TED´s TEC´s Enviados STR */
    IF  CAN-DO("STR0008,STR0005,STR0037," +
               "STR0006,STR0025,STR0034",
               gnmvspb.dsmensag)  THEN
        ASSIGN tt-lancto.envokstr = tt-lancto.envokstr + gnmvspb.vllanmto
               tot_strcabdb = tot_strcabdb + gnmvspb.vllanmto.
    ELSE
    /* Devolucao Enviada STR */
    IF  gnmvspb.dsmensag = "STR0010" THEN
        ASSIGN tt-lancto.envdestr = tt-lancto.envdestr + gnmvspb.vllanmto
               tot_strcabdb = tot_strcabdb + gnmvspb.vllanmto.
    ELSE
    /* TED´s TEC´s Enviados PAG */
    IF  CAN-DO("PAG0108,PAG0107,PAG0137," +
               "PAG0121,PAG0134",
               gnmvspb.dsmensag) THEN
        ASSIGN tt-lancto.envokpag = tt-lancto.envokpag + gnmvspb.vllanmto
               tot_pagcabdb = tot_pagcabdb + gnmvspb.vllanmto.
    ELSE
    /* Devolucao Enviada PAG */ 
    IF  gnmvspb.dsmensag = "PAG0111" THEN
        ASSIGN tt-lancto.envdepag = tt-lancto.envdepag + gnmvspb.vllanmto
               tot_pagcabdb = tot_pagcabdb + gnmvspb.vllanmto.
    ELSE
    /* TED´s TEC´s Recebidos STR */
    IF  CAN-DO("STR0008R2,STR0037R2," + 
               "STR0005R2,STR0007R2,STR0025R2,STR0034R2,STR0006R2," +
               "STR0039R2",TRIM(gnmvspb.dsmensag))  THEN
        ASSIGN tt-lancto.recokstr = tt-lancto.recokstr + gnmvspb.vllanmto
               tot_strcabcr = tot_strcabcr + gnmvspb.vllanmto.
    ELSE
    /* Devolucao Recebida STR */ 
    IF   gnmvspb.dsmensag = "STR0010R2" THEN
         ASSIGN tt-lancto.recdestr = tt-lancto.recdestr + gnmvspb.vllanmto
                tot_strcabcr = tot_strcabcr + gnmvspb.vllanmto.
    ELSE
    /* TED´s TEC´s Recebidos PAG */
    IF  CAN-DO("PAG0108R2,PAG0137R2,PAG0143R2,PAG0142R2," +
               "PAG0107R2,PAG0121R2,PAG0134R2",
               TRIM(gnmvspb.dsmensag))  THEN
        ASSIGN tt-lancto.recokpag = tt-lancto.recokpag + gnmvspb.vllanmto
               tot_pagcabcr = tot_pagcabcr + gnmvspb.vllanmto.
    ELSE
    /* Devolucao Recebida PAG */ 
    IF  gnmvspb.dsmensag = "PAG0111R2" THEN
        ASSIGN tt-lancto.recdepag = tt-lancto.recdepag + gnmvspb.vllanmto
               tot_pagcabcr = tot_pagcabcr + gnmvspb.vllanmto.
    ELSE
    DO:
        CREATE tt-rej.
        ASSIGN tt-rej.cdagenci = aux_cdagectl
               tt-rej.dsmensag = gnmvspb.dsmensag
               tt-rej.vllanmto = gnmvspb.vllanmto.
    END.
END.

/* Movimentacoes registrada no Ayllos */
FOR EACH gnmvcen WHERE gnmvcen.dtmvtolt = glb_dtmvtolt NO-LOCK:

    FIND FIRST tt-lancto WHERE 
               tt-lancto.cdagectl = gnmvcen.cdagectl
               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAIL tt-lancto  THEN
        DO:
            IF  NOT LOCKED tt-lancto  THEN 
                DO:
                    CREATE tt-lancto.
                    ASSIGN tt-lancto.cdagectl = gnmvcen.cdagectl.
                END.
        END.

    /* TED´s TEC´s Enviados */
    IF  CAN-DO("STR0008,STR0005,STR0037,PAG0108," +
               "PAG0107,PAG0137",gnmvcen.dsmensag)  THEN
        ASSIGN tt-lancto.aylenvok = tt-lancto.aylenvok + gnmvcen.vllanmto.
    ELSE
    /* Devolucoes Enviadas TED´s TEC´s */
    IF  CAN-DO("STR0010,PAG0111",gnmvcen.dsmensag)  THEN
        ASSIGN tt-lancto.aylenvde = tt-lancto.aylenvde + gnmvcen.vllanmto.
    ELSE    
    /* TED´s TEC´s Recebidos */
    IF  CAN-DO("STR0005R2,STR0007R2,STR0008R2,STR0037R2," +
               "PAG0107R2,PAG0108R2,PAG0137R2,PAG0143R2",
               gnmvcen.dsmensag) THEN
        ASSIGN tt-lancto.aylrecok = tt-lancto.aylrecok + gnmvcen.vllanmto.
    ELSE
    /* Devolucoes Recebidas TED´s TEC´s */
    IF  CAN-DO("STR0010R2,PAG0111R2",gnmvcen.dsmensag)  THEN
        ASSIGN tt-lancto.aylrecde = tt-lancto.aylrecde + gnmvcen.vllanmto.
    ELSE
    /* Rejeitadas pela Cooperativa */ 
    IF  CAN-DO("MSGREJ",gnmvcen.dsmensag)  THEN
        ASSIGN tt-lancto.aylrejei = tt-lancto.aylrejei + gnmvcen.vllanmto. 

END.

{ includes/cabrel132_1.i }          /*  Monta cabecalho do relatorio  */

ASSIGN glb_nmformul = ""
       glb_nrcopias = 1                                       
       glb_nmarqimp = "rl/crrl536.lst".

OUTPUT STREAM str_1 TO VALUE(glb_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

VIEW STREAM str_1 FRAME f_header_fechamento.

FOR EACH tt-lancto NO-LOCK BREAK BY tt-lancto.cdagectl:

    IF  FIRST-OF(tt-lancto.cdagectl) THEN
        DO:
            FIND crapcop WHERE 
                 crapcop.cdagectl = tt-lancto.cdagectl NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapcop  THEN
                DO:
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - " + glb_cdprogra + "' --> '"  +
                                  "Agencia nao cadastrada nas cooperativas " + 
                                      " filiadas. Agencia: " + 
                                      STRING(tt-lancto.cdagectl) +
                                      " >> log/proc_batch.log").
                    NEXT.
                END.

            ASSIGN aux_dscooper = STRING(crapcop.cdcooper) + 
                                  " - " + crapcop.nmrescop.
        END.
           /* Cabine Financeira - JD */
    ASSIGN tot_cabinedb = tot_cabinedb + 
                          tt-lancto.envokstr +
                          tt-lancto.envokpag +
                          tt-lancto.envdestr +
                          tt-lancto.envdepag
           tot_cabinecr = tot_cabinecr + 
                          tt-lancto.recokstr +
                          tt-lancto.recokpag + 
                          tt-lancto.recdestr + 
                          tt-lancto.recdepag
           /* Ayllos */
           tot_cooperdb = tot_cooperdb + 
                          tt-lancto.aylenvok + 
                          tt-lancto.aylenvde
           tot_coopercr = tot_coopercr + 
                          tt-lancto.aylrecok + 
                          tt-lancto.aylrecde + 
                          tt-lancto.aylrejei.
    
    ASSIGN tot_gercabdb = tot_gercabdb + tot_cabinedb
           tot_gercabcr = tot_gercabcr + tot_cabinecr
           tot_gerayldb = tot_gerayldb + tot_cooperdb
           tot_geraylcr = tot_geraylcr + tot_coopercr.

    IF  LINE-COUNTER(str_1) >= 70  THEN
        DO:
            PAGE STREAM str_1.
            VIEW STREAM str_1 FRAME f_cabrel132_1.
            VIEW STREAM str_1 FRAME f_header_fechamento.
        END.
    
    DISPLAY STREAM str_1 aux_dscooper
                         tt-lancto.envokstr
                         tt-lancto.envokpag
                         tt-lancto.envdestr
                         tt-lancto.envdepag
                         tt-lancto.recokstr
                         tt-lancto.recokpag
                         tt-lancto.recdestr
                         tt-lancto.recdepag
                         tt-lancto.aylenvok
                         tt-lancto.aylenvde
                         tt-lancto.aylrecok
                         tt-lancto.aylrecde
                         tt-lancto.aylrejei
                         tot_cabinedb tot_cabinecr tot_cooperdb tot_coopercr 
                         WITH FRAME f_fechamento.
    
    DOWN WITH FRAME f_fechamento.
    
    IF  LAST-OF(tt-lancto.cdagectl)  THEN
        DO:
            ASSIGN tot_cabinedb = 0
                   tot_cabinecr = 0
                   tot_cooperdb = 0
                   tot_coopercr = 0.
        END.

END.

DISPLAY STREAM str_1 tot_strcabdb tot_strcabcr 
                     tot_pagcabdb tot_pagcabcr 
                     tot_gercabdb tot_gercabcr tot_gerayldb tot_geraylcr
                     WITH FRAME f_totais.

IF  LINE-COUNTER(str_1) >= 80  THEN
    PAGE STREAM str_1.

VIEW STREAM str_1 FRAME f_header_rejeitados.

FOR EACH tt-rej NO-LOCK:

    IF  LINE-COUNTER(str_1) >= 80  THEN
        DO:
            PAGE STREAM str_1.
            VIEW STREAM str_1 FRAME f_header_rejeitados.
        END.

    FIND crapcop WHERE crapcop.cdagectl = tt-rej.cdagenci NO-LOCK NO-ERROR.

    IF  AVAIL crapcop  THEN
        ASSIGN aux_dsagenci = STRING(tt-rej.cdagenci,"zzz9") 
                              + " - " + crapcop.nmrescop.
    ELSE
        ASSIGN aux_dsagenci = STRING(tt-rej.cdagenci,"zzz9") 
                              + " - NAO CADASTRADA". 
    
    ASSIGN aux_totrejei = aux_totrejei + tt-rej.vllanmto.
        
    DISPLAY STREAM str_1 aux_dsagenci
            tt-rej.dsmensag
            tt-rej.vllanmto
            WITH FRAME f_rejeitados.

    DOWN WITH FRAME f_rejeitados.

END.

DISPLAY STREAM str_1 aux_totrejei WITH FRAME f_tot_rejeitados.

OUTPUT STREAM str_1 CLOSE.

RUN fontes/imprim.p.

RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.

RUN converte_arquivo IN h-b1wgen0011 (INPUT glb_cdcooper,
                                      INPUT glb_nmarqimp,
                                      INPUT SUBSTR(glb_nmarqimp,4)).

RUN enviar_email IN h-b1wgen0011 (INPUT glb_cdcooper,
                                  INPUT glb_cdprogra,
                                  INPUT "financeiro@cecred.coop.br",
                                  INPUT "FECHAMENTO SPB - CECRED",
                                  INPUT SUBSTR(glb_nmarqimp,4),
                                  INPUT TRUE).
                       
DELETE PROCEDURE h-b1wgen0011.

RUN fontes/fimprg.p.

/*............................................................................*/
