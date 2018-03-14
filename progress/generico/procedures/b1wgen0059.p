
/******************************************************************************
                           ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-------------------------------------+----------------------------------------+
  | Rotina Progress                     | Rotina Oracle PLSQL                    |
  +-------------------------------------+----------------------------------------+
  | busca-crapope			            | ZOOM0001.pc_busca_operadores           |
  | busca-crapban					    | ZOOM0001.pc_busca_bancos               |
  | busca-historico                     | ZOOM0001.pc_busca_historico            |
  | busca-craplrt					    | ZOOM0001.pc_busca_craplrt			     | 
  | busca-craplcr                       | ZOOM0001.pc_busca_craplcr              | 
  | busca-crapfin						| ZOOM0001.pc_busca_finalidades_empr_web |
  | busca-gncdnto                       | ZOOM0001.pc_busca_gncdnto              |
  | busca-gncdocp                       | ZOOM0001.pc_busca_gncdocp              |
  +-------------------------------------+----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*.............................................................................

    Programa: b1wgen0059.p
    Autor   : Jose Luis Marchezoni (DB1)
    Data    : Marco/2010                   Ultima atualizacao:  02/08/2017

    Objetivo  : Buscar os dados p/ telas de pesquisas ou zoom's

    Alteracoes: 28/07/2010 - Corrigir zoom-associados pois nao retorna nenhum
                             dado quando o filtro de pesquisa for a conta
                             integracao (David).
                             
                02/08/2010 - Desprezar tipos de conta BB que utilizam cheque
                             (Guilherme).
                             
                10/08/2010 - Retirar espaco (TRIM) em zooms que possuem
                             pesquisa (David). 
                             
                27/09/2010 - Incluido parametro para que na procedure 
                             zoom-associados possa ser ordenado por 
                             nome de coop ou por numero da conta (Adriano).
                             
                28/10/2010 - Inclusao de procedure busca-craplrt para padronizar
                             a busca de linhas de credito (GATI - Eder).
                             
                06/01/2011 - Incluir zoom para a tabela crapcco.
                
                04/04/2011 - Adicionado tratamento no retorno da busca-craprad
                             ( Gabriel/DB1 ).
                             
                12/05/2011 - Inclusao da procedure busca-modalidade para 
                             carregar as modalidades de risco (Isara - RKAM).
                             
                16/05/2011 - Procedimento busca-historico. (André - DB1)
                
                18/05/2011 - Procedimento busca-opcoes-manut-inss. (André - DB1)
                 
                19/05/2011 - Incluir flgregis na tt-crapcco. (Guilherme).
                
                16/06/2011 - Ignorar 'Nat.Ocupacao' = 99 (Gabriel). 
                
                22/06/2011 - Incluir zoom para Convenio da tela DECONV
                             (Gabriel).
                             
                28/07/2011 - Procedimento para busca de motivos de nao 
                             aprovacao - busca-gncmapr (Diego B. - Gati).
                             
                06/10/2011 - Criado a procedure busca-crapcop (Adriano).

                24/10/2011 - Adicionado a opçao de pesquisa por CPF/CNPJ 
                           na procedure zoom-associados (Rogerius Militao/DB1).
                            
                28/10/2011 - Criado a procecure busca-crapecv (Adriano).
                
                07/11/2011 - Criado a procecure busca-craptfn (Gabriel - DB1).
                
                12/01/2012 - Criado a procedure busca_arquivos_pamcard.
                             (Fabricio)
                06/03/2012 - Ayllos-Carac. Problema no zoom  Motivo quando 
                             digitava valor invalido no campo (Guilherme/Supero)
                             
                05/06/2012 - Projeto Adaptaçao de Fontes - Substituiçao da funçao 
                             CONTAINS pela MATCHES (Lucas R.). 
                             
                11/06/2012 - Procedure 'busca-crapfin' alterada para remoçao do 
                             campo EXTENT crapfin.cdlcrhab (Lucas).
                
                14/06/2012 - Inclusao de log para consulta de associados na 
                             procedure zoom-associados (Lucas R.).
                             
                27/06/2012 - Retirar uso do MATCHES nas leituras de pesquisa
                             (Guilherme).
                             
                25/02/2013 - Ajustes realizados:
                             - Alterado o nome do campo "cdcoosol" na procedure 
                               busca-crapcop para "cdcopsol";
                             - Criado a procedure busca-crapope;
                             - Criado a procedure busca-agencia;
                             - Criado a procedure busca-rotina.
                              (Adriano).   
                              
                08/04/2013 - Incluir novos campos na busca das cooperativas
                             (Gabriel) 

                                02/10/2013 - Alterado procedure busca-crapttl para conter registros
                             nos novos campo nmrescop e cdagenci (Jean Michel).             
                  
                23/10/2013 - Ajuste na procedure "busca-craptfn" para ordenar
                             a busca pelo nome da rede. (James)
                                                         
                                13/11/2013 - Alterado procedure busca-crapttl para busca do
                                                         nome da cooperativa (Jean Michel). 
                
                18/03/2014 - Ajustado leitura na craptfn estava somente 
                             FIELDS() - Projeto Oracle 
                           - Refeito a alteraçao CONTAINS - MATCHES(Guilherme).
                           
                02/04/2014 - Correcoes da tela operad web SD 122817 (Carlos)
                
                03/04/2014 - Ajuste na procedure zoom-associados para ganho 
                             performace dataserver (Daniel).
                             
                16/04/2014 - Adicionado parametro par_cdfinemp na procedure 
                             busca-craplcr
                           - Removido parametro par_cdlcremp da procedure 
                             busca-crapfin. (Reinert)
                             
                12/06/2014 - Trazer apenas convenios de cobrança ATIVOS na
                             busca-crapcco (SD. 165347 - Lunelli)
                             
                16/06/2014 -(Chamado 117414) - Alteraçao das informaçoes do conjuge da crapttl 
                            para utilizar somente crapcje. 
                            (Tiago Castro - RKAM)

                28/08/2014 - Nova procedure de Zoom para Perfil de Operadores
                             (Guilherme/SUPERO)
                             
                02/09/2014 - Carregar somente as cooperativas ativas no zoom
                             de cooperativas (David).
                             
                20/02/2015 - Retirado o cdsitprf na consulta da rotina
                             busca-crappfo (Adriano).
                             
                01/04/2015 - Criado proc. busca-produtos. (Jorge/Rodrigo)
                
                03/07/2015 - Criacao do novo parametro par_cdmodali na busca-craplcr
                             (Carlos Rafael Tanholi - Projeto Portabilidade).   

                24/07/2015 - Reformulacao cadastral (Gabriel-RKAM).
                
                04/11/2015 - Nao listar convenio de cobranca EMPRESTIMO
                             ref ao projeto 210. (Rafael)
                
                 06/11/2015 - Ajuste na rotina busca-crapope para corrigir
                             a logica utilizada no for each. Foi realizado
                             e liberado um ajuste indevidamente
                             (Adriano).
                 
                 25/11/2015 - Correcao no carregamento de linhas de credito
                              na procedure busca-craplcr, para consistir a 
                              modalidade igual a "undefined" assim nao gerando 
                              erro no carregamento das linhas em tela.
                              Projeto Portabilidade - Carlos Rafael Tanholi.
                             
                 23/03/2016 - Adicionar validacao para nao exibir os historicos
                              817,821, e 825 na tela de custodia
                              (Douglas - Melhoria 100 - Alineas)

				 15/07/2016 - Realizado a conversao da rotina busca-craplrt 
							  (Andrei - RKAM).

                20/07/2016 - Realizado a conversao das rotinas busca-craplcr,
				             busca-crapfin 
							  (Andrei - RKAM).

                17/08/2016 - Incluido campo txmensal na table tt-craplcr
                             busca-craplcr. (Lombardi)				             

				06/10/2016 - Inclusao de tratamento de origem "ACORDO" na
							 procedure busca-crapcco, prj. 302 (Jean Michel).
							 				
			    22/02/2017 - Removido as rotinas busca_nat_ocupacao, busca_ocupacao devido a conversao 
				             da busca_gncdnto e da busca-gncdocp
							 (Adriano - SD 614408).
							 				
                29/03/2017 - Criacao de filtro por tpprodut na busca-craplcr.
                             (Jaison/James - PRJ298)
							 				
                 07/06/2016 - Adicionar validacao para nao exibir o historico 
                              1019 na tela autori (Lucas Ranghetti #464211)

                 31/07/2017 - Alterado leitura da CRAPNAT pela CRAPMUN.
                             PRJ339 - CRM (Odirlei-AMcom)       
							         
			    02/08/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							 (Adriano - P339).

				15/07/2017 - Nova procedure. busca-crapass para listar os associados. (Mauro).

.............................................................................*/


/*................................. DEFINICOES ..............................*/

{ sistema/generico/includes/b1wgen0059tt.i &VAR-LOC=SIM &BD-GEN=SIM }

DEF STREAM str_1.

/*................................. PROCEDURES ..............................*/

PROCEDURE busca-gngresc:
    /* Busca dados de GRAU DE INSTRUCAO/ESCOLAR */

    DEF  INPUT PARAM par_grescola AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsescola AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-gngresc.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-gngresc. 

        ASSIGN par_dsescola = TRIM(par_dsescola).

        FOR EACH gngresc WHERE (IF par_grescola <> 0 THEN 
                                gngresc.grescola = par_grescola ELSE TRUE) AND
                               gngresc.dsescola MATCHES("*" + par_dsescola + 
                                                        "*") NO-LOCK:
            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-gngresc OF gngresc NO-ERROR.
    
                   IF   NOT AVAILABLE tt-gngresc THEN
                        DO:
                           CREATE tt-gngresc.
                           BUFFER-COPY gngresc TO tt-gngresc.
                        END.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END.

PROCEDURE busca-gncdfrm:
    /* Pesquisa para FORMACAO */

    DEF  INPUT PARAM par_cdfrmttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_rsfrmttl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-gncdfrm.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, RETURN:
        EMPTY TEMP-TABLE tt-gncdfrm. 

        ASSIGN par_rsfrmttl = TRIM(par_rsfrmttl).

        FOR EACH gncdfrm WHERE (IF par_cdfrmttl <> 0 THEN 
                                gncdfrm.cdfrmttl = par_cdfrmttl ELSE TRUE) AND
                                gncdfrm.rsfrmttl MATCHES("*" + par_rsfrmttl + 
                                                         "*") 
                                NO-LOCK BY gncdfrm.cdfrmttl:

            IF  gncdfrm.rsfrmttl = "" THEN
                NEXT.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO: 
                   FIND tt-gncdfrm OF gncdfrm NO-ERROR.
    
                   IF   NOT AVAILABLE tt-gncdfrm THEN
                        DO:
                           CREATE tt-gncdfrm.
                           BUFFER-COPY gncdfrm TO tt-gncdfrm.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

