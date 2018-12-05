<?
/* * *********************************************************************

  Fonte: form_filtro.php
  Autor: Thaise - Envolti
  Data : Setembro/2018

  Objetivo  : Mostrar filtro da CONLOG.

  Alterações: 
  

 * ********************************************************************* */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	require_once("../../includes/carrega_permissoes.php");	

	require_once("busca_arlog.php");
	require_once("busca_coop.php");
	
?>
<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">
	
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin-bottom:10px; padding: 10 10 10 10;">
		
		<legend>Filtro</legend>
		
		<div id="divFiltro">

			<label for="dtde" class="rotulo" style="width: 100px">Data de:</label>
			<input type="text" id="dtde" name="dtde" value="01/10/2018"/>
				
			<label for="dtate" class="rotulo-linha" style="width: 117px"><? echo utf8ToHtml('Data até:') ?></label>
			<input type="text" id="dtate" name="dtate"value="02/10/2018" />
			
			<label for="cdcooper" class="rotulo-linha" style="width: 110px">Cooperativa:</label>
			<select id="cdcooper" name="cdcooper">
				<? echo $nmrescop; ?>
			</select>
			
			<label for="nmarqlog" class="rotulo-linha" style="width: 116px">Arquivo Log:</label>
			<select id="nmarqlog" name="nmarqlog">
			<option value="">-- Selecione --</option>
				<? echo $nmarqlog; ?>
			</select>
			<input type="text" id="nmarqlog" name="nmarqlog" />

			<label for="cdprogra" class="rotulo" style="width: 100px">Programa:</label>
			<input type="text" id="cdprogra" name="cdprogra"/>
			
			<label for="tpocorre" class="rotulo-linha" style="width: 117px"><? echo utf8ToHtml('Tipo Ocorrência:') ?></label>
			<select id="tpocorre" name="tpocorre">
				<option value="">-- Selecione --</option>
				<option value="1"><? echo utf8ToHtml('Erro de Negócio') ?></option>
				<option value="2"><? echo utf8ToHtml('Erro não Tratado') ?></option>
				<option value="3">Alerta</option>
				<option value="4"><? echo utf8ToHtml('Informação') ?></option>
			</select>
			
			<label for="cdcriti" class="rotulo-linha" style="width: 110px">Criticidade:</label>
			<select id="cdcriti" name="cdcriti">
				<option value="">-- Selecione --</option>
				<option value="0">Baixa</option>
				<option value="1"><?echo utf8ToHtml('Média')?></option>
				<option value="2">Alta</option>
				<option value="3"><? echo utf8ToHtml('Crítica') ?></option>
			</select>
			
			<label for="tpexecuc" class="rotulo-linha" style="width: 116px"><? echo utf8ToHtml('Tipo Execução:') ?></label>
			<select id="tpexecuc" name="tpexecuc">
				<option value="">-- Selecione --</option>
				<option value="0">Outros</option>
				<option value="1">Batch</option>
				<option value="2">Job</option>
				<option value="3">Online</option>
			</select>
			
			<label for="cdmensag" class="rotulo" style="width: 100px">Cod Mensag:</label>
			<input type="text" id="cdmensag" name="cdmensag"/>
			
			<label for="dsmensag" class="rotulo-linha" style="width: 117px"><? echo utf8ToHtml('Descrição:') ?></label>
			<input type="text" id="dsmensag" name="dsmensag"/>
			
			<label for="clausula" class="rotulo-linha" style="width: 116px"><? echo utf8ToHtml('Cláusula:') ?></label>
			<select type="text" id="clausula" name="clausula">
				<option value="">-- Selecione --</option>
				<option value="IN">IN</option>
				<option value="NOT IN">NOT IN</option>
			</select>
			
			<label for="chamaber" class="rotulo" >Chamado Aberto:</label>
			<select id="chamaber" name="chamaber">
				<option value="">-- Selecione --</option>
				<option value="S">Sim</option>
				<option value="N"><? echo utf8ToHtml('Não') ?></option>
			</select>
			
			<label for="nrchamad" class="rotulo-linha" style="width: 117px">Nr Chamado:</label>
			<input type="text" id="nrchamad" name="nrchamad"/>
			
			<a style="margin-left: 513px;" href="#" class="botao" id="btConsultar" >Consultar</a>
		</div> 
		
	</fieldset>

</form>

