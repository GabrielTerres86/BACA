/*...........................................................................

  Programa: b1wgen0191.p
  Autor   : Jonata-RKAM
  Data    : Agosto/2014                       Ultima Atualizacao: 19/12/2017
                                                                      
  Dados referentes ao programa:
  
  Objetivo  : BO referente ao Projeto Automatização de Consultas em 
              Propostas de Crédito.
                
  Alteracoes:  26/11/2014 - Aumentar formato dos valores das anotacoes
                            das consultas automatizadas (Jonata/RKAM).     
                            
               07/04/2015 - Consultas automatizadas para o limite de credito
                            (Jonata-RKAM).                         
               
               11/12/2015 - Inclusao do campo dsmotivo no relatorio
                            Chamado 363148 (Heitor - RKAM)
                            
               21/03/2016 - Inclusao campos consulta boa vista.
                            PRJ207 - Esteira (Odirlei/AMcom)              

               19/05/2016 - Alterado a variavel xml_req de CHAR para LONGCHAR
                            pois o retorno do xml estava estourando a variavel
                            ocasionando problemas na tela CONTAS e na 
                            imressão da proposta de emprestimo (Tiago/Thiago)
                            SD 453764.
                            
               07/07/2017 - P337 - Ajustada Imprime_Consulta para nao mais buscar 
                            fixo o nrseqdet = 1 pois quando a consulta foi efetuada
                            na Esteira o Titular nem sempre eh o primeiro a ser 
                            retornado (Marcos-Supero)

               19/12/2017 - Apresentar erros nos Biros Externos. (Jaison/James - M464)

............................................................................ */  

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/var_oracle.i   }  
{ sistema/generico/includes/b1wgen0024tt.i }
{ sistema/generico/includes/b1wgen0191tt.i }

DEF STREAM str_1.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstagavo AS CHAR                                           NO-UNDO.
DEF VAR aux_dstagpai AS CHAR                                           NO-UNDO.                            
                             
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_dsendere AS CHAR                                           NO-UNDO.
DEF VAR aux_nmbairro AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidade AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufende AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcepend AS CHAR                                           NO-UNDO.
DEF VAR aux_dtatuend AS DATE                                           NO-UNDO.
DEF VAR aux_nmtitcon AS CHAR                                           NO-UNDO.
DEF VAR aux_dtconbir AS DATE                                           NO-UNDO.
DEF VAR aux_inreapro AS CHAR                                           NO-UNDO.
DEF VAR aux_nmtitcab AS CHAR                                           NO-UNDO.
DEF VAR aux_dscpfcgc AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinha1 AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinha2 AS CHAR                                           NO-UNDO.
DEF VAR aux_dssepara AS CHAR                                           NO-UNDO.
DEF VAR aux_dsnegati AS CHAR EXTENT 99                                 NO-UNDO.
DEF VAR aux_vlnegati AS DECI EXTENT 99                                 NO-UNDO.
DEF VAR aux_dtultneg AS DATE EXTENT 99                                 NO-UNDO.
DEF VAR aux_dscabec  AS CHAR INIT "************"                       NO-UNDO.
DEF VAR aux_dscabe2  AS CHAR INIT "************"                       NO-UNDO.
DEF VAR aux_dsconsul AS CHAR                                           NO-UNDO.
DEF VAR aux_qtcaract AS INTE                                           NO-UNDO.

DEF VAR rel_dsnegati AS CHAR                                       NO-UNDO.


FORM aux_dscabec  AT 40 NO-LABEL          FORMAT "x(12)"
     SKIP
     aux_dsconsul AT 40 NO-LABEL          FORMAT "x(12)"
     SKIP
     aux_dscabe2  AT 40 NO-LABEL          FORMAT "x(12)"
     WITH SIDE-LABEL WIDTH 132 FRAME f_cabecalho.

FORM aux_nrdconta AT 03 LABEL "Conta/dv"         FORMAT "zzzz,zzz,9"
     aux_dtconbir AT 60 LABEL "Data da consulta" FORMAT "99/99/9999"
     aux_nmtitcon AT 07 LABEL "Nome"             FORMAT "x(40)"
     aux_inreapro AT 60 LABEL "Reaproveitamento" FORMAT "x(3)"
     aux_dscpfcgc AT 03 LABEL "CPF/CNPJ"         FORMAT "x(20)"  
     WITH SIDE-LABEL WIDTH 132 FRAME f_cabecalho_2.

FORM aux_dsendere COLUMN-LABEL "Endereco"            FORMAT "x(30)"
     aux_nmbairro COLUMN-LABEL "Bairro"              FORMAT "x(20)"
     aux_nmcidade COLUMN-LABEL "Cidade"              FORMAT "x(20)"
     aux_cdufende COLUMN-LABEL "UF"                  FORMAT "x(02)"
     aux_nrcepend COLUMN-LABEL "CEP"                 FORMAT "x(15)"
     WITH DOWN WIDTH 132 FRAME f_dados_endereco.

FORM "Anotacoes                        Qtde                  Valor Dt. Ultima"
     WITH WIDTH 132 FRAME f_titulo_serasa.
                                                                 
FORM rel_dsnegati        AT 01 FORMAT "x(30)"     
     tt-craprpf.dsnegati AT 34 FORMAT "x(14)"     
     tt-craprpf.vlnegati AT 49 FORMAT "z,zzz,zz9.99"
     tt-craprpf.dtultneg AT 62 FORMAT "99/99/9999"
     WITH DOWN NO-LABELS WIDTH 132 FRAME f_anotacoes_1. 


PROCEDURE Busca_Biro:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_nrconbir AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_nrseqdet AS INTE                              NO-UNDO.


    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_busca_consulta_biro
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                            OUTPUT 0,
                                            OUTPUT 0).

    CLOSE STORED-PROC pc_busca_consulta_biro
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_nrconbir  = pc_busca_consulta_biro.pr_nrconbir 
                             WHEN pc_busca_consulta_biro.pr_nrconbir <> ?

           par_nrseqdet = pc_busca_consulta_biro.pr_nrseqdet
                             WHEN pc_busca_consulta_biro.pr_nrseqdet <> ?.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Busca_Biro_Emp_Lim:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_inprodut AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctacon AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcon AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM par_nrconbir AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_nrseqdet AS INTE                              NO-UNDO.

    DEF VAR aux_contador AS INTE                                       NO-UNDO.


    DO aux_contador = 1 TO 5:
   
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
       
       RUN STORED-PROCEDURE pc_busca_cns_biro
           aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                INPUT par_nrdconta,
                                                INPUT par_nrctrato,
                                                INPUT par_inprodut, 
                                                INPUT par_nrctacon,
                                                INPUT par_nrcpfcon,
                                               OUTPUT 0,
                                               OUTPUT 0).
       
       CLOSE STORED-PROC pc_busca_cns_biro
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
       
       { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
       
       ASSIGN par_nrconbir  = pc_busca_cns_biro.pr_nrconbir 
                                WHEN pc_busca_cns_biro.pr_nrconbir <> ?
       
              par_nrseqdet = pc_busca_cns_biro.pr_nrseqdet
                                WHEN pc_busca_cns_biro.pr_nrseqdet <> ?.

       IF   par_nrconbir <> 0   AND
            par_nrseqdet <> 0   THEN
            LEAVE.

    END.

    RETURN "OK".

END PROCEDURE.
            

PROCEDURE Busca_Situacao:

    DEF  INPUT PARAM par_nrconbir AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrseqdet AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_cdbircon AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_dsbircon AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_cdmodbir AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_dssituac AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_dsmodbir AS CHAR                              NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_verifica_situacao 
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_nrconbir,
                                             INPUT par_nrseqdet,
                                            OUTPUT 0, 
                                            OUTPUT "", 
                                            OUTPUT 0,
                                            OUTPUT "", 
                                            OUTPUT ""). 

    CLOSE STORED-PROC pc_verifica_situacao
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_cdbircon = pc_verifica_situacao.pr_cdbircon 
                             WHEN pc_verifica_situacao.pr_cdbircon <> ?

           par_dsbircon = pc_verifica_situacao.pr_dsbircon
                             WHEN pc_verifica_situacao.pr_dsbircon <> ?    

           par_cdmodbir = pc_verifica_situacao.pr_cdmodbir
                             WHEN pc_verifica_situacao.pr_cdmodbir <> ? 

           par_dssituac = pc_verifica_situacao.pr_flsituac
                             WHEN pc_verifica_situacao.pr_flsituac <> ?
        
           par_dsmodbir = pc_verifica_situacao.pr_dsmodbir
                             WHEN pc_verifica_situacao.pr_dsmodbir <> ?.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Verifica_Consulta_Biro:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_inprodut AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-msg-confirma.                               
    DEF OUTPUT PARAM par_flmudfai AS CHAR                             NO-UNDO.

    DEF VAR aux_inobriga AS CHAR                                      NO-UNDO.
    DEF VAR aux_cdlcremp AS INTE                                      NO-UNDO.
    DEF VAR aux_cdfinemp AS INTE                                      NO-UNDO.
    DEF VAR aux_vlprodut AS DECI                                      NO-UNDO.
    DEF VAR aux_dsmensag AS CHAR                                      NO-UNDO.
    DEF VAR bkp_cdcritic AS INTE                                      NO-UNDO.
    DEF VAR bkp_dscritic AS CHAR                                      NO-UNDO.


    Solicita:
    DO ON ERROR UNDO, LEAVE:

       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.
      
       IF   NOT AVAIL crapass THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE Solicita.
            END.
      
       IF   par_inprodut = 1   THEN /* Emprestimo */
            DO:
                FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                   crawepr.nrdconta = par_nrdconta   AND
                                   crawepr.nrctremp = par_nrctrato   
                                   NO-LOCK NO-ERROR.
            
                IF   NOT AVAIL crawepr   THEN
                     DO:
                         ASSIGN aux_cdcritic = 510.
                         LEAVE Solicita.
                     END.

                ASSIGN aux_vlprodut = crawepr.vlemprst
                       aux_cdfinemp = crawepr.cdfinemp
                       aux_cdlcremp = crawepr.cdlcremp.

            END.
       ELSE      /* Limite de credito */
            DO: 
                FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                   craplim.nrdconta = par_nrdconta   AND
                                   craplim.tpctrlim = 1              AND
                                   craplim.nrctrlim = par_nrctrato   
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL craplim   THEN
                     DO:
                         ASSIGN aux_cdcritic = 484.
                         LEAVE Solicita.
                     END.

                ASSIGN aux_vlprodut = craplim.vllimite
                       aux_cdfinemp = 0
                       aux_cdlcremp = 0.
          
            END.

       RUN Obrigacao_Consulta (INPUT par_cdcooper, 
                               INPUT par_inprodut,
                               INPUT crapass.inpessoa, 
                               INPUT aux_vlprodut, 
                               INPUT aux_cdfinemp, 
                               INPUT aux_cdlcremp, 
                              OUTPUT aux_inobriga). 
       
       IF   aux_inobriga <> "N"   THEN
            DO:
                IF   par_cddopcao = "I"   THEN /* Inclusao */
                     DO:                                            
                         RUN Solicita_Consulta_Biro (INPUT par_cdcooper,
                                                     INPUT par_nrdconta,
                                                     INPUT par_inprodut,
                                                     INPUT par_nrctrato,
                                                     INPUT par_cdoperad,
                                                    OUTPUT aux_cdcritic,
                                                    OUTPUT aux_dscritic,
                                                    OUTPUT aux_dsmensag).

                         IF   aux_dsmensag <> ""   THEN /* Deu certo*/
                              DO:
                                  RUN atualiza_inf_cadastrais 
                                                (INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_inprodut,
                                                 INPUT par_nrctrato,
                                                OUTPUT TABLE tt-erro).
                              END.

                     END.
                ELSE       /* Alteracao */
                     DO:
                         RUN Verifica_Mud_Faixa (INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_inprodut,
                                                 INPUT par_nrctrato,
                                                OUTPUT par_flmudfai).

                         /* Se mudou de faixa, efetua as consultas */
                         IF   par_flmudfai = "S"   THEN
                              RUN Solicita_Consulta_Biro (INPUT par_cdcooper,
                                                          INPUT par_nrdconta,
                                                          INPUT par_inprodut,
                                                          INPUT par_nrctrato,
                                                          INPUT par_cdoperad,
                                                         OUTPUT aux_cdcritic,
                                                         OUTPUT aux_dscritic,
                                                         OUTPUT aux_dsmensag).
                                                                                 
                     END.                     
            END.

       IF   par_inprodut = 1      AND   /* Emprestimo */ 
            par_flmudfai <> "N"   THEN 
            DO:
                RUN efetua_analise_ctr (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrctrato,
                                       OUTPUT bkp_cdcritic,
                                       OUTPUT bkp_dscritic). 

                IF   aux_cdcritic = 0    AND
                     aux_dscritic = ""   THEN
                     ASSIGN aux_cdcritic = bkp_cdcritic
                            aux_dscritic = bkp_dscritic.

            END.

    END.

    /* Qualquer erro nesta procedure, devera ser retonada somente com */
    /* uma mensagem, sem comprometer o resto da execucao */
    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   OR  
         aux_dsmensag <> ""   THEN
         DO:
             IF   aux_cdcritic > 0    AND 
                  aux_dscritic = ""   THEN
                  DO:
                      FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                         NO-LOCK NO-ERROR.

                      IF   AVAIL crapcri    THEN
                           ASSIGN aux_dscritic = crapcri.dscritic. 
                  END.
             ELSE
             IF   aux_dsmensag <> ""   THEN
                  ASSIGN aux_dscritic = aux_dsmensag.

             CREATE tt-msg-confirma.
             ASSIGN tt-msg-confirma.inconfir = 3
                    tt-msg-confirma.dsmensag = aux_dscritic.  
         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Solicita_Consulta_Biro:

   DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_inprodut AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_nrctrato AS INTE                               NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
   DEF OUTPUT PARAM par_cdcritic AS INTE                               NO-UNDO.
   DEF OUTPUT PARAM par_dscritic AS CHAR                               NO-UNDO.
   DEF OUTPUT PARAM par_dsmensag AS CHAR                               NO-UNDO.


   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
   
   RUN STORED-PROCEDURE pc_solicita_consulta_biro
       aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_nrctrato,
                                            INPUT par_inprodut,
                                            INPUT par_cdoperad,
                                            INPUT 0, /* nao validar esteira */
                                           OUTPUT 0,
                                           OUTPUT "").
   
   CLOSE STORED-PROC pc_solicita_consulta_biro
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
   
   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
   ASSIGN par_cdcritic = pc_solicita_consulta_biro.pr_cdcritic
                 WHEN pc_solicita_consulta_biro.pr_cdcritic <> ?
   
          par_dscritic = pc_solicita_consulta_biro.pr_dscritic
                 WHEN pc_solicita_consulta_biro.pr_dscritic <> ?.
   
   IF   par_cdcritic <> 0    OR
        par_dscritic <> ""   THEN
        RETURN "NOK".
   
   ASSIGN par_dsmensag = "Consultas efetuadas com sucesso!".

   RETURN "OK".

END PROCEDURE.

PROCEDURE Verifica_Mud_Faixa: 

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_inprodut AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_flmudfai AS CHAR                              NO-UNDO.


    IF   par_inprodut = 1 THEN
         RUN Verifica_Mud_Faixa_Emp (INPUT par_cdcooper,
                                     INPUT par_nrdconta,
                                     INPUT par_nrctrato,
                                    OUTPUT par_flmudfai).
    ELSE 
         RUN Verifica_Mud_Faixa_Lim (INPUT par_cdcooper,
                                     INPUT par_nrdconta,
                                     INPUT par_nrctrato,
                                    OUTPUT par_flmudfai).
             
    RETURN "OK".

END PROCEDURE.


PROCEDURE Verifica_Mud_Faixa_Emp: 

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_flmudfai AS CHAR                              NO-UNDO.
    
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_verifica_mud_faixa_emp
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctrato,
                                            OUTPUT "").
    
    CLOSE STORED-PROC pc_verifica_mud_faixa_emp
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN par_flmudfai = pc_verifica_mud_faixa_emp.pr_flmudfai
                             WHEN pc_verifica_mud_faixa_emp.pr_flmudfai <> ?.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Verifica_Mud_Faixa_Lim: 

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_flmudfai AS CHAR                              NO-UNDO.
    
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_verifica_mud_faixa_lim
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctrato,
                                            OUTPUT "").
    
    CLOSE STORED-PROC pc_verifica_mud_faixa_lim
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN par_flmudfai = pc_verifica_mud_faixa_lim.pr_flmudfai
                             WHEN pc_verifica_mud_faixa_lim.pr_flmudfai <> ?.

    RETURN "OK".

END PROCEDURE.


PROCEDURE efetua_analise_ctr:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_efetua_analise_ctr
         aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT par_cdcooper, /* Cooperativa */
                       INPUT par_nrdconta, /* Conta       */
                       INPUT par_nrctremp, /* Contrato    */
                      OUTPUT 0,
                      OUTPUT "").

    CLOSE STORED-PROC pc_efetua_analise_ctr
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
 
    ASSIGN par_cdcritic = pc_efetua_analise_ctr.pr_cdcritic
                             WHEN pc_efetua_analise_ctr.pr_cdcritic <> ?
           par_dscritic = pc_efetua_analise_ctr.pr_dscritic
                             WHEN pc_efetua_analise_ctr.pr_dscritic <> ?.

    IF   par_cdcritic <> 0    OR
         par_dscritic <> ""   THEN
         RETURN "NOK".

    RETURN "OK".

END PROCEDURE.


