/* .............................................................................

   Programa: Includes/transfi.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Outubro/91                        Ultima atualizacao: 12/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela TRANSF.

   Alteracoes: 15/09/94 - Alterado para fazer tratamento do arquivo crapdem
                          na rotina de inclusao (Odair).

               20/08/97 - Alterado para nao permitir duplicar ou transferir
                          associados demitidos (Deborah).

               09/11/98 - Tratar situacao em prejuizo (Deborah).
               
               02/07/2000 - Duplicar a conta on_line (Odair)
              
               24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               02/01/2002 - Transferir o valor minimo do capital quando uma 
                            conta for duplicada.
                            
               28/02/2002 - Alimentar crapass.tpavsdeb com 0 (Junior).

               29/10/2003  - Atualizar campo crapsld.dtrefere(Mirtes).

               24/11/2003 - Nao permitir a inclusao do numero de conta 8544-8
                            (Edson).

               09/01/2004 - Atualizar os campos craptrf.cdoperad e 
                            craptrf.hrtransa (Edson).

               14/01/2004 - Nao permitir a transf. de conta de tenha
                            cheques em custodia e desconto de cheques ativos
                            (Edson).

               11/02/2004 - Atualizar os campos crapsld.dtrefere e 
                            crapsld.dtrefext na duplicacao da conta (Edson).

               03/03/2004 - Nao verificar mais se existem cheques Custodia/
                            Desconto de Cheques (Mirtes)
               
               06/04/2004 - Cooperativa 6 - Capital Minimo - Considerar 
                            matricula (qdo menor que tabela)(Mirtes).

               21/09/2004 - Atualiza numero Conta Investimento - Campo
                            crapass.nrctainv(Mirtes).

               07/12/2004 - Tratar conta integracao (Margarete).

               18/04/2005 - Tratar campo cdcooper nas tabelas (Edson).

               02/01/2006 - Passado a usar o lote 8008 (Magui).

               03/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               06/02/2006 - Incluida a criacao da "crapsnh" (Evandro).
               
               23/02/2006 - Modificado o status ATIVO de 0 para 1 e 'idseqttl'
                            recebe 0 (Evandro).
               
               23/05/2006 - Criar crapenc na duplicacao (Magui).

               07/08/2006 - Alterada critica para confirmar operacao (David).
               
               28/03/2007 - Alterado campos de endereco para receberem dados da
                            estrutura crapenc (Elton).
               
               10/04/2007 - Utilizada BO para criacao de endereco na estrutura
                            crapenc (Elton).
                            
               06/09/2007 - Alimentar crapjur.nmextttl da crapass.nmprimttl
                            (Guilherme).

               05/11/2007 - Retirar campo crapass.cddsenha (David).
                          - Alterar nmdsecao(crapass)p/ttl.nmdsecao(Guilherme).

               28/01/2008 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)

               27/08/2008 - Corrigir MESSAGE de critica retornada pela rotina
                            ver_capital (David).

               01/09/2008 - Alteracao cdempres (Kbase IT) - Eduardo Silva.
       
               22/09/2009 - Incluir validacao para a conta salario - crapccs
                            (Fernando).
                            
               31/08/2010 - Removido campo crapass.cdempres (Diego).
               
               28/09/2010 - Nao permitir transferir conta do PAC 5 Creditextil.
                            Motivo: Transferencia de PAC.
                            Necessario remover alteracao em Jan/2011. (Irlan)
                            
               11/11/2010 - Replicar os dados de procuradores tambem p/ pessoas
                            físicas (Vitor).
                            
               01/02/2011 - Retirado restricao do PAC 5 da Acredi. (Irlan)
               
               19/05/2011 - Substituicao do campo crapenc.nranores por 
                            crapenc.dtinires (data que o cooperado passou a
                            residir no endereco informado). Fabricio 
               
               26/04/2012 - Inclusao de tratamento do campo tel_nrsconta
                            que nao poder ser criada contas com numeracao
                            abaixo de 90000.(David Kruger).
                                           
               10/12/2012 - Incluido restricao de contas por pacs migrados da
                            Viacredi para Alto Vale (David Kruger).
                                                
               29/04/2013 - Incluir campo crapttl.cdufnatu no create crapttl
                            (Lucas R.)                 
               
               31/07/2013 - Inclusao de flgimpri para msg na ATENDA (Jean).
               
               13/08/2013 - Incluido restricao de contas por pacs migrados da
                            Acredi para Viacredi (Carlos).
                            
               26/09/2013 - Removidos a gravacao na tabela crapttl dos campos 
                            de endereço: dsendres, nmbairro, nrcepend, nmcidade,
                            mrcxpost, cdufresd e os de telefone: nrdddres e 
                            nrfonres.
                          - Alteradas Strings de PAC para PA
                            (Reinert)
                            
               28/10/2013 - Retirada criaçao automatica da senha, tabela
                             crapsnh. (Oliver - GATI)
                             
               06/12/2013 - Bloqueada opcao de transferencia de conta na
                            Acredicop - Migracao (Tiago).              

               15/05/2014 - Ajuste no CREATE CRAPASS. Colunas cdestcvl e dsestcvl
                            movidas para a tabela crapttl. 
                            (Douglas - Chamado 131253)
                            
               16/06/2014 - (Chamado 117414) - Alteraçao das informaçoes do conjuge da crapttl 
                            para utilizar somente crapcje. (Tiago Castro - RKAM)

               30/07/2014 - Incluido restricao faixa de contas, migrado Concredi
                            (Daniel - Chamado  184333).
                            
               25/08/2014 - Incluido restricao faixa de contas, migrado Credimilsul
                            (Daniel - Chamado  190663).
                            
               30/10/2014 - Incluso bloqueio de criacao de novas contas nas cooperativas
                            Credimilsul e Concredi (Daniel - Chamado - 217482)
                            
               18/11/2014 - Removido bloqueio de criaco de novas contas na
                            SCRCRED com faixa de valores entre 700000 - 730000.
                            (Reinert)                            
                            
              12/08/2015 - Projeto Reformulacao cadastral
                           Eliminado o campo nmdsecao (Tiago Castro - RKAM).

              11/08/2017 - Incluído o número do cpf ou cnpj na tabela crapdoc.
                           Projeto 339 - CRM. (Lombardi)		 

.............................................................................*/

/* Handle para a BO */
DEF      VAR h-b1crapenc           AS HANDLE                         NO-UNDO.
DEF      VAR h-b1craptfc           AS HANDLE                         NO-UNDO.

{ sistema/generico/includes/var_internet.i }
DEF VAR h-b1wgen0001 AS HANDLE                                        NO-UNDO.

