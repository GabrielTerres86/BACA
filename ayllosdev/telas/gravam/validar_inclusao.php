<?php
/*!
 * FONTE        : validar_inclusao.php
 * CRIAÇÃO      : Thaise Medeiros (Envolti)
 * DATA CRIAÇÃO : Outubro/2018
 * OBJETIVO     : Rotina para realizar validação da inclusão manual do gravame
 * --------------
 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	require_once('uteis/funcoes_gravame.php');
	isPostMethod();		

	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	$nrctrpro = (isset($_POST["nrctrpro"])) ? $_POST["nrctrpro"] : 0;
	$tpctrpro = (isset($_POST["tpctrpro"])) ? $_POST["tpctrpro"] : 0;
	$idseqbem = (isset($_POST["idseqbem"])) ? $_POST["idseqbem"] : 0;
	$operacao = (isset($_POST["operacao"])) ? $_POST["operacao"] : 0;

		// Monta o xml de requisição		
		$xml  		= "";
		$xml 	   .= "	<Root>";
		$xml 	   .= "		<Dados>";
		$xml 	   .= "			<cddopcao>".$cddopcao."</cddopcao>";
		$xml 	   .= "			<nrdconta>".$nrdconta."</nrdconta>";
		$xml 	   .= "			<nrctrpro>".$nrctrpro."</nrctrpro>";
		$xml 	   .= "			<tpctrpro>".$tpctrpro."</tpctrpro>";
		$xml 	   .= "			<idseqbem>".$idseqbem."</idseqbem>";
		$xml 	   .= "			<tpinclus>".$operacao."</tpinclus>";
		$xml 	   .= "		</Dados>";
		$xml 	   .= "	</Root>";

		// Executa script para envio do XML	
		$xmlResult = mensageria($xml
					   ,"GRVM0001"
					   ,"VALMANUALGRAVAM"
					   ,$glbvars["cdcooper"]
					   ,$glbvars["cdagenci"]
					   ,$glbvars["nrdcaixa"]
					   ,$glbvars["idorigem"]
					   ,$glbvars["cdoperad"]
					   ,"</Root>");
		$xmlObj = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];

			if(empty ($nmdcampo)){ $nmdcampo = "dtmvttel"; }

			exibirErro('error',$msgErro,'Alerta - Ayllos','formataFormularioBens();focaCampoErro(\''.$nmdcampo.'\',\'frmBens\');',false);		

	} else if (strtoupper($xmlObj->roottag->tags[0]->name) != "GRAVAMEB3") {

		echo "formatarInclusaoManual();";

		} else {

			parametrosParaAudit($glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"]);
			$xml = getXML( $xmlResult );
			$url = $Url_SOA . getURL( $xml->gravameB3[0]->gravame[0] );

			if ($operacao == "A") {
				$data = convertXMLtoJSONAliena( $xml->gravameB3[0]->gravame[0] );
			} else {
				$data = convertXMLtoJSONConsulta( $xml->gravameB3[0]->gravame[0] );
			}
			$xmlStr = postGravame( $xml, $data, $url, $Auth_SOA );

			if ($operacao == "A") {
				$cdoperac = getCdOperac($xml->gravameB3[0]->gravame[0]);
				$cdidseqbem = getCdIdseqbem( $xml->gravameB3[0]->gravame[0] );
				verificarRetornoAliena( $xmlStr, $cdoperac, $cdidseqbem );
			} else {
				verificarRetornoConsulta( $xmlStr );
			}

		}
/*
	} else {

	  // Monta o xml de requisição
		$xmlReq  		= "";
		$xmlReq 	   .= "<Root>";
		$xmlReq 	   .= "  <Dados>";
		$xmlReq 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
		$xmlReq 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
		$xmlReq 	   .= "     <nrctrpro>".$nrctrpro."</nrctrpro>"; 
		$xmlReq 	   .= "     <tpctrpro>".$tpctrpro."</tpctrpro>";
		$xmlReq 	   .= "     <idseqbem>".$idseqbem."</idseqbem>";
		$xmlReq 	   .= "  </Dados>";
		$xmlReq 	   .= "</Root>";

		// Executa script para envio do XML	
		$xmlResult = mensageria($xmlReq, "GRVM0001", "VALMANUALGRAVAM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	

			if(empty ($nmdcampo)){
				$nmdcampo = "dtmvttel";
			}

			exibirErro('error',$msgErro,'Alerta - Ayllos','formataFormularioBens();focaCampoErro(\''.$nmdcampo.'\',\'frmBens\');',false);		

		} else {

			parametrosParaAudit($glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"]);
			$xml = getXML( $xmlResult );
			$url = $Url_SOA.getURL( $xml->gravameB3[0]->gravame[0] );
			$data = convertXMLtoJSONConsulta( $xml->gravameB3[0]->gravame[0] );
			$xmlStr = postGravame( $xml, $data, $url, $Auth_SOA );
			verificarRetornoConsulta( $xmlStr );

			function validaDados(){
				IF($GLOBALS["dtmvttel"] == '' ){
					exibirErro('error','Data do registro deve ser informada!.','Alerta - Ayllos','formataFormularioBens();focaCampoErro(\'dtmvttel\',\'frmBens\');',false);
				}

				IF($GLOBALS["dsjustif"] == '' ){
					exibirErro('error','Justificativa deve ser informada!','Alerta - Ayllos','formataFormularioBens();focaCampoErro(\'dsjustif\',\'frmBens\');',false);
				}

				IF($GLOBALS["nrgravam"] == 0 ){
					exibirErro('error','O n&uacute;mero do registro deve ser !','Alerta - Ayllos','formataFormularioBens();focaCampoErro(\'nrgravam\',\'frmBens\');',false);
				}

			}
		}
	}
 ?>
