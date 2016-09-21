/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------------+-------------------------------------------+
  | Rotina Progress                       | Rotina Oracle PLSQL                       |
  +---------------------------------------+-------------------------------------------+
  | b1wgen0112.p (Variaveis)              | EXTR0002                                  |
  | Gera_Impressao                        | EXTR0002.pc_gera_impressao                |
  | gera-impextdpv                        | EXTR0002.pc_gera_impextdpv                |
  | gera-impextcti                        | EXTR0002.pc_gera_impextcti                |
  | gera-impextir                         | EXTR0002.pc_gera_impextir                 |
  | gera-impextepr                        | EXTR0002.pc_gera_impextepr                |
  | gera-impextrda                        | EXTR0002.pc_gera_impextrda                |
  | gera-impextppr                        | EXTR0002.pc_gera_impextppr                |
  | gera-impextcap                        | EXTR0002.pc_gera_impextcap                |
  | gera-impexttar                        | EXTR0002.pc_gera_impexttar                |
  | gera-impextapl                        | EXTR0002.pc_gera_impextapl                |
  | consulta-imposto-renda                | EXTR0002.pc_consulta_imposto_renda        |
  | imprime_extrato                       | EXTR0002.pc_imprime_extrato     
  +------------------------------------------+----------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0112.p
    Autor   : Gabriel Capoia dos Santos (DB1)
    Data    : Agosto/2011                        Ultima atualizacao: 02/08/2016

    Objetivo  : Tranformacao BO tela IMPRES

    Alteracoes: 
               04/10/2011 - Adicionado o parametro par_flgerlog na chamada da 
                            procedure extrato_cotas (Rogerius Milit�o - DB1)
               
               21/10/2011 - Adicionado a include b1cabrelvar.i 
                            (Rogerius Milit�o - DB1)

               06/02/2012 - Ajsutes em layout e informa��es adicionais em
                            Informativos de Rendimento. (Jorge) 

                21/03/2012 - Modificado o titulo do item 3 do extrato de  
                            tarifas (Tiago).

                23/03/2012 - Tratamento para composicao do saldo do extrato
                             tt-extrato_epr.flgsaldo (Tiago)

                03/04/2012 - Inserido procedure imprime extrato (Tiago).

                17/04/2012 - Alteracoes na procedure imprime extrato (Tiago).

                19/04/2012 - Alteracoes na procedure gera-impextepr (Tiago).

                02/05/2012 - Modificacoes nahora de compor o saldo
                             do emprestimo tipo 1 (Tiago).

                28/08/2012 - Novo param. par_tprelato na gera-impextrda
                           - Alter. FOR EACH tt-saldo-rdca na gera-impextrda
                           - Novo param tpmodelo na Valida_Opcao
                           - TT-IMPRES incluida validacao do tpmodelo
                           - Procedure Gera_Impressao_Aplicacao
                           - Novos parametros DATA na chamada da procedure
                             obtem-dados-aplicacoes (Guilherme/Supero).
                             
                01/10/2012 - Ajustes format dos frames f_lanctos_rdc e
                             f_lanctos da procedure gera-impextrda . (Jorge)
                             
                02/10/2012 - Ajustes no layout de impressao da procedure
                             gera-impextcap (Lucas R.).
                            
                03/10/2012 - Trocado parametro dshistor pelo dsextrat em 
                             procedure gera-impextppr. (Jorge)           
                             
                04/10/2012 - Altera��es no frame 'f_lanctos' para exibi��o do
                             campo de Descr. do Extrato (Lucas) [Projeto Tarifas] 
                             
                08/10/2012 - Ajustes no layout de impressao da procedure
                             gera-impextepr e imprime_extrato, removido opcao
                             de tpemprst = 1 da gera-impextepr (Lucas R.)
                             
                17/10/2012 - Nova chamada da procedure valida_operador_migrado
                             da b1wgen9998 para controle de contas e operadores
                             migrados (David Kruger).
                             
                11/12/2012 - Incluir historicos de migracao (Ze).
                
                30/01/2013 - Incluir tratamento para nao aparecer juros na
                             listagem quando cdhistor = 1040,1041,1042,1043
                             (Lucas R.).
                             
                13/02/2013 - Adicionado em "Rendimentos Isentos" e "Informacoes 
                             Complementares" o item "CREDITO RETORNO DAS SOBRAS"
                             (Jorge).
                             
                14/02/2013 - Nova chamada da procedure valida_restricao_operador
                             Projeto Acesso a contas Restritas (Lucas R.)
                             
                26/03/2013 - Incluido dshistor na ordena��o do emprestimo 
                             price pre-fixado. (Irlan)
                
                29/05/2013 - Chamada da procedure verifica-tarifacao-extrato
                             na procedure grava_dados para pegar o campo
                             aux_inisenta (Tiago).
                                 
                04/06/2013 - Ajuste no Demonstrativo Financeiro 
                             (Guilherme/Supero).
                             
                11/06/2013 - Incluir etorna-valor-blqjud e listado vlblqjud
                             como rodape dos relatorios nas procedures:
                             gera-impextrda, gera-impextppr, gera-impextcap,
                             gera_impressao_demonstrativo, gera-impextapl, 
                             gera_impressao_sintetico,gera-impextdpv (Lucas R).
                             
                18/06/2013 - Segunda fase do Projeto Credito (Gabriel).
                
                01/07/2013 - Retirado o USE-INDEX da crapext (Evandro).
                
                08/08/2013 - Ajuste na ordenacao do extrato do emprestimo 
                            (Gabriel).
                  
                30/09/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                            a escrita ser� PA (Andr� Euz�bio - Supero).  
                            
                27/11/2013 - Ajuste na procedure imprime_extrato para
                             alimentar a aux_txinmens com craplcr.perjurmo
                             (Adriano).
                             
                11/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                07/01/2014 - Ajuste de format de documento e valor no frame 
                             f_lanctos_rdc, procedure gera-impextrda (Carlos)
                             
                31/01/2014 - Ajustes no format do frame f_lanctos0, "nrdocmto"
                             (Lucas R.)
                             
                05/02/2014 - Ajustes no format da procedure gera-impextcap
                             frame f_lanctos_n "nrdocmto" (Lucas R.)
                             
                24/02/2014 - Adicionado param. de paginacao em procedure
                             obtem-dados-emprestimos em BO 0002.(Jorge)
                                          
                14/04/2014 - Ajuste para mostrar Aplicacao de Renda Fixa em
                             Inf. Rend. de PJ e bloquear impressao de Inf. Rend.
                             de PF quando for PJ.(Jorge)
                             
                03/07/2014 - Restricao de operadores (Chamado 163002) 
                             (Jonata - RKAM).  
                             
                04/08/2014 - Incluso limpeza da Temp-Table tt-extrato_epr_aux
                             na procedure imprime_extrato (Daniel)             
                             
                21/10/2014 - Alteracao da Gera_Impressao_Aplicacao para chamar 
                             a pc_lista_aplicacoes_car. Remocao das procedures
                             (gera-impextdpv,gera-impextcti,gera-impextir,
                              gera-impextepr,gera-impextrda,gera-impextppr,
                              gera-impextcap,gera-impexttar,gera-impextapl) do
                              PROGRESS para utilizacao das procedures convertidas
                              para ORACLE.(Carlos Rafael Tanholi - Projeto Captacao)                       
                             
                21/10/2013 - Ajuste na rotina gera-impextepr para utilizar a variavel
                             tt-dados-epr.nrctremp na busca da craplem (Chamado 183410)
                             (Andrino - RKAM)
                
                18/11/2014 - Adicionado format para valor negativo no campo 
                             tt-extr-rdca.vllanmto da gera-impextrda 
                             (Douglas - Chamado 191418)

                21/01/2015 - Inclusao do parametro par_intpextr na Gera_Impressao
                             para ser usado na pc_gera_impressao_car servindo para 
                             indicar o tipo de extrato a ser gerado.
                             (Carlos Rafael Tanholi - Projeto Captacao) 
                             
                10/02/2015 - Ajuste na procedure "imprime_extrato" para zerar
                             o saldo no ultimo lancamento quando o contrato
                             estiver em prejuizo. (James/Oscar)
                             
                12/03/2015 - Passagem do parametro par_nranoref para a procedure
                             pc_gera_impressao_car atraves da procedure Gera_Impressao
                             (Carlos Rafael Tanholi)                                                       
                
                08/04/2015 - Corre��o dos dados impressos no relatorio 622 - Demonstrativo
                             de Aplicacoes. pi_monta_demonstrativo (Carlos Rafael Tanholi).
                
                05/05/2015 - Adicionado coluna de data de carencia e de carencia no relatorio
                             demonstrativo de aplicacoes. Tambem foi adicionado a data de carencia
                             no relatorio analitico e sinetico de aplicacoes. SD 266191 (Kelvin)
                             
                28/05/2015 - Ajuste na procedure "imprime_extrato" para 
                             verificar se cobra multa. (James)
                             
                13/08/2015 - Tratado historicos 1711 e 1720 na procedure 
                             imprime_extrato. (Reinert)
                             
                08/10/2015 - Tratar os hist�ricos de estorno do produto PP (Oscar)
                
                10/12/2015 - Ajuste na procedure "Valida_Opcao" para permitir filtro
                             para o ano atual. (Dionathan)
                
                11/12/2015 - Ajustes para inclusao de novo relatorio de 
                            "Extrato Operacao de credito"
                            (Jonathan RKAM - M273).
                
                06/04/2016 - Incluida a procedure pc_verifica_pacote_tarifas para o 
                             Prj. Tarifas 218/2, na procedure Grava_Dados (Jean Michel).
                             
                02/08/2016 - Nao tratar parametro de isencao de extrato na cooperativa
                             quando cooperado possuir servico de extrato no pacote de 
                             tarifas (Diego).

                11/07/2016 - M325 - Informe de Rendimentos - Novos parametros
                             para Gera_Impressao (Guilherme/SUPERO)            
                                                      
............................................................................*/

/*............................. DEFINICOES .................................*/

{ sistema/generico/includes/b1wgen9999tt.i  }
{ sistema/generico/includes/b1wgen0112tt.i  }
{ sistema/generico/includes/b1wgen0081tt.i  }
{ sistema/generico/includes/b1wgen0021tt.i  }
{ sistema/generico/includes/b1wgen0020tt.i  }
{ sistema/generico/includes/b1wgen0006tt.i  }
{ sistema/generico/includes/b1wgen0004tt.i  }
{ sistema/generico/includes/b1wgen0003tt.i  }
{ sistema/generico/includes/b1wgen0002tt.i  }
{ sistema/generico/includes/b1wgen0001tt.i  }
{ sistema/generico/includes/b1wgen0084tt.i  }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/var_internet.i  }

{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR  FORMAT "x(70)"                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0084 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0002 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen9998 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0001 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                      NO-UNDO.

DEF VAR tot_sldresga AS DECIMAL                                     NO-UNDO. 
DEF VAR aux_dtmvtolt AS DATE                                        NO-UNDO. 

DEF VAR rel_cdagenci AS INTE    FORMAT "zz9"                        NO-UNDO.
DEF VAR rel_nmresage AS CHAR    FORMAT "x(15)"                      NO-UNDO.

DEF VAR aux_vlblqjud AS DECI                                        NO-UNDO.
DEF VAR aux_vlresblq AS DECI                                        NO-UNDO.

DEF STREAM str_1.

DEF TEMP-TABLE tt-extr-apl      NO-UNDO LIKE tt-extr-rdca.

DEF BUFFER bt-saldo-demonst  FOR tt-demonstrativo.
DEF BUFFER bt-demonstrativo  FOR tt-demonstrativo.
DEF BUFFER crabrda           FOR craprda.

FUNCTION LockTabela   RETURNS CHARACTER PRIVATE () FORWARD.

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                EFETUA A BUSCA DOS DADOS DO ASSOCIADO                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

     DEF OUTPUT PARAM TABLE FOR tt-impres.
     DEF OUTPUT PARAM TABLE FOR tt-erro.

     DEF VAR aux_flgemiss AS LOGI                                    NO-UNDO.
     DEF VAR aux_flgtarif AS LOGI                                    NO-UNDO.
     DEF VAR aux_inrelext AS INTE                                    NO-UNDO.
     DEF VAR aux_dsextrat AS CHAR                                    NO-UNDO.
     DEF VAR aux_opmigrad AS LOGI                                    NO-UNDO.
         
     
     DEF BUFFER crabass FOR crapass.
     DEF BUFFER crabext FOR crapext.

     ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem, des_dorigens,","))
            aux_dstransa = "Consulta Extrato"
            aux_dscritic = ""
            aux_cdcritic = 0
            aux_returnvl = "NOK".
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-impres.
        EMPTY TEMP-TABLE tt-erro.

        RUN sistema/generico/procedures/b1wgen9998.p
            PERSISTENT SET h-b1wgen9998.
         
        /* Validacao de operador e conta migrada */
        RUN valida_operador_migrado IN h-b1wgen9998 (INPUT par_cdoperad,
                                                     INPUT par_nrdconta,
                                                     INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     OUTPUT aux_opmigrad,
                                                     OUTPUT TABLE tt-erro).
                     

        DELETE PROCEDURE h-b1wgen9998.

        IF  RETURN-VALUE <> "OK"  THEN
            DO:
               FIND tt-erro NO-LOCK NO-ERROR.

               IF AVAIL tt-erro THEN
                  DO:
                     ASSIGN aux_cdcritic = tt-erro.cdcritic.

                     EMPTY TEMP-TABLE tt-erro.
                  END.
               ELSE
                 ASSIGN aux_cdcritic = 36.
                 LEAVE Busca.

            END. 

        IF par_cddopcao <> "I" AND aux_opmigrad THEN
           DO:
              ASSIGN aux_cdcritic = 36.
              LEAVE Busca.
           END.

        FOR EACH crabext WHERE crabext.cdcooper = par_cdcooper AND
                               crabext.insitext = 0            NO-LOCK:

            ASSIGN aux_flgemiss = IF   crabext.insitext = 0 THEN 
                                       FALSE 
                                  ELSE TRUE
                   aux_flgtarif = IF   crabext.inisenta = 0 THEN
                                       TRUE 
                                  ELSE FALSE
                   aux_inrelext = IF   crabext.tpextrat = 1 THEN 
                                       crabext.inselext 
                                  ELSE 0.

            CASE crabext.tpextrat:
             
                WHEN 1  THEN ASSIGN aux_dsextrat = "C/C".
                WHEN 2  THEN ASSIGN aux_dsextrat = "I.R.".
                WHEN 3  THEN ASSIGN aux_dsextrat = "EMPR".
                WHEN 4  THEN
                    DO:
                        FOR FIRST crabrda WHERE 
                                        crabrda.cdcooper = par_cdcooper     AND
                                        crabrda.nrdconta = crabext.nrdconta AND
                                        crabrda.nraplica = crabext.nraplica
                                        NO-LOCK:
                        END.

                        IF  AVAILABLE crabrda THEN
                            DO:
                                IF  crabrda.tpaplica > 5 THEN
                                    ASSIGN aux_dsextrat = "RDC".
                                ELSE
                                    ASSIGN aux_dsextrat = "RDCA".
                            END.
                        ELSE
                            ASSIGN aux_dsextrat = "". 
                    END.
                WHEN 5  THEN ASSIGN aux_dsextrat = "PROG".
                WHEN 6  THEN ASSIGN aux_dsextrat = "IRJr".
                WHEN 7  THEN ASSIGN aux_dsextrat = "CI".
                WHEN 8  THEN ASSIGN aux_dsextrat = "CAP".
                WHEN 9  THEN ASSIGN aux_dsextrat = "Tari".
                WHEN 10 THEN ASSIGN aux_dsextrat = "Apli".
                WHEN 12 THEN ASSIGN aux_dsextrat = "OpCr".
             
            END.

            CREATE tt-impres.
            ASSIGN tt-impres.dtrefere = crabext.dtrefere
                   tt-impres.dtreffim = crabext.dtreffim
                   tt-impres.inisenta = IF  crabext.inisenta = 0 THEN  
                                             TRUE
                                        ELSE FALSE
                   tt-impres.inselext = crabext.inselext
                   tt-impres.nranoref = crabext.nranoref
                   tt-impres.nraplica = crabext.nraplica
                   tt-impres.nrctremp = crabext.nrctremp
                   tt-impres.nrdconta = crabext.nrdconta
                   tt-impres.tpextrat = crabext.tpextrat
                   tt-impres.insitext = crabext.insitext
                   tt-impres.dsextrat = aux_dsextrat
                   tt-impres.flgemiss = aux_flgemiss
                   tt-impres.flgtarif = aux_flgtarif
                   tt-impres.inrelext = aux_inrelext.

        END. /* FOR EACH crabext */

        IF  NOT TEMP-TABLE tt-impres:HAS-RECORDS THEN
            DO:
                ASSIGN aux_cdcritic = 266.
                LEAVE Busca.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Busca.

     END. /* Busca */

     IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------- */
/*                  Efetua a Valida��o dos dados informados                  */
/* ------------------------------------------------------------------------- */
PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextrat AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabass FOR crapass.

    DEF VAR aux_opmigrad AS LOG                                     NO-UNDO.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = ""
           aux_dstransa = "Valida Extrato"
           aux_cdcritic = 0
           par_nmdcampo = ""
           aux_returnvl = "NOK".


    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        
        EMPTY TEMP-TABLE tt-erro.
        
        RUN sistema/generico/procedures/b1wgen9998.p
            PERSISTENT SET h-b1wgen9998.
         
        /* Validacao de operador e conta migrada */
        RUN valida_operador_migrado IN h-b1wgen9998 (INPUT par_cdoperad,
                                                     INPUT par_nrdconta,
                                                     INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     OUTPUT aux_opmigrad,
                                                     OUTPUT TABLE tt-erro).
                     

        DELETE PROCEDURE h-b1wgen9998.
                   
        IF  RETURN-VALUE <> "OK"  THEN
            DO:
               FIND tt-erro NO-LOCK NO-ERROR.

               IF AVAIL tt-erro THEN
                  DO:
                     ASSIGN aux_cdcritic = tt-erro.cdcritic.

                     EMPTY TEMP-TABLE tt-erro.
                  END.
               ELSE
                 ASSIGN aux_cdcritic = 36.
                
                 LEAVE Valida.

            END. 

       IF  par_nmdatela = "impres" THEN
           DO:
               IF  NOT VALID-HANDLE(h-b1wgen9998) THEN
                   RUN sistema/generico/procedures/b1wgen9998.p
                       PERSISTENT SET h-b1wgen9998.
               
               RUN valida_restricao_operador IN h-b1wgen9998
                                            (INPUT par_cdoperad,
                                             INPUT par_nrdconta,
                                             INPUT "",
                                             INPUT par_cdcooper,
                                            OUTPUT aux_dscritic).
               
               IF  VALID-HANDLE(h-b1wgen9998) THEN
                   DELETE OBJECT h-b1wgen9998.

               IF  RETURN-VALUE <> "OK" THEN
                   DO:
                       RUN gera_erro (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT 1,
                                      INPUT 0,
                                      INPUT-OUTPUT aux_dscritic).
                      RETURN "NOK".  
                   END.



           END.

        IF par_cddopcao <> "I" AND aux_opmigrad THEN
           DO:
              ASSIGN aux_cdcritic = 36.
              LEAVE Valida.
           END.

        /* Validar o digito da conta */
        IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_nrdconta ) THEN
            DO:
               ASSIGN aux_cdcritic = 8
                      par_nmdcampo = "nrdconta".
               LEAVE Valida.
            END.
        
        /* Informacoes sobre o cooperado */
        FOR FIRST crabass FIELDS(tpextcta cdtipcta dtdemiss cdsitdct cdagenci inpessoa)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK: END.

        IF  NOT AVAILABLE crabass THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       par_nmdcampo = "nrdconta".
                LEAVE Valida.
            END.

        IF  par_tpextrat > 12 OR par_tpextrat = 0 OR par_tpextrat = 11 THEN
            DO:
                ASSIGN aux_cdcritic = 264
                       par_nmdcampo = "tpextrat".
                LEAVE Valida.
            END.

        IF (par_tpextrat = 6 AND crabass.inpessoa = 1) 
            OR 
           (par_tpextrat = 2 AND crabass.inpessoa = 2) 
            THEN
            DO:
                ASSIGN aux_cdcritic = 436
                       par_nmdcampo = "tpextrat".
                LEAVE Valida.
            END.

        ASSIGN aux_returnvl = "OK".
        
        LEAVE Valida.

    END. /* Valida */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  aux_returnvl = "NOK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT NO,
                            INPUT 1, /** idseqttl **/
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).


END PROCEDURE. /* Valida_Dados */

