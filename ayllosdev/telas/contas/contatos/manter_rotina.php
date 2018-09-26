<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/05/2010 
 * OBJETIVO     : Rotina para validar/alterar/incluir/excluir os dados das CONTATOS da tela de CONTAS
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
	
	$nrdctato = (isset($_POST['nrdctato'])) ? $_POST['nrdctato'] : '' ;
	$nmdavali = (isset($_POST['nmdavali'])) ? $_POST['nmdavali'] : '' ;
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
	
	$nmdavali = trim($nmdavali);
	$dsendere = trim($dsendere);
	$complend = trim($complend);
	$nmbairro = trim($nmbairro);
	$nmcidade = trim($nmcidade);	
	
	// Verifica os valores permitidos para operação
	if(!in_array($operacao,array('AV','VA','IV','VI','E'))) exibirErro('error','O parâmetro operação inválido. Valor informado '.$operacao.'.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	if(in_array($operacao,array('AV','IV'))) validaDados();
	
	// Dependendo da operação, chamo uma procedure diferente cddopcao
	$procedure = '';
	if ( $operacao == 'IV' ) {$procedure = 'valida_dados'; $cddopcao = 'I';}
	if ( $operacao == 'AV' ) {$procedure = 'valida_dados'; $cddopcao = 'A';}
	if ( $operacao == 'VI' ) {$procedure = 'grava_dados' ; $cddopcao = 'I';}
	if ( $operacao == 'VA' ) {$procedure = 'grava_dados' ; $cddopcao = 'A';}
	if ( $operacao == 'E'  ) {$procedure = 'grava_dados' ; $cddopcao = 'E';}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0073.p</Bo>';
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
	$xml .= '		<nrcepend>'.$nrcepend.'</nrcepend>';
	$xml .= '		<dsendere>'.$dsendere.'</dsendere>';
	$xml .= '		<nrendere>'.$nrendere.'</nrendere>';
	$xml .= '		<complend>'.$complend.'</complend>';
	$xml .= '		<nmbairro>'.$nmbairro.'</nmbairro>';
	$xml .= '		<nmcidade>'.$nmcidade.'</nmcidade>';
	$xml .= '		<cdufende>'.$cdufende.'</cdufende>';
	$xml .= '		<nrcxapst>'.$nrcxapst.'</nrcxapst>';
	$xml .= '		<nrtelefo>'.$nrtelefo.'</nrtelefo>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<dsdemail>'.$dsdemail.'</dsdemail>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';	
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	$metodo = ( $operacao == 'E' ) ? 'controlaOperacaoContatos();' : 'bloqueiaFundo(divRotina);' ;
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$metodo,false);
	
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
	
	
	
	// Se é Validação
	if( ($operacao == 'AV') || ($operacao == 'IV') ) {				
		if( $operacao == 'AV' ) exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacaoContatos(\'VA\')','bloqueiaFundo(divRotina)',false);		
		if( $operacao == 'IV' ) exibirConfirmacao('Deseja confirmar inclusão?' ,'Confirmação - Aimaro','controlaOperacaoContatos(\'VI\')','bloqueiaFundo(divRotina)',false);		
	
	// Se é Inclusão/Alteração/Exclusão
	} else {		
		
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad!='') {					
			
			if( $operacao == 'VA' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0073.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoContatos(\"\");\')',false);
			if( $operacao == 'VI' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0073.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoContatos(\"\");\')',false);
			if( $operacao == 'E'  ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0073.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoContatos(\"\");\')',false);
			
			
		
		// Se não existe necessidade de Revisão Cadastral
		} else {				
						
			if( $operacao == 'VA' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoContatos(\"\");\');';
			if( $operacao == 'VI' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoContatos(\"\");\');';
			if( $operacao == 'E'  ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoContatos(\"\");\');';
			
			
		}
	} 
	
	function validaDados() {			
		
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input, select","#frmContatos").removeClass("campoErro");';
		
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inválida.'   ,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inválida','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

		if( $GLOBALS['nmdavali'] == '' ) exibirErro('error','Campo Nome inválido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nmdavali\',\'frmContatos\')',false);		
		
		// E-mail ou Telefone deve ser informado
		if ( ($GLOBALS['nrdconta'] == 0 && $GLOBALS['nrtelefo'] == '') && ($GLOBALS['dsdemail'] == '') ) {
			echo '$("#nrtelefo, #dsdemail","#frmContatos").addClass("campoErro");';
			exibirErro('error','Telefone ou E-mail devem ser informados.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		}
		
	}
?>