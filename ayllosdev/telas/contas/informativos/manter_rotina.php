<?php
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 19/04/2010 
 * OBJETIVO     : Rotina para validar/incluir/alterar/excluir os INFORMATIVOS da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001 [07/07/2011] David (CECRED)        : Ajuste na funcao validaPermissao() para utilizar variavel $op
 * 002 [14/07/2016] Carlos R. : Correcao da forma de utilizacao dos dados vindos do XML. SD 479874.
 */
 
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	// Guardo os parâmetos do POST em variáveis
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';		
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : ''; 
	$cdrelato = (isset($_POST['cdrelato'])) ? $_POST['cdrelato'] : '';
	$cdprogra = (isset($_POST['cdprogra'])) ? $_POST['cdprogra'] : '';
	$cddfrenv = (isset($_POST['cddfrenv'])) ? $_POST['cddfrenv'] : ''; 
	$cdperiod = (isset($_POST['cdperiod'])) ? $_POST['cdperiod'] : '';
	$cdseqinc = (isset($_POST['cdseqinc'])) ? $_POST['cdseqinc'] : '';	
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';	
	
	$op = ( $cddopcao == 'A' ) ? '@' : $cddopcao ;
	
	// Verifica os valores permitidos para operação
	if(!in_array($operacao,array('IV','AV','VI','VA','CE'))) exibirErro('error','O parâmetro operação não é válido.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	if(in_array($operacao,array('IV','AV'))) validaDados();
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	if(in_array($operacao,array('IV','AV'))) $procedure = 'valida_dados';
	if(in_array($operacao,array('VI','VA','CE'))) $procedure = 'grava_dados';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op)) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
			
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0064.p</Bo>';
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
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<cdrelato>'.$cdrelato.'</cdrelato>';
	$xml .= '		<cdprogra>'.$cdprogra.'</cdprogra>';
	$xml .= '		<cddfrenv>'.$cddfrenv.'</cddfrenv>';
	$xml .= '		<cdperiod>'.$cdperiod.'</cdperiod>';
	$xml .= '		<cdseqinc>'.$cdseqinc.'</cdseqinc>';
	$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	$metodo = ( $operacao != 'CE' ) ? 'bloqueiaFundo(divRotina)' : 'controlaOperacao(\'\')'; 
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') 
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$metodo,false);
	
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRETOR']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'] : '';
	$msgAlerta  = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'] : '';
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( "|", $msg);
	
	// Verificação da revisão Cadastral
	$msgAtCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGATCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'] : '';
	$chaveAlt     = ( isset($xmlObjeto->roottag->tags[0]->attributes['CHAVEALT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'] : '';
	$tpAtlCad    = ( isset($xmlObjeto->roottag->tags[0]->attributes['TPATLCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'] : '';
	
	// Se é Validação
	if(in_array($operacao,array('IV','AV'))) {		
		
		if($operacao=='IV') exibirConfirmacao('Deseja confirmar inclusão?','Confirmação - Aimaro','controlaOperacao(\'VI\')','bloqueiaFundo(divRotina)',false);
		if($operacao=='AV') exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);
		
	// Se é Inclusão ou Alteração
	} else {
	
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad!='') {
		
			if($operacao=='VI') exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0064.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FI\")\')',false);
			if($operacao=='VA') exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0064.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FA\")\')',false);
			
		// Se não existe necessidade de Revisão Cadastral
		} else {	
		
			// Chama o controla Operação Finalizando a Inclusão ou Alteração			
		    if($operacao=='VI') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FI\")\');';
		    if($operacao=='VA') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FA\")\');';
		    if($operacao=='CE') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FE\")\');';
			
		}
	} 
	
	function validaDados() {	
		
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("select","#frmDadosInformativos").removeClass("campoErro");';
		
		// Número da conta e o titular são inteiros válidos
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inválida.'   ,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);				
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inválida','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	

		// Valida se todos valores são inteiros
		if (!validaInteiro($GLOBALS['cdrelato'])) exibirErro('error','Informativo deve ser selecionado.'    ,'Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdrelato\',\'frmDadosInformativos\')',false);	
		if (!validaInteiro($GLOBALS['cddfrenv'])) exibirErro('error','Forma de Envido deve ser selecionada.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cddfrenv\',\'frmDadosInformativos\')',false); 
		if (!validaInteiro($GLOBALS['cdperiod'])) exibirErro('error','Período deve ser selecionado.'        ,'Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdperiod\',\'frmDadosInformativos\')',false); 
		if (!validaInteiro($GLOBALS['cdseqinc'])) exibirErro('error','Recebimento deve ser selecionado.'    ,'Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdseqinc\',\'frmDadosInformativos\')',false); 
	}
?>