<?
/*!
 * FONTE        : consulta_conta.php
 * CRIA��O      : Andre Santos - SUPERO
 * DATA CRIA��O : 22/11/2013
 * OBJETIVO     : Consultar informa��es - Tela RATBND
 * --------------
 * ALTERA��ES   :
 * --------------
 */
?>

<?
    session_cache_limiter("private");
    session_start();

    // Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
    require_once("../../includes/config.php");
    require_once("../../includes/funcoes.php");
    require_once("../../includes/controla_secao.php");

    // Verifica se tela foi chamada pelo m�todo POST
    isPostMethod();

    // Classe para leitura do xml de retorno
    require_once("../../class/xmlfile.php");

    // Recebe as variaveis
    $nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
    $tipopesq	= (isset($_POST['tipopesq'])) ? $_POST['tipopesq'] : 'C';

    if ($tipopesq == "R") { // Tipo de Pesquisa Relatorio
        if ($nrdconta == 0) { // Verifica se a conta informada � ZERO
            $retornoAposErro = 'focaCampoErro(\'cdagenci\', \'frmRelRatingOpe\');';
        }else{
            $retornoAposErro = 'focaCampoErro(\'nrdctarl\', \'frmRelRatingOpe\');';
        }
    }else{
        $retornoAposErro = 'focaCampoErro(\'nrdconta\', \'frmConta\');';
    }

    if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$tipopesq)) <> "") {
        ?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
        exit();
    }

    // Monta o xml de requisi��o
    $xmlContrato  = '';
    $xmlContrato .= '<Root>';
    $xmlContrato .= '	<Cabecalho>';
    $xmlContrato .= '		<Bo>b1wgen0157.p</Bo>';
    $xmlContrato .= '		<Proc>consulta-conta</Proc>';
    $xmlContrato .= '	</Cabecalho>';
    $xmlContrato .= '	<Dados>';
    $xmlContrato .=	'       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
    $xmlContrato .=	'       <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
    $xmlContrato .=	'       <nrdconta>'.$nrdconta.'</nrdconta>';
    $xmlContrato .=	'       <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
    $xmlContrato .=	'       <cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
    $xmlContrato .=	'       <tipopesq>'.$tipopesq.'</tipopesq>';
    $xmlContrato .= '	</Dados>';
    $xmlContrato .= '</Root>';

    // Executa script para envio do XML
    $xmlResult = getDataXML($xmlContrato);

    // Cria objeto para classe de tratamento de XML
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra cr�tica
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        $msg = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msg,'Alerta - Ayllos',$retornoAposErro,false);
        exit();
    }else {
        $associados  = $xmlObjeto->roottag->tags[0]->tags;
    }


    if ($tipopesq == "C" || // Consultar
		$tipopesq == "E" || // Efetivar
		$tipopesq == "A") { // Alterar
        $nmprimtl    = $xmlObjeto->roottag->tags[1]->attributes["NMPRIMTL"];
        $contratos   = $xmlObjeto->roottag->tags[1]->tags;
        $qtContratos = count($contratos);
        $qtrequis    = $xmlObjeto->roottag->tags[1]->attributes["QTREQUIS"];
        $dsmsgcnt    = $xmlObjeto->roottag->tags[1]->attributes["DSMSGCNT"];
        include('form_ratbnd.php');
        include('form_contrato.php');
    }else if ($tipopesq == "I") { // Incluir
        $nmprimtl = $xmlObjeto->roottag->tags[1]->attributes["NMPRIMTL"];
        $contratos   = 0;
        $qtContratos = 0;
        $qtrequis 	 = 0;
        $dsmsgcnt    = 0;
        $inpessoa    = getByTagName($associados[0]->tags,'inpessoa');
        include('form_ratbnd.php');
        include('form_contrato.php');
        include('form_detalhe.php');
    }else if ($tipopesq == "R") { // Relat�rio
        $nmprimtl = $xmlObjeto->roottag->tags[1]->attributes["NMPRIMTL"];
        $contratos   = 0;
        $qtContratos = 0;
        $qtrequis 	 = 0;
        $dsmsgcnt    = 0;
        $cdagenci    = getByTagName($associados[0]->tags,'cdagenci');
        echo '<script> nome    = "'.$nmprimtl.'";</script>';
        echo '<script> agencia = "'.$cdagenci.'";</script>';
        include('form_relatorio_efetivo.php');
    }
?>