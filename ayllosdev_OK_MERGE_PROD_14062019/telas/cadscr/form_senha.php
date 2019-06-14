<?php
	/*!
	* FONTE        : form_senha.php					Último ajuste: 01/08/2016
	* CRIAÇÃO      : Jéssica (DB1)
	* DATA CRIAÇÃO : 09/10/2015
	* OBJETIVO     : Formulario para validar a senha dos coordenadores da Tela CADSCR
	* --------------
	* ALTERAÇÕES   : 08/12/2015 - Ajustes de homologação referente a conversão efetuada pela DB1 (Adriano).
	*				  01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	* --------------
	*/ 

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>
<form id="frmSenha" name="frmSenha" class="formulario" style="display:none">
	<fieldset id="fsetSenha" name="fsetSenha" style="padding:0px; margin:0px; padding-bottom:10px;">
	   	<legend>Senha</legend>
		
		<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		<div id="divSenha" >
								
			<label for="operador">Coordenador:</label>
			<input id="operador" name="operador" type="text"/>
		
			<label for="nrdsenha">Senha:</label>
			<input id="nrdsenha" name="nrdsenha" type="password" class="campo"/>																
						
		</div>
	</fieldset>
</form>
