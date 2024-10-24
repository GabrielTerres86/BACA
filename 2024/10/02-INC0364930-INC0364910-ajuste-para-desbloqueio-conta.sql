DECLARE
	  pr_idsolblqanalitico CONSTANT VARCHAR2(100) := '2369A7FDD8A00852E0630A2935739C1D'; -- Valor do ID do Bloqueio
	  pr_cdcritic crapcri.cdcritic%TYPE;
	  pr_dscritic VARCHAR2(4000);
	BEGIN
	  CONTACORRENTE.devolucaoParcialBloqueioPix(
		pr_idsolblqanalitico => pr_idsolblqanalitico,
		pr_cdcritic => pr_cdcritic,
		pr_dscritic => pr_dscritic
	  );
	  -- Exibir os valores dos par�metros de sa�da
	  DBMS_OUTPUT.PUT_LINE('Cr�tica: ' || pr_cdcritic);
	  DBMS_OUTPUT.PUT_LINE('Descri��o da Cr�tica: ' || pr_dscritic);
	EXCEPTION
	  WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Ocorreu um erro: ' || SQLERRM);
	END;