DEF TEMP-TABLE cratenc NO-UNDO   LIKE crapenc.

ASSIGN tel_nrdconta = 0   tel_nmprimtl = ""
       tel_nrsconta = 0   tel_nrmatric = 0
       tel_tptransa = 0   tel_dstransa = ""
       tel_sttransa = "".

DISPLAY tel_nmprimtl tel_dstransa tel_sttransa WITH FRAME f_transf.

DO WHILE TRUE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_nrdconta tel_nrsconta tel_nrmatric
             tel_tptransa WITH FRAME f_transf.

      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        LEAVE.

   glb_nrcalcul = tel_nrdconta.

   RUN fontes/digfun.p.
   IF   NOT glb_stsnrcal THEN
        DO:
            glb_cdcritic = 8.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
            NEXT.
         END.

   glb_nrcalcul = tel_nrsconta.
   RUN fontes/digfun.p.
   IF   NOT glb_stsnrcal THEN
        DO:
            glb_cdcritic = 8.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrsconta WITH FRAME f_transf.
            NEXT.
        END.

   IF   tel_nrdconta = tel_nrsconta THEN
        DO:
            glb_cdcritic = 121.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrsconta WITH FRAME f_transf.
            NEXT.
        END.

   IF glb_cdcooper = 1       AND
      tel_nrsconta < 90000   THEN
      DO:
         BELL.
         MESSAGE COLOR WHITE "Nova conta nao permitida. " +
                             "Transferencia de PA!".
         PAUSE.
         NEXT-PROMPT tel_nrsconta WITH FRAME f_transf.
         NEXT.
      END.

    IF  (
        glb_cdcooper = 1           AND
        glb_dtmvtolt <= 12/31/2013 AND
        tel_nrsconta >= 80000000   AND
        tel_nrsconta <  90000000
        )
        OR
        (
        glb_cdcooper = 2           AND
        glb_dtmvtolt <= 12/31/2013 AND
        tel_nrsconta >= 10000000
        )                          THEN
        DO:
            BELL.
            MESSAGE COLOR WHITE "Nova conta nao permitida. " +
                                "Transferencia de PA!".
            PAUSE.
            NEXT-PROMPT tel_nrsconta WITH FRAME f_transf.
            NEXT.
        END.

   IF  (
        glb_cdcooper  = 1 /*Viacredi*/ AND 
        glb_dtmvtolt <= 12/02/2014     AND  
        tel_nrsconta >= 9100000        AND /* Nao criar contas na faixa reservada para migraçao */
        tel_nrsconta <= 9190000
        )
        THEN
        DO:    
            BELL.
            MESSAGE COLOR WHITE "Nova conta nao permitida. " +
                                "Transferencia de Cooperativa!".
            PAUSE.
            NEXT-PROMPT tel_nrsconta WITH FRAME f_transf.
            NEXT.
        END.

    IF  ( /*Concredi*/
        glb_cdcooper  = 4                  AND
        glb_dtmvtolt >= DATE("14/11/2014") )
        THEN
        DO:    
            BELL.
            MESSAGE COLOR WHITE "Operacao Invalida! " +
                                "Incorporacao de Cooperativa!".
            PAUSE.
            NEXT-PROMPT tel_nrsconta WITH FRAME f_transf.
            NEXT.
        END.

    IF  ( /*Credimilsul*/
        glb_cdcooper  = 15                 AND
        glb_dtmvtolt >= DATE("11/11/2014") )
        THEN
        DO:    
            BELL.
            MESSAGE COLOR WHITE "Operacao Invalida! " +
                                "Incorporacao de Cooperativa!".
            PAUSE.
            NEXT-PROMPT tel_nrsconta WITH FRAME f_transf.
            NEXT.
        END.

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                      crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 009.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
            NEXT.
        END.

