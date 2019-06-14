<?
/*!
 * FONTE        : imp_completo_pf_html.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 06/04/2010 
 * OBJETIVO     : Responsável por buscar as informações que serão apresentadas no PDF da Ficha Cadastral 
 *                da Pessoa Física e montar o HTML.
 *
 * ALTERACOES	: 05/04/2011 - Passado tprelato = completo para que no imp_fichacadastral, as informacoes
 *							   dos contatos na ficha cadastral a partir da tela contas, nao sejam 
 *							   impressos (Adriano). 
 *
 *				  30/09/2013 - Incluir impressao de cartao assinatura (Jean Michel). 
 *				  19/10/2015 - Projeto Reformulacao cadastral (Tiago Castro - RKAM)
 *
 *                25/04/2018 - Adicionado nova opcao de impresssao Declaracao de FATCA/CRS
 *							   PRJ 414 (Mateus Z - Mouts)
 */	

?>
<style type="text/css">
	p {
		 page-break-before: always;
		 padding: 0px;
		 margin:0px;	
	}
</style>
<?		
	$GLOBALS['tprelato'] = 'ficha_cadastral';
	
	$fichaCadastralComDeclaracaoPEP = true;
	
	include('../ficha_cadastral/imp_fichacadastral_pf_html.php');	
	
	$GLOBALS['tprelato'] = 'completo';
	
	echo "<p>&nbsp;</p>"; $GLOBALS['numPagina']++; $GLOBALS['numLinha'] = 0;
	
	include('imp_abertura_pf_html.php');
	
	//include('imp_termo_pf_html.php');		
	
	include('imp_cartao_ass_pf_html.php');
	
	include('imp_cartao_ass_pj_html.php');
	
	echo "<p>&nbsp;</p>"; $GLOBALS['numPagina']++; $GLOBALS['numLinha'] = 0;

	include('imp_declaracao_fatca_crs_completo_html.php');
	
?>