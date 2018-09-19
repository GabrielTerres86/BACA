<?
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 28/07/2011
 * OBJETIVO     : Rotina para manter as operações da tela EXTPPR
 * --------------
 * ALTERAÇÕES   :
 * --------------
 *   001 [28/02/2014] Guilherme(SUPERO)         : Novos campos NrCpfCgc e validações.
 *	 002 [11/12/2014] Lucas Reinert(CECRED)		: Adicionado campos tpproapl e novo parametro na function arrayTipo
 *   003 [01/11/2017] Passagem do tpctrato e idgaropc. (Jaison/Marcos Martini - PRJ404)
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
	$registro 		= array();
	$procedure 		= '';
	$retornoAposErro= '';

	// Recebe a operação que está sendo realizada
	$operacao		= (isset($_POST['operacao']))   ? $_POST['operacao']   : '' ;
	$nrdconta		= (isset($_POST['nrdconta']))   ? $_POST['nrdconta']   : 0  ;
	$idseqttl		=  1  ;
	$cddopcao		= (isset($_POST['cddopcao']))   ? $_POST['cddopcao']   : 0  ;
	$nrctremp		= (isset($_POST['nrctremp']))   ? $_POST['nrctremp']   : 0  ;
	$cdaditiv		= (isset($_POST['cdaditiv']))   ? $_POST['cdaditiv']   : 0  ;
	$nraditiv		= (isset($_POST['nraditiv']))   ? $_POST['nraditiv']   : 0  ;
	$tpctrato		= (isset($_POST['tpctrato']))   ? $_POST['tpctrato']   : 0  ;
	$idgaropc		= (isset($_POST['idgaropc']))   ? $_POST['idgaropc']   : 0  ;

	$idseqbem		= (isset($_POST['idseqbem']))   ? $_POST['idseqbem']   : 0  ;

	$flgpagto		= (isset($_POST['flgpagto']))   ? $_POST['flgpagto']   : '' ;
	$dtdpagto		= (isset($_POST['dtdpagto']))   ? $_POST['dtdpagto']   : '' ;
	$flgaplic		= (isset($_POST['flgaplic']))   ? $_POST['flgaplic']   : '' ;
	$tpaplica		= (isset($_POST['tpaplica']))   ? $_POST['tpaplica']   : 0  ;
	$nraplica		= (isset($_POST['nraplica']))   ? $_POST['nraplica']   : 0  ;

	$nrctagar		= (isset($_POST['nrctagar']))   ? $_POST['nrctagar']   : 0  ;
	$dsbemfin		= (isset($_POST['dsbemfin']))   ? $_POST['dsbemfin']   : '' ;
	$dschassi		= (isset($_POST['dschassi']))   ? $_POST['dschassi']   : '' ;
	$nrdplaca		= (isset($_POST['nrdplaca']))   ? str_replace('-','',$_POST['nrdplaca']) : '' ;
	$dscorbem		= (isset($_POST['dscorbem']))   ? $_POST['dscorbem']   : '' ;
	$nranobem		= (isset($_POST['nranobem']))   ? $_POST['nranobem']   : 0  ;
	$nrmodbem		= (isset($_POST['nrmodbem']))   ? $_POST['nrmodbem']   : 0  ;
	$nrrenava		= (isset($_POST['nrrenava']))   ? $_POST['nrrenava']   : 0  ;
	$tpchassi		= (isset($_POST['tpchassi']))   ? $_POST['tpchassi']   : 0  ;
	$ufdplaca		= (isset($_POST['ufdplaca']))   ? $_POST['ufdplaca']   : '' ;
	$uflicenc		= (isset($_POST['uflicenc']))   ? $_POST['uflicenc']   : '' ;
    $nrcpfcgc       = (isset($_POST['nrcpfcgc']))   ? $_POST['nrcpfcgc']   : 0 ;

	$nrcpfgar		= (isset($_POST['nrcpfgar']))   ? $_POST['nrcpfgar']   : 0  ;
	$nrdocgar		= (isset($_POST['nrdocgar']))   ? $_POST['nrdocgar']   : 0  ;
	$nmdgaran		= (isset($_POST['nmdgaran']))   ? $_POST['nmdgaran']   : '' ;

	$nrpromi1		= (isset($_POST['nrpromi1']))   ? $_POST['nrpromi1']   : '' ;
	$nrpromi2		= (isset($_POST['nrpromi2']))   ? $_POST['nrpromi2']   : '' ;
	$nrpromi3		= (isset($_POST['nrpromi3']))   ? $_POST['nrpromi3']   : '' ;
	$nrpromi4		= (isset($_POST['nrpromi4']))   ? $_POST['nrpromi4']   : '' ;
	$nrpromi5		= (isset($_POST['nrpromi5']))   ? $_POST['nrpromi5']   : '' ;
	$nrpromi6		= (isset($_POST['nrpromi6']))   ? $_POST['nrpromi6']   : '' ;
	$nrpromi7		= (isset($_POST['nrpromi7']))   ? $_POST['nrpromi7']   : '' ;
	$nrpromi8		= (isset($_POST['nrpromi8']))   ? $_POST['nrpromi8']   : '' ;
	$nrpromi9		= (isset($_POST['nrpromi9']))   ? $_POST['nrpromi9']   : '' ;
	$nrprom10		= (isset($_POST['nrprom10']))   ? $_POST['nrprom10']   : '' ;

	$vlpromi1		= (isset($_POST['vlpromi1']))   ? $_POST['vlpromi1']   : 0  ;
	$vlpromi2		= (isset($_POST['vlpromi2']))   ? $_POST['vlpromi2']   : 0  ;
	$vlpromi3		= (isset($_POST['vlpromi3']))   ? $_POST['vlpromi3']   : 0  ;
	$vlpromi4		= (isset($_POST['vlpromi4']))   ? $_POST['vlpromi4']   : 0  ;
	$vlpromi5		= (isset($_POST['vlpromi5']))   ? $_POST['vlpromi5']   : 0  ;
	$vlpromi6		= (isset($_POST['vlpromi6']))   ? $_POST['vlpromi6']   : 0  ;
	$vlpromi7		= (isset($_POST['vlpromi7']))   ? $_POST['vlpromi7']   : 0  ;
	$vlpromi8		= (isset($_POST['vlpromi8']))   ? $_POST['vlpromi8']   : 0  ;
	$vlpromi9		= (isset($_POST['vlpromi9']))   ? $_POST['vlpromi9']   : 0  ;
	$vlprom10		= (isset($_POST['vlprom10']))   ? $_POST['vlprom10']   : 0  ;

	$tpaplic1		= (isset($_POST['tpaplic1']))   ? $_POST['tpaplic1']   : '' ;
	$tpaplic3		= (isset($_POST['tpaplic3']))   ? $_POST['tpaplic3']   : '' ;
	$tpaplic5		= (isset($_POST['tpaplic5']))   ? $_POST['tpaplic5']   : '' ;
	$tpaplic7		= (isset($_POST['tpaplic7']))   ? $_POST['tpaplic7']   : '' ;
	$tpaplic8		= (isset($_POST['tpaplic8']))   ? $_POST['tpaplic8']   : '' ;
	
	$tpproap1		= (isset($_POST['tpproap1']))   ? $_POST['tpproap1']   : '' ;
	$tpproap3		= (isset($_POST['tpproap3']))   ? $_POST['tpproap3']   : '' ;
	$tpproap5		= (isset($_POST['tpproap5']))   ? $_POST['tpproap5']   : '' ;
	$tpproap7		= (isset($_POST['tpproap7']))   ? $_POST['tpproap7']   : '' ;
	$tpproap8		= (isset($_POST['tpproap8']))   ? $_POST['tpproap8']   : '' ;

	$registro = !empty($tpaplic1) ? arrayTipo('1', $tpaplic1, $tpproap1, $registro) : $registro;
	$registro = !empty($tpaplic3) ? arrayTipo('3', $tpaplic3, $tpproap3, $registro) : $registro;
	$registro = !empty($tpaplic5) ? arrayTipo('5', $tpaplic5, $tpproap5, $registro) : $registro;
	$registro = !empty($tpaplic7) ? arrayTipo('7', $tpaplic7, $tpproap7, $registro) : $registro;
	$registro = !empty($tpaplic8) ? arrayTipo('8', $tpaplic8, $tpproap8, $registro) : $registro;

	// Dependendo da operação, chamo uma procedure diferente
	switch($operacao) {
		case 'VD':  $procedure = 'Valida_Dados';	$retornoAposErro = 'bloqueiaFundo( $(\'#divRotina\') );';			break;
		case 'GD':  $procedure = 'Grava_Dados';		$retornoAposErro = 'bloqueiaFundo( $(\'#divRotina\') );';			break;
		default:    $retornoAposErro   = 'estadoInicial();'; return false; 			break;
	}

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

	if ( $cddopcao == 'E' ) {
		$retornoAposErro = 'estadoInicial();';
	}

	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0115.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '		<cdaditiv>'.$cdaditiv.'</cdaditiv>';
	$xml .= '		<nraditiv>'.$nraditiv.'</nraditiv>';
	$xml .= '		<tpctrato>'.$tpctrato.'</tpctrato>';
	$xml .= '		<idgaropc>'.$idgaropc.'</idgaropc>';
	$xml .= '		<flgpagto>'.$flgpagto.'</flgpagto>';
	$xml .= '		<dtdpagto>'.$dtdpagto.'</dtdpagto>';
	$xml .= '		<flgaplic>'.$flgaplic.'</flgaplic>';
	$xml .= '		<tpaplica>'.$tpaplica.'</tpaplica>';
	$xml .= '		<nraplica>'.$nraplica.'</nraplica>';
	$xml .= '		<nrctagar>'.$nrctagar.'</nrctagar>';
	$xml .= '		<dsbemfin>'.$dsbemfin.'</dsbemfin>';
	$xml .= '		<dschassi>'.$dschassi.'</dschassi>';
	$xml .= '		<nrdplaca>'.$nrdplaca.'</nrdplaca>';
	$xml .= '		<dscorbem>'.$dscorbem.'</dscorbem>';
	$xml .= '		<nranobem>'.$nranobem.'</nranobem>';
	$xml .= '		<nrmodbem>'.$nrmodbem.'</nrmodbem>';
	$xml .= '		<nrrenava>'.$nrrenava.'</nrrenava>';
	$xml .= '		<tpchassi>'.$tpchassi.'</tpchassi>';
	$xml .= '		<ufdplaca>'.$ufdplaca.'</ufdplaca>';
	$xml .= '		<uflicenc>'.$uflicenc.'</uflicenc>';
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '		<idseqbem>'.$idseqbem.'</idseqbem>';
	$xml .= '		<nrcpfgar>'.$nrcpfgar.'</nrcpfgar>';
	$xml .= '		<nrdocgar>'.$nrdocgar.'</nrdocgar>';
	$xml .= '		<nmdgaran>'.$nmdgaran.'</nmdgaran>';

	$xml .= '		<nrpromis1>'.$nrpromi1.'</nrpromis1>';
	$xml .= '		<nrpromis2>'.$nrpromi2.'</nrpromis2>';
	$xml .= '		<nrpromis3>'.$nrpromi3.'</nrpromis3>';
	$xml .= '		<nrpromis4>'.$nrpromi4.'</nrpromis4>';
	$xml .= '		<nrpromis5>'.$nrpromi5.'</nrpromis5>';
	$xml .= '		<nrpromis6>'.$nrpromi6.'</nrpromis6>';
	$xml .= '		<nrpromis7>'.$nrpromi7.'</nrpromis7>';
	$xml .= '		<nrpromis8>'.$nrpromi8.'</nrpromis8>';
	$xml .= '		<nrpromis9>'.$nrpromi9.'</nrpromis9>';
	$xml .= '		<nrpromis10>'.$nrprom10.'</nrpromis10>';

	$xml .= '		<vlpromis1>'.$vlpromi1.'</vlpromis1>';
	$xml .= '		<vlpromis2>'.$vlpromi2.'</vlpromis2>';
	$xml .= '		<vlpromis3>'.$vlpromi3.'</vlpromis3>';
	$xml .= '		<vlpromis4>'.$vlpromi4.'</vlpromis4>';
	$xml .= '		<vlpromis5>'.$vlpromi5.'</vlpromis5>';
	$xml .= '		<vlpromis6>'.$vlpromi6.'</vlpromis6>';
	$xml .= '		<vlpromis7>'.$vlpromi7.'</vlpromis7>';
	$xml .= '		<vlpromis8>'.$vlpromi8.'</vlpromis8>';
	$xml .= '		<vlpromis9>'.$vlpromi9.'</vlpromis9>';
	$xml .= '		<vlpromis10>'.$vlprom10.'</vlpromis10>';

	$xml .=			xmlFilho($registro,'Aplicacoes','Itens');

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
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " $('#".$nmdcampo."').focus();"; }
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
	}

	echo "hideMsgAguardo();";

	if ( $cddopcao == 'E' and $operacao == 'VD' ) {
		echo "showConfirmacao('078 - Confirma a operacao?','Confirma&ccedil;&atilde;o - Aimaro','manterRotina(\'GD\')','fechaRotina($(\'#divRotina\'))','sim.gif','nao.gif');";

	} else if ( $cddopcao == 'E' and $operacao == 'GD' ) {
		echo "estadoInicial();";

	} else if ( $cddopcao == 'X' and $operacao == 'GD' ) {
		echo "mostraTipo();";

	} else if ( $cddopcao == 'I' and $operacao == 'VD' ) {
		$flgaplic = $xmlObjeto->roottag->tags[0]->attributes['FLGAPLIC'];
		echo "flgaplic ='".$flgaplic."';";

		$nmdgaran = $xmlObjeto->roottag->tags[0]->attributes['NMDGARAN'];
		echo "nmdgaran ='".$nmdgaran."';";

		echo "showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','substituirBem( 0 );','estadoInicial();','sim.gif','nao.gif');";

	} else if ( $cddopcao == 'I' and $operacao == 'GD' ) {
		echo "bloqueiaFundo( $('#divRotina') );";

		$nraditiv = $xmlObjeto->roottag->tags[0]->attributes['NRADITIV'];

        // Se for Cobertura de Aplicacao Vinculada a Operacao
        if ($cdaditiv == 9) {
            exibirErro('inform','Aditivo contratual de Cobertura de Aplicação criado com sucesso!','Alerta - Aimaro','carregaAditivoCadastrado(\''.$nrdconta.'\',\''.$tpctrato.'\',\''.$nrctremp.'\',\''.$nraditiv.'\')',false);
        } else {
		echo "$('#dtmvtolt', '#frmTipo').val('".$glbvars['dtmvtolt']."');";
		echo "nraditiv ='".$nraditiv."';";
		echo "$('select, input', '#frmTipo').desabilitaCampo();";
		echo "trocaBotao( 'imprimir' );";
        }
	}

	// cria um array com todas as aplicacoes
	function arrayTipo($tpaplica, $contrato, $dsproapl, $rgaplica) {
		$contrato 	= trim($contrato);
		$qtcontra	= explode('/', $contrato);
		$tpproapl	= explode('/', $dsproapl);
		$y = 0;
		foreach ( $qtcontra as $nraplica ) {
			$i = count($rgaplica);			
			$rgaplica[$i]['tpaplica'] = $tpaplica;
			$rgaplica[$i]['nraplica'] = $nraplica;
			$rgaplica[$i]['tpproapl'] = $tpproapl[$y];						
			$y = $y + 1;
		}		
		return $rgaplica;
	}

?>