<?php 

	//************************************************************************//
	//*** Fonte: resgate_cadastrar.php                                     ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2009                 Última Alteração: 10/05/2018 ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar e cadastrar resgate para aplicação           ***//	
	//***                                                                  ***//	 
	//*** Alterações: 27/10/2010 - Ajuste nas mensagens de notificacao re- ***//
	//***                          tornadas após a validação (David).      ***//
	//***															       ***//
	//***             01/12/2010 - Alterado a chamada da BO b1wgen0004.p   ***//
	//***                          para a BO b1wgen0081.p (Adriano).       ***//
	//***																   ***//
	//***			  04/12/2014 - Incluido resgate de novos produtos de   ***//
	//***						   captação. (Jean Michel)				   ***//
	//***																   ***//	
    /*         		  17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) */
    //***																   ***//
	//***			  10/05/2018 - Permitir resgate de aplicações          ***//
	//***						   bloqueadas (SM404)				   	   ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nraplica"]) || !isset($_POST["tpresgat"]) || !isset($_POST["vlresgat"]) ||
		!isset($_POST["dtresgat"]) || !isset($_POST["flgctain"]) || !isset($_POST["flmensag"]) || !isset($_POST["tpaplica"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nraplica = $_POST["nraplica"];	
	$tpresgat = $_POST["tpresgat"];
	$vlresgat = $_POST["vlresgat"];
	$dtresgat = $_POST["dtresgat"];
	$flgctain = $_POST["flgctain"];
	$flmensag = $_POST["flmensag"];	
	$tpaplica = $_POST["tpaplica"];	
	
	$cdopera2 = (isset($_POST['cdopera2'])) ? $_POST['cdopera2'] : '';
	$cddsenha = (isset($_POST['cddsenha'])) ? $_POST['cddsenha'] : '';
	$flgsenha = ($cdopera2 != '') ? '1' : '0';
	
	$cdopelib = (isset($_SESSION['cdopelib'])) ? $_SESSION['cdopelib'] : '';
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o número da aplicação é um inteiro válido
	if (!validaInteiro($nraplica)) {
		exibeErro("N&uacute;mero da aplica&ccedil;&atilde;o inv&aacute;lida.");
	}	
	
	// Verifica se o valor de resgate é um inteiro válido
	if (!validaDecimal($vlresgat)) {
		exibeErro("Valor do resgate inv&aacute;lido.");
	}
	
	// Verifica se a data de resgate é válida
	if (!validaData($dtresgat)) {
		exibeErro("Data do resgate inv&aacute;lida.");
	}	
	
	// Verifica se flag de recebimento em conta investimento é válida
	if ($flgctain <> "yes" && $flgctain <> "no") {
		exibeErro("Identificador de resgate inv&aacute;lido.");
	}

	// Verifica se flag de envio de mensagem é válida
	if ($flmensag <> "yes" && $flmensag <> "no") {
		exibeErro("Identificador de resgate inv&aacute;lido.");
	}
	
	// Verifica se tipo de aplicação é valido, caso não for, atribui como aplicação antiga
	if ($tpaplica <> "N" && $tpaplica <> "A") {
		$tpaplica = "A";
	}
	
	// Verifica se é produto antigo ou novo	
	if($tpaplica == "A"){		
		// Monta o xml de requisição
		$xmlResgate  = "";
		$xmlResgate .= "<Root>";
		$xmlResgate .= "	<Cabecalho>";
		$xmlResgate .= "		<Bo>b1wgen0081.p</Bo>";
		$xmlResgate .= "		<Proc>cadastrar-resgate-aplicacao</Proc>";
		$xmlResgate .= "	</Cabecalho>";
		$xmlResgate .= "	<Dados>";
		$xmlResgate .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlResgate .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
		$xmlResgate .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlResgate .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlResgate .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlResgate .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xmlResgate .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlResgate .= "		<idseqttl>1</idseqttl>";
		$xmlResgate .= "		<nraplica>".$nraplica."</nraplica>";
		$xmlResgate .= "		<tpresgat>".$tpresgat."</tpresgat>";
		$xmlResgate .= "		<vlresgat>".$vlresgat."</vlresgat>";
		$xmlResgate .= "		<dtresgat>".$dtresgat."</dtresgat>";
		$xmlResgate .= "		<flgctain>".$flgctain."</flgctain>";
		$xmlResgate .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
		$xmlResgate .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
		$xmlResgate .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";
		$xmlResgate .= "		<flmensag>".$flmensag."</flmensag>";		
		$xmlResgate .= "		<cdopera2>".$cdopera2."</cdopera2>";
		$xmlResgate .= "		<cddsenha>".$cddsenha."</cddsenha>";
		$xmlResgate .= "	</Dados>";
		$xmlResgate .= "</Root>";	
		
		//var_dump($xmlResgate);
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlResgate);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjResgate = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjResgate->roottag->tags[0]->name) == "ERRO") {
			//var_dump($xmlResgate);
			exibeErro($xmlObjResgate->roottag->tags[0]->tags[0]->tags[4]->cdata);
		// Senão, gera log com os dados da autorização e exclui o bloqueio no caso de resgate total (SM404)
		}else{
			if(isset($_SESSION['cdopelib'])) {
				$vlresgat = str_replace(',','.',str_replace('.','',$vlresgat));
				// Montar o xml de Requisicao
				$xml .= "<Root>";
				$xml .= " <Dados>";
				$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; // Código da cooperativa
				$xml .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>"; // Código do operador
				$xml .= "   <cdopelib>".$_SESSION['cdopelib']."</cdopelib>"; // Código do coordenador
				$xml .= "   <nrdconta>".$nrdconta."</nrdconta>"; // Número da Conta
				$xml .= "   <nraplica>".$nraplica."</nraplica>"; // Número da Aplicação
				$xml .= "   <vlresgat>".$vlresgat."</vlresgat>"; // Valor do resgate
				$xml .= "   <tpresgat>".$tpresgat."</tpresgat>"; // Tipo do resgate
				$xml .= "	<idseqttl>1</idseqttl>";
				$xml .= " </Dados>";
				$xml .= "</Root>";
				
				$xmlResult = mensageria($xml, "APLI0002", "PROC_POS_RESGATE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
				$xmlObj = getObjectXML($xmlResult);
								
				//-----------------------------------------------------------------------------------------------
				// Controle de Erros
				//-----------------------------------------------------------------------------------------------
				
				if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
					$msgErro = $xmlObj->roottag->tags[0]->cdata;
					
					if($msgErro == null || $msgErro == ''){
						$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
					}
					
					exibeErro($msgErro,$frm);			
					exit();
				}else{
					$_SESSION['cdopelib'] = null;
				}
			}
		} 
			
		// Esconde mensagem de aguardo
		echo 'hideMsgAguardo();';	
		
		if ($flmensag == "yes") {		
			$msgConfirma = $xmlObjResgate->roottag->tags[0]->tags;		
			
			if (count($msgConfirma) > 1) {			
				echo 'var metodoConfirm = \'showConfirmacao("'.$msgConfirma[0]->tags[1]->cdata.'","Confirma&ccedil;&atilde;o - Aimaro","cadastrarResgate(\\\'no\\\')","blockBackground(parseInt($(\\\'#divRotina\\\').css(\\\'z-index\\\')))","sim.gif","nao.gif")\';';				
				// Quebrar mensagem em duas linhas
				$strMsg = $msgConfirma[1]->tags[1]->cdata;
				$strMsg = trim(substr($strMsg,0,strpos($strMsg,".") + 1))."<br>".trim(substr($strMsg,strpos($strMsg,".") + 1));

				echo 'showError("inform","'.$strMsg.'","Notifica&ccedil;&atilde;o - Aimaro",metodoConfirm);';			
			} else {				
				echo 'showConfirmacao("Confirma opera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","cadastrarResgate(\'no\')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
			}
		} else {
			echo 'flgoprgt = true;';
			
			// Bloqueia conteúdo que está atrás do div da rotina
			echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
			
			// Voltar para opção geral de resgate
			echo 'voltarDivResgate();';
		}
	}else{
		$vlresgat = str_replace(',','.',str_replace('.','',$vlresgat));
		$tpresgat = $tpresgat == 'T' ? 2 : 1;
		$flgctain = $flgctain == 'no' ? 0 : 1;
		
		// Montar o xml de Requisicao
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>"; // Número da Conta
		$xml .= "   <nraplica>".$nraplica."</nraplica>"; // Número da Aplicação
		$xml .= "   <dtresgat>".$dtresgat."</dtresgat>"; // Data do Resgate (Data informada em tela)
		$xml .= "   <vlresgat>".$vlresgat."</vlresgat>"; // Valor do Resgate (Valor informado em tela)
		$xml .= "   <idseqttl>1</idseqttl>"; 			 // Sequencial de titular 
		$xml .= "   <idtiprgt>".$tpresgat."</idtiprgt>"; // Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total)
		$xml .= "   <idrgtcti>".$flgctain."</idrgtcti>"; // Resgate na Conta Investimento (Identificador informado em tela, 0 – Não)
		$xml .= "   <idvldblq>1</idvldblq>"; 			 // Identificador de validação do bloqueio judicial (0 – Não / 1 – Sim)
		$xml .= "   <idgerlog>1</idgerlog>"; 			 // Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)					
		$xml .= "   <idvalida>0</idvalida>"; 			 // Identificador de Validacao (0 – Valida / 1 - Cadastra)	
		$xml .= "   <cdopera2>".$cdopera2."</cdopera2>"; // Operador
		$xml .= "   <cddsenha>".$cddsenha."</cddsenha>"; // Senha
		$xml .= "   <flgsenha>".$flgsenha."</flgsenha>"; // Validar senha
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "ATENDA", "VALRES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
						
		//-----------------------------------------------------------------------------------------------
		// Controle de Erros
		//-----------------------------------------------------------------------------------------------
		
		if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
			
			if($msgErro == null || $msgErro == ''){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			
			exibeErro($msgErro,$frm);			
			exit();
		}else{
			echo 'hideMsgAguardo();';
			echo "showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Aimaro','cadastraNovaAplicacaoResgate()','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))','sim.gif','nao.gif');";	
		}
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>