<?
/*!
 * FONTE        : form_instrucoes.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 24/02/2012
 * OBJETIVO     : Formulário Instrucoes
 * --------------
 * ALTERAÇÕES   :  30/12/2015 - Alterações Referente Projeto Negativação Serasa (Daniel)	
 * --------------
 */

?>

<label for="cdinstru"><? echo utf8ToHtml('Instrução:') ?></label>
<select id="cdinstru" name="cdinstru">
<option value="0"></option>


<?php foreach( $registro as $r ) { ?>

	<?php if ( ( $flserasa == "no" ) && ( ( getByTagName($r->tags,'cdocorre') == 93 ) || ( getByTagName($r->tags,'cdocorre') == 94 ) ) ) { 
		
		} else {?>

	<option value="<? echo getByTagName($r->tags,'cdocorre') ?>"><? echo getByTagName($r->tags,'cdocorre') ?> - <? echo getByTagName($r->tags,'dsocorre') ?></option>
<?php
}

}
?>

</select>

<a href="#" class="botao" id="btnOk2">Ok</a>
<br style="clear:both" />	



