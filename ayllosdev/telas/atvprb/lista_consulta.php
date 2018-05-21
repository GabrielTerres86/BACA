<?
/*!
 * FONTE        : tab_consulta.php
 * CRIAÇÃO      : Marcel Kohls - (AMCom)
 * DATA CRIAÇÃO : 23/03/2018
 * OBJETIVO     : Tabela que apresenta consulta de registros de ativo problematico
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

 include ("dpto_permissoes.php");
?>

<div id="divConta" style="border-bottom: 1px solid #777; padding: 10px 0px;">
  <div style="padding-bottom: 10px;">
    <label><input type="checkbox" id="ckApenasAtivos" name="ckApenasAtivos" style="margin-right:5px;">Exibir apenas os ativos</label>
  </div>
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Conta'); ?></th>
					<th><? echo utf8ToHtml('Contrato');  ?></th>
					<th><? echo utf8ToHtml('Motivo');  ?></th>
					<th><? echo utf8ToHtml('Dt. Inclusão');  ?></th>
					<th><? echo utf8ToHtml('Dt. Exclusão');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?php foreach( $retornoRotina as $registro ): ?>
					<tr>
            <td data-campo="nrdconta"><?= getByTagName($registro->tags,'nrdconta'); ?></td>
            <td data-campo="nrctremp"><?= getByTagName($registro->tags,'nrctremp'); ?></td>
            <td data-campo="dsmotivo"><?= getByTagName($registro->tags,'dsmotivo'); ?></td>
            <td data-campo="dtinclus"><?= getByTagName($registro->tags,'dtinclus'); ?></td>
            <td data-campo="dtexclus"><?= getByTagName($registro->tags,'dtexclus'); ?></td>
            <td data-campo="cdmotivo" style="display:none"><?= getByTagName($registro->tags,'cdmotivo'); ?></td>
            <td data-campo="dsobserv" style="display:none"><?= getByTagName($registro->tags,'dsobserv'); ?></td>
					</tr>
			  <?php endforeach; ?>
			</tbody>
		</table>
	</div>
  <div id="divPesquisaRodape" class="divPesquisaRodape">
    <table>
      <tr>
        <td>
          <?php if (!$ehPrimeiraPagina): ?>
            <a class='paginacaoAnt'><<< Anterior</a>
          <?php endif; ?>
        </td>
        <td>
            Exibindo <?= $regInicial ?> at&eacute; <?= $regFinal ?> de <?= $totRegistros ?>
        </td>
        <td>
          <?php if (!$ehUltimaPagina): ?>
            <a class='paginacaoProx'>Pr&oacute;ximo >>></a>
          <?php endif; ?>
        </td>
      </tr>
    </table>
  </div>
  <div style="padding-top:10px">
    <label for="dsobserv" class="rotulo">Observa&ccedil;&atilde;o:</label>
    <input name="dsobserv" id="dsobserv" type="text"  class="campo" value="<?= $dsobserv ?>" disabled/>
  </div>
</div>

<div id="divBotoes" style="text-align:center; padding-bottom:10px; clear: both; float: none;">
  <a href="#" class="botao" id="btVoltar" onclick="voltarListagem();">Voltar</a>
  <?php if(in_array('I', $glbvars['opcoesTela'])) : ?>
    <a href="#" class="botao" id="btIncluir" onclick="abreIncluir();">Incluir</a>
  <?php endif; ?>
  <?php if(in_array('A', $glbvars['opcoesTela'])) : ?>
    <a href="#" class="botao" id="btAlterar" onclick="abreAlterar();">Alterar</a>
  <?php endif; ?>
  <?php if(in_array('E', $glbvars['opcoesTela'])) : ?>
    <a href="#" class="botao" id="btExcluir" onclick="perguntaExcluir();">Excluir</a>
  <?php endif; ?>
</div>

<script type="text/javascript">
  $('a.paginacaoAnt').unbind('click').bind('click', function() {
    trocaPagina(-1);
  });

  $('a.paginacaoProx').unbind('click').bind('click', function() {
    trocaPagina(1);
  });
</script>
