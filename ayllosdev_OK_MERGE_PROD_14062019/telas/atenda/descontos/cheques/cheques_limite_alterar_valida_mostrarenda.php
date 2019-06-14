<?php 

	/************************************************************************
	 Fonte: cheques_limite_incluir_valida_mostrarenda.php
	 Autor: Guilherme                                                 
	 Data : Abril/2009                Última Alteração:   /  / 
	                                                                  
	 Objetivo  : Validar dados do primeiro passo e mostrar formulario de 
				 rendas e observações
	                                                                  	 
	 Alterações:                                                      
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["diaratin"]) ||
		!isset($_POST["vllimite"]) ||
		!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrlim"]) ||
		!isset($_POST["dtrating"]) ||
		!isset($_POST["cddlinha"]) ||
		!isset($_POST["vlrrisco"]) ||
		!isset($_POST["inconfir"]) || 
		!isset($_POST["inconfi2"]) ||
		!isset($_POST["inconfi4"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$diaratin = $_POST["diaratin"];
	$vllimite = $_POST["vllimite"];
	$dtrating = $_POST["dtrating"];
	$vlrrisco = $_POST["vlrrisco"];
	$cddlinha = $_POST["cddlinha"];
	$inconfir = $_POST["inconfir"];
	$inconfi2 = $_POST["inconfi2"];
	$inconfi4 = $_POST["inconfi4"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se o do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}
	
	// Verifica se o do contrato é um inteiro válido
	if (!validaData($dtrating)) {
		exibeErro("Data de rating inv&aacute;lida.");
	}	
	
	// Monta o xml de requisição
	$xmlGetDadosLimIncluir  = "";
	$xmlGetDadosLimIncluir .= "<Root>";
	$xmlGetDadosLimIncluir .= "	<Cabecalho>";
	$xmlGetDadosLimIncluir .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlGetDadosLimIncluir .= "		<Proc>valida_proposta_dados</Proc>";
	$xmlGetDadosLimIncluir .= "	</Cabecalho>";
	$xmlGetDadosLimIncluir .= "	<Dados>";
	$xmlGetDadosLimIncluir .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosLimIncluir .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosLimIncluir .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosLimIncluir .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosLimIncluir .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosLimIncluir .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosLimIncluir .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosLimIncluir .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosLimIncluir .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlGetDadosLimIncluir .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetDadosLimIncluir .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlGetDadosLimIncluir .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlGetDadosLimIncluir .= "		<diaratin>".$diaratin."</diaratin>";
	$xmlGetDadosLimIncluir .= "		<vllimite>".$vllimite."</vllimite>";
	$xmlGetDadosLimIncluir .= "		<dtrating>".$dtrating."</dtrating>";
	$xmlGetDadosLimIncluir .= "		<vlrrisco>".$vlrrisco."</vlrrisco>";
	$xmlGetDadosLimIncluir .= "		<cddopcao>A</cddopcao>";
	$xmlGetDadosLimIncluir .= "		<cddlinha>".$cddlinha."</cddlinha>";
	$xmlGetDadosLimIncluir .= "		<inconfir>".$inconfir."</inconfir>";
	$xmlGetDadosLimIncluir .= "		<inconfi2>".$inconfi2."</inconfi2>";
	$xmlGetDadosLimIncluir .= "		<inconfi4>".$inconfi4."</inconfi4>";
	$xmlGetDadosLimIncluir .= "	</Dados>";
	$xmlGetDadosLimIncluir .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosLimIncluir);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosLimIncluir = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDadosLimIncluir->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosLimIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$qtMensagens = count($xmlObjDadosLimIncluir->roottag->tags[0]->tags);
	$mensagem    = $xmlObjDadosLimIncluir->roottag->tags[0]->tags[$qtMensagens - 1]->tags[1]->cdata;
	$inconfir    = $xmlObjDadosLimIncluir->roottag->tags[0]->tags[$qtMensagens - 1]->tags[0]->cdata;

	?>
    inconfir = 01;
	inconfi2 = 11;
	<?
	if ($inconfir == 2){
	?>
			hideMsgAguardo();
			inconfir = "<?php echo $inconfir; ?>";
			showConfirmacao("<?php echo $mensagem; ?>","Confirma&ccedil;&atilde;o - Aimaro","validaPrimeiroPassoAlteracao(inconfir,inconfi2)","metodoBlock()","sim.gif","nao.gif");
	<?
	exit();
	}elseif ($inconfir == 12){
	?>
			hideMsgAguardo();
			inconfi2 = "<?php echo $inconfir; ?>";
			showConfirmacao("<?php echo $mensagem; ?>","Confirma&ccedil;&atilde;o - Aimaro","validaPrimeiroPassoAlteracao(inconfir,inconfi2)","metodoBlock()","sim.gif","nao.gif");
	<?php
	exit();
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>
// Mostrar <div> da renda
$("#divAlteraDscChq_Renda").css("display","block");

// Esconder <div> do primeiro passo
$("#divAlteraDscChq").css("display","none");

$("#vloutras","#frmAlterarDscChq").setMask("DECIMAL","zzz.zzz.zz9,99","");
$("#vlsalari","#frmAlterarDscChq").setMask("DECIMAL","zzz.zzz.zz9,99","");
$("#vlsalcon","#frmAlterarDscChq").setMask("DECIMAL","zzz.zzz.zz9,99","");
$("#dsdbens1","#frmAlterarDscChq").setMask("STRING","60",charPermitido(),"");
$("#dsdbens2","#frmAlterarDscChq").setMask("STRING","60",charPermitido(),"");
$("#dsobserv","#frmAlterarDscChq").setMask("STRING","900",charPermitido(),"");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
<?	
if ($inconfir == 72 || $inconfir == 19) { ?>
		// Mostra informação e continua
		showError("inform","<?php echo $mensagem; ?>","Alerta - Aimaro",metodoBlock);
<?php 
}
?>
