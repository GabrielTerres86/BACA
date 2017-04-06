 /* ..........................................................................

   Programa: Fontes/crps388.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Abril/2004                          Ultima atualizacao: 03/04/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atender a solicitacao 092
               Gerar arquivo de arrecadacao de faturas(Debito Automatico)
               Emite relatorio 350.

   Alteracoes: 29/06/2004 - Tratamento de erros nos relatorios (Ze Eduardo).
   
               30/06/2004 - Nomear arquivo de dados dentro do FOR EACH crapndb
                            caso este ainda nao tenha sido nomeado (Julio).
  
               06/10/2004 - Sequenciar pelo numero do convenio(Mirtes). 

               03/11/2004 - Inclusao dos convenios 5 e 15 (Julio) 

               26/11/2004 - Inclusao do convenio 16 (Julio) 

               30/11/2004 - Cooperativa 1, nunca vai com "9001" na frente do
                            numero da conta (Julio)

               07/01/2005 - Referencia de cliente  VIVO deve ter 11 digitos
                            (Julio)

               28/01/2005 - Tratamento SAMAE GASPAR (CECRED) -> Hist. 635
                            convenio 19 
                            SAMAE TIMBO -> Hist. 628 convenio 16 (Julio)
                            
               02/02/2005 - Tratamento SAMAE BLUMENAU CECRED -> 643 (Julio)
                 
               25/04/2005 - Tratamento para UNIMED -> 509 (Julio)  

               31/05/2005 - Tratamento para AGUAS ITAPEMA -> 24 Hist. 455
                            (Julio)

               12/07/2005 - Alteracoes no tratamento de SAMAE GASPAR -> 19
                            (Julio)

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crabcop.cdcooper = glb_cdcooper (Diego).

               03/10/2005 - Quando for UNIMED (22), sempre colocar o codigo da
                            cooperativa no numero da conta, mesmo quendo for
                            VIACREDI. (Julio)

               12/01/2006 - Tratamento para email's em branco (Julio)

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               13/10/2006 - Tratamento para CELESC Distribuicao (Julio)

               27/11/2006 - Acerto no envio de email pela BO b1wgen0011 (David).
               
               29/11/2006 - Inclusao do convenio 28 - Unimed (Elton).
               
               02/02/2007 - Tratamento para DAE Navegantes -> 31 (Elton).
               
               29/05/2007 - Inclusao de registros "J" no caso do convenio
                            solicitar arquivos de confirmacao (Elton).
                            
               30/05/2007 - Inclusao do convenio 32 - Uniodonto (Elton).
               
               01/06/2007 - Incluido possibilidade de envio de arquivo para
                            Accestage (Elton).
               
               27/07/2007 - Acertado total de registros no trailer "Z" quando
                            houver registros do tipo "J" (Elton).
                            
               19/11/2007 - Tratamento para Aguas de Joinville -> 33 (Elton).
               
               28/11/2007 - Tratamento para SEMASA Itajai -> 34 (Elton).

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)
               
               15/08/2008 - Tratamento para o convenio SAMAE Jaragua -> 9
                            (Diego).
                            
               04/11/2008 - Retirado constante da UF "SC" e colocado campo de
                            arquivo (Martin).
                            
               14/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - Paulo
                            
               16/10/2009 - Tratamento para convenio 38 -> Unimed Planalto Norte
                            e convenio 43 -> Servmed (Elton). 
                            
               15/04/2010 - Tratamento para convenio 46 -> Uniodonto Federacao
                            (Elton).
                            
               18/05/2010 - Tratamento para convenio 48 -> TIM Celular, conforme
                            convenio 3 (Elton).
               
               09/06/2010 - Tratamento para convenio 47 -> Unimed Credcrea 
                            (Elton).
               
               01/10/2010 - Tratamento para convenio 49 -> Samae Rio Negrinho e
                            convenio 50 -> HDI (Elton). 
                            
               08/11/2010 - Acerto no retorno de lancamentos nao debitados para
                            VIVO (Elton).             
                            
               11/05/2011 - Tratamento para convenio 53 -> Foz do Brasil e 
                            convenio 54 -> Aguas de Massaranduba (Elton).
                            
               27/05/2011 - Tratamento para convenio 55 -> Liberty
                            Tratamento para convenio 57 -> Jornal de SC (Elton).
               
               02/06/2011 - Incluido no for each a condição -
                            craplau.dsorigem <> "TAA" (Evandro).
                            
               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. (Fabricio)
                            
               03/11/2011 - Tratamento para convenio 58 -> Porto Seguro (Elton).

               23/01/2012 - Tratamento para unificacao arqs. Convenios
                            (Guilherme/Supero)
                            
               22/06/2012 - Substituido gncoper por crabcop (Tiago).       
               
               03/07/2012 - Alterado nomeclatura do relatório gerado incluindo 
                            código do convênio (Guilherme Maba).                
                            
               29/11/2102 - Tratamento migracao Alto Vale (Elton).
               
               03/06/2013 - Incluindo no FIND FIRST craplau a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)
                            
               04/07/2013 - Tratamento para Azul Seguros (Elton).
               
               08/08/2013 - Nao cria registro de controle na gncontr se for 
                            Cecred e o convenio for unificado (Elton).
                            
               20/09/2013 - Retirada condicao para atribuicao da variavel 
                            aux_nragenci;
                          - Retirado tratamento para GLOBAL TELECOM;
                          - Agrupados convenios: SAMAE Jaragua, SAMAE Gaspar,
                            SAMAE Blumenau Viacredi, SAMAE Blumenau Creditextil,
                            SAMAE Blumenau CECRED, SAMAE Timbo CECRED,
                            SAMAE Rio Negrinho em uma mesma condicao para a 
                            atribuicao da variavel aux_dslinreg;
                          - Adicionada condicao para os convenios: 1,25,26,33,
                            39,41,43,62;
                          - Adionado ultimo else no for each do craplcm. 
                            (Reinert)
               
               07/11/2013 - Tratamento migracao Acredi (Elton).
               
               22/11/2013 - Ajustes de format na exportacao convenios (Lucas R)
               
               22/01/2014 - Incluir VALIDATE gncontr, gncvuni (Lucas R.)
               
               01/04/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                            
               26/05/2014 - Retirado mensagens do log: "Sem movtos Convenio"; 
                            "Executando Convenio"; conforme chamado: 146206
                            data: 07/04/2014 - chamado:146223 data: 07/04/2014
                            chamado: 146226 data: 07/04/2014. Jéssica (DB1)
                            
               29/05/2014 - Retirado Criticas: 657; 748; 696 e 905 conforme 
                            chamado: 146231 data: 07/04/2014 - chamado:146236 
                            data: 07/04/2014. Jéssica (DB1)
                            
               25/09/2014 - Inclusao do convenio PREVISUL (cdconven = 66)
                            para montagem do arquivo de retorno com campo
                            de identificacao do cliente com 20 posicoes.
                            Removido das verificacoes alguns convenios 
                            que estao inativos. (Chamado 101648) - (Fabricio)
                            
               23/10/2014 - Tratamento para o campo Usa Agencia 
                            (gnconve.flgagenc); convenios a partir de 2014.
                            (Fabricio)
                            
               14/11/2014 - Ajuste para montar os registros da crapndb no
                            arquivo da mesma forma que quando montado atraves
                            da leitura da craplcm. (Chamado 173646) - (Fabricio)
                            
               28/11/2014 - Implementacao Van E-Sales (utilizacao inicial pela
                            Oi). (Chamado 192004) - (Fabricio)
                            
               07/04/2015 - Logs migrados para proc_message.log que nao eram
                            referentes ao processo (SD273550 - Tiago).
                            
               03/06/2015 - Retirado validacoes para o convenio 53 Foz do brasil
                            (Lucas Ranghetti #292200)
                            
               19/06/2015 - Alterado ordem do calculo da data aux_dtmvtopr
                            (Lucas Ranghetti #296615)
                            
               13/08/2015 - Adicioanar tratamento para o convenio MAPFRE VERA CRUZ SEG, 
                            referencia e conta (Lucas Ranghetti #292988 )
               
               28/09/2015 - incluido nas consultas da craplau
                            craplau.dsorigem <> "CAIXA" (Lombardi).
                            
               27/11/2015 - Alterar proc_batch pelo proc_message e tambem
                            retirado os logs do proc_message que eram gerados
                            com linhas em branco (Lucas Ranghetti #366033)

			         04/04/2016 - Incluido a regra Caso a data de inicio da
				        	          autorização seja maior que 01/09/2013 ira gravar a 
							              agencia com formato novo. 

               15/06/2016 - Adicnioar ux2dos para a Van E-sales (Lucas Ranghetti #469980)

               23/06/2016 - P333.1 - Devolução de arquivos com tipo de envio 
			                      6 - WebService (Marcos)
               
               15/08/2016 - Alterado ordem da leitura da crapatr (Lucas Ranghetti #499449)

			         05/10/2016 - Incluir tratamento para a CASAN enviar a angecia 1294 para autorizacoes
							              mais antigas (Lucas Ranghetti ##534110)
              
               28/12/2016 - Ajustes para incorporaçao da Transulcred (SD585459 Tiago/Elton) 

			         17/01/2016 - Ajustes para incorporação da Transulcred (SD593672 Tiago/Elton)
               
               19/01/2017 - Validar se referencia existe atraves do campo nrcrcard da craplau com a
                            tabela crapatr (Lucas Ranghetti #533520)
                            
               03/04/2017 - Conversao Progress para PLSQL (Jonata - Mouts)             
                            
............................................................................. */

{ includes/var_batch.i {1} }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "CRPS388"
       glb_cdcritic = 0
       glb_dscritic = ""
       
       glb_flgbatch = false
       
       .

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

RUN STORED-PROCEDURE pc_crps388 aux_handproc = PROC-HANDLE
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
        
CLOSE STORED-PROCEDURE pc_crps388 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps388.pr_cdcritic WHEN pc_crps388.pr_cdcritic <> ?
       glb_dscritic = pc_crps388.pr_dscritic WHEN pc_crps388.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps388.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps388.pr_infimsol = 1 THEN
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

/* .......................................................................... */