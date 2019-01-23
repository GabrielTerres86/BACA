<?php 

	/***************************************************************************
	 Fonte: aplicacoes_programadas_carregar.php                             
	 Autor: David                                                     
     Data : Março/2010                   Ultima Alteracao: 10/09/2018
	 
	 Objetivo  : Mostrar opção para alterar Aplicação Programada      
	                                                                  
	 Alterações: 04/04/2018 - Chamada da rotina para verificar se o tipo de conta permite produto 
				              16 - Poupança Programada. PRJ366 (Lombardi).
							  
				 27/07/2018 - Derivação para Aplicação Programada 
				 
				 10/09/2018 - Inclusao do Campo Finalidade - Proj. 411.2
				 
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	$cdprodut = $_POST["cdprodut"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da "poupança" é um inteiro válido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
			
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cdprodut>". 16 ."</cdprodut>"; //Poupança Programada
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro(utf8_encode($msgErro));
	}
	
	// Monta o xml de requisição
	$xmlAlterar  = "";
	$xmlAlterar .= "<Root>";
	$xmlAlterar .= "	<Cabecalho>";
	$xmlAlterar .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlAlterar .= "		<Proc>obtem-dados-alteracao</Proc>";
	$xmlAlterar .= "	</Cabecalho>";
	$xmlAlterar .= "	<Dados>";
	$xmlAlterar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAlterar .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlAlterar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlAlterar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlAlterar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlAlterar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlAlterar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAlterar .= "		<idseqttl>1</idseqttl>";
	$xmlAlterar .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";
	$xmlAlterar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlAlterar .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlAlterar .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlAlterar .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";	
	$xmlAlterar .= "	</Dados>";
	$xmlAlterar .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlAlterar);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAlterar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAlterar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAlterar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	*/

	// Montar o xml de Requisicao
	$xmlAlterar = "<Root>";
	$xmlAlterar .= " <Dados>";
	$xmlAlterar .= "	<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAlterar .= "	<idseqttl>1</idseqttl>";
	$xmlAlterar .= "	<nrctrrpp>".$nrctrrpp."</nrctrrpp>";
	$xmlAlterar .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlAlterar .= "	<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlAlterar .= "	<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlAlterar .= "   <flgerlog>1</flgerlog>";
	$xmlAlterar .= " </Dados>";
	$xmlAlterar .= "</Root>";

	$xmlResult = mensageria($xmlAlterar, "APLI0008", "OBTEM_DADOS_ALTERACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjAlterar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjAlterar->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjAlterar->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro(utf8_encode($msgErro));
	}

	$poupanca = $xmlObjAlterar->roottag->tags[0]->tags[0]->tags;	
	$diadebit = $poupanca[7]->cdata;
	$dsfinali = $poupanca[28]->cdata ; // Finalidade

	// Flags para montagem do formul�rio
	$flgAlterar   = true;
	$flgSuspender = false;	
	$legend 	  = "Alterar";
	include("aplicacoes_programadas_formulario_dados.php");

	include("aplicacoes_programadas_formulario_dados.php");

?>	
<script type="text/javascript">
	$("#vlprerpp","#frmDadosPoupanca").focus();
</script>
<?php 
	// Funcao para exibir erros na tela atraves de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
	
?>											
