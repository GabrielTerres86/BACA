<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jéssica (DB1)        
 * DATA CRIAÇÃO : 30/09/2013
 * OBJETIVO     : Rotina para alteração e inclusão cadastral da tela HISTOR
 * --------------
 * ALTERAÇÕES   :  05/12/2017 - Adicionado campo Ind. Monitoramento - Melhoria 458 - Antonio R. Jr (mouts)
 *                 26/03/2018 - PJ 416 - BacenJud - Incluir o campo de inclusão do histórico no bloqueio judicial - Márcio - Mouts  
 *                 05/04/2018 - PJ 416 - BacenJud - Incluido no XML de gravacao o valor operauto (operador do form senha) 
 *                                                  para salvar no log - Mateus Z (Mouts)
 *                 11/04/2018 - Incluído novo campo "Estourar a conta corrente" (inestocc)
 *                              Diego Simas - AMcom
 *                 16/05/2017 - Ajustes prj420 - Resolucao - Heitor (Mouts)
 *
 *                 15/05/2018 - 364 - Sm5 - Incluir campo inperdes - Rafael (Mouts)
 *
 *				   18/07/2018 - Alterado para esconder o campo referente ao débito após o estouro de conta  
 * 							    Criado novo campo "indebprj", indicador de débito após transferência da CC para Prejuízo
 * 							    PJ 450 - Diego Simas - AMcom
 * -------------- 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	$cdhistor = (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0;
	$cdhinovo = (isset($_POST['cdhinovo'])) ? $_POST['cdhinovo'] : 0;
	
	$cdhstctb = (isset($_POST['cdhstctb'])) ? $_POST['cdhstctb'] : 0;
	$dsexthst = (isset($_POST['dsexthst'])) ? $_POST['dsexthst'] : '';
	$dshistor = (isset($_POST['dshistor'])) ? $_POST['dshistor'] : '';
	$inautori = (isset($_POST['inautori'])) ? $_POST['inautori'] : 0;
	$inavisar = (isset($_POST['inavisar'])) ? $_POST['inavisar'] : 0;
	$inclasse = (isset($_POST['inclasse'])) ? $_POST['inclasse'] : 0;
	$incremes = (isset($_POST['incremes'])) ? $_POST['incremes'] : 0;
	$inmonpld = (isset($_POST['inmonpld'])) ? $_POST['inmonpld'] : 0;
	$indcompl = (isset($_POST['indcompl'])) ? $_POST['indcompl'] : 0;
	$indebcta = (isset($_POST['indebcta'])) ? $_POST['indebcta'] : 0;
	$indoipmf = (isset($_POST['indoipmf'])) ? $_POST['indoipmf'] : 0;
	$inestocc = (isset($_POST['inestocc'])) ? $_POST['inestocc'] : 0;
	$indebprj = (isset($_POST['indebprj'])) ? $_POST['indebprj'] : 0;

	$inhistor = (isset($_POST['inhistor'])) ? $_POST['inhistor'] : 0;
	$indebcre = (isset($_POST['indebcre'])) ? $_POST['indebcre'] : '';
	$nmestrut = (isset($_POST['nmestrut'])) ? $_POST['nmestrut'] : '';
	$nrctacrd = (isset($_POST['nrctacrd'])) ? $_POST['nrctacrd'] : 0;
	$nrctatrc = (isset($_POST['nrctatrc'])) ? $_POST['nrctatrc'] : 0;
	$nrctadeb = (isset($_POST['nrctadeb'])) ? $_POST['nrctadeb'] : 0;
	$nrctatrd = (isset($_POST['nrctatrd'])) ? $_POST['nrctatrd'] : 0;
	$tpctbccu = (isset($_POST['tpctbccu'])) ? $_POST['tpctbccu'] : 0;
	$tplotmov = (isset($_POST['tplotmov'])) ? $_POST['tplotmov'] : 0;
	$tpctbcxa = (isset($_POST['tpctbcxa'])) ? $_POST['tpctbcxa'] : 0;

	$ingercre = (isset($_POST['ingercre'])) ? $_POST['ingercre'] : 0;
	$ingerdeb = (isset($_POST['ingerdeb'])) ? $_POST['ingerdeb'] : 0;
	
	$cdgrupo_historico = (isset($_POST['cdgrupo_historico'])) ? $_POST['cdgrupo_historico'] : 0;
	
	$flgsenha = (isset($_POST['flgsenha'])) ? $_POST['flgsenha'] : 0;
	$indutblq = (isset($_POST['indutblq'])) ? $_POST['indutblq'] : '';
	$cdprodut = (isset($_POST['cdprodut'])) ? $_POST['cdprodut'] : 0;
	$cdagrupa = (isset($_POST['cdagrupa'])) ? $_POST['cdagrupa'] : 0;
	$dsextrat = (isset($_POST['dsextrat'])) ? $_POST['dsextrat'] : '';

	$vltarayl = (isset($_POST['vltarayl'])) ? $_POST['vltarayl'] : 0;
	$vltarcxo = (isset($_POST['vltarcxo'])) ? $_POST['vltarcxo'] : 0;
	$vltarint = (isset($_POST['vltarint'])) ? $_POST['vltarint'] : 0;
	$vltarcsh = (isset($_POST['vltarcsh'])) ? $_POST['vltarcsh'] : 0;

	$indebfol = (isset($_POST['indebfol'])) ? $_POST['indebfol'] : 0;
	$txdoipmf = (isset($_POST['txdoipmf'])) ? $_POST['txdoipmf'] : 0;

	$inperdes = (isset($_POST['inperdes'])) ? $_POST['inperdes'] : 0;
	$idmonpld = (isset($_POST['idmonpld'])) ? $_POST['idmonpld'] : 0;

	// PRJ 416 - Receber via POST o operador que autorizou via form senha
	$operauto = (isset($_POST['operauto'])) ? $_POST['operauto'] : 0;

    if ($cdhistor == 0 ) {
		exibirErro('error','C&oacute;digo do hist&oacute;rico inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('cdhistor','frmHistorico');",false);
	}

    if ($cddopcao == "I" && $cdhinovo == 0 ) {
		exibirErro('error','Novo c&oacute;digo do hist&oacute;rico inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('cdhinovo','frmHistorico');",false);
	}
	
    if ($dshistor == '' ) {
		exibirErro('error','Nome do hist&oacute;rico inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('dshistor','frmHistorico');",false);
	}

    if ($indebcre != 'C' && $indebcre != 'D') {
		exibirErro('error','D&eacute;bito/Cr&eacute;dito inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('indebcre','frmHistorico');",false);
	}
	
    if ($dsexthst == '' ) {
		exibirErro('error','Descri&ccedil;&atilde;op extensa inv&aacute;lida.','Alerta - Ayllos',"focaCampoErro('dsexthst','frmHistorico');",false);
	}

    if ($dsextrat == '' ) {
		exibirErro('error','Descri&ccedil;&atilde;op extrato inv&aacute;lida.','Alerta - Ayllos',"focaCampoErro('dsextrat','frmHistorico');",false);
	}

    if ($indoipmf != 0 && $indoipmf != 1 && $indoipmf != 2) {
		exibirErro('error','Indicador de Incid&ecirc;ncia IPMF inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('indoipmf','frmHistorico');",false);
	}

    if ($inautori != 0 && $inautori != 1) {
		exibirErro('error','Indicador para autoriza&ccedil;&atilde;o de d&eacute;bito inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('inautori','frmHistorico');",false);
	}

    if ($inavisar != 0 && $inavisar != 1) {
		exibirErro('error','Indicador de aviso para d&eacute;bito inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('inavisar','frmHistorico');",false);
	}

    if ($indcompl != 0 && $indcompl != 1) {
		exibirErro('error','Indicador de complemento inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('indcompl','frmHistorico');",false);
	}
	
    if ($indebcta != 0 && $indebcta != 1) {
		exibirErro('error','Indicador d&eacute;bito em conta inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('indebcta','frmHistorico');",false);
	}

    if ($incremes != 0 && $incremes != 1) {
		exibirErro('error','Indicador para estat&iacute;stica de cr&eacute;dito do m&ecirc;s inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('incremes','frmHistorico');",false);
	}

	if ($inmonpld != 0 && $inmonpld != 1) {
		exibirErro('error','Indicador para Monitoramento inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('inmonpld','frmHistorico');",false);
	}

    if ($tpctbccu != 0 && $tpctbccu != 1) {
		exibirErro('error','Tipo de contabiliza&ccedil;&atilde;o no centro de custo inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('tpctbccu','frmHistorico');",false);
	}

    if ($tpctbcxa != 0 && $tpctbcxa != 1 && $tpctbcxa != 2 && $tpctbcxa != 3 && $tpctbcxa != 4 && $tpctbcxa != 5 && $tpctbcxa != 6) {
		exibirErro('error','Tipo de contabiliza&ccedil;&atilde;o no caixa inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('tpctbcxa','frmHistorico');",false);
	}

    if ($ingercre != 1 && $ingercre != 2 && $ingercre != 3) {
		exibirErro('error','Gerencial a cr&eacute;dito inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('ingercre','frmHistorico');",false);
	}
	
	if ($inestocc != 0 && $inestocc != 1) {
		exibirErro('error','Estourar a Conta Corrente inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('inestocc','frmHistorico');",false);
	}
	
	if ($indebprj != 0 && $indebprj != 1) {
		exibirErro('error','Debita ap&oacute;s transfer&ecirc;ncia da conta para preju&iacute;zo.','Alerta - Ayllos',"focaCampoErro('indebprj','frmHistorico');",false);
	}
    if ($ingerdeb != 1 && $ingerdeb != 2 && $ingerdeb != 3) {
		exibirErro('error','Gerencial a d&eacute;bito inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('ingerdeb','frmHistorico');",false);
	}
	
    if ($flgsenha != 0 && $flgsenha != 1) {
		exibirErro('error','Solicita&ccedil;&atilde;o de senha  inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('flgsenha','frmHistorico');",false);
	}

	if ($idmonpld != 0 && $idmonpld != 1) {
		exibirErro('error','Indicador para Monitoramento inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('idmonpld','frmHistorico');",false);
	}
	if ($inperdes != 0 && $inperdes != 1) {
		exibirErro('error','Indicador para Permitir Desligamento inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('inperdes','frmHistorico');",false);
	}


	if ($indutblq != 'S' && $indutblq != 'N') {
		exibirErro('error','Indicador de Considera para Bloqueio Judicial inv&aacute;lido.','Alerta - Ayllos',"focaCampoErro('indutblq','frmHistorico');",false);
	}

	/*  Campos sem validacao:
			- nmestrut
			- inclasse
			- cdhstctb
			- nrctacre
			- nrctadeb
			- nrctatrc
			- nrctatrd
			- vltarayl
			- vltarcxo
			- vltarint
			- vltarcsh
			- cdprodut
			- cdagrupa
	*/

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0179.p</Bo>';
	$xml .= '		<Proc>Grava_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '       <cdhistor>'.$cdhistor.'</cdhistor>';
	$xml .= '       <cdhinovo>'.$cdhinovo.'</cdhinovo>';
	
	$xml .= '       <cdhstctb>'.$cdhstctb.'</cdhstctb>';
	$xml .= '       <dsexthst>'.$dsexthst.'</dsexthst>';
	$xml .= '       <dshistor>'.$dshistor.'</dshistor>';
	$xml .= '       <inautori>'.$inautori.'</inautori>';
	$xml .= '       <inavisar>'.$inavisar.'</inavisar>';
	$xml .= '       <inclasse>'.$inclasse.'</inclasse>';
	$xml .= '       <incremes>'.$incremes.'</incremes>';
	$xml .= '       <inmonpld>'.$inmonpld.'</inmonpld>';
	$xml .= '       <indcompl>'.$indcompl.'</indcompl>';
	$xml .= '       <indebcta>'.$indebcta.'</indebcta>';
	$xml .= '       <indoipmf>'.$indoipmf.'</indoipmf>';

	$xml .= '       <inhistor>'.$inhistor.'</inhistor>';
	$xml .= '       <indebcre>'.$indebcre.'</indebcre>';
	$xml .= '       <nmestrut>'.$nmestrut.'</nmestrut>';
	$xml .= '       <nrctacrd>'.$nrctacrd.'</nrctacrd>';
	$xml .= '       <nrctatrc>'.$nrctatrc.'</nrctatrc>';
	$xml .= '       <nrctadeb>'.$nrctadeb.'</nrctadeb>';
	$xml .= '       <nrctatrd>'.$nrctatrd.'</nrctatrd>';
	$xml .= '       <tpctbccu>'.$tpctbccu.'</tpctbccu>';
	$xml .= '       <tplotmov>'.$tplotmov.'</tplotmov>';
	$xml .= '       <tpctbcxa>'.$tpctbcxa.'</tpctbcxa>';

	$xml .= '       <ingercre>'.$ingercre.'</ingercre>';
	$xml .= '       <inestocc>'.$inestocc.'</inestocc>';
	$xml .= '       <indebprj>'.$indebprj.'</indebprj>';
	$xml .= '       <ingerdeb>'.$ingerdeb.'</ingerdeb>';
	
	$xml .= '       <cdgrphis>'.$cdgrupo_historico.'</cdgrphis>';
	
	$xml .= '       <flgsenha>'.$flgsenha.'</flgsenha>';
	$xml .= '       <indutblq>'.$indutblq.'</indutblq>';
	$xml .= '       <cdprodut>'.$cdprodut.'</cdprodut>';
	$xml .= '       <cdagrupa>'.$cdagrupa.'</cdagrupa>';
	$xml .= '       <dsextrat>'.$dsextrat.'</dsextrat>';

	$xml .= '       <vltarayl>'.$vltarayl.'</vltarayl>';
	$xml .= '       <vltarcxo>'.$vltarcxo.'</vltarcxo>';
	$xml .= '       <vltarint>'.$vltarint.'</vltarint>';
	$xml .= '       <vltarcsh>'.$vltarcsh.'</vltarcsh>';

	$xml .= '       <indebfol>'.$indebfol.'</indebfol>';
	$xml .= '       <txdoipmf>'.$txdoipmf.'</txdoipmf>';
	$xml .= '       <inperdes>'.$inperdes.'</inperdes>';    
	
	$xml .= '       <idmonpld>'.$idmonpld.'</idmonpld>';
	
	// PRJ 416 - Passar via parametro o operador que autorizou, para que dentro da proc seja gravado log com esse valor
	$xml .= '       <operauto>'.$operauto.'</operauto>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML e cria objeto para classe de tratamento de XML

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	// Verifica se ocorreu erro na gravacao
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}

		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];	
		if (!empty($nmdcampo)) { $mtdErro = "focaCampoErro('" . $nmdcampo . "','frmHistorico');"; }
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	} 

	// Se nao ocorreu erro, exibe mensagem de sucesso e volta para o estado inicial da tela
	echo 'showError("inform","Operacao Efetuada com Sucesso.","Notifica&ccedil;&atilde;o - Ayllos","estadoInicial();");';	
	
?>
