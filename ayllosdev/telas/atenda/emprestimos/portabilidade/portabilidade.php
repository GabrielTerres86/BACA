<?php
/*!
 * FONTE        : portabilidade.php
 * CRIAÇÃO      : CARLOS RAFAEL TANHOLI
 * DATA CRIAÇÃO : 22/05/2015
 * OBJETIVO     : Formulário de dados da portabilidade
 */

$retorno = array();

// Montar o xml de Requisicao
$xml = '';
$xml .= "<Root>";
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
    exibirErro('error', $msgErro, 'Alerta - Aimaro', '', false);
    echo "</script>";    
} else {
    $registros = $xmlObj->roottag->tags;
}       
?>
<style type="text/css">
    #frmPortabilidadeCredito fieldset {
        padding: 15px 0;
    }
    #frmPortabilidadeCredito label {
        clear: left;
        width: 110px;
    }   
    #frmPortabilidadeCredito input#nrcnpjbase_if_origem { width: 110px; }
    #frmPortabilidadeCredito input#nmif_origem { width: 250px; text-transform: uppercase; }
    #frmPortabilidadeCredito input#nrcontrato_if_origem { width: 270px; }
    #frmPortabilidadeCredito select#cdmodali_portabilidade { width: 330px; }
    #frmPortabilidadeCredito input#nrunico_portabilidade { width: 138px; }
    #frmPortabilidadeCredito input#dssit_portabilidade { width: 330px; }
</style>
<div id="divPortabilidadeCredito">
    <form name="frmPortabilidadeCredito" id="frmPortabilidadeCredito" class="formulario">
        <fieldset>
            <legend>Portabilidade - Institui&ccedil;&atilde;o Credora Original</legend>
            
            <label for="nrcnpjbase_if_origem">CNPJ:</label>
            <input name="nrcnpjbase_if_origem" class="campo" id="nrcnpjbase_if_origem" type="text" value="" />
            
            <label for="nmif_origem">Nome:</label>
            <input name="nmif_origem" class="campo" id="nmif_origem" type="text" value="" />

            <label for="nrcontrato_if_origem">Contrato:</label>
            <input name="nrcontrato_if_origem" class="campo" id="nrcontrato_if_origem" type="text" value="" />
            
            <label for="cdmodali_portabilidade">Modalidade:</label>
            <select name="cdmodali_portabilidade" id="cdmodali_portabilidade" class="campo" >
                <option value="0">Selecione uma modalidade</option>
                <?php
                foreach ($registros as $registro) {
                    echo '<option value="' . $registro->tags[0]->cdata . '" >' . str_replace('?', "-", $registro->tags[1]->cdata) . '</option>';
                }
                ?>                
            </select>

            <label for="nrunico_portabilidade">Nr.Portabilidade:</label>
            <input name="nrunico_portabilidade" class="campo" id="nrunico_portabilidade" type="text" value="" />
            
            <label for="dssit_portabilidade">Situa&ccedil;&atilde;o:</label>    
            <input name="dssit_portabilidade" class="campo" id="dssit_portabilidade" type="text" value="" />

        </fieldset>
    </form>
    <div id="divBotoesFormPortabilidade" style="margin-top:5px; margin-bottom:5px;">
        <a href="#" class="botao" id="btVoltar">Voltar</a>
	<a href="javascript:void(0);" class="botao" id="btSalvar">Continuar</a>
    </div>
</div>
<script type="text/javascript">
    $( function() {
        highlightObjFocus($('#frmPortabilidadeCredito'));
    });
</script>    
