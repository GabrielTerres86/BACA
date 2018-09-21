<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 12/03/2010 
 * OBJETIVO     : Rotina para validar/alterar/incluir/excluir os dados das REFERÊNCIAS da tela de CONTAS
 *
 * ALTERACOES   : 05/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *
 *                02/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
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
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;		
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '' ;			
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '' ;
	
	$nrdctato = (isset($_POST['nrdctato'])) ? $_POST['nrdctato'] : '' ;
	$nmdavali = (isset($_POST['nmdavali'])) ? $_POST['nmdavali'] : '' ;
	$nmextemp = (isset($_POST['nmextemp'])) ? $_POST['nmextemp'] : '' ;
	$cddbanco = (isset($_POST['cddbanco'])) ? $_POST['cddbanco'] : '' ;
	$cdageban = (isset($_POST['cdageban'])) ? $_POST['cdageban'] : '' ;
	$dsproftl = (isset($_POST['dsproftl'])) ? $_POST['dsproftl'] : '' ;
	$nrcepend = (isset($_POST['nrcepend'])) ? $_POST['nrcepend'] : '' ;
	$dsendere = (isset($_POST['dsendere'])) ? $_POST['dsendere'] : '' ;
	$nrendere = (isset($_POST['nrendere'])) ? $_POST['nrendere'] : '' ;
	$complend = (isset($_POST['complend'])) ? $_POST['complend'] : '' ;
	$nmbairro = (isset($_POST['nmbairro'])) ? $_POST['nmbairro'] : '' ;
	$nmcidade = (isset($_POST['nmcidade'])) ? $_POST['nmcidade'] : '' ;
	$cdufende = (isset($_POST['cdufende'])) ? $_POST['cdufende'] : '' ;
	$nrcxapst = (isset($_POST['nrcxapst'])) ? $_POST['nrcxapst'] : '' ;
	$nrtelefo = (isset($_POST['nrtelefo'])) ? $_POST['nrtelefo'] : '' ;
	$dsdemail = (isset($_POST['dsdemail'])) ? $_POST['dsdemail'] : '' ;
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '' ;
	
	$nmdavali = trim($nmdavali);
	$dsproftl = trim($dsproftl);
	$nmextemp = trim($nmextemp);
	$dsendere = trim($dsendere);
	$complend = trim($complend);
	$nmbairro = trim($nmbairro);
	$nmcidade = trim($nmcidade);	
	
	// Verifica os valores permitidos para operação
	if(!in_array($operacao,array('AV','VA','IV','VI','CE'))) exibirErro('error','O parâmetro operação inválido. Valor informado '.$operacao.'.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	if( $operacao == 'VI' ) { $procedure = 'gerenciar-contato'; $cddopcao = 'I'; }
	if( $operacao == 'VA' ) { $procedure = 'gerenciar-contato'; $cddopcao = 'A'; }
	if( $operacao == 'CE' ) { $procedure = 'gerenciar-contato'; $cddopcao = 'E'; }
	if( $operacao == 'AV' ) { $procedure = 'validar-dados-contato'; $cddopcao = 'A';}
	if( $operacao == 'IV' ) { $procedure = 'validar-dados-contato'; $cddopcao = 'I';}
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	
		
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0049.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';		
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';	
	$xml .= '		<nrdctato>'.$nrdctato.'</nrdctato>';
	$xml .= '		<nmdavali>'.$nmdavali.'</nmdavali>';
	$xml .= '		<nmextemp>'.$nmextemp.'</nmextemp>';		
	$xml .= '		<cddbanco>'.$cddbanco.'</cddbanco>';
	$xml .= '		<cdageban>'.$cdageban.'</cdageban>';
	$xml .= '		<dsproftl>'.$dsproftl.'</dsproftl>';
	$xml .= '		<nrcepend>'.$nrcepend.'</nrcepend>';
	$xml .= '		<dsendere>'.$dsendere.'</dsendere>';
	$xml .= '		<nrendere>'.$nrendere.'</nrendere>';
	$xml .= '		<complend>'.$complend.'</complend>';
	$xml .= '		<nmbairro>'.$nmbairro.'</nmbairro>';
	$xml .= '		<nmcidade>'.$nmcidade.'</nmcidade>';
	$xml .= '		<cdufende>'.$cdufende.'</cdufende>';
	$xml .= '		<nrcxapst>'.$nrcxapst.'</nrcxapst>';
	$xml .= '		<nrtelefo>'.$nrtelefo.'</nrtelefo>';
	$xml .= '		<dsdemail>'.$dsdemail.'</dsdemail>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';	
		
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
		
	$retorno = ( $operacao == 'CE') ? 'controlaOperacao()' : 'bloqueiaFundo(divRotina)';
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$retorno,false);
	
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];	
	$msgAlerta  = $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'];
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( "|", $msg);
	
	// Verificação da revisão Cadastral
	$msgAtCad = $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'];
	$chaveAlt = $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'];
	$tpAtlCad = $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'];	
	
	// exibirErro('error','operacao='.$operacao.'| nrdconta='.$nrdconta.'| idseqttl='.$idseqttl.'| procedure='.$procedure.'| nrdrowid='.$nrdrowid,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	
	
	// Se é Validação
	if( ($operacao == 'AV') || ($operacao == 'IV') ) {				
		if( $operacao == 'AV' ) exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);		
		if( $operacao == 'IV' ) exibirConfirmacao('Deseja confirmar inclusão?' ,'Confirmação - Aimaro','controlaOperacao(\'VI\')','bloqueiaFundo(divRotina)',false);		
	
	// Se é Inclusão/Alteração/Exclusão
	} else {		
		
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad!='' && $flgcadas != 'M') {					
			if( $operacao == 'VA' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0049.p\',\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
			if( $operacao == 'VI' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0049.p\',\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
		
		// Se não existe necessidade de Revisão Cadastral
		} else {
						
			if( $operacao == 'VA' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')';
			if( $operacao == 'VI' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')';
			if( $operacao == 'CE' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')';
		}
	} 
	
?>