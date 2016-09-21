<?php 

	//************************************************************************//
	//*** Fonte: rating_dados_impressao.php                                ***//
	//*** Autor: David                                                     ***//
	//*** Data : Junho/2010                   Última Alteração: 07/04/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Formatar dados para impressão do RATING              ***//	
	//***                                                                  ***//
	//*** Alterações: 07/04/2011 - Incluido os dados do Risco_Cooperado    ***//	
	//***						   (Adriano).							   ***//
	//************************************************************************//
	
	
	
	
	// Obtem dados da tag RELATORIO
	$tagsRelatorio   = $xmlObjRating->roottag->tags[0]->tags[0]->tags;
	$qtTagsRelatorio = count($tagsRelatorio);
	
	for ($i = 0; $i < $qtTagsRelatorio; $i++) {
		$relatorio[$tagsRelatorio[$i]->name] = $tagsRelatorio[$i]->cdata;
	}
	
	// Obtem dados da tag COOPERADO
	$tagsCooperado   = $xmlObjRating->roottag->tags[1]->tags[0]->tags;
	$qtTagsCooperado = count($tagsCooperado);
	
	for ($i = 0; $i < $qtTagsCooperado; $i++) {
		$cooperado[$tagsCooperado[$i]->name] = $tagsCooperado[$i]->cdata;
	}
	
	// Obtem dados da tag RATING
	$tagsRating   = $xmlObjRating->roottag->tags[2]->tags;
	$qtTagsRating = count($tagsRating);	
	
	for ($i = 0; $i < $qtTagsRating; $i++) {
		$tagsRatingDet = $tagsRating[$i]->tags;
		
		if ($tagsRatingDet[2]->cdata == 0) {
			$rating[$tagsRatingDet[1]->cdata][$tagsRatingDet[2]->cdata][$tagsRatingDet[3]->cdata]["DSITETOP"] = $tagsRatingDet[4]->cdata;			
		} elseif ($tagsRatingDet[2]->cdata > 0 && $tagsRatingDet[3]->cdata == 0) {
			$rating[$tagsRatingDet[1]->cdata][$tagsRatingDet[2]->cdata][$tagsRatingDet[3]->cdata]["DSITETOP"] = trim(substr($tagsRatingDet[4]->cdata,strpos($tagsRatingDet[4]->cdata," ")));
			$rating[$tagsRatingDet[1]->cdata][$tagsRatingDet[2]->cdata][$tagsRatingDet[3]->cdata]["DSPESOIT"] = trim($tagsRatingDet[5]->cdata);
			$rating[$tagsRatingDet[1]->cdata][$tagsRatingDet[2]->cdata][$tagsRatingDet[3]->cdata]["DSNOTAIT"] = "";		
		} elseif ($tagsRatingDet[2]->cdata > 0 && $tagsRatingDet[3]->cdata > 0) {	
			// Retirar espaços para quebrar o dados em duas partes
			$tagsRatingDet[5]->cdata = trim($tagsRatingDet[5]->cdata);
			
			$rating[$tagsRatingDet[1]->cdata][$tagsRatingDet[2]->cdata][$tagsRatingDet[3]->cdata]["DSITETOP"] = trim(substr($tagsRatingDet[4]->cdata,strpos($tagsRatingDet[4]->cdata," ")));
			$rating[$tagsRatingDet[1]->cdata][$tagsRatingDet[2]->cdata][$tagsRatingDet[3]->cdata]["DSPESOIT"] = trim(substr($tagsRatingDet[5]->cdata,0,strpos($tagsRatingDet[5]->cdata," ")));
			$rating[$tagsRatingDet[1]->cdata][$tagsRatingDet[2]->cdata][$tagsRatingDet[3]->cdata]["DSNOTAIT"] = trim(substr($tagsRatingDet[5]->cdata,strrpos($tagsRatingDet[5]->cdata," ")));
		}
	}
	
	// Obtem dados da tag RISCO
	$tagsRisco   = $xmlObjRating->roottag->tags[3]->tags[0]->tags;
	$qtTagsRisco = count($tagsRisco);
	
	for ($i = 0; $i < $qtTagsRisco; $i++) {
		$risco[$tagsRisco[$i]->name] = $tagsRisco[$i]->cdata;
	}
	
	// Obtem dados da tag ASSINATURA
	$tagsAssinatura   = $xmlObjRating->roottag->tags[4]->tags[0]->tags;
	$qtTagsAssinatura = count($tagsAssinatura);
	
	for ($i = 0; $i < $qtTagsAssinatura; $i++) {
		$assinatura[$tagsAssinatura[$i]->name] = $tagsAssinatura[$i]->cdata;
	}
	
	// Obtem dados da tag EFETIVACAO
	$tagsEfetivacao   = $xmlObjRating->roottag->tags[5]->tags;
	$qtTagsEfetivacao = count($tagsEfetivacao);
	
	for ($i = 0; $i < $qtTagsEfetivacao; $i++) {
		$tagsEfetivacaoDet = $tagsEfetivacao[$i]->tags;				
		$efetivacao[$tagsEfetivacaoDet[1]->cdata] = $tagsEfetivacaoDet[0]->cdata;		
	}
	
	// Obtem dados da tag RATING_COOPERADO
	$tagsRatings   = $xmlObjRating->roottag->tags[6]->tags;
	$qtTagsRatings = count($tagsRatings);	
	
	for ($i = 0; $i < $qtTagsRatings; $i++) {
		$tagsRatingsDet   = $tagsRatings[$i]->tags;
		$qtTagsRatingsDet = count($tagsRatingsDet);
		
		for($j = 0; $j < $qtTagsRatingsDet; $j++) {
			$ratings[$i][$tagsRatingsDet[$j]->name] = $tagsRatingsDet[$j]->cdata;
		}		
	}
		
	// Obtem dados da tag RISCO_COOPERADO
	$tagsRisco_Cooperado   = $xmlObjRating->roottag->tags[7]->tags[0]->tags;
	$qtTagsRisco_Cooperado = count($tagsRisco_Cooperado);
	
	for ($i = 0; $i < $qtTagsRisco_Cooperado; $i++) {
		$risco_cooperado[$tagsRisco_Cooperado[$i]->name] = $tagsRisco_Cooperado[$i]->cdata;
					
	}
	
	unsetVarSession($glbvars["dadosImpressaoRatingEfetivo"]);
	unsetVarSession($glbvars["dadosImpressaoRating"]);	
	
	if (!$flgEfetivacao || $qtTagsEfetivacao > 0) {	
		$tmpDadosImpRating["RELATORIO"]  = $relatorio;
		$tmpDadosImpRating["COOPERADO"]  = $cooperado;
		$tmpDadosImpRating["RATING"]     = $rating;
		$tmpDadosImpRating["RISCO"]      = $risco;
		$tmpDadosImpRating["ASSINATURA"] = $assinatura;
		$tmpDadosImpRating["EFETIVACAO"] = $efetivacao;		
		$tmpDadosImpRating["RISCO_COOPERADO"] = $risco_cooperado;
		
		setVarSession(($flgEfetivacao ? "dadosImpressaoRatingEfetivo" : "dadosImpressaoRating"),$tmpDadosImpRating);		
	}
	
?>