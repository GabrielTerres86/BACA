<?php
	/*!
	 * FONTE        : form_consulta_assessoria.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 25/08/2015
	 * OBJETIVO     : Consulta de Assessorias para a tela CADCAS
	 * --------------
	 * ALTERAÇÕES   : 19/09/2016 - Inclusão do campo de codigo de acessoria do CYBER, Prj. 302 (Jean Michel)
   *
   *                17/01/2017 - Inclusão campos flgjudic e flextjud, Prj. 432 (Jean Calão / Mout´S)
	 * --------------
	 */
?>
<div id="divConsultaAssessoria" name="divConsultaAssessoria">
	<div id="tabCadcas">
		<div class="divRegistros">
			<table class="tituloRegistros" id="tbCadcas">
				<thead>
					<tr>
						<th><? echo utf8ToHtml("C&oacute;digo");?></th>
						<th><? echo utf8ToHtml("C&oacute;digo CYBER");?></th>
						<th><? echo utf8ToHtml("Nome da Assessoria");?></th>
					    <th><? echo utf8ToHtml("Judicial");?></th>
						<th><? echo utf8ToHtml("Extra Judicial");?></th>
						<th><? echo utf8ToHtml("Sigla Cyber");?></th>
                   </tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div> 
	</div>
</div>
