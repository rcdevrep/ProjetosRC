#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR116    �Autor  �Microsiga           � Data �  05/12/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa facilidador para manipulacao na Tabela de Precos. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AGR116()

	Local cLinha1 := "Esta rotina foi desativada por estar fora dos padr�es de qualidade e causar lentid�o no Protheus!"
	Local cLinha2 := "Para inserir novos produtos nas tabelas de venda, favor utilizar a rotina padr�o: CALLCENTER >> Atualizacoes >> Cenarios de Venda >> Tabelas de Precos"
	Local cLinha3 := "Duvidas favor entrar em contato com o TI. Obrigado!"

	MsgInfo(cLinha1 + CRLF + CRLF + cLinha2 + CRLF + CRLF + cLinha3, "Aten��o!")

Return()