/*    Irlan: Comentado para ser utilizado nos proximos projetos de transferencia         */
/*    IF   AVAIL crapass THEN                                                            */
/*         DO:                                                                           */
/*             IF  crapass.cdcooper = 2 AND crapass.cdagenci = 5 THEN                    */
/*                 DO:                                                                   */
/*                     BELL.                                                             */
/*                     MESSAGE COLOR WHITE "Opcao nao disponivel. Transferencia de PAC". */
/*                     PAUSE.                                                            */
/*                     NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.                     */
/*                     NEXT.                                                             */
/*                 END.                                                                  */
/*         END.                                                                          */


    IF   AVAIL crapass THEN                                                           
         DO:                                                                          
             IF (crapass.cdcooper = 1  AND 
                 (crapass.cdagenci = 7  OR
                  crapass.cdagenci = 33 OR
                  crapass.cdagenci = 38 OR
                  crapass.cdagenci = 60 OR
                  crapass.cdagenci = 62 OR
                  crapass.cdagenci = 66 )) OR
                 (crapass.cdcooper = 2 AND
                  (crapass.cdagenci = 2 OR
                   crapass.cdagenci = 4 OR
                   crapass.cdagenci = 6 OR
                   crapass.cdagenci = 7 OR
                   crapass.cdagenci = 11)) THEN                   
                 DO:                                                                  
                     BELL.                                                            
                     MESSAGE COLOR WHITE "Opcao nao disponivel. Transferencia de PA".
                     PAUSE.                                                           
                     NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.                    
                     NEXT.                                                            
                 END.                                                                 
         END.                                                                         

   /* Verifica se ja existe o numero da conta como conta salario */
   FIND crapccs WHERE crapccs.cdcooper = glb_cdcooper   AND
                      crapccs.nrdconta = tel_nrdconta
                      NO-LOCK NO-ERROR.
                                         
   IF   AVAILABLE crapccs   THEN
        DO:
           BELL.
           MESSAGE "Conta ja cadastrada para uma conta salario.".
           NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
           NEXT.
        END.
        
   /* Nao permite duplicar ou transferir associados demitidos */

   IF   crapass.dtdemiss <> ? THEN
        DO:
            glb_cdcritic = 075.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
            NEXT.
        END.

   /* Atualizado em 15/09/94  por Odair onde deve
      Nao permitir a duplicacao e transferencia de contas que tenham dtelimin */

   IF   crapass.dtelimin <> ? THEN
        DO:
            glb_cdcritic = 410.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
            NEXT.
        END.

   IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl)) THEN
        DO:
            glb_cdcritic = 695.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrmatric WITH FRAME f_transf.
            NEXT.
        END.

   IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl)) THEN
        DO:
            glb_cdcritic = 95.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrmatric WITH FRAME f_transf.
            NEXT.
        END.

   IF   crapass.nrmatric <> INPUT tel_nrmatric THEN
        DO:
            glb_cdcritic = 048.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrmatric WITH FRAME f_transf.
            NEXT.
        END.

   /* Procura no ass e dem para ver se existe para nao criar outro igual */

   IF   CAN-FIND(crapass WHERE crapass.cdcooper = glb_cdcooper          AND
                               crapass.nrdconta = INPUT tel_nrsconta)   OR
        CAN-FIND(crapdem WHERE crapdem.cdcooper = glb_cdcooper          AND
                               crapdem.nrdconta = INPUT tel_nrsconta)   THEN
        DO:
            glb_cdcritic = 046.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrsconta WITH FRAME f_transf.
            NEXT.
        END.


   /*  Verifica se a conta eh 8544-8  */

   IF   glb_cdcooper <> 2 THEN  /* CCTEXTIL */
        DO:
           IF   INPUT tel_nrsconta = 85448  THEN
                DO:
                   BELL.
                   MESSAGE "Numero de conta NAO permitido.".
                   NEXT-PROMPT tel_nrsconta WITH FRAME f_transf.
                   NEXT.
                END.
        END.

   FIND FIRST craptrf WHERE craptrf.cdcooper = glb_cdcooper       AND
                            craptrf.nrdconta = INPUT tel_nrdconta AND
                            craptrf.tptransa = 1
                            USE-INDEX craptrf1 NO-LOCK NO-ERROR.

   IF   AVAILABLE craptrf THEN
        DO:
            glb_cdcritic = 122.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
            NEXT.
        END.

   FIND craptrf WHERE craptrf.cdcooper = glb_cdcooper        AND
                      craptrf.nrsconta = INPUT tel_nrsconta
                      USE-INDEX craptrf2 NO-LOCK NO-WAIT NO-ERROR.

   IF   AVAILABLE craptrf THEN
        DO:
            glb_cdcritic = 123.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrsconta WITH FRAME f_transf.
            NEXT.
        END.

   /*--------------- Desativado em 03/03/2004
   IF   tel_tptransa = 1   THEN                        /*   Transf. de conta  */
        DO:
            /*  Verifica se tem cheques em custodia  */
   
            FIND FIRST crapcst WHERE crapcst.cdcooper  = glb_cdcooper   AND
                                     crapcst.nrdconta  = tel_nrdconta   AND
                                     crapcst.dtlibera >= glb_dtmvtolt   AND
                                     crapcst.dtdevolu  = ?
                                     NO-LOCK NO-ERROR.
                            
            IF   AVAILABLE crapcst   THEN
                 DO:
                     BELL.
                     MESSAGE "Associado com cheques em custodia"
                             "AINDA nao liberados.".
                     NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
                     NEXT.
                 END.

            /*  Verifica se tem cheques descontados  */
   
            FIND FIRST crapcdb WHERE crapcdb.cdcooper  = glb_cdcooper   AND
                                     crapcdb.nrdconta  = tel_nrdconta   AND
                                     crapcdb.dtlibera >= glb_dtmvtolt   AND
                                     crapcdb.dtdevolu  = ?              
                                     NO-LOCK NO-ERROR.
                            
            IF   AVAILABLE crapcdb   THEN
                 DO:
                     BELL.
                     MESSAGE "Associado com cheques descontados"
                             "AINDA nao liberados.".
                     NEXT-PROMPT tel_nrdconta WITH FRAME f_transf.
                     NEXT.
                 END.
        END.
   -----------------------------*/     
   
   aux_nrsconta = 0.     
   glb_cdcritic = 0.
   
   IF   tel_tptransa = 2 THEN /* DUPLICACAO EXECUTAR ON_LINE */
        DO:
             DO WHILE TRUE:
             
                UPDATE aux_nrsconta WITH FRAME f_verifica.
                                     
                LEAVE.
             END.   
        
             IF   aux_nrsconta <> tel_nrsconta THEN
                  DO:
                         glb_cdcritic = 301.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         NEXT.
                  END.

             /*  Le registro de matricula  */

             FIND FIRST crapmat WHERE crapmat.cdcooper = glb_cdcooper
                                      NO-LOCK NO-ERROR.

             /*  Le tabela de valor minimo do capital  */

             FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                craptab.nmsistem = "CRED"         AND
                                craptab.tptabela = "USUARI"       AND
                                craptab.cdempres = 11             AND
                                craptab.cdacesso = "VLRUNIDCAP"   AND
                                craptab.tpregist = 1
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE craptab   THEN
                  aux_vlcapmin = crapmat.vlcapini.
             ELSE
                  aux_vlcapmin = DECIMAL(craptab.dstextab).
             /*
             IF   aux_vlcapmin < crapmat.vlcapini   THEN
                  IF  glb_cdcooper <> 6 THEN
                      aux_vlcapmin = crapmat.vlcapini.
             */
             RUN sistema/generico/procedures/b1wgen0001.p
                 PERSISTENT SET h-b1wgen0001.
      
             IF   VALID-HANDLE(h-b1wgen0001)   THEN
                  DO:
                      RUN ver_capital IN h-b1wgen0001
                                         (INPUT glb_cdcooper,
                                          INPUT tel_nrdconta,
                                          INPUT 0,            /* cod-agencia */
                                          INPUT 0,            /* nro-caixa   */
                                          INPUT aux_vlcapmin, /* vllanmto    */
                                          INPUT glb_dtmvtolt,
                                          INPUT "TRANSF",
                                          INPUT 1,            /* AYLLOS      */
                                         OUTPUT TABLE tt-erro).
                                         
                      DELETE PROCEDURE h-b1wgen0001.
                      
                      IF   RETURN-VALUE = "NOK"  THEN
                           DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                                IF   AVAILABLE tt-erro   THEN
                                     ASSIGN glb_dscritic = tt-erro.dscritic.
                                ELSE
                                     ASSIGN glb_dscritic = "Erro na rotina " +
                                                           "ver_capital". 
                           
                                BELL.
                                MESSAGE glb_dscritic.
                                NEXT.
                           END.
                  END.
        END.
             
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N".
           /*glb_cdcritic = 78.*/
             
    /*RUN fontes/critic.p.*/
      BELL.
      MESSAGE COLOR NORMAL "Operacao sem volta, deseja confirmar?"
      UPDATE aux_confirma.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 079.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   DO WHILE TRUE TRANSACTION:

      CREATE craptrf.
      ASSIGN craptrf.cdcooper = glb_cdcooper
             craptrf.nrdconta = tel_nrdconta
             craptrf.nrsconta = tel_nrsconta
             craptrf.cdcooper = glb_cdcooper
             craptrf.dttransa = glb_dtmvtolt
             craptrf.insittrs = 1
             craptrf.tptransa = tel_tptransa
             craptrf.cdoperad = glb_cdoperad
             craptrf.hrtransa = TIME.

      IF tel_tptransa = 2 THEN /* DUPLICACAO EXECUTAR ON_LINE */
        DO:
            RUN proc_duplica.
               
            IF glb_cdcritic > 0   THEN
                UNDO, LEAVE.

            RUN proc_registro_documentos(INPUT  glb_cdcooper,
                                         INPUT  tel_nrsconta,
                                         INPUT  glb_dtmvtolt).

            IF glb_cdcritic > 0   THEN
                UNDO, LEAVE.
        END.

      LEAVE.
       
   END. /* Fim da transacao */

   RELEASE craptrf.
   
   CLEAR FRAME f_transf NO-PAUSE.
   
   LEAVE.

