<? 
/*!
 * FONTE        : principal.php
 * CRIA��O      : Alexandre Scola (DB1)
 * DATA CRIA��O : 08/03/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de CONJUGE da tela de CONTAS 
 * --------------
 * ALTERA��ES   :
 * --------------
 * 001: [19/05/2010] Rodolpho Telmo  (DB1) : Adpta��o ao padr�o
 * 002: [20/12/2010] Gabriel Capoia  (DB1) : Adicionado chamada validaPermissao
 * 003: [01/09/2015] Gabriel (RKAM)        : Reformulacao cadastral.
 */
?> 
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();				
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';

	$op = ( $cddopcao == 'C' ) ? '@' : $cddopcao ;
	
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	
	// Verifica permiss�es de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op,false)) <> '') { 
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'fechaRotina(divRotina);';		
		exibirErro('error',$msgError,'Alerta - Ayllos',$metodo,false);
	}
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','fechaRotina(divRotina)',false);

	// Carrega permiss�es do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);
	
	$qtOpcoesTela = count($opcoesTela);
	
	// Carregas as op��es da Rotina de Bens
	$flgAcesso   = (in_array("@", $glbvars["opcoesTela"]));
	$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));
	
	// Guardo os par�metos do POST em vari�veis	
	$nrdconta = $_POST['nrdconta'] == '' ?  0  : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ?  0  : $_POST['idseqttl'];
	$nrcpfcjg = $_POST['nrcpfcjg'] == '' ?  0  : $_POST['nrcpfcjg'];
	$nrctacje = $_POST['nrctacje'] == '' ?  0  : $_POST['nrctacje'];
		
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	
	// Verifica se o n�mero da conta e o titular s�o inteiros v�lidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	
	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0057.p</Bo>';
	$xml .= '		<Proc>busca_dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrcpfcjg>'.$nrcpfcjg.'</nrcpfcjg>';
	$xml .= '		<nrctacje>'.$nrctacje.'</nrctacje>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);
	
	$conjuge   = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$msgAlert  = trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']);	
	
		
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		switch ($operacao) {
			case 'CA' : $metodo = 'bloqueiaFundo(divRotina);controlaFoco(\'CA\');'; break;
			case 'CB' : $metodo = 'bloqueiaFundo(divRotina);controlaFoco(\'CA\');'; break;
			case ''   : $metodo = 'return false;';          				        break; 
			default   : $metodo = 'bloqueiaFundo(divRotina);';                      break;
		}
				
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'fechaRotina(divRotina);';		
		
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$metodo,false);
	}	
	
	// Obtenho valores de algumas vari�veis
	$nrdrowid = getByTagName($conjuge,'nrdrowid');
	$cdnvlcgo = getByTagName($conjuge,'cdnvlcgo');
	$cdturnos = getByTagName($conjuge,'cdturnos');
	
	//Verifico se conta � titular em outra conta. Se atributo vier preenchido, muda opera��o para 'SC' => Somente Consulta
	$msgConta = trim($xmlObjeto->roottag->tags[0]->attributes['MSGCONTA']);
	if( $msgConta != '' ) $operacao = 'SC';
	
?>
<script type='text/javascript'>
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
</script> 
<?
	include('formulario_conjuge.php');	
?>
<script type='text/javascript'>
	
	var flgAlterar   = '<? echo $flgAlterar;   ?>';
	var qtOpcoesTela = '<? echo $qtOpcoesTela; ?>';	
	var msgAlert = '<? echo $msgAlert ?>';
	var msgConta = '<? echo $msgConta ?>';
	var operacao = '<? echo $operacao ?>';
	var dsblqalt = '<? echo getByTagName($conjuge,'dsblqalt') ?>';	
	var flgcadas = '<? echo $flgcadas; ?>';
		
	nrdrowid = '<? echo $nrdrowid ?>';
	cdnvlcgo = '<? echo $cdnvlcgo ?>';
	cdturnos = '<? echo $cdturnos ?>';
	
	controlaLayout( operacao );
	
	if ( msgConta != '' ) { 
		showError('inform',msgConta,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');');
	}else if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');');
	}
		
	if (flgcadas == 'M' && operacao == '') {
		controlaOperacao('CA');
	}
	
</script>