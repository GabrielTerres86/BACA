<?php
/*!
 * FONTE        : form_cadsms_OpI.php
 * CRIAÇÃO      : Ricardo Linhares
 * DATA CRIAÇÃO : 21/05/2017
 * OBJETIVO     : Incluir pacote de SMS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<style>
    .labelNomeParametro {
        width:200px;
    }

	.registroinput {
		width: 115px;
	}

</style>


<div id="divOpcaoI">
<form id="frmOpcaoI" name="frmOpcaoI" class="formulario" style="display:block;">

	<br style="clear:both" />

    <label for="idpacote" class="labelNomeParametro"><? echo utf8ToHtml('Código do Pacote:') ?></label>
	<input name="idpacote" id="idpacote" disabled readonly class="registroinput" type="text" style="margin-right: 5px" />

    <br style="clear:both" />

    <label for="dspacote" class="labelNomeParametro"><? echo utf8ToHtml('Descrição do Pacote:') ?></label>
	<input name="dspacote" id="dspacote" style='width:300px' maxlength="30" type="text" style="margin-right: 5px" />

    <br style="clear:both" />

    <label for="cdtarifa" class="labelNomeParametro"><? echo utf8ToHtml('Código da Tarifa:') ?></label>
	<input name="cdtarifa" id="cdtarifa" class="registroinput" type="text" style="margin-right: 5px" />

    <br style="clear:both" />

    <label for="perdesconto" class="labelNomeParametro"><? echo utf8ToHtml('% de Desconto:') ?></label>
	<input name="perdesconto" id="perdesconto" class="registroinput" type="text"  style="margin-right: 5px" />

    <br style="clear:both" />

    <label for="qtdsms" class="labelNomeParametro"><? echo utf8ToHtml('Quantidade de SMSs:') ?></label>
	<input name="qtdsms" id="qtdsms" class="registroinput" type="text" style="margin-right: 5px" />

    <br style="clear:both" />

    <label for="flgstatus" class="labelNomeParametro"><? echo utf8ToHtml('Status do Pacote:') ?></label>
    <select id="flgstatus" name="flgstatus" style="width:115px" >
        <option value="1">Ativo</option>
        <option value="0">Inativo</option>
    </select>

    <br style="clear:both" />

    <label for="inpessoa" class="labelNomeParametro"><? echo utf8ToHtml('Tipo de Conta:') ?></label>
    <select id="inpessoa" name="inpessoa" style="width:115px" disabled readonly >
        <option value="1"><? echo utf8ToHtml('Pessoa Física') ?></option>
        <option value="2"><? echo utf8ToHtml('Pessoa Jurídica') ?></option>
    </select>

    <br style="clear:both" />

    <label for="vlsms" class="labelNomeParametro"><? echo utf8ToHtml('Valor da SMS do Pacote:') ?></label>
	<input name="vlsms" id="vlsms" disabled readonly class="registroinput" type="text" style="margin-right: 5px" />

    <br style="clear:both" />

    <label for="vlsmsad" class="labelNomeParametro"><? echo utf8ToHtml('Valor da SMS/Adicional:') ?></label>
	<input name="vlsmsad" id="vlsmsad" disabled readonly class="registroinput" type="text" style="margin-right: 5px" />

    <br style="clear:both" />

    <label for="vlpacote" class="labelNomeParametro"><? echo utf8ToHtml('Valor do Pacote:') ?></label>
	<input name="vlpacote" id="vlpacote" disabled readonly class="registroinput" type="text" style="margin-right: 5px" />

	<br style="clear:both" />
    <br style="clear:both" />

    <hr style="background-color:#666; height:1px;" />

	<div id="divBotoes" style="margin-bottom: 10px;">
		<a href="#" class="botao" id="btVoltar" onClick="FormularioPacote.onClick_Voltar();">Voltar</a>
		<a href="#" class="botao" id="btProsseguir" onClick="FormularioPacote.onClick_Prosseguir();">Prosseguir</a>
	</div>

</form>
</div>
