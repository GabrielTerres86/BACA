<?php

	//************************************************************************//
	//*** Fonte: autentica_crm.php                                         ***//
	//*** Autor: Lucas Reinert                                             ***//
	//*** Data : Setembro/2017                Última Alteração: --/--/---- ***//
	//***                                                                  ***//
	//*** Objetivo  : Rotina para efetuar a autenticação do usuário no     ***//	
	//***             Ayllos pelo CRM.                                     ***//	 
	//***                                                                  ***//	 
	//*** Alterações: 										               ***//
	//************************************************************************//
	session_start();	
	
	// Includes para variáveis globais de controle, e biblioteca de funções
	require_once("includes/config.php");
	require_once("includes/funcoes.php");		
	
	isPostMethod(true);
	
	// Parâmetros enviados pelo CRM
	$inacesso   = isset($_POST["CRM_INACESSO"]) ? $_POST["CRM_INACESSO"] : 0;
	$nmdatela   = isset($_POST["CRM_NMDATELA"]) ? $_POST["CRM_NMDATELA"] : "";
	$nrdconta   = isset($_POST["CRM_NRDCONTA"]) ? $_POST["CRM_NRDCONTA"] : 0;
	$nrcpfcgc   = isset($_POST["CRM_NRCPFCGC"]) ? $_POST["CRM_NRCPFCGC"] : 0;
	$cdcooper   = isset($_POST["CRM_CDCOOPER"]) ? $_POST["CRM_CDCOOPER"] : 0;
	$cdoperad   = isset($_POST["CRM_CDOPERAD"]) ? $_POST["CRM_CDOPERAD"] : "";
	$cdpactra   = isset($_POST["CRM_CDAGENCI"]) ? $_POST["CRM_CDAGENCI"] : "";
	$dstoken    = isset($_POST["CRM_DSTOKEN"]) ? $_POST["CRM_DSTOKEN"] : "";
	
	// Verificar parâmetros recebidos
	if (trim($inacesso) == 0  || 
		trim($nmdatela) == "" || 
		trim($nrdconta) == 0  || 
		trim($nrcpfcgc) == 0  || 
		trim($cdoperad) == "" || 
		trim($cdpactra) == "" || 
		trim($cdcooper) == 0  || 
		trim($dstoken)  == "") {
		$dsmsgerr = "Dados n&atilde;o informados corretamente.";
		echo $dsmsgerr;
		exit();
	} else {		
	
		// Monta o xml de requisição
		$xmlLogin  = "";
		$xmlLogin .= "<Root>";
		$xmlLogin .= "  <Cabecalho>";
		$xmlLogin .= "      <Bo>b1wgen0000.p</Bo>";
		$xmlLogin .= "      <Proc>efetua_login</Proc>";
		$xmlLogin .= "  </Cabecalho>";
		$xmlLogin .= "  <Dados>";
		$xmlLogin .= "      <cdcooper>".$cdcooper."</cdcooper>";
		$xmlLogin .= "      <cdagenci>".$cdpactra."</cdagenci>";
		$xmlLogin .= "      <nrdcaixa>0</nrdcaixa>";
		$xmlLogin .= "      <cdoperad>".$cdoperad."</cdoperad>";
		$xmlLogin .= "      <idorigem>5</idorigem>";			
		$xmlLogin .= "      <vldsenha>no</vldsenha>";
		$xmlLogin .= "      <cddsenha></cddsenha>";
		$xmlLogin .= "      <cdpactra>".$cdpactra."</cdpactra>";
		$xmlLogin .= "  </Dados>";
		$xmlLogin .= "</Root>";
		
		// Classe para leitura do xml de retorno
		require_once("class/xmlfile.php");	
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlLogin,false,true,$cdcooper);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjLogin = getObjectXML($xmlResult);
		
		// Se BO retornou alguma erro, atribui crítica a variável $dsmsgerr
		if (strtoupper($xmlObjLogin->roottag->tags[0]->name) == "ERRO") {
			$dsmsgerr = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[4]->cdata;
			echo $dsmsgerr;
			exit();
		} else {
			// Verifica se está sendo efetuado um login no momento
			$flglogin = false;
			$inilogin = strtotime("now");
			
			while (($flglogin = isset($_SESSION["sidlogin"]))) {				
				// 5 segundos é o tempo limite para efetuar o login
				if ((strtotime("now") - $inilogin) >= 5) {
					break;
				}
			}
			
			if ($flglogin) {
				if (($inilogin - $_SESSION["hrdlogin"]) >= 10) {
					$flglogin = false;
				} else {
					$dsmsgerr = "Sistema ocupado. Um tentativa de login j&aacute; estava sendo efetuada.";
					echo $dsmsgerr;
					exit();

				}
			} 
			
			if (!$flglogin) {				
				// Criar SID de login para armazenamento de dados na SESSION
				$sidlogin = md5(time().uniqid());						
				$cdoperad = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[13]->cdata;							
				
				// Armazena SID para utilizar no momento que a HOME é carregada
				$_SESSION["sidlogin"] = $sidlogin;				
				$_SESSION["hrdlogin"] = strtotime("now");
				
				// Cria array temporário com variáveis globais					
				$glbvars["cdcooper"] = $cdcooper;		
				$glbvars["nmcooper"] = strtolower($xmlObjLogin->roottag->tags[0]->tags[0]->tags[1]->cdata);	
				$glbvars["cdagenci"] = 0;
				$glbvars["nrdcaixa"] = 0;
				$glbvars["cdoperad"] = $cdoperad;							
				$glbvars["nmoperad"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[0]->cdata;				
				$glbvars["dtmvtolt"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[2]->cdata;
				$glbvars["dtmvtopr"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[3]->cdata;
				$glbvars["dtmvtoan"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[4]->cdata;
				$glbvars["inproces"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[5]->cdata;
				$glbvars["idorigem"] = 5;
				$glbvars["idsistem"] = 1;
				$glbvars["stimeout"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[6]->cdata;
				$glbvars["dsdepart"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[7]->cdata;
				$glbvars["dsdircop"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[8]->cdata;
				$glbvars["hraction"] = strtotime("now");
				$glbvars["flgdsenh"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[9]->cdata; // Verifica se tem q trocar de senha 
				$glbvars["sidlogin"] = $sidlogin;
				$glbvars["cdpactra"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[10]->cdata;
				$glbvars["flgperac"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[11]->cdata;
				$glbvars["nvoperad"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[12]->cdata;
				$glbvars["cddepart"] = $xmlObjLogin->roottag->tags[0]->tags[0]->tags[14]->cdata;
				$glbvars["idparame_reciproci"] = 0;
				$glbvars["desretorno"] = "NOK";
				
				// Armazena os dados globais na session
				$_SESSION["glbvars"][$sidlogin] = $glbvars;				
				
				// Devemos validar o token do operador
				// Montar o xml de Requisicao
				$xml  = "<Root>";
				$xml .= " <Dados>";
				$xml .= " <dstoken>".$dstoken."</dstoken>";
				$xml .= " </Dados>";
				$xml .= "</Root>";
				
				$xmlResult = mensageria($xml, "CADA0011", "VALIDA_TOKEN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
				$xmlObj = getObjectXML($xmlResult);		
				//-----------------------------------------------------------------------------------------------
				// Controle de Erros
				//-----------------------------------------------------------------------------------------------
				
				if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
					$msgErro = $xmlObj->roottag->tags[0]->cdata;
					if($msgErro == null || $msgErro == ''){
						$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
					}
					echo $msgErro;
					exit();
				}

				
				// Efetuar login através do form para forçar o acesso via POST
				// Assim é possível impedir que o operador carregue a HOME diretamente no browse
				?>
				<html>
				<head>
				</head>
				<body>
				<form action="home.php" name="frmLogin" id="frmLogin" method="post">				
				<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $sidlogin; ?>">
				<input type="hidden" name="CRM_INACESSO" id="CRM_INACESSO" value="<? echo $inacesso; ?>" />
				<input type="hidden" name="CRM_NMDATELA" id="CRM_NMDATELA" value="<? echo $nmdatela; ?>" />
				<input type="hidden" name="CRM_NRDCONTA" id="CRM_NRDCONTA" value="<? echo $nrdconta; ?>" />
				<input type="hidden" name="CRM_NRCPFCGC" id="CRM_NRCPFCGC" value="<? echo $nrcpfcgc; ?>" />
				<input type="hidden" name="CRM_CDCOOPER" id="CRM_CDCOOPER" value="<? echo $cdoperad; ?>" />
				<input type="hidden" name="CRM_CDOPERAD" id="CRM_CDOPERAD" value="<? echo $cdpactra; ?>" />
				<input type="hidden" name="CRM_CDAGENCI" id="CRM_CDAGENCI" value="<? echo $cdcooper; ?>" />
				<input type="hidden" name="CRM_DSTOKEN" id="CRM_DSTOKEN"   value="<? echo $dstoken; ?>" />
				</form>
				<script type="text/javascript">document.frmLogin.submit();</script>
				</body>
				</html>				
				<?php				
				
				exit();
			}
		} 
	}

?>
