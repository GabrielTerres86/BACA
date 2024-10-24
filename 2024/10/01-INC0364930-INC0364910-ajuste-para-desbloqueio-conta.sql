DECLARE
	  pr_idsolblqanalitico CONSTANT VARCHAR2(100) := '232C0AD414940828E0630A29357E2712'; -- Valor do ID do Bloqueio
	  pr_cdcritic crapcri.cdcritic%TYPE;
	  pr_dscritic VARCHAR2(4000);
	BEGIN
	  CONTACORRENTE.devolucaoParcialBloqueioPix(
		pr_idsolblqanalitico => pr_idsolblqanalitico,
		pr_cdcritic => pr_cdcritic,
		pr_dscritic => pr_dscritic
	  );
	  -- Exibir os valores dos parâmetros de saída
	  DBMS_OUTPUT.PUT_LINE('Crítica: ' || pr_cdcritic);
	  DBMS_OUTPUT.PUT_LINE('Descrição da Crítica: ' || pr_dscritic);
	EXCEPTION
	  WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Ocorreu um erro: ' || SQLERRM);
	END;