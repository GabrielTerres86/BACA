<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 24/05/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de DEPENDENTES da tela de CONTAS 
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *                02/09/2015 - Reformulacao Cadastral (Gabriel-RKAM).
 *                13/07/2016 - Correcao da forma de recuperacao da msgalert do XML de dados. SD 479874. Carlos R.
 *
 *                01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 *
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '@';
	
	$op = $cddopcao;
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op)) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','fechaRotina(divRotina)',false);
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Parâmetros incorretos.','Alerta - Aimaro','fechaRotina(divRotina)',false);	

	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ? 0 : $_POST['idseqttl'];	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';
	
	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');

	setVarSession("opcoesTela",$opcoesTela);
	$qtOpcoesTela = count($opcoesTela);

	// Carregas as opções da Rotina de Bens
	$flgAlterar   = (in_array('A', $glbvars['opcoesTela']));
	$flgExcluir   = (in_array('E', $glbvars['opcoesTela']));
	$flgIncluir   = (in_array('I', $glbvars['opcoesTela']));
	$flgConsultar = (in_array('C', $glbvars['opcoesTela']));
		
	if ( $operacao == 'TI' ) { 
		include('formulario_dependentes.php'); 
		?>
		<script type="text/javascript">
			var operacao = '<? echo $operacao; ?>';
			controlaLayoutDependentes(operacao);
		</script>
		<?
		exit(); 
	}
	
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro','fechaRotina(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl inválida.','Alerta - Aimaro','fechaRotina(divRotina)',false);	
	
	$procedure = (in_array($operacao,array('TA','TE','TI','CF'))) ? 'obtem-dados-operacao' : 'obtem-dependentes';
		
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0047.p</Bo>';
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
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	$msgAlert  = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) : '';

	//Verifico se conta é titular em outra conta. Se atributo vier preenchido, muda operação para 'SC' => Somente Consulta
	$msgConta = trim($xmlObjeto->roottag->tags[0]->attributes['MSGCONTA']);
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
		include('formulario_dependentes.php');	
	
	// Se estiver consultando, chamar a TABELA
	} else if(in_array($operacao,array('AT','IT','FI','FA','FE','SC',''))) {
		include('tabela_dependentes.php');
	}
?>
<script type="text/javascript">
	var msgAlert = '<? echo $msgAlert; ?>';
	var msgConta = '<? echo $msgConta; ?>';
	var operacao = '<? echo $operacao; ?>';	
	var flgAlterar   = '<? echo $flgAlterar;   ?>';
	var flgExcluir   = '<? echo $flgExcluir;   ?>';	
	var flgIncluir   = '<? echo $flgIncluir;   ?>';
	var flgConsultar = '<? echo $flgConsultar; ?>';
	var qtOpcoesTela = '<? echo $qtOpcoesTela; ?>';	
		
	controlaLayoutDependentes(operacao);	
	if ( msgConta != '' && operacao == 'SC' ){
		showError('inform',msgConta,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFocoDependentes(\''+operacao+'\');'); 
	}else if ( msgAlert != ''   ){ 
		showError('inform',msgAlert,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFocoDependentes(\''+operacao+'\');'); 
	}
	if ( operacao == 'TE' ){ controlaOperacaoDependentes('VE'); }
</script>