PROCEDURE Imprime_Dados_Proposta:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.   
    DEF  INPUT PARAM par_inprodut AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdtipcon AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrctacon AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcon AS DECI                              NO-UNDO.
    DEF  INPUT PARAM par_iddoaval AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarquiv AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                               
                                                                      

    DEF VAR aux_cdtipcon AS INTE                                       NO-UNDO.
    DEF VAR aux_nrconbir AS INTE                                       NO-UNDO.
    DEF VAR aux_nrseqdet AS INTE                                       NO-UNDO.
    DEF VAR aux_dsnegati AS CHAR EXTENT 99                             NO-UNDO.
    DEF VAR aux_vlnegati AS DECI EXTENT 99                             NO-UNDO.
    DEF VAR aux_dtultneg AS DATE EXTENT 99                             NO-UNDO.
    DEF VAR aux_nmtitcon AS CHAR                                       NO-UNDO.
    DEF VAR aux_dtconbir AS DATE                                       NO-UNDO.
    DEF VAR aux_nmtitcab AS CHAR                                       NO-UNDO.
    DEF VAR aux_dscpfcgc AS CHAR                                       NO-UNDO.
    DEF VAR aux_inreapro AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdbircon AS INTE                                       NO-UNDO.
    DEF VAR aux_dsbircon AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdmodbir AS INTE                                       NO-UNDO.
    DEF VAR aux_dssituac AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsmodbir AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsconsul AS CHAR                                       NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI  INIT FALSE                           NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                     NO-UNDO.


    /* Variáveis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.
    DEF VAR xRoot         AS HANDLE   NO-UNDO.
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.
    DEF VAR xField        AS HANDLE   NO-UNDO.
    DEF VAR xText         AS HANDLE   NO-UNDO.
    DEF VAR aux_cont      AS INTEGER  NO-UNDO.
    DEF VAR aux_cont2     AS INTEGER  NO-UNDO.
    DEF VAR aux_cont3     AS INTEGER  NO-UNDO.
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO.
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.


    EMPTY TEMP-TABLE tt-erros-bir.


    FORM "Resumo das informacoes do" aux_dsconsul NO-LABEL  FORMAT "x(70)"     
         SKIP
         aux_dtconbir LABEL "Data da Consulta"              FORMAT "99/99/9999"
         aux_inreapro LABEL "Reaproveitamento"
         SKIP
         tt-central-risco.dtdrisco LABEL "Consulta SCR"     FORMAT "99/99/9999"
         SPACE(5)
         tt-central-risco.qtopescr LABEL "Qtd. Operacoes"   FORMAT "zz9"
         SPACE(5)
         tt-central-risco.qtifoper LABEL "Qtd. IF com ope." FORMAT "zz9"
         SKIP
         tt-central-risco.vltotsfn LABEL "Endividamento"    FORMAT "z,zzz,zz9.99"
         SPACE(2)
         tt-central-risco.vlopescr LABEL "Vencidas"         FORMAT "z,zzz,zz9.99"
         SPACE(2)
         tt-central-risco.vlrpreju LABEL "Prej."            FORMAT "z,zzz,zz9.99"
         SKIP
         aux_dsmodbir              NO-LABEL                 FORMAT "x(30)"
         SKIP(1)
         WITH SIDE-LABELS WIDTH 137 FRAME f_scr_cab.

    FORM 
         tt-erros-bir.dscritic     NO-LABEL                 FORMAT "x(130)"
         WITH SIDE-LABELS NO-BOX WIDTH 137 FRAME f_erro_bir.

    FORM "Anotacoes negativas      Quantidade           Valor"
         AT 01
         "SPC"              AT 01
         aux_dsnegati[99]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[99]   AT 40 FORMAT "z,zzz,zz9.99"
         "PEFIN/REFIN"      AT 01
         aux_dsnegati[98]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[98]   AT 40 FORMAT "z,zzz,zz9.99"
         "PROTESTO"         AT 01
         aux_dsnegati[03]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[03]   AT 40 FORMAT "z,zzz,zz9.99"
         "CHEQUE SEM FUNDO" AT 01
         aux_dsnegati[06]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[06]   AT 40 FORMAT "z,zzz,zz9.99"
         SKIP(1)
         WITH SIDE-LABELS NO-UNDERLINE NO-BOX NO-LABELS WIDTH 96 
              FRAME f_anotacoes_fis.

    FORM "SOCIO"
         SKIP
         aux_dscpfcgc LABEL "CPF"  AT 01       FORMAT "x(25)"
         aux_nmtitcon LABEL "Nome"             FORMAT "x(40)"
         SKIP(1)
         "Anotacoes negativas      Quantidade           Valor Data da ultima" 
         AT 01
         "REFIN"            AT 01                               
         aux_dsnegati[01]   AT 26 FORMAT "x(11)"       
         aux_vlnegati[01]   AT 40 FORMAT "z,zzz,zz9.99"  
         aux_dtultneg[01]   AT 53 FORMAT "99/99/9999"  
         "PEFIN"            AT 01
         aux_dsnegati[02]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[02]   AT 40 FORMAT "z,zzz,zz9.99"
         aux_dtultneg[02]   AT 53 FORMAT "99/99/9999"
         "PROTESTO"         AT 01
         aux_dsnegati[03]   AT 26 FORMAT "x(11)"  
         aux_vlnegati[03]   AT 40 FORMAT "z,zzz,zz9.99"
         aux_dtultneg[03]   AT 53 FORMAT "99/99/9999"
         "ACAO JUDICIAL"    AT 01                      
         aux_dsnegati[04]   AT 26 FORMAT "x(11)"      
         aux_vlnegati[04]   AT 40 FORMAT "z,zzz,zz9.99" 
         aux_dtultneg[04]   AT 53 FORMAT "99/99/9999" 
         "PARTICIPACAO EM FALENC."   AT 01             
         aux_dsnegati[05]   AT 26 FORMAT "x(11)"       
         aux_vlnegati[05]   AT 40 FORMAT "z,zzz,zz9.99"  
         aux_dtultneg[05]   AT 53 FORMAT "99/99/9999"  
         "CHEQUE SEM FUNDO" AT 01
         aux_dsnegati[06]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[06]   AT 40 FORMAT "z,zzz,zz9.99"
         aux_dtultneg[06]   AT 53 FORMAT "99/99/9999" 
         "CHEQUES SUST. E EXTR."   AT 01                
         aux_dsnegati[07]   AT 26 FORMAT "x(11)"        
         aux_vlnegati[07]   AT 40 FORMAT "z,zzz,zz9.99"   
         aux_dtultneg[07]   AT 53 FORMAT "99/99/9999"  
         SKIP(1)
         WITH DOWN SIDE-LABELS NO-UNDERLINE NO-BOX NO-LABELS WIDTH 96 
              FRAME f_anotacoes_soc.
    
    FORM "Resumo das informacoes da Empresa"
         SKIP(1)
         "Anotacoes negativas      Quantidade           Valor Data da ultima" 
         AT 01
         "REFIN"            AT 01
         aux_dsnegati[01]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[01]   AT 40 FORMAT "z,zzz,zz9.99"
         aux_dtultneg[01]   AT 53 FORMAT "99/99/9999"
         "PEFIN"            AT 01
         aux_dsnegati[02]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[02]   AT 40 FORMAT "z,zzz,zz9.99"
         aux_dtultneg[02]   AT 53 FORMAT "99/99/9999"
         "PROTESTO"         AT 01
         aux_dsnegati[03]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[03]   AT 40 FORMAT "z,zzz,zz9.99"
         aux_dtultneg[03]   AT 53 FORMAT "99/99/9999"
         "ACAO JUDICIAL"    AT 01
         aux_dsnegati[04]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[04]   AT 40 FORMAT "z,zzz,zz9.99"
         aux_dtultneg[04]   AT 53 FORMAT "99/99/9999"
         "PARTICIPACAO EM FALENC." AT 01
         aux_dsnegati[05]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[05]   AT 40 FORMAT "z,zzz,zz9.99"
         aux_dtultneg[05]   AT 53 FORMAT "99/99/9999"
         "CHEQUE SEM FUNDO" AT 01
         aux_dsnegati[06]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[06]   AT 40 FORMAT "z,zzz,zz9.99"
         aux_dtultneg[06]   AT 53 FORMAT "99/99/9999"
         "CHEQUES SUST. E EXTRAV." AT 01
         aux_dsnegati[07]   AT 26 FORMAT "x(11)"   
         aux_vlnegati[07]   AT 40 FORMAT "z,zzz,zz9.99"
         aux_dtultneg[07]   AT 53 FORMAT "99/99/9999"
         SKIP(1)
         WITH SIDE-LABELS NO-UNDERLINE NO-BOX NO-LABELS WIDTH 96 
              FRAME f_anotacoes_emp.

    Imprime_Proposta:
    DO ON ERROR UNDO, LEAVE.

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper.

        IF   NOT AVAIL crapcop    THEN
             DO:
                 ASSIGN aux_cdcritic = 651.
                 LEAVE Imprime_Proposta.
             END.

        /* Efetuar a chamada a rotina Oracle */
        RUN STORED-PROCEDURE pc_lista_erros_biro_proposta
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                            ,INPUT par_nrdconta
                                            ,INPUT par_nrctrato
                                            ,INPUT par_inprodut
                                            ,OUTPUT ?     /* pr_clob_xml */
                                            ,OUTPUT 0     /* pr_cdcritic */
                                            ,OUTPUT "").  /* pr_dscritic */

        /* Fechar o procedimento para buscarmos o resultado */
        CLOSE STORED-PROC pc_lista_erros_biro_proposta
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        /* Busca possíveis erros */
        ASSIGN aux_cdcritic = 0
               aux_dscritic = ""
               aux_cdcritic = pc_lista_erros_biro_proposta.pr_cdcritic
                              WHEN pc_lista_erros_biro_proposta.pr_cdcritic <> ?
               aux_dscritic = pc_lista_erros_biro_proposta.pr_dscritic
                              WHEN pc_lista_erros_biro_proposta.pr_dscritic <> ?.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            DO:
                LEAVE Imprime_Proposta.
            END.
        ELSE
            DO:
                /* Inicializando objetos para leitura do XML */
                CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */
                CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */
                CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */
                CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */
                CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */

                /* Buscar o XML na tabela de retorno da procedure Progress */
                ASSIGN xml_req = pc_lista_erros_biro_proposta.pr_clob_xml.

                /* Efetuar a leitura do XML*/
                SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1.
                PUT-STRING(ponteiro_xml,1) = xml_req.

                xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
                xDoc:GET-DOCUMENT-ELEMENT(xRoot).

                DO  aux_cont = 1 TO xRoot:NUM-CHILDREN:

                    xRoot:GET-CHILD(xRoot2,aux_cont).

                    IF xRoot2:SUBTYPE <> "ELEMENT"   THEN
                       NEXT.

                    DO  aux_cont2 = 1 TO xRoot2:NUM-CHILDREN:

                      xRoot2:GET-CHILD(xField,aux_cont2).

                      IF xField:SUBTYPE <> "ELEMENT" THEN
                         NEXT.

                      IF xField:NUM-CHILDREN = 0 THEN
                         NEXT.

                      xField:GET-CHILD(xText,1).
                        
                      CREATE tt-erros-bir.
                      ASSIGN tt-erros-bir.dscritic = xText:NODE-VALUE WHEN xField:NAME = "erro".

                    END.

                END.

                SET-SIZE(ponteiro_xml) = 0.

                DELETE OBJECT xDoc.
                DELETE OBJECT xRoot.
                DELETE OBJECT xRoot2.
                DELETE OBJECT xField.
                DELETE OBJECT xText.
            END.

        ASSIGN par_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                              "consultas-" + STRING(par_cdtipcon)      +
                              STRING(TIME) + ".ex".

        OUTPUT STREAM str_1 TO VALUE (par_nmarquiv) .

        IF   par_iddoaval > 0   THEN
             ASSIGN aux_cdtipcon = 3.
        ELSE 
             ASSIGN aux_cdtipcon = par_cdtipcon.

        RUN sistema/generico/procedures/b1wgen0024.p 
            PERSISTENT SET h-b1wgen0024.

        RUN obtem-valores-central-risco IN h-b1wgen0024 
                                        (INPUT par_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT par_dtmvtolt,
                                         INPUT aux_cdtipcon,
                                         INPUT par_nrdconta,
                                         INPUT par_inprodut,
                                         INPUT par_nrctrato,
                                         INPUT par_nrctacon,
                                         INPUT par_nrcpfcon,
                                         INPUT FALSE,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-central-risco).

        DELETE PROCEDURE h-b1wgen0024.
 
        IF   RETURN-VALUE <> "OK"   THEN
             DO: 
                 ASSIGN aux_flgtrans = TRUE.
                 LEAVE Imprime_Proposta.
             END.
            
        ASSIGN aux_dsconsul = IF   par_cdtipcon <= 2   AND
                                   par_iddoaval  = 0   THEN
                                   "TITULAR"
                              ELSE
                              IF   par_cdtipcon = 5   THEN
                                   "CONJUGE" 
                              ELSE
                                   "AVALISTA " + STRING(par_iddoaval).

        FIND FIRST tt-central-risco NO-LOCK NO-ERROR.

        IF  NOT AVAIL tt-central-risco  THEN
            CREATE tt-central-risco.

        RUN Busca_Biro_Emp_Lim (INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT par_inprodut,
                                INPUT par_nrctrato,
                                INPUT par_nrctacon,
                                INPUT par_nrcpfcon,
                               OUTPUT aux_nrconbir,
                               OUTPUT aux_nrseqdet).
                          
        /* Se nao tem consulta, mostra os dados do SCR e volta */
        /* Se for consulta ao conjuge */
        IF   RETURN-VALUE <> "OK"   OR
             aux_nrconbir = 0       OR   
             aux_nrseqdet = 0       THEN
             DO:  
                 DISPLAY STREAM str_1 aux_dsconsul
                                      tt-central-risco.dtdrisco 
                                      tt-central-risco.qtopescr
                                      tt-central-risco.qtifoper
                                      tt-central-risco.vltotsfn
                                      tt-central-risco.vlopescr
                                      tt-central-risco.vlrpreju
                                      WITH FRAME f_scr_cab.

                 ASSIGN aux_flgtrans = TRUE.

                 /* Exibe os erros do biro */
                 FOR EACH tt-erros-bir BREAK BY tt-erros-bir.dscritic:
                   DISPLAY STREAM str_1 tt-erros-bir.dscritic
                                        WITH FRAME f_erro_bir.

                   DOWN WITH FRAME f_erro_bir.
                   
                   IF LAST(tt-erros-bir.dscritic) THEN
                      DISPLAY STREAM str_1 SKIP WITH FRAME f_erro_bir.
                 END.

                 LEAVE Imprime_Proposta.
             END.

        RUN Busca_Situacao (INPUT aux_nrconbir,
                            INPUT aux_nrseqdet,
                           OUTPUT aux_cdbircon,
                           OUTPUT aux_dsbircon,
                           OUTPUT aux_cdmodbir,
                           OUTPUT aux_dssituac,
                           OUTPUT aux_dsmodbir).
                   
        RUN Consulta_Geral (INPUT aux_nrconbir,
                            INPUT aux_nrseqdet,
                           OUTPUT aux_dscritic,
                           OUTPUT TABLE tt-xml-geral).

        /* Se nao retornou as consulta, mostra os dados da scr e volta*/
        IF   RETURN-VALUE <> "OK"   THEN
             DO:
                 DISPLAY STREAM str_1 aux_dsconsul
                                      tt-central-risco.dtdrisco 
                                      tt-central-risco.qtopescr
                                      tt-central-risco.qtifoper
                                      tt-central-risco.vltotsfn
                                      tt-central-risco.vlopescr
                                      tt-central-risco.vlrpreju
                                      WITH FRAME f_scr_cab.

                 ASSIGN aux_flgtrans = TRUE.

                 /* Exibe os erros do biro */
                 FOR EACH tt-erros-bir BREAK BY tt-erros-bir.dscritic:
                   DISPLAY STREAM str_1 tt-erros-bir.dscritic
                                        WITH FRAME f_erro_bir.

                   DOWN WITH FRAME f_erro_bir.
                   
                   IF LAST(tt-erros-bir.dscritic) THEN
                      DISPLAY STREAM str_1 SKIP WITH FRAME f_erro_bir.
                 END.

                 LEAVE Imprime_Proposta.
             END.

        IF   CAN-DO("1,2,3,5",STRING(par_cdtipcon))   THEN                    
             RUN Trata_Anotacoes (INPUT TABLE tt-xml-geral,                
                                 OUTPUT aux_dsnegati,                      
                                 OUTPUT aux_vlnegati,       
                                 OUTPUT aux_dtultneg,       
                                 OUTPUT TABLE tt-craprpf).  

        RUN Busca_Dados_Consultado (INPUT 1,
                                    INPUT TABLE tt-xml-geral,
                                    OUTPUT aux_nmtitcon,
                                    OUTPUT aux_dtconbir, 
                                    OUTPUT aux_nmtitcab, 
                                    OUTPUT aux_dscpfcgc,
                                    OUTPUT aux_inreapro).

        /* Concatenar o nome do consultado */
        IF   aux_dsconsul <> "TITULAR"   THEN
             ASSIGN aux_dsconsul = aux_dsconsul + " - " + aux_nmtitcon.

        /* Descricao da consulta */
        IF   aux_cdbircon = 1   THEN
             ASSIGN aux_dsmodbir = "Consulta SPC - " + aux_dsmodbir.
        ELSE
             ASSIGN aux_dsmodbir = "Consulta SERASA - " + aux_dsmodbir.

        DISPLAY STREAM str_1 aux_dsconsul
                             aux_dtconbir
                             aux_inreapro               
                             tt-central-risco.dtdrisco 
                             tt-central-risco.qtopescr
                             tt-central-risco.qtifoper
                             tt-central-risco.vltotsfn
                             tt-central-risco.vlopescr
                             tt-central-risco.vlrpreju
                             aux_dsmodbir
                             WITH FRAME f_scr_cab.

       /* Exibe os erros do biro */
       FOR EACH tt-erros-bir BREAK BY tt-erros-bir.dscritic:
         DISPLAY STREAM str_1 tt-erros-bir.dscritic
                              WITH FRAME f_erro_bir.

         DOWN WITH FRAME f_erro_bir.
         
         IF LAST(tt-erros-bir.dscritic) THEN
            DISPLAY STREAM str_1 SKIP WITH FRAME f_erro_bir.
       END.
 
       IF    aux_cdbircon = 1   THEN /* Pessoa Fisica */
             DO: 
                 DISPLAY STREAM str_1 
                               aux_dsnegati[99]  
                               aux_vlnegati[99] WHEN aux_dsnegati[99] <> "Nada Consta"
                               aux_dsnegati[98]  
                               aux_vlnegati[98] WHEN aux_dsnegati[98] <> "Nada Consta"
                               aux_dsnegati[03] 
                               aux_vlnegati[03] WHEN aux_dsnegati[03] <> "Nada Consta" 
                               aux_dsnegati[06]  
                               aux_vlnegati[06] WHEN aux_dsnegati[06] <> "Nada Consta"
                               WITH FRAME f_anotacoes_fis.
             END.
       ELSE  
       IF    aux_cdbircon =  2   THEN /* Pessoa juridica */
             DO:                  
                 DISPLAY STREAM str_1  
                      aux_dsnegati[02]    
                      aux_vlnegati[02] WHEN aux_dsnegati[02] <> "Nada Consta" 
                      aux_dtultneg[02]
                      aux_dsnegati[03]   
                      aux_vlnegati[03] WHEN aux_dsnegati[03] <> "Nada Consta" 
                      aux_dtultneg[03]
                      aux_dsnegati[06]    
                      aux_vlnegati[06] WHEN aux_dsnegati[06] <> "Nada Consta"
                      aux_dtultneg[06]
                      aux_dsnegati[01]   
                      aux_vlnegati[01] WHEN aux_dsnegati[01] <> "Nada Consta"
                      aux_dtultneg[01]
                      aux_dsnegati[04]   
                      aux_vlnegati[04] WHEN aux_dsnegati[04] <> "Nada Consta"
                      aux_dtultneg[04]
                      aux_dsnegati[05]   
                      aux_vlnegati[05] WHEN aux_dsnegati[05] <> "Nada Consta"
                      aux_dtultneg[05]
                      aux_dsnegati[07]  
                      aux_vlnegati[07] WHEN aux_dsnegati[07] <> "Nada Consta"
                      aux_dtultneg[07]
                      WITH FRAME f_anotacoes_emp.   
                 
                 RUN Trata_Societarios (INPUT TABLE tt-xml-geral,                             
                                        INPUT 1,                    
                                       OUTPUT TABLE tt-crapcbd).    
                                                                                    
                 RUN Trata_Anotacoes_Pj (INPUT TABLE tt-xml-geral,          
                                        OUTPUT TABLE tt-craprpf).           
                                                                                    
                 /* Socios */                                                       
                 FOR EACH tt-crapcbd BREAK BY tt-crapcbd.dscpfcgc:                  
                                                                                                                                       
                     ASSIGN aux_dscpfcgc = tt-crapcbd.dscpfcgc                      
                            aux_nmtitcon = tt-crapcbd.nmtitcon.                     
                                                                                    
                     /* Anotacoes do socio */                                       
                     FOR EACH tt-craprpf WHERE                                      
                              tt-craprpf.dscpfcgc = tt-crapcbd.dscpfcgc:            
                                                                                    
                         ASSIGN aux_dsnegati[tt-craprpf.innegati] =                 
                                            tt-craprpf.dsnegati                     
                                aux_vlnegati[tt-craprpf.innegati] =                 
                                            tt-craprpf.vlnegati                     
                                aux_dtultneg[tt-craprpf.innegati] =                 
                                            tt-craprpf.dtultneg.                    
                                                                                    
                     END.                                                           
                                                                                    
                     DISPLAY STREAM str_1                                           
                            aux_dscpfcgc     aux_nmtitcon                           
                            aux_dsnegati[02]                                        
                            aux_vlnegati[02] WHEN aux_dsnegati[02] <> "Nada Consta" 
                            aux_dtultneg[02]                                        
                            aux_dsnegati[01]                                        
                            aux_vlnegati[01] WHEN aux_dsnegati[01] <> "Nada Consta" 
                            aux_dtultneg[01]                                        
                            aux_dsnegati[03]                                        
                            aux_vlnegati[03] WHEN aux_dsnegati[03] <> "Nada Consta" 
                            aux_dtultneg[03]                                        
                            aux_dsnegati[04]                                        
                            aux_vlnegati[04] WHEN aux_dsnegati[04] <> "Nada Consta" 
                            aux_dtultneg[04]                                        
                            aux_dsnegati[05]                                        
                            aux_vlnegati[05] WHEN aux_dsnegati[05] <> "Nada Consta" 
                            aux_dtultneg[05]                                        
                            aux_dsnegati[07]                                        
                            aux_vlnegati[07] WHEN aux_dsnegati[07] <> "Nada Consta" 
                            aux_dtultneg[07]                                        
                            aux_dsnegati[06]                                        
                            aux_vlnegati[06] WHEN aux_dsnegati[06] <> "Nada Consta" 
                            aux_dtultneg[06]                                        
                            WITH FRAME f_anotacoes_soc.                             
                                                                                    
                     DOWN WITH FRAME f_anotacoes_soc.                               
                                                                                    
                 END. /* Fim for each socios */ 

             END.   
        ASSIGN aux_flgtrans = TRUE.

    END.  

    OUTPUT STREAM str_1 CLOSE.

    IF   NOT aux_flgtrans    THEN
         DO:
             IF   NOT TEMP-TABLE tt-erro:HAS-RECORDS    THEN
                  RUN gera_erro (INPUT par_cdcooper,
                            INPUT 1,
                            INPUT 1,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

         END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Imprime_Consulta: 

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_inprodut AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_tpimpres AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrconbir AS INTE                                      NO-UNDO.
    DEF VAR aux_nrseqdet AS INTE                                      NO-UNDO.
    DEF VAR aux_iddeaval AS INTE                                      NO-UNDO.
    DEF VAR aux_inconcje AS INTE                                      NO-UNDO.                                                                  
    DEF VAR aux_tpctrlim AS INTE                                      NO-UNDO.
    DEF VAR aux_nrctaav1 AS INTE                                      NO-UNDO.
    DEF VAR aux_nrctaav2 AS INTE                                      NO-UNDO.

    DEF BUFFER crabass FOR crapass.

    DEF VAR h-b1wgen0024 AS HANDLE                                    NO-UNDO.

    FORM HEADER
     "PAG:"            AT  74
     PAGE-NUMBER(str_1)       AT  78 FORMAT "zz9"
     WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_paginacao.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapcop   THEN
            DO:
                ASSIGN aux_cdcritic = 651.
                LEAVE.
            END.

       ASSIGN par_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                             "consultas_" + STRING(TIME) + ".ex".
                           
       IF   par_idorigem = 1    AND  /* Ayllos caracter */
            par_tpimpres = "I"  THEN     /* Impressao */
            DO: 
                OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGE-SIZE 78 PAGED.

                VIEW STREAM str_1 FRAME f_paginacao.

                /*  Configura a impressora para 1/8"  */
                PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
              
                PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
            END.
       ELSE
            OUTPUT STREAM str_1 TO VALUE (par_nmarqimp).

       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapass   THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.

       IF   par_nrctrato <> 0   THEN
            DO:            
                IF   par_inprodut = 1   THEN /* Emprestimo */
                     DO:
                         FIND crawepr WHERE 
                              crawepr.cdcooper = par_cdcooper   AND    
                              crawepr.nrdconta = par_nrdconta   AND    
                              crawepr.nrctremp = par_nrctrato          
                              NO-LOCK NO-ERROR.                        
                                                                                     
                         IF   NOT AVAIL crawepr  THEN                                
                              DO:                                                    
                                  ASSIGN aux_cdcritic = 510.                         
                                  LEAVE.                                             
                              END.                                                   

                         ASSIGN aux_inconcje = crawepr.inconcje
                                aux_nrctaav1 = crawepr.nrctaav1
                                aux_nrctaav2 = crawepr.nrctaav2
                                aux_nrconbir = crawepr.nrconbir.
 
                         /* Buscar NRSEQDET  */
                         RUN Busca_Biro_Emp_Lim (INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_inprodut,
                                                 INPUT par_nrctrato,
                                                 INPUT 0,
                                                 INPUT crapass.nrcpfcgc,
                                                 OUTPUT aux_nrconbir,
                                                 OUTPUT aux_nrseqdet). 

                     END.
                ELSE       /* Limite */
                     DO:
                          IF   par_inprodut = 3   THEN /* Chq. Especial */
                               ASSIGN aux_tpctrlim = 1.

                          FIND craplim WHERE 
                               craplim.cdcooper = par_cdcooper   AND
                               craplim.nrdconta = par_nrdconta   AND
                               craplim.tpctrlim = aux_tpctrlim   AND
                               craplim.nrctrlim = par_nrctrato
                               NO-LOCK NO-ERROR.

                          IF   NOT AVAIL craplim    THEN
                               DO:
                                   ASSIGN aux_cdcritic = 105.
                                   LEAVE.
                               END.

                          ASSIGN aux_inconcje = craplim.inconcje
                                 aux_nrctaav1 = craplim.nrctaav1
                                 aux_nrctaav2 = craplim.nrctaav2
                                 aux_nrconbir = craplim.nrconbir
                                 aux_nrseqdet = 1.

                     END.             
                
                
                RUN Trata_Pessoa (INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctrato,
                                  INPUT crapass.inpessoa,
                                  INPUT "Titular",
                                  INPUT aux_nrconbir,
                                  INPUT aux_nrseqdet).

                IF   aux_inconcje = 1   THEN /* Consulta ao Conjuge */
                     DO:
                         FIND crapcje WHERE 
                              crapcje.cdcooper = par_cdcooper   AND
                              crapcje.nrdconta = par_nrdconta   AND
                              crapcje.idseqttl = 1
                              NO-LOCK NO-ERROR.
                          
                         IF   NOT AVAIL crapcje   THEN
                              DO:
                                  ASSIGN aux_cdcritic = 610.
                                  LEAVE.
                              END.

                         IF crapcje.nrcpfcjg = 0 THEN
                         DO:
                           FIND crabass WHERE 
                                crabass.cdcooper = par_cdcooper   AND
                                crabass.nrdconta = crapcje.nrctacje
                                NO-LOCK NO-ERROR.

                            IF   NOT AVAIL crabass   THEN
                            DO:
                                ASSIGN aux_cdcritic = 9.
                                LEAVE.
                            END.                              
 
                            /* Dados do conjuge pela conta e CPF da CRAPASS */
                            RUN Busca_Biro_Emp_Lim (INPUT par_cdcooper,
                                                    INPUT par_nrdconta,
                                                    INPUT par_inprodut,
                                                    INPUT par_nrctrato,
                                                    INPUT crapcje.nrctacje,
                                                    INPUT crabass.nrcpfcgc,
                                                   OUTPUT aux_nrconbir,
                                                   OUTPUT aux_nrseqdet).
                            
                            
                          END.
                          ELSE
                          DO:
                            /* Dados do conjuge direto da tabela de Conjuge */
                         RUN Busca_Biro_Emp_Lim (INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_inprodut,
                                                 INPUT par_nrctrato,
                                                 INPUT crapcje.nrctacje,
                                                 INPUT crapcje.nrcpfcjg,
                                                OUTPUT aux_nrconbir,
                                                OUTPUT aux_nrseqdet).
                                  
                          END.                      
                                                
                         RUN Trata_Pessoa (INPUT par_cdcooper,
                                           INPUT crapcje.nrctacje,
                                           INPUT 0,
                                           INPUT 1,
                                           INPUT "Conjuge",
                                           INPUT aux_nrconbir,
                                           INPUT aux_nrseqdet).
                     
                     END.

                 /* Aval 1 */       
                 IF   aux_nrctaav1 > 0   THEN
                      DO:
                          FIND crabass WHERE 
                               crabass.cdcooper = par_cdcooper   AND
                               crabass.nrdconta = aux_nrctaav1
                               NO-LOCK NO-ERROR.

                          IF   NOT AVAIL crabass   THEN
                               DO:
                                   ASSIGN aux_cdcritic = 9.
                                   LEAVE.
                               END.

                          RUN Busca_Biro_Emp_Lim (INPUT par_cdcooper,
                                                  INPUT par_nrdconta,
                                                  INPUT par_inprodut,                                                   
                                                  INPUT par_nrctrato,
                                                  INPUT crabass.nrdconta,
                                                  INPUT crabass.nrcpfcgc,
                                                 OUTPUT aux_nrconbir,
                                                 OUTPUT aux_nrseqdet).
        
                          RUN Trata_Pessoa (INPUT par_cdcooper,
                                            INPUT crabass.nrdconta,
                                            INPUT 0,
                                            INPUT crabass.inpessoa,
                                            INPUT "Avalista 1",
                                            INPUT aux_nrconbir,
                                            INPUT aux_nrseqdet).

                          ASSIGN aux_iddeaval = aux_iddeaval + 1.
                      END.

                /* Aval 2 */
                IF   aux_nrctaav2 > 0   THEN
                     DO:
                          FIND crabass WHERE 
                               crabass.cdcooper = par_cdcooper   AND
                               crabass.nrdconta = aux_nrctaav2
                               NO-LOCK NO-ERROR.
                         
                          IF   NOT AVAIL crabass   THEN
                               DO:
                                   ASSIGN aux_cdcritic = 9.
                                   LEAVE.
                               END.

                          RUN Busca_Biro_Emp_Lim (INPUT par_cdcooper,
                                                  INPUT par_nrdconta,
                                                  INPUT par_inprodut, 
                                                  INPUT par_nrctrato,
                                                  INPUT crabass.nrdconta,
                                                  INPUT crabass.nrcpfcgc,
                                                 OUTPUT aux_nrconbir,
                                                 OUTPUT aux_nrseqdet).
                                  
                          RUN Trata_Pessoa (INPUT par_cdcooper,
                                            INPUT crabass.nrdconta,
                                            INPUT 0,
                                            INPUT crabass.inpessoa,
                                            INPUT "Avalista 2",
                                            INPUT aux_nrconbir,
                                            INPUT aux_nrseqdet).

                          ASSIGN aux_iddeaval = aux_iddeaval + 1.

                     END.

                 /*** Avalistas Terceiros ***/
                 FOR EACH crapavt WHERE  
                          crapavt.cdcooper = par_cdcooper   AND
                          crapavt.nrdconta = par_nrdconta   AND
                          crapavt.nrctremp = par_nrctrato   AND
                          crapavt.tpctrato = par_inprodut   NO-LOCK:

                     ASSIGN aux_iddeaval = aux_iddeaval + 1.

                     RUN Busca_Biro_Emp_Lim (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_inprodut,
                                             INPUT par_nrctrato,
                                             INPUT 0,
                                             INPUT crapavt.nrcpfcgc,
                                            OUTPUT aux_nrconbir,
                                            OUTPUT aux_nrseqdet).
                               
                     RUN Trata_Pessoa (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT crapavt.inpessoa,
                                       INPUT "Avalista " + STRING(aux_iddeaval),
                                       INPUT aux_nrconbir,
                                       INPUT aux_nrseqdet).
              
                 END.
                 
            END.
       ELSE
            DO:
                /* Dados do titular */ 
                RUN Busca_Biro (INPUT par_cdcooper,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrconbir,
                               OUTPUT aux_nrseqdet).

                RUN Trata_Pessoa (INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_nrctrato,
                                  INPUT crapass.inpessoa,
                                  INPUT "",
                                  INPUT aux_nrconbir,
                                  INPUT aux_nrseqdet).
            END.

       
       OUTPUT STREAM str_1 CLOSE.

       /* Se for Ayllos web*/
       IF   par_idorigem = 5   THEN
            DO:     
                RUN sistema/generico/procedures/b1wgen0024.p 
                    PERSISTENT SET h-b1wgen0024.

                RUN envia-arquivo-web IN h-b1wgen0024 
                                (INPUT par_cdcooper,
                                 INPUT 1, /* cdagenci */
                                 INPUT 1, /* nrdcaixa */
                                 INPUT par_nmarqimp,
                                OUTPUT par_nmarqpdf,
                                OUTPUT TABLE tt-erro ).

                DELETE PROCEDURE h-b1wgen0024.
     
                IF   RETURN-VALUE <> "OK"   THEN
                     RETURN "NOK".

            END.

       LEAVE.

    END.

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT 1,
                            INPUT 1,
                            INPUT 1,
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Trata_Pessoa:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dsconsul AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nrconbir AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrseqdet AS INTE                            NO-UNDO.


    DEF VAR aux_cdbircon AS INTE                                    NO-UNDO.
    DEF VAR aux_dsbircon AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdmodbir AS INTE                                    NO-UNDO.
    DEF VAR aux_dssituac AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsmodbir AS CHAR                                    NO-UNDO.


    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
       RUN Busca_Situacao (INPUT par_nrconbir,
                           INPUT par_nrseqdet,
                          OUTPUT aux_cdbircon,
                          OUTPUT aux_dsbircon,
                          OUTPUT aux_cdmodbir,
                          OUTPUT aux_dssituac,
                          OUTPUT aux_dsmodbir).
       
       IF   RETURN-VALUE <> "OK"   THEN
            LEAVE.

       RUN Consulta_Geral (INPUT par_nrconbir,
                           INPUT par_nrseqdet,
                          OUTPUT aux_dscritic,
                          OUTPUT TABLE tt-xml-geral).

       IF   aux_cdbircon = 1   AND   
            aux_cdmodbir = 1   THEN /*  Consulta SPC – Opção 62  */
            DO:
                RUN Trata_Spc_62 (INPUT TABLE tt-xml-geral,
                                  INPUT par_nrdconta,
                                  INPUT par_inpessoa,
                                  INPUT par_dsconsul,
                                  INPUT TRUE).
            END.
       ELSE 
       IF   aux_cdbircon = 1   AND
            aux_cdmodbir = 2   THEN /*  Consulta SPC – Opção 65 */
            DO:
                RUN Trata_Spc_62 (INPUT TABLE tt-xml-geral,
                                  INPUT par_nrdconta,
                                  INPUT par_inpessoa,
                                  INPUT par_dsconsul,
                                  INPUT FALSE).
            END.
       ELSE
       IF   aux_cdbircon = 2   AND
            par_inpessoa = 1   THEN /*  Consulta Serasa – PF */
            DO:
                RUN Trata_Serasa_Pf (INPUT TABLE tt-xml-geral,
                                     INPUT par_nrdconta,
                                     INPUT par_inpessoa,
                                     INPUT par_dsconsul).
            END.
       ELSE
       IF   aux_cdbircon = 2   AND 
            par_inpessoa = 2   THEN /* Consulta Serasa – PJ */
            DO:
                RUN Trata_Serasa_Pj (INPUT TABLE tt-xml-geral,
                                     INPUT par_nrdconta,
                                     INPUT par_dsconsul).
            END.


       RUN Trata_BoaVista (INPUT par_cdcooper,
                           INPUT par_nrdconta,
                           INPUT crapass.inpessoa).

       LEAVE.

    END.

    RETURN "OK".

END PROCEDURE. 


PROCEDURE Consulta_Geral:

    DEF INPUT  PARAM par_nrconbir AS INTE                             NO-UNDO.
    DEF INPUT  PARAM par_nrseqdet AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-xml-geral.


    DEF VAR aux_dstagfil AS CHAR                                      NO-UNDO.
    DEF VAR aux_dstagnet AS CHAR                                      NO-UNDO.
    DEF VAR aux_dsvldtag AS CHAR                                      NO-UNDO.
    DEF VAR aux_contador AS INTE                                      NO-UNDO.
    DEF VAR aux_contado2 AS INTE                                      NO-UNDO.
    DEF VAR aux_contado3 AS INTE                                      NO-UNDO.
    DEF VAR aux_contado4 AS INTE                                      NO-UNDO.
    DEF VAR aux_contado5 AS INTE                                      NO-UNDO.
    DEF VAR ponteiro_xml AS MEMPTR                                    NO-UNDO.
    DEF VAR xml_req      AS LONGCHAR                                  NO-UNDO.
    DEF VAR xDoc         AS HANDLE                                    NO-UNDO.  
    DEF VAR xRoot        AS HANDLE                                    NO-UNDO. 
    DEF VAR xRoot2       AS HANDLE                                    NO-UNDO. 
    DEF VAR xRoot3       AS HANDLE                                    NO-UNDO.
    DEF VAR xRoot4       AS HANDLE                                    NO-UNDO.
    DEF VAR xRoot5       AS HANDLE                                    NO-UNDO.
    DEF VAR xField       AS HANDLE                                    NO-UNDO.
    DEF VAR xText        AS HANDLE                                    NO-UNDO.
    
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_consulta_geral 
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_nrconbir,
                                             INPUT par_nrseqdet,
                                            OUTPUT "",
                                            OUTPUT 0,
                                            OUTPUT ""). 
    
    CLOSE STORED-PROC pc_consulta_geral
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN par_dscritic = pc_consulta_geral.pr_dscritic
                            WHEN pc_consulta_geral.pr_dscritic <> ?.
    
    IF   par_dscritic <> ""                 OR 
         pc_consulta_geral.pr_retxml = ?   THEN
         RETURN "NOK".
    
    ASSIGN xml_req = pc_consulta_geral.pr_retxml.
    
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */
    CREATE X-NODEREF  xRoot.   
    CREATE X-NODEREF  xRoot2. 
    CREATE X-NODEREF  xRoot3. 
    CREATE X-NODEREF  xRoot4.
    CREATE X-NODEREF  xRoot5.
    CREATE X-NODEREF  xField. 
    CREATE X-NODEREF  xText.  
    
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1.
    PUT-STRING(ponteiro_xml,1) = xml_req.
    
    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
      
    xDoc:GET-DOCUMENT-ELEMENT(xRoot).
    
    EMPTY TEMP-TABLE tt-xml-geral.
    
    DO  aux_contador = 1 TO xRoot:NUM-CHILDREN:
    
        xRoot:GET-CHILD(xRoot2,aux_contador).
    
        ASSIGN aux_dstagavo = xRoot2:NAME
               aux_dsvldtag = xRoot2:NODE-VALUE NO-ERROR.
    
        IF   ERROR-STATUS:ERROR   THEN
             NEXT. 
    
        CREATE tt-xml-geral.
        ASSIGN tt-xml-geral.dstagavo = aux_dstagavo
               tt-xml-geral.dsdvalor = aux_dsvldtag.
    
        DO  aux_contado2 = 1 TO xRoot2:NUM-CHILDREN:
                   
            xRoot2:GET-CHILD(xRoot3,aux_contado2).
        
            IF   xRoot3:SUBTYPE <> "ELEMENT"   THEN
                 NEXT.
    
            ASSIGN aux_dstagpai = xRoot3:NAME
                   aux_dsvldtag = xRoot3:NODE-VALUE NO-ERROR.
    
            IF   ERROR-STATUS:ERROR   THEN
                 NEXT. 
    
            CREATE tt-xml-geral.
            ASSIGN tt-xml-geral.dstagavo = aux_dstagavo
                   tt-xml-geral.dstagpai = aux_dstagpai
                   tt-xml-geral.dsdvalor = aux_dsvldtag.
    
            DO aux_contado3 = 1 TO xRoot3:NUM-CHILDREN:
    
               xRoot3:GET-CHILD(xRoot4,aux_contado3).       
               
               IF   xRoot4:NUM-CHILDREN = 0   THEN
                    NEXT.
    
               xRoot4:GET-CHILD(xText,1).
    
               ASSIGN aux_dstagfil = xRoot4:NAME
                      aux_dsvldtag = xText:NODE-VALUE NO-ERROR.
    
               IF   ERROR-STATUS:ERROR   THEN
                    NEXT. 
    
               CREATE tt-xml-geral.
               ASSIGN tt-xml-geral.dstagavo = aux_dstagavo
                      tt-xml-geral.dstagpai = aux_dstagpai
                      tt-xml-geral.dstagfil = aux_dstagfil
                      tt-xml-geral.dsdvalor = aux_dsvldtag.
    
               DO aux_contado4 = 1 TO xRoot4:NUM-CHILDREN:
    
                   xRoot4:GET-CHILD(xRoot5,aux_contado4).
    
                   DO aux_contado5 = 1 TO xRoot5:NUM-CHILDREN:
                  
                       xRoot5:GET-CHILD(xField,aux_contado5).
    
                       IF   xField:NUM-CHILDREN = 0   THEN
                            NEXT.
    
                       xField:GET-CHILD(xText,1).
    
                       ASSIGN aux_dstagnet = xField:NAME
                              aux_dsvldtag = xText:NODE-VALUE NO-ERROR.
    
                       IF  ERROR-STATUS:ERROR   THEN
                           NEXT.
    
                       CREATE tt-xml-geral.
                       ASSIGN tt-xml-geral.dstagavo = aux_dstagavo
                              tt-xml-geral.dstagpai = aux_dstagpai
                              tt-xml-geral.dstagfil = aux_dstagfil
                              tt-xml-geral.dstagnet = aux_dstagnet
                              tt-xml-geral.dsdvalor = aux_dsvldtag. 
                   END.
               END.
            END.                    
        END.         
    END.
    
    SET-SIZE(ponteiro_xml) = 0.
    
    DELETE OBJECT xDoc.
    DELETE OBJECT xRoot.
    DELETE OBJECT xRoot2.
    DELETE OBJECT xRoot4.
    DELETE OBJECT xText. 
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE atualiza_inf_cadastrais:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_inprodut AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    EMPTY TEMP-TABLE tt-erro.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_atualiza_inf_cadastrais 
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctrato,
                                             INPUT par_inprodut,
                                            OUTPUT 0,
                                            OUTPUT ""). 
    
    CLOSE STORED-PROC pc_atualiza_inf_cadastrais
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_dscritic = pc_atualiza_inf_cadastrais.pr_dscritic
                            WHEN pc_atualiza_inf_cadastrais.pr_dscritic <> ?
        
           aux_cdcritic =  pc_atualiza_inf_cadastrais.pr_cdcritic
                            WHEN pc_atualiza_inf_cadastrais.pr_cdcritic <> ?.
    
    IF   aux_dscritic <> ""   OR
         aux_cdcritic <> 0    THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT 0,
                            INPUT 0,
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.
  
