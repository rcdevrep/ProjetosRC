#Include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBX110  � Autor � Pilar S. Albaladejo   � Data � 09.11.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Diario Geral                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBX110(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function CTBX110()

	Local cLinha1 := "Esta rotina foi desativada por estar fora dos padr�es de qualidade e causar lentid�o no Protheus!"
	Local cLinha2 := "Para realizar a impress�o do di�rio cont�bil, favor utilizar a rotina padr�o: CONTAB. GERENCIAL >> Relat�rios >> Di�rios >> Contabil"
	Local cLinha3 := "Duvidas favor entrar em contato com o TI. Obrigado!"

	MsgInfo(cLinha1 + CRLF + CRLF + cLinha2 + CRLF + CRLF + cLinha3, "Aten��o!")

Return()