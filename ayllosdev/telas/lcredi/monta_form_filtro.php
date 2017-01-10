<? 
/*!
 * FONTE        : monta_form_filtro.php
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Julho/2016 
 * OBJETIVO     : Monta o form de filtro correspondente a opção selecionada
 * --------------
 * ALTERAÇÕES   : 05/12/2016 - P341-Automatização BACENJUD - Realizar a validação de acesso pelo 
 *                             código do departamento e não mais pela descrição (Renato Darosci)
 */

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
		
   /* Cooperativas singulares podem somente consultar */
   if(($cddopcao != 'C' && $cddopcao != 'F')){

        if( $glbvars['cddepart'] != 8   &&  /* COORD.ADM/FINANCEIRO */
            $glbvars['cddepart'] != 14  &&  /* PRODUTOS             */
            $glbvars['cddepart'] != 20  &&  /* TI                   */
           ($glbvars['cddepart'] ==  11  && /* FINANCEIRO           */
            $glbvars['cdcooper'] != 3)){                      
              
			exibirErro('error','Sistema liberado apenas para Consulta!','Alerta - Ayllos','formataFormularioFiltro();focaCampoErro(\'cddlinha\',\'frmFiltro\');',false);
                
         }  

	}
			
	include('form_filtro.php'); 		
		
?>


<script type="text/javascript">

  formataFiltro();

</script>
