<? 
/*!
 * FONTE        : pricipal.php
 * CRIAÇÃO      : Marcelo Leandro Pereira
 * DATA CRIAÇÃO : 31/09/2011
 * OBJETIVO     : Mostrar opcao Principal da rotina de Seguro da tela ATENDA
 * ALTERAÇÕES   : 25/07/2013 - Incluído o campo Complemento no endereço. (James).		
 */
session_start();
	
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");
// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");
	
// Verifica se tela foi chamada pelo método POST
isPostMethod();	
	
if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
	exibeErro($msgError);		
}
	
// Verifica se número da conta foi informado
if (!isset($_POST["nrdconta"])) {
	exibeErro("Par&acirc;metros incorretos.");
}

$nrdconta = $_POST["nrdconta"];

// Verifica se número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}

$operacao = (isset($_POST['operacao'])?$_POST['operacao']:'');
$nrctrseg = (isset($_POST['nrctrseg'])?$_POST['nrctrseg']:'');
$cdsegura = (isset($_POST['cdsegura'])?$_POST['cdsegura']:'');
$tpseguro = (isset($_POST['tpseguro'])?$_POST['tpseguro']:'');
$cdsitpsg = (isset($_POST['cdsitpsg'])?$_POST['cdsitpsg']:'');

$nrctrseg = ( $nrctrseg == 'null' ) ? '' : $nrctrseg ;
$cdsegura = ( $cdsegura == 'null' ) ? '' : $cdsegura ;
$tpseguro = ( $tpseguro == 'null' ) ? '' : $tpseguro ;
$cdsitpsg = ( $cdsitpsg == 'null' ) ? '' : $cdsitpsg ;

if($operacao == 'C_AUTO'){
	$procedure = 'seguro_auto';
}else if($operacao == 'C_CASA'){
	$procedure = 'buscar_seguro_geral';
}else if($operacao == 'SEGUR'){
	$procedure = 'buscar_seguradora';
	$tpseguro=11;
	$cdsitpsg=1;
}else{
	$procedure = 'busca_seguros';
}

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0033.p</Bo>";
$xml .= "		<Proc>".$procedure."</Proc>";
$xml .= "	</Cabecalho>";
$xml .= "	<Dados>";
$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "		<nrctrseg>".$nrctrseg."</nrctrseg>";
$xml .= "		<idseqttl>1</idseqttl>";
$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xml .= "		<cdsegura>".$cdsegura."</cdsegura>";
$xml .= "		<tpseguro>".$tpseguro."</tpseguro>";
$xml .= "		<cdsitpsg>".$cdsitpsg."</cdsitpsg>";
$xml .= "		<flgerlog>FALSE</flgerlog>";	
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

// Cria objeto para classe de tratamento de XML
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
} 

