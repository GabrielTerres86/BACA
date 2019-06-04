<?php

/*!
 * FONTE        : wssoa.php 
 * CRIAÇÃO      : JDB - AMcom
 * DATA CRIAÇÃO : 05/2019
 * OBJETIVO     : Comunicação com SOA x FIS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 
 */
if (file_exists('../../../../includes/funcoes.php')){
	require_once('../../../../includes/funcoes.php');
}else{
	require_once('../../../includes/funcoes.php');
}
if (file_exists('../../../../class/xmlfile.php')){
	require_once('../../../../class/xmlfile.php');
}else{
	require_once('../../../class/xmlfile.php');
}




/*
// Variaveis para SOA 
$Url_SOA = "http://servicosinternosint.cecred.coop.br";
$Auth_SOA = "Basic aWJzdnJjb3JlOndlbGNvbWUx"; 
$aux = chamaServico('x',$Url_SOA, $Auth_SOA);
*/


function chamaServico($data,$Url_SOA, $Auth_SOA){
	$arrayHeader = array("Content-Type:application/json","Accept:application/json","Authorization:".$Auth_SOA);
	$url = $Url_SOA."/osb-soa/TransacaoCreditoRestService/v1/CalcularCreditoConsignado";
	
	$dataexemplo = '{
  "convenioCredito" : {
    "cooperativa" : {
      "codigo" : "13"
    },
    "numeroContrato" : "90000"
  },
  "configuracaoCredito" : {
    "diasCarencia" : 27,
    "financiaIOF" : 1,
    "financiaTarifa" : 1
  },
  "credito" : {
    "dataPrimeiraParcela" : "2019-06-05",
    "produto" : {
      "codigo" : "161"
    },
    "quantidadeParcelas" : 10,
    "taxaJurosRemuneratorios" : 2.04,
    "tipoJuros" : {
      "codigo" : 1
    },
    "tipoLiberacao" : {
      "codigo" : 1
    },
    "tipoLiquidacao" : {
      "codigo" : 1
    },
    "valorBase" : 1000.00
  },
  "tarifa" : {
    "valor" : 48.00
  },
  "sistemaTransacao" : {
  },
  "interacaoGrafica" : {
    "dataAcaoUsuario" : "2019-05-09T17:39:09"
  },
  "parametroConsignado" : {
    "codigoFisTabelaJuros" : "1521"
  }
}
	';
	//echo '<pre>'.$data.'</pre>';
	//echo "cttc('".$data."');";
	return envServico($url, "POST", $arrayHeader, $data);
}

function envServico($url, $method, $arrayHeader, $data) {
	
	$ch = curl_init($url);                                                                      
	curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_HTTPHEADER, $arrayHeader);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $data);	
	$result = curl_exec($ch);	
	$GLOBALS["httpcode"] = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	curl_close($ch);
	//echo '<pre>'.htmlentities($result).'</pre>';
	//echo $result;
	//echo "cttc('".$result."');";
	$result = json_decode($result);
	return $result;

}

function gravaTbeprConsignado($nrdconta,$nrctremp,$pejuro_anual,$pecet_anual,$glbvars){
	$xml  = '';
	$xml .= '<Root>';
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
	$xml .= "		<nrctremp>" . $nrctremp . "</nrctremp>";
	$xml .= "		<pejuro_anual>" . str_replace(",", ".",str_replace(".","",$pejuro_anual)) . "</pejuro_anual>";
	$xml .= "		<pecet_anual>" . str_replace(",", ".",str_replace(".","",$pecet_anual)) . "</pecet_anual>";
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	$xmlResult = mensageria(
		$xml,
		"TELA_ATENDA_EMPRESTIMO",
		"GRAVA_TBEPR_CONSIGNADO",
		$glbvars["cdcooper"],
		$glbvars["cdagenci"],
		$glbvars["nrdcaixa"],
		$glbvars["idorigem"],
		$glbvars["cdoperad"],
		"</Root>");		
		
	$xmlObj = getObjectXML($xmlResult);

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
		exibirErro(
			"error",
			$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,
			"Alerta - Ayllos",
			"",
			false);
		exit();
	}
}

function gravaLog($tela,$acao,$dstransal,$dscriticl,$nrdconta,$glbvars,$json,$rs){	
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<dto>';
	$xml .= '       <dstransal>'.$dstransal.'</dstransal>';
	$xml .= '       <dscriticl>'.$dscriticl.'</dscriticl>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';	
	$xml .= '       <json_req>'.utf8_decode(mb_strimwidth($json, 0, 3995, "...")).'</json_req>';
	$xml .= '       <json_res>'.utf8_encode(mb_strimwidth($rs, 0, 3995, "...")).'</json_res>';
	$xml .= '	</dto>';
	$xml .= '</Root>';	
	$xmlResult = mensageria(
		$xml,
		$tela,
		$acao,
		$glbvars["cdcooper"],
		$glbvars["cdagenci"],
		$glbvars["nrdcaixa"],
		$glbvars["idorigem"],
		$glbvars["cdoperad"],
		"</Root>");		
		
	$xmlObj = getObjectXML($xmlResult);

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
		exibirErro(
			"error",
			"Erro ao calcular a parcela no SIV (log), não é possível incluir a proposta de Consignado. Contate a Sede.",
			"Alerta - Ayllos",
			"",
			false);
	}else{
		exibirErro(
				"error",
				"Erro ao calcular a parcela no SIV, não é possível incluir a proposta de Consignado. Contate a Sede.",
				"Alerta - Ayllos",
				"",
				false);
	}
	exit();
}

