<?php 

	/************************************************************************
	 Fonte: cheques_limite_consultar.php                          
	 Autor: Guilherme                                                 
	 Data : Março/2009                        Última Alteração: 20/08/2015
	                                                                  
	 Objetivo  : Carregar dados para consulta de um limite
	                                                                  	 
	 Alterações: 14/06/2010 - Adaptação para RATING (David).
				 20/08/2015 - Ajuste feito para não inserir caracters 
						      especiais na observação, conforme solicitado
							  no chamado 315453 (Kelvin).
				 12/07/2019 - Ajustes referente a reformulação da tela avalista - PRJ 438 - Sprint 14 (Mateus Z / Mouts)
						
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
	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrlim"]) ||
		!isset($_POST["cddopcao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$cddopcao = $_POST["cddopcao"];
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}	
	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisição
	$xmlGetDados = "";
	$xmlGetDados .= "<Root>";
	$xmlGetDados .= "	<Cabecalho>";
	$xmlGetDados .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlGetDados .= "		<Proc>busca_dados_limite_consulta</Proc>";
	$xmlGetDados .= "	</Cabecalho>";
	$xmlGetDados .= "	<Dados>";
	$xmlGetDados .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDados .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDados .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDados .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDados .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetDados .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetDados .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDados .= "		<idseqttl>1</idseqttl>";
	$xmlGetDados .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDados .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlGetDados .= "	</Dados>";
	$xmlGetDados .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDados);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML(retiraAcentos(removeCaracteresInvalidos($xmlResult)));
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$dados = $xmlObjDados->roottag->tags[0]->tags[0]->tags;
	$avais = $xmlObjDados->roottag->tags[1]->tags;
	
	
	
	// Variável que armazena código da opção para utilização na include cheques_limite_formulario.php
//	$cddopcao = "C";
	
	// Include para carregar formulário para gerenciamento de dados do limite
	include("cheques_limite_formulario.php");
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<script type="text/javascript">
	var arrayAvalistas = new Array();
	nrAvalistas     = 0;
	contAvalistas   = 1;
	<? 
	for ($i=0; $i<count($avais); $i++) {
	    if (getByTagName($avais[$i]->tags,'nrctaava') != 0 || getByTagName($avais[$i]->tags,'nrcpfcgc') != 0) {
	?>
			var arrayAvalista<? echo $i; ?> = new Object();
			arrayAvalista<? echo $i; ?>['nrctaava'] = '<? echo getByTagName($avais[$i]->tags,'nrctaava'); ?>';
			arrayAvalista<? echo $i; ?>['cdnacion'] = '<? echo getByTagName($avais[$i]->tags,'cdnacion'); ?>';
			arrayAvalista<? echo $i; ?>['dsnacion'] = '<? echo getByTagName($avais[$i]->tags,'dsnacion'); ?>';
			arrayAvalista<? echo $i; ?>['tpdocava'] = '<? echo getByTagName($avais[$i]->tags,'tpdocava'); ?>';
			arrayAvalista<? echo $i; ?>['nmconjug'] = '<? echo getByTagName($avais[$i]->tags,'nmconjug'); ?>';
			arrayAvalista<? echo $i; ?>['tpdoccjg'] = '<? echo getByTagName($avais[$i]->tags,'tpdoccjg'); ?>';
			arrayAvalista<? echo $i; ?>['dsendre1'] = '<? echo getByTagName($avais[$i]->tags,'dsendre1'); ?>';
			arrayAvalista<? echo $i; ?>['nrfonres'] = '<? echo getByTagName($avais[$i]->tags,'nrfonres'); ?>';
			arrayAvalista<? echo $i; ?>['nmcidade'] = '<? echo getByTagName($avais[$i]->tags,'nmcidade'); ?>';
			arrayAvalista<? echo $i; ?>['nrcepend'] = '<? echo getByTagName($avais[$i]->tags,'nrcepend'); ?>';
			arrayAvalista<? echo $i; ?>['nmdavali'] = '<? echo getByTagName($avais[$i]->tags,'nmdavali'); ?>';
			arrayAvalista<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($avais[$i]->tags,'nrcpfcgc'); ?>';
			arrayAvalista<? echo $i; ?>['nrdocava'] = '<? echo getByTagName($avais[$i]->tags,'nrdocava'); ?>';
			arrayAvalista<? echo $i; ?>['nrcpfcjg'] = '<? echo getByTagName($avais[$i]->tags,'nrcpfcjg'); ?>';
			arrayAvalista<? echo $i; ?>['nrdoccjg'] = '<? echo getByTagName($avais[$i]->tags,'nrdoccjg'); ?>';
			arrayAvalista<? echo $i; ?>['dsendre2'] = '<? echo getByTagName($avais[$i]->tags,'dsendre2'); ?>';
			arrayAvalista<? echo $i; ?>['dsdemail'] = '<? echo getByTagName($avais[$i]->tags,'dsdemail'); ?>';
			arrayAvalista<? echo $i; ?>['cdufresd'] = '<? echo getByTagName($avais[$i]->tags,'cdufresd'); ?>';
			arrayAvalista<? echo $i; ?>['vlrenmes'] = '<? echo getByTagName($avais[$i]->tags,'vlrenmes'); ?>';
			arrayAvalista<? echo $i; ?>['vledvmto'] = '<? echo getByTagName($avais[$i]->tags,'vledvmto'); ?>';
			arrayAvalista<? echo $i; ?>['nrendere'] = '<? echo getByTagName($avais[$i]->tags,'nrendere'); ?>';
			arrayAvalista<? echo $i; ?>['complend'] = '<? echo getByTagName($avais[$i]->tags,'complend'); ?>';
			arrayAvalista<? echo $i; ?>['nrcxapst'] = '<? echo getByTagName($avais[$i]->tags,'nrcxapst'); ?>';
			arrayAvalista<? echo $i; ?>['inpessoa'] = '<? echo getByTagName($avais[$i]->tags,'inpessoa'); ?>';
			arrayAvalista<? echo $i; ?>['dtnascto'] = '<? echo getByTagName($avais[$i]->tags,'dtnascto'); ?>';
			arrayAvalista<? echo $i; ?>['nrctacjg'] = '<? echo getByTagName($avais[$i]->tags,'nrctacjg'); ?>';
			arrayAvalista<? echo $i; ?>['vlrencjg'] = '<? echo getByTagName($avais[$i]->tags,'vlrencjg'); ?>';
			arrayAvalistas[<? echo $i; ?>] = arrayAvalista<? echo $i; ?>;
			nrAvalistas++;
	<?	
		}
	}
	?>
	habilitaAvalista(false, operacao);
</script>