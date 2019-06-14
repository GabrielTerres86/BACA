<?
/*!
 * FONTE        : efetivar_ratbnd.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 22/11/2013
 * OBJETIVO     : Efetiva contratos - Tela RATBND
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
    $cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
    $nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
    $inpessoa	= (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0  ;
    $nrctrato	= (isset($_POST['nrctrato'])) ? $_POST['nrctrato'] : 0  ;
    $tppesqui	= (isset($_POST['tppesqui'])) ? $_POST['tppesqui'] : 'C';

    //Monta o xml de requisição
    if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
        exibeErro($msgError);
    }

    // Monta o xml de requisição
    $xmlContrato  = '';
    $xmlContrato .= '<Root>';
    $xmlContrato .= '	<Cabecalho>';
    $xmlContrato .= '		<Bo>b1wgen0157.p</Bo>';
    $xmlContrato .= '		<Proc>efetivacao-rating</Proc>';
    $xmlContrato .= '	</Cabecalho>';
    $xmlContrato .= '	<Dados>';
    $xmlContrato .=	'       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
    $xmlContrato .=	'       <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
    $xmlContrato .=	'       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
    $xmlContrato .=	'       <dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
    $xmlContrato .=	'       <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
    $xmlContrato .=	'       <inproces>'.$glbvars['inproces'].'</inproces>';
    $xmlContrato .=	'       <nrdconta>'.$nrdconta.'</nrdconta>';
    $xmlContrato .=	'       <inpessoa>'.$inpessoa.'</inpessoa>';
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
        echo 'var tpcritic = 1;';
        $dscritic	= $xmlObjRating->roottag->tags[0]->attributes['DSCRITIC'];
        exibirErro('error',$dscritic,'Alerta - Ayllos',$retornoAposErro,false);
        exit();
    }else
    if ($tpcritic == 2)	{ // Se for critica 830, mostra as demais criticas em outra janela
        $criticas 	= $xmlObjRating->roottag->tags[0]->tags;
        $qtCriticas = count($criticas);

        function exibeErro($msgErro) {
            echo 'hideMsgAguardo();';
            echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
            exit();
        }

        include ('rating.php'); // Monta outra janela para mostra as criticas

    }else
    if ($tpcritic == 0)	{ // Se não ocorreu nenhum erro
        $dssitcrt	= $xmlObjRating->roottag->tags[0]->attributes['DSDRISCO'];
        echo 'var tpcritic = 0;';
        echo 'var dssitcrt = "' . $dssitcrt . '";';
    }
?>
