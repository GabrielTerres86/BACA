<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO : 03/02/2015 
 * OBJETIVO     : Rotina para manter as operações da tela parrac
 * --------------
 * ALTERAÇÕES   : 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	
	// Recebe a operação que está sendo realizada
	$operacao	= (isset($_POST['operacao'])) ? $_POST['operacao'] :'C1'; 
	$nrseqvac	= (isset($_POST['nrseqvac'])) ? $_POST['nrseqvac'] : 0; 
	$cddopcao   = "C";
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}	
	
	switch ($operacao) {
		case 'C1': { $strnomacao = 'CRAPVAC'; break; }
		case 'C2': { $strnomacao = 'CRAPQAC'; break; }
	}
	
	// Montar o xml para requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "    <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "    <nrseqvac>".$nrseqvac."</nrseqvac>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
 
	$xmlResult = mensageria($xml, "PARRAC", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObj    = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	$xml_dados = simplexml_load_string($xmlResult);

	if ($operacao == "C1") {
	
		$inf       = $xml_dados->inf;
		$qtregist  = count($inf); 	
		
		$strnomacao = 'DESABILITA_PARECER_RATING';
		
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "    <cddopcao>C</cddopcao>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
	 
		$xmlResult = mensageria($xml, "PARRAC", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		$xmlObj    = getObjectXML($xmlResult);
		
		$xml_dados = simplexml_load_string($xmlResult);
		
		$inparece = $xml_dados->inparece;
		
		include("tab_crapvac.php");
	}
	else if ($operacao == "C2") {
	
		$indicadores  = $xml_dados->indicadores;
		$qtregist_ind = count($indicadores);  
				
		$arr_criterios["01"] = "Idade máxima para Atenção:";
		$arr_criterios["02"] = "Idade mínima para Atenção:";
		$arr_criterios["11"] = "Tempo Mínimo de Fundação (meses):";
		$arr_criterios["21"] = "Comprometimento mínimo:";
		$arr_criterios["22"] = "Comprometimento mínimo:";
		$arr_criterios["24"] = "Comprometimento mínimo:";
		$arr_criterios["25"] = "Comprometimento mínimo:";
		$arr_criterios["31"] = "Tipo Res.:";
		$arr_criterios["32"] = "Mensagem para mesmo tipo com meses superiores:";
		$arr_criterios["33"] = "Tipo Res.:";
		$arr_criterios["34"] = "Mensagem para mesmo tipo com meses superiores:";
		$arr_criterios["35"] = "Tipo Res.:";
		$arr_criterios["36"] = "Mensagem para mesmo tipo com meses superiores:";
		$arr_criterios["41"] = "Tempo máximo (meses):";
		$arr_criterios["51"] = "Tempo máximo (meses) da conta:";
		$arr_criterios["61"] = "Situações com análise manual:";
		$arr_criterios["71"] = "Status quando valor financiado é superior a reciprocidade:";
		$arr_criterios["81"] = "Saldo médio mínimo:";
		$arr_criterios["90"] = "Meses:";
		$arr_criterios["91"] = "Quantidade mín. Chq sem fundos:";
		$arr_criterios["92"] = "Quantidade mín. Chq sem fundos:";
		$arr_criterios["100"] = "Meses:";
		$arr_criterios["101"] = "Quantidade mínima de estouros:";
		$arr_criterios["110"] = "Meses:";
		$arr_criterios["111"] = "Valor:";
		$arr_criterios["121"] = "Limite Renda:";
		$arr_criterios["122"] = "Limite Renda:";
		$arr_criterios["123"] = "Acima de:";	
		$arr_criterios["125"] = "Limite Renda:";
		$arr_criterios["126"] = "Limite Renda:";
		$arr_criterios["127"] = "Acima de:";	
		$arr_criterios["131"] = "Valor:";
		$arr_criterios["141"] = "Valor:";
		$arr_criterios["151"] = "Status quando existir restrições relevantes:";
		$arr_criterios["152"] = "Status quando existir restrições justificadas e aceitas:";
		$arr_criterios["153"] = "Status até 3 restrições com somatório inferior a R$ 1.000,00:";
		$arr_criterios["161"] = "Status quando cooperado é avalista em outras operações:";
			
		include("tab_crapqac.php");
	}
 ?>