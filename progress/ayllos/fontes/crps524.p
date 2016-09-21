/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps524.p                | pc_crps524                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/










/* ............................................................................
      
   Programa: Fontes/crps524.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Paulo
   Data    : Junho/2009                         Ultima alteracao: 09/12/2013
   
   Dados referentes ao programa:

   Frequencia: Mensal 
   Objetivo  : Gerar base informacoes gerenciais dos produtos

   Alteracoes:
               23/09/2009 - Precise - Paulo - criados campos novos de
                            beneficios, seguros, e cartoes

               06/10/2009 - Precise Guilherme - Tratar dados REDECARD(444)

               27/10/2009 - Alterado para utilizar a BO b1wgen0045.p que sera
                            agrupadora das funcoes compartilhadas com o CRPS524
                            Guilherme - Precise

               18/02/2010 - Alterar nome do handle (Magui).
               
               09/04/2010 - Incluido valores para os campos novos da tabela 
                            crapgpr (Elton).
               
               11/05/2010 - Incluido valores para o novo campo
                            crapgpr.qtassrda (Irlan).
                            
               13/05/2010 - Incluido novo parametro na procedure 
                            valor-convenios (Elton).
               
               19/05/2010 - Incluido novos campos na tabela crapgpr
                            (qtasunet e qtasucxa)
                            (Irlan)
                
               17/06/2010 - Incluido novos campos(Desc.Cheque, Desc. Titulo,
                            Pagamentos TAA).(Irlan) 
               
               15/07/2010 - alterado forma de consulta dos campos qtassoci e
                            qtasscot. Buscar informação da CRAPGER.(Irlan)
                            
               19/08/2010 - Incluido os campos de Depositos no TAA 
                            qtdepcxa e vldepcxa (Irlan).
                            
               31/08/2010 - Incluido novo campo em Participações: qtchcomp 
                            Quantidade de Cheques Compensados
                            (Irlan).
                            
               01/09/2010 - Incluido informações de Caixa On-line
                            qttiponl e qtchconl (Irlan).
                            
               18/10/2010 - Alterado forma de busca dos dados partindo da 
                            tabela crapass;
                          - Acertado informações de cobrança trazendo dados
                            para cada PAC;
                          - Incluido indice na Temp-Table tt-participacao 
                            (Elton).
                            
               28/10/2010 - Inclusão do historico 918(Saque) devido ao 
                            TAA compartilhado (Henrique).
                            
               15/03/2011 - Inclusao das variaveis ret_vlcancel e 
                            ret_qtcancel na chamada da procedure 
                            limite-cartao-credito (Vitor)

               23/05/2011 - Inclusao historico 376-Transferencia TAA(Mirtes)
               
               13/09/2011 - Incluido Cobranca Registrada e DDA (Adriano).
               
               18/10/2011 - Movido rotina carrega-dda para b1wgen0087 (Rafael).
               
               10/11/2011 - Ajuste no for each do crapcob (Gabriel).
               
               17/01/2012 - Separar leitura de titulos por emissao dos
                            titulos pagos. (Rafael)
                            
               14/02/2012 - Separar leitura de acessos unicos à internet e
                            extratos emitidos. (Rafael)
                            
               20/03/2012 - Subistituido o parametro aux_qtassaut pela table
                            crawass na chamada da procedure valor-convenios
                            (Adriano).
                           
               25/04/2012 - Incluido novo parametro na chamada da  procedure
                            limite-cartao-credito.(David Kruger).
                            
               12/06/2012 - Implementação de melhorias.(David Kruger).
               
               14/08/2012 - Remoção do historico 920, e inclusão do historico 555
                            para uso na internet, incluido somatoria de TED
                            (Lucas R.).
                            
               21/02/2013 - Alteração nos parametros da procedure de seguros
                            (David Kruger).

                           25/03/2013 - Armazenar valores sobre a transferencia 
                            intercooperativa (Gabriel). 
                            
               09/04/2013 - Ajuste de desempenho (Gabriel).             
               
               09/05/2013 - Ajuste de totalização da cobranca BB. (Rafael)
               
               27/11/2013 - Ajustes para migracao da Acredicoop e tratamento
                            para considerar movimentacoes de contas demitidas
                            (Evandro).
                            
               09/12/2013 - Ajustar posicao da flag flg_qtasscob (David).
               
............................................................................ */

{includes/var_batch.i "NEW"}
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps524"
       glb_cdcritic = 0
       glb_dscritic = "".
       
RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

    QUIT.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps524 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),                                     
    INPUT glb_cdagenci,
    INPUT glb_cdoperad,
    INPUT glb_nmdatela,
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
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps524 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps524.pr_cdcritic WHEN pc_crps524.pr_cdcritic <> ?
       glb_dscritic = pc_crps524.pr_dscritic WHEN pc_crps524.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps524.pr_stprogra = 1 THEN 
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps524.pr_infimsol = 1 THEN 
                          TRUE 
                      ELSE 
                          FALSE. 

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

