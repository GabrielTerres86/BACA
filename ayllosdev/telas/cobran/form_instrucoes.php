<?
/*!
 * FONTE        : form_instrucoes.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 24/02/2012
 * OBJETIVO     : Formulário Instrucoes
 * --------------
 * ALTERAÇÕES   :  30/12/2015 - Alterações Referente Projeto Negativação Serasa (Daniel)	
 *                 22/09/2017 - Ajustes nas validações para exibir as instruções de Serasa e Protesto (Douglas - Chamado 754911)
 *			       05/10/2018 - Adicionado validação para não exibir Protesto 9 quando sacado estiver em uma UF não autorizada (Anderson Alan - SM_Projeto_352)
 *                 08/05/2019 - inc0012536 adicionada a validação do código da espécie 2 (duplicata de serviço) juntamente 
 *                              com a UF não autorizada. Duplicatas de serviço dos estados listados não podem ir para protesto (Carlos)
 * --------------
 */

?>

<label for="cdinstru"><? echo utf8ToHtml('Instrução:') ?></label>
<select id="cdinstru" name="cdinstru">
<option value="0"></option>


<?php 
//$esta_protestado  =  (( $flgdprot == "yes" || $flgdprot == "YES" ) && ( $qtdiaprt > 0 )) ? 1 : 0;
$esta_em_cartorio =  ( in_array($insitcrt, array('1','2','3') )) ? 1 : 0;
$tem_inst_protest = (( strcasecmp($flgdprot, 'yes') == 0 ) && $qtdiaprt > 0 ) ? 1 : 0;
$esta_protestado  =  ( $insitcrt == '5' ) ? 1 : 0;
$esta_negativado  = (( strcasecmp($flserasa, 'yes') == 0 || $qtdianeg > 0 ) && $inserasa > 0) ? 1 : 0;
$tem_inst_serasa  = strcasecmp($flserasa, 'yes') == 0 || $qtdianeg > 0 ? 1 : 0;

$vr_dtvencto = implode('-', array_reverse(explode('/', $dtvencto)));
$vr_dtmvtolt = implode('-', array_reverse(explode('/', $glbvars['dtmvtolt'])));
$vr_dtvencto = strtotime($vr_dtvencto . ' + '.$qtlimaxp.' days');
$vr_dtmvtolt = strtotime($vr_dtmvtolt);

$exec_inst_auto = $vr_dtvencto > $vr_dtmvtolt ? 1 : 0;
//var_dump($vr_dtvencto,$vr_dtmvtolt,$qtlimaxp,$exec_inst_auto);

foreach( $registro as $r ) { // Cada crapoco de b1wgen0010.busca_instrucoes
    // Por padrão vamos criar a opção da instrução em tela
	$cria_opcao = 1;
	
	if (getByTagName($r->tags,'cdocorre') == 94) { // Instrução Excluir Serasa substituida pela 41 - Cancelar Instrução Automática de Protesto/Serasa
		$cria_opcao = 0;
	}
	
	// Verificar se já esta protestado
	if ($esta_protestado == 1){
		// Não exibir as seguintes regras 
		if( getByTagName($r->tags,'cdocorre') == 93 || // Incluir Serasa
		    getByTagName($r->tags,'cdocorre') == 94 || // Excluir Serasa
			getByTagName($r->tags,'cdocorre') == 9 ) { // Protestar
			// Não criar a opção
			$cria_opcao = 0;
		} 
		// Verifica se o UF está cadastrado, caso não estiver, não permite instrução 81
		if (!$ufCadastrado) {
			if( getByTagName($r->tags,'cdocorre') == 81) { // Excluir Protesto com Carta de Anuência Eletrônica
				// Não criar a opção
				$cria_opcao = 0;
			}
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
		
		// Verifica se o UF sacado está em um UF sem autorização para estar em protesto e 
        // a especie do boleto for DS (duplicata de serviço), caso estiver, não permite instrução 9
		if ($estaEmDsnegufds && $cddespec === 2) {
			if( getByTagName($r->tags,'cdocorre') == 9 || // Protestar
				getByTagName($r->tags, 'cdocorre') == 80) { // Incluir Instrução Automática de Protesto
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
	
	if ($esta_protestado == 0){
		if( getByTagName($r->tags,'cdocorre') == 81) { // Excluir Protesto com Carta de Anuência Eletrônica
			// Não criar a opção
			$cria_opcao = 0;
		} 
		if ($tem_inst_serasa == 0 && $esta_negativado == 0 && $esta_em_cartorio == 0 && $tem_inst_protest == 0){
		// Não está Negativado no Serasa
		if( getByTagName($r->tags,'cdocorre') == 41) { // Cancelar Instrução Automática de Protesto/Serasa
			// Não criar a opção
			$cria_opcao = 0;
		} 
	}
	}
    if ($exec_inst_auto == 0){
		if( getByTagName($r->tags,'cdocorre') == 80) { // Incluir Instrução Automática de Protesto
			// Não criar a opção
			$cria_opcao = 0;
		} 
	}
	
    //$cria_opcao = 1;	
	
	if ($cria_opcao == 1) {?>
        <option value="<? echo getByTagName($r->tags,'cdocorre') ?>"><? echo getByTagName($r->tags,'cdocorre') ?> - <? echo getByTagName($r->tags,'dsocorre') ?></option>
<?php
    }
}
?>

</select>

<a href="#" class="botao" id="btnOk2">Ok</a>
<br style="clear:both" />	



