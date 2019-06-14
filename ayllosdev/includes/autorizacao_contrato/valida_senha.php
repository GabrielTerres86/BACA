<? 
/*!
 * FONTE        : valida_senha.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 18/12/2018
 * OBJETIVO     : Rotina para validar senha
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$dssencar	= (isset($_POST['dssencar'])) ? $_POST['dssencar'] : '' ;

	$nrdconta    = (isset($_POST["nrdconta"]))    ? $_POST["nrdconta"]    : "";
	$tpcontrato  = (isset($_POST["tpcontrato"]))  ? $_POST["tpcontrato"]  : "";
	$vlcontrato  = (isset($_POST["vlcontrato"]))  ? $_POST["vlcontrato"]  : "";

	//bruno - prj 470 - alt 1
	$nrcontrato  = (isset($_POST["nrcontrato"]))  ? $_POST["nrcontrato"]  : "";

	$nrSenhas = (isset($_POST["nrSenhas"]))  ? $_POST["nrSenhas"]  : "";
	
    $obrigatoria  = (isset($_POST["obrigatoria"]))  ? $_POST["obrigatoria"]  : "";

    $contador = 1;
    
    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= "  <Dados>";
    $xml .= "    <nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "    <tpcontrato>" . $tpcontrato . "</tpcontrato>";
    $xml .= "    <vlcontrato>" . $vlcontrato . "</vlcontrato>";
    $xml .= "    <nrcontrato>" . $nrcontrato . "</nrcontrato>";
    $xml .= "  </Dados>";
    $xml .= "</Root>";
    
    $xmlResult = mensageria($xml, "TELA_AUTCTD", "VER_CARTAO_MAG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = simplexml_load_string($xmlResult);

    if ($xmlObj->Erro->Registro->dscritic != '') {
		$msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
		exibirErro('inform',$msgErro,'Alerta - Aimaro','', false);
	}

    $contas = $xmlObject->inf->contas;
    $qtContas = count($contas);

    /* Irá percorrer todas as contas, e para cada conta, irá passar por todos os cartões existentes da conta, a fim de
       verificar se a senha digitada pertence a algum dos cartões de alguma das contas. */
    foreach ($contas as $keyConta => $conta) {

    	$nrdconta = $conta->nrdconta;
    	$inpessoa = $conta->inpessoa;

		// Montar o xml de Requisicao
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <idtipcar>1</idtipcar>";
		//enviar valor 3 para inpessoa 1 para retornar cartoes somente do titular quando conta PF
		$xml .= "   <inpessoa>".($inpessoa == "1" ? '4' : $inpessoa)."</inpessoa>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "TELA_CUSTOD", "RETORNA_CARTAO_VALIDO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);

		if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			if($msgErro == null || $msgErro == ''){
				$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
			}
			exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
			exit();
		}

		$registrosCartaoMagnetico = ( isset($xmlObj->roottag->tags) ) ? $xmlObj->roottag->tags : array();

		// Montar o xml de Requisicao
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <idtipcar>2</idtipcar>";
		//enviar valor 3 para inpessoa 1 para retornar cartoes somente do titular quando conta PF
		$xml .= "   <inpessoa>".($inpessoa == "1" ? '4' : $inpessoa)."</inpessoa>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "TELA_CUSTOD", "RETORNA_CARTAO_VALIDO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);

		

		if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			if($msgErro == null || $msgErro == ''){
				$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
			}
			exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
			exit();
		}

		$registrosCartaoCredito = ( isset($xmlObj->roottag->tags) ) ? $xmlObj->roottag->tags : array();

		//var_dump(count($registrosCartaoMagnetico), count($registrosCartaoCredito), "Contador: ".$contador, "nrdconta: ".$nrdconta);

		if (count($registrosCartaoMagnetico)) {
			validarCartaoMagnetico();
		}
		
		if (count($registrosCartaoCredito)) {
			validarCartaoCredito();
		}

		/** 
		 * Mostrar mensagem de O socio de conta xxxxxx não possui cartão quando:
		 * cartão magnetico == 0
		 * cartão normal == 0
		 * obrigatoria == T ou nrSenhas == 1
		*/
		if(count($registrosCartaoMagnetico) == 0 && 
		   count($registrosCartaoCredito) == 0 && 
		   ($obrigatoria == "T" || $nrSenhas == 1)){
			$msgErro = 'O sócio de conta ' . $nrdconta . ' não possui cartão.';
			exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
			exit();
		}

		if($qtContas == $contador){
			// Se chegou até aqui é pq passou por todas as contas e cartôes e a senha não é valida
			echo 'invalida';
			exit();
		}

		$contador++;
	}

	function validarCartaoMagnetico(){

		global $nrdconta, $dssencar, $glbvars, $registrosCartaoMagnetico, $registrosCartaoCredito;

		$arrayKeys = array_keys($registrosCartaoMagnetico);
		$lastArrayKey = array_pop($arrayKeys);

		foreach ($registrosCartaoMagnetico as $key => $result) {

			$nrcartao = getByTagName($result->tags,'nrcartao');

			//----------------------------------------------------------------------------------------------------------------------------------	
			// Primeiro validar com senha do cartão Magnetico (idtipcar = 1), 
			// caso retorne erro, tentar validar com a senha cartão Credito (idtipcar = 2).
			//----------------------------------------------------------------------------------------------------------------------------------

			// Monta o xml dinâmico de acordo com a operação 
			$xml  = '';
			$xml .= '<Root>';
			$xml .= '	<Cabecalho>';
			$xml .= '		<Bo>b1wgen0025.p</Bo>';
			$xml .= '		<Proc>valida_senha_tp_cartao</Proc>';
			$xml .= '	</Cabecalho>';
			$xml .= '	<Dados>';
			$xml .= '       <cdcooper>'.$glbvars["cdcooper"].'</cdcooper>';	
			$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
			$xml .= '		<nrcrcard>'.$nrcartao.'</nrcrcard>';
			$xml .= '		<idtipcar>1</idtipcar>';
			$xml .= '		<dssencar>'.$dssencar.'</dssencar>';
			$xml .= '		<infocry></infocry>';
			$xml .= '		<chvcry></chvcry>';
			$xml .= '	</Dados>';
			$xml .= '</Root>';
			
			$xmlResult = getDataXML($xml);
			$xmlObjeto = getObjectXML($xmlResult);

			if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {

				// Verifica se ja testou todos os cartoes magneticos possiveis da conta
				if($lastArrayKey == $key){	

					//Verifica se existe cartoes credito, caso nao, retornar erro
					if(count($registrosCartaoCredito)){
						
						validarCartaoCredito();

					}

				} else {

					continue;

				}

			} else {

				// Retorna a conta na qual a senha foi correta
				echo $nrdconta;
				exit();

			}

		}

	}

	function validarCartaoCredito(){

		global $nrdconta, $dssencar, $glbvars, $registrosCartaoCredito;

		$arrayKeys = array_keys($registrosCartaoMagnetico);
		$lastArrayKey = array_pop($arrayKeys);

		foreach ($registrosCartaoCredito as $result) {
			
			$nrcartao = getByTagName($result->tags,'nrcartao');
		
			// Monta o xml dinâmico de acordo com a operação 
			$xml  = '';
			$xml .= '<Root>';
			$xml .= '	<Cabecalho>';
			$xml .= '		<Bo>b1wgen0025.p</Bo>';
			$xml .= '		<Proc>valida_senha_tp_cartao</Proc>';
			$xml .= '	</Cabecalho>';
			$xml .= '	<Dados>';
			$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';	
			$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
			$xml .= '		<nrcrcard>'.$nrcartao.',00</nrcrcard>';
			$xml .= '		<idtipcar>2</idtipcar>';
			$xml .= '		<dssencar>'.$dssencar.'</dssencar>';
			$xml .= '		<infocry></infocry>';
			$xml .= '		<chvcry></chvcry>';
			$xml .= '	</Dados>';
			$xml .= '</Root>';
			
			$xmlResult = getDataXML($xml);
			$xmlObjeto = getObjectXML($xmlResult);
			if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	

				if($lastArrayKey != $key){
					continue;
				}

			} else {
				// Retorna a conta na qual a senha foi correta
				echo $nrdconta;
				exit();

			}			

		}
	}	
?>
