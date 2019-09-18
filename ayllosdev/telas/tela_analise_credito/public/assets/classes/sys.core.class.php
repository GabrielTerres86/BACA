<?php

/* 
*  @author Mout's - Anderson Schloegel
*  Ailos - Projeto 438 - sprint 9 - Tela Única de Análise de Crédito
*  fevereiro/março de 2019
* 
*  Classe principal, carrega configs, cabeçalho, rodapé e estrutura inicial do sistema
*/

class Core {

	// inicializar variáveis
	private $configs = array(
								'env'				=> 'dev',
								'error_reporting'	=> 'E_ALL',
								'header'			=> false,
								'footer'			=> false,
								'charset'			=> 'UTF-8',
								'language'			=> 'pt-br',
								'title'				=> 'Ailos',
								'localhost' 		=> false
								);

	function __construct($configs = array()) {

	    if (count($configs) > 0) {
			$this->configs = array_merge($this->configs, $configs);
		}

		// check
		if($configs['localhost'] === true){
			ini_set('session.cookie_domain', '.cecred.coop.br' );
	        session_start();
  	    }

  	    // check again
		// check if SESSION is started | PHP < 5.4.0
		if(session_id() == ''){
			ini_set('session.cookie_domain', '.cecred.coop.br' );
			session_start();
		}



		/* 
		 * P A N I C !
		 * Página para ativar ou desativar o modo de manutenção do sistema
		 * Quando ativo, o sistema inteiro deixa de ser acessível
		 * 
		 * 
		 */

		require_once '../panic/panic.secret.php';

		if (file_exists('../panic/panic.status.php')) {

		    // lê conteúdo do arquivo
		    $panic_file_content = file_get_contents('../panic/panic.status.php');
		    
		    // verifica status
		    if ($panic_file_content === $secret_crypt) {
		        $panic = true;

		        header('Location: ../panic/panic.show.php');
		        die();
		    }
		}

		// token e conteúdo do PDF
        $_SESSION['token_pdf']      = 0;						// zera token, ou cria zerado caso não exista
        $token_pdf                  = self::generatePassword(); // para gerar PDF
        $_SESSION['token_pdf']      = $token_pdf;           	// para gerar PDF

        // token e conteúdo do JSON
        $_SESSION['token_json']     = 0;						// zera token, ou cria zerado caso não exista
        $token_json                 = self::generatePassword(); // para btn homologação json
        $_SESSION['token_json']     = $token_json;          	// para btn homologação json


		# AMBIENTE - define as configurações baseando-se no ambiente

        //Atualizar configcore para recuperar em modo localhost
        if($configs['localhost']){
            $_SESSION['configCore'] = $configs;
        }

		switch ($this->configs['env']) {

			// dev
			case 'dev':
				error_reporting(E_ALL);
				break;
			
			// prod
			case 'prod':
				error_reporting(0);
				break;
			
			// null
			default:
				die('Ambiente não definido');
				break;
		}

		# header
		if ($this->configs['header'] === true) {
			echo $this->header();
		}
	}

	function __destruct(){

		# footer
		if ($this->configs['footer'] === true) {
			echo $this->footer();
		}
	}

