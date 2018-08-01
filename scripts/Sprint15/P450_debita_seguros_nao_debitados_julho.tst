PL/SQL Developer Test script 3.0
119
-- Created on 01/08/2018 by T0031667 
declare 
  -- Busca dados do cadastro de seguros --
	CURSOR cr_crapseg IS
		SELECT /*+index_asc (seg CRAPSEG##CRAPSEG2)*/
					 seg.rowid
					,seg.dtprideb
					,seg.dtrenova
					,seg.dtdebito
					,seg.nrdconta
					,seg.cdsegura
					,seg.vlpreseg
					,seg.nrctrseg
					,seg.vlprepag
					,seg.qtprevig
					,seg.qtprepag
					,seg.tpseguro
					,seg.dtfimvig
		FROM crapseg seg
		WHERE seg.cdcooper  = 1
			AND seg.nrdconta IN (6150810, 2760428,90112105,7880146,7622856,3973956)
			AND seg.tpseguro  = 3
			AND seg.cdsitseg  = 1;
	rw_crapseg cr_crapseg%ROWTYPE;
	
	-- Busca dados da seguradora
	CURSOR cr_crapcsg(pr_cdcooper IN crapcsg.cdcooper%TYPE,
										pr_cdsegura IN crapcsg.cdsegura%TYPE) IS
		SELECT csg.nrcgcseg
					,csg.cdhstaut##2
		FROM crapcsg csg
		WHERE csg.cdcooper = pr_cdcooper
			AND csg.cdsegura = pr_cdsegura;
	rw_crapcsg cr_crapcsg%ROWTYPE;
	
	rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
	
	vr_cdhistor craphis.cdhistor%TYPE;
	vr_tab_retorno LANC0001.typ_reg_retorno;
	vr_incrineg NUMBER;
	vr_cdcritic crapcri.cdcritic%TYPE;
	vr_dscritic crapcri.dscritic%TYPE;
	
	vr_dtdeb28 DATE;
	vr_dtdebito DATE;
BEGIN
  -- Carrega calendário de datas da cooperativa
	OPEN BTCH0001.cr_crapdat(1);
	FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
	CLOSE BTCH0001.cr_crapdat;	

  -- Percorre os contratos de seguro a debitar
  FOR rw_crapseg IN cr_crapseg LOOP
		-- Abre cursor seguradoras
		OPEN cr_crapcsg(pr_cdcooper => 1,
										pr_cdsegura => rw_crapseg.cdsegura);
		FETCH cr_crapcsg INTO rw_crapcsg;
		CLOSE cr_crapcsg;

		vr_cdhistor := rw_crapcsg.cdhstaut##2;
		
		-- Insere o lançamento de débito no valor do seguro
		LANC0001.pc_gerar_lancamento_conta(pr_cdagenci => 1 -- rw_craplot.cdagenci
																			, pr_cdbccxlt => 100 -- rw_craplot.cdbccxlt
																			 , pr_cdhistor => vr_cdhistor
																			 , pr_dtmvtolt => rw_crapdat.dtmvtolt
																			 , pr_cdpesqbb => to_char(rw_crapseg.cdsegura)
																			 , pr_nrdconta => rw_crapseg.nrdconta
																			 , pr_nrdctabb => rw_crapseg.nrdconta
																			 , pr_nrdctitg => to_char(rw_crapseg.nrdconta)
																			 , pr_nrdocmto => rw_crapseg.nrctrseg
																			 , pr_nrdolote => 4154 --rw_craplot.nrdolote
																			 , pr_vllanmto => rw_crapseg.vlpreseg
																			 , pr_cdcooper => 1
																			 , pr_inprolot => 1  -- processa o lote na própria procedure
																			 , pr_tplotmov => 1
																			 , pr_tab_retorno => vr_tab_retorno
																			 , pr_incrineg => vr_incrineg
																			 , pr_cdcritic => vr_cdcritic
																			 , pr_dscritic => vr_dscritic);
																			 
		UPDATE crapseg SET
					 crapseg.dtultpag = rw_crapdat.dtmvtolt,
					 crapseg.qtprepag = rw_crapseg.qtprepag + 1,
					 crapseg.qtprevig = rw_crapseg.qtprevig + 1,
					 crapseg.vlprepag = rw_crapseg.vlprepag + rw_crapseg.vlpreseg,
					 crapseg.indebito = 1
		 WHERE crapseg.rowid = rw_crapseg.rowid;
		 
		 IF nvl(rw_crapseg.dtprideb,to_date('01/01/1500','DD/MM/RRRR')) <> rw_crapdat.dtmvtolt THEN
				-- Se o débito for dias 29, 30 ou 31, debitará sempre no dia 28
				IF to_char(rw_crapseg.dtdebito,'DD') > 28 THEN
					vr_dtdeb28 := '28'||to_char(rw_crapseg.dtdebito, '/MM/YYYY');
				END IF;


				IF vr_dtdeb28 IS NOT NULL THEN
					-- CALCULA DATA COM DIA 28 FIXADO
					vr_dtdebito := GENE0005.fn_calc_data(pr_dtmvtolt => vr_dtdeb28
																							,pr_qtmesano => 1
																							,pr_tpmesano => 'M'
																							,pr_des_erro => vr_dscritic);
				ELSE
					-- CALCULA DATA GERAL
					vr_dtdebito := GENE0005.fn_calc_data(pr_dtmvtolt => rw_crapseg.dtdebito
																							,pr_qtmesano => 1
																							,pr_tpmesano => 'M'
																							,pr_des_erro => vr_dscritic);

				END IF;

				-- Altera o registro de seguro
				-- Data de Débito para o dia 28
					UPDATE crapseg SET
								 crapseg.dtdebito = vr_dtdebito
					 WHERE crapseg.rowid = rw_crapseg.rowid;
			END IF;
	END LOOP;
	commit;
end;