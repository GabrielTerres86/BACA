<?
/*!
 * FONTE        : tab_historico.php
 * CRIAÇÃO      : Marcel Kohls - (AMCom)
 * DATA CRIAÇÃO : 23/03/2018
 * OBJETIVO     : Tabela que apresenta historico de registros de ativo problematico
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

function generateRandomString($length = 10, $minLength = 3) {
    return substr(str_shuffle(str_repeat($x='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', ceil(rand($minLength, $length)/strlen($x)) )),1,$length);
}

$registros = array();
for ($i=0; $i < rand(0, 15) ; $i++) {
	array_push($registros, array('nrdconta'=>rand(0,1000),
								 'contrato'=>rand(0,1000),
								 'motivo'=>generateRandomString(32),
								 'observac'=>'',
								 'dtinicio'=>date("d/m/Y", mt_rand(1262055681,1262055681)),
								 'dtfinal'=>date("d/m/Y", mt_rand(1262055681,1262055681))
								 )
			 );
}
?>

<div id="divConta">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Conta'); ?></th>
					<th><? echo utf8ToHtml('Contrato');  ?></th>
					<th><? echo utf8ToHtml('Motivo');  ?></th>
					<th><? echo utf8ToHtml('Dt. Envio');  ?></th>
					<th><? echo utf8ToHtml('Tipo Envio');  ?></th>
				</tr>
			</thead>
			<tbody>
        <?php foreach( $retornoRotina as $registro ): ?>
					<tr>
            <td><?= getByTagName($registro->tags,'nrdconta'); ?></td>
            <td><?= getByTagName($registro->tags,'nrctremp'); ?></td>
            <td><?= getByTagName($registro->tags,'dsmotivo'); ?></td>
            <td><?= getByTagName($registro->tags,'dataEnvio'); ?></td>
            <td><?= getByTagName($registro->tags,'tipoEnvio'); ?></td>
					</tr>
			  <?php endforeach; ?>
			</tbody>
		</table>
	</div>
</div>

<div id="divBotoes" style="text-align:center; padding-bottom:10px; clear: both; float: none;">
  <a href="#" class="botao" id="btVoltar" onclick="voltarListagem();">Voltar</a>
</div>
