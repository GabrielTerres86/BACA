<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Henrique
 * DATA CRIAÇÃO : 24/06/2011
 * OBJETIVO     : Cabeçalho para a tela ALTERA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * [27/03/2012] Rogérius Militão (DB1) : Novo layout padrão, retirado a tag <br style="clear:both" />;
 * [11/04/2017] Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 */ 
?>

<form id="frmCabAltera" name="frmCabAltera" class="formulario cabecalho">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
	
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" alt="Informe o nro. da conta do cooperado." />
	<a href="#" id="pesquisaAssoc" name="pesquisaAssoc" onClick="mostraPesquisaAssociado('nrdconta','frmCabAltera','');return false;"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" ></a>
	<a href="#" class="botao" id="btBuscaCartao" onclick="carrega_dados();return false;">Ok</a>
	
	<label for="nmprimtl">Titular:</label>
	<input name="nmprimtl" id="nmprimtl" type="text" />
	
	<label for="nrdctitg">Conta ITG:</label>
	<input name="nrdctitg" id="nrdctitg" type="text" />
	
	<br style="clear:both" />	
	
	
</form>
