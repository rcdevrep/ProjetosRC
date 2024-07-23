#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR245    �Autor  �Microsiga           � Data �  04/24/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa para Manutencao Romaneio (Incl/Excl/Alter).      ���
���          �                                                            ���
���          �  Criar Arquivos:                                           ���
���          �  SZB - Cabecalho Romaneio de Cargas.                       ���
���          �  SZC - Itens Romaneio de Cargas.                           ���
���          �                                                            ���
���          �  Criar Indices:                                            ���
���          �  SZB - (1) ZB_FILIAL+ZB_NUM                                ���
���          �  SZB - (2) ZB_FILIAL+ZB_NUM+ZB_MOTORIS+DTOS(ZB_DTSAIDA)    ���
���          �  SZC - (1) ZC_FILIAL+ZC_NUM+ZC_DOC                         ���
���          �                                                            ���
���          �  Criar Campos                                              ���
���          �  SF2 - F2_ROMANE 6 C                                       ���
���          �                                                            ���
���          �  Appendar o SF2 E SZ9 para o SXB.                          ���
���          �                                                            ���
���          �  Incluir Gatilho                                           ���
���          �  SZC ZC_DOC 001                                            ���
���          �  EXECBLOCK("AGR245D",.F.,.F.)                              ���
���          �  ZC_COD                                                    ���
���          �  P                                                         ���
���          �  N                                                         ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
