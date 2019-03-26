<?php
/*!
 * FONTE         : valida_operacao_rating.php
 * CRIAÇÃO       : Bruno Luiz Katzjarowski - Mout's
 * DATA CRIAÇÃO  : 19/10/2018
 * OBJETIVO      : Retornar informações da linha
 *
 * ALTERACOES    : 
 */

 
		$xml = "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0002.p</Bo>";
		$xml .= "		<Proc>".$procedure."</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "		<inconfir>".$inconfir."</inconfir>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		$xmlResult = getDataXML($xml);
		$xmlObjeto = getObjectXML($xmlResult);
		
		$analise = $xmlObjeto->roottag->tags[9]->tags[0]->tags;
		
		$nrinfcad = getByTagName($analise,'nrinfcad');
				
		if($cdlcremp == ""){
			$cdlcremp = 100;
		}
		if(is_null($nrregist)){
			$nrregist = 0;
		}
		if(is_null($nriniseq)){
			$nriniseq = 0;
		}
		
		// Monta o xml de requisição		
		$xml  		= "";
		$xml 	   .= "<Root>";
		$xml 	   .= "  <Dados>";
		$xml 	   .= "     <cdlcremp>".$cdlcremp."</cdlcremp>";
		$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
		$xml 	   .= "     <nrregist>".$nrregist."</nrregist>";
		$xml 	   .= "     <nriniseq>".$nriniseq."</nriniseq>";
		$xml 	   .= "  </Dados>";
		$xml 	   .= "</Root>";
		// Executa script para envio do XML	
		$xmlResult = mensageria($xml, "TELA_LCREDI", "CONSLINHA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		
		$linha     = $xmlObj->roottag->tags[0]->tags[0];

?>