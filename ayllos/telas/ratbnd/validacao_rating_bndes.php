<?
/*!
 * FONTE        : validacao_rating_bndes.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 22/11/2013
 * OBJETIVO     : Validação dos itens do rating - Tela RATBND
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
    $nrcpfcgc	= (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0  ;
    $vlempbnd	= (isset($_POST['vlempbnd'])) ? $_POST['vlempbnd'] : 0  ;
    $qtparbnd	= (isset($_POST['qtparbnd'])) ? $_POST['qtparbnd'] : 0  ;
    $nrinfcad	= (isset($_POST['nrinfcad'])) ? $_POST['nrinfcad'] : 0  ;
    $nrgarope	= (isset($_POST['nrgarope'])) ? $_POST['nrgarope'] : 0  ;
    $nrliquid	= (isset($_POST['nrliquid'])) ? $_POST['nrliquid'] : 0  ;
    $inconfir	= (isset($_POST['inconfir'])) ? $_POST['inconfir'] : 0  ;
    if ($inpessoa == 1) {
        $nrpatlvr	= (isset($_POST['nrpatrim'])) ? $_POST['nrpatrim'] : 0  ;
    }else{
        $nrperger	= (isset($_POST['nrperger'])) ? $_POST['nrperger'] : 0  ;
    }

    //Monta o xml de requisição
    if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
        exibeErro($msgError);
    }

    // Monta o xml de requisição
    $xmlContrato  = '';
    $xmlContrato .= '<Root>';
    $xmlContrato .= '	<Cabecalho>';
    $xmlContrato .= '		<Bo>b1wgen0157.p</Bo>';
    $xmlContrato .= '		<Proc>validacao-rating-bndes</Proc>';
    $xmlContrato .= '	</Cabecalho>';
    $xmlContrato .= '	<Dados>';
    $xmlContrato .=	'       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
    $xmlContrato .=	'       <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
    $xmlContrato .=	'       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
    $xmlContrato .=	'       <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
    $xmlContrato .=	'       <inproces>'.$glbvars['inproces'].'</inproces>';
    $xmlContrato .=	'       <nrdconta>'.$nrdconta.'</nrdconta>';
    $xmlContrato .=	'       <inpessoa>'.$inpessoa.'</inpessoa>';
    $xmlContrato .=	'       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
    $xmlContrato .=	'       <vlempbnd>'.$vlempbnd.'</vlempbnd>';
    $xmlContrato .=	'       <qtparbnd>'.$qtparbnd.'</qtparbnd>';
    $xmlContrato .=	'       <nrinfcad>'.$nrinfcad.'</nrinfcad>';
    $xmlContrato .=	'       <nrgarope>'.$nrgarope.'</nrgarope>';
    $xmlContrato .=	'       <nrliquid>'.$nrliquid.'</nrliquid>';
    $xmlContrato .=	'       <nrpatlvr>'.$nrpatlvr.'</nrpatlvr>';
    $xmlContrato .=	'       <nrperger>'.$nrperger.'</nrperger>';
    $xmlContrato .=	'       <inconfir>'.$inconfir.'</inconfir>';
    $xmlContrato .= '	</Dados>';
    $xmlContrato .= '</Root>';

    // Executa script para envio do XML
    $xmlResult = getDataXML($xmlContrato);

    // Cria objeto para classe de tratamento de XML
    $xmlObjRating = getObjectXML($xmlResult);

    /* Quando for return OK utiliza, dscritic, tpcritic e retorno
    ou o Tipo de Retorno é 2(tpcritic == 2)	*/
    $dscritic = $xmlObjRating->roottag->tags[1]->attributes['DSCRITIC'];
    $tpcritic = $xmlObjRating->roottag->tags[1]->attributes['TPCRITIC'];
    $retorno = $xmlObjRating->roottag->tags[1]->attributes['RETORNO'];
    $nrctrato = $xmlObjRating->roottag->tags[1]->attributes['NRCTRATO'];

    /* Quando for return NOK utiliza, dscritic1, tpcritic1 e retorno1 */
    $dscritic1 = $xmlObjRating->roottag->tags[0]->attributes['DSCRITIC'];
    $tpcritic1 = $xmlObjRating->roottag->tags[0]->attributes['TPCRITIC'];
    $retorno1  = $xmlObjRating->roottag->tags[0]->attributes['RETORNO'];

    if ($retorno == 'sucesso' && $tpcritic == 0) { // Passou em todos os testes
        echo 'aux_retorno  = "'.$retorno.'";';
        echo 'var aux_tpcritic = "'.$tpcritic.'";';
        echo 'aux_nrctrato = "'.$nrctrato.'";';
    }else
    if ($retorno == 'critica') { // Retornou mensagem de confirmação
        $confirmacao   = $xmlObjRating->roottag->tags[0]->tags;
        $mensagem = getByTagName($confirmacao[0]->tags,'dsmensag');
        if ($inconfir == 2) { // Tipo: Valor Max. Utilizado(inconfir == 2)
            echo 'aux_retorno  = "'.$retorno.'";';
            echo 'aux_nrctrato = "'.$nrctrato.'";';
            echo 'var aux_tpcritic = "'.$tpcritic.'";';
            echo 'var mensagem = "'.$mensagem.'";';
        }
    }else
    if ($retorno1 == 'erro' && $tpcritic1 == 1) { // Retornou algum erro especifico
        $grupo   = $xmlObjRating->roottag->tags[0]->tags;
		$qtGrupo = 0;
        $qtGrupo = count($grupo);

        if ($qtGrupo > 0) { // Se a conta possuir grupo economico e ultrapassou valor max legal
            echo "strHTML =	'';";
			echo "strHTML += '<form name=\'frmGrupoEconomico\' id=\'frmGrupoEconomico\' class=\'formulario\'>';";
			echo "strHTML +=		'<br />';";
			echo "strHTML +=		'Conta pertence a grupo econ&ocirc;mico.';";
			echo "strHTML +=		'<br />';";
			echo "strHTML +=		'Valor ultrapassa limite legal permitido.';";
			echo "strHTML +=		'<br />';";
			echo "strHTML +=		'Verifique endividamento total das contas.';";
			echo "strHTML += '</form>';";
			echo "strHTML += '<br style=\'clear:both\' />';";
			echo "strHTML += '<br style=\'clear:both\' />';";
            echo "strHTML += '<div class=\'divRegistros\'>';";
            echo "strHTML +=	'<table>';";
            echo "strHTML +=		'<thead>';";
            echo "strHTML +=			'<tr>';";
            echo 'strHTML +=				\'<th>'.utf8ToHtml("Contas Relacionadas").'</th>\';';
            echo "strHTML +=			'</tr>';";
            echo "strHTML +=		'</thead>';";
            echo "strHTML +=		'<tbody>';";

            for ($i = 0; $i < count($grupo); $i++) { // Quantidade de contas do grupo

                echo "strHTML +=				'<tr>';";
                echo "strHTML +=					'</td>';";
                echo 'strHTML +=					\'<td><span>'.$grupo[$i]->tags[2]->cdata.'</span>\';';
                echo 'strHTML +=							\''.formataContaDV($grupo[$i]->tags[2]->cdata).'\';';
                echo "strHTML +=					'</td>';";
                echo "strHTML +=				'</tr>';";

            }

            echo "strHTML +=		'</tbody>';";
            echo "strHTML +=	'</table>';";

            echo "mostraMsgsGrupoEconomico();";
            echo "formataGrupoEconomico();";
        }

		echo 'aux_retorno  = "'.$retorno1.'";';
        echo 'var aux_tpcritic = "'.$tpcritic1.'";';
        echo 'var mensagem = "'.$dscritic1.'";';
        echo 'var existeGrupo = "'.$qtGrupo.'";';

    }else
    if ($tpcritic == 2 && $retorno == 'erro')	{ // Retornou critica 830 + erros de cadastro
        $grupo   = $xmlObjRating->roottag->tags[1]->tags;
        $qtGrupo = count($grupo);

        if ($qtGrupo > 0) {
            echo "strHTML =	'';";
            echo "strHTML +='<div class=\'divRegistros\'>';";
            echo "strHTML +=	'<table>';";
            echo "strHTML +=		'<thead>';";
            echo "strHTML +=			'<tr>';";
            echo 'strHTML +=				\'<th>'.utf8ToHtml("Contas Relacionadas").'</th>\';';
            echo "strHTML +=			'</tr>';";
            echo "strHTML +=		'</thead>';";
            echo "strHTML +=		'<tbody>';";

            for ($i = 0; $i < count($grupo); $i++) {

                echo "strHTML +=				'<tr>';";
                echo "strHTML +=					'</td>';";
                echo 'strHTML +=					\'<td><span>'.$grupo[$i]->tags[2]->cdata.'</span>\';';
                echo 'strHTML +=							\''.formataContaDV($grupo[$i]->tags[2]->cdata).'\';';
                echo "strHTML +=					'</td>';";
                echo "strHTML +=				'</tr>';";

            }

            echo "strHTML +=		'</tbody>';";
            echo "strHTML +=	'</table>';";

            echo "mostraMsgsGrupoEconomico();";
            echo "formataGrupoEconomico();";
        }


        $criticas 	= $xmlObjRating->roottag->tags[0]->tags;
        $qtCriticas = count($criticas);


        function exibeErro($msgErro) {
            echo 'hideMsgAguardo();';
            echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
            exit();
        }

        include ('rating.php');

    }

    if ($inconfir == 3) { // Exibição do Grupo Economico
        $grupo   = $xmlObjRating->roottag->tags[1]->tags;
        $qtGrupo = count($grupo);

        if ($qtGrupo > 0) {
            echo "strHTML =	'';";
            echo "strHTML +='<div class=\'divRegistros\'>';";
            echo "strHTML +=	'<table>';";
            echo "strHTML +=		'<thead>';";
            echo "strHTML +=			'<tr>';";
            echo 'strHTML +=				\'<th>'.utf8ToHtml("Contas Relacionadas").'</th>\';';
            echo "strHTML +=			'</tr>';";
            echo "strHTML +=		'</thead>';";
            echo "strHTML +=		'<tbody>';";

            for ($i = 0; $i < count($grupo); $i++) {

                echo "strHTML +=				'<tr>';";
                echo "strHTML +=					'</td>';";
                echo 'strHTML +=					\'<td><span>'.$grupo[$i]->tags[2]->cdata.'</span>\';';
                echo 'strHTML +=							\''.formataContaDV($grupo[$i]->tags[2]->cdata).'\';';
                echo "strHTML +=					'</td>';";
                echo "strHTML +=				'</tr>';";

            }

            echo "strHTML +=		'</tbody>';";
            echo "strHTML +=	'</table>';";

            echo "mostraMsgsGrupoEconomico();";
            echo "formataGrupoEconomico();";
        }else
        if ($retorno == 'sucesso') {
            if ($cddopcao == "I") {
                echo 'aux_nrctrato = "'.$nrctrato.'";';
                echo "incluirRegistro();";
            }else
            if ($cddopcao == "A") {
                echo "alterarRegistro();";
            }
        }
    }
?>
