DECLARE
	  pr_idsolblqanalitico CONSTANT VARCHAR2(100) := '213B51C2DB8602FCE0630A29357C4B4F'; 
	  pr_cdcritic crapcri.cdcritic%TYPE;
	  pr_dscritic VARCHAR2(4000);
	BEGIN
	  CONTACORRENTE.devolucaoParcialBloqueioPix(
		pr_idsolblqanalitico => pr_idsolblqanalitico,
		pr_cdcritic => pr_cdcritic,
		pr_dscritic => pr_dscritic
	  );
	  COMMIT;
	  DBMS_OUTPUT.PUT_LINE('Crítica: ' || pr_cdcritic);
	  DBMS_OUTPUT.PUT_LINE('Descrição da Crítica: ' || pr_dscritic);
	EXCEPTION
	  WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Ocorreu um erro: ' || SQLERRM);
	END;