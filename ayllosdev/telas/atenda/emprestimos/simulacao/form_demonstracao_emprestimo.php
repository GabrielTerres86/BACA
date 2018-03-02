<?php
/*!
* FONTE        : form_demonstracao_emprestimo.php
* CRIAÇÃO      : Diogo Carlassara (MoutS)
* DATA CRIAÇÃO : 26/06/2011 
* OBJETIVO     : Formulário de demonstração do IOF

ALTERACOES     : 

*/	

$retorno = array();

// Montar o xml de Requisicao
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "PORTAB_CRED", "CAR_MODALI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    echo "<script>";
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);
    echo "</script>";    
} else {
    $registros = $xmlObj->roottag->tags;
}
?>
<div id="divProcDemonstSimulacoesFormulario" style="display:none">
    <form name="frmDemonstracaoSimulacao" id="frmSimulacao" class="formulario">
        <fieldset>
            <legend><? echo utf8ToHtml('Demonstração da simulação de empréstimo') ?></legend>

            <label for="vlemprst">Valor:</label>
            <input name="vlemprst" id="vlemprst" type="text" value="" />
            <br />

            <label for="vliofepr">IOF:</label>
            <input name="vliofepr" id="vliofepr" type="text" value=""/>
            <br />

            <label for="vlrtarif">Tarifa:</label>
            <input name="vlrtarif" id="vlrtarif" type="text" value=""/>
            <br />

            <label for="vlrtotal">Valor Total:</label>
            <input name="vlrtotal" id="vlrtotal" type="text" value=""/>
            <br />

            <label for="vlpreemp">Prest. Estim.:</label>
            <input name="vlpreemp" id="vlpreemp" type="text" value="" />
            <br />

            <label for="percetop">CET(%a.a.):</label>
            <input name="percetop" id="percetop" type="text" value="" />
            <br />
        </fieldset>
    </form>
    <div id="divBotoesFormSimulacao" style="margin-top:5px; margin-bottom:5px;">
        <a href="#" class="botao" id="btVoltar" onClick="controlaOperacaoSimulacoes('A_SIMULACAO');return false;">Voltar</a>
        <a href="#" class="botao" id="btSalvar"  onClick="mostraTabelaSimulacao('TS');return false;">Continuar</a>
    </div>
</div>

<script>

    $(document).ready(function() {
        highlightObjFocus($('#frmDemonstracaoSimulacao'));
    });

</script>