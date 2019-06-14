<?php
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 18/05/2010 
 * OBJETIVO     : Rotina para validar/alterar/incluir/excluir os dados das TELEFONES da tela de CONTAS
 *
 * ALTERACOES   : 04/08/2015 - Reformulacao Cadastral (Gabriel-RKAM).
 *                14/07/2016 - Correcao da forma de recuperacao da dados do XML.SD 479874. Carlos R.
 *
 *                02/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
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
	$tptelefo = (isset($_POST['tptelefo'])) ? $_POST['tptelefo'] : '' ;
	$nrdddtfc = (isset($_POST['nrdddtfc'])) ? $_POST['nrdddtfc'] : '' ;
	$nrtelefo = (isset($_POST['nrtelefo'])) ? $_POST['nrtelefo'] : '' ;
	$nrdramal = (isset($_POST['nrdramal'])) ? $_POST['nrdramal'] : '' ;
	$secpscto = (isset($_POST['secpscto'])) ? $_POST['secpscto'] : '' ;
	$nmpescto = (isset($_POST['nmpescto'])) ? $_POST['nmpescto'] : '' ;
	$cdopetfn = (isset($_POST['cdopetfn'])) ? $_POST['cdopetfn'] : '' ;
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '' ;
	$idsittfc = (isset($_POST['idsittfc'])) ? $_POST['idsittfc'] : '' ;
	$idorigem = (isset($_POST['idorigem'])) ? $_POST['idorigem'] : '' ;
	
	$secpscto = trim($secpscto);
	$nmpescto = trim($nmpescto);	
	
	// Verifica os valores permitidos para operação
	//if(!in_array($operacao,array('AV','VA','IV','VI','EV','VE'))) exibirErro('error','O parâmetro operação inválido. Valor informado '.$operacao.'.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	if(in_array($operacao,array('AV','IV'))) validaDados();

	// Dependendo da operação, chamo uma procedure diferente cddopcao
	$procedure = '';
	if ( $operacao == 'IV' ) { $procedure = 'validar-telefone'  ; $cddopcao = 'I'; }
	if ( $operacao == 'AV' ) { $procedure = 'validar-telefone'  ; $cddopcao = 'A'; }
	if ( $operacao == 'EV' ) { $procedure = 'validar-telefone'  ; $cddopcao = 'E'; }
	if ( $operacao == 'VI' ) { $procedure = 'gerenciar-telefone'; $cddopcao = 'I'; }
	if ( $operacao == 'VA' ) { $procedure = 'gerenciar-telefone'; $cddopcao = 'A'; }
	if ( $operacao == 'VE' ) { $procedure = 'gerenciar-telefone'; $cddopcao = 'E'; }
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0070.p</Bo>';
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
	$xml .= '       <tptelefo>'.$tptelefo.'</tptelefo>';
	$xml .= '       <nrdddtfc>'.$nrdddtfc.'</nrdddtfc>';
	$xml .= '       <nrtelefo>'.$nrtelefo.'</nrtelefo>';
	$xml .= '       <nrdramal>'.$nrdramal.'</nrdramal>';
	$xml .= '       <secpscto>'.$secpscto.'</secpscto>';
	$xml .= '       <nmpescto>'.$nmpescto.'</nmpescto>';
	$xml .= '       <cdopetfn>'.$cdopetfn.'</cdopetfn>';
	$xml .= '		<prgqfalt>A</prgqfalt>';

	if ($procedure == 'gerenciar-telefone') {
		$xml .= '       <idsittfc>'.$idsittfc.'</idsittfc>';
		$xml .= '       <idorigee>'.$idorigem.'</idorigee>';
	}

	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	$retorno = ( $operacao == 'EV' || $operacao == 'VE' ) ? 'controlaOperacao();' : 'bloqueiaFundo(divRotina);' ;
	
	// Se ocorrer um erro, mostra crítica
	if ( isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') 
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$retorno,false);
	
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRETOR']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'] : '';
	$msgAlerta   = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'] : '';
	$msgRvcad   = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRVCAD'] : '';
	
	if ($msgRetorno !='' ) $msg[] = $msgRetorno;
	if ($msgRvcad   !='' ) $msg[] = $msgRvcad;
	if ($msgAlerta  !='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( "|", $msg);
	
	// Verificação da revisão Cadastral
	$msgAtCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGATCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'] : '';
	$chaveAlt = ( isset($xmlObjeto->roottag->tags[0]->attributes['CHAVEALT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'] : '';
	$tpAtlCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['TPATLCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'] : '';
	
	// Se é Validação
	if( ($operacao == 'AV') || ($operacao == 'IV') || ($operacao == 'EV') ) {				
		if( $operacao == 'AV' ) exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);		
		if( $operacao == 'IV' ) exibirConfirmacao('Deseja confirmar inclusão?' ,'Confirmação - Aimaro','controlaOperacao(\'VI\')','bloqueiaFundo(divRotina)',false);
		if( $operacao == 'EV' ) exibirConfirmacao('Deseja confirmar exclusão?' ,'Confirmação - Aimaro','controlaOperacao(\'VE\')','bloqueiaFundo(divRotina);controlaOperacao(\'\');',false);
	
	// Se é Inclusão/Alteração/Exclusão
	} else {		

		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad!='' && $flgcadas != 'M') {					
			if( $operacao == 'VA' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0070.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
			if( $operacao == 'VI' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0070.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
			if( $operacao == 'VE' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0070.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);

		// Se não existe necessidade de Revisão Cadastral
		} else {
			if( $operacao == 'VA' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')';
			if( $operacao == 'VI' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')';
			if( $operacao == 'VE' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')';
		}
	}

	function validaDados() {

		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input,select","#frmTelefones").removeClass("campoErro");';
		
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inválida.'   ,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inválida','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
		if( $GLOBALS['tptelefo'] == '' ) exibirErro('error','A Identificação deve ser informada.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'tptelefo\',\'frmTelefones\')',false);
		if( $GLOBALS['nrdddtfc'] == '' ) exibirErro('error','O DDD deve ser informado.'          ,'Alerta - Aimaro','bloqueiaFundo(divRotina,\'nrdddtfc\',\'frmTelefones\')',false);
		if( $GLOBALS['nrtelefo'] == '' ) exibirErro('error','O Nr. Telefone deve ser informado.' ,'Alerta - Aimaro','bloqueiaFundo(divRotina,\'nrtelefo\',\'frmTelefones\')',false);
		
		if( $GLOBALS['idsittfc'] == '' ) exibirErro('error','A Situação deve ser informada.' ,'Alerta - Aimaro','bloqueiaFundo(divRotina,\'idsittfc\',\'frmTelefones\')',false);
		if( $GLOBALS['idorigem'] == '' ) exibirErro('error','A Origem deve ser informada.' ,'Alerta - Aimaro','bloqueiaFundo(divRotina,\'idorigem\',\'frmTelefones\')',false);
		
		// Se é tipo Celular, Operadora deve ser informada 
		if( ($GLOBALS['tptelefo'] == 2 ) && ($GLOBALS['cdopetfn'] == '') ) exibirErro('error','A Operadora deve ser informada.' ,'Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdopetfn\',\'frmTelefones\')',false);
		
		// Se é tipo Comercial, o nome do Contato deve ser informado
		if( ($GLOBALS['tptelefo'] == 3 ) && ($GLOBALS['nmpescto'] == '') ) exibirErro('error','O nome do Contato deve ser informado.' ,'Alerta - Aimaro','bloqueiaFundo(divRotina,\'nmpescto\',\'frmTelefones\')',false);
		
		// Se é tipo Contato, o nome do Contato deve ser informado
		if( ($GLOBALS['tptelefo'] == 4 ) && ($GLOBALS['nmpescto'] == '') ) exibirErro('error','O nome do Contato deve ser informado.' ,'Alerta - Aimaro','bloqueiaFundo(divRotina,\'nmpescto\',\'frmTelefones\')',false);
		
	}
?>