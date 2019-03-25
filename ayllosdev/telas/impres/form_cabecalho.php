<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 31/08/2011
 * OBJETIVO     : Cabeçalho para a tela IMPRES
 * --------------
 * ALTERAÇÕES   : 29/11/2012 - Alterado botões do tipo tag <input> para
 *					           tag <a> e alteração layout da tela (Daniel).

				  05/01/2016 - Ajsutes para inclusão do relatorio de juros e encargos
							   (Jonatha - RKAM M273).
 *
 *                10/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 *                28/08/2018 - Adicionado campo bordero para desconto de titulo. (Cássia de Oliveira - GFT)
 *	              14/11/2018 - Inserção da lupa para borderôs. (Vitor S Assanuma - GFT))
 * --------------
 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
		
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="I" <? echo $cddopcao == 'I' ? 'selected' : '' ?> >I - Imprimir Extratos Especiais </option> 
		<option value="E" <? echo $cddopcao == 'E' ? 'selected' : '' ?> >E - Excluir Extratos Especiais</option>
		<option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> >C - Consulta Extratos Especiais </option>
	</select>
	<a href="#" class="botao" id="btnOK1">OK</a>
    
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" />
	<a style="margin-top:5px"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

	<br style="clear:both" />	
	
	<label for="tpextrat">Tipo:</label>
	<select id="tpextrat" name="tpextrat">
	<option value="0"></option>
	<option value="1">1 - Conta Corrente</option>
	<option value="2">2 - I.R Fisica</option>
	<option value="3">3 - Emprestimo</option>
	<option value="4">4 - Aplicacao</option>
	<option value="5">5 - Poupanca Programada</option>
	<option value="6">6 - I.R Juridica</option>
	<option value="7">7 - Conta Investimento</option>
	<option value="8">8 - Capital</option>
	<option value="9">9 - Tarifas</option>
	<option value="10">10 - Saldo p/ Resgate de Apli.</option>
	<option value="12">12 - Tarifas Op. de Cr&eacute;dito</option>
	<option id="desctit" value="13">13 - Desconto de t&iacutetulos</option>
	</select>
	<a href="#" class="botao" id="btnOK2">OK</a>
	<div id="nrborderdiv">
		<label for="nrborder">Border&ocirc:</label>
		<input type="text" id="nrborder" name="nrborder" />
		<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<a href="#" class="botao" id="btnOK4">OK</a>
	</div>
	<br style="clear:both" />	
	
</form>