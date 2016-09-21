<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Mostrar opcao Principal da rotina de Liberar/Bloquear da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 05/01/2016 - Adicionar leitura dos campos do XML flgcrdpa e libcrdpa, para
                               o comportamento do campo de libera credito pre-aprovado (Anderson)
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
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0193.p</Bo>";					
	$xml .= "		<Proc>busca_dados</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRegistro = getObjectXML($xmlResult);
	
    if (strtoupper($xmlObjRegistro->roottag->tags[0]->name) == 'ERRO') {
        exibirErro('error',$xmlObjRegistro->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
    }

	include('form_liberar_bloquear.php');
?>
<script type='text/javascript'>
	$('#flgrenli','#frmLiberarBloquear').val('<?= ((strtoupper($xmlObjRegistro->roottag->tags[0]->attributes['FLGRENLI']) == "NO") ? "no" : "yes") ?>');
	$('#flgcrdpa','#frmLiberarBloquear').val('<?= ((strtoupper($xmlObjRegistro->roottag->tags[0]->attributes['FLGCRDPA']) == "NO") ? "no" : "yes") ?>');
	var libera_crd_pa = <?= ((strtoupper($xmlObjRegistro->roottag->tags[0]->attributes['LIBCRDPA']) == "NO") ? "false" : "true") ?>;
	var operacao = '<? echo $operacao;  ?>';
	controlaLayout(operacao, libera_crd_pa);
</script>
