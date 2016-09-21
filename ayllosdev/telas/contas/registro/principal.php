<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 23/04/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de registro da tela de CONTAS 
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *                04/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *
 */
?>
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	
	switch( $operacao ) {
		case 'CA': $op = "A"; break;
		case 'AC': $op = "@"; break;
		case ''  : $op = "@"; break;
		default  : $op = "@"; break;
	}
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op)) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Parâmetros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = ($_POST['nrdconta'] == '') ? 0 : $_POST['nrdconta'];
	$idseqttl = ($_POST['idseqttl'] == '') ? 0 : $_POST['idseqttl'];
	$flgcadas = ($_POST['flgcadas'] == '') ? '' : $_POST['flgcadas'];
		
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl não foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0065.p</Bo>';
	$xml .= '		<Proc>busca_dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dsdepart>'.$glbvars['dsdepart'].'</dsdepart>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRegistro = getObjectXML($xmlResult);
	
	$registro = $xmlObjRegistro->roottag->tags[0]->tags[0]->tags;
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjConjuge->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjConjuge->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
	
	// Se não retornou erro, então pegar a mensagem de alerta do Progress na variável msgAlert, para ser utilizada posteriormente
	$msgAlert = trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']);		
	
	include('formulario_registro.php');	
?>
<script type="text/javascript">
	var msgAlert = '<? echo $msgAlert; ?>';
	var operacao = '<? echo $operacao; ?>';		
	controlaLayout(operacao);	
	if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(operacao);');
	} else {
		controlaFoco(operacao);
	}
</script>