/*
craptab dstextab = 'CONJUGE,1,PAI/MAE,2,FILHO(A),3,COMPANHEIRO(A),4,OUTROS,5,COLABORADOR(A),6,ENTEADO(A),7,NENHUM,9'
			where craptab.cdcooper > 0 AND
				  craptab.nmsistem = 'CRED'                     AND
				  craptab.tptabela = 'GENERI'                   AND
				  craptab.cdempres = 0                          AND
				  craptab.cdacesso = 'VINCULOTTL'               AND
				  craptab.tpregist = 0;
*/
PROCEDURE busca-relacionamento:
    /* Pesquisa para RELACIONAMENTO */
    DEF  INPUT PARAM par_cdrelacionamento  AS INTE                  NO-UNDO.
    DEF  INPUT PARAM par_dsrelacionamento  AS CHAR                  NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-relacionamento.

    DEF VAR aux_idx AS INTE.

    ASSIGN aux_nrregist = par_nrregist.

    EMPTY TEMP-TABLE tt-relacionamento.
    EMPTY TEMP-TABLE tt-relacionamento2.

    DO ON ERROR UNDO, RETURN:

        ASSIGN par_dsrelacionamento = TRIM(par_dsrelacionamento).

        FIND FIRST craptab
            WHERE craptab.cdcooper = 1 AND
				  craptab.nmsistem = 'CRED'       AND
				  craptab.tptabela = 'GENERI'     AND
				  craptab.cdempres = 0            AND
				  craptab.cdacesso = 'VINCULOTTL' AND
				  craptab.tpregist = 0 NO-LOCK NO-ERROR.

        /* "CONJUGE,1,
            PAI/MAE,2,
           FILHO(A),3,
     COMPANHEIRO(A),4,
             OUTROS,5,
     COLABORADOR(A),6,
         ENTEADO(A),7,
             NENHUM,9" */
        DO aux_idx = 1 TO (NUM-ENTRIES(craptab.dstextab) ):
            CREATE tt-relacionamento2.
            ASSIGN tt-relacionamento2.cdcooper  = 1
                   tt-relacionamento2.codigo    = INTE(ENTRY((aux_idx + 1), craptab.dstextab))
                   tt-relacionamento2.descricao = ENTRY(aux_idx, craptab.dstextab)
                   aux_idx = aux_idx + 1. /* incrementa antes para avancar de 2 em 2 */
        END.

        FOR EACH tt-relacionamento2 WHERE (IF par_cdrelacionamento <> 0 THEN
                                          tt-relacionamento2.codigo = par_cdrelacionamento ELSE TRUE) AND
                                          tt-relacionamento2.descricao 
                                          MATCHES("*" + par_dsrelacionamento + "*") NO-LOCK:
            IF tt-relacionamento2.descricao = "" THEN
                NEXT.

            CREATE tt-relacionamento.
            ASSIGN tt-relacionamento.cdcooper  = tt-relacionamento2.cdcooper
                   tt-relacionamento.codigo    = tt-relacionamento2.codigo
                   tt-relacionamento.descricao = tt-relacionamento2.descricao.

            ASSIGN par_qtregist = par_qtregist + 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE busca-gncdncg:
    /* Pesquisa para NIVEL CARGO */

    DEF  INPUT PARAM par_cdnvlcgo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_rsnvlcgo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-gncdncg.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, RETURN:
        EMPTY TEMP-TABLE tt-gncdncg. 

        ASSIGN par_rsnvlcgo = TRIM(par_rsnvlcgo).

        FOR EACH gncdncg WHERE (IF par_cdnvlcgo <> 0 THEN 
                                gncdncg.cdnvlcgo = par_cdnvlcgo ELSE TRUE) AND
                               gncdncg.rsnvlcgo MATCHES("*" + par_rsnvlcgo + 
                                                        "*") NO-LOCK:

            IF  gncdncg.rsnvlcgo = "" THEN
                NEXT.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO: 
                   FIND tt-gncdncg OF gncdncg NO-ERROR.
    
                   IF   NOT AVAILABLE tt-gncdncg THEN
                        DO:
                           CREATE tt-gncdncg.
                           BUFFER-COPY gncdncg TO tt-gncdncg.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-turnos:
    /* Pesquisa para TURNOS */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdturnos AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsturnos AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-turnos.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, RETURN:
        EMPTY TEMP-TABLE tt-turnos. 

        ASSIGN par_dsturnos = TRIM(par_dsturnos).

        FOR EACH craptab FIELDS(dstextab tpregist)
                         WHERE craptab.cdcooper = par_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 0              AND
                               craptab.cdacesso = "DSCDTURNOS"   AND 
                              (IF par_cdturnos <> 0 THEN 
                                craptab.tpregist = par_cdturnos ELSE TRUE) AND
                               craptab.dstextab MATCHES("*" + par_dsturnos + 
                                                        "*") NO-LOCK:

            IF  craptab.dstextab = "" THEN
                NEXT.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO: 
                   FIND tt-turnos WHERE 
                                  tt-turnos.cdturnos = craptab.tpregist AND
                                  tt-turnos.dsturnos = craptab.dstextab 
                                  NO-ERROR.
    
                   IF   NOT AVAILABLE tt-turnos THEN
                        DO:
                           CREATE tt-turnos.
                           ASSIGN
                               tt-turnos.cdturnos = craptab.tpregist
                               tt-turnos.dsturnos = craptab.dstextab.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-cargos:
    /* Pesquisa para CARGOS */

    DEF  INPUT PARAM par_cddcargo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdcargo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-cargos.

    DEF VAR aux_contador          AS INTE                           NO-UNDO.
    DEF VAR aux_dsdcargo          AS CHAR                           NO-UNDO.

    ASSIGN 
        aux_nrregist = par_nrregist
        aux_dsdcargo = "SOCIO/PROPRIETARIO,DIRETOR/ADMINISTRADOR,PROCURADOR," +
                       "SOCIO COTISTA,SOCIO ADMINISTRADOR,SINDICO,"           + 
                       "TESOUREIRO,ADMINISTRADOR".

    DO ON ERROR UNDO, RETURN:
        EMPTY TEMP-TABLE tt-cargos. 

        DO aux_contador = 1 TO NUM-ENTRIES(aux_dsdcargo):
            CREATE tt-cargos.
            ASSIGN 
                tt-cargos.dsdcargo = ENTRY(aux_contador,aux_dsdcargo)
                par_qtregist       = par_qtregist + 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-gnetcvl:
    /* Pesquisa para ESTADO CIVIL */

    DEF  INPUT PARAM par_cdestcvl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsestcvl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-gnetcvl.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-gnetcvl. 

        ASSIGN par_dsestcvl = TRIM(par_dsestcvl).

        FOR EACH gnetcvl WHERE 
                         (IF par_cdestcvl <> 0 THEN 
                          gnetcvl.cdestcvl = par_cdestcvl ELSE TRUE) AND
                         gnetcvl.dsestcvl MATCHES("*" + par_dsestcvl + "*") 
                         NO-LOCK:

            IF  gnetcvl.dsestcvl = "" THEN
                NEXT.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO: 
                   FIND tt-gnetcvl OF gnetcvl NO-ERROR.
    
                   IF   NOT AVAILABLE tt-gnetcvl THEN
                        DO:
                           CREATE tt-gnetcvl.
                           BUFFER-COPY gnetcvl TO tt-gnetcvl.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-gncdntj:
    /* Pesquisa para NATUREZA JURIDICA */

    DEF  INPUT PARAM par_cdnatjur AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnatjur AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-gncdntj.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, RETURN:
        EMPTY TEMP-TABLE tt-gncdntj. 

        ASSIGN par_dsnatjur = TRIM(par_dsnatjur).

        FOR EACH gncdntj WHERE 
                         (IF par_cdnatjur <> 0 THEN 
                          gncdntj.cdnatjur = par_cdnatjur ELSE TRUE) AND
                         gncdntj.dsnatjur MATCHES('*' + par_dsnatjur + '*') 
                         NO-LOCK:

            IF  gncdntj.dsnatjur = "" THEN
                NEXT.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO: 
                   FIND tt-gncdntj OF gncdntj NO-ERROR.
    
                   IF   NOT AVAILABLE tt-gncdntj THEN
                        DO:
                           CREATE tt-gncdntj.
                           BUFFER-COPY gncdntj TO tt-gncdntj.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-setorec:
    /* Pesquisa para SETOR ECONOMICO */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdseteco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsseteco AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-setorec.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, RETURN:
        EMPTY TEMP-TABLE tt-turnos. 

        ASSIGN par_dsseteco = TRIM(par_dsseteco).

        FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper   AND
                               craptab.cdacesso = "SETORECONO"   AND 
                              (IF par_cdseteco <> 0 THEN 
                                craptab.tpregist = par_cdseteco ELSE TRUE) AND
                               craptab.dstextab MATCHES("*" + par_dsseteco + 
                                                        "*") NO-LOCK:

            IF  craptab.dstextab = "" THEN
                NEXT.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO: 
                   FIND tt-setorec WHERE tt-setorec.cdseteco = craptab.tpregist
                                         NO-ERROR.
    
                   IF   NOT AVAILABLE tt-setorec THEN
                        DO:
                           CREATE tt-setorec.
                           ASSIGN 
                               tt-setorec.cdseteco = craptab.tpregist
                               tt-setorec.nmseteco = craptab.dstextab.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-gnrativ:
    /* Pesquisa para RAMO DE ATIVIDADE */

    DEF  INPUT PARAM par_cdseteco AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrmativ AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmrmativ AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-gnrativ.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-gnrativ. 

        ASSIGN par_nmrmativ = TRIM(par_nmrmativ).
        
        FOR EACH gnrativ WHERE gnrativ.cdseteco = par_cdseteco AND
                               (IF par_cdrmativ <> 0 THEN 
                                gnrativ.cdrmativ = par_cdrmativ ELSE TRUE) AND
                               gnrativ.nmrmativ MATCHES("*" + par_nmrmativ + 
                                                        "*") NO-LOCK:

            IF  gnrativ.nmrmativ = "" THEN
                NEXT.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO: 
                   FIND tt-gnrativ OF gnrativ NO-ERROR.
    
                   IF   NOT AVAILABLE tt-gnrativ THEN
                        DO:
                           CREATE tt-gnrativ.
                           BUFFER-COPY gnrativ TO tt-gnrativ.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE busca-gnconve:
    /* Pesquisa do convenio para a DECONV */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdconven AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmempres AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-gnconve.

    ASSIGN aux_nrregist = par_nrregist.


    DO ON ERROR UNDO, LEAVE:

        EMPTY TEMP-TABLE tt-gnconve. 

        ASSIGN par_nmempres = TRIM(par_nmempres).

        FOR EACH gnconve WHERE (IF par_cdconven <> 0 THEN 
                                   gnconve.cdconven = par_cdconven 
                                ELSE TRUE)
                               AND 
                               (IF  par_nmempres <> "" THEN
                                    gnconve.nmempres MATCHES "*" + par_nmempres + "*"
                                ELSE TRUE) NO-LOCK:

            FIND gncvcop WHERE gncvcop.cdcooper = par_cdcooper       AND
                               gncvcop.cdconven = gnconve.cdconven   
                               NO-LOCK NO-ERROR.

            IF   NOT AVAIL gncvcop   THEN
                 NEXT.

            IF   NOT gnconve.flgativo    THEN
                 NEXT.

            IF   NOT gnconve.flgdecla    THEN
                 NEXT.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   CREATE tt-gnconve.
                   BUFFER-COPY gnconve TO tt-gnconve.                   
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

        IF   par_cdconven <> 0     AND 
             par_cdconven <> 900   THEN 
             LEAVE.

        IF   par_nmempres <> ""    AND
             NOT "CARTAO BRADESCO VISA" MATCHES "*" + par_nmempres + "*"  THEN
             LEAVE.
             
        IF   NOT CAN-FIND (FIRST tt-gnconve WHERE
                                 tt-gnconve.cdconven = 900)  THEN
             DO:
                 CREATE tt-gnconve.
                 ASSIGN tt-gnconve.cdconven = 900
                        tt-gnconve.nmempres = "CARTAO BRADESCO VISA"
                        tt-gnconve.flgdecla = YES
                        tt-gnconve.flgativo = YES
                        tt-gnconve.flgautdb = NO
                     
                        par_qtregist = par_qtregist + 1.
             END.   

        LEAVE.

    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE busca-crapnac:
    /* Pesquisa para NACIONALIDADE */

    DEF  INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnacion AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapnac.

    ASSIGN aux_nrregist = par_nrregist.

    Nacion: DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-crapnac.

        ASSIGN par_dsnacion = TRIM(par_dsnacion).

        FOR EACH crapnac WHERE 
                         (IF par_cdnacion <> 0 THEN
                          crapnac.cdnacion = par_cdnacion ELSE TRUE) AND
                         crapnac.dsnacion MATCHES("*" + par_dsnacion + "*") 
                         NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND first tt-crapnac 
                        where crapnac.cdnacion = tt-crapnac.cdnacion 
                        NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapnac THEN
                        DO:
                           CREATE tt-crapnac.
                           BUFFER-COPY crapnac TO tt-crapnac.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE Nacion.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-crapnat:
    /* Pesquisa para NATURALIDADE */

    DEF  INPUT PARAM par_dsnatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapnat.

    ASSIGN aux_nrregist = par_nrregist.

    Natura: DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-crapnat.

        ASSIGN par_dsnatura = TRIM(par_dsnatura).

        FOR EACH crapmun WHERE
                         crapmun.dscidade MATCHES("*" + par_dsnatura + "*")
                         NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-crapnat 
                     WHERE tt-crapnat.dsnatura = crapmun.dscidade NO-ERROR.

                   IF   NOT AVAILABLE tt-crapnat THEN
                        DO:
                           CREATE tt-crapnat.
                           ASSIGN tt-crapnat.dsnatura = crapmun.dscidade.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE Natura.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-gntpnac:
    /* Pesquisa para TIPO NACIONALIDADE */

    DEF  INPUT PARAM par_tpnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_restpnac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-gntpnac.

    ASSIGN aux_nrregist = par_nrregist.

    TpNacion: DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-gntpnac.

        ASSIGN par_restpnac = TRIM(par_restpnac).

        FOR EACH gntpnac WHERE 
                         (IF par_tpnacion <> 0 THEN
                          gntpnac.tpnacion = par_tpnacion ELSE TRUE) AND
                         gntpnac.restpnac MATCHES("*" + par_restpnac + "*") 
                         NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-gntpnac OF gntpnac NO-ERROR.
    
                   IF   NOT AVAILABLE tt-gntpnac THEN
                        DO:
                           CREATE tt-gntpnac.
                           BUFFER-COPY gntpnac TO tt-gntpnac.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE TpNacion.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-crapban:
    /* Pesquisa para BANCOS */
                                              
    DEF  INPUT PARAM par_cdbccxlt AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmextbcc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapban.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-crapban.

        ASSIGN par_nmextbcc = TRIM(par_nmextbcc).

        FOR EACH crapban WHERE 
                         (IF par_cdbccxlt <> 0 THEN
                          crapban.cdbccxlt = par_cdbccxlt ELSE TRUE) AND
                         crapban.nmextbcc MATCHES("*" + par_nmextbcc + "*") 
                         NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND first tt-crapban 
                      where crapban.cdbccxlt = tt-crapban.cdbccxlt
                      NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapban THEN
                        DO:
                           CREATE tt-crapban.
                           BUFFER-COPY crapban TO tt-crapban.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-crapagb:
    /* Pesquisa para AGENCIA */
                                              
    DEF  INPUT PARAM par_cdbccxlt AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageban AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmageban AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapagb.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-crapagb.

        ASSIGN par_nmageban = TRIM(par_nmageban).

        FOR EACH crapagb WHERE 
                         crapagb.cddbanco = par_cdbccxlt AND
                         (IF par_cdageban <> 0 THEN
                          crapagb.cdageban = par_cdageban ELSE TRUE) AND
                         crapagb.nmageban MATCHES("*" + par_nmageban + "*") 
                         NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-crapagb OF crapagb NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapagb THEN
                        DO:
                           CREATE tt-crapagb.
                           BUFFER-COPY crapagb TO tt-crapagb.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-crapifc:
    /* Pesquisa para RELATORIOS */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddfrenv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdperiod AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapifc.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-crapifc.

        FOR EACH crapifc WHERE 
                         crapifc.cdcooper = par_cdcooper AND
                         (IF par_cdrelato <> 0 THEN
                          crapifc.cdrelato = par_cdrelato ELSE TRUE) AND
                         (IF par_cdprogra <> 0 THEN
                          crapifc.cdprogra = par_cdprogra ELSE TRUE) AND
                         (IF par_cddfrenv <> 0 THEN
                          crapifc.cddfrenv = par_cddfrenv ELSE TRUE) AND
                         (IF par_cdperiod <> 0 THEN
                          crapifc.cdperiod = par_cdperiod ELSE TRUE) NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-crapifc OF crapifc NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapifc THEN
                        DO:
                           CREATE tt-crapifc.
                           BUFFER-COPY crapifc TO tt-crapifc.
                        END.

                   FOR FIRST gnrlema FIELDS(nmrelato) 
                       WHERE gnrlema.cdprogra = crapifc.cdprogra AND
                             gnrlema.cdrelato = crapifc.cdrelato NO-LOCK:
                       ASSIGN tt-crapifc.nmrelato = gnrlema.nmrelato.
                   END.

                   FOR FIRST craptab FIELDS(dstextab)
                       WHERE craptab.cdcooper = 0              AND
                             craptab.nmsistem = "CRED"         AND
                             craptab.tptabela = "USUARI"       AND
                             craptab.cdempres = 11             AND
                             craptab.cdacesso = "FORENVINFO"   AND
                             craptab.tpregist = crapifc.cddfrenv NO-LOCK: 
                      tt-crapifc.dsdfrenv = ENTRY(1,craptab.dstextab,",").
                   END.

                   FOR FIRST craptab FIELDS(dstextab)
                       WHERE craptab.cdcooper = 0              AND
                             craptab.nmsistem = "CRED"         AND
                             craptab.tptabela = "USUARI"       AND
                             craptab.cdempres = 11             AND
                             craptab.cdacesso = "PERIODICID"   AND
                             craptab.tpregist = crapifc.cdperiod NO-LOCK:
                       ASSIGN tt-crapifc.dsperiod = craptab.dstextab.
                   END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-crapcem:
    /* Pesquisa para EMAIL */
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddemail AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcem.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-crapcem.

        FOR EACH crapcem WHERE crapcem.cdcooper = par_cdcooper AND
                               crapcem.nrdconta = par_nrdconta AND
                               crapcem.idseqttl = par_idseqttl AND
                               (IF par_cddemail <> 0 THEN 
                                   crapcem.cddemail = par_cddemail 
                                ELSE TRUE) AND 
                               (IF par_dsdemail <> "" THEN 
                                   crapcem.dsdemail = par_dsdemail 
                                ELSE TRUE) NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-crapcem WHERE 
                                   tt-crapcem.cdcooper = crapcem.cdcooper AND
                                   tt-crapcem.nrdconta = crapcem.nrdconta AND
                                   tt-crapcem.idseqttl = crapcem.idseqttl AND
                                   tt-crapcem.dsdemail = crapcem.dsdemail
                                   NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapcem THEN
                        DO:
                           CREATE tt-crapcem.
                           BUFFER-COPY crapcem TO tt-crapcem.
                        END.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-craptfc:
    /* Pesquisa para TELEFONE */
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tptelefo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdseqtfc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craptfc.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-craptfc.

        FOR EACH craptfc WHERE craptfc.cdcooper = par_cdcooper AND
                               craptfc.nrdconta = par_nrdconta AND
                               craptfc.idseqttl = par_idseqttl AND
                               (IF par_tptelefo <> 0 THEN 
                                   craptfc.tptelefo = par_tptelefo 
                                ELSE TRUE)                     AND
                               (IF par_cdseqtfc <> 0 THEN 
                                   craptfc.cdseqtfc = par_cdseqtfc
                                ELSE TRUE) NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-craptfc WHERE 
                                   tt-craptfc.cdcooper = craptfc.cdcooper AND
                                   tt-craptfc.nrdconta = craptfc.nrdconta AND
                                   tt-craptfc.idseqttl = craptfc.idseqttl AND
                                   tt-craptfc.tptelefo = craptfc.tptelefo 
                                   NO-ERROR.
    
                   IF   NOT AVAILABLE tt-craptfc THEN
                        DO:
                           CREATE tt-craptfc.
                           BUFFER-COPY craptfc TO tt-craptfc.
                        END.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-crapenc:
    /* Pesquisa para ENDERECO */
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdseqinc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpendass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapenc.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-crapenc.

        FOR EACH crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                               crapenc.nrdconta = par_nrdconta AND
                               crapenc.idseqttl = par_idseqttl AND
                               crapenc.tpendass = par_tpendass AND 
                               (IF par_cdseqinc <> 0 THEN 
                                   crapenc.cdseqinc = par_cdseqinc 
                                ELSE TRUE) NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-crapenc WHERE
                                   tt-crapenc.cdcooper = crapenc.cdcooper AND
                                   tt-crapenc.nrdconta = crapenc.nrdconta AND
                                   tt-crapenc.idseqttl = crapenc.idseqttl AND
                                   tt-crapenc.tpendass = crapenc.tpendass
                                   NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapenc THEN
                        DO:
                           CREATE tt-crapenc.
                           BUFFER-COPY crapenc TO tt-crapenc.
                        END.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-craprad:
    /* Pesquisa para INFORMATIVOS/PATRIMONIO/PERCEPCAO GERAL */
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtopico AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nritetop AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqite AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsseqite AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgcompl AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craprad.
    
    DEF VAR aux_dssequte AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdindex AS INTE                                    NO-UNDO.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-craprad.

        ASSIGN par_dsseqite = TRIM(par_dsseqite).

        FOR EACH craprad WHERE 
                         craprad.cdcooper = par_cdcooper AND
                         craprad.nrtopico = par_nrtopico AND
                         craprad.nritetop = par_nritetop AND
                         (IF par_nrseqite <> 0 THEN
                            craprad.nrseqite = par_nrseqite ELSE TRUE) AND
                         (IF par_dsseqite <> "" THEN
                            craprad.dsseqite MATCHES("*" + par_dsseqite + "*")
                          ELSE TRUE) NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-craprad OF craprad NO-ERROR.
    
                   IF   NOT AVAILABLE tt-craprad THEN
                       DO:
                           CREATE tt-craprad.

                           IF par_flgcompl THEN
                               DO:
                                   BUFFER-COPY craprad TO tt-craprad
                                       ASSIGN tt-craprad.dsseqit1 = 
                                                              craprad.dsseqite.
                               END.
                           ELSE
                               DO:
                                   IF (par_nrtopico = 1  AND
                                       par_nritetop = 8) OR
                                      (par_nrtopico = 3  AND
                                       par_nritetop = 9) THEN
                                       aux_dssequte = 
                                             REPLACE(craprad.dsseqite,"..","").
                                   ELSE
                                       DO:
                                           /* Verifica se tem um '.' 
                                              na descricao   */
                                           aux_nrdindex = 
                                               INDEX(craprad.dsseqite,".").  
                                                    
                                           /* Se tem, pegar ate ele */
                                           IF aux_nrdindex  >= 1  THEN 
                                              aux_dssequte = 
                                    SUBSTRING(craprad.dsseqite,1,aux_nrdindex).
                                           ELSE      
                                               aux_dssequte = craprad.dsseqite.
                                       END.
                                    BUFFER-COPY craprad 
                                        EXCEPT dsseqite TO tt-craprad 
                                        ASSIGN  tt-craprad.dsseqit1 = 
                                                                   aux_dssequte
                                                tt-craprad.dsseqite = 
                                                              craprad.dsseqite.

                               END.
                       END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.         