	public function header() {

  	    // check again
		// check if SESSION is started | PHP < 5.4.0
		if(session_id() == ''){
			ini_set('session.cookie_domain', '.cecred.coop.br' );
			session_start();
		}

		// rand para carregar JS
		$v = rand(1000,9999);
		

		?>
			<!doctype html>
			<html lang="<?=$this->configs['language'];?>">
			  <head>
			    <!-- Required meta tags -->
			    <meta charset="<?=$this->configs['charset'];?>">
			    <meta name="viewport"   content="width=device-width, initial-scale=1, shrink-to-fit=no">

			    <!-- Bootstrap CSS -->
			    <link rel="stylesheet"  href="../node_modules/bootstrap/dist/css/bootstrap.min.css">
                <link rel="stylesheet"  href="../public/assets/3rdparty/DataTables/jquery.dataTables.min.css">
			    <link rel="stylesheet"  href="../node_modules/@fortawesome/fontawesome-free/css/all.min.css">
				<link rel="stylesheet"  href="../public/assets/css/style.css">
				<link rel="stylesheet"  href="../public/assets/css/custom.css?v=<?=$v?>">
				<link rel="icon" 		href="../public/assets/images/favicon-96x96.png" />
                <!-- filtroBusca -->
                <link rel="stylesheet"  href="../public/assets/css/filtroBusca.css?v=<?=$v?>">

			    <title><?=$this->configs['title'].($this->configs['localhost']?' - LOCALHOST' : '');?></title>

					<script>
					<?php
						if($this->configs['localhost']){
							?>
								var thisLocalhost = true;
							<?php
						}else{
							?>
								var thisLocalhost = false;
							<?php
						}
					?>
					</script>

			  </head>
			  <body>
				<div id="loading">
					<img src="assets/images/logos/coop0.png" alt="" class="imageAilosLoading"> <br>

					<!-- <div class="spinner"></div> -->
					<div class="loader"></div>
					<!-- <i class="fas fa-spinner fa-spin fa-2x"></i> <br> <br> -->
					<br>carregando informações... <br>

				</div>

				<div class="container-scroller" id="main-content">

				    <!-- partial:partials/_navbar.html -->
				    <nav class="navbar default-layout col-lg-12 col-12 p-0 fixed-top d-flex flex-row">
				      <div class="text-center navbar-brand-wrapper d-flex align-items-top justify-content-center">
				        <a class="navbar-brand brand-logo" href="#">

						<?php 
							// mudar o logo conforme cooperativa
							if (isset($_SESSION['globalCDCOOPER'])) {

								switch ($_SESSION['globalCDCOOPER']) {
									case '1':  echo '<img src="assets/images/logos/coop1.png">';  break;
									case '2':  echo '<img src="assets/images/logos/coop2.png">';  break;
									case '3':  echo '<img src="assets/images/logos/coop3.png">';  break;
									case '4':  echo '<img src="assets/images/logos/coop4.png">';  break;
									case '5':  echo '<img src="assets/images/logos/coop5.png">';  break;
									case '6':  echo '<img src="assets/images/logos/coop6.png">';  break;
									case '7':  echo '<img src="assets/images/logos/coop7.png">';  break;
									case '8':  echo '<img src="assets/images/logos/coop8.png">';  break;
									case '9':  echo '<img src="assets/images/logos/coop9.png">';  break;
									case '10': echo '<img src="assets/images/logos/coop10.png">'; break;
									case '11': echo '<img src="assets/images/logos/coop11.png">'; break;
									case '12': echo '<img src="assets/images/logos/coop12.png">'; break;
									case '13': echo '<img src="assets/images/logos/coop13.png">'; break;
									case '14': echo '<img src="assets/images/logos/coop14.png">'; break;
									case '15': echo '<img src="assets/images/logos/coop15.png">'; break;
									case '16': echo '<img src="assets/images/logos/coop16.png">'; break;
									case '99': echo '<img src="assets/images/logos/coopxy.png">'; break;
									default:   echo '<img src="assets/images/logos/coop3.png">';  break;
								}							
							} else {
								echo '<img src="assets/images/logos/coop3.png">';
							}
						?>

				        </a>
				        <a class="navbar-brand brand-logo-mini" href="#">
				          <img src="assets/images/logos/coop0.png">
				        </a>
				      </div>
				      <div class="navbar-menu-wrapper d-flex align-items-center">
				        <ul class="navbar-nav navbar-nav-left header-links d-none d-md-flex" id="html_personas">
							<!-- AQUI FILTRO DE PERSONAS -->
				        </ul>

				        <button class="navbar-toggler navbar-toggler-right d-lg-none align-self-center" type="button" data-toggle="offcanvas">
				          <i class="fas fa-bars"></i>
				        </button>
				      </div>
				    </nav>

				    <!-- partial -->
				    <div class="container-fluid page-body-wrapper">
				      <!-- partial:partials/_sidebar.html -->

				      <nav class="sidebar sidebar-offcanvas" id="sidebar">

                        <!-- FILTRO DE BUSCA -->
                        <div class="filtroBuscaDiv">
                            <div id="myDropdown" class="dropdown-content">
                                <input type="text" placeholder="Busca..." id="filtroBusca" autofocus="">
                                <div id='searchElements'>
                                	<!-- AQUI RENDERIZA RESULTADOS DA BUSCA -->
                                </div>
                            </div>
                        </div>

				        <ul class="nav" id="html_categorias">
				        	<!-- AQUI RENDERIZA FILTRO DE CATEGORIAS -->
				        	<li>
							<a href="pdf.php?token=<?=$_SESSION['token_pdf'];?>" target="_blank"><button class="btn btn-primary btn-gerar-pdf col-10" style="margin-left:9%; color: #fff;"><i class="fas fa-file-pdf" style="color: #fff !important;"></i> Gerar PDF</button></a>
							</li>
				        </ul>

				      </nav>
				      <!-- partial -->
				      <div class="main-panel">

						<div class="row html_sub_filtro">
							<div class="col-12">
					          <div class="row sub-menu html_avalista"></div>
					          <div class="row sub-menu html_grupo"></div>
					          <div class="row sub-menu html_quadro"></div>
					          <div class="row sub-menu html_contapj"></div>
				          	</div>
				        </div>

				        <div class="content-wrapper">

							<div class="row">
								<div class="col-12">
										<?php

											// echo '<br> globalCDCOOPER :'.$_SESSION['globalCDCOOPER'];
								   //          echo '<br> globalNRDCONTA :'.$_SESSION['globalNRDCONTA'];
								   //          echo '<br> globalCDOPERAD :'.$_SESSION['globalCDOPERAD'];
								   //          echo '<br> globalNRPROPOSTA :'.$_SESSION['globalNRPROPOSTA'];
								   //          echo '<br> globalTPPRODUTO :'.$_SESSION['globalTPPRODUTO'];
								   //          echo '<br> globalDHINICIO :'.$_SESSION['globalDHINICIO'];
            										?>
								</div>
							</div>

 							<div class="row">
								<div class="col-12" id="html_blocos">
							          
									<!-- AQUI RENDERIZA TELAS -->

								</div>
							</div>
				        </div>
		<?php
	}

