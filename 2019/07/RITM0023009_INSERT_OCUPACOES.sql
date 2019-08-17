BEGIN
	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'AUXILIAR DE PRODUÇÃO', 1, 'AUXILIAR DE PRODUÇÃO' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'OPERADOR DE CAIXA', 1, 'OPERADOR DE CAIXA' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'RECEPCIONISTA', 1, 'RECEPCIONISTA' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'BALCONISTA', 1, 'BALCONISTA' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'AUXILIAR DE BANHO E TOSA DE ANIMAIS', 1, 'AUXILIAR DE BANHO E TOSA DE ANIMAIS' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'ANALISTA DE NEGÓCIOS', 1, 'ANALISTA DE NEGÓCIOS' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'ASSISTENTE DE NEGÓCIOS', 1, 'ASSISTENTE DE NEGÓCIOS' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'COORDENADOR DE PA', 1, 'COORDENADOR DE PA' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'GERENTE', 1, 'GERENTE' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'MONTADOR', 1, 'MONTADOR' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'TECNICO DE MANUTENÇÃO', 1, 'TECNICO DE MANUTENÇÃO' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'ATENDENTE', 1, 'ATENDENTE' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'PROJETISTA', 1, 'PROJETISTA' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'AUXILIAR TÉCNICO', 1, 'AUXILIAR TÉCNICO' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'INSPETOR SANITÁRIO', 4, 'INSPETOR SANITÁRIO' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'SUPERVISOR', 1, 'SUPERV.' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'CONSULTOR DE NEGÓCIOS', 1, 'CONSULTOR DE NEGÓCIOS' FROM gncdocp;


	INSERT INTO gncdocp (cdocupa, dsdocupa, cdnatocp, rsdocupa)
	SELECT MAX(cdocupa) + 1 cdocupa, 'ENTREGADOR', 1, 'ENTREGADOR' FROM gncdocp;

	COMMIT;
END;