/* ------------------------------------------------------------------------- */
/*                  Efetua a Valida��o dos dados informados                  */
/* ------------------------------------------------------------------------- */
PROCEDURE Valida_Opcao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextrat AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtreffim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgtarif AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nranoref AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inselext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemiss AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_inrelext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpmodelo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-impres.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_dtrefere AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM aux_dtreffim AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_dsextrat AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_msgretor AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrmesant AS INTE                                    NO-UNDO.
    DEF VAR aux_nranoant AS INTE                                    NO-UNDO.
    DEF VAR aux_dtmesant AS DATE                                    NO-UNDO.
    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.


    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabext FOR crapext.
    DEF BUFFER crabdir FOR crapdir.
    DEF BUFFER crabrpp FOR craprpp.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = ""
           aux_dstransa = "Valida Extrato"
           aux_cdcritic = 0
           aux_dtrefere = par_dtrefere
           aux_dtreffim = par_dtreffim
           par_nmdcampo = ""
           aux_returnvl = "NOK"
           aux_nrmesant = IF MONTH(par_dtmvtolt) = 1
                          THEN 12
                          ELSE MONTH(par_dtmvtolt) - 1

           aux_nranoant = IF MONTH(par_dtmvtolt) = 1
                          THEN YEAR(par_dtmvtolt) - 1
                          ELSE YEAR(par_dtmvtolt)

           aux_dtmesant = DATE(aux_nrmesant,01,aux_nranoant).
    

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.
       
        /* Validar o digito da conta */
        IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_nrdconta ) THEN
            DO:
               ASSIGN aux_cdcritic = 8.
               LEAVE Valida.
            END.
        
        /* Informacoes sobre o cooperado */
        FOR FIRST crabass FIELDS(tpextcta cdtipcta dtdemiss cdsitdct cdagenci)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK: END.

        IF  NOT AVAILABLE crabass THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE Valida.
            END.
    
        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.


        CASE par_tpextrat:
            WHEN 1 OR WHEN 7 THEN
                DO:
                    IF  par_dtrefere = ? THEN
                        ASSIGN aux_dtrefere = par_dtmvtolt - 
                                              DAY(par_dtmvtolt) + 1
                               par_dtrefere = aux_dtrefere.

                    IF  par_tpextrat = 1 AND
                        par_dtreffim = ? THEN
                        ASSIGN aux_dtreffim = par_dtmvtolt
                               par_dtreffim = aux_dtreffim.

                    IF  ((par_dtrefere < aux_dtmesant  OR
                          par_dtrefere > par_dtmvtolt) AND
                          par_tpextrat <> 1)           OR
                        ((par_dtreffim > par_dtmvtolt  OR
                          par_dtrefere > par_dtreffim) AND
                          par_tpextrat = 1)            THEN
                        DO:
                            ASSIGN aux_cdcritic = 13
                                   par_nmdcampo = "dtrefere".
                            LEAVE Valida.
                        END.

                    IF  par_inrelext = 0 AND
                        par_tpextrat = 1 THEN
                        DO:
                            ASSIGN aux_cdcritic = 375
                                   par_nmdcampo = "inrelext".
                            LEAVE Valida.
                        END.

                    IF  par_dtrefere <= 03/31/2005  AND par_tpextrat = 1 THEN
                        ASSIGN aux_dtrefere = 04/01/2005.

                    IF  par_cddopcao = "I" THEN
                        IF  par_flgtarif AND par_tpextrat = 1  THEN
                            DO:
                                FOR FIRST crabext WHERE
                                          crabext.cdcooper = par_cdcooper AND
                                          crabext.nrdconta = par_nrdconta AND
                                          crabext.tpextrat = 1 NO-LOCK: END.
    
                                IF  AVAIL crabext THEN
                                    DO:
                                        ASSIGN aux_msgretor = 
                                             DYNAMIC-FUNCTION("BuscaCritica" IN
                                                      h-b1wgen0060, INPUT 531).
                                        
                                    END.
                                
                            END.
                END. /* tpextrat =  1 ou 7*/
            WHEN 2 OR WHEN 6 THEN
                DO:
                    IF  par_nranoref <= 1000 THEN
                        DO:
                            ASSIGN aux_dscritic = "560 - Ano errado. Deve " +
                                                  "ser no formato AAAA. " +
                                                  "Ex.: 1997"
                                   par_nmdcampo = "nranoref".
                                   
                            LEAVE Valida.
                        END.

                    IF  par_nranoref = YEAR(par_dtmvtolt) THEN
                        DO:
                            IF  par_tpextrat = 2 THEN
                                DO:
                                    ASSIGN aux_cdcritic = 438
                                           par_nmdcampo = "nranoref".
                                    LEAVE Valida.
                                END.
                        END.
                    ELSE
                        DO:
                            FOR FIRST crabdir WHERE
                                      crabdir.cdcooper = 
                                                       par_cdcooper AND
                                      crabdir.nrdconta = 
                                                       par_nrdconta AND
                                      YEAR(crabdir.dtmvtolt) = 
                                                       par_nranoref
                                      NO-LOCK: END.

                            IF  NOT AVAIL crabdir THEN
                                DO: 
                                    ASSIGN aux_cdcritic = 438
                                           par_nmdcampo = "nranoref".
                                    LEAVE Valida.
                                END.
                        END.
                    
                END. /* tpextrat =  2 ou 6*/
            WHEN 3 THEN
                DO:
                    IF  NOT CAN-DO("1,2",string(par_inselext)) THEN
                        DO:
                            ASSIGN aux_cdcritic = 170
                                   par_nmdcampo = "inselext".
                            LEAVE Valida.
                        END.
                    
                    IF  par_inselext = 1 AND par_nrctremp = 0 THEN
                        DO:
                            ASSIGN aux_cdcritic = 361
                                   par_nmdcampo = "nrctremp".
                            LEAVE Valida.
                        END.

                    IF  par_nrctremp > 0 THEN
                        IF  NOT CAN-FIND(crapepr WHERE
                                         crapepr.cdcooper = par_cdcooper  AND
                                         crapepr.nrdconta = par_nrdconta  AND
                                         crapepr.nrctremp = par_nrctremp) THEN
                            DO:
                                ASSIGN aux_cdcritic = 356
                                       par_nmdcampo = "nrctremp".
                                LEAVE Valida.
                            END.
                END. /* tpextrat = 3 */
            WHEN 4 THEN
                DO:
                    IF  NOT CAN-DO("1,2,3,4",string(par_inselext)) THEN
                        DO:
                            ASSIGN aux_cdcritic = 170
                                   par_nmdcampo = "inselext".
                            LEAVE Valida.
                        END.

                    IF  par_inselext = 1 AND par_nraplica = 0 THEN
                        DO:
                            ASSIGN aux_cdcritic = 425
                                   par_nmdcampo = "nraplica".
                            LEAVE Valida.
                        END.

                        IF  par_nraplica > 0 THEN
                            IF  NOT CAN-FIND
                                   (FIRST craprda WHERE
                                          craprda.cdcooper = par_cdcooper AND
                                          craprda.nrdconta = par_nrdconta AND
                                          craprda.nraplica = par_nraplica) AND
                                NOT CAN-FIND
                                   (FIRST craprac WHERE
                                          craprac.cdcooper = par_cdcooper AND
                                          craprac.nrdconta = par_nrdconta AND
                                          craprac.nraplica = par_nraplica)
                             THEN
                                DO:
                                    ASSIGN aux_cdcritic = 426.
                                           par_nmdcampo = "nraplica".
                                    LEAVE Valida.
                                END.
                END. /* tpextrat = 4 */
            WHEN 5 THEN
                DO:
                    IF  NOT CAN-DO("1,2",string(par_inselext)) THEN
                        DO:
                            ASSIGN aux_cdcritic = 170
                                   par_nmdcampo = "inselext".
                            LEAVE Valida.
                        END.

                    IF  par_inselext = 1 AND par_nraplica = 0 THEN
                        DO:
                            ASSIGN aux_cdcritic = 425.
                                   par_nmdcampo = "nraplica".
                            LEAVE Valida.
                        END.

                    IF  par_nraplica > 0 THEN
                        IF  NOT CAN-FIND
                                  (FIRST crabrpp WHERE
                                         crabrpp.cdcooper = par_cdcooper  AND
                                         crabrpp.nrdconta = par_nrdconta  AND
                                         crabrpp.nrctrrpp = par_nraplica) THEN
                            DO:
                                ASSIGN aux_cdcritic = 426
                                       par_nmdcampo = "nraplica".
                                LEAVE Valida.
                            END.
                END. /* tpextrat = 5 */
            WHEN 8 THEN
                DO:
                    IF  par_cddopcao = "E" THEN
                        DO:
                            IF  par_dtrefere = ? THEN
                                DO:
                                    ASSIGN aux_cdcritic = 13
                                           par_nmdcampo = "dtrefere".
                                    LEAVE Valida.
                                END.
                        END.
                    ELSE
                        DO:
                            IF  par_dtrefere = ? THEN
                                ASSIGN aux_dtrefere = par_dtmvtolt -
                                                      DAY(par_dtmvtolt) + 1.
                        END.


                    IF  YEAR(par_dtrefere)  >  YEAR(par_dtmvtolt) OR
                       (MONTH(par_dtrefere) > MONTH(par_dtmvtolt) AND
                        YEAR(par_dtrefere) >= YEAR(par_dtmvtolt)) THEN
                        DO:
                            ASSIGN aux_cdcritic = 13
                                   par_nmdcampo = "dtrefere".
                            LEAVE Valida.
                        END.
                    
                END. /* tpextrat = 8 */
            WHEN 9 THEN
                DO:
                    IF  par_nranoref <= 1000 THEN
                        DO:
                            ASSIGN aux_dscritic = "560 - Ano errado. Deve " +
                                                  "ser no formato AAAA. " +
                                                  "Ex.: 1997"
                                   par_nmdcampo = "nranoref".
                                   
                            LEAVE Valida.
                        END.
                    IF  par_cddopcao = "I" THEN
                        IF  par_nranoref > YEAR(par_dtmvtolt) THEN
                            DO:
                                ASSIGN aux_dscritic = 
                                                  "O ano para consulta deve " +
                                                  "ser menor ou igual a " +
                                                  STRING(YEAR(par_dtmvtolt)) + "!"
                                       par_nmdcampo = "nranoref".
                                LEAVE Valida.
                            END.
                END. /* tpextrat = 9 */
            WHEN 12 THEN
                DO:
                    IF  par_nranoref <= 2011 THEN
                        DO:
                            ASSIGN aux_dscritic = "O ano para consulta deve " +
                                                  "ser superior a 2011."
                                   par_nmdcampo = "nranoref".
                                   
                            LEAVE Valida.
                        END.
                    IF  par_cddopcao = "I" THEN
                        IF  par_nranoref > YEAR(par_dtmvtolt) THEN
                            DO:
                                ASSIGN aux_dscritic = 
                                                  "O ano para consulta deve " +
                                                  "ser menor ou igual a " +
                                                  STRING(YEAR(par_dtmvtolt)) + "!"
                                       par_nmdcampo = "nranoref".
                                LEAVE Valida.
                            END.
                END. /* tpextrat = 9 */

        END CASE. /* CASE tpextrat: */

        IF  par_flgemiss THEN
            DO:
            
                FOR FIRST tt-impres WHERE
                          tt-impres.nrdconta = par_nrdconta  AND
                          tt-impres.dtrefere = par_dtrefere  AND
                          tt-impres.dtreffim = par_dtreffim  AND
                          tt-impres.nranoref = par_nranoref  AND
                          tt-impres.nrctremp = par_nrctremp  AND
                          tt-impres.nraplica = par_nraplica  AND
                          tt-impres.inrelext = par_inrelext  AND
                          tt-impres.inselext = par_inselext  AND
                          tt-impres.tpextrat = par_tpextrat  AND
                          tt-impres.tpmodelo = par_tpmodelo  AND
                          tt-impres.insitext = 1             AND
                          tt-impres.inisenta = par_flgtarif NO-LOCK: END.

                IF  par_cddopcao = "I" THEN
                    DO:
                        IF  AVAIL tt-impres THEN
                            DO:
                                ASSIGN aux_cdcritic = 265.
                                LEAVE Valida.
                            END.
                    END.
                ELSE
                    IF  NOT AVAIL tt-impres THEN
                        DO:
                            ASSIGN aux_cdcritic = 266.
                            LEAVE Valida.
                        END.

            END. /* IF  par_flgemiss */
        ELSE
            DO:
                FOR FIRST crabext WHERE
                          crabext.cdcooper = par_cdcooper         AND
                          crabext.cdagenci = crabass.cdagenci     AND
                          crabext.nrdconta = par_nrdconta         AND
                          crabext.dtrefere = par_dtrefere         AND
                          crabext.dtreffim = par_dtreffim         AND
                          crabext.nranoref = par_nranoref         AND
                          crabext.nrctremp = par_nrctremp         AND
                          crabext.nraplica = par_nraplica         AND
                          crabext.inselext = (IF  par_tpextrat = 1 THEN 
                                                   par_inrelext
                                              ELSE par_inselext)  AND
                          crabext.tpextrat = par_tpextrat         AND
                          crabext.insitext = 0                    
                          NO-LOCK: END.

                IF  par_cddopcao = "I" THEN
                    DO:
                        IF  AVAIL crabext THEN
                            DO:
                                ASSIGN aux_cdcritic = 265.
                                LEAVE Valida.
                            END.
                    END.
                ELSE
                    IF  NOT AVAIL crabext THEN
                        DO:
                            ASSIGN aux_cdcritic = 266.
                            LEAVE Valida.
                        END.
                
            END. /* ELSE */

        CASE par_tpextrat:
              
            WHEN 1 THEN par_dsextrat = " C/C  ".
            WHEN 2 THEN par_dsextrat = " I.R. ".
            WHEN 3 THEN par_dsextrat = " EMPR ".
            WHEN 4 THEN 
                DO:
                    FOR FIRST crabrda WHERE crabrda.cdcooper = par_cdcooper AND
                                            crabrda.nrdconta = par_nrdconta AND
                                            crabrda.nraplica = par_nraplica
                                            NO-LOCK: END.
                         
                    IF  AVAIL crabrda THEN
                        DO:
                            IF  crabrda.tpaplica > 5 THEN
                                ASSIGN par_dsextrat = " RDC  ".
                            ELSE
                                ASSIGN par_dsextrat = " RDCA ".
                        END.
                    ELSE
                        ASSIGN par_dsextrat = "".
                END.
            WHEN 5   THEN   par_dsextrat = "PROG ". 
            WHEN 6   THEN   par_dsextrat = "IRJr ".
            WHEN 7   THEN   par_dsextrat = "CI   ".
            WHEN 8   THEN   par_dsextrat = "CAP  ".
            WHEN 9   THEN   par_dsextrat = "Tari ".
            WHEN 10  THEN   par_dsextrat = "Apli ".
            WHEN 12  THEN   par_dsextrat = "OpCr ".
  
        END CASE.

        ASSIGN aux_returnvl = "OK".

        LEAVE Valida.

    END. /* Valida */

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE PROCEDURE h-b1wgen0060.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  aux_returnvl = "NOK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT NO,
                            INPUT 1, /** idseqttl **/
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

END PROCEDURE. /* Valida_Opcao */

/* ------------------------------------------------------------------------- */
/*          Grava relat�rios para serem impressos em processo noturno        */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextrat AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtreffim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgtarif AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nranoref AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inselext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemiss AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_inrelext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_inisenta AS INTE                                    NO-UNDO.
    DEF VAR aux_qtopdisp AS INTE                                    NO-UNDO.
    DEF VAR aux_tpservic AS INTE                                    NO-UNDO.
    DEF VAR aux_flservic AS INTEGER                                 NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = ""
           aux_dstransa = "Grava Extrato"
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_idorigem = par_idorigem.
    
    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.

        /* Validar o digito da conta */
        IF  NOT ValidaDigFun ( INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_nrdconta ) THEN
            DO:
               ASSIGN aux_cdcritic = 8.
               LEAVE Grava.
            END.
        
        /* Informacoes sobre o cooperado */
        FOR FIRST crabass FIELDS(tpextcta cdtipcta dtdemiss cdsitdct cdagenci)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK: END.

        IF  NOT AVAILABLE crabass THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE Grava.
            END.
        
        IF  par_cddopcao = "E" THEN
            DO:
                ContadorImpressos: DO aux_contador = 1 TO 10:
                    FIND FIRST crapext WHERE 
                                      crapext.cdcooper = par_cdcooper     AND
                                      crapext.cdagenci = crabass.cdagenci AND
                                      crapext.nrdconta = par_nrdconta     AND
                                      crapext.dtrefere = par_dtrefere     AND
                                      crapext.nranoref = par_nranoref     AND
                                      crapext.nrctremp = par_nrctremp     AND
                                      crapext.nraplica = par_nraplica     AND
                                      crapext.inselext = 
                                                     (IF  par_tpextrat = 1 THEN
                                                           par_inrelext
                                                      ELSE par_inselext) AND
                                      crapext.tpextrat = par_tpextrat    AND
                                      crapext.insitext = 0               AND
                                      crapext.inisenta = (IF par_flgtarif
                                                                 THEN 0 ELSE 1)
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          
                    IF  NOT AVAIL crapext THEN
                        IF  LOCKED crapext THEN
                            DO:
                                IF  aux_contador = 10 THEN
                                    DO:
                                     /* encontra o usuario que esta travando */
                                        ASSIGN aux_dscritic = LockTabela().
                                        LEAVE ContadorImpressos.
                                    END.
                                ELSE 
                                    DO:
                                       PAUSE 1 NO-MESSAGE.
                                       NEXT ContadorImpressos.
                                    END.
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 266.
                                LEAVE ContadorImpressos.
                            END.

                END. /*ContadorImpressos*/

                IF  aux_cdcritic <> 0 THEN
                    LEAVE Grava.
                ELSE
                    DELETE crapext.

            END. /* par_cddopcao = "E" */
        ELSE
        IF  par_cddopcao = "I" THEN
            DO:
                /* Verifica o tipo do servi�o a ser validado no pacote de tarifas, com base na origem, se mensal ou por periodo */
                IF par_dtrefere < ( par_dtmvtolt - 30 ) THEN /* Periodo */
                    DO:
                        IF par_idorigem = 4 THEN 
                          ASSIGN aux_tpservic = 9.
                        ELSE IF   par_idorigem = 1 OR par_idorigem = 5 THEN
                          ASSIGN aux_tpservic = 8.
                    END.
                ELSE /* Mensal */
                    DO:
                        IF par_idorigem = 4 THEN 
                          ASSIGN aux_tpservic = 7.
                        ELSE IF par_idorigem = 1 OR par_idorigem = 5 THEN 
                          ASSIGN aux_tpservic = 6.
                    END.

                /*JMD*/
                /* VERIFICACAO PACOTE DE TARIFAS */
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                RUN STORED-PROCEDURE pc_verifica_pacote_tarifas
                    aux_handproc = PROC-HANDLE NO-ERROR
                                            (INPUT par_cdcooper,  /* C�digo da Cooperativa */
                                             INPUT par_nrdconta,  /* Numero da Conta */
                                             INPUT par_idorigem,  /* Origem */
                                             INPUT aux_tpservic,   /* Tipo de Servico */
                                             OUTPUT 0,            /* Flag de Pacote */
                                             OUTPUT 0,            /* Flag de Sevico */
                                             OUTPUT 0,            /* Quantidade de Operacoes Disponiveis */
                                             OUTPUT 0,            /* C�digo da cr�tica */
                                             OUTPUT "").          /* Descri��o da cr�tica */ 
                
                CLOSE STORED-PROC pc_verifica_pacote_tarifas
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = ""
                       aux_cdcritic = pc_verifica_pacote_tarifas.pr_cdcritic 
                                      WHEN pc_verifica_pacote_tarifas.pr_cdcritic <> ?
                       aux_dscritic = pc_verifica_pacote_tarifas.pr_dscritic
                                      WHEN pc_verifica_pacote_tarifas.pr_dscritic <> ?.
                
                IF aux_cdcritic <> 0   OR
                   aux_dscritic <> ""  THEN
                     DO:
                         RETURN "NOK".
                     END.
                                                           
                ASSIGN /* retorna qtd. de extratos isentos que ainda possui disponivel no pacote de tarifas */
                       aux_qtopdisp = pc_verifica_pacote_tarifas.pr_qtopdisp
                       /* retorna pr_flservic = 1 quando existir o servico "extrato" no pacote */
                       aux_flservic = pc_verifica_pacote_tarifas.pr_flservic.
            
                IF aux_qtopdisp > 0 THEN 
                  ASSIGN aux_inisenta = 1.
                ELSE
                    /* Quando o cooperado NAO possuir o servico "extrato" contemplado no pacote de tarifas,
                    devera validar a qtd. de extratos isentos oferecidos pela cooperativa(parametro). 
                    Caso contrario, o cooperado tera direito apenas a qtd. disponibilizada no pacote */
                    IF   aux_flservic = 0 THEN
                         DO:
                             RUN sistema/generico/procedures/b1wgen0001.p
                                 PERSISTENT SET h-b1wgen0001.
        
                             RUN verifica-tarifacao-extrato 
                                 IN h-b1wgen0001(INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtrefere,
                                                 OUTPUT aux_inisenta,
                                                 OUTPUT TABLE tt-erro).
        
                             DELETE PROCEDURE h-b1wgen0001.
                         END.
                
                IF CAN-FIND(FIRST crapext WHERE
                                  crapext.cdcooper = par_cdcooper         AND
                                  crapext.cdagenci = crabass.cdagenci     AND
                                  crapext.nrdconta = par_nrdconta         AND
                                  crapext.dtrefere = par_dtrefere         AND
                                  crapext.dtreffim = par_dtreffim         AND
                                  crapext.nranoref = par_nranoref         AND
                                  crapext.nrctremp = par_nrctremp         AND
                                  crapext.nraplica = par_nraplica         AND
                                  crapext.inselext = (IF  par_tpextrat = 1 THEN
                                                          par_inrelext
                                                      ELSE par_inselext)  AND
                                  crapext.tpextrat = par_tpextrat         AND
                                  crapext.insitext = 0                    AND
                                  crapext.inisenta = aux_inisenta ) THEN

                    DO:
                        ASSIGN aux_cdcritic = 265.
                        LEAVE Grava.
                    END.

                CREATE crapext.
                ASSIGN crapext.cdagenci = crabass.cdagenci
                       crapext.nrdconta = par_nrdconta
                       crapext.dtrefere = par_dtrefere
                       crapext.dtreffim = par_dtreffim
                       crapext.nranoref = par_nranoref
                       crapext.nrctremp = par_nrctremp
                       crapext.nraplica = par_nraplica
                       crapext.tpextrat = par_tpextrat
                       crapext.inisenta = aux_inisenta
                       crapext.inselext = IF  par_tpextrat = 1 THEN
                                               par_inrelext
                                          ELSE par_inselext
                       crapext.insitext = 0
                       crapext.cdcooper = par_cdcooper.
                
                VALIDATE crapext.

            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Grava.

    END. /* Grava */

    RELEASE crapext.
    
    IF  aux_dscritic <> "" OR 
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
            
            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT IF aux_returnvl = "OK" THEN YES ELSE NO,
                            INPUT 1, /** idseqttl **/
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Dados */

