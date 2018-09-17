<?
/*!
 * FONTE        : consulta_rating.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 22/11/2013
 * OBJETIVO     : Busca contratos - Tela RATBND
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<?
    session_cache_limiter("private");
    session_start();

    // Includes para controle da session, variáveis globais de controle, e biblioteca de funções
    require_once("../../includes/config.php");
    require_once("../../includes/funcoes.php");
    require_once("../../includes/controla_secao.php");

    // Verifica se tela foi chamada pelo método POST
    isPostMethod();

    // Classe para leitura do xml de retorno
    require_once("../../class/xmlfile.php");

    // Recebe as variaveis
    $nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
    $inpessoa	= (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0  ;
    $nrctrato	= (isset($_POST['nrctrato'])) ? $_POST['nrctrato'] : 0  ;
    $tppesqui	= (isset($_POST['tppesqui'])) ? $_POST['tppesqui'] : 'C';
    $nrcpfcgc	= (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0  ;

    $retornoAposErro = 'focaCampoErro(\'nrdconta\', \'frmConta\');';

    if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$tppesqui)) <> "") {
        ?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
        exit();
    }

    // Monta o xml de requisição
    $xmlContrato  = '';
    $xmlContrato .= '<Root>';
    $xmlContrato .= '	<Cabecalho>';
    $xmlContrato .= '		<Bo>b1wgen0157.p</Bo>';
    $xmlContrato .= '		<Proc>consulta-informacao-ratbnd</Proc>';
    $xmlContrato .= '	</Cabecalho>';
    $xmlContrato .= '	<Dados>';
    $xmlContrato .=	'       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
    $xmlContrato .=	'       <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
    $xmlContrato .=	'       <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
    $xmlContrato .=	'       <inproces>'.$glbvars['inproces'].'</inproces>';
    $xmlContrato .=	'       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
    $xmlContrato .=	'       <nrdconta>'.$nrdconta.'</nrdconta>';
    $xmlContrato .=	'       <inpessoa>'.$inpessoa.'</inpessoa>';
    $xmlContrato .=	'       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
    $xmlContrato .=	'       <cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
    $xmlContrato .=	'       <nrctrato>'.$nrctrato.'</nrctrato>';
    $xmlContrato .=	'       <tppesqui>'.$tppesqui.'</tppesqui>';
    $xmlContrato .= '	</Dados>';
    $xmlContrato .= '</Root>';

    // Executa script para envio do XML
    $xmlResult = getDataXML($xmlContrato);

    // Cria objeto para classe de tratamento de XML
    $xmlObjRating = getObjectXML($xmlResult);

    $tpcritic	= $xmlObjRating->roottag->tags[0]->attributes['CDCRITIC'];

    // Se ocorrer um erro, mostra crítica
    if ($tpcritic == 1) {
        $retornoAposErro = 'estadoInicial();';
        $dscritic	= $xmlObjRating->roottag->tags[0]->attributes['DSCRITIC'];
        exibirErro('error',$dscritic,'Alerta - Ayllos',$retornoAposErro,false);
        exit();
    }else
    if ($tpcritic == 2)	{ // Se for critica 830, mostra todas as demais criticas em outra janela
        $criticas 	= $xmlObjRating->roottag->tags[0]->tags;
        $qtCriticas = count($criticas);

        function exibeErro($msgErro) {
            echo 'hideMsgAguardo();';
            echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
            exit();
        }

        ?><script>var tpcritic = 2;</script><?
        include ('rating.php'); // Montagem da Janela de Criticas

    }else
    if ($tpcritic == 0)	{ // Se nenhum erro ocorreu
        $dssitcrt = $xmlObjRating->roottag->tags[0]->attributes['DSDRISCO'];
        $vlctrbnd = $xmlObjRating->roottag->tags[0]->attributes["VLCTRBND"];
        $qtparbnd = $xmlObjRating->roottag->tags[0]->attributes["QTPARBND"];
        $nrinfcad = $xmlObjRating->roottag->tags[0]->attributes["NRINFCAD"];
        $dsinfcad = $xmlObjRating->roottag->tags[0]->attributes["DSINFCAD"];
        $nrgarope = $xmlObjRating->roottag->tags[0]->attributes["NRGAROPE"];
        $dsgarope = $xmlObjRating->roottag->tags[0]->attributes["DSGAROPE"];
        $nrliquid = $xmlObjRating->roottag->tags[0]->attributes["NRLIQUID"];
        $dsliquid = $xmlObjRating->roottag->tags[0]->attributes["DSLIQUID"];
        $nrpatlvr = $xmlObjRating->roottag->tags[0]->attributes["NRPATLVR"];
        $dspatlvr = $xmlObjRating->roottag->tags[0]->attributes["DSPATLVR"];
        $nrperger = $xmlObjRating->roottag->tags[0]->attributes["NRPERGER"];
        $dsperger = $xmlObjRating->roottag->tags[0]->attributes["DSPERGER"];
        $insitrat = $xmlObjRating->roottag->tags[0]->attributes["INSITRAT"];
        $dssitcrt = $xmlObjRating->roottag->tags[0]->attributes["DSSITCRT"];
        ?><script>var tpcritic = 0;</script><?

        include('form_detalhe.php');  // Mostra os detalhes da consulta do registro
        include('form_situacao.php'); // Mostra a situação do risco proposto/efetivo
    }
?>