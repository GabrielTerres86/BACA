
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +--------------------------------+------------------------------------------+
  | Rotina Progress                | Rotina Oracle PLSQL                      |
  +--------------------------------+------------------------------------------+
  | forma-grupo-economico          | geco0001.pc_forma_grupo_economico        |
  | log-simula-perc                | geco0001.pc_log_simula_perc              |
  | monta_arvore                   | geco0001.pc_monta_arvore                 |
  | mesclar_grupos                 | geco0001.pc_mesclar_grupos               |
  | calc_endivid_risco_grupo       | geco0001.pc_calc_endivid_risco_grupo     |
  | calc_endividamento_individual  | geco0001.pc_calc_endividamento_individual| 
  | calc_risco_individual          | geco0001.pc_calc_risco_individual        |
  | busca_grupo                    | GECO0001.pc_busca_grupo_associado        |
  +--------------------------------+------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/








/*.............................................................................

    Programa  : sistema/generico/procedures/b1wgen0138.p
    Autor     : Guilherme
    Data      : Maio/2012                   Ultima Atualizacao: 05/03/2014
    
    Dados referentes ao programa:

    Objetivo  : BO para controle do Grupo Economico
    
   +-----------idseqttl-----------+ _
   |999 formadora do grupo        |  } Estes aqui sao tipos de inclusao
   |998 proprietarios/procuradores|  } no grupo e ligacoes (vinculos) dos
   |997 empresas proprietarias    |  } integrantes ente si. (idseqttl nrcpfcgc 
   |996 resp. legal               | _} nrctasoc sao campos ref. a mesma pessoa)
   |  1 primeiro titular          |
   |  2 segunto titular           |
   |  3 terceiro titular          |
   +------------------------------+

    Alteracoes: 15/06/2012 - Inclusão de log para tela simula (Lucas R.).
    
                04/07/2012 - Tratamento do cdoperad "operador" de INTE para CHAR.
                             (Lucas R.)
                             
                07/08/2012 - Mostrar os grupos de forma diferente para melhor
                             entendimento da area de negocios (Guilherme)
                             
                11/10/2012 - Ajustes Projeto GE:
                             > Incluido a passagem de um novo parametro na 
                               chamada da procedure saldo_utiliza
                             > Incluido a passagem de um novo parametro na 
                               procedure calc_risco_individual
                             > Criado a procedure calc_endividamento_individual
                               para realizar somente o calculo de endividamento.
                               Na procedure calc_endividamento_individual sera
                               realizado apenas o calculo do risco individual
                               (Adriano).
                               
                28/03/2013 - Ajustes realizados:
                             - Incluido o parametro cdprogra nas procedures
                               forma_grupo_economico, calc_endivid_risco_grupo;
                             - Na procedure calc_risco_individual, se o inindris
                               for igual a 0 sera usado o innivris;
                             - Dentro da calc_endivid_risco_grup na chamada da
                               procedure calc_risco_individual, sera passado
                               dtmvtolt quando cdprogra for "crps634" se nao,
                               sera passado dtultdma
                             (Adriano).

                05/04/2013 - Ajuste realizado:
                             - Dentro da calc_endivid_risco_grup na chamada da
                               procedure calc_risco_individual, sera passado
                               dtmvtolt quando cdprogra for "crps634",
                               dtultdma quando "crps641" se nao, sera passado 
                               dtultdia (Adriano). 

                18/04/2013 - Ajustes realizados:
                              - Alimentado o campo crapgrp.dtrefere com a
                                crapris.dtrefere;
                              - Alimentado o campo crapgrp.dtmvtolt com a
                                data atual;
                              - No CREATE do "preposto com percentual 
                                societario" foi buscado a conta do mesmo
                                e alimentado os campos nrdconta, nrcpfcgc,
                                cdagenci com os respectivos campos da leitura
                                na b-crapass1;
                              - Incluido empty temp-table da tabela tt-grupo
                                na procedure calc_endivid_grupo (Adriano).

                29/04/2013 - Ajuste na procedure calc_risco_individual para
                             considerar o ultimo risco maior que o valor de 
                             arrasto (Adriano).

                09/05/2013 - Desprezado rep/procurador emancipado e que nao
                             tenha conta na cooperativa (Adriano).

                04/06/2013 - Ajustes realizados:
                             - Ajuste no "FIND LAST crapris" da procedure 
                               calc_risco_individual;
                             - Ajuste nas procedures forma_grupo_economico,
                               monta_arvore para desprezar as contas que 
                               estejam eliminadas (dtelimin <> ?); 
                             - Ajuste na procedure forma_grupo_economico para
                               nao criar grupo com apenas um participante e
                               para desprezar contas que tenham registro na
                               crapttl e nao tenham na crapass;
                               (Adriano).

                25/06/2013 - RATING BNDES (Guilherme/Supero)
                
                18/11/2013 - Passando instrucoes de leitura e gravacao de dados
                             da tela verige p/ BO p/ conversão web. Criacao da
                             procedure relatorio_gp (Carlos)
                             
                05/03/2014 - Incluso VALIDATE (Daniel). 
                             
.............................................................................*/


/*........................... DEFINICOES GLOBAIS ............................*/

