/* .............................................................................

   Programa: Fontes/seguro_i.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/97.                           Ultima atualizacao: 12/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da inclusao do seguro.

   Alteracoes: 19/08/97 - Alterado para tratar seguro auto em mais de uma segu-
                          radora e tratar pagto com parcela unica (Edson).

               12/09/97 - Alterado para deixar passar valores de verba especial
                          e danos morais iguais a tabela (Deborah).

               30/10/97 - Alterado para nao criticar o dia do debito para os
                          seguros com parcela unica (Edson).

               06/11/97 - Alterado para tratar coberturas extras de seguro e
                          data de inicio de vigencia retroativa (Edson).

               06/04/1999 - Alterado para na inclusao de renovacao de auto,
                            buscar os dados da proposta anterior (Deborah).
                            
               08/04/1999 - Alterado para tratar o ano bisexto (Edson).

               02/08/1999 - Tratar seguro de vida em grupo (Deborah).
               
               10/11/1999 - Seguro de vida para conjuge (Deborah). 

               20/01/2000 - Tratar seguro prestamista (Deborah).
               
               02/05/2001 - Permitir o cadastramento de seguro auto parcelado.
                            (Ze Eduardo).
                            
               01/08/2001 - Alteracao a pedido do Sr. Marcelo deixar 0 o valor. 
                            Qdo a alteracao do veiculo sem modificar 
                            o valor do seguro (Ze Eduardo).

               21/09/2001 - Seguro Residencial (Ze Eduardo).

               28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).

               03/01/2002 - Acertos no seguro residencial (Ze Eduardo).
               
               31/07/2003 - Inclusao da rotina ver_cadastro.p (Julio).
               
               11/08/2003 - Acertos na qtdade de prestacoes (Auto) (Ze Eduardo)
               
               16/06/2004 - Ajuste no controle de idade para contratacao de
                            seguro vida/prestamista (Edson).
                            
               23/03/2005 - Acertos para novo modelo de cadastramento de
                            seguro (Unibanco), escolher tipo e seguradora
                            atraves de listas (Evandro)

               05/07/2005 - Alimentado campo cdcooper das tabelas crapseg e 
                            crawseg (Diego).

               10/08/2005 - Alterado para buscar descricao do estado civil
                            na tabela generica gnetcvl(Diego).
               
               24/08/2005 - Incluir F7 para Plano contratado (Ze).

               24/11/2005 - Tratamento para b_segura mandar todas seguradoras
                            (CASA) para a mesma tela (Julio).
                            
               01/12/2005 - Tratamento para seguro SUL AMERICA-CASA (Evandro).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               09/02/2006 - Bloqueado Sul-America Seguros (Temporario) (Julio)
               
               12/06/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).
                            
               12/09/2006 - Excluidas opcoes "TAB" (Diego).
               
               15/09/2006 - Alterado para nao permitir a inclusao do seguro
                            de VIDA mais de uma vez na mesma conta (Diego).
               
               31/10/2007 - Alterado nmdsecao(crapass) para ttl.nmdsecao
                          - Utilizar rotina ver_capital e ver_cadastro 
                            da b1gwen0001 (Guilherme).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
                          - Retirada inclusao de contratos AUTO (Gabriel).
                          - So mostrar seguradoras com flgativo "Sim" (Gabriel)
                          
               13/07/2009 - Buscar dados conjuge da tabela crapcje(Guilherme).

               29/03/2010 - Automatizar seguro de residencial, desativando
                            a LANSEG.
                            Retirar o seguro de casa do tipo 1.    
                            Retirar comentarios desnecessarios. (Gabriel).
                            
               04/10/2010 - Bloquear seguro residencial para PJ (David).
               
               13/05/2011 - Alteracao na criacao dos seguros de vida e prestamista.
                            - Nao permitir idade menor que 14 anos.
                            - Buscar dados do conjugue na crapass caso ele seja
                              um cooperado.
                              
               27/06/2011 - Bloqueado seguro prestamista para PJ. (Fabricio)
               
               31/08/2011 - Adicionada busca no metodo buscar_tip_seguro,
                            buscar_seguradora, valida_inc_seguro,
                            busca_end_cor da bo b1wgen0033.
                            (Gati - Oliver)
                            
               16/12/2011 - Incluido a passagem do parametro seg_dtnascsg nas
                            procedures:
                            - validar_criacao
                            - cria_seguro
                            (Adriano).            
                            
               30/04/2012 - Habilitar mensagem de bloqueio seguro VIDA para
                            pessoa juridica (Diego).        
                            
               17/12/2012 - Incluir mensagem alerta para seguro de vida se
                            aux_flgsegur for true (Lucas R.)
                            
               28/02/2013 - Incluir aux_flgsegur em procedure cria_seguro
                            (Lucas R.)
                            
               25/07/2013 - Incluido o campo Complemento no endereco. (James)
               
               24/09/2014 - Tratar vigencia de 01 ano nos seguros de vida. 
                            Chamado 150612 (Jonata-RKAM).
                            
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
               
............................................................................. */
{ sistema/generico/includes/b1wgen0038tt.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_seguro.i }

DEF BUFFER btt-seguros   FOR tt-seguros.    

DEF        VAR aux_nrdeanos AS INT                                   NO-UNDO.
DEF        VAR aux_nrdmeses AS INT                                   NO-UNDO.
DEF        VAR aux_dsdidade AS CHAR                                  NO-UNDO.
DEF        VAR aux_flghaseg AS LOGICAL                               NO-UNDO.
DEF        VAR aux_qtregist AS INT                                   NO-UNDO.
DEF        VAR aux_flgsegur AS LOG                                   NO-UNDO.

/* Include com a tt-erro */
{ sistema/generico/includes/var_internet.i }
/* HANDLE para b1wgen0001 */
DEF VAR h-b1wgen0001 AS HANDLE                                       NO-UNDO.

/* flag para saber se rodou a rotina nova de seguros */
DEF VAR aux_flgrotin AS LOGICAL                                      NO-UNDO.

DEF BUFFER b-crapass1 FOR crapass.

DEF TEMP-TABLE tt-associado1 LIKE tt-associado.

