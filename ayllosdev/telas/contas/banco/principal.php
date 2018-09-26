<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 23/04/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de banco da tela de CONTAS 
 * 
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1).
 *                05/08/2015 - Gabriel (RKAM) : Reformulacao Cadastral.	
 *                01/12/2016 - Renato (Supero): P341-Automatização BACENJUD - Retirado o envio do
 *                                              parametro do departamento ao invés pois não é 
 *                                              utilizado na BO 
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

	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
	
	$op = ( $cddopcao == "C" ) ? "@" : $cddopcao ;
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op)) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Verifica se o número da conta e o titular foram informados
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','fechaRotina(divRotina)',false);
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrdlinha = (isset($_POST['nrdlinha'])) ? $_POST['nrdlinha'] : '';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
			
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','fechaRotina(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Aimaro','fechaRotina(divRotina)',false);
	
	// exibirErro('error','nrdlinha='.$nrdlinha.'| cddopcao='.$cddopcao,'Alerta - Aimaro','controlaOperacao()');
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0067.p</Bo>';
	$xml .= '		<Proc>busca_dados</Proc>';
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
	$xml .= '		<nrdlinha>'.$nrdlinha.'</nrdlinha>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','controlaOperacao()',false);
	
	// Define a variágel que guarda todos os itens
	$registros = $xmlObjeto->roottag->tags[0]->tags;	
	// Verifica a quantidade de registros retornaods
	$nrregatu  = count($registros);
	// Define o número máximo de registros de acordo com o atributo NRLIMMAX
	$nrlimmax  = $xmlObjeto->roottag->tags[0]->attributes['NRLIMMAX'];
	// Define a mensagem de alerta
	$msgAlert  = trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']);		
	
?> 
<script type="text/javascript">
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
</script>  
<?
	// Se estiver Alterando/Incluindo, chamar o formulario de alteracao
	if(in_array($operacao,array('TI','TA','TE'))) {
		$registro = $registros[0]->tags;
		include('formulario_banco.php');
	
	// Se estiver consultando, chamar a tabela que exibe os bens
	} else if(in_array($operacao,array('AT','IT','FI','FA','FE',''))) {
		include('tabela_banco.php');
	}
?>	
<script type="text/javascript">		
	var nrregatu = '<? echo $nrregatu; ?>';
	var nrlimmax = '<? echo $nrlimmax; ?>';
	var msgAlert = '<? echo $msgAlert; ?>';
	var operacao = '<? echo $operacao; ?>';
	controlaLayout(operacao);
	if ( msgAlert != ''   ){ showError('inform',msgAlert,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFoco(operacao);'); }
	if ( operacao == 'TE' ){ controlaOperacao('EV'); }
</script>