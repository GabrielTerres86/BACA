
/* ..........................................................................

   Programa: Fontes/crps386.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio/Mirtes
   Data    : Abril/2004                    Ultima atualizacao: 27/05/2014

   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Gerar arquivo de atualizacao de cadastro de debito em conta
               para convenios
               Solicitacao : 086
               Ordem do programa na solicitacao = 1.
               Exclusividade = 2
               Relatorio 343.

   Alteracao : 29/09/2004 - Tratamento para o convenio 5 - CELESC CECRED
                            (Julio)

               03/11/2004 - Tratamento para o convenio 15 - VIVO (Julio) 
               
               26/11/2004 - Tratamento para convenio 16 - SAMAE TIMBO (Julio)

               30/11/2004 - Cooperativa 1, nunca vai com "9001" na frente do
                            numero da conta (Julio)

               07/01/2005 - Tamanho do codigo de referencia para convenio 15
                            deve ser igual a 11 (Julio)
                            
               26/01/2005 - Tratamento para SAMAE GASPAR CECRED (Julio)
                            
               02/02/2005 - Tratamento SAMAE BLUMENAU CECRED (Julio)
               
               22/04/2005 - Tratamento UNIMED (Julio)

               30/05/2005 - Tratamento Aguas Itapema -> 24 (Julio)

               24/08/2005 - Tratamento Samae Brusque -> 25 / 616 (Julio)
               
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               20/10/2005 - Tratamento Samae Pomerode -> 26 / 619 (Julio)
               
               12/01/2006 - Tratamento para email's em branco (Julio)
               
               12/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               13/10/2006 - Tratamento para CELESC Distribuicao -> 30 (Julio)
               
               24/11/2006 - Acertar envio de email pela BO b1wgen0011 (David).
               
               27/11/2006 - Restringir envio de email para convenio 28 - Unimed
                            (Elton).
               
               02/02/2007 - Tratamento para DAE Navegantes -> 31 (Elton).
               
               31/05/2007 - Restringir envio de arquivo contendo autorizacoes
                            de debito para convenio 32 - Uniodonto (Elton).
               
               01/06/2007 - Incluido possibilidade de envio de arquivo para
                            Accestage (Elton).
               
               19/11/2007 - Tratamento para Aguas de Joinville -> 33 (Elton).
               
               26/11/2007 - Tratamento para SEMASA Itajai -> 34 (Elton).
               
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "for each" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               01/07/2008 - Alterados "finds e for eachs" para buscar o codigo
                            da cooperativa atraves da variavel "glb_cdcooper"
                            nas tabelas genericas. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               15/08/2008 - Tratamento para o convenio SAMAE Jaragua -> 9
                            (Diego).
               
               26/02/2009 - Acerto na leitura da tabela gncooper, campo
                            cdcooper (Diego).
               
               16/10/2009 - Restringir envio de arquivo de autorizacoes para
                            convenio 38 - Unimed Planalto Norte e convenio 43 -
                            Servmed (Elton).
                            
               11/05/2010 - Tratamento para convenio 45 - Aguas Pres. Getulio;
                          - Tratamento para convenio 48 - TIM Celular (Elton).
                            
               01/10/2010 - Tratamento para Samae Rio Negrinho -> 49 (Elton).
               
               05/04/2011 - Tratamento para CERSAD -> 51;
                          - Tratamento para Foz do Brasil -> 53;
                          - Tratamento para Aguas de Massaranduba -> 54 (Elton).

               27/01/2012 - Tratamento para Unificacao Arq. Convenios
                            (Guilherme/Supero)
                            
               22/06/2012 - Substituido gncoper por crapcop (Tiago).
               
               02/07/2012 - Alterado nomeclatura do relatório gerado incluindo 
                            código do convenio (Guilherme Maba).
                            
               02/08/2012 - Acerto para convenios com arquivos unificados que 
                            utilizam a Nexxera, para enviar somente o arquivo 
                            unificado para a van (Elton).
                            
               09/10/2012 - Tratamento para executar o programa todos os dias 
                            (Elton).
               
               31/07/2013 - Melhorias no código fonte e envio da informacao da 
                            agencia da cooperativa na Cecred no arquivo de 
                            inclusoes (Elton).
                            
               22/01/2014 - Incluir VALIDATE gncvuni, gncontr (Lucas R.) 
                         
               27/05/2014 - Migracao PROGRESS/ORACLE - Alterado para executar
                            a nova procedure no Oracle (Daniel - Supero)
..............................................................................*/
{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }


ASSIGN glb_cdprogra = "crps386"
       glb_cdcritic = 0
       glb_flgbatch = false
       glb_flgresta = false
       glb_dscritic = "". 

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    QUIT.
END.
ERROR-STATUS:ERROR = false.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps386 aux_handproc = PROC-HANDLE
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
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps386 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps386.pr_cdcritic WHEN pc_crps386.pr_cdcritic <> ?
       glb_dscritic = pc_crps386.pr_dscritic WHEN pc_crps386.pr_dscritic <> ?
       glb_stprogra = IF pc_crps386.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps386.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
        QUIT.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.
       
/* .......................................................................... */


