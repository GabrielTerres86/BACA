<? 
/*!
 * FONTE         : manter_rotina.php
 * CRIAÇÃO       : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO  : 17/07/2014
 * OBJETIVO      : Mantem a rotina das informacoes de inclusao, selecao e delecao na tela Conaut
 *
 * ALTERACOES: (Chamado 380686) Correcao no tratamento retorno de criticas do xml
 *      	   (Tiago Castro - RKAM).
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	

	// Tipo de cadastro e opcao	
	$cdtipcad = $_POST['cdtipcad'];
	$cddopcao = $_POST['cddopcao'];
	// Cadastro do biro
	$cdbircon = $_POST['cdbircon'];
	$dsbircon = $_POST['dsbircon'];
	$nmtagbir = $_POST['nmtagbir'];
	// Cadastro da modalidades
	$cdmodbir = $_POST['cdmodbir'];
	$dsmodbir = $_POST['dsmodbir'];
	$inpessoa = $_POST['inpessoa'];
	$nmtagmod = $_POST['nmtagmod'];
	$nrordimp = $_POST['nrordimp'];
	// Tempo de retorno de consultas
	$qtsegrsp = $_POST['qtsegrsp'];
	// Cadastro de propostas
	$vlinicio = $_POST['vlinicio'];
	// Reaproveitamento de consultas
	$inprodut = isset($_POST['inprodut']) ? $_POST['inprodut'] : '' ;
	$qtdiarpv = $_POST['qtdiarpv'];
	// Cadastro de contingencia
	$dtinicon = $_POST['dtinicon'];
	
	if ($cdtipcad == 'B' || $cddopcao == "I0" || $cddopcao == "A3") {  // Cadastro de biros
		
		if ($cdtipcad == "P" && $cddopcao == "I0") { 
			$strnomacao = 'CRAPMBR';
		}
		else {
			$strnomacao = 'CRAPBIR';	
		}
	}	
	elseif ($cdtipcad == 'M' || $cddopcao == "I2" || $cddopcao == "A4") { // Cadastro de modalidades
		$strnomacao = 'CRAPMBR';
	}
	elseif ($cdtipcad == 'C') { // Cadastro de contingencia
		$strnomacao = 'CRAPCBR';
	}
	elseif ($cdtipcad == 'R') { // Reaproveitamento de consultas
		$strnomacao = 'CRAPRBI';
	}
	elseif ($cdtipcad == 'P') { // Cadastro de propostas`
		$strnomacao = 'CRAPPCB';
	} 
	elseif ($cdtipcad == 'T') {  // Tempo de consulta
		$strnomacao = 'CONAUT_CRAPPRM';
	}
	
	$bkp_cddopcao = $cddopcao;
		
	if ($cddopcao == 'C' || $cddopcao == 'A1' || $cddopcao == 'E1' || $cddopcao == 'I0'  || $cddopcao == 'A3' || $cddopcao == "I2" || $cddopcao == "A4") { 

	   if ( $cddopcao != "I2" && $cddopcao != "I0") {		 
			$inpessoa = '';
	   }

	   if ( !($cdtipcad == "T" && ($cddopcao == 'C' || $cddopcao == "A1" || $cddopcao == "E1"))) {
		   //$inprodut = '';
	   }
	   	  
		$cddopcao = 'C';
	     	   
	}
		
	// Montar o xml para requisicao
	$xml_requisicao  = "";
	$xml_requisicao .= "<Root>";
	$xml_requisicao .= " <Dados>";
	$xml_requisicao .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml_requisicao .= "    <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xml_requisicao .= "    <cddopcao>".$cddopcao."</cddopcao>";
	$xml_requisicao .= "    <cdbircon>".$cdbircon."</cdbircon>";
	$xml_requisicao .= "    <dsbircon>".$dsbircon."</dsbircon>";
	$xml_requisicao .= "    <nmtagbir>".$nmtagbir."</nmtagbir>";
	$xml_requisicao .= "    <vlinicio>".$vlinicio."</vlinicio>";
	$xml_requisicao .= "    <cdmodbir>".$cdmodbir."</cdmodbir>";
	$xml_requisicao .= "    <dsmodbir>".$dsmodbir."</dsmodbir>";
	$xml_requisicao .= "    <inpessoa>".$inpessoa."</inpessoa>";
	$xml_requisicao .= "    <nmtagmod>".$nmtagmod."</nmtagmod>";
	$xml_requisicao .= "    <nrordimp>".$nrordimp."</nrordimp>";
	$xml_requisicao .= "    <dtinicon>".$dtinicon."</dtinicon>";
	$xml_requisicao .= "    <inprodut>".$inprodut."</inprodut>";
 	$xml_requisicao .= "    <qtdiarpv>".$qtdiarpv."</qtdiarpv>";
	$xml_requisicao .= "    <qtsegrsp>".$qtsegrsp."</qtsegrsp>";
	$xml_requisicao .= " </Dados>";
	$xml_requisicao .= "</Root>";
 
	$xmlResult = mensageria($xml_requisicao, "CONAUT", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObj    = getObjectXML($xmlResult);
	   
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	  $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	  exibirErro('error',$msgErro,'Alerta - Ayllos',false);
	}	
	
	
	if ($cdtipcad == 'B')
		$dsCadastro = 'Bir&ocirc;';
	elseif ($cdtipcad == 'M') 
	    $dsCadastro = 'Modalidade';
	elseif ($cdtipcad == "C") 
	    $dsCadastro = 'Conting&ecirc;ncia';
	elseif ($cdtipcad == "R") 
		$dsCadastro = 'Reaproveitamento de consulta';
	elseif ($cdtipcad == "P") 
	    $dsCadastro = 'Parametriza&ccedil;&atilde;o da proposta';
	elseif ($cdtipcad == "T")
		$dsCadastro = 'Tempo de retorno';
	else
		$dsCadastro = '';
			
	if ( ($cdtipcad == "M" || $cdtipcad == "C" || $cdtipcad == "P") && ($strnomacao == "CRAPBIR" || $bkp_cddopcao == "I0" )) { // Consulta de biros no cadastro de modalidades (Alteracao e Inclusao)
		//retorno dos registros
		$registros = $xmlObj->roottag->tags;
				
		// Remover opcoes ja existentes
		echo '$("option",$("#dsbircon","#form_opcao_' . strtolower($cdtipcad) . '")).remove();';
				
		// Incluir opcoes de biro
		foreach ($registros as $biro) {
				
			$cdbircon = getByTagName($biro->tags,'cdbircon');
			$dsbircon = getByTagName($biro->tags,'dsbircon');
			
			if ($arr_dsbiron[$cdbircon] == $dsbircon) {
				continue;
			}
			
   	    	echo '$("#dsbircon","#form_opcao_' . strtolower($cdtipcad) . '").append("<option value=' . "$cdbircon" . '>' . $dsbircon . '</option>");';
			
			$arr_dsbiron[$cdbircon] = $dsbircon;
					
		}
	}	
	elseif ($cdtipcad == "P" && $strnomacao	== "CRAPMBR") { // Consulta de modalidades
		
		//retorno dos registros
		$registros = $xmlObj->roottag->tags;
				
		// Remover opcoes ja existentes
		echo '$("option",$("#dsmodbir","#form_opcao_' . strtolower($cdtipcad) . '")).remove();';
		
		$dsmodbir_selected = $dsmodbir;
				
		// Incluir opcoes de modalidade
		foreach ($registros as $modalidade) {
				
			$cdmodbir = getByTagName($modalidade->tags,'cdmodbir');
			$dsmodbir = getByTagName($modalidade->tags,'dsmodbir');
			
			$selected = ($dsmodbir_selected == $dsmodbir) ? " selected" : "";
						   	  
			echo '$("#dsmodbir","#form_opcao_' . strtolower($cdtipcad) . '").append("<option value=' . "$cdmodbir" . $selected . '>' . $dsmodbir . '</option>");';

					
		}
	}
	elseif  ($cddopcao == 'A') { // Alterar o biro
		$msgOK = "$dsCadastro alterado/a com sucesso!";
	}
	elseif ($cddopcao == 'I') { // Inclusao de biros
		$msgOK = "$dsCadastro criado/a com sucesso!";
	}
	elseif ($cddopcao == "E") { // Exclusao do biro
		$msgOK = "$dsCadastro excluido/a com sucesso!";
	} else {
		
		//retorno dos registros
		$registros = $xmlObj->roottag->tags;
		
		switch ($cdtipcad) {
			case "B": {
				include ('tabela_biro.php');
				break;
			}
			case "M": {
				include ('tabela_modalidade.php');
				break;
			}
			case "C": {
				include ('tabela_contingencia.php');
				break;
			}
			case "R": {
				include ('tabela_reaproveitamento.php');
				break;
			}
			case "P": {
				include ('tabela_proposta.php');
				break;
			}
			case "T": {				
				$qtsegrsp = $xmlObj->roottag->tags[0]->cdata; 
				echo '$("#qtsegrsp","#form_opcao_t").val(' . $qtsegrsp . ');';
				break;
			}
		
		}

 	}
 
	if ($msgOK != '') {
		exibirErro('inform',$msgOK,'Alerta - Ayllos',false);
	}
	
?>