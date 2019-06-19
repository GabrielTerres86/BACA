<?php
/*!
 * FONTE        : manter_motivos.php
 * CRIAÇÃO      : Petter Rafael - Envolti
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Mostrar opcao pre-aprovado da rotina de Motivos da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
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
	if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], $op)) <> "") 
	exibirErro('error', $msgError, 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)', false);
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) 
		exibirErro('error', 'Par&acirc;metros incorretos.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)', false);
    
    $nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Ayllos','bloqueiaFundo(divRotina)', false);

    // Monta o xml de requisição
	$xml = "<Root>";
	$xml .= "	<Dados>";
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= "	</Dados>";
	$xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_ATENDA_PREAPV", "MOTIVO_SEM_PREAPV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata == "" ? $xmlObjeto->roottag->tags[0]->cdata : $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;

		exibirErro('error', htmlentities($msgErro), 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);', false);
	}

    include('form_motivos.php');
?>
<script>
    tabelaLayout();
    hideMsgAguardo();
    blockBackground(parseInt($("#divRotina").css("z-index")));
</script>