PROCEDURE busca-recebto:
    /* Pesquisa para RECEBIMENTO */
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddfrenv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdseqinc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-recebto.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-recebto.

        FOR FIRST craptab FIELDS(dstextab) 
                          WHERE 
                          craptab.cdcooper = 0            AND
                          craptab.nmsistem = "CRED"       AND
                          craptab.tptabela = "USUARI"     AND
                          craptab.cdempres = 11           AND
                          craptab.cdacesso = "FORENVINFO" AND
                          craptab.tpregist = par_cddfrenv NO-LOCK:

            CASE ENTRY(2,craptab.dstextab,","):
                WHEN "crapcem" THEN DO:
                    RUN busca-crapcem 
                        ( INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT par_cdseqinc,
                          INPUT "",
                          INPUT par_nrregist,
                          INPUT par_nriniseq,
                         OUTPUT par_qtregist,
                         OUTPUT TABLE tt-crapcem ).

                    FOR EACH tt-crapcem:
                        CREATE tt-recebto.
                        ASSIGN 
                            tt-recebto.cddfrenv = par_cddfrenv
                            tt-recebto.dsdfrenv = ENTRY(1,craptab.dstextab,",")
                            tt-recebto.cdrecebe = tt-crapcem.cddemail
                            tt-recebto.dsrecebe = tt-crapcem.dsdemail.
                    END.
                END.

                WHEN "craptfc" THEN DO:
                    RUN busca-craptfc
                        ( INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT par_cdseqinc,
                          INPUT par_nrregist,
                          INPUT par_nriniseq,
                         OUTPUT par_qtregist,
                         OUTPUT TABLE tt-craptfc ).

                    FOR EACH tt-craptfc:
                        CREATE tt-recebto.
                        ASSIGN 
                            tt-recebto.cddfrenv = par_cddfrenv
                            tt-recebto.dsdfrenv = ENTRY(1,craptab.dstextab,",")
                            tt-recebto.cdrecebe = tt-craptfc.cdseqtfc
                            tt-recebto.dsrecebe = STRING(tt-craptfc.nrtelefo).
                    END.
                END.

                WHEN "crapenc" THEN DO:
                    RUN busca-crapenc
                        ( INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT par_cdseqinc,
                          INPUT 12,
                          INPUT par_nrregist,
                          INPUT par_nriniseq,
                         OUTPUT par_qtregist,
                         OUTPUT TABLE tt-crapenc ).

                    IF  NOT TEMP-TABLE tt-crapenc:HAS-RECORDS THEN
                        RUN busca-crapenc
                            ( INPUT par_cdcooper,
                              INPUT par_nrdconta,
                              INPUT par_idseqttl,
                              INPUT par_cdseqinc,
                              INPUT 10,
                              INPUT par_nrregist,
                              INPUT par_nriniseq,
                             OUTPUT par_qtregist,
                             OUTPUT TABLE tt-crapenc ).

                    FOR EACH tt-crapenc:
                        CREATE tt-recebto.
                        ASSIGN 
                            tt-recebto.cddfrenv = par_cddfrenv
                            tt-recebto.dsdfrenv = ENTRY(1,craptab.dstextab,",")
                            tt-recebto.cdrecebe = tt-crapenc.cdseqinc
                            tt-recebto.dsrecebe = STRING(tt-crapenc.dsendere).
                    END.
                END.
            END CASE.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-tpimovel:
    /* Pesquisa para TIPO DE IMOVEL */

    DEF  INPUT PARAM par_incasprp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dscasprp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-tpimovel.

    DEF VAR aux_contador          AS INTE                           NO-UNDO.
    DEF VAR aux_dscasprp          AS CHAR                           NO-UNDO.

    ASSIGN 
        aux_nrregist = par_nrregist
        aux_dscasprp = "1-QUITADO,2-FINANC,3-ALUGADO,4-FAMILIAR,5-CEDIDO".

    DO ON ERROR UNDO, RETURN:
        EMPTY TEMP-TABLE tt-tpimovel. 

        DO aux_contador = 1 TO NUM-ENTRIES(aux_dscasprp):
            IF  par_dscasprp <> "" AND 
                NOT(par_dscasprp MATCHES ("*" + 
                                          ENTRY(aux_contador,aux_dscasprp) + 
                                          "*"))  THEN
                NEXT.
                                              
            CREATE tt-tpimovel.
            ASSIGN 
                tt-tpimovel.incasprp = aux_contador
                tt-tpimovel.dscasprp = ENTRY(aux_contador,aux_dscasprp)
                par_qtregist         = par_qtregist + 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-crapage:
    /* Pesquisa para PAC */
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsagepac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapage.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-crapagb.

        ASSIGN par_dsagepac = TRIM(par_dsagepac).

        FOR EACH crapage WHERE 
                         crapage.cdcooper = par_cdcooper AND
                         (IF par_cdagepac <> 0 THEN
                          crapage.cdagenci = par_cdagepac ELSE TRUE) AND
                         crapage.nmresage MATCHES("*" + par_dsagepac + "*") 
                         NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-crapage WHERE 
                                   tt-crapage.cdcooper = crapage.cdcooper AND
                                   tt-crapage.cdagepac = crapage.cdagenci
                                   NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapage THEN
                        DO:
                           CREATE tt-crapage.
                           ASSIGN
                               tt-crapage.cdcooper = crapage.cdcooper
                               tt-crapage.cdagepac = crapage.cdagenci
                               tt-crapage.dsagepac = crapage.nmresage.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-crapdes:
    /* Pesquisa para DESTINO DO EXTRATO */
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsecext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dssecext AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapdes.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-crapagb.

        ASSIGN par_dssecext = TRIM(par_dssecext).

        FOR EACH crapdes WHERE 
                         crapdes.cdcooper = par_cdcooper AND
                         crapdes.cdagenci = par_cdagepac AND
                         (IF par_cdsecext <> 0 THEN
                          crapdes.cdsecext = par_cdsecext ELSE TRUE) AND
                         crapdes.nmsecext MATCHES("*" + par_dssecext + "*") 
                         NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-crapdes WHERE 
                                   tt-crapdes.cdcooper = crapdes.cdcooper AND
                                   tt-crapdes.cdagepac = crapdes.cdagenci AND
                                   tt-crapdes.cdsecext = crapdes.cdsecext
                                   NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapdes THEN
                        DO:
                           CREATE tt-crapdes.
                           ASSIGN
                               tt-crapdes.cdcooper = crapdes.cdcooper
                               tt-crapdes.cdagepac = crapdes.cdagenci
                               tt-crapdes.cdsecext = crapdes.cdsecext
                               tt-crapdes.dssecext = crapdes.nmsecext
                               tt-crapdes.indespac = crapdes.indespac.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE busca-craptip:
    /* Pesquisa para TIPO DA CONTA */
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dstipcta AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craptip.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-crapagb.

        ASSIGN par_dstipcta = TRIM(par_dstipcta).

        FOR EACH craptip WHERE 
                         craptip.cdcooper = par_cdcooper AND
                         (IF par_cdtipcta <> 0 THEN
                          craptip.cdtipcta = par_cdtipcta ELSE TRUE) AND
                         craptip.dstipcta MATCHES("*" + par_dstipcta + "*") 
                         NO-LOCK:

            /* DESPREZAR TIPOS DE CONTA BB QUE UTILIZAM CHEQUE - GUILHERME */
            IF  craptip.cdtipcta >= 12  AND
                craptip.cdtipcta <= 15  THEN
                NEXT.
                          
            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND FIRST tt-craptip OF craptip NO-ERROR.
    
                   IF   NOT AVAILABLE tt-craptip THEN
                        DO:
                           CREATE tt-craptip.
                           BUFFER-COPY craptip TO tt-craptip.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE zoom-associados:

    

    /* Busca dados dos associados para Zoom/Pesquisa, logica extraida
       da procedure zoom-associados, b1wgen0001.p */

    DEF INPUT  PARAM par_cdcooper AS INTE NO-UNDO.                   
    DEF INPUT  PARAM par_cdagpesq AS INTE NO-UNDO. /** 0-TODOS           **/
    DEF INPUT  PARAM par_cdpesqui AS INTE NO-UNDO. /** 1-NMTTL, 2-CT.ITG, 3-CPFCNPJ **/
    DEF INPUT  PARAM par_nmdbusca AS CHAR NO-UNDO. /** NOME A PESQUISAR  **/
    DEF INPUT  PARAM par_tpdapesq AS INTE NO-UNDO. /** 0-TTL 1-CJE 2-PAI **/
                                                   /** 3-MAE 4-JUR       **/
    DEF INPUT  PARAM par_nrdctitg AS CHAR NO-UNDO. 
    DEF INPUT  PARAM par_tpdorgan AS INT  NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc AS DEC  NO-UNDO.
    DEF INPUT  PARAM par_flgpagin AS LOGI NO-UNDO.
    DEF INPUT  PARAM par_nrregist AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nriniseq AS INTE NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-titular2.
    

    DEF VAR par_qtcopera AS INTE NO-UNDO.
    DEF VAR aux_etime as INTE       no-undo.
    DEF VAR aux_inpessoa AS INTE    NO-UNDO.
    DEF VAR aux_cdagenci AS INTE    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-titular.
    EMPTY TEMP-TABLE tt-titular2.
    
    IF  par_cdpesqui = 1 THEN
        DO:
           IF  par_nmdbusca = ""  THEN
               RETURN. 
        
           ASSIGN par_nmdbusca = REPLACE(RIGHT-TRIM(par_nmdbusca," ") + "*"," ","* *").

           CASE par_tpdapesq:
               WHEN 0 THEN DO: /* Titular */


                  FOR EACH crapttl FIELDS(cdcooper nrdconta nmextttl
                                           idseqttl nrcpfcgc cdempres
                                           dtnasttl  ) 
                            WHERE crapttl.cdcooper = par_cdcooper AND
                                  crapttl.nmextttl MATCHES ("*" + par_nmdbusca + "*")
                                  NO-LOCK,    
                       EACH crapass FIELDS(cdagenci nrdctitg dtdemiss
                                           nmprimtl dsnivris)
                            WHERE crapass.cdcooper = crapttl.cdcooper AND
                                  crapass.nrdconta = crapttl.nrdconta AND
                                  (IF par_cdagpesq <> 0 THEN 
                                      crapass.cdagenci = par_cdagpesq 
                                   ELSE TRUE) NO-LOCK: /* BY (IF par_tpdorgan = 1 THEN
                                                          crapttl.nmextttl ELSE
                                                          STRING(crapttl.nrdconta,"zzzzzz99")): */
                                                                              
                       ASSIGN par_qtregist = par_qtregist + 1.                

                       /* controles da paginaçao */
                       IF  par_flgpagin AND ((par_qtregist < par_nriniseq) OR
                           (par_qtregist > (par_nriniseq + par_nrregist))) THEN
                           NEXT.
                       
                       
                       CREATE tt-titular.
                       ASSIGN 
                           tt-titular.cdcooper = crapttl.cdcooper
                           tt-titular.nrdconta = crapttl.nrdconta
                           tt-titular.cdagenci = crapass.cdagenci
                           tt-titular.nmextttl = crapttl.nmextttl
                           tt-titular.nrdctitg = crapass.nrdctitg
                           tt-titular.idseqttl = crapttl.idseqttl
                           tt-titular.dtnasttl = crapttl.dtnasttl
                           tt-titular.dtdemiss = crapass.dtdemiss
                           tt-titular.cdempres = crapttl.cdempres
                           tt-titular.nmpesttl = tt-titular.nmextttl
                           tt-titular.nmprimtl = tt-titular.nmextttl
						   tt-titular.dsnivris = (IF TRIM(crapass.dsnivris) = "" THEN
									                  "A"
										  		  ELSE
													  crapass.dsnivris)
                           tt-titular.nrdocttl = STRING(STRING
                                                        (crapttl.nrcpfcgc,
                                                        "99999999999"),
                                                        "xxx.xxx.xxx-xx").
                        
                       FOR FIRST crapage FIELDS(nmresage)
                           WHERE crapage.cdcooper = tt-titular.cdcooper AND
                                 crapage.cdagenci = tt-titular.cdagenci 
                                 NO-LOCK:
                           ASSIGN tt-titular.dsagenci = crapage.nmresage.
                       END.
                   END.
               END.
               WHEN 1 THEN DO: /* Conjuge */
                   FOR EACH crapcje WHERE crapcje.cdcooper = crapttl.cdcooper AND                         
                                          crapcje.nrdconta = crapttl.nrdconta AND 
                                          crapcje.nmconjug MATCHES ("*" + par_nmdbusca + "*") AND
                                          crapcje.idseqttl = 1 
                                          USE-INDEX crapcje1 NO-LOCK,
                       EACH crapttl FIELDS(cdcooper nrdconta 
                                           idseqttl nrcpfcgc cdempres
                                           dtnasttl )
                                    WHERE crapttl.cdcooper = par_cdcooper NO-LOCK,                       
                       EACH crapass FIELDS(cdagenci nrdctitg dtdemiss dsnivris)
                            WHERE crapass.cdcooper = crapttl.cdcooper AND
                                  crapass.nrdconta = crapttl.nrdconta AND
                                  (IF par_cdagpesq <> 0 THEN 
                                      crapass.cdagenci = par_cdagpesq 
                                   ELSE TRUE) NO-LOCK: /* BY (IF par_tpdorgan = 1 THEN
                                                          crapttl.nmconjug ELSE
                                                          STRING(crapass.nrdconta, "zzzzzz99")): */
                        
                                                          
                       ASSIGN par_qtregist = par_qtregist + 1.
                     

                       /* controles da paginaçao */
                       IF  par_flgpagin AND ((par_qtregist < par_nriniseq) OR
                           (par_qtregist > (par_nriniseq + par_nrregist))) THEN
                           NEXT.

                       CREATE tt-titular.
                       ASSIGN 
                           tt-titular.cdcooper = crapttl.cdcooper
                           tt-titular.nrdconta = crapttl.nrdconta
                           tt-titular.cdagenci = crapass.cdagenci 
                           tt-titular.nmextttl = crapcje.nmconjug  
                           tt-titular.nrdctitg = crapass.nrdctitg
                           tt-titular.idseqttl = crapttl.idseqttl
                           tt-titular.dtnasttl = crapttl.dtnasttl
                           tt-titular.dtdemiss = crapass.dtdemiss
                           tt-titular.cdempres = crapttl.cdempres
                           tt-titular.nmpesttl = tt-titular.nmextttl + "(Conj)"
                           tt-titular.nmprimtl = tt-titular.nmextttl
						   tt-titular.dsnivris = (IF TRIM(crapass.dsnivris) = "" THEN
									                 "A"
												  ELSE
												     crapass.dsnivris)
                           tt-titular.nrdocttl = STRING(STRING
                                                        (crapttl.nrcpfcgc, 
                                                        "99999999999"),
                                                        "xxx.xxx.xxx-xx").

                       FOR FIRST crapage FIELDS(nmresage)
                           WHERE crapage.cdcooper = tt-titular.cdcooper AND
                                 crapage.cdagenci = tt-titular.cdagenci 
                                 NO-LOCK:
                           ASSIGN tt-titular.dsagenci = crapage.nmresage.
                       END.
                   END.
               END.
               WHEN 2 THEN DO: /* Nome do pai */
                   FOR EACH crapttl FIELDS(cdcooper nrdconta nmpaittl
                                           idseqttl nrcpfcgc cdempres
                                           dtnasttl )
                            WHERE crapttl.cdcooper = par_cdcooper AND
                                  crapttl.nmpaittl MATCHES ("*" + par_nmdbusca + "*")
                       NO-LOCK,
                       EACH crapass FIELDS(cdagenci nrdctitg dtdemiss dsnivris)
                            WHERE crapass.cdcooper = crapttl.cdcooper AND
                                  crapass.nrdconta = crapttl.nrdconta AND
                                  (IF par_cdagpesq <> 0 THEN 
                                      crapass.cdagenci = par_cdagpesq 
                                   ELSE TRUE) NO-LOCK: /* BY (IF par_tpdorgan = 1 THEN
                                                          crapttl.nmpaittl ELSE
                                                          STRING(crapttl.nrdconta, "zzzzzz99")): */

                       ASSIGN par_qtregist = par_qtregist + 1.
                      

                       /* controles da paginaçao */
                       IF  par_flgpagin AND ((par_qtregist < par_nriniseq) OR
                           (par_qtregist > (par_nriniseq + par_nrregist))) THEN
                           NEXT.

                       CREATE tt-titular.
                       ASSIGN 
                           tt-titular.cdcooper = crapttl.cdcooper
                           tt-titular.nrdconta = crapttl.nrdconta
                           tt-titular.cdagenci = crapass.cdagenci 
                           tt-titular.nmextttl = crapttl.nmpaittl  
                           tt-titular.nrdctitg = crapass.nrdctitg
                           tt-titular.idseqttl = crapttl.idseqttl
                           tt-titular.dtnasttl = crapttl.dtnasttl
                           tt-titular.dtdemiss = crapass.dtdemiss
                           tt-titular.cdempres = crapttl.cdempres
                           tt-titular.nmpesttl = tt-titular.nmextttl + "(PAI)"
                           tt-titular.nmprimtl = tt-titular.nmextttl
						   tt-titular.dsnivris = (IF TRIM(crapass.dsnivris) = "" THEN
									                  "A"
											   	  ELSE
													  crapass.dsnivris)
                           tt-titular.nrdocttl = STRING(STRING
                                                        (crapttl.nrcpfcgc,
                                                        "99999999999"),
                                                        "xxx.xxx.xxx-xx").

                       FOR FIRST crapage FIELDS(nmresage)
                           WHERE crapage.cdcooper = tt-titular.cdcooper AND
                                 crapage.cdagenci = tt-titular.cdagenci 
                                 NO-LOCK:
                           ASSIGN tt-titular.dsagenci = crapage.nmresage.
                       END.
                   END.
               END.
               WHEN 3 THEN DO: /* Nome da mae */
                   FOR EACH crapttl FIELDS(cdcooper nrdconta nmmaettl
                                           idseqttl nrcpfcgc cdempres
                                           dtnasttl )
                            WHERE crapttl.cdcooper = par_cdcooper AND
                                  crapttl.nmmaettl MATCHES ("*" + par_nmdbusca + "*")
                                  NO-LOCK,
                       EACH crapass FIELDS(cdagenci nrdctitg dtdemiss dsnivris)
                            WHERE crapass.cdcooper = crapttl.cdcooper AND
                                  crapass.nrdconta = crapttl.nrdconta AND
                                  (IF par_cdagpesq <> 0 THEN 
                                      crapass.cdagenci = par_cdagpesq 
                                   ELSE TRUE) NO-LOCK: /* BY (IF par_tpdorgan = 1 THEN
                                                          crapttl.nmmaettl ELSE
                                                          STRING(crapttl.nrdconta, "zzzzzz99")): */

                       ASSIGN par_qtregist = par_qtregist + 1.
                      

                       /* controles da paginaçao */
                       IF  par_flgpagin AND ((par_qtregist < par_nriniseq) OR
                           (par_qtregist > (par_nriniseq + par_nrregist))) THEN
                           NEXT.

                       CREATE tt-titular.
                       ASSIGN 
                           tt-titular.cdcooper = crapttl.cdcooper
                           tt-titular.nrdconta = crapttl.nrdconta
                           tt-titular.cdagenci = crapass.cdagenci 
                           tt-titular.nmextttl = crapttl.nmmaettl  
                           tt-titular.nrdctitg = crapass.nrdctitg
                           tt-titular.idseqttl = crapttl.idseqttl
                           tt-titular.dtnasttl = crapttl.dtnasttl
                           tt-titular.dtdemiss = crapass.dtdemiss
                           tt-titular.cdempres = crapttl.cdempres
                           tt-titular.nmpesttl = tt-titular.nmextttl + "(MAE)"
                           tt-titular.nmprimtl = tt-titular.nmextttl
						   tt-titular.dsnivris = (IF TRIM(crapass.dsnivris) = "" THEN
									                 "A"
											 	  ELSE
													 crapass.dsnivris)
                           tt-titular.nrdocttl = STRING(STRING
                                                        (crapttl.nrcpfcgc, 
                                                        "99999999999"),
                                                        "xxx.xxx.xxx-xx").

                       FOR FIRST crapage FIELDS(nmresage)
                           WHERE crapage.cdcooper = tt-titular.cdcooper AND
                                 crapage.cdagenci = tt-titular.cdagenci 
                                 NO-LOCK:
                           ASSIGN tt-titular.dsagenci = crapage.nmresage.
                       END.
                   END.
               END.
               WHEN 4 THEN DO: /* Pessoa Juridica */
                   FOR EACH crapjur FIELDS(cdcooper nrdconta nmextttl cdempres)
                            WHERE crapjur.cdcooper = par_cdcooper AND
                                  crapjur.nmextttl MATCHES ("*" + par_nmdbusca + "*")
                                  NO-LOCK,
                       EACH crapass FIELDS(cdagenci nrdctitg dtdemiss nrcpfcgc dsnivris)
                            WHERE crapass.cdcooper = crapjur.cdcooper AND
                                  crapass.nrdconta = crapjur.nrdconta AND
                                  (IF par_cdagpesq <> 0 THEN 
                                      crapass.cdagenci = par_cdagpesq 
                                   ELSE TRUE) NO-LOCK: /* BY (IF par_tpdorgan = 1 THEN
                                                          crapjur.nmextttl ELSE
                                                          STRING(crapjur.nrdconta, "zzzzzz99")): */

                       ASSIGN par_qtregist = par_qtregist + 1.
                      

                       /* controles da paginaçao */
                       IF  par_flgpagin AND ((par_qtregist < par_nriniseq) OR
                           (par_qtregist > (par_nriniseq + par_nrregist))) THEN
                           NEXT.

                       CREATE tt-titular.
                       ASSIGN 
                           tt-titular.cdcooper = crapjur.cdcooper
                           tt-titular.nrdconta = crapjur.nrdconta
                           tt-titular.cdagenci = crapass.cdagenci 
                           tt-titular.nmextttl = crapjur.nmextttl  
                           tt-titular.nrdctitg = crapass.nrdctitg
                           tt-titular.dtdemiss = crapass.dtdemiss
                           tt-titular.cdempres = crapjur.cdempres
                           tt-titular.nmpesttl = tt-titular.nmextttl
                           tt-titular.nmprimtl = tt-titular.nmextttl
						   tt-titular.dsnivris = (IF TRIM(crapass.dsnivris) = "" THEN
									                 "A"
												  ELSE
													 crapass.dsnivris)
                           tt-titular.nrdocttl = STRING(STRING
                                                        (crapass.nrcpfcgc,
                                                         "99999999999999"),
                                                        "xx.xxx.xxx/xxxx-xx").

                       FOR FIRST crapage FIELDS(nmresage)
                           WHERE crapage.cdcooper = tt-titular.cdcooper AND
                                 crapage.cdagenci = tt-titular.cdagenci 
                                 NO-LOCK:
                           ASSIGN tt-titular.dsagenci = crapage.nmresage.
                       END.

                   END. /* Fim do FOR EACH crapjur */
                    
                   /* buscar pelo nome de fantasia */
                   FOR EACH crapjur FIELDS(cdcooper nrdconta nmfansia cdempres)
                            WHERE crapjur.cdcooper = par_cdcooper AND
                                  crapjur.nmfansia MATCHES ("*" + par_nmdbusca + "*")
                                  NO-LOCK,
                       EACH crapass FIELDS(cdagenci nrdctitg dtdemiss nrcpfcgc inpessoa dsnivris)
                            WHERE crapass.cdcooper = crapjur.cdcooper AND
                                  crapass.nrdconta = crapjur.nrdconta AND
                                  (IF par_cdagpesq <> 0 THEN 
                                      crapass.cdagenci = par_cdagpesq 
                                   ELSE TRUE) NO-LOCK: /* BY (IF par_tpdorgan = 1 THEN
                                                          crapjur.nmfansia ELSE
                                                          STRING(crapjur.nrdconta, "zzzzzz99")): */
                           
                           ASSIGN aux_inpessoa = crapass.inpessoa
                                  aux_cdagenci = crapass.cdagenci.
                       
                       FIND FIRST tt-titular WHERE 
                            tt-titular.cdcooper = crapjur.cdcooper AND
                            tt-titular.nrdconta = crapjur.nrdconta 
                            NO-LOCK NO-ERROR.

                       IF  AVAILABLE tt-titular THEN
                           NEXT.

                       ASSIGN par_qtregist = par_qtregist + 1.
                      

                       /* controles da paginaçao */
                       IF  par_flgpagin AND ((par_qtregist < par_nriniseq) OR
                           (par_qtregist > (par_nriniseq + par_nrregist))) THEN
                           NEXT.

                       CREATE tt-titular.
                       ASSIGN 
                           tt-titular.cdcooper = crapjur.cdcooper
                           tt-titular.nrdconta = crapjur.nrdconta
                           tt-titular.cdagenci = crapass.cdagenci 
                           tt-titular.nmextttl = crapjur.nmfansia  
                           tt-titular.nrdctitg = crapass.nrdctitg
                           tt-titular.dtdemiss = crapass.dtdemiss
                           tt-titular.cdempres = crapjur.cdempres
                           tt-titular.nmpesttl = tt-titular.nmextttl
                           tt-titular.nmprimtl = tt-titular.nmextttl
						   tt-titular.dsnivris = (IF TRIM(crapass.dsnivris) = "" THEN
									                 "A"
												  ELSE
													 crapass.dsnivris)
                           tt-titular.nrdocttl = STRING(STRING
                                                        (crapass.nrcpfcgc,
                                                         "99999999999999"),
                                                        "xx.xxx.xxx/xxxx-xx").

                       FOR FIRST crapage FIELDS(nmresage)
                           WHERE crapage.cdcooper = tt-titular.cdcooper AND
                                 crapage.cdagenci = tt-titular.cdagenci 
                                 NO-LOCK:
                           ASSIGN tt-titular.dsagenci = crapage.nmresage.
                       END.

                   END. /* Fim do FOR EACH crapjur - fantasia */
               END.
               
               END CASE.
               
                aux_etime = etime / 1000.

               RUN log-nome-assciado
               (INPUT TODAY,
                INPUT par_nmdbusca,
                INPUT aux_inpessoa,
                INPUT aux_cdagenci, 
                INPUT par_tpdorgan,
                INPUT aux_etime).  

        END. /* Fim do tipo de pesquisa 1 */   
       ELSE
        IF  par_cdpesqui = 2 THEN
            DO:
               /* Arruma os caracteres */
               DO WHILE LENGTH(par_nrdctitg) < 8:
                  par_nrdctitg = "0" + par_nrdctitg.
               END.
    
               IF  par_nrdctitg = "00000000"   THEN
                   DO:
                      FOR EACH crapass FIELDS(cdcooper nrdconta cdagenci dtdemiss 
                                              inpessoa nrdctitg inpessoa nrcpfcgc dsnivris)
                                       WHERE crapass.cdcooper = par_cdcooper AND
                                             crapass.nrdctitg = ""
                                             NO-LOCK: /*
                                             BY (IF par_tpdorgan = 1 THEN
                                                 crapass.nmprimtl ELSE
                                                 STRING(crapass.nrdconta,"zzzzzz99")): */
                             
                   ASSIGN aux_inpessoa = crapass.inpessoa
                          aux_cdagenci = crapass.cdagenci.
                         
                          IF  crapass.inpessoa = 1 THEN
                              DO:            
                                 FOR FIRST crapttl FIELDS(nmextttl nrdconta idseqttl
                                                          dtnasttl 
                                                          cdempres nrcpfcgc)
                                     WHERE crapttl.cdcooper = par_cdcooper     AND
                                           crapttl.nrdconta = crapass.nrdconta AND
                                           crapttl.idseqttl = 1 NO-LOCK:
                                        
                                     ASSIGN par_qtregist = par_qtregist + 1.
                                   
                                     /* controles da paginaçao */
                                     IF  par_flgpagin AND 
                                         ((par_qtregist < par_nriniseq) OR
                                         (par_qtregist > 
                                          (par_nriniseq + par_nrregist))) THEN
                                         NEXT.
                                    
                                     CREATE tt-titular.
                                     ASSIGN 
                                         tt-titular.cdcooper = crapass.cdcooper
                                         tt-titular.nrdconta = crapass.nrdconta
                                         tt-titular.cdagenci = crapass.cdagenci 
                                         tt-titular.nrdctitg = crapass.nrdctitg
                                         tt-titular.dtdemiss = crapass.dtdemiss
                                         tt-titular.nmextttl = crapttl.nmextttl  
                                         tt-titular.idseqttl = crapttl.idseqttl  
                                         tt-titular.dtnasttl = crapttl.dtnasttl
                                         tt-titular.cdempres = crapttl.cdempres
                                         tt-titular.nmpesttl = tt-titular.nmextttl
                                         tt-titular.nmprimtl = tt-titular.nmextttl
										 tt-titular.dsnivris = (IF TRIM(crapass.dsnivris) = "" THEN
									                               "A"
														     	ELSE
															       crapass.dsnivris)
                                         tt-titular.nrdocttl = STRING(STRING
                                                                (crapttl.nrcpfcgc, 
                                                                 "99999999999"),
                                                               "xxx.xxx.xxx-xx").
    
                                     FOR FIRST crapage FIELDS(nmresage)
                                         WHERE 
                                         crapage.cdcooper = tt-titular.cdcooper AND
                                         crapage.cdagenci = tt-titular.cdagenci 
                                         NO-LOCK:
                                         tt-titular.dsagenci = crapage.nmresage.
                                     END.
                                 END.
                              END.        
                          ELSE
                              DO:
                                 FOR FIRST crapjur FIELDS(nmextttl cdempres)
                                     WHERE crapjur.cdcooper = par_cdcooper     AND
                                           crapjur.nrdconta = crapass.nrdconta 
                                           NO-LOCK:
    
                                     ASSIGN par_qtregist = par_qtregist + 1.
                                    
                                     /* controles da paginaçao */
                                     IF  par_flgpagin AND 
                                         ((par_qtregist < par_nriniseq) OR
                                         (par_qtregist > 
                                          (par_nriniseq + par_nrregist))) THEN
                                         NEXT.
    
                                     CREATE tt-titular.
                                     ASSIGN 
                                         tt-titular.cdcooper = crapass.cdcooper
                                         tt-titular.cdagenci = crapass.cdagenci
                                         tt-titular.nrdconta = crapass.nrdconta
                                         tt-titular.nrdctitg = crapass.nrdctitg
                                         tt-titular.dtdemiss = crapass.dtdemiss
                                         tt-titular.nmextttl = crapjur.nmextttl
                                         tt-titular.cdempres = crapjur.cdempres
                                         tt-titular.nmpesttl = tt-titular.nmextttl
                                         tt-titular.nmprimtl = tt-titular.nmextttl
										 tt-titular.dsnivris = (IF TRIM(crapass.dsnivris) = "" THEN
									                               "A"
															    ELSE
															       crapass.dsnivris)
                                         tt-titular.nrdocttl = STRING(STRING
                                                                (crapass.nrcpfcgc,
                                                                 "99999999999999"),
                                                             "xx.xxx.xxx/xxxx-xx").
    
                                     FOR FIRST crapage FIELDS(nmresage)
                                         WHERE 
                                         crapage.cdcooper = tt-titular.cdcooper AND
                                         crapage.cdagenci = tt-titular.cdagenci 
                                         NO-LOCK:
                                         tt-titular.dsagenci = crapage.nmresage.
                                     END.
                                 END.
                              END.
                      
                      END. /* Fim do FOR EACH */
    
                   END. /* Fim da Cta.ITG = "00000000" */
               ELSE 
                   FOR EACH crapass FIELDS(cdcooper cdagenci nrdctitg inpessoa
                                           dtdemiss nrdconta nrcpfcgc dsnivris)
                                    WHERE crapass.cdcooper = par_cdcooper AND
                                          crapass.nrdctitg = par_nrdctitg
                                          NO-LOCK USE-INDEX crapass7:
                   
                   ASSIGN aux_inpessoa = crapass.inpessoa
                          aux_cdagenci = crapass.cdagenci.

                        IF  crapass.inpessoa = 1 THEN /* Pessoa Fisica */
                            DO:
                               FOR FIRST crapttl FIELDS(nmextttl idseqttl
                                                        dtnasttl 
                                                        cdempres nrcpfcgc)
                                   WHERE crapttl.cdcooper = par_cdcooper     AND
                                         crapttl.nrdconta = crapass.nrdconta AND
                                         crapttl.idseqttl = 1 NO-LOCK:
    
                                   ASSIGN par_qtregist = par_qtregist + 1.
                                 
    
                                   /* controles da paginaçao */
                                   IF  par_flgpagin AND 
                                       ((par_qtregist < par_nriniseq) OR
                                       (par_qtregist > 
                                        (par_nriniseq + par_nrregist))) THEN
                                       NEXT.
    
                                   CREATE tt-titular.
                                   ASSIGN 
                                       tt-titular.cdcooper = crapass.cdcooper
                                       tt-titular.nrdconta = crapass.nrdconta
                                       tt-titular.cdagenci = crapass.cdagenci 
                                       tt-titular.nrdctitg = crapass.nrdctitg
                                       tt-titular.dtdemiss = crapass.dtdemiss
                                       tt-titular.nmextttl = crapttl.nmextttl  
                                       tt-titular.idseqttl = crapttl.idseqttl  
                                       tt-titular.dtnasttl = crapttl.dtnasttl
                                       tt-titular.cdempres = crapttl.cdempres
                                       tt-titular.nmpesttl = tt-titular.nmextttl
                                       tt-titular.nmprimtl = tt-titular.nmextttl
									   tt-titular.dsnivris = (IF TRIM(crapass.dsnivris) = "" THEN
									                             "A"
															  ELSE
															     crapass.dsnivris)
                                       tt-titular.nrdocttl = STRING(STRING
                                                             (crapttl.nrcpfcgc,
                                                              "99999999999"),
                                                              "xxx.xxx.xxx-xx").
    
                                   FOR FIRST crapage FIELDS(nmresage)
                                       WHERE 
                                       crapage.cdcooper = tt-titular.cdcooper AND
                                       crapage.cdagenci = tt-titular.cdagenci 
                                       NO-LOCK:
                                       tt-titular.dsagenci = crapage.nmresage.
                                   END.
                               END.
                            END.        
                        ELSE /* Pessoa Juridica */
                            DO:
                               FOR FIRST crapjur FIELDS(nmextttl cdempres)
                                   WHERE crapjur.cdcooper = par_cdcooper     AND
                                         crapjur.nrdconta = crapass.nrdconta 
                                         NO-LOCK:
    
                                   ASSIGN par_qtregist = par_qtregist + 1.
                                 
    
                                   /* controles da paginaçao */
                                   IF  par_flgpagin AND 
                                       ((par_qtregist < par_nriniseq) OR
                                       (par_qtregist > 
                                        (par_nriniseq + par_nrregist))) THEN
                                       NEXT.
    
                                   CREATE tt-titular.
                                   ASSIGN 
                                       tt-titular.cdcooper = crapass.cdcooper
                                       tt-titular.cdagenci = crapass.cdagenci
                                       tt-titular.nrdconta = crapass.nrdconta
                                       tt-titular.nrdctitg = crapass.nrdctitg
                                       tt-titular.dtdemiss = crapass.dtdemiss
                                       tt-titular.nmextttl = crapjur.nmextttl
                                       tt-titular.cdempres = crapjur.cdempres
                                       tt-titular.nmpesttl = tt-titular.nmextttl
                                       tt-titular.nmprimtl = tt-titular.nmextttl
									   tt-titular.dsnivris = (IF TRIM(crapass.dsnivris) = "" THEN
									                             "A"
															  ELSE
															     crapass.dsnivris)
                                       tt-titular.nrdocttl =  STRING(STRING
                                                             (crapass.nrcpfcgc,
                                                              "99999999999999"),
                                                             "xx.xxx.xxx/xxxx-xx").
    
                                   FOR FIRST crapage FIELDS(nmresage)
                                       WHERE 
                                       crapage.cdcooper = tt-titular.cdcooper AND
                                       crapage.cdagenci = tt-titular.cdagenci 
                                       NO-LOCK:
                                       tt-titular.dsagenci = crapage.nmresage.
                                   END.
                               END.
                            END.
                   END. /* Fim do FOR EACH */
                   
                   aux_etime = etime / 1000.
                     
                    RUN log-nome-assciado
                    (INPUT TODAY,
                     INPUT par_nmdbusca,
                     INPUT aux_inpessoa,
                     INPUT aux_cdagenci, 
                     INPUT par_tpdorgan,
                     INPUT aux_etime).  

           END. /* Fim do tipo de pesquisa 2 */
       ELSE
           IF  par_cdpesqui = 3 THEN
               DO:
                  IF  par_tpdapesq = 2 THEN /* pessoa jurifica */
                      DO:
                          FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper AND
                                                 crapass.nrcpfcgc = par_nrcpfcgc AND
                                                 (IF par_cdagpesq <> 0 THEN 
                                                    crapass.cdagenci = par_cdagpesq 
                                                  ELSE TRUE) AND /* Se par_cdagenci > 0 */
                                                 crapass.inpessoa > 1 NO-LOCK USE-INDEX crapass5,
                              FIRST crapjur WHERE crapjur.cdcooper = crapass.cdcooper AND 
                                                  crapjur.nrdconta = crapass.nrdconta NO-LOCK: /*
                                                  BY (IF par_tpdorgan = 1 THEN
                                                  crapjur.nmextttl ELSE
                                                  STRING(crapjur.nrdconta,"zzzzzz99")):          */
                                                    .

                              ASSIGN par_qtregist = par_qtregist + 1.
    
                              /* controles da paginaçao */
                              IF  par_flgpagin AND ((par_qtregist < par_nriniseq) OR
                                  (par_qtregist > (par_nriniseq + par_nrregist))) THEN
                                  NEXT.
    
                              CREATE tt-titular.
                              ASSIGN 
                                  tt-titular.cdcooper = crapjur.cdcooper
                                  tt-titular.nrdconta = crapjur.nrdconta
                                  tt-titular.cdagenci = crapass.cdagenci 
                                  tt-titular.nmextttl = crapjur.nmextttl  
                                  tt-titular.nrdctitg = crapass.nrdctitg
                                  tt-titular.dtdemiss = crapass.dtdemiss
                                  tt-titular.cdempres = crapjur.cdempres
                                  tt-titular.nmpesttl = tt-titular.nmextttl
                                  tt-titular.nmprimtl = tt-titular.nmextttl
								  tt-titular.dsnivris = (IF TRIM(crapass.dsnivris) = "" THEN
									                        "A"
													     ELSE
														    crapass.dsnivris)
                                  tt-titular.nrdocttl = STRING(STRING
                                                               (crapass.nrcpfcgc,
                                                                "99999999999999"),
                                                               "xx.xxx.xxx/xxxx-xx").
    
                              FOR FIRST crapage FIELDS(nmresage)
                                  WHERE crapage.cdcooper = tt-titular.cdcooper AND
                                        crapage.cdagenci = tt-titular.cdagenci 
                                        NO-LOCK:
                                  ASSIGN tt-titular.dsagenci = crapage.nmresage.
                              END.
    
                          END. /* FOR EACH crapttl  */

                      END. /* IF  par_tpdapesq = 1 */
                  ELSE
                      IF  par_tpdapesq = 1 THEN /* pessoa fisica */
                          DO:
                              FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                                     crapttl.nrcpfcgc = par_nrcpfcgc NO-LOCK,
                              FIRST crapass WHERE crapass.cdcooper = crapttl.cdcooper AND
                                                  crapass.nrdconta = crapttl.nrdconta AND
                                                  (IF par_cdagpesq <> 0 THEN 
                                                    crapass.cdagenci = par_cdagpesq 
                                                   ELSE TRUE) AND /* Se par_cdagenci > 0 */
                                                  crapass.inpessoa = 1 NO-LOCK: /*
                                                  BY (IF par_tpdorgan = 1 THEN
                                                      crapttl.nmextttl ELSE
                                                      STRING(crapttl.nrdconta,"zzzzzz99")): */

                                  ASSIGN aux_inpessoa = crapass.inpessoa
                                         aux_cdagenci = crapass.cdagenci.

                                  ASSIGN par_qtregist = par_qtregist + 1.
            
            
                                  /* controles da paginaçao */
                                  IF  par_flgpagin AND ((par_qtregist < par_nriniseq) OR
                                      (par_qtregist > (par_nriniseq + par_nrregist))) THEN
                                      NEXT.
            
                                  CREATE tt-titular.
                                  ASSIGN 
                                      tt-titular.cdcooper = crapttl.cdcooper
                                      tt-titular.nrdconta = crapttl.nrdconta
                                      tt-titular.cdagenci = crapass.cdagenci
                                      tt-titular.nmextttl = crapttl.nmextttl
                                      tt-titular.nrdctitg = crapass.nrdctitg
                                      tt-titular.idseqttl = crapttl.idseqttl
                                      tt-titular.dtnasttl = crapttl.dtnasttl
                                      tt-titular.dtdemiss = crapass.dtdemiss
                                      tt-titular.cdempres = crapttl.cdempres
                                      tt-titular.nmpesttl = tt-titular.nmextttl
                                      tt-titular.nmprimtl = tt-titular.nmextttl
									  tt-titular.dsnivris = (IF TRIM(crapass.dsnivris) = "" THEN
									                            "A"
															ELSE
															    crapass.dsnivris)
                                      tt-titular.nrdocttl = STRING(STRING
                                                                   (crapttl.nrcpfcgc,
                                                                   "99999999999"),
                                                                   "xxx.xxx.xxx-xx").
            
                                  FOR FIRST crapage FIELDS(nmresage)
                                      WHERE crapage.cdcooper = tt-titular.cdcooper AND
                                            crapage.cdagenci = tt-titular.cdagenci 
                                            NO-LOCK:
                                      ASSIGN tt-titular.dsagenci = crapage.nmresage.
                                  END.
    
                              END. /* FOR EACH crapttl  */
    
                          END. /* par_tpdapesq = 2  */
                          
                          aux_etime = etime / 1000.
                          RUN log-nome-assciado
                          (INPUT TODAY,
                           INPUT par_nmdbusca,
                           INPUT aux_inpessoa,
                           INPUT aux_cdagenci, 
                           INPUT par_tpdorgan,
                           INPUT aux_etime).  

               END. /* IF  par_cdpesqui = 3 */

         FOR EACH tt-titular NO-LOCK
                     BY (IF par_tpdorgan = 1 THEN
                            tt-titular.nmextttl 
                         ELSE
                            STRING(tt-titular.nrdconta,"zzzzzz99")):

                CREATE tt-titular2.
                BUFFER-COPY tt-titular TO tt-titular2. 


         END.
    
         RETURN "OK".
    
