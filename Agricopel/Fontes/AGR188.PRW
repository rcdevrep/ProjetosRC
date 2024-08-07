#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/* SIGAVILLE
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Cliente      � Agricopel Com. Derivados de Petr�leo Ltda               ���
�������������������������������������������������������������������������Ĵ��
���Programa     � AGR188           � Responsavel � Deco                   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o    � Gatilho que Busca proxima seq. para apontamento visita  ���
�������������������������������������������������������������������������Ĵ��
��� Data        � 12/12/05         � Implantacao �                        ���
�������������������������������������������������������������������������Ĵ��
��� Programador � Deco                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGR188()
**********************                       

LOCAL _cVend    := M->AD5_VEND
LOCAL _cData    := M->AD5_DATA
LOCAL cQuery    := ""             
LOCAL _nSeqAux  := 0
LOCAL _nSeqProx := "00"

cQuery := ""
cQuery += "SELECT MAX(AD5_SEQUEN) AS SEQ "
cQuery += "FROM "+RetSqlName("AD5")+" (NOLOCK) "
cQuery += "WHERE AD5_FILIAL = '"+xFilial("AD5")+"' "
cQuery += "AND D_E_L_E_T_ = '' "	
cQuery += "AND AD5_VEND = '"+_cVend+"' "
cQuery += "AND AD5_DATA = '"+DTOS(_cData)+"' "

If (Select("ALA") <> 0)
	dbSelectArea("ALA")
	dbCloseArea()
Endif

TCQuery cQuery NEW ALIAS "ALA"
  	 	                        	                        
_nSeqAux  := Val(ALA->SEQ)
If Empty(Val(ALA->SEQ))
   _nSeqAux := 0
EndIf
_nSeqAux++
_nSeqProx := Strzero(_nSeqAux,2)

If (Select("ALA") <> 0)
	dbSelectArea("ALA")
	dbCloseArea()
Endif

Return (_nSeqProx)
