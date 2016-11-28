/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps647.p                | pc_crps647                        |
  +---------------------------------+-----------------------------------+
  
   TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 04/MAR/2015 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA  (CECRED)
   - MARCOS MARTINI      (SUPERO)

******************************************************************************/
/* ..........................................................................

Programa: Fontes/crps647.p
Sistema : Conta-Corrente - Cooperativa de Credito
Sigla   : CRED
Autora  : Lucas R.
Data    : Setembro/2013                        Ultima atualizacao: 08/11/2016

Dados referentes ao programa:

Frequencia: Diario (Batch).
Objetivo  : Integrar Arquivos de debitos de consorcios enviados pelo SICREDI.
            Emite relatorio 661 e 673.

Alteracoes: 27/11/2013 - Incluido o RUN do fimprg no final do programa e onde 
                         a glb_cdcritic <> 0 antes do return. (Lucas R.)
                         
            10/12/2013 - Alterado crapndb.dtmvtolt para armazenar data de 
                         vencimneto do debito, (aux_setlinha,45,8).
                       - Substituido glb_dtmvtoan por glb_dtmvtolt (Lucas R.)
                       
            11/12/2013 - Ajustes na gravacao da crapndb para gravar posicao
                         70,60 (Lucas R.)
                         
            14/01/2014 - Alteracao referente a integracao Progress X 
                         Dataserver Oracle 
                         Inclusao do VALIDATE ( Andre Euzebio / SUPERO)       
                         
            20/01/2014 - Na critica 182 substituir NEXT por 
                         "RUN fontes/fimprg.p RETURN".
                       - Mover IF  glb_cdcritic <> 0 THEN RETURN para logo apos
                         o run fontes/iniprg.p. (Lucas R.)
                         
            12/02/2014 - Ajustes para importar arquivo de debito automatico
                         junto com o de consorcios - Softdesk 128107 (Lucas R)
                         
            18/02/2014 - Alterado craptab.cdacesso = "LOTEINT031" para
                         craptab.cdacesso = "LOTEINT032" - Softdesk 131871 
                         (Lucas R.)
                         
            04/04/2014 - Retirado craptab do LOTEINT032 e substituido por
                         aux_nrdolote = 6650.
                       - Na craplau adicionado ao create o campo cdempres 
                         (Lucas R)
                         
            23/05/2014 - incluido nas consultas da craplau
                         craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                         
            03/10/2014 - Alterado lo/proc_batch para log/proc_message.log
                         (Lucas R./Elton)             
                         
            24/03/2015 - Criada a function verificaUltDia e chamada sempre
                         que for criado um registro na crapndb ou craplau
                         (SD245218 - Tiago)
                         
            30/03/2015 - Alterado gravacao da crapass.cdagenci quando nao 
                         encontrar PA, na critica 961 (Lucas R. #265513)
                         
            08/04/2015 - Adicionado a data na frente do log do proc_message
                         (Tiago).             
                                                 
                        06/05/2015 - Retirado a gravacao do campo nrcrcard na tabela
                         craplau pois havia problemas de conversao com os 
                         dados que estavam vindo do arquivo FUT e este dado
                         acabava nao sendo usado posteriormente
                         SD282057 (Tiago/Fabricio).
                         
            14/08/2015 - Ajustes na busca de arquivos no diretorio do Connect.
                         (Chamado 276157) - (Fabricio)
                         
            04/09/2015 - Incluir validacao caso o cooperado esteja demitido 
                         (Lucas Ranghetti #324974)
                         
            21/09/2015 - Ajustes no processamento dos arquivos.
                         Gerar quoter em outro diretorio pois o diretorio do
                         Connect no Unix eh um mapeamento do servidor Connect
                         Windows e acontecem alguns problemas ao trabalhar com
                         arquivos dentro deste mapeamento. 
                         (Chamado 276157) - (Fabricio)
                         
            18/01/2016 - Ajuste na leitura da tabela CRAPCNS (consorcio) para
                         filtrar tambem pela conta Sicredi (quando um cooperado
                         possui duas contas e migra o consorcio de uma conta
                         para outra, o n. do contrato nao se altera e, como
                         o CPF eh o mesmo da falha no FIND porque retorna dois
                         registros). (Chamado 377579) - (Fabricio)
                         
            25/01/2016 - Incluido crapatr.dtfimatr = ? na verificacao da autorizacao,
                         pois autorizacao nao pode estar cancelada ao efetuar 
                         agendamento (Ranghetti #389327)
                         
            29/01/2016 - Incluir craplau.insitlau = 1 na busca do registro para 
                         cancelamento(Ranghetti #384817)
                       - Adicionar crapass para uma temp-table para ganhar performace
                         na execucao do programa (Ranghetti/Elton)
                         
            19/05/2016 - Incluido ajuste para notificar cooperado qnd valor 
                         da fatura ultrapassar limite definido 
                         PRJ320 - Oferta DebAut (Odirlei-AMcom)  

            20/05/2016 - Incluido nas consultas da craplau
                         craplau.dsorigem <> "TRMULTAJUROS". (Jaison/James)
                            
            25/07/2016 - Se for o convenio 045, 14 BRT CELULAR - FEBRABAN e referencia conter 
                         um hifen no final, iremos despresar este hifen e seguir normalmente 
                         com o programa (Lucas Ranghetti #453337)
             
            03/08/2016 - Incluir crapndb para a critica 103 (Lucas Ranghetti #490987)
             
            14/09/2016 - Ajuste para somente verificar valor maximo para debito
                         caso lancamento nao seja de Consorcio (J5).
                         (Chamado 519962) - (Fabrício)
                            
            27/09/2016 - Ajuste para somente criar crapndb se nao for os registros "C" e "D"
                         (Lucas Ranghetti #507171)
                                                 
            08/11/2016 - Conversao Progress >> PLSQL (Jonata - Mouts)                                                 
                            
............................................................................*/

{ includes/var_batch.i}  
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps647"
       glb_progerad = "647".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " +
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    RETURN.
END.
ERROR-STATUS:ERROR = FALSE.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps647 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
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

CLOSE STORED-PROCEDURE pc_crps647 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps647.pr_cdcritic WHEN pc_crps647.pr_cdcritic <> ?
       glb_dscritic = pc_crps647.pr_dscritic WHEN pc_crps647.pr_dscritic <> ?
       glb_stprogra = IF pc_crps647.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps647.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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