{ sistema/generico/includes/b1wgen0138tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1.

DEF VAR aux_cdcritic  AS INTE                                          NO-UNDO.
DEF VAR aux_dscritic  AS CHAR                                          NO-UNDO.


DEF BUFFER b-tt-grupo  FOR tt-grupo.
DEF BUFFER b2-tt-grupo FOR tt-grupo.

DEF VAR aux_limpagrp AS LOGICAL INIT TRUE NO-UNDO.


DEFINE VARIABLE aux_dsdrisco AS CHARACTER INIT "AA,A,B,C,D,E,F,G,H,HH" NO-UNDO.


FORM tt-grupo.cdagenci COLUMN-LABEL "PA"    
     tt-grupo.nrdgrupo COLUMN-LABEL "Grupo"
     tt-grupo.nrctasoc COLUMN-LABEL "Conta"
     tt-grupo.nrcpfcgc COLUMN-LABEL "CNPJ/CPF"
     tt-grupo.vlendivi COLUMN-LABEL "Endividamento" FORMAT "zzz,zzz,zzz,zz9.99" 
     tt-grupo.dsdrisco COLUMN-LABEL "Risco"  
     tt-grupo.vlendigp COLUMN-LABEL "Endividamento do Grupo" 
                                    FORMAT "zzz,zzz,zzz,zz9.99"
     tt-grupo.dsdrisgp COLUMN-LABEL "Risco do Grupo"
     WITH DOWN WIDTH 132 NO-BOX FRAME f_grupo_3.



FUNCTION busca_grupo RETURNS LOGICAL(INPUT par_cdcooper  AS INT,
                                     INPUT par_nrdconta  AS INT,
                                     OUTPUT par_nrdgrupo AS INT,
                                     OUTPUT par_gergrupo AS CHAR,
                                     OUTPUT par_dsdrisgp AS CHAR)
                                     FORWARD.


/*****************************************************************************/
/**  Procedure que controla a formacao do grupo economico                   **/
/*****************************************************************************/
PROCEDURE forma_grupo_economico:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdprogra AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_persocio AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_consider AS LOGICAL     NO-UNDO.

    DEFINE OUTPUT PARAMETER TABLE FOR tt-grupo. 
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_nrdgrupo AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrultgrp AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrdeanos AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrdmeses AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_dsdidade AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_dtrefere AS DATE        NO-UNDO.
    DEFINE VARIABLE aux_innivris AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_vlendivi AS DECIMAL     NO-UNDO.

    DEFINE VARIABLE aux_nrdconta AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrctasoc AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrcpfcgc AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_inpessoa AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_cdagenci AS INTEGER     NO-UNDO.

    DEFINE VARIABLE flg_continue AS LOGICAL     NO-UNDO.

    DEFINE VARIABLE opt_vlendivi AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE opt_innivris AS INTEGER     NO-UNDO.
    DEFINE VARIABLE opt_dsdrisco AS CHARACTER   NO-UNDO.


    DEFINE BUFFER crabass FOR crapass.   /* contas do resp. legal */
    DEFINE BUFFER b-crapass1 FOR crapass.
    DEFINE BUFFER b-gncdntj1 FOR gncdntj.
    DEFINE BUFFER b-crapjur1 FOR crapjur. 

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-grupo.         
    EMPTY TEMP-TABLE tt-dados-grupo.   

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  AVAIL crapdat  THEN
        ASSIGN aux_dtrefere = crapdat.dtultdma.

    IF NOT VALID-HANDLE(h-b1wgen9999) THEN
       RUN sistema/generico/procedures/b1wgen9999.p 
           PERSISTENT SET h-b1wgen9999.

    IF NOT VALID-HANDLE(h-b1wgen9999) THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Handle invalido para b1wgen9999".
      
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
      
           RETURN "NOK".
      
       END.

    RUN log-simula-perc (INPUT TODAY,
                         INPUT par_cdoperad,
                         INPUT par_persocio).

    /* Remover todos os grupos */
    FOR EACH crapgrp WHERE crapgrp.cdcooper = par_cdcooper 
                           EXCLUSIVE-LOCK:
        
        DELETE crapgrp.

    END.


    /* empresas socias de outra empresa */
    FOR EACH crapepa WHERE crapepa.cdcooper = par_cdcooper  AND
                           crapepa.persocio >= par_persocio 
                           NO-LOCK,

        FIRST crapass WHERE crapass.cdcooper = crapepa.cdcooper AND
                            crapass.nrdconta = crapepa.nrdconta AND
                            crapass.dtelimin = ?
                            NO-LOCK:

        FIND crapjur WHERE crapjur.cdcooper = crapass.cdcooper AND   
                           crapjur.nrdconta = crapass.nrdconta
                           NO-LOCK NO-ERROR.
       
        IF AVAIL crapjur THEN
        DO:
           FIND gncdntj WHERE gncdntj.cdnatjur = crapjur.natjurid AND
                              gncdntj.flgprsoc
                              NO-LOCK NO-ERROR.
           
           IF AVAIL gncdntj  THEN
           DO:
              /* Nao eh formado grupo se a empresa socia proprietaria 
                 nao possuir c/c na cooperativa */
              IF crapepa.nrctasoc = 0  AND
                 NOT CAN-FIND(FIRST crabass 
                              WHERE crabass.cdcooper = crapepa.cdcooper  AND
                                    crabass.nrcpfcgc = crapepa.nrdocsoc)  THEN
                 NEXT.

              /*Nao eh formado o grupo se a empresa socia proprietaria nao 
                tiver percentual de soc. obrigatoria*/
              FIND b-crapjur1 WHERE b-crapjur1.cdcooper = crapepa.cdcooper AND
                                    b-crapjur1.nrdconta = crapepa.nrctasoc
                                    NO-LOCK NO-ERROR.

              IF AVAIL b-crapjur1 THEN
                 DO:
                    FIND b-gncdntj1 
                         WHERE b-gncdntj1.cdnatjur = b-crapjur1.natjurid AND
                               b-gncdntj1.flgprsoc = FALSE
                               NO-LOCK NO-ERROR.

                    IF AVAIL b-gncdntj1 THEN
                       NEXT.

                 END.

              /* Nao eh formado grupo se a empresa socia proprietaria 
                 nao possuir c/c na cooperativa */
              FIND b-crapass1 WHERE b-crapass1.cdcooper = crapepa.cdcooper AND
                                    b-crapass1.nrdconta = crapepa.nrctasoc 
                                    NO-LOCK NO-ERROR.

              IF NOT AVAIL b-crapass1 THEN
                 NEXT.
              ELSE 
                 DO:
                    /* Despreza empresa socia proprietaria que tenha conta na 
                       cooperarita e que esteja eliminada */
                    IF b-crapass1.dtelimin <> ? THEN 
                       NEXT.

                 END.

              /* Verifica se o CNPJ da empresa ja pertence a 
                 outro grupo */
              FIND FIRST crapgrp WHERE crapgrp.cdcooper = crapass.cdcooper AND
                                       crapgrp.nrcpfcgc = crapass.nrcpfcgc 
                                       NO-LOCK NO-ERROR.

              IF AVAIL crapgrp  THEN
                 DO:
                     ASSIGN aux_nrdgrupo = crapgrp.nrdgrupo.
                 END.
              ELSE
                 DO:
                    /* Verifica se o CNPJ da empresa participante 
                       ja pertence a outro grupo */
                    FIND FIRST crapgrp WHERE 
                               crapgrp.cdcooper = crapepa.cdcooper AND 
                               crapgrp.nrcpfcgc = crapepa.nrdocsoc
                               NO-LOCK NO-ERROR.
              
                    IF AVAIL crapgrp  THEN
                       DO:
                           ASSIGN aux_nrdgrupo = crapgrp.nrdgrupo.
                       END.
                    ELSE
                       DO:
                          ASSIGN aux_nrdgrupo = aux_nrultgrp + 1
                                 aux_nrultgrp = aux_nrdgrupo
                                 aux_nrdconta = crapepa.nrdconta 
                                 aux_nrctasoc = crapepa.nrdconta 
                                 aux_nrcpfcgc = crapass.nrcpfcgc 
                                 aux_inpessoa = 2
                                 aux_cdagenci = crapass.cdagenci.

                       END.

                 END.
              
              /* cria a formadora do grupo */
              CREATE crapgrp.

              ASSIGN crapgrp.cdcooper = crapepa.cdcooper
                     crapgrp.nrdgrupo = aux_nrdgrupo
                     crapgrp.nrdconta = crapepa.nrdconta
                     crapgrp.nrctasoc = crapepa.nrdconta
                     crapgrp.nrcpfcgc = crapass.nrcpfcgc
                     crapgrp.inpessoa = 2
                     crapgrp.idseqttl = 999 /* conta juridica que inicia o grupo */
                     crapgrp.cdagenci = crapass.cdagenci
                     crapgrp.dtmvtolt = par_dtmvtolt.
              VALIDATE crapgrp.


              /* monta a ligacao de contas desta empresa no grupo */
              RUN monta_arvore(INPUT crapepa.cdcooper, 
                               INPUT par_dtmvtolt,
                               INPUT aux_nrdgrupo, 
                               INPUT crapepa.nrdconta, 
                               INPUT crapass.nrcpfcgc).

              /* cria o relacionamento no grupo */
              CREATE crapgrp.

              ASSIGN crapgrp.cdcooper = crapepa.cdcooper
                     crapgrp.nrdgrupo = aux_nrdgrupo
                     crapgrp.nrdconta = crapepa.nrdconta
                     crapgrp.nrctasoc = crapepa.nrctasoc
                     crapgrp.nrcpfcgc = crapepa.nrdocsoc
                     crapgrp.inpessoa = 2
                     crapgrp.idseqttl = 997 /* empresa com percentual societario */
                     crapgrp.cdagenci = b-crapass1.cdagenci
                     crapgrp.dtmvtolt = par_dtmvtolt.
              VALIDATE crapgrp.

              /* monta a ligacao de contas desta empresa no grupo */
              RUN monta_arvore(INPUT crapepa.cdcooper, 
                               INPUT par_dtmvtolt,
                               INPUT aux_nrdgrupo, 
                               INPUT crapepa.nrctasoc, 
                               INPUT crapepa.nrdocsoc).

           END.
       
        END. /* fim if contas natureza juridica */
       
    END.

    
    /* Procuradores/socio proprietario da empresa */
    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper  AND
                           crapavt.tpctrato = 6             AND
                           crapavt.persocio >= par_persocio AND
                           crapavt.flgdepec
                           NO-LOCK,

        FIRST crapass WHERE crapass.cdcooper = crapavt.cdcooper AND
                            crapass.nrdconta = crapavt.nrdconta AND
                            crapass.dtelimin = ?
                            NO-LOCK:
        
        FIND crapjur WHERE crapjur.cdcooper = crapass.cdcooper AND
                           crapjur.nrdconta = crapass.nrdconta
                           NO-LOCK NO-ERROR.

        IF AVAIL crapjur  THEN
        DO:
           FIND gncdntj WHERE gncdntj.cdnatjur = crapjur.natjurid AND
                              gncdntj.flgprsoc
                              NO-LOCK NO-ERROR.
    
           IF AVAIL gncdntj  THEN
           DO:
              /* Verifica se o CNPJ ja pertence a outro grupo */
              FIND FIRST crapgrp WHERE crapgrp.cdcooper = crapass.cdcooper AND
                                       crapgrp.nrcpfcgc = crapass.nrcpfcgc 
                                       NO-LOCK NO-ERROR.

              IF AVAIL crapgrp  THEN
                 DO:
                    /* pega o codigo do grupo */
                    ASSIGN aux_nrdgrupo = crapgrp.nrdgrupo
                           aux_nrdconta = crapass.nrdconta
                           aux_nrctasoc = crapass.nrdconta
                           aux_nrcpfcgc = crapass.nrcpfcgc
                           aux_inpessoa = crapass.inpessoa
                           aux_cdagenci = crapass.cdagenci.
               
                 END.
              ELSE
                 DO: 
                    ASSIGN aux_nrdgrupo = aux_nrultgrp + 1
                           aux_nrultgrp = aux_nrdgrupo
                           aux_nrdconta = crapavt.nrdconta
                           aux_nrctasoc = crapavt.nrdconta
                           aux_nrcpfcgc = crapass.nrcpfcgc
                           aux_inpessoa = 2
                           aux_cdagenci = crapass.cdagenci.
               
                 END.

              /* buscar dados do socio/prop para validar resp. legal */
              FIND FIRST crapttl WHERE crapttl.cdcooper = crapavt.cdcooper AND
                                       crapttl.nrdconta = crapavt.nrdctato 
                                       NO-LOCK NO-ERROR.

              IF AVAIL crapttl THEN
              DO:
                 /* Nao eh formado grupo se o rep.Procurador 
                    nao possuir c/c na cooperativa */
                 FIND b-crapass1 
                      WHERE b-crapass1.cdcooper = crapttl.cdcooper AND
                            b-crapass1.nrdconta = crapttl.nrdconta 
                            NO-LOCK NO-ERROR.
                  
                 IF NOT AVAIL b-crapass1 THEN
                    NEXT.
                 ELSE
                    DO:
                       /* Despreza rep.Procurador que tenha conta na 
                          cooperarita e que esteja eliminada */
                       IF b-crapass1.dtelimin <> ? THEN 
                          NEXT.

                    END.

                 /* Buscar idade */     
                 IF crapttl.inhabmen = 0  OR   /* pode ser menor de idade */
                    crapttl.inhabmen = 2  THEN /* incapacidade civil */
                 DO:
                    /* Verificar idade */
                    RUN idade IN h-b1wgen9999 (INPUT crapttl.dtnasttl,
                                               INPUT par_dtmvtolt, 
                                              OUTPUT aux_nrdeanos,
                                              OUTPUT aux_nrdmeses, 
                                              OUTPUT aux_dsdidade).
    
                    IF RETURN-VALUE = "NOK"  THEN
                       NEXT.
    
                    /* Se for menor de idade o integrante do grupo eh o 
                       representante/responsavel do menor */
                    IF aux_nrdeanos < 18     OR 
                       crapttl.inhabmen = 2  THEN
                    DO: 
                       /* Busca as contas/CPFs que sao responsavel pelo menor */
                       FOR EACH crapcrl WHERE crapcrl.cdcooper = crapttl.cdcooper AND
                                              crapcrl.nrctamen = crapttl.nrdconta 
                                              NO-LOCK BREAK BY crapcrl.nrctamen:
    
                           /* Varre todas as contas deste representante */
                           FOR EACH crabass WHERE crabass.cdcooper = crapcrl.cdcooper AND
                                                  crabass.nrdconta = crapcrl.nrdconta AND
                                                  crabass.dtelimin = ?
                                                  NO-LOCK:

                               IF FIRST-OF(crapcrl.nrctamen) THEN
                                  DO:
                                     /* conta formadora */
                                     CREATE crapgrp.
                                     
                                     ASSIGN crapgrp.cdcooper = crapavt.cdcooper
                                            crapgrp.nrdgrupo = aux_nrdgrupo
                                            crapgrp.nrdconta = aux_nrdconta
                                            crapgrp.nrctasoc = aux_nrctasoc
                                            crapgrp.nrcpfcgc = aux_nrcpfcgc
                                            crapgrp.inpessoa = aux_inpessoa
                                            crapgrp.idseqttl = 999
                                            crapgrp.cdagenci = aux_cdagenci
                                            crapgrp.dtmvtolt = par_dtmvtolt. 
                                     VALIDATE crapgrp.
                                     
                                     /* monta a ligacao de contas desta empresa no grupo */
                                     RUN monta_arvore(INPUT crapavt.cdcooper, 
                                                      INPUT par_dtmvtolt,
                                                      INPUT aux_nrdgrupo, 
                                                      INPUT aux_nrdconta, 
                                                      INPUT aux_nrcpfcgc).
                                     
                                  END.

                               /* cria o relacionamento no grupo */
                               CREATE crapgrp.
    
                               ASSIGN crapgrp.cdcooper = crapavt.cdcooper
                                      crapgrp.nrdgrupo = aux_nrdgrupo
                                      crapgrp.nrdconta = crapavt.nrdconta /* conta do menor */
                                      crapgrp.nrctasoc = crabass.nrdconta /* conta do resp */
                                      crapgrp.nrcpfcgc = crabass.nrcpfcgc /* cpf do resp */
                                      crapgrp.inpessoa = 1
                                      crapgrp.idseqttl = 996 /* representante de um menor */
                                      crapgrp.cdagenci = crabass.cdagenci
                                      crapgrp.dtmvtolt = par_dtmvtolt.
                               VALIDATE crapgrp.

                               /* monta a ligacao de titulares deste responsavel no grupo, 
                                  utiliza metodo de recursao para varrer todos os titulares */
                               RUN monta_arvore(INPUT par_cdcooper, 
                                                INPUT par_dtmvtolt,
                                                INPUT aux_nrdgrupo, 
                                                INPUT crabass.nrdconta, 
                                                INPUT crabass.nrcpfcgc).
    
                           END.
    
                       END.
    
                       NEXT. /* parte para o proximo pois termina o processo no responsavel */

                    END.
    
                 END.

              END.
              ELSE /* caso nao encontrar este socio/proprietario */
              DO:
                 /* Buscar idade */     
                 IF crapavt.inhabmen = 0  OR   /* pode ser menor de idade */
                    crapavt.inhabmen = 2  THEN /* incapacidade civil */
                 DO:
                    /* Verificar se eh menor de idade */
                    /* Verificar idade */
                    RUN idade IN h-b1wgen9999 (INPUT crapavt.dtnascto,
                                               INPUT par_dtmvtolt, 
                                              OUTPUT aux_nrdeanos,
                                              OUTPUT aux_nrdmeses, 
                                              OUTPUT aux_dsdidade).
    
                    IF RETURN-VALUE = "NOK"  THEN
                       NEXT.
    
                    /* Se for menor de idade */
                    IF aux_nrdeanos < 18     OR
                       crapavt.inhabmen = 2  THEN
                       DO:
                          /* Busca as contas/CPFs que sao responsavel pelo menor */
                          FOR EACH crapcrl WHERE crapcrl.cdcooper = crapavt.cdcooper AND
                                                 crapcrl.nrcpfmen = crapavt.nrcpfcgc 
                                                 NO-LOCK BREAK BY crapcrl.nrctamen
                                                                BY crapcrl.nrcpfmen:
                       
                              /* Varre todas as contas deste representante */
                              FOR EACH crabass WHERE crabass.cdcooper = crapcrl.cdcooper AND
                                                     crabass.nrdconta = crapcrl.nrdconta AND
                                                     crabass.dtelimin = ?
                                                     NO-LOCK:

                                  IF FIRST-OF(crapcrl.nrcpfmen) THEN
                                     DO:
                                        /* conta formadora */
                                        CREATE crapgrp.
                                       
                                        ASSIGN crapgrp.cdcooper = crapavt.cdcooper
                                               crapgrp.nrdgrupo = aux_nrdgrupo
                                               crapgrp.nrdconta = aux_nrdconta
                                               crapgrp.nrctasoc = aux_nrctasoc
                                               crapgrp.nrcpfcgc = aux_nrcpfcgc
                                               crapgrp.inpessoa = aux_inpessoa
                                               crapgrp.idseqttl = 999
                                               crapgrp.cdagenci = aux_cdagenci
                                               crapgrp.dtmvtolt = par_dtmvtolt. 
                                        VALIDATE crapgrp.
                                       
                                        /* monta a ligacao de contas desta empresa no grupo */
                                        RUN monta_arvore(INPUT crapavt.cdcooper, 
                                                         INPUT par_dtmvtolt,
                                                         INPUT aux_nrdgrupo, 
                                                         INPUT aux_nrdconta, 
                                                         INPUT aux_nrcpfcgc).

                                     END.
                       
                                  /* cria o relacionamento no grupo */
                                  CREATE crapgrp.
                       
                                  ASSIGN crapgrp.cdcooper = crapavt.cdcooper
                                         crapgrp.nrdgrupo = aux_nrdgrupo
                                         crapgrp.nrdconta = crapavt.nrdconta /* conta do menor */
                                         crapgrp.nrctasoc = crabass.nrdconta /* conta do resp */
                                         crapgrp.nrcpfcgc = crabass.nrcpfcgc /* cpf do resp */
                                         crapgrp.inpessoa = 1
                                         crapgrp.idseqttl = 996 /* representante de um menor */
                                         crapgrp.cdagenci = crabass.cdagenci
                                         crapgrp.dtmvtolt = par_dtmvtolt.
                                  VALIDATE crapgrp.
                       
                                  /* monta a ligacao de titulares deste responsavel no grupo, 
                                     utiliza metodo de recursao para varrer todos os titulares */
                                  RUN monta_arvore(INPUT par_cdcooper, 
                                                   INPUT par_dtmvtolt,
                                                   INPUT aux_nrdgrupo, 
                                                   INPUT crabass.nrdconta, 
                                                   INPUT crabass.nrcpfcgc).
                       
                              END.
                       
                          END.
                       
                          NEXT. /* parte para o proximo pois termina o processo no responsavel */
                       
                       END.
                    ELSE
                       NEXT. /* parte para o proximo pois socio/proc sem conta nao entra no grupo*/
                    

                 END. 
                 ELSE 
                    NEXT. /* parte para o proximo pois socio/proc sem conta nao entra no grupo*/
                        
              END. /* Fim Else */
              
              /* conta formadora */
              CREATE crapgrp.

              ASSIGN crapgrp.cdcooper = crapavt.cdcooper
                     crapgrp.nrdgrupo = aux_nrdgrupo
                     crapgrp.nrdconta = aux_nrdconta
                     crapgrp.nrctasoc = aux_nrctasoc
                     crapgrp.nrcpfcgc = aux_nrcpfcgc
                     crapgrp.inpessoa = aux_inpessoa
                     crapgrp.idseqttl = 999
                     crapgrp.cdagenci = aux_cdagenci
                     crapgrp.dtmvtolt = par_dtmvtolt.
              VALIDATE crapgrp.

              /* monta a ligacao de contas desta empresa no grupo */
              RUN monta_arvore(INPUT crapavt.cdcooper, 
                               INPUT par_dtmvtolt,
                               INPUT aux_nrdgrupo, 
                               INPUT aux_nrdconta, 
                               INPUT aux_nrcpfcgc).

              /* cria o relacionamento no grupo */
              CREATE crapgrp.

              ASSIGN crapgrp.cdcooper = crapavt.cdcooper
                     crapgrp.nrdgrupo = aux_nrdgrupo
                     crapgrp.nrdconta = crapavt.nrdconta
                     crapgrp.nrctasoc = b-crapass1.nrdconta
                     crapgrp.nrcpfcgc = b-crapass1.nrcpfcgc
                     crapgrp.inpessoa = b-crapass1.inpessoa
                     crapgrp.idseqttl = 998 /* preposta com percentual societario */
                     crapgrp.cdagenci = b-crapass1.cdagenci
                     crapgrp.dtmvtolt = par_dtmvtolt.
              VALIDATE crapgrp.

              /* monta a ligacao de titulares no grupo, 
                 utiliza metodo de recursao para varrer todos os titulares */
              RUN monta_arvore(INPUT par_cdcooper, 
                               INPUT par_dtmvtolt,
                               INPUT aux_nrdgrupo, 
                               INPUT crapavt.nrdctato, 
                               INPUT crapavt.nrcpfcgc).

              IF RETURN-VALUE <> "OK"  THEN
                 NEXT.
    
           END. /* Fim IF Natureza Juridica */
    
        END. /* Fim IF Conta Juridica */

    END. /* Fim FOR EACH busca socios proprietarios */
    
    /* Mesclar Grupos Economicos */
    RUN mesclar_grupos (INPUT par_cdcooper,
                        INPUT 0).

    FOR EACH crapgrp WHERE crapgrp.cdcooper = par_cdcooper 
                           NO-LOCK BREAK BY crapgrp.nrdgrupo:

        IF FIRST-OF(crapgrp.nrdgrupo) THEN
           RUN calc_endivid_risco_grupo (INPUT par_cdcooper,
                                         INPUT par_cdagenci, 
                                         INPUT par_nrdcaixa, 
                                         INPUT par_cdoperad, 
                                         INPUT par_dtmvtolt, 
                                         INPUT par_nmdatela, 
                                         INPUT par_cdprogra,
                                         INPUT par_idorigem, 
                                         INPUT crapgrp.nrdgrupo, 
                                         INPUT TRUE, /*Consulta por conta*/
                                        OUTPUT opt_dsdrisco, 
                                        OUTPUT opt_vlendivi,
                                        OUTPUT TABLE tt-grupo,
                                        OUTPUT TABLE tt-erro).
           
    
    END.
    
    IF VALID-HANDLE(h-b1wgen9999) THEN
       DELETE OBJECT h-b1wgen9999.

    RETURN "OK".

END PROCEDURE.


/* Procedure responsavel por calcular e gravar o risco e o endividamento do 
   grupo*/
PROCEDURE calc_endivid_risco_grupo:

    DEF INPUT  PARAM par_cdcooper AS INT                           NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INT                           NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INT                           NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                          NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_cdprogra AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INT                           NO-UNDO.
    DEF INPUT  PARAM par_nrdgrupo AS INT                           NO-UNDO.
    DEF INPUT  PARAM par_tpdecons AS LOG                           NO-UNDO.
    
    DEF OUTPUT PARAMETER par_dsdrisco AS CHAR                      NO-UNDO.
    DEF OUTPUT PARAMETER par_vlendivi AS DEC                       NO-UNDO.
    DEF OUTPUT PARAMETER TABLE FOR tt-grupo.
    DEF OUTPUT PARAMETER TABLE FOR tt-erro.

    DEF VARIABLE aux_innivris AS INT                               NO-UNDO.
    DEF VARIABLE opt_vlendivi AS DEC                               NO-UNDO.
    DEF VARIABLE opt_innivris AS INT                               NO-UNDO.
    DEF VARIABLE h-b1wgen9999 AS HANDLE                            NO-UNDO.
    DEF VARIABLE aux_contador AS INT                               NO-UNDO.
    DEF VARIABLE aux_tpdordem AS CHAR                              NO-UNDO.
    DEF VARIABLE aux_query    AS CHAR                              NO-UNDO.
    DEF VARIABLE q_crapgrp    AS HANDLE                            NO-UNDO.
    DEF VARIABLE aux_regisant AS CHAR                              NO-UNDO.

    DEF BUFFER b-crapgrp FOR crapgrp.
 
    ASSIGN aux_innivris = 0
           aux_query    = ""
           aux_tpdordem = ""
           aux_regisant = "".


    IF NOT VALID-HANDLE(h-b1wgen9999) THEN
       RUN sistema/generico/procedures/b1wgen9999.p 
           PERSISTENT SET h-b1wgen9999.

    IF NOT VALID-HANDLE(h-b1wgen9999)  THEN
       RETURN "NOK".

    /*Informa se o break by sera por cpf ou por conta - break by dinamico*/
    IF par_tpdecons = FALSE THEN
       ASSIGN aux_tpdordem = "crapgrp.nrcpfcgc".
    ELSE
       ASSIGN aux_tpdordem = "crapgrp.nrctasoc".
    

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.

    /*Monta o for each com break by dinamico*/
    ASSIGN aux_query = "FOR EACH crapgrp WHERE " +
                       "crapgrp.cdcooper = " + STRING(par_cdcooper) +
                       " AND crapgrp.nrdgrupo = " + STRING(par_nrdgrupo) +
                       " NO-LOCK BREAK BY " + aux_tpdordem.

    CREATE QUERY q_crapgrp.

    q_crapgrp:SET-BUFFERS(BUFFER crapgrp:HANDLE).
    q_crapgrp:QUERY-PREPARE(aux_query).
    q_crapgrp:QUERY-OPEN.


    DO WHILE TRUE:
    
       ASSIGN opt_vlendivi = 0
              opt_innivris = 0
              par_dsdrisco = "".

       q_crapgrp:GET-NEXT().

       IF q_crapgrp:QUERY-OFF-END THEN
          LEAVE.

       IF par_tpdecons = TRUE THEN
          DO:
             IF STRING(crapgrp.nrctasoc) <> aux_regisant THEN
                ASSIGN aux_regisant = STRING(crapgrp.nrctasoc).
             ELSE
                NEXT.

          END.
       ELSE
          DO:
             IF STRING(crapgrp.nrcpfcgc) <> aux_regisant THEN
                ASSIGN aux_regisant = STRING(crapgrp.nrcpfcgc).
             ELSE
                NEXT.
           
          END.
       

       IF crapgrp.nrctasoc > 0  THEN
          DO TRANSACTION:

              RUN calc_risco_individual(INPUT crapgrp.cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT "b1wgen0138",
                                        INPUT par_idorigem,
                                        INPUT crapgrp.nrctasoc,
                                        INPUT (IF par_cdprogra = "crps634" THEN 
                                                  crapdat.dtmvtolt
                                               ELSE IF par_cdprogra = "crps641" THEN
                                                    crapdat.dtultdma
                                               ELSE 
                                                  crapdat.dtultdia),
                                        OUTPUT opt_innivris,  
                                        OUTPUT par_dsdrisco,
                                        OUTPUT TABLE tt-erro).
          
              IF RETURN-VALUE <> "OK"  THEN
                 NEXT.
          
              DO aux_contador = 1 TO 10:
          
                 FIND FIRST b-crapgrp 
                      WHERE b-crapgrp.cdcooper = crapgrp.cdcooper AND
                            b-crapgrp.nrdgrupo = crapgrp.nrdgrupo AND
                            b-crapgrp.nrcpfcgc = crapgrp.nrcpfcgc AND
                            b-crapgrp.nrctasoc = crapgrp.nrctasoc
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
                 IF NOT AVAIL b-crapgrp THEN
                    NEXT.
                 ELSE
                    LEAVE.
          
              END.

              IF AVAIL b-crapgrp  THEN
                 DO:
                     ASSIGN b-crapgrp.innivris = opt_innivris
                            b-crapgrp.dsdrisco = par_dsdrisco
                            b-crapgrp.dtrefere = 
                                         (IF par_cdprogra = "crps634" THEN 
                                             crapdat.dtmvtolt
                                          ELSE IF par_cdprogra = "crps641" THEN
                                                  crapdat.dtultdma
                                          ELSE 
                                             crapdat.dtultdia).
          
                 END.
          

              RUN calc_endividamento_individual(INPUT crapgrp.cdcooper, 
                                                INPUT par_cdagenci, 
                                                INPUT par_nrdcaixa, 
                                                INPUT par_cdoperad, 
                                                INPUT "b1wgen0138", 
                                                INPUT par_idorigem, 
                                                INPUT crapgrp.nrctasoc, 
                                                INPUT 1, 
                                                INPUT par_dtmvtolt, 
                                                INPUT crapdat.dtmvtopr, 
                                                INPUT crapdat.inproces, 
                                                INPUT h-b1wgen9999:HANDLE,
                                                INPUT par_tpdecons, 
                                               OUTPUT opt_vlendivi,  
                                               OUTPUT TABLE tt-erro). 
          
              
              ASSIGN par_vlendivi = par_vlendivi + opt_vlendivi.
          
              /* Retornar as contas individuais do grupo com seu 
                 endividamento e risco */
              IF NOT CAN-FIND(FIRST tt-grupo WHERE 
                              tt-grupo.cdcooper = crapgrp.cdcooper  AND
                              tt-grupo.nrctasoc = crapgrp.nrctasoc  AND
                              tt-grupo.nrdgrupo = crapgrp.nrdgrupo
                              NO-LOCK)                              THEN
                 DO:
                     CREATE tt-grupo.

                     ASSIGN tt-grupo.cdcooper = crapgrp.cdcooper
                            tt-grupo.nrdgrupo = crapgrp.nrdgrupo
                            tt-grupo.nrdconta = crapgrp.nrdconta
                            tt-grupo.nrctasoc = crapgrp.nrctasoc
                            tt-grupo.nrcpfcgc = crapgrp.nrcpfcgc
                            tt-grupo.inpessoa = crapgrp.inpessoa
                            tt-grupo.vlendivi = opt_vlendivi
                            tt-grupo.dsdrisco = par_dsdrisco
                            tt-grupo.innivris = crapgrp.innivris
                            tt-grupo.idseqttl = crapgrp.idseqttl
                            tt-grupo.cdagenci = crapgrp.cdagenci
                            tt-grupo.dtmvtolt = crapgrp.dtmvtolt
                            tt-grupo.dtrefere = crapgrp.dtrefere.
                 END.


          END.


       IF opt_innivris > 0              AND 
          opt_innivris < 10             AND /* Excessao de HH */
          aux_innivris < opt_innivris  THEN /* Buscar o maior risco do grupo */
          ASSIGN aux_innivris = opt_innivris.
           
    END.
        

    q_crapgrp:QUERY-CLOSE().
    DELETE OBJECT q_crapgrp.
    
    /* Grupo nao pode estar em prejuizo, sendo assim é trocado para 
       ir em risco H */
    IF aux_innivris = 0 THEN
       ASSIGN par_dsdrisco = "H"
              aux_innivris = 9.
    ELSE
       ASSIGN par_dsdrisco = ENTRY(aux_innivris,aux_dsdrisco).

    /* Leitura de todos do grupo para atualizar o risco do grupo */
    FOR EACH crapgrp WHERE crapgrp.cdcooper = par_cdcooper AND
                           crapgrp.nrdgrupo = par_nrdgrupo 
                           EXCLUSIVE-LOCK TRANSACTION:

        /* Risco/Endividamento do grupo */
        ASSIGN crapgrp.dsdrisgp = par_dsdrisco
               crapgrp.innivrge = aux_innivris.
    
    END.

    /*Le todos os registros do grupo e atualiza o valor do risco e do
      endividamento do grupo*/
    FOR EACH tt-grupo WHERE tt-grupo.cdcooper = par_cdcooper AND
                            tt-grupo.nrdgrupo = par_nrdgrupo
                            NO-LOCK:
    
        ASSIGN tt-grupo.vlendigp = par_vlendivi
               tt-grupo.dsdrisgp = par_dsdrisco
               tt-grupo.innivrge = aux_innivris.
    
    END.

    IF VALID-HANDLE(h-b1wgen9999) THEN
       DELETE OBJECT h-b1wgen9999.

    RETURN "OK".

END PROCEDURE. 


/* Procedure responsavel por calcular o endividamento do grupo */
PROCEDURE calc_endivid_grupo:

    DEF INPUT  PARAM par_cdcooper AS INT                        NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INT                        NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INT                        NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                       NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INT                        NO-UNDO.
    DEF INPUT  PARAM par_nrdgrupo AS INT                        NO-UNDO.
    DEF INPUT  PARAM par_tpdecons AS LOG                        NO-UNDO.
                                                            
    DEF OUTPUT PARAM par_dsdrisco AS CHAR                       NO-UNDO.
    DEF OUTPUT PARAM par_vlendivi AS DECI                       NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-grupo.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                     
                                                            
    DEF VAR opt_vlendivi AS DECI                                NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                              NO-UNDO.
    DEF VAR aux_tpdordem AS CHAR                                NO-UNDO.
    DEF VAR aux_query    AS CHAR                                NO-UNDO.
    DEF VAR q_crapgrp    AS HANDLE                              NO-UNDO.
    DEF VAR aux_regisant AS CHAR                                NO-UNDO.

    IF aux_limpagrp THEN
    EMPTY TEMP-TABLE tt-grupo.

    ASSIGN aux_query = ""
           aux_tpdordem = ""
           aux_regisant = "".

    IF NOT VALID-HANDLE(h-b1wgen9999) THEN
       RUN sistema/generico/procedures/b1wgen9999.p 
           PERSISTENT SET h-b1wgen9999.

    
    IF NOT VALID-HANDLE(h-b1wgen9999)  THEN
       RETURN "NOK".

    /*Informa se o break by sera por cpf ou conta - break by dinamico*/
    IF par_tpdecons = FALSE THEN
       ASSIGN aux_tpdordem = "crapgrp.nrcpfcgc".
    ELSE
       ASSIGN aux_tpdordem = "crapgrp.nrctasoc".
   

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.


    /*Monta o for each com break by dinamico*/
    ASSIGN aux_query = "FOR EACH crapgrp WHERE " +
                       "crapgrp.cdcooper = " + STRING(par_cdcooper) +
                       " AND crapgrp.nrdgrupo = " + STRING(par_nrdgrupo) +
                       " NO-LOCK BREAK BY " + aux_tpdordem.

    CREATE QUERY q_crapgrp.

    q_crapgrp:SET-BUFFERS(BUFFER crapgrp:HANDLE).
    q_crapgrp:QUERY-PREPARE(aux_query).
    q_crapgrp:QUERY-OPEN.


    DO WHILE TRUE:
    
        ASSIGN opt_vlendivi = 0.

        q_crapgrp:GET-NEXT().

        IF q_crapgrp:QUERY-OFF-END THEN
           LEAVE.

        IF par_tpdecons = TRUE THEN
           DO:
              IF STRING(crapgrp.nrctasoc) <> aux_regisant THEN
                 ASSIGN aux_regisant = STRING(crapgrp.nrctasoc).
              ELSE
                 NEXT.
         
           END.
        ELSE
           DO:
              IF STRING(crapgrp.nrcpfcgc) <> aux_regisant THEN
                 ASSIGN aux_regisant = STRING(crapgrp.nrcpfcgc).
              ELSE
                 NEXT.
            
           END.


        IF crapgrp.nrctasoc > 0  THEN
           DO:
               RUN calc_endividamento_individual(INPUT crapgrp.cdcooper, 
                                                 INPUT par_cdagenci, 
                                                 INPUT par_nrdcaixa, 
                                                 INPUT par_cdoperad, 
                                                 INPUT "b1wgen0138", 
                                                 INPUT par_idorigem, 
                                                 INPUT crapgrp.nrctasoc, 
                                                 INPUT 1, 
                                                 INPUT par_dtmvtolt, 
                                                 INPUT crapdat.dtmvtopr, 
                                                 INPUT crapdat.inproces, 
                                                 INPUT h-b1wgen9999:HANDLE,
                                                 INPUT par_tpdecons, 
                                                OUTPUT opt_vlendivi,  
                                                OUTPUT TABLE tt-erro). 
               
               ASSIGN par_vlendivi = par_vlendivi + opt_vlendivi.
           
               /* Retornar as contas individuais do grupo com seu 
                  endividamento e risco */
               IF NOT CAN-FIND(FIRST tt-grupo WHERE 
                               tt-grupo.cdcooper = crapgrp.cdcooper  AND
                               tt-grupo.nrctasoc = crapgrp.nrctasoc  AND
                               tt-grupo.nrdgrupo = crapgrp.nrdgrupo
                               NO-LOCK)                              THEN
                  DO:
                      CREATE tt-grupo.

                      ASSIGN tt-grupo.cdcooper = crapgrp.cdcooper
                             tt-grupo.nrdgrupo = crapgrp.nrdgrupo
                             tt-grupo.nrdconta = crapgrp.nrdconta
                             tt-grupo.nrctasoc = crapgrp.nrctasoc
                             tt-grupo.nrcpfcgc = crapgrp.nrcpfcgc
                             tt-grupo.inpessoa = crapgrp.inpessoa
                             tt-grupo.vlendivi = opt_vlendivi
                             tt-grupo.innivris = (IF crapgrp.innivris = 10 THEN 
                                                     9
                                                  ELSE
                                                     crapgrp.innivris)
                             tt-grupo.dsdrisco = (IF crapgrp.innivris = 10 THEN 
                                                     "H"
                                                  ELSE
                                                     crapgrp.dsdrisco)
                             tt-grupo.dsdrisgp = crapgrp.dsdrisgp
                             par_dsdrisco = crapgrp.dsdrisgp
                             tt-grupo.idseqttl = crapgrp.idseqttl
                             tt-grupo.cdagenci = crapgrp.cdagenci
                             tt-grupo.dtmvtolt = crapgrp.dtmvtolt
                             tt-grupo.dtrefere = crapgrp.dtrefere.
                  END.
           END.
    END.

    q_crapgrp:QUERY-CLOSE().
    DELETE OBJECT q_crapgrp.

    /*Le todos os registros do grupo e atualiza o valor do endividamento do 
      grupo*/
      
    FOR EACH tt-grupo WHERE tt-grupo.cdcooper = par_cdcooper AND
                            tt-grupo.nrdgrupo = par_nrdgrupo
                            NO-LOCK:

        ASSIGN tt-grupo.vlendigp = par_vlendivi.
               
    
    END.

    IF VALID-HANDLE(h-b1wgen9999) THEN
       DELETE OBJECT h-b1wgen9999.

    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ..........................*/

/*****************************************************************************/
/** Procedure para montar a 'arvore' de ligacoes do grupo economico SIMULANDO*/
/*****************************************************************************/
PROCEDURE monta_arvore PRIVATE:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdgrupo AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcpfcgc AS DECIMAL     NO-UNDO.

    DEF BUFFER cra2ass FOR crapass.

    FIND FIRST cra2ass WHERE cra2ass.cdcooper = par_cdcooper AND
                             cra2ass.nrcpfcgc = par_nrcpfcgc 
                             NO-LOCK NO-ERROR.

    IF AVAIL cra2ass  THEN
       DO:
          /* monta vinculos de pessoa fisica */
          IF cra2ass.inpessoa = 1  THEN
             DO:
                /* Busca as contas onde este cpf esta envolvido como primeiro 
                   titular */
                FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrcpfcgc = par_nrcpfcgc AND
                                       crapttl.idseqttl = 1 
                                       NO-LOCK,
                     
                   FIRST cra2ass WHERE cra2ass.cdcooper = crapttl.cdcooper AND
                                       cra2ass.nrdconta = crapttl.nrdconta AND
                                       cra2ass.dtelimin = ? 
                                       NO-LOCK:
             
                    /* se nao encontrar este relacionamento no grupo */
                    IF  NOT CAN-FIND(crapgrp WHERE 
                                     crapgrp.cdcooper = crapttl.cdcooper  AND
                                     crapgrp.nrdgrupo = par_nrdgrupo      AND
                                     crapgrp.nrcpfcgc = crapttl.nrcpfcgc  AND
                                     crapgrp.nrdconta = crapttl.nrdconta  AND
                                     crapgrp.idseqttl = crapttl.idseqttl) THEN
                    DO:
                        /* cria o relacionamento no grupo */
                        CREATE crapgrp.
             
                        ASSIGN crapgrp.cdcooper = crapttl.cdcooper
                               crapgrp.nrdgrupo = par_nrdgrupo
                               crapgrp.nrdconta = par_nrdconta
                               crapgrp.nrctasoc = crapttl.nrdconta
                               crapgrp.nrcpfcgc = crapttl.nrcpfcgc
                               crapgrp.inpessoa = 1
                               crapgrp.idseqttl = crapttl.idseqttl
                               crapgrp.cdagenci = cra2ass.cdagenci
                               crapgrp.dtmvtolt = par_dtmvtolt.
                        VALIDATE crapgrp.
             
                    END.
             
                END. /* FIM -Busca as contas onde este cpf esta envolvido */
             
             END. /* Fim IF */
          ELSE
             DO:
                /* monta vinculos de pessoa juridica */
                FOR EACH cra2ass WHERE cra2ass.cdcooper = par_cdcooper AND
                                       cra2ass.nrcpfcgc = par_nrcpfcgc AND
                                       cra2ass.dtelimin = ?
                                       NO-LOCK,
             
                   FIRST crapjur WHERE crapjur.cdcooper = cra2ass.cdcooper AND
                                       crapjur.nrdconta = cra2ass.nrdconta
                                       NO-LOCK:
             
                    FIND gncdntj WHERE gncdntj.cdnatjur = crapjur.natjurid AND
                                       gncdntj.flgprsoc
                                       NO-LOCK NO-ERROR.
             
                    IF AVAIL gncdntj  THEN
                       DO:
                          /* se nao encontrar este relacionamento no grupo */
                          IF NOT CAN-FIND(FIRST crapgrp WHERE 
                                          crapgrp.cdcooper = cra2ass.cdcooper  AND
                                          crapgrp.nrdgrupo = par_nrdgrupo      AND
                                          crapgrp.nrcpfcgc = cra2ass.nrcpfcgc  AND
                                          crapgrp.nrdconta = cra2ass.nrdconta  AND
                                         (crapgrp.idseqttl = 1   OR     /* ja criou a ligacao normal */ 
                                          crapgrp.idseqttl = 999 OR     /* ja criou a formadora */
                                          crapgrp.idseqttl = 997)) THEN /* ja criou a participante */
                             DO:
                                 /* cria o relacionamento no grupo */
                                 CREATE crapgrp.
                             
                                 ASSIGN crapgrp.cdcooper = cra2ass.cdcooper
                                        crapgrp.nrdgrupo = par_nrdgrupo
                                        crapgrp.nrdconta = cra2ass.nrdconta
                                        crapgrp.nrctasoc = cra2ass.nrdconta
                                        crapgrp.nrcpfcgc = cra2ass.nrcpfcgc
                                        crapgrp.inpessoa = cra2ass.inpessoa
                                        crapgrp.idseqttl = 1
                                        crapgrp.cdagenci = cra2ass.cdagenci
                                        crapgrp.dtmvtolt = par_dtmvtolt.
                                 VALIDATE crapgrp.
                             
                             END.
                      
                       END.
             
                END. /* Fim FOR EACH */
             
             END. /* Fim Else */
              
       END. /* Fim Avail crapass */
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/** Procedure que calcula o risco de um cooperado                           **/
/*****************************************************************************/
PROCEDURE calc_risco_individual:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctasoc AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtrefere AS DATE        NO-UNDO.
    
    DEFINE OUTPUT PARAMETER par_innivris AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER par_dsdrisco AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF BUFFER b-crapris1 FOR crapris.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "RISCOBACEN" AND
                       craptab.tpregist = 000 
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE craptab   THEN                   
       RETURN "NOK".
    
    FIND LAST crapris WHERE crapris.cdcooper = par_cdcooper AND
                            crapris.dtrefere = par_dtrefere AND
                            crapris.inddocto = 1            AND 
                            crapris.nrdconta = par_nrctasoc AND
                            crapris.vldivida > DEC(SUBSTRING(craptab.dstextab,3,9))
                            NO-LOCK NO-ERROR.

    IF AVAIL crapris THEN
       DO:
          IF crapris.innivris = 10 THEN
             DO:
                 FIND LAST b-crapris1 
                      WHERE b-crapris1.cdcooper = par_cdcooper AND
                            b-crapris1.dtrefere = par_dtrefere AND
                            b-crapris1.inddocto = 1            AND 
                            b-crapris1.nrdconta = par_nrctasoc AND
                            b-crapris1.vldivida > DEC(SUBSTRING(craptab.dstextab,3,9)) AND
                            b-crapris1.innivris <> 10
                            NO-LOCK NO-ERROR.
                 
                 IF AVAIL b-crapris1 THEN
                    ASSIGN par_innivris = (IF b-crapris1.inindris = 0 THEN
                                              b-crapris1.innivris
                                           ELSE
                                              b-crapris1.inindris)
                           par_dsdrisco = ENTRY(par_innivris,aux_dsdrisco).
                 ELSE
                    ASSIGN par_innivris = (IF crapris.inindris = 0 THEN
                                              crapris.innivris
                                           ELSE
                                              crapris.inindris)
                           par_dsdrisco = ENTRY(par_innivris,aux_dsdrisco).

             END.
          ELSE
             ASSIGN par_innivris = (IF crapris.inindris = 0 THEN
                                       crapris.innivris
                                    ELSE
                                       crapris.inindris)
                    par_dsdrisco = ENTRY(par_innivris,aux_dsdrisco).

       END.
    ELSE
       ASSIGN par_innivris = 2
              par_dsdrisco = "A".

    
    RETURN "OK".
    

END PROCEDURE.


/*****************************************************************************/
/** Procedure que calcula o endividamento de um cooperado                   **/
/*****************************************************************************/
PROCEDURE calc_endividamento_individual:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctasoc AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtopr AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_inproces AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_b1wgen9999 AS HANDLE    NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdecons AS LOG         NO-UNDO.
    /* par_tpdecons => FALSE - Consulta endividamento por cpf
                    => TRUE  - Consulta endividamento por conta */

    DEFINE OUTPUT PARAMETER par_vlutiliz AS DECIMAL     NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    IF par_nrctasoc <> 0 THEN
       DO:
          RUN saldo_utiliza IN par_b1wgen9999 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT par_nrctasoc,
                                               INPUT par_idseqttl,
                                               INPUT par_dtmvtolt,
                                               INPUT par_dtmvtopr,
                                               INPUT "",
                                               INPUT par_inproces,
                                               INPUT par_tpdecons,
                                              OUTPUT par_vlutiliz,
                                              OUTPUT TABLE tt-erro).

          IF  RETURN-VALUE <> "OK"  THEN
              RETURN "NOK".
       
          /* Buscar o saldo devedor de prejuizo e somar ao utilizado */
          /* Nao foi utilizado a bo27 pois ela le registro extras e 
             gera registro de log sem necessidade */
          FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                                 crapepr.nrdconta = par_nrctasoc   AND
                                 crapepr.inprejuz = 1 /*prejuizo*/ AND
                                 crapepr.vlprejuz > 0              AND
                                 crapepr.vlsdprej > 0 
                                 NO-LOCK:
       
              ASSIGN par_vlutiliz = par_vlutiliz    + 
                                    crapepr.vlsdprej.
       
          END.

          /* BNDES - Emprestimos em Prejuizo */
          FOR EACH crapebn WHERE crapebn.cdcooper = par_cdcooper     AND
                                 crapebn.nrdconta = par_nrctasoc     AND 
                                 crapebn.insitctr = "P"         NO-LOCK:

               ASSIGN par_vlutiliz = par_vlutiliz + crapebn.vlsdeved.

          END.
       
       END.

    RETURN "OK".