	public function footer() {

						// rand para carregar JS
						$v = rand(1000,9999);

				  	    // check again
						// check if SESSION is started | PHP < 5.4.0
						if(session_id() == ''){
							ini_set('session.cookie_domain', '.cecred.coop.br' );
							session_start();
						}

						?>

				      </div>
				      <!-- main-panel ends -->
				    </div>
				    <!-- page-body-wrapper ends -->
				  </div>
				  <!-- container-scroller -->

				<div id="side-by-side-bottom" class="row justify-content-center">
					<!-- rodapé que mostra as categorias selecionadas -->
				</div>

				<div id="side-by-side-decide" class="row justify-content-center">
					<!-- tela que mostra qual lado deve ser mostrada a categoria -->
				</div>

				<div id="side-by-side">
					<!-- exibição lado a lado -->
				</div>

				<!-- caixa de diálogo para alertar que uma categoria já foi selecionada para o side by side -->
				<div id="alert-selecionado-backdrop">
					<div id="alert-selecionado">
						<div class="container">
							<div class="row">
								<div class="col-12 text-right">
									<span class="close-alert-selecionado cursor-pointer">x</span>
								</div>
							</div>
							<div class="row">
								<div class="col-12 text-center">
									<p class="alertText">
										<i class="fas fa-info-circle"></i> &nbsp; Categoria já selecionada.
									</p>
								</div>
							</div>
							<div class="row">
								<div class="col-12 text-center">
									<button class="btn btn-primary close-alert-selecionado">ok</button>
								</div>
							</div>
						</div>
					</div>
				</div>

				<!-- BTN para auxiliar na homologação da tela -->
				<!-- <a href="getDataJson.php?token=<?=$_SESSION['token_json']?>" target="_blank">
					<button class="btn-json"><span>dev:</span> JSON</button>
				</a>
				 -->
			    <script src="../node_modules/jquery/dist/jquery.min.js"></script>
			    <script src="../public/assets/js/popper.min.js"></script>
				<script src="../public/assets/js/off-canvas.js"></script>
				<script src="../public/assets/js/misc.js"></script>
                <script src="../public/assets/3rdparty/DataTables/jquery.dataTables.min.js"></script>

				<script src="../public/assets/js/functions.js?v=<?=$v?>"></script>
				<script src="../public/assets/js/SideBySide.js?v=<?=$v?>"></script>
                <script src="../public/assets/js/filtroBusca.js?v=<?=$v?>"></script>
                <script src="../public/assets/js/filtros.js?v=<?=$v?>"></script>
				<script src="../public/assets/js/app.js?v=<?=$v?>"></script>

                <script src="../public/assets/js/plugins/select2.full.min.js"></script>

			  </body>
			</html>
		<?php
	}

	// gerador de caracteres (usado para gerar token pdf e token json)
	function generatePassword($length = 32) {

	    // quais caracteres devem estar na chave gerada
	    $possibleChars  = "abcdefghijklmnopqrstuvxywz0123456789ABCDEFGHIJKLMNOPQRSTUVXYWZ";
	    $password       = '';

	    for($i = 0; $i < $length; $i++) {
	        $rand       = rand(0, strlen($possibleChars) - 1);
	        $password  .= substr($possibleChars, $rand, 1);
	    }

	    return $password;
	}

}
?>