END PROCEDURE.

PROCEDURE busca-operadoras:
    /* Pesquisa para OPERADORAS DE TELEFONE */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopetfn AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmopetfn AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-oper-tel.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, RETURN:
        EMPTY TEMP-TABLE tt-oper-tel. 

        ASSIGN par_nmopetfn = TRIM(par_nmopetfn).

        FOR EACH craptab FIELDS(dstextab tpregist)
                         WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "USUARI"     AND
                               craptab.cdempres = 11           AND
                               craptab.cdacesso = "OPETELEFON" AND 
                              (IF par_cdopetfn <> 0 THEN 
                                craptab.tpregist = par_cdopetfn ELSE TRUE) AND
                               craptab.dstextab MATCHES("*" + par_nmopetfn + 
                                                        "*") NO-LOCK:

            IF  craptab.dstextab = "" THEN
                NEXT.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO: 
                   FIND tt-oper-tel WHERE 
                                    tt-oper-tel.cdopetfn = craptab.tpregist AND
                                    tt-oper-tel.nmopetfn = craptab.dstextab 
                                    NO-ERROR.
    
                   IF   NOT AVAILABLE tt-oper-tel THEN
                        DO:
                           CREATE tt-oper-tel.
                           ASSIGN
                               tt-oper-tel.cdopetfn = craptab.tpregist
                               tt-oper-tel.nmopetfn = craptab.dstextab.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-tipo-depend:
    /* Pesquisa para TIPOS DE DEPENDENTES */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipdep AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dstipdep AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-tipo-depend.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, RETURN:
        EMPTY TEMP-TABLE tt-tipo-depend. 

        ASSIGN par_dstipdep = TRIM(par_dstipdep).

        FOR EACH craptab FIELDS(dstextab tpregist)
                         WHERE craptab.cdcooper = par_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 0              AND
                               craptab.cdacesso = "DSTPDEPEND"   AND 
                              (IF par_cdtipdep <> 0 THEN 
                                craptab.tpregist = par_cdtipdep ELSE TRUE) AND
                               craptab.dstextab MATCHES("*" + par_dstipdep + 
                                                        "*") NO-LOCK:

            IF  craptab.dstextab = "" THEN
                NEXT.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO: 
                   FIND FIRST tt-tipo-depend WHERE
                        tt-tipo-depend.cdtipdep = craptab.tpregist AND
                        tt-tipo-depend.dstipdep = craptab.dstextab NO-ERROR.

                   IF   NOT AVAILABLE tt-tipo-depend THEN
                        DO:
                           CREATE tt-tipo-depend.
                           ASSIGN
                               tt-tipo-depend.cdtipdep = craptab.tpregist
                               tt-tipo-depend.dstipdep = craptab.dstextab.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-tipo-rendi:
    /* Pesquisa para TIPOS DE RENDIMENTOS */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdrendi AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdrendi AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-tipo-rendi.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, RETURN:
        EMPTY TEMP-TABLE tt-tipo-rendi. 

        ASSIGN par_dsdrendi = TRIM(par_dsdrendi).

        FOR EACH craptab FIELDS(dstextab tpregist)
                         WHERE craptab.cdcooper = par_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 0              AND
                               craptab.cdacesso = "DSRENDIMEN"   AND 
                              (IF par_tpdrendi <> 0 THEN 
                                craptab.tpregist = par_tpdrendi ELSE TRUE) AND
                               craptab.dstextab MATCHES("*" + par_dsdrendi + 
                                                        "*") NO-LOCK:

            IF  craptab.dstextab = "" THEN
                NEXT.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO: 
                   FIND FIRST tt-tipo-rendi WHERE
                        tt-tipo-rendi.tpdrendi = craptab.tpregist AND
                        tt-tipo-rendi.dsdrendi = craptab.dstextab NO-ERROR.

                   IF   NOT AVAILABLE tt-tipo-rendi THEN
                        DO:
                           CREATE tt-tipo-rendi.
                           ASSIGN
                               tt-tipo-rendi.tpdrendi = craptab.tpregist
                               tt-tipo-rendi.dsdrendi = craptab.dstextab.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-crapemp:
    /* Pesquisa para EMPRESA */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmresemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapemp.

    ASSIGN aux_nrregist = par_nrregist.

    Nacion: DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-crapemp.

        ASSIGN par_nmresemp = TRIM(par_nmresemp).

        FOR EACH crapemp FIELDS(cdempres nmresemp)
                         WHERE 
                         crapemp.cdcooper  = par_cdcooper AND
                         (IF par_cdempres <> 0 THEN
                          crapemp.cdempres = par_cdempres ELSE TRUE) AND
                         crapemp.nmresemp MATCHES("*" + par_nmresemp + "*") 
                         NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND FIRST tt-crapemp 
                       WHERE tt-crapemp.cdempres = crapemp.cdempres NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapemp THEN
                        DO:
                           CREATE tt-crapemp.
                           BUFFER-COPY crapemp TO tt-crapemp.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE Nacion.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-crapttl:
    /* Pesquisa para SEQUENCIA DOS TITULARES DA CONTA */
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapttl.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-crapttl.

        FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND FIRST tt-crapttl WHERE 
                              tt-crapttl.idseqttl = crapttl.idseqttl NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapttl THEN
                        DO:
                           CREATE tt-crapttl.
                           BUFFER-COPY crapttl TO tt-crapttl.
                                                   
                                                   FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                                    crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR NO-WAIT.

                           ASSIGN tt-crapttl.cdagenci = crapass.cdagenci.

                           FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.

                           ASSIGN tt-crapttl.nmrescop = crapcop.nmrescop.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-mot-demissao:
    /* Pesquisa para MOTIVO DEMISSAO */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmotdem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsmotdem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-mot-demissao.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, RETURN:

        EMPTY TEMP-TABLE tt-mot-demissao. 

        ASSIGN par_dsmotdem = TRIM(par_dsmotdem).

        FOR EACH craptab FIELDS(dstextab tpregist)
                         WHERE craptab.cdcooper = par_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 0              AND
                               craptab.cdacesso = "MOTIVODEMI"   AND 
                              (IF par_cdmotdem <> 0 THEN 
                                craptab.tpregist = par_cdmotdem ELSE TRUE) AND
                               craptab.dstextab MATCHES("*" + par_dsmotdem + 
                                                        "*") NO-LOCK:

            IF  craptab.dstextab = "" THEN
                NEXT.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO: 
                   FIND FIRST tt-mot-demissao WHERE
                        tt-mot-demissao.cdmotdem = craptab.tpregist AND
                        tt-mot-demissao.dsmotdem = craptab.dstextab NO-ERROR.

                   IF   NOT AVAILABLE tt-mot-demissao THEN
                        DO:
                           CREATE tt-mot-demissao.
                           ASSIGN
                               tt-mot-demissao.cdmotdem = craptab.tpregist
                               tt-mot-demissao.dsmotdem = craptab.dstextab.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END. 

        LEAVE.
    END.       

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-craplrt:
    /* Pesquisa para Linhas de Credito */
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddlinha AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdlinha AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdlinha AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgstlcr AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craplrt.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-craplrt.

        FOR EACH craplrt WHERE 
                 craplrt.cdcooper = par_cdcooper              AND
                 (IF par_cddlinha <> 0 THEN
                 craplrt.cddlinha = par_cddlinha ELSE TRUE)   AND 
                 (IF par_tpdlinha <> 0 THEN
                 craplrt.tpdlinha = par_tpdlinha ELSE TRUE)   AND
                 (IF par_flgstlcr = TRUE THEN
                 craplrt.flgstlcr = TRUE ELSE TRUE)           AND
                 craplrt.dsdlinha MATCHES("*" + par_dsdlinha + 
                                                        "*")  NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-craplrt WHERE 
                        tt-craplrt.cdcooper = craplrt.cdcooper   AND
                        tt-craplrt.cddlinha = craplrt.cddlinha   NO-ERROR.
                   IF   NOT AVAILABLE tt-craplrt   THEN
                        DO:
                           CREATE tt-craplrt.
                           BUFFER-COPY craplrt TO tt-craplrt
                               ASSIGN tt-craplrt.dsdtxfix = 
                                         STRING(craplrt.txjurfix,">>9.99%") + 
                                         " + TR"
                                      tt-craplrt.dsdtplin = 
                                         STRING(craplrt.tpdlinha = 1,
                                                "Limite PF/Limite PJ").
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
  Procedure para trazer os convenios da crapcco
