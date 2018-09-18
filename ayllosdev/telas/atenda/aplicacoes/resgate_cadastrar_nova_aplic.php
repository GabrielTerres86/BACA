<?php 
	//************************************************************************//
	//*** Fonte: resgate_cadastrar_nova_aplic.php                          ***//
	//*** Autor: Jean Michel                                               ***//
	//*** Data : Dezembro/2014                Última Alteração: 		   ***//
	//***                                                                  ***//
	//*** Objetivo  : Cadastrar resgate para aplicação de novos produtos   ***//	
	//***			  de captacao.										   ***//
	//***                                                                  ***//	 
	//*** Alterações: 													   ***//
	//***																   ***//	
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") { exibeErro($msgError); }	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nraplica"]) || !isset($_POST["tpresgat"]) || 
		!isset($_POST["vlresgat"]) || !isset($_POST["dtresgat"]) || !isset($_POST["flgctain"])) {		
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$vlresgat = $_POST["vlresgat"];
	$tpresgat = $_POST["tpresgat"];
	$flgctain = $_POST["flgctain"];
	$nraplica = $_POST["nraplica"];
	$dtresgat = $_POST["dtresgat"];	
    $cdopera2 = (isset($_POST['cdopera2'])) ? $_POST['cdopera2'] : '';
	$cddsenha = (isset($_POST['cddsenha'])) ? $_POST['cddsenha'] : '';
	$flgsenha = ($cdopera2 != '') ? '1' : '0';

	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) { exibeErro("Conta/dv inv&aacute;lida. Conta: " . $nrdconta); }	
	
	// Verifica se o número da aplicação é um inteiro válido
	if (!validaInteiro($nraplica)) { exibeErro("N&uacute;mero da aplica&ccedil;&atilde;o inv&aacute;lida.");	}	
	
	// Verifica se o valor de resgate é um inteiro válido
	if (!validaDecimal($vlresgat)) { exibeErro("Valor do resgate inv&aacute;lido.");	}
	
	// Verifica se a data de resgate é válida
	if (!validaData($dtresgat)) { exibeErro("Data do resgate inv&aacute;lida."); }	
	
	// Verifica se flag de recebimento em conta investimento é válida
	if ($flgctain <> "yes" && $flgctain <> "no") { exibeErro("Identificador de resgate inv&aacute;lido."); }
		
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
	$xml .= "   <idvalida>1</idvalida>"; 			 // Identificador de Validacao (0 – Valida / 1 - Cadastra)					
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
		echo 'acessaRotina("APLICACOES","Aplica&ccedil;&otilde;es","aplicacoes");'; 
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
?>