<? 
/*!
 * FONTE        : cheques_limite_alterar.php
 * CRIA��O      : Guilherme
 * DATA CRIA��O : Abril/2009
 * OBJETIVO     : Carregar dados para alterar um limite existente	             		        				   
 * --------------
 * ALTERA��ES   :
 * --------------
 * 000: [15/07/2009] Guilherme		 	(CECRED) : Titulos para "frames".	
 * 000: [14/06/2010] David           	(CECRED) : Adapta��o para RATING
 * 001: [06/05/2011] Rogerius Militao      (DB1) : Adapta��o no formul�rio de avalista gen�rico
 * 002: [20/08/2015] Kelvin 			(CECRED) : Ajuste feito para n�o inserir caracters 
 *												   especiais na observa��o, conforme solicitado
 *	   										       no chamado 315453.
 * 003: [12/07/2019] Mateus Zimmermann	 (Mouts) : Ajustes referente a reformula��o da tela avalista - 
 *                                                 PRJ 438 - Sprint 14 (Mateus Z / Mouts)
 */
?>


<?php 

	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrlim"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi��o
	$xmlGetDados = "";
	$xmlGetDados .= "<Root>";
	$xmlGetDados .= "	<Cabecalho>";
	$xmlGetDados .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlGetDados .= "		<Proc>busca_dados_limite_altera</Proc>";
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$dados = $xmlObjDados->roottag->tags[0]->tags[0]->tags;
	$avais = $xmlObjDados->roottag->tags[1]->tags;
	$risco = $xmlObjDados->roottag->tags[2]->tags;
	
	
	
	// Alimentar data rating
	for ($i = 0; $i < count($risco); $i++) { 								
		if ($risco[$i]->tags[4]->cdata <> 0) {
			?>
			<script type="text/javascript">
			dtrating = '<?php echo subDiasNaData($glbvars["dtmvtolt"],$risco[$i]->tags[4]->cdata); ?>';
			diaratin = '<?php echo $risco[$i]->tags[4]->cdata; ?>';
			vlrrisco = '<?php echo $risco[$i]->tags[3]->cdata; ?>';
			</script>
			<?php
		}
	}
	
	// Vari�vel que armazena c�digo da op��o para utiliza��o na include cheques_limite_formulario.php
	$cddopcao = "A";
	
	// Include para carregar formul�rio para gerenciamento de dados do limite
	include("cheques_limite_formulario.php");
	
	// Fun��o para exibir erros na tela atrav�s de javascript
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
	habilitaAvalista(true, operacao);
</script>