PROCEDURE consulta-imposto-renda:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nranoref AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextrat AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-extrato_ir.
    DEF OUTPUT PARAM TABLE FOR tt-retencao_ir.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgemiss AS LOGI                                    NO-UNDO.
    DEF VAR aux_inrelext AS INTE                                    NO-UNDO.
    DEF VAR aux_dsextrat AS CHAR                                    NO-UNDO.
    DEF        VAR rel_dsagenci     AS CHAR    FORMAT "x(21)"            NO-UNDO.
    DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
    DEF        VAR rel_qtjaicmf     AS DECIMAL                           NO-UNDO.
    DEF        VAR rel_qtjaicm1     AS DECIMAL                           NO-UNDO.
    DEF        VAR rel_vlrenapl     AS DECIMAL                           NO-UNDO.
    DEF        VAR rel_vlrenap1     AS DECIMAL                           NO-UNDO.
    DEF        VAR rel_vldjuros     AS DECIMAL                           NO-UNDO.
    
    DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
    
    DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
    DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                   INIT ["DEP. A VISTA   ","CAPITAL        ",
                                         "EMPRESTIMOS    ","DIGITACAO      ",
                                         "GENERICO       "]              NO-UNDO.
    
    DEF        VAR rel_nmmesano AS CHAR    FORMAT "x(09)"                NO-UNDO.
    DEF        VAR rel_ddmesano AS INT     FORMAT "99"                   NO-UNDO.
    DEF        VAR rel_aamesano AS INT     FORMAT "9999"                 NO-UNDO.
    
    DEF        VAR rel_dscooper AS CHAR                                  NO-UNDO.
    DEF        VAR rel_dsendcop AS CHAR                                  NO-UNDO.
    DEF        VAR rel_dstelcop AS CHAR                                  NO-UNDO.
    
    DEF        VAR mfx_vlsddvem AS DECIMAL                               NO-UNDO.
    DEF        VAR mfx_vlsdccdp AS DECIMAL                               NO-UNDO.
    DEF        VAR mfx_vlsdapli AS DECIMAL                               NO-UNDO.
    DEF        VAR mfx_vlttccap AS DECIMAL                               NO-UNDO.
    DEF        VAR mfx_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
    
    DEF        VAR mfx_vlsddve1 AS DECIMAL                               NO-UNDO.
    DEF        VAR mfx_vlsdccd1 AS DECIMAL                               NO-UNDO.
    DEF        VAR mfx_vlsdapl1 AS DECIMAL                               NO-UNDO.
    DEF        VAR mfx_vlttcca1 AS DECIMAL                               NO-UNDO.
    DEF        VAR mfx_dtmvtol1 AS DATE    FORMAT "99/99/9999"           NO-UNDO.
    DEF        VAR aux_nmmesano AS CHAR    EXTENT 12 INIT
                                           ["JANEIRO  ","FEVEREIRO",
                                            "MARCO    ","ABRIL    ",
                                            "MAIO     ","JUNHO    ",
                                            "JULHO    ","AGOSTO   ",
                                            "SETEMBRO ","OUTUBRO  ",
                                            "NOVEMBRO ","DEZEMBRO "]     NO-UNDO.
    
    DEF        VAR aux_contador AS INT                                   NO-UNDO.
    
    DEF        VAR aux_regexis1 AS LOGICAL                               NO-UNDO.
    DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.
    DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
    
    DEF        VAR aux_cdacesso AS CHAR                                  NO-UNDO.
    DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
    DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
    DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
    
    DEF        VAR aux_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
    
    DEF        VAR aux_vlmoefix AS DECIMAL DECIMALS 8                    NO-UNDO.
    DEF        VAR aux_vlmoefi1 AS DECIMAL DECIMALS 8                    NO-UNDO.
    DEF        VAR aux_nmcidade AS CHAR                                  NO-UNDO.

    DEF        VAR rel_vlrencot AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
    DEF        VAR rel_vlirfcot AS DECIMAL FORMAT "zzzzz,zzz,zz9.99-"    NO-UNDO.
    DEF        VAR ant_vlirfcot AS DECIMAL FORMAT "zzzzz,zzz,zz9.99-"    NO-UNDO.
    DEF        VAR rel_vlrendim AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
    DEF        VAR rel_vlcpmfpg AS DECIMAL FORMAT "zzzzz,zzz,zz9.99-"    NO-UNDO.
    DEF        VAR rel_vldoirrf AS DECIMAL FORMAT "zzzzz,zzz,zz9.99-"    NO-UNDO.
    
    DEF        VAR rel_dscpmfpg AS CHAR    FORMAT "x(16)"                NO-UNDO.
    
    DEF        VAR rel_nrcpfcgc AS CHAR    FORMAT "x(18)"                NO-UNDO.
    
    DEF        VAR rel_aarefere AS INT     FORMAT "9999"                 NO-UNDO.
    
    DEF        VAR rel_nrdocnpj AS CHAR                                  NO-UNDO.
    
    DEF        VAR rel_nmmesref AS CHAR    FORMAT "x(3)" EXTENT 12
                   INIT ["JAN","FEV","MAR","ABR","MAI","JUN",
                         "JUL","AGO","SET","OUT","NOV","DEZ"]           NO-UNDO.
               
    DEF        VAR ant_dtrefere AS DATE    FORMAT "99/99/9999" EXTENT 3  NO-UNDO.
    DEF        VAR sol_dtrefere AS DATE    FORMAT "99/99/9999" EXTENT 3  NO-UNDO.
    
    DEF        VAR ant_vlsdapli AS DECIMAL FORMAT "z,zzz,zzz,zz9.99-"    NO-UNDO.
    DEF        VAR sol_vlsdapli AS DECIMAL FORMAT "z,zzz,zzz,zz9.99-"    NO-UNDO.
    
    DEF        VAR ant_vlpoupan AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
    DEF        VAR sol_vlpoupan AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
    
    DEF        VAR ant_vlfundos AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
    DEF        VAR sol_vlfundos AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
    
    DEF        VAR ant_vlrenfix AS DECIMAL                               NO-UNDO.
    DEF        VAR sol_vlrenfix AS DECIMAL                               NO-UNDO.
    
    DEF        VAR ant_vlsdccdp AS DECIMAL FORMAT "zzzzz,zzz,zz9.99-"    NO-UNDO.
    DEF        VAR sol_vlsdccdp AS DECIMAL FORMAT "zzzzz,zzz,zz9.99-"    NO-UNDO.
    
    DEF        VAR ant_vlsddvem AS DECIMAL FORMAT "zzzzz,zzz,zz9.99-"    NO-UNDO.
    DEF        VAR sol_vlsddvem AS DECIMAL FORMAT "zzzzz,zzz,zz9.99-"    NO-UNDO.
    
    DEF        VAR ant_vlttccap AS DECIMAL FORMAT "zzzzz,zzz,zz9.99-"    NO-UNDO.
    DEF        VAR sol_vlttccap AS DECIMAL FORMAT "zzzzz,zzz,zz9.99-"    NO-UNDO.
    
    DEF        VAR ren_vlpoupan AS DECIMAL FORMAT "zzzzz,zz9.99-"        NO-UNDO.
    DEF        VAR ren_vlfundos AS DECIMAL FORMAT "zzzzz,zz9.99-"        NO-UNDO.
    
    DEF        VAR tot_vlrendim AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
    
    DEF        VAR lit_dsanoant AS CHAR    FORMAT "x(8)" EXTENT 3        NO-UNDO.
    
    DEF        VAR aux_flganter AS LOGICAL                               NO-UNDO.
    
    DEF        VAR aux_dtemissa AS DATE                                  NO-UNDO.
    
    DEF        VAR aux_vlrentot AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
    DEF        VAR aux_vlirfont AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
    DEF        VAR aux_nmmesref AS CHAR    FORMAT "x(3)"                 NO-UNDO.
    DEF        VAR aux_nrmesref AS INT                                   NO-UNDO.
    
    DEF        VAR aux_cdretenc AS INTE    FORMAT "zzz9"                 NO-UNDO.
    DEF        VAR aux_dsretenc AS CHAR    FORMAT "x(41)"                NO-UNDO.
    DEF        VAR aux_vlrdrtrt AS DECI                                  NO-UNDO.
    DEF        VAR aux_vlrrtirf AS DECI                                  NO-UNDO.
    DEF        VAR aux_flghames as LOGI                                  NO-UNDO.

    DEF        VAR aux_nrdconta AS CHAR   FORMAT "x(20)"                 NO-UNDO.
    DEF        VAR aux_cdagectl AS CHAR   FORMAT "x(15)"                 NO-UNDO.

    DEF        VAR aux_dsre3426 AS CHAR                                  NO-UNDO.
    DEF        VAR aux_dsre5706 AS CHAR                                  NO-UNDO.
    
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabext FOR crapext.
    
    
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-extrato_ir.
        EMPTY TEMP-TABLE tt-retencao_ir.
        EMPTY TEMP-TABLE tt-erro.

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapcop THEN
             DO:
                 ASSIGN aux_cdcritic = 651.
                 LEAVE Busca.
             END.

         FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                            crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE crapass THEN
              DO:
                 ASSIGN aux_cdcritic = 251.
                 LEAVE Busca.
              END.

        FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                   crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.

        IF  par_nranoref > 1994 THEN
            DO:
                
                ASSIGN ant_vlsdapli = 0
                       ant_vlsdccdp = 0
                       ant_vlsddvem = 0
                       ant_vlttccap = 0
                
                       sol_vlsdapli = 0
                       sol_vlsdccdp = 0
                       sol_vlsddvem = 0
                       sol_vlttccap = 0
                
                       rel_vlrendim = 0
                       rel_vldjuros = 0
                
                       rel_aarefere = par_nranoref
                
                       
                       lit_dsanoant = "SALDO EM"
                       rel_dscpmfpg = "CPMF PAGO NO ANO"
                       
                       aux_regexis1 = FALSE.
                
                IF   crapass.inpessoa = 1 THEN
                     ASSIGN rel_nrcpfcgc = 
                                     STRING(crapass.nrcpfcgc,"99999999999")
                            rel_nrcpfcgc = 
                                     STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx    ").
                ELSE
                     ASSIGN rel_nrcpfcgc = 
                                     STRING(crapass.nrcpfcgc,"99999999999999")
                            rel_nrcpfcgc = 
                                     STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

                /* se for extrato para pessoa fisica */
                IF  par_tpextrat = 2 THEN
                    DO:
                        FIND FIRST crapdir WHERE 
                            crapdir.cdcooper = par_cdcooper       AND
                            crapdir.nrdconta = crapass.nrdconta   AND
                            YEAR(crapdir.dtmvtolt) = par_nranoref
                            USE-INDEX crapdir1 NO-LOCK NO-ERROR.

                        IF  NOT AVAILABLE crapdir THEN
                            DO:
                                ASSIGN aux_dscritic = "Conta/dv: "            +
                                                      STRING(par_nrdconta)    +
                                                      " - Nao ha dados para " +
                                                      "imposto de renda de "  +
                                                      STRING(par_nranoref) + ".".
                                LEAVE Busca.
                            END.

                         ASSIGN sol_dtrefere = DATE(12,31,YEAR(crapdir.dtmvtolt))
                                sol_vlsdapli = crapdir.vlsdapli + 
                                               crapdir.vlsdrdpp
                                sol_vlsdccdp = crapdir.vlsdccdp
                                sol_vlsddvem = crapdir.vlsddvem
                                sol_vlttccap = crapdir.vlttccap
                                aux_cdacesso = "IRENDA" + 
                                         STRING(YEAR(crapdir.dtmvtolt),"9999")
                                rel_vlrencot = crapdir.vlrencot
                                rel_vlirfcot = crapdir.vlirfcot.

                        FIND FIRST crapsli WHERE 
                                        crapsli.cdcooper = par_cdcooper     AND
                                        crapsli.nrdconta = crapass.nrdconta AND
                                        crapsli.dtrefere = 
                                                       DATE(12,31,par_nranoref)
                                        NO-LOCK NO-ERROR.

                        IF   AVAILABLE crapsli THEN
                              ASSIGN sol_vlsdccdp = 
                                     sol_vlsdccdp + crapsli.vlsddisp.
                         ELSE
                              .

                        FIND craptab WHERE 
                             craptab.cdcooper = par_cdcooper AND
                             craptab.nmsistem = "CRED"       AND
                             craptab.tptabela = "GENERI"     AND
                             craptab.cdempres = 0            AND
                             craptab.cdacesso = aux_cdacesso AND
                             craptab.tpregist = 1            NO-LOCK NO-ERROR.

                        IF  NOT AVAILABLE craptab THEN
                            DO:
                                ASSIGN aux_cdcritic = 457.
                                LEAVE Busca.
                            END.

                        ASSIGN aux_vlmoefix = DECIMAL(STRING(SUBSTRING(craptab.dstextab,22,15),
                                               "999999,99999999"))

                rel_vlrendim = crapdir.vlrenrda[01] + crapdir.vlrenrda[02] +
                               crapdir.vlrenrda[03] + crapdir.vlrenrda[04] +
                               crapdir.vlrenrda[05] + crapdir.vlrenrda[06] +
                               crapdir.vlrenrda[07] + crapdir.vlrenrda[08] +
                               crapdir.vlrenrda[09] + crapdir.vlrenrda[10] +
                               crapdir.vlrenrda[11] + crapdir.vlrenrda[12] +
                              
                               crapdir.vlrenrdc[01] + crapdir.vlrenrdc[02] +
                               crapdir.vlrenrdc[03] + crapdir.vlrenrdc[04] +
                               crapdir.vlrenrdc[05] + crapdir.vlrenrdc[06] +
                               crapdir.vlrenrdc[07] + crapdir.vlrenrdc[08] +
                               crapdir.vlrenrdc[09] + crapdir.vlrenrdc[10] +
                               crapdir.vlrenrdc[11] + crapdir.vlrenrdc[12] +
                               
                               crapdir.vlrenrpp + crapdir.vlabonpp + crapdir.vlabonrd +
                               crapdir.vlabiopp + crapdir.vlabiord - 
                               
                               crapdir.vlirabap[1]  - crapdir.vlirabap[2] -
                               crapdir.vlirabap[3]  - crapdir.vlirabap[4] -
                               crapdir.vlirabap[5]  - crapdir.vlirabap[6] -
                               crapdir.vlirabap[7]  - crapdir.vlirabap[8] -
                               crapdir.vlirabap[9]  - crapdir.vlirabap[10] -
                               crapdir.vlirabap[11] - crapdir.vlirabap[12] -
                               
                               crapdir.vlirrdca[1]  - crapdir.vlirrdca[2] -
                               crapdir.vlirrdca[3]  - crapdir.vlirrdca[4] -
                               crapdir.vlirrdca[5]  - crapdir.vlirrdca[6] -
                               crapdir.vlirrdca[7]  - crapdir.vlirrdca[8] -
                               crapdir.vlirrdca[9]  - crapdir.vlirrdca[10] -
                               crapdir.vlirrdca[11] - crapdir.vlirrdca[12] -
                               
                               crapdir.vlirfrdc[01] - crapdir.vlirfrdc[02] -
                               crapdir.vlirfrdc[03] - crapdir.vlirfrdc[04] -
                               crapdir.vlirfrdc[05] - crapdir.vlirfrdc[06] -
                               crapdir.vlirfrdc[07] - crapdir.vlirfrdc[08] -
                               crapdir.vlirfrdc[09] - crapdir.vlirfrdc[10] -
                               crapdir.vlirfrdc[11] - crapdir.vlirfrdc[12] -
                               
                               crapdir.vlrirrpp[1]  - crapdir.vlrirrpp[2] -
                               crapdir.vlrirrpp[3]  - crapdir.vlrirrpp[4] -
                               crapdir.vlrirrpp[5]  - crapdir.vlrirrpp[6] -
                               crapdir.vlrirrpp[7]  - crapdir.vlrirrpp[8] -
                               crapdir.vlrirrpp[9]  - crapdir.vlrirrpp[10] -
                               crapdir.vlrirrpp[11] - crapdir.vlrirrpp[12] -
                            
                               crapdir.vlirajus[1]  - crapdir.vlirajus[2] -
                               crapdir.vlirajus[3]  - crapdir.vlirajus[4] -
                               crapdir.vlirajus[5]  - crapdir.vlirajus[6] -
                               crapdir.vlirajus[7]  - crapdir.vlirajus[8] -
                               crapdir.vlirajus[9]  - crapdir.vlirajus[10] -
                               crapdir.vlirajus[11] - crapdir.vlirajus[12]
                  
                         rel_vldoirrf = crapdir.vlirabap[1]  + crapdir.vlirabap[2] +
                                  crapdir.vlirabap[3]  + crapdir.vlirabap[4] +
                                  crapdir.vlirabap[5]  + crapdir.vlirabap[6] +
                                  crapdir.vlirabap[7]  + crapdir.vlirabap[8] +
                                  crapdir.vlirabap[9]  + crapdir.vlirabap[10] +
                                  crapdir.vlirabap[11] + crapdir.vlirabap[12] +
                               
                                  crapdir.vlirrdca[1]  + crapdir.vlirrdca[2] +
                                  crapdir.vlirrdca[3]  + crapdir.vlirrdca[4] +
                                  crapdir.vlirrdca[5]  + crapdir.vlirrdca[6] +
                                  crapdir.vlirrdca[7]  + crapdir.vlirrdca[8] +
                                  crapdir.vlirrdca[9]  + crapdir.vlirrdca[10] +
                                  crapdir.vlirrdca[11] + crapdir.vlirrdca[12] +
                                  
                                  crapdir.vlirfrdc[01] + crapdir.vlirfrdc[02] +
                                  crapdir.vlirfrdc[03] + crapdir.vlirfrdc[04] +
                                  crapdir.vlirfrdc[05] + crapdir.vlirfrdc[06] +
                                  crapdir.vlirfrdc[07] + crapdir.vlirfrdc[08] +
                                  crapdir.vlirfrdc[09] + crapdir.vlirfrdc[10] +
                                  crapdir.vlirfrdc[11] + crapdir.vlirfrdc[12] +
                                  
                                  crapdir.vlrirrpp[1]  + crapdir.vlrirrpp[2] +
                                  crapdir.vlrirrpp[3]  + crapdir.vlrirrpp[4] +
                                  crapdir.vlrirrpp[5]  + crapdir.vlrirrpp[6] +
                                  crapdir.vlrirrpp[7]  + crapdir.vlrirrpp[8] +
                                  crapdir.vlrirrpp[9]  + crapdir.vlrirrpp[10] +
                                  crapdir.vlrirrpp[11] + crapdir.vlrirrpp[12] +
                                  
                                  crapdir.vlirajus[1]  + crapdir.vlirajus[2] +
                                  crapdir.vlirajus[3]  + crapdir.vlirajus[4] +
                                  crapdir.vlirajus[5]  + crapdir.vlirajus[6] +
                                  crapdir.vlirajus[7]  + crapdir.vlirajus[8] +
                                  crapdir.vlirajus[9]  + crapdir.vlirajus[10] +
                                  crapdir.vlirajus[11] + crapdir.vlirajus[12]
                  
                         rel_vldjuros = ROUND(crapdir.qtjaicmf * aux_vlmoefix,2)
                         rel_vlcpmfpg = crapdir.vlcpmfpg
                         
                         tot_vlrendim = rel_vlrendim
                  
                         aux_regexist = TRUE.

                        IF  crapcop.cdcooper = 6 THEN
                             ASSIGN rel_vlcpmfpg = 0
                                    rel_dscpmfpg = "".

                        FOR EACH craplct WHERE 
                                 craplct.cdcooper = par_cdcooper       AND
                                 craplct.nrdconta = crapdir.nrdconta   AND
                                 craplct.cdhistor = 421 NO-LOCK:
                                                
                             ASSIGN rel_vldjuros = 
                                       rel_vldjuros - ROUND(craplct.qtlanmfx *
                                                               aux_vlmoefix,2).
                             
                        END.  /*  Fim do FOR EACH -- craplct  */

                        IF  rel_vldjuros < 0   THEN
                            rel_vldjuros = 0.

                        IF  aux_regexist THEN
                            DO:
                                FIND FIRST crapdir WHERE 
                                           crapdir.cdcooper = par_cdcooper      AND
                                           crapdir.nrdconta = crapass.nrdconta  AND
                                           YEAR(crapdir.dtmvtolt) = par_nranoref - 1
                                           USE-INDEX crapdir1 NO-LOCK NO-ERROR.

                                IF  AVAILABLE crapdir THEN
                                    ASSIGN ant_dtrefere = crapdir.dtmvtolt
                                           ant_vlsdapli = crapdir.vlsdapli + 
                                                          crapdir.vlsdrdpp
                                           ant_vlsdccdp = crapdir.vlsdccdp
                                           ant_vlsddvem = crapdir.vlsddvem
                                           ant_vlttccap = crapdir.vlttccap
                                           ant_vlirfcot = crapdir.vlirfcot
                                           aux_flganter = TRUE.
                                ELSE
                                    ASSIGN aux_flganter = FALSE.

                                FIND FIRST crapsli WHERE
                                           crapsli.cdcooper = par_cdcooper     AND
                                           crapsli.nrdconta = crapass.nrdconta AND
                                           crapsli.dtrefere = DATE(12,31,par_nranoref - 1)
                                           NO-LOCK NO-ERROR.

                                IF  AVAILABLE crapsli THEN
                                    ASSIGN ant_vlsdccdp = ant_vlsdccdp + 
                                                          crapsli.vlsddisp.
                                ELSE
                                    .
                                    
                            END.

                        IF  rel_vlrendim <= 0   THEN
                             ASSIGN rel_vlrendim = 0
                                    rel_vldoirrf = 0.

                        CREATE tt-extrato_ir.
                        ASSIGN tt-extrato_ir.nrcpfcgc = rel_nrcpfcgc
                               tt-extrato_ir.nrdconta = crapass.nrdconta
                               tt-extrato_ir.nmprimtl = crapass.nmprimtl
                               tt-extrato_ir.cdagenci = crapass.cdagenci
                               tt-extrato_ir.nmsegntl = crapass.nmsegntl
                               tt-extrato_ir.dsanoant = lit_dsanoant[1]
                               tt-extrato_ir.dtrefer1 = ant_dtrefere[1]
                               tt-extrato_ir.vlsdapl1 = ant_vlsdapli
                               tt-extrato_ir.vlsdccd1 = ant_vlsdccdp
                               tt-extrato_ir.vlsddve1 = ant_vlsddvem
                               tt-extrato_ir.vlttcca1 = ant_vlttccap
                               tt-extrato_ir.dtrefer2 = sol_dtrefere[1]
                               tt-extrato_ir.vlsdapl2 = sol_vlsdapli
                               tt-extrato_ir.vlsdccd2 = sol_vlsdccdp
                               tt-extrato_ir.vlsddve2 = sol_vlsddvem
                               tt-extrato_ir.vlttcca2 = sol_vlttccap
                               tt-extrato_ir.vlrendim = rel_vlrendim
                               tt-extrato_ir.nmextcop = crapcop.nmextcop
                               tt-extrato_ir.nrdocnpj = rel_nrdocnpj
                               tt-extrato_ir.dsendcop = rel_dsendcop
                               tt-extrato_ir.dscpmfpg = rel_dscpmfpg
                               tt-extrato_ir.vlcpmfpg = rel_vlcpmfpg
                               tt-extrato_ir.vldoirrf = rel_vldoirrf
                               tt-extrato_ir.cdagectl = crapcop.cdagectl
                               tt-extrato_ir.flganter = aux_flganter
                               tt-extrato_ir.vlrencot = rel_vlrencot
                               tt-extrato_ir.vlirfcot = rel_vlirfcot
                               tt-extrato_ir.anirfcot = ant_vlirfcot.
                        
                    END. /* IF  par_tpextrat = 2 */
                ELSE    
                    DO: 
                        CREATE tt-extrato_ir.
                        ASSIGN tt-extrato_ir.nmextcop = crapcop.nmextcop
                               tt-extrato_ir.nrdocnpj = rel_nrdocnpj
                               tt-extrato_ir.dsendcop = rel_dsendcop
                               tt-extrato_ir.nrcpfcgc = rel_nrcpfcgc
                               tt-extrato_ir.nmprimtl = crapass.nmprimtl
                               tt-extrato_ir.cdagenci = crapass.cdagenci
                               tt-extrato_ir.nrdconta = crapass.nrdconta
                               tt-extrato_ir.nmsegntl = crapass.nmsegntl.
                        
                        /* pegar descricao do codigo retencao 3426 */
                        FIND FIRST gnrdirf WHERE gnrdirf.cdretenc = 3426 
                        NO-ERROR.
                        
                        IF  NOT AVAILABLE gnrdirf THEN
                            DO:
                               ASSIGN aux_dscritic = "Problema na consulta da " +
                                                     "descricao de retencao. "  +
                                                     "Comunique seu PA.".
                               LEAVE Busca.
                            END.
                        ASSIGN aux_dsre3426 = gnrdirf.dsretenc.
                    
                        /* pegar descricao do codigo retencao 5706 */
                        FIND FIRST gnrdirf WHERE gnrdirf.cdretenc = 5706 
                        NO-ERROR.
                        
                        IF  NOT AVAILABLE gnrdirf THEN
                            DO:
                               ASSIGN aux_dscritic = "Problema na consulta da " +
                                                     "descricao de retencao. "  +
                                                     "Comunique seu PA.".
                               LEAVE Busca.
                            END.
                        ASSIGN aux_dsre5706 = gnrdirf.dsretenc.
                        
                        ASSIGN ant_dtrefere = DATE(12,31,(par_nranoref - 1))
                               sol_dtrefere = DATE(12,31,par_nranoref).
                               
                        
                        /* se for ano vigente */
                        IF  par_nranoref = YEAR(par_dtmvtolt)  THEN
                            DO:
                                ASSIGN aux_nrmesref = 
                                       MONTH(par_dtmvtolt - DAY(par_dtmvtolt)).

                               FIND crapcot WHERE crapcot.cdcooper = 
                                                  par_cdcooper 
                                                  AND
                                                  crapcot.nrdconta = 
                                                  crapass.nrdconta
                                                  NO-LOCK NO-ERROR.
                
                               IF NOT AVAILABLE crapcot THEN
                                  DO:
                                     ASSIGN aux_dscritic = 
                                            "Conta/dv: " + STRING(par_nrdconta) +
                                            "- Nao ha dados para imposto "      +
                                            "de renda de " + STRING(par_nranoref).
                
                                     LEAVE Busca.
                                  END.

                               DO aux_contador = 1 TO aux_nrmesref:

                                  ASSIGN aux_nmmesref = 
                                         rel_nmmesref[aux_contador]
                                         aux_cdretenc = 3426
                                         aux_dsretenc = aux_dsre3426
                                         aux_vlrentot = 
                                         crapcot.vlrentot[aux_contador]
                                         aux_vlirfont = 
                                         crapcot.vlirrdca[aux_contador] +
                                         crapcot.vlrirrpp[aux_contador] +
                                         crapcot.vlirabap[aux_contador] +
                                         crapcot.vlirajus[aux_contador] +
                                         crapcot.vlirfrdc[aux_contador].

                                  IF aux_vlirfont > 0 THEN
                                     DO:
                                        CREATE tt-retencao_ir.
                                          ASSIGN tt-retencao_ir.nmmesref =
                                                 aux_nmmesref
                                                 tt-retencao_ir.cdretenc =
                                                 STRING(aux_cdretenc)
                                                 tt-retencao_ir.dsretenc = 
                                                 aux_dsretenc
                                                 tt-retencao_ir.vlrentot = 
                                                 aux_vlrentot.
                                        
                                          IF par_nranoref >= 2004   THEN
                                             ASSIGN tt-retencao_ir.vlirfont =
                                                    aux_vlirfont.
                                     END.
                
                                  ASSIGN aux_vlirfont = 0.

                                  FOR EACH craplct WHERE
                                      craplct.cdcooper = par_cdcooper        AND
                                      craplct.nrdconta = crapass.nrdconta    AND
                                      YEAR(craplct.dtmvtolt)  = par_nranoref AND
                                      MONTH(craplct.dtmvtolt) = aux_contador AND
                                      CAN-DO("0922,0926",
                                             STRING(craplct.cdhistor,"9999"))
                                      NO-LOCK:
            
                                      IF  craplct.cdhistor = 926 THEN
                                          ASSIGN aux_vlrentot = craplct.vllanmto.
                                      ELSE
                                          ASSIGN aux_vlirfont = craplct.vllanmto.
            
                                  END. /* FOR EACH */

                                  IF aux_vlirfont > 0 THEN
                                     DO:
                                        ASSIGN aux_cdretenc = 5706
                                               aux_dsretenc = aux_dsre5706.
                
                                        CREATE tt-retencao_ir.
                                          ASSIGN tt-retencao_ir.nmmesref =
                                                 aux_nmmesref
                                                 tt-retencao_ir.cdretenc =
                                                 STRING(aux_cdretenc)
                                                 tt-retencao_ir.dsretenc = 
                                                 aux_dsretenc
                                                 tt-retencao_ir.vlrentot = 
                                                 aux_vlrentot.
                                        
                                          IF par_nranoref >= 2004   THEN
                                             ASSIGN tt-retencao_ir.vlirfont =
                                                    aux_vlirfont.
                
                                     END.

                               END. /* FIM DO TO */

                            END. /* se for ano vigente */
                        ELSE
                            DO: /* senao for ano vigente */
                                ASSIGN aux_nrmesref = 12.

                                FIND FIRST crapdir WHERE
                                     crapdir.cdcooper = par_cdcooper AND
                                     crapdir.nrdconta = crapass.nrdconta  AND
                                     YEAR(crapdir.dtmvtolt) = par_nranoref
                                     USE-INDEX crapdir1 NO-LOCK NO-ERROR.
                    
                                IF NOT AVAILABLE crapdir THEN
                                   DO:
                                       ASSIGN aux_dscritic = 
                                           "Conta/dv: " + STRING(par_nrdconta) +
                                           " - Nao ha dados para imposto de "  +
                                           "renda de " + STRING(par_nranoref).
                                       LEAVE Busca.   
                                    
                                   END.

                                rel_vlrendim = 
                                   crapdir.vlrenrda[01] + crapdir.vlrenrda[02] +
                                   crapdir.vlrenrda[03] + crapdir.vlrenrda[04] +
                                   crapdir.vlrenrda[05] + crapdir.vlrenrda[06] +
                                   crapdir.vlrenrda[07] + crapdir.vlrenrda[08] +
                                   crapdir.vlrenrda[09] + crapdir.vlrenrda[10] +
                                   crapdir.vlrenrda[11] + crapdir.vlrenrda[12] +
                              
                                   crapdir.vlrenrdc[01] + crapdir.vlrenrdc[02] +
                                   crapdir.vlrenrdc[03] + crapdir.vlrenrdc[04] +
                                   crapdir.vlrenrdc[05] + crapdir.vlrenrdc[06] +
                                   crapdir.vlrenrdc[07] + crapdir.vlrenrdc[08] +
                                   crapdir.vlrenrdc[09] + crapdir.vlrenrdc[10] +
                                   crapdir.vlrenrdc[11] + crapdir.vlrenrdc[12] +
                                   
                                   crapdir.vlrenrpp + crapdir.vlabonpp + crapdir.vlabonrd +
                                   crapdir.vlabiopp + crapdir.vlabiord - 
                                   
                                   crapdir.vlirabap[1]  - crapdir.vlirabap[2] -
                                   crapdir.vlirabap[3]  - crapdir.vlirabap[4] -
                                   crapdir.vlirabap[5]  - crapdir.vlirabap[6] -
                                   crapdir.vlirabap[7]  - crapdir.vlirabap[8] -
                                   crapdir.vlirabap[9]  - crapdir.vlirabap[10] -
                                   crapdir.vlirabap[11] - crapdir.vlirabap[12] -
                                   
                                   crapdir.vlirrdca[1]  - crapdir.vlirrdca[2] -
                                   crapdir.vlirrdca[3]  - crapdir.vlirrdca[4] -
                                   crapdir.vlirrdca[5]  - crapdir.vlirrdca[6] -
                                   crapdir.vlirrdca[7]  - crapdir.vlirrdca[8] -
                                   crapdir.vlirrdca[9]  - crapdir.vlirrdca[10] -
                                   crapdir.vlirrdca[11] - crapdir.vlirrdca[12] -
                                   
                                   crapdir.vlirfrdc[01] - crapdir.vlirfrdc[02] -
                                   crapdir.vlirfrdc[03] - crapdir.vlirfrdc[04] -
                                   crapdir.vlirfrdc[05] - crapdir.vlirfrdc[06] -
                                   crapdir.vlirfrdc[07] - crapdir.vlirfrdc[08] -
                                   crapdir.vlirfrdc[09] - crapdir.vlirfrdc[10] -
                                   crapdir.vlirfrdc[11] - crapdir.vlirfrdc[12] -
                                   
                                   crapdir.vlrirrpp[1]  - crapdir.vlrirrpp[2] -
                                   crapdir.vlrirrpp[3]  - crapdir.vlrirrpp[4] -
                                   crapdir.vlrirrpp[5]  - crapdir.vlrirrpp[6] -
                                   crapdir.vlrirrpp[7]  - crapdir.vlrirrpp[8] -
                                   crapdir.vlrirrpp[9]  - crapdir.vlrirrpp[10] -
                                   crapdir.vlrirrpp[11] - crapdir.vlrirrpp[12] -
                            
                                   crapdir.vlirajus[1]  - crapdir.vlirajus[2] -
                                   crapdir.vlirajus[3]  - crapdir.vlirajus[4] -
                                   crapdir.vlirajus[5]  - crapdir.vlirajus[6] -
                                   crapdir.vlirajus[7]  - crapdir.vlirajus[8] -
                                   crapdir.vlirajus[9]  - crapdir.vlirajus[10] -
                                   crapdir.vlirajus[11] - crapdir.vlirajus[12].
    
                                DO  aux_contador = 1 TO aux_nrmesref:

                                    ASSIGN aux_nmmesref = 
                                           rel_nmmesref[aux_contador]
                                           aux_cdretenc = 3426
                                           aux_dsretenc = aux_dsre3426
                                           aux_vlrentot = 
                                           crapdir.vlrentot[aux_contador]
                                           aux_vlirfont = 
                                           crapdir.vlirrdca[aux_contador] +
                                           crapdir.vlrirrpp[aux_contador] +
                                           crapdir.vlirabap[aux_contador] +
                                           crapdir.vlirajus[aux_contador] +
                                           crapdir.vlirfrdc[aux_contador].

                                    IF aux_vlirfont > 0 THEN
                                       DO:
                                          CREATE tt-retencao_ir.
                                          ASSIGN tt-retencao_ir.nmmesref =
                                                 aux_nmmesref
                                                 tt-retencao_ir.cdretenc =
                                                 STRING(aux_cdretenc)
                                                 tt-retencao_ir.dsretenc = 
                                                 aux_dsretenc
                                                 tt-retencao_ir.vlrentot = 
                                                 aux_vlrentot.
                                        
                                          IF par_nranoref >= 2004   THEN
                                             ASSIGN tt-retencao_ir.vlirfont =
                                                    aux_vlirfont.
                                        
                                       END.

                                    ASSIGN aux_vlirfont = 0.

                                    FOR EACH craplct WHERE
                                        craplct.cdcooper = par_cdcooper 
                                        AND
                                        craplct.nrdconta = crapass.nrdconta 
                                        AND
                                        YEAR(craplct.dtmvtolt)  = par_nranoref 
                                        AND
                                        MONTH(craplct.dtmvtolt) = aux_contador
                                        AND
                                        CAN-DO("0922,0926",
                                               STRING(craplct.cdhistor,"9999"))
                                        NO-LOCK:
                
                                        IF  craplct.cdhistor = 926 THEN
                                            ASSIGN aux_vlrentot = 
                                                   craplct.vllanmto.
                                        ELSE
                                            ASSIGN aux_vlirfont = 
                                                   craplct.vllanmto.
                
                                    END. /* FOR EACH */

                                    IF aux_vlirfont > 0 THEN
                                       DO:
                                          ASSIGN aux_cdretenc = 5706
                                                 aux_dsretenc = aux_dsre5706.
                
                                          CREATE tt-retencao_ir.
                                          ASSIGN tt-retencao_ir.nmmesref =
                                                 aux_nmmesref
                                                 tt-retencao_ir.cdretenc =
                                                 STRING(aux_cdretenc)
                                                 tt-retencao_ir.dsretenc = 
                                                 aux_dsretenc
                                                 tt-retencao_ir.vlrentot = 
                                                 aux_vlrentot.
                                        
                                          IF par_nranoref >= 2004   THEN
                                             ASSIGN tt-retencao_ir.vlirfont =
                                                    aux_vlirfont.
                                       END.

                                END. /* DO TO */

                                ASSIGN sol_dtrefere = 
                                       DATE(12,31,YEAR(crapdir.dtmvtolt))
                                       sol_vlsdccdp = crapdir.vlsdccdp
                                       sol_vlsddvem = crapdir.vlsddvem
                                       sol_vlttccap = crapdir.vlttccap
                                       sol_vlsdapli = crapdir.vlsdapli + 
                                                      crapdir.vlsdrdpp
                                       aux_cdacesso = "IRENDA" +
                                       STRING(YEAR(crapdir.dtmvtolt),"9999")
                                       rel_vlrencot = crapdir.vlrencot
                                       rel_vlirfcot = crapdir.vlirfcot.
                
                                FIND FIRST crapsli WHERE
                                     crapsli.cdcooper = par_cdcooper     AND
                                     crapsli.nrdconta = crapass.nrdconta AND
                                     crapsli.dtrefere = DATE(12,31,par_nranoref)
                                     NO-LOCK NO-ERROR.

                                IF   AVAILABLE crapsli THEN
                                     ASSIGN sol_vlsdccdp = 
                                     sol_vlsdccdp + crapsli.vlsddisp.
                              
                                ASSIGN tt-extrato_ir.vlsdccd2 = sol_vlsdccdp
                                       tt-extrato_ir.vlttcca2 = sol_vlttccap
                                       tt-extrato_ir.vlsddve2 = sol_vlsddvem
                                       tt-extrato_ir.vlsdapl2 = sol_vlsdapli
                                       tt-extrato_ir.vlrencot = rel_vlrencot
                                       tt-extrato_ir.vlirfcot = rel_vlirfcot.

                            END. /* else senao for ano vigente */
                        
                        ASSIGN tt-extrato_ir.dtrefer2 = sol_dtrefere[1]
                               tt-extrato_ir.dtrefer1 = ant_dtrefere[1]
                               tt-extrato_ir.dsanoant = lit_dsanoant[1]
                               tt-extrato_ir.vlrendim = rel_vlrendim.


                        FIND FIRST crapdir WHERE
                                   crapdir.cdcooper = par_cdcooper      AND
                                   crapdir.nrdconta = crapass.nrdconta  AND
                                   YEAR(crapdir.dtmvtolt) = (par_nranoref - 1)
                                   USE-INDEX crapdir1 NO-LOCK NO-ERROR.
                        
                        IF AVAILABLE crapdir THEN
                           DO:
                              ASSIGN ant_vlsdccdp = crapdir.vlsdccdp
                                     ant_vlsddvem = crapdir.vlsddvem
                                     ant_vlttccap = crapdir.vlttccap
                                     ant_vlsdapli = crapdir.vlsdapli + 
                                                    crapdir.vlsdrdpp
                                     aux_flganter = TRUE.
                           END.

                        FIND FIRST crapsli WHERE
                             crapsli.cdcooper = par_cdcooper     AND
                             crapsli.nrdconta = crapass.nrdconta AND
                             crapsli.dtrefere = DATE(12,31,(par_nranoref - 1))
                             NO-LOCK NO-ERROR.
                
                        IF  AVAILABLE crapsli THEN
                            ASSIGN ant_vlsdccdp = 
                                   ant_vlsdccdp + crapsli.vlsddisp.

                        IF  aux_flganter THEN
                            DO:
                               ASSIGN tt-extrato_ir.flganter = aux_flganter
                                      tt-extrato_ir.vlsdccd1 = ant_vlsdccdp
                                      tt-extrato_ir.vlsddve1 = ant_vlsddvem
                                      tt-extrato_ir.vlttcca1 = ant_vlttccap
                                      tt-extrato_ir.vlsdapl1 = ant_vlsdapli.
                            END.

                    END. /* ELSE */
               
            END. /* IF  par_nranoref > 1994  */
            ELSE
            DO:
                ASSIGN aux_nmcidade = TRIM(crapcop.nmcidade)
                       rel_dscooper = crapcop.nmextcop + " - " +
                                      STRING(STRING(crapcop.nrdocnpj,
                                                    "99999999999999"),
                                                    "xx.xxx.xxx/xxxx-xx")
                
                       rel_dsendcop = crapcop.dsendcop + ", " + 
                                      STRING(crapcop.nrendcop,"zz,zz9") + 
                                      " - CEP " + STRING(crapcop.nrcepend,
                                                          "99,999,999") +
                                      " - " + aux_nmcidade + " - " +
                                      crapcop.cdufdcop
                                      
                       rel_dstelcop = "TELEFONE: " + crapcop.nrtelvoz + " - " +
                                      "FAX: " + crapcop.nrtelfax.

                IF  NOT AVAILABLE crapage   THEN
                    ASSIGN rel_dsagenci = STRING(crapass.cdagenci) + 
                                                " - Nao cadastrada!".
                ELSE
                    ASSIGN rel_dsagenci = crapage.nmresage.

                ASSIGN  mfx_vlsddvem = 0
                        mfx_vlsdccdp = 0
                        mfx_vlsdapli = 0
                        mfx_vlttccap = 0
                        rel_qtjaicmf = 0
                        rel_vlrenapl = 0
                        aux_regexis1 = FALSE.

                FIND FIRST crapdir WHERE 
                           crapdir.cdcooper = par_cdcooper      AND
                           crapdir.nrdconta = crapass.nrdconta  AND
                           YEAR(crapdir.dtmvtolt) = par_nranoref
                           USE-INDEX crapdir1 NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapdir THEN
                    DO:
                        ASSIGN aux_dscritic = "Conta/dv: " +
                                                      STRING(par_nrdconta) +
                                                      " - Nao ha dados para " +
                                                      "imposto de renda de " +
                                                      STRING(par_nranoref) + "." .
                        LEAVE Busca. 
                    END.

                ASSIGN aux_cdacesso = "IRENDA" + 
                                      STRING(YEAR(crapdir.dtmvtolt),"9999").

                FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                                   craptab.nmsistem = "CRED"       AND
                                   craptab.tptabela = "GENERI"     AND
                                   craptab.cdempres = 0            AND
                                   craptab.cdacesso = aux_cdacesso AND
                                   craptab.tpregist = 1            
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE craptab THEN
                    DO:
                        ASSIGN aux_cdcritic = 457.
                        LEAVE Busca.
                    END.

                ASSIGN aux_vlmoefi1 = DECIMAL(STRING(SUBSTRING(craptab.dstextab,22,15),
                                               "999999,99999999"))
                       rel_vldjuros = DECIMAL(STRING(SUBSTRING(craptab.dstextab,38,15),
                                                               "999999,99999999"))
                       mfx_vlsddve1 = crapdir.vlsddvem / aux_vlmoefi1
                       mfx_vlsdccd1 = crapdir.vlsdccdp / aux_vlmoefi1
                       mfx_vlsdapl1 = crapdir.vlsdapli / aux_vlmoefi1
                       mfx_vlttcca1 = crapdir.vlttccap / aux_vlmoefi1
                
                       rel_vldjuros = crapdir.qtjaicmf * rel_vldjuros
                
                       rel_vlrenap1 = crapdir.qtreamfx
                
                       rel_qtjaicm1 = rel_vldjuros / aux_vlmoefi1
                
                       mfx_dtmvtol1 = crapdir.dtmvtolt
                
                       aux_regexist = TRUE.

                IF  aux_regexist THEN
                    DO:
                        FIND FIRST crapdir WHERE 
                                   crapdir.cdcooper = par_cdcooper      AND
                                   crapdir.nrdconta = crapass.nrdconta  AND
                                   YEAR(crapdir.dtmvtolt) = par_nranoref - 1
                                   USE-INDEX crapdir1 NO-LOCK NO-ERROR.

                        IF  AVAILABLE crapdir THEN
                            DO:
                                ASSIGN aux_cdacesso = "IRENDA" + 
                                         STRING(YEAR(crapdir.dtmvtolt),"9999").
            
                                FIND craptab WHERE 
                                     craptab.cdcooper = par_cdcooper      AND
                                     craptab.nmsistem = "CRED"            AND
                                     craptab.tptabela = "GENERI"          AND
                                     craptab.cdempres = 0                 AND
                                     craptab.cdacesso = aux_cdacesso      AND
                                     craptab.tpregist = 1 NO-LOCK NO-ERROR.
            
                                IF  AVAILABLE craptab THEN
                                    DO:
                                        ASSIGN aux_vlmoefix = DECIMAL(STRING(SUBSTRING(
                                                        craptab.dstextab,22,15),
                                                        "999999,99999999"))
                                                rel_vldjuros = DECIMAL(STRING(SUBSTRING(
                                                                    craptab.dstextab,38,15),
                                                                    "999999,99999999"))
                                                mfx_vlsddvem = crapdir.vlsddvem / aux_vlmoefix
                                                mfx_vlsdccdp = crapdir.vlsdccdp~  / aux_vlmoefix
                                                mfx_vlsdapli = crapdir.vlsdapli / aux_vlmoefix
                                                mfx_vlttccap = crapdir.vlttccap / aux_vlmoefix
                                              
                                                rel_vldjuros = crapdir.qtjaicmf * rel_vldjuros
                                              
                                                rel_vlrenapl = crapdir.qtreamfx
                                              
                                                rel_qtjaicmf = rel_vldjuros / aux_vlmoefix
                                              
                                                mfx_dtmvtolt = crapdir.dtmvtolt
                                              
                                                aux_regexis1 = TRUE.
                                    END.

                            END.

                        CREATE tt-extrato_ir.
                        ASSIGN tt-extrato_ir.nmcidade = aux_nmcidade
                               tt-extrato_ir.nrdconta = crapass.nrdconta
                               tt-extrato_ir.nmprimtl = crapass.nmprimtl
                               tt-extrato_ir.regexis1 = aux_regexis1
                               tt-extrato_ir.dsagenci = rel_dsagenci
                               tt-extrato_ir.dtmvtolt = mfx_dtmvtolt
                               tt-extrato_ir.dtmvtol1 = mfx_dtmvtol1
                               tt-extrato_ir.vlsddvem = mfx_vlsddvem
                               tt-extrato_ir.vlsddve1 = mfx_vlsddve1
                               tt-extrato_ir.vlsdccdp = mfx_vlsdccdp
                               tt-extrato_ir.vlsdccd1 = mfx_vlsdccd1
                               tt-extrato_ir.vlsdapli = mfx_vlsdapli
                               tt-extrato_ir.vlsdapl1 = mfx_vlsdapl1
                               tt-extrato_ir.vlttccap = mfx_vlttccap
                               tt-extrato_ir.vlttcca1 = mfx_vlttcca1
                               tt-extrato_ir.qtjaicmf = rel_qtjaicmf
                               tt-extrato_ir.qtjaicm1 = rel_qtjaicm1
                               tt-extrato_ir.vlrenap1 = rel_vlrenap1
                               tt-extrato_ir.vlmoefix = aux_vlmoefix
                               tt-extrato_ir.vlmoefi1 = aux_vlmoefi1
                               tt-extrato_ir.dscooper = rel_dscooper
                               tt-extrato_ir.dsendcop = rel_dsendcop
                               tt-extrato_ir.dstelcop = rel_dstelcop
                               tt-extrato_ir.vlrenapl = rel_vlrenapl.

                    END. /* IF  aux_regexist */
                
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Busca.

    END. /* Busca */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    
    RETURN aux_returnvl.