END.

/* ......................................................................... */




PROCEDURE proc_duplica: 

    DEF VAR aux_senha       AS CHAR     NO-UNDO.
    DEF VAR aux_cddsenha    AS INT      NO-UNDO.
    DEF VAR aux_contador    AS INT      NO-UNDO.
    DEF VAR aux_tiposdoc    AS INT      NO-UNDO.
    /**/
    
    Contador: DO TRANSACTION ON ENDKEY UNDO Contador, LEAVE Contador
                   ON ERROR  UNDO Contador, LEAVE Contador
                   ON STOP   UNDO Contador, LEAVE Contador:
    
        FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper AND
                           crapttl.nrdconta = tel_nrsconta AND
                           crapttl.idseqttl = 1
                           NO-LOCK NO-ERROR.

        IF NOT AVAILABLE crapttl THEN
            DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Titular nao cadastrado.".
            UNDO Grava, LEAVE Grava.
        END.

        DO aux_contador = 1 TO 10:
        
            FIND FIRST crapdoc WHERE crapdoc.cdcooper = glb_cdcooper AND
                               crapdoc.nrdconta = tel_nrsconta AND
                               crapdoc.dtmvtolt = glb_dtmvtolt AND
                               crapdoc.idseqttl = 1 AND 
                               crapdoc.nrcpfcgc = crapttl.nrcpfcgc
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF NOT AVAILABLE crapdoc THEN
                DO:
                    IF LOCKED(crapdoc) THEN
                        DO:
                            IF aux_contador = 10 THEN
                                DO:
                                    ASSIGN glb_cdcritic = 341.
                                    LEAVE Contador.
                                END.
                            ELSE 
                                DO: 
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                        END.
                    ELSE
                        DO:
                            DO aux_tiposdoc = 1 TO 7:
                                
                                FIND FIRST crapdoc WHERE crapdoc.cdcooper = glb_cdcooper AND
                                                   crapdoc.nrdconta = tel_nrsconta AND
                                                   crapdoc.tpdocmto = aux_tiposdoc AND
                                                   crapdoc.dtmvtolt = glb_dtmvtolt AND
                                                   crapdoc.idseqttl = 1 AND 
                                                   crapdoc.nrcpfcgc = crapttl.nrcpfcgc NO-LOCK NO-ERROR.

                                IF NOT AVAILABLE crapdoc THEN
                                    DO:
                                        CREATE crapdoc.
                                        ASSIGN crapdoc.cdcooper = glb_cdcooper
                                               crapdoc.nrdconta = tel_nrsconta
                                               crapdoc.flgdigit = FALSE
                                               crapdoc.dtmvtolt = glb_dtmvtolt
                                               crapdoc.tpdocmto = aux_tiposdoc
                                               crapdoc.idseqttl = 1
                                               crapdoc.nrcpfcgc = crapttl.nrcpfcgc.
                                    END.
                            END.
                                      
                            LEAVE Contador.
                        END.
                END.
            ELSE
                DO:
                    ASSIGN crapdoc.flgdigit = FALSE
                           crapdoc.dtmvtolt = glb_dtmvtolt.
    
                    LEAVE Contador.
                END.
        END.

        FIND CURRENT crapdoc EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        RELEASE crapdoc.

    END.

    /**/

    INICIO:
            
    FOR EACH craptrf WHERE craptrf.cdcooper = glb_cdcooper AND
                           craptrf.dttransa = glb_dtmvtolt AND
                           craptrf.tptransa = 2            AND
                           craptrf.insittrs = 1            AND
                           craptrf.nrdconta = tel_nrdconta AND
                           craptrf.nrsconta = tel_nrsconta
                           TRANSACTION ON ERROR UNDO INICIO, NEXT INICIO:

        DO WHILE TRUE:

           FIND crabass WHERE crabass.cdcooper = glb_cdcooper AND
                              crabass.nrdconta = craptrf.nrdconta
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
           IF   NOT AVAILABLE crabass THEN
                IF   LOCKED crabass   THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         glb_cdcritic = 9.
                         RUN fontes/critic.p.
                         MESSAGE glb_dscritic + " na duplicacao da conta " +
                                 STRING(craptrf.nrdconta).
                         craptrf.insittrs = 3.
                         NEXT INICIO.
                     END.
           
           LEAVE.

        END.

        FIND crabenc WHERE crabenc.cdcooper = glb_cdcooper       AND
                           crabenc.nrdconta = craptrf.nrdconta   AND
                           crabenc.idseqttl = 1                  AND
                           crabenc.cdseqinc = 1          NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE crabenc   THEN                   
             DO:
                 glb_cdcritic = 9.
                 RUN fontes/critic.p.
                 MESSAGE glb_dscritic + " na duplicacao da conta " +
                         STRING(craptrf.nrdconta).
                 craptrf.insittrs = 3.
                 NEXT INICIO.
             END.

        IF   crabass.inpessoa <> 1   THEN /* FISICA */
             DO:
                 FIND crabjur WHERE crabjur.cdcooper = glb_cdcooper       AND 
                                    crabjur.nrdconta = craptrf.nrdconta   
                                    EXCLUSIVE-LOCK  NO-ERROR.
                 
                 IF   NOT AVAILABLE crabjur   THEN   
                      DO:
                          glb_cdcritic = 9.
                          RUN fontes/critic.p.
                          MESSAGE glb_dscritic + " na duplicacao da conta " +
                                  STRING(craptrf.nrdconta).
                          craptrf.insittrs = 3.
                          NEXT INICIO.
                      END.
                 
                 FIND crabtfc WHERE crabtfc.cdcooper = glb_cdcooper       AND 
                                    crabtfc.nrdconta = craptrf.nrdconta   AND
                                    crabtfc.idseqttl = 1                  AND
                                    crabtfc.cdseqtfc = 1            
                                    EXCLUSIVE-LOCK  NO-ERROR.
             END.
        ELSE
             DO:
                 FIND crabttl WHERE crabttl.cdcooper = glb_cdcooper       AND 
                                    crabttl.nrdconta = craptrf.nrdconta   AND
                                    crabttl.idseqttl = 1
                                    EXCLUSIVE-LOCK  NO-ERROR.
                 IF   NOT AVAILABLE crabttl   THEN   
                      DO:
                          glb_cdcritic = 9.
                          RUN fontes/critic.p.
                          MESSAGE glb_dscritic + " na duplicacao da conta " +
                                  STRING(craptrf.nrdconta).
                          craptrf.insittrs = 3.
                          NEXT INICIO.
                      END.

                 /* se existir um titular para a conta, vamos verificar o estado civil
                    para buscar o conjuge  */
                 IF  (crabttl.cdestcvl <> 1   AND   /* SOLTEIRO */
                      crabttl.cdestcvl <> 5   AND   /* VIUVO */
                      crabttl.cdestcvl <> 6   AND   /* SEPARADO */
                      crabttl.cdestcvl <> 7)  THEN  /* DIVORCIADO */
                     DO:
                        FIND crabcje WHERE crabcje.cdcooper = glb_cdcooper       AND 
                                           crabcje.nrdconta = craptrf.nrdconta   AND
                                           crabcje.idseqttl = 1 
                                           EXCLUSIVE-LOCK  NO-ERROR.

                            IF   NOT AVAILABLE crabcje   THEN   
                                DO:
                                    glb_cdcritic = 9.
                                    RUN fontes/critic.p.
                                    MESSAGE glb_dscritic + " na duplicacao da conta " +
                                            STRING(craptrf.nrdconta).
                                    craptrf.insittrs = 3.
                                    NEXT INICIO.
                                END.
                     END.

             END.

        IF   CAN-FIND(crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                    crapass.nrdconta = craptrf.nrsconta)   OR
             CAN-FIND(FIRST crapenc WHERE crapenc.cdcooper = glb_cdcooper AND
                                    crapenc.nrdconta = craptrf.nrsconta AND
                                    crapenc.idseqttl = 1)               OR
             CAN-FIND(crapcje WHERE crapcje.cdcooper = glb_cdcooper AND
                                    crapcje.nrdconta = craptrf.nrsconta AND
                                    crapcje.idseqttl = 1)   OR
             CAN-FIND(crapsld WHERE crapsld.cdcooper = glb_cdcooper AND
                                    crapsld.nrdconta = craptrf.nrsconta)   OR
             CAN-FIND(crapcot WHERE crapcot.cdcooper = glb_cdcooper AND
                                    crapcot.nrdconta = craptrf.nrsconta)   THEN
             DO:
                 glb_cdcritic = 46.
                 RUN fontes/critic.p.
                 MESSAGE glb_dscritic + " na duplicacao da conta " +
                         STRING(craptrf.nrdconta).
                 craptrf.insittrs = 3.
                 NEXT INICIO.
             END.

        CREATE crapass.

        ASSIGN crapass.cdagenci = crabass.cdagenci
               crapass.nrdconta = craptrf.nrsconta
               crapass.cdcooper = craptrf.cdcooper
               crapass.nrmatric = crabass.nrmatric
               crapass.cdsexotl = crabass.cdsexotl
               crapass.nrcadast = crabass.nrcadast
               crapass.nmprimtl = crabass.nmprimtl
               crapass.dtnasctl = crabass.dtnasctl
               crapass.dsnacion = crabass.dsnacion
               crapass.dsproftl = crabass.dsproftl
               crapass.dtadmiss = crabass.dtadmiss
               crapass.dtdemiss = crabass.dtdemiss
               crapass.nrcpfcgc = crabass.nrcpfcgc
               crapass.cdsitdtl = crabass.cdsitdtl
               crapass.inpessoa = crabass.inpessoa
               crapass.tpdocptl = crabass.tpdocptl
               crapass.nrdocptl = crabass.nrdocptl
               crapass.cdoedptl = crabass.cdoedptl
               crapass.cdufdptl = crabass.cdufdptl
               crapass.dtemdptl = crabass.dtemdptl
               crapass.nmpaiptl = crabass.nmpaiptl
               crapass.nmmaeptl = crabass.nmmaeptl
               crapass.dsfiliac = crabass.dsfiliac
               crapass.indnivel = 1
               crapass.inmatric = 2
               crapass.tpavsdeb = 0.
        
        /*** Cadastro de endereco do cooperado **/
        EMPTY TEMP-TABLE cratenc.
        
        CREATE cratenc.
        ASSIGN cratenc.cdcooper = craptrf.cdcooper
               cratenc.nrdconta = crapass.nrdconta
               cratenc.idseqttl = 1
               cratenc.cdseqinc = 1
               cratenc.tpendass = crabenc.tpendass
               cratenc.dsendere = crabenc.dsendere
               cratenc.nrendere = crabenc.nrendere
               cratenc.complend = crabenc.complend
               cratenc.nmbairro = crabenc.nmbairro
               cratenc.nmcidade = crabenc.nmcidade
               cratenc.cdufende = crabenc.cdufende
               cratenc.nrcepend = crabenc.nrcepend
               cratenc.incasprp = crabenc.incasprp
               cratenc.dtinires = crabenc.dtinires
               cratenc.vlalugue = crabenc.vlalugue
               cratenc.nrcxapst = crabenc.nrcxapst.
 
        
        /* Instancia a BO para executar as procedures */
           RUN sistema/generico/procedures/b1crapenc.p 
               PERSISTENT SET h-b1crapenc.
    
           /* Se BO foi instanciada */
           IF   VALID-HANDLE(h-b1crapenc)   THEN
                DO:
                    RUN inclui-registro IN h-b1crapenc
                             (INPUT TABLE cratenc, OUTPUT glb_dscritic).
                                             
                    /* Mata a instancia da BO */
                    DELETE PROCEDURE h-b1crapenc.
                END.
           
           IF   glb_dscritic <> ""   THEN
                DO:
                    MESSAGE glb_dscritic.
                    glb_dscritic = "".
                    RETURN "NOK".
                END.

        /*** Procuradores ***/
        FOR EACH crabavt WHERE crabavt.cdcooper = glb_cdcooper   AND
                               crabavt.tpctrato = 6 /*procurad*/ AND
                               crabavt.nrdconta = crabass.nrdconta   
                               EXCLUSIVE-LOCK:
            CREATE crapavt.
            ASSIGN crapavt.nrdconta    = crapass.nrdconta
                   crapavt.nrctremp    = crabavt.nrctremp
                   crapavt.nrcpfcgc    = crabavt.nrcpfcgc
                   crapavt.nmdavali    = crabavt.nmdavali
                   crapavt.nrcpfcjg    = crabavt.nrcpfcjg
                   crapavt.nmconjug    = crabavt.nmconjug
                   crapavt.tpdoccjg    = crabavt.tpdoccjg
                   crapavt.nrdoccjg    = crabavt.nrdoccjg
                   crapavt.tpdocava    = crabavt.tpdocava
                   crapavt.nrdocava    = crabavt.nrdocava
                   crapavt.dsendres[1] = crabavt.dsendres[1]
                   crapavt.dsendres[2] = crabavt.dsendres[2]
                   crapavt.nrfonres    = crabavt.nrfonres
                   crapavt.dsdemail    = crabavt.dsdemail
                   crapavt.tpctrato    = crabavt.tpctrato
                   crapavt.nrcepend    = crabavt.nrcepend
                   crapavt.nmcidade    = crabavt.nmcidade
                   crapavt.cdufresd    = crabavt.cdufresd
                   crapavt.dtmvtolt    = crabavt.dtmvtolt
                   crapavt.cdcooper    = crabavt.cdcooper
                   crapavt.dsnacion    = crabavt.dsnacion
                   crapavt.nrendere    = crabavt.nrendere
                   crapavt.complend    = crabavt.complend
                   crapavt.nmbairro    = crabavt.nmbairro
                   crapavt.nrcxapst    = crabavt.nrcxapst
                   crapavt.nrtelefo    = crabavt.nrtelefo
                   crapavt.nmextemp    = crabavt.nmextemp
                   crapavt.cddbanco    = crabavt.cddbanco
                   crapavt.cdagenci    = crabavt.cdagenci
                   crapavt.dsproftl    = crabavt.dsproftl
                   crapavt.nrdctato    = crabavt.nrdctato
                   crapavt.cdoeddoc    = crabavt.cdoeddoc
                   crapavt.dtemddoc    = crabavt.dtemddoc
                   crapavt.cdufddoc    = crabavt.cdufddoc
                   crapavt.dtvalida    = crabavt.dtvalida
                   crapavt.nmmaecto    = crabavt.nmmaecto
                   crapavt.nmpaicto    = crabavt.nmpaicto
                   crapavt.dtnascto    = crabavt.dtnascto
                   crapavt.dsnatura    = crabavt.dsnatura
                   crapavt.cdsexcto    = crabavt.cdsexcto
                   crapavt.cdestcvl    = crabavt.cdestcvl
                   crapavt.flgimpri    = TRUE.
        END. 
 
        /*** Criando o primeiro titular da conta ***/
        IF   crapass.inpessoa = 1     THEN /* FISICA */
             DO:         
                 CREATE crapttl.
                 ASSIGN crapttl.nrdconta = crapass.nrdconta
                        crapttl.cdcooper = craptrf.cdcooper
                        crapttl.idseqttl = 1
                        crapttl.nmextttl = crapass.nmprimtl
                        crapttl.inpessoa = crapass.inpessoa
                        crapttl.nrcpfcgc = crapass.nrcpfcgc
                        crapttl.dsnacion = crapass.dsnacion 
                        crapttl.dtnasttl = crapass.dtnasctl
                        crapttl.cdsexotl = crabttl.cdsexotl
                        crapttl.cdgraupr = 0
                        crapttl.cdestcvl = crabttl.cdestcvl
                        crapttl.cdempres = crabttl.cdempres   
                        crapttl.dsproftl = crapass.dsproftl
                        crapttl.tpdocttl = crabttl.tpdocttl
                        crapttl.nrdocttl = crabttl.nrdocttl
                        crapttl.cdoedttl = crabttl.cdoedttl
                        crapttl.cdufdttl = crabttl.cdufdttl
                        crapttl.dtemdttl = crabttl.dtemdttl
                        crapttl.nmmaettl = crabttl.nmmaettl
                        crapttl.nmpaittl = crabttl.nmpaittl
                        crapttl.dsnatura = crabttl.dsnatura
                        crapttl.cdufnatu = crabttl.cdufnatu
                        crapttl.tpnacion = crabttl.tpnacion
                        crapttl.cdocpttl = crabttl.cdocpttl                        
                        crapttl.flgimpri = TRUE.
       
                 /*** Se cooperado tiver conjuge ***/
                 IF   AVAILABLE crabcje   THEN 
                      DO:
                          CREATE crapcje.
                          ASSIGN crapcje.cdcooper = glb_cdcooper
                                 crapcje.nrdconta = crapass.nrdconta
                                 crapcje.idseqttl = 1
                                 crapcje.nmconjug = crabcje.nmconjug
                                 crapcje.nrcpfcjg = crabcje.nrcpfcjg
                                 crapcje.dtnasccj = crabcje.dtnasccj
                                 crapcje.tpdoccje = crabcje.tpdoccje
                                 crapcje.nrdoccje = crabcje.nrdoccje
                                 crapcje.cdoedcje = crabcje.cdoedcje
                                 crapcje.cdufdcje = crabcje.cdufdcje
                                 crapcje.dtemdcje = crabcje.dtemdcje
                                 crapcje.grescola = crabcje.grescola
                                 crapcje.cdfrmttl = crabcje.cdfrmttl
                                 crapcje.cdnatopc = crabcje.cdnatopc
                                 crapcje.cdocpcje = crabcje.cdocpcje
                                 crapcje.tpcttrab = crabcje.tpcttrab
                                 crapcje.nmextemp = crabcje.nmextemp
                                 crapcje.dsproftl = crabcje.dsproftl
                                 crapcje.cdnvlcgo = crabcje.cdnvlcgo
                                 crapcje.nrfonemp = crabcje.nrfonemp
                                 crapcje.nrramemp = crabcje.nrramemp
                                 crapcje.cdturnos = crabcje.cdturnos
                                 crapcje.dtadmemp = crabcje.dtadmemp
                                 crapcje.vlsalari = crabcje.vlsalari
                                 crapcje.nrdocnpj = crabcje.nrdocnpj.
                      END.

                 RUN fontes/abreviar.p (INPUT crapttl.nmextttl, INPUT 25,
                                        OUTPUT crapttl.nmtalttl).
             END.
        ELSE
             DO: /* JURIDICAS E ADMINISTRATIVAS */ 
                 CREATE crapjur.
                 ASSIGN crapjur.cdcooper = crabjur.cdcooper
                        crapjur.nrdconta = crapass.nrdconta
                        crapjur.nmfansia = crabjur.nmfansia
                        crapjur.nmextttl = crapass.nmprimtl
                        crapjur.nrinsest = crabjur.nrinsest
                        crapjur.natjurid = crabjur.natjurid
                        crapjur.dtiniatv = crabjur.dtiniatv
                        crapjur.qtfilial = crabjur.qtfilial
                        crapjur.qtfuncio = crabjur.qtfuncio
                        crapjur.nmtalttl = crabjur.nmtalttl
                        crapjur.vlcapsoc = crabjur.vlcapsoc
                        crapjur.vlcaprea = crabjur.vlcaprea
                        crapjur.dtregemp = crabjur.dtregemp
                        crapjur.nrregemp = crabjur.nrregemp
                        crapjur.orregemp = crabjur.orregemp
                        crapjur.dtinsnum = crabjur.dtinsnum
                        crapjur.nrcdnire = crabjur.nrcdnire
                        crapjur.flgrefis = crabjur.flgrefis
                        crapjur.dsendweb = crabjur.dsendweb
                        crapjur.nrinsmun = crabjur.nrinsmun
                        crapjur.cdseteco = crabjur.cdseteco
                        crapjur.vlfatano = crabjur.vlfatano
                        crapjur.cdmodali = crabjur.cdmodali
                        crapjur.cdrmativ = crabjur.cdrmativ
                        crapjur.cdempres = crabjur.cdempres.
                      
                 CREATE craptfc.
                 ASSIGN craptfc.cdcooper = glb_cdcooper
                        craptfc.nrdconta = crapass.nrdconta
                        craptfc.idseqttl = 1
                        craptfc.cdseqtfc = 1
                        craptfc.cdopetfn = 0
                        craptfc.nmpescto = ""
                        craptfc.nrdddtfc = IF AVAILABLE crabtfc THEN
                                              crabtfc.nrdddtfc ELSE 0
                        craptfc.nrtelefo = IF AVAILABLE crabtfc THEN
                                              crabtfc.nrtelefo ELSE 0
                        craptfc.nrdramal = 0
                        craptfc.prgqfalt = "A"  /* AYLLOS */
                        craptfc.tptelefo = 3    /* COMERCIAL */
                        craptfc.secpscto = "".

             END.
             
         /*** Cria Conta de Investimento ***/
        ASSIGN aux_nrdconta = crapass.nrdconta
               glb_nrcalcul = 600000000 + aux_nrdconta
               aux_calculo  = 0 
               aux_peso     = 9.
    
        DO  aux_posicao = (LENGTH(STRING(glb_nrcalcul)) - 1) TO 1 BY -1:
            aux_calculo = aux_calculo + (INT(SUBSTR(STRING(glb_nrcalcul),
                                         aux_posicao,1)) * aux_peso).
            aux_peso = aux_peso - 1.
            IF   aux_peso = 1   THEN
                 aux_peso = 9.
        END.  /*  Fim do DO .. TO  */

        aux_resto = aux_calculo MODULO 11.

        IF   aux_resto > 9   THEN
             aux_digito = 0.
        ELSE
             aux_digito = aux_resto.

        ASSIGN aux_numero = STRING(glb_nrcalcul,"999999999").
        ASSIGN aux_numero = SUBSTR(aux_numero,1,8) + STRING(aux_digito,"9").
        ASSIGN glb_nrcalcul = INTE(aux_numero).

        ASSIGN crapass.nrctainv = glb_nrcalcul.
        /*----------------------------------*/
   
            
        DO WHILE TRUE:                

              aux_senha = "".

              DO aux_contador = 1 TO 6:

                 aux_cddsenha = RANDOM(0,9).

                 aux_senha = aux_senha + STRING(aux_cddsenha,"9").

              END.

              IF   aux_senha <> "000000" THEN
                   LEAVE.
        END.

        CREATE crapsld.

        ASSIGN crapsld.dtrefere = glb_dtmvtoan  
               crapsld.nrdconta = craptrf.nrsconta
               crapsld.cdcooper = craptrf.cdcooper
               crapsld.qtddsdev = 0
               crapsld.dtdsdclq = ?
               
               crapsld.dtrefere = glb_dtmvtoan
               crapsld.dtrefext = glb_dtmvtolt - DAY(glb_dtmvtolt).

        CREATE crapcot.

        ASSIGN crapcot.nrdconta = craptrf.nrsconta
               crapcot.cdcooper = craptrf.cdcooper
               craptrf.insittrs = 2.

        CREATE crapsda.
        
        ASSIGN crapsda.dtmvtolt = glb_dtmvtoan
               crapsda.nrdconta = crapass.nrdconta
               crapsda.cdcooper = crapass.cdcooper.
               
        RUN proc_transf_cotas.

        IF   glb_cdcritic > 0   THEN
             DO:
                 RUN fontes/critic.p.
                 MESSAGE glb_dscritic glb_dscricpl.
                 UNDO INICIO, RETURN.
             END.
    END.  /*  Fim do FOR EACH e da TRANSACAO  */

    MESSAGE "Conta duplicada".



