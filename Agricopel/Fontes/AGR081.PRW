#INCLUDE "RWMAKE.CH"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*SIGAVILLE
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Cliente      ¦ AGRICOPEL                                                ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦Programa     ¦ AGR081.PRW       ¦ Responsavel ¦ ALEXANDRE CAMARGO      ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦Descriçäo    ¦ ATUALIZACAO DO CONTAS A PAGAR VIA LEITORA OU MANUAL     ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Data        ¦ 29/05/01         ¦ Implantacao ¦                        ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Programador ¦ ALEXANDRE CAMARGO                                       ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Objetivos   ¦ MOSTRAR TELA DO CONTAS A PAGAR                          ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Arquivos    ¦ SE2 - Contas a Pagar                                    ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Indices     ¦ Todos os que o usuario escolher do arquivo.             ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Parametros  ¦                                                         ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Observacoes ¦                                                         ¦¦¦
¦¦+-------------+---------------------------------------------------------¦¦¦
¦¦¦ Cuidados na ¦Salvar as Opcoes do Menu antes da atualizacao.           ¦¦¦
¦¦¦ Atualizacao ¦                                                         ¦¦¦
¦¦¦ de versao   ¦                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
SIGAVILLE */
User Function AGR081()
	// +-------------------------------------------------------------+
	// ¦ Define titulo do programa que aparecera na tela             ¦
	// +-------------------------------------------------------------+
	cCadastro  := OemToAnsi("Contas a Pagar")
	
	// +-------------------------------------------------------------+
	// ¦ Define opcoes/botoes para acessar outras consultas.         ¦
	// +-------------------------------------------------------------+                 
	aRotina    := {{OemToAnsi("Pesquisar")  ,'AxPesqui',0,1},;
                       {OemToAnsi("Atualizar Boleto")  ,'ExecBlock("AGR081A",.f.,.f.)',0,2},;
	                  {OemToAnsi("Atualizar Conta Consumo Manual")  ,'ExecBlock("AGR081B",.f.,.f.)',0,2}}
				   
	mBrowse(06, 01, 22, 75, "SE2",,"!E2_SALDO")
Return
