<?php 
    /************************************************************************
      Fonte: principal_imprimir.php
      Autor: ???
      Data : ???                      Última Alteração: 21/07/2016
      
      Alterações: 09/07/2012 - Retirado campo "redirect" do form.
	  						 Jorge (CECRED)
      
	  		      10/09/2012 - Preparação para outros tipos de
                               relatório de Aplicação
	  			        	   Guilherme (SUPERO)
	  			  						 
	  			  30/04/2014 - Ajuste referente ao projeto Captação:
	  			  			   - Layout dos botões
	  			  			   - Verficar se fonte está sendo chamado via
	  			  			     método POST
				  			   - Retirado códigos que estavam comentados
	  			  		       (Adriano).
	  			 
				  21/07/2016 - Removi o comando session_start pois este fonte
							   esta sendo incluido em outro fonte que ja possui
							   o comando. SD 479874 (Carlos R).			  

	************************************************************************/
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
?>	  

<div id="divImprimir">

	<form action="" method="post" name="frmImpressao" id="frmImpressao" class="formulario" onSubmit="return false;">

		<fieldset>
		<legend>Impressão</legend>

		<label for="tpmodelo">Modelo:</label>
		<select name="tpmodelo" id="tpmodelo">
			<option value="1">Demonstrativo</option>
			<option value="2">Extrato Analítico</option>
			<option value="3">Extrato Sintético</option>				
		</select>

		<div id="divImpPeriodo">
		<br />

		<label for="dtiniper">Perído:</label>
		<input name="dtiniper" type="text" id="dtiniper" class="campo" autocomplete="no" value="" maxlength="7" size="8" />
		<label for="dtfimper">&nbsp;&nbsp;até&nbsp;&nbsp;</label>
		<input name="dtfimper" type="text" id="dtfimper" class="campo" autocomplete="no" value="" maxlength="7" size="8" />
		</div>

		<br />
					
		<label for="tprelato">Tipo:</label>
		<select name="tprelato" id="tprelato">
			<option value="1" selected>Específico</option>
			<option value="2">Todos</option>				
			<option value="3">Com Saldo</option>
			<option value="4">Sem Saldo</option>
		</select>

		<br />

		<label for="tpaplic2">Aplicação:</label>
		<input name="tpaplic2" id="tpaplic2" type="text" value="" autocomplete="no" class="campo"/>
		
		<br />

		</fieldset>
		
		<input type="hidden" name="dtdehoje" id="dtdehoje" value="<?php echo $glbvars["dtmvtolt"]; ?>">

	</form>

	<div id="divBtnImpressao" style="margin:9px">
	
		<a href="#" class="botao" id="btVoltar" onClick="voltarDivPrincipal();return false;">Voltar</a>
		<a href="#" class="botao" id="btPrint" onClick="imprimirValidar();return false;">Imprimir</a>
	
	</div>

    <form name="frmImprimir" id="frmImprimir" action="<?php echo $UrlSite; ?>telas/atenda/aplicacoes/imprimir_relatorio.php" method="post">

        <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
   </form>

</div>