END PROCEDURE. /* consulta-imposto-renda */

                                  

PROCEDURE imprime_extrato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcalcul AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    /*  extrato    */
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_intpextr AS INTE                           NO-UNDO.
    /*  relatorio */
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgimpri AS LOGI                           NO-UNDO.    

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-extrato_epr_aux.

    EMPTY TEMP-TABLE tt-erro.

    EMPTY TEMP-TABLE tt-extrato_epr_aux.

    /*  Campos f_cabec  */
    DEF VAR aux_vlemprst AS CHAR                                    NO-UNDO.
    DEF VAR aux_txmensal AS CHAR                                    NO-UNDO.
    DEF VAR aux_txinmens AS CHAR                                    NO-UNDO.
    DEF VAR aux_multatra AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlparepr AS CHAR                                    NO-UNDO.
    DEF VAR aux_carencia AS CHAR                                    NO-UNDO.
                                                           
    /* campos f-parcelas    ESQ */                         
    DEF VAR aux_codigesq AS CHAR                                    NO-UNDO.
    DEF VAR aux_datadesq AS DATE                                    NO-UNDO.
    DEF VAR aux_valoresq AS CHAR                                    NO-UNDO.
    DEF VAR aux_indpgesq AS CHAR                                    NO-UNDO.
    DEF VAR aux_contaesq AS INTE INIT 1                             NO-UNDO.
    /* campos f-parcelas    DIR */                         
    DEF VAR aux_codigdir AS CHAR                                    NO-UNDO.
    DEF VAR aux_dataddir AS DATE                                    NO-UNDO.
    DEF VAR aux_valordir AS CHAR                                    NO-UNDO.
    DEF VAR aux_indpgdir AS CHAR                                    NO-UNDO.
    DEF VAR aux_contadir AS INTE                                    NO-UNDO.
                                                           
    DEF VAR aux2_carencia AS DECIMAL                                NO-UNDO.
    DEF VAR h-b1wgen0084a AS HANDLE                                 NO-UNDO.
    DEF VAR h-b1wgen0134  AS HANDLE                                 NO-UNDO.
                                                           
    /*  relatorio */                                       
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR cSepara      AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlsaldo1 AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsaldo2 AS DECI                                    NO-UNDO.
    DEF VAR aux_flginfor AS LOGI                                    NO-UNDO.
    DEF VAR aux_flginfor2 AS LOGI                                   NO-UNDO.
                                                           
    DEF VAR aux_diapagto AS INTE                                    NO-UNDO.
    DEF VAR aux_mespagto AS INTE                                    NO-UNDO.
    DEF VAR aux_anopagto AS INTE                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.


    FORM 
        crapepr.nrdconta              AT 01 LABEL "Conta"
        crapepr.nrctremp              AT 26 LABEL "Contrato"
        crapepr.cdagenci              AT 67 LABEL "Pa" 
        SKIP
        cSepara          FORMAT "x(80)"    AT 01     NO-LABEL
        SKIP(1)
        craplcr.dslcremp                COLON 24     LABEL "Linha de Credito"
        SKIP(1)
        aux_vlemprst     FORMAT "x(18)"     COLON 24 LABEL "Valor Emprestado"
        crapepr.dtmvtolt        COLON 61 LABEL "Data de Liberacao"
        SKIP
        aux_txmensal     FORMAT "x(16)" COLON 24 LABEL "Taxa do Contrato ao mes"
        aux_vlparepr     FORMAT "x(18)" COLON 61 LABEL "Valor da Parcela"
        SKIP
        aux_txinmens     FORMAT "x(10)" COLON 24
                                                 LABEL "Taxa de Mora ao mes"
        aux_carencia            COLON 61 LABEL "Dias de Carencia" 
        SKIP
        aux_multatra     FORMAT "x(10)" COLON 24 LABEL "Multa"
        crapepr.qtpreemp        COLON 24         LABEL "Quantidade de Parcelas"
        WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f-cabec STREAM-IO.


    FORM aux_codigesq AT 01 FORMAT "X(4)" 
         aux_datadesq 
         aux_valoresq       FORMAT "X(12)"
         aux_indpgesq       FORMAT "x(9)"

         aux_codigdir AT 42 FORMAT "X(4)" 
         aux_dataddir 
         aux_valordir       FORMAT "X(12)"
         aux_indpgdir       FORMAT "x(9)"
         WITH NO-BOX WIDTH 80  FRAME f-parcela STREAM-IO NO-LABELS.

    FORM tt-extrato_epr_aux.dtmvtolt FORMAT "99/99/99" COLUMN-LABEL "DATA"
         tt-extrato_epr_aux.dsextrat FORMAT "X(21)"    COLUMN-LABEL "HISTORICO"
         tt-extrato_epr_aux.nrparepr FORMAT "x(4)"     COLUMN-LABEL " PAR"
         tt-extrato_epr_aux.vldebito FORMAT "->>,>>>,>>9.99" 
                                                       COLUMN-LABEL "DEBITO"
         tt-extrato_epr_aux.vlcredit FORMAT "->>,>>>,>>9.99" 
                                                       COLUMN-LABEL "CREDITO"
         tt-extrato_epr_aux.vlsaldo  FORMAT "->>,>>>,>>9.99" COLUMN-LABEL "SALDO"
         WITH NO-BOX WIDTH 80  FRAME f-extrato STREAM-IO DOWN.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcop THEN
       DO:
          ASSIGN aux_cdcritic = 651
                 aux_dscritic = "".

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1, /*nrsequen*/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

       END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                             NO-LOCK NO-ERROR.
   
    IF NOT AVAIL crapdat  THEN
       DO:
           ASSIGN aux_cdcritic = 1 
                  aux_dscritic = "".
          
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).  

           RETURN "NOK".

       END. 

    IF NOT VALID-HANDLE(h-b1wgen0134) THEN
       RUN sistema/generico/procedures/b1wgen0134.p 
           PERSISTENT SET h-b1wgen0134.

    RUN valida_empr_tipo1 IN h-b1wgen0134 (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_nrdconta,
                                           INPUT par_nrctremp,
                                          OUTPUT TABLE tt-erro).  

    IF VALID-HANDLE(h-b1wgen0134) THEN
       DELETE PROCEDURE h-b1wgen0134.
    
    IF RETURN-VALUE <> "OK"  THEN
       RETURN "NOK".

    IF NOT VALID-HANDLE(h-b1wgen0002) THEN
       RUN sistema/generico/procedures/b1wgen0002.p 
           PERSISTENT SET h-b1wgen0002.          
    
    RUN obtem-extrato-emprestimo IN h-b1wgen0002 ( 
                                    INPUT  par_cdcooper,
                                    INPUT  par_cdagenci,
                                    INPUT  par_nrdcaixa,
                                    INPUT  par_cdoperad,
                                    INPUT  par_nmdatela,
                                    INPUT  par_idorigem,
                                    INPUT  par_nrdconta,
                                    INPUT  par_idseqttl,
                                    INPUT  par_nrctremp,
                                    INPUT  par_dtiniper,
                                    INPUT  par_dtfimper,
                                    INPUT  par_flgerlog,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-extrato_epr).

    IF VALID-HANDLE(h-b1wgen0002) THEN
       DELETE PROCEDURE h-b1wgen0002.

    IF RETURN-VALUE <> "OK" THEN 
       RETURN "NOK".

    IF NOT VALID-HANDLE(h-b1wgen0084) THEN
       RUN sistema/generico/procedures/b1wgen0084.p 
           PERSISTENT SET h-b1wgen0084.
    
    FOR FIRST crapepr WHERE crapepr.cdcooper = par_cdcooper AND
                            crapepr.nrdconta = par_nrdconta AND 
                            crapepr.nrctremp = par_nrctremp
                            NO-LOCK:
                        
        FIND FIRST crawepr WHERE crawepr.cdcooper = par_cdcooper AND
                                 crawepr.nrdconta = par_nrdconta AND
                                 crawepr.nrctremp = par_nrctremp 
                                 NO-LOCK NO-ERROR. 

        IF NOT AVAIL crawepr THEN
           DO:
              IF VALID-HANDLE(h-b1wgen0084) THEN
                 DELETE OBJECT h-b1wgen0084.

              ASSIGN aux_cdcritic = 535
                     aux_dscritic = "".
                  
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1, /*nrsequen*/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
           
              RETURN "NOK".

           END.

        FIND craplcr WHERE craplcr.cdcooper = crapcop.cdcooper AND
                           craplcr.cdlcremp = crapepr.cdlcremp 
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL craplcr THEN
           DO:           
              IF VALID-HANDLE(h-b1wgen0084) THEN
                 DELETE OBJECT h-b1wgen0084.

              ASSIGN aux_cdcritic = 363.
                     aux_dscritic = "".
              
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).  
              
              RETURN "NOK".

           END.

        /* Verifica se Cobra Multa */
        IF craplcr.flgcobmu THEN
           DO:
               FIND FIRST craptab WHERE craptab.cdcooper = 3             AND
                                        craptab.nmsistem = "CRED"        AND
                                        craptab.tptabela = "USUARI"      AND
                                        craptab.cdempres = 11            AND
                                        craptab.cdacesso = "PAREMPCTL"   AND
                                        craptab.tpregist = 01            
                                        NO-LOCK NO-ERROR.

               IF NOT AVAIL craptab THEN
                  DO:
                      IF VALID-HANDLE(h-b1wgen0084) THEN
                         DELETE OBJECT h-b1wgen0084.
        
                      ASSIGN aux_cdcritic = 55
                             aux_dscritic = "".
                         
                      RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1, /*nrsequen*/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).
                  
                      RETURN "NOK".
        
                  END.

               ASSIGN aux_multatra = DYNAMIC-FUNCTION("fnFormataValor" 
                                            IN h-b1wgen0084,
                                                  INPUT "",                    
                                                  INPUT
                                            DEC(SUBSTRING(craptab.dstextab,1,6)),
                                                    INPUT ">>9.99",
                                                    INPUT "%").

           END. /* END IF craplcr.flgcobmu THEN */
        ELSE
           ASSIGN aux_multatra = "0".

        ASSIGN aux_diapagto =  DAY(crawepr.dtdpagto)
               aux_mespagto = MONTH(crawepr.dtdpagto)
               aux_anopagto = YEAR(crawepr.dtdpagto).

        RUN Dias360 IN h-b1wgen0084 (INPUT FALSE,
                                     INPUT DAY(crawepr.dtdpagto),
                                     INPUT DAY(crawepr.dtlibera),
                                     INPUT MONTH(crawepr.dtlibera) ,
                                     INPUT YEAR(crawepr.dtlibera),
                                     INPUT-OUTPUT aux_diapagto,
                                     INPUT-OUTPUT aux_mespagto,
                                     INPUT-OUTPUT aux_anopagto,
                                     OUTPUT aux2_carencia).
                                   
        ASSIGN  aux_vlemprst = 
                DYNAMIC-FUNCTION("fnFormataValor" IN h-b1wgen0084,
                                  INPUT "R$ ",
                                  INPUT crapepr.vlemprst,
                                  INPUT "zzz,zzz,zz9.99",
                                  INPUT "")
            
                aux_txmensal = 
                DYNAMIC-FUNCTION("fnFormataValor" IN h-b1wgen0084,
                                  INPUT "",
                                  INPUT crapepr.txmensal,
                                  INPUT "zz9.99",
                                  INPUT "%")
    
                aux_carencia = 
                DYNAMIC-FUNCTION("fnFormataValor" IN h-b1wgen0084,
                                  INPUT "",
                                  INPUT aux2_carencia,
                                  INPUT ">>>9",
                                  INPUT " dias")

                aux_vlparepr = 
                DYNAMIC-FUNCTION("fnFormataValor" IN h-b1wgen0084,
                                  INPUT "R$ ",
                                  INPUT crapepr.vlpreemp,
                                  INPUT "zzz,zzz,zz9.99",
                                  INPUT "").

                aux_txinmens = 
                DYNAMIC-FUNCTION("fnFormataValor" IN h-b1wgen0084,
                                  INPUT "",                    
                                  INPUT craplcr.perjurmo,
                                  INPUT ">>9.99",
                                  INPUT "%").

        IF par_flgimpri THEN
           DO:
               DISPLAY STREAM str_1 
                   FILL("-",80) @ cSepara
                   crapepr.nrdconta
                   crapepr.nrctremp
                   crapepr.cdagenci
                   craplcr.dslcremp WHEN AVAIL craplcr
                   aux_vlemprst
                   crapepr.dtmvtolt
                   aux_txmensal
                   aux_txinmens 
                   aux_multatra 
                   aux_vlparepr
                   crapepr.qtpreemp
                   aux_carencia
                   WITH FRAME f-cabec.             
           END.
                     
        RUN busca_parcelas_proposta IN h-b1wgen0084
                                    ( INPUT  par_cdcooper,
                                      INPUT  par_cdagenci,
                                      INPUT  par_nrdcaixa,
                                      INPUT  par_cdoperad,
                                      INPUT  par_nmdatela,
                                      INPUT  par_idorigem,
                                      INPUT  par_nrdconta,
                                      INPUT  par_idseqttl,
                                      INPUT  par_dtmvtolt,
                                      INPUT  par_flgerlog,
                                      INPUT  par_nrctremp,
                                      INPUT  crapepr.cdlcremp,
                                      INPUT  crapepr.vlemprst,
                                      INPUT  crapepr.qtpreemp,
                                      INPUT  crapepr.dtmvtolt,
                                      INPUT  crapepr.dtdpagto,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-parcelas-epr).
                
        IF RETURN-VALUE <> "OK" THEN
           DO:
              IF VALID-HANDLE(h-b1wgen0084) THEN
                 DELETE PROCEDURE h-b1wgen0084.

              RETURN "NOK".

           END.

        IF CAN-FIND(FIRST tt-parcelas-epr)   AND 
           par_flgimpri                      THEN
           PUT STREAM str_1 SKIP(2) "PARCELAS em R$:" SKIP.

        ASSIGN aux_contadir = INT(crapepr.qtpreemp / 2) + 1.

        
        DO aux_contador = 1 TO crapepr.qtpreemp:
        
           IF aux_contador MOD 2 = 1 THEN
              DO:
                 FIND tt-parcelas-epr 
                       WHERE tt-parcelas-epr.nrparepr = aux_contaesq 
                             NO-LOCK NO-ERROR.

                 ASSIGN aux_contaesq = aux_contaesq + 1.

              END. 
           ELSE
              DO:
                 FIND tt-parcelas-epr 
                      WHERE tt-parcelas-epr.nrparepr = aux_contadir 
                            NO-LOCK NO-ERROR.

                 ASSIGN aux_contadir = aux_contadir + 1.
          
              END.
        
           IF NOT AVAIL tt-parcelas-epr THEN 
              LEAVE.
        
           ASSIGN aux_codigesq = 
                  DYNAMIC-FUNCTION("fnFormataValor" IN h-b1wgen0084,
                                    INPUT "",
                                    INPUT DEC(tt-parcelas-epr.nrparepr),
                                    INPUT ">9",
                                    INPUT ") ")

                  aux_valoresq = 
                  DYNAMIC-FUNCTION("fnFormataValor" IN h-b1wgen0084,
                                    INPUT "",
                                    INPUT tt-parcelas-epr.vlparepr,
                                    INPUT "zzz,zzz,zz9.99",
                                    INPUT "")
        
                  aux_codigdir = 
                  DYNAMIC-FUNCTION("fnFormataValor" IN h-b1wgen0084,
                                    INPUT "",
                                    INPUT DEC(tt-parcelas-epr.nrparepr),
                                    INPUT ">9",
                                    INPUT ") ")

                  aux_valordir = 
                  DYNAMIC-FUNCTION("fnFormataValor" IN h-b1wgen0084,
                                    INPUT "",
                                    INPUT tt-parcelas-epr.vlparepr,
                                    INPUT "zzz,zzz,zz9.99",
                                    INPUT "").
        
           ASSIGN aux_indpgesq = "?????".

           CASE tt-parcelas-epr.indpagto:
               WHEN 0 THEN 
                   DO: 
                     IF tt-parcelas-epr.dtvencto < par_dtmvtolt      AND
                        tt-parcelas-epr.dtvencto <= crapdat.dtmvtoan THEN 
                        ASSIGN aux_indpgesq = "Vencida".
                     ELSE
                        DO:
                            ASSIGN aux_indpgesq = "A vencer"
                                   aux_vlsaldo1 = aux_vlsaldo1
                                                  + tt-parcelas-epr.vlparepr.
                        END.
                   END.
               WHEN 1 THEN 
                   ASSIGN aux_indpgesq = "Liquidada".

           END CASE.

           ASSIGN aux_indpgdir = aux_indpgesq.
        
           IF par_flgimpri THEN
              DO:
                 IF aux_contador MOD 2 = 1 THEN
                    DISP STREAM str_1
                                aux_codigesq
                                tt-parcelas-epr.dtparepr @ aux_datadesq
                                aux_valoresq
                                aux_indpgesq
                                WITH FRAME f-parcela.
                 ELSE 
                    DO:
                        DISP STREAM str_1
                             aux_codigdir
                             tt-parcelas-epr.dtparepr @ aux_dataddir
                             aux_valordir 
                             aux_indpgdir
                             WITH FRAME f-parcela.

                        DOWN STREAM str_1 WITH FRAME f-parcela.

                    END.
              END.           
        
        END. /*  DO  aux_contador = 1 TO crapepr.qtpreemp   */

        ASSIGN aux_vlsaldo1 =  crapepr.vlemprst.

        IF VALID-HANDLE(h-b1wgen0084) THEN
           DELETE PROCEDURE h-b1wgen0084.

        IF NOT VALID-HANDLE(h-b1wgen0084a) THEN
           RUN sistema/generico/procedures/b1wgen0084a.p 
               PERSISTENT SET h-b1wgen0084a.

        RUN busca_pagamentos_parcelas IN h-b1wgen0084a 
                                    (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT par_cdoperad,
                                     INPUT par_nmdatela,
                                     INPUT par_idorigem,
                                     INPUT crapepr.nrdconta,
                                     INPUT par_idseqttl,
                                     INPUT par_dtmvtolt,
                                     INPUT FALSE,
                                     INPUT crapepr.nrctremp,
                                     INPUT crapdat.dtmvtoan,
                                     INPUT 0, /* Todas */
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-pagamentos-parcelas,
                                    OUTPUT TABLE tt-calculado).

        IF VALID-HANDLE(h-b1wgen0084a) THEN
           DELETE PROCEDURE h-b1wgen0084a.

        IF RETURN-VALUE <> "OK" THEN
           RETURN "NOK".

        FIND FIRST tt-calculado NO-LOCK NO-ERROR.

        IF AVAIL tt-calculado THEN
           ASSIGN aux_vlsaldo2 = tt-calculado.vlsdeved.

    END. /* FOR EACH tt-dados-epr */ 

    IF VALID-HANDLE(h-b1wgen0084) THEN
       DELETE PROCEDURE h-b1wgen0084.

    FOR EACH tt-extrato_epr BREAK BY tt-extrato_epr.dtmvtolt
                                     BY tt-extrato_epr.nrparepr
                                        BY tt-extrato_epr.dsextrat
                                           BY tt-extrato_epr.flglista:
                    
        CREATE tt-extrato_epr_aux.

        BUFFER-COPY tt-extrato_epr TO tt-extrato_epr_aux.

        IF tt-extrato_epr.cdhistor = 1050 OR 
           tt-extrato_epr.cdhistor = 1051 THEN
           DO:
               ASSIGN aux_flginfor = TRUE
                      tt-extrato_epr_aux.dsextrat = tt-extrato_epr.dsextrat + 
                                                    "*".
           END.
        IF tt-extrato_epr.cdhistor = 1711 OR 
           tt-extrato_epr.cdhistor = 1720 OR
           tt-extrato_epr.cdhistor = 1708 OR
           tt-extrato_epr.cdhistor = 1717 THEN 
           DO:
               ASSIGN aux_flginfor2 = TRUE
                      tt-extrato_epr_aux.dsextrat = tt-extrato_epr.dsextrat + 
                                                    "**".
           END.  

        IF FIRST (tt-extrato_epr.dtmvtolt) THEN
           DO:
               /* Saldo Inicial */
               ASSIGN tt-extrato_epr_aux.vlsaldo  = tt-extrato_epr.vllanmto
                      tt-extrato_epr_aux.vldebito = tt-extrato_epr.vllanmto
                      aux_vlsaldo1 = tt-extrato_epr.vllanmto.

               NEXT.

           END.
   
        CASE tt-extrato_epr_aux.indebcre:
            WHEN "C" THEN
            DO: 
                ASSIGN tt-extrato_epr_aux.vlcredit = tt-extrato_epr.vllanmto.

                IF tt-extrato_epr.flgsaldo THEN
                   ASSIGN aux_vlsaldo1 = aux_vlsaldo1 - tt-extrato_epr.vllanmto 
                          tt-extrato_epr_aux.vlsaldo = aux_vlsaldo1.
                ELSE
                   ASSIGN tt-extrato_epr_aux.vlsaldo = aux_vlsaldo1.

            END.
            WHEN "D" THEN
            DO: 
               ASSIGN tt-extrato_epr_aux.vldebito = tt-extrato_epr.vllanmto.
                        
               IF tt-extrato_epr.flgsaldo THEN
                   ASSIGN aux_vlsaldo1 = aux_vlsaldo1 + tt-extrato_epr.vllanmto
                          tt-extrato_epr_aux.vlsaldo = aux_vlsaldo1.
                ELSE
                   ASSIGN tt-extrato_epr_aux.vlsaldo = aux_vlsaldo1.

            END.
        END CASE.

        IF LAST(tt-extrato_epr.dtmvtolt) THEN
           DO:
               IF crapepr.tpemprst = 1 AND crapepr.inprejuz = 1 THEN
                  DO:
                      tt-extrato_epr_aux.vlsaldo = 0.
                  END.

           END. /* END IF LAST(tt-extrato_epr.dtmvtolt) THEN */
    
    END. /* FOR EACH tt-extrato_epr */

    IF par_flgimpri THEN
       DO:
           DISPLAY STREAM str_1 SKIP(2) WITH FRAME f_pula_linha.
    
           IF par_intpextr = 2 THEN
              DO: /* 1 - Simplificado,  2 - Detalhado */           
                  /* Cuidado ao mudar BY deste for each, pois tem que */
                  /* estar igual ao FOR EACH da tt-extrato_epr de cima */
                  FOR EACH tt-extrato_epr_aux
                      WHERE tt-extrato_epr_aux.flglista = TRUE
                            NO-LOCK BY tt-extrato_epr_aux.dtmvtolt
                                     BY tt-extrato_epr_aux.nrparepr
                                      BY tt-extrato_epr_aux.dsextrat:
                  
                      DISP STREAM str_1 
                           tt-extrato_epr_aux.dtmvtolt
                           tt-extrato_epr_aux.dsextrat 
                           tt-extrato_epr_aux.nrparepr 
                                 WHEN tt-extrato_epr_aux.nrparepr <> "99"
                           tt-extrato_epr_aux.vldebito
                           tt-extrato_epr_aux.vlcredit
                          tt-extrato_epr_aux.vlsaldo 
                           WITH FRAME f-extrato.

                      DOWN STREAM str_1 WITH FRAME f-extrato.
                  
                  END. /* FOR EACH tt-extrato_epr_aux */            

                  DISPLAY STREAM str_1
                      SKIP(2)
                      "Saldo para Liquidacao em"  AT 25
                      STRING(par_dtmvtolt,'99/99/9999') FORMAT "x(10)" "R$:"
                      aux_vlsaldo2 AT 64 FORMAT "-z,zzz,zz9.99"
                      WITH WIDTH 80 NO-LABELS FRAME f_saldo_liquidacao.
              END.
           ELSE
              DISPLAY STREAM str_1
                  SKIP(2)
                  "Saldo para Liquidacao em" AT 25
                  STRING(par_dtmvtolt,'99/99/9999') FORMAT "x(10)" "R$:"
                  aux_vlsaldo2 AT 64 FORMAT "-z,zzz,zz9.99"
                  WITH WIDTH 80 NO-LABELS FRAME f_saldo_liquidacao_2.
       END.

    IF par_flgimpri AND    /* Se imprime e se teve juros remuneratorios* */
       aux_flginfor THEN
       DO:
           DISPLAY STREAM str_1
                   SKIP(2)
                   "* Demonstracao dos juros remuneratorios da parcela paga em" AT 01
                   "atraso. Nao altera" 
                   SKIP 
                   " o saldo devedor. " AT 01
                   WITH WIDTH 80 NO-LABELS FRAME f_lanc_informativo.    

       END.

    IF par_flgimpri  AND
       aux_flginfor2 THEN
       DO:
            DISPLAY STREAM str_1
                    SKIP(2)
                    "** Atencao! Esse lancamento e apenas informativo, nao altera "
                    "o saldo devedor."                       
                    SKIP
                    "O credito do estorno e efetuado em conta corrente."
                    WITH WIDTH 80 NO-LABELS FRAME f_lanc_informativo.           
       END.
        
    RETURN "OK".

