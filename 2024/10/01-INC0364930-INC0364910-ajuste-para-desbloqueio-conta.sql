DECLARE
	pr_idsolblqanalitico CONSTANT VARCHAR2(100) := '239FCE133E7202AEE0630A2935749AE3';
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


DECLARE
	pr_idblqpix CONSTANT VARCHAR2(100) := '232C0AD414940828E0630A29357E2712';
	pr_vlbloqueado CONSTANT NUMBER := 0;
	pr_instatus CONSTANT NUMBER := 0;
	pr_cdcritic crapcri.cdcritic%TYPE;
	pr_dscritic VARCHAR2(4000);
BEGIN
	CONTACORRENTE.atualizaBloqueioPix(
	pr_idblqpix => pr_idblqpix,
	pr_vlbloqueado => pr_vlbloqueado, 
	pr_instatus => pr_instatus,
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