/*  F7 de Plano contratado  */
DEF TEMP-TABLE crawtmp                                               NO-UNDO
    FIELD tpplaseg LIKE crapsga.tpplaseg
    FIELD nmresseg LIKE crapcsg.nmresseg
    FIELD flgunica LIKE crapsga.flgunica
    INDEX crawrel1 AS PRIMARY tpplaseg.
 
DEF QUERY  q_tpplaseg FOR crawtmp. 
DEF BROWSE b_tpplaseg QUERY q_tpplaseg
           DISP crawtmp.tpplaseg  COLUMN-LABEL "Plano"
                crawtmp.nmresseg  COLUMN-LABEL "Seguradora" FORMAT "x(20)"
                crawtmp.flgunica  COLUMN-LABEL "Parcelamento"
                WITH 10 DOWN OVERLAY.    

FORM b_tpplaseg SKIP 
     WITH NO-BOX CENTERED OVERLAY ROW 6 FRAME f_tpplaseg.


RUN sistema/generico/procedures/b1wgen0033.p
    PERSISTENT SET h-b1wgen0033.

RUN buscar_associados IN h-b1wgen0033(INPUT glb_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT glb_cdoperad,
                                      INPUT glb_dtmvtolt,
                                      INPUT tel_nrdconta,
                                      INPUT 1,
                                      INPUT 1,
                                      INPUT glb_nmdatela,
                                      INPUT FALSE,
                                      OUTPUT TABLE tt-associado,
                                      OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0033.

IF   RETURN-VALUE <> "OK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        IF   AVAIL tt-erro   THEN
            DO:
                ASSIGN glb_cdcritic = tt-erro.cdcritic
                       glb_dscritic = tt-erro.dscritic.
                RETURN.
            END.
    END.

FIND tt-associado WHERE
     tt-associado.cdcooper = glb_cdcooper  AND
     tt-associado.nrdconta = tel_nrdconta  NO-ERROR.


ON RETURN OF tel_tpseguro DO:

   HIDE FRAME f_tipo.

   IF   tel_tpseguro:SCREEN-VALUE = "CASA"   THEN
        DO:
                 
            RUN sistema/generico/procedures/b1wgen0033.p 
                PERSISTENT SET h-b1wgen0033.

            /* Bloqueio pessoa juridica */ 
            RUN valida_inc_seguro IN h-b1wgen0033(INPUT glb_cdcooper,
                                                  INPUT 0,
                                                  INPUT 0,
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT tel_nrdconta,
                                                  INPUT 1,
                                                  INPUT 1,
                                                  INPUT glb_nmdatela,
                                                  INPUT FALSE,
                                                  INPUT tt-associado.inpessoa,
                                                  OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0033.

            IF   RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF   AVAIL tt-erro   THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                            VIEW FRAME f_tipo.
                            RETURN NO-APPLY.
                        END.
                END.
            
            RUN seguro_casa.

            IF RETURN-VALUE <> "OK" THEN DO:
                BELL.
                VIEW FRAME f_tipo.
                RETURN NO-APPLY.
            END.

            IF   aux_flgrotin = TRUE   THEN  /* se rodou a nova rotina */
                 LEAVE.
            ELSE
            IF   KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN
                 DO:
                    PAUSE(0).
                    APPLY "GO".   /* para executar a rotina antiga */
                 END.
        END.
   ELSE
        /* VIDA E PRESTAMISTA */ 
        DO:
            /** Bloquear seguro prestamista para pessoa juridica **/
            RUN sistema/generico/procedures/b1wgen0033.p 
                PERSISTENT SET h-b1wgen0033.

            /* Bloqueio pessoa juridica */ 
            RUN valida_inc_seguro IN h-b1wgen0033(INPUT glb_cdcooper,
                                                  INPUT 0,
                                                  INPUT 0,
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT tel_nrdconta,
                                                  INPUT 1,
                                                  INPUT 1,
                                                  INPUT glb_nmdatela,
                                                  INPUT FALSE,
                                                  INPUT tt-associado.inpessoa,
                                                  OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0033.

            IF   RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    IF   AVAIL tt-erro   THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                            VIEW FRAME f_tipo.
                            RETURN NO-APPLY.
                        END.
                END.

            APPLY "GO".

        END.

END.


IF   tt-associado.inpessoa = 1   THEN 
    DO:
        RUN sistema/generico/procedures/b1wgen0033.p
            PERSISTENT SET h-b1wgen0033.

        RUN buscar_titular IN h-b1wgen0033(INPUT glb_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT glb_cdoperad,
                                           INPUT glb_dtmvtolt,
                                           INPUT tel_nrdconta,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT glb_nmdatela,
                                           INPUT FALSE,
                                           OUTPUT TABLE tt-titular,
                                           OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0033.    

        FIND tt-titular WHERE
             tt-titular.cdcooper = glb_cdcooper       AND
             tt-titular.nrdconta = tt-associado.nrdconta   AND
             tt-titular.idseqttl = 1 NO-LOCK NO-ERROR.
        IF  AVAIL tt-titular  THEN
            ASSIGN aux_cdempres = tt-titular.cdempres.
    END.
ELSE
    DO:
        RUN sistema/generico/procedures/b1wgen0033.p
            PERSISTENT SET h-b1wgen0033.

        RUN buscar_pessoa_juridica IN h-b1wgen0033(INPUT glb_cdcooper,
                                                   INPUT 0,
                                                   INPUT 0,
                                                   INPUT glb_cdoperad,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT tel_nrdconta,
                                                   INPUT 1,
                                                   INPUT 1,
                                                   INPUT glb_nmdatela,
                                                   INPUT FALSE,
                                                   OUTPUT TABLE tt-pess-jur,
                                                   OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0033.

        FIND tt-pess-jur WHERE
             tt-pess-jur.cdcooper = glb_cdcooper      AND
             tt-pess-jur.nrdconta = tt-associado.nrdconta  NO-ERROR.
        IF  AVAIL tt-pess-jur THEN
            ASSIGN aux_cdempres = tt-pess-jur.cdempres.
    END.

RUN sistema/generico/procedures/b1wgen0033.p
    PERSISTENT SET h-b1wgen0033.

RUN buscar_empresa IN h-b1wgen0033(INPUT glb_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT glb_cdoperad,
                                   INPUT glb_dtmvtolt,
                                   INPUT tel_nrdconta,
                                   INPUT 1,
                                   INPUT 1,
                                   INPUT glb_nmdatela,
                                   INPUT FALSE,
                                   INPUT aux_cdempres,
                                   OUTPUT TABLE tt-empresa,
                                   OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0033.

IF   RETURN-VALUE <> "OK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        IF   AVAIL tt-erro   THEN
            DO:
                ASSIGN glb_cdcritic = tt-erro.cdcritic
                       glb_dscritic = tt-erro.dscritic.
                RETURN.
            END.
    END.
    
FIND tt-empresa WHERE
     tt-empresa.cdcooper = glb_cdcooper  AND
     tt-empresa.cdempres = aux_cdempres  NO-ERROR.

IF   glb_cdcritic > 0   THEN
     RETURN.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       RUN sistema/generico/procedures/b1wgen0033.p 
           PERSISTENT SET h-b1wgen0033.

       RUN buscar_tip_seguro IN h-b1wgen0033(INPUT glb_cdcooper,
                                             INPUT 0,
                                             INPUT 0,
                                             INPUT glb_cdoperad,
                                             INPUT glb_dtmvtolt,
                                             INPUT tel_nrdconta,
                                             INPUT 1,
                                             INPUT 1,
                                             INPUT glb_nmdatela,
                                             INPUT FALSE,
                                             INPUT seg_cdsegura,
                                             INPUT 0, /* tpseguro */
                                             INPUT 0,
                                             OUTPUT aux_tpseguro,
                                             OUTPUT TABLE tt-erro).

       DELETE PROCEDURE h-b1wgen0033.

       DO aux2_tpseguro = 1 TO NUM-ENTRIES(aux_tpseguro,";"):
           tel_tpseguro:ADD-LAST(ENTRY(aux2_tpseguro,aux_tpseguro,";"))
               IN FRAME f_tipo NO-ERROR.

           IF aux2_tpseguro = 1 THEN
               ASSIGN tel_tpseguro = ENTRY(aux2_tpseguro,aux_tpseguro,";").
       END.

       UPDATE tel_tpseguro WITH FRAME f_tipo.
       LEAVE.
   END.

   HIDE FRAME f_tipo.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        RETURN.

   LEAVE. 

END.   /*  Fim do DO WHILE TRUE  */


RUN sistema/generico/procedures/b1wgen0033.p 
    PERSISTENT SET h-b1wgen0033.

RUN buscar_end_coo IN h-b1wgen0033(INPUT glb_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT glb_cdoperad,
                                   INPUT glb_dtmvtolt,
                                   INPUT tt-associado.nrdconta,
                                   INPUT 1,
                                   INPUT 1,
                                   INPUT glb_nmdatela,
                                   INPUT FALSE,
                                   OUTPUT TABLE tt-end-coop,
                                   OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0033.

FIND FIRST tt-end-coop WHERE
           tt-end-coop.cdcooper = glb_cdcooper           AND
           tt-end-coop.nrdconta = tt-associado.nrdconta  AND
           tt-end-coop.idseqttl = 1                      NO-ERROR.

ASSIGN seg_nmdsegur = tt-associado.nmprimtl
       seg_nrcpfcgc = IF tt-associado.inpessoa = 1
                         THEN STRING(tt-associado.nrcpfcgc)
                         ELSE STRING(tt-associado.nrcpfcgc)
       seg_cdsexosg = tt-associado.cdsexotl
       seg_dtnascsg = tt-associado.dtnasctl
       seg_nmempres = tt-empresa.nmextemp
       seg_nrcadast = tt-associado.nrcadast
       seg_nrfonemp = tt-associado.nrfonemp
       seg_dsendres = tt-end-coop.dsendere + " " +
                      TRIM(STRING(tt-end-coop.nrendere,"zzz,zzz"))
       seg_nrfonres = tt-associado.nrfonres
       seg_nmbairro = tt-end-coop.nmbairro
       seg_nmcidade = tt-end-coop.nmcidade
       seg_cdufresd = tt-end-coop.cdufende
       seg_nrcepend = tt-end-coop.nrcepend
       seg_complend = tt-end-coop.complend

       seg_dtinivig = glb_dtmvtolt

       seg_ddvencto = DAY(seg_dtinivig)
       seg_nrctrato = 0

       seg_tpseguro = 3
       seg_flgdutil = TRUE

       seg_flgunica = FALSE
       seg_flgvisto = FALSE

       seg_nmresseg = ""
       aux_indposic = 1
       aux_indpostp = 1 
       seg_dstitseg = TRIM(ENTRY(1,aux_dstitseg))
       seg_dstipseg = IF  tel_tpseguro:SCREEN-VALUE = "VIDA"   THEN
                          TRIM(ENTRY(1,aux_dstipseg))
                      ELSE
                          TRIM(ENTRY(2,aux_dstipseg))
       seg_vldifseg = 0
       seg_vlfrqobr = 0
       seg_dsestcvl = " "
       seg_dtnasctl = tt-associado.dtnasctl
       seg_cdsexosg = tt-associado.cdsexotl.

                          
RUN fontes/calcdata.p (seg_dtinivig, 1, "A", 0, OUTPUT seg_dtfimvig).

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   DISPLAY seg_dstipseg WITH FRAME f_seguro_1.
   

   UPDATE seg_dstitseg 
          seg_cdsexosg WITH FRAME f_seguro_1 
   
   EDITING:
   
      READKEY.

      IF   FRAME-FIELD = "seg_dstitseg"   THEN
           DO:
               IF   CAN-DO("CURSOR-UP,CURSOR-RIGHT",KEYFUNCTION(LASTKEY))  THEN
                    DO:
                        IF   aux_indposic > NUM-ENTRIES(aux_dstitseg)   THEN
                             aux_indposic = NUM-ENTRIES(aux_dstitseg).
                    
                        aux_indposic = aux_indposic - 1.
   
                        IF   aux_indposic = 0   THEN
                             aux_indposic = NUM-ENTRIES(aux_dstitseg).
   
                        seg_dstitseg = ENTRY(aux_indposic,aux_dstitseg).
   
                        DISPLAY seg_dstitseg WITH FRAME f_seguro_1.
                    END.
               ELSE
               IF   CAN-DO("CURSOR-DOWN,CURSOR-LEFT",KEYFUNCTION(LASTKEY)) THEN
                    DO:
                        aux_indposic = aux_indposic + 1.
   
                        IF   aux_indposic > NUM-ENTRIES(aux_dstitseg)  THEN
                             aux_indposic = 1.
          
                        seg_dstitseg = TRIM(ENTRY(aux_indposic,aux_dstitseg)).
   
                        DISPLAY seg_dstitseg WITH FRAME f_seguro_1.
                    END.
               ELSE
               IF   CAN-DO("RETURN,BACK-TAB,GO",KEYFUNCTION(LASTKEY))   THEN
                    DO:
                        IF   TRIM(ENTRY(aux_indposic,aux_cdtitseg)) = "2" THEN
                             DO:
                                /* Busca conjuge */
                                RUN sistema/generico/procedures/b1wgen0033.p
                                    PERSISTENT SET h-b1wgen0033.

                                RUN buscar_inf_conjuge IN h-b1wgen0033
                                    (INPUT tt-associado.cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_dtmvtolt,
                                     INPUT tt-associado.nrdconta,
                                     INPUT 1,
                                     INPUT 1,
                                     INPUT glb_nmdatela,
                                     INPUT FALSE,
                                     OUTPUT TABLE tt-inf-conj,
                                     OUTPUT TABLE tt-erro).

                                DELETE PROCEDURE h-b1wgen0033.

                                IF RETURN-VALUE <> "OK" THEN 
                                    DO:
                                        FIND FIRST tt-erro NO-ERROR.
                                        IF AVAIL tt-erro THEN 
                                            DO:
                                                IF tt-erro.cdcritic <> 0 THEN DO:
                                                    glb_cdcritic = tt-erro.cdcritic.
                                                    glb_dscritic = tt-erro.dscritic.
                                                END.
                                                ELSE
                                                    glb_dscritic = tt-erro.dscritic.
        
                                                MESSAGE glb_dscritic.
                                                BELL.
                                                glb_cdcritic = 0.
                                                NEXT-PROMPT seg_dstitseg 
                                                    WITH FRAME f_seguro_1.
                                                NEXT.
                                            END.
                                    END.

                                FIND tt-inf-conj WHERE 
                                     tt-inf-conj.cdcooper =
                                         tt-associado.cdcooper  AND
                                     tt-inf-conj.nrdconta =
                                         tt-associado.nrdconta  AND
                                     tt-inf-conj.idseqttl = 1   NO-ERROR.
                                
                                IF AVAIL tt-inf-conj THEN
                                   DO: 
                                       RUN
                                       sistema/generico/procedures/b1wgen0033.p
                                       PERSISTENT SET h-b1wgen0033.

                                       RUN buscar_associados IN h-b1wgen0033
                                           (INPUT glb_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT glb_cdoperad,
                                            INPUT glb_dtmvtolt,
                                            INPUT tt-inf-conj.nrctacje,
                                            INPUT 1,
                                            INPUT 1,
                                            INPUT glb_nmdatela,
                                            INPUT FALSE,
                                            OUTPUT TABLE tt-associado1,
                                            OUTPUT TABLE tt-erro).

                                       DELETE PROCEDURE h-b1wgen0033.

                                       FIND tt-associado1 WHERE
                                            tt-associado1.cdcooper =
                                                 tt-inf-conj.cdcooper AND
                                            tt-associado1.nrdconta =
                                                  tt-inf-conj.nrctacje NO-ERROR.
                                      
                                       IF NOT AVAIL tt-associado1 THEN
                                          DO: 
                                             ASSIGN
                                             seg_nmdsegur = tt-inf-conj.nmconjug
                                             seg_dtnascsg = tt-inf-conj.dtnasccj
                                             seg_nrcpfcgc =
                                                   STRING(tt-inf-conj.nrcpfcjg).
                                                       
                                             DISPLAY seg_nmdsegur
                                                     seg_nrcpfcgc
                                                     seg_dtnascsg
                                                     WITH FRAME f_seguro_1.

                                          END.
                                       ELSE
                                          DO: 
                                             ASSIGN
                                             seg_nmdsegur =
                                                 tt-associado1.nmprimtl
                                             seg_dtnascsg =
                                                 tt-associado1.dtnasctl
                                             seg_nrcpfcgc =
                                                 STRING(tt-associado1.nrcpfcgc).
                                                       
                                             DISPLAY seg_nmdsegur
                                                     seg_nrcpfcgc
                                                     seg_dtnascsg
                                                     WITH FRAME f_seguro_1.
                                          END.
                                   END.
                             END.
                        ELSE           
                        IF   TRIM(ENTRY(aux_indposic,aux_cdtitseg)) = "1"  THEN
                             DO:

                                ASSIGN
                                seg_nmdsegur = tt-associado.nmprimtl    
                                seg_dtnascsg = tt-associado.dtnasctl
                                seg_nrcpfcgc = IF tt-associado.inpessoa = 1 THEN
                                                  STRING(tt-associado.nrcpfcgc)
                                               ELSE 
                                                  STRING(tt-associado.nrcpfcgc).
                                DISPLAY seg_nmdsegur 
                                        seg_nrcpfcgc
                                        seg_dtnascsg WITH FRAME f_seguro_1.
                             END.
                        ELSE     
                             DO:
                                 ASSIGN seg_nmdsegur = ""
                                        seg_nrcpfcgc = ""
                                        seg_dtnascsg = ?.
              
                                 DISPLAY seg_nmdsegur 
                                         seg_nrcpfcgc
                                         seg_dtnascsg WITH FRAME f_seguro_1.
                             END.
   
                        APPLY LASTKEY.
               
                    END.
               ELSE
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    APPLY LASTKEY.
           END.
      ELSE
           APPLY LASTKEY.
   END.
   PAUSE 0.

   IF   seg_dstipseg = "VIDA" THEN  /* Seguro de Vida  */
        DO:   
            seg_tpseguro = 3.
            RUN
            sistema/generico/procedures/b1wgen0033.p
            PERSISTENT SET h-b1wgen0033.

            RUN validar_inclusao_vida IN h-b1wgen0033
                  (INPUT glb_cdcooper,                          
                   INPUT 0,                                     
                   INPUT 0,                                     
                   INPUT glb_cdoperad,                          
                   INPUT glb_dtmvtolt,                          
                   INPUT tel_nrdconta,                          
                   INPUT 1,                                     
                   INPUT 1,                                     
                   INPUT glb_nmdatela,                          
                   INPUT FALSE,                                 
                   INPUT tt-associado.inpessoa,                 
                   INPUT tt-associado.cdsitdct,                 
                   INPUT seg_dtnascsg,
                   INPUT seg_nmdsegur,
                   OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0033.

            IF RETURN-VALUE <> "OK"  THEN DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF AVAIL tt-erro   THEN DO:
                    NEXT-PROMPT seg_dtnascsg WITH FRAME f_seguro_1.
                    ASSIGN glb_cdcritic = tt-erro.cdcritic
                           glb_dscritic = tt-erro.dscritic.
                    NEXT.
                END.
            END.

            DEF VAR aux_teste AS INT NO-UNDO.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.

               ASSIGN seg_ddvencto = DAY(glb_dtmvtolt).

               DISPLAY seg_nmdsegur WITH FRAME f_seguro_3_i.
               
               UPDATE seg_vlpreseg    tel_vlcapseg    
                      seg_ddvencto    seg_tpplaseg 
                      tel_nmbenefi[1] tel_dsgraupr[1]
                      tel_txpartic[1] tel_nmbenefi[2] tel_dsgraupr[2] 
                      tel_txpartic[2] tel_nmbenefi[3] tel_dsgraupr[3] 
                      tel_txpartic[3] tel_nmbenefi[4] tel_dsgraupr[4] 
                      tel_txpartic[4] tel_nmbenefi[5] tel_dsgraupr[5]
                      tel_txpartic[5] 
                      WITH FRAME f_seguro_3_i
                      
               EDITING:
  
                  READKEY.
                 
                  IF   FRAME-FIELD = "seg_vlpreseg"   OR
                       FRAME-FIELD = "tel_vlcapseg"   THEN
                       IF   LASTKEY =  KEYCODE(".")   THEN
                            APPLY 44.
                       ELSE
                            APPLY LASTKEY.
                  ELSE
                       APPLY LASTKEY.

               END.  /*  Fim do EDITING  */

               PAUSE 0.
               
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    DO:
                        HIDE FRAME f_seguro_3_i.
                        NEXT.
                    END.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   /*   F4 OU FIM   */
                 DO:
                     HIDE FRAME f_seguro_3_i.
                     NEXT.
                 END.
        
        END. /* Fim Seguro VIDA */
   ELSE
   IF   seg_dstipseg = "PRST" THEN  /* Seguro p/emprestimo  */
        DO:   
            seg_tpseguro = 4.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.

               DISPLAY seg_nmdsegur WITH FRAME f_seguro_3.

               UPDATE seg_vlpreseg    tel_vlcapseg    seg_tpplaseg 
                      WITH FRAME f_seguro_3
                      
               EDITING:
  
               READKEY.
    
               IF   FRAME-FIELD = "seg_vlpreseg"   OR
                    FRAME-FIELD = "tel_vlcapseg"   THEN
                    IF   LASTKEY =  KEYCODE(".")   THEN
                         APPLY 44.
                    ELSE
                         APPLY LASTKEY.
               ELSE
                    APPLY LASTKEY.

               END.  /*  Fim do EDITING  */
               PAUSE 0.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    DO:
                        HIDE FRAME f_seguro_3.
                        NEXT.
                    END.
               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   /*   F4 OU FIM   */
                 DO:
                     HIDE FRAME f_seguro_3.
                     NEXT.
                 END.
        END.

   /* inicia processo validacao/criacao*/
   seg_nrctrseg = 0.

   RUN sistema/generico/procedures/b1wgen0033.p
                   PERSISTENT SET h-b1wgen0033.

   RUN buscar_plano_seguro IN h-b1wgen0033
       (INPUT glb_cdcooper,
        INPUT 0,
        INPUT 0,
        INPUT glb_cdoperad,
        INPUT glb_dtmvtolt,
        INPUT tel_nrdconta,
        INPUT 1,
        INPUT 1,
        INPUT glb_nmdatela,
        INPUT FALSE,
        INPUT seg_cdsegura,
        INPUT seg_tpseguro,
        INPUT seg_tpplaseg,
        OUTPUT TABLE tt-plano-seg,
        OUTPUT TABLE tt-erro).

   DELETE PROCEDURE h-b1wgen0033.

   IF   RETURN-VALUE <> "OK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           IF   AVAIL tt-erro   THEN
               DO:
                   ASSIGN glb_cdcritic = tt-erro.cdcritic
                          glb_dscritic = tt-erro.dscritic.
                   HIDE FRAME f_seguro_1   NO-PAUSE.
                   HIDE FRAME f_seguro_3   NO-PAUSE.
                   HIDE FRAME f_seguro_3_i   NO-PAUSE.
                   
                   NEXT.
               END.
       END.

   FIND tt-plano-seg WHERE
        tt-plano-seg.cdcooper = glb_cdcooper  AND
        tt-plano-seg.tpplaseg = seg_tpplaseg  NO-ERROR.
   
   
   IF AVAIL tt-plano-seg THEN
        ASSIGN seg_cdsegura = tt-plano-seg.cdsegura.
   
   IF   seg_tpseguro = 3 OR seg_tpseguro = 4 THEN DO:
       ASSIGN seg_nmcpveic = ""
              seg_nmbenefi = IF seg_tpseguro = 3 THEN
                                 ""
                             ELSE
                                 seg_nmdsegur
              seg_vlbenefi = 0
              seg_dsmarvei = ""
              seg_dstipvei = ""
              seg_nranovei = 0
              seg_nrmodvei = 0 
              seg_nrdplaca = ""
              seg_qtpassag = 0
              seg_dschassi = ""
              seg_ppdbonus = 0
              seg_cdapoant = ""
              seg_nmsegant = ""
              seg_cdcalcul = 0
              seg_vlseguro = IF AVAIL tt-plano-seg then
                                     tt-plano-seg.vlmorada
                             ELSE 0
              seg_vldfranq = 0
              seg_vldcasco = 0
              seg_vlverbae = 0
              seg_vldanmat = 0
              seg_vldanpes = 0
              seg_vldanmor = 0
              seg_vlappmor = 0
              seg_vlappinv = 0
              aux_dtdebito = glb_dtmvtolt
              aux_dtprideb = glb_dtmvtolt
              seg_nrctrato = 0
              seg_dscobext = "" 
              seg_vlcobext = 0.

       /* se for seguro de VIDA definir data das proximas parcelas
          conforme o dia solicitado */
       IF   seg_tpseguro = 3 THEN
       DO:
           /* Se nao for a vista, cacula a data do proximo debito */
           IF   NOT tt-plano-seg.flgunica   AND   seg_qtmaxpar <> 1   THEN
           DO:
                /* calcula a data para o proximo mes */
                 RUN fontes/calcdata.p (INPUT DATE(MONTH(glb_dtmvtolt),
                                                   seg_ddvencto,
                                                   YEAR(glb_dtmvtolt)),
                                        INPUT  1,
                                        INPUT  "M",
                                        INPUT  seg_ddvencto,
                                        OUTPUT aux_dtdebito).
           END.
           ELSE
               ASSIGN aux_dtdebito = DATE(MONTH(glb_dtmvtolt),
                                          DAY(seg_dtpripag),
                                          YEAR(glb_dtmvtolt)).
       END.
   END.
   
   RUN sistema/generico/procedures/b1wgen0033.p 
         PERSISTENT SET h-b1wgen0033.             
   
   RUN validar_criacao IN h-b1wgen0033(INPUT glb_cdcooper,                                                                              
                                       INPUT 0, /*cdagenci*/                                                                            
                                       INPUT 0, /*nrdcaixa*/                                                                            
                                       INPUT glb_cdoperad,                                                                              
                                       INPUT glb_dtmvtolt,                                                                              
                                       INPUT tel_nrdconta,                                                                              
                                       INPUT 1, /*idseqttl*/                                                                            
                                       INPUT 1, /*idorigem*/                                                                            
                                       INPUT glb_nmdatela,                                                                              
                                       INPUT FALSE, /*flgerlog*/                                                                        
                                       INPUT IF AVAIL tt-plano-seg THEN tt-plano-seg.cdsegura
                                             ELSE 0,   
                                       INPUT seg_ddvencto,
                                       INPUT IF   seg_tpseguro = 4 THEN ? 
                                             ELSE seg_dtfimvig, /*dtfimvig*/               
                                       INPUT seg_dtinivig, /*dtiniseg*/                                                                    
                                       INPUT aux_dtprideb,                                                                                   
                                       INPUT CAPS(tel_nmbenefi[1]), /*nmbenvid[1]*/              
                                       INPUT CAPS(tel_nmbenefi[2]), /*nmbenvid[2]*/                                                          
                                       INPUT CAPS(tel_nmbenefi[3]), /*nmbenvid[3]*/                                                          
                                       INPUT CAPS(tel_nmbenefi[4]), /*nmbenvid[4]*/                                                          
                                       INPUT CAPS(tel_nmbenefi[5]), /*nmbenvid[5]*/                                                        
                                       INPUT seg_nrctrseg,                                                                                   
                                       INPUT 0, /*nrdolote*/                                                                                 
                                       INPUT seg_tpplaseg,                                                                                   
                                       INPUT seg_tpseguro,                                                                                   
                                       INPUT tel_txpartic[1],                                                                                                  
                                       INPUT tel_txpartic[2],                                                                                
                                       INPUT tel_txpartic[3],                                                                                
                                       INPUT tel_txpartic[4],                                                                                
                                       INPUT tel_txpartic[5],                                                                                
                                       INPUT seg_vlpreseg,
                                       INPUT tel_vlcapseg,
                                       INPUT 0, /*cdbccxlt*/
                                       INPUT seg_nrcpfcgc,
                                       INPUT CAPS(seg_nmdsegur),
                                       INPUT CAPS(seg_nmcidade),
                                       INPUT seg_nrcepend,
                                       INPUT 0,
                                       INPUT 0, /*nrpagina*/
                                       INPUT seg_dtnascsg,
                                       OUTPUT aux_crawseg,
                                       OUTPUT aux_nmdcampo,
                                       OUTPUT TABLE tt-erro).

   DELETE PROCEDURE h-b1wgen0033. 

   IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF AVAIL tt-erro THEN
              IF tt-erro.cdcritic <> 0 THEN DO:
                  glb_cdcritic = tt-erro.cdcritic.
                  glb_dscritic = tt-erro.dscritic.
              END.
              ELSE
                  glb_dscritic = tt-erro.dscritic.
          ELSE
              ASSIGN glb_cdcritic = 0
                     glb_dscritic = "Nao foi possivel criar o seguro.".

          BELL.

          IF glb_cdcritic = 582 THEN
              ASSIGN glb_dscritic = glb_dscritic + "para proposta de seguro CASA.".

          MESSAGE glb_dscritic.
          glb_cdcritic = 0.
          
          HIDE FRAME f_seguro_1   NO-PAUSE.
          HIDE FRAME f_seguro_3   NO-PAUSE.
          HIDE FRAME f_seguro_3_i NO-PAUSE.
          
          NEXT.
      END.
    ELSE  /* passou por todas as validacoes*/
        DO:
           /*  Confirmacao dos dados  */
           RUN fontes/confirma.p (INPUT "",
                                  OUTPUT aux_confirma).
        
           IF   aux_confirma <> "S"   THEN
                DO:
                    HIDE FRAME f_seguro_1   NO-PAUSE.
                    HIDE FRAME f_seguro_3   NO-PAUSE.
                    HIDE FRAME f_seguro_3_i NO-PAUSE.
                    
                    NEXT.
                END.
    
           HIDE FRAME f_seguro_1    NO-PAUSE.
           HIDE FRAME f_seguro_3    NO-PAUSE.
           HIDE FRAME f_seguro_3_i  NO-PAUSE.
              
           LEAVE.
        END.

END.  /*  Fim do DO WHILE TRUE  */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   /*   F4 OU FIM   */
     DO:
         HIDE FRAME f_seguro_1      NO-PAUSE.
         HIDE FRAME f_seguro_3      NO-PAUSE.
         HIDE FRAME f_seguro_3_i    NO-PAUSE.

         RETURN.
     END.

DO TRANSACTION ON ERROR UNDO, RETURN:

   RUN sistema/generico/procedures/b1wgen0033.p 
         PERSISTENT SET h-b1wgen0033. 

   RUN cria_seguro IN h-b1wgen0033(INPUT glb_cdcooper,
                                   INPUT 0,                                                 /*cdagenci*/
                                   INPUT 0,                                                 /*nrdcaixa*/
                                   INPUT glb_cdoperad,
                                   INPUT glb_dtmvtolt,
                                   INPUT tel_nrdconta,
                                   INPUT 1,                                                 /*idseqttl*/
                                   INPUT 1,                                                 /*idorigem*/
                                   INPUT glb_nmdatela,
                                   INPUT FALSE,                                             /*flgerlog*/
                                   INPUT 0,                                                 /*cdmotcan*/
                                   INPUT IF AVAIL tt-plano-seg THEN tt-plano-seg.cdsegura
                                         ELSE 0,
                                   INPUT 1,                                                 /*cdsitseg*/
                                   INPUT CAPS(tel_dsgraupr[1]),
                                   INPUT CAPS(tel_dsgraupr[2]),
                                   INPUT CAPS(tel_dsgraupr[3]),
                                   INPUT CAPS(tel_dsgraupr[4]),
                                   INPUT CAPS(tel_dsgraupr[5]),
                                   INPUT glb_dtmvtolt,                                      /*dtaltseg*/
                                   INPUT ?,                                                 /*dtcancel*/
                                   INPUT aux_dtdebito,
                                   INPUT IF   seg_tpseguro = 4 THEN ? 
                                         ELSE seg_dtfimvig,                                /*dtfimvig*/
                                   INPUT seg_dtinivig,                                      /*dtiniseg*/
                                   INPUT seg_dtinivig,
                                   INPUT aux_dtprideb,
                                   INPUT ?,                                                 /*dtultalt*/
                                   INPUT glb_dtmvtolt,                                      /*dtultpag*/
                                   INPUT NO,                                                /*flgclabe*/
                                   INPUT NO,                                                /*flgconve*/
                                   INPUT seg_flgunica,
                                   INPUT 0,                                                 /*indebito*/
                                   INPUT "",                                                /*lsctrant*/
                                   INPUT CAPS(tel_nmbenefi[1]),                             /*nmbenvid[1]*/
                                   INPUT CAPS(tel_nmbenefi[2]),                             /*nmbenvid[2]*/
                                   INPUT CAPS(tel_nmbenefi[3]),                             /*nmbenvid[3]*/
                                   INPUT CAPS(tel_nmbenefi[4]),                             /*nmbenvid[4]*/
                                   INPUT CAPS(tel_nmbenefi[5]),                             /*nmbenvid[5]*/ 
                                   INPUT 0,                                                 /*nrctratu*/
                                   INPUT seg_nrctrseg,
                                   INPUT 0,                                                 /*nrdolote*/
                                   INPUT seg_qtparseg,
                                   INPUT 0,                                                 /*qtprepag*/
                                   INPUT 0,                                                 /*qtprevig*/
                                   INPUT 0,                                                 /*tpdpagto*/
                                   INPUT 0,                                                 /*tpendcor*/
                                   INPUT seg_tpplaseg,
                                   INPUT seg_tpseguro,
                                   INPUT tel_txpartic[1],
                                   INPUT tel_txpartic[2],
                                   INPUT tel_txpartic[3],
                                   INPUT tel_txpartic[4],
                                   INPUT tel_txpartic[5],
                                   INPUT seg_vldifseg,
                                   INPUT seg_vltotpre,                                      /*vlpremio*/
                                   INPUT 0,                                                 /*vlprepag*/
                                   INPUT seg_vlpreseg,
                                   INPUT tel_vlcapseg,
                                   INPUT 0,                                                 /*cdbccxlt*/
                                   INPUT seg_nrcpfcgc,
                                   INPUT CAPS(seg_nmdsegur),
                                   INPUT seg_vltotpre,
                                   INPUT seg_cdcalcul,
                                   INPUT seg_vlseguro,
                                   INPUT CAPS(seg_dsendres),
                                   INPUT 0,                                                 /*nrendres*/
                                   INPUT CAPS(seg_nmbairro),
                                   INPUT CAPS(seg_nmcidade),
                                   INPUT seg_cdufresd,
                                   INPUT seg_nrcepend,
                                   INPUT seg_cdsexosg,
                                   INPUT aux_cdempres,
                                   INPUT seg_dtnascsg,
                                   INPUT CAPS(seg_complend),
                                   OUTPUT aux_flgsegur,
                                   OUTPUT aux_crawseg,
                                   OUTPUT TABLE tt-erro).

   DELETE PROCEDURE h-b1wgen0033.

   /*999 nao e considerado um erro pois a b1wgen0033 retorna NOK entao 
     nao deve entrar na condicao abaixo*/
   FIND FIRST tt-erro NO-ERROR.

   IF RETURN-VALUE <> "OK" AND 
      tt-erro.cdcritic <> 999 THEN
       DO:
           FIND FIRST tt-erro NO-ERROR.
           IF AVAIL tt-erro THEN
               ASSIGN glb_cdcritic = tt-erro.cdcritic
                      glb_dscritic = tt-erro.dscritic.
           ELSE
               ASSIGN glb_cdcritic = 0
                      glb_dscritic = "Nao foi possivel criar o seguro.".

           IF glb_cdcritic <> 0 THEN
               RUN fontes/critic.p.

           BELL.
           MESSAGE glb_dscritic.
           glb_cdcritic = 0.

           LEAVE.
       END.

    /*Abaixo e gerado um alerta para seguro de VIDA */
    IF aux_flgsegur = TRUE THEN
       MESSAGE "Atencao! Para a contratacao deste" +
               " plano de seguro, nao ha necessidade do envio da " +
               "DPS - Declaracao Pessoal de Saude." 
               VIEW-AS ALERT-BOX.

END.  /*  Fim da transacao  */

IF seg_tpseguro = 4 OR seg_tpseguro = 3 THEN
   RUN fontes/segvida_m.p (INPUT INTEGER(aux_crawseg),
                           INPUT "I" ). /*cddopcao*/
ELSE                                           
     RUN fontes/seguro_m.p (INPUT INTEGER(aux_crawseg)).
                            


PROCEDURE seguro_casa.

    DEF QUERY q_segura FOR tt-seguradora.
    DEF BROWSE b_segura QUERY q_segura
        DISPLAY tt-seguradora.nmsegura  COLUMN-LABEL "Seguradora"
                WITH 7 DOWN NO-BOX.

    FORM SKIP(1)
         b_segura  HELP "Pressione ENTER para selecionar / F4 para sair"
         WITH OVERLAY CENTERED ROW 8 TITLE ("Escolha a Seguradora (" +
              tel_tpseguro:SCREEN-VALUE IN FRAME f_tipo + ")")  FRAME f_segura.

    ON RETURN OF b_segura DO:

        aux_flgrotin = FALSE.   /* por padaro eh a rotina antiga */

        ASSIGN aux_flgrotin = TRUE  /* p/ o UNIBANCO eh nova rotina */
               /* descricao e codigo do tipo do seguro */
               seg_dstipseg = tel_tpseguro:SCREEN-VALUE IN FRAME f_tipo
               seg_cdtipseg = IF seg_dstipseg = "CASA" 
                                 THEN 11
                                 ELSE 0
               /* codigo e nome da seguradora */
               seg_cdsegura = tt-seguradora.cdsegura
               seg_nmresseg = tt-seguradora.nmsegura.

        { includes/seg_simples.i }
    END.   

    /* lista as seguradoras que tem seguro de casa */

    EMPTY TEMP-TABLE tt-seguradora.

    RUN sistema/generico/procedures/b1wgen0033.p 
        PERSISTENT SET h-b1wgen0033.

    RUN buscar_seguradora IN h-b1wgen0033(INPUT glb_cdcooper,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT glb_cdoperad,
                                          INPUT glb_dtmvtolt,
                                          INPUT tel_nrdconta,
                                          INPUT 1,
                                          INPUT 1,
                                          INPUT glb_nmdatela,
                                          INPUT FALSE,
                                          INPUT 11, /* casa */
                                          INPUT 1, /* ativo */
                                          INPUT 0,
                                          INPUT "",
                                          OUTPUT aux_qtregist,
                                          OUTPUT TABLE tt-seguradora,
                                          OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0033.

    IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF   AVAIL tt-erro   THEN
                DO:
                    MESSAGE tt-erro.dscritic.

                    RETURN "NOK".
                END.
        END.

    OPEN QUERY q_segura FOR EACH tt-seguradora.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE b_segura WITH FRAME f_segura.
       LEAVE.
    END.

    HIDE FRAME f_segura.
    VIEW FRAME f_tipo.

    RETURN "OK".

END PROCEDURE.

PROCEDURE carrega_end_cor:
    DEF INPUT PARAM par_nrctrseg LIKE crawseg.nrctrseg NO-UNDO.

    ASSIGN INPUT FRAME f_seg_simples_end_corr seg_tpendcor.

    CASE seg_tpendcor:
        WHEN 1 THEN DO:
            ASSIGN seg_dsendres_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                     seg_dsendres:SCREEN-VALUE IN FRAME f_seg_simples_mens
                   seg_nrendere_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                     seg_nrendere:SCREEN-VALUE IN FRAME f_seg_simples_mens
                   seg_complend_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                     seg_complend:SCREEN-VALUE IN FRAME f_seg_simples_mens
                   seg_nmbairro_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                     seg_nmbairro:SCREEN-VALUE IN FRAME f_seg_simples_mens
                   seg_nrcepend_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                     seg_nrcepend:SCREEN-VALUE IN FRAME f_seg_simples_mens
                   seg_nmcidade_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                     seg_nmcidade:SCREEN-VALUE IN FRAME f_seg_simples_mens
                   seg_cdufresd_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                     seg_cdufresd:SCREEN-VALUE IN FRAME f_seg_simples_mens.
        END.
        OTHERWISE DO:
            RUN sistema/generico/procedures/b1wgen0033.p 
                PERSISTENT SET h-b1wgen0033.

            RUN busca_end_cor IN h-b1wgen0033(INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT glb_dtmvtolt,
                                              INPUT tel_nrdconta,
                                              INPUT 1,
                                              INPUT 1,
                                              INPUT glb_nmdatela,
                                              INPUT FALSE,
                                              INPUT par_nrctrseg,
                                              INPUT seg_tpendcor,
                                              OUTPUT TABLE tt_end_cor,
                                              OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0033.

            IF RETURN-VALUE <> "OK" THEN
                DO:
                    FIND FIRST tt-erro NO-ERROR.
                    IF AVAIL tt-erro THEN
                        DO:
                            MESSAGE tt-erro.dscritic.
                            RETURN "NOK".
                        END.
                END.
                
            FIND FIRST tt_end_cor.

            IF NOT AVAIL tt_end_cor THEN RETURN "NOK".

            ASSIGN seg_dsendres_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                       tt_end_cor.dsendres
                   seg_nrendere_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                       STRING(tt_end_cor.nrendres)
                   seg_nmbairro_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                       tt_end_cor.nmbairro
                   seg_nrcepend_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                       STRING(tt_end_cor.nrcepend)
                   seg_nmcidade_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                       tt_end_cor.nmcidade
                   seg_cdufresd_2:SCREEN-VALUE IN FRAME f_seg_simples_end_corr =
                       tt_end_cor.cdufresd.
        END.
    END CASE.

    RETURN "OK".
END PROCEDURE.

/* .......................................................................... */


