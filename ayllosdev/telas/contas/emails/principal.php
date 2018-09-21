<?php 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 17/04/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de E-MAILS da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *                04/08/2015 - Reformulacao cadastral (Gabriel-Rkam).
 *                13/07/2016 - Correcao do uso das variaveis do array $_POST e do XML de retorno. SD  479874. Carlos R.
 *
 *                01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '' ;

	$op = ( $cddopcao == 'C' ) ? '@' : $cddopcao ;
	
	// Verifica permissões de acessa a tela
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op,false)) <> '') {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Aimaro',$metodo,false);	
	}
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Parâmetros incorretos.','Alerta - Aimaro','fechaRotina(divRotina)',false);	

	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');

	setVarSession("opcoesTela",$opcoesTela);

	// Carregas as opções da Rotina de Bens
	$flgAlterar   = (in_array('A', $glbvars['opcoesTela']));
	$flgExcluir   = (in_array('E', $glbvars['opcoesTela']));
	$flgIncluir   = (in_array('I', $glbvars['opcoesTela']));
	
	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ? 0 : $_POST['idseqttl'];	
	$inpessoa = ( isset($_POST['inpessoa']) ) ? $_POST['inpessoa'] : 0;
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';
		
	if ( $operacao == 'TI' ) { 
		include('formulario_emails.php'); 
		?>
		<script type="text/javascript">
			var operacao = '<?php echo $operacao; ?>';
			controlaLayout(operacao);
		</script>
		<?php
		exit(); 
	}
	
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro','fechaRotina(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl inválida.','Alerta - Aimaro','fechaRotina(divRotina)',false);	
	
	$procedure = (in_array($operacao,array('TA','TE','TI','CF'))) ? 'obtem-dados-gerenciar-email' : 'obtem-email-cooperado';
			
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0071.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
    $xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';	
    $xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") { exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false); }
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	$msgAlert  = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) : '';
	
	//Verifico se conta é titular em outra conta. Se atributo vier preenchido, muda operação para 'SC' => Somente Consulta
	$msgConta = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGCONTA']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGCONTA']) : '';
	if( $msgConta != '' ) {
		$operacao = ( $operacao != 'CF' ) ? 'SC' : $operacao ;
	}
	
?>
<script type="text/javascript">
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
</script> 
<?	
	// Se estiver Alterando/Incluindo/Excluindo, chamar o FORMULARIO
	if(in_array($operacao,array('TA','TI','TE','CF'))) {
		$registro = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
		include('formulario_emails.php');	
	
	// Se estiver consultando, chamar a TABELA
	} else if(in_array($operacao,array('AT','IT','ET','FI','FA','FE','SC',''))) {
		include('tabela_emails.php');
	}
?>
<script type="text/javascript">
	var msgAlert = '<? echo $msgAlert; ?>';
	var msgConta = '<? echo $msgConta; ?>';
	var operacao = '<? echo $operacao; ?>';
	
	if (inpessoa == 1) {
		var flgAlterar   = '<? echo $flgAlterar;   ?>';
		var flgExcluir   = '<? echo $flgExcluir;   ?>';
		var flgIncluir   = '<? echo $flgIncluir;   ?>';	
		var flgcadas     = '<? echo $flgcadas;     ?>';	
	}
	
	controlaLayout(operacao);
	
	if ( msgConta != '' && operacao == 'SC' ){
		showError('inform',msgConta,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');'); 
	}else if ( msgAlert != ''   ){ 
		showError('inform',msgAlert,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');'); 
	}
	if ( operacao == 'TE'){ controlaOperacao('EV'); }
</script>