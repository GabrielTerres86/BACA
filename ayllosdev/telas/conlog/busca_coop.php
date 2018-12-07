<? 
/*!
 * FONTE        : busca_coop.php
 * CRIAÇÃO      : Thaise - Envolti
 * DATA CRIAÇÃO : Outubro/2018
 * OBJETIVO     : Busca as cooperativas 
 * --------------
 * ALTERAÇÕES   : 
 */

	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <flcecred>1</flcecred>";
	$xml 	   .= "     <flgtodas>1</flgtodas>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";

	$xmlResult = "";

	// Executa script para envio do XML	 
	$xmlResult = mensageria($xml, "CONLOG", "BUSCA_COOPER", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	//var_dump($xmlObj->roottag->tags[0]); die;
/*
	$xmlx = "<Root>";
	$xmlx .= " <Dados>";
	$xmlx .= " <cdcooper>0</cdcooper>";
	$xmlx .= " <flgativo>1</flgativo>";
	$xmlx .= " </Dados>";
	$xmlx .= "</Root>";

	$xmlResultx = mensageria($xmlx, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjx = getObjectXML($xmlResultx);
*/
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		//echo ""exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","","NaN");';

	} else {

		$cooperativas = $xmlObj->roottag->tags[0]->tags;
		foreach ( $cooperativas as $coop ) {

		   $nmrescop .= '<option value="'.getByTagName($coop->tags,'cdcooper').'">'.getByTagName($coop->tags,'nmrescop').'</option> ';

		}

	}
?>