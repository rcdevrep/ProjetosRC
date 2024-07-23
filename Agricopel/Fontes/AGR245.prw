#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGR245    บAutor  ณMicrosiga           บ Data ณ  04/24/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Programa para Manutencao Romaneio (Incl/Excl/Alter).      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ  Criar Arquivos:                                           บฑฑ
ฑฑบ          ณ  SZB - Cabecalho Romaneio de Cargas.                       บฑฑ
ฑฑบ          ณ  SZC - Itens Romaneio de Cargas.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ  Criar Indices:                                            บฑฑ
ฑฑบ          ณ  SZB - (1) ZB_FILIAL+ZB_NUM                                บฑฑ
ฑฑบ          ณ  SZB - (2) ZB_FILIAL+ZB_NUM+ZB_MOTORIS+DTOS(ZB_DTSAIDA)    บฑฑ
ฑฑบ          ณ  SZC - (1) ZC_FILIAL+ZC_NUM+ZC_DOC                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ  Criar Campos                                              บฑฑ
ฑฑบ          ณ  SF2 - F2_ROMANE 6 C                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ  Appendar o SF2 E SZ9 para o SXB.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ  Incluir Gatilho                                           บฑฑ
ฑฑบ          ณ  SZC ZC_DOC 001                                            บฑฑ
ฑฑบ          ณ  EXECBLOCK("AGR245D",.F.,.F.)                              บฑฑ
ฑฑบ          ณ  ZC_COD                                                    บฑฑ
ฑฑบ          ณ  P                                                         บฑฑ
ฑฑบ          ณ  N                                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function AGR245()

	PRIVATE aRotina  := {}
	PRIVATE aHeader  := {}
	PRIVATE aCols    := {}    
	PRIVATE nUsado   := 0
   
	cCadastro := "Romaneio de Cargas Agricopel" 
 	aRotina   := {{"Pesquisar","AxPesqui",0,1},;
				  {"Incluir",'EXECBLOCK("AGR245A",.F.,.F.)',0,3},;
 				  {"Alterar",'EXECBLOCK("AGR245B",.F.,.F.)',0,4},;
                  {"Excluir",'EXECBLOCK("AGR245C",.F.,.F.)',0,5},;
                  {"Importar Prog.",'EXECBLOCK("AGR245F",.F.,.F.)',0,6},;
				  {"Imprimir",'EXECBLOCK("AGR246",.F.,.F.)',0,3}}

	Mbrowse(6, 1, 22, 75, "SZB")
Return