PROCEDURE Obrigacao_Consulta:

    DEF  INPUT PARAM par_cdcooper AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_inprodut AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_vlprodut AS DECI                         NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                         NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                         NO-UNDO.
    DEF OUTPUT PARAM par_inobriga AS CHAR                         NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    
    RUN STORED-PROCEDURE pc_obrigacao_consulta  
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_inprodut,
                                             INPUT par_inpessoa,
                                             INPUT par_vlprodut,
                                             INPUT par_cdfinemp,
                                             INPUT par_cdlcremp,
                                            OUTPUT ""). 
       
    CLOSE STORED-PROC pc_obrigacao_consulta 
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_inobriga = pc_obrigacao_consulta.pr_inobriga
                            WHEN pc_obrigacao_consulta.pr_inobriga <> ?.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE Trata_Spc_62:

    DEF INPUT PARAM TABLE FOR tt-xml-geral.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dsconsul AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_flgeho62 AS LOGI                               NO-UNDO.

    DEF VAR rel_vlnegati AS DECI                                       NO-UNDO.


    FORM tt-craprsc.dslocnac COLUMN-LABEL "Tipo"         
         tt-craprsc.dsinstit COLUMN-LABEL "Instituicao"  FORMAT "x(15)"
         tt-craprsc.vlregist COLUMN-LABEL "Valor"        FORMAT "zzz,zz9.99"
         tt-craprsc.dtregist COLUMN-LABEL "Registro"     FORMAT "99/99/99"
         tt-craprsc.dtvencto COLUMN-LABEL "Vencto"       FORMAT "99/99/99"
         tt-craprsc.dsmtvreg COLUMN-LABEL "Motivo"       FORMAT "x(10)"
         tt-craprsc.dsentorg COLUMN-LABEL "Ent. Org"     FORMAT "x(11)"
         aux_nmcidade        COLUMN-LABEL "Cidade-UF"    FORMAT "x(15)" 
         WITH DOWN WIDTH 132 FRAME f_inf_craprsc_62.

    FORM tt-crapcsf.nmbanchq COLUMN-LABEL "Banco"        FORMAT "x(19)"   
         tt-crapcsf.cdagechq COLUMN-LABEL "Agencia"
         tt-crapcsf.cdalinea COLUMN-LABEL "Alinea"
         tt-crapcsf.dsmotivo COLUMN-LABEL "Motivo"       FORMAT "x(16)"
         tt-crapcsf.qtcheque COLUMN-LABEL "Qtde."
         tt-crapcsf.dtultocr COLUMN-LABEL "Ult. Ocorr."
         tt-crapcsf.dtinclus COLUMN-LABEL "Data Incl."
         WITH DOWN WIDTH 132 FRAME f_inf_crapcsf_62.

    RUN Busca_Dados_Consultado (INPUT  par_inpessoa,
                                INPUT TABLE tt-xml-geral,
                                OUTPUT aux_nmtitcon,
                                OUTPUT aux_dtconbir, 
                                OUTPUT aux_nmtitcab, 
                                OUTPUT aux_dscpfcgc,
                                OUTPUT aux_inreapro). 

    RUN Trata_SPC (INPUT TABLE tt-xml-geral,
                   OUTPUT rel_dsnegati,
                   OUTPUT rel_vlnegati,
                   OUTPUT TABLE tt-craprsc).
        
    RUN Trata_Cheques (INPUT TABLE tt-xml-geral,
                      OUTPUT TABLE tt-crapcsf).

    RUN separador_item (INPUT aux_nmtitcab,
                       INPUT TRUE).

    ASSIGN aux_qtcaract = (12 - LENGTH(par_dsconsul)) / 2 .

    ASSIGN par_dsconsul = FILL(" ",aux_qtcaract) + par_dsconsul.

    IF   par_dsconsul <> ""   THEN
         DISPLAY STREAM str_1 aux_dscabec  
                              UPPER(par_dsconsul) @ aux_dsconsul
                              aux_dscabe2 WITH FRAME f_cabecalho.
         
    DISPLAY STREAM str_1 par_nrdconta @ aux_nrdconta
                         aux_dtconbir
                         aux_nmtitcon
                         aux_inreapro 
                         aux_dscpfcgc WITH FRAME f_cabecalho_2.

    RUN separador_item (INPUT "REGISTRO SPC",
                        TEMP-TABLE tt-craprsc:HAS-RECORDS).

    /* Listar os registros SPC */
    FOR EACH tt-craprsc BY tt-craprsc.dtregist DESC:

        ASSIGN aux_nmcidade = tt-craprsc.nmcidade + "-" + tt-craprsc.cdufende.

        DISPLAY STREAM str_1
                tt-craprsc.dslocnac
                tt-craprsc.dsinstit
                tt-craprsc.dsentorg
                aux_nmcidade     
                tt-craprsc.dtregist
                tt-craprsc.dtvencto
                tt-craprsc.dsmtvreg
                tt-craprsc.vlregist WITH FRAME f_inf_craprsc_62.

        DOWN WITH FRAME f_inf_craprsc_62.

    END.

    RUN separador_item (INPUT "CHEQUE SEM FUNDO",
                        INPUT TEMP-TABLE tt-crapcsf:HAS-RECORDS).

    /* Listar os cheques do banco central */
    FOR EACH tt-crapcsf BY tt-crapcsf.dtinclus DESC:
        
        DISPLAY STREAM str_1
                tt-crapcsf.nmbanchq
                tt-crapcsf.cdagechq
                tt-crapcsf.cdalinea
                tt-crapcsf.dsmotivo
                tt-crapcsf.qtcheque
                tt-crapcsf.dtultocr
                tt-crapcsf.dtinclus WITH FRAME f_inf_crapcsf_62.

        DOWN WITH FRAME f_inf_crapcsf_62.

    END.
        
    IF   NOT par_flgeho62   THEN
         RUN Trata_Spc_65.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Trata_Spc_65:

    DEF VAR aux_qtddeprf AS INTE                                       NO-UNDO.
    DEF VAR aux_qtprotes AS INTE                                       NO-UNDO.


    FORM tt-crapprf.dtvencto LABEL "Data da ultima"
         SPACE(3)
         tt-crapprf.vlregist LABEL "Valor da ultima"
         SPACE(3)
         aux_qtddeprf        LABEL "Quantidade"         FORMAT "z,zz9"
         WITH WIDTH 132 SIDE-LABELS FRAME f_inf_crapprf_65_1.

    FORM SKIP(1)
         aux_qtprotes LABEL "Quantidade total"
         WITH WIDTH 132 SIDE-LABELS FRAME f_tit_crapprt_2_65.

    FORM tt-crapprf.dsinstit COLUMN-LABEL "Instituicao" FORMAT "x(20)"            
         tt-crapprf.vlregist COLUMN-LABEL "Valor"
         tt-crapprf.dtvencto COLUMN-LABEL "Vencto"
         tt-crapprf.dsmtvreg COLUMN-LABEL "Motivo"      FORMAT "x(20)"
         tt-crapprf.dsnature COLUMN-LABEL "Natureza"    FORMAT "x(20)"
         WITH DOWN WIDTH 132 FRAME f_inf_crapprf_65_2.

    FORM tt-crapprt.nmlocprt COLUMN-LABEL "Local"       FORMAT "x(60)"
         tt-crapprt.qtprotes COLUMN-LABEL "Qtde"
         WITH DOWN WIDTH 132 FRAME f_inf_crapprt_65.

    RUN Trata_Pefin_Refin (INPUT 1,
                           INPUT TABLE tt-xml-geral,
                          OUTPUT TABLE tt-crapprf).

    RUN Trata_Protestos (INPUT TABLE tt-xml-geral,
                        OUTPUT TABLE tt-crapprt).


    ASSIGN aux_qtddeprf = 0.

    /* Contabilizar os registros */
    FOR EACH tt-crapprf WHERE tt-crapprf.dstagpai = "crapprf_inf" NO-LOCK:
        aux_qtddeprf = aux_qtddeprf + 1.
    END.

    RUN separador_item (INPUT "PEFIN / REFIN",
                        INPUT aux_qtddeprf <> 0).

    /* Mostrar dados SPC 65 */
    FOR EACH tt-crapprf WHERE tt-crapprf.dstagpai = "crapprf_inf" 
                              BREAK BY tt-crapprf.dtvencto DESC:

        IF  FIRST(tt-crapprf.dtvencto)   THEN
            DO:
                DISPLAY STREAM str_1 tt-crapprf.dtvencto
                                     tt-crapprf.vlregist
                                     aux_qtddeprf
                                     WITH FRAME f_inf_crapprf_65_1.
            END.
                          
        DISPLAY STREAM str_1 tt-crapprf.dsinstit
                             tt-crapprf.dtvencto
                             tt-crapprf.dsmtvreg
                             tt-crapprf.dsnature
                             tt-crapprf.vlregist WITH FRAME f_inf_crapprf_65_2.

        DOWN WITH FRAME f_inf_crapprf_65_2.

    END.

    ASSIGN aux_qtprotes = 0.

    FOR EACH tt-crapprt NO-LOCK:
        aux_qtprotes = aux_qtprotes + tt-crapprt.qtprotes.
    END.

    IF   aux_qtprotes = 0   THEN
         DO:
             RUN separador_item (INPUT "PROTESTOS",
                                 INPUT FALSE).
         END.
    ELSE
         DO: 
             RUN separador_item (INPUT "PROTESTOS",
                                 INPUT TRUE).

             DISPLAY STREAM str_1 aux_qtprotes
                                  WITH FRAME f_tit_crapprt_2_65.
         END.

    FOR EACH tt-crapprt NO-LOCK BY tt-crapprt.nmlocprt:

        DISPLAY STREAM str_1 tt-crapprt.nmlocprt
                             tt-crapprt.qtprotes
                             WITH FRAME f_inf_crapprt_65.

        DOWN WITH FRAME f_inf_crapprt_65.

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Trata_Serasa_Pf:
    
    DEF INPUT PARAM TABLE FOR tt-xml-geral.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dsconsul AS CHAR                               NO-UNDO.


    DEF VAR aux_dsnegati AS CHAR EXTENT 99                             NO-UNDO.
    DEF VAR aux_vlnegati AS DECI EXTENT 99                             NO-UNDO.
    DEF VAR aux_dtultneg AS DATE EXTENT 99                             NO-UNDO.
        

    RUN Busca_Dados_Consultado (INPUT  par_inpessoa,
                                INPUT TABLE tt-xml-geral,
                                OUTPUT aux_nmtitcon,
                                OUTPUT aux_dtconbir, 
                                OUTPUT aux_nmtitcab, 
                                OUTPUT aux_dscpfcgc,
                                OUTPUT aux_inreapro). 

    RUN Trata_Anotacoes (INPUT TABLE tt-xml-geral,
                         OUTPUT aux_dsnegati,
                         OUTPUT aux_vlnegati,
                         OUTPUT aux_dtultneg,
                         OUTPUT TABLE tt-craprpf).

    RUN Trata_Endereco (INPUT TABLE tt-xml-geral,
                       OUTPUT aux_dsendere,
                       OUTPUT aux_nmbairro,
                       OUTPUT aux_nmcidade,
                       OUTPUT aux_cdufende,
                       OUTPUT aux_nrcepend,
                       OUTPUT aux_dtatuend).

    RUN separador_item (INPUT aux_nmtitcab,
                        INPUT TRUE).

    ASSIGN aux_qtcaract = (12 - LENGTH(par_dsconsul)) / 2 .

    ASSIGN par_dsconsul = FILL(" ",aux_qtcaract) + par_dsconsul.

    IF   par_dsconsul <> ""   THEN
         DISPLAY STREAM str_1 aux_dscabec  
                              UPPER(par_dsconsul) @ aux_dsconsul
                              aux_dscabe2 WITH FRAME f_cabecalho.
         
    DISPLAY STREAM str_1 par_nrdconta @ aux_nrdconta
                         aux_dtconbir
                         aux_nmtitcon
                         aux_inreapro
                         aux_dscpfcgc WITH FRAME f_cabecalho_2.

    RUN Imprime_Anotacoes (INPUT TABLE tt-craprpf).

    IF   aux_dtatuend = ?  THEN
         RUN separador_item 
            (INPUT "CONFIRMACAO DE ENDERECO PELO CEP ( Atualizado em )",
             INPUT TRUE).
    ELSE
         RUN separador_item 
             (INPUT "CONFIRMACAO DE ENDERECO PELO CEP ( Atualizado em " + 
                     STRING(aux_dtatuend,"99/99/9999") + " )",
              INPUT TRUE).

    /* Dados do endereco */
    DISPLAY STREAM str_1 aux_dsendere
                         aux_nmbairro
                         aux_nmcidade
                         aux_cdufende
                         aux_nrcepend WITH FRAME f_dados_endereco.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Trata_Serasa_Pj:

    DEF INPUT PARAM TABLE FOR tt-xml-geral.
    DEF INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF INPUT PARAM par_dsconsul AS CHAR                              NO-UNDO.

    DEF VAR aux_nrseqreg AS INTE                                      NO-UNDO.
    DEF VAR aux_dsconteu AS CHAR                                      NO-UNDO.
    DEF VAR rel_vlnegati AS DECI                                      NO-UNDO.
    

    FORM rel_dsnegati LABEL "Total de Ocorrencias" FORMAT "x(5)"
         rel_vlnegati LABEL "Valor total"          FORMAT "z,zzz,zz9.99" 
         WITH SIDE-LABEL WIDTH 132 FRAME f_tot_ocorrencias.

    FORM tt-crapprt.dtprotes COLUMN-LABEL "Data"
         tt-crapprt.vlprotes COLUMN-LABEL "Valor"
         tt-crapprt.nmcidade COLUMN-LABEL "Cidade" FORMAT "x(25)"
         tt-crapprt.cdufende COLUMN-LABEL "UF"
         WITH DOWN WIDTH 132 FRAME f_inf_crapprt_serasa_pj.
    
    FORM SKIP(1)
         tt-crapcbd.nmtitcon LABEL "Nome"          FORMAT "x(25)"
         tt-crapcbd.dtentsoc LABEL "Entrada"
         SKIP
         tt-crapcbd.dscpfcgc LABEL "CPF"           FORMAT "x(17)"
         SPACE(3)
         tt-crapcbd.percapvt LABEL "%CAP.Votante"  FORMAT "zz9.99"
         SPACE(3)
         tt-crapcbd.pertotal LABEL "%CAP.Tot"      FORMAT "zz9.99"
         WITH DOWN SIDE-LABEL WIDTH 132 FRAME f_inf_crapcbd_serasa_pj_3.

    FORM tt-crapprf.dtvencto COLUMN-LABEL "Data"
         tt-crapprf.dsmtvreg COLUMN-LABEL "Modalidade"
         tt-crapprf.vlregist COLUMN-LABEL "Valor"
         tt-crapprf.dsinstit COLUMN-LABEL "Origem" FORMAT "x(20)" 
         WITH DOWN WIDTH 132 FRAME f_inf_crapprf_serasa_pj.

    FORM tt-crapcsf.dtinclus COLUMN-LABEL "Data"
         tt-crapcsf.nrcheque COLUMN-LABEL "Nr. Cheque"
         tt-crapcsf.cdalinea COLUMN-LABEL "Alinea"     FORMAT "zz9"
         tt-crapcsf.dsmotivo COLUMN-LABEL "Motivo"     FORMAT "x(10)"         
         tt-crapcsf.vlcheque COLUMN-LABEL "Valor"      FORMAT "zzz,zz9.99"
         tt-crapcsf.nmbanchq COLUMN-LABEL "Banco"      FORMAT "x(15)"
         tt-crapcsf.cdagechq COLUMN-LABEL "Agencia"    FORMAT "zzz9"
         tt-crapcsf.nmcidade COLUMN-LABEL "Cidade"     FORMAT "x(16)"
         tt-crapcsf.cdufende COLUMN-LABEL "UF"         FORMAT "x(2)"
         WITH DOWN WIDTH 132 FRAME f_inf_crapcsf_serasa_pj.
      
    FORM tt-crapabr.dtacajud COLUMN-LABEL "Data"
         tt-crapabr.dsnataca COLUMN-LABEL "Natureza"   FORMAT "x(20)"
         tt-crapabr.vltotaca COLUMN-LABEL "Valor"
         tt-crapabr.nrdistri COLUMN-LABEL "Distr."
         tt-crapabr.nrvaraca COLUMN-LABEL "Vara"
         tt-crapabr.nmcidade COLUMN-LABEL "Cidade"     FORMAT "x(25)"
         tt-crapabr.cdufende COLUMN-LABEL "UF"         FORMAT "x(2)"
         WITH DOWN WIDTH 132 FRAME f_inf_crapabr_serasa_pj.
      
    FORM tt-craprfc.dtregist COLUMN-LABEL "Data"
         tt-craprfc.dstipreg COLUMN-LABEL "Tipo"       FORMAT "x(25)"
         tt-craprfc.dsorgreg COLUMN-LABEL "Origem"     FORMAT "x(20)"
         tt-craprfc.nmcidade COLUMN-LABEL "Cidade"     FORMAT "x(25)"
         tt-craprfc.cdufende COLUMN-LABEL "UF"
         WITH DOWN WIDTH 132 FRAME f_inf_craprfc_serasa_pj.
         
    FORM tt-crapcbd.dscpfcgc COLUMN-LABEL "CPF/CNPJ"        FORMAT "x(14)"
         tt-crapcbd.nmtitcon COLUMN-LABEL "Socio/Acionista" FORMAT "x(25)"
         tt-crapcbd.dtentsoc COLUMN-LABEL "Entrada"
         tt-crapcbd.percapvt COLUMN-LABEL "%CAP.VOT"        FORMAT "zz9.99"
         tt-crapcbd.pertotal COLUMN-LABEL "%CAP.TOT"        FORMAT "zz9.99"
         WITH DOWN WIDTH 132 FRAME f_inf_crapcbd_serasa_pj. 
    
    FORM tt-crapcbd.dscpfcgc COLUMN-LABEL "CPF/CNPJ"        FORMAT "x(14)"
         tt-crapcbd.nmtitcon COLUMN-LABEL "Administracao"   FORMAT "x(24)"
         tt-crapcbd.dtentadm COLUMN-LABEL "Entrada"
         tt-crapcbd.dsprofis COLUMN-LABEL "Cargo"           FORMAT "x(20)"
         tt-crapcbd.dtmanadm COLUMN-LABEL "Mandato"         FORMAT "x(20)"
         WITH DOWN WIDTH 132 FRAME f_inf_crapcbd_serasa_pj_2. 
    
    FORM SKIP(1)
         SPACE(21)
         "CPF/CNPJ   NOME                     VINCULO %CAPITAL"
         SKIP
         SPACE(10)
         "-------------------   ------------------------ ------- --------"
         WITH NO-LABELS WIDTH 132 FRAME f_tit_crapbcd_serasa_pj_3.
    
    FORM "Socio:"                            
         SPACE(9)                            
         tt-crapcbd.dscpfcgc FORMAT "x(15)"  
         tt-crapcbd.nmtitcon FORMAT "x(24)"  
         SPACE(2)                            
         tt-crappsa.nmvincul FORMAT "x(8)"   
         SPACE(2)                            
         tt-crappsa.pertotal FORMAT "zz9.99" 
         SKIP
         "Empresa:"                          
         SPACE(3)                            
         tt-crappsa.nrdecnpj FORMAT "x(19)"  
         tt-crappsa.nmempres FORMAT "x(30)"  
         SPACE(1)                            
         aux_nmcidade        FORMAT "x(25)"  
         SKIP(1)
         WITH NO-LABEL DOWN WIDTH 132 FRAME f_empresa.   


    ASSIGN aux_nrseqreg = 0.
        
    RUN Busca_Dados_Consultado (INPUT  2,
                                INPUT TABLE tt-xml-geral,
                                OUTPUT aux_nmtitcon,
                                OUTPUT aux_dtconbir, 
                                OUTPUT aux_nmtitcab, 
                                OUTPUT aux_dscpfcgc,
                                OUTPUT aux_inreapro). 

    RUN Trata_Endereco  (INPUT TABLE tt-xml-geral,
                        OUTPUT aux_dsendere,
                        OUTPUT aux_nmbairro,
                        OUTPUT aux_nmcidade,
                        OUTPUT aux_cdufende,
                        OUTPUT aux_nrcepend,
                        OUTPUT aux_dtatuend).

    RUN Trata_Anotacoes  (INPUT TABLE tt-xml-geral,
                         OUTPUT aux_dsnegati,
                         OUTPUT aux_vlnegati,
                         OUTPUT aux_dtultneg,
                         OUTPUT TABLE tt-craprpf).
                         
    RUN Trata_Pefin_Refin (INPUT 2,
                           INPUT TABLE tt-xml-geral,
                          OUTPUT TABLE tt-crapprf).

    RUN Trata_Protestos  (INPUT TABLE tt-xml-geral,
                         OUTPUT TABLE tt-crapprt).

    RUN Trata_Cheques (INPUT TABLE tt-xml-geral,
                      OUTPUT TABLE tt-crapcsf).

    RUN Trata_Pefin_Refin  (INPUT 3,
                            INPUT TABLE tt-xml-geral,
                           OUTPUT TABLE tt-crapprf).

    RUN Trata_Acoes (INPUT TABLE tt-xml-geral,
                    OUTPUT TABLE tt-crapabr).

    RUN Trata_Recuperacoes (INPUT TABLE tt-xml-geral,
                           OUTPUT TABLE tt-craprfc).
    
    RUN Trata_Societarios (INPUT TABLE tt-xml-geral,
                           INPUT 1,
                          OUTPUT TABLE tt-crapcbd).

    RUN Trata_Societarios (INPUT TABLE tt-xml-geral,
                           INPUT 2,
                          OUTPUT TABLE tt-crapcbd).

    RUN Trata_Empresas (INPUT TABLE tt-xml-geral,
                       OUTPUT TABLE tt-crappsa).

    RUN Trata_Anotacoes_Pj (INPUT TABLE tt-xml-geral,
                           OUTPUT TABLE tt-craprpf).

    RUN separador_item (INPUT aux_nmtitcab,
                        INPUT TRUE).

    ASSIGN aux_qtcaract = (12 - LENGTH(par_dsconsul)) / 2 .

    ASSIGN par_dsconsul = FILL(" ",aux_qtcaract) + par_dsconsul.

    IF   par_dsconsul <> ""   THEN
         DISPLAY STREAM str_1 aux_dscabec  
                              UPPER(par_dsconsul) @ aux_dsconsul
                              aux_dscabe2 WITH FRAME f_cabecalho.
         
    DISPLAY STREAM str_1 par_nrdconta @ aux_nrdconta
                         aux_dtconbir
                         aux_nmtitcon
                         aux_inreapro
                         aux_dscpfcgc WITH FRAME f_cabecalho_2.

    IF   aux_dtatuend = ?  THEN
         RUN separador_item 
            (INPUT "CONFIRMACAO DE ENDERECO PELO CEP ( Atualizado em )",
             INPUT TRUE).
    ELSE
         RUN separador_item 
             (INPUT "CONFIRMACAO DE ENDERECO PELO CEP ( Atualizado em " + 
                     STRING(aux_dtatuend,"99/99/9999") + " )",
              INPUT TRUE).

    /* Dados do endereco */
    DISPLAY STREAM str_1 aux_dsendere
                         aux_nmbairro
                         aux_nmcidade
                         aux_cdufende
                         aux_nrcepend WITH FRAME f_dados_endereco.

    RUN Imprime_Anotacoes (INPUT TABLE tt-craprpf).

    ASSIGN aux_dsconteu = "- NADA CONSTA".
    
    /* Dados Pefin */
    FOR EACH tt-crapprf WHERE tt-crapprf.dstagpai = "crapprf_pefin_inf"   AND
                              tt-crapprf.inpefref = 1
                              BREAK BY tt-crapprf.dtvencto DESC:

        IF   FIRST(tt-crapprf.dtvencto)   THEN
             DO:   
                 ASSIGN aux_dsconteu =  
                     "PEFIN (Ocorrencias mais recentes - ate cinco)".   

                 RUN separador_item 
                     (INPUT aux_dsconteu,
                      INPUT TRUE).
             END.                           

        DISPLAY STREAM str_1 tt-crapprf.dtvencto 
                             tt-crapprf.dsmtvreg 
                             tt-crapprf.vlregist 
                             tt-crapprf.dsinstit 
                             WITH FRAME f_inf_crapprf_serasa_pj.

        DOWN WITH FRAME f_inf_crapprf_serasa_pj.

    END.

    IF   aux_dsconteu = "- NADA CONSTA"   THEN
         RUN separador_item 
                     (INPUT "PEFIN",
                      INPUT FALSE).
    ELSE
         DO:
             /* Total de ocorrencias */
             ASSIGN rel_dsnegati = aux_dsnegati[2]
                    rel_vlnegati = aux_vlnegati[2].
             
             DISPLAY STREAM str_1 rel_dsnegati
                                  rel_vlnegati WITH FRAME f_tot_ocorrencias.             
         END.                                  
  
    /* Dados protesto */
    ASSIGN aux_dsconteu = "- NADA CONSTA".

    FOR EACH tt-crapprt NO-LOCK BREAK BY tt-crapprt.dtprotes DESC:

        IF   FIRST (tt-crapprt.dtprotes)   THEN
             DO:
                 ASSIGN aux_dsconteu =  
                     "PROTESTO (Ocorrencias mais recentes - ate cinco)".   
                     
                 RUN separador_item
                     (INPUT aux_dsconteu,
                      INPUT TRUE).
             END.                          

        DISPLAY STREAM str_1 tt-crapprt.dtprotes
                             tt-crapprt.vlprotes
                             tt-crapprt.nmcidade
                             tt-crapprt.cdufende 
                             WITH FRAME f_inf_crapprt_serasa_pj.

        DOWN WITH FRAME f_inf_crapprt_serasa_pj.

    END.

    IF   NOT aux_dsconteu = "- NADA CONSTA"   THEN
         DO:
             /* Total de ocorrencias */
             ASSIGN rel_dsnegati = aux_dsnegati[3]
                    rel_vlnegati = aux_vlnegati[3].
             
             DISPLAY STREAM str_1 rel_dsnegati
                                  rel_vlnegati 
                                  WITH FRAME f_tot_ocorrencias.             
         END. 
    ELSE 
         DO:
             RUN separador_item (INPUT "PROTESTO",
                                 INPUT FALSE).  
         END.

    /* Cheques sem fundo */
    ASSIGN aux_dsconteu = "- NADA CONSTA".
                              
    FOR EACH tt-crapcsf WHERE tt-crapcsf.intipchq = 1
                              BREAK BY tt-crapcsf.dtinclus:

        IF   FIRST(tt-crapcsf.dtinclus)   THEN
             DO:
                 ASSIGN aux_dsconteu = 
                  "CHEQUE SEM FUNDOS (Ocorrencias mais recentes - ate cinco)".

                 RUN separador_item (INPUT aux_dsconteu,
                                     INPUT TRUE).

             END.                          

        DISPLAY STREAM str_1 tt-crapcsf.dtinclus
                             tt-crapcsf.nrcheque
                             tt-crapcsf.cdalinea
                             tt-crapcsf.dsmotivo
                             tt-crapcsf.vlcheque
                             tt-crapcsf.nmbanchq
                             tt-crapcsf.cdagechq
                             tt-crapcsf.nmcidade
                             tt-crapcsf.cdufende WITH FRAME f_inf_crapcsf_serasa_pj.

        DOWN WITH FRAME f_inf_crapcsf_serasa_pj.

    END.

    IF   aux_dsconteu = "- NADA CONSTA"   THEN
         RUN separador_item (INPUT "CHEQUE SEM FUNDOS",
                             INPUT FALSE).
    ELSE 
         DO:
             /* Total de ocorrencias */
             ASSIGN rel_dsnegati = aux_dsnegati[6]
                    rel_vlnegati = aux_vlnegati[6].
         
             DISPLAY STREAM str_1 rel_dsnegati
                                  rel_vlnegati WITH FRAME f_tot_ocorrencias.
         
         END.
         
    /* Dados Refin */
    ASSIGN aux_dsconteu = "- NADA CONSTA".

    FOR EACH tt-crapprf WHERE tt-crapprf.dstagpai = "crapprf_refin_inf"   AND
                              tt-crapprf.inpefref = 2
                              BREAK BY tt-crapprf.dtvencto DESC:

        IF   FIRST (tt-crapprf.dtvencto)   THEN
             DO:
                 ASSIGN aux_dsconteu = 
                     "REFIN (Ocorrencias mais recentes - ate cinco)".

                 RUN separador_item (INPUT aux_dsconteu,
                                     INPUT TRUE).
             END.

        DISPLAY STREAM str_1 tt-crapprf.dtvencto 
                             tt-crapprf.dsmtvreg 
                             tt-crapprf.vlregist 
                             tt-crapprf.dsinstit 
                             WITH FRAME f_inf_crapprf_serasa_pj.

        DOWN WITH FRAME f_inf_crapprf_serasa_pj.

    END.

    IF   aux_dsconteu = "- NADA CONSTA"   THEN
         DO:
             RUN separador_item (INPUT "REFIN",
                                 INPUT FALSE). 
         END.
    ELSE
         DO:
             /* Total de ocorrencias */
             ASSIGN rel_dsnegati = aux_dsnegati[1]
                    rel_vlnegati = aux_vlnegati[1].
             
             DISPLAY STREAM str_1 rel_dsnegati
                                  rel_vlnegati WITH FRAME f_tot_ocorrencias.             
         END.

    /* Acoes */
    FOR EACH tt-crapabr NO-LOCK BREAK BY tt-crapabr.dtacajud DESC:

        IF   FIRST (tt-crapabr.dtacajud)   THEN
             DO:
                 ASSIGN aux_dsconteu = 
                     "ACOES (Ocorrencias mais recentes - ate cinco)".   

                 RUN separador_item (INPUT aux_dsconteu,
                                     INPUT TRUE).
             END.                          

        DISPLAY STREAM str_1 tt-crapabr.dtacajud 
                             tt-crapabr.dsnataca 
                             tt-crapabr.vltotaca 
                             tt-crapabr.nrdistri 
                             tt-crapabr.nrvaraca 
                             tt-crapabr.nmcidade 
                             tt-crapabr.cdufende 
                             WITH FRAME f_inf_crapabr_serasa_pj.

        DOWN WITH FRAME f_inf_crapabr_serasa_pj.

    END.

    IF   TEMP-TABLE tt-crapabr:HAS-RECORDS    THEN
         DO:
             /* Total de ocorrencias */
             ASSIGN rel_dsnegati = aux_dsnegati[4]
                    rel_vlnegati = aux_vlnegati[4].
                
             DISPLAY STREAM str_1 rel_dsnegati
                                  rel_vlnegati WITH FRAME f_tot_ocorrencias. 
         END.
    ELSE
         DO:
             RUN separador_item (INPUT "ACOES",
                                 INPUT FALSE).
         END.

    /* RECUPERACOES, FALENCIAS E CONCORDATAS */
    FOR EACH tt-craprfc NO-LOCK BREAK BY tt-craprfc.dtregist DESC:

        IF   FIRST(tt-craprfc.dtregist)   THEN
             DO:
                 ASSIGN aux_dsconteu = 
                  "RECUPERACOES, FALENCIAS E CONCORDATAS (Ocr. recentes - ate cinco".

                 RUN separador_item (INPUT aux_dsconteu,
                                     INPUT TRUE).
             END.                          

        DISPLAY STREAM str_1 tt-craprfc.dtregist
                             tt-craprfc.dstipreg
                             tt-craprfc.dsorgreg
                             tt-craprfc.nmcidade
                             tt-craprfc.cdufende 
                             WITH FRAME f_inf_craprfc_serasa_pj.

        DOWN WITH FRAME f_inf_craprfc_serasa_pj.

    END.

    /* Total de ocorrencias */
    IF   TEMP-TABLE tt-craprfc:HAS-RECORDS THEN
         DO:
             ASSIGN rel_dsnegati = aux_dsnegati[5]
                    rel_vlnegati = aux_vlnegati[5].
         
             DISPLAY STREAM str_1 rel_dsnegati
                                  rel_vlnegati WITH FRAME f_tot_ocorrencias.
         END.
    ELSE
         DO:
             RUN separador_item (INPUT "RECUPERACOES, FALENCIAS E CONCORDATAS",
                                 INPUT FALSE).
         END.

    /* Cheques extraviados */
    ASSIGN aux_dsconteu = "- NADA CONSTA".

    FOR EACH tt-crapcsf WHERE tt-crapcsf.intipchq = 2
                              BREAK BY tt-crapcsf.dtinclus:

        IF   FIRST(tt-crapcsf.dtinclus)   THEN
             DO:
                 ASSIGN aux_dsconteu = 
           "CHEQUE SUSTADO/EXTRAVIADO (Ocorrencias mais recentes - ate cinco)".

                 RUN separador_item (INPUT aux_dsconteu,
                                     INPUT TRUE). 
             END.

        DISPLAY STREAM str_1 tt-crapcsf.dtinclus
                             tt-crapcsf.nrcheque
                             tt-crapcsf.cdalinea
                             tt-crapcsf.dsmotivo
                             tt-crapcsf.vlcheque
                             tt-crapcsf.nmbanchq
                             tt-crapcsf.cdagechq
                             tt-crapcsf.nmcidade
                             tt-crapcsf.cdufende 
                             WITH FRAME f_inf_crapcsf_serasa_pj.

        DOWN WITH FRAME f_inf_crapcsf_serasa_pj.

    END.

    IF   aux_dsconteu = "- NADA CONSTA"   THEN
         DO:
             RUN separador_item (INPUT "CHEQUE SUSTADO/EXTRAVIADO",
                                 INPUT FALSE).
         END.
    ELSE
         DO:
             /* Total de ocorrencias */
             ASSIGN rel_dsnegati = aux_dsnegati[7]
                    rel_vlnegati = aux_vlnegati[7].
         
             DISPLAY STREAM str_1 rel_dsnegati
                                  rel_vlnegati WITH FRAME f_tot_ocorrencias.
         END.

    /* Societarios */
    FOR EACH tt-crapcbd WHERE tt-crapcbd.dstagpai = "crapcbd_socio_inf" 
                              BREAK BY tt-crapcbd.pertotal DESC:

        IF  FIRST(tt-crapcbd.pertotal)   THEN
            DO:
                RUN separador_item 
                        (INPUT "CONTROLE SOCIETARIO ( Atualizado em " + 
                               STRING(tt-crapcbd.dtatusoc,"99/99/9999") + " )",
                         INPUT TRUE).
            END.
                                    
        DISPLAY STREAM str_1 tt-crapcbd.dscpfcgc
                             tt-crapcbd.nmtitcon
                             tt-crapcbd.dtentsoc
                             tt-crapcbd.percapvt
                             tt-crapcbd.pertotal
                             WITH FRAME  f_inf_crapcbd_serasa_pj.

        DOWN WITH FRAME  f_inf_crapcbd_serasa_pj.

    END.

    /* Administracao */
    FOR EACH tt-crapcbd WHERE tt-crapcbd.dstagpai = "crapcbd_adm_inf" 
                              BREAK BY tt-crapcbd.pertotal DESC:

        IF   FIRST(tt-crapcbd.pertotal)   THEN
             DO:
                 IF   tt-crapcbd.dtatuadm <> ? THEN
                      RUN separador_item 
                       (INPUT "ADMINISTRACAO ( Atualizado em " + 
                                STRING(tt-crapcbd.dtatuadm,"99/99/9999") + " )" ,
                        INPUT TRUE). 
                 ELSE
                      RUN separador_item (INPUT "ADMINISTRACAO",
                                          INPUT TRUE).
             END.                         
        
        DISPLAY STREAM str_1 tt-crapcbd.dscpfcgc
                             tt-crapcbd.nmtitcon
                             tt-crapcbd.dtentadm
                             tt-crapcbd.dsprofis
                             tt-crapcbd.dtmanadm
                             WITH FRAME  f_inf_crapcbd_serasa_pj_2.

        DOWN WITH FRAME f_inf_crapcbd_serasa_pj_2.

    END.

    /* Participacoes */
    /* Ler os socios */
    FOR EACH tt-crapcbd WHERE tt-crapcbd.dstagpai = "crapcbd_socio_inf" 
                              BREAK BY tt-crapcbd.pertotal DESC: 

        IF  FIRST(tt-crapcbd.pertotal)   THEN
            DO:
                RUN separador_item 
                 (INPUT "PARTICIPACOES ( Atualizado em " + 
                        STRING(tt-crapcbd.dtatusoc,"99/99/9999") + " )",
                  INPUT TRUE).

                VIEW STREAM str_1 FRAME f_tit_crapbcd_serasa_pj_3.
                
            END.

        /* Empresas dos socios*/
        FOR EACH tt-crappsa WHERE tt-crappsa.dscpfcgc = tt-crapcbd.dscpfcgc 
                                  BREAK BY tt-crappsa.nrdecnpj:
         
            ASSIGN aux_nmcidade = tt-crappsa.nmcidade + "-" + 
                                  tt-crappsa.cdufende.                          
            
            DISPLAY STREAM str_1 tt-crapcbd.dscpfcgc
                                 tt-crapcbd.nmtitcon
                                 tt-crappsa.nmvincul
                                 tt-crappsa.pertotal
                                 tt-crappsa.nrdecnpj 
                                 tt-crappsa.nmempres   
                                 aux_nmcidade        
                                 WITH FRAME f_empresa.

            DOWN WITH FRAME f_empresa.
        END.                  

    END.

    /* Resumo das pendencias */
    RUN separador_item ("RESUMO DE PENDENCIAS FINANCEIRAS SOCIOS - SERASA",
                        INPUT TRUE). 

    /* Ler os socios */
    FOR EACH tt-crapcbd WHERE tt-crapcbd.dstagpai = "crapcbd_socio_inf" 
                              BREAK BY tt-crapcbd.dscpfcgc DESC: 
                                
        DISPLAY STREAM str_1 tt-crapcbd.nmtitcon
                             tt-crapcbd.dtentsoc
                             tt-crapcbd.dscpfcgc
                             tt-crapcbd.percapvt
                             tt-crapcbd.pertotal 
                             WITH FRAME f_inf_crapcbd_serasa_pj_3.

        DOWN WITH FRAME f_inf_crapcbd_serasa_pj_3.

        VIEW STREAM str_1 FRAME f_titulo_serasa.

        /* Anotacoes */
        FOR EACH tt-craprpf WHERE 
                 tt-craprpf.dscpfcgc = tt-crapcbd.dscpfcgc:

            CASE tt-craprpf.innegati:
                WHEN 1 THEN
                    ASSIGN rel_dsnegati = "REFIN".
                WHEN 2 THEN
                    ASSIGN rel_dsnegati = "PEFIN".
                WHEN 3 THEN
                    ASSIGN rel_dsnegati = "Protesto".
                WHEN 4 THEN
                    ASSIGN rel_dsnegati = "Acao judicial".
                WHEN 5 THEN
                    ASSIGN rel_dsnegati = "Participacao falencia".
                WHEN 6 THEN
                    ASSIGN rel_dsnegati = "Cheque sem fundo".
                WHEN 7 THEN
                    ASSIGN rel_dsnegati = "Cheque Sust./Extrav.".
            END CASE.
                          
            DISPLAY STREAM str_1 rel_dsnegati        
                                 tt-craprpf.dsnegati
                                 tt-craprpf.vlnegati 
                                    WHEN tt-craprpf.dsnegati <> "Nada Consta"
                                 tt-craprpf.dtultneg 
                                 WITH FRAME f_anotacoes_1.
                                        
            DOWN WITH FRAME f_anotacoes_1.
            

        END.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Trata_BoaVista:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                               NO-UNDO.
    
    DEF VAR aux_dtdscore AS DATE                               NO-UNDO.
    DEF VAR aux_dsdscore AS CHAR                               NO-UNDO.    
    DEF BUFFER crabass2 FOR crapass.
    
    FORM  aux_dtdscore AT 03 label "Data da Consulta"     FORMAT "99/99/9999"
          aux_dsdscore AT 40 LABEL "Score"     FORMAT "x(70)"
              WITH SIDE-LABEL  WIDTH 132 FRAME f_inf_boavista.
        
    RUN separador_item (INPUT "BOA VISTA",
                        INPUT TRUE).    

    FIND FIRST crabass2 
      WHERE crabass2.cdcooper = par_cdcooper
        AND crabass2.nrdconta = par_nrdconta
        NO-LOCK NO-ERROR.
    
    IF AVAILABLE crabass2 THEN    
    DO:
      ASSIGN aux_dtdscore = crabass2.dtdscore
             aux_dsdscore = crabass2.dsdscore.
        END.
    
    IF aux_dtdscore = ? AND
       aux_dsdscore = "" THEN
      DO:   
          DISPLAY STREAM str_1 "SEM CONSULTA" AT 03 WITH FRAME f_nada_consta.
         RETURN "OK".
    END.

    DISPLAY STREAM  str_1  aux_dtdscore  aux_dsdscore
    WITH FRAME f_inf_boavista.
      
    RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_Mensagens:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-xml-geral.
    DEF OUTPUT PARAM TABLE FOR tt-msg-orgaos.


    EMPTY TEMP-TABLE tt-msg-orgaos.

    FOR EACH tt-xml-geral WHERE 
             tt-xml-geral.dstagavo = "crapcbd"       AND
             tt-xml-geral.dstagpai = "crapcbd_inf"   AND                     
             tt-xml-geral.dstagfil <> ""             NO-LOCK:

        IF   tt-xml-geral.dstagfil = "dslogret"   THEN
             DO:
                 IF   tt-xml-geral.dsdvalor <> " "   THEN
                      DO:
                          CREATE tt-msg-orgaos.
                          ASSIGN tt-msg-orgaos.dsmensag = 
                                            tt-xml-geral.dsdvalor.
                      END.
             END.
        ELSE 
        IF   tt-xml-geral.dstagfil = "nrcepend"   THEN
             DO:
                 FIND crapenc WHERE crapenc.cdcooper = par_cdcooper   AND
                                    crapenc.nrdconta = par_nrdconta   AND
                                    crapenc.idseqttl = par_idseqttl   AND
                                    crapenc.cdseqinc = 1
                                    NO-LOCK NO-ERROR.

                 IF   crapenc.nrcepend <> INTE(tt-xml-geral.dsdvalor)   AND 
                      INTE(tt-xml-geral.dsdvalor) > 0                   THEN
                      DO:
                          CREATE tt-msg-orgaos.
                          ASSIGN tt-msg-orgaos.dsmensag = "CEP da empresa " +
                                    "diverge do existente no SPC / Serasa".
                      END.
             END.

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_Dados_Consultado:

    DEF INPUT  PARAM par_inpessoa AS INTE                              NO-UNDO.
    DEF INPUT  PARAM TABLE FOR tt-xml-geral.
    DEF OUTPUT PARAM par_nmtitcon AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_dtconbir AS DATE                              NO-UNDO.
    DEF OUTPUT PARAM par_nmtitcab AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_dscpfcgc AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_inreapro AS CHAR                              NO-UNDO.

    FOR EACH tt-xml-geral WHERE 
             tt-xml-geral.dstagavo = "crapcbd"       AND
             tt-xml-geral.dstagpai = "crapcbd_inf"   AND                     
             tt-xml-geral.dstagfil <> ""             NO-LOCK:

        CASE tt-xml-geral.dstagfil:
            WHEN "nmtitcon" THEN 
                ASSIGN par_nmtitcon = tt-xml-geral.dsdvalor.
            WHEN "dtconbir" THEN
                ASSIGN par_dtconbir = DATE(tt-xml-geral.dsdvalor).
            WHEN "nmtitcab" THEN
                 ASSIGN par_nmtitcab = tt-xml-geral.dsdvalor.
            WHEN "nrcpfcgc" THEN
                 ASSIGN par_dscpfcgc = tt-xml-geral.dsdvalor.
            WHEN "inreapro" THEN
                 ASSIGN par_inreapro = tt-xml-geral.dsdvalor.

        END CASE.

    END.

    IF   par_inpessoa = 1 THEN
         ASSIGN par_dscpfcgc = STRING(par_dscpfcgc,"99999999999")
                par_dscpfcgc = STRING(par_dscpfcgc,"xxx.xxx.xxx-xx").
    ELSE
         ASSIGN par_dscpfcgc = STRING(par_dscpfcgc,"99999999999999")
                par_dscpfcgc = STRING(par_dscpfcgc,"xx.xxx.xxx/xxxx-xx").

