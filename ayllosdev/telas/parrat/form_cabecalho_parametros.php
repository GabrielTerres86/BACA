<?php
/* 
 * FONTE        : form_cabecalho_parametros.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMcom
 * DATA CRIAÇÃO : 24/01/2019
 * OBJETIVO     : Cabeçalho para a tela PARRAT aba Parametros
 * ALTERAÇÕES   : 08/02/2019 - Adicionado o filtro Cooperativa na consulta e alteração
                               P450 - Luiz Otávio Olinger Momm (AMCOM)
                  04/03/2019 - Adicionado o campo "Habilitar sugestão" para as cooperativas
                               P450 - Luiz Otávio Olinger Momm (AMCOM)
                  14/05/2019 - Retirado o filtro inpessoa da pesquisa a alteração. Vamos sempre atualizar os dois tipos de produtos
                               P450 - Luiz Otávio Olinger Momm (AMCOM)
                  14/08/2019 - Adicionado a opção Modelo Cálculo Rating
                               P450 - Luiz Otávio Olinger Momm (AMCOM)
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
		<label for="cddopcao"><? echo utf8_decode('Opção:') ?></label>
		<select id="cddopcao" name="cddopcao" onchange="parrat_trataCab();">
				<option value="C"><? echo utf8_decode('C - Consultar Parâmetros do Rating') ?></option>
				<option value="A"><? echo utf8_decode('A - Alterar Parâmetros do Rating') ?></option>
				<option value="P"><? echo utf8_decode('P - Habilitar Alteração Rating') ?></option>
				<option value="B"><? echo utf8_decode('B - Alterar Birô Rating') ?></option>
				<option value="M"><? echo utf8_decode('M - Modelo Cálculo Rating') ?></option>
		</select>

		<label for="formPesquisa_pr_tpproduto"><? echo utf8_decode('Tipo Produto:') ?></label>
		<select id="formPesquisa_pr_tpproduto" name="formPesquisa_pr_tpproduto">
				<option value="90"><? echo utf8_decode('Empréstimo/financiamento') ?></option>
				<option value="2"><? echo utf8_decode('Limite Desconto Cheque') ?></option>
				<option value="1"><? echo utf8_decode('Limite Crédito') ?></option>
				<option value="3"><? echo utf8_decode('Limite de Desconto de Título') ?></option>
		</select>

		<label for="formPesquisa_pr_cooperat"><? echo utf8ToHtml('Cooperativa:') ?></label>
		<select id="formPesquisa_pr_cooperat" name="formPesquisa_pr_cooperat">
		</select>

		<a href="#" class="botao" id="btnOK" name="btnOK" onClick="controlaOperacao(); return false;" style = "margin-left: 10px; text-align:center;">OK</a>

		<br style="clear:both" />
</form>
