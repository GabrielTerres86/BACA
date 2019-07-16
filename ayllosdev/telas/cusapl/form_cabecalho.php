<?
//*********************************************************************************************//
//*** Fonte: form_cabecalho.php                                    						              ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Monta a TELA DE PESQUISA                                                  ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//*********************************************************************************************//
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" class="campo" autofocus onchange="mostracooperativa($(this));">
		<option value="A"><? echo utf8ToHtml('A - Log dos Arquivos de Custódia') ?></option>
		<option value="O"><? echo utf8ToHtml('O - Log das Operações de Custódia Pendentes') ?></option>
		<option value="E"><? echo utf8ToHtml('E - Solicitar Envio dos Arquivos Pendentes') ?></option>
		<option value="R"><? echo utf8ToHtml('R - Solicitar Retorno dos Arquivos Pendentes') ?></option>
		<option value="C"><? echo utf8ToHtml('C – Configuração por Cooperativa da Custódia de Aplicações') ?></option>
		<option value="G"><? echo utf8ToHtml('G – Configuração Geral da Custódia de Aplicações') ?></option>
		<option value="V"><? echo utf8ToHtml('V – Valor Devido B3') ?></option>
	</select>

	<div id="divcdcooper" style="display: none;">
		<label id="tlcooper" for="tlcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
		<select tabindex="1" id="cdcooper" name="cdcooper" class="filtrocooperativa" style="width:100px;">
			<option value="0">Todos</option>
		</select>
	</div>

	<a href="#" class="botao" id="btnOK" onClick="btnOK();return false;" style="text-align: right;">OK</a>

	<br style="clear:both" />
</form>
<script>atualizaCooperativas2(1);</script>
