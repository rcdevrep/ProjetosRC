#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR186    �Autor  �Deco                � Data �  23/11/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa para informar DDD e Telefone correto do cliente  ���
�������������������������������������������������������������������������͹��
���Uso       �  Criar campo SA1 ->  A1_DDD     - C - 03	                 ���
���Uso       �              SA1 ->  A1_TEL     - D - 15                   ���
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

*/


User Function Agr186()
   cCadastro := "Cadastro de Clientes" 
   aRotina   := {{"Pesquisar","AxPesqui",0,1},;
                 {"Alterar",'EXECBLOCK("AGR186A",.F.,.F.)',0,2}}

	Mbrowse(6, 1, 22, 75, "SA1")
Return