******************************************************************************/
PROCEDURE busca-crapcco:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrconven AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dsorgarq AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM par_qtregist AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcco.

   
    EMPTY TEMP-TABLE tt-crapcco.

    FOR EACH crapcco WHERE crapcco.cdcooper = par_cdcooper AND 
                           crapcco.flgativo = TRUE         AND /* ATIVOS */
                           crapcco.dsorgarq <> "MIGRACAO"  AND 
                           crapcco.dsorgarq <> "EMPRESTIMO" AND
						   crapcco.dsorgarq <> "ACORDO" NO-LOCK
                           BY crapcco.nmdbanco:

        IF   par_nrconven <> 0   THEN
             IF    crapcco.nrconven <> par_nrconven  THEN
                   NEXT.

        IF   par_dsorgarq <> ""  THEN
             IF    crapcco.dsorgarq <> par_dsorgarq  THEN
                   NEXT.

        ASSIGN par_qtregist = par_qtregist + 1.

        CREATE tt-crapcco.
        ASSIGN tt-crapcco.nrconven = STRING(crapcco.nrconven,"zzzzz,zz9")
               tt-crapcco.flgativo = IF   crapcco.flgativo  THEN
                                          "ATIVO"
                                     ELSE
                                          "INATIVO"
               tt-crapcco.flgregis = IF   crapcco.flgregis  THEN
                                          "SIM"
                                     ELSE
                                          "NAO"
               tt-crapcco.dsorgarq = crapcco.dsorgarq.       
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
  Procedure para trazer as linhas de credito da craplcr
