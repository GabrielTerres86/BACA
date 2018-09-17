<?
/*!
 * FONTE        : form_inclusao.php
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 23/04/2013
 * OBJETIVO     : Mostrar campos da opcao B - Bloqueio
 * --------------
 * ALTERAÇÕES   : 19/12/2013 - Alterado label do nrdconta de "CPF/CGC" para "CPF/CNPJ". (Reinert)
 * --------------
 */

?>
<div id="divInclusao">
<form id="frmInclusao" name="frmInclusao" class="formulario" onsubmit="return false;">

    <fieldset>
		<legend><? echo utf8ToHtml('Pesquisar Associado'); ?></legend>

        <label for="nrdconta"><? echo utf8ToHtml('Informe Conta/DV ou CPF/CNPJ:') ?></label>
        <br style="clear:both;" />
        <input id="nrdconta" name="nrdconta" type="text" />

        <a href="#" class="botao" id="btOK" onclick="consulta_OLD_Inicial();return false;">OK</a>
        <input name="nmprimtl" id="nmprimtl" type="text" value="<? echo $dsdconta ?>" />
        <br style="clear:both;" />
    </fieldset>

	<br style="clear:both;" />

    <fieldset>
		<legend><? echo utf8ToHtml('Dados Judiciais'); ?></legend>

        <label for="nroficio"><? echo utf8ToHtml('Nr Of&iacute;cio:') ?></label>
        <input id="nroficio" name="nroficio" type="text" maxlength="30"  />
        <br/>

        <label for="nrproces"><? echo utf8ToHtml('Nr Processo:') ?></label>
        <input id="nrproces" name="nrproces" type="text" maxlength="30"  />
        <br/>

        <label for="dsjuizem"><? echo utf8ToHtml('Juiz Emissor:') ?></label>
        <input id="dsjuizem" name="dsjuizem" type="text" maxlength="50"  />
        <br/>

        <label for="dsresord"><? echo utf8ToHtml('Resumo da Ordem:') ?></label>
        <input id="dsresord" name="dsresord" type="text" maxlength="300"  />
        <br/>

        <label for="dtenvres"><? echo utf8ToHtml('Dt Envio Resposta:') ?></label>
        <input id="dtenvres" name="dtenvres" type="text" maxlength="12" />

        <label for="vlbloque"><? echo utf8ToHtml('Vlr Bloqueio/Transfer&ecirc;ncia:') ?></label>
        <input id="vlbloque" name="vlbloque" type="text" maxlength="20"  />
    </fieldset>

	<br style="clear:both;" />

    <fieldset>
		<legend><? echo utf8ToHtml('Contas do Cooperado'); ?></legend>
        <div id="divResultado" align="center" style="display:none;">
        </div>
    </fieldset>
	<hr style="background-color:#666; height:1px;" />

	<div id="divBotoes">
		<a href="#" class="botao" id="btnVoltar" name="btnVoltar" onClick="estadoInicial();return false;">Voltar</a>
		<a href="#" class="botao" id="btnSalvar" name="btnSalvar" onClick="incluiBloqueio(); return false;">Salvar</a>
	</div>

</form>
</div>