END PROCEDURE. /*   imprime extrato  */


PROCEDURE Gera_Impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgrodar AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextrat AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtreffim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgtarif AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM par_inrelext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inselext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO. 
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nranoref AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM par_intpextr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpinform AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrperiod AS INTE                           NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.    
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    /* Vari�veis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
    DEF VAR aux_flgrodar  AS INTEGER  NO-UNDO.
    DEF VAR aux_flgtarif  AS INTEGER  NO-UNDO. 
    DEF VAR aux_flgerlog  AS INTEGER  NO-UNDO. 
    DEF VAR aux_dtrefere  AS DATE NO-UNDO.
    DEF VAR aux_dtreffim  AS DATE NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dscritic = ""
           aux_cdcritic = 0.
    
    /* conversao de variavies booleanas para inteiro */
    IF par_flgrodar THEN
        aux_flgrodar = 1.
    ELSE 
        aux_flgrodar = 0.

    IF par_flgtarif THEN
        aux_flgtarif = 1.
    ELSE 
        aux_flgtarif = 0.

    IF par_flgerlog THEN
        aux_flgerlog = 1.
    ELSE 
        aux_flgerlog = 0.
    
    /* Data referencia ini */
    IF par_dtrefere <> ? THEN
        ASSIGN aux_dtrefere = par_dtrefere.
    ELSE
        ASSIGN aux_dtrefere = par_dtmvtolt.

    /* Data referencia fim */
    IF par_dtreffim <> ? THEN
        ASSIGN aux_dtreffim = par_dtreffim.
    ELSE
        ASSIGN aux_dtreffim = par_dtmvtolt.


    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 


    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_gera_impressao_car
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* C�digo da Cooperativa */
                                             INPUT par_cdagenci, /* Codigo da Agencia */
                                             INPUT par_nrdcaixa, /* Numero do Caixa */
                                             INPUT par_idorigem, /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                             INPUT par_nmdatela, /* Nome da Tela */
                                             INPUT par_dtmvtolt, /* Data de Movimento */
                                             INPUT par_dtmvtopr, /* Data Proximo Movimento */
                                             INPUT par_cdprogra, /* Codigo do Programa */
                                             INPUT par_inproces, /* Indicador Processo */
                                             INPUT par_cdoperad, /* C�digo do Operador */
                                             INPUT par_dsiduser, /* Identificador Usuario */
                                             INPUT aux_flgrodar, /* Flag Executar */
                                             INPUT par_nrdconta, /* N�mero da Conta */
                                             INPUT par_idseqttl, /* Sequencial do Titular */
                                             INPUT par_tpextrat, /* Tipo de Extrato */
                                             INPUT aux_dtrefere, /* Data de Referencia */
                                             INPUT aux_dtreffim, /* Data Referencia Final */
                                             INPUT aux_flgtarif, /* Indicador Cobra tarifa */
                                             INPUT par_inrelext, /* Indicador Relatorio Extrato */
                                             INPUT par_inselext, /* Indicador Selecao Extrato */
                                             INPUT par_nrctremp, /* Numero Contrato Emprestimo */
                                             INPUT par_nraplica, /* Numero Aplicacao */
                                             INPUT par_nranoref, /* Ano de Referencia */
                                             INPUT 1,            /* Escreve erro Log */ 
                                             INPUT par_intpextr, /* Tipo de extrato (1=Simplificado, 2=Detalhado) */ 
                                             INPUT par_tpinform, /* Tipo do Informe PJ => 0-Anual / 1-Trimestral */
                                             INPUT par_nrperiod, /* Trimestre PJ 1-Jan-Mar / 2-Abr-Jun / 3-Jul-Set / 4-Out-Dez */
                                             OUTPUT "",          /* pr_nmarqimp */
                                             OUTPUT "",          /* pr_nmarqpdf */
                                             OUTPUT "").         /* pr_des_reto */


    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_gera_impressao_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

     /*Busca poss�veis erros */
    ASSIGN aux_dscritic = ""
           aux_nmarqimp = pc_gera_impressao_car.pr_nmarqimp
           aux_nmarqpdf = pc_gera_impressao_car.pr_nmarqpdf
           aux_dscritic = pc_gera_impressao_car.pr_des_reto 
                          WHEN pc_gera_impressao_car.pr_des_reto <> ?.

    IF aux_dscritic <> "OK" THEN
        DO:  
             CREATE tt-erro.

             IF aux_dscritic = "NOK" THEN
                ASSIGN tt-erro.cdcritic = 1
                       tt-erro.dscritic = "Erro ao gerar extrado das aplicacoes".
             ELSE 
                ASSIGN tt-erro.cdcritic = 2
                       tt-erro.dscritic = aux_dscritic.
        
             RETURN "NOK".
        END.

    IF par_idorigem = 1 THEN
        DO:
            ASSIGN aux_nmarqimp = SUBSTR(aux_nmarqimp,R-INDEX(aux_nmarqimp,"/rl/") + 1).
        END.

    RETURN "OK".

END PROCEDURE. /* Gera_Impressao */

/****************************************************************************/

