<?
/*!
 * FONTE        : conta_corrente.php
 * CRIAÇÃO      : Heitor (Mouts)
 * DATA CRIAÇÃO : julho/2017
 * OBJETIVO     : Mostrar opcao conta corrente da rotina de Liberar/Bloquear da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 08/08/2017 - Implementacao da melhoria 438. Heitor (Mouts).
 *								15/03/2018 - Adicionada opção para sinalizar cancelamento automático de conta corrente
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

	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;

	switch( $operacao ) {
		case 'MA': $op = "A"; break;
		case 'AM': $op = "@"; break;
		default  : $op = "@"; break;
	}

	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op)) <> "")
	exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]))
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];

	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "ATENDA", "DESOPE_BUSCA_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
	}

	include('form_conta_corrente.php');
?>
<script type='text/javascript'>
	$('#flgrenli','#frmContaCorrente').val('<? echo (getByTagName($xmlObjeto->roottag->tags[0]->tags,'flgrenli') == 0) ? "no" : "yes" ?>');
	$('#flmajora','#frmContaCorrente').val('<? echo (getByTagName($xmlObjeto->roottag->tags[0]->tags,'flmajora') == 0) ? "no" : "yes" ?>');
	$('#flcnaulc','#frmContaCorrente').val('<? echo (getByTagName($xmlObjeto->roottag->tags[0]->tags,'flcnaulc') == 0) ? "no" : "yes" ?>');
	$('#motivo_bloqueio_maj','#frmContaCorrente').val('<? echo (getByTagName($xmlObjeto->roottag->tags[0]->tags,'dsmotmaj'))?>');
	$('#cdopemaj','#frmContaCorrente').val('<? echo (getByTagName($xmlObjeto->roottag->tags[0]->tags,'cdopemaj'))?>');
	$('#nmopemaj','#frmContaCorrente').val('<? echo (getByTagName($xmlObjeto->roottag->tags[0]->tags,'nmopemaj'))?>');
	var operacao = '<? echo $operacao;  ?>';
	controlaLayout(operacao);
</script>
