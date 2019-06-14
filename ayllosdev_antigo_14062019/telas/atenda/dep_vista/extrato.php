<?php 

	//************************************************************************//
	//*** Fonte: extrato.php                                               ***//
	//*** Autor: Guilherme                                                 ***//
	//*** Data : Fevereiro/2009               Última Alteração: 24/05/2018 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao Principal da rotina de Conta           ***//
	//***             Investimento da tela ATENDA  			               ***//
	//***                                                                  ***//
	//*** Alterações: 15/07/2009 - Pesquisar pelo último dia do mês quando ***//
	//***                          entrar na rotna (Guilherme).            ***//
	//***                                                                  ***//
	//***             24/06/2011 - Alterado para layout padrão             ***//
	//***                          (Gabriel - DB1).                        ***//
	//***                                                                  ***//
	//***             15/09/2011 - Alterado contagem da quantidade de      ***//
	//***                          lançamentos do extrato (David).         ***//
  //***                                                                  ***//
  //***             24/05/2018 - Incluído label para mensagem            ***// 
  //***                          se está, ou se houve prejuízo na CC     ***//
  //***                          Projeto Regulatório de Crédito          ***//
  //***                          Diego Simas - AMcom                     ***//
  //***                                                                  ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dtiniper = isset($_POST["dtiniper"]) && validaData($_POST["dtiniper"]) ? $_POST["dtiniper"] : "01/".substr($glbvars["dtmvtolt"],3);
	$dtfimper = isset($_POST["dtfimper"]) && validaData($_POST["dtfimper"]) ? $_POST["dtfimper"] : $glbvars["dtmvtolt"];
	$iniregis = isset($_POST["iniregis"]) ? $_POST["iniregis"] : 1;
	$qtregpag = 50;

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Monta o xml de requisição
	$xmlGetExtrato  = "";
	$xmlGetExtrato .= "<Root>";
	$xmlGetExtrato .= "	<Cabecalho>";
	$xmlGetExtrato .= "		<Bo>b1wgen0001.p</Bo>";
	$xmlGetExtrato .= "		<Proc>extrato-paginado</Proc>";
	$xmlGetExtrato .= "	</Cabecalho>";
	$xmlGetExtrato .= "	<Dados>";
	$xmlGetExtrato .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetExtrato .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetExtrato .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetExtrato .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetExtrato .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetExtrato .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetExtrato .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetExtrato .= "		<idseqttl>1</idseqttl>";
	$xmlGetExtrato .= "		<dtiniper>".$dtiniper."</dtiniper>";
	$xmlGetExtrato .= "		<dtfimper>".$dtfimper."</dtfimper>";	
	$xmlGetExtrato .= "		<iniregis>".$iniregis."</iniregis>";
	$xmlGetExtrato .= "		<qtregpag>".$qtregpag."</qtregpag>";
	$xmlGetExtrato .= "	</Dados>";
	$xmlGetExtrato .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetExtrato);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjExtrato = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjExtrato->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjExtrato->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$extrato   = $xmlObjExtrato->roottag->tags[0]->tags;
	$qtregist  = $xmlObjExtrato->roottag->tags[0]->attributes["QTREGIST"];
	$qtExtrato = count($extrato);
	
	// Procura indíce da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}		

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
	//Mensageria referente a situação de prejuízo
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_ATENDA_DEPOSVIS", "CONSULTA_PREJU_CC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
	$xmlObjeto = getObjectXML($xmlResult);	
	
	$param = $xmlObjeto->roottag->tags[0]->tags[0];

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"controlaOperacao('');",false); 
	}else{
		$despreju = getByTagName($param->tags,'despreju');	    
	}
	
?>

<form action="" name="frmExtDepVista" id="frmExtDepVista" method="post" >
	
	<input type="hidden" name="iniregis" id="iniregis" value="<?php echo $iniregis; ?>">
			
	<label for="dtiniper"><? echo utf8ToHtml('Período:') ?></label>
	<input type="text" name="dtiniper" id="dtiniper" value="<?php echo $dtiniper; ?>" autocomplete="no">
	
	<label for="dtfimper"><? echo utf8ToHtml('à:') ?></label>
	<input type="text" name="dtfimper" id="dtfimper" value="<?php echo $dtfimper; ?>" autocomplete="no">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/pesquisar.gif" onClick="obtemExtrato();return false;">

	<?php
		if($despreju != ''){
			echo "<label><font color='red'>&nbsp;&nbsp;".$despreju."</font></label>";
		}
	?>
			
</form>

<br />

<? include('tabela_extrato.php'); ?>

<script type="text/javascript">

controlaLayout('frmExtDepVista');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));	

dtiniper = "<?php echo $dtiniper; ?>";
dtfimper = "<?php echo $dtfimper; ?>";
</script>