PROCEDURE Gera_Impressao_Aplicacao:

     DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
     DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.

     DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_tpmodelo AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dtvctini AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_tprelato AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
     DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
     DEF  INPUT PARAM par_dtvctfim AS DATE                           NO-UNDO.

     DEF  OUTPUT PARAM aux_nmarqimp AS LONGCHAR                          NO-UNDO.
     DEF  OUTPUT PARAM aux_nmarqpdf AS LONGCHAR                          NO-UNDO.
     DEF  OUTPUT PARAM TABLE FOR tt-demonstrativo.
     DEF  OUTPUT PARAM TABLE FOR tt-erro.

     DEF  VAR          aux_vlsldapl AS DECI                          NO-UNDO.
     DEF  VAR          aux_dtiniper AS DATE                          NO-UNDO.
     DEF  VAR          aux_dtfimper AS DATE                          NO-UNDO.
     DEF  VAR          aux_intpextr AS INTE     INIT 0               NO-UNDO.

     /* Vari�veis utilizadas para receber clob da rotina no oracle */
     DEF VAR xDoc          as HANDLE   NO-UNDO.   
     DEF VAR xRoot         AS HANDLE   NO-UNDO.  
     DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
     DEF VAR xField        AS HANDLE   NO-UNDO. 
     DEF VAR xText         AS HANDLE   NO-UNDO. 
     DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
     DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
     DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
     DEF VAR xml_req       AS LONGCHAR NO-UNDO.

     EMPTY TEMP-TABLE tt-extr-apl.
     EMPTY TEMP-TABLE tt-extr-rdca.
     EMPTY TEMP-TABLE tt-saldo-rdca. /* b1wgen0004tt.i */
     EMPTY TEMP-TABLE tt-erro.

     DEF VAR aux_nraplica   AS INTE                                  NO-UNDO.
     DEF VAR aux_cdprodut   AS INTE                                  NO-UNDO.
     DEF VAR aux_nmprodut   AS CHAR                                  NO-UNDO.
     DEF VAR aux_dsnomenc   AS CHAR                                  NO-UNDO.
     DEF VAR aux_nmdindex   AS CHAR                                  NO-UNDO.
     DEF VAR aux_vlaplica   AS DECI                                  NO-UNDO.
     DEF VAR aux_vlsldtot   AS DECI                                  NO-UNDO.
     DEF VAR aux_vlsldrgt   AS DECI                                  NO-UNDO.
     DEF VAR aux_vlrdirrf   AS DECI                                  NO-UNDO.
     DEF VAR aux_percirrf   AS DECI                                  NO-UNDO.
     DEF VAR aux_dtmvtolt   AS CHAR                                  NO-UNDO.
     DEF VAR aux_dtvencto   AS CHAR                                  NO-UNDO.
     DEF VAR aux_qtdiacar   AS INTE                                  NO-UNDO.
     DEF VAR aux_qtdiaapl   AS INTE                                  NO-UNDO.
     DEF VAR aux_txaplica   AS DECI                                  NO-UNDO.
     DEF VAR aux_idblqrgt   AS INTE                                  NO-UNDO.
     DEF VAR aux_dsblqrgt   AS CHAR                                  NO-UNDO.
     DEF VAR aux_dsresgat   AS CHAR                                  NO-UNDO.
     DEF VAR aux_dtresgat   AS CHAR                                  NO-UNDO.
     DEF VAR aux_cdoperad   AS CHAR                                  NO-UNDO.
     DEF VAR aux_nmoperad   AS CHAR                                  NO-UNDO.
     DEF VAR aux_idtxfixa   AS INTE                                  NO-UNDO.
     DEF VAR aux_idtipapl   AS CHAR                                  NO-UNDO.

     /* Variaveis usadas na chamada da pc_gera_impressao_car (gera-impextrda) */
     DEF VAR aux_dtrefere AS DATE NO-UNDO.
     DEF VAR aux_dtreffim AS DATE NO-UNDO.
     DEF VAR aux_inselext AS INTE NO-UNDO.
     
     IF  par_tpmodelo = 1 THEN DO:
         IF  (MONTH(par_dtvctfim) + 1) = 13  THEN
             par_dtvctfim = DATE(1,1,YEAR(par_dtvctfim) + 1).
         ELSE
             par_dtvctfim = DATE(MONTH(par_dtvctfim) + 1,1,YEAR(par_dtvctfim)).

         ASSIGN aux_dtiniper = par_dtvctini
                aux_dtfimper = par_dtvctfim.
     END.
     ELSE DO:
         ASSIGN aux_dtiniper = ?
                aux_dtfimper = ?.
     END.
     

     /* CARREGA A TEMP-TABLE (tt-saldo-rdca) USADA NOS MODELOS(par_tpmodelo) 1 E 3 */
     IF  par_tpmodelo <> 2 THEN 
     DO:
    
         /* Inicializando objetos para leitura do XML */ 
         CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
         CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
         CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
         CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
         CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
        
         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
         
         /* Efetuar a chamada a rotina Oracle */ 
         RUN STORED-PROCEDURE pc_lista_aplicacoes_car
             aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* C�digo da Cooperativa */
                                                  INPUT par_cdoperad, /* C�digo do Operador */
                                                  INPUT par_nmdatela, /* Nome da Tela */
                                                  INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                  INPUT 1,            /* Numero do Caixa */
                                                  INPUT par_nrdconta, /* N�mero da Conta */
                                                  INPUT 1,            /* Titular da Conta */
                                                  INPUT 1,            /* Codigo da Agencia */
                                                  INPUT par_nmdatela, /* Codigo do Programa */
                                                  INPUT par_nraplica, /* N�mero da Aplica��o - Par�metro Opcional */
                                                  INPUT 0,            /* C�digo do Produto � Par�metro Opcional */ 
                                                  INPUT par_dtmvtolt, /* Data de Movimento */
                                                  INPUT 5,            /* Identificador de Consulta (0 � Ativas / 1 � Encerradas / 2 � Todas) */
                                                  INPUT 1,            /* Identificador de Log (0 � N�o / 1 � Sim) */                                                                                                                                  
                                                 OUTPUT ?,            /* XML com informa��es de LOG */
                                                 OUTPUT 0,            /* C�digo da cr�tica */
                                                 OUTPUT "").          /* Descri��o da cr�tica */
        
         /* Fechar o procedimento para buscarmos o resultado */ 
         CLOSE STORED-PROC pc_lista_aplicacoes_car
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
        
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        
         /* Busca poss�veis erros */ 
         ASSIGN aux_cdcritic = 0
                aux_dscritic = ""
                aux_cdcritic = pc_lista_aplicacoes_car.pr_cdcritic 
                               WHEN pc_lista_aplicacoes_car.pr_cdcritic <> ?
                aux_dscritic = pc_lista_aplicacoes_car.pr_dscritic 
                               WHEN pc_lista_aplicacoes_car.pr_dscritic <> ?.
    
    
         IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
         DO:
              CREATE tt-erro.
              ASSIGN tt-erro.cdcritic = aux_cdcritic
                     tt-erro.dscritic = aux_dscritic.
        
              RETURN "NOK".
        
         END.
    
         EMPTY TEMP-TABLE tt-saldo-rdca.
        
         /* Buscar o XML na tabela de retorno da procedure Progress */ 
         ASSIGN xml_req = pc_lista_aplicacoes_car.pr_clobxmlc. 
        
         /* Efetuar a leitura do XML*/ 
         SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
         PUT-STRING(ponteiro_xml,1) = xml_req. 
        
         IF ponteiro_xml <> ? THEN
         DO:
            xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
            xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
            DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:
               xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
               
               IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 
        
               IF xRoot2:NUM-CHILDREN > 0 THEN               
                   CREATE tt-saldo-rdca.     
    
               DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                 xRoot2:GET-CHILD(xField,aux_cont).
        
                 IF xField:SUBTYPE <> "ELEMENT" THEN 
                     NEXT. 
        
                 xField:GET-CHILD(xText,1).
    
                 ASSIGN tt-saldo-rdca.sldresga = DECI(xText:NODE-VALUE) WHEN xField:NAME = "sldresga"
                        tt-saldo-rdca.dssitapl = xText:NODE-VALUE  WHEN xField:NAME = "dssitapl"
                        tt-saldo-rdca.vllanmto = DECI(xText:NODE-VALUE)  WHEN xField:NAME = "vllanmto"
                        tt-saldo-rdca.nraplica = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "nraplica"
                        tt-saldo-rdca.qtdiauti = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "qtdiauti"
                        tt-saldo-rdca.dshistor = xText:NODE-VALUE  WHEN xField:NAME = "dshistor"
                        tt-saldo-rdca.vlaplica = DECI(xText:NODE-VALUE)  WHEN xField:NAME = "vlaplica"
                        tt-saldo-rdca.nrdocmto = xText:NODE-VALUE  WHEN xField:NAME = "nrdocmto"
                        tt-saldo-rdca.cdprodut = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "cdprodut"
                        tt-saldo-rdca.tpaplica = INTE(xText:NODE-VALUE)  WHEN xField:NAME = "tpaplica"
                        tt-saldo-rdca.idtipapl = xText:NODE-VALUE  WHEN xField:NAME = "idtipapl"
                        tt-saldo-rdca.vlsdrdad = DECI(xText:NODE-VALUE)  WHEN xField:NAME = "vlsdrdad"
                        tt-saldo-rdca.dtvencto = DATE(xText:NODE-VALUE)  WHEN xField:NAME = "dtvencto"
                        tt-saldo-rdca.dtmvtolt = DATE(xText:NODE-VALUE)  WHEN xField:NAME = "dtmvtolt"
                        tt-saldo-rdca.qtdiacar = INTE(xText:NODE-VALUE) WHEN xField:NAME = "qtdiacar"
                        tt-saldo-rdca.txaplmax = xText:NODE-VALUE  WHEN xField:NAME = "txaplmax"
                        tt-saldo-rdca.txaplmin = xText:NODE-VALUE  WHEN xField:NAME = "txaplmin"
                        tt-saldo-rdca.dtcarenc = DATE(xText:NODE-VALUE)  WHEN xField:NAME = "dtcarenc"
                        /* aplica��o antiga utilizar campo 'dsaplica' e para nova 'dsnomenc' */
                        tt-saldo-rdca.dsnomenc = xText:NODE-VALUE  WHEN xField:NAME = "dsnomenc"
                        tt-saldo-rdca.dsaplica = xText:NODE-VALUE  WHEN xField:NAME = "dsaplica".

                 VALIDATE tt-saldo-rdca.
    
    
               END. 
        
            END.
    
            SET-SIZE(ponteiro_xml) = 0.
         END.
           
      
         /* VERIFICAR SE EXISTE ALGUMA APLICACAO */
         FIND FIRST tt-saldo-rdca NO-ERROR.
         IF  NOT AVAIL tt-saldo-rdca THEN
            DO:
                ASSIGN aux_cdcritic = 426.
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,          /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
         
         /* VERIFICAR SE EXISTE ALGUMA ALICACAO COM SALDO */
         IF  par_tprelato = 3 THEN DO:
             FIND FIRST tt-saldo-rdca
                  WHERE tt-saldo-rdca.vlsdrdad > 0 NO-ERROR.
             IF  NOT AVAIL tt-saldo-rdca THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = 
                                "Aplica��es Com saldo n�o encontradas no periodo!".
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,          /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
         END.
    
         /* VERIFICAR SE EXISTE ALGUMA ALICACAO SEM SALDO */
         IF  par_tprelato = 4 THEN DO:
             FIND FIRST tt-saldo-rdca
                  WHERE tt-saldo-rdca.vlsdrdad = 0 NO-ERROR.
             IF  NOT AVAIL tt-saldo-rdca THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = 
                                "Aplica��es Sem saldo n�o encontradas no periodo!".
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,          /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
             END.
         END.
         
         /* Aplicacoes Antigas */
         /* Gerar tabela de Extrato de TODAS ou de uma aplicacao Especifica */
         IF  par_nraplica = 0 THEN DO: /* Se informou TODAS no Ayllos Web*/
             
             FOR EACH tt-saldo-rdca NO-LOCK:
                 /* Aplicacoes antigas */
                 IF tt-saldo-rdca.idtipapl <> "N" THEN
                    DO:
                        /* cria handle para aplicacoes antigas */
                        IF  NOT VALID-HANDLE(h-b1wgen0081) THEN
                            RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
                   
                        IF  NOT VALID-HANDLE(h-b1wgen0081) THEN
                        DO: 
                            ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0081.".
                        END.
    
                        RUN consulta-extrato-rdca IN h-b1wgen0081
                                                   ( INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT par_cdoperad,
                                                     INPUT par_nmdatela,
                                                     INPUT par_nrdconta,
                                                     INPUT par_idseqttl,
                                                     INPUT par_dtmvtolt,
                                                     INPUT tt-saldo-rdca.nraplica,
                                                     INPUT 0, /* tpaplica */
                                                     INPUT aux_vlsldapl,
                                                     INPUT ?, /* par_dtvctini, /* dtinicio */*/
                                                     INPUT ?, /* par_dtmvtolt, /* datafim  */ */
                                                     INPUT par_cdprogra,
                                                     INPUT par_idorigem,
                                                     INPUT FALSE, /*flgerlog*/
                                                    OUTPUT TABLE tt-erro,
                                                    OUTPUT TABLE tt-extr-rdca).
    
                        IF  VALID-HANDLE(h-b1wgen0081) THEN
                            DELETE PROCEDURE h-b1wgen0081.        
                        
                        IF  RETURN-VALUE <> "OK" THEN
                            RETURN "NOK".     
    
                    END.
                 /* Novas aplicacaoes */
                 ELSE
                    DO:
                        RUN busca_extrato_aplicacao(INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                    INPUT par_idseqttl,
                                                    INPUT par_dtmvtolt,
                                                    INPUT tt-saldo-rdca.nraplica,
                                                    OUTPUT TABLE tt-extr-rdca,
                                                    OUTPUT aux_cdcritic,
                                                    OUTPUT aux_dscritic).
        
                        IF  aux_cdcritic <> 0 OR
                            aux_dscritic <> "" THEN
                           DO:
                               RUN gera_erro (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT 1,            /** Sequencia **/
                                              INPUT aux_cdcritic,
                                              INPUT-OUTPUT aux_dscritic).
                               RETURN "NOK".
                           END.
            
                    END.
                     
                 FOR EACH tt-extr-rdca:
                    CREATE tt-extr-apl.
                    BUFFER-COPY tt-extr-rdca TO tt-extr-apl.
                 END.
                 EMPTY TEMP-TABLE tt-extr-rdca.
             END.
         END.
         ELSE DO: /* Informou um Nr de Aplicacao no Ayllos Web */
    
             FIND FIRST tt-saldo-rdca WHERE tt-saldo-rdca.nraplica = par_nraplica NO-ERROR.
             
             IF  NOT AVAIL tt-saldo-rdca THEN
                 DO:
                    ASSIGN aux_cdcritic = 426
                           aux_dscritic = " ".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                 END.
    
             IF  tt-saldo-rdca.idtipapl <> "N" THEN
                 DO:
    
                     /* cria handle para aplicacoes antigas */
                     IF  NOT VALID-HANDLE(h-b1wgen0081) THEN
                         RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
        
                     IF  NOT VALID-HANDLE(h-b1wgen0081) THEN
                     DO: 
                         ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0081.".
                     END.
    
                     RUN consulta-extrato-rdca IN h-b1wgen0081
                                                ( INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT par_cdoperad,
                                                  INPUT par_nmdatela,
                                                  INPUT par_nrdconta,
                                                  INPUT par_idseqttl,
                                                  INPUT par_dtmvtolt,
                                                  INPUT par_nraplica,
                                                  INPUT 0, /* tpaplica */
                                                  INPUT aux_vlsldapl,
                                                  INPUT par_dtvctini, /* dtinicio */
                                                  INPUT par_dtmvtolt, /* datafim  */
                                                  INPUT par_cdprogra,
                                                  INPUT par_idorigem,
                                                  INPUT FALSE, /*flgerlog*/
                                                 OUTPUT TABLE tt-erro,
                                                 OUTPUT TABLE tt-extr-rdca).
    
                     IF  VALID-HANDLE(h-b1wgen0081) THEN
                         DELETE PROCEDURE h-b1wgen0081.
                     
                     IF  RETURN-VALUE <> "OK" THEN
                         RETURN "NOK".
    
                 END.
             ELSE
                DO:
                    RUN busca_extrato_aplicacao(INPUT par_cdcooper,  
                                                 INPUT par_cdoperad,  
                                                 INPUT par_nmdatela,  
                                                 INPUT par_nrdconta,  
                                                 INPUT par_idseqttl,  
                                                 INPUT par_dtmvtolt,  
                                                 INPUT par_nraplica,  
                                                 OUTPUT TABLE tt-extr-rdca,
                                                 OUTPUT aux_cdcritic, 
                                                 OUTPUT aux_dscritic).
                                                 
                    IF  aux_cdcritic <> 0 OR
                        aux_dscritic <> "" THEN
                        DO:
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            RETURN "NOK".
                        END.
    
    
                END.
         END.
    
         FOR EACH tt-extr-apl no-lock:
             CREATE tt-extr-rdca.
             BUFFER-COPY tt-extr-apl TO tt-extr-rdca.
         END.

     END. /* IF  par_tpmodelo <> 2 */
            
     /* tprelato: 1-Todos/2-Especifico/3-ComSaldo/4-SemSaldo */
     IF  par_tpmodelo = 1 THEN 
     DO: /* Demonstrativo Aplicacao*/
         RUN gera_impressao_demonstrativo ( INPUT par_cdcooper, 
                                            INPUT par_nrdconta,
                                            INPUT par_dsiduser,
                                            INPUT par_idorigem,
                                            INPUT par_dtvctini,
                                            INPUT par_dtvctfim,
                                            INPUT par_tprelato,
                                            INPUT par_nraplica,
                                            INPUT par_dtmvtolt,
                                           INPUT TABLE tt-saldo-rdca,
                                           INPUT TABLE tt-extr-rdca,
                                           OUTPUT aux_nmarqimp,
                                           OUTPUT aux_nmarqpdf,
                                           OUTPUT TABLE tt-demonstrativo,
                                           OUTPUT TABLE tt-erro
                                           ).
     END.
     ELSE IF par_tpmodelo = 2 THEN 
     DO: /* Extrato Analitico */ 
        EMPTY TEMP-TABLE tt-erro.

        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dscritic = ""
               aux_cdcritic = 0.
    
        /* Data referencia ini */
        IF par_dtvctini <> ? THEN
            ASSIGN aux_dtrefere = par_dtvctini.
        ELSE
            ASSIGN aux_dtrefere = par_dtmvtolt.
    
        /* Data referencia fim */
        IF par_dtvctfim <> ? THEN
            ASSIGN aux_dtreffim = par_dtvctfim.
        ELSE
            ASSIGN aux_dtreffim = par_dtmvtolt.
    

        IF par_nraplica = 0 THEN
           ASSIGN aux_inselext = 2.
        ELSE
           ASSIGN aux_inselext = 0.

        FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK.

        /* Inicializando objetos para leitura do XML */ 
        CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
        CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
        CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
        CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
        CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
    
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

        /* Efetuar a chamada a rotina Oracle */ 
        RUN STORED-PROCEDURE pc_gera_impressao_car
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* C�digo da Cooperativa */
                                                 INPUT par_cdagenci, /* Codigo da Agencia */
                                                 INPUT par_nrdcaixa, /* Numero do Caixa */
                                                 INPUT par_idorigem, /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                 INPUT par_nmdatela, /* Nome da Tela */
                                                 INPUT par_dtmvtolt, /* Data de Movimento */
                                                 INPUT crapdat.dtmvtopr, /* Data Proximo Movimento */
                                                 INPUT par_cdprogra, /* Codigo do Programa */
                                                 INPUT par_inproces, /* Indicador Processo */
                                                 INPUT par_cdoperad, /* C�digo do Operador */
                                                 INPUT par_dsiduser, /* Identificador Usuario */
                                                 INPUT 1,            /* Flag Executar */
                                                 INPUT par_nrdconta, /* N�mero da Conta */
                                                 INPUT par_idseqttl, /* Sequencial do Titular */
                                                 INPUT 4,            /* Tipo de Extrato */
                                                 INPUT aux_dtrefere, /* Data de Referencia */
                                                 INPUT aux_dtreffim, /* Data Referencia Final */
                                                 INPUT 0,            /* Indicador Cobra tarifa */
                                                 INPUT aux_inselext, /* Indicador Relatorio Extrato */
                                                 INPUT par_tprelato, /* Indicador Selecao Extrato */
                                                 INPUT 0,            /* Numero Contrato Emprestimo */
                                                 INPUT par_nraplica, /* Numero Aplicacao */
                                                 INPUT 0,            /* Ano de Referencia */
                                                 INPUT 1,            /* Escreve erro Log */
                                                 INPUT aux_intpextr, /* Tipo de extrato (1=Simplificado, 2=Detalhado) */ 
                                                 INPUT 0,            /* Tipo do Informe PJ => 0-Anual / 1-Trimestral */
                                                 INPUT 1,            /* Trimestre PJ 1-Jan-Mar / 2-Abr-Jun / 3-Jul-Set / 4-Out-Dez */
                                                 OUTPUT "",          /* pr_nmarqimp */
                                                 OUTPUT "",          /* pr_nmarqpdf */
                                                 OUTPUT "").         /* pr_des_reto */
                
        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_gera_impressao_car
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    
        /* Busca poss�veis erros */ 
        ASSIGN aux_dscritic = ""
               aux_nmarqimp = pc_gera_impressao_car.pr_nmarqimp
               aux_nmarqpdf = pc_gera_impressao_car.pr_nmarqpdf
               aux_dscritic = pc_gera_impressao_car.pr_des_reto
                              WHEN pc_gera_impressao_car.pr_des_reto <> ?.
    
        IF aux_dscritic <> "OK" THEN
            DO:
                 CREATE tt-erro.
                 ASSIGN tt-erro.cdcritic = 1
                        tt-erro.dscritic = aux_dscritic.

                 RETURN "NOK".
            END.
                
     END.
     ELSE IF par_tpmodelo = 3 THEN 
     DO: /* Extrato Sintetico */
        RUN gera_impressao_sintetico ( INPUT par_cdcooper,
                                       INPUT par_nrdconta,
                                       INPUT par_dsiduser,
                                       INPUT par_dtvctini,
                                       INPUT par_tprelato,
                                       INPUT par_nraplica,
                                       INPUT par_dtmvtolt,
                                      INPUT TABLE tt-saldo-rdca,
                                      INPUT TABLE tt-extr-rdca,
                                      OUTPUT aux_nmarqimp,
                                      OUTPUT aux_nmarqpdf,
                                      OUTPUT TABLE tt-erro).

     END.

     FIND FIRST tt-erro no-lock no-error.
     IF AVAIL tt-erro THEN
        RETURN "NOK".
     ELSE
        RETURN "OK".


END PROCEDURE.


/***************************************************************************/

PROCEDURE gera_impressao_sintetico:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtvctini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tprelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-saldo-rdca.
    DEF  INPUT PARAM TABLE FOR tt-extr-rdca.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR          aux_nmendter AS CHAR                           NO-UNDO.
    DEF VAR          aux_contador AS INT                            NO-UNDO.
    DEF VAR          aux_nmarqimp AS CHAR                           NO-UNDO.
    DEF VAR          aux_nmarqpdf AS CHAR                           NO-UNDO.
    DEF VAR          aux_returnvl AS CHAR                           NO-UNDO.
    DEF VAR          aux_lshistor AS CHAR                           NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.


    FORM "Conta/DV:"                             AT 01
         crapass.nrdconta  FORMAT "zzzz,zzz,9"   AT 12
         "-"                                     AT 23
         crapass.nmprimtl  FORMAT "x(40)"        AT 25
         SKIP(2)
         WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 80 FRAME f_header.

    FORM tt-extr-rdca.dtmvtolt  AT  1 FORMAT "99/99/9999"  LABEL "DATA"
         tt-extr-rdca.dshistor  AT 12 FORMAT "x(17)"       LABEL "HISTORICO"
         tt-extr-rdca.nrdocmto  AT 30 FORMAT "zzz,zz9"     LABEL "DOCMTO"
         tt-saldo-rdca.dtvencto AT 38 FORMAT "99/99/9999"  LABEL "DT. VENCTO"
         tt-saldo-rdca.dtcarenc AT 49 FORMAT "99/99/9999"  LABEL "DT. CAR"
         tt-saldo-rdca.qtdiauti AT 60 FORMAT "zzz9"        LABEL "CARENCIA"
         tt-saldo-rdca.vlsdrdad AT 69 FORMAT "zzzz,zz9.99" LABEL "SALDO"
         tt-saldo-rdca.sldresga AT 81 FORMAT "zzzz,zz9.99" LABEL "SALDO RESG"
         WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 91 
            FRAME f_dados_relat_sintetico.

    FORM SKIP(2)
         "Saldo disponivel para resgate:"                 AT  01
         tot_sldresga  FORMAT "z,zzz,zz9.99"              AT  46
         WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 80 FRAME f_footer_total.

    ASSIGN aux_vlblqjud = 0
           aux_vlresblq = 0.

    /*** Busca Saldo Bloqueado Judicial ***/
    IF  NOT VALID-HANDLE(h-b1wgen0155) THEN
        RUN sistema/generico/procedures/b1wgen0155.p 
            PERSISTENT SET h-b1wgen0155.
    
    RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT 0, /* nrcpfcgc */
                                             INPUT 1, /* 1 - Bloqueio  */
                                             INPUT 2, /* 2 - Aplicacao */
                                             INPUT par_dtmvtolt,
                                             OUTPUT aux_vlblqjud,
                                             OUTPUT aux_vlresblq).
    
    IF  VALID-HANDLE(h-b1wgen0155) THEN
        DELETE PROCEDURE h-b1wgen0155.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper
                   AND crapass.nrdconta = par_nrdconta 
               NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
           ASSIGN aux_cdcritic = 9.
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT 1,
                          INPUT 1,
                          INPUT 1,          /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
    END.

    FIND FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.


    ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop +
                          "/rl/" + par_dsiduser.
    
    UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
    
    ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
           aux_nmarqimp = aux_nmendter + ".ex"
           aux_nmarqpdf = aux_nmendter + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 82.

    /** Configura a impressora para 1/8" **/
    PUT STREAM str_1 CONTROL "\022\024\033\120\0330\033x0" NULL.
            
    /* Cdempres = 11 , Relatorio 88 em 80 colunas */
    { sistema/generico/includes/b1cabrelvar.i }
    { sistema/generico/includes/b1cabrel080.i "11" "624" }


    DISPLAY STREAM str_1 
            crapass.nrdconta
            crapass.nmprimtl WITH FRAME f_header.

    ASSIGN  tot_sldresga = 0
            aux_lshistor = "113,176,473,528".

    FOR EACH crapcpc NO-LOCK:
        ASSIGN aux_lshistor = aux_lshistor + "," +
                              STRING(crapcpc.cdhsnrap) + "," + 
                              STRING(crapcpc.cdhsraap).
    END.
    FOR EACH tt-saldo-rdca NO-LOCK
       WHERE ( (par_tprelato = 1 OR par_tprelato = 2)            OR
               (par_tprelato = 3 AND tt-saldo-rdca.vlsdrdad > 0) OR
               (par_tprelato = 4 AND tt-saldo-rdca.vlsdrdad = 0)
              )
        BREAK BY tt-saldo-rdca.nraplica
              BY tt-saldo-rdca.dtmvtolt:
        FIND FIRST tt-extr-rdca NO-LOCK
             WHERE (tt-extr-rdca.nraplica = tt-saldo-rdca.nraplica
               AND CAN-DO(aux_lshistor,STRING(tt-extr-rdca.cdhistor)))
               OR  (tt-extr-rdca.indebcre = "1")
           NO-ERROR.

        IF  AVAIL tt-extr-rdca THEN DO:

            DISPLAY STREAM str_1 tt-extr-rdca.dtmvtolt 
                                 tt-extr-rdca.dshistor 
                                 tt-extr-rdca.nrdocmto 
                                 tt-saldo-rdca.dtvencto
                                 tt-saldo-rdca.dtcarenc
                                 tt-saldo-rdca.qtdiauti
                                 tt-saldo-rdca.vlsdrdad
                                 tt-saldo-rdca.sldresga
                      WITH FRAME f_dados_relat_sintetico.
            DOWN WITH FRAME f_dados_relat_sintetico.
        END.

         tot_sldresga =  tot_sldresga +  tt-saldo-rdca.sldresga.

    END.
        
    /** FIM Processamento do Extrato **/
    DISPLAY STREAM str_1 
            tot_sldresga WITH FRAME f_footer_total.

    IF  aux_vlblqjud > 0 THEN
        DO: 
            PUT STREAM str_1
                "Valor Bloqueado Judicialmente e de R$: "
                aux_vlblqjud FORMAT "zzz,zzz,zzz,zz9.99"
                SKIP.
        END.

    OUTPUT STREAM str_1 CLOSE.

    DO WHILE TRUE:

        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
            SET h-b1wgen0024.

        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0024.".
                LEAVE.
            END.


        RUN envia-arquivo-web IN h-b1wgen0024
            ( INPUT par_cdcooper,
              INPUT 1, /* cdagenci */
              INPUT 1, /* nrdcaixa */
              INPUT aux_nmarqimp,
             OUTPUT aux_nmarqpdf,
             OUTPUT TABLE tt-erro ).

        IF  VALID-HANDLE(h-b1wgen0024)  THEN
             DELETE PROCEDURE h-b1wgen0024.

        IF  RETURN-VALUE <> "OK" THEN
            RETURN "NOK".

        ASSIGN aux_returnvl = "OK".

        par_nmarqpdf = aux_nmarqpdf.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

END PROCEDURE.

/***************************************************************************/

PROCEDURE gera_impressao_demonstrativo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvctini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvctfim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tprelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-saldo-rdca.
    DEF  INPUT PARAM TABLE FOR tt-extr-rdca.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-demonstrativo.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF VAR          aux_nmendter AS CHAR                           NO-UNDO.
    DEF VAR          aux_nmarqimp AS CHAR                           NO-UNDO.
    DEF VAR          aux_nmarqpdf AS CHAR                           NO-UNDO.
    DEF VAR          aux_returnvl AS CHAR                           NO-UNDO.

    DEF VAR          aux_mesextra AS CHAR
        INIT "JAN,FEV,MAR,ABR,MAI,JUN,JUL,AGO,SET,OUT,NOV,DEZ"      NO-UNDO.
    DEF VAR          aux_dsmesext AS CHAR EXTENT 14                 NO-UNDO.
    DEF VAR          aux_dtmvtini AS DATE                           NO-UNDO.
    DEF VAR          aux_dtmvtfim AS DATE                           NO-UNDO.
    
    DEF BUFFER crabcop FOR crapcop.

    EMPTY TEMP-TABLE tt-demonstrativo.

    /** DEFINICAO FORMS/FRAMES **/
    FORM "Conta/DV:"                             AT 01
         crapass.nrdconta  FORMAT "zzzz,zzz,9"   AT 12
         "-"                                     AT 23
         crapass.nmprimtl  FORMAT "x(40)"        AT 25
         SKIP(2)
         WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 234 FRAME f_header.


    FORM "\033\107APLICACAO:"                        AT 01
         tt-demonstrativo.nraplica FORMAT "zzz,zz9"  AT 13
         " \033\110"
         SKIP
         WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 234 FRAME f_head_aplic.

    FORM aux_dsmesext[1]       FORMAT "x(8)"      AT   1
         aux_dsmesext[2]       FORMAT "x(8)"      AT 061
         aux_dsmesext[3]       FORMAT "x(8)"      AT 076
         aux_dsmesext[4]       FORMAT "x(8)"      AT 091
         aux_dsmesext[5]       FORMAT "x(8)"      AT 106
         aux_dsmesext[6]       FORMAT "x(8)"      AT 121
         aux_dsmesext[7]       FORMAT "x(8)"      AT 136
         aux_dsmesext[8]       FORMAT "x(8)"      AT 151
         aux_dsmesext[9]       FORMAT "x(8)"      AT 166   
         aux_dsmesext[10]      FORMAT "x(8)"      AT 181
         aux_dsmesext[11]      FORMAT "x(8)"      AT 196
         aux_dsmesext[12]      FORMAT "x(8)"      AT 211
         aux_dsmesext[13]      FORMAT "x(8)"      AT 226
/*         aux_dsmesext[14]      FORMAT "x(8)"      AT 232*/
         SKIP
         WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 234 FRAME f_head_colunas.

    FORM tt-demonstrativo.vlcolu14  FORMAT "x(14)"         AT 001 NO-LABEL
         tt-demonstrativo.vlcolu15  FORMAT "x(20)"         AT 018 NO-LABEL
         tt-demonstrativo.dstplanc  FORMAT "x(10)"         AT 044 NO-LABEL
         tt-demonstrativo.vlcolu01  FORMAT "zz,zzz,zz9.99" AT 056 NO-LABEL
         tt-demonstrativo.vlcolu02  FORMAT "zz,zzz,zz9.99" AT 071 NO-LABEL
         tt-demonstrativo.vlcolu03  FORMAT "zz,zzz,zz9.99" AT 086 NO-LABEL
         tt-demonstrativo.vlcolu04  FORMAT "zz,zzz,zz9.99" AT 101 NO-LABEL
         tt-demonstrativo.vlcolu05  FORMAT "zz,zzz,zz9.99" AT 116 NO-LABEL
         tt-demonstrativo.vlcolu06  FORMAT "zz,zzz,zz9.99" AT 131 NO-LABEL
         tt-demonstrativo.vlcolu07  FORMAT "zz,zzz,zz9.99" AT 146 NO-LABEL
         tt-demonstrativo.vlcolu08  FORMAT "zz,zzz,zz9.99" AT 161 NO-LABEL
         tt-demonstrativo.vlcolu09  FORMAT "zz,zzz,zz9.99" AT 176 NO-LABEL
         tt-demonstrativo.vlcolu10  FORMAT "zz,zzz,zz9.99" AT 191 NO-LABEL
         tt-demonstrativo.vlcolu11  FORMAT "zz,zzz,zz9.99" AT 206 NO-LABEL
         tt-demonstrativo.vlcolu12  FORMAT "zz,zzz,zz9.99" AT 221 NO-LABEL
