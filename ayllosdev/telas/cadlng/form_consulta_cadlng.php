<?
/******************************************************************
  Fonte        : form_consulta_cadlng.php
  Criação      : Adriano
  Data criação : Outubro/2011
  Objetivo     : Form de consulta CADLNG.
  --------------
  Alterações   :
  --------------
 *****************************************************************/ 
?>

<form id="frmConCadlng" name="frmConCadlng" class="formulario">	
		
	<label for="tppesqui">Procurar por:</label>
	<input name="tppesqui" id="cpfcgc" type="radio" class="radio" />
	<label for="cpfcgcRadio" class="radio">Número CPF/CNPJ</label>
	<input name="tppesqui" id="nome" type="radio" class="radio" />
	<label for="nomeRadio" class="radio">Nome</label>
	
	<br />
		
	<div id="divCpf">
		<label for="consucpf"><? echo utf8ToHtml('Digite o n&uacute;mero do CPF/CNPJ:') ?></label>
		<input name="consucpf" id="consucpf" type="text" />
	</div>
		
	<div id="divNome">
		<label for="consupes"><? echo utf8ToHtml('Informe o nome:') ?></label>
		<input name="consupes" id="consupes" type="text" />
	</div>
		
	<br />
	<br />
		
	<div id="divDetalheConsulta">
	
	</div>
		
	<br/ >
	
	<div id="divBtConsulta">
		<span></span>
		<input type="image" id="btConsulta" src="<? echo $UrlImagens; ?>botoes/consultar.gif" onClick="realizaConsulta(1,30);return false;" />
	</div>
	
	
</form>