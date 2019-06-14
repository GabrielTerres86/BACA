<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Mateus Z (Mouts)
 * DATA CRIAÇÃO : Abril/2018 
 * OBJETIVO     : Mostrar opcao Principal da rotina de FATCA/CRS da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------

 */	
?>

<?	
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op)) <> "") exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	$nrcpfcgc = $_POST["nrcpfcgc"] == "" ? 0 : $_POST["nrcpfcgc"];

	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '@';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';	

	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);

	$qtOpcoesTela = count($opcoesTela);

	// Carregas as opções da Rotina de Fatca/CRS
	$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "    <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "    <nriniseq>1</nriniseq>";
	$xml .= "    <nrregist>9999</nrregist>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
 
	$xmlResult = mensageria($xml, "TELA_FATCA_CRS", "BUSCAR_DADOS_FATCA_CRS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj    = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','fechaRotina(divRotina)',false);
	}

	$dados = $xmlObj->roottag->tags[0]->tags[0]->tags;
		
	include('formulario_fatca_crs.php');
	
?>
<script type='text/javascript'>
	operacao = '<? echo $operacao; ?>';	

	var flgAlterar   = "<? echo $flgAlterar;   ?>";
	var flgcadas     = "<? echo $flgcadas;     ?>";
		
	if (flgcadas == 'M' && operacao != 'CA') {
		controlaOperacao('CA');
	}

	controlaLayout();
</script>