END PROCEDURE.


/*****************************************************************************/
/** Relatorio grupo economico                                               **/
/*****************************************************************************/
PROCEDURE relatorio_gp:
                
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmendter AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdrelato AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdgrupo AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_infoagen AS LOGICAL     NO-UNDO.

    DEFINE OUTPUT PARAMETER par_nmarqimp AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER tel_dsdrisgp AS CHARACTER   NO-UNDO. 
    DEFINE OUTPUT PARAMETER tel_vlendivi AS DECIMAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-grupo.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.


    DEFINE VARIABLE         h-b1wgen0024 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE         aux_nmarqpdf AS CHARACTER   NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    IF (par_infoagen) THEN
    DO:
    
        /* se informou agencia, não limpar a tt-grupo, 
           utlilizado na procedure calc_endivid_grupo */
        aux_limpagrp = FALSE.

        FOR EACH crapgrp WHERE crapgrp.cdcooper = par_cdcooper AND
                               crapgrp.cdagenci = par_cdagenci
                               NO-LOCK BREAK BY crapgrp.nrdgrupo:
            IF FIRST-OF(crapgrp.nrdgrupo) THEN
            DO:

                /*Procedure responsavel para calcular o endividamento do grupo */
                RUN calc_endivid_grupo
                                    (INPUT crapgrp.cdcooper,
                                     INPUT par_cdagenci, 
                                     INPUT 0, 
                                     INPUT par_cdoperad, 
                                     INPUT par_dtmvtolt, 
                                     INPUT par_nmdatela, 
                                     INPUT 1, 
                                     INPUT crapgrp.nrdgrupo, 
                                     INPUT TRUE, /*Consulta por conta*/
                                    OUTPUT tel_dsdrisgp, 
                                    OUTPUT tel_vlendivi,
                                    OUTPUT TABLE tt-grupo,
                                    OUTPUT TABLE tt-erro).
              
                IF  RETURN-VALUE <> "OK"  THEN
                    RETURN "NOK".   
            END.
    
        END.

        aux_limpagrp = TRUE.
        
    END.
    ELSE 
    DO:
        aux_limpagrp = TRUE.

        RUN calc_endivid_grupo (INPUT par_cdcooper,
                                INPUT par_cdagenci, 
                                INPUT 0, 
                                INPUT par_cdoperad, 
                                INPUT par_dtmvtolt, 
                                INPUT par_nmdatela, 
                                INPUT 1, 
                                INPUT par_nrdgrupo, 
                                INPUT TRUE, /*Consulta por conta*/
                               OUTPUT tel_dsdrisgp, 
                               OUTPUT tel_vlendivi,
                               OUTPUT TABLE tt-grupo,
                               OUTPUT TABLE tt-erro).
              
        IF  RETURN-VALUE <> "OK"  THEN
            RETURN "NOK".
    END.
          
    RUN imprimir_relatorio(
        INPUT  par_cdcooper,
        OUTPUT par_nmarqimp,
        INPUT  par_dtmvtolt,
        INPUT  par_cdrelato,
        INPUT  par_nmendter,
        INPUT TABLE tt-grupo).

    IF  par_idorigem = 5 THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT 
                SET h-b1wgen0024.
            
            RUN envia-arquivo-web 
                IN h-b1wgen0024 (INPUT  par_cdcooper,
                                 INPUT  par_cdagenci,
                                 INPUT  par_nrdcaixa,
                                 INPUT  par_nmarqimp,
                                 OUTPUT aux_nmarqpdf,
                                 OUTPUT TABLE tt-erro).
            
            IF  VALID-HANDLE(h-b1wgen0024) THEN
                DELETE PROCEDURE h-b1wgen0024.
            
            IF RETURN-VALUE <> "OK" THEN
                LEAVE.
            
            par_nmarqimp = aux_nmarqpdf.
        END.

    RETURN "OK".