/*         tt-demonstrativo.vlcolu13  FORMAT "zz,zzz,zz9.99" AT 237 NO-LABEL*/
         SKIP                                                            
       WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 234 FRAME f_dados_colunas.

    ASSIGN aux_vlblqjud = 0
           aux_vlresblq = 0.

    /*** Busca Saldo Bloqueado Judicial ***/
    IF  NOT VALID-HANDLE(h-b1wgen0155) THEN
        RUN sistema/generico/procedures/b1wgen0155.p 
            PERSISTENT SET h-b1wgen0155.
    
    RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT 0, /* nrcpfcgc */
                                             INPUT 1, /* 1 - Bloqueio  */
                                             INPUT 2, /* 2 - Aplicacao */
                                             INPUT par_dtmvtolt,
                                             OUTPUT aux_vlblqjud,
                                             OUTPUT aux_vlresblq).
    
    IF  VALID-HANDLE(h-b1wgen0155) THEN
        DELETE PROCEDURE h-b1wgen0155.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper
                   AND crapass.nrdconta = par_nrdconta 
               NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
           ASSIGN aux_cdcritic = 9.
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT 1,
                          INPUT 1,
                          INPUT 1,          /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
    END.

    /** PROCESSAMENTO **/
    ASSIGN aux_dtmvtini = par_dtvctini
           aux_dtmvtfim = par_dtvctini
           aux_dtmvtolt = DATE(MONTH(par_dtmvtolt),1,YEAR(par_dtmvtolt))
           aux_nrsequen = 0.

    DO  WHILE ((aux_dtmvtini <= par_dtvctfim) AND /* LIMITE DATA FIM    */
               (aux_nrsequen < 12 )           AND /* LIMITE DE 12 MESES */
               (aux_dtmvtini <= aux_dtmvtolt)     /* LIMITE MES ATUAL   */
              ):

        ASSIGN aux_nrsequen = aux_nrsequen + 1.

        IF (MONTH(aux_dtmvtini) + 1) = 13  THEN
            aux_dtmvtfim = DATE(1,1,YEAR(aux_dtmvtini) + 1).
        ELSE
            aux_dtmvtfim = DATE(MONTH(aux_dtmvtini) + 1,1,YEAR(aux_dtmvtini)).
            
        assign aux_dtmvtfim = aux_dtmvtfim - 1.
        
        RUN pi_monta_demonstrativo (INPUT par_cdcooper,
                                    INPUT par_nrdconta,
                                    INPUT aux_dtmvtini,
                                    INPUT aux_dtmvtfim,
                                    INPUT par_tprelato,
                                    INPUT par_nraplica).


        ASSIGN aux_dsmesext[aux_nrsequen + 1] = 
                      STRING(ENTRY(MONTH(aux_dtmvtini),aux_mesextra,","))
                      + "/" + 
                      STRING(YEAR(aux_dtmvtini)).

        IF (MONTH(aux_dtmvtini) + 1) = 13  THEN
            aux_dtmvtini = DATE(1,1,YEAR(aux_dtmvtini) + 1).
        ELSE
            aux_dtmvtini = DATE(MONTH(aux_dtmvtini) + 1,1,YEAR(aux_dtmvtini)).
    END.

    /* TOTALIZA AREA DE TOTAIS */
    /* PARA CADA LINHA DE INFORMACAO, TOTALIZA SALDO TOTAL */
    FOR EACH bt-saldo-demonst NO-LOCK
       WHERE bt-saldo-demonst.nraplica < 999999
       BREAK BY bt-saldo-demonst.idsequen:

        /* POSICIONA O BUFFER NOS REGISTROS DE TOTAIS */
        FIND FIRST tt-demonstrativo
             WHERE tt-demonstrativo.nraplica = 999999
               AND tt-demonstrativo.idsequen = bt-saldo-demonst.idsequen
           EXCLUSIVE-LOCK NO-ERROR.

        ASSIGN tt-demonstrativo.vlcolu01 = 
                       tt-demonstrativo.vlcolu01 +
                       bt-saldo-demonst.vlcolu01
               tt-demonstrativo.vlcolu02 = 
                       tt-demonstrativo.vlcolu02 +
                       bt-saldo-demonst.vlcolu02
               tt-demonstrativo.vlcolu03 = 
                       tt-demonstrativo.vlcolu03 +
                       bt-saldo-demonst.vlcolu03
               tt-demonstrativo.vlcolu04 = 
                       tt-demonstrativo.vlcolu04 +
                       bt-saldo-demonst.vlcolu04
               tt-demonstrativo.vlcolu05 = 
                       tt-demonstrativo.vlcolu05 +
                       bt-saldo-demonst.vlcolu05
               tt-demonstrativo.vlcolu06 = 
                       tt-demonstrativo.vlcolu06 +
                       bt-saldo-demonst.vlcolu06
               tt-demonstrativo.vlcolu07 = 
                       tt-demonstrativo.vlcolu07 +
                       bt-saldo-demonst.vlcolu07
               tt-demonstrativo.vlcolu08 = 
                       tt-demonstrativo.vlcolu08 +
                       bt-saldo-demonst.vlcolu08
               tt-demonstrativo.vlcolu09 = 
                       tt-demonstrativo.vlcolu09 +
                       bt-saldo-demonst.vlcolu09
               tt-demonstrativo.vlcolu10 = 
                       tt-demonstrativo.vlcolu10 +
                       bt-saldo-demonst.vlcolu10
               tt-demonstrativo.vlcolu11 = 
                       tt-demonstrativo.vlcolu11 +
                       bt-saldo-demonst.vlcolu11
               tt-demonstrativo.vlcolu12 = 
                       tt-demonstrativo.vlcolu12 +
                       bt-saldo-demonst.vlcolu12
               tt-demonstrativo.vlcolu13 =
                       tt-demonstrativo.vlcolu13 +
                       bt-saldo-demonst.vlcolu13.
    END.

    IF  par_idorigem = 3  THEN DO: /* INTERNET BANK. */
        RETURN "OK".
    END.

    FIND FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop +
                          "/rl/" + par_dsiduser.
    
    UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
    
    ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
           aux_nmarqimp = aux_nmendter + ".ex"
           aux_nmarqpdf = aux_nmendter + ".pdf".

    /* PROCESAMENTO E SAIDA DO RELATORIO */
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 64.
   
    /** Configura a impressora para 1/8" **/
    PUT STREAM str_1 CONTROL "\022\024\033\120\0330\033x0" NULL.

    { sistema/generico/includes/b1cabrelvar.i }
    { sistema/generico/includes/b1cabrel234.i "11" "622" }


    DISPLAY STREAM str_1 
            crapass.nrdconta
            crapass.nmprimtl WITH FRAME f_header.

    /* AREA DE DADOS DAS APLICACOES */
    FOR EACH tt-demonstrativo NO-LOCK
        WHERE tt-demonstrativo.nraplica <> 999999
        BREAK BY tt-demonstrativo.nraplica
              BY tt-demonstrativo.idsequen:

        IF  FIRST-OF(tt-demonstrativo.nraplica) THEN DO:

            IF  LINE-COUNTER(str_1) > 57 THEN
                DO:
                    PAGE STREAM str_1.
                    DISPLAY STREAM str_1 
                        crapass.nrdconta
                        crapass.nmprimtl WITH FRAME f_header.
                END.

            
            DISPLAY STREAM str_1 tt-demonstrativo.nraplica
                WITH FRAME f_head_aplic.

            DISPLAY STREAM str_1 aux_dsmesext[1]  aux_dsmesext[2]
                                 aux_dsmesext[3]  aux_dsmesext[4]
                                 aux_dsmesext[5]  aux_dsmesext[6]
                                 aux_dsmesext[7]  aux_dsmesext[8]
                                 aux_dsmesext[9]  aux_dsmesext[10]
                                 aux_dsmesext[11] aux_dsmesext[12]
                                 aux_dsmesext[13]
                WITH FRAME f_head_colunas.

        END.

        /* DISP CONDICIONADO - SE HOUVER VALOR, EXIBE COLUNA */
        DISPLAY STREAM str_1
            tt-demonstrativo.vlcolu14
            tt-demonstrativo.vlcolu15
            tt-demonstrativo.dstplanc
            tt-demonstrativo.vlcolu01  WHEN aux_nrsequen >= 1
            tt-demonstrativo.vlcolu02  WHEN aux_nrsequen >= 2
            tt-demonstrativo.vlcolu03  WHEN aux_nrsequen >= 3
            tt-demonstrativo.vlcolu04  WHEN aux_nrsequen >= 4
            tt-demonstrativo.vlcolu05  WHEN aux_nrsequen >= 5
            tt-demonstrativo.vlcolu06  WHEN aux_nrsequen >= 6
            tt-demonstrativo.vlcolu07  WHEN aux_nrsequen >= 7
            tt-demonstrativo.vlcolu08  WHEN aux_nrsequen >= 8
            tt-demonstrativo.vlcolu09  WHEN aux_nrsequen >= 9
            tt-demonstrativo.vlcolu10  WHEN aux_nrsequen >= 10
            tt-demonstrativo.vlcolu11  WHEN aux_nrsequen >= 11
            tt-demonstrativo.vlcolu12  WHEN aux_nrsequen >= 12
           WITH FRAME f_dados_colunas.
           DOWN WITH FRAME f_dados_colunas.


        IF  LAST-OF(tt-demonstrativo.nraplica) THEN DO:
            DISPLAY STREAM str_1 "" SKIP.
        END.

    END.
           
    /* AREA DE DADOS DOS TOTAIS DAS APLICACOES */
    aux_dsmesext[1] = "TOTAL".
    FOR EACH tt-demonstrativo NO-LOCK
        WHERE tt-demonstrativo.nraplica = 999999
        BREAK BY tt-demonstrativo.nraplica
              BY tt-demonstrativo.idsequen:

        IF  FIRST-OF(tt-demonstrativo.nraplica) THEN DO:
            DISPLAY STREAM str_1 aux_dsmesext[1]  aux_dsmesext[2]
                                 aux_dsmesext[3]  aux_dsmesext[4]
                                 aux_dsmesext[5]  aux_dsmesext[6]
                                 aux_dsmesext[7]  aux_dsmesext[8]
                                 aux_dsmesext[9]  aux_dsmesext[10]
                                 aux_dsmesext[11] aux_dsmesext[12]
                                 aux_dsmesext[13]
                WITH FRAME f_head_colunas.

        END.

        DISPLAY STREAM str_1 tt-demonstrativo.dstplanc
            tt-demonstrativo.vlcolu01  WHEN aux_nrsequen >= 1
            tt-demonstrativo.vlcolu02  WHEN aux_nrsequen >= 2
            tt-demonstrativo.vlcolu03  WHEN aux_nrsequen >= 3
            tt-demonstrativo.vlcolu04  WHEN aux_nrsequen >= 4
            tt-demonstrativo.vlcolu05  WHEN aux_nrsequen >= 5
            tt-demonstrativo.vlcolu06  WHEN aux_nrsequen >= 6
            tt-demonstrativo.vlcolu07  WHEN aux_nrsequen >= 7
            tt-demonstrativo.vlcolu08  WHEN aux_nrsequen >= 8
            tt-demonstrativo.vlcolu09  WHEN aux_nrsequen >= 9
            tt-demonstrativo.vlcolu10  WHEN aux_nrsequen >= 10
            tt-demonstrativo.vlcolu11  WHEN aux_nrsequen >= 11
            tt-demonstrativo.vlcolu12  WHEN aux_nrsequen >= 12
            tt-demonstrativo.vlcolu14
            tt-demonstrativo.vlcolu15
                WITH FRAME f_dados_colunas.                                   
           DOWN WITH FRAME f_dados_colunas.           

    END.

    IF  aux_vlblqjud > 0 THEN
        DO: 
            PUT STREAM str_1
                SKIP(1)
                "Valor Bloqueado Judicialmente e de R$: "
                aux_vlblqjud FORMAT "zzz,zzz,zzz,zz9.99"
                SKIP.
        END.

    /** FIM Processamento do Extrato **/       

    OUTPUT STREAM str_1 CLOSE.

    DO WHILE TRUE:

        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
            SET h-b1wgen0024.

        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0024.".
                LEAVE.
            END.
        
        RUN envia-arquivo-web IN h-b1wgen0024
            ( INPUT par_cdcooper,
              INPUT 1, /* cdagenci */
              INPUT 1, /* nrdcaixa */
              INPUT aux_nmarqimp,
             OUTPUT aux_nmarqpdf,
             OUTPUT TABLE tt-erro ).

        IF  VALID-HANDLE(h-b1wgen0024)  THEN
             DELETE PROCEDURE h-b1wgen0024.

        IF  RETURN-VALUE <> "OK" THEN
            RETURN "NOK".

        ASSIGN aux_returnvl = "OK".

        par_nmarqpdf = aux_nmarqpdf.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

END PROCEDURE.

/***************************************************************************/

