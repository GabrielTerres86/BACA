<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 24/05/2010 
 * OBJETIVO     : Rotina para validar/alterar/incluir/excluir os dados das DEPENDENTES da tela de CONTAS
 *
 * ALTERACOES   : 02/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *
 *                01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
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
	
	$nmdepend = (isset($_POST['nmdepend'])) ? $_POST['nmdepend'] : '' ;
	$dtnascto = (isset($_POST['dtnascto'])) ? $_POST['dtnascto'] : '' ;
	$cdtipdep = (isset($_POST['cdtipdep'])) ? $_POST['cdtipdep'] : '' ;
	
	$nmdepend = trim($nmdepend);
	
	// Verifica os valores permitidos para operação
	if(!in_array($operacao,array('AV','VA','IV','VI','EV','VE'))) exibirErro('error','O parâmetro operação inválido. Valor informado '.$operacao.'.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	
	if(in_array($operacao,array('AV','IV'))) validaDados();
	
	// Dependendo da operação, chamo uma procedure diferente cddopcao
	$procedure = '';
	if ( $operacao == 'IV' ) { $procedure = 'valida-operacao'     ; $cddopcao = 'I'; }
	if ( $operacao == 'AV' ) { $procedure = 'valida-operacao'     ; $cddopcao = 'A'; }
	if ( $operacao == 'EV' ) { $procedure = 'valida-operacao'     ; $cddopcao = 'E'; }
	if ( $operacao == 'VI' ) { $procedure = 'gerenciar-dependente'; $cddopcao = 'I'; }
	if ( $operacao == 'VA' ) { $procedure = 'gerenciar-dependente'; $cddopcao = 'A'; }
	if ( $operacao == 'VE' ) { $procedure = 'gerenciar-dependente'; $cddopcao = 'E'; }
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','fechaRotina(divRotina)',false);
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0047.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
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
	$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';			
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '       <nmdepend>'.$nmdepend.'</nmdepend>';
	$xml .= '       <dtnascto>'.$dtnascto.'</dtnascto>';
	$xml .= '       <cdtipdep>'.$cdtipdep.'</cdtipdep>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';	
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$metodoErro = ( $operacao == 'EV' || $operacao == 'VE' ) ? 'bloqueiaFundo(divRotina);controlaOperacaoDependentes();' : 'bloqueiaFundo(divRotina);';
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$metodoErro,false);
	}
	
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];	
	$msgAlerta  = $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'];
	$msgRvcad  = $xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD'];
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	if ($msgRvcad!='' ) $msg[] = $msgRvcad;
	
	$stringArrayMsg = implode( "|", $msg);
	
	// Verificação da revisão Cadastral
	$msgAtCad = $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'];
	$chaveAlt = $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'];
	$tpAtlCad = $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'];		
	
	// Se é Validação
	if( in_array($operacao,array('AV','IV','EV')) ) {
		if( $operacao == 'AV' ) exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacaoDependentes(\'VA\')','bloqueiaFundo(divRotina)',false);		
		if( $operacao == 'IV' ) exibirConfirmacao('Deseja confirmar inclusão?' ,'Confirmação - Aimaro','controlaOperacaoDependentes(\'VI\')','bloqueiaFundo(divRotina)',false);		
		if( $operacao == 'EV' ) exibirConfirmacao('Deseja confirmar exclusão?' ,'Confirmação - Aimaro','controlaOperacaoDependentes(\'VE\')','bloqueiaFundo(divRotina);controlaOperacaoDependentes();',false);
	
	// Se é Inclusão/Alteração/Exclusão
	} else {		
		
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad!='') {					
			if( $operacao == 'VA' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0071.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoDependentes(\"\")\')',false);
			if( $operacao == 'VI' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0071.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoDependentes(\"\")\')',false);
			if( $operacao == 'VE' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0071.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoDependentes(\"\")\')',false);
		
		// Se não existe necessidade de Revisão Cadastral
		} else {				
			if( $operacao == 'VA' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoDependentes(\"\")\');';
			if( $operacao == 'VI' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoDependentes(\"\")\');';
			if( $operacao == 'VE' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoDependentes(\"\")\');';
		}
	} 
	
	function validaDados() {					
		
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input","#frmDependentes").removeClass("campoErro");';
		
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inválida.'   ,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inválida','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
		// Valida o Nome
		if( $GLOBALS['nmdepend'] == '' ) exibirErro('error','O Nome do Dependente deve ser informado.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nmdepend\',\'frmDependentes\')',false);
		
		// Valida a Data Nascimento
		if ( !validaData( $GLOBALS['dtnascto'] )) exibirErro('error','A Data de Nascimento não é uma data válida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dtnascto\',\'frmDependentes\')',false);
		
		// Valida o Tipo de Dependente
		if ( !validaInteiro( $GLOBALS['cdtipdep'] )) exibirErro('error','O Tipo de Dependente deve ser informado.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdtipdep\',\'frmDependentes\')',false);	
		
	}
?>