******************************************************************************/

PROCEDURE busca-craplcr:
    /* Pesquisa para LINHA DE CREDITO */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dslcremp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgstlcr AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmodali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpprodut AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craplcr.

    DEFINE VARIABLE aux_nrregist AS INTEGER     NO-UNDO.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, RETURN:
        EMPTY TEMP-TABLE tt-craplcr. 

        ASSIGN par_dslcremp = TRIM(par_dslcremp).

        IF  par_cdfinemp > 0 THEN
            DO:               
                FOR EACH craplch WHERE craplch.cdcooper = par_cdcooper AND
                                       craplch.cdfinemp = par_cdfinemp AND
                                       craplch.cdlcrhab >= par_cdlcremp  NO-LOCK,
                   FIRST craplcr WHERE craplcr.cdcooper = craplch.cdcooper  AND
                                       craplcr.cdlcremp = craplch.cdlcrhab  AND                                      
                                      (IF par_cdmodali <> "0" AND par_cdmodali <> "" AND par_cdmodali <> "undefined" THEN
										STRING(craplcr.cdmodali) + STRING(craplcr.cdsubmod) = par_cdmodali 
									   ELSE TRUE ) AND
									  (IF par_cdmodali <> "0" AND par_cdmodali <> "" AND par_cdlcremp > 0 THEN 
									    craplch.cdlcrhab = par_cdlcremp  
									   ELSE 
									    craplch.cdlcrhab >= par_cdlcremp ) AND 
                                      (IF par_flgstlcr THEN craplcr.flgstlcr = par_flgstlcr ELSE TRUE)   AND
                                       craplcr.dslcremp MATCHES("*" + par_dslcremp + "*")
                                       NO-LOCK:
        
                    ASSIGN par_qtregist = par_qtregist + 1.
        
                    /* controles da paginaçao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.
        
                    IF  aux_nrregist > 0 THEN
                        DO: 
                           FIND FIRST tt-craplcr WHERE
                                tt-craplcr.cdlcremp = craplcr.cdlcremp AND
                                tt-craplcr.dslcremp = craplcr.dslcremp NO-ERROR.
        
                           IF   NOT AVAILABLE tt-craplcr THEN
                                DO:                                   

                                   CREATE tt-craplcr.
                                   ASSIGN
                                       tt-craplcr.cdlcremp = craplcr.cdlcremp
                                       tt-craplcr.dslcremp = craplcr.dslcremp
                                       tt-craplcr.flgstlcr = craplcr.flgstlcr
                                       tt-craplcr.tpctrato = craplcr.tpctrato
                                       tt-craplcr.txbaspre = craplcr.txbaspre
                                       tt-craplcr.txmensal = craplcr.txmensal
                                       tt-craplcr.nrfimpre = craplcr.nrfimpre
                                       tt-craplcr.tpgarant = craplcr.tpctrato.

                                   CASE tt-craplcr.tpgarant:
                                       WHEN 1 THEN ASSIGN tt-craplcr.dsgarant = "AVAL".
                                       WHEN 2 THEN ASSIGN tt-craplcr.dsgarant = "VEICULOS".
                                       WHEN 3 THEN ASSIGN tt-craplcr.dsgarant = "IMOVEIS".
                                       OTHERWISE ASSIGN tt-craplcr.dsgarant = "NAO CADASTRADO".
                                   END CASE.                                   
                                       
                                END.
                        END.
        
                     ASSIGN aux_nrregist = aux_nrregist - 1.
                END.

            END.
        ELSE
            DO:
                FOR EACH craplcr WHERE 
                         craplcr.cdcooper = par_cdcooper              AND
                         (IF par_cdmodali <> "0" AND par_cdmodali <> "" THEN
                         STRING(craplcr.cdmodali) + STRING(craplcr.cdsubmod) = par_cdmodali ELSE TRUE) AND
                         (IF par_cdlcremp <> 0 THEN
                         craplcr.cdlcremp = par_cdlcremp ELSE TRUE)   AND
                         (IF par_flgstlcr THEN 
                         craplcr.flgstlcr = par_flgstlcr ELSE TRUE)   AND
                         craplcr.dslcremp MATCHES("*" + par_dslcremp + "*") AND
                         (IF par_tpprodut <> ? THEN craplcr.tpprodut = par_tpprodut ELSE TRUE) NO-LOCK:
        
                    ASSIGN par_qtregist = par_qtregist + 1.
        
                    /* controles da paginaçao */
                    IF  (par_qtregist < par_nriniseq) OR
                        (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                        NEXT.
        
                    IF  aux_nrregist > 0 THEN
                        DO: 
                           FIND FIRST tt-craplcr WHERE
                                tt-craplcr.cdlcremp = craplcr.cdlcremp AND
                                tt-craplcr.dslcremp = craplcr.dslcremp NO-ERROR.
        
                           IF   NOT AVAILABLE tt-craplcr THEN
                                DO:                                   

                                   CREATE tt-craplcr.
                                   ASSIGN
                                       tt-craplcr.cdlcremp = craplcr.cdlcremp
                                       tt-craplcr.dslcremp = craplcr.dslcremp
                                       tt-craplcr.flgstlcr = craplcr.flgstlcr
                                       tt-craplcr.tpctrato = craplcr.tpctrato
                                       tt-craplcr.txbaspre = craplcr.txbaspre
                                       tt-craplcr.txmensal = craplcr.txmensal
                                       tt-craplcr.nrfimpre = craplcr.nrfimpre
                                       tt-craplcr.tpgarant = craplcr.tpctrato.

                                   CASE tt-craplcr.tpgarant:
                                       WHEN 1 THEN ASSIGN tt-craplcr.dsgarant = "AVAL".
                                       WHEN 2 THEN ASSIGN tt-craplcr.dsgarant = "VEICULOS".
                                       WHEN 3 THEN ASSIGN tt-craplcr.dsgarant = "IMOVEIS".
                                       OTHERWISE ASSIGN tt-craplcr.dsgarant = "NAO CADASTRADO".
                                   END CASE.                                   

                                END.
                        END.
        
                     ASSIGN aux_nrregist = aux_nrregist - 1.
                END.
            END.
        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
       Procedure para trazer as finalidades de emprestimos da crapfin
******************************************************************************/
PROCEDURE busca-crapfin:
    /* Pesquisa para LINHA DE CREDITO */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsfinemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgstfin AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapfin.

    DEFINE VARIABLE aux_nrregist AS INTEGER     NO-UNDO.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, RETURN:
        EMPTY TEMP-TABLE tt-crapfin. 

        ASSIGN par_dsfinemp = TRIM(par_dsfinemp).

        FOR EACH crapfin WHERE 
                 crapfin.cdcooper = par_cdcooper              AND
                 (IF par_cdfinemp <> 0 THEN
                 crapfin.cdfinemp = par_cdfinemp ELSE TRUE)   AND
                 (IF par_flgstfin THEN 
                 crapfin.flgstfin = par_flgstfin ELSE TRUE)   AND
                 crapfin.dsfinemp MATCHES("*" + par_dsfinemp + "*")  NO-LOCK:
                    
                ASSIGN par_qtregist = par_qtregist + 1.
            
                /* controles da paginaçao */
                IF  (par_qtregist < par_nriniseq) OR
                    (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                    NEXT.
            
                IF  aux_nrregist > 0 THEN
                    DO: 
                       FIND FIRST tt-crapfin WHERE
                            tt-crapfin.cdfinemp = crapfin.cdfinemp AND
                            tt-crapfin.dsfinemp = crapfin.dsfinemp NO-ERROR.
            
                       IF   NOT AVAILABLE tt-crapfin THEN
                            DO:
                               CREATE tt-crapfin.
                               ASSIGN tt-crapfin.cdfinemp = crapfin.cdfinemp
                                      tt-crapfin.dsfinemp = crapfin.dsfinemp
                                      tt-crapfin.flgstfin = crapfin.flgstfin
                                      tt-crapfin.tpfinali = crapfin.tpfinali.
                            END.
                    END.
            
                 ASSIGN aux_nrregist = aux_nrregist - 1.
        END.            

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
  Procedure para trazer as modalidades de risco da gnmodal
******************************************************************************/
PROCEDURE busca-modalidade:

    DEF OUTPUT PARAM par_qtregist AS INTE NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-gnmodal.

    EMPTY TEMP-TABLE tt-gnmodal.

    FOR EACH gnmodal NO-LOCK:

        CREATE tt-gnmodal.
        ASSIGN tt-gnmodal.cdmodali = gnmodal.cdmodali
               tt-gnmodal.dsmodali = gnmodal.dsmodali
               par_qtregist        = par_qtregist + 1.
    END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
  Procedure para trazer historicos
******************************************************************************/
PROCEDURE busca-historico:
    /* Pesquisa para HISTORICOS */

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dshistor AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_flglanca AS LOGI                            NO-UNDO.
    DEF  INPUT PARAM par_inautori AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                            NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craphis.

    ASSIGN aux_nrregist = par_nrregist.

    Histor: DO ON ERROR UNDO, LEAVE:

        EMPTY TEMP-TABLE tt-craphis.

        FOR EACH craphis WHERE 
                 craphis.cdcooper = par_cdcooper                AND
                 (IF par_cdhistor <> 0 THEN
                     craphis.cdhistor = par_cdhistor ELSE TRUE) AND
                 (IF par_dshistor <> "" THEN 
                     craphis.dsexthst MATCHES("*" + par_dshistor + "*")
                     ELSE TRUE) NO-LOCK
                  BY craphis.dsexthst:

            IF  par_flglanca   THEN /* Utilizado pela LOTE e LANAUT */
                DO:
                    IF   craphis.indebfol <> 1   THEN 
                         IF   craphis.tplotmov <> 1     OR
                              craphis.indebcre <> "D"   OR
                              craphis.inhistor <> 1     OR
                              craphis.indebcta <> 1     THEN
                              NEXT.
                END.
        
            IF  par_inautori = 9 THEN      /* Utilizado pelo programa DCTROR */
                DO:
                    /* Historicos 817,821,825 nao sao mais permitidos
                       para escolha na tela DCTROR. Melhoria 100 */
                    IF (craphis.tplotmov <> 8 AND
                        craphis.tplotmov <> 9) OR
                       (craphis.cdhistor = 817 OR
                        craphis.cdhistor = 821 OR
                        craphis.cdhistor = 825) THEN
                        NEXT.
                END.       
            ELSE 
            IF   par_inautori <> 0   THEN
                 DO:
                     IF   craphis.inautori <> 1   THEN
                          NEXT.
                          
                     /* Nao listar historico sicredi */
                     IF  craphis.inautori = 1 AND 
                         craphis.cdhistor = 1019 THEN
                         NEXT.
                 END.

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND FIRST tt-craphis 
                       WHERE tt-craphis.cdhistor = craphis.cdhistor NO-ERROR.
    
                   IF   NOT AVAILABLE tt-craphis THEN
                        DO:
                           CREATE tt-craphis.
                           ASSIGN tt-craphis.cdhistor = craphis.cdhistor
                                  tt-craphis.dshistor = craphis.dsexthst.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE Histor.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
  Procedure para trazer opcoes de alteracao
******************************************************************************/
PROCEDURE busca-opcoes-manut-inss:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nmsistem AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_tptabela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_cdempres AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdacesso AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                            NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-manut-inss.

    ASSIGN aux_nrregist = par_nrregist.
  
    Opcao: DO ON ERROR UNDO, LEAVE:

        EMPTY TEMP-TABLE tt-manut-inss.

        FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper AND
                               craptab.nmsistem = par_nmsistem AND
                               craptab.tptabela = par_tptabela AND
                               craptab.cdempres = par_cdempres AND
                               craptab.cdacesso = par_cdacesso 
                               NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND FIRST tt-manut-inss WHERE 
                              tt-manut-inss.tpregist = craptab.tpregist 
                              NO-LOCK NO-ERROR.
    
                   IF   NOT AVAILABLE tt-manut-inss THEN
                        DO:
                           CREATE tt-manut-inss.
                           ASSIGN tt-manut-inss.tpregist = craptab.tpregist
                                  tt-manut-inss.dstextab = craptab.dstextab.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE Opcao.
    END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
  Procedure para guias de previdencia
******************************************************************************/
PROCEDURE busca-crapcgp:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdidenti AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                              NO-UNDO.
                                                                     
    DEF OUTPUT PARAM par_qtregist AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcgp.                            
                                                                     
    DEF VAR aux_nrregist AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-crapcgp.

    ASSIGN aux_nrregist = par_nrregist.
    
    Busca: DO WHILE TRUE:

        FOR EACH crapcgp  WHERE  crapcgp.cdcooper = par_cdcooper AND
                                (IF par_cdidenti <> 0 THEN
                                    crapcgp.cdidenti = par_cdidenti 
                                 ELSE crapcgp.cdidenti > 0)
                                NO-LOCK BY crapcgp.cdidenti:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:

                    CREATE tt-crapcgp.
                    ASSIGN tt-crapcgp.cdidenti = crapcgp.cdidenti
                           tt-crapcgp.cddpagto = crapcgp.cddpagto
                           tt-crapcgp.nrdconta = crapcgp.nrdconta
                           tt-crapcgp.nmprimtl = crapcgp.nmprimtl.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
  Procedure para busca de motivos de nao aprovacao
******************************************************************************/
PROCEDURE busca-gncmapr:

    DEF  INPUT PARAM par_cdcmaprv AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dscmaprv AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                              NO-UNDO.
                                                                     
    DEF OUTPUT PARAM par_qtregist AS INTE                              NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt-gncmapr.

    DEF VAR aux_nrregist AS INTE                                       NO-UNDO.

    
    ASSIGN aux_nrregist = par_nrregist.
    
    Busca: DO ON ERROR UNDO, LEAVE:

        EMPTY TEMP-TABLE tt-gncmapr.
        
        /*Quando informava 0, criava tt com todos motivos e pegava 1a descr*/
        IF  par_dscmaprv = "ZM" THEN DO:
            par_dscmaprv = "".
            IF  par_cdcmaprv = 0 THEN DO:
                CREATE tt-gncmapr.
                ASSIGN tt-gncmapr.cdcmaprv = par_cdcmaprv
                       tt-gncmapr.dscmaprv = "".
                RETURN "OK".
            END.
        END.
        /**/

        FOR EACH gncmapr WHERE 
                 (IF par_cdcmaprv <> 0 THEN
                     gncmapr.cdcmaprv = par_cdcmaprv ELSE TRUE) AND
                     gncmapr.dscmaprv MATCHES "*" + par_dscmaprv + "*"
                     NO-LOCK
                  BY gncmapr.dscmaprv:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginacao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:

                    CREATE tt-gncmapr.
                    ASSIGN tt-gncmapr.cdcmaprv = gncmapr.cdcmaprv
                           tt-gncmapr.dscmaprv = gncmapr.dscmaprv.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
  Procedure para aditivos do contrato de emprestimo
******************************************************************************/
PROCEDURE busca-crapadt:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                              NO-UNDO.
                                                                     
    DEF OUTPUT PARAM par_qtregist AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapadt.                            
                                                                     
    DEF VAR aux_nrregist AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-crapadt.

    ASSIGN aux_nrregist = par_nrregist.
    
    Busca: DO WHILE TRUE:

        FOR EACH crapadt WHERE crapadt.cdcooper = par_cdcooper AND
                               crapadt.nrdconta = par_nrdconta AND
                               crapadt.nrctremp = par_nrctremp NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:

                    CREATE tt-crapadt.
                    ASSIGN tt-crapadt.nraditiv = crapadt.nraditiv
                           tt-crapadt.cdaditiv = crapadt.cdaditiv.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
  Procedure para buscar as cooperativas
******************************************************************************/
PROCEDURE busca-crapcop:

    /* Pesquisa para Cdcooper */
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmextcop AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcop.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:

        EMPTY TEMP-TABLE tt-crapcop.

        FOR EACH crapcop WHERE (IF par_cdcooper <> 0 THEN
                                crapcop.cdcooper = par_cdcooper ELSE
                                crapcop.cdcooper >= par_cdcooper) AND
                                crapcop.flgativo = TRUE           AND
                                crapcop.nmextcop MATCHES 
                               ("*" + par_nmextcop + "*")
                                NO-LOCK:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-crapcop WHERE 
                                   tt-crapcop.cdcopsol = crapcop.cdcooper AND
                                   tt-crapcop.nmextcop = crapcop.nmextcop
                                   NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapcop THEN
                        DO:
                           CREATE tt-crapcop.
                                  
                           ASSIGN tt-crapcop.cdcopsol = crapcop.cdcooper
                                  tt-crapcop.nmextcop = crapcop.nmextcop
                                  tt-crapcop.cdagectl = crapcop.cdagectl
                                  tt-crapcop.nmrescop = crapcop.nmrescop
                                  tt-crapcop.cdbcoctl = crapcop.cdbcoctl
                                  tt-crapcop.cdagenmr =
                                         STRING(crapcop.cdagectl) +   " - " +
                                         crapcop.nmrescop.                               
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.

    END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
  Procedure para buscar os nomes dos arquivos importados para a tela ALTCAR
******************************************************************************/
PROCEDURE busca-crapecv:

    DEF INPUT PARAM par_dtvencto AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapecv.


    FOR EACH crapecv FIELDS(dtvencto nmarqimp)
              WHERE MONTH(crapecv.dtvencto) = INT(SUBSTR(par_dtvencto,1,2)) AND
                    YEAR(crapecv.dtvencto)  = INT(SUBSTR(par_dtvencto,3,4))
                    NO-LOCK:

        FIND FIRST tt-crapecv WHERE tt-crapecv.nmarqimp = crapecv.nmarqimp
                                    NO-LOCK NO-ERROR.

        IF NOT AVAIL tt-crapecv THEN
           DO:                  
              CREATE tt-crapecv.

              ASSIGN tt-crapecv.nmarqimp = crapecv.nmarqimp
                     tt-crapecv.dtvencto = STRING(MONTH(crapecv.dtvencto)) +
                                           STRING(YEAR(crapecv.dtvencto)).

           END.

    END.


    RETURN "OK".

END.

/******************************************************************************
  Procedure para buscar chashes
******************************************************************************/
PROCEDURE busca-craptfn:
    /* Pesquisa para CASH */
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrterfin AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmterfin AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craptfn.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:
        EMPTY TEMP-TABLE tt-craptfn.

        ASSIGN par_nmterfin = TRIM(par_nmterfin).

        FOR EACH craptfn FIELDS(cdcooper nrterfin nmnarede nmterfin)
           WHERE craptfn.cdcooper = par_cdcooper AND
                 (IF par_nrterfin <> 0 THEN
                  craptfn.nrterfin = par_nrterfin ELSE TRUE) AND
                  craptfn.nmterfin MATCHES("*" + par_nmterfin + "*") 
                  NO-LOCK BREAK BY craptfn.nmnarede:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND tt-craptfn WHERE 
                                   tt-craptfn.cdcooper = craptfn.cdcooper AND
                                   tt-craptfn.nrterfin = craptfn.nrterfin
                                   NO-ERROR.
    
                   IF   NOT AVAIL tt-craptfn THEN
                        DO:
                           CREATE tt-craptfn.
                           ASSIGN
                               tt-craptfn.cdcooper = craptfn.cdcooper
                               tt-craptfn.nrterfin = craptfn.nrterfin
                               tt-craptfn.nmnarede = craptfn.nmnarede
                               tt-craptfn.nmterfin = craptfn.nmterfin.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca_arquivos_pamcard:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR NO-UNDO.

    DEF OUTPUT PARAM par_qtdregis AS INTE NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-arquivos-pamcard.

    DEF VAR aux_setlinha AS CHAR FORMAT "x(100)" NO-UNDO.

    EMPTY TEMP-TABLE tt-arquivos-pamcard.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    UNIX SILENT VALUE("rm /micros/" + crapcop.dsdircop 
                       + "/arquivos_pamcard.txt 2> /dev/null").

    IF par_nmarquiv <> "" THEN
    DO:
     IF SUBSTR(par_nmarquiv, 1, 2) = "MT" THEN
         IF INDEX(par_nmarquiv, ".txt") > 0 THEN
            UNIX SILENT VALUE("ls /micros/" + crapcop.dsdircop + "/" + 
                                par_nmarquiv +
                                " >> /micros/" + crapcop.dsdircop + 
                                "/arquivos_pamcard.txt").
         ELSE
            UNIX SILENT VALUE("ls /micros/" + crapcop.dsdircop + "/" + 
                                par_nmarquiv + "*.txt" +
                                " >> /micros/" + crapcop.dsdircop + 
                                "/arquivos_pamcard.txt").
     ELSE
         UNIX SILENT VALUE("ls /micros/" + crapcop.dsdircop + "/MT*" + 
                            par_nmarquiv + "*.txt" +
                            " >> /micros/" + crapcop.dsdircop + 
                            "/arquivos_pamcard.txt").
    END.
    ELSE
        UNIX SILENT VALUE("ls /micros/" + crapcop.dsdircop + "/MT*.txt" +
                            " >> /micros/" + crapcop.dsdircop + 
                            "/arquivos_pamcard.txt").

    INPUT STREAM str_1 THROUGH VALUE("cat /micros/" + crapcop.dsdircop +
                                     "/arquivos_pamcard.txt") NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
        
        SET STREAM str_1 aux_setlinha WITH FRAME AA WIDTH 110.

        CREATE tt-arquivos-pamcard.
        ASSIGN tt-arquivos-pamcard.nmarquiv = aux_setlinha.

        ASSIGN par_qtdregis = par_qtdregis + 1.


    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
                  Procedure para gerar log de consulta do associado
*******************************************************************************/
PROCEDURE log-nome-assciado:

    DEF INPUT PARAM par_dtmvtolt AS DATE                                NO-UNDO.
    DEF INPUT PARAM par_nmdbusca AS CHAR                                NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_tpdorgan AS INTE                                NO-UNDO.
    DEF INPUT PARAM par_etime    AS INTE                                NO-UNDO.
         
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt) +
                          " "     + STRING(TIME,"HH:MM:SS")  + " ' --> ' " +
                          "Tempo: " + STRING(par_etime,"HH:MM:SS") + " "   + 
                          "Termo: " + replace(par_nmdbusca, "*", "") + " " +
                          "Tipo: "  + STRING(par_inpessoa)    +  " "       +
                          "Pac: "   + STRING(par_cdagenci)    +  " "       +
                          "Ordenacao: " + STRING(par_tpdorgan) + 
                          " >> log/nome.log").

