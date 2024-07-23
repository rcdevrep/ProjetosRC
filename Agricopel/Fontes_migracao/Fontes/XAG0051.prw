#INCLUDE "RWMAKE.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �XAG0051  �Autor  �Osmar Schimitberger  � Data �  04/04/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para Retorna Filial no LP 001 - contab.Folha        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Agricopel                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function XAG0051(cCnpj)

Local cQuery  := ""
Local cFilQry := ""

cQuery := ""
cQuery += "SELECT * "
cQuery += "FROM EMPRESAS "
cQuery += "WHERE EMP_CNPJ = '"+cCnpj+"' "

If Select("CNPJ") <> 0
	dbSelectArea("CNPJ")
	dbCloseArea()
Endif

TCQuery cQuery NEW ALIAS "CNPJ"

DbSelectArea("CNPJ")
DbGoTop()
While !Eof()
	
	cFilQry:= alltrim(CNPJ->EMP_FIL)
	
	DbSkip()
End

Return(cFilQry)