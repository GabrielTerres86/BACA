
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps594.p                | pc_crps594                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/
/* ............................................................................

   Programa: Fontes/crps594.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Abril/2011                        Ultima atualizacao: 18/12/2013
   
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 5.(Exclusivo)
               Integrar arquivos do BANCO BRASIL de COBRANCA.
               Emite relatorio ....

   Alteracao : 27/06/2011 - Utilizado a glb_dtmvtolt como base para todas as
                            procedures deste fonte. Tratado para nao gerar
                            critica caso seja 'COMPEFORA'. (Fabricio)
                            
               19/07/2011 - Removido campo CNPJ do relatorio analitico e
                            adicionado o campo BCO/AGE. Feito tratamento para
                            listar os motivos para cada ocorrencia.
                            Desmembrado a coluna OUTROS D/C em OUTROS DEB. e
                            OUTROS CRED. (Fabricio)
                            
               27/07/2011 - Alterado o valor da variavel glb_nmformul para
                            "234dh". (Fabricio)
                          - Passado como parametro dtmvtopr para os lanctos
                            na conta do cooperado (Rafael).
                            
               16/08/2011 - Utilizado replace nas rotinas que precisam 
                            converter o nr da conta para numerico (Rafael).
                            
               22/08/2011 - Alterado a coluna "Boleto" para "Nosso Num" e a
                            coluna "Doc Coop" para "N Docto" (Adriano).
                            
               25/08/2011 - No create do cratarq estava faltando glb_cdcooper
                          - Alterado tamanho do frame f_cab e posições dos
                            campos (Rafael).
                            
               13/09/2011 - Utilizado dtmvtopr no lancto das tarifas qdo
                            utilizado grava-retorno 
                          - Ajuste no relatorio crrl594 (Rafael).
                          
               03/10/2011 - Utilizado dtocorre e dtdcredi ao lancar tarifa
                            ao cooperado para fins contabeis. (Rafael).
                            
               18/10/2011 - Ajustes na rotina principal a fim de evitar
                            erros na cadeia. (Rafael).
                          - Ajustes no relatorio crrl594. (Rafael).
                          
               31/10/2011 - Nao tratar ent rejeitada e motivos 39,00,60
                            (Rafael).
                            
               15/12/2011 - Utilizar convenio do header do arquivo pela
                            variavel aux_nrconven. (Rafael).
                          - Incluido rotina de inst de protesto para titulos
                            que estao com o indiaprt = 0. (Rafael).
                            
               23/12/2011 - Alterações para incluir o campo "Tarifa COOP" no
                            relatório 594. (Lucas)
                            
               26/01/2012 - Antes de protestar automaticamente, verificar se 
                            não há instruções de baixa ou sustação. (Rafael)
                            
               16/02/2012 - Adequar o COMPEFORA ao gravar a data do retorno
                            referente a contabilidade. (Rafael)
                            
               08/08/2012 - Ajuste na rotina de liquidacao de titulos
                            descontados da cob. registrada. (Rafael)
                            
               13/12/2012 - Tratamento para titulos das contas migradas
                            (Viacredi -> Alto Vale). Alimentado tabela crapafi
                            para acerto financeiro entre as singulares,
                            por parte da Cecred. (Fabricio)
                            
               11/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                            consulta da craptco (Tiago).             
                            
               23/04/2013 - Adicionar critica 940 no relatorio 594 quando
                            titulos pagos a menor. (Rafael)
                          - Alterado na procedure cria_rejeitados, a atribuicao
                            do campo craprej.nrdocmto; de: = aux_nrdocmto
                            para: = tt-regimp.nrdocmto. (Fabricio)
                            
               13/05/2013 - Tratamento para titulos com entrada confirmada
                            indevida - critica 955. (Rafael)
                            
               04/06/2013 - Ignorar processamento de ent.rejeitada com 
                            motivos "00","39","60" ou "". (Rafael)             
                            
               19/06/2013 - Ajuste nos lanctos de Acerto Financeiro entre 
                            contas migradas BB. (Rafael)
                            
               30/07/2013 - Incluso processo de log com base nas informacoes 
                            da tabela crapcol. (Daniel) 
                            
               08/08/2013 - Retirado leitura da crapcct na procedure
                            "efetiva_atualizacoes_compensacao" e incluso 
                            processo busca tarifa utilizando rotina b1wgen0153.
                            (Daniel) 
                            
               25/09/2013 - Incluso tratamento para assumir historico 969 caso
                            nao encontre historico de tarifa. Incluso tratamento
                            para busca historico de ocorrencia 28 (Daniel).
                            
               26/09/2013 - Incluso parametro tt-lat-consolidada nas chamadas de
                            instrucoes da b1wgen0088 e incluso processo de 
                            lancamento de tarifas consolidadas (Daniel). 
               
               11/10/2013 - Incluido parametro cdprogra para as procedures da
                            b1wgen0153 que carregam dados de tarifa(Tiago).
                            
               21/10/2013 - Incluido novo parametro na chamada da procedure
                            inst-protestar  ref. ao nro do arq remessa (Rafael).
               
               11/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               09/12/2013 - Adicionado "VALIDATE <tabela>" apos o create de 
                            registros nas tabelas. (Rafael).
                            
               18/12/2013 - Tratamento para convenios migrados para todas 
                            as cooperativas. (Rafael)

               04/06/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Alisson - AMcom)
                            
               31/10/2014 - Voltado a versão antes da versão hibrida
                            (progres/oracle) devido a necessidade de correção:
                            Ajuste para quando for registro de entrada 
                            confirmada, apos gerar crapret verificar se cobrança                             
                            85 já foi baixada e gerar instrução de baixa do
                            boleto de protesto.(SD 197217 Odirlei-AMcom)  
               
               05/11/2014 - Projeto 198-Viacon - Incorporacao Concredi e 
                            Credimilsul (Odirlei-AMcom)
                            
               28/11/2014 - Ajustado leitura para verificar se boleto original
                            do boleto protestado ja foi liquidado(Odirlei-Amcom)     
                            
               19/12/2014 - Retirar tratamento para gerar lançamentos na crapafi referente 
                            os lançamentos de contas incorporadas, não é necessario pois 
                            não existe a cooperativa antiga para realizar ajuste financeiro
                            (SD236521 - Odirlei/AMcom)
              
               30/12/2014 - Retirada a critica de entrada não confirmada ao gerar
                            a inst-protestar, visto que ja gera essa informação em relatorio.
                            SD 237716(Odirlei-AMcom)
 
             
............................................................................ */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps594"
       glb_cdcritic = 0
       glb_dscritic = "".
              
RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    RETURN.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps594 aux_handproc = PROC-HANDLE NO-ERROR
   (INPUT glb_cdcooper,
    INPUT glb_nmtelant,
    INPUT glb_cdoperad,
    INPUT INT(STRING(glb_flgresta,"1/0")),
    OUTPUT 0,
    OUTPUT 0,
    OUTPUT 0, 
    OUTPUT "").

IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
        
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps594 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps594.pr_cdcritic WHEN pc_crps594.pr_cdcritic <> ?
       glb_dscritic = pc_crps594.pr_dscritic WHEN pc_crps594.pr_dscritic <> ?
       glb_stprogra = IF pc_crps594.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps594.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
        RETURN.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.

/* .......................................................................... */