END PROCEDURE. 


/*PROCEDURE RESPONSAVEL POR ENCONTRAR UM OPERADOR DE UMA COOPERATIVA ESPECIFICA

ATENÇÃO: Esta rotina foi convertida para o Oracle e qualquer alteracao devera
         ser replicada para sua respectiva conversao e vice-versa.  */
PROCEDURE busca-crapope:
                                              
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapope.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:

       EMPTY TEMP-TABLE tt-crapope.

       ASSIGN par_cdoperad = TRIM(par_cdoperad)
              par_nmoperad = TRIM(par_nmoperad).

       FOR EACH crapope 
                WHERE (IF par_cdoperad <> "" THEN
                          crapope.cdcooper = par_cdcooper  AND
                          crapope.cdoperad = par_cdoperad  AND
                          crapope.cdagenci = par_cdagenci
                       ELSE
                          crapope.cdcooper = par_cdcooper  AND
                          crapope.cdagenci = par_cdagenci) AND
                       crapope.nmoperad MATCHES "*" + par_nmoperad + "*"
                       NO-LOCK:

           ASSIGN par_qtregist = par_qtregist + 1.

           /* controles da paginaçao */
           IF (par_qtregist < par_nriniseq)                  OR
              (par_qtregist > (par_nriniseq + par_nrregist)) THEN
              NEXT.

           IF aux_nrregist > 0 THEN
              DO:
                 FIND tt-crapope WHERE 
                                 tt-crapope.cdcooper = crapope.cdcooper AND
                                 tt-crapope.cdoperad = crapope.cdoperad AND
                                 tt-crapope.cdagenci = crapope.cdagenci
                                 NO-ERROR.
    
                 IF NOT AVAILABLE tt-crapope THEN
                    DO:
                       CREATE tt-crapope.

                       ASSIGN tt-crapope.cdcooper = crapope.cdcooper
                              tt-crapope.cdoperad = crapope.cdoperad
                              tt-crapope.nmoperad = crapope.nmoperad
                              tt-crapope.cdagenci = crapope.cdagenci
                              tt-crapope.vlpagchq = crapope.vlpagchq.

                    END.

              END.

            ASSIGN aux_nrregist = aux_nrregist - 1.
       END.

       LEAVE.

    END.

    RETURN "OK".

