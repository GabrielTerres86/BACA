create or replace and compile java source named "OSCommand" as
import java.io.*;

public class OSCommand {

  /**
	 *  Classe     : ExecComando
	 *  Sistema  : Rotinas genéricas focando em tratamento de seções e SO
	 *  Sigla       : GENE
	 *  Autor      : Marcos E. Martini - Supero
	 *  Data       : Novembro/2012.                   Ultima atualizacao: 20/12/2012
	 *
	 *  Dados referentes ao programa:
	 *  Frequencia: Sempre que for chamada
	 *  Objetivo  : Criar um interface para execução de comandos Shell ou Perl
	 *                     diretamente no SO em que o banco roda.
	 *                     Esta classe será aproveitada pela package GENE0001, onde existem
	 *                     as rotinas que fazem a interface.
	 *  Oracle >> Java e processam o retorno dessa rotina.
	 *  A rotina básica é a GENE0001.pc_interface_OScommand, que é oculta e chamada pelas PC_OSCommand.
	 *
	 * Alteracoes: 20/12/2012 - Implementar alterações para corrigir retorno de comandos Java.
	 *							Remoção de Threads de bufferização para melhorar performance. Petter - Supero.
	 */

	public static void executeCommand(java.lang.String scriptExec, java.lang.String typeCommand, java.lang.String command) {

		String[] finalCommand;
        finalCommand = new String[3];
        finalCommand[0] = scriptExec;
        finalCommand[1] = typeCommand;
        finalCommand[2] = command;
        Process proc;
        String sucesso = "", erro = "", escuta;

        try{
            proc = Runtime.getRuntime().exec(finalCommand);
            proc.waitFor();

            BufferedReader inputSucesso = new BufferedReader(new InputStreamReader(proc.getInputStream()));
            BufferedReader inputErro = new BufferedReader(new InputStreamReader(proc.getErrorStream()));

             while ((escuta = inputSucesso.readLine()) != null) {
                sucesso += escuta + "\n";
            }

            inputSucesso.close();

            while ((escuta = inputErro.readLine()) != null) {
                erro += escuta + "\n";
            }

            inputErro.close();

			if(!sucesso.equals("")){
				System.out.println("OUT");
				System.out.println(sucesso);
			}else{
                if(!erro.equals("")){
					String[] erros = erro.split("Error");
                    String[] exec = command.split(".jar");

                     if(command.length() > 4){
                        if(command.substring(0, 4).equals("java") && exec.length <= 1){
                            if(erros.length > 1){
                                System.out.println("ERR");
                            }else{
                                System.out.println("OUT");
                            }
                        }else{
                            System.out.println("ERR");
                        }
                    }else{
                         System.out.println("ERR");
                    }

                    System.out.println(erro);
                }
            }
        }catch (IOException ex) {
            ex.printStackTrace();
        }catch (InterruptedException ie){
            ie.printStackTrace();
        }
	}

};
/
