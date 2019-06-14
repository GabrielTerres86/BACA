<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 01/12/2011
 * OBJETIVO     : Cabeçalho para a tela CONSCR
 * --------------
 * ALTERAÇÕES   :
 * 001: 21/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * 002: 14/08/2013 - Carlos (CECRED) : Alteração da sigla PAC para PA.
 * 003: 10/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input type="hidden" name="nrdcoaux" id="nrdcoaux" value="" />
	<input type="hidden" name="nrcpfaux" id="nrcpfaux" value="" />
	<input type="hidden" name="nmprimtl" id="nmprimtl" value="" >
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
	<input type="hidden" name="crm_nrcpfcgc" id="crm_nrcpfcgc" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRCPFCGC']; ?>" />

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" alt="<? echo utf8ToHtml('Clique no botão PROSSEGUIR ou  pressione ENTER para continuar.') ?>">
		<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?> > C - Consulta </option> 
		<option value="F" <?php echo $cddopcao == 'F' ? 'selected' : '' ?> > F - Fluxo </option>
		<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?> > R - Impressao </option>
		<option value="M" <?php echo $cddopcao == 'M' ? 'selected' : '' ?> > M - Modalidade </option>
		<option value="H" <?php echo $cddopcao == 'H' ? 'selected' : '' ?> > H - Historico </option>
	</select>
		
	<label for="tpconsul">Consulta:</label>
	<select id="tpconsul" name="tpconsul" alt="<? echo utf8ToHtml('Clique no botão PROSSEGUIR ou  pressione ENTER para continuar.') ?>">
		<option value="1" <?php echo $tpconsul == '1' ? 'selected' : '' ?> > 1 - CPF/CNPJ </option> 
		<option value="2" <?php echo $tpconsul == '2' ? 'selected' : '' ?> > 2 - Conta Corrente </option>
		<option value="3" <?php echo $tpconsul == '3' ? 'selected' : '' ?> > 3 - PA </option>
	</select>

	<label for="nrdconta">Conta:</label>
	<input id="nrdconta" name="nrdconta" type="text" value="<?php echo formataContaDV( $nrdconta ) ?>" autocomplete="off" alt="Informe o numero da conta ou F7 para pesquisar." />
	<a style="margin-top:5px"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

	<label for="nrcpfcgc"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
	<input id="nrcpfcgc" name="nrcpfcgc" type="text" value="<?php echo $nrcpfcgc ?>" autocomplete="off" alt="Informe o numero CPF/CNPJ do cooperado." />
	
	<label for="cdagenci">PA:</label>
	<input id="cdagenci" name="cdagenci" type="text" value="<?php echo $cdagenci ?>" autocomplete="off" alt="Informe numero do PA."/>

	<br style="clear:both" />	

</form>

<!-- <div id="divMsgAjuda"> -->
	<!--- <span><? /*echo utf8ToHtml('Clique no botão PROSSEGUIR ou pressione ENTER para continuar.') */?></span> 

	<div id="divBotoes" >
		<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onclick="selecionaTabela(); return false;">Prosseguir</a>
	</div> 

<!--- </div>		-->																	
