<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 31/08/2011
 * OBJETIVO     : Mostrar opcao Principal da rotina de participacao em empresas da tela de CONTAS
 *
 * ALTERACOES   : 
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
	
	$cddopcao = $_POST['cddopcao'] == '' ? 'C'  : $_POST['cddopcao'];
	
	$op = $cddopcao;
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op)) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
		
	// Verifica se o número da conta e o titular foram informados
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl']))  exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Guardo o número da conta e titular em variáveis
	$nrdconta = $_POST['nrdconta'] == '' ? 0    : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ? 0    : $_POST['idseqttl'];
	$nrcpfcgc = $_POST['nrcpfcgc'] == '' ? 0    : $_POST['nrcpfcgc'];
	$nrdctato = $_POST['nrdctato'] == '' ? 0    : $_POST['nrdctato'];	
	$nrdrowid = $_POST['nrdrowid'] == '' ? 0    : $_POST['nrdrowid'];	
	$operacao = $_POST['operacao'] == '' ? 'CT' : $_POST['operacao'];
		
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0080.p</Bo>';
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
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<nrdctato>'.$nrdctato.'</nrdctato>';	
	$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';	

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	
	$registros = $xmlObjeto->roottag->tags[0]->tags;	
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		if ( $operacao == 'IB' ) { 
			$metodo = 'bloqueiaFundo(divRotina);controlaOperacao(\'TI\');';
		} else {
			$metodo = 'bloqueiaFundo(divRotina);controlaOperacao();';
		}		
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$metodo,false);
	}
?>
 
<script type="text/javascript">
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
</script>  
 
<?
	// Se estiver alterando, chamar o formulario de alteracao
	if ( $operacao != 'CT' ) {
		include('formulario_participacao.php');
	// Se estiver consultando, chamar a tabela que exibe as empresas participantes
	} else if ( $operacao == 'CT' ) {
		include('tabela_participacao.php');
	}
?>	
<script type="text/javascript">
	var operacao 	= '<? echo $operacao;    ?>';
	
	// Quando cpf é digitado na inclusão, e cpf não esta cadastrado no sistema, então
	// salvo o cpf digitado e atribuo esse valor novamente ao campo apos a busca
	if ( operacao == 'IB' && $('#nrcpfcgc','#frmParticipacaoEmpresas').val()=='' ) {
		$('#nrcpfcgc','#frmParticipacaoEmpresas').val(cpfaux);
	}
	
	// Controla o layout da tela
	controlaLayout( operacao );
	if ( operacao == 'TX'){	controlaOperacao("EV");}
</script>