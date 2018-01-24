<? 
/*!
 * FONTE        : varifica_dados.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 17/05/2010 
 * OBJETIVO     : valida os campos pac,situação e tipo da conta da rotina de CONTA CORRENTE da tela de CONTAS 
 * 
 * ALTERACOES   : Adicionado confirmacao de impressao na chamada imprimeCritica(). (Jorge)
 *
 *            01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                         pois a BO não utiliza o mesmo (Renato Darosci)
 */
?>
 
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : ''; 
	$cdagepac = (isset($_POST['cdagepac'])) ? $_POST['cdagepac'] : ''; 
	$cdsitdct = (isset($_POST['cdsitdct'])) ? $_POST['cdsitdct'] : ''; 
	$cdtipcta = (isset($_POST['cdtipcta'])) ? $_POST['cdtipcta'] : ''; 
	$cdbcochq = (isset($_POST['cdbcochq'])) ? $_POST['cdbcochq'] : ''; 
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : ''; 
	$tpevento = ( $operacao == 'VD') ? 'c' : 'b';
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0074.p</Bo>';
	$xml .= '		<Proc>verifica_dados</Proc>';
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
	$xml .= '		<tpevento>'.$tpevento.'</tpevento>';
	$xml .= '		<cdagepac>'.$cdagepac.'</cdagepac>';
	$xml .= '		<cdsitdct>'.$cdsitdct.'</cdsitdct>';
	$xml .= '		<cdtipcta>'.$cdtipcta.'</cdtipcta>';
	$xml .= '		<cdbcochq>'.$cdbcochq.'</cdbcochq>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	$msgTitular = trim($xmlObj->roottag->tags[0]->attributes['MSGCONFI']);
	$flgcreca = $xmlObj->roottag->tags[0]->attributes['FLGCRECA'];
    // echo "flgcreca = '".$flgcreca."';";
	
	if ( $operacao == 'VD' ){
		// Se ocorrer um erro, mostra crítica
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
		} else if ( $xmlObj->roottag->tags[0]->attributes['TIPCONFI'] == 0 ){
			echo "controlaLayout('CB');";
		} else if ( $xmlObj->roottag->tags[0]->attributes['TIPCONFI'] == 1 ){
			echo "showConfirmacao('".$msgTitular."','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'XT\')','controlaLayout(\'CA\')','sim.gif','nao.gif');";
		} else if ( $xmlObj->roottag->tags[0]->attributes['TIPCONFI'] == 2 ){
			echo "showConfirmacao('Deseja visualizar as cr&iacute;ticas?','Confirma&ccedil;&atilde;o - Ayllos','imprimeCritica(\'\');','bloqueiaFundo(divRotina);','sim.gif','nao.gif');";
			//echo "controlaLayout('CA');";
		}
	} else if ( $operacao == 'VB' ){
		// Se ocorrer um erro, mostra crítica
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
		} else if ( $xmlObj->roottag->tags[0]->attributes['TIPCONFI'] == 0 ){
			echo 'controlaLayout(\'CD\');';
		}	
	}
	
?>