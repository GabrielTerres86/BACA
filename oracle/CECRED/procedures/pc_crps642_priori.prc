CREATE OR REPLACE PROCEDURE CECRED.pc_crps642_priori (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código da cooperativa
                                              ,pr_flgresta IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação                                        
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                              ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /*..............................................................................

       Programa: pc_crps642_priori  (Copia de: pc_crps642)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Fabiano B. Dias (AMcom)
       Data    : Março/2018                        Ultima atualizacao: 26/03/2018

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Solicitacao 005. Efetuar debito de agendamentos de
                   convenios SICREDI feitos na Internet. 
									 Inclusão do PR_INPRIORI: Indicador de prioridade para o debitador unico ("S"= agua/luz, "N"=outros, ).
                   No programa CRPS642 o valor DEFAULT eh 'T'=todos por causa das telas.
									 Criamos a PC_CRPS642_PRIORI com  valor DEFAULT 'S'.
                   No agendamento do programa CRPS642 o valor do PR_INPRIORI deve ser 'N'=outros.
																

                               ************ ATENCAO *************
                   CASO NECESSARIO RODAR PROGRAMA MANUALMENTE VERIFICAR A NECESSIDADE DE AJUSTAR O
                   PARAMETRO(CRAPPRM) CTRL_DEBSIC_EXEC QUE CONTROLA A EXECUÇÃO DO PROGRAMA.

       Alteracoes: 00/00/0000 - Ajuste ...
    ..............................................................................*/
  DECLARE
	
		vr_stprogra  NUMBER;
		vr_infimsol  NUMBER;                                        
		vr_cdcritic  crapcri.cdcritic%TYPE;
		vr_dscritic  VARCHAR2(500);
																																														
	BEGIN

		pc_crps642(pr_cdcooper => pr_cdcooper   --> Código da cooperativa
							,pr_flgresta => pr_flgresta   --> Flag 0/1 para utilizar restart na chamada
							,pr_inpriori => 'S'           --> Indicador de prioridade para o debitador unico ("S"= agua/luz, "N"=outros) 
							,pr_stprogra => vr_stprogra   --> Saída de termino da execução
							,pr_infimsol => vr_infimsol   --> Saída de termino da solicitação                                        
							,pr_cdcritic => vr_cdcritic
							,pr_dscritic => vr_dscritic );
	
		pr_stprogra := vr_stprogra;
		pr_infimsol := vr_infimsol;                                        
		pr_cdcritic := vr_cdcritic;
		pr_dscritic := vr_dscritic;

	END;
END pc_crps642_priori;