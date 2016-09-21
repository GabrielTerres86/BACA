<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann        
 * DATA CRIAÇÃO : 10/01/2013 
 * OBJETIVO     : Rotina para manter as operações da tela ADMCRD
 * --------------
 * ALTERAÇÕES   : 26/02/2014 - Revisão e Correção (Lucas).
 *				  24/03/2014 - Implementados novos campos Projeto cartão Bancoob (Jean Michel).
 * -------------- 
 */

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$cddopcao  = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	
	$cdadmcrd  = (isset($_POST["cdadmcrd"])) ? $_POST['cdadmcrd'] : '' ; 
	$nmadmcrd  = (isset($_POST['nmadmcrd'])) ? $_POST['nmadmcrd'] : '' ; 
	$nmresadm  = (isset($_POST['nmresadm'])) ? $_POST['nmresadm'] : '' ; 
	$insitadc  = (isset($_POST['insitadc'])) ? $_POST['insitadc'] : '' ; 
	$nmbandei  = (isset($_POST['nmbandei'])) ? $_POST['nmbandei'] : '' ; 
	$qtcarnom  = (isset($_POST['qtcarnom'])) ? $_POST['qtcarnom'] : '' ; 
	$tpctahab  = (isset($_POST['tpctahab'])) ? $_POST['tpctahab'] : '' ; 
	$inanuida  = (isset($_POST['inanuida'])) ? $_POST['inanuida'] : '' ; 	
	$nrctamae  = (isset($_POST['nrctamae'])) ? $_POST['nrctamae'] : '' ; 
	$cdclasse  = (isset($_POST['cdclasse'])) ? $_POST['cdclasse'] : '' ; 	
	$nrctacor  = (isset($_POST['nrctacor'])) ? $_POST['nrctacor'] : '' ; 
	$nrdigcta  = (isset($_POST['nrdigcta'])) ? $_POST['nrdigcta'] : '' ; 
	$nrrazcta  = (isset($_POST['nrrazcta'])) ? $_POST['nrrazcta'] : '' ; 
	$nmagecta  = (isset($_POST['nmagecta'])) ? $_POST['nmagecta'] : '' ; 
	$cdagecta  = (isset($_POST['cdagecta'])) ? $_POST['cdagecta'] : '' ; 
	$cddigage  = (isset($_POST['cddigage'])) ? $_POST['cddigage'] : '' ; 
	$dsendere  = (isset($_POST['dsendere'])) ? $_POST['dsendere'] : '' ; 
	$nmbairro  = (isset($_POST['nmbairro'])) ? $_POST['nmbairro'] : '' ; 
	$nmcidade  = (isset($_POST['nmcidade'])) ? $_POST['nmcidade'] : '' ; 
	$cdufende  = (isset($_POST['cdufende'])) ? $_POST['cdufende'] : '' ; 
	$nrcepend  = (isset($_POST['nrcepend'])) ? $_POST['nrcepend'] : '' ; 
	$nmpescto  = (isset($_POST['nmpescto'])) ? $_POST['nmpescto'] : '' ; 
	$flgcchip  = (isset($_POST['flgcchip'])) ? $_POST['flgcchip'] : '' ; 
	
	$dsdemail1 = (isset($_POST['dsdemail1'])) ? $_POST['dsdemail1'] : '' ; 
	$dsdemail2 = (isset($_POST['dsdemail2'])) ? $_POST['dsdemail2'] : '' ; 
	$dsdemail3 = (isset($_POST['dsdemail3'])) ? $_POST['dsdemail3'] : '' ; 
	$dsdemail4 = (isset($_POST['dsdemail4'])) ? $_POST['dsdemail4'] : '' ; 
	$dsdemail5 = (isset($_POST['dsdemail5'])) ? $_POST['dsdemail5'] : '' ; 
	
	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'C' : $procedure = 'consulta-administradora'; break;
		case 'A' : $procedure = 'consulta-administradora'; break;
		case 'E' : $procedure = 'consulta-administradora'; break;
		case 'I' : $procedure = 'consulta-administradora'; break;
		case 'A1': $procedure = 'altera-adm-cartoes'; $cddopcaoAnt = $cddopcao; $cddopcao = str_replace('1','',$cddopcao); break;
		case 'I1': $procedure = 'inclui-adm-cartoes'; $cddopcaoAnt = $cddopcao; $cddopcao = str_replace('1','',$cddopcao); break;
		case 'E1': $procedure = 'exclui-adm-cartoes'; $cddopcaoAnt = $cddopcao; $cddopcao = str_replace('1','',$cddopcao); break;
		default  : $procedure = 'consulta-administradora'; break;
	}
	
	$retornoAposErro = 'focaCampoErro(\'cdadmcrd\', \'frmAdministradoras\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '  <Cabecalho>';
	$xml .= '	    <Bo>b1wgen0182.p</Bo>';
	$xml .= '        <Proc>'.$procedure.'</Proc>';
	$xml .= '  </Cabecalho>';
	$xml .= '  <Dados>';
	$xml .= '        <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '        <cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '        <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '        <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '        <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '        <cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '        <cdadmcrd>'.$cdadmcrd.'</cdadmcrd>';
	$xml .= '        <nmadmcrd>'.$nmadmcrd.'</nmadmcrd>';
	$xml .= '        <nmresadm>'.$nmresadm.'</nmresadm>';
	$xml .= '        <insitadc>'.$insitadc.'</insitadc>';
	$xml .= '        <qtcarnom>'.$qtcarnom.'</qtcarnom>';
	$xml .= '        <nmbandei>'.$nmbandei.'</nmbandei>';
	$xml .= '        <nrctacor>'.$nrctacor.'</nrctacor>';
	$xml .= '        <nrdigcta>'.$nrdigcta.'</nrdigcta>';
	$xml .= '        <nrrazcta>'.$nrrazcta.'</nrrazcta>';
	$xml .= '        <nmagecta>'.$nmagecta.'</nmagecta>';
	$xml .= '        <cdagecta>'.$cdagecta.'</cdagecta>';
	$xml .= '        <cddigage>'.$cddigage.'</cddigage>';
	$xml .= '        <dsendere>'.$dsendere.'</dsendere>';
	$xml .= '        <nmbairro>'.$nmbairro.'</nmbairro>';
	$xml .= '        <nmcidade>'.$nmcidade.'</nmcidade>';
	$xml .= '        <cdufende>'.$cdufende.'</cdufende>';
	$xml .= '        <nrcepend>'.$nrcepend.'</nrcepend>';
	$xml .= '        <nmpescto>'.$nmpescto.'</nmpescto>';
	$xml .= '        <dsemail1>'.$dsdemail1.'</dsemail1>';
	$xml .= '        <dsemail2>'.$dsdemail2.'</dsemail2>';
	$xml .= '        <dsemail3>'.$dsdemail3.'</dsemail3>';
	$xml .= '        <dsemail4>'.$dsdemail4.'</dsemail4>';
	$xml .= '        <dsemail5>'.$dsdemail5.'</dsemail5>';
	$xml .= '        <tpctahab>'.$tpctahab.'</tpctahab>';
	$xml .= '        <inanuida>'.$inanuida.'</inanuida>';
	$xml .= '		 <nrctamae>'.$nrctamae.'</nrctamae>';
	$xml .= '		 <cdclasse>'.$cdclasse.'</cdclasse>';
	$xml .= '		 <flgcchip>'.$flgcchip.'</flgcchip>';
	$xml .= '		 <flgerlog>YES</flgerlog>';
	$xml .= '  </Dados>';
	$xml .= '</Root>';
	
	if($cddopcaoAnt == 'A1' || $cddopcaoAnt == 'E1' || $cddopcaoAnt == 'I1'){
		$cddopcao = $cddopcaoAnt;
	}
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$pesquisa = $xmlObjeto->roottag->tags[0]->tags[0];
	$nmadmcrd = getByTagName($pesquisa->tags,'nmadmcrd');
	$nmresadm = getByTagName($pesquisa->tags,'nmresadm');
	$insitadc = getByTagName($pesquisa->tags,'insitadc');
	$nmbandei = getByTagName($pesquisa->tags,'nmbandei');
	$qtcarnom = getByTagName($pesquisa->tags,'qtcarnom');
	$tpctahab = getByTagName($pesquisa->tags,'tpctahab');
	$nrctamae = getByTagName($pesquisa->tags,'nrctamae');
	$cdclasse = getByTagName($pesquisa->tags,'cdclasse');
	$flgcchip = getByTagName($pesquisa->tags,'flgcchip');
	$inanuida = getByTagName($pesquisa->tags,'inanuida');
	$nrctacor = getByTagName($pesquisa->tags,'nrctacor');
	$nrdigcta = getByTagName($pesquisa->tags,'nrdigcta');
	$nrrazcta = getByTagName($pesquisa->tags,'nrrazcta');
	$nmagecta = getByTagName($pesquisa->tags,'nmagecta');
	$cdagecta = getByTagName($pesquisa->tags,'cdagecta');
	$cddigage = getByTagName($pesquisa->tags,'cddigage');
	$dsendere = getByTagName($pesquisa->tags,'dsendere');
	$nmbairro = getByTagName($pesquisa->tags,'nmbairro');
	$nmcidade = getByTagName($pesquisa->tags,'nmcidade');
	$cdufende = getByTagName($pesquisa->tags,'cdufende');
	$nrcepend = mascara(getByTagName($pesquisa->tags,'nrcepend'),'#####-###');
	$nmpescto = getByTagName($pesquisa->tags,'nmpescto');
	$dsdemail = getByTagName($pesquisa->tags,'dsdemail');

	if ($cddopcao == "C" || $cddopcao == "A" || $cddopcao == "E"){
	
		if ( $insitadc == "1" ){
			echo "$('#insitadc','#frmAdministradoras').val('NO');";
		} else {
			echo "$('#insitadc','#frmAdministradoras').val('YES');";
		}
		
		if ($flgcchip == 'yes') {
			echo "$('#flgcchip','#frmAdministradoras').prop('checked',true);";
		}else{
			echo "$('#flgcchip','#frmAdministradoras').prop('checked',false);";
		}
		
		echo "$('#nmadmcrd','#frmAdministradoras').val('$nmadmcrd');";
		echo "$('#nmresadm','#frmAdministradoras').val('$nmresadm');";		
		echo "$('#nmbandei','#frmAdministradoras').val('$nmbandei');";
		echo "$('#qtcarnom','#frmAdministradoras').val('$qtcarnom');";
		echo "$('#tpctahab','#frmAdministradoras').val('$tpctahab');";
		echo "$('#nrctamae','#frmAdministradoras').val('$nrctamae');";
		echo "$('#cdclasse','#frmAdministradoras').val('$cdclasse');";
		echo "$('#inanuida','#frmAdministradoras').val('$inanuida');";
		echo "$('#nrctacor','#frmAdministradoras').val('$nrctacor');";
		echo "$('#nrdigcta','#frmAdministradoras').val('$nrdigcta');";
		echo "$('#nrrazcta','#frmAdministradoras').val('$nrrazcta');";
		echo "$('#nmagecta','#frmAdministradoras').val('$nmagecta');";
		echo "$('#cdagecta','#frmAdministradoras').val('$cdagecta');";
		echo "$('#cddigage','#frmAdministradoras').val('$cddigage');";
		echo "$('#dsendere','#frmAdministradoras').val('$dsendere');";
		echo "$('#nmbairro','#frmAdministradoras').val('$nmbairro');";
		echo "$('#nmcidade','#frmAdministradoras').val('$nmcidade');";
		echo "$('#cdufende','#frmAdministradoras').val('$cdufende');";
		echo "$('#nrcepend','#frmAdministradoras').val('$nrcepend');";
		echo "$('#nmpescto','#frmAdministradoras').val('$nmpescto');";	
						
		// Rotina para efetuar a carga dos email no form.
		echo "carregaEmail('$dsdemail');";
		
		// Rotina para exibir apenas o botao Voltar.
		echo "trocaBotao( '' );";
	}
	
	if ($cddopcao == "I1"){
		echo 'showError("inform","Administradora incluida com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
	}
	
	if ($cddopcao == "A1"){
		echo 'showError("inform","Administradora alterada com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
	}
	
	if ($cddopcao == "E1"){
		echo 'showError("inform","Administradora excluida com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
	}
	
	echo "controlaOperacao('$cddopcao')";

?>
