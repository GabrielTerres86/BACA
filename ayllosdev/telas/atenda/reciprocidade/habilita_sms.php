<?php

    /* !
     * FONTE        : habilita_sms.php
     * CRIAÇÃO      : Ricardo Linhares
     * DATA CRIAÇÃO : 22/02/2017
     * OBJETIVO     : Rotina para exibir a habilitação do serviço de SMS
     */
?>

<?php

    session_start();
    require_once('../../../includes/config.php');
    require_once('../../../includes/funcoes.php');
    require_once('../../../includes/controla_secao.php');
    require_once('../../../class/xmlfile.php');
    isPostMethod();

    $inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 1;
    $pagina = (isset($_POST['pagina'])) ? $_POST['pagina'] : 1;
    $introca = (isset($_POST['introca'])) ? $_POST['introca'] : 0;

    $tamanho_pagina = 4;

    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
    $xml .= "   <flgstatus>1</flgstatus>";
    $xml .= "   <pagina>".$pagina."</pagina>";
    $xml .= "   <tamanho_pagina>".$tamanho_pagina."</tamanho_pagina>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "CADSMS", "LISTAR_PACOTES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }
        exibirErro('error', utf8_encode($msgErro), 'Alerta - Ayllos', "", true);
    }

    $registros = $xmlObj->roottag->tags;

?>

<style>
    .labelFormPacote {
        width:150px;
    }

	.registroinput {
		width: 115px;
	}

</style>

<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>

<form id="frmPacote" name="frmPacote" class="formulario" style="display:block;">

    <? if($introca == 0) { ?>
        <fieldset>
            <legend>Habilita&ccedil;&otilde;es SMS cobran&ccedil;a</legend>
            <br>
            <div style="height:60px; width:80px">
                <input type="radio" id="rdIndividual" name="rdTipoPacote" value="Individual" checked>
                <label for="rdIndividual" style="padding-left:5px;">Individual</label>
                <br>

                <br>
                <input type="radio" id="rdPacote" name="rdTipoPacote" <? if(count($registros) == 0) echo "disabled" ?> value="Pacote">
                <label for="rdPacote" style="padding-left:5px;">Pacote</label>
            </div>

        </fieldset>

    <? } ?>

    <!-- Grid -->
    <div id="gridPacotesHabilitar" style="display:none" />

    </div>

    <!-- Fim Grid -->


</form>

<div id="divBotoes">
    <a href="#" class="botao" id="btHabilitaSmsVoltar" onClick="acessaOpcaoContratos();">Voltar</a>
    <a href="#" class="botao" id="btHabilitaSmsContinuar" onClick="habilitaSMS.onContinuarClick();">Continuar</a>
</div>
<br>
