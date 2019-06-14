<? 
/*!
 * FONTE        : manter_endereco.php
 * CRIAÇÃO      : Rodolpho e Rogérius (DB1)
 * DATA CRIAÇÃO : 19/04/2011 
 * OBJETIVO     : Rotina para validar/incluir os dados do ENDERECO
 *
 * ALTERAÇÕES   : 01/08/2011 - Adicionado campo de retorno caso ocorra erro, para se dar focus() no mesmo.

                  25/05/2017 - Ajuste para retirar acentução das informações a serem enviadas para gravação do endereço
				               (Adriano - SD 676347).
 */
?> 
<?
    session_start();	
	require_once('../funcoes.php');
	require_once('../config.php');
	require_once('../controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	

	// Guardo os parâmetos do POST em variáveis
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;		
	$nrcepend = (isset($_POST['nrcepend'])) ? $_POST['nrcepend'] : '';
	$dstiplog = (isset($_POST['dstiplog'])) ? retiraAcentos(utf8_decode(trim($_POST['dstiplog']))) : '';
	$nmreslog = (isset($_POST['nmreslog'])) ? retiraAcentos(utf8_decode(trim($_POST['nmreslog']))) : '';	
	$nmresbai = (isset($_POST['nmresbai'])) ? retiraAcentos(utf8_decode(trim($_POST['nmresbai']))) : '';	
	$nmrescid = (isset($_POST['nmrescid'])) ? retiraAcentos(utf8_decode(trim($_POST['nmrescid']))) : '';
	$cdufende = (isset($_POST['cdufende'])) ? trim($_POST['cdufende']) : '';
	$dscmplog = (isset($_POST['dscmplog'])) ? retiraAcentos(utf8_decode(trim($_POST['dscmplog']))) : '';
	
	// Verifica os valores permitidos para operação
	if(!in_array($operacao,array('S','V'))) exibirErro('error','O parâmetro operação inválido. Valor informado '.$operacao.'.','Alerta - Aimaro','bloqueiaFundo($(\'#divFormularioEndereco\'))',false);
	
	if( $operacao == 'V' ) validaDados();
	
	// Dependendo da operação, chamo uma procedure diferente cddopcao
	$procedure = '';
	if ( $operacao == 'V' ) {$procedure = 'valida-endereco-cep'; }
	if ( $operacao == 'S' ) {$procedure = 'gravar-endereco-cep'; }
		
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0038.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";	
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml .= "		<nrcepend>".$nrcepend."</nrcepend>";
	$xml .= "		<cdufende>".$cdufende."</cdufende>";
	$xml .= "		<dstiplog>".$dstiplog."</dstiplog>";
	$xml .= "		<nmextlog>".$nmreslog."</nmextlog>";
	$xml .= "		<nmreslog>".$nmreslog."</nmreslog>";		
	$xml .= "		<nmextbai>".$nmresbai."</nmextbai>";
	$xml .= "		<nmresbai>".$nmresbai."</nmresbai>";
	$xml .= "		<nmextcid>".$nmrescid."</nmextcid>";
	$xml .= "		<nmrescid>".$nmrescid."</nmrescid>";
	$xml .= "		<dscmplog>".$dscmplog."</dscmplog>";
	$xml .= "		<nrdrowid>?</nrdrowid>";
	$xml .= "		<flgalter>FALSE</flgalter>";	
	$xml .= '	</Dados>';
	$xml .= '</Root>';	
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO'){
		$focus = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		$addclass = "";
		if($focus != ""){
			$addclass = "$(\'#".$focus."\').addClass(\'campoErro\');";
		}
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$addclass.'bloqueiaFundo($(\'#divFormularioEndereco\'),\''.$focus.'\',\'formFormularioEndereco\');',false);
	}
	
	// Se é Validação
	if ($operacao == 'V') {				
		exibirConfirmacao('Deseja confirmar inclusão?' ,'Confirmação - Aimaro','manterEndereco(\'S\')','bloqueiaFundo($(\'#divFormularioEndereco\'))',false);
	} else {
		echo "$('#nrcepend','#formPesquisaEndereco').val('".$nrcepend."');";		
		echo "$('#formPesquisaEndereco').css({'display':'none'});";
		echo "realizaPesquisaEndereco(1,20,'N');";
		echo "$('.fecharPesquisa','#divFormularioEndereco').click();";
	}
	
	function validaDados() {					
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input, select","#formFormularioEndereco").removeClass("campoErro");';
		
		if ( $GLOBALS['nrcepend'] == 0  ) exibirErro('error','O CEP deve ser informado.','Alerta - Aimaro','$(\'#nrcepend\').addClass(\'campoErro\');bloqueiaFundo($(\'#divFormularioEndereco\'),\'nrcepend\',\'formFormularioEndereco\')',false);		
		if ( $GLOBALS['dstiplog'] == '' ) exibirErro('error','Tipo Logradouro deve ser informado.','Alerta - Aimaro','$(\'#dstiplog\').addClass(\'campoErro\');bloqueiaFundo($(\'#divFormularioEndereco\'),\'dstiplog\',\'formFormularioEndereco\')',false);				
		if ( $GLOBALS['nmreslog'] == '' ) exibirErro('error','Logradouro deve ser informado.','Alerta - Aimaro','$(\'#nmreslog\').addClass(\'campoErro\');bloqueiaFundo($(\'#divFormularioEndereco\'),\'nmreslog\',\'formFormularioEndereco\')',false);				
		if ( $GLOBALS['nmresbai'] == '' ) exibirErro('error','Bairro deve ser informado.','Alerta - Aimaro','$(\'#nmresbai\').addClass(\'campoErro\');bloqueiaFundo($(\'#divFormularioEndereco\'),\'nmresbai\',\'formFormularioEndereco\')',false);				
		if ( $GLOBALS['nmrescid'] == '' ) exibirErro('error','Cidade deve ser informada.','Alerta - Aimaro','$(\'#nmrescid\').addClass(\'campoErro\');bloqueiaFundo($(\'#divFormularioEndereco\'),\'nmrescid\',\'formFormularioEndereco\')',false);		
		if ( $GLOBALS['cdufende'] == '' || $GLOBALS['cdufende'] == 'null') exibirErro('error','Estado deve ser informado.','Alerta - Aimaro','bloqueiaFundo($(\'#divFormularioEndereco\'),\'cdufende\',\'formFormularioEndereco\')',false);		
	}
?>