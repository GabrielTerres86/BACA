<?
/*!
 * FONTE        : mater_rotina.php
 * CRIAÇÃO      : André Santos / SUPERO				Última alteração: 25/02/2015
 * DATA CRIAÇÃO : 19/07/2013
 * OBJETIVO     : Requisição da tela LISEPR
 * --------------
 * ALTERAÇÕES   : 25/02/2015 - Validação e correção da conversão realizada pela SUPERO
							  (Adriano).
 * --------------
 */
?>

<?
    session_cache_limiter("private");
    session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');

    // Verifica se tela foi chamada pelo método POST
	isPostMethod();

    // Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	// Inicializa
	$retornoAposErro = '';

	// Recebe a operação que está sendo realizada
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0  ;
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : 0  ;
	$cddotipo = (isset($_POST['cddotipo'])) ? $_POST['cddotipo'] : '' ;
    $dtinicio = (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : '' ;
    $dttermin = (isset($_POST['dttermin'])) ? $_POST['dttermin'] : '' ;
    $nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0  ;
    $nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 9999;
    $tipsaida = (isset($_POST['tipsaida'])) ? $_POST['tipsaida'] : 0;
    $nmarquiv = (isset($_POST['nmarquiv'])) ? $_POST['nmarquiv'] : '';
	$dsiduser = session_id();
	
    
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0161.p</Bo>';
	$xml .= '		<Proc>busca_emprestimos</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '       <cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '       <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xml .= '		<dtinicio>'.$dtinicio.'</dtinicio>';
    $xml .= '		<dttermin>'.$dttermin.'</dttermin>';
    $xml .= '		<cdagesel>'.$cdagenci.'</cdagesel>';
	$xml .= '		<cdlcremp>'.$cdlcremp.'</cdlcremp>';
	$xml .= '		<cddotipo>'.$cddotipo.'</cddotipo>';
	$xml .= '		<nrregist>'.$nrregist.'</nrregist>';
	$xml .= '		<nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<nmarquiv>'.$nmarquiv.'</nmarquiv>';
	$xml .= '		<tipsaida>'.$tipsaida.'</tipsaida>';
    $xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
    $xml .= '	</Dados>';
	$xml .= '</Root>';

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

    // ----------------------------------------------------------------------------------------------------------------------------------
	// Controle de Erros
	// ----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['nmdcampo'];
		
		if($nmdcampo == ''){
			$nmdcampo = 'focaCampoErro(\'cdagenci\', \'frmOpcoes\');';
		}
		
		if($tipsaida == 1){
			$retornoAposErro = 'fechaRotina($(\'#divRotina\'));controlaLayout();'.$nmdcampo.';trocaBotao(false,\''.$cddopcao.'\');';
			
		}else{
			$retornoAposErro = 'controlaLayout();'.$nmdcampo.';trocaBotao(false,\''.$cddopcao.'\');';
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

    $emprestimo = $xmlObjeto->roottag->tags[0]->tags;
    $qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
    $vlrtotal	= $xmlObjeto->roottag->tags[0]->attributes['VLRTOTAL'];
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
    $nmarqpdf = $xmlObjeto->roottag->tags[0]->attributes["NMARQPDF"];
	
	if($cddopcao == "T"){
		include('tab_lisepr.php');
		?>
		<script type="text/javascript">
			
			$('#btSalvar','#divBotoes').css('display','none');
			trocaBotao(false,'<?echo $cddopcao;?>');
			formataTabela();
		</script>
		<?

	}else if($tipsaida == 1){
		?>
		<script type="text/javascript">
		
			fechaRotina($('#divRotina'));
			controlaLayout();
			
		</script>
		<?
		
	}else{
		echo 'Gera_Impressao("'.$nmarqpdf.'")';
	
	}

?>
