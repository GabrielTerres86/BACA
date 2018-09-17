<? 
 /*!
 * FONTE        : form_conalt.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 13/06/2011 
 * OBJETIVO     : Formulário de exibição da tela CONALT
 * --------------
 * ALTERAÇÕES   : 15/06/2010 - Alterado botões com novo estilo. Modificado botão OK para Visualizar (Guilherme Maba).
 *                14/08/2013 - Alteração da sigla PAC para PA (Carlos).
 * --------------
 */	
?>
<form name="frmConalt" id="frmConalt" class="formulario">		
	
	<div id="divAltConta">
		<div id="divAltContaCampos">
			<fieldset>
			
				<legend><? echo utf8ToHtml('Dados da conta') ?></legend>
			
				<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
				<input name="nrdconta" id="nrdconta" type="text" />
				<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

				<label for="dsagenci"><? echo utf8ToHtml('PA:') ?></label>
				<input name="dsagenci" id="dsagenci" type="text" />
				
				<label for="nrmatric"><? echo utf8ToHtml('Matrícula:') ?></label>
				<input name="nrmatric" id="nrmatric" type="text" />


				<label for="dstipcta"><? echo utf8ToHtml('Tipo de Conta:') ?></label>
				<input name="dstipcta" id="dstipcta" type="text" />

				<label for="dtabtcct"><? echo utf8ToHtml('Abertura da Conta:') ?></label>
				<input name="dtabtcct" id="dtabtcct" type="text" />


				<label for="dssititg"><? echo utf8ToHtml('Conta/ITG:') ?></label>
				<input name="dssititg" id="dssititg" type="text" />

				<label for="dtatipct"><? echo utf8ToHtml('Ult.Alt.Tipo de Conta:') ?></label>
				<input name="dtatipct" id="dtatipct" type="text" />

				
				<label for="nmprimtl"><? echo utf8ToHtml('Titulares:') ?></label>
				<input name="nmprimtl" id="nmprimtl" type="text" />
				
				<label for="nmsegntl"></label>
				<input name="nmsegntl" id="nmsegntl" type="text" />
				
			</fieldset>	
		</div>
		<div id="divAltContaTabela">
		</div>
	</div>
	
	<div id="divTransfPAC">
		<div id="divTransfCampos">
			<fieldset>
			
				<legend><? echo utf8ToHtml('Dados de pesquisa') ?></legend>
				<label for="nrpacpac"><? echo utf8ToHtml('PA:') ?></label>
				<label for="nrpacori"><? echo utf8ToHtml('Origem:') ?></label>
				<input name="nrpacori" id="nrpacori" type="text" />		

				<label for="nrpacdes"><? echo utf8ToHtml('Destino:') ?></label>
				<input name="nrpacdes" id="nrpacdes" type="text" />	

				
				<label for="dtperper"><? echo utf8ToHtml('Período:') ?></label>
				<label for="dtperini"><? echo utf8ToHtml('Início:') ?></label>
				<input name="dtperini" id="dtperini" type="text" />			

				<label for="dtperfim"><? echo utf8ToHtml('Fim:') ?></label>
				<input name="dtperfim" id="dtperfim" type="text" />
				
			</fieldset>
		</div>
		<div id="divTransfTabela">
		
		</div>
	
	</div>

</form>

<div id="divBotoes">
	<a href="#" class="botao" id="btVisualizar" onclick="manterRotina();return false;">Visualizar</a>
	<a href="#" class="botao" id="btImprimir" onClick="imprime('Transfer&ecirc;ncia de PA'); return false;">Imprimir</a>
	<a href="#" class="botao" id="btVoltar" onclick="estadoInicial(); return false;">Voltar</a>
</div>