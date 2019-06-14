<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 26/04/2010 
 * OBJETIVO     : Rotina para validar/incluir/alterar/excluir os REGISTROS da tela de CONTAS
 *
 * ALTERACOES   : 04/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
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
	$vlfatano = (isset($_POST['vlfatano'])) ? $_POST['vlfatano'] : '' ;
	$vlcaprea = (isset($_POST['vlcaprea'])) ? $_POST['vlcaprea'] : '' ;
	$dtregemp = (isset($_POST['dtregemp'])) ? $_POST['dtregemp'] : '' ;
	$nrregemp = (isset($_POST['nrregemp'])) ? $_POST['nrregemp'] : '' ;
	$orregemp = (isset($_POST['orregemp'])) ? $_POST['orregemp'] : '' ;
	$dtinsnum = (isset($_POST['dtinsnum'])) ? $_POST['dtinsnum'] : '' ;
	$nrinsmun = (isset($_POST['nrinsmun'])) ? $_POST['nrinsmun'] : '' ;
	$nrinsest = (isset($_POST['nrinsest'])) ? $_POST['nrinsest'] : '' ;
	$flgrefis = (isset($_POST['flgrefis'])) ? $_POST['flgrefis'] : '' ;
	$nrcdnire = (isset($_POST['nrcdnire'])) ? $_POST['nrcdnire'] : '' ;
	$perfatcl = (isset($_POST['perfatcl'])) ? $_POST['perfatcl'] : '' ;
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '' ;
	
	// Retirando os "." dos valores monetários
	$vlfatano = str_replace('.','',$vlfatano);
	$vlcaprea = str_replace('.','',$vlcaprea);	
	
	$orregemp = trim($orregemp);
	
	// Verifica os valores permitidos para operação
	if(!in_array($operacao,array('AV','VA'))) exibirErro('error','O parâmetro operação não é válido.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	if( $operacao == 'AV' ) validaDados();
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	if( $operacao == 'AV' ) $procedure = 'valida_dados';
	if( $operacao == 'VA' ) $procedure = 'grava_dados';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// exibirErro('error','operacao='.$operacao.'| procedure='.$procedure.'| idseqttl='.$idseqttl.'| nrdconta='.$nrdconta.'| vlfatano='.$vlfatano.'| vlcaprea='.$vlcaprea.'| dtregemp='.$dtregemp.'| nrregemp='.$nrregemp.'| orregemp='.$orregemp,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	// exibirErro('error','dtinsnum='.$dtinsnum.'| nrinsmun='.$nrinsmun.'| nrinsest='.$nrinsest.'| flgrefis='.$flgrefis.'| nrcdnire='.$nrcdnire.'| perfatcl='.$perfatcl,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0065.p</Bo>';
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
	$xml .= '		<vlfatano>'.$vlfatano.'</vlfatano>';
	$xml .= '		<vlcaprea>'.$vlcaprea.'</vlcaprea>';
	$xml .= '		<dtregemp>'.$dtregemp.'</dtregemp>';	
	$xml .= '		<nrregemp>'.$nrregemp.'</nrregemp>';
	$xml .= '		<orregemp>'.$orregemp.'</orregemp>';
	$xml .= '		<dtinsnum>'.$dtinsnum.'</dtinsnum>';
	$xml .= '		<nrinsmun>'.$nrinsmun.'</nrinsmun>';
	$xml .= '		<nrinsest>'.$nrinsest.'</nrinsest>';
	$xml .= '		<flgrefis>'.$flgrefis.'</flgrefis>';
	$xml .= '		<nrcdnire>'.$nrcdnire.'</nrcdnire>';
	$xml .= '		<perfatcl>'.$perfatcl.'</perfatcl>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
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
	if( $operacao == 'AV' ) {		
		exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);		
	
	// Se é Inclusão
	} else {	
		
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad!='' && $flgcadas != 'M') {		
			exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0065.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
		
		// Se não existe necessidade de Revisão Cadastral
		} else {		
			echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')';			
		}
	} 
	
	function validaDados() {			
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input","#frmRegistro").removeClass("campoErro");';
		
		// Número da conta e o titular são inteiros válidos
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inválida.'   ,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);				
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inválida','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	
		
		// Faturamento Ano
		if ( $GLOBALS['vlfatano'] == 0 ) exibirErro('error','Faturamento Ano não pode ser zero.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'vlfatano\',\'frmRegistro\')',false);			
		if (!validaDecimal($GLOBALS['vlfatano'])) exibirErro('error','Faturamento Ano deve ser um decimal válido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'vlfatano\',\'frmRegistro\')',false);			
		
		// Capital Realizado
		if ( $GLOBALS['vlcaprea'] == 0 ) exibirErro('error','Capital Realizado não pode ser zero.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'vlcaprea\',\'frmRegistro\')',false);					
				
		// Data Registro
		if ( $GLOBALS['dtregemp'] == '' ) exibirErro('error','Data do Registro deve ser preenchido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dtregemp\',\'frmRegistro\')',false); 
		if (!validaData($GLOBALS['dtregemp']) ) exibirErro('error','Data do Registro deve ser uma data válida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dtregemp\',\'frmRegistro\')',false); 
		
		// Número Registro
		if ( $GLOBALS['nrregemp'] == 0 ) exibirErro('error','Número do Registro não pode ser zero.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nrregemp\',\'frmRegistro\')',false);
		if ( $GLOBALS['nrregemp'] == '' ) exibirErro('error','Número do Registro deve ser preenchido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nrregemp\',\'frmRegistro\')',false); 
		
		// Orgão Registro
		if ( $GLOBALS['orregemp'] == '' ) exibirErro('error','Orgão do Registro deve ser preenchido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'orregemp\',\'frmRegistro\')',false); 
		
		// Data da Insc. Municipal		
		if ( ($GLOBALS['dtinsnum'] != '') && (!validaData($GLOBALS['dtinsnum'])) ) exibirErro('error','Data da Inscrição Municipal deve ser uma data válida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dtinsnum\',\'frmRegistro\')',false); 	
		
		// Percentual Faturamento Único cliente
		if ( $GLOBALS['perfatcl'] == 0 ) exibirErro('error','(%) Concentração Faturamento em Único Cliente não pode ser zero.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'perfatcl\',\'frmRegistro\')',false);					
		if (!validaDecimal($GLOBALS['perfatcl'])) exibirErro('error','(%) Concentração Faturamento em Único Cliente não é um decimal válido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'perfatcl\',\'frmRegistro\')',false);			
	}
?>