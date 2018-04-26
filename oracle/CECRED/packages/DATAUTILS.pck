CREATE OR REPLACE PACKAGE CECRED.DATAUTILS IS

-- Altera a data atual da cooperativa para uma data especificada
PROCEDURE pc_mudar_data(pr_cdcooper IN  NUMBER
                             , pr_dtmvtolt IN  DATE
                             , pr_dscritic OUT VARCHAR2);

-- Avança a data da cooperativa uma quantidade de dias
PROCEDURE pc_avancar_data(pr_cdcooper IN  NUMBER
                        , pr_qtdiasav IN  INTEGER DEFAULT 1  -- quantidade de dias a avançar
												, pr_avautom  IN  BOOLEAN DEFAULT TRUE -- Avançar automaticamente pra o próximo dia útil
                        , pr_dscritic OUT VARCHAR2);

-- Retrocede a data da cooperativa uma quantidade de dias
PROCEDURE pc_retroceder_data(pr_cdcooper IN  NUMBER
                           , pr_qtdiasrt IN  INTEGER DEFAULT 1 -- quantidade de dias a retroceder
													 , pr_retautom IN  BOOLEAN DEFAULT TRUE -- Retroceder automaticamente para o dia útil anterior
                           , pr_dscritic OUT VARCHAR2);

END DATAUTILS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.DATAUTILS IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : DATAUTILS
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Reginaldo (AMcom)
  --  Data     : Janeiro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas utilitárias para manipulação das datas da cooperativa (CRAPDAT)
  --
  -- Alterado:
  --
  ---------------------------------------------------------------------------------------------------------------

-- Redefine a data com base em uma data específica fornecida
PROCEDURE pc_mudar_data(pr_cdcooper IN  NUMBER
                      , pr_dtmvtolt IN  DATE
                      , pr_dscritic OUT VARCHAR2) IS
BEGIN

DECLARE
  CURSOR cr_crapfer(pr_dtmvtolt DATE) IS
  SELECT fer.dsferiad
    FROM crapfer fer
   WHERE fer.cdcooper = pr_cdcooper
     AND fer.dtferiad = pr_dtmvtolt;

  vr_dsferiad crapfer.dsferiad%TYPE;
  vr_dtmvtoan crapdat.dtmvtoan%TYPE;
  vr_dtmvtopr crapdat.dtmvtopr%TYPE;
BEGIN
    pr_dscritic := NULL;
		
		IF pr_cdcooper IS NULL 
    OR pr_cdcooper = 0 THEN
			pr_dscritic := 'Erro. A cooperativa não pode ser nula.';
			RETURN;
		END IF;

    IF to_char(pr_dtmvtolt, 'D') = 7 THEN
      pr_dscritic := 'Erro. A nova data é um sábado.';
      RETURN;
    END IF;

    IF to_char(pr_dtmvtolt, 'D') = 1 THEN
      pr_dscritic := 'Erro. A nova data é um domingo.';
      RETURN;
    END IF;

    OPEN cr_crapfer(pr_dtmvtolt);
    FETCH cr_crapfer INTO vr_dsferiad;
    IF cr_crapfer%FOUND THEN
      pr_dscritic := 'Erro. A nova data é feriado (' || vr_dsferiad || ').';
      CLOSE cr_crapfer;
      RETURN;
    ELSE
      CLOSE cr_crapfer;
    END IF;

    vr_dtmvtoan := pr_dtmvtolt;

    LOOP
      vr_dtmvtoan := vr_dtmvtoan - 1;

      OPEN cr_crapfer(vr_dtmvtoan);
      FETCH cr_crapfer INTO vr_dsferiad;

      EXIT WHEN cr_crapfer%NOTFOUND AND to_char(vr_dtmvtoan, 'D') NOT IN (1,7);

      CLOSE cr_crapfer;
    END LOOP;

    CLOSE cr_crapfer;

    vr_dtmvtopr := pr_dtmvtolt;

		LOOP
			vr_dtmvtopr := vr_dtmvtopr + 1;

			OPEN cr_crapfer(vr_dtmvtopr);
			FETCH cr_crapfer INTO vr_dsferiad;

			EXIT WHEN cr_crapfer%NOTFOUND AND to_char(vr_dtmvtopr, 'D') NOT IN (1,7);

			CLOSE cr_crapfer;
		END LOOP;

		CLOSE cr_crapfer;

		UPDATE crapdat dat
		   SET dat.dtmvtolt = pr_dtmvtolt
			   , dat.dtmvtoan = vr_dtmvtoan
				 , dat.dtmvtopr = vr_dtmvtopr
				 , dat.dtmvtocd = pr_dtmvtolt
				 , dat.dtultdia = last_day(pr_dtmvtolt)
				 , dat.dtultdma = last_day(add_months(pr_dtmvtolt, -1))
				 , dat.inproces = 1
		 WHERE dat.cdcooper = pr_cdcooper;

		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			pr_dscritic := 'Erro não tratado - pc_mudar_data: ' || SQLERRM;
	END;
