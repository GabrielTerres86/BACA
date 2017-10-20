<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 12/07/2016
 * OBJETIVO     : Rotina para inclusao/alteracao da tela CADPAC
 * --------------
 * ALTERAÇÕES   : 09/02/2017 - Adicionar a funcao utf8_decode para as informacoes do cheque 
 * --------------			   conforme ja faz pro endereço (Lucas Ranghetti #610360)
 *  
 *                08/08/2017 - Implementacao da melhoria 438. Heitor (Mouts).
 *  
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : '';
    $nmextage = (isset($_POST['nmextage'])) ? $_POST['nmextage'] : '';
    $nmresage = (isset($_POST['nmresage'])) ? $_POST['nmresage'] : '';
    $insitage = (isset($_POST['insitage'])) ? $_POST['insitage'] : '';
    $cdcxaage = (isset($_POST['cdcxaage'])) ? $_POST['cdcxaage'] : '';
    $tpagenci = (isset($_POST['tpagenci'])) ? $_POST['tpagenci'] : '';
    $cdccuage = (isset($_POST['cdccuage'])) ? $_POST['cdccuage'] : '';
    $cdorgpag = (isset($_POST['cdorgpag'])) ? $_POST['cdorgpag'] : '';
    $cdagecbn = (isset($_POST['cdagecbn'])) ? $_POST['cdagecbn'] : '';
    $cdcomchq = (isset($_POST['cdcomchq'])) ? $_POST['cdcomchq'] : '';
    $vercoban = (isset($_POST['vercoban'])) ? $_POST['vercoban'] : '';
    $cdbantit = (isset($_POST['cdbantit'])) ? $_POST['cdbantit'] : '';
    $cdagetit = (isset($_POST['cdagetit'])) ? $_POST['cdagetit'] : '';
    $cdbanchq = (isset($_POST['cdbanchq'])) ? $_POST['cdbanchq'] : '';
    $cdagechq = (isset($_POST['cdagechq'])) ? $_POST['cdagechq'] : '';
    $cdbandoc = (isset($_POST['cdbandoc'])) ? $_POST['cdbandoc'] : '';
    $cdagedoc = (isset($_POST['cdagedoc'])) ? $_POST['cdagedoc'] : '';
    $flgdsede = (isset($_POST['flgdsede'])) ? $_POST['flgdsede'] : '';
    $cdagepac = (isset($_POST['cdagepac'])) ? $_POST['cdagepac'] : '';
    $dsendcop = (isset($_POST['dsendcop'])) ? $_POST['dsendcop'] : '';
    $nrendere = (isset($_POST['nrendere'])) ? $_POST['nrendere'] : '';
    $nmbairro = (isset($_POST['nmbairro'])) ? $_POST['nmbairro'] : '';
    $dscomple = (isset($_POST['dscomple'])) ? $_POST['dscomple'] : '';
    $nrcepend = (isset($_POST['nrcepend'])) ? $_POST['nrcepend'] : '';
    $idcidade = (isset($_POST['idcidade'])) ? $_POST['idcidade'] : '';
    $nmcidade = (isset($_POST['nmcidade'])) ? $_POST['nmcidade'] : '';
    $cdufdcop = (isset($_POST['cdufdcop'])) ? $_POST['cdufdcop'] : '';
    $dsdemail = (isset($_POST['dsdemail'])) ? $_POST['dsdemail'] : '';
    $dsmailbd = (isset($_POST['dsmailbd'])) ? $_POST['dsmailbd'] : '';
    $dsinform1 = (isset($_POST['dsinform1'])) ? $_POST['dsinform1'] : '';
    $dsinform2 = (isset($_POST['dsinform2'])) ? $_POST['dsinform2'] : '';
    $dsinform3 = (isset($_POST['dsinform3'])) ? $_POST['dsinform3'] : '';
    $hhsicini = (isset($_POST['hhsicini'])) ? $_POST['hhsicini'] : '';
    $hhsicfim = (isset($_POST['hhsicfim'])) ? $_POST['hhsicfim'] : '';
    $hhtitini = (isset($_POST['hhtitini'])) ? $_POST['hhtitini'] : '';
    $hhtitfim = (isset($_POST['hhtitfim'])) ? $_POST['hhtitfim'] : '';
    $hhcompel = (isset($_POST['hhcompel'])) ? $_POST['hhcompel'] : '';
    $hhcapini = (isset($_POST['hhcapini'])) ? $_POST['hhcapini'] : '';
    $hhcapfim = (isset($_POST['hhcapfim'])) ? $_POST['hhcapfim'] : '';
    $hhdoctos = (isset($_POST['hhdoctos'])) ? $_POST['hhdoctos'] : '';
    $hhtrfini = (isset($_POST['hhtrfini'])) ? $_POST['hhtrfini'] : '';
    $hhtrffim = (isset($_POST['hhtrffim'])) ? $_POST['hhtrffim'] : '';
    $hhguigps = (isset($_POST['hhguigps'])) ? $_POST['hhguigps'] : '';
    $hhbolini = (isset($_POST['hhbolini'])) ? $_POST['hhbolini'] : '';
    $hhbolfim = (isset($_POST['hhbolfim'])) ? $_POST['hhbolfim'] : '';
    $hhenvelo = (isset($_POST['hhenvelo'])) ? $_POST['hhenvelo'] : '';
    $hhcpaini = (isset($_POST['hhcpaini'])) ? $_POST['hhcpaini'] : '';
    $hhcpafim = (isset($_POST['hhcpafim'])) ? $_POST['hhcpafim'] : '';
    $hhlimcan = (isset($_POST['hhlimcan'])) ? $_POST['hhlimcan'] : '';
    $hhsiccan = (isset($_POST['hhsiccan'])) ? $_POST['hhsiccan'] : '';
    $nrtelvoz = (isset($_POST['nrtelvoz'])) ? $_POST['nrtelvoz'] : '';
    $nrtelfax = (isset($_POST['nrtelfax'])) ? $_POST['nrtelfax'] : '';
    $qtddaglf = (isset($_POST['qtddaglf'])) ? $_POST['qtddaglf'] : '';
    $qtmesage = (isset($_POST['qtmesage'])) ? $_POST['qtmesage'] : '';
    $qtddlslf = (isset($_POST['qtddlslf'])) ? $_POST['qtddlslf'] : '';
    $flsgproc = (isset($_POST['flsgproc'])) ? $_POST['flsgproc'] : '';
    $vllimapv = (isset($_POST['vllimapv'])) ? converteFloat($_POST['vllimapv']) : '';
    $qtchqprv = (isset($_POST['qtchqprv'])) ? $_POST['qtchqprv'] : '';
    $flgdopgd = (isset($_POST['flgdopgd'])) ? $_POST['flgdopgd'] : '';
    $cdageagr = (isset($_POST['cdageagr'])) ? $_POST['cdageagr'] : '';
    $cddregio = (isset($_POST['cddregio'])) ? $_POST['cddregio'] : '';
    $tpageins = (isset($_POST['tpageins'])) ? $_POST['tpageins'] : '';
    $cdorgins = (isset($_POST['cdorgins'])) ? $_POST['cdorgins'] : '';
    $vlminsgr = (isset($_POST['vlminsgr'])) ? converteFloat($_POST['vlminsgr']) : '';
    $vlmaxsgr = (isset($_POST['vlmaxsgr'])) ? converteFloat($_POST['vlmaxsgr']) : '';
    $nrdcaixa = (isset($_POST['nrdcaixa'])) ? $_POST['nrdcaixa'] : '';
    $cdopercx = (isset($_POST['cdopercx'])) ? $_POST['cdopercx'] : '';
    $dtdcaixa = (isset($_POST['dtdcaixa'])) ? $_POST['dtdcaixa'] : '';
    $rowidcxa = (isset($_POST['rowidcxa'])) ? $_POST['rowidcxa'] : '';
    $nmpasite = (isset($_POST['nmpasite'])) ? $_POST['nmpasite'] : '';
    $dstelsit = (isset($_POST['dstelsit'])) ? $_POST['dstelsit'] : '';
    $dsemasit = (isset($_POST['dsemasit'])) ? $_POST['dsemasit'] : '';
    $hrinipaa = (isset($_POST['hrinipaa'])) ? $_POST['hrinipaa'] : '';
    $hrfimpaa = (isset($_POST['hrfimpaa'])) ? $_POST['hrfimpaa'] : '';
    $indspcxa = (isset($_POST['indspcxa'])) ? $_POST['indspcxa'] : '';	
    $nrlatitu = (isset($_POST['nrlatitu'])) ? $_POST['nrlatitu'] : '';
    $nrlongit = (isset($_POST['nrlongit'])) ? $_POST['nrlongit'] : '';
	$flmajora = (isset($_POST['flmajora'])) ? $_POST['flmajora'] : '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
    
    // Monta o xml de requisicao
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";		
    $xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
    $xml .= "   <cdagenci>".$cdagenci."</cdagenci>";
    $xml .= "   <nmextage>".$nmextage."</nmextage>";
    $xml .= "   <nmresage>".$nmresage."</nmresage>";
    $xml .= "   <insitage>".$insitage."</insitage>";
    $xml .= "   <cdcxaage>".$cdcxaage."</cdcxaage>";
    $xml .= "   <tpagenci>".$tpagenci."</tpagenci>";
    $xml .= "   <cdccuage>".$cdccuage."</cdccuage>";
    $xml .= "   <cdorgpag>".$cdorgpag."</cdorgpag>";
    $xml .= "   <cdagecbn>".$cdagecbn."</cdagecbn>";
    $xml .= "   <cdcomchq>".$cdcomchq."</cdcomchq>";
    $xml .= "   <vercoban>".$vercoban."</vercoban>";
    $xml .= "   <cdbantit>".$cdbantit."</cdbantit>";
    $xml .= "   <cdagetit>".$cdagetit."</cdagetit>";
    $xml .= "   <cdbanchq>".$cdbanchq."</cdbanchq>";
    $xml .= "   <cdagechq>".$cdagechq."</cdagechq>";
    $xml .= "   <cdbandoc>".$cdbandoc."</cdbandoc>";
    $xml .= "   <cdagedoc>".$cdagedoc."</cdagedoc>";
    $xml .= "   <flgdsede>".$flgdsede."</flgdsede>";
    $xml .= "   <cdagepac>".$cdagepac."</cdagepac>";
    $xml .= "   <dsendcop>".utf8_decode($dsendcop)."</dsendcop>";
    $xml .= "   <nrendere>".$nrendere."</nrendere>";
    $xml .= "   <nmbairro>".utf8_decode($nmbairro)."</nmbairro>";
    $xml .= "   <dscomple>".utf8_decode($dscomple)."</dscomple>";
    $xml .= "   <nrcepend>".$nrcepend."</nrcepend>";
    $xml .= "   <idcidade>".$idcidade."</idcidade>";
    $xml .= "   <nmcidade>".$nmcidade."</nmcidade>";
    $xml .= "   <cdufdcop>".$cdufdcop."</cdufdcop>";
    $xml .= "   <dsdemail>".$dsdemail."</dsdemail>";
    $xml .= "   <dsmailbd>".$dsmailbd."</dsmailbd>";
    $xml .= "   <dsinform1>".utf8_decode($dsinform1)."</dsinform1>";
    $xml .= "   <dsinform2>".utf8_decode($dsinform2)."</dsinform2>";
    $xml .= "   <dsinform3>".utf8_decode($dsinform3)."</dsinform3>";
    $xml .= "   <hhsicini>".$hhsicini."</hhsicini>";
    $xml .= "   <hhsicfim>".$hhsicfim."</hhsicfim>";
    $xml .= "   <hhtitini>".$hhtitini."</hhtitini>";
    $xml .= "   <hhtitfim>".$hhtitfim."</hhtitfim>";
    $xml .= "   <hhcompel>".$hhcompel."</hhcompel>";
    $xml .= "   <hhcapini>".$hhcapini."</hhcapini>";
    $xml .= "   <hhcapfim>".$hhcapfim."</hhcapfim>";
    $xml .= "   <hhdoctos>".$hhdoctos."</hhdoctos>";
    $xml .= "   <hhtrfini>".$hhtrfini."</hhtrfini>";
    $xml .= "   <hhtrffim>".$hhtrffim."</hhtrffim>";
    $xml .= "   <hhguigps>".$hhguigps."</hhguigps>";
    $xml .= "   <hhbolini>".$hhbolini."</hhbolini>";
    $xml .= "   <hhbolfim>".$hhbolfim."</hhbolfim>";
    $xml .= "   <hhenvelo>".$hhenvelo."</hhenvelo>";
    $xml .= "   <hhcpaini>".$hhcpaini."</hhcpaini>";
    $xml .= "   <hhcpafim>".$hhcpafim."</hhcpafim>";
    $xml .= "   <hhlimcan>".$hhlimcan."</hhlimcan>";
    $xml .= "   <hhsiccan>".$hhsiccan."</hhsiccan>";
    $xml .= "   <nrtelvoz>".$nrtelvoz."</nrtelvoz>";
    $xml .= "   <nrtelfax>".$nrtelfax."</nrtelfax>";
    $xml .= "   <qtddaglf>".$qtddaglf."</qtddaglf>";
    $xml .= "   <qtmesage>".$qtmesage."</qtmesage>";
    $xml .= "   <qtddlslf>".$qtddlslf."</qtddlslf>";
    $xml .= "   <flsgproc>".$flsgproc."</flsgproc>";
    $xml .= "   <vllimapv>".$vllimapv."</vllimapv>";
    $xml .= "   <qtchqprv>".$qtchqprv."</qtchqprv>";
    $xml .= "   <flgdopgd>".$flgdopgd."</flgdopgd>";
    $xml .= "   <cdageagr>".$cdageagr."</cdageagr>";
    $xml .= "   <cddregio>".$cddregio."</cddregio>";
    $xml .= "   <tpageins>".$tpageins."</tpageins>";
    $xml .= "   <cdorgins>".$cdorgins."</cdorgins>";
    $xml .= "   <vlminsgr>".$vlminsgr."</vlminsgr>";
    $xml .= "   <vlmaxsgr>".$vlmaxsgr."</vlmaxsgr>";
    $xml .= "   <nrdcaixa>".$nrdcaixa."</nrdcaixa>";
    $xml .= "   <cdopercx>".$cdopercx."</cdopercx>";
    $xml .= "   <dtdcaixa>".$dtdcaixa."</dtdcaixa>";
    $xml .= "   <rowidcxa>".$rowidcxa."</rowidcxa>";
    $xml .= "   <nmpasite>".utf8_decode($nmpasite)."</nmpasite>";
    $xml .= "   <dstelsit>".$dstelsit."</dstelsit>";
    $xml .= "   <dsemasit>".$dsemasit."</dsemasit>";
	$xml .= "   <hrinipaa>".$hrinipaa."</hrinipaa>";
	$xml .= "   <hrfimpaa>".$hrfimpaa."</hrfimpaa>";	
	$xml .= "   <indspcxa>".$indspcxa."</indspcxa>";
    $xml .= "   <nrlatitu>".$nrlatitu."</nrlatitu>";
    $xml .= "   <nrlongit>".$nrlongit."</nrlongit>";

	if ($cddopcao == 'B') { // Cadastramento de Caixa
        $nmdeacao = 'CADPAC_CAIXA';
        $dsmensag = 'Caixa gravado com sucesso!';
	} elseif ($cddopcao == 'X') { // Valor de Aprovacao do Comite Local
        $nmdeacao = 'CADPAC_VALOR_COMITE';
        $dsmensag = 'Valor de Aprova&ccedil;&atilde;o do Comit&ecirc; Local gravado com sucesso!';
	} elseif ($cddopcao == 'S') { // Valor de Aprovacao do Comite Local
        $nmdeacao = 'CADPAC_DADOS_SITE';
        $dsmensag = 'Dados gravados com sucesso!';
	} else { // Inclusao/Alteracao
	    $xml .= "   <flmajora>".$flmajora."</flmajora>";
        $nmdeacao = 'CADPAC_GRAVA';
        $dsmensag = 'PA '.($cddopcao == 'I' ? 'inclu&iacute;do' : 'alterado').' com sucesso!';
    }

	$xml .= " </Dados>";
    $xml .= "</Root>";
	
    $xmlResult = mensageria($xml, "TELA_CADPAC", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        $arrErro = explode("###", $msgErro);
        $msgErro = $arrErro[0];
        $nmCampo = $arrErro[1];
        $nmOpAba = '';
        if ($cddopcao == 'I' || $cddopcao == 'A') { // Inclusao/Alteracao
            $inOpcao = $arrErro[2];
            $nmOpAba = "acessaOpcaoAba('".$inOpcao."');";
        }
        $nmFunca = $nmCampo ? $nmOpAba."$('#".$nmCampo."', '#frmCadpac').focus();" : '' ;
        exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos',$nmFunca,false);
    }

    echo "hideMsgAguardo();";    
    echo 'showError("inform","'.$dsmensag.'","Alerta - Ayllos","carregaTelaCadpac();");';
?>