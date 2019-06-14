<?php 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 14/04/2010 
 * OBJETIVO     : Rotina para validar/alterar os dados de INF. ADICIONAL da tela de CONTAS
 
   ALTERACOES   : 15/09/2010 - Incluir campo de observacao na pessoa fisica (Gabriel).
				  16/11/2011 - Tratamento para cdcooper = 3 na funcao validaDados(). (Fabricio)
				  06/08/2015 - Reformulacao Cadastral (Gabriel-RKAM)
				  14/07/2016 - Correcao na forma de uso do retorno XML. SD 479874. Carlos R.
				  01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
                               pois a BO não utiliza o mesmo (Renato Darosci)
 */
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$cdcooper = $glbvars['cdcooper'];
	$cdagenci = $glbvars['cdagenci'];
	$nrdcaixa = $glbvars['nrdcaixa'];
	$cdoperad = $glbvars['cdoperad'];
	$nmdatela = $glbvars['nmdatela'];
	$idorigem = $glbvars['idorigem'];
	
	// Guardo os parâmetos do POST em variáveis
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;		
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '' ;		
	$nrinfcad = (isset($_POST['nrinfcad'])) ? $_POST['nrinfcad'] : '' ;
	$nrpatlvr = (isset($_POST['nrpatlvr'])) ? $_POST['nrpatlvr'] : '' ;
	$nrperger = (isset($_POST['nrperger'])) ? $_POST['nrperger'] : '' ;
	$dsinfadi = (isset($_POST['dsinfadi'])) ? $_POST['dsinfadi'] : '' ;
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '' ;	
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';	
	
    $dsinfadi = retiraSerialize( $dsinfadi, 'dsinfadi' );
	
	if($operacao == 'AV') validaDados($inpessoa);
		
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	switch($operacao) {
		case 'AV': $procedure = 'validar-informacoes-adicionais'; break;
		case 'VA': $procedure = 'atualizar-informacoes-adicionais'; break;
		default: return false;
	}	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0048.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$cdcooper.'</cdcooper>';
	$xml .= '		<cdagenci>'.$cdagenci.'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$nrdcaixa.'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$cdoperad.'</cdoperad>';
	$xml .= '		<nmdatela>'.$nmdatela.'</nmdatela>';
	$xml .= '		<idorigem>'.$idorigem.'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrinfcad>'.$nrinfcad.'</nrinfcad>';
    $xml .= '		<nrpatlvr>'.$nrpatlvr.'</nrpatlvr>';
    $xml .= '		<nrperger>'.$nrperger.'</nrperger>';
    $xml .= '		<dsinfadi>'.$dsinfadi.'</dsinfadi>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') 
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRETOR']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'] : '';	
	$msgAlerta  = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'] : '';
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( "|", $msg);
	
	// Verificação da revisão Cadastral
	$msgAtCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGATCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'] : '';
	$chaveAlt    = ( isset($xmlObjeto->roottag->tags[0]->attributes['CHAVEALT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'] : '';
	$tpAtlCad    = ( isset($xmlObjeto->roottag->tags[0]->attributes['TPATLCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'] : '';
	
	if( $operacao == 'AV' ) { // Se é Validação
		exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacao(\'VA\','.$inpessoa.')','bloqueiaFundo(divRotina)',false);
	} else { // Se é Alteração
		
		// Verificar se existe "Verificação de Revisão Cadastral"
		if( $msgAtCad != '' && $flgcadas != 'M') {					
			if( $operacao == 'VA' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0048.p\',\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
		
		// Se não existe necessidade de Revisão Cadastral
		} else {				
			if($operacao == 'VA') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';
		}
		
	} 
	
	function validaDados($inpessoa) {
	
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input","#frmInfAdicional").removeClass("campoErro");';
		
		// Número da conta e o titular são inteiros válidos
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);				
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inválida','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
			
		// Valida se cods. são numericos
		if ( (!validaInteiro($GLOBALS['nrinfcad'])) || ( $GLOBALS['nrinfcad'] == 0 ) ) exibirErro('error','Código inválido','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nrinfcad\',\'frmInfAdicional\')',false);	
		if ( ((!validaInteiro($GLOBALS['nrpatlvr'])) || ( $GLOBALS['nrpatlvr'] == 0 )) && ($GLOBALS['cdcooper'] != 3) ) exibirErro('error','Código inválido','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nrpatlvr\',\'frmInfAdicional\')',false);  
		if ( $inpessoa == 2 && ((!validaInteiro($GLOBALS['nrperger'])) || ( $GLOBALS['nrperger'] == 0 )) && ($GLOBALS['cdcooper'] != 3) ) exibirErro('error','Código inválido','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nrperger\',\'frmInfAdicional\')',false);  
			
	}		
?>