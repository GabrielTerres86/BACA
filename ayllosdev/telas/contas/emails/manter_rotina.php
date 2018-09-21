<?php
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 18/05/2010 
 * OBJETIVO     : Rotina para validar/alterar/incluir/excluir os dados das E-MAILS da tela de CONTAS
 *
 * ALTERACOES   : 04/08/2015 - Reformulacao cadastral (Gabriel-Rkam).
 *						      14/07/2016 - Correcao da forma de recuperacao da dados do XML.SD 479874. Carlos R.
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
	
	// Guardo os parâmetos do POST em variáveis
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;		
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '' ;			
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '' ;
	$cddopcao = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '' ;
	
	$dsdemail = (isset($_POST['dsdemail'])) ? trim($_POST['dsdemail']) : '' ;
	$secpscto = (isset($_POST['secpscto'])) ? trim($_POST['secpscto']) : '' ;
	$nmpescto = (isset($_POST['nmpescto'])) ? trim($_POST['nmpescto']) : '' ;
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '' ;
	
	// Verifica os valores permitidos para operação
	if(!in_array($operacao,array('AV','VA','IV','VI','EV','VE'))) exibirErro('error','O parâmetro operação inválido. Valor informado '.$operacao.'.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	if(in_array($operacao,array('AV','IV'))) validaDados();
	
	// Dependendo da operação, chamo uma procedure diferente cddopcao
	$procedure = '';
	if ( $operacao == 'IV' ) { $procedure = 'validar-email'  ; $cddopcao = 'I'; }
	if ( $operacao == 'AV' ) { $procedure = 'validar-email'  ; $cddopcao = 'A'; }
	if ( $operacao == 'EV' ) { $procedure = 'validar-email'  ; $cddopcao = 'E'; }
	if ( $operacao == 'VI' ) { $procedure = 'gerenciar-email'; $cddopcao = 'I'; }
	if ( $operacao == 'VA' ) { $procedure = 'gerenciar-email'; $cddopcao = 'A'; }
	if ( $operacao == 'VE' ) { $procedure = 'gerenciar-email'; $cddopcao = 'E'; }
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0071.p</Bo>';
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
	$xml .= '		<dsdemail>'.$dsdemail.'</dsdemail>';
	$xml .= '		<secpscto>'.$secpscto.'</secpscto>';
	$xml .= '		<nmpescto>'.$nmpescto.'</nmpescto>';
	$xml .= '		<prgqfalt>A</prgqfalt>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';	
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$metodoErro = ( $operacao == 'EV' || $operacao == 'VE' ) ? 'bloqueiaFundo(divRotina);controlaOperacao();' : 'bloqueiaFundo(divRotina);';
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$metodoErro,false);
	}
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRETOR']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'] : '';	
	$msgAlerta    = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'] : '';
	$msgRvcad    = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD'] : '';
	
	if ($msgRetorno !='' ) $msg[] = $msgRetorno;
	if ($msgAlerta  !='' ) $msg[] = $msgAlerta;
	if ($msgRvcad   !='' ) $msg[] = $msgRvcad;
	
	$stringArrayMsg = implode( "|", $msg);
	
	// Verificação da revisão Cadastral
	$msgAtCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGATCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'] : '';
	$chaveAlt    = ( isset($xmlObjeto->roottag->tags[0]->attributes['CHAVEALT']) )  ? $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'] : '';
	$tpAtlCad    = ( isset($xmlObjeto->roottag->tags[0]->attributes['TPATLCAD']) )  ? $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'] : '';
	
	// Se é Validação
	if( in_array($operacao,array('AV','IV','EV')) ) {
		if( $operacao == 'AV' ) exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);		
		if( $operacao == 'IV' ) exibirConfirmacao('Deseja confirmar inclusão?' ,'Confirmação - Aimaro','controlaOperacao(\'VI\')','bloqueiaFundo(divRotina)',false);		
		if( $operacao == 'EV' ) exibirConfirmacao('Deseja confirmar exclusão?' ,'Confirmação - Aimaro','controlaOperacao(\'VE\')','bloqueiaFundo(divRotina);controlaOperacao();',false);
	
	// Se é Inclusão/Alteração/Exclusão
	} else {		
		
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad !='' && $flgcadas != 'M') {					
			if( $operacao == 'VA' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0071.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
			if( $operacao == 'VI' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0071.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
			if( $operacao == 'VE' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0071.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
		
		// Se não existe necessidade de Revisão Cadastral
		} else {				
			if( $operacao == 'VA' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';
			if( $operacao == 'VI' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';
			if( $operacao == 'VE' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';
		}
	} 
	
	function validaDados() {			
		
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input","#frmEmails").removeClass("campoErro");';
		
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inválida.'   ,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inválida','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
		if( $GLOBALS['dsdemail'] == '' ) exibirErro('error','E-Mail deve ser informado.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dsdemail\',\'frmEmails\')',false);
		
	}
?>