END PROCEDURE.


/*PROCEDURE RESPONAVEL POR BUSCAR O PAC DE UM COOPERATIVA INFORMADA*/
PROCEDURE busca-agencia:
                                              
    DEF  INPUT PARAM par_cdcopsol AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsagepac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapage.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:

       EMPTY TEMP-TABLE tt-crapagb.

       ASSIGN par_dsagepac = TRIM(par_dsagepac).

       FOR EACH crapage 
                WHERE crapage.cdcooper = par_cdcopsol                    AND
                     (IF par_cdagepac <> 0 THEN
                         crapage.cdagenci = par_cdagepac 
                      ELSE 
                         TRUE)                                           AND
                      crapage.nmresage MATCHES("*" + par_dsagepac + "*") 
                      NO-LOCK:

           ASSIGN par_qtregist = par_qtregist + 1.

           /* controles da paginaçao */
           IF (par_qtregist < par_nriniseq) OR
              (par_qtregist > (par_nriniseq + par_nrregist)) THEN
              NEXT.

           IF aux_nrregist > 0 THEN
              DO:
                 FIND tt-crapage WHERE 
                                 tt-crapage.cdcooper = crapage.cdcooper AND
                                 tt-crapage.cdagepac = crapage.cdagenci
                                 NO-ERROR.
    
                 IF   NOT AVAILABLE tt-crapage THEN
                      DO:
                         CREATE tt-crapage.

                         ASSIGN tt-crapage.cdcooper = crapage.cdcooper
                                tt-crapage.cdagepac = crapage.cdagenci
                                tt-crapage.dsagepac = crapage.nmresage.

                      END.

              END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

       END.

       LEAVE.

    END.

    RETURN "OK".

END PROCEDURE.


/*PROCEDURE RESPONAVEL POR BUSCAR A(s) ROTINA(s) NA TABELA CRAPROT*/
PROCEDURE busca-rotina:
                                              
    DEF  INPUT PARAM par_cdoperac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsoperac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craprot.

    ASSIGN aux_nrregist = par_nrregist.

    DO ON ERROR UNDO, LEAVE:

       EMPTY TEMP-TABLE tt-craprot.

       ASSIGN par_dsoperac = TRIM(par_dsoperac).

       FOR EACH craprot 
                WHERE (IF par_cdoperac <> "" THEN
                          craprot.cdoperac = INT(par_cdoperac)
                       ELSE 
                          TRUE)                                           AND
                       craprot.dsoperac MATCHES("*" + par_dsoperac + "*") 
                       NO-LOCK:

           ASSIGN par_qtregist = par_qtregist + 1.

           /* controles da paginaçao */
           IF  (par_qtregist < par_nriniseq)                  OR
               (par_qtregist > (par_nriniseq + par_nrregist)) THEN
               NEXT.

           IF aux_nrregist > 0 THEN
              DO:
                 FIND tt-craprot WHERE tt-craprot.cdoperac = craprot.cdoperac
                                       NO-ERROR.
    
                 IF NOT AVAILABLE tt-craprot THEN
                    DO:
                       CREATE tt-craprot.

                       ASSIGN tt-craprot.cdoperac = craprot.cdoperac
                              tt-craprot.dsoperac = craprot.dsoperac.

                    END.

              END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

       END.

       LEAVE.

    END.

    RETURN "OK".

END PROCEDURE.
                                          

PROCEDURE busca-crappfo:
                                          /*
     GABRIEL - RKAM - ESTAVA DANDO ERRO DE TABELA CRAPPFO NAO ENCONTRADA
                                          
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdperfil AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsperfil AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crappfo.

    EMPTY TEMP-TABLE tt-crapcco.

    ASSIGN aux_nrregist = par_nrregist.

    FOR EACH crappfo NO-LOCK BY crappfo.cdperfil:

        IF par_cdperfil <> ""   THEN
           IF  crappfo.cdperfil <> par_cdperfil  THEN
               NEXT.

        ASSIGN par_qtregist = par_qtregist + 1.

        /* controles da paginaçao */
        IF (par_qtregist < par_nriniseq)                  OR
          (par_qtregist > (par_nriniseq + par_nrregist)) THEN
          NEXT.
        
        IF aux_nrregist > 0 THEN 
           DO:
              CREATE tt-crappfo.
              BUFFER-COPY crappfo TO tt-crappfo.
           END.
        
    END.
                                         */
    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-produtos:

    DEF  INPUT PARAM par_dsarnego AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsprodut AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-produtos.

    EMPTY TEMP-TABLE tt-produtos.

    ASSIGN aux_nrregist = par_nrregist.

    FOR EACH crapadn WHERE (IF par_dsprodut <> "" THEN
                               crapprd.dsprodut MATCHES("*" + par_dsprodut + "*")
                            ELSE TRUE)
                            NO-LOCK,
        EACH crapprd WHERE crapprd.cdarnego = crapadn.cdarnego
                       AND (IF par_dsarnego <> "" THEN 
                               crapadn.dsarnego MATCHES("*" + par_dsarnego + "*")
                            ELSE TRUE)
                       NO-LOCK:

        ASSIGN par_qtregist = par_qtregist + 1.

        /* controles da paginaçao */
        IF (par_qtregist < par_nriniseq)                  OR
          (par_qtregist > (par_nriniseq + par_nrregist)) THEN
          NEXT.
        
        IF aux_nrregist > 0 THEN 
           DO:
              CREATE tt-produtos.
              ASSIGN tt-produtos.cdarnego = crapadn.cdarnego
                     tt-produtos.dsarnego = crapadn.dsarnego
                     tt-produtos.cdprodut = crapprd.cdprodut
                     tt-produtos.dsprodut = crapprd.dsprodut.
           END.
        
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-crapass:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapass.

    DEFINE VARIABLE aux_nrregist AS INTEGER     NO-UNDO.

    ASSIGN aux_nrregist = par_nrregist.
    
    DO ON ERROR UNDO, RETURN:
       
       EMPTY TEMP-TABLE tt-crapass.
       
       IF par_nrcpfcgc > 0 AND par_nrdconta = 0 THEN
          DO:
              FOR EACH crapass FIELDS(nrdconta nmprimtl inpessoa nrcpfcgc) 
                       WHERE 
                       crapass.cdcooper = par_cdcooper              AND
                       crapass.inpessoa = par_inpessoa              AND
                       crapass.nrcpfcgc = par_nrcpfcgc              AND
                       crapass.nmprimtl MATCHES("*" + par_nmprimtl + "*")  
                       NO-LOCK:
              
                  ASSIGN par_qtregist = par_qtregist + 1.
              
                  /* controles da paginaçao */
                  IF  (par_qtregist < par_nriniseq) OR
                      (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                      NEXT.
              
                  IF  aux_nrregist > 0 THEN
                      DO: 
                         FIND FIRST tt-crapass 
                              WHERE tt-crapass.nrdconta = crapass.nrdconta
                                    NO-ERROR.
              
                         IF NOT AVAILABLE tt-crapass THEN
                            DO:
                                CREATE tt-crapass.
                                ASSIGN tt-crapass.nrdconta = crapass.nrdconta
                                       tt-crapass.nmprimtl = crapass.nmprimtl
                                       tt-crapass.inpessoa = crapass.inpessoa.
                                       
                                IF crapass.inpessoa = 1 THEN 
                                   tt-crapass.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,"99999999999"),
                                                                "xxx.xxx.xxx-xx").
                                ELSE 
                                   tt-crapass.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,"99999999999999"),
                                                               "xx.xxx.xxx/xx~xx-xx").
                                VALIDATE tt-crapass.
                            END.
                      END.
              
                   ASSIGN aux_nrregist = aux_nrregist - 1.
              END.
          END.
       ELSE
       IF par_nrdconta > 0 AND par_nrcpfcgc = 0 THEN
          DO:
              FOR EACH crapass FIELDS(nrdconta nmprimtl inpessoa nrcpfcgc) 
                       WHERE 
                       crapass.cdcooper = par_cdcooper AND
                       crapass.inpessoa = par_inpessoa AND
                       crapass.nrdconta = par_nrdconta AND                       
                       crapass.nmprimtl MATCHES("*" + par_nmprimtl + "*")  NO-LOCK:
              
                  ASSIGN par_qtregist = par_qtregist + 1.
              
                  /* controles da paginaçao */
                  IF  (par_qtregist < par_nriniseq) OR
                      (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                      NEXT.
              
                  IF  aux_nrregist > 0 THEN
                      DO: 
                         FIND FIRST tt-crapass 
                              WHERE tt-crapass.nrdconta = crapass.nrdconta
                                    NO-ERROR.
              
                         IF NOT AVAILABLE tt-crapass THEN
                            DO:
                                CREATE tt-crapass.
                                ASSIGN tt-crapass.nrdconta = crapass.nrdconta
                                       tt-crapass.nmprimtl = crapass.nmprimtl
                                       tt-crapass.inpessoa = crapass.inpessoa.
                                       
                                IF crapass.inpessoa = 1 THEN 
                                   tt-crapass.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,"99999999999"),
                                                                "xxx.xxx.xxx-xx").
                                ELSE 
                                   tt-crapass.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,"99999999999999"),
                                                               "xx.xxx.xxx/xx~xx-xx").
                                VALIDATE tt-crapass.
                            END.
                      END.
              
                   ASSIGN aux_nrregist = aux_nrregist - 1.
              END.
          END.    
       ELSE
       IF par_nrdconta > 0 AND par_nrcpfcgc > 0 THEN
          DO:
              FOR EACH crapass FIELDS(nrdconta nmprimtl inpessoa nrcpfcgc) 
                       WHERE 
                       crapass.cdcooper = par_cdcooper AND
                       crapass.inpessoa = par_inpessoa AND
                       crapass.nrdconta = par_nrdconta AND   
                       crapass.nrcpfcgc = par_nrcpfcgc AND
                       crapass.nmprimtl MATCHES("*" + par_nmprimtl + "*")  NO-LOCK:
              
                  ASSIGN par_qtregist = par_qtregist + 1.
              
                  /* controles da paginaçao */
                  IF  (par_qtregist < par_nriniseq) OR
                      (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                      NEXT.
              
                  IF  aux_nrregist > 0 THEN
                      DO: 
                         FIND FIRST tt-crapass 
                              WHERE tt-crapass.nrdconta = crapass.nrdconta
                                    NO-ERROR.
              
                         IF NOT AVAILABLE tt-crapass THEN
                            DO:
                                CREATE tt-crapass.
                                ASSIGN tt-crapass.nrdconta = crapass.nrdconta
                                       tt-crapass.nmprimtl = crapass.nmprimtl
                                       tt-crapass.inpessoa = crapass.inpessoa.
                                       
                                IF crapass.inpessoa = 1 THEN 
                                   tt-crapass.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,"99999999999"),
                                                                "xxx.xxx.xxx-xx").
                                ELSE 
                                   tt-crapass.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,"99999999999999"),
                                                               "xx.xxx.xxx/xx~xx-xx").
                                VALIDATE tt-crapass.
                            END.
                      END.
              
                   ASSIGN aux_nrregist = aux_nrregist - 1.
              END.
          END.              
       ELSE
          DO:
              FOR EACH crapass FIELDS(nrdconta nmprimtl inpessoa nrcpfcgc) 
                       WHERE 
                       crapass.cdcooper = par_cdcooper              AND
                       crapass.inpessoa = par_inpessoa              AND
                       crapass.nmprimtl MATCHES("*" + par_nmprimtl + "*")  NO-LOCK:
              
                  ASSIGN par_qtregist = par_qtregist + 1.
              
                  /* controles da paginaçao */
                  IF  (par_qtregist < par_nriniseq) OR
                      (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                      NEXT.
              
                  IF  aux_nrregist > 0 THEN
                      DO: 
                         FIND FIRST tt-crapass 
                              WHERE tt-crapass.nrdconta = crapass.nrdconta
                                    NO-ERROR.
              
                         IF NOT AVAILABLE tt-crapass THEN
                            DO:
                                CREATE tt-crapass.
                                ASSIGN tt-crapass.nrdconta = crapass.nrdconta
                                       tt-crapass.nmprimtl = crapass.nmprimtl
                                       tt-crapass.inpessoa = crapass.inpessoa.
                                       
                                IF crapass.inpessoa = 1 THEN 
                                   tt-crapass.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,"99999999999"),
                                                                "xxx.xxx.xxx-xx").
                                ELSE 
                                   tt-crapass.nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,"99999999999999"),
                                                               "xx.xxx.xxx/xx~xx-xx").
                                VALIDATE tt-crapass.
                            END.
                      END.
              
                   ASSIGN aux_nrregist = aux_nrregist - 1.
              END.
          END.
    END.

    RETURN "OK".

END PROCEDURE.