END.
    

PROCEDURE imprimir_relatorio:
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER par_nmarqimp AS CHAR    NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE    NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdrelato AS INTEGER NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmendter AS CHAR    NO-UNDO.
    DEFINE INPUT  PARAMETER TABLE FOR tt-grupo.

    /***Cabecalho****/
    DEF VAR rel_nmrescop AS CHAR                           NO-UNDO.
    DEF VAR rel_nmresemp AS CHAR  FORMAT "x(15)"           NO-UNDO.
    DEF VAR rel_nmrelato AS CHAR  FORMAT "x(40)"           NO-UNDO.
    DEF VAR rel_nrmodulo AS INTE  FORMAT     "9"           NO-UNDO.
    DEF VAR rel_nmempres AS CHAR  FORMAT "x(15)"           NO-UNDO.
    DEF VAR rel_nmdestin AS CHAR                           NO-UNDO.
    DEF VAR rel_nmmodulo AS CHAR  FORMAT "x(15)" EXTENT 5  
                                  INIT ["","","","",""]    NO-UNDO.

    IF  TEMP-TABLE tt-grupo:HAS-RECORDS THEN
        DO:

            FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

            ASSIGN par_nmarqimp = "/usr/coop/" + crapcop.dsdircop
                                  + "/rl/" + par_nmendter 
                                  + STRING(TIME) + ".ex".

            OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED. 

            { sistema/generico/includes/b1cabrel132.i "11" par_cdrelato }

            VIEW STREAM str_1 FRAME f_cabrel132_1.

            FOR EACH tt-grupo NO-LOCK BREAK BY tt-grupo.nrdgrupo
                                             BY tt-grupo.cdagenci
                                              BY tt-grupo.nrctasoc:
                DISP STREAM str_1 
                              tt-grupo.cdagenci 
                              tt-grupo.nrdgrupo
                              tt-grupo.nrctasoc
                              tt-grupo.nrcpfcgc
                              tt-grupo.vlendivi 
                              tt-grupo.dsdrisco 
                              tt-grupo.vlendigp
                              tt-grupo.dsdrisgp
                              WITH FRAME f_grupo_3.
                DOWN WITH FRAME f_grupo_3.
            END.

            OUTPUT STREAM str_1 CLOSE.
        END. /* tt-grupo:HAS-RECORDS */

    RETURN "OK".
