<?php
/*!
* FONTE        : form_opcao_r.php
* CRIAÇÃO      : Rogérius Militao - (DB1)
* DATA CRIAÇÃO : 30/01/2012 
* OBJETIVO     : Formulario que apresenta a opcao R da tela CUSTOD
* --------------
* ALTERAÇÕES   : 01/10/2013 - Alteração da sigla PAC para PA (Carlos).
* --------------
*/

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

/*
if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], 'R')) <> '') {
    exibirErro('error', $msgError, 'Alerta - Aimaro', '', false);
}

// Monta o xml de requisição
$xml = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0018.p</Bo>';
$xml .= '		<Proc>Inicializa_Opcao</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
$xml .= '		<cdagenci>' . $glbvars['cdagenci'] . '</cdagenci>';
$xml .= '		<nrdcaixa>' . $glbvars['nrdcaixa'] . '</nrdcaixa>';
$xml .= '		<idorigem>' . $glbvars['idorigem'] . '</idorigem>';
$xml .= '		<dtmvtolt>' . $glbvars['dtmvtolt'] . '</dtmvtolt>';
$xml .= '		<cddopcao>R</cddopcao>';
$xml .= '	</Dados>';
$xml .= '</Root>';

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
    $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    exibirErro('error', $msgErro, 'Alerta - Aimaro', '', false);
}

$dtmvtini = $xmlObjeto->roottag->tags[0]->attributes['DTMVTINI'];
$dtmvtfim = $xmlObjeto->roottag->tags[0]->attributes['DTMVTFIM'];
$nmdireto = $xmlObjeto->roottag->tags[0]->attributes['NMDIRETO'];
*/
include('form_cabecalho.php');
?>

<form id="frmOpcao" class="formulario" >

    <input type="hidden" id="cddopcao" name="cddopcao" value="" />
    <input type="hidden" id="nmdireto" name="nmdireto" value="<?php echo $nmdireto ?>" />
    <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

    <fieldset>
        <legend>Relat&oacute;rio</legend>

        <label for="dtmvtini">Per&iacute;odo Lotes:</label>
        <input type="text" id="dtmvtini" name="dtmvtini" value="<?php echo $dtmvtini ?>" />
        <label for="dtmvtfim">at&eacute;</label>
        <input type="text" id="dtmvtfim" name="dtmvtfim" value="<?php echo $dtmvtfim ?>" />

        <label for="cdagenci">PA:</label>
        <input type="text" id="cdagenci" name="cdagenci" />

        <label for="flgrelat">Detalhado:</label>
        <select id="flgrelat" name="flgrelat">
            <option value="no">Nao</option>
            <option value="yes">Sim</option>
        </select>

        <label for="nmdopcao">Sa&iacute;da:</label>
        <select id="nmdopcao" name="nmdopcao">
            <option value="yes">Arquivo</option>
            <option value="no">Impressao</option>
        </select>

    </fieldset>	

</form>

<div id="divBotoes" style="padding-bottom:10px">
    <a href="#" class="botao" id="btVoltar" onclick="btnVoltar();
                return false;">Voltar</a>
    <a href="#" class="botao" onclick="btnContinuar();
                return false;" >Prosseguir</a>
</div>