PROCEDURE pi_monta_demonstrativo:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtfim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tprelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nraplica AS INTE                           NO-UNDO.

    DEF          VAR aux_vlrsaldo AS DECI                           NO-UNDO.
    DEF          VAR aux_vlsldapl AS DECI                           NO-UNDO.
    DEF          VAR aux_vlsaldos AS DECI                           NO-UNDO.
    DEF          VAR aux_idsequen AS INT                            NO-UNDO.
    DEF          VAR aux_dstplanc AS CHAR                           NO-UNDO.
    DEF          VAR aux_dstpapli AS CHAR                           NO-UNDO.
    DEF          VAR aux_txaplica AS CHAR                           NO-UNDO.
    DEF          VAR aux_flgaplic AS LOGI                           NO-UNDO.
    DEF          VAR aux_lshistor AS CHAR                           NO-UNDO.
    DEF          VAR aux_cdhsrdap AS CHAR                           NO-UNDO.
    DEF          VAR aux_cdhsprap AS CHAR                           NO-UNDO.
    DEF          VAR aux_cdhsrgap AS CHAR                           NO-UNDO.
    DEF          VAR aux_cdhsirap AS CHAR                           NO-UNDO.
    DEF          VAR aux_cdhsrvap AS CHAR                           NO-UNDO.

    IF  aux_nrsequen = 1 THEN DO:

        /** CRIAR LINHAS PARA A AREA DE TOTAL FINAL **/
        /* LINHA 1 - TOTAL */
        CREATE tt-demonstrativo.
        ASSIGN tt-demonstrativo.nraplica = 999999
               tt-demonstrativo.idsequen = 1
               tt-demonstrativo.dstplanc = "APLICADO".
        /* LINHA 2 */
        CREATE tt-demonstrativo.
        ASSIGN tt-demonstrativo.nraplica = 999999
               tt-demonstrativo.idsequen = 2
               tt-demonstrativo.dstplanc = "PROVISAO".
        /* LINHA 3 */
        CREATE tt-demonstrativo.
        ASSIGN tt-demonstrativo.nraplica = 999999
               tt-demonstrativo.idsequen = 3
               tt-demonstrativo.dstplanc = "RESGATE".
        /* LINHA 4 */
        CREATE tt-demonstrativo.
        ASSIGN tt-demonstrativo.nraplica = 999999
               tt-demonstrativo.idsequen = 4
               tt-demonstrativo.dstplanc = "REVERSAO".
        /* LINHA 5 */
        CREATE tt-demonstrativo.
        ASSIGN tt-demonstrativo.nraplica = 999999
               tt-demonstrativo.idsequen = 5
               tt-demonstrativo.dstplanc = "RENDIMENTO".
        /* LINHA 6 */
        CREATE tt-demonstrativo.
        ASSIGN tt-demonstrativo.nraplica = 999999
               tt-demonstrativo.idsequen = 6
               tt-demonstrativo.dstplanc = "IR".
        /* LINHA 7 */
        CREATE tt-demonstrativo.
        ASSIGN tt-demonstrativo.nraplica = 999999
               tt-demonstrativo.idsequen = 7
               tt-demonstrativo.dstplanc = "SALDO".

    END.
    
    FOR EACH crapcpc NO-LOCK:
        ASSIGN aux_lshistor = aux_lshistor + "," +
                              STRING(crapcpc.cdhsnrap) + "," + 
                              STRING(crapcpc.cdhsraap)
               aux_cdhsrdap = aux_cdhsrdap + "," +
                              STRING(crapcpc.cdhsrdap)
               aux_cdhsprap = aux_cdhsprap + "," + 
                              STRING(crapcpc.cdhsprap)
               aux_cdhsrgap = aux_cdhsrgap + "," +
                              STRING(crapcpc.cdhsrgap) + "," + STRING(crapcpc.cdhsvtap)
               aux_cdhsirap = aux_cdhsirap + "," +
                              STRING(crapcpc.cdhsirap)
               aux_cdhsrvap = aux_cdhsrvap + "," +
                              STRING(crapcpc.cdhsrvap).
    END.
    FOR EACH tt-saldo-rdca NO-LOCK 
       WHERE ( (par_tprelato = 1 OR par_tprelato = 2)            OR
               (par_tprelato = 3 AND tt-saldo-rdca.vlsdrdad > 0) OR
               (par_tprelato = 4 AND tt-saldo-rdca.vlsdrdad = 0)
              )
        BREAK BY tt-saldo-rdca.nraplica:

        IF  FIRST-OF(tt-saldo-rdca.nraplica) THEN DO:

            IF  aux_nrsequen = 1 THEN DO:

                ASSIGN tot_sldresga = tot_sldresga + tt-saldo-rdca.sldresga.

                /** CRIAR CADA LINHA PARA CADA APLICACAO **/

                /* LINHA 1 */
                CREATE tt-demonstrativo.
                ASSIGN tt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       tt-demonstrativo.idsequen = 1
                       tt-demonstrativo.dstplanc = "APLICADO"
                       tt-demonstrativo.vlcolu14 = "TIPO" 
                       tt-demonstrativo.vlcolu15 = IF  tt-saldo-rdca.idtipapl <> "A" THEN /* APLIC. NOVA */
                                                    FILL(" ", 20 - LENGTH(TRIM(tt-saldo-rdca.dsnomenc))) + tt-saldo-rdca.dsnomenc
                                                   ELSE 
                                                    FILL(" ", 20 - LENGTH(TRIM(tt-saldo-rdca.dsaplica))) + tt-saldo-rdca.dsaplica.
                /* LINHA 2 */
                CREATE tt-demonstrativo.
                ASSIGN tt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       tt-demonstrativo.idsequen = 2
                       tt-demonstrativo.dstplanc = "PROVISAO"
                       tt-demonstrativo.vlcolu14 = "VALOR APLICADO"
                       tt-demonstrativo.vlcolu15 = STRING(tt-saldo-rdca.vlaplica,"z,zzz,zzz,zzz,zz9.99").


                /* LINHA 3 */
                CREATE tt-demonstrativo.
                ASSIGN tt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       tt-demonstrativo.idsequen = 3
                       tt-demonstrativo.dstplanc = "RESGATE"
                       tt-demonstrativo.vlcolu14 = "APLICACAO"
                       tt-demonstrativo.vlcolu15 = 
                          IF  tt-saldo-rdca.dtmvtolt = ? THEN
                              ""
                          ELSE
                           FILL(" ", 20 - LENGTH(STRING(tt-saldo-rdca.dtmvtolt,"99/99/9999"))) +
                                                 STRING(tt-saldo-rdca.dtmvtolt,"99/99/9999").

                
                /* LINHA 4 */
                CREATE tt-demonstrativo.
                ASSIGN tt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       tt-demonstrativo.idsequen = 4
                       tt-demonstrativo.dstplanc = "REVERSAO"
                       tt-demonstrativo.vlcolu14 = IF tt-saldo-rdca.qtdiauti = ? THEN "" ELSE "CARENCIA".
                       tt-demonstrativo.vlcolu15 = 
                          IF  tt-saldo-rdca.qtdiauti = ? THEN
                              ""
                          ELSE
                              FILL(" ", 20 - LENGTH(STRING(tt-saldo-rdca.qtdiauti,"zzz9") + " Dia(s)")) +
                                                 STRING(tt-saldo-rdca.qtdiauti,"zzz9") + " Dia(s)". 
                                        
                
                /* LINHA 5 */
                CREATE tt-demonstrativo.
                ASSIGN tt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       tt-demonstrativo.idsequen = 5
                       tt-demonstrativo.dstplanc = "RENDIMENTO"
                       tt-demonstrativo.vlcolu14 = IF tt-saldo-rdca.dtcarenc = ? THEN "" ELSE "DT. CARENCIA".
                       tt-demonstrativo.vlcolu15 = 
                          IF  tt-saldo-rdca.dtcarenc = ? THEN
                              ""
                          ELSE
                           FILL(" ", 20 -
                           LENGTH(STRING(tt-saldo-rdca.dtcarenc,"99/99/9999")))
                           +  STRING(tt-saldo-rdca.dtcarenc,"99/99/9999").           

                /* LINHA 6 */
                IF  tt-saldo-rdca.dsaplica <> "RDCPRE" THEN DO:
                    IF  tt-saldo-rdca.dtvencto = ? THEN
                        ASSIGN aux_dstpapli = ""
                               aux_txaplica = "".
                    ELSE
                        ASSIGN aux_dstpapli = "VENCIMENTO"
                               aux_txaplica = 
                                   STRING(tt-saldo-rdca.dtvencto,"99/99/9999").
                END.
                ELSE
                    ASSIGN aux_dstpapli = ""
                           aux_txaplica = "".
                CREATE tt-demonstrativo.
                ASSIGN tt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       tt-demonstrativo.idsequen = 6
                       tt-demonstrativo.dstplanc = "IR"
                       tt-demonstrativo.vlcolu14 = aux_dstpapli
                       tt-demonstrativo.vlcolu15 = 
                                         FILL(" ",20 - LENGTH(aux_txaplica)) + 
                                         aux_txaplica.

                /* LINHA 7 */
                IF  tt-saldo-rdca.dsaplica <> "RDCPRE" THEN DO:
                    IF  tt-saldo-rdca.txaplmax = "" OR tt-saldo-rdca.txaplmax = ? THEN
                        ASSIGN aux_dstpapli = ""
                               aux_txaplica = "".
                    ELSE
                        ASSIGN aux_dstpapli = "TAXA CONTRAT."
                               aux_txaplica = tt-saldo-rdca.txaplmax.
                END.
                ELSE
                    ASSIGN aux_dstpapli = ""
                           aux_txaplica = "".
                CREATE tt-demonstrativo.
                ASSIGN tt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       tt-demonstrativo.idsequen = 7
                       tt-demonstrativo.dstplanc = "SALDO"
                       tt-demonstrativo.vlcolu14 = aux_dstpapli
                       tt-demonstrativo.vlcolu15 = 
                                          FILL(" ",20 - LENGTH(aux_txaplica)) + 
                                          aux_txaplica.

                /* LINHA 8 */
                IF  tt-saldo-rdca.dsaplica <> "RDCPRE" THEN DO: 
                    IF  tt-saldo-rdca.txaplmin = "" OR tt-saldo-rdca.txaplmin = ? OR tt-saldo-rdca.idtipapl = "N" THEN /* APLIC. NOVAS */
                        ASSIGN aux_dstpapli = ""
                               aux_txaplica = "".
                    ELSE
                        ASSIGN aux_dstpapli = "TAXA MINIMA"
                               aux_txaplica = tt-saldo-rdca.txaplmin.
                END.
                ELSE
                    ASSIGN aux_dstpapli = ""
                           aux_txaplica = "".
                CREATE tt-demonstrativo.
                ASSIGN tt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       tt-demonstrativo.idsequen = 8
                       tt-demonstrativo.dstplanc = " "
                       tt-demonstrativo.vlcolu14 = aux_dstpapli
                       tt-demonstrativo.vlcolu15 = 
                                          FILL(" ",20 - LENGTH(aux_txaplica)) + 
                                          aux_txaplica.

                /* LINHA 9 */
                CREATE tt-demonstrativo.
                ASSIGN tt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       tt-demonstrativo.idsequen = 9
                       tt-demonstrativo.dstplanc = " "
                       tt-demonstrativo.vlcolu14 = "SALDO RESGATE"
                       tt-demonstrativo.vlcolu15 = 
                            STRING(tt-saldo-rdca.sldresga,"z,zzz,zzz,zzz,zz9.99").

            END.

        END. /* END do FIRST-OF nraplica*/


        IF  aux_nrsequen = 1 THEN DO:

            FIND FIRST tt-demonstrativo
                 WHERE tt-demonstrativo.nraplica = 999999
                   AND tt-demonstrativo.idsequen = 7
                   AND tt-demonstrativo.dstplanc = "SALDO" 
                EXCLUSIVE-LOCK NO-ERROR.

            ASSIGN tt-demonstrativo.vlcolu14 = "SALDO RESGATE"
                   tt-demonstrativo.vlcolu15 = 
                      STRING(tot_sldresga,"zz,zzz,zz9.99").
        END.
                    
        /** Processamento dos dados do extrato **/
        FOR EACH tt-extr-rdca NO-LOCK
           WHERE tt-extr-rdca.nraplica  = tt-saldo-rdca.nraplica
             AND tt-extr-rdca.dtmvtolt >= par_dtmvtini
             AND tt-extr-rdca.dtmvtolt <= par_dtmvtfim
             BREAK BY tt-extr-rdca.nraplica:

            IF  FIRST-OF(tt-extr-rdca.nraplica) THEN DO:

                ASSIGN aux_vlrsaldo = 0
                       aux_vlsldapl = 0
                       aux_vlsaldos = 0
                       aux_flgaplic = FALSE
                       aux_dstplanc = "".

                /* ATUALIZA O SALDO INICIAL P/ CADA PERIODO **/

                /* PEGA VALOR LANCTO TIPO "APLICACAO" */
                IF  CAN-DO("113,176,473,528" + aux_lshistor, STRING(tt-extr-rdca.cdhistor)) THEN DO:

                    ASSIGN aux_vlrsaldo = tt-extr-rdca.vllanmto
                           aux_vlsldapl = tt-extr-rdca.vllanmto. 
                        /* Guarda saldo para usar quando mes fim incompleto */
                END.
                ELSE DO:

                /** RETORNA SALDO INICIAL DO PERIODO - 1a LINHA DA COLUNA **/
                    IF  CAN-DO("116,179,475,532" + aux_cdhsrdap, STRING(tt-extr-rdca.cdhistor)) THEN DO:

                        ASSIGN aux_vlrsaldo    = tt-extr-rdca.vlsldapl.

                    END.
                    ELSE DO:
                        IF  tt-extr-rdca.indebcre = "C" THEN
                            aux_vlrsaldo = tt-extr-rdca.vlsldapl - 
                                           tt-extr-rdca.vllanmto.
                        ELSE
                            aux_vlrsaldo = tt-extr-rdca.vlsldapl + 
                                           tt-extr-rdca.vllanmto.
                    END.
                    aux_vlsaldos = aux_vlsaldos + aux_vlrsaldo.
                END.

                /* POSICIONAR NO REGISTRO "APLICADO" */
                FIND FIRST tt-demonstrativo EXCLUSIVE-LOCK
                     WHERE tt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       AND tt-demonstrativo.idsequen = 1
                       AND tt-demonstrativo.dstplanc = "APLICADO"
                    NO-ERROR.

                CASE aux_nrsequen:
                    WHEN  1 THEN
                        ASSIGN tt-demonstrativo.vlcolu01 = aux_vlrsaldo.
                    WHEN  2 THEN
                        ASSIGN tt-demonstrativo.vlcolu02 = aux_vlrsaldo.
                    WHEN  3 THEN
                        ASSIGN tt-demonstrativo.vlcolu03 = aux_vlrsaldo.
                    WHEN  4 THEN
                        ASSIGN tt-demonstrativo.vlcolu04 = aux_vlrsaldo.
                    WHEN  5 THEN
                        ASSIGN tt-demonstrativo.vlcolu05 = aux_vlrsaldo.
                    WHEN  6 THEN
                        ASSIGN tt-demonstrativo.vlcolu06 = aux_vlrsaldo.
                    WHEN  7 THEN
                        ASSIGN tt-demonstrativo.vlcolu07 = aux_vlrsaldo.
                    WHEN  8 THEN
                        ASSIGN tt-demonstrativo.vlcolu08 = aux_vlrsaldo.
                    WHEN  9 THEN
                        ASSIGN tt-demonstrativo.vlcolu09 = aux_vlrsaldo.
                    WHEN 10 THEN
                        ASSIGN tt-demonstrativo.vlcolu10 = aux_vlrsaldo.
                    WHEN 11 THEN
                        ASSIGN tt-demonstrativo.vlcolu11 = aux_vlrsaldo.
                    WHEN 12 THEN
                        ASSIGN tt-demonstrativo.vlcolu12 = aux_vlrsaldo.
                    WHEN 13 THEN
                        ASSIGN tt-demonstrativo.vlcolu13 = aux_vlrsaldo.
                END CASE.

            END. /* END do IF FIRST-OF (nraplica) */
            ELSE
                aux_flgaplic = FALSE.


            /* CATEGORIZAR OS LANCAMENTOS */
            IF  CAN-DO("117,124,125,180,181,182,474,529" + aux_cdhsprap,STRING(tt-extr-rdca.cdhistor)) THEN DO:
                ASSIGN aux_dstplanc = "PROVISAO".
                
            END.
            ELSE
            IF  CAN-DO("118,126,143,178,183,477,492,493,494,495,534,923,924," +
                       "1111,1112,1113,1114" + aux_cdhsrgap,
                       STRING(tt-extr-rdca.cdhistor)) THEN DO:
                ASSIGN aux_dstplanc = "RESGATE".

            END.
            ELSE
            IF  CAN-DO("463,531" + aux_cdhsrvap,STRING(tt-extr-rdca.cdhistor)) THEN DO:
                ASSIGN aux_dstplanc = "REVERSAO".

            END.
            ELSE
            IF  CAN-DO("116,475,532" + aux_cdhsrdap, /* REMOVIDO HISTORICO 179 */
                       STRING(tt-extr-rdca.cdhistor)) THEN DO:
                ASSIGN aux_dstplanc = "RENDIMENTO".

            END.
            ELSE
            IF  CAN-DO("476,533,861,862,868,871,875,876,877" + aux_cdhsirap, STRING(tt-extr-rdca.cdhistor)) THEN DO:
                ASSIGN aux_dstplanc = "IR".

            END.
            ELSE DO: /* HISTORICO "APLICACAO" JA TRATADO NO FIRST-OF */
                IF  CAN-DO("113,176,473,528",
                       STRING(tt-extr-rdca.cdhistor)) THEN
                    ASSIGN aux_dstplanc = "APLICADO"
                           aux_flgaplic = TRUE.
                ELSE DO:
                    aux_flgaplic = FALSE.
                    NEXT. /* PODE SER ALGUM OUTRO HISTOR. NAO TRATADO */
                END.
            END.
        
            IF  aux_flgaplic = FALSE THEN DO:

                /* POSICIONA TT CONFORME HISTORICO */
                FIND FIRST tt-demonstrativo
                     WHERE tt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       AND tt-demonstrativo.dstplanc = aux_dstplanc
                    EXCLUSIVE-LOCK NO-ERROR.


                /* ATUALIZAR INFORMACOES NA COLUNA CERTA        */
                /* CADA MES QUE PASSA, VAI PARA COLUNA SEGUINTE */
                CASE aux_nrsequen:
                    WHEN  1 THEN DO: /* Coluna  1 */
                        /* SOMA LANCTOS CONFORME HISTORICO */
                        ASSIGN tt-demonstrativo.vlcolu01 =
                               tt-demonstrativo.vlcolu01 +
                               tt-extr-rdca.vllanmto.

                    END.
                    WHEN  2 THEN DO: /* Coluna  2 */
                        /* SOMA LANCTOS CONFORME HISTORICO */
                        ASSIGN tt-demonstrativo.vlcolu02 =
                               tt-demonstrativo.vlcolu02 +
                               tt-extr-rdca.vllanmto.

                    END.
                    WHEN  3 THEN DO: /* Coluna  3 */
                         /* SOMA LANCTOS CONFORME HISTORICO */
                         ASSIGN tt-demonstrativo.vlcolu03 =
                                tt-demonstrativo.vlcolu03 +
                                tt-extr-rdca.vllanmto.
                    END.
                    WHEN  4 THEN DO: /* Coluna  4 */
                        /* SOMA LANCTOS CONFORME HISTORICO */
                        ASSIGN tt-demonstrativo.vlcolu04 =
                               tt-demonstrativo.vlcolu04 +
                               tt-extr-rdca.vllanmto.
                    END.
                    WHEN  5 THEN DO: /* Coluna  5 */
                        /* SOMA LANCTOS CONFORME HISTORICO */
                        ASSIGN tt-demonstrativo.vlcolu05 =
                               tt-demonstrativo.vlcolu05 +
                               tt-extr-rdca.vllanmto.
                    END.
                    WHEN  6 THEN DO: /* Coluna  6 */
                        /* SOMA LANCTOS CONFORME HISTORICO */
                        ASSIGN tt-demonstrativo.vlcolu06 =
                               tt-demonstrativo.vlcolu06 +
                               tt-extr-rdca.vllanmto.
                    END.
                    WHEN  7 THEN DO: /* Coluna  7 */
                        /* SOMA LANCTOS CONFORME HISTORICO */
                        ASSIGN tt-demonstrativo.vlcolu07 =
                               tt-demonstrativo.vlcolu07 +
                                tt-extr-rdca.vllanmto.
                    END.
                    WHEN  8 THEN DO: /* Coluna  8 */
                        /* SOMA LANCTOS CONFORME HISTORICO */
                        ASSIGN tt-demonstrativo.vlcolu08 =
                               tt-demonstrativo.vlcolu08 +
                               tt-extr-rdca.vllanmto.
                    END.
                    WHEN  9 THEN DO: /* Coluna  9 */
                        /* SOMA LANCTOS CONFORME HISTORICO */
                        ASSIGN tt-demonstrativo.vlcolu09 =
                               tt-demonstrativo.vlcolu09 +
                               tt-extr-rdca.vllanmto.
                    END.
                    WHEN 10 THEN DO: /* Coluna 10 */
                        /* SOMA LANCTOS CONFORME HISTORICO */
                        ASSIGN tt-demonstrativo.vlcolu10 =
                               tt-demonstrativo.vlcolu10 +
                               tt-extr-rdca.vllanmto.
                    END.
                    WHEN 11 THEN DO: /* Coluna 11 */
                        /* SOMA LANCTOS CONFORME HISTORICO */
                        ASSIGN tt-demonstrativo.vlcolu11 =
                               tt-demonstrativo.vlcolu11 +
                               tt-extr-rdca.vllanmto.
                    END.
                    WHEN 12 THEN DO: /* Coluna 12 */
                        /* SOMA LANCTOS CONFORME HISTORICO */
                        ASSIGN tt-demonstrativo.vlcolu12 =
                               tt-demonstrativo.vlcolu12 +
                               tt-extr-rdca.vllanmto.
                    END.
                    WHEN 13 THEN DO: /* Coluna 13 */
                        /* SOMA LANCTOS CONFORME HISTORICO */
                        ASSIGN tt-demonstrativo.vlcolu13 =
                               tt-demonstrativo.vlcolu13 +
                               tt-extr-rdca.vllanmto.
                    END.

                END CASE.

                ASSIGN aux_vlsaldos = aux_vlsaldos + tt-extr-rdca.vllanmto.
                
            END. /* END do IF  aux_flgaplic */

            IF  LAST-OF(tt-extr-rdca.nraplica) THEN DO:

                /* ATUALIZA O SALDO FINAL PARA CADA PERIODO */
                ASSIGN aux_vlrsaldo = 0.
                FIND FIRST tt-demonstrativo EXCLUSIVE-LOCK
                     WHERE tt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       AND tt-demonstrativo.idsequen = 7
                       AND tt-demonstrativo.dstplanc = "SALDO"
                    NO-ERROR.

                IF  aux_vlsaldos = 0 THEN
                    aux_vlrsaldo = aux_vlsldapl.
                ELSE
                    aux_vlrsaldo = tt-extr-rdca.vlsldapl.

            
                /* POSICIONAR NO REGISTRO "APLICADO" */
                FIND FIRST bt-demonstrativo EXCLUSIVE-LOCK
                     WHERE bt-demonstrativo.nraplica = tt-saldo-rdca.nraplica
                       AND bt-demonstrativo.idsequen = 1
                       AND bt-demonstrativo.dstplanc = "APLICADO"
                    NO-ERROR.

    
                CASE aux_nrsequen:
                  /* OBS.: A coluna seguinte eh atualizada tambem para
                           que, caso o mes corrente nao tenha valor,
                           fica com o valor do mes anterior, evitando 
                           divergencias no saldo final (Conforme
                           conversado com Ze(Guilherme/Supero)       */
                    WHEN  1 THEN
                        ASSIGN tt-demonstrativo.vlcolu01 = aux_vlrsaldo
                               tt-demonstrativo.vlcolu02 = aux_vlrsaldo
                               bt-demonstrativo.vlcolu02 = aux_vlrsaldo.
                    WHEN  2 THEN
                        ASSIGN tt-demonstrativo.vlcolu02 = aux_vlrsaldo
                               tt-demonstrativo.vlcolu03 = aux_vlrsaldo
                               bt-demonstrativo.vlcolu03 = aux_vlrsaldo.
                    WHEN  3 THEN
                        ASSIGN tt-demonstrativo.vlcolu03 = aux_vlrsaldo
                               tt-demonstrativo.vlcolu04 = aux_vlrsaldo
                               bt-demonstrativo.vlcolu04 = aux_vlrsaldo.
                    WHEN  4 THEN
                        ASSIGN tt-demonstrativo.vlcolu04 = aux_vlrsaldo
                               tt-demonstrativo.vlcolu05 = aux_vlrsaldo
                               bt-demonstrativo.vlcolu05 = aux_vlrsaldo.
                    WHEN  5 THEN
                        ASSIGN tt-demonstrativo.vlcolu05 = aux_vlrsaldo
                               tt-demonstrativo.vlcolu06 = aux_vlrsaldo
                               bt-demonstrativo.vlcolu06 = aux_vlrsaldo.
                    WHEN  6 THEN
                        ASSIGN tt-demonstrativo.vlcolu06 = aux_vlrsaldo
                               tt-demonstrativo.vlcolu07 = aux_vlrsaldo
                               bt-demonstrativo.vlcolu07 = aux_vlrsaldo.
                    WHEN  7 THEN
                        ASSIGN tt-demonstrativo.vlcolu07 = aux_vlrsaldo
                               tt-demonstrativo.vlcolu08 = aux_vlrsaldo
                               bt-demonstrativo.vlcolu08 = aux_vlrsaldo.
                    WHEN  8 THEN
                        ASSIGN tt-demonstrativo.vlcolu08 = aux_vlrsaldo
                               tt-demonstrativo.vlcolu09 = aux_vlrsaldo
                               bt-demonstrativo.vlcolu09 = aux_vlrsaldo.
                    WHEN  9 THEN
                        ASSIGN tt-demonstrativo.vlcolu09 = aux_vlrsaldo
                               tt-demonstrativo.vlcolu10 = aux_vlrsaldo
                               bt-demonstrativo.vlcolu10 = aux_vlrsaldo.
                    WHEN 10 THEN
                        ASSIGN tt-demonstrativo.vlcolu10 = aux_vlrsaldo
                               tt-demonstrativo.vlcolu11 = aux_vlrsaldo
                               bt-demonstrativo.vlcolu11 = aux_vlrsaldo.
                    WHEN 11 THEN
                        ASSIGN tt-demonstrativo.vlcolu11 = aux_vlrsaldo
                               tt-demonstrativo.vlcolu12 = aux_vlrsaldo
                               bt-demonstrativo.vlcolu12 = aux_vlrsaldo.
                    WHEN 12 THEN
                        ASSIGN tt-demonstrativo.vlcolu12 = aux_vlrsaldo
                               tt-demonstrativo.vlcolu13 = aux_vlrsaldo
                               bt-demonstrativo.vlcolu13 = aux_vlrsaldo.
                    WHEN 13 THEN
                        ASSIGN tt-demonstrativo.vlcolu13 = aux_vlrsaldo.
                END CASE.    
                
            END. /* END do IF  LAST-OF (nraplica) */

        END. /* END do FOR EACH tt-extr-rdca */

    END. /* END do FOR EACH tt-saldo-rdca */

END PROCEDURE.


/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/

FUNCTION LockTabela RETURNS CHARACTER PRIVATE ():
/*-----------------------------------------------------------------------------
  Objetivo:  Identifica o usuario que esta locando o registro
     Notas:  
-----------------------------------------------------------------------------*/

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_loginusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdevice AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtconnec AS CHAR                                    NO-UNDO.
    DEF VAR aux_numipusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_mslocktb AS CHAR                                    NO-UNDO.

    ASSIGN aux_mslocktb = "Registro sendo alterado em outro terminal " +
                          "(crapcdv).".

    IF  aux_idorigem = 3  THEN  /** InternetBank **/
        RETURN aux_mslocktb.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN aux_mslocktb.
        
    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapobs),
                                   INPUT "banco",
                                   INPUT "crapobs",
                                  OUTPUT aux_loginusr,
                                  OUTPUT aux_nmusuari,
                                  OUTPUT aux_dsdevice,
                                  OUTPUT aux_dtconnec, 
                                  OUTPUT aux_numipusr).

    DELETE OBJECT h-b1wgen9999.

    ASSIGN aux_mslocktb = aux_mslocktb + " Operador: " + 
                          aux_loginusr + " - " + aux_nmusuari.

    RETURN aux_mslocktb.   /* Function return value. */

END FUNCTION. /* LockTabela */

FUNCTION ValidaDigFun RETURNS LOGICAL PRIVATE
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_cdagenci AS INTEGER,
      INPUT par_nrdcaixa AS INTEGER,
      INPUT par_nrdconta AS INTEGER ):
/*-----------------------------------------------------------------------------
  Objetivo:  Valida o digita verificador
     Notas:  
-----------------------------------------------------------------------------*/

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_vlresult AS LOGICAL     NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    ASSIGN 
        aux_nrdconta = par_nrdconta
        aux_vlresult = TRUE.

    RUN dig_fun IN h-b1wgen9999 
        ( INPUT par_cdcooper,
          INPUT par_cdagenci,
          INPUT par_nrdcaixa,
          INPUT-OUTPUT aux_nrdconta,
         OUTPUT TABLE tt-erro ).
    
    DELETE OBJECT h-b1wgen9999.

    /* verifica se o digito foi informado corretamente */
    IF  RETURN-VALUE <> "OK" THEN
        ASSIGN aux_vlresult = FALSE.

    FIND FIRST tt-erro NO-ERROR.

    IF  AVAILABLE tt-erro THEN
        ASSIGN aux_vlresult = FALSE.

    EMPTY TEMP-TABLE tt-erro.

    IF  aux_nrdconta <> par_nrdconta THEN
        ASSIGN aux_vlresult = FALSE.

   RETURN aux_vlresult.
        
END FUNCTION. /* ValidaDigFun */


/***********************************************************************/
PROCEDURE busca_extrato_aplicacao:

    /* parametros de entrada */
    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper NO-UNDO.
    DEF INPUT PARAM par_cdoperad LIKE crapope.cdoperad NO-UNDO.
    DEF INPUT PARAM par_nmdatela LIKE craptel.nmdatela NO-UNDO.
    DEF INPUT PARAM par_nrdconta LIKE crapcop.nrdconta NO-UNDO.
    DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt NO-UNDO.
    DEF INPUT PARAM par_nraplica LIKE craprac.nraplica NO-UNDO.
    /* parametros de retorno */
    DEF OUTPUT PARAM TABLE FOR tt-extr-rdca.
    DEF OUTPUT PARAM par_cdcritic LIKE crapcri.cdcritic NO-UNDO.
    DEF OUTPUT PARAM par_dscritic LIKE crapcri.dscritic NO-UNDO.


    /* Vari�veis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.


    /* Variaveis retornadas da procedure pc_busca_aplicacoes_car */
    DEF VAR aux_nraplica   AS INTE                                  NO-UNDO.
    DEF VAR aux_cdprodut   AS INTE                                  NO-UNDO.
    DEF VAR aux_nmprodut   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dsnomenc   AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmdindex   AS CHAR                                  NO-UNDO.
    DEF VAR aux_vlaplica   AS DECI                                  NO-UNDO.
    DEF VAR aux_vlsldtot   AS DECI                                  NO-UNDO.
    DEF VAR aux_vlsldrgt   AS DECI                                  NO-UNDO.
    DEF VAR aux_vlrdirrf   AS DECI                                  NO-UNDO.
    DEF VAR aux_percirrf   AS DECI                                  NO-UNDO.
    DEF VAR aux_dtmvtolt   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dtvencto   AS CHAR                                  NO-UNDO.
    DEF VAR aux_qtdiacar   AS INTE                                  NO-UNDO.
    DEF VAR aux_qtdiaapl   AS INTE                                  NO-UNDO.
    DEF VAR aux_txaplica   AS DECI                                  NO-UNDO.
    DEF VAR aux_txlancto   AS DECI                                  NO-UNDO.
    DEF VAR aux_idblqrgt   AS INTE                                  NO-UNDO.
    DEF VAR aux_dsblqrgt   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dsresgat   AS CHAR                                  NO-UNDO.
    DEF VAR aux_dtresgat   AS CHAR                                  NO-UNDO.
    DEF VAR aux_cdoperad   AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmoperad   AS CHAR                                  NO-UNDO.
    DEF VAR aux_idtxfixa   AS INTE                                  NO-UNDO.
    DEF VAR aux_cdagenci   AS INTE                                  NO-UNDO.
    DEF VAR aux_dshistor   AS CHAR                                  NO-UNDO.
    DEF VAR aux_cdhistor   AS INTE                                  NO-UNDO.
    DEF VAR aux_nrdocmto   AS INTE                                  NO-UNDO.
    DEF VAR aux_indebcre   AS CHAR                                  NO-UNDO.
    DEF VAR aux_vllanmto   AS DECI                                  NO-UNDO.


    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 


      /* Efetuar a chamada a rotina Oracle */
     RUN STORED-PROCEDURE pc_busca_extrato_aplicacao_car
     aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper /* C�digo da Cooperativa */
                                         ,INPUT par_cdoperad /* C�digo do Operador */
                                         ,INPUT par_nmdatela /* Nome da Tela */
                                         ,INPUT 1            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                         ,INPUT par_nrdconta /* N�mero da Conta */
                                         ,INPUT par_idseqttl /* Titular da Conta */
                                         ,INPUT par_dtmvtolt /* Data de Movimento */
                                         ,INPUT par_nraplica /* N�mero da Aplica��o */
                                         ,INPUT 1            /* Identificador de Listagem de Todos Hist�ricos (Fixo na chamada, 0 � N�o / 1 � Sim) */
                                         ,INPUT 0            /* Identificador de Log (Fixo na chamada, 0 � N�o / 1 � Sim) */
                                         ,OUTPUT 0           /* Valor de resgate    */
                                         ,OUTPUT 0           /* Valor de rendimento */
                                         ,OUTPUT 0           /* Valor do IRRF       */
                                         ,OUTPUT 0           /* Rendimento no mes   */
                                         ,OUTPUT 0           /* Rendimento total    */
                                         ,OUTPUT 0           /* Valor de aliquota de IR */
                                         ,OUTPUT ?           /* XML com informa��es de LOG*/
                                         ,OUTPUT 0           /* C�digo da cr�tica */
                                         ,OUTPUT "").        /* Descri��o da cr�tica */

     /* Fechar o procedimento para buscarmos o resultado */ 
     CLOSE STORED-PROC pc_busca_extrato_aplicacao_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

     
     { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

     /* Busca poss�veis erros */ 
     ASSIGN aux_cdcritic = 0
            aux_dscritic = ""
            aux_cdcritic = pc_busca_extrato_aplicacao_car.pr_cdcritic 
                           WHEN pc_busca_extrato_aplicacao_car.pr_cdcritic <> ?
            aux_dscritic = pc_busca_extrato_aplicacao_car.pr_dscritic 
                           WHEN pc_busca_extrato_aplicacao_car.pr_dscritic <> ?.


     IF aux_cdcritic > 0 OR 
        aux_dscritic <> "" THEN
     DO:
         ASSIGN par_cdcritic = aux_cdcritic
                par_dscritic = aux_dscritic.

         RETURN "NOK".
     END.

     /* Buscar o XML na tabela de retorno da procedure Progress */ 
     ASSIGN xml_req = pc_busca_extrato_aplicacao_car.pr_clobxmlc.

     /* Efetuar a leitura do XML*/ 
     SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
     PUT-STRING(ponteiro_xml,1) = xml_req. 

     xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
     xDoc:GET-DOCUMENT-ELEMENT(xRoot).

     DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

         xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

         IF xRoot2:SUBTYPE <> "ELEMENT"   THEN 
          NEXT. 

         IF xRoot2:NUM-CHILDREN > 0 THEN
            CREATE tt-extr-rdca.

         DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

             xRoot2:GET-CHILD(xField,aux_cont).

             IF xField:SUBTYPE <> "ELEMENT" THEN 
                 NEXT. 

             xField:GET-CHILD(xText,1).                   

             ASSIGN aux_cdagenci = INTE(xText:NODE-VALUE) WHEN xField:NAME = "cdagenci"                               
                    aux_dtmvtolt = xText:NODE-VALUE WHEN xField:NAME = "dtmvtolt"                               
                    aux_txlancto = DECI(xText:NODE-VALUE) WHEN xField:NAME = "txlancto"
                    aux_cdhistor = INTE(xText:NODE-VALUE) WHEN xField:NAME = "cdhistor"
                    aux_dshistor = xText:NODE-VALUE WHEN xField:NAME = "dshistor"
                    aux_nrdocmto = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrdocmto"
                    aux_indebcre = xText:NODE-VALUE WHEN xField:NAME = "indebcre"
                    aux_vllanmto = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vllanmto"
                    aux_vlsldtot = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsldtot"
                    aux_nraplica = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nraplica".

         END.            

         ASSIGN tt-extr-rdca.dsaplica = STRING(aux_nraplica)
                tt-extr-rdca.dtmvtolt = DATE(aux_dtmvtolt)
                tt-extr-rdca.cdhistor = aux_cdhistor
                tt-extr-rdca.dshistor = STRING(aux_cdhistor, "9999") + "-" + aux_dshistor
                tt-extr-rdca.vllanmto = aux_vllanmto
                tt-extr-rdca.vlsldapl = aux_vlsldtot
                tt-extr-rdca.indebcre = aux_indebcre
                tt-extr-rdca.nrdocmto = aux_nrdocmto
                tt-extr-rdca.cdagenci = aux_cdagenci
                tt-extr-rdca.txaplica = aux_txlancto
                tt-extr-rdca.vlpvlrgt = "0"
                tt-extr-rdca.nraplica = aux_nraplica.

     END.                

     SET-SIZE(ponteiro_xml) = 0. 

     DELETE OBJECT xDoc. 
     DELETE OBJECT xRoot. 
     DELETE OBJECT xRoot2. 
     DELETE OBJECT xField. 
     DELETE OBJECT xText.

END PROCEDURE.