END.


/* Mesclar Grupos Economicos */
PROCEDURE mesclar_grupos PRIVATE:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdgrupo AS INTEGER     NO-UNDO.
    
    DEFINE VARIABLE flg_continue AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_nrdgrupo AS INTEGER     NO-UNDO.

    DEFINE BUFFER b-crapgrp FOR crapgrp.

    ASSIGN flg_continue = TRUE.
    
    DO WHILE flg_continue:
    
       ASSIGN flg_continue = FALSE.
       
       IF par_nrdgrupo = 0  THEN
          FOR EACH crapgrp WHERE crapgrp.cdcooper = par_cdcooper 
                                 NO-LOCK:
         
              /* verificar se o cpf/cnpj esta em algum outro grupo */
              /* cpf da conta */
              FIND FIRST b-crapgrp WHERE 
                         b-crapgrp.cdcooper =  crapgrp.cdcooper AND
                         b-crapgrp.nrcpfcgc =  crapgrp.nrcpfcgc AND
                         b-crapgrp.nrdgrupo <> crapgrp.nrdgrupo 
                         NO-LOCK NO-ERROR.
         
              /* se encontrar, muda todos do grupo para o novo grupo */
              IF AVAIL b-crapgrp  THEN
                 DO:
                    /* 'salva' o grupo que todos serao movidos */
                    ASSIGN aux_nrdgrupo = b-crapgrp.nrdgrupo.
                 
                    /* migra todo mundo do atual grupo para o novo grupo */
                    FOR EACH b-crapgrp WHERE 
                             b-crapgrp.cdcooper = crapgrp.cdcooper AND 
                             b-crapgrp.nrdgrupo = crapgrp.nrdgrupo
                             EXCLUSIVE-LOCK:
                        /*-----------------------------------------------------------------------------
                        Nao remover, manter os relacionamentos no grupo para haver a identificação
                        /* Quando migrar, se ja existir o relacionamento no novo grupo, remove-o */
                        IF  CAN-FIND(b2-tt-grupo WHERE b2-tt-grupo.cdcooper = b-tt-grupo.cdcooper  AND
                                                       b2-tt-grupo.nrdgrupo = b-tt-grupo.nrdgrupo  AND
                                                       b2-tt-grupo.nrdconta = b-tt-grupo.nrdconta  AND
                                                       b2-tt-grupo.nrctasoc = b-tt-grupo.nrctasoc  AND
                                                       b2-tt-grupo.nrcpfcgc = b-tt-grupo.nrcpfcgc  AND
                                                       b2-tt-grupo.idseqttl = b-tt-grupo.idseqttl) THEN
                            DELETE b-tt-grupo.
                        ELSE
                        -----------------------------------------------------------------------------*/
                        /* migra para o novo grupo */
                        ASSIGN b-crapgrp.nrdgrupo = aux_nrdgrupo.
                 
                        /* se ja estiver remove */
                    END.
                    
                    ASSIGN flg_continue = TRUE.
                    LEAVE.
                 
                 END.
         
          END.
       ELSE
          FOR EACH crapgrp WHERE crapgrp.cdcooper = par_cdcooper AND
                                 crapgrp.nrdgrupo = par_nrdgrupo 
                                 NO-LOCK:
          
              /* verificar se o cpf/cnpj esta em algum outro grupo */
              /* cpf da conta */
              FIND FIRST b-crapgrp WHERE 
                         b-crapgrp.cdcooper =  crapgrp.cdcooper AND
                         b-crapgrp.nrcpfcgc =  crapgrp.nrcpfcgc AND
                         b-crapgrp.nrdgrupo <> crapgrp.nrdgrupo 
                         NO-LOCK NO-ERROR.
          
              /* se encontrar, muda todos do grupo para o novo grupo */
              IF AVAIL b-crapgrp  THEN
                 DO:
                     /* 'salva' o grupo que todos serao movidos */
                     ASSIGN aux_nrdgrupo = b-crapgrp.nrdgrupo.
                 
                     /* migra todo mundo do atual grupo para o novo grupo */
                     FOR EACH b-crapgrp WHERE 
                              b-crapgrp.cdcooper = crapgrp.cdcooper AND 
                              b-crapgrp.nrdgrupo = crapgrp.nrdgrupo
                              EXCLUSIVE-LOCK:
                         /*-----------------------------------------------------------------------------
                         Nao remover, manter os relacionamentos no grupo para haver a identificação
                         /* Quando migrar, se ja existir o relacionamento no novo grupo, remove-o */
                         IF  CAN-FIND(b2-tt-grupo WHERE b2-tt-grupo.cdcooper = b-tt-grupo.cdcooper  AND
                                                        b2-tt-grupo.nrdgrupo = b-tt-grupo.nrdgrupo  AND
                                                        b2-tt-grupo.nrdconta = b-tt-grupo.nrdconta  AND
                                                        b2-tt-grupo.nrctasoc = b-tt-grupo.nrctasoc  AND
                                                        b2-tt-grupo.nrcpfcgc = b-tt-grupo.nrcpfcgc  AND
                                                        b2-tt-grupo.idseqttl = b-tt-grupo.idseqttl) THEN
                             DELETE b-tt-grupo.
                         ELSE
                         -----------------------------------------------------------------------------*/
                         /* migra para o novo grupo */
                         ASSIGN b-crapgrp.nrdgrupo = aux_nrdgrupo.
                 
                         /* se ja estiver remove */
                     END.
                 
                     ASSIGN flg_continue = TRUE.
                     LEAVE.
                 
                 END.
          
          END.

    END. /* FIM - mesclar os grupos com cpfs/cnpj em comum */

