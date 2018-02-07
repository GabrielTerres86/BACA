<? 
/*!
 * FONTE        : valida_senha_cooperado.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 07/12/2017 
 * OBJETIVO     : Rotina para validar a senha do cooperado
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Varivel de controle do caracter
	$nrdconta 	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$dssencar	= (isset($_POST['dssencar'])) ? $_POST['dssencar'] : '' ;
	$inpessoa	= (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '' ;
	$idastcjt	= (isset($_POST['idastcjt'])) ? $_POST['idastcjt'] : '' ;	

	// Verifica se os parâmetros necessários foram informados
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','',false);
	if ($dssencar === "") exibirErro('error','Favor informar a senha.','Alerta - Ayllos','',false);

	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <idtipcar>1</idtipcar>";
	$xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CUSTOD", "RETORNA_CARTAO_VALIDO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	}

	$registrosCartaoMagnetico = ( isset($xmlObj->roottag->tags) ) ? $xmlObj->roottag->tags : array();

	// ---------------------------

	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <idtipcar>2</idtipcar>";
	$xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CUSTOD", "RETORNA_CARTAO_VALIDO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	}

	$registrosCartaoCredito = ( isset($xmlObj->roottag->tags) ) ? $xmlObj->roottag->tags : array();

	// ---------------------------	

	if (count($registrosCartaoMagnetico)) {

		validarCartaoMagnetico();

	} else if (count($registrosCartaoCredito)) {

		validarCartaoCredito();

	} else {

		$msgErro = 'Nenhum cartao foi encontrado';
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);

	}

	function validarCartaoMagnetico(){

		global $nrdconta, $dssencar, $glbvars, $registrosCartaoMagnetico, $registrosCartaoCredito, $inpessoa, $idastcjt;

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

					} else {

						$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
						exibirErro('error',$msgErro,'Alerta - Ayllos','',false);

					}


				} else {

					continue;

				}

			} else {

				if ($inpessoa > 1 && $idastcjt == 1) {
					echo "formRespAssinatura()";
					exit();
				} else {
					echo "efetuaResgate()";
					exit();
				}

			}

		}

	}

	function validarCartaoCredito(){

		global $nrdconta, $dssencar, $glbvars, $registrosCartaoCredito, $inpessoa, $idastcjt;

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

				if($lastArrayKey == $key){

					$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
					exibirErro('error',$msgErro,'Alerta - Ayllos','',false);

				} else {

					continue;

				}

			} else {

				if ($inpessoa > 1 && $idastcjt == 1) {
					echo "formRespAssinatura()";
					exit();
				} else {
					echo "efetuaResgate()";
					exit();
				}
			}			
		}
	}	
?>
