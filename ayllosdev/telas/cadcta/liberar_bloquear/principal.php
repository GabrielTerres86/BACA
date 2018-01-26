<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Mostrar opcao Principal da rotina de Liberar/Bloquear da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 05/01/2016 - Adicionar leitura dos campos do XML flgcrdpa e libcrdpa, para
                               o comportamento do campo de libera credito pre-aprovado (Anderson)
							   
				  27/07/2016 - Adicionados novos campos para a fase 3 do projeto pre aprovado.
							   Rotinas convertidas para o oracle (Lombardi)
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
		case 'CA': $op = "A"; break;
		case 'AC': $op = "@"; break;
		default  : $op = "@"; break;
	}
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op)) <> "") 
	exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) 
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"] == "" ? 0 : $_POST["idseqttl"];
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	
	if ($idseqttl==0) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_CONTAS_DESAB", "DESOPE_BUSCA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
	}

	include('form_liberar_bloquear.php');
?>
<script type='text/javascript'>
	$('#flgrenli','#frmLiberarBloquear').val('<? echo (getByTagName($xmlObjeto->roottag->tags[0]->tags,'flgrenli') == 0) ? "no" : "yes" ?>');
	$('#flgcrdpa','#frmLiberarBloquear').val('<? echo (getByTagName($xmlObjeto->roottag->tags[0]->tags,'flgcrdpa') == 0) ? "no" : "yes" ?>');
	$('#dtultatt','#frmLiberarBloquear').val('<? echo getByTagName($xmlObjeto->roottag->tags[0]->tags,'dtatualiza') ?>');
	$('#motivo_bloqueio','#frmLiberarBloquear').val('<? echo getByTagName($xmlObjeto->roottag->tags[0]->tags,'dsmotivo') ?>');
	$('#liberado_sem','#frmLiberarBloquear').val('<? echo (getByTagName($xmlObjeto->roottag->tags[0]->tags,'preautom') == 0) ? "no" : "yes" ?>');
	$('#liberado_man','#frmLiberarBloquear').val('<? echo (getByTagName($xmlObjeto->roottag->tags[0]->tags,'premanua') == 0) ? "no" : "yes" ?>');
	$('#dscarga','#frmLiberarBloquear').val('<? echo getByTagName($xmlObjeto->roottag->tags[0]->tags,'dscarga') ?>');
	$('#dtinicial','#frmLiberarBloquear').val('<? echo getByTagName($xmlObjeto->roottag->tags[0]->tags,'dtinicial') ?>');
	$('#dtfinal','#frmLiberarBloquear').val('<? echo getByTagName($xmlObjeto->roottag->tags[0]->tags,'dtfinal') ?>');
	var operacao = '<? echo $operacao;  ?>';
	controlaLayout(operacao);
</script>