END PROCEDURE.

PROCEDURE proc_transf_cotas:

    glb_cdcritic = 0.

    DO WHILE TRUE:
    
       /*FIND crabcot OF crabass NO-ERROR.*/
       FIND crabcot WHERE crabcot.cdcooper = glb_cdcooper AND
                          crabcot.nrdconta = crabass.nrdconta
                          EXCLUSIVE-LOCK NO-ERROR.

       IF   NOT AVAILABLE crabcot   THEN
            IF   LOCKED crabcot   THEN
                 DO:
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 169.
                     RETURN.
                 END.

       LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */
    /*** Magui nao e mais necessario esta dentro do ver_capital
    IF  (crabcot.vldcotas - aux_vlcapmin) < aux_vlcapmin   THEN
         DO:
             message "Magui dentro 630" crabcot.nrdconta 
                     crabcot.vldcotas aux_vlcapmin.
             pause.
             glb_cdcritic = 630.
             RETURN.
         END.
    ***************************/
    DO WHILE TRUE:

       FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                          craplot.dtmvtolt = glb_dtmvtolt   AND
                          craplot.cdagenci = 1              AND
                          craplot.cdbccxlt = 100            AND
                          craplot.nrdolote = 8008
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craplot   THEN
            IF   LOCKED craplot   THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     CREATE craplot.

                     ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                            craplot.cdagenci = 1
                            craplot.cdbccxlt = 100
                            craplot.nrdolote = 8008
                            craplot.tplotmov = 2
                            craplot.cdcooper = glb_cdcooper.

                     LEAVE.
                 END.

       IF   craplot.tplotmov <> 2   THEN
            DO:
                glb_cdcritic = 62.
                RETURN.
            END.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    CREATE craplct.

    ASSIGN craplct.cdcooper = craplot.cdcooper
           craplct.dtmvtolt = craplot.dtmvtolt
           craplct.cdagenci = craplot.cdagenci
           craplct.cdbccxlt = craplot.cdbccxlt
           craplct.nrdolote = craplot.nrdolote
           craplct.nrdconta = craptrf.nrdconta
           craplct.nrdocmto = craplot.nrseqdig + 1
           craplct.cdhistor = 86
           craplct.nrseqdig = craplot.nrseqdig + 1
           craplct.vllanmto = aux_vlcapmin
           craplct.nrctrpla = 0
           craplct.qtlanmfx = 0

           crabcot.vldcotas = crabcot.vldcotas - craplct.vllanmto

           craplot.vlinfodb = craplot.vlinfodb + craplct.vllanmto
           craplot.vlcompdb = craplot.vlcompdb + craplct.vllanmto.

    CREATE craplct.

    ASSIGN craplct.cdcooper = craplot.cdcooper
           craplct.dtmvtolt = craplot.dtmvtolt
           craplct.cdagenci = craplot.cdagenci
           craplct.cdbccxlt = craplot.cdbccxlt
           craplct.nrdolote = craplot.nrdolote
           craplct.nrdconta = craptrf.nrsconta
           craplct.nrdocmto = craplot.nrseqdig + 2
           craplct.cdhistor = 67
           craplct.nrseqdig = craplot.nrseqdig + 2
           craplct.vllanmto = aux_vlcapmin
           craplct.nrctrpla = 0
           craplct.qtlanmfx = 0

           crapcot.vldcotas = crapcot.vldcotas + craplct.vllanmto

           craplot.nrseqdig = craplot.nrseqdig + 2
           craplot.qtinfoln = craplot.qtinfoln + 2
           craplot.qtcompln = craplot.qtcompln + 2

           craplot.vlinfocr = craplot.vlinfocr + craplct.vllanmto
           craplot.vlcompcr = craplot.vlcompcr + craplct.vllanmto.

