<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 01/08/2011 
 * OBJETIVO     : Rotina para manter as operações da tela EXTEMP
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 * 000: [06/10/2011] Exibe extrato de acordo com o tipo de empréstimo -  Marcelo L. Pereira (GATI)
 * 001: [10/08/2017] Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)
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

	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$operacao		= (isset($_POST['operacao']))   ? $_POST['operacao']   : 0  ; 
	$nrdconta		= (isset($_POST['nrdconta']))   ? $_POST['nrdconta']   : 0  ; 
	$idseqttl		=  1; 
	$nrctremp		= (isset($_POST['nrctremp']))   ? $_POST['nrctremp']   : 0  ; 
	$qtdeExtemp		= (isset($_POST['qtdeExtemp'])) ? $_POST['qtdeExtemp'] : 0  ; 
	
	if ( $qtdeExtemp == '0' ) {
		$retornoAposErro = 'estadoInicial();';
	} else {
		$retornoAposErro = 'estadoExtrato();';
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0103.p</Bo>';
	$xml .= '		<Proc>Busca_Emprestimo</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xml .= '		<inproces>'.$glbvars['inproces'].'</inproces>';	
	$xml .= '		<cdprogra>extemp</cdprogra>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " focaCampoErro('".$nmdcampo."','frmCab');"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
		
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Retorno
	//----------------------------------------------------------------------------------------------------------------------------------
	$dados 	  = $xmlObjeto->roottag->tags[0]->tags[0]->tags;	
	$tpemprst = getByTagName($dados,'tpemprst');
	if($tpemprst == 0){
		echo "cVlsdeved.val('".formataMoeda(getByTagName($dados,'vlsdeved'))."');";
		echo "cVljuracu.val('".formataMoeda(getByTagName($dados,'vljuracu'))."');";
		echo "cVlemprst.val('".formataMoeda(getByTagName($dados,'vlemprst'))."');";
		echo "cVlpreemp.val('".formataMoeda(getByTagName($dados,'vlpreemp'))."');";
		echo "cDtdpagto.val('".getByTagName($dados,'dtpripgt')."');";
		echo "controlaLayout();";

		$emprestimo = $xmlObjeto->roottag->tags[1]->tags;
		preencheArray( $emprestimo );
		echo "montarTabela( 0, 30 );";
	}else if($tpemprst == 1 || $tpemprst == 2){
		echo 'verificaTipoRelatorio();';
	}

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Preenche o array
	//----------------------------------------------------------------------------------------------------------------------------------
	function preencheArray( $emprestimo ) {

		$i = 0;
		echo "arrayExtemp.length = 0;";

		foreach ( $emprestimo as $e ) {
		
			echo 'var aux = new Array();';
		
			echo 'aux[\'dtmvtolt\'] = "<span>'.dataParaTimestamp(getByTagName($e->tags,'dtmvtolt')) .'</span>'.getByTagName($e->tags,'dtmvtolt').'";';
			echo 'aux[\'cdagenci\'] = "'.getByTagName($e->tags,'cdagenci').'";';
			echo 'aux[\'cdbccxlt\'] = "'.getByTagName($e->tags,'cdbccxlt').'";';
			echo 'aux[\'nrdolote\'] = "<span>'.getByTagName($e->tags,'nrdolote').'</span>'.mascara(getByTagName($e->tags,'nrdolote'),'###.###').'";';
			echo 'aux[\'dshistor\'] = "'.getByTagName($e->tags,'dshistoi').'";';
			echo 'aux[\'nrdocmto\'] = "'.getByTagName($e->tags,'nrdocmto').'";';
			echo 'aux[\'indebcre\'] = "'.getByTagName($e->tags,'indebcre').'";';
			echo 'aux[\'vllanmto\'] = "<span>'.converteFloat(getByTagName($e->tags,'vllanmto'), 'MOEDA').'</span> '.formataMoeda(getByTagName($e->tags,'vllanmto')).' ";';
			
			if ( getByTagName($e->tags,'txjurepr') != '0') {
				echo 'aux[\'txjurepr\'] = "<span>'.converteFloat(getByTagName($e->tags,'txjurepr'),'TAXA').'</span>'.formataTaxa(getByTagName($e->tags,'txjurepr')).'";';
			} else {
				echo 'aux[\'txjurepr\'] = "";';
			}
			
			
			if ( getByTagName($e->tags,'qtpresta') != '0') {
				echo 'aux[\'qtpresta\'] = "'.number_format(str_replace(',','.',getByTagName($e->tags,'qtpresta')),4,',','.').'";';
			} else {
				echo 'aux[\'qtpresta\'] = "";';
			}
			
			// recebe
			echo 'arrayExtemp['.$i.'] = aux;';
			$i++;
			
		}
		
	
	}
?>