END PROCEDURE.


PROCEDURE Trata_SPC:

    DEF INPUT  PARAM TABLE FOR tt-xml-geral.
    DEF OUTPUT PARAM par_dsnegati AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_vlnegati AS DECI                             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craprsc. 


    DEF VAR aux_nrseqreg AS INTE                                       NO-UNDO.
   

    EMPTY TEMP-TABLE tt-craprsc.

   
    /* Obter Registro SPC*/
    FOR EACH tt-xml-geral WHERE tt-xml-geral.dstagavo = "craprsc"     AND
                                tt-xml-geral.dstagpai = "craprsc_inf" AND
                                tt-xml-geral.dstagfil <> ""           NO-LOCK:

        IF  tt-xml-geral.dstagfil = "nrseqreg"   THEN
            DO:
                ASSIGN aux_nrseqreg = INTE(tt-xml-geral.dsdvalor). 
            END.
       
        FIND tt-craprsc WHERE tt-craprsc.nrseqreg = aux_nrseqreg NO-ERROR.

        IF  NOT AVAIL tt-craprsc   THEN
            DO:
                CREATE tt-craprsc.
                ASSIGN tt-craprsc.nrseqreg = aux_nrseqreg
                       par_dsnegati = STRING(INTE(par_dsnegati) + 1).
            END.

        IF   tt-xml-geral.dstagfil = "inlocnac"   THEN
             ASSIGN tt-craprsc.dslocnac =  tt-xml-geral.dsdvalor.
        ELSE
        IF   tt-xml-geral.dstagfil = "dsinstit"   THEN
             ASSIGN tt-craprsc.dsinstit = tt-xml-geral.dsdvalor.
        ELSE
        IF   tt-xml-geral.dstagfil = "dsentorg"   THEN
             ASSIGN tt-craprsc.dsentorg = tt-xml-geral.dsdvalor.
        ELSE
        IF   tt-xml-geral.dstagfil = "nmcidade"   THEN
             ASSIGN tt-craprsc.nmcidade = tt-xml-geral.dsdvalor.
        ELSE
        IF   tt-xml-geral.dstagfil = "cdufende"   THEN
             ASSIGN tt-craprsc.cdufende = tt-xml-geral.dsdvalor.
        ELSE
        IF   tt-xml-geral.dstagfil = "dtregist"   THEN
             ASSIGN tt-craprsc.dtregist = DATE(tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "dtvencto"   THEN
             ASSIGN tt-craprsc.dtvencto = DATE(tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "dsmtvreg"   THEN
             ASSIGN tt-craprsc.dsmtvreg = tt-xml-geral.dsdvalor.
        ELSE
        IF   tt-xml-geral.dstagfil = "vlregist" THEN
             ASSIGN tt-craprsc.vlregist = DECI(tt-xml-geral.dsdvalor)
                    par_vlnegati = par_vlnegati + DECI(tt-xml-geral.dsdvalor).
                                 
    END.

    IF   par_dsnegati = ""    THEN
         par_dsnegati = "Nada consta".

    RETURN "OK".

END PROCEDURE.


PROCEDURE Trata_Anotacoes:

    DEF INPUT  PARAM TABLE FOR tt-xml-geral.
    DEF OUTPUT PARAM par_dsnegati AS CHAR EXTENT 99                    NO-UNDO.
    DEF OUTPUT PARAM par_vlnegati AS DECI EXTENT 99                    NO-UNDO.
    DEF OUTPUT PARAM par_dtultneg AS DATE EXTENT 99                    NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craprpf.

    DEF VAR aux_innegati AS INTE                                       NO-UNDO.
    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_qtnegati AS INTE                                       NO-UNDO.

    
    FOR EACH tt-craprpf WHERE tt-craprpf.dscpfcgc = "":
        DELETE tt-craprpf.
    END.

    RUN Trata_SPC (INPUT TABLE tt-xml-geral,  
                  OUTPUT par_dsnegati[99],
                  OUTPUT par_vlnegati[99],
                  OUTPUT TABLE tt-craprsc).

    FOR EACH tt-xml-geral WHERE tt-xml-geral.dstagavo = "craprpf"       AND
                                tt-xml-geral.dstagpai = "craprpf_inf"   AND
                                tt-xml-geral.dstagfil <> ""        NO-LOCK:
    
        IF  tt-xml-geral.dstagfil = "innegati"   THEN
            DO:
                ASSIGN aux_innegati = INTE(tt-xml-geral.dsdvalor). 
            END.
    
        FIND tt-craprpf WHERE tt-craprpf.dscpfcgc = ""           AND
                              tt-craprpf.innegati = aux_innegati NO-ERROR.
    
        IF  NOT AVAIL tt-craprpf   THEN
            DO:
                CREATE tt-craprpf.
                ASSIGN tt-craprpf.dscpfcgc = ""
                       tt-craprpf.innegati = aux_innegati.
            END.    
    
        IF  tt-xml-geral.dstagfil = "qtnegati"   THEN
            ASSIGN tt-craprpf.dsnegati         = tt-xml-geral.dsdvalor
                    par_dsnegati[aux_innegati] = tt-xml-geral.dsdvalor.

        ELSE
        IF  tt-xml-geral.dstagfil = "vlnegati"   THEN
            ASSIGN tt-craprpf.vlnegati        = DECI(tt-xml-geral.dsdvalor)
                   par_vlnegati[aux_innegati] = 
                      par_vlnegati[aux_innegati] + DECI(tt-xml-geral.dsdvalor).
        ELSE
        IF  tt-xml-geral.dstagfil = "dtultneg"   THEN
            ASSIGN tt-craprpf.dtultneg        = DATE(tt-xml-geral.dsdvalor)
                   par_dtultneg[aux_innegati] = DATE(tt-xml-geral.dsdvalor).
    

    END.

    /* 98 -> Pefin e Refin juntos */   
    ASSIGN par_dsnegati[98] = STRING(INTE(par_dsnegati[01])) NO-ERROR.

    ASSIGN par_dsnegati[98] = STRING(INTE(par_dsnegati[98]) +  
                                     INTE(par_dsnegati[02])) NO-ERROR.

    IF   par_dsnegati[98] = ""   THEN
         ASSIGN par_dsnegati[98] = "Nada consta".

    /* Somar valores */
    ASSIGN par_vlnegati[98] = par_vlnegati[01] + par_vlnegati[02].

    /* Obter a data mais recente entre Pefin e Refin */
    IF   par_dtultneg[01] > par_dtultneg[02]   THEN
         ASSIGN par_dtultneg[98] = par_dtultneg[01].
    ELSE
         ASSIGN par_dtultneg[98] = par_dtultneg[02].

    /* Percorrer todos os valores salvos */
    DO aux_contador = 1 TO 99:

       /* 
       * 97 -> SPC + PEFIN/REFIN + PROTESTO + CHQUE SEM FUNDO  
       */

       /* 
       * 96 -> PEFIN + PROTESTO + CHEQUE SEM FUNDO + REFIN + ACOES 
       *       RECUPER. FAL. E CONCORD + CHEQUES SUST. E EXTRAV.
       */

       /* Gravar os valores */
       IF   CAN-DO("98,99,3,6",STRING(aux_contador))   THEN
            ASSIGN par_vlnegati[97] = par_vlnegati[97] + 
                                      par_vlnegati[aux_contador].

       IF   CAN-DO("2,3,6,1,4,5,7",STRING(aux_contador))   THEN
            ASSIGN par_vlnegati[96] = par_vlnegati[96] + 
                                      par_vlnegati[aux_contador].

       /* Se a quant. vem zerada ou nao pode ser convertida para int, next*/
       ASSIGN aux_qtnegati = INTE (par_dsnegati[aux_contador]) NO-ERROR.

       IF   ERROR-STATUS:ERROR   OR
            aux_qtnegati = 0     THEN
            NEXT.

       /* Gravar as quantidades */
       IF   CAN-DO("98,99,3,6",STRING(aux_contador))   THEN
            ASSIGN par_dsnegati[97] = STRING( INTE(par_dsnegati[97]) + 
                                              aux_qtnegati).
               
       IF   CAN-DO("2,3,6,1,4,5,7",STRING(aux_contador))   THEN
            ASSIGN par_dsnegati[96] = STRING( INTE(par_dsnegati[96]) + 
                                              aux_qtnegati).

    END.

    IF   par_dsnegati[96] = ""   THEN
         ASSIGN par_dsnegati[96] = "0".

    IF   par_dsnegati[97] = ""   THEN
         ASSIGN par_dsnegati[97] = "0".

    RETURN "OK".

END PROCEDURE.


PROCEDURE Trata_Societarios:

    DEF  INPUT  PARAM TABLE FOR tt-xml-geral.
    DEF  INPUT PARAM par_tpdconsu AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcbd. 

    DEF VAR aux_nrseqreg AS INTE                                       NO-UNDO.


    IF   par_tpdconsu = 1   THEN
         ASSIGN aux_dstagavo = "crapcbd_socio".
    ELSE
    IF   par_tpdconsu = 2   THEN
         ASSIGN aux_dstagavo = "crapcbd_adm".

    ASSIGN aux_dstagpai = aux_dstagavo + "_inf".

    FOR EACH tt-crapcbd WHERE tt-crapcbd.dstagpai = aux_dstagpai:
        DELETE tt-crapcbd.
    END.

    FOR EACH tt-xml-geral WHERE 
             tt-xml-geral.dstagavo = aux_dstagavo   AND
             tt-xml-geral.dstagpai = aux_dstagpai   AND
             tt-xml-geral.dstagfil <> ""            NO-LOCK:

        IF   tt-xml-geral.dstagfil = "nmtitcon" THEN
             DO:
                 ASSIGN aux_nrseqreg = aux_nrseqreg + 1.
             END.

        FIND tt-crapcbd WHERE tt-crapcbd.nrseqreg = aux_nrseqreg   AND 
                              tt-crapcbd.dstagpai = aux_dstagpai 
                              NO-LOCK NO-ERROR.

        IF   NOT AVAIL tt-crapcbd   THEN
             DO:
                 CREATE tt-crapcbd.
                 ASSIGN tt-crapcbd.nrseqreg = aux_nrseqreg
                        tt-crapcbd.nmtitcon = tt-xml-geral.dsdvalor
                        tt-crapcbd.dstagpai = aux_dstagpai.
             END.

        IF   tt-xml-geral.dstagfil = "nrcpfcgc"   THEN 
            ASSIGN tt-crapcbd.dscpfcgc = tt-xml-geral.dsdvalor.                 
        ELSE
        IF   tt-xml-geral.dstagfil = "percapvt"   THEN
             ASSIGN tt-crapcbd.percapvt = INTE(tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "dtentsoc"   THEN
             ASSIGN tt-crapcbd.dtentsoc = DATE(tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "pertotal"   THEN
             ASSIGN tt-crapcbd.pertotal = INTE(tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "dsprofis"   THEN
             ASSIGN tt-crapcbd.dsprofis = tt-xml-geral.dsdvalor.
        ELSE
        IF   tt-xml-geral.dstagfil = "dtmanadm"   THEN
             ASSIGN tt-crapcbd.dtmanadm = tt-xml-geral.dsdvalor.
        ELSE
        IF   tt-xml-geral.dstagfil = "dtatusoc"   THEN
             ASSIGN tt-crapcbd.dtatusoc = DATE(tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "dtentadm"   THEN
             ASSIGN tt-crapcbd.dtentadm = DATE(tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "dtatuadm"   THEN
             ASSIGN tt-crapcbd.dtatuadm = DATE(tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "nmvincul"   THEN
             ASSIGN tt-crapcbd.nmvincul = tt-xml-geral.dsdvalor.

    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Trata_Anotacoes_Pj:

    DEF INPUT  PARAM TABLE FOR tt-xml-geral.
    DEF OUTPUT PARAM TABLE FOR tt-craprpf.

    DEF VAR aux_nrcpfcgc AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrdecnpj AS CHAR                                       NO-UNDO.
    DEF VAR aux_innegati AS INTE                                       NO-UNDO.


    FOR EACH tt-xml-geral WHERE
             tt-xml-geral.dstagavo = "crapcbd_socio"      AND
             tt-xml-geral.dstagpai = "crapcbd_socio_inf"  AND 
          ( (tt-xml-geral.dstagfil = "nrcpfcgc"  AND  
             tt-xml-geral.dstagnet = "")  OR 
             tt-xml-geral.dstagfil = "craprpf_soc")       NO-LOCK:
  
        /* Obter o CPF do socio */
        IF   tt-xml-geral.dstagfil = "nrcpfcgc"   AND
             tt-xml-geral.dstagnet = ""           THEN
             DO:
                 ASSIGN aux_nrcpfcgc = tt-xml-geral.dsdvalor.
             END.

        IF   tt-xml-geral.dstagnet = ""   THEN
             NEXT.
       
        IF  tt-xml-geral.dstagnet = "innegati"   THEN
            DO:
                ASSIGN aux_innegati = INTE(tt-xml-geral.dsdvalor). 
            END.
    
        FIND tt-craprpf WHERE tt-craprpf.dscpfcgc = aux_nrcpfcgc AND
                              tt-craprpf.innegati = aux_innegati NO-ERROR.
    
        IF  NOT AVAIL tt-craprpf   THEN
            DO:
                CREATE tt-craprpf.
                ASSIGN tt-craprpf.dscpfcgc = aux_nrcpfcgc
                       tt-craprpf.innegati = aux_innegati.
            END.  
          
        IF  tt-xml-geral.dstagnet = "qtnegati"   THEN
            ASSIGN tt-craprpf.dsnegati = tt-xml-geral.dsdvalor.                                          
        ELSE
        IF  tt-xml-geral.dstagnet = "dsnegati"   THEN
            ASSIGN tt-craprpf.dsnegati = tt-xml-geral.dsdvalor.
        ELSE
        IF  tt-xml-geral.dstagnet = "dtultneg"   THEN
            ASSIGN tt-craprpf.dtultneg = DATE (tt-xml-geral.dsdvalor).
        ELSE
        IF  tt-xml-geral.dstagnet = "vlnegati"   THEN
            ASSIGN tt-craprpf.vlnegati = DECI(tt-xml-geral.dsdvalor).

    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Trata_Cheques:

    DEF  INPUT PARAM TABLE FOR tt-xml-geral.
    DEF OUTPUT PARAM TABLE FOR tt-crapcsf.

    DEF VAR aux_nrseqreg AS INTE                                       NO-UNDO.


    EMPTY TEMP-TABLE tt-crapcsf.

    /* Cheques do banco central */
    FOR EACH tt-xml-geral WHERE 
            (tt-xml-geral.dstagavo = "crapcsf_sem_fundos" OR
             tt-xml-geral.dstagavo = "crapcsf_sinistrado")            AND
             tt-xml-geral.dstagpai = tt-xml-geral.dstagavo + "_inf"   AND                     
             tt-xml-geral.dstagfil <> ""                              NO-LOCK:

        IF  tt-xml-geral.dstagfil = "nrseqreg"   THEN
            DO:
                ASSIGN aux_nrseqreg = INTE(tt-xml-geral.dsdvalor). 
            END.
       
        FIND tt-crapcsf WHERE tt-crapcsf.nrseqreg = aux_nrseqreg NO-ERROR.

        IF  NOT AVAIL tt-crapcsf   THEN
            DO:
                CREATE tt-crapcsf.
                ASSIGN tt-crapcsf.nrseqreg = aux_nrseqreg
                       tt-crapcsf.intipchq = IF   tt-xml-geral.dstagavo = 
                                                    "crapcsf_sem_fundos" THEN
                                                  1
                                             ELSE
                                                  2.
            END.

        CASE tt-xml-geral.dstagfi:

            WHEN "nmbanchq"   THEN 
                ASSIGN tt-crapcsf.nmbanchq = tt-xml-geral.dsdvalor.
            WHEN "cdagechq"   THEN
                ASSIGN tt-crapcsf.cdagechq = INTE(tt-xml-geral.dsdvalor).
            WHEN "cdalinea"   THEN
                ASSIGN tt-crapcsf.cdalinea = INTE(tt-xml-geral.dsdvalor).
            WHEN "dsmotivo" THEN
                ASSIGN tt-crapcsf.dsmotivo = tt-xml-geral.dsdvalor.
            WHEN "qtcheque"   THEN
                ASSIGN tt-crapcsf.qtcheque = INTE(tt-xml-geral.dsdvalor).
            WHEN "dtultocr"   THEN
                ASSIGN tt-crapcsf.dtultocr = DATE(tt-xml-geral.dsdvalor).
            WHEN "dtinclus"   THEN
                ASSIGN tt-crapcsf.dtinclus = DATE(tt-xml-geral.dsdvalor).
            WHEN "nrcheque"   THEN
                ASSIGN tt-crapcsf.nrcheque = tt-xml-geral.dsdvalor.
            WHEN "vlcheque"   THEN
                ASSIGN tt-crapcsf.vlcheque = DECI(tt-xml-geral.dsdvalor).
            WHEN "nmcidade"   THEN
                ASSIGN tt-crapcsf.nmcidade = tt-xml-geral.dsdvalor.
            WHEN "cdufende" THEN
                ASSIGN tt-crapcsf.cdufende = tt-xml-geral.dsdvalor.
        END CASE.

    END.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE Trata_Endereco:

    DEF  INPUT PARAM TABLE FOR tt-xml-geral.
    DEF OUTPUT PARAM aux_dsendere AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nmbairro AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nmcidade AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_cdufende AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_nrcepend AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM aux_dtatuend AS DATE                              NO-UNDO.


    FOR EACH tt-xml-geral WHERE 
             tt-xml-geral.dstagavo = "crapcbd"       AND
             tt-xml-geral.dstagpai = "crapcbd_inf"   AND                     
             tt-xml-geral.dstagfil <> ""             NO-LOCK:

        CASE tt-xml-geral.dstagfil:

            WHEN "dsendere"   THEN
                ASSIGN aux_dsendere = tt-xml-geral.dsdvalor.
            WHEN "nmbairro"   THEN
                ASSIGN aux_nmbairro = tt-xml-geral.dsdvalor.
            WHEN "nmcidade"   THEN
                ASSIGN aux_nmcidade = tt-xml-geral.dsdvalor.
            WHEN "cdufende"   THEN
                ASSIGN aux_cdufende = tt-xml-geral.dsdvalor.
            WHEN "nrcepend"   THEN
                ASSIGN aux_nrcepend = tt-xml-geral.dsdvalor.
            WHEN "dtatuend"   THEN
                ASSIGN aux_dtatuend  = DATE(tt-xml-geral.dsdvalor).

        END CASE.

    END.

END PROCEDURE.


PROCEDURE Trata_Pefin_Refin:

    DEF  INPUT PARAM par_idconsul AS INTE                              NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-xml-geral.
    DEF OUTPUT PARAM TABLE FOR tt-crapprf.

    DEF VAR aux_nrseqreg AS INTE                                       NO-UNDO.


    IF   par_idconsul = 1   THEN
         ASSIGN aux_dstagavo = "crapprf".
    ELSE 
    IF   par_idconsul = 2   THEN
         ASSIGN aux_dstagavo = "crapprf_pefin".
    ELSE
    IF   par_idconsul = 3   THEN
         ASSIGN aux_dstagavo = "crapprf_refin".

    ASSIGN aux_dstagpai = aux_dstagavo + "_inf".                

    FOR EACH tt-crapprf WHERE tt-crapprf.dstagpai = aux_dstagpai:
        DELETE tt-crapprf.
    END.

    /* Obter dados Pefin/Refin */
    FOR EACH tt-xml-geral WHERE tt-xml-geral.dstagavo = aux_dstagavo    AND
                                tt-xml-geral.dstagpai = aux_dstagpai    AND
                                tt-xml-geral.dstagfil <> ""        NO-LOCK:
           
        IF  tt-xml-geral.dstagfil = "nrseqreg"   THEN
            DO:
                ASSIGN aux_nrseqreg = INTE(tt-xml-geral.dsdvalor). 
            END.
       
        FIND tt-crapprf WHERE tt-crapprf.nrseqreg = aux_nrseqreg   AND 
                              tt-crapprf.dstagpai = aux_dstagpai   NO-ERROR.

        IF  NOT AVAIL tt-crapprf   THEN
            DO:
                CREATE tt-crapprf.
                ASSIGN tt-crapprf.nrseqreg = aux_nrseqreg.
                       tt-crapprf.dstagpai = aux_dstagpai.
            END.

        IF   tt-xml-geral.dstagfil = "dtvencto"   THEN
             ASSIGN tt-crapprf.dtvencto = DATE(tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "vlregist"   THEN
             ASSIGN tt-crapprf.vlregist = DECI(tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "dsinstit"   THEN
             ASSIGN tt-crapprf.dsinstit = tt-xml-geral.dsdvalor.
        ELSE
        IF   tt-xml-geral.dstagfil = "dsmtvreg"   THEN
             ASSIGN tt-crapprf.dsmtvreg = tt-xml-geral.dsdvalor.
        ELSE
        IF   tt-xml-geral.dstagfil = "dsnature"   THEN
             ASSIGN tt-crapprf.dsnature = tt-xml-geral.dsdvalor.
        ELSE
        IF   tt-xml-geral.dstagfil = "inpefref"   THEN
             ASSIGN tt-crapprf.inpefref = INTE(tt-xml-geral.dsdvalor).

    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Trata_Protestos:

    DEF  INPUT PARAM TABLE FOR tt-xml-geral.
    DEF OUTPUT PARAM TABLE FOR tt-crapprt.

    DEF VAR aux_nrseqreg AS INTE                                       NO-UNDO.


    EMPTY TEMP-TABLE tt-crapprt.

    FOR EACH tt-xml-geral WHERE tt-xml-geral.dstagavo = "crapprt"       AND
                                tt-xml-geral.dstagpai = "crapprt_inf"   AND
                                tt-xml-geral.dstagfil <> ""        NO-LOCK:

        IF  tt-xml-geral.dstagfil = "nmlocprt"   THEN
            DO:
                ASSIGN aux_nrseqreg = aux_nrseqreg + 1. 
            END.
       
        FIND tt-crapprt WHERE tt-crapprt.nrseqreg = aux_nrseqreg NO-ERROR.

        IF  NOT AVAIL tt-crapprt   THEN
            DO:
                CREATE tt-crapprt.
                ASSIGN tt-crapprt.nrseqreg = aux_nrseqreg
                       tt-crapprt.nmlocprt = tt-xml-geral.dsdvalor.
                NEXT.
            END.

        IF   tt-xml-geral.dstagfil = "qtprotes"   THEN
             ASSIGN tt-crapprt.qtprotes = tt-crapprt.qtprotes + 
                                INTE(tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "dtprotes"   THEN
             ASSIGN tt-crapprt.dtprotes = DATE (tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "vlprotes"   THEN
             ASSIGN tt-crapprt.vlprotes = DECI(tt-xml-geral.dsdvalor).
        ELSE
        IF   tt-xml-geral.dstagfil = "nmcidade"   THEN
             ASSIGN tt-crapprt.nmcidade = tt-xml-geral.dsdvalor.
        ELSE
        IF   tt-xml-geral.dstagfil = "cdufende"   THEN
             ASSIGN tt-crapprt.cdufende = tt-xml-geral.dsdvalor.

    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Trata_Acoes:

    DEF  INPUT PARAM TABLE FOR tt-xml-geral.
    DEF OUTPUT PARAM TABLE FOR tt-crapabr.

    DEF VAR aux_nrseqreg AS INTE                                    NO-UNDO.


    FOR EACH tt-xml-geral WHERE tt-xml-geral.dstagavo = "crapabr"       AND
                                tt-xml-geral.dstagpai = "crapabr_inf"   AND
                                tt-xml-geral.dstagfil <> ""        NO-LOCK:

        IF  tt-xml-geral.dstagfil = "nrseqreg"   THEN
            DO:
                ASSIGN aux_nrseqreg = INTE(tt-xml-geral.dsdvalor). 
            END.
       
        FIND tt-crapabr WHERE tt-crapabr.nrseqreg = aux_nrseqreg NO-ERROR.

        IF  NOT AVAIL tt-crapabr   THEN
            DO:
                CREATE tt-crapabr.
                ASSIGN tt-crapabr.nrseqreg = aux_nrseqreg.
            END.

        IF  tt-xml-geral.dstagfil = "dtacajud"   THEN
            ASSIGN tt-crapabr.dtacajud = DATE(tt-xml-geral.dsdvalor).
        ELSE
        IF  tt-xml-geral.dstagfil = "dsnataca"   THEN
            ASSIGN tt-crapabr.dsnataca = tt-xml-geral.dsdvalor.
        ELSE
        IF  tt-xml-geral.dstagfil = "vltotaca"   THEN
            ASSIGN tt-crapabr.vltotaca = DECI(tt-xml-geral.dsdvalor).
        ELSE
        IF  tt-xml-geral.dstagfil = "nrdistri"   THEN
            ASSIGN tt-crapabr.nrdistri = INTE(tt-xml-geral.dsdvalor).
        ELSE
        IF  tt-xml-geral.dstagfil = "nmcidade"   THEN
            ASSIGN tt-crapabr.nmcidade = tt-xml-geral.dsdvalor.
        ELSE
        IF  tt-xml-geral.dstagfil = "cdufende"   THEN
            ASSIGN tt-crapabr.cdufende = tt-xml-geral.dsdvalor.
        ELSE
        IF  tt-xml-geral.dstagfil = "nrvaraca"  THEN
            ASSIGN tt-crapabr.nrvaraca = INTE(tt-xml-geral.dsdvalor).

    END.

     RETURN "OK".

END PROCEDURE.


PROCEDURE Trata_Recuperacoes:

    DEF  INPUT PARAM TABLE FOR tt-xml-geral.
    DEF OUTPUT PARAM TABLE FOR tt-craprfc.

    DEF VAR aux_nrseqreg AS INTE                                       NO-UNDO.


    EMPTY TEMP-TABLE tt-craprfc.

    FOR EACH tt-xml-geral WHERE tt-xml-geral.dstagavo = "craprfc"      AND
                                tt-xml-geral.dstagpai = "craprfc_inf"  AND 
                                tt-xml-geral.dstagfil <> ""            NO-LOCK:

        IF  tt-xml-geral.dstagfil = "nrseqreg"   THEN
            DO:
                ASSIGN aux_nrseqreg = INTE(tt-xml-geral.dsdvalor). 
            END.
       
        FIND tt-craprfc WHERE tt-craprfc.nrseqreg = aux_nrseqreg NO-ERROR.

        IF  NOT AVAIL tt-craprfc   THEN
            DO:
                CREATE tt-craprfc.
                ASSIGN tt-craprfc.nrseqreg = aux_nrseqreg.
            END.

        IF  tt-xml-geral.dstagfil = "dtregist"   THEN
            ASSIGN tt-craprfc.dtregist = DATE(tt-xml-geral.dsdvalor).
        ELSE
        IF  tt-xml-geral.dstagfil = "dsinstit"   THEN
            ASSIGN tt-craprfc.dstipreg = tt-xml-geral.dsdvalor.
        ELSE
        IF  tt-xml-geral.dstagfil = "dsentorg"   THEN
            ASSIGN tt-craprfc.dsorgreg = tt-xml-geral.dsdvalor.
        ELSE
        IF  tt-xml-geral.dstagfil = "nmcidade"   THEN
            ASSIGN tt-craprfc.nmcidade = tt-xml-geral.dsdvalor.
        ELSE
        IF  tt-xml-geral.dstagfil = "cdufende"   THEN
            ASSIGN tt-craprfc.cdufende = tt-xml-geral.dsdvalor.

    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE Trata_Empresas:

    DEF  INPUT PARAM TABLE FOR tt-xml-geral.
    DEF OUTPUT PARAM TABLE FOR tt-crappsa.

    DEF VAR aux_nrcpfcgc AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrdecnpj AS CHAR                                       NO-UNDO.


    EMPTY TEMP-TABLE tt-crappsa.

    FOR EACH tt-xml-geral WHERE
             tt-xml-geral.dstagavo = "crapcbd_socio"      AND
             tt-xml-geral.dstagpai = "crapcbd_socio_inf"  AND 
            ( (tt-xml-geral.dstagfil = "nrcpfcgc"  AND  
               tt-xml-geral.dstagnet = "")  OR 
             tt-xml-geral.dstagfil = "crappsa_soc")       NO-LOCK:

        /* Obter o CPF do socio */
        IF   tt-xml-geral.dstagfil = "nrcpfcgc"   AND
             tt-xml-geral.dstagnet = ""           THEN
             DO:
                 ASSIGN aux_nrcpfcgc = tt-xml-geral.dsdvalor.
             END.

        IF   tt-xml-geral.dstagnet <> ""   THEN
             DO:        
                 IF   tt-xml-geral.dstagnet = "nrcpfcgc_empresa"   THEN
                      ASSIGN aux_nrdecnpj = tt-xml-geral.dsdvalor. 

                 FIND tt-crappsa WHERE tt-crappsa.nrdecnpj = aux_nrdecnpj   AND
                                       tt-crappsa.dscpfcgc = aux_nrcpfcgc 
                                       NO-ERROR.
                
                 IF   NOT AVAIL tt-crappsa   THEN
                      DO:
                          CREATE tt-crappsa.
                          ASSIGN tt-crappsa.nrdecnpj = aux_nrdecnpj
                                 tt-crappsa.dscpfcgc = aux_nrcpfcgc.
                      END.
                
                 IF  tt-xml-geral.dstagnet = "nmempres"   THEN
                     ASSIGN tt-crappsa.nmempres = tt-xml-geral.dsdvalor.
                 ELSE
                 IF  tt-xml-geral.dstagnet = "nmcidade"   THEN
                     ASSIGN tt-crappsa.nmcidade = tt-xml-geral.dsdvalor.
                 ELSE
                 IF  tt-xml-geral.dstagnet = "cdufende"   THEN
                     ASSIGN tt-crappsa.cdufende = tt-xml-geral.dsdvalor.
                 ELSE
                 IF  tt-xml-geral.dstagnet = "pertotal"   THEN
                     ASSIGN tt-crappsa.pertotal = INTE(tt-xml-geral.dsdvalor).
                 ELSE
                 IF  tt-xml-geral.dstagnet = "nmvincul"   THEN
                     ASSIGN tt-crappsa.nmvincul = tt-xml-geral.dsdvalor.
             END.
    END.                

    RETURN "OK".

END PROCEDURE.

PROCEDURE Imprime_Anotacoes:

    DEF INPUT PARAM TABLE FOR tt-craprpf.


    RUN separador_item (INPUT "RESUMO ANOTACOES NEGATIVAS",
                        INPUT TRUE).

    VIEW STREAM str_1 FRAME f_titulo_serasa.
    
    /* Anotacoes negativas */
    FOR EACH tt-craprpf WHERE tt-craprpf.dscpfcgc = "" 
                              NO-LOCK BY tt-craprpf.innegati:

        CASE tt-craprpf.innegati:
            WHEN 1 THEN
                ASSIGN rel_dsnegati = "REFIN".
            WHEN 2 THEN
                ASSIGN rel_dsnegati = "PEFIN".
            WHEN 3 THEN
                ASSIGN rel_dsnegati = "Protesto".
            WHEN 4 THEN
                ASSIGN rel_dsnegati = "Acao judicial".
            WHEN 5 THEN
                ASSIGN rel_dsnegati = "Participacao falencia".
            WHEN 6 THEN
                ASSIGN rel_dsnegati = "Cheque sem fundo".
            WHEN 7 THEN
                ASSIGN rel_dsnegati = "Cheque Sust./Extrav.".
        END CASE.
        
        DISPLAY STREAM str_1 rel_dsnegati       
                             tt-craprpf.dsnegati
                             tt-craprpf.vlnegati 
                                WHEN tt-craprpf.dsnegati <> "Nada Consta"
                             tt-craprpf.dtultneg
                             WITH FRAME f_anotacoes_1.

        DOWN WITH FRAME f_anotacoes_1.

    END.           

END PROCEDURE.

PROCEDURE separador_item:

    DEF INPUT PARAM par_dstitulo AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_flgregis AS LOGI                            NO-UNDO.

    DEF VAR aux_dsespaco AS CHAR                                    NO-UNDO.

    FORM aux_dslinha1 FORMAT "x(130)"
         SKIP
         aux_dssepara FORMAT "x(130)"
         SKIP
         aux_dslinha2 FORMAT "x(130)"
         SKIP
         WITH SIDE-LABEL NO-LABEL WIDTH 132 FRAME f_separador.

    ASSIGN aux_dslinha1 = FILL("-",92)
           aux_dslinha2 = FILL("-",92)
           aux_dsespaco = FILL(" ", INTE ((92 - LENGTH(par_dstitulo)) / 2)) 
           aux_dssepara = aux_dsespaco + par_dstitulo + aux_dsespaco.

    DISPLAY STREAM str_1 aux_dslinha1
                         aux_dssepara
                         aux_dslinha2 WITH FRAME f_separador.
            
    IF  NOT par_flgregis   THEN
        DISPLAY STREAM str_1 "NADA CONSTA" AT 03 WITH FRAME f_nada_consta.

END PROCEDURE.

/* ......................................................................... */