END PROCEDURE.

PROCEDURE log-simula-perc:

    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_persocio AS DECI                    NO-UNDO.

    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt) +
                      " "     + STRING(TIME,"HH:MM:SS")  + " ' --> ' " +
                      "Operador: " + par_cdoperad + " "  +
                      "Percentual: " + STRING(par_persocio) +
                      " >> log/simula.log").

    RETURN "OK".

END PROCEDURE.


/****************************************************************************
  FUNCAO IRA RETORNAR SE A CONTA EM QUESTAO PERTENCE A ALGUM GRUPO E QUAL E,
  SE O GRUPO ECONOMICO ESTA SENDO GERADO.
****************************************************************************/
FUNCTION busca_grupo RETURNS LOGICAL(INPUT par_cdcooper  AS INT,
                                     INPUT par_nrdconta  AS INT,
                                     OUTPUT par_nrdgrupo AS INT,
                                     OUTPUT par_gergrupo AS CHAR,
                                     OUTPUT par_dsdrisgp AS CHAR):

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND       
                       craptab.cdempres = 00           AND        
                       craptab.cdacesso = "CTRGRPECON" AND
                       craptab.tpregist = 99           
                       NO-LOCK NO-ERROR.
        
    IF AVAIL craptab          AND  
       craptab.dstextab <> "" THEN
       ASSIGN par_gergrupo = "Grupo Economico esta sendo gerado. " +
                             "Resultados podem variar.".
    ELSE
       ASSIGN par_gergrupo = "".



    FIND FIRST crapgrp WHERE crapgrp.cdcooper = par_cdcooper AND
                             crapgrp.nrctasoc = par_nrdconta
                             NO-LOCK NO-ERROR.
     IF AVAIL crapgrp THEN
       DO:
          ASSIGN par_nrdgrupo = crapgrp.nrdgrupo
                 par_dsdrisgp = crapgrp.dsdrisgp.

          RETURN TRUE.

       END.
    ELSE
       RETURN FALSE.

    RETURN FALSE.

END FUNCTION.

/*...........................................................................*/