END PROCEDURE.

PROCEDURE proc_registro_documentos:

    DEF INPUT   PARAM par_cdcooper  AS INT      NO-UNDO.
    DEF INPUT   PARAM par_nrdconta  AS INT      NO-UNDO.
    DEF INPUT   PARAM par_dtmvtolt  AS DATE     NO-UNDO.
    
    DEF VAR aux_contador AS INT NO-UNDO.

    glb_cdcritic = 0.

    FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                       crapttl.nrdconta = par_nrdconta AND
                       crapttl.idseqttl = 1
                       NO-LOCK NO-ERROR.

    IF NOT AVAILABLE crapttl THEN
        DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Titular nao cadastrado.".
        UNDO Grava, LEAVE Grava.
    END.
    
    DO aux_contador = 1 TO 10:
        
        FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                           crapdoc.nrdconta = par_nrdconta AND
                           crapdoc.tpdocmto = 1            AND
                           crapdoc.dtmvtolt = par_dtmvtolt AND
                           crapdoc.idseqttl = 1 AND 
                           crapdoc.nrcpfcgc = crapttl.nrcpfcgc
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
        IF NOT AVAILABLE crapdoc THEN
            DO:
                IF LOCKED(crapdoc) THEN
                    DO:
                        IF aux_contador = 10 THEN
                            DO:
                                glb_cdcritic = 341.
                            END.
                        ELSE 
                            DO: 
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                    END.
                ELSE
                    DO:
                        DO aux_contador = 1 TO 7:
                            
                            FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                               crapdoc.nrdconta = par_nrdconta AND
                                               crapdoc.tpdocmto = aux_contador AND
                                               crapdoc.dtmvtolt = par_dtmvtolt AND
                                               crapdoc.idseqttl = 1 AND 
                                               crapdoc.nrcpfcgc = crapttl.nrcpfcgc NO-LOCK NO-ERROR.

                            IF NOT AVAILABLE crapdoc THEN
                                DO:
                                    CREATE crapdoc.
                                    ASSIGN crapdoc.cdcooper = par_cdcooper
                                           crapdoc.nrdconta = par_nrdconta
                                           crapdoc.flgdigit = FALSE
                                           crapdoc.dtmvtolt = par_dtmvtolt
                                           crapdoc.tpdocmto = aux_contador
                                           crapdoc.idseqttl = 1
                                           crapdoc.nrcpfcgc = crapttl.nrcpfcgc.
                                END.
                        END.
                        LEAVE.
                    END.
            END.
        ELSE
            DO:
                ASSIGN crapdoc.flgdigit = FALSE
                       crapdoc.dtmvtolt = par_dtmvtolt.
                LEAVE.
            END. 
            
        /*FICHA CADASTRAL*/
    
        FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                           crapdoc.nrdconta = par_nrdconta AND
                           crapdoc.tpdocmto = 7            AND
                           crapdoc.dtmvtolt = par_dtmvtolt AND
                           crapdoc.idseqttl = 1            AND
                           crapdoc.nrcpfcgc = crapttl.nrcpfcgc
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
        IF NOT AVAILABLE crapdoc THEN
            DO:
                IF LOCKED(crapdoc) THEN
                    DO:
                        IF aux_contador = 10 THEN
                            DO:
                                glb_cdcritic = 341.
                            END.
                        ELSE 
                            DO: 
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                    END.
                ELSE
                    DO:
                        DO aux_contador = 1 TO 7:
                            FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                               crapdoc.nrdconta = par_nrdconta AND
                                               crapdoc.tpdocmto = aux_contador AND
                                               crapdoc.dtmvtolt = par_dtmvtolt AND
                                               crapdoc.idseqttl = 1            AND
                                               crapdoc.nrcpfcgc = crapttl.nrcpfcgc NO-LOCK NO-ERROR.

                            IF NOT AVAILABLE crapdoc THEN
                                DO:
                                    CREATE crapdoc.
                                    ASSIGN crapdoc.cdcooper = par_cdcooper
                                           crapdoc.nrdconta = par_nrdconta
                                           crapdoc.flgdigit = FALSE
                                           crapdoc.dtmvtolt = par_dtmvtolt
                                           crapdoc.tpdocmto = aux_contador
                                           crapdoc.idseqttl = 1
                                           crapdoc.nrcpfcgc = crapttl.nrcpfcgc.
                                END.
                        END.
                        LEAVE.
                    END.
            END.
        ELSE
            DO:
                ASSIGN crapdoc.flgdigit = FALSE
                       crapdoc.dtmvtolt = par_dtmvtolt.
                LEAVE.
            END.

    END.

    RETURN "OK".

END PROCEDURE.
/* .......................................................................... */





