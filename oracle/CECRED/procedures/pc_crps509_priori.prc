CREATE OR REPLACE PROCEDURE cecred.PC_CRPS509_priori ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                                                      ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da Critica
                                                      ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: pc_crps509_priori       (Copia de: pc_crps509)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabiano B. Dias (AMcom)
   Data    : Março/2018                        Ultima atualizacao: 26/03/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 005. Efetuar debito de agendamentos feitos
               na Internet.
							 Inclusão do PR_INPRIORI: Indicador de prioridade para o debitador unico ("S"= agua/luz, "N"=outros, ).
							 No programa CRPS509 o valor DEFAULT eh 'T'=todos por causa das telas.
							 Criamos a PC_CRPS509_PRIORI com  valor DEFAULT 'S'.
							 No agendamento do programa CRPS509 o valor do PR_INPRIORI deve ser 'N'=outros.
							 
   Alteracoes: 00/00/0000 - Ajuste ...
	 
     ............................................................................. */
  DECLARE
	
		vr_stprogra  NUMBER;
		vr_infimsol  NUMBER;                                        
		vr_cdcritic  crapcri.cdcritic%TYPE;
		vr_dscritic  VARCHAR2(500);
																																														
	BEGIN

    PC_CRPS509 ( pr_cdcooper => pr_cdcooper  --> Código Cooperativa
                ,pr_flgresta => pr_flgresta  --> Flag padrão para utilização de restart
							  ,pr_inpriori => 'S'          --> Indicador de prioridade para o debitador unico ("S"= agua/luz, "N"=outros) 
                ,pr_stprogra => vr_stprogra  --> Saída de termino da execução
                ,pr_infimsol => vr_infimsol  --> Saída de termino da solicitação
                ,pr_cdcritic => vr_cdcritic  --> Código da Critica
                ,pr_dscritic => vr_dscritic); --> Descricao da Critica
	
	
		pr_stprogra := vr_stprogra;
		pr_infimsol := vr_infimsol;                                        
		pr_cdcritic := vr_cdcritic;
		pr_dscritic := vr_dscritic;

	END;
END pc_crps509_priori;		 