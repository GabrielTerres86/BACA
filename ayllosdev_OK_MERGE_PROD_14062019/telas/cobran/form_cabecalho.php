<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 10/02/2012
 * OBJETIVO     : Cabeçalho para a tela COBRAN
 * --------------
 * ALTERAÇÕES   : 28/04/2016 - Inclusao opcao S. PRJ318 - Nova Plataforma de cobrança (Odirlei-AMcom)
 *
 *                10/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * --------------
 */

?>


<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" onchange="document.getElementById('btnOk1').click();">
	<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>><? echo utf8ToHtml('C - Consultar informações de boletos cadastrados no sistema.') ?></option>
	<option value="I" <?php echo $cddopcao == 'I' ? 'selected' : '' ?>><? echo utf8ToHtml('I - Integrar arquivos de cobrança.') ?></option>
	<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?>><? echo utf8ToHtml('R - Imprimir relatórios e consultar na tela.') ?></option>
    <option value="S" <?php echo $cddopcao == 'S' ? 'selected' : '' ?>><? echo utf8ToHtml('S - Consultar Status dos convênios de cobrança.') ?></option>
	</select>

	<a href="#" class="botao" id="btnOk1">Ok</a>
	<br style="clear:both" />	

</form>


