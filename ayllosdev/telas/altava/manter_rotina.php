<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 01/08/2011 
 * OBJETIVO     : Rotina para manter as operações da tela ALTAVA
 * --------------
 * ALTERAÇÕES   : 
 * 20/06/2012 - Adicionado confirmacao de visualizacao de impressao. (Jorge)
 * 15/07/2014 - Incluso novos parametros e tratamento xml (inpessoa e dtnascto). (Daniel) 
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
	$aux 			= array();
	$procedure 		= '';
	$retornoAposErro= '';
	$nrdcontx		= 0 ;
	$nrcpfcgx		= 0 ;
	
	
	// Recebe a operação que está sendo realizada
	$operacao		= (isset($_POST['operacao']))   ? $_POST['operacao']   : '' ;
	$nrdconta		= (isset($_POST['nrdconta']))   ? $_POST['nrdconta']   : 0  ; 
	$nrctremp		= (isset($_POST['nrctremp']))   ? $_POST['nrctremp']   : 0  ; 
	$nrindice		= (isset($_POST['nrindice']))   ? $_POST['nrindice']   : 0  ;
	$nrctaava       = (isset($_POST['nrctaava']))   ? $_POST['nrctaava']   : 0  ;
	$nmdavali       = (isset($_POST['nmdavali']))   ? $_POST['nmdavali']   : '' ;
	$nrcpfcgc       = (isset($_POST['nrcpfcgc']))   ? $_POST['nrcpfcgc']   : 0  ;
	$nmconjug		= (isset($_POST['nmconjug']))   ? $_POST['nmconjug']   : '' ;
	$nrcpfcjg		= (isset($_POST['nrcpfcjg']))   ? $_POST['nrcpfcjg']   : 0  ;
	$nrcepend       = (isset($_POST['nrcepend']))   ? $_POST['nrcepend']   : 0  ;
	$dsendre1       = (isset($_POST['dsendre1']))   ? $_POST['dsendre1']   : '' ;
	$nrendere       = (isset($_POST['nrendere']))   ? $_POST['nrendere']   : 0  ;
	$complend       = (isset($_POST['complend']))   ? $_POST['complend']   : '' ;
	$nrcxapst       = (isset($_POST['nrcxapst']))   ? $_POST['nrcxapst']   : 0  ;
	$dsendre2       = (isset($_POST['dsendre2']))   ? $_POST['dsendre2']   : '' ;
	$cdufresd       = (isset($_POST['cdufresd']))   ? $_POST['cdufresd']   : '' ;
	$nmcidade       = (isset($_POST['nmcidade']))   ? $_POST['nmcidade']   : '' ;
	$dsdemail       = (isset($_POST['dsdemail']))   ? $_POST['dsdemail']   : '' ;
	$nrfonres       = (isset($_POST['nrfonres']))   ? $_POST['nrfonres']   : '' ;
	
	$inpessoa       = (isset($_POST['inpessoa']))   ? $_POST['inpessoa']   : 0  ;
	$cdnacion       = (isset($_POST['cdnacion']))   ? $_POST['cdnacion']   : '' ;	
	$dsnacion       = (isset($_POST['dsnacion']))   ? $_POST['dsnacion']   : '' ;	
	$nrctacjg       = (isset($_POST['nrctacjg']))   ? $_POST['nrctacjg']   : '' ;	
	$vlrencjg       = (isset($_POST['vlrencjg']))   ? $_POST['vlrencjg']   : '' ;	
	$vlrenmes       = (isset($_POST['vlrenmes']))   ? $_POST['vlrenmes']   : '' ;
	$dtnascto       = (isset($_POST['dtnascto']))   ? $_POST['dtnascto']   : '' ;
	
	$avalista		= (!empty($_POST['avalista'])) ? unserialize($_POST['avalista']) : array()  ;
	
	switch ( $operacao ) {
		case 'BC': $procedure = 'Busca_Contrato'; 	$retornoAposErro= 'cNrctremp.focus();'; break;
		case 'VA': $procedure = 'Valida_Avalista'; 	$retornoAposErro= 'bloqueiaFundo($(\'#divRotina\'));'; break;
		case 'VC': $procedure = 'Valida_Conta'; 	$retornoAposErro= 'bloqueiaFundo($(\'#divRotina\')); '; break;
		case 'BA': $procedure = 'Busca_Avalista'; 	$retornoAposErro= 'bloqueiaFundo($(\'#divRotina\'));'; break;
		case 'GD': $procedure = 'Grava_Dados'; 	$retornoAposErro= 'bloqueiaFundo($(\'#divRotina\'));'; break;
	}

	// Valida o 1 avalista, seta as variaveis sem nenhum valor 
	if ( $nrindice == 1 and $operacao == 'VA' ) {
		$nrdcontx = 0;
		$nrcpfcgx = 0;	

	// Validar o 2 avalista, seta as variaveis com os dados do 1 avalista 
	} else if ( $nrindice == 2 and $operacao == 'VA' ) {
		$nrdcontx = $avalista[1]['nrctaava']; // 1 avalista
		$nrcpfcgx = $avalista[1]['nrcpfcgc']; // 1 avalista
		
	// Busca os dados do avalista, atraves do cpf
	} else {
		$nrcpfcgx = $nrcpfcgc; //
	
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0126.p</Bo>";
	$xml .= "        <Proc>".$procedure."</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";	
	$xml .= "		<dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";

	$xml .= "		<nrdcontx>".$nrdcontx."</nrdcontx>"; // dados do 1 avalista	
	$xml .= "		<nrcpfcgc>".$nrcpfcgx."</nrcpfcgc>"; // dados do 1 avalista
	$xml .= "		<idavalis>".$nrindice."</idavalis>"; // dados do que está sendo validado	
	$xml .= "		<nrctaava>".$nrctaava."</nrctaava>"; // dados do que está sendo validado	
	$xml .= "		<nmdavali>".$nmdavali."</nmdavali>"; // dados do que está sendo validado	
	$xml .= "		<nrcpfava>".$nrcpfcgc."</nrcpfava>"; // dados do que está sendo validado	
	$xml .= "		<nrcpfcjg>".$nrcpfcjg."</nrcpfcjg>"; // dados do que está sendo validado	
	$xml .= "		<dsendere>".$dsendre1."</dsendere>"; // dados do que está sendo validado	
	$xml .= "		<cdufresd>".$cdufresd."</cdufresd>"; // dados do que está sendo validado	
	$xml .= "		<nrcepend>".$nrcepend."</nrcepend>"; // dados do que está sendo validado	
	
	$xml .= "		<inpessoa>".$inpessoa."</inpessoa>"; // dados do que está sendo validado
    $xml .= "		<dtnascto>".$dtnascto."</dtnascto>"; // dados do que está sendo validado

	/* Avalista 1 */
	$xml .= "		<nrctaav1>".$avalista[1]['nrctaava']."</nrctaav1>"; // 	
	$xml .= "		<cpfcgc1>".$avalista[1]['nrcpfcgc']."</cpfcgc1>"; // 	
	$xml .= "		<nmdaval1>".$avalista[1]['nmdavali']."</nmdaval1>"; // 	
	$xml .= "		<cpfccg1>".$avalista[1]['nrcpfcjg']."</cpfccg1>"; // 	
	$xml .= "		<nmcjgav1>".$avalista[1]['nmconjug']."</nmcjgav1>"; // 	
	$xml .= "		<dsenda11>".$avalista[1]['dsendre1']."</dsenda11>"; // 	
	$xml .= "		<dsenda12>".$avalista[1]['dsendre2']."</dsenda12>"; // 	
	$xml .= "		<nrfonres1>".$avalista[1]['nrfonres']."</nrfonres1>"; // 	
	$xml .= "		<dsdemail1>".$avalista[1]['dsdemail']."</dsdemail1>"; // 	
	$xml .= "		<nmcidade1>".$avalista[1]['nmcidade']."</nmcidade1>"; // 	
	$xml .= "		<cdufresd1>".$avalista[1]['cdufresd']."</cdufresd1>"; // 	
	$xml .= "		<nrcepend1>".$avalista[1]['nrcepend']."</nrcepend1>"; // 	
	$xml .= "		<nrendere1>".$avalista[1]['nrendere']."</nrendere1>"; // 	
	$xml .= "		<complend1>".$avalista[1]['complend']."</complend1>"; // 	
	$xml .= "		<nrcxapst1>".$avalista[1]['nrcxapst']."</nrcxapst1>"; //
    $xml .= "		<inpessoa1>".$avalista[1]['inpessoa']."</inpessoa1>"; // 
    $xml .= "		<cdnacion1>".$avalista[1]['cdnacion']."</cdnacion1>"; //  	
    $xml .= "		<vlrencjg1>".$avalista[1]['vlrencjg']."</vlrencjg1>"; //  	
    $xml .= "		<vlrenmes1>".$avalista[1]['vlrenmes']."</vlrenmes1>"; //  	
    $xml .= "		<dtnascto1>".$avalista[1]['dtnascto']."</dtnascto1>"; //  	
	
	/* Avalista 2 */
	$xml .= "		<nrctaav2>".$avalista[2]['nrctaava']."</nrctaav2>"; // 	
	$xml .= "		<cpfcgc2>".$avalista[2]['nrcpfcgc']."</cpfcgc2>"; // 	
	$xml .= "		<nmdaval2>".$avalista[2]['nmdavali']."</nmdaval2>"; // 	
	$xml .= "		<cpfccg2>".$avalista[2]['nrcpfcjg']."</cpfccg2>"; // 	
	$xml .= "		<nmcjgav2>".$avalista[2]['nmconjug']."</nmcjgav2>"; // 	
	$xml .= "		<dsenda21>".$avalista[2]['dsendre1']."</dsenda21>"; // 	
	$xml .= "		<dsenda22>".$avalista[2]['dsendre2']."</dsenda22>"; // 	
	$xml .= "		<nrfonres2>".$avalista[2]['nrfonres']."</nrfonres2>"; // 	
	$xml .= "		<dsdemail2>".$avalista[2]['dsdemail']."</dsdemail2>"; // 	
	$xml .= "		<nmcidade2>".$avalista[2]['nmcidade']."</nmcidade2>"; // 	
	$xml .= "		<cdufresd2>".$avalista[2]['cdufresd']."</cdufresd2>"; // 	
	$xml .= "		<nrcepend2>".$avalista[2]['nrcepend']."</nrcepend2>"; // 	
	$xml .= "		<nrendere2>".$avalista[2]['nrendere']."</nrendere2>"; // 	
	$xml .= "		<complend2>".$avalista[2]['complend']."</complend2>"; // 	
	$xml .= "		<nrcxapst2>".$avalista[2]['nrcxapst']."</nrcxapst2>"; // 	
	$xml .= "		<inpessoa2>".$avalista[2]['inpessoa']."</inpessoa2>"; // 
    $xml .= "		<cdnacion2>".$avalista[2]['cdnacion']."</cdnacion2>"; //  
    $xml .= "		<vlrencjg2>".$avalista[2]['vlrencjg']."</vlrencjg2>"; //  
    $xml .= "		<vlrenmes2>".$avalista[2]['vlrenmes']."</vlrenmes2>"; //  
    $xml .= "		<dtnascto2>".$avalista[2]['dtnascto']."</dtnascto2>"; //  
	
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
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
	
	// Busca os dados do contrato e os avalista
	if ( $operacao == 'BC' ) {
	
		$contrato = $xmlObjeto->roottag->tags[0]->tags[0]->tags; // dados contrato
		$fiadores = $xmlObjeto->roottag->tags[1]->tags; 		 // avalistas do contrato
		$qtdavali = count( $xmlObjeto->roottag->tags[1]->tags );
	
		echo "cDslcremp.val('".getByTagName($contrato,'dslcremp')."');"; 
		echo "cDsfinemp.val('".getByTagName($contrato,'dsfinemp')."');"; 
		echo "cVlemprst.val('".formataMoeda(getByTagName($contrato,'vlemprst'))."');"; 
		echo "cVlpreemp.val('".formataMoeda(getByTagName($contrato,'vlpreemp'))."');"; 
		echo "cQtpreemp.val('".getByTagName($contrato,'qtpreemp')."');";
		
		echo "qtdavali='".$qtdavali."';";
		preencheArray( $fiadores  );

		echo "controlaLayout();"; 
		
	// Valida os dados do avalista, antes de salvar	
	} else if ( $operacao == 'VA' ) {
	
		$avalista[$nrindice]['nrindice'] = $nrindice;
		$avalista[$nrindice]['nrctaava'] = $nrctaava;
		$avalista[$nrindice]['nmdavali'] = $nmdavali;
		$avalista[$nrindice]['nrcpfcgc'] = $nrcpfcgc;
		$avalista[$nrindice]['nmconjug'] = $nmconjug;
		$avalista[$nrindice]['nrcpfcjg'] = $nrcpfcjg;
		$avalista[$nrindice]['nrcepend'] = $nrcepend;
		$avalista[$nrindice]['dsendre1'] = $dsendre1;
		$avalista[$nrindice]['nrendere'] = $nrendere;
		$avalista[$nrindice]['complend'] = $complend;
		$avalista[$nrindice]['nrcxapst'] = $nrcxapst;
		$avalista[$nrindice]['dsendre2'] = $dsendre2;
		$avalista[$nrindice]['cdufresd'] = $cdufresd;
		$avalista[$nrindice]['nmcidade'] = $nmcidade;	
		$avalista[$nrindice]['dsdemail'] = $dsdemail;	
		$avalista[$nrindice]['nrfonres'] = $nrfonres;
		
		$avalista[$nrindice]['inpessoa'] = $inpessoa;	
		$avalista[$nrindice]['cdnacion'] = $cdnacion;
		$avalista[$nrindice]['dsnacion'] = $dsnacion;
		$avalista[$nrindice]['nrctacjg'] = $nrctacjg;
		$avalista[$nrindice]['vlrencjg'] = $vlrencjg;
		$avalista[$nrindice]['vlrenmes'] = $vlrenmes;
		$avalista[$nrindice]['dtnascto'] = $dtnascto;
		
		echo "avalista = '".serialize($avalista)."';";
		echo "controlaLayout();";
	
	// Valida o avalista que tem conta
	} else if ( $operacao == 'VC' ) {
		echo "manterRotina('BA');";
	
	// Busca os dados do que tem conta ou cpf/cnpj	
	} else if ( $operacao == 'BA' ) {

		$fiadores = $xmlObjeto->roottag->tags[0]->tags[0]->tags; // 
		
		// Preenche apenas se retornar o avalista
		if ( !empty($fiadores) ) { 
		
			$avalista[$nrindice]['nrctaava'] = getByTagName($fiadores,'nrctaava');
			$avalista[$nrindice]['nmdavali'] = getByTagName($fiadores,'nmdavali');
			$avalista[$nrindice]['nrcpfcgc'] = getByTagName($fiadores,'nrcpfcgc');
			$avalista[$nrindice]['nmconjug'] = getByTagName($fiadores,'nmcjgava');
			$avalista[$nrindice]['nrcpfcjg'] = getByTagName($fiadores,'nrcpfcjg');
			$avalista[$nrindice]['nrcepend'] = getByTagName($fiadores,'nrcepend');
			$avalista[$nrindice]['dsendre1'] = getByTagName($fiadores[5]->tags,'dsendava.1'); // endereco
			$avalista[$nrindice]['nrendere'] = getByTagName($fiadores,'nrendere');
			$avalista[$nrindice]['complend'] = getByTagName($fiadores,'complend');
			$avalista[$nrindice]['nrcxapst'] = getByTagName($fiadores,'nrcxapst');
			$avalista[$nrindice]['dsendre2'] = getByTagName($fiadores[5]->tags,'dsendava.2'); // bairro
			$avalista[$nrindice]['cdufresd'] = getByTagName($fiadores,'cdufende');
			$avalista[$nrindice]['nmcidade'] = getByTagName($fiadores,'nmcidade');	
			$avalista[$nrindice]['dsdemail'] = getByTagName($fiadores,'dsdemail');	
			$avalista[$nrindice]['nrfonres'] = getByTagName($fiadores,'nrfonres');

			$avalista[$nrindice]['inpessoa'] = getByTagName($fiadores,'inpessoa');
			$avalista[$nrindice]['cdnacion'] = getByTagName($fiadores,'cdnacion');			
			$avalista[$nrindice]['dsnacion'] = getByTagName($fiadores,'dsnacion');			
			$avalista[$nrindice]['nrctacjg'] = getByTagName($fiadores,'nrctacjg');			
			$avalista[$nrindice]['vlrencjg'] = getByTagName($fiadores,'vlrencjg');			
			$avalista[$nrindice]['vlrenmes'] = getByTagName($fiadores,'vlrenmes');			
			$avalista[$nrindice]['dtnascto'] = getByTagName($fiadores,'dtnascto');			
		
			echo "avalista = '".serialize($avalista)."';";

			echo "cNrctaava.val('".formataContaDV($avalista[$nrindice]['nrctaava'])."');";
			echo "cNmdavali.val('".$avalista[$nrindice]['nmdavali']."');";		
			if ($avalista[$nrindice]['inpessoa'] == 1) {
    			echo "cNrcpfcgc.val('".mascaraCpf($avalista[$nrindice]['nrcpfcgc'])."');";
			} else {
    			echo "cNrcpfcgc.val('".mascaraCnpj($avalista[$nrindice]['nrcpfcgc'])."');";
			}
			echo "cNmconjug.val('".$avalista[$nrindice]['nmconjug']."');";
			if ($avalista[$nrindice]['nrcpfcjg'] > 0) { echo "cNrcpfcjg.val('".mascaraCpf($avalista[$nrindice]['nrcpfcjg'])."');"; }
			echo "cNrcepend.val('".formataCep($avalista[$nrindice]['nrcepend'])."');";
			echo "cDsendre1.val('".$avalista[$nrindice]['dsendre1']."');";
			echo "cNrendere.val('".$avalista[$nrindice]['nrendere']."');";
			echo "cComplend.val('".$avalista[$nrindice]['complend']."');";
			echo "cNrcxapst.val('".$avalista[$nrindice]['nrcxapst']."');";
			echo "cDsendre2.val('".$avalista[$nrindice]['dsendre2']."');";
			echo "cCdufresd.val('".$avalista[$nrindice]['cdufresd']."');";
			echo "cNmcidade.val('".$avalista[$nrindice]['nmcidade']."');";
			echo "cDsdemail.val('".$avalista[$nrindice]['dsdemail']."');";
			echo "cNrfonres.val('".$avalista[$nrindice]['nrfonres']."');";
			echo "cInpessoa.val('".$avalista[$nrindice]['inpessoa']."');";
			echo "cCdnacion.val('".$avalista[$nrindice]['cdnacion']."');";
			echo "cDsnacion.val('".$avalista[$nrindice]['dsnacion']."');";
			echo "cNrctacjg.val('".formataContaDV($avalista[$nrindice]['nrctacjg'])."');";
			echo "cVlrencjg.val('".formataMoeda($avalista[$nrindice]['vlrencjg'])."');";
			echo "cVlrenmes.val('".formataMoeda($avalista[$nrindice]['vlrenmes'])."');";
			echo "cDtnascto.val('".$avalista[$nrindice]['dtnascto']."');";
	
			echo "cInpessoa.trigger('change');";

		} 
	
		echo "hideMsgAguardo();";
		echo "bloqueiaFundo($('#divRotina'));";
	
	// Salva os dados
	} else if ( $operacao == 'GD' ) {
		
		$i		  = 0;				
		$fiadores = $xmlObjeto->roottag->tags[0]->tags;  // imprimir
		
		echo "fiadores.length = 0;";

		// Verifica se teve alteracao para gerar impressao
		foreach ( $fiadores as $f ) {

			echo "var aux = new Array();";
			
			echo "aux['nrcpfava'] = '".getByTagName($f->tags,'nrcpfava')."';";
			echo "aux['nmdavali'] = '".getByTagName($f->tags,'nmdavali')."';";
			echo "aux['uladitiv'] = '".getByTagName($f->tags,'uladitiv')."';";

			$i = $i + 1;
			echo "fiadores['".$i."'] = aux;";
			
		}
		
		//
		if ( $i == 1 ) {
			echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","Gera_Impressao(\'1\');","fechaAvalista();","sim.gif","nao.gif");';
		} else if ( $i == 2 ) {
			echo "mostraImprimir();";
		} else {
			echo "fechaAvalista();";
		}
	}


	// Pega os avalistas do contrato	
	function preencheArray( $avalista ) {
	
		$i = 0;
		echo "avalista = '';"; 
		
		foreach ( $avalista as $a ) {

			$i = getByTagName($a->tags,'nrindice');
		
			$aux[$i]['nrindice'] = getByTagName($a->tags,'nrindice');
			$aux[$i]['nrctaava'] = getByTagName($a->tags,'nrctaava');
			$aux[$i]['nmdavali'] = getByTagName($a->tags,'nmdavali');
			$aux[$i]['nrcpfcgc'] = getByTagName($a->tags,'nrcpfcgc');
			$aux[$i]['nmconjug'] = getByTagName($a->tags,'nmcjgava');
			$aux[$i]['nrcpfcjg'] = getByTagName($a->tags,'nrcpfcjg');
			$aux[$i]['nrcepend'] = getByTagName($a->tags,'nrcepend');
			$aux[$i]['dsendav1'] = getByTagName($a->tags[5]->tags,'dsendava.1'); // endereco
			$aux[$i]['nrendere'] = getByTagName($a->tags,'nrendere');
			$aux[$i]['complend'] = getByTagName($a->tags,'complend');
			$aux[$i]['nrcxapst'] = getByTagName($a->tags,'nrcxapst');
			$aux[$i]['dsendav2'] = getByTagName($a->tags[5]->tags,'dsendava.2'); // bairro
			$aux[$i]['cdufresd'] = getByTagName($a->tags,'cdufende');
			$aux[$i]['nmcidade'] = getByTagName($a->tags,'nmcidade');
			$aux[$i]['dsdemail'] = getByTagName($a->tags,'dsdemail');
			$aux[$i]['nrfonres'] = getByTagName($a->tags,'nrfonres');
			$aux[$i]['inpessoa'] = getByTagName($a->tags,'inpessoa');
			$aux[$i]['cdnacion'] = getByTagName($a->tags,'cdnacion');
			$aux[$i]['dsnacion'] = getByTagName($a->tags,'dsnacion');
			$aux[$i]['nrctacjg'] = getByTagName($a->tags,'nrctacjg');
			$aux[$i]['vlrencjg'] = getByTagName($a->tags,'vlrencjg');
			$aux[$i]['vlrenmes'] = getByTagName($a->tags,'vlrenmes');
			$aux[$i]['dtnascto'] = getByTagName($a->tags,'dtnascto');
			
		}
		
		if ( $i > 0 ) {
			echo "avalista = '".serialize($aux)."';";
		}
		
	}
	
?>