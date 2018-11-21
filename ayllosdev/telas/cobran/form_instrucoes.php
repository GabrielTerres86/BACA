<?
/*!
 * FONTE        : form_instrucoes.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 24/02/2012
 * OBJETIVO     : Formulário Instrucoes
 * --------------
 * ALTERAÇÕES   :  30/12/2015 - Alterações Referente Projeto Negativação Serasa (Daniel)	
 *                 22/09/2017 - Ajustes nas validações para exibir as instruções de Serasa e Protesto (Douglas - Chamado 754911)
 * --------------
 */

?>

<label for="cdinstru"><? echo utf8ToHtml('Instrução:') ?></label>
<select id="cdinstru" name="cdinstru">
<option value="0"></option>


<?php 
$esta_protestado  =  (( $flgdprot == "yes" || $flgdprot == "YES" ) && ( $qtdiaprt > 0 )) ? 1 : 0;
$esta_negativado  = ((( $flserasa == "yes" || $flserasa == "YES" ) || ( $qtdianeg > 0 )) && ($inserasa > 0)) ? 1 : 0;

foreach( $registro as $r ) {
    // Por padrão vamos criar a opção da instrução em tela
	$cria_opcao = 1;
	// Verificar se já esta protestado
	if ($esta_protestado == 1){
		// Não exibir as seguintes regras 
		if( getByTagName($r->tags,'cdocorre') == 93 || // Incluir Serasa
		    getByTagName($r->tags,'cdocorre') == 94 || // Excluir Serasa
			getByTagName($r->tags,'cdocorre') == 9 ) { // Protestar
			// Não criar a opção
			$cria_opcao = 0;
		} 
	} else {
		// Não está protestado
		if( getByTagName($r->tags,'cdocorre') == 11) { // Sustar Protesto e Manter em Carteira
			// Não criar a opção
			$cria_opcao = 0;
		} 		

        if ( $flgdprot == "no" || $flgdprot == "NO" ) {
			if( getByTagName($r->tags,'cdocorre') == 9  || // Protestar
			    getByTagName($r->tags,'cdocorre') == 11) { // Sustar Protesto e Manter em Carteira
				// Não criar a opção
				$cria_opcao = 0;
			} 
		}
	}

	// Verificar se já esta negativado
	if ($esta_negativado == 1){
		// Não exibir as seguintes regras 
		if( getByTagName($r->tags,'cdocorre') == 93 || // Incluir Serasa
		    getByTagName($r->tags,'cdocorre') == 9  || // Protestar
			getByTagName($r->tags,'cdocorre') == 11) { // Sustar Protesto e Manter em Carteira
			// Não criar a opção
			$cria_opcao = 0;
		} 
	} else {
		// Não está Negativado no Serasa
		if( getByTagName($r->tags,'cdocorre') == 94) { // Exluir Serasa
			// Não criar a opção
			$cria_opcao = 0;
		} 
		
        if ( $flserasa == "no" || $flserasa == "NO" ) {
			if( getByTagName($r->tags,'cdocorre') == 93 || // Incluir Serasa
			    getByTagName($r->tags,'cdocorre') == 94) { // Excluir Serasa
				// Não criar a opção
				$cria_opcao = 0;
			} 
		} 
	}
	
	if (($esta_protestado == 0) && ($esta_negativado == 0)){
		// Não está Negativado no Serasa
		if( getByTagName($r->tags,'cdocorre') == 41) { // Cancelar Instrução Automática de Protesto/Serasa
			// Não criar a opção
			$cria_opcao = 0;
		} 
	}
	
	if ($cria_opcao == 1) {?>
        <option value="<? echo getByTagName($r->tags,'cdocorre') ?>"><? echo getByTagName($r->tags,'cdocorre') ?> - <? echo getByTagName($r->tags,'dsocorre') ?></option>
<?php
    }
}
?>

</select>

<a href="#" class="botao" id="btnOk2">Ok</a>
<br style="clear:both" />	