if(in_array($operacao,array('C_AUTO'))){
	$seguro_auto = $xmlObjeto->roottag->tags[0]->tags[0]->tags;

	?><script type="text/javascript">
	
		var arraySeguroAuto = new Object();
		
		arraySeguroAuto['nmresseg'] = '<? echo getByTagName($seguro_auto,'nmdsegur'); ?>';
		arraySeguroAuto['dsmarvei'] = '<? echo getByTagName($seguro_auto,'dsmarvei'); ?>';
		arraySeguroAuto['dstipvei'] = '<? echo getByTagName($seguro_auto,'dstipvei'); ?>';
		arraySeguroAuto['nranovei'] = '<? echo getByTagName($seguro_auto,'nranovei'); ?>';
		arraySeguroAuto['nrmodvei'] = '<? echo getByTagName($seguro_auto,'nrmodvei'); ?>';
		arraySeguroAuto['nrdplaca'] = '<? echo getByTagName($seguro_auto,'nrdplaca'); ?>';
		arraySeguroAuto['dtinivig'] = '<? echo getByTagName($seguro_auto,'dtinivig'); ?>';
		arraySeguroAuto['dtfimvig'] = '<? echo getByTagName($seguro_auto,'dtfimvig'); ?>';
		arraySeguroAuto['qtparcel'] = '<? echo getByTagName($seguro_auto,'qtparcel'); ?>';
		arraySeguroAuto['vlpreseg'] = '<? echo getByTagName($seguro_auto,'vlpreseg'); ?>';
		arraySeguroAuto['vlpremio'] = '<? echo getByTagName($seguro_auto,'vlpremio'); ?>';
		arraySeguroAuto['dtdebito'] = '<? echo getByTagName($seguro_auto,'dtdebito'); ?>';
		
	</script><?
}else if(in_array($operacao,array('C_CASA'))){
	$seguros = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	
	?>
	
	<script type="text/javascript">
		
		var arraySeguroCasa = new Object();
		
		arraySeguroCasa['nmresseg'] = '<? echo getByTagName($seguros,'nmresseg'); ?>';
		arraySeguroCasa['nrctrseg'] = '<? echo getByTagName($seguros,'nrctrseg'); ?>';
		arraySeguroCasa['tpplaseg'] = '<? echo getByTagName($seguros,'tpplaseg'); ?>';
		arraySeguroCasa['ddpripag'] = '<? echo getByTagName($seguros,'dtprideb'); ?>';
		arraySeguroCasa['ddpripag'] = arraySeguroCasa['ddpripag'].split("/");
		arraySeguroCasa['ddpripag'] = arraySeguroCasa['ddpripag'][0];
			
		arraySeguroCasa['ddvencto'] = '<? echo getByTagName($seguros,'dtdebito'); ?>';
		arraySeguroCasa['ddvencto'] = arraySeguroCasa['ddvencto'].split("/");
		arraySeguroCasa['ddvencto'] = arraySeguroCasa['ddvencto'][0];
		
		arraySeguroCasa['vlpreseg'] = '<? echo getByTagName($seguros,'vlpreseg'); ?>';
		arraySeguroCasa['dtinivig'] = '<? echo getByTagName($seguros,'dtinivig'); ?>';
		arraySeguroCasa['dtfimvig'] = '<? echo getByTagName($seguros,'dtfimvig'); ?>';
		arraySeguroCasa['flgclabe'] = '<? echo getByTagName($seguros,'flgclabe'); ?>';
		arraySeguroCasa['nmbenvid'] = '<? echo $seguros[28]->tags[0]->cdata; ?>';
		arraySeguroCasa['dtcancel'] = '<? echo getByTagName($seguros,'dtcancel'); ?>';
		arraySeguroCasa['dsmotcan'] = '<? echo getByTagName($seguros,'dsmotcan'); ?>';
		
		arraySeguroCasa['nrcepend'] = '<? echo getByTagName($seguros,'nrcepend'); ?>';
		arraySeguroCasa['dsendres'] = '<? echo getByTagName($seguros,'dsendres'); ?>';
		arraySeguroCasa['nrendere'] = '<? echo getByTagName($seguros,'nrendres'); ?>';
		arraySeguroCasa['complend'] = '<? echo getByTagName($seguros,'complend'); ?>';
		arraySeguroCasa['nmbairro'] = '<? echo getByTagName($seguros,'nmbairro'); ?>';
		arraySeguroCasa['nmcidade'] = '<? echo getByTagName($seguros,'nmcidade'); ?>';
		arraySeguroCasa['cdufresd'] = '<? echo getByTagName($seguros,'cdufresd'); ?>';
		
		arraySeguroCasa['tpendcor'] = '<? echo getByTagName($seguros,'tpendcor'); ?>';
		
	</script><?
}else if($operacao == 'SEGUR'){
	$seguradoras  = $xmlObjeto->roottag->tags[0]->tags;
}else if($operacao == ''){
	$seguros = $xmlObjeto->roottag->tags[0]->tags;
}

// Procura indíce da opção "@"
$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
if ($idPrincipal === false) {
	$idPrincipal = 0;
}

// Função para exibir erros na tela através de javascript
function exibeErro($msgErro) { 
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	echo '</script>';
	exit();
}

// Se estiver consultando, chamar a TABELA
if(in_array($operacao,array(''))) {
	include('tabela_seguro.php');
}else if(in_array($operacao,array('I'))){
	include('tipo_seguro.php');
}else if(in_array($operacao,array('TF'))){
	include('form_seguro.php');
}else if(in_array($operacao,array('TI','CONSULTAR','ALTERAR'))){
	include('form_seguro_vida_prest.php');
}else if(in_array($operacao,array('C_AUTO'))){
	include('form_auto.php');
}else if(in_array($operacao,array('C_CASA'))){
	include('form_seguro_casa.php');
}else if(in_array($operacao,array('SEGUR'))) {
	include('tabela_seguradora.php');
}else if(in_array($operacao,array('I_CASA'))) {
	include('form_seguro_casa.php');
}
?>
<script type="text/javascript"> 
 
controlaLayout('<?php echo $operacao;?>');
// Esconde mensagem de aguardo
hideMsgAguardo();
// Bloqueia conteúdo que está atras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
<? if($operacao == 'C_CASA'){ ?> formataCep(); <? } ?>
</script>