<? 
/*!
 * FONTE        : tabela_bens.php
 * CRIAÇÃO      : Rodolpho Telmo - DB1 Informatica
 * DATA CRIAÇÃO : 03/03/2010 
 * OBJETIVO     : Tabela que apresenda os bens do titular selecionado
 *
 * ALTERACOES   : 05/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
 *                04/04/2019 - Adicionado campos de média de faturamente (Cássia de Oliveira - GFT)
 */
?>
<?
	function retorna_mes ($mes){
	    switch ($mes) {
	   		case 1:
	        	return "Jan";
	        	break;
	    	case 2:
	        	return "Fev";
	        	break;
	    	case 3:
	        	return "Mar";
	        	break;
	        case 4:
	        	return "Abr";
	        	break;
	    	case 5:
	        	return "Mai";
	        	break;
	    	case 6:
	        	return "Jun";
	        	break;
	        case 7:
	        	return "Jul";
	        	break;
	    	case 8:
	        	return "Ago";
	        	break;
	    	case 9:
	        	return "Set";
	        	break;
	        case 10:
	        	return "Out";
	        	break;
	    	case 11:
	        	return "Nov";
	        	break;
	    	case 12:
	        	return "Des";
	        	break;
		}
	}
?>

<div class="divRegistros">
	<table>
		<thead>
			<tr><th><? echo utf8ToHtml(Mês);?></th>
				<th>Ano</th>
				<th>Faturamento</th></tr>			
		</thead>
		<tbody>
			<? $media = 0; 
			   $primeiromes = 0;
			   $primeiroano = 0;
			   $ultimomes = 0;
			   $ultimoano = 0;?>
			<? foreach( $registros as $faturamento ) {
					if ( getByTagName($faturamento->tags,'mesftbru') != 0 && getByTagName($faturamento->tags,'anoftbru') != 0) {
			?>
				<?  $media = $media + (float)str_replace(',','.',getByTagName($faturamento->tags,'vlrftbru')); 
					if($primeiromes == 0){
						$primeiromes = (int)getByTagName($faturamento->tags,'mesftbru');
						$primeiroano = (int)getByTagName($faturamento->tags,'anoftbru');
					} elseif((int)getByTagName($faturamento->tags,'anoftbru') <= $primeiroano){
						if((int)getByTagName($faturamento->tags,'mesftbru') < $primeiromes){
							$primeiromes = (int)getByTagName($faturamento->tags,'mesftbru');
							$primeiroano = (int)getByTagName($faturamento->tags,'anoftbru');
						}
					}
					if($ultimomes == 0){
						$ultimomes = (int)getByTagName($faturamento->tags,'mesftbru');
						$ultimoano = (int)getByTagName($faturamento->tags,'anoftbru');
					} elseif((int)getByTagName($faturamento->tags,'anoftbru') >= $ultimoano){
						if((int)getByTagName($faturamento->tags,'mesftbru') > $ultimomes){
							$ultimomes = (int)getByTagName($faturamento->tags,'mesftbru');
							$ultimoano = (int)getByTagName($faturamento->tags,'anoftbru');
						}
					}
				?>
				<tr><td><span><? echo getByTagName($faturamento->tags,'mesftbru') ?></span>
						<? echo getByTagName($faturamento->tags,'mesftbru') ?>						
						<input type="hidden" id="nrposext" name="nrposext" value="<? echo getByTagName($faturamento->tags,'nrposext') ?>" /></td>
					<td><? echo getByTagName($faturamento->tags,'anoftbru') ?></td>						
					<td><span><? echo str_replace(',','.',getByTagName($faturamento->tags,'vlrftbru')) ?></span>
						<? echo number_format(str_replace(',','.',getByTagName($faturamento->tags,'vlrftbru')),2,',','.') ?></td></tr>				
				<? } ?>
			 <?}?>			
		</tbody>
	</table>
</div>

<div class="divFinanc">
	<? $faturamento = $registros[0]->tags; 
	   $ultimo = end($registros); 
	   $media = $media / count($registros);
	   $primeiromes = retorna_mes($primeiromes);
	   $ultimomes = retorna_mes($ultimomes);
	?>
	<label for="dtaltjfn">Alterado:</label>	
	<input name="dtaltjfn" id="dtaltjfn" type="text" value="<? echo getByTagName($faturamento,'dtaltjfn') ?>" />
	
	<label for="cdoperad">Operador:</label>
	<input name="cdoperad" id="cdoperad" type="text" value="<? echo getByTagName($faturamento,'cdoperad') ?>" />
	<input name="nmoperad" id="nmoperad" type="text" value="<? echo getByTagName($faturamento,'nmoperad') ?>" />

	<label for="vlmediaf">M&eacutedia Faturamento:</label>
	<input name="vlmediaf" id="vlmediaf" type="text" value="<? echo number_format(str_replace(',','.',$media),2,',','.') ?>" />
	<input name="nmperiod" id="nmperiod" type="text" value="<? echo $primeiromes, ' - ', $ultimomes ?>" />
</div>

<div id="divBotoes">

	<? if ($flgcadas == 'M' ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
	<? } else { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);"   />
	<? } ?>

	<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('CA');" />
	<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="controlaOperacao('CE');" />
	<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacao('CI');" />	
	<input type="image" id="btContinuar"  src="<? echo $UrlImagens; ?>botoes/continuar.gif"  onClick="proximaRotina();"   />
	
</div>