END pc_mudar_data;

-- Avança a data da cooperativa uma quantidade de dias
PROCEDURE pc_avancar_data(pr_cdcooper IN  NUMBER
                        , pr_qtdiasav IN  INTEGER DEFAULT 1  -- quantidade de dias a avançar
												, pr_avautom  IN  BOOLEAN DEFAULT TRUE -- Avançar automaticamente pra o próximo dia útil
                        , pr_dscritic OUT VARCHAR2) IS
												
  CURSOR cr_crapdat IS
	SELECT dat.dtmvtolt
	  FROM crapdat dat
	 WHERE dat.cdcooper = pr_cdcooper;

	vr_dtmvtolt crapdat.dtmvtolt%TYPE;												
												
BEGIN
  pr_dscritic := NULL;

	OPEN cr_crapdat;
	FETCH cr_crapdat INTO vr_dtmvtolt;
	CLOSE cr_crapdat;

	vr_dtmvtolt := vr_dtmvtolt + pr_qtdiasav;
	
	LOOP
	  pc_mudar_data(pr_cdcooper, vr_dtmvtolt, pr_dscritic);
		
		EXIT WHEN pr_dscritic IS NULL OR NOT pr_avautom;
		
		vr_dtmvtolt := vr_dtmvtolt + 1; -- Avançar caso a data não seja dia útil
	END LOOP;
END pc_avancar_data;

-- Retrocede a data da cooperativa uma quantidade de dias
PROCEDURE pc_retroceder_data(pr_cdcooper IN  NUMBER
                           , pr_qtdiasrt IN  INTEGER DEFAULT 1 -- quantidade de dias a retroceder
													 , pr_retautom IN  BOOLEAN DEFAULT TRUE -- Retroceder automaticamente para o dia útil anterior
                           , pr_dscritic OUT VARCHAR2) IS
													 
  CURSOR cr_crapdat IS
	SELECT dat.dtmvtolt
	  FROM crapdat dat
	 WHERE dat.cdcooper = pr_cdcooper;

	vr_dtmvtolt crapdat.dtmvtolt%TYPE;
  
BEGIN
  pr_dscritic := NULL;

	OPEN cr_crapdat;
	FETCH cr_crapdat INTO vr_dtmvtolt;
	CLOSE cr_crapdat;

	vr_dtmvtolt := vr_dtmvtolt - pr_qtdiasrt;
	
	LOOP
	  pc_mudar_data(pr_cdcooper, vr_dtmvtolt, pr_dscritic);
		
		EXIT WHEN pr_dscritic IS NULL OR NOT pr_retautom;
		
		vr_dtmvtolt := vr_dtmvtolt - 1; -- Retrocede caso a data não seja dia útil
	END LOOP;
END pc_retroceder_data;

END DATAUTILS;
/
