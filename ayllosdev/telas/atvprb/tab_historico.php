<? 
/*!
 * FONTE        : tab_devedor.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 08/03/2012 
 * OBJETIVO     : Tabela que apresenta os devedores
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
					<th><? echo utf8ToHtml('Dt. Inclusão');  ?></th>
					<th><? echo utf8ToHtml('Dt. Exclusão');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $r ) { ?>
					<tr>
						<td><? echo $r['nrdconta']; ?></td>
						<td><? echo $r['contrato']; ?></td>
						<td><? echo $r['motivo']; ?></td>
						<td><? echo $r['dtinicio']; ?></td>
						<td><? echo $r['dtfinal']; ?></td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>
