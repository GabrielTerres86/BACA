/* ..........................................................................

   Programa: Fontes/crps385.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes     
   Data    : Marco/2004.                        Ultima atualizacao: 22/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atender a solicitacao 092
               Gerar arquivos de arrecadacao, conforme convenios cadastrados
               Emite relatorio 342.
   Alteracoes : Sequenciar pelo numero do convenio. Arquivos via e_mail , 
                utilizar diretorio micros(Mirtes)

                12/01/2005 - Tratamento SAMAE Timbo (Julio)

                19/01/2005 - Tratamento para IPTU Indaial (Julio)
                
                28/01/2005 - Tratamento para SAMAE GASPAR/CECRED -> 634 (Julio)

                02/05/2005 - Ordenar por PAC e CAIXA (Evandro).
                
                30/05/2005 - Convenio Aguas Itapema -> 456 (Julio)

                06/06/2005 - Preparacao para unificacao de arquivos (Julio)
                
                15/08/2005 - Mandar relatorio por e-mail para Prefeitura 
                             Indaial. Tratamento SAMAE Brusque -> 615 (Julio).

                23/09/2005 - Modificado FIND FIRST para FIND na tabela
                             crapcop.cdcooper = glb_cdcooper (Diego).
                             
                12/01/2006 - Tratamento para P.M.Itajai -> 659 (Julio)
                
                16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                    
                09/08/2006 - Tratamento para P.M.Pomerode -> 663 (Julio) 
                   
                26/10/2006 - Incluir data do movimento nos e-mails (David).
                
                23/11/2006 - Acertar envio de email pela BO b1wgen0011 (David).
                
                27/02/2007 - Apos alteracao do envio de e-mail, estava enviando
                             relatorio em branco para a Prefeitura Intaial (18)
                             (Julio).
                             
                01/06/2007 - Incluido envio de arquivo para Accestage (Elton).
                
                05/06/2007 - Altera numero do convenio no arquivo de caixa da
                             DAE NAVEGANTES para ser diferente do numero de
                             convenio do arquivo de debito automatico (Elton).
                             
                23/08/2007 - Tratamento de tarifas para internet(Guilherme)
                           - Colocado chamada do fontes/fimprg.p para as saidas
                             com RETURN (Evandro).
                
                25/09/2007 - Incluido coluna contendo o PAC onde foi feito o
                             pagamento. Demonstrado no relatorio os totais
                             dos pagamentos feitos pela internet (Elton).
                             
                28/11/2007 - Alterado numero do convenio do arquivo de caixa da
                             SEMASA Itajai para ser diferente do numero de
                             convenio do arquivo de debito automatico (Elton).
                
                30/11/2007 - Alterado numero do convenio do arquivo de caixa da
                             Aguas de Joinville para ser diferente do numero de
                             convenio do arquivo de debito automatico (Elton).
                
                22/01/2008 - IPTU Blumenau passa a ter o mesmo tratamento dos
                             outros convenio (Elton).               
                                                                            
                18/03/2008 - Alterado envio de email para BO b1wgen0011
                             (Sidnei - Precise)
                             
                04/11/2008 - Retirado constante da UF "SC" e colocado campo de
                             arquivo (Martin).
                            
                21/12/2009 - Faturas da CASAN -> 348 pagas no caixa serao 
                             consideradas como pagas na internet (Elton).
                              
                02/06/2010 - Alteração do campo "pkzip25" para "zipcecred.pl" 
                             (Vitor).
                
                11/06/2010 - Incluido tipo de pagamento "2" quando for feito
                             atraves de TAA e no relatorio incluido o valor das 
                             tarifas referente a TAA (Elton).
                
                28/04/2011 - Tratamento para guardar mais um campo de valor 
                             para Foz do Brasil -> 963; 
                           - Alterado numero do convenio do arquivo de caixa 
                             da Aguas de Massaranduba para ser diferente do 
                             numero de convenio do arquivo de debito 
                             automatico (Elton).  

                23/01/2012 - Gravar Tipo Controle na GNCVUNI (Guilherme/Supero)
                
                07/03/2012 - Ajuste na criacao do registro "G".Incluido conforme
                             o layout da FEBRABAN os campos G.11, G12
                             (Adriano).
                
                18/05/2012 - Mostra somente 20 caracteres no relatorio 
                             crrl342.lst no campo sequencial quando valor tiver 
                             mais de 20 caracteres (Elton).
                             
                22/06/2012 - Substituido gncoper por crapcop (Tiago).
                
                02/07/2012 - Alterado nomeclatura do relatório gerado incluindo 
                             código do convênio (Guilherme Maba).
                             
                30/07/2012 - Ajuste do format no campo nmrescop (David Kruger).
                
                18/09/2012 - Tratamento para codigo febraban da Aguas de 
                             Itapocoroy (Elton).
                             
                31/10/2012 - Modificacao na agencia arrecadadora e na 
                             autenticacao do arquivo de arrecadacao (Elton).
                
                16/08/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (André Euzébio - Supero).
                             
                12/11/2013 - Alterado totalizador de PAs de 99 para 999.
                             (Reinert)       
                             
                22/01/2014 - Incluir VALIDATE gncvuni, gncontr (Lucas R.)
                
                
                07/04/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                             procedure (Andre Santos - SUPERO)
                
.............................................................................*/

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps385"
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

RUN STORED-PROCEDURE pc_crps385 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps385 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps385.pr_cdcritic WHEN pc_crps385.pr_cdcritic <> ?
       glb_dscritic = pc_crps385.pr_dscritic WHEN pc_crps385.pr_dscritic <> ?
       glb_stprogra